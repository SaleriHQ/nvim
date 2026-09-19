local M = {}

local api = vim.api
local fn = vim.fn
local cs61b_root = fn.expand('~/workSpace/CS61B')

local single_test_runner = {
    'import org.junit.runner.JUnitCore;',
    'import org.junit.runner.Request;',
    'import org.junit.runner.Result;',
    'import org.junit.runner.notification.Failure;',
    '',
    'public final class NvimJUnitSingleRunner {',
    '    public static void main(String[] args) throws Exception {',
    '        Result result = new JUnitCore().run(',
    '            Request.method(Class.forName(args[0]), args[1])',
    '        );',
    '',
    '        for (Failure failure : result.getFailures()) {',
    '            System.err.println(failure);',
    '            failure.getException().printStackTrace(System.err);',
    '        }',
    '',
    '        System.out.printf(',
    '            "Tests run: %d, Failures: %d, Ignored: %d, Time: %.3fs%n",',
    '            result.getRunCount(),',
    '            result.getFailureCount(),',
    '            result.getIgnoreCount(),',
    '            result.getRunTime() / 1000.0',
    '        );',
    '        System.exit(result.wasSuccessful() ? 0 : 1);',
    '    }',
    '}',
}

local function notify(message, level)
    vim.notify(message, level or vim.log.levels.ERROR, { title = 'Java Runner' })
end

local function shell_join(arguments)
    return table.concat(vim.tbl_map(fn.shellescape, arguments), ' ')
end

