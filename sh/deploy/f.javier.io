#!/bin/sh

progname="$(basename "${0}")"

_seconds2human() {
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

    [ "${_s2h__day}"  -gt 0 ] && printf "%s" "${_s2h__day}d "
    [ "${_s2h__hour}" -gt 0 ] && printf "%s" "${_s2h__day}h "
    [ "${_s2h__min}"  -gt 0 ] && printf "%s" "${_s2h__min}m "
    printf "%s" "${_s2h__sec}s"
    printf "\\n"
}

_printfl() {
    _printfl__max_len="80"
    if [ -n "${1}" ]; then
        _printfl__word_len="$(expr "${#1}" + 2)"
        _printfl__sub="$(expr "${_printfl__max_len}" - "${_printfl__word_len}")"
        _printfl__half="$(expr "${_printfl__sub}" / 2)"
        _printfl__other_half="$(expr "${_printfl__sub}" - "${_printfl__half}")"
        printf "%b" "\033[1m" #white strong
        printf '%*s' "${_printfl__half}" '' | tr ' ' -
        printf "%b" "\033[7m" #white background
        printf " %s " "${1}"
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

_printfs() {
    [ -z "${1}" ] && return 1
    printf "%s\\n" "[+] ${*}"
}

_cmd_verbose() {
    [ -z "${1}" ] && return 1
    printf "%s \\n" "    $ ${*}"
    eval ${@} || exit "${?}"
}

_cmd() {
    [ -z "${1}" ] && return 1
    printf "%s \\n" "    $ ${*}"
    _cmd__output="$(eval ${@} 2>&1)"
    _cmd__status="${?}"

    if [ X"${_cmd__status}" != X"0" ]; then
        printf "> %s:%s" "${*}" "${_cmd__output}"
        printf "\\n"
        exit "${_cmd__status}"
    else
        return "${_cmd__status}"
    fi
}

_apt_update() {
    [ -z "${1}" ] && _aupdate__cache_seconds="3600" || _aupdate__cache_seconds="${1}"
    _aupdate__cache_file="/var/cache/apt/pkgcache.bin"

    if [ -f "${_aupdate__cache_file}" ]; then
        _aupdate__last="$(stat -c %Y "${_aupdate__cache_file}")"
        _aupdate__now="$(date +'%s')"
        _aupdate__diff="$(($_aupdate__now - $_aupdate__last))"
        if [ "${_aupdate__diff}" -lt "${_aupdate__cache_seconds}" ]; then
            _printfs "apt-get update was recently used ($(_seconds2human "${_aupdate__diff}") ago), skipping ..."
        else
            _cmd sudo apt-get update
        fi
    else
        _cmd sudo apt-get update
    fi
}

_apt_install() {
    for pkg in "${@}"; do
        if ! dpkg -s "${pkg}" >/dev/null 2>&1; then
            pkgs="${pkgs} ${pkg}"
        else
            already_installed_pkgs="${already_installed_pkgs} ${pkg}"
        fi
    done
    [ -z "${already_installed_pkgs}" ] || printf "%s\\n" "skipping already installed pkgs:${already_installed_pkgs} ..."
    [ -z "${pkgs}" ] || _cmd sudo DEBIAN_FRONTEND=noninteractive apt-get install \
        --no-install-recommends -y -o Dpkg::Options::="--force-confdef" \
        -o Dpkg::Options::="--force-confold" --force-yes ${pkgs}
}

_printfl "Quick & dirty ${progname} setup"
_printfs "Detecting distro ..."
. /etc/lsb-release
case "$DISTRIB_ID" in
    Ubuntu)
        if ! dpkg -s minos-core-settings >/dev/null 2>&1; then
            _printfs "Adding minos configuration file to ${DISTRIB_ID} ${DISTRIB_CODENAME} ..."
            _cmd sudo mkdir -p /etc/minos/
            _cmd sudo wget --no-check-certificate https://raw.githubusercontent.com/chilicuil/dotfiles/master/.minos/config -O /etc/minos/config

            _printfs "Installing minos base ..."
            _cmd wget javier.io/deploy -O deploy
            _cmd_verbose sudo sh deploy minos core
            _cmd rm -rf deploy
        fi

        _printfl "Installing deps ..."
        _apt_update 3600
        [ X"${DISTRIB_CODENAME}" = X"trusty" ] && _apt_install apache2 libapache2-mod-php5 php5
        [ X"${DISTRIB_CODENAME}" = X"xenial" ] && _apt_install apache2 libapache2-mod-php php
        _printfs "Setting up apache2/php ..."
        _cmd "sudo sed -i '/^<Directory/,/^</d' /etc/apache2/apache2.conf"
        for file in $(find /etc -name php.ini 2>/dev/null); do
            _cmd "sudo sed -i -e '/upload_max_filesize =/ s:=.*:= 5000M:' ${file}"
            _cmd "sudo sed -i -e '/post_max_size =/ s:=.*:= 5000M:' ${file}"
        done

        _printfs "Getting files"
        _cmd_verbose 'rsync -avz -e "ssh -o StrictHostKeyChecking=no" admin@b.javier.io:/home/admin/backup/files.javier.io /tmp'

        _printfs "Setting up sites"
        _cmd_verbose sudo rsync --delete -av /tmp/files.javier.io/root-var-www/  /var/www/
        _cmd_verbose sudo rsync --delete -av /tmp/files.javier.io/root-etc-apache2/sites-available/ /etc/apache2/sites-available/
        _cmd sudo chown -R www-data:www-data /var/www/
        for site in /etc/apache2/sites-enabled/*default*; do
            test -f "${site}" && _cmd sudo a2dissite "$(basename "${site}")"
        done
        for site in /etc/apache2/sites-available/*javier*; do
            test -f "${site}" && _cmd sudo a2ensite "$(basename "${site}")"
        done
        _cmd sudo service apache2 restart

        _printfs "Installing crons"
        _cmd cp /var/www/crontabs.tar.gz /tmp/
        _cmd "cd /tmp && tar zxf crontabs.tar.gz"
        _cmd sudo mv /tmp/var/spool/cron/crontabs/admin /var/spool/cron/crontabs/admin
        _cmd sudo mv /tmp/var/spool/cron/crontabs/root  /var/spool/cron/crontabs/root
        _cmd rm -rf  /tmp/crontabs.tar.gz /tmp/var

        ;;
    *) printf "%s\\n" "Distribution not supported, exiting..."; return 1;;
esac
