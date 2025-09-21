local async = require 'isthatcentered.vtsls.async'
local config = require 'isthatcentered.vtsls.config'

local path_sep = package.config:sub(1, 1)

local function to_file_range_request_args(file, range)
  return {
    file = file,
    startLine = range.start.line + 1,
    startOffset = range.start.character + 1,
    endLine = range['end'].line + 1,
    endOffset = range['end'].character + 1,
  }
end

local has_telescope
local function get_default_telescope_opts(items)
  if has_telescope == nil then
    has_telescope = pcall(require, 'telescope')
  end
  if not has_telescope then
    return {}
  end
  local finders = require 'telescope.finders'
  local file_entry_maker = require('telescope.make_entry').gen_from_file()

  return require('telescope.themes').get_dropdown {
    finder = finders.new_table {
      results = items,
      entry_maker = function(item)
        local path = item[1]
        local idx = item[3]
        if idx == 1 then
          -- enter input option
          return {
            display = item[2],
            ordinal = '',
            value = item,
          }
        else
          local entry = file_entry_maker(path)
          -- entry is rebuilt because the value should be item(table), not string
          return {
            display = function()
              return entry:display()
            end,
            ordinal = path,
            filename = path,
            value = item,
          }
        end
      end,
      no_ignore = true,
    },
  }
end

return function(client)
  local function get_target_file(uri, range)
    local bufnr = vim.uri_to_bufnr(uri)
    local fname = vim.uri_to_fname(uri)

    local err, response = async.request(client, 'workspace/executeCommand', {
      command = 'typescript.tsserverRequest',
      arguments = { 'getMoveToRefactoringFileSuggestions', to_file_range_request_args(fname, range) },
    }, bufnr)

    if err or response.type ~= 'response' or not response.body then
      error('get candidate target files failed: ' .. vim.inspect(response))
    end

    local files = response.body.files
    local items = { { '', 'Enter new file path...', 1 } }

    async.schedule()
    for i = 1, #files do
      local path = files[i]
      table.insert(items, { path, vim.fn.fnamemodify(path, ':.'), i + 1 })
    end

    local telescope_opts = get_default_telescope_opts(items)
    if config.get().refactor_move_to_file.telescope_opts then
      telescope_opts = config.get().refactor_move_to_file.telescope_opts(items, telescope_opts)
    end

    local item, idx = async.call(vim.ui.select, items, {
      prompt = 'Select move destination:',
      kind = 'nvim_vtsls_move_to_file_destination',
      format_item = function(item)
        return item[2]
      end,
      telescope = telescope_opts,
    })

    if not item then -- selection cancelled
      return
    end

    if idx == 1 then
      return async.call(vim.ui.input, {
        prompt = 'Enter move destination:',
        default = vim.fn.fnamemodify(fname, ':h') .. path_sep,
        completion = 'file',
      })
    else
      return item[1]
    end
  end

  local function move_to_file_handler(command)
    async.exec(
      function()
        local args = command.arguments
        local action = args[1]
        local uri = args[2]
        local range = args[3]

        --[[
        -- 
{ "Command", {
    arguments = { {
        description = "Move to file",
        kind = "refactor.move.file",
        name = "Move to file",
        range = {
          ["end"] = {
            line = 16,
            offset = 23
          },
          start = {
            line = 16,
            offset = 1
          }
        }
      }, "file:///Users/edouardpenin/Test/random-ts-project-for-test/src/index.ts", {
        This is where I asked for refactorings
        ["end"] = {
          character = 6,
          line = 15
        },
        start = {
          character = 6,
          line = 15
        }
      } },
    command = "_typescript.moveToFileRefactoring",
    title = "Move to file"
  } }
        --]]

        --[[
        --{ "typescript.tsserverRequest", { "getMoveToRefactoringFileSuggestions", {
        endLine = 16,
        endOffset = 7,
        file = "/Users/edouardpenin/Test/random-ts-project-for-test/src/index.ts",
        startLine = 16,
        startOffset = 7
      } } }
        --]]
        vim.print { 'Command', command }

        local bufnr = vim.uri_to_bufnr(uri)
        local target_file = get_target_file(uri, range)

        --[[
        --{ "After get file", "_typescript.moveToFileRefactoring", { {
      description = "Move to file",
      kind = "refactor.move.file",
      name = "Move to file",
      range = {
        ["end"] = {
          line = 16,
          offset = 23
        },
        start = {
          line = 16,
          offset = 1
        }
      }
    }, "file:///Users/edouardpenin/Test/random-ts-project-for-test/src/index.ts", {
      ["end"] = {
        character = 6,
        line = 15
      },
      start = {
        character = 6,
        line = 15
      }
    }, "/Users/edouardpenin/Test/random-ts-project-for-test/src/blah.ts" } }
        --]]
        vim.print { 'After get file', command.command, { action, uri, range, target_file } }

        if target_file then
          async.request(client, 'workspace/executeCommand', {
            command = command.command,
            arguments = { action, uri, range, target_file },
          }, bufnr)
        end
      end, --
      config.get().default_resolve,
      config.get().default_reject
    )
  end

  return move_to_file_handler
end
