return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	lazy = false,
	build = ":TSUpdate",
	config = function()
		-- the tree-sitter CLI shells out to cl.exe on Windows; fall back to the mingw gcc
		if vim.fn.executable("cl") == 0 and vim.fn.executable("gcc") == 1 then
			vim.env.CC = "gcc"
		end

		require("nvim-treesitter").setup()

		local ensure_installed = { "lua", "javascript", "markdown", "markdown_inline" }
		require("nvim-treesitter").install(ensure_installed)

		vim.api.nvim_create_autocmd("FileType", {
			callback = function(args)
				local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
				if not lang or not vim.treesitter.language.add(lang) then
					return
				end
				vim.treesitter.start(args.buf, lang)
				vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
			end,
		})
	end,
}
