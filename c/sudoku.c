/**********************************************************************
 * Sudoku
 *
 * Por: A.F. Luis --rabano_c.uing@hotmail.com
 *      P.L Javier --disco299@gmail.com
 *********************************************************************/

/*****************************INCLUDES********************************/
#include <stdio.h>  /* printf, scanf, fflush, getchar, etc */
#include <stdlib.h> /* system, rand, exit, qsort */
#include <time.h>   /* time */

/*****************************DEFINES********************************/
#define ancho   4
#define largo   4
#define TIEMPO_DE_CARGA 6
#define No_frases  10

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

/* Definicion de funciones */
void generando (void);
void generar_sudoku (int [largo][ancho], int);
void imprimir_sudoku (int [largo][ancho]);
int jugar (int [largo][ancho], int);
int analizar (int [largo][ancho], int); 

const char *logo="\n\n\n\
                  \n\t\t.oPYo.             8        8             \
                  \n\t\t8                  8        8             \
                  \n\t\t`Yooo. o    o .oPYo8 .oPYo. 8  .o  o    o \
                  \n\t\t    `8 8    8 8    8 8    8 8oP'   8    8 \
                  \n\t\t     8 8    8 8    8 8    8 8 `b.  8    8 \
                  \n\t\t`YooP' `YooP' `YooP' `YooP' 8  `o. `YooP' \
                  \n\t\t:.....::.....::.....::.....:..::...:.....:\
                  \n\t\t::::::::::::::::::::::::::::::::::::::::::\
                  \n\t\t:::::::::::::::::::::::::::Version: 0.0.1:\n\n";  

int main (int argc, char const* argv[])
{
    int i, debug=0, arg_actual, sudoku [largo] [ancho], quiera_jugar=1;
    int resultado=0, marcador_usuario=0, marcador_maq=0;
    char nombre[100];
    FILE *archivo;
    for (i = 0; i < 100; i++) nombre[i] = '\0';     /*Limpiar la variable*/

    /* Manejo de opciones */
    for (arg_actual = 1; arg_actual < argc && argv[arg_actual][0] == '-'; arg_actual++)
    {
        const char *opcion;
        for (opcion = &argv[arg_actual][1]; *opcion != '\0'; opcion++)
        {
            switch (*opcion)
            {
                case 'd': debug = 1;
                          break;
                default: printf("Uso: ~ %s [Opciones...]\n", argv[0]);
                         printf("\t\t -d\tmodo depurador\n");
                         sleep(2);
                         exit(-1);
                         break;
            }
        }
    }

    system(clear); printf("%s", logo); 
    if (!debug) printf("\tINSTRUCCIONES:\n\n\
            Introduzca numeros del 1 al 4 (se deshabilitaran el \n\
            el resto de las teclas) para formar sumatorias de 10 \n\
            horizontalmente, verticalmente y diagonalmente, solo \n\
            tendra una oportunidad por tablero!, asi que analice\n\
            su juego\n");

    printf("\n\tPara empezar introduzca su nombre: ");
    //fgets(nombre, 100, stdin); /*fgets agrega un '\n' al final*/

    for (i = 0; i < 100; i++)
    {
        scanf("%c", &nombre[i]);
        if (nombre[i]=='\n') {nombre[i]='\0'; break;}/*quita la fea '\n'*/
    }

    if (debug) {printf("[DEBUG] Nombre: %s", nombre);getchar();}

    while (quiera_jugar)
    {
        system(clear); printf("%s", logo); if (!debug) generando();
        generar_sudoku(sudoku, debug);
        resultado=jugar(sudoku, debug);
        if (resultado==1) marcador_usuario+=1;
        if (resultado==2) marcador_maq+=1;

        printf("\n\n\t\t=======================================\n");
        printf("\n\t\t         %s %d-%d local\n\n",nombre, marcador_usuario, marcador_maq);
        printf("\t\t=======================================\n");
        printf("\n\n\n\t\tDeseas volver a jugar? (s/n) > ");
        char continuar=getchar();
        while (getchar() != '\n'){}
        switch (continuar)
        {
            case 's':
            case 'S': quiera_jugar=1;break;
            case 'n':
            case 'N': quiera_jugar=0;break;
            default:break;
        }
    }
    
    printf("\n\n\t\tSu ultima partida, junto a sus estadisticas\
                 \n\t\tse han guardado en \"ap.txt\"\n");
    sleep(3);

    /*freopen nos ahorra la hueva de reimplementar las funciones nomas para 
     * escribirlas sobre archivos, redirecciona stdout a "archivo.txt"*/
    archivo = freopen ("ap.txt", "a+", stdout);
    printf("=====================================================================\
            \n=====================================================================\n");
    printf("Nombre: %s\n", nombre);
    printf("\nMarcador final: %s %d-%d local\n\n", nombre, marcador_usuario, marcador_maq);
    printf("Ultimo juego: \n");
    imprimir_sudoku(sudoku);
    printf("\t\t\t\t%s\n", (resultado==2)?"Incorrecto":"Correcto");
    printf("\n\n");

    fclose(archivo);
    return 0;
}

