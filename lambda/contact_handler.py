"""Contact form handler — receives submissions from the homepage and forwards via SES."""

import json
import os
import boto3
from email.mime.text import MIMEText

SES_REGION = os.environ.get("SES_REGION", "us-east-1")
TO_EMAIL = os.environ.get("TO_EMAIL", "hello@robertmaefs.com")
FROM_EMAIL = os.environ.get("FROM_EMAIL", "noreply@robertmaefs.com")

ses = boto3.client("ses", region_name=SES_REGION)


def lambda_handler(event, context):
    # Handle CORS preflight
    if event.get("requestContext", {}).get("http", {}).get("method") == "OPTIONS":
        return cors_response(200, {"ok": True})

    try:
        body = json.loads(event.get("body", "{}"))
    except json.JSONDecodeError:
        return cors_response(400, {"error": "Invalid JSON"})

    name = body.get("name", "").strip()
    email = body.get("email", "").strip()
    message = body.get("message", "").strip()

    if not name or not email or not message:
        return cors_response(400, {"error": "Name, email, and message are required"})

    email_body = f"""
New contact form submission from robertmaefs.com:

Name:    {name}
Email:   {email}
Message:
{message}
"""

    try:
        msg = MIMEText(email_body.strip())
        msg["Subject"] = f"Contact form: {name}"
        msg["From"] = FROM_EMAIL
        msg["To"] = TO_EMAIL

        ses.send_raw_email(
            Source=FROM_EMAIL,
            Destinations=[TO_EMAIL],
            RawMessage={"Data": msg.as_string()},
        )

        return cors_response(200, {"ok": True})

    except Exception as e:
        print(f"SES error: {e}")
        return cors_response(500, {"error": "Failed to send message"})


def cors_response(status, data):
    return {
        "statusCode": status,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "https://robertmaefs.com",
            "Access-Control-Allow-Methods": "POST, OPTIONS",
            "Access-Control-Allow-Headers": "Content-Type",
        },
        "body": json.dumps(data),
    }
