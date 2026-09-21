#!/bin/sh
#Based on the GNU shtool test suite

tools="../tools/"
tools_db="./tools.db"

#database exist?
[ -d "${tools}" ]    || exit 1
[ -f "${tools_db}" ] || exit 1

#override temp debug string, avoid "Bad substitution" errors
PS4=">>"

#a block is one script and its later lines live off the homes and fixtures the
#earlier ones built, so a piece taken out of the middle is not a test of
#anything. What is sound is stopping early: everything from @begin to the end
#of a section is a prefix of the same script. A section is the comment
##@section{name}, which names what follows it and is a comment for the same
#reason the topic comments around it are - a whole run does not see it
sections() {
    sed -e "/^@begin{${1}}/,/^@end/p" -e '1,$d' "${tools_db}" |\
    sed -n -e 's/^#@section{\([^}]*\)}.*$/\1/p'
}

#everything a block has up to the end of the section asked for. The section
#after the one asked for ends the prefix, and the rest is read and dropped
#rather than closing the pipe on the sed that feeds this
upto_cut() {
    if [ -z "${TESTS_UPTO}" ]; then
        cat
    else
        awk -v upto="${TESTS_UPTO}" '
            index($0, "#@section{") == 1 {
                name = substr($0, 11); brace = index(name, "}")
                if (brace > 0) { name = substr(name, 1, brace - 1) }
                if (seen == 1) { past = 1 } else if (name == upto) { seen = 1 }
            }
            past != 1 { print }'
    fi
}

#test tools
#a tool is a file directly in the tools directory. What sits in a directory
#next to one supports that
#tool and is not a command, so the search does not descend. -maxdepth is not
#posix; pruning everything below the starting point is
TOOLS="$(find "${tools}". ! -name . -prune -type f -exec basename '{}' ';')"
TESTS="$(grep '^@begin' "${tools_db}" | sed -e 's/^@begin{//' -e 's/}.*$//')"

#-l says where a run may be told to stop, for one tool or for every tool that
#has anywhere to stop, and runs nothing
if [ X"${1}" = X"-l" ]; then
    for tool in ${2:-${TESTS}}; do
        tool_sections="$(sections "${tool}")"
        if [ -n "${tool_sections}" ]; then
            printf "%s\\n" "${tool}: TESTS_UPTO=<section> sh tools.sh ${tool} stops the block at the end of"
            printf "%s\\n" "${tool_sections}" | awk '{ printf("  %2d %s\n", NR, $0) }'
        elif [ -n "${2}" ]; then
            printf "%s\\n" "${tool}: no sections, so the whole block is the only thing to run"
        fi
    done
    exit 0
fi

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

#a run that stops early stops one block at a section that block has, and both
#are settled before a sandbox is made, so a name nobody has does nothing at all
if [ -n "${TESTS_UPTO}" ]; then
    set -- ${1}
    if [ "${#}" -ne "1" ]; then
        printf "%s\\n" "Error - TESTS_UPTO stops one block: TESTS_UPTO=${TESTS_UPTO} sh tools.sh <tool>" >&2
        exit 1
    fi
    upto_nth="$(sections "${1}" | grep -n -x -F -e "${TESTS_UPTO}" | sed -e 's/:.*$//')"
    upto_of="$(sections "${1}" | grep -c .)"
    if [ -z "${upto_nth}" ]; then
        printf "%s\\n" "Error - ${1} has no section '${TESTS_UPTO}', sh tools.sh -l ${1} says which it has" >&2
        exit 1
    fi
fi

#move to a tmp subdirectory
rm -rf test.sd || (sleep 1; rm -rf test.sd)
mkdir test.sd  || exit 1
cd test.sd     || exit 1

failed="0"
passed="0"
ran="0"

if [ -z "${TESTS_UPTO}" ]; then
    printf "%s\\n\\n" "Info - running ${tools} tests:"
else
    printf "%s\\n\\n" "Info - running ${tools} tests: ${1} down to the end of section '${TESTS_UPTO}' (${upto_nth} of ${upto_of}), a prefix of its block and not the block:"
fi

[ -z "${1}" ] || TOOLS_WITH_TEST="${1}"

for tool in ${TOOLS_WITH_TEST}; do
    rm -rf ./* || (sleep 1; rm -rf ./*)
    printf "%s\\n" "${tool}${TESTS_UPTO:+:${TESTS_UPTO}} ........................" | awk '{ printf("%s ", substr($0, 0, 25)); }'
    printf "%s\\n" "PATH=../${tools}:/bin:/usr/bin" > run.sh
    sed -e "/^@begin{$tool}/,/^@end/p" -e '1,$d' ../${tools_db} | upto_cut |\
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
#a prefix answers for itself and never for the block: what it says is what it
#ran and how far it got, and the word the whole suite passes with is not there
if [ -n "${TESTS_UPTO}" ]; then
    if [ "${failed}" -gt "0" ]; then
        printf "PREFIX FAILED: ${1} down to '${TESTS_UPTO}', section ${upto_nth} of ${upto_of}\\n"
        exit 1
    else
        printf "PREFIX ok: ${1} down to '${TESTS_UPTO}', section ${upto_nth} of ${upto_of}; a prefix is not the block and does not pass it\\n"
        exit 0
    fi
fi

if [ "${failed}" -gt "0" ]; then
    printf "FAILED: passed: ${passed}/${ran}, failed: ${failed}/${ran}\\n"
    exit 1
else
    printf "OK: passed: ${passed}/${ran}\\n"
fi

# vim: set ts=8 sw=4 tw=0 ft=sh :
