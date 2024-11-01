--- Feeds keys as if typed. No remapping.
--- @param keys string
local function feedkeys(keys)
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "n", false)
end

--- @param s string
--- @return string
local function trim(s)
	return s:match("^%s*(.*)"):match("(.-)%s*$")
end

--- Return surrounding texts for cursor.
--- @return string left, string right
local function get_surrounding()
	local col = vim.fn.col(".")
	local line = vim.fn.getline(".")

	local left = line:sub(0, col - 1)
	local right = line:sub(col, -1)

	return left, right
end

--- @param s string
--- @param prefix_list string[]
--- @return boolean
local function hasprefix(s, prefix_list)
	s = trim(s)

	for _, prefix in ipairs(prefix_list) do
		if prefix == "" or s:sub(1, #prefix) == prefix then
			return true
		end
	end

	return false
end

--- @param s string
--- @param suffix_list string[]
--- @return boolean
local function hassuffix(s, suffix_list)
	s = trim(s)

	for _, suffix in ipairs(suffix_list) do
		if suffix == "" or s:sub(-#suffix) == suffix then
			return true
		end
	end

	return false
end

--- @param s string
--- @return boolean
local function has_open_brace_suffix(s)
	return hassuffix(s, { "(", "[", "{" })
end

--- @param s string
--- @return boolean
local function has_open_brace_prefix(s)
	return hasprefix(s, { "(", "[", "{" })
end

--- @param s string
--- @return boolean
local function has_close_brace_prefix(s)
	return hasprefix(s, { ")", "]", "}" })
end

--- @param s string
--- @return boolean
local function has_operator_suffix(s)
	return hassuffix(s, { "=", ":" })
end

--- @param s string
--- @return boolean
local function has_comma_suffix(s)
	return hassuffix(s, { "," })
end

--- @param pair Pair
local function on_open_quote(pair)
	local left, right = get_surrounding()

	if right:sub(1, 1) == pair.right then
		-- Handle manually closing the quote.
		feedkeys("<Right>")
	elseif left == "" and right == "" then
		feedkeys(pair.left .. pair.right .. "<Left>")
	elseif (has_operator_suffix(left) or has_comma_suffix(left)) and right == "" then
		feedkeys(pair.left .. pair.right .. "<Left>")
	elseif has_open_brace_suffix(left) or (has_comma_suffix(left) and has_close_brace_prefix(right)) then
		feedkeys(pair.left .. pair.right .. "<Left>")
	else
		feedkeys(pair.left)
	end
end

--- @param pair Pair
local function on_open_brace(pair)
	local left, right = get_surrounding()

	if right == "" then
		feedkeys(pair.left .. pair.right .. "<Left>")
	elseif has_open_brace_suffix(left) or has_close_brace_prefix(right) or has_open_brace_prefix(right) then
		feedkeys(pair.left .. pair.right .. "<Left>")
	else
		feedkeys(pair.left)
	end
end

--- @param pair Pair
local function on_close_brace(pair)
	local _, right = get_surrounding()

	if right:sub(1, 1) == pair.right then
		feedkeys("<Right>")
	else
		feedkeys(pair.right)
	end
end

--- @param config Config
local function on_enter(config)
	local left, right = get_surrounding()

	local found = false

	for _, pair in ipairs(config["pairs"]) do
		if hassuffix(left, { pair.left }) and hasprefix(right, { pair.right }) then
			found = true
			break
		end
	end

	if found then
		-- Note: assumes these settings:
		-- vim.o.autoindent = true
		-- vim.cmd("filetype plugin indent on")
		feedkeys("<CR><Up><End><CR>")
	else
		feedkeys("<CR>")
	end
end

--- @param config Config
local function on_backspace(config)
	local left, right = get_surrounding()

	local found = false
	local del_count = 1

	for _, pair in ipairs(config["pairs"]) do
		if left:sub(-1) == pair.left and hasprefix(right, { pair.right }) then
			-- Find how many <Del> we need to reach pair.right.
			local idx, _ = right:find(pair.right)
			if idx ~= nil then
				del_count = idx
			end

			found = true
			break
		end
	end

	if found then
		feedkeys(string.rep("<Del>", del_count) .. "<BS>")
	else
		feedkeys("<BS>")
	end
end

local M = {}

--- @class (exact) Pair
--- @field left string
--- @field right string

--- @class (exact) Config
--- @field pairs Pair[]

--- @type Config
local default_config = {
	pairs = {
		{
			left = "(",
			right = ")",
		},
		{
			left = "[",
			right = "]",
		},
		{
			left = "{",
			right = "}",
		},
		{
			left = '"',
			right = '"',
		},
		{
			left = "'",
			right = "'",
		},
		{
			left = "`",
			right = "`",
		},
	},
}

--- @param config Config
function M.setup(config)
	config = vim.tbl_extend("force", default_config, config or {})

	for _, pair in ipairs(config["pairs"]) do
		if pair.left:len() > 1 or pair.right:len() > 1 then
			error("only single-character quotes/braces are supported")
		end

		if pair.left == pair.right then
			vim.keymap.set("i", pair.left, function()
				on_open_quote(pair)
			end, { desc = "Complete quotes" })
		else
			vim.keymap.set("i", pair.left, function()
				on_open_brace(pair)
			end, { desc = "Complete braces" })
			vim.keymap.set("i", pair.right, function()
				on_close_brace(pair)
			end, { desc = "Handle manual brace close" })
		end
	end

	vim.keymap.set("i", "<CR>", function()
		on_enter(config)
	end, { desc = "Indent when pressing enter between braces" })

	vim.keymap.set("i", "<BS>", function()
		on_backspace(config)
	end, { desc = "Delete both braces when pressing backspace between braces" })
end

return M
