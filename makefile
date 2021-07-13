#
# nimbus
# project makefile
#

.PHONY: all clean sealed-secrets

WIREGUARD_DIR:=k8s/kustomize/wireguard
FLUENT_BIT_DIR:=k8s/kustomize/fluent-bit
ELASTIC_DIR:=k8s/kustomize/elastic-cloud

SEAL_SECRETS:=$(WIREGUARD_DIR)/wg-conf-sealed.yaml \
	$(ELASTIC_DIR)/elastic-filerealm-sealed.yaml \
	$(FLUENT_BIT_DIR)/elastic-creds-sealed.yaml

all: sealed-secrets

sealed-secrets:  $(SEAL_SECRETS)

clean:
	rm -rf $(SEAL_SECRETS)

# seal secrets to protect them from disclosure on public repo
# asymmetrically encrypts secret using cert.pem
# see logs of the sealed-secrets-controller for cert.pem (rotated every 30 days)

SEAL_CERT:=cert.pem
KUBESEAL:=kubeseal --cert $(SEAL_CERT) -o yaml

$(WIREGUARD_DIR)/wg-conf-sealed.yaml: $(WIREGUARD_DIR)/wg0.conf $(SEAL_CERT)
	kubectl create secret generic wg-conf \
		--namespace wireguard \
		--dry-run=client \
		--from-file=$< \
		--output yaml | $(KUBESEAL) >$@

$(ELASTIC_DIR)/elastic-filerealm-sealed.yaml: $(ELASTIC_DIR)/filerealm $(SEAL_CERT)
	kubectl create secret generic elastic-filerealm \
		--namespace elastic-system \
		--dry-run=client \
		--from-file=$< \
		--output yaml | $(KUBESEAL) >$@

$(FLUENT_BIT_DIR)/elastic-creds-sealed.yaml: $(FLUENT_BIT_DIR)/elastic-creds.env $(SEAL_CERT)
	kubectl create secret generic elastic-creds \
		--namespace logging \
		--dry-run=client \
		--from-env-file=$< \
		--output yaml | $(KUBESEAL) >$@
