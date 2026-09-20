return {
	"junegunn/goyo.vim",
	keys = {
		{ "<leader>go", "<cmd>Goyo<cr>", desc = "Toggle Goyo" },
	},
	config = function()
		vim.api.nvim_create_autocmd("User", {
			pattern = "GoyoEnter",
			callback = function()
				require("lualine").hide({ unhide = false })
			end,
		})
		vim.api.nvim_create_autocmd("User", {
			pattern = "GoyoLeave",
			callback = function()
				require("lualine").hide({ unhide = true })
			end,
		})
	end,
}
