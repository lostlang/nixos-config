{
  config,
  lib,
  ...
}:
let
  enable = config.myConfig.cloudflare.enable;
  tunnels = config.myConfig.cloudflare.tunnels;

  mkSecret = name: [
    {
      name = "cloudflare.tunnel.${name}";
      value = { };
    }
  ];
  secretEntries = builtins.concatMap mkSecret tunnels;

  mkTemplate = name: [
    {
      name = "cloudflare/${name}.env";
      value = {
        content = ''
          TUNNEL_TOKEN=${config.sops.placeholder."cloudflare.tunnel.${name}"}
        '';
      };
    }
  ];
  templateEntries = builtins.concatMap mkTemplate tunnels;
in
{
  sops = lib.mkIf enable {
    secrets = builtins.listToAttrs secretEntries;
    templates = builtins.listToAttrs templateEntries;
  };
}
