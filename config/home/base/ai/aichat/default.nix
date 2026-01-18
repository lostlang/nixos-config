{
  lib,
  provider,
  secret,
  ...
}:
let
  hasOpenrouterFree = secret.apiKey.llm.free.openrouter != "";

  hasOpenrouterPaid = secret.apiKey.llm.paid.openrouter != "";
  hasOpenaiPaid = secret.apiKey.llm.paid.openai != "";
  hasZaiPaid = secret.apiKey.llm.paid.zai != "";
in
{
  programs.aichat = {
    enable = true;

    settings = {
      model =
        if hasZaiPaid then
          "zai-paid:${provider.zai.model.default}"
        else if hasOpenrouterFree then
          "openrouter-free:${provider.openrouterFree.model.default}"
        else
          "ollama-local:${provider.ollamaLocal.model.default}";

      rag_top_k = 20;

      clients = [
        {
          name = "ollama-local";
          type = "openai-compatible";
          api_base = provider.ollamaLocal.api_base;
          models = provider.ollamaLocal.model.embedding ++ provider.ollamaLocal.model.chat;
        }
      ]
      ++ lib.optional hasOpenrouterFree {
        name = "openrouter-free";
        type = "openai-compatible";
        api_base = provider.openrouterFree.api_base;
        api_key = secret.apiKey.llm.free.openrouter;
        models = provider.openrouterFree.model.embedding ++ provider.openrouterFree.model.chat;
      }
      ++ lib.optional hasOpenrouterPaid {
        name = "openrouter-paid";
        type = "openai-compatible";
        api_base = provider.openrouterPaid.api_base;
        api_key = secret.apiKey.llm.paid.openrouter;
        models = provider.openrouterPaid.model.embedding ++ provider.openrouterPaid.model.chat;
      }
      ++ lib.optional hasOpenaiPaid {
        name = "openai-paid";
        type = "openai-compatible";
        api_base = provider.openai.api_base;
        api_key = secret.apiKey.llm.paid.openai;
        models = provider.openai.model.embedding ++ provider.openai.model.chat;
      }
      ++ lib.optional hasZaiPaid {
        name = "zai-paid";
        type = "openai-compatible";
        api_base = provider.zai.api_base;
        api_key = secret.apiKey.llm.paid.zai;
        models = provider.zai.model.embedding ++ provider.zai.model.chat;
      };
    };
  };
}
