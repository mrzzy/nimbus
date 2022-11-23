#
# Nimbus
# Docker Container
# proxy-gae
#

FROM nginx:1.23.2-alpine

RUN mkdir -p \
  # create log dir expected by Google App Engine
  /var/log/app_engine \

# Copy nginx configuration. This sets up the behavior of nginx.
COPY nginx.conf /etc/nginx/nginx.conf

# default target URL nginx proxies to
ENV PROXY_URL=http://example.com
EXPOSE 8080
