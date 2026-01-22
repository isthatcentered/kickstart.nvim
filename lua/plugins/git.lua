local function get_main_branch()
  -- Try symbolic-ref first (most reliable)
  local ref = vim.fn.system 'git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null'
  if vim.v.shell_error == 0 then
    return ref:match('refs/remotes/origin/(.+)'):gsub('%s+', '')
  end
  -- Fallback: check if origin/main or origin/master exists
  vim.fn.system 'git rev-parse --verify origin/main 2>/dev/null'
  if vim.v.shell_error == 0 then
    return 'main'
  end
  vim.fn.system 'git rev-parse --verify origin/master 2>/dev/null'
  if vim.v.shell_error == 0 then
    return 'master'
  end
  return nil
end

local function get_current_branch()
  local branch = vim.fn.system 'git rev-parse --abbrev-ref HEAD 2>/dev/null'
  if vim.v.shell_error == 0 then
    return branch:gsub('%s+', '')
  end
  return nil
end

local DiffView = {
  'sindrets/diffview.nvim',
  config = function()
    local diffview = require 'diffview'

    diffview.setup {
      view = {
        default = {
          diff_args = { '--ignore-all-space', '-U99999' },
        },
        merge_tool = {
          diff_args = { '--ignore-all-space', '-U99999' },
        },
        file_history = {
          diff_args = { '--ignore-all-space', '-U99999' },
        },
      },
      hooks = {
        diff_buf_read = function()
          vim.opt_local.foldenable = false
          vim.opt_local.relativenumber = true
        end,
        view_opened = function(view)
          for _, win in ipairs(vim.api.nvim_tabpage_list_wins(view.tabpage)) do
            vim.wo[win].relativenumber = true
          end
          vim.keymap.set('n', '<Esc><Esc>', function()
            if vim.api.nvim_get_current_tabpage() == view.tabpage then
              vim.cmd 'DiffviewClose'
            end
          end, { desc = 'Close diffview' })

          -- Auto-close diffview when leaving its tab
          vim.api.nvim_create_autocmd('TabLeave', {
            once = true,
            callback = function()
              vim.print 'close'
              vim.cmd 'DiffviewClose'
            end,
          })
        end,
        view_closed = function() end,
      },
    }

    vim.keymap.set('n', '<leader>gc', function()
      local main = get_main_branch()
      local current = get_current_branch()
      if main == nil or current == main then
        vim.cmd 'DiffviewFileHistory'
      else
        vim.cmd('DiffviewFileHistory --range=origin/' .. main .. '..HEAD')
      end
    end, { desc = 'Branch commit history' })

    vim.keymap.set('n', '<leader>gf', function()
      vim.cmd 'DiffviewFileHistory %'
    end, { desc = 'File history' })

    vim.keymap.set('n', '<leader>ga', function()
      local main = get_main_branch()
      if main == nil then
        vim.notify('No remote main branch found', vim.log.levels.WARN)
        return
      end
      vim.cmd('!git fetch origin ' .. main)
      vim.cmd('DiffviewOpen origin/' .. main)
    end, { desc = 'Diff against main branch' })

    vim.keymap.set('n', '<leader>gg', function()
      vim.cmd 'DiffviewOpen'
    end, { desc = 'Diff unstaged changes' })

    vim.keymap.set('n', '<leader>gq', function()
      vim.cmd 'DiffviewClose'
    end, { desc = 'Close diffview' })
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
    { '<leader>gc', '<cmd>Neogit commit<cr>', desc = 'Commit' },
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
