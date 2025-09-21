-- Basic settings
vim.o.termguicolors = true
vim.opt.number = true -- Line numbers
vim.opt.relativenumber = true -- Relative line numbers
vim.opt.cursorline = true -- Highlight current line
vim.opt.wrap = false -- Don't wrap lines
vim.opt.scrolloff = 10 -- Keep 10 lines above/below cursor
vim.opt.sidescrolloff = 8 -- Keep 8 columns left/right of cursor

-- Indentation
vim.opt.tabstop = 2 -- Tab width
vim.opt.shiftwidth = 2 -- Indent width
vim.opt.softtabstop = 2 -- Soft tab stop
vim.opt.expandtab = true -- Use spaces instead of tabs
vim.opt.smartindent = true -- Smart auto-indenting
vim.opt.autoindent = true -- Copy indent from current line
vim.o.breakindent = true

-- Search settings
vim.opt.ignorecase = true -- Case insensitive search
vim.opt.smartcase = true -- Case sensitive if uppercase in search
vim.opt.hlsearch = true -- Do highlight search results
vim.opt.incsearch = true -- Show matches as you type

-- Visual settings
vim.opt.termguicolors = true -- Enable 24-bit colors
vim.opt.signcolumn = 'yes' -- Always show sign column
vim.opt.showmatch = true -- Highlight matching brackets
vim.o.inccommand = 'split' -- Preview substitutions live, as you type!
vim.o.cursorline = true
vim.o.winborder = 'rounded'

-- File handling
vim.opt.backup = false -- Don't create backup files
vim.opt.writebackup = false -- Don't create backup before writing
vim.opt.swapfile = false -- Don't create swap files
vim.opt.undofile = true -- Persistent undo
vim.opt.updatetime = 100 -- Faster completion
vim.opt.timeoutlen = 300 -- Key timeout duration
vim.opt.autoread = true -- Auto reload files changed outside vim
vim.opt.autowrite = true -- Auto save

-- Behavior settings
vim.opt.errorbells = false -- No error bells
vim.opt.mouse = 'a' -- Enable mouse support
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.confirm = true -- show confirm dialog when a file hasn't been saved
vim.opt.path:append '**' -- include sub directories in search

-- folding settings
vim.opt.foldmethod = 'expr' -- use expression for folding
-- vim.wo.vim.foldexpr = "v:lua.vim.treesitter.foldexpr()" -- use treesitter for folding
vim.opt.foldlevel = 99 -- start with all folds open

-- split behavior
vim.opt.splitbelow = true -- horizontal splits go below
vim.opt.splitright = true -- vertical splits go right

-- key mappings
vim.g.mapleader = ' ' -- set leader key to space
vim.g.maplocalleader = ' ' -- set local leader key (new)

vim.g.neovide_input_macos_alt_is_meta = true

-- normal mode mappings
vim.keymap.set('n', '<esc>', '<cmd>nohlsearch<cr>') -- clear search highlights when pressing <esc> in normal mode

-- center screen when jumping
vim.keymap.set('n', 'n', 'nzzzv', { desc = 'next search result (centered)' })
vim.keymap.set('n', 'n', 'nzzzv', { desc = 'previous search result (centered)' })

-- NAVIGATION  -----------------------------------------
-- Window navigation
vim.keymap.set('n', '<C-l>', '<c-w><c-w>', { desc = 'move focus to next window' })
-- vim.keymap.set('n', '<c-h>', '<c-w><c-w>', { desc = 'move focus to next window' })

-- Buffer navigation
vim.keymap.set('n', '<c-d>', '<c-d>zz', { desc = 'half page down (centered)' })
vim.keymap.set('n', '<c-u>', '<c-u>zz', { desc = 'half page up (centered)' })
-- vim.keymap.set('n', '<C-j>', ':bnext<cr>', { desc = 'next buffer' })
-- vim.keymap.set('n', '<C-k>', ':bprevious<cr>', { desc = 'previous buffer' })

-- move lines up/down
-- vim.keymap.set('n', '<a-j>', ':m .+1<cr>==', { desc = 'move line down' })
-- vim.keymap.set('n', '<a-k>', ':m .-2<cr>==', { desc = 'move line up' })
-- vim.keymap.set('v', '<a-j>', ":m '>+1<cr>gv=gv", { desc = 'move selection down' })
-- vim.keymap.set('v', '<a-k>', ":m '<-2<cr>gv=gv", { desc = 'move selection up' })

-- -- better indenting in visual mode
-- vim.keymap.set('v', '<', '<gv', { desc = 'indent left and reselect' })
-- vim.keymap.set('v', '>', '>gv', { desc = 'indent right and reselect' })

