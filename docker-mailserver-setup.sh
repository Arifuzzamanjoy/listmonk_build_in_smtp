#!/bin/bash
# Docker-Mailserver Quick Setup Script
# Run this after you have a domain name ready

set -e

echo "🚀 Docker-Mailserver Setup for Listmonk"
echo "========================================"
echo ""

# Check if domain is provided
if [ -z "$1" ]; then
    echo "Usage: bash docker-mailserver-setup.sh yourdomain.com"
    echo "Example: bash docker-mailserver-setup.sh example.com"
    exit 1
fi

DOMAIN=$1
MAIL_SUBDOMAIN="mail.$DOMAIN"
POSTMASTER="postmaster@$DOMAIN"

echo "📧 Setting up mail server for: $DOMAIN"
echo "Mail hostname: $MAIL_SUBDOMAIN"
echo ""

# Create directory
cd /root/Agent
if [ ! -d "docker-mailserver" ]; then
    echo "📥 Cloning docker-mailserver repository..."
    git clone https://github.com/docker-mailserver/docker-mailserver.git
fi

cd docker-mailserver

# Download compose file if not exists
if [ ! -f "compose.yaml" ]; then
    echo "📥 Downloading compose file..."
    wget https://raw.githubusercontent.com/docker-mailserver/docker-mailserver/master/compose.yaml
fi

# Copy and configure environment file
echo "⚙️  Configuring mailserver.env..."
if [ ! -f "mailserver.env" ]; then
    if [ -f "../listmonk/mailserver.env" ]; then
        cp ../listmonk/mailserver.env .
    else
        wget https://raw.githubusercontent.com/docker-mailserver/docker-mailserver/master/mailserver.env
    fi
fi

# Configure key settings
cat > mailserver.env << EOF
# Generated for $DOMAIN

# Hostname
OVERRIDE_HOSTNAME=$MAIL_SUBDOMAIN
POSTMASTER_ADDRESS=$POSTMASTER

# Enable security features
ENABLE_SPAMASSASSIN=1
ENABLE_CLAMAV=0
ENABLE_FAIL2BAN=1
ENABLE_POSTGREY=1

# SSL/TLS
SSL_TYPE=letsencrypt
LETSENCRYPT_HOST=$MAIL_SUBDOMAIN
LETSENCRYPT_EMAIL=$POSTMASTER

# DKIM/DMARC/SPF
ENABLE_DKIM=1
DKIM_SELECTOR=mail
ENABLE_OPENDKIM=1
ENABLE_OPENDMARC=1
ENABLE_POLICYD_SPF=1

# Other
ENABLE_SRS=1
PERMIT_DOCKER=network
SPOOF_PROTECTION=1
EOF

echo "✅ Configuration complete!"
echo ""
echo "⚠️  BEFORE starting the mail server:"
echo ""
echo "1️⃣  Add these DNS records for $DOMAIN:"
echo "────────────────────────────────────────"
echo "Record Type | Name  | Value"
echo "────────────────────────────────────────"
echo "A           | mail  | $(curl -s ifconfig.me)"
echo "MX          | @     | $MAIL_SUBDOMAIN (Priority: 10)"
echo "TXT (SPF)   | @     | v=spf1 mx ip4:$(curl -s ifconfig.me) -all"
echo "TXT (DMARC) | _dmarc| v=DMARC1; p=quarantine; rua=mailto:$POSTMASTER"
echo ""
echo "2️⃣  Set up Reverse DNS (PTR) with your hosting provider:"
echo "   $(curl -s ifconfig.me) → $MAIL_SUBDOMAIN"
echo ""
echo "3️⃣  Ensure ports are open: 25, 587, 993"
echo ""
echo "📝 After DNS is configured, run:"
echo "   cd /root/Agent/docker-mailserver"
echo "   docker compose up -d"
echo ""
echo "🔑 Create email account:"
echo "   docker exec -it mailserver setup email add noreply@$DOMAIN"
echo ""
echo "🔐 Get DKIM key (add to DNS after starting):"
echo "   docker exec -it mailserver setup config dkim"
echo "   cat docker-data/dms/config/opendkim/keys/$DOMAIN/mail.txt"
echo ""
echo "✅ Then configure Listmonk SMTP:"
echo "   Host: $MAIL_SUBDOMAIN"
echo "   Port: 587"
echo "   Username: noreply@$DOMAIN"
echo "   TLS: STARTTLS"
EOF

chmod +x /root/Agent/docker-mailserver-setup.sh

echo "✅ Setup script created!"
echo ""
