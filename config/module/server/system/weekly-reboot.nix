{
  lib,
  pkgs,
  ...
}:
{
  systemd.services.weekly-reboot = {
    description = "Weekly system reboot";

    startAt = "Tue *-*-* 04:00:00";

    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${lib.getExe' pkgs.systemd "systemctl"} --no-block reboot";
    };
  };
}
