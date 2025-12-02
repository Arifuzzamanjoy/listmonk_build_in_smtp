# Listmonk Email Setup Guide

## Current Setup: Testing with Mailpit ✅

Mailpit is now running and ready for testing emails locally.

### 1️⃣ Configure Listmonk to Use Mailpit (Testing)

1. **Open listmonk**: http://your-server-ip:9000
2. **Go to Settings → SMTP**
3. **Configure as follows:**
   ```
   SMTP Host: mailpit
   SMTP Port: 1025
   Auth protocol: none
   Username: (leave empty)
   Password: (leave empty)
   TLS: Disabled
   HELO hostname: localhost
   Max connections: 10
   Max messages per connection: 100
   Idle timeout: 15s
   Wait timeout: 5s
   ```
4. **Click "Save"**

### 2️⃣ View Test Emails

- **Mailpit Web UI**: http://your-server-ip:8025
- All emails sent from listmonk will appear here
- No emails actually leave your server (perfect for testing!)

---

## Production Setup: Docker-Mailserver 🚀

For production email delivery with high inbox rates:

### Step 1: Prerequisites

You need:
- ✅ A domain name (e.g., yourdomain.com)
- ✅ A dedicated server with static IP
- ✅ Ability to set DNS records
- ✅ Ports 25, 587, 993 open

### Step 2: Download Docker-Mailserver

```bash
cd /root/Agent
git clone https://github.com/docker-mailserver/docker-mailserver
cd docker-mailserver
cp compose.yaml docker-compose.yml
cp mailserver.env.example mailserver.env
```

### Step 3: Configure Environment

Edit `mailserver.env`:
```bash
# Required settings
OVERRIDE_HOSTNAME=mail.yourdomain.com
POSTMASTER_ADDRESS=postmaster@yourdomain.com

# Enable services
ENABLE_SPAMASSASSIN=1
ENABLE_CLAMAV=1
ENABLE_FAIL2BAN=1
ENABLE_POSTGREY=1
ENABLE_AMAVIS=0
ENABLE_DNSBL=1

# Security
SSL_TYPE=letsencrypt
LETSENCRYPT_EMAIL=admin@yourdomain.com
LETSENCRYPT_HOST=mail.yourdomain.com

# DKIM
ENABLE_DKIM=1
DKIM_SELECTOR=mail

# Deliverability
ENABLE_SRS=1
ENABLE_OPENDKIM=1
ENABLE_OPENDMARC=1
ENABLE_POLICYD_SPF=1
```

### Step 4: DNS Records (CRITICAL!)

Set these DNS records for `yourdomain.com`:

```dns
# MX Record (Mail Exchange)
MX    @    mail.yourdomain.com    Priority: 10

# A Record (Points to your server IP)
A     mail    YOUR.SERVER.IP.ADDRESS

# PTR Record (Reverse DNS - ask your hosting provider)
PTR   YOUR.SERVER.IP.ADDRESS    mail.yourdomain.com

# SPF Record (Sender Policy Framework)
TXT   @    v=spf1 mx ip4:YOUR.SERVER.IP.ADDRESS -all

# DMARC Record (after DKIM setup)
TXT   _dmarc    v=DMARC1; p=quarantine; rua=mailto:dmarc@yourdomain.com; fo=1

# DKIM Record (generated after setup, see below)
TXT   mail._domainkey    v=DKIM1; k=rsa; p=YOUR_DKIM_PUBLIC_KEY
```

### Step 5: Start Docker-Mailserver

```bash
docker compose up -d
```

### Step 6: Create Email Accounts

```bash
# Setup command helper
docker exec -it mailserver setup help

# Create an email account for sending
docker exec -it mailserver setup email add noreply@yourdomain.com password123

# List accounts
docker exec -it mailserver setup email list
```

### Step 7: Get DKIM Keys

```bash
# Generate DKIM keys
docker exec -it mailserver setup config dkim

# View the public key to add to DNS
cat /root/Agent/docker-mailserver/docker-data/dms/config/opendkim/keys/yourdomain.com/mail.txt
```

Copy the DKIM public key and add it to your DNS as shown in Step 4.

### Step 8: Configure Listmonk for Production

In Listmonk Settings → SMTP:
```
SMTP Host: mail.yourdomain.com
SMTP Port: 587
Auth protocol: PLAIN
Username: noreply@yourdomain.com
Password: password123
TLS: Enabled (STARTTLS)
HELO hostname: mail.yourdomain.com
```

### Step 9: Test Email Delivery

1. Send a test campaign to a Gmail/Outlook address
2. Check inbox placement
3. Verify headers show SPF, DKIM, DMARC passing

### Step 10: Warm Up Your IP

**Critical for inbox delivery!**

```
Week 1:  50-100 emails/day
Week 2:  200-500 emails/day
Week 3:  1,000-2,000 emails/day
Week 4+: Full volume
```

---

## Monitoring & Maintenance

### Check Email Logs
```bash
docker compose logs -f mailserver
```

### Monitor Blacklists
- https://mxtoolbox.com/blacklists.aspx
- https://multirbl.valli.org/

### Test Your Setup
- https://www.mail-tester.com/ (send test email, check score)
- https://mxtoolbox.com/emailhealth/ (verify DNS)

### Bounce Handling in Listmonk
Go to Settings → Bounce Processing:
- Enable bounce processing
- Configure to check bounced emails
- Auto-unsubscribe hard bounces

---

## Troubleshooting

### Emails going to spam?
1. ✅ Verify SPF, DKIM, DMARC records
2. ✅ Check reverse DNS (PTR)
3. ✅ Warm up IP gradually
4. ✅ Monitor sender reputation
5. ✅ Clean content (avoid spam words)
6. ✅ Set up feedback loops with ISPs

### Port 25 blocked?
Some providers block port 25. Use port 587 with authentication.

### SSL Certificate Issues?
Docker-Mailserver auto-generates Let's Encrypt certificates if configured properly.

---

## Quick Commands Reference

```bash
# Start services
docker compose up -d

# Stop services
docker compose down

# View logs
docker compose logs -f

# Restart mail server
docker compose restart mailserver

# Check mail queue
docker exec -it mailserver postqueue -p

# Flush mail queue
docker exec -it mailserver postqueue -f
```

---

## Current Status

✅ **Listmonk**: Running on port 9000
✅ **PostgreSQL**: Running on port 5432
✅ **Mailpit** (Testing): Running on ports 1025 (SMTP) and 8025 (Web UI)
⏳ **Docker-Mailserver** (Production): Not yet configured

**Next Step**: Configure Mailpit in Listmonk settings to start testing campaigns!
