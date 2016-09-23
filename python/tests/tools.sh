#!/bin/sh
#Based on the GNU shtool test suite

tools="../tools"
tools_db="./tools.db"

#database exist?
[ -d "${tools}" ]    || exit 1
[ -f "${tools_db}" ] || exit 1

#override temp debug string, avoid "Bad substitution" errors
PS4=">>"

#test tools
TOOLS="$(find "${tools}" -maxdepth 1 -type f -exec basename '{}' ';')"
TESTS="$(grep '^@begin' "${tools_db}" | sed -e 's/^@begin{//' -e 's/}.*$//')"
TOOLS_WITH_TEST="$(printf "%s\\n" ${TOOLS} ${TESTS} | awk 'x[$0]++')"

mkfifo fifo1 && mkfifo fifo2
if [ -e fifo1 ] && [ -e fifo2 ]; then
    printf "%s\\n" "${TOOLS_WITH_TEST}" > fifo1 &
    printf "%s\\n" "${TOOLS}"           > fifo2 &
    TOOLS_WITHOUT_TEST="$(awk 'NR == FNR { A[$0]=1; next } !A[$0]' fifo1 fifo2)"
    rm -rf fifo1; rm -rf fifo2
fi

if [ -n "${TOOLS_WITHOUT_TEST}" ]; then
    printf "%s\\n\\n" "Warning - tools in ${tools} without tests!, create the missing tests in ${tools_db}"
    printf "%s\\n\\n" "${TOOLS_WITHOUT_TEST}"
fi

#move to a tmp subdirectory

rm -rf test.sd || (sleep 1; rm -rf test.sd)
mkdir test.sd  || exit 1
cd test.sd     || exit 1

failed="0"
passed="0"
ran="0"

printf "%s\\n\\n" "Info - running ${tools} tests:"

[ -z "${1}" ] || TOOLS_WITH_TEST="${1}"

for tool in ${TOOLS_WITH_TEST}; do
    rm -rf ./* >/dev/null 2>&1
    printf "%s\\n" "${tool} ........................" | awk '{ printf("%s ", substr($0, 0, 25)); }'
    printf "%s\\n" "PATH=../${tools}:/bin:/usr/bin" > run.sh
    sed -e "/^@begin{$tool}/,/^@end/p" -e '1,$d' ../${tools_db} |\
    sed -e '/^@begin/d' -e '/^@end/d' \
        -e 's/\([^\\]\)[ 	]*$/\1 || exit 1/g' >> run.sh
    printf "exit 0\\n" >> run.sh
    sh -x run.sh        > run.log 2>&1
    if [ "${?}" -ne "0" ]; then
        #generate report
        printf "FAILED\\n"
        printf "+---Test------------------------------\\n"
        cat run.sh | sed -e 's/^/| /g'
        printf "+---Trace-----------------------------\\n"
        cat run.log | sed -e 's/^/| /g'
        failed="$((${failed} + 1))"
        printf "+-------------------------------------\\n"
    else
    passed="$((${passed} + 1))"
        printf "ok\\n"
    fi
    ran="$((${ran} + 1))"
done

#result
if [ "${failed}" -gt "0" ]; then
    printf "FAILED: passed: ${passed}/${ran}, failed: ${failed}/${ran}\\n"
    exit 1
else
    printf "OK: passed: ${passed}/${ran}\\n"
    cd .. && rm -rf test.sd >/dev/null 2>&1
fi

# vim: set ts=8 sw=4 tw=0 ft=sh :
