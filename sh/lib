#!/bin/sh
#shell functions, copy and paste in your own scripts

#new functions:
#[+] must be self contained, with no dependencies in other functions
#[+] must follow general style (read guideline.md) and comply with POSIX sh
#[+] must no print errors, use return instead
#[+] can depend on exotic cli commands
#[+] must provide an example after the definition of the function
#[+] must provide at least one unit test (tests/lib.db)

_1stchar() { #return first char of a string
    [ -z "${1}" ] && return 1
    _1stchar__substr="${1#?}"
    printf "%s\\n" "${1%$_1stchar__substr}"
}
#==================================================== Example ====
#_1stchar test #print 't'
#=================================================================

_1stletter_upper() { #return string with first char in upper case
    [ -z "${1}" ] && return 1
    _1stletter__substr="${1#?}"
    _1stletter__char="${1%$_1stletter__substr}"

    _1stletter__charupper="$(printf "%s\\n" "${_1stletter__char}" | \
        tr 'abcdefghijklmnopqrstuvwxyz' 'ABCDEFGHIJKLMNOPQRSTUVWXYZ')"

    printf "%s\\n" "${_1stletter__charupper}${_1stletter__substr}"
}
#==================================================== Example ====
#_1stletter_upper test #print 'Test'
#=================================================================

_1stletter_lower() { #return string with first char in lower case
    [ -z "${1}" ] && return 1
    _1stletter__substr="${1#?}"
    _1stletter__char="${1%$_1stletter__substr}"

    _1stletter__charlower="$(printf "%s\\n" "${_1stletter__char}" | \
        tr 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' 'abcdefghijklmnopqrstuvwxyz')"

    printf "%s\\n" "${_1stletter__charlower}${_1stletter__substr}"
}
#==================================================== Example ====
#_1stletter_lower Test #print 'test'
#=================================================================

_abs() { #return the absolute value of the argument, or 1 on failure
    case "${1}" in
        *[!0-9-]*|"") return 1 ;;
    esac

    printf "%s" "${1}" | awk '{ print ($1 >= 0) ? $1 : 0 - $1}'
}
#==================================================== Example ====
#_abs -2 #print 2
#_abs 2  #print 2
#=================================================================

_alphanum() { #check for alphanum strings
  [ -z "${1}" ] && return 1

  #remove unacceptable chars
  _alphanum__compressed="$(printf "%s" "${1}" | sed -e 's:[^[:alnum:]]::g')"
  [ X"${_alphanum__compressed}" = X"${1}" ]
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

_aptproxy() { #test if an apt proxy exist on the local network
    avahi-browse -a  -t | grep apt-cacher-ng >/dev/null && return 0
    return 1
}
#==================================================== Example ====
#if ! _aptproxy; then
    #printf "%s\\n" "no apt proxy was found, setting up one ..."
#fi
#=================================================================

_arch() { #check system arch, return 64|32 (32 by default)
    if [ -z "${MACHTYPE}" ]; then
        _arch__arch="$(uname -m)"
    else
        _arch__arch="$(printf "%s" "${MACHTYPE}" | cut -d- -f1)"
    fi

    case "${_arch__arch}" in
        x86_64) _arch__arch="64" ;;
             *) _arch__arch="32" ;;
    esac

    printf "%s" "${_arch__arch}"
}
#==================================================== Example ====
#arch="$(_arch)"
#[ "${arch}" -eq "32" ] && command32 || command64
#=================================================================

_basename() { #portable basename
    [ -z "${1}" ] && return 1 || _basename__name="${1%%/}"
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

_basename2() { #alternative portable basename, faster but with
               #possible drawbacks
    [ -z "${1}" ] && return 1 || _basename2__name="${1%%/}"
    [ -z "${2}" ] || _basename2__suffix="${2}"
    case "${_basename2__name}" in
        /*|*/*) _basename2__name="${_basename2__name##*/}"
    esac

    if [ -n "${_basename2__suffix}" ] && [ "${#_basename2__name}" -gt "${#2}" ]; then
        _basename2__name="${_basename2__name%$_basename2__suffix}"
    fi

    printf "%s" "${_basename2__name}"
}
#==================================================== Example ====
#_basename2 /path/file #print file
#=================================================================

_bytes2human() { #convert byte-count into human readable K|M|G|..
    [ -z "${1}" ] && return 1
    #is int?
    case "${1%.*}" in
        *[!0-9]*|"") return 1 ;;
    esac

    printf "%s" "${1}" | awk '{
        split( "B K M G T E P Y Z" , v );
        s=1; while($1>=1024) { $1/=1024; s++ }
        printf("%.2f %s\n", $1, v[s])}' | sed 's:\.00 ::;s:B::;s: ::'
}
#==================================================== Example ====
#_bytes2human 1024 #prints 1K
#=================================================================

_char2int() {
    [ -z "${1}" ] && return 1
    printf '%d' "'${*}"
}
#==================================================== Example ====
#num="$(_char2int a)"
#printf "%s\\n" "${num}" #prints 97
#=================================================================

_daemonize() { #daemonize an external command
    #http://blog.n01se.net/blog-n01se-net-p-145.html
    [ -z "${1}" ] && return 1
    (   # 1. fork, to guarantee the child is not a process
        # group leader, necessary for setsid) and have the
        # parent exit (to allow control to return to the shell)

        # 2. redirect stdin/stdout/stderr before running child
        [ -t 0 ] && exec  </dev/null
        [ -t 1 ] && exec  >/dev/null
        [ -t 2 ] && exec 2>/dev/null
        if ! command -v "setsid" >/dev/null 2>&1; then
            # 2.1 guard against HUP and INT (in child)
            trap '' 1 2
        fi

        # 3. ensure cwd isn't a mounted fs so it does't block
        # umount invocations
        cd /

        # 4. umask (leave this to caller)
        # umask 0

        # 5. close unneeded fds
        #XCU 2.7 Redirection says: open files are represented by
        #decimal numbers starting with zero. The largest possible
        #value is implementation-defined; however, all
        #implementations shall support at least 0 to 9, inclusive,
        #for use by the application.
        i=3; while [ "${i}" -le "9" ]; do
            eval "exec ${i}>&-"
            i="$(($i + 1))"
        done

        # 6. create new session, so the child has no
        # controlling terminal, this prevents the child from
        # accesing a terminal (using /dev/tty) and getting
        # signals from the controlling terminal (e.g. HUP, INT)
        if command -v "setsid" >/dev/null 2>&1; then
            exec setsid "$@"
        elif command -v "nohup" >/dev/null 2>&1; then
            exec nohup "$@" >/dev/null 2>&1
        else
            if [ ! -f "${1}" ]; then
                "$@"
            else
                exec "$@"
            fi
        fi
    ) &
    # 2.2 guard against HUP (in parent)
    if ! command -v "setsid" >/dev/null 2>&1 \ &&
       ! command -v "nohup"  >/dev/null 2>&1; then
        disown -h "${!}"
    fi
}
#==================================================== Example ====
#_daemonize /bin/sh /path/script #daemonize script
#kill -15 $(cat /var/run/script.pid #finish daemon
#=================================================================

