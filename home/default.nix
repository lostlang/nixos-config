{
  lib,
  stateVersion,
  user,
  system_type,
  ...
}:
{
  imports = [
    ./base
    ./${system_type}
  ]
  ++ lib.optionals (system_type == "workstation") [ ./workstation_cli ];

  home = {
    username = user;
    homeDirectory = "/home/${user}";
    stateVersion = stateVersion;
  };
}
