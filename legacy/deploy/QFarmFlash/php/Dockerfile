FROM php:5.6-fpm

# Stretch 已 archive + GPG key 过期：必须显式 trusted=yes 跳过签名验证
RUN echo 'deb [trusted=yes] http://archive.debian.org/debian stretch main' > /etc/apt/sources.list && \
    echo 'deb [trusted=yes] http://archive.debian.org/debian-security stretch/updates main' >> /etc/apt/sources.list && \
    echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99no-check-valid

RUN apt-get update && apt-get install -y --no-install-recommends \
        libpng-dev libjpeg62-turbo-dev libfreetype6-dev libxml2-dev && \
    docker-php-ext-configure gd \
        --with-freetype-dir=/usr/include/ \
        --with-jpeg-dir=/usr/include/ \
        --with-png-dir=/usr/include/ && \
    docker-php-ext-install -j"$(nproc)" mysql mysqli pdo_mysql gd mbstring xmlrpc && \
    rm -rf /var/lib/apt/lists/*

# short_open_tag 是宿主安装器硬要求；时区影响农场收获时间
RUN { echo 'short_open_tag=On'; \
      echo 'date.timezone=Asia/Shanghai'; \
      echo 'upload_max_filesize=10M'; \
      echo 'post_max_size=12M'; \
      echo 'max_execution_time=60'; \
      echo 'display_errors=Off'; \
      echo 'memory_limit=128M'; \
    } > /usr/local/etc/php/conf.d/qqfarm.ini

# 关键：worker 也必须是 root（默认 www-data 写不了 host 用户拥有的挂载文件）
RUN sed -i -e 's/^user = .*/user = root/' \
           -e 's/^group = .*/group = root/' /usr/local/etc/php-fpm.d/www.conf

USER root
CMD ["php-fpm", "--allow-to-run-as-root"]