void generando(void)
{
    int i;
    printf("\t\tGenerando . . . ");
    for (i = 0; i < TIEMPO_DE_CARGA; i++)
    {
        printf("%c\b", "|/-\\"[i%4]);
        fflush(stdout);
        //fflush(NULL);
        sleep(1);
    }
    printf("\n");
}

void generar_sudoku(int sudoku [largo][ancho], int debug)
{
    /*Solo funciona con un sudoku 4x4, deberia reescribirla completamente*/
    int cuadrante=0;
    int i,j,k;
    int aleatorios[(largo*ancho)/4];     /*Numero de cuadrantes*/
    srand(time(0));                      /*Sembrar semilla para rand()*/

    /* Inicializar sudoku, con 0 */
    for (i = 0; i < largo; i++)
    {
        for (j = 0; j < ancho; j++)
        {
            sudoku[i][j]=0;
        }
    }

    if (debug) imprimir_sudoku(sudoku);

    /* Inicializar los cuadrantes */
    for (i = 0; i < (ancho*largo)/4; i++)
    {
        /* Produce mejor entropia que rand()%n */
        aleatorios[i]=rand() / (RAND_MAX / ((ancho*largo)/4) + 1);
        //aleatorios[i]=rand()%((ancho*largo)/4);       /*numeros aleatorios desde 0-3*/

        if (debug) printf("[DEBUG] aleatorios[%d] = %d\n", i, aleatorios[i]); 
    }

    for (k=0; k < (ancho*largo)/4; k++)
    {
        if (debug) getchar();

        for (i = 0; i < 2; i++)
        {
            for (j = 0; j < 2; j++)
            {
                if (cuadrante==aleatorios[k])
                {
                    if (debug) printf("%d, %d ", i, j);
                    switch (k)
                    {
                        case 0:sudoku[i][j]=1 + rand()/(RAND_MAX/((ancho*largo)/4) +1);
                               if (debug) printf(" = %d ---> %d", aleatorios[k], sudoku[i][j]);
                               break;
                        case 1:do
                               {
                                   sudoku[i+2][j]=1 + rand()/(RAND_MAX/((ancho*largo)/4) +1);
                               if (debug) printf(" = %d ---> %d", aleatorios[k], sudoku[i+2][j]);
                               }while((sudoku[i+2][j]==sudoku[i][j])||
                                       (sudoku[i+2][j]==sudoku[i+1][j])||
                                       (sudoku[i+2][j]==sudoku[i-1][j]));
                               break;
                        case 2:do
                               {
                                   sudoku[i][j+2]=1 + rand()/(RAND_MAX / ((ancho*largo)/4) + 1);
                               if (debug) printf(" = %d ---> %d", aleatorios[k], sudoku[i][j+2]); 
                               }while((sudoku[i][j+2]==sudoku[i][j])||
                                       (sudoku[i][j+2]==sudoku[i][j+1])||
                                       (sudoku[i][j+2]==sudoku[i][j-1])||
                                       ((1==aleatorios[k])   &&
                                        ((sudoku[i][j+2]==sudoku[i+2][j])||
                                        (sudoku[i][j+2]==sudoku[i+3][j-1])))||
                                       ((2==aleatorios[k])   &&
                                        ((sudoku[i][j+2]==sudoku[i+1][j+1])||
                                         (sudoku[i][j+2]==sudoku[i+2][j])))
                                       );
                               break;
                        case 3:do
                               {
                                   sudoku[i+2][j+2]=1 + rand()/(RAND_MAX / ((ancho*largo)/4) + 1);
                               if (debug) printf(" = %d ---> %d", aleatorios[k], sudoku[i+2][j+2]);
                               }while((sudoku[i+2][j+2]==sudoku[i+2][j])||
                                       (sudoku[i+2][j+2]==sudoku[i+2][j+1])||
                                       (sudoku[i+2][j+2]==sudoku[i+2][j-1])||
                                       (sudoku[i+2][j+2]==sudoku[i][j+2])||
                                       (sudoku[i+2][j+2]==sudoku[i+1][j+2])||
                                       (sudoku[i+2][j+2]==sudoku[i-1][j+2])||
                                       ((0==aleatorios[k])   &&
                                        ((sudoku[i+2][j+2]==sudoku[i][j])||
                                        (sudoku[i+2][j+2]==sudoku[i+1][j+1])))||
                                       ((3==aleatorios[k])   &&
                                        ((sudoku[i+2][j+2]==sudoku[i][j])||
                                         (sudoku[i+2][j+2]==sudoku[i-1][j-1])))
                                       );
                               break;
                    }
                }
                cuadrante++;
                if (cuadrante==4)
                {
                    cuadrante=0;
                }
            }
        }
    }
}

