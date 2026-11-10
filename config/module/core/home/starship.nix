{
  stylix.targets.starship.enable = false;

  programs.starship = {
    enable = true;

    enableZshIntegration = true;
    enableBashIntegration = true;

    settings = {
      package.style = "bold cyan";
      directory.style = "bold green";
      cmd_duration.style = "bold bright-green";

      git_branch.disabled = true;
      git_status.disabled = true;
    };
  };
}
