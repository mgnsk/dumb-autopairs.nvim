--- Feeds keys as if typed. No remapping.
--- @param keys string
local function feedkeys(keys)
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "n", false)
end

--- Return surrounding characters for cursor.
--- @return string, string
local function get_surrounding()
	local col = vim.fn.col(".")
	local line = vim.fn.getline(".")

	local left = line:sub(col - 1, col - 1)
	local right = line:sub(col, col)

	return left, right
end

--- @return boolean
local function is_open_brace(s)
	return s == "(" or s == "[" or s == "{"
end

--- @return boolean
local function is_space(s)
	return s:match("%s")
end

local M = {}

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

function M.setup(config)
	config = vim.tbl_extend("force", default_config, config or {})

	for _, pair in ipairs(config["pairs"]) do
		if pair.left == pair.right then
			-- Handle completing quotes.
			vim.keymap.set("i", pair.left, function()
				local left, right = get_surrounding()

				if right == pair.right then
					-- Handle manually inserting the closing quote, just move cursor to right.
					feedkeys("<Right>")
				elseif left == "" or is_space(left) or is_open_brace(left) then
					-- Complete quotes.
					feedkeys(pair.left .. pair.right .. "<Left>")
				else
					feedkeys(pair.left)
				end
			end)
		else
			-- Handle completing braces. It does not attempt to "wrap" anything in braces.
			vim.keymap.set("i", pair.left, function()
				local left, right = get_surrounding()

				if right == "" or is_space(right) then
					-- Complete braces when end of line or whitespace on right.
					feedkeys(pair.left .. pair.right .. "<Left>")
				elseif is_open_brace(left) then
					-- Complete braces when inside braces.
					feedkeys(pair.left .. pair.right .. "<Left>")
				else
					feedkeys(pair.left)
				end
			end)

			-- Handle manually inserting the closing brace, just move cursor to right.
			vim.keymap.set("i", pair.right, function()
				local _, right = get_surrounding()

				if right == pair.right then
					feedkeys("<Right>")
				else
					feedkeys(pair.right)
				end
			end)
		end
	end

	-- Handle enter key between braces.
	vim.keymap.set("i", "<CR>", function()
		local left, right = get_surrounding()

		local found = false

		for _, pair in ipairs(config["pairs"]) do
			if left == pair.left and right == pair.right then
				found = true
				break
			end
		end

		if found then
			feedkeys("<CR><Up><End><CR>")
		else
			feedkeys("<CR>")
		end
	end, { desc = "Indent when pressing enter between braces" })

	-- Handle backspace key between braces.
	vim.keymap.set("i", "<BS>", function()
		local left, right = get_surrounding()

		local found = false

		for _, pair in ipairs(config["pairs"]) do
			if left == pair.left and right == pair.right then
				found = true
				break
			end
		end

		if found then
			feedkeys("<Right><BS><BS>")
		else
			feedkeys("<BS>")
		end
	end, { desc = "Delete both braces when pressing backspace between braces" })
end

return M