_decode64() { #decode a base64 string
    [ ! -t 0 ] && set -- "${@}" "$(cat)"
    [ -z "${1}" ] && return 1
    if command -v "base64" >/dev/null 2>&1; then
        printf "%s\\n" "${@}" | base64 -d
    elif command -v "openssl" >/dev/null 2>&1; then
        printf "%s\\n" "${@}" | openssl enc -base64 -d
    elif command -v "awk" >/dev/null 2>&1 && (command -v "uudecode" || command -v "busybox") >/dev/null 2>&1; then
        if command -v "uudecode" >/dev/null 2>&1; then
            uudecode__bin="uudecode"
        elif command -v "busybox"  >/dev/null 2>&1; then
            uudecode__bin="busybox uudecode"
        fi
        _decode64_awk() { [ ! -t 0 ] && set -- "${@}" "$(cat)"
          [ -z "${1}" ] && return 1
          printf "%s\\n" "${@}" | sed 's/=//g' | (
            printf "begin 644 -\\n"; awk 'function _decode64_awk() {
              inp=1; out=""; while (getline) { for(i=1; i<=length($0); i++) {
                  c=substr(uu,index(b64,substr($0,i,1)),1);
                  inp++; out=(out c); if (inp==61) {
                    print "M" out; inp=1; out=""; }}}
              if (length(out)) { printf "%c", (32+3*length(out)/4); print out; }}
            BEGIN { b64="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
              uu="`!\"#$%&'\''()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_"
              _decode64_awk(); exit; }'
            printf "%s\\n%s\\n" '`' 'end' #'
          ) | $uudecode__bin
        }
        printf "%s\\n" "${@}" | _decode64_awk
    else
        _decode64_sh() { [ ! -t 0 ] && set -- "${@}" "$(cat)"
            _decode64_sh__b64='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
            _decode64_sh__n="0"; _decode64_sh__v="0"; _decode64_sh__args="$@"
            while [ "${_decode64_sh__args}" ]; do #process char by char
                _decode64_sh__char="${_decode64_sh__args%${_decode64_sh__args#?}}"
                case "${_decode64_sh__char}" in
                    '\n') continue ;;
                     '=') _decode64_sh__v="$(($_decode64_sh__v << 6))" ;;
                       *) _decode64_sh__char="${_decode64_sh__b64#*$_decode64_sh__char}"
                          _decode64_sh__char="$((${#_decode64_sh__b64}-${#_decode64_sh__char}))"
                          if [ "${_decode64_sh__char}" -eq "0" ]; then
                            [ X"${_decode64_sh__args}" = X"${_decode64_sh__char}" ] &&\
                                _decode64_sh__args='' || _decode64_sh__args="${_decode64_sh__args#?}"
                            continue
                          fi
                          _decode64_sh__v="$(($_decode64_sh__v << 6 | $_decode64_sh__char-1))"
                esac
                _decode64_sh__n="$(($_decode64_sh__n+1))"
                if [ "${_decode64_sh__n}" -eq "4" ]; then
                    _decode64_sh__s="16"; while [ "${_decode64_sh__s}" -gt "-1" ]; do
                        _decode64_sh__char="$(($_decode64_sh__v >> $_decode64_sh__s & 255))"
                        printf \\$(($_decode64_sh__char/64*100+$_decode64_sh__char%64/8*10+$_decode64_sh__char%8))
                        _decode64_sh__s="$(($_decode64_sh__s-8))"
                    done
                    _decode64_sh__v="0"; _decode64_sh__n="0"
                fi
                [ X"${_decode64_sh__args}" = X"${_decode64_sh__char}" ] &&\
                    _decode64_sh__args='' || _decode64_sh__args="${_decode64_sh__args#?}"
            done
        }
        printf "%s\\n" "${@}" | _decode64_sh
    fi
} # too hardcore for vim syntax`"
#==================================================== Example ====
#string="$(_decode64 "${string}")"
#[ -z "${string}" ] && printf "%s\\n" "fail, empty string"
#=================================================================

_die() { #exit execution after printing a message
    [ -z "${1}" ] && return 1
    printf "%b\\n" "$(expr "${0}" : '.*/\([^/]*\)'): ${*}" >&2
    exit 1
}
#==================================================== Example ====
#[ -z "${var}" ] && _die "error msg"
#=================================================================

_dirname() {
    #return string containing dirname on success, 1 on failure
    [ -z "${1}" ] && return 1

    #http://www.linuxselfhelp.com/gnu/autoconf/html_chapter/autoconf_10.html
    case "${1}" in
        /*|*/*) _dirname__dir=$(expr "x${1}" : 'x\(.*\)/[^/]*' \| '.' : '.')
                printf "%s\\n" "${_dirname__dir}" ;;
             *) printf "%s\\n" ".";;
    esac
}
#==================================================== Example ====
#_dirname /path/file #print /path
#=================================================================

_distro() { #return distro name in lower string
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

_echo() { #safe echo, http://www.etalabs.net/sh_tricks.html
    fmt=%s end=\\n IFS=" "

    while [ "${#}" -gt "1" ] ; do
        case "${1}" in
            [!-]*|-*[!ne]*) break    ;;
            *ne*|*en*) fmt=%b end="" ;;
            *n*) end="" ;;
            *e*) fmt=%b ;;
        esac
        shift
    done

    printf "${fmt}${end}" "${*}"
}
#==================================================== Example ====
#_echo 'Hello World!' #print Hello World!
#=================================================================

_empty() {
    #detect if arg is an empty file, returns 0 on sucess, 1 otherwise
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

_encode64() { #encode a base64 string
    [ ! -t 0 ] && set -- "${@}" "$(cat)"
    [ -z "${1}" ] && return 1
    if command -v "base64" >/dev/null 2>&1; then
        printf "%s\\n" "${@}" | base64
    elif command -v "openssl" >/dev/null 2>&1; then
        printf "%s\\n" "${@}" | openssl enc -base64
    else
        _encode64_sh() { #slow but quite portable
            [ ! -t 0 ] && set -- "${@}" "$(cat)"
            _od() {
                if command -v "od" >/dev/null 2>&1; then
                    od -v -t x1
                else
                    [ ! -t 0 ] && set -- "${@}" "$(cat)"
                    _od__O="0"; _od__W="16"; _od__args="$@"
                    while [ "${_od__args}" ]; do #process char by char
                        _od__char="${_od__args%${_od__args#?}}"
                        [ "$(($_od__O%$_od__W))" -eq "0" ] && printf '%07o' "${_od__O}"
                        printf ' %02x' "'${_od__char}"
                        _od__O="$(($_od__O+1))"
                        [ "$(($_od__O%$_od__W))" -eq "0" ] && printf "\\n"
                        [ X"${_od__args}" = X"${_od__char}" ] &&\
                            _od__args='' || _od__args="${_od__args#?}"
                    done
                    printf " 0a\\n"
                fi
            }
             __0='A';  __1='B';  __2='C';  __3='D';  __4='E';  __5='F';  __6='G';  __7='H';  __8='I';  __9='J';
            __10='K'; __11='L'; __12='M'; __13='N'; __14='O'; __15='P'; __16='Q'; __17='R'; __18='S'; __19='T';
            __20='U'; __21='V'; __22='W'; __23='X'; __24='Y'; __25='Z'; __26='a'; __27='b'; __28='c'; __29='d';
            __30='e'; __31='f'; __32='g'; __33='h'; __34='i'; __35='j'; __36='k'; __37='l'; __38='m'; __39='n';
            __40='o'; __41='p'; __42='q'; __43='r'; __44='s'; __45='t'; __46='u'; __47='v'; __48='w'; __49='x';
            __50='y'; __51='z'; __52='0'; __53='1'; __54='2'; __55='3'; __56='4'; __57='5'; __58='6'; __59='7';
            __60='8'; __61='9'; __62='+'; __63='/';
            printf "%s\\n" "${@}" | _od | {
                _encode64_sh__v="0"; _encode64_sh__w="0"; _encode64_sh__s="16"
                while read _encode64_sh__line; do
                    for _encode64_sh__word in ${_encode64_sh__line}; do
                        [ X"${#_encode64_sh__word}" = X"7" ] && continue
                        _encode64_sh__v="$((16#${_encode64_sh__word} << ${_encode64_sh__s} | ${_encode64_sh__v}))"
                        _encode64_sh__s="$((${_encode64_sh__s}-8))"
                        [ "${_encode64_sh__s}" -lt "0" ] || continue
                        _encode64_sh__s="18"; while [ "${_encode64_sh__s}" -ge "0" ]; do
                            case "$((${_encode64_sh__v} >> ${_encode64_sh__s} & 63))" in
                             0) printf "%s"  "${__0}" ;;  1) printf "%s"  "${__1}" ;;  2) printf "%s"  "${__2}" ;;
                             3) printf "%s"  "${__3}" ;;  4) printf "%s"  "${__4}" ;;  5) printf "%s"  "${__5}" ;;
                             6) printf "%s"  "${__6}" ;;  7) printf "%s"  "${__7}" ;;  8) printf "%s"  "${__8}" ;;
                             9) printf "%s"  "${__9}" ;; 10) printf "%s" "${__10}" ;; 11) printf "%s" "${__11}" ;;
                            12) printf "%s" "${__12}" ;; 13) printf "%s" "${__13}" ;; 14) printf "%s" "${__14}" ;;
                            15) printf "%s" "${__15}" ;; 16) printf "%s" "${__16}" ;; 17) printf "%s" "${__17}" ;;
                            18) printf "%s" "${__18}" ;; 19) printf "%s" "${__19}" ;; 20) printf "%s" "${__20}" ;;
                            21) printf "%s" "${__21}" ;; 22) printf "%s" "${__22}" ;; 23) printf "%s" "${__23}" ;;
                            24) printf "%s" "${__24}" ;; 25) printf "%s" "${__25}" ;; 26) printf "%s" "${__26}" ;;
                            27) printf "%s" "${__27}" ;; 28) printf "%s" "${__28}" ;; 29) printf "%s" "${__29}" ;;
                            30) printf "%s" "${__30}" ;; 31) printf "%s" "${__31}" ;; 32) printf "%s" "${__32}" ;;
                            33) printf "%s" "${__33}" ;; 34) printf "%s" "${__34}" ;; 35) printf "%s" "${__35}" ;;
                            36) printf "%s" "${__36}" ;; 37) printf "%s" "${__37}" ;; 38) printf "%s" "${__38}" ;;
                            39) printf "%s" "${__39}" ;; 40) printf "%s" "${__40}" ;; 41) printf "%s" "${__41}" ;;
                            42) printf "%s" "${__42}" ;; 43) printf "%s" "${__43}" ;; 44) printf "%s" "${__44}" ;;
                            45) printf "%s" "${__45}" ;; 46) printf "%s" "${__46}" ;; 47) printf "%s" "${__47}" ;;
                            48) printf "%s" "${__48}" ;; 49) printf "%s" "${__49}" ;; 50) printf "%s" "${__50}" ;;
                            51) printf "%s" "${__51}" ;; 52) printf "%s" "${__52}" ;; 53) printf "%s" "${__53}" ;;
                            54) printf "%s" "${__54}" ;; 55) printf "%s" "${__55}" ;; 56) printf "%s" "${__56}" ;;
                            57) printf "%s" "${__57}" ;; 58) printf "%s" "${__58}" ;; 59) printf "%s" "${__59}" ;;
                            60) printf "%s" "${__60}" ;; 61) printf "%s" "${__61}" ;; 62) printf "%s" "${__62}" ;;
                            63) printf "%s" "${__63}" ;; esac
                            #printf "%s" "${_encode64_sh__64:$((${_encode64_sh__v} >> ${_encode64_sh__s} & 63)):1}"
                            #printf "%s" "${_encode64_sh__64}" | cut -c$(($waa+1)) | tr -d '\n'
                            _encode64_sh__s="$((${_encode64_sh__s}-6))"; _encode64_sh__w="$((${_encode64_sh__w}+1))"
                            [ "${_encode64_sh__w}" -gt "75" ] && { printf "\\n"; _encode64_sh__w="0"; }
                        done
                    _encode64_sh__v="0"; _encode64_sh__s="16"
                    done
                done

                case "${_encode64_sh__s}" in
                    8) _encode64_sh__n="11" ;;
                    0) _encode64_sh__n="5"  ;;
                    *) _encode64_sh__n="0"  ;;
                esac

                [ X"${_encode64_sh__n}" = X"0" ] || {
                    _encode64_sh__s="18"; while [ "${_encode64_sh__s}" -gt "${_encode64_sh__n}" ]; do
                        case "$((${_encode64_sh__v} >> ${_encode64_sh__s} & 63))" in
                         0) printf "%s"  "${__0}" ;;  1) printf "%s"  "${__1}" ;;  2) printf "%s"  "${__2}" ;;
                         3) printf "%s"  "${__3}" ;;  4) printf "%s"  "${__4}" ;;  5) printf "%s"  "${__5}" ;;
                         6) printf "%s"  "${__6}" ;;  7) printf "%s"  "${__7}" ;;  8) printf "%s"  "${__8}" ;;
                         9) printf "%s"  "${__9}" ;; 10) printf "%s" "${__10}" ;; 11) printf "%s" "${__11}" ;;
                        12) printf "%s" "${__12}" ;; 13) printf "%s" "${__13}" ;; 14) printf "%s" "${__14}" ;;
                        15) printf "%s" "${__15}" ;; 16) printf "%s" "${__16}" ;; 17) printf "%s" "${__17}" ;;
                        18) printf "%s" "${__18}" ;; 19) printf "%s" "${__19}" ;; 20) printf "%s" "${__20}" ;;
                        21) printf "%s" "${__21}" ;; 22) printf "%s" "${__22}" ;; 23) printf "%s" "${__23}" ;;
                        24) printf "%s" "${__24}" ;; 25) printf "%s" "${__25}" ;; 26) printf "%s" "${__26}" ;;
                        27) printf "%s" "${__27}" ;; 28) printf "%s" "${__28}" ;; 29) printf "%s" "${__29}" ;;
                        30) printf "%s" "${__30}" ;; 31) printf "%s" "${__31}" ;; 32) printf "%s" "${__32}" ;;
                        33) printf "%s" "${__33}" ;; 34) printf "%s" "${__34}" ;; 35) printf "%s" "${__35}" ;;
                        36) printf "%s" "${__36}" ;; 37) printf "%s" "${__37}" ;; 38) printf "%s" "${__38}" ;;
                        39) printf "%s" "${__39}" ;; 40) printf "%s" "${__40}" ;; 41) printf "%s" "${__41}" ;;
                        42) printf "%s" "${__42}" ;; 43) printf "%s" "${__43}" ;; 44) printf "%s" "${__44}" ;;
                        45) printf "%s" "${__45}" ;; 46) printf "%s" "${__46}" ;; 47) printf "%s" "${__47}" ;;
                        48) printf "%s" "${__48}" ;; 49) printf "%s" "${__49}" ;; 50) printf "%s" "${__50}" ;;
                        51) printf "%s" "${__51}" ;; 52) printf "%s" "${__52}" ;; 53) printf "%s" "${__53}" ;;
                        54) printf "%s" "${__54}" ;; 55) printf "%s" "${__55}" ;; 56) printf "%s" "${__56}" ;;
                        57) printf "%s" "${__57}" ;; 58) printf "%s" "${__58}" ;; 59) printf "%s" "${__59}" ;;
                        60) printf "%s" "${__60}" ;; 61) printf "%s" "${__61}" ;; 62) printf "%s" "${__62}" ;;
                        63) printf "%s" "${__63}" ;; esac
                        #printf "%s" "${_encode64_sh__64:$((${_encode64_sh__v} >> ${_encode64_sh__s} & 63)):1}"
                        #printf "%s" "${_encode64_sh__64}" | cut -c$(($waa+1)) | tr -d '\n'
                        _encode64_sh__s="$((${_encode64_sh__s}-6))"; _encode64_sh__w="$((${_encode64_sh__w}+1))"
                        [ "${_encode64_sh__w}" -gt "75" ] && { printf "\\n"; _encode64_sh__w="0"; }
                    done

                    _encode64_sh__s="$((${_encode64_sh__n}/5))"; while [ "${_encode64_sh__s}" -gt "0" ]; do
                        _encode64_sh__s="$((${_encode64_sh__s}-1))"; printf "="
                    done
                }
                printf "\\n"
            }
        }
        printf "%s\\n" "${@}" | _encode64_sh
    fi
}
#==================================================== Example ====
#string="$(_encode64 "${string}")"
#=================================================================

