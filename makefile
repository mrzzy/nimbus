#
# Nimbus
# Makefile
#

.PHONY: all k8s-secrets

all: k8s-secrets

# Template k8s secrets with env vars.
# see k8s/env for a list env vars used for secret templating
K8S_SECRET_TEMPLATES:=$(shell find k8s -name "*.env.tmpl" -type f)
$(info $(K8S_SECRET_TEMPLATES))
k8s-secrets: $(patsubst %.env.tmpl,%.env,$(K8S_SECRET_TEMPLATES))

%.env: %.env.tmpl
	envsubst < $< > $@
