{% from "docker/map.jinja" import docker with context %}

{% if grains['os_family']=='Debian' %}
docker-repo:
  pkgrepo.managed:
    - humanname: Docker Repo
    - name: deb http://get.docker.com/ubuntu docker main
    - file: /etc/apt/sources.list.d/docker.list
    - keyid: 36A1D7869245C8950F966E92D8576A8BA88D21E9
    - keyserver: keyserver.ubuntu.com
    - require_in:
      - pkg: lxc-docker
{% endif %}

docker:
  pkg.installed:
    - name: {{ docker.pkgname }}
    - refresh: True

docker-py:
  pip.installed:
    - use_wheel: True
