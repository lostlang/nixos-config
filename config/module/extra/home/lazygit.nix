{
  lib,
  ...
}:
{
  programs.lazygit = {
    enable = lib.mkDefault false;

    settings = {
      gui.spinner.frames = [
        "⠋"
        "⠙"
        "⠹"
        "⠸"
        "⠼"
        "⠴"
        "⠦"
        "⠧"
        "⠇"
        "⠏"
      ];

      keybinding.commits = {
        moveDownCommit = [
          "<ctrl+j>"
          "<ctrl+down>"
        ];
        moveUpCommit = [
          "<ctrl+k>"
          "<ctrl+up>"
        ];
      };
    };
  };
}
