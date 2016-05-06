{% from "edx-sandbox/map.jinja" import edx_sandbox with context %}

# Do some simple filesystem checks that will certainly fail if edX wasn't deployed.

{%
set fs_validation = {
  'edxapp_env': {'type': 'file', 'loc': '/edx/app/edxapp/edxapp_env'},
  'nginx_sites': {'type': 'directory', 'loc': '/edx/app/nginx/sites-available'},
  'supervisor_bin': {'type': 'file', 'loc': '/edx/bin/supervisorctl'},
  'edxapp_manage_bin': {'type': 'symlink', 'loc': '/edx/bin/manage.edxapp', 'link': '/edx/app/edxapp/edx-platform/manage.py'},
  'edxapp_pip_bin': {'type': 'symlink', 'loc': '/edx/bin/pip.edxapp', 'link': '/edx/app/edxapp/venvs/edxapp/bin/pip'},
}
%}

{% for name, props in fs_validation.items() %}
test_{{ name }}_file_exists:
  testinfra.file:
    - name: {{ props.loc }}
    - is_{{ props.type }}: True
    {% if props.type == 'symlink' %}
    - linked_to: {{ props.link }}
    {% endif %}
{% endfor %}

test_page_request:
    testinfra.command:
      - name: wget -qO- localhost --no-check-certificate 2>&1
      - stdout:
          expected: <section class="courses-container">
          comparison: search
