{
  pkgs,
  ...
}:
pkgs.writeShellScriptBin "env-rm" ''
  #!/usr/bin/env bash

  rm -f .envrc
  rm -f flake.*
  rm -rf .direnv
''
