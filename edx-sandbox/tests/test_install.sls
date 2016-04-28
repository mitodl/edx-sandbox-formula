{% from "edx-sandbox/map.jinja" import edx_sandbox with context %}

test_packages_installed:
  testinfra.package:
    - name: git
    - is_installed: True

test_cloned_configuration:
  testinfra.file:
    - name: {{ edx_sandbox.repo_path }}/.git
    - is_directory: True

test_edx_configuration_pip_requirements:
  testinfra.python_package:
    - name: ansible
    - is_installed: True

test_ansible_config_placed:
  testinfra.file:
    - name: {{ edx_sandbox.repo_path }}/playbooks/ansible_env_config.yaml
    - is_file: True
    - contains:
        parameter: {{ edx_sandbox.ansible_env_config.keys()[0] }}
        expected: True
        comparison: is_
