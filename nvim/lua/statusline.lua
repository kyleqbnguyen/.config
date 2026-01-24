local git_cache = { branch = "", added = 0, changed = 0, removed = 0 }

local function update_git_cache()
  -- Get branch name
  local branch = vim.fn.system("git branch --show-current 2>/dev/null"):gsub("\n", "")
  git_cache.branch = branch ~= "" and branch or ""

  -- Get diff stats (added/changed/removed lines)
  local added, removed = 0, 0
  local numstat = vim.fn.system("git diff --numstat 2>/dev/null")
  for a, r in numstat:gmatch("(%d+)%s+(%d+)%s+[^\n]+") do
    added = added + tonumber(a)
    removed = removed + tonumber(r)
  end
  git_cache.added = added
  git_cache.removed = removed

  -- Changed files count
  local status = vim.fn.system("git diff --name-only 2>/dev/null")
  local changed = 0
  for _ in status:gmatch("[^\n]+") do
    changed = changed + 1
  end
  git_cache.changed = changed
end

-- Update cache on relevant events
vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained", "BufWritePost", "VimEnter" }, {
  group = vim.api.nvim_create_augroup("statusline_git", { clear = true }),
  callback = update_git_cache,
})

function StatusLine()
  local parts = {}

  -- Git branch
  if git_cache.branch ~= "" then
    table.insert(parts, "[" .. git_cache.branch .. "]")
  end

  -- Git diff stats
  local diff_parts = {}
  if git_cache.added > 0 then table.insert(diff_parts, "+" .. git_cache.added) end
  if git_cache.removed > 0 then table.insert(diff_parts, "-" .. git_cache.removed) end
  if #diff_parts > 0 then
    table.insert(parts, table.concat(diff_parts, " "))
  end

  -- File info
  table.insert(parts, "%f %m")

  -- Diagnostics
  local diag_parts = {}
  local errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
  local warns = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
  local info = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
  local hints = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
  if errors > 0 then table.insert(diag_parts, "E:" .. errors) end
  if warns > 0 then table.insert(diag_parts, "W:" .. warns) end
  if info > 0 then table.insert(diag_parts, "I:" .. info) end
  if hints > 0 then table.insert(diag_parts, "H:" .. hints) end
  if #diag_parts > 0 then
    table.insert(parts, table.concat(diag_parts, " "))
  end

  -- Right side: position, filetype, readonly
  table.insert(parts, "%=%l,%c %y%r")

  return table.concat(parts, " ")
end

vim.o.statusline = "%{%v:lua.StatusLine()%}"
