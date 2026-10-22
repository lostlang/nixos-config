local source = {}

function source.new()
	return setmetatable({}, { __index = source })
end

function source:get_completions(_, callback)
	local items = {}

	for _, word in ipairs({ "TODO", "HACK", "WARN", "PERF", "TEST", "NOTE", "FIX" }) do
		local documentation = {
			kind = "markdown",
			value = "```markdown\n" .. word .. ": \n```",
		}
		table.insert(items, {
			label = word,
			filterText = "todo" .. word,
			insertText = word .. ": ",
			kind = vim.lsp.protocol.CompletionItemKind.Keyword,
			kind_name = "Todo",
			documentation = documentation,
		})
	end

	callback({
		items = items,
		is_incomplete_forward = false,
		is_incomplete_backward = false,
	})
end

return source
