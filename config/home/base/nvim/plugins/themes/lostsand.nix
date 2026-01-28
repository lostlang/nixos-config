{
  pkgs,
  user,
  ...
}:
{
  programs.nixvim = {
    extraPlugins = with pkgs.vimUtils; [
      (buildVimPlugin {
        pname = "lostsand.nvim";
        version = "latest";
        src = pkgs.fetchFromGitHub {
          owner = user;
          repo = "lostsand.nvim";
          rev = "dc8ab2043837046efc19679caccf278a86b1408b";
          hash = "sha256-UlAOFQN+CzWc46H7CWQi6ATPp9puPqeBzMbEjvWyGXY=";
        };
      })
    ];
  };
}
