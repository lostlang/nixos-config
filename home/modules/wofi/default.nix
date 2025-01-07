{
programs.wofi = {
    enable = true;

    settings = {
		width = "400";
		height = "600";
		mode = "drun";
		allow_images = true;
		allow_markup = true;
		insensitive = true;
		hide_scroll = true;
    };
};

home.file.".config/wofi/style.css".source = "./style.css";
}
