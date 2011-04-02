#!/usr/bin/env bash
# nicenumber -- Given a number, shows it in comma-separated form.
# Expects DD and TD to be instantiated. Instantiates nicenum
# or, if a second arg is specified, the output is echoed to stdout.

nicenumber()
{
  # Note that we assume that '.' is the decimal separator in
  # the INPUT value to this script. The decimal separator in the output value is
  # '.' unless specified by the user with the -d flag

  integer=$(echo $1 | cut -d. -f1)              # left of the decimal
  decimal=$(echo $1 | cut -d. -f2)              # right of the decimal

  if [ $decimal != $1 ]; then
    # There's a fractional part, so let's include it.
    result="${DD:="."}$decimal"
  fi

  thousands=$integer

  while [ $thousands -gt 999 ]; do
    remainder=$(($thousands % 1000))    # three least significant digits

    while [ ${#remainder} -lt 3 ] ; do  # force leading zeros as needed
      remainder="0$remainder"
    done

    thousands=$(($thousands / 1000))    # to left of remainder, if any
    result="${TD:=","}${remainder}${result}"    # builds right to left
  done

  nicenum="${thousands}${result}"
  if [ ! -z $2 ] ; then
    echo $nicenum
  fi
}

DD="." # decimal point delimiter, to separate integer and fractional values
TD="," # thousands delimiter, to separate every three digits

while getopts "d:t:" opt; do
  case $opt in
    d ) DD="$OPTARG"    ;;
    t ) TD="$OPTARG"    ;;
  esac
done
shift $(($OPTIND - 1))

if [ $# -eq 0 ] ; then
  echo "Usage: $(basename $0) [-d c] [-t c] numeric value"
  echo "  -d specifies the decimal point delimiter (default '.')"
  echo "  -t specifies the thousands delimiter (default ',')"
  exit 0
fi

nicenumber $1 1         # second arg forces nicenumber to 'echo' output

exit 0
