#ifndef BUILTIN_H
#define BUILTIN_H

#include "defs.h"
#include "utils.h"
#include <unistd.h>

extern char promt[PRMTLEN];

int cd(char *cmd);

int exit_shell(char *cmd);

int pwd(char *cmd);

int history(char *cmd);

void guardar_history(char *cmd);

char *designador_eventos(char *cmd, bool *falla);

#endif  // BUILTIN_H
