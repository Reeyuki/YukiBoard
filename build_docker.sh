#!/bin/bash

docker rm -f yukiboard
docker build -t reeyuki/yukiboard:latest .

docker run -d \
  --name yukiboard \
  -p 9000:8000 \
  -v /home/arch/yukiboard/data:/app/data \
  -e UID=1000 \
  -e GID=1000 \
  -e SHM_NICE_URLS=true \
  --restart always \
  reeyuki/yukiboard \
  php /app/.docker/run.php
