local utils = require("tests.test_utils")

local data = {
	{
		name = "pair",
		before = { [[|]] },
		feed = [[a"]],
		after = { [["|"]] },
	},
	{
		name = "pair after brace open",
		before = { [[(|]] },
		feed = [[a"]],
		after = { [[("|"]] },
	},
	{
		name = "pair before brace close inside list between braces",
		before = { [[,|)]] },
		feed = [[a"]],
		after = { [[,"|")]] },
	},
	{
		name = "manual close",
		before = { [["|"]] },
		feed = [[a"]],
		after = { [[""|]] },
	},
	{
		name = "no pair when existing quote on right",
		before = { [[|"]] },
		feed = [[i"]],
		after = { [["|]] },
	},
	{
		name = "no pair when existing quote on right and word on left",
		before = { [[word|"]] },
		feed = [[a"]],
		after = { [[word"|]] },
	},
	{
		name = "no pair when existing quote left",
		before = { [["|]] },
		feed = [[a"]],
		after = { [[""|]] },
	},
	{
		name = "no pair when word on left",
		before = { [[word|]] },
		feed = [[a"]],
		after = { [[word"|]] },
	},
	{
		name = "no pair when word on right",
		before = { [[|word]] },
		feed = [[i"]],
		after = { [["|word]] },
	},
	{
		name = "backspace between adjacent quotes deletes both",
		before = { [["|"]] },
		feed = [[a<BS>]],
		after = { [[|]] },
	},
	{
		name = "backspace between spaced quotes deletes left",
		before = { [["| "]] },
		feed = [[a<BS>]],
		after = { [[ |"]] },
	},
}

describe("quotes", function()
	before_each(function()
		require("dumb-autopairs").setup({
			pairs = {
				{
					left = '"',
					right = '"',
				},
			},
		})
	end)

	for _, tc in ipairs(data) do
		utils.run_test(tc)
	end
end)
