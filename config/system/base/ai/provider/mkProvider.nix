{
  name,
  provider,
}:
{
  config,
  lib,
  user,
  ...
}:
{
  options.myConfig.ai.provider.${name} = lib.mkOption {
    type = lib.types.attrs;
    default = provider;
    apply = v: lib.recursiveUpdate provider v;
  };

  config.sops = lib.mkIf config.myConfig.ai.provider.${name}.enable {
    secrets."ai.provider.${name}.apiKey".owner = user;
    templates."ai-provider.env".content = lib.mkAfter ''
      ${lib.toUpper name}_API_KEY=${config.sops.placeholder."ai.provider.${name}.apiKey"}
    '';
  };
}
