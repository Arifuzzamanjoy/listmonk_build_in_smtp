# Listmonk Email Marketing System - Complete Ecosystem

## 📊 System Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         YOUR SERVER (134.199.230.98)                     │
│                                                                           │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                    Docker Compose Network                        │   │
│  │                                                                   │   │
│  │  ┌──────────────────┐      ┌──────────────────┐                │   │
│  │  │   PostgreSQL     │      │   Mailpit        │                │   │
│  │  │   (Database)     │      │ (Testing SMTP)   │                │   │
│  │  │                  │      │                  │                │   │
│  │  │  Port: 5432      │      │  SMTP: 1025     │                │   │
│  │  │  User: listmonk  │      │  Web:  8025     │                │   │
│  │  └────────┬─────────┘      └────────┬─────────┘                │   │
│  │           │                          │                          │   │
│  │           │                          │                          │   │
│  │  ┌────────▼──────────────────────────▼─────────┐               │   │
│  │  │          Listmonk Application               │               │   │
│  │  │        (Newsletter Manager)                 │               │   │
│  │  │                                             │               │   │
│  │  │  - Campaign Management                      │               │   │
│  │  │  - Subscriber Management                    │               │   │
│  │  │  - Template Editor                          │               │   │
│  │  │  - Analytics & Tracking                     │               │   │
│  │  │                                             │               │   │
│  │  │  Port: 9000 (Web Interface)                │               │   │
│  │  └─────────────────────────────────────────────┘               │   │
│  │                         │                                       │   │
│  └─────────────────────────┼───────────────────────────────────────┘   │
│                            │                                            │
│                            │ SMTP Connection                            │
│                            ▼                                            │
│                  ┌─────────────────┐                                   │
│                  │ SMTP Server     │                                   │
│                  │ (Choose One)    │                                   │
│                  └────────┬────────┘                                   │
│                           │                                             │
└───────────────────────────┼─────────────────────────────────────────────┘
                            │
                            │
        ┌───────────────────┼────────────────────┐
        │                   │                    │
        ▼                   ▼                    ▼
   ┌─────────┐      ┌──────────────┐    ┌──────────────┐
   │ Mailpit │      │ Gmail SMTP   │    │   Docker     │
   │(Testing)│      │ (Quick Start)│    │ Mailserver   │
   └─────────┘      └──────────────┘    │ (Production) │
        │                   │            └──────────────┘
        │                   │                    │
        ▼                   ▼                    ▼
   ┌─────────┐      ┌──────────────┐    ┌──────────────┐
   │  Local  │      │   Gmail      │    │  Internet    │
   │ Testing │      │   Servers    │    │ Mail Servers │
   │Interface│      │              │    │              │
   │Port:8025│      │ smtp.gmail   │    │ Gmail,Outlook│
   └─────────┘      │    .com      │    │ Yahoo, etc   │
                    └──────────────┘    └──────────────┘
```

---

## 🔄 Email Sending Flow

### Testing Flow (Current Setup)
```
User Creates Campaign in Listmonk
         │
         ▼
Listmonk connects to Mailpit (localhost:1025)
         │
         ▼
