{
  programs.tmux = {
    enable = true;

    escapeTime = 0;
    keyMode = "vi";
    mouse = true;
    terminal = "tmux-256color";

    extraConfig = ''
      set-option -sa terminal-features ",*:RGB"
      set-option -s set-clipboard on
      set-option -g allow-passthrough on
    '';
  };
}
