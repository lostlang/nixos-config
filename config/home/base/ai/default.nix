let
  provider = import ./provider.nix;
in
{
  imports = [
    ./aichat
    ./aider
  ];

  _module.args.provider = provider;
}
