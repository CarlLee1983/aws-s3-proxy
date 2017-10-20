FROM ubuntu:16.04
RUN apt-get update \
    && apt-get install -y \
    vim \
    wget \
    git \
    nginx \
    
    && apt-get clean \
    && apt-get autoclean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN rm -rf /etc/nginx/sites-available/default && \
    rm -rf /etc/nginx/sites-enabled/default

# Copy error page
COPY html/404.html /var/www/html/404.html
COPY html/500.html /var/www/html/500.html

# Set time zone
ENV TZ=Asia/Taipei
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Start nginx service
CMD service nginx start && tail -F /var/log/nginx/error.log

# Expos port
EXPOSE 80