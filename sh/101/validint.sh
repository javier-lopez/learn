#!/usr/bin/env bash
# validint -- Validates integer input, allowing negative ints too.

function validint
{
  # Validate first field. Then test against min value $2 and/or
  # max value $3 if they are supplied. If they are not supplied, skip these tests.

  number="$1";      min="$2";      max="$3"

  if [ -z $number ] ; then
    echo "You didn't enter anything. Unacceptable." >&2 ; return 1
  fi

  if [ "${number%${number#?}}" = "-" ] ; then  # is first char a '-' sign?
testvalue="${number#?}"     # all but first character
  else
    testvalue="$number"
  fi

  nodigits="$(echo $testvalue | sed 's/[[:digit:]]//g')"

  if [ ! -z $nodigits ] ; then
    echo "Invalid number format! Only digits, no commas, spaces, etc." >&2
    return 1
  fi

  if [ ! -z $min ] ; then
    if [ "$number" -lt "$min" ] ; then
       echo "Your value is too small: smallest acceptable value is $min" >&2
       return 1
    fi
  fi
  if [ ! -z $max ] ; then
     if [ "$number" -gt "$max" ] ; then
       echo "Your value is too big: largest acceptable value is $max" >&2
       return 1
     fi
  fi
  return 0
}
