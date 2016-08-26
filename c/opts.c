#include <stdio.h>
#include <string.h>
#include <errno.h>

int main(int argc, char *argv[])
{
        int argi;
        int aflag = 0;
        char *bval = NULL;

        for(argi = 1; argi < argc && argv[argi][0] == '-'; argi++) {
                char *p;
                for(p = &argv[argi][1]; *p != '\0'; p++) {
                        switch(*p) {
                        case 'a':
                                aflag = 1;
                                printf("-a seen\n");
                                break;

                        case 'b':
                                bval = argv[++argi];
                                printf("-b seen (\"%s\")\n", bval);
                                break;

                        default:
                                fprintf(stderr,
                                        "unknown option -%c\n", *p);
                        }
                }
        }

        if(argi >= argc) {
                /* no filename arguments; process stdin */
                printf("processing standard input\n");
        } else {
                /* process filename arguments */

                for(; argi < argc; argi++) {
                        FILE *ifp = fopen(argv[argi], "r");
                        if(ifp == NULL) {
                                fprintf(stderr, "can't open %s: %s\n",
                                        argv[argi], strerror(errno));
                                continue;
                        }

                        printf("processing %s\n", argv[argi]);

                        fclose(ifp);
                }
        }

        return 0;
}
