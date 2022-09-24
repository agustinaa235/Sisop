#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <stdbool.h>

#define ERROR -1
#define EXITO 0
#define FDLECTURA 0
#define FDESCRITURA 1
#define PIPEINVALIDO -1
#define PROCESOINVALIDO 0
#define CANTIDAD_MINIMA_ARGUMENTOS 2



static void procesarNumeros(int fdLectura){
    int numeroPrimo;
    int lei = read(fdLectura, &numeroPrimo, sizeof(numeroPrimo));
    if (lei == 0){
          close (fdLectura);
          exit(EXITO);
    }
    printf("Numero primo: %i \n", numeroPrimo);
        int fds2[2];
        if (pipe(fds2) != PIPEINVALIDO){
              int proceso = fork();
              if (proceso == 0){
                  close(fds2[FDESCRITURA]);
                  close(fdLectura);
                  procesarNumeros(fds2[FDLECTURA]);
                  exit(0);
              } else {
                  close(fds2[FDLECTURA]);
                  int numero;
                  bool fallo = false;
                  while (read(fdLectura, &numero, sizeof(numero)) > 0 && !fallo){
                      if (numero % numeroPrimo != 0){
                          if (write(fds2[FDESCRITURA], &numero, sizeof(numero)) < 0){
                              perror("error de escritura");
                              fallo = true;
                          }
                      }
                  }
                  close(fds2[FDESCRITURA]);
                  close (fdLectura);
                  wait(0);
              }
        } else {
            	perror("hubo un error en pipe");
        }

}

int main(int argc, char *argv[]){
	if (argc < CANTIDAD_MINIMA_ARGUMENTOS){
         printf("cantidad insuficiente de argumentos\n");
         exit(ERROR);
     }
     int numeroMax = atoi(argv[1]);
     if (numeroMax < 2){
         printf("Numero ingresado menor que 2, ingresar numero >= a dos");
         exit(ERROR);
     }
     int fds[2];
     int pipestatus = pipe(fds);
     if (pipestatus == PIPEINVALIDO){
           perror("hubo un error en pipe");
           exit(ERROR);
     }
     int proceso = fork();
     if (proceso < PROCESOINVALIDO){
         perror("Hubo un error en fork");
         exit(ERROR);
     }
     if (proceso == 0){
           close(fds[FDESCRITURA]);
           procesarNumeros(fds[FDLECTURA]);
     } else {
         close(fds[FDLECTURA]);
         bool hayError = false;
         int i = 2;
         while (!hayError && i< numeroMax){
              if (write(fds[FDESCRITURA], &i, sizeof(i)) < 0){
                    perror("error de escritura");
                    hayError = true;
              }
              i++;
         }
         close(fds[FDESCRITURA]);
         wait(0);
     }
	exit(EXITO);
}
