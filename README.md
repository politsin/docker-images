# Docker images

https://hub.docker.com/repositories/synstd

- php
- backup
- exim
- mattermost

## Docker push

- Чтобы это само заливалось, нужно наличие файла.
  - `/root/.docker/config.json`
- Вроде этот файл сам как-то появляется командой `docker login`

```json
{
  "auths": {
    "https://index.docker.io/v1/": {
      "auth": "ТУТАУФ=="
    }
  }
}
```
