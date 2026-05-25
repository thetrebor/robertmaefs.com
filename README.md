# robertmaefs.com

Personal consulting website — hosted on S3 + CloudFront with a contact form backend via API Gateway + Lambda + SES.

## Structure

```
├── index.html           Homepage
├── css/style.css        Styles
├── lambda/
│   ├── contact_handler.py   Contact form Lambda
│   └── api-template.yaml    CloudFormation for API backend
├── deploy.sh            Deploy script
└── README.md
```

## Deploy

```bash
./deploy.sh
```

Requires AWS CLI with appropriate credentials.

## Contact form

The contact form POSTs to `https://api.robertmaefs.com/contact` which triggers a Lambda that forwards the message via SES.

**One-time setup:** Verify the SES sending address:
```bash
aws ses verify-email-identity --email-address hello@robertmaefs.com
```
Then click the verification link sent to that inbox.

## Domain

- `robertmaefs.com` — homepage (CloudFront via S3)
- `app.robertmaefs.com` — privacy policy, EULA (CloudFront via S3)
- `api.robertmaefs.com` — contact form API (API Gateway)
- `oauth.robertmaefs.com` — QuickBooks OAuth callback (Cloudflare Tunnel)
