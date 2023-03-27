#
# Nimbus
# Makefile
#

.PHONY: all clean k8s-secrets clean-k8s-secrets

all: k8s-secrets

clean: clean-k8s-secrets

# Template k8s secrets with env vars.
# see k8s/env for a list env vars used for secret templating
K8S_SECRET_TEMPLATES:=$(shell find k8s -name "*.env.tmpl" -type f)
K8S_SECRETS:=$(patsubst %.env.tmpl,%.env,$(K8S_SECRET_TEMPLATES))
k8s-secrets: $(K8S_SECRETS)

%.env: %.env.tmpl
	envsubst < $< > $@

clean-k8s-secrets: $(K8S_SECRETS)
	rm -f $+
