#!/bin/sh
#functions, copy and paste them in your own scripts

#https://github.com/chilicuil/learn/blob/master/sh/lib
#if you have more or can improve the current ones please send your push request!

#new functions:
#[+] must be self contained, with no dependencies in other functions
#[+] can depend on exotic cli commands
#[+] must follow general style (read guideline.md) and comply with POSIX sh
#[+] must no print errors, use return instead
#[+] must provide an example after the definition of the function
#[+] must provide at least 1 unit test (tests/lib.db)

_abs()
{   #return the absolute value of the argument, or 1 on failure
    [ -z "${1}" ] && return 1
    printf "%s\\n" "${1}" | grep -v "[^0-9-]" >/dev/null || return 1
    printf "%s" "${1}" | awk '{ print ($1 >= 0) ? $1 : 0 - $1}'
}
#==================================================== Example ====
#_abs -2 #print 2
#_abs 2  #print 2
#=================================================================

_aptproxy()
{   #test if an apt proxy exist on the local network
    #return 0 on sucess, 1 otherwise
    avahi-browse -a  -t | grep apt-cacher-ng >/dev/null && return 0
    return 1
}
#==================================================== Example ====
#if ! _aptproxy; then
    #printf "%s\\n" "no apt proxy was found, setting up one ..."
#fi
#=================================================================

_arch()
{   #check system arch, return 64|32 (32 by default)
    if [ -z "${MACHTYPE}" ]; then
        _arch__arch="$(uname -m)"
    else
        _arch__arch="$(printf "%s" "${MACHTYPE}" | cut -d- -f1)"
    fi

    case "${_arch__arch}" in
        x86_64) _arch__arch="64" ;;
        *)      _arch__arch="32" ;;
    esac

    printf "%s" "${_arch__arch}"
}
#==================================================== Example ====
#arch="$(_arch)"
#[ "${arch}" -eq "32" ] && command32 || command64
#=================================================================

