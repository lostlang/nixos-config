{
  config,
  lib,
  ...
}:
let
  webPort = 43074;
  dnsPort = 51071;
in
{
  imports = [
    ./traefik.nix
  ];

  _module.args = { inherit dnsPort webPort; };

  services.adguardhome = {
    enable = lib.mkDefault false;

    host = "127.0.0.1";
    port = webPort;

    settings = {
      http.doh.insecure_enabled = true;

      dns = {
        bind_hosts = [ "127.0.0.1" ];
        port = dnsPort;

        upstream_dns = [
          "https://dns.cloudflare.com/dns-query"
          "https://dns.google/dns-query"
        ];

        bootstrap_dns = [
          "1.1.1.1"
          "8.8.8.8"
        ];

        cache_enabled = true;
        cache_size = 8 * 1024 * 1024;
      };

      statistics = {
        enabled = true;
        interval = "24h";
      };

      querylog = {
        enabled = true;
        interval = "24h";
      };

      filtering = {
        protection_enabled = true;
        filtering_enabled = true;
        filters_update_interval = 24;
      };
    };
  };

  # HACK: wait pr https://github.com/NixOS/nixpkgs/pull/554062
  systemd.services.adguardhome = lib.mkIf config.services.adguardhome.enable {
    preStart = lib.mkAfter ''
      configFile="$STATE_DIRECTORY/AdGuardHome.yaml"
      content="$(<"$configFile")"
      content="''${content/insecure_enabled: false/insecure_enabled: true}"
      printf '%s\n' "$content" > "$configFile"
    '';
  };
}
