{
  pkgs,
  ...
}:
let
  fmt-staged = pkgs.writeShellApplication {
    name = "fmt-staged";
    runtimeInputs = [
      pkgs.git
      pkgs.nix
    ];

    text = ''
      mapfile -d $'\0' -t staged_files < <(git diff --cached --name-only --diff-filter=d -z)

      if [[ "''${#staged_files[@]}" -eq 0 ]]; then
        exit 0
      fi

      nix fmt "''${staged_files[@]}"
    '';
  };
in
{
  environment.systemPackages = [ fmt-staged ];
}
