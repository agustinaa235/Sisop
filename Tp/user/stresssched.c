#include <inc/lib.h>

volatile int counter;

void
umain(int argc, char **argv)
{
	int i = fork();

	if (i == 0) {
			cprintf("Soy el primer hijo cuyo id es: %08x y prioridad: %d \n", thisenv->env_id, thisenv->priority);
			int j = fork();
			if (j == 0){
					cprintf("Soy el primer nieto del primer hijo cuyo id es: %08x y prioridad: %d \n", thisenv->env_id, thisenv->priority);
			} else {
					cprintf("Soy primer hijo cuyo id es: %08x y prioridad: %d \n", thisenv->env_id, thisenv->priority);
					int r = fork();
					if (r == 0){
						cprintf("Soy el segundo nieto cuyo id es: %08x y prioridad: %d \n", thisenv->env_id, thisenv->priority);
					} else {
							cprintf("Soy primer hijo cuyo id es: %08x y prioridad: %d \n", thisenv->env_id, thisenv->priority);
					}
			}
	}else{
			cprintf("Soy el padre cuyo id es:  %08x y prioridad: %d \n", thisenv->env_id, thisenv->priority);

			int j = fork();
			if (j == 0) {
					cprintf("Soy el segundo hijo cuyo id es: %08x y prioridad: %d \n", thisenv->env_id, thisenv->priority);
			}
	}
	for (i = 0; i < 5; i++) {
			sys_yield();
			cprintf("Back in environment %08x, iteration %d, cpu %d\n",
							thisenv->env_id,
							i,
							thisenv->env_cpunum);
			cprintf("Running %08x con prioridad: %d \n",thisenv->env_id, thisenv->priority);

	}
	cprintf("All done in environment %08x.\n", thisenv->env_id);
}
