local PERSONAL_PLUGINS_PATH = '/Users/edouardpenin/Test/nvim'
local PERSONAL_PLUGINS = {
  { name = 'acid', opts = {} },
  -- { name = 'snitch', opts = {} },
  {
    name = 'beacon2',
    config = function()
      local beacon = require 'beacon'

      beacon.setup {
      }
    end,
  },
}

for _, plugin in pairs(PERSONAL_PLUGINS) do
  vim.opt.rtp:prepend(PERSONAL_PLUGINS_PATH .. '/' .. plugin.name .. '.nvim')
  if plugin.opts then
    require(plugin.name).setup(plugin.opts)
  else
    plugin.config()
  end
end
