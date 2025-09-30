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
	{ src = "https://github.com/nvim-lua/plenary.nvim" },
	{ src = "https://github.com/nvim-telescope/telescope.nvim" },
	{ src = "https://github.com/nvim-telescope/telescope-fzf-native.nvim", build = "make" },
	{ src = "https://github.com/mason-org/mason.nvim" },
	{ src = "https://github.com/mbbill/undotree" },
	{ src = "https://github.com/MeanderingProgrammer/render-markdown.nvim" },
	{ src = "https://github.com/slugbyte/lackluster.nvim" },
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

vim.lsp.enable({ "lua_ls" , "jdtls", "ts_ls" })
vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			workspace = {
				library = vim.api.nvim_get_runtime_file("", true),
			}
		}
	}
})

local square_borders = { "─", "│", "─", "│", "┌", "┐", "┘", "└" }

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
      theme = "dropdown",
      borderchars = square_borders,
    },
    live_grep = {
      theme = "dropdown",
      borderchars = square_borders,
    },
    help_tags = {
      theme = "dropdown",
      borderchars = square_borders,
    },
    git_files = {
      theme = "dropdown",
      borderchars = square_borders,
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

require("render-markdown").setup({
	completions = { lsp = { enabled = true } },
	heading = {
		sign = false,
	},
})

local color = require("lackluster").color

require("lackluster").setup({
	tweak_highlight = {
		-- modify @keyword's highlights to be bold and italic
		["@keyword"] = {
			overwrite = false, -- overwrite falsey will extend/update lackluster's defaults (nil also does this)
			bold = true,
			italic = false,
			-- see `:help nvim_set_hl` for all possible keys
		},
		-- overwrite @function to link to @keyword
		["@function"] = {
			overwrite = true, -- overwrite == true will force overwrite lackluster's default highlights
			link = "@keyword",
		},
	},
	tweak_ui = {
		disable_undercurl = true,
		enable_end_of_buffer = true,
	},
	tweak_syntax = {
		comment = color.gray4, -- or gray5
	},
	tweak_background = {
		normal = 'none',
		menu = color.gray3,
		popup = 'default',
	},
})
vim.cmd("colorscheme lackluster-dark")

require("mason").setup()

vim.keymap.set("n", "<leader>ff", ":Telescope find_files<CR>")
vim.keymap.set("n", "<leader>gr", ":Telescope live_grep<CR>")
vim.keymap.set("n", "<leader>gf", ":Telescope git_files<CR>")
vim.keymap.set("n", "<leader>ht", ":Telescope help_tags<CR>")

--------------------------------------------------------------------------------
