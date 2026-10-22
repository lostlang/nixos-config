{
  pkgs,
  ...
}:
{
  programs.zsh.initContent = /* sh */ ''
    eval "$(${pkgs.python3Packages.argcomplete}/bin/register-python-argcomplete --shell zsh \
      make-sandbox \
      rebuild-vps \
      system-clean \
      zp \
      zs \
    )"
  '';
}