_ensurecron() { #adds cron job, returns 1 on error
    [ -z "${1}" ] && return 1
    _ensurecron__exist="$(crontab -l 2>/dev/null | awk -v p="${1}" '{ if ($0 == p) {print p}}')"
    [ -n "${_ensurecron__exist}" ] && return 0
    ( crontab -l 2>/dev/null; printf "%s\\n" "${1}" ) | crontab -
}
#==================================================== Example ====
#_ensurecron "* * * * * /path/task"
#=================================================================

_false() { #opposite to ':' or 'true'
    return 1
#==================================================== Example ====
#_false #set current status to '1' which commonly refers to false
#=================================================================
}

_filesize_in_bytes() {
    [ -z "${1}" ] && return 1
    [ -r "${1}" ] || return 1
    (\du --apparent-size --block-size=1 "${1}" 2>/dev/null   || \
      \gdu --apparent-size --block-size=1 "${1}" 2>/dev/null || \
      \find "${1}" -printf "%s" 2>/dev/null  || \
      \gfind "${1}" -printf "%s" 2>/dev/null || \
      \stat --printf="%s" "${1}" 2>/dev/null || \
      \stat -f%z "${1}" 2>/dev/null || wc -c < "${1}" 2>/dev/null) | awk '{print $1}'
}
#==================================================== Example ====
#_file_size_in_bytes "/path/file"
#=================================================================

_float2fraction() {
    [ -z "${1}" ] && return 1
    _float2fraction__num="${1%%.*}"
    _float2fraction__den="${1##*.}"
    [ "${_float2fraction__num}" ] && [ "${_float2fraction__num}" -eq "0" ] && _float2fraction__num=""
    _float2fraction__num="${_float2fraction__num}${_float2fraction__den}"
    _float2fraction__zero="${#_float2fraction__den}"
    _float2fraction__den="1"
    #checking if denominator or numerator is greater
    while [ "${_float2fraction__zero}" -gt "0" ]; do
        _float2fraction__den="${_float2fraction__den}0"
        _float2fraction__zero="$((${_float2fraction__zero}-1))"
    done
    if [ "${_float2fraction__num}" -gt "${_float2fraction__den}" ];then
       _float2fraction__greater="${_float2fraction__num}"
       _float2fraction__lower="${_float2fraction__den}"
    else
       _float2fraction__greater="${_float2fraction__den}"
       _float2fraction__lower="${_float2fraction__num}"
    fi #finding hcf
    while [ "${_float2fraction__lower}" -ne "0" ];do
        _float2fraction__hcf="${_float2fraction__lower}"
        _float2fraction__lower=$((${_float2fraction__greater}%${_float2fraction__lower}))
        _float2fraction__greater="${_float2fraction__hcf}"
    done #dividing numerator and denominator by hcf
    _float2fraction__num="$((${_float2fraction__num}/${_float2fraction__hcf}))"
    _float2fraction__den="$((${_float2fraction__den}/${_float2fraction__hcf}))" #answer
    printf "%s\\n" "${_float2fraction__num}/${_float2fraction__den}"
}
#==================================================== Example ====
#_float2fraction "0.5"  #prints "1/2"
#_float2fraction "0.75" #prints "3/4"
#=================================================================

