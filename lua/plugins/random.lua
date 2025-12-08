local ShowKeys = {
  'nvzone/showkeys',
  cmd = 'ShowkeysToggle',
  opts = {
    timeout = 6,
    maxkeys = 4,
    position = 'top-center',
    -- more opts
  },
}

local SmoothScroll = {
  'karb94/neoscroll.nvim',
  opts = {
    cursor_scrolls_alone = false,
    duration_multiplier = 0.4,
    hide_cursor = false,
  },
}

local AutoTag = { 'windwp/nvim-ts-autotag', opts = {} }

local IndentLines = {
  'lukas-reineke/indent-blankline.nvim',
  main = 'ibl',
  ---@module "ibl"
  ---@type ibl.config
  opts = {
    scope = {
      enabled = false,
    },
  },
}
local WhichKeys = {
  'folke/which-key.nvim',
  event = 'VimEnter', -- Sets the loading event to 'VimEnter'
  opts = {
    -- delay between pressing a key and opening which-key (milliseconds)
    -- this setting is independent of vim.o.timeoutlen
    delay = 0,
    icons = {
      -- set icon mappings to true if you have a Nerd Font
      mappings = vim.g.have_nerd_font,
      -- If you are using a Nerd Font: set icons.keys to an empty table which will use the
      -- default which-key.nvim defined Nerd Font icons, otherwise define a string table
      keys = vim.g.have_nerd_font and {} or {
        Up = '<Up> ',
        Down = '<Down> ',
        Left = '<Left> ',
        Right = '<Right> ',
        C = '<C-…> ',
        M = '<M-…> ',
        D = '<D-…> ',
        S = '<S-…> ',
        CR = '<CR> ',
        Esc = '<Esc> ',
        ScrollWheelDown = '<ScrollWheelDown> ',
        ScrollWheelUp = '<ScrollWheelUp> ',
        NL = '<NL> ',
        BS = '<BS> ',
        Space = '<Space> ',
        Tab = '<Tab> ',
        F1 = '<F1>',
        F2 = '<F2>',
        F3 = '<F3>',
        F4 = '<F4>',
        F5 = '<F5>',
        F6 = '<F6>',
        F7 = '<F7>',
        F8 = '<F8>',
        F9 = '<F9>',
        F10 = '<F10>',
        F11 = '<F11>',
        F12 = '<F12>',
      },
    },

    -- Document existing key chains
    spec = {
      { '<leader>s', group = '[S]earch' },
      { '<leader>t', group = '[T]oggle' },
      { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
    },
  },
}

local TodoComments = {
  'folke/todo-comments.nvim',
  dependencies = { 'nvim-lua/plenary.nvim' },
  opts = {},
}

local Mini = {
  'nvim-mini/mini.nvim',
  version = '*',
  config = function()
    local spec_treesitter = require('mini.ai').gen_spec.treesitter
    require('mini.ai').setup {
      custom_textobjects = {
        f = spec_treesitter { a = '@function.outer', i = '@function.inner' },
        a = spec_treesitter { a = '@assignment.lhs', i = '@assignment.rhs' },
        P = spec_treesitter { a = '@parameter.inner', i = '@parameter.inner' },
        k = spec_treesitter { a = '@comment.outer', i = '@comment.inner' },
        c = spec_treesitter { a = '@call.outer', i = '@call.outer' },
      },
    }

    require('mini.pairs').setup {}
  end,
}

local Leap = {
  'ggandor/leap.nvim',
  config = function()
    require('leap').setup {}
    vim.keymap.set({ 'n', 'x', 'o' }, 's', '<Plug>(leap-forward)')
    vim.keymap.set({ 'n', 'x', 'o' }, 'S', '<Plug>(leap-backward)')
    vim.keymap.set('n', 'gs', '<Plug>(leap-from-window)')
  end,
}

local FolkePersistence = {
  'folke/persistence.nvim',
  event = 'BufReadPre', -- this will only start session saving when an actual file was opened
  config = function()
    local persistence = require 'persistence'
    persistence.setup {}

    -- local IsThatCenteredSession = vim.api.nvim_create_augroup('IsThatCenteredSession', { clear = true })
    -- vim.api.nvim_create_autocmd({ 'VeryLazy' }, {
    --   group = IsThatCenteredSession,
    --   callback = function()
    --     vim.print("verylazy::::")
    --   end,
    -- })
    --
    -- load the session for the current directory
    -- vim.keymap.set('n', '<leader>pS', function()
    --   require('persistence').load()
    -- end)
    --
    -- select a session to load
    -- vim.keymap.set('n', '<leader>pS', function()
    --   require('persistence').select()
    -- end)
    --
    -- load the last session
    -- stop Persistence => session won't be saved on exit
    -- vim.keymap.set('n', '<leader>qd', function()
    --   require('persistence').stop()
    -- end)
  end,
}

local copilot = { 'github/copilot.vim' }

local Oil = {
  'stevearc/oil.nvim',
  config = function()
    require('oil').setup {
      view_options = {
        show_hidden = true,
      },
      lsp_file_methods = {
        -- Enable or disable LSP file operations
        enabled = true,
        -- Time to wait for LSP file operations to complete before skipping
        timeout_ms = 1000,
        -- Set to true to autosave buffers that are updated with LSP willRenameFiles
        -- Set to "unmodified" to only save unmodified buffers
        autosave_changes = true,
      },
      preview_win = {
        preview_method = 'scratch',
      },
      keymaps = {
        ['<C-d>'] = { 'actions.preview_scroll_down' },
        ['<C-u>'] = { 'actions.preview_scroll_up' },
        ['<C-v>'] = { 'actions.select', opts = { vertical = true } },
        ['<esc><esc>'] = { 'actions.close', mode = 'n' },
      },
    }
    vim.keymap.set('n', '-', '<CMD>Oil<CR>', { desc = 'Open file explorer' })
  end,
  -- Optional dependencies
  dependencies = { { 'echasnovski/mini.icons', opts = {} } },
  -- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
  -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
  lazy = false,
}

local Harpoon = {

  'ThePrimeagen/harpoon',
  branch = 'harpoon2',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    local harpoon = require 'harpoon'
    local harpoon_extensions = require 'harpoon.extensions'

    harpoon:setup()

    harpoon:extend(harpoon_extensions.builtins.highlight_current_file())

    -- Default list
    vim.keymap.set('n', '<leader>haa', function()
      harpoon:list():add()
    end, { desc = 'Add to main list' })

    vim.keymap.set('n', '<leader><leader>', function()
      harpoon.ui:toggle_quick_menu(harpoon:list())
    end, { desc = 'Show main list' })

    vim.keymap.set('n', '<leader>hax', function()
      harpoon:list():clear()
    end, { desc = 'Clear main list' })

    -- Alt list
    local alt_list_name = 'alt'
    vim.keymap.set('n', '<leader>hba', function()
      harpoon:list(alt_list_name):add()
    end, { desc = 'Add to alternative list' })

    vim.keymap.set('n', '<leader>hbl', function()
      harpoon.ui:toggle_quick_menu(harpoon:list(alt_list_name))
    end, { desc = 'Show alternative list' })

    vim.keymap.set('n', '<leader>hbx', function()
      harpoon:list(alt_list_name):clear()
    end, { desc = 'Clear alternative list' })

    -- vim.keymap.set('n', '<C-h>', function()
    --   harpoon:list():select(1)
    -- end)
    -- vim.keymap.set('n', '<C-t>', function()
    --   harpoon:list():select(2)
    -- end)
    -- vim.keymap.set('n', '<C-n>', function()
    --   harpoon:list():select(3)
    -- end)
    -- vim.keymap.set('n', '<C-s>', function()
    --   harpoon:list():select(4)
    -- end)
    --
    vim.keymap.set('n', '<C-k>', function()
      harpoon:list():prev()
    end)

    vim.keymap.set('n', '<C-j>', function()
      harpoon:list():next()
    end)

    vim.keymap.set('n', '<C-h>', ':b#<cr>', { desc = 'Go to alternate buffer' })

    harpoon:extend {
      UI_CREATE = function(cx)
        vim.keymap.set('n', '<C-v>', function()
          harpoon.ui:select_menu_item { vsplit = true }
        end, { buffer = cx.bufnr })

        vim.keymap.set('n', '<C-x>', function()
          harpoon.ui:select_menu_item { split = true }
        end, { buffer = cx.bufnr })

        vim.keymap.set('n', '<C-t>', function()
          harpoon.ui:select_menu_item { tabedit = true }
        end, { buffer = cx.bufnr })
      end,
    }
  end,
}

local TextCase = {
  'johmsalas/text-case.nvim',
  dependencies = { 'nvim-telescope/telescope.nvim' },
  config = function()
    require('textcase').setup {}
    require('telescope').load_extension 'textcase'
    vim.api.nvim_set_keymap('n', '<leader>Cc', '<cmd>TextCaseOpenTelescope<CR>', { desc = 'Telescope' })
    -- vim.api.nvim_set_keymap('v', 'ga.', '<cmd>TextCaseOpenTelescope<CR>', { desc = 'Telescope' })
  end,
  keys = {
    'ga', -- Default invocation prefix
    { 'ga.', '<cmd>TextCaseOpenTelescope<CR>', mode = { 'n', 'x' }, desc = 'Telescope' },
  },
  cmd = {
    -- NOTE: The Subs command name can be customized via the option "substitude_command_name"
    'Subs',
    'TextCaseOpenTelescope',
    'TextCaseOpenTelescopeQuickChange',
    'TextCaseOpenTelescopeLSPChange',
    'TextCaseStartReplacingCommand',
  },
  -- If you want to use the interactive feature of the `Subs` command right away, text-case.nvim
  -- has to be loaded on startup. Otherwise, the interactive feature of the `Subs` will only be
  -- available after the first executing of it or after a keymap of text-case.nvim has been used.
  lazy = false,
}

local Noice = {
  'folke/noice.nvim',
  event = 'VeryLazy',
  opts = {
    -- add any options here
  },
  dependencies = {
    -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
    'MunifTanjim/nui.nvim',
    -- OPTIONAL:
    --   `nvim-notify` is only needed, if you want to use the notification view.
    --   If not available, we use `mini` as the fallback
    'rcarriga/nvim-notify',
  },
}

local NeoTree = {
  'nvim-neo-tree/neo-tree.nvim',
  branch = 'v3.x',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'MunifTanjim/nui.nvim',
    'nvim-tree/nvim-web-devicons', -- optional, but recommended
  },
  lazy = false, -- neo-tree will lazily load itself
}


return {
  -- copilot,
  -- Noice,
  NeoTree,
  { 'nvim-tree/nvim-web-devicons', opts = {} },
  TextCase,
  Harpoon,
  Oil,
  ShowKeys,
  SmoothScroll,
  AutoTag,
  IndentLines,
  { 'NMAC427/guess-indent.nvim', opts = {} }, -- Detect tabstop and shiftwidth automatically
  Leap,
  FolkePersistence,
  Mini,
  TodoComments,
  WhichKeys,
  -- {
  --   'catgoose/nvim-colorizer.lua',
  --   event = 'BufReadPre',
  --   opts = {},
  -- },
  { 'elihunter173/dirbuf.nvim' },
}
