# Newsletter2Feed

Get a unique email address that turns newsletters into Atom feeds.

## How it works

1. Create a feed with any title you'd like

<img src="https://github.com/user-attachments/assets/4ce624f1-6fcd-4bc5-8d8b-c8fe9b891d16" width="500" />

2. Subscribe to newsletters using the generated email address

<img src="https://github.com/user-attachments/assets/86e938bd-9b9b-4476-9cd9-3e1150f65e8c" width="500" />

3. Add the Atom feed URL to your feed reader.


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