_getfirstvalue() { #returns first value that is non-empty
    for _getfirstvalue__param in "${@}"; do
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

_getfs() { #returns file system detected or 1 on failure
    [ -z "${1}" ] && return 1
    udevadm info -q all -n "${1}" | awk -F"=" '/ID_FS_TYPE/ {print $2 }'
}
#==================================================== Example ====
#_getfs /dev/sda1 #print "ext4" or the format found
#=================================================================

_getpasswd() { #define vars as passwords
    if [ -n "${1}" ]; then
        _getpasswd__option="$(printf "%s\\n" "${1}" | tr '[:upper:]' '[:lower:]')"
        printf "%s" "Enter your ${_getpasswd__option} password: "
        stty -echo
        read "${_getpasswd__option}"passwd
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

_getuuid() { #returns a uuid or 1 on failure
    [ -z "${1}" ] && return 1
    udevadm info -q all -n "${1}" | awk -F"/" '/^S.*uuid.*/ {print $3}'
}
#==================================================== Example ====
#_getuuid /dev/sda1 #print "793e9a6d-d545-46f0-ac9c-49071c450b62"
#=================================================================

_human2seconds() { #translate human date format to seconds
    [ -z "${1}" ] && return 1
    _h2s__string="$(printf "%s" "${*}" | tr \
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ' 'abcdefghijklmnopqrstuvwxyz')"
    _h2s__string="$(printf "%s\\n" ""${_h2s__string} | sed 's:[ -]::g;')"

    _h2s__partial_secs="0"; _h2s__total_secs="0"; _h2s__valid_input="";
    #read char by char
    while [ "${_h2s__string}" ]; do
        _h2s__1stchar="${_h2s__string#?}"
        _h2s__1stchar="${_h2s__string%$_h2s__1stchar}"
        case "${_h2s__1stchar}" in
            m|M) if [ X"${_h2s__waiting_digit}" = X"0" ]; then
                    _h2s__partial_secs="$(($_h2s__partial_secs * 60))"
                    _h2s__total_secs="$(($_h2s__total_secs + _h2s__partial_secs))"
                    _h2s__partial_secs="0"; _h2s__waiting_digit="1"
                fi
                ;;
            h|H) if [ X"${_h2s__waiting_digit}" = X"0" ]; then
                    _h2s__partial_secs="$(($_h2s__partial_secs * 3600))"
                    _h2s__total_secs="$(($_h2s__total_secs + _h2s__partial_secs))"
                    _h2s__partial_secs="0"; _h2s__waiting_digit="1"
                fi
                ;;
            d|D) if [ X"${_h2s__waiting_digit}" = X"0" ]; then
                    _h2s__partial_secs="$(($_h2s__partial_secs * 86400))"
                    _h2s__total_secs="$(($_h2s__total_secs + _h2s__partial_secs))"
                    _h2s__partial_secs="0"; _h2s__waiting_digit="1"
                fi
                ;;
            s|S) _h2s__waiting_digit="1" ;;
            0|1|2|3|4|5|6|7|8|9)
                _h2s__partial_secs="${_h2s__partial_secs}${_h2s__1stchar}"
                _h2s__partial_secs="${_h2s__partial_secs##0}"
                _h2s__waiting_digit="0"; _h2s__valid_input="0"
                ;;
        esac
        [ X"${_h2s__string}" = X"${_h2s__1stchar}" ] && \
            _h2s__string='' || _h2s__string="${_h2s__string#?}"
    done

    if [ X"${_h2s__valid_input}" = X"0" ]; then
        _h2s__total_secs="$(($_h2s__total_secs + $_h2s__partial_secs))"
        printf "%s\\n" "${_h2s__total_secs}"
    else
        return 1
    fi
}
#==================================================== Example ====
#_human2seconds "3 minutes and 30 seconds" #print "210"
#=================================================================

_internet() {
    #check for internet connection, return 0 on success, 1 otherwise
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

_is_int() { #look for an integer, returns 0 on success, 1 otherwise
    #http://www.unix.com/shell-programming-and-scripting/172070-help-scripting-command.html
    case "${1}" in
        *[!0-9]*|"") return 1 ;;
    esac
}
#==================================================== Example ====
#printf "%s" "Enter input: "
#read input
#if ! _is_int "${input}" ; then
    #printf "%s\\n" "Your input must consist of only numbers." >&2
    #exit 1
#else
    #printf "%s\\n" "Input is valid."
#fi
#exit 0
#=================================================================

_is_root() { #current user is root?
    [ X"$(whoami)" = X"root" ]
}
#==================================================== Example ====
#if _is_root; then
    #apt-get install -y htop
#fi
#=================================================================

_lastchar() { #return last char of a string
    [ -z "${1}" ] && return 1
    for i in "${@}"; do :; done
    _1stchar__substr="${i%?}"
    printf "%s" "${i#$_1stchar__substr}"
}
#==================================================== Example ====
#_lastchar test #print 't'
#=================================================================

