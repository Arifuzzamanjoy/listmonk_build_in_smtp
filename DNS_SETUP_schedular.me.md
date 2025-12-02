# DNS Configuration for schedular.me Mail Server

## ⚠️ IMPORTANT: Configure These DNS Records FIRST

Go to your domain registrar (where you bought schedular.me) and add these DNS records:

### 1. A Record (Points mail subdomain to server)
```
Type: A
Name: mail
Value: 134.199.230.98
TTL: 3600 (or default)
```

### 2. MX Record (Mail Exchange)
```
Type: MX
Name: @ (or root/blank)
Value: mail.schedular.me
Priority: 10
TTL: 3600
```

### 3. SPF Record (Sender Policy Framework)
```
Type: TXT
Name: @ (or root/blank)
Value: v=spf1 mx ip4:134.199.230.98 -all
TTL: 3600
```

### 4. DMARC Record (Email Authentication)
```
Type: TXT
Name: _dmarc
Value: v=DMARC1; p=quarantine; rua=mailto:postmaster@schedular.me
TTL: 3600
```

### 5. Reverse DNS (PTR) - Contact Your Hosting Provider
Ask your hosting provider to set:
```
134.199.230.98 → mail.schedular.me
```

---

## After DNS is Configured (wait 5-30 minutes for propagation)

### Step 1: Verify DNS
```bash
# Check A record
dig mail.schedular.me +short

# Check MX record
dig schedular.me MX +short

# Check SPF
dig schedular.me TXT +short | grep spf
```

### Step 2: Start Mail Server
```bash
cd /root/Agent/docker-mailserver
docker compose up -d
```

### Step 3: Wait for startup (2-3 minutes)
```bash
docker compose logs -f mailserver
# Press Ctrl+C when you see "mail.schedular.me is up and running"
```

### Step 4: Create Email Account
```bash
docker exec -it mailserver setup email add noreply@schedular.me
# Enter password when prompted (e.g., SecurePass123!)
```

### Step 5: Generate and Get DKIM Key
```bash
docker exec -it mailserver setup config dkim
sleep 5
cat /root/Agent/docker-mailserver/docker-data/dms/config/opendkim/keys/schedular.me/mail.txt
```

### Step 6: Add DKIM to DNS
Copy the output from Step 5 and add this DNS record:
```
Type: TXT
Name: mail._domainkey
Value: (paste the v=DKIM1; k=rsa; p=... string)
TTL: 3600
```

### Step 7: Configure Listmonk
In Listmonk Settings → SMTP:
```
Host: mail.schedular.me
Port: 587
Auth protocol: PLAIN
Username: noreply@schedular.me
Password: (the password from Step 4)
TLS: STARTTLS
HELO hostname: mail.schedular.me
```

### Step 8: Test Email Delivery
Send a test campaign to your personal Gmail/Outlook to verify!

---

## Quick Commands Reference

```bash
# Check mail server status
cd /root/Agent/docker-mailserver
docker compose ps

# View logs
docker compose logs -f mailserver

# Create additional email accounts
docker exec -it mailserver setup email add marketing@schedular.me

# List all accounts
docker exec -it mailserver setup email list

# Check mail queue
docker exec -it mailserver postqueue -p

# Restart mail server
docker compose restart mailserver
```

---

## Troubleshooting

### DNS not propagating?
Wait 30-60 minutes or use Cloudflare DNS (faster propagation)

### Port 25 blocked?
Contact your hosting provider to unblock it

### Emails going to spam?
1. Verify all DNS records are correct
2. Check mail-tester.com (send test email)
3. Warm up IP gradually (50-100 emails/day for first week)

---

## Current Status:
✅ Docker-Mailserver configured for schedular.me
⏳ Waiting for DNS records to be added
⏳ Waiting to start mail server

**Next:** Add the DNS records above, then follow the steps!
