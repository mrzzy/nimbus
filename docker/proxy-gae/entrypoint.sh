#!/bin/sh
#
# Nimbus
# Proxy GAE
# Docker Entrypoint
#

# template nginx config
if [ -n "${HOSTNAME}" -a -n "${PROXY_SPEC}" ]
then
  python3 template.py --output-path /etc/nginx/nginx.conf "${HOSTNAME}" "${PROXY_SPEC}"
fi
