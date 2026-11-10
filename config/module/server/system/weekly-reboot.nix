{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.services.weekly-reboot.schedule = lib.mkOption {
    type = lib.types.str;
    default = "Tue *-*-* 04:00:00";
    description = "Systemd calendar expression for the weekly reboot.";
  };

  config.systemd.services.weekly-reboot = {
    description = "Weekly system reboot";

    startAt = config.services.weekly-reboot.schedule;

    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${lib.getExe' pkgs.systemd "systemctl"} --no-block reboot";
    };
  };
}
