{
  _module.args = {
    remnawave = {
      panel = {
        address = "172.30.0.2";
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
    };
  };

  imports = [
    ./node
    ./panel
  ];
}
