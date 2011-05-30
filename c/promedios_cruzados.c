/**********************************************************************
 * UAM/Cuajimalpa - Estructura de datos - Calificaciones cruzadas
 * $ gcc -Wall 6.c -o 6
 * P.L. Francisco Javier <fco.plj@gmail.com> Matricula:210368224
 * Preguntas:
 * TODO 13-05-2011 11:44 => Como prevenir que scanf acepte teclas de
 *                          control, flecha arriba, abajo, ctrl, esc
 * TODO 13-05-2011 11:49 => Como hacer uso de i10n con printf
 *********************************************************************/
#include <stdio.h>
#include <stdlib.h>  /* atoi()    */
#include <ctype.h>   /* isdigit() */
#include <string.h>  /* strlen()  */
#define len      5
#define width    4

#ifdef _WIN32
    #include <windows.h>
    #include <conio.h>
    #define clear               "cls"
    #define sleep(x)            Sleep((x)*1000)
    #define without_echo()
    #define with_echo()
    #define get_char()          get_charWin()
    int get_charWin (void)      { return getche();}
#else
    #include <unistd.h>
    #define clear               "clear"
    #define sleep(x)            usleep((x)*1000000)
    #define without_echo()      system("/bin/stty cbreak")
    #define with_echo()         system("/bin/stty -cbreak")
    #define get_char()          get_charLin()
    int get_charLin (void)      { return getchar();}
#endif

void printMatrix (int matrix[width][len]);
int enterInt(void);
int isNumber(char *string);

int main(int argc, char const* argv[])
{
    int matrix[width][len], sum=0, notvalid=0, i, j;
    float average=0;

    system(clear);
    printf("\tINSTRUCCIONES:\n\n\
                    Introduzca sus calificaciones [1-10]\n");

    for (i = 0; i < width; i++) //initialize
    {
        for (j = 0; j < len; j++)
        {
            matrix[i][j]=0;
        }
    }
    printMatrix(matrix); //print empty matrix
    printf("\n\t\t> ");

    //fill matrix
    for (i = 0; i < width; i++)
    {
        for (j = 0; j < len; j++)
        {
            if (matrix[i][j]==0)
            {
                if ((matrix[i][j]=enterInt()) == -1) {notvalid=1; matrix[i][j]=0; j--;} //restore values
                if (notvalid)
                {
                    notvalid=0;
                    system(clear);
                    printf("\tINSTRUCCIONES:\n\n\
                    Introduzca sus calificaciones [1-10]\n");
                    printMatrix(matrix);
                    without_echo();
                    printf("\n\t\tCalificacion invalida, presione cualquier tecla para continuar...");
                    get_char();
                    with_echo();

                    system(clear);
                    printf("\tINSTRUCCIONES:\n\n\
                    Introduzca sus calificaciones [1-10]\n");
                    printMatrix(matrix);
                    printf("\n\t\t> ");
                }
                else
                {
                    system(clear);
                    printf("\tINSTRUCCIONES:\n\n\
                    Introduzca sus calificaciones [1-10]\n");
                    printMatrix(matrix);
                    printf("\n\t\t> ");
                }
            }
            if (i==(width-1)&&j==(len-1))printf("\n\n"); /*ayuda a limpiar la pantalla*/
        }
    }
    
    //animation, 3 seconds
    system(clear);
    printf("\tINSTRUCCIONES:\n\n\
                    Introduzca sus calificaciones [1-10]\n");
    printMatrix(matrix);

    printf("\n\t\tCalculando . . . ");
    for (i = 0; i < 3; i++)
    {
        printf("%c\b", "|/-\\"[i%4]);
        fflush(stdout);
        sleep(1);
    }

    //results
    system(clear);
    printf("\tINSTRUCCIONES:\n\n\
                    Introduzca sus calificaciones [1-10]\n");
    printf("\n");

    //custom printMatrix statements
    for (i = 0; i < width; i++)
    {
        printf("\t\t\t    ---------------------\n\t\t\t    ");
        for (j = 0; j < len; j++)
        {
            printf("| %d ", matrix[i][j]);
            sum+=matrix[i][j];
        }
        average=sum/len; sum=0;
        printf("| -> %1.1f\n", average);
    }
    printf("\t\t\t    ---------------------\n");

    printf("\t\t\t    ");
    for (j = 0; j < len; j++)
    {
        printf("  ↓ ");
    }
    printf("\n"); printf("\t\t\t    ");
    for (j = 0; j < len; j++)
    {
        for (i = 0; i < width; i++)
        {
            sum+=matrix[i][j];
        }
        average=sum/width; sum=0;
        printf(" %1.1f", average);
    }

    printf("\n\nPresione cualquier tecla para salir...\n");
    get_char();
    return 0;
}

void printMatrix (int matrix[width][len])
{
    int i,j;
    printf("\n");
    for (i = 0; i < width; i++)
    {
        printf("\t\t\t    ---------------------\n\t\t\t    ");
        for (j = 0; j < len; j++)
        {
            printf("| %d ", matrix[i][j]);
        }
        printf("|\n");
    }
    printf("\t\t\t    ---------------------\n");
}

int enterInt(void)
{/* asks for 1 number (of 2 digits) and returns its value, otherwise -1 */
    int i, num;
    char input[2];
    for (i = 0; i < 3; i++) //an additional space for '\0'
    {
        scanf("%c", &input[i]);
        if (input[i]=='\n') {input[i]='\0'; break;}
    }

    if (! isNumber(input)) return(-1);
    else {
        num=atoi(input);
        if (num < 0 || num > 10)
        {
            return(-1);
        }
        else return(num);
    }
}

int isNumber (char *string)
{/* returns negative if string is NOT a valid number otherwise 0 */
    int i;
    for (i=0; i<strlen(string); i++)
    {
        if (! isdigit(string[i]) /*&& str[j]!='.' any other condition*/ )
            return(0);
    }
    return(-1);
}
