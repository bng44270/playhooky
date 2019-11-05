#!/bin/bash

##############################
# sends the follows JSON to webhook:
#
# { "value1":"<ghe-version>" }
##############################

CHECKDIR="BASEDIR"
CONFDIR="$CHECKDIR/conf"

IFTTTKEY="KEYTEXT"

gheversiondata() {
  curl -s https://enterprise.github.com/releases | \
  awk '/href="\/releases\/[0-9\.]*"/ { 
  printf("%s",gensub(/^.*>(.*)<.*$/,"\\1","g",$0)); 
  exit;
  }'
}

if [ "$1" == "cache" ]; then
  gheversiondata > $CONFDIR/gheversion
else
  if [ ! -f $CONFDIR/gheversion ]; then
    echo "Caching GHE version"
    $0 cache
  else
    gheversiondata > /tmp/gheversion
    diff /tmp/gheversion $CONFDIR/gheversion > /dev/null
    if [ $? -eq 1 ] && [ $(grep '^[ \t]*$' /tmp/gheversion | wc -l) -eq 0 ]; then
      mv /tmp/gheversion $CONFDIR/gheversion
      echo "{\"value1\":\"$(cat $CONFDIR/gheversion)\"}" | curl -X POST -d ''"$(cat -)"'' -H "Content-type: application/json" https://maker.ifttt.com/trigger/{gheversion}/with/key/$IFTTTKEY
    else
      echo "skipping"
    fi
  fi
fi