local function java_context()
    local bufnr = api.nvim_get_current_buf()
    if vim.bo[bufnr].filetype ~= 'java' then
        notify('当前缓冲区不是 Java 文件')
        return
    end

    local file = api.nvim_buf_get_name(bufnr)
    if file == '' then
        notify('请先保存当前 Java 文件')
        return
    end

    local ok, err = pcall(vim.cmd, 'silent update')
    if not ok then
        notify('保存文件失败：' .. tostring(err))
        return
    end

    local lines = api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local package_name
    for _, line in ipairs(lines) do
        package_name = line:match('^%s*package%s+([%a_][%w_%.]*)%s*;')
        if package_name then
            break
        end
    end

    local class_name = fn.fnamemodify(file, ':t:r')
    local qualified_name = package_name and (package_name .. '.' .. class_name) or class_name
    local source_root = fn.fnamemodify(file, ':h')
    if package_name then
        local package_path = package_name:gsub('%.', '/')
        if source_root:sub(-#package_path) == package_path then
            source_root = source_root:sub(1, #source_root - #package_path - 1)
        end
    end
    local clients = vim.lsp.get_clients({ bufnr = bufnr, name = 'jdtls' })
    local client = clients[1]

    if not client then
        notify('JDTLS 尚未附加到当前文件，请等待项目初始化完成后重试')
        return
    end

    return {
        bufnr = bufnr,
        client = client,
        file = file,
        lines = lines,
        class_name = class_name,
        qualified_name = qualified_name,
        root = client.config.root_dir or fn.fnamemodify(file, ':h'),
        source_root = source_root,
        uri = vim.uri_from_bufnr(bufnr),
    }
end

local function add_path(paths, seen, path)
    if not seen[path] and (fn.filereadable(path) == 1 or fn.isdirectory(path) == 1) then
        seen[path] = true
        table.insert(paths, path)
    end
end

local function with_classpath(context, scope, callback)
    local params = {
        command = 'java.project.getClasspaths',
        arguments = { context.uri, vim.json.encode({ scope = scope }) },
    }

    context.client:request('workspace/executeCommand', params, function(err, result)
        vim.schedule(function()
            if err then
                notify('JDTLS 获取 classpath 失败：' .. (err.message or vim.inspect(err)))
                return
            end

            if not result or not result.classpaths then
                notify('JDTLS 没有返回可用的 classpath，请先修复当前项目的编译错误')
                return
            end

            local paths, seen = {}, {}
            for _, path in ipairs(result.classpaths or {}) do
                add_path(paths, seen, path)
            end
            for _, path in ipairs(result.modulepaths or {}) do
                add_path(paths, seen, path)
            end

            -- CS61B 的父 POM 指向一些不存在的本地 Maven 坐标；实际依赖在课程仓库中。
            if vim.fs.normalize(context.root):sub(1, #vim.fs.normalize(cs61b_root))
                == vim.fs.normalize(cs61b_root) then
                local jar_patterns = {
                    cs61b_root .. '/library-sp21/javalib/*.jar',
                    cs61b_root .. '/proj0/javalib/*.jar',
                }
                for _, pattern in ipairs(jar_patterns) do
                    for _, jar in ipairs(fn.glob(pattern, false, true)) do
                        add_path(paths, seen, jar)
                    end
                end
            end
            callback(paths)
        end)
    end, context.bufnr)
end

local function output_directory(context)
    local directory = fn.stdpath('cache')
        .. '/java-runner/classes/'
        .. fn.sha256(context.root):sub(1, 12)
    fn.mkdir(directory, 'p')
    return directory
end

local function run_in_terminal(command, cwd)
    local Terminal = require('toggleterm.terminal').Terminal
    local terminal = Terminal:new({
        count = 1,
        direction = 'float',
        display_name = 'Java',
    })

    terminal:open(nil, 'float')
    if terminal.job_id then
        -- 如果上一次运行仍未结束，先停止它，再发送新的命令。
        fn.chansend(terminal.job_id, string.char(3))
    end

    vim.defer_fn(function()
        terminal:send('cd ' .. fn.shellescape(cwd) .. ' && clear && ' .. command, false)
    end, 50)
end

local function compile_command(context, classpaths, extra_sources)
    local javac = fn.exepath('javac')
    if javac == '' then
        notify('找不到 javac，请确认 JDK 已加入 PATH')
        return
    end

    local separator = fn.has('win32') == 1 and ';' or ':'
    local output = output_directory(context)
    local compile_paths = { output }
    vim.list_extend(compile_paths, classpaths)

    local source_paths, seen_source_paths = {}, {}
    local candidates = {
        context.source_root,
        context.root .. '/src/main/java',
        context.root .. '/src/test/java',
        context.root,
    }
    for _, path in ipairs(candidates) do
        if not seen_source_paths[path] and fn.isdirectory(path) == 1 then
            seen_source_paths[path] = true
            table.insert(source_paths, path)
        end
    end

    local arguments = {
        javac,
        '-cp',
        table.concat(compile_paths, separator),
        '-sourcepath',
        table.concat(source_paths, separator),
        '-d',
        output,
        context.file,
    }
    vim.list_extend(arguments, extra_sources or {})

    return shell_join(arguments), output, separator
end

local function java_command(classpaths, output, separator, main_class, arguments)
    local java = fn.exepath('java')
    if java == '' then
        notify('找不到 java，请确认 JDK 已加入 PATH')
        return
    end

    local runtime_paths = { output }
    vim.list_extend(runtime_paths, classpaths)
    local command = {
        java,
        '-ea',
        '-cp',
        table.concat(runtime_paths, separator),
        main_class,
    }
    vim.list_extend(command, arguments or {})
    return shell_join(command)
end

local function contains(lines, pattern)
    for _, line in ipairs(lines) do
        if line:match(pattern) then
            return true
        end
    end
    return false
end

local function test_method_at_cursor(context)
    local node = vim.treesitter.get_node({ bufnr = context.bufnr })
    while node and node:type() ~= 'method_declaration' do
        node = node:parent()
    end

    if node then
        local text = vim.treesitter.get_node_text(node, context.bufnr)
        local name_node = node:field('name')[1]
        if name_node and text:match('@[%w_%.]*Test') then
            return vim.treesitter.get_node_text(name_node, context.bufnr)
        end
    end

    -- Treesitter 不可用时，允许光标停在 @Test 上，并向下寻找方法声明。
    local cursor_line = api.nvim_win_get_cursor(0)[1]
    if not (context.lines[cursor_line] or ''):match('@[%w_%.]*Test') then
        return
    end

    local ignored = { ['if'] = true, ['for'] = true, ['while'] = true, ['switch'] = true, ['catch'] = true }
    for line_number = cursor_line + 1, math.min(#context.lines, cursor_line + 12) do
        local line = context.lines[line_number]
        if not line:match('^%s*@') then
            local before_parenthesis = line:match('^(.-)%(')
            local name = before_parenthesis and before_parenthesis:match('([%a_][%w_]*)%s*$')
            if name and not ignored[name] then
                return name
            end
        end
    end
end

function M.run_main()
    local context = java_context()
    if not context then
        return
    end
    if not contains(context.lines, 'static%s+void%s+main%s*%(') then
        notify('当前文件中没有找到 static void main(...)')
        return
    end

    with_classpath(context, 'runtime', function(classpaths)
        local compile, output, separator = compile_command(context, classpaths)
        if not compile then
            return
        end
        local run = java_command(classpaths, output, separator, context.qualified_name)
        if run then
            run_in_terminal(compile .. ' && ' .. run, context.root)
        end
    end)
end

function M.run_test_class()
    local context = java_context()
    if not context then
        return
    end
    if not contains(context.lines, '@[%w_%.]*Test') then
        notify('当前文件中没有找到 @Test 测试')
        return
    end

    with_classpath(context, 'test', function(classpaths)
        local compile, output, separator = compile_command(context, classpaths)
        if not compile then
            return
        end
        local run = java_command(
            classpaths,
            output,
            separator,
            'org.junit.runner.JUnitCore',
            { context.qualified_name }
        )
        if run then
            run_in_terminal(compile .. ' && ' .. run, context.root)
        end
    end)
end

function M.run_test_method()
    local context = java_context()
    if not context then
        return
    end

    local method_name = test_method_at_cursor(context)
    if not method_name then
        notify('光标所在位置不是带有 @Test 的测试方法')
        return
    end

    with_classpath(context, 'test', function(classpaths)
        local runner_directory = fn.stdpath('cache') .. '/java-runner'
        local runner_file = runner_directory .. '/NvimJUnitSingleRunner.java'
        fn.mkdir(runner_directory, 'p')
        fn.writefile(single_test_runner, runner_file)

        local compile, output, separator = compile_command(context, classpaths, { runner_file })
        if not compile then
            return
        end
        local run = java_command(
            classpaths,
            output,
            separator,
            'NvimJUnitSingleRunner',
            { context.qualified_name, method_name }
        )
        if run then
            run_in_terminal(compile .. ' && ' .. run, context.root)
        end
    end)
end

return M
