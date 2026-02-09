# Deployment

This repository contains:
- A static site in [lib](lib)
- A Dart Frog API in [api](api) that sends contact emails via Resend

## Environment variables
**Never commit secrets to source control.** Use runtime environment variables or a secrets manager.

Required:
- `RESEND_API_KEY`

Optional:
- `RESEND_FROM` (must be a sender on a verified domain in Resend)

## Local development
### API
From [api](api):
- `dart pub get`
- `dart_frog dev`

### Static site
From [lib](lib):
- `python3 -m http.server 8888`

## Production deployment (overview)
1. **Host the static site** (any static hosting service):
   - Upload contents of [lib](lib) or point your host to that folder.
2. **Host the API** (any Dart-compatible host or container runtime):
   - Run the Dart Frog server from [api](api).
   - Ensure it can reach Resend’s API.
3. **Configure environment variables** on the API host:
   - Set `RESEND_API_KEY`
   - Set `RESEND_FROM` to a verified sender
4. **Set the frontend environment**:
   - Update `window.ENVIRONMENT` or your deployment logic in [lib/script.js](lib/script.js) if you use different endpoints for dev/test/prod.

## CORS
The API includes CORS headers for `POST` and `OPTIONS`. If you change domains, ensure the frontend origin is allowed.

## Common issues
- **403 from Resend**: `RESEND_FROM` domain is not verified.
- **404 from API**: Ensure the API route exists at `/api/contact`.
- **CORS errors**: Confirm the API is reachable and CORS headers are returned.


## Production Deployment

### Website Deployment

# Background Service for App
## Compile to make it a service

    dart_frog build
    dart compile exe build/bin/server.dart -o frog_server
    sudo chmod +x /var/www/ka-ikena.tech/app/frog_server


rob@skills-ez-server:/var/www/ka-ikena.tech $ ls -al
total 24
drwxr-xr-x 6 root     root     4096 Feb  8 09:59 .
drwxr-xr-x 5 root     root     4096 Feb  4 17:05 ..
drwxr-xr-x 5 root     root     4096 Feb  8 10:19 app
drwxr-xr-x 4 www-data www-data 4096 Feb  8 11:05 html
drwxr-xr-x 9 rob      www-data 4096 Feb  5 13:57 profile
drwxr-xr-x 2 www-data www-data 4096 Feb  4 20:34 tools

## Setting up the frog server as a service

### Configuration File
Configuration File
/etc/systemd/system/kaikena.service

[Unit]
Description=Ka-Ikena Backend Service
After=network.target

[Service]
# Run as a specific user (highly recommended)
User=www-data
Group=www-data

# Set the working directory
WorkingDirectory=/var/www/ka-ikena.tech/app

# Path to your compiled executable
ExecStart=/var/www/ka-ikena.tech/app/server

# Automatically restart on crash
Restart=always
RestartSec=5

# Environment variables (optional)
Environment=RESEND_API_KEY=resend api key
Environment=RESEND_FROM="admin@ask-my-geek.net"
Environment=PORT=8088
Environment=NODE_ENV=production

[Install]
WantedBy=multi-user.target


## Starting the Service
sudo systemctl daemon-reload
sudo systemctl start kaikena.service
sudo systemctl enable kaikena.service

## Monitor Service
sudo systemctl status kaikena.service
journalctl -u kaikena.service -f

curl -X POST http://localhost:8088/api/contact \
  -H "Content-Type: application/json" \
  -d '{"name":"Jane Doe","email":"jane@example.com","message":"Hello from curl!"}'

curl -X POST http://ka-ikena.tech:8088/api/contact \
  -H "Content-Type: application/json" \
  -d '{"name":"Jane Doe","email":"jane@example.com","message":"Hello from curl!"}'

# NGINX Setup

## Configuration File


### /etc/nginx/sites-available/ka-ikena.tech

        server {
            server_name ka-ikena.tech www.ka-ikena.tech;

            root /var/www/ka-ikena.tech/html;
            index index.html;

            location / {
                try_files $uri $uri/ =404;
            }

            # proxy settings for API calls
            location /api/ {
                proxy_pass http://127.0.0.1:8088/;
                proxy_http_version 1.1;
                proxy_set_header Host $host;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header X-Forwarded-Proto $scheme;
            }

            # Optional: cache static assets
            location ~* \.(css|js|png|jpg|jpeg|gif|svg|ico|webp|woff2?)$ {
                expires 30d;
                add_header Cache-Control "public";
                try_files $uri =404;
            }

            listen 443 ssl; # managed by Certbot
            ssl_certificate /etc/letsencrypt/live/ka-ikena.tech/fullchain.pem; # managed by Certbot
            ssl_certificate_key /etc/letsencrypt/live/ka-ikena.tech/privkey.pem; # managed by Certbot
            include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
            ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot


        }

        server {
            if ($host = www.ka-ikena.tech) {
                return 301 https://$host$request_uri;
            } # managed by Certbot


            if ($host = ka-ikena.tech) {
                return 301 https://$host$request_uri;
            } # managed by Certbot


            listen 80;
            server_name ka-ikena.tech www.ka-ikena.tech;
            return 404; # managed by Certbot
        }
### /etc/nginx/sites-available/profile.ka-ikena.tech

        server {
            server_name profile.ka-ikena.tech;

            root /var/www/ka-ikena.tech/profile;
            index index.html;

            location / {
                try_files $uri $uri/ =404;
            }

            # Optional: cache static assets
            location ~* \.(css|js|png|jpg|jpeg|gif|svg|ico|webp|woff2?)$ {
                expires 30d;
                add_header Cache-Control "public";
                try_files $uri =404;
            }

            listen 443 ssl; # managed by Certbot
            ssl_certificate /etc/letsencrypt/live/ka-ikena.tech/fullchain.pem; # managed by Certbot
            ssl_certificate_key /etc/letsencrypt/live/ka-ikena.tech/privkey.pem; # managed by Certbot
            include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
            ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot
        }

        server {
            if ($host = profile.ka-ikena.tech) {
                return 301 https://$host$request_uri;
            } # managed by Certbot

            listen 80;
            server_name profile.ka-ikena.tech;
            return 404; # managed by Certbot
        }
