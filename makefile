#
# Nimbus
# Makefile
#

.PHONY: all clean k8s-secrets clean-k8s-secrets clean-helm

all: k8s-secrets

clean: clean-k8s-secrets clean-helm

# Template k8s secrets with env vars.
# see k8s/env for a list env vars used for secret templating
K8S_SECRET_TEMPLATES:=$(shell find k8s -name "*.tmpl" -type f)
K8S_SECRETS:=$(patsubst %.tmpl,%,$(K8S_SECRET_TEMPLATES))
k8s-secrets: $(K8S_SECRETS)

%: %.tmpl
	envsubst < $< > $@

clean-k8s-secrets: $(K8S_SECRETS)
	rm -f $+

# Remove helm charts pulled by kustomize.
# forces kustomize to pull updated helm charts which kustomize does not do by default.
clean-helm:
	find k8s -name 'charts' -type d -print0 | xargs -0 rm -rf
