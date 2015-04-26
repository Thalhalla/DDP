#!/bin/bash
a2enmod vhost_alias
sleep 3
supervisord -n -c /etc/supervisord.conf
