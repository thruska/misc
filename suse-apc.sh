#!/bin/sh

# PHP Apc installer and deinstaller
#
# Usage: sh suse-apc.sh [install|uninstall]
#
# Run as root
# Tested on SuSe 11.1


apc_installed() {
    if ! which pecl > /dev/null ; then return 1 ; fi
    if ! pecl info apc > /dev/null ; then return 1 ; fi
    php -i | grep 'apc.enabled => On => On' > /dev/null
    return $?
}

if [ "$1" = "install" ] ; then

    if apc_installed ; then
        echo "APC is already installed"
        exit 1
    fi

    echo "Installing dependencies"
    yast -i gcc autoconf make php5 php5-pear php5-devel

    if [ $? -gt 0 ] ; then
        echo "Installation of dependencies failed"
        exit 1
    fi

    echo "Installing apc by pecl"
    echo '' | pecl install apc

    if [ $? -gt 0 ] ; then
        echo "Apc installation failed"
    fi

    echo "Enabling apc"
    echo "extension=apc.so" > /etc/php5/conf.d/apc.ini

    if [ $? -gt 0 ] ; then
        echo "Apc enabling failed"
        exit 1
    fi

    if apc_installed ; then
        echo -e "\nApc installed successfully"
        echo -e "Restart the Apache server to enable it for projects using mod_php\n"
    else    
        echo "Apc not installed or enabled"
        exit 1
    fi

elif [ "$1" = "uninstall" ] ; then

    if ! apc_installed ; then
        echo "Apc or pecl is not installed"
        exit 1
    fi

    echo "Disabling apc"
    rm /etc/php5/conf.d/apc.ini

    if [ $? -gt 0 ] ; then
        echo "Failed"
        exit 1
    fi

    echo "Uninstalling using pecl"
    pecl uninstall apc

    if [ $? -gt 0 ] ; then
        echo "Uninstall failed"
        exit 1
    fi

    echo "Uninstalled"

else
    echo -e "usage:\n  sh $0 [install|uninstall]"
    exit 1
fi
