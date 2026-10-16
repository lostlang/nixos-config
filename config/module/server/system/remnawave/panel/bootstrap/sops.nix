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
  sops = lib.mkIf (cfg.enable && cfg.bootstrap.enable && nodes != [ ]) {
    secrets =
      lib.genAttrs (map domainSecret nodes) (_: { })
      // {
        "remnawave.api-token".restartUnits = [ "remnawave-node-bootstrap.service" ];
      }
      // lib.optionalAttrs config.services.adguardhome.enable {
        "domain.adguardhome".restartUnits = [ "remnawave-node-bootstrap.service" ];
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
