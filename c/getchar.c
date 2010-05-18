#include <stdio.h>
#include <termios.h>

//static struct termio savemodes;
//static int havemodes = 0;

/*int tty_break()
{
        struct termio modmodes;
        if(ioctl(fileno(stdin), TCGETA, &savemodes) < 0)
                return -1;
        havemodes = 1;
        modmodes = savemodes;
        modmodes.c_lflag &= ~ECHO; // echo off 
        modmodes.c_lflag &= ~ICANON;  only one character at a time 
        modmodes.c_cc[VMIN] = 1;
        modmodes.c_cc[VTIME] = 0;
        return ioctl(fileno(stdin), TCSETAW, &modmodes);
}*/

int tty_getchar()
{
        return getchar();
}

/*int tty_fix()
{
        if(!havemodes)
                return 0;
        return ioctl(fileno(stdin), TCSETAW, &savemodes);
}*/

struct termios stable;
main()
{
        int i;
//        system("stty -echo");
        if(tty_break(&stable) != 0)
                return -1;
        for(i = 0; i < 15; i++){
                printf("\t%d\n", tty_getchar());}
        tty_fix(&stable);
//        system("stty echo");
        return 0;
}

/*      windows
int tty_break() { return 0; }

int tty_getchar()
{
        return getche();
}

int tty_fix() { return 0; }
*/
int tty_break(struct termios *stable)
{
    struct termios new;
    char ch;

    tcgetattr(fileno(stdin), stable);
    new=*stable;
    new.c_lflag &= ~(ECHO | ICANON);
    new.c_cc[VMIN] = 1;
    return tcsetattr(fileno(stdin), TCSANOW, &new);
}

int tty_fix(struct termios *stable)
{
    tcsetattr(fileno(stdin), TCSANOW, stable);
    return 0;
}
