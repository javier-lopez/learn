#include <stdio.h>
#include <stdlib.h>

int main(int argc, char const* argv[])
{
    int i, lotsa=10;
    printf("working: ");
    for(i = 0; i < lotsa; i++) {
        printf("%c\b", "|/-\\"[i%4]);
        fflush(stdout);
        system("sleep 1");
    }
    printf("done.\n");
    return 0;
}
   
