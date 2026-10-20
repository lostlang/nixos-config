{
  config,
  lib,
  ...
}:
{
  networking = lib.mkIf config.services.remnawave-node.enable {
    firewall.extraInputRules = ''
      include "${config.sops.templates."remnawave-node-firewall.nft".path}"
    '';
  };
}
