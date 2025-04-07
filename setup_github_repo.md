# Настройка GitHub репозитория

## 1. Создание репозитория на GitHub

1. Войдите в свой аккаунт GitHub
2. Создайте новый репозиторий с названием "n8n_personal"
3. Не инициализируйте репозиторий с README, .gitignore или лицензией

## 2. Подключение локального репозитория к GitHub

После создания репозитория на GitHub, выполните следующие команды на вашем VPS:

```bash
cd /root/temp_sync_project
git remote add origin https://github.com/YOUR_USERNAME/n8n_personal.git

# Или с использованием SSH (рекомендуется)
# git remote add origin git@github.com:YOUR_USERNAME/n8n_personal.git

# Отправка кода в GitHub
git push -u origin master
```

## 3. Настройка аутентификации

### Вариант 1: Настройка Personal Access Token (PAT)

1. На GitHub создайте новый PAT: Settings → Developer settings → Personal access tokens → Generate new token
2. Дайте токену права на работу с репозиториями (repo)
3. Скопируйте токен и сохраните на VPS:

```bash
# Настройка git для использования токена
git config --global credential.helper store
# Или для временного хранения (15 минут)
# git config --global credential.helper 'cache --timeout=900'

# При первом push git попросит имя пользователя и пароль
# Введите имя пользователя на GitHub и PAT в качестве пароля
```

### Вариант 2: Настройка SSH ключа (более безопасный метод)

```bash
# Создание SSH ключа
ssh-keygen -t ed25519 -C "github@example.com"

# Вывод публичного ключа для добавления в GitHub
cat ~/.ssh/id_ed25519.pub
```

Скопируйте вывод ключа и добавьте его в GitHub: Settings → SSH and GPG keys → New SSH key

## 4. Активация ежедневной синхронизации

Добавьте настройку crontab:

```bash
crontab -e
```

Вставьте содержимое файла crontab_setup.txt

## 5. Проверка работы скрипта

Запустите скрипт вручную для проверки:

```bash
/root/temp_sync_project/sync_to_github.sh
``` 