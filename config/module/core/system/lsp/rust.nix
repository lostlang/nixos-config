{
  lib,
  pkgs,
  makeSandbox,
  user,
}:
let
  cargoHome = "/home/${user}/.cargo";
  sandboxDirectory = "/home/${user}/.cache/sandbox/rust-analyzer";
in
makeSandbox {
  inherit user sandboxDirectory;
  name = "rust-analyzer-sandbox";
  executable = lib.getExe pkgs.rust-analyzer-unwrapped;
  shareNetwork = true;
  runtimeInputs = with pkgs; [
    cargo
    rustc
    gcc
    protobuf
  ];

  hostEnvPassthrough = [ ];
  directories = [
    cargoHome
    "${sandboxDirectory}/home/${user}/.config/rust-analyzer"
    "${sandboxDirectory}/target"
  ];
  binds = [
    {
      source = cargoHome;
      target = cargoHome;
    }
  ];
  environment = {
    CARGO_HOME = cargoHome;
    CARGO_TARGET_DIR = "/target";
    SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
    SSL_CERT_DIR = "${pkgs.cacert}/etc/ssl/certs";
  };
}
