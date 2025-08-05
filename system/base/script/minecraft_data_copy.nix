{ pkgs, ... }:
pkgs.writeShellScriptBin "minecraft-data-copy" ''
  #!/usr/bin/env bash

  if [ -z "$1" ]; then
    echo "❌ Использование: $0 /путь/к/minecraft_серверу"
    exit 1
  fi

  SERVER_DIR="$1"

  ITEMS=(
    "world"
    "eula.txt"
    "ops.json"
    "server.properties"
    "usercache.json"
    "usernamecache.json"
  )

  for item in ''${ITEMS[@]}; do
    src="$SERVER_DIR/$item"
    if [ -e "$src" ]; then
      cp -r "$src" "."
      echo "Скопировано: $item"
    else
      echo "Пропущено (не найдено): $item"
    fi
  done

  echo "Копирование завершено."
''
