{
  config,
  lib,
  ...
}:
let
  inherit (config.services.cloudflare) enable tunnels;
in
{
  sops.secrets = lib.mkIf enable (
    lib.genAttrs (map (name: "cloudflare.tunnel.${name}") tunnels) (
      secretName:
      let
        name = lib.removePrefix "cloudflare.tunnel." secretName;
      in
      {
        restartUnits = [ "cloudflared-tunnel-${name}.service" ];
      }
    )
  );
}
