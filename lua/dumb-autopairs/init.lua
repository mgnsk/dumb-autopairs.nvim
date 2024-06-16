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
			-- Handle inserting quotes.
			-- TODO: only when whitespace on left or brace on left
			vim.keymap.set("i", pair.left, pair.left .. pair.right .. "<Left>")
		else
			-- Handle inserting closing brace. It does not attempt to "wrap" anything in braces.
			vim.keymap.set("i", pair.left, function()
				local left, right = get_surrounding()

				if right == "" or right:match("%s") then
					-- Complete braces when end of line or whitespace on right.
					feedkeys(pair.left .. pair.right .. "<Left>")
				elseif
					(left == "(" and right == ")")
					or (left == "[" and right == "]")
					or (left == "{" and right == "}")
				then
					-- Complete braces when already between any braces.
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
