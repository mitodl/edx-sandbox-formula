{% from "edx-sandbox/map.jinja" import edx_sandbox with context %}

test_ansible_config_placed:
  testinfra.file:
    - name: {{ edx_sandbox.conf_file }}
    - is_file: True
    - contains:
        parameter: {{ edx_sandbox.ansible_env_config.keys()[0] }}
        expected: True
        comparison: is_

{% for ext in ['key', 'crt'] %}
test_tls_{{ ext }}_file_placed:
  testinfra.file:
    - name: {{ edx_sandbox.ansible_env_config.TLS_LOCATION }}/{{ edx_sandbox.ansible_env_config.TLS_KEY_NAME }}.{{ ext }}
    - is_file: True
    - exists: True
    - user: root
    - group: root
    - mode: 384 # 0o600
{% endfor %}
