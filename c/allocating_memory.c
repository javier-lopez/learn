#include <stdio.h>
#include <stdlib.h>


int main(int argc, char const* argv[])
{
    int *i=NULL, *j=NULL;

    printf("Address of *i: %p\n", i);
    printf("Address of *j: %p\n", j);

    printf("Allocating memory sizeof(int) to i,j\n");
    i=(int *)malloc(sizeof(int)); //int i
    j=(int *)malloc(sizeof(int)); //int j

    printf("Inserting 5 to *i\n");
    printf("Inserting 10 to *j\n");

    *i=5;
    *j=10;

    printf("i: %d\n", *i);
    printf("j: %d\n", *j);

    printf("Freeing memory...\n");
    free(i);
    free(j);

    fflush(stdout);
    if (ferror(stdout))
        exit(EXIT_FAILURE);
    return EXIT_SUCCESS;
}
