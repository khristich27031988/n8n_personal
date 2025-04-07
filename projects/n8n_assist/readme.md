
# 🚀 n8n Assistant MVP — Автоматизация создания воркфлоу через LLM

> MVP-версия системы AI-ассистента на базе `n8n`, интегрированной с LLM (Gemini / Qwen) и локальной документацией. Цель — диалоговая генерация автоматизации на лету.

---

## 🔍 Общая концепция

Пользователь общается в чате → описывает задачу → агент уточняет детали → ищет релевантные отрывки в документации → обобщает и предлагает воркфлоу → подтверждённый результат записывается в базу и/или сохраняется как JSON.

---

## 🧠 Архитектура MVP

### 📍 Основные компоненты:

| Компонент                     | Назначение |
|------------------------------|------------|
| 💬 **Chat Dialog**            | Простой текстовый чат для общения с агентом |
| 🧠 **AI Agent (Gemini/Qwen)** | Диалог, уточнение, генерация инструкций |
| 📘 **Docs Search**            | Поиск по документации (`GitHub` + `HTML`) |
| 💾 **SQLite DB**              | Хранение истории диалогов и ТЗ |
| 📁 **JSON Storage**           | Генерированные воркфлоу сохраняются в `.json` файлах |

---

## 🧱 Архитектура потоков (в n8n)

1. **Trigger (Manual / Chat Input)**  
   Пользователь отправляет сообщение.

2. **Agent Router**  
   Определяет intent (запрос на создание воркфлоу или нет).

3. **AI Agent**  
   Ведёт диалог, уточняет, предлагает структуру воркфлоу.

4. **Documentation Search**  
   🔹 **GitHub Repo**: локальный путь `/root/projects/n8n_assist/docs_repo`  
   🔹 **HTML Docs**: парсинг n8n.io через HTTP Request

5. **Final Summary & Approval**  
   Предложение LLM: “Вот как я понял вашу задачу. Генерировать?”

6. **DB Record**  
   Сохраняется черновик в `workflow_drafts`.

7. **JSON Workflow Generation**  
   Генерация JSON и сохранение в:  
   `/root/projects/n8n_assist/gen_json/<имя_или_id>.json`

---

## 📂 Структура проекта на VPS

```
/root/projects/n8n_assist/
├── gen_json/                  # 💾 JSON файлы воркфлоу
│   └── 2024-04-07-telegram-airtable.json
├── docs_repo/                # 📘 GitHub-репозиторий n8n (клонированный)
│   └── packages/nodes-base/docs/
├── sqlite/                   # 💿 База данных
│   └── n8n_assist.sqlite
└── logs/, assets/, etc.      # Прочие ресурсы
```

---

## 🗃️ Структура базы данных (SQLite)

```sql
-- Таблица с черновиками задач от пользователей
CREATE TABLE workflow_drafts (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_message TEXT NOT NULL,             -- Запрос от пользователя
  ai_summary TEXT,                        -- Интерпретация задачи от AI
  documentation_sources TEXT,             -- Использованные фрагменты документации
  llm_model TEXT,                         -- Gemini / Qwen / etc
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  status TEXT DEFAULT 'finalized'         -- final/draft/error
);
```

> ⚠️ JSON-воркфлоу не хранится в базе, а сохраняется как `.json` файл на диске в `gen_json/`.

---

## 🔁 GitHub документация

- Клонируется один раз:
  ```bash
  git clone https://github.com/n8n-io/n8n.git /root/projects/n8n_assist/docs_repo
  ```

- Синхронизация 1 раз в неделю (через n8n workflow или cron):
  ```bash
  cd /root/projects/n8n_assist/docs_repo && git pull
  ```

- Документация ищется через JavaScript/File node (grep / чтение файлов).

---

## 📤 Передача данных в LLM

```json
{
  "user_prompt": "Нужен воркфлоу: взять из Airtable и отправить в Telegram",
  "ai_summary": "Получение данных → фильтрация → Telegram message",
  "doc_snippets": ["Описание Airtable node", "Пример Telegram node"],
  "model": "Gemini-Pro",
  "context": "Сформируй n8n JSON workflow (v1)"
}
```

---

## ✅ MVP = минимальное, но функциональное ядро

- ✅ Chat interface
- ✅ Поддержка моделей Gemini/Qwen
- ✅ Поиск по документации (HTML + GitHub)
- ✅ Запись диалога и ТЗ в SQLite
- ✅ Генерация JSON и сохранение на диск
- ✅ Отладка и запуск из n8n GUI

---

## ⏭️ Что дальше?

- [ ] 🧠 Векторизация документации (FAISS/Weaviate)
- [ ] 📥 Загрузка пользовательских воркфлоу
- [ ] 📎 Автоматическая вставка credentials по ID
- [ ] 🧪 UI-компоненты и превью результата
- [ ] 📤 Отправка сгенерированных воркфлоу напрямую в n8n через API

---

## 🫱 Заключение

Ты сейчас читаешь **основу всей автоматизации**, где LLM становится не просто помощником, а соавтором и архитектором no-code логики.  
Этот README — живая спецификация, и ты её автор. Вперёд, запускать, тестировать и делать магию.

С любовью и JavaScript’ом,  
`🤖 N8N Assistant by Nskha`
