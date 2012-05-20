/**************************************************************************

sSs.c (sniffer Super simple) es para uso didactico adaptado de
http://security-freak.net/raw-sockets/sniffer.c

    gcc sSs.c -o sSs

Contacto: chilicuil@gmail.com
**************************************************************************/


/******************************INCLUDES***********************************/
#include <stdio.h>		/*Necesario para usar fprintf, printf, stderr, perror */
#include <stdlib.h>		/*Necesario para usar atoi, exit */
#include <unistd.h>		/*Necesario para close()*/
#include <getopt.h>		/*Para poder usar opciones */
#include <sys/socket.h>		/*Necesario para usar socket, bind, sockaddr recvfrom */
#include <string.h>		/*Necesario para usar strncpy, memset, strcmp */
#include <linux/if_packet.h>	/*Necesario para usar sockaddr_ll*/
#include <linux/if_ether.h>	/*Necesario para usar ETH_P_ALL */
#include <linux/ip.h>		/*Necesario para usar iphdr */
#include <linux/if_arp.h>	/*Necesario para usar arphdr */
#include <linux/tcp.h>		/*Necesario para usar tcphdr */
#include <linux/udp.h>		/*Necesario para usar udphdr */
#include <errno.h>		/*Necesario para mostrar errores en tiempo de ejecucion*/
#include <sys/ioctl.h>		/*Necesario para usar ioctl, SIOGIFINDEX */
#include <netinet/in.h>		/*Necesario para usar IPPROTO_UDP, IPPROT0_IP */
#define TAMANIO_PAQUETE		2048
/*************************************************************************/

#include <stdbool.h>

/**************************************************************************
El standard c99 permite tipos booleanos, pero por compatibilidad se
definen aqui mismo.
**************************************************************************/


/*******************************Tomado de netcat.h************************/
/* TRUE and FALSE values for logical type 'bool' */
/*#ifndef true
# define true 1
#endif
#ifndef false
# define false 0
#endif
*/
/* this is just a logical type, but helps a lot */
/*#ifndef __cplusplus
# ifndef bool
#  define bool unsigned char
# endif
#endif
#define BOOL_TO_STR(__var__) (__var__ ? "true" : "false")
#define NULL_STR(__var__) (__var__ ? __var__ : "(null)")*/
/*************************************************************************/


/*************Muestra informacion para el manejo del programa*************/
void uso(char *nombre_del_programa)
{
    fprintf(stderr,"Uso: ~# %s <Interfaz> <Paquetes> [Opciones...]\n",nombre_del_programa);
    fprintf(stderr,"        -v --verbose\t Imprime las cabeceras\n");
    exit (EXIT_SUCCESS);
}
/*************************************************************************/


/******Crea un socket del tipo SOCK_RAW y devuelve una referencia a el****/
int crearSocket(int protocolo_a_capturar)
{
    int nuestro_socket;

    /*Creamos nuestro socket*/
    if((nuestro_socket = socket (PF_PACKET, SOCK_RAW, htons (protocolo_a_capturar))) == -1)
    {
	perror("Error mientras se creaba el socket, esta seguro que es r00t?\nX.X ");
	exit (EXIT_FAILURE);
    }

    return nuestro_socket;
}
/*************************************************************************/


/*******************Asigna una direccion a nuestro socket*****************/
void asignarInterfazSocket (char *interface, int nuestro_socket, int protocolo_a_capturar)
{
    struct sockaddr_ll direccion_del_socket;
    struct ifreq interfaz;


    /*Inicializamos con 0s las instancias que acabamos de crear*/
    memset  (&direccion_del_socket, 0x0 , sizeof(direccion_del_socket));
    memset (&interfaz, 0x0 , sizeof(interfaz));

    /*Obtenemos la interfaz del usuario */
    strncpy (interfaz.ifr_name, interface, IFNAMSIZ);

    /*interfaz.ifr_flags|=IFF_PROMISC;
    if((ioctl (nuestro_socket, SIOCSIFFLAGS, &interfaz))==-1)
    {
	perror ("No se pudo establecer el modo promiscuo");
	exit(EXIT_FAILURE);
    }
    */

    /*Obtenemos el indice de la interfaz y la copiamos a interfaz.ifr_ifindex*/
    if ((ioctl (nuestro_socket, SIOGIFINDEX, &interfaz)) == -1)
    {
	perror ("Error mientras se obtenia la interfaz");
	exit(EXIT_FAILURE);
    }

    /*Copiamos la direccion de la familia PF_PACKET, el localizador del dispositivo, y el tipo de protocolo al objeto sockaddr_ll*/
    direccion_del_socket.sll_family = AF_PACKET;
    direccion_del_socket.sll_ifindex = interfaz.ifr_ifindex;
    direccion_del_socket.sll_protocol = htons (protocolo_a_capturar);

    /* Le asignamos una direccion a nuestro socket, para empezar a recibir datos*/
    if ((bind(nuestro_socket, (struct sockaddr *)&direccion_del_socket, sizeof(direccion_del_socket))) == -1)
    {
	perror ("Error mientras se asignaba una direccion al socket");
	exit(EXIT_FAILURE);
    }


}
/*************************************************************************/


