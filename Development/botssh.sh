#!/bin/bash

if [ -e "${BOTKEY}" ] ; then
  ssh -i ${BOTKEY} $*
  exit $?
else
  echo "If you ever drop your keys into a river of molten lava, let 'em go, because, man, they're gone." 1>&2
  exit 1
fi
