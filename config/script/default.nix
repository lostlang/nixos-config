{
  pkgs,
  ...
}:
{
  environment.systemPackages = [
    (pkgs.callPackage ./env_init.nix { })
    (pkgs.callPackage ./minecraft_data_copy.nix { })
    (pkgs.callPackage ./steam_clip_builder.nix { })
  ];
}
