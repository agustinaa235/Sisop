#include <inc/assert.h>
#include <inc/x86.h>
#include <kern/spinlock.h>
#include <kern/env.h>
#include <kern/pmap.h>
#include <kern/monitor.h>


void sched_halt(void);

unsigned long int next = 1;

// Choose a user environment to run and run it.
unsigned int
rand()
{  // le puse numeros primos
	next = next * 1103515245 + 12345;
	return ((unsigned) (next / 65536) % 32768);
}

void
sched_yield(void)
{
	struct Env *idle;

	// Implement simple round-robin scheduling.
	//
	// Search through 'envs' for an ENV_RUNNABLE environment in
	// circular fashion starting just after the env this CPU was
	// last running.  Switch to the first such environment found.
	//
	// If no envs are runnable, but the environment previously
	// running on this CPU is still ENV_RUNNING, it's okay to
	// choose that environment.
	//
	// Never choose an environment that's currently running on
	// anoexternther CPU (env_status == ENV_RUNNING). If there are
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.
	struct Env *runenv = NULL;
	// LAB 4: Your code here.
	int indx = 0;
	if (curenv) {
		indx = ENVX(curenv->env_id) + 1;
	}
	int counter = 0;
	int total_priority = 0;

	for (int i = 0; i < NENV; i++) {
		if (envs[i].env_status == ENV_RUNNABLE ||
		    envs[i].env_status == ENV_RUNNING) {
			total_priority += envs[i].priority;
		}
	}

	unsigned winner = (rand() % (total_priority - 1) + 1);

	bool find = false;
	int i = 0;
	while (i < NENV && !find) {
		int j = (indx + i) % NENV;
		if (envs[j].env_status == ENV_RUNNABLE ||
		    envs[j].env_status == ENV_RUNNING) {
			counter = counter + envs[j].priority;
			if (counter >= winner) {
				// encontramos al ganador
				find = true;
				env_run(envs + j);
			}
		}
		i++;
	}

	if (curenv && (curenv->env_status == ENV_RUNNING)) {
		env_run(curenv);
	}
	// sched_halt never returns
	sched_halt();
}

// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
		cprintf("No runnable environments in the system!\n");
		while (1)
			monitor(NULL);
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
	lcr3(PADDR(kern_pgdir));

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile("movl $0, %%ebp\n"
	             "movl %0, %%esp\n"
	             "pushl $0\n"
	             "pushl $0\n"
	             "sti\n"
	             "1:\n"
	             "hlt\n"
	             "jmp 1b\n"
	             :
	             : "a"(thiscpu->cpu_ts.ts_esp0));
}
