{% from "php/map.jinja" import php with context %}

{% if not salt['config.get']('sudo_user') %}
  {% set salt_user = salt['config.get']('user', 'root') %}
{% else %}
  {% set salt_user = salt['config.get']('sudo_user', 'root') %}
{% endif %}

{% set tools = salt['pillar.get']('php:lookup:tools', []) %}

include:
  - php
{% if grains['os_family'] == 'FreeBSD' %}
  - php.filter
  - php.hash
  - php.json
  - php.mbstring
  - php.openssl
  - php.phar
{% endif %}

{% for tool,source in tools.items() %}
/usr/bin/{{tool}}:
  file.managed:
    - source: {{ source['url'].replace('VERSION_STRING', source['version']) }}
    - source_hash: {{ source['hash'] }}
    - show_changes: False
    - user: {{ salt_user }}
    - group: {{ salt_user }}
    - mode: 755
    - unless:
      - \{ /usr/bin/{{tool}} -v 2>&1; /usr/bin/{{tool}} --version 2>&1; \} | grep {{ source['version'] }}
{% endfor %}
