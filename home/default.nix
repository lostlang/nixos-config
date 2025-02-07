{
  stateVersion,
  user,
  modules,
  ...
}:
{
  imports = [
    ./default
    ./${modules}
  ];

  home = {
    username = user;
    homeDirectory = "/home/${user}";
    stateVersion = stateVersion;
  };
}
