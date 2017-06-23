#!/bin/bash

# Fail on error
set -e

ECHO='echo -e'
KILL=/bin/kill
CAT=/bin/cat
RM=/bin/rm
ID=/usr/bin/id

identity=$0

CURRENT_USER=$($ID -un)

function usage() {
  echo "Usage: $0 NUMBER"
}

function lock() {
  # open the file 
  exec {fd}> "lockfile";

  # Attempt to obtain exclusive lock, non-blocking
  flock -x -n $fd || return 1;

  # Store PID in file
  echo "$$" >&$fd

  return 0
}

function unlock() {

  # unlock fd
  flock -u $fd || return 1;

  # success
  return 0;
}

function echoExit() {
  if [ $# -ne 1 ]; then
    echo "Error: Invalid number of arguments" >&2
    echo "Usage: echoExit MESSAGE" 
    exit 1;
  fi

  echo $1

  exit 1
}

###############################################################################
#
# lock function
#
function lock_old () {
    lock=/tmp/$identity.$CURRENT_USER
    $ECHO $$ > $lock.$$
#
# we probably only want to try once (plus once for stale lock)
#
    for i in 1 2
    do
        if $LN -n $lock.$$ $lock.lock 2>/dev/null 1>&2
        then
                return
        else
            if $KILL -0 $($CAT $lock.lock) 2>/dev/null
            then
                emit "$identity: unable to get lock...lock held by pid $($CAT $lock.lock)"
                $RM -f $lock.$$
                exit 9
            else
                $RM -f $lock.lock
            fi
        fi
    done
    $RM -f $lock.$$
}

###############################################################################
#
# unlock function
#
function unlock_old () {
    lock=/tmp/$identity.$CURRENT_USER
    if [ -f $lock.lock ] && [ "$($CAT $lock.lock 2>/dev/null)" = "$$" ]; then
        $RM -f $lock.$$ $lock.lock
    fi
}

if [ $# -ne 1 ]; then
  usage
  exit 1
fi

lock || echoExit "$1 unavailable";

echo "$1 locked"

sleep 1

unlock || echoExit "$1 unlock failed";

echo "$1 unlocked"
