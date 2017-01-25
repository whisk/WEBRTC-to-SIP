#!/bin/bash
# Generate self-signed certificates "bundle": CA (authority) private key and certificate,
# server private key, CSR (certificate signing request) and a certiticate

# How-to check certificate request:
# openssl req -in server.csr -text -noout
# How-to check certificate:
# openssl x509 -in server.crt -text -noout

CAORG="WebSIP Dev CA"
CACNAME="websip.dev"
CADAYS=3650
ORG="WebSIP Dev Server"
CNAME="*.websip.dev"
ALTNAMES="DNS:*.*.websip.dev"
CRTDAYS=3650

# CA
openssl genrsa 4096 > ca.key
openssl req -x509 -sha256 -new -nodes -key ca.key -days $CADAYS -subj "/O=$CAORG/CN=$CACNAME" -out ca.crt

# server
openssl genrsa 4096 > server.key
openssl req -new -sha256 -key server.key \
  -subj "/O=$ORG/CN=$CNAME" \
  -reqexts SAN -config <(cat openssl.cnf <(printf "[SAN]\nsubjectAltName=$ALTNAMES")) \
  -out server.csr
openssl x509 -sha256 -req -extfile <(printf "[ext]\nsubjectAltName=$ALTNAMES") -extensions ext -in server.csr \
  -CA ca.crt -CAkey ca.key -CAcreateserial -days $CRTDAYS -out server.crt

# generate pfx
openssl pkcs12 -export -inkey ca.key -in ca.crt -nokeys -password pass: -out ca.pfx
openssl pkcs12 -export -inkey server.key -in server.crt -nokeys -password pass: -out server.pfx
