#include <stdio.h>
#include <limits.h>

volatile int char_min = CHAR_MIN;

int main(void)
{
    printf("Size of Boolean type is %d byte(s)\n\n",
	    (int)sizeof(_Bool));

    printf("Number of bits in a character: %d\n",
	    CHAR_BIT);
    printf("Size of character types is %d byte\n",
	    (int)sizeof(char));
    printf("Signed char min: %d max: %d\n",
	    SCHAR_MIN, SCHAR_MAX);
    printf("Unsigned char min: 0 max: %u\n",
	    (unsigned int)UCHAR_MAX);

    printf("Default char is ");
    if (char_min < 0)
	printf("signed\n\n");
    else if (char_min == 0)
	printf("unsigned\n\n");
    else
	printf("non-standard\n\n");

    printf("Size of short int types is %d bytes\n",
	    (int)sizeof(short));
    printf("Signed short min: %d max: %d\n",
	    SHRT_MIN, SHRT_MAX);
    printf("Unsigned short min: 0 max: %u\n\n",
	    (unsigned int)USHRT_MAX);

    printf("Size of int types is %d bytes\n",
	    (int)sizeof(int));
    printf("Signed int min: %d max: %d\n",
	    INT_MIN, INT_MAX);
    printf("Unsigned int min: 0 max: %u\n\n",
	    (unsigned int)UINT_MAX);

    printf("Size of long int types is %d bytes\n",
	    (int)sizeof(long));
    printf("Signed long min: %ld max: %ld\n",
	    LONG_MIN, LONG_MAX);
    printf("Unsigned long min: 0 max: %lu\n\n",
	    ULONG_MAX);

    printf("Size of long long types is %d bytes\n",
	    (int)sizeof(long long));
    printf("Signed long long min: %lld max: %lld\n",
	    LLONG_MIN, LLONG_MAX);
    printf("Unsigned long long min: 0 max: %llu\n",
	    ULLONG_MAX);

    return 0;
}
