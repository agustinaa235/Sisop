#include <inc/lib.h>

void
umain(int argc, char **argv)
{
	int i;
	for (i = 1; i <= 5; ++i) {
		int pid = priority_fork(i);
		if (pid == 0) {
			cprintf("Hello, child %x is now living!\n", i);
			int j;
			for (j = 0; j < 5; ++j) {
				cprintf("Hello, child %x is yielding!\n", i);
				sys_yield();
			}
			break;
		}
	}
}