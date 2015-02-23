{% if grains['os_family']=='Debian' %}
docker-repo:
  pkgrepo.managed:
    - humanname: Official Docker Repository
    - name: deb http://get.docker.com/ubuntu docker main
    - file: /etc/apt/sources.list.d/docker.list
    - keyid: 36A1D7869245C8950F966E92D8576A8BA88D21E9
    - keyserver: keyserver.ubuntu.com
    - require_in:
      - pkg: {{ pillar['pkgs']['docker'] }}
    - pkg.installed:
      - refresh: True
{% endif %}

docker:
  pkg.installed:
    - name: {{ pillar['pkgs']['docker'] }}

docker-py:
  pip.installed:
    - use_wheel: True
