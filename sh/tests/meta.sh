#!/bin/sh
#Based on the GNU shtool test suite
#
#the runner had nothing testing it: tools.db keys its blocks by tool and
#tools.sh is not a tool, so the thing that runs every block was the one thing
#here nobody ran. What is tested below is the part of it that would be silent
#when wrong - a run told to stop at a section, which has to stop where it says
#it stopped and has to be impossible to read as a run of the whole block, and
#a name it has no block for, which it has to refuse rather than run as the
#empty script that name extracts
#
#the runner is run as it is really run, against a tools directory and a
#tools.db of three tools built here: it takes its paths relative to itself, so
#a copy of it in a directory laid out the same way is the real thing under test

runner="./tools.sh"

[ -f "${runner}" ] || exit 1

#a block writes the sections it reached into a file outside the sandbox the
#runner wipes, which is how a stop is seen to have stopped where it says
sd="$(pwd)/meta.sd"
PREFIX_TEST_OUT="${sd}/reached"; export PREFIX_TEST_OUT

rm -rf "${sd}" || (sleep 1; rm -rf "${sd}")
mkdir -p "${sd}/tools" "${sd}/tests" || exit 1
cp "${runner}" "${sd}/tests/tools.sh"                                  || exit 1
for t in alpha beta gamma; do
    printf "%s\\n" '#!/bin/sh' 'exit 0' > "${sd}/tools/${t}"           || exit 1
    chmod 755 "${sd}/tools/${t}"                                       || exit 1
done

cat > "${sd}/tests/tools.db" <<'EOD'
@begin{alpha}
printf "head\n" >> "${PREFIX_TEST_OUT}"
#@section{one}
printf "one\n" >> "${PREFIX_TEST_OUT}"
#@section{two}
printf "two\n" >> "${PREFIX_TEST_OUT}"
#@section{three}
printf "three\n" >> "${PREFIX_TEST_OUT}"
@end
@begin{beta}
printf "beta\n" >> "${PREFIX_TEST_OUT}"
@end
@begin{gamma}
#@section{good}
true
#@section{bad}
false
@end
EOD
[ -f "${sd}/tests/tools.db" ] || exit 1

failed="0"
passed="0"
ran="0"
why=""
upto=""

#every run below is that copy of the runner, started from the directory it
#expects, with what it is told to stop at passed the way a user passes it. Its
#output, its status and the sections the block reached are all that is looked at
run() {
    if [ -n "${upto}" ]; then
        TESTS_UPTO="${upto}"; export TESTS_UPTO
    else
        unset TESTS_UPTO
    fi
    rm -f "${PREFIX_TEST_OUT}"
    ( cd "${sd}/tests" && sh tools.sh "${@}" > "${sd}/out" 2>"${sd}/err" )
    rc="${?}"
    out="$(cat "${sd}/out")"
    err="$(cat "${sd}/err")"
    return 0
}

reached() {
    [ -f "${PREFIX_TEST_OUT}" ] || return 0
    tr '\n' ' ' < "${PREFIX_TEST_OUT}"
}

line() {
    printf "%s\\n" "${out}" | sed -n -e "${1}p"
}

is() {
    [ X"${2}" = X"${3}" ] && return 0
    why="${why}${why:+; }${1}: wanted [${3}], got [${2}]"
    return 1
}

has() {
    printf "%s\\n" "${2}" | grep -q -e "${3}" && return 0
    why="${why}${why:+; }${1}: nothing matching [${3}]"
    return 1
}

hasnt() {
    printf "%s\\n" "${2}" | grep -q -e "${3}" || return 0
    why="${why}${why:+; }${1}: something matches [${3}] and nothing should"
    return 1
}

#a run nobody told to stop is the run it always was: the same three lines, the
#whole block, and the word the suite passes with
t_whole() {
    run alpha                                                          || return 1
    is status "${rc}" "0"                                              || return 1
    is reached "$(reached)" "head one two three "                      || return 1
    is header "$(line 1)" "Info - running ../tools/ tests:"            || return 1
    has column "${out}" '^alpha \.* ok$'                               || return 1
    is result "$(line '$')" "OK: passed: 1/1"                          || return 1
    is quiet "${err}" ""
}

#and a block with no sections in it runs as it always did too
t_whole_unmarked() {
    run beta                                                           || return 1
    is status "${rc}" "0"                                              || return 1
    is reached "$(reached)" "beta "                                    || return 1
    is result "$(line '$')" "OK: passed: 1/1"
}

#-l says where a run may be told to stop, in the order the block has them
t_list() {
    run -l alpha                                                       || return 1
    is status "${rc}" "0"                                              || return 1
    is names "$(printf "%s\\n" "${out}" | awk 'NR > 1 { print $2 }' | tr '\n' ' ')" \
        "one two three "                                               || return 1
    is numbers "$(printf "%s\\n" "${out}" | awk 'NR > 1 { print $1 }' | tr '\n' ' ')" \
        "1 2 3 "                                                       || return 1
    is nothing_ran "$(reached)" ""
}

#a tool with nowhere to stop says so when it is the one asked about, and a
#listing of everything leaves it out instead of printing an empty heading
t_list_unmarked() {
    run -l beta                                                        || return 1
    has said "${out}" '^beta: no sections'                             || return 1
    run -l                                                             || return 1
    has alpha "${out}" '^alpha:'                                       || return 1
    hasnt beta "${out}" '^beta:'                                       || return 1
    has gamma "${out}" '^gamma:'
}

#told to stop at a section, the run is everything from the top of the block to
#the end of that section, and nothing below it
t_prefix() {
    upto="two"; run alpha                                              || return 1
    is status "${rc}" "0"                                              || return 1
    is reached "$(reached)" "head one two "
}

