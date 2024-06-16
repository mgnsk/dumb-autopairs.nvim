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

	local left_char = line:sub(col - 1, col - 1)
	local right_char = line:sub(col, col)

	return left_char, right_char
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
		-- TODO
		-- {
		-- 	left = '"',
		-- 	right = '"',
		-- },
		-- {
		-- 	left = "'",
		-- 	right = "'",
		-- },
		-- {
		-- 	left = "`",
		-- 	right = "`",
		-- },
	},
}

function M.setup(config)
	config = vim.tbl_extend("force", default_config, config or {})

	for _, pair in ipairs(config["pairs"]) do
		-- Insert closing brace and move cursor between them.
		vim.keymap.set("i", pair.left, function()
			local _, right_char = get_surrounding()

			-- Only insert closing brace when end of line or whitespace on right.
			-- Don't attempt to "wrap" anything in braces.
			if right_char == "" or right_char:match("%s") then
				feedkeys(pair.left .. pair.right .. "<Left>")
			else
				feedkeys(pair.left)
			end
		end)

		-- Handle manually inserting the closing brace, just move cursor to right.
		vim.keymap.set("i", pair.right, function()
			local _, right_char = get_surrounding()

			if right_char == pair.right then
				feedkeys("<Right>")
			else
				feedkeys(pair.right)
			end
		end)
	end

	vim.keymap.set("i", "<CR>", function()
		local left_char, right_char = get_surrounding()

		local found = false

		for _, pair in ipairs(config["pairs"]) do
			if left_char == pair.left and right_char == pair.right then
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

	vim.keymap.set("i", "<BS>", function()
		local left_char, right_char = get_surrounding()

		local found = false

		for _, pair in ipairs(config["pairs"]) do
			if left_char == pair.left and right_char == pair.right then
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
