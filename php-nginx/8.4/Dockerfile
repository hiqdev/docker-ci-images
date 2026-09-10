FROM hiqdev/php:8.4-fpm-alpine

# Nginx comes straight from Alpine's own repos, so its version tracks whatever
# the base image's Alpine release ships. This avoids pinning to an exact
# nginx.org mainline build, which gets dropped from that repo's index once
# newer versions are published and breaks the build (see NGINX_VERSION churn
# in git history before this file).
RUN apk add --no-cache \
        nginx \
        gettext-envsubst \
        tzdata \
        curl \
        ca-certificates \
    && rm -rf /etc/nginx/http.d \
    && mkdir /etc/nginx/conf.d \
# forward request and error logs to docker log collector
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

COPY nginx.conf /etc/nginx/nginx.conf

WORKDIR /app
EXPOSE "80"
STOPSIGNAL SIGQUIT

COPY ci-docker-entrypoint /usr/local/bin
ENTRYPOINT ["ci-docker-entrypoint"]
