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

#A python 2 script added tomorrow must not slip in unnoticed. The list of
#files to check is the directory itself rather than a list kept by hand, so a
#new tool is covered the moment it lands and nobody has to remember anything.
#The interpreters are pinned by digest: "python:2.7-slim" is whatever was last
#pushed under that name, and a check that changes underneath you checks nothing
_PY2="python@sha256:6c1ffdff499e29ea663e6e67c9b6b9a3b401d554d2c9f061f9a45344e3992363"
_PY3="python@sha256:ffb752e139c0a19692a43af8d8523b274222dd68eebad5d583b45c2201c6e30a"

#skipped on a single tool run, and where there is no docker to run it in
if [ -z "${1}" ] && command -v docker >/dev/null 2>&1; then
    #a tool declares which pythons it is for in its own first line, and there
    #is nowhere else to declare it. The sh header means both, and then both
    #have to be able to read it; "#!/usr/bin/env python3" means what it says
    #and is taken at its word. Anything else - python, python2, no shebang at
    #all - is a script that will not start on some machine this repository is
    #meant for, and says so by failing here
    guard_both=""
    guard_bad=""
    for f in "${tools}"/*; do
        [ -f "${f}" ] || continue
        case "$(head -1 "${f}")" in
            "#!/bin/sh")               guard_both="${guard_both} ${f##*/}" ;;
            "#!/usr/bin/env python3")  ;;
            *) guard_bad="${guard_bad} ${f##*/}" ;;
        esac
    done

    if [ -n "${guard_bad}" ]; then
        printf "%s\\n" "FAILED - shebang says nothing this repository can run:${guard_bad}" >&2
        printf "%s\\n" "         use the two line sh header for a python 2 and 3 polyglot," >&2
        printf "%s\\n" "         or '#!/usr/bin/env python3' for one that is python 3 only" >&2
        exit 1
    fi

    #the polyglots parse under both, one container per interpreter. The list
    #comes from the directory, so a tool added tomorrow is covered without
    #anyone remembering to list it anywhere
    printf "%s\\n" "import sys" "for f in sys.argv[1:]:" \
        "    compile(open('/w/' + f).read(), f, 'exec')" > /tmp/compile_all.$$.py
    for guard_img in "${_PY2}" "${_PY3}"; do
        docker run --rm -v "$(cd "${tools}" && pwd)":/w:ro \
            -v /tmp:/t:ro "${guard_img}" \
            python /t/compile_all.$$.py ${guard_both} || {
                printf "%s\\n" "FAILED - does not parse under ${guard_img}" >&2
                rm -f /tmp/compile_all.$$.py; exit 1; }
    done
    rm -f /tmp/compile_all.$$.py
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
    rm -rf ./* || (sleep 1; rm -rf ./*)
    printf "%s\\n" "${tool} ........................" | awk '{ printf("%s ", substr($0, 0, 25)); }'
    printf "%s\\n" "PATH=../${tools}:/bin:/usr/bin" > run.sh
    sed -e "/^@begin{$tool}/,/^@end/p" -e '1,$d' ../${tools_db} |\
    sed -e '/^@begin/d' -e '/^@end/d' \
        -e 's/\([^\\]\)[ 	]*$/\1 || exit 1/g' >> run.sh
    printf "exit 0\\n" >> run.sh
    #stdin is closed, not inherited: 32 of these tools read their arguments
    #from stdin when it is not a terminal, so a runner started from cron, CI
    #or a pipeline hands them an idle descriptor they wait on forever. A block
    #that wants to pipe something in writes the pipe itself
    sh -x run.sh        > run.log 2>&1 </dev/null
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

#the sandbox goes whether the run passed or not. Keeping it after a failure
#reads like forensics and is not: every tool wipes the directory before it
#runs, so what survives to the end belongs to the last tool, not to the one
#that failed. The script and the log of the failure are printed above, in full
cd .. && rm -rf test.sd >/dev/null 2>&1

#result
if [ "${failed}" -gt "0" ]; then
    printf "FAILED: passed: ${passed}/${ran}, failed: ${failed}/${ran}\\n"
    exit 1
else
    printf "OK: passed: ${passed}/${ran}\\n"
fi

# vim: set ts=8 sw=4 tw=0 ft=sh :
