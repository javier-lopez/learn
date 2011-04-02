#!/bin/bash
# Copyfuck © 2010 q (http://pastebin.com/hKbZSGP6 --only with mono support)
# modified by chilicuil@gmail.com (wine)
#
# This script installs, updates and runs LOIC on Linux.
#
# Supported distributions:
#   * Ubuntu / Debian / Linux Mint
#   * Fedora
#   * Red-Hat
#   * Gentoo
#   * Arch
#
# Usage: bash install_loic.bash [-w|-m] <install|update|run>

###COLOURS###

DEFAULT=$'\E[0m'
LIGHT_GREEN=$'\E[1;32m'
LIGHT_RED=$'\E[1;31m'

###GLOBALS###

GIT_REPO=https://github.com/NewEraCracker/LOIC.git
GIT_BRANCH=master

###AUX FUNCTIONS###

#fancy output, taken mainly from /etc/lsb-base-logging.sh
COLS=`tput cols`
if [ "$COLS" ] && [ "$COLS" -gt 6 ]; then
    COL=`expr $COLS - 8`
else
    COLS=80
    COL=72
fi

st()
{
    printf "\r"
    tput hpa $COL
    if [ $1 -ne 0 ]; then
            echo -e "$LIGHT_RED[FAILED]$DEFAULT"
            exit 1
        else
            echo -e "$LIGHT_GREEN[DONE]$DEFAULT"
    fi
}
#===================================================

###FUNCTIONS###
usage()
{
  echo -e "Usage: `basename $0` [-w|-m] <run|compile|update|run>" >&2
  echo -e >&2
  echo -e "  run                alskja" >&2
  echo -e "  compile            alkajs" >&2
  echo -e "  update             jalsk" >&2
  echo -e "  -w                 Use wine (by default)" >&2
  echo -e "  -m                 Use mono" >&2
  exit 1
}

while getopts ":wm" option; do
    case $option in
        w)
          WFLAG=yes
          EXECUTE=$OPTARG
          ;;
        m)
          MFLAG=yes
          EXECUTE=$OPTARG
          ;;
        \?)
          echo "Invalid option: -$OPTARG"
          usage
          ;;
    esac
done

ensure_git() #Checks if git is installed, Tries to install it if not
{
    type -P git &>/dev/null ||
    {
        echo -e "$LIGHT_RED[-]$DEFAULT Git not found! Attempting to install..."
        if [ -f /etc/lsb-release ] ; then
            echo -e "$LIGHT_RED[+]$DEFAULT sudo apt-get install git"
            sudo apt-get install git
        elif [ -f /etc/debian_version ] ; then
            echo -e "$LIGHT_RED[+]$DEFAULT sudo apt-get install git"
            sudo apt-get install git
        elif [[ -d /etc/linuxmint ]]; then
            echo -e "$LIGHT_RED[+]$DEFAULT sudo apt-get install git"
            sudo apt-get install git
        elif [ -f /etc/fedora-release ] ; then
            echo -e "$LIGHT_RED[+]$DEFAULT sudo yum install git"
            sudo yum install git
        elif [[ -f /etc/redhat-release ]]; then
            echo -e "$LIGHT_RED[+]$DEFAULT sudo yum install git"
            sudo yum install git
        elif [[ -f /etc/arch-release ]]; then
            echo -e "$LIGHT_RED[+]$DEFAULT sudo pacman install git"
            sudo pacman install git
        elif [[ -r /etc/gentoo-release ]]; then
            echo -e "$LIGHT_RED[+]$DEFAULT sudo merge git"
            sudo merge git
        fi
    }
}


is_loic_git()
{
    [[ -d .git ]] && grep -q LOIC .git/config
}


is_loic() {
    is_loic_git ||
    {
        [[ -d LOIC ]] && cd LOIC && is_loic_git
    }
}

get_loic() {
    ensure_git
    if ! is_loic ; then
        echo -ne "$LIGHT_RED[+]$DEFAULT git init"
        git init
        echo -e "$LIGHT_RED[+]$DEFAULT git clone $GIT_REPO -b $GIT_BRANCH"
        git clone $GIT_REPO -b $GIT_BRANCH
    fi
}

compile_loic() {
    get_loic
    if ! is_loic ; then
        echo -e "$LIGHT_RED[-]$DEFAULT Error: You are not in a LOIC repository"
        exit 1
    else
        if [ -f /etc/lsb-release ] ; then
            echo -e "$LIGHT_RED[+]$DEFAULT monodevelop and liblog4net-cil-dev not found! Attempting to install..."
            sudo apt-get install monodevelop liblog4net-cil-dev
        elif [ -f /etc/fedora-release ] ; then
            echo -e "$LIGHT_RED[+]$DEFAULT mono-basic, mono-devel, monodevelop and mono-tools not found! Attempting to install..."
            sudo yum install mono-basic mono-devel monodevelop mono-tools
        elif [ -f /etc/debian_version ] ; then
            echo -e "$LIGHT_RED[+] monodevelop and liblog4net-cil-dev not found! Attempting to install..."
            sudo apt-get install monodevelop liblog4net-cil-dev
        fi
    fi
    mdtool build
}

run_loic() {
    is_loic
    if [[ ! -e bin/Debug/LOIC.exe ]] ; then
        compile_loic
    fi
    type -P mono &>/dev/null ||
    {
        echo -e "$LIGHT_RED[+]$DEFAULT mono-runtime not found! Attempting to install..."
        if [ -f /etc/lsb-release ] ; then
            sudo apt-get install mono-runtime
        elif [ -f /etc/fedora-release ] ; then
            sudo yum install mono-runtime
        elif [ -f /etc/debian_version ] ; then
            sudo apt-get install mono-runtime
        fi
    }
    mono bin/Debug/LOIC.exe
}

update_loic() {
    ensure_git
    if is_loic ; then
        git pull --rebase
        compile_loic
    else
        echo -e "$LIGHT_RED[-]$DEFAULT Error: You are not in a LOIC repository"
    fi
}

case $1 in
    compile)
        compile_loic
        ;;
    update)
        update_loic
        ;;
    run)
        run_loic
        ;;
    *)
        usage
        ;;
esac
