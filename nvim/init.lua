--------------------------------------------------------------------------------
-- Gui
vim.g.netrw_banner = 0
vim.o.number = true
vim.o.relativenumber = true
vim.opt.guicursor = { "n-v:block", "i-c:block-blinkon500-blinkoff500" }
vim.o.statusline = "%f %m%=%c %q%y%r"
vim.o.scrolloff = 8
vim.o.colorcolumn = "81"
vim.o.signcolumn = "yes"
vim.o.winborder = "single"
vim.o.termguicolors = true

-- Text
vim.o.tabstop = 2
vim.o.wrap = false
vim.o.smartindent = true
vim.o.incsearch = true

-- Misc
vim.o.swapfile = false
vim.o.backup = false
vim.o.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.o.undofile = true

-- Remap
vim.g.mapleader = " "

vim.keymap.set("n", "<leader>nw", vim.cmd.Ex)
vim.keymap.set("n", "<leader>gq", vim.lsp.buf.format)
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "G", "Gzz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
vim.keymap.set({ "n", "v", "x" }, "<leader>y", [["+y]])
vim.keymap.set({ "n", "v", "x" }, "<leader>d", [["+d]])
vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)
vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww ~/.local/bin/tmux-sessionizer<CR>")

--------------------------------------------------------------------------------
-- Pack
vim.pack.add({
	{ src = "https://github.com/neovim/nvim-lspconfig" },
	{ src = "https://github.com/metalelf0/black-metal-theme-neovim" },
	{ src = "https://github.com/nvim-lua/plenary.nvim" },
	{ src = "https://github.com/nvim-telescope/telescope.nvim" },
	{ src = "https://github.com/nvim-telescope/telescope-fzf-native.nvim", build = "make" },
	{ src = "https://github.com/mason-org/mason.nvim" },
	{ src = "https://github.com/mbbill/undotree" },
	{ src = "https://github.com/MeanderingProgrammer/render-markdown.nvim" },
})

vim.api.nvim_create_autocmd('LspAttach', {
	group = vim.api.nvim_create_augroup('my.lsp', {}),
	callback = function(args)
		local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
		if client:supports_method('textDocument/completion') then
			vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
		end
	end,
})
vim.cmd [[set completeopt+=menuone,noselect,popup]]

vim.lsp.enable({ "lua_ls" , "jdtls" })
vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			workspace = {
				library = vim.api.nvim_get_runtime_file("", true),
			}
		}
	}
})

require "telescope".setup({
	defaults = {
		mappings = {
			n = {
				["<C-c>"] = require("telescope.actions").close,
			},
		},
	},

	pickers = {
		find_files = {
			theme = 'dropdown',
			border = true,
			borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
		},

		live_grep = {
			theme = 'dropdown',
			border = true,
			borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
		},

		help_tags = {
			theme = 'dropdown',
			border = true,
			borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
		},

		git_files = {
			theme = 'dropdown',
			border = true,
			borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
		},
	},

	extensions = {
		fzf = {
			fuzzy = true,
			override_generic_sorter = true,
			override_file_sorter = true,
			case_mode = "smart_case",
		}
	},
})

require("black-metal").setup({
	theme = "darkthrone",
	variant = "dark",
	alt_bg = false,
	colored_docstrings = true,
	cursorline_gutter = false,
	dark_gutter = true,
	favor_treesitter_hl = false,
	plain_float = true,
	show_eob = true,
	term_colors = true,
	toggle_variant_key = nil,
	transparent = false,

	diagnostics = {
		darker = true,
		undercurl = false,
		background = false,
	},

	code_style = {
		comments = "none",
		conditionals = "none",
		functions = "none",
		keywords = "none",
		headings = "bold",
		operators = "none",
		keyword_return = "none",
		strings = "none",
		variables = "none",
	},
	highlights = {
		ColorColumn = { bg = "fg"},
		Visual = { fg = "type" },
		StatusLine = { bg = "fg" , fg = "bg" },
		["@punctuation.bracket"] = { fg = "constant" },
		["@constructor.lua"] = { fg = "constant" },
	},
})

require("render-markdown").setup({
	completions = { lsp = { enabled = true } },
	heading = {
		sign = false,
		backgrounds = {
			'RenderMarkdownH2Bg',
			'RenderMarkdownH2Bg',
			'RenderMarkdownH2Bg',
			'RenderMarkdownH2Bg',
			'RenderMarkdownH2Bg',
			'RenderMarkdownH2Bg',
		},
	},
	code = {
		highlight = 'RenderMarkdownH3Bg',
		highlight_border = 'RenderMarkdownH3Bg',
	},
})
require("black-metal").load()

require("mason").setup()

vim.keymap.set("n", "<leader>ff", ":Telescope find_files<CR>")
vim.keymap.set("n", "<leader>gr", ":Telescope live_grep<CR>")
vim.keymap.set("n", "<leader>gf", ":Telescope git_files<CR>")
vim.keymap.set("n", "<leader>ht", ":Telescope help_tags<CR>")

--------------------------------------------------------------------------------
