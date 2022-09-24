#define _GNU_SOURCE
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <sys/types.h>
#include <dirent.h>
#include <fcntl.h>

#define FLAGCASE "-i"
#define MAXPATH 1000
#define BARRA "/"
#define EXITO 0
#define ERROR -1
#define CANTIDAD_MINIMA_ARGUMENTOS 2
#define CASEINSENSITVE 3
#define CASESENSITIVE 2

static void buscarDirectorios(DIR* directorio, char* path, const char* cadenaABuscar,
												char*(*comparar)(const char*,const char*)){
		if (directorio == NULL){
				return;
		}
		char pathActual[MAXPATH] = "";
		memcpy(pathActual, path, strlen(path));
		struct dirent* entrada;
		while ((entrada = readdir(directorio)) != NULL){

				if (comparar(entrada->d_name, cadenaABuscar) != NULL){
							if (strlen(path) == 1){
									printf("%s \n", entrada->d_name);
							} else {
									printf("%s%s \n", path, entrada->d_name);
							}
				}

				if (entrada->d_type == DT_DIR && strcmp(entrada->d_name, ".") != 0 &&
						strcmp(entrada->d_name, "..") != 0){
						int fd_subdirectorio = openat(dirfd(directorio), entrada->d_name,
																					O_DIRECTORY);
						if (fd_subdirectorio != -1){
								char aux[MAXPATH] = "";
								strcat(aux, path);
								strcat(aux, entrada->d_name);
								strcat(aux, BARRA);
								DIR* subdir = fdopendir(fd_subdirectorio);
								buscarDirectorios(subdir,aux,cadenaABuscar, comparar);
								closedir(subdir);
								path = pathActual;
						} else {
								perror("error al acceder a file descriptor");
						}
				}
			}
}

int main(int argc, char *argv[]){
		if (argc < CANTIDAD_MINIMA_ARGUMENTOS){
				printf("cantidad invalida de argumentos");
				exit(ERROR);
		}
		char *path = ".";
		DIR *directorio = opendir(path);
		if (directorio == NULL) {
				perror("error con opendir");
				exit(ERROR);
		}
		if (argc == CASEINSENSITVE && strcmp(argv[1], FLAGCASE) == 0){
				buscarDirectorios(directorio,path, argv[2], strcasestr);
		} else if (argc == CASESENSITIVE){
				buscarDirectorios(directorio,path, argv[1], strstr);
		} else {
				perror("error de ingreso correcto de comandos");
		}
		closedir(directorio);
		exit(EXITO);
}
