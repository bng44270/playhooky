#!/bin/bash

##############################
# sends the follows JSON to webhook:
#
# { "value1":"<openssh-version>" }
##############################

CHECKDIR="BASEDIR"
CONFDIR="$CHECKDIR/conf"

IFTTTKEY="KEYTEXT"

sshversiondata() {
  curl -s https://www.openssh.com/ | \
  awk '/released/ { print gensub(/^.*OpenSSH ([0-9\.]+)<.*$/,"\\1","1",$0); }'
}

if [ "$1" == "cache" ]; then
  sshversiondata > $CONFDIR/sshver
else
  if [ ! -f $CONFDIR/sshver ]; then
    echo "Caching OpenSSH version"
    $0 cache
  else
    sshversiondata  > /tmp/sshver
    diff /tmp/sshver $CONFDIR/sshver
    if [ $? -eq 1 ]; then
      mv /tmp/sshver $CONFDIR/sshver
      echo "{\"value1\":\"$(cat $CONFDIR/sshver)\"}" |curl -X POST -d ''"$(cat -)"'' -H "Content-type: application/json" https://maker.ifttt.com/trigger/{sshversion}/with/key/$IFTTTKEY
    else
      echo "skipped"
    fi
  fi
fi
