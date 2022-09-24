#include "runcmd.h"

int status = 0;
struct cmd *parsed_pipe;

// runs the command in 'cmd'
int
run_cmd(char *cmd)
{
	pid_t p;
	struct cmd *parsed;

	// if the "enter" key is pressed
	// just print the promt again
	// guardar_history(cmd);
	if (cmd[0] == END_STRING)
		return 0;
	char *comando = NULL;
	bool falla = true;
	comando = designador_eventos(cmd, &falla);
	if (comando != NULL) {
		int resultado = run_cmd(comando);
		free(comando);
		return resultado;
	} else {
		if (!falla) {
			return 0;
		}
		guardar_history(cmd);
		// "cd" built-in call
		if (cd(cmd))
			return 0;

		if (history(cmd)) {
			return 0;
		}
		// "exit" built-in call
		if (exit_shell(cmd))
			return EXIT_SHELL;

		// "pwd" buil-in call
		if (pwd(cmd))
			return 0;

		// parses the command line
		// guardar_history(cmd);
		parsed = parse_line(cmd);
		// forks and run the command
		if ((p = fork()) == 0) {
			// keep a reference
			// to the parsed pipe cmd
			// so it can be freed later
			if (parsed->type == PIPE)
				parsed_pipe = parsed;

			exec_cmd(parsed);
		}

		// store the pid of the process
		parsed->pid = p;

		// background process special treatment
		// Hint:
		// - check if the process is
		//		going to be run in the 'back'
		// - print info about it with
		// 	'print_back_info()'
		//
		// Your code here

		if ((parsed->type == BACK)) {
			// waits for the process to finish
			waitpid(p, &status, WNOHANG);
			print_back_info(parsed);
		} else {
			waitpid(p, &status, 0);
			print_status_info(parsed);
		}

		free_command(parsed);
	}
	return 0;
}
