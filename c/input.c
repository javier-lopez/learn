/*Q302. How can I find out whether a character has been typed, without
      waiting for one?*/


#include <stdio.h>
#include <termio.h>
#include <stdlib.h>
#include <unistd.h>


#define ON    0
#define OFF   1
#define READ  2
#define FALSE 0 == 1
#define TRUE  !FALSE
#define ETX 0x03
#define EOT 0x04

int hitkey(int select);

int main()
{
    int c;

    hitkey(ON);
    while((c = hitkey(READ)) > 0) {
        printf("%02x\n", c);
        if (c == ETX || c == EOT)
            break;
    }
    printf("\n");
    hitkey(OFF);
    exit(0);
}

int hitkey(int select) {
   static int last = OFF;
   static struct termio org;
   struct termio tmp;
   char c;
   int rv = TRUE;
   int fd = fileno(stdin);

   if (last == select) {
      return(rv);
   }

   switch(select) {
   case ON: 
        ioctl(fd, TCGETA, &org);
        ioctl(fd, TCGETA, &tmp);
        tmp.c_lflag = 0;
        tmp.c_cc[VMIN] = 1;
        tmp.c_cc[VTIME] = 0;
        ioctl(fd, TCSETA, &tmp);
        last = ON;
        break;
    case OFF:
        ioctl(fd, TCSETA, &org);
        last = OFF;
        break;
    case READ: 
        if ((rv = read(fd, &c, 1)) == 1);
            rv = c;
        break;
    default:
        fprintf(stderr, "Invalid call to hitkey()");
        exit(1);
    }
    return(rv);
}
