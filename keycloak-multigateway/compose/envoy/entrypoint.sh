#!/bin/sh

sed -e "s/\${SERVICE_NAME}/${SERVICE_NAME}/" -e "s/\${SERVICE_HOST}/${SERVICE_HOST}/" -e "s/\${SERVICE_PORT}/${SERVICE_PORT}/" -e "s/\${OPA_HOST}/${OPA_HOST}/" /config/envoy.yaml > /etc/envoy.yaml

/usr/local/bin/envoy -c /etc/envoy.yaml -l ${DEBUG_LEVEL}
