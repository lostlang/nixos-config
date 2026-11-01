{
  lib,
  hostname,
  ...
}:
{
  config = lib.mkIf (lib.hasPrefix "vps" hostname) {
    sops.secrets."vps.${hostname}.ip" = { };
  };
}
