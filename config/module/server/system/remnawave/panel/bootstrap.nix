{
  config,
  lib,
  pkgs,
  ports,
  pythonScriptEnv,
  hostname,
  user,
  ...
}:
let
  panelCfg = config.services.remnawave-panel;
  nodeArgs =
    lib.concatMap (name: [
      "--node"
      "Basic"
      name
    ]) panelCfg.nodes.basic
    ++ lib.concatLists (
      lib.mapAttrsToList (
        country: names:
        lib.concatMap (name: [
          "--node"
          "Hopping"
          name
          "--direct-country"
          name
          country
        ]) names
      ) panelCfg.nodes.hopping
    );
  dnsArgs = lib.optional config.services.adguardhome.enable "--adguard-dns";
  bootstrap = pkgs.writeShellApplication {
    name = "bootstrap-remnawave";

    runtimeInputs = [ pythonScriptEnv ];

    text = /* sh */ ''
      exec ${lib.getExe' pythonScriptEnv "python"} ${pythonScriptEnv.script "remnawave-bootstrap.py"} \
        --openbao-config-path ${lib.escapeShellArg "server/${hostname}"} \
        --api-port ${toString ports.remnawave.panel.port} \
        --node-port ${toString ports.remnawave.node.port} \
        --mask-port ${toString ports.remnawave.mask.entryPoint} \
        --hopping-port-start ${toString ports.remnawave.node.hopping.start} \
        ${lib.escapeShellArgs dnsArgs} \
        ${lib.escapeShellArgs nodeArgs} \
        --username ${lib.escapeShellArg user} \
        "$@"
    '';
  };

in
{
  options.services.remnawave-panel = {
    nodes = {
      basic = lib.mkOption {
        description = "Node names to register in Remnawave panel without port hopping.";
        type = lib.types.listOf lib.types.str;
        default = [ ];
        apply = lib.unique;
      };

      hopping = lib.mkOption {
        description = "Hopping node names grouped by the country routed directly.";
        type = lib.types.attrsOf (lib.types.listOf lib.types.str);
        default = { };
        apply = lib.mapAttrs (_: lib.unique);
      };
    };
  };

  config = lib.mkIf panelCfg.enable {
    environment.systemPackages = [ bootstrap ];
  };
}