_livecd() {
    #detect a livecd system, return 0 on success, 1 otherwise
    grep boot=live   /proc/cmdline >/dev/null && return 0
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

_lock() {
    #locks the execution of a program, it should be used at the
    #beggining of it, exit on failure
    exec 9>/tmp/"$(expr "${1}" : '.*/\([^/]*\)')".lock #verify only one instance is running
    [ X"${LOGNAME}" = X"root" ] && chmod 666 /tmp/"$(expr "${1}" : '.*/\([^/]*\)')".lock
    if ! flock -n 9  ; then         #http://mywiki.wooledge.org/BashFAQ/045
        printf "%s\\n" "$(expr "${1}" : '.*/\([^/]*\)'): another instance is running";
        exit 1
    fi
}
#==================================================== Example ====
#_lock "${0}" #locks script till finish
#=================================================================

_mkdir_p() { #portable mkdir -p
    [ -n "${1}" ] || return 1
    for _mkdir_p__dir in "${@}"; do
        [ -d "${_mkdir_p__dir}" ] && continue
        _mkdir_p__IFS="${IFS}"
        IFS="/"
        set -- ${_mkdir_p__dir}
        IFS="${_mkdir_p__IFS}"
        (
        case "${_mkdir_p__dir}" in
            /*) cd /; shift ;;
        esac
        for _mkdir_p__subdir in "${@}"; do
            [ -z "${_mkdir_p__subdir}" ] && continue
            if [ -d "${_mkdir_p__subdir}" ] || mkdir "${_mkdir_p__subdir}"; then
                if cd "${_mkdir_p__subdir}"; then
                    :
                else
                    printf "%s\\n" "_mkdir_p: Can't enter ${_mkdir_p__subdir} while creating ${_mkdir_p__dir}"
                    return 1
                fi
            else
                return 1
            fi
        done
        )
    done
}
#==================================================== Example ====
#_mkdir_p "foo/bar/daa" #creates the directory hier
#=================================================================

_notify() {
    #output messages through the notification system, prints to
    #stdout in the worst escenario
    [ -z "${1}" ] && return 1
    if [ X"${TERM}" = X"linux" ] || [ -z "${TERM}" ]; then
        kill -9 $(pgrep notify-osd) >/dev/null 2>&1
        if ! DISPLAY=${DISPLAY:-:0} notify-send -t 1000 "${1}"  "${2}"; then
            if command -v "gxmessage" 2>/dev/null; then
                font="Monaco 9"
                DISPLAY=${DISPLAY:-:0} gxmessage "${font:+-fn "$font"}" "${1} ${2}" "ok"
            elif command -v "xmessage" 2>/dev/null; then
                font="fixed"
                DISPLAY=${DISPLAY:-:0}  xmessage "${font:+-fn "$font"}" "${1} ${2}" "ok"
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

_notify2() {
    #output messages through the notification system, prints to
    #stdout in the worst escenario
    [ -z "${1}" ] && return 1
    if [ X"${TERM}" = X"linux" ] || [ -z "${TERM}" ]; then
        kill -9 $(pgrep notify-osd) >/dev/null 2>&1
        if ! DISPLAY=${DISPLAY:-:0} notify-send -t 1000 "${1}" "${3}"; then
            if command -v "gxmessage" 2>/dev/null; then
                font="Monaco 9"
                DISPLAY=${DISPLAY:-:0} gxmessage "${font:+-fn "$font"}" "${1}" "ok"
            elif command -v "xmessage" 2>/dev/null; then
                font="fixed"
                DISPLAY=${DISPLAY:-:0}  xmessage "${font:+-fn "$font"}" "${1}" "ok"
            fi
        fi
    else
        printf "%s\\n" "${2}"
    fi
    case "${3}" in
        *clipboard*)
            #dumping xclip's stdout to the bitbucket works around xclip's
            #failure to properly daemonize
            #https://sourceforge.net/p/xclip/patches/9/
            printf "%s" "${2}" 2>/dev/null | xclip -selection clipboard -i >/dev/null 2>&1 || \
            printf "%s" "${2}" 2>/dev/null | xsel -bi 2>/dev/null || \
            printf "%s" "${2}" 2>/dev/null | pbcopy 2>/dev/null   || :
            ;;
    esac
}
#==================================================== Example ====
#_notify2 "5+3 = 8" "8" "Copied to the clipboard!"
#=================================================================

_printfc() { #print command
    [ -z "${1}" ] && return 1
    printf "%s\\n" "    $ ${*}"
}
#==================================================== Example ====
#_printfc "command"
#=================================================================

_printfl() { #print lines
    command -v "tput" >/dev/null 2>&1 && _printfl_var_max_len="$(tput cols)"
    _printfl_var_max_len="${_printfl_var_max_len:-80}"
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

_printfs() { #print step
    [ -z "${1}" ] && return 1
    printf "%s\\n" "[+] ${*}"
}
#==================================================== Example ====
#_printfs "Subtitle"
#=================================================================

_seconds2human() { #format seconds to a pretty human string
    [ -z "${1}" ] && return 1
    printf "%s\\n" "${1}" | grep -v "[^0-9]" >/dev/null || return 1;

    _s2h__num="${1}"
    _s2h__min="0"
    _s2h__hour="0"
    _s2h__day="0"
    if [ "${_s2h__num}" -gt "59" ]; then
        _s2h__sec="$((${_s2h__num} % 60))"
        _s2h__num="$((${_s2h__num} / 60))"
        if [ "${_s2h__num}" -gt "59" ]; then
            _s2h__min="$((${_s2h__num} % 60))"
            _s2h__num="$((${_s2h__num} / 60))"
            if [ "${_s2h__num}" -gt "23" ]; then
                _s2h__hour="$((${_s2h__num} % 24))"
                _s2h__day="$((${_s2h__num} / 24))"
            else
                _s2h__hour="${_s2h__num}"
            fi
        else
            _s2h__min="${_s2h__num}"
        fi
    else
        _s2h__sec="${_s2h__num}"
    fi
    printf "%s\\n" \
    "${_s2h__day}d ${_s2h__hour}h ${_s2h__min}m ${_s2h__sec}s"
}
#==================================================== Example ====
#SECONDS="12345"
#_seconds2human "${SECONDS}" #prints "0d 3h 25m 49s"
#=================================================================

_privport() {
    #check if port is a num and if it's privated (<1025)
    #returns 0 on success, 1 otherwise
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

_random() { #return a random number between two limits
    #default to numbers between 1-10
    _random__min="${1:-1}"
    _random__max="${2:-10}"
    _random__awk_prog='BEGIN {srand(); print int(MIN+rand()*(MAX-MIN+1))}'
    awk -v MIN="${_random__min}" -v MAX="${_random__max}" "${_random__awk_prog}" < /dev/null
}
#==================================================== Example ====
#printf "%s\\n" "$(_random)"     "prints random numbers between 1 and 10
#printf "%s\\n" "$(_random 1 5)" "prints random numbers between 1 and 5
#=================================================================

_readc() {
    stty -echo
    stty raw
    dd bs=1 count=1 2> /dev/null
    stty -raw
    stty echo
}
#==================================================== Example ====
#while :; do
    #case "$(_readc)" in
        #q) break ;;
        #1) printf "%s\\n" "1 pressed" ;;
    #esac
#done
#=================================================================

_realpath() {
    #print absolute path
    [ -z "${1}" ] && return 1

    #start with the file name (sans the trailing slash)
    _realpath__path="${1%/}"

    #if we stripped off the trailing slash and were left with nothing, that means we're in the root directory
    [ -z "${_realpath__path}" ] && _realpath__path="/"

    #get the basename of the file (ignoring '.' & '..', because they're really part of the path)
    _realpath__file_basename="${_realpath__path##*/}"
    if [ X"${_realpath__file_basename}" = X"." ] || [ X"${_realpath__file_basename}" = X".." ]; then
        _realpath__file_basename=""
    fi

    #extracts the directory component of the full path, if it's empty then assume '.'
    _realpath__directory="${_realpath__path%${_realpath__file_basename}}"
    [ -z "${_realpath__directory}" ] && _realpath__directory="."

    #attempt to change to the directory
    if ! \cd "${_realpath__directory}" >/dev/null 2>/dev/null; then
        return 1
    fi

    #get the absolute path of the current directory & change back to previous directory
    _realpath__abs_path="$(pwd -P)"
    \cd "-" >/dev/null 2>/dev/null

    #append base filename to absolute path
    if [ X"${_realpath__abs_path}" = X"/" ]; then
        _realpath__abs_path="${_realpath__abs_path}${_realpath__file_basename}"
    else
        _realpath__abs_path="${_realpath__abs_path}/${_realpath__file_basename}"
    fi

    printf "%s\\n" "${_realpath__abs_path}"
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

_rmcron() { #remove cron jobs, returns 1 on failure
    [ -z "${1}" ] && return 1
    crontab -l | grep -v "${1}" | crontab
}
#==================================================== Example ====
#_rmcron "pattern"
#=================================================================

_seq() { #portable seq
    for _seq__arg in "${@}"; do
        case "${_seq__arg}" in
            *[!0-9-]*|"") return 1 ;;
        esac
    done

    [ -z "${1}" ] && return 1

    _seq__first="1"; _seq__increment="1"; _seq__last="${1}"

    if [ "${#2}" -gt "0" ]; then
        _seq__first="${1}"
        _seq__last="${2}"
    fi

    if [ "${#3}" -gt "0" ]; then
        _seq__first="${1}"
        _seq__increment="${2}"
        _seq__last="${3}"
    fi

    while [ "$_seq__first" -le "${_seq__last}" ]; do
        printf "%s\\n" "${_seq__first}"
        _seq__first="$((_seq__first + _seq__increment))"
    done
}
#==================================================== Example ====
#_seq 3
#1
#2
#3
#=================================================================

_shuf() { #shuffle input
    awk 'BEGIN{srand()}{print rand()"\t"$0}' "${@}" | sort | cut -f2-
}
#==================================================== Example ====
#printf "%s" "1,2,3,4,5" | tr ',' '\n' | _shuf | tr '\n' ','
#=================================================================

_str2octal() { #convert a string to octal
    [ -z "${1}" ] && return 1
    printf "%s" "${@}" | od -v -A n -t o1 | \
        sed "s:^ ::" | tr -d "\n"
}
#==================================================== Example ====
#hello="hello"
#hello="$(_str2octal "${hello}")"
#printf "%s\\n" "${hello}"   #prints "150 145 154 154 157"
#=================================================================

_str2octal_escaped() { #convert a string to escaped octal
    [ -z "${1}" ] && return 1
    printf "%s" "${@}" | od -v -A n -t o1 | \
        sed "s/ *\([0-9]*\) */\\\\\1/g" | tr -d "\n"
}
#==================================================== Example ====
#hello="hello"
#hello="$(_str2octal "${hello}")"
#printf "%s\\n" "${hello}"   #prints "\150\145\154\154\157"
#=================================================================

_str2lower() { #convert a string to lower string
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

_str2upper() { #convert a string to lower string
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

_strdiff() { #prints the diff of two strings
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

_strduplicates() { #print duplicated strings, return 1 on failure
    [ -z "${1}" ] && return 1
    [ -z "${2}" ] && return 1
    printf "%s\\n" $@ | awk 'x[$0]++'
}
#==================================================== Example ====
#hello="hello world"
#bye="bye world"
#world=$(_strduplicates "${hello}" "${bye}")
#printf "%s\\n"  "${world}"   #prints "world"
#=================================================================

_strlen() { #print the length of a string, return 1 on failure
    [ -z "${1}" ] && return 1
    printf "%s\\n" "${#1}"
}
#==================================================== Example ====
#_strlen "hello world!" #returns "12"
#=================================================================

_strreplace() { #replace param in string, return 1 on failure
   #http://www.unix.com/shell-programming-and-scripting/124160-replace-word-string.html
  _strreplace__orig="${1}"
  [ -n "${3}" ] || return 1 #nothing to search for: error
  _strreplace__srch="${2}"  #pattern to replace
  _strreplace__rep="${3}"   #replacement string
  case "${_strreplace__orig}" in
    *"${_strreplace__srch}"*) #if pattern exists in the string
       _strreplace__sr1="${_strreplace__orig%%$_strreplace__srch*}" #take the string preceding the first match
       _strreplace__sr2="${_strreplace__orig#*$_strreplace__srch}"  #and the string following the first match
       _strreplace__orig="${_strreplace__sr1}${_strreplace__rep}${_strreplace__sr2}" #and sandwich the replacement string between them
       ;;
  esac
  printf "%s" "${_strreplace__orig}"
}
#==================================================== Example ====
#hello="hello world"
#bye="$(_strreplace "${hello}" "hello" "bye")"
#printf "%s\\n" "${bye}"   #prints "bye world"
#=================================================================

_strreplace2() { #replace param in string, return 1 on failure
    [ -z "${1}" ] && return 1
    [ -z "${2}" ] && return 1
    [ -z "${3}" ] && return 1
    _strreplace2__replace=$(printf "%s" "${1}" | sed -e "s:${2}:${3}:g")
    printf "%s" "${_strreplace2__replace}"
}
#==================================================== Example ====
#hello="hello world"
#bye="$(_strreplace2 "${hello}" "hello" "bye")"
#printf "%s\\n" "${bye}"   #prints "bye world"
#=================================================================

_strunique() { #print unique strings, return 1 on failure
    [ -z "${1}" ] && return 1
    [ -z "${2}" ] && return 1
    _strunique__retval="$(printf "%s\\n" $@ | \
        awk '!($0 in x) {x[$0];print}')" #faster
        #printf "%s\\n" $@ | awk '!x[$0]++'
    _strunique__retval="$(printf "%s" "${_strunique__retval}" | \
        tr '\n' ' ')"
    printf "%s\\n" "${_strunique__retval}"
}
#==================================================== Example ====
#hello="hello world"
#bye="bye world"
#world="$(_strunique "${hello}" "${bye}")"
#printf "%s\\n"  "${world}"   #prints "hello world bye"
#=================================================================

_subchar() { #print n character in string
    [ -z "${1}" ] && return 1
    [ -z "${2}" ] && return 1

    if [ "${2}" -lt "0" ]; then
        _subchar__pos="$((${#1} + ${2}))"
    else
        _subchar__pos="${2}"
    fi

    [ "${_subchar__pos}" -ge "${#1}" ] && return 1
    [ "${_subchar__pos}" -lt "0" ]     && return 1

    _subchar__string="${1}"

    i="0"; while [ "${i}" -le "${_subchar__pos}" ]; do
        _subchar__char="${_subchar__string#?}"
        _subchar__char="${_subchar__string%$_subchar__char}"
        i="$((i+1))"
        _subchar__string="${_subchar__string#?}"
    done
    #_subchar__retval="${_subchar__char}"
    printf "%s\\n" "${_subchar__char}"
}

_subchar2() { #print n character in string
    #faster but unsecure alternative
    _subchar__string="${1}"
    i="0"; while [ "${i}" -le "${2}" ]; do
        _subchar__char="${_subchar__string#?}"
        _subchar__char="${_subchar__string%$_subchar__char}"
        i="$(($i+1))"
        _subchar__string="${_subchar__string#?}"
    done
    #_subchar__retval="${_subchar__char}"
    printf "%s\\n" "${_subchar__char}"
}

_substr() { #print a substring
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

_unprintf() { #unprint sentence
    [ -z "${1}" ] && return 1
    printf "\\r"
    for i in $(seq 0 "${#1}"); do printf " "  ; done
    printf "\\r"
}
#==================================================== Example ====
#printf "hello world"
#sleep 1s
#_unprintf "hello world"
#prinf "bye world"
#=================================================================

_uploadimg() { #upload images, return url on success, 1 otherwise
    #requires curl, and optionally xclip
    [ -z "${1}" ] && return 1

    for _upload_img__param in "${@}"; do
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

_update() {
    _u__current_file="$(cd "$(dirname "${0}")" && pwd)/${progname}"
    _u__current_version_long="$(awk -F\" \
        '/VERSION=/{print $2;exit}' "${_u__current_file}" 2>/dev/null)"
    _u__current_version="$(printf "%s\\n" "${_u__current_version_long}" | \
        awk '{gsub(/[\.:]/,"");gsub(/-/,"");print;exit}' 2>/dev/null)"
    [ -z "${_u__current_version}" ] && printf "%s\\n%s\\n%s\\n"           \
        "ERROR: Failed to detect current version, please update manually" \
        "${progname}         = ${_u__current_file}"                       \
        "${progname} version = ${_u__current_version}" >&2 && return 1

    command -v "wget" >/dev/null 2>&1 || command -v "curl" >/dev/null 2>&1 || \
        { printf "%s\\n" "ERROR: Install either 'wget' or 'curl' to upgrade" >&2; return 1; }

    _u__url="https://raw.githubusercontent.com/minos-org/minos-static/master/${progname}"
    _u__tmpfile="/tmp/${progname}.${$}.update"

    _u__error_msg="$(wget -q -O- --no-check-certificate "${_u__url}" \
        > "${_u__tmpfile}" 2>&1   || curl -s "${_u__url}"  \
        > "${_u__tmpfile}" 2>&1)" || { printf "%s\\n%s\\n" \
        "ERROR: Failed to fetch update, please try later or update manually" \
        "${_u__error_msg}" >&2; return 1; }

    _u__update_version_long="$(awk -F\" \
        '/VERSION=/{print $2;exit}' "${_u__tmpfile}" 2>/dev/null)"
    _u__update_version="$(printf "%s" "${_u__update_version_long}" | awk \
        '{gsub(/[\.:]/,"");gsub(/-/,"");print;exit}' 2>/dev/null)"
    [ -n "${_u__update_version}" ] || _u__update_version="0"

    if [ "${_u__current_version}" -lt "${_u__update_version}" ]; then
        printf "%s %s\\n" "Updating from version" \
            "${_u__current_version_long} to ${_u__update_version_long} ..."
        chmod +x "${_u__tmpfile}"
        if ! mv -f "${_u__tmpfile}" "${_u__current_file}" 2>/dev/null; then
            printf "%s\\n" "ERROR: no write permissions on ${_u__current_file}" >&2
            printf "%s\\n" "INFO : trying with sudo ..." >&2
            if command -v "sudo" >/dev/null 2>&1; then
                sudo mv "${_u__tmpfile}" "${_u__current_file}" || return 1
            else
                printf "%s\\n" "ERROR: sudo isn't available, exiting ..." >&2
                rm -rf "${_u__tmpfile}"
                return 1
            fi
        fi
        printf "%s %s\\n" "${progname} is up-to-date (${_u__update_version_long})"
        return 0
    fi
    printf "%s %s\\n" "${progname} is up-to-date (${_u__current_version_long})"
    rm -rf "${_u__tmpfile}"
}
#==================================================== Example ====
#for arg in "${@}"; do #parse options and update if requested
    #case "${arg}" in
        #-U|--update)  _update; exit "${?}" ;;
    #esac
#done
#=================================================================

_user() {
    #test if an user exists on the system
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

_validip4() {
    #return 0 if parameter is a valid ip4 address, non-zero otherwise
    #https://groups.google.com/forum/#!original/comp.unix.shell/NDu-kAL5cHs/7Zpc6Q2Hu5YJ
    [ -z "${1}" ] && return 1

    case "${*}" in
        ""|*[!0-9.]*|*[!0-9]) return 1 ;;
    esac

    OLDIFS="${IFS}"
    IFS="."
    set -- $@
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

_validmail() { #verify if an email is valid, return 1 on failure
    case "${1}" in
        *@*.*) return 0 ;;
         *|"") return 1 ;;
    esac
}
#===================================================== Example ====
#if ! _validmail "${address}"; then
    #printf "%s\\n" "not valid email address: ${address}"
#fi
#=================================================================

_validnetinterface() {
    #check if parameter is a valid network interface
    #return 0 if sucess, 0 otherwise
    [ -z "${1}" ] && return 1
    ip addr show | grep "${1}": >/dev/null && return 0
}
#===================================================== Example ====
#if ! _validnetinterface "${interface}"; then
    #printf "%s\\n" "not valid interface ${interface}"
#fi
#=================================================================

_verbose() { #print a message when in verbose mode
    [ -z "${1}" ] && return 1
    [ -n "${VERBOSE}" ] && printf "%s\\n" "${*}"
}
#==================================================== Example ====
#_verbose "hello"           # print nothing
#VERBOSE=1 _verbose "hello" # print verbose
#=================================================================

_virt_what() { #print used virtualization system
    if [ -d /proc/vz ] && [ ! -d /proc/bc ]; then
        printf "openvz"
    elif grep 'UML' /proc/cpuinfo >/dev/null 2>&1; then
        printf "uml"
    elif [ -f /proc/xen/capabilities ]; then
        printf "xen"
    elif grep 'QEMU' /proc/cpuinfo >/dev/null 2>&1; then
        printf "qemu"
    elif grep 'Hypervisor detected' /var/log/dmesg >/dev/null 2>&1; then
        awk '/Hypervisor detected/{print tolower($NF); exit;}' /var/log/dmesg
    else
        return 1
    fi
}
#==================================================== Example ====
#_virt_what # print virt tech used or return -1 if none
#=================================================================

_whereis() { #whereis portable version
    command -v "${1}" 2>/dev/null || return 1
}
#==================================================== Example ====
#if _whereis command >/dev/null; then
    #command
#fi
#=================================================================

_xmessage() { #prints a message using xmessage || gxmessage
    [ -z "${1}" ] && return 1
    _xmessage__bin="$(command -v gxmessage 2>/dev/null)" \
        || _xmessage__bin="$(command -v xmessage 2>/dev/null)"
    _xmessage__str="$(expr "${0}" : '.*/\([^/]*\)'): ${*}"
    printf "%s\\n" "${_xmessage__str}" | fold -s -w ${COLUMNS:-80}
    if [ -n "${DISPLAY}" ] && [ -n "${_xmessage__str}" ]; then
        printf "%s\\n" "${_xmessage__str}" | \
            fold -s -w ${COLUMNS:-80}      | \
            "${_xmessage__bin}" -center -file -
    fi
}
#==================================================== Example ====
#_xmessage "Notice ..." #show a dialog with notice
#=================================================================
