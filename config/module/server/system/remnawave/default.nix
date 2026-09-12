{
  _module.args = {
    remnawave = {
      mask = {
        backend.port = 20267;
        entryPoint.port = 20268;
      };
      node = {
        port = 2222;
        hopping.port = 30173;
      };
      panel = {
        address = "172.30.0.2";
        port = 15867;
        metrics.port = 15868;
        subscription.port = 15869;
      };
      network = {
        subnet = "172.30.0.0/24";
        pool = "172.30.0.128/25";
        gateway = "172.30.0.1";
      };
    };

    remnawaveContainerCommon = {
      restart = "always";
      networks = [ "remnawave-network" ];
      ulimits.nofile = {
        soft = 1048576;
        hard = 1048576;
      };
      logging = {
        driver = "json-file";
        options = {
          max-size = "5m";
          max-file = "2";
        };
      };
    };
  };

  imports = [
    ./node
    ./panel
  ];
}
