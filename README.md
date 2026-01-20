# Newsletter2Feed

Get a unique email address that turns newsletters into Atom feeds.

## How it works

1. Create a feed with any title you'd like
2. Subscribe to newsletters using the generated email address
3. Add the Atom feed URL to your feed reader.

<img src="https://github.com/user-attachments/assets/8ad0e59f-c138-4ec5-bd0a-64f9c41fe335" width="500" />

<hr>

<img src="https://github.com/user-attachments/assets/35524a2f-979b-474f-bf68-26aed5c1a646" width="500" />

## Deployment

Use Docker Compose:

```yaml
services:
  web:
    build: .
    ports:
      - "80:80"
      - "443:443"
    environment:
      # Random 128+ char hex string (`openssl rand -hex 64`)
      - SECRET_KEY_BASE=${SECRET_KEY_BASE}

      # Background process/housekeeping
      - SOLID_QUEUE_IN_PUMA=true

      # Your domain (e.g., `newsletter2feed.example.com`)
      - APP_HOSTNAME=${APP_HOSTNAME}

      # Same as `APP_HOSTNAME` to enable automatic HTTPS via Let's Encrypt
      - TLS_DOMAIN=${APP_HOSTNAME}

      # From Mailgun dashboard: Settings → Security & Users → API security
      - MAILGUN_INGRESS_SIGNING_KEY=${MAILGUN_INGRESS_SIGNING_KEY}
    volumes:
      - storage:/rails/storage
    restart: unless-stopped

volumes:
  storage:
```

### Mailgun setup

1. Add your domain in Mailgun (Sending → Domains)
2. Configure inbound webhook to forward emails to:
   ```
   https://<APP_HOSTNAME>/rails/action_mailbox/mailgun/inbound_emails/mime
   ```
3. Create a catch-all route to forward all incoming emails to the webhook
