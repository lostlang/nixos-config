{
  secretPath,
  ...
}:
let
  secret = "${secretPath}/secret.yaml";
  key = "${secretPath}/key";
in
{
  sops = {
    validateSopsFiles = false;
    defaultSopsFile = secret;
    age.keyFile = key;
  };
}
