{% from "edx-sandbox/map.jinja" import edx_sandbox with context %}

test_packages_installed:
  testinfra.package:
    - name: git
    - is_installed: True

test_cloned_configuration:
  testinfra.file:
    - name: {{ edx_sandbox.repo_path }}/.git
    - is_directory: True