_basename()
{   #basename portable version
    [ -z "${1}" ] && return 1 || _basename__name="${1}"
    [ -z "${2}" ] || _basename__suffix="${2}"
    case "${_basename__name}" in
        /*|*/*) _basename__name="$(expr "${_basename__name}" : '.*/\([^/]*\)')" ;;
    esac

    if [ -n "${_basename__suffix}" ] && [ "${#_basename__name}" -gt "${#2}" ]; then
        if [ X"$(printf "%s" "${_basename__name}" | cut -c"$((${#_basename__name} - ${#_basename__suffix} + 1))"-"${#_basename__name}")" \
           = X"$(printf "%s" "${_basename__suffix}")" ]; then
            _basename__name="$(printf "%s" "${_basename__name}" | cut -c1-"$((${#_basename__name} - ${#_basename__suffix}))")"
        fi
    fi

    printf "%s" "${_basename__name}"
}
#==================================================== Example ====
#_basename /path/file #print file
#=================================================================

_bbasename()
{   #alternative basename portable version, faster! but with possible drawbacks
    [ -z "${1}" ] && return 1 || _bbasename__name="${1}"
    [ -z "${2}" ] || _bbasename__suffix="${2}"
    case "${_bbasename__name}" in
        /*|*/*) _bbasename__name="${_bbasename__name##*/}"
    esac

    if [ -n "${_bbasename__suffix}" ] && [ "${#_bbasename__name}" -gt "${#2}" ]; then
        _bbasename__name="${_bbasename__name%$_bbasename__suffix}"
    fi

    printf "%s" "${_bbasename__name}"
}
#==================================================== Example ====
#_bbasename /path/file #print file
#=================================================================

_decode64()
{   #decode a string in base64
    [ -z "${1}" ] && return 1
    printf "%s\\n" "${1}" | openssl enc -base64 -d
}
#==================================================== Example ====
#string="$(_decode64 "${string}")"
#[ -z "${string}" ] && printf "%s\\n" "fail, empty string"
#=================================================================

_die()
{   # exit execution after printing a message
    [ -z "${1}" ] && return 1
    printf "%b\\n" "$(expr "${0}" : '.*/\([^/]*\)'): ${*}" >&2
    exit 1
}
#==================================================== Example ====
#[ -z "${var}" ] && _die "error msg"
#=================================================================

_dirname()
{   #return string containing dirname on success, 1 on failure
    [ -z "${1}" ] && return 1

    case "${1}" in
        /*|*/*) #http://www.linuxselfhelp.com/gnu/autoconf/html_chapter/autoconf_10.html
            _dirname__dir=$(expr "x${1}" : 'x\(.*\)/[^/]*' \| '.'      : '.')
            printf "%s\\n" "${_dirname__dir}"
            ;;
        *) printf "%s\\n" ".";;
    esac
}
#==================================================== Example ====
#_dirname /path/file #print /path
#=================================================================

_distro()
{   #return distro name in lower string
    _distro__DIST_INFO="/etc/lsb-release"
    if [ -r "${_distro__DIST_INFO}" ]; then
        . "${_distro__DIST_INFO}"
    fi

    if [ -z "${DISTRIB_ID}" ]; then
        _distro__DISTRIB_ID="Unknown";
        if [ -f /etc/arch-release ]; then
            _distro__DISTRIB_ID="Arch"
        elif [ -r /etc/knoppix-version ]; then
            _distro__DISTRIB_ID="Knoppix"
        elif [ -r /etc/sidux-version ]; then
            _distro__DISTRIB_ID="Sidux"
        elif [ -r /etc/debian_version ]; then
            _distro__DISTRIB_ID="Debian"
        elif [ -r /etc/issue ]; then
            _distro__DISTRIB_ID="$(awk '{print $1}' /etc/issue.net)"
            if [ X"${_distro__DISTRIB_ID}" = X"Ubuntu" ]; then
                _distro__DISTRIB_ID="Ubuntu"
            fi
        elif [ -r /etc/gentoo-release ]; then
            _distro__DISTRIB_ID="Gentoo"
        elif [ -f /etc/lfs-version ]; then
            _distro__DISTRIB_ID="LFS"
        elif [ -r /etc/pclinuxos-release ]; then
            _distro__DISTRIB_ID="PCLinuxOS"
        elif [ -f /etc/mandriva-release ] || [ -f /etc/mandrake-release ]; then
            _distro__DISTRIB_ID="Mandriva"
        elif [ -f /etc/redhat-release ]; then
            _distro__DISTRIB_ID="RedHat"
        elif [ -f /etc/fedora-release ]; then
            _distro__DISTRIB_ID="Fedora"
        elif [ -r /etc/vector-version ]; then
            _distro__DISTRIB_ID="VectorLinux"
        elif [ -r /etc/slackware-version ]; then
            _distro__DISTRIB_ID="$(cat /etc/slackware-version)"
        elif [ -f /etc/release ]; then
            _distro__DISTRIB_ID="Solaris"
        elif [ -r /etc/SuSE-release ]; then
            _distro__DISTRIB_ID="$(grep -i suse /etc/SuSE-release)"
        elif [ -f /etc/yellowdog-release ]; then
            _distro__DISTRIB_ID="YellowDog Linux"
        elif [ -f /etc/zenwalk-version ]; then
            _distro__DISTRIB_ID="Zenwalk"
        fi
        printf "%s\\n" "${_distro__DISTRIB_ID}" | \
            tr 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' 'abcdefghijklmnopqrstuvwxyz'
    else
        printf "%s\\n" "${DISTRIB_ID}" | \
            tr 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' 'abcdefghijklmnopqrstuvwxyz'
    fi
}
#==================================================== Example ====
#distro="$(_distro)"
#=================================================================

_echo()
{   #safe echo, http://www.etalabs.net/sh_tricks.html
    fmt=%s end=\\n IFS=" "

    while [ "${#}" -gt "1" ] ; do
        case "${1}" in
            [!-]*|-*[!ne]*) break ;;
            *ne*|*en*) fmt=%b end= ;;
            *n*) end= ;;
            *e*) fmt=%b ;;
        esac
        shift
    done

    printf "${fmt}${end}" "${*}"
}
#==================================================== Example ====
#_echo 'Hello World!' #print Hello World!
#=================================================================

_encode64()
{   #encode a string in base64
    [ -z "${1}" ] && return 1
    printf "%s\\n" "${1}" | openssl enc -base64
}
#==================================================== Example ====
#string="$(_encode64 "${string}")"
#=================================================================

_ensurecron()
{   #adds cron job, returns 1 on error
    [ -z "${1}" ] && return 1
    _ensurecron__exist="$(crontab -l 2>/dev/null | awk -v p="${1}" '{ if ($0 == p) {print p}}')"
    [ -n "${_ensurecron__exist}" ] && return 0
    ( crontab -l 2>/dev/null; printf "%s\\n" "${1}" ) | crontab -
}
#==================================================== Example ====
#_ensurecron "* * * * * /path/task"
#=================================================================

_user()
{   #test if an user exists on the system
    #return 0 on sucess, 1 otherwise
    [ -z "${1}" ] && return 1
    if id -u "${1}" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}
#==================================================== Example ====
#if _user user; then
    #printf "%s\\n" "user exists"
#fi
#=================================================================

_getfirstvalue()
{   #returns first value that is non-empty
    for _getfirstvalue__param; do
        if [ ! -z "${_getfirstvalue__param}" ]; then
            printf "%s\\n" "${_getfirstvalue__param}"
            return 0
        fi
    done
    return 1
}
#==================================================== Example ====
#EDITOR="$(_getfirstvalue "$VISUAL" "$EDITOR" vi)"
#=================================================================

_getfs()
{   #returns file system detected or 1 on failure
    [ -z "${1}" ] && return 1
    udevadm info -q all -n "${1}" | awk -F"=" '/ID_FS_TYPE/ {print $2 }'
}
#==================================================== Example ====
#_getfs /dev/sda1 #print "ext4" or the format found
#=================================================================

_getpasswd()
{   #define vars as passwords
    if [ -n "${1}" ]; then
        _getpasswd__option="$(printf "%s\\n" "${1}" | tr '[:upper:]' '[:lower:]')"
        printf "%s" "Enter your ${_getpasswd__option} password: "
        stty -echo
        read ${_getpasswd__option}passwd
        stty echo
        printf "\\n"
    else
        printf "%s" "Enter your password: "
        stty -echo
        read passwd
        stty echo
        printf "\\n"
    fi
}
#==================================================== Example ====
#_getpasswd
#printf "%s\\n" "${passwd}"
#_getpasswd config
#printf "%s\\n" "${configpasswd}"
#=================================================================

_getuuid()
{   #returns a uuid or 1 on failure
    [ -z "${1}" ] && return 1
    udevadm info -q all -n "${1}" | awk -F"/" '/^S.*uuid.*/ {print $3}'
}
#==================================================== Example ====
#_getuuid /dev/sda1 #print "793e9a6d-d545-46f0-ac9c-49071c450b62"
#=================================================================

_internet()
{   #check for internet connection, return 0 on success, 1 otherwise
    wget --tries=3 --timeout=5 http://www.google.com -O /tmp/index.google > /dev/null 2>&1
    if [ -s /tmp/index.google ]; then
        rm -rf /tmp/index.google
        return 0
    else
        rm -rf /tmp/index.google
        return 1
    fi
}
#==================================================== Example ====
#if ! _internet; then
    #printf "%s\\n" \
    #"You must have an Internet connection to run this script"
    #exit 1
#fi
#=================================================================

_alphanum()
{ #check for alphanum strings
  # return 0 if all upper+lower+digits, 1 otherwise

  # Remove all unacceptable chars
  [ -z "${1}" ] && return 1
  _alphanum__compressed="$(printf "%s" "${1}" | \
                              sed -e 's:[^[:alnum:]]::g')"

  [ X"${_alphanum__compressed}" = X"${1}" ] && return 0 || return 1
}
#==================================================== Example ====
#printf "%s" "Enter input: "
#read input
#if ! _alphanum "${input}" ; then
    #printf "%s\\n" "Your input must consist of only letters and numbers." >&2
    #exit 1
