{
  pkgs,
  ...
}:
{
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    claude-code
    codex
  ];
}
