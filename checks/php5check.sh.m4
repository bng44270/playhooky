#!/bin/bash

##############################
# sends the follows JSON to webhook:
#
# { "value1":"<php5-version>" }
##############################

CHECKDIR="BASEDIR"
CONFDIR="$CHECKDIR/conf"

IFTTTKEY="KEYTEXT"

php5versiondata() {
  curl -s http://php.net/downloads.php 2>/dev/null | \
  grep -A1 'Current Stable' | awk '/^[ \t]*PHP 5/ { print $2 }'
}

if [ "$1" == "cache" ]; then
  php5versiondata > $CONFDIR/php5ver
else
  if [ ! -f $CONFDIR/php5ver ]; then
    echo "Caching PHP 5 version"
    $0 cache
  else
    php5versiondata  > /tmp/php5ver
    diff /tmp/php5ver $CONFDIR/php5ver
    if [ $? -eq 1 ] && [ $(grep '^[ \t]*$' /tmp/php5ver | wc -l) -eq 0 ]; then
      mv /tmp/php5ver $CONFDIR/php5ver
      echo "{\"value1\":\"$(cat $CONFDIR/php5ver)\"}" |curl -X POST -d ''"$(cat -)"'' -H "Content-type: application/json" https://maker.ifttt.com/trigger/{php5version}/with/key/$IFTTTKEY
    else
      echo "skipping"
    fi
  fi
fi
