{
  config,
  ...
}:
{
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    BITWARDENCLI_APPDATA_DIR = "${config.xdg.configHome}/bw/default";
  };
}
