## scan with  conditions (PIC='test', status='active', Public='Yes') added within the last hour

import requests
import nmap
import os
import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.base import MIMEBase
from email import encoders
from datetime import datetime, timedelta, timezone
from pytz import timezone
import ipaddress
from dotenv import load_dotenv


# Load environment variables from .env file
load_dotenv()
#Configuration
netbox_url = os.getenv('NETBOX_URL_IP')
netbox_api_token = os.getenv('NETBOX_API_TOKEN')
bot_token = os.getenv('BOT_TOKEN')
chat_id = os.getenv('CHAT_ID')
sender_email = os.getenv('SENDER_EMAIL')
sender_password = os.getenv('SENDER_PASSWORD')
recipient_emails = os.getenv('RECIPIENT_EMAIL')
if recipient_emails:
    recipients = [email.strip() for email in recipient_emails.split(',')]
else:
    recipients = []  # Or handle the case when no recipients are provided

smtp_server = "smtp.gmail.com"
smtp_port = "587"

# Set up headers for NetBox API authentication
headers = {
    'Authorization': f'Token {netbox_api_token}',
    'Content-Type': 'application/json',
}

###scan new ip
# def fetch_ips():
#     """Fetch IP addresses from NetBox that were added within the last hour, with PIC='test', IP status='active', and Public='Yes'."""
#     ip_addresses = []
#     url = netbox_url

#     # Get the current time and calculate the time one hour ago
#     current_time = datetime.now()
#     one_hour_ago = current_time - timedelta(hours=3)

#     # Format the time in ISO 8601 for querying NetBox
#     time_filter = one_hour_ago.isoformat()

#     # Modify the URL to filter by created time
#     url += f'?created__gte={time_filter}'

#     while url:
#         response = requests.get(url, headers=headers, verify=False)
#         if response.status_code == 200:
#             for ip_data in response.json()['results']:
#                 # Check conditions for custom fields and status
#                 if (ip_data['custom_fields'].get('PIC') == 'test' and
#                     ip_data['status']['label'].lower() == 'active'):
#                     ip_address = ip_data['address'].split('/')[0]  # Extract IP address without subnet
#                     ip_addresses.append(ip_address)

#             url = response.json().get('next')  # Pagination for next batch
#         else:
#             print(f"Failed to fetch data: {response.status_code}")
#             break

#     return ip_addresses

###Scan all
def fetch_ips():
    """Fetch IP addresses from NetBox, filtering by Pic == 'test'."""
    ip_addresses = []
    url = netbox_url

    while url:
        response = requests.get(url, headers=headers, verify=False)
        if response.status_code == 200:
            for ip_data in response.json()['results']:
                ip_address = ip_data['address'].split('/')[0]  # Extract IP address
                pic = ip_data.get('custom_fields', {}).get('PIC', None)  # Get the 'Pic' attribute

                if pic == "test":  # Only add IPs where 'Pic' is 'test'
                    ip_addresses.append(ip_address)

            url = response.json().get('next')  # Pagination for next batch
        else:
            print(f"Failed to fetch data: {response.status_code}")
            break

    return ip_addresses

def scan_ips(ips, output_file):
    """Scan IPs for open ports and write results to a file if there are open ports."""
    nm = nmap.PortScanner()
    with open(output_file, 'w') as f:
        for ip in ips:
            try:
                # Validate IP
                ipaddress.ip_address(ip)
            except ValueError:
                print(f"{ip}: Invalid IP format")
                continue
            
            print(f"Scanning {ip}...")
            nm.scan(ip, arguments='-p 1-100')

            # Check if the IP is in the scan result
            if ip not in nm.all_hosts():
                print(f"{ip}: No scan results returned")
                continue

            # Now safely access the host info
            host_info = nm[ip]
            print(f"Nmap scan results for {ip}: {host_info}")

            if host_info.state() == "up":
                open_ports = [port for port in host_info.get('tcp', {}) if host_info['tcp'][port]['state'] == 'open']
                if open_ports:  # Only write to the file if there are open ports
                    f.write(f"{ip}: {', '.join(map(str, open_ports))}\n")
                    print(f"{ip}: {', '.join(map(str, open_ports))}")
            else:
                print(f"{ip}: Host is down")

def send_email(filename):
    """Send the result file as an email attachment."""
    # Create the email
    msg = MIMEMultipart()
    msg['From'] = sender_email
    msg['To'] = ", ".join(recipients)
    msg['Subject'] = 'Nmap Scan Results'

    body = 'Please find the attached Nmap scan results.'
    msg.attach(MIMEText(body, 'plain'))

    # Attach the file
    with open(filename, 'rb') as attachment:
        part = MIMEBase('application', 'octet-stream')
        part.set_payload(attachment.read())
        encoders.encode_base64(part)
        part.add_header('Content-Disposition', f'attachment; filename={os.path.basename(filename)}')
        msg.attach(part)

    # Send the email
    with smtplib.SMTP(smtp_server, smtp_port) as server:
        server.starttls()  # Secure the connection
        server.login(sender_email, sender_password)  # Login to your email account
        server.send_message(msg)

if __name__ == '__main__':
    # Fetch IPs that were added within the last hour and meet the filtering conditions
    ips = fetch_ips()

    if ips:  # Proceed only if there are new IPs to scan
        execute_date = datetime.now(timezone('Asia/Ho_Chi_Minh')).strftime('%Y%m%d_%H%M%S')
        report_folder = f"/netbox/report_{execute_date}"
        os.makedirs(report_folder, exist_ok=True)
        output_file = os.path.join(report_folder, f"nmap_results_{execute_date}.txt")

        with open(output_file, 'w') as f:
            f.write("Nmap scan results will be written here.\n")  # Example content
            f.write("\n".join(ips))

        scan_ips(ips, output_file)  # Scan the fetched IPs
        send_email(output_file)  # Send the result file via email
    else:
        print("No new IPs matching the conditions (Status='active', Public='Yes'). Skipping scan.")