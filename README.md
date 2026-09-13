# Docker images

https://hub.docker.com/repositories/synstd

- php
- backup
- exim
- mattermost

## Docker push

- Чтобы это само заливалось, нужно наличие файла.
  - `/root/.docker/config.json`
- Вроде этот файл сам появляется командой `docker login --username=synstd`

## PHP CodeSniffer

В образах `synstd/php` PHP CodeSniffer по умолчанию использует
`/var/lib/composer/phpcs.xml`. Из набора `Drupal.Commenting` отключены правила
оформления PHPDoc и описаний типов/свойств/параметров: они не должны
переписывать комментарии PHPStan. Оставлены включёнными:

- `Drupal.Commenting.Deprecated`;
- `Drupal.Commenting.PostStatementComment`;
- `Drupal.Commenting.TodoComment`.

Остальные правила Drupal и PHP CodeSniffer продолжают работать как обычно.

```json
{
  "auths": {
    "https://index.docker.io/v1/": {
      "auth": "ТУТАУФ=="
    }
  }
}
```
