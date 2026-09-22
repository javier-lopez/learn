Usage
-----

   ```sh
   $ sh meta.sh
   $ sh lib.sh
   $ sh tools.sh
   ```

One tool's block:

   ```sh
   $ sh tools.sh code-freeze
   ```

Part of one tool's block
------------------------

A block is one script, and what is further down it lives off the homes and
fixtures built further up: a piece taken out of the middle tests nothing. What
is sound is stopping early, because everything from `@begin` down to the end of
a section is a prefix of that same script. `-l` says where a block can be
stopped, `TESTS_UPTO` stops it there:

   ```sh
   $ sh tools.sh -l code-freeze
   $ TESTS_UPTO=renamed sh tools.sh code-freeze
   ```

A run that stopped says so on the line above it, in the column it runs in and
on the line that ends it, and never reports the block as passed.

A section is a comment in the block, `#@section{name}`, naming what follows it.
