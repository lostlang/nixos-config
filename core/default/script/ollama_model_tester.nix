{ pkgs, ... }:
pkgs.writeShellScriptBin "ollama-model-tester" ''
  #!/usr/bin/env bash

  if [ -z "$1" ]; then
    echo "Использование: $0 <название_модели>"
    exit 1
  fi

  model="$1"
  prompt='Write simple python script tcp client and server, use only std libs.'


  response=$(curl -s http://localhost:11434/api/generate -d "{
    \"model\": \"$model\",
    \"prompt\": \"$prompt\",
    \"stream\": false
  }")

  eval_count=$(echo "$response" | ${pkgs.jq}/bin/jq -r '.eval_count')
  eval_duration=$(echo "$response" | ${pkgs.jq}/bin/jq -r '.eval_duration')

  if [ "$eval_count" = "null" ] || [ "$eval_duration" = "null" ]; then
    echo "Ошибка: ответ от Ollama некорректен или пуст"
    exit 1
  fi

  tps=$(echo "scale=2; $eval_count / ($eval_duration / 1000000000)" |  ${pkgs.bc}/bin/bc)

  echo "Модель: $model"
  echo "Prompt: \"$prompt\""
  echo "Сгенерировано токенов: $eval_count"
  echo "Время генерации: $eval_duration наносекунд"
  echo "Скорость: $tps токенов в секунду"

''
