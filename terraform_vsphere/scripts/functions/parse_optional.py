def parse_strip(value):
    return value.strip() if value and value.strip() else None

def parse_list(value):
    return [v.strip() for v in value.split(";") if v.strip()] if value else []

def parse_ip_list(ip_string):
    return ['"%s"' % ip.strip() for ip in ip_string.split(";") if ip.strip()]