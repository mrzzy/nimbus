#
# Nimbus
# Docker Container
# proxy-gae
#

FROM nginx:1.23.2-alpine

RUN mkdir -p \
  # create log dir expected by Google App Engine
  /var/log/app_engine \
  # create directory for nginx config templates
  /etc/nginx/templates

# Copy nginx configuration. This sets up the behavior of nginx.
COPY nginx.conf /etc/nginx/nginx.conf
COPY location.conf.template /etc/nginx/templates/

# default target URL nginx proxies to
ENV PROXY_URL=http://example.com
EXPOSE 8080
