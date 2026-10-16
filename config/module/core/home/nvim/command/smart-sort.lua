local function row_range(node)
	local start_row, _, end_row, end_col = node:range()
	-- Treesitter ranges end just after the node.
	return start_row, end_col == 0 and end_row - 1 or end_row
end

-- Keep a trailing line break in its original separator slot.
local function node_end(node, lines)
	local row, col, byte = node:end_()
	if col == 0 and row > 0 then
		row = row - 1
		col = #lines[row + 1]
		byte = byte - 1
	end
	return row, col, byte
end

local function selected_children(node, first_row, end_row)
	local children = {}
	for child in node:iter_children() do
		if child:named() then
			local start_row, last_row = row_range(child)
			if start_row < end_row and last_row >= first_row then
				table.insert(children, child)
			end
		end
	end
	return children
end

local function sort_key(node, source)
	-- Grammars use different field names for an element's identifier.
	for _, field in ipairs({ "name", "key", "attrpath" }) do
		local key = node:field(field)[1]
		if key then
			return vim.treesitter.get_node_text(key, source)
		end
	end
	return vim.treesitter.get_node_text(node, source)
end

local function validate_syntax(source, language)
	local parser = vim.treesitter.get_string_parser(source, language)
	local ok, trees = pcall(parser.parse, parser)
	parser:destroy()
	if not ok then
		error("Could not validate sorted syntax: " .. tostring(trees), 0)
	end
	if trees[1]:root():has_error() then
		error("Sorting these nodes would produce invalid syntax", 0)
	end
end

local function smart_sort(args)
	if args.range == 0 then
		error("Select the elements first, or provide a line range", 0)
	end

	local buf = vim.api.nvim_get_current_buf()
	local ok, parser = pcall(vim.treesitter.get_parser, buf)
	if not ok or not parser then
		error("No Treesitter parser available for this buffer", 0)
	end
	local root = parser:parse()[1]:root()
	if root:has_error() then
		error("Fix syntax errors before sorting", 0)
	end

	-- Descend until the selection spans siblings, without sorting their contents.
	local first_row, end_row = args.line1 - 1, args.line2
	local children = selected_children(root, first_row, end_row)
	while #children == 1 do
		children = selected_children(children[1], first_row, end_row)
	end
	if #children < 2 then
		error("Select at least two sibling elements", 0)
	end

	local block_scalars = parser:lang() == "yaml" and vim.treesitter.query.parse("yaml", "(block_scalar) @scalar")
	local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
	local source = table.concat(lines, "\n") .. "\n"
	local items, gaps = {}, {}
	local previous_end
	for index, child in ipairs(children) do
		local start_row, last_row = row_range(child)
		if start_row < first_row or last_row >= end_row then
			error("Selection must include complete elements", 0)
		end
		if child:type():find("comment") then
			error("Comments between elements need to be moved manually", 0)
		end
		if block_scalars then
			-- Blank lines around YAML block scalars can change their values.
			for _ in block_scalars:iter_captures(child, buf) do
				error("YAML block scalars need to be sorted manually", 0)
			end
		end
		local _, _, start_byte = child:start()
		local _, _, end_byte = node_end(child, lines)
		if previous_end then
			-- Keep commas, semicolons, and whitespace in their original positions.
			local gap = source:sub(previous_end + 1, start_byte)
			if gap:find("[^%s,;]") then
				error("Cannot sort across comments or other syntax", 0)
			end
			gaps[index - 1] = gap
		end
		previous_end = end_byte
		items[index] = {
			text = source:sub(start_byte + 1, end_byte),
			key = sort_key(child, source),
			index = index,
		}
	end

	table.sort(items, function(a, b)
		if a.key == b.key then
			return a.index < b.index
		end
		if args.bang then
			return a.key > b.key
		end
		return a.key < b.key
	end)

	local parts = {}
	for index, item in ipairs(items) do
		parts[index] = item.text .. (gaps[index] or "")
	end
	local replacement = table.concat(parts)
	local start_row, start_col, start_byte = children[1]:start()
	local end_row, end_col, end_byte = node_end(children[#children], lines)
	if replacement == source:sub(start_byte + 1, end_byte) then
		return
	end

	validate_syntax(source:sub(1, start_byte) .. replacement .. source:sub(end_byte + 1), parser:lang())
	vim.api.nvim_buf_set_text(
		buf,
		start_row,
		start_col,
		end_row,
		end_col,
		vim.split(replacement, "\n", { plain = true })
	)
end

vim.api.nvim_create_user_command("SmartSort", function(args)
	local ok, err = pcall(smart_sort, args)
	if not ok then
		vim.notify(tostring(err), vim.log.levels.WARN, { title = "SmartSort" })
	end
end, {
	range = true,
	bang = true,
	desc = "Sort selected sibling elements with Treesitter (! reverses order)",
})
