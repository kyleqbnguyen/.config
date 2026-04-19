local git_cache = {}
local diag_cache = {}

local git_group = vim.api.nvim_create_augroup("statusline_git", { clear = true })

local function run_git(args, repo)
	local escaped_args = vim.fn.map(args, function(_, arg)
		return vim.fn.shellescape(arg)
	end)
	local cmd = "git -C " .. vim.fn.shellescape(repo) .. " " .. table.concat(escaped_args, " ") .. " 2>/dev/null"
	return vim.fn.systemlist(cmd)
end

local function buf_dir(bufnr)
	local bufname = vim.api.nvim_buf_get_name(bufnr)
	local dir = vim.uv.cwd()

	if bufname ~= "" then
		local normalized = vim.fs.normalize(bufname)
		if vim.fn.isdirectory(normalized) == 1 then
			dir = normalized
		else
			dir = vim.fs.dirname(normalized)
		end
	end

	return dir
end

local function current_repo(bufnr)
	local root = run_git({ "rev-parse", "--show-toplevel" }, buf_dir(bufnr))[1]

	if not root or root == "" then
		return nil
	end

	return root
end

local function parse_numstat(lines)
	local added = 0
	local removed = 0

	for _, line in ipairs(lines) do
		local a, r = line:match("^(%d+)%s+(%d+)%s+")
		if a and r then
			added = added + tonumber(a)
			removed = removed + tonumber(r)
		end
	end

	return added, removed
end

local function redraw_statusline()
	vim.cmd("redrawstatus")
end

local function update_git_cache(bufnr)
	if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
		return
	end

	local repo = current_repo(bufnr)
	if not repo then
		git_cache[bufnr] = nil
		return
	end

	local status_lines = run_git({ "status", "--porcelain=1", "--branch" }, repo)
	local unstaged_numstat = run_git({ "diff", "--numstat" }, repo)
	local staged_numstat = run_git({ "diff", "--cached", "--numstat" }, repo)
	local modified_files = run_git({ "status", "--porcelain=1" }, repo)
	local branch = ""
	local unstaged_added, unstaged_removed = parse_numstat(unstaged_numstat)
	local staged_added, staged_removed = parse_numstat(staged_numstat)
	local added = unstaged_added + staged_added
	local removed = unstaged_removed + staged_removed
	local changed_files = {}

	for _, line in ipairs(status_lines) do
		if vim.startswith(line, "## ") then
			branch = line:sub(4):match("^[^. ]+") or ""
		end
	end

	for _, line in ipairs(modified_files) do
		local x = line:sub(1, 1)
		local y = line:sub(2, 2)
		local path = line:sub(4)

		if line:sub(1, 2) ~= "??" and path ~= "" and x ~= "D" and y ~= "D" and (x == "M" or x == "R" or y == "M") then
			changed_files[path] = true
		end
	end

	git_cache[bufnr] = {
		repo = repo,
		branch = branch,
		added = added,
		removed = removed,
		changed = vim.tbl_count(changed_files),
	}
end

local function update_diag_cache(bufnr)
	if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
		return
	end

	diag_cache[bufnr] = {
		errors = #vim.diagnostic.get(bufnr, { severity = vim.diagnostic.severity.ERROR }),
		warns = #vim.diagnostic.get(bufnr, { severity = vim.diagnostic.severity.WARN }),
		info = #vim.diagnostic.get(bufnr, { severity = vim.diagnostic.severity.INFO }),
		hints = #vim.diagnostic.get(bufnr, { severity = vim.diagnostic.severity.HINT }),
	}
end

vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "FocusGained", "VimEnter", "DirChanged" }, {
	group = git_group,
	callback = function(args)
		local bufnr = args.buf == 0 and vim.api.nvim_get_current_buf() or args.buf
		update_git_cache(bufnr)
		redraw_statusline()
	end,
})

vim.api.nvim_create_autocmd({ "BufEnter", "DiagnosticChanged", "VimEnter" }, {
	group = git_group,
	callback = function(args)
		local bufnr = args.buf == 0 and vim.api.nvim_get_current_buf() or args.buf
		update_diag_cache(bufnr)
		redraw_statusline()
	end,
})

local function cached_git(bufnr)
	return git_cache[bufnr] or {
		branch = "",
		added = 0,
		removed = 0,
		changed = 0,
	}
end

local function cached_diag(bufnr)
	return diag_cache[bufnr] or {
		errors = 0,
		warns = 0,
		info = 0,
		hints = 0,
	}
end

function StatusLine()
	local bufnr = vim.api.nvim_get_current_buf()
	local git = cached_git(bufnr)
	local diag = cached_diag(bufnr)
	local parts = {}

	if git.branch ~= "" then
		table.insert(parts, "[" .. git.branch .. "]")
	end

	local git_parts = {}
	if git.added > 0 then
		table.insert(git_parts, "+" .. git.added)
	end
	if git.removed > 0 then
		table.insert(git_parts, "-" .. git.removed)
	end
	if git.changed > 0 then
		table.insert(git_parts, "~" .. git.changed)
	end
	if #git_parts > 0 then
		table.insert(parts, table.concat(git_parts, " "))
	end

	table.insert(parts, "%f %m")

	local diag_parts = {}
	if diag.errors > 0 then
		table.insert(diag_parts, "E:" .. diag.errors)
	end
	if diag.warns > 0 then
		table.insert(diag_parts, "W:" .. diag.warns)
	end
	if diag.info > 0 then
		table.insert(diag_parts, "I:" .. diag.info)
	end
	if diag.hints > 0 then
		table.insert(diag_parts, "H:" .. diag.hints)
	end
	if #diag_parts > 0 then
		table.insert(parts, table.concat(diag_parts, " "))
	end

	table.insert(parts, "%=%l,%c %y%r")

	return table.concat(parts, " ")
end

vim.o.statusline = "%{%v:lua.StatusLine()%}"
