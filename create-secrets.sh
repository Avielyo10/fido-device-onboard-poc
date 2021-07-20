#!/bin/bash

mkdir -vp keys
# manufacturer key & cert
openssl ecparam -name prime256v1 -genkey -out keys/manufacturer_key.der -outform der
openssl req -x509 -key keys/manufacturer_key.der -keyform der -out keys/manufacturer_cert.pem -days 365 -subj "/C=US/O=RHEL for Edge/CN=FIDO Manufacturer"
# device key & cert
openssl ecparam -name prime256v1 -genkey -out keys/device_ca_key.der -outform der
openssl req -x509 -key keys/device_ca_key.der -keyform der -out keys/device_ca_cert.pem -days 365 -subj "/C=US/O=RHEL for Edge/CN=Device"
# owner key & cert
openssl ecparam -name prime256v1 -genkey -out keys/owner_key.der -outform der
openssl req -x509 -key keys/owner_key.der -keyform der -out keys/owner_cert.pem -days 365 -subj "/C=US/O=RHEL for Edge/CN=Owner"
# reseller key & cert
openssl ecparam -name prime256v1 -genkey -out keys/reseller_key.der -outform der
openssl req -x509 -key keys/reseller_key.der -keyform der -out keys/reseller_cert.pem -days 365 -subj "/C=US/O=RHEL for Edge/CN=Reseller"