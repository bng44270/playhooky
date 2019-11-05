#!/bin/bash

##############################
# sends the follows JSON to webhook:
#
# { "value1":"<monit-version>" }
##############################

CHECKDIR="BASEDIR"
CONFDIR="$CHECKDIR/conf"

IFTTTKEY="KEYTEXT"

monitversiondata() {
  curl -s https://mmonit.com/monit/ | \
  awk '/Monit.*Downloads/ { print gensub(/^.*Monit ([0-9\.]+) Downloads.*$/,"\\1","g",$0); }'
}

if [ "$1" == "cache" ]; then
  monitversiondata  > $CONFDIR/monitversion
else
  if [ ! -f $CONFDIR/monitversion ]; then
    echo "Caching Monit version"
    $0 cache
  else
    monitversiondata > /tmp/monitversion
    diff /tmp/monitversion $CONFDIR/monitversion
    if [ $? -eq 1 ] && [ $(grep '^[ \t]*$' /tmp/monitversion | wc -l) -eq 0 ]; then
      mv /tmp/monitversion $CONFDIR/monitversion
      echo "{\"value1\":\"$(cat $CONFDIR/monitversion)\"}" |curl -X POST -d ''"$(cat -)"'' -H "Content-type: application/json" https://maker.ifttt.com/trigger/{monitversion}/with/key/$IFTTTKEY
    else
      echo "skipping"
    fi
  fi
fi
