#
# nimbus
# project makefile
#



# seal secrets to protect them from disclosure on public repo
# asymmetrically encrypts secret using cert.pem
# see logs of the sealed-secrets-controller for cert.pem (rotated every 30 days)

SEAL_CERT=cert.pem
WIREGUARD_DIR:=k8s/kustomize/wireguard

$(WIREGUARD_DIR)/wg0-conf-sealed.yaml: $(WIREGUARD_DIR)/wg0.conf $(SEAL_CERT)
	kubectl create secret generic wg-conf \
		--namespace wireguard \
		--dry-run=client \
		--from-file=$< \
		--output yaml | kubeseal --cert $(SEAL_CERT) -o yaml >$@
