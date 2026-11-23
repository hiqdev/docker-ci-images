FROM hiqdev/php:8.0-fpm-alpine

ENV NGINX_VERSION=1.30.7
ENV NGINX_SHA256=2565b5c837050e958f70fb0f73c48e2bca4542ad349fd356f46fb0c72610bc6e

RUN set -x \
    && addgroup -S nginx \
    && adduser -S -D -H -h /var/cache/nginx -s /sbin/nologin -G nginx -g nginx nginx \
    && apk add --no-cache --virtual .nginx-build-deps \
        gcc \
        libc-dev \
        make \
        openssl-dev \
        pcre2-dev \
        zlib-dev \
        linux-headers \
    && curl -fsSL -o /tmp/nginx.tar.gz "https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz" \
    && echo "${NGINX_SHA256}  /tmp/nginx.tar.gz" | sha256sum -c - \
    && tar -xzf /tmp/nginx.tar.gz -C /tmp \
    && cd "/tmp/nginx-${NGINX_VERSION}" \
    && ./configure \
        --prefix=/etc/nginx \
        --sbin-path=/usr/sbin/nginx \
        --modules-path=/usr/lib/nginx/modules \
        --conf-path=/etc/nginx/nginx.conf \
        --error-log-path=/var/log/nginx/error.log \
        --http-log-path=/var/log/nginx/access.log \
        --pid-path=/var/run/nginx.pid \
        --lock-path=/var/run/nginx.lock \
        --http-client-body-temp-path=/var/cache/nginx/client_temp \
        --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
        --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
        --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
        --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
        --user=nginx \
        --group=nginx \
        --with-compat \
        --with-file-aio \
        --with-threads \
        --with-http_ssl_module \
        --with-http_v2_module \
        --with-http_realip_module \
        --with-http_gzip_static_module \
        --with-http_stub_status_module \
    && make -j"$(nproc)" \
    && make install \
    && cd / \
    && rm -rf /tmp/nginx.tar.gz "/tmp/nginx-${NGINX_VERSION}" /etc/nginx/html \
    && mkdir -p /var/cache/nginx /etc/nginx/conf.d /docker-entrypoint.d \
    && runDeps="$( \
        scanelf --needed --nobanner /usr/sbin/nginx \
            | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
            | sort -u \
            | xargs -r apk info --installed \
            | sort -u \
    )" \
    && apk add --no-cache --virtual .nginx-run-deps $runDeps \
    && apk del .nginx-build-deps \
    && apk add --no-cache \
        gettext \
        tzdata \
        curl \
        ca-certificates \
# forward request and error logs to docker log collector
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

COPY nginx.conf /etc/nginx/nginx.conf

WORKDIR /app
EXPOSE "80"
STOPSIGNAL SIGQUIT

COPY ci-docker-entrypoint /usr/local/bin
ENTRYPOINT ["ci-docker-entrypoint"]
