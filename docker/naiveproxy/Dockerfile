#
# Hydra
# Naiveproxy
# Docker Container
#

ARG CADDY_VERSION=2.6.4
FROM caddy:2.8.4 AS production
# Add front page
ADD http://example.com/ /var/www/html/index.html
# Install caddy
ADD https://github.com/klzgrad/forwardproxy/releases/download/v2.6.4-caddy2-naive/caddy-forwardproxy-naive.tar.xz /tmp/caddy.txz
RUN tar -xJf /tmp/caddy.txz -C /tmp caddy-forwardproxy-naive/caddy && \
  mv /tmp/caddy-forwardproxy-naive/caddy -t /usr/local/bin
# Copy config
COPY Caddyfile /etc/caddy/Caddyfile
