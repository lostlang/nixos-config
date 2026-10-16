vim.api.nvim_create_user_command("CopyLineContext", function(args)
	local location = vim.fn.expand("%:.") .. ":" .. args.line1
	if args.line2 ~= args.line1 then
		location = location .. "-" .. args.line2
	end

	vim.fn.setreg("+", location, "v")
	vim.notify("Copied " .. location, vim.log.levels.INFO)
end, {
	range = true,
	desc = "Copy file path and line numbers to clipboard",
})
