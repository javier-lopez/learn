/**********************************************************************
 * Random snippets I've taken from random sources, only for educational
 * purposes - Code Reading The Open Source Perspective
 *********************************************************************/

/*netbsd/src/bin/echo/echo.c*/
/* This utility may NOT do getopt(3) option parsing. */
/**********************************************************************
 * *++argv is the second [1] var in the argv[] array, it can be viewed
 * by using a previous printf statement, printf(%s, *(argv+1));
 *********************************************************************/
if (*++argv && !strcmp(*argv, "-n")) {
        ++argv;
        nflag = 1;
}
