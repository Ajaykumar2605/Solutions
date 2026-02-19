#!/bin/bash

# ============================================
# Pacemaker (pcsd) SSL Certificate Generator
# ============================================

# Auto-detect FQDN
AUTO_HOST=$(hostname -f 2>/dev/null)

if [[ "$AUTO_HOST" == *.* ]]; then
  HOSTNAME_FQDN="$AUTO_HOST"
else
  HOSTNAME_FQDN=$(hostname)
fi

VALIDITY_DAYS=365
CERT_DIR="/var/lib/pcsd"

echo "==========================================="
echo " Pacemaker (pcsd) SSL Certificate Setup"
echo " Hostname Detected: $HOSTNAME_FQDN"
echo "==========================================="

sleep 1

mkdir -p $CERT_DIR
cd $CERT_DIR || exit 1

# Backup old certs
if [ -f pcsd.crt ]; then
  mv pcsd.crt pcsd.crt.bak.$(date +%F-%H%M%S)
fi

if [ -f pcsd.key ]; then
  mv pcsd.key pcsd.key.bak.$(date +%F-%H%M%S)
fi

# Generate Private Key
openssl genrsa -out pcsd.key 4096

# Generate Self-Signed Certificate
openssl req -new -x509 -days $VALIDITY_DAYS \
  -key pcsd.key \
  -out pcsd.crt \
  -subj "/CN=${HOSTNAME_FQDN}"

# Set permissions
chmod 600 pcsd.key
chmod 644 pcsd.crt
chown root:root pcsd.*

# Restart pcsd
systemctl restart pcsd

echo "==========================================="
echo " SSL Certificate Installed Successfully"
echo " CN         : $HOSTNAME_FQDN"
echo " Valid Days : $VALIDITY_DAYS"
echo " Access UI  : https://${HOSTNAME_FQDN}:2224"
echo "==========================================="
