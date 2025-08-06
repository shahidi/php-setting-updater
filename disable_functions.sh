#!/bin/bash

# Define the functions you want to disable
DISABLED_FUNCTIONS="exec,passthru,shell_exec,system,proc_open,popen,curl_exec,curl_multi_exec,parse_ini_file,show_source"

echo "🔍 Searching for installed EA4 PHP versions..."

# Find all php.ini files for EA4 PHP versions
PHP_INI_FILES=$(find /opt/cpanel/ea-php*/root/etc/php.ini 2>/dev/null)

if [ -z "$PHP_INI_FILES" ]; then
    echo "❌ No PHP versions found in /opt/cpanel/ea-php*/root/etc/"
    exit 1
fi

for php_ini in $PHP_INI_FILES; do
    echo "📄 Processing: $php_ini"

    # Backup the original
    cp "$php_ini" "${php_ini}.bak"

    # Check if disable_functions exists
    if grep -q "^disable_functions" "$php_ini"; then
        sed -i "s|^disable_functions =.*|disable_functions = $DISABLED_FUNCTIONS|" "$php_ini"
        echo "✅ Updated disable_functions"
    else
        echo -e "\ndisable_functions = $DISABLED_FUNCTIONS" >> "$php_ini"
        echo "➕ Added disable_functions"
    fi
done

# Restart services
echo "🔁 Restarting Apache..."
systemctl restart httpd

echo "🔁 Restarting PHP-FPM (if used)..."
/scripts/restartsrv_apache_php_fpm

echo "✅ All PHP versions updated."