int jugar(int sudoku[largo][ancho], int debug)
{
    int i,j, tecla_deshabilitada, frase, resultado=0;
    char entrada;
    if (!debug) {system(clear);printf("%s", logo); printf("\t\tBuena suerte!\n");}
    imprimir_sudoku(sudoku);
    printf("\n\t\t> ");
    without_echo();/*para producir un efecto de respuesta inmediata*/

    for (i = 0; i < largo; i++)
    {
        for (j = 0; j < ancho; j++)
        {
            if (sudoku[i][j]==0)
            {
                entrada=get_char();
                tecla_deshabilitada=0;
                switch(entrada)
                {
                    case 49:sudoku[i][j]=1;break;
                    case 50:sudoku[i][j]=2;break;
                    case 51:sudoku[i][j]=3;break;
                    case 52:sudoku[i][j]=4;break;
                    default:tecla_deshabilitada=1; j--;break;
                }
                if (debug) printf("%d\n", sudoku[i][j]);
                if (!debug) {system(clear);printf("%s", logo); printf("\t\tBuena suerte!\n");}
                imprimir_sudoku(sudoku);
                if (tecla_deshabilitada)
                {
                    system(clear);printf("%s", logo); printf("\t\tBuena suerte!\n");
                    imprimir_sudoku(sudoku);
                    printf("\t\tTecla deshabilitada  ");getchar();
                }
                printf("\n\t\t> ");
            }
            if (i==(largo-1)&&j==(ancho-1))printf("\n\n"); /*ayuda a limpiar la pantalla*/
        }
    }
    with_echo();/*se regresa la consola a su estado normal*/
    
    frase= 1+ rand() / (RAND_MAX / (No_frases) + 1);/*se genera una frase aleatoria*/
    if (debug) printf("frase = %d\n", frase);
    system(clear);printf("%s", logo);imprimir_sudoku(sudoku);

    if (analizar (sudoku, debug)==1)
    {
        resultado=1;
        switch (frase)
        {
            case 1:printf("\n\t\tCorrecto\n");break;
            case 2:printf("\n\t\tFelicidades\n");break;
            case 3:printf("\n\t\tSuerte de novato\n");break;
            case 4:printf("\n\t\tCreo que este sudoku estuvo muy facil\n");break;
            case 5:printf("\n\t\tRifado!\n");break;
            case 6:printf("\n\t\tSi asi contestaras los finales no estarias aqui -.-'\n");break;
            case 7:printf("\n\t\tBien\n");break;
            case 8:printf("\n\t\tLo has logrado, ahora ve a hacer algo mas productivo\n");break;
            case 9:printf("\n\t\tPorque no intentas con el ajedrez?\n");break;
            case 10:printf("\n\t\tAl menos debes tener un CI arriba de la media\n");break;
            default:printf("\n\t\tNo deberias estar viendo este mensaje\n");break;
        }
    }

    else 
    {
        resultado=2;
        switch (frase)
        {
            case 1:printf("\n\t\tOrale! a chillar a otra parte!\n");break;
            case 2:printf("\n\t\tVuelve a intentar\n");break;
            case 3:printf("\n\t\tTe pongo uno de 2x2?\n");break;
            case 4:printf("\n\t\tIncorrecto\n");break;
            case 5:printf("\n\t\tEso estuvo cerca\n");break;
            case 6:printf("\n\t\tPista: La suma debe ser de 10\n");break;
            case 7:printf("\n\t\tPorque no intentas con el gato?\n");break;
            case 8:printf("\n\t\tCasi aciertas\n");break;
            case 9:printf("\n\t\tDebes tener otros talentos\n");break;
            case 10:printf("\n\t\tBoring...\n");break;
            default:printf("\n\t\tNo deberias estar viendo este mensaje\n");break;
        }
    }
    return resultado;
}

