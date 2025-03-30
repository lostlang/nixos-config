{
	lib,
  system_type,
  ...
}:
{
  imports = [
    ./default
    ./${system_type}
  ]
  	++ lib.optionals (system_type == "workstation") [ ./workstation_cli ];
}
