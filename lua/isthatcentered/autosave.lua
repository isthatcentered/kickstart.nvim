local function shouldSave(bufferId)
  local buffer = vim.bo[bufferId]

  return vim.api.nvim_buf_is_loaded(bufferId)
    and (vim.api.nvim_buf_get_name(bufferId) ~= '') -- Has a file path
    and (buffer.buftype == '') -- Is file type
    and buffer.modified
    and buffer.buflisted
    and not buffer.readonly
end

local debounce_delay_ms = 1000
local debounce_generation = 0

local function shouldDelayAutosave()
  local mode = vim.api.nvim_get_mode().mode
  local mode_prefix = string.sub(mode, 1, 1)

  return mode_prefix == 'i' or mode_prefix == 'R'
end

local function saveBuffer(bufferId)
  if not shouldSave(bufferId) then
    return
  end

  vim.api.nvim_buf_call(bufferId, function()
    vim.cmd 'write'
  end)
end

local function flushModifiedBuffers()
  for _, bufferId in ipairs(vim.api.nvim_list_bufs()) do
    saveBuffer(bufferId)
  end
end

local function scheduleAutosave(bufferId)
  if not shouldSave(bufferId) then
    return
  end

  debounce_generation = debounce_generation + 1
  local generation = debounce_generation

  vim.defer_fn(function()
    if generation ~= debounce_generation then
      return
    end

    if shouldDelayAutosave() then
      return
    end

    flushModifiedBuffers()
  end, debounce_delay_ms)
end

local AutoSaveGroup = vim.api.nvim_create_augroup('isthatcentered/autosave', { clear = true })
vim.api.nvim_create_autocmd('TextChanged', {
  group = AutoSaveGroup,
  callback = function(args)
    scheduleAutosave(args.buf)
  end,
})

vim.api.nvim_create_autocmd('InsertLeave', {
  group = AutoSaveGroup,
  callback = function(args)
    scheduleAutosave(args.buf)
  end,
})
