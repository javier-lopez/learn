#include <stdio.h>
#include <stdlib.h>

/**********************************************************************
 * ----
 * j 1
 * k
 * l
 * m 4
 * ----
 * j=k
 * l=&j
 * *l=m
 *********************************************************************/


int main(int argc, char const* argv[])
{
    int j=1, k=2, *l=NULL, m=4;
    printf("j = %i\n", j);
    printf("k = %i\n", k);
    printf("*l = %i\n", *l);
    printf("*m = %i\n", m);

    printf("j = k ;\n");
    j=k;
    printf("k = %i;\n", k);

    printf("l = &j;\n");
    l=&j;
    printf("l = %p;\n", l);

    printf("*l = m;\n");
    *l=m;
    printf("*l = %i;\n", *l);
    printf("m = %i;\n", m);
    printf("j = %i;\n", j);

    fflush(stdout);                                                                                                                                                 
    if (ferror(stdout))
        exit(EXIT_FAILURE);
    return EXIT_SUCCESS;
}
