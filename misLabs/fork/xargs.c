
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <stdbool.h>
#ifndef NARGS
#define NARGS 4
#endif
#define CANTIDAD_MINIMA_ARGUMENTOS 2
#define MAX 1000
#define EXITO 0
#define ERROR -1
#define PROCESOINVALIDO 0

static bool procesarlinea(char** cadenas, int* cantidad){
			bool termine = false;
			char* linea = NULL;
			size_t tamanio = 0;
			if (getline(&linea, &tamanio, stdin) == ERROR){
					termine = true;
			} else {
					linea[strlen(linea) -1] = 0;
					strncpy(cadenas[*cantidad], linea, tamanio);
					(*cantidad)++;
			}
			return termine;
}
int main(int argc, char *argv[]){
		const char* comando = argv[1];
		if (argc < CANTIDAD_MINIMA_ARGUMENTOS){;
				printf("cantidad de argumentos invalidad");
				exit(ERROR);
		}
		int cantidad = 0;
		char** cadenas = calloc((NARGS + 2),sizeof(char*));
		for (int i = 0; i< (NARGS + 1); i++){
				cadenas[i] = (char*)calloc(1, (MAX+1)*sizeof(char));
		}
		size_t tam_argumento = strlen(comando);
		memcpy(cadenas[cantidad], comando, tam_argumento);
		cantidad++;
		bool termine = false;
		while (!termine){
				while (cantidad < (NARGS + 1) && !termine){
						termine = procesarlinea(cadenas, &cantidad);
				}
				cadenas[cantidad] = NULL;
				int proceso = fork();
				if (proceso < PROCESOINVALIDO){
						perror("Hubo un error en fork");
						termine = true;
				} else {
						if (proceso == 0){
									if (execvp(argv[1], cadenas) < 0){
												exit(ERROR);
									}
						} else {
								wait(0);
						}
						cantidad = 1;
						procesarlinea(cadenas, &cantidad);
				}
		}
		for (int i = 0; i<5; i++){
				free(cadenas[i]);
		}
		free(cadenas);
		exit(EXITO);
}
