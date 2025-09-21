local LazyDev = {
  'folke/lazydev.nvim',
  ft = 'lua', -- only load on lua files
  opts = {
    library = {
      -- See the configuration section for more details
      -- Load luvit types when the `vim.uv` word is found
      { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
    },
  },
}
local Refactoring = {
  'ThePrimeagen/refactoring.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
  },
  lazy = false,
  opts = {},
}

-- https://github.com/nvim-treesitter/nvim-treesitter/tree/main
local TreeSitter = {
  'nvim-treesitter/nvim-treesitter',
  lazy = false,
  branch = 'main',
  build = ':TSUpdate', -- Rebuild tree sitter on update
  config = function()
    local languages = { 'c', 'lua', 'vim', 'vimdoc', 'query', 'markdown', 'markdown_inline', 'json', 'tsx', 'typescript', 'typescriptreact' }

    require('nvim-treesitter').install(languages)

    vim.api.nvim_create_autocmd('FileType', {
      pattern = languages,
      callback = function()
        vim.treesitter.start()
        vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
      end,
    })
  end,
}

local LSP = {
  'neovim/nvim-lspconfig',
  -- commit = '782dda984da54e465dcc142544133606139d0306',
  dependencies = {
    -- Package manager for lsp/formatters/linters
    {
      'mason-org/mason.nvim',
      opts = {
        ensure_installed = {
          'ast-grep',
          'biome',
          'eslint-lsp',
          'eslint_d',
          'prettier',
          'prettierd',
          'typescript-language-server',
          'vtsls',
          'emmet-language-server',
        },
      },
    },
    -- Useful status updates for LSP.
    { 'j-hui/fidget.nvim', opts = {} },

    -- Completions
    -- https://github.com/Saghen/blink.cmp
    {
      'saghen/blink.cmp',

      build = 'cargo build --release',

      opts = {
        -- 'super-tab' for mappings similar to vscode (tab to accept)
        -- 'enter' for enter to accept
        -- 'none' for no mappings
        --
        -- All presets have the following mappings:
        -- C-space: Open menu or open docs if already open
        -- C-n/C-p or Up/Down: Select next/previous item
        -- C-e: Hide menu
        -- C-k: Toggle signature help (if signature.enabled = true)
        --
        -- See :h blink-cmp-config-keymap for defining your own keymap
        keymap = {
          preset = 'enter',
          ['<C-s>'] = {
            function(cmp)
              cmp.show()
            end,
          },
          ['<C-a>'] = {
            function(cmp)
              cmp.show_signature()
            end,
          },
        },

        documentation = { auto_show = false, auto_show_delay_ms = 500, border = 'rounded', window = { border = 'rounded' } },

        completion = {
          menu = { auto_show = true, border = 'rounded' },

          documentation = {
            window = { border = 'rounded' },
          },

          -- ghost_text = { enabled = true },
        },

        signature = {
          window = { border = 'rounded', show_documentation = true },
          enabled = true,
          trigger = {
            -- Show the signature help automatically
            enabled = false,
            -- Show the signature help window after typing any of alphanumerics, `-` or `_`
            show_on_keyword = true,
            blocked_trigger_characters = {},
            blocked_retrigger_characters = {},
            -- Show the signature help window after typing a trigger character
            show_on_trigger_character = true,
            -- Show the signature help window when entering insert mode
            show_on_insert = false,
            -- Show the signature help window when the cursor comes after a trigger character when entering insert mode
            show_on_insert_on_trigger_character = true,
          },
        },

        sources = {
          default = { 'lsp', 'path', 'snippets', 'buffer' },
        },

        fuzzy = { implementation = 'prefer_rust_with_warning' },
      },

      opts_extend = { 'sources.default' },
    },
  },
  config = function()
    local language_servers = {
      'lua_ls',
      'eslint',
      'biome',
      -- 'ts_ls',
      'vtsls',
      'jsonls',
    }

    vim.lsp.config('vtsls', {
      settings = {
        vtsls = {
          enableMoveToFileCodeAction = true,
        },
        typescript = {
          updateImportsOnFileMove = 'always',
          preferences = {
            importModuleSpecifier = 'relative',
          },
        },
      },
    })

    for _, ls in pairs(language_servers) do
      vim.lsp.enable(ls)
    end

    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
      callback = function(event)
        local map = function(keys, func, desc, mode)
          mode = mode or 'n'
          vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
        end

        map('grr', vim.lsp.buf.rename, '[R]efactor [R]ename')

        map('gra', vim.lsp.buf.code_action, '[R]efactor [A]ctions', { 'n', 'x' })

        map('glr', function()
          require('telescope.builtin').lsp_references { jump_type = 'never' }
        end, '[L]ens [R]eferences')

        map('gli', function()
          require('telescope.builtin').lsp_implementations { jump_type = 'never' }
        end, '[L]ens [I]mplementation')

        --  To jump back, press <C-t>.
        map('gld', function()
          require('telescope.builtin').lsp_definitions { jump_type = 'never' }
        end, '[G]oto [D]efinition')

        -- WARN: This is not Goto Definition, this is Goto Declaration.
        --  For example, in C this would take you to the header.
        map('glD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

        map('gls', require('telescope.builtin').lsp_document_symbols, '[L]ens [S]ymbols')

        map('glws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[L]ens [W]orkspace [S]ymbols')

        -- Jump to the type of the word under your cursor.
        --  Useful when you're not sure what type a variable is and you want to see
        --  the definition of its *type*, not where it was *defined*.
        map('glt', require('telescope.builtin').lsp_type_definitions, '[G]oto [T]ype Definition')

        -- vim.print(vim.fn.getcompletion('@lsp', 'highlight'))
        -- for _, group in ipairs(vim.fn.getcompletion('@lsp', 'highlight')) do
        --   vim.api.nvim_set_hl(0, group, {})
        -- end

        -- Highlight word under cursor
        --
        -- local original_handler = vim.lsp.handlers['textDocument/rename']
        -- vim.lsp.handlers['textDocument/rename'] = function(err, method, result, ...)
        --   vim.print 'Calling rename'
        --   original_handler(err, method, result, ...)
        --   vim.print 'Reame done:::'
        -- end
        --

        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
          local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
          vim.api.nvim_create_autocmd({ 'CursorHold' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.document_highlight,
          })

          vim.api.nvim_create_autocmd({ 'CursorMoved' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.clear_references,
          })

          vim.api.nvim_create_autocmd('LspDetach', {
            group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
            callback = function(event2)
              vim.lsp.buf.clear_references()
              vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
            end,
          })
        end

        map('<leader>th', function()
          vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
        end, '[T]oggle Inlay [H]ints')
      end,
    })
  end,
}

return {
  LazyDev,
  TreeSitter,
  Refactoring,
  LSP,
}