Mailpit captures email (doesn't send)
         │
         ▼
View email in Mailpit Web UI (http://134.199.230.98:8025)
         │
         ▼
✅ Test without sending real emails
```

### Production Flow (After Setup)
```
User Creates Campaign in Listmonk
         │
         ▼
Listmonk connects to Docker-Mailserver (mail.schedular.me:587)
         │
         ▼
Docker-Mailserver processes email
         │
         ├─ Adds DKIM Signature
         ├─ Checks SPF/DMARC
         ├─ Applies Anti-spam filters
         └─ Encrypts with TLS
         │
         ▼
Sends to recipient's mail server (Gmail, Outlook, etc.)
         │
         ▼
Email arrives in recipient's inbox
         │
         ▼
Listmonk tracks opens, clicks, bounces
```

---

## 🏗️ Component Details

### 1. Listmonk (Newsletter Manager)
```
┌─────────────────────────────────────────┐
│          Listmonk Core Features         │
├─────────────────────────────────────────┤
│ ✅ Campaign Management                  │
│ ✅ Subscriber Lists & Segmentation      │
│ ✅ Email Templates (Visual Editor)      │
│ ✅ Personalization & Variables          │
│ ✅ Analytics & Click Tracking           │
│ ✅ Bounce Handling                      │
│ ✅ Multi-user Support with Roles        │
│ ✅ REST API                             │
│ ✅ Webhooks                             │
│ ✅ Import/Export CSV                    │
└─────────────────────────────────────────┘

Access: http://134.199.230.98:9000
Database: PostgreSQL (listmonk)
Config: Via Web UI & Environment Variables
```

### 2. PostgreSQL Database
```
┌─────────────────────────────────────────┐
│          PostgreSQL Storage             │
├─────────────────────────────────────────┤
│ 📦 Subscribers Data                     │
│ 📦 Campaign History                     │
│ 📦 Email Templates                      │
│ 📦 Analytics & Metrics                  │
│ 📦 User Accounts & Permissions          │
│ 📦 Lists & Segmentation Rules           │
└─────────────────────────────────────────┘

Port: 5432 (Internal)
Volume: listmonk_listmonk-data
Backup: Via docker volume snapshots
```

### 3. SMTP Options

#### Option A: Mailpit (Testing) ✅ Currently Active
```
┌─────────────────────────────────────────┐
│              Mailpit                    │
├─────────────────────────────────────────┤
│ Purpose: Local email testing            │
│ SMTP Port: 1025                         │
│ Web UI: 8025                            │
│ Cost: FREE                              │
│ Emails: Captured, not sent              │
│ Best For: Development & Testing         │
└─────────────────────────────────────────┘

Web UI: http://134.199.230.98:8025
Config: No authentication required
```

#### Option B: Gmail SMTP (Quick Start)
```
┌─────────────────────────────────────────┐
│            Gmail SMTP                   │
├─────────────────────────────────────────┤
│ Host: smtp.gmail.com                    │
│ Port: 587                               │
│ Auth: PLAIN                             │
│ TLS: STARTTLS                           │
│ Limit: 500 emails/day                   │
│ Cost: FREE                              │
│ Setup Time: 5 minutes                   │
│ Best For: Small newsletters             │
└─────────────────────────────────────────┘

Required: Gmail account + App Password
Deliverability: Good (using Gmail's reputation)
```

#### Option C: Docker-Mailserver (Production) ⭐ Recommended
```
┌─────────────────────────────────────────┐
│        Docker-Mailserver                │
│      (mail.schedular.me)                │
├─────────────────────────────────────────┤
│ Components:                             │
│  • Postfix (SMTP Server)                │
│  • Dovecot (IMAP Server)                │
│  • Rspamd (Spam Filter)                 │
│  • ClamAV (Antivirus)                   │
│  • Fail2ban (Security)                  │
│  • Let's Encrypt (SSL)                  │
├─────────────────────────────────────────┤
│ Port 25:   SMTP (Receiving)             │
│ Port 587:  Submission (Sending)         │
│ Port 993:  IMAPS                        │
│ Cost: FREE (self-hosted)                │
│ Limit: Unlimited                        │
│ Setup Time: 1-2 hours                   │
│ Best For: High volume, full control     │
└─────────────────────────────────────────┘

Domain: schedular.me
Mail Host: mail.schedular.me
IP: 134.199.230.98
Status: ⏳ Pending DNS configuration
```

---

## 🌐 DNS Configuration for schedular.me

```
┌──────────────────────────────────────────────────────────────┐
│             DNS Records for Mail Server                       │
├──────────────────────────────────────────────────────────────┤
│                                                               │
│  A Record (Mail Subdomain)                                   │
│  ┌────────────────────────────────────────────────────┐     │
│  │ mail.schedular.me → 134.199.230.98                │     │
│  └────────────────────────────────────────────────────┘     │
│                                                               │
│  MX Record (Mail Exchange)                                   │
│  ┌────────────────────────────────────────────────────┐     │
│  │ schedular.me → mail.schedular.me (Priority: 10)   │     │
│  └────────────────────────────────────────────────────┘     │
│                                                               │
│  SPF Record (Sender Policy Framework)                        │
│  ┌────────────────────────────────────────────────────┐     │
│  │ TXT: v=spf1 mx ip4:134.199.230.98 -all           │     │
│  └────────────────────────────────────────────────────┘     │
│                                                               │
│  DKIM Record (DomainKeys Identified Mail)                    │
│  ┌────────────────────────────────────────────────────┐     │
│  │ mail._domainkey.schedular.me                      │     │
│  │ TXT: v=DKIM1; k=rsa; p=[PUBLIC_KEY]              │     │
│  └────────────────────────────────────────────────────┘     │
│                                                               │
│  DMARC Record (Authentication Policy)                        │
│  ┌────────────────────────────────────────────────────┐     │
│  │ _dmarc.schedular.me                               │     │
│  │ TXT: v=DMARC1; p=quarantine; rua=mailto:...      │     │
│  └────────────────────────────────────────────────────┘     │
│                                                               │
│  PTR Record (Reverse DNS) - Set by Hosting Provider          │
│  ┌────────────────────────────────────────────────────┐     │
│  │ 134.199.230.98 → mail.schedular.me                │     │
│  └────────────────────────────────────────────────────┘     │
│                                                               │
└──────────────────────────────────────────────────────────────┘
```

---

## 📧 Email Authentication Stack

```
                    Inbox Delivery Success
                           ⬆
                           │
        ┌──────────────────┼──────────────────┐
        │                  │                  │
    ┌───▼───┐         ┌────▼────┐       ┌────▼────┐
    │  SPF  │         │  DKIM   │       │  DMARC  │
    └───┬───┘         └────┬────┘       └────┬────┘
        │                  │                  │
        ▼                  ▼                  ▼
   Verifies IP      Signs Message      Policy Check
   is authorized    with private       Pass = Inbox
   to send email    key (proves        Fail = Spam
                    authenticity)       /Quarantine
```

### How It Works:
1. **SPF** - "Is this server allowed to send email for schedular.me?"
2. **DKIM** - "Is this email really from schedular.me? (signature check)"
3. **DMARC** - "What should I do if SPF/DKIM fail?"

All 3 ✅ = High inbox rate (95-99%)

---

## 🔐 Security Layers

```
┌──────────────────────────────────────────────┐
│         Security & Protection Stack          │
├──────────────────────────────────────────────┤
│                                              │
│  Layer 1: Network Security                   │
│  ├─ Firewall (Ports 25, 587, 993)           │
│  └─ Fail2ban (Brute force protection)       │
│                                              │
│  Layer 2: Connection Security                │
│  ├─ TLS/SSL Encryption (Let's Encrypt)      │
│  └─ STARTTLS on port 587                    │
│                                              │
│  Layer 3: Authentication                     │
│  ├─ SMTP Authentication Required            │
│  └─ Strong passwords enforced               │
│                                              │
│  Layer 4: Email Validation                   │
│  ├─ SPF Checking                            │
│  ├─ DKIM Signing/Verification               │
│  └─ DMARC Policy Enforcement                │
│                                              │
│  Layer 5: Content Filtering                  │
│  ├─ Rspamd (Spam filtering)                 │
│  ├─ ClamAV (Virus scanning)                 │
│  └─ Content policy rules                    │
│                                              │
└──────────────────────────────────────────────┘
```

---

## 📊 Monitoring & Analytics

### Listmonk Analytics Dashboard
```
┌────────────────────────────────────────┐
│       Campaign Performance             │
├────────────────────────────────────────┤
│  📊 Sent:        10,000                │
│  ✅ Delivered:   9,850 (98.5%)         │
│  📧 Opened:      4,925 (50%)           │
│  🔗 Clicked:     1,970 (20%)           │
│  ⚠️  Bounced:     150 (1.5%)           │
│  🚫 Unsubscribed: 25 (0.25%)          │
└────────────────────────────────────────┘
```

### Email Server Monitoring
```
┌────────────────────────────────────────┐
│       Server Health Checks             │
├────────────────────────────────────────┤
│  ✅ DNS Records (SPF/DKIM/DMARC)       │
│  ✅ Blacklist Status (multirbl.org)    │
│  ✅ SSL Certificate Validity           │
│  ✅ Disk Space & Memory                │
│  ✅ Mail Queue Status                  │
│  ✅ Service Uptime                     │
└────────────────────────────────────────┘
```

---

## 🚀 Deployment Options Comparison

| Feature | Mailpit | Gmail SMTP | Docker-Mailserver |
|---------|---------|------------|-------------------|
| **Cost** | FREE | FREE | FREE |
| **Setup Time** | 5 min | 5 min | 1-2 hours |
| **Email Limit** | ∞ (local only) | 500/day | Unlimited |
| **Real Delivery** | ❌ No | ✅ Yes | ✅ Yes |
| **Domain Required** | ❌ No | ❌ No | ✅ Yes |
| **DNS Setup** | ❌ No | ❌ No | ✅ Yes |
| **Inbox Rate** | N/A | 95%+ | 90-99% |
| **IP Warmup** | N/A | Not needed | ✅ Required |
| **Maintenance** | None | None | Monthly |
| **Control Level** | Full | Limited | Full |
| **Best For** | Testing | Quick start | Production |

---

## 📋 Quick Command Reference

### Listmonk Management
```bash
# View logs
docker compose logs -f app

# Restart listmonk
docker compose restart app

# Backup database
docker exec listmonk_db pg_dump -U listmonk listmonk > backup.sql
```

### Mailpit (Testing)
```bash
# View Mailpit logs
docker compose logs -f mailpit

# Access web interface
http://134.199.230.98:8025
```

### Docker-Mailserver (Production)
```bash
# Start mail server
cd /root/Agent/docker-mailserver
docker compose up -d

# Create email account
docker exec -it mailserver setup email add user@schedular.me

# Check logs
docker compose logs -f mailserver

# Check mail queue
docker exec -it mailserver postqueue -p

# Get DKIM key
cat docker-data/dms/config/opendkim/keys/schedular.me/mail.txt

# Test email sending
echo "Test" | mail -s "Subject" test@gmail.com
```

---

## 🎯 Current Status Summary

```
┌────────────────────────────────────────────────────────┐
│              CURRENT SYSTEM STATUS                      │
├────────────────────────────────────────────────────────┤
│                                                         │
│  ✅ Listmonk:        Running (Port 9000)               │
│  ✅ PostgreSQL:      Running (Healthy)                 │
│  ✅ Mailpit:         Running (Testing mode)            │
│  ⏳ Docker-Mailserver: Configured, awaiting DNS        │
│                                                         │
│  Domain: schedular.me                                  │
│  Mail Server: mail.schedular.me                        │
│  IP Address: 134.199.230.98                            │
│                                                         │
│  Next Steps:                                           │
│  1. Add DNS records for schedular.me                   │
│  2. Configure reverse DNS (PTR)                        │
│  3. Start Docker-Mailserver                            │
│  4. Create email account                               │
│  5. Configure Listmonk SMTP settings                   │
│  6. Test email delivery                                │
│  7. Start IP warmup process                            │
│                                                         │
└────────────────────────────────────────────────────────┘
```

---

## 📚 Related Documentation Files

- `/root/Agent/listmonk/SETUP_GUIDE.md` - Complete setup guide
- `/root/Agent/DNS_SETUP_schedular.me.md` - DNS configuration details
- `/root/Agent/docker-mailserver-setup.sh` - Automation script
- `/root/Agent/listmonk/docker-compose.yml` - Current compose config

---

## 🔗 Useful Links

- **Listmonk Docs**: https://listmonk.app/docs
- **Docker-Mailserver**: https://docker-mailserver.github.io
- **Mail Tester**: https://www.mail-tester.com (test spam score)
- **MX Toolbox**: https://mxtoolbox.com (check DNS & blacklists)
- **DMARC Analyzer**: https://www.dmarcanalyzer.com

---

*Last Updated: December 2, 2025*
*System: Ubuntu Server @ 134.199.230.98*
*Domain: schedular.me*
