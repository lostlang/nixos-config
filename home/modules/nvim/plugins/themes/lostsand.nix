{ pkgs, ... }:
{
  programs.nixvim = {
    extraPlugins = with pkgs.vimUtils; [
      (buildVimPlugin {
        pname = "lostsand.nvim";
        version = "2024-01-07";
        src = pkgs.fetchFromGitHub {
          owner = "lostlang";
          repo = "lostsand.nvim";
          tag = "v0.2.1";
          hash = "sha256-lcgRZgrUScsa5pm/6/MmIVPU/21nE6EvczYwPCF4YXQ=";
        };
      })
    ];
  };
}
