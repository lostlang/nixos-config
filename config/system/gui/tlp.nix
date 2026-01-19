{
  services.tlp = {
    enable = true;

    settings = {
      PLATFORM_PROFILE_ON_AC = "balanced";
      CPU_SCALING_GOVERNOR_ON_AC = "powersave";
      CPU_MIN_PERF_ON_AC = 0;
      CPU_MAX_PERF_ON_AC = 100;
      CPU_BOOST_ON_AC = true;
      CPU_HWP_DYN_BOOST_ON_AC = true;
      SCHED_POWERSAVE_ON_AC = false;
    };
  };
}
