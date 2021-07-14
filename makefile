#
# nimbus
# project makefile
#

.PHONY: all clean sealed-secrets

FLUENT_BIT_DIR:=k8s/kustomize/fluent-bit
ELASTIC_DIR:=k8s/kustomize/elastic-cloud

SEAL_SECRETS:=$(ELASTIC_DIR)/elastic-filerealm-sealed.yaml \
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

$(ELASTIC_DIR)/elastic-filerealm-sealed.yaml: $(ELASTIC_DIR)/filerealm $(SEAL_CERT)
	kubectl create secret generic elastic-filerealm \
		--namespace elastic-system \
		--dry-run=client \
		--from-file=$< \
		--output yaml | $(KUBESEAL) >$@

$(FLUENT_BIT_DIR)/elastic-creds-sealed.yaml: $(FLUENT_BIT_DIR)/elastic-creds.yaml $(SEAL_CERT)
	cat $< | $(KUBESEAL) >$@
