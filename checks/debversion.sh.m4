#!/bin/bash

##############################
# sends the follows JSON to webhook:
#
# { "value1":"<debian-version>" }
##############################

CHECKDIR="BASEDIR"
CONFDIR="$CHECKDIR/conf"

IFTTTKEY="KEYTEXT"

debversiondata() {
  curl -s https://www.debian.org/releases/stable/ 2>/dev/null | \
  awk '/Debian [0-9]/ { printf("%s",gensub(/^.*Debian[ \t]*([0-9\.]+)[ \t]*.*$/,"\\1","g",$0));exit; }'
}

if [ "$1" == "cache" ]; then
  debversiondata > $CONFDIR/debversion
else
  if [ ! -f $CONFDIR/debversion ]; then
    echo "Caching Debian version"
    $0 cache
  else
    debversiondata > /tmp/debversion
    diff /tmp/debversion $CONFDIR/debversion
    if [ $? -eq 1 ] && [ $(grep '^[ \t]*$' /tmp/debversion | wc -l) -eq 0 ]; then
      mv /tmp/debversion $CONFDIR/debversion
      echo "{\"value1\":\"$(cat $CONFDIR/debversion)\"}" |curl -X POST -d ''"$(cat -)"'' -H "Content-type: application/json" https://maker.ifttt.com/trigger/{debversion}/with/key/$IFTTTKEY
    else
      echo "skipping"
    fi
  fi
fi
