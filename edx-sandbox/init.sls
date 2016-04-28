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

install_edx_configuration_pip_requirements:
  pip.installed:
    - requirements: {{ edx_sandbox.repo_path }}/requirements.txt
    - require:
      - git: clone_edx_configuration

place_the_sandbox_configuration:
  file.managed:
    - name: {{ edx_sandbox.repo_path }}/playbooks/ansible_env_config.yaml
    - source: salt://edx-sandbox/templates/ansible_env_config.yaml.j2
    - template: jinja
    - context:
      ansible_env_config: {{ edx_sandbox.ansible_env_config }}
    - makedirs: True