-- quick file navigation
-- vim.keymap.set("n", "<leader>fe", ":explore<cr>", { desc = "open file explorer" })
-- vim.keymap.set("n", "<leader>ff", ":find ", { desc = "find file" })

-- lines
-- vim.keymap.set('n', '<leader>lj', 'mzj`z', { desc = 'join lines and keep cursor position' })

-- terminal
vim.keymap.set('t', '<esc>', '<c-\\><c-n>', { desc = 'exit terminal mode' })

-- ============================================================================
-- useful functions
-- ============================================================================
vim.api.nvim_create_autocmd('textyankpost', {
  desc = 'highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank { timeout = 500 }
  end,
})

-- use system clipboard
vim.schedule(function()
  vim.o.clipboard = 'unnamedplus'
end)

local augroup = vim.api.nvim_create_augroup('userconfig', {})

-- disable line numbers in terminal
vim.api.nvim_create_autocmd('termopen', {
  group = augroup,
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = 'no'
  end,
})

-- auto-resize splits when window is resized
vim.api.nvim_create_autocmd('vimresized', {
  group = augroup,
  callback = function()
    vim.cmd 'tabdo wincmd ='
  end,
})

require 'config.lazy'

-- create a new terminal in a new split down.
-- if there is already a terminal somewhere, reuse the same split and use same buffer.
-- if inside terminal you can create a new terminal or close an existing one. the same split will be used
local terminal_state = {
  bufferId = nil,
  windowId = nil,
}
local openShellWindow = function(bufferId)
  local windowConfig = { vertical = true, height = 15, split = 'below' }
  local padding = 4
  local windowId = vim.api.nvim_open_win(terminal_state.bufferId, true, {
    relative = 'editor',
    width = (vim.o.columns - (padding * 2)),
    height = 20,
    col = padding,
    row = (vim.o.lines - padding),
    border = 'rounded',
    style = 'minimal',
    footer = { { 'Hello' } },
  })

  -- vim.keymap.set({"t", "n"}, '<Esc><Esc>', vim.cmd.ToggleOverShell, {})

  return windowId
end

local toggleOverShell = function()
  if terminal_state.windowId then
    vim.api.nvim_win_close(terminal_state.windowId, false)
    terminal_state.windowId = nil
    return
  end

  if terminal_state.bufferId and vim.api.nvim_buf_is_valid(terminal_state.bufferId) then
    local windowId = openShellWindow(terminal_state.bufferId)
    terminal_state.windowId = windowId
    vim.cmd.startinsert()
    return
  end

  local bufferId = vim.api.nvim_create_buf(false, true)
  terminal_state.bufferId = bufferId
  local windowId = openShellWindow(terminal_state.bufferId)
  terminal_state.windowId = windowId
  vim.cmd.terminal()
  vim.cmd.startinsert()
end

-- TODO: esc + esc toggles terminal (attach to buffer)
vim.api.nvim_create_user_command('ToggleOverShell', toggleOverShell, {})

vim.keymap.set('n', '<leader>tt', ':ToggleOverShell<CR>', { desc = 'Toggle OverShell' })

vim.keymap.set('n', '<leader>ws', ':w<CR>:source %<CR>', { desc = 'Save & source' })

-- Session management
vim.keymap.set('n', '<leader>_', function()
  require('persistence').load {}
end, { desc = 'Load last session' })

-- load color scheme

-- ignore lazy and go back to native imprt it should work with g_color
-- autosave plugn
-- moves to go to arg/fn start /...v
require 'isthatcentered/load_custom_plugins'
require 'isthatcentered.diagnostics'
require 'isthatcentered.autosave'
require 'isthatcentered.autorun'
vim.opt.background = 'light'
vim.g.colors_name = 'acid'
require('acid').setup()

local lastClosedBuffer = nil
vim.api.nvim_create_user_command('BufferClose', function()
  lastClosedBuffer = vim.api.nvim_get_current_buf()
  vim.cmd 'bp'
  vim.cmd 'bd#'
end, {})
vim.api.nvim_create_user_command('BufferOpenLastClosed', function()
  if not lastClosedBuffer or not vim.api.nvim_buf_is_valid(lastClosedBuffer) then
    return
  end

  local currentWin = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(currentWin, lastClosedBuffer)
end, {})

vim.keymap.set('n', '<M-w>', ':BufferClose<cr>', { desc = 'Close current buffer while keeping window open' })
vim.keymap.set('n', '<M-W>', ':BufferOpenLastClosed<cr>', { desc = 'Open last closed buffer' })

