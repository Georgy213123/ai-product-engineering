#!/usr/bin/env bash
# PreToolUse-хук Claude Code для Bash.
# Deny-правила на Read не мешают агенту сделать `cat .env` или `python -c open(...)`.
# Хук разбирает саму команду и отклоняет обращения к секретам любым способом.
# Вход — JSON вызова инструмента на stdin, код выхода 2 = отказ с сообщением агенту.
set -euo pipefail

cmd="$(jq -r '.tool_input.command // ""')"

if grep -qiE '(^|[^a-z0-9_.-])\.env([^a-z0-9_]|$)|\.env\.(local|prod|production)|secrets/|\.pem\b|\.key\b|id_(rsa|ed25519)' <<<"$cmd" \
   && ! grep -qE '\.env\.example' <<<"$cmd"; then
  echo "Отклонено хуком: команда обращается к секретам. Нужен ключ — попроси человека." >&2
  exit 2
fi
exit 0
