{
  pkgs,
  ...
}:
pkgs.writeShellScriptBin "resolution-switch" ''
  #!/usr/bin/env bash
  set -euo pipefail

''
