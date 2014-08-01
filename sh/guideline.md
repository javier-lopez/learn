## Personal guidelines for sh scripting

- Avoid syntax or semantics unique to bash, zsh, or any other specific shell, eg:
    - array contructs
    - `<()` or `>()`
    - `{a,b,c}` or `{1..10}`
    - `function` keyword at the beginning of a function
    - C-like for loops, `for ((i=0; i<3; i++))`
- Avoid `basename`, use `expr` or substrings (${variable##\*/}) instead
- Use `=` over `==`
- Use `[` or `test` over `[[`
- Use `case` over `test` or `[` for regex
- Use `command -v` over `which`
- Use `awk` over `sed`, `grep`, `cut`, `sort`, `tr` or `unique`
- Use `/bin/sh` over `/bin/bash` or `/usr/bin/env sh`
- Use `$(foo)` over `foo`
- Use `$((${i}+1))` over `$(expr "${i}" + 1)`
- Use `:` as a sed separator, eg: `sed -e 's:foo:bar:'`
- Use lowercase over uppercase, except in vars users will interact with, eg: `PROGNAME_ENV`
- Use spaces over tabs
- Use braces around variables, eg, 

  **Bad**
   ```sh
   var="$foo"
   var="$foo$bar"
   var="/path/$foo.suffix"
   ```

  **Good**
   ```sh
   var="${foo}"
   var="${foo}${bar}"
   var="/path/${foo}.suffix"
   ```
- Prefer minimal style, except in functions:

  **Bad**
   ```sh
   if foo
   then
       bar
   fi

   if [ -z "${foo}" ]; then
       cmd
   fi

   if [ -z "${foo}" ]; then
       cmd
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

   [ -z "${foo}" ] && cmd

   [ -z "${foo}" ] && cmd || other_cmd

   _function()
   {
       steps
   }
   ```
- Local variables should be named after their function name, avoid `local`

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

- Use quotes when assigning values to variables, use single quotes when absolutely necesary

  **Bad**
   ```sh
   foo=bar
   bar=${foo}
   ```

  **Good**
   ```sh
   foo="bar"
   bar="${foo}"
   ```
- Use `printf` over `echo` (specially when echoing ${vars})

  **Bad**
   ```sh
   echo "${foo}"
   ```

  **Good**
   ```sh
   printf "%s\\n" "${foo}"
   ```
- Avoid fixed paths in commands:

  **Bad**
   ```sh
   [ -f /usr/bin/ps ] && /usr/bin/ps
   ```

  **Good**
   ```sh
   if command -v "ps" > /dev/null; then
       $(command -v "ps")
   fi
   ```

  **Best**
   ```sh
   [ -f "$(command -v "mplayer")" ] && $(command -v "mplayer")
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
- Do NOT write to the file system, save to a var or use pipes instead

  **Bad**
   ```sh
   ls > /tmp/ls.output
   cat /tmp/ls.output && rm /tmp/ls.output
   ```

  **Good**
   ```sh
   ls_output="$(ls)"
   printf "%s\\n" "${ls_output}"
   ```

  **Best**
   ```sh
   printf "%s\\n" "$(ls)"
   ```
- On string comparations use X as a prefix

  **Bad**
   ```sh
   [ "${cmd}" = "foo" ] && cmd
   ```

  **Good**
   ```sh
   [ X"${cmd}" = X"foo" ] && cmd
   ```
- Use `||` and `&&` over `-a` and `-o`

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
