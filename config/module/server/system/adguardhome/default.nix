{
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
}
