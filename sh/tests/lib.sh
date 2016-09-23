#!/bin/sh
#Based on the GNU shtool test suite

lib="../lib"
lib_db="./lib.db"

#database exist?
[ -f "${lib}" ]    || exit 1
[ -f "${lib_db}" ] || exit 1

#override temp debug string, avoid "Bad substitution" errors
PS4=">>"

#test lib
FUNCTIONS="$(grep '^_.*()' "${lib}" | sed -e 's:().*::')"
TESTS="$(grep '^@begin' "${lib_db}" | sed -e 's/^@begin{//' -e 's/}.*$//')"
FUNCTIONS_WITH_TESTS="$(printf "%s\\n" ${FUNCTIONS} ${TESTS} | awk 'x[$0]++')"

mkfifo fifo1 && mkfifo fifo2
if [ -e fifo1 ] && [ -e fifo2 ]; then
    printf "%s\\n" "${FUNCTIONS_WITH_TESTS}" > fifo1 &
    printf "%s\\n" "${FUNCTIONS}"            > fifo2 &
    FUNCTIONS_WITHOUT_TESTS="$(awk 'NR == FNR { A[$0]=1; next } !A[$0]' fifo1 fifo2)"
    rm -rf fifo1; rm -rf fifo2
fi

if [ -n "${FUNCTIONS_WITHOUT_TESTS}" ]; then
    printf "%s\\n" "Warning - functions in ${lib} without tests!, create the missing tests in ${lib_db}"
    printf "%s\\n\\n" "${FUNCTIONS_WITHOUT_TESTS}"
fi

#move to a tmp subdirectory
rm -rf test.sd || (sleep 1; rm -rf test.sd)
mkdir test.sd  || exit 1
cd test.sd     || exit 1

failed="0"
passed="0"
ran="0"

printf "%s\\n\\n" "Info - running ${lib} tests:"

for function in ${FUNCTIONS_WITH_TESTS}; do
    rm -rf ./* >/dev/null 2>&1
    printf "%s\\n" "${function} ........................" | awk '{ printf("%s ", substr($0, 0, 25)); }'
    printf "%s\\n" ". ../${lib}" > run.sh
    sed -e "/^@begin{$function}/,/^@end/p" -e '1,$d' ../${lib_db} |\
    sed -e '/^@begin/d' -e '/^@end/d' \
        -e 's/\([^\\]\)[ 	]*$/\1 || exit 1/g' >> run.sh
    printf "exit 0\\n" >> run.sh
    sh -x run.sh > run.log 2>&1
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
