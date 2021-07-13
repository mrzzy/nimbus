#
# nimbus
# project makefile
#

.PHONY: all sealed-secrets elastic-filerealm-secrets

all: sealed-secrets

# seal secrets to protect them from disclosure on public repo
# asymmetrically encrypts secret using cert.pem
# see logs of the sealed-secrets-controller for cert.pem (rotated every 30 days)

WIREGUARD_DIR:=k8s/kustomize/wireguard
FLUENT_BIT_DIR:=k8s/kustomize/fluent-bit
ELASTIC_DIR:=k8s/kustomize/elastic-cloud

SEAL_CERT=cert.pem

sealed-secrets: $(WIREGUARD_DIR)/wg0-conf-sealed.yaml\
	$(ELASTIC_DIR)/elastic-filerealm-sealed.yaml \
	$(FLUENT_BIT_DIR)/elastic-creds-sealed.yaml

WG_SECRET:=wg-conf

$(WIREGUARD_DIR)/$(WG_SECRET)-sealed.yaml: $(WIREGUARD_DIR)/wg0.conf $(SEAL_CERT)
	kubectl create secret generic $(WG_SECRET)
		--namespace wireguard \
		--dry-run=client \
		--from-file=$< \
		--output yaml | kubeseal --cert $(SEAL_CERT) -o yaml >$@


elastic-secrets: $(ELASTIC_DIR)/elastic-filerealm-sealed.yaml \
	$(FLUENT_BIT_DIR)/elastic-creds-sealed.yaml

$(ELASTIC_DIR)/elastic-filerealm-sealed.yaml: $(ELASTIC_DIR)/filerealm $(SEAL_CERT)
	kubectl create secret generic elastic-filerealm \
		--namespace elastic-system \
		--dry-run=client \
		--from-file=$< \
		--output yaml | kubeseal --cert $(SEAL_CERT) -o yaml >$@

#$(FLUENT_BIT_DIR)/elastic-creds-sealed.yaml: $(SEAL_CERT)
#	kubectl create secret generic elastic-creds \
#		--namespace logging \
#		--dry-run=client \
#		--from-file=$<
#		--output yaml | kubeseal --cert $(SEAL_CERT) -o yaml >$@
