{% from "pip/map.jinja" import pip with context %}

pip:
  pkg.installed:
    - name: {{ pip.pkgname }}

wheel:
  pip.installed:
    - name: wheel
