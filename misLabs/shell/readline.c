#include "defs.h"
#include "readline.h"
#include "nonCanonical.h"
#include "history.h"

static char buffer[BUFLEN];


/*
 * borra lo que se encuentra en la consola
 */
static void
actualizar_salida(int largo_comando_actual)
{
	// hasta largo - 1 para no borrar el $
	for (int i = 0; i < largo_comando_actual; i++) {
		write(STDOUT_FILENO, "\b \b", 3);
	}
}
/*
 * actualiza el buffer con un nuevo comando
 */
static void
actualizar_buffer(int *largo_comando_actual,
                  char *comando_actual,
                  int comando_a_mostrar,
                  int cant_comandos)
{
	if (comando_a_mostrar < cant_comandos) {
		memset(buffer, 0, BUFLEN);
		int tam = strlen(comando_actual);
		memcpy(buffer, comando_actual, tam);
		(*largo_comando_actual) = tam;
	}
	// printf("bufer: %s ", buffer);
}
/*
 * se encargar de realizar la actualizacion del buffer y de la consola
 */
static void
actualizacion(int *largo_comando_actual,
              char *comando_actual,
              int comando_a_mostrar,
              int cant_comandos)
{
	actualizar_salida(*largo_comando_actual);
	write(STDOUT_FILENO, comando_actual, strlen(comando_actual));
	actualizar_buffer(largo_comando_actual,
	                  comando_actual,
	                  comando_a_mostrar,
	                  cant_comandos);
}

/*
 * se encargar de realizar modificar el buffer y la salida por consola cuando
 * llega una flecha para arriba o una para abajo
 */
static void
parceo(int *c,
       int *comando_a_mostrar,
       int cant_comandos,
       char **comandos,
       int *largo_comando_actual)
{
	if (*c == FLECHA_ARRIBA) {
		// printf("soy felcha arriba");
		if (cant_comandos > 0 && (*comando_a_mostrar) < cant_comandos) {
			(*comando_a_mostrar) += 1;
			actualizacion(largo_comando_actual,
			              comandos[cant_comandos - (*comando_a_mostrar)],
			              *comando_a_mostrar,
			              cant_comandos);
		}
	} else if (*c == FLECHA_ABAJO) {
		// no sos el ulitmo comando
		if ((*comando_a_mostrar) > 1) {
			(*comando_a_mostrar) -= 1;
			actualizacion(largo_comando_actual,
			              comandos[cant_comandos - *comando_a_mostrar],
			              *comando_a_mostrar,
			              cant_comandos);
		} else {
			// sos el ultimo comando
			*comando_a_mostrar = 0;
			actualizar_salida(*largo_comando_actual);
			*largo_comando_actual = 0;
			buffer[0] = '\0';
		}

	} else if (*c == FLECHA_IZQUIERDA) {
		if ((*largo_comando_actual) != 0) {
			(*largo_comando_actual) -= 1;
			write(STDOUT_FILENO, "\b", 1);
		}
	} else if (*c == FLECHA_DERECHA) {
		if ((*largo_comando_actual) != (strlen(buffer))) {
			(*largo_comando_actual) += 1;
			printf("\033[1C");
		}
	}
}

static void
actualizar(int *p, int tam_buffer)
{
	while (*p < tam_buffer) {
		write(STDOUT_FILENO, " ", 1);
		*p += 1;
	}
}
static void
mover_cursor(int *p, int pos)
{
	while (*p > pos) {
		write(STDOUT_FILENO, "\b", 1);
		*p -= 1;
	}
}
static void
concatenar(char aux[BUFLEN], char buffer[BUFLEN], int j)
{
	while (j < strlen(buffer)) {
		strncat(aux, &buffer[j], 1);
		write(STDOUT_FILENO, &buffer[j], 1);
		j++;
	}
}
static void
cambio_buffer_y_muevo_cursor(char aux[BUFLEN], char buffer[BUFLEN], int k)
{
	memset(buffer, 0, BUFLEN);
	memcpy(buffer, aux, BUFLEN);
	while (k < strlen(buffer)) {
		printf("\033[1D");
		k++;
	}
}

// reads a line from the standard input
// and prints the prompt
char *
read_line(const char *promt)
{
	int i = 0, c = 0;

#ifndef SHELL_NO_INTERACTIVE
	fprintf(stdout, "%s %s %s\n", COLOR_RED, promt, COLOR_RESET);
	fprintf(stdout, "%s", "$ ");
#endif

	memset(buffer, 0, BUFLEN);

	char *ruta = NULL;
	ruta = obtener_path_history();

	int cant_comandos = 0;
	FILE *fhistory = fopen(ruta, "r");
	if (!fhistory) {
		fhistory = fopen(ruta, "w+");
		if (!fhistory) {
			free(ruta);
			return NULL;
		}
	}
	if (fhistory != NULL) {
		cant_comandos = cant_de_comandos(fhistory);
	}
	char **comandos = calloc((cant_comandos), sizeof(char *));
	for (int i = 0; i < cant_comandos; i++) {
		comandos[i] = (char *) calloc(1, (BUFLEN) * sizeof(char));
	}

	if (fhistory != NULL) {
		obtener_comandos(fhistory, comandos);
		fclose(fhistory);
	}
	int comando_a_mostrar = 0;
	set_input_mode();
	c = getchar();
	while (c != END_LINE && c != VEOF) {
		if (c == ESC) {
			getchar();  // salteo la [
			c = getchar();
			parceo(&c, &comando_a_mostrar, cant_comandos, comandos, &i);
		} else if (c == BACKSPACE) {
			// no le permito borrar el $
			if (i == strlen(buffer)) {
				if (strlen(buffer) != 0) {
					buffer[i] = '\0';
					(i) -= 1;
					buffer[i] = '\0';
					write(STDOUT_FILENO, "\b \b", 3);
				}
			} else {
				int j = i;
				int k = i - 1;
				char aux[BUFLEN];
				memset(aux, 0, BUFLEN);

				int p = i - 1;
				write(STDOUT_FILENO, "\b", 1);
				actualizar(&p, strlen(buffer));
				p++;
				mover_cursor(&p, i);
				strncpy(aux, buffer, j);
				j--;
				aux[j] = '\0';
				j++;
				concatenar(aux, buffer, j);
				cambio_buffer_y_muevo_cursor(aux, buffer, k);
				if (i != 0) {
					i--;
				}
			}
		} else {
			if (i == strlen(buffer)) {
				write(STDOUT_FILENO, &c, 1);
				(i) += 1;
				char caracter = (char) c;
				strncat(buffer, &caracter, 1);
			} else {
				char aux[BUFLEN];
				memset(aux, 0, BUFLEN);
				int p = i;
				actualizar(&p, strlen(buffer));
				mover_cursor(&p, i);
				int j = i;
				int k = i + 1;
				strncpy(aux, buffer, j);
				char caracter = (char) c;
				strncat(aux, &caracter, 1);
				write(STDOUT_FILENO, &c, 1);
				concatenar(aux, buffer, j);
				cambio_buffer_y_muevo_cursor(aux, buffer, k);
				i++;
			}
		}
		if (c != VEOF) {
			c = getchar();
		}
	}
	i = strlen(buffer);
	write(1, "\n", 1);
	for (int i = 0; i < cant_comandos; i++) {
		free(comandos[i]);
	}
	free(comandos);
	free(ruta);
	// if the user press ctrl+D
	// just exit normally
	if (c == VEOF)
		return NULL;
	i++;
	buffer[i] = END_STRING;

	return buffer;
}
