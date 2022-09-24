#include<stdio.h>
#include<unistd.h>
#include<stdlib.h>
#include <time.h>
#include <string.h>
#include <sys/types.h>
#include <sys/wait.h>

#define ERROR -1
#define EXITO 0
#define PROCESOINVALIDO 0
#define PIPEINVALIDO -1
#define FDLECTURA 0
#define FDESCRITURA 1



static void imprimirPipes(int fds1[2], int fds2[2]){
		printf("Hola, soy PID: %d \n", getpid());
		printf("\t - primer pipe me devuelve: [%i, %i]\n", fds1[0], fds1[1]);
		printf("\t - segundo pipe me devuelve: [%i, %i]\n", fds2[0], fds2[1]);
}
static void imprimirInformacionProceso(int proceso){
		printf("Donde fork me devuelve %i:\n", proceso);
		printf("\t - getpid me devuelve: %d\n", getpid());
		printf("\t - getppid me devuelve: %d\n", getppid());
}
int main(void){
		srand(time(NULL));
		int fds1[2], fds2[2];
		int lecturaMensaje = 0;
		int pipestatus1 = pipe(fds1);
		if (pipestatus1 == PIPEINVALIDO){
			perror("hubo un error en pipe");
			exit(ERROR);
		}
		int pipestatus2 = pipe(fds2);
		if (pipestatus2 == PIPEINVALIDO){
			perror("hubo un error en pipe");
			exit(ERROR);
		}
		imprimirPipes(fds1, fds2);
		int proceso = fork();
		if (proceso < PROCESOINVALIDO){
				perror("Hubo un error en fork");
				exit(ERROR);
		}
		int escrituraMensaje = rand();
		if (proceso == 0){

				 close(fds1[FDESCRITURA]);
				 close(fds2[FDLECTURA]);

				 imprimirInformacionProceso(proceso);
				 if (read(fds1[FDLECTURA], &lecturaMensaje, sizeof(lecturaMensaje)) < 0){
					 		perror("error de lectura");
					 		exit(ERROR);
				 }
				 printf("\t - recibo valor: %i via fd: %i \n", lecturaMensaje, fds1[FDLECTURA]);
				 close(fds1[FDLECTURA]);
				 printf("\t - reenvío valor en fd: %i y termino \n", fds2[FDESCRITURA]);
				 if (write(fds2[FDESCRITURA], &lecturaMensaje, sizeof(lecturaMensaje)) < 0){
					 		perror("error de escritura");
					 		exit(ERROR);
				 }
				 close(fds2[FDESCRITURA]);
				 exit(EXITO);
		} else {

				 close(fds1[FDLECTURA]);
				 close(fds2[FDESCRITURA]);

				imprimirInformacionProceso(proceso);

				 printf("\t - random me devuelve: %i \n", escrituraMensaje);
				 if (write(fds1[FDESCRITURA], &escrituraMensaje, sizeof(escrituraMensaje)) < 0){
						 perror("error de escritura");
						 exit(ERROR);
				 }
				 printf("\t - envío valor %i a través de fd: %i \n", escrituraMensaje, fds1[FDESCRITURA]);
				 close(fds1[FDESCRITURA]);

				 if (read(fds2[FDLECTURA], &lecturaMensaje, sizeof(lecturaMensaje)) < 0){
						 perror("error de lectura");
						 exit(ERROR);
				 }
				 printf("Hola, de nuevo PID: %d\n", getpid());
				 printf("\t - recibí valor %i vía fd: %i\n", lecturaMensaje, fds2[FDLECTURA]);
				 close(fds2[FDLECTURA]);
				 wait(0);
				 exit(EXITO);
		}
}