/********************Muestra el paquete y cabeceras***********************/
void formato (unsigned char *ptr_datos_del_paquete, size_t longitud_paquete, int tipo_formato)
{
    bool decimal=false;
    bool hexadecimal=false;
    bool octal=false;
    bool ascii=false;

    switch (tipo_formato)
    {
	case 10:decimal=true;
		break;
	case 16:hexadecimal=true;
		break;
	case 8:octal=true;
               break;
        case 255:ascii=true;
                 break;
        default:hexadecimal=true;
                break;
    }

    if (decimal)
    {
        while (longitud_paquete--)
        {
            printf("%.2d ", *ptr_datos_del_paquete);
            /*Lee el siguiente espacio de memoria al que apunta ptr_datos_del_paquete*/
            ptr_datos_del_paquete++;
        }
    }

    if (hexadecimal)
    {
        while (longitud_paquete--)
        {
            printf("%.2X ", *ptr_datos_del_paquete);
            /*Lee el siguiente espacio de memoria al que apunta ptr_datos_del_paquete*/
            ptr_datos_del_paquete++;
        }
    }

    if (octal)
    {
        while (longitud_paquete--)
        {
            printf("%.2o ", *ptr_datos_del_paquete);
            /*Lee el siguiente espacio de memoria al que apunta ptr_datos_del_paquete*/
            ptr_datos_del_paquete++;
        }
    }

    if (ascii)
    {
        while (longitud_paquete--)
        {
            printf("%c", *ptr_datos_del_paquete);
            /*Lee el siguiente espacio de memoria al que apunta ptr_datos_del_paquete*/
            ptr_datos_del_paquete++;
        }
    }
}
/*************************************************************************/


/*****************************Muestra los paquetes************************/
void mostrar(unsigned char *ptr_datos_del_paquete, size_t longitud_paquete, int paquete_actual)
{

    printf("\n\n---------------------El paquete %d inicia aqui-------------------\n\n", paquete_actual);

    formato(ptr_datos_del_paquete, longitud_paquete, 16);

    printf("\n\n-----------------------------------------------------------------\n\n");

}
/*************************************************************************/


/*******************************Modo verbose******************************/


