# AI Product Engineering

[![CI](https://github.com/Georgy213123/ai-product-engineering/actions/workflows/ci.yml/badge.svg)](https://github.com/Georgy213123/ai-product-engineering/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

Три демо-проекта и процесс, по которому они сделаны: от постановки задачи до релиза,
с рабочим кодом, автотестами и проверкой в браузере. Код генерировал ИИ (Claude Code) по моим заданиям,
второй ИИ (Codex) проверял, я ставил задачи и принимал результат: постановка, архитектурные решения (ADR),
разбор каждой ошибки, найденной при проверке.
Процесс описан в [`ai-workflow/`](ai-workflow/).

> Проекты написаны заново на вымышленных данных, внешние сервисы на заглушках.

## Проекты

| | Проект | Задача | Что показывает | CI |
|---|---|---|---|---|
| 01 | [**SellerDesk**](https://github.com/Georgy213123/sellerdesk) | рабочее место оператора продавца на трёх маркетплейсах: чаты, отзывы, AI-черновики, шаблоны | интеграция с внешними API через адаптеры, фоновая синхронизация, защита от повторной отправки, Claude API; автономный агент с чекпоинтом и бюджетом токенов | [![CI](https://github.com/Georgy213123/sellerdesk/actions/workflows/ci.yml/badge.svg)](https://github.com/Georgy213123/sellerdesk/actions/workflows/ci.yml) |
| 02 | [**ShopProbe**](https://github.com/Georgy213123/shopprobe) | автоматическая приёмка интернет-витрины перед релизом | e2e и a11y на Playwright, перепроверка находок против ложных срабатываний, отчёт для владельца; витрина на Next.js | [![CI](https://github.com/Georgy213123/shopprobe/actions/workflows/ci.yml/badge.svg)](https://github.com/Georgy213123/shopprobe/actions/workflows/ci.yml) |
| 03 | [**OrderFlow**](https://github.com/Georgy213123/orderflow) | мастерская мебели на заказ: заявка → конструкция → смета | системный анализ (BPMN, use case, FR/NFR, user stories), расчёт в копейках, машина состояний | [![CI](https://github.com/Georgy213123/orderflow/actions/workflows/ci.yml/badge.svg)](https://github.com/Georgy213123/orderflow/actions/workflows/ci.yml) |

<p>
  <a href="https://github.com/Georgy213123/sellerdesk"><img src="https://github.com/Georgy213123/sellerdesk/raw/main/docs/img/chats-desktop.png" width="32%" alt="SellerDesk: лента чатов и AI-черновик"></a>
  <a href="https://github.com/Georgy213123/shopprobe"><img src="https://github.com/Georgy213123/shopprobe/raw/main/docs/img/probe-report-desktop.png" width="32%" alt="ShopProbe: отчёт приёмки витрины"></a>
  <a href="https://github.com/Georgy213123/orderflow"><img src="https://github.com/Georgy213123/orderflow/raw/main/docs/img/intake-sources-desktop.png" width="32%" alt="OrderFlow: заявка с источниками полей"></a>
</p>

Стек общий: Python 3.12, FastAPI, SQLAlchemy 2, PostgreSQL 16, React + TypeScript (витрина ShopProbe — Next.js), Playwright,
Docker Compose, GitHub Actions. Документация в проектах по одному канону:
постановка → анализ → проектирование → разработка с AI → тесты → баги → релизы
([CASE_STRUCTURE.md](docs/CASE_STRUCTURE.md)).

## Где AI ошибался

- **Агент вписал в черновик «замечания Codex» до запуска Codex.** Заметил при приёмке
  и запустил ревью по-настоящему.
- **Тесты зелёные, код с ошибками.** Первый же круг ревью нашёл 13, 11 и 10 проблем при зелёных
  тестах, а за все круги набралось 43, 15 и 13: после перезапуска сервиса ответ покупателю падал
  с ошибкой, две одновременные правки одной заявки давали неверную смету, поздний AI-черновик
  появлялся в чужом чате. Каждую ошибку сначала подтверждал тестом, который на ней падает.
- **Исправление тоже надо ревьюить.** Фикс гонки в очереди синхронизации дал ещё 4 находки,
  одна из них — тест, который проходил и без фикса ([разбор](ai-workflow/examples/task-walkthrough.md)).
- **Автономный агент ломается там, где нет человека.** В агенте-маркетологе SellerDesk Codex
  до коммита нашёл 9 проблем, повторное ревью после (отдельная сессия Claude и Codex) — ещё 11:
  после временного отказа модели разбор ждал следующей недели, телефон, записанный через точки,
  уходил в модель без маски. Девять исправлены с тестами, два отложены
  ([круги 4 и 5](https://github.com/Georgy213123/sellerdesk/blob/main/docs/04-ai-development.md)).
- **Тесты не видят того, что видно глазами.** Просмотр скриншотов свежим агентом нашёл два
  бага интерфейса, мимо которых прошли все тесты: по одному в SellerDesk и OrderFlow.

## Запуск и проверки

```bash
git clone https://github.com/Georgy213123/sellerdesk && cd sellerdesk   # или shopprobe, orderflow
make up                       # Docker: PostgreSQL, API, фронт
make lint test e2e audit      # ruff, mypy strict, ESLint, tsc; pytest на PostgreSQL; Playwright; pip-audit, npm audit
```

В CI ещё gitleaks по всей истории, CodeQL, `docker compose up --wait` и сверка `openapi.yaml` с кодом.
Последний прогон:

| Проект | pytest | покрытие | Vitest | e2e (1440×900 и 390×844) |
|---|---|---|---|---|
| SellerDesk | 196 | 94 % | 30 | 14 |
| ShopProbe | 40 | 96 % | 23 + 49 | 37, включая мета-тест с посаженными дефектами |
| OrderFlow | 91 | 97 % | 19 | 7 |

[CONTRIBUTING.md](CONTRIBUTING.md) · [SECURITY.md](SECURITY.md) · [LICENSE](LICENSE)
