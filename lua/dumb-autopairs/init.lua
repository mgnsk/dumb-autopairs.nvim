--- Feeds keys as if typed. No remapping.
--- @param keys string
local function feedkeys(keys)
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "n", false)
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

--- @param pair Pair
local function on_quote(pair)
	local left, right = get_surrounding()
	local rt = vim.trim(right)
	local lt = vim.trim(left)

	local hasopenleft = function(s)
		return vim.endswith(s, "(") or vim.endswith(s, "{") or vim.endswith(s, "[")
	end

	local hascloseright = function(s)
		return vim.startswith(s, ")") or vim.startswith(s, "}") or vim.startswith(s, "]")
	end

	if right:sub(1, 1) == pair.right then
		-- Manually close existing right quote.
		feedkeys("<Right>")
	elseif left:sub(-1) == pair.left then
		-- Manually close quote.
		feedkeys(pair.right)
	elseif vim.endswith(lt, ",") and hascloseright(rt) then
		-- Inside list.
		feedkeys(pair.left .. pair.right .. "<Left>")
	elseif (left:sub(-1) == " " or left:sub(-1) == "\t") and rt == "" then
		-- Go struct tags.
		feedkeys(pair.left .. pair.right .. "<Left>")
	elseif (lt:sub(-1) == ":" and right:sub(1, 1)) == "`" then
		-- Go struct tag values.
		feedkeys(pair.left .. pair.right .. "<Left>")
	elseif hasopenleft(lt) and hascloseright(rt) then
		-- Directly between braces.
		feedkeys(pair.left .. pair.right .. "<Left>")
	else
		feedkeys(pair.left)
	end
end

--- @param pair Pair
local function on_open_brace(pair)
	local _, right = get_surrounding()

	right = vim.trim(right)

	if
		right == ""
		or vim.startswith(right, ")")
		or vim.startswith(right, "}")
		or vim.startswith(right, "]")
		or vim.startswith(right, ",")
	then
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
		if vim.endswith(vim.trim(left), pair.left) and vim.startswith(vim.trim(right), pair.right) then
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

	for _, pair in ipairs(config["pairs"]) do
		-- Delete adjacent pair.
		if left:sub(-1) == pair.left and right:sub(1, 1) == pair.right then
			feedkeys("<Del><BS>")
			return
		end

		-- Delete braces pair when only whitespace in between and same line.
		if pair.left ~= pair.right and left:sub(-1) == pair.left then
			local endline, endcol = unpack(vim.fn.searchpairpos(pair.left, "", pair.right, "n"))

			if endline > 0 and endcol > 0 then
				local curline, curcol = unpack(vim.api.nvim_win_get_cursor(0))
				if endline == curline then
					local start_row = curline - 1
					local start_col = curcol
					local end_row = endline - 1
					local end_col = endcol - 1

					-- E5108: Error executing lua: ...vim/lazy/dumb-autopairs.nvim/lua/dumb-autopairs/init.lua:132: start_col must be less than or equal to end_col
					-- stack traceback:
					--         [C]: in function 'nvim_buf_get_text'
					--         ...vim/lazy/dumb-autopairs.nvim/lua/dumb-autopairs/init.lua:132: in function 'on_backspace'
					--         ...vim/lazy/dumb-autopairs.nvim/lua/dumb-autopairs/init.lua:223: in function <...vim/lazy/dumb-autopairs.nvim/lua/dumb-autopairs/init.lua:222>
					--         TODO: breaks with line break - same line but end col is less than start col

					local lines = vim.api.nvim_buf_get_text(0, start_row, start_col, end_row, end_col, {})

					local iswhitespace = true

					for _, line in ipairs(lines) do
						-- Match non-whitespace one or more.
						if line:match("%S+") then
							iswhitespace = false
							break
						end
					end

					if iswhitespace then
						vim.api.nvim_buf_set_text(0, start_row, start_col - 1, end_row, end_col + 1, { "" })
						return
					end
				end
			end
		end
	end

	feedkeys("<BS>")
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
				on_quote(pair)
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
