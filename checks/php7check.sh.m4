#!/bin/bash

##############################
# sends the follows JSON to webhook:
#
# { "value1":"<php7-version>" }
##############################

CHECKDIR="BASEDIR"
CONFDIR="$CHECKDIR/conf"

IFTTTKEY="KEYTEXT"

php7versiondata() {
  curl -s http://php.net/downloads.php 2>/dev/null | \
  grep -A1 'Current Stable' | awk '/^[ \t]*PHP 7/ { print $2 }'
}

if [ "$1" == "cache" ]; then
  php7versiondata > $CONFDIR/php7ver
else
  if [ ! -f $CONFDIR/php7ver ]; then
    echo "Caching PHP 7 version"
    $0 cache
  else
    php7versiondata  > /tmp/php7ver
    diff /tmp/php7ver $CONFDIR/php7ver
    if [ $? -eq 1 ] && [ $(grep '^[ \t]*$' /tmp/php7ver | wc -l) -eq 0 ]; then
      mv /tmp/php7ver $CONFDIR/php7ver
      echo "{\"value1\":\"$(cat $CONFDIR/php7ver)\"}" |curl -X POST -d ''"$(cat -)"'' -H "Content-type: application/json" https://maker.ifttt.com/trigger/{php7version}/with/key/$IFTTTKEY
    else
      echo "skipping"
    fi
  fi
fi
