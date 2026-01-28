{
  pkgs,
  ...
}:
{
  environment.systemPackages = [
    (pkgs.callPackage ./clean_script.nix { })
    (pkgs.callPackage ./env_init.nix { })
    (pkgs.callPackage ./env_rm.nix { })
    (pkgs.callPackage ./minecraft_data_copy.nix { })
    (pkgs.callPackage ./steam_clip_builder.nix { })
  ];
}
