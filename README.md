# AI Product Engineering

[![CI](https://github.com/Georgy213123/ai-product-engineering/actions/workflows/ci.yml/badge.svg)](https://github.com/Georgy213123/ai-product-engineering/actions/workflows/ci.yml)
[![CodeQL](https://github.com/Georgy213123/ai-product-engineering/actions/workflows/codeql.yml/badge.svg)](https://github.com/Georgy213123/ai-product-engineering/actions/workflows/codeql.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

Три продуктовых кейса. Каждый пройден целиком: постановка задачи, системный анализ,
проектирование, разработка с AI-агентами, тестирование, разбор багов и релиз.
Код рабочий, стенд каждого кейса поднимается одной командой, тесты проходят в CI.

Автор — Георгий Андреев, Product Engineer. Разрабатываю вместе с Claude Code и Codex.
Как устроена эта работа, описано в [`ai-workflow/`](ai-workflow/).

> **О происхождении кейсов.** Мои коммерческие проекты лежат у заказчиков в закрытых
> репозиториях. Кейсы ниже написаны заново: компании, данные и цифры в них вымышлены,
> внешние сервисы заменены заглушками. Задачи по типу те же, что я решаю в работе,
> и подход к ним тот же. Боевые системы могу показать на созвоне со своего экрана.

## Кейсы

| | Кейс | Задача | Что показывает | Стек |
|---|---|---|---|---|
| 01 | [**SellerDesk**](projects/01-sellerdesk/) | рабочее место оператора продавца на трёх маркетплейсах: чаты, отзывы, AI-черновики, шаблоны | интеграция с внешними API через адаптеры, фоновая синхронизация, идемпотентность, LLM без риска отправить лишнее | FastAPI · PostgreSQL · React · Playwright |
| 02 | [**ShopProbe**](projects/02-shopprobe/) | автоматическая приёмка интернет-витрины перед релизом | e2e и a11y на Playwright, перепроверка находок против ложных срабатываний, отчёт для владельца | Playwright · axe-core · FastAPI · React |
| 03 | [**OrderFlow**](projects/03-orderflow/) | мастерская мебели на заказ: заявка → конструкция → смета | системный анализ (BPMN, use case, FR/NFR, user stories), расчёт в копейках, машина состояний | FastAPI · PostgreSQL · React · Playwright |

```mermaid
flowchart LR
    P[01 Постановка] --> A[02 Анализ<br/>BPMN · use case · FR/NFR · US]
    A --> D[03 Проектирование<br/>C4 · ER · OpenAPI · ADR]
    D --> AI[04 Разработка с AI<br/>план → проверка → код → ревью]
    AI --> T[05 Тесты<br/>unit · integration · e2e]
    T --> B[06 Баги<br/>симптом → причина → фикс → регрессия]
    B --> R[07 Релизы<br/>MVP → v1 · CHANGELOG]
```

Документация во всех кейсах лежит по одному канону: [docs/CASE_STRUCTURE.md](docs/CASE_STRUCTURE.md).

## С чего начать

| Если есть 2 минуты | Если есть 15 минут |
|---|---|
| README любого кейса: задача, карта модулей, запуск | `docs/02-analysis/` кейса 03 — анализ без готового ТЗ |
| [ai-workflow/README.md](ai-workflow/README.md) — как идёт работа с агентами | `docs/04-ai-development.md` кейса 01 — настоящее ревью Codex и что по нему исправлено |
| | `docs/06-bugs.md` любого кейса — баги с регрессионными тестами |

## Запуск

```bash
cd projects/01-sellerdesk   # или 02-shopprobe, 03-orderflow
make up                     # docker compose: PostgreSQL, API, фронт
```

Без Docker: `make install && make dev` (Python 3.12 + uv, Node.js 24, PostgreSQL 16).
Проверки во всех кейсах одинаковые: `make lint`, `make test`, `make e2e`, `make audit`.

## Качество

| Что | Где |
|---|---|
| Линтеры и типы: ruff, mypy strict, ESLint, TypeScript strict, Prettier | `make lint`, CI |
| Unit и интеграционные тесты на настоящем PostgreSQL | `make test`, CI |
| E2E на Playwright, десктоп 1440×900 и телефон 390×844 | `make e2e`, CI |
| Контракт API: `openapi.yaml` сверяется с кодом тестом | `make test` |
| Аудит зависимостей (pip-audit, npm audit) | `make audit`, CI |
| Поиск секретов по всей истории (gitleaks), CodeQL, Dependabot | CI, pre-commit |
| Conventional Commits | pre-commit, CI на PR |

Последний полный прогон (чистая установка, PostgreSQL 16, переменные как в CI):

| Кейс | pytest (unit + integration) | покрытие бэкенда | Vitest | Playwright e2e |
|---|---|---|---|---|
| SellerDesk | 80 | 93 % | 14 | 12 |
| ShopProbe | 39 | — | 22 витрина + 36 ShopProbe | 32: 20 проверок ShopProbe на фикстурах, 11 витрины, 1 мета-тест с посаженными дефектами |
| OrderFlow | 82 | 97 % | 16 | 7 |

Каждый кейс прошёл независимое ревью Codex. Все находки разобраны в `docs/04-ai-development.md`
кейса: подтверждена ли находка тестом и что с ней сделано.

## Репозиторий

```
projects/        три кейса, у каждого свои README, Makefile, docker-compose, docs/01…07
ai-workflow/     CLAUDE.md, агенты, команды, skills, Playwright MCP, правила ревью
docs/            канон оформления кейса
tools/           служебные скрипты
.github/         CI, CodeQL, Dependabot, шаблоны issue и PR
```

[CONTRIBUTING.md](CONTRIBUTING.md) · [SECURITY.md](SECURITY.md) · [LICENSE](LICENSE)
