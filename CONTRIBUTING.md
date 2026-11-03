# Как вносить изменения

Репозиторий ведётся так же, как рабочий: каждое изменение проходит одну дорогу.

## Порядок

1. **Issue.** Что сломано или что нужно, критерий готовности. Шаблоны — в `.github/ISSUE_TEMPLATE/`.
2. **Ветка** от `main`: `feat/<кратко>`, `fix/<кратко>`, `docs/<кратко>`.
3. **План.** Для задачи больше часа: план в описании PR до кода (см. [`ai-workflow/`](ai-workflow/)).
4. **Код + тесты.** Изменение поведения без теста не принимается. Баг: сначала падающий тест, потом фикс.
5. **Локальные проверки** в папке проекта: `make lint test e2e`.
6. **PR** по шаблону, CI зелёный, ревью. Слияние squash-ом.

## Коммиты — Conventional Commits

```
<тип>(<область>): <что сделано, в повелительном наклонении>
```

Типы: `feat`, `fix`, `docs`, `test`, `refactor`, `perf`, `build`, `ci`, `chore`.
Область — проект (`sellerdesk`, `shopprobe`, `orderflow`) или `repo`, `ci`, `ai-workflow`.

```
feat(sellerdesk): черновик ответа сохраняется, если переменная шаблона не подставилась
fix(orderflow): считать смету в копейках, а не во float
test(shopprobe): регрессия на ленивую загрузку картинок
```

Формат проверяет хук `conventional-pre-commit`.

## Настройка окружения

```bash
uv tool install pre-commit
pre-commit install && pre-commit install --hook-type commit-msg
```

Нужны: Python 3.12 и [uv](https://docs.astral.sh/uv/), Node.js 24, Docker с Compose v2.

## Стиль

- Python: ruff (lint + format), mypy strict. Длина строки 100.
- TypeScript: strict, ESLint + Prettier.
- Отступы и переводы строк — `.editorconfig`.
- Документация по-русски, код и идентификаторы по-английски.
