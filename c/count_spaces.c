#include <stdio.h>
#include <stdlib.h>

int main (void)

{
    char ch;
    short count = 0;

    printf ("Type in a line of text\n");

    while ((ch = getchar()) != '\n')
    {
        if (ch == ' ')
        {
            count++;
        }
    }

    printf ("Number of space = %d\n",count);
    exit(EXIT_SUCCESS);
}
