/* nos permite seguir la ejecucion de un proceso hijo(que estaba detenido)
  por medio de PRACE_SYSCALL hasta la entrada de una nueva syscall o salida de
  ella.
*/
#include <sys/ptrace.h>
#include <sys/reg.h>
#include <sys/wait.h>
#include <sys/types.h>
#include <sys/user.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <errno.h>
#include <string.h>
#include <stdbool.h>

#include "syscalls.h"

#define EXITO 0
#define ERROR -1
#define CANTIDAD_MINIMA_ARGUMENTOS 2
#define PROCESOINVALIDO 0
#define MAX 1000

static void imprimirSyscall(int codigo) {
    struct syscall *sc;

    for (sc = tablasyscall; sc->codigo >= 0; sc++) {
        if (sc->codigo == codigo) {
            fprintf(stderr, "syscall: %s = ", sc->nombre);
        }
    }
}

static void procesarEntradaASyscall(int hijo, struct user_regs_struct regs){
    ptrace(PTRACE_GETREGS, hijo, 0, &regs);
    int syscall = regs.orig_rax;
    imprimirSyscall(syscall);
    fprintf(stderr, "(%d) = ", syscall);
}
static void procesarRetornoSyscall(int hijo, struct user_regs_struct regs){
      ptrace(PTRACE_GETREGS, hijo, 0, &regs);
      int valorRetorno = regs.rax;
      fprintf(stderr, "%d\n", valorRetorno);
}

static void realizarstrace(int hijo){
    
    int estado;
    bool termine = false;
    bool entro = 0;
    struct user_regs_struct regs;

    waitpid(hijo, &estado, 0);
    if (WIFEXITED(estado)){
        return;
    }
    procesarEntradaASyscall(hijo, regs);
    procesarRetornoSyscall(hijo, regs);

    ptrace (PTRACE_SYSCALL, hijo, NULL, NULL);
    while (!termine){
        waitpid(hijo, &estado, 0);
        if (WIFEXITED(estado) || WIFSIGNALED(estado)){
            termine = true;
        } else {
            if (entro == 0){
                // entro a la syscall por primera vez
                procesarEntradaASyscall(hijo, regs);
                entro = 1;
            } else {
                // sale de la syscall obtener valor de retorno
                procesarRetornoSyscall(hijo, regs);
                entro = 0;
            }
        }
        ptrace (PTRACE_SYSCALL, hijo, NULL, NULL);
      }

}


int main(int argc, char** argv){
    if (argc < CANTIDAD_MINIMA_ARGUMENTOS){
        perror("cantidad de argumentos ingresada invalida");
        exit(ERROR);
    }
    int proceso = fork();
    if (proceso < PROCESOINVALIDO){
        perror("error en crear proceso hijo");
        exit(ERROR);
    }
    if (proceso == 0){
          // a ser traqueado
         ptrace(PTRACE_TRACEME,  0, NULL, NULL);
         execvp(argv[1], argv + 1);
    } else {
          // realiza el traqueo
       realizarstrace(proceso);
    }
    exit(EXITO);
}
