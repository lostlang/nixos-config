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
  ];

  home = {
    username = user;
    homeDirectory = "/home/${user}";
    stateVersion = stateVersion;
  };
}
