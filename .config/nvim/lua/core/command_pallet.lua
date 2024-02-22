local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"
local finders = require "telescope.finders"
local make_entry = require "telescope.make_entry"
local pickers = require "telescope.pickers"
local utils = require "telescope.utils"
local entry_display = require "telescope.pickers.entry_display"

local conf = require("telescope.config").values

local M = {}

local function get_key_record(data)
  local function get_desc(entry)
    if entry.callback and not entry.desc then
      return require("telescope.actions.utils")._get_anon_function_name(debug.getinfo(entry.callback))
    end
    return vim.F.if_nil(entry.desc, entry.rhs):gsub("\n", "\\n")
  end

  return {
    id = data.lhs,
    name = utils.display_termcodes(data.lhs),
    desc = get_desc(data),
    nargs = 0,
    mode = data.mode,
    type = "key"
  }
end

local function get_cmd_record(data)
  return {
    id = data.name,
    name = data.name,
    desc = data.definition,
    nargs = data.nargs,
    mode = " ",
    type = "cmd"
  }
end

local function get_keymaps(opts)
  opts.modes = vim.F.if_nil(opts.modes, { "n", "i", "c", "x" })
  opts.show_plug = vim.F.if_nil(opts.show_plug, true)
  opts.only_buf = vim.F.if_nil(opts.only_buf, false)

  local keymap_encountered = {} -- used to make sure no duplicates are inserted into keymaps_table
  local keymaps_table = {}
  local max_len_name = vim.F.if_nil(opts.width_name, 0)

  -- helper function to populate keymaps_table and determine max_len_lhs
  local function extract_keymaps(keymaps)
    for _, keymap in pairs(keymaps) do
      local keymap_key = keymap.buffer .. keymap.mode .. keymap.lhs -- should be distinct for every keymap
      if not keymap_encountered[keymap_key] then
        keymap_encountered[keymap_key] = true
        if
            (opts.show_plug or not string.find(keymap.lhs, "<Plug>"))
            and (not opts.lhs_filter or opts.lhs_filter(keymap.lhs))
            and (not opts.filter or opts.filter(keymap))
        then
          local value = get_key_record(keymap)
          table.insert(keymaps_table, value)
          max_len_name = math.max(max_len_name, #value.name)
        end
      end
    end
  end

  for _, mode in pairs(opts.modes) do
    if not opts.only_buf then
      local global = vim.api.nvim_get_keymap(mode)
      extract_keymaps(global)
    end

    local buf_local = vim.api.nvim_buf_get_keymap(0, mode)
    extract_keymaps(buf_local)
  end

  opts.width_name = max_len_name + 1

  return keymaps_table
end

local function get_commands(opts)
  local commands = {}
  local max_len_name = vim.F.if_nil(opts.width_name, 0)

  local function extract_command(cmd)
    if type(cmd) ~= "table" then return end
    local value = get_cmd_record(cmd)
    table.insert(commands, value)
    max_len_name = math.max(max_len_name, #value.name)
  end

  local command_iter = vim.api.nvim_get_commands {}
  for _, cmd in pairs(command_iter) do
    extract_command(cmd)
  end

  local show_buf_command = vim.F.if_nil(opts.show_buf_command, true)
  if show_buf_command then
    local buf_command_iter = vim.api.nvim_buf_get_commands(0, {})
    for _, cmd in pairs(buf_command_iter) do
      extract_command(cmd)
    end
  end

  opts.width_name = max_len_name

  return commands
end

local function gen_from_pallet(opts)
  local displayer = entry_display.create {
    separator = "▏",
    items = {
      { width = 3 },
      { width = opts.width_name },
      { remaining = true },
    },
  }

  local make_display = function(entry)
    return displayer {
      entry.mode,
      -- entry.name,
      { entry.name, "TelescopeResultsIdentifier" },
      entry.desc:gsub("\n", " "),
    }
  end

  return function(entry)
    return make_entry.set_default_entry_mt({
      name = entry.name,
      mode = entry.mode,
      desc = entry.desc,
      value = entry,
      ordinal = entry.mode .. " " .. entry.name .. " " .. entry.desc,
      display = make_display,
    }, opts)
  end
end

local function execute_selected(val)
  if val.type == "cmd" then
    local cmd = string.format([[:%s ]], val.name)
    if val.nargs == "0" then
      local cr = vim.api.nvim_replace_termcodes("<cr>", true, false, true)
      cmd = cmd .. cr
    end
    vim.cmd [[stopinsert]]
    vim.api.nvim_feedkeys(cmd, "t", false)
  elseif val.type == "key" then
    local key_combo = vim.api.nvim_replace_termcodes(val.lhs, true, false, true)
    vim.api.nvim_feedkeys(key_combo, "t", true)
  end
end

M.show = function(opts)
  local res = get_commands(opts)
  for _, v in ipairs(get_keymaps(opts)) do
    table.insert(res, v)
  end

  pickers
      .new(opts, {
        prompt_title = "Command Pallet",
        finder = finders.new_table {
          results = res,
          entry_maker = gen_from_pallet(opts),
        },
        sorter = conf.generic_sorter(opts),
        attach_mappings = function(prompt_bufnr)
          actions.select_default:replace(function()
            local selection = action_state.get_selected_entry()
            if selection == nil then
              vim.notify("Nothing selected!", vim.log.levels.WARN, { title = "Command Pallet" })
              return
            end

            actions.close(prompt_bufnr)
            execute_selected(selection.value)
          end)
          return true
        end,
      })
      :find()
end

return M
