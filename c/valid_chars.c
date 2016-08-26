/********************************************************/
/*                                                      */
/* Demonstration of character utility functions         */
/*                                                      */
/********************************************************/

/* prints out all the ASCII characters which give */
/* the value "true" for the listed character fns  */

#include <stdio.h>
#include <ctype.h>   /* contains character utilities */

#define  ALLCHARS    ch = 0; isascii(ch); ch++

/********************************************************/

int main ()           /* A criminally long main program! */
{
    char ch;

    printf ("VALID CHARACTERS FROM isalpha()\n\n");

    for (ALLCHARS)
    {
        if (isalpha(ch))
        {
            printf ("%c ",ch);
        }
    }

    printf ("\n\nVALID CHARACTERS FROM isupper()\n\n");

    for (ALLCHARS)
    {
        if (isupper(ch))
        {
            printf ("%c ",ch);
        }
    }

    printf ("\n\nVALID CHARACTERS FROM islower()\n\n");

    for (ALLCHARS)
    {
        if (islower(ch))
        {
            printf ("%c ",ch);
        }
    }

    printf ("\n\nVALID CHARACTERS FROM isdigit()\n\n");

    for (ALLCHARS)
    {
        if (isdigit(ch))
        {
            printf ("%c ",ch);
        }
    }

    printf ("\n\nVALID CHARACTERS FROM isxdigit()\n\n");

    for (ALLCHARS)
    {
        if (isxdigit(ch))
        {
            printf ("%c ",ch);
        }
    }

    printf ("\n\nVALID CHARACTERS FROM ispunct()\n\n");

    for (ALLCHARS)
    {
        if (ispunct(ch))
        {
            printf ("%c ",ch);
        }
    }

    printf ("\n\nVALID CHARACTERS FROM isalnum()\n\n");

    for (ALLCHARS)
    {
        if (isalnum(ch))
        {
            printf ("%c ",ch);
        }
    }
    printf("\n");

    return 0;
}
