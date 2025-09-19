--[[ DIAGNOSTICS ]]
--
---------------------
-- DIagnostics navigation
-- local pos_equal = function (p1, p2)
--   local r1, c1 = unpack(p1)
--   local r2, c2 = unpack(p2)
--   return r1 == r2 and c1 == c2
-- end
--
-- local goto_next_error_then_hint = function ()
--   local pos = vim.api.nvim_win_get_cursor(0)
--   vim.diagnostic.jump( {count= 1, float=true,severity=vim.diagnostic.severity.ERROR, wrap = true} )
--   local pos2 = vim.api.nvim_win_get_cursor(0)
--   if ( pos_equal(pos, pos2)) then
--     vim.diagnostic.goto_next( {wrap = true} )
--   end
-- end
-- local goto_prev_error_then_hint = function ()
--   local pos = vim.api.nvim_win_get_cursor(0)
--   vim.diagnostic.goto_prev( {severity=vim.diagnostic.severity.ERROR, wrap = true} )
--   local pos2 = vim.api.nvim_win_get_cursor(0)
--   if ( pos_equal(pos, pos2)) then
--     vim.diagnostic.goto_prev( {wrap = true} )
--   end
-- end
vim.keymap.set('n', '<M-k>', function()
  vim.diagnostic.jump { count = -1, float = true, wrap = true }
end, { desc = 'Previous Diagnostic', noremap = true })

vim.keymap.set('n', '<M-j>', function()
  vim.diagnostic.jump { count = 1, float = true, wrap = true }
end, { desc = 'Next Diagnostic', noremap = true })

-- Quickfix navigation
vim.keymap.set('n', '<M-h>', ':cnext<cr>', { desc = 'Previous Quickfix' })
vim.keymap.set('n', '<M-l>', ':cnext<cr>', { desc = 'Next Quickfix' })

function shallowCopyTable(table)
  local copy = {}
  for key, value in pairs(table) do
    copy[key] = value
  end
 return copy 
end

--
-- local ns = vim.api.nvim_create_namespace 'isthatcentered_diagnostics'
-- local original_underline_handler = vim.diagnostic.handlers.underline
-- vim.diagnostic.handlers.underline = {
--   show = function(namespace, bufferId, diagnostics, opts)
--     ---@type vim.Diagnostic[]
--     local updatedDiagnostics = {}
--     for _, diagnostic in pairs(diagnostics) do
--       -- vim.print(diagnostic.source)
--       local isLinter = diagnostic.source == 'eslint' or diagnostic.source == 'biome'
--       if isLinter and diagnostic.severity < vim.diagnostic.severity.WARN then
--         --@type vim.Diagnostic
--         local updatedDiagnostic = shallowCopyTable(diagnostic)
--         updatedDiagnostic.severity = vim.diagnostic.severity.WARN
--
--         table.insert(updatedDiagnostics, updatedDiagnostic)
--       else
--         table.insert(updatedDiagnostics, diagnostic)
--       end
--     end
--     original_underline_handler.show(ns, bufferId, updatedDiagnostics, opts)
--   end,
--   hide = function(_namespace, ...)
--     original_underline_handler.hide(ns, ...)
--   end,
-- }

vim.diagnostic.config {
  virtual_lines = false,
  virtual_text = false,
  underline = true,
  severity_sort = true,
  jump = { float = true },
  float = { source = true, border = 'rounded', severity_sort = true, scope = 'cursor' },
  signs = {
    severity_sort = true,
    -- text = {
    --   -- [vim.diagnostic.severity.ERROR] = '',
    --   -- [vim.diagnostic.severity.WARN] = '',
    --   -- [vim.diagnostic.severity.INFO] = '',
    --   -- [vim.diagnostic.severity.HINT] = '',
    -- },
    linehl = {},
    numhl = {
      -- [vim.diagnostic.severity.ERROR] = 'DiagnosticLineNumberError',
      -- [vim.diagnostic.severity.WARN] = 'DiagnosticLineNumberWarn',
      -- [vim.diagnostic.severity.INFO] = 'DiagnosticLineNumberInfo',
      -- [vim.diagnostic.severity.HINT] = 'DiagnosticLineNumberHint',
    },
  },
}

vim.keymap.set('n', 'dt', function()
  local new_config = not vim.diagnostic.config().virtual_lines
  vim.diagnostic.config { virtual_lines = new_config }
end, { desc = 'Toggle diagnostic virtual_lines' })
