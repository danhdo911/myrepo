### Fix Horizon may display "Something went wrong!" when a memcached node becomes unavailable.
SESSION_ENGINE = 'django.contrib.sessions.backends.cache'

CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.memcached.PyMemcacheCache',
        'LOCATION': [
            {% for host in groups['memcached'] %}
            '{{ 'api' | kolla_address(host) | put_address_in_context('url') }}:{{ memcached_port }}'
            {% if not loop.last %},{% endif %}
            {% endfor %}
        ],
        'OPTIONS': {
            'allow_unicode_keys': True,
            'default_noreply': False,
            'ignore_exc': True,
            'timeout': 2.0,
            'connect_timeout': 1.0,
            'no_delay': True,
            'retry_attempts': 2,
            'retry_timeout': 3.0,
            'dead_timeout': 10
        }
    }
}

SESSION_COOKIE_SECURE = True
CSRF_COOKIE_SECURE = True

### ENABLE HORIZON MFA
