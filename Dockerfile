FROM    debian:jessie
MAINTAINER Josh Cox <josh 'at' webhosting coop>

ENV DDP_updated 20150831
RUN echo "deb http://mirrors.liquidweb.com/debian/ jessie main contrib non-free" > /etc/apt/sources.list
RUN echo "deb-src http://mirrors.liquidweb.com/debian/ jessie main contrib non-free" >> /etc/apt/sources.list

RUN echo "deb http://security.debian.org/ jessie/updates main contrib non-free" >> /etc/apt/sources.list
RUN echo "deb-src http://security.debian.org/ jessie/updates main contrib non-free" >> /etc/apt/sources.list

RUN apt-get update
#RUN apt-get -y upgrade

VOLUME ["/var/www"]
# MOUNT_FROM_HOST /exports/family_recipe /var/www

# Keep upstart from complaining
RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -sf /bin/true /sbin/initctl

# Basic Requirements
RUN DEBIAN_FRONTEND=noninteractive apt-get -y --force-yes install nginx php5-fpm php5-mysql php-apc pwgen python-setuptools curl git unzip

# Drupal Requirements
RUN DEBIAN_FRONTEND=noninteractive apt-get -y --force-yes install php5-curl php5-gd php5-intl php-pear php5-imap php5-memcache memcached drush mc

RUN apt-get clean

# nginx config
RUN sed -i -e"s/keepalive_timeout\s*65/keepalive_timeout 2/" /etc/nginx/nginx.conf
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

# php-fpm config
RUN sed -i -e "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php5/fpm/php.ini
RUN sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php5/fpm/php-fpm.conf
RUN find /etc/php5/cli/conf.d/ -name "*.ini" -exec sed -i -re 's/^(\s*)#(.*)/\1;\2/g' {} \;

# nginx site conf
ADD ./nginx-site.conf /etc/nginx/sites-available/default

# Supervisor Config
RUN /usr/bin/easy_install supervisor
ADD ./supervisord.conf /etc/supervisord.conf

# Retrieve drupal
RUN rm -rf /var/www/ ; cd /var ; drush dl drupal ; mv /var/drupal*/ /var/www/
RUN chmod a+w /var/www/sites/default ; mkdir /var/www/sites/default/files ; chown -R www-data:www-data /var/www/

ADD ./start.sh /start.sh
RUN chmod 755 /start.sh

# private expose
EXPOSE 80

CMD ["/bin/bash", "/start.sh"]
