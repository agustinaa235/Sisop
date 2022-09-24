// hello, world
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
	cprintf("hello, world\n");


	int i;
	cprintf("prioridad proceso padre: %d\n", thisenv->priority);
	for (i = 1; i <= 5; ++i) {
		int pid = fork();
		if (pid == 0) {
			cprintf("\t\ti am environment %08x\n", sys_getenvid());
			cprintf("\t\tHello, child %x is now living! con prioridad: %d \n", i, thisenv->priority);
			int j;
			for (j = 0; j < 5; ++j) {
				cprintf("\t\t\tHello, child %x is yielding! con prioridad: %d \n", i, thisenv->priority);
				sys_yield();
			}
			break;
		}
	}
}
