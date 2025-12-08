local DiffView = {
  'sindrets/diffview.nvim',
  config = function()
    local diffview = require 'diffview'

    diffview.setup()

    local opened = false
    vim.keymap.set('n', '<leader>gg', function()
      if not opened then
        diffview.open()
        opened = true
      else
        diffview.close()
        opened = false
      end
    end, { desc = 'Toggle DiffView' })
  end,
}

local GitSigns = {
  'lewis6991/gitsigns.nvim',
  config = function()
    require('gitsigns').setup()
  end,
}

local colors = {
  black = '#000000',
  white = '#ffffff',
  red = '#ffcccc',
  green = '#c6ead8',
}

local NeoGit = {
  'NeogitOrg/neogit',
  lazy = true,
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope.nvim',
  },
  cmd = 'Neogit',
  keys = {
    { '<leader>gG', '<cmd>Neogit<cr>', desc = 'Show Neogit UI' },
  },
  opts = {
    integrations = {
      diffview = true,
    },
    highlight = {

      italic = true, --
      bold = true, --
      underline = true, --
      -- bg0       = colors.red, -- Darkest background color
      -- bg1       = colors.red, -- Second darkest background color
      bg2 = colors.white, -- Second lightest background color
      -- bg3       = colors.red, -- Lightest background color
      -- grey      = colors.red, -- middle grey shade for foreground
      -- white     = colors.red, -- Foreground white (main text)

      -- red = '#000000', -- Foreground red
      -- bg_red = '#f4e7e7', -- Background red
      line_red = colors.red, -- Cursor line highlight for red regions
      --
      -- orange    = "", -- Foreground orange
      -- bg_orange = "", -- background orange
      -- yellow    = "", -- Foreground yellow
      -- bg_yellow = "", -- background yellow
      green = colors.black, -- Foreground green
      -- bg_green  = colors.green, -- Background green
      line_green = colors.green, -- Cursor line highlight for green regions
      -- cyan      = "", -- Foreground cyan
      -- bg_cyan   = "", -- Background cyan
      -- blue      = "", -- Foreground blue
      -- bg_blue   = colors.red, -- Background blue

      -- purple    = colors.red, -- Foreground purple
      -- bg_purple = colors.red, -- Background purple
      -- md_purple = colors.red, -- Background medium purple
    },
  },
}
return {
  DiffView,
  NeoGit,
  GitSigns,
}
