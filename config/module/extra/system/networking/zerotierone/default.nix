{
  config,
  lib,
  ports,
  ...
}:
let
  inherit (config.services.zerotierone) enable interfaces;
in
{
  imports = [
    ./sops.nix
  ];

  options.services.zerotierone.interfaces = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ ];
  };

  config = lib.mkIf enable {
    networking.firewall.extraInputRules = lib.concatMapStringsSep "\n" (name: ''
      include "${config.sops.templates."zerotier/${name}.nft".path}"
    '') interfaces;

    services.zerotierone.port = ports.zerotierone;
  };
}
