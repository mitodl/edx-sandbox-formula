{% from "edx-sandbox/map.jinja" import edx-sandbox with context %}

edx-sandbox:
  pkg.installed:
    - pkgs: {{ edx-sandbox.pkgs }}
  service:
    - running
    - name: {{ edx-sandbox.service }}
    - enable: True
    - require:
      - pkg: edx-sandbox