vim.api.nvim_create_user_command('IsThatCenteredFormatAction', function()
  local bufferId = vim.api.nvim_get_current_buf()
  local buffer = vim.bo
  local filetype = vim.bo.filetype

  require('conform').format { async = false }

  if string.find(filetype, '^typescript') then
    local client = vim.lsp.get_clients({ name = 'vtsls', bufnr = 0 })[1]

    -- vim.lsp.buf.code_action { apply = true, context = { only = { 'source.addMissingImports' }, diagnostics = {} } }
    vim.cmd 'LspEslintFixAll'

    -- client:exec_cmd({
    --   title = 'Sort imports',
    --   command = 'typescript.sortImports',
    --   arguments = {
    --     vim.api.nvim_buf_get_name(bufferId),
    --   },
    -- }, { bufnr = vim.api.nvim_get_current_buf() })

    -- client:exec_cmd({
    --   title = 'Remove unused imports',
    --   command = 'typescript.removeUnusedImports',
    --   arguments = {
    --     vim.api.nvim_buf_get_name(bufferId),
    --   },
    -- }, { bufnr = vim.api.nvim_get_current_buf() })
  end
end, {})

vim.api.nvim_create_user_command('IsThatCenteredImportAction', function()
  local bufferId = vim.api.nvim_get_current_buf()
  local buffer = vim.bo
  local filetype = vim.bo.filetype

  if string.find(filetype, '^typescript') then
    local client = vim.lsp.get_clients({ name = 'vtsls', bufnr = 0 })[1]

    -- vim.lsp.buf.code_action { apply = true, context = { only = { 'source.addMissingImports' }, diagnostics = {} } }
    -- vim.cmd 'LspEslintFixAll'

    -- client:exec_cmd({
    --   title = 'Sort imports',
    --   command = 'typescript.sortImports',
    --   arguments = {
    --     vim.api.nvim_buf_get_name(bufferId),
    --   },
    -- }, { bufnr = vim.api.nvim_get_current_buf() })

    client:exec_cmd({
      title = 'Remove unused imports',
      command = 'typescript.removeUnusedImports',
      arguments = {
        vim.api.nvim_buf_get_name(bufferId),
      },
    }, { bufnr = vim.api.nvim_get_current_buf() })
  end
end, {})

vim.keymap.set('n', '<leader>f', ':IsThatCenteredFormatAction<cr>', { desc = 'Code fixup actions' })
vim.keymap.set('n', 'gri', ':IsThatCenteredImportAction<CR>', { desc = 'Remove unused imports' })
vim.keymap.set('n', '<leader>ll', ':LspRestart<cr>', { desc = 'Restart lsp server' })

-- @TODO: Auto save + custom format per language
-- TODO:  bnext only switches to buffers opened in this window
-- @TODO: have window layout presets ?
-- TODO: new file helper
--
-- local ScrollNamespace = vim.api.nvim_create_namespace 'IsThatCenteredScroll'
-- vim.api.nvim_set_hl(0, 'IsThatCenteredScrollStartMark', {})
--
-- ---@param config {timeout: number}
-- local function highlight_current_line(config)
--   local row = vim.api.nvim_win_get_cursor(0)[1] - 1 -- 0-indexed
--
--   vim.hl.range(
--     0,
--     ScrollNamespace,
--     'Visual',
--     { row, 0 },
--     { row, -1 }, -- -1 = highlight to end of line
--     { timeout = config.timeout }
--   )
--
--   local neoscroll = require("neoscroll")
--   neoscroll.ctrl_u({})
--   vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-u>', true, false, true), 'm', true)
--   -- vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('zz', true, false, true), 'm', true)
-- end
--
-- vim.api.nvim_create_user_command('IsScroll', function()
--   highlight_current_line { timeout = 3000 }
-- end, {})
--
-- vim.keymap.set('n', '<leader>a', ':IsScroll<CR>', { desc = 'Code fixup actions' })

local initialRenameHandler = vim.lsp.handlers['textDocument/rename']
local blah2 = 123
vim.lsp.handlers['textDocument/rename'] = function(...)
  initialRenameHandler(...)
  vim.cmd("")
  vim.notify 'Renamed:::'
end

-- Auto restore last session on startup
vim.api.nvim_create_autocmd('VimEnter', {
  group = vim.api.nvim_create_augroup('Persistence', { clear = true }),
  callback = function()
    -- NOTE: Before restoring the session, check:
    -- 1. No arg passed when opening nvim, means no `nvim --some-arg ./some-path`
    -- 2. No pipe, e.g. `echo "Hello world" | nvim`
    if vim.fn.argc() == 0 and not vim.g.started_with_stdin then
      require('persistence').load()
    end
  end,
  -- HACK: need to enable `nested` otherwise the current buffer will not have a filetype(no syntax)
  nested = true,
})
local custom_lsp_handler = require("isthatcentered.vtsls.hello")
custom_lsp_handler.setup()
