#!/usr/bin/env bash

# create CA
if [ ! -f /keys/rootCA.key ]
then
  openssl genrsa -out /keys/rootCA.key 2048
fi

# write openssl.cnf file for ca
cat << EOF > /keys/openssl.cnf
[ req ]
default_bits        = 2048
prompt              = no
distinguished_name  = req_distinguished_name
string_mask         = utf8only
default_md          = sha256

[ req_distinguished_name ]
C=US
ST=Maryland
L=Ellicott City
O=Dev
OU=IT
CN=ca
EOF

if [ ! -f /keys/rootCA.pem ]
then
  openssl req -x509 -new -nodes -key /keys/rootCA.key -days 365 -out /keys/rootCA.pem -config <( cat /keys/openssl.cnf )
fi

# write openssl.cnf file for cert
cat << EOF > /keys/openssl.cnf
[req]
default_bits = 2048
prompt = no
default_md = sha256
distinguished_name = $DEV_COMMON_NAME

[ $DEV_COMMON_NAME ]
C=US
ST=Maryland
L=Ellicott City
O=Dev
OU=IT
CN=$DEV_COMMON_NAME
EOF

if [ ! -z "$DEV_ALT_NAMES" ]
then
  cat /keys/openssl.cnf | sed 's/distinguished_name/req_extensions = req_ext\ndistinguished_name/' > /keys/openssl.cnf.tmp
  mv /keys/openssl.cnf.tmp /keys/openssl.cnf
  echo '
[ req_ext ]
subjectAltName = @alt_names

[ alt_names ]' >> /keys/openssl.cnf

  IPCOUNT=1
  DNSCOUNT=1
  for entry in $(echo $DEV_ALT_NAMES | sed 's/,/ /g')
  do
    if echo $entry | egrep '^[0-9\.]+$' > /dev/null # just an IP
    then
      echo "IP.$IPCOUNT = $entry" >> /keys/openssl.cnf
      IPCOUNT=$(($IPCOUNT + 1))
    else
      echo "DNS.$DNSCOUNT = $entry" >> /keys/openssl.cnf
      DNSCOUNT=$(($DNSCOUNT + 1))
    fi
  done
fi

# creat client key and request
if [ ! -f /keys/haproxy.key ]
then
  openssl req -new -sha256 -nodes -out /keys/haproxy.csr -newkey rsa:2048 -keyout /keys/haproxy.key -config <( cat /keys/openssl.cnf )
fi

# generate signed cert from generated CA
if [ ! -f /keys/haproxy.crt ]
then
  openssl x509 -req -in /keys/haproxy.csr -CA /keys/rootCA.pem -CAkey /keys/rootCA.key -CAcreateserial -out /keys/haproxy.crt -days 364 -sha256 -extensions req_ext -extfile /keys/openssl.cnf
fi

# combine for haproxy config
cat /keys/haproxy.crt /keys/haproxy.key > /usr/local/etc/haproxy/haproxy.pem
chmod 600 /usr/local/etc/haproxy/haproxy.pem
