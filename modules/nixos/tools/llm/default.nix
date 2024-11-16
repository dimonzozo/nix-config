{
  config,
  pkgs,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.tools.llm;
in
{
  options.${namespace}.tools.llm = with types; {
    enable = mkBoolOpt false "Whether or not to install local LLM tools.";
  };

  config = mkIf cfg.enable {

    services.ollama.enable = true;

    environment.systemPackages = with pkgs; [
      oterm # Terminal-based chat interface for OpenAI's GPT models
      # alpaca # Command-line LLM client that supports local models and various APIs (OpenAI, Anthropic, etc.)
      # nextjs-ollama-llm-ui # Web-based UI for interacting with Ollama's local LLM models
      # aichat # Command-line tool for chatting with AI models, supports multiple providers
      # tgpt # Terminal interface for ChatGPT, no API key required, uses web interface
      # smartcat # Semi-automated translation tool that leverages AI for machine translation
    ];
  };
}
