#!/usr/bin/env bash
# Проверка хука: какие команды он отклоняет, какие пропускает и где его предел.
set -uo pipefail
hook="$(dirname "$0")/../block-secrets.sh"
fail=0

check() { # ожидаемый код, команда
  local want=$1 cmd=$2 got
  jq -n --arg c "$cmd" '{tool_input:{command:$c}}' | bash "$hook" 2>/dev/null
  got=$?
  if [ "$got" -eq "$want" ]; then echo "ok   $want  $cmd"; else echo "FAIL want $want got $got  $cmd"; fail=1; fi
}

# Отказ: прямое чтение
check 2 'cat .env'
check 2 'python -c "print(open(\".env\").read())"'
check 2 'head -5 backend/.env.local'
check 2 'cp secrets/token.txt /tmp/'
check 2 'cat ~/.ssh/id_ed25519'
check 2 'cat ~/.ssh/id_ecdsa'
check 2 'openssl x509 -in server.pem -text'
check 2 'cat credentials.json'
# Отказ: обходы, найденные внешним аудитом
check 2 'cat .env.example .env'
check 2 'cat .e""nv'
check 2 "cat .e''nv"
check 2 'cat .[e]nv'
check 2 'cat .en?'
check 2 'cat .ENV'
check 2 'cat secrets/token.txt # .env.example'
check 2 'cat .en[v]'
# Пропуск: обычная работа
check 0 'cat .env.example'
check 0 'make lint test'
check 0 'grep -rn environment docs/'
check 0 'uv run pytest tests/unit'
check 0 "jq '.key' package.json"
check 0 'git log --oneline'

# Без jq хук отказывает, а не пропускает вслепую
got=$(echo '{}' | PATH=/nonexistent /bin/bash "$hook" 2>/dev/null; echo $?)
if [ "$got" -eq 2 ]; then echo "ok   2  (нет jq)"; else echo "FAIL нет jq: код $got"; fail=1; fi

# Предел хука (не ловится, и это записано в README): команда, собранная во время выполнения.
#   f=.e; cat ${f}nv        echo LmVudg== | base64 -d | xargs cat
# Против этого работает только отсутствие секретов в рабочей копии агента.

exit $fail
