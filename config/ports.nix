let
  ports = {
    adguardhome = {
      web = 43074;
      dns = 51071;
    };

    remnawave = {
      mask = {
        backend = 20267;
        entryPoint = 20268;
      };

      node = {
        port = 2222;
        hopping = {
          start = 30173;
          count = 100;
        };
      };

      panel = {
        port = 15867;
        metrics = 15868;
        subscription = 15869;
      };

      database = 5432;
    };

    vaultwarden = 43774;

    ollama = 11434;
    openWebui = 11435;

    syncthing.gui = 8384;
  };

  flatten =
    path: value:
    if builtins.isAttrs value && value ? start && value ? count then
      [
        {
          name = path;
          inherit (value) start;
          end = value.start + value.count - 1;
        }
      ]
    else if builtins.isAttrs value then
      builtins.concatLists (
        map (name: flatten (if path == "" then name else "${path}.${name}") value.${name}) (
          builtins.attrNames value
        )
      )
    else
      [
        {
          name = path;
          start = value;
          end = value;
        }
      ];

  portRanges = flatten "" ports;
  rangeCount = builtins.length portRanges;
  indexedPortRanges = builtins.genList (
    index: (builtins.elemAt portRanges index) // { inherit index; }
  ) rangeCount;
  collisions = builtins.concatLists (
    builtins.genList (
      index:
      let
        left = builtins.elemAt indexedPortRanges index;
        remaining = builtins.filter (entry: entry.index > index) indexedPortRanges;
      in
      map (right: {
        start = if left.start > right.start then left.start else right.start;
        end = if left.end < right.end then left.end else right.end;
        names = [
          left.name
          right.name
        ];
      }) (builtins.filter (right: left.start <= right.end && right.start <= left.end) remaining)
    ) rangeCount
  );
  sortedCollisions = builtins.sort (left: right: left.start < right.start) collisions;
  collisionDetails = map (
    collision:
    "${toString collision.start}${
      if collision.start == collision.end then "" else "-${toString collision.end}"
    }: ${builtins.concatStringsSep ", " collision.names}"
  ) sortedCollisions;

  errorMessage = ''
    Duplicate ports in config/ports.nix:
    ${builtins.concatStringsSep ";\n" (map (detail: "  " + detail) collisionDetails)}
  '';
in
assert collisions == [ ] || throw errorMessage;
ports
