{
  services.journald.settings.Journal = {
    SystemMaxUse = "10M";
    RuntimeMaxUse = "10M";
    MaxRetentionSec = "7day";
  };
}
