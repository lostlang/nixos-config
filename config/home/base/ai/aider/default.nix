{
  colorScheme,
  lib,
  pkgs,
  provider,
  secret,
  ...
}:
let
  aiderw = pkgs.callPackage ./script/aiderw.nix { inherit colorScheme; };

  hasOpenrouterFree = secret.apiKey.llm.free.openrouter != "";

  hasOpenrouterPaid = secret.apiKey.llm.paid.openrouter != "";
  hasOpenaiPaid = secret.apiKey.llm.paid.openai != "";
  hasZaiPaid = secret.apiKey.llm.paid.zai != "";
in
{
  home.packages = [
    (pkgs.callPackage ./script/aiderw-ollama.nix { inherit aiderw provider; })
  ]
  ++ lib.optionals hasOpenrouterFree [
    (pkgs.callPackage ./script/aiderw-openrouter-free.nix { inherit aiderw provider secret; })
  ]
  ++ lib.optionals hasOpenrouterPaid [
    (pkgs.callPackage ./script/aiderw-openrouter-paid.nix { inherit aiderw provider secret; })
  ]
  ++ lib.optionals hasOpenaiPaid [
    (pkgs.callPackage ./script/aiderw-openai.nix { inherit aiderw provider secret; })
  ]
  ++ lib.optionals hasZaiPaid [
    (pkgs.callPackage ./script/aiderw-zai.nix { inherit aiderw provider secret; })
    (pkgs.callPackage ./script/aiderw-zai-temp.nix { })
  ];
}
