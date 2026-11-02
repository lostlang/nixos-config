{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (config.services.cloudflare) enable tunnels;
in
{
  imports = [
    ./sops.nix
  ];

  options.services.cloudflare = {
    enable = lib.mkEnableOption "Cloudflare token-based tunnels";
    tunnels = lib.mkOption {
      description = "Cloudflare tunnel names to run using their corresponding SOPS token secrets.";
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
  };

  config.systemd.services = lib.mkIf enable (
    builtins.listToAttrs (
      map (name: {
        name = "cloudflared-tunnel-${name}";

        value = {
          description = "Cloudflare tunnel ${name}";

          wantedBy = [ "multi-user.target" ];
          wants = [ "network-online.target" ];
          after = [ "network-online.target" ];

          serviceConfig = {
            ExecStart = lib.escapeShellArgs [
              (lib.getExe pkgs.cloudflared)
              "tunnel"
              "--no-autoupdate"
              "run"
              "--token-file"
              config.sops.secrets."cloudflare.tunnel.${name}".path
            ];
            Restart = "on-failure";
          };
        };
      }) tunnels
    )
  );
}
