{% from "edx-sandbox/map.jinja" import edx_sandbox with context %}

install_os_packages:
  pkg.installed:
    - pkgs: {{ edx_sandbox.pkgs }}
    - refresh: True

clone_edx_configuration:
  file.directory:
    - name: {{ edx_sandbox.repo_path }}
    - makedirs: True
  git.latest:
    - name: https://github.com/edx/configuration.git
    - branch: master
    - target: {{ edx_sandbox.repo_path }}
    - user: root
    - require:
      - file: clone_edx_configuration

mark_ansible_as_editable:
  file.replace:
    - name: {{ edx_sandbox.repo_path }}/requirements.txt
    - pattern: |
        ^git\+https://github\.com/edx/ansible.*
    - repl: |
        --editable git+https://github.com/edx/ansible.git@stable-1.9.3-rc1-edx#egg=ansible==1.9.3-edx
    - require:
      - git: clone_edx_configuration

create_ansible_virtualenv:
  # Note: We need to use a virtualenv over here because the Salt minion bootstrap
  #       installs some OS `python-` packages that are also pulled in by the edX
  #       config requirements for Ansible (e.g. python-jinja). This causes python
  #       package metadata issues, resulting in Ansible not being able to import
  #       dependencies at runtime.
  virtualenv.managed:
    - name: {{ edx_sandbox.venv_path }}
    - requirements: {{ edx_sandbox.repo_path }}/requirements.txt
    - require:
      - git: clone_edx_configuration

place_sandbox_ansible_configuration:
  file.managed:
    - name: {{ edx_sandbox.conf_file }}
    - source: salt://edx-sandbox/templates/ansible_env_config.yaml.j2
    - template: jinja
    - context:
      ansible_env_config: {{ edx_sandbox.ansible_env_config }}
    - makedirs: True

{% if edx_sandbox.generate_certificate %}
generate_self_signed_certificate:
  module.run:
    - name: tls.create_self_signed_cert
    - CN: {{ edx_sandbox.ansible_env_config.TLS_KEY_NAME }}
    - replace: True
    - require_in:
      - cmd: run_ansible
{% else %}
{%
  set key_path = '{}/{}'.format(
    edx_sandbox.ansible_env_config.TLS_LOCATION,
    edx_sandbox.ansible_env_config.TLS_KEY_NAME
  )
%}
{% for ext in ['crt', 'key'] %}
place_tls_{{ ext }}_file:
  file.managed:
    - name: {{ key_path }}.{{ ext }}
    - contents: {{ edx_sandbox['edx_tls_{}'.format(ext)] }}
    - user: root
    - group: root
    - mode: 600
    - require_in:
      - cmd: run_ansible
{% endfor %}
{% endif %}

run_ansible:
  cmd.script:
    - name: {{ edx_sandbox.data_path }}/run_ansible.sh
    - source: salt://edx-sandbox/templates/run_ansible.sh.j2
    - template: jinja
    - cwd: {{ edx_sandbox.repo_path }}/playbooks
    - require:
      - virtualenv: create_ansible_virtualenv