#else
    #printf "%s\\n" "Input is valid."
#fi
#exit 0
#=================================================================

_empty()
{  #detect if arg is an empty file, returns 0 on sucess, 1 otherwise
    [ -z "${1}" ] && return 1
    if [ -f "${1}" ] && [ X"$(wc -c "${1}" | cut -d" " -f1)" = X"0" ]; then
        return 0
    else
        return 1
    fi
}
#==================================================== Example ====
#if _empty /path/file; then
    #printf "%s\\n" "/path/file is empty"
#else
    #printf "%s\\n" "/path/file is not empty"
#fi
#=================================================================

_livecd()
{   #detect a livecd system, return 0 on success, 1 otherwise
    grep boot=live /proc/cmdline >/dev/null && return 0
    grep boot=casper /proc/cmdline >/dev/null && return 0
    return 1
}
#==================================================== Example ====
#if _livecd ; then
    #printf "%s\\n" "Live cd detected"
#else
    #printf "%s\\n" "Non LiveCd detected"
#fi
#=================================================================

_newer()
{   #compare the dates of two files, return true (0) if file1 has
    #been modified more recently otherwise 1

    [ "${#}" -ne "2" ] && return 1

    if [ ! -f "${1}" ] || [ ! -f "${2}" ]; then
        return 1
    fi

    if [ -n "$(find "${1}" -newer "${2}" -print)" ]; then
        return 0
    else
        return 1
    fi
}
#==================================================== Example ====
#if _newer 1stfile 2ndfile; then
    #printf "%s\\n" "1stfile is newer"
#else
    #printf "%s\\n" "2ndfile is newer"
#fi
#=================================================================

_num()
{   #look for a number, returns 0 on success, 1 otherwise
    [ -z "${1}" ] && return 1
    printf "%s\\n" "${@}" | grep -v "[^0-9]" >/dev/null
}
#==================================================== Example ====
#printf "%s" "Enter input: "
#read input
#if ! _num "${input}" ; then
    #printf "%s\\n" "Your input must consist of only numbers." >&2
    #exit 1
#else
    #printf "%s\\n" "Input is valid."
#fi
#exit 0
#=================================================================

_lock()
{   #locks the execution of a program, it should be used at the
    #beggining of it, exit on failure
    exec 9>/tmp/$(expr "${1}" : '.*/\([^/]*\)').lock #verify only one instance is running
    [ X"${LOGNAME}" = X"root" ] && chmod 666 /tmp/"$(expr "${1}" : '.*/\([^/]*\)')".lock
    if ! flock -n 9  ; then         #http://mywiki.wooledge.org/BashFAQ/045
        printf "%s\\n" "$(expr "${1}" : '.*/\([^/]*\)'): another instance is running";
        exit 1
    fi
}
#==================================================== Example ====
#_lock "${0}" #locks script till finish
#=================================================================

_notify()
{   #output messages through the notification system, prints to
    #stdout in the worst escenario
    [ -z "${1}" ] && return 1
    if [ X"${TERM}" = X"linux" ] || [ -z "${TERM}" ]; then
        kill -9 $(pgrep notify-osd) >/dev/null 2>&1
        if ! DISPLAY=:0 notify-send -t 1000 "${1}"  "${2}"; then
            if command -v "gxmessage" 2>/dev/null; then
                font="Monaco 9"
                gxmessage "${font:+-fn "$font"}" "${1} ${2}" "ok"
            else
                font="fixed"
                xmessage "${font:+-fn "$font"}" "${1} ${2}" "ok"
            fi
        fi
    else
        if [ -z "${2}" ]; then
            printf "%s\\n" "${1}"
        else
            printf "%s: %s\\n" "${1}" "${2}"
        fi
    fi
}
#==================================================== Example ====
#_notify "You need html2text" "$ sudo apt-get install html2text"
#=================================================================

