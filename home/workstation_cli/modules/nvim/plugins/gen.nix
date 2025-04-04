{ pkgs, ... }:
{
  programs.nixvim = {
    extraPlugins = with pkgs.vimUtils; [
      (buildVimPlugin {
        pname = "gen.nvim";
        version = "latest";
        src = pkgs.fetchFromGitHub {
          owner = "David-Kunz";
          repo = "gen.nvim";
          rev = "e09a8dbffa139ad60d5b47998fcc8669ead1ebf4";
          hash = "sha256-s3Ky2uhRviKAaKF3iCF2uHctzk+kFV7BnqyxAGwqhbo=";
        };
      })
    ];
  };

  programs.nixvim.extraConfigLua = ''
    require('gen').setup({
      model = "mistral:7b",
      host = "localhost",
      port = "11434",
    })
    require('gen').prompts['Explain'] = {
      prompt = "Explain the meaning of concept(context filetype $filetype):\n$text"
    }
    require('gen').prompts['Explain_word'] = {
      prompt = "Explain the word like in a dictionary(include language level and use example):\n$text"
    }
  '';
}
