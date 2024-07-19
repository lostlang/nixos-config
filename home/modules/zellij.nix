{ lib, ... }: {
xdg.configFile."zellij/layouts/code.kdl" = lib.mkIf (true) {
	text = ''
layout {
	tab name="nvim" focus=true{
		pane {
			command "nvim"
		}
		pane size=1 borderless=true {
			plugin location="zellij:status-bar"
		}
	}
	tab name="terminal"{
		pane split_direction="vertical"{
			pane {
			}
			pane {
			}
		}
		pane size=1 borderless=true {
			plugin location="zellij:status-bar"
		}
	}
}
'';
};
programs.zellij = {
	enable = true;
	settings = {
		default_mode = "locked";
		theme = "lostsand";
		themes = {
			lostsand= {
				fg = "#437F06";
				bg = "#A69B9C";
				black = "#EDDFBF";
				red = "#EDDFBF";
				green = "#437F06";
				yellow = "#977407";
				blue = "#074297";
				magenta = "#970771";
				cyan = "#07974A";
				white = "#60577A";
				orange = "#973D07";
				};
		};
		keybinds = {
			locked = {
				"bind \"Alt f\"" = {
					GoToNextTab = {};
				};
			};
		};
	};
};
}
