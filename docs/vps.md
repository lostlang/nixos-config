# Instalation VPS

1. 

1.
```bash
nix run nixpkgs#nixos-anywhere -- \
    --no-disko-deps \
    --extra-files ./extra-files \
    --flake ./config#vps<HASH> \
    --generate-hardware-config nixos-generate-config \
    ./config/host/vps<HASH>/system/hardware-configuration.nix \
    --target-host root@<IP>
```

```bash
nixos-rebuild switch \
    --flake ./config#vps<HASH> \
    --target-host lostlang@<IP> \
    --use-remote-sudo
```

