{
  user,
  ...
}:
{
  imports = [
    ./ollamaLocal.nix
    ./openai.nix
    ./openrouter.nix
    ./zai.nix
  ];

  sops.templates."ai-provider.env".owner = user;
}
