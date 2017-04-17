#! /bin/bash
if [ "$DWL_SHIELD_HTTP" == "true" ]; then
    DWL_APACHE2_SHIELD="/dwl/shield/apache2";
    echo "Generate htpasswd with htpasswd -b -c '$DWL_APACHE2_SHIELD/.htpasswd $DWL_USER_NAME $DWL_USER_PASSWD'";
    if [ ! -d $DWL_APACHE2_SHIELD ]; then
        mkdir -p $DWL_APACHE2_SHIELD;
    fi
    htpasswd -b -c $DWL_APACHE2_SHIELD/.htpasswd $DWL_USER_NAME $DWL_USER_PASSWD;
    if [ ! -f /etc/apache2/sites-available/0000_allowoverride_0.conf ]; then
        cp /dwl/default/etc/apache2/sites-available/0000_allowoverride_0.conf /etc/apache2/sites-available
    fi
    if [ ! -f /var/www/html/.htaccess ]; then
        cp /dwl/shield/default/var/www/html/.htaccess /var/www/html/.htaccess
    fi
fi

for conf in `find /etc/apache2/sites-available -type f -name "*.conf"`; do

    DWL_USER_DNS_CONF=${conf};

    DWL_USER_DNS_DATA=`echo ${DWL_USER_DNS_CONF} | awk -F '[/]' '{print $5}' | sed "s|\.conf||g"`;

    a2ensite ${DWL_USER_DNS_DATA};

done;

if [ -d /home/${DWL_USER_NAME}/files ]; then
    rm -rdf ${DWL_HTTP_DOCUMENTROOT:-/var/www/html};
    ln -sf /home/${DWL_USER_NAME}/files ${DWL_HTTP_DOCUMENTROOT:-/var/www/html};
fi

service apache2 start;
DWL_KEEP_RUNNING=true;
