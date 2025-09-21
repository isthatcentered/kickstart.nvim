local M = {}

function M.setup()
  vim.print 'registered'

  vim.lsp.commands['_typescript.moveToFileRefactoring'] = function(command, defaultHandler)
    local client = vim.lsp.get_clients({ name = 'vtsls', bufnr = 0 })[1]
    command.targetFile = '/Users/edouardpenin/Test/random-ts-project-for-test/src/blah.ts'

    if not client then
      vim.notify('No vtsls client attached', vim.log.levels.ERROR)
      return
    end

    command.arguments[1].targetFile = '/Users/edouardpenin/Test/random-ts-project-for-test/src/blah2.ts'
    client:request('workspace/executeCommand', command, function(err, result, ctx, config)
      vim.print(err, result, ctx, config)
      if err then
        vim.notify('MoveToFileRefactoring failed: ' .. vim.inspect(err), vim.log.levels.ERROR)
        return
      end
      if result then
        vim.lsp.handlers['workspace/executeCommand'](err, result, ctx, config)
      else
        vim.notify('No result from moveToFileRefactoring', vim.log.levels.WARN)
      end
    end, vim.api.nvim_get_current_buf() )
  end
  -- local defaultWorkspaceActionHandler = vim.lsp.handlers['workspace/executeCommand']
  --
  -- vim.print("registered:::", defaultWorkspaceActionHandler)
  -- vim.lsp.handlers['workspace/executeCommand'] = function(err, method, result, ...)
  --   vim.print(err, method, result, ...)
  --   defaultWorkspaceActionHandler(err, method, result, ...)
  --   vim.print 'Overridden'
  -- end
  --
  vim.keymap.set('n', '<leader>y', function()
    local lspParams = vim.lsp.util.make_position_params(0, 'utf-8')
    vim.print(lspParams)
    lspParams.newName = 'new_name'

    vim.lsp.buf_request(0, 'textDocument/rename', lspParams, function(err, method, result, ...)
      print(err, method, result)
      vim.lsp.handlers['textDocument/rename'](err, method, result, ...)
      vim.print 'Renaming done'
    end)
  end)
end

M.setup()

-- TextCaseOpenTelescope
local blah = 1234
