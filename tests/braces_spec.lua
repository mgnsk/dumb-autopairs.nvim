local utils = require("tests.test_utils")

local data = {
	{
		name = "pair",
		before = { [[|]] },
		feed = [[a{]],
		after = { [[{|}]] },
	},
	{
		name = "nested pair",
		before = { [[{|}]] },
		feed = [[a{]],
		after = { [[{{|}}]] },
	},
	{
		name = "no pair when manually closing",
		before = { [[{|}]] },
		feed = [[a}]],
		after = { [[{}|]] },
	},
	{
		name = "pair when comma on right",
		before = { [[|,]] },
		feed = [[i{]],
		after = { [[{|},]] },
	},
	{
		name = "no pair when word on right",
		before = { [[|w]] },
		feed = [[i{]],
		after = { [[{|w]] },
	},
	{
		name = "no pair when word on right after space",
		before = { [[| w]] },
		feed = [[i{]],
		after = { [[{| w]] },
	},
	{
		name = "no pair between words",
		before = { [[w|w]] },
		feed = [[a{]],
		after = { [[w{|w]] },
	},
	{
		name = "enter between braces",
		before = { [[{|}]] },
		feed = [[a<CR>]],
		after = {
			[[{]],
			[[|]], -- Note: depends on filetype and autoindent.
			[[}]],
		},
	},
	{
		name = "enter between braces with space",
		before = { [[{   |   }]] },
		feed = [[a<CR>]],
		after = {
			[[{   ]],
			[[|]], -- Note: depends on filetype and autoindent.
			[[}]],
		},
	},
	{
		name = "backspace between braces",
		before = { [[{|}]] },
		feed = [[a<BS>]],
		after = { "|" },
	},
	{
		name = "backspace between braces with space",
		before = { [[{|   }]] },
		feed = [[a<BS>]],
		after = { "|" },
	},
	{
		name = "backspace between multiline braces",
		before = {
			[[{|]],
			"",
			"",
			[[}]],
		},
		feed = [[a<BS>]],
		after = { "|" },
	},
	{
		name = "backspace between multiline braces before word",
		before = {
			[[{|]],
			"",
			"",
			[[}]],
			[[word]],
		},
		feed = [[a<BS>]],
		after = {
			"|",
			"word",
		},
	},
	{
		name = "backspace between multiline nested braces",
		before = {
			[[{{|]],
			"",
			"",
			[[}}]],
		},
		feed = [[a<BS>]],
		after = { "{|}" },
	},
	{
		name = "backspace between nested braces",
		before = { [[{{|}}]] },
		feed = [[a<BS>]],
		after = { "{|}" },
	},
	{
		name = "backspace between braces containing word deletes left brace",
		before = { [[{|word}]] },
		feed = [[a<BS>]],
		after = { "w|ord}" }, -- TODO
	},
	{
		name = "backspace between braces containing word deletes left brace",
		before = { [[ {|word}]] }, -- Space in the beginning.
		feed = [[a<BS>]],
		after = { " |word}" },
	},
}

describe("braces", function()
	before_each(function()
		require("dumb-autopairs").setup({
			pairs = {
				{
					left = "{",
					right = "}",
				},
			},
		})
	end)

	for _, tc in ipairs(data) do
		utils.run_test(tc)
	end
end)