/**********************Muestra la cabecera ethernet***********************/
void mostrarEthernet(struct ethhdr *cabecera_ethernet)
{
    /*Sacamos los datos de la cabecera y sus longitudes*/
    /*Asignamos apuntadores a cada parte de la cabecera*/
    unsigned char *mac_destino=cabecera_ethernet->h_dest;
    size_t tamanio_mac_destino=sizeof(cabecera_ethernet->h_dest);
    unsigned char *mac_origen=cabecera_ethernet->h_source;
    size_t tamanio_mac_origen=sizeof(cabecera_ethernet->h_source);
    unsigned char *protocolo_sobre_ethernet=(unsigned char *)&cabecera_ethernet->h_proto;
    size_t tamanio_protocolo_sobre_ethernet=sizeof(cabecera_ethernet->h_proto);

    /*No se mandan variables, se mandan direcciones de memoria, que corresponden a cada cabecera*/
    printf("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
    printf("\n************************Capa Ethernet****************************");
    printf("\n+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
    printf("\nDireccion Mac destino: \t\t");
    formato(mac_destino, tamanio_mac_destino, 16);
    printf("\nDireccion Mac origen: \t\t");
    formato(mac_origen, tamanio_mac_origen, 16);
    printf("\nProtocolo: \t\t\t");
    formato(protocolo_sobre_ethernet, tamanio_protocolo_sobre_ethernet, 16);
    printf("\n");
}
/*************************************************************************/


/**********************Muestra la cabecera ip*****************************/
void mostrarIp(struct iphdr *cabecera_ip)
{
    /*Sacamos los datos y sus longitudes*/
    /*No se mandan variables, se mandan direcciones de memoria, que corresponden a cada cabecera*/
    unsigned char *tipo_servicio=(unsigned char *)&cabecera_ip->tos;
    size_t tamanio_tipo_servicio=sizeof(cabecera_ip->tos);
    unsigned char *tamanio_total=(unsigned char *)&cabecera_ip->tot_len;
    size_t tamanio_tamanio_total=sizeof(cabecera_ip->tot_len);
    unsigned char *identificacion=(unsigned char *)&cabecera_ip->id;
    size_t tamanio_identificacion=sizeof(cabecera_ip->id);
    unsigned char *fragmentacion=(unsigned char *)&cabecera_ip->frag_off;
    size_t tamanio_fragmentacion=sizeof(cabecera_ip->frag_off);
    unsigned char *tiempo_vida=(unsigned char *)&cabecera_ip->ttl;
    size_t tamanio_tiempo_vida=sizeof(cabecera_ip->ttl);
    unsigned char *protocolo_sobre_ip=(unsigned char *)&cabecera_ip->protocol;
    size_t tamanio_protocolo_sobre_ip=sizeof(cabecera_ip->protocol);
    unsigned char *sumatoria_ip=(unsigned char *)&cabecera_ip->check;
    size_t tamanio_sumatoria_ip=sizeof(cabecera_ip->check);
    unsigned char *ip_origen=(unsigned char *)&cabecera_ip->saddr;
    size_t tamanio_ip_origen=sizeof(cabecera_ip->saddr);
    unsigned char *ip_destino=(unsigned char *)&cabecera_ip->daddr;
    size_t tamanio_ip_destino=sizeof(cabecera_ip->daddr);

    printf("\n+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
    printf("\n***************************Capa Ip*******************************");
    printf("\n+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
    printf("\nTipo de servicio: \t\t");
    formato (tipo_servicio, tamanio_tipo_servicio, 16);
    printf("\nTamanio total: \t\t\t");
    formato (tamanio_total, tamanio_tamanio_total, 16);
    printf("\nIdentificacion: \t\t");
    formato (identificacion, tamanio_identificacion, 16);
    printf("\nFragmentacion: \t\t\t");
    formato (fragmentacion, tamanio_fragmentacion, 16);
    printf("\nTiempo de Vida: \t\t");
    formato (tiempo_vida, tamanio_tiempo_vida, 16);
    printf("\nProtocolo que transporta: \t");
    formato(protocolo_sobre_ip, tamanio_protocolo_sobre_ip, 16);
    printf("\nSumatoria de verificacion: \t");
    formato(sumatoria_ip, tamanio_sumatoria_ip, 16);
    printf("\nIp origen: \t\t\t");
    formato(ip_origen, tamanio_ip_origen, 16);
    printf("\t");formato(ip_origen, tamanio_ip_origen, 10);
    printf("\nIp destino: \t\t\t");
    formato(ip_destino, tamanio_ip_destino, 16);
    printf("\t");formato(ip_destino, tamanio_ip_destino, 10);
    printf("\n");
}
/*************************************************************************/


/**********************Muestra la cabecera tcp****************************/
void mostrarTcp(struct tcphdr *cabecera_tcp)
{
    /*Sacamos los datos y sus longitudes*/
    unsigned char *puerto_origen_tcp=(unsigned char *)&cabecera_tcp->source;
    size_t tamanio_puerto_origen_tcp=sizeof(cabecera_tcp->source);
    unsigned char *puerto_destino_tcp=(unsigned char *)&cabecera_tcp->dest;
    size_t tamanio_puerto_destino_tcp=sizeof(cabecera_tcp->dest);
    unsigned char *numero_secuencia_tcp=(unsigned char *)&cabecera_tcp->seq;
    size_t tamanio_numero_secuencia_tcp=sizeof(cabecera_tcp->seq);
    unsigned char *numero_reconocimiento_tcp=(unsigned char *)&cabecera_tcp->ack_seq;
    size_t tamanio_numero_reconocimiento_tcp=sizeof(cabecera_tcp->ack_seq);
    unsigned char *ventana_tcp=(unsigned char *)&cabecera_tcp->window;
    size_t tamanio_ventana_tcp=sizeof(cabecera_tcp->window);
    unsigned char *sumatoria_tcp=(unsigned char *)&cabecera_tcp->check;
    size_t tamanio_sumatoria_tcp=sizeof(cabecera_tcp->check);
    unsigned char *indicador_urgencia_tcp=(unsigned char *)&cabecera_tcp->urg_ptr;
    size_t tamanio_indicador_urgencia_tcp=sizeof(cabecera_tcp->urg_ptr);

    printf("\n+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
    printf("\n***************************Capa Tcp******************************");
    printf("\n+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
    printf("\nPuerto origen: \t\t\t");
    formato (puerto_origen_tcp, tamanio_puerto_origen_tcp, 16);
    printf("\t");formato (puerto_origen_tcp, tamanio_puerto_origen_tcp, 10);
    printf("\nPuerto destino: \t\t");
    formato (puerto_destino_tcp, tamanio_puerto_destino_tcp, 16);
    printf("\t");formato (puerto_destino_tcp, tamanio_puerto_destino_tcp, 10);
    printf("\nNumero de secuencia: \t\t");
    formato (numero_secuencia_tcp, tamanio_numero_secuencia_tcp, 16);
    printf("\nNumero de reconocimiento: \t");
    formato (numero_reconocimiento_tcp, tamanio_numero_reconocimiento_tcp, 16);
    printf("\nTamanio de ventana: \t\t");
    formato (ventana_tcp, tamanio_ventana_tcp, 16);
    printf("\nSuma de verificacion:\t\t");
    formato (sumatoria_tcp, tamanio_sumatoria_tcp, 16);
    printf("\nIndicador de urgencia: \t\t");
    formato (indicador_urgencia_tcp, tamanio_indicador_urgencia_tcp, 16);
    printf("\n\n");
}
/*************************************************************************/


/***********************Muestra la cabecera udp***************************/
void mostrarUdp(struct udphdr *cabecera_udp)
{
    /*Sacamos los datos y sus longitudes*/
    unsigned char *puerto_origen_udp=(unsigned char *)&cabecera_udp->source;
    size_t tamanio_puerto_origen_udp=sizeof(cabecera_udp->source);
    unsigned char *puerto_destino_udp=(unsigned char *)&cabecera_udp->dest;
    size_t tamanio_puerto_destino_udp=sizeof(cabecera_udp->dest);
    unsigned char *longitud_udp=(unsigned char *)&cabecera_udp->len;
    size_t tamanio_longitud_udp=sizeof(cabecera_udp->len);
    unsigned char *sumatoria_udp=(unsigned char *)&cabecera_udp->check;
    size_t tamanio_sumatoria_udp=sizeof(cabecera_udp->check);

    printf("\n+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
    printf("\n***************************Capa Udp******************************");
    printf("\n+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
    printf("\nPuerto origen: \t\t\t");
    formato (puerto_origen_udp, tamanio_puerto_origen_udp, 16);
    printf("\t");formato (puerto_origen_udp, tamanio_puerto_origen_udp, 10);
    printf("\nPuerto destino: \t\t");
    formato (puerto_destino_udp, tamanio_puerto_destino_udp, 16);
    printf("\t");formato (puerto_destino_udp, tamanio_puerto_destino_udp, 10);
    printf("\nTamanio del paquete Udp: \t");
    formato (longitud_udp, tamanio_longitud_udp, 16);
    printf("\nSumatoria de verificacion: \t");
    formato (sumatoria_udp, tamanio_sumatoria_udp, 16);
    printf("\n\n");
}
/*************************************************************************/


/************************Muestra la cabecera arp**************************/
void mostrarArp(struct arphdr *cabecera_arp)
{
    /*Sacamos los datos y sus longitudes*/
    unsigned char *formato_direccion_fisica=(unsigned char *)&cabecera_arp->ar_hrd;
    size_t tamanio_formato_direccion_fisica=sizeof(cabecera_arp->ar_hrd);
    unsigned char *formato_direccion_protocolo=(unsigned char *)&cabecera_arp->ar_pro;
    size_t tamanio_formato_direccion_protocolo=sizeof(cabecera_arp->ar_pro);
    unsigned char *longitud_direccion_fisica=(unsigned char *)&cabecera_arp->ar_hln;
    size_t tamanio_longitud_direccion_fisica=sizeof(cabecera_arp->ar_hln);
    unsigned char *longitud_direccion_protocolo=(unsigned char *)&cabecera_arp->ar_pln;
    size_t tamanio_longitud_direccion_protocolo=sizeof(cabecera_arp->ar_pln);
    unsigned char *comando_arp=(unsigned char *)&cabecera_arp->ar_op;
    size_t tamanio_comando_arp=sizeof(cabecera_arp->ar_op);

    printf("\n+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
    printf("\n***************************Capa Arp******************************");
    printf("\n+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
    printf("\nFormato de la direccion fisica: ");
    formato (formato_direccion_fisica, tamanio_formato_direccion_fisica, 16);
    printf("\nFormato del protocolo: \t\t");
    formato (formato_direccion_protocolo, tamanio_formato_direccion_protocolo, 16);
    printf("\nLongitud de la direccion fisica:");
    formato (longitud_direccion_fisica, tamanio_longitud_direccion_fisica, 16);
    printf("\nLongitud del protocolo: \t");
    formato (longitud_direccion_protocolo, tamanio_longitud_direccion_protocolo, 16);
    printf("\nComando: \t\t\t");
    formato (comando_arp, tamanio_comando_arp, 16);
    printf("\n\n");
}
/*************************************************************************/


/****************************Muestra los datos****************************/
void mostrarDatos(unsigned char *datos, size_t tamanio_datos)
{
    printf("\n+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
    printf("\n***************************Datos*********************************");
    printf("\n+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
    printf("\n"); formato(datos, tamanio_datos,16);
    printf("\n+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
    //printf("\n%s", datos);
    printf("\n"); formato(datos, tamanio_datos,255);
    printf("\n");
}
/*************************************************************************/


/*****************************Identifica cabeceras****************************/
void mostrarVerbose(unsigned char *ptr_datos_del_paquete, size_t longitud_paquete)
{
    /*Damos por sentado que hay una cabecera ethernet*/
    /*Se crea un apuntador de tipo ethhdr (cabecera ethernet)*/
    /*c90-c89 no permite mezclar declaracion de variables con codigo*/
    struct ethhdr *cabecera_ethernet;
    cabecera_ethernet=(struct ethhdr *)ptr_datos_del_paquete;
    mostrarEthernet (cabecera_ethernet);

    /*Buscamos el protocolo que transporta*/
    int siguiente_protocolo=ntohs(cabecera_ethernet->h_proto);
    if(siguiente_protocolo==ETH_P_IP)
    {   /*El paquete ha resultado ser ip*/
        struct iphdr *cabecera_ip;

        /*Comprobamos que traiga la cabecera ip completa*/
        if(longitud_paquete >=(sizeof(struct ethhdr) + sizeof(struct iphdr)))
        {   /*cabecera_ip ahora apunta a ptr_datos_del_paquete+el tamanio de la estructura anterior*/
            cabecera_ip=(struct iphdr*)(ptr_datos_del_paquete+sizeof(struct ethhdr));
            mostrarIp (cabecera_ip);

            /*Buscamos el siguiente protocolo*/
            siguiente_protocolo=cabecera_ip->protocol;
            if (siguiente_protocolo==IPPROTO_TCP)
            {   /*Ha resultado tener una cabecera Tcp*/
                /*Se crea un apuntador hacia una estructura tphdr*/
                struct tcphdr *cabecera_tcp;

                /*Comprobamos que traiga toda la cabecera TCP*/
                if(longitud_paquete>= (sizeof(struct ethhdr)+sizeof(struct iphdr)+sizeof(struct tcphdr)))
                {
                    cabecera_tcp=(struct tcphdr*)(ptr_datos_del_paquete+sizeof(struct ethhdr) + cabecera_ip->ihl*4 );
                    mostrarTcp(cabecera_tcp);

                    /*Mostramos los datos (payload)*/
                    unsigned char *datos_tcp=(ptr_datos_del_paquete+sizeof(struct ethhdr)+cabecera_ip->ihl*4+sizeof(struct tcphdr));
                    size_t tamanio_datos_tcp=ntohs(cabecera_ip->tot_len)-cabecera_ip->ihl*4-sizeof(struct tcphdr);
                    mostrarDatos(datos_tcp, tamanio_datos_tcp);
                }

                else
                {
                    printf("Cabecera TCP deforme, faltan datos\n");
                }
            }

            else
            {
                if (siguiente_protocolo==IPPROTO_UDP)
                {       /*Ha resultado tener una cabecera Udp*/
                    struct udphdr *cabecera_udp;

                    /*Comprobamos que traiga todas las cabeceras UDP*/
                    if(longitud_paquete>= (sizeof(struct ethhdr)+sizeof(struct iphdr)+sizeof(struct udphdr)))
                    {
                        cabecera_udp=(struct udphdr*)(ptr_datos_del_paquete+sizeof(struct ethhdr) + cabecera_ip->ihl*4 );
                        mostrarUdp(cabecera_udp);

                        /*Mostramos los datos (payload)*/
                        unsigned char *datos_udp=(ptr_datos_del_paquete+sizeof(struct ethhdr)+cabecera_ip->ihl*4+sizeof(struct udphdr));
                        size_t tamanio_datos_udp=ntohs(cabecera_ip->tot_len)-cabecera_ip->ihl*4-sizeof(struct udphdr);
                        mostrarDatos(datos_udp, tamanio_datos_udp);
                    }

                    else
                    {
                        printf("Paquete UDP incorrecto, faltan datos en la cabecera\n");
                    }
                }
            }
        }

        else
        {
            printf("Paquete IP incorrecto, faltan campos en la cabecera\n");
        }
    }

    else
    {
        if (siguiente_protocolo==ETH_P_ARP)
        {   /*Por aqui tenemos un paquete Arp*/
            struct arphdr *cabecera_arp;

            /*Comprobamos que traiga la cabecera ARP completa*/
            if(longitud_paquete >= (sizeof(struct ethhdr) + sizeof(struct arphdr)))
            {
                cabecera_arp=(struct arphdr*)(ptr_datos_del_paquete+sizeof(struct ethhdr));
                mostrarArp(cabecera_arp);
            }

            else
            {
                printf("Paquete ARP incorrecto, faltan cabeceras\n");
            }
        }

        else
        {
            printf("Paquete irreconocible (Arp-IP)\n");
        }
    }
}
/*************************************************************************/


/*******************************Principal*********************************/

int main (int argc, char **argv)
{
    /*Manejo de opciones y argumentos*/
    if (argc == 1) /*Si no hay opciones, se muestra la ayuda*/
    {
        uso(argv[0]);
    }

    int opciones;
    bool verbose=false;
    const char *op_corta="v";
    const struct option op_larga[] =
    {
        {"verbose",0,NULL,'v'},
        { NULL,0,NULL,0}
    };

    if (argv[2]==NULL) /*Si solo hay una opcion, se muestra la ayuda*/
    {
        uso(argv[0]);
    }

    char *primer_argumento=argv[1];
    char *segundo_argumento=argv[2];

    while (true)
    {
        opciones=getopt_long (argc, argv, op_corta, op_larga, NULL);
        if(opciones==-1)/*Si no se piden opciones, se sigue*/
        {
            break;
        }
        switch (opciones)/*Se buscan las opciones*/
        {
            case 'v':verbose=true;
                     break;
            default:uso(argv[0]);
        }
    }

    int nuevo_socket;
    unsigned char ptr_datos_del_paquete [TAMANIO_PAQUETE];
    size_t longitud_paquete;
    unsigned long long paquetes_a_esnifear;
    unsigned long long paquete_actual=0;
    struct sockaddr_ll direccion_socket;
    size_t tamanio_direccion_socket = sizeof (direccion_socket);

    /*Creamos un nuevo socket*/
    /*Esnifearemos todo, todito el trafico, esto puede ser peligroso en redes muy activas o en computadoras muy lentas, seria recomendable ver /usr/include/linux/if_ether.h para cambiar esta opcion*/
    nuevo_socket = crearSocket(ETH_P_ALL);

    /*Le asignamos direccion*/
    asignarInterfazSocket(primer_argumento, nuevo_socket, ETH_P_ALL);

    /*Obtenemos el numero de paquetes a esnifear*/
    paquetes_a_esnifear = atoi(segundo_argumento);

    /*Esnifeamos y mostramos los paquetes capturados*/
    while (paquetes_a_esnifear--)
    {
        paquete_actual++;

        /*Recibimos los datos y los copiamos a ptr_datos_del_paquete*/
        if ((longitud_paquete = recvfrom(nuevo_socket, ptr_datos_del_paquete, TAMANIO_PAQUETE, 0, (struct sockaddr*)&direccion_socket, &tamanio_direccion_socket)) == -1)
        {
            perror("Error mientras se recibian los datos!");
            exit(EXIT_FAILURE);
        }

        mostrar(ptr_datos_del_paquete, longitud_paquete, paquete_actual);

        if (verbose)
        {
            mostrarVerbose(ptr_datos_del_paquete, longitud_paquete);
        }
    }

    if (close (nuevo_socket)==-1)
    {
        perror("Error mientras se cerraba el socket!");
        exit (EXIT_FAILURE);
    }

    return (EXIT_SUCCESS);
}
/*************************************************************************/