_printfc()
{   #print command
    [ -z "${1}" ] && return 1
    printf "%s\\n" "    $ ${*}"
}
#==================================================== Example ====
#_printfc "command"
#=================================================================

_printfl()
{   #print lines
    _printfl__max_len="80"
    if [ -n "${1}" ]; then
        _printfl__word_len="$((${#*} + 2))"
        _printfl__sub="$((${_printfl__max_len} - ${_printfl__word_len}))"
        _printfl__half="$((${_printfl__sub} / 2))"
        _printfl__other_half="$((${_printfl__sub} - ${_printfl__half}))"
        printf "%b" "\033[1m" #white strong
        printf '%*s' "${_printfl__half}" '' | tr ' ' -
        printf "%b" "\033[7m" #white background
        printf " %s " "${*}"
        printf "%b" "\033[0m\033[1m" #white strong
        printf '%*s' "${_printfl__other_half}" '' | tr ' ' -
        printf "%b" "\033[0m" #back to normal
        printf "\\n"
    else
        printf "%b" "\033[1m" #white strong
        printf '%*s' "${_printfl__max_len}" '' | tr ' ' -
        printf "%b" "\033[0m" #back to normal
        printf "\\n"
    fi
}
#==================================================== Example ====
#_printfl "Title"
#_printfl #prints a line
#=================================================================

_printfs()
{   #print step
    [ -z "${1}" ] && return 1
    printf "%s\\n" "[+] ${*}"
}
#==================================================== Example ====
#_printfs "Subtitle"
#=================================================================

_printtime()
{  #format seconds to a pretty string
    [ -z "${1}" ] && return 1
    printf "%s\\n" "${1}" | grep -v "[^0-9]" >/dev/null || return 1;

    _printtime__num="${1}"
    _printtime__min="0"
    _printtime__hour="0"
    _printtime__day="0"
    if [ "${_printtime__num}" -gt "59" ]; then
        _printtime__sec="$((${_printtime__num} % 60))"
        _printtime__num="$((${_printtime__num} / 60))"
        if [ "${_printtime__num}" -gt "59" ]; then
            _printtime__min="$((${_printtime__num} % 60))"
            _printtime__num="$((${_printtime__num} / 60))"
            if [ "${_printtime__num}" -gt "23" ]; then
                _printtime__hour="$((${_printtime__num} % 24))"
                _printtime__day="$((${_printtime__num} / 24))"
            else
                _printtime__hour="${_printtime__num}"
            fi
        else
            _printtime__min="${_printtime__num}"
        fi
    else
        _printtime__sec="${_printtime__num}"
    fi
    printf "%s\\n" \
    ""${_printtime__day}"d "${_printtime__hour}"h "${_printtime__min}"m "${_printtime__sec}"s"
}
#==================================================== Example ====
#SECONDS="12345"
#_printtime "${SECONDS}" #prints "0d 3h 25m 49s"
#=================================================================

_privport()
{   #check if port is a num and if it's privated (<1025), returns 0 on success, 1 otherwise
    [ -z "${1}" ] && return 1

    printf "%s\\n" "${1}" | grep -v "[^0-9]" >/dev/null
    if [ "${?}" -eq "0" ]; then
        [ "${1}" -gt "0" ] && [ "${1}" -lt "1025" ] && return 0 || return 1
    else
        return 1
    fi
}
#==================================================== Example ====
#printf "%s" "Enter port: "
#read port
#if _privport "${port}" ; then #priv ports requires root
    #sudo script "${port}"
#else
    #script "${port}"
#fi
#=================================================================

