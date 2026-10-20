{
  config,
  lib,
  ...
}:
let
  inherit (config.services.zerotierone) enable interfaces;

in
{
  sops = lib.mkIf enable {
    secrets = lib.genAttrs (lib.concatMap (name: [
      "zerotier.interface.${name}.id"
      "zerotier.interface.${name}.open.udpPorts"
      "zerotier.interface.${name}.open.tcpPorts"
    ]) interfaces) (_: { });
    templates = lib.genAttrs (map (name: "zerotier/${name}.nft") interfaces) (
      templateName:
      let
        name = lib.removeSuffix ".nft" (lib.removePrefix "zerotier/" templateName);
      in
      {
        restartUnits = [ "nftables.service" ];
        content = ''
          iifname "${
            config.sops.placeholder."zerotier.interface.${name}.id"
          }" udp dport != 0 udp dport { 0, ${
            config.sops.placeholder."zerotier.interface.${name}.open.udpPorts"
          } } accept
          iifname "${
            config.sops.placeholder."zerotier.interface.${name}.id"
          }" tcp dport != 0 tcp dport { 0, ${
            config.sops.placeholder."zerotier.interface.${name}.open.tcpPorts"
          } } accept
        '';
      }
    );
  };
}
