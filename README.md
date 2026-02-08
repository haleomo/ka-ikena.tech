# Ka 'Ikena

Marketing site + Dart Frog contact API for sending emails via Resend.

## Architecture
- **Frontend**: Static site in [lib](lib) with a contact form that POSTs JSON to `/api/contact`.
- **Backend**: Dart Frog API in [api](api) with a single route that validates the form payload and calls the Resend API to send the email to **admin@ask-my-geek.net**.

## Prerequisites
- Dart SDK 3.3+ installed
- A Resend account and API key

## Environment variables
Set these before starting the API server:
- `RESEND_API_KEY` (required)
- `RESEND_FROM` (optional)
  - Default: `Ka 'Ikena <noreply@ask-my-geek.net>`

Example (macOS/Linux):
- `export RESEND_API_KEY="your_key_here"`
- `export RESEND_FROM="Ka 'Ikena <noreply@ask-my-geek.net>"`

## Start the API server
From the [api](api) folder:
- `dart pub get`
- `dart_frog dev`

The API will be available at:
- `POST /api/contact`

Payload:
- `name` (string)
- `email` (string)
- `message` (string)

## Frontend integration
The contact form in [lib/index.html](lib/index.html) points to `/api/contact` via `data-api-endpoint`. The JavaScript in [lib/script.js](lib/script.js) submits the form as JSON and shows a success or error alert.

## Local development tips
If you serve the static site separately from the Dart Frog server, keep the API server running and ensure requests can reach `/api/contact`. The API includes basic CORS headers for local testing.

### Start web server
python3 -m http.server 8888

