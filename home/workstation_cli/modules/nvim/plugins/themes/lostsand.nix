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
	  rev = "4f6ef28589042f186e0f589b6134370883f1cc75";
          hash = "sha256-7PZRWYPww/CqBztfrUfBdPAyaPGQKqLTqSWyMeHxNMY=";
        };
      })
    ];
  };
}
