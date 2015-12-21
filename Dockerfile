FROM ubuntu:14.04
MAINTAINER d9magai

RUN apt-get update && apt-get -y install wget php5 apache2 php5-fpm libapache2-mod-php5 php5-mysql php5-gd php-pear php-apc php5-curl curl lynx-cur python-software-properties software-properties-common && apt-get clean


RUN sudo locale-gen en_US.UTF-8
RUN export LANG=en_US.UTF-8

RUN LC_ALL=en_US.UTF-8 add-apt-repository -y ppa:ondrej/apache2
RUN apt-key update
RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y php5-fpm apache2
RUN a2enmod proxy_fcgi proxy proxy_http http2 ssl expires headers rewrite

# Step 1:
#wget https://archive.apache.org/dist/httpd/httpd-2.4.18.tar.bz2
# Step 2:
#tar -vxjf httpd-2.4.18.tar.bz2
# Step 3:
#cd httpd-2.4.18






#RUN apt-get install python-software-properties
#RUN add-apt-repository -y ppa:ondrej/apache2
#RUN add-apt-repository -y ppa:ondrej/php5
#RUN apt-key update
#RUN apt-get update && apt-get upgrade -y
#RUN apt-get install -y php5-fpm apache2
#RUN a2enmod proxy_fcgi proxy proxy_http http2 ssl expires headers rewrite





RUN sed -i "s/short_open_tag = Off/short_open_tag = On/" /etc/php5/apache2/php.ini
RUN sed -i "s/error_reporting = .*$/error_reporting = E_ERROR | E_WARNING | E_PARSE/" /etc/php5/apache2/php.ini

Run sed -i "s/listen =.*/listen = 127.0.0.1:9000/" /etc/php5/fpm/pool.d/www.conf


ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid


ADD www /var/www/site
ADD www/.htaccess /var/www/site/.htaccess


ADD apache-config.conf /etc/apache2/sites-enabled/000-default.conf
ADD apache-config-ssl.conf /etc/apache2/sites-enabled/001-default-ssl.conf

#RUN rm -rf /var/www/site/*; rm -rf /etc/apache2/sites-enabled/*; \
#    mkdir -p /etc/apache2/external




RUN sed -i 's/^ServerSignature/#ServerSignature/g' /etc/apache2/conf-enabled/security.conf; \
    sed -i 's/^ServerTokens/#ServerTokens/g' /etc/apache2/conf-enabled/security.conf; \
    echo "ServerSignature Off" >> /etc/apache2/conf-enabled/security.conf; \
    echo "ServerTokens Prod" >> /etc/apache2/conf-enabled/security.conf; \
    a2enmod ssl; \
    a2enmod headers; \
    echo "SSLProtocol ALL -SSLv2 -SSLv3" >> /etc/apache2/apache2.conf


RUN a2enmod php5
RUN a2enmod rewrite
RUN a2enmod deflate


ADD ssl2/bundle.crt /etc/apache2/ssl/bundle.crt
ADD ssl2/gendev.key /etc/apache2/ssl/gendev.key
ADD ssl2/ca-certs.pem /etc/ssl/ca-certs.pem

#ADD ssl/server.key /usr/local/apache2/conf/server.key
#ADD ssl/server.crt /usr/local/apache2/conf/server.crt
ADD httpd.conf /usr/local/apache2/conf/httpd.conf
ADD httpd-ssl.conf /usr/local/apache2/conf/extra/httpd-ssl.conf

EXPOSE 80
EXPOSE 443

ADD entrypoint.sh /opt/entrypoint.sh
RUN chmod a+x /opt/entrypoint.sh

#RUN ["apt-get", "update"]
#RUN ["apt-get", "install", "-y", "nano"]
CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
