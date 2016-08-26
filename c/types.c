#include <stdio.h>
#include <float.h>
#include <limits.h>

int main(void)
{
    //bool
    printf("Size of Boolean type is %d byte(s)\n\n",
	    (int)sizeof(_Bool));

    //char
    printf("Number of bits in a character: %d\n",
	    CHAR_BIT);
    printf("Size of character types is %d byte\n",
	    (int)sizeof(char));
    printf("Signed char min: %d max: %d\n",
	    SCHAR_MIN, SCHAR_MAX);
    printf("Unsigned char min: 0 max: %u\n",
	    (unsigned int)UCHAR_MAX);
    printf("Default char is ");
    if (CHAR_MIN < 0)
	printf("signed\n\n");
    else if (CHAR_MIN == 0)
	printf("unsigned\n\n");
    else
	printf("non-standard\n\n");

    //short
    printf("Size of short int types is %d bytes\n",
	    (int)sizeof(short));
    printf("Signed short min: %d max: %d\n",
	    SHRT_MIN, SHRT_MAX);
    printf("Unsigned short min: 0 max: %u\n",
	    (unsigned int)USHRT_MAX);
    printf("Default short is ");
    if (SHRT_MIN < 0)
	printf("signed\n\n");
    else if (SHRT_MIN == 0)
	printf("unsigned\n\n");
    else
	printf("non-standard\n\n");

    //int
    printf("Size of int types is %d bytes\n",
	    (int)sizeof(int));
    printf("Signed int min: %d max: %d\n",
	    INT_MIN, INT_MAX);
    printf("Unsigned int min: 0 max: %u\n",
	    (unsigned int)UINT_MAX);
    printf("Default int is ");
    if (INT_MIN < 0)
	printf("signed\n\n");
    else if (INT_MIN == 0)
	printf("unsigned\n\n");
    else
	printf("non-standard\n\n");

    //long
    printf("Size of long int types is %d bytes\n",
	    (int)sizeof(long));
    printf("Signed long min: %ld max: %ld\n",
	    LONG_MIN, LONG_MAX);
    printf("Unsigned long min: 0 max: %lu\n",
	    ULONG_MAX);
    printf("Default long is ");
    if (LONG_MIN < 0)
	printf("signed\n\n");
    else if (LONG_MIN == 0)
	printf("unsigned\n\n");
    else
	printf("non-standard\n\n");

    //long long
    printf("Size of long long types is %d bytes\n",
	    (int)sizeof(long long));
    printf("Signed long long min: %lld max: %lld\n",
	    LLONG_MIN, LLONG_MAX);
    printf("Unsigned long long min: 0 max: %llu\n",
	    ULLONG_MAX);
    printf("Default long long is ");
    if (LLONG_MIN < 0)
	printf("signed\n\n");
    else if (LLONG_MIN == 0)
	printf("unsigned\n\n");
    else
	printf("non-standard\n\n");

    //float
    printf("Size of float types is %d bytes\n",
            (int)sizeof(float));
    printf("Signed float min: %.0f max: %.0f\n",
	    FLT_MIN, FLT_MAX);
    printf("Default float is ");
    if (FLT_MIN < 0)
	printf("signed\n\n");
    else if (FLT_MIN == 0)
	printf("unsigned\n\n");
    else
	printf("non-standard\n\n");
    /*printf("Unsigned long long min: 0 max: %llu\n\n",*/
	    /*UFLT_MAX);*/

    //pointer
    printf("Size of ANY pointer is %d bytes\n",
            (int)sizeof(int *));

    return 0;
}
