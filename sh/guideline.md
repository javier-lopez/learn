## Personal guidelines for sh scripting

- Don't use syntax or semantics unique to Bash, for example, array contructs
- Use `/usr/bin/env sh` over `/bin/sh`
- Use `$(foo)` over `foo`
- Use `$(expr $i + 1)` over `$((i+1))`
- Use spaces over tabs
- Prefer lowercase over uppercase in everything, except on vars which users will have to deal with, eg: `PROGNAME_ENV`
- Generally lines are 80 chars at maximum
- Prefer minimalism style, except on functions:

  **Bad**
   ```sh
   if foo
   then
       bar
   fi

   if [ -z "${foo}" ]; then
       single_cmd
   fi

   if [ -z "${foo}" ]; then
       single_cmd
   else
       other_cmd
   fi

   _function() {
       steps
   }
   ```

  **Good**
   ```sh
   if foo; then
       bar
   fi

   [ -z "${foo}" ] && single_cmd

   [ -z "${foo}" ] && single_cmd || other_cmd

   _function()
   {
       steps
   }
   ```
- Local variables should be named after their function name, avoid using `local`

  **Bad**
   ```sh
   _foo()
   {
       local first_argument="${1}"
   }
   ```

  **Good**
   ```sh
   _foo()
   {
       _foo_var_first_argument="${1}"
   }
   ```
- Use braces around variables, eg. `${foo}` instead of `$foo`
- Use quotes when assigning values to variables, use single quotes when absolutely necesary

  **Bad**
   ```sh
   foo=bar
   bar=$foo
   ```

  **Good**
   ```sh
   foo="bar"
   bar="${foo}"
   ```
- Avoid `echo`, use `printf` instead (specially when echoing ${vars})

  **Bad**
   ```sh
   echo "${foo}"
   ```

  **Good**
   ```sh
   printf "%s\\n" "${foo}"
   ```
- Avoid `[[`, use `[` or `test` instead 
- Avoid `which`, use `command -v` or `type` instead 
- Avoid `basename`, use `expr` instead
- Avoid fixed paths:

  **Bad**
   ```sh
   [ -f /usr/bin/mplayer ] && single_cmd
   ```

  **Good**
   ```sh
   if command -v "mplayer" > /dev/null; then
       single_cmd
   fi
   ```

  **Best**
   ```sh
   [ -f "$(command -v "mplayer")" ] && single_cmd
   ```
- Avoid -q in grep

   **Bad**
   ```sh
   ls | grep -qs file && return 0
   ```

   **Good**
   ```sh
   ls | grep file >/dev/null && return 0
   ```
- Avoid writing to the file system, use in memory outputs instead

  **Bad**
   ```sh
   ls > /tmp/ls.output
   cat /tmp/ls.output && rm /tmp/ls.output
   ```

  **Good**
   ```sh
   ls_output=$(ls)
   printf "%s\\n" "${ls_output}"
   ```

  **Best**
   ```sh
   printf "%s\\n" "$(ls)"
   ```
- Prefer `awk` over `sed`, `grep`, `cut`, `sort`, `tr` and `unique`
- Use `case` over `test` when posible
- On string comparations use X as a prefix for comparitions, avoid errors when ${vars} contain '-'

  **Bad**
   ```sh
   [ "${cmd}" = "foo" ] && single_cmd
   ```

  **Good**
   ```sh
   [ X"${cmd}" = X"foo" ] && single_cmd
   ```
- Use `:` as a separator for `sed`, eg: `sed -e 's:foo:bar:'`
- Prefer `||` and `&&` over `-a` and `-o`

  **Bad**
   ```sh
   if [ "-d" = "${1}" -o "--delete" = "${1}" ]; then
       foo
   fi
   ```

  **Good**
   ```sh
   if [ X"-d" = X"${1}" ] || [ X"--delete" = "${1}" ]; then
       foo
   fi
   ```
