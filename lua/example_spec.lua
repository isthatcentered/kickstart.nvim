local nope = require("nope")

---@class SpyEventHandler: NopeEventHandler
---@field log {event: string, args: any}[]

---@return SpyEventHandler
local function makeSpyEventHandler()
  local object = { log = {} }
  return setmetatable(object, {
    __index = function(_, key)
      return function(...)
        table.insert(object.log, { event = key, args = { ... } })
      end
    end,
  })
end

describe("Test example", function()
  test("No matching runner fails", function()
    local eventHandler = makeSpyEventHandler()
    nope.setup({
      eventHandler = eventHandler,
    })

    vim.api.nvim_cmd({ cmd = "Nope", args = { "runnername" } }, {})

    assert.same({ { event = "onUnknownRunner", args = { "runnername" } } }, eventHandler.log)
  end)

  -- describe("Matching runner", function()
  --   test("Starts runner", function()
  --     local eventHandler = makeSpyEventHandler()
  --     nope.setup({
  --       eventHandler = eventHandler,
  --     })
  --
  --     vim.api.nvim_cmd({ cmd = "Nope", args = { "runnername" } }, {})
  --
  --     assert.same({ { event = "runStarted", args = { { folder = nil, configPath = nil } } } }, eventHandler.log)
  --   end)
  --   -- failed to start runner
  --   -- stop runner
  --   -- get runner update
  --   -- multiple of the same runner at the same time (folder specific, file specific, )
  --   -- custom test config
  -- end)
  -- TODO: no runner name passed
end)
describe("Runner", function()
  test("Start fail", function() end)

  test("Start success", function() end)
  -- done success
  -- done failure
  -- failed to start/exited immediately
end)
