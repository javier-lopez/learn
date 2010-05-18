/**********************************************************************
 * Example who shows how the compilation works:
 *
 *      gcc -E program.c -o program.preprocessor
 *          cpp program.c program.preprocessor
 *
 *      gcc -S program.c -o program.ensemble
 *
 *      gcc -c program.ensemble -o program.object
 *          as program.ensemble -o program.object
 *
 *      gcc program.object -o program
 *          ld ....
 *
 *
 *       gcc -v program.c -o program --To see a verbose output showing the
 *       steps
 *********************************************************************/

#include <stdio.h>

int main (int argc, char const* argv[])
{
    printf("\
    Example who shows how the compilation works:\n\
\n\
      gcc -E program.c -o program.preprocessor\n\
          cpp program.c program.preprocessor\n\
\n\
      gcc -S program.c -o program.ensemble\n\
\n\
      gcc -c program.ensemble -o program.object\n\
          as program.ensemble -o program.object\n\
\n\
      gcc program.object -o program\n\
          ld ....\n\
\n\
\n\
       gcc -v program.c -o program --To see a verbose output showing the\n\
       steps\n\
            \n");
    return 0;
}
