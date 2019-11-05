#!/bin/bash

##############################
# sends the follows JSON to webhook:
#
# { "value1":"<openssl-version>" }
##############################

CHECKDIR="BASEDIR"
CONFDIR="$CHECKDIR/conf"

IFTTTKEY="KEYTEXT"

opensslversiondata() {
  curl -s https://www.openssl.org/source/ | \
  awk '/stable/ { print gensub(/^.* ([0-9\.]+) .*$/,"\\1","g",$0); }'
}

if [ "$1" == "cache" ]; then
  opensslversiondata > $CONFDIR/sslver
else
  if [ ! -f $CONFDIR/sslver ]; then
    echo "Caching OpenSSL version"
    $0 cache
  else
    opensslversiondata > /tmp/sslver
    diff /tmp/sslver $CONFDIR/sslver
    if [ $? -eq 1 ]; then
      mv /tmp/sslver $CONFDIR/sslver
      echo "{\"value1\":\"$(cat $CONFDIR/sslver)\"}" |curl -X POST -d ''"$(cat -)"'' -H "Content-type: application/json" https://maker.ifttt.com/trigger/{sslversion}/with/key/$IFTTTKEY
    else
      echo "skipped"
    fi
  fi
fi
