local function write_msg(msg)
	vim.notify(msg, vim.log.levels.INFO)
end

local function write_err(msg)
	vim.notify(msg, vim.log.levels.WARN)
end

local M = {}

-- Function to create a file if it doesn't exist
local function ensure_file_exists(path)
	if vim.fn.filereadable(path) == 1 then
		return true
	end
	local success = vim.fn.writefile({}, path)
	if success == 0 then
		write_msg("File created: " .. path)
		return true
	end
	write_err("Error: Unable to create file " .. path)
	return false
end

-- Function to get the file content
local function get_file_content(path)
	local file_content = vim.fn.readfile(path)
	local data = {}
	if file_content and #file_content > 0 then
		data = vim.fn.json_decode(table.concat(file_content, "\n"))
	end
	return data
end

-- Function to read the content of the file and check for the key
local function read_file_and_check_key(path, key)
	local data = get_file_content(path)
	if data and data[key] and #data[key] > 0 then
		return data[key]
	end
	return nil
end

-- Function to add the value to the file and return the value if success
local function add_value_to_file(path, key, value)
	local data = get_file_content(path)
	data[key] = vim.fn.fnameescape(vim.fn.expand(value))
	local json_data = vim.fn.json_encode(data)
	local success = vim.fn.writefile({ json_data }, path)
	if success == 0 then
		write_msg("\nValue added to " .. path)
		return value
	end
	write_err("\nError: Unable to update file " .. path)
	return nil
end

-- Function to create a file and handle key-value operations
function M.get_config_key(key, type)
	-- Construct the file path
	local path = vim.fn.expand("$HOME/.config/nvim.json")

	if not ensure_file_exists(path) then
		return nil
	end

	local value = read_file_and_check_key(path, key)
	if value then
		return value
	end

	value = vim.fn.input({
		prompt = "Enter value for " .. key .. ": ",
		completion = type
	})
	return add_value_to_file(path, key, value)
end

M.kmap = vim.keymap.set

-- Function to find the git root directory based on the current buffer's path
function M.find_git_root()
	-- Use the current buffer's path as the starting point for the git search
	local current_file = vim.api.nvim_buf_get_name(0)
	local current_dir
	local cwd = vim.fn.getcwd()
	-- If the buffer is not associated with a file, return nil
	if current_file == '' then
		current_dir = cwd
	else
		-- Extract the directory from the current file's path
		current_dir = vim.fn.fnamemodify(current_file, ':h')
	end

	-- Find the Git root directory from the current file's path
	local git_root = vim.fn.systemlist('git -C ' .. vim.fn.fnameescape(current_dir) .. ' rev-parse --show-toplevel')[1]
	if vim.v.shell_error ~= 0 then
		write_msg('Not a git repository. Searching in current working directory')
		return cwd
	end
	return git_root
end

return M
