pip:
  pkg.installed:
    - name: {{ pillar['pkgs']['pip'] }}

wheel:
  pip.installed
