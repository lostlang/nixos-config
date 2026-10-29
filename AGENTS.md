Before creating or modifying scripts or their Nix wrappers, read and follow [script/AGENTS.md](script/AGENTS.md).
Its Python and Nix rules also apply to script wrappers under `config/`. Keep application logic in `script/` and pass configuration and executable paths from Nix through named arguments.
