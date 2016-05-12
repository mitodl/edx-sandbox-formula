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
    - pip_path: {{ edx_sandbox.venv_path }}/bin/pip
    - is_installed: True
