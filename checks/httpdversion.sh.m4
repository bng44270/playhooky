#!/bin/bash

##############################
# sends the follows JSON to webhook:
#
# { "value1":"<httpd-version>" }
##############################

CHECKDIR="BASEDIR"
CONFDIR="$CHECKDIR/conf"

IFTTTKEY="KEYTEXT"

httpdversiondata() {
  curl -s https://httpd.apache.org/ | \
  awk '/Released/ { print gensub(/^.* httpd[ \t]*([0-9\.]+)[ \t]*Released.*$/,"\\1","g",$0); }'
}

if [ "$1" == "cache" ]; then
  httpdversiondata  > $CONFDIR/httpdversion
else
  if [ ! -f $CONFDIR/httpdversion ]; then
    echo "Caching httpd version"
    $0 cache
  else
    httpdversiondata  > /tmp/httpdversion
    diff /tmp/httpdversion $CONFDIR/httpdversion
    if [ $? -eq 1 ] && [ $(grep '^[ \t]*$' /tmp/httpdversion | wc -l) -eq 0 ]; then
      mv /tmp/httpdversion $CONFDIR/httpdversion
      echo "{\"value1\":\"$(cat $CONFDIR/httpdversion)\"}" |curl -X POST -d ''"$(cat -)"'' -H "Content-type: application/json" https://maker.ifttt.com/trigger/{httpdversion}/with/key/$IFTTTKEY
    else
      echo "skipping"
    fi
  fi
fi
