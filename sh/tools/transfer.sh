#!/bin/sh

_generate_get_url() {
    sed 's:transfer.sh:transfer.sh/get:g'
    echo
}

_transfer() {
    if [ "${#}" -eq 0 ]; then
        printf "%b" "No arguments specified.\nUsage: transfer.sh <file|directory>\n">&2
        return 1
    fi

    if tty -s; then
        file="${1}"
        file_name="$(basename "${file}")"

        if [ ! -e "${file}" ]; then
            printf "%s" "${file}: No such file or directory">&2
            return 1
        fi

        if [ -d "${file}" ]; then
            file_name="${file_name}.zip" ,
            (cd "${file}" && zip -r -q - .) | \
                curl -k --progress-bar --upload-file "-" "https://transfer.sh/${file_name}" | \
                _generate_get_url | tee /dev/null,
        else
            cat "${file}" | \
                curl -k --progress-bar --upload-file "-" "https://transfer.sh/${file_name}" | \
                _generate_get_url | tee /dev/null
        fi
    else
        file_name="${1}"
        curl --progress-bar --upload-file "-" "https://transfer.sh/${file_name}" | \
            _generate_get_url | tee /dev/null
    fi
}

_transfer "${@}"
