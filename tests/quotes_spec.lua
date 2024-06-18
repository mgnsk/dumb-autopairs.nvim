local utils = require("tests.test_utils")

local data = {
	{
		name = "pair",
		before = [[|]],
		feed = [[a"]],
		after = { [["|"]] },
	},
	{
		name = "pair after brace open",
		before = [[(|]],
		feed = [[a"]],
		after = { [[("|"]] },
	},
	{
		name = "pair before brace close",
		before = [[|)]],
		feed = [[i"]],
		after = { [["|")]] },
	},
	{
		name = "manual close",
		before = [["|"]],
		feed = [[a"]],
		after = { [[""|]] },
	},
	{
		name = "no pair when existing quote on right",
		before = [[|"]],
		feed = [[i"]],
		after = { [["|]] },
	},
	{
		name = "no pair when existing quote on right",
		before = [[word|"]],
		feed = [[a"]],
		after = { [[word"|]] },
	},
	{
		name = "no pair when non-empty or non-bracket on left",
		before = [[word|]],
		feed = [[a"]],
		after = { [[word"|]] },
	},
	{
		name = "no pair when non-empty or non-bracket on right",
		before = [[|word]],
		feed = [[i"]],
		after = { [["|word]] },
	},
	{
		name = "pair when operator on left",
		before = [[=|]],
		feed = [[a"]],
		after = { [[="|"]] },
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
