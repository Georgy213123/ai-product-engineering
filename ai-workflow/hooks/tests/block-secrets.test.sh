#!/usr/bin/env bash
# Проверка хука: какие команды он должен отклонять, а какие пропускать.
set -uo pipefail
hook="$(dirname "$0")/../block-secrets.sh"
fail=0

check() { # ожидаемый код, команда
  local want=$1 cmd=$2 got
  jq -n --arg c "$cmd" '{tool_input:{command:$c}}' | bash "$hook" 2>/dev/null
  got=$?
  if [ "$got" -eq "$want" ]; then echo "ok   $want  $cmd"; else echo "FAIL want $want got $got  $cmd"; fail=1; fi
}

check 2 'cat .env'
check 2 'python -c "print(open(\".env\").read())"'
check 2 'head -5 backend/.env.local'
check 2 'cp secrets/token.txt /tmp/'
check 2 'cat ~/.ssh/id_ed25519'
check 2 'openssl x509 -in server.pem -text'
check 0 'cat .env.example'
check 0 'make lint test'
check 0 'grep -rn environment docs/'
check 0 'uv run pytest tests/unit'

exit $fail
