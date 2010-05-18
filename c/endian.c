#include <stdio.h>
 
int main(void)
{
   int i = 1; /* i = 0x0001 */
   char *p = (char *) &i;
   if ( p[0] == 1 )
        /* i    = 0x0100 it's twisted */
        /* p[0] = 0x01 */
        /* p[1] = 0x00 */
        printf("Little Endian\n");
   else
        /* i    = 0x0001 */
        /* p[0] = 0x00 */
        /* p[1] = 0x01 */
        printf("Big Endian\n");
   return 0;
}

