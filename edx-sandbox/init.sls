{% from "edx-sandbox/map.jinja" import edx_sandbox with context %}



install_os_packages:
  pkg.installed:
    - pkgs: {{ edx_sandbox.pkgs }}
    - refresh: True

clone_edx_configuration:
  git.latest:
    - name: https://github.com/edx/configuration.git
    - branch: master
    - target: {{ edx_sandbox.repo_path }}
    - user: root