int analizar (int sudoku[largo][ancho], int debug)
{   /*No se me ocurrio un metodo elegante de validar los campos -.-'*/
    int i, j, lugar_actual=0;

    for (i = 0; i < largo; i++)
    {
        for (j = 0; j < ancho; j++)
        {
            switch (lugar_actual)
            {
                case 0:if (sudoku[i][j]==sudoku[i+1][j]||
                           sudoku[i][j]==sudoku[i+2][j]||
                           sudoku[i][j]==sudoku[i+3][j]||
                           sudoku[i][j]==sudoku[i][j+1]||
                           sudoku[i][j]==sudoku[i][j+2]||
                           sudoku[i][j]==sudoku[i][j+3]||
                           sudoku[i][j]==sudoku[i+1][j+1]||
                           sudoku[i][j]==sudoku[i+2][j+2]||
                           sudoku[i][j]==sudoku[i+3][j+3])
                           return -1;break;
                case 1:if (sudoku[i][j]==sudoku[i+1][j]||
                           sudoku[i][j]==sudoku[i+2][j]||
                           sudoku[i][j]==sudoku[i+3][j]||
                           sudoku[i][j]==sudoku[i][j+1]||
                           sudoku[i][j]==sudoku[i][j+2]||
                           sudoku[i][j]==sudoku[i][j-1])
                           return -1;break;
                case 2:if (sudoku[i][j]==sudoku[i+1][j]||
                           sudoku[i][j]==sudoku[i+2][j]||
                           sudoku[i][j]==sudoku[i+3][j]||
                           sudoku[i][j]==sudoku[i][j+1]||
                           sudoku[i][j]==sudoku[i][j-1]||
                           sudoku[i][j]==sudoku[i][j-2])
                           return -1;break;
                case 3:if (sudoku[i][j]==sudoku[i+1][j]||
                           sudoku[i][j]==sudoku[i+2][j]||
                           sudoku[i][j]==sudoku[i+3][j]||
                           sudoku[i][j]==sudoku[i][j-1]||
                           sudoku[i][j]==sudoku[i][j-2]||
                           sudoku[i][j]==sudoku[i][j-3]||
                           sudoku[i][j]==sudoku[i-1][j-1]||
                           sudoku[i][j]==sudoku[i-2][j-2]||
                           sudoku[i][j]==sudoku[i-3][j-3])
                           return -1;break;
                case 4:if (sudoku[i][j]==sudoku[i+1][j]||
                           sudoku[i][j]==sudoku[i+2][j]||
                           sudoku[i][j]==sudoku[i-1][j]||
                           sudoku[i][j]==sudoku[i][j+1]||
                           sudoku[i][j]==sudoku[i][j+2]||
                           sudoku[i][j]==sudoku[i][j+3])
                           return -1;break;
                case 5:if (sudoku[i][j]==sudoku[i+1][j]||
                           sudoku[i][j]==sudoku[i+2][j]||
                           sudoku[i][j]==sudoku[i-1][j]||
                           sudoku[i][j]==sudoku[i][j+1]||
                           sudoku[i][j]==sudoku[i][j+2]||
                           sudoku[i][j]==sudoku[i][j-1])
                           return -1;break;
                case 6:if (sudoku[i][j]==sudoku[i+1][j]||
                           sudoku[i][j]==sudoku[i+2][j]||
                           sudoku[i][j]==sudoku[i-1][j]||
                           sudoku[i][j]==sudoku[i][j+1]||
                           sudoku[i][j]==sudoku[i][j-1]||
                           sudoku[i][j]==sudoku[i][j-2])
                           return -1;break;
                case 7:if (sudoku[i][j]==sudoku[i+1][j]||
                           sudoku[i][j]==sudoku[i+2][j]||
                           sudoku[i][j]==sudoku[i-1][j]||
                           sudoku[i][j]==sudoku[i][j-1]||
                           sudoku[i][j]==sudoku[i][j-2]||
                           sudoku[i][j]==sudoku[i][j-3])
                           return -1;break;
                case 8:if (sudoku[i][j]==sudoku[i+1][j]||
                           sudoku[i][j]==sudoku[i-1][j]||
                           sudoku[i][j]==sudoku[i-2][j]||
                           sudoku[i][j]==sudoku[i][j+1]||
                           sudoku[i][j]==sudoku[i][j+2]||
                           sudoku[i][j]==sudoku[i][j+3])
                           return -1;break;
                case 9:if (sudoku[i][j]==sudoku[i+1][j]||
                           sudoku[i][j]==sudoku[i-1][j]||
                           sudoku[i][j]==sudoku[i-2][j]||
                           sudoku[i][j]==sudoku[i][j+1]||
                           sudoku[i][j]==sudoku[i][j+2]||
                           sudoku[i][j]==sudoku[i][j-1])
                           return -1;break;
                case 10:if(sudoku[i][j]==sudoku[i+1][j]||
                           sudoku[i][j]==sudoku[i-1][j]||
                           sudoku[i][j]==sudoku[i-2][j]||
                           sudoku[i][j]==sudoku[i][j+1]||
                           sudoku[i][j]==sudoku[i][j-1]||
                           sudoku[i][j]==sudoku[i][j-2])
                           return -1;break;
                case 11:if(sudoku[i][j]==sudoku[i+1][j]||
                           sudoku[i][j]==sudoku[i-1][j]||
                           sudoku[i][j]==sudoku[i-2][j]||
                           sudoku[i][j]==sudoku[i][j-1]||
                           sudoku[i][j]==sudoku[i][j-2]||
                           sudoku[i][j]==sudoku[i][j-3])
                           return -1;break;
                case 12:if(sudoku[i][j]==sudoku[i-1][j]||
                           sudoku[i][j]==sudoku[i-2][j]||
                           sudoku[i][j]==sudoku[i-3][j]||
                           sudoku[i][j]==sudoku[i][j+1]||
                           sudoku[i][j]==sudoku[i][j+2]||
                           sudoku[i][j]==sudoku[i][j+3]||
                           sudoku[i][j]==sudoku[i-1][j+1]||
                           sudoku[i][j]==sudoku[i-2][j+2]||
                           sudoku[i][j]==sudoku[i-3][j+3])
                           return -1;break;
                case 13:if (sudoku[i][j]==sudoku[i-1][j]||
                           sudoku[i][j]==sudoku[i-2][j]||
                           sudoku[i][j]==sudoku[i-3][j]||
                           sudoku[i][j]==sudoku[i][j+1]||
                           sudoku[i][j]==sudoku[i][j+2]||
                           sudoku[i][j]==sudoku[i][j-1])
                           return -1;break;
                case 14:if (sudoku[i][j]==sudoku[i-1][j]||
                           sudoku[i][j]==sudoku[i-2][j]||
                           sudoku[i][j]==sudoku[i-3][j]||
                           sudoku[i][j]==sudoku[i][j+1]||
                           sudoku[i][j]==sudoku[i][j-1]||
                           sudoku[i][j]==sudoku[i][j-2])
                           return -1;break;
                case 15:if (sudoku[i][j]==sudoku[i-1][j]||
                           sudoku[i][j]==sudoku[i-2][j]||
                           sudoku[i][j]==sudoku[i-3][j]||
                           sudoku[i][j]==sudoku[i][j-1]||
                           sudoku[i][j]==sudoku[i][j-2]||
                           sudoku[i][j]==sudoku[i][j-3])
                           return -1;break;
            }
            lugar_actual++; 
        }
    }
    return 1;
}

void imprimir_sudoku (int sudoku [largo][ancho])
{
    int i,j;
    printf("\n");
    for (i = 0; i < largo; i++)
    {
        printf("\t\t\t    -----------------\n\t\t\t    ");
        for (j = 0; j < ancho; j++)
        {
            printf("| %d ", sudoku[i][j]);
        }
        printf("|\n");
    }
    printf("\t\t\t    -----------------\n");
}
