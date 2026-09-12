{
  programs.nixvim.plugins.todo-comments = {
    enable = true;

    settings.keywords = {
      TODO.icon = "󰈸 ";
      HACK.icon = " ";
      WARN.icon = " ";
      PERF.icon = "󰓅 ";
      TEST.icon = "󰙨 ";
      NOTE.icon = " ";
      FIX.icon = "󰃤 ";
    };
  };
}
