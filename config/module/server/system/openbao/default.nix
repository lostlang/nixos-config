{
  config,
  lib,
  ports,
  ...
}:
{
  imports = [
    ./bootstrap
    ./sops.nix
    ./traefik.nix
  ];

  environment = lib.mkIf config.services.openbao.enable {
    systemPackages = [ config.services.openbao.package ];
    sessionVariables.BAO_ADDR = "http://127.0.0.1:${toString ports.openbao.api}";
  };

  services.openbao = lib.mkIf config.services.openbao.enable {
    settings = {
      ui = true;

      seal.static = {
        current_key_id = "sops-static-1";
        current_key = "env://BAO_STATIC_UNSEAL_KEY";
      };

      storage.raft.path = "/var/lib/openbao";
      cluster_addr = "https://127.0.0.1:${toString ports.openbao.cluster}";

      listener.default = {
        type = "tcp";
        address = "127.0.0.1:${toString ports.openbao.api}";
        cluster_address = "127.0.0.1:${toString ports.openbao.cluster}";
        tls_disable = true;
      };
    };
  };
}
