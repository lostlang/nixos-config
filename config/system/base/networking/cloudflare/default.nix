{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (config.myConfig.cloudflare) enable;
  inherit (config.myConfig.cloudflare) tunnels;
in
{
  imports = [
    ./options.nix
    ./sops.nix
  ];

  systemd.services = lib.mkIf (enable && tunnels != [ ]) (
    builtins.listToAttrs (
      map (name: {
        name = "cloudflared-tunnel-${name}";
        value = {
          wantedBy = [ "multi-user.target" ];
          wants = [ "network-online.target" ];
          after = [ "network-online.target" ];

          serviceConfig = {
            EnvironmentFile = config.sops.templates."cloudflare/${name}.env".path;
            ExecStart = "${pkgs.cloudflared}/bin/cloudflared tunnel --no-autoupdate run --token $TUNNEL_TOKEN";
          };
        };
      }) tunnels
    )
  );
}
