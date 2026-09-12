{
  pkgs,
  ...
}:
pkgs.writeShellScriptBin "get-openrouter-models" ''
  set -euo pipefail

  URL="https://openrouter.ai/api/v1/models"

  ${pkgs.curl}/bin/curl -fsSL "$URL" | ${pkgs.jq}/bin/jq -r '
    [
      .data[]
      | select(.id | test(":free$"))
      | select(.context_length >= 100000)
      | select(.supported_parameters | index("tools"))
      | select(.supported_parameters | index("structured_outputs"))
      | select(.top_provider.is_moderated == false)
      | select(.expiration_date == null)
      | {
          name: .id,
          max_input_tokens: (.context_length - 1),
          max_output_tokens: ((.top_provider.max_completion_tokens // .context_length) - 1),
          input_price: (.pricing.prompt // 0),
          output_price: (.pricing.completion // 0)
        }
    ]
    | sort_by(-.max_input_tokens)
    | map(
        "  { name = \"\(.name)\"; max_input_tokens = \(.max_input_tokens); max_output_tokens = \(.max_output_tokens); input_price = \(.input_price); output_price = \(.output_price); }"
      )
    | "[\n" + (join("\n")) + "\n];"
  '
''
