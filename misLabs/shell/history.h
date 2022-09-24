#ifndef HISTORY
#define HISTORY

#include "defs.h"

void guardar_history(char* cmd);

char* buscar_comando(FILE* fhistory, int cant_comandos, bool* falla);

int cant_de_comandos(FILE* fhistory);

void obtener_comandos(FILE* fhistory, char** comandos);

char* obtener_path_history();

#endif
