local configured = {}

local function configure_comment_folds(language, grammar)
	local comment_patterns = {}
	for name, named in pairs(grammar.symbols) do
		if named and (name == "comment" or name:match("_comment$")) then
			table.insert(comment_patterns, "(" .. name .. ")")
		end
	end
	if #comment_patterns == 0 then
		return
	end
	table.sort(comment_patterns)

	-- Extend the existing fold queries with comment nodes.
	local queries = {}
	for _, path in ipairs(vim.treesitter.query.get_files(language, "folds")) do
		table.insert(queries, table.concat(vim.fn.readfile(path), "\n"))
	end
	table.insert(queries, "([" .. table.concat(comment_patterns, " ") .. "]+ @fold)")
	local query = table.concat(queries, "\n")
	vim.treesitter.query.parse(language, query)
	vim.treesitter.query.set(language, "folds", query)
end

local function add_comment_folds(event)
	local language = vim.treesitter.language.get_lang(vim.bo[event.buf].filetype)
	if not language or configured[language] then
		return
	end

	local ok, grammar = pcall(vim.treesitter.language.inspect, language)
	if not ok then
		return
	end

	local success, err = pcall(configure_comment_folds, language, grammar)
	if success then
		configured[language] = true
	else
		vim.notify(tostring(err), vim.log.levels.WARN, { title = "CommentFolds" })
	end
end

vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("CommentFolds", { clear = true }),
	callback = add_comment_folds,
})