_realpath()
{   # print the absolute path
    _realpath__success="true"
    _realpath__path="${1}"

    # make sure the string isn't empty as that implies something in further logic
    if [ -z "${_realpath__path}" ]; then
        _realpath__success="false"
    else
        # start with the file name (sans the trailing slash)
        _realpath__path="${_realpath__path%/}"

        # if we stripped off the trailing slash and were left with nothing, that means we're in the root directory
        [ -z "${_realpath__path}" ] && _realpath__path="/"

        # get the basename of the file (ignoring '.' & '..', because they're really part of the path)
        _realpath__file_basename="${_realpath__path##*/}"
        if [ X"${_realpath__file_basename}" = X"." ] || [ X"${_realpath__file_basename}" = X".." ]; then
            _realpath__file_basename=""
        fi

        # extracts the directory component of the full path, if it's empty then assume '.' (the current working directory)
        _realpath__directory="${_realpath__path%${_realpath__file_basename}}"
        [ -z "${_realpath__directory}" ] && _realpath__directory="."

        # attempt to change to the directory
        if ! \cd "${_realpath__directory}" >/dev/null 2>/dev/null; then
            _realpath__success="false"
        fi

        if "${_realpath__success}"; then
            # does the filename exist?
            if [ -n "${_realpath__file_basename}" ] && [ ! -e "${_realpath__file_basename}" ]; then
                _realpath__success="false"
            fi

            # get the absolute path of the current directory & change back to previous directory
            _realpath__abs_path="$(pwd -P)"
            \cd "-" >/dev/null 2>/dev/null

            # Append base filename to absolute path
            if [ X"${_realpath__abs_path}" = X"/" ]; then
                _realpath__abs_path="${_realpath__abs_path}${_realpath__file_basename}"
            else
                _realpath__abs_path="${_realpath__abs_path}/${_realpath__file_basename}"
            fi

            printf "%s\\n" "${_realpath__abs_path}"
        fi
    fi

    "${_realpath__success}"
}
#==================================================== Example ====
#relative_path="../Shared/"
#absolute_path="$(_realpath "$relative_path")"
#if [ "${?}" -eq "0" ]; then
	#printf "%s\\n" "absolute_path = ${absolute_path}"
#else
	#printf "%s\\n" "'${relative_path}' does not exist!"
#fi
#=================================================================

_rmcron()
{   #remove cron jobs, returns 1 on failure
    [ -z "${1}" ] && return 1
    crontab -l | grep -v "${1}" | crontab
}
#==================================================== Example ====
#_rmcron "pattern"
#=================================================================

_str2lower()
{   #convert a string to lower string
    [ -z "${1}" ] && return 1
    printf "%s\\n" "${@}" | \
    tr 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' 'abcdefghijklmnopqrstuvwxyz'
    # tr '[:upper:]' '[:lower:]'
}
#==================================================== Example ====
#hello="HELLO WORLD"
#hello="$(_str2lower "${hello}")"
#printf "%s\\n" "${hello}"   #prints "hello world"
#=================================================================

_str2upper()
{   #convert a string to lower string
    [ -z "${1}" ] && return 1
    printf "%s\\n" "${@}" | \
    tr 'abcdefghijklmnopqrstuvwxyz' 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    # tr '[:upper:]' '[:lower:]'
}
#==================================================== Example ====
#hello="hello world"
#hello="$(_str2upper "${hello}")"
#printf "%s\\n" "${hello}"   #prints "HELLO WORLD"
#=================================================================

_strdiff()
{   #prints the diff of two strings
    [ -z "${1}" ] && return 1
    [ -z "${2}" ] && return 1

    mkfifo "${$}".fifo1 && mkfifo "${$}".fifo2
    if [ -e "${$}".fifo1 ] && [ -e "${$}".fifo2 ]; then
        _strdiff__1st_string="$(printf "%s" "${1}" | sed 's: :\n:g')"
        _strdiff__2nd_string="$(printf "%s" "${2}" | sed 's: :\n:g')"
        printf "%s\\n" "${_strdiff__1st_string}" > "${$}".fifo1 &
        printf "%s\\n" "${_strdiff__2nd_string}" > "${$}".fifo2 &
        _strdiff__diff="$(awk 'NR == FNR { A[$0]=1; next } !A[$0]' "${$}".fifo1 "${$}".fifo2)"
        rm -rf "${$}".fifo1; rm -rf "${$}".fifo2
        printf "%s\\n" "${_strdiff__diff}"
    else
        return 1
    fi
}
#==================================================== Example ====
#hello="hello world"
#world="world"
#diff="$(_strdiff "${world}" "${hello}")"
#printf "%s\\n"  "${diff}"   #prints "hello"
#=================================================================

