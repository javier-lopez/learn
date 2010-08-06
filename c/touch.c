/*
 *a traves del sistema que yo sepa y que haya investigado no hay forma de
 *modificar la ultima estampa (ctime). utime() y utimes() solo pueden modificar
 *las primeras 2. La ultima se modifica indirectamente, cambiando la hr del
 *sistema, llamando a utime() y regresando el sistema al estado anterior. Si
 *descubres como hacerlo sin permisos de root me puedes pasar el tip, pero hasta
 *donde lei no es posible, hay varios programas en packetstorm.org (o com?) que
 *te podrian servir de inspiracion, touch*.
 *
 *he modificado tu codigo para que veas como seria, tengo que quejarme que me
 *costo un poco entender el snippet inicial, no ma, pon comentarios!
 *
 * $ rm tmp; touch tmp; stat tmp
 * $ sudo ./test
 * $ stat tmp
 */

#include <time.h>
#include <sys/time.h> //settimeofday(), gettimeofday() requieren root
#include <utime.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <string.h>
#include <stdio.h>

/* Modulo Modificar fecha y weas solo ls -la , un ls -lc y caga :S  */
/* Por p0fk! */

/*tambien he modificado el nombre de las variables, para segun yo hacerlo mas claro*/
int main(void){
    char *file= "tmp";
    time_t t_old, t_new;
    struct tm format;

    struct utimbuf u_new; //esta claro que esto define el formato, has pensado en usar
                          //un timeval en su lugar?

    printf("[+] Seleccionando archivo tmp\n");

    time(&t_old);
    printf("[+] Fecha original : %s", ctime(&t_old));

    format.tm_year        = 2001 - 1900;
    format.tm_mon         = 7 -1;
    format.tm_mday        = 4;
    format.tm_hour        = 0;
    format.tm_min         = 0;
    format.tm_sec         = 1;
    format.tm_isdst       = -1;//no entendi que hacia este

    t_new = mktime(&format); //mktime debe darle un formato adecuado (time_t)

    printf("[+] Fecha modificada: %s", ctime(&t_new));

    /*======================================*/
    struct timeval original, fake; //[get|set]timeofday() necesitan esta estructura
    fake.tv_sec=t_new; //se copia la fecha seleccionada
    fake.tv_usec=0;
    if (gettimeofday(&original, NULL) < 0) perror("52"); //nos muestra el ultimo error que haya
    if (settimeofday(&fake, NULL) < 0) perror("53");     //arrojado una funcion
    /*======================================*/

    u_new.actime  = t_new;
    u_new.modtime = t_new;

    utime(file, &u_new);

    /*======================================*/
    /* restore system time */
    printf("Change: %s",ctime( (time_t *)&fake ));
    if (settimeofday(&original, NULL) < 0) perror("63");
    /*======================================*/

    return 0;
}
/* vim: set ts=8 sw=4 tw=0 ft=c : */
