#!/bin/bash
set -ex
#
# nimbus
# helper script for quickly sealing wireguard server config as a secret
#

kubectl create secret generic wg-config-secret \
    --namespace wireguard \
    --dry-run=client \
    --from-file=wg0.conf \
    -output yaml | kubeseal --cert cert.pem -o yaml >config-secret.yaml