_strlen()
{   #print the length of a string, return 1 on failure
    [ -z "${1}" ] && return 0
    printf "%s\\n" "${#1}"
}
#==================================================== Example ====
#_strlen "hello world!" #returns "12"
#=================================================================

_stronlyduplicates()
{   #print duplicated strings, return 1 on failure
    [ -z "${1}" ] && return 1
    [ -z "${2}" ] && return 1
    printf "%s\\n" ${@} | awk 'x[$0]++'
}
#==================================================== Example ====
#hello="hello world"
#bye="bye world"
#world=$(_stronlyduplicates "${hello}" "${bye}")
#printf "%s\\n"  "${world}"   #prints "world"
#=================================================================

_strreplace()
{   #replace param in string, return 1 on failure
    [ -z "${1}" ] && return 1
    [ -z "${2}" ] && return 1
    [ -z "${3}" ] && return 1
    _strreplace__replace=$(printf "%s" "${1}" | sed -e "s:${2}:${3}:g")
    printf "%s" "${_strreplace__replace}"
}
#==================================================== Example ====
#hello="hello world"
#bye="$(_strreplace "${hello}" "hello" "bye")"
#printf "%s\\n" "${bye}"   #prints "bye world"
#=================================================================

_strunique()
{   #print unique strings, return 1 on failure
    [ -z "${1}" ] && return 1
    [ -z "${2}" ] && return 1
    _strunique__unique="$(printf "%s\\n" ${@} | \
                            awk '!($0 in x) {x[$0];print}')"  #faster
    #printf "%s\\n" $@ | awk '!x[$0]++'
    _strunique__unique="$(printf "%s" "${_strunique__unique}" | \
                            tr '\n' ' ')"
    printf "%s\\n" "${_strunique__unique}"
}
#==================================================== Example ====
#hello="hello world"
#bye="bye world"
#world="$(_strunique "${hello}" "${bye}")"
#printf "%s\\n"  "${world}"   #prints "hello world bye"
#=================================================================

_substr()
{   #print a substring
    [ -z "${1}" ] && return 1
    [ -z "${2}" ] && return 1

    if [ "${2}" -lt "0" ]; then
        _substr__start="$((${#1} + ${2}))"
    else
        _substr__start="${2}"
    fi

    if [ -z "${3}" ]; then
        _substr__len="${#1}"
    else
        if [ "${3}" -lt "0" ]; then
            _substr__len="$((${#1} + ${3}))"
        else
            _substr__len="$((${_substr__start} + ${3}))"
        fi
    fi

    _substr__start="$((${_substr__start} + 1))"

    [ "${_substr__start}" -lt "0" ] && return 1
    [ "${_substr__start}" -gt "${_substr__len}" ] && return 1

    printf "%s\\n" "${1}" | cut -c"${_substr__start}"-"${_substr__len}"
}
#==================================================== Example ====
#_substr "abcdef" 0 4 #print "abcd"
#=================================================================

_uploadimg()
{   #upload images, return url on success, 1 otherwise
    #requires curl, and optionally xclip
    [ -z "${1}" ] && return 1

    for _upload_img__param; do
        if [ -f "${_upload_img__param}" ] ; then
            case "${_upload_img__param}" in
                *.jpg|*.JPG|*.jpeg|*.png|*.PNG)
                    if command -v "xclip" >/dev/null 2>&1; then
                        curl -s -F "image=@${_upload_img__param}"                   \
                            -F "key=486690f872c678126a2c09a9e196ce1b"          \
                            http://imgur.com/api/upload.xml |                  \
                            egrep -o "<original_image>(.)*</original_image>" | \
                            egrep -o "http://i.imgur.com/[^<]*" | xclip -selection clipboard; xclip -o -selection clipboard
                    else
                        curl -s -F "image=@${_upload_img__param}"                   \
                            -F "key=486690f872c678126a2c09a9e196ce1b"          \
                            http://imgur.com/api/upload.xml |                  \
                            egrep -o "<original_image>(.)*</original_image>" | \
                            egrep -o "http://i.imgur.com/[^<]*"
                    fi ;;
                *) return 1
            esac
        else
            return 1
        fi
    done
}
#==================================================== Example ====
#url="$(_upload_img file.png)"
#[ -z "${url}" ] && printf "%s\\n" "Error"
#=================================================================

