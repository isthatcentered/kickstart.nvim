local autosave_group = 'isthatcentered/autosave'
local autosave_module = 'isthatcentered.autosave'
local debounce_delay_ms = 1000
local debounce_wait_ms = debounce_delay_ms + 150

local function create_test_buffer()
  local path = vim.fn.tempname() .. '.txt'

  vim.fn.writefile({ 'before' }, path)
  vim.cmd('edit ' .. vim.fn.fnameescape(path))
  vim.api.nvim_buf_set_lines(0, 0, -1, false, { 'after' })

  return vim.api.nvim_get_current_buf(), path
end

local function read_file(path)
  return vim.fn.readfile(path)
end

local function reload_autosave()
  package.loaded[autosave_module] = nil
  require(autosave_module)
end

local function trigger_insert_leave(bufferId)
  vim.api.nvim_exec_autocmds('InsertLeave', {
    group = autosave_group,
    buffer = bufferId,
    modeline = false,
  })
end

describe('isthatcentered.autosave', function()
  after_each(function()
    vim.wait(debounce_wait_ms)

    for _, bufferId in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_valid(bufferId) and vim.bo[bufferId].buflisted then
        local name = vim.api.nvim_buf_get_name(bufferId)

        if name ~= '' and name:find(vim.loop.os_tmpdir(), 1, true) == 1 then
          vim.api.nvim_buf_delete(bufferId, { force = true })
          os.remove(name)
        end
      end
    end
  end)

  it('saves after insert leave debounce', function()
    reload_autosave()
    local bufferId, path = create_test_buffer()

    trigger_insert_leave(bufferId)
    vim.wait(debounce_wait_ms)

    assert.same({ 'after' }, read_file(path))
    assert.is_false(vim.bo[bufferId].modified)
  end)

  it('does not save while mode stays insert-like when debounce expires', function()
    reload_autosave()
    local _, path = create_test_buffer()
    local original_get_mode = vim.api.nvim_get_mode

    vim.api.nvim_get_mode = function()
      return { mode = 'i' }
    end

    trigger_insert_leave(0)
    vim.wait(debounce_wait_ms)
    vim.api.nvim_get_mode = original_get_mode

    assert.same({ 'before' }, read_file(path))
    assert.is_true(vim.bo.modified)
  end)

  it('saves on the next insert leave after an insert-like debounce skip', function()
    reload_autosave()
    local bufferId, path = create_test_buffer()
    local original_get_mode = vim.api.nvim_get_mode

    vim.api.nvim_get_mode = function()
      return { mode = 'i' }
    end

    trigger_insert_leave(bufferId)
    vim.wait(debounce_wait_ms)
    vim.api.nvim_get_mode = original_get_mode

    assert.same({ 'before' }, read_file(path))
    assert.is_true(vim.bo[bufferId].modified)

    trigger_insert_leave(bufferId)
    vim.wait(debounce_wait_ms)

    assert.same({ 'after' }, read_file(path))
    assert.is_false(vim.bo[bufferId].modified)
  end)
end)
