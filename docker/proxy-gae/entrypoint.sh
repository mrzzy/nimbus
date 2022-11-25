#!/bin/sh
#
# Nimbus
# Proxy GAE
# Docker Entrypoint
#

# template nginx config from proxy spec if set
if [ -n "${PROXY_SPEC}" ]
then
  python3 template.py --output-path /etc/nginx/nginx.conf "${PROXY_SPEC}"
fi
