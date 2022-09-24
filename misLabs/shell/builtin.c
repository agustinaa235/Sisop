#include "builtin.h"
#include <string.h>
#include "history.h"
#define SALIDA "exit"
#define CD "cd"
#define PWD "pwd"
#define EXITO 0
#define TODOS_LOS_COMANDOS -1

// returns true if the 'exit' call
// should be performed
//
// (It must not be called from here)
int
exit_shell(char *cmd)
{
	// Your code here
	if (strcmp(cmd, SALIDA) == 0) {
		return true;
	}
	return false;
}

// returns true if "chdir" was performed
//  this means that if 'cmd' contains:
// 	1. $ cd directory (change to 'directory')
// 	2. $ cd (change to $HOME)
//  it has to be executed and then return true
//
//  Remember to update the 'prompt' with the
//  	new directory.
//
// Examples:
//  1. cmd = ['c','d', ' ', '/', 'b', 'i', 'n', '\0']
//  2. cmd = ['c','d', '\0']
int
cd(char *cmd)
{
	// Your code here
	if (strncmp(cmd, CD, 2) == 0) {
		int pos = block_contains(cmd, ' ');
		if (pos > 0) {
			char *path = split_line(cmd, ' ');
			chdir(path);
			char *direc_actual = getcwd(path, PRMTLEN);
			snprintf(promt, sizeof promt, "(%s)", direc_actual);
		} else {
			char *home = chdir(getenv("HOME"));
			snprintf(promt, sizeof promt, "(%s)", home);
		}
		return true;
	}
	return false;
}

// returns true if 'pwd' was invoked
// in the command line
//
// (It has to be executed here and then
// 	return true)
int
pwd(char *cmd)
{
	// Your code here
	if (strcmp(cmd, PWD) == 0) {
		char cadena[BUFLEN];
		printf("%s\n", getcwd(cadena, BUFLEN));
		return true;
	}
	return false;
}

/*
 * Se encarga de mostrara por consola todos los comandos en el caso
 * que no se indique una cantidad o la cantidad de comandos indicada
 * a partir del ultimo comando ejecutado.
 * El archivo debe estar previamente abierto.
 */
static void
mostrar_history(FILE *fhistory, int cantidad)
{
	if (cantidad != 0) {
		if (cantidad == TODOS_LOS_COMANDOS) {
			char c = 0;
			fread(&c, sizeof(char), 1, fhistory);
			while (!feof(fhistory)) {
				write(STDOUT_FILENO, &c, 1);
				fread(&c, sizeof(char), 1, fhistory);
			}
		} else {
			int cantidad_a_leer = 0;
			char *comando = NULL;
			size_t len = 0;
			getline(&comando, &len, fhistory);
			while (!feof(fhistory)) {
				cantidad_a_leer++;
				free(comando);
				comando = NULL;
				len = 0;
				getline(&comando, &len, fhistory);
			}
			free(comando);
			comando = NULL;
			rewind(fhistory);
			int borrar = 0;
			if (cantidad_a_leer - cantidad > 0) {
				borrar = cantidad_a_leer - cantidad;
			}
			int aux = 0;
			while (aux < (borrar) && !feof(fhistory)) {
				free(comando);
				comando = NULL;
				len = 0;
				aux++;
				getline(&comando, &len, fhistory);
			}
			free(comando);
			char c = 0;
			fread(&c, sizeof(char), 1, fhistory);
			while (!feof(fhistory)) {
				write(1, &c, 1);
				fread(&c, sizeof(char), 1, fhistory);
			}
		}
	}
}

/*
 * Se encarga de mostrar el historial de comandos en caso de que llegue "history"
 */
int
history(char *cmd)
{
	if (!cmd) {
		return false;
	}
	char *aux = strstr(cmd, "history");
	if (aux == cmd) {
		char *cant_aux = cmd + strlen("history") + 1;
		char *espacio = cmd + strlen("history");

		char *ruta = NULL;

		ruta = obtener_path_history();
		FILE *fhistory = fopen(ruta, "r");
		if (!fhistory) {
			perror("No se pudo abrir el archivo history");
			free(ruta);
			return false;
		}
		if (strlen(cant_aux) > 0 && espacio[0] == ' ') {
			int cant_history = atoi(cant_aux);
			mostrar_history(fhistory, cant_history);
		} else {
			if (espacio[0] == ' ' || espacio[0] == '\0') {
				mostrar_history(fhistory, TODOS_LOS_COMANDOS);
			}
		}
		fclose(fhistory);
		free(ruta);
		return true;
	}
	return false;
}

/*
 * se encarga de ejecutar el comando anterior en caso de que le llegue !! o
 * el comando n anterior al ejecutado si llega !-n.
 */
char *
designador_eventos(char *cmd, bool *falla)
{
	if (!cmd) {
		return NULL;
	}
	char *comando = NULL;
	if (cmd[0] == '!' && strlen(cmd) >= 2) {
		char *ruta = NULL;
		ruta = obtener_path_history();

		FILE *fhistory = fopen(ruta, "r");
		if (!fhistory) {
			perror("No se pudo abrir el archivo history");
			free(ruta);
			return NULL;
		}
		if (strlen(cmd) >= 2 && cmd[1] == '!') {
			comando = buscar_comando(fhistory, 1, falla);
		} else {
			if (strlen(cmd) >= 3 && cmd[1] == '-') {
				int cant_comandos_ejecutar = atoi(cmd + 2);
				comando = buscar_comando(fhistory,
				                         cant_comandos_ejecutar,
				                         falla);
			}
		}
		fclose(fhistory);
		free(ruta);
		return comando;
	}
	return NULL;
}
