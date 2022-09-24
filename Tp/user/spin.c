// Test preemption by forking off a child process that just spins forever.
// Let it run for a couple time slices, then kill it.

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
	envid_t env;

	cprintf("I am the parent con prioridad: %d .  Forking the child...\n", thisenv->priority);
	env = fork();
	if (env == 0) {
		cprintf("I am the child con prioridad: %d .  Spinning...\n", thisenv->priority);
		while (1)
			/* do nothing */;
	}
	cprintf("I am the parent con prioridad: %d.  Running the child...\n");
	sys_yield();
	sys_yield();
	sys_yield();
	sys_yield();
	sys_yield();
	sys_yield();
	sys_yield();
	sys_yield();

	cprintf("I am the parent con prioridad: %d.  Killing the child...\n");
	sys_env_destroy(env);
}
