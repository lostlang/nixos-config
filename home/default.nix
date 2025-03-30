{
  stateVersion,
  user,
  system_type,
  ...
}:
{
  imports = [
    ./default
    ./${system_type}
  ]
	++ nixpkgs.lib.optionals (system_type == "workstation") [ ./workstation_cli ];

  home = {
    username = user;
    homeDirectory = "/home/${user}";
    stateVersion = stateVersion;
  };
}
