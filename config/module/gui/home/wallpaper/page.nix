{
  lib,
  writeTextDir,
  colorScheme,
}:
let
  colorSchemeJson = lib.replaceStrings [ "<" ] [ "\\u003c" ] (builtins.toJSON colorScheme.default);
in
writeTextDir "index.html" (
  lib.replaceStrings [ "\"@colorScheme@\"" ] [ colorSchemeJson ] (builtins.readFile ./index.html)
)
