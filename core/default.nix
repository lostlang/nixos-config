{
  system_type,
  ...
}:
{
  imports = [
    ./default
    ./${system_type}
  ];
}
