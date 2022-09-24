
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
_start = RELOC(entry)

.globl entry
.func entry
entry:
	movw	$0x1234,0x472			# warm boot
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 20 12 00       	mov    $0x122000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3

	# Turn on large pages.
	movl	%cr4, %eax
f010001d:	0f 20 e0             	mov    %cr4,%eax
	orl	$(CR4_PSE), %eax
f0100020:	83 c8 10             	or     $0x10,%eax
	movl	%eax, %cr4
f0100023:	0f 22 e0             	mov    %eax,%cr4

	# Turn on paging.
	movl	%cr0, %eax
f0100026:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100029:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f010002e:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100031:	b8 38 00 10 f0       	mov    $0xf0100038,%eax
	jmp	*%eax
f0100036:	ff e0                	jmp    *%eax

f0100038 <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f0100038:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f010003d:	bc 00 20 12 f0       	mov    $0xf0122000,%esp

	# now to C code
	call	i386_init
f0100042:	e8 83 01 00 00       	call   f01001ca <i386_init>

f0100047 <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f0100047:	eb fe                	jmp    f0100047 <spin>

f0100049 <lcr3>:
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0100049:	0f 22 d8             	mov    %eax,%cr3
}
f010004c:	c3                   	ret    

f010004d <xchg>:
	return tsc;
}

static inline uint32_t
xchg(volatile uint32_t *addr, uint32_t newval)
{
f010004d:	89 c1                	mov    %eax,%ecx
f010004f:	89 d0                	mov    %edx,%eax
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0100051:	f0 87 01             	lock xchg %eax,(%ecx)
		     : "+m" (*addr), "=a" (result)
		     : "1" (newval)
		     : "cc");
	return result;
}
f0100054:	c3                   	ret    

f0100055 <lock_kernel>:

extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
f0100055:	55                   	push   %ebp
f0100056:	89 e5                	mov    %esp,%ebp
f0100058:	83 ec 14             	sub    $0x14,%esp
	spin_lock(&kernel_lock);
f010005b:	68 c0 33 12 f0       	push   $0xf01233c0
f0100060:	e8 94 62 00 00       	call   f01062f9 <spin_lock>
}
f0100065:	83 c4 10             	add    $0x10,%esp
f0100068:	c9                   	leave  
f0100069:	c3                   	ret    

f010006a <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
f010006a:	f3 0f 1e fb          	endbr32 
f010006e:	55                   	push   %ebp
f010006f:	89 e5                	mov    %esp,%ebp
f0100071:	56                   	push   %esi
f0100072:	53                   	push   %ebx
f0100073:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f0100076:	83 3d 80 fe 24 f0 00 	cmpl   $0x0,0xf024fe80
f010007d:	74 0f                	je     f010008e <_panic+0x24>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010007f:	83 ec 0c             	sub    $0xc,%esp
f0100082:	6a 00                	push   $0x0
f0100084:	e8 b1 0a 00 00       	call   f0100b3a <monitor>
f0100089:	83 c4 10             	add    $0x10,%esp
f010008c:	eb f1                	jmp    f010007f <_panic+0x15>
	panicstr = fmt;
f010008e:	89 35 80 fe 24 f0    	mov    %esi,0xf024fe80
	asm volatile("cli; cld");
f0100094:	fa                   	cli    
f0100095:	fc                   	cld    
	va_start(ap, fmt);
f0100096:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf(">>>\n>>> kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f0100099:	e8 56 5f 00 00       	call   f0105ff4 <cpunum>
f010009e:	ff 75 0c             	pushl  0xc(%ebp)
f01000a1:	ff 75 08             	pushl  0x8(%ebp)
f01000a4:	50                   	push   %eax
f01000a5:	68 c0 66 10 f0       	push   $0xf01066c0
f01000aa:	e8 7e 38 00 00       	call   f010392d <cprintf>
	vcprintf(fmt, ap);
f01000af:	83 c4 08             	add    $0x8,%esp
f01000b2:	53                   	push   %ebx
f01000b3:	56                   	push   %esi
f01000b4:	e8 4a 38 00 00       	call   f0103903 <vcprintf>
	cprintf("\n>>>\n");
f01000b9:	c7 04 24 34 67 10 f0 	movl   $0xf0106734,(%esp)
f01000c0:	e8 68 38 00 00       	call   f010392d <cprintf>
f01000c5:	83 c4 10             	add    $0x10,%esp
f01000c8:	eb b5                	jmp    f010007f <_panic+0x15>

f01000ca <_kaddr>:
 * virtual address.  It panics if you pass an invalid physical address. */
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
f01000ca:	55                   	push   %ebp
f01000cb:	89 e5                	mov    %esp,%ebp
f01000cd:	53                   	push   %ebx
f01000ce:	83 ec 04             	sub    $0x4,%esp
	if (PGNUM(pa) >= npages)
f01000d1:	89 cb                	mov    %ecx,%ebx
f01000d3:	c1 eb 0c             	shr    $0xc,%ebx
f01000d6:	3b 1d 88 fe 24 f0    	cmp    0xf024fe88,%ebx
f01000dc:	73 0b                	jae    f01000e9 <_kaddr+0x1f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
	return (void *)(pa + KERNBASE);
f01000de:	8d 81 00 00 00 f0    	lea    -0x10000000(%ecx),%eax
}
f01000e4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01000e7:	c9                   	leave  
f01000e8:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01000e9:	51                   	push   %ecx
f01000ea:	68 ec 66 10 f0       	push   $0xf01066ec
f01000ef:	52                   	push   %edx
f01000f0:	50                   	push   %eax
f01000f1:	e8 74 ff ff ff       	call   f010006a <_panic>

f01000f6 <_paddr>:
	if ((uint32_t)kva < KERNBASE)
f01000f6:	81 f9 ff ff ff ef    	cmp    $0xefffffff,%ecx
f01000fc:	76 07                	jbe    f0100105 <_paddr+0xf>
	return (physaddr_t)kva - KERNBASE;
f01000fe:	8d 81 00 00 00 10    	lea    0x10000000(%ecx),%eax
}
f0100104:	c3                   	ret    
{
f0100105:	55                   	push   %ebp
f0100106:	89 e5                	mov    %esp,%ebp
f0100108:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010010b:	51                   	push   %ecx
f010010c:	68 10 67 10 f0       	push   $0xf0106710
f0100111:	52                   	push   %edx
f0100112:	50                   	push   %eax
f0100113:	e8 52 ff ff ff       	call   f010006a <_panic>

f0100118 <boot_aps>:
{
f0100118:	55                   	push   %ebp
f0100119:	89 e5                	mov    %esp,%ebp
f010011b:	56                   	push   %esi
f010011c:	53                   	push   %ebx
	code = KADDR(MPENTRY_PADDR);
f010011d:	b9 00 70 00 00       	mov    $0x7000,%ecx
f0100122:	ba 62 00 00 00       	mov    $0x62,%edx
f0100127:	b8 3a 67 10 f0       	mov    $0xf010673a,%eax
f010012c:	e8 99 ff ff ff       	call   f01000ca <_kaddr>
f0100131:	89 c6                	mov    %eax,%esi
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f0100133:	83 ec 04             	sub    $0x4,%esp
f0100136:	b8 f2 5b 10 f0       	mov    $0xf0105bf2,%eax
f010013b:	2d 70 5b 10 f0       	sub    $0xf0105b70,%eax
f0100140:	50                   	push   %eax
f0100141:	68 70 5b 10 f0       	push   $0xf0105b70
f0100146:	56                   	push   %esi
f0100147:	e8 67 58 00 00       	call   f01059b3 <memmove>
	for (c = cpus; c < cpus + ncpu; c++) {
f010014c:	83 c4 10             	add    $0x10,%esp
f010014f:	bb 20 00 25 f0       	mov    $0xf0250020,%ebx
f0100154:	eb 4a                	jmp    f01001a0 <boot_aps+0x88>
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100156:	89 d8                	mov    %ebx,%eax
f0100158:	2d 20 00 25 f0       	sub    $0xf0250020,%eax
f010015d:	c1 f8 02             	sar    $0x2,%eax
f0100160:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f0100166:	c1 e0 0f             	shl    $0xf,%eax
f0100169:	8d 80 00 90 25 f0    	lea    -0xfda7000(%eax),%eax
f010016f:	a3 84 fe 24 f0       	mov    %eax,0xf024fe84
		lapic_startap(c->cpu_id, PADDR(code));
f0100174:	89 f1                	mov    %esi,%ecx
f0100176:	ba 6d 00 00 00       	mov    $0x6d,%edx
f010017b:	b8 3a 67 10 f0       	mov    $0xf010673a,%eax
f0100180:	e8 71 ff ff ff       	call   f01000f6 <_paddr>
f0100185:	83 ec 08             	sub    $0x8,%esp
f0100188:	50                   	push   %eax
f0100189:	0f b6 03             	movzbl (%ebx),%eax
f010018c:	50                   	push   %eax
f010018d:	e8 d6 5f 00 00       	call   f0106168 <lapic_startap>
		while (c->cpu_status != CPU_STARTED)
f0100192:	83 c4 10             	add    $0x10,%esp
f0100195:	8b 43 04             	mov    0x4(%ebx),%eax
f0100198:	83 f8 01             	cmp    $0x1,%eax
f010019b:	75 f8                	jne    f0100195 <boot_aps+0x7d>
	for (c = cpus; c < cpus + ncpu; c++) {
f010019d:	83 c3 74             	add    $0x74,%ebx
f01001a0:	6b 05 c4 03 25 f0 74 	imul   $0x74,0xf02503c4,%eax
f01001a7:	05 20 00 25 f0       	add    $0xf0250020,%eax
f01001ac:	39 c3                	cmp    %eax,%ebx
f01001ae:	73 13                	jae    f01001c3 <boot_aps+0xab>
		if (c == cpus + cpunum())  // We've started already.
f01001b0:	e8 3f 5e 00 00       	call   f0105ff4 <cpunum>
f01001b5:	6b c0 74             	imul   $0x74,%eax,%eax
f01001b8:	05 20 00 25 f0       	add    $0xf0250020,%eax
f01001bd:	39 c3                	cmp    %eax,%ebx
f01001bf:	74 dc                	je     f010019d <boot_aps+0x85>
f01001c1:	eb 93                	jmp    f0100156 <boot_aps+0x3e>
}
f01001c3:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01001c6:	5b                   	pop    %ebx
f01001c7:	5e                   	pop    %esi
f01001c8:	5d                   	pop    %ebp
f01001c9:	c3                   	ret    

f01001ca <i386_init>:
{
f01001ca:	f3 0f 1e fb          	endbr32 
f01001ce:	55                   	push   %ebp
f01001cf:	89 e5                	mov    %esp,%ebp
f01001d1:	83 ec 0c             	sub    $0xc,%esp
	memset(__bss_start, 0, end - __bss_start);
f01001d4:	b8 08 10 29 f0       	mov    $0xf0291008,%eax
f01001d9:	2d 00 e0 24 f0       	sub    $0xf024e000,%eax
f01001de:	50                   	push   %eax
f01001df:	6a 00                	push   $0x0
f01001e1:	68 00 e0 24 f0       	push   $0xf024e000
f01001e6:	e8 7a 57 00 00       	call   f0105965 <memset>
	cons_init();
f01001eb:	e8 e1 06 00 00       	call   f01008d1 <cons_init>
	cprintf("6828 decimal is %o octal!\n", 6828);
f01001f0:	83 c4 08             	add    $0x8,%esp
f01001f3:	68 ac 1a 00 00       	push   $0x1aac
f01001f8:	68 46 67 10 f0       	push   $0xf0106746
f01001fd:	e8 2b 37 00 00       	call   f010392d <cprintf>
	mem_init();
f0100202:	e8 80 2a 00 00       	call   f0102c87 <mem_init>
	env_init();
f0100207:	e8 81 30 00 00       	call   f010328d <env_init>
	trap_init();
f010020c:	e8 22 38 00 00       	call   f0103a33 <trap_init>
	mp_init();
f0100211:	e8 21 5c 00 00       	call   f0105e37 <mp_init>
	lapic_init();
f0100216:	e8 f3 5d 00 00       	call   f010600e <lapic_init>
	pic_init();
f010021b:	e8 bf 35 00 00       	call   f01037df <pic_init>
	lock_kernel();
f0100220:	e8 30 fe ff ff       	call   f0100055 <lock_kernel>
	boot_aps();
f0100225:	e8 ee fe ff ff       	call   f0100118 <boot_aps>
	ENV_CREATE(TEST, ENV_TYPE_USER);
f010022a:	83 c4 08             	add    $0x8,%esp
f010022d:	6a 00                	push   $0x0
f010022f:	68 5c 66 1b f0       	push   $0xf01b665c
f0100234:	e8 ad 31 00 00       	call   f01033e6 <env_create>
	sched_yield();
f0100239:	e8 15 43 00 00       	call   f0104553 <sched_yield>

f010023e <mp_main>:
{
f010023e:	f3 0f 1e fb          	endbr32 
f0100242:	55                   	push   %ebp
f0100243:	89 e5                	mov    %esp,%ebp
f0100245:	83 ec 08             	sub    $0x8,%esp
	lcr3(PADDR(kern_pgdir));
f0100248:	8b 0d 8c fe 24 f0    	mov    0xf024fe8c,%ecx
f010024e:	ba 79 00 00 00       	mov    $0x79,%edx
f0100253:	b8 3a 67 10 f0       	mov    $0xf010673a,%eax
f0100258:	e8 99 fe ff ff       	call   f01000f6 <_paddr>
f010025d:	e8 e7 fd ff ff       	call   f0100049 <lcr3>
	cprintf("SMP: CPU %d starting\n", cpunum());
f0100262:	e8 8d 5d 00 00       	call   f0105ff4 <cpunum>
f0100267:	83 ec 08             	sub    $0x8,%esp
f010026a:	50                   	push   %eax
f010026b:	68 61 67 10 f0       	push   $0xf0106761
f0100270:	e8 b8 36 00 00       	call   f010392d <cprintf>
	lapic_init();
f0100275:	e8 94 5d 00 00       	call   f010600e <lapic_init>
	env_init_percpu();
f010027a:	e8 d3 2f 00 00       	call   f0103252 <env_init_percpu>
	trap_init_percpu();
f010027f:	e8 1b 37 00 00       	call   f010399f <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED);  // tell boot_aps() we're up
f0100284:	e8 6b 5d 00 00       	call   f0105ff4 <cpunum>
f0100289:	6b c0 74             	imul   $0x74,%eax,%eax
f010028c:	05 24 00 25 f0       	add    $0xf0250024,%eax
f0100291:	ba 01 00 00 00       	mov    $0x1,%edx
f0100296:	e8 b2 fd ff ff       	call   f010004d <xchg>
	lock_kernel();
f010029b:	e8 b5 fd ff ff       	call   f0100055 <lock_kernel>
	sched_yield();
f01002a0:	e8 ae 42 00 00       	call   f0104553 <sched_yield>

f01002a5 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt, ...)
{
f01002a5:	f3 0f 1e fb          	endbr32 
f01002a9:	55                   	push   %ebp
f01002aa:	89 e5                	mov    %esp,%ebp
f01002ac:	53                   	push   %ebx
f01002ad:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f01002b0:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f01002b3:	ff 75 0c             	pushl  0xc(%ebp)
f01002b6:	ff 75 08             	pushl  0x8(%ebp)
f01002b9:	68 77 67 10 f0       	push   $0xf0106777
f01002be:	e8 6a 36 00 00       	call   f010392d <cprintf>
	vcprintf(fmt, ap);
f01002c3:	83 c4 08             	add    $0x8,%esp
f01002c6:	53                   	push   %ebx
f01002c7:	ff 75 10             	pushl  0x10(%ebp)
f01002ca:	e8 34 36 00 00       	call   f0103903 <vcprintf>
	cprintf("\n");
f01002cf:	c7 04 24 fe 78 10 f0 	movl   $0xf01078fe,(%esp)
f01002d6:	e8 52 36 00 00       	call   f010392d <cprintf>
	va_end(ap);
}
f01002db:	83 c4 10             	add    $0x10,%esp
f01002de:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01002e1:	c9                   	leave  
f01002e2:	c3                   	ret    

f01002e3 <inb>:
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002e3:	89 c2                	mov    %eax,%edx
f01002e5:	ec                   	in     (%dx),%al
}
f01002e6:	c3                   	ret    

f01002e7 <outb>:
{
f01002e7:	89 c1                	mov    %eax,%ecx
f01002e9:	89 d0                	mov    %edx,%eax
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002eb:	89 ca                	mov    %ecx,%edx
f01002ed:	ee                   	out    %al,(%dx)
}
f01002ee:	c3                   	ret    

f01002ef <delay>:
static void cons_putc(int c);

// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
f01002ef:	55                   	push   %ebp
f01002f0:	89 e5                	mov    %esp,%ebp
f01002f2:	83 ec 08             	sub    $0x8,%esp
	inb(0x84);
f01002f5:	b8 84 00 00 00       	mov    $0x84,%eax
f01002fa:	e8 e4 ff ff ff       	call   f01002e3 <inb>
	inb(0x84);
f01002ff:	b8 84 00 00 00       	mov    $0x84,%eax
f0100304:	e8 da ff ff ff       	call   f01002e3 <inb>
	inb(0x84);
f0100309:	b8 84 00 00 00       	mov    $0x84,%eax
f010030e:	e8 d0 ff ff ff       	call   f01002e3 <inb>
	inb(0x84);
f0100313:	b8 84 00 00 00       	mov    $0x84,%eax
f0100318:	e8 c6 ff ff ff       	call   f01002e3 <inb>
}
f010031d:	c9                   	leave  
f010031e:	c3                   	ret    

f010031f <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f010031f:	f3 0f 1e fb          	endbr32 
f0100323:	55                   	push   %ebp
f0100324:	89 e5                	mov    %esp,%ebp
f0100326:	83 ec 08             	sub    $0x8,%esp
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100329:	b8 fd 03 00 00       	mov    $0x3fd,%eax
f010032e:	e8 b0 ff ff ff       	call   f01002e3 <inb>
f0100333:	a8 01                	test   $0x1,%al
f0100335:	74 0f                	je     f0100346 <serial_proc_data+0x27>
		return -1;
	return inb(COM1+COM_RX);
f0100337:	b8 f8 03 00 00       	mov    $0x3f8,%eax
f010033c:	e8 a2 ff ff ff       	call   f01002e3 <inb>
f0100341:	0f b6 c0             	movzbl %al,%eax
}
f0100344:	c9                   	leave  
f0100345:	c3                   	ret    
		return -1;
f0100346:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010034b:	eb f7                	jmp    f0100344 <serial_proc_data+0x25>

f010034d <serial_putc>:
		cons_intr(serial_proc_data);
}

static void
serial_putc(int c)
{
f010034d:	55                   	push   %ebp
f010034e:	89 e5                	mov    %esp,%ebp
f0100350:	56                   	push   %esi
f0100351:	53                   	push   %ebx
f0100352:	89 c6                	mov    %eax,%esi
	int i;

	for (i = 0;
f0100354:	bb 00 00 00 00       	mov    $0x0,%ebx
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100359:	b8 fd 03 00 00       	mov    $0x3fd,%eax
f010035e:	e8 80 ff ff ff       	call   f01002e3 <inb>
f0100363:	a8 20                	test   $0x20,%al
f0100365:	75 12                	jne    f0100379 <serial_putc+0x2c>
f0100367:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f010036d:	7f 0a                	jg     f0100379 <serial_putc+0x2c>
	     i++)
		delay();
f010036f:	e8 7b ff ff ff       	call   f01002ef <delay>
	     i++)
f0100374:	83 c3 01             	add    $0x1,%ebx
f0100377:	eb e0                	jmp    f0100359 <serial_putc+0xc>

	outb(COM1 + COM_TX, c);
f0100379:	89 f0                	mov    %esi,%eax
f010037b:	0f b6 d0             	movzbl %al,%edx
f010037e:	b8 f8 03 00 00       	mov    $0x3f8,%eax
f0100383:	e8 5f ff ff ff       	call   f01002e7 <outb>
}
f0100388:	5b                   	pop    %ebx
f0100389:	5e                   	pop    %esi
f010038a:	5d                   	pop    %ebp
f010038b:	c3                   	ret    

f010038c <serial_init>:

static void
serial_init(void)
{
f010038c:	55                   	push   %ebp
f010038d:	89 e5                	mov    %esp,%ebp
f010038f:	83 ec 08             	sub    $0x8,%esp
	// Turn off the FIFO
	outb(COM1+COM_FCR, 0);
f0100392:	ba 00 00 00 00       	mov    $0x0,%edx
f0100397:	b8 fa 03 00 00       	mov    $0x3fa,%eax
f010039c:	e8 46 ff ff ff       	call   f01002e7 <outb>

	// Set speed; requires DLAB latch
	outb(COM1+COM_LCR, COM_LCR_DLAB);
f01003a1:	ba 80 00 00 00       	mov    $0x80,%edx
f01003a6:	b8 fb 03 00 00       	mov    $0x3fb,%eax
f01003ab:	e8 37 ff ff ff       	call   f01002e7 <outb>
	outb(COM1+COM_DLL, (uint8_t) (115200 / 9600));
f01003b0:	ba 0c 00 00 00       	mov    $0xc,%edx
f01003b5:	b8 f8 03 00 00       	mov    $0x3f8,%eax
f01003ba:	e8 28 ff ff ff       	call   f01002e7 <outb>
	outb(COM1+COM_DLM, 0);
f01003bf:	ba 00 00 00 00       	mov    $0x0,%edx
f01003c4:	b8 f9 03 00 00       	mov    $0x3f9,%eax
f01003c9:	e8 19 ff ff ff       	call   f01002e7 <outb>

	// 8 data bits, 1 stop bit, parity off; turn off DLAB latch
	outb(COM1+COM_LCR, COM_LCR_WLEN8 & ~COM_LCR_DLAB);
f01003ce:	ba 03 00 00 00       	mov    $0x3,%edx
f01003d3:	b8 fb 03 00 00       	mov    $0x3fb,%eax
f01003d8:	e8 0a ff ff ff       	call   f01002e7 <outb>

	// No modem controls
	outb(COM1+COM_MCR, 0);
f01003dd:	ba 00 00 00 00       	mov    $0x0,%edx
f01003e2:	b8 fc 03 00 00       	mov    $0x3fc,%eax
f01003e7:	e8 fb fe ff ff       	call   f01002e7 <outb>
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);
f01003ec:	ba 01 00 00 00       	mov    $0x1,%edx
f01003f1:	b8 f9 03 00 00       	mov    $0x3f9,%eax
f01003f6:	e8 ec fe ff ff       	call   f01002e7 <outb>

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01003fb:	b8 fd 03 00 00       	mov    $0x3fd,%eax
f0100400:	e8 de fe ff ff       	call   f01002e3 <inb>
f0100405:	3c ff                	cmp    $0xff,%al
f0100407:	0f 95 05 34 e2 24 f0 	setne  0xf024e234
	(void) inb(COM1+COM_IIR);
f010040e:	b8 fa 03 00 00       	mov    $0x3fa,%eax
f0100413:	e8 cb fe ff ff       	call   f01002e3 <inb>
	(void) inb(COM1+COM_RX);
f0100418:	b8 f8 03 00 00       	mov    $0x3f8,%eax
f010041d:	e8 c1 fe ff ff       	call   f01002e3 <inb>

}
f0100422:	c9                   	leave  
f0100423:	c3                   	ret    

f0100424 <lpt_putc>:
// For information on PC parallel port programming, see the class References
// page.

static void
lpt_putc(int c)
{
f0100424:	55                   	push   %ebp
f0100425:	89 e5                	mov    %esp,%ebp
f0100427:	56                   	push   %esi
f0100428:	53                   	push   %ebx
f0100429:	89 c6                	mov    %eax,%esi
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010042b:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100430:	b8 79 03 00 00       	mov    $0x379,%eax
f0100435:	e8 a9 fe ff ff       	call   f01002e3 <inb>
f010043a:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100440:	7f 0e                	jg     f0100450 <lpt_putc+0x2c>
f0100442:	84 c0                	test   %al,%al
f0100444:	78 0a                	js     f0100450 <lpt_putc+0x2c>
		delay();
f0100446:	e8 a4 fe ff ff       	call   f01002ef <delay>
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010044b:	83 c3 01             	add    $0x1,%ebx
f010044e:	eb e0                	jmp    f0100430 <lpt_putc+0xc>
	outb(0x378+0, c);
f0100450:	89 f0                	mov    %esi,%eax
f0100452:	0f b6 d0             	movzbl %al,%edx
f0100455:	b8 78 03 00 00       	mov    $0x378,%eax
f010045a:	e8 88 fe ff ff       	call   f01002e7 <outb>
	outb(0x378+2, 0x08|0x04|0x01);
f010045f:	ba 0d 00 00 00       	mov    $0xd,%edx
f0100464:	b8 7a 03 00 00       	mov    $0x37a,%eax
f0100469:	e8 79 fe ff ff       	call   f01002e7 <outb>
	outb(0x378+2, 0x08);
f010046e:	ba 08 00 00 00       	mov    $0x8,%edx
f0100473:	b8 7a 03 00 00       	mov    $0x37a,%eax
f0100478:	e8 6a fe ff ff       	call   f01002e7 <outb>
}
f010047d:	5b                   	pop    %ebx
f010047e:	5e                   	pop    %esi
f010047f:	5d                   	pop    %ebp
f0100480:	c3                   	ret    

f0100481 <cga_init>:
static uint16_t *crt_buf;
static uint16_t crt_pos;

static void
cga_init(void)
{
f0100481:	55                   	push   %ebp
f0100482:	89 e5                	mov    %esp,%ebp
f0100484:	57                   	push   %edi
f0100485:	56                   	push   %esi
f0100486:	53                   	push   %ebx
f0100487:	83 ec 1c             	sub    $0x1c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f010048a:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100491:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100498:	5a a5 
	if (*cp != 0xA55A) {
f010049a:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f01004a1:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01004a5:	74 63                	je     f010050a <cga_init+0x89>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f01004a7:	c7 05 30 e2 24 f0 b4 	movl   $0x3b4,0xf024e230
f01004ae:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f01004b1:	c7 45 e4 00 00 0b f0 	movl   $0xf00b0000,-0x1c(%ebp)
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f01004b8:	8b 35 30 e2 24 f0    	mov    0xf024e230,%esi
f01004be:	ba 0e 00 00 00       	mov    $0xe,%edx
f01004c3:	89 f0                	mov    %esi,%eax
f01004c5:	e8 1d fe ff ff       	call   f01002e7 <outb>
	pos = inb(addr_6845 + 1) << 8;
f01004ca:	8d 7e 01             	lea    0x1(%esi),%edi
f01004cd:	89 f8                	mov    %edi,%eax
f01004cf:	e8 0f fe ff ff       	call   f01002e3 <inb>
f01004d4:	0f b6 d8             	movzbl %al,%ebx
f01004d7:	c1 e3 08             	shl    $0x8,%ebx
	outb(addr_6845, 15);
f01004da:	ba 0f 00 00 00       	mov    $0xf,%edx
f01004df:	89 f0                	mov    %esi,%eax
f01004e1:	e8 01 fe ff ff       	call   f01002e7 <outb>
	pos |= inb(addr_6845 + 1);
f01004e6:	89 f8                	mov    %edi,%eax
f01004e8:	e8 f6 fd ff ff       	call   f01002e3 <inb>

	crt_buf = (uint16_t*) cp;
f01004ed:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01004f0:	89 0d 2c e2 24 f0    	mov    %ecx,0xf024e22c
	pos |= inb(addr_6845 + 1);
f01004f6:	0f b6 c0             	movzbl %al,%eax
f01004f9:	09 c3                	or     %eax,%ebx
	crt_pos = pos;
f01004fb:	66 89 1d 28 e2 24 f0 	mov    %bx,0xf024e228
}
f0100502:	83 c4 1c             	add    $0x1c,%esp
f0100505:	5b                   	pop    %ebx
f0100506:	5e                   	pop    %esi
f0100507:	5f                   	pop    %edi
f0100508:	5d                   	pop    %ebp
f0100509:	c3                   	ret    
		*cp = was;
f010050a:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100511:	c7 05 30 e2 24 f0 d4 	movl   $0x3d4,0xf024e230
f0100518:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f010051b:	c7 45 e4 00 80 0b f0 	movl   $0xf00b8000,-0x1c(%ebp)
f0100522:	eb 94                	jmp    f01004b8 <cga_init+0x37>

f0100524 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100524:	55                   	push   %ebp
f0100525:	89 e5                	mov    %esp,%ebp
f0100527:	53                   	push   %ebx
f0100528:	83 ec 04             	sub    $0x4,%esp
f010052b:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f010052d:	ff d3                	call   *%ebx
f010052f:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100532:	74 29                	je     f010055d <cons_intr+0x39>
		if (c == 0)
f0100534:	85 c0                	test   %eax,%eax
f0100536:	74 f5                	je     f010052d <cons_intr+0x9>
			continue;
		cons.buf[cons.wpos++] = c;
f0100538:	8b 0d 24 e2 24 f0    	mov    0xf024e224,%ecx
f010053e:	8d 51 01             	lea    0x1(%ecx),%edx
f0100541:	88 81 20 e0 24 f0    	mov    %al,-0xfdb1fe0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f0100547:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.wpos = 0;
f010054d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100552:	0f 44 d0             	cmove  %eax,%edx
f0100555:	89 15 24 e2 24 f0    	mov    %edx,0xf024e224
f010055b:	eb d0                	jmp    f010052d <cons_intr+0x9>
	}
}
f010055d:	83 c4 04             	add    $0x4,%esp
f0100560:	5b                   	pop    %ebx
f0100561:	5d                   	pop    %ebp
f0100562:	c3                   	ret    

f0100563 <kbd_proc_data>:
{
f0100563:	f3 0f 1e fb          	endbr32 
f0100567:	55                   	push   %ebp
f0100568:	89 e5                	mov    %esp,%ebp
f010056a:	53                   	push   %ebx
f010056b:	83 ec 04             	sub    $0x4,%esp
	stat = inb(KBSTATP);
f010056e:	b8 64 00 00 00       	mov    $0x64,%eax
f0100573:	e8 6b fd ff ff       	call   f01002e3 <inb>
	if ((stat & KBS_DIB) == 0)
f0100578:	a8 01                	test   $0x1,%al
f010057a:	0f 84 f7 00 00 00    	je     f0100677 <kbd_proc_data+0x114>
	if (stat & KBS_TERR)
f0100580:	a8 20                	test   $0x20,%al
f0100582:	0f 85 f6 00 00 00    	jne    f010067e <kbd_proc_data+0x11b>
	data = inb(KBDATAP);
f0100588:	b8 60 00 00 00       	mov    $0x60,%eax
f010058d:	e8 51 fd ff ff       	call   f01002e3 <inb>
	if (data == 0xE0) {
f0100592:	3c e0                	cmp    $0xe0,%al
f0100594:	74 61                	je     f01005f7 <kbd_proc_data+0x94>
	} else if (data & 0x80) {
f0100596:	84 c0                	test   %al,%al
f0100598:	78 70                	js     f010060a <kbd_proc_data+0xa7>
	} else if (shift & E0ESC) {
f010059a:	8b 15 00 e0 24 f0    	mov    0xf024e000,%edx
f01005a0:	f6 c2 40             	test   $0x40,%dl
f01005a3:	74 0c                	je     f01005b1 <kbd_proc_data+0x4e>
		data |= 0x80;
f01005a5:	83 c8 80             	or     $0xffffff80,%eax
		shift &= ~E0ESC;
f01005a8:	83 e2 bf             	and    $0xffffffbf,%edx
f01005ab:	89 15 00 e0 24 f0    	mov    %edx,0xf024e000
	shift |= shiftcode[data];
f01005b1:	0f b6 c0             	movzbl %al,%eax
f01005b4:	0f b6 90 e0 68 10 f0 	movzbl -0xfef9720(%eax),%edx
f01005bb:	0b 15 00 e0 24 f0    	or     0xf024e000,%edx
	shift ^= togglecode[data];
f01005c1:	0f b6 88 e0 67 10 f0 	movzbl -0xfef9820(%eax),%ecx
f01005c8:	31 ca                	xor    %ecx,%edx
f01005ca:	89 15 00 e0 24 f0    	mov    %edx,0xf024e000
	c = charcode[shift & (CTL | SHIFT)][data];
f01005d0:	89 d1                	mov    %edx,%ecx
f01005d2:	83 e1 03             	and    $0x3,%ecx
f01005d5:	8b 0c 8d c0 67 10 f0 	mov    -0xfef9840(,%ecx,4),%ecx
f01005dc:	0f b6 04 01          	movzbl (%ecx,%eax,1),%eax
f01005e0:	0f b6 d8             	movzbl %al,%ebx
	if (shift & CAPSLOCK) {
f01005e3:	f6 c2 08             	test   $0x8,%dl
f01005e6:	74 5f                	je     f0100647 <kbd_proc_data+0xe4>
		if ('a' <= c && c <= 'z')
f01005e8:	89 d8                	mov    %ebx,%eax
f01005ea:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f01005ed:	83 f9 19             	cmp    $0x19,%ecx
f01005f0:	77 49                	ja     f010063b <kbd_proc_data+0xd8>
			c += 'A' - 'a';
f01005f2:	83 eb 20             	sub    $0x20,%ebx
f01005f5:	eb 0c                	jmp    f0100603 <kbd_proc_data+0xa0>
		shift |= E0ESC;
f01005f7:	83 0d 00 e0 24 f0 40 	orl    $0x40,0xf024e000
		return 0;
f01005fe:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f0100603:	89 d8                	mov    %ebx,%eax
f0100605:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100608:	c9                   	leave  
f0100609:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f010060a:	8b 15 00 e0 24 f0    	mov    0xf024e000,%edx
f0100610:	89 c1                	mov    %eax,%ecx
f0100612:	83 e1 7f             	and    $0x7f,%ecx
f0100615:	f6 c2 40             	test   $0x40,%dl
f0100618:	0f 44 c1             	cmove  %ecx,%eax
		shift &= ~(shiftcode[data] | E0ESC);
f010061b:	0f b6 c0             	movzbl %al,%eax
f010061e:	0f b6 80 e0 68 10 f0 	movzbl -0xfef9720(%eax),%eax
f0100625:	83 c8 40             	or     $0x40,%eax
f0100628:	0f b6 c0             	movzbl %al,%eax
f010062b:	f7 d0                	not    %eax
f010062d:	21 d0                	and    %edx,%eax
f010062f:	a3 00 e0 24 f0       	mov    %eax,0xf024e000
		return 0;
f0100634:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100639:	eb c8                	jmp    f0100603 <kbd_proc_data+0xa0>
		else if ('A' <= c && c <= 'Z')
f010063b:	83 e8 41             	sub    $0x41,%eax
			c += 'a' - 'A';
f010063e:	8d 4b 20             	lea    0x20(%ebx),%ecx
f0100641:	83 f8 1a             	cmp    $0x1a,%eax
f0100644:	0f 42 d9             	cmovb  %ecx,%ebx
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100647:	f7 d2                	not    %edx
f0100649:	f6 c2 06             	test   $0x6,%dl
f010064c:	75 b5                	jne    f0100603 <kbd_proc_data+0xa0>
f010064e:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100654:	75 ad                	jne    f0100603 <kbd_proc_data+0xa0>
		cprintf("Rebooting!\n");
f0100656:	83 ec 0c             	sub    $0xc,%esp
f0100659:	68 91 67 10 f0       	push   $0xf0106791
f010065e:	e8 ca 32 00 00       	call   f010392d <cprintf>
		outb(0x92, 0x3); // courtesy of Chris Frost
f0100663:	ba 03 00 00 00       	mov    $0x3,%edx
f0100668:	b8 92 00 00 00       	mov    $0x92,%eax
f010066d:	e8 75 fc ff ff       	call   f01002e7 <outb>
f0100672:	83 c4 10             	add    $0x10,%esp
f0100675:	eb 8c                	jmp    f0100603 <kbd_proc_data+0xa0>
		return -1;
f0100677:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f010067c:	eb 85                	jmp    f0100603 <kbd_proc_data+0xa0>
		return -1;
f010067e:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f0100683:	e9 7b ff ff ff       	jmp    f0100603 <kbd_proc_data+0xa0>

f0100688 <cga_putc>:
{
f0100688:	55                   	push   %ebp
f0100689:	89 e5                	mov    %esp,%ebp
f010068b:	57                   	push   %edi
f010068c:	56                   	push   %esi
f010068d:	53                   	push   %ebx
f010068e:	83 ec 0c             	sub    $0xc,%esp
		c |= 0x0700;
f0100691:	89 c2                	mov    %eax,%edx
f0100693:	80 ce 07             	or     $0x7,%dh
f0100696:	a9 00 ff ff ff       	test   $0xffffff00,%eax
f010069b:	0f 44 c2             	cmove  %edx,%eax
	switch (c & 0xff) {
f010069e:	3c 0a                	cmp    $0xa,%al
f01006a0:	0f 84 f0 00 00 00    	je     f0100796 <cga_putc+0x10e>
f01006a6:	0f b6 d0             	movzbl %al,%edx
f01006a9:	83 fa 0a             	cmp    $0xa,%edx
f01006ac:	7f 46                	jg     f01006f4 <cga_putc+0x6c>
f01006ae:	83 fa 08             	cmp    $0x8,%edx
f01006b1:	0f 84 b5 00 00 00    	je     f010076c <cga_putc+0xe4>
f01006b7:	83 fa 09             	cmp    $0x9,%edx
f01006ba:	0f 85 e3 00 00 00    	jne    f01007a3 <cga_putc+0x11b>
		cons_putc(' ');
f01006c0:	b8 20 00 00 00       	mov    $0x20,%eax
f01006c5:	e8 44 01 00 00       	call   f010080e <cons_putc>
		cons_putc(' ');
f01006ca:	b8 20 00 00 00       	mov    $0x20,%eax
f01006cf:	e8 3a 01 00 00       	call   f010080e <cons_putc>
		cons_putc(' ');
f01006d4:	b8 20 00 00 00       	mov    $0x20,%eax
f01006d9:	e8 30 01 00 00       	call   f010080e <cons_putc>
		cons_putc(' ');
f01006de:	b8 20 00 00 00       	mov    $0x20,%eax
f01006e3:	e8 26 01 00 00       	call   f010080e <cons_putc>
		cons_putc(' ');
f01006e8:	b8 20 00 00 00       	mov    $0x20,%eax
f01006ed:	e8 1c 01 00 00       	call   f010080e <cons_putc>
		break;
f01006f2:	eb 25                	jmp    f0100719 <cga_putc+0x91>
	switch (c & 0xff) {
f01006f4:	83 fa 0d             	cmp    $0xd,%edx
f01006f7:	0f 85 a6 00 00 00    	jne    f01007a3 <cga_putc+0x11b>
		crt_pos -= (crt_pos % CRT_COLS);
f01006fd:	0f b7 05 28 e2 24 f0 	movzwl 0xf024e228,%eax
f0100704:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f010070a:	c1 e8 16             	shr    $0x16,%eax
f010070d:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100710:	c1 e0 04             	shl    $0x4,%eax
f0100713:	66 a3 28 e2 24 f0    	mov    %ax,0xf024e228
	if (crt_pos >= CRT_SIZE) {
f0100719:	66 81 3d 28 e2 24 f0 	cmpw   $0x7cf,0xf024e228
f0100720:	cf 07 
f0100722:	0f 87 9e 00 00 00    	ja     f01007c6 <cga_putc+0x13e>
	outb(addr_6845, 14);
f0100728:	8b 3d 30 e2 24 f0    	mov    0xf024e230,%edi
f010072e:	ba 0e 00 00 00       	mov    $0xe,%edx
f0100733:	89 f8                	mov    %edi,%eax
f0100735:	e8 ad fb ff ff       	call   f01002e7 <outb>
	outb(addr_6845 + 1, crt_pos >> 8);
f010073a:	0f b7 1d 28 e2 24 f0 	movzwl 0xf024e228,%ebx
f0100741:	8d 77 01             	lea    0x1(%edi),%esi
f0100744:	0f b6 d7             	movzbl %bh,%edx
f0100747:	89 f0                	mov    %esi,%eax
f0100749:	e8 99 fb ff ff       	call   f01002e7 <outb>
	outb(addr_6845, 15);
f010074e:	ba 0f 00 00 00       	mov    $0xf,%edx
f0100753:	89 f8                	mov    %edi,%eax
f0100755:	e8 8d fb ff ff       	call   f01002e7 <outb>
	outb(addr_6845 + 1, crt_pos);
f010075a:	0f b6 d3             	movzbl %bl,%edx
f010075d:	89 f0                	mov    %esi,%eax
f010075f:	e8 83 fb ff ff       	call   f01002e7 <outb>
}
f0100764:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100767:	5b                   	pop    %ebx
f0100768:	5e                   	pop    %esi
f0100769:	5f                   	pop    %edi
f010076a:	5d                   	pop    %ebp
f010076b:	c3                   	ret    
		if (crt_pos > 0) {
f010076c:	0f b7 15 28 e2 24 f0 	movzwl 0xf024e228,%edx
f0100773:	66 85 d2             	test   %dx,%dx
f0100776:	74 b0                	je     f0100728 <cga_putc+0xa0>
			crt_pos--;
f0100778:	83 ea 01             	sub    $0x1,%edx
f010077b:	66 89 15 28 e2 24 f0 	mov    %dx,0xf024e228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100782:	0f b7 d2             	movzwl %dx,%edx
f0100785:	b0 00                	mov    $0x0,%al
f0100787:	83 c8 20             	or     $0x20,%eax
f010078a:	8b 0d 2c e2 24 f0    	mov    0xf024e22c,%ecx
f0100790:	66 89 04 51          	mov    %ax,(%ecx,%edx,2)
f0100794:	eb 83                	jmp    f0100719 <cga_putc+0x91>
		crt_pos += CRT_COLS;
f0100796:	66 83 05 28 e2 24 f0 	addw   $0x50,0xf024e228
f010079d:	50 
f010079e:	e9 5a ff ff ff       	jmp    f01006fd <cga_putc+0x75>
		crt_buf[crt_pos++] = c;		/* write the character */
f01007a3:	0f b7 15 28 e2 24 f0 	movzwl 0xf024e228,%edx
f01007aa:	8d 4a 01             	lea    0x1(%edx),%ecx
f01007ad:	66 89 0d 28 e2 24 f0 	mov    %cx,0xf024e228
f01007b4:	0f b7 d2             	movzwl %dx,%edx
f01007b7:	8b 0d 2c e2 24 f0    	mov    0xf024e22c,%ecx
f01007bd:	66 89 04 51          	mov    %ax,(%ecx,%edx,2)
		break;
f01007c1:	e9 53 ff ff ff       	jmp    f0100719 <cga_putc+0x91>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01007c6:	a1 2c e2 24 f0       	mov    0xf024e22c,%eax
f01007cb:	83 ec 04             	sub    $0x4,%esp
f01007ce:	68 00 0f 00 00       	push   $0xf00
f01007d3:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01007d9:	52                   	push   %edx
f01007da:	50                   	push   %eax
f01007db:	e8 d3 51 00 00       	call   f01059b3 <memmove>
			crt_buf[i] = 0x0700 | ' ';
f01007e0:	8b 15 2c e2 24 f0    	mov    0xf024e22c,%edx
f01007e6:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f01007ec:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f01007f2:	83 c4 10             	add    $0x10,%esp
f01007f5:	66 c7 00 20 07       	movw   $0x720,(%eax)
f01007fa:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01007fd:	39 d0                	cmp    %edx,%eax
f01007ff:	75 f4                	jne    f01007f5 <cga_putc+0x16d>
		crt_pos -= CRT_COLS;
f0100801:	66 83 2d 28 e2 24 f0 	subw   $0x50,0xf024e228
f0100808:	50 
f0100809:	e9 1a ff ff ff       	jmp    f0100728 <cga_putc+0xa0>

f010080e <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f010080e:	55                   	push   %ebp
f010080f:	89 e5                	mov    %esp,%ebp
f0100811:	53                   	push   %ebx
f0100812:	83 ec 04             	sub    $0x4,%esp
f0100815:	89 c3                	mov    %eax,%ebx
	serial_putc(c);
f0100817:	e8 31 fb ff ff       	call   f010034d <serial_putc>
	lpt_putc(c);
f010081c:	89 d8                	mov    %ebx,%eax
f010081e:	e8 01 fc ff ff       	call   f0100424 <lpt_putc>
	cga_putc(c);
f0100823:	89 d8                	mov    %ebx,%eax
f0100825:	e8 5e fe ff ff       	call   f0100688 <cga_putc>
}
f010082a:	83 c4 04             	add    $0x4,%esp
f010082d:	5b                   	pop    %ebx
f010082e:	5d                   	pop    %ebp
f010082f:	c3                   	ret    

f0100830 <serial_intr>:
{
f0100830:	f3 0f 1e fb          	endbr32 
	if (serial_exists)
f0100834:	80 3d 34 e2 24 f0 00 	cmpb   $0x0,0xf024e234
f010083b:	75 01                	jne    f010083e <serial_intr+0xe>
f010083d:	c3                   	ret    
{
f010083e:	55                   	push   %ebp
f010083f:	89 e5                	mov    %esp,%ebp
f0100841:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f0100844:	b8 1f 03 10 f0       	mov    $0xf010031f,%eax
f0100849:	e8 d6 fc ff ff       	call   f0100524 <cons_intr>
}
f010084e:	c9                   	leave  
f010084f:	c3                   	ret    

f0100850 <kbd_intr>:
{
f0100850:	f3 0f 1e fb          	endbr32 
f0100854:	55                   	push   %ebp
f0100855:	89 e5                	mov    %esp,%ebp
f0100857:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f010085a:	b8 63 05 10 f0       	mov    $0xf0100563,%eax
f010085f:	e8 c0 fc ff ff       	call   f0100524 <cons_intr>
}
f0100864:	c9                   	leave  
f0100865:	c3                   	ret    

f0100866 <kbd_init>:
{
f0100866:	55                   	push   %ebp
f0100867:	89 e5                	mov    %esp,%ebp
f0100869:	83 ec 08             	sub    $0x8,%esp
	kbd_intr();
f010086c:	e8 df ff ff ff       	call   f0100850 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_KBD));
f0100871:	83 ec 0c             	sub    $0xc,%esp
f0100874:	0f b7 05 a8 33 12 f0 	movzwl 0xf01233a8,%eax
f010087b:	25 fd ff 00 00       	and    $0xfffd,%eax
f0100880:	50                   	push   %eax
f0100881:	e8 cc 2e 00 00       	call   f0103752 <irq_setmask_8259A>
}
f0100886:	83 c4 10             	add    $0x10,%esp
f0100889:	c9                   	leave  
f010088a:	c3                   	ret    

f010088b <cons_getc>:
{
f010088b:	f3 0f 1e fb          	endbr32 
f010088f:	55                   	push   %ebp
f0100890:	89 e5                	mov    %esp,%ebp
f0100892:	83 ec 08             	sub    $0x8,%esp
	serial_intr();
f0100895:	e8 96 ff ff ff       	call   f0100830 <serial_intr>
	kbd_intr();
f010089a:	e8 b1 ff ff ff       	call   f0100850 <kbd_intr>
	if (cons.rpos != cons.wpos) {
f010089f:	a1 20 e2 24 f0       	mov    0xf024e220,%eax
	return 0;
f01008a4:	ba 00 00 00 00       	mov    $0x0,%edx
	if (cons.rpos != cons.wpos) {
f01008a9:	3b 05 24 e2 24 f0    	cmp    0xf024e224,%eax
f01008af:	74 1c                	je     f01008cd <cons_getc+0x42>
		c = cons.buf[cons.rpos++];
f01008b1:	8d 48 01             	lea    0x1(%eax),%ecx
f01008b4:	0f b6 90 20 e0 24 f0 	movzbl -0xfdb1fe0(%eax),%edx
			cons.rpos = 0;
f01008bb:	3d ff 01 00 00       	cmp    $0x1ff,%eax
f01008c0:	b8 00 00 00 00       	mov    $0x0,%eax
f01008c5:	0f 45 c1             	cmovne %ecx,%eax
f01008c8:	a3 20 e2 24 f0       	mov    %eax,0xf024e220
}
f01008cd:	89 d0                	mov    %edx,%eax
f01008cf:	c9                   	leave  
f01008d0:	c3                   	ret    

f01008d1 <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f01008d1:	f3 0f 1e fb          	endbr32 
f01008d5:	55                   	push   %ebp
f01008d6:	89 e5                	mov    %esp,%ebp
f01008d8:	83 ec 08             	sub    $0x8,%esp
	cga_init();
f01008db:	e8 a1 fb ff ff       	call   f0100481 <cga_init>
	kbd_init();
f01008e0:	e8 81 ff ff ff       	call   f0100866 <kbd_init>
	serial_init();
f01008e5:	e8 a2 fa ff ff       	call   f010038c <serial_init>

	if (!serial_exists)
f01008ea:	80 3d 34 e2 24 f0 00 	cmpb   $0x0,0xf024e234
f01008f1:	74 02                	je     f01008f5 <cons_init+0x24>
		cprintf("Serial port does not exist!\n");
}
f01008f3:	c9                   	leave  
f01008f4:	c3                   	ret    
		cprintf("Serial port does not exist!\n");
f01008f5:	83 ec 0c             	sub    $0xc,%esp
f01008f8:	68 9d 67 10 f0       	push   $0xf010679d
f01008fd:	e8 2b 30 00 00       	call   f010392d <cprintf>
f0100902:	83 c4 10             	add    $0x10,%esp
}
f0100905:	eb ec                	jmp    f01008f3 <cons_init+0x22>

f0100907 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100907:	f3 0f 1e fb          	endbr32 
f010090b:	55                   	push   %ebp
f010090c:	89 e5                	mov    %esp,%ebp
f010090e:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100911:	8b 45 08             	mov    0x8(%ebp),%eax
f0100914:	e8 f5 fe ff ff       	call   f010080e <cons_putc>
}
f0100919:	c9                   	leave  
f010091a:	c3                   	ret    

f010091b <getchar>:

int
getchar(void)
{
f010091b:	f3 0f 1e fb          	endbr32 
f010091f:	55                   	push   %ebp
f0100920:	89 e5                	mov    %esp,%ebp
f0100922:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100925:	e8 61 ff ff ff       	call   f010088b <cons_getc>
f010092a:	85 c0                	test   %eax,%eax
f010092c:	74 f7                	je     f0100925 <getchar+0xa>
		/* do nothing */;
	return c;
}
f010092e:	c9                   	leave  
f010092f:	c3                   	ret    

f0100930 <iscons>:

int
iscons(int fdnum)
{
f0100930:	f3 0f 1e fb          	endbr32 
	// used by readline
	return 1;
}
f0100934:	b8 01 00 00 00       	mov    $0x1,%eax
f0100939:	c3                   	ret    

f010093a <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f010093a:	f3 0f 1e fb          	endbr32 
f010093e:	55                   	push   %ebp
f010093f:	89 e5                	mov    %esp,%ebp
f0100941:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100944:	68 e0 69 10 f0       	push   $0xf01069e0
f0100949:	68 fe 69 10 f0       	push   $0xf01069fe
f010094e:	68 03 6a 10 f0       	push   $0xf0106a03
f0100953:	e8 d5 2f 00 00       	call   f010392d <cprintf>
f0100958:	83 c4 0c             	add    $0xc,%esp
f010095b:	68 6c 6a 10 f0       	push   $0xf0106a6c
f0100960:	68 0c 6a 10 f0       	push   $0xf0106a0c
f0100965:	68 03 6a 10 f0       	push   $0xf0106a03
f010096a:	e8 be 2f 00 00       	call   f010392d <cprintf>
	return 0;
}
f010096f:	b8 00 00 00 00       	mov    $0x0,%eax
f0100974:	c9                   	leave  
f0100975:	c3                   	ret    

f0100976 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100976:	f3 0f 1e fb          	endbr32 
f010097a:	55                   	push   %ebp
f010097b:	89 e5                	mov    %esp,%ebp
f010097d:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100980:	68 15 6a 10 f0       	push   $0xf0106a15
f0100985:	e8 a3 2f 00 00       	call   f010392d <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f010098a:	83 c4 08             	add    $0x8,%esp
f010098d:	68 0c 00 10 00       	push   $0x10000c
f0100992:	68 94 6a 10 f0       	push   $0xf0106a94
f0100997:	e8 91 2f 00 00       	call   f010392d <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010099c:	83 c4 0c             	add    $0xc,%esp
f010099f:	68 0c 00 10 00       	push   $0x10000c
f01009a4:	68 0c 00 10 f0       	push   $0xf010000c
f01009a9:	68 bc 6a 10 f0       	push   $0xf0106abc
f01009ae:	e8 7a 2f 00 00       	call   f010392d <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01009b3:	83 c4 0c             	add    $0xc,%esp
f01009b6:	68 ad 66 10 00       	push   $0x1066ad
f01009bb:	68 ad 66 10 f0       	push   $0xf01066ad
f01009c0:	68 e0 6a 10 f0       	push   $0xf0106ae0
f01009c5:	e8 63 2f 00 00       	call   f010392d <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01009ca:	83 c4 0c             	add    $0xc,%esp
f01009cd:	68 bc da 24 00       	push   $0x24dabc
f01009d2:	68 bc da 24 f0       	push   $0xf024dabc
f01009d7:	68 04 6b 10 f0       	push   $0xf0106b04
f01009dc:	e8 4c 2f 00 00       	call   f010392d <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01009e1:	83 c4 0c             	add    $0xc,%esp
f01009e4:	68 08 10 29 00       	push   $0x291008
f01009e9:	68 08 10 29 f0       	push   $0xf0291008
f01009ee:	68 28 6b 10 f0       	push   $0xf0106b28
f01009f3:	e8 35 2f 00 00       	call   f010392d <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f01009f8:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f01009fb:	b8 08 10 29 f0       	mov    $0xf0291008,%eax
f0100a00:	2d 0d fc 0f f0       	sub    $0xf00ffc0d,%eax
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100a05:	c1 f8 0a             	sar    $0xa,%eax
f0100a08:	50                   	push   %eax
f0100a09:	68 4c 6b 10 f0       	push   $0xf0106b4c
f0100a0e:	e8 1a 2f 00 00       	call   f010392d <cprintf>
	return 0;
}
f0100a13:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a18:	c9                   	leave  
f0100a19:	c3                   	ret    

f0100a1a <runcmd>:
#define WHITESPACE "\t\r\n "
#define MAXARGS 16

static int
runcmd(char *buf, struct Trapframe *tf)
{
f0100a1a:	55                   	push   %ebp
f0100a1b:	89 e5                	mov    %esp,%ebp
f0100a1d:	57                   	push   %edi
f0100a1e:	56                   	push   %esi
f0100a1f:	53                   	push   %ebx
f0100a20:	83 ec 5c             	sub    $0x5c,%esp
f0100a23:	89 c3                	mov    %eax,%ebx
f0100a25:	89 55 a4             	mov    %edx,-0x5c(%ebp)
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100a28:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f0100a2f:	be 00 00 00 00       	mov    $0x0,%esi
f0100a34:	eb 5d                	jmp    f0100a93 <runcmd+0x79>
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100a36:	83 ec 08             	sub    $0x8,%esp
f0100a39:	0f be c0             	movsbl %al,%eax
f0100a3c:	50                   	push   %eax
f0100a3d:	68 2e 6a 10 f0       	push   $0xf0106a2e
f0100a42:	e8 d9 4e 00 00       	call   f0105920 <strchr>
f0100a47:	83 c4 10             	add    $0x10,%esp
f0100a4a:	85 c0                	test   %eax,%eax
f0100a4c:	74 0a                	je     f0100a58 <runcmd+0x3e>
			*buf++ = 0;
f0100a4e:	c6 03 00             	movb   $0x0,(%ebx)
f0100a51:	89 f7                	mov    %esi,%edi
f0100a53:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100a56:	eb 39                	jmp    f0100a91 <runcmd+0x77>
		if (*buf == 0)
f0100a58:	0f b6 03             	movzbl (%ebx),%eax
f0100a5b:	84 c0                	test   %al,%al
f0100a5d:	74 3b                	je     f0100a9a <runcmd+0x80>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100a5f:	83 fe 0f             	cmp    $0xf,%esi
f0100a62:	0f 84 86 00 00 00    	je     f0100aee <runcmd+0xd4>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
f0100a68:	8d 7e 01             	lea    0x1(%esi),%edi
f0100a6b:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
		while (*buf && !strchr(WHITESPACE, *buf))
f0100a6f:	83 ec 08             	sub    $0x8,%esp
f0100a72:	0f be c0             	movsbl %al,%eax
f0100a75:	50                   	push   %eax
f0100a76:	68 2e 6a 10 f0       	push   $0xf0106a2e
f0100a7b:	e8 a0 4e 00 00       	call   f0105920 <strchr>
f0100a80:	83 c4 10             	add    $0x10,%esp
f0100a83:	85 c0                	test   %eax,%eax
f0100a85:	75 0a                	jne    f0100a91 <runcmd+0x77>
			buf++;
f0100a87:	83 c3 01             	add    $0x1,%ebx
		while (*buf && !strchr(WHITESPACE, *buf))
f0100a8a:	0f b6 03             	movzbl (%ebx),%eax
f0100a8d:	84 c0                	test   %al,%al
f0100a8f:	75 de                	jne    f0100a6f <runcmd+0x55>
			*buf++ = 0;
f0100a91:	89 fe                	mov    %edi,%esi
		while (*buf && strchr(WHITESPACE, *buf))
f0100a93:	0f b6 03             	movzbl (%ebx),%eax
f0100a96:	84 c0                	test   %al,%al
f0100a98:	75 9c                	jne    f0100a36 <runcmd+0x1c>
	}
	argv[argc] = 0;
f0100a9a:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100aa1:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100aa2:	85 f6                	test   %esi,%esi
f0100aa4:	74 5f                	je     f0100b05 <runcmd+0xeb>
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100aa6:	83 ec 08             	sub    $0x8,%esp
f0100aa9:	68 fe 69 10 f0       	push   $0xf01069fe
f0100aae:	ff 75 a8             	pushl  -0x58(%ebp)
f0100ab1:	e8 04 4e 00 00       	call   f01058ba <strcmp>
f0100ab6:	83 c4 10             	add    $0x10,%esp
f0100ab9:	85 c0                	test   %eax,%eax
f0100abb:	74 57                	je     f0100b14 <runcmd+0xfa>
f0100abd:	83 ec 08             	sub    $0x8,%esp
f0100ac0:	68 0c 6a 10 f0       	push   $0xf0106a0c
f0100ac5:	ff 75 a8             	pushl  -0x58(%ebp)
f0100ac8:	e8 ed 4d 00 00       	call   f01058ba <strcmp>
f0100acd:	83 c4 10             	add    $0x10,%esp
f0100ad0:	85 c0                	test   %eax,%eax
f0100ad2:	74 3b                	je     f0100b0f <runcmd+0xf5>
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100ad4:	83 ec 08             	sub    $0x8,%esp
f0100ad7:	ff 75 a8             	pushl  -0x58(%ebp)
f0100ada:	68 50 6a 10 f0       	push   $0xf0106a50
f0100adf:	e8 49 2e 00 00       	call   f010392d <cprintf>
	return 0;
f0100ae4:	83 c4 10             	add    $0x10,%esp
f0100ae7:	be 00 00 00 00       	mov    $0x0,%esi
f0100aec:	eb 17                	jmp    f0100b05 <runcmd+0xeb>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100aee:	83 ec 08             	sub    $0x8,%esp
f0100af1:	6a 10                	push   $0x10
f0100af3:	68 33 6a 10 f0       	push   $0xf0106a33
f0100af8:	e8 30 2e 00 00       	call   f010392d <cprintf>
			return 0;
f0100afd:	83 c4 10             	add    $0x10,%esp
f0100b00:	be 00 00 00 00       	mov    $0x0,%esi
}
f0100b05:	89 f0                	mov    %esi,%eax
f0100b07:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100b0a:	5b                   	pop    %ebx
f0100b0b:	5e                   	pop    %esi
f0100b0c:	5f                   	pop    %edi
f0100b0d:	5d                   	pop    %ebp
f0100b0e:	c3                   	ret    
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100b0f:	b8 01 00 00 00       	mov    $0x1,%eax
			return commands[i].func(argc, argv, tf);
f0100b14:	83 ec 04             	sub    $0x4,%esp
f0100b17:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100b1a:	ff 75 a4             	pushl  -0x5c(%ebp)
f0100b1d:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100b20:	52                   	push   %edx
f0100b21:	56                   	push   %esi
f0100b22:	ff 14 85 cc 6b 10 f0 	call   *-0xfef9434(,%eax,4)
f0100b29:	89 c6                	mov    %eax,%esi
f0100b2b:	83 c4 10             	add    $0x10,%esp
f0100b2e:	eb d5                	jmp    f0100b05 <runcmd+0xeb>

f0100b30 <mon_backtrace>:
{
f0100b30:	f3 0f 1e fb          	endbr32 
}
f0100b34:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b39:	c3                   	ret    

f0100b3a <monitor>:

void
monitor(struct Trapframe *tf)
{
f0100b3a:	f3 0f 1e fb          	endbr32 
f0100b3e:	55                   	push   %ebp
f0100b3f:	89 e5                	mov    %esp,%ebp
f0100b41:	53                   	push   %ebx
f0100b42:	83 ec 10             	sub    $0x10,%esp
f0100b45:	8b 5d 08             	mov    0x8(%ebp),%ebx
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100b48:	68 78 6b 10 f0       	push   $0xf0106b78
f0100b4d:	e8 db 2d 00 00       	call   f010392d <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100b52:	c7 04 24 9c 6b 10 f0 	movl   $0xf0106b9c,(%esp)
f0100b59:	e8 cf 2d 00 00       	call   f010392d <cprintf>

	if (tf != NULL)
f0100b5e:	83 c4 10             	add    $0x10,%esp
f0100b61:	85 db                	test   %ebx,%ebx
f0100b63:	74 0c                	je     f0100b71 <monitor+0x37>
		print_trapframe(tf);
f0100b65:	83 ec 0c             	sub    $0xc,%esp
f0100b68:	53                   	push   %ebx
f0100b69:	e8 1a 33 00 00       	call   f0103e88 <print_trapframe>
f0100b6e:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f0100b71:	83 ec 0c             	sub    $0xc,%esp
f0100b74:	68 66 6a 10 f0       	push   $0xf0106a66
f0100b79:	e8 54 4b 00 00       	call   f01056d2 <readline>
		if (buf != NULL)
f0100b7e:	83 c4 10             	add    $0x10,%esp
f0100b81:	85 c0                	test   %eax,%eax
f0100b83:	74 ec                	je     f0100b71 <monitor+0x37>
			if (runcmd(buf, tf) < 0)
f0100b85:	89 da                	mov    %ebx,%edx
f0100b87:	e8 8e fe ff ff       	call   f0100a1a <runcmd>
f0100b8c:	85 c0                	test   %eax,%eax
f0100b8e:	79 e1                	jns    f0100b71 <monitor+0x37>
				break;
	}
}
f0100b90:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100b93:	c9                   	leave  
f0100b94:	c3                   	ret    

f0100b95 <invlpg>:
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0100b95:	0f 01 38             	invlpg (%eax)
}
f0100b98:	c3                   	ret    

f0100b99 <lcr0>:
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0100b99:	0f 22 c0             	mov    %eax,%cr0
}
f0100b9c:	c3                   	ret    

f0100b9d <rcr0>:
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0100b9d:	0f 20 c0             	mov    %cr0,%eax
}
f0100ba0:	c3                   	ret    

f0100ba1 <lcr3>:
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0100ba1:	0f 22 d8             	mov    %eax,%cr3
}
f0100ba4:	c3                   	ret    

f0100ba5 <page2pa>:
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100ba5:	2b 05 90 fe 24 f0    	sub    0xf024fe90,%eax
f0100bab:	c1 f8 03             	sar    $0x3,%eax
f0100bae:	c1 e0 0c             	shl    $0xc,%eax
}
f0100bb1:	c3                   	ret    

f0100bb2 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100bb2:	55                   	push   %ebp
f0100bb3:	89 e5                	mov    %esp,%ebp
f0100bb5:	56                   	push   %esi
f0100bb6:	53                   	push   %ebx
f0100bb7:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100bb9:	83 ec 0c             	sub    $0xc,%esp
f0100bbc:	50                   	push   %eax
f0100bbd:	e8 39 2b 00 00       	call   f01036fb <mc146818_read>
f0100bc2:	89 c6                	mov    %eax,%esi
f0100bc4:	83 c3 01             	add    $0x1,%ebx
f0100bc7:	89 1c 24             	mov    %ebx,(%esp)
f0100bca:	e8 2c 2b 00 00       	call   f01036fb <mc146818_read>
f0100bcf:	c1 e0 08             	shl    $0x8,%eax
f0100bd2:	09 f0                	or     %esi,%eax
}
f0100bd4:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100bd7:	5b                   	pop    %ebx
f0100bd8:	5e                   	pop    %esi
f0100bd9:	5d                   	pop    %ebp
f0100bda:	c3                   	ret    

f0100bdb <i386_detect_memory>:

static void
i386_detect_memory(void)
{
f0100bdb:	55                   	push   %ebp
f0100bdc:	89 e5                	mov    %esp,%ebp
f0100bde:	56                   	push   %esi
f0100bdf:	53                   	push   %ebx
	size_t basemem, extmem, ext16mem, totalmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	basemem = nvram_read(NVRAM_BASELO);
f0100be0:	b8 15 00 00 00       	mov    $0x15,%eax
f0100be5:	e8 c8 ff ff ff       	call   f0100bb2 <nvram_read>
f0100bea:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f0100bec:	b8 17 00 00 00       	mov    $0x17,%eax
f0100bf1:	e8 bc ff ff ff       	call   f0100bb2 <nvram_read>
f0100bf6:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f0100bf8:	b8 34 00 00 00       	mov    $0x34,%eax
f0100bfd:	e8 b0 ff ff ff       	call   f0100bb2 <nvram_read>

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (ext16mem)
f0100c02:	c1 e0 06             	shl    $0x6,%eax
f0100c05:	74 2b                	je     f0100c32 <i386_detect_memory+0x57>
		totalmem = 16 * 1024 + ext16mem;
f0100c07:	05 00 40 00 00       	add    $0x4000,%eax
	else if (extmem)
		totalmem = 1 * 1024 + extmem;
	else
		totalmem = basemem;

	npages = totalmem / (PGSIZE / 1024);
f0100c0c:	89 c2                	mov    %eax,%edx
f0100c0e:	c1 ea 02             	shr    $0x2,%edx
f0100c11:	89 15 88 fe 24 f0    	mov    %edx,0xf024fe88
	npages_basemem = basemem / (PGSIZE / 1024);

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0100c17:	89 c2                	mov    %eax,%edx
f0100c19:	29 da                	sub    %ebx,%edx
f0100c1b:	52                   	push   %edx
f0100c1c:	53                   	push   %ebx
f0100c1d:	50                   	push   %eax
f0100c1e:	68 dc 6b 10 f0       	push   $0xf0106bdc
f0100c23:	e8 05 2d 00 00       	call   f010392d <cprintf>
	        totalmem,
	        basemem,
	        totalmem - basemem);
}
f0100c28:	83 c4 10             	add    $0x10,%esp
f0100c2b:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100c2e:	5b                   	pop    %ebx
f0100c2f:	5e                   	pop    %esi
f0100c30:	5d                   	pop    %ebp
f0100c31:	c3                   	ret    
		totalmem = 1 * 1024 + extmem;
f0100c32:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f0100c38:	85 f6                	test   %esi,%esi
f0100c3a:	0f 44 c3             	cmove  %ebx,%eax
f0100c3d:	eb cd                	jmp    f0100c0c <i386_detect_memory+0x31>

f0100c3f <_kaddr>:
{
f0100c3f:	55                   	push   %ebp
f0100c40:	89 e5                	mov    %esp,%ebp
f0100c42:	53                   	push   %ebx
f0100c43:	83 ec 04             	sub    $0x4,%esp
	if (PGNUM(pa) >= npages)
f0100c46:	89 cb                	mov    %ecx,%ebx
f0100c48:	c1 eb 0c             	shr    $0xc,%ebx
f0100c4b:	3b 1d 88 fe 24 f0    	cmp    0xf024fe88,%ebx
f0100c51:	73 0b                	jae    f0100c5e <_kaddr+0x1f>
	return (void *)(pa + KERNBASE);
f0100c53:	8d 81 00 00 00 f0    	lea    -0x10000000(%ecx),%eax
}
f0100c59:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100c5c:	c9                   	leave  
f0100c5d:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c5e:	51                   	push   %ecx
f0100c5f:	68 ec 66 10 f0       	push   $0xf01066ec
f0100c64:	52                   	push   %edx
f0100c65:	50                   	push   %eax
f0100c66:	e8 ff f3 ff ff       	call   f010006a <_panic>

f0100c6b <page2kva>:
	return &pages[PGNUM(pa)];
}

static inline void*
page2kva(struct PageInfo *pp)
{
f0100c6b:	55                   	push   %ebp
f0100c6c:	89 e5                	mov    %esp,%ebp
f0100c6e:	83 ec 08             	sub    $0x8,%esp
	return KADDR(page2pa(pp));
f0100c71:	e8 2f ff ff ff       	call   f0100ba5 <page2pa>
f0100c76:	89 c1                	mov    %eax,%ecx
f0100c78:	ba 58 00 00 00       	mov    $0x58,%edx
f0100c7d:	b8 1d 76 10 f0       	mov    $0xf010761d,%eax
f0100c82:	e8 b8 ff ff ff       	call   f0100c3f <_kaddr>
}
f0100c87:	c9                   	leave  
f0100c88:	c3                   	ret    

f0100c89 <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100c89:	55                   	push   %ebp
f0100c8a:	89 e5                	mov    %esp,%ebp
f0100c8c:	53                   	push   %ebx
f0100c8d:	83 ec 04             	sub    $0x4,%esp
f0100c90:	89 d3                	mov    %edx,%ebx
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100c92:	c1 ea 16             	shr    $0x16,%edx
	if (!(*pgdir & PTE_P))
f0100c95:	8b 0c 90             	mov    (%eax,%edx,4),%ecx
		return ~0;
f0100c98:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	if (!(*pgdir & PTE_P))
f0100c9d:	f6 c1 01             	test   $0x1,%cl
f0100ca0:	74 14                	je     f0100cb6 <check_va2pa+0x2d>
	if (*pgdir & PTE_PS)
f0100ca2:	f6 c1 80             	test   $0x80,%cl
f0100ca5:	74 15                	je     f0100cbc <check_va2pa+0x33>
		return (physaddr_t) PGADDR(PDX(*pgdir), PTX(va), PGOFF(va));
f0100ca7:	81 e1 00 00 c0 ff    	and    $0xffc00000,%ecx
f0100cad:	89 d8                	mov    %ebx,%eax
f0100caf:	25 ff ff 3f 00       	and    $0x3fffff,%eax
f0100cb4:	09 c8                	or     %ecx,%eax
	p = (pte_t *) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f0100cb6:	83 c4 04             	add    $0x4,%esp
f0100cb9:	5b                   	pop    %ebx
f0100cba:	5d                   	pop    %ebp
f0100cbb:	c3                   	ret    
	p = (pte_t *) KADDR(PTE_ADDR(*pgdir));
f0100cbc:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0100cc2:	ba d3 03 00 00       	mov    $0x3d3,%edx
f0100cc7:	b8 2b 76 10 f0       	mov    $0xf010762b,%eax
f0100ccc:	e8 6e ff ff ff       	call   f0100c3f <_kaddr>
	if (!(p[PTX(va)] & PTE_P))
f0100cd1:	c1 eb 0c             	shr    $0xc,%ebx
f0100cd4:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0100cda:	8b 14 98             	mov    (%eax,%ebx,4),%edx
	return PTE_ADDR(p[PTX(va)]);
f0100cdd:	89 d0                	mov    %edx,%eax
f0100cdf:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100ce4:	f6 c2 01             	test   $0x1,%dl
f0100ce7:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
f0100cec:	0f 44 c1             	cmove  %ecx,%eax
f0100cef:	eb c5                	jmp    f0100cb6 <check_va2pa+0x2d>

f0100cf1 <boot_alloc>:
{
f0100cf1:	55                   	push   %ebp
f0100cf2:	89 e5                	mov    %esp,%ebp
f0100cf4:	56                   	push   %esi
f0100cf5:	53                   	push   %ebx
f0100cf6:	89 c3                	mov    %eax,%ebx
	if (!nextfree) {
f0100cf8:	83 3d 38 e2 24 f0 00 	cmpl   $0x0,0xf024e238
f0100cff:	74 13                	je     f0100d14 <boot_alloc+0x23>
		return nextfree;
f0100d01:	8b 35 38 e2 24 f0    	mov    0xf024e238,%esi
	if (n == 0) {
f0100d07:	85 db                	test   %ebx,%ebx
f0100d09:	75 1a                	jne    f0100d25 <boot_alloc+0x34>
}
f0100d0b:	89 f0                	mov    %esi,%eax
f0100d0d:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100d10:	5b                   	pop    %ebx
f0100d11:	5e                   	pop    %esi
f0100d12:	5d                   	pop    %ebp
f0100d13:	c3                   	ret    
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100d14:	b8 07 20 29 f0       	mov    $0xf0292007,%eax
f0100d19:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100d1e:	a3 38 e2 24 f0       	mov    %eax,0xf024e238
f0100d23:	eb dc                	jmp    f0100d01 <boot_alloc+0x10>
	result = nextfree;
f0100d25:	8b 35 38 e2 24 f0    	mov    0xf024e238,%esi
	nextfree = ROUNDUP((char *) nextfree + n, PGSIZE);
f0100d2b:	8d 84 1e ff 0f 00 00 	lea    0xfff(%esi,%ebx,1),%eax
f0100d32:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100d37:	a3 38 e2 24 f0       	mov    %eax,0xf024e238
	if (result > (char *) KADDR(npages * PGSIZE - 1)) {
f0100d3c:	8b 0d 88 fe 24 f0    	mov    0xf024fe88,%ecx
f0100d42:	c1 e1 0c             	shl    $0xc,%ecx
f0100d45:	83 e9 01             	sub    $0x1,%ecx
f0100d48:	ba 7a 00 00 00       	mov    $0x7a,%edx
f0100d4d:	b8 2b 76 10 f0       	mov    $0xf010762b,%eax
f0100d52:	e8 e8 fe ff ff       	call   f0100c3f <_kaddr>
f0100d57:	39 c6                	cmp    %eax,%esi
f0100d59:	76 b0                	jbe    f0100d0b <boot_alloc+0x1a>
		panic("boot_alloc: no se pudo reservar los %d bytes debido a "
f0100d5b:	53                   	push   %ebx
f0100d5c:	68 18 6c 10 f0       	push   $0xf0106c18
f0100d61:	6a 7b                	push   $0x7b
f0100d63:	68 2b 76 10 f0       	push   $0xf010762b
f0100d68:	e8 fd f2 ff ff       	call   f010006a <_panic>

f0100d6d <_paddr>:
	if ((uint32_t)kva < KERNBASE)
f0100d6d:	81 f9 ff ff ff ef    	cmp    $0xefffffff,%ecx
f0100d73:	76 07                	jbe    f0100d7c <_paddr+0xf>
	return (physaddr_t)kva - KERNBASE;
f0100d75:	8d 81 00 00 00 10    	lea    0x10000000(%ecx),%eax
}
f0100d7b:	c3                   	ret    
{
f0100d7c:	55                   	push   %ebp
f0100d7d:	89 e5                	mov    %esp,%ebp
f0100d7f:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100d82:	51                   	push   %ecx
f0100d83:	68 10 67 10 f0       	push   $0xf0106710
f0100d88:	52                   	push   %edx
f0100d89:	50                   	push   %eax
f0100d8a:	e8 db f2 ff ff       	call   f010006a <_panic>

f0100d8f <check_page_free_list>:
{
f0100d8f:	55                   	push   %ebp
f0100d90:	89 e5                	mov    %esp,%ebp
f0100d92:	57                   	push   %edi
f0100d93:	56                   	push   %esi
f0100d94:	53                   	push   %ebx
f0100d95:	83 ec 2c             	sub    $0x2c,%esp
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100d98:	84 c0                	test   %al,%al
f0100d9a:	0f 85 3f 02 00 00    	jne    f0100fdf <check_page_free_list+0x250>
	if (!page_free_list)
f0100da0:	83 3d 40 e2 24 f0 00 	cmpl   $0x0,0xf024e240
f0100da7:	74 0a                	je     f0100db3 <check_page_free_list+0x24>
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100da9:	be 00 04 00 00       	mov    $0x400,%esi
f0100dae:	e9 84 02 00 00       	jmp    f0101037 <check_page_free_list+0x2a8>
		panic("'page_free_list' is a null pointer!");
f0100db3:	83 ec 04             	sub    $0x4,%esp
f0100db6:	68 6c 6c 10 f0       	push   $0xf0106c6c
f0100dbb:	68 f1 02 00 00       	push   $0x2f1
f0100dc0:	68 2b 76 10 f0       	push   $0xf010762b
f0100dc5:	e8 a0 f2 ff ff       	call   f010006a <_panic>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100dca:	8b 1b                	mov    (%ebx),%ebx
f0100dcc:	85 db                	test   %ebx,%ebx
f0100dce:	74 2d                	je     f0100dfd <check_page_free_list+0x6e>
		if (PDX(page2pa(pp)) < pdx_limit)
f0100dd0:	89 d8                	mov    %ebx,%eax
f0100dd2:	e8 ce fd ff ff       	call   f0100ba5 <page2pa>
f0100dd7:	c1 e8 16             	shr    $0x16,%eax
f0100dda:	39 f0                	cmp    %esi,%eax
f0100ddc:	73 ec                	jae    f0100dca <check_page_free_list+0x3b>
			memset(page2kva(pp), 0x97, 128);
f0100dde:	89 d8                	mov    %ebx,%eax
f0100de0:	e8 86 fe ff ff       	call   f0100c6b <page2kva>
f0100de5:	83 ec 04             	sub    $0x4,%esp
f0100de8:	68 80 00 00 00       	push   $0x80
f0100ded:	68 97 00 00 00       	push   $0x97
f0100df2:	50                   	push   %eax
f0100df3:	e8 6d 4b 00 00       	call   f0105965 <memset>
f0100df8:	83 c4 10             	add    $0x10,%esp
f0100dfb:	eb cd                	jmp    f0100dca <check_page_free_list+0x3b>
	first_free_page = (char *) boot_alloc(0);
f0100dfd:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e02:	e8 ea fe ff ff       	call   f0100cf1 <boot_alloc>
f0100e07:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100e0a:	8b 1d 40 e2 24 f0    	mov    0xf024e240,%ebx
		assert(pp >= pages);
f0100e10:	8b 35 90 fe 24 f0    	mov    0xf024fe90,%esi
		assert(pp < pages + npages);
f0100e16:	a1 88 fe 24 f0       	mov    0xf024fe88,%eax
f0100e1b:	8d 3c c6             	lea    (%esi,%eax,8),%edi
	int nfree_basemem = 0, nfree_extmem = 0;
f0100e1e:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
f0100e25:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100e2c:	e9 e0 00 00 00       	jmp    f0100f11 <check_page_free_list+0x182>
		assert(pp >= pages);
f0100e31:	68 37 76 10 f0       	push   $0xf0107637
f0100e36:	68 43 76 10 f0       	push   $0xf0107643
f0100e3b:	68 0b 03 00 00       	push   $0x30b
f0100e40:	68 2b 76 10 f0       	push   $0xf010762b
f0100e45:	e8 20 f2 ff ff       	call   f010006a <_panic>
		assert(pp < pages + npages);
f0100e4a:	68 58 76 10 f0       	push   $0xf0107658
f0100e4f:	68 43 76 10 f0       	push   $0xf0107643
f0100e54:	68 0c 03 00 00       	push   $0x30c
f0100e59:	68 2b 76 10 f0       	push   $0xf010762b
f0100e5e:	e8 07 f2 ff ff       	call   f010006a <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100e63:	68 90 6c 10 f0       	push   $0xf0106c90
f0100e68:	68 43 76 10 f0       	push   $0xf0107643
f0100e6d:	68 0d 03 00 00       	push   $0x30d
f0100e72:	68 2b 76 10 f0       	push   $0xf010762b
f0100e77:	e8 ee f1 ff ff       	call   f010006a <_panic>
		assert(page2pa(pp) != 0);
f0100e7c:	68 6c 76 10 f0       	push   $0xf010766c
f0100e81:	68 43 76 10 f0       	push   $0xf0107643
f0100e86:	68 10 03 00 00       	push   $0x310
f0100e8b:	68 2b 76 10 f0       	push   $0xf010762b
f0100e90:	e8 d5 f1 ff ff       	call   f010006a <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100e95:	68 7d 76 10 f0       	push   $0xf010767d
f0100e9a:	68 43 76 10 f0       	push   $0xf0107643
f0100e9f:	68 11 03 00 00       	push   $0x311
f0100ea4:	68 2b 76 10 f0       	push   $0xf010762b
f0100ea9:	e8 bc f1 ff ff       	call   f010006a <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100eae:	68 c4 6c 10 f0       	push   $0xf0106cc4
f0100eb3:	68 43 76 10 f0       	push   $0xf0107643
f0100eb8:	68 12 03 00 00       	push   $0x312
f0100ebd:	68 2b 76 10 f0       	push   $0xf010762b
f0100ec2:	e8 a3 f1 ff ff       	call   f010006a <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100ec7:	68 96 76 10 f0       	push   $0xf0107696
f0100ecc:	68 43 76 10 f0       	push   $0xf0107643
f0100ed1:	68 13 03 00 00       	push   $0x313
f0100ed6:	68 2b 76 10 f0       	push   $0xf010762b
f0100edb:	e8 8a f1 ff ff       	call   f010006a <_panic>
		assert(page2pa(pp) < EXTPHYSMEM ||
f0100ee0:	89 d8                	mov    %ebx,%eax
f0100ee2:	e8 84 fd ff ff       	call   f0100c6b <page2kva>
f0100ee7:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0100eea:	77 06                	ja     f0100ef2 <check_page_free_list+0x163>
			++nfree_extmem;
f0100eec:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
f0100ef0:	eb 1d                	jmp    f0100f0f <check_page_free_list+0x180>
		assert(page2pa(pp) < EXTPHYSMEM ||
f0100ef2:	68 e8 6c 10 f0       	push   $0xf0106ce8
f0100ef7:	68 43 76 10 f0       	push   $0xf0107643
f0100efc:	68 14 03 00 00       	push   $0x314
f0100f01:	68 2b 76 10 f0       	push   $0xf010762b
f0100f06:	e8 5f f1 ff ff       	call   f010006a <_panic>
			++nfree_basemem;
f0100f0b:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100f0f:	8b 1b                	mov    (%ebx),%ebx
f0100f11:	85 db                	test   %ebx,%ebx
f0100f13:	74 77                	je     f0100f8c <check_page_free_list+0x1fd>
		assert(pp >= pages);
f0100f15:	39 de                	cmp    %ebx,%esi
f0100f17:	0f 87 14 ff ff ff    	ja     f0100e31 <check_page_free_list+0xa2>
		assert(pp < pages + npages);
f0100f1d:	39 df                	cmp    %ebx,%edi
f0100f1f:	0f 86 25 ff ff ff    	jbe    f0100e4a <check_page_free_list+0xbb>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100f25:	89 d8                	mov    %ebx,%eax
f0100f27:	29 f0                	sub    %esi,%eax
f0100f29:	a8 07                	test   $0x7,%al
f0100f2b:	0f 85 32 ff ff ff    	jne    f0100e63 <check_page_free_list+0xd4>
		assert(page2pa(pp) != 0);
f0100f31:	89 d8                	mov    %ebx,%eax
f0100f33:	e8 6d fc ff ff       	call   f0100ba5 <page2pa>
f0100f38:	85 c0                	test   %eax,%eax
f0100f3a:	0f 84 3c ff ff ff    	je     f0100e7c <check_page_free_list+0xed>
		assert(page2pa(pp) != IOPHYSMEM);
f0100f40:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100f45:	0f 84 4a ff ff ff    	je     f0100e95 <check_page_free_list+0x106>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100f4b:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100f50:	0f 84 58 ff ff ff    	je     f0100eae <check_page_free_list+0x11f>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100f56:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100f5b:	0f 84 66 ff ff ff    	je     f0100ec7 <check_page_free_list+0x138>
		assert(page2pa(pp) < EXTPHYSMEM ||
f0100f61:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100f66:	0f 87 74 ff ff ff    	ja     f0100ee0 <check_page_free_list+0x151>
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100f6c:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100f71:	75 98                	jne    f0100f0b <check_page_free_list+0x17c>
f0100f73:	68 b0 76 10 f0       	push   $0xf01076b0
f0100f78:	68 43 76 10 f0       	push   $0xf0107643
f0100f7d:	68 17 03 00 00       	push   $0x317
f0100f82:	68 2b 76 10 f0       	push   $0xf010762b
f0100f87:	e8 de f0 ff ff       	call   f010006a <_panic>
	assert(nfree_basemem > 0);
f0100f8c:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0100f90:	7e 1b                	jle    f0100fad <check_page_free_list+0x21e>
	assert(nfree_extmem > 0);
f0100f92:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f0100f96:	7e 2e                	jle    f0100fc6 <check_page_free_list+0x237>
	cprintf("check_page_free_list() succeeded!\n");
f0100f98:	83 ec 0c             	sub    $0xc,%esp
f0100f9b:	68 30 6d 10 f0       	push   $0xf0106d30
f0100fa0:	e8 88 29 00 00       	call   f010392d <cprintf>
}
f0100fa5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100fa8:	5b                   	pop    %ebx
f0100fa9:	5e                   	pop    %esi
f0100faa:	5f                   	pop    %edi
f0100fab:	5d                   	pop    %ebp
f0100fac:	c3                   	ret    
	assert(nfree_basemem > 0);
f0100fad:	68 cd 76 10 f0       	push   $0xf01076cd
f0100fb2:	68 43 76 10 f0       	push   $0xf0107643
f0100fb7:	68 1f 03 00 00       	push   $0x31f
f0100fbc:	68 2b 76 10 f0       	push   $0xf010762b
f0100fc1:	e8 a4 f0 ff ff       	call   f010006a <_panic>
	assert(nfree_extmem > 0);
f0100fc6:	68 df 76 10 f0       	push   $0xf01076df
f0100fcb:	68 43 76 10 f0       	push   $0xf0107643
f0100fd0:	68 20 03 00 00       	push   $0x320
f0100fd5:	68 2b 76 10 f0       	push   $0xf010762b
f0100fda:	e8 8b f0 ff ff       	call   f010006a <_panic>
	if (!page_free_list)
f0100fdf:	8b 1d 40 e2 24 f0    	mov    0xf024e240,%ebx
f0100fe5:	85 db                	test   %ebx,%ebx
f0100fe7:	0f 84 c6 fd ff ff    	je     f0100db3 <check_page_free_list+0x24>
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100fed:	8d 45 d8             	lea    -0x28(%ebp),%eax
f0100ff0:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100ff3:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0100ff6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100ff9:	89 d8                	mov    %ebx,%eax
f0100ffb:	e8 a5 fb ff ff       	call   f0100ba5 <page2pa>
f0101000:	c1 e8 16             	shr    $0x16,%eax
f0101003:	0f 95 c0             	setne  %al
f0101006:	0f b6 c0             	movzbl %al,%eax
			*tp[pagetype] = pp;
f0101009:	8b 54 85 e0          	mov    -0x20(%ebp,%eax,4),%edx
f010100d:	89 1a                	mov    %ebx,(%edx)
			tp[pagetype] = &pp->pp_link;
f010100f:	89 5c 85 e0          	mov    %ebx,-0x20(%ebp,%eax,4)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101013:	8b 1b                	mov    (%ebx),%ebx
f0101015:	85 db                	test   %ebx,%ebx
f0101017:	75 e0                	jne    f0100ff9 <check_page_free_list+0x26a>
		*tp[1] = 0;
f0101019:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010101c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0101022:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0101025:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101028:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f010102a:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010102d:	a3 40 e2 24 f0       	mov    %eax,0xf024e240
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0101032:	be 01 00 00 00       	mov    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101037:	8b 1d 40 e2 24 f0    	mov    0xf024e240,%ebx
f010103d:	e9 8a fd ff ff       	jmp    f0100dcc <check_page_free_list+0x3d>

f0101042 <pa2page>:
	if (PGNUM(pa) >= npages)
f0101042:	c1 e8 0c             	shr    $0xc,%eax
f0101045:	3b 05 88 fe 24 f0    	cmp    0xf024fe88,%eax
f010104b:	73 0a                	jae    f0101057 <pa2page+0x15>
	return &pages[PGNUM(pa)];
f010104d:	8b 15 90 fe 24 f0    	mov    0xf024fe90,%edx
f0101053:	8d 04 c2             	lea    (%edx,%eax,8),%eax
}
f0101056:	c3                   	ret    
{
f0101057:	55                   	push   %ebp
f0101058:	89 e5                	mov    %esp,%ebp
f010105a:	83 ec 0c             	sub    $0xc,%esp
		panic("pa2page called with invalid pa");
f010105d:	68 54 6d 10 f0       	push   $0xf0106d54
f0101062:	6a 51                	push   $0x51
f0101064:	68 1d 76 10 f0       	push   $0xf010761d
f0101069:	e8 fc ef ff ff       	call   f010006a <_panic>

f010106e <page_init>:
{
f010106e:	f3 0f 1e fb          	endbr32 
f0101072:	55                   	push   %ebp
f0101073:	89 e5                	mov    %esp,%ebp
f0101075:	57                   	push   %edi
f0101076:	56                   	push   %esi
f0101077:	53                   	push   %ebx
f0101078:	83 ec 1c             	sub    $0x1c,%esp
	physaddr_t pagesEnd = PADDR(boot_alloc(0));
f010107b:	b8 00 00 00 00       	mov    $0x0,%eax
f0101080:	e8 6c fc ff ff       	call   f0100cf1 <boot_alloc>
f0101085:	89 c1                	mov    %eax,%ecx
f0101087:	ba 56 01 00 00       	mov    $0x156,%edx
f010108c:	b8 2b 76 10 f0       	mov    $0xf010762b,%eax
f0101091:	e8 d7 fc ff ff       	call   f0100d6d <_paddr>
f0101096:	89 45 e0             	mov    %eax,-0x20(%ebp)
	for (i = 0; i < npages; i++) {
f0101099:	bb 00 00 00 00       	mov    $0x0,%ebx
f010109e:	eb 03                	jmp    f01010a3 <page_init+0x35>
f01010a0:	83 c3 01             	add    $0x1,%ebx
f01010a3:	8b 35 88 fe 24 f0    	mov    0xf024fe88,%esi
f01010a9:	39 de                	cmp    %ebx,%esi
f01010ab:	76 5b                	jbe    f0101108 <page_init+0x9a>
		if (i != 0 && (physaddres < IOPHYSMEM || physaddres > pagesEnd) &&
f01010ad:	85 db                	test   %ebx,%ebx
f01010af:	74 ef                	je     f01010a0 <page_init+0x32>
f01010b1:	8d 3c dd 00 00 00 00 	lea    0x0(,%ebx,8),%edi
		physaddr_t physaddres = page2pa(&pages[i]);
f01010b8:	89 f8                	mov    %edi,%eax
f01010ba:	03 05 90 fe 24 f0    	add    0xf024fe90,%eax
f01010c0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01010c3:	e8 dd fa ff ff       	call   f0100ba5 <page2pa>
		if (i != 0 && (physaddres < IOPHYSMEM || physaddres > pagesEnd) &&
f01010c8:	3d ff ff 09 00       	cmp    $0x9ffff,%eax
f01010cd:	76 05                	jbe    f01010d4 <page_init+0x66>
f01010cf:	39 45 e0             	cmp    %eax,-0x20(%ebp)
f01010d2:	73 cc                	jae    f01010a0 <page_init+0x32>
		    (physaddres < npages * PGSIZE - 1) &&
f01010d4:	c1 e6 0c             	shl    $0xc,%esi
f01010d7:	83 ee 01             	sub    $0x1,%esi
		if (i != 0 && (physaddres < IOPHYSMEM || physaddres > pagesEnd) &&
f01010da:	39 c6                	cmp    %eax,%esi
f01010dc:	76 c2                	jbe    f01010a0 <page_init+0x32>
		    (physaddres < npages * PGSIZE - 1) &&
f01010de:	89 d8                	mov    %ebx,%eax
f01010e0:	c1 e0 0c             	shl    $0xc,%eax
f01010e3:	3d 00 70 00 00       	cmp    $0x7000,%eax
f01010e8:	74 b6                	je     f01010a0 <page_init+0x32>
			pages[i].pp_ref = 0;
f01010ea:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01010ed:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
			pages[i].pp_link = page_free_list;
f01010f3:	a1 40 e2 24 f0       	mov    0xf024e240,%eax
f01010f8:	89 01                	mov    %eax,(%ecx)
			page_free_list = &pages[i];
f01010fa:	03 3d 90 fe 24 f0    	add    0xf024fe90,%edi
f0101100:	89 3d 40 e2 24 f0    	mov    %edi,0xf024e240
f0101106:	eb 98                	jmp    f01010a0 <page_init+0x32>
}
f0101108:	83 c4 1c             	add    $0x1c,%esp
f010110b:	5b                   	pop    %ebx
f010110c:	5e                   	pop    %esi
f010110d:	5f                   	pop    %edi
f010110e:	5d                   	pop    %ebp
f010110f:	c3                   	ret    

f0101110 <page_alloc>:
{
f0101110:	f3 0f 1e fb          	endbr32 
f0101114:	55                   	push   %ebp
f0101115:	89 e5                	mov    %esp,%ebp
f0101117:	53                   	push   %ebx
f0101118:	83 ec 04             	sub    $0x4,%esp
	if (!page_free_list) {
f010111b:	8b 1d 40 e2 24 f0    	mov    0xf024e240,%ebx
f0101121:	85 db                	test   %ebx,%ebx
f0101123:	74 13                	je     f0101138 <page_alloc+0x28>
	page_free_list = page_free_list->pp_link;          // avanzo la original
f0101125:	8b 03                	mov    (%ebx),%eax
f0101127:	a3 40 e2 24 f0       	mov    %eax,0xf024e240
	allocated_page->pp_link =
f010112c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (alloc_flags & ALLOC_ZERO) {
f0101132:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0101136:	75 07                	jne    f010113f <page_alloc+0x2f>
}
f0101138:	89 d8                	mov    %ebx,%eax
f010113a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010113d:	c9                   	leave  
f010113e:	c3                   	ret    
		memset(page2kva(allocated_page), '\0', PGSIZE);
f010113f:	89 d8                	mov    %ebx,%eax
f0101141:	e8 25 fb ff ff       	call   f0100c6b <page2kva>
f0101146:	83 ec 04             	sub    $0x4,%esp
f0101149:	68 00 10 00 00       	push   $0x1000
f010114e:	6a 00                	push   $0x0
f0101150:	50                   	push   %eax
f0101151:	e8 0f 48 00 00       	call   f0105965 <memset>
f0101156:	83 c4 10             	add    $0x10,%esp
f0101159:	eb dd                	jmp    f0101138 <page_alloc+0x28>

f010115b <page_free>:
{
f010115b:	f3 0f 1e fb          	endbr32 
f010115f:	55                   	push   %ebp
f0101160:	89 e5                	mov    %esp,%ebp
f0101162:	83 ec 08             	sub    $0x8,%esp
f0101165:	8b 45 08             	mov    0x8(%ebp),%eax
	if (pp->pp_ref || pp->pp_link) {
f0101168:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f010116d:	75 14                	jne    f0101183 <page_free+0x28>
f010116f:	83 38 00             	cmpl   $0x0,(%eax)
f0101172:	75 0f                	jne    f0101183 <page_free+0x28>
	pp->pp_link = page_free_list;
f0101174:	8b 15 40 e2 24 f0    	mov    0xf024e240,%edx
f010117a:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f010117c:	a3 40 e2 24 f0       	mov    %eax,0xf024e240
}
f0101181:	c9                   	leave  
f0101182:	c3                   	ret    
		panic("page_free: pp->pp_ref is nonzero or pp->pp_link is not "
f0101183:	83 ec 04             	sub    $0x4,%esp
f0101186:	68 74 6d 10 f0       	push   $0xf0106d74
f010118b:	68 8e 01 00 00       	push   $0x18e
f0101190:	68 2b 76 10 f0       	push   $0xf010762b
f0101195:	e8 d0 ee ff ff       	call   f010006a <_panic>

f010119a <check_page_alloc>:
{
f010119a:	55                   	push   %ebp
f010119b:	89 e5                	mov    %esp,%ebp
f010119d:	57                   	push   %edi
f010119e:	56                   	push   %esi
f010119f:	53                   	push   %ebx
f01011a0:	83 ec 1c             	sub    $0x1c,%esp
	if (!pages)
f01011a3:	83 3d 90 fe 24 f0 00 	cmpl   $0x0,0xf024fe90
f01011aa:	74 0c                	je     f01011b8 <check_page_alloc+0x1e>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01011ac:	a1 40 e2 24 f0       	mov    0xf024e240,%eax
f01011b1:	be 00 00 00 00       	mov    $0x0,%esi
f01011b6:	eb 1c                	jmp    f01011d4 <check_page_alloc+0x3a>
		panic("'pages' is a null pointer!");
f01011b8:	83 ec 04             	sub    $0x4,%esp
f01011bb:	68 f0 76 10 f0       	push   $0xf01076f0
f01011c0:	68 33 03 00 00       	push   $0x333
f01011c5:	68 2b 76 10 f0       	push   $0xf010762b
f01011ca:	e8 9b ee ff ff       	call   f010006a <_panic>
		++nfree;
f01011cf:	83 c6 01             	add    $0x1,%esi
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01011d2:	8b 00                	mov    (%eax),%eax
f01011d4:	85 c0                	test   %eax,%eax
f01011d6:	75 f7                	jne    f01011cf <check_page_alloc+0x35>
	assert((pp0 = page_alloc(0)));
f01011d8:	83 ec 0c             	sub    $0xc,%esp
f01011db:	6a 00                	push   $0x0
f01011dd:	e8 2e ff ff ff       	call   f0101110 <page_alloc>
f01011e2:	89 c7                	mov    %eax,%edi
f01011e4:	83 c4 10             	add    $0x10,%esp
f01011e7:	85 c0                	test   %eax,%eax
f01011e9:	0f 84 d3 01 00 00    	je     f01013c2 <check_page_alloc+0x228>
	assert((pp1 = page_alloc(0)));
f01011ef:	83 ec 0c             	sub    $0xc,%esp
f01011f2:	6a 00                	push   $0x0
f01011f4:	e8 17 ff ff ff       	call   f0101110 <page_alloc>
f01011f9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01011fc:	83 c4 10             	add    $0x10,%esp
f01011ff:	85 c0                	test   %eax,%eax
f0101201:	0f 84 d4 01 00 00    	je     f01013db <check_page_alloc+0x241>
	assert((pp2 = page_alloc(0)));
f0101207:	83 ec 0c             	sub    $0xc,%esp
f010120a:	6a 00                	push   $0x0
f010120c:	e8 ff fe ff ff       	call   f0101110 <page_alloc>
f0101211:	89 c3                	mov    %eax,%ebx
f0101213:	83 c4 10             	add    $0x10,%esp
f0101216:	85 c0                	test   %eax,%eax
f0101218:	0f 84 d6 01 00 00    	je     f01013f4 <check_page_alloc+0x25a>
	assert(pp1 && pp1 != pp0);
f010121e:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
f0101221:	0f 84 e6 01 00 00    	je     f010140d <check_page_alloc+0x273>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101227:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
f010122a:	0f 84 f6 01 00 00    	je     f0101426 <check_page_alloc+0x28c>
f0101230:	39 c7                	cmp    %eax,%edi
f0101232:	0f 84 ee 01 00 00    	je     f0101426 <check_page_alloc+0x28c>
	assert(page2pa(pp0) < npages * PGSIZE);
f0101238:	89 f8                	mov    %edi,%eax
f010123a:	e8 66 f9 ff ff       	call   f0100ba5 <page2pa>
f010123f:	8b 0d 88 fe 24 f0    	mov    0xf024fe88,%ecx
f0101245:	c1 e1 0c             	shl    $0xc,%ecx
f0101248:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f010124b:	39 c8                	cmp    %ecx,%eax
f010124d:	0f 83 ec 01 00 00    	jae    f010143f <check_page_alloc+0x2a5>
	assert(page2pa(pp1) < npages * PGSIZE);
f0101253:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101256:	e8 4a f9 ff ff       	call   f0100ba5 <page2pa>
f010125b:	39 45 e0             	cmp    %eax,-0x20(%ebp)
f010125e:	0f 86 f4 01 00 00    	jbe    f0101458 <check_page_alloc+0x2be>
	assert(page2pa(pp2) < npages * PGSIZE);
f0101264:	89 d8                	mov    %ebx,%eax
f0101266:	e8 3a f9 ff ff       	call   f0100ba5 <page2pa>
f010126b:	39 45 e0             	cmp    %eax,-0x20(%ebp)
f010126e:	0f 86 fd 01 00 00    	jbe    f0101471 <check_page_alloc+0x2d7>
	fl = page_free_list;
f0101274:	a1 40 e2 24 f0       	mov    0xf024e240,%eax
f0101279:	89 45 e0             	mov    %eax,-0x20(%ebp)
	page_free_list = 0;
f010127c:	c7 05 40 e2 24 f0 00 	movl   $0x0,0xf024e240
f0101283:	00 00 00 
	assert(!page_alloc(0));
f0101286:	83 ec 0c             	sub    $0xc,%esp
f0101289:	6a 00                	push   $0x0
f010128b:	e8 80 fe ff ff       	call   f0101110 <page_alloc>
f0101290:	83 c4 10             	add    $0x10,%esp
f0101293:	85 c0                	test   %eax,%eax
f0101295:	0f 85 ef 01 00 00    	jne    f010148a <check_page_alloc+0x2f0>
	page_free(pp0);
f010129b:	83 ec 0c             	sub    $0xc,%esp
f010129e:	57                   	push   %edi
f010129f:	e8 b7 fe ff ff       	call   f010115b <page_free>
	page_free(pp1);
f01012a4:	83 c4 04             	add    $0x4,%esp
f01012a7:	ff 75 e4             	pushl  -0x1c(%ebp)
f01012aa:	e8 ac fe ff ff       	call   f010115b <page_free>
	page_free(pp2);
f01012af:	89 1c 24             	mov    %ebx,(%esp)
f01012b2:	e8 a4 fe ff ff       	call   f010115b <page_free>
	assert((pp0 = page_alloc(0)));
f01012b7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01012be:	e8 4d fe ff ff       	call   f0101110 <page_alloc>
f01012c3:	89 c3                	mov    %eax,%ebx
f01012c5:	83 c4 10             	add    $0x10,%esp
f01012c8:	85 c0                	test   %eax,%eax
f01012ca:	0f 84 d3 01 00 00    	je     f01014a3 <check_page_alloc+0x309>
	assert((pp1 = page_alloc(0)));
f01012d0:	83 ec 0c             	sub    $0xc,%esp
f01012d3:	6a 00                	push   $0x0
f01012d5:	e8 36 fe ff ff       	call   f0101110 <page_alloc>
f01012da:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01012dd:	83 c4 10             	add    $0x10,%esp
f01012e0:	85 c0                	test   %eax,%eax
f01012e2:	0f 84 d4 01 00 00    	je     f01014bc <check_page_alloc+0x322>
	assert((pp2 = page_alloc(0)));
f01012e8:	83 ec 0c             	sub    $0xc,%esp
f01012eb:	6a 00                	push   $0x0
f01012ed:	e8 1e fe ff ff       	call   f0101110 <page_alloc>
f01012f2:	89 c7                	mov    %eax,%edi
f01012f4:	83 c4 10             	add    $0x10,%esp
f01012f7:	85 c0                	test   %eax,%eax
f01012f9:	0f 84 d6 01 00 00    	je     f01014d5 <check_page_alloc+0x33b>
	assert(pp1 && pp1 != pp0);
f01012ff:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0101302:	0f 84 e6 01 00 00    	je     f01014ee <check_page_alloc+0x354>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101308:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
f010130b:	0f 84 f6 01 00 00    	je     f0101507 <check_page_alloc+0x36d>
f0101311:	39 c3                	cmp    %eax,%ebx
f0101313:	0f 84 ee 01 00 00    	je     f0101507 <check_page_alloc+0x36d>
	assert(!page_alloc(0));
f0101319:	83 ec 0c             	sub    $0xc,%esp
f010131c:	6a 00                	push   $0x0
f010131e:	e8 ed fd ff ff       	call   f0101110 <page_alloc>
f0101323:	83 c4 10             	add    $0x10,%esp
f0101326:	85 c0                	test   %eax,%eax
f0101328:	0f 85 f2 01 00 00    	jne    f0101520 <check_page_alloc+0x386>
	memset(page2kva(pp0), 1, PGSIZE);
f010132e:	89 d8                	mov    %ebx,%eax
f0101330:	e8 36 f9 ff ff       	call   f0100c6b <page2kva>
f0101335:	83 ec 04             	sub    $0x4,%esp
f0101338:	68 00 10 00 00       	push   $0x1000
f010133d:	6a 01                	push   $0x1
f010133f:	50                   	push   %eax
f0101340:	e8 20 46 00 00       	call   f0105965 <memset>
	page_free(pp0);
f0101345:	89 1c 24             	mov    %ebx,(%esp)
f0101348:	e8 0e fe ff ff       	call   f010115b <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f010134d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101354:	e8 b7 fd ff ff       	call   f0101110 <page_alloc>
f0101359:	83 c4 10             	add    $0x10,%esp
f010135c:	85 c0                	test   %eax,%eax
f010135e:	0f 84 d5 01 00 00    	je     f0101539 <check_page_alloc+0x39f>
	assert(pp && pp0 == pp);
f0101364:	39 c3                	cmp    %eax,%ebx
f0101366:	0f 85 e6 01 00 00    	jne    f0101552 <check_page_alloc+0x3b8>
	c = page2kva(pp);
f010136c:	e8 fa f8 ff ff       	call   f0100c6b <page2kva>
f0101371:	8d 90 00 10 00 00    	lea    0x1000(%eax),%edx
		assert(c[i] == 0);
f0101377:	80 38 00             	cmpb   $0x0,(%eax)
f010137a:	0f 85 eb 01 00 00    	jne    f010156b <check_page_alloc+0x3d1>
f0101380:	83 c0 01             	add    $0x1,%eax
	for (i = 0; i < PGSIZE; i++)
f0101383:	39 d0                	cmp    %edx,%eax
f0101385:	75 f0                	jne    f0101377 <check_page_alloc+0x1dd>
	page_free_list = fl;
f0101387:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010138a:	a3 40 e2 24 f0       	mov    %eax,0xf024e240
	page_free(pp0);
f010138f:	83 ec 0c             	sub    $0xc,%esp
f0101392:	53                   	push   %ebx
f0101393:	e8 c3 fd ff ff       	call   f010115b <page_free>
	page_free(pp1);
f0101398:	83 c4 04             	add    $0x4,%esp
f010139b:	ff 75 e4             	pushl  -0x1c(%ebp)
f010139e:	e8 b8 fd ff ff       	call   f010115b <page_free>
	page_free(pp2);
f01013a3:	89 3c 24             	mov    %edi,(%esp)
f01013a6:	e8 b0 fd ff ff       	call   f010115b <page_free>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01013ab:	a1 40 e2 24 f0       	mov    0xf024e240,%eax
f01013b0:	83 c4 10             	add    $0x10,%esp
f01013b3:	85 c0                	test   %eax,%eax
f01013b5:	0f 84 c9 01 00 00    	je     f0101584 <check_page_alloc+0x3ea>
		--nfree;
f01013bb:	83 ee 01             	sub    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01013be:	8b 00                	mov    (%eax),%eax
f01013c0:	eb f1                	jmp    f01013b3 <check_page_alloc+0x219>
	assert((pp0 = page_alloc(0)));
f01013c2:	68 0b 77 10 f0       	push   $0xf010770b
f01013c7:	68 43 76 10 f0       	push   $0xf0107643
f01013cc:	68 3b 03 00 00       	push   $0x33b
f01013d1:	68 2b 76 10 f0       	push   $0xf010762b
f01013d6:	e8 8f ec ff ff       	call   f010006a <_panic>
	assert((pp1 = page_alloc(0)));
f01013db:	68 21 77 10 f0       	push   $0xf0107721
f01013e0:	68 43 76 10 f0       	push   $0xf0107643
f01013e5:	68 3c 03 00 00       	push   $0x33c
f01013ea:	68 2b 76 10 f0       	push   $0xf010762b
f01013ef:	e8 76 ec ff ff       	call   f010006a <_panic>
	assert((pp2 = page_alloc(0)));
f01013f4:	68 37 77 10 f0       	push   $0xf0107737
f01013f9:	68 43 76 10 f0       	push   $0xf0107643
f01013fe:	68 3d 03 00 00       	push   $0x33d
f0101403:	68 2b 76 10 f0       	push   $0xf010762b
f0101408:	e8 5d ec ff ff       	call   f010006a <_panic>
	assert(pp1 && pp1 != pp0);
f010140d:	68 4d 77 10 f0       	push   $0xf010774d
f0101412:	68 43 76 10 f0       	push   $0xf0107643
f0101417:	68 40 03 00 00       	push   $0x340
f010141c:	68 2b 76 10 f0       	push   $0xf010762b
f0101421:	e8 44 ec ff ff       	call   f010006a <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101426:	68 b0 6d 10 f0       	push   $0xf0106db0
f010142b:	68 43 76 10 f0       	push   $0xf0107643
f0101430:	68 41 03 00 00       	push   $0x341
f0101435:	68 2b 76 10 f0       	push   $0xf010762b
f010143a:	e8 2b ec ff ff       	call   f010006a <_panic>
	assert(page2pa(pp0) < npages * PGSIZE);
f010143f:	68 d0 6d 10 f0       	push   $0xf0106dd0
f0101444:	68 43 76 10 f0       	push   $0xf0107643
f0101449:	68 42 03 00 00       	push   $0x342
f010144e:	68 2b 76 10 f0       	push   $0xf010762b
f0101453:	e8 12 ec ff ff       	call   f010006a <_panic>
	assert(page2pa(pp1) < npages * PGSIZE);
f0101458:	68 f0 6d 10 f0       	push   $0xf0106df0
f010145d:	68 43 76 10 f0       	push   $0xf0107643
f0101462:	68 43 03 00 00       	push   $0x343
f0101467:	68 2b 76 10 f0       	push   $0xf010762b
f010146c:	e8 f9 eb ff ff       	call   f010006a <_panic>
	assert(page2pa(pp2) < npages * PGSIZE);
f0101471:	68 10 6e 10 f0       	push   $0xf0106e10
f0101476:	68 43 76 10 f0       	push   $0xf0107643
f010147b:	68 44 03 00 00       	push   $0x344
f0101480:	68 2b 76 10 f0       	push   $0xf010762b
f0101485:	e8 e0 eb ff ff       	call   f010006a <_panic>
	assert(!page_alloc(0));
f010148a:	68 5f 77 10 f0       	push   $0xf010775f
f010148f:	68 43 76 10 f0       	push   $0xf0107643
f0101494:	68 4b 03 00 00       	push   $0x34b
f0101499:	68 2b 76 10 f0       	push   $0xf010762b
f010149e:	e8 c7 eb ff ff       	call   f010006a <_panic>
	assert((pp0 = page_alloc(0)));
f01014a3:	68 0b 77 10 f0       	push   $0xf010770b
f01014a8:	68 43 76 10 f0       	push   $0xf0107643
f01014ad:	68 52 03 00 00       	push   $0x352
f01014b2:	68 2b 76 10 f0       	push   $0xf010762b
f01014b7:	e8 ae eb ff ff       	call   f010006a <_panic>
	assert((pp1 = page_alloc(0)));
f01014bc:	68 21 77 10 f0       	push   $0xf0107721
f01014c1:	68 43 76 10 f0       	push   $0xf0107643
f01014c6:	68 53 03 00 00       	push   $0x353
f01014cb:	68 2b 76 10 f0       	push   $0xf010762b
f01014d0:	e8 95 eb ff ff       	call   f010006a <_panic>
	assert((pp2 = page_alloc(0)));
f01014d5:	68 37 77 10 f0       	push   $0xf0107737
f01014da:	68 43 76 10 f0       	push   $0xf0107643
f01014df:	68 54 03 00 00       	push   $0x354
f01014e4:	68 2b 76 10 f0       	push   $0xf010762b
f01014e9:	e8 7c eb ff ff       	call   f010006a <_panic>
	assert(pp1 && pp1 != pp0);
f01014ee:	68 4d 77 10 f0       	push   $0xf010774d
f01014f3:	68 43 76 10 f0       	push   $0xf0107643
f01014f8:	68 56 03 00 00       	push   $0x356
f01014fd:	68 2b 76 10 f0       	push   $0xf010762b
f0101502:	e8 63 eb ff ff       	call   f010006a <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101507:	68 b0 6d 10 f0       	push   $0xf0106db0
f010150c:	68 43 76 10 f0       	push   $0xf0107643
f0101511:	68 57 03 00 00       	push   $0x357
f0101516:	68 2b 76 10 f0       	push   $0xf010762b
f010151b:	e8 4a eb ff ff       	call   f010006a <_panic>
	assert(!page_alloc(0));
f0101520:	68 5f 77 10 f0       	push   $0xf010775f
f0101525:	68 43 76 10 f0       	push   $0xf0107643
f010152a:	68 58 03 00 00       	push   $0x358
f010152f:	68 2b 76 10 f0       	push   $0xf010762b
f0101534:	e8 31 eb ff ff       	call   f010006a <_panic>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101539:	68 6e 77 10 f0       	push   $0xf010776e
f010153e:	68 43 76 10 f0       	push   $0xf0107643
f0101543:	68 5d 03 00 00       	push   $0x35d
f0101548:	68 2b 76 10 f0       	push   $0xf010762b
f010154d:	e8 18 eb ff ff       	call   f010006a <_panic>
	assert(pp && pp0 == pp);
f0101552:	68 8c 77 10 f0       	push   $0xf010778c
f0101557:	68 43 76 10 f0       	push   $0xf0107643
f010155c:	68 5e 03 00 00       	push   $0x35e
f0101561:	68 2b 76 10 f0       	push   $0xf010762b
f0101566:	e8 ff ea ff ff       	call   f010006a <_panic>
		assert(c[i] == 0);
f010156b:	68 9c 77 10 f0       	push   $0xf010779c
f0101570:	68 43 76 10 f0       	push   $0xf0107643
f0101575:	68 61 03 00 00       	push   $0x361
f010157a:	68 2b 76 10 f0       	push   $0xf010762b
f010157f:	e8 e6 ea ff ff       	call   f010006a <_panic>
	assert(nfree == 0);
f0101584:	85 f6                	test   %esi,%esi
f0101586:	75 18                	jne    f01015a0 <check_page_alloc+0x406>
	cprintf("check_page_alloc() succeeded!\n");
f0101588:	83 ec 0c             	sub    $0xc,%esp
f010158b:	68 30 6e 10 f0       	push   $0xf0106e30
f0101590:	e8 98 23 00 00       	call   f010392d <cprintf>
}
f0101595:	83 c4 10             	add    $0x10,%esp
f0101598:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010159b:	5b                   	pop    %ebx
f010159c:	5e                   	pop    %esi
f010159d:	5f                   	pop    %edi
f010159e:	5d                   	pop    %ebp
f010159f:	c3                   	ret    
	assert(nfree == 0);
f01015a0:	68 a6 77 10 f0       	push   $0xf01077a6
f01015a5:	68 43 76 10 f0       	push   $0xf0107643
f01015aa:	68 6e 03 00 00       	push   $0x36e
f01015af:	68 2b 76 10 f0       	push   $0xf010762b
f01015b4:	e8 b1 ea ff ff       	call   f010006a <_panic>

f01015b9 <page_decref>:
{
f01015b9:	f3 0f 1e fb          	endbr32 
f01015bd:	55                   	push   %ebp
f01015be:	89 e5                	mov    %esp,%ebp
f01015c0:	83 ec 08             	sub    $0x8,%esp
f01015c3:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f01015c6:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f01015ca:	83 e8 01             	sub    $0x1,%eax
f01015cd:	66 89 42 04          	mov    %ax,0x4(%edx)
f01015d1:	66 85 c0             	test   %ax,%ax
f01015d4:	74 02                	je     f01015d8 <page_decref+0x1f>
}
f01015d6:	c9                   	leave  
f01015d7:	c3                   	ret    
		page_free(pp);
f01015d8:	83 ec 0c             	sub    $0xc,%esp
f01015db:	52                   	push   %edx
f01015dc:	e8 7a fb ff ff       	call   f010115b <page_free>
f01015e1:	83 c4 10             	add    $0x10,%esp
}
f01015e4:	eb f0                	jmp    f01015d6 <page_decref+0x1d>

f01015e6 <create_page_table>:
{
f01015e6:	f3 0f 1e fb          	endbr32 
f01015ea:	55                   	push   %ebp
f01015eb:	89 e5                	mov    %esp,%ebp
f01015ed:	83 ec 14             	sub    $0x14,%esp
	struct PageInfo *page = page_alloc(ALLOC_ZERO);
f01015f0:	6a 01                	push   $0x1
f01015f2:	e8 19 fb ff ff       	call   f0101110 <page_alloc>
	if (!page) {
f01015f7:	83 c4 10             	add    $0x10,%esp
f01015fa:	85 c0                	test   %eax,%eax
f01015fc:	74 19                	je     f0101617 <create_page_table+0x31>
	page->pp_ref++;
f01015fe:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	pde_t new_pde = page2pa(page);
f0101603:	e8 9d f5 ff ff       	call   f0100ba5 <page2pa>
	*page_direc_entry = new_pde | PTE_P | PTE_W | PTE_U;
f0101608:	83 c8 07             	or     $0x7,%eax
f010160b:	8b 55 08             	mov    0x8(%ebp),%edx
f010160e:	89 02                	mov    %eax,(%edx)
	return 1;
f0101610:	b8 01 00 00 00       	mov    $0x1,%eax
}
f0101615:	c9                   	leave  
f0101616:	c3                   	ret    
		return 0;
f0101617:	b8 00 00 00 00       	mov    $0x0,%eax
f010161c:	eb f7                	jmp    f0101615 <create_page_table+0x2f>

f010161e <pgdir_walk>:
{
f010161e:	f3 0f 1e fb          	endbr32 
f0101622:	55                   	push   %ebp
f0101623:	89 e5                	mov    %esp,%ebp
f0101625:	56                   	push   %esi
f0101626:	53                   	push   %ebx
f0101627:	8b 75 0c             	mov    0xc(%ebp),%esi
	pde_t *page_direc_entry = pgdir + PDX(va);
f010162a:	89 f3                	mov    %esi,%ebx
f010162c:	c1 eb 16             	shr    $0x16,%ebx
f010162f:	c1 e3 02             	shl    $0x2,%ebx
f0101632:	03 5d 08             	add    0x8(%ebp),%ebx
	if (!(*page_direc_entry & PTE_P) &&
f0101635:	f6 03 01             	testb  $0x1,(%ebx)
f0101638:	75 1b                	jne    f0101655 <pgdir_walk+0x37>
		return NULL;
f010163a:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(*page_direc_entry & PTE_P) &&
f010163f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101643:	74 35                	je     f010167a <pgdir_walk+0x5c>
	    (!create || !create_page_table(page_direc_entry))) {
f0101645:	83 ec 0c             	sub    $0xc,%esp
f0101648:	53                   	push   %ebx
f0101649:	e8 98 ff ff ff       	call   f01015e6 <create_page_table>
f010164e:	83 c4 10             	add    $0x10,%esp
f0101651:	85 c0                	test   %eax,%eax
f0101653:	74 2c                	je     f0101681 <pgdir_walk+0x63>
	pte_t *pageTable = KADDR(PTE_ADDR(*page_direc_entry));
f0101655:	8b 0b                	mov    (%ebx),%ecx
f0101657:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f010165d:	ba d1 01 00 00       	mov    $0x1d1,%edx
f0101662:	b8 2b 76 10 f0       	mov    $0xf010762b,%eax
f0101667:	e8 d3 f5 ff ff       	call   f0100c3f <_kaddr>
f010166c:	89 c2                	mov    %eax,%edx
	return (pageTable + PTX(va));
f010166e:	89 f0                	mov    %esi,%eax
f0101670:	c1 e8 0a             	shr    $0xa,%eax
f0101673:	25 fc 0f 00 00       	and    $0xffc,%eax
f0101678:	01 d0                	add    %edx,%eax
}
f010167a:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010167d:	5b                   	pop    %ebx
f010167e:	5e                   	pop    %esi
f010167f:	5d                   	pop    %ebp
f0101680:	c3                   	ret    
		return NULL;
f0101681:	b8 00 00 00 00       	mov    $0x0,%eax
f0101686:	eb f2                	jmp    f010167a <pgdir_walk+0x5c>

f0101688 <boot_map_region_pages>:
{
f0101688:	55                   	push   %ebp
f0101689:	89 e5                	mov    %esp,%ebp
f010168b:	57                   	push   %edi
f010168c:	56                   	push   %esi
f010168d:	53                   	push   %ebx
f010168e:	83 ec 1c             	sub    $0x1c,%esp
f0101691:	89 c7                	mov    %eax,%edi
f0101693:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0101696:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	size_t aux = 0;
f0101699:	be 00 00 00 00       	mov    $0x0,%esi
f010169e:	89 f3                	mov    %esi,%ebx
f01016a0:	03 5d 08             	add    0x8(%ebp),%ebx
	while (aux < size) {
f01016a3:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f01016a6:	73 3f                	jae    f01016e7 <boot_map_region_pages+0x5f>
		pte_t *entry = pgdir_walk(pgdir, (void *) va, 1);
f01016a8:	83 ec 04             	sub    $0x4,%esp
f01016ab:	6a 01                	push   $0x1
f01016ad:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01016b0:	01 f0                	add    %esi,%eax
f01016b2:	50                   	push   %eax
f01016b3:	57                   	push   %edi
f01016b4:	e8 65 ff ff ff       	call   f010161e <pgdir_walk>
		if (!entry) {
f01016b9:	83 c4 10             	add    $0x10,%esp
f01016bc:	85 c0                	test   %eax,%eax
f01016be:	74 10                	je     f01016d0 <boot_map_region_pages+0x48>
		*entry = pa | perm | PTE_P;
f01016c0:	0b 5d 0c             	or     0xc(%ebp),%ebx
f01016c3:	83 cb 01             	or     $0x1,%ebx
f01016c6:	89 18                	mov    %ebx,(%eax)
		aux += PGSIZE;
f01016c8:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01016ce:	eb ce                	jmp    f010169e <boot_map_region_pages+0x16>
			panic("pgdir_walk doesnt work");
f01016d0:	83 ec 04             	sub    $0x4,%esp
f01016d3:	68 b1 77 10 f0       	push   $0xf01077b1
f01016d8:	68 dd 01 00 00       	push   $0x1dd
f01016dd:	68 2b 76 10 f0       	push   $0xf010762b
f01016e2:	e8 83 e9 ff ff       	call   f010006a <_panic>
}
f01016e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01016ea:	5b                   	pop    %ebx
f01016eb:	5e                   	pop    %esi
f01016ec:	5f                   	pop    %edi
f01016ed:	5d                   	pop    %ebp
f01016ee:	c3                   	ret    

f01016ef <boot_map_region>:
{
f01016ef:	55                   	push   %ebp
f01016f0:	89 e5                	mov    %esp,%ebp
f01016f2:	83 ec 10             	sub    $0x10,%esp
	boot_map_region_pages(pgdir, va, size, pa, perm);
f01016f5:	ff 75 0c             	pushl  0xc(%ebp)
f01016f8:	ff 75 08             	pushl  0x8(%ebp)
f01016fb:	e8 88 ff ff ff       	call   f0101688 <boot_map_region_pages>
}
f0101700:	83 c4 10             	add    $0x10,%esp
f0101703:	c9                   	leave  
f0101704:	c3                   	ret    

f0101705 <mem_init_mp>:
{
f0101705:	55                   	push   %ebp
f0101706:	89 e5                	mov    %esp,%ebp
f0101708:	57                   	push   %edi
f0101709:	56                   	push   %esi
f010170a:	53                   	push   %ebx
f010170b:	83 ec 0c             	sub    $0xc,%esp
f010170e:	bb 00 10 25 f0       	mov    $0xf0251000,%ebx
f0101713:	bf 00 10 29 f0       	mov    $0xf0291000,%edi
f0101718:	be 00 80 ff ef       	mov    $0xefff8000,%esi
		boot_map_region(kern_pgdir,
f010171d:	89 d9                	mov    %ebx,%ecx
f010171f:	ba 2b 01 00 00       	mov    $0x12b,%edx
f0101724:	b8 2b 76 10 f0       	mov    $0xf010762b,%eax
f0101729:	e8 3f f6 ff ff       	call   f0100d6d <_paddr>
f010172e:	83 ec 08             	sub    $0x8,%esp
f0101731:	6a 02                	push   $0x2
f0101733:	50                   	push   %eax
f0101734:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0101739:	89 f2                	mov    %esi,%edx
f010173b:	a1 8c fe 24 f0       	mov    0xf024fe8c,%eax
f0101740:	e8 aa ff ff ff       	call   f01016ef <boot_map_region>
f0101745:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f010174b:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	for (int i = 0; i < NCPU; i++) {
f0101751:	83 c4 10             	add    $0x10,%esp
f0101754:	39 fb                	cmp    %edi,%ebx
f0101756:	75 c5                	jne    f010171d <mem_init_mp+0x18>
}
f0101758:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010175b:	5b                   	pop    %ebx
f010175c:	5e                   	pop    %esi
f010175d:	5f                   	pop    %edi
f010175e:	5d                   	pop    %ebp
f010175f:	c3                   	ret    

f0101760 <check_kern_pgdir>:
{
f0101760:	55                   	push   %ebp
f0101761:	89 e5                	mov    %esp,%ebp
f0101763:	57                   	push   %edi
f0101764:	56                   	push   %esi
f0101765:	53                   	push   %ebx
f0101766:	83 ec 1c             	sub    $0x1c,%esp
	pgdir = kern_pgdir;
f0101769:	8b 3d 8c fe 24 f0    	mov    0xf024fe8c,%edi
	n = ROUNDUP(npages * sizeof(struct PageInfo), PGSIZE);
f010176f:	a1 88 fe 24 f0       	mov    0xf024fe88,%eax
f0101774:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f010177b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101780:	89 45 e0             	mov    %eax,-0x20(%ebp)
	for (i = 0; i < n; i += PGSIZE) {
f0101783:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101788:	3b 5d e0             	cmp    -0x20(%ebp),%ebx
f010178b:	0f 83 83 00 00 00    	jae    f0101814 <check_kern_pgdir+0xb4>
f0101791:	8d b3 00 00 00 ef    	lea    -0x11000000(%ebx),%esi
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0101797:	89 f2                	mov    %esi,%edx
f0101799:	89 f8                	mov    %edi,%eax
f010179b:	e8 e9 f4 ff ff       	call   f0100c89 <check_va2pa>
f01017a0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01017a3:	8b 0d 90 fe 24 f0    	mov    0xf024fe90,%ecx
f01017a9:	ba 87 03 00 00       	mov    $0x387,%edx
f01017ae:	b8 2b 76 10 f0       	mov    $0xf010762b,%eax
f01017b3:	e8 b5 f5 ff ff       	call   f0100d6d <_paddr>
f01017b8:	01 d8                	add    %ebx,%eax
f01017ba:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
f01017bd:	75 23                	jne    f01017e2 <check_kern_pgdir+0x82>
		pte = pgdir_walk(pgdir, (void *) (UPAGES + i), 0);
f01017bf:	83 ec 04             	sub    $0x4,%esp
f01017c2:	6a 00                	push   $0x0
f01017c4:	56                   	push   %esi
f01017c5:	57                   	push   %edi
f01017c6:	e8 53 fe ff ff       	call   f010161e <pgdir_walk>
		assert(PGOFF(*pte) == (PTE_U | PTE_P));
f01017cb:	8b 00                	mov    (%eax),%eax
f01017cd:	25 ff 0f 00 00       	and    $0xfff,%eax
f01017d2:	83 c4 10             	add    $0x10,%esp
f01017d5:	83 f8 05             	cmp    $0x5,%eax
f01017d8:	75 21                	jne    f01017fb <check_kern_pgdir+0x9b>
	for (i = 0; i < n; i += PGSIZE) {
f01017da:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01017e0:	eb a6                	jmp    f0101788 <check_kern_pgdir+0x28>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01017e2:	68 50 6e 10 f0       	push   $0xf0106e50
f01017e7:	68 43 76 10 f0       	push   $0xf0107643
f01017ec:	68 87 03 00 00       	push   $0x387
f01017f1:	68 2b 76 10 f0       	push   $0xf010762b
f01017f6:	e8 6f e8 ff ff       	call   f010006a <_panic>
		assert(PGOFF(*pte) == (PTE_U | PTE_P));
f01017fb:	68 84 6e 10 f0       	push   $0xf0106e84
f0101800:	68 43 76 10 f0       	push   $0xf0107643
f0101805:	68 8a 03 00 00       	push   $0x38a
f010180a:	68 2b 76 10 f0       	push   $0xf010762b
f010180f:	e8 56 e8 ff ff       	call   f010006a <_panic>
f0101814:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0101819:	89 da                	mov    %ebx,%edx
f010181b:	89 f8                	mov    %edi,%eax
f010181d:	e8 67 f4 ff ff       	call   f0100c89 <check_va2pa>
f0101822:	89 c6                	mov    %eax,%esi
f0101824:	8b 0d 44 e2 24 f0    	mov    0xf024e244,%ecx
f010182a:	ba 90 03 00 00       	mov    $0x390,%edx
f010182f:	b8 2b 76 10 f0       	mov    $0xf010762b,%eax
f0101834:	e8 34 f5 ff ff       	call   f0100d6d <_paddr>
f0101839:	8d 84 03 00 00 40 11 	lea    0x11400000(%ebx,%eax,1),%eax
f0101840:	39 c6                	cmp    %eax,%esi
f0101842:	75 54                	jne    f0101898 <check_kern_pgdir+0x138>
		pte = pgdir_walk(pgdir, (void *) (UENVS + i), 0);
f0101844:	83 ec 04             	sub    $0x4,%esp
f0101847:	6a 00                	push   $0x0
f0101849:	53                   	push   %ebx
f010184a:	57                   	push   %edi
f010184b:	e8 ce fd ff ff       	call   f010161e <pgdir_walk>
		assert(PGOFF(*pte) == (PTE_U | PTE_P));
f0101850:	8b 00                	mov    (%eax),%eax
f0101852:	25 ff 0f 00 00       	and    $0xfff,%eax
f0101857:	83 c4 10             	add    $0x10,%esp
f010185a:	83 f8 05             	cmp    $0x5,%eax
f010185d:	75 52                	jne    f01018b1 <check_kern_pgdir+0x151>
f010185f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE) {
f0101865:	81 fb 00 00 c2 ee    	cmp    $0xeec20000,%ebx
f010186b:	75 ac                	jne    f0101819 <check_kern_pgdir+0xb9>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f010186d:	8b 35 88 fe 24 f0    	mov    0xf024fe88,%esi
f0101873:	c1 e6 0c             	shl    $0xc,%esi
f0101876:	bb 00 00 00 00       	mov    $0x0,%ebx
f010187b:	39 de                	cmp    %ebx,%esi
f010187d:	76 64                	jbe    f01018e3 <check_kern_pgdir+0x183>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f010187f:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f0101885:	89 f8                	mov    %edi,%eax
f0101887:	e8 fd f3 ff ff       	call   f0100c89 <check_va2pa>
f010188c:	39 d8                	cmp    %ebx,%eax
f010188e:	75 3a                	jne    f01018ca <check_kern_pgdir+0x16a>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0101890:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0101896:	eb e3                	jmp    f010187b <check_kern_pgdir+0x11b>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0101898:	68 a4 6e 10 f0       	push   $0xf0106ea4
f010189d:	68 43 76 10 f0       	push   $0xf0107643
f01018a2:	68 90 03 00 00       	push   $0x390
f01018a7:	68 2b 76 10 f0       	push   $0xf010762b
f01018ac:	e8 b9 e7 ff ff       	call   f010006a <_panic>
		assert(PGOFF(*pte) == (PTE_U | PTE_P));
f01018b1:	68 84 6e 10 f0       	push   $0xf0106e84
f01018b6:	68 43 76 10 f0       	push   $0xf0107643
f01018bb:	68 93 03 00 00       	push   $0x393
f01018c0:	68 2b 76 10 f0       	push   $0xf010762b
f01018c5:	e8 a0 e7 ff ff       	call   f010006a <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f01018ca:	68 d8 6e 10 f0       	push   $0xf0106ed8
f01018cf:	68 43 76 10 f0       	push   $0xf0107643
f01018d4:	68 98 03 00 00       	push   $0x398
f01018d9:	68 2b 76 10 f0       	push   $0xf010762b
f01018de:	e8 87 e7 ff ff       	call   f010006a <_panic>
f01018e3:	c7 45 dc 00 10 25 f0 	movl   $0xf0251000,-0x24(%ebp)
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01018ea:	b8 00 80 ff ef       	mov    $0xefff8000,%eax
f01018ef:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f01018f2:	89 c7                	mov    %eax,%edi
f01018f4:	8d b7 00 80 ff ff    	lea    -0x8000(%edi),%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i) ==
f01018fa:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01018fd:	89 45 e0             	mov    %eax,-0x20(%ebp)
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0101900:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101905:	89 75 d8             	mov    %esi,-0x28(%ebp)
			assert(check_va2pa(pgdir, base + KSTKGAP + i) ==
f0101908:	8d 14 3b             	lea    (%ebx,%edi,1),%edx
f010190b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010190e:	e8 76 f3 ff ff       	call   f0100c89 <check_va2pa>
f0101913:	89 c6                	mov    %eax,%esi
f0101915:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0101918:	ba a0 03 00 00       	mov    $0x3a0,%edx
f010191d:	b8 2b 76 10 f0       	mov    $0xf010762b,%eax
f0101922:	e8 46 f4 ff ff       	call   f0100d6d <_paddr>
f0101927:	01 d8                	add    %ebx,%eax
f0101929:	39 c6                	cmp    %eax,%esi
f010192b:	75 4d                	jne    f010197a <check_kern_pgdir+0x21a>
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f010192d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0101933:	81 fb 00 80 00 00    	cmp    $0x8000,%ebx
f0101939:	75 cd                	jne    f0101908 <check_kern_pgdir+0x1a8>
f010193b:	8b 75 d8             	mov    -0x28(%ebp),%esi
f010193e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			assert(check_va2pa(pgdir, base + i) == ~0);
f0101941:	89 f2                	mov    %esi,%edx
f0101943:	89 d8                	mov    %ebx,%eax
f0101945:	e8 3f f3 ff ff       	call   f0100c89 <check_va2pa>
f010194a:	83 f8 ff             	cmp    $0xffffffff,%eax
f010194d:	75 44                	jne    f0101993 <check_kern_pgdir+0x233>
f010194f:	81 c6 00 10 00 00    	add    $0x1000,%esi
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0101955:	39 fe                	cmp    %edi,%esi
f0101957:	75 e8                	jne    f0101941 <check_kern_pgdir+0x1e1>
f0101959:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f010195c:	81 ef 00 00 01 00    	sub    $0x10000,%edi
f0101962:	81 45 dc 00 80 00 00 	addl   $0x8000,-0x24(%ebp)
	for (n = 0; n < NCPU; n++) {
f0101969:	81 ff 00 80 f7 ef    	cmp    $0xeff78000,%edi
f010196f:	75 83                	jne    f01018f4 <check_kern_pgdir+0x194>
f0101971:	89 df                	mov    %ebx,%edi
	for (i = 0; i < NPDENTRIES; i++) {
f0101973:	b8 00 00 00 00       	mov    $0x0,%eax
f0101978:	eb 68                	jmp    f01019e2 <check_kern_pgdir+0x282>
			assert(check_va2pa(pgdir, base + KSTKGAP + i) ==
f010197a:	68 00 6f 10 f0       	push   $0xf0106f00
f010197f:	68 43 76 10 f0       	push   $0xf0107643
f0101984:	68 9f 03 00 00       	push   $0x39f
f0101989:	68 2b 76 10 f0       	push   $0xf010762b
f010198e:	e8 d7 e6 ff ff       	call   f010006a <_panic>
			assert(check_va2pa(pgdir, base + i) == ~0);
f0101993:	68 48 6f 10 f0       	push   $0xf0106f48
f0101998:	68 43 76 10 f0       	push   $0xf0107643
f010199d:	68 a2 03 00 00       	push   $0x3a2
f01019a2:	68 2b 76 10 f0       	push   $0xf010762b
f01019a7:	e8 be e6 ff ff       	call   f010006a <_panic>
			assert(pgdir[i] & PTE_P);
f01019ac:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f01019b0:	75 48                	jne    f01019fa <check_kern_pgdir+0x29a>
f01019b2:	68 c8 77 10 f0       	push   $0xf01077c8
f01019b7:	68 43 76 10 f0       	push   $0xf0107643
f01019bc:	68 ad 03 00 00       	push   $0x3ad
f01019c1:	68 2b 76 10 f0       	push   $0xf010762b
f01019c6:	e8 9f e6 ff ff       	call   f010006a <_panic>
				assert(pgdir[i] & PTE_P);
f01019cb:	8b 14 87             	mov    (%edi,%eax,4),%edx
f01019ce:	f6 c2 01             	test   $0x1,%dl
f01019d1:	74 2c                	je     f01019ff <check_kern_pgdir+0x29f>
				assert(pgdir[i] & PTE_W);
f01019d3:	f6 c2 02             	test   $0x2,%dl
f01019d6:	74 40                	je     f0101a18 <check_kern_pgdir+0x2b8>
	for (i = 0; i < NPDENTRIES; i++) {
f01019d8:	83 c0 01             	add    $0x1,%eax
f01019db:	3d 00 04 00 00       	cmp    $0x400,%eax
f01019e0:	74 68                	je     f0101a4a <check_kern_pgdir+0x2ea>
		switch (i) {
f01019e2:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f01019e8:	83 fa 04             	cmp    $0x4,%edx
f01019eb:	76 bf                	jbe    f01019ac <check_kern_pgdir+0x24c>
			if (i >= PDX(KERNBASE)) {
f01019ed:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f01019f2:	77 d7                	ja     f01019cb <check_kern_pgdir+0x26b>
				assert(pgdir[i] == 0);
f01019f4:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f01019f8:	75 37                	jne    f0101a31 <check_kern_pgdir+0x2d1>
	for (i = 0; i < NPDENTRIES; i++) {
f01019fa:	83 c0 01             	add    $0x1,%eax
f01019fd:	eb e3                	jmp    f01019e2 <check_kern_pgdir+0x282>
				assert(pgdir[i] & PTE_P);
f01019ff:	68 c8 77 10 f0       	push   $0xf01077c8
f0101a04:	68 43 76 10 f0       	push   $0xf0107643
f0101a09:	68 b1 03 00 00       	push   $0x3b1
f0101a0e:	68 2b 76 10 f0       	push   $0xf010762b
f0101a13:	e8 52 e6 ff ff       	call   f010006a <_panic>
				assert(pgdir[i] & PTE_W);
f0101a18:	68 d9 77 10 f0       	push   $0xf01077d9
f0101a1d:	68 43 76 10 f0       	push   $0xf0107643
f0101a22:	68 b2 03 00 00       	push   $0x3b2
f0101a27:	68 2b 76 10 f0       	push   $0xf010762b
f0101a2c:	e8 39 e6 ff ff       	call   f010006a <_panic>
				assert(pgdir[i] == 0);
f0101a31:	68 ea 77 10 f0       	push   $0xf01077ea
f0101a36:	68 43 76 10 f0       	push   $0xf0107643
f0101a3b:	68 b4 03 00 00       	push   $0x3b4
f0101a40:	68 2b 76 10 f0       	push   $0xf010762b
f0101a45:	e8 20 e6 ff ff       	call   f010006a <_panic>
	cprintf("check_kern_pgdir() succeeded!\n");
f0101a4a:	83 ec 0c             	sub    $0xc,%esp
f0101a4d:	68 6c 6f 10 f0       	push   $0xf0106f6c
f0101a52:	e8 d6 1e 00 00       	call   f010392d <cprintf>
}
f0101a57:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101a5a:	5b                   	pop    %ebx
f0101a5b:	5e                   	pop    %esi
f0101a5c:	5f                   	pop    %edi
f0101a5d:	5d                   	pop    %ebp
f0101a5e:	c3                   	ret    

f0101a5f <page_lookup>:
{
f0101a5f:	f3 0f 1e fb          	endbr32 
f0101a63:	55                   	push   %ebp
f0101a64:	89 e5                	mov    %esp,%ebp
f0101a66:	53                   	push   %ebx
f0101a67:	83 ec 08             	sub    $0x8,%esp
f0101a6a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	pte_t *pgTable = pgdir_walk(pgdir, va, 0);
f0101a6d:	6a 00                	push   $0x0
f0101a6f:	ff 75 0c             	pushl  0xc(%ebp)
f0101a72:	ff 75 08             	pushl  0x8(%ebp)
f0101a75:	e8 a4 fb ff ff       	call   f010161e <pgdir_walk>
	if (!pgTable || !(*pgTable | PTE_P)) {
f0101a7a:	83 c4 10             	add    $0x10,%esp
f0101a7d:	85 c0                	test   %eax,%eax
f0101a7f:	74 12                	je     f0101a93 <page_lookup+0x34>
	if (pte_store != 0) {
f0101a81:	85 db                	test   %ebx,%ebx
f0101a83:	74 02                	je     f0101a87 <page_lookup+0x28>
		*pte_store = pgTable;
f0101a85:	89 03                	mov    %eax,(%ebx)
	return pa2page(PTE_ADDR(*pgTable));
f0101a87:	8b 00                	mov    (%eax),%eax
f0101a89:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101a8e:	e8 af f5 ff ff       	call   f0101042 <pa2page>
}
f0101a93:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101a96:	c9                   	leave  
f0101a97:	c3                   	ret    

f0101a98 <tlb_invalidate>:
{
f0101a98:	f3 0f 1e fb          	endbr32 
f0101a9c:	55                   	push   %ebp
f0101a9d:	89 e5                	mov    %esp,%ebp
f0101a9f:	83 ec 08             	sub    $0x8,%esp
	if (!curenv || curenv->env_pgdir == pgdir)
f0101aa2:	e8 4d 45 00 00       	call   f0105ff4 <cpunum>
f0101aa7:	6b c0 74             	imul   $0x74,%eax,%eax
f0101aaa:	83 b8 28 00 25 f0 00 	cmpl   $0x0,-0xfdaffd8(%eax)
f0101ab1:	74 16                	je     f0101ac9 <tlb_invalidate+0x31>
f0101ab3:	e8 3c 45 00 00       	call   f0105ff4 <cpunum>
f0101ab8:	6b c0 74             	imul   $0x74,%eax,%eax
f0101abb:	8b 80 28 00 25 f0    	mov    -0xfdaffd8(%eax),%eax
f0101ac1:	8b 55 08             	mov    0x8(%ebp),%edx
f0101ac4:	39 50 64             	cmp    %edx,0x64(%eax)
f0101ac7:	75 08                	jne    f0101ad1 <tlb_invalidate+0x39>
		invlpg(va);
f0101ac9:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101acc:	e8 c4 f0 ff ff       	call   f0100b95 <invlpg>
}
f0101ad1:	c9                   	leave  
f0101ad2:	c3                   	ret    

f0101ad3 <page_remove>:
{
f0101ad3:	f3 0f 1e fb          	endbr32 
f0101ad7:	55                   	push   %ebp
f0101ad8:	89 e5                	mov    %esp,%ebp
f0101ada:	56                   	push   %esi
f0101adb:	53                   	push   %ebx
f0101adc:	83 ec 14             	sub    $0x14,%esp
f0101adf:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0101ae2:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct PageInfo *pp = page_lookup(pgdir, va, &pte);
f0101ae5:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101ae8:	50                   	push   %eax
f0101ae9:	56                   	push   %esi
f0101aea:	53                   	push   %ebx
f0101aeb:	e8 6f ff ff ff       	call   f0101a5f <page_lookup>
	if (!pp) {
f0101af0:	83 c4 10             	add    $0x10,%esp
f0101af3:	85 c0                	test   %eax,%eax
f0101af5:	74 27                	je     f0101b1e <page_remove+0x4b>
	page_decref(pp);
f0101af7:	83 ec 0c             	sub    $0xc,%esp
f0101afa:	50                   	push   %eax
f0101afb:	e8 b9 fa ff ff       	call   f01015b9 <page_decref>
	if (*pte) {
f0101b00:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101b03:	83 c4 10             	add    $0x10,%esp
f0101b06:	83 38 00             	cmpl   $0x0,(%eax)
f0101b09:	74 06                	je     f0101b11 <page_remove+0x3e>
		*pte = 0;
f0101b0b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	tlb_invalidate(pgdir, va);
f0101b11:	83 ec 08             	sub    $0x8,%esp
f0101b14:	56                   	push   %esi
f0101b15:	53                   	push   %ebx
f0101b16:	e8 7d ff ff ff       	call   f0101a98 <tlb_invalidate>
f0101b1b:	83 c4 10             	add    $0x10,%esp
}
f0101b1e:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101b21:	5b                   	pop    %ebx
f0101b22:	5e                   	pop    %esi
f0101b23:	5d                   	pop    %ebp
f0101b24:	c3                   	ret    

f0101b25 <page_insert>:
{
f0101b25:	f3 0f 1e fb          	endbr32 
f0101b29:	55                   	push   %ebp
f0101b2a:	89 e5                	mov    %esp,%ebp
f0101b2c:	57                   	push   %edi
f0101b2d:	56                   	push   %esi
f0101b2e:	53                   	push   %ebx
f0101b2f:	83 ec 10             	sub    $0x10,%esp
f0101b32:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101b35:	8b 7d 10             	mov    0x10(%ebp),%edi
	pte_t *pte = pgdir_walk(pgdir, va, 1);
f0101b38:	6a 01                	push   $0x1
f0101b3a:	57                   	push   %edi
f0101b3b:	ff 75 08             	pushl  0x8(%ebp)
f0101b3e:	e8 db fa ff ff       	call   f010161e <pgdir_walk>
	if (!pte) {
f0101b43:	83 c4 10             	add    $0x10,%esp
f0101b46:	85 c0                	test   %eax,%eax
f0101b48:	74 39                	je     f0101b83 <page_insert+0x5e>
f0101b4a:	89 c3                	mov    %eax,%ebx
	pp->pp_ref++;
f0101b4c:	66 83 46 04 01       	addw   $0x1,0x4(%esi)
	if (*pte & PTE_P) {
f0101b51:	f6 00 01             	testb  $0x1,(%eax)
f0101b54:	75 1c                	jne    f0101b72 <page_insert+0x4d>
	*pte = page2pa(pp) | perm | PTE_P;
f0101b56:	89 f0                	mov    %esi,%eax
f0101b58:	e8 48 f0 ff ff       	call   f0100ba5 <page2pa>
f0101b5d:	0b 45 14             	or     0x14(%ebp),%eax
f0101b60:	83 c8 01             	or     $0x1,%eax
f0101b63:	89 03                	mov    %eax,(%ebx)
	return 0;
f0101b65:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101b6a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101b6d:	5b                   	pop    %ebx
f0101b6e:	5e                   	pop    %esi
f0101b6f:	5f                   	pop    %edi
f0101b70:	5d                   	pop    %ebp
f0101b71:	c3                   	ret    
		page_remove(pgdir, va);
f0101b72:	83 ec 08             	sub    $0x8,%esp
f0101b75:	57                   	push   %edi
f0101b76:	ff 75 08             	pushl  0x8(%ebp)
f0101b79:	e8 55 ff ff ff       	call   f0101ad3 <page_remove>
f0101b7e:	83 c4 10             	add    $0x10,%esp
f0101b81:	eb d3                	jmp    f0101b56 <page_insert+0x31>
		return -E_NO_MEM;
f0101b83:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0101b88:	eb e0                	jmp    f0101b6a <page_insert+0x45>

f0101b8a <check_page_installed_pgdir>:
}

// check page_insert, page_remove, &c, with an installed kern_pgdir
static void
check_page_installed_pgdir(void)
{
f0101b8a:	55                   	push   %ebp
f0101b8b:	89 e5                	mov    %esp,%ebp
f0101b8d:	57                   	push   %edi
f0101b8e:	56                   	push   %esi
f0101b8f:	53                   	push   %ebx
f0101b90:	83 ec 18             	sub    $0x18,%esp
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101b93:	6a 00                	push   $0x0
f0101b95:	e8 76 f5 ff ff       	call   f0101110 <page_alloc>
f0101b9a:	83 c4 10             	add    $0x10,%esp
f0101b9d:	85 c0                	test   %eax,%eax
f0101b9f:	0f 84 67 01 00 00    	je     f0101d0c <check_page_installed_pgdir+0x182>
f0101ba5:	89 c6                	mov    %eax,%esi
	assert((pp1 = page_alloc(0)));
f0101ba7:	83 ec 0c             	sub    $0xc,%esp
f0101baa:	6a 00                	push   $0x0
f0101bac:	e8 5f f5 ff ff       	call   f0101110 <page_alloc>
f0101bb1:	89 c7                	mov    %eax,%edi
f0101bb3:	83 c4 10             	add    $0x10,%esp
f0101bb6:	85 c0                	test   %eax,%eax
f0101bb8:	0f 84 67 01 00 00    	je     f0101d25 <check_page_installed_pgdir+0x19b>
	assert((pp2 = page_alloc(0)));
f0101bbe:	83 ec 0c             	sub    $0xc,%esp
f0101bc1:	6a 00                	push   $0x0
f0101bc3:	e8 48 f5 ff ff       	call   f0101110 <page_alloc>
f0101bc8:	89 c3                	mov    %eax,%ebx
f0101bca:	83 c4 10             	add    $0x10,%esp
f0101bcd:	85 c0                	test   %eax,%eax
f0101bcf:	0f 84 69 01 00 00    	je     f0101d3e <check_page_installed_pgdir+0x1b4>
	page_free(pp0);
f0101bd5:	83 ec 0c             	sub    $0xc,%esp
f0101bd8:	56                   	push   %esi
f0101bd9:	e8 7d f5 ff ff       	call   f010115b <page_free>
	memset(page2kva(pp1), 1, PGSIZE);
f0101bde:	89 f8                	mov    %edi,%eax
f0101be0:	e8 86 f0 ff ff       	call   f0100c6b <page2kva>
f0101be5:	83 c4 0c             	add    $0xc,%esp
f0101be8:	68 00 10 00 00       	push   $0x1000
f0101bed:	6a 01                	push   $0x1
f0101bef:	50                   	push   %eax
f0101bf0:	e8 70 3d 00 00       	call   f0105965 <memset>
	memset(page2kva(pp2), 2, PGSIZE);
f0101bf5:	89 d8                	mov    %ebx,%eax
f0101bf7:	e8 6f f0 ff ff       	call   f0100c6b <page2kva>
f0101bfc:	83 c4 0c             	add    $0xc,%esp
f0101bff:	68 00 10 00 00       	push   $0x1000
f0101c04:	6a 02                	push   $0x2
f0101c06:	50                   	push   %eax
f0101c07:	e8 59 3d 00 00       	call   f0105965 <memset>
	page_insert(kern_pgdir, pp1, (void *) PGSIZE, PTE_W);
f0101c0c:	6a 02                	push   $0x2
f0101c0e:	68 00 10 00 00       	push   $0x1000
f0101c13:	57                   	push   %edi
f0101c14:	ff 35 8c fe 24 f0    	pushl  0xf024fe8c
f0101c1a:	e8 06 ff ff ff       	call   f0101b25 <page_insert>
	assert(pp1->pp_ref == 1);
f0101c1f:	83 c4 20             	add    $0x20,%esp
f0101c22:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101c27:	0f 85 2a 01 00 00    	jne    f0101d57 <check_page_installed_pgdir+0x1cd>
	assert(*(uint32_t *) PGSIZE == 0x01010101U);
f0101c2d:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0101c34:	01 01 01 
f0101c37:	0f 85 33 01 00 00    	jne    f0101d70 <check_page_installed_pgdir+0x1e6>
	page_insert(kern_pgdir, pp2, (void *) PGSIZE, PTE_W);
f0101c3d:	6a 02                	push   $0x2
f0101c3f:	68 00 10 00 00       	push   $0x1000
f0101c44:	53                   	push   %ebx
f0101c45:	ff 35 8c fe 24 f0    	pushl  0xf024fe8c
f0101c4b:	e8 d5 fe ff ff       	call   f0101b25 <page_insert>
	assert(*(uint32_t *) PGSIZE == 0x02020202U);
f0101c50:	83 c4 10             	add    $0x10,%esp
f0101c53:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0101c5a:	02 02 02 
f0101c5d:	0f 85 26 01 00 00    	jne    f0101d89 <check_page_installed_pgdir+0x1ff>
	assert(pp2->pp_ref == 1);
f0101c63:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101c68:	0f 85 34 01 00 00    	jne    f0101da2 <check_page_installed_pgdir+0x218>
	assert(pp1->pp_ref == 0);
f0101c6e:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101c73:	0f 85 42 01 00 00    	jne    f0101dbb <check_page_installed_pgdir+0x231>
	*(uint32_t *) PGSIZE = 0x03030303U;
f0101c79:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0101c80:	03 03 03 
	assert(*(uint32_t *) page2kva(pp2) == 0x03030303U);
f0101c83:	89 d8                	mov    %ebx,%eax
f0101c85:	e8 e1 ef ff ff       	call   f0100c6b <page2kva>
f0101c8a:	81 38 03 03 03 03    	cmpl   $0x3030303,(%eax)
f0101c90:	0f 85 3e 01 00 00    	jne    f0101dd4 <check_page_installed_pgdir+0x24a>
	page_remove(kern_pgdir, (void *) PGSIZE);
f0101c96:	83 ec 08             	sub    $0x8,%esp
f0101c99:	68 00 10 00 00       	push   $0x1000
f0101c9e:	ff 35 8c fe 24 f0    	pushl  0xf024fe8c
f0101ca4:	e8 2a fe ff ff       	call   f0101ad3 <page_remove>
	assert(pp2->pp_ref == 0);
f0101ca9:	83 c4 10             	add    $0x10,%esp
f0101cac:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101cb1:	0f 85 36 01 00 00    	jne    f0101ded <check_page_installed_pgdir+0x263>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101cb7:	8b 1d 8c fe 24 f0    	mov    0xf024fe8c,%ebx
f0101cbd:	89 f0                	mov    %esi,%eax
f0101cbf:	e8 e1 ee ff ff       	call   f0100ba5 <page2pa>
f0101cc4:	89 c2                	mov    %eax,%edx
f0101cc6:	8b 03                	mov    (%ebx),%eax
f0101cc8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101ccd:	39 d0                	cmp    %edx,%eax
f0101ccf:	0f 85 31 01 00 00    	jne    f0101e06 <check_page_installed_pgdir+0x27c>
	kern_pgdir[0] = 0;
f0101cd5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	assert(pp0->pp_ref == 1);
f0101cdb:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101ce0:	0f 85 39 01 00 00    	jne    f0101e1f <check_page_installed_pgdir+0x295>
	pp0->pp_ref = 0;
f0101ce6:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f0101cec:	83 ec 0c             	sub    $0xc,%esp
f0101cef:	56                   	push   %esi
f0101cf0:	e8 66 f4 ff ff       	call   f010115b <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0101cf5:	c7 04 24 28 70 10 f0 	movl   $0xf0107028,(%esp)
f0101cfc:	e8 2c 1c 00 00       	call   f010392d <cprintf>
}
f0101d01:	83 c4 10             	add    $0x10,%esp
f0101d04:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101d07:	5b                   	pop    %ebx
f0101d08:	5e                   	pop    %esi
f0101d09:	5f                   	pop    %edi
f0101d0a:	5d                   	pop    %ebp
f0101d0b:	c3                   	ret    
	assert((pp0 = page_alloc(0)));
f0101d0c:	68 0b 77 10 f0       	push   $0xf010770b
f0101d11:	68 43 76 10 f0       	push   $0xf0107643
f0101d16:	68 9a 04 00 00       	push   $0x49a
f0101d1b:	68 2b 76 10 f0       	push   $0xf010762b
f0101d20:	e8 45 e3 ff ff       	call   f010006a <_panic>
	assert((pp1 = page_alloc(0)));
f0101d25:	68 21 77 10 f0       	push   $0xf0107721
f0101d2a:	68 43 76 10 f0       	push   $0xf0107643
f0101d2f:	68 9b 04 00 00       	push   $0x49b
f0101d34:	68 2b 76 10 f0       	push   $0xf010762b
f0101d39:	e8 2c e3 ff ff       	call   f010006a <_panic>
	assert((pp2 = page_alloc(0)));
f0101d3e:	68 37 77 10 f0       	push   $0xf0107737
f0101d43:	68 43 76 10 f0       	push   $0xf0107643
f0101d48:	68 9c 04 00 00       	push   $0x49c
f0101d4d:	68 2b 76 10 f0       	push   $0xf010762b
f0101d52:	e8 13 e3 ff ff       	call   f010006a <_panic>
	assert(pp1->pp_ref == 1);
f0101d57:	68 f8 77 10 f0       	push   $0xf01077f8
f0101d5c:	68 43 76 10 f0       	push   $0xf0107643
f0101d61:	68 a1 04 00 00       	push   $0x4a1
f0101d66:	68 2b 76 10 f0       	push   $0xf010762b
f0101d6b:	e8 fa e2 ff ff       	call   f010006a <_panic>
	assert(*(uint32_t *) PGSIZE == 0x01010101U);
f0101d70:	68 8c 6f 10 f0       	push   $0xf0106f8c
f0101d75:	68 43 76 10 f0       	push   $0xf0107643
f0101d7a:	68 a2 04 00 00       	push   $0x4a2
f0101d7f:	68 2b 76 10 f0       	push   $0xf010762b
f0101d84:	e8 e1 e2 ff ff       	call   f010006a <_panic>
	assert(*(uint32_t *) PGSIZE == 0x02020202U);
f0101d89:	68 b0 6f 10 f0       	push   $0xf0106fb0
f0101d8e:	68 43 76 10 f0       	push   $0xf0107643
f0101d93:	68 a4 04 00 00       	push   $0x4a4
f0101d98:	68 2b 76 10 f0       	push   $0xf010762b
f0101d9d:	e8 c8 e2 ff ff       	call   f010006a <_panic>
	assert(pp2->pp_ref == 1);
f0101da2:	68 09 78 10 f0       	push   $0xf0107809
f0101da7:	68 43 76 10 f0       	push   $0xf0107643
f0101dac:	68 a5 04 00 00       	push   $0x4a5
f0101db1:	68 2b 76 10 f0       	push   $0xf010762b
f0101db6:	e8 af e2 ff ff       	call   f010006a <_panic>
	assert(pp1->pp_ref == 0);
f0101dbb:	68 1a 78 10 f0       	push   $0xf010781a
f0101dc0:	68 43 76 10 f0       	push   $0xf0107643
f0101dc5:	68 a6 04 00 00       	push   $0x4a6
f0101dca:	68 2b 76 10 f0       	push   $0xf010762b
f0101dcf:	e8 96 e2 ff ff       	call   f010006a <_panic>
	assert(*(uint32_t *) page2kva(pp2) == 0x03030303U);
f0101dd4:	68 d4 6f 10 f0       	push   $0xf0106fd4
f0101dd9:	68 43 76 10 f0       	push   $0xf0107643
f0101dde:	68 a8 04 00 00       	push   $0x4a8
f0101de3:	68 2b 76 10 f0       	push   $0xf010762b
f0101de8:	e8 7d e2 ff ff       	call   f010006a <_panic>
	assert(pp2->pp_ref == 0);
f0101ded:	68 2b 78 10 f0       	push   $0xf010782b
f0101df2:	68 43 76 10 f0       	push   $0xf0107643
f0101df7:	68 aa 04 00 00       	push   $0x4aa
f0101dfc:	68 2b 76 10 f0       	push   $0xf010762b
f0101e01:	e8 64 e2 ff ff       	call   f010006a <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101e06:	68 00 70 10 f0       	push   $0xf0107000
f0101e0b:	68 43 76 10 f0       	push   $0xf0107643
f0101e10:	68 ad 04 00 00       	push   $0x4ad
f0101e15:	68 2b 76 10 f0       	push   $0xf010762b
f0101e1a:	e8 4b e2 ff ff       	call   f010006a <_panic>
	assert(pp0->pp_ref == 1);
f0101e1f:	68 3c 78 10 f0       	push   $0xf010783c
f0101e24:	68 43 76 10 f0       	push   $0xf0107643
f0101e29:	68 af 04 00 00       	push   $0x4af
f0101e2e:	68 2b 76 10 f0       	push   $0xf010762b
f0101e33:	e8 32 e2 ff ff       	call   f010006a <_panic>

f0101e38 <mmio_map_region>:
{
f0101e38:	f3 0f 1e fb          	endbr32 
f0101e3c:	55                   	push   %ebp
f0101e3d:	89 e5                	mov    %esp,%ebp
f0101e3f:	53                   	push   %ebx
f0101e40:	83 ec 04             	sub    $0x4,%esp
	size = ROUNDUP(size, PGSIZE);
f0101e43:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101e46:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
f0101e4c:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if (base + size > MMIOLIM) {
f0101e52:	8b 15 00 33 12 f0    	mov    0xf0123300,%edx
f0101e58:	8d 04 1a             	lea    (%edx,%ebx,1),%eax
f0101e5b:	3d 00 00 c0 ef       	cmp    $0xefc00000,%eax
f0101e60:	77 26                	ja     f0101e88 <mmio_map_region+0x50>
	boot_map_region(kern_pgdir, base, size, pa, PTE_PCD | PTE_PWT | PTE_W);
f0101e62:	83 ec 08             	sub    $0x8,%esp
f0101e65:	6a 1a                	push   $0x1a
f0101e67:	ff 75 08             	pushl  0x8(%ebp)
f0101e6a:	89 d9                	mov    %ebx,%ecx
f0101e6c:	a1 8c fe 24 f0       	mov    0xf024fe8c,%eax
f0101e71:	e8 79 f8 ff ff       	call   f01016ef <boot_map_region>
	void *base_aux = (void *) base;
f0101e76:	a1 00 33 12 f0       	mov    0xf0123300,%eax
	base += size;
f0101e7b:	01 c3                	add    %eax,%ebx
f0101e7d:	89 1d 00 33 12 f0    	mov    %ebx,0xf0123300
}
f0101e83:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101e86:	c9                   	leave  
f0101e87:	c3                   	ret    
		panic("mmiolim overflow");
f0101e88:	83 ec 04             	sub    $0x4,%esp
f0101e8b:	68 4d 78 10 f0       	push   $0xf010784d
f0101e90:	68 99 02 00 00       	push   $0x299
f0101e95:	68 2b 76 10 f0       	push   $0xf010762b
f0101e9a:	e8 cb e1 ff ff       	call   f010006a <_panic>

f0101e9f <check_page>:
{
f0101e9f:	55                   	push   %ebp
f0101ea0:	89 e5                	mov    %esp,%ebp
f0101ea2:	57                   	push   %edi
f0101ea3:	56                   	push   %esi
f0101ea4:	53                   	push   %ebx
f0101ea5:	83 ec 38             	sub    $0x38,%esp
	assert((pp0 = page_alloc(0)));
f0101ea8:	6a 00                	push   $0x0
f0101eaa:	e8 61 f2 ff ff       	call   f0101110 <page_alloc>
f0101eaf:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101eb2:	83 c4 10             	add    $0x10,%esp
f0101eb5:	85 c0                	test   %eax,%eax
f0101eb7:	0f 84 71 07 00 00    	je     f010262e <check_page+0x78f>
	assert((pp1 = page_alloc(0)));
f0101ebd:	83 ec 0c             	sub    $0xc,%esp
f0101ec0:	6a 00                	push   $0x0
f0101ec2:	e8 49 f2 ff ff       	call   f0101110 <page_alloc>
f0101ec7:	89 c6                	mov    %eax,%esi
f0101ec9:	83 c4 10             	add    $0x10,%esp
f0101ecc:	85 c0                	test   %eax,%eax
f0101ece:	0f 84 73 07 00 00    	je     f0102647 <check_page+0x7a8>
	assert((pp2 = page_alloc(0)));
f0101ed4:	83 ec 0c             	sub    $0xc,%esp
f0101ed7:	6a 00                	push   $0x0
f0101ed9:	e8 32 f2 ff ff       	call   f0101110 <page_alloc>
f0101ede:	89 c3                	mov    %eax,%ebx
f0101ee0:	83 c4 10             	add    $0x10,%esp
f0101ee3:	85 c0                	test   %eax,%eax
f0101ee5:	0f 84 75 07 00 00    	je     f0102660 <check_page+0x7c1>
	assert(pp1 && pp1 != pp0);
f0101eeb:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
f0101eee:	0f 84 85 07 00 00    	je     f0102679 <check_page+0x7da>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101ef4:	39 c6                	cmp    %eax,%esi
f0101ef6:	0f 84 96 07 00 00    	je     f0102692 <check_page+0x7f3>
f0101efc:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101eff:	0f 84 8d 07 00 00    	je     f0102692 <check_page+0x7f3>
	fl = page_free_list;
f0101f05:	a1 40 e2 24 f0       	mov    0xf024e240,%eax
f0101f0a:	89 45 c8             	mov    %eax,-0x38(%ebp)
	page_free_list = 0;
f0101f0d:	c7 05 40 e2 24 f0 00 	movl   $0x0,0xf024e240
f0101f14:	00 00 00 
	assert(!page_alloc(0));
f0101f17:	83 ec 0c             	sub    $0xc,%esp
f0101f1a:	6a 00                	push   $0x0
f0101f1c:	e8 ef f1 ff ff       	call   f0101110 <page_alloc>
f0101f21:	83 c4 10             	add    $0x10,%esp
f0101f24:	85 c0                	test   %eax,%eax
f0101f26:	0f 85 7f 07 00 00    	jne    f01026ab <check_page+0x80c>
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101f2c:	83 ec 04             	sub    $0x4,%esp
f0101f2f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101f32:	50                   	push   %eax
f0101f33:	6a 00                	push   $0x0
f0101f35:	ff 35 8c fe 24 f0    	pushl  0xf024fe8c
f0101f3b:	e8 1f fb ff ff       	call   f0101a5f <page_lookup>
f0101f40:	83 c4 10             	add    $0x10,%esp
f0101f43:	85 c0                	test   %eax,%eax
f0101f45:	0f 85 79 07 00 00    	jne    f01026c4 <check_page+0x825>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101f4b:	6a 02                	push   $0x2
f0101f4d:	6a 00                	push   $0x0
f0101f4f:	56                   	push   %esi
f0101f50:	ff 35 8c fe 24 f0    	pushl  0xf024fe8c
f0101f56:	e8 ca fb ff ff       	call   f0101b25 <page_insert>
f0101f5b:	83 c4 10             	add    $0x10,%esp
f0101f5e:	85 c0                	test   %eax,%eax
f0101f60:	0f 89 77 07 00 00    	jns    f01026dd <check_page+0x83e>
	page_free(pp0);
f0101f66:	83 ec 0c             	sub    $0xc,%esp
f0101f69:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101f6c:	e8 ea f1 ff ff       	call   f010115b <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101f71:	6a 02                	push   $0x2
f0101f73:	6a 00                	push   $0x0
f0101f75:	56                   	push   %esi
f0101f76:	ff 35 8c fe 24 f0    	pushl  0xf024fe8c
f0101f7c:	e8 a4 fb ff ff       	call   f0101b25 <page_insert>
f0101f81:	83 c4 20             	add    $0x20,%esp
f0101f84:	85 c0                	test   %eax,%eax
f0101f86:	0f 85 6a 07 00 00    	jne    f01026f6 <check_page+0x857>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101f8c:	8b 3d 8c fe 24 f0    	mov    0xf024fe8c,%edi
f0101f92:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101f95:	e8 0b ec ff ff       	call   f0100ba5 <page2pa>
f0101f9a:	89 c2                	mov    %eax,%edx
f0101f9c:	8b 07                	mov    (%edi),%eax
f0101f9e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101fa3:	39 d0                	cmp    %edx,%eax
f0101fa5:	0f 85 64 07 00 00    	jne    f010270f <check_page+0x870>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101fab:	ba 00 00 00 00       	mov    $0x0,%edx
f0101fb0:	89 f8                	mov    %edi,%eax
f0101fb2:	e8 d2 ec ff ff       	call   f0100c89 <check_va2pa>
f0101fb7:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101fba:	89 f0                	mov    %esi,%eax
f0101fbc:	e8 e4 eb ff ff       	call   f0100ba5 <page2pa>
f0101fc1:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0101fc4:	0f 85 5e 07 00 00    	jne    f0102728 <check_page+0x889>
	assert(pp1->pp_ref == 1);
f0101fca:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101fcf:	0f 85 6c 07 00 00    	jne    f0102741 <check_page+0x8a2>
	assert(pp0->pp_ref == 1);
f0101fd5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101fd8:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101fdd:	0f 85 77 07 00 00    	jne    f010275a <check_page+0x8bb>
	assert(page_insert(kern_pgdir, pp2, (void *) PGSIZE, PTE_W) == 0);
f0101fe3:	6a 02                	push   $0x2
f0101fe5:	68 00 10 00 00       	push   $0x1000
f0101fea:	53                   	push   %ebx
f0101feb:	57                   	push   %edi
f0101fec:	e8 34 fb ff ff       	call   f0101b25 <page_insert>
f0101ff1:	83 c4 10             	add    $0x10,%esp
f0101ff4:	85 c0                	test   %eax,%eax
f0101ff6:	0f 85 77 07 00 00    	jne    f0102773 <check_page+0x8d4>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101ffc:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102001:	a1 8c fe 24 f0       	mov    0xf024fe8c,%eax
f0102006:	e8 7e ec ff ff       	call   f0100c89 <check_va2pa>
f010200b:	89 c7                	mov    %eax,%edi
f010200d:	89 d8                	mov    %ebx,%eax
f010200f:	e8 91 eb ff ff       	call   f0100ba5 <page2pa>
f0102014:	39 c7                	cmp    %eax,%edi
f0102016:	0f 85 70 07 00 00    	jne    f010278c <check_page+0x8ed>
	assert(pp2->pp_ref == 1);
f010201c:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102021:	0f 85 7e 07 00 00    	jne    f01027a5 <check_page+0x906>
	assert(!page_alloc(0));
f0102027:	83 ec 0c             	sub    $0xc,%esp
f010202a:	6a 00                	push   $0x0
f010202c:	e8 df f0 ff ff       	call   f0101110 <page_alloc>
f0102031:	83 c4 10             	add    $0x10,%esp
f0102034:	85 c0                	test   %eax,%eax
f0102036:	0f 85 82 07 00 00    	jne    f01027be <check_page+0x91f>
	assert(page_insert(kern_pgdir, pp2, (void *) PGSIZE, PTE_W) == 0);
f010203c:	6a 02                	push   $0x2
f010203e:	68 00 10 00 00       	push   $0x1000
f0102043:	53                   	push   %ebx
f0102044:	ff 35 8c fe 24 f0    	pushl  0xf024fe8c
f010204a:	e8 d6 fa ff ff       	call   f0101b25 <page_insert>
f010204f:	83 c4 10             	add    $0x10,%esp
f0102052:	85 c0                	test   %eax,%eax
f0102054:	0f 85 7d 07 00 00    	jne    f01027d7 <check_page+0x938>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010205a:	ba 00 10 00 00       	mov    $0x1000,%edx
f010205f:	a1 8c fe 24 f0       	mov    0xf024fe8c,%eax
f0102064:	e8 20 ec ff ff       	call   f0100c89 <check_va2pa>
f0102069:	89 c7                	mov    %eax,%edi
f010206b:	89 d8                	mov    %ebx,%eax
f010206d:	e8 33 eb ff ff       	call   f0100ba5 <page2pa>
f0102072:	39 c7                	cmp    %eax,%edi
f0102074:	0f 85 76 07 00 00    	jne    f01027f0 <check_page+0x951>
	assert(pp2->pp_ref == 1);
f010207a:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010207f:	0f 85 84 07 00 00    	jne    f0102809 <check_page+0x96a>
	assert(!page_alloc(0));
f0102085:	83 ec 0c             	sub    $0xc,%esp
f0102088:	6a 00                	push   $0x0
f010208a:	e8 81 f0 ff ff       	call   f0101110 <page_alloc>
f010208f:	83 c4 10             	add    $0x10,%esp
f0102092:	85 c0                	test   %eax,%eax
f0102094:	0f 85 88 07 00 00    	jne    f0102822 <check_page+0x983>
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f010209a:	8b 3d 8c fe 24 f0    	mov    0xf024fe8c,%edi
f01020a0:	8b 0f                	mov    (%edi),%ecx
f01020a2:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f01020a8:	ba 18 04 00 00       	mov    $0x418,%edx
f01020ad:	b8 2b 76 10 f0       	mov    $0xf010762b,%eax
f01020b2:	e8 88 eb ff ff       	call   f0100c3f <_kaddr>
f01020b7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void *) PGSIZE, 0) == ptep + PTX(PGSIZE));
f01020ba:	83 ec 04             	sub    $0x4,%esp
f01020bd:	6a 00                	push   $0x0
f01020bf:	68 00 10 00 00       	push   $0x1000
f01020c4:	57                   	push   %edi
f01020c5:	e8 54 f5 ff ff       	call   f010161e <pgdir_walk>
f01020ca:	89 c2                	mov    %eax,%edx
f01020cc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01020cf:	83 c0 04             	add    $0x4,%eax
f01020d2:	83 c4 10             	add    $0x10,%esp
f01020d5:	39 d0                	cmp    %edx,%eax
f01020d7:	0f 85 5e 07 00 00    	jne    f010283b <check_page+0x99c>
	assert(page_insert(kern_pgdir, pp2, (void *) PGSIZE, PTE_W | PTE_U) == 0);
f01020dd:	6a 06                	push   $0x6
f01020df:	68 00 10 00 00       	push   $0x1000
f01020e4:	53                   	push   %ebx
f01020e5:	ff 35 8c fe 24 f0    	pushl  0xf024fe8c
f01020eb:	e8 35 fa ff ff       	call   f0101b25 <page_insert>
f01020f0:	83 c4 10             	add    $0x10,%esp
f01020f3:	85 c0                	test   %eax,%eax
f01020f5:	0f 85 59 07 00 00    	jne    f0102854 <check_page+0x9b5>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01020fb:	8b 3d 8c fe 24 f0    	mov    0xf024fe8c,%edi
f0102101:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102106:	89 f8                	mov    %edi,%eax
f0102108:	e8 7c eb ff ff       	call   f0100c89 <check_va2pa>
f010210d:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102110:	89 d8                	mov    %ebx,%eax
f0102112:	e8 8e ea ff ff       	call   f0100ba5 <page2pa>
f0102117:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f010211a:	0f 85 4d 07 00 00    	jne    f010286d <check_page+0x9ce>
	assert(pp2->pp_ref == 1);
f0102120:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102125:	0f 85 5b 07 00 00    	jne    f0102886 <check_page+0x9e7>
	assert(*pgdir_walk(kern_pgdir, (void *) PGSIZE, 0) & PTE_U);
f010212b:	83 ec 04             	sub    $0x4,%esp
f010212e:	6a 00                	push   $0x0
f0102130:	68 00 10 00 00       	push   $0x1000
f0102135:	57                   	push   %edi
f0102136:	e8 e3 f4 ff ff       	call   f010161e <pgdir_walk>
f010213b:	83 c4 10             	add    $0x10,%esp
f010213e:	f6 00 04             	testb  $0x4,(%eax)
f0102141:	0f 84 58 07 00 00    	je     f010289f <check_page+0xa00>
	assert(kern_pgdir[0] & PTE_U);
f0102147:	a1 8c fe 24 f0       	mov    0xf024fe8c,%eax
f010214c:	f6 00 04             	testb  $0x4,(%eax)
f010214f:	0f 84 63 07 00 00    	je     f01028b8 <check_page+0xa19>
	assert(page_insert(kern_pgdir, pp2, (void *) PGSIZE, PTE_W) == 0);
f0102155:	6a 02                	push   $0x2
f0102157:	68 00 10 00 00       	push   $0x1000
f010215c:	53                   	push   %ebx
f010215d:	50                   	push   %eax
f010215e:	e8 c2 f9 ff ff       	call   f0101b25 <page_insert>
f0102163:	83 c4 10             	add    $0x10,%esp
f0102166:	85 c0                	test   %eax,%eax
f0102168:	0f 85 63 07 00 00    	jne    f01028d1 <check_page+0xa32>
	assert(*pgdir_walk(kern_pgdir, (void *) PGSIZE, 0) & PTE_W);
f010216e:	83 ec 04             	sub    $0x4,%esp
f0102171:	6a 00                	push   $0x0
f0102173:	68 00 10 00 00       	push   $0x1000
f0102178:	ff 35 8c fe 24 f0    	pushl  0xf024fe8c
f010217e:	e8 9b f4 ff ff       	call   f010161e <pgdir_walk>
f0102183:	83 c4 10             	add    $0x10,%esp
f0102186:	f6 00 02             	testb  $0x2,(%eax)
f0102189:	0f 84 5b 07 00 00    	je     f01028ea <check_page+0xa4b>
	assert(!(*pgdir_walk(kern_pgdir, (void *) PGSIZE, 0) & PTE_U));
f010218f:	83 ec 04             	sub    $0x4,%esp
f0102192:	6a 00                	push   $0x0
f0102194:	68 00 10 00 00       	push   $0x1000
f0102199:	ff 35 8c fe 24 f0    	pushl  0xf024fe8c
f010219f:	e8 7a f4 ff ff       	call   f010161e <pgdir_walk>
f01021a4:	83 c4 10             	add    $0x10,%esp
f01021a7:	f6 00 04             	testb  $0x4,(%eax)
f01021aa:	0f 85 53 07 00 00    	jne    f0102903 <check_page+0xa64>
	assert(page_insert(kern_pgdir, pp0, (void *) PTSIZE, PTE_W) < 0);
f01021b0:	6a 02                	push   $0x2
f01021b2:	68 00 00 40 00       	push   $0x400000
f01021b7:	ff 75 d4             	pushl  -0x2c(%ebp)
f01021ba:	ff 35 8c fe 24 f0    	pushl  0xf024fe8c
f01021c0:	e8 60 f9 ff ff       	call   f0101b25 <page_insert>
f01021c5:	83 c4 10             	add    $0x10,%esp
f01021c8:	85 c0                	test   %eax,%eax
f01021ca:	0f 89 4c 07 00 00    	jns    f010291c <check_page+0xa7d>
	assert(page_insert(kern_pgdir, pp1, (void *) PGSIZE, PTE_W) == 0);
f01021d0:	6a 02                	push   $0x2
f01021d2:	68 00 10 00 00       	push   $0x1000
f01021d7:	56                   	push   %esi
f01021d8:	ff 35 8c fe 24 f0    	pushl  0xf024fe8c
f01021de:	e8 42 f9 ff ff       	call   f0101b25 <page_insert>
f01021e3:	83 c4 10             	add    $0x10,%esp
f01021e6:	85 c0                	test   %eax,%eax
f01021e8:	0f 85 47 07 00 00    	jne    f0102935 <check_page+0xa96>
	assert(!(*pgdir_walk(kern_pgdir, (void *) PGSIZE, 0) & PTE_U));
f01021ee:	83 ec 04             	sub    $0x4,%esp
f01021f1:	6a 00                	push   $0x0
f01021f3:	68 00 10 00 00       	push   $0x1000
f01021f8:	ff 35 8c fe 24 f0    	pushl  0xf024fe8c
f01021fe:	e8 1b f4 ff ff       	call   f010161e <pgdir_walk>
f0102203:	83 c4 10             	add    $0x10,%esp
f0102206:	f6 00 04             	testb  $0x4,(%eax)
f0102209:	0f 85 3f 07 00 00    	jne    f010294e <check_page+0xaaf>
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f010220f:	8b 3d 8c fe 24 f0    	mov    0xf024fe8c,%edi
f0102215:	ba 00 00 00 00       	mov    $0x0,%edx
f010221a:	89 f8                	mov    %edi,%eax
f010221c:	e8 68 ea ff ff       	call   f0100c89 <check_va2pa>
f0102221:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102224:	89 f0                	mov    %esi,%eax
f0102226:	e8 7a e9 ff ff       	call   f0100ba5 <page2pa>
f010222b:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010222e:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0102231:	0f 85 30 07 00 00    	jne    f0102967 <check_page+0xac8>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102237:	ba 00 10 00 00       	mov    $0x1000,%edx
f010223c:	89 f8                	mov    %edi,%eax
f010223e:	e8 46 ea ff ff       	call   f0100c89 <check_va2pa>
f0102243:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0102246:	0f 85 34 07 00 00    	jne    f0102980 <check_page+0xae1>
	assert(pp1->pp_ref == 2);
f010224c:	66 83 7e 04 02       	cmpw   $0x2,0x4(%esi)
f0102251:	0f 85 42 07 00 00    	jne    f0102999 <check_page+0xafa>
	assert(pp2->pp_ref == 0);
f0102257:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010225c:	0f 85 50 07 00 00    	jne    f01029b2 <check_page+0xb13>
	assert((pp = page_alloc(0)) && pp == pp2);
f0102262:	83 ec 0c             	sub    $0xc,%esp
f0102265:	6a 00                	push   $0x0
f0102267:	e8 a4 ee ff ff       	call   f0101110 <page_alloc>
f010226c:	83 c4 10             	add    $0x10,%esp
f010226f:	39 c3                	cmp    %eax,%ebx
f0102271:	0f 85 54 07 00 00    	jne    f01029cb <check_page+0xb2c>
f0102277:	85 c0                	test   %eax,%eax
f0102279:	0f 84 4c 07 00 00    	je     f01029cb <check_page+0xb2c>
	page_remove(kern_pgdir, 0x0);
f010227f:	83 ec 08             	sub    $0x8,%esp
f0102282:	6a 00                	push   $0x0
f0102284:	ff 35 8c fe 24 f0    	pushl  0xf024fe8c
f010228a:	e8 44 f8 ff ff       	call   f0101ad3 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010228f:	8b 3d 8c fe 24 f0    	mov    0xf024fe8c,%edi
f0102295:	ba 00 00 00 00       	mov    $0x0,%edx
f010229a:	89 f8                	mov    %edi,%eax
f010229c:	e8 e8 e9 ff ff       	call   f0100c89 <check_va2pa>
f01022a1:	83 c4 10             	add    $0x10,%esp
f01022a4:	83 f8 ff             	cmp    $0xffffffff,%eax
f01022a7:	0f 85 37 07 00 00    	jne    f01029e4 <check_page+0xb45>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01022ad:	ba 00 10 00 00       	mov    $0x1000,%edx
f01022b2:	89 f8                	mov    %edi,%eax
f01022b4:	e8 d0 e9 ff ff       	call   f0100c89 <check_va2pa>
f01022b9:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01022bc:	89 f0                	mov    %esi,%eax
f01022be:	e8 e2 e8 ff ff       	call   f0100ba5 <page2pa>
f01022c3:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f01022c6:	0f 85 31 07 00 00    	jne    f01029fd <check_page+0xb5e>
	assert(pp1->pp_ref == 1);
f01022cc:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01022d1:	0f 85 3f 07 00 00    	jne    f0102a16 <check_page+0xb77>
	assert(pp2->pp_ref == 0);
f01022d7:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01022dc:	0f 85 4d 07 00 00    	jne    f0102a2f <check_page+0xb90>
	assert(page_insert(kern_pgdir, pp1, (void *) PGSIZE, 0) == 0);
f01022e2:	6a 00                	push   $0x0
f01022e4:	68 00 10 00 00       	push   $0x1000
f01022e9:	56                   	push   %esi
f01022ea:	57                   	push   %edi
f01022eb:	e8 35 f8 ff ff       	call   f0101b25 <page_insert>
f01022f0:	83 c4 10             	add    $0x10,%esp
f01022f3:	85 c0                	test   %eax,%eax
f01022f5:	0f 85 4d 07 00 00    	jne    f0102a48 <check_page+0xba9>
	assert(pp1->pp_ref);
f01022fb:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102300:	0f 84 5b 07 00 00    	je     f0102a61 <check_page+0xbc2>
	assert(pp1->pp_link == NULL);
f0102306:	83 3e 00             	cmpl   $0x0,(%esi)
f0102309:	0f 85 6b 07 00 00    	jne    f0102a7a <check_page+0xbdb>
	page_remove(kern_pgdir, (void *) PGSIZE);
f010230f:	83 ec 08             	sub    $0x8,%esp
f0102312:	68 00 10 00 00       	push   $0x1000
f0102317:	ff 35 8c fe 24 f0    	pushl  0xf024fe8c
f010231d:	e8 b1 f7 ff ff       	call   f0101ad3 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102322:	8b 3d 8c fe 24 f0    	mov    0xf024fe8c,%edi
f0102328:	ba 00 00 00 00       	mov    $0x0,%edx
f010232d:	89 f8                	mov    %edi,%eax
f010232f:	e8 55 e9 ff ff       	call   f0100c89 <check_va2pa>
f0102334:	83 c4 10             	add    $0x10,%esp
f0102337:	83 f8 ff             	cmp    $0xffffffff,%eax
f010233a:	0f 85 53 07 00 00    	jne    f0102a93 <check_page+0xbf4>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102340:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102345:	89 f8                	mov    %edi,%eax
f0102347:	e8 3d e9 ff ff       	call   f0100c89 <check_va2pa>
f010234c:	83 f8 ff             	cmp    $0xffffffff,%eax
f010234f:	0f 85 57 07 00 00    	jne    f0102aac <check_page+0xc0d>
	assert(pp1->pp_ref == 0);
f0102355:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010235a:	0f 85 65 07 00 00    	jne    f0102ac5 <check_page+0xc26>
	assert(pp2->pp_ref == 0);
f0102360:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102365:	0f 85 73 07 00 00    	jne    f0102ade <check_page+0xc3f>
	assert((pp = page_alloc(0)) && pp == pp1);
f010236b:	83 ec 0c             	sub    $0xc,%esp
f010236e:	6a 00                	push   $0x0
f0102370:	e8 9b ed ff ff       	call   f0101110 <page_alloc>
f0102375:	83 c4 10             	add    $0x10,%esp
f0102378:	39 c6                	cmp    %eax,%esi
f010237a:	0f 85 77 07 00 00    	jne    f0102af7 <check_page+0xc58>
f0102380:	85 c0                	test   %eax,%eax
f0102382:	0f 84 6f 07 00 00    	je     f0102af7 <check_page+0xc58>
	assert(!page_alloc(0));
f0102388:	83 ec 0c             	sub    $0xc,%esp
f010238b:	6a 00                	push   $0x0
f010238d:	e8 7e ed ff ff       	call   f0101110 <page_alloc>
f0102392:	83 c4 10             	add    $0x10,%esp
f0102395:	85 c0                	test   %eax,%eax
f0102397:	0f 85 73 07 00 00    	jne    f0102b10 <check_page+0xc71>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010239d:	8b 3d 8c fe 24 f0    	mov    0xf024fe8c,%edi
f01023a3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01023a6:	e8 fa e7 ff ff       	call   f0100ba5 <page2pa>
f01023ab:	89 c2                	mov    %eax,%edx
f01023ad:	8b 07                	mov    (%edi),%eax
f01023af:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01023b4:	39 d0                	cmp    %edx,%eax
f01023b6:	0f 85 6d 07 00 00    	jne    f0102b29 <check_page+0xc8a>
	kern_pgdir[0] = 0;
f01023bc:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
	assert(pp0->pp_ref == 1);
f01023c2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01023c5:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f01023ca:	0f 85 72 07 00 00    	jne    f0102b42 <check_page+0xca3>
	pp0->pp_ref = 0;
f01023d0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01023d3:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
	page_free(pp0);
f01023d9:	83 ec 0c             	sub    $0xc,%esp
f01023dc:	50                   	push   %eax
f01023dd:	e8 79 ed ff ff       	call   f010115b <page_free>
	ptep = pgdir_walk(kern_pgdir, va, 1);
f01023e2:	83 c4 0c             	add    $0xc,%esp
f01023e5:	6a 01                	push   $0x1
f01023e7:	68 00 10 40 00       	push   $0x401000
f01023ec:	ff 35 8c fe 24 f0    	pushl  0xf024fe8c
f01023f2:	e8 27 f2 ff ff       	call   f010161e <pgdir_walk>
f01023f7:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01023fa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f01023fd:	8b 3d 8c fe 24 f0    	mov    0xf024fe8c,%edi
f0102403:	8b 4f 04             	mov    0x4(%edi),%ecx
f0102406:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f010240c:	ba 5c 04 00 00       	mov    $0x45c,%edx
f0102411:	b8 2b 76 10 f0       	mov    $0xf010762b,%eax
f0102416:	e8 24 e8 ff ff       	call   f0100c3f <_kaddr>
	assert(ptep == ptep1 + PTX(va));
f010241b:	83 c0 04             	add    $0x4,%eax
f010241e:	83 c4 10             	add    $0x10,%esp
f0102421:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0102424:	0f 85 31 07 00 00    	jne    f0102b5b <check_page+0xcbc>
	kern_pgdir[PDX(va)] = 0;
f010242a:	c7 47 04 00 00 00 00 	movl   $0x0,0x4(%edi)
	pp0->pp_ref = 0;
f0102431:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102434:	89 f8                	mov    %edi,%eax
f0102436:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
	memset(page2kva(pp0), 0xFF, PGSIZE);
f010243c:	e8 2a e8 ff ff       	call   f0100c6b <page2kva>
f0102441:	83 ec 04             	sub    $0x4,%esp
f0102444:	68 00 10 00 00       	push   $0x1000
f0102449:	68 ff 00 00 00       	push   $0xff
f010244e:	50                   	push   %eax
f010244f:	e8 11 35 00 00       	call   f0105965 <memset>
	page_free(pp0);
f0102454:	89 3c 24             	mov    %edi,(%esp)
f0102457:	e8 ff ec ff ff       	call   f010115b <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f010245c:	83 c4 0c             	add    $0xc,%esp
f010245f:	6a 01                	push   $0x1
f0102461:	6a 00                	push   $0x0
f0102463:	ff 35 8c fe 24 f0    	pushl  0xf024fe8c
f0102469:	e8 b0 f1 ff ff       	call   f010161e <pgdir_walk>
	ptep = (pte_t *) page2kva(pp0);
f010246e:	89 f8                	mov    %edi,%eax
f0102470:	e8 f6 e7 ff ff       	call   f0100c6b <page2kva>
f0102475:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102478:	89 c2                	mov    %eax,%edx
f010247a:	05 00 10 00 00       	add    $0x1000,%eax
f010247f:	83 c4 10             	add    $0x10,%esp
		assert((ptep[i] & PTE_P) == 0);
f0102482:	f6 02 01             	testb  $0x1,(%edx)
f0102485:	0f 85 e9 06 00 00    	jne    f0102b74 <check_page+0xcd5>
f010248b:	83 c2 04             	add    $0x4,%edx
	for (i = 0; i < NPTENTRIES; i++)
f010248e:	39 c2                	cmp    %eax,%edx
f0102490:	75 f0                	jne    f0102482 <check_page+0x5e3>
	kern_pgdir[0] = 0;
f0102492:	a1 8c fe 24 f0       	mov    0xf024fe8c,%eax
f0102497:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f010249d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01024a0:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
	page_free_list = fl;
f01024a6:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f01024a9:	89 0d 40 e2 24 f0    	mov    %ecx,0xf024e240
	page_free(pp0);
f01024af:	83 ec 0c             	sub    $0xc,%esp
f01024b2:	50                   	push   %eax
f01024b3:	e8 a3 ec ff ff       	call   f010115b <page_free>
	page_free(pp1);
f01024b8:	89 34 24             	mov    %esi,(%esp)
f01024bb:	e8 9b ec ff ff       	call   f010115b <page_free>
	page_free(pp2);
f01024c0:	89 1c 24             	mov    %ebx,(%esp)
f01024c3:	e8 93 ec ff ff       	call   f010115b <page_free>
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f01024c8:	83 c4 08             	add    $0x8,%esp
f01024cb:	68 01 10 00 00       	push   $0x1001
f01024d0:	6a 00                	push   $0x0
f01024d2:	e8 61 f9 ff ff       	call   f0101e38 <mmio_map_region>
f01024d7:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f01024d9:	83 c4 08             	add    $0x8,%esp
f01024dc:	68 00 10 00 00       	push   $0x1000
f01024e1:	6a 00                	push   $0x0
f01024e3:	e8 50 f9 ff ff       	call   f0101e38 <mmio_map_region>
f01024e8:	89 c6                	mov    %eax,%esi
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f01024ea:	8d 83 a0 1f 00 00    	lea    0x1fa0(%ebx),%eax
f01024f0:	83 c4 10             	add    $0x10,%esp
f01024f3:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f01024f9:	0f 86 8e 06 00 00    	jbe    f0102b8d <check_page+0xcee>
f01024ff:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0102504:	0f 87 83 06 00 00    	ja     f0102b8d <check_page+0xcee>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f010250a:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f0102510:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f0102516:	0f 87 8a 06 00 00    	ja     f0102ba6 <check_page+0xd07>
f010251c:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0102522:	0f 86 7e 06 00 00    	jbe    f0102ba6 <check_page+0xd07>
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0102528:	89 da                	mov    %ebx,%edx
f010252a:	09 f2                	or     %esi,%edx
f010252c:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0102532:	0f 85 87 06 00 00    	jne    f0102bbf <check_page+0xd20>
	assert(mm1 + 8096 <= mm2);
f0102538:	39 f0                	cmp    %esi,%eax
f010253a:	0f 87 98 06 00 00    	ja     f0102bd8 <check_page+0xd39>
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0102540:	8b 3d 8c fe 24 f0    	mov    0xf024fe8c,%edi
f0102546:	89 da                	mov    %ebx,%edx
f0102548:	89 f8                	mov    %edi,%eax
f010254a:	e8 3a e7 ff ff       	call   f0100c89 <check_va2pa>
f010254f:	85 c0                	test   %eax,%eax
f0102551:	0f 85 9a 06 00 00    	jne    f0102bf1 <check_page+0xd52>
	assert(check_va2pa(kern_pgdir, mm1 + PGSIZE) == PGSIZE);
f0102557:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f010255d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102560:	89 c2                	mov    %eax,%edx
f0102562:	89 f8                	mov    %edi,%eax
f0102564:	e8 20 e7 ff ff       	call   f0100c89 <check_va2pa>
f0102569:	3d 00 10 00 00       	cmp    $0x1000,%eax
f010256e:	0f 85 96 06 00 00    	jne    f0102c0a <check_page+0xd6b>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0102574:	89 f2                	mov    %esi,%edx
f0102576:	89 f8                	mov    %edi,%eax
f0102578:	e8 0c e7 ff ff       	call   f0100c89 <check_va2pa>
f010257d:	85 c0                	test   %eax,%eax
f010257f:	0f 85 9e 06 00 00    	jne    f0102c23 <check_page+0xd84>
	assert(check_va2pa(kern_pgdir, mm2 + PGSIZE) == ~0);
f0102585:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f010258b:	89 f8                	mov    %edi,%eax
f010258d:	e8 f7 e6 ff ff       	call   f0100c89 <check_va2pa>
f0102592:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102595:	0f 85 a1 06 00 00    	jne    f0102c3c <check_page+0xd9d>
	assert(*pgdir_walk(kern_pgdir, (void *) mm1, 0) &
f010259b:	83 ec 04             	sub    $0x4,%esp
f010259e:	6a 00                	push   $0x0
f01025a0:	53                   	push   %ebx
f01025a1:	57                   	push   %edi
f01025a2:	e8 77 f0 ff ff       	call   f010161e <pgdir_walk>
f01025a7:	83 c4 10             	add    $0x10,%esp
f01025aa:	f6 00 1a             	testb  $0x1a,(%eax)
f01025ad:	0f 84 a2 06 00 00    	je     f0102c55 <check_page+0xdb6>
	assert(!(*pgdir_walk(kern_pgdir, (void *) mm1, 0) & PTE_U));
f01025b3:	83 ec 04             	sub    $0x4,%esp
f01025b6:	6a 00                	push   $0x0
f01025b8:	53                   	push   %ebx
f01025b9:	ff 35 8c fe 24 f0    	pushl  0xf024fe8c
f01025bf:	e8 5a f0 ff ff       	call   f010161e <pgdir_walk>
f01025c4:	83 c4 10             	add    $0x10,%esp
f01025c7:	f6 00 04             	testb  $0x4,(%eax)
f01025ca:	0f 85 9e 06 00 00    	jne    f0102c6e <check_page+0xdcf>
	*pgdir_walk(kern_pgdir, (void *) mm1, 0) = 0;
f01025d0:	83 ec 04             	sub    $0x4,%esp
f01025d3:	6a 00                	push   $0x0
f01025d5:	53                   	push   %ebx
f01025d6:	ff 35 8c fe 24 f0    	pushl  0xf024fe8c
f01025dc:	e8 3d f0 ff ff       	call   f010161e <pgdir_walk>
f01025e1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void *) mm1 + PGSIZE, 0) = 0;
f01025e7:	83 c4 0c             	add    $0xc,%esp
f01025ea:	6a 00                	push   $0x0
f01025ec:	ff 75 d4             	pushl  -0x2c(%ebp)
f01025ef:	ff 35 8c fe 24 f0    	pushl  0xf024fe8c
f01025f5:	e8 24 f0 ff ff       	call   f010161e <pgdir_walk>
f01025fa:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void *) mm2, 0) = 0;
f0102600:	83 c4 0c             	add    $0xc,%esp
f0102603:	6a 00                	push   $0x0
f0102605:	56                   	push   %esi
f0102606:	ff 35 8c fe 24 f0    	pushl  0xf024fe8c
f010260c:	e8 0d f0 ff ff       	call   f010161e <pgdir_walk>
f0102611:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	cprintf("check_page() succeeded!\n");
f0102617:	c7 04 24 e7 78 10 f0 	movl   $0xf01078e7,(%esp)
f010261e:	e8 0a 13 00 00       	call   f010392d <cprintf>
}
f0102623:	83 c4 10             	add    $0x10,%esp
f0102626:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102629:	5b                   	pop    %ebx
f010262a:	5e                   	pop    %esi
f010262b:	5f                   	pop    %edi
f010262c:	5d                   	pop    %ebp
f010262d:	c3                   	ret    
	assert((pp0 = page_alloc(0)));
f010262e:	68 0b 77 10 f0       	push   $0xf010770b
f0102633:	68 43 76 10 f0       	push   $0xf0107643
f0102638:	68 e8 03 00 00       	push   $0x3e8
f010263d:	68 2b 76 10 f0       	push   $0xf010762b
f0102642:	e8 23 da ff ff       	call   f010006a <_panic>
	assert((pp1 = page_alloc(0)));
f0102647:	68 21 77 10 f0       	push   $0xf0107721
f010264c:	68 43 76 10 f0       	push   $0xf0107643
f0102651:	68 e9 03 00 00       	push   $0x3e9
f0102656:	68 2b 76 10 f0       	push   $0xf010762b
f010265b:	e8 0a da ff ff       	call   f010006a <_panic>
	assert((pp2 = page_alloc(0)));
f0102660:	68 37 77 10 f0       	push   $0xf0107737
f0102665:	68 43 76 10 f0       	push   $0xf0107643
f010266a:	68 ea 03 00 00       	push   $0x3ea
f010266f:	68 2b 76 10 f0       	push   $0xf010762b
f0102674:	e8 f1 d9 ff ff       	call   f010006a <_panic>
	assert(pp1 && pp1 != pp0);
f0102679:	68 4d 77 10 f0       	push   $0xf010774d
f010267e:	68 43 76 10 f0       	push   $0xf0107643
f0102683:	68 ed 03 00 00       	push   $0x3ed
f0102688:	68 2b 76 10 f0       	push   $0xf010762b
f010268d:	e8 d8 d9 ff ff       	call   f010006a <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0102692:	68 b0 6d 10 f0       	push   $0xf0106db0
f0102697:	68 43 76 10 f0       	push   $0xf0107643
f010269c:	68 ee 03 00 00       	push   $0x3ee
f01026a1:	68 2b 76 10 f0       	push   $0xf010762b
f01026a6:	e8 bf d9 ff ff       	call   f010006a <_panic>
	assert(!page_alloc(0));
f01026ab:	68 5f 77 10 f0       	push   $0xf010775f
f01026b0:	68 43 76 10 f0       	push   $0xf0107643
f01026b5:	68 f5 03 00 00       	push   $0x3f5
f01026ba:	68 2b 76 10 f0       	push   $0xf010762b
f01026bf:	e8 a6 d9 ff ff       	call   f010006a <_panic>
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f01026c4:	68 54 70 10 f0       	push   $0xf0107054
f01026c9:	68 43 76 10 f0       	push   $0xf0107643
f01026ce:	68 f8 03 00 00       	push   $0x3f8
f01026d3:	68 2b 76 10 f0       	push   $0xf010762b
f01026d8:	e8 8d d9 ff ff       	call   f010006a <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01026dd:	68 8c 70 10 f0       	push   $0xf010708c
f01026e2:	68 43 76 10 f0       	push   $0xf0107643
f01026e7:	68 fb 03 00 00       	push   $0x3fb
f01026ec:	68 2b 76 10 f0       	push   $0xf010762b
f01026f1:	e8 74 d9 ff ff       	call   f010006a <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f01026f6:	68 bc 70 10 f0       	push   $0xf01070bc
f01026fb:	68 43 76 10 f0       	push   $0xf0107643
f0102700:	68 ff 03 00 00       	push   $0x3ff
f0102705:	68 2b 76 10 f0       	push   $0xf010762b
f010270a:	e8 5b d9 ff ff       	call   f010006a <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010270f:	68 00 70 10 f0       	push   $0xf0107000
f0102714:	68 43 76 10 f0       	push   $0xf0107643
f0102719:	68 00 04 00 00       	push   $0x400
f010271e:	68 2b 76 10 f0       	push   $0xf010762b
f0102723:	e8 42 d9 ff ff       	call   f010006a <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0102728:	68 ec 70 10 f0       	push   $0xf01070ec
f010272d:	68 43 76 10 f0       	push   $0xf0107643
f0102732:	68 01 04 00 00       	push   $0x401
f0102737:	68 2b 76 10 f0       	push   $0xf010762b
f010273c:	e8 29 d9 ff ff       	call   f010006a <_panic>
	assert(pp1->pp_ref == 1);
f0102741:	68 f8 77 10 f0       	push   $0xf01077f8
f0102746:	68 43 76 10 f0       	push   $0xf0107643
f010274b:	68 02 04 00 00       	push   $0x402
f0102750:	68 2b 76 10 f0       	push   $0xf010762b
f0102755:	e8 10 d9 ff ff       	call   f010006a <_panic>
	assert(pp0->pp_ref == 1);
f010275a:	68 3c 78 10 f0       	push   $0xf010783c
f010275f:	68 43 76 10 f0       	push   $0xf0107643
f0102764:	68 03 04 00 00       	push   $0x403
f0102769:	68 2b 76 10 f0       	push   $0xf010762b
f010276e:	e8 f7 d8 ff ff       	call   f010006a <_panic>
	assert(page_insert(kern_pgdir, pp2, (void *) PGSIZE, PTE_W) == 0);
f0102773:	68 1c 71 10 f0       	push   $0xf010711c
f0102778:	68 43 76 10 f0       	push   $0xf0107643
f010277d:	68 07 04 00 00       	push   $0x407
f0102782:	68 2b 76 10 f0       	push   $0xf010762b
f0102787:	e8 de d8 ff ff       	call   f010006a <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010278c:	68 58 71 10 f0       	push   $0xf0107158
f0102791:	68 43 76 10 f0       	push   $0xf0107643
f0102796:	68 08 04 00 00       	push   $0x408
f010279b:	68 2b 76 10 f0       	push   $0xf010762b
f01027a0:	e8 c5 d8 ff ff       	call   f010006a <_panic>
	assert(pp2->pp_ref == 1);
f01027a5:	68 09 78 10 f0       	push   $0xf0107809
f01027aa:	68 43 76 10 f0       	push   $0xf0107643
f01027af:	68 09 04 00 00       	push   $0x409
f01027b4:	68 2b 76 10 f0       	push   $0xf010762b
f01027b9:	e8 ac d8 ff ff       	call   f010006a <_panic>
	assert(!page_alloc(0));
f01027be:	68 5f 77 10 f0       	push   $0xf010775f
f01027c3:	68 43 76 10 f0       	push   $0xf0107643
f01027c8:	68 0c 04 00 00       	push   $0x40c
f01027cd:	68 2b 76 10 f0       	push   $0xf010762b
f01027d2:	e8 93 d8 ff ff       	call   f010006a <_panic>
	assert(page_insert(kern_pgdir, pp2, (void *) PGSIZE, PTE_W) == 0);
f01027d7:	68 1c 71 10 f0       	push   $0xf010711c
f01027dc:	68 43 76 10 f0       	push   $0xf0107643
f01027e1:	68 0f 04 00 00       	push   $0x40f
f01027e6:	68 2b 76 10 f0       	push   $0xf010762b
f01027eb:	e8 7a d8 ff ff       	call   f010006a <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01027f0:	68 58 71 10 f0       	push   $0xf0107158
f01027f5:	68 43 76 10 f0       	push   $0xf0107643
f01027fa:	68 10 04 00 00       	push   $0x410
f01027ff:	68 2b 76 10 f0       	push   $0xf010762b
f0102804:	e8 61 d8 ff ff       	call   f010006a <_panic>
	assert(pp2->pp_ref == 1);
f0102809:	68 09 78 10 f0       	push   $0xf0107809
f010280e:	68 43 76 10 f0       	push   $0xf0107643
f0102813:	68 11 04 00 00       	push   $0x411
f0102818:	68 2b 76 10 f0       	push   $0xf010762b
f010281d:	e8 48 d8 ff ff       	call   f010006a <_panic>
	assert(!page_alloc(0));
f0102822:	68 5f 77 10 f0       	push   $0xf010775f
f0102827:	68 43 76 10 f0       	push   $0xf0107643
f010282c:	68 15 04 00 00       	push   $0x415
f0102831:	68 2b 76 10 f0       	push   $0xf010762b
f0102836:	e8 2f d8 ff ff       	call   f010006a <_panic>
	assert(pgdir_walk(kern_pgdir, (void *) PGSIZE, 0) == ptep + PTX(PGSIZE));
f010283b:	68 88 71 10 f0       	push   $0xf0107188
f0102840:	68 43 76 10 f0       	push   $0xf0107643
f0102845:	68 19 04 00 00       	push   $0x419
f010284a:	68 2b 76 10 f0       	push   $0xf010762b
f010284f:	e8 16 d8 ff ff       	call   f010006a <_panic>
	assert(page_insert(kern_pgdir, pp2, (void *) PGSIZE, PTE_W | PTE_U) == 0);
f0102854:	68 cc 71 10 f0       	push   $0xf01071cc
f0102859:	68 43 76 10 f0       	push   $0xf0107643
f010285e:	68 1c 04 00 00       	push   $0x41c
f0102863:	68 2b 76 10 f0       	push   $0xf010762b
f0102868:	e8 fd d7 ff ff       	call   f010006a <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010286d:	68 58 71 10 f0       	push   $0xf0107158
f0102872:	68 43 76 10 f0       	push   $0xf0107643
f0102877:	68 1d 04 00 00       	push   $0x41d
f010287c:	68 2b 76 10 f0       	push   $0xf010762b
f0102881:	e8 e4 d7 ff ff       	call   f010006a <_panic>
	assert(pp2->pp_ref == 1);
f0102886:	68 09 78 10 f0       	push   $0xf0107809
f010288b:	68 43 76 10 f0       	push   $0xf0107643
f0102890:	68 1e 04 00 00       	push   $0x41e
f0102895:	68 2b 76 10 f0       	push   $0xf010762b
f010289a:	e8 cb d7 ff ff       	call   f010006a <_panic>
	assert(*pgdir_walk(kern_pgdir, (void *) PGSIZE, 0) & PTE_U);
f010289f:	68 10 72 10 f0       	push   $0xf0107210
f01028a4:	68 43 76 10 f0       	push   $0xf0107643
f01028a9:	68 1f 04 00 00       	push   $0x41f
f01028ae:	68 2b 76 10 f0       	push   $0xf010762b
f01028b3:	e8 b2 d7 ff ff       	call   f010006a <_panic>
	assert(kern_pgdir[0] & PTE_U);
f01028b8:	68 5e 78 10 f0       	push   $0xf010785e
f01028bd:	68 43 76 10 f0       	push   $0xf0107643
f01028c2:	68 20 04 00 00       	push   $0x420
f01028c7:	68 2b 76 10 f0       	push   $0xf010762b
f01028cc:	e8 99 d7 ff ff       	call   f010006a <_panic>
	assert(page_insert(kern_pgdir, pp2, (void *) PGSIZE, PTE_W) == 0);
f01028d1:	68 1c 71 10 f0       	push   $0xf010711c
f01028d6:	68 43 76 10 f0       	push   $0xf0107643
f01028db:	68 23 04 00 00       	push   $0x423
f01028e0:	68 2b 76 10 f0       	push   $0xf010762b
f01028e5:	e8 80 d7 ff ff       	call   f010006a <_panic>
	assert(*pgdir_walk(kern_pgdir, (void *) PGSIZE, 0) & PTE_W);
f01028ea:	68 44 72 10 f0       	push   $0xf0107244
f01028ef:	68 43 76 10 f0       	push   $0xf0107643
f01028f4:	68 24 04 00 00       	push   $0x424
f01028f9:	68 2b 76 10 f0       	push   $0xf010762b
f01028fe:	e8 67 d7 ff ff       	call   f010006a <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void *) PGSIZE, 0) & PTE_U));
f0102903:	68 78 72 10 f0       	push   $0xf0107278
f0102908:	68 43 76 10 f0       	push   $0xf0107643
f010290d:	68 25 04 00 00       	push   $0x425
f0102912:	68 2b 76 10 f0       	push   $0xf010762b
f0102917:	e8 4e d7 ff ff       	call   f010006a <_panic>
	assert(page_insert(kern_pgdir, pp0, (void *) PTSIZE, PTE_W) < 0);
f010291c:	68 b0 72 10 f0       	push   $0xf01072b0
f0102921:	68 43 76 10 f0       	push   $0xf0107643
f0102926:	68 29 04 00 00       	push   $0x429
f010292b:	68 2b 76 10 f0       	push   $0xf010762b
f0102930:	e8 35 d7 ff ff       	call   f010006a <_panic>
	assert(page_insert(kern_pgdir, pp1, (void *) PGSIZE, PTE_W) == 0);
f0102935:	68 ec 72 10 f0       	push   $0xf01072ec
f010293a:	68 43 76 10 f0       	push   $0xf0107643
f010293f:	68 2c 04 00 00       	push   $0x42c
f0102944:	68 2b 76 10 f0       	push   $0xf010762b
f0102949:	e8 1c d7 ff ff       	call   f010006a <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void *) PGSIZE, 0) & PTE_U));
f010294e:	68 78 72 10 f0       	push   $0xf0107278
f0102953:	68 43 76 10 f0       	push   $0xf0107643
f0102958:	68 2d 04 00 00       	push   $0x42d
f010295d:	68 2b 76 10 f0       	push   $0xf010762b
f0102962:	e8 03 d7 ff ff       	call   f010006a <_panic>
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102967:	68 28 73 10 f0       	push   $0xf0107328
f010296c:	68 43 76 10 f0       	push   $0xf0107643
f0102971:	68 30 04 00 00       	push   $0x430
f0102976:	68 2b 76 10 f0       	push   $0xf010762b
f010297b:	e8 ea d6 ff ff       	call   f010006a <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102980:	68 54 73 10 f0       	push   $0xf0107354
f0102985:	68 43 76 10 f0       	push   $0xf0107643
f010298a:	68 31 04 00 00       	push   $0x431
f010298f:	68 2b 76 10 f0       	push   $0xf010762b
f0102994:	e8 d1 d6 ff ff       	call   f010006a <_panic>
	assert(pp1->pp_ref == 2);
f0102999:	68 74 78 10 f0       	push   $0xf0107874
f010299e:	68 43 76 10 f0       	push   $0xf0107643
f01029a3:	68 33 04 00 00       	push   $0x433
f01029a8:	68 2b 76 10 f0       	push   $0xf010762b
f01029ad:	e8 b8 d6 ff ff       	call   f010006a <_panic>
	assert(pp2->pp_ref == 0);
f01029b2:	68 2b 78 10 f0       	push   $0xf010782b
f01029b7:	68 43 76 10 f0       	push   $0xf0107643
f01029bc:	68 34 04 00 00       	push   $0x434
f01029c1:	68 2b 76 10 f0       	push   $0xf010762b
f01029c6:	e8 9f d6 ff ff       	call   f010006a <_panic>
	assert((pp = page_alloc(0)) && pp == pp2);
f01029cb:	68 84 73 10 f0       	push   $0xf0107384
f01029d0:	68 43 76 10 f0       	push   $0xf0107643
f01029d5:	68 37 04 00 00       	push   $0x437
f01029da:	68 2b 76 10 f0       	push   $0xf010762b
f01029df:	e8 86 d6 ff ff       	call   f010006a <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01029e4:	68 a8 73 10 f0       	push   $0xf01073a8
f01029e9:	68 43 76 10 f0       	push   $0xf0107643
f01029ee:	68 3b 04 00 00       	push   $0x43b
f01029f3:	68 2b 76 10 f0       	push   $0xf010762b
f01029f8:	e8 6d d6 ff ff       	call   f010006a <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01029fd:	68 54 73 10 f0       	push   $0xf0107354
f0102a02:	68 43 76 10 f0       	push   $0xf0107643
f0102a07:	68 3c 04 00 00       	push   $0x43c
f0102a0c:	68 2b 76 10 f0       	push   $0xf010762b
f0102a11:	e8 54 d6 ff ff       	call   f010006a <_panic>
	assert(pp1->pp_ref == 1);
f0102a16:	68 f8 77 10 f0       	push   $0xf01077f8
f0102a1b:	68 43 76 10 f0       	push   $0xf0107643
f0102a20:	68 3d 04 00 00       	push   $0x43d
f0102a25:	68 2b 76 10 f0       	push   $0xf010762b
f0102a2a:	e8 3b d6 ff ff       	call   f010006a <_panic>
	assert(pp2->pp_ref == 0);
f0102a2f:	68 2b 78 10 f0       	push   $0xf010782b
f0102a34:	68 43 76 10 f0       	push   $0xf0107643
f0102a39:	68 3e 04 00 00       	push   $0x43e
f0102a3e:	68 2b 76 10 f0       	push   $0xf010762b
f0102a43:	e8 22 d6 ff ff       	call   f010006a <_panic>
	assert(page_insert(kern_pgdir, pp1, (void *) PGSIZE, 0) == 0);
f0102a48:	68 cc 73 10 f0       	push   $0xf01073cc
f0102a4d:	68 43 76 10 f0       	push   $0xf0107643
f0102a52:	68 41 04 00 00       	push   $0x441
f0102a57:	68 2b 76 10 f0       	push   $0xf010762b
f0102a5c:	e8 09 d6 ff ff       	call   f010006a <_panic>
	assert(pp1->pp_ref);
f0102a61:	68 85 78 10 f0       	push   $0xf0107885
f0102a66:	68 43 76 10 f0       	push   $0xf0107643
f0102a6b:	68 42 04 00 00       	push   $0x442
f0102a70:	68 2b 76 10 f0       	push   $0xf010762b
f0102a75:	e8 f0 d5 ff ff       	call   f010006a <_panic>
	assert(pp1->pp_link == NULL);
f0102a7a:	68 91 78 10 f0       	push   $0xf0107891
f0102a7f:	68 43 76 10 f0       	push   $0xf0107643
f0102a84:	68 43 04 00 00       	push   $0x443
f0102a89:	68 2b 76 10 f0       	push   $0xf010762b
f0102a8e:	e8 d7 d5 ff ff       	call   f010006a <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102a93:	68 a8 73 10 f0       	push   $0xf01073a8
f0102a98:	68 43 76 10 f0       	push   $0xf0107643
f0102a9d:	68 47 04 00 00       	push   $0x447
f0102aa2:	68 2b 76 10 f0       	push   $0xf010762b
f0102aa7:	e8 be d5 ff ff       	call   f010006a <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102aac:	68 04 74 10 f0       	push   $0xf0107404
f0102ab1:	68 43 76 10 f0       	push   $0xf0107643
f0102ab6:	68 48 04 00 00       	push   $0x448
f0102abb:	68 2b 76 10 f0       	push   $0xf010762b
f0102ac0:	e8 a5 d5 ff ff       	call   f010006a <_panic>
	assert(pp1->pp_ref == 0);
f0102ac5:	68 1a 78 10 f0       	push   $0xf010781a
f0102aca:	68 43 76 10 f0       	push   $0xf0107643
f0102acf:	68 49 04 00 00       	push   $0x449
f0102ad4:	68 2b 76 10 f0       	push   $0xf010762b
f0102ad9:	e8 8c d5 ff ff       	call   f010006a <_panic>
	assert(pp2->pp_ref == 0);
f0102ade:	68 2b 78 10 f0       	push   $0xf010782b
f0102ae3:	68 43 76 10 f0       	push   $0xf0107643
f0102ae8:	68 4a 04 00 00       	push   $0x44a
f0102aed:	68 2b 76 10 f0       	push   $0xf010762b
f0102af2:	e8 73 d5 ff ff       	call   f010006a <_panic>
	assert((pp = page_alloc(0)) && pp == pp1);
f0102af7:	68 2c 74 10 f0       	push   $0xf010742c
f0102afc:	68 43 76 10 f0       	push   $0xf0107643
f0102b01:	68 4d 04 00 00       	push   $0x44d
f0102b06:	68 2b 76 10 f0       	push   $0xf010762b
f0102b0b:	e8 5a d5 ff ff       	call   f010006a <_panic>
	assert(!page_alloc(0));
f0102b10:	68 5f 77 10 f0       	push   $0xf010775f
f0102b15:	68 43 76 10 f0       	push   $0xf0107643
f0102b1a:	68 50 04 00 00       	push   $0x450
f0102b1f:	68 2b 76 10 f0       	push   $0xf010762b
f0102b24:	e8 41 d5 ff ff       	call   f010006a <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102b29:	68 00 70 10 f0       	push   $0xf0107000
f0102b2e:	68 43 76 10 f0       	push   $0xf0107643
f0102b33:	68 53 04 00 00       	push   $0x453
f0102b38:	68 2b 76 10 f0       	push   $0xf010762b
f0102b3d:	e8 28 d5 ff ff       	call   f010006a <_panic>
	assert(pp0->pp_ref == 1);
f0102b42:	68 3c 78 10 f0       	push   $0xf010783c
f0102b47:	68 43 76 10 f0       	push   $0xf0107643
f0102b4c:	68 55 04 00 00       	push   $0x455
f0102b51:	68 2b 76 10 f0       	push   $0xf010762b
f0102b56:	e8 0f d5 ff ff       	call   f010006a <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102b5b:	68 a6 78 10 f0       	push   $0xf01078a6
f0102b60:	68 43 76 10 f0       	push   $0xf0107643
f0102b65:	68 5d 04 00 00       	push   $0x45d
f0102b6a:	68 2b 76 10 f0       	push   $0xf010762b
f0102b6f:	e8 f6 d4 ff ff       	call   f010006a <_panic>
		assert((ptep[i] & PTE_P) == 0);
f0102b74:	68 be 78 10 f0       	push   $0xf01078be
f0102b79:	68 43 76 10 f0       	push   $0xf0107643
f0102b7e:	68 67 04 00 00       	push   $0x467
f0102b83:	68 2b 76 10 f0       	push   $0xf010762b
f0102b88:	e8 dd d4 ff ff       	call   f010006a <_panic>
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f0102b8d:	68 50 74 10 f0       	push   $0xf0107450
f0102b92:	68 43 76 10 f0       	push   $0xf0107643
f0102b97:	68 77 04 00 00       	push   $0x477
f0102b9c:	68 2b 76 10 f0       	push   $0xf010762b
f0102ba1:	e8 c4 d4 ff ff       	call   f010006a <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f0102ba6:	68 78 74 10 f0       	push   $0xf0107478
f0102bab:	68 43 76 10 f0       	push   $0xf0107643
f0102bb0:	68 78 04 00 00       	push   $0x478
f0102bb5:	68 2b 76 10 f0       	push   $0xf010762b
f0102bba:	e8 ab d4 ff ff       	call   f010006a <_panic>
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0102bbf:	68 a0 74 10 f0       	push   $0xf01074a0
f0102bc4:	68 43 76 10 f0       	push   $0xf0107643
f0102bc9:	68 7a 04 00 00       	push   $0x47a
f0102bce:	68 2b 76 10 f0       	push   $0xf010762b
f0102bd3:	e8 92 d4 ff ff       	call   f010006a <_panic>
	assert(mm1 + 8096 <= mm2);
f0102bd8:	68 d5 78 10 f0       	push   $0xf01078d5
f0102bdd:	68 43 76 10 f0       	push   $0xf0107643
f0102be2:	68 7c 04 00 00       	push   $0x47c
f0102be7:	68 2b 76 10 f0       	push   $0xf010762b
f0102bec:	e8 79 d4 ff ff       	call   f010006a <_panic>
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0102bf1:	68 c8 74 10 f0       	push   $0xf01074c8
f0102bf6:	68 43 76 10 f0       	push   $0xf0107643
f0102bfb:	68 7e 04 00 00       	push   $0x47e
f0102c00:	68 2b 76 10 f0       	push   $0xf010762b
f0102c05:	e8 60 d4 ff ff       	call   f010006a <_panic>
	assert(check_va2pa(kern_pgdir, mm1 + PGSIZE) == PGSIZE);
f0102c0a:	68 ec 74 10 f0       	push   $0xf01074ec
f0102c0f:	68 43 76 10 f0       	push   $0xf0107643
f0102c14:	68 7f 04 00 00       	push   $0x47f
f0102c19:	68 2b 76 10 f0       	push   $0xf010762b
f0102c1e:	e8 47 d4 ff ff       	call   f010006a <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0102c23:	68 1c 75 10 f0       	push   $0xf010751c
f0102c28:	68 43 76 10 f0       	push   $0xf0107643
f0102c2d:	68 80 04 00 00       	push   $0x480
f0102c32:	68 2b 76 10 f0       	push   $0xf010762b
f0102c37:	e8 2e d4 ff ff       	call   f010006a <_panic>
	assert(check_va2pa(kern_pgdir, mm2 + PGSIZE) == ~0);
f0102c3c:	68 40 75 10 f0       	push   $0xf0107540
f0102c41:	68 43 76 10 f0       	push   $0xf0107643
f0102c46:	68 81 04 00 00       	push   $0x481
f0102c4b:	68 2b 76 10 f0       	push   $0xf010762b
f0102c50:	e8 15 d4 ff ff       	call   f010006a <_panic>
	assert(*pgdir_walk(kern_pgdir, (void *) mm1, 0) &
f0102c55:	68 6c 75 10 f0       	push   $0xf010756c
f0102c5a:	68 43 76 10 f0       	push   $0xf0107643
f0102c5f:	68 83 04 00 00       	push   $0x483
f0102c64:	68 2b 76 10 f0       	push   $0xf010762b
f0102c69:	e8 fc d3 ff ff       	call   f010006a <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void *) mm1, 0) & PTE_U));
f0102c6e:	68 b4 75 10 f0       	push   $0xf01075b4
f0102c73:	68 43 76 10 f0       	push   $0xf0107643
f0102c78:	68 85 04 00 00       	push   $0x485
f0102c7d:	68 2b 76 10 f0       	push   $0xf010762b
f0102c82:	e8 e3 d3 ff ff       	call   f010006a <_panic>

f0102c87 <mem_init>:
{
f0102c87:	f3 0f 1e fb          	endbr32 
f0102c8b:	55                   	push   %ebp
f0102c8c:	89 e5                	mov    %esp,%ebp
f0102c8e:	53                   	push   %ebx
f0102c8f:	83 ec 04             	sub    $0x4,%esp
	i386_detect_memory();
f0102c92:	e8 44 df ff ff       	call   f0100bdb <i386_detect_memory>
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0102c97:	b8 00 10 00 00       	mov    $0x1000,%eax
f0102c9c:	e8 50 e0 ff ff       	call   f0100cf1 <boot_alloc>
f0102ca1:	a3 8c fe 24 f0       	mov    %eax,0xf024fe8c
	memset(kern_pgdir, 0, PGSIZE);
f0102ca6:	83 ec 04             	sub    $0x4,%esp
f0102ca9:	68 00 10 00 00       	push   $0x1000
f0102cae:	6a 00                	push   $0x0
f0102cb0:	50                   	push   %eax
f0102cb1:	e8 af 2c 00 00       	call   f0105965 <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0102cb6:	8b 1d 8c fe 24 f0    	mov    0xf024fe8c,%ebx
f0102cbc:	89 d9                	mov    %ebx,%ecx
f0102cbe:	ba a4 00 00 00       	mov    $0xa4,%edx
f0102cc3:	b8 2b 76 10 f0       	mov    $0xf010762b,%eax
f0102cc8:	e8 a0 e0 ff ff       	call   f0100d6d <_paddr>
f0102ccd:	83 c8 05             	or     $0x5,%eax
f0102cd0:	89 83 f4 0e 00 00    	mov    %eax,0xef4(%ebx)
	size_t size_pages = npages * sizeof(struct PageInfo);
f0102cd6:	a1 88 fe 24 f0       	mov    0xf024fe88,%eax
f0102cdb:	8d 1c c5 00 00 00 00 	lea    0x0(,%eax,8),%ebx
	pages = boot_alloc(size_pages);
f0102ce2:	89 d8                	mov    %ebx,%eax
f0102ce4:	e8 08 e0 ff ff       	call   f0100cf1 <boot_alloc>
f0102ce9:	a3 90 fe 24 f0       	mov    %eax,0xf024fe90
	memset(pages, 0, size_pages);
f0102cee:	83 c4 0c             	add    $0xc,%esp
f0102cf1:	53                   	push   %ebx
f0102cf2:	6a 00                	push   $0x0
f0102cf4:	50                   	push   %eax
f0102cf5:	e8 6b 2c 00 00       	call   f0105965 <memset>
	envs = boot_alloc(size_envs);
f0102cfa:	b8 00 00 02 00       	mov    $0x20000,%eax
f0102cff:	e8 ed df ff ff       	call   f0100cf1 <boot_alloc>
f0102d04:	a3 44 e2 24 f0       	mov    %eax,0xf024e244
	memset(envs, 0, size_envs);
f0102d09:	83 c4 0c             	add    $0xc,%esp
f0102d0c:	68 00 00 02 00       	push   $0x20000
f0102d11:	6a 00                	push   $0x0
f0102d13:	50                   	push   %eax
f0102d14:	e8 4c 2c 00 00       	call   f0105965 <memset>
	page_init();
f0102d19:	e8 50 e3 ff ff       	call   f010106e <page_init>
	check_page_free_list(1);
f0102d1e:	b8 01 00 00 00       	mov    $0x1,%eax
f0102d23:	e8 67 e0 ff ff       	call   f0100d8f <check_page_free_list>
	check_page_alloc();
f0102d28:	e8 6d e4 ff ff       	call   f010119a <check_page_alloc>
	check_page();
f0102d2d:	e8 6d f1 ff ff       	call   f0101e9f <check_page>
	boot_map_region(kern_pgdir, UPAGES, size_pages, PADDR(pages), PTE_U | PTE_P);
f0102d32:	8b 0d 90 fe 24 f0    	mov    0xf024fe90,%ecx
f0102d38:	ba cf 00 00 00       	mov    $0xcf,%edx
f0102d3d:	b8 2b 76 10 f0       	mov    $0xf010762b,%eax
f0102d42:	e8 26 e0 ff ff       	call   f0100d6d <_paddr>
f0102d47:	83 c4 08             	add    $0x8,%esp
f0102d4a:	6a 05                	push   $0x5
f0102d4c:	50                   	push   %eax
f0102d4d:	89 d9                	mov    %ebx,%ecx
f0102d4f:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102d54:	a1 8c fe 24 f0       	mov    0xf024fe8c,%eax
f0102d59:	e8 91 e9 ff ff       	call   f01016ef <boot_map_region>
	boot_map_region(kern_pgdir, UENVS, size_envs, PADDR(envs), PTE_U);
f0102d5e:	8b 0d 44 e2 24 f0    	mov    0xf024e244,%ecx
f0102d64:	ba d7 00 00 00       	mov    $0xd7,%edx
f0102d69:	b8 2b 76 10 f0       	mov    $0xf010762b,%eax
f0102d6e:	e8 fa df ff ff       	call   f0100d6d <_paddr>
f0102d73:	83 c4 08             	add    $0x8,%esp
f0102d76:	6a 04                	push   $0x4
f0102d78:	50                   	push   %eax
f0102d79:	b9 00 00 02 00       	mov    $0x20000,%ecx
f0102d7e:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102d83:	a1 8c fe 24 f0       	mov    0xf024fe8c,%eax
f0102d88:	e8 62 e9 ff ff       	call   f01016ef <boot_map_region>
	boot_map_region(kern_pgdir,
f0102d8d:	b9 00 a0 11 f0       	mov    $0xf011a000,%ecx
f0102d92:	ba e6 00 00 00       	mov    $0xe6,%edx
f0102d97:	b8 2b 76 10 f0       	mov    $0xf010762b,%eax
f0102d9c:	e8 cc df ff ff       	call   f0100d6d <_paddr>
f0102da1:	83 c4 08             	add    $0x8,%esp
f0102da4:	6a 02                	push   $0x2
f0102da6:	50                   	push   %eax
f0102da7:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102dac:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102db1:	a1 8c fe 24 f0       	mov    0xf024fe8c,%eax
f0102db6:	e8 34 e9 ff ff       	call   f01016ef <boot_map_region>
	boot_map_region(kern_pgdir, KERNBASE, tam, 0, PTE_W);
f0102dbb:	83 c4 08             	add    $0x8,%esp
f0102dbe:	6a 02                	push   $0x2
f0102dc0:	6a 00                	push   $0x0
f0102dc2:	b9 ff ff ff 0f       	mov    $0xfffffff,%ecx
f0102dc7:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102dcc:	a1 8c fe 24 f0       	mov    0xf024fe8c,%eax
f0102dd1:	e8 19 e9 ff ff       	call   f01016ef <boot_map_region>
	mem_init_mp();
f0102dd6:	e8 2a e9 ff ff       	call   f0101705 <mem_init_mp>
	check_kern_pgdir();
f0102ddb:	e8 80 e9 ff ff       	call   f0101760 <check_kern_pgdir>
	lcr3(PADDR(kern_pgdir));
f0102de0:	8b 0d 8c fe 24 f0    	mov    0xf024fe8c,%ecx
f0102de6:	ba 02 01 00 00       	mov    $0x102,%edx
f0102deb:	b8 2b 76 10 f0       	mov    $0xf010762b,%eax
f0102df0:	e8 78 df ff ff       	call   f0100d6d <_paddr>
f0102df5:	e8 a7 dd ff ff       	call   f0100ba1 <lcr3>
	check_page_free_list(0);
f0102dfa:	b8 00 00 00 00       	mov    $0x0,%eax
f0102dff:	e8 8b df ff ff       	call   f0100d8f <check_page_free_list>
	cr0 = rcr0();
f0102e04:	e8 94 dd ff ff       	call   f0100b9d <rcr0>
f0102e09:	83 e0 f3             	and    $0xfffffff3,%eax
	cr0 &= ~(CR0_TS | CR0_EM);
f0102e0c:	0d 23 00 05 80       	or     $0x80050023,%eax
	lcr0(cr0);
f0102e11:	e8 83 dd ff ff       	call   f0100b99 <lcr0>
	check_page_installed_pgdir();
f0102e16:	e8 6f ed ff ff       	call   f0101b8a <check_page_installed_pgdir>
}
f0102e1b:	83 c4 10             	add    $0x10,%esp
f0102e1e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102e21:	c9                   	leave  
f0102e22:	c3                   	ret    

f0102e23 <user_mem_check>:
{
f0102e23:	f3 0f 1e fb          	endbr32 
f0102e27:	55                   	push   %ebp
f0102e28:	89 e5                	mov    %esp,%ebp
f0102e2a:	57                   	push   %edi
f0102e2b:	56                   	push   %esi
f0102e2c:	53                   	push   %ebx
f0102e2d:	83 ec 2c             	sub    $0x2c,%esp
	void *aux_page = ROUNDDOWN((void *) va, PGSIZE);
f0102e30:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102e33:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102e36:	89 c3                	mov    %eax,%ebx
f0102e38:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	void *last_page = ROUNDUP((void *) (va + len), PGSIZE);
f0102e3e:	89 c6                	mov    %eax,%esi
f0102e40:	03 75 10             	add    0x10(%ebp),%esi
f0102e43:	81 c6 ff 0f 00 00    	add    $0xfff,%esi
f0102e49:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
		    !(page_lookup(env->env_pgdir, aux_page, &pte_aux) &&
f0102e4f:	8d 7d e4             	lea    -0x1c(%ebp),%edi
	while (aux_page < last_page) {
f0102e52:	eb 06                	jmp    f0102e5a <user_mem_check+0x37>
		aux_page += PGSIZE;
f0102e54:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	while (aux_page < last_page) {
f0102e5a:	39 f3                	cmp    %esi,%ebx
f0102e5c:	73 4f                	jae    f0102ead <user_mem_check+0x8a>
		pte_t *pte_aux = NULL;
f0102e5e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0102e65:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
		if ((uintptr_t) aux_page >= ULIM ||
f0102e68:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102e6e:	77 21                	ja     f0102e91 <user_mem_check+0x6e>
		    !(page_lookup(env->env_pgdir, aux_page, &pte_aux) &&
f0102e70:	83 ec 04             	sub    $0x4,%esp
f0102e73:	57                   	push   %edi
f0102e74:	53                   	push   %ebx
f0102e75:	8b 45 08             	mov    0x8(%ebp),%eax
f0102e78:	ff 70 64             	pushl  0x64(%eax)
f0102e7b:	e8 df eb ff ff       	call   f0101a5f <page_lookup>
		if ((uintptr_t) aux_page >= ULIM ||
f0102e80:	83 c4 10             	add    $0x10,%esp
f0102e83:	85 c0                	test   %eax,%eax
f0102e85:	74 0a                	je     f0102e91 <user_mem_check+0x6e>
		    !(page_lookup(env->env_pgdir, aux_page, &pte_aux) &&
f0102e87:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102e8a:	8b 00                	mov    (%eax),%eax
f0102e8c:	85 45 14             	test   %eax,0x14(%ebp)
f0102e8f:	75 c3                	jne    f0102e54 <user_mem_check+0x31>
			if (aux_page < va) {
f0102e91:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
f0102e94:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102e97:	0f 43 45 d4          	cmovae -0x2c(%ebp),%eax
f0102e9b:	a3 3c e2 24 f0       	mov    %eax,0xf024e23c
			return -E_FAULT;
f0102ea0:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
}
f0102ea5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102ea8:	5b                   	pop    %ebx
f0102ea9:	5e                   	pop    %esi
f0102eaa:	5f                   	pop    %edi
f0102eab:	5d                   	pop    %ebp
f0102eac:	c3                   	ret    
	return 0;
f0102ead:	b8 00 00 00 00       	mov    $0x0,%eax
f0102eb2:	eb f1                	jmp    f0102ea5 <user_mem_check+0x82>

f0102eb4 <user_mem_assert>:
{
f0102eb4:	f3 0f 1e fb          	endbr32 
f0102eb8:	55                   	push   %ebp
f0102eb9:	89 e5                	mov    %esp,%ebp
f0102ebb:	53                   	push   %ebx
f0102ebc:	83 ec 04             	sub    $0x4,%esp
f0102ebf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0102ec2:	8b 45 14             	mov    0x14(%ebp),%eax
f0102ec5:	83 c8 04             	or     $0x4,%eax
f0102ec8:	50                   	push   %eax
f0102ec9:	ff 75 10             	pushl  0x10(%ebp)
f0102ecc:	ff 75 0c             	pushl  0xc(%ebp)
f0102ecf:	53                   	push   %ebx
f0102ed0:	e8 4e ff ff ff       	call   f0102e23 <user_mem_check>
f0102ed5:	83 c4 10             	add    $0x10,%esp
f0102ed8:	85 c0                	test   %eax,%eax
f0102eda:	78 05                	js     f0102ee1 <user_mem_assert+0x2d>
}
f0102edc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102edf:	c9                   	leave  
f0102ee0:	c3                   	ret    
		cprintf("[%08x] user_mem_check assertion failure for "
f0102ee1:	83 ec 04             	sub    $0x4,%esp
f0102ee4:	ff 35 3c e2 24 f0    	pushl  0xf024e23c
f0102eea:	ff 73 48             	pushl  0x48(%ebx)
f0102eed:	68 e8 75 10 f0       	push   $0xf01075e8
f0102ef2:	e8 36 0a 00 00       	call   f010392d <cprintf>
		env_destroy(env);  // may not return
f0102ef7:	89 1c 24             	mov    %ebx,(%esp)
f0102efa:	e8 88 06 00 00       	call   f0103587 <env_destroy>
f0102eff:	83 c4 10             	add    $0x10,%esp
}
f0102f02:	eb d8                	jmp    f0102edc <user_mem_assert+0x28>

f0102f04 <lgdt>:
	asm volatile("lgdt (%0)" : : "r" (p));
f0102f04:	0f 01 10             	lgdtl  (%eax)
}
f0102f07:	c3                   	ret    

f0102f08 <lldt>:
	asm volatile("lldt %0" : : "r" (sel));
f0102f08:	0f 00 d0             	lldt   %ax
}
f0102f0b:	c3                   	ret    

f0102f0c <lcr3>:
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102f0c:	0f 22 d8             	mov    %eax,%cr3
}
f0102f0f:	c3                   	ret    

f0102f10 <page2pa>:
	return (pp - pages) << PGSHIFT;
f0102f10:	2b 05 90 fe 24 f0    	sub    0xf024fe90,%eax
f0102f16:	c1 f8 03             	sar    $0x3,%eax
f0102f19:	c1 e0 0c             	shl    $0xc,%eax
}
f0102f1c:	c3                   	ret    

f0102f1d <_kaddr>:
{
f0102f1d:	55                   	push   %ebp
f0102f1e:	89 e5                	mov    %esp,%ebp
f0102f20:	53                   	push   %ebx
f0102f21:	83 ec 04             	sub    $0x4,%esp
	if (PGNUM(pa) >= npages)
f0102f24:	89 cb                	mov    %ecx,%ebx
f0102f26:	c1 eb 0c             	shr    $0xc,%ebx
f0102f29:	3b 1d 88 fe 24 f0    	cmp    0xf024fe88,%ebx
f0102f2f:	73 0b                	jae    f0102f3c <_kaddr+0x1f>
	return (void *)(pa + KERNBASE);
f0102f31:	8d 81 00 00 00 f0    	lea    -0x10000000(%ecx),%eax
}
f0102f37:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102f3a:	c9                   	leave  
f0102f3b:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102f3c:	51                   	push   %ecx
f0102f3d:	68 ec 66 10 f0       	push   $0xf01066ec
f0102f42:	52                   	push   %edx
f0102f43:	50                   	push   %eax
f0102f44:	e8 21 d1 ff ff       	call   f010006a <_panic>

f0102f49 <page2kva>:
{
f0102f49:	55                   	push   %ebp
f0102f4a:	89 e5                	mov    %esp,%ebp
f0102f4c:	83 ec 08             	sub    $0x8,%esp
	return KADDR(page2pa(pp));
f0102f4f:	e8 bc ff ff ff       	call   f0102f10 <page2pa>
f0102f54:	89 c1                	mov    %eax,%ecx
f0102f56:	ba 58 00 00 00       	mov    $0x58,%edx
f0102f5b:	b8 1d 76 10 f0       	mov    $0xf010761d,%eax
f0102f60:	e8 b8 ff ff ff       	call   f0102f1d <_kaddr>
}
f0102f65:	c9                   	leave  
f0102f66:	c3                   	ret    

f0102f67 <_paddr>:
	if ((uint32_t)kva < KERNBASE)
f0102f67:	81 f9 ff ff ff ef    	cmp    $0xefffffff,%ecx
f0102f6d:	76 07                	jbe    f0102f76 <_paddr+0xf>
	return (physaddr_t)kva - KERNBASE;
f0102f6f:	8d 81 00 00 00 10    	lea    0x10000000(%ecx),%eax
}
f0102f75:	c3                   	ret    
{
f0102f76:	55                   	push   %ebp
f0102f77:	89 e5                	mov    %esp,%ebp
f0102f79:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102f7c:	51                   	push   %ecx
f0102f7d:	68 10 67 10 f0       	push   $0xf0106710
f0102f82:	52                   	push   %edx
f0102f83:	50                   	push   %eax
f0102f84:	e8 e1 d0 ff ff       	call   f010006a <_panic>

f0102f89 <env_setup_vm>:
// Returns 0 on success, < 0 on error.  Errors include:
//	-E_NO_MEM if page directory or table could not be allocated.
//
static int
env_setup_vm(struct Env *e)
{
f0102f89:	55                   	push   %ebp
f0102f8a:	89 e5                	mov    %esp,%ebp
f0102f8c:	53                   	push   %ebx
f0102f8d:	83 ec 10             	sub    $0x10,%esp
f0102f90:	89 c3                	mov    %eax,%ebx
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0102f92:	6a 01                	push   $0x1
f0102f94:	e8 77 e1 ff ff       	call   f0101110 <page_alloc>
f0102f99:	83 c4 10             	add    $0x10,%esp
f0102f9c:	85 c0                	test   %eax,%eax
f0102f9e:	74 4b                	je     f0102feb <env_setup_vm+0x62>
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	p->pp_ref++;
f0102fa0:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	e->env_pgdir = page2kva(p);
f0102fa5:	e8 9f ff ff ff       	call   f0102f49 <page2kva>
f0102faa:	89 43 64             	mov    %eax,0x64(%ebx)
	memcpy(e->env_pgdir, kern_pgdir, PGSIZE);
f0102fad:	83 ec 04             	sub    $0x4,%esp
f0102fb0:	68 00 10 00 00       	push   $0x1000
f0102fb5:	ff 35 8c fe 24 f0    	pushl  0xf024fe8c
f0102fbb:	50                   	push   %eax
f0102fbc:	e8 58 2a 00 00       	call   f0105a19 <memcpy>
	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0102fc1:	8b 5b 64             	mov    0x64(%ebx),%ebx
f0102fc4:	89 d9                	mov    %ebx,%ecx
f0102fc6:	ba c2 00 00 00       	mov    $0xc2,%edx
f0102fcb:	b8 74 79 10 f0       	mov    $0xf0107974,%eax
f0102fd0:	e8 92 ff ff ff       	call   f0102f67 <_paddr>
f0102fd5:	83 c8 05             	or     $0x5,%eax
f0102fd8:	89 83 f4 0e 00 00    	mov    %eax,0xef4(%ebx)

	return 0;
f0102fde:	83 c4 10             	add    $0x10,%esp
f0102fe1:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102fe6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102fe9:	c9                   	leave  
f0102fea:	c3                   	ret    
		return -E_NO_MEM;
f0102feb:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0102ff0:	eb f4                	jmp    f0102fe6 <env_setup_vm+0x5d>

f0102ff2 <pa2page>:
	if (PGNUM(pa) >= npages)
f0102ff2:	c1 e8 0c             	shr    $0xc,%eax
f0102ff5:	3b 05 88 fe 24 f0    	cmp    0xf024fe88,%eax
f0102ffb:	73 0a                	jae    f0103007 <pa2page+0x15>
	return &pages[PGNUM(pa)];
f0102ffd:	8b 15 90 fe 24 f0    	mov    0xf024fe90,%edx
f0103003:	8d 04 c2             	lea    (%edx,%eax,8),%eax
}
f0103006:	c3                   	ret    
{
f0103007:	55                   	push   %ebp
f0103008:	89 e5                	mov    %esp,%ebp
f010300a:	83 ec 0c             	sub    $0xc,%esp
		panic("pa2page called with invalid pa");
f010300d:	68 54 6d 10 f0       	push   $0xf0106d54
f0103012:	6a 51                	push   $0x51
f0103014:	68 1d 76 10 f0       	push   $0xf010761d
f0103019:	e8 4c d0 ff ff       	call   f010006a <_panic>

f010301e <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f010301e:	55                   	push   %ebp
f010301f:	89 e5                	mov    %esp,%ebp
f0103021:	57                   	push   %edi
f0103022:	56                   	push   %esi
f0103023:	53                   	push   %ebx
f0103024:	83 ec 0c             	sub    $0xc,%esp
f0103027:	89 c7                	mov    %eax,%edi
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	void *va_aux = ROUNDDOWN(va, PGSIZE);
f0103029:	89 d3                	mov    %edx,%ebx
f010302b:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	void *va_len = ROUNDUP(va + len, PGSIZE);
f0103031:	8d b4 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%esi
f0103038:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi

	while (va_aux < va_len) {
f010303e:	39 f3                	cmp    %esi,%ebx
f0103040:	73 5a                	jae    f010309c <region_alloc+0x7e>
		struct PageInfo *page = page_alloc(ALLOC_ZERO);
f0103042:	83 ec 0c             	sub    $0xc,%esp
f0103045:	6a 01                	push   $0x1
f0103047:	e8 c4 e0 ff ff       	call   f0101110 <page_alloc>
		if (!page) {
f010304c:	83 c4 10             	add    $0x10,%esp
f010304f:	85 c0                	test   %eax,%eax
f0103051:	74 1b                	je     f010306e <region_alloc+0x50>
			panic("region_alloc: page alloc failed");
		}
		if (page_insert(e->env_pgdir, page, va_aux, PTE_W | PTE_U) < 0) {
f0103053:	6a 06                	push   $0x6
f0103055:	53                   	push   %ebx
f0103056:	50                   	push   %eax
f0103057:	ff 77 64             	pushl  0x64(%edi)
f010305a:	e8 c6 ea ff ff       	call   f0101b25 <page_insert>
f010305f:	83 c4 10             	add    $0x10,%esp
f0103062:	85 c0                	test   %eax,%eax
f0103064:	78 1f                	js     f0103085 <region_alloc+0x67>
			panic("region_alloc: cannot do insert page");
		}
		va_aux += PGSIZE;
f0103066:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010306c:	eb d0                	jmp    f010303e <region_alloc+0x20>
			panic("region_alloc: page alloc failed");
f010306e:	83 ec 04             	sub    $0x4,%esp
f0103071:	68 00 79 10 f0       	push   $0xf0107900
f0103076:	68 28 01 00 00       	push   $0x128
f010307b:	68 74 79 10 f0       	push   $0xf0107974
f0103080:	e8 e5 cf ff ff       	call   f010006a <_panic>
			panic("region_alloc: cannot do insert page");
f0103085:	83 ec 04             	sub    $0x4,%esp
f0103088:	68 20 79 10 f0       	push   $0xf0107920
f010308d:	68 2b 01 00 00       	push   $0x12b
f0103092:	68 74 79 10 f0       	push   $0xf0107974
f0103097:	e8 ce cf ff ff       	call   f010006a <_panic>
	}
}
f010309c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010309f:	5b                   	pop    %ebx
f01030a0:	5e                   	pop    %esi
f01030a1:	5f                   	pop    %edi
f01030a2:	5d                   	pop    %ebp
f01030a3:	c3                   	ret    

f01030a4 <load_icode>:
// load_icode panics if it encounters problems.
//  - How might load_icode fail?  What might be wrong with the given input?
//
static void
load_icode(struct Env *e, uint8_t *binary)
{
f01030a4:	55                   	push   %ebp
f01030a5:	89 e5                	mov    %esp,%ebp
f01030a7:	57                   	push   %edi
f01030a8:	56                   	push   %esi
f01030a9:	53                   	push   %ebx
f01030aa:	83 ec 1c             	sub    $0x1c,%esp
f01030ad:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	//  What?  (See env_run() and env_pop_tf() below.)

	// LAB 3: Your code here.
	struct Elf *elf = (struct Elf *) binary;

	if (elf->e_magic != ELF_MAGIC) {
f01030b0:	81 3a 7f 45 4c 46    	cmpl   $0x464c457f,(%edx)
f01030b6:	75 2c                	jne    f01030e4 <load_icode+0x40>
f01030b8:	89 d7                	mov    %edx,%edi
		panic("load_icode: elf magic error\n");
	}
	lcr3(PADDR(e->env_pgdir));
f01030ba:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01030bd:	8b 48 64             	mov    0x64(%eax),%ecx
f01030c0:	ba 6c 01 00 00       	mov    $0x16c,%edx
f01030c5:	b8 74 79 10 f0       	mov    $0xf0107974,%eax
f01030ca:	e8 98 fe ff ff       	call   f0102f67 <_paddr>
f01030cf:	e8 38 fe ff ff       	call   f0102f0c <lcr3>

	struct Proghdr *ph = (struct Proghdr *) (binary + elf->e_phoff);
f01030d4:	89 fb                	mov    %edi,%ebx
f01030d6:	03 5f 1c             	add    0x1c(%edi),%ebx
	struct Proghdr *eph = ph + elf->e_phnum;
f01030d9:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
f01030dd:	c1 e6 05             	shl    $0x5,%esi
f01030e0:	01 de                	add    %ebx,%esi

	while (ph < eph) {
f01030e2:	eb 31                	jmp    f0103115 <load_icode+0x71>
		panic("load_icode: elf magic error\n");
f01030e4:	83 ec 04             	sub    $0x4,%esp
f01030e7:	68 7f 79 10 f0       	push   $0xf010797f
f01030ec:	68 6a 01 00 00       	push   $0x16a
f01030f1:	68 74 79 10 f0       	push   $0xf0107974
f01030f6:	e8 6f cf ff ff       	call   f010006a <_panic>
		if (ph->p_type == ELF_PROG_LOAD) {
			if (ph->p_filesz > ph->p_memsz) {
				panic("load_icode: must be ph->p_filesz <= "
f01030fb:	83 ec 04             	sub    $0x4,%esp
f01030fe:	68 44 79 10 f0       	push   $0xf0107944
f0103103:	68 74 01 00 00       	push   $0x174
f0103108:	68 74 79 10 f0       	push   $0xf0107974
f010310d:	e8 58 cf ff ff       	call   f010006a <_panic>
			       ph->p_filesz);
			memset((void *) ph->p_va + ph->p_filesz,
			       0,
			       ph->p_memsz - ph->p_filesz);
		}
		ph++;
f0103112:	83 c3 20             	add    $0x20,%ebx
	while (ph < eph) {
f0103115:	39 f3                	cmp    %esi,%ebx
f0103117:	73 48                	jae    f0103161 <load_icode+0xbd>
		if (ph->p_type == ELF_PROG_LOAD) {
f0103119:	83 3b 01             	cmpl   $0x1,(%ebx)
f010311c:	75 f4                	jne    f0103112 <load_icode+0x6e>
			if (ph->p_filesz > ph->p_memsz) {
f010311e:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0103121:	39 4b 10             	cmp    %ecx,0x10(%ebx)
f0103124:	77 d5                	ja     f01030fb <load_icode+0x57>
			region_alloc(e, (void *) ph->p_va, ph->p_memsz);
f0103126:	8b 53 08             	mov    0x8(%ebx),%edx
f0103129:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010312c:	e8 ed fe ff ff       	call   f010301e <region_alloc>
			memcpy((void *) ph->p_va,
f0103131:	83 ec 04             	sub    $0x4,%esp
f0103134:	ff 73 10             	pushl  0x10(%ebx)
			       binary + ph->p_offset,
f0103137:	89 f8                	mov    %edi,%eax
f0103139:	03 43 04             	add    0x4(%ebx),%eax
			memcpy((void *) ph->p_va,
f010313c:	50                   	push   %eax
f010313d:	ff 73 08             	pushl  0x8(%ebx)
f0103140:	e8 d4 28 00 00       	call   f0105a19 <memcpy>
			       ph->p_memsz - ph->p_filesz);
f0103145:	8b 43 10             	mov    0x10(%ebx),%eax
			memset((void *) ph->p_va + ph->p_filesz,
f0103148:	83 c4 0c             	add    $0xc,%esp
f010314b:	8b 53 14             	mov    0x14(%ebx),%edx
f010314e:	29 c2                	sub    %eax,%edx
f0103150:	52                   	push   %edx
f0103151:	6a 00                	push   $0x0
f0103153:	03 43 08             	add    0x8(%ebx),%eax
f0103156:	50                   	push   %eax
f0103157:	e8 09 28 00 00       	call   f0105965 <memset>
f010315c:	83 c4 10             	add    $0x10,%esp
f010315f:	eb b1                	jmp    f0103112 <load_icode+0x6e>
	}
	// restauro valor cr3
	lcr3(PADDR(kern_pgdir));
f0103161:	8b 0d 8c fe 24 f0    	mov    0xf024fe8c,%ecx
f0103167:	ba 82 01 00 00       	mov    $0x182,%edx
f010316c:	b8 74 79 10 f0       	mov    $0xf0107974,%eax
f0103171:	e8 f1 fd ff ff       	call   f0102f67 <_paddr>
f0103176:	e8 91 fd ff ff       	call   f0102f0c <lcr3>
	// configuro el entry
	e->env_tf.tf_eip = elf->e_entry;
f010317b:	8b 47 18             	mov    0x18(%edi),%eax
f010317e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103181:	89 47 30             	mov    %eax,0x30(%edi)

	region_alloc(e, (void *) (USTACKTOP - PGSIZE), PGSIZE);
f0103184:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0103189:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f010318e:	89 f8                	mov    %edi,%eax
f0103190:	e8 89 fe ff ff       	call   f010301e <region_alloc>
	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.
}
f0103195:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103198:	5b                   	pop    %ebx
f0103199:	5e                   	pop    %esi
f010319a:	5f                   	pop    %edi
f010319b:	5d                   	pop    %ebp
f010319c:	c3                   	ret    

f010319d <unlock_kernel>:

static inline void
unlock_kernel(void)
{
f010319d:	55                   	push   %ebp
f010319e:	89 e5                	mov    %esp,%ebp
f01031a0:	83 ec 14             	sub    $0x14,%esp
	spin_unlock(&kernel_lock);
f01031a3:	68 c0 33 12 f0       	push   $0xf01233c0
f01031a8:	e8 b2 31 00 00       	call   f010635f <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f01031ad:	f3 90                	pause  
}
f01031af:	83 c4 10             	add    $0x10,%esp
f01031b2:	c9                   	leave  
f01031b3:	c3                   	ret    

f01031b4 <envid2env>:
{
f01031b4:	f3 0f 1e fb          	endbr32 
f01031b8:	55                   	push   %ebp
f01031b9:	89 e5                	mov    %esp,%ebp
f01031bb:	56                   	push   %esi
f01031bc:	53                   	push   %ebx
f01031bd:	8b 75 08             	mov    0x8(%ebp),%esi
f01031c0:	8b 45 10             	mov    0x10(%ebp),%eax
	if (envid == 0) {
f01031c3:	85 f6                	test   %esi,%esi
f01031c5:	74 2e                	je     f01031f5 <envid2env+0x41>
	e = &envs[ENVX(envid)];
f01031c7:	89 f3                	mov    %esi,%ebx
f01031c9:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f01031cf:	c1 e3 07             	shl    $0x7,%ebx
f01031d2:	03 1d 44 e2 24 f0    	add    0xf024e244,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f01031d8:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f01031dc:	74 2e                	je     f010320c <envid2env+0x58>
f01031de:	39 73 48             	cmp    %esi,0x48(%ebx)
f01031e1:	75 29                	jne    f010320c <envid2env+0x58>
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f01031e3:	84 c0                	test   %al,%al
f01031e5:	75 35                	jne    f010321c <envid2env+0x68>
	*env_store = e;
f01031e7:	8b 45 0c             	mov    0xc(%ebp),%eax
f01031ea:	89 18                	mov    %ebx,(%eax)
	return 0;
f01031ec:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01031f1:	5b                   	pop    %ebx
f01031f2:	5e                   	pop    %esi
f01031f3:	5d                   	pop    %ebp
f01031f4:	c3                   	ret    
		*env_store = curenv;
f01031f5:	e8 fa 2d 00 00       	call   f0105ff4 <cpunum>
f01031fa:	6b c0 74             	imul   $0x74,%eax,%eax
f01031fd:	8b 80 28 00 25 f0    	mov    -0xfdaffd8(%eax),%eax
f0103203:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103206:	89 02                	mov    %eax,(%edx)
		return 0;
f0103208:	89 f0                	mov    %esi,%eax
f010320a:	eb e5                	jmp    f01031f1 <envid2env+0x3d>
		*env_store = 0;
f010320c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010320f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0103215:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f010321a:	eb d5                	jmp    f01031f1 <envid2env+0x3d>
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f010321c:	e8 d3 2d 00 00       	call   f0105ff4 <cpunum>
f0103221:	6b c0 74             	imul   $0x74,%eax,%eax
f0103224:	39 98 28 00 25 f0    	cmp    %ebx,-0xfdaffd8(%eax)
f010322a:	74 bb                	je     f01031e7 <envid2env+0x33>
f010322c:	8b 73 4c             	mov    0x4c(%ebx),%esi
f010322f:	e8 c0 2d 00 00       	call   f0105ff4 <cpunum>
f0103234:	6b c0 74             	imul   $0x74,%eax,%eax
f0103237:	8b 80 28 00 25 f0    	mov    -0xfdaffd8(%eax),%eax
f010323d:	3b 70 48             	cmp    0x48(%eax),%esi
f0103240:	74 a5                	je     f01031e7 <envid2env+0x33>
		*env_store = 0;
f0103242:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103245:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f010324b:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103250:	eb 9f                	jmp    f01031f1 <envid2env+0x3d>

f0103252 <env_init_percpu>:
{
f0103252:	f3 0f 1e fb          	endbr32 
f0103256:	55                   	push   %ebp
f0103257:	89 e5                	mov    %esp,%ebp
f0103259:	83 ec 08             	sub    $0x8,%esp
	lgdt(&gdt_pd);
f010325c:	b8 20 33 12 f0       	mov    $0xf0123320,%eax
f0103261:	e8 9e fc ff ff       	call   f0102f04 <lgdt>
	asm volatile("movw %%ax,%%gs" : : "a"(GD_UD | 3));
f0103266:	b8 23 00 00 00       	mov    $0x23,%eax
f010326b:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a"(GD_UD | 3));
f010326d:	8e e0                	mov    %eax,%fs
	asm volatile("movw %%ax,%%es" : : "a"(GD_KD));
f010326f:	b8 10 00 00 00       	mov    $0x10,%eax
f0103274:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a"(GD_KD));
f0103276:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a"(GD_KD));
f0103278:	8e d0                	mov    %eax,%ss
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i"(GD_KT));
f010327a:	ea 81 32 10 f0 08 00 	ljmp   $0x8,$0xf0103281
	lldt(0);
f0103281:	b8 00 00 00 00       	mov    $0x0,%eax
f0103286:	e8 7d fc ff ff       	call   f0102f08 <lldt>
}
f010328b:	c9                   	leave  
f010328c:	c3                   	ret    

f010328d <env_init>:
{
f010328d:	f3 0f 1e fb          	endbr32 
f0103291:	55                   	push   %ebp
f0103292:	89 e5                	mov    %esp,%ebp
f0103294:	83 ec 08             	sub    $0x8,%esp
		envs[i].env_id = 0;
f0103297:	8b 15 44 e2 24 f0    	mov    0xf024e244,%edx
f010329d:	8d 82 80 00 00 00    	lea    0x80(%edx),%eax
f01032a3:	81 c2 00 00 02 00    	add    $0x20000,%edx
f01032a9:	c7 40 c8 00 00 00 00 	movl   $0x0,-0x38(%eax)
		envs[i].env_status = ENV_FREE;
f01032b0:	c7 40 d4 00 00 00 00 	movl   $0x0,-0x2c(%eax)
		envs[i].env_link = &envs[i + 1];
f01032b7:	89 40 c4             	mov    %eax,-0x3c(%eax)
f01032ba:	83 e8 80             	sub    $0xffffff80,%eax
	for (size_t i = 0; i < NENV - 1; i++) {
f01032bd:	39 d0                	cmp    %edx,%eax
f01032bf:	75 e8                	jne    f01032a9 <env_init+0x1c>
	env_free_list = &envs[0];
f01032c1:	a1 44 e2 24 f0       	mov    0xf024e244,%eax
f01032c6:	a3 48 e2 24 f0       	mov    %eax,0xf024e248
	envs[NENV - 1].env_link = NULL;
f01032cb:	c7 80 c4 ff 01 00 00 	movl   $0x0,0x1ffc4(%eax)
f01032d2:	00 00 00 
	env_init_percpu();
f01032d5:	e8 78 ff ff ff       	call   f0103252 <env_init_percpu>
}
f01032da:	c9                   	leave  
f01032db:	c3                   	ret    

f01032dc <env_alloc>:
{
f01032dc:	f3 0f 1e fb          	endbr32 
f01032e0:	55                   	push   %ebp
f01032e1:	89 e5                	mov    %esp,%ebp
f01032e3:	53                   	push   %ebx
f01032e4:	83 ec 04             	sub    $0x4,%esp
	if (!(e = env_free_list))
f01032e7:	8b 1d 48 e2 24 f0    	mov    0xf024e248,%ebx
f01032ed:	85 db                	test   %ebx,%ebx
f01032ef:	0f 84 ea 00 00 00    	je     f01033df <env_alloc+0x103>
	if ((r = env_setup_vm(e)) < 0)
f01032f5:	89 d8                	mov    %ebx,%eax
f01032f7:	e8 8d fc ff ff       	call   f0102f89 <env_setup_vm>
f01032fc:	85 c0                	test   %eax,%eax
f01032fe:	0f 88 d6 00 00 00    	js     f01033da <env_alloc+0xfe>
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0103304:	8b 43 48             	mov    0x48(%ebx),%eax
f0103307:	05 00 10 00 00       	add    $0x1000,%eax
		generation = 1 << ENVGENSHIFT;
f010330c:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f0103311:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103316:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f0103319:	89 da                	mov    %ebx,%edx
f010331b:	2b 15 44 e2 24 f0    	sub    0xf024e244,%edx
f0103321:	c1 fa 07             	sar    $0x7,%edx
f0103324:	09 d0                	or     %edx,%eax
f0103326:	89 43 48             	mov    %eax,0x48(%ebx)
	e->env_parent_id = parent_id;
f0103329:	8b 45 0c             	mov    0xc(%ebp),%eax
f010332c:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f010332f:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0103336:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f010333d:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
	e->priority = (NENV / 4);
f0103344:	c7 43 60 00 01 00 00 	movl   $0x100,0x60(%ebx)
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f010334b:	83 ec 04             	sub    $0x4,%esp
f010334e:	6a 44                	push   $0x44
f0103350:	6a 00                	push   $0x0
f0103352:	53                   	push   %ebx
f0103353:	e8 0d 26 00 00       	call   f0105965 <memset>
	e->env_tf.tf_ds = GD_UD | 3;
f0103358:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f010335e:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0103364:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f010336a:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0103371:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	e->env_tf.tf_eflags = FL_IF;
f0103377:	c7 43 38 00 02 00 00 	movl   $0x200,0x38(%ebx)
	e->env_pgfault_upcall = 0;
f010337e:	c7 43 68 00 00 00 00 	movl   $0x0,0x68(%ebx)
	e->env_ipc_recving = 0;
f0103385:	c6 43 6c 00          	movb   $0x0,0x6c(%ebx)
	env_free_list = e->env_link;
f0103389:	8b 43 44             	mov    0x44(%ebx),%eax
f010338c:	a3 48 e2 24 f0       	mov    %eax,0xf024e248
	*newenv_store = e;
f0103391:	8b 45 08             	mov    0x8(%ebp),%eax
f0103394:	89 18                	mov    %ebx,(%eax)
	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103396:	8b 5b 48             	mov    0x48(%ebx),%ebx
f0103399:	e8 56 2c 00 00       	call   f0105ff4 <cpunum>
f010339e:	6b c0 74             	imul   $0x74,%eax,%eax
f01033a1:	83 c4 10             	add    $0x10,%esp
f01033a4:	ba 00 00 00 00       	mov    $0x0,%edx
f01033a9:	83 b8 28 00 25 f0 00 	cmpl   $0x0,-0xfdaffd8(%eax)
f01033b0:	74 11                	je     f01033c3 <env_alloc+0xe7>
f01033b2:	e8 3d 2c 00 00       	call   f0105ff4 <cpunum>
f01033b7:	6b c0 74             	imul   $0x74,%eax,%eax
f01033ba:	8b 80 28 00 25 f0    	mov    -0xfdaffd8(%eax),%eax
f01033c0:	8b 50 48             	mov    0x48(%eax),%edx
f01033c3:	83 ec 04             	sub    $0x4,%esp
f01033c6:	53                   	push   %ebx
f01033c7:	52                   	push   %edx
f01033c8:	68 9c 79 10 f0       	push   $0xf010799c
f01033cd:	e8 5b 05 00 00       	call   f010392d <cprintf>
	return 0;
f01033d2:	83 c4 10             	add    $0x10,%esp
f01033d5:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01033da:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01033dd:	c9                   	leave  
f01033de:	c3                   	ret    
		return -E_NO_FREE_ENV;
f01033df:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f01033e4:	eb f4                	jmp    f01033da <env_alloc+0xfe>

f01033e6 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f01033e6:	f3 0f 1e fb          	endbr32 
f01033ea:	55                   	push   %ebp
f01033eb:	89 e5                	mov    %esp,%ebp
f01033ed:	83 ec 20             	sub    $0x20,%esp
	// LAB 3: Your code here.
	struct Env *e;
	int err = env_alloc(&e, 0);
f01033f0:	6a 00                	push   $0x0
f01033f2:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01033f5:	50                   	push   %eax
f01033f6:	e8 e1 fe ff ff       	call   f01032dc <env_alloc>
	if (err < 0) {
f01033fb:	83 c4 10             	add    $0x10,%esp
f01033fe:	85 c0                	test   %eax,%eax
f0103400:	78 17                	js     f0103419 <env_create+0x33>
		panic("env_create: %e", err);
	}
	load_icode(e, binary);
f0103402:	8b 55 08             	mov    0x8(%ebp),%edx
f0103405:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103408:	e8 97 fc ff ff       	call   f01030a4 <load_icode>
	e->env_parent_id = 0;
f010340d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103410:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
}
f0103417:	c9                   	leave  
f0103418:	c3                   	ret    
		panic("env_create: %e", err);
f0103419:	50                   	push   %eax
f010341a:	68 b1 79 10 f0       	push   $0xf01079b1
f010341f:	68 9b 01 00 00       	push   $0x19b
f0103424:	68 74 79 10 f0       	push   $0xf0107974
f0103429:	e8 3c cc ff ff       	call   f010006a <_panic>

f010342e <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f010342e:	f3 0f 1e fb          	endbr32 
f0103432:	55                   	push   %ebp
f0103433:	89 e5                	mov    %esp,%ebp
f0103435:	57                   	push   %edi
f0103436:	56                   	push   %esi
f0103437:	53                   	push   %ebx
f0103438:	83 ec 1c             	sub    $0x1c,%esp
f010343b:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f010343e:	e8 b1 2b 00 00       	call   f0105ff4 <cpunum>
f0103443:	6b c0 74             	imul   $0x74,%eax,%eax
f0103446:	39 b8 28 00 25 f0    	cmp    %edi,-0xfdaffd8(%eax)
f010344c:	74 45                	je     f0103493 <env_free+0x65>
		lcr3(PADDR(kern_pgdir));

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f010344e:	8b 5f 48             	mov    0x48(%edi),%ebx
f0103451:	e8 9e 2b 00 00       	call   f0105ff4 <cpunum>
f0103456:	6b c0 74             	imul   $0x74,%eax,%eax
f0103459:	ba 00 00 00 00       	mov    $0x0,%edx
f010345e:	83 b8 28 00 25 f0 00 	cmpl   $0x0,-0xfdaffd8(%eax)
f0103465:	74 11                	je     f0103478 <env_free+0x4a>
f0103467:	e8 88 2b 00 00       	call   f0105ff4 <cpunum>
f010346c:	6b c0 74             	imul   $0x74,%eax,%eax
f010346f:	8b 80 28 00 25 f0    	mov    -0xfdaffd8(%eax),%eax
f0103475:	8b 50 48             	mov    0x48(%eax),%edx
f0103478:	83 ec 04             	sub    $0x4,%esp
f010347b:	53                   	push   %ebx
f010347c:	52                   	push   %edx
f010347d:	68 c0 79 10 f0       	push   $0xf01079c0
f0103482:	e8 a6 04 00 00       	call   f010392d <cprintf>
f0103487:	83 c4 10             	add    $0x10,%esp
f010348a:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103491:	eb 75                	jmp    f0103508 <env_free+0xda>
		lcr3(PADDR(kern_pgdir));
f0103493:	8b 0d 8c fe 24 f0    	mov    0xf024fe8c,%ecx
f0103499:	ba af 01 00 00       	mov    $0x1af,%edx
f010349e:	b8 74 79 10 f0       	mov    $0xf0107974,%eax
f01034a3:	e8 bf fa ff ff       	call   f0102f67 <_paddr>
f01034a8:	e8 5f fa ff ff       	call   f0102f0c <lcr3>
f01034ad:	eb 9f                	jmp    f010344e <env_free+0x20>
		pt = (pte_t *) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01034af:	83 ec 08             	sub    $0x8,%esp
f01034b2:	89 d8                	mov    %ebx,%eax
f01034b4:	c1 e0 0c             	shl    $0xc,%eax
f01034b7:	0b 45 e4             	or     -0x1c(%ebp),%eax
f01034ba:	50                   	push   %eax
f01034bb:	ff 77 64             	pushl  0x64(%edi)
f01034be:	e8 10 e6 ff ff       	call   f0101ad3 <page_remove>
f01034c3:	83 c4 10             	add    $0x10,%esp
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01034c6:	83 c3 01             	add    $0x1,%ebx
f01034c9:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f01034cf:	74 08                	je     f01034d9 <env_free+0xab>
			if (pt[pteno] & PTE_P)
f01034d1:	f6 04 9e 01          	testb  $0x1,(%esi,%ebx,4)
f01034d5:	74 ef                	je     f01034c6 <env_free+0x98>
f01034d7:	eb d6                	jmp    f01034af <env_free+0x81>
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f01034d9:	8b 47 64             	mov    0x64(%edi),%eax
f01034dc:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01034df:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
		page_decref(pa2page(pa));
f01034e6:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01034e9:	e8 04 fb ff ff       	call   f0102ff2 <pa2page>
f01034ee:	83 ec 0c             	sub    $0xc,%esp
f01034f1:	50                   	push   %eax
f01034f2:	e8 c2 e0 ff ff       	call   f01015b9 <page_decref>
f01034f7:	83 c4 10             	add    $0x10,%esp
f01034fa:	83 45 e0 04          	addl   $0x4,-0x20(%ebp)
f01034fe:	8b 45 e0             	mov    -0x20(%ebp),%eax
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103501:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f0103506:	74 38                	je     f0103540 <env_free+0x112>
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103508:	8b 47 64             	mov    0x64(%edi),%eax
f010350b:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010350e:	8b 04 10             	mov    (%eax,%edx,1),%eax
f0103511:	a8 01                	test   $0x1,%al
f0103513:	74 e5                	je     f01034fa <env_free+0xcc>
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103515:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010351a:	89 45 dc             	mov    %eax,-0x24(%ebp)
		pt = (pte_t *) KADDR(pa);
f010351d:	89 c1                	mov    %eax,%ecx
f010351f:	ba bd 01 00 00       	mov    $0x1bd,%edx
f0103524:	b8 74 79 10 f0       	mov    $0xf0107974,%eax
f0103529:	e8 ef f9 ff ff       	call   f0102f1d <_kaddr>
f010352e:	89 c6                	mov    %eax,%esi
f0103530:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103533:	c1 e0 14             	shl    $0x14,%eax
f0103536:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103539:	bb 00 00 00 00       	mov    $0x0,%ebx
f010353e:	eb 91                	jmp    f01034d1 <env_free+0xa3>
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103540:	8b 4f 64             	mov    0x64(%edi),%ecx
f0103543:	ba cb 01 00 00       	mov    $0x1cb,%edx
f0103548:	b8 74 79 10 f0       	mov    $0xf0107974,%eax
f010354d:	e8 15 fa ff ff       	call   f0102f67 <_paddr>
	e->env_pgdir = 0;
f0103552:	c7 47 64 00 00 00 00 	movl   $0x0,0x64(%edi)
	page_decref(pa2page(pa));
f0103559:	e8 94 fa ff ff       	call   f0102ff2 <pa2page>
f010355e:	83 ec 0c             	sub    $0xc,%esp
f0103561:	50                   	push   %eax
f0103562:	e8 52 e0 ff ff       	call   f01015b9 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103567:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f010356e:	a1 48 e2 24 f0       	mov    0xf024e248,%eax
f0103573:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0103576:	89 3d 48 e2 24 f0    	mov    %edi,0xf024e248
}
f010357c:	83 c4 10             	add    $0x10,%esp
f010357f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103582:	5b                   	pop    %ebx
f0103583:	5e                   	pop    %esi
f0103584:	5f                   	pop    %edi
f0103585:	5d                   	pop    %ebp
f0103586:	c3                   	ret    

f0103587 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0103587:	f3 0f 1e fb          	endbr32 
f010358b:	55                   	push   %ebp
f010358c:	89 e5                	mov    %esp,%ebp
f010358e:	53                   	push   %ebx
f010358f:	83 ec 04             	sub    $0x4,%esp
f0103592:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103595:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0103599:	74 21                	je     f01035bc <env_destroy+0x35>
		e->env_status = ENV_DYING;
		return;
	}

	env_free(e);
f010359b:	83 ec 0c             	sub    $0xc,%esp
f010359e:	53                   	push   %ebx
f010359f:	e8 8a fe ff ff       	call   f010342e <env_free>

	if (curenv == e) {
f01035a4:	e8 4b 2a 00 00       	call   f0105ff4 <cpunum>
f01035a9:	6b c0 74             	imul   $0x74,%eax,%eax
f01035ac:	83 c4 10             	add    $0x10,%esp
f01035af:	39 98 28 00 25 f0    	cmp    %ebx,-0xfdaffd8(%eax)
f01035b5:	74 1e                	je     f01035d5 <env_destroy+0x4e>
		curenv = NULL;
		sched_yield();
	}
}
f01035b7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01035ba:	c9                   	leave  
f01035bb:	c3                   	ret    
	if (e->env_status == ENV_RUNNING && curenv != e) {
f01035bc:	e8 33 2a 00 00       	call   f0105ff4 <cpunum>
f01035c1:	6b c0 74             	imul   $0x74,%eax,%eax
f01035c4:	39 98 28 00 25 f0    	cmp    %ebx,-0xfdaffd8(%eax)
f01035ca:	74 cf                	je     f010359b <env_destroy+0x14>
		e->env_status = ENV_DYING;
f01035cc:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f01035d3:	eb e2                	jmp    f01035b7 <env_destroy+0x30>
		curenv = NULL;
f01035d5:	e8 1a 2a 00 00       	call   f0105ff4 <cpunum>
f01035da:	6b c0 74             	imul   $0x74,%eax,%eax
f01035dd:	c7 80 28 00 25 f0 00 	movl   $0x0,-0xfdaffd8(%eax)
f01035e4:	00 00 00 
		sched_yield();
f01035e7:	e8 67 0f 00 00       	call   f0104553 <sched_yield>

f01035ec <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f01035ec:	f3 0f 1e fb          	endbr32 
f01035f0:	55                   	push   %ebp
f01035f1:	89 e5                	mov    %esp,%ebp
f01035f3:	53                   	push   %ebx
f01035f4:	83 ec 04             	sub    $0x4,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f01035f7:	e8 f8 29 00 00       	call   f0105ff4 <cpunum>
f01035fc:	6b c0 74             	imul   $0x74,%eax,%eax
f01035ff:	8b 98 28 00 25 f0    	mov    -0xfdaffd8(%eax),%ebx
f0103605:	e8 ea 29 00 00       	call   f0105ff4 <cpunum>
f010360a:	89 43 5c             	mov    %eax,0x5c(%ebx)

	asm volatile("\tmovl %0,%%esp\n"
f010360d:	8b 65 08             	mov    0x8(%ebp),%esp
f0103610:	61                   	popa   
f0103611:	07                   	pop    %es
f0103612:	1f                   	pop    %ds
f0103613:	83 c4 08             	add    $0x8,%esp
f0103616:	cf                   	iret   
	             "\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
	             "\tiret\n"
	             :
	             : "g"(tf)
	             : "memory");
	panic("iret failed"); /* mostly to placate the compiler */
f0103617:	83 ec 04             	sub    $0x4,%esp
f010361a:	68 d6 79 10 f0       	push   $0xf01079d6
f010361f:	68 03 02 00 00       	push   $0x203
f0103624:	68 74 79 10 f0       	push   $0xf0107974
f0103629:	e8 3c ca ff ff       	call   f010006a <_panic>

f010362e <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f010362e:	f3 0f 1e fb          	endbr32 
f0103632:	55                   	push   %ebp
f0103633:	89 e5                	mov    %esp,%ebp
f0103635:	83 ec 08             	sub    $0x8,%esp
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.

	if (curenv && curenv->env_status == ENV_RUNNING) {
f0103638:	e8 b7 29 00 00       	call   f0105ff4 <cpunum>
f010363d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103640:	83 b8 28 00 25 f0 00 	cmpl   $0x0,-0xfdaffd8(%eax)
f0103647:	74 14                	je     f010365d <env_run+0x2f>
f0103649:	e8 a6 29 00 00       	call   f0105ff4 <cpunum>
f010364e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103651:	8b 80 28 00 25 f0    	mov    -0xfdaffd8(%eax),%eax
f0103657:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f010365b:	74 78                	je     f01036d5 <env_run+0xa7>
		curenv->env_status = ENV_RUNNABLE;
	}
	curenv = e;
f010365d:	e8 92 29 00 00       	call   f0105ff4 <cpunum>
f0103662:	6b c0 74             	imul   $0x74,%eax,%eax
f0103665:	8b 55 08             	mov    0x8(%ebp),%edx
f0103668:	89 90 28 00 25 f0    	mov    %edx,-0xfdaffd8(%eax)
	curenv->env_status = ENV_RUNNING;
f010366e:	e8 81 29 00 00       	call   f0105ff4 <cpunum>
f0103673:	6b c0 74             	imul   $0x74,%eax,%eax
f0103676:	8b 80 28 00 25 f0    	mov    -0xfdaffd8(%eax),%eax
f010367c:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
	curenv->env_runs += 1;
f0103683:	e8 6c 29 00 00       	call   f0105ff4 <cpunum>
f0103688:	6b c0 74             	imul   $0x74,%eax,%eax
f010368b:	8b 80 28 00 25 f0    	mov    -0xfdaffd8(%eax),%eax
f0103691:	83 40 58 01          	addl   $0x1,0x58(%eax)

	lcr3(PADDR(curenv->env_pgdir));
f0103695:	e8 5a 29 00 00       	call   f0105ff4 <cpunum>
f010369a:	6b c0 74             	imul   $0x74,%eax,%eax
f010369d:	8b 80 28 00 25 f0    	mov    -0xfdaffd8(%eax),%eax
f01036a3:	8b 48 64             	mov    0x64(%eax),%ecx
f01036a6:	ba 29 02 00 00       	mov    $0x229,%edx
f01036ab:	b8 74 79 10 f0       	mov    $0xf0107974,%eax
f01036b0:	e8 b2 f8 ff ff       	call   f0102f67 <_paddr>
f01036b5:	e8 52 f8 ff ff       	call   f0102f0c <lcr3>

	unlock_kernel();
f01036ba:	e8 de fa ff ff       	call   f010319d <unlock_kernel>

	env_pop_tf(&curenv->env_tf);
f01036bf:	e8 30 29 00 00       	call   f0105ff4 <cpunum>
f01036c4:	83 ec 0c             	sub    $0xc,%esp
f01036c7:	6b c0 74             	imul   $0x74,%eax,%eax
f01036ca:	ff b0 28 00 25 f0    	pushl  -0xfdaffd8(%eax)
f01036d0:	e8 17 ff ff ff       	call   f01035ec <env_pop_tf>
		curenv->env_status = ENV_RUNNABLE;
f01036d5:	e8 1a 29 00 00       	call   f0105ff4 <cpunum>
f01036da:	6b c0 74             	imul   $0x74,%eax,%eax
f01036dd:	8b 80 28 00 25 f0    	mov    -0xfdaffd8(%eax),%eax
f01036e3:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
f01036ea:	e9 6e ff ff ff       	jmp    f010365d <env_run+0x2f>

f01036ef <inb>:
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01036ef:	89 c2                	mov    %eax,%edx
f01036f1:	ec                   	in     (%dx),%al
}
f01036f2:	c3                   	ret    

f01036f3 <outb>:
{
f01036f3:	89 c1                	mov    %eax,%ecx
f01036f5:	89 d0                	mov    %edx,%eax
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01036f7:	89 ca                	mov    %ecx,%edx
f01036f9:	ee                   	out    %al,(%dx)
}
f01036fa:	c3                   	ret    

f01036fb <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f01036fb:	f3 0f 1e fb          	endbr32 
f01036ff:	55                   	push   %ebp
f0103700:	89 e5                	mov    %esp,%ebp
f0103702:	83 ec 08             	sub    $0x8,%esp
	outb(IO_RTC, reg);
f0103705:	0f b6 55 08          	movzbl 0x8(%ebp),%edx
f0103709:	b8 70 00 00 00       	mov    $0x70,%eax
f010370e:	e8 e0 ff ff ff       	call   f01036f3 <outb>
	return inb(IO_RTC+1);
f0103713:	b8 71 00 00 00       	mov    $0x71,%eax
f0103718:	e8 d2 ff ff ff       	call   f01036ef <inb>
f010371d:	0f b6 c0             	movzbl %al,%eax
}
f0103720:	c9                   	leave  
f0103721:	c3                   	ret    

f0103722 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103722:	f3 0f 1e fb          	endbr32 
f0103726:	55                   	push   %ebp
f0103727:	89 e5                	mov    %esp,%ebp
f0103729:	83 ec 08             	sub    $0x8,%esp
	outb(IO_RTC, reg);
f010372c:	0f b6 55 08          	movzbl 0x8(%ebp),%edx
f0103730:	b8 70 00 00 00       	mov    $0x70,%eax
f0103735:	e8 b9 ff ff ff       	call   f01036f3 <outb>
	outb(IO_RTC+1, datum);
f010373a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
f010373e:	b8 71 00 00 00       	mov    $0x71,%eax
f0103743:	e8 ab ff ff ff       	call   f01036f3 <outb>
}
f0103748:	c9                   	leave  
f0103749:	c3                   	ret    

f010374a <outb>:
{
f010374a:	89 c1                	mov    %eax,%ecx
f010374c:	89 d0                	mov    %edx,%eax
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010374e:	89 ca                	mov    %ecx,%edx
f0103750:	ee                   	out    %al,(%dx)
}
f0103751:	c3                   	ret    

f0103752 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0103752:	f3 0f 1e fb          	endbr32 
f0103756:	55                   	push   %ebp
f0103757:	89 e5                	mov    %esp,%ebp
f0103759:	56                   	push   %esi
f010375a:	53                   	push   %ebx
f010375b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	irq_mask_8259A = mask;
f010375e:	66 89 1d a8 33 12 f0 	mov    %bx,0xf01233a8
	if (!didinit)
f0103765:	80 3d 4c e2 24 f0 00 	cmpb   $0x0,0xf024e24c
f010376c:	75 07                	jne    f0103775 <irq_setmask_8259A+0x23>
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
}
f010376e:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103771:	5b                   	pop    %ebx
f0103772:	5e                   	pop    %esi
f0103773:	5d                   	pop    %ebp
f0103774:	c3                   	ret    
f0103775:	89 de                	mov    %ebx,%esi
	outb(IO_PIC1+1, (char)mask);
f0103777:	0f b6 d3             	movzbl %bl,%edx
f010377a:	b8 21 00 00 00       	mov    $0x21,%eax
f010377f:	e8 c6 ff ff ff       	call   f010374a <outb>
	outb(IO_PIC2+1, (char)(mask >> 8));
f0103784:	0f b6 d7             	movzbl %bh,%edx
f0103787:	b8 a1 00 00 00       	mov    $0xa1,%eax
f010378c:	e8 b9 ff ff ff       	call   f010374a <outb>
	cprintf("enabled interrupts:");
f0103791:	83 ec 0c             	sub    $0xc,%esp
f0103794:	68 e2 79 10 f0       	push   $0xf01079e2
f0103799:	e8 8f 01 00 00       	call   f010392d <cprintf>
f010379e:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f01037a1:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f01037a6:	0f b7 f6             	movzwl %si,%esi
f01037a9:	f7 d6                	not    %esi
f01037ab:	eb 19                	jmp    f01037c6 <irq_setmask_8259A+0x74>
			cprintf(" %d", i);
f01037ad:	83 ec 08             	sub    $0x8,%esp
f01037b0:	53                   	push   %ebx
f01037b1:	68 f3 7e 10 f0       	push   $0xf0107ef3
f01037b6:	e8 72 01 00 00       	call   f010392d <cprintf>
f01037bb:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f01037be:	83 c3 01             	add    $0x1,%ebx
f01037c1:	83 fb 10             	cmp    $0x10,%ebx
f01037c4:	74 07                	je     f01037cd <irq_setmask_8259A+0x7b>
		if (~mask & (1<<i))
f01037c6:	0f a3 de             	bt     %ebx,%esi
f01037c9:	73 f3                	jae    f01037be <irq_setmask_8259A+0x6c>
f01037cb:	eb e0                	jmp    f01037ad <irq_setmask_8259A+0x5b>
	cprintf("\n");
f01037cd:	83 ec 0c             	sub    $0xc,%esp
f01037d0:	68 fe 78 10 f0       	push   $0xf01078fe
f01037d5:	e8 53 01 00 00       	call   f010392d <cprintf>
f01037da:	83 c4 10             	add    $0x10,%esp
f01037dd:	eb 8f                	jmp    f010376e <irq_setmask_8259A+0x1c>

f01037df <pic_init>:
{
f01037df:	f3 0f 1e fb          	endbr32 
f01037e3:	55                   	push   %ebp
f01037e4:	89 e5                	mov    %esp,%ebp
f01037e6:	83 ec 08             	sub    $0x8,%esp
	didinit = 1;
f01037e9:	c6 05 4c e2 24 f0 01 	movb   $0x1,0xf024e24c
	outb(IO_PIC1+1, 0xFF);
f01037f0:	ba ff 00 00 00       	mov    $0xff,%edx
f01037f5:	b8 21 00 00 00       	mov    $0x21,%eax
f01037fa:	e8 4b ff ff ff       	call   f010374a <outb>
	outb(IO_PIC2+1, 0xFF);
f01037ff:	ba ff 00 00 00       	mov    $0xff,%edx
f0103804:	b8 a1 00 00 00       	mov    $0xa1,%eax
f0103809:	e8 3c ff ff ff       	call   f010374a <outb>
	outb(IO_PIC1, 0x11);
f010380e:	ba 11 00 00 00       	mov    $0x11,%edx
f0103813:	b8 20 00 00 00       	mov    $0x20,%eax
f0103818:	e8 2d ff ff ff       	call   f010374a <outb>
	outb(IO_PIC1+1, IRQ_OFFSET);
f010381d:	ba 20 00 00 00       	mov    $0x20,%edx
f0103822:	b8 21 00 00 00       	mov    $0x21,%eax
f0103827:	e8 1e ff ff ff       	call   f010374a <outb>
	outb(IO_PIC1+1, 1<<IRQ_SLAVE);
f010382c:	ba 04 00 00 00       	mov    $0x4,%edx
f0103831:	b8 21 00 00 00       	mov    $0x21,%eax
f0103836:	e8 0f ff ff ff       	call   f010374a <outb>
	outb(IO_PIC1+1, 0x3);
f010383b:	ba 03 00 00 00       	mov    $0x3,%edx
f0103840:	b8 21 00 00 00       	mov    $0x21,%eax
f0103845:	e8 00 ff ff ff       	call   f010374a <outb>
	outb(IO_PIC2, 0x11);			// ICW1
f010384a:	ba 11 00 00 00       	mov    $0x11,%edx
f010384f:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0103854:	e8 f1 fe ff ff       	call   f010374a <outb>
	outb(IO_PIC2+1, IRQ_OFFSET + 8);	// ICW2
f0103859:	ba 28 00 00 00       	mov    $0x28,%edx
f010385e:	b8 a1 00 00 00       	mov    $0xa1,%eax
f0103863:	e8 e2 fe ff ff       	call   f010374a <outb>
	outb(IO_PIC2+1, IRQ_SLAVE);		// ICW3
f0103868:	ba 02 00 00 00       	mov    $0x2,%edx
f010386d:	b8 a1 00 00 00       	mov    $0xa1,%eax
f0103872:	e8 d3 fe ff ff       	call   f010374a <outb>
	outb(IO_PIC2+1, 0x01);			// ICW4
f0103877:	ba 01 00 00 00       	mov    $0x1,%edx
f010387c:	b8 a1 00 00 00       	mov    $0xa1,%eax
f0103881:	e8 c4 fe ff ff       	call   f010374a <outb>
	outb(IO_PIC1, 0x68);             /* clear specific mask */
f0103886:	ba 68 00 00 00       	mov    $0x68,%edx
f010388b:	b8 20 00 00 00       	mov    $0x20,%eax
f0103890:	e8 b5 fe ff ff       	call   f010374a <outb>
	outb(IO_PIC1, 0x0a);             /* read IRR by default */
f0103895:	ba 0a 00 00 00       	mov    $0xa,%edx
f010389a:	b8 20 00 00 00       	mov    $0x20,%eax
f010389f:	e8 a6 fe ff ff       	call   f010374a <outb>
	outb(IO_PIC2, 0x68);               /* OCW3 */
f01038a4:	ba 68 00 00 00       	mov    $0x68,%edx
f01038a9:	b8 a0 00 00 00       	mov    $0xa0,%eax
f01038ae:	e8 97 fe ff ff       	call   f010374a <outb>
	outb(IO_PIC2, 0x0a);               /* OCW3 */
f01038b3:	ba 0a 00 00 00       	mov    $0xa,%edx
f01038b8:	b8 a0 00 00 00       	mov    $0xa0,%eax
f01038bd:	e8 88 fe ff ff       	call   f010374a <outb>
	if (irq_mask_8259A != 0xFFFF)
f01038c2:	0f b7 05 a8 33 12 f0 	movzwl 0xf01233a8,%eax
f01038c9:	66 83 f8 ff          	cmp    $0xffff,%ax
f01038cd:	75 02                	jne    f01038d1 <pic_init+0xf2>
}
f01038cf:	c9                   	leave  
f01038d0:	c3                   	ret    
		irq_setmask_8259A(irq_mask_8259A);
f01038d1:	83 ec 0c             	sub    $0xc,%esp
f01038d4:	0f b7 c0             	movzwl %ax,%eax
f01038d7:	50                   	push   %eax
f01038d8:	e8 75 fe ff ff       	call   f0103752 <irq_setmask_8259A>
f01038dd:	83 c4 10             	add    $0x10,%esp
}
f01038e0:	eb ed                	jmp    f01038cf <pic_init+0xf0>

f01038e2 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01038e2:	f3 0f 1e fb          	endbr32 
f01038e6:	55                   	push   %ebp
f01038e7:	89 e5                	mov    %esp,%ebp
f01038e9:	53                   	push   %ebx
f01038ea:	83 ec 10             	sub    $0x10,%esp
f01038ed:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	cputchar(ch);
f01038f0:	ff 75 08             	pushl  0x8(%ebp)
f01038f3:	e8 0f d0 ff ff       	call   f0100907 <cputchar>
	(*cnt)++;
f01038f8:	83 03 01             	addl   $0x1,(%ebx)
}
f01038fb:	83 c4 10             	add    $0x10,%esp
f01038fe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103901:	c9                   	leave  
f0103902:	c3                   	ret    

f0103903 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103903:	f3 0f 1e fb          	endbr32 
f0103907:	55                   	push   %ebp
f0103908:	89 e5                	mov    %esp,%ebp
f010390a:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f010390d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103914:	ff 75 0c             	pushl  0xc(%ebp)
f0103917:	ff 75 08             	pushl  0x8(%ebp)
f010391a:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010391d:	50                   	push   %eax
f010391e:	68 e2 38 10 f0       	push   $0xf01038e2
f0103923:	e8 e6 19 00 00       	call   f010530e <vprintfmt>
	return cnt;
}
f0103928:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010392b:	c9                   	leave  
f010392c:	c3                   	ret    

f010392d <cprintf>:

int
cprintf(const char *fmt, ...)
{
f010392d:	f3 0f 1e fb          	endbr32 
f0103931:	55                   	push   %ebp
f0103932:	89 e5                	mov    %esp,%ebp
f0103934:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103937:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f010393a:	50                   	push   %eax
f010393b:	ff 75 08             	pushl  0x8(%ebp)
f010393e:	e8 c0 ff ff ff       	call   f0103903 <vcprintf>
	va_end(ap);

	return cnt;
}
f0103943:	c9                   	leave  
f0103944:	c3                   	ret    

f0103945 <lidt>:
	asm volatile("lidt (%0)" : : "r" (p));
f0103945:	0f 01 18             	lidtl  (%eax)
}
f0103948:	c3                   	ret    

f0103949 <ltr>:
	asm volatile("ltr %0" : : "r" (sel));
f0103949:	0f 00 d8             	ltr    %ax
}
f010394c:	c3                   	ret    

f010394d <rcr2>:
	asm volatile("movl %%cr2,%0" : "=r" (val));
f010394d:	0f 20 d0             	mov    %cr2,%eax
}
f0103950:	c3                   	ret    

f0103951 <read_eflags>:
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f0103951:	9c                   	pushf  
f0103952:	58                   	pop    %eax
}
f0103953:	c3                   	ret    

f0103954 <xchg>:
{
f0103954:	89 c1                	mov    %eax,%ecx
f0103956:	89 d0                	mov    %edx,%eax
	asm volatile("lock; xchgl %0, %1"
f0103958:	f0 87 01             	lock xchg %eax,(%ecx)
}
f010395b:	c3                   	ret    

f010395c <trapname>:
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < ARRAY_SIZE(excnames))
f010395c:	83 f8 13             	cmp    $0x13,%eax
f010395f:	76 20                	jbe    f0103981 <trapname+0x25>
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f0103961:	ba 05 7a 10 f0       	mov    $0xf0107a05,%edx
	if (trapno == T_SYSCALL)
f0103966:	83 f8 30             	cmp    $0x30,%eax
f0103969:	74 13                	je     f010397e <trapname+0x22>
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f010396b:	83 e8 20             	sub    $0x20,%eax
		return "Hardware Interrupt";
f010396e:	83 f8 0f             	cmp    $0xf,%eax
f0103971:	ba f6 79 10 f0       	mov    $0xf01079f6,%edx
f0103976:	b8 11 7a 10 f0       	mov    $0xf0107a11,%eax
f010397b:	0f 46 d0             	cmovbe %eax,%edx
	return "(unknown trap)";
}
f010397e:	89 d0                	mov    %edx,%eax
f0103980:	c3                   	ret    
		return excnames[trapno];
f0103981:	8b 14 85 80 7d 10 f0 	mov    -0xfef8280(,%eax,4),%edx
f0103988:	eb f4                	jmp    f010397e <trapname+0x22>

f010398a <lock_kernel>:
{
f010398a:	55                   	push   %ebp
f010398b:	89 e5                	mov    %esp,%ebp
f010398d:	83 ec 14             	sub    $0x14,%esp
	spin_lock(&kernel_lock);
f0103990:	68 c0 33 12 f0       	push   $0xf01233c0
f0103995:	e8 5f 29 00 00       	call   f01062f9 <spin_lock>
}
f010399a:	83 c4 10             	add    $0x10,%esp
f010399d:	c9                   	leave  
f010399e:	c3                   	ret    

f010399f <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f010399f:	f3 0f 1e fb          	endbr32 
f01039a3:	55                   	push   %ebp
f01039a4:	89 e5                	mov    %esp,%ebp
f01039a6:	56                   	push   %esi
f01039a7:	53                   	push   %ebx
	// get a triple fault.  If you set up an individual CPU's TSS
	// wrong, you may not get a fault until you try to return from
	// user space on that CPU.
	//
	// LAB 4: Your code here:
	struct Taskstate *cur_cpu_ts = &thiscpu->cpu_ts;
f01039a8:	e8 47 26 00 00       	call   f0105ff4 <cpunum>
f01039ad:	6b f0 74             	imul   $0x74,%eax,%esi
f01039b0:	8d 9e 2c 00 25 f0    	lea    -0xfdaffd4(%esi),%ebx
	int id = cpunum();
f01039b6:	e8 39 26 00 00       	call   f0105ff4 <cpunum>

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	cur_cpu_ts->ts_esp0 = KSTACKTOP - id * (KSTKSIZE + KSTKGAP);
f01039bb:	8d 96 20 00 25 f0    	lea    -0xfdaffe0(%esi),%edx
f01039c1:	89 c6                	mov    %eax,%esi
f01039c3:	c1 e6 10             	shl    $0x10,%esi
f01039c6:	b9 00 00 00 f0       	mov    $0xf0000000,%ecx
f01039cb:	29 f1                	sub    %esi,%ecx
f01039cd:	89 4a 10             	mov    %ecx,0x10(%edx)
	cur_cpu_ts->ts_ss0 = GD_KD;
f01039d0:	66 c7 42 14 10 00    	movw   $0x10,0x14(%edx)
	cur_cpu_ts->ts_iomb = sizeof(struct Taskstate);
f01039d6:	66 c7 42 72 68 00    	movw   $0x68,0x72(%edx)

	uint16_t idx = (GD_TSS0 >> 3) + id;
f01039dc:	83 c0 05             	add    $0x5,%eax
	uint16_t seg = idx << 3;
	// Initialize the TSS slot of the gdt.
	gdt[idx] = SEG16(
f01039df:	0f b7 d0             	movzwl %ax,%edx
f01039e2:	66 c7 04 d5 40 33 12 	movw   $0x67,-0xfedccc0(,%edx,8)
f01039e9:	f0 67 00 
f01039ec:	66 89 1c d5 42 33 12 	mov    %bx,-0xfedccbe(,%edx,8)
f01039f3:	f0 
f01039f4:	89 d9                	mov    %ebx,%ecx
f01039f6:	c1 e9 10             	shr    $0x10,%ecx
f01039f9:	88 0c d5 44 33 12 f0 	mov    %cl,-0xfedccbc(,%edx,8)
f0103a00:	c6 04 d5 46 33 12 f0 	movb   $0x40,-0xfedccba(,%edx,8)
f0103a07:	40 
f0103a08:	c1 eb 18             	shr    $0x18,%ebx
f0103a0b:	88 1c d5 47 33 12 f0 	mov    %bl,-0xfedccb9(,%edx,8)
	        STS_T32A, (uint32_t) cur_cpu_ts, sizeof(struct Taskstate) - 1, 0);
	gdt[idx].sd_s = 0;
f0103a12:	c6 04 d5 45 33 12 f0 	movb   $0x89,-0xfedccbb(,%edx,8)
f0103a19:	89 
	uint16_t seg = idx << 3;
f0103a1a:	c1 e0 03             	shl    $0x3,%eax

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(seg);
f0103a1d:	0f b7 c0             	movzwl %ax,%eax
f0103a20:	e8 24 ff ff ff       	call   f0103949 <ltr>

	// Load the IDT
	lidt(&idt_pd);
f0103a25:	b8 ac 33 12 f0       	mov    $0xf01233ac,%eax
f0103a2a:	e8 16 ff ff ff       	call   f0103945 <lidt>
}
f0103a2f:	5b                   	pop    %ebx
f0103a30:	5e                   	pop    %esi
f0103a31:	5d                   	pop    %ebp
f0103a32:	c3                   	ret    

f0103a33 <trap_init>:
{
f0103a33:	f3 0f 1e fb          	endbr32 
f0103a37:	55                   	push   %ebp
f0103a38:	89 e5                	mov    %esp,%ebp
f0103a3a:	83 ec 08             	sub    $0x8,%esp
	SETGATE(idt[T_DIVIDE], 0, GD_KT, trap_0, 0);
f0103a3d:	b8 b2 43 10 f0       	mov    $0xf01043b2,%eax
f0103a42:	66 a3 60 e2 24 f0    	mov    %ax,0xf024e260
f0103a48:	66 c7 05 62 e2 24 f0 	movw   $0x8,0xf024e262
f0103a4f:	08 00 
f0103a51:	c6 05 64 e2 24 f0 00 	movb   $0x0,0xf024e264
f0103a58:	c6 05 65 e2 24 f0 8e 	movb   $0x8e,0xf024e265
f0103a5f:	c1 e8 10             	shr    $0x10,%eax
f0103a62:	66 a3 66 e2 24 f0    	mov    %ax,0xf024e266
	SETGATE(idt[T_DEBUG], 0, GD_KT, trap_1, 0);
f0103a68:	b8 b8 43 10 f0       	mov    $0xf01043b8,%eax
f0103a6d:	66 a3 68 e2 24 f0    	mov    %ax,0xf024e268
f0103a73:	66 c7 05 6a e2 24 f0 	movw   $0x8,0xf024e26a
f0103a7a:	08 00 
f0103a7c:	c6 05 6c e2 24 f0 00 	movb   $0x0,0xf024e26c
f0103a83:	c6 05 6d e2 24 f0 8e 	movb   $0x8e,0xf024e26d
f0103a8a:	c1 e8 10             	shr    $0x10,%eax
f0103a8d:	66 a3 6e e2 24 f0    	mov    %ax,0xf024e26e
	SETGATE(idt[T_NMI], 0, GD_KT, trap_2, 0);
f0103a93:	b8 be 43 10 f0       	mov    $0xf01043be,%eax
f0103a98:	66 a3 70 e2 24 f0    	mov    %ax,0xf024e270
f0103a9e:	66 c7 05 72 e2 24 f0 	movw   $0x8,0xf024e272
f0103aa5:	08 00 
f0103aa7:	c6 05 74 e2 24 f0 00 	movb   $0x0,0xf024e274
f0103aae:	c6 05 75 e2 24 f0 8e 	movb   $0x8e,0xf024e275
f0103ab5:	c1 e8 10             	shr    $0x10,%eax
f0103ab8:	66 a3 76 e2 24 f0    	mov    %ax,0xf024e276
	SETGATE(idt[T_BRKPT], 0, GD_KT, trap_3, 3);
f0103abe:	b8 c4 43 10 f0       	mov    $0xf01043c4,%eax
f0103ac3:	66 a3 78 e2 24 f0    	mov    %ax,0xf024e278
f0103ac9:	66 c7 05 7a e2 24 f0 	movw   $0x8,0xf024e27a
f0103ad0:	08 00 
f0103ad2:	c6 05 7c e2 24 f0 00 	movb   $0x0,0xf024e27c
f0103ad9:	c6 05 7d e2 24 f0 ee 	movb   $0xee,0xf024e27d
f0103ae0:	c1 e8 10             	shr    $0x10,%eax
f0103ae3:	66 a3 7e e2 24 f0    	mov    %ax,0xf024e27e
	SETGATE(idt[T_OFLOW], 0, GD_KT, trap_4, 0);
f0103ae9:	b8 ca 43 10 f0       	mov    $0xf01043ca,%eax
f0103aee:	66 a3 80 e2 24 f0    	mov    %ax,0xf024e280
f0103af4:	66 c7 05 82 e2 24 f0 	movw   $0x8,0xf024e282
f0103afb:	08 00 
f0103afd:	c6 05 84 e2 24 f0 00 	movb   $0x0,0xf024e284
f0103b04:	c6 05 85 e2 24 f0 8e 	movb   $0x8e,0xf024e285
f0103b0b:	c1 e8 10             	shr    $0x10,%eax
f0103b0e:	66 a3 86 e2 24 f0    	mov    %ax,0xf024e286
	SETGATE(idt[T_BOUND], 0, GD_KT, trap_5, 0);
f0103b14:	b8 d0 43 10 f0       	mov    $0xf01043d0,%eax
f0103b19:	66 a3 88 e2 24 f0    	mov    %ax,0xf024e288
f0103b1f:	66 c7 05 8a e2 24 f0 	movw   $0x8,0xf024e28a
f0103b26:	08 00 
f0103b28:	c6 05 8c e2 24 f0 00 	movb   $0x0,0xf024e28c
f0103b2f:	c6 05 8d e2 24 f0 8e 	movb   $0x8e,0xf024e28d
f0103b36:	c1 e8 10             	shr    $0x10,%eax
f0103b39:	66 a3 8e e2 24 f0    	mov    %ax,0xf024e28e
	SETGATE(idt[T_ILLOP], 0, GD_KT, trap_6, 0);
f0103b3f:	b8 d6 43 10 f0       	mov    $0xf01043d6,%eax
f0103b44:	66 a3 90 e2 24 f0    	mov    %ax,0xf024e290
f0103b4a:	66 c7 05 92 e2 24 f0 	movw   $0x8,0xf024e292
f0103b51:	08 00 
f0103b53:	c6 05 94 e2 24 f0 00 	movb   $0x0,0xf024e294
f0103b5a:	c6 05 95 e2 24 f0 8e 	movb   $0x8e,0xf024e295
f0103b61:	c1 e8 10             	shr    $0x10,%eax
f0103b64:	66 a3 96 e2 24 f0    	mov    %ax,0xf024e296
	SETGATE(idt[T_DEVICE], 0, GD_KT, trap_7, 0);
f0103b6a:	b8 dc 43 10 f0       	mov    $0xf01043dc,%eax
f0103b6f:	66 a3 98 e2 24 f0    	mov    %ax,0xf024e298
f0103b75:	66 c7 05 9a e2 24 f0 	movw   $0x8,0xf024e29a
f0103b7c:	08 00 
f0103b7e:	c6 05 9c e2 24 f0 00 	movb   $0x0,0xf024e29c
f0103b85:	c6 05 9d e2 24 f0 8e 	movb   $0x8e,0xf024e29d
f0103b8c:	c1 e8 10             	shr    $0x10,%eax
f0103b8f:	66 a3 9e e2 24 f0    	mov    %ax,0xf024e29e
	SETGATE(idt[T_DBLFLT], 0, GD_KT, trap_8, 0);
f0103b95:	b8 e2 43 10 f0       	mov    $0xf01043e2,%eax
f0103b9a:	66 a3 a0 e2 24 f0    	mov    %ax,0xf024e2a0
f0103ba0:	66 c7 05 a2 e2 24 f0 	movw   $0x8,0xf024e2a2
f0103ba7:	08 00 
f0103ba9:	c6 05 a4 e2 24 f0 00 	movb   $0x0,0xf024e2a4
f0103bb0:	c6 05 a5 e2 24 f0 8e 	movb   $0x8e,0xf024e2a5
f0103bb7:	c1 e8 10             	shr    $0x10,%eax
f0103bba:	66 a3 a6 e2 24 f0    	mov    %ax,0xf024e2a6
	SETGATE(idt[9], 0, GD_KT, trap_9, 0);
f0103bc0:	b8 e6 43 10 f0       	mov    $0xf01043e6,%eax
f0103bc5:	66 a3 a8 e2 24 f0    	mov    %ax,0xf024e2a8
f0103bcb:	66 c7 05 aa e2 24 f0 	movw   $0x8,0xf024e2aa
f0103bd2:	08 00 
f0103bd4:	c6 05 ac e2 24 f0 00 	movb   $0x0,0xf024e2ac
f0103bdb:	c6 05 ad e2 24 f0 8e 	movb   $0x8e,0xf024e2ad
f0103be2:	c1 e8 10             	shr    $0x10,%eax
f0103be5:	66 a3 ae e2 24 f0    	mov    %ax,0xf024e2ae
	SETGATE(idt[T_TSS], 0, GD_KT, trap_10, 0);
f0103beb:	b8 ea 43 10 f0       	mov    $0xf01043ea,%eax
f0103bf0:	66 a3 b0 e2 24 f0    	mov    %ax,0xf024e2b0
f0103bf6:	66 c7 05 b2 e2 24 f0 	movw   $0x8,0xf024e2b2
f0103bfd:	08 00 
f0103bff:	c6 05 b4 e2 24 f0 00 	movb   $0x0,0xf024e2b4
f0103c06:	c6 05 b5 e2 24 f0 8e 	movb   $0x8e,0xf024e2b5
f0103c0d:	c1 e8 10             	shr    $0x10,%eax
f0103c10:	66 a3 b6 e2 24 f0    	mov    %ax,0xf024e2b6
	SETGATE(idt[T_SEGNP], 0, GD_KT, trap_11, 0);
f0103c16:	b8 ee 43 10 f0       	mov    $0xf01043ee,%eax
f0103c1b:	66 a3 b8 e2 24 f0    	mov    %ax,0xf024e2b8
f0103c21:	66 c7 05 ba e2 24 f0 	movw   $0x8,0xf024e2ba
f0103c28:	08 00 
f0103c2a:	c6 05 bc e2 24 f0 00 	movb   $0x0,0xf024e2bc
f0103c31:	c6 05 bd e2 24 f0 8e 	movb   $0x8e,0xf024e2bd
f0103c38:	c1 e8 10             	shr    $0x10,%eax
f0103c3b:	66 a3 be e2 24 f0    	mov    %ax,0xf024e2be
	SETGATE(idt[T_STACK], 0, GD_KT, trap_12, 0);
f0103c41:	b8 f2 43 10 f0       	mov    $0xf01043f2,%eax
f0103c46:	66 a3 c0 e2 24 f0    	mov    %ax,0xf024e2c0
f0103c4c:	66 c7 05 c2 e2 24 f0 	movw   $0x8,0xf024e2c2
f0103c53:	08 00 
f0103c55:	c6 05 c4 e2 24 f0 00 	movb   $0x0,0xf024e2c4
f0103c5c:	c6 05 c5 e2 24 f0 8e 	movb   $0x8e,0xf024e2c5
f0103c63:	c1 e8 10             	shr    $0x10,%eax
f0103c66:	66 a3 c6 e2 24 f0    	mov    %ax,0xf024e2c6
	SETGATE(idt[T_GPFLT], 0, GD_KT, trap_13, 0);
f0103c6c:	b8 f6 43 10 f0       	mov    $0xf01043f6,%eax
f0103c71:	66 a3 c8 e2 24 f0    	mov    %ax,0xf024e2c8
f0103c77:	66 c7 05 ca e2 24 f0 	movw   $0x8,0xf024e2ca
f0103c7e:	08 00 
f0103c80:	c6 05 cc e2 24 f0 00 	movb   $0x0,0xf024e2cc
f0103c87:	c6 05 cd e2 24 f0 8e 	movb   $0x8e,0xf024e2cd
f0103c8e:	c1 e8 10             	shr    $0x10,%eax
f0103c91:	66 a3 ce e2 24 f0    	mov    %ax,0xf024e2ce
	SETGATE(idt[T_PGFLT], 0, GD_KT, trap_14, 0);
f0103c97:	b8 fa 43 10 f0       	mov    $0xf01043fa,%eax
f0103c9c:	66 a3 d0 e2 24 f0    	mov    %ax,0xf024e2d0
f0103ca2:	66 c7 05 d2 e2 24 f0 	movw   $0x8,0xf024e2d2
f0103ca9:	08 00 
f0103cab:	c6 05 d4 e2 24 f0 00 	movb   $0x0,0xf024e2d4
f0103cb2:	c6 05 d5 e2 24 f0 8e 	movb   $0x8e,0xf024e2d5
f0103cb9:	c1 e8 10             	shr    $0x10,%eax
f0103cbc:	66 a3 d6 e2 24 f0    	mov    %ax,0xf024e2d6
	SETGATE(idt[15], 0, GD_KT, trap_15, 0);
f0103cc2:	b8 fe 43 10 f0       	mov    $0xf01043fe,%eax
f0103cc7:	66 a3 d8 e2 24 f0    	mov    %ax,0xf024e2d8
f0103ccd:	66 c7 05 da e2 24 f0 	movw   $0x8,0xf024e2da
f0103cd4:	08 00 
f0103cd6:	c6 05 dc e2 24 f0 00 	movb   $0x0,0xf024e2dc
f0103cdd:	c6 05 dd e2 24 f0 8e 	movb   $0x8e,0xf024e2dd
f0103ce4:	c1 e8 10             	shr    $0x10,%eax
f0103ce7:	66 a3 de e2 24 f0    	mov    %ax,0xf024e2de
	SETGATE(idt[T_FPERR], 0, GD_KT, trap_16, 0);
f0103ced:	b8 04 44 10 f0       	mov    $0xf0104404,%eax
f0103cf2:	66 a3 e0 e2 24 f0    	mov    %ax,0xf024e2e0
f0103cf8:	66 c7 05 e2 e2 24 f0 	movw   $0x8,0xf024e2e2
f0103cff:	08 00 
f0103d01:	c6 05 e4 e2 24 f0 00 	movb   $0x0,0xf024e2e4
f0103d08:	c6 05 e5 e2 24 f0 8e 	movb   $0x8e,0xf024e2e5
f0103d0f:	c1 e8 10             	shr    $0x10,%eax
f0103d12:	66 a3 e6 e2 24 f0    	mov    %ax,0xf024e2e6
	SETGATE(idt[T_ALIGN], 0, GD_KT, trap_17, 0);
f0103d18:	b8 0a 44 10 f0       	mov    $0xf010440a,%eax
f0103d1d:	66 a3 e8 e2 24 f0    	mov    %ax,0xf024e2e8
f0103d23:	66 c7 05 ea e2 24 f0 	movw   $0x8,0xf024e2ea
f0103d2a:	08 00 
f0103d2c:	c6 05 ec e2 24 f0 00 	movb   $0x0,0xf024e2ec
f0103d33:	c6 05 ed e2 24 f0 8e 	movb   $0x8e,0xf024e2ed
f0103d3a:	c1 e8 10             	shr    $0x10,%eax
f0103d3d:	66 a3 ee e2 24 f0    	mov    %ax,0xf024e2ee
	SETGATE(idt[T_MCHK], 0, GD_KT, trap_18, 0);
f0103d43:	b8 0e 44 10 f0       	mov    $0xf010440e,%eax
f0103d48:	66 a3 f0 e2 24 f0    	mov    %ax,0xf024e2f0
f0103d4e:	66 c7 05 f2 e2 24 f0 	movw   $0x8,0xf024e2f2
f0103d55:	08 00 
f0103d57:	c6 05 f4 e2 24 f0 00 	movb   $0x0,0xf024e2f4
f0103d5e:	c6 05 f5 e2 24 f0 8e 	movb   $0x8e,0xf024e2f5
f0103d65:	c1 e8 10             	shr    $0x10,%eax
f0103d68:	66 a3 f6 e2 24 f0    	mov    %ax,0xf024e2f6
	SETGATE(idt[T_SIMDERR], 0, GD_KT, trap_19, 0);
f0103d6e:	b8 14 44 10 f0       	mov    $0xf0104414,%eax
f0103d73:	66 a3 f8 e2 24 f0    	mov    %ax,0xf024e2f8
f0103d79:	66 c7 05 fa e2 24 f0 	movw   $0x8,0xf024e2fa
f0103d80:	08 00 
f0103d82:	c6 05 fc e2 24 f0 00 	movb   $0x0,0xf024e2fc
f0103d89:	c6 05 fd e2 24 f0 8e 	movb   $0x8e,0xf024e2fd
f0103d90:	c1 e8 10             	shr    $0x10,%eax
f0103d93:	66 a3 fe e2 24 f0    	mov    %ax,0xf024e2fe
	SETGATE(idt[IRQ_OFFSET + IRQ_TIMER], 0, GD_KT, trap_32, 0);
f0103d99:	b8 1a 44 10 f0       	mov    $0xf010441a,%eax
f0103d9e:	66 a3 60 e3 24 f0    	mov    %ax,0xf024e360
f0103da4:	66 c7 05 62 e3 24 f0 	movw   $0x8,0xf024e362
f0103dab:	08 00 
f0103dad:	c6 05 64 e3 24 f0 00 	movb   $0x0,0xf024e364
f0103db4:	c6 05 65 e3 24 f0 8e 	movb   $0x8e,0xf024e365
f0103dbb:	c1 e8 10             	shr    $0x10,%eax
f0103dbe:	66 a3 66 e3 24 f0    	mov    %ax,0xf024e366
	SETGATE(idt[T_SYSCALL], 0, GD_KT, trap_48, 3);
f0103dc4:	b8 20 44 10 f0       	mov    $0xf0104420,%eax
f0103dc9:	66 a3 e0 e3 24 f0    	mov    %ax,0xf024e3e0
f0103dcf:	66 c7 05 e2 e3 24 f0 	movw   $0x8,0xf024e3e2
f0103dd6:	08 00 
f0103dd8:	c6 05 e4 e3 24 f0 00 	movb   $0x0,0xf024e3e4
f0103ddf:	c6 05 e5 e3 24 f0 ee 	movb   $0xee,0xf024e3e5
f0103de6:	c1 e8 10             	shr    $0x10,%eax
f0103de9:	66 a3 e6 e3 24 f0    	mov    %ax,0xf024e3e6
	trap_init_percpu();
f0103def:	e8 ab fb ff ff       	call   f010399f <trap_init_percpu>
}
f0103df4:	c9                   	leave  
f0103df5:	c3                   	ret    

f0103df6 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103df6:	f3 0f 1e fb          	endbr32 
f0103dfa:	55                   	push   %ebp
f0103dfb:	89 e5                	mov    %esp,%ebp
f0103dfd:	53                   	push   %ebx
f0103dfe:	83 ec 0c             	sub    $0xc,%esp
f0103e01:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103e04:	ff 33                	pushl  (%ebx)
f0103e06:	68 24 7a 10 f0       	push   $0xf0107a24
f0103e0b:	e8 1d fb ff ff       	call   f010392d <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103e10:	83 c4 08             	add    $0x8,%esp
f0103e13:	ff 73 04             	pushl  0x4(%ebx)
f0103e16:	68 33 7a 10 f0       	push   $0xf0107a33
f0103e1b:	e8 0d fb ff ff       	call   f010392d <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103e20:	83 c4 08             	add    $0x8,%esp
f0103e23:	ff 73 08             	pushl  0x8(%ebx)
f0103e26:	68 42 7a 10 f0       	push   $0xf0107a42
f0103e2b:	e8 fd fa ff ff       	call   f010392d <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103e30:	83 c4 08             	add    $0x8,%esp
f0103e33:	ff 73 0c             	pushl  0xc(%ebx)
f0103e36:	68 51 7a 10 f0       	push   $0xf0107a51
f0103e3b:	e8 ed fa ff ff       	call   f010392d <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103e40:	83 c4 08             	add    $0x8,%esp
f0103e43:	ff 73 10             	pushl  0x10(%ebx)
f0103e46:	68 60 7a 10 f0       	push   $0xf0107a60
f0103e4b:	e8 dd fa ff ff       	call   f010392d <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103e50:	83 c4 08             	add    $0x8,%esp
f0103e53:	ff 73 14             	pushl  0x14(%ebx)
f0103e56:	68 6f 7a 10 f0       	push   $0xf0107a6f
f0103e5b:	e8 cd fa ff ff       	call   f010392d <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103e60:	83 c4 08             	add    $0x8,%esp
f0103e63:	ff 73 18             	pushl  0x18(%ebx)
f0103e66:	68 7e 7a 10 f0       	push   $0xf0107a7e
f0103e6b:	e8 bd fa ff ff       	call   f010392d <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103e70:	83 c4 08             	add    $0x8,%esp
f0103e73:	ff 73 1c             	pushl  0x1c(%ebx)
f0103e76:	68 8d 7a 10 f0       	push   $0xf0107a8d
f0103e7b:	e8 ad fa ff ff       	call   f010392d <cprintf>
}
f0103e80:	83 c4 10             	add    $0x10,%esp
f0103e83:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103e86:	c9                   	leave  
f0103e87:	c3                   	ret    

f0103e88 <print_trapframe>:
{
f0103e88:	f3 0f 1e fb          	endbr32 
f0103e8c:	55                   	push   %ebp
f0103e8d:	89 e5                	mov    %esp,%ebp
f0103e8f:	56                   	push   %esi
f0103e90:	53                   	push   %ebx
f0103e91:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0103e94:	e8 5b 21 00 00       	call   f0105ff4 <cpunum>
f0103e99:	83 ec 04             	sub    $0x4,%esp
f0103e9c:	50                   	push   %eax
f0103e9d:	53                   	push   %ebx
f0103e9e:	68 c3 7a 10 f0       	push   $0xf0107ac3
f0103ea3:	e8 85 fa ff ff       	call   f010392d <cprintf>
	print_regs(&tf->tf_regs);
f0103ea8:	89 1c 24             	mov    %ebx,(%esp)
f0103eab:	e8 46 ff ff ff       	call   f0103df6 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103eb0:	83 c4 08             	add    $0x8,%esp
f0103eb3:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103eb7:	50                   	push   %eax
f0103eb8:	68 e1 7a 10 f0       	push   $0xf0107ae1
f0103ebd:	e8 6b fa ff ff       	call   f010392d <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103ec2:	83 c4 08             	add    $0x8,%esp
f0103ec5:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103ec9:	50                   	push   %eax
f0103eca:	68 f4 7a 10 f0       	push   $0xf0107af4
f0103ecf:	e8 59 fa ff ff       	call   f010392d <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103ed4:	8b 73 28             	mov    0x28(%ebx),%esi
f0103ed7:	89 f0                	mov    %esi,%eax
f0103ed9:	e8 7e fa ff ff       	call   f010395c <trapname>
f0103ede:	83 c4 0c             	add    $0xc,%esp
f0103ee1:	50                   	push   %eax
f0103ee2:	56                   	push   %esi
f0103ee3:	68 07 7b 10 f0       	push   $0xf0107b07
f0103ee8:	e8 40 fa ff ff       	call   f010392d <cprintf>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103eed:	83 c4 10             	add    $0x10,%esp
f0103ef0:	39 1d 60 ea 24 f0    	cmp    %ebx,0xf024ea60
f0103ef6:	0f 84 9f 00 00 00    	je     f0103f9b <print_trapframe+0x113>
	cprintf("  err  0x%08x", tf->tf_err);
f0103efc:	83 ec 08             	sub    $0x8,%esp
f0103eff:	ff 73 2c             	pushl  0x2c(%ebx)
f0103f02:	68 28 7b 10 f0       	push   $0xf0107b28
f0103f07:	e8 21 fa ff ff       	call   f010392d <cprintf>
	if (tf->tf_trapno == T_PGFLT)
f0103f0c:	83 c4 10             	add    $0x10,%esp
f0103f0f:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103f13:	0f 85 a7 00 00 00    	jne    f0103fc0 <print_trapframe+0x138>
		        tf->tf_err & 1 ? "protection" : "not-present");
f0103f19:	8b 43 2c             	mov    0x2c(%ebx),%eax
		cprintf(" [%s, %s, %s]\n",
f0103f1c:	a8 01                	test   $0x1,%al
f0103f1e:	b9 9c 7a 10 f0       	mov    $0xf0107a9c,%ecx
f0103f23:	ba a7 7a 10 f0       	mov    $0xf0107aa7,%edx
f0103f28:	0f 44 ca             	cmove  %edx,%ecx
f0103f2b:	a8 02                	test   $0x2,%al
f0103f2d:	be b3 7a 10 f0       	mov    $0xf0107ab3,%esi
f0103f32:	ba b9 7a 10 f0       	mov    $0xf0107ab9,%edx
f0103f37:	0f 45 d6             	cmovne %esi,%edx
f0103f3a:	a8 04                	test   $0x4,%al
f0103f3c:	b8 be 7a 10 f0       	mov    $0xf0107abe,%eax
f0103f41:	be e8 7b 10 f0       	mov    $0xf0107be8,%esi
f0103f46:	0f 44 c6             	cmove  %esi,%eax
f0103f49:	51                   	push   %ecx
f0103f4a:	52                   	push   %edx
f0103f4b:	50                   	push   %eax
f0103f4c:	68 36 7b 10 f0       	push   $0xf0107b36
f0103f51:	e8 d7 f9 ff ff       	call   f010392d <cprintf>
f0103f56:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103f59:	83 ec 08             	sub    $0x8,%esp
f0103f5c:	ff 73 30             	pushl  0x30(%ebx)
f0103f5f:	68 45 7b 10 f0       	push   $0xf0107b45
f0103f64:	e8 c4 f9 ff ff       	call   f010392d <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103f69:	83 c4 08             	add    $0x8,%esp
f0103f6c:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103f70:	50                   	push   %eax
f0103f71:	68 54 7b 10 f0       	push   $0xf0107b54
f0103f76:	e8 b2 f9 ff ff       	call   f010392d <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103f7b:	83 c4 08             	add    $0x8,%esp
f0103f7e:	ff 73 38             	pushl  0x38(%ebx)
f0103f81:	68 67 7b 10 f0       	push   $0xf0107b67
f0103f86:	e8 a2 f9 ff ff       	call   f010392d <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0103f8b:	83 c4 10             	add    $0x10,%esp
f0103f8e:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103f92:	75 3e                	jne    f0103fd2 <print_trapframe+0x14a>
}
f0103f94:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103f97:	5b                   	pop    %ebx
f0103f98:	5e                   	pop    %esi
f0103f99:	5d                   	pop    %ebp
f0103f9a:	c3                   	ret    
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103f9b:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103f9f:	0f 85 57 ff ff ff    	jne    f0103efc <print_trapframe+0x74>
		cprintf("  cr2  0x%08x\n", rcr2());
f0103fa5:	e8 a3 f9 ff ff       	call   f010394d <rcr2>
f0103faa:	83 ec 08             	sub    $0x8,%esp
f0103fad:	50                   	push   %eax
f0103fae:	68 19 7b 10 f0       	push   $0xf0107b19
f0103fb3:	e8 75 f9 ff ff       	call   f010392d <cprintf>
f0103fb8:	83 c4 10             	add    $0x10,%esp
f0103fbb:	e9 3c ff ff ff       	jmp    f0103efc <print_trapframe+0x74>
		cprintf("\n");
f0103fc0:	83 ec 0c             	sub    $0xc,%esp
f0103fc3:	68 fe 78 10 f0       	push   $0xf01078fe
f0103fc8:	e8 60 f9 ff ff       	call   f010392d <cprintf>
f0103fcd:	83 c4 10             	add    $0x10,%esp
f0103fd0:	eb 87                	jmp    f0103f59 <print_trapframe+0xd1>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0103fd2:	83 ec 08             	sub    $0x8,%esp
f0103fd5:	ff 73 3c             	pushl  0x3c(%ebx)
f0103fd8:	68 76 7b 10 f0       	push   $0xf0107b76
f0103fdd:	e8 4b f9 ff ff       	call   f010392d <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0103fe2:	83 c4 08             	add    $0x8,%esp
f0103fe5:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0103fe9:	50                   	push   %eax
f0103fea:	68 85 7b 10 f0       	push   $0xf0107b85
f0103fef:	e8 39 f9 ff ff       	call   f010392d <cprintf>
f0103ff4:	83 c4 10             	add    $0x10,%esp
}
f0103ff7:	eb 9b                	jmp    f0103f94 <print_trapframe+0x10c>

f0103ff9 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0103ff9:	f3 0f 1e fb          	endbr32 
f0103ffd:	55                   	push   %ebp
f0103ffe:	89 e5                	mov    %esp,%ebp
f0104000:	57                   	push   %edi
f0104001:	56                   	push   %esi
f0104002:	53                   	push   %ebx
f0104003:	83 ec 1c             	sub    $0x1c,%esp
f0104006:	8b 5d 08             	mov    0x8(%ebp),%ebx
	uint32_t fault_va;

	// Read processor's CR2 register to find the faulting address
	fault_va = rcr2();
f0104009:	e8 3f f9 ff ff       	call   f010394d <rcr2>

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	// si un page fault ocurre en el ring 0.
	if ((tf->tf_cs & 3) == 0) {
f010400e:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0104012:	74 5f                	je     f0104073 <page_fault_handler+0x7a>
f0104014:	89 c6                	mov    %eax,%esi
	//   user_mem_assert() and env_run() are useful here.
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	if (curenv->env_pgfault_upcall) {
f0104016:	e8 d9 1f 00 00       	call   f0105ff4 <cpunum>
f010401b:	6b c0 74             	imul   $0x74,%eax,%eax
f010401e:	8b 80 28 00 25 f0    	mov    -0xfdaffd8(%eax),%eax
f0104024:	83 78 68 00          	cmpl   $0x0,0x68(%eax)
f0104028:	75 60                	jne    f010408a <page_fault_handler+0x91>

		env_run(curenv);
		return;
	}
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f010402a:	8b 7b 30             	mov    0x30(%ebx),%edi
	        curenv->env_id,
f010402d:	e8 c2 1f 00 00       	call   f0105ff4 <cpunum>
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104032:	57                   	push   %edi
f0104033:	56                   	push   %esi
	        curenv->env_id,
f0104034:	6b c0 74             	imul   $0x74,%eax,%eax
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104037:	8b 80 28 00 25 f0    	mov    -0xfdaffd8(%eax),%eax
f010403d:	ff 70 48             	pushl  0x48(%eax)
f0104040:	68 54 7d 10 f0       	push   $0xf0107d54
f0104045:	e8 e3 f8 ff ff       	call   f010392d <cprintf>
	        fault_va,
	        tf->tf_eip);
	print_trapframe(tf);
f010404a:	89 1c 24             	mov    %ebx,(%esp)
f010404d:	e8 36 fe ff ff       	call   f0103e88 <print_trapframe>
	env_destroy(curenv);
f0104052:	e8 9d 1f 00 00       	call   f0105ff4 <cpunum>
f0104057:	83 c4 04             	add    $0x4,%esp
f010405a:	6b c0 74             	imul   $0x74,%eax,%eax
f010405d:	ff b0 28 00 25 f0    	pushl  -0xfdaffd8(%eax)
f0104063:	e8 1f f5 ff ff       	call   f0103587 <env_destroy>
f0104068:	83 c4 10             	add    $0x10,%esp
}
f010406b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010406e:	5b                   	pop    %ebx
f010406f:	5e                   	pop    %esi
f0104070:	5f                   	pop    %edi
f0104071:	5d                   	pop    %ebp
f0104072:	c3                   	ret    
		panic("page fault en ring 0");
f0104073:	83 ec 04             	sub    $0x4,%esp
f0104076:	68 98 7b 10 f0       	push   $0xf0107b98
f010407b:	68 60 01 00 00       	push   $0x160
f0104080:	68 ad 7b 10 f0       	push   $0xf0107bad
f0104085:	e8 e0 bf ff ff       	call   f010006a <_panic>
		if ((tf->tf_esp < UXSTACKTOP) &&
f010408a:	8b 43 3c             	mov    0x3c(%ebx),%eax
f010408d:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
f0104093:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f0104099:	0f 87 c0 00 00 00    	ja     f010415f <page_fault_handler+0x166>
			u = (struct UTrapframe *) (tf->tf_esp - 4 -
f010409f:	83 e8 38             	sub    $0x38,%eax
f01040a2:	89 c7                	mov    %eax,%edi
f01040a4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			user_mem_assert(curenv,
f01040a7:	e8 48 1f 00 00       	call   f0105ff4 <cpunum>
f01040ac:	6a 03                	push   $0x3
f01040ae:	6a 38                	push   $0x38
f01040b0:	57                   	push   %edi
f01040b1:	6b c0 74             	imul   $0x74,%eax,%eax
f01040b4:	ff b0 28 00 25 f0    	pushl  -0xfdaffd8(%eax)
f01040ba:	e8 f5 ed ff ff       	call   f0102eb4 <user_mem_assert>
f01040bf:	83 c4 10             	add    $0x10,%esp
		        curenv, (void *) curenv->env_pgfault_upcall, 4, PTE_P);
f01040c2:	e8 2d 1f 00 00       	call   f0105ff4 <cpunum>
f01040c7:	6b c0 74             	imul   $0x74,%eax,%eax
f01040ca:	8b 80 28 00 25 f0    	mov    -0xfdaffd8(%eax),%eax
f01040d0:	8b 78 68             	mov    0x68(%eax),%edi
f01040d3:	e8 1c 1f 00 00       	call   f0105ff4 <cpunum>
		user_mem_assert(
f01040d8:	6a 01                	push   $0x1
f01040da:	6a 04                	push   $0x4
f01040dc:	57                   	push   %edi
f01040dd:	6b c0 74             	imul   $0x74,%eax,%eax
f01040e0:	ff b0 28 00 25 f0    	pushl  -0xfdaffd8(%eax)
f01040e6:	e8 c9 ed ff ff       	call   f0102eb4 <user_mem_assert>
		u->utf_fault_va = fault_va;
f01040eb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01040ee:	89 32                	mov    %esi,(%edx)
		u->utf_err = tf->tf_err;
f01040f0:	8b 43 2c             	mov    0x2c(%ebx),%eax
f01040f3:	89 42 04             	mov    %eax,0x4(%edx)
		u->utf_regs = tf->tf_regs;
f01040f6:	8d 7a 08             	lea    0x8(%edx),%edi
f01040f9:	b9 08 00 00 00       	mov    $0x8,%ecx
f01040fe:	89 de                	mov    %ebx,%esi
f0104100:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		u->utf_eflags = tf->tf_eflags;
f0104102:	8b 43 38             	mov    0x38(%ebx),%eax
f0104105:	89 42 2c             	mov    %eax,0x2c(%edx)
		u->utf_eip = tf->tf_eip;
f0104108:	8b 43 30             	mov    0x30(%ebx),%eax
f010410b:	89 d6                	mov    %edx,%esi
f010410d:	89 42 28             	mov    %eax,0x28(%edx)
		u->utf_esp = tf->tf_esp;
f0104110:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104113:	89 42 30             	mov    %eax,0x30(%edx)
		curenv->env_tf.tf_eip = (uintptr_t) curenv->env_pgfault_upcall;
f0104116:	e8 d9 1e 00 00       	call   f0105ff4 <cpunum>
f010411b:	6b c0 74             	imul   $0x74,%eax,%eax
f010411e:	8b 80 28 00 25 f0    	mov    -0xfdaffd8(%eax),%eax
f0104124:	8b 58 68             	mov    0x68(%eax),%ebx
f0104127:	e8 c8 1e 00 00       	call   f0105ff4 <cpunum>
f010412c:	6b c0 74             	imul   $0x74,%eax,%eax
f010412f:	8b 80 28 00 25 f0    	mov    -0xfdaffd8(%eax),%eax
f0104135:	89 58 30             	mov    %ebx,0x30(%eax)
		curenv->env_tf.tf_esp = (uintptr_t) u;
f0104138:	e8 b7 1e 00 00       	call   f0105ff4 <cpunum>
f010413d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104140:	8b 80 28 00 25 f0    	mov    -0xfdaffd8(%eax),%eax
f0104146:	89 70 3c             	mov    %esi,0x3c(%eax)
		env_run(curenv);
f0104149:	e8 a6 1e 00 00       	call   f0105ff4 <cpunum>
f010414e:	83 c4 04             	add    $0x4,%esp
f0104151:	6b c0 74             	imul   $0x74,%eax,%eax
f0104154:	ff b0 28 00 25 f0    	pushl  -0xfdaffd8(%eax)
f010415a:	e8 cf f4 ff ff       	call   f010362e <env_run>
			user_mem_assert(curenv,
f010415f:	e8 90 1e 00 00       	call   f0105ff4 <cpunum>
f0104164:	6a 03                	push   $0x3
f0104166:	6a 34                	push   $0x34
f0104168:	68 cc ff bf ee       	push   $0xeebfffcc
f010416d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104170:	ff b0 28 00 25 f0    	pushl  -0xfdaffd8(%eax)
f0104176:	e8 39 ed ff ff       	call   f0102eb4 <user_mem_assert>
f010417b:	83 c4 10             	add    $0x10,%esp
			u = (struct UTrapframe *) (UXSTACKTOP -
f010417e:	c7 45 e4 cc ff bf ee 	movl   $0xeebfffcc,-0x1c(%ebp)
f0104185:	e9 38 ff ff ff       	jmp    f01040c2 <page_fault_handler+0xc9>

f010418a <trap_dispatch>:
{
f010418a:	55                   	push   %ebp
f010418b:	89 e5                	mov    %esp,%ebp
f010418d:	53                   	push   %ebx
f010418e:	83 ec 04             	sub    $0x4,%esp
f0104191:	89 c3                	mov    %eax,%ebx
	if (tf->tf_trapno == T_BRKPT) {
f0104193:	8b 40 28             	mov    0x28(%eax),%eax
f0104196:	83 f8 03             	cmp    $0x3,%eax
f0104199:	74 49                	je     f01041e4 <trap_dispatch+0x5a>
	if (tf->tf_trapno == T_PGFLT) {
f010419b:	83 f8 0e             	cmp    $0xe,%eax
f010419e:	74 52                	je     f01041f2 <trap_dispatch+0x68>
	if (tf->tf_trapno == T_SYSCALL) {
f01041a0:	83 f8 30             	cmp    $0x30,%eax
f01041a3:	74 5b                	je     f0104200 <trap_dispatch+0x76>
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f01041a5:	83 f8 27             	cmp    $0x27,%eax
f01041a8:	74 77                	je     f0104221 <trap_dispatch+0x97>
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER) {
f01041aa:	83 f8 20             	cmp    $0x20,%eax
f01041ad:	0f 84 88 00 00 00    	je     f010423b <trap_dispatch+0xb1>
	print_trapframe(tf);
f01041b3:	83 ec 0c             	sub    $0xc,%esp
f01041b6:	53                   	push   %ebx
f01041b7:	e8 cc fc ff ff       	call   f0103e88 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f01041bc:	83 c4 10             	add    $0x10,%esp
f01041bf:	66 83 7b 34 08       	cmpw   $0x8,0x34(%ebx)
f01041c4:	74 7f                	je     f0104245 <trap_dispatch+0xbb>
		env_destroy(curenv);
f01041c6:	e8 29 1e 00 00       	call   f0105ff4 <cpunum>
f01041cb:	83 ec 0c             	sub    $0xc,%esp
f01041ce:	6b c0 74             	imul   $0x74,%eax,%eax
f01041d1:	ff b0 28 00 25 f0    	pushl  -0xfdaffd8(%eax)
f01041d7:	e8 ab f3 ff ff       	call   f0103587 <env_destroy>
		return;
f01041dc:	83 c4 10             	add    $0x10,%esp
}
f01041df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01041e2:	c9                   	leave  
f01041e3:	c3                   	ret    
		monitor(tf);
f01041e4:	83 ec 0c             	sub    $0xc,%esp
f01041e7:	53                   	push   %ebx
f01041e8:	e8 4d c9 ff ff       	call   f0100b3a <monitor>
		return;
f01041ed:	83 c4 10             	add    $0x10,%esp
f01041f0:	eb ed                	jmp    f01041df <trap_dispatch+0x55>
		page_fault_handler(tf);
f01041f2:	83 ec 0c             	sub    $0xc,%esp
f01041f5:	53                   	push   %ebx
f01041f6:	e8 fe fd ff ff       	call   f0103ff9 <page_fault_handler>
		return;
f01041fb:	83 c4 10             	add    $0x10,%esp
f01041fe:	eb df                	jmp    f01041df <trap_dispatch+0x55>
		int resultado = syscall(regs->reg_eax,
f0104200:	83 ec 08             	sub    $0x8,%esp
f0104203:	ff 73 04             	pushl  0x4(%ebx)
f0104206:	ff 33                	pushl  (%ebx)
f0104208:	ff 73 10             	pushl  0x10(%ebx)
f010420b:	ff 73 18             	pushl  0x18(%ebx)
f010420e:	ff 73 14             	pushl  0x14(%ebx)
f0104211:	ff 73 1c             	pushl  0x1c(%ebx)
f0104214:	e8 db 0a 00 00       	call   f0104cf4 <syscall>
		regs->reg_eax = resultado;
f0104219:	89 43 1c             	mov    %eax,0x1c(%ebx)
		return;
f010421c:	83 c4 20             	add    $0x20,%esp
f010421f:	eb be                	jmp    f01041df <trap_dispatch+0x55>
		cprintf("Spurious interrupt on irq 7\n");
f0104221:	83 ec 0c             	sub    $0xc,%esp
f0104224:	68 b9 7b 10 f0       	push   $0xf0107bb9
f0104229:	e8 ff f6 ff ff       	call   f010392d <cprintf>
		print_trapframe(tf);
f010422e:	89 1c 24             	mov    %ebx,(%esp)
f0104231:	e8 52 fc ff ff       	call   f0103e88 <print_trapframe>
		return;
f0104236:	83 c4 10             	add    $0x10,%esp
f0104239:	eb a4                	jmp    f01041df <trap_dispatch+0x55>
		lapic_eoi();
f010423b:	e8 03 1f 00 00       	call   f0106143 <lapic_eoi>
		sched_yield();
f0104240:	e8 0e 03 00 00       	call   f0104553 <sched_yield>
		panic("unhandled trap in kernel");
f0104245:	83 ec 04             	sub    $0x4,%esp
f0104248:	68 d6 7b 10 f0       	push   $0xf0107bd6
f010424d:	68 0f 01 00 00       	push   $0x10f
f0104252:	68 ad 7b 10 f0       	push   $0xf0107bad
f0104257:	e8 0e be ff ff       	call   f010006a <_panic>

f010425c <trap>:
{
f010425c:	f3 0f 1e fb          	endbr32 
f0104260:	55                   	push   %ebp
f0104261:	89 e5                	mov    %esp,%ebp
f0104263:	57                   	push   %edi
f0104264:	56                   	push   %esi
f0104265:	8b 75 08             	mov    0x8(%ebp),%esi
	asm volatile("cld" ::: "cc");
f0104268:	fc                   	cld    
	if (panicstr)
f0104269:	83 3d 80 fe 24 f0 00 	cmpl   $0x0,0xf024fe80
f0104270:	74 01                	je     f0104273 <trap+0x17>
		asm volatile("hlt");
f0104272:	f4                   	hlt    
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f0104273:	e8 7c 1d 00 00       	call   f0105ff4 <cpunum>
f0104278:	6b c0 74             	imul   $0x74,%eax,%eax
f010427b:	05 24 00 25 f0       	add    $0xf0250024,%eax
f0104280:	ba 01 00 00 00       	mov    $0x1,%edx
f0104285:	e8 ca f6 ff ff       	call   f0103954 <xchg>
f010428a:	83 f8 02             	cmp    $0x2,%eax
f010428d:	74 52                	je     f01042e1 <trap+0x85>
	assert(!(read_eflags() & FL_IF));
f010428f:	e8 bd f6 ff ff       	call   f0103951 <read_eflags>
f0104294:	f6 c4 02             	test   $0x2,%ah
f0104297:	75 4f                	jne    f01042e8 <trap+0x8c>
	if ((tf->tf_cs & 3) == 3) {
f0104299:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f010429d:	83 e0 03             	and    $0x3,%eax
f01042a0:	66 83 f8 03          	cmp    $0x3,%ax
f01042a4:	74 5b                	je     f0104301 <trap+0xa5>
	last_tf = tf;
f01042a6:	89 35 60 ea 24 f0    	mov    %esi,0xf024ea60
	trap_dispatch(tf);
f01042ac:	89 f0                	mov    %esi,%eax
f01042ae:	e8 d7 fe ff ff       	call   f010418a <trap_dispatch>
	if (curenv && curenv->env_status == ENV_RUNNING)
f01042b3:	e8 3c 1d 00 00       	call   f0105ff4 <cpunum>
f01042b8:	6b c0 74             	imul   $0x74,%eax,%eax
f01042bb:	83 b8 28 00 25 f0 00 	cmpl   $0x0,-0xfdaffd8(%eax)
f01042c2:	74 18                	je     f01042dc <trap+0x80>
f01042c4:	e8 2b 1d 00 00       	call   f0105ff4 <cpunum>
f01042c9:	6b c0 74             	imul   $0x74,%eax,%eax
f01042cc:	8b 80 28 00 25 f0    	mov    -0xfdaffd8(%eax),%eax
f01042d2:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01042d6:	0f 84 bf 00 00 00    	je     f010439b <trap+0x13f>
		sched_yield();
f01042dc:	e8 72 02 00 00       	call   f0104553 <sched_yield>
		lock_kernel();
f01042e1:	e8 a4 f6 ff ff       	call   f010398a <lock_kernel>
f01042e6:	eb a7                	jmp    f010428f <trap+0x33>
	assert(!(read_eflags() & FL_IF));
f01042e8:	68 ef 7b 10 f0       	push   $0xf0107bef
f01042ed:	68 43 76 10 f0       	push   $0xf0107643
f01042f2:	68 29 01 00 00       	push   $0x129
f01042f7:	68 ad 7b 10 f0       	push   $0xf0107bad
f01042fc:	e8 69 bd ff ff       	call   f010006a <_panic>
		lock_kernel();
f0104301:	e8 84 f6 ff ff       	call   f010398a <lock_kernel>
		assert(curenv);
f0104306:	e8 e9 1c 00 00       	call   f0105ff4 <cpunum>
f010430b:	6b c0 74             	imul   $0x74,%eax,%eax
f010430e:	83 b8 28 00 25 f0 00 	cmpl   $0x0,-0xfdaffd8(%eax)
f0104315:	74 3e                	je     f0104355 <trap+0xf9>
		if (curenv->env_status == ENV_DYING) {
f0104317:	e8 d8 1c 00 00       	call   f0105ff4 <cpunum>
f010431c:	6b c0 74             	imul   $0x74,%eax,%eax
f010431f:	8b 80 28 00 25 f0    	mov    -0xfdaffd8(%eax),%eax
f0104325:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0104329:	74 43                	je     f010436e <trap+0x112>
		curenv->env_tf = *tf;
f010432b:	e8 c4 1c 00 00       	call   f0105ff4 <cpunum>
f0104330:	6b c0 74             	imul   $0x74,%eax,%eax
f0104333:	8b 80 28 00 25 f0    	mov    -0xfdaffd8(%eax),%eax
f0104339:	b9 11 00 00 00       	mov    $0x11,%ecx
f010433e:	89 c7                	mov    %eax,%edi
f0104340:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		tf = &curenv->env_tf;
f0104342:	e8 ad 1c 00 00       	call   f0105ff4 <cpunum>
f0104347:	6b c0 74             	imul   $0x74,%eax,%eax
f010434a:	8b b0 28 00 25 f0    	mov    -0xfdaffd8(%eax),%esi
f0104350:	e9 51 ff ff ff       	jmp    f01042a6 <trap+0x4a>
		assert(curenv);
f0104355:	68 08 7c 10 f0       	push   $0xf0107c08
f010435a:	68 43 76 10 f0       	push   $0xf0107643
f010435f:	68 31 01 00 00       	push   $0x131
f0104364:	68 ad 7b 10 f0       	push   $0xf0107bad
f0104369:	e8 fc bc ff ff       	call   f010006a <_panic>
			env_free(curenv);
f010436e:	e8 81 1c 00 00       	call   f0105ff4 <cpunum>
f0104373:	83 ec 0c             	sub    $0xc,%esp
f0104376:	6b c0 74             	imul   $0x74,%eax,%eax
f0104379:	ff b0 28 00 25 f0    	pushl  -0xfdaffd8(%eax)
f010437f:	e8 aa f0 ff ff       	call   f010342e <env_free>
			curenv = NULL;
f0104384:	e8 6b 1c 00 00       	call   f0105ff4 <cpunum>
f0104389:	6b c0 74             	imul   $0x74,%eax,%eax
f010438c:	c7 80 28 00 25 f0 00 	movl   $0x0,-0xfdaffd8(%eax)
f0104393:	00 00 00 
			sched_yield();
f0104396:	e8 b8 01 00 00       	call   f0104553 <sched_yield>
		env_run(curenv);
f010439b:	e8 54 1c 00 00       	call   f0105ff4 <cpunum>
f01043a0:	83 ec 0c             	sub    $0xc,%esp
f01043a3:	6b c0 74             	imul   $0x74,%eax,%eax
f01043a6:	ff b0 28 00 25 f0    	pushl  -0xfdaffd8(%eax)
f01043ac:	e8 7d f2 ff ff       	call   f010362e <env_run>
f01043b1:	90                   	nop

f01043b2 <trap_0>:
.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
TRAPHANDLER_NOEC(trap_0, T_DIVIDE);
f01043b2:	6a 00                	push   $0x0
f01043b4:	6a 00                	push   $0x0
f01043b6:	eb 6e                	jmp    f0104426 <_alltraps>

f01043b8 <trap_1>:
TRAPHANDLER_NOEC(trap_1, T_DEBUG);
f01043b8:	6a 00                	push   $0x0
f01043ba:	6a 01                	push   $0x1
f01043bc:	eb 68                	jmp    f0104426 <_alltraps>

f01043be <trap_2>:
TRAPHANDLER_NOEC(trap_2, T_NMI);
f01043be:	6a 00                	push   $0x0
f01043c0:	6a 02                	push   $0x2
f01043c2:	eb 62                	jmp    f0104426 <_alltraps>

f01043c4 <trap_3>:
TRAPHANDLER_NOEC(trap_3, T_BRKPT);
f01043c4:	6a 00                	push   $0x0
f01043c6:	6a 03                	push   $0x3
f01043c8:	eb 5c                	jmp    f0104426 <_alltraps>

f01043ca <trap_4>:
TRAPHANDLER_NOEC(trap_4, T_OFLOW);
f01043ca:	6a 00                	push   $0x0
f01043cc:	6a 04                	push   $0x4
f01043ce:	eb 56                	jmp    f0104426 <_alltraps>

f01043d0 <trap_5>:
TRAPHANDLER_NOEC(trap_5, T_BOUND);
f01043d0:	6a 00                	push   $0x0
f01043d2:	6a 05                	push   $0x5
f01043d4:	eb 50                	jmp    f0104426 <_alltraps>

f01043d6 <trap_6>:
TRAPHANDLER_NOEC(trap_6, T_ILLOP);
f01043d6:	6a 00                	push   $0x0
f01043d8:	6a 06                	push   $0x6
f01043da:	eb 4a                	jmp    f0104426 <_alltraps>

f01043dc <trap_7>:
TRAPHANDLER_NOEC(trap_7, T_DEVICE);
f01043dc:	6a 00                	push   $0x0
f01043de:	6a 07                	push   $0x7
f01043e0:	eb 44                	jmp    f0104426 <_alltraps>

f01043e2 <trap_8>:
TRAPHANDLER(trap_8, T_DBLFLT);
f01043e2:	6a 08                	push   $0x8
f01043e4:	eb 40                	jmp    f0104426 <_alltraps>

f01043e6 <trap_9>:
TRAPHANDLER(trap_9, 9);
f01043e6:	6a 09                	push   $0x9
f01043e8:	eb 3c                	jmp    f0104426 <_alltraps>

f01043ea <trap_10>:
TRAPHANDLER(trap_10, T_TSS);
f01043ea:	6a 0a                	push   $0xa
f01043ec:	eb 38                	jmp    f0104426 <_alltraps>

f01043ee <trap_11>:
TRAPHANDLER(trap_11, T_SEGNP);
f01043ee:	6a 0b                	push   $0xb
f01043f0:	eb 34                	jmp    f0104426 <_alltraps>

f01043f2 <trap_12>:
TRAPHANDLER(trap_12, T_STACK);
f01043f2:	6a 0c                	push   $0xc
f01043f4:	eb 30                	jmp    f0104426 <_alltraps>

f01043f6 <trap_13>:
TRAPHANDLER(trap_13, T_GPFLT);
f01043f6:	6a 0d                	push   $0xd
f01043f8:	eb 2c                	jmp    f0104426 <_alltraps>

f01043fa <trap_14>:
TRAPHANDLER(trap_14, T_PGFLT);
f01043fa:	6a 0e                	push   $0xe
f01043fc:	eb 28                	jmp    f0104426 <_alltraps>

f01043fe <trap_15>:
TRAPHANDLER_NOEC(trap_15, 15)
f01043fe:	6a 00                	push   $0x0
f0104400:	6a 0f                	push   $0xf
f0104402:	eb 22                	jmp    f0104426 <_alltraps>

f0104404 <trap_16>:
TRAPHANDLER_NOEC(trap_16, T_FPERR)
f0104404:	6a 00                	push   $0x0
f0104406:	6a 10                	push   $0x10
f0104408:	eb 1c                	jmp    f0104426 <_alltraps>

f010440a <trap_17>:
TRAPHANDLER(trap_17, T_ALIGN)
f010440a:	6a 11                	push   $0x11
f010440c:	eb 18                	jmp    f0104426 <_alltraps>

f010440e <trap_18>:
TRAPHANDLER_NOEC(trap_18, T_MCHK)
f010440e:	6a 00                	push   $0x0
f0104410:	6a 12                	push   $0x12
f0104412:	eb 12                	jmp    f0104426 <_alltraps>

f0104414 <trap_19>:
TRAPHANDLER_NOEC(trap_19, T_SIMDERR)
f0104414:	6a 00                	push   $0x0
f0104416:	6a 13                	push   $0x13
f0104418:	eb 0c                	jmp    f0104426 <_alltraps>

f010441a <trap_32>:

//IRQ
TRAPHANDLER_NOEC(trap_32, IRQ_TIMER + IRQ_OFFSET);
f010441a:	6a 00                	push   $0x0
f010441c:	6a 20                	push   $0x20
f010441e:	eb 06                	jmp    f0104426 <_alltraps>

f0104420 <trap_48>:
// SYSCALL
TRAPHANDLER_NOEC(trap_48, T_SYSCALL)
f0104420:	6a 00                	push   $0x0
f0104422:	6a 30                	push   $0x30
f0104424:	eb 00                	jmp    f0104426 <_alltraps>

f0104426 <_alltraps>:
/*
 * Lab 3: Your code here for _alltraps
 */
 _alltraps:
 // push de los valores
 pushl %ds
f0104426:	1e                   	push   %ds
 pushl %es
f0104427:	06                   	push   %es
 pushal
f0104428:	60                   	pusha  

 // cargo GD_KD en %ds y %es
 mov $GD_KD, %ax
f0104429:	66 b8 10 00          	mov    $0x10,%ax
 movw %ax, %ds
f010442d:	8e d8                	mov    %eax,%ds
 movw %ax, %es
f010442f:	8e c0                	mov    %eax,%es

 // push de los registros que faltan
 pushl %esp
f0104431:	54                   	push   %esp

 // llamada a trap
 call trap
f0104432:	e8 25 fe ff ff       	call   f010425c <trap>

f0104437 <lcr3>:
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0104437:	0f 22 d8             	mov    %eax,%cr3
}
f010443a:	c3                   	ret    

f010443b <xchg>:
{
f010443b:	89 c1                	mov    %eax,%ecx
f010443d:	89 d0                	mov    %edx,%eax
	asm volatile("lock; xchgl %0, %1"
f010443f:	f0 87 01             	lock xchg %eax,(%ecx)
}
f0104442:	c3                   	ret    

f0104443 <_paddr>:
	if ((uint32_t)kva < KERNBASE)
f0104443:	81 f9 ff ff ff ef    	cmp    $0xefffffff,%ecx
f0104449:	76 07                	jbe    f0104452 <_paddr+0xf>
	return (physaddr_t)kva - KERNBASE;
f010444b:	8d 81 00 00 00 10    	lea    0x10000000(%ecx),%eax
}
f0104451:	c3                   	ret    
{
f0104452:	55                   	push   %ebp
f0104453:	89 e5                	mov    %esp,%ebp
f0104455:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104458:	51                   	push   %ecx
f0104459:	68 10 67 10 f0       	push   $0xf0106710
f010445e:	52                   	push   %edx
f010445f:	50                   	push   %eax
f0104460:	e8 05 bc ff ff       	call   f010006a <_panic>

f0104465 <unlock_kernel>:
{
f0104465:	55                   	push   %ebp
f0104466:	89 e5                	mov    %esp,%ebp
f0104468:	83 ec 14             	sub    $0x14,%esp
	spin_unlock(&kernel_lock);
f010446b:	68 c0 33 12 f0       	push   $0xf01233c0
f0104470:	e8 ea 1e 00 00       	call   f010635f <spin_unlock>
	asm volatile("pause");
f0104475:	f3 90                	pause  
}
f0104477:	83 c4 10             	add    $0x10,%esp
f010447a:	c9                   	leave  
f010447b:	c3                   	ret    

f010447c <rand>:
unsigned long int next = 1;

// Choose a user environment to run and run it.
unsigned int
rand()
{  // le puse numeros primos
f010447c:	f3 0f 1e fb          	endbr32 
	next = next * 1103515245 + 12345;
f0104480:	69 05 b4 33 12 f0 6d 	imul   $0x41c64e6d,0xf01233b4,%eax
f0104487:	4e c6 41 
f010448a:	05 39 30 00 00       	add    $0x3039,%eax
f010448f:	a3 b4 33 12 f0       	mov    %eax,0xf01233b4
	return ((unsigned) (next / 65536) % 32768);
f0104494:	c1 e8 10             	shr    $0x10,%eax
f0104497:	25 ff 7f 00 00       	and    $0x7fff,%eax
}
f010449c:	c3                   	ret    

f010449d <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f010449d:	f3 0f 1e fb          	endbr32 
f01044a1:	55                   	push   %ebp
f01044a2:	89 e5                	mov    %esp,%ebp
f01044a4:	83 ec 08             	sub    $0x8,%esp
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if ((envs[i].env_status == ENV_RUNNABLE ||
f01044a7:	8b 0d 44 e2 24 f0    	mov    0xf024e244,%ecx
	for (i = 0; i < NENV; i++) {
f01044ad:	b8 00 00 00 00       	mov    $0x0,%eax
		if ((envs[i].env_status == ENV_RUNNABLE ||
f01044b2:	89 c2                	mov    %eax,%edx
f01044b4:	c1 e2 07             	shl    $0x7,%edx
		     envs[i].env_status == ENV_RUNNING ||
f01044b7:	8b 54 11 54          	mov    0x54(%ecx,%edx,1),%edx
f01044bb:	83 ea 01             	sub    $0x1,%edx
		if ((envs[i].env_status == ENV_RUNNABLE ||
f01044be:	83 fa 02             	cmp    $0x2,%edx
f01044c1:	76 29                	jbe    f01044ec <sched_halt+0x4f>
	for (i = 0; i < NENV; i++) {
f01044c3:	83 c0 01             	add    $0x1,%eax
f01044c6:	3d 00 04 00 00       	cmp    $0x400,%eax
f01044cb:	75 e5                	jne    f01044b2 <sched_halt+0x15>
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
		cprintf("No runnable environments in the system!\n");
f01044cd:	83 ec 0c             	sub    $0xc,%esp
f01044d0:	68 d0 7d 10 f0       	push   $0xf0107dd0
f01044d5:	e8 53 f4 ff ff       	call   f010392d <cprintf>
f01044da:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f01044dd:	83 ec 0c             	sub    $0xc,%esp
f01044e0:	6a 00                	push   $0x0
f01044e2:	e8 53 c6 ff ff       	call   f0100b3a <monitor>
f01044e7:	83 c4 10             	add    $0x10,%esp
f01044ea:	eb f1                	jmp    f01044dd <sched_halt+0x40>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f01044ec:	e8 03 1b 00 00       	call   f0105ff4 <cpunum>
f01044f1:	6b c0 74             	imul   $0x74,%eax,%eax
f01044f4:	c7 80 28 00 25 f0 00 	movl   $0x0,-0xfdaffd8(%eax)
f01044fb:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f01044fe:	8b 0d 8c fe 24 f0    	mov    0xf024fe8c,%ecx
f0104504:	ba 69 00 00 00       	mov    $0x69,%edx
f0104509:	b8 f9 7d 10 f0       	mov    $0xf0107df9,%eax
f010450e:	e8 30 ff ff ff       	call   f0104443 <_paddr>
f0104513:	e8 1f ff ff ff       	call   f0104437 <lcr3>

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0104518:	e8 d7 1a 00 00       	call   f0105ff4 <cpunum>
f010451d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104520:	05 24 00 25 f0       	add    $0xf0250024,%eax
f0104525:	ba 02 00 00 00       	mov    $0x2,%edx
f010452a:	e8 0c ff ff ff       	call   f010443b <xchg>

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();
f010452f:	e8 31 ff ff ff       	call   f0104465 <unlock_kernel>
	             "sti\n"
	             "1:\n"
	             "hlt\n"
	             "jmp 1b\n"
	             :
	             : "a"(thiscpu->cpu_ts.ts_esp0));
f0104534:	e8 bb 1a 00 00       	call   f0105ff4 <cpunum>
f0104539:	6b c0 74             	imul   $0x74,%eax,%eax
	asm volatile("movl $0, %%ebp\n"
f010453c:	8b 80 30 00 25 f0    	mov    -0xfdaffd0(%eax),%eax
f0104542:	bd 00 00 00 00       	mov    $0x0,%ebp
f0104547:	89 c4                	mov    %eax,%esp
f0104549:	6a 00                	push   $0x0
f010454b:	6a 00                	push   $0x0
f010454d:	fb                   	sti    
f010454e:	f4                   	hlt    
f010454f:	eb fd                	jmp    f010454e <sched_halt+0xb1>
}
f0104551:	c9                   	leave  
f0104552:	c3                   	ret    

f0104553 <sched_yield>:
{
f0104553:	f3 0f 1e fb          	endbr32 
f0104557:	55                   	push   %ebp
f0104558:	89 e5                	mov    %esp,%ebp
f010455a:	57                   	push   %edi
f010455b:	56                   	push   %esi
f010455c:	53                   	push   %ebx
f010455d:	83 ec 1c             	sub    $0x1c,%esp
	if (curenv) {
f0104560:	e8 8f 1a 00 00       	call   f0105ff4 <cpunum>
f0104565:	6b c0 74             	imul   $0x74,%eax,%eax
	int indx = 0;
f0104568:	be 00 00 00 00       	mov    $0x0,%esi
	if (curenv) {
f010456d:	83 b8 28 00 25 f0 00 	cmpl   $0x0,-0xfdaffd8(%eax)
f0104574:	74 1a                	je     f0104590 <sched_yield+0x3d>
		indx = ENVX(curenv->env_id) + 1;
f0104576:	e8 79 1a 00 00       	call   f0105ff4 <cpunum>
f010457b:	6b c0 74             	imul   $0x74,%eax,%eax
f010457e:	8b 80 28 00 25 f0    	mov    -0xfdaffd8(%eax),%eax
f0104584:	8b 48 48             	mov    0x48(%eax),%ecx
f0104587:	81 e1 ff 03 00 00    	and    $0x3ff,%ecx
f010458d:	8d 71 01             	lea    0x1(%ecx),%esi
		if (envs[i].env_status == ENV_RUNNABLE ||
f0104590:	8b 0d 44 e2 24 f0    	mov    0xf024e244,%ecx
f0104596:	8d 41 54             	lea    0x54(%ecx),%eax
f0104599:	81 c1 54 00 02 00    	add    $0x20054,%ecx
	int total_priority = 0;
f010459f:	bb 00 00 00 00       	mov    $0x0,%ebx
f01045a4:	eb 0a                	jmp    f01045b0 <sched_yield+0x5d>
			total_priority += envs[i].priority;
f01045a6:	03 58 0c             	add    0xc(%eax),%ebx
f01045a9:	83 e8 80             	sub    $0xffffff80,%eax
	for (int i = 0; i < NENV; i++) {
f01045ac:	39 c8                	cmp    %ecx,%eax
f01045ae:	74 0c                	je     f01045bc <sched_yield+0x69>
		if (envs[i].env_status == ENV_RUNNABLE ||
f01045b0:	8b 10                	mov    (%eax),%edx
f01045b2:	83 ea 02             	sub    $0x2,%edx
f01045b5:	83 fa 01             	cmp    $0x1,%edx
f01045b8:	77 ef                	ja     f01045a9 <sched_yield+0x56>
f01045ba:	eb ea                	jmp    f01045a6 <sched_yield+0x53>
	unsigned winner = (rand() % (total_priority - 1) + 1);
f01045bc:	e8 bb fe ff ff       	call   f010447c <rand>
f01045c1:	83 eb 01             	sub    $0x1,%ebx
f01045c4:	ba 00 00 00 00       	mov    $0x0,%edx
f01045c9:	f7 f3                	div    %ebx
f01045cb:	8d 42 01             	lea    0x1(%edx),%eax
f01045ce:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		if (envs[j].env_status == ENV_RUNNABLE ||
f01045d1:	8b 1d 44 e2 24 f0    	mov    0xf024e244,%ebx
f01045d7:	89 f2                	mov    %esi,%edx
f01045d9:	8d 8e 00 04 00 00    	lea    0x400(%esi),%ecx
	int counter = 0;
f01045df:	be 00 00 00 00       	mov    $0x0,%esi
f01045e4:	eb 07                	jmp    f01045ed <sched_yield+0x9a>
f01045e6:	83 c2 01             	add    $0x1,%edx
	while (i < NENV && !find) {
f01045e9:	39 ca                	cmp    %ecx,%edx
f01045eb:	74 33                	je     f0104620 <sched_yield+0xcd>
		int j = (indx + i) % NENV;
f01045ed:	89 d7                	mov    %edx,%edi
f01045ef:	c1 ff 1f             	sar    $0x1f,%edi
f01045f2:	c1 ef 16             	shr    $0x16,%edi
f01045f5:	8d 04 3a             	lea    (%edx,%edi,1),%eax
f01045f8:	25 ff 03 00 00       	and    $0x3ff,%eax
f01045fd:	29 f8                	sub    %edi,%eax
		if (envs[j].env_status == ENV_RUNNABLE ||
f01045ff:	c1 e0 07             	shl    $0x7,%eax
f0104602:	01 d8                	add    %ebx,%eax
f0104604:	8b 78 54             	mov    0x54(%eax),%edi
f0104607:	83 ef 02             	sub    $0x2,%edi
f010460a:	83 ff 01             	cmp    $0x1,%edi
f010460d:	77 d7                	ja     f01045e6 <sched_yield+0x93>
			counter = counter + envs[j].priority;
f010460f:	03 70 60             	add    0x60(%eax),%esi
			if (counter >= winner) {
f0104612:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f0104615:	72 cf                	jb     f01045e6 <sched_yield+0x93>
				env_run(envs + j);
f0104617:	83 ec 0c             	sub    $0xc,%esp
f010461a:	50                   	push   %eax
f010461b:	e8 0e f0 ff ff       	call   f010362e <env_run>
	if (curenv && (curenv->env_status == ENV_RUNNING)) {
f0104620:	e8 cf 19 00 00       	call   f0105ff4 <cpunum>
f0104625:	6b c0 74             	imul   $0x74,%eax,%eax
f0104628:	83 b8 28 00 25 f0 00 	cmpl   $0x0,-0xfdaffd8(%eax)
f010462f:	74 14                	je     f0104645 <sched_yield+0xf2>
f0104631:	e8 be 19 00 00       	call   f0105ff4 <cpunum>
f0104636:	6b c0 74             	imul   $0x74,%eax,%eax
f0104639:	8b 80 28 00 25 f0    	mov    -0xfdaffd8(%eax),%eax
f010463f:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104643:	74 0d                	je     f0104652 <sched_yield+0xff>
	sched_halt();
f0104645:	e8 53 fe ff ff       	call   f010449d <sched_halt>
}
f010464a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010464d:	5b                   	pop    %ebx
f010464e:	5e                   	pop    %esi
f010464f:	5f                   	pop    %edi
f0104650:	5d                   	pop    %ebp
f0104651:	c3                   	ret    
		env_run(curenv);
f0104652:	e8 9d 19 00 00       	call   f0105ff4 <cpunum>
f0104657:	83 ec 0c             	sub    $0xc,%esp
f010465a:	6b c0 74             	imul   $0x74,%eax,%eax
f010465d:	ff b0 28 00 25 f0    	pushl  -0xfdaffd8(%eax)
f0104663:	e8 c6 ef ff ff       	call   f010362e <env_run>

f0104668 <sys_getenvid>:
}

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
f0104668:	55                   	push   %ebp
f0104669:	89 e5                	mov    %esp,%ebp
f010466b:	83 ec 08             	sub    $0x8,%esp
	return curenv->env_id;
f010466e:	e8 81 19 00 00       	call   f0105ff4 <cpunum>
f0104673:	6b c0 74             	imul   $0x74,%eax,%eax
f0104676:	8b 80 28 00 25 f0    	mov    -0xfdaffd8(%eax),%eax
f010467c:	8b 40 48             	mov    0x48(%eax),%eax
}
f010467f:	c9                   	leave  
f0104680:	c3                   	ret    

f0104681 <sys_cputs>:
{
f0104681:	55                   	push   %ebp
f0104682:	89 e5                	mov    %esp,%ebp
f0104684:	56                   	push   %esi
f0104685:	53                   	push   %ebx
f0104686:	89 c6                	mov    %eax,%esi
f0104688:	89 d3                	mov    %edx,%ebx
	user_mem_assert(curenv, s, len, PTE_U);
f010468a:	e8 65 19 00 00       	call   f0105ff4 <cpunum>
f010468f:	6a 04                	push   $0x4
f0104691:	53                   	push   %ebx
f0104692:	56                   	push   %esi
f0104693:	6b c0 74             	imul   $0x74,%eax,%eax
f0104696:	ff b0 28 00 25 f0    	pushl  -0xfdaffd8(%eax)
f010469c:	e8 13 e8 ff ff       	call   f0102eb4 <user_mem_assert>
	cprintf("%.*s", len, s);
f01046a1:	83 c4 0c             	add    $0xc,%esp
f01046a4:	56                   	push   %esi
f01046a5:	53                   	push   %ebx
f01046a6:	68 06 7e 10 f0       	push   $0xf0107e06
f01046ab:	e8 7d f2 ff ff       	call   f010392d <cprintf>
}
f01046b0:	83 c4 10             	add    $0x10,%esp
f01046b3:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01046b6:	5b                   	pop    %ebx
f01046b7:	5e                   	pop    %esi
f01046b8:	5d                   	pop    %ebp
f01046b9:	c3                   	ret    

f01046ba <sys_cgetc>:
{
f01046ba:	55                   	push   %ebp
f01046bb:	89 e5                	mov    %esp,%ebp
f01046bd:	83 ec 08             	sub    $0x8,%esp
	return cons_getc();
f01046c0:	e8 c6 c1 ff ff       	call   f010088b <cons_getc>
}
f01046c5:	c9                   	leave  
f01046c6:	c3                   	ret    

f01046c7 <sys_env_set_status>:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
//	-E_INVAL if status is not a valid status for an environment.
static int
sys_env_set_status(envid_t envid, int status)
{
f01046c7:	55                   	push   %ebp
f01046c8:	89 e5                	mov    %esp,%ebp
f01046ca:	53                   	push   %ebx
f01046cb:	83 ec 14             	sub    $0x14,%esp
f01046ce:	89 d3                	mov    %edx,%ebx
	// check whether the current environment has permission to set
	// envid's status.

	// LAB 4: Your code here.
	struct Env *e;
	if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE) {
f01046d0:	8d 52 fe             	lea    -0x2(%edx),%edx
f01046d3:	f7 c2 fd ff ff ff    	test   $0xfffffffd,%edx
f01046d9:	75 26                	jne    f0104701 <sys_env_set_status+0x3a>
		cprintf("sys_env_set_status. 1 fails: %d (-E_INVAL)\n", -E_INVAL);
		return -E_INVAL;
	}
	int result = envid2env(envid, &e, 1);
f01046db:	83 ec 04             	sub    $0x4,%esp
f01046de:	6a 01                	push   $0x1
f01046e0:	8d 55 f4             	lea    -0xc(%ebp),%edx
f01046e3:	52                   	push   %edx
f01046e4:	50                   	push   %eax
f01046e5:	e8 ca ea ff ff       	call   f01031b4 <envid2env>
	if (result < 0) {
f01046ea:	83 c4 10             	add    $0x10,%esp
f01046ed:	85 c0                	test   %eax,%eax
f01046ef:	78 29                	js     f010471a <sys_env_set_status+0x53>
		cprintf("sys_env_set_status. 1 fails: %d (-E_INVAL)\n",
		        -E_BAD_ENV);
		return -E_BAD_ENV;
	}
	e->env_status = status;
f01046f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01046f4:	89 58 54             	mov    %ebx,0x54(%eax)
	return 0;
f01046f7:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01046fc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01046ff:	c9                   	leave  
f0104700:	c3                   	ret    
		cprintf("sys_env_set_status. 1 fails: %d (-E_INVAL)\n", -E_INVAL);
f0104701:	83 ec 08             	sub    $0x8,%esp
f0104704:	6a fd                	push   $0xfffffffd
f0104706:	68 40 7e 10 f0       	push   $0xf0107e40
f010470b:	e8 1d f2 ff ff       	call   f010392d <cprintf>
		return -E_INVAL;
f0104710:	83 c4 10             	add    $0x10,%esp
f0104713:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104718:	eb e2                	jmp    f01046fc <sys_env_set_status+0x35>
		cprintf("sys_env_set_status. 1 fails: %d (-E_INVAL)\n",
f010471a:	83 ec 08             	sub    $0x8,%esp
f010471d:	6a fe                	push   $0xfffffffe
f010471f:	68 40 7e 10 f0       	push   $0xf0107e40
f0104724:	e8 04 f2 ff ff       	call   f010392d <cprintf>
		return -E_BAD_ENV;
f0104729:	83 c4 10             	add    $0x10,%esp
f010472c:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104731:	eb c9                	jmp    f01046fc <sys_env_set_status+0x35>

f0104733 <sys_env_set_pgfault_upcall>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
static int
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
f0104733:	55                   	push   %ebp
f0104734:	89 e5                	mov    %esp,%ebp
f0104736:	53                   	push   %ebx
f0104737:	83 ec 18             	sub    $0x18,%esp
f010473a:	89 d3                	mov    %edx,%ebx
	// LAB 4: Your code here.
	struct Env *e;
	if (envid2env(envid, &e, 1) < 0)
f010473c:	6a 01                	push   $0x1
f010473e:	8d 55 f4             	lea    -0xc(%ebp),%edx
f0104741:	52                   	push   %edx
f0104742:	50                   	push   %eax
f0104743:	e8 6c ea ff ff       	call   f01031b4 <envid2env>
f0104748:	83 c4 10             	add    $0x10,%esp
f010474b:	85 c0                	test   %eax,%eax
f010474d:	78 10                	js     f010475f <sys_env_set_pgfault_upcall+0x2c>
		return -E_BAD_ENV;

	e->env_pgfault_upcall = func;
f010474f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104752:	89 58 68             	mov    %ebx,0x68(%eax)

	return 0;
f0104755:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010475a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010475d:	c9                   	leave  
f010475e:	c3                   	ret    
		return -E_BAD_ENV;
f010475f:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104764:	eb f4                	jmp    f010475a <sys_env_set_pgfault_upcall+0x27>

f0104766 <sys_change_priority>:
{
f0104766:	55                   	push   %ebp
f0104767:	89 e5                	mov    %esp,%ebp
f0104769:	56                   	push   %esi
f010476a:	53                   	push   %ebx
f010476b:	83 ec 14             	sub    $0x14,%esp
f010476e:	89 c3                	mov    %eax,%ebx
f0104770:	89 d6                	mov    %edx,%esi
	if ((envid2env(envid, &e, 0)) < 0) {
f0104772:	6a 00                	push   $0x0
f0104774:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104777:	50                   	push   %eax
f0104778:	52                   	push   %edx
f0104779:	e8 36 ea ff ff       	call   f01031b4 <envid2env>
f010477e:	83 c4 10             	add    $0x10,%esp
f0104781:	85 c0                	test   %eax,%eax
f0104783:	78 2e                	js     f01047b3 <sys_change_priority+0x4d>
	if (curenv->env_id == envid) {
f0104785:	e8 6a 18 00 00       	call   f0105ff4 <cpunum>
f010478a:	6b c0 74             	imul   $0x74,%eax,%eax
f010478d:	8b 80 28 00 25 f0    	mov    -0xfdaffd8(%eax),%eax
	if (pr < 0) {
f0104793:	39 70 48             	cmp    %esi,0x48(%eax)
f0104796:	74 22                	je     f01047ba <sys_change_priority+0x54>
f0104798:	85 db                	test   %ebx,%ebx
f010479a:	78 1e                	js     f01047ba <sys_change_priority+0x54>
	if (pr < e->priority) {
f010479c:	8b 55 f4             	mov    -0xc(%ebp),%edx
	return 0;
f010479f:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pr < e->priority) {
f01047a4:	39 5a 60             	cmp    %ebx,0x60(%edx)
f01047a7:	7e 03                	jle    f01047ac <sys_change_priority+0x46>
		e->priority = pr;
f01047a9:	89 5a 60             	mov    %ebx,0x60(%edx)
}
f01047ac:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01047af:	5b                   	pop    %ebx
f01047b0:	5e                   	pop    %esi
f01047b1:	5d                   	pop    %ebp
f01047b2:	c3                   	ret    
		return -E_BAD_ENV;
f01047b3:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01047b8:	eb f2                	jmp    f01047ac <sys_change_priority+0x46>
		return -E_INVAL;
f01047ba:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01047bf:	eb eb                	jmp    f01047ac <sys_change_priority+0x46>

f01047c1 <sys_env_destroy>:
{
f01047c1:	55                   	push   %ebp
f01047c2:	89 e5                	mov    %esp,%ebp
f01047c4:	53                   	push   %ebx
f01047c5:	83 ec 18             	sub    $0x18,%esp
	if ((r = envid2env(envid, &e, 1)) < 0)
f01047c8:	6a 01                	push   $0x1
f01047ca:	8d 55 f4             	lea    -0xc(%ebp),%edx
f01047cd:	52                   	push   %edx
f01047ce:	50                   	push   %eax
f01047cf:	e8 e0 e9 ff ff       	call   f01031b4 <envid2env>
f01047d4:	83 c4 10             	add    $0x10,%esp
f01047d7:	85 c0                	test   %eax,%eax
f01047d9:	78 4b                	js     f0104826 <sys_env_destroy+0x65>
	if (e == curenv)
f01047db:	e8 14 18 00 00       	call   f0105ff4 <cpunum>
f01047e0:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01047e3:	6b c0 74             	imul   $0x74,%eax,%eax
f01047e6:	39 90 28 00 25 f0    	cmp    %edx,-0xfdaffd8(%eax)
f01047ec:	74 3d                	je     f010482b <sys_env_destroy+0x6a>
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f01047ee:	8b 5a 48             	mov    0x48(%edx),%ebx
f01047f1:	e8 fe 17 00 00       	call   f0105ff4 <cpunum>
f01047f6:	83 ec 04             	sub    $0x4,%esp
f01047f9:	53                   	push   %ebx
f01047fa:	6b c0 74             	imul   $0x74,%eax,%eax
f01047fd:	8b 80 28 00 25 f0    	mov    -0xfdaffd8(%eax),%eax
f0104803:	ff 70 48             	pushl  0x48(%eax)
f0104806:	68 26 7e 10 f0       	push   $0xf0107e26
f010480b:	e8 1d f1 ff ff       	call   f010392d <cprintf>
f0104810:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f0104813:	83 ec 0c             	sub    $0xc,%esp
f0104816:	ff 75 f4             	pushl  -0xc(%ebp)
f0104819:	e8 69 ed ff ff       	call   f0103587 <env_destroy>
	return 0;
f010481e:	83 c4 10             	add    $0x10,%esp
f0104821:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104826:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104829:	c9                   	leave  
f010482a:	c3                   	ret    
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f010482b:	e8 c4 17 00 00       	call   f0105ff4 <cpunum>
f0104830:	83 ec 08             	sub    $0x8,%esp
f0104833:	6b c0 74             	imul   $0x74,%eax,%eax
f0104836:	8b 80 28 00 25 f0    	mov    -0xfdaffd8(%eax),%eax
f010483c:	ff 70 48             	pushl  0x48(%eax)
f010483f:	68 0b 7e 10 f0       	push   $0xf0107e0b
f0104844:	e8 e4 f0 ff ff       	call   f010392d <cprintf>
f0104849:	83 c4 10             	add    $0x10,%esp
f010484c:	eb c5                	jmp    f0104813 <sys_env_destroy+0x52>

f010484e <sys_yield>:
{
f010484e:	55                   	push   %ebp
f010484f:	89 e5                	mov    %esp,%ebp
f0104851:	83 ec 08             	sub    $0x8,%esp
	sched_yield();
f0104854:	e8 fa fc ff ff       	call   f0104553 <sched_yield>

f0104859 <sys_ipc_recv>:
// return 0 on success.
// Return < 0 on error.  Errors are:
//	-E_INVAL if dstva < UTOP but dstva is not page-aligned.
static int
sys_ipc_recv(void *dstva)
{
f0104859:	55                   	push   %ebp
f010485a:	89 e5                	mov    %esp,%ebp
f010485c:	53                   	push   %ebx
f010485d:	83 ec 04             	sub    $0x4,%esp
	// LAB 4: Your code here.
	if (((uintptr_t) dstva < UTOP)) {
f0104860:	3d ff ff bf ee       	cmp    $0xeebfffff,%eax
f0104865:	77 33                	ja     f010489a <sys_ipc_recv+0x41>
f0104867:	89 c3                	mov    %eax,%ebx
		if ((uintptr_t) dstva % PGSIZE != 0) {
f0104869:	a9 ff 0f 00 00       	test   $0xfff,%eax
f010486e:	74 19                	je     f0104889 <sys_ipc_recv+0x30>
			cprintf("sys_ipc_recv. fails  1: %d (-E_INVAL)\n",
f0104870:	83 ec 08             	sub    $0x8,%esp
f0104873:	6a fd                	push   $0xfffffffd
f0104875:	68 6c 7e 10 f0       	push   $0xf0107e6c
f010487a:	e8 ae f0 ff ff       	call   f010392d <cprintf>
	curenv->env_ipc_recving = 1;
	curenv->env_status = ENV_NOT_RUNNABLE;
	curenv->env_tf.tf_regs.reg_eax = 0;

	sched_yield();
}
f010487f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104884:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104887:	c9                   	leave  
f0104888:	c3                   	ret    
			curenv->env_ipc_dstva = dstva;
f0104889:	e8 66 17 00 00       	call   f0105ff4 <cpunum>
f010488e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104891:	8b 80 28 00 25 f0    	mov    -0xfdaffd8(%eax),%eax
f0104897:	89 58 70             	mov    %ebx,0x70(%eax)
	curenv->env_ipc_recving = 1;
f010489a:	e8 55 17 00 00       	call   f0105ff4 <cpunum>
f010489f:	6b c0 74             	imul   $0x74,%eax,%eax
f01048a2:	8b 80 28 00 25 f0    	mov    -0xfdaffd8(%eax),%eax
f01048a8:	c6 40 6c 01          	movb   $0x1,0x6c(%eax)
	curenv->env_status = ENV_NOT_RUNNABLE;
f01048ac:	e8 43 17 00 00       	call   f0105ff4 <cpunum>
f01048b1:	6b c0 74             	imul   $0x74,%eax,%eax
f01048b4:	8b 80 28 00 25 f0    	mov    -0xfdaffd8(%eax),%eax
f01048ba:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	curenv->env_tf.tf_regs.reg_eax = 0;
f01048c1:	e8 2e 17 00 00       	call   f0105ff4 <cpunum>
f01048c6:	6b c0 74             	imul   $0x74,%eax,%eax
f01048c9:	8b 80 28 00 25 f0    	mov    -0xfdaffd8(%eax),%eax
f01048cf:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	sched_yield();
f01048d6:	e8 78 fc ff ff       	call   f0104553 <sched_yield>

f01048db <sys_exofork>:
{
f01048db:	55                   	push   %ebp
f01048dc:	89 e5                	mov    %esp,%ebp
f01048de:	57                   	push   %edi
f01048df:	56                   	push   %esi
f01048e0:	83 ec 10             	sub    $0x10,%esp
	int result = env_alloc(&e, curenv->env_id);
f01048e3:	e8 0c 17 00 00       	call   f0105ff4 <cpunum>
f01048e8:	83 ec 08             	sub    $0x8,%esp
f01048eb:	6b c0 74             	imul   $0x74,%eax,%eax
f01048ee:	8b 80 28 00 25 f0    	mov    -0xfdaffd8(%eax),%eax
f01048f4:	ff 70 48             	pushl  0x48(%eax)
f01048f7:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01048fa:	50                   	push   %eax
f01048fb:	e8 dc e9 ff ff       	call   f01032dc <env_alloc>
	if (result < 0) {
f0104900:	83 c4 10             	add    $0x10,%esp
f0104903:	85 c0                	test   %eax,%eax
f0104905:	78 2c                	js     f0104933 <sys_exofork+0x58>
	e->env_tf = curenv->env_tf;
f0104907:	e8 e8 16 00 00       	call   f0105ff4 <cpunum>
f010490c:	6b c0 74             	imul   $0x74,%eax,%eax
f010490f:	8b b0 28 00 25 f0    	mov    -0xfdaffd8(%eax),%esi
f0104915:	b9 11 00 00 00       	mov    $0x11,%ecx
f010491a:	8b 7d f4             	mov    -0xc(%ebp),%edi
f010491d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	e->env_status = ENV_NOT_RUNNABLE;
f010491f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104922:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	e->env_tf.tf_regs.reg_eax = 0;
f0104929:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return e->env_id;
f0104930:	8b 40 48             	mov    0x48(%eax),%eax
}
f0104933:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0104936:	5e                   	pop    %esi
f0104937:	5f                   	pop    %edi
f0104938:	5d                   	pop    %ebp
f0104939:	c3                   	ret    

f010493a <sys_page_alloc>:
{
f010493a:	55                   	push   %ebp
f010493b:	89 e5                	mov    %esp,%ebp
f010493d:	57                   	push   %edi
f010493e:	56                   	push   %esi
f010493f:	53                   	push   %ebx
f0104940:	83 ec 30             	sub    $0x30,%esp
f0104943:	89 d6                	mov    %edx,%esi
f0104945:	89 cb                	mov    %ecx,%ebx
	if (envid2env(envid, &e, 1) < 0)
f0104947:	6a 01                	push   $0x1
f0104949:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f010494c:	52                   	push   %edx
f010494d:	50                   	push   %eax
f010494e:	e8 61 e8 ff ff       	call   f01031b4 <envid2env>
f0104953:	83 c4 10             	add    $0x10,%esp
f0104956:	85 c0                	test   %eax,%eax
f0104958:	78 69                	js     f01049c3 <sys_page_alloc+0x89>
	if (perm & ~PTE_SYSCALL || !(perm & (PTE_U | PTE_P)))
f010495a:	89 d8                	mov    %ebx,%eax
f010495c:	25 f8 f1 ff ff       	and    $0xfffff1f8,%eax
f0104961:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0104964:	75 66                	jne    f01049cc <sys_page_alloc+0x92>
f0104966:	f6 c3 05             	test   $0x5,%bl
f0104969:	74 6a                	je     f01049d5 <sys_page_alloc+0x9b>
	if (((uintptr_t) va >= UTOP) || ((uintptr_t) va % PGSIZE != 0))
f010496b:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f0104971:	77 6b                	ja     f01049de <sys_page_alloc+0xa4>
f0104973:	f7 c6 ff 0f 00 00    	test   $0xfff,%esi
f0104979:	75 6c                	jne    f01049e7 <sys_page_alloc+0xad>
	struct PageInfo *page = page_alloc(ALLOC_ZERO);
f010497b:	83 ec 0c             	sub    $0xc,%esp
f010497e:	6a 01                	push   $0x1
f0104980:	e8 8b c7 ff ff       	call   f0101110 <page_alloc>
f0104985:	89 c7                	mov    %eax,%edi
	if (!page)
f0104987:	83 c4 10             	add    $0x10,%esp
f010498a:	85 c0                	test   %eax,%eax
f010498c:	74 62                	je     f01049f0 <sys_page_alloc+0xb6>
	if (page_insert(e->env_pgdir, page, va, perm) < 0) {
f010498e:	53                   	push   %ebx
f010498f:	56                   	push   %esi
f0104990:	50                   	push   %eax
f0104991:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104994:	ff 70 64             	pushl  0x64(%eax)
f0104997:	e8 89 d1 ff ff       	call   f0101b25 <page_insert>
f010499c:	83 c4 10             	add    $0x10,%esp
f010499f:	85 c0                	test   %eax,%eax
f01049a1:	78 0b                	js     f01049ae <sys_page_alloc+0x74>
}
f01049a3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01049a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01049a9:	5b                   	pop    %ebx
f01049aa:	5e                   	pop    %esi
f01049ab:	5f                   	pop    %edi
f01049ac:	5d                   	pop    %ebp
f01049ad:	c3                   	ret    
		page_free(page);
f01049ae:	83 ec 0c             	sub    $0xc,%esp
f01049b1:	57                   	push   %edi
f01049b2:	e8 a4 c7 ff ff       	call   f010115b <page_free>
		return -E_NO_MEM;
f01049b7:	83 c4 10             	add    $0x10,%esp
f01049ba:	c7 45 d4 fc ff ff ff 	movl   $0xfffffffc,-0x2c(%ebp)
f01049c1:	eb e0                	jmp    f01049a3 <sys_page_alloc+0x69>
		return -E_BAD_ENV;
f01049c3:	c7 45 d4 fe ff ff ff 	movl   $0xfffffffe,-0x2c(%ebp)
f01049ca:	eb d7                	jmp    f01049a3 <sys_page_alloc+0x69>
		return -E_INVAL;
f01049cc:	c7 45 d4 fd ff ff ff 	movl   $0xfffffffd,-0x2c(%ebp)
f01049d3:	eb ce                	jmp    f01049a3 <sys_page_alloc+0x69>
f01049d5:	c7 45 d4 fd ff ff ff 	movl   $0xfffffffd,-0x2c(%ebp)
f01049dc:	eb c5                	jmp    f01049a3 <sys_page_alloc+0x69>
		return -E_INVAL;
f01049de:	c7 45 d4 fd ff ff ff 	movl   $0xfffffffd,-0x2c(%ebp)
f01049e5:	eb bc                	jmp    f01049a3 <sys_page_alloc+0x69>
f01049e7:	c7 45 d4 fd ff ff ff 	movl   $0xfffffffd,-0x2c(%ebp)
f01049ee:	eb b3                	jmp    f01049a3 <sys_page_alloc+0x69>
		return -E_NO_MEM;
f01049f0:	c7 45 d4 fc ff ff ff 	movl   $0xfffffffc,-0x2c(%ebp)
f01049f7:	eb aa                	jmp    f01049a3 <sys_page_alloc+0x69>

f01049f9 <sys_page_map>:
{
f01049f9:	55                   	push   %ebp
f01049fa:	89 e5                	mov    %esp,%ebp
f01049fc:	57                   	push   %edi
f01049fd:	56                   	push   %esi
f01049fe:	53                   	push   %ebx
f01049ff:	83 ec 20             	sub    $0x20,%esp
f0104a02:	89 d3                	mov    %edx,%ebx
f0104a04:	89 cf                	mov    %ecx,%edi
f0104a06:	8b 75 08             	mov    0x8(%ebp),%esi
	if (envid2env(srcenvid, &se, 0) < 0 || envid2env(dstenvid, &de, 0) < 0) {
f0104a09:	6a 00                	push   $0x0
f0104a0b:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104a0e:	52                   	push   %edx
f0104a0f:	50                   	push   %eax
f0104a10:	e8 9f e7 ff ff       	call   f01031b4 <envid2env>
f0104a15:	83 c4 10             	add    $0x10,%esp
f0104a18:	85 c0                	test   %eax,%eax
f0104a1a:	0f 88 c4 00 00 00    	js     f0104ae4 <sys_page_map+0xeb>
f0104a20:	83 ec 04             	sub    $0x4,%esp
f0104a23:	6a 00                	push   $0x0
f0104a25:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104a28:	50                   	push   %eax
f0104a29:	57                   	push   %edi
f0104a2a:	e8 85 e7 ff ff       	call   f01031b4 <envid2env>
f0104a2f:	83 c4 10             	add    $0x10,%esp
f0104a32:	85 c0                	test   %eax,%eax
f0104a34:	0f 88 b1 00 00 00    	js     f0104aeb <sys_page_map+0xf2>
	if (srcva >= (void *) UTOP || ROUNDUP(srcva, PGSIZE) != srcva) {
f0104a3a:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
f0104a40:	0f 87 ac 00 00 00    	ja     f0104af2 <sys_page_map+0xf9>
f0104a46:	8d 83 ff 0f 00 00    	lea    0xfff(%ebx),%eax
f0104a4c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (dstva >= (void *) UTOP || ROUNDUP(dstva, PGSIZE) != dstva) {
f0104a51:	39 c3                	cmp    %eax,%ebx
f0104a53:	0f 85 a0 00 00 00    	jne    f0104af9 <sys_page_map+0x100>
f0104a59:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f0104a5f:	0f 87 94 00 00 00    	ja     f0104af9 <sys_page_map+0x100>
f0104a65:	8d 86 ff 0f 00 00    	lea    0xfff(%esi),%eax
f0104a6b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0104a70:	39 c6                	cmp    %eax,%esi
f0104a72:	0f 85 88 00 00 00    	jne    f0104b00 <sys_page_map+0x107>
	page = page_lookup(se->env_pgdir, srcva, &pte);
f0104a78:	83 ec 04             	sub    $0x4,%esp
f0104a7b:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104a7e:	50                   	push   %eax
f0104a7f:	53                   	push   %ebx
f0104a80:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104a83:	ff 70 64             	pushl  0x64(%eax)
f0104a86:	e8 d4 cf ff ff       	call   f0101a5f <page_lookup>
f0104a8b:	89 c3                	mov    %eax,%ebx
	if (!page) {
f0104a8d:	83 c4 10             	add    $0x10,%esp
f0104a90:	85 c0                	test   %eax,%eax
f0104a92:	74 73                	je     f0104b07 <sys_page_map+0x10e>
	if ((flags & perm) != flags) {
f0104a94:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104a97:	83 e0 05             	and    $0x5,%eax
f0104a9a:	83 f8 05             	cmp    $0x5,%eax
f0104a9d:	75 6f                	jne    f0104b0e <sys_page_map+0x115>
	if (!(*pte & PTE_W) && (perm & PTE_W)) {
f0104a9f:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104aa2:	f6 00 02             	testb  $0x2,(%eax)
f0104aa5:	75 06                	jne    f0104aad <sys_page_map+0xb4>
f0104aa7:	f6 45 0c 02          	testb  $0x2,0xc(%ebp)
f0104aab:	75 68                	jne    f0104b15 <sys_page_map+0x11c>
	if (page_insert(de->env_pgdir, page, dstva, perm) < 0) {
f0104aad:	ff 75 0c             	pushl  0xc(%ebp)
f0104ab0:	56                   	push   %esi
f0104ab1:	53                   	push   %ebx
f0104ab2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104ab5:	ff 70 64             	pushl  0x64(%eax)
f0104ab8:	e8 68 d0 ff ff       	call   f0101b25 <page_insert>
f0104abd:	83 c4 10             	add    $0x10,%esp
f0104ac0:	85 c0                	test   %eax,%eax
f0104ac2:	78 0d                	js     f0104ad1 <sys_page_map+0xd8>
	return 0;
f0104ac4:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104ac9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104acc:	5b                   	pop    %ebx
f0104acd:	5e                   	pop    %esi
f0104ace:	5f                   	pop    %edi
f0104acf:	5d                   	pop    %ebp
f0104ad0:	c3                   	ret    
		page_free(page);
f0104ad1:	83 ec 0c             	sub    $0xc,%esp
f0104ad4:	53                   	push   %ebx
f0104ad5:	e8 81 c6 ff ff       	call   f010115b <page_free>
		return -E_NO_MEM;
f0104ada:	83 c4 10             	add    $0x10,%esp
f0104add:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0104ae2:	eb e5                	jmp    f0104ac9 <sys_page_map+0xd0>
		return -E_BAD_ENV;
f0104ae4:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104ae9:	eb de                	jmp    f0104ac9 <sys_page_map+0xd0>
f0104aeb:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104af0:	eb d7                	jmp    f0104ac9 <sys_page_map+0xd0>
		return -E_INVAL;
f0104af2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104af7:	eb d0                	jmp    f0104ac9 <sys_page_map+0xd0>
		return -E_INVAL;
f0104af9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104afe:	eb c9                	jmp    f0104ac9 <sys_page_map+0xd0>
f0104b00:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104b05:	eb c2                	jmp    f0104ac9 <sys_page_map+0xd0>
		return -E_INVAL;
f0104b07:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104b0c:	eb bb                	jmp    f0104ac9 <sys_page_map+0xd0>
		return -E_INVAL;
f0104b0e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104b13:	eb b4                	jmp    f0104ac9 <sys_page_map+0xd0>
		return -E_INVAL;
f0104b15:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104b1a:	eb ad                	jmp    f0104ac9 <sys_page_map+0xd0>

f0104b1c <sys_ipc_try_send>:
{
f0104b1c:	55                   	push   %ebp
f0104b1d:	89 e5                	mov    %esp,%ebp
f0104b1f:	57                   	push   %edi
f0104b20:	56                   	push   %esi
f0104b21:	53                   	push   %ebx
f0104b22:	83 ec 20             	sub    $0x20,%esp
f0104b25:	89 d7                	mov    %edx,%edi
f0104b27:	89 cb                	mov    %ecx,%ebx
f0104b29:	8b 75 08             	mov    0x8(%ebp),%esi
	if ((envid2env(envid, &e, 0)) < 0) {
f0104b2c:	6a 00                	push   $0x0
f0104b2e:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104b31:	52                   	push   %edx
f0104b32:	50                   	push   %eax
f0104b33:	e8 7c e6 ff ff       	call   f01031b4 <envid2env>
f0104b38:	83 c4 10             	add    $0x10,%esp
f0104b3b:	85 c0                	test   %eax,%eax
f0104b3d:	0f 88 de 00 00 00    	js     f0104c21 <sys_ipc_try_send+0x105>
	if (!e->env_ipc_recving) {
f0104b43:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104b46:	80 78 6c 00          	cmpb   $0x0,0x6c(%eax)
f0104b4a:	0f 84 d8 00 00 00    	je     f0104c28 <sys_ipc_try_send+0x10c>
	if ((int) srcva < UTOP) {
f0104b50:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
f0104b56:	77 71                	ja     f0104bc9 <sys_ipc_try_send+0xad>
		if ((int) srcva % PGSIZE != 0) {
f0104b58:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
f0104b5e:	0f 85 cb 00 00 00    	jne    f0104c2f <sys_ipc_try_send+0x113>
		if ((PTE_P & perm) == 0 || (PTE_U & perm) == 0 ||
f0104b64:	89 f0                	mov    %esi,%eax
f0104b66:	83 e0 05             	and    $0x5,%eax
f0104b69:	83 f8 05             	cmp    $0x5,%eax
f0104b6c:	0f 85 c4 00 00 00    	jne    f0104c36 <sys_ipc_try_send+0x11a>
f0104b72:	f7 c6 f8 f1 ff ff    	test   $0xfffff1f8,%esi
f0104b78:	0f 85 bf 00 00 00    	jne    f0104c3d <sys_ipc_try_send+0x121>
		if ((p = page_lookup(curenv->env_pgdir, srcva, &pte)) == NULL) {
f0104b7e:	e8 71 14 00 00       	call   f0105ff4 <cpunum>
f0104b83:	83 ec 04             	sub    $0x4,%esp
f0104b86:	8d 55 e0             	lea    -0x20(%ebp),%edx
f0104b89:	52                   	push   %edx
f0104b8a:	53                   	push   %ebx
f0104b8b:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b8e:	8b 80 28 00 25 f0    	mov    -0xfdaffd8(%eax),%eax
f0104b94:	ff 70 64             	pushl  0x64(%eax)
f0104b97:	e8 c3 ce ff ff       	call   f0101a5f <page_lookup>
f0104b9c:	83 c4 10             	add    $0x10,%esp
f0104b9f:	85 c0                	test   %eax,%eax
f0104ba1:	0f 84 9d 00 00 00    	je     f0104c44 <sys_ipc_try_send+0x128>
		if ((perm & PTE_W) == PTE_W && (PGOFF(*pte) & PTE_W) != PTE_W) {
f0104ba7:	f7 c6 02 00 00 00    	test   $0x2,%esi
f0104bad:	74 0c                	je     f0104bbb <sys_ipc_try_send+0x9f>
f0104baf:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104bb2:	f6 02 02             	testb  $0x2,(%edx)
f0104bb5:	0f 84 90 00 00 00    	je     f0104c4b <sys_ipc_try_send+0x12f>
		if ((int) e->env_ipc_dstva < UTOP) {
f0104bbb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104bbe:	8b 4a 70             	mov    0x70(%edx),%ecx
f0104bc1:	81 f9 ff ff bf ee    	cmp    $0xeebfffff,%ecx
f0104bc7:	76 38                	jbe    f0104c01 <sys_ipc_try_send+0xe5>
	e->env_ipc_recving = 0;
f0104bc9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104bcc:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
	e->env_ipc_from = curenv->env_id;
f0104bd0:	e8 1f 14 00 00       	call   f0105ff4 <cpunum>
f0104bd5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104bd8:	6b c0 74             	imul   $0x74,%eax,%eax
f0104bdb:	8b 80 28 00 25 f0    	mov    -0xfdaffd8(%eax),%eax
f0104be1:	8b 40 48             	mov    0x48(%eax),%eax
f0104be4:	89 42 78             	mov    %eax,0x78(%edx)
	e->env_ipc_value = value;
f0104be7:	89 7a 74             	mov    %edi,0x74(%edx)
	e->env_ipc_perm = perm;
f0104bea:	89 72 7c             	mov    %esi,0x7c(%edx)
	e->env_status = ENV_RUNNABLE;
f0104bed:	c7 42 54 02 00 00 00 	movl   $0x2,0x54(%edx)
	return 0;
f0104bf4:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104bf9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104bfc:	5b                   	pop    %ebx
f0104bfd:	5e                   	pop    %esi
f0104bfe:	5f                   	pop    %edi
f0104bff:	5d                   	pop    %ebp
f0104c00:	c3                   	ret    
			e->env_ipc_perm = 0;
f0104c01:	c7 42 7c 00 00 00 00 	movl   $0x0,0x7c(%edx)
			if ((page_insert(e->env_pgdir, p, e->env_ipc_dstva, perm)) <
f0104c08:	56                   	push   %esi
f0104c09:	51                   	push   %ecx
f0104c0a:	50                   	push   %eax
f0104c0b:	ff 72 64             	pushl  0x64(%edx)
f0104c0e:	e8 12 cf ff ff       	call   f0101b25 <page_insert>
f0104c13:	83 c4 10             	add    $0x10,%esp
f0104c16:	85 c0                	test   %eax,%eax
f0104c18:	79 af                	jns    f0104bc9 <sys_ipc_try_send+0xad>
				return -E_NO_MEM;
f0104c1a:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0104c1f:	eb d8                	jmp    f0104bf9 <sys_ipc_try_send+0xdd>
		return -E_BAD_ENV;
f0104c21:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104c26:	eb d1                	jmp    f0104bf9 <sys_ipc_try_send+0xdd>
		return -E_IPC_NOT_RECV;
f0104c28:	b8 f9 ff ff ff       	mov    $0xfffffff9,%eax
f0104c2d:	eb ca                	jmp    f0104bf9 <sys_ipc_try_send+0xdd>
			return -E_INVAL;
f0104c2f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104c34:	eb c3                	jmp    f0104bf9 <sys_ipc_try_send+0xdd>
			return -E_INVAL;
f0104c36:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104c3b:	eb bc                	jmp    f0104bf9 <sys_ipc_try_send+0xdd>
f0104c3d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104c42:	eb b5                	jmp    f0104bf9 <sys_ipc_try_send+0xdd>
			return -E_INVAL;
f0104c44:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104c49:	eb ae                	jmp    f0104bf9 <sys_ipc_try_send+0xdd>
			return -E_INVAL;
f0104c4b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104c50:	eb a7                	jmp    f0104bf9 <sys_ipc_try_send+0xdd>

f0104c52 <sys_page_unmap>:
{
f0104c52:	55                   	push   %ebp
f0104c53:	89 e5                	mov    %esp,%ebp
f0104c55:	53                   	push   %ebx
f0104c56:	83 ec 18             	sub    $0x18,%esp
f0104c59:	89 d3                	mov    %edx,%ebx
	if (envid2env(envid, &e, 1) < 0)
f0104c5b:	6a 01                	push   $0x1
f0104c5d:	8d 55 f4             	lea    -0xc(%ebp),%edx
f0104c60:	52                   	push   %edx
f0104c61:	50                   	push   %eax
f0104c62:	e8 4d e5 ff ff       	call   f01031b4 <envid2env>
f0104c67:	83 c4 10             	add    $0x10,%esp
f0104c6a:	85 c0                	test   %eax,%eax
f0104c6c:	78 4b                	js     f0104cb9 <sys_page_unmap+0x67>
	if (((int) va >= UTOP) | ((int) va % PGSIZE != 0))
f0104c6e:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
f0104c74:	75 4a                	jne    f0104cc0 <sys_page_unmap+0x6e>
f0104c76:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
f0104c7c:	77 42                	ja     f0104cc0 <sys_page_unmap+0x6e>
	struct PageInfo *page = page_lookup(e->env_pgdir, va, NULL);
f0104c7e:	83 ec 04             	sub    $0x4,%esp
f0104c81:	6a 00                	push   $0x0
f0104c83:	53                   	push   %ebx
f0104c84:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104c87:	ff 70 64             	pushl  0x64(%eax)
f0104c8a:	e8 d0 cd ff ff       	call   f0101a5f <page_lookup>
f0104c8f:	89 c2                	mov    %eax,%edx
	if (!page)
f0104c91:	83 c4 10             	add    $0x10,%esp
		return 0;
f0104c94:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!page)
f0104c99:	85 d2                	test   %edx,%edx
f0104c9b:	74 17                	je     f0104cb4 <sys_page_unmap+0x62>
	page_remove(e->env_pgdir, va);
f0104c9d:	83 ec 08             	sub    $0x8,%esp
f0104ca0:	53                   	push   %ebx
f0104ca1:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104ca4:	ff 70 64             	pushl  0x64(%eax)
f0104ca7:	e8 27 ce ff ff       	call   f0101ad3 <page_remove>
	return 0;
f0104cac:	83 c4 10             	add    $0x10,%esp
f0104caf:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104cb4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104cb7:	c9                   	leave  
f0104cb8:	c3                   	ret    
		return -E_BAD_ENV;
f0104cb9:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104cbe:	eb f4                	jmp    f0104cb4 <sys_page_unmap+0x62>
		return -E_INVAL;
f0104cc0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104cc5:	eb ed                	jmp    f0104cb4 <sys_page_unmap+0x62>

f0104cc7 <rand2>:
{
f0104cc7:	f3 0f 1e fb          	endbr32 
	next1 = next1 * 1103515245 + 12345;
f0104ccb:	69 05 b8 33 12 f0 6d 	imul   $0x41c64e6d,0xf01233b8,%eax
f0104cd2:	4e c6 41 
f0104cd5:	8d 90 39 30 00 00    	lea    0x3039(%eax),%edx
f0104cdb:	89 15 b8 33 12 f0    	mov    %edx,0xf01233b8
	return ((unsigned) (next1 / 65536) % 32768);
f0104ce1:	05 38 30 01 00       	add    $0x13038,%eax
f0104ce6:	85 d2                	test   %edx,%edx
f0104ce8:	0f 49 c2             	cmovns %edx,%eax
f0104ceb:	c1 f8 10             	sar    $0x10,%eax
f0104cee:	25 ff 7f 00 00       	and    $0x7fff,%eax
}
f0104cf3:	c3                   	ret    

f0104cf4 <syscall>:


// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104cf4:	f3 0f 1e fb          	endbr32 
f0104cf8:	55                   	push   %ebp
f0104cf9:	89 e5                	mov    %esp,%ebp
f0104cfb:	83 ec 08             	sub    $0x8,%esp
f0104cfe:	8b 45 08             	mov    0x8(%ebp),%eax
f0104d01:	83 f8 0d             	cmp    $0xd,%eax
f0104d04:	0f 87 ca 00 00 00    	ja     f0104dd4 <syscall+0xe0>
f0104d0a:	3e ff 24 85 94 7e 10 	notrack jmp *-0xfef816c(,%eax,4)
f0104d11:	f0 
	// Return any appropriate return value.
	// LAB 3: Your code here.

	switch (syscallno) {
	case SYS_cputs:
		sys_cputs((const char *) a1, a2);
f0104d12:	8b 55 10             	mov    0x10(%ebp),%edx
f0104d15:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104d18:	e8 64 f9 ff ff       	call   f0104681 <sys_cputs>
		return 0;
f0104d1d:	b8 00 00 00 00       	mov    $0x0,%eax
		return sys_change_priority(a1, a2);

	default:
		return -E_INVAL;
	}
}
f0104d22:	c9                   	leave  
f0104d23:	c3                   	ret    
		return sys_getenvid();
f0104d24:	e8 3f f9 ff ff       	call   f0104668 <sys_getenvid>
f0104d29:	eb f7                	jmp    f0104d22 <syscall+0x2e>
		return sys_cgetc();
f0104d2b:	e8 8a f9 ff ff       	call   f01046ba <sys_cgetc>
f0104d30:	eb f0                	jmp    f0104d22 <syscall+0x2e>
		return sys_env_destroy(a1);
f0104d32:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104d35:	e8 87 fa ff ff       	call   f01047c1 <sys_env_destroy>
f0104d3a:	eb e6                	jmp    f0104d22 <syscall+0x2e>
		sys_yield();
f0104d3c:	e8 0d fb ff ff       	call   f010484e <sys_yield>
		return sys_exofork();
f0104d41:	e8 95 fb ff ff       	call   f01048db <sys_exofork>
f0104d46:	eb da                	jmp    f0104d22 <syscall+0x2e>
		return sys_env_set_status(a1, a2);
f0104d48:	8b 55 10             	mov    0x10(%ebp),%edx
f0104d4b:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104d4e:	e8 74 f9 ff ff       	call   f01046c7 <sys_env_set_status>
f0104d53:	eb cd                	jmp    f0104d22 <syscall+0x2e>
		return sys_page_alloc(a1, (void *) a2, a3);
f0104d55:	8b 4d 14             	mov    0x14(%ebp),%ecx
f0104d58:	8b 55 10             	mov    0x10(%ebp),%edx
f0104d5b:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104d5e:	e8 d7 fb ff ff       	call   f010493a <sys_page_alloc>
f0104d63:	eb bd                	jmp    f0104d22 <syscall+0x2e>
		return sys_page_map(a1, (void *) a2, a3, (void *) a4, a5);
f0104d65:	83 ec 08             	sub    $0x8,%esp
f0104d68:	ff 75 1c             	pushl  0x1c(%ebp)
f0104d6b:	ff 75 18             	pushl  0x18(%ebp)
f0104d6e:	8b 4d 14             	mov    0x14(%ebp),%ecx
f0104d71:	8b 55 10             	mov    0x10(%ebp),%edx
f0104d74:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104d77:	e8 7d fc ff ff       	call   f01049f9 <sys_page_map>
f0104d7c:	83 c4 10             	add    $0x10,%esp
f0104d7f:	eb a1                	jmp    f0104d22 <syscall+0x2e>
		return sys_page_unmap(a1, (void *) a2);
f0104d81:	8b 55 10             	mov    0x10(%ebp),%edx
f0104d84:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104d87:	e8 c6 fe ff ff       	call   f0104c52 <sys_page_unmap>
f0104d8c:	eb 94                	jmp    f0104d22 <syscall+0x2e>
		return sys_ipc_recv((void *) a1);
f0104d8e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104d91:	e8 c3 fa ff ff       	call   f0104859 <sys_ipc_recv>
f0104d96:	eb 8a                	jmp    f0104d22 <syscall+0x2e>
		return sys_ipc_try_send(a1, a2, (void *) a3, a4);
f0104d98:	83 ec 0c             	sub    $0xc,%esp
f0104d9b:	ff 75 18             	pushl  0x18(%ebp)
f0104d9e:	8b 4d 14             	mov    0x14(%ebp),%ecx
f0104da1:	8b 55 10             	mov    0x10(%ebp),%edx
f0104da4:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104da7:	e8 70 fd ff ff       	call   f0104b1c <sys_ipc_try_send>
f0104dac:	83 c4 10             	add    $0x10,%esp
f0104daf:	e9 6e ff ff ff       	jmp    f0104d22 <syscall+0x2e>
		return sys_env_set_pgfault_upcall(a1, (void *) a2);
f0104db4:	8b 55 10             	mov    0x10(%ebp),%edx
f0104db7:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104dba:	e8 74 f9 ff ff       	call   f0104733 <sys_env_set_pgfault_upcall>
f0104dbf:	e9 5e ff ff ff       	jmp    f0104d22 <syscall+0x2e>
		return sys_change_priority(a1, a2);
f0104dc4:	8b 55 10             	mov    0x10(%ebp),%edx
f0104dc7:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104dca:	e8 97 f9 ff ff       	call   f0104766 <sys_change_priority>
f0104dcf:	e9 4e ff ff ff       	jmp    f0104d22 <syscall+0x2e>
		return 0;
f0104dd4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104dd9:	e9 44 ff ff ff       	jmp    f0104d22 <syscall+0x2e>

f0104dde <stab_binsearch>:
stab_binsearch(const struct Stab *stabs,
               int *region_left,
               int *region_right,
               int type,
               uintptr_t addr)
{
f0104dde:	55                   	push   %ebp
f0104ddf:	89 e5                	mov    %esp,%ebp
f0104de1:	57                   	push   %edi
f0104de2:	56                   	push   %esi
f0104de3:	53                   	push   %ebx
f0104de4:	83 ec 14             	sub    $0x14,%esp
f0104de7:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104dea:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104ded:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104df0:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0104df3:	8b 1a                	mov    (%edx),%ebx
f0104df5:	8b 01                	mov    (%ecx),%eax
f0104df7:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104dfa:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0104e01:	eb 23                	jmp    f0104e26 <stab_binsearch+0x48>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {  // no match in [l, m]
			l = true_m + 1;
f0104e03:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0104e06:	eb 1e                	jmp    f0104e26 <stab_binsearch+0x48>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0104e08:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104e0b:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104e0e:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0104e12:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0104e15:	73 46                	jae    f0104e5d <stab_binsearch+0x7f>
			*region_left = m;
f0104e17:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104e1a:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0104e1c:	8d 5f 01             	lea    0x1(%edi),%ebx
		any_matches = 1;
f0104e1f:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0104e26:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0104e29:	7f 5f                	jg     f0104e8a <stab_binsearch+0xac>
		int true_m = (l + r) / 2, m = true_m;
f0104e2b:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104e2e:	8d 14 03             	lea    (%ebx,%eax,1),%edx
f0104e31:	89 d0                	mov    %edx,%eax
f0104e33:	c1 e8 1f             	shr    $0x1f,%eax
f0104e36:	01 d0                	add    %edx,%eax
f0104e38:	89 c7                	mov    %eax,%edi
f0104e3a:	d1 ff                	sar    %edi
f0104e3c:	83 e0 fe             	and    $0xfffffffe,%eax
f0104e3f:	01 f8                	add    %edi,%eax
f0104e41:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104e44:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0104e48:	89 f8                	mov    %edi,%eax
		while (m >= l && stabs[m].n_type != type)
f0104e4a:	39 c3                	cmp    %eax,%ebx
f0104e4c:	7f b5                	jg     f0104e03 <stab_binsearch+0x25>
f0104e4e:	0f b6 0a             	movzbl (%edx),%ecx
f0104e51:	83 ea 0c             	sub    $0xc,%edx
f0104e54:	39 f1                	cmp    %esi,%ecx
f0104e56:	74 b0                	je     f0104e08 <stab_binsearch+0x2a>
			m--;
f0104e58:	83 e8 01             	sub    $0x1,%eax
f0104e5b:	eb ed                	jmp    f0104e4a <stab_binsearch+0x6c>
		} else if (stabs[m].n_value > addr) {
f0104e5d:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0104e60:	76 14                	jbe    f0104e76 <stab_binsearch+0x98>
			*region_right = m - 1;
f0104e62:	83 e8 01             	sub    $0x1,%eax
f0104e65:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104e68:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0104e6b:	89 07                	mov    %eax,(%edi)
		any_matches = 1;
f0104e6d:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104e74:	eb b0                	jmp    f0104e26 <stab_binsearch+0x48>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0104e76:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104e79:	89 07                	mov    %eax,(%edi)
			l = m;
			addr++;
f0104e7b:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0104e7f:	89 c3                	mov    %eax,%ebx
		any_matches = 1;
f0104e81:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104e88:	eb 9c                	jmp    f0104e26 <stab_binsearch+0x48>
		}
	}

	if (!any_matches)
f0104e8a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0104e8e:	75 15                	jne    f0104ea5 <stab_binsearch+0xc7>
		*region_right = *region_left - 1;
f0104e90:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104e93:	8b 00                	mov    (%eax),%eax
f0104e95:	83 e8 01             	sub    $0x1,%eax
f0104e98:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0104e9b:	89 07                	mov    %eax,(%edi)
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0104e9d:	83 c4 14             	add    $0x14,%esp
f0104ea0:	5b                   	pop    %ebx
f0104ea1:	5e                   	pop    %esi
f0104ea2:	5f                   	pop    %edi
f0104ea3:	5d                   	pop    %ebp
f0104ea4:	c3                   	ret    
		for (l = *region_right;
f0104ea5:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104ea8:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0104eaa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104ead:	8b 0f                	mov    (%edi),%ecx
f0104eaf:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104eb2:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0104eb5:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
		for (l = *region_right;
f0104eb9:	eb 03                	jmp    f0104ebe <stab_binsearch+0xe0>
		     l--)
f0104ebb:	83 e8 01             	sub    $0x1,%eax
		for (l = *region_right;
f0104ebe:	39 c1                	cmp    %eax,%ecx
f0104ec0:	7d 0a                	jge    f0104ecc <stab_binsearch+0xee>
		     l > *region_left && stabs[l].n_type != type;
f0104ec2:	0f b6 1a             	movzbl (%edx),%ebx
f0104ec5:	83 ea 0c             	sub    $0xc,%edx
f0104ec8:	39 f3                	cmp    %esi,%ebx
f0104eca:	75 ef                	jne    f0104ebb <stab_binsearch+0xdd>
		*region_left = l;
f0104ecc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104ecf:	89 07                	mov    %eax,(%edi)
}
f0104ed1:	eb ca                	jmp    f0104e9d <stab_binsearch+0xbf>

f0104ed3 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0104ed3:	f3 0f 1e fb          	endbr32 
f0104ed7:	55                   	push   %ebp
f0104ed8:	89 e5                	mov    %esp,%ebp
f0104eda:	57                   	push   %edi
f0104edb:	56                   	push   %esi
f0104edc:	53                   	push   %ebx
f0104edd:	83 ec 4c             	sub    $0x4c,%esp
f0104ee0:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104ee3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0104ee6:	c7 03 cc 7e 10 f0    	movl   $0xf0107ecc,(%ebx)
	info->eip_line = 0;
f0104eec:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0104ef3:	c7 43 08 cc 7e 10 f0 	movl   $0xf0107ecc,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0104efa:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0104f01:	89 7b 10             	mov    %edi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0104f04:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0104f0b:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0104f11:	0f 86 21 01 00 00    	jbe    f0105038 <debuginfo_eip+0x165>
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0104f17:	c7 45 b8 f1 90 11 f0 	movl   $0xf01190f1,-0x48(%ebp)
		stabstr = __STABSTR_BEGIN__;
f0104f1e:	c7 45 b4 e5 4f 11 f0 	movl   $0xf0114fe5,-0x4c(%ebp)
		stab_end = __STAB_END__;
f0104f25:	be e4 4f 11 f0       	mov    $0xf0114fe4,%esi
		stabs = __STAB_BEGIN__;
f0104f2a:	c7 45 bc b4 83 10 f0 	movl   $0xf01083b4,-0x44(%ebp)
		    user_mem_check(curenv, stabstr, stabstr_end - stabstr, 0))
			return -1;
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0104f31:	8b 4d b8             	mov    -0x48(%ebp),%ecx
f0104f34:	39 4d b4             	cmp    %ecx,-0x4c(%ebp)
f0104f37:	0f 83 62 02 00 00    	jae    f010519f <debuginfo_eip+0x2cc>
f0104f3d:	80 79 ff 00          	cmpb   $0x0,-0x1(%ecx)
f0104f41:	0f 85 5f 02 00 00    	jne    f01051a6 <debuginfo_eip+0x2d3>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0104f47:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0104f4e:	2b 75 bc             	sub    -0x44(%ebp),%esi
f0104f51:	c1 fe 02             	sar    $0x2,%esi
f0104f54:	69 c6 ab aa aa aa    	imul   $0xaaaaaaab,%esi,%eax
f0104f5a:	83 e8 01             	sub    $0x1,%eax
f0104f5d:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0104f60:	83 ec 08             	sub    $0x8,%esp
f0104f63:	57                   	push   %edi
f0104f64:	6a 64                	push   $0x64
f0104f66:	8d 55 e0             	lea    -0x20(%ebp),%edx
f0104f69:	89 d1                	mov    %edx,%ecx
f0104f6b:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104f6e:	8b 75 bc             	mov    -0x44(%ebp),%esi
f0104f71:	89 f0                	mov    %esi,%eax
f0104f73:	e8 66 fe ff ff       	call   f0104dde <stab_binsearch>
	if (lfile == 0)
f0104f78:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104f7b:	83 c4 10             	add    $0x10,%esp
f0104f7e:	85 c0                	test   %eax,%eax
f0104f80:	0f 84 27 02 00 00    	je     f01051ad <debuginfo_eip+0x2da>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0104f86:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0104f89:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104f8c:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0104f8f:	83 ec 08             	sub    $0x8,%esp
f0104f92:	57                   	push   %edi
f0104f93:	6a 24                	push   $0x24
f0104f95:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0104f98:	89 d1                	mov    %edx,%ecx
f0104f9a:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0104f9d:	89 f0                	mov    %esi,%eax
f0104f9f:	e8 3a fe ff ff       	call   f0104dde <stab_binsearch>

	if (lfun <= rfun) {
f0104fa4:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104fa7:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104faa:	83 c4 10             	add    $0x10,%esp
f0104fad:	39 d0                	cmp    %edx,%eax
f0104faf:	0f 8f 32 01 00 00    	jg     f01050e7 <debuginfo_eip+0x214>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0104fb5:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0104fb8:	8d 34 8e             	lea    (%esi,%ecx,4),%esi
f0104fbb:	89 75 c4             	mov    %esi,-0x3c(%ebp)
f0104fbe:	8b 36                	mov    (%esi),%esi
f0104fc0:	8b 4d b8             	mov    -0x48(%ebp),%ecx
f0104fc3:	2b 4d b4             	sub    -0x4c(%ebp),%ecx
f0104fc6:	39 ce                	cmp    %ecx,%esi
f0104fc8:	73 06                	jae    f0104fd0 <debuginfo_eip+0xfd>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0104fca:	03 75 b4             	add    -0x4c(%ebp),%esi
f0104fcd:	89 73 08             	mov    %esi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0104fd0:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0104fd3:	8b 4e 08             	mov    0x8(%esi),%ecx
f0104fd6:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0104fd9:	29 cf                	sub    %ecx,%edi
		// Search within the function definition for the line number.
		lline = lfun;
f0104fdb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0104fde:	89 55 d0             	mov    %edx,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0104fe1:	83 ec 08             	sub    $0x8,%esp
f0104fe4:	6a 3a                	push   $0x3a
f0104fe6:	ff 73 08             	pushl  0x8(%ebx)
f0104fe9:	e8 57 09 00 00       	call   f0105945 <strfind>
f0104fee:	2b 43 08             	sub    0x8(%ebx),%eax
f0104ff1:	89 43 0c             	mov    %eax,0xc(%ebx)
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.

	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0104ff4:	83 c4 08             	add    $0x8,%esp
f0104ff7:	57                   	push   %edi
f0104ff8:	6a 44                	push   $0x44
f0104ffa:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0104ffd:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0105000:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0105003:	89 f8                	mov    %edi,%eax
f0105005:	e8 d4 fd ff ff       	call   f0104dde <stab_binsearch>
	if (lline <= rline) {
f010500a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f010500d:	83 c4 10             	add    $0x10,%esp
f0105010:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f0105013:	7f 0b                	jg     f0105020 <debuginfo_eip+0x14d>
		info->eip_line = stabs[lline].n_desc;
f0105015:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0105018:	0f b7 44 87 06       	movzwl 0x6(%edi,%eax,4),%eax
f010501d:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile && stabs[lline].n_type != N_SOL &&
f0105020:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105023:	89 d0                	mov    %edx,%eax
f0105025:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0105028:	8b 75 bc             	mov    -0x44(%ebp),%esi
f010502b:	8d 54 96 04          	lea    0x4(%esi,%edx,4),%edx
f010502f:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f0105033:	e9 cd 00 00 00       	jmp    f0105105 <debuginfo_eip+0x232>
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), 0))
f0105038:	e8 b7 0f 00 00       	call   f0105ff4 <cpunum>
f010503d:	6a 00                	push   $0x0
f010503f:	6a 10                	push   $0x10
f0105041:	68 00 00 20 00       	push   $0x200000
f0105046:	6b c0 74             	imul   $0x74,%eax,%eax
f0105049:	ff b0 28 00 25 f0    	pushl  -0xfdaffd8(%eax)
f010504f:	e8 cf dd ff ff       	call   f0102e23 <user_mem_check>
f0105054:	83 c4 10             	add    $0x10,%esp
f0105057:	85 c0                	test   %eax,%eax
f0105059:	0f 85 32 01 00 00    	jne    f0105191 <debuginfo_eip+0x2be>
		stabs = usd->stabs;
f010505f:	8b 0d 00 00 20 00    	mov    0x200000,%ecx
f0105065:	89 4d bc             	mov    %ecx,-0x44(%ebp)
		stab_end = usd->stab_end;
f0105068:	8b 35 04 00 20 00    	mov    0x200004,%esi
		stabstr = usd->stabstr;
f010506e:	a1 08 00 20 00       	mov    0x200008,%eax
f0105073:	89 45 b4             	mov    %eax,-0x4c(%ebp)
		stabstr_end = usd->stabstr_end;
f0105076:	8b 15 0c 00 20 00    	mov    0x20000c,%edx
f010507c:	89 55 b8             	mov    %edx,-0x48(%ebp)
		if (user_mem_check(curenv, stabs, stab_end - stabs, 0) ||
f010507f:	e8 70 0f 00 00       	call   f0105ff4 <cpunum>
f0105084:	89 c2                	mov    %eax,%edx
f0105086:	6a 00                	push   $0x0
f0105088:	89 f0                	mov    %esi,%eax
f010508a:	8b 4d bc             	mov    -0x44(%ebp),%ecx
f010508d:	29 c8                	sub    %ecx,%eax
f010508f:	c1 f8 02             	sar    $0x2,%eax
f0105092:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0105098:	50                   	push   %eax
f0105099:	51                   	push   %ecx
f010509a:	6b d2 74             	imul   $0x74,%edx,%edx
f010509d:	ff b2 28 00 25 f0    	pushl  -0xfdaffd8(%edx)
f01050a3:	e8 7b dd ff ff       	call   f0102e23 <user_mem_check>
f01050a8:	83 c4 10             	add    $0x10,%esp
f01050ab:	85 c0                	test   %eax,%eax
f01050ad:	0f 85 e5 00 00 00    	jne    f0105198 <debuginfo_eip+0x2c5>
		    user_mem_check(curenv, stabstr, stabstr_end - stabstr, 0))
f01050b3:	e8 3c 0f 00 00       	call   f0105ff4 <cpunum>
f01050b8:	6a 00                	push   $0x0
f01050ba:	8b 55 b8             	mov    -0x48(%ebp),%edx
f01050bd:	8b 4d b4             	mov    -0x4c(%ebp),%ecx
f01050c0:	29 ca                	sub    %ecx,%edx
f01050c2:	52                   	push   %edx
f01050c3:	51                   	push   %ecx
f01050c4:	6b c0 74             	imul   $0x74,%eax,%eax
f01050c7:	ff b0 28 00 25 f0    	pushl  -0xfdaffd8(%eax)
f01050cd:	e8 51 dd ff ff       	call   f0102e23 <user_mem_check>
		if (user_mem_check(curenv, stabs, stab_end - stabs, 0) ||
f01050d2:	83 c4 10             	add    $0x10,%esp
f01050d5:	85 c0                	test   %eax,%eax
f01050d7:	0f 84 54 fe ff ff    	je     f0104f31 <debuginfo_eip+0x5e>
			return -1;
f01050dd:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f01050e2:	e9 d2 00 00 00       	jmp    f01051b9 <debuginfo_eip+0x2e6>
		info->eip_fn_addr = addr;
f01050e7:	89 7b 10             	mov    %edi,0x10(%ebx)
		lline = lfile;
f01050ea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01050ed:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f01050f0:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01050f3:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01050f6:	e9 e6 fe ff ff       	jmp    f0104fe1 <debuginfo_eip+0x10e>
f01050fb:	83 e8 01             	sub    $0x1,%eax
f01050fe:	83 ea 0c             	sub    $0xc,%edx
	while (lline >= lfile && stabs[lline].n_type != N_SOL &&
f0105101:	c6 45 c4 01          	movb   $0x1,-0x3c(%ebp)
f0105105:	89 45 c0             	mov    %eax,-0x40(%ebp)
f0105108:	39 c7                	cmp    %eax,%edi
f010510a:	7f 45                	jg     f0105151 <debuginfo_eip+0x27e>
f010510c:	0f b6 0a             	movzbl (%edx),%ecx
f010510f:	80 f9 84             	cmp    $0x84,%cl
f0105112:	74 19                	je     f010512d <debuginfo_eip+0x25a>
f0105114:	80 f9 64             	cmp    $0x64,%cl
f0105117:	75 e2                	jne    f01050fb <debuginfo_eip+0x228>
	       (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0105119:	83 7a 04 00          	cmpl   $0x0,0x4(%edx)
f010511d:	74 dc                	je     f01050fb <debuginfo_eip+0x228>
f010511f:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0105123:	74 11                	je     f0105136 <debuginfo_eip+0x263>
f0105125:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0105128:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f010512b:	eb 09                	jmp    f0105136 <debuginfo_eip+0x263>
f010512d:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0105131:	74 03                	je     f0105136 <debuginfo_eip+0x263>
f0105133:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0105136:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0105139:	8b 7d bc             	mov    -0x44(%ebp),%edi
f010513c:	8b 14 87             	mov    (%edi,%eax,4),%edx
f010513f:	8b 45 b8             	mov    -0x48(%ebp),%eax
f0105142:	8b 7d b4             	mov    -0x4c(%ebp),%edi
f0105145:	29 f8                	sub    %edi,%eax
f0105147:	39 c2                	cmp    %eax,%edx
f0105149:	73 06                	jae    f0105151 <debuginfo_eip+0x27e>
		info->eip_file = stabstr + stabs[lline].n_strx;
f010514b:	89 f8                	mov    %edi,%eax
f010514d:	01 d0                	add    %edx,%eax
f010514f:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0105151:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105154:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0105157:	ba 00 00 00 00       	mov    $0x0,%edx
	if (lfun < rfun)
f010515c:	39 f0                	cmp    %esi,%eax
f010515e:	7d 59                	jge    f01051b9 <debuginfo_eip+0x2e6>
		for (lline = lfun + 1;
f0105160:	8d 50 01             	lea    0x1(%eax),%edx
f0105163:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0105166:	89 d0                	mov    %edx,%eax
f0105168:	8d 14 52             	lea    (%edx,%edx,2),%edx
f010516b:	8b 7d bc             	mov    -0x44(%ebp),%edi
f010516e:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
f0105172:	eb 04                	jmp    f0105178 <debuginfo_eip+0x2a5>
			info->eip_fn_narg++;
f0105174:	83 43 14 01          	addl   $0x1,0x14(%ebx)
		for (lline = lfun + 1;
f0105178:	39 c6                	cmp    %eax,%esi
f010517a:	7e 38                	jle    f01051b4 <debuginfo_eip+0x2e1>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f010517c:	0f b6 0a             	movzbl (%edx),%ecx
f010517f:	83 c0 01             	add    $0x1,%eax
f0105182:	83 c2 0c             	add    $0xc,%edx
f0105185:	80 f9 a0             	cmp    $0xa0,%cl
f0105188:	74 ea                	je     f0105174 <debuginfo_eip+0x2a1>
	return 0;
f010518a:	ba 00 00 00 00       	mov    $0x0,%edx
f010518f:	eb 28                	jmp    f01051b9 <debuginfo_eip+0x2e6>
			return -1;
f0105191:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0105196:	eb 21                	jmp    f01051b9 <debuginfo_eip+0x2e6>
			return -1;
f0105198:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f010519d:	eb 1a                	jmp    f01051b9 <debuginfo_eip+0x2e6>
		return -1;
f010519f:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f01051a4:	eb 13                	jmp    f01051b9 <debuginfo_eip+0x2e6>
f01051a6:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f01051ab:	eb 0c                	jmp    f01051b9 <debuginfo_eip+0x2e6>
		return -1;
f01051ad:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f01051b2:	eb 05                	jmp    f01051b9 <debuginfo_eip+0x2e6>
	return 0;
f01051b4:	ba 00 00 00 00       	mov    $0x0,%edx
}
f01051b9:	89 d0                	mov    %edx,%eax
f01051bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01051be:	5b                   	pop    %ebx
f01051bf:	5e                   	pop    %esi
f01051c0:	5f                   	pop    %edi
f01051c1:	5d                   	pop    %ebp
f01051c2:	c3                   	ret    

f01051c3 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f01051c3:	55                   	push   %ebp
f01051c4:	89 e5                	mov    %esp,%ebp
f01051c6:	57                   	push   %edi
f01051c7:	56                   	push   %esi
f01051c8:	53                   	push   %ebx
f01051c9:	83 ec 1c             	sub    $0x1c,%esp
f01051cc:	89 c7                	mov    %eax,%edi
f01051ce:	89 d6                	mov    %edx,%esi
f01051d0:	8b 45 08             	mov    0x8(%ebp),%eax
f01051d3:	8b 55 0c             	mov    0xc(%ebp),%edx
f01051d6:	89 d1                	mov    %edx,%ecx
f01051d8:	89 c2                	mov    %eax,%edx
f01051da:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01051dd:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f01051e0:	8b 45 10             	mov    0x10(%ebp),%eax
f01051e3:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f01051e6:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01051e9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f01051f0:	39 c2                	cmp    %eax,%edx
f01051f2:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
f01051f5:	72 3e                	jb     f0105235 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f01051f7:	83 ec 0c             	sub    $0xc,%esp
f01051fa:	ff 75 18             	pushl  0x18(%ebp)
f01051fd:	83 eb 01             	sub    $0x1,%ebx
f0105200:	53                   	push   %ebx
f0105201:	50                   	push   %eax
f0105202:	83 ec 08             	sub    $0x8,%esp
f0105205:	ff 75 e4             	pushl  -0x1c(%ebp)
f0105208:	ff 75 e0             	pushl  -0x20(%ebp)
f010520b:	ff 75 dc             	pushl  -0x24(%ebp)
f010520e:	ff 75 d8             	pushl  -0x28(%ebp)
f0105211:	e8 3a 12 00 00       	call   f0106450 <__udivdi3>
f0105216:	83 c4 18             	add    $0x18,%esp
f0105219:	52                   	push   %edx
f010521a:	50                   	push   %eax
f010521b:	89 f2                	mov    %esi,%edx
f010521d:	89 f8                	mov    %edi,%eax
f010521f:	e8 9f ff ff ff       	call   f01051c3 <printnum>
f0105224:	83 c4 20             	add    $0x20,%esp
f0105227:	eb 13                	jmp    f010523c <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0105229:	83 ec 08             	sub    $0x8,%esp
f010522c:	56                   	push   %esi
f010522d:	ff 75 18             	pushl  0x18(%ebp)
f0105230:	ff d7                	call   *%edi
f0105232:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f0105235:	83 eb 01             	sub    $0x1,%ebx
f0105238:	85 db                	test   %ebx,%ebx
f010523a:	7f ed                	jg     f0105229 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f010523c:	83 ec 08             	sub    $0x8,%esp
f010523f:	56                   	push   %esi
f0105240:	83 ec 04             	sub    $0x4,%esp
f0105243:	ff 75 e4             	pushl  -0x1c(%ebp)
f0105246:	ff 75 e0             	pushl  -0x20(%ebp)
f0105249:	ff 75 dc             	pushl  -0x24(%ebp)
f010524c:	ff 75 d8             	pushl  -0x28(%ebp)
f010524f:	e8 0c 13 00 00       	call   f0106560 <__umoddi3>
f0105254:	83 c4 14             	add    $0x14,%esp
f0105257:	0f be 80 d6 7e 10 f0 	movsbl -0xfef812a(%eax),%eax
f010525e:	50                   	push   %eax
f010525f:	ff d7                	call   *%edi
}
f0105261:	83 c4 10             	add    $0x10,%esp
f0105264:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105267:	5b                   	pop    %ebx
f0105268:	5e                   	pop    %esi
f0105269:	5f                   	pop    %edi
f010526a:	5d                   	pop    %ebp
f010526b:	c3                   	ret    

f010526c <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f010526c:	83 fa 01             	cmp    $0x1,%edx
f010526f:	7f 13                	jg     f0105284 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
f0105271:	85 d2                	test   %edx,%edx
f0105273:	74 1c                	je     f0105291 <getuint+0x25>
		return va_arg(*ap, unsigned long);
f0105275:	8b 10                	mov    (%eax),%edx
f0105277:	8d 4a 04             	lea    0x4(%edx),%ecx
f010527a:	89 08                	mov    %ecx,(%eax)
f010527c:	8b 02                	mov    (%edx),%eax
f010527e:	ba 00 00 00 00       	mov    $0x0,%edx
f0105283:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
f0105284:	8b 10                	mov    (%eax),%edx
f0105286:	8d 4a 08             	lea    0x8(%edx),%ecx
f0105289:	89 08                	mov    %ecx,(%eax)
f010528b:	8b 02                	mov    (%edx),%eax
f010528d:	8b 52 04             	mov    0x4(%edx),%edx
f0105290:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
f0105291:	8b 10                	mov    (%eax),%edx
f0105293:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105296:	89 08                	mov    %ecx,(%eax)
f0105298:	8b 02                	mov    (%edx),%eax
f010529a:	ba 00 00 00 00       	mov    $0x0,%edx
}
f010529f:	c3                   	ret    

f01052a0 <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f01052a0:	83 fa 01             	cmp    $0x1,%edx
f01052a3:	7f 0f                	jg     f01052b4 <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
f01052a5:	85 d2                	test   %edx,%edx
f01052a7:	74 18                	je     f01052c1 <getint+0x21>
		return va_arg(*ap, long);
f01052a9:	8b 10                	mov    (%eax),%edx
f01052ab:	8d 4a 04             	lea    0x4(%edx),%ecx
f01052ae:	89 08                	mov    %ecx,(%eax)
f01052b0:	8b 02                	mov    (%edx),%eax
f01052b2:	99                   	cltd   
f01052b3:	c3                   	ret    
		return va_arg(*ap, long long);
f01052b4:	8b 10                	mov    (%eax),%edx
f01052b6:	8d 4a 08             	lea    0x8(%edx),%ecx
f01052b9:	89 08                	mov    %ecx,(%eax)
f01052bb:	8b 02                	mov    (%edx),%eax
f01052bd:	8b 52 04             	mov    0x4(%edx),%edx
f01052c0:	c3                   	ret    
	else
		return va_arg(*ap, int);
f01052c1:	8b 10                	mov    (%eax),%edx
f01052c3:	8d 4a 04             	lea    0x4(%edx),%ecx
f01052c6:	89 08                	mov    %ecx,(%eax)
f01052c8:	8b 02                	mov    (%edx),%eax
f01052ca:	99                   	cltd   
}
f01052cb:	c3                   	ret    

f01052cc <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f01052cc:	f3 0f 1e fb          	endbr32 
f01052d0:	55                   	push   %ebp
f01052d1:	89 e5                	mov    %esp,%ebp
f01052d3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f01052d6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f01052da:	8b 10                	mov    (%eax),%edx
f01052dc:	3b 50 04             	cmp    0x4(%eax),%edx
f01052df:	73 0a                	jae    f01052eb <sprintputch+0x1f>
		*b->buf++ = ch;
f01052e1:	8d 4a 01             	lea    0x1(%edx),%ecx
f01052e4:	89 08                	mov    %ecx,(%eax)
f01052e6:	8b 45 08             	mov    0x8(%ebp),%eax
f01052e9:	88 02                	mov    %al,(%edx)
}
f01052eb:	5d                   	pop    %ebp
f01052ec:	c3                   	ret    

f01052ed <printfmt>:
{
f01052ed:	f3 0f 1e fb          	endbr32 
f01052f1:	55                   	push   %ebp
f01052f2:	89 e5                	mov    %esp,%ebp
f01052f4:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f01052f7:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f01052fa:	50                   	push   %eax
f01052fb:	ff 75 10             	pushl  0x10(%ebp)
f01052fe:	ff 75 0c             	pushl  0xc(%ebp)
f0105301:	ff 75 08             	pushl  0x8(%ebp)
f0105304:	e8 05 00 00 00       	call   f010530e <vprintfmt>
}
f0105309:	83 c4 10             	add    $0x10,%esp
f010530c:	c9                   	leave  
f010530d:	c3                   	ret    

f010530e <vprintfmt>:
{
f010530e:	f3 0f 1e fb          	endbr32 
f0105312:	55                   	push   %ebp
f0105313:	89 e5                	mov    %esp,%ebp
f0105315:	57                   	push   %edi
f0105316:	56                   	push   %esi
f0105317:	53                   	push   %ebx
f0105318:	83 ec 2c             	sub    $0x2c,%esp
f010531b:	8b 5d 08             	mov    0x8(%ebp),%ebx
f010531e:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105321:	8b 7d 10             	mov    0x10(%ebp),%edi
f0105324:	e9 86 02 00 00       	jmp    f01055af <vprintfmt+0x2a1>
		padc = ' ';
f0105329:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
f010532d:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
f0105334:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
f010533b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f0105342:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f0105347:	8d 47 01             	lea    0x1(%edi),%eax
f010534a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010534d:	0f b6 17             	movzbl (%edi),%edx
f0105350:	8d 42 dd             	lea    -0x23(%edx),%eax
f0105353:	3c 55                	cmp    $0x55,%al
f0105355:	0f 87 df 02 00 00    	ja     f010563a <vprintfmt+0x32c>
f010535b:	0f b6 c0             	movzbl %al,%eax
f010535e:	3e ff 24 85 a0 7f 10 	notrack jmp *-0xfef8060(,%eax,4)
f0105365:	f0 
f0105366:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
f0105369:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
f010536d:	eb d8                	jmp    f0105347 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
f010536f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105372:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
f0105376:	eb cf                	jmp    f0105347 <vprintfmt+0x39>
f0105378:	0f b6 d2             	movzbl %dl,%edx
f010537b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
f010537e:	b8 00 00 00 00       	mov    $0x0,%eax
f0105383:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
f0105386:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0105389:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f010538d:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f0105390:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0105393:	83 f9 09             	cmp    $0x9,%ecx
f0105396:	77 52                	ja     f01053ea <vprintfmt+0xdc>
			for (precision = 0; ; ++fmt) {
f0105398:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
f010539b:	eb e9                	jmp    f0105386 <vprintfmt+0x78>
			precision = va_arg(ap, int);
f010539d:	8b 45 14             	mov    0x14(%ebp),%eax
f01053a0:	8d 50 04             	lea    0x4(%eax),%edx
f01053a3:	89 55 14             	mov    %edx,0x14(%ebp)
f01053a6:	8b 00                	mov    (%eax),%eax
f01053a8:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01053ab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
f01053ae:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01053b2:	79 93                	jns    f0105347 <vprintfmt+0x39>
				width = precision, precision = -1;
f01053b4:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01053b7:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01053ba:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
f01053c1:	eb 84                	jmp    f0105347 <vprintfmt+0x39>
f01053c3:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01053c6:	85 c0                	test   %eax,%eax
f01053c8:	ba 00 00 00 00       	mov    $0x0,%edx
f01053cd:	0f 49 d0             	cmovns %eax,%edx
f01053d0:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01053d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f01053d6:	e9 6c ff ff ff       	jmp    f0105347 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
f01053db:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
f01053de:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
f01053e5:	e9 5d ff ff ff       	jmp    f0105347 <vprintfmt+0x39>
f01053ea:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01053ed:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01053f0:	eb bc                	jmp    f01053ae <vprintfmt+0xa0>
			lflag++;
f01053f2:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f01053f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f01053f8:	e9 4a ff ff ff       	jmp    f0105347 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
f01053fd:	8b 45 14             	mov    0x14(%ebp),%eax
f0105400:	8d 50 04             	lea    0x4(%eax),%edx
f0105403:	89 55 14             	mov    %edx,0x14(%ebp)
f0105406:	83 ec 08             	sub    $0x8,%esp
f0105409:	56                   	push   %esi
f010540a:	ff 30                	pushl  (%eax)
f010540c:	ff d3                	call   *%ebx
			break;
f010540e:	83 c4 10             	add    $0x10,%esp
f0105411:	e9 96 01 00 00       	jmp    f01055ac <vprintfmt+0x29e>
			err = va_arg(ap, int);
f0105416:	8b 45 14             	mov    0x14(%ebp),%eax
f0105419:	8d 50 04             	lea    0x4(%eax),%edx
f010541c:	89 55 14             	mov    %edx,0x14(%ebp)
f010541f:	8b 00                	mov    (%eax),%eax
f0105421:	99                   	cltd   
f0105422:	31 d0                	xor    %edx,%eax
f0105424:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0105426:	83 f8 08             	cmp    $0x8,%eax
f0105429:	7f 20                	jg     f010544b <vprintfmt+0x13d>
f010542b:	8b 14 85 00 81 10 f0 	mov    -0xfef7f00(,%eax,4),%edx
f0105432:	85 d2                	test   %edx,%edx
f0105434:	74 15                	je     f010544b <vprintfmt+0x13d>
				printfmt(putch, putdat, "%s", p);
f0105436:	52                   	push   %edx
f0105437:	68 55 76 10 f0       	push   $0xf0107655
f010543c:	56                   	push   %esi
f010543d:	53                   	push   %ebx
f010543e:	e8 aa fe ff ff       	call   f01052ed <printfmt>
f0105443:	83 c4 10             	add    $0x10,%esp
f0105446:	e9 61 01 00 00       	jmp    f01055ac <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
f010544b:	50                   	push   %eax
f010544c:	68 ee 7e 10 f0       	push   $0xf0107eee
f0105451:	56                   	push   %esi
f0105452:	53                   	push   %ebx
f0105453:	e8 95 fe ff ff       	call   f01052ed <printfmt>
f0105458:	83 c4 10             	add    $0x10,%esp
f010545b:	e9 4c 01 00 00       	jmp    f01055ac <vprintfmt+0x29e>
			if ((p = va_arg(ap, char *)) == NULL)
f0105460:	8b 45 14             	mov    0x14(%ebp),%eax
f0105463:	8d 50 04             	lea    0x4(%eax),%edx
f0105466:	89 55 14             	mov    %edx,0x14(%ebp)
f0105469:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
f010546b:	85 c9                	test   %ecx,%ecx
f010546d:	b8 e7 7e 10 f0       	mov    $0xf0107ee7,%eax
f0105472:	0f 45 c1             	cmovne %ecx,%eax
f0105475:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
f0105478:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f010547c:	7e 06                	jle    f0105484 <vprintfmt+0x176>
f010547e:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
f0105482:	75 0d                	jne    f0105491 <vprintfmt+0x183>
				for (width -= strnlen(p, precision); width > 0; width--)
f0105484:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0105487:	89 c7                	mov    %eax,%edi
f0105489:	03 45 e0             	add    -0x20(%ebp),%eax
f010548c:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010548f:	eb 57                	jmp    f01054e8 <vprintfmt+0x1da>
f0105491:	83 ec 08             	sub    $0x8,%esp
f0105494:	ff 75 d8             	pushl  -0x28(%ebp)
f0105497:	ff 75 cc             	pushl  -0x34(%ebp)
f010549a:	e8 35 03 00 00       	call   f01057d4 <strnlen>
f010549f:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01054a2:	29 c2                	sub    %eax,%edx
f01054a4:	89 55 e0             	mov    %edx,-0x20(%ebp)
f01054a7:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f01054aa:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
f01054ae:	89 5d 08             	mov    %ebx,0x8(%ebp)
f01054b1:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
f01054b3:	85 db                	test   %ebx,%ebx
f01054b5:	7e 10                	jle    f01054c7 <vprintfmt+0x1b9>
					putch(padc, putdat);
f01054b7:	83 ec 08             	sub    $0x8,%esp
f01054ba:	56                   	push   %esi
f01054bb:	57                   	push   %edi
f01054bc:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f01054bf:	83 eb 01             	sub    $0x1,%ebx
f01054c2:	83 c4 10             	add    $0x10,%esp
f01054c5:	eb ec                	jmp    f01054b3 <vprintfmt+0x1a5>
f01054c7:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01054ca:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01054cd:	85 d2                	test   %edx,%edx
f01054cf:	b8 00 00 00 00       	mov    $0x0,%eax
f01054d4:	0f 49 c2             	cmovns %edx,%eax
f01054d7:	29 c2                	sub    %eax,%edx
f01054d9:	89 55 e0             	mov    %edx,-0x20(%ebp)
f01054dc:	eb a6                	jmp    f0105484 <vprintfmt+0x176>
					putch(ch, putdat);
f01054de:	83 ec 08             	sub    $0x8,%esp
f01054e1:	56                   	push   %esi
f01054e2:	52                   	push   %edx
f01054e3:	ff d3                	call   *%ebx
f01054e5:	83 c4 10             	add    $0x10,%esp
f01054e8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01054eb:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01054ed:	83 c7 01             	add    $0x1,%edi
f01054f0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f01054f4:	0f be d0             	movsbl %al,%edx
f01054f7:	85 d2                	test   %edx,%edx
f01054f9:	74 42                	je     f010553d <vprintfmt+0x22f>
f01054fb:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f01054ff:	78 06                	js     f0105507 <vprintfmt+0x1f9>
f0105501:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
f0105505:	78 1e                	js     f0105525 <vprintfmt+0x217>
				if (altflag && (ch < ' ' || ch > '~'))
f0105507:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f010550b:	74 d1                	je     f01054de <vprintfmt+0x1d0>
f010550d:	0f be c0             	movsbl %al,%eax
f0105510:	83 e8 20             	sub    $0x20,%eax
f0105513:	83 f8 5e             	cmp    $0x5e,%eax
f0105516:	76 c6                	jbe    f01054de <vprintfmt+0x1d0>
					putch('?', putdat);
f0105518:	83 ec 08             	sub    $0x8,%esp
f010551b:	56                   	push   %esi
f010551c:	6a 3f                	push   $0x3f
f010551e:	ff d3                	call   *%ebx
f0105520:	83 c4 10             	add    $0x10,%esp
f0105523:	eb c3                	jmp    f01054e8 <vprintfmt+0x1da>
f0105525:	89 cf                	mov    %ecx,%edi
f0105527:	eb 0e                	jmp    f0105537 <vprintfmt+0x229>
				putch(' ', putdat);
f0105529:	83 ec 08             	sub    $0x8,%esp
f010552c:	56                   	push   %esi
f010552d:	6a 20                	push   $0x20
f010552f:	ff d3                	call   *%ebx
			for (; width > 0; width--)
f0105531:	83 ef 01             	sub    $0x1,%edi
f0105534:	83 c4 10             	add    $0x10,%esp
f0105537:	85 ff                	test   %edi,%edi
f0105539:	7f ee                	jg     f0105529 <vprintfmt+0x21b>
f010553b:	eb 6f                	jmp    f01055ac <vprintfmt+0x29e>
f010553d:	89 cf                	mov    %ecx,%edi
f010553f:	eb f6                	jmp    f0105537 <vprintfmt+0x229>
			num = getint(&ap, lflag);
f0105541:	89 ca                	mov    %ecx,%edx
f0105543:	8d 45 14             	lea    0x14(%ebp),%eax
f0105546:	e8 55 fd ff ff       	call   f01052a0 <getint>
f010554b:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010554e:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
f0105551:	85 d2                	test   %edx,%edx
f0105553:	78 0b                	js     f0105560 <vprintfmt+0x252>
			num = getint(&ap, lflag);
f0105555:	89 d1                	mov    %edx,%ecx
f0105557:	89 c2                	mov    %eax,%edx
			base = 10;
f0105559:	b8 0a 00 00 00       	mov    $0xa,%eax
f010555e:	eb 32                	jmp    f0105592 <vprintfmt+0x284>
				putch('-', putdat);
f0105560:	83 ec 08             	sub    $0x8,%esp
f0105563:	56                   	push   %esi
f0105564:	6a 2d                	push   $0x2d
f0105566:	ff d3                	call   *%ebx
				num = -(long long) num;
f0105568:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010556b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f010556e:	f7 da                	neg    %edx
f0105570:	83 d1 00             	adc    $0x0,%ecx
f0105573:	f7 d9                	neg    %ecx
f0105575:	83 c4 10             	add    $0x10,%esp
			base = 10;
f0105578:	b8 0a 00 00 00       	mov    $0xa,%eax
f010557d:	eb 13                	jmp    f0105592 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
f010557f:	89 ca                	mov    %ecx,%edx
f0105581:	8d 45 14             	lea    0x14(%ebp),%eax
f0105584:	e8 e3 fc ff ff       	call   f010526c <getuint>
f0105589:	89 d1                	mov    %edx,%ecx
f010558b:	89 c2                	mov    %eax,%edx
			base = 10;
f010558d:	b8 0a 00 00 00       	mov    $0xa,%eax
			printnum(putch, putdat, num, base, width, padc);
f0105592:	83 ec 0c             	sub    $0xc,%esp
f0105595:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
f0105599:	57                   	push   %edi
f010559a:	ff 75 e0             	pushl  -0x20(%ebp)
f010559d:	50                   	push   %eax
f010559e:	51                   	push   %ecx
f010559f:	52                   	push   %edx
f01055a0:	89 f2                	mov    %esi,%edx
f01055a2:	89 d8                	mov    %ebx,%eax
f01055a4:	e8 1a fc ff ff       	call   f01051c3 <printnum>
			break;
f01055a9:	83 c4 20             	add    $0x20,%esp
{
f01055ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01055af:	83 c7 01             	add    $0x1,%edi
f01055b2:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f01055b6:	83 f8 25             	cmp    $0x25,%eax
f01055b9:	0f 84 6a fd ff ff    	je     f0105329 <vprintfmt+0x1b>
			if (ch == '\0')
f01055bf:	85 c0                	test   %eax,%eax
f01055c1:	0f 84 93 00 00 00    	je     f010565a <vprintfmt+0x34c>
			putch(ch, putdat);
f01055c7:	83 ec 08             	sub    $0x8,%esp
f01055ca:	56                   	push   %esi
f01055cb:	50                   	push   %eax
f01055cc:	ff d3                	call   *%ebx
f01055ce:	83 c4 10             	add    $0x10,%esp
f01055d1:	eb dc                	jmp    f01055af <vprintfmt+0x2a1>
			num = getuint(&ap, lflag);
f01055d3:	89 ca                	mov    %ecx,%edx
f01055d5:	8d 45 14             	lea    0x14(%ebp),%eax
f01055d8:	e8 8f fc ff ff       	call   f010526c <getuint>
f01055dd:	89 d1                	mov    %edx,%ecx
f01055df:	89 c2                	mov    %eax,%edx
			base = 8;
f01055e1:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
f01055e6:	eb aa                	jmp    f0105592 <vprintfmt+0x284>
			putch('0', putdat);
f01055e8:	83 ec 08             	sub    $0x8,%esp
f01055eb:	56                   	push   %esi
f01055ec:	6a 30                	push   $0x30
f01055ee:	ff d3                	call   *%ebx
			putch('x', putdat);
f01055f0:	83 c4 08             	add    $0x8,%esp
f01055f3:	56                   	push   %esi
f01055f4:	6a 78                	push   $0x78
f01055f6:	ff d3                	call   *%ebx
				(uintptr_t) va_arg(ap, void *);
f01055f8:	8b 45 14             	mov    0x14(%ebp),%eax
f01055fb:	8d 50 04             	lea    0x4(%eax),%edx
f01055fe:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
f0105601:	8b 10                	mov    (%eax),%edx
f0105603:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f0105608:	83 c4 10             	add    $0x10,%esp
			base = 16;
f010560b:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f0105610:	eb 80                	jmp    f0105592 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
f0105612:	89 ca                	mov    %ecx,%edx
f0105614:	8d 45 14             	lea    0x14(%ebp),%eax
f0105617:	e8 50 fc ff ff       	call   f010526c <getuint>
f010561c:	89 d1                	mov    %edx,%ecx
f010561e:	89 c2                	mov    %eax,%edx
			base = 16;
f0105620:	b8 10 00 00 00       	mov    $0x10,%eax
f0105625:	e9 68 ff ff ff       	jmp    f0105592 <vprintfmt+0x284>
			putch(ch, putdat);
f010562a:	83 ec 08             	sub    $0x8,%esp
f010562d:	56                   	push   %esi
f010562e:	6a 25                	push   $0x25
f0105630:	ff d3                	call   *%ebx
			break;
f0105632:	83 c4 10             	add    $0x10,%esp
f0105635:	e9 72 ff ff ff       	jmp    f01055ac <vprintfmt+0x29e>
			putch('%', putdat);
f010563a:	83 ec 08             	sub    $0x8,%esp
f010563d:	56                   	push   %esi
f010563e:	6a 25                	push   $0x25
f0105640:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
f0105642:	83 c4 10             	add    $0x10,%esp
f0105645:	89 f8                	mov    %edi,%eax
f0105647:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f010564b:	74 05                	je     f0105652 <vprintfmt+0x344>
f010564d:	83 e8 01             	sub    $0x1,%eax
f0105650:	eb f5                	jmp    f0105647 <vprintfmt+0x339>
f0105652:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105655:	e9 52 ff ff ff       	jmp    f01055ac <vprintfmt+0x29e>
}
f010565a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010565d:	5b                   	pop    %ebx
f010565e:	5e                   	pop    %esi
f010565f:	5f                   	pop    %edi
f0105660:	5d                   	pop    %ebp
f0105661:	c3                   	ret    

f0105662 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0105662:	f3 0f 1e fb          	endbr32 
f0105666:	55                   	push   %ebp
f0105667:	89 e5                	mov    %esp,%ebp
f0105669:	83 ec 18             	sub    $0x18,%esp
f010566c:	8b 45 08             	mov    0x8(%ebp),%eax
f010566f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0105672:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105675:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0105679:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f010567c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0105683:	85 c0                	test   %eax,%eax
f0105685:	74 26                	je     f01056ad <vsnprintf+0x4b>
f0105687:	85 d2                	test   %edx,%edx
f0105689:	7e 22                	jle    f01056ad <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f010568b:	ff 75 14             	pushl  0x14(%ebp)
f010568e:	ff 75 10             	pushl  0x10(%ebp)
f0105691:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0105694:	50                   	push   %eax
f0105695:	68 cc 52 10 f0       	push   $0xf01052cc
f010569a:	e8 6f fc ff ff       	call   f010530e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f010569f:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01056a2:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01056a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01056a8:	83 c4 10             	add    $0x10,%esp
}
f01056ab:	c9                   	leave  
f01056ac:	c3                   	ret    
		return -E_INVAL;
f01056ad:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01056b2:	eb f7                	jmp    f01056ab <vsnprintf+0x49>

f01056b4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01056b4:	f3 0f 1e fb          	endbr32 
f01056b8:	55                   	push   %ebp
f01056b9:	89 e5                	mov    %esp,%ebp
f01056bb:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01056be:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01056c1:	50                   	push   %eax
f01056c2:	ff 75 10             	pushl  0x10(%ebp)
f01056c5:	ff 75 0c             	pushl  0xc(%ebp)
f01056c8:	ff 75 08             	pushl  0x8(%ebp)
f01056cb:	e8 92 ff ff ff       	call   f0105662 <vsnprintf>
	va_end(ap);

	return rc;
}
f01056d0:	c9                   	leave  
f01056d1:	c3                   	ret    

f01056d2 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01056d2:	f3 0f 1e fb          	endbr32 
f01056d6:	55                   	push   %ebp
f01056d7:	89 e5                	mov    %esp,%ebp
f01056d9:	57                   	push   %edi
f01056da:	56                   	push   %esi
f01056db:	53                   	push   %ebx
f01056dc:	83 ec 0c             	sub    $0xc,%esp
f01056df:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01056e2:	85 c0                	test   %eax,%eax
f01056e4:	74 11                	je     f01056f7 <readline+0x25>
		cprintf("%s", prompt);
f01056e6:	83 ec 08             	sub    $0x8,%esp
f01056e9:	50                   	push   %eax
f01056ea:	68 55 76 10 f0       	push   $0xf0107655
f01056ef:	e8 39 e2 ff ff       	call   f010392d <cprintf>
f01056f4:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f01056f7:	83 ec 0c             	sub    $0xc,%esp
f01056fa:	6a 00                	push   $0x0
f01056fc:	e8 2f b2 ff ff       	call   f0100930 <iscons>
f0105701:	89 c7                	mov    %eax,%edi
f0105703:	83 c4 10             	add    $0x10,%esp
	i = 0;
f0105706:	be 00 00 00 00       	mov    $0x0,%esi
f010570b:	eb 4b                	jmp    f0105758 <readline+0x86>
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
f010570d:	83 ec 08             	sub    $0x8,%esp
f0105710:	50                   	push   %eax
f0105711:	68 24 81 10 f0       	push   $0xf0108124
f0105716:	e8 12 e2 ff ff       	call   f010392d <cprintf>
			return NULL;
f010571b:	83 c4 10             	add    $0x10,%esp
f010571e:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f0105723:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105726:	5b                   	pop    %ebx
f0105727:	5e                   	pop    %esi
f0105728:	5f                   	pop    %edi
f0105729:	5d                   	pop    %ebp
f010572a:	c3                   	ret    
			if (echoing)
f010572b:	85 ff                	test   %edi,%edi
f010572d:	75 05                	jne    f0105734 <readline+0x62>
			i--;
f010572f:	83 ee 01             	sub    $0x1,%esi
f0105732:	eb 24                	jmp    f0105758 <readline+0x86>
				cputchar('\b');
f0105734:	83 ec 0c             	sub    $0xc,%esp
f0105737:	6a 08                	push   $0x8
f0105739:	e8 c9 b1 ff ff       	call   f0100907 <cputchar>
f010573e:	83 c4 10             	add    $0x10,%esp
f0105741:	eb ec                	jmp    f010572f <readline+0x5d>
				cputchar(c);
f0105743:	83 ec 0c             	sub    $0xc,%esp
f0105746:	53                   	push   %ebx
f0105747:	e8 bb b1 ff ff       	call   f0100907 <cputchar>
f010574c:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f010574f:	88 9e 80 ea 24 f0    	mov    %bl,-0xfdb1580(%esi)
f0105755:	8d 76 01             	lea    0x1(%esi),%esi
		c = getchar();
f0105758:	e8 be b1 ff ff       	call   f010091b <getchar>
f010575d:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010575f:	85 c0                	test   %eax,%eax
f0105761:	78 aa                	js     f010570d <readline+0x3b>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0105763:	83 f8 08             	cmp    $0x8,%eax
f0105766:	0f 94 c2             	sete   %dl
f0105769:	83 f8 7f             	cmp    $0x7f,%eax
f010576c:	0f 94 c0             	sete   %al
f010576f:	08 c2                	or     %al,%dl
f0105771:	74 04                	je     f0105777 <readline+0xa5>
f0105773:	85 f6                	test   %esi,%esi
f0105775:	7f b4                	jg     f010572b <readline+0x59>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0105777:	83 fb 1f             	cmp    $0x1f,%ebx
f010577a:	7e 0e                	jle    f010578a <readline+0xb8>
f010577c:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0105782:	7f 06                	jg     f010578a <readline+0xb8>
			if (echoing)
f0105784:	85 ff                	test   %edi,%edi
f0105786:	74 c7                	je     f010574f <readline+0x7d>
f0105788:	eb b9                	jmp    f0105743 <readline+0x71>
		} else if (c == '\n' || c == '\r') {
f010578a:	83 fb 0a             	cmp    $0xa,%ebx
f010578d:	74 05                	je     f0105794 <readline+0xc2>
f010578f:	83 fb 0d             	cmp    $0xd,%ebx
f0105792:	75 c4                	jne    f0105758 <readline+0x86>
			if (echoing)
f0105794:	85 ff                	test   %edi,%edi
f0105796:	75 11                	jne    f01057a9 <readline+0xd7>
			buf[i] = 0;
f0105798:	c6 86 80 ea 24 f0 00 	movb   $0x0,-0xfdb1580(%esi)
			return buf;
f010579f:	b8 80 ea 24 f0       	mov    $0xf024ea80,%eax
f01057a4:	e9 7a ff ff ff       	jmp    f0105723 <readline+0x51>
				cputchar('\n');
f01057a9:	83 ec 0c             	sub    $0xc,%esp
f01057ac:	6a 0a                	push   $0xa
f01057ae:	e8 54 b1 ff ff       	call   f0100907 <cputchar>
f01057b3:	83 c4 10             	add    $0x10,%esp
f01057b6:	eb e0                	jmp    f0105798 <readline+0xc6>

f01057b8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01057b8:	f3 0f 1e fb          	endbr32 
f01057bc:	55                   	push   %ebp
f01057bd:	89 e5                	mov    %esp,%ebp
f01057bf:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01057c2:	b8 00 00 00 00       	mov    $0x0,%eax
f01057c7:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01057cb:	74 05                	je     f01057d2 <strlen+0x1a>
		n++;
f01057cd:	83 c0 01             	add    $0x1,%eax
f01057d0:	eb f5                	jmp    f01057c7 <strlen+0xf>
	return n;
}
f01057d2:	5d                   	pop    %ebp
f01057d3:	c3                   	ret    

f01057d4 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01057d4:	f3 0f 1e fb          	endbr32 
f01057d8:	55                   	push   %ebp
f01057d9:	89 e5                	mov    %esp,%ebp
f01057db:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01057de:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01057e1:	b8 00 00 00 00       	mov    $0x0,%eax
f01057e6:	39 d0                	cmp    %edx,%eax
f01057e8:	74 0d                	je     f01057f7 <strnlen+0x23>
f01057ea:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f01057ee:	74 05                	je     f01057f5 <strnlen+0x21>
		n++;
f01057f0:	83 c0 01             	add    $0x1,%eax
f01057f3:	eb f1                	jmp    f01057e6 <strnlen+0x12>
f01057f5:	89 c2                	mov    %eax,%edx
	return n;
}
f01057f7:	89 d0                	mov    %edx,%eax
f01057f9:	5d                   	pop    %ebp
f01057fa:	c3                   	ret    

f01057fb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01057fb:	f3 0f 1e fb          	endbr32 
f01057ff:	55                   	push   %ebp
f0105800:	89 e5                	mov    %esp,%ebp
f0105802:	53                   	push   %ebx
f0105803:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105806:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0105809:	b8 00 00 00 00       	mov    $0x0,%eax
f010580e:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
f0105812:	88 14 01             	mov    %dl,(%ecx,%eax,1)
f0105815:	83 c0 01             	add    $0x1,%eax
f0105818:	84 d2                	test   %dl,%dl
f010581a:	75 f2                	jne    f010580e <strcpy+0x13>
		/* do nothing */;
	return ret;
}
f010581c:	89 c8                	mov    %ecx,%eax
f010581e:	5b                   	pop    %ebx
f010581f:	5d                   	pop    %ebp
f0105820:	c3                   	ret    

f0105821 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0105821:	f3 0f 1e fb          	endbr32 
f0105825:	55                   	push   %ebp
f0105826:	89 e5                	mov    %esp,%ebp
f0105828:	53                   	push   %ebx
f0105829:	83 ec 10             	sub    $0x10,%esp
f010582c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f010582f:	53                   	push   %ebx
f0105830:	e8 83 ff ff ff       	call   f01057b8 <strlen>
f0105835:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
f0105838:	ff 75 0c             	pushl  0xc(%ebp)
f010583b:	01 d8                	add    %ebx,%eax
f010583d:	50                   	push   %eax
f010583e:	e8 b8 ff ff ff       	call   f01057fb <strcpy>
	return dst;
}
f0105843:	89 d8                	mov    %ebx,%eax
f0105845:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0105848:	c9                   	leave  
f0105849:	c3                   	ret    

f010584a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f010584a:	f3 0f 1e fb          	endbr32 
f010584e:	55                   	push   %ebp
f010584f:	89 e5                	mov    %esp,%ebp
f0105851:	56                   	push   %esi
f0105852:	53                   	push   %ebx
f0105853:	8b 75 08             	mov    0x8(%ebp),%esi
f0105856:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105859:	89 f3                	mov    %esi,%ebx
f010585b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010585e:	89 f0                	mov    %esi,%eax
f0105860:	39 d8                	cmp    %ebx,%eax
f0105862:	74 11                	je     f0105875 <strncpy+0x2b>
		*dst++ = *src;
f0105864:	83 c0 01             	add    $0x1,%eax
f0105867:	0f b6 0a             	movzbl (%edx),%ecx
f010586a:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f010586d:	80 f9 01             	cmp    $0x1,%cl
f0105870:	83 da ff             	sbb    $0xffffffff,%edx
f0105873:	eb eb                	jmp    f0105860 <strncpy+0x16>
	}
	return ret;
}
f0105875:	89 f0                	mov    %esi,%eax
f0105877:	5b                   	pop    %ebx
f0105878:	5e                   	pop    %esi
f0105879:	5d                   	pop    %ebp
f010587a:	c3                   	ret    

f010587b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f010587b:	f3 0f 1e fb          	endbr32 
f010587f:	55                   	push   %ebp
f0105880:	89 e5                	mov    %esp,%ebp
f0105882:	56                   	push   %esi
f0105883:	53                   	push   %ebx
f0105884:	8b 75 08             	mov    0x8(%ebp),%esi
f0105887:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010588a:	8b 55 10             	mov    0x10(%ebp),%edx
f010588d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f010588f:	85 d2                	test   %edx,%edx
f0105891:	74 21                	je     f01058b4 <strlcpy+0x39>
f0105893:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0105897:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
f0105899:	39 c2                	cmp    %eax,%edx
f010589b:	74 14                	je     f01058b1 <strlcpy+0x36>
f010589d:	0f b6 19             	movzbl (%ecx),%ebx
f01058a0:	84 db                	test   %bl,%bl
f01058a2:	74 0b                	je     f01058af <strlcpy+0x34>
			*dst++ = *src++;
f01058a4:	83 c1 01             	add    $0x1,%ecx
f01058a7:	83 c2 01             	add    $0x1,%edx
f01058aa:	88 5a ff             	mov    %bl,-0x1(%edx)
f01058ad:	eb ea                	jmp    f0105899 <strlcpy+0x1e>
f01058af:	89 d0                	mov    %edx,%eax
		*dst = '\0';
f01058b1:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f01058b4:	29 f0                	sub    %esi,%eax
}
f01058b6:	5b                   	pop    %ebx
f01058b7:	5e                   	pop    %esi
f01058b8:	5d                   	pop    %ebp
f01058b9:	c3                   	ret    

f01058ba <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01058ba:	f3 0f 1e fb          	endbr32 
f01058be:	55                   	push   %ebp
f01058bf:	89 e5                	mov    %esp,%ebp
f01058c1:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01058c4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01058c7:	0f b6 01             	movzbl (%ecx),%eax
f01058ca:	84 c0                	test   %al,%al
f01058cc:	74 0c                	je     f01058da <strcmp+0x20>
f01058ce:	3a 02                	cmp    (%edx),%al
f01058d0:	75 08                	jne    f01058da <strcmp+0x20>
		p++, q++;
f01058d2:	83 c1 01             	add    $0x1,%ecx
f01058d5:	83 c2 01             	add    $0x1,%edx
f01058d8:	eb ed                	jmp    f01058c7 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01058da:	0f b6 c0             	movzbl %al,%eax
f01058dd:	0f b6 12             	movzbl (%edx),%edx
f01058e0:	29 d0                	sub    %edx,%eax
}
f01058e2:	5d                   	pop    %ebp
f01058e3:	c3                   	ret    

f01058e4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01058e4:	f3 0f 1e fb          	endbr32 
f01058e8:	55                   	push   %ebp
f01058e9:	89 e5                	mov    %esp,%ebp
f01058eb:	53                   	push   %ebx
f01058ec:	8b 45 08             	mov    0x8(%ebp),%eax
f01058ef:	8b 55 0c             	mov    0xc(%ebp),%edx
f01058f2:	89 c3                	mov    %eax,%ebx
f01058f4:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f01058f7:	eb 06                	jmp    f01058ff <strncmp+0x1b>
		n--, p++, q++;
f01058f9:	83 c0 01             	add    $0x1,%eax
f01058fc:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f01058ff:	39 d8                	cmp    %ebx,%eax
f0105901:	74 16                	je     f0105919 <strncmp+0x35>
f0105903:	0f b6 08             	movzbl (%eax),%ecx
f0105906:	84 c9                	test   %cl,%cl
f0105908:	74 04                	je     f010590e <strncmp+0x2a>
f010590a:	3a 0a                	cmp    (%edx),%cl
f010590c:	74 eb                	je     f01058f9 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f010590e:	0f b6 00             	movzbl (%eax),%eax
f0105911:	0f b6 12             	movzbl (%edx),%edx
f0105914:	29 d0                	sub    %edx,%eax
}
f0105916:	5b                   	pop    %ebx
f0105917:	5d                   	pop    %ebp
f0105918:	c3                   	ret    
		return 0;
f0105919:	b8 00 00 00 00       	mov    $0x0,%eax
f010591e:	eb f6                	jmp    f0105916 <strncmp+0x32>

f0105920 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0105920:	f3 0f 1e fb          	endbr32 
f0105924:	55                   	push   %ebp
f0105925:	89 e5                	mov    %esp,%ebp
f0105927:	8b 45 08             	mov    0x8(%ebp),%eax
f010592a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f010592e:	0f b6 10             	movzbl (%eax),%edx
f0105931:	84 d2                	test   %dl,%dl
f0105933:	74 09                	je     f010593e <strchr+0x1e>
		if (*s == c)
f0105935:	38 ca                	cmp    %cl,%dl
f0105937:	74 0a                	je     f0105943 <strchr+0x23>
	for (; *s; s++)
f0105939:	83 c0 01             	add    $0x1,%eax
f010593c:	eb f0                	jmp    f010592e <strchr+0xe>
			return (char *) s;
	return 0;
f010593e:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105943:	5d                   	pop    %ebp
f0105944:	c3                   	ret    

f0105945 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0105945:	f3 0f 1e fb          	endbr32 
f0105949:	55                   	push   %ebp
f010594a:	89 e5                	mov    %esp,%ebp
f010594c:	8b 45 08             	mov    0x8(%ebp),%eax
f010594f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105953:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0105956:	38 ca                	cmp    %cl,%dl
f0105958:	74 09                	je     f0105963 <strfind+0x1e>
f010595a:	84 d2                	test   %dl,%dl
f010595c:	74 05                	je     f0105963 <strfind+0x1e>
	for (; *s; s++)
f010595e:	83 c0 01             	add    $0x1,%eax
f0105961:	eb f0                	jmp    f0105953 <strfind+0xe>
			break;
	return (char *) s;
}
f0105963:	5d                   	pop    %ebp
f0105964:	c3                   	ret    

f0105965 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0105965:	f3 0f 1e fb          	endbr32 
f0105969:	55                   	push   %ebp
f010596a:	89 e5                	mov    %esp,%ebp
f010596c:	57                   	push   %edi
f010596d:	56                   	push   %esi
f010596e:	53                   	push   %ebx
f010596f:	8b 55 08             	mov    0x8(%ebp),%edx
f0105972:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
f0105975:	85 c9                	test   %ecx,%ecx
f0105977:	74 33                	je     f01059ac <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0105979:	89 d0                	mov    %edx,%eax
f010597b:	09 c8                	or     %ecx,%eax
f010597d:	a8 03                	test   $0x3,%al
f010597f:	75 23                	jne    f01059a4 <memset+0x3f>
		c &= 0xFF;
f0105981:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0105985:	89 d8                	mov    %ebx,%eax
f0105987:	c1 e0 08             	shl    $0x8,%eax
f010598a:	89 df                	mov    %ebx,%edi
f010598c:	c1 e7 18             	shl    $0x18,%edi
f010598f:	89 de                	mov    %ebx,%esi
f0105991:	c1 e6 10             	shl    $0x10,%esi
f0105994:	09 f7                	or     %esi,%edi
f0105996:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
f0105998:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f010599b:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
f010599d:	89 d7                	mov    %edx,%edi
f010599f:	fc                   	cld    
f01059a0:	f3 ab                	rep stos %eax,%es:(%edi)
f01059a2:	eb 08                	jmp    f01059ac <memset+0x47>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01059a4:	89 d7                	mov    %edx,%edi
f01059a6:	8b 45 0c             	mov    0xc(%ebp),%eax
f01059a9:	fc                   	cld    
f01059aa:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
f01059ac:	89 d0                	mov    %edx,%eax
f01059ae:	5b                   	pop    %ebx
f01059af:	5e                   	pop    %esi
f01059b0:	5f                   	pop    %edi
f01059b1:	5d                   	pop    %ebp
f01059b2:	c3                   	ret    

f01059b3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01059b3:	f3 0f 1e fb          	endbr32 
f01059b7:	55                   	push   %ebp
f01059b8:	89 e5                	mov    %esp,%ebp
f01059ba:	57                   	push   %edi
f01059bb:	56                   	push   %esi
f01059bc:	8b 45 08             	mov    0x8(%ebp),%eax
f01059bf:	8b 75 0c             	mov    0xc(%ebp),%esi
f01059c2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01059c5:	39 c6                	cmp    %eax,%esi
f01059c7:	73 32                	jae    f01059fb <memmove+0x48>
f01059c9:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01059cc:	39 c2                	cmp    %eax,%edx
f01059ce:	76 2b                	jbe    f01059fb <memmove+0x48>
		s += n;
		d += n;
f01059d0:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01059d3:	89 fe                	mov    %edi,%esi
f01059d5:	09 ce                	or     %ecx,%esi
f01059d7:	09 d6                	or     %edx,%esi
f01059d9:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01059df:	75 0e                	jne    f01059ef <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f01059e1:	83 ef 04             	sub    $0x4,%edi
f01059e4:	8d 72 fc             	lea    -0x4(%edx),%esi
f01059e7:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f01059ea:	fd                   	std    
f01059eb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01059ed:	eb 09                	jmp    f01059f8 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f01059ef:	83 ef 01             	sub    $0x1,%edi
f01059f2:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f01059f5:	fd                   	std    
f01059f6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01059f8:	fc                   	cld    
f01059f9:	eb 1a                	jmp    f0105a15 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01059fb:	89 c2                	mov    %eax,%edx
f01059fd:	09 ca                	or     %ecx,%edx
f01059ff:	09 f2                	or     %esi,%edx
f0105a01:	f6 c2 03             	test   $0x3,%dl
f0105a04:	75 0a                	jne    f0105a10 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0105a06:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f0105a09:	89 c7                	mov    %eax,%edi
f0105a0b:	fc                   	cld    
f0105a0c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105a0e:	eb 05                	jmp    f0105a15 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
f0105a10:	89 c7                	mov    %eax,%edi
f0105a12:	fc                   	cld    
f0105a13:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0105a15:	5e                   	pop    %esi
f0105a16:	5f                   	pop    %edi
f0105a17:	5d                   	pop    %ebp
f0105a18:	c3                   	ret    

f0105a19 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0105a19:	f3 0f 1e fb          	endbr32 
f0105a1d:	55                   	push   %ebp
f0105a1e:	89 e5                	mov    %esp,%ebp
f0105a20:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0105a23:	ff 75 10             	pushl  0x10(%ebp)
f0105a26:	ff 75 0c             	pushl  0xc(%ebp)
f0105a29:	ff 75 08             	pushl  0x8(%ebp)
f0105a2c:	e8 82 ff ff ff       	call   f01059b3 <memmove>
}
f0105a31:	c9                   	leave  
f0105a32:	c3                   	ret    

f0105a33 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0105a33:	f3 0f 1e fb          	endbr32 
f0105a37:	55                   	push   %ebp
f0105a38:	89 e5                	mov    %esp,%ebp
f0105a3a:	56                   	push   %esi
f0105a3b:	53                   	push   %ebx
f0105a3c:	8b 45 08             	mov    0x8(%ebp),%eax
f0105a3f:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105a42:	89 c6                	mov    %eax,%esi
f0105a44:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105a47:	39 f0                	cmp    %esi,%eax
f0105a49:	74 1c                	je     f0105a67 <memcmp+0x34>
		if (*s1 != *s2)
f0105a4b:	0f b6 08             	movzbl (%eax),%ecx
f0105a4e:	0f b6 1a             	movzbl (%edx),%ebx
f0105a51:	38 d9                	cmp    %bl,%cl
f0105a53:	75 08                	jne    f0105a5d <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f0105a55:	83 c0 01             	add    $0x1,%eax
f0105a58:	83 c2 01             	add    $0x1,%edx
f0105a5b:	eb ea                	jmp    f0105a47 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
f0105a5d:	0f b6 c1             	movzbl %cl,%eax
f0105a60:	0f b6 db             	movzbl %bl,%ebx
f0105a63:	29 d8                	sub    %ebx,%eax
f0105a65:	eb 05                	jmp    f0105a6c <memcmp+0x39>
	}

	return 0;
f0105a67:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105a6c:	5b                   	pop    %ebx
f0105a6d:	5e                   	pop    %esi
f0105a6e:	5d                   	pop    %ebp
f0105a6f:	c3                   	ret    

f0105a70 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0105a70:	f3 0f 1e fb          	endbr32 
f0105a74:	55                   	push   %ebp
f0105a75:	89 e5                	mov    %esp,%ebp
f0105a77:	8b 45 08             	mov    0x8(%ebp),%eax
f0105a7a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0105a7d:	89 c2                	mov    %eax,%edx
f0105a7f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0105a82:	39 d0                	cmp    %edx,%eax
f0105a84:	73 09                	jae    f0105a8f <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
f0105a86:	38 08                	cmp    %cl,(%eax)
f0105a88:	74 05                	je     f0105a8f <memfind+0x1f>
	for (; s < ends; s++)
f0105a8a:	83 c0 01             	add    $0x1,%eax
f0105a8d:	eb f3                	jmp    f0105a82 <memfind+0x12>
			break;
	return (void *) s;
}
f0105a8f:	5d                   	pop    %ebp
f0105a90:	c3                   	ret    

f0105a91 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0105a91:	f3 0f 1e fb          	endbr32 
f0105a95:	55                   	push   %ebp
f0105a96:	89 e5                	mov    %esp,%ebp
f0105a98:	57                   	push   %edi
f0105a99:	56                   	push   %esi
f0105a9a:	53                   	push   %ebx
f0105a9b:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105a9e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105aa1:	eb 03                	jmp    f0105aa6 <strtol+0x15>
		s++;
f0105aa3:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
f0105aa6:	0f b6 01             	movzbl (%ecx),%eax
f0105aa9:	3c 20                	cmp    $0x20,%al
f0105aab:	74 f6                	je     f0105aa3 <strtol+0x12>
f0105aad:	3c 09                	cmp    $0x9,%al
f0105aaf:	74 f2                	je     f0105aa3 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
f0105ab1:	3c 2b                	cmp    $0x2b,%al
f0105ab3:	74 2a                	je     f0105adf <strtol+0x4e>
	int neg = 0;
f0105ab5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f0105aba:	3c 2d                	cmp    $0x2d,%al
f0105abc:	74 2b                	je     f0105ae9 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105abe:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0105ac4:	75 0f                	jne    f0105ad5 <strtol+0x44>
f0105ac6:	80 39 30             	cmpb   $0x30,(%ecx)
f0105ac9:	74 28                	je     f0105af3 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0105acb:	85 db                	test   %ebx,%ebx
f0105acd:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105ad2:	0f 44 d8             	cmove  %eax,%ebx
f0105ad5:	b8 00 00 00 00       	mov    $0x0,%eax
f0105ada:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0105add:	eb 46                	jmp    f0105b25 <strtol+0x94>
		s++;
f0105adf:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
f0105ae2:	bf 00 00 00 00       	mov    $0x0,%edi
f0105ae7:	eb d5                	jmp    f0105abe <strtol+0x2d>
		s++, neg = 1;
f0105ae9:	83 c1 01             	add    $0x1,%ecx
f0105aec:	bf 01 00 00 00       	mov    $0x1,%edi
f0105af1:	eb cb                	jmp    f0105abe <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105af3:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0105af7:	74 0e                	je     f0105b07 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
f0105af9:	85 db                	test   %ebx,%ebx
f0105afb:	75 d8                	jne    f0105ad5 <strtol+0x44>
		s++, base = 8;
f0105afd:	83 c1 01             	add    $0x1,%ecx
f0105b00:	bb 08 00 00 00       	mov    $0x8,%ebx
f0105b05:	eb ce                	jmp    f0105ad5 <strtol+0x44>
		s += 2, base = 16;
f0105b07:	83 c1 02             	add    $0x2,%ecx
f0105b0a:	bb 10 00 00 00       	mov    $0x10,%ebx
f0105b0f:	eb c4                	jmp    f0105ad5 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
f0105b11:	0f be d2             	movsbl %dl,%edx
f0105b14:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0105b17:	3b 55 10             	cmp    0x10(%ebp),%edx
f0105b1a:	7d 3a                	jge    f0105b56 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
f0105b1c:	83 c1 01             	add    $0x1,%ecx
f0105b1f:	0f af 45 10          	imul   0x10(%ebp),%eax
f0105b23:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f0105b25:	0f b6 11             	movzbl (%ecx),%edx
f0105b28:	8d 72 d0             	lea    -0x30(%edx),%esi
f0105b2b:	89 f3                	mov    %esi,%ebx
f0105b2d:	80 fb 09             	cmp    $0x9,%bl
f0105b30:	76 df                	jbe    f0105b11 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
f0105b32:	8d 72 9f             	lea    -0x61(%edx),%esi
f0105b35:	89 f3                	mov    %esi,%ebx
f0105b37:	80 fb 19             	cmp    $0x19,%bl
f0105b3a:	77 08                	ja     f0105b44 <strtol+0xb3>
			dig = *s - 'a' + 10;
f0105b3c:	0f be d2             	movsbl %dl,%edx
f0105b3f:	83 ea 57             	sub    $0x57,%edx
f0105b42:	eb d3                	jmp    f0105b17 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
f0105b44:	8d 72 bf             	lea    -0x41(%edx),%esi
f0105b47:	89 f3                	mov    %esi,%ebx
f0105b49:	80 fb 19             	cmp    $0x19,%bl
f0105b4c:	77 08                	ja     f0105b56 <strtol+0xc5>
			dig = *s - 'A' + 10;
f0105b4e:	0f be d2             	movsbl %dl,%edx
f0105b51:	83 ea 37             	sub    $0x37,%edx
f0105b54:	eb c1                	jmp    f0105b17 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
f0105b56:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0105b5a:	74 05                	je     f0105b61 <strtol+0xd0>
		*endptr = (char *) s;
f0105b5c:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105b5f:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f0105b61:	89 c2                	mov    %eax,%edx
f0105b63:	f7 da                	neg    %edx
f0105b65:	85 ff                	test   %edi,%edi
f0105b67:	0f 45 c2             	cmovne %edx,%eax
}
f0105b6a:	5b                   	pop    %ebx
f0105b6b:	5e                   	pop    %esi
f0105b6c:	5f                   	pop    %edi
f0105b6d:	5d                   	pop    %ebp
f0105b6e:	c3                   	ret    
f0105b6f:	90                   	nop

f0105b70 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16
.globl mpentry_start
mpentry_start:
	cli
f0105b70:	fa                   	cli    

	xorw    %ax, %ax
f0105b71:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f0105b73:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105b75:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105b77:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0105b79:	0f 01 16             	lgdtl  (%esi)
f0105b7c:	7c 70                	jl     f0105bee <gdtdesc+0x2>
	movl    %cr0, %eax
f0105b7e:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0105b81:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0105b85:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0105b88:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0105b8e:	08 00                	or     %al,(%eax)

f0105b90 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0105b90:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0105b94:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105b96:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105b98:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0105b9a:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0105b9e:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0105ba0:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0105ba2:	b8 00 20 12 00       	mov    $0x122000,%eax
	movl    %eax, %cr3
f0105ba7:	0f 22 d8             	mov    %eax,%cr3

	# Turn on large pages.
	movl	%cr4, %eax
f0105baa:	0f 20 e0             	mov    %cr4,%eax
	orl	$(CR4_PSE), %eax
f0105bad:	83 c8 10             	or     $0x10,%eax
	movl	%eax, %cr4
f0105bb0:	0f 22 e0             	mov    %eax,%cr4

	# Turn on paging.
	movl    %cr0, %eax
f0105bb3:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0105bb6:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0105bbb:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0105bbe:	8b 25 84 fe 24 f0    	mov    0xf024fe84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0105bc4:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0105bc9:	b8 3e 02 10 f0       	mov    $0xf010023e,%eax
	call    *%eax
f0105bce:	ff d0                	call   *%eax

f0105bd0 <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0105bd0:	eb fe                	jmp    f0105bd0 <spin>
f0105bd2:	66 90                	xchg   %ax,%ax

f0105bd4 <gdt>:
	...
f0105bdc:	ff                   	(bad)  
f0105bdd:	ff 00                	incl   (%eax)
f0105bdf:	00 00                	add    %al,(%eax)
f0105be1:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0105be8:	00                   	.byte 0x0
f0105be9:	92                   	xchg   %eax,%edx
f0105bea:	cf                   	iret   
	...

f0105bec <gdtdesc>:
f0105bec:	17                   	pop    %ss
f0105bed:	00 64 70 00          	add    %ah,0x0(%eax,%esi,2)
	...

f0105bf2 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0105bf2:	90                   	nop

f0105bf3 <inb>:
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0105bf3:	89 c2                	mov    %eax,%edx
f0105bf5:	ec                   	in     (%dx),%al
}
f0105bf6:	c3                   	ret    

f0105bf7 <outb>:
{
f0105bf7:	89 c1                	mov    %eax,%ecx
f0105bf9:	89 d0                	mov    %edx,%eax
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105bfb:	89 ca                	mov    %ecx,%edx
f0105bfd:	ee                   	out    %al,(%dx)
}
f0105bfe:	c3                   	ret    

f0105bff <sum>:
#define MPIOINTR  0x03  // One per bus interrupt source
#define MPLINTR   0x04  // One per system interrupt source

static uint8_t
sum(void *addr, int len)
{
f0105bff:	55                   	push   %ebp
f0105c00:	89 e5                	mov    %esp,%ebp
f0105c02:	56                   	push   %esi
f0105c03:	53                   	push   %ebx
f0105c04:	89 c6                	mov    %eax,%esi
	int i, sum;

	sum = 0;
f0105c06:	b8 00 00 00 00       	mov    $0x0,%eax
	for (i = 0; i < len; i++)
f0105c0b:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105c10:	39 d1                	cmp    %edx,%ecx
f0105c12:	7d 0b                	jge    f0105c1f <sum+0x20>
		sum += ((uint8_t *)addr)[i];
f0105c14:	0f b6 1c 0e          	movzbl (%esi,%ecx,1),%ebx
f0105c18:	01 d8                	add    %ebx,%eax
	for (i = 0; i < len; i++)
f0105c1a:	83 c1 01             	add    $0x1,%ecx
f0105c1d:	eb f1                	jmp    f0105c10 <sum+0x11>
	return sum;
}
f0105c1f:	5b                   	pop    %ebx
f0105c20:	5e                   	pop    %esi
f0105c21:	5d                   	pop    %ebp
f0105c22:	c3                   	ret    

f0105c23 <_kaddr>:
{
f0105c23:	55                   	push   %ebp
f0105c24:	89 e5                	mov    %esp,%ebp
f0105c26:	53                   	push   %ebx
f0105c27:	83 ec 04             	sub    $0x4,%esp
	if (PGNUM(pa) >= npages)
f0105c2a:	89 cb                	mov    %ecx,%ebx
f0105c2c:	c1 eb 0c             	shr    $0xc,%ebx
f0105c2f:	3b 1d 88 fe 24 f0    	cmp    0xf024fe88,%ebx
f0105c35:	73 0b                	jae    f0105c42 <_kaddr+0x1f>
	return (void *)(pa + KERNBASE);
f0105c37:	8d 81 00 00 00 f0    	lea    -0x10000000(%ecx),%eax
}
f0105c3d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0105c40:	c9                   	leave  
f0105c41:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105c42:	51                   	push   %ecx
f0105c43:	68 ec 66 10 f0       	push   $0xf01066ec
f0105c48:	52                   	push   %edx
f0105c49:	50                   	push   %eax
f0105c4a:	e8 1b a4 ff ff       	call   f010006a <_panic>

f0105c4f <mpsearch1>:

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0105c4f:	55                   	push   %ebp
f0105c50:	89 e5                	mov    %esp,%ebp
f0105c52:	57                   	push   %edi
f0105c53:	56                   	push   %esi
f0105c54:	53                   	push   %ebx
f0105c55:	83 ec 0c             	sub    $0xc,%esp
f0105c58:	89 c7                	mov    %eax,%edi
f0105c5a:	89 d6                	mov    %edx,%esi
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0105c5c:	89 c1                	mov    %eax,%ecx
f0105c5e:	ba 57 00 00 00       	mov    $0x57,%edx
f0105c63:	b8 c1 82 10 f0       	mov    $0xf01082c1,%eax
f0105c68:	e8 b6 ff ff ff       	call   f0105c23 <_kaddr>
f0105c6d:	89 c3                	mov    %eax,%ebx
f0105c6f:	8d 0c 3e             	lea    (%esi,%edi,1),%ecx
f0105c72:	ba 57 00 00 00       	mov    $0x57,%edx
f0105c77:	b8 c1 82 10 f0       	mov    $0xf01082c1,%eax
f0105c7c:	e8 a2 ff ff ff       	call   f0105c23 <_kaddr>
f0105c81:	89 c6                	mov    %eax,%esi

	for (; mp < end; mp++)
f0105c83:	eb 03                	jmp    f0105c88 <mpsearch1+0x39>
f0105c85:	83 c3 10             	add    $0x10,%ebx
f0105c88:	39 f3                	cmp    %esi,%ebx
f0105c8a:	73 29                	jae    f0105cb5 <mpsearch1+0x66>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105c8c:	83 ec 04             	sub    $0x4,%esp
f0105c8f:	6a 04                	push   $0x4
f0105c91:	68 d1 82 10 f0       	push   $0xf01082d1
f0105c96:	53                   	push   %ebx
f0105c97:	e8 97 fd ff ff       	call   f0105a33 <memcmp>
f0105c9c:	83 c4 10             	add    $0x10,%esp
f0105c9f:	85 c0                	test   %eax,%eax
f0105ca1:	75 e2                	jne    f0105c85 <mpsearch1+0x36>
		    sum(mp, sizeof(*mp)) == 0)
f0105ca3:	ba 10 00 00 00       	mov    $0x10,%edx
f0105ca8:	89 d8                	mov    %ebx,%eax
f0105caa:	e8 50 ff ff ff       	call   f0105bff <sum>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105caf:	84 c0                	test   %al,%al
f0105cb1:	75 d2                	jne    f0105c85 <mpsearch1+0x36>
f0105cb3:	eb 05                	jmp    f0105cba <mpsearch1+0x6b>
			return mp;
	return NULL;
f0105cb5:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f0105cba:	89 d8                	mov    %ebx,%eax
f0105cbc:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105cbf:	5b                   	pop    %ebx
f0105cc0:	5e                   	pop    %esi
f0105cc1:	5f                   	pop    %edi
f0105cc2:	5d                   	pop    %ebp
f0105cc3:	c3                   	ret    

f0105cc4 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) if there is no EBDA, in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp *
mpsearch(void)
{
f0105cc4:	55                   	push   %ebp
f0105cc5:	89 e5                	mov    %esp,%ebp
f0105cc7:	83 ec 08             	sub    $0x8,%esp
	struct mp *mp;

	static_assert(sizeof(*mp) == 16);

	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);
f0105cca:	b9 00 04 00 00       	mov    $0x400,%ecx
f0105ccf:	ba 6f 00 00 00       	mov    $0x6f,%edx
f0105cd4:	b8 c1 82 10 f0       	mov    $0xf01082c1,%eax
f0105cd9:	e8 45 ff ff ff       	call   f0105c23 <_kaddr>

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0105cde:	0f b7 50 0e          	movzwl 0xe(%eax),%edx
f0105ce2:	85 d2                	test   %edx,%edx
f0105ce4:	74 24                	je     f0105d0a <mpsearch+0x46>
		p <<= 4;	// Translate from segment to PA
f0105ce6:	89 d0                	mov    %edx,%eax
f0105ce8:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f0105ceb:	ba 00 04 00 00       	mov    $0x400,%edx
f0105cf0:	e8 5a ff ff ff       	call   f0105c4f <mpsearch1>
f0105cf5:	85 c0                	test   %eax,%eax
f0105cf7:	75 0f                	jne    f0105d08 <mpsearch+0x44>
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
		if ((mp = mpsearch1(p - 1024, 1024)))
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f0105cf9:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105cfe:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0105d03:	e8 47 ff ff ff       	call   f0105c4f <mpsearch1>
}
f0105d08:	c9                   	leave  
f0105d09:	c3                   	ret    
		p = *(uint16_t *) (bda + 0x13) * 1024;
f0105d0a:	0f b7 40 13          	movzwl 0x13(%eax),%eax
f0105d0e:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f0105d11:	2d 00 04 00 00       	sub    $0x400,%eax
f0105d16:	ba 00 04 00 00       	mov    $0x400,%edx
f0105d1b:	e8 2f ff ff ff       	call   f0105c4f <mpsearch1>
f0105d20:	85 c0                	test   %eax,%eax
f0105d22:	75 e4                	jne    f0105d08 <mpsearch+0x44>
f0105d24:	eb d3                	jmp    f0105cf9 <mpsearch+0x35>

f0105d26 <mpconfig>:
// Search for an MP configuration table.  For now, don't accept the
// default configurations (physaddr == 0).
// Check for the correct signature, checksum, and version.
static struct mpconf *
mpconfig(struct mp **pmp)
{
f0105d26:	55                   	push   %ebp
f0105d27:	89 e5                	mov    %esp,%ebp
f0105d29:	57                   	push   %edi
f0105d2a:	56                   	push   %esi
f0105d2b:	53                   	push   %ebx
f0105d2c:	83 ec 1c             	sub    $0x1c,%esp
f0105d2f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f0105d32:	e8 8d ff ff ff       	call   f0105cc4 <mpsearch>
f0105d37:	89 c6                	mov    %eax,%esi
f0105d39:	85 c0                	test   %eax,%eax
f0105d3b:	0f 84 ef 00 00 00    	je     f0105e30 <mpconfig+0x10a>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f0105d41:	8b 48 04             	mov    0x4(%eax),%ecx
f0105d44:	85 c9                	test   %ecx,%ecx
f0105d46:	74 6e                	je     f0105db6 <mpconfig+0x90>
f0105d48:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0105d4c:	75 68                	jne    f0105db6 <mpconfig+0x90>
		cprintf("SMP: Default configurations not implemented\n");
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
f0105d4e:	ba 90 00 00 00       	mov    $0x90,%edx
f0105d53:	b8 c1 82 10 f0       	mov    $0xf01082c1,%eax
f0105d58:	e8 c6 fe ff ff       	call   f0105c23 <_kaddr>
f0105d5d:	89 c3                	mov    %eax,%ebx
	if (memcmp(conf, "PCMP", 4) != 0) {
f0105d5f:	83 ec 04             	sub    $0x4,%esp
f0105d62:	6a 04                	push   $0x4
f0105d64:	68 d6 82 10 f0       	push   $0xf01082d6
f0105d69:	50                   	push   %eax
f0105d6a:	e8 c4 fc ff ff       	call   f0105a33 <memcmp>
f0105d6f:	83 c4 10             	add    $0x10,%esp
f0105d72:	85 c0                	test   %eax,%eax
f0105d74:	75 57                	jne    f0105dcd <mpconfig+0xa7>
		cprintf("SMP: Incorrect MP configuration table signature\n");
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0105d76:	0f b7 7b 04          	movzwl 0x4(%ebx),%edi
f0105d7a:	0f b7 d7             	movzwl %di,%edx
f0105d7d:	89 d8                	mov    %ebx,%eax
f0105d7f:	e8 7b fe ff ff       	call   f0105bff <sum>
f0105d84:	84 c0                	test   %al,%al
f0105d86:	75 5c                	jne    f0105de4 <mpconfig+0xbe>
		cprintf("SMP: Bad MP configuration checksum\n");
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f0105d88:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
f0105d8c:	3c 01                	cmp    $0x1,%al
f0105d8e:	74 04                	je     f0105d94 <mpconfig+0x6e>
f0105d90:	3c 04                	cmp    $0x4,%al
f0105d92:	75 67                	jne    f0105dfb <mpconfig+0xd5>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0105d94:	0f b7 53 28          	movzwl 0x28(%ebx),%edx
f0105d98:	0f b7 c7             	movzwl %di,%eax
f0105d9b:	01 d8                	add    %ebx,%eax
f0105d9d:	e8 5d fe ff ff       	call   f0105bff <sum>
f0105da2:	02 43 2a             	add    0x2a(%ebx),%al
f0105da5:	75 6f                	jne    f0105e16 <mpconfig+0xf0>
		cprintf("SMP: Bad MP configuration extended checksum\n");
		return NULL;
	}
	*pmp = mp;
f0105da7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105daa:	89 30                	mov    %esi,(%eax)
	return conf;
}
f0105dac:	89 d8                	mov    %ebx,%eax
f0105dae:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105db1:	5b                   	pop    %ebx
f0105db2:	5e                   	pop    %esi
f0105db3:	5f                   	pop    %edi
f0105db4:	5d                   	pop    %ebp
f0105db5:	c3                   	ret    
		cprintf("SMP: Default configurations not implemented\n");
f0105db6:	83 ec 0c             	sub    $0xc,%esp
f0105db9:	68 34 81 10 f0       	push   $0xf0108134
f0105dbe:	e8 6a db ff ff       	call   f010392d <cprintf>
		return NULL;
f0105dc3:	83 c4 10             	add    $0x10,%esp
f0105dc6:	bb 00 00 00 00       	mov    $0x0,%ebx
f0105dcb:	eb df                	jmp    f0105dac <mpconfig+0x86>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0105dcd:	83 ec 0c             	sub    $0xc,%esp
f0105dd0:	68 64 81 10 f0       	push   $0xf0108164
f0105dd5:	e8 53 db ff ff       	call   f010392d <cprintf>
		return NULL;
f0105dda:	83 c4 10             	add    $0x10,%esp
f0105ddd:	bb 00 00 00 00       	mov    $0x0,%ebx
f0105de2:	eb c8                	jmp    f0105dac <mpconfig+0x86>
		cprintf("SMP: Bad MP configuration checksum\n");
f0105de4:	83 ec 0c             	sub    $0xc,%esp
f0105de7:	68 98 81 10 f0       	push   $0xf0108198
f0105dec:	e8 3c db ff ff       	call   f010392d <cprintf>
		return NULL;
f0105df1:	83 c4 10             	add    $0x10,%esp
f0105df4:	bb 00 00 00 00       	mov    $0x0,%ebx
f0105df9:	eb b1                	jmp    f0105dac <mpconfig+0x86>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0105dfb:	83 ec 08             	sub    $0x8,%esp
f0105dfe:	0f b6 c0             	movzbl %al,%eax
f0105e01:	50                   	push   %eax
f0105e02:	68 bc 81 10 f0       	push   $0xf01081bc
f0105e07:	e8 21 db ff ff       	call   f010392d <cprintf>
		return NULL;
f0105e0c:	83 c4 10             	add    $0x10,%esp
f0105e0f:	bb 00 00 00 00       	mov    $0x0,%ebx
f0105e14:	eb 96                	jmp    f0105dac <mpconfig+0x86>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0105e16:	83 ec 0c             	sub    $0xc,%esp
f0105e19:	68 dc 81 10 f0       	push   $0xf01081dc
f0105e1e:	e8 0a db ff ff       	call   f010392d <cprintf>
		return NULL;
f0105e23:	83 c4 10             	add    $0x10,%esp
f0105e26:	bb 00 00 00 00       	mov    $0x0,%ebx
f0105e2b:	e9 7c ff ff ff       	jmp    f0105dac <mpconfig+0x86>
		return NULL;
f0105e30:	89 c3                	mov    %eax,%ebx
f0105e32:	e9 75 ff ff ff       	jmp    f0105dac <mpconfig+0x86>

f0105e37 <mp_init>:

void
mp_init(void)
{
f0105e37:	f3 0f 1e fb          	endbr32 
f0105e3b:	55                   	push   %ebp
f0105e3c:	89 e5                	mov    %esp,%ebp
f0105e3e:	57                   	push   %edi
f0105e3f:	56                   	push   %esi
f0105e40:	53                   	push   %ebx
f0105e41:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0105e44:	c7 05 c0 03 25 f0 20 	movl   $0xf0250020,0xf02503c0
f0105e4b:	00 25 f0 
	if ((conf = mpconfig(&mp)) == 0)
f0105e4e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105e51:	e8 d0 fe ff ff       	call   f0105d26 <mpconfig>
f0105e56:	85 c0                	test   %eax,%eax
f0105e58:	0f 84 e5 00 00 00    	je     f0105f43 <mp_init+0x10c>
f0105e5e:	89 c7                	mov    %eax,%edi
		return;
	ismp = 1;
f0105e60:	c7 05 00 00 25 f0 01 	movl   $0x1,0xf0250000
f0105e67:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0105e6a:	8b 40 24             	mov    0x24(%eax),%eax
f0105e6d:	a3 00 10 29 f0       	mov    %eax,0xf0291000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105e72:	8d 77 2c             	lea    0x2c(%edi),%esi
f0105e75:	bb 00 00 00 00       	mov    $0x0,%ebx
f0105e7a:	eb 38                	jmp    f0105eb4 <mp_init+0x7d>
		switch (*p) {
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0105e7c:	f6 46 03 02          	testb  $0x2,0x3(%esi)
f0105e80:	74 11                	je     f0105e93 <mp_init+0x5c>
				bootcpu = &cpus[ncpu];
f0105e82:	6b 05 c4 03 25 f0 74 	imul   $0x74,0xf02503c4,%eax
f0105e89:	05 20 00 25 f0       	add    $0xf0250020,%eax
f0105e8e:	a3 c0 03 25 f0       	mov    %eax,0xf02503c0
			if (ncpu < NCPU) {
f0105e93:	a1 c4 03 25 f0       	mov    0xf02503c4,%eax
f0105e98:	83 f8 07             	cmp    $0x7,%eax
f0105e9b:	7f 33                	jg     f0105ed0 <mp_init+0x99>
				cpus[ncpu].cpu_id = ncpu;
f0105e9d:	6b d0 74             	imul   $0x74,%eax,%edx
f0105ea0:	88 82 20 00 25 f0    	mov    %al,-0xfdaffe0(%edx)
				ncpu++;
f0105ea6:	83 c0 01             	add    $0x1,%eax
f0105ea9:	a3 c4 03 25 f0       	mov    %eax,0xf02503c4
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0105eae:	83 c6 14             	add    $0x14,%esi
	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105eb1:	83 c3 01             	add    $0x1,%ebx
f0105eb4:	0f b7 47 22          	movzwl 0x22(%edi),%eax
f0105eb8:	39 d8                	cmp    %ebx,%eax
f0105eba:	76 4f                	jbe    f0105f0b <mp_init+0xd4>
		switch (*p) {
f0105ebc:	0f b6 06             	movzbl (%esi),%eax
f0105ebf:	84 c0                	test   %al,%al
f0105ec1:	74 b9                	je     f0105e7c <mp_init+0x45>
f0105ec3:	8d 50 ff             	lea    -0x1(%eax),%edx
f0105ec6:	80 fa 03             	cmp    $0x3,%dl
f0105ec9:	77 1c                	ja     f0105ee7 <mp_init+0xb0>
			continue;
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0105ecb:	83 c6 08             	add    $0x8,%esi
			continue;
f0105ece:	eb e1                	jmp    f0105eb1 <mp_init+0x7a>
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0105ed0:	83 ec 08             	sub    $0x8,%esp
f0105ed3:	0f b6 46 01          	movzbl 0x1(%esi),%eax
f0105ed7:	50                   	push   %eax
f0105ed8:	68 0c 82 10 f0       	push   $0xf010820c
f0105edd:	e8 4b da ff ff       	call   f010392d <cprintf>
f0105ee2:	83 c4 10             	add    $0x10,%esp
f0105ee5:	eb c7                	jmp    f0105eae <mp_init+0x77>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0105ee7:	83 ec 08             	sub    $0x8,%esp
		switch (*p) {
f0105eea:	0f b6 c0             	movzbl %al,%eax
			cprintf("mpinit: unknown config type %x\n", *p);
f0105eed:	50                   	push   %eax
f0105eee:	68 34 82 10 f0       	push   $0xf0108234
f0105ef3:	e8 35 da ff ff       	call   f010392d <cprintf>
			ismp = 0;
f0105ef8:	c7 05 00 00 25 f0 00 	movl   $0x0,0xf0250000
f0105eff:	00 00 00 
			i = conf->entry;
f0105f02:	0f b7 5f 22          	movzwl 0x22(%edi),%ebx
f0105f06:	83 c4 10             	add    $0x10,%esp
f0105f09:	eb a6                	jmp    f0105eb1 <mp_init+0x7a>
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0105f0b:	a1 c0 03 25 f0       	mov    0xf02503c0,%eax
f0105f10:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0105f17:	83 3d 00 00 25 f0 00 	cmpl   $0x0,0xf0250000
f0105f1e:	74 2b                	je     f0105f4b <mp_init+0x114>
		ncpu = 1;
		lapicaddr = 0;
		cprintf("SMP: configuration not found, SMP disabled\n");
		return;
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0105f20:	83 ec 04             	sub    $0x4,%esp
f0105f23:	ff 35 c4 03 25 f0    	pushl  0xf02503c4
f0105f29:	0f b6 00             	movzbl (%eax),%eax
f0105f2c:	50                   	push   %eax
f0105f2d:	68 db 82 10 f0       	push   $0xf01082db
f0105f32:	e8 f6 d9 ff ff       	call   f010392d <cprintf>

	if (mp->imcrp) {
f0105f37:	83 c4 10             	add    $0x10,%esp
f0105f3a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105f3d:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0105f41:	75 2e                	jne    f0105f71 <mp_init+0x13a>
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f0105f43:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105f46:	5b                   	pop    %ebx
f0105f47:	5e                   	pop    %esi
f0105f48:	5f                   	pop    %edi
f0105f49:	5d                   	pop    %ebp
f0105f4a:	c3                   	ret    
		ncpu = 1;
f0105f4b:	c7 05 c4 03 25 f0 01 	movl   $0x1,0xf02503c4
f0105f52:	00 00 00 
		lapicaddr = 0;
f0105f55:	c7 05 00 10 29 f0 00 	movl   $0x0,0xf0291000
f0105f5c:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0105f5f:	83 ec 0c             	sub    $0xc,%esp
f0105f62:	68 54 82 10 f0       	push   $0xf0108254
f0105f67:	e8 c1 d9 ff ff       	call   f010392d <cprintf>
		return;
f0105f6c:	83 c4 10             	add    $0x10,%esp
f0105f6f:	eb d2                	jmp    f0105f43 <mp_init+0x10c>
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0105f71:	83 ec 0c             	sub    $0xc,%esp
f0105f74:	68 80 82 10 f0       	push   $0xf0108280
f0105f79:	e8 af d9 ff ff       	call   f010392d <cprintf>
		outb(0x22, 0x70);   // Select IMCR
f0105f7e:	ba 70 00 00 00       	mov    $0x70,%edx
f0105f83:	b8 22 00 00 00       	mov    $0x22,%eax
f0105f88:	e8 6a fc ff ff       	call   f0105bf7 <outb>
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f0105f8d:	b8 23 00 00 00       	mov    $0x23,%eax
f0105f92:	e8 5c fc ff ff       	call   f0105bf3 <inb>
f0105f97:	83 c8 01             	or     $0x1,%eax
f0105f9a:	0f b6 d0             	movzbl %al,%edx
f0105f9d:	b8 23 00 00 00       	mov    $0x23,%eax
f0105fa2:	e8 50 fc ff ff       	call   f0105bf7 <outb>
f0105fa7:	83 c4 10             	add    $0x10,%esp
f0105faa:	eb 97                	jmp    f0105f43 <mp_init+0x10c>

f0105fac <outb>:
{
f0105fac:	89 c1                	mov    %eax,%ecx
f0105fae:	89 d0                	mov    %edx,%eax
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105fb0:	89 ca                	mov    %ecx,%edx
f0105fb2:	ee                   	out    %al,(%dx)
}
f0105fb3:	c3                   	ret    

f0105fb4 <lapicw>:
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
	lapic[index] = value;
f0105fb4:	8b 0d 04 10 29 f0    	mov    0xf0291004,%ecx
f0105fba:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0105fbd:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0105fbf:	a1 04 10 29 f0       	mov    0xf0291004,%eax
f0105fc4:	8b 40 20             	mov    0x20(%eax),%eax
}
f0105fc7:	c3                   	ret    

f0105fc8 <_kaddr>:
{
f0105fc8:	55                   	push   %ebp
f0105fc9:	89 e5                	mov    %esp,%ebp
f0105fcb:	53                   	push   %ebx
f0105fcc:	83 ec 04             	sub    $0x4,%esp
	if (PGNUM(pa) >= npages)
f0105fcf:	89 cb                	mov    %ecx,%ebx
f0105fd1:	c1 eb 0c             	shr    $0xc,%ebx
f0105fd4:	3b 1d 88 fe 24 f0    	cmp    0xf024fe88,%ebx
f0105fda:	73 0b                	jae    f0105fe7 <_kaddr+0x1f>
	return (void *)(pa + KERNBASE);
f0105fdc:	8d 81 00 00 00 f0    	lea    -0x10000000(%ecx),%eax
}
f0105fe2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0105fe5:	c9                   	leave  
f0105fe6:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105fe7:	51                   	push   %ecx
f0105fe8:	68 ec 66 10 f0       	push   $0xf01066ec
f0105fed:	52                   	push   %edx
f0105fee:	50                   	push   %eax
f0105fef:	e8 76 a0 ff ff       	call   f010006a <_panic>

f0105ff4 <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0105ff4:	f3 0f 1e fb          	endbr32 
	if (lapic)
f0105ff8:	8b 15 04 10 29 f0    	mov    0xf0291004,%edx
		return lapic[ID] >> 24;
	return 0;
f0105ffe:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lapic)
f0106003:	85 d2                	test   %edx,%edx
f0106005:	74 06                	je     f010600d <cpunum+0x19>
		return lapic[ID] >> 24;
f0106007:	8b 42 20             	mov    0x20(%edx),%eax
f010600a:	c1 e8 18             	shr    $0x18,%eax
}
f010600d:	c3                   	ret    

f010600e <lapic_init>:
{
f010600e:	f3 0f 1e fb          	endbr32 
	if (!lapicaddr)
f0106012:	a1 00 10 29 f0       	mov    0xf0291000,%eax
f0106017:	85 c0                	test   %eax,%eax
f0106019:	75 01                	jne    f010601c <lapic_init+0xe>
f010601b:	c3                   	ret    
{
f010601c:	55                   	push   %ebp
f010601d:	89 e5                	mov    %esp,%ebp
f010601f:	83 ec 10             	sub    $0x10,%esp
	lapic = mmio_map_region(lapicaddr, 4096);
f0106022:	68 00 10 00 00       	push   $0x1000
f0106027:	50                   	push   %eax
f0106028:	e8 0b be ff ff       	call   f0101e38 <mmio_map_region>
f010602d:	a3 04 10 29 f0       	mov    %eax,0xf0291004
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0106032:	ba 27 01 00 00       	mov    $0x127,%edx
f0106037:	b8 3c 00 00 00       	mov    $0x3c,%eax
f010603c:	e8 73 ff ff ff       	call   f0105fb4 <lapicw>
	lapicw(TDCR, X1);
f0106041:	ba 0b 00 00 00       	mov    $0xb,%edx
f0106046:	b8 f8 00 00 00       	mov    $0xf8,%eax
f010604b:	e8 64 ff ff ff       	call   f0105fb4 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0106050:	ba 20 00 02 00       	mov    $0x20020,%edx
f0106055:	b8 c8 00 00 00       	mov    $0xc8,%eax
f010605a:	e8 55 ff ff ff       	call   f0105fb4 <lapicw>
	lapicw(TICR, 10000000); 
f010605f:	ba 80 96 98 00       	mov    $0x989680,%edx
f0106064:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0106069:	e8 46 ff ff ff       	call   f0105fb4 <lapicw>
	if (thiscpu != bootcpu)
f010606e:	e8 81 ff ff ff       	call   f0105ff4 <cpunum>
f0106073:	6b c0 74             	imul   $0x74,%eax,%eax
f0106076:	05 20 00 25 f0       	add    $0xf0250020,%eax
f010607b:	83 c4 10             	add    $0x10,%esp
f010607e:	39 05 c0 03 25 f0    	cmp    %eax,0xf02503c0
f0106084:	74 0f                	je     f0106095 <lapic_init+0x87>
		lapicw(LINT0, MASKED);
f0106086:	ba 00 00 01 00       	mov    $0x10000,%edx
f010608b:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0106090:	e8 1f ff ff ff       	call   f0105fb4 <lapicw>
	lapicw(LINT1, MASKED);
f0106095:	ba 00 00 01 00       	mov    $0x10000,%edx
f010609a:	b8 d8 00 00 00       	mov    $0xd8,%eax
f010609f:	e8 10 ff ff ff       	call   f0105fb4 <lapicw>
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f01060a4:	a1 04 10 29 f0       	mov    0xf0291004,%eax
f01060a9:	8b 40 30             	mov    0x30(%eax),%eax
f01060ac:	c1 e8 10             	shr    $0x10,%eax
f01060af:	a8 fc                	test   $0xfc,%al
f01060b1:	75 7c                	jne    f010612f <lapic_init+0x121>
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f01060b3:	ba 33 00 00 00       	mov    $0x33,%edx
f01060b8:	b8 dc 00 00 00       	mov    $0xdc,%eax
f01060bd:	e8 f2 fe ff ff       	call   f0105fb4 <lapicw>
	lapicw(ESR, 0);
f01060c2:	ba 00 00 00 00       	mov    $0x0,%edx
f01060c7:	b8 a0 00 00 00       	mov    $0xa0,%eax
f01060cc:	e8 e3 fe ff ff       	call   f0105fb4 <lapicw>
	lapicw(ESR, 0);
f01060d1:	ba 00 00 00 00       	mov    $0x0,%edx
f01060d6:	b8 a0 00 00 00       	mov    $0xa0,%eax
f01060db:	e8 d4 fe ff ff       	call   f0105fb4 <lapicw>
	lapicw(EOI, 0);
f01060e0:	ba 00 00 00 00       	mov    $0x0,%edx
f01060e5:	b8 2c 00 00 00       	mov    $0x2c,%eax
f01060ea:	e8 c5 fe ff ff       	call   f0105fb4 <lapicw>
	lapicw(ICRHI, 0);
f01060ef:	ba 00 00 00 00       	mov    $0x0,%edx
f01060f4:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01060f9:	e8 b6 fe ff ff       	call   f0105fb4 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f01060fe:	ba 00 85 08 00       	mov    $0x88500,%edx
f0106103:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106108:	e8 a7 fe ff ff       	call   f0105fb4 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f010610d:	8b 15 04 10 29 f0    	mov    0xf0291004,%edx
f0106113:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0106119:	f6 c4 10             	test   $0x10,%ah
f010611c:	75 f5                	jne    f0106113 <lapic_init+0x105>
	lapicw(TPR, 0);
f010611e:	ba 00 00 00 00       	mov    $0x0,%edx
f0106123:	b8 20 00 00 00       	mov    $0x20,%eax
f0106128:	e8 87 fe ff ff       	call   f0105fb4 <lapicw>
}
f010612d:	c9                   	leave  
f010612e:	c3                   	ret    
		lapicw(PCINT, MASKED);
f010612f:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106134:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0106139:	e8 76 fe ff ff       	call   f0105fb4 <lapicw>
f010613e:	e9 70 ff ff ff       	jmp    f01060b3 <lapic_init+0xa5>

f0106143 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f0106143:	f3 0f 1e fb          	endbr32 
	if (lapic)
f0106147:	83 3d 04 10 29 f0 00 	cmpl   $0x0,0xf0291004
f010614e:	74 17                	je     f0106167 <lapic_eoi+0x24>
{
f0106150:	55                   	push   %ebp
f0106151:	89 e5                	mov    %esp,%ebp
f0106153:	83 ec 08             	sub    $0x8,%esp
		lapicw(EOI, 0);
f0106156:	ba 00 00 00 00       	mov    $0x0,%edx
f010615b:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0106160:	e8 4f fe ff ff       	call   f0105fb4 <lapicw>
}
f0106165:	c9                   	leave  
f0106166:	c3                   	ret    
f0106167:	c3                   	ret    

f0106168 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0106168:	f3 0f 1e fb          	endbr32 
f010616c:	55                   	push   %ebp
f010616d:	89 e5                	mov    %esp,%ebp
f010616f:	56                   	push   %esi
f0106170:	53                   	push   %ebx
f0106171:	8b 75 08             	mov    0x8(%ebp),%esi
f0106174:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	uint16_t *wrv;

	// "The BSP must initialize CMOS shutdown code to 0AH
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
f0106177:	ba 0f 00 00 00       	mov    $0xf,%edx
f010617c:	b8 70 00 00 00       	mov    $0x70,%eax
f0106181:	e8 26 fe ff ff       	call   f0105fac <outb>
	outb(IO_RTC+1, 0x0A);
f0106186:	ba 0a 00 00 00       	mov    $0xa,%edx
f010618b:	b8 71 00 00 00       	mov    $0x71,%eax
f0106190:	e8 17 fe ff ff       	call   f0105fac <outb>
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
f0106195:	b9 67 04 00 00       	mov    $0x467,%ecx
f010619a:	ba 98 00 00 00       	mov    $0x98,%edx
f010619f:	b8 f8 82 10 f0       	mov    $0xf01082f8,%eax
f01061a4:	e8 1f fe ff ff       	call   f0105fc8 <_kaddr>
	wrv[0] = 0;
f01061a9:	66 c7 00 00 00       	movw   $0x0,(%eax)
	wrv[1] = addr >> 4;
f01061ae:	89 da                	mov    %ebx,%edx
f01061b0:	c1 ea 04             	shr    $0x4,%edx
f01061b3:	66 89 50 02          	mov    %dx,0x2(%eax)

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f01061b7:	c1 e6 18             	shl    $0x18,%esi
f01061ba:	89 f2                	mov    %esi,%edx
f01061bc:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01061c1:	e8 ee fd ff ff       	call   f0105fb4 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f01061c6:	ba 00 c5 00 00       	mov    $0xc500,%edx
f01061cb:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01061d0:	e8 df fd ff ff       	call   f0105fb4 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f01061d5:	ba 00 85 00 00       	mov    $0x8500,%edx
f01061da:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01061df:	e8 d0 fd ff ff       	call   f0105fb4 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01061e4:	c1 eb 0c             	shr    $0xc,%ebx
f01061e7:	80 cf 06             	or     $0x6,%bh
		lapicw(ICRHI, apicid << 24);
f01061ea:	89 f2                	mov    %esi,%edx
f01061ec:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01061f1:	e8 be fd ff ff       	call   f0105fb4 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01061f6:	89 da                	mov    %ebx,%edx
f01061f8:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01061fd:	e8 b2 fd ff ff       	call   f0105fb4 <lapicw>
		lapicw(ICRHI, apicid << 24);
f0106202:	89 f2                	mov    %esi,%edx
f0106204:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106209:	e8 a6 fd ff ff       	call   f0105fb4 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f010620e:	89 da                	mov    %ebx,%edx
f0106210:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106215:	e8 9a fd ff ff       	call   f0105fb4 <lapicw>
		microdelay(200);
	}
}
f010621a:	5b                   	pop    %ebx
f010621b:	5e                   	pop    %esi
f010621c:	5d                   	pop    %ebp
f010621d:	c3                   	ret    

f010621e <lapic_ipi>:

void
lapic_ipi(int vector)
{
f010621e:	f3 0f 1e fb          	endbr32 
f0106222:	55                   	push   %ebp
f0106223:	89 e5                	mov    %esp,%ebp
f0106225:	83 ec 08             	sub    $0x8,%esp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0106228:	8b 55 08             	mov    0x8(%ebp),%edx
f010622b:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0106231:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106236:	e8 79 fd ff ff       	call   f0105fb4 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f010623b:	8b 15 04 10 29 f0    	mov    0xf0291004,%edx
f0106241:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0106247:	f6 c4 10             	test   $0x10,%ah
f010624a:	75 f5                	jne    f0106241 <lapic_ipi+0x23>
		;
}
f010624c:	c9                   	leave  
f010624d:	c3                   	ret    

f010624e <xchg>:
{
f010624e:	89 c1                	mov    %eax,%ecx
f0106250:	89 d0                	mov    %edx,%eax
	asm volatile("lock; xchgl %0, %1"
f0106252:	f0 87 01             	lock xchg %eax,(%ecx)
}
f0106255:	c3                   	ret    

f0106256 <get_caller_pcs>:
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0106256:	89 e9                	mov    %ebp,%ecx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0106258:	ba 00 00 00 00       	mov    $0x0,%edx
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f010625d:	81 f9 ff ff 7f ef    	cmp    $0xef7fffff,%ecx
f0106263:	76 3f                	jbe    f01062a4 <get_caller_pcs+0x4e>
f0106265:	83 fa 09             	cmp    $0x9,%edx
f0106268:	7f 3a                	jg     f01062a4 <get_caller_pcs+0x4e>
{
f010626a:	55                   	push   %ebp
f010626b:	89 e5                	mov    %esp,%ebp
f010626d:	53                   	push   %ebx
			break;
		pcs[i] = ebp[1];          // saved %eip
f010626e:	8b 59 04             	mov    0x4(%ecx),%ebx
f0106271:	89 1c 90             	mov    %ebx,(%eax,%edx,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0106274:	8b 09                	mov    (%ecx),%ecx
	for (i = 0; i < 10; i++){
f0106276:	83 c2 01             	add    $0x1,%edx
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0106279:	81 f9 ff ff 7f ef    	cmp    $0xef7fffff,%ecx
f010627f:	76 11                	jbe    f0106292 <get_caller_pcs+0x3c>
f0106281:	83 fa 09             	cmp    $0x9,%edx
f0106284:	7e e8                	jle    f010626e <get_caller_pcs+0x18>
f0106286:	eb 0a                	jmp    f0106292 <get_caller_pcs+0x3c>
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f0106288:	c7 04 90 00 00 00 00 	movl   $0x0,(%eax,%edx,4)
	for (; i < 10; i++)
f010628f:	83 c2 01             	add    $0x1,%edx
f0106292:	83 fa 09             	cmp    $0x9,%edx
f0106295:	7e f1                	jle    f0106288 <get_caller_pcs+0x32>
}
f0106297:	5b                   	pop    %ebx
f0106298:	5d                   	pop    %ebp
f0106299:	c3                   	ret    
		pcs[i] = 0;
f010629a:	c7 04 90 00 00 00 00 	movl   $0x0,(%eax,%edx,4)
	for (; i < 10; i++)
f01062a1:	83 c2 01             	add    $0x1,%edx
f01062a4:	83 fa 09             	cmp    $0x9,%edx
f01062a7:	7e f1                	jle    f010629a <get_caller_pcs+0x44>
f01062a9:	c3                   	ret    

f01062aa <holding>:

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f01062aa:	83 38 00             	cmpl   $0x0,(%eax)
f01062ad:	75 06                	jne    f01062b5 <holding+0xb>
f01062af:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01062b4:	c3                   	ret    
{
f01062b5:	55                   	push   %ebp
f01062b6:	89 e5                	mov    %esp,%ebp
f01062b8:	53                   	push   %ebx
f01062b9:	83 ec 04             	sub    $0x4,%esp
	return lock->locked && lock->cpu == thiscpu;
f01062bc:	8b 58 08             	mov    0x8(%eax),%ebx
f01062bf:	e8 30 fd ff ff       	call   f0105ff4 <cpunum>
f01062c4:	6b c0 74             	imul   $0x74,%eax,%eax
f01062c7:	05 20 00 25 f0       	add    $0xf0250020,%eax
f01062cc:	39 c3                	cmp    %eax,%ebx
f01062ce:	0f 94 c0             	sete   %al
f01062d1:	0f b6 c0             	movzbl %al,%eax
}
f01062d4:	83 c4 04             	add    $0x4,%esp
f01062d7:	5b                   	pop    %ebx
f01062d8:	5d                   	pop    %ebp
f01062d9:	c3                   	ret    

f01062da <__spin_initlock>:
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f01062da:	f3 0f 1e fb          	endbr32 
f01062de:	55                   	push   %ebp
f01062df:	89 e5                	mov    %esp,%ebp
f01062e1:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f01062e4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f01062ea:	8b 55 0c             	mov    0xc(%ebp),%edx
f01062ed:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f01062f0:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f01062f7:	5d                   	pop    %ebp
f01062f8:	c3                   	ret    

f01062f9 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f01062f9:	f3 0f 1e fb          	endbr32 
f01062fd:	55                   	push   %ebp
f01062fe:	89 e5                	mov    %esp,%ebp
f0106300:	53                   	push   %ebx
f0106301:	83 ec 04             	sub    $0x4,%esp
f0106304:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0106307:	89 d8                	mov    %ebx,%eax
f0106309:	e8 9c ff ff ff       	call   f01062aa <holding>
f010630e:	85 c0                	test   %eax,%eax
f0106310:	74 20                	je     f0106332 <spin_lock+0x39>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0106312:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0106315:	e8 da fc ff ff       	call   f0105ff4 <cpunum>
f010631a:	83 ec 0c             	sub    $0xc,%esp
f010631d:	53                   	push   %ebx
f010631e:	50                   	push   %eax
f010631f:	68 08 83 10 f0       	push   $0xf0108308
f0106324:	6a 41                	push   $0x41
f0106326:	68 6a 83 10 f0       	push   $0xf010836a
f010632b:	e8 3a 9d ff ff       	call   f010006a <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f0106330:	f3 90                	pause  
	while (xchg(&lk->locked, 1) != 0)
f0106332:	ba 01 00 00 00       	mov    $0x1,%edx
f0106337:	89 d8                	mov    %ebx,%eax
f0106339:	e8 10 ff ff ff       	call   f010624e <xchg>
f010633e:	85 c0                	test   %eax,%eax
f0106340:	75 ee                	jne    f0106330 <spin_lock+0x37>

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0106342:	e8 ad fc ff ff       	call   f0105ff4 <cpunum>
f0106347:	6b c0 74             	imul   $0x74,%eax,%eax
f010634a:	05 20 00 25 f0       	add    $0xf0250020,%eax
f010634f:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0106352:	8d 43 0c             	lea    0xc(%ebx),%eax
f0106355:	e8 fc fe ff ff       	call   f0106256 <get_caller_pcs>
#endif
}
f010635a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010635d:	c9                   	leave  
f010635e:	c3                   	ret    

f010635f <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f010635f:	f3 0f 1e fb          	endbr32 
f0106363:	55                   	push   %ebp
f0106364:	89 e5                	mov    %esp,%ebp
f0106366:	57                   	push   %edi
f0106367:	56                   	push   %esi
f0106368:	53                   	push   %ebx
f0106369:	83 ec 4c             	sub    $0x4c,%esp
f010636c:	8b 75 08             	mov    0x8(%ebp),%esi
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f010636f:	89 f0                	mov    %esi,%eax
f0106371:	e8 34 ff ff ff       	call   f01062aa <holding>
f0106376:	85 c0                	test   %eax,%eax
f0106378:	74 22                	je     f010639c <spin_unlock+0x3d>
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
	}

	lk->pcs[0] = 0;
f010637a:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f0106381:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
	// The xchg instruction is atomic (i.e. uses the "lock" prefix) with
	// respect to any other instruction which references the same memory.
	// x86 CPUs will not reorder loads/stores across locked instructions
	// (vol 3, 8.2.2). Because xchg() is implemented using asm volatile,
	// gcc will not reorder C statements across the xchg.
	xchg(&lk->locked, 0);
f0106388:	ba 00 00 00 00       	mov    $0x0,%edx
f010638d:	89 f0                	mov    %esi,%eax
f010638f:	e8 ba fe ff ff       	call   f010624e <xchg>
}
f0106394:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0106397:	5b                   	pop    %ebx
f0106398:	5e                   	pop    %esi
f0106399:	5f                   	pop    %edi
f010639a:	5d                   	pop    %ebp
f010639b:	c3                   	ret    
		memmove(pcs, lk->pcs, sizeof pcs);
f010639c:	83 ec 04             	sub    $0x4,%esp
f010639f:	6a 28                	push   $0x28
f01063a1:	8d 46 0c             	lea    0xc(%esi),%eax
f01063a4:	50                   	push   %eax
f01063a5:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f01063a8:	53                   	push   %ebx
f01063a9:	e8 05 f6 ff ff       	call   f01059b3 <memmove>
			cpunum(), lk->name, lk->cpu->cpu_id);
f01063ae:	8b 46 08             	mov    0x8(%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f01063b1:	0f b6 38             	movzbl (%eax),%edi
f01063b4:	8b 76 04             	mov    0x4(%esi),%esi
f01063b7:	e8 38 fc ff ff       	call   f0105ff4 <cpunum>
f01063bc:	57                   	push   %edi
f01063bd:	56                   	push   %esi
f01063be:	50                   	push   %eax
f01063bf:	68 34 83 10 f0       	push   $0xf0108334
f01063c4:	e8 64 d5 ff ff       	call   f010392d <cprintf>
f01063c9:	83 c4 20             	add    $0x20,%esp
			if (debuginfo_eip(pcs[i], &info) >= 0)
f01063cc:	8d 7d a8             	lea    -0x58(%ebp),%edi
f01063cf:	eb 1c                	jmp    f01063ed <spin_unlock+0x8e>
				cprintf("  %08x\n", pcs[i]);
f01063d1:	83 ec 08             	sub    $0x8,%esp
f01063d4:	ff 36                	pushl  (%esi)
f01063d6:	68 91 83 10 f0       	push   $0xf0108391
f01063db:	e8 4d d5 ff ff       	call   f010392d <cprintf>
f01063e0:	83 c4 10             	add    $0x10,%esp
f01063e3:	83 c3 04             	add    $0x4,%ebx
		for (i = 0; i < 10 && pcs[i]; i++) {
f01063e6:	8d 45 e8             	lea    -0x18(%ebp),%eax
f01063e9:	39 c3                	cmp    %eax,%ebx
f01063eb:	74 40                	je     f010642d <spin_unlock+0xce>
f01063ed:	89 de                	mov    %ebx,%esi
f01063ef:	8b 03                	mov    (%ebx),%eax
f01063f1:	85 c0                	test   %eax,%eax
f01063f3:	74 38                	je     f010642d <spin_unlock+0xce>
			if (debuginfo_eip(pcs[i], &info) >= 0)
f01063f5:	83 ec 08             	sub    $0x8,%esp
f01063f8:	57                   	push   %edi
f01063f9:	50                   	push   %eax
f01063fa:	e8 d4 ea ff ff       	call   f0104ed3 <debuginfo_eip>
f01063ff:	83 c4 10             	add    $0x10,%esp
f0106402:	85 c0                	test   %eax,%eax
f0106404:	78 cb                	js     f01063d1 <spin_unlock+0x72>
					pcs[i] - info.eip_fn_addr);
f0106406:	8b 06                	mov    (%esi),%eax
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0106408:	83 ec 04             	sub    $0x4,%esp
f010640b:	89 c2                	mov    %eax,%edx
f010640d:	2b 55 b8             	sub    -0x48(%ebp),%edx
f0106410:	52                   	push   %edx
f0106411:	ff 75 b0             	pushl  -0x50(%ebp)
f0106414:	ff 75 b4             	pushl  -0x4c(%ebp)
f0106417:	ff 75 ac             	pushl  -0x54(%ebp)
f010641a:	ff 75 a8             	pushl  -0x58(%ebp)
f010641d:	50                   	push   %eax
f010641e:	68 7a 83 10 f0       	push   $0xf010837a
f0106423:	e8 05 d5 ff ff       	call   f010392d <cprintf>
f0106428:	83 c4 20             	add    $0x20,%esp
f010642b:	eb b6                	jmp    f01063e3 <spin_unlock+0x84>
		panic("spin_unlock");
f010642d:	83 ec 04             	sub    $0x4,%esp
f0106430:	68 99 83 10 f0       	push   $0xf0108399
f0106435:	6a 67                	push   $0x67
f0106437:	68 6a 83 10 f0       	push   $0xf010836a
f010643c:	e8 29 9c ff ff       	call   f010006a <_panic>
f0106441:	66 90                	xchg   %ax,%ax
f0106443:	66 90                	xchg   %ax,%ax
f0106445:	66 90                	xchg   %ax,%ax
f0106447:	66 90                	xchg   %ax,%ax
f0106449:	66 90                	xchg   %ax,%ax
f010644b:	66 90                	xchg   %ax,%ax
f010644d:	66 90                	xchg   %ax,%ax
f010644f:	90                   	nop

f0106450 <__udivdi3>:
f0106450:	f3 0f 1e fb          	endbr32 
f0106454:	55                   	push   %ebp
f0106455:	57                   	push   %edi
f0106456:	56                   	push   %esi
f0106457:	53                   	push   %ebx
f0106458:	83 ec 1c             	sub    $0x1c,%esp
f010645b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010645f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f0106463:	8b 74 24 34          	mov    0x34(%esp),%esi
f0106467:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f010646b:	85 d2                	test   %edx,%edx
f010646d:	75 19                	jne    f0106488 <__udivdi3+0x38>
f010646f:	39 f3                	cmp    %esi,%ebx
f0106471:	76 4d                	jbe    f01064c0 <__udivdi3+0x70>
f0106473:	31 ff                	xor    %edi,%edi
f0106475:	89 e8                	mov    %ebp,%eax
f0106477:	89 f2                	mov    %esi,%edx
f0106479:	f7 f3                	div    %ebx
f010647b:	89 fa                	mov    %edi,%edx
f010647d:	83 c4 1c             	add    $0x1c,%esp
f0106480:	5b                   	pop    %ebx
f0106481:	5e                   	pop    %esi
f0106482:	5f                   	pop    %edi
f0106483:	5d                   	pop    %ebp
f0106484:	c3                   	ret    
f0106485:	8d 76 00             	lea    0x0(%esi),%esi
f0106488:	39 f2                	cmp    %esi,%edx
f010648a:	76 14                	jbe    f01064a0 <__udivdi3+0x50>
f010648c:	31 ff                	xor    %edi,%edi
f010648e:	31 c0                	xor    %eax,%eax
f0106490:	89 fa                	mov    %edi,%edx
f0106492:	83 c4 1c             	add    $0x1c,%esp
f0106495:	5b                   	pop    %ebx
f0106496:	5e                   	pop    %esi
f0106497:	5f                   	pop    %edi
f0106498:	5d                   	pop    %ebp
f0106499:	c3                   	ret    
f010649a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01064a0:	0f bd fa             	bsr    %edx,%edi
f01064a3:	83 f7 1f             	xor    $0x1f,%edi
f01064a6:	75 48                	jne    f01064f0 <__udivdi3+0xa0>
f01064a8:	39 f2                	cmp    %esi,%edx
f01064aa:	72 06                	jb     f01064b2 <__udivdi3+0x62>
f01064ac:	31 c0                	xor    %eax,%eax
f01064ae:	39 eb                	cmp    %ebp,%ebx
f01064b0:	77 de                	ja     f0106490 <__udivdi3+0x40>
f01064b2:	b8 01 00 00 00       	mov    $0x1,%eax
f01064b7:	eb d7                	jmp    f0106490 <__udivdi3+0x40>
f01064b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01064c0:	89 d9                	mov    %ebx,%ecx
f01064c2:	85 db                	test   %ebx,%ebx
f01064c4:	75 0b                	jne    f01064d1 <__udivdi3+0x81>
f01064c6:	b8 01 00 00 00       	mov    $0x1,%eax
f01064cb:	31 d2                	xor    %edx,%edx
f01064cd:	f7 f3                	div    %ebx
f01064cf:	89 c1                	mov    %eax,%ecx
f01064d1:	31 d2                	xor    %edx,%edx
f01064d3:	89 f0                	mov    %esi,%eax
f01064d5:	f7 f1                	div    %ecx
f01064d7:	89 c6                	mov    %eax,%esi
f01064d9:	89 e8                	mov    %ebp,%eax
f01064db:	89 f7                	mov    %esi,%edi
f01064dd:	f7 f1                	div    %ecx
f01064df:	89 fa                	mov    %edi,%edx
f01064e1:	83 c4 1c             	add    $0x1c,%esp
f01064e4:	5b                   	pop    %ebx
f01064e5:	5e                   	pop    %esi
f01064e6:	5f                   	pop    %edi
f01064e7:	5d                   	pop    %ebp
f01064e8:	c3                   	ret    
f01064e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01064f0:	89 f9                	mov    %edi,%ecx
f01064f2:	b8 20 00 00 00       	mov    $0x20,%eax
f01064f7:	29 f8                	sub    %edi,%eax
f01064f9:	d3 e2                	shl    %cl,%edx
f01064fb:	89 54 24 08          	mov    %edx,0x8(%esp)
f01064ff:	89 c1                	mov    %eax,%ecx
f0106501:	89 da                	mov    %ebx,%edx
f0106503:	d3 ea                	shr    %cl,%edx
f0106505:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0106509:	09 d1                	or     %edx,%ecx
f010650b:	89 f2                	mov    %esi,%edx
f010650d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106511:	89 f9                	mov    %edi,%ecx
f0106513:	d3 e3                	shl    %cl,%ebx
f0106515:	89 c1                	mov    %eax,%ecx
f0106517:	d3 ea                	shr    %cl,%edx
f0106519:	89 f9                	mov    %edi,%ecx
f010651b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f010651f:	89 eb                	mov    %ebp,%ebx
f0106521:	d3 e6                	shl    %cl,%esi
f0106523:	89 c1                	mov    %eax,%ecx
f0106525:	d3 eb                	shr    %cl,%ebx
f0106527:	09 de                	or     %ebx,%esi
f0106529:	89 f0                	mov    %esi,%eax
f010652b:	f7 74 24 08          	divl   0x8(%esp)
f010652f:	89 d6                	mov    %edx,%esi
f0106531:	89 c3                	mov    %eax,%ebx
f0106533:	f7 64 24 0c          	mull   0xc(%esp)
f0106537:	39 d6                	cmp    %edx,%esi
f0106539:	72 15                	jb     f0106550 <__udivdi3+0x100>
f010653b:	89 f9                	mov    %edi,%ecx
f010653d:	d3 e5                	shl    %cl,%ebp
f010653f:	39 c5                	cmp    %eax,%ebp
f0106541:	73 04                	jae    f0106547 <__udivdi3+0xf7>
f0106543:	39 d6                	cmp    %edx,%esi
f0106545:	74 09                	je     f0106550 <__udivdi3+0x100>
f0106547:	89 d8                	mov    %ebx,%eax
f0106549:	31 ff                	xor    %edi,%edi
f010654b:	e9 40 ff ff ff       	jmp    f0106490 <__udivdi3+0x40>
f0106550:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0106553:	31 ff                	xor    %edi,%edi
f0106555:	e9 36 ff ff ff       	jmp    f0106490 <__udivdi3+0x40>
f010655a:	66 90                	xchg   %ax,%ax
f010655c:	66 90                	xchg   %ax,%ax
f010655e:	66 90                	xchg   %ax,%ax

f0106560 <__umoddi3>:
f0106560:	f3 0f 1e fb          	endbr32 
f0106564:	55                   	push   %ebp
f0106565:	57                   	push   %edi
f0106566:	56                   	push   %esi
f0106567:	53                   	push   %ebx
f0106568:	83 ec 1c             	sub    $0x1c,%esp
f010656b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f010656f:	8b 74 24 30          	mov    0x30(%esp),%esi
f0106573:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f0106577:	8b 7c 24 38          	mov    0x38(%esp),%edi
f010657b:	85 c0                	test   %eax,%eax
f010657d:	75 19                	jne    f0106598 <__umoddi3+0x38>
f010657f:	39 df                	cmp    %ebx,%edi
f0106581:	76 5d                	jbe    f01065e0 <__umoddi3+0x80>
f0106583:	89 f0                	mov    %esi,%eax
f0106585:	89 da                	mov    %ebx,%edx
f0106587:	f7 f7                	div    %edi
f0106589:	89 d0                	mov    %edx,%eax
f010658b:	31 d2                	xor    %edx,%edx
f010658d:	83 c4 1c             	add    $0x1c,%esp
f0106590:	5b                   	pop    %ebx
f0106591:	5e                   	pop    %esi
f0106592:	5f                   	pop    %edi
f0106593:	5d                   	pop    %ebp
f0106594:	c3                   	ret    
f0106595:	8d 76 00             	lea    0x0(%esi),%esi
f0106598:	89 f2                	mov    %esi,%edx
f010659a:	39 d8                	cmp    %ebx,%eax
f010659c:	76 12                	jbe    f01065b0 <__umoddi3+0x50>
f010659e:	89 f0                	mov    %esi,%eax
f01065a0:	89 da                	mov    %ebx,%edx
f01065a2:	83 c4 1c             	add    $0x1c,%esp
f01065a5:	5b                   	pop    %ebx
f01065a6:	5e                   	pop    %esi
f01065a7:	5f                   	pop    %edi
f01065a8:	5d                   	pop    %ebp
f01065a9:	c3                   	ret    
f01065aa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01065b0:	0f bd e8             	bsr    %eax,%ebp
f01065b3:	83 f5 1f             	xor    $0x1f,%ebp
f01065b6:	75 50                	jne    f0106608 <__umoddi3+0xa8>
f01065b8:	39 d8                	cmp    %ebx,%eax
f01065ba:	0f 82 e0 00 00 00    	jb     f01066a0 <__umoddi3+0x140>
f01065c0:	89 d9                	mov    %ebx,%ecx
f01065c2:	39 f7                	cmp    %esi,%edi
f01065c4:	0f 86 d6 00 00 00    	jbe    f01066a0 <__umoddi3+0x140>
f01065ca:	89 d0                	mov    %edx,%eax
f01065cc:	89 ca                	mov    %ecx,%edx
f01065ce:	83 c4 1c             	add    $0x1c,%esp
f01065d1:	5b                   	pop    %ebx
f01065d2:	5e                   	pop    %esi
f01065d3:	5f                   	pop    %edi
f01065d4:	5d                   	pop    %ebp
f01065d5:	c3                   	ret    
f01065d6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01065dd:	8d 76 00             	lea    0x0(%esi),%esi
f01065e0:	89 fd                	mov    %edi,%ebp
f01065e2:	85 ff                	test   %edi,%edi
f01065e4:	75 0b                	jne    f01065f1 <__umoddi3+0x91>
f01065e6:	b8 01 00 00 00       	mov    $0x1,%eax
f01065eb:	31 d2                	xor    %edx,%edx
f01065ed:	f7 f7                	div    %edi
f01065ef:	89 c5                	mov    %eax,%ebp
f01065f1:	89 d8                	mov    %ebx,%eax
f01065f3:	31 d2                	xor    %edx,%edx
f01065f5:	f7 f5                	div    %ebp
f01065f7:	89 f0                	mov    %esi,%eax
f01065f9:	f7 f5                	div    %ebp
f01065fb:	89 d0                	mov    %edx,%eax
f01065fd:	31 d2                	xor    %edx,%edx
f01065ff:	eb 8c                	jmp    f010658d <__umoddi3+0x2d>
f0106601:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106608:	89 e9                	mov    %ebp,%ecx
f010660a:	ba 20 00 00 00       	mov    $0x20,%edx
f010660f:	29 ea                	sub    %ebp,%edx
f0106611:	d3 e0                	shl    %cl,%eax
f0106613:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106617:	89 d1                	mov    %edx,%ecx
f0106619:	89 f8                	mov    %edi,%eax
f010661b:	d3 e8                	shr    %cl,%eax
f010661d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0106621:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106625:	8b 54 24 04          	mov    0x4(%esp),%edx
f0106629:	09 c1                	or     %eax,%ecx
f010662b:	89 d8                	mov    %ebx,%eax
f010662d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106631:	89 e9                	mov    %ebp,%ecx
f0106633:	d3 e7                	shl    %cl,%edi
f0106635:	89 d1                	mov    %edx,%ecx
f0106637:	d3 e8                	shr    %cl,%eax
f0106639:	89 e9                	mov    %ebp,%ecx
f010663b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f010663f:	d3 e3                	shl    %cl,%ebx
f0106641:	89 c7                	mov    %eax,%edi
f0106643:	89 d1                	mov    %edx,%ecx
f0106645:	89 f0                	mov    %esi,%eax
f0106647:	d3 e8                	shr    %cl,%eax
f0106649:	89 e9                	mov    %ebp,%ecx
f010664b:	89 fa                	mov    %edi,%edx
f010664d:	d3 e6                	shl    %cl,%esi
f010664f:	09 d8                	or     %ebx,%eax
f0106651:	f7 74 24 08          	divl   0x8(%esp)
f0106655:	89 d1                	mov    %edx,%ecx
f0106657:	89 f3                	mov    %esi,%ebx
f0106659:	f7 64 24 0c          	mull   0xc(%esp)
f010665d:	89 c6                	mov    %eax,%esi
f010665f:	89 d7                	mov    %edx,%edi
f0106661:	39 d1                	cmp    %edx,%ecx
f0106663:	72 06                	jb     f010666b <__umoddi3+0x10b>
f0106665:	75 10                	jne    f0106677 <__umoddi3+0x117>
f0106667:	39 c3                	cmp    %eax,%ebx
f0106669:	73 0c                	jae    f0106677 <__umoddi3+0x117>
f010666b:	2b 44 24 0c          	sub    0xc(%esp),%eax
f010666f:	1b 54 24 08          	sbb    0x8(%esp),%edx
f0106673:	89 d7                	mov    %edx,%edi
f0106675:	89 c6                	mov    %eax,%esi
f0106677:	89 ca                	mov    %ecx,%edx
f0106679:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f010667e:	29 f3                	sub    %esi,%ebx
f0106680:	19 fa                	sbb    %edi,%edx
f0106682:	89 d0                	mov    %edx,%eax
f0106684:	d3 e0                	shl    %cl,%eax
f0106686:	89 e9                	mov    %ebp,%ecx
f0106688:	d3 eb                	shr    %cl,%ebx
f010668a:	d3 ea                	shr    %cl,%edx
f010668c:	09 d8                	or     %ebx,%eax
f010668e:	83 c4 1c             	add    $0x1c,%esp
f0106691:	5b                   	pop    %ebx
f0106692:	5e                   	pop    %esi
f0106693:	5f                   	pop    %edi
f0106694:	5d                   	pop    %ebp
f0106695:	c3                   	ret    
f0106696:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f010669d:	8d 76 00             	lea    0x0(%esi),%esi
f01066a0:	29 fe                	sub    %edi,%esi
f01066a2:	19 c3                	sbb    %eax,%ebx
f01066a4:	89 f2                	mov    %esi,%edx
f01066a6:	89 d9                	mov    %ebx,%ecx
f01066a8:	e9 1d ff ff ff       	jmp    f01065ca <__umoddi3+0x6a>
