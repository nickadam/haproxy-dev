# haproxy-dev
Docker container for testing services through simple haproxy configs.

The docker-compose.yml file is a great starting point to get up and running with
a stand-in haproxy service.

haproxy-dev assumes you want to use TLS on 443 and redirect all port HTTP
requests to HTTPS. Environment variables are used to generate a CA and sign a
cert. All keys and certs and stored in /keys. Keys will only be created if
they don't already exist in the volume.

## Environment Variables
### DEV_COMMON_NAME
The common name of the cert used by haproxy
### DEV_ALT_NAMES
Additional names or IP addresses you wish to use with the cert
### DEV_DEFAULT_BACKEND
The backend service for all requests that don't match an ACL
### DEV_SERVICE_ACLS
A comma separated list of ACLs for matching other backends. See
[HAProxy Configuration Manual](http://cbonte.github.io/haproxy-dconv/1.8/configuration.html)
for a list of possible ACLs. haproxy-dev only supports one ACL per backend.
### DEV_SERVICE_BACKENDS
A comma separated list of backends that coorelate with the ACLS.