_unprintf()
{   #unprint sentence
    [ -z "${1}" ] && return 1
    _unprintf__word_len="${#1}"
    _unprintf__i="0"
    while [ "${_unprintf__i}" -lt "${_unprintf__word_len}" ]; do
        _unprintf__i="$((${_unprintf__i} + 1))"
        printf "%b" "\b"
    done
}
#==================================================== Example ====
#printf "hello world"
#sleep 1s
#_unprintf "hello world"
#prinf "bye world"
#=================================================================

_validnetinterface()
{   #return 0 if parameter is a valid network interface, 1 otherwise
    [ -z "${1}" ] && return 1
    ip addr show | grep "${1}": >/dev/null && return 0
    return 1
}
#===================================================== Example ====
#if ! _validnetinterface "${interface}"; then
    #printf "%s\\n" "not valid interface ${interface}"
#fi
#=================================================================

_validip4()
{   #return 0 if parameter is a valid ip4 address, non-zero otherwise
    #https://groups.google.com/forum/#!original/comp.unix.shell/NDu-kAL5cHs/7Zpc6Q2Hu5YJ
    [ -z "${1}" ] && return 1

    case "${*}" in
        ""|*[!0-9.]*|*[!0-9]) return 1 ;;
    esac

    OLDIFS="${IFS}"
    IFS="."
    set -- ${*}
    IFS="${OLDIFS}"

    [ "${#}" -eq "4" ] &&
        [ "${1:-666}" -le "255" ] && [ "${2:-666}" -le "255" ] &&
        [ "${3:-666}" -le "255" ] && [ "${4:-666}" -le "254" ]
}
#===================================================== Example ====
#if ! _validip4 "${ip}"; then
    #printf "%s\\n" "not valid ip: ${ip}"
#fi
#=================================================================

_validmail()
{   #verify if an email is valid, return 1 on failure
    [ -z "${1}" ] && return 1

    case "${1}" in
        *@*.*) return 0 ;;
        *)   return 1 ;;
    esac
}
#===================================================== Example ====
#if ! _validmail "${address}"; then
    #printf "%s\\n" "not valid email address: ${address}"
#fi
#=================================================================

_verbose()
{   #print a message when in verbose mode
    [ -z "${1}" ] && return 1
    [ -n "${VERBOSE}" ] && printf "%s\\n" "${*}"
}
#==================================================== Example ====
#_verbose "hello"           # print nothing
#VERBOSE=1 _verbose "hello" # print verbose
#=================================================================

_whereis()
{   #whereis portable version
    [ -z "${1}" ] && return 1
    if ! command -v "${1}" 2>/dev/null; then
        return 1
    fi
}
#==================================================== Example ====
#if _whereis command >/dev/null; then
    #command
#fi
#=================================================================

_xmessage()
{   #prints a message using xmessage || gxmessage
    [ -z "${1}" ] && return 1
    XMESSAGE="$(command -v gxmessage 2>/dev/null)" || XMESSAGE="$(command -v xmessage 2>/dev/null)"
    MESSAGE="$(expr "${0}" : '.*/\([^/]*\)'): ${*}"
    printf "%s\\n" "${MESSAGE}" | fold -s -w ${COLUMNS:-80}
    if [ -n "${DISPLAY}" ] && [ -n "${XMESSAGE}" ]; then
        printf "%s\\n" "${MESSAGE}" | fold -s -w ${COLUMNS:-80} | "${XMESSAGE}" -center -file -
    fi
}
#==================================================== Example ====
#_xmessage "Notice ..." #show a dialog with notice
#=================================================================
