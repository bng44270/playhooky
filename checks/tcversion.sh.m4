#!/bin/bash

##############################
# sends the follows JSON to webhook:
#
# { "value1":"<core-version>" }
##############################

CHECKDIR="BASEDIR"
CONFDIR="$CHECKDIR/conf"

IFTTTKEY="KEYTEXT"

tinycoreversiondata() {
  curl -s http://tinycorelinux.net/ | \
  awk '/The latest version:/ { print gensub(/^.*The latest version:[ \t]*<[\/]*[a-z]*[\/]*>([0-9\.]*)<.*$/,"\\1","g",$0); }'
}

if [ "$1" == "cache" ]; then
  tinycoreversiondata > $CONFDIR/tcver
else
  if [ ! -f $CONFDIR/tcver ]; then
    echo "Caching OpenSSL version"
    $0 cache
  else
    tinycoreversiondata > /tmp/tcver
    diff /tmp/tcver $CONFDIR/tcver > /dev/null
    if [ $? -eq 1 ]; then
      mv /tmp/tcver $CONFDIR/tcver
      echo "{\"value1\":\"$(cat $CONFDIR/tcver)\"}" | curl -X POST -d ''"$(cat -)"'' -H "Content-type: application/json" https://maker.ifttt.com/trigger/{tcversion}/with/key/$IFTTTKEY
    else
      echo "skipping"
    fi
  fi
fi
