{% from "edx-sandbox/map.jinja" import edx_sandbox with context %}

install_os_packages:
  pkg.installed:
    - pkgs: {{ edx_sandbox.pkgs }}
    - refresh: True

upgrade_pip:
  cmd.run:
    - name: pip install --upgrade pip
    - require:
      - pkg: install_os_packages

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

install_edx_configuration_pip_requirements:
  pip.installed:
    - requirements: {{ edx_sandbox.repo_path }}/requirements.txt
    - require:
      - cmd: upgrade_pip
      - git: clone_edx_configuration

place_sandbox_ansible_configuration:
  file.managed:
    - name: {{ edx_sandbox.conf_file }}
    - source: salt://edx-sandbox/templates/ansible_env_config.yaml.j2
    - template: jinja
    - context:
      ansible_env_config: {{ edx_sandbox.ansible_env_config }}
    - makedirs: True

run_ansible:
  cmd.run:
    - name: "ansible-playbook -c local -i localhost, edx_sandbox.yml --extra-vars @{{ edx_sandbox.conf_file }}"
    - cwd: {{ edx_sandbox.repo_path }}/playbooks
    - require:
      - pip: install_edx_configuration_pip_requirements
      - file: place_sandbox_ansible_configuration
