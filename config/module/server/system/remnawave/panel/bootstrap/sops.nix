{
  config,
  lib,
  ...
}:
let
  cfg = config.services.remnawave-panel;
  nodes = lib.unique (cfg.nodes.basic ++ cfg.nodes.hopping);
  domainSecret = host: "domain.remnawave.node.${host}";
in
{
  sops = lib.mkIf (cfg.enable && nodes != [ ]) {
    secrets = lib.genAttrs (map domainSecret nodes) (_: { });

    templates."remnawave-node-bootstrap.env" = {
      mode = "0400";
      restartUnits = [ "remnawave-node-bootstrap.service" ];
      content = ''
        ADGUARD_DOMAIN=${
          lib.optionalString config.services.adguardhome.enable config.sops.placeholder."domain.adguardhome"
        }
        API_TOKEN=${config.sops.placeholder."remnawave.api-token"}
      '';
    };

    templates."remnawave-node-domains.json" = {
      mode = "0400";
      restartUnits = [ "remnawave-node-bootstrap.service" ];
      content = builtins.toJSON {
        basic = map (host: {
          inherit host;
          domain = config.sops.placeholder.${domainSecret host};
        }) cfg.nodes.basic;
        hopping = map (host: {
          inherit host;
          domain = config.sops.placeholder.${domainSecret host};
        }) cfg.nodes.hopping;
      };
    };
  };
}
