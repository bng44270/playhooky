#!/bin/bash

##############################
# sends the follows JSON to webhook:
#
# { "value1":"<snmp-version>" }
##############################

CHECKDIR="BASEDIR"
CONFDIR="$CHECKDIR/conf"

IFTTTKEY="KEYTEXT"

snmpversiondata() {
  curl -s http://www.net-snmp.org/ | \
  awk '/Current release/ { print gensub(/^.*Current release:[ \t]*([0-9\.]+).*$/,"\\1","g",$0); }'
}

if [ "$1" == "cache" ]; then
  snmpversiondata > $CONFDIR/snmpver
else
  if [ ! -f $CONFDIR/snmpver ]; then
    echo "Caching Net-SNMP version"
    $0 cache
  else
    snmpversiondata > /tmp/snmpver
    diff /tmp/snmpver $CONFDIR/snmpver
    if [ $? -eq 1 ]; then
      mv /tmp/snmpver $CONFDIR/snmpver
      echo "{\"value1\":\"$(cat $CONFDIR/snmpver)\"}" |curl -X POST -d ''"$(cat -)"'' -H "Content-type: application/json" https://maker.ifttt.com/trigger/{snmpversion}/with/key/$IFTTTKEY
    else
      echo "skipped"
    fi
  fi
fi
