#!/bin/sh

set -e
[ ${DEBUG} = "on" ] && set -x && VERBOSE="-verbose"


config_count () {
    return $(xmlstarlet sel -t -v "count(/configuration/$1)" $CONFIG_FILE)
}

config_del () {
    xmlstarlet ed -O -L -d /configuration/$1 $CONFIG_FILE
}

config_set () {
    if [ -z $2 ]; then
        config_del $1
        return
    fi

    if config_count $1; then
        local xpath
        local name
        local type
        xpath=/configuration/$(dirname $1)
        name=$(basename $1)
        if echo $name | egrep -q "^@.*"; then
            type=attr
            name=${name:1}
        else
            type=elem
        fi
        xmlstarlet ed -O -L -s $xpath -t $type -n $name -v $2 $CONFIG_FILE
    else
        xmlstarlet ed -O -L -u /configuration/$1 -v $2 $CONFIG_FILE
    fi
}

# environment defaults
: ${CONFIG_DIR:='/syncthing/config'}
CONFIG_FILE=$CONFIG_DIR/config.xml
: ${UID:='1000'}
: ${GID:='1000'}
: ${GUI_ADDRESS:='[::]:8384'}
: ${GUI_ENABLED:='true'}
: ${GUI_TLS:='false'}
: ${GUI_USERNAME:=''}
: ${GUI_PASSWORD_PLAIN:=''}
if [ -z "$GUI_PASSWORD_BCRYPT" ] && [ -n "$GUI_PASSWORD_PLAIN" ]; then
    echo "Calculating password hash..."
    GUI_PASSWORD_BCRYPT=$(htpasswd -bnB -C12 foo ${GUI_PASSWORD_PLAIN} | cut -f2 -d:)
fi
: ${GUI_PASSWORD_BCRYPT:=''}

# create user and group if necessary
if [ ! $(getent group $GID) ]; then
    addgroup -g $GID syncthing
fi
GROUP_NAME=$(getent group $GID | cut -f 1 -d ":")
if [ ! $(getent passwd $UID) ]; then
    adduser -D -H -u $UID -G $GROUP_NAME syncthing
fi
USER_NAME=$(getent passwd $UID | cut -f 1 -d ":")

# generate initial config if necessary
if [ ! -f $CONFIG_FILE ]; then
    syncthing -generate=$CONFIG_DIR
    config_del "/configuration/folder"
    config_set "options/startBrowser" "false"
fi

# ensure the default folder points to the data volume
config_set "options/defaultFolderPath" "/syncthing/data"

# disable automated upgrades
config_set "options/autoUpgradeIntervalH" "0"

# update config.xml according to environment variables
config_set "gui/address" $GUI_ADDRESS
config_set "gui/@enabled" $GUI_ENABLED
config_set "gui/@tls" $GUI_TLS
config_set "gui/user" $GUI_USERNAME
config_set "gui/password" $GUI_PASSWORD_BCRYPT

if config_count "gui/user"; then
    config_set "gui/insecureAdminAccess" "true"
else
    config_del "gui/insecureAdminAccess"
fi

if [ -n "$GUI_APIKEY" ]; then
    config_set "gui/apikey" $GUI_APIKEY
fi

unset GUI_PASSWORD_PLAIN
unset GUI_PASSWORD_BCRYPT

# execute additional script
if [ -f "/pre-launch.sh" ]; then
    source /pre-launch.sh
fi

# change ownership to executing user
chown -R $UID:$GID /syncthing $CONFIG_DIR

syncthing -home=$CONFIG_DIR -paths
echo "======== config.xml ========"
cat $CONFIG_FILE
echo "============================"

su-exec $USER_NAME syncthing -home=$CONFIG_DIR $VERBOSE

exit 1
