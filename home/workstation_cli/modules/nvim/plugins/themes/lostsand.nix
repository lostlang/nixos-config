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
          rev = "938e669412590b95f05225bdcd730a3f8fb15564";
          hash = "sha256-7PZRWYPww/CqBztfrUfBdPAyaPGQKqLTqSWyMeHxNMY=";
        };
      })
    ];
  };
}
