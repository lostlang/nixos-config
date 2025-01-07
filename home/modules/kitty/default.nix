{ ... }: {
programs.kitty = {
    enable = true;
    settings = {
        confirm_os_window_close = 0;
        font_family = "JetBrainsMono";
        font_size = 14.0;
        include = "lostsand.conf";
    };
};

home.file.".config/kitty/lostsand.conf".source = ./lostsand.conf;
}
