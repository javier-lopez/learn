#include <stdio.h>
#include <stdlib.h>

int main(int argc, char const* argv[])
{
    int i, lotsa=10;
    for(i = 0; i < lotsa; i++) {
        printf("\r%3d%%", (int)(100L * i / lotsa));
        fflush(stdout);
        system("sleep 1");
    }
    printf("\ndone.\n");

    return 0;
}
   
