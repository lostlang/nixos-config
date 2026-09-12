{
  config,
  lib,
  pkgs,
  user,
  ...
}:
let
  hosts = config.myConfig.ssh.vpsHosts;

  rebuild-vps = pkgs.writeShellApplication {
    name = "rebuild-vps";
    runtimeInputs = [ pkgs.fzf ];

    text = ''
      hosts=(${lib.escapeShellArgs hosts})

      host="$(
        printf '%s\n' "all" "''${hosts[@]}" \
          | fzf \
            --height='~50%' \
            --reverse \
            --prompt='Select a VPS to update: ' \
          || true
      )"

      [[ -n "$host" ]] || exit 0

      config_dir="/home/${user}/.config/nixos/config"

      if [[ "$host" == "all" ]]; then
        selected_hosts=("''${hosts[@]}")
      else
        selected_hosts=("$host")
      fi

      for selected_host in "''${selected_hosts[@]}"; do
        nixos-rebuild switch \
          --flake "$config_dir#$selected_host" \
          --target-host "$selected_host" \
          --elevate=sudo
      done
    '';
  };
in
{
  environment.systemPackages = lib.mkIf (hosts != [ ]) [ rebuild-vps ];
}
