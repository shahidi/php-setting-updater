#!/bin/bash

# Define the functions you want to disable
DISABLED_FUNCTIONS="exec,passthru,shell_exec,system,proc_open,popen,curl_exec,curl_multi_exec,parse_ini_file,show_source"

echo "Updating disable_functions for all PHP versions..."

# Loop through each PHP version's php.ini
for php_ini in /opt/cpanel/ea-php*/root/etc/php.ini; do
    echo "Processing $php_ini"

    # Backup the original file
    cp "$php_ini" "$php_ini.bak"

    # If disable_functions exists, replace it; otherwise, append it
    if grep -q "^disable_functions" "$php_ini"; then
        sed -i "s|^disable_functions = .*|disable_functions = $DISABLED_FUNCTIONS|" "$php_ini"
    else
        echo -e "\ndisable_functions = $DISABLED_FUNCTIONS" >> "$php_ini"
    fi

    echo "Updated disable_functions in $php_ini"
done

# Restart Apache and PHP-FPM to apply changes
echo "Restarting Apache..."
systemctl restart httpd

echo "Restarting PHP-FPM for all versions..."
/scripts/restartsrv_apache_php_fpm

echo "✅ All disable_functions updated successfully."
