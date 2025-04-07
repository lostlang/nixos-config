{ pkgs, ... }:
{
  programs.nixvim = {
    extraPlugins = with pkgs.vimUtils; [
      (buildVimPlugin {
        pname = "minuet-ai.nvim";
        version = "latest";
        src = pkgs.fetchFromGitHub {
          owner = "milanglacier";
          repo = "minuet-ai.nvim";
          rev = "b28affc5a6556e95eaf57a81dd910b087bb46dbe";
          hash = "sha256-UX1zUdijQ31u6KTMTEwxqREENndoV28TR6pnrYNUZFE=";
        };
      })
    ];
  };

  programs.nixvim.extraConfigLua = ''
    require('minuet').setup {
      provider = 'openai_fim_compatible',
      n_completions = 1,
      -- context_window = 1024,
      throttle = 1000,
      debounce = 1000,
      notify = 'debug',
      cmp = { enable_auto_complete = true },
      virtualtext = {
        show_on_completion_menu = true,
        auto_trigger_ft = { "*" },
        keymap = {
          accept = '<A-CR>',
          accept_line = '<A-SPACE>',
          accept_n_lines = '<A-z>',
          prev = '<A-LEFT>',
          next = '<A-RIGHT>',
          dismiss = '<A-ESC>',
        },
      },
      provider_options = {
        openai_fim_compatible = {
          name = "Ollama",
          api_key = 'TERM',
          end_point = "http://localhost:11434/v1/completions",
          model = "qwen2.5-coder:3b",
          stream  = true,
          optional = {
            max_tokens = 1024,
            top_p = 0.5,
          },
        },
      },
    }
  '';
}
