{% from "edx-sandbox/map.jinja" import edx-sandbox, edx-sandbox_config with context %}

include:
  - edx-sandbox

edx-sandbox-config:
  file.managed:
    - name: {{ edx-sandbox.conf_file }}
    - source: salt://edx-sandbox/templates/conf.jinja
    - template: jinja
    - context:
      config: {{ edx-sandbox_config }}
    - watch_in:
      - service: edx-sandbox
    - require:
      - pkg: edx-sandbox
