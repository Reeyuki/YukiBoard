ARG PHP_VERSION=8.4

FROM debian:trixie-slim AS base
COPY --from=mwader/static-ffmpeg:7.1 /ffmpeg /ffprobe /usr/local/bin/
RUN apt update && apt install -y --no-install-recommends \
    curl \
    supervisor \
    nginx \
    php${PHP_VERSION}-cli php${PHP_VERSION}-fpm \
    php${PHP_VERSION}-gd php${PHP_VERSION}-zip php${PHP_VERSION}-xml php${PHP_VERSION}-mbstring php${PHP_VERSION}-curl \
    php${PHP_VERSION}-pgsql php${PHP_VERSION}-mysql php${PHP_VERSION}-sqlite3 \
    php${PHP_VERSION}-memcached \
    imagemagick zip unzip librsvg2-bin git && \
    rm -rf /var/lib/apt/lists/*

FROM base AS dev-tools
RUN apt update && apt install -y --no-install-recommends \
    composer php${PHP_VERSION}-xdebug procps net-tools vim && \
    rm -rf /var/lib/apt/lists/*
ENV XDEBUG_MODE=coverage

FROM dev-tools AS build
WORKDIR /app
COPY composer.json composer.lock ./
RUN composer install --no-dev --no-progress --optimize-autoloader
COPY . .

FROM dev-tools AS devcontainer
EXPOSE 8000

FROM base AS run
EXPOSE 8000
ARG BUILD_TIME=unknown
ARG BUILD_HASH=unknown
ENV UID=1000
ENV GID=1000
ENV SHM_NICE_URLS=true
COPY --from=build /app /app
WORKDIR /app
RUN echo "define('BUILD_TIME', '$BUILD_TIME');" >> core/Config/SysConfig.php && \
    echo "define('BUILD_HASH', '$BUILD_HASH');" >> core/Config/SysConfig.php
ENTRYPOINT ["/app/.docker/entrypoint.sh"]
CMD ["php", "/app/.docker/run.php"]
