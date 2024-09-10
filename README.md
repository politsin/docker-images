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

```json
{
  "auths": {
    "https://index.docker.io/v1/": {
      "auth": "ТУТАУФ=="
    }
  }
}
```
