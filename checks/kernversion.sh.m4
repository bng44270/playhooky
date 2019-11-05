#!/bin/bash

##############################
# sends the follows JSON to webhook:
#
# { "value1":"<kernel-version>" }
##############################

CHECKDIR="BASEDIR"
CONFDIR="$CHECKDIR/conf"

IFTTTKEY="KEYTEXT"

kernversiondata() {
  curl -s https://www.kernel.org/ | \
  awk '/stable:/ { getline; print gensub(/[ \t]*<[\/]*[a-z]*[\/]*>[ \t]*/,"","g",$0);exit }'
}

if [ "$1" == "cache" ]; then
  kernversiondata  > $CONFDIR/kernversion
else
  if [ ! -f $CONFDIR/kernversion ]; then
    echo "Caching kernel version"
	$0 cache
  else
    kernversiondata > /tmp/kernversion
    diff /tmp/kernversion $CONFDIR/kernversion > /dev/null
    if [ $? -eq 1 ] && [ $(grep '^[ \t]*$' /tmp/kernversion | wc -l) -eq 0 ]; then
      mv /tmp/kernversion $CONFDIR/kernversion
      echo "{\"value1\":\"$(cat $CONFDIR/kernversion)\"}" | curl -X POST -d ''"$(cat -)"'' -H "Content-type: application/json" https://maker.ifttt.com/trigger/{kernversion}/with/key/$IFTTTKEY
    else
      echo "skipping"
    fi
  fi
fi
