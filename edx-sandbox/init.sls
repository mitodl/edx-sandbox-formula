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
