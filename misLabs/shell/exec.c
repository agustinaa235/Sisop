#include "exec.h"
#include <string.h>
#define FD_ESCRITURA 1
#define FD_LECTURA 0
#define AMPERSEN '&'
#define EXITO 0
#define ERROR 1
// sets "key" with the key part of "arg"
// and null-terminates it
//
// Example:
//  - KEY=value
//  arg = ['K', 'E', 'Y', '=', 'v', 'a', 'l', 'u', 'e', '\0']
//  key = "KEY"
//
static void
get_environ_key(char *arg, char *key)
{
	int i;
	for (i = 0; arg[i] != '='; i++)
		key[i] = arg[i];

	key[i] = END_STRING;
}

// sets "value" with the value part of "arg"
// and null-terminates it
// "idx" should be the index in "arg" where "=" char
// resides
//
// Example:
//  - KEY=value
//  arg = ['K', 'E', 'Y', '=', 'v', 'a', 'l', 'u', 'e', '\0']
//  value = "value"
//
static void
get_environ_value(char *arg, char *value, int idx)
{
	size_t i, j;
	for (i = (idx + 1), j = 0; i < strlen(arg); i++, j++)
		value[j] = arg[i];

	value[j] = END_STRING;
}

// sets the environment variables received
// in the command line
//
// Hints:
// - use 'block_contains()' to
// 	get the index where the '=' is
// - 'get_environ_*()' can be useful here
static void
set_environ_vars(char **eargv, int eargc)
{
	// Your code here
	for (int i = 0; i < eargc; i++) {
		int pos = block_contains(eargv[i], '=');
		char valor[BUFLEN];
		char clave[BUFLEN];
		get_environ_value(eargv[i], valor, pos);
		get_environ_key(eargv[i], clave);
		setenv(clave, valor, 1);
	}
}

// opens the file in which the stdin/stdout/stderr
// flow will be redirected, and returns
// the file descriptor
//
// Find out what permissions it needs.
// Does it have to be closed after the execve(2) call?
//
// Hints:
// - if O_CREAT is used, add S_IWUSR and S_IRUSR
// 	to make it a readable normal file
static int
open_redir_fd(char *file, int flags)
{
	int modo = S_IRWXU | S_IRWXG;
	return open(file, flags, modo);
}

static void
cerrafd(int file)
{
	if (file != -1) {
		close(file);
	}
}
// executes a command - does not return
//
// Hint:
// - check how the 'cmd' structs are defined
// 	in types.h
// - casting could be a good option

void
exec_cmd(struct cmd *cmd)
{
	// To be used in the different cases
	struct execcmd *e;
	struct backcmd *b;
	struct execcmd *r;
	struct pipecmd *p;

	switch (cmd->type) {
	case EXEC:
		// spawns a command
		//
		// Your code here
		e = (struct execcmd *) cmd;
		set_environ_vars(e->eargv, e->eargc);
		execvp(e->argv[0], e->argv);
		free_command(cmd);
		exit(ERROR);
		break;

	case BACK: {
		// runs a command in background
		//
		// Your code here
		b = (struct backcmd *) cmd;
		exec_cmd(b->c);
		break;
	}

	case REDIR: {
		// changes the input/output/stderr flow
		//
		// To check if a redirection has to be performed
		// verify if file name's length (in the execcmd struct)
		// is greater than zero
		//
		r = (struct execcmd *) cmd;
		int fd_in = -1;
		int fd_out = -1;
		int fd_error = -1;
		if (strlen(r->in_file) > 0) {
			fd_in = open_redir_fd(r->in_file,
			                      O_CREAT | O_CLOEXEC | O_RDONLY);
			if (fd_in == -1) {
				fprintf_debug(
				        stderr, "%s\n", "Error: no se pudo abrir el archivo de entrada");
				_exit(ERROR);
			}
			dup2(fd_in, 0);
		}
		if (strlen(r->out_file) > 0) {
			fd_out = open_redir_fd(r->out_file,
			                       O_CREAT | O_TRUNC | O_WRONLY);
			if (fd_out == -1) {
				fprintf_debug(
				        stderr, "%s\n", "Error: no se pudo abrir el archivo de salida");
				_exit(ERROR);
			}
			dup2(fd_out, 1);
		}
		if (strlen(r->err_file) > 0) {
			if (r->err_file[0] == AMPERSEN) {
				dup2(fd_out, 2);
			} else {
				fd_error = open_redir_fd(r->err_file,
				                         O_CREAT | O_TRUNC |
				                                 O_WRONLY |
				                                 O_CLOEXEC);
				if (fd_error == -1) {
					fprintf_debug(
					        stderr, "%s\n", "Error: no se pudo abrir el archivo de error");
					_exit(ERROR);
				}
				dup2(fd_error, 2);
			}
		}
		execvp(r->argv[0], r->argv);
		cerrafd(fd_in);
		cerrafd(fd_out);
		cerrafd(fd_error);
		_exit(EXITO);
		break;
	}

	case PIPE: {
		// pipes two commands
		//
		// Your code here
		p = (struct pipecmd *) cmd;
		int fd[2];
		int estado = pipe(fd);
		if (estado == -1) {
			fprintf_debug(stderr,
			              "%s\n",
			              "Error: no se pudo hacer pipe");
			free_command(cmd);
			_exit(ERROR);
		}
		int proceso_izquierda = fork();
		if (proceso_izquierda < 0) {
			fprintf_debug(stderr,
			              "%s\n",
			              "Error: no se pudo hacer fork");
			_exit(ERROR);
		}
		if (proceso_izquierda == 0) {
			close(fd[FD_LECTURA]);
			dup2(fd[FD_ESCRITURA], 1);
			close(fd[FD_ESCRITURA]);
			exec_cmd(p->leftcmd);
		} else {
			int proceso_derecha = fork();
			if (proceso_derecha < 0) {
				fprintf_debug(stderr,
				              "%s\n",
				              "Error: no se pudo hacer fork");
				free_command(cmd);
				_exit(ERROR);
			}
			if (proceso_derecha == 0) {
				close(fd[FD_ESCRITURA]);
				dup2(fd[FD_LECTURA], 0);
				close(fd[FD_LECTURA]);
				struct cmd *aux = p->rightcmd;
				free_command(p->leftcmd);
				free(cmd);
				exec_cmd(aux);
			} else {
				close(fd[FD_ESCRITURA]);
				close(fd[FD_LECTURA]);
				waitpid(proceso_derecha, NULL, 0);
				waitpid(proceso_izquierda, NULL, 0);
				free_command(cmd);
			}
		}
		// free the memory allocated
		// for the pipe tree structure
		// free_command(cmd);
		exit(EXITO);
		break;
	}
	}
}
