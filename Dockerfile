ARG PHP_VERSION=7.0.8

FROM php:${PHP_VERSION}-fpm-alpine AS memory_issues

# persistent / runtime deps
RUN apk add --no-cache \
		acl \
		file \
		gettext \
		git \
	;

ARG APCU_VERSION=5.1.12
RUN set -eux; \
	apk add --no-cache --virtual .build-deps \
		$PHPIZE_DEPS \
		icu-dev \
		mysql-dev \
		zlib-dev \
		zip \
	; \
	\
	docker-php-ext-configure zip; \
	docker-php-ext-install \
		intl \
		pdo_mysql \
		zip \
		bcmath \
		json \
		sockets \
		ftp \
	; \
	pecl install \
		apcu-${APCU_VERSION} \
	; \
	pecl clear-cache; \
	docker-php-ext-enable \
		apcu \
		opcache \
	; \
	\
	runDeps="$( \
		scanelf --needed --nobanner --format '%n#p' --recursive /usr/local/lib/php/extensions \
			| tr ',' '\n' \
			| sort -u \
			| awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
	)"; \
	apk add --no-cache --virtual .api-phpexts-rundeps $runDeps; \
	\
	apk del .build-deps

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

ENV COMPOSER_ALLOW_SUPERUSER=1
ENV PATH="${PATH}:/root/.composer/vendor/bin"

WORKDIR /srv/app

RUN apk add --no-cache ca-certificates
RUN update-ca-certificates

COPY . ./

RUN composer install --prefer-dist --no-progress --no-suggest; \
	composer clear-cache

WORKDIR /srv/app

CMD ["php-fpm"]
