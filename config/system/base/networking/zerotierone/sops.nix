{
  config,
  lib,
  ...
}:
let
  enable = config.myConfig.zerotierone.enable;
  interfaces = config.myConfig.zerotierone.interfaces;

  mkSecret = name: [
    {
      name = "zerotier.interface.${name}.id";
      value = { };
    }
    {
      name = "zerotier.interface.${name}.open.udpPorts";
      value = { };
    }
    {
      name = "zerotier.interface.${name}.open.tcpPorts";
      value = { };
    }
  ];
  secretEntries = builtins.concatMap mkSecret interfaces;

  mkTemplate = name: [
    {
      name = "zerotier/${name}.env";
      value = {
        content = ''
          ZEROTIER_INTERFACE_ID=${config.sops.placeholder."zerotier.interface.${name}.id"}
          ZEROTIER_OPEN_UDP_PORTS=${config.sops.placeholder."zerotier.interface.${name}.open.udpPorts"}
          ZEROTIER_OPEN_TCP_PORTS=${config.sops.placeholder."zerotier.interface.${name}.open.tcpPorts"}
        '';
      };
    }
  ];
  templateEntries = builtins.concatMap mkTemplate interfaces;
in
{
  sops = lib.mkIf enable {
    secrets = builtins.listToAttrs secretEntries;
    templates = builtins.listToAttrs templateEntries;
  };
}