#the first section carries what is above it, which is in no section
t_prefix_first() {
    upto="one"; run alpha                                              || return 1
    is reached "$(reached)" "head one "
}

#and the last is the whole block, announced as a prefix all the same
t_prefix_last() {
    upto="three"; run alpha                                            || return 1
    is reached "$(reached)" "head one two three "                      || return 1
    has result "${out}" "^PREFIX ok: alpha down to 'three', section 3 of 3;"
}

#a prefix says so where a run is read: the line above it, the column it runs
#in, and the last line, which never carries the word the suite passes with
t_prefix_says_so() {
    upto="two"; run alpha                                              || return 1
    has header "${out}" "^Info - .* alpha down to the end of section 'two' (2 of 3), a prefix of its block and not the block:$" || return 1
    has column "${out}" '^alpha:two \.* ok$'                           || return 1
    has result "${out}" "^PREFIX ok: alpha down to 'two', section 2 of 3; a prefix is not the block and does not pass it$" || return 1
    hasnt passed "${out}" '^OK: passed'
}

#a prefix that fails is a failure, said the same way and with the status
t_prefix_failure() {
    upto="bad"; run gamma                                              || return 1
    is status "${rc}" "1"                                              || return 1
    has result "${out}" "^PREFIX FAILED: gamma down to 'bad', section 2 of 2$" || return 1
    hasnt passed "${out}" '^OK: passed'                                || return 1
    upto="good"; run gamma                                             || return 1
    is good_status "${rc}" "0"
}

#a section nobody has stops the run before anything is run, says where to look
#for the names there are, and leaves nothing of a run behind
t_prefix_unknown() {
    upto="nosuch"; run alpha                                           || return 1
    is status "${rc}" "1"                                              || return 1
    has said "${err}" "^Error - alpha has no section 'nosuch', sh tools.sh -l alpha" || return 1
    is nothing_ran "$(reached)" ""                                     || return 1
    is nothing_said "${out}" ""                                        || return 1
    [ ! -d "${sd}/tests/test.sd" ] && return 0
    why="${why}${why:+; }unknown: a sandbox was made for a run that never happened"
    return 1
}

#a name the database has no block for is refused before anything is run: it
#would extract an empty script, and an empty script is one that exits 0, so a
#typo would be read as a tool that ran and passed
t_unknown_tool() {
    run nosuchtool                                                     || return 1
    is status "${rc}" "1"                                              || return 1
    has said "${err}" "^Error - .* has no test for 'nosuchtool'"       || return 1
    is nothing_said "${out}" ""                                        || return 1
    hasnt ok "${out}" 'ok'                                             || return 1
    [ ! -d "${sd}/tests/test.sd" ] && return 0
    why="${why}${why:+; }unknown: a sandbox was made for a run that never happened"
    return 1
}

#what is given is a list and every name in it is checked, with the one that is
#wrong named and the ones that are right left out of it and not run either
t_unknown_tool_in_list() {
    run "alpha nosuchtool"                                             || return 1
    is status "${rc}" "1"                                              || return 1
    has said "${err}" "^Error - .* has no test for 'nosuchtool'"       || return 1
    hasnt alpha "${err}" "'alpha'"                                     || return 1
    is nothing_ran "$(reached)" ""
}

#a run nobody gave a name to is every block the database has, in its order
t_all() {
    run                                                                || return 1
    is status "${rc}" "1"                                              || return 1
    is reached "$(reached)" "head one two three beta "                 || return 1
    has alpha "${out}" '^alpha \.* ok$'                                || return 1
    has beta "${out}" '^beta \.* ok$'                                  || return 1
    has gamma "${out}" '^gamma \.* FAILED$'                            || return 1
    is result "$(line '$')" "FAILED: passed: 2/3, failed: 1/3"
}

#and a stop is one block's: two tools, or none, is nothing to stop
t_prefix_one_tool() {
    upto="two"; run "alpha beta"                                       || return 1
    is two_status "${rc}" "1"                                          || return 1
    has two_said "${err}" '^Error - TESTS_UPTO stops one block'        || return 1
    is two_ran "$(reached)" ""                                         || return 1
    upto="two"; run                                                    || return 1
    is none_status "${rc}" "1"                                         || return 1
    has none_said "${err}" '^Error - TESTS_UPTO stops one block'       || return 1
    is none_ran "$(reached)" ""
}

printf "%s\\n\\n" "Info - running ${runner} tests:"

for t in t_whole t_whole_unmarked t_list t_list_unmarked t_prefix \
         t_prefix_first t_prefix_last t_prefix_says_so t_prefix_failure \
         t_prefix_unknown t_unknown_tool t_unknown_tool_in_list t_all \
         t_prefix_one_tool; do
    why=""
    upto=""
    printf "%s\\n" "${t} ........................" | awk '{ printf("%s ", substr($0, 0, 25)); }'
    if "${t}"; then
        passed="$((${passed} + 1))"
        printf "ok\\n"
    else
        printf "FAILED\\n"
        printf "+---Why-------------------------------\\n"
        printf "%s\\n" "${why}" | sed -e 's/^/| /g'
        printf "+-------------------------------------\\n"
        failed="$((${failed} + 1))"
    fi
    ran="$((${ran} + 1))"
done

rm -rf "${sd}" >/dev/null 2>&1

#result
if [ "${failed}" -gt "0" ]; then
    printf "FAILED: passed: ${passed}/${ran}, failed: ${failed}/${ran}\\n"
    exit 1
else
    printf "OK: passed: ${passed}/${ran}\\n"
fi

# vim: set ts=8 sw=4 tw=0 ft=sh :
