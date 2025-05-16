## Check SSL Expiration data, if SSL has expiration date less than 31 days, then an alert will be send to email and telegram
import requests
import smtplib
from email.message import EmailMessage
from datetime import datetime
from ssl import create_default_context
import os
from dotenv import load_dotenv


# Load environment variables from .env file
load_dotenv()
# Configuration
netbox_url = os.getenv('NETBOX_URL_SSL')
netbox_api_token = os.getenv('NETBOX_API_TOKEN')
bot_token = os.getenv('BOT_TOKEN')
chat_id = os.getenv('CHAT_ID')
sender_email = os.getenv('SENDER_EMAIL')
recipient_email = os.getenv('RECIPIENT_EMAIL')
sender_password = os.getenv('SENDER_PASSWORD')

smtp_server = "smtp.gmail.com"
smtp_port = "587"

# Get data from NetBox
def get_netbox_data():
    headers = {
        'Authorization': f'Token {netbox_api_token}'
    }
    response = requests.get(netbox_url, headers=headers, verify=False)
    if response.status_code == 200:
        return response.json()
    else:
        print(f"Error fetching data from NetBox: {response.status_code}")
        return None

# Check SSL expiration and notify
def check_ssl_expiration_and_notify():
    data = get_netbox_data()
    if data:
        for tenant in data['results']:
            tenant_name = tenant.get('name', 'Unknown Tenant')
            expiration_date = tenant['custom_fields'].get('Expire_Date')

            print(f"Checking SSL Expiry for {tenant_name}, Expiration Date: {expiration_date}")

            if expiration_date:
                try:
                    expiration_date_obj = datetime.strptime(expiration_date, '%Y-%m-%d')
                    days_left = (expiration_date_obj - datetime.now()).days

                    # Notify if expiration is within 30 days
                    if days_left <= 30:
                        message = f"SSL Certificate for {tenant_name} will expire in {days_left} days on {expiration_date}."
                        send_email(message, sender_email, recipient_email)
                        send_telegram_message(message)

                except ValueError as ve:
                    print(f"Date format error for {tenant_name}: {ve}")


# Send message to Telegram
def send_telegram_message(message):
    telegram_api_url = f"https://api.telegram.org/bot{bot_token}/sendMessage"
    data = {
        "chat_id": chat_id,
        "text": message
    }
    response = requests.post(telegram_api_url, data=data)
    if response.status_code == 200:
        print("Telegram message sent successfully")
    else:
        print(f"Failed to send Telegram message: {response.status_code}")

# Send email function
def send_email(message, sender_email, recipient_email):
    msg = EmailMessage()
    msg.set_content(message)
    msg["Subject"] = "SSL Certificate Expiry Alert"
    msg["From"] = sender_email
    msg["To"] = recipient_email
    try:
        with smtplib.SMTP(smtp_server, smtp_port) as server:
            server.starttls(context=create_default_context())
            server.login(sender_email, sender_password)
            server.send_message(msg)
        print("Email sent successfully")
    except Exception as e:
        print(f"Failed to send email: {e}")

# Run the expiration check
check_ssl_expiration_and_notify()