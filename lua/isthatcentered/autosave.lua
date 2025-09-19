local function shouldSave(bufferId)
  local buffer = vim.bo[bufferId]

  return vim.api.nvim_buf_is_loaded(bufferId)
    and (vim.api.nvim_buf_get_name(bufferId) ~= '') -- Has a file path
    and (buffer.buftype == '') -- Is file type
    and buffer.modified
    and buffer.buflisted
    and not buffer.readonly
end

local function handleBufferChanged(buffer)
  if not shouldSave(buffer) then
    vim.print 'Do no save buffer'
    return
  end

  vim.api.nvim_buf_call(buffer, function()
    vim.cmd 'write'
  end)
end

local AutoSaveGroup = vim.api.nvim_create_augroup('isthatcentered/autosave', { clear = true })
vim.api.nvim_create_autocmd('TextChanged', {
  group = AutoSaveGroup,
  callback = function(args)
    vim.schedule(function()
      handleBufferChanged(args.buf)
    end)
  end,
})

vim.api.nvim_create_autocmd('InsertLeave', {
  group = AutoSaveGroup,
  callback = function(args)
    vim.schedule(function()
      handleBufferChanged(args.buf)
    end)
  end,
})
