local M = {}

--- @param str1 string
--- @param str2 string
--- @param pos integer
local function insert(str1, str2, pos)
	return str1:sub(1, pos) .. str2 .. str1:sub(pos + 1)
end

--- @param tc {name: string, before: string, feed: string, after: string[]}
M.run_test = function(tc)
	before_each(function()
		vim.cmd("bd!")
		vim.cmd(":new")

		local col, _ = tc.before:find("|")
		local text = tc.before:gsub("|", "")

		vim.api.nvim_set_current_line(text)
		vim.fn.setcursorcharpos(1, col - 1)
		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(tc.feed, true, false, true), "x", false)
	end)

	after_each(function()
		vim.cmd("bd!")
	end)

	it(tc.name, function()
		local _, curline, curcol, _ = unpack(vim.fn.getcharpos("."))
		local actual_lines = {}

		for i, line in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, true)) do
			if i == curline then
				table.insert(actual_lines, insert(line, "|", curcol))
			else
				table.insert(actual_lines, line)
			end
		end

		assert.are.same(tc.after, actual_lines)
	end)
end

return M
