{ pkgs, ... }:
{
  programs.nixvim = {
    extraPlugins = with pkgs.vimUtils; [
      (buildVimPlugin {
        pname = "lostsand.nvim";
        version = "latest";
        src = pkgs.fetchFromGitHub {
          owner = "lostlang";
          repo = "lostsand.nvim";
          rev = "68ec085a5efff0aeb222cbeafbaaa982a439744b";
          hash = "sha256-ECd1nOMsSv4Nqv9x2wZddB/y/3nPlaNV+MOxJhfjejU=";
        };
      })
    ];
  };
}
