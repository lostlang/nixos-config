{ ... }: {
programs.nixvim = {
	plugins.lualine = {
		enable = true;
		disabledFiletypes = {
			statusline = [ "dashboard" "alpha" "starter" "filesystem"];
		};
		sections = {
			lualine_a = [ "mode" ];
			lualine_b = [ "branch" ];
			lualine_c = [
				"filetype"
				{
					name.__raw = ''
function()
	local msg = ""
	local buf_ft = vim.api.nvim_buf_get_option(0, 'filetype')
	local clients = vim.lsp.get_active_clients()
	if next(clients) == nil then
		return msg
	end
	for _, client in ipairs(clients) do
		local filetypes = client.config.filetypes
		if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
			return string.format("%s %s", client.name, require('lsp-status').status())
		end
	end
	return msg
end
'';
				}
				"encoding"
			];
			lualine_x = [ "diff" "diagnostics" ];
			lualine_y = [ "location" ];
			lualine_z = [ "os.date(\"!%H:%M\", os.time() + (60 * 60 * 5))" ];
		};
	};
};
}
