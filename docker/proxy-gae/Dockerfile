#
# Nimbus
# Docker Container
# proxy-gae
#

FROM nginx:1.23.3-alpine

RUN mkdir -p /app \
  # create log dir expected by Google App Engine
  /var/log/app_engine
WORKDIR /app

# install python & pip modules
RUN apk add --no-cache python3=3.10.9-r1 py3-pip=22.3.1-r1
COPY requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt

# copy source code
COPY entrypoint.sh /docker-entrypoint.d/5-template-entrypoint.sh
RUN chmod u+x /docker-entrypoint.d/5-template-entrypoint.sh
COPY nginx.conf.jinja2 template.py /app/
