
obj/kern/kernel：     文件格式 elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 f0 11 00       	mov    $0x11f000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 f0 11 f0       	mov    $0xf011f000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 b2 00 00 00       	call   f01000f0 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <test_backtrace>:
static void boot_aps(void);

// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	53                   	push   %ebx
f0100044:	83 ec 0c             	sub    $0xc,%esp
f0100047:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("entering test_backtrace %d\n", x);
f010004a:	53                   	push   %ebx
f010004b:	68 00 57 10 f0       	push   $0xf0105700
f0100050:	e8 9d 37 00 00       	call   f01037f2 <cprintf>
	if (x > 0)
f0100055:	83 c4 10             	add    $0x10,%esp
f0100058:	85 db                	test   %ebx,%ebx
f010005a:	7e 25                	jle    f0100081 <test_backtrace+0x41>
		test_backtrace(x-1);
f010005c:	83 ec 0c             	sub    $0xc,%esp
f010005f:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0100062:	50                   	push   %eax
f0100063:	e8 d8 ff ff ff       	call   f0100040 <test_backtrace>
f0100068:	83 c4 10             	add    $0x10,%esp
	else
		mon_backtrace(0, 0, 0);
	cprintf("leaving test_backtrace %d\n", x);
f010006b:	83 ec 08             	sub    $0x8,%esp
f010006e:	53                   	push   %ebx
f010006f:	68 1c 57 10 f0       	push   $0xf010571c
f0100074:	e8 79 37 00 00       	call   f01037f2 <cprintf>
}
f0100079:	83 c4 10             	add    $0x10,%esp
f010007c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010007f:	c9                   	leave  
f0100080:	c3                   	ret    
		mon_backtrace(0, 0, 0);
f0100081:	83 ec 04             	sub    $0x4,%esp
f0100084:	6a 00                	push   $0x0
f0100086:	6a 00                	push   $0x0
f0100088:	6a 00                	push   $0x0
f010008a:	e8 62 08 00 00       	call   f01008f1 <mon_backtrace>
f010008f:	83 c4 10             	add    $0x10,%esp
f0100092:	eb d7                	jmp    f010006b <test_backtrace+0x2b>

f0100094 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100094:	55                   	push   %ebp
f0100095:	89 e5                	mov    %esp,%ebp
f0100097:	56                   	push   %esi
f0100098:	53                   	push   %ebx
f0100099:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f010009c:	83 3d 80 1e 23 f0 00 	cmpl   $0x0,0xf0231e80
f01000a3:	74 0f                	je     f01000b4 <_panic+0x20>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000a5:	83 ec 0c             	sub    $0xc,%esp
f01000a8:	6a 00                	push   $0x0
f01000aa:	e8 c9 08 00 00       	call   f0100978 <monitor>
f01000af:	83 c4 10             	add    $0x10,%esp
f01000b2:	eb f1                	jmp    f01000a5 <_panic+0x11>
	panicstr = fmt;
f01000b4:	89 35 80 1e 23 f0    	mov    %esi,0xf0231e80
	asm volatile("cli; cld");
f01000ba:	fa                   	cli    
f01000bb:	fc                   	cld    
	va_start(ap, fmt);
f01000bc:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f01000bf:	e8 de 4f 00 00       	call   f01050a2 <cpunum>
f01000c4:	ff 75 0c             	pushl  0xc(%ebp)
f01000c7:	ff 75 08             	pushl  0x8(%ebp)
f01000ca:	50                   	push   %eax
f01000cb:	68 90 57 10 f0       	push   $0xf0105790
f01000d0:	e8 1d 37 00 00       	call   f01037f2 <cprintf>
	vcprintf(fmt, ap);
f01000d5:	83 c4 08             	add    $0x8,%esp
f01000d8:	53                   	push   %ebx
f01000d9:	56                   	push   %esi
f01000da:	e8 ed 36 00 00       	call   f01037cc <vcprintf>
	cprintf("\n");
f01000df:	c7 04 24 0b 69 10 f0 	movl   $0xf010690b,(%esp)
f01000e6:	e8 07 37 00 00       	call   f01037f2 <cprintf>
f01000eb:	83 c4 10             	add    $0x10,%esp
f01000ee:	eb b5                	jmp    f01000a5 <_panic+0x11>

f01000f0 <i386_init>:
{
f01000f0:	55                   	push   %ebp
f01000f1:	89 e5                	mov    %esp,%ebp
f01000f3:	53                   	push   %ebx
f01000f4:	83 ec 04             	sub    $0x4,%esp
	cons_init();
f01000f7:	e8 b4 05 00 00       	call   f01006b0 <cons_init>
	cprintf("6828 decimal is %o octal!\n", 6828);
f01000fc:	83 ec 08             	sub    $0x8,%esp
f01000ff:	68 ac 1a 00 00       	push   $0x1aac
f0100104:	68 37 57 10 f0       	push   $0xf0105737
f0100109:	e8 e4 36 00 00       	call   f01037f2 <cprintf>
	test_backtrace(5);
f010010e:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f0100115:	e8 26 ff ff ff       	call   f0100040 <test_backtrace>
	mem_init();
f010011a:	e8 01 12 00 00       	call   f0101320 <mem_init>
	env_init();
f010011f:	e8 20 2f 00 00       	call   f0103044 <env_init>
	trap_init();
f0100124:	e8 a7 37 00 00       	call   f01038d0 <trap_init>
	mp_init();
f0100129:	e8 7d 4c 00 00       	call   f0104dab <mp_init>
	lapic_init();
f010012e:	e8 85 4f 00 00       	call   f01050b8 <lapic_init>
	pic_init();
f0100133:	e8 db 35 00 00       	call   f0103713 <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0100138:	c7 04 24 c0 13 12 f0 	movl   $0xf01213c0,(%esp)
f010013f:	e8 ce 51 00 00       	call   f0105312 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100144:	83 c4 10             	add    $0x10,%esp
f0100147:	83 3d 88 1e 23 f0 07 	cmpl   $0x7,0xf0231e88
f010014e:	76 27                	jbe    f0100177 <i386_init+0x87>
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f0100150:	83 ec 04             	sub    $0x4,%esp
f0100153:	b8 0e 4d 10 f0       	mov    $0xf0104d0e,%eax
f0100158:	2d 94 4c 10 f0       	sub    $0xf0104c94,%eax
f010015d:	50                   	push   %eax
f010015e:	68 94 4c 10 f0       	push   $0xf0104c94
f0100163:	68 00 70 00 f0       	push   $0xf0007000
f0100168:	e8 7f 49 00 00       	call   f0104aec <memmove>
f010016d:	83 c4 10             	add    $0x10,%esp
	for (c = cpus; c < cpus + ncpu; c++) {
f0100170:	bb 20 20 23 f0       	mov    $0xf0232020,%ebx
f0100175:	eb 19                	jmp    f0100190 <i386_init+0xa0>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100177:	68 00 70 00 00       	push   $0x7000
f010017c:	68 b4 57 10 f0       	push   $0xf01057b4
f0100181:	6a 5e                	push   $0x5e
f0100183:	68 52 57 10 f0       	push   $0xf0105752
f0100188:	e8 07 ff ff ff       	call   f0100094 <_panic>
f010018d:	83 c3 74             	add    $0x74,%ebx
f0100190:	6b 05 c4 23 23 f0 74 	imul   $0x74,0xf02323c4,%eax
f0100197:	05 20 20 23 f0       	add    $0xf0232020,%eax
f010019c:	39 c3                	cmp    %eax,%ebx
f010019e:	73 4d                	jae    f01001ed <i386_init+0xfd>
		if (c == cpus + cpunum())  // We've started already.
f01001a0:	e8 fd 4e 00 00       	call   f01050a2 <cpunum>
f01001a5:	6b c0 74             	imul   $0x74,%eax,%eax
f01001a8:	05 20 20 23 f0       	add    $0xf0232020,%eax
f01001ad:	39 c3                	cmp    %eax,%ebx
f01001af:	74 dc                	je     f010018d <i386_init+0x9d>
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f01001b1:	89 d8                	mov    %ebx,%eax
f01001b3:	2d 20 20 23 f0       	sub    $0xf0232020,%eax
f01001b8:	c1 f8 02             	sar    $0x2,%eax
f01001bb:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f01001c1:	c1 e0 0f             	shl    $0xf,%eax
f01001c4:	8d 80 00 b0 23 f0    	lea    -0xfdc5000(%eax),%eax
f01001ca:	a3 84 1e 23 f0       	mov    %eax,0xf0231e84
		lapic_startap(c->cpu_id, PADDR(code));
f01001cf:	83 ec 08             	sub    $0x8,%esp
f01001d2:	68 00 70 00 00       	push   $0x7000
f01001d7:	0f b6 03             	movzbl (%ebx),%eax
f01001da:	50                   	push   %eax
f01001db:	e8 2a 50 00 00       	call   f010520a <lapic_startap>
f01001e0:	83 c4 10             	add    $0x10,%esp
		while(c->cpu_status != CPU_STARTED)
f01001e3:	8b 43 04             	mov    0x4(%ebx),%eax
f01001e6:	83 f8 01             	cmp    $0x1,%eax
f01001e9:	75 f8                	jne    f01001e3 <i386_init+0xf3>
f01001eb:	eb a0                	jmp    f010018d <i386_init+0x9d>
	ENV_CREATE(user_primes, ENV_TYPE_USER);
f01001ed:	83 ec 08             	sub    $0x8,%esp
f01001f0:	6a 00                	push   $0x0
f01001f2:	68 c0 71 22 f0       	push   $0xf02271c0
f01001f7:	e8 19 30 00 00       	call   f0103215 <env_create>
	ENV_CREATE(user_yield, ENV_TYPE_USER);
f01001fc:	83 c4 08             	add    $0x8,%esp
f01001ff:	6a 00                	push   $0x0
f0100201:	68 b4 96 19 f0       	push   $0xf01996b4
f0100206:	e8 0a 30 00 00       	call   f0103215 <env_create>
	ENV_CREATE(user_yield, ENV_TYPE_USER);
f010020b:	83 c4 08             	add    $0x8,%esp
f010020e:	6a 00                	push   $0x0
f0100210:	68 b4 96 19 f0       	push   $0xf01996b4
f0100215:	e8 fb 2f 00 00       	call   f0103215 <env_create>
	ENV_CREATE(user_yield, ENV_TYPE_USER);
f010021a:	83 c4 08             	add    $0x8,%esp
f010021d:	6a 00                	push   $0x0
f010021f:	68 b4 96 19 f0       	push   $0xf01996b4
f0100224:	e8 ec 2f 00 00       	call   f0103215 <env_create>
	sched_yield();
f0100229:	e8 db 3b 00 00       	call   f0103e09 <sched_yield>

f010022e <mp_main>:
{
f010022e:	55                   	push   %ebp
f010022f:	89 e5                	mov    %esp,%ebp
f0100231:	83 ec 08             	sub    $0x8,%esp
	lcr3(PADDR(kern_pgdir));
f0100234:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f0100239:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010023e:	76 52                	jbe    f0100292 <mp_main+0x64>
	return (physaddr_t)kva - KERNBASE;
f0100240:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0100245:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f0100248:	e8 55 4e 00 00       	call   f01050a2 <cpunum>
f010024d:	83 ec 08             	sub    $0x8,%esp
f0100250:	50                   	push   %eax
f0100251:	68 5e 57 10 f0       	push   $0xf010575e
f0100256:	e8 97 35 00 00       	call   f01037f2 <cprintf>
	lapic_init();
f010025b:	e8 58 4e 00 00       	call   f01050b8 <lapic_init>
	env_init_percpu();
f0100260:	e8 b3 2d 00 00       	call   f0103018 <env_init_percpu>
	trap_init_percpu();
f0100265:	e8 9c 35 00 00       	call   f0103806 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f010026a:	e8 33 4e 00 00       	call   f01050a2 <cpunum>
f010026f:	6b d0 74             	imul   $0x74,%eax,%edx
f0100272:	83 c2 04             	add    $0x4,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0100275:	b8 01 00 00 00       	mov    $0x1,%eax
f010027a:	f0 87 82 20 20 23 f0 	lock xchg %eax,-0xfdcdfe0(%edx)
f0100281:	c7 04 24 c0 13 12 f0 	movl   $0xf01213c0,(%esp)
f0100288:	e8 85 50 00 00       	call   f0105312 <spin_lock>
	sched_yield();
f010028d:	e8 77 3b 00 00       	call   f0103e09 <sched_yield>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100292:	50                   	push   %eax
f0100293:	68 d8 57 10 f0       	push   $0xf01057d8
f0100298:	6a 75                	push   $0x75
f010029a:	68 52 57 10 f0       	push   $0xf0105752
f010029f:	e8 f0 fd ff ff       	call   f0100094 <_panic>

f01002a4 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f01002a4:	55                   	push   %ebp
f01002a5:	89 e5                	mov    %esp,%ebp
f01002a7:	53                   	push   %ebx
f01002a8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f01002ab:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f01002ae:	ff 75 0c             	pushl  0xc(%ebp)
f01002b1:	ff 75 08             	pushl  0x8(%ebp)
f01002b4:	68 74 57 10 f0       	push   $0xf0105774
f01002b9:	e8 34 35 00 00       	call   f01037f2 <cprintf>
	vcprintf(fmt, ap);
f01002be:	83 c4 08             	add    $0x8,%esp
f01002c1:	53                   	push   %ebx
f01002c2:	ff 75 10             	pushl  0x10(%ebp)
f01002c5:	e8 02 35 00 00       	call   f01037cc <vcprintf>
	cprintf("\n");
f01002ca:	c7 04 24 0b 69 10 f0 	movl   $0xf010690b,(%esp)
f01002d1:	e8 1c 35 00 00       	call   f01037f2 <cprintf>
	va_end(ap);
}
f01002d6:	83 c4 10             	add    $0x10,%esp
f01002d9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01002dc:	c9                   	leave  
f01002dd:	c3                   	ret    

f01002de <serial_proc_data>:
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002de:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01002e3:	ec                   	in     (%dx),%al
static bool serial_exists;

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01002e4:	a8 01                	test   $0x1,%al
f01002e6:	74 0a                	je     f01002f2 <serial_proc_data+0x14>
f01002e8:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01002ed:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01002ee:	0f b6 c0             	movzbl %al,%eax
f01002f1:	c3                   	ret    
		return -1;
f01002f2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f01002f7:	c3                   	ret    

f01002f8 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01002f8:	55                   	push   %ebp
f01002f9:	89 e5                	mov    %esp,%ebp
f01002fb:	53                   	push   %ebx
f01002fc:	83 ec 04             	sub    $0x4,%esp
f01002ff:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100301:	ff d3                	call   *%ebx
f0100303:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100306:	74 29                	je     f0100331 <cons_intr+0x39>
		if (c == 0)
f0100308:	85 c0                	test   %eax,%eax
f010030a:	74 f5                	je     f0100301 <cons_intr+0x9>
			continue;
		cons.buf[cons.wpos++] = c;
f010030c:	8b 0d 24 12 23 f0    	mov    0xf0231224,%ecx
f0100312:	8d 51 01             	lea    0x1(%ecx),%edx
f0100315:	88 81 20 10 23 f0    	mov    %al,-0xfdcefe0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f010031b:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.wpos = 0;
f0100321:	b8 00 00 00 00       	mov    $0x0,%eax
f0100326:	0f 44 d0             	cmove  %eax,%edx
f0100329:	89 15 24 12 23 f0    	mov    %edx,0xf0231224
f010032f:	eb d0                	jmp    f0100301 <cons_intr+0x9>
	}
}
f0100331:	83 c4 04             	add    $0x4,%esp
f0100334:	5b                   	pop    %ebx
f0100335:	5d                   	pop    %ebp
f0100336:	c3                   	ret    

f0100337 <kbd_proc_data>:
{
f0100337:	55                   	push   %ebp
f0100338:	89 e5                	mov    %esp,%ebp
f010033a:	53                   	push   %ebx
f010033b:	83 ec 04             	sub    $0x4,%esp
f010033e:	ba 64 00 00 00       	mov    $0x64,%edx
f0100343:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f0100344:	a8 01                	test   $0x1,%al
f0100346:	0f 84 f2 00 00 00    	je     f010043e <kbd_proc_data+0x107>
	if (stat & KBS_TERR)
f010034c:	a8 20                	test   $0x20,%al
f010034e:	0f 85 f1 00 00 00    	jne    f0100445 <kbd_proc_data+0x10e>
f0100354:	ba 60 00 00 00       	mov    $0x60,%edx
f0100359:	ec                   	in     (%dx),%al
f010035a:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f010035c:	3c e0                	cmp    $0xe0,%al
f010035e:	74 61                	je     f01003c1 <kbd_proc_data+0x8a>
	} else if (data & 0x80) {
f0100360:	84 c0                	test   %al,%al
f0100362:	78 70                	js     f01003d4 <kbd_proc_data+0x9d>
	} else if (shift & E0ESC) {
f0100364:	8b 0d 00 10 23 f0    	mov    0xf0231000,%ecx
f010036a:	f6 c1 40             	test   $0x40,%cl
f010036d:	74 0e                	je     f010037d <kbd_proc_data+0x46>
		data |= 0x80;
f010036f:	83 c8 80             	or     $0xffffff80,%eax
f0100372:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100374:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100377:	89 0d 00 10 23 f0    	mov    %ecx,0xf0231000
	shift |= shiftcode[data];
f010037d:	0f b6 d2             	movzbl %dl,%edx
f0100380:	0f b6 82 60 59 10 f0 	movzbl -0xfefa6a0(%edx),%eax
f0100387:	0b 05 00 10 23 f0    	or     0xf0231000,%eax
	shift ^= togglecode[data];
f010038d:	0f b6 8a 60 58 10 f0 	movzbl -0xfefa7a0(%edx),%ecx
f0100394:	31 c8                	xor    %ecx,%eax
f0100396:	a3 00 10 23 f0       	mov    %eax,0xf0231000
	c = charcode[shift & (CTL | SHIFT)][data];
f010039b:	89 c1                	mov    %eax,%ecx
f010039d:	83 e1 03             	and    $0x3,%ecx
f01003a0:	8b 0c 8d 40 58 10 f0 	mov    -0xfefa7c0(,%ecx,4),%ecx
f01003a7:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f01003ab:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f01003ae:	a8 08                	test   $0x8,%al
f01003b0:	74 61                	je     f0100413 <kbd_proc_data+0xdc>
		if ('a' <= c && c <= 'z')
f01003b2:	89 da                	mov    %ebx,%edx
f01003b4:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f01003b7:	83 f9 19             	cmp    $0x19,%ecx
f01003ba:	77 4b                	ja     f0100407 <kbd_proc_data+0xd0>
			c += 'A' - 'a';
f01003bc:	83 eb 20             	sub    $0x20,%ebx
f01003bf:	eb 0c                	jmp    f01003cd <kbd_proc_data+0x96>
		shift |= E0ESC;
f01003c1:	83 0d 00 10 23 f0 40 	orl    $0x40,0xf0231000
		return 0;
f01003c8:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f01003cd:	89 d8                	mov    %ebx,%eax
f01003cf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01003d2:	c9                   	leave  
f01003d3:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f01003d4:	8b 0d 00 10 23 f0    	mov    0xf0231000,%ecx
f01003da:	89 cb                	mov    %ecx,%ebx
f01003dc:	83 e3 40             	and    $0x40,%ebx
f01003df:	83 e0 7f             	and    $0x7f,%eax
f01003e2:	85 db                	test   %ebx,%ebx
f01003e4:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01003e7:	0f b6 d2             	movzbl %dl,%edx
f01003ea:	0f b6 82 60 59 10 f0 	movzbl -0xfefa6a0(%edx),%eax
f01003f1:	83 c8 40             	or     $0x40,%eax
f01003f4:	0f b6 c0             	movzbl %al,%eax
f01003f7:	f7 d0                	not    %eax
f01003f9:	21 c8                	and    %ecx,%eax
f01003fb:	a3 00 10 23 f0       	mov    %eax,0xf0231000
		return 0;
f0100400:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100405:	eb c6                	jmp    f01003cd <kbd_proc_data+0x96>
		else if ('A' <= c && c <= 'Z')
f0100407:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f010040a:	8d 4b 20             	lea    0x20(%ebx),%ecx
f010040d:	83 fa 1a             	cmp    $0x1a,%edx
f0100410:	0f 42 d9             	cmovb  %ecx,%ebx
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100413:	f7 d0                	not    %eax
f0100415:	a8 06                	test   $0x6,%al
f0100417:	75 b4                	jne    f01003cd <kbd_proc_data+0x96>
f0100419:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f010041f:	75 ac                	jne    f01003cd <kbd_proc_data+0x96>
		cprintf("Rebooting!\n");
f0100421:	83 ec 0c             	sub    $0xc,%esp
f0100424:	68 fc 57 10 f0       	push   $0xf01057fc
f0100429:	e8 c4 33 00 00       	call   f01037f2 <cprintf>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010042e:	b8 03 00 00 00       	mov    $0x3,%eax
f0100433:	ba 92 00 00 00       	mov    $0x92,%edx
f0100438:	ee                   	out    %al,(%dx)
f0100439:	83 c4 10             	add    $0x10,%esp
f010043c:	eb 8f                	jmp    f01003cd <kbd_proc_data+0x96>
		return -1;
f010043e:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f0100443:	eb 88                	jmp    f01003cd <kbd_proc_data+0x96>
		return -1;
f0100445:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f010044a:	eb 81                	jmp    f01003cd <kbd_proc_data+0x96>

f010044c <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f010044c:	55                   	push   %ebp
f010044d:	89 e5                	mov    %esp,%ebp
f010044f:	57                   	push   %edi
f0100450:	56                   	push   %esi
f0100451:	53                   	push   %ebx
f0100452:	83 ec 1c             	sub    $0x1c,%esp
f0100455:	89 c1                	mov    %eax,%ecx
	for (i = 0;
f0100457:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010045c:	bf fd 03 00 00       	mov    $0x3fd,%edi
f0100461:	bb 84 00 00 00       	mov    $0x84,%ebx
f0100466:	89 fa                	mov    %edi,%edx
f0100468:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100469:	a8 20                	test   $0x20,%al
f010046b:	75 13                	jne    f0100480 <cons_putc+0x34>
f010046d:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f0100473:	7f 0b                	jg     f0100480 <cons_putc+0x34>
f0100475:	89 da                	mov    %ebx,%edx
f0100477:	ec                   	in     (%dx),%al
f0100478:	ec                   	in     (%dx),%al
f0100479:	ec                   	in     (%dx),%al
f010047a:	ec                   	in     (%dx),%al
	     i++)
f010047b:	83 c6 01             	add    $0x1,%esi
f010047e:	eb e6                	jmp    f0100466 <cons_putc+0x1a>
	outb(COM1 + COM_TX, c);
f0100480:	88 4d e7             	mov    %cl,-0x19(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100483:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100488:	89 c8                	mov    %ecx,%eax
f010048a:	ee                   	out    %al,(%dx)
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010048b:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100490:	bf 79 03 00 00       	mov    $0x379,%edi
f0100495:	bb 84 00 00 00       	mov    $0x84,%ebx
f010049a:	89 fa                	mov    %edi,%edx
f010049c:	ec                   	in     (%dx),%al
f010049d:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f01004a3:	7f 0f                	jg     f01004b4 <cons_putc+0x68>
f01004a5:	84 c0                	test   %al,%al
f01004a7:	78 0b                	js     f01004b4 <cons_putc+0x68>
f01004a9:	89 da                	mov    %ebx,%edx
f01004ab:	ec                   	in     (%dx),%al
f01004ac:	ec                   	in     (%dx),%al
f01004ad:	ec                   	in     (%dx),%al
f01004ae:	ec                   	in     (%dx),%al
f01004af:	83 c6 01             	add    $0x1,%esi
f01004b2:	eb e6                	jmp    f010049a <cons_putc+0x4e>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01004b4:	ba 78 03 00 00       	mov    $0x378,%edx
f01004b9:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f01004bd:	ee                   	out    %al,(%dx)
f01004be:	ba 7a 03 00 00       	mov    $0x37a,%edx
f01004c3:	b8 0d 00 00 00       	mov    $0xd,%eax
f01004c8:	ee                   	out    %al,(%dx)
f01004c9:	b8 08 00 00 00       	mov    $0x8,%eax
f01004ce:	ee                   	out    %al,(%dx)
	if (!(c & ~0xFF))
f01004cf:	89 ca                	mov    %ecx,%edx
f01004d1:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f01004d7:	89 c8                	mov    %ecx,%eax
f01004d9:	80 cc 07             	or     $0x7,%ah
f01004dc:	85 d2                	test   %edx,%edx
f01004de:	0f 44 c8             	cmove  %eax,%ecx
	switch (c & 0xff) {
f01004e1:	0f b6 c1             	movzbl %cl,%eax
f01004e4:	83 f8 09             	cmp    $0x9,%eax
f01004e7:	0f 84 b0 00 00 00    	je     f010059d <cons_putc+0x151>
f01004ed:	7e 73                	jle    f0100562 <cons_putc+0x116>
f01004ef:	83 f8 0a             	cmp    $0xa,%eax
f01004f2:	0f 84 98 00 00 00    	je     f0100590 <cons_putc+0x144>
f01004f8:	83 f8 0d             	cmp    $0xd,%eax
f01004fb:	0f 85 d3 00 00 00    	jne    f01005d4 <cons_putc+0x188>
		crt_pos -= (crt_pos % CRT_COLS);
f0100501:	0f b7 05 28 12 23 f0 	movzwl 0xf0231228,%eax
f0100508:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f010050e:	c1 e8 16             	shr    $0x16,%eax
f0100511:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100514:	c1 e0 04             	shl    $0x4,%eax
f0100517:	66 a3 28 12 23 f0    	mov    %ax,0xf0231228
	if (crt_pos >= CRT_SIZE) {
f010051d:	66 81 3d 28 12 23 f0 	cmpw   $0x7cf,0xf0231228
f0100524:	cf 07 
f0100526:	0f 87 cb 00 00 00    	ja     f01005f7 <cons_putc+0x1ab>
	outb(addr_6845, 14);
f010052c:	8b 0d 30 12 23 f0    	mov    0xf0231230,%ecx
f0100532:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100537:	89 ca                	mov    %ecx,%edx
f0100539:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f010053a:	0f b7 1d 28 12 23 f0 	movzwl 0xf0231228,%ebx
f0100541:	8d 71 01             	lea    0x1(%ecx),%esi
f0100544:	89 d8                	mov    %ebx,%eax
f0100546:	66 c1 e8 08          	shr    $0x8,%ax
f010054a:	89 f2                	mov    %esi,%edx
f010054c:	ee                   	out    %al,(%dx)
f010054d:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100552:	89 ca                	mov    %ecx,%edx
f0100554:	ee                   	out    %al,(%dx)
f0100555:	89 d8                	mov    %ebx,%eax
f0100557:	89 f2                	mov    %esi,%edx
f0100559:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f010055a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010055d:	5b                   	pop    %ebx
f010055e:	5e                   	pop    %esi
f010055f:	5f                   	pop    %edi
f0100560:	5d                   	pop    %ebp
f0100561:	c3                   	ret    
	switch (c & 0xff) {
f0100562:	83 f8 08             	cmp    $0x8,%eax
f0100565:	75 6d                	jne    f01005d4 <cons_putc+0x188>
		if (crt_pos > 0) {
f0100567:	0f b7 05 28 12 23 f0 	movzwl 0xf0231228,%eax
f010056e:	66 85 c0             	test   %ax,%ax
f0100571:	74 b9                	je     f010052c <cons_putc+0xe0>
			crt_pos--;
f0100573:	83 e8 01             	sub    $0x1,%eax
f0100576:	66 a3 28 12 23 f0    	mov    %ax,0xf0231228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010057c:	0f b7 c0             	movzwl %ax,%eax
f010057f:	b1 00                	mov    $0x0,%cl
f0100581:	83 c9 20             	or     $0x20,%ecx
f0100584:	8b 15 2c 12 23 f0    	mov    0xf023122c,%edx
f010058a:	66 89 0c 42          	mov    %cx,(%edx,%eax,2)
f010058e:	eb 8d                	jmp    f010051d <cons_putc+0xd1>
		crt_pos += CRT_COLS;
f0100590:	66 83 05 28 12 23 f0 	addw   $0x50,0xf0231228
f0100597:	50 
f0100598:	e9 64 ff ff ff       	jmp    f0100501 <cons_putc+0xb5>
		cons_putc(' ');
f010059d:	b8 20 00 00 00       	mov    $0x20,%eax
f01005a2:	e8 a5 fe ff ff       	call   f010044c <cons_putc>
		cons_putc(' ');
f01005a7:	b8 20 00 00 00       	mov    $0x20,%eax
f01005ac:	e8 9b fe ff ff       	call   f010044c <cons_putc>
		cons_putc(' ');
f01005b1:	b8 20 00 00 00       	mov    $0x20,%eax
f01005b6:	e8 91 fe ff ff       	call   f010044c <cons_putc>
		cons_putc(' ');
f01005bb:	b8 20 00 00 00       	mov    $0x20,%eax
f01005c0:	e8 87 fe ff ff       	call   f010044c <cons_putc>
		cons_putc(' ');
f01005c5:	b8 20 00 00 00       	mov    $0x20,%eax
f01005ca:	e8 7d fe ff ff       	call   f010044c <cons_putc>
f01005cf:	e9 49 ff ff ff       	jmp    f010051d <cons_putc+0xd1>
		crt_buf[crt_pos++] = c;		/* write the character */
f01005d4:	0f b7 05 28 12 23 f0 	movzwl 0xf0231228,%eax
f01005db:	8d 50 01             	lea    0x1(%eax),%edx
f01005de:	66 89 15 28 12 23 f0 	mov    %dx,0xf0231228
f01005e5:	0f b7 c0             	movzwl %ax,%eax
f01005e8:	8b 15 2c 12 23 f0    	mov    0xf023122c,%edx
f01005ee:	66 89 0c 42          	mov    %cx,(%edx,%eax,2)
f01005f2:	e9 26 ff ff ff       	jmp    f010051d <cons_putc+0xd1>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01005f7:	a1 2c 12 23 f0       	mov    0xf023122c,%eax
f01005fc:	83 ec 04             	sub    $0x4,%esp
f01005ff:	68 00 0f 00 00       	push   $0xf00
f0100604:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010060a:	52                   	push   %edx
f010060b:	50                   	push   %eax
f010060c:	e8 db 44 00 00       	call   f0104aec <memmove>
			crt_buf[i] = 0x0700 | ' ';
f0100611:	8b 15 2c 12 23 f0    	mov    0xf023122c,%edx
f0100617:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f010061d:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100623:	83 c4 10             	add    $0x10,%esp
f0100626:	66 c7 00 20 07       	movw   $0x720,(%eax)
f010062b:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010062e:	39 d0                	cmp    %edx,%eax
f0100630:	75 f4                	jne    f0100626 <cons_putc+0x1da>
		crt_pos -= CRT_COLS;
f0100632:	66 83 2d 28 12 23 f0 	subw   $0x50,0xf0231228
f0100639:	50 
f010063a:	e9 ed fe ff ff       	jmp    f010052c <cons_putc+0xe0>

f010063f <serial_intr>:
	if (serial_exists)
f010063f:	80 3d 34 12 23 f0 00 	cmpb   $0x0,0xf0231234
f0100646:	75 01                	jne    f0100649 <serial_intr+0xa>
f0100648:	c3                   	ret    
{
f0100649:	55                   	push   %ebp
f010064a:	89 e5                	mov    %esp,%ebp
f010064c:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f010064f:	b8 de 02 10 f0       	mov    $0xf01002de,%eax
f0100654:	e8 9f fc ff ff       	call   f01002f8 <cons_intr>
}
f0100659:	c9                   	leave  
f010065a:	c3                   	ret    

f010065b <kbd_intr>:
{
f010065b:	55                   	push   %ebp
f010065c:	89 e5                	mov    %esp,%ebp
f010065e:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100661:	b8 37 03 10 f0       	mov    $0xf0100337,%eax
f0100666:	e8 8d fc ff ff       	call   f01002f8 <cons_intr>
}
f010066b:	c9                   	leave  
f010066c:	c3                   	ret    

f010066d <cons_getc>:
{
f010066d:	55                   	push   %ebp
f010066e:	89 e5                	mov    %esp,%ebp
f0100670:	83 ec 08             	sub    $0x8,%esp
	serial_intr();
f0100673:	e8 c7 ff ff ff       	call   f010063f <serial_intr>
	kbd_intr();
f0100678:	e8 de ff ff ff       	call   f010065b <kbd_intr>
	if (cons.rpos != cons.wpos) {
f010067d:	8b 15 20 12 23 f0    	mov    0xf0231220,%edx
	return 0;
f0100683:	b8 00 00 00 00       	mov    $0x0,%eax
	if (cons.rpos != cons.wpos) {
f0100688:	3b 15 24 12 23 f0    	cmp    0xf0231224,%edx
f010068e:	74 1e                	je     f01006ae <cons_getc+0x41>
		c = cons.buf[cons.rpos++];
f0100690:	8d 4a 01             	lea    0x1(%edx),%ecx
f0100693:	0f b6 82 20 10 23 f0 	movzbl -0xfdcefe0(%edx),%eax
			cons.rpos = 0;
f010069a:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f01006a0:	ba 00 00 00 00       	mov    $0x0,%edx
f01006a5:	0f 44 ca             	cmove  %edx,%ecx
f01006a8:	89 0d 20 12 23 f0    	mov    %ecx,0xf0231220
}
f01006ae:	c9                   	leave  
f01006af:	c3                   	ret    

f01006b0 <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f01006b0:	55                   	push   %ebp
f01006b1:	89 e5                	mov    %esp,%ebp
f01006b3:	57                   	push   %edi
f01006b4:	56                   	push   %esi
f01006b5:	53                   	push   %ebx
f01006b6:	83 ec 0c             	sub    $0xc,%esp
	was = *cp;
f01006b9:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f01006c0:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f01006c7:	5a a5 
	if (*cp != 0xA55A) {
f01006c9:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f01006d0:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01006d4:	0f 84 d4 00 00 00    	je     f01007ae <cons_init+0xfe>
		addr_6845 = MONO_BASE;
f01006da:	c7 05 30 12 23 f0 b4 	movl   $0x3b4,0xf0231230
f01006e1:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f01006e4:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
	outb(addr_6845, 14);
f01006e9:	8b 3d 30 12 23 f0    	mov    0xf0231230,%edi
f01006ef:	b8 0e 00 00 00       	mov    $0xe,%eax
f01006f4:	89 fa                	mov    %edi,%edx
f01006f6:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01006f7:	8d 4f 01             	lea    0x1(%edi),%ecx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006fa:	89 ca                	mov    %ecx,%edx
f01006fc:	ec                   	in     (%dx),%al
f01006fd:	0f b6 c0             	movzbl %al,%eax
f0100700:	c1 e0 08             	shl    $0x8,%eax
f0100703:	89 c3                	mov    %eax,%ebx
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100705:	b8 0f 00 00 00       	mov    $0xf,%eax
f010070a:	89 fa                	mov    %edi,%edx
f010070c:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010070d:	89 ca                	mov    %ecx,%edx
f010070f:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f0100710:	89 35 2c 12 23 f0    	mov    %esi,0xf023122c
	pos |= inb(addr_6845 + 1);
f0100716:	0f b6 c0             	movzbl %al,%eax
f0100719:	09 d8                	or     %ebx,%eax
	crt_pos = pos;
f010071b:	66 a3 28 12 23 f0    	mov    %ax,0xf0231228
	kbd_intr();
f0100721:	e8 35 ff ff ff       	call   f010065b <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_KBD));
f0100726:	83 ec 0c             	sub    $0xc,%esp
f0100729:	0f b7 05 a8 13 12 f0 	movzwl 0xf01213a8,%eax
f0100730:	25 fd ff 00 00       	and    $0xfffd,%eax
f0100735:	50                   	push   %eax
f0100736:	e8 5a 2f 00 00       	call   f0103695 <irq_setmask_8259A>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010073b:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100740:	b9 fa 03 00 00       	mov    $0x3fa,%ecx
f0100745:	89 d8                	mov    %ebx,%eax
f0100747:	89 ca                	mov    %ecx,%edx
f0100749:	ee                   	out    %al,(%dx)
f010074a:	bf fb 03 00 00       	mov    $0x3fb,%edi
f010074f:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100754:	89 fa                	mov    %edi,%edx
f0100756:	ee                   	out    %al,(%dx)
f0100757:	b8 0c 00 00 00       	mov    $0xc,%eax
f010075c:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100761:	ee                   	out    %al,(%dx)
f0100762:	be f9 03 00 00       	mov    $0x3f9,%esi
f0100767:	89 d8                	mov    %ebx,%eax
f0100769:	89 f2                	mov    %esi,%edx
f010076b:	ee                   	out    %al,(%dx)
f010076c:	b8 03 00 00 00       	mov    $0x3,%eax
f0100771:	89 fa                	mov    %edi,%edx
f0100773:	ee                   	out    %al,(%dx)
f0100774:	ba fc 03 00 00       	mov    $0x3fc,%edx
f0100779:	89 d8                	mov    %ebx,%eax
f010077b:	ee                   	out    %al,(%dx)
f010077c:	b8 01 00 00 00       	mov    $0x1,%eax
f0100781:	89 f2                	mov    %esi,%edx
f0100783:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100784:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100789:	ec                   	in     (%dx),%al
f010078a:	89 c3                	mov    %eax,%ebx
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f010078c:	83 c4 10             	add    $0x10,%esp
f010078f:	3c ff                	cmp    $0xff,%al
f0100791:	0f 95 05 34 12 23 f0 	setne  0xf0231234
f0100798:	89 ca                	mov    %ecx,%edx
f010079a:	ec                   	in     (%dx),%al
f010079b:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01007a0:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01007a1:	80 fb ff             	cmp    $0xff,%bl
f01007a4:	74 23                	je     f01007c9 <cons_init+0x119>
		cprintf("Serial port does not exist!\n");
}
f01007a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01007a9:	5b                   	pop    %ebx
f01007aa:	5e                   	pop    %esi
f01007ab:	5f                   	pop    %edi
f01007ac:	5d                   	pop    %ebp
f01007ad:	c3                   	ret    
		*cp = was;
f01007ae:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01007b5:	c7 05 30 12 23 f0 d4 	movl   $0x3d4,0xf0231230
f01007bc:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01007bf:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
f01007c4:	e9 20 ff ff ff       	jmp    f01006e9 <cons_init+0x39>
		cprintf("Serial port does not exist!\n");
f01007c9:	83 ec 0c             	sub    $0xc,%esp
f01007cc:	68 08 58 10 f0       	push   $0xf0105808
f01007d1:	e8 1c 30 00 00       	call   f01037f2 <cprintf>
f01007d6:	83 c4 10             	add    $0x10,%esp
}
f01007d9:	eb cb                	jmp    f01007a6 <cons_init+0xf6>

f01007db <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01007db:	55                   	push   %ebp
f01007dc:	89 e5                	mov    %esp,%ebp
f01007de:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01007e1:	8b 45 08             	mov    0x8(%ebp),%eax
f01007e4:	e8 63 fc ff ff       	call   f010044c <cons_putc>
}
f01007e9:	c9                   	leave  
f01007ea:	c3                   	ret    

f01007eb <getchar>:

int
getchar(void)
{
f01007eb:	55                   	push   %ebp
f01007ec:	89 e5                	mov    %esp,%ebp
f01007ee:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01007f1:	e8 77 fe ff ff       	call   f010066d <cons_getc>
f01007f6:	85 c0                	test   %eax,%eax
f01007f8:	74 f7                	je     f01007f1 <getchar+0x6>
		/* do nothing */;
	return c;
}
f01007fa:	c9                   	leave  
f01007fb:	c3                   	ret    

f01007fc <iscons>:
int
iscons(int fdnum)
{
	// used by readline
	return 1;
}
f01007fc:	b8 01 00 00 00       	mov    $0x1,%eax
f0100801:	c3                   	ret    

f0100802 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100802:	55                   	push   %ebp
f0100803:	89 e5                	mov    %esp,%ebp
f0100805:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100808:	68 60 5a 10 f0       	push   $0xf0105a60
f010080d:	68 7e 5a 10 f0       	push   $0xf0105a7e
f0100812:	68 83 5a 10 f0       	push   $0xf0105a83
f0100817:	e8 d6 2f 00 00       	call   f01037f2 <cprintf>
f010081c:	83 c4 0c             	add    $0xc,%esp
f010081f:	68 30 5b 10 f0       	push   $0xf0105b30
f0100824:	68 8c 5a 10 f0       	push   $0xf0105a8c
f0100829:	68 83 5a 10 f0       	push   $0xf0105a83
f010082e:	e8 bf 2f 00 00       	call   f01037f2 <cprintf>
f0100833:	83 c4 0c             	add    $0xc,%esp
f0100836:	68 95 5a 10 f0       	push   $0xf0105a95
f010083b:	68 ac 5a 10 f0       	push   $0xf0105aac
f0100840:	68 83 5a 10 f0       	push   $0xf0105a83
f0100845:	e8 a8 2f 00 00       	call   f01037f2 <cprintf>
	return 0;
}
f010084a:	b8 00 00 00 00       	mov    $0x0,%eax
f010084f:	c9                   	leave  
f0100850:	c3                   	ret    

f0100851 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100851:	55                   	push   %ebp
f0100852:	89 e5                	mov    %esp,%ebp
f0100854:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100857:	68 b6 5a 10 f0       	push   $0xf0105ab6
f010085c:	e8 91 2f 00 00       	call   f01037f2 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100861:	83 c4 08             	add    $0x8,%esp
f0100864:	68 0c 00 10 00       	push   $0x10000c
f0100869:	68 58 5b 10 f0       	push   $0xf0105b58
f010086e:	e8 7f 2f 00 00       	call   f01037f2 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100873:	83 c4 0c             	add    $0xc,%esp
f0100876:	68 0c 00 10 00       	push   $0x10000c
f010087b:	68 0c 00 10 f0       	push   $0xf010000c
f0100880:	68 80 5b 10 f0       	push   $0xf0105b80
f0100885:	e8 68 2f 00 00       	call   f01037f2 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010088a:	83 c4 0c             	add    $0xc,%esp
f010088d:	68 ef 56 10 00       	push   $0x1056ef
f0100892:	68 ef 56 10 f0       	push   $0xf01056ef
f0100897:	68 a4 5b 10 f0       	push   $0xf0105ba4
f010089c:	e8 51 2f 00 00       	call   f01037f2 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01008a1:	83 c4 0c             	add    $0xc,%esp
f01008a4:	68 00 10 23 00       	push   $0x231000
f01008a9:	68 00 10 23 f0       	push   $0xf0231000
f01008ae:	68 c8 5b 10 f0       	push   $0xf0105bc8
f01008b3:	e8 3a 2f 00 00       	call   f01037f2 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01008b8:	83 c4 0c             	add    $0xc,%esp
f01008bb:	68 08 30 27 00       	push   $0x273008
f01008c0:	68 08 30 27 f0       	push   $0xf0273008
f01008c5:	68 ec 5b 10 f0       	push   $0xf0105bec
f01008ca:	e8 23 2f 00 00       	call   f01037f2 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f01008cf:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f01008d2:	b8 08 30 27 f0       	mov    $0xf0273008,%eax
f01008d7:	2d 0d fc 0f f0       	sub    $0xf00ffc0d,%eax
	cprintf("Kernel executable memory footprint: %dKB\n",
f01008dc:	c1 f8 0a             	sar    $0xa,%eax
f01008df:	50                   	push   %eax
f01008e0:	68 10 5c 10 f0       	push   $0xf0105c10
f01008e5:	e8 08 2f 00 00       	call   f01037f2 <cprintf>
	return 0;
}
f01008ea:	b8 00 00 00 00       	mov    $0x0,%eax
f01008ef:	c9                   	leave  
f01008f0:	c3                   	ret    

f01008f1 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01008f1:	55                   	push   %ebp
f01008f2:	89 e5                	mov    %esp,%ebp
f01008f4:	57                   	push   %edi
f01008f5:	56                   	push   %esi
f01008f6:	53                   	push   %ebx
f01008f7:	83 ec 38             	sub    $0x38,%esp
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f01008fa:	89 eb                	mov    %ebp,%ebx
	// Your code here.
	uint32_t ebp, *ptr_ebp;
	ebp = read_ebp();
	cprintf("Stack backtrace:\n");
f01008fc:	68 cf 5a 10 f0       	push   $0xf0105acf
f0100901:	e8 ec 2e 00 00       	call   f01037f2 <cprintf>
	while (ebp != 0) {
f0100906:	83 c4 10             	add    $0x10,%esp
		ptr_ebp = (uint32_t *)ebp;
		cprintf(" ebp %x  eip %x  args %08x %08x %08x %08x %08x\n", 
        		ebp, ptr_ebp[1], ptr_ebp[2], ptr_ebp[3], ptr_ebp[4], ptr_ebp[5], ptr_ebp[6]);
		struct Eipdebuginfo info;
		if (debuginfo_eip(ptr_ebp[1], &info) == 0) {
f0100909:	8d 7d d0             	lea    -0x30(%ebp),%edi
	while (ebp != 0) {
f010090c:	eb 25                	jmp    f0100933 <mon_backtrace+0x42>
			uint32_t fn_offset = ptr_ebp[1] - info.eip_fn_addr; 
			cprintf(" \t%s:%d: %.*s+%d\n", info.eip_file, info.eip_line\
f010090e:	83 ec 08             	sub    $0x8,%esp
			uint32_t fn_offset = ptr_ebp[1] - info.eip_fn_addr; 
f0100911:	8b 43 04             	mov    0x4(%ebx),%eax
f0100914:	2b 45 e0             	sub    -0x20(%ebp),%eax
			cprintf(" \t%s:%d: %.*s+%d\n", info.eip_file, info.eip_line\
f0100917:	50                   	push   %eax
f0100918:	ff 75 d8             	pushl  -0x28(%ebp)
f010091b:	ff 75 dc             	pushl  -0x24(%ebp)
f010091e:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100921:	ff 75 d0             	pushl  -0x30(%ebp)
f0100924:	68 e1 5a 10 f0       	push   $0xf0105ae1
f0100929:	e8 c4 2e 00 00       	call   f01037f2 <cprintf>
f010092e:	83 c4 20             	add    $0x20,%esp
							, info.eip_fn_namelen, info.eip_fn_name, fn_offset);
		}
		ebp = *ptr_ebp;
f0100931:	8b 1e                	mov    (%esi),%ebx
	while (ebp != 0) {
f0100933:	85 db                	test   %ebx,%ebx
f0100935:	74 34                	je     f010096b <mon_backtrace+0x7a>
		ptr_ebp = (uint32_t *)ebp;
f0100937:	89 de                	mov    %ebx,%esi
		cprintf(" ebp %x  eip %x  args %08x %08x %08x %08x %08x\n", 
f0100939:	ff 73 18             	pushl  0x18(%ebx)
f010093c:	ff 73 14             	pushl  0x14(%ebx)
f010093f:	ff 73 10             	pushl  0x10(%ebx)
f0100942:	ff 73 0c             	pushl  0xc(%ebx)
f0100945:	ff 73 08             	pushl  0x8(%ebx)
f0100948:	ff 73 04             	pushl  0x4(%ebx)
f010094b:	53                   	push   %ebx
f010094c:	68 3c 5c 10 f0       	push   $0xf0105c3c
f0100951:	e8 9c 2e 00 00       	call   f01037f2 <cprintf>
		if (debuginfo_eip(ptr_ebp[1], &info) == 0) {
f0100956:	83 c4 18             	add    $0x18,%esp
f0100959:	57                   	push   %edi
f010095a:	ff 73 04             	pushl  0x4(%ebx)
f010095d:	e8 03 37 00 00       	call   f0104065 <debuginfo_eip>
f0100962:	83 c4 10             	add    $0x10,%esp
f0100965:	85 c0                	test   %eax,%eax
f0100967:	75 c8                	jne    f0100931 <mon_backtrace+0x40>
f0100969:	eb a3                	jmp    f010090e <mon_backtrace+0x1d>
	}
	return 0;
}
f010096b:	b8 00 00 00 00       	mov    $0x0,%eax
f0100970:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100973:	5b                   	pop    %ebx
f0100974:	5e                   	pop    %esi
f0100975:	5f                   	pop    %edi
f0100976:	5d                   	pop    %ebp
f0100977:	c3                   	ret    

f0100978 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100978:	55                   	push   %ebp
f0100979:	89 e5                	mov    %esp,%ebp
f010097b:	57                   	push   %edi
f010097c:	56                   	push   %esi
f010097d:	53                   	push   %ebx
f010097e:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100981:	68 6c 5c 10 f0       	push   $0xf0105c6c
f0100986:	e8 67 2e 00 00       	call   f01037f2 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f010098b:	c7 04 24 90 5c 10 f0 	movl   $0xf0105c90,(%esp)
f0100992:	e8 5b 2e 00 00       	call   f01037f2 <cprintf>

	if (tf != NULL)
f0100997:	83 c4 10             	add    $0x10,%esp
f010099a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f010099e:	0f 84 d9 00 00 00    	je     f0100a7d <monitor+0x105>
		print_trapframe(tf);
f01009a4:	83 ec 0c             	sub    $0xc,%esp
f01009a7:	ff 75 08             	pushl  0x8(%ebp)
f01009aa:	e8 bc 2f 00 00       	call   f010396b <print_trapframe>
f01009af:	83 c4 10             	add    $0x10,%esp
f01009b2:	e9 c6 00 00 00       	jmp    f0100a7d <monitor+0x105>
		while (*buf && strchr(WHITESPACE, *buf))
f01009b7:	83 ec 08             	sub    $0x8,%esp
f01009ba:	0f be c0             	movsbl %al,%eax
f01009bd:	50                   	push   %eax
f01009be:	68 f7 5a 10 f0       	push   $0xf0105af7
f01009c3:	e8 9f 40 00 00       	call   f0104a67 <strchr>
f01009c8:	83 c4 10             	add    $0x10,%esp
f01009cb:	85 c0                	test   %eax,%eax
f01009cd:	74 63                	je     f0100a32 <monitor+0xba>
			*buf++ = 0;
f01009cf:	c6 03 00             	movb   $0x0,(%ebx)
f01009d2:	89 f7                	mov    %esi,%edi
f01009d4:	8d 5b 01             	lea    0x1(%ebx),%ebx
f01009d7:	89 fe                	mov    %edi,%esi
		while (*buf && strchr(WHITESPACE, *buf))
f01009d9:	0f b6 03             	movzbl (%ebx),%eax
f01009dc:	84 c0                	test   %al,%al
f01009de:	75 d7                	jne    f01009b7 <monitor+0x3f>
	argv[argc] = 0;
f01009e0:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f01009e7:	00 
	if (argc == 0)
f01009e8:	85 f6                	test   %esi,%esi
f01009ea:	0f 84 8d 00 00 00    	je     f0100a7d <monitor+0x105>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f01009f0:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (strcmp(argv[0], commands[i].name) == 0)
f01009f5:	83 ec 08             	sub    $0x8,%esp
f01009f8:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f01009fb:	ff 34 85 c0 5c 10 f0 	pushl  -0xfefa340(,%eax,4)
f0100a02:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a05:	e8 ff 3f 00 00       	call   f0104a09 <strcmp>
f0100a0a:	83 c4 10             	add    $0x10,%esp
f0100a0d:	85 c0                	test   %eax,%eax
f0100a0f:	0f 84 8f 00 00 00    	je     f0100aa4 <monitor+0x12c>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100a15:	83 c3 01             	add    $0x1,%ebx
f0100a18:	83 fb 03             	cmp    $0x3,%ebx
f0100a1b:	75 d8                	jne    f01009f5 <monitor+0x7d>
	cprintf("Unknown command '%s'\n", argv[0]);
f0100a1d:	83 ec 08             	sub    $0x8,%esp
f0100a20:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a23:	68 19 5b 10 f0       	push   $0xf0105b19
f0100a28:	e8 c5 2d 00 00       	call   f01037f2 <cprintf>
f0100a2d:	83 c4 10             	add    $0x10,%esp
f0100a30:	eb 4b                	jmp    f0100a7d <monitor+0x105>
		if (*buf == 0)
f0100a32:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100a35:	74 a9                	je     f01009e0 <monitor+0x68>
		if (argc == MAXARGS-1) {
f0100a37:	83 fe 0f             	cmp    $0xf,%esi
f0100a3a:	74 2f                	je     f0100a6b <monitor+0xf3>
		argv[argc++] = buf;
f0100a3c:	8d 7e 01             	lea    0x1(%esi),%edi
f0100a3f:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
		while (*buf && !strchr(WHITESPACE, *buf))
f0100a43:	0f b6 03             	movzbl (%ebx),%eax
f0100a46:	84 c0                	test   %al,%al
f0100a48:	74 8d                	je     f01009d7 <monitor+0x5f>
f0100a4a:	83 ec 08             	sub    $0x8,%esp
f0100a4d:	0f be c0             	movsbl %al,%eax
f0100a50:	50                   	push   %eax
f0100a51:	68 f7 5a 10 f0       	push   $0xf0105af7
f0100a56:	e8 0c 40 00 00       	call   f0104a67 <strchr>
f0100a5b:	83 c4 10             	add    $0x10,%esp
f0100a5e:	85 c0                	test   %eax,%eax
f0100a60:	0f 85 71 ff ff ff    	jne    f01009d7 <monitor+0x5f>
			buf++;
f0100a66:	83 c3 01             	add    $0x1,%ebx
f0100a69:	eb d8                	jmp    f0100a43 <monitor+0xcb>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100a6b:	83 ec 08             	sub    $0x8,%esp
f0100a6e:	6a 10                	push   $0x10
f0100a70:	68 fc 5a 10 f0       	push   $0xf0105afc
f0100a75:	e8 78 2d 00 00       	call   f01037f2 <cprintf>
f0100a7a:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f0100a7d:	83 ec 0c             	sub    $0xc,%esp
f0100a80:	68 f3 5a 10 f0       	push   $0xf0105af3
f0100a85:	e8 b9 3d 00 00       	call   f0104843 <readline>
f0100a8a:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100a8c:	83 c4 10             	add    $0x10,%esp
f0100a8f:	85 c0                	test   %eax,%eax
f0100a91:	74 ea                	je     f0100a7d <monitor+0x105>
	argv[argc] = 0;
f0100a93:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f0100a9a:	be 00 00 00 00       	mov    $0x0,%esi
f0100a9f:	e9 35 ff ff ff       	jmp    f01009d9 <monitor+0x61>
			return commands[i].func(argc, argv, tf);
f0100aa4:	83 ec 04             	sub    $0x4,%esp
f0100aa7:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100aaa:	ff 75 08             	pushl  0x8(%ebp)
f0100aad:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100ab0:	52                   	push   %edx
f0100ab1:	56                   	push   %esi
f0100ab2:	ff 14 85 c8 5c 10 f0 	call   *-0xfefa338(,%eax,4)
			if (runcmd(buf, tf) < 0)
f0100ab9:	83 c4 10             	add    $0x10,%esp
f0100abc:	85 c0                	test   %eax,%eax
f0100abe:	79 bd                	jns    f0100a7d <monitor+0x105>
				break;
	}
}
f0100ac0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100ac3:	5b                   	pop    %ebx
f0100ac4:	5e                   	pop    %esi
f0100ac5:	5f                   	pop    %edi
f0100ac6:	5d                   	pop    %ebp
f0100ac7:	c3                   	ret    

f0100ac8 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100ac8:	89 c2                	mov    %eax,%edx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100aca:	83 3d 38 12 23 f0 00 	cmpl   $0x0,0xf0231238
f0100ad1:	74 1a                	je     f0100aed <boot_alloc+0x25>
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	//cprintf("nextfree:%p\n", nextfree);
	result = nextfree;
f0100ad3:	a1 38 12 23 f0       	mov    0xf0231238,%eax
	nextfree += ROUNDUP(n, PGSIZE);
f0100ad8:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
f0100ade:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100ae4:	01 c2                	add    %eax,%edx
f0100ae6:	89 15 38 12 23 f0    	mov    %edx,0xf0231238
	return result;
}
f0100aec:	c3                   	ret    
		nextfree = ROUNDUP((char *) end, PGSIZE);		
f0100aed:	b8 07 40 27 f0       	mov    $0xf0274007,%eax
f0100af2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100af7:	a3 38 12 23 f0       	mov    %eax,0xf0231238
f0100afc:	eb d5                	jmp    f0100ad3 <boot_alloc+0xb>

f0100afe <nvram_read>:
{
f0100afe:	55                   	push   %ebp
f0100aff:	89 e5                	mov    %esp,%ebp
f0100b01:	56                   	push   %esi
f0100b02:	53                   	push   %ebx
f0100b03:	89 c6                	mov    %eax,%esi
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100b05:	83 ec 0c             	sub    $0xc,%esp
f0100b08:	50                   	push   %eax
f0100b09:	e8 59 2b 00 00       	call   f0103667 <mc146818_read>
f0100b0e:	89 c3                	mov    %eax,%ebx
f0100b10:	83 c6 01             	add    $0x1,%esi
f0100b13:	89 34 24             	mov    %esi,(%esp)
f0100b16:	e8 4c 2b 00 00       	call   f0103667 <mc146818_read>
f0100b1b:	c1 e0 08             	shl    $0x8,%eax
f0100b1e:	09 d8                	or     %ebx,%eax
}
f0100b20:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100b23:	5b                   	pop    %ebx
f0100b24:	5e                   	pop    %esi
f0100b25:	5d                   	pop    %ebp
f0100b26:	c3                   	ret    

f0100b27 <check_va2pa>:

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;
	pgdir = &pgdir[PDX(va)];
f0100b27:	89 d1                	mov    %edx,%ecx
f0100b29:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100b2c:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100b2f:	a8 01                	test   $0x1,%al
f0100b31:	74 52                	je     f0100b85 <check_va2pa+0x5e>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100b33:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0100b38:	89 c1                	mov    %eax,%ecx
f0100b3a:	c1 e9 0c             	shr    $0xc,%ecx
f0100b3d:	3b 0d 88 1e 23 f0    	cmp    0xf0231e88,%ecx
f0100b43:	73 25                	jae    f0100b6a <check_va2pa+0x43>
	if (!(p[PTX(va)] & PTE_P))
f0100b45:	c1 ea 0c             	shr    $0xc,%edx
f0100b48:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100b4e:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100b55:	89 c2                	mov    %eax,%edx
f0100b57:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100b5a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b5f:	85 d2                	test   %edx,%edx
f0100b61:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100b66:	0f 44 c2             	cmove  %edx,%eax
f0100b69:	c3                   	ret    
{
f0100b6a:	55                   	push   %ebp
f0100b6b:	89 e5                	mov    %esp,%ebp
f0100b6d:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100b70:	50                   	push   %eax
f0100b71:	68 b4 57 10 f0       	push   $0xf01057b4
f0100b76:	68 a1 03 00 00       	push   $0x3a1
f0100b7b:	68 05 66 10 f0       	push   $0xf0106605
f0100b80:	e8 0f f5 ff ff       	call   f0100094 <_panic>
		return ~0;
f0100b85:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f0100b8a:	c3                   	ret    

f0100b8b <check_page_free_list>:
{
f0100b8b:	55                   	push   %ebp
f0100b8c:	89 e5                	mov    %esp,%ebp
f0100b8e:	57                   	push   %edi
f0100b8f:	56                   	push   %esi
f0100b90:	53                   	push   %ebx
f0100b91:	83 ec 2c             	sub    $0x2c,%esp
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100b94:	84 c0                	test   %al,%al
f0100b96:	0f 85 77 02 00 00    	jne    f0100e13 <check_page_free_list+0x288>
	if (!page_free_list)
f0100b9c:	83 3d 3c 12 23 f0 00 	cmpl   $0x0,0xf023123c
f0100ba3:	74 0a                	je     f0100baf <check_page_free_list+0x24>
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100ba5:	be 00 04 00 00       	mov    $0x400,%esi
f0100baa:	e9 d1 02 00 00       	jmp    f0100e80 <check_page_free_list+0x2f5>
		panic("'page_free_list' is a null pointer!");
f0100baf:	83 ec 04             	sub    $0x4,%esp
f0100bb2:	68 e4 5c 10 f0       	push   $0xf0105ce4
f0100bb7:	68 cb 02 00 00       	push   $0x2cb
f0100bbc:	68 05 66 10 f0       	push   $0xf0106605
f0100bc1:	e8 ce f4 ff ff       	call   f0100094 <_panic>
f0100bc6:	50                   	push   %eax
f0100bc7:	68 b4 57 10 f0       	push   $0xf01057b4
f0100bcc:	6a 58                	push   $0x58
f0100bce:	68 18 66 10 f0       	push   $0xf0106618
f0100bd3:	e8 bc f4 ff ff       	call   f0100094 <_panic>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100bd8:	8b 1b                	mov    (%ebx),%ebx
f0100bda:	85 db                	test   %ebx,%ebx
f0100bdc:	74 41                	je     f0100c1f <check_page_free_list+0x94>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100bde:	89 d8                	mov    %ebx,%eax
f0100be0:	2b 05 90 1e 23 f0    	sub    0xf0231e90,%eax
f0100be6:	c1 f8 03             	sar    $0x3,%eax
f0100be9:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100bec:	89 c2                	mov    %eax,%edx
f0100bee:	c1 ea 16             	shr    $0x16,%edx
f0100bf1:	39 f2                	cmp    %esi,%edx
f0100bf3:	73 e3                	jae    f0100bd8 <check_page_free_list+0x4d>
	if (PGNUM(pa) >= npages)
f0100bf5:	89 c2                	mov    %eax,%edx
f0100bf7:	c1 ea 0c             	shr    $0xc,%edx
f0100bfa:	3b 15 88 1e 23 f0    	cmp    0xf0231e88,%edx
f0100c00:	73 c4                	jae    f0100bc6 <check_page_free_list+0x3b>
			memset(page2kva(pp), 0x97, 128);
f0100c02:	83 ec 04             	sub    $0x4,%esp
f0100c05:	68 80 00 00 00       	push   $0x80
f0100c0a:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0100c0f:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c14:	50                   	push   %eax
f0100c15:	e8 8a 3e 00 00       	call   f0104aa4 <memset>
f0100c1a:	83 c4 10             	add    $0x10,%esp
f0100c1d:	eb b9                	jmp    f0100bd8 <check_page_free_list+0x4d>
	first_free_page = (char *) boot_alloc(0);
f0100c1f:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c24:	e8 9f fe ff ff       	call   f0100ac8 <boot_alloc>
f0100c29:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c2c:	8b 15 3c 12 23 f0    	mov    0xf023123c,%edx
		assert(pp >= pages);
f0100c32:	8b 0d 90 1e 23 f0    	mov    0xf0231e90,%ecx
		assert(pp < pages + npages);
f0100c38:	a1 88 1e 23 f0       	mov    0xf0231e88,%eax
f0100c3d:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100c40:	8d 34 c1             	lea    (%ecx,%eax,8),%esi
	int nfree_basemem = 0, nfree_extmem = 0;
f0100c43:	bf 00 00 00 00       	mov    $0x0,%edi
f0100c48:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c4b:	e9 f9 00 00 00       	jmp    f0100d49 <check_page_free_list+0x1be>
		assert(pp >= pages);
f0100c50:	68 26 66 10 f0       	push   $0xf0106626
f0100c55:	68 32 66 10 f0       	push   $0xf0106632
f0100c5a:	68 e8 02 00 00       	push   $0x2e8
f0100c5f:	68 05 66 10 f0       	push   $0xf0106605
f0100c64:	e8 2b f4 ff ff       	call   f0100094 <_panic>
		assert(pp < pages + npages);
f0100c69:	68 47 66 10 f0       	push   $0xf0106647
f0100c6e:	68 32 66 10 f0       	push   $0xf0106632
f0100c73:	68 e9 02 00 00       	push   $0x2e9
f0100c78:	68 05 66 10 f0       	push   $0xf0106605
f0100c7d:	e8 12 f4 ff ff       	call   f0100094 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100c82:	68 08 5d 10 f0       	push   $0xf0105d08
f0100c87:	68 32 66 10 f0       	push   $0xf0106632
f0100c8c:	68 ea 02 00 00       	push   $0x2ea
f0100c91:	68 05 66 10 f0       	push   $0xf0106605
f0100c96:	e8 f9 f3 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != 0);
f0100c9b:	68 5b 66 10 f0       	push   $0xf010665b
f0100ca0:	68 32 66 10 f0       	push   $0xf0106632
f0100ca5:	68 ed 02 00 00       	push   $0x2ed
f0100caa:	68 05 66 10 f0       	push   $0xf0106605
f0100caf:	e8 e0 f3 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100cb4:	68 6c 66 10 f0       	push   $0xf010666c
f0100cb9:	68 32 66 10 f0       	push   $0xf0106632
f0100cbe:	68 ee 02 00 00       	push   $0x2ee
f0100cc3:	68 05 66 10 f0       	push   $0xf0106605
f0100cc8:	e8 c7 f3 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100ccd:	68 3c 5d 10 f0       	push   $0xf0105d3c
f0100cd2:	68 32 66 10 f0       	push   $0xf0106632
f0100cd7:	68 ef 02 00 00       	push   $0x2ef
f0100cdc:	68 05 66 10 f0       	push   $0xf0106605
f0100ce1:	e8 ae f3 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100ce6:	68 85 66 10 f0       	push   $0xf0106685
f0100ceb:	68 32 66 10 f0       	push   $0xf0106632
f0100cf0:	68 f0 02 00 00       	push   $0x2f0
f0100cf5:	68 05 66 10 f0       	push   $0xf0106605
f0100cfa:	e8 95 f3 ff ff       	call   f0100094 <_panic>
	if (PGNUM(pa) >= npages)
f0100cff:	89 c3                	mov    %eax,%ebx
f0100d01:	c1 eb 0c             	shr    $0xc,%ebx
f0100d04:	39 5d d0             	cmp    %ebx,-0x30(%ebp)
f0100d07:	76 0f                	jbe    f0100d18 <check_page_free_list+0x18d>
	return (void *)(pa + KERNBASE);
f0100d09:	2d 00 00 00 10       	sub    $0x10000000,%eax
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100d0e:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0100d11:	77 17                	ja     f0100d2a <check_page_free_list+0x19f>
			++nfree_extmem;
f0100d13:	83 c7 01             	add    $0x1,%edi
f0100d16:	eb 2f                	jmp    f0100d47 <check_page_free_list+0x1bc>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100d18:	50                   	push   %eax
f0100d19:	68 b4 57 10 f0       	push   $0xf01057b4
f0100d1e:	6a 58                	push   $0x58
f0100d20:	68 18 66 10 f0       	push   $0xf0106618
f0100d25:	e8 6a f3 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100d2a:	68 60 5d 10 f0       	push   $0xf0105d60
f0100d2f:	68 32 66 10 f0       	push   $0xf0106632
f0100d34:	68 f1 02 00 00       	push   $0x2f1
f0100d39:	68 05 66 10 f0       	push   $0xf0106605
f0100d3e:	e8 51 f3 ff ff       	call   f0100094 <_panic>
			++nfree_basemem;
f0100d43:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100d47:	8b 12                	mov    (%edx),%edx
f0100d49:	85 d2                	test   %edx,%edx
f0100d4b:	74 74                	je     f0100dc1 <check_page_free_list+0x236>
		assert(pp >= pages);
f0100d4d:	39 d1                	cmp    %edx,%ecx
f0100d4f:	0f 87 fb fe ff ff    	ja     f0100c50 <check_page_free_list+0xc5>
		assert(pp < pages + npages);
f0100d55:	39 d6                	cmp    %edx,%esi
f0100d57:	0f 86 0c ff ff ff    	jbe    f0100c69 <check_page_free_list+0xde>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100d5d:	89 d0                	mov    %edx,%eax
f0100d5f:	29 c8                	sub    %ecx,%eax
f0100d61:	a8 07                	test   $0x7,%al
f0100d63:	0f 85 19 ff ff ff    	jne    f0100c82 <check_page_free_list+0xf7>
	return (pp - pages) << PGSHIFT;
f0100d69:	c1 f8 03             	sar    $0x3,%eax
		assert(page2pa(pp) != 0);
f0100d6c:	c1 e0 0c             	shl    $0xc,%eax
f0100d6f:	0f 84 26 ff ff ff    	je     f0100c9b <check_page_free_list+0x110>
		assert(page2pa(pp) != IOPHYSMEM);
f0100d75:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100d7a:	0f 84 34 ff ff ff    	je     f0100cb4 <check_page_free_list+0x129>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100d80:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100d85:	0f 84 42 ff ff ff    	je     f0100ccd <check_page_free_list+0x142>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100d8b:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100d90:	0f 84 50 ff ff ff    	je     f0100ce6 <check_page_free_list+0x15b>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100d96:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100d9b:	0f 87 5e ff ff ff    	ja     f0100cff <check_page_free_list+0x174>
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100da1:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100da6:	75 9b                	jne    f0100d43 <check_page_free_list+0x1b8>
f0100da8:	68 9f 66 10 f0       	push   $0xf010669f
f0100dad:	68 32 66 10 f0       	push   $0xf0106632
f0100db2:	68 f3 02 00 00       	push   $0x2f3
f0100db7:	68 05 66 10 f0       	push   $0xf0106605
f0100dbc:	e8 d3 f2 ff ff       	call   f0100094 <_panic>
f0100dc1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
	assert(nfree_basemem > 0);
f0100dc4:	85 db                	test   %ebx,%ebx
f0100dc6:	7e 19                	jle    f0100de1 <check_page_free_list+0x256>
	assert(nfree_extmem > 0);
f0100dc8:	85 ff                	test   %edi,%edi
f0100dca:	7e 2e                	jle    f0100dfa <check_page_free_list+0x26f>
	cprintf("check_page_free_list() succeeded!\n");
f0100dcc:	83 ec 0c             	sub    $0xc,%esp
f0100dcf:	68 a8 5d 10 f0       	push   $0xf0105da8
f0100dd4:	e8 19 2a 00 00       	call   f01037f2 <cprintf>
}
f0100dd9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100ddc:	5b                   	pop    %ebx
f0100ddd:	5e                   	pop    %esi
f0100dde:	5f                   	pop    %edi
f0100ddf:	5d                   	pop    %ebp
f0100de0:	c3                   	ret    
	assert(nfree_basemem > 0);
f0100de1:	68 bc 66 10 f0       	push   $0xf01066bc
f0100de6:	68 32 66 10 f0       	push   $0xf0106632
f0100deb:	68 fb 02 00 00       	push   $0x2fb
f0100df0:	68 05 66 10 f0       	push   $0xf0106605
f0100df5:	e8 9a f2 ff ff       	call   f0100094 <_panic>
	assert(nfree_extmem > 0);
f0100dfa:	68 ce 66 10 f0       	push   $0xf01066ce
f0100dff:	68 32 66 10 f0       	push   $0xf0106632
f0100e04:	68 fc 02 00 00       	push   $0x2fc
f0100e09:	68 05 66 10 f0       	push   $0xf0106605
f0100e0e:	e8 81 f2 ff ff       	call   f0100094 <_panic>
	if (!page_free_list)
f0100e13:	a1 3c 12 23 f0       	mov    0xf023123c,%eax
f0100e18:	85 c0                	test   %eax,%eax
f0100e1a:	0f 84 8f fd ff ff    	je     f0100baf <check_page_free_list+0x24>
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100e20:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100e23:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100e26:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100e29:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100e2c:	89 c2                	mov    %eax,%edx
f0100e2e:	2b 15 90 1e 23 f0    	sub    0xf0231e90,%edx
			pagetype = (PDX(page2pa(pp)) >= pdx_limit);
f0100e34:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100e3a:	0f 95 c2             	setne  %dl
f0100e3d:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100e40:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100e44:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100e46:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100e4a:	8b 00                	mov    (%eax),%eax
f0100e4c:	85 c0                	test   %eax,%eax
f0100e4e:	75 dc                	jne    f0100e2c <check_page_free_list+0x2a1>
		cprintf("end%p\n",pp);
f0100e50:	83 ec 08             	sub    $0x8,%esp
f0100e53:	6a 00                	push   $0x0
f0100e55:	68 11 66 10 f0       	push   $0xf0106611
f0100e5a:	e8 93 29 00 00       	call   f01037f2 <cprintf>
		*tp[1] = 0;
f0100e5f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100e62:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100e68:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100e6b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100e6e:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100e70:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100e73:	a3 3c 12 23 f0       	mov    %eax,0xf023123c
f0100e78:	83 c4 10             	add    $0x10,%esp
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100e7b:	be 01 00 00 00       	mov    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100e80:	8b 1d 3c 12 23 f0    	mov    0xf023123c,%ebx
f0100e86:	e9 4f fd ff ff       	jmp    f0100bda <check_page_free_list+0x4f>

f0100e8b <page_init>:
{
f0100e8b:	55                   	push   %ebp
f0100e8c:	89 e5                	mov    %esp,%ebp
f0100e8e:	56                   	push   %esi
f0100e8f:	53                   	push   %ebx
	pages[0].pp_ref = 1;
f0100e90:	a1 90 1e 23 f0       	mov    0xf0231e90,%eax
f0100e95:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
    for (i = 1; i < npages_basemem; i++) {
f0100e9b:	bb 01 00 00 00       	mov    $0x1,%ebx
f0100ea0:	eb 3c                	jmp    f0100ede <page_init+0x53>
f0100ea2:	8d 34 dd 00 00 00 00 	lea    0x0(,%ebx,8),%esi
        pages[i].pp_ref = 0;
f0100ea9:	89 f2                	mov    %esi,%edx
f0100eab:	03 15 90 1e 23 f0    	add    0xf0231e90,%edx
f0100eb1:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
        pages[i].pp_link = page_free_list;
f0100eb7:	a1 3c 12 23 f0       	mov    0xf023123c,%eax
f0100ebc:	89 02                	mov    %eax,(%edx)
		cprintf("page_init:%p\n", page_free_list);
f0100ebe:	83 ec 08             	sub    $0x8,%esp
f0100ec1:	50                   	push   %eax
f0100ec2:	68 df 66 10 f0       	push   $0xf01066df
f0100ec7:	e8 26 29 00 00       	call   f01037f2 <cprintf>
        page_free_list = &pages[i];
f0100ecc:	03 35 90 1e 23 f0    	add    0xf0231e90,%esi
f0100ed2:	89 35 3c 12 23 f0    	mov    %esi,0xf023123c
f0100ed8:	83 c4 10             	add    $0x10,%esp
    for (i = 1; i < npages_basemem; i++) {
f0100edb:	83 c3 01             	add    $0x1,%ebx
f0100ede:	39 1d 40 12 23 f0    	cmp    %ebx,0xf0231240
f0100ee4:	76 12                	jbe    f0100ef8 <page_init+0x6d>
		if (i == mp_page) {
f0100ee6:	83 fb 07             	cmp    $0x7,%ebx
f0100ee9:	75 b7                	jne    f0100ea2 <page_init+0x17>
			 pages[i].pp_ref = 1;
f0100eeb:	a1 90 1e 23 f0       	mov    0xf0231e90,%eax
f0100ef0:	66 c7 40 3c 01 00    	movw   $0x1,0x3c(%eax)
			 continue;
f0100ef6:	eb e3                	jmp    f0100edb <page_init+0x50>
	size_t first_free_address = PADDR(boot_alloc(0));
f0100ef8:	b8 00 00 00 00       	mov    $0x0,%eax
f0100efd:	e8 c6 fb ff ff       	call   f0100ac8 <boot_alloc>
	if ((uint32_t)kva < KERNBASE)
f0100f02:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100f07:	76 3b                	jbe    f0100f44 <page_init+0xb9>
	return (physaddr_t)kva - KERNBASE;
f0100f09:	8d 88 00 00 00 10    	lea    0x10000000(%eax),%ecx
        pages[i].pp_ref = 1;
f0100f0f:	8b 15 90 1e 23 f0    	mov    0xf0231e90,%edx
f0100f15:	8d 82 04 05 00 00    	lea    0x504(%edx),%eax
f0100f1b:	81 c2 04 08 00 00    	add    $0x804,%edx
f0100f21:	66 c7 00 01 00       	movw   $0x1,(%eax)
f0100f26:	83 c0 08             	add    $0x8,%eax
    for (i = IOPHYSMEM/PGSIZE; i < EXTPHYSMEM/PGSIZE; i++) {
f0100f29:	39 d0                	cmp    %edx,%eax
f0100f2b:	75 f4                	jne    f0100f21 <page_init+0x96>
    for (i = first_free_address/PGSIZE; i < npages; i++) {
f0100f2d:	89 c8                	mov    %ecx,%eax
f0100f2f:	c1 e8 0c             	shr    $0xc,%eax
f0100f32:	8b 1d 3c 12 23 f0    	mov    0xf023123c,%ebx
f0100f38:	ba 00 00 00 00       	mov    $0x0,%edx
f0100f3d:	be 01 00 00 00       	mov    $0x1,%esi
f0100f42:	eb 39                	jmp    f0100f7d <page_init+0xf2>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100f44:	50                   	push   %eax
f0100f45:	68 d8 57 10 f0       	push   $0xf01057d8
f0100f4a:	68 5b 01 00 00       	push   $0x15b
f0100f4f:	68 05 66 10 f0       	push   $0xf0106605
f0100f54:	e8 3b f1 ff ff       	call   f0100094 <_panic>
f0100f59:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
        pages[i].pp_ref = 0;
f0100f60:	89 d1                	mov    %edx,%ecx
f0100f62:	03 0d 90 1e 23 f0    	add    0xf0231e90,%ecx
f0100f68:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
        pages[i].pp_link = page_free_list;
f0100f6e:	89 19                	mov    %ebx,(%ecx)
    for (i = first_free_address/PGSIZE; i < npages; i++) {
f0100f70:	83 c0 01             	add    $0x1,%eax
        page_free_list = &pages[i];
f0100f73:	89 d3                	mov    %edx,%ebx
f0100f75:	03 1d 90 1e 23 f0    	add    0xf0231e90,%ebx
f0100f7b:	89 f2                	mov    %esi,%edx
    for (i = first_free_address/PGSIZE; i < npages; i++) {
f0100f7d:	39 05 88 1e 23 f0    	cmp    %eax,0xf0231e88
f0100f83:	77 d4                	ja     f0100f59 <page_init+0xce>
f0100f85:	84 d2                	test   %dl,%dl
f0100f87:	74 06                	je     f0100f8f <page_init+0x104>
f0100f89:	89 1d 3c 12 23 f0    	mov    %ebx,0xf023123c
}
f0100f8f:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100f92:	5b                   	pop    %ebx
f0100f93:	5e                   	pop    %esi
f0100f94:	5d                   	pop    %ebp
f0100f95:	c3                   	ret    

f0100f96 <page_alloc>:
{
f0100f96:	55                   	push   %ebp
f0100f97:	89 e5                	mov    %esp,%ebp
f0100f99:	53                   	push   %ebx
f0100f9a:	83 ec 04             	sub    $0x4,%esp
	if (!page_free_list) {
f0100f9d:	8b 1d 3c 12 23 f0    	mov    0xf023123c,%ebx
f0100fa3:	85 db                	test   %ebx,%ebx
f0100fa5:	74 13                	je     f0100fba <page_alloc+0x24>
	page_free_list = page->pp_link;
f0100fa7:	8b 03                	mov    (%ebx),%eax
f0100fa9:	a3 3c 12 23 f0       	mov    %eax,0xf023123c
	page->pp_link = NULL;
f0100fae:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (alloc_flags & ALLOC_ZERO) {
f0100fb4:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100fb8:	75 07                	jne    f0100fc1 <page_alloc+0x2b>
}
f0100fba:	89 d8                	mov    %ebx,%eax
f0100fbc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100fbf:	c9                   	leave  
f0100fc0:	c3                   	ret    
	return (pp - pages) << PGSHIFT;
f0100fc1:	89 d8                	mov    %ebx,%eax
f0100fc3:	2b 05 90 1e 23 f0    	sub    0xf0231e90,%eax
f0100fc9:	c1 f8 03             	sar    $0x3,%eax
f0100fcc:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0100fcf:	89 c2                	mov    %eax,%edx
f0100fd1:	c1 ea 0c             	shr    $0xc,%edx
f0100fd4:	3b 15 88 1e 23 f0    	cmp    0xf0231e88,%edx
f0100fda:	73 1a                	jae    f0100ff6 <page_alloc+0x60>
		memset(page2kva(page), 0, PGSIZE); 
f0100fdc:	83 ec 04             	sub    $0x4,%esp
f0100fdf:	68 00 10 00 00       	push   $0x1000
f0100fe4:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f0100fe6:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100feb:	50                   	push   %eax
f0100fec:	e8 b3 3a 00 00       	call   f0104aa4 <memset>
f0100ff1:	83 c4 10             	add    $0x10,%esp
f0100ff4:	eb c4                	jmp    f0100fba <page_alloc+0x24>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ff6:	50                   	push   %eax
f0100ff7:	68 b4 57 10 f0       	push   $0xf01057b4
f0100ffc:	6a 58                	push   $0x58
f0100ffe:	68 18 66 10 f0       	push   $0xf0106618
f0101003:	e8 8c f0 ff ff       	call   f0100094 <_panic>

f0101008 <page_free>:
{
f0101008:	55                   	push   %ebp
f0101009:	89 e5                	mov    %esp,%ebp
f010100b:	83 ec 08             	sub    $0x8,%esp
f010100e:	8b 45 08             	mov    0x8(%ebp),%eax
	if (pp->pp_ref || pp->pp_link) {
f0101011:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101016:	75 14                	jne    f010102c <page_free+0x24>
f0101018:	83 38 00             	cmpl   $0x0,(%eax)
f010101b:	75 0f                	jne    f010102c <page_free+0x24>
	pp->pp_link = page_free_list;
f010101d:	8b 15 3c 12 23 f0    	mov    0xf023123c,%edx
f0101023:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0101025:	a3 3c 12 23 f0       	mov    %eax,0xf023123c
}
f010102a:	c9                   	leave  
f010102b:	c3                   	ret    
		panic("page_free: double check failed when dealloc page. '\n");
f010102c:	83 ec 04             	sub    $0x4,%esp
f010102f:	68 cc 5d 10 f0       	push   $0xf0105dcc
f0101034:	68 96 01 00 00       	push   $0x196
f0101039:	68 05 66 10 f0       	push   $0xf0106605
f010103e:	e8 51 f0 ff ff       	call   f0100094 <_panic>

f0101043 <page_decref>:
{
f0101043:	55                   	push   %ebp
f0101044:	89 e5                	mov    %esp,%ebp
f0101046:	83 ec 08             	sub    $0x8,%esp
f0101049:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f010104c:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0101050:	83 e8 01             	sub    $0x1,%eax
f0101053:	66 89 42 04          	mov    %ax,0x4(%edx)
f0101057:	66 85 c0             	test   %ax,%ax
f010105a:	74 02                	je     f010105e <page_decref+0x1b>
}
f010105c:	c9                   	leave  
f010105d:	c3                   	ret    
		page_free(pp);
f010105e:	83 ec 0c             	sub    $0xc,%esp
f0101061:	52                   	push   %edx
f0101062:	e8 a1 ff ff ff       	call   f0101008 <page_free>
f0101067:	83 c4 10             	add    $0x10,%esp
}
f010106a:	eb f0                	jmp    f010105c <page_decref+0x19>

f010106c <pgdir_walk>:
{
f010106c:	55                   	push   %ebp
f010106d:	89 e5                	mov    %esp,%ebp
f010106f:	56                   	push   %esi
f0101070:	53                   	push   %ebx
f0101071:	8b 45 0c             	mov    0xc(%ebp),%eax
	uint32_t ptx = PTX(va);		
f0101074:	89 c6                	mov    %eax,%esi
f0101076:	c1 ee 0c             	shr    $0xc,%esi
f0101079:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
	uint32_t pdx = PDX(va);		
f010107f:	c1 e8 16             	shr    $0x16,%eax
	if (pgdir[pdx] & PTE_P) {
f0101082:	8d 1c 85 00 00 00 00 	lea    0x0(,%eax,4),%ebx
f0101089:	03 5d 08             	add    0x8(%ebp),%ebx
f010108c:	8b 03                	mov    (%ebx),%eax
f010108e:	a8 01                	test   $0x1,%al
f0101090:	74 36                	je     f01010c8 <pgdir_walk+0x5c>
		pgtab = KADDR(PTE_ADDR(pgdir[pdx]));
f0101092:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0101097:	89 c2                	mov    %eax,%edx
f0101099:	c1 ea 0c             	shr    $0xc,%edx
f010109c:	39 15 88 1e 23 f0    	cmp    %edx,0xf0231e88
f01010a2:	76 0f                	jbe    f01010b3 <pgdir_walk+0x47>
	return (void *)(pa + KERNBASE);
f01010a4:	2d 00 00 00 10       	sub    $0x10000000,%eax
	return &pgtab[ptx];
f01010a9:	8d 04 b0             	lea    (%eax,%esi,4),%eax
}
f01010ac:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01010af:	5b                   	pop    %ebx
f01010b0:	5e                   	pop    %esi
f01010b1:	5d                   	pop    %ebp
f01010b2:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01010b3:	50                   	push   %eax
f01010b4:	68 b4 57 10 f0       	push   $0xf01057b4
f01010b9:	68 c6 01 00 00       	push   $0x1c6
f01010be:	68 05 66 10 f0       	push   $0xf0106605
f01010c3:	e8 cc ef ff ff       	call   f0100094 <_panic>
		if (create) {
f01010c8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01010cc:	74 50                	je     f010111e <pgdir_walk+0xb2>
			struct PageInfo *new_pginfo = page_alloc(ALLOC_ZERO);	
f01010ce:	83 ec 0c             	sub    $0xc,%esp
f01010d1:	6a 01                	push   $0x1
f01010d3:	e8 be fe ff ff       	call   f0100f96 <page_alloc>
			if (new_pginfo) {
f01010d8:	83 c4 10             	add    $0x10,%esp
f01010db:	85 c0                	test   %eax,%eax
f01010dd:	74 46                	je     f0101125 <pgdir_walk+0xb9>
				new_pginfo->pp_ref += 1;
f01010df:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f01010e4:	2b 05 90 1e 23 f0    	sub    0xf0231e90,%eax
f01010ea:	89 c2                	mov    %eax,%edx
f01010ec:	c1 fa 03             	sar    $0x3,%edx
f01010ef:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f01010f2:	89 d0                	mov    %edx,%eax
f01010f4:	c1 e8 0c             	shr    $0xc,%eax
f01010f7:	3b 05 88 1e 23 f0    	cmp    0xf0231e88,%eax
f01010fd:	73 0d                	jae    f010110c <pgdir_walk+0xa0>
	return (void *)(pa + KERNBASE);
f01010ff:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
				pgdir[pdx] = page2pa(new_pginfo) | PTE_P | PTE_W | PTE_U;
f0101105:	83 ca 07             	or     $0x7,%edx
f0101108:	89 13                	mov    %edx,(%ebx)
f010110a:	eb 9d                	jmp    f01010a9 <pgdir_walk+0x3d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010110c:	52                   	push   %edx
f010110d:	68 b4 57 10 f0       	push   $0xf01057b4
f0101112:	6a 58                	push   $0x58
f0101114:	68 18 66 10 f0       	push   $0xf0106618
f0101119:	e8 76 ef ff ff       	call   f0100094 <_panic>
			return NULL;
f010111e:	b8 00 00 00 00       	mov    $0x0,%eax
f0101123:	eb 87                	jmp    f01010ac <pgdir_walk+0x40>
			return NULL; 
f0101125:	b8 00 00 00 00       	mov    $0x0,%eax
f010112a:	eb 80                	jmp    f01010ac <pgdir_walk+0x40>

f010112c <boot_map_region>:
{
f010112c:	55                   	push   %ebp
f010112d:	89 e5                	mov    %esp,%ebp
f010112f:	57                   	push   %edi
f0101130:	56                   	push   %esi
f0101131:	53                   	push   %ebx
f0101132:	83 ec 1c             	sub    $0x1c,%esp
f0101135:	89 c7                	mov    %eax,%edi
f0101137:	8b 45 08             	mov    0x8(%ebp),%eax
f010113a:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0101140:	01 c1                	add    %eax,%ecx
f0101142:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	for (size_t i = 0;i < pg_num; i++) {
f0101145:	89 c3                	mov    %eax,%ebx
		pte = pgdir_walk(pgdir, (void *)va, 1);		 
f0101147:	89 d6                	mov    %edx,%esi
f0101149:	29 c6                	sub    %eax,%esi
	for (size_t i = 0;i < pg_num; i++) {
f010114b:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f010114e:	74 28                	je     f0101178 <boot_map_region+0x4c>
		pte = pgdir_walk(pgdir, (void *)va, 1);		 
f0101150:	83 ec 04             	sub    $0x4,%esp
f0101153:	6a 01                	push   $0x1
f0101155:	8d 04 1e             	lea    (%esi,%ebx,1),%eax
f0101158:	50                   	push   %eax
f0101159:	57                   	push   %edi
f010115a:	e8 0d ff ff ff       	call   f010106c <pgdir_walk>
		if (!pte) {
f010115f:	83 c4 10             	add    $0x10,%esp
f0101162:	85 c0                	test   %eax,%eax
f0101164:	74 12                	je     f0101178 <boot_map_region+0x4c>
		*pte = pa | perm | PTE_P;
f0101166:	89 da                	mov    %ebx,%edx
f0101168:	0b 55 0c             	or     0xc(%ebp),%edx
f010116b:	83 ca 01             	or     $0x1,%edx
f010116e:	89 10                	mov    %edx,(%eax)
		pa += PGSIZE;
f0101170:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0101176:	eb d3                	jmp    f010114b <boot_map_region+0x1f>
}
f0101178:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010117b:	5b                   	pop    %ebx
f010117c:	5e                   	pop    %esi
f010117d:	5f                   	pop    %edi
f010117e:	5d                   	pop    %ebp
f010117f:	c3                   	ret    

f0101180 <page_lookup>:
{
f0101180:	55                   	push   %ebp
f0101181:	89 e5                	mov    %esp,%ebp
f0101183:	83 ec 0c             	sub    $0xc,%esp
	pte_t *pte = pgdir_walk(pgdir, va, 0);
f0101186:	6a 00                	push   $0x0
f0101188:	ff 75 0c             	pushl  0xc(%ebp)
f010118b:	ff 75 08             	pushl  0x8(%ebp)
f010118e:	e8 d9 fe ff ff       	call   f010106c <pgdir_walk>
	if (!pte) {
f0101193:	83 c4 10             	add    $0x10,%esp
f0101196:	85 c0                	test   %eax,%eax
f0101198:	74 3b                	je     f01011d5 <page_lookup+0x55>
		*pte_store = pte;
f010119a:	8b 55 10             	mov    0x10(%ebp),%edx
f010119d:	89 02                	mov    %eax,(%edx)
	 	if (*pte) {
f010119f:	8b 10                	mov    (%eax),%edx
	return NULL;
f01011a1:	b8 00 00 00 00       	mov    $0x0,%eax
	 	if (*pte) {
f01011a6:	85 d2                	test   %edx,%edx
f01011a8:	75 02                	jne    f01011ac <page_lookup+0x2c>
}
f01011aa:	c9                   	leave  
f01011ab:	c3                   	ret    
f01011ac:	c1 ea 0c             	shr    $0xc,%edx
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01011af:	39 15 88 1e 23 f0    	cmp    %edx,0xf0231e88
f01011b5:	76 0a                	jbe    f01011c1 <page_lookup+0x41>
		panic("pa2page called with invalid pa");
	return &pages[PGNUM(pa)];
f01011b7:	a1 90 1e 23 f0       	mov    0xf0231e90,%eax
f01011bc:	8d 04 d0             	lea    (%eax,%edx,8),%eax
			return pa2page(PTE_ADDR(*pte)); 
f01011bf:	eb e9                	jmp    f01011aa <page_lookup+0x2a>
		panic("pa2page called with invalid pa");
f01011c1:	83 ec 04             	sub    $0x4,%esp
f01011c4:	68 04 5e 10 f0       	push   $0xf0105e04
f01011c9:	6a 51                	push   $0x51
f01011cb:	68 18 66 10 f0       	push   $0xf0106618
f01011d0:	e8 bf ee ff ff       	call   f0100094 <_panic>
		 return NULL;
f01011d5:	b8 00 00 00 00       	mov    $0x0,%eax
f01011da:	eb ce                	jmp    f01011aa <page_lookup+0x2a>

f01011dc <tlb_invalidate>:
{
f01011dc:	55                   	push   %ebp
f01011dd:	89 e5                	mov    %esp,%ebp
f01011df:	83 ec 08             	sub    $0x8,%esp
	if (!curenv || curenv->env_pgdir == pgdir)
f01011e2:	e8 bb 3e 00 00       	call   f01050a2 <cpunum>
f01011e7:	6b c0 74             	imul   $0x74,%eax,%eax
f01011ea:	83 b8 28 20 23 f0 00 	cmpl   $0x0,-0xfdcdfd8(%eax)
f01011f1:	74 16                	je     f0101209 <tlb_invalidate+0x2d>
f01011f3:	e8 aa 3e 00 00       	call   f01050a2 <cpunum>
f01011f8:	6b c0 74             	imul   $0x74,%eax,%eax
f01011fb:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0101201:	8b 55 08             	mov    0x8(%ebp),%edx
f0101204:	39 50 60             	cmp    %edx,0x60(%eax)
f0101207:	75 06                	jne    f010120f <tlb_invalidate+0x33>
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101209:	8b 45 0c             	mov    0xc(%ebp),%eax
f010120c:	0f 01 38             	invlpg (%eax)
}
f010120f:	c9                   	leave  
f0101210:	c3                   	ret    

f0101211 <page_remove>:
{
f0101211:	55                   	push   %ebp
f0101212:	89 e5                	mov    %esp,%ebp
f0101214:	56                   	push   %esi
f0101215:	53                   	push   %ebx
f0101216:	83 ec 14             	sub    $0x14,%esp
f0101219:	8b 5d 08             	mov    0x8(%ebp),%ebx
f010121c:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct PageInfo *pginfo = page_lookup(pgdir, va, pte_store);
f010121f:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101222:	50                   	push   %eax
f0101223:	56                   	push   %esi
f0101224:	53                   	push   %ebx
f0101225:	e8 56 ff ff ff       	call   f0101180 <page_lookup>
	if (pginfo) {
f010122a:	83 c4 10             	add    $0x10,%esp
f010122d:	85 c0                	test   %eax,%eax
f010122f:	74 1f                	je     f0101250 <page_remove+0x3f>
		page_decref(pginfo);
f0101231:	83 ec 0c             	sub    $0xc,%esp
f0101234:	50                   	push   %eax
f0101235:	e8 09 fe ff ff       	call   f0101043 <page_decref>
		*pte = 0;	 
f010123a:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010123d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		tlb_invalidate(pgdir, va);
f0101243:	83 c4 08             	add    $0x8,%esp
f0101246:	56                   	push   %esi
f0101247:	53                   	push   %ebx
f0101248:	e8 8f ff ff ff       	call   f01011dc <tlb_invalidate>
f010124d:	83 c4 10             	add    $0x10,%esp
}
f0101250:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101253:	5b                   	pop    %ebx
f0101254:	5e                   	pop    %esi
f0101255:	5d                   	pop    %ebp
f0101256:	c3                   	ret    

f0101257 <page_insert>:
{
f0101257:	55                   	push   %ebp
f0101258:	89 e5                	mov    %esp,%ebp
f010125a:	57                   	push   %edi
f010125b:	56                   	push   %esi
f010125c:	53                   	push   %ebx
f010125d:	83 ec 10             	sub    $0x10,%esp
f0101260:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101263:	8b 7d 10             	mov    0x10(%ebp),%edi
	pte_t *pte = pgdir_walk(pgdir, va, 1);	
f0101266:	6a 01                	push   $0x1
f0101268:	57                   	push   %edi
f0101269:	ff 75 08             	pushl  0x8(%ebp)
f010126c:	e8 fb fd ff ff       	call   f010106c <pgdir_walk>
	if (!pte) {
f0101271:	83 c4 10             	add    $0x10,%esp
f0101274:	85 c0                	test   %eax,%eax
f0101276:	74 3e                	je     f01012b6 <page_insert+0x5f>
f0101278:	89 c6                	mov    %eax,%esi
	pp->pp_ref++;
f010127a:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
	if (*pte & PTE_P) {
f010127f:	f6 00 01             	testb  $0x1,(%eax)
f0101282:	75 21                	jne    f01012a5 <page_insert+0x4e>
	return (pp - pages) << PGSHIFT;
f0101284:	2b 1d 90 1e 23 f0    	sub    0xf0231e90,%ebx
f010128a:	c1 fb 03             	sar    $0x3,%ebx
f010128d:	c1 e3 0c             	shl    $0xc,%ebx
	*pte = page2pa(pp) | perm | PTE_P;
f0101290:	0b 5d 14             	or     0x14(%ebp),%ebx
f0101293:	83 cb 01             	or     $0x1,%ebx
f0101296:	89 1e                	mov    %ebx,(%esi)
	return 0;
f0101298:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010129d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01012a0:	5b                   	pop    %ebx
f01012a1:	5e                   	pop    %esi
f01012a2:	5f                   	pop    %edi
f01012a3:	5d                   	pop    %ebp
f01012a4:	c3                   	ret    
		 page_remove(pgdir, va);
f01012a5:	83 ec 08             	sub    $0x8,%esp
f01012a8:	57                   	push   %edi
f01012a9:	ff 75 08             	pushl  0x8(%ebp)
f01012ac:	e8 60 ff ff ff       	call   f0101211 <page_remove>
f01012b1:	83 c4 10             	add    $0x10,%esp
f01012b4:	eb ce                	jmp    f0101284 <page_insert+0x2d>
		 return -E_NO_MEM;
f01012b6:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01012bb:	eb e0                	jmp    f010129d <page_insert+0x46>

f01012bd <mmio_map_region>:
{
f01012bd:	55                   	push   %ebp
f01012be:	89 e5                	mov    %esp,%ebp
f01012c0:	53                   	push   %ebx
f01012c1:	83 ec 04             	sub    $0x4,%esp
    size_t rounded_size = ROUNDUP(size, PGSIZE);
f01012c4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01012c7:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
f01012cd:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    if (base + rounded_size > MMIOLIM) panic("memory overflow ");
f01012d3:	8b 15 00 13 12 f0    	mov    0xf0121300,%edx
f01012d9:	8d 04 1a             	lea    (%edx,%ebx,1),%eax
f01012dc:	3d 00 00 c0 ef       	cmp    $0xefc00000,%eax
f01012e1:	77 26                	ja     f0101309 <mmio_map_region+0x4c>
    boot_map_region(kern_pgdir, base, rounded_size, pa, PTE_W|PTE_PCD|PTE_PWT);
f01012e3:	83 ec 08             	sub    $0x8,%esp
f01012e6:	6a 1a                	push   $0x1a
f01012e8:	ff 75 08             	pushl  0x8(%ebp)
f01012eb:	89 d9                	mov    %ebx,%ecx
f01012ed:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f01012f2:	e8 35 fe ff ff       	call   f010112c <boot_map_region>
    uintptr_t return_base = base;
f01012f7:	a1 00 13 12 f0       	mov    0xf0121300,%eax
    base += rounded_size;
f01012fc:	01 c3                	add    %eax,%ebx
f01012fe:	89 1d 00 13 12 f0    	mov    %ebx,0xf0121300
}
f0101304:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101307:	c9                   	leave  
f0101308:	c3                   	ret    
    if (base + rounded_size > MMIOLIM) panic("memory overflow ");
f0101309:	83 ec 04             	sub    $0x4,%esp
f010130c:	68 ed 66 10 f0       	push   $0xf01066ed
f0101311:	68 84 02 00 00       	push   $0x284
f0101316:	68 05 66 10 f0       	push   $0xf0106605
f010131b:	e8 74 ed ff ff       	call   f0100094 <_panic>

f0101320 <mem_init>:
{
f0101320:	55                   	push   %ebp
f0101321:	89 e5                	mov    %esp,%ebp
f0101323:	57                   	push   %edi
f0101324:	56                   	push   %esi
f0101325:	53                   	push   %ebx
f0101326:	83 ec 3c             	sub    $0x3c,%esp
	basemem = nvram_read(NVRAM_BASELO);
f0101329:	b8 15 00 00 00       	mov    $0x15,%eax
f010132e:	e8 cb f7 ff ff       	call   f0100afe <nvram_read>
f0101333:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f0101335:	b8 17 00 00 00       	mov    $0x17,%eax
f010133a:	e8 bf f7 ff ff       	call   f0100afe <nvram_read>
f010133f:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f0101341:	b8 34 00 00 00       	mov    $0x34,%eax
f0101346:	e8 b3 f7 ff ff       	call   f0100afe <nvram_read>
	if (ext16mem)
f010134b:	c1 e0 06             	shl    $0x6,%eax
f010134e:	0f 84 ea 00 00 00    	je     f010143e <mem_init+0x11e>
		totalmem = 16 * 1024 + ext16mem;
f0101354:	05 00 40 00 00       	add    $0x4000,%eax
	npages = totalmem / (PGSIZE / 1024);
f0101359:	89 c2                	mov    %eax,%edx
f010135b:	c1 ea 02             	shr    $0x2,%edx
f010135e:	89 15 88 1e 23 f0    	mov    %edx,0xf0231e88
	npages_basemem = basemem / (PGSIZE / 1024);
f0101364:	89 da                	mov    %ebx,%edx
f0101366:	c1 ea 02             	shr    $0x2,%edx
f0101369:	89 15 40 12 23 f0    	mov    %edx,0xf0231240
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010136f:	89 c2                	mov    %eax,%edx
f0101371:	29 da                	sub    %ebx,%edx
f0101373:	52                   	push   %edx
f0101374:	53                   	push   %ebx
f0101375:	50                   	push   %eax
f0101376:	68 24 5e 10 f0       	push   $0xf0105e24
f010137b:	e8 72 24 00 00       	call   f01037f2 <cprintf>
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0101380:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101385:	e8 3e f7 ff ff       	call   f0100ac8 <boot_alloc>
f010138a:	a3 8c 1e 23 f0       	mov    %eax,0xf0231e8c
	memset(kern_pgdir, 0, PGSIZE);
f010138f:	83 c4 0c             	add    $0xc,%esp
f0101392:	68 00 10 00 00       	push   $0x1000
f0101397:	6a 00                	push   $0x0
f0101399:	50                   	push   %eax
f010139a:	e8 05 37 00 00       	call   f0104aa4 <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f010139f:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f01013a4:	83 c4 10             	add    $0x10,%esp
f01013a7:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01013ac:	0f 86 9c 00 00 00    	jbe    f010144e <mem_init+0x12e>
	return (physaddr_t)kva - KERNBASE;
f01013b2:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01013b8:	83 ca 05             	or     $0x5,%edx
f01013bb:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	pages = (struct PageInfo*) boot_alloc(npages * sizeof(struct PageInfo));
f01013c1:	a1 88 1e 23 f0       	mov    0xf0231e88,%eax
f01013c6:	c1 e0 03             	shl    $0x3,%eax
f01013c9:	e8 fa f6 ff ff       	call   f0100ac8 <boot_alloc>
f01013ce:	a3 90 1e 23 f0       	mov    %eax,0xf0231e90
	memset(pages, 0, npages * sizeof(struct PageInfo));
f01013d3:	83 ec 04             	sub    $0x4,%esp
f01013d6:	8b 0d 88 1e 23 f0    	mov    0xf0231e88,%ecx
f01013dc:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f01013e3:	52                   	push   %edx
f01013e4:	6a 00                	push   $0x0
f01013e6:	50                   	push   %eax
f01013e7:	e8 b8 36 00 00       	call   f0104aa4 <memset>
	envs = (struct Env*) boot_alloc(NENV * sizeof(struct Env));
f01013ec:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f01013f1:	e8 d2 f6 ff ff       	call   f0100ac8 <boot_alloc>
f01013f6:	a3 44 12 23 f0       	mov    %eax,0xf0231244
	memset(envs, 0, NENV * sizeof(struct Env));
f01013fb:	83 c4 0c             	add    $0xc,%esp
f01013fe:	68 00 f0 01 00       	push   $0x1f000
f0101403:	6a 00                	push   $0x0
f0101405:	50                   	push   %eax
f0101406:	e8 99 36 00 00       	call   f0104aa4 <memset>
	page_init();
f010140b:	e8 7b fa ff ff       	call   f0100e8b <page_init>
	check_page_free_list(1);
f0101410:	b8 01 00 00 00       	mov    $0x1,%eax
f0101415:	e8 71 f7 ff ff       	call   f0100b8b <check_page_free_list>
	if (!pages)
f010141a:	83 c4 10             	add    $0x10,%esp
f010141d:	83 3d 90 1e 23 f0 00 	cmpl   $0x0,0xf0231e90
f0101424:	74 3d                	je     f0101463 <mem_init+0x143>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101426:	a1 3c 12 23 f0       	mov    0xf023123c,%eax
f010142b:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f0101432:	85 c0                	test   %eax,%eax
f0101434:	74 44                	je     f010147a <mem_init+0x15a>
		++nfree;
f0101436:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010143a:	8b 00                	mov    (%eax),%eax
f010143c:	eb f4                	jmp    f0101432 <mem_init+0x112>
		totalmem = 1 * 1024 + extmem;
f010143e:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f0101444:	85 f6                	test   %esi,%esi
f0101446:	0f 44 c3             	cmove  %ebx,%eax
f0101449:	e9 0b ff ff ff       	jmp    f0101359 <mem_init+0x39>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010144e:	50                   	push   %eax
f010144f:	68 d8 57 10 f0       	push   $0xf01057d8
f0101454:	68 a3 00 00 00       	push   $0xa3
f0101459:	68 05 66 10 f0       	push   $0xf0106605
f010145e:	e8 31 ec ff ff       	call   f0100094 <_panic>
		panic("'pages' is a null pointer!");
f0101463:	83 ec 04             	sub    $0x4,%esp
f0101466:	68 fe 66 10 f0       	push   $0xf01066fe
f010146b:	68 0f 03 00 00       	push   $0x30f
f0101470:	68 05 66 10 f0       	push   $0xf0106605
f0101475:	e8 1a ec ff ff       	call   f0100094 <_panic>
	assert((pp0 = page_alloc(0)));
f010147a:	83 ec 0c             	sub    $0xc,%esp
f010147d:	6a 00                	push   $0x0
f010147f:	e8 12 fb ff ff       	call   f0100f96 <page_alloc>
f0101484:	89 c3                	mov    %eax,%ebx
f0101486:	83 c4 10             	add    $0x10,%esp
f0101489:	85 c0                	test   %eax,%eax
f010148b:	0f 84 00 02 00 00    	je     f0101691 <mem_init+0x371>
	assert((pp1 = page_alloc(0)));
f0101491:	83 ec 0c             	sub    $0xc,%esp
f0101494:	6a 00                	push   $0x0
f0101496:	e8 fb fa ff ff       	call   f0100f96 <page_alloc>
f010149b:	89 c6                	mov    %eax,%esi
f010149d:	83 c4 10             	add    $0x10,%esp
f01014a0:	85 c0                	test   %eax,%eax
f01014a2:	0f 84 02 02 00 00    	je     f01016aa <mem_init+0x38a>
	assert((pp2 = page_alloc(0)));
f01014a8:	83 ec 0c             	sub    $0xc,%esp
f01014ab:	6a 00                	push   $0x0
f01014ad:	e8 e4 fa ff ff       	call   f0100f96 <page_alloc>
f01014b2:	89 c7                	mov    %eax,%edi
f01014b4:	83 c4 10             	add    $0x10,%esp
f01014b7:	85 c0                	test   %eax,%eax
f01014b9:	0f 84 04 02 00 00    	je     f01016c3 <mem_init+0x3a3>
	assert(pp1 && pp1 != pp0);
f01014bf:	39 f3                	cmp    %esi,%ebx
f01014c1:	0f 84 15 02 00 00    	je     f01016dc <mem_init+0x3bc>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01014c7:	39 c6                	cmp    %eax,%esi
f01014c9:	0f 84 26 02 00 00    	je     f01016f5 <mem_init+0x3d5>
f01014cf:	39 c3                	cmp    %eax,%ebx
f01014d1:	0f 84 1e 02 00 00    	je     f01016f5 <mem_init+0x3d5>
	return (pp - pages) << PGSHIFT;
f01014d7:	8b 0d 90 1e 23 f0    	mov    0xf0231e90,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f01014dd:	8b 15 88 1e 23 f0    	mov    0xf0231e88,%edx
f01014e3:	c1 e2 0c             	shl    $0xc,%edx
f01014e6:	89 d8                	mov    %ebx,%eax
f01014e8:	29 c8                	sub    %ecx,%eax
f01014ea:	c1 f8 03             	sar    $0x3,%eax
f01014ed:	c1 e0 0c             	shl    $0xc,%eax
f01014f0:	39 d0                	cmp    %edx,%eax
f01014f2:	0f 83 16 02 00 00    	jae    f010170e <mem_init+0x3ee>
f01014f8:	89 f0                	mov    %esi,%eax
f01014fa:	29 c8                	sub    %ecx,%eax
f01014fc:	c1 f8 03             	sar    $0x3,%eax
f01014ff:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp1) < npages*PGSIZE);
f0101502:	39 c2                	cmp    %eax,%edx
f0101504:	0f 86 1d 02 00 00    	jbe    f0101727 <mem_init+0x407>
f010150a:	89 f8                	mov    %edi,%eax
f010150c:	29 c8                	sub    %ecx,%eax
f010150e:	c1 f8 03             	sar    $0x3,%eax
f0101511:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp2) < npages*PGSIZE);
f0101514:	39 c2                	cmp    %eax,%edx
f0101516:	0f 86 24 02 00 00    	jbe    f0101740 <mem_init+0x420>
	fl = page_free_list;
f010151c:	a1 3c 12 23 f0       	mov    0xf023123c,%eax
f0101521:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101524:	c7 05 3c 12 23 f0 00 	movl   $0x0,0xf023123c
f010152b:	00 00 00 
	assert(!page_alloc(0));
f010152e:	83 ec 0c             	sub    $0xc,%esp
f0101531:	6a 00                	push   $0x0
f0101533:	e8 5e fa ff ff       	call   f0100f96 <page_alloc>
f0101538:	83 c4 10             	add    $0x10,%esp
f010153b:	85 c0                	test   %eax,%eax
f010153d:	0f 85 16 02 00 00    	jne    f0101759 <mem_init+0x439>
	page_free(pp0);
f0101543:	83 ec 0c             	sub    $0xc,%esp
f0101546:	53                   	push   %ebx
f0101547:	e8 bc fa ff ff       	call   f0101008 <page_free>
	page_free(pp1);
f010154c:	89 34 24             	mov    %esi,(%esp)
f010154f:	e8 b4 fa ff ff       	call   f0101008 <page_free>
	page_free(pp2);
f0101554:	89 3c 24             	mov    %edi,(%esp)
f0101557:	e8 ac fa ff ff       	call   f0101008 <page_free>
	assert((pp0 = page_alloc(0)));
f010155c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101563:	e8 2e fa ff ff       	call   f0100f96 <page_alloc>
f0101568:	89 c3                	mov    %eax,%ebx
f010156a:	83 c4 10             	add    $0x10,%esp
f010156d:	85 c0                	test   %eax,%eax
f010156f:	0f 84 fd 01 00 00    	je     f0101772 <mem_init+0x452>
	assert((pp1 = page_alloc(0)));
f0101575:	83 ec 0c             	sub    $0xc,%esp
f0101578:	6a 00                	push   $0x0
f010157a:	e8 17 fa ff ff       	call   f0100f96 <page_alloc>
f010157f:	89 c6                	mov    %eax,%esi
f0101581:	83 c4 10             	add    $0x10,%esp
f0101584:	85 c0                	test   %eax,%eax
f0101586:	0f 84 ff 01 00 00    	je     f010178b <mem_init+0x46b>
	assert((pp2 = page_alloc(0)));
f010158c:	83 ec 0c             	sub    $0xc,%esp
f010158f:	6a 00                	push   $0x0
f0101591:	e8 00 fa ff ff       	call   f0100f96 <page_alloc>
f0101596:	89 c7                	mov    %eax,%edi
f0101598:	83 c4 10             	add    $0x10,%esp
f010159b:	85 c0                	test   %eax,%eax
f010159d:	0f 84 01 02 00 00    	je     f01017a4 <mem_init+0x484>
	assert(pp1 && pp1 != pp0);
f01015a3:	39 f3                	cmp    %esi,%ebx
f01015a5:	0f 84 12 02 00 00    	je     f01017bd <mem_init+0x49d>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01015ab:	39 c3                	cmp    %eax,%ebx
f01015ad:	0f 84 23 02 00 00    	je     f01017d6 <mem_init+0x4b6>
f01015b3:	39 c6                	cmp    %eax,%esi
f01015b5:	0f 84 1b 02 00 00    	je     f01017d6 <mem_init+0x4b6>
	assert(!page_alloc(0));
f01015bb:	83 ec 0c             	sub    $0xc,%esp
f01015be:	6a 00                	push   $0x0
f01015c0:	e8 d1 f9 ff ff       	call   f0100f96 <page_alloc>
f01015c5:	83 c4 10             	add    $0x10,%esp
f01015c8:	85 c0                	test   %eax,%eax
f01015ca:	0f 85 1f 02 00 00    	jne    f01017ef <mem_init+0x4cf>
f01015d0:	89 d8                	mov    %ebx,%eax
f01015d2:	2b 05 90 1e 23 f0    	sub    0xf0231e90,%eax
f01015d8:	c1 f8 03             	sar    $0x3,%eax
f01015db:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f01015de:	89 c2                	mov    %eax,%edx
f01015e0:	c1 ea 0c             	shr    $0xc,%edx
f01015e3:	3b 15 88 1e 23 f0    	cmp    0xf0231e88,%edx
f01015e9:	0f 83 19 02 00 00    	jae    f0101808 <mem_init+0x4e8>
	memset(page2kva(pp0), 1, PGSIZE);
f01015ef:	83 ec 04             	sub    $0x4,%esp
f01015f2:	68 00 10 00 00       	push   $0x1000
f01015f7:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f01015f9:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01015fe:	50                   	push   %eax
f01015ff:	e8 a0 34 00 00       	call   f0104aa4 <memset>
	page_free(pp0);
f0101604:	89 1c 24             	mov    %ebx,(%esp)
f0101607:	e8 fc f9 ff ff       	call   f0101008 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f010160c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101613:	e8 7e f9 ff ff       	call   f0100f96 <page_alloc>
f0101618:	83 c4 10             	add    $0x10,%esp
f010161b:	85 c0                	test   %eax,%eax
f010161d:	0f 84 f7 01 00 00    	je     f010181a <mem_init+0x4fa>
	assert(pp && pp0 == pp);
f0101623:	39 c3                	cmp    %eax,%ebx
f0101625:	0f 85 08 02 00 00    	jne    f0101833 <mem_init+0x513>
	return (pp - pages) << PGSHIFT;
f010162b:	2b 05 90 1e 23 f0    	sub    0xf0231e90,%eax
f0101631:	c1 f8 03             	sar    $0x3,%eax
f0101634:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0101637:	89 c2                	mov    %eax,%edx
f0101639:	c1 ea 0c             	shr    $0xc,%edx
f010163c:	3b 15 88 1e 23 f0    	cmp    0xf0231e88,%edx
f0101642:	0f 83 04 02 00 00    	jae    f010184c <mem_init+0x52c>
	return (void *)(pa + KERNBASE);
f0101648:	8d 90 00 00 00 f0    	lea    -0x10000000(%eax),%edx
f010164e:	2d 00 f0 ff 0f       	sub    $0xffff000,%eax
		assert(c[i] == 0);
f0101653:	80 3a 00             	cmpb   $0x0,(%edx)
f0101656:	0f 85 02 02 00 00    	jne    f010185e <mem_init+0x53e>
f010165c:	83 c2 01             	add    $0x1,%edx
	for (i = 0; i < PGSIZE; i++)
f010165f:	39 c2                	cmp    %eax,%edx
f0101661:	75 f0                	jne    f0101653 <mem_init+0x333>
	page_free_list = fl;
f0101663:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101666:	a3 3c 12 23 f0       	mov    %eax,0xf023123c
	page_free(pp0);
f010166b:	83 ec 0c             	sub    $0xc,%esp
f010166e:	53                   	push   %ebx
f010166f:	e8 94 f9 ff ff       	call   f0101008 <page_free>
	page_free(pp1);
f0101674:	89 34 24             	mov    %esi,(%esp)
f0101677:	e8 8c f9 ff ff       	call   f0101008 <page_free>
	page_free(pp2);
f010167c:	89 3c 24             	mov    %edi,(%esp)
f010167f:	e8 84 f9 ff ff       	call   f0101008 <page_free>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101684:	a1 3c 12 23 f0       	mov    0xf023123c,%eax
f0101689:	83 c4 10             	add    $0x10,%esp
f010168c:	e9 ec 01 00 00       	jmp    f010187d <mem_init+0x55d>
	assert((pp0 = page_alloc(0)));
f0101691:	68 19 67 10 f0       	push   $0xf0106719
f0101696:	68 32 66 10 f0       	push   $0xf0106632
f010169b:	68 17 03 00 00       	push   $0x317
f01016a0:	68 05 66 10 f0       	push   $0xf0106605
f01016a5:	e8 ea e9 ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f01016aa:	68 2f 67 10 f0       	push   $0xf010672f
f01016af:	68 32 66 10 f0       	push   $0xf0106632
f01016b4:	68 18 03 00 00       	push   $0x318
f01016b9:	68 05 66 10 f0       	push   $0xf0106605
f01016be:	e8 d1 e9 ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f01016c3:	68 45 67 10 f0       	push   $0xf0106745
f01016c8:	68 32 66 10 f0       	push   $0xf0106632
f01016cd:	68 19 03 00 00       	push   $0x319
f01016d2:	68 05 66 10 f0       	push   $0xf0106605
f01016d7:	e8 b8 e9 ff ff       	call   f0100094 <_panic>
	assert(pp1 && pp1 != pp0);
f01016dc:	68 5b 67 10 f0       	push   $0xf010675b
f01016e1:	68 32 66 10 f0       	push   $0xf0106632
f01016e6:	68 1c 03 00 00       	push   $0x31c
f01016eb:	68 05 66 10 f0       	push   $0xf0106605
f01016f0:	e8 9f e9 ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01016f5:	68 60 5e 10 f0       	push   $0xf0105e60
f01016fa:	68 32 66 10 f0       	push   $0xf0106632
f01016ff:	68 1d 03 00 00       	push   $0x31d
f0101704:	68 05 66 10 f0       	push   $0xf0106605
f0101709:	e8 86 e9 ff ff       	call   f0100094 <_panic>
	assert(page2pa(pp0) < npages*PGSIZE);
f010170e:	68 6d 67 10 f0       	push   $0xf010676d
f0101713:	68 32 66 10 f0       	push   $0xf0106632
f0101718:	68 1e 03 00 00       	push   $0x31e
f010171d:	68 05 66 10 f0       	push   $0xf0106605
f0101722:	e8 6d e9 ff ff       	call   f0100094 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0101727:	68 8a 67 10 f0       	push   $0xf010678a
f010172c:	68 32 66 10 f0       	push   $0xf0106632
f0101731:	68 1f 03 00 00       	push   $0x31f
f0101736:	68 05 66 10 f0       	push   $0xf0106605
f010173b:	e8 54 e9 ff ff       	call   f0100094 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f0101740:	68 a7 67 10 f0       	push   $0xf01067a7
f0101745:	68 32 66 10 f0       	push   $0xf0106632
f010174a:	68 20 03 00 00       	push   $0x320
f010174f:	68 05 66 10 f0       	push   $0xf0106605
f0101754:	e8 3b e9 ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f0101759:	68 c4 67 10 f0       	push   $0xf01067c4
f010175e:	68 32 66 10 f0       	push   $0xf0106632
f0101763:	68 27 03 00 00       	push   $0x327
f0101768:	68 05 66 10 f0       	push   $0xf0106605
f010176d:	e8 22 e9 ff ff       	call   f0100094 <_panic>
	assert((pp0 = page_alloc(0)));
f0101772:	68 19 67 10 f0       	push   $0xf0106719
f0101777:	68 32 66 10 f0       	push   $0xf0106632
f010177c:	68 2e 03 00 00       	push   $0x32e
f0101781:	68 05 66 10 f0       	push   $0xf0106605
f0101786:	e8 09 e9 ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f010178b:	68 2f 67 10 f0       	push   $0xf010672f
f0101790:	68 32 66 10 f0       	push   $0xf0106632
f0101795:	68 2f 03 00 00       	push   $0x32f
f010179a:	68 05 66 10 f0       	push   $0xf0106605
f010179f:	e8 f0 e8 ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f01017a4:	68 45 67 10 f0       	push   $0xf0106745
f01017a9:	68 32 66 10 f0       	push   $0xf0106632
f01017ae:	68 30 03 00 00       	push   $0x330
f01017b3:	68 05 66 10 f0       	push   $0xf0106605
f01017b8:	e8 d7 e8 ff ff       	call   f0100094 <_panic>
	assert(pp1 && pp1 != pp0);
f01017bd:	68 5b 67 10 f0       	push   $0xf010675b
f01017c2:	68 32 66 10 f0       	push   $0xf0106632
f01017c7:	68 32 03 00 00       	push   $0x332
f01017cc:	68 05 66 10 f0       	push   $0xf0106605
f01017d1:	e8 be e8 ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01017d6:	68 60 5e 10 f0       	push   $0xf0105e60
f01017db:	68 32 66 10 f0       	push   $0xf0106632
f01017e0:	68 33 03 00 00       	push   $0x333
f01017e5:	68 05 66 10 f0       	push   $0xf0106605
f01017ea:	e8 a5 e8 ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f01017ef:	68 c4 67 10 f0       	push   $0xf01067c4
f01017f4:	68 32 66 10 f0       	push   $0xf0106632
f01017f9:	68 34 03 00 00       	push   $0x334
f01017fe:	68 05 66 10 f0       	push   $0xf0106605
f0101803:	e8 8c e8 ff ff       	call   f0100094 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101808:	50                   	push   %eax
f0101809:	68 b4 57 10 f0       	push   $0xf01057b4
f010180e:	6a 58                	push   $0x58
f0101810:	68 18 66 10 f0       	push   $0xf0106618
f0101815:	e8 7a e8 ff ff       	call   f0100094 <_panic>
	assert((pp = page_alloc(ALLOC_ZERO)));
f010181a:	68 d3 67 10 f0       	push   $0xf01067d3
f010181f:	68 32 66 10 f0       	push   $0xf0106632
f0101824:	68 39 03 00 00       	push   $0x339
f0101829:	68 05 66 10 f0       	push   $0xf0106605
f010182e:	e8 61 e8 ff ff       	call   f0100094 <_panic>
	assert(pp && pp0 == pp);
f0101833:	68 f1 67 10 f0       	push   $0xf01067f1
f0101838:	68 32 66 10 f0       	push   $0xf0106632
f010183d:	68 3a 03 00 00       	push   $0x33a
f0101842:	68 05 66 10 f0       	push   $0xf0106605
f0101847:	e8 48 e8 ff ff       	call   f0100094 <_panic>
f010184c:	50                   	push   %eax
f010184d:	68 b4 57 10 f0       	push   $0xf01057b4
f0101852:	6a 58                	push   $0x58
f0101854:	68 18 66 10 f0       	push   $0xf0106618
f0101859:	e8 36 e8 ff ff       	call   f0100094 <_panic>
		assert(c[i] == 0);
f010185e:	68 01 68 10 f0       	push   $0xf0106801
f0101863:	68 32 66 10 f0       	push   $0xf0106632
f0101868:	68 3d 03 00 00       	push   $0x33d
f010186d:	68 05 66 10 f0       	push   $0xf0106605
f0101872:	e8 1d e8 ff ff       	call   f0100094 <_panic>
		--nfree;
f0101877:	83 6d d4 01          	subl   $0x1,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010187b:	8b 00                	mov    (%eax),%eax
f010187d:	85 c0                	test   %eax,%eax
f010187f:	75 f6                	jne    f0101877 <mem_init+0x557>
	assert(nfree == 0);
f0101881:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0101885:	0f 85 65 09 00 00    	jne    f01021f0 <mem_init+0xed0>
	cprintf("check_page_alloc() succeeded!\n");
f010188b:	83 ec 0c             	sub    $0xc,%esp
f010188e:	68 80 5e 10 f0       	push   $0xf0105e80
f0101893:	e8 5a 1f 00 00       	call   f01037f2 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101898:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010189f:	e8 f2 f6 ff ff       	call   f0100f96 <page_alloc>
f01018a4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01018a7:	83 c4 10             	add    $0x10,%esp
f01018aa:	85 c0                	test   %eax,%eax
f01018ac:	0f 84 57 09 00 00    	je     f0102209 <mem_init+0xee9>
	assert((pp1 = page_alloc(0)));
f01018b2:	83 ec 0c             	sub    $0xc,%esp
f01018b5:	6a 00                	push   $0x0
f01018b7:	e8 da f6 ff ff       	call   f0100f96 <page_alloc>
f01018bc:	89 c7                	mov    %eax,%edi
f01018be:	83 c4 10             	add    $0x10,%esp
f01018c1:	85 c0                	test   %eax,%eax
f01018c3:	0f 84 59 09 00 00    	je     f0102222 <mem_init+0xf02>
	assert((pp2 = page_alloc(0)));
f01018c9:	83 ec 0c             	sub    $0xc,%esp
f01018cc:	6a 00                	push   $0x0
f01018ce:	e8 c3 f6 ff ff       	call   f0100f96 <page_alloc>
f01018d3:	89 c3                	mov    %eax,%ebx
f01018d5:	83 c4 10             	add    $0x10,%esp
f01018d8:	85 c0                	test   %eax,%eax
f01018da:	0f 84 5b 09 00 00    	je     f010223b <mem_init+0xf1b>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01018e0:	39 7d d4             	cmp    %edi,-0x2c(%ebp)
f01018e3:	0f 84 6b 09 00 00    	je     f0102254 <mem_init+0xf34>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01018e9:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f01018ec:	0f 84 7b 09 00 00    	je     f010226d <mem_init+0xf4d>
f01018f2:	39 c7                	cmp    %eax,%edi
f01018f4:	0f 84 73 09 00 00    	je     f010226d <mem_init+0xf4d>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01018fa:	a1 3c 12 23 f0       	mov    0xf023123c,%eax
f01018ff:	89 45 cc             	mov    %eax,-0x34(%ebp)
	page_free_list = 0;
f0101902:	c7 05 3c 12 23 f0 00 	movl   $0x0,0xf023123c
f0101909:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f010190c:	83 ec 0c             	sub    $0xc,%esp
f010190f:	6a 00                	push   $0x0
f0101911:	e8 80 f6 ff ff       	call   f0100f96 <page_alloc>
f0101916:	83 c4 10             	add    $0x10,%esp
f0101919:	85 c0                	test   %eax,%eax
f010191b:	0f 85 65 09 00 00    	jne    f0102286 <mem_init+0xf66>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101921:	83 ec 04             	sub    $0x4,%esp
f0101924:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101927:	50                   	push   %eax
f0101928:	6a 00                	push   $0x0
f010192a:	ff 35 8c 1e 23 f0    	pushl  0xf0231e8c
f0101930:	e8 4b f8 ff ff       	call   f0101180 <page_lookup>
f0101935:	83 c4 10             	add    $0x10,%esp
f0101938:	85 c0                	test   %eax,%eax
f010193a:	0f 85 5f 09 00 00    	jne    f010229f <mem_init+0xf7f>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101940:	6a 02                	push   $0x2
f0101942:	6a 00                	push   $0x0
f0101944:	57                   	push   %edi
f0101945:	ff 35 8c 1e 23 f0    	pushl  0xf0231e8c
f010194b:	e8 07 f9 ff ff       	call   f0101257 <page_insert>
f0101950:	83 c4 10             	add    $0x10,%esp
f0101953:	85 c0                	test   %eax,%eax
f0101955:	0f 89 5d 09 00 00    	jns    f01022b8 <mem_init+0xf98>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f010195b:	83 ec 0c             	sub    $0xc,%esp
f010195e:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101961:	e8 a2 f6 ff ff       	call   f0101008 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101966:	6a 02                	push   $0x2
f0101968:	6a 00                	push   $0x0
f010196a:	57                   	push   %edi
f010196b:	ff 35 8c 1e 23 f0    	pushl  0xf0231e8c
f0101971:	e8 e1 f8 ff ff       	call   f0101257 <page_insert>
f0101976:	83 c4 20             	add    $0x20,%esp
f0101979:	85 c0                	test   %eax,%eax
f010197b:	0f 85 50 09 00 00    	jne    f01022d1 <mem_init+0xfb1>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101981:	8b 35 8c 1e 23 f0    	mov    0xf0231e8c,%esi
	return (pp - pages) << PGSHIFT;
f0101987:	8b 0d 90 1e 23 f0    	mov    0xf0231e90,%ecx
f010198d:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0101990:	8b 16                	mov    (%esi),%edx
f0101992:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101998:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010199b:	29 c8                	sub    %ecx,%eax
f010199d:	c1 f8 03             	sar    $0x3,%eax
f01019a0:	c1 e0 0c             	shl    $0xc,%eax
f01019a3:	39 c2                	cmp    %eax,%edx
f01019a5:	0f 85 3f 09 00 00    	jne    f01022ea <mem_init+0xfca>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f01019ab:	ba 00 00 00 00       	mov    $0x0,%edx
f01019b0:	89 f0                	mov    %esi,%eax
f01019b2:	e8 70 f1 ff ff       	call   f0100b27 <check_va2pa>
f01019b7:	89 fa                	mov    %edi,%edx
f01019b9:	2b 55 d0             	sub    -0x30(%ebp),%edx
f01019bc:	c1 fa 03             	sar    $0x3,%edx
f01019bf:	c1 e2 0c             	shl    $0xc,%edx
f01019c2:	39 d0                	cmp    %edx,%eax
f01019c4:	0f 85 39 09 00 00    	jne    f0102303 <mem_init+0xfe3>
	assert(pp1->pp_ref == 1);
f01019ca:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01019cf:	0f 85 47 09 00 00    	jne    f010231c <mem_init+0xffc>
	assert(pp0->pp_ref == 1);
f01019d5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01019d8:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f01019dd:	0f 85 52 09 00 00    	jne    f0102335 <mem_init+0x1015>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01019e3:	6a 02                	push   $0x2
f01019e5:	68 00 10 00 00       	push   $0x1000
f01019ea:	53                   	push   %ebx
f01019eb:	56                   	push   %esi
f01019ec:	e8 66 f8 ff ff       	call   f0101257 <page_insert>
f01019f1:	83 c4 10             	add    $0x10,%esp
f01019f4:	85 c0                	test   %eax,%eax
f01019f6:	0f 85 52 09 00 00    	jne    f010234e <mem_init+0x102e>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01019fc:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101a01:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f0101a06:	e8 1c f1 ff ff       	call   f0100b27 <check_va2pa>
f0101a0b:	89 da                	mov    %ebx,%edx
f0101a0d:	2b 15 90 1e 23 f0    	sub    0xf0231e90,%edx
f0101a13:	c1 fa 03             	sar    $0x3,%edx
f0101a16:	c1 e2 0c             	shl    $0xc,%edx
f0101a19:	39 d0                	cmp    %edx,%eax
f0101a1b:	0f 85 46 09 00 00    	jne    f0102367 <mem_init+0x1047>
	assert(pp2->pp_ref == 1);
f0101a21:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101a26:	0f 85 54 09 00 00    	jne    f0102380 <mem_init+0x1060>

	// should be no free memory
	assert(!page_alloc(0));
f0101a2c:	83 ec 0c             	sub    $0xc,%esp
f0101a2f:	6a 00                	push   $0x0
f0101a31:	e8 60 f5 ff ff       	call   f0100f96 <page_alloc>
f0101a36:	83 c4 10             	add    $0x10,%esp
f0101a39:	85 c0                	test   %eax,%eax
f0101a3b:	0f 85 58 09 00 00    	jne    f0102399 <mem_init+0x1079>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101a41:	6a 02                	push   $0x2
f0101a43:	68 00 10 00 00       	push   $0x1000
f0101a48:	53                   	push   %ebx
f0101a49:	ff 35 8c 1e 23 f0    	pushl  0xf0231e8c
f0101a4f:	e8 03 f8 ff ff       	call   f0101257 <page_insert>
f0101a54:	83 c4 10             	add    $0x10,%esp
f0101a57:	85 c0                	test   %eax,%eax
f0101a59:	0f 85 53 09 00 00    	jne    f01023b2 <mem_init+0x1092>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101a5f:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101a64:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f0101a69:	e8 b9 f0 ff ff       	call   f0100b27 <check_va2pa>
f0101a6e:	89 da                	mov    %ebx,%edx
f0101a70:	2b 15 90 1e 23 f0    	sub    0xf0231e90,%edx
f0101a76:	c1 fa 03             	sar    $0x3,%edx
f0101a79:	c1 e2 0c             	shl    $0xc,%edx
f0101a7c:	39 d0                	cmp    %edx,%eax
f0101a7e:	0f 85 47 09 00 00    	jne    f01023cb <mem_init+0x10ab>
	assert(pp2->pp_ref == 1);
f0101a84:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101a89:	0f 85 55 09 00 00    	jne    f01023e4 <mem_init+0x10c4>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101a8f:	83 ec 0c             	sub    $0xc,%esp
f0101a92:	6a 00                	push   $0x0
f0101a94:	e8 fd f4 ff ff       	call   f0100f96 <page_alloc>
f0101a99:	83 c4 10             	add    $0x10,%esp
f0101a9c:	85 c0                	test   %eax,%eax
f0101a9e:	0f 85 59 09 00 00    	jne    f01023fd <mem_init+0x10dd>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101aa4:	8b 15 8c 1e 23 f0    	mov    0xf0231e8c,%edx
f0101aaa:	8b 02                	mov    (%edx),%eax
f0101aac:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0101ab1:	89 c1                	mov    %eax,%ecx
f0101ab3:	c1 e9 0c             	shr    $0xc,%ecx
f0101ab6:	3b 0d 88 1e 23 f0    	cmp    0xf0231e88,%ecx
f0101abc:	0f 83 54 09 00 00    	jae    f0102416 <mem_init+0x10f6>
	return (void *)(pa + KERNBASE);
f0101ac2:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101ac7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101aca:	83 ec 04             	sub    $0x4,%esp
f0101acd:	6a 00                	push   $0x0
f0101acf:	68 00 10 00 00       	push   $0x1000
f0101ad4:	52                   	push   %edx
f0101ad5:	e8 92 f5 ff ff       	call   f010106c <pgdir_walk>
f0101ada:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101add:	8d 51 04             	lea    0x4(%ecx),%edx
f0101ae0:	83 c4 10             	add    $0x10,%esp
f0101ae3:	39 d0                	cmp    %edx,%eax
f0101ae5:	0f 85 40 09 00 00    	jne    f010242b <mem_init+0x110b>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101aeb:	6a 06                	push   $0x6
f0101aed:	68 00 10 00 00       	push   $0x1000
f0101af2:	53                   	push   %ebx
f0101af3:	ff 35 8c 1e 23 f0    	pushl  0xf0231e8c
f0101af9:	e8 59 f7 ff ff       	call   f0101257 <page_insert>
f0101afe:	83 c4 10             	add    $0x10,%esp
f0101b01:	85 c0                	test   %eax,%eax
f0101b03:	0f 85 3b 09 00 00    	jne    f0102444 <mem_init+0x1124>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101b09:	8b 35 8c 1e 23 f0    	mov    0xf0231e8c,%esi
f0101b0f:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101b14:	89 f0                	mov    %esi,%eax
f0101b16:	e8 0c f0 ff ff       	call   f0100b27 <check_va2pa>
	return (pp - pages) << PGSHIFT;
f0101b1b:	89 da                	mov    %ebx,%edx
f0101b1d:	2b 15 90 1e 23 f0    	sub    0xf0231e90,%edx
f0101b23:	c1 fa 03             	sar    $0x3,%edx
f0101b26:	c1 e2 0c             	shl    $0xc,%edx
f0101b29:	39 d0                	cmp    %edx,%eax
f0101b2b:	0f 85 2c 09 00 00    	jne    f010245d <mem_init+0x113d>
	assert(pp2->pp_ref == 1);
f0101b31:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101b36:	0f 85 3a 09 00 00    	jne    f0102476 <mem_init+0x1156>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101b3c:	83 ec 04             	sub    $0x4,%esp
f0101b3f:	6a 00                	push   $0x0
f0101b41:	68 00 10 00 00       	push   $0x1000
f0101b46:	56                   	push   %esi
f0101b47:	e8 20 f5 ff ff       	call   f010106c <pgdir_walk>
f0101b4c:	83 c4 10             	add    $0x10,%esp
f0101b4f:	f6 00 04             	testb  $0x4,(%eax)
f0101b52:	0f 84 37 09 00 00    	je     f010248f <mem_init+0x116f>
	assert(kern_pgdir[0] & PTE_U);
f0101b58:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f0101b5d:	f6 00 04             	testb  $0x4,(%eax)
f0101b60:	0f 84 42 09 00 00    	je     f01024a8 <mem_init+0x1188>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101b66:	6a 02                	push   $0x2
f0101b68:	68 00 10 00 00       	push   $0x1000
f0101b6d:	53                   	push   %ebx
f0101b6e:	50                   	push   %eax
f0101b6f:	e8 e3 f6 ff ff       	call   f0101257 <page_insert>
f0101b74:	83 c4 10             	add    $0x10,%esp
f0101b77:	85 c0                	test   %eax,%eax
f0101b79:	0f 85 42 09 00 00    	jne    f01024c1 <mem_init+0x11a1>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101b7f:	83 ec 04             	sub    $0x4,%esp
f0101b82:	6a 00                	push   $0x0
f0101b84:	68 00 10 00 00       	push   $0x1000
f0101b89:	ff 35 8c 1e 23 f0    	pushl  0xf0231e8c
f0101b8f:	e8 d8 f4 ff ff       	call   f010106c <pgdir_walk>
f0101b94:	83 c4 10             	add    $0x10,%esp
f0101b97:	f6 00 02             	testb  $0x2,(%eax)
f0101b9a:	0f 84 3a 09 00 00    	je     f01024da <mem_init+0x11ba>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101ba0:	83 ec 04             	sub    $0x4,%esp
f0101ba3:	6a 00                	push   $0x0
f0101ba5:	68 00 10 00 00       	push   $0x1000
f0101baa:	ff 35 8c 1e 23 f0    	pushl  0xf0231e8c
f0101bb0:	e8 b7 f4 ff ff       	call   f010106c <pgdir_walk>
f0101bb5:	83 c4 10             	add    $0x10,%esp
f0101bb8:	f6 00 04             	testb  $0x4,(%eax)
f0101bbb:	0f 85 32 09 00 00    	jne    f01024f3 <mem_init+0x11d3>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101bc1:	6a 02                	push   $0x2
f0101bc3:	68 00 00 40 00       	push   $0x400000
f0101bc8:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101bcb:	ff 35 8c 1e 23 f0    	pushl  0xf0231e8c
f0101bd1:	e8 81 f6 ff ff       	call   f0101257 <page_insert>
f0101bd6:	83 c4 10             	add    $0x10,%esp
f0101bd9:	85 c0                	test   %eax,%eax
f0101bdb:	0f 89 2b 09 00 00    	jns    f010250c <mem_init+0x11ec>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101be1:	6a 02                	push   $0x2
f0101be3:	68 00 10 00 00       	push   $0x1000
f0101be8:	57                   	push   %edi
f0101be9:	ff 35 8c 1e 23 f0    	pushl  0xf0231e8c
f0101bef:	e8 63 f6 ff ff       	call   f0101257 <page_insert>
f0101bf4:	83 c4 10             	add    $0x10,%esp
f0101bf7:	85 c0                	test   %eax,%eax
f0101bf9:	0f 85 26 09 00 00    	jne    f0102525 <mem_init+0x1205>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101bff:	83 ec 04             	sub    $0x4,%esp
f0101c02:	6a 00                	push   $0x0
f0101c04:	68 00 10 00 00       	push   $0x1000
f0101c09:	ff 35 8c 1e 23 f0    	pushl  0xf0231e8c
f0101c0f:	e8 58 f4 ff ff       	call   f010106c <pgdir_walk>
f0101c14:	83 c4 10             	add    $0x10,%esp
f0101c17:	f6 00 04             	testb  $0x4,(%eax)
f0101c1a:	0f 85 1e 09 00 00    	jne    f010253e <mem_init+0x121e>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101c20:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f0101c25:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101c28:	ba 00 00 00 00       	mov    $0x0,%edx
f0101c2d:	e8 f5 ee ff ff       	call   f0100b27 <check_va2pa>
f0101c32:	89 fe                	mov    %edi,%esi
f0101c34:	2b 35 90 1e 23 f0    	sub    0xf0231e90,%esi
f0101c3a:	c1 fe 03             	sar    $0x3,%esi
f0101c3d:	c1 e6 0c             	shl    $0xc,%esi
f0101c40:	39 f0                	cmp    %esi,%eax
f0101c42:	0f 85 0f 09 00 00    	jne    f0102557 <mem_init+0x1237>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101c48:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c4d:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101c50:	e8 d2 ee ff ff       	call   f0100b27 <check_va2pa>
f0101c55:	39 c6                	cmp    %eax,%esi
f0101c57:	0f 85 13 09 00 00    	jne    f0102570 <mem_init+0x1250>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101c5d:	66 83 7f 04 02       	cmpw   $0x2,0x4(%edi)
f0101c62:	0f 85 21 09 00 00    	jne    f0102589 <mem_init+0x1269>
	assert(pp2->pp_ref == 0);
f0101c68:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101c6d:	0f 85 2f 09 00 00    	jne    f01025a2 <mem_init+0x1282>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101c73:	83 ec 0c             	sub    $0xc,%esp
f0101c76:	6a 00                	push   $0x0
f0101c78:	e8 19 f3 ff ff       	call   f0100f96 <page_alloc>
f0101c7d:	83 c4 10             	add    $0x10,%esp
f0101c80:	85 c0                	test   %eax,%eax
f0101c82:	0f 84 33 09 00 00    	je     f01025bb <mem_init+0x129b>
f0101c88:	39 c3                	cmp    %eax,%ebx
f0101c8a:	0f 85 2b 09 00 00    	jne    f01025bb <mem_init+0x129b>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101c90:	83 ec 08             	sub    $0x8,%esp
f0101c93:	6a 00                	push   $0x0
f0101c95:	ff 35 8c 1e 23 f0    	pushl  0xf0231e8c
f0101c9b:	e8 71 f5 ff ff       	call   f0101211 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101ca0:	8b 35 8c 1e 23 f0    	mov    0xf0231e8c,%esi
f0101ca6:	ba 00 00 00 00       	mov    $0x0,%edx
f0101cab:	89 f0                	mov    %esi,%eax
f0101cad:	e8 75 ee ff ff       	call   f0100b27 <check_va2pa>
f0101cb2:	83 c4 10             	add    $0x10,%esp
f0101cb5:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101cb8:	0f 85 16 09 00 00    	jne    f01025d4 <mem_init+0x12b4>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101cbe:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101cc3:	89 f0                	mov    %esi,%eax
f0101cc5:	e8 5d ee ff ff       	call   f0100b27 <check_va2pa>
f0101cca:	89 fa                	mov    %edi,%edx
f0101ccc:	2b 15 90 1e 23 f0    	sub    0xf0231e90,%edx
f0101cd2:	c1 fa 03             	sar    $0x3,%edx
f0101cd5:	c1 e2 0c             	shl    $0xc,%edx
f0101cd8:	39 d0                	cmp    %edx,%eax
f0101cda:	0f 85 0d 09 00 00    	jne    f01025ed <mem_init+0x12cd>
	assert(pp1->pp_ref == 1);
f0101ce0:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101ce5:	0f 85 1b 09 00 00    	jne    f0102606 <mem_init+0x12e6>
	assert(pp2->pp_ref == 0);
f0101ceb:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101cf0:	0f 85 29 09 00 00    	jne    f010261f <mem_init+0x12ff>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101cf6:	6a 00                	push   $0x0
f0101cf8:	68 00 10 00 00       	push   $0x1000
f0101cfd:	57                   	push   %edi
f0101cfe:	56                   	push   %esi
f0101cff:	e8 53 f5 ff ff       	call   f0101257 <page_insert>
f0101d04:	83 c4 10             	add    $0x10,%esp
f0101d07:	85 c0                	test   %eax,%eax
f0101d09:	0f 85 29 09 00 00    	jne    f0102638 <mem_init+0x1318>
	assert(pp1->pp_ref);
f0101d0f:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101d14:	0f 84 37 09 00 00    	je     f0102651 <mem_init+0x1331>
	assert(pp1->pp_link == NULL);
f0101d1a:	83 3f 00             	cmpl   $0x0,(%edi)
f0101d1d:	0f 85 47 09 00 00    	jne    f010266a <mem_init+0x134a>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101d23:	83 ec 08             	sub    $0x8,%esp
f0101d26:	68 00 10 00 00       	push   $0x1000
f0101d2b:	ff 35 8c 1e 23 f0    	pushl  0xf0231e8c
f0101d31:	e8 db f4 ff ff       	call   f0101211 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101d36:	8b 35 8c 1e 23 f0    	mov    0xf0231e8c,%esi
f0101d3c:	ba 00 00 00 00       	mov    $0x0,%edx
f0101d41:	89 f0                	mov    %esi,%eax
f0101d43:	e8 df ed ff ff       	call   f0100b27 <check_va2pa>
f0101d48:	83 c4 10             	add    $0x10,%esp
f0101d4b:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101d4e:	0f 85 2f 09 00 00    	jne    f0102683 <mem_init+0x1363>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101d54:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d59:	89 f0                	mov    %esi,%eax
f0101d5b:	e8 c7 ed ff ff       	call   f0100b27 <check_va2pa>
f0101d60:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101d63:	0f 85 33 09 00 00    	jne    f010269c <mem_init+0x137c>
	assert(pp1->pp_ref == 0);
f0101d69:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101d6e:	0f 85 41 09 00 00    	jne    f01026b5 <mem_init+0x1395>
	assert(pp2->pp_ref == 0);
f0101d74:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101d79:	0f 85 4f 09 00 00    	jne    f01026ce <mem_init+0x13ae>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101d7f:	83 ec 0c             	sub    $0xc,%esp
f0101d82:	6a 00                	push   $0x0
f0101d84:	e8 0d f2 ff ff       	call   f0100f96 <page_alloc>
f0101d89:	83 c4 10             	add    $0x10,%esp
f0101d8c:	39 c7                	cmp    %eax,%edi
f0101d8e:	0f 85 53 09 00 00    	jne    f01026e7 <mem_init+0x13c7>
f0101d94:	85 c0                	test   %eax,%eax
f0101d96:	0f 84 4b 09 00 00    	je     f01026e7 <mem_init+0x13c7>

	// should be no free memory
	assert(!page_alloc(0));
f0101d9c:	83 ec 0c             	sub    $0xc,%esp
f0101d9f:	6a 00                	push   $0x0
f0101da1:	e8 f0 f1 ff ff       	call   f0100f96 <page_alloc>
f0101da6:	83 c4 10             	add    $0x10,%esp
f0101da9:	85 c0                	test   %eax,%eax
f0101dab:	0f 85 4f 09 00 00    	jne    f0102700 <mem_init+0x13e0>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101db1:	8b 0d 8c 1e 23 f0    	mov    0xf0231e8c,%ecx
f0101db7:	8b 11                	mov    (%ecx),%edx
f0101db9:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101dbf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101dc2:	2b 05 90 1e 23 f0    	sub    0xf0231e90,%eax
f0101dc8:	c1 f8 03             	sar    $0x3,%eax
f0101dcb:	c1 e0 0c             	shl    $0xc,%eax
f0101dce:	39 c2                	cmp    %eax,%edx
f0101dd0:	0f 85 43 09 00 00    	jne    f0102719 <mem_init+0x13f9>
	kern_pgdir[0] = 0;
f0101dd6:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0101ddc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ddf:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101de4:	0f 85 48 09 00 00    	jne    f0102732 <mem_init+0x1412>
	pp0->pp_ref = 0;
f0101dea:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ded:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0101df3:	83 ec 0c             	sub    $0xc,%esp
f0101df6:	50                   	push   %eax
f0101df7:	e8 0c f2 ff ff       	call   f0101008 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0101dfc:	83 c4 0c             	add    $0xc,%esp
f0101dff:	6a 01                	push   $0x1
f0101e01:	68 00 10 40 00       	push   $0x401000
f0101e06:	ff 35 8c 1e 23 f0    	pushl  0xf0231e8c
f0101e0c:	e8 5b f2 ff ff       	call   f010106c <pgdir_walk>
f0101e11:	89 c1                	mov    %eax,%ecx
f0101e13:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0101e16:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f0101e1b:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101e1e:	8b 40 04             	mov    0x4(%eax),%eax
f0101e21:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0101e26:	8b 35 88 1e 23 f0    	mov    0xf0231e88,%esi
f0101e2c:	89 c2                	mov    %eax,%edx
f0101e2e:	c1 ea 0c             	shr    $0xc,%edx
f0101e31:	83 c4 10             	add    $0x10,%esp
f0101e34:	39 f2                	cmp    %esi,%edx
f0101e36:	0f 83 0f 09 00 00    	jae    f010274b <mem_init+0x142b>
	assert(ptep == ptep1 + PTX(va));
f0101e3c:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f0101e41:	39 c1                	cmp    %eax,%ecx
f0101e43:	0f 85 17 09 00 00    	jne    f0102760 <mem_init+0x1440>
	kern_pgdir[PDX(va)] = 0;
f0101e49:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101e4c:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f0101e53:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e56:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f0101e5c:	2b 05 90 1e 23 f0    	sub    0xf0231e90,%eax
f0101e62:	c1 f8 03             	sar    $0x3,%eax
f0101e65:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0101e68:	89 c2                	mov    %eax,%edx
f0101e6a:	c1 ea 0c             	shr    $0xc,%edx
f0101e6d:	39 d6                	cmp    %edx,%esi
f0101e6f:	0f 86 04 09 00 00    	jbe    f0102779 <mem_init+0x1459>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0101e75:	83 ec 04             	sub    $0x4,%esp
f0101e78:	68 00 10 00 00       	push   $0x1000
f0101e7d:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f0101e82:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101e87:	50                   	push   %eax
f0101e88:	e8 17 2c 00 00       	call   f0104aa4 <memset>
	page_free(pp0);
f0101e8d:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0101e90:	89 34 24             	mov    %esi,(%esp)
f0101e93:	e8 70 f1 ff ff       	call   f0101008 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0101e98:	83 c4 0c             	add    $0xc,%esp
f0101e9b:	6a 01                	push   $0x1
f0101e9d:	6a 00                	push   $0x0
f0101e9f:	ff 35 8c 1e 23 f0    	pushl  0xf0231e8c
f0101ea5:	e8 c2 f1 ff ff       	call   f010106c <pgdir_walk>
	return (pp - pages) << PGSHIFT;
f0101eaa:	89 f0                	mov    %esi,%eax
f0101eac:	2b 05 90 1e 23 f0    	sub    0xf0231e90,%eax
f0101eb2:	c1 f8 03             	sar    $0x3,%eax
f0101eb5:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0101eb8:	89 c2                	mov    %eax,%edx
f0101eba:	c1 ea 0c             	shr    $0xc,%edx
f0101ebd:	83 c4 10             	add    $0x10,%esp
f0101ec0:	3b 15 88 1e 23 f0    	cmp    0xf0231e88,%edx
f0101ec6:	0f 83 bf 08 00 00    	jae    f010278b <mem_init+0x146b>
	return (void *)(pa + KERNBASE);
f0101ecc:	8d 90 00 00 00 f0    	lea    -0x10000000(%eax),%edx
	ptep = (pte_t *) page2kva(pp0);
f0101ed2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0101ed5:	2d 00 f0 ff 0f       	sub    $0xffff000,%eax
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0101eda:	f6 02 01             	testb  $0x1,(%edx)
f0101edd:	0f 85 ba 08 00 00    	jne    f010279d <mem_init+0x147d>
f0101ee3:	83 c2 04             	add    $0x4,%edx
	for(i=0; i<NPTENTRIES; i++)
f0101ee6:	39 c2                	cmp    %eax,%edx
f0101ee8:	75 f0                	jne    f0101eda <mem_init+0xbba>
	kern_pgdir[0] = 0;
f0101eea:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f0101eef:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0101ef5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ef8:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0101efe:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0101f01:	89 0d 3c 12 23 f0    	mov    %ecx,0xf023123c

	// free the pages we took
	page_free(pp0);
f0101f07:	83 ec 0c             	sub    $0xc,%esp
f0101f0a:	50                   	push   %eax
f0101f0b:	e8 f8 f0 ff ff       	call   f0101008 <page_free>
	page_free(pp1);
f0101f10:	89 3c 24             	mov    %edi,(%esp)
f0101f13:	e8 f0 f0 ff ff       	call   f0101008 <page_free>
	page_free(pp2);
f0101f18:	89 1c 24             	mov    %ebx,(%esp)
f0101f1b:	e8 e8 f0 ff ff       	call   f0101008 <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f0101f20:	83 c4 08             	add    $0x8,%esp
f0101f23:	68 01 10 00 00       	push   $0x1001
f0101f28:	6a 00                	push   $0x0
f0101f2a:	e8 8e f3 ff ff       	call   f01012bd <mmio_map_region>
f0101f2f:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f0101f31:	83 c4 08             	add    $0x8,%esp
f0101f34:	68 00 10 00 00       	push   $0x1000
f0101f39:	6a 00                	push   $0x0
f0101f3b:	e8 7d f3 ff ff       	call   f01012bd <mmio_map_region>
f0101f40:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8192 < MMIOLIM);
f0101f42:	8d 83 00 20 00 00    	lea    0x2000(%ebx),%eax
f0101f48:	83 c4 10             	add    $0x10,%esp
f0101f4b:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0101f51:	0f 86 5f 08 00 00    	jbe    f01027b6 <mem_init+0x1496>
f0101f57:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0101f5c:	0f 87 54 08 00 00    	ja     f01027b6 <mem_init+0x1496>
	assert(mm2 >= MMIOBASE && mm2 + 8192 < MMIOLIM);
f0101f62:	8d 96 00 20 00 00    	lea    0x2000(%esi),%edx
f0101f68:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f0101f6e:	0f 87 5b 08 00 00    	ja     f01027cf <mem_init+0x14af>
f0101f74:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0101f7a:	0f 86 4f 08 00 00    	jbe    f01027cf <mem_init+0x14af>
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0101f80:	89 da                	mov    %ebx,%edx
f0101f82:	09 f2                	or     %esi,%edx
f0101f84:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0101f8a:	0f 85 58 08 00 00    	jne    f01027e8 <mem_init+0x14c8>
	// check that they don't overlap
	assert(mm1 + 8192 <= mm2);
f0101f90:	39 c6                	cmp    %eax,%esi
f0101f92:	0f 82 69 08 00 00    	jb     f0102801 <mem_init+0x14e1>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0101f98:	8b 3d 8c 1e 23 f0    	mov    0xf0231e8c,%edi
f0101f9e:	89 da                	mov    %ebx,%edx
f0101fa0:	89 f8                	mov    %edi,%eax
f0101fa2:	e8 80 eb ff ff       	call   f0100b27 <check_va2pa>
f0101fa7:	85 c0                	test   %eax,%eax
f0101fa9:	0f 85 6b 08 00 00    	jne    f010281a <mem_init+0x14fa>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0101faf:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f0101fb5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101fb8:	89 c2                	mov    %eax,%edx
f0101fba:	89 f8                	mov    %edi,%eax
f0101fbc:	e8 66 eb ff ff       	call   f0100b27 <check_va2pa>
f0101fc1:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0101fc6:	0f 85 67 08 00 00    	jne    f0102833 <mem_init+0x1513>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0101fcc:	89 f2                	mov    %esi,%edx
f0101fce:	89 f8                	mov    %edi,%eax
f0101fd0:	e8 52 eb ff ff       	call   f0100b27 <check_va2pa>
f0101fd5:	85 c0                	test   %eax,%eax
f0101fd7:	0f 85 6f 08 00 00    	jne    f010284c <mem_init+0x152c>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0101fdd:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f0101fe3:	89 f8                	mov    %edi,%eax
f0101fe5:	e8 3d eb ff ff       	call   f0100b27 <check_va2pa>
f0101fea:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101fed:	0f 85 72 08 00 00    	jne    f0102865 <mem_init+0x1545>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f0101ff3:	83 ec 04             	sub    $0x4,%esp
f0101ff6:	6a 00                	push   $0x0
f0101ff8:	53                   	push   %ebx
f0101ff9:	57                   	push   %edi
f0101ffa:	e8 6d f0 ff ff       	call   f010106c <pgdir_walk>
f0101fff:	83 c4 10             	add    $0x10,%esp
f0102002:	f6 00 1a             	testb  $0x1a,(%eax)
f0102005:	0f 84 73 08 00 00    	je     f010287e <mem_init+0x155e>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f010200b:	83 ec 04             	sub    $0x4,%esp
f010200e:	6a 00                	push   $0x0
f0102010:	53                   	push   %ebx
f0102011:	ff 35 8c 1e 23 f0    	pushl  0xf0231e8c
f0102017:	e8 50 f0 ff ff       	call   f010106c <pgdir_walk>
f010201c:	83 c4 10             	add    $0x10,%esp
f010201f:	f6 00 04             	testb  $0x4,(%eax)
f0102022:	0f 85 6f 08 00 00    	jne    f0102897 <mem_init+0x1577>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f0102028:	83 ec 04             	sub    $0x4,%esp
f010202b:	6a 00                	push   $0x0
f010202d:	53                   	push   %ebx
f010202e:	ff 35 8c 1e 23 f0    	pushl  0xf0231e8c
f0102034:	e8 33 f0 ff ff       	call   f010106c <pgdir_walk>
f0102039:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f010203f:	83 c4 0c             	add    $0xc,%esp
f0102042:	6a 00                	push   $0x0
f0102044:	ff 75 d4             	pushl  -0x2c(%ebp)
f0102047:	ff 35 8c 1e 23 f0    	pushl  0xf0231e8c
f010204d:	e8 1a f0 ff ff       	call   f010106c <pgdir_walk>
f0102052:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f0102058:	83 c4 0c             	add    $0xc,%esp
f010205b:	6a 00                	push   $0x0
f010205d:	56                   	push   %esi
f010205e:	ff 35 8c 1e 23 f0    	pushl  0xf0231e8c
f0102064:	e8 03 f0 ff ff       	call   f010106c <pgdir_walk>
f0102069:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f010206f:	c7 04 24 f4 68 10 f0 	movl   $0xf01068f4,(%esp)
f0102076:	e8 77 17 00 00       	call   f01037f2 <cprintf>
	boot_map_region(kern_pgdir, (uintptr_t) UPAGES, npages*sizeof(struct PageInfo), PADDR(pages), PTE_U | PTE_P);
f010207b:	a1 90 1e 23 f0       	mov    0xf0231e90,%eax
	if ((uint32_t)kva < KERNBASE)
f0102080:	83 c4 10             	add    $0x10,%esp
f0102083:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102088:	0f 86 22 08 00 00    	jbe    f01028b0 <mem_init+0x1590>
f010208e:	8b 0d 88 1e 23 f0    	mov    0xf0231e88,%ecx
f0102094:	c1 e1 03             	shl    $0x3,%ecx
f0102097:	83 ec 08             	sub    $0x8,%esp
f010209a:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f010209c:	05 00 00 00 10       	add    $0x10000000,%eax
f01020a1:	50                   	push   %eax
f01020a2:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f01020a7:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f01020ac:	e8 7b f0 ff ff       	call   f010112c <boot_map_region>
	boot_map_region(kern_pgdir, (uintptr_t) UENVS, ROUNDUP(NENV * sizeof(struct Env), PGSIZE), PADDR(envs), PTE_U | PTE_P);
f01020b1:	a1 44 12 23 f0       	mov    0xf0231244,%eax
	if ((uint32_t)kva < KERNBASE)
f01020b6:	83 c4 10             	add    $0x10,%esp
f01020b9:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01020be:	0f 86 01 08 00 00    	jbe    f01028c5 <mem_init+0x15a5>
f01020c4:	83 ec 08             	sub    $0x8,%esp
f01020c7:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f01020c9:	05 00 00 00 10       	add    $0x10000000,%eax
f01020ce:	50                   	push   %eax
f01020cf:	b9 00 f0 01 00       	mov    $0x1f000,%ecx
f01020d4:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f01020d9:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f01020de:	e8 49 f0 ff ff       	call   f010112c <boot_map_region>
	if ((uint32_t)kva < KERNBASE)
f01020e3:	83 c4 10             	add    $0x10,%esp
f01020e6:	b8 00 70 11 f0       	mov    $0xf0117000,%eax
f01020eb:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01020f0:	0f 86 e4 07 00 00    	jbe    f01028da <mem_init+0x15ba>
	boot_map_region(kern_pgdir, (uintptr_t) (KSTACKTOP-KSTKSIZE), KSTKSIZE, PADDR(bootstack), PTE_W | PTE_P);
f01020f6:	83 ec 08             	sub    $0x8,%esp
f01020f9:	6a 03                	push   $0x3
f01020fb:	68 00 70 11 00       	push   $0x117000
f0102100:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102105:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f010210a:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f010210f:	e8 18 f0 ff ff       	call   f010112c <boot_map_region>
	boot_map_region(kern_pgdir, (uintptr_t) KERNBASE, ROUNDUP(0xffffffff - KERNBASE, PGSIZE), 0, PTE_W | PTE_P);
f0102114:	83 c4 08             	add    $0x8,%esp
f0102117:	6a 03                	push   $0x3
f0102119:	6a 00                	push   $0x0
f010211b:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0102120:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102125:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f010212a:	e8 fd ef ff ff       	call   f010112c <boot_map_region>
f010212f:	c7 45 d0 00 30 23 f0 	movl   $0xf0233000,-0x30(%ebp)
f0102136:	83 c4 10             	add    $0x10,%esp
f0102139:	bb 00 30 23 f0       	mov    $0xf0233000,%ebx
    uintptr_t start_addr = KSTACKTOP - KSTKSIZE;    
f010213e:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f0102143:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102149:	0f 86 a0 07 00 00    	jbe    f01028ef <mem_init+0x15cf>
        boot_map_region(kern_pgdir, (uintptr_t) start_addr, KSTKSIZE, PADDR(percpu_kstacks[i]), PTE_W | PTE_P);
f010214f:	83 ec 08             	sub    $0x8,%esp
f0102152:	6a 03                	push   $0x3
f0102154:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f010215a:	50                   	push   %eax
f010215b:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102160:	89 f2                	mov    %esi,%edx
f0102162:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f0102167:	e8 c0 ef ff ff       	call   f010112c <boot_map_region>
        start_addr -= KSTKSIZE + KSTKGAP;
f010216c:	81 ee 00 00 01 00    	sub    $0x10000,%esi
f0102172:	81 c3 00 80 00 00    	add    $0x8000,%ebx
    for (size_t i = 0; i < NCPU; i++) {
f0102178:	83 c4 10             	add    $0x10,%esp
f010217b:	81 fe 00 80 f7 ef    	cmp    $0xeff78000,%esi
f0102181:	75 c0                	jne    f0102143 <mem_init+0xe23>
	pgdir = kern_pgdir;
f0102183:	8b 3d 8c 1e 23 f0    	mov    0xf0231e8c,%edi
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102189:	a1 88 1e 23 f0       	mov    0xf0231e88,%eax
f010218e:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0102191:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0102198:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010219d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01021a0:	8b 35 90 1e 23 f0    	mov    0xf0231e90,%esi
f01021a6:	89 75 cc             	mov    %esi,-0x34(%ebp)
	return (physaddr_t)kva - KERNBASE;
f01021a9:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f01021af:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (i = 0; i < n; i += PGSIZE)
f01021b2:	bb 00 00 00 00       	mov    $0x0,%ebx
f01021b7:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f01021ba:	0f 86 72 07 00 00    	jbe    f0102932 <mem_init+0x1612>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01021c0:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f01021c6:	89 f8                	mov    %edi,%eax
f01021c8:	e8 5a e9 ff ff       	call   f0100b27 <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f01021cd:	81 7d cc ff ff ff ef 	cmpl   $0xefffffff,-0x34(%ebp)
f01021d4:	0f 86 2a 07 00 00    	jbe    f0102904 <mem_init+0x15e4>
f01021da:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f01021dd:	8d 14 0b             	lea    (%ebx,%ecx,1),%edx
f01021e0:	39 d0                	cmp    %edx,%eax
f01021e2:	0f 85 31 07 00 00    	jne    f0102919 <mem_init+0x15f9>
	for (i = 0; i < n; i += PGSIZE)
f01021e8:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01021ee:	eb c7                	jmp    f01021b7 <mem_init+0xe97>
	assert(nfree == 0);
f01021f0:	68 0b 68 10 f0       	push   $0xf010680b
f01021f5:	68 32 66 10 f0       	push   $0xf0106632
f01021fa:	68 4a 03 00 00       	push   $0x34a
f01021ff:	68 05 66 10 f0       	push   $0xf0106605
f0102204:	e8 8b de ff ff       	call   f0100094 <_panic>
	assert((pp0 = page_alloc(0)));
f0102209:	68 19 67 10 f0       	push   $0xf0106719
f010220e:	68 32 66 10 f0       	push   $0xf0106632
f0102213:	68 b6 03 00 00       	push   $0x3b6
f0102218:	68 05 66 10 f0       	push   $0xf0106605
f010221d:	e8 72 de ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f0102222:	68 2f 67 10 f0       	push   $0xf010672f
f0102227:	68 32 66 10 f0       	push   $0xf0106632
f010222c:	68 b7 03 00 00       	push   $0x3b7
f0102231:	68 05 66 10 f0       	push   $0xf0106605
f0102236:	e8 59 de ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f010223b:	68 45 67 10 f0       	push   $0xf0106745
f0102240:	68 32 66 10 f0       	push   $0xf0106632
f0102245:	68 b8 03 00 00       	push   $0x3b8
f010224a:	68 05 66 10 f0       	push   $0xf0106605
f010224f:	e8 40 de ff ff       	call   f0100094 <_panic>
	assert(pp1 && pp1 != pp0);
f0102254:	68 5b 67 10 f0       	push   $0xf010675b
f0102259:	68 32 66 10 f0       	push   $0xf0106632
f010225e:	68 bb 03 00 00       	push   $0x3bb
f0102263:	68 05 66 10 f0       	push   $0xf0106605
f0102268:	e8 27 de ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010226d:	68 60 5e 10 f0       	push   $0xf0105e60
f0102272:	68 32 66 10 f0       	push   $0xf0106632
f0102277:	68 bc 03 00 00       	push   $0x3bc
f010227c:	68 05 66 10 f0       	push   $0xf0106605
f0102281:	e8 0e de ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f0102286:	68 c4 67 10 f0       	push   $0xf01067c4
f010228b:	68 32 66 10 f0       	push   $0xf0106632
f0102290:	68 c3 03 00 00       	push   $0x3c3
f0102295:	68 05 66 10 f0       	push   $0xf0106605
f010229a:	e8 f5 dd ff ff       	call   f0100094 <_panic>
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f010229f:	68 a0 5e 10 f0       	push   $0xf0105ea0
f01022a4:	68 32 66 10 f0       	push   $0xf0106632
f01022a9:	68 c6 03 00 00       	push   $0x3c6
f01022ae:	68 05 66 10 f0       	push   $0xf0106605
f01022b3:	e8 dc dd ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01022b8:	68 d8 5e 10 f0       	push   $0xf0105ed8
f01022bd:	68 32 66 10 f0       	push   $0xf0106632
f01022c2:	68 c9 03 00 00       	push   $0x3c9
f01022c7:	68 05 66 10 f0       	push   $0xf0106605
f01022cc:	e8 c3 dd ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f01022d1:	68 08 5f 10 f0       	push   $0xf0105f08
f01022d6:	68 32 66 10 f0       	push   $0xf0106632
f01022db:	68 cd 03 00 00       	push   $0x3cd
f01022e0:	68 05 66 10 f0       	push   $0xf0106605
f01022e5:	e8 aa dd ff ff       	call   f0100094 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01022ea:	68 38 5f 10 f0       	push   $0xf0105f38
f01022ef:	68 32 66 10 f0       	push   $0xf0106632
f01022f4:	68 ce 03 00 00       	push   $0x3ce
f01022f9:	68 05 66 10 f0       	push   $0xf0106605
f01022fe:	e8 91 dd ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0102303:	68 60 5f 10 f0       	push   $0xf0105f60
f0102308:	68 32 66 10 f0       	push   $0xf0106632
f010230d:	68 cf 03 00 00       	push   $0x3cf
f0102312:	68 05 66 10 f0       	push   $0xf0106605
f0102317:	e8 78 dd ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 1);
f010231c:	68 16 68 10 f0       	push   $0xf0106816
f0102321:	68 32 66 10 f0       	push   $0xf0106632
f0102326:	68 d0 03 00 00       	push   $0x3d0
f010232b:	68 05 66 10 f0       	push   $0xf0106605
f0102330:	e8 5f dd ff ff       	call   f0100094 <_panic>
	assert(pp0->pp_ref == 1);
f0102335:	68 27 68 10 f0       	push   $0xf0106827
f010233a:	68 32 66 10 f0       	push   $0xf0106632
f010233f:	68 d1 03 00 00       	push   $0x3d1
f0102344:	68 05 66 10 f0       	push   $0xf0106605
f0102349:	e8 46 dd ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010234e:	68 90 5f 10 f0       	push   $0xf0105f90
f0102353:	68 32 66 10 f0       	push   $0xf0106632
f0102358:	68 d4 03 00 00       	push   $0x3d4
f010235d:	68 05 66 10 f0       	push   $0xf0106605
f0102362:	e8 2d dd ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102367:	68 cc 5f 10 f0       	push   $0xf0105fcc
f010236c:	68 32 66 10 f0       	push   $0xf0106632
f0102371:	68 d5 03 00 00       	push   $0x3d5
f0102376:	68 05 66 10 f0       	push   $0xf0106605
f010237b:	e8 14 dd ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f0102380:	68 38 68 10 f0       	push   $0xf0106838
f0102385:	68 32 66 10 f0       	push   $0xf0106632
f010238a:	68 d6 03 00 00       	push   $0x3d6
f010238f:	68 05 66 10 f0       	push   $0xf0106605
f0102394:	e8 fb dc ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f0102399:	68 c4 67 10 f0       	push   $0xf01067c4
f010239e:	68 32 66 10 f0       	push   $0xf0106632
f01023a3:	68 d9 03 00 00       	push   $0x3d9
f01023a8:	68 05 66 10 f0       	push   $0xf0106605
f01023ad:	e8 e2 dc ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01023b2:	68 90 5f 10 f0       	push   $0xf0105f90
f01023b7:	68 32 66 10 f0       	push   $0xf0106632
f01023bc:	68 dc 03 00 00       	push   $0x3dc
f01023c1:	68 05 66 10 f0       	push   $0xf0106605
f01023c6:	e8 c9 dc ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01023cb:	68 cc 5f 10 f0       	push   $0xf0105fcc
f01023d0:	68 32 66 10 f0       	push   $0xf0106632
f01023d5:	68 dd 03 00 00       	push   $0x3dd
f01023da:	68 05 66 10 f0       	push   $0xf0106605
f01023df:	e8 b0 dc ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f01023e4:	68 38 68 10 f0       	push   $0xf0106838
f01023e9:	68 32 66 10 f0       	push   $0xf0106632
f01023ee:	68 de 03 00 00       	push   $0x3de
f01023f3:	68 05 66 10 f0       	push   $0xf0106605
f01023f8:	e8 97 dc ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f01023fd:	68 c4 67 10 f0       	push   $0xf01067c4
f0102402:	68 32 66 10 f0       	push   $0xf0106632
f0102407:	68 e2 03 00 00       	push   $0x3e2
f010240c:	68 05 66 10 f0       	push   $0xf0106605
f0102411:	e8 7e dc ff ff       	call   f0100094 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102416:	50                   	push   %eax
f0102417:	68 b4 57 10 f0       	push   $0xf01057b4
f010241c:	68 e5 03 00 00       	push   $0x3e5
f0102421:	68 05 66 10 f0       	push   $0xf0106605
f0102426:	e8 69 dc ff ff       	call   f0100094 <_panic>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f010242b:	68 fc 5f 10 f0       	push   $0xf0105ffc
f0102430:	68 32 66 10 f0       	push   $0xf0106632
f0102435:	68 e6 03 00 00       	push   $0x3e6
f010243a:	68 05 66 10 f0       	push   $0xf0106605
f010243f:	e8 50 dc ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0102444:	68 3c 60 10 f0       	push   $0xf010603c
f0102449:	68 32 66 10 f0       	push   $0xf0106632
f010244e:	68 e9 03 00 00       	push   $0x3e9
f0102453:	68 05 66 10 f0       	push   $0xf0106605
f0102458:	e8 37 dc ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010245d:	68 cc 5f 10 f0       	push   $0xf0105fcc
f0102462:	68 32 66 10 f0       	push   $0xf0106632
f0102467:	68 ea 03 00 00       	push   $0x3ea
f010246c:	68 05 66 10 f0       	push   $0xf0106605
f0102471:	e8 1e dc ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f0102476:	68 38 68 10 f0       	push   $0xf0106838
f010247b:	68 32 66 10 f0       	push   $0xf0106632
f0102480:	68 eb 03 00 00       	push   $0x3eb
f0102485:	68 05 66 10 f0       	push   $0xf0106605
f010248a:	e8 05 dc ff ff       	call   f0100094 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f010248f:	68 7c 60 10 f0       	push   $0xf010607c
f0102494:	68 32 66 10 f0       	push   $0xf0106632
f0102499:	68 ec 03 00 00       	push   $0x3ec
f010249e:	68 05 66 10 f0       	push   $0xf0106605
f01024a3:	e8 ec db ff ff       	call   f0100094 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f01024a8:	68 49 68 10 f0       	push   $0xf0106849
f01024ad:	68 32 66 10 f0       	push   $0xf0106632
f01024b2:	68 ed 03 00 00       	push   $0x3ed
f01024b7:	68 05 66 10 f0       	push   $0xf0106605
f01024bc:	e8 d3 db ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01024c1:	68 90 5f 10 f0       	push   $0xf0105f90
f01024c6:	68 32 66 10 f0       	push   $0xf0106632
f01024cb:	68 f0 03 00 00       	push   $0x3f0
f01024d0:	68 05 66 10 f0       	push   $0xf0106605
f01024d5:	e8 ba db ff ff       	call   f0100094 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f01024da:	68 b0 60 10 f0       	push   $0xf01060b0
f01024df:	68 32 66 10 f0       	push   $0xf0106632
f01024e4:	68 f1 03 00 00       	push   $0x3f1
f01024e9:	68 05 66 10 f0       	push   $0xf0106605
f01024ee:	e8 a1 db ff ff       	call   f0100094 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01024f3:	68 e4 60 10 f0       	push   $0xf01060e4
f01024f8:	68 32 66 10 f0       	push   $0xf0106632
f01024fd:	68 f2 03 00 00       	push   $0x3f2
f0102502:	68 05 66 10 f0       	push   $0xf0106605
f0102507:	e8 88 db ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f010250c:	68 1c 61 10 f0       	push   $0xf010611c
f0102511:	68 32 66 10 f0       	push   $0xf0106632
f0102516:	68 f5 03 00 00       	push   $0x3f5
f010251b:	68 05 66 10 f0       	push   $0xf0106605
f0102520:	e8 6f db ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0102525:	68 54 61 10 f0       	push   $0xf0106154
f010252a:	68 32 66 10 f0       	push   $0xf0106632
f010252f:	68 f8 03 00 00       	push   $0x3f8
f0102534:	68 05 66 10 f0       	push   $0xf0106605
f0102539:	e8 56 db ff ff       	call   f0100094 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f010253e:	68 e4 60 10 f0       	push   $0xf01060e4
f0102543:	68 32 66 10 f0       	push   $0xf0106632
f0102548:	68 f9 03 00 00       	push   $0x3f9
f010254d:	68 05 66 10 f0       	push   $0xf0106605
f0102552:	e8 3d db ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102557:	68 90 61 10 f0       	push   $0xf0106190
f010255c:	68 32 66 10 f0       	push   $0xf0106632
f0102561:	68 fc 03 00 00       	push   $0x3fc
f0102566:	68 05 66 10 f0       	push   $0xf0106605
f010256b:	e8 24 db ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102570:	68 bc 61 10 f0       	push   $0xf01061bc
f0102575:	68 32 66 10 f0       	push   $0xf0106632
f010257a:	68 fd 03 00 00       	push   $0x3fd
f010257f:	68 05 66 10 f0       	push   $0xf0106605
f0102584:	e8 0b db ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 2);
f0102589:	68 5f 68 10 f0       	push   $0xf010685f
f010258e:	68 32 66 10 f0       	push   $0xf0106632
f0102593:	68 ff 03 00 00       	push   $0x3ff
f0102598:	68 05 66 10 f0       	push   $0xf0106605
f010259d:	e8 f2 da ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f01025a2:	68 70 68 10 f0       	push   $0xf0106870
f01025a7:	68 32 66 10 f0       	push   $0xf0106632
f01025ac:	68 00 04 00 00       	push   $0x400
f01025b1:	68 05 66 10 f0       	push   $0xf0106605
f01025b6:	e8 d9 da ff ff       	call   f0100094 <_panic>
	assert((pp = page_alloc(0)) && pp == pp2);
f01025bb:	68 ec 61 10 f0       	push   $0xf01061ec
f01025c0:	68 32 66 10 f0       	push   $0xf0106632
f01025c5:	68 03 04 00 00       	push   $0x403
f01025ca:	68 05 66 10 f0       	push   $0xf0106605
f01025cf:	e8 c0 da ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01025d4:	68 10 62 10 f0       	push   $0xf0106210
f01025d9:	68 32 66 10 f0       	push   $0xf0106632
f01025de:	68 07 04 00 00       	push   $0x407
f01025e3:	68 05 66 10 f0       	push   $0xf0106605
f01025e8:	e8 a7 da ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01025ed:	68 bc 61 10 f0       	push   $0xf01061bc
f01025f2:	68 32 66 10 f0       	push   $0xf0106632
f01025f7:	68 08 04 00 00       	push   $0x408
f01025fc:	68 05 66 10 f0       	push   $0xf0106605
f0102601:	e8 8e da ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 1);
f0102606:	68 16 68 10 f0       	push   $0xf0106816
f010260b:	68 32 66 10 f0       	push   $0xf0106632
f0102610:	68 09 04 00 00       	push   $0x409
f0102615:	68 05 66 10 f0       	push   $0xf0106605
f010261a:	e8 75 da ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f010261f:	68 70 68 10 f0       	push   $0xf0106870
f0102624:	68 32 66 10 f0       	push   $0xf0106632
f0102629:	68 0a 04 00 00       	push   $0x40a
f010262e:	68 05 66 10 f0       	push   $0xf0106605
f0102633:	e8 5c da ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0102638:	68 34 62 10 f0       	push   $0xf0106234
f010263d:	68 32 66 10 f0       	push   $0xf0106632
f0102642:	68 0d 04 00 00       	push   $0x40d
f0102647:	68 05 66 10 f0       	push   $0xf0106605
f010264c:	e8 43 da ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref);
f0102651:	68 81 68 10 f0       	push   $0xf0106881
f0102656:	68 32 66 10 f0       	push   $0xf0106632
f010265b:	68 0e 04 00 00       	push   $0x40e
f0102660:	68 05 66 10 f0       	push   $0xf0106605
f0102665:	e8 2a da ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_link == NULL);
f010266a:	68 8d 68 10 f0       	push   $0xf010688d
f010266f:	68 32 66 10 f0       	push   $0xf0106632
f0102674:	68 0f 04 00 00       	push   $0x40f
f0102679:	68 05 66 10 f0       	push   $0xf0106605
f010267e:	e8 11 da ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102683:	68 10 62 10 f0       	push   $0xf0106210
f0102688:	68 32 66 10 f0       	push   $0xf0106632
f010268d:	68 13 04 00 00       	push   $0x413
f0102692:	68 05 66 10 f0       	push   $0xf0106605
f0102697:	e8 f8 d9 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f010269c:	68 6c 62 10 f0       	push   $0xf010626c
f01026a1:	68 32 66 10 f0       	push   $0xf0106632
f01026a6:	68 14 04 00 00       	push   $0x414
f01026ab:	68 05 66 10 f0       	push   $0xf0106605
f01026b0:	e8 df d9 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 0);
f01026b5:	68 a2 68 10 f0       	push   $0xf01068a2
f01026ba:	68 32 66 10 f0       	push   $0xf0106632
f01026bf:	68 15 04 00 00       	push   $0x415
f01026c4:	68 05 66 10 f0       	push   $0xf0106605
f01026c9:	e8 c6 d9 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f01026ce:	68 70 68 10 f0       	push   $0xf0106870
f01026d3:	68 32 66 10 f0       	push   $0xf0106632
f01026d8:	68 16 04 00 00       	push   $0x416
f01026dd:	68 05 66 10 f0       	push   $0xf0106605
f01026e2:	e8 ad d9 ff ff       	call   f0100094 <_panic>
	assert((pp = page_alloc(0)) && pp == pp1);
f01026e7:	68 94 62 10 f0       	push   $0xf0106294
f01026ec:	68 32 66 10 f0       	push   $0xf0106632
f01026f1:	68 19 04 00 00       	push   $0x419
f01026f6:	68 05 66 10 f0       	push   $0xf0106605
f01026fb:	e8 94 d9 ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f0102700:	68 c4 67 10 f0       	push   $0xf01067c4
f0102705:	68 32 66 10 f0       	push   $0xf0106632
f010270a:	68 1c 04 00 00       	push   $0x41c
f010270f:	68 05 66 10 f0       	push   $0xf0106605
f0102714:	e8 7b d9 ff ff       	call   f0100094 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102719:	68 38 5f 10 f0       	push   $0xf0105f38
f010271e:	68 32 66 10 f0       	push   $0xf0106632
f0102723:	68 1f 04 00 00       	push   $0x41f
f0102728:	68 05 66 10 f0       	push   $0xf0106605
f010272d:	e8 62 d9 ff ff       	call   f0100094 <_panic>
	assert(pp0->pp_ref == 1);
f0102732:	68 27 68 10 f0       	push   $0xf0106827
f0102737:	68 32 66 10 f0       	push   $0xf0106632
f010273c:	68 21 04 00 00       	push   $0x421
f0102741:	68 05 66 10 f0       	push   $0xf0106605
f0102746:	e8 49 d9 ff ff       	call   f0100094 <_panic>
f010274b:	50                   	push   %eax
f010274c:	68 b4 57 10 f0       	push   $0xf01057b4
f0102751:	68 28 04 00 00       	push   $0x428
f0102756:	68 05 66 10 f0       	push   $0xf0106605
f010275b:	e8 34 d9 ff ff       	call   f0100094 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102760:	68 b3 68 10 f0       	push   $0xf01068b3
f0102765:	68 32 66 10 f0       	push   $0xf0106632
f010276a:	68 29 04 00 00       	push   $0x429
f010276f:	68 05 66 10 f0       	push   $0xf0106605
f0102774:	e8 1b d9 ff ff       	call   f0100094 <_panic>
f0102779:	50                   	push   %eax
f010277a:	68 b4 57 10 f0       	push   $0xf01057b4
f010277f:	6a 58                	push   $0x58
f0102781:	68 18 66 10 f0       	push   $0xf0106618
f0102786:	e8 09 d9 ff ff       	call   f0100094 <_panic>
f010278b:	50                   	push   %eax
f010278c:	68 b4 57 10 f0       	push   $0xf01057b4
f0102791:	6a 58                	push   $0x58
f0102793:	68 18 66 10 f0       	push   $0xf0106618
f0102798:	e8 f7 d8 ff ff       	call   f0100094 <_panic>
		assert((ptep[i] & PTE_P) == 0);
f010279d:	68 cb 68 10 f0       	push   $0xf01068cb
f01027a2:	68 32 66 10 f0       	push   $0xf0106632
f01027a7:	68 33 04 00 00       	push   $0x433
f01027ac:	68 05 66 10 f0       	push   $0xf0106605
f01027b1:	e8 de d8 ff ff       	call   f0100094 <_panic>
	assert(mm1 >= MMIOBASE && mm1 + 8192 < MMIOLIM);
f01027b6:	68 b8 62 10 f0       	push   $0xf01062b8
f01027bb:	68 32 66 10 f0       	push   $0xf0106632
f01027c0:	68 43 04 00 00       	push   $0x443
f01027c5:	68 05 66 10 f0       	push   $0xf0106605
f01027ca:	e8 c5 d8 ff ff       	call   f0100094 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8192 < MMIOLIM);
f01027cf:	68 e0 62 10 f0       	push   $0xf01062e0
f01027d4:	68 32 66 10 f0       	push   $0xf0106632
f01027d9:	68 44 04 00 00       	push   $0x444
f01027de:	68 05 66 10 f0       	push   $0xf0106605
f01027e3:	e8 ac d8 ff ff       	call   f0100094 <_panic>
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f01027e8:	68 08 63 10 f0       	push   $0xf0106308
f01027ed:	68 32 66 10 f0       	push   $0xf0106632
f01027f2:	68 46 04 00 00       	push   $0x446
f01027f7:	68 05 66 10 f0       	push   $0xf0106605
f01027fc:	e8 93 d8 ff ff       	call   f0100094 <_panic>
	assert(mm1 + 8192 <= mm2);
f0102801:	68 e2 68 10 f0       	push   $0xf01068e2
f0102806:	68 32 66 10 f0       	push   $0xf0106632
f010280b:	68 48 04 00 00       	push   $0x448
f0102810:	68 05 66 10 f0       	push   $0xf0106605
f0102815:	e8 7a d8 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f010281a:	68 30 63 10 f0       	push   $0xf0106330
f010281f:	68 32 66 10 f0       	push   $0xf0106632
f0102824:	68 4a 04 00 00       	push   $0x44a
f0102829:	68 05 66 10 f0       	push   $0xf0106605
f010282e:	e8 61 d8 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0102833:	68 54 63 10 f0       	push   $0xf0106354
f0102838:	68 32 66 10 f0       	push   $0xf0106632
f010283d:	68 4b 04 00 00       	push   $0x44b
f0102842:	68 05 66 10 f0       	push   $0xf0106605
f0102847:	e8 48 d8 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f010284c:	68 84 63 10 f0       	push   $0xf0106384
f0102851:	68 32 66 10 f0       	push   $0xf0106632
f0102856:	68 4c 04 00 00       	push   $0x44c
f010285b:	68 05 66 10 f0       	push   $0xf0106605
f0102860:	e8 2f d8 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0102865:	68 a8 63 10 f0       	push   $0xf01063a8
f010286a:	68 32 66 10 f0       	push   $0xf0106632
f010286f:	68 4d 04 00 00       	push   $0x44d
f0102874:	68 05 66 10 f0       	push   $0xf0106605
f0102879:	e8 16 d8 ff ff       	call   f0100094 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f010287e:	68 d4 63 10 f0       	push   $0xf01063d4
f0102883:	68 32 66 10 f0       	push   $0xf0106632
f0102888:	68 4f 04 00 00       	push   $0x44f
f010288d:	68 05 66 10 f0       	push   $0xf0106605
f0102892:	e8 fd d7 ff ff       	call   f0100094 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102897:	68 18 64 10 f0       	push   $0xf0106418
f010289c:	68 32 66 10 f0       	push   $0xf0106632
f01028a1:	68 50 04 00 00       	push   $0x450
f01028a6:	68 05 66 10 f0       	push   $0xf0106605
f01028ab:	e8 e4 d7 ff ff       	call   f0100094 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01028b0:	50                   	push   %eax
f01028b1:	68 d8 57 10 f0       	push   $0xf01057d8
f01028b6:	68 d1 00 00 00       	push   $0xd1
f01028bb:	68 05 66 10 f0       	push   $0xf0106605
f01028c0:	e8 cf d7 ff ff       	call   f0100094 <_panic>
f01028c5:	50                   	push   %eax
f01028c6:	68 d8 57 10 f0       	push   $0xf01057d8
f01028cb:	68 da 00 00 00       	push   $0xda
f01028d0:	68 05 66 10 f0       	push   $0xf0106605
f01028d5:	e8 ba d7 ff ff       	call   f0100094 <_panic>
f01028da:	50                   	push   %eax
f01028db:	68 d8 57 10 f0       	push   $0xf01057d8
f01028e0:	68 e7 00 00 00       	push   $0xe7
f01028e5:	68 05 66 10 f0       	push   $0xf0106605
f01028ea:	e8 a5 d7 ff ff       	call   f0100094 <_panic>
f01028ef:	53                   	push   %ebx
f01028f0:	68 d8 57 10 f0       	push   $0xf01057d8
f01028f5:	68 2a 01 00 00       	push   $0x12a
f01028fa:	68 05 66 10 f0       	push   $0xf0106605
f01028ff:	e8 90 d7 ff ff       	call   f0100094 <_panic>
f0102904:	56                   	push   %esi
f0102905:	68 d8 57 10 f0       	push   $0xf01057d8
f010290a:	68 63 03 00 00       	push   $0x363
f010290f:	68 05 66 10 f0       	push   $0xf0106605
f0102914:	e8 7b d7 ff ff       	call   f0100094 <_panic>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102919:	68 4c 64 10 f0       	push   $0xf010644c
f010291e:	68 32 66 10 f0       	push   $0xf0106632
f0102923:	68 63 03 00 00       	push   $0x363
f0102928:	68 05 66 10 f0       	push   $0xf0106605
f010292d:	e8 62 d7 ff ff       	call   f0100094 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102932:	a1 44 12 23 f0       	mov    0xf0231244,%eax
f0102937:	89 45 cc             	mov    %eax,-0x34(%ebp)
	if ((uint32_t)kva < KERNBASE)
f010293a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010293d:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f0102942:	8d b0 00 00 40 21    	lea    0x21400000(%eax),%esi
f0102948:	89 da                	mov    %ebx,%edx
f010294a:	89 f8                	mov    %edi,%eax
f010294c:	e8 d6 e1 ff ff       	call   f0100b27 <check_va2pa>
f0102951:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f0102958:	76 3d                	jbe    f0102997 <mem_init+0x1677>
f010295a:	8d 14 1e             	lea    (%esi,%ebx,1),%edx
f010295d:	39 d0                	cmp    %edx,%eax
f010295f:	75 4d                	jne    f01029ae <mem_init+0x168e>
f0102961:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE) {
f0102967:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f010296d:	75 d9                	jne    f0102948 <mem_init+0x1628>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f010296f:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0102972:	c1 e6 0c             	shl    $0xc,%esi
f0102975:	bb 00 00 00 00       	mov    $0x0,%ebx
f010297a:	39 f3                	cmp    %esi,%ebx
f010297c:	73 62                	jae    f01029e0 <mem_init+0x16c0>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f010297e:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f0102984:	89 f8                	mov    %edi,%eax
f0102986:	e8 9c e1 ff ff       	call   f0100b27 <check_va2pa>
f010298b:	39 c3                	cmp    %eax,%ebx
f010298d:	75 38                	jne    f01029c7 <mem_init+0x16a7>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f010298f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102995:	eb e3                	jmp    f010297a <mem_init+0x165a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102997:	ff 75 cc             	pushl  -0x34(%ebp)
f010299a:	68 d8 57 10 f0       	push   $0xf01057d8
f010299f:	68 6a 03 00 00       	push   $0x36a
f01029a4:	68 05 66 10 f0       	push   $0xf0106605
f01029a9:	e8 e6 d6 ff ff       	call   f0100094 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f01029ae:	68 80 64 10 f0       	push   $0xf0106480
f01029b3:	68 32 66 10 f0       	push   $0xf0106632
f01029b8:	68 6a 03 00 00       	push   $0x36a
f01029bd:	68 05 66 10 f0       	push   $0xf0106605
f01029c2:	e8 cd d6 ff ff       	call   f0100094 <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f01029c7:	68 b4 64 10 f0       	push   $0xf01064b4
f01029cc:	68 32 66 10 f0       	push   $0xf0106632
f01029d1:	68 71 03 00 00       	push   $0x371
f01029d6:	68 05 66 10 f0       	push   $0xf0106605
f01029db:	e8 b4 d6 ff ff       	call   f0100094 <_panic>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01029e0:	b8 00 30 23 f0       	mov    $0xf0233000,%eax
f01029e5:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f01029ea:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f01029ed:	89 c7                	mov    %eax,%edi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f01029ef:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f01029f2:	89 f3                	mov    %esi,%ebx
f01029f4:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01029f7:	05 00 80 00 20       	add    $0x20008000,%eax
f01029fc:	89 45 cc             	mov    %eax,-0x34(%ebp)
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f01029ff:	8d 86 00 80 00 00    	lea    0x8000(%esi),%eax
f0102a05:	89 45 c8             	mov    %eax,-0x38(%ebp)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102a08:	89 da                	mov    %ebx,%edx
f0102a0a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102a0d:	e8 15 e1 ff ff       	call   f0100b27 <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f0102a12:	81 ff ff ff ff ef    	cmp    $0xefffffff,%edi
f0102a18:	76 59                	jbe    f0102a73 <mem_init+0x1753>
f0102a1a:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0102a1d:	8d 14 19             	lea    (%ecx,%ebx,1),%edx
f0102a20:	39 d0                	cmp    %edx,%eax
f0102a22:	75 66                	jne    f0102a8a <mem_init+0x176a>
f0102a24:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102a2a:	3b 5d c8             	cmp    -0x38(%ebp),%ebx
f0102a2d:	75 d9                	jne    f0102a08 <mem_init+0x16e8>
f0102a2f:	8d 9e 00 80 ff ff    	lea    -0x8000(%esi),%ebx
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102a35:	89 da                	mov    %ebx,%edx
f0102a37:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102a3a:	e8 e8 e0 ff ff       	call   f0100b27 <check_va2pa>
f0102a3f:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102a42:	75 5f                	jne    f0102aa3 <mem_init+0x1783>
f0102a44:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0102a4a:	39 f3                	cmp    %esi,%ebx
f0102a4c:	75 e7                	jne    f0102a35 <mem_init+0x1715>
f0102a4e:	81 ee 00 00 01 00    	sub    $0x10000,%esi
f0102a54:	81 45 d0 00 80 01 00 	addl   $0x18000,-0x30(%ebp)
f0102a5b:	81 c7 00 80 00 00    	add    $0x8000,%edi
	for (n = 0; n < NCPU; n++) {
f0102a61:	81 ff 00 30 27 f0    	cmp    $0xf0273000,%edi
f0102a67:	75 86                	jne    f01029ef <mem_init+0x16cf>
f0102a69:	8b 7d d4             	mov    -0x2c(%ebp),%edi
	for (i = 0; i < NPDENTRIES; i++) {
f0102a6c:	b8 00 00 00 00       	mov    $0x0,%eax
f0102a71:	eb 7f                	jmp    f0102af2 <mem_init+0x17d2>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102a73:	ff 75 c4             	pushl  -0x3c(%ebp)
f0102a76:	68 d8 57 10 f0       	push   $0xf01057d8
f0102a7b:	68 7a 03 00 00       	push   $0x37a
f0102a80:	68 05 66 10 f0       	push   $0xf0106605
f0102a85:	e8 0a d6 ff ff       	call   f0100094 <_panic>
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102a8a:	68 dc 64 10 f0       	push   $0xf01064dc
f0102a8f:	68 32 66 10 f0       	push   $0xf0106632
f0102a94:	68 7a 03 00 00       	push   $0x37a
f0102a99:	68 05 66 10 f0       	push   $0xf0106605
f0102a9e:	e8 f1 d5 ff ff       	call   f0100094 <_panic>
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102aa3:	68 24 65 10 f0       	push   $0xf0106524
f0102aa8:	68 32 66 10 f0       	push   $0xf0106632
f0102aad:	68 7c 03 00 00       	push   $0x37c
f0102ab2:	68 05 66 10 f0       	push   $0xf0106605
f0102ab7:	e8 d8 d5 ff ff       	call   f0100094 <_panic>
			assert(pgdir[i] & PTE_P);
f0102abc:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f0102ac0:	75 48                	jne    f0102b0a <mem_init+0x17ea>
f0102ac2:	68 0d 69 10 f0       	push   $0xf010690d
f0102ac7:	68 32 66 10 f0       	push   $0xf0106632
f0102acc:	68 87 03 00 00       	push   $0x387
f0102ad1:	68 05 66 10 f0       	push   $0xf0106605
f0102ad6:	e8 b9 d5 ff ff       	call   f0100094 <_panic>
				assert(pgdir[i] & PTE_P);
f0102adb:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0102ade:	f6 c2 01             	test   $0x1,%dl
f0102ae1:	74 2c                	je     f0102b0f <mem_init+0x17ef>
				assert(pgdir[i] & PTE_W);
f0102ae3:	f6 c2 02             	test   $0x2,%dl
f0102ae6:	74 40                	je     f0102b28 <mem_init+0x1808>
	for (i = 0; i < NPDENTRIES; i++) {
f0102ae8:	83 c0 01             	add    $0x1,%eax
f0102aeb:	3d 00 04 00 00       	cmp    $0x400,%eax
f0102af0:	74 68                	je     f0102b5a <mem_init+0x183a>
		switch (i) {
f0102af2:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0102af8:	83 fa 04             	cmp    $0x4,%edx
f0102afb:	76 bf                	jbe    f0102abc <mem_init+0x179c>
			if (i >= PDX(KERNBASE)) {
f0102afd:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102b02:	77 d7                	ja     f0102adb <mem_init+0x17bb>
				assert(pgdir[i] == 0);
f0102b04:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f0102b08:	75 37                	jne    f0102b41 <mem_init+0x1821>
	for (i = 0; i < NPDENTRIES; i++) {
f0102b0a:	83 c0 01             	add    $0x1,%eax
f0102b0d:	eb e3                	jmp    f0102af2 <mem_init+0x17d2>
				assert(pgdir[i] & PTE_P);
f0102b0f:	68 0d 69 10 f0       	push   $0xf010690d
f0102b14:	68 32 66 10 f0       	push   $0xf0106632
f0102b19:	68 8b 03 00 00       	push   $0x38b
f0102b1e:	68 05 66 10 f0       	push   $0xf0106605
f0102b23:	e8 6c d5 ff ff       	call   f0100094 <_panic>
				assert(pgdir[i] & PTE_W);
f0102b28:	68 1e 69 10 f0       	push   $0xf010691e
f0102b2d:	68 32 66 10 f0       	push   $0xf0106632
f0102b32:	68 8c 03 00 00       	push   $0x38c
f0102b37:	68 05 66 10 f0       	push   $0xf0106605
f0102b3c:	e8 53 d5 ff ff       	call   f0100094 <_panic>
				assert(pgdir[i] == 0);
f0102b41:	68 2f 69 10 f0       	push   $0xf010692f
f0102b46:	68 32 66 10 f0       	push   $0xf0106632
f0102b4b:	68 8e 03 00 00       	push   $0x38e
f0102b50:	68 05 66 10 f0       	push   $0xf0106605
f0102b55:	e8 3a d5 ff ff       	call   f0100094 <_panic>
	cprintf("check_kern_pgdir() succeeded!\n");
f0102b5a:	83 ec 0c             	sub    $0xc,%esp
f0102b5d:	68 48 65 10 f0       	push   $0xf0106548
f0102b62:	e8 8b 0c 00 00       	call   f01037f2 <cprintf>
	lcr3(PADDR(kern_pgdir));
f0102b67:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f0102b6c:	83 c4 10             	add    $0x10,%esp
f0102b6f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102b74:	0f 86 fb 01 00 00    	jbe    f0102d75 <mem_init+0x1a55>
	return (physaddr_t)kva - KERNBASE;
f0102b7a:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102b7f:	0f 22 d8             	mov    %eax,%cr3
	check_page_free_list(0);
f0102b82:	b8 00 00 00 00       	mov    $0x0,%eax
f0102b87:	e8 ff df ff ff       	call   f0100b8b <check_page_free_list>
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0102b8c:	0f 20 c0             	mov    %cr0,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f0102b8f:	83 e0 f3             	and    $0xfffffff3,%eax
f0102b92:	0d 23 00 05 80       	or     $0x80050023,%eax
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0102b97:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102b9a:	83 ec 0c             	sub    $0xc,%esp
f0102b9d:	6a 00                	push   $0x0
f0102b9f:	e8 f2 e3 ff ff       	call   f0100f96 <page_alloc>
f0102ba4:	89 c6                	mov    %eax,%esi
f0102ba6:	83 c4 10             	add    $0x10,%esp
f0102ba9:	85 c0                	test   %eax,%eax
f0102bab:	0f 84 d9 01 00 00    	je     f0102d8a <mem_init+0x1a6a>
	assert((pp1 = page_alloc(0)));
f0102bb1:	83 ec 0c             	sub    $0xc,%esp
f0102bb4:	6a 00                	push   $0x0
f0102bb6:	e8 db e3 ff ff       	call   f0100f96 <page_alloc>
f0102bbb:	89 c7                	mov    %eax,%edi
f0102bbd:	83 c4 10             	add    $0x10,%esp
f0102bc0:	85 c0                	test   %eax,%eax
f0102bc2:	0f 84 db 01 00 00    	je     f0102da3 <mem_init+0x1a83>
	assert((pp2 = page_alloc(0)));
f0102bc8:	83 ec 0c             	sub    $0xc,%esp
f0102bcb:	6a 00                	push   $0x0
f0102bcd:	e8 c4 e3 ff ff       	call   f0100f96 <page_alloc>
f0102bd2:	89 c3                	mov    %eax,%ebx
f0102bd4:	83 c4 10             	add    $0x10,%esp
f0102bd7:	85 c0                	test   %eax,%eax
f0102bd9:	0f 84 dd 01 00 00    	je     f0102dbc <mem_init+0x1a9c>
	page_free(pp0);
f0102bdf:	83 ec 0c             	sub    $0xc,%esp
f0102be2:	56                   	push   %esi
f0102be3:	e8 20 e4 ff ff       	call   f0101008 <page_free>
	return (pp - pages) << PGSHIFT;
f0102be8:	89 f8                	mov    %edi,%eax
f0102bea:	2b 05 90 1e 23 f0    	sub    0xf0231e90,%eax
f0102bf0:	c1 f8 03             	sar    $0x3,%eax
f0102bf3:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102bf6:	89 c2                	mov    %eax,%edx
f0102bf8:	c1 ea 0c             	shr    $0xc,%edx
f0102bfb:	83 c4 10             	add    $0x10,%esp
f0102bfe:	3b 15 88 1e 23 f0    	cmp    0xf0231e88,%edx
f0102c04:	0f 83 cb 01 00 00    	jae    f0102dd5 <mem_init+0x1ab5>
	memset(page2kva(pp1), 1, PGSIZE);
f0102c0a:	83 ec 04             	sub    $0x4,%esp
f0102c0d:	68 00 10 00 00       	push   $0x1000
f0102c12:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0102c14:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102c19:	50                   	push   %eax
f0102c1a:	e8 85 1e 00 00       	call   f0104aa4 <memset>
	return (pp - pages) << PGSHIFT;
f0102c1f:	89 d8                	mov    %ebx,%eax
f0102c21:	2b 05 90 1e 23 f0    	sub    0xf0231e90,%eax
f0102c27:	c1 f8 03             	sar    $0x3,%eax
f0102c2a:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102c2d:	89 c2                	mov    %eax,%edx
f0102c2f:	c1 ea 0c             	shr    $0xc,%edx
f0102c32:	83 c4 10             	add    $0x10,%esp
f0102c35:	3b 15 88 1e 23 f0    	cmp    0xf0231e88,%edx
f0102c3b:	0f 83 a6 01 00 00    	jae    f0102de7 <mem_init+0x1ac7>
	memset(page2kva(pp2), 2, PGSIZE);
f0102c41:	83 ec 04             	sub    $0x4,%esp
f0102c44:	68 00 10 00 00       	push   $0x1000
f0102c49:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f0102c4b:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102c50:	50                   	push   %eax
f0102c51:	e8 4e 1e 00 00       	call   f0104aa4 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102c56:	6a 02                	push   $0x2
f0102c58:	68 00 10 00 00       	push   $0x1000
f0102c5d:	57                   	push   %edi
f0102c5e:	ff 35 8c 1e 23 f0    	pushl  0xf0231e8c
f0102c64:	e8 ee e5 ff ff       	call   f0101257 <page_insert>
	assert(pp1->pp_ref == 1);
f0102c69:	83 c4 20             	add    $0x20,%esp
f0102c6c:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102c71:	0f 85 82 01 00 00    	jne    f0102df9 <mem_init+0x1ad9>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102c77:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102c7e:	01 01 01 
f0102c81:	0f 85 8b 01 00 00    	jne    f0102e12 <mem_init+0x1af2>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102c87:	6a 02                	push   $0x2
f0102c89:	68 00 10 00 00       	push   $0x1000
f0102c8e:	53                   	push   %ebx
f0102c8f:	ff 35 8c 1e 23 f0    	pushl  0xf0231e8c
f0102c95:	e8 bd e5 ff ff       	call   f0101257 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102c9a:	83 c4 10             	add    $0x10,%esp
f0102c9d:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102ca4:	02 02 02 
f0102ca7:	0f 85 7e 01 00 00    	jne    f0102e2b <mem_init+0x1b0b>
	assert(pp2->pp_ref == 1);
f0102cad:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102cb2:	0f 85 8c 01 00 00    	jne    f0102e44 <mem_init+0x1b24>
	assert(pp1->pp_ref == 0);
f0102cb8:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102cbd:	0f 85 9a 01 00 00    	jne    f0102e5d <mem_init+0x1b3d>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102cc3:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102cca:	03 03 03 
	return (pp - pages) << PGSHIFT;
f0102ccd:	89 d8                	mov    %ebx,%eax
f0102ccf:	2b 05 90 1e 23 f0    	sub    0xf0231e90,%eax
f0102cd5:	c1 f8 03             	sar    $0x3,%eax
f0102cd8:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102cdb:	89 c2                	mov    %eax,%edx
f0102cdd:	c1 ea 0c             	shr    $0xc,%edx
f0102ce0:	3b 15 88 1e 23 f0    	cmp    0xf0231e88,%edx
f0102ce6:	0f 83 8a 01 00 00    	jae    f0102e76 <mem_init+0x1b56>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102cec:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102cf3:	03 03 03 
f0102cf6:	0f 85 8c 01 00 00    	jne    f0102e88 <mem_init+0x1b68>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102cfc:	83 ec 08             	sub    $0x8,%esp
f0102cff:	68 00 10 00 00       	push   $0x1000
f0102d04:	ff 35 8c 1e 23 f0    	pushl  0xf0231e8c
f0102d0a:	e8 02 e5 ff ff       	call   f0101211 <page_remove>
	assert(pp2->pp_ref == 0);
f0102d0f:	83 c4 10             	add    $0x10,%esp
f0102d12:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102d17:	0f 85 84 01 00 00    	jne    f0102ea1 <mem_init+0x1b81>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102d1d:	8b 0d 8c 1e 23 f0    	mov    0xf0231e8c,%ecx
f0102d23:	8b 11                	mov    (%ecx),%edx
f0102d25:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	return (pp - pages) << PGSHIFT;
f0102d2b:	89 f0                	mov    %esi,%eax
f0102d2d:	2b 05 90 1e 23 f0    	sub    0xf0231e90,%eax
f0102d33:	c1 f8 03             	sar    $0x3,%eax
f0102d36:	c1 e0 0c             	shl    $0xc,%eax
f0102d39:	39 c2                	cmp    %eax,%edx
f0102d3b:	0f 85 79 01 00 00    	jne    f0102eba <mem_init+0x1b9a>
	kern_pgdir[0] = 0;
f0102d41:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102d47:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102d4c:	0f 85 81 01 00 00    	jne    f0102ed3 <mem_init+0x1bb3>
	pp0->pp_ref = 0;
f0102d52:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f0102d58:	83 ec 0c             	sub    $0xc,%esp
f0102d5b:	56                   	push   %esi
f0102d5c:	e8 a7 e2 ff ff       	call   f0101008 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102d61:	c7 04 24 dc 65 10 f0 	movl   $0xf01065dc,(%esp)
f0102d68:	e8 85 0a 00 00       	call   f01037f2 <cprintf>
}
f0102d6d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102d70:	5b                   	pop    %ebx
f0102d71:	5e                   	pop    %esi
f0102d72:	5f                   	pop    %edi
f0102d73:	5d                   	pop    %ebp
f0102d74:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102d75:	50                   	push   %eax
f0102d76:	68 d8 57 10 f0       	push   $0xf01057d8
f0102d7b:	68 03 01 00 00       	push   $0x103
f0102d80:	68 05 66 10 f0       	push   $0xf0106605
f0102d85:	e8 0a d3 ff ff       	call   f0100094 <_panic>
	assert((pp0 = page_alloc(0)));
f0102d8a:	68 19 67 10 f0       	push   $0xf0106719
f0102d8f:	68 32 66 10 f0       	push   $0xf0106632
f0102d94:	68 65 04 00 00       	push   $0x465
f0102d99:	68 05 66 10 f0       	push   $0xf0106605
f0102d9e:	e8 f1 d2 ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f0102da3:	68 2f 67 10 f0       	push   $0xf010672f
f0102da8:	68 32 66 10 f0       	push   $0xf0106632
f0102dad:	68 66 04 00 00       	push   $0x466
f0102db2:	68 05 66 10 f0       	push   $0xf0106605
f0102db7:	e8 d8 d2 ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f0102dbc:	68 45 67 10 f0       	push   $0xf0106745
f0102dc1:	68 32 66 10 f0       	push   $0xf0106632
f0102dc6:	68 67 04 00 00       	push   $0x467
f0102dcb:	68 05 66 10 f0       	push   $0xf0106605
f0102dd0:	e8 bf d2 ff ff       	call   f0100094 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102dd5:	50                   	push   %eax
f0102dd6:	68 b4 57 10 f0       	push   $0xf01057b4
f0102ddb:	6a 58                	push   $0x58
f0102ddd:	68 18 66 10 f0       	push   $0xf0106618
f0102de2:	e8 ad d2 ff ff       	call   f0100094 <_panic>
f0102de7:	50                   	push   %eax
f0102de8:	68 b4 57 10 f0       	push   $0xf01057b4
f0102ded:	6a 58                	push   $0x58
f0102def:	68 18 66 10 f0       	push   $0xf0106618
f0102df4:	e8 9b d2 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 1);
f0102df9:	68 16 68 10 f0       	push   $0xf0106816
f0102dfe:	68 32 66 10 f0       	push   $0xf0106632
f0102e03:	68 6c 04 00 00       	push   $0x46c
f0102e08:	68 05 66 10 f0       	push   $0xf0106605
f0102e0d:	e8 82 d2 ff ff       	call   f0100094 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102e12:	68 68 65 10 f0       	push   $0xf0106568
f0102e17:	68 32 66 10 f0       	push   $0xf0106632
f0102e1c:	68 6d 04 00 00       	push   $0x46d
f0102e21:	68 05 66 10 f0       	push   $0xf0106605
f0102e26:	e8 69 d2 ff ff       	call   f0100094 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102e2b:	68 8c 65 10 f0       	push   $0xf010658c
f0102e30:	68 32 66 10 f0       	push   $0xf0106632
f0102e35:	68 6f 04 00 00       	push   $0x46f
f0102e3a:	68 05 66 10 f0       	push   $0xf0106605
f0102e3f:	e8 50 d2 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f0102e44:	68 38 68 10 f0       	push   $0xf0106838
f0102e49:	68 32 66 10 f0       	push   $0xf0106632
f0102e4e:	68 70 04 00 00       	push   $0x470
f0102e53:	68 05 66 10 f0       	push   $0xf0106605
f0102e58:	e8 37 d2 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 0);
f0102e5d:	68 a2 68 10 f0       	push   $0xf01068a2
f0102e62:	68 32 66 10 f0       	push   $0xf0106632
f0102e67:	68 71 04 00 00       	push   $0x471
f0102e6c:	68 05 66 10 f0       	push   $0xf0106605
f0102e71:	e8 1e d2 ff ff       	call   f0100094 <_panic>
f0102e76:	50                   	push   %eax
f0102e77:	68 b4 57 10 f0       	push   $0xf01057b4
f0102e7c:	6a 58                	push   $0x58
f0102e7e:	68 18 66 10 f0       	push   $0xf0106618
f0102e83:	e8 0c d2 ff ff       	call   f0100094 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102e88:	68 b0 65 10 f0       	push   $0xf01065b0
f0102e8d:	68 32 66 10 f0       	push   $0xf0106632
f0102e92:	68 73 04 00 00       	push   $0x473
f0102e97:	68 05 66 10 f0       	push   $0xf0106605
f0102e9c:	e8 f3 d1 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f0102ea1:	68 70 68 10 f0       	push   $0xf0106870
f0102ea6:	68 32 66 10 f0       	push   $0xf0106632
f0102eab:	68 75 04 00 00       	push   $0x475
f0102eb0:	68 05 66 10 f0       	push   $0xf0106605
f0102eb5:	e8 da d1 ff ff       	call   f0100094 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102eba:	68 38 5f 10 f0       	push   $0xf0105f38
f0102ebf:	68 32 66 10 f0       	push   $0xf0106632
f0102ec4:	68 78 04 00 00       	push   $0x478
f0102ec9:	68 05 66 10 f0       	push   $0xf0106605
f0102ece:	e8 c1 d1 ff ff       	call   f0100094 <_panic>
	assert(pp0->pp_ref == 1);
f0102ed3:	68 27 68 10 f0       	push   $0xf0106827
f0102ed8:	68 32 66 10 f0       	push   $0xf0106632
f0102edd:	68 7a 04 00 00       	push   $0x47a
f0102ee2:	68 05 66 10 f0       	push   $0xf0106605
f0102ee7:	e8 a8 d1 ff ff       	call   f0100094 <_panic>

f0102eec <user_mem_check>:
}
f0102eec:	b8 00 00 00 00       	mov    $0x0,%eax
f0102ef1:	c3                   	ret    

f0102ef2 <user_mem_assert>:
}
f0102ef2:	c3                   	ret    

f0102ef3 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0102ef3:	55                   	push   %ebp
f0102ef4:	89 e5                	mov    %esp,%ebp
f0102ef6:	57                   	push   %edi
f0102ef7:	56                   	push   %esi
f0102ef8:	53                   	push   %ebx
f0102ef9:	83 ec 0c             	sub    $0xc,%esp
f0102efc:	89 c7                	mov    %eax,%edi
	// LAB 3: Your code here.
	void* i;
	for (i = ROUNDDOWN(va, PGSIZE); i < ROUNDUP(va + len, PGSIZE); i+=PGSIZE){
f0102efe:	89 d3                	mov    %edx,%ebx
f0102f00:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0102f06:	8d b4 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%esi
f0102f0d:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
f0102f13:	39 f3                	cmp    %esi,%ebx
f0102f15:	73 5c                	jae    f0102f73 <region_alloc+0x80>
		struct PageInfo *pginfo = page_alloc(0);
f0102f17:	83 ec 0c             	sub    $0xc,%esp
f0102f1a:	6a 00                	push   $0x0
f0102f1c:	e8 75 e0 ff ff       	call   f0100f96 <page_alloc>
		if (!pginfo) {
f0102f21:	83 c4 10             	add    $0x10,%esp
f0102f24:	85 c0                	test   %eax,%eax
f0102f26:	74 20                	je     f0102f48 <region_alloc+0x55>
			 panic("region_alloc:%e", -E_NO_MEM);
		}
		pginfo->pp_ref++;
f0102f28:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
		int r = page_insert(e->env_pgdir, pginfo, i, PTE_W | PTE_U | PTE_P);
f0102f2d:	6a 07                	push   $0x7
f0102f2f:	53                   	push   %ebx
f0102f30:	50                   	push   %eax
f0102f31:	ff 77 60             	pushl  0x60(%edi)
f0102f34:	e8 1e e3 ff ff       	call   f0101257 <page_insert>
		if (r < 0) {
f0102f39:	83 c4 10             	add    $0x10,%esp
f0102f3c:	85 c0                	test   %eax,%eax
f0102f3e:	78 1e                	js     f0102f5e <region_alloc+0x6b>
	for (i = ROUNDDOWN(va, PGSIZE); i < ROUNDUP(va + len, PGSIZE); i+=PGSIZE){
f0102f40:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102f46:	eb cb                	jmp    f0102f13 <region_alloc+0x20>
			 panic("region_alloc:%e", -E_NO_MEM);
f0102f48:	6a fc                	push   $0xfffffffc
f0102f4a:	68 3d 69 10 f0       	push   $0xf010693d
f0102f4f:	68 22 01 00 00       	push   $0x122
f0102f54:	68 4d 69 10 f0       	push   $0xf010694d
f0102f59:	e8 36 d1 ff ff       	call   f0100094 <_panic>
			 panic("region_alloc:%e", r);
f0102f5e:	50                   	push   %eax
f0102f5f:	68 3d 69 10 f0       	push   $0xf010693d
f0102f64:	68 27 01 00 00       	push   $0x127
f0102f69:	68 4d 69 10 f0       	push   $0xf010694d
f0102f6e:	e8 21 d1 ff ff       	call   f0100094 <_panic>
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
}
f0102f73:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102f76:	5b                   	pop    %ebx
f0102f77:	5e                   	pop    %esi
f0102f78:	5f                   	pop    %edi
f0102f79:	5d                   	pop    %ebp
f0102f7a:	c3                   	ret    

f0102f7b <envid2env>:
{
f0102f7b:	55                   	push   %ebp
f0102f7c:	89 e5                	mov    %esp,%ebp
f0102f7e:	56                   	push   %esi
f0102f7f:	53                   	push   %ebx
f0102f80:	8b 45 08             	mov    0x8(%ebp),%eax
f0102f83:	8b 55 10             	mov    0x10(%ebp),%edx
	if (envid == 0) {
f0102f86:	85 c0                	test   %eax,%eax
f0102f88:	74 2e                	je     f0102fb8 <envid2env+0x3d>
	e = &envs[ENVX(envid)];
f0102f8a:	89 c3                	mov    %eax,%ebx
f0102f8c:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0102f92:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f0102f95:	03 1d 44 12 23 f0    	add    0xf0231244,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0102f9b:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0102f9f:	74 31                	je     f0102fd2 <envid2env+0x57>
f0102fa1:	39 43 48             	cmp    %eax,0x48(%ebx)
f0102fa4:	75 2c                	jne    f0102fd2 <envid2env+0x57>
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0102fa6:	84 d2                	test   %dl,%dl
f0102fa8:	75 38                	jne    f0102fe2 <envid2env+0x67>
	*env_store = e;
f0102faa:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102fad:	89 18                	mov    %ebx,(%eax)
	return 0;
f0102faf:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102fb4:	5b                   	pop    %ebx
f0102fb5:	5e                   	pop    %esi
f0102fb6:	5d                   	pop    %ebp
f0102fb7:	c3                   	ret    
		*env_store = curenv;
f0102fb8:	e8 e5 20 00 00       	call   f01050a2 <cpunum>
f0102fbd:	6b c0 74             	imul   $0x74,%eax,%eax
f0102fc0:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0102fc6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102fc9:	89 01                	mov    %eax,(%ecx)
		return 0;
f0102fcb:	b8 00 00 00 00       	mov    $0x0,%eax
f0102fd0:	eb e2                	jmp    f0102fb4 <envid2env+0x39>
		*env_store = 0;
f0102fd2:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102fd5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102fdb:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102fe0:	eb d2                	jmp    f0102fb4 <envid2env+0x39>
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0102fe2:	e8 bb 20 00 00       	call   f01050a2 <cpunum>
f0102fe7:	6b c0 74             	imul   $0x74,%eax,%eax
f0102fea:	39 98 28 20 23 f0    	cmp    %ebx,-0xfdcdfd8(%eax)
f0102ff0:	74 b8                	je     f0102faa <envid2env+0x2f>
f0102ff2:	8b 73 4c             	mov    0x4c(%ebx),%esi
f0102ff5:	e8 a8 20 00 00       	call   f01050a2 <cpunum>
f0102ffa:	6b c0 74             	imul   $0x74,%eax,%eax
f0102ffd:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0103003:	3b 70 48             	cmp    0x48(%eax),%esi
f0103006:	74 a2                	je     f0102faa <envid2env+0x2f>
		*env_store = 0;
f0103008:	8b 45 0c             	mov    0xc(%ebp),%eax
f010300b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0103011:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103016:	eb 9c                	jmp    f0102fb4 <envid2env+0x39>

f0103018 <env_init_percpu>:
	asm volatile("lgdt (%0)" : : "r" (p));
f0103018:	b8 20 13 12 f0       	mov    $0xf0121320,%eax
f010301d:	0f 01 10             	lgdtl  (%eax)
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f0103020:	b8 23 00 00 00       	mov    $0x23,%eax
f0103025:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f0103027:	8e e0                	mov    %eax,%fs
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f0103029:	b8 10 00 00 00       	mov    $0x10,%eax
f010302e:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f0103030:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f0103032:	8e d0                	mov    %eax,%ss
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f0103034:	ea 3b 30 10 f0 08 00 	ljmp   $0x8,$0xf010303b
	asm volatile("lldt %0" : : "r" (sel));
f010303b:	b8 00 00 00 00       	mov    $0x0,%eax
f0103040:	0f 00 d0             	lldt   %ax
}
f0103043:	c3                   	ret    

f0103044 <env_init>:
{
f0103044:	55                   	push   %ebp
f0103045:	89 e5                	mov    %esp,%ebp
f0103047:	56                   	push   %esi
f0103048:	53                   	push   %ebx
		envs[i].env_id = 0;
f0103049:	8b 35 44 12 23 f0    	mov    0xf0231244,%esi
f010304f:	8b 15 48 12 23 f0    	mov    0xf0231248,%edx
f0103055:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f010305b:	89 f3                	mov    %esi,%ebx
f010305d:	eb 02                	jmp    f0103061 <env_init+0x1d>
f010305f:	89 c8                	mov    %ecx,%eax
f0103061:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_link = env_free_list;
f0103068:	89 50 44             	mov    %edx,0x44(%eax)
f010306b:	8d 48 84             	lea    -0x7c(%eax),%ecx
		env_free_list = &envs[i];
f010306e:	89 c2                	mov    %eax,%edx
	for (int i = NENV-1;i >= 0;i--) {
f0103070:	39 d8                	cmp    %ebx,%eax
f0103072:	75 eb                	jne    f010305f <env_init+0x1b>
f0103074:	89 35 48 12 23 f0    	mov    %esi,0xf0231248
	env_init_percpu();
f010307a:	e8 99 ff ff ff       	call   f0103018 <env_init_percpu>
}
f010307f:	5b                   	pop    %ebx
f0103080:	5e                   	pop    %esi
f0103081:	5d                   	pop    %ebp
f0103082:	c3                   	ret    

f0103083 <env_alloc>:
{
f0103083:	55                   	push   %ebp
f0103084:	89 e5                	mov    %esp,%ebp
f0103086:	56                   	push   %esi
f0103087:	53                   	push   %ebx
	if (!(e = env_free_list))
f0103088:	8b 1d 48 12 23 f0    	mov    0xf0231248,%ebx
f010308e:	85 db                	test   %ebx,%ebx
f0103090:	0f 84 71 01 00 00    	je     f0103207 <env_alloc+0x184>
	if (!(p = page_alloc(ALLOC_ZERO)))
f0103096:	83 ec 0c             	sub    $0xc,%esp
f0103099:	6a 01                	push   $0x1
f010309b:	e8 f6 de ff ff       	call   f0100f96 <page_alloc>
f01030a0:	89 c6                	mov    %eax,%esi
f01030a2:	83 c4 10             	add    $0x10,%esp
f01030a5:	85 c0                	test   %eax,%eax
f01030a7:	0f 84 61 01 00 00    	je     f010320e <env_alloc+0x18b>
	return (pp - pages) << PGSHIFT;
f01030ad:	2b 05 90 1e 23 f0    	sub    0xf0231e90,%eax
f01030b3:	c1 f8 03             	sar    $0x3,%eax
f01030b6:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f01030b9:	89 c2                	mov    %eax,%edx
f01030bb:	c1 ea 0c             	shr    $0xc,%edx
f01030be:	3b 15 88 1e 23 f0    	cmp    0xf0231e88,%edx
f01030c4:	0f 83 16 01 00 00    	jae    f01031e0 <env_alloc+0x15d>
	return (void *)(pa + KERNBASE);
f01030ca:	2d 00 00 00 10       	sub    $0x10000000,%eax
	e->env_pgdir = page2kva(p);	
f01030cf:	89 43 60             	mov    %eax,0x60(%ebx)
	memcpy(e->env_pgdir, kern_pgdir, PGSIZE);
f01030d2:	83 ec 04             	sub    $0x4,%esp
f01030d5:	68 00 10 00 00       	push   $0x1000
f01030da:	ff 35 8c 1e 23 f0    	pushl  0xf0231e8c
f01030e0:	50                   	push   %eax
f01030e1:	e8 68 1a 00 00       	call   f0104b4e <memcpy>
	p->pp_ref++;
f01030e6:	66 83 46 04 01       	addw   $0x1,0x4(%esi)
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f01030eb:	8b 43 60             	mov    0x60(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f01030ee:	83 c4 10             	add    $0x10,%esp
f01030f1:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01030f6:	0f 86 f6 00 00 00    	jbe    f01031f2 <env_alloc+0x16f>
	return (physaddr_t)kva - KERNBASE;
f01030fc:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0103102:	83 ca 05             	or     $0x5,%edx
f0103105:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f010310b:	8b 43 48             	mov    0x48(%ebx),%eax
f010310e:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0103113:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f0103118:	ba 00 10 00 00       	mov    $0x1000,%edx
f010311d:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f0103120:	89 da                	mov    %ebx,%edx
f0103122:	2b 15 44 12 23 f0    	sub    0xf0231244,%edx
f0103128:	c1 fa 02             	sar    $0x2,%edx
f010312b:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f0103131:	09 d0                	or     %edx,%eax
f0103133:	89 43 48             	mov    %eax,0x48(%ebx)
	e->env_parent_id = parent_id;
f0103136:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103139:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f010313c:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0103143:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f010314a:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0103151:	83 ec 04             	sub    $0x4,%esp
f0103154:	6a 44                	push   $0x44
f0103156:	6a 00                	push   $0x0
f0103158:	53                   	push   %ebx
f0103159:	e8 46 19 00 00       	call   f0104aa4 <memset>
	e->env_tf.tf_ds = GD_UD | 3;
f010315e:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0103164:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f010316a:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0103170:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0103177:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	e->env_pgfault_upcall = 0;
f010317d:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)
	e->env_ipc_recving = 0;
f0103184:	c6 43 68 00          	movb   $0x0,0x68(%ebx)
	env_free_list = e->env_link;
f0103188:	8b 43 44             	mov    0x44(%ebx),%eax
f010318b:	a3 48 12 23 f0       	mov    %eax,0xf0231248
	*newenv_store = e;
f0103190:	8b 45 08             	mov    0x8(%ebp),%eax
f0103193:	89 18                	mov    %ebx,(%eax)
	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103195:	8b 5b 48             	mov    0x48(%ebx),%ebx
f0103198:	e8 05 1f 00 00       	call   f01050a2 <cpunum>
f010319d:	6b c0 74             	imul   $0x74,%eax,%eax
f01031a0:	83 c4 10             	add    $0x10,%esp
f01031a3:	ba 00 00 00 00       	mov    $0x0,%edx
f01031a8:	83 b8 28 20 23 f0 00 	cmpl   $0x0,-0xfdcdfd8(%eax)
f01031af:	74 11                	je     f01031c2 <env_alloc+0x13f>
f01031b1:	e8 ec 1e 00 00       	call   f01050a2 <cpunum>
f01031b6:	6b c0 74             	imul   $0x74,%eax,%eax
f01031b9:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f01031bf:	8b 50 48             	mov    0x48(%eax),%edx
f01031c2:	83 ec 04             	sub    $0x4,%esp
f01031c5:	53                   	push   %ebx
f01031c6:	52                   	push   %edx
f01031c7:	68 58 69 10 f0       	push   $0xf0106958
f01031cc:	e8 21 06 00 00       	call   f01037f2 <cprintf>
	return 0;
f01031d1:	83 c4 10             	add    $0x10,%esp
f01031d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01031d9:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01031dc:	5b                   	pop    %ebx
f01031dd:	5e                   	pop    %esi
f01031de:	5d                   	pop    %ebp
f01031df:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01031e0:	50                   	push   %eax
f01031e1:	68 b4 57 10 f0       	push   $0xf01057b4
f01031e6:	6a 58                	push   $0x58
f01031e8:	68 18 66 10 f0       	push   $0xf0106618
f01031ed:	e8 a2 ce ff ff       	call   f0100094 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01031f2:	50                   	push   %eax
f01031f3:	68 d8 57 10 f0       	push   $0xf01057d8
f01031f8:	68 c6 00 00 00       	push   $0xc6
f01031fd:	68 4d 69 10 f0       	push   $0xf010694d
f0103202:	e8 8d ce ff ff       	call   f0100094 <_panic>
		return -E_NO_FREE_ENV;
f0103207:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f010320c:	eb cb                	jmp    f01031d9 <env_alloc+0x156>
		return -E_NO_MEM;
f010320e:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0103213:	eb c4                	jmp    f01031d9 <env_alloc+0x156>

f0103215 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f0103215:	55                   	push   %ebp
f0103216:	89 e5                	mov    %esp,%ebp
f0103218:	57                   	push   %edi
f0103219:	56                   	push   %esi
f010321a:	53                   	push   %ebx
f010321b:	83 ec 34             	sub    $0x34,%esp
f010321e:	8b 75 08             	mov    0x8(%ebp),%esi
	// LAB 3: Your code here.
	struct 	Env *e;	
	int r = env_alloc(&e, (envid_t)0);
f0103221:	6a 00                	push   $0x0
f0103223:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103226:	50                   	push   %eax
f0103227:	e8 57 fe ff ff       	call   f0103083 <env_alloc>
	if (r < 0) {
f010322c:	83 c4 10             	add    $0x10,%esp
f010322f:	85 c0                	test   %eax,%eax
f0103231:	78 36                	js     f0103269 <env_create+0x54>
		 panic("env_create: %e", r);
	}
	e->env_type = type;
f0103233:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103236:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103239:	89 47 50             	mov    %eax,0x50(%edi)
	if (elf->e_magic != ELF_MAGIC) {
f010323c:	81 3e 7f 45 4c 46    	cmpl   $0x464c457f,(%esi)
f0103242:	75 3a                	jne    f010327e <env_create+0x69>
	ph = (struct Proghdr *) (binary + elf->e_phoff);
f0103244:	89 f3                	mov    %esi,%ebx
f0103246:	03 5e 1c             	add    0x1c(%esi),%ebx
	eph = ph + elf->e_phnum;
f0103249:	0f b7 46 2c          	movzwl 0x2c(%esi),%eax
f010324d:	c1 e0 05             	shl    $0x5,%eax
f0103250:	01 d8                	add    %ebx,%eax
f0103252:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	lcr3(PADDR(e->env_pgdir));
f0103255:	8b 47 60             	mov    0x60(%edi),%eax
	if ((uint32_t)kva < KERNBASE)
f0103258:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010325d:	76 36                	jbe    f0103295 <env_create+0x80>
	return (physaddr_t)kva - KERNBASE;
f010325f:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0103264:	0f 22 d8             	mov    %eax,%cr3
f0103267:	eb 5b                	jmp    f01032c4 <env_create+0xaf>
		 panic("env_create: %e", r);
f0103269:	50                   	push   %eax
f010326a:	68 6d 69 10 f0       	push   $0xf010696d
f010326f:	68 94 01 00 00       	push   $0x194
f0103274:	68 4d 69 10 f0       	push   $0xf010694d
f0103279:	e8 16 ce ff ff       	call   f0100094 <_panic>
		 panic("load_icode: not an Elf file");
f010327e:	83 ec 04             	sub    $0x4,%esp
f0103281:	68 7c 69 10 f0       	push   $0xf010697c
f0103286:	68 6c 01 00 00       	push   $0x16c
f010328b:	68 4d 69 10 f0       	push   $0xf010694d
f0103290:	e8 ff cd ff ff       	call   f0100094 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103295:	50                   	push   %eax
f0103296:	68 d8 57 10 f0       	push   $0xf01057d8
f010329b:	68 71 01 00 00       	push   $0x171
f01032a0:	68 4d 69 10 f0       	push   $0xf010694d
f01032a5:	e8 ea cd ff ff       	call   f0100094 <_panic>
					 panic("load_icode: file size is greater than memory size");
f01032aa:	83 ec 04             	sub    $0x4,%esp
f01032ad:	68 bc 69 10 f0       	push   $0xf01069bc
f01032b2:	68 75 01 00 00       	push   $0x175
f01032b7:	68 4d 69 10 f0       	push   $0xf010694d
f01032bc:	e8 d3 cd ff ff       	call   f0100094 <_panic>
	for (; ph<eph; ph++) {
f01032c1:	83 c3 20             	add    $0x20,%ebx
f01032c4:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f01032c7:	76 47                	jbe    f0103310 <env_create+0xfb>
		if (ph->p_type == ELF_PROG_LOAD) {
f01032c9:	83 3b 01             	cmpl   $0x1,(%ebx)
f01032cc:	75 f3                	jne    f01032c1 <env_create+0xac>
			 if (ph->p_filesz > ph->p_memsz) {
f01032ce:	8b 4b 14             	mov    0x14(%ebx),%ecx
f01032d1:	39 4b 10             	cmp    %ecx,0x10(%ebx)
f01032d4:	77 d4                	ja     f01032aa <env_create+0x95>
			 region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f01032d6:	8b 53 08             	mov    0x8(%ebx),%edx
f01032d9:	89 f8                	mov    %edi,%eax
f01032db:	e8 13 fc ff ff       	call   f0102ef3 <region_alloc>
			 memcpy((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
f01032e0:	83 ec 04             	sub    $0x4,%esp
f01032e3:	ff 73 10             	pushl  0x10(%ebx)
f01032e6:	89 f0                	mov    %esi,%eax
f01032e8:	03 43 04             	add    0x4(%ebx),%eax
f01032eb:	50                   	push   %eax
f01032ec:	ff 73 08             	pushl  0x8(%ebx)
f01032ef:	e8 5a 18 00 00       	call   f0104b4e <memcpy>
			 memset((void *)ph->p_va + ph->p_filesz, 0, ph->p_memsz - ph->p_filesz);
f01032f4:	8b 43 10             	mov    0x10(%ebx),%eax
f01032f7:	83 c4 0c             	add    $0xc,%esp
f01032fa:	8b 53 14             	mov    0x14(%ebx),%edx
f01032fd:	29 c2                	sub    %eax,%edx
f01032ff:	52                   	push   %edx
f0103300:	6a 00                	push   $0x0
f0103302:	03 43 08             	add    0x8(%ebx),%eax
f0103305:	50                   	push   %eax
f0103306:	e8 99 17 00 00       	call   f0104aa4 <memset>
f010330b:	83 c4 10             	add    $0x10,%esp
f010330e:	eb b1                	jmp    f01032c1 <env_create+0xac>
	e->env_tf.tf_eip = elf->e_entry;
f0103310:	8b 46 18             	mov    0x18(%esi),%eax
f0103313:	89 47 30             	mov    %eax,0x30(%edi)
	region_alloc(e, (void *)USTACKTOP - PGSIZE, PGSIZE);
f0103316:	b9 00 10 00 00       	mov    $0x1000,%ecx
f010331b:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0103320:	89 f8                	mov    %edi,%eax
f0103322:	e8 cc fb ff ff       	call   f0102ef3 <region_alloc>
	lcr3(PADDR(kern_pgdir));
f0103327:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f010332c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103331:	76 10                	jbe    f0103343 <env_create+0x12e>
	return (physaddr_t)kva - KERNBASE;
f0103333:	05 00 00 00 10       	add    $0x10000000,%eax
f0103338:	0f 22 d8             	mov    %eax,%cr3
	load_icode(e, binary);
}
f010333b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010333e:	5b                   	pop    %ebx
f010333f:	5e                   	pop    %esi
f0103340:	5f                   	pop    %edi
f0103341:	5d                   	pop    %ebp
f0103342:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103343:	50                   	push   %eax
f0103344:	68 d8 57 10 f0       	push   $0xf01057d8
f0103349:	68 83 01 00 00       	push   $0x183
f010334e:	68 4d 69 10 f0       	push   $0xf010694d
f0103353:	e8 3c cd ff ff       	call   f0100094 <_panic>

f0103358 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0103358:	55                   	push   %ebp
f0103359:	89 e5                	mov    %esp,%ebp
f010335b:	57                   	push   %edi
f010335c:	56                   	push   %esi
f010335d:	53                   	push   %ebx
f010335e:	83 ec 1c             	sub    $0x1c,%esp
f0103361:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103364:	e8 39 1d 00 00       	call   f01050a2 <cpunum>
f0103369:	6b c0 74             	imul   $0x74,%eax,%eax
f010336c:	39 b8 28 20 23 f0    	cmp    %edi,-0xfdcdfd8(%eax)
f0103372:	74 48                	je     f01033bc <env_free+0x64>
		lcr3(PADDR(kern_pgdir));

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103374:	8b 5f 48             	mov    0x48(%edi),%ebx
f0103377:	e8 26 1d 00 00       	call   f01050a2 <cpunum>
f010337c:	6b c0 74             	imul   $0x74,%eax,%eax
f010337f:	ba 00 00 00 00       	mov    $0x0,%edx
f0103384:	83 b8 28 20 23 f0 00 	cmpl   $0x0,-0xfdcdfd8(%eax)
f010338b:	74 11                	je     f010339e <env_free+0x46>
f010338d:	e8 10 1d 00 00       	call   f01050a2 <cpunum>
f0103392:	6b c0 74             	imul   $0x74,%eax,%eax
f0103395:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f010339b:	8b 50 48             	mov    0x48(%eax),%edx
f010339e:	83 ec 04             	sub    $0x4,%esp
f01033a1:	53                   	push   %ebx
f01033a2:	52                   	push   %edx
f01033a3:	68 98 69 10 f0       	push   $0xf0106998
f01033a8:	e8 45 04 00 00       	call   f01037f2 <cprintf>
f01033ad:	83 c4 10             	add    $0x10,%esp
f01033b0:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f01033b7:	e9 a9 00 00 00       	jmp    f0103465 <env_free+0x10d>
		lcr3(PADDR(kern_pgdir));
f01033bc:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f01033c1:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01033c6:	76 0a                	jbe    f01033d2 <env_free+0x7a>
	return (physaddr_t)kva - KERNBASE;
f01033c8:	05 00 00 00 10       	add    $0x10000000,%eax
f01033cd:	0f 22 d8             	mov    %eax,%cr3
f01033d0:	eb a2                	jmp    f0103374 <env_free+0x1c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01033d2:	50                   	push   %eax
f01033d3:	68 d8 57 10 f0       	push   $0xf01057d8
f01033d8:	68 a8 01 00 00       	push   $0x1a8
f01033dd:	68 4d 69 10 f0       	push   $0xf010694d
f01033e2:	e8 ad cc ff ff       	call   f0100094 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01033e7:	56                   	push   %esi
f01033e8:	68 b4 57 10 f0       	push   $0xf01057b4
f01033ed:	68 b7 01 00 00       	push   $0x1b7
f01033f2:	68 4d 69 10 f0       	push   $0xf010694d
f01033f7:	e8 98 cc ff ff       	call   f0100094 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01033fc:	83 ec 08             	sub    $0x8,%esp
f01033ff:	89 d8                	mov    %ebx,%eax
f0103401:	c1 e0 0c             	shl    $0xc,%eax
f0103404:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103407:	50                   	push   %eax
f0103408:	ff 77 60             	pushl  0x60(%edi)
f010340b:	e8 01 de ff ff       	call   f0101211 <page_remove>
f0103410:	83 c4 10             	add    $0x10,%esp
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103413:	83 c3 01             	add    $0x1,%ebx
f0103416:	83 c6 04             	add    $0x4,%esi
f0103419:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f010341f:	74 07                	je     f0103428 <env_free+0xd0>
			if (pt[pteno] & PTE_P)
f0103421:	f6 06 01             	testb  $0x1,(%esi)
f0103424:	74 ed                	je     f0103413 <env_free+0xbb>
f0103426:	eb d4                	jmp    f01033fc <env_free+0xa4>
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103428:	8b 47 60             	mov    0x60(%edi),%eax
f010342b:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010342e:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
	if (PGNUM(pa) >= npages)
f0103435:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103438:	3b 05 88 1e 23 f0    	cmp    0xf0231e88,%eax
f010343e:	73 69                	jae    f01034a9 <env_free+0x151>
		page_decref(pa2page(pa));
f0103440:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f0103443:	a1 90 1e 23 f0       	mov    0xf0231e90,%eax
f0103448:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010344b:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f010344e:	50                   	push   %eax
f010344f:	e8 ef db ff ff       	call   f0101043 <page_decref>
f0103454:	83 c4 10             	add    $0x10,%esp
f0103457:	83 45 e0 04          	addl   $0x4,-0x20(%ebp)
f010345b:	8b 45 e0             	mov    -0x20(%ebp),%eax
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f010345e:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f0103463:	74 58                	je     f01034bd <env_free+0x165>
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103465:	8b 47 60             	mov    0x60(%edi),%eax
f0103468:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010346b:	8b 34 10             	mov    (%eax,%edx,1),%esi
f010346e:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0103474:	74 e1                	je     f0103457 <env_free+0xff>
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103476:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	if (PGNUM(pa) >= npages)
f010347c:	89 f0                	mov    %esi,%eax
f010347e:	c1 e8 0c             	shr    $0xc,%eax
f0103481:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0103484:	39 05 88 1e 23 f0    	cmp    %eax,0xf0231e88
f010348a:	0f 86 57 ff ff ff    	jbe    f01033e7 <env_free+0x8f>
	return (void *)(pa + KERNBASE);
f0103490:	81 ee 00 00 00 10    	sub    $0x10000000,%esi
f0103496:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103499:	c1 e0 14             	shl    $0x14,%eax
f010349c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f010349f:	bb 00 00 00 00       	mov    $0x0,%ebx
f01034a4:	e9 78 ff ff ff       	jmp    f0103421 <env_free+0xc9>
		panic("pa2page called with invalid pa");
f01034a9:	83 ec 04             	sub    $0x4,%esp
f01034ac:	68 04 5e 10 f0       	push   $0xf0105e04
f01034b1:	6a 51                	push   $0x51
f01034b3:	68 18 66 10 f0       	push   $0xf0106618
f01034b8:	e8 d7 cb ff ff       	call   f0100094 <_panic>
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f01034bd:	8b 47 60             	mov    0x60(%edi),%eax
	if ((uint32_t)kva < KERNBASE)
f01034c0:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01034c5:	76 49                	jbe    f0103510 <env_free+0x1b8>
	e->env_pgdir = 0;
f01034c7:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
	return (physaddr_t)kva - KERNBASE;
f01034ce:	05 00 00 00 10       	add    $0x10000000,%eax
	if (PGNUM(pa) >= npages)
f01034d3:	c1 e8 0c             	shr    $0xc,%eax
f01034d6:	3b 05 88 1e 23 f0    	cmp    0xf0231e88,%eax
f01034dc:	73 47                	jae    f0103525 <env_free+0x1cd>
	page_decref(pa2page(pa));
f01034de:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f01034e1:	8b 15 90 1e 23 f0    	mov    0xf0231e90,%edx
f01034e7:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f01034ea:	50                   	push   %eax
f01034eb:	e8 53 db ff ff       	call   f0101043 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f01034f0:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f01034f7:	a1 48 12 23 f0       	mov    0xf0231248,%eax
f01034fc:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f01034ff:	89 3d 48 12 23 f0    	mov    %edi,0xf0231248
}
f0103505:	83 c4 10             	add    $0x10,%esp
f0103508:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010350b:	5b                   	pop    %ebx
f010350c:	5e                   	pop    %esi
f010350d:	5f                   	pop    %edi
f010350e:	5d                   	pop    %ebp
f010350f:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103510:	50                   	push   %eax
f0103511:	68 d8 57 10 f0       	push   $0xf01057d8
f0103516:	68 c5 01 00 00       	push   $0x1c5
f010351b:	68 4d 69 10 f0       	push   $0xf010694d
f0103520:	e8 6f cb ff ff       	call   f0100094 <_panic>
		panic("pa2page called with invalid pa");
f0103525:	83 ec 04             	sub    $0x4,%esp
f0103528:	68 04 5e 10 f0       	push   $0xf0105e04
f010352d:	6a 51                	push   $0x51
f010352f:	68 18 66 10 f0       	push   $0xf0106618
f0103534:	e8 5b cb ff ff       	call   f0100094 <_panic>

f0103539 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0103539:	55                   	push   %ebp
f010353a:	89 e5                	mov    %esp,%ebp
f010353c:	53                   	push   %ebx
f010353d:	83 ec 04             	sub    $0x4,%esp
f0103540:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103543:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0103547:	74 21                	je     f010356a <env_destroy+0x31>
		e->env_status = ENV_DYING;
		return;
	}

	env_free(e);
f0103549:	83 ec 0c             	sub    $0xc,%esp
f010354c:	53                   	push   %ebx
f010354d:	e8 06 fe ff ff       	call   f0103358 <env_free>

	if (curenv == e) {
f0103552:	e8 4b 1b 00 00       	call   f01050a2 <cpunum>
f0103557:	6b c0 74             	imul   $0x74,%eax,%eax
f010355a:	83 c4 10             	add    $0x10,%esp
f010355d:	39 98 28 20 23 f0    	cmp    %ebx,-0xfdcdfd8(%eax)
f0103563:	74 1e                	je     f0103583 <env_destroy+0x4a>
		curenv = NULL;
		sched_yield();
	}
}
f0103565:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103568:	c9                   	leave  
f0103569:	c3                   	ret    
	if (e->env_status == ENV_RUNNING && curenv != e) {
f010356a:	e8 33 1b 00 00       	call   f01050a2 <cpunum>
f010356f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103572:	39 98 28 20 23 f0    	cmp    %ebx,-0xfdcdfd8(%eax)
f0103578:	74 cf                	je     f0103549 <env_destroy+0x10>
		e->env_status = ENV_DYING;
f010357a:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0103581:	eb e2                	jmp    f0103565 <env_destroy+0x2c>
		curenv = NULL;
f0103583:	e8 1a 1b 00 00       	call   f01050a2 <cpunum>
f0103588:	6b c0 74             	imul   $0x74,%eax,%eax
f010358b:	c7 80 28 20 23 f0 00 	movl   $0x0,-0xfdcdfd8(%eax)
f0103592:	00 00 00 
		sched_yield();
f0103595:	e8 6f 08 00 00       	call   f0103e09 <sched_yield>

f010359a <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f010359a:	55                   	push   %ebp
f010359b:	89 e5                	mov    %esp,%ebp
f010359d:	53                   	push   %ebx
f010359e:	83 ec 04             	sub    $0x4,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f01035a1:	e8 fc 1a 00 00       	call   f01050a2 <cpunum>
f01035a6:	6b c0 74             	imul   $0x74,%eax,%eax
f01035a9:	8b 98 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%ebx
f01035af:	e8 ee 1a 00 00       	call   f01050a2 <cpunum>
f01035b4:	89 43 5c             	mov    %eax,0x5c(%ebx)

	asm volatile(
f01035b7:	8b 65 08             	mov    0x8(%ebp),%esp
f01035ba:	61                   	popa   
f01035bb:	07                   	pop    %es
f01035bc:	1f                   	pop    %ds
f01035bd:	83 c4 08             	add    $0x8,%esp
f01035c0:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f01035c1:	83 ec 04             	sub    $0x4,%esp
f01035c4:	68 ae 69 10 f0       	push   $0xf01069ae
f01035c9:	68 fc 01 00 00       	push   $0x1fc
f01035ce:	68 4d 69 10 f0       	push   $0xf010694d
f01035d3:	e8 bc ca ff ff       	call   f0100094 <_panic>

f01035d8 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f01035d8:	55                   	push   %ebp
f01035d9:	89 e5                	mov    %esp,%ebp
f01035db:	53                   	push   %ebx
f01035dc:	83 ec 04             	sub    $0x4,%esp
f01035df:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	if (curenv && curenv->env_status == ENV_RUNNING) {
f01035e2:	e8 bb 1a 00 00       	call   f01050a2 <cpunum>
f01035e7:	6b c0 74             	imul   $0x74,%eax,%eax
f01035ea:	83 b8 28 20 23 f0 00 	cmpl   $0x0,-0xfdcdfd8(%eax)
f01035f1:	74 14                	je     f0103607 <env_run+0x2f>
f01035f3:	e8 aa 1a 00 00       	call   f01050a2 <cpunum>
f01035f8:	6b c0 74             	imul   $0x74,%eax,%eax
f01035fb:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0103601:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103605:	74 34                	je     f010363b <env_run+0x63>
		 curenv->env_status = ENV_RUNNABLE;
	}
		 curenv = e;
f0103607:	e8 96 1a 00 00       	call   f01050a2 <cpunum>
f010360c:	6b c0 74             	imul   $0x74,%eax,%eax
f010360f:	89 98 28 20 23 f0    	mov    %ebx,-0xfdcdfd8(%eax)
		 e->env_status = ENV_RUNNING;
f0103615:	c7 43 54 03 00 00 00 	movl   $0x3,0x54(%ebx)
		 e->env_runs++ ;
f010361c:	83 43 58 01          	addl   $0x1,0x58(%ebx)
		 lcr3(PADDR(e->env_pgdir));
f0103620:	8b 43 60             	mov    0x60(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f0103623:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103628:	76 28                	jbe    f0103652 <env_run+0x7a>
	return (physaddr_t)kva - KERNBASE;
f010362a:	05 00 00 00 10       	add    $0x10000000,%eax
f010362f:	0f 22 d8             	mov    %eax,%cr3

		 env_pop_tf(&e->env_tf);
f0103632:	83 ec 0c             	sub    $0xc,%esp
f0103635:	53                   	push   %ebx
f0103636:	e8 5f ff ff ff       	call   f010359a <env_pop_tf>
		 curenv->env_status = ENV_RUNNABLE;
f010363b:	e8 62 1a 00 00       	call   f01050a2 <cpunum>
f0103640:	6b c0 74             	imul   $0x74,%eax,%eax
f0103643:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0103649:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
f0103650:	eb b5                	jmp    f0103607 <env_run+0x2f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103652:	50                   	push   %eax
f0103653:	68 d8 57 10 f0       	push   $0xf01057d8
f0103658:	68 20 02 00 00       	push   $0x220
f010365d:	68 4d 69 10 f0       	push   $0xf010694d
f0103662:	e8 2d ca ff ff       	call   f0100094 <_panic>

f0103667 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103667:	55                   	push   %ebp
f0103668:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010366a:	8b 45 08             	mov    0x8(%ebp),%eax
f010366d:	ba 70 00 00 00       	mov    $0x70,%edx
f0103672:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103673:	ba 71 00 00 00       	mov    $0x71,%edx
f0103678:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103679:	0f b6 c0             	movzbl %al,%eax
}
f010367c:	5d                   	pop    %ebp
f010367d:	c3                   	ret    

f010367e <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f010367e:	55                   	push   %ebp
f010367f:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103681:	8b 45 08             	mov    0x8(%ebp),%eax
f0103684:	ba 70 00 00 00       	mov    $0x70,%edx
f0103689:	ee                   	out    %al,(%dx)
f010368a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010368d:	ba 71 00 00 00       	mov    $0x71,%edx
f0103692:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103693:	5d                   	pop    %ebp
f0103694:	c3                   	ret    

f0103695 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0103695:	55                   	push   %ebp
f0103696:	89 e5                	mov    %esp,%ebp
f0103698:	56                   	push   %esi
f0103699:	53                   	push   %ebx
f010369a:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f010369d:	66 a3 a8 13 12 f0    	mov    %ax,0xf01213a8
	if (!didinit)
f01036a3:	80 3d 4c 12 23 f0 00 	cmpb   $0x0,0xf023124c
f01036aa:	75 07                	jne    f01036b3 <irq_setmask_8259A+0x1e>
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
}
f01036ac:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01036af:	5b                   	pop    %ebx
f01036b0:	5e                   	pop    %esi
f01036b1:	5d                   	pop    %ebp
f01036b2:	c3                   	ret    
f01036b3:	89 c6                	mov    %eax,%esi
f01036b5:	ba 21 00 00 00       	mov    $0x21,%edx
f01036ba:	ee                   	out    %al,(%dx)
	outb(IO_PIC2+1, (char)(mask >> 8));
f01036bb:	66 c1 e8 08          	shr    $0x8,%ax
f01036bf:	ba a1 00 00 00       	mov    $0xa1,%edx
f01036c4:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f01036c5:	83 ec 0c             	sub    $0xc,%esp
f01036c8:	68 ee 69 10 f0       	push   $0xf01069ee
f01036cd:	e8 20 01 00 00       	call   f01037f2 <cprintf>
f01036d2:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f01036d5:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f01036da:	0f b7 f6             	movzwl %si,%esi
f01036dd:	f7 d6                	not    %esi
f01036df:	eb 19                	jmp    f01036fa <irq_setmask_8259A+0x65>
			cprintf(" %d", i);
f01036e1:	83 ec 08             	sub    $0x8,%esp
f01036e4:	53                   	push   %ebx
f01036e5:	68 93 6e 10 f0       	push   $0xf0106e93
f01036ea:	e8 03 01 00 00       	call   f01037f2 <cprintf>
f01036ef:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f01036f2:	83 c3 01             	add    $0x1,%ebx
f01036f5:	83 fb 10             	cmp    $0x10,%ebx
f01036f8:	74 07                	je     f0103701 <irq_setmask_8259A+0x6c>
		if (~mask & (1<<i))
f01036fa:	0f a3 de             	bt     %ebx,%esi
f01036fd:	73 f3                	jae    f01036f2 <irq_setmask_8259A+0x5d>
f01036ff:	eb e0                	jmp    f01036e1 <irq_setmask_8259A+0x4c>
	cprintf("\n");
f0103701:	83 ec 0c             	sub    $0xc,%esp
f0103704:	68 0b 69 10 f0       	push   $0xf010690b
f0103709:	e8 e4 00 00 00       	call   f01037f2 <cprintf>
f010370e:	83 c4 10             	add    $0x10,%esp
f0103711:	eb 99                	jmp    f01036ac <irq_setmask_8259A+0x17>

f0103713 <pic_init>:
{
f0103713:	55                   	push   %ebp
f0103714:	89 e5                	mov    %esp,%ebp
f0103716:	57                   	push   %edi
f0103717:	56                   	push   %esi
f0103718:	53                   	push   %ebx
f0103719:	83 ec 0c             	sub    $0xc,%esp
	didinit = 1;
f010371c:	c6 05 4c 12 23 f0 01 	movb   $0x1,0xf023124c
f0103723:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103728:	bb 21 00 00 00       	mov    $0x21,%ebx
f010372d:	89 da                	mov    %ebx,%edx
f010372f:	ee                   	out    %al,(%dx)
f0103730:	b9 a1 00 00 00       	mov    $0xa1,%ecx
f0103735:	89 ca                	mov    %ecx,%edx
f0103737:	ee                   	out    %al,(%dx)
f0103738:	bf 11 00 00 00       	mov    $0x11,%edi
f010373d:	be 20 00 00 00       	mov    $0x20,%esi
f0103742:	89 f8                	mov    %edi,%eax
f0103744:	89 f2                	mov    %esi,%edx
f0103746:	ee                   	out    %al,(%dx)
f0103747:	b8 20 00 00 00       	mov    $0x20,%eax
f010374c:	89 da                	mov    %ebx,%edx
f010374e:	ee                   	out    %al,(%dx)
f010374f:	b8 04 00 00 00       	mov    $0x4,%eax
f0103754:	ee                   	out    %al,(%dx)
f0103755:	b8 03 00 00 00       	mov    $0x3,%eax
f010375a:	ee                   	out    %al,(%dx)
f010375b:	bb a0 00 00 00       	mov    $0xa0,%ebx
f0103760:	89 f8                	mov    %edi,%eax
f0103762:	89 da                	mov    %ebx,%edx
f0103764:	ee                   	out    %al,(%dx)
f0103765:	b8 28 00 00 00       	mov    $0x28,%eax
f010376a:	89 ca                	mov    %ecx,%edx
f010376c:	ee                   	out    %al,(%dx)
f010376d:	b8 02 00 00 00       	mov    $0x2,%eax
f0103772:	ee                   	out    %al,(%dx)
f0103773:	b8 01 00 00 00       	mov    $0x1,%eax
f0103778:	ee                   	out    %al,(%dx)
f0103779:	bf 68 00 00 00       	mov    $0x68,%edi
f010377e:	89 f8                	mov    %edi,%eax
f0103780:	89 f2                	mov    %esi,%edx
f0103782:	ee                   	out    %al,(%dx)
f0103783:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0103788:	89 c8                	mov    %ecx,%eax
f010378a:	ee                   	out    %al,(%dx)
f010378b:	89 f8                	mov    %edi,%eax
f010378d:	89 da                	mov    %ebx,%edx
f010378f:	ee                   	out    %al,(%dx)
f0103790:	89 c8                	mov    %ecx,%eax
f0103792:	ee                   	out    %al,(%dx)
	if (irq_mask_8259A != 0xFFFF)
f0103793:	0f b7 05 a8 13 12 f0 	movzwl 0xf01213a8,%eax
f010379a:	66 83 f8 ff          	cmp    $0xffff,%ax
f010379e:	75 08                	jne    f01037a8 <pic_init+0x95>
}
f01037a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01037a3:	5b                   	pop    %ebx
f01037a4:	5e                   	pop    %esi
f01037a5:	5f                   	pop    %edi
f01037a6:	5d                   	pop    %ebp
f01037a7:	c3                   	ret    
		irq_setmask_8259A(irq_mask_8259A);
f01037a8:	83 ec 0c             	sub    $0xc,%esp
f01037ab:	0f b7 c0             	movzwl %ax,%eax
f01037ae:	50                   	push   %eax
f01037af:	e8 e1 fe ff ff       	call   f0103695 <irq_setmask_8259A>
f01037b4:	83 c4 10             	add    $0x10,%esp
}
f01037b7:	eb e7                	jmp    f01037a0 <pic_init+0x8d>

f01037b9 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01037b9:	55                   	push   %ebp
f01037ba:	89 e5                	mov    %esp,%ebp
f01037bc:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f01037bf:	ff 75 08             	pushl  0x8(%ebp)
f01037c2:	e8 14 d0 ff ff       	call   f01007db <cputchar>
	*cnt++;
}
f01037c7:	83 c4 10             	add    $0x10,%esp
f01037ca:	c9                   	leave  
f01037cb:	c3                   	ret    

f01037cc <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01037cc:	55                   	push   %ebp
f01037cd:	89 e5                	mov    %esp,%ebp
f01037cf:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f01037d2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01037d9:	ff 75 0c             	pushl  0xc(%ebp)
f01037dc:	ff 75 08             	pushl  0x8(%ebp)
f01037df:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01037e2:	50                   	push   %eax
f01037e3:	68 b9 37 10 f0       	push   $0xf01037b9
f01037e8:	e8 af 0b 00 00       	call   f010439c <vprintfmt>
	return cnt;
}
f01037ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01037f0:	c9                   	leave  
f01037f1:	c3                   	ret    

f01037f2 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01037f2:	55                   	push   %ebp
f01037f3:	89 e5                	mov    %esp,%ebp
f01037f5:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01037f8:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f01037fb:	50                   	push   %eax
f01037fc:	ff 75 08             	pushl  0x8(%ebp)
f01037ff:	e8 c8 ff ff ff       	call   f01037cc <vcprintf>
	va_end(ap);

	return cnt;
}
f0103804:	c9                   	leave  
f0103805:	c3                   	ret    

f0103806 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103806:	55                   	push   %ebp
f0103807:	89 e5                	mov    %esp,%ebp
f0103809:	56                   	push   %esi
f010380a:	53                   	push   %ebx
	// get a triple fault.  If you set up an individual CPU's TSS
	// wrong, you may not get a fault until you try to return from
	// user space on that CPU.
	//
	// LAB 4: Your code here:
	struct Taskstate *this_ts = &thiscpu->cpu_ts;
f010380b:	e8 92 18 00 00       	call   f01050a2 <cpunum>
f0103810:	6b f0 74             	imul   $0x74,%eax,%esi
f0103813:	8d 9e 2c 20 23 f0    	lea    -0xfdcdfd4(%esi),%ebx
	this_ts->ts_esp0 = KSTACKTOP - thiscpu->cpu_id*(KSTKSIZE + KSTKGAP);
f0103819:	e8 84 18 00 00       	call   f01050a2 <cpunum>
f010381e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103821:	0f b6 88 20 20 23 f0 	movzbl -0xfdcdfe0(%eax),%ecx
f0103828:	c1 e1 10             	shl    $0x10,%ecx
f010382b:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
f0103830:	29 c8                	sub    %ecx,%eax
f0103832:	89 86 30 20 23 f0    	mov    %eax,-0xfdcdfd0(%esi)
	this_ts->ts_ss0 = GD_KD;
f0103838:	66 c7 86 34 20 23 f0 	movw   $0x10,-0xfdcdfcc(%esi)
f010383f:	10 00 
	this_ts->ts_iomb = sizeof(struct Taskstate);
f0103841:	66 c7 86 92 20 23 f0 	movw   $0x68,-0xfdcdf6e(%esi)
f0103848:	68 00 
//	ts.ts_esp0 = KSTACKTOP;
//	ts.ts_ss0 = GD_KD;
//	ts.ts_iomb = sizeof(struct Taskstate);

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3) + thiscpu->cpu_id] = SEG16(STS_T32A, (uint32_t) (this_ts),
f010384a:	e8 53 18 00 00       	call   f01050a2 <cpunum>
f010384f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103852:	0f b6 80 20 20 23 f0 	movzbl -0xfdcdfe0(%eax),%eax
f0103859:	83 c0 05             	add    $0x5,%eax
f010385c:	66 c7 04 c5 40 13 12 	movw   $0x67,-0xfedecc0(,%eax,8)
f0103863:	f0 67 00 
f0103866:	66 89 1c c5 42 13 12 	mov    %bx,-0xfedecbe(,%eax,8)
f010386d:	f0 
f010386e:	89 da                	mov    %ebx,%edx
f0103870:	c1 ea 10             	shr    $0x10,%edx
f0103873:	88 14 c5 44 13 12 f0 	mov    %dl,-0xfedecbc(,%eax,8)
f010387a:	c6 04 c5 45 13 12 f0 	movb   $0x99,-0xfedecbb(,%eax,8)
f0103881:	99 
f0103882:	c6 04 c5 46 13 12 f0 	movb   $0x40,-0xfedecba(,%eax,8)
f0103889:	40 
f010388a:	c1 eb 18             	shr    $0x18,%ebx
f010388d:	88 1c c5 47 13 12 f0 	mov    %bl,-0xfedecb9(,%eax,8)
					sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3) + thiscpu->cpu_id].sd_s = 0;
f0103894:	e8 09 18 00 00       	call   f01050a2 <cpunum>
f0103899:	6b c0 74             	imul   $0x74,%eax,%eax
f010389c:	0f b6 80 20 20 23 f0 	movzbl -0xfdcdfe0(%eax),%eax
f01038a3:	80 24 c5 6d 13 12 f0 	andb   $0xef,-0xfedec93(,%eax,8)
f01038aa:	ef 

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0 + (thiscpu->cpu_id << 3));
f01038ab:	e8 f2 17 00 00       	call   f01050a2 <cpunum>
f01038b0:	6b c0 74             	imul   $0x74,%eax,%eax
f01038b3:	0f b6 80 20 20 23 f0 	movzbl -0xfdcdfe0(%eax),%eax
f01038ba:	8d 04 c5 28 00 00 00 	lea    0x28(,%eax,8),%eax
	asm volatile("ltr %0" : : "r" (sel));
f01038c1:	0f 00 d8             	ltr    %ax
	asm volatile("lidt (%0)" : : "r" (p));
f01038c4:	b8 ac 13 12 f0       	mov    $0xf01213ac,%eax
f01038c9:	0f 01 18             	lidtl  (%eax)

	// Load the IDT
	lidt(&idt_pd);
}
f01038cc:	5b                   	pop    %ebx
f01038cd:	5e                   	pop    %esi
f01038ce:	5d                   	pop    %ebp
f01038cf:	c3                   	ret    

f01038d0 <trap_init>:
{
f01038d0:	55                   	push   %ebp
f01038d1:	89 e5                	mov    %esp,%ebp
f01038d3:	83 ec 08             	sub    $0x8,%esp
	trap_init_percpu();
f01038d6:	e8 2b ff ff ff       	call   f0103806 <trap_init_percpu>
}
f01038db:	c9                   	leave  
f01038dc:	c3                   	ret    

f01038dd <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f01038dd:	55                   	push   %ebp
f01038de:	89 e5                	mov    %esp,%ebp
f01038e0:	53                   	push   %ebx
f01038e1:	83 ec 0c             	sub    $0xc,%esp
f01038e4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f01038e7:	ff 33                	pushl  (%ebx)
f01038e9:	68 02 6a 10 f0       	push   $0xf0106a02
f01038ee:	e8 ff fe ff ff       	call   f01037f2 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f01038f3:	83 c4 08             	add    $0x8,%esp
f01038f6:	ff 73 04             	pushl  0x4(%ebx)
f01038f9:	68 11 6a 10 f0       	push   $0xf0106a11
f01038fe:	e8 ef fe ff ff       	call   f01037f2 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103903:	83 c4 08             	add    $0x8,%esp
f0103906:	ff 73 08             	pushl  0x8(%ebx)
f0103909:	68 20 6a 10 f0       	push   $0xf0106a20
f010390e:	e8 df fe ff ff       	call   f01037f2 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103913:	83 c4 08             	add    $0x8,%esp
f0103916:	ff 73 0c             	pushl  0xc(%ebx)
f0103919:	68 2f 6a 10 f0       	push   $0xf0106a2f
f010391e:	e8 cf fe ff ff       	call   f01037f2 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103923:	83 c4 08             	add    $0x8,%esp
f0103926:	ff 73 10             	pushl  0x10(%ebx)
f0103929:	68 3e 6a 10 f0       	push   $0xf0106a3e
f010392e:	e8 bf fe ff ff       	call   f01037f2 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103933:	83 c4 08             	add    $0x8,%esp
f0103936:	ff 73 14             	pushl  0x14(%ebx)
f0103939:	68 4d 6a 10 f0       	push   $0xf0106a4d
f010393e:	e8 af fe ff ff       	call   f01037f2 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103943:	83 c4 08             	add    $0x8,%esp
f0103946:	ff 73 18             	pushl  0x18(%ebx)
f0103949:	68 5c 6a 10 f0       	push   $0xf0106a5c
f010394e:	e8 9f fe ff ff       	call   f01037f2 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103953:	83 c4 08             	add    $0x8,%esp
f0103956:	ff 73 1c             	pushl  0x1c(%ebx)
f0103959:	68 6b 6a 10 f0       	push   $0xf0106a6b
f010395e:	e8 8f fe ff ff       	call   f01037f2 <cprintf>
}
f0103963:	83 c4 10             	add    $0x10,%esp
f0103966:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103969:	c9                   	leave  
f010396a:	c3                   	ret    

f010396b <print_trapframe>:
{
f010396b:	55                   	push   %ebp
f010396c:	89 e5                	mov    %esp,%ebp
f010396e:	56                   	push   %esi
f010396f:	53                   	push   %ebx
f0103970:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0103973:	e8 2a 17 00 00       	call   f01050a2 <cpunum>
f0103978:	83 ec 04             	sub    $0x4,%esp
f010397b:	50                   	push   %eax
f010397c:	53                   	push   %ebx
f010397d:	68 cf 6a 10 f0       	push   $0xf0106acf
f0103982:	e8 6b fe ff ff       	call   f01037f2 <cprintf>
	print_regs(&tf->tf_regs);
f0103987:	89 1c 24             	mov    %ebx,(%esp)
f010398a:	e8 4e ff ff ff       	call   f01038dd <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f010398f:	83 c4 08             	add    $0x8,%esp
f0103992:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103996:	50                   	push   %eax
f0103997:	68 ed 6a 10 f0       	push   $0xf0106aed
f010399c:	e8 51 fe ff ff       	call   f01037f2 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f01039a1:	83 c4 08             	add    $0x8,%esp
f01039a4:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f01039a8:	50                   	push   %eax
f01039a9:	68 00 6b 10 f0       	push   $0xf0106b00
f01039ae:	e8 3f fe ff ff       	call   f01037f2 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01039b3:	8b 43 28             	mov    0x28(%ebx),%eax
	if (trapno < ARRAY_SIZE(excnames))
f01039b6:	83 c4 10             	add    $0x10,%esp
f01039b9:	83 f8 13             	cmp    $0x13,%eax
f01039bc:	0f 86 e1 00 00 00    	jbe    f0103aa3 <print_trapframe+0x138>
		return "System call";
f01039c2:	ba 7a 6a 10 f0       	mov    $0xf0106a7a,%edx
	if (trapno == T_SYSCALL)
f01039c7:	83 f8 30             	cmp    $0x30,%eax
f01039ca:	74 13                	je     f01039df <print_trapframe+0x74>
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f01039cc:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
f01039cf:	83 fa 0f             	cmp    $0xf,%edx
f01039d2:	ba 86 6a 10 f0       	mov    $0xf0106a86,%edx
f01039d7:	b9 95 6a 10 f0       	mov    $0xf0106a95,%ecx
f01039dc:	0f 46 d1             	cmovbe %ecx,%edx
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01039df:	83 ec 04             	sub    $0x4,%esp
f01039e2:	52                   	push   %edx
f01039e3:	50                   	push   %eax
f01039e4:	68 13 6b 10 f0       	push   $0xf0106b13
f01039e9:	e8 04 fe ff ff       	call   f01037f2 <cprintf>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f01039ee:	83 c4 10             	add    $0x10,%esp
f01039f1:	39 1d 60 1a 23 f0    	cmp    %ebx,0xf0231a60
f01039f7:	0f 84 b2 00 00 00    	je     f0103aaf <print_trapframe+0x144>
	cprintf("  err  0x%08x", tf->tf_err);
f01039fd:	83 ec 08             	sub    $0x8,%esp
f0103a00:	ff 73 2c             	pushl  0x2c(%ebx)
f0103a03:	68 34 6b 10 f0       	push   $0xf0106b34
f0103a08:	e8 e5 fd ff ff       	call   f01037f2 <cprintf>
	if (tf->tf_trapno == T_PGFLT)
f0103a0d:	83 c4 10             	add    $0x10,%esp
f0103a10:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103a14:	0f 85 b8 00 00 00    	jne    f0103ad2 <print_trapframe+0x167>
			tf->tf_err & 1 ? "protection" : "not-present");
f0103a1a:	8b 43 2c             	mov    0x2c(%ebx),%eax
		cprintf(" [%s, %s, %s]\n",
f0103a1d:	89 c2                	mov    %eax,%edx
f0103a1f:	83 e2 01             	and    $0x1,%edx
f0103a22:	b9 a8 6a 10 f0       	mov    $0xf0106aa8,%ecx
f0103a27:	ba b3 6a 10 f0       	mov    $0xf0106ab3,%edx
f0103a2c:	0f 44 ca             	cmove  %edx,%ecx
f0103a2f:	89 c2                	mov    %eax,%edx
f0103a31:	83 e2 02             	and    $0x2,%edx
f0103a34:	be bf 6a 10 f0       	mov    $0xf0106abf,%esi
f0103a39:	ba c5 6a 10 f0       	mov    $0xf0106ac5,%edx
f0103a3e:	0f 45 d6             	cmovne %esi,%edx
f0103a41:	83 e0 04             	and    $0x4,%eax
f0103a44:	b8 ca 6a 10 f0       	mov    $0xf0106aca,%eax
f0103a49:	be ff 6b 10 f0       	mov    $0xf0106bff,%esi
f0103a4e:	0f 44 c6             	cmove  %esi,%eax
f0103a51:	51                   	push   %ecx
f0103a52:	52                   	push   %edx
f0103a53:	50                   	push   %eax
f0103a54:	68 42 6b 10 f0       	push   $0xf0106b42
f0103a59:	e8 94 fd ff ff       	call   f01037f2 <cprintf>
f0103a5e:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103a61:	83 ec 08             	sub    $0x8,%esp
f0103a64:	ff 73 30             	pushl  0x30(%ebx)
f0103a67:	68 51 6b 10 f0       	push   $0xf0106b51
f0103a6c:	e8 81 fd ff ff       	call   f01037f2 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103a71:	83 c4 08             	add    $0x8,%esp
f0103a74:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103a78:	50                   	push   %eax
f0103a79:	68 60 6b 10 f0       	push   $0xf0106b60
f0103a7e:	e8 6f fd ff ff       	call   f01037f2 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103a83:	83 c4 08             	add    $0x8,%esp
f0103a86:	ff 73 38             	pushl  0x38(%ebx)
f0103a89:	68 73 6b 10 f0       	push   $0xf0106b73
f0103a8e:	e8 5f fd ff ff       	call   f01037f2 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0103a93:	83 c4 10             	add    $0x10,%esp
f0103a96:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103a9a:	75 4b                	jne    f0103ae7 <print_trapframe+0x17c>
}
f0103a9c:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103a9f:	5b                   	pop    %ebx
f0103aa0:	5e                   	pop    %esi
f0103aa1:	5d                   	pop    %ebp
f0103aa2:	c3                   	ret    
		return excnames[trapno];
f0103aa3:	8b 14 85 80 6d 10 f0 	mov    -0xfef9280(,%eax,4),%edx
f0103aaa:	e9 30 ff ff ff       	jmp    f01039df <print_trapframe+0x74>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103aaf:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103ab3:	0f 85 44 ff ff ff    	jne    f01039fd <print_trapframe+0x92>
	asm volatile("movl %%cr2,%0" : "=r" (val));
f0103ab9:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0103abc:	83 ec 08             	sub    $0x8,%esp
f0103abf:	50                   	push   %eax
f0103ac0:	68 25 6b 10 f0       	push   $0xf0106b25
f0103ac5:	e8 28 fd ff ff       	call   f01037f2 <cprintf>
f0103aca:	83 c4 10             	add    $0x10,%esp
f0103acd:	e9 2b ff ff ff       	jmp    f01039fd <print_trapframe+0x92>
		cprintf("\n");
f0103ad2:	83 ec 0c             	sub    $0xc,%esp
f0103ad5:	68 0b 69 10 f0       	push   $0xf010690b
f0103ada:	e8 13 fd ff ff       	call   f01037f2 <cprintf>
f0103adf:	83 c4 10             	add    $0x10,%esp
f0103ae2:	e9 7a ff ff ff       	jmp    f0103a61 <print_trapframe+0xf6>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0103ae7:	83 ec 08             	sub    $0x8,%esp
f0103aea:	ff 73 3c             	pushl  0x3c(%ebx)
f0103aed:	68 82 6b 10 f0       	push   $0xf0106b82
f0103af2:	e8 fb fc ff ff       	call   f01037f2 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0103af7:	83 c4 08             	add    $0x8,%esp
f0103afa:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0103afe:	50                   	push   %eax
f0103aff:	68 91 6b 10 f0       	push   $0xf0106b91
f0103b04:	e8 e9 fc ff ff       	call   f01037f2 <cprintf>
f0103b09:	83 c4 10             	add    $0x10,%esp
}
f0103b0c:	eb 8e                	jmp    f0103a9c <print_trapframe+0x131>

f0103b0e <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0103b0e:	55                   	push   %ebp
f0103b0f:	89 e5                	mov    %esp,%ebp
f0103b11:	57                   	push   %edi
f0103b12:	56                   	push   %esi
f0103b13:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0103b16:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f0103b17:	83 3d 80 1e 23 f0 00 	cmpl   $0x0,0xf0231e80
f0103b1e:	74 01                	je     f0103b21 <trap+0x13>
		asm volatile("hlt");
f0103b20:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f0103b21:	e8 7c 15 00 00       	call   f01050a2 <cpunum>
f0103b26:	6b d0 74             	imul   $0x74,%eax,%edx
f0103b29:	83 c2 04             	add    $0x4,%edx
	asm volatile("lock; xchgl %0, %1"
f0103b2c:	b8 01 00 00 00       	mov    $0x1,%eax
f0103b31:	f0 87 82 20 20 23 f0 	lock xchg %eax,-0xfdcdfe0(%edx)
f0103b38:	83 f8 02             	cmp    $0x2,%eax
f0103b3b:	0f 84 8a 00 00 00    	je     f0103bcb <trap+0xbd>
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f0103b41:	9c                   	pushf  
f0103b42:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0103b43:	f6 c4 02             	test   $0x2,%ah
f0103b46:	0f 85 94 00 00 00    	jne    f0103be0 <trap+0xd2>

	if ((tf->tf_cs & 3) == 3) {
f0103b4c:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0103b50:	83 e0 03             	and    $0x3,%eax
f0103b53:	66 83 f8 03          	cmp    $0x3,%ax
f0103b57:	0f 84 9c 00 00 00    	je     f0103bf9 <trap+0xeb>
		tf = &curenv->env_tf;
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0103b5d:	89 35 60 1a 23 f0    	mov    %esi,0xf0231a60
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f0103b63:	83 7e 28 27          	cmpl   $0x27,0x28(%esi)
f0103b67:	0f 84 31 01 00 00    	je     f0103c9e <trap+0x190>
	print_trapframe(tf);
f0103b6d:	83 ec 0c             	sub    $0xc,%esp
f0103b70:	56                   	push   %esi
f0103b71:	e8 f5 fd ff ff       	call   f010396b <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0103b76:	83 c4 10             	add    $0x10,%esp
f0103b79:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0103b7e:	0f 84 37 01 00 00    	je     f0103cbb <trap+0x1ad>
		env_destroy(curenv);
f0103b84:	e8 19 15 00 00       	call   f01050a2 <cpunum>
f0103b89:	83 ec 0c             	sub    $0xc,%esp
f0103b8c:	6b c0 74             	imul   $0x74,%eax,%eax
f0103b8f:	ff b0 28 20 23 f0    	pushl  -0xfdcdfd8(%eax)
f0103b95:	e8 9f f9 ff ff       	call   f0103539 <env_destroy>
f0103b9a:	83 c4 10             	add    $0x10,%esp
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f0103b9d:	e8 00 15 00 00       	call   f01050a2 <cpunum>
f0103ba2:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ba5:	83 b8 28 20 23 f0 00 	cmpl   $0x0,-0xfdcdfd8(%eax)
f0103bac:	74 18                	je     f0103bc6 <trap+0xb8>
f0103bae:	e8 ef 14 00 00       	call   f01050a2 <cpunum>
f0103bb3:	6b c0 74             	imul   $0x74,%eax,%eax
f0103bb6:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0103bbc:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103bc0:	0f 84 0c 01 00 00    	je     f0103cd2 <trap+0x1c4>
		env_run(curenv);
	else
		sched_yield();
f0103bc6:	e8 3e 02 00 00       	call   f0103e09 <sched_yield>
f0103bcb:	83 ec 0c             	sub    $0xc,%esp
f0103bce:	68 c0 13 12 f0       	push   $0xf01213c0
f0103bd3:	e8 3a 17 00 00       	call   f0105312 <spin_lock>
f0103bd8:	83 c4 10             	add    $0x10,%esp
f0103bdb:	e9 61 ff ff ff       	jmp    f0103b41 <trap+0x33>
	assert(!(read_eflags() & FL_IF));
f0103be0:	68 a4 6b 10 f0       	push   $0xf0106ba4
f0103be5:	68 32 66 10 f0       	push   $0xf0106632
f0103bea:	68 e7 00 00 00       	push   $0xe7
f0103bef:	68 bd 6b 10 f0       	push   $0xf0106bbd
f0103bf4:	e8 9b c4 ff ff       	call   f0100094 <_panic>
f0103bf9:	83 ec 0c             	sub    $0xc,%esp
f0103bfc:	68 c0 13 12 f0       	push   $0xf01213c0
f0103c01:	e8 0c 17 00 00       	call   f0105312 <spin_lock>
		assert(curenv);
f0103c06:	e8 97 14 00 00       	call   f01050a2 <cpunum>
f0103c0b:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c0e:	83 c4 10             	add    $0x10,%esp
f0103c11:	83 b8 28 20 23 f0 00 	cmpl   $0x0,-0xfdcdfd8(%eax)
f0103c18:	74 3e                	je     f0103c58 <trap+0x14a>
		if (curenv->env_status == ENV_DYING) {
f0103c1a:	e8 83 14 00 00       	call   f01050a2 <cpunum>
f0103c1f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c22:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0103c28:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0103c2c:	74 43                	je     f0103c71 <trap+0x163>
		curenv->env_tf = *tf;
f0103c2e:	e8 6f 14 00 00       	call   f01050a2 <cpunum>
f0103c33:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c36:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0103c3c:	b9 11 00 00 00       	mov    $0x11,%ecx
f0103c41:	89 c7                	mov    %eax,%edi
f0103c43:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		tf = &curenv->env_tf;
f0103c45:	e8 58 14 00 00       	call   f01050a2 <cpunum>
f0103c4a:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c4d:	8b b0 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%esi
f0103c53:	e9 05 ff ff ff       	jmp    f0103b5d <trap+0x4f>
		assert(curenv);
f0103c58:	68 c9 6b 10 f0       	push   $0xf0106bc9
f0103c5d:	68 32 66 10 f0       	push   $0xf0106632
f0103c62:	68 ef 00 00 00       	push   $0xef
f0103c67:	68 bd 6b 10 f0       	push   $0xf0106bbd
f0103c6c:	e8 23 c4 ff ff       	call   f0100094 <_panic>
			env_free(curenv);
f0103c71:	e8 2c 14 00 00       	call   f01050a2 <cpunum>
f0103c76:	83 ec 0c             	sub    $0xc,%esp
f0103c79:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c7c:	ff b0 28 20 23 f0    	pushl  -0xfdcdfd8(%eax)
f0103c82:	e8 d1 f6 ff ff       	call   f0103358 <env_free>
			curenv = NULL;
f0103c87:	e8 16 14 00 00       	call   f01050a2 <cpunum>
f0103c8c:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c8f:	c7 80 28 20 23 f0 00 	movl   $0x0,-0xfdcdfd8(%eax)
f0103c96:	00 00 00 
			sched_yield();
f0103c99:	e8 6b 01 00 00       	call   f0103e09 <sched_yield>
		cprintf("Spurious interrupt on irq 7\n");
f0103c9e:	83 ec 0c             	sub    $0xc,%esp
f0103ca1:	68 d0 6b 10 f0       	push   $0xf0106bd0
f0103ca6:	e8 47 fb ff ff       	call   f01037f2 <cprintf>
		print_trapframe(tf);
f0103cab:	89 34 24             	mov    %esi,(%esp)
f0103cae:	e8 b8 fc ff ff       	call   f010396b <print_trapframe>
f0103cb3:	83 c4 10             	add    $0x10,%esp
f0103cb6:	e9 e2 fe ff ff       	jmp    f0103b9d <trap+0x8f>
		panic("unhandled trap in kernel");
f0103cbb:	83 ec 04             	sub    $0x4,%esp
f0103cbe:	68 ed 6b 10 f0       	push   $0xf0106bed
f0103cc3:	68 cd 00 00 00       	push   $0xcd
f0103cc8:	68 bd 6b 10 f0       	push   $0xf0106bbd
f0103ccd:	e8 c2 c3 ff ff       	call   f0100094 <_panic>
		env_run(curenv);
f0103cd2:	e8 cb 13 00 00       	call   f01050a2 <cpunum>
f0103cd7:	83 ec 0c             	sub    $0xc,%esp
f0103cda:	6b c0 74             	imul   $0x74,%eax,%eax
f0103cdd:	ff b0 28 20 23 f0    	pushl  -0xfdcdfd8(%eax)
f0103ce3:	e8 f0 f8 ff ff       	call   f01035d8 <env_run>

f0103ce8 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0103ce8:	55                   	push   %ebp
f0103ce9:	89 e5                	mov    %esp,%ebp
f0103ceb:	57                   	push   %edi
f0103cec:	56                   	push   %esi
f0103ced:	53                   	push   %ebx
f0103cee:	83 ec 0c             	sub    $0xc,%esp
f0103cf1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	asm volatile("movl %%cr2,%0" : "=r" (val));
f0103cf4:	0f 20 d6             	mov    %cr2,%esi
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103cf7:	8b 7b 30             	mov    0x30(%ebx),%edi
		curenv->env_id, fault_va, tf->tf_eip);
f0103cfa:	e8 a3 13 00 00       	call   f01050a2 <cpunum>
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103cff:	57                   	push   %edi
f0103d00:	56                   	push   %esi
		curenv->env_id, fault_va, tf->tf_eip);
f0103d01:	6b c0 74             	imul   $0x74,%eax,%eax
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103d04:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0103d0a:	ff 70 48             	pushl  0x48(%eax)
f0103d0d:	68 4c 6d 10 f0       	push   $0xf0106d4c
f0103d12:	e8 db fa ff ff       	call   f01037f2 <cprintf>
	print_trapframe(tf);
f0103d17:	89 1c 24             	mov    %ebx,(%esp)
f0103d1a:	e8 4c fc ff ff       	call   f010396b <print_trapframe>
	env_destroy(curenv);
f0103d1f:	e8 7e 13 00 00       	call   f01050a2 <cpunum>
f0103d24:	83 c4 04             	add    $0x4,%esp
f0103d27:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d2a:	ff b0 28 20 23 f0    	pushl  -0xfdcdfd8(%eax)
f0103d30:	e8 04 f8 ff ff       	call   f0103539 <env_destroy>
}
f0103d35:	83 c4 10             	add    $0x10,%esp
f0103d38:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103d3b:	5b                   	pop    %ebx
f0103d3c:	5e                   	pop    %esi
f0103d3d:	5f                   	pop    %edi
f0103d3e:	5d                   	pop    %ebp
f0103d3f:	c3                   	ret    

f0103d40 <sched_halt>:
f0103d40:	55                   	push   %ebp
f0103d41:	89 e5                	mov    %esp,%ebp
f0103d43:	83 ec 08             	sub    $0x8,%esp
f0103d46:	a1 44 12 23 f0       	mov    0xf0231244,%eax
f0103d4b:	8d 50 54             	lea    0x54(%eax),%edx
f0103d4e:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103d53:	8b 02                	mov    (%edx),%eax
f0103d55:	83 e8 01             	sub    $0x1,%eax
f0103d58:	83 f8 02             	cmp    $0x2,%eax
f0103d5b:	76 2d                	jbe    f0103d8a <sched_halt+0x4a>
f0103d5d:	83 c1 01             	add    $0x1,%ecx
f0103d60:	83 c2 7c             	add    $0x7c,%edx
f0103d63:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f0103d69:	75 e8                	jne    f0103d53 <sched_halt+0x13>
f0103d6b:	83 ec 0c             	sub    $0xc,%esp
f0103d6e:	68 d0 6d 10 f0       	push   $0xf0106dd0
f0103d73:	e8 7a fa ff ff       	call   f01037f2 <cprintf>
f0103d78:	83 c4 10             	add    $0x10,%esp
f0103d7b:	83 ec 0c             	sub    $0xc,%esp
f0103d7e:	6a 00                	push   $0x0
f0103d80:	e8 f3 cb ff ff       	call   f0100978 <monitor>
f0103d85:	83 c4 10             	add    $0x10,%esp
f0103d88:	eb f1                	jmp    f0103d7b <sched_halt+0x3b>
f0103d8a:	e8 13 13 00 00       	call   f01050a2 <cpunum>
f0103d8f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d92:	c7 80 28 20 23 f0 00 	movl   $0x0,-0xfdcdfd8(%eax)
f0103d99:	00 00 00 
f0103d9c:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f0103da1:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103da6:	76 4f                	jbe    f0103df7 <sched_halt+0xb7>
f0103da8:	05 00 00 00 10       	add    $0x10000000,%eax
f0103dad:	0f 22 d8             	mov    %eax,%cr3
f0103db0:	e8 ed 12 00 00       	call   f01050a2 <cpunum>
f0103db5:	6b d0 74             	imul   $0x74,%eax,%edx
f0103db8:	83 c2 04             	add    $0x4,%edx
f0103dbb:	b8 02 00 00 00       	mov    $0x2,%eax
f0103dc0:	f0 87 82 20 20 23 f0 	lock xchg %eax,-0xfdcdfe0(%edx)
f0103dc7:	83 ec 0c             	sub    $0xc,%esp
f0103dca:	68 c0 13 12 f0       	push   $0xf01213c0
f0103dcf:	e8 da 15 00 00       	call   f01053ae <spin_unlock>
f0103dd4:	f3 90                	pause  
f0103dd6:	e8 c7 12 00 00       	call   f01050a2 <cpunum>
f0103ddb:	6b c0 74             	imul   $0x74,%eax,%eax
f0103dde:	8b 80 30 20 23 f0    	mov    -0xfdcdfd0(%eax),%eax
f0103de4:	bd 00 00 00 00       	mov    $0x0,%ebp
f0103de9:	89 c4                	mov    %eax,%esp
f0103deb:	6a 00                	push   $0x0
f0103ded:	6a 00                	push   $0x0
f0103def:	f4                   	hlt    
f0103df0:	eb fd                	jmp    f0103def <sched_halt+0xaf>
f0103df2:	83 c4 10             	add    $0x10,%esp
f0103df5:	c9                   	leave  
f0103df6:	c3                   	ret    
f0103df7:	50                   	push   %eax
f0103df8:	68 d8 57 10 f0       	push   $0xf01057d8
f0103dfd:	6a 4c                	push   $0x4c
f0103dff:	68 f9 6d 10 f0       	push   $0xf0106df9
f0103e04:	e8 8b c2 ff ff       	call   f0100094 <_panic>

f0103e09 <sched_yield>:
f0103e09:	55                   	push   %ebp
f0103e0a:	89 e5                	mov    %esp,%ebp
f0103e0c:	57                   	push   %edi
f0103e0d:	56                   	push   %esi
f0103e0e:	53                   	push   %ebx
f0103e0f:	83 ec 0c             	sub    $0xc,%esp
f0103e12:	e8 8b 12 00 00       	call   f01050a2 <cpunum>
f0103e17:	6b c0 74             	imul   $0x74,%eax,%eax
f0103e1a:	8b b8 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%edi
f0103e20:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103e25:	85 ff                	test   %edi,%edi
f0103e27:	74 08                	je     f0103e31 <sched_yield+0x28>
f0103e29:	8b 47 48             	mov    0x48(%edi),%eax
f0103e2c:	25 ff 03 00 00       	and    $0x3ff,%eax
f0103e31:	8b 35 44 12 23 f0    	mov    0xf0231244,%esi
f0103e37:	b9 00 04 00 00       	mov    $0x400,%ecx
f0103e3c:	bb 00 00 00 00       	mov    $0x0,%ebx
f0103e41:	8d 50 01             	lea    0x1(%eax),%edx
f0103e44:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f0103e49:	89 d0                	mov    %edx,%eax
f0103e4b:	0f 44 c3             	cmove  %ebx,%eax
f0103e4e:	6b d0 7c             	imul   $0x7c,%eax,%edx
f0103e51:	01 f2                	add    %esi,%edx
f0103e53:	83 7a 54 02          	cmpl   $0x2,0x54(%edx)
f0103e57:	74 1c                	je     f0103e75 <sched_yield+0x6c>
f0103e59:	83 e9 01             	sub    $0x1,%ecx
f0103e5c:	75 e3                	jne    f0103e41 <sched_yield+0x38>
f0103e5e:	85 ff                	test   %edi,%edi
f0103e60:	74 06                	je     f0103e68 <sched_yield+0x5f>
f0103e62:	83 7f 54 03          	cmpl   $0x3,0x54(%edi)
f0103e66:	74 16                	je     f0103e7e <sched_yield+0x75>
f0103e68:	e8 d3 fe ff ff       	call   f0103d40 <sched_halt>
f0103e6d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103e70:	5b                   	pop    %ebx
f0103e71:	5e                   	pop    %esi
f0103e72:	5f                   	pop    %edi
f0103e73:	5d                   	pop    %ebp
f0103e74:	c3                   	ret    
f0103e75:	83 ec 0c             	sub    $0xc,%esp
f0103e78:	52                   	push   %edx
f0103e79:	e8 5a f7 ff ff       	call   f01035d8 <env_run>
f0103e7e:	83 ec 0c             	sub    $0xc,%esp
f0103e81:	57                   	push   %edi
f0103e82:	e8 51 f7 ff ff       	call   f01035d8 <env_run>

f0103e87 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0103e87:	55                   	push   %ebp
f0103e88:	89 e5                	mov    %esp,%ebp
f0103e8a:	53                   	push   %ebx
f0103e8b:	83 ec 14             	sub    $0x14,%esp
f0103e8e:	8b 45 08             	mov    0x8(%ebp),%eax
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
	int32_t ret = 0;
	switch (syscallno) {
f0103e91:	83 f8 0a             	cmp    $0xa,%eax
f0103e94:	0f 87 d1 00 00 00    	ja     f0103f6b <syscall+0xe4>
f0103e9a:	ff 24 85 40 6e 10 f0 	jmp    *-0xfef91c0(,%eax,4)
	cprintf("%.*s", len, s);
f0103ea1:	83 ec 04             	sub    $0x4,%esp
f0103ea4:	ff 75 0c             	pushl  0xc(%ebp)
f0103ea7:	ff 75 10             	pushl  0x10(%ebp)
f0103eaa:	68 06 6e 10 f0       	push   $0xf0106e06
f0103eaf:	e8 3e f9 ff ff       	call   f01037f2 <cprintf>
f0103eb4:	83 c4 10             	add    $0x10,%esp
	int32_t ret = 0;
f0103eb7:	b8 00 00 00 00       	mov    $0x0,%eax
		 default:
			return -E_INVAL;

	}
	return ret;	
}
f0103ebc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103ebf:	c9                   	leave  
f0103ec0:	c3                   	ret    
	return cons_getc();
f0103ec1:	e8 a7 c7 ff ff       	call   f010066d <cons_getc>
			break;
f0103ec6:	eb f4                	jmp    f0103ebc <syscall+0x35>
	if ((r = envid2env(envid, &e, 1)) < 0)
f0103ec8:	83 ec 04             	sub    $0x4,%esp
f0103ecb:	6a 01                	push   $0x1
f0103ecd:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103ed0:	50                   	push   %eax
f0103ed1:	ff 75 0c             	pushl  0xc(%ebp)
f0103ed4:	e8 a2 f0 ff ff       	call   f0102f7b <envid2env>
f0103ed9:	83 c4 10             	add    $0x10,%esp
f0103edc:	85 c0                	test   %eax,%eax
f0103ede:	78 dc                	js     f0103ebc <syscall+0x35>
	if (e == curenv)
f0103ee0:	e8 bd 11 00 00       	call   f01050a2 <cpunum>
f0103ee5:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0103ee8:	6b c0 74             	imul   $0x74,%eax,%eax
f0103eeb:	39 90 28 20 23 f0    	cmp    %edx,-0xfdcdfd8(%eax)
f0103ef1:	74 3a                	je     f0103f2d <syscall+0xa6>
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0103ef3:	8b 5a 48             	mov    0x48(%edx),%ebx
f0103ef6:	e8 a7 11 00 00       	call   f01050a2 <cpunum>
f0103efb:	83 ec 04             	sub    $0x4,%esp
f0103efe:	53                   	push   %ebx
f0103eff:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f02:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0103f08:	ff 70 48             	pushl  0x48(%eax)
f0103f0b:	68 26 6e 10 f0       	push   $0xf0106e26
f0103f10:	e8 dd f8 ff ff       	call   f01037f2 <cprintf>
f0103f15:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f0103f18:	83 ec 0c             	sub    $0xc,%esp
f0103f1b:	ff 75 f4             	pushl  -0xc(%ebp)
f0103f1e:	e8 16 f6 ff ff       	call   f0103539 <env_destroy>
f0103f23:	83 c4 10             	add    $0x10,%esp
	return 0;
f0103f26:	b8 00 00 00 00       	mov    $0x0,%eax
			break;
f0103f2b:	eb 8f                	jmp    f0103ebc <syscall+0x35>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0103f2d:	e8 70 11 00 00       	call   f01050a2 <cpunum>
f0103f32:	83 ec 08             	sub    $0x8,%esp
f0103f35:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f38:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0103f3e:	ff 70 48             	pushl  0x48(%eax)
f0103f41:	68 0b 6e 10 f0       	push   $0xf0106e0b
f0103f46:	e8 a7 f8 ff ff       	call   f01037f2 <cprintf>
f0103f4b:	83 c4 10             	add    $0x10,%esp
f0103f4e:	eb c8                	jmp    f0103f18 <syscall+0x91>
	return curenv->env_id;
f0103f50:	e8 4d 11 00 00       	call   f01050a2 <cpunum>
f0103f55:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f58:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0103f5e:	8b 40 48             	mov    0x48(%eax),%eax
			break;
f0103f61:	e9 56 ff ff ff       	jmp    f0103ebc <syscall+0x35>
	sched_yield();
f0103f66:	e8 9e fe ff ff       	call   f0103e09 <sched_yield>
			return -E_INVAL;
f0103f6b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0103f70:	e9 47 ff ff ff       	jmp    f0103ebc <syscall+0x35>

f0103f75 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0103f75:	55                   	push   %ebp
f0103f76:	89 e5                	mov    %esp,%ebp
f0103f78:	57                   	push   %edi
f0103f79:	56                   	push   %esi
f0103f7a:	53                   	push   %ebx
f0103f7b:	83 ec 14             	sub    $0x14,%esp
f0103f7e:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103f81:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0103f84:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0103f87:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0103f8a:	8b 1a                	mov    (%edx),%ebx
f0103f8c:	8b 01                	mov    (%ecx),%eax
f0103f8e:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103f91:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0103f98:	eb 23                	jmp    f0103fbd <stab_binsearch+0x48>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0103f9a:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0103f9d:	eb 1e                	jmp    f0103fbd <stab_binsearch+0x48>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0103f9f:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103fa2:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0103fa5:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0103fa9:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0103fac:	73 41                	jae    f0103fef <stab_binsearch+0x7a>
			*region_left = m;
f0103fae:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0103fb1:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0103fb3:	8d 5f 01             	lea    0x1(%edi),%ebx
		any_matches = 1;
f0103fb6:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0103fbd:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0103fc0:	7f 5a                	jg     f010401c <stab_binsearch+0xa7>
		int true_m = (l + r) / 2, m = true_m;
f0103fc2:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103fc5:	01 d8                	add    %ebx,%eax
f0103fc7:	89 c7                	mov    %eax,%edi
f0103fc9:	c1 ef 1f             	shr    $0x1f,%edi
f0103fcc:	01 c7                	add    %eax,%edi
f0103fce:	d1 ff                	sar    %edi
f0103fd0:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0103fd3:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0103fd6:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0103fda:	89 f8                	mov    %edi,%eax
		while (m >= l && stabs[m].n_type != type)
f0103fdc:	39 c3                	cmp    %eax,%ebx
f0103fde:	7f ba                	jg     f0103f9a <stab_binsearch+0x25>
f0103fe0:	0f b6 0a             	movzbl (%edx),%ecx
f0103fe3:	83 ea 0c             	sub    $0xc,%edx
f0103fe6:	39 f1                	cmp    %esi,%ecx
f0103fe8:	74 b5                	je     f0103f9f <stab_binsearch+0x2a>
			m--;
f0103fea:	83 e8 01             	sub    $0x1,%eax
f0103fed:	eb ed                	jmp    f0103fdc <stab_binsearch+0x67>
		} else if (stabs[m].n_value > addr) {
f0103fef:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0103ff2:	76 14                	jbe    f0104008 <stab_binsearch+0x93>
			*region_right = m - 1;
f0103ff4:	83 e8 01             	sub    $0x1,%eax
f0103ff7:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103ffa:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0103ffd:	89 07                	mov    %eax,(%edi)
		any_matches = 1;
f0103fff:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104006:	eb b5                	jmp    f0103fbd <stab_binsearch+0x48>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0104008:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010400b:	89 07                	mov    %eax,(%edi)
			l = m;
			addr++;
f010400d:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0104011:	89 c3                	mov    %eax,%ebx
		any_matches = 1;
f0104013:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f010401a:	eb a1                	jmp    f0103fbd <stab_binsearch+0x48>
		}
	}

	if (!any_matches)
f010401c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0104020:	75 15                	jne    f0104037 <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f0104022:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104025:	8b 00                	mov    (%eax),%eax
f0104027:	83 e8 01             	sub    $0x1,%eax
f010402a:	8b 75 e0             	mov    -0x20(%ebp),%esi
f010402d:	89 06                	mov    %eax,(%esi)
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f010402f:	83 c4 14             	add    $0x14,%esp
f0104032:	5b                   	pop    %ebx
f0104033:	5e                   	pop    %esi
f0104034:	5f                   	pop    %edi
f0104035:	5d                   	pop    %ebp
f0104036:	c3                   	ret    
		for (l = *region_right;
f0104037:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010403a:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f010403c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010403f:	8b 0f                	mov    (%edi),%ecx
f0104041:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104044:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0104047:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
		for (l = *region_right;
f010404b:	eb 03                	jmp    f0104050 <stab_binsearch+0xdb>
		     l--)
f010404d:	83 e8 01             	sub    $0x1,%eax
		for (l = *region_right;
f0104050:	39 c1                	cmp    %eax,%ecx
f0104052:	7d 0a                	jge    f010405e <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f0104054:	0f b6 1a             	movzbl (%edx),%ebx
f0104057:	83 ea 0c             	sub    $0xc,%edx
f010405a:	39 f3                	cmp    %esi,%ebx
f010405c:	75 ef                	jne    f010404d <stab_binsearch+0xd8>
		*region_left = l;
f010405e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104061:	89 06                	mov    %eax,(%esi)
}
f0104063:	eb ca                	jmp    f010402f <stab_binsearch+0xba>

f0104065 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0104065:	55                   	push   %ebp
f0104066:	89 e5                	mov    %esp,%ebp
f0104068:	57                   	push   %edi
f0104069:	56                   	push   %esi
f010406a:	53                   	push   %ebx
f010406b:	83 ec 4c             	sub    $0x4c,%esp
f010406e:	8b 75 08             	mov    0x8(%ebp),%esi
f0104071:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0104074:	c7 03 6c 6e 10 f0    	movl   $0xf0106e6c,(%ebx)
	info->eip_line = 0;
f010407a:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0104081:	c7 43 08 6c 6e 10 f0 	movl   $0xf0106e6c,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0104088:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f010408f:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0104092:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0104099:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f010409f:	0f 87 1d 01 00 00    	ja     f01041c2 <debuginfo_eip+0x15d>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f01040a5:	a1 00 00 20 00       	mov    0x200000,%eax
f01040aa:	89 45 b8             	mov    %eax,-0x48(%ebp)
		stab_end = usd->stab_end;
f01040ad:	a1 04 00 20 00       	mov    0x200004,%eax
		stabstr = usd->stabstr;
f01040b2:	8b 3d 08 00 20 00    	mov    0x200008,%edi
f01040b8:	89 7d b4             	mov    %edi,-0x4c(%ebp)
		stabstr_end = usd->stabstr_end;
f01040bb:	8b 3d 0c 00 20 00    	mov    0x20000c,%edi
f01040c1:	89 7d bc             	mov    %edi,-0x44(%ebp)
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01040c4:	8b 7d bc             	mov    -0x44(%ebp),%edi
f01040c7:	39 7d b4             	cmp    %edi,-0x4c(%ebp)
f01040ca:	0f 83 bb 01 00 00    	jae    f010428b <debuginfo_eip+0x226>
f01040d0:	80 7f ff 00          	cmpb   $0x0,-0x1(%edi)
f01040d4:	0f 85 b8 01 00 00    	jne    f0104292 <debuginfo_eip+0x22d>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f01040da:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f01040e1:	8b 7d b8             	mov    -0x48(%ebp),%edi
f01040e4:	29 f8                	sub    %edi,%eax
f01040e6:	c1 f8 02             	sar    $0x2,%eax
f01040e9:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f01040ef:	83 e8 01             	sub    $0x1,%eax
f01040f2:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f01040f5:	56                   	push   %esi
f01040f6:	6a 64                	push   $0x64
f01040f8:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01040fb:	89 c1                	mov    %eax,%ecx
f01040fd:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104100:	89 f8                	mov    %edi,%eax
f0104102:	e8 6e fe ff ff       	call   f0103f75 <stab_binsearch>
	if (lfile == 0)
f0104107:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010410a:	83 c4 08             	add    $0x8,%esp
f010410d:	85 c0                	test   %eax,%eax
f010410f:	0f 84 84 01 00 00    	je     f0104299 <debuginfo_eip+0x234>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0104115:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0104118:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010411b:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f010411e:	56                   	push   %esi
f010411f:	6a 24                	push   $0x24
f0104121:	8d 45 d8             	lea    -0x28(%ebp),%eax
f0104124:	89 c1                	mov    %eax,%ecx
f0104126:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0104129:	89 f8                	mov    %edi,%eax
f010412b:	e8 45 fe ff ff       	call   f0103f75 <stab_binsearch>

	if (lfun <= rfun) {
f0104130:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104133:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0104136:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
f0104139:	83 c4 08             	add    $0x8,%esp
f010413c:	39 c8                	cmp    %ecx,%eax
f010413e:	0f 8f 9d 00 00 00    	jg     f01041e1 <debuginfo_eip+0x17c>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0104144:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104147:	8d 0c 97             	lea    (%edi,%edx,4),%ecx
f010414a:	8b 11                	mov    (%ecx),%edx
f010414c:	8b 7d bc             	mov    -0x44(%ebp),%edi
f010414f:	2b 7d b4             	sub    -0x4c(%ebp),%edi
f0104152:	39 fa                	cmp    %edi,%edx
f0104154:	73 06                	jae    f010415c <debuginfo_eip+0xf7>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0104156:	03 55 b4             	add    -0x4c(%ebp),%edx
f0104159:	89 53 08             	mov    %edx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f010415c:	8b 51 08             	mov    0x8(%ecx),%edx
f010415f:	89 53 10             	mov    %edx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0104162:	29 d6                	sub    %edx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0104164:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0104167:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f010416a:	89 45 d0             	mov    %eax,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f010416d:	83 ec 08             	sub    $0x8,%esp
f0104170:	6a 3a                	push   $0x3a
f0104172:	ff 73 08             	pushl  0x8(%ebx)
f0104175:	e8 0e 09 00 00       	call   f0104a88 <strfind>
f010417a:	2b 43 08             	sub    0x8(%ebx),%eax
f010417d:	89 43 0c             	mov    %eax,0xc(%ebx)
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0104180:	83 c4 08             	add    $0x8,%esp
f0104183:	56                   	push   %esi
f0104184:	6a 44                	push   $0x44
f0104186:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0104189:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f010418c:	8b 75 b8             	mov    -0x48(%ebp),%esi
f010418f:	89 f0                	mov    %esi,%eax
f0104191:	e8 df fd ff ff       	call   f0103f75 <stab_binsearch>
	if (lline <= rline) {
f0104196:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0104199:	83 c4 10             	add    $0x10,%esp
f010419c:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f010419f:	0f 8f fb 00 00 00    	jg     f01042a0 <debuginfo_eip+0x23b>
		 info->eip_line = stabs[lline].n_desc;
f01041a5:	89 d0                	mov    %edx,%eax
f01041a7:	8d 14 52             	lea    (%edx,%edx,2),%edx
f01041aa:	c1 e2 02             	shl    $0x2,%edx
f01041ad:	0f b7 4c 16 06       	movzwl 0x6(%esi,%edx,1),%ecx
f01041b2:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01041b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01041b8:	8d 54 16 04          	lea    0x4(%esi,%edx,1),%edx
f01041bc:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f01041c0:	eb 3d                	jmp    f01041ff <debuginfo_eip+0x19a>
		stabstr_end = __STABSTR_END__;
f01041c2:	c7 45 bc ed 66 11 f0 	movl   $0xf01166ed,-0x44(%ebp)
		stabstr = __STABSTR_BEGIN__;
f01041c9:	c7 45 b4 ad 2f 11 f0 	movl   $0xf0112fad,-0x4c(%ebp)
		stab_end = __STAB_END__;
f01041d0:	b8 ac 2f 11 f0       	mov    $0xf0112fac,%eax
		stabs = __STAB_BEGIN__;
f01041d5:	c7 45 b8 54 73 10 f0 	movl   $0xf0107354,-0x48(%ebp)
f01041dc:	e9 e3 fe ff ff       	jmp    f01040c4 <debuginfo_eip+0x5f>
		info->eip_fn_addr = addr;
f01041e1:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f01041e4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01041e7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f01041ea:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01041ed:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01041f0:	e9 78 ff ff ff       	jmp    f010416d <debuginfo_eip+0x108>
f01041f5:	83 e8 01             	sub    $0x1,%eax
f01041f8:	83 ea 0c             	sub    $0xc,%edx
f01041fb:	c6 45 c4 01          	movb   $0x1,-0x3c(%ebp)
f01041ff:	89 45 c0             	mov    %eax,-0x40(%ebp)
	while (lline >= lfile
f0104202:	39 c7                	cmp    %eax,%edi
f0104204:	7f 45                	jg     f010424b <debuginfo_eip+0x1e6>
	       && stabs[lline].n_type != N_SOL
f0104206:	0f b6 0a             	movzbl (%edx),%ecx
f0104209:	80 f9 84             	cmp    $0x84,%cl
f010420c:	74 19                	je     f0104227 <debuginfo_eip+0x1c2>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f010420e:	80 f9 64             	cmp    $0x64,%cl
f0104211:	75 e2                	jne    f01041f5 <debuginfo_eip+0x190>
f0104213:	83 7a 04 00          	cmpl   $0x0,0x4(%edx)
f0104217:	74 dc                	je     f01041f5 <debuginfo_eip+0x190>
f0104219:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f010421d:	74 11                	je     f0104230 <debuginfo_eip+0x1cb>
f010421f:	8b 75 c0             	mov    -0x40(%ebp),%esi
f0104222:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0104225:	eb 09                	jmp    f0104230 <debuginfo_eip+0x1cb>
f0104227:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f010422b:	74 03                	je     f0104230 <debuginfo_eip+0x1cb>
f010422d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0104230:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0104233:	8b 7d b8             	mov    -0x48(%ebp),%edi
f0104236:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0104239:	8b 45 bc             	mov    -0x44(%ebp),%eax
f010423c:	8b 7d b4             	mov    -0x4c(%ebp),%edi
f010423f:	29 f8                	sub    %edi,%eax
f0104241:	39 c2                	cmp    %eax,%edx
f0104243:	73 06                	jae    f010424b <debuginfo_eip+0x1e6>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0104245:	89 f8                	mov    %edi,%eax
f0104247:	01 d0                	add    %edx,%eax
f0104249:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f010424b:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010424e:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104251:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f0104256:	39 f2                	cmp    %esi,%edx
f0104258:	7d 52                	jge    f01042ac <debuginfo_eip+0x247>
		for (lline = lfun + 1;
f010425a:	83 c2 01             	add    $0x1,%edx
f010425d:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0104260:	89 d0                	mov    %edx,%eax
f0104262:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0104265:	8b 7d b8             	mov    -0x48(%ebp),%edi
f0104268:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
f010426c:	eb 04                	jmp    f0104272 <debuginfo_eip+0x20d>
			info->eip_fn_narg++;
f010426e:	83 43 14 01          	addl   $0x1,0x14(%ebx)
		for (lline = lfun + 1;
f0104272:	39 c6                	cmp    %eax,%esi
f0104274:	7e 31                	jle    f01042a7 <debuginfo_eip+0x242>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0104276:	0f b6 0a             	movzbl (%edx),%ecx
f0104279:	83 c0 01             	add    $0x1,%eax
f010427c:	83 c2 0c             	add    $0xc,%edx
f010427f:	80 f9 a0             	cmp    $0xa0,%cl
f0104282:	74 ea                	je     f010426e <debuginfo_eip+0x209>
	return 0;
f0104284:	b8 00 00 00 00       	mov    $0x0,%eax
f0104289:	eb 21                	jmp    f01042ac <debuginfo_eip+0x247>
		return -1;
f010428b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104290:	eb 1a                	jmp    f01042ac <debuginfo_eip+0x247>
f0104292:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104297:	eb 13                	jmp    f01042ac <debuginfo_eip+0x247>
		return -1;
f0104299:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010429e:	eb 0c                	jmp    f01042ac <debuginfo_eip+0x247>
		 return -1;
f01042a0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01042a5:	eb 05                	jmp    f01042ac <debuginfo_eip+0x247>
	return 0;
f01042a7:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01042ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01042af:	5b                   	pop    %ebx
f01042b0:	5e                   	pop    %esi
f01042b1:	5f                   	pop    %edi
f01042b2:	5d                   	pop    %ebp
f01042b3:	c3                   	ret    

f01042b4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f01042b4:	55                   	push   %ebp
f01042b5:	89 e5                	mov    %esp,%ebp
f01042b7:	57                   	push   %edi
f01042b8:	56                   	push   %esi
f01042b9:	53                   	push   %ebx
f01042ba:	83 ec 1c             	sub    $0x1c,%esp
f01042bd:	89 c7                	mov    %eax,%edi
f01042bf:	89 d6                	mov    %edx,%esi
f01042c1:	8b 45 08             	mov    0x8(%ebp),%eax
f01042c4:	8b 55 0c             	mov    0xc(%ebp),%edx
f01042c7:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01042ca:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f01042cd:	8b 4d 10             	mov    0x10(%ebp),%ecx
f01042d0:	bb 00 00 00 00       	mov    $0x0,%ebx
f01042d5:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01042d8:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f01042db:	3b 45 10             	cmp    0x10(%ebp),%eax
f01042de:	89 d0                	mov    %edx,%eax
f01042e0:	1b 45 e4             	sbb    -0x1c(%ebp),%eax
f01042e3:	8b 5d 14             	mov    0x14(%ebp),%ebx
f01042e6:	73 15                	jae    f01042fd <printnum+0x49>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f01042e8:	83 eb 01             	sub    $0x1,%ebx
f01042eb:	85 db                	test   %ebx,%ebx
f01042ed:	7e 43                	jle    f0104332 <printnum+0x7e>
			putch(padc, putdat);
f01042ef:	83 ec 08             	sub    $0x8,%esp
f01042f2:	56                   	push   %esi
f01042f3:	ff 75 18             	pushl  0x18(%ebp)
f01042f6:	ff d7                	call   *%edi
f01042f8:	83 c4 10             	add    $0x10,%esp
f01042fb:	eb eb                	jmp    f01042e8 <printnum+0x34>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f01042fd:	83 ec 0c             	sub    $0xc,%esp
f0104300:	ff 75 18             	pushl  0x18(%ebp)
f0104303:	8b 45 14             	mov    0x14(%ebp),%eax
f0104306:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0104309:	53                   	push   %ebx
f010430a:	ff 75 10             	pushl  0x10(%ebp)
f010430d:	83 ec 08             	sub    $0x8,%esp
f0104310:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104313:	ff 75 e0             	pushl  -0x20(%ebp)
f0104316:	ff 75 dc             	pushl  -0x24(%ebp)
f0104319:	ff 75 d8             	pushl  -0x28(%ebp)
f010431c:	e8 7f 11 00 00       	call   f01054a0 <__udivdi3>
f0104321:	83 c4 18             	add    $0x18,%esp
f0104324:	52                   	push   %edx
f0104325:	50                   	push   %eax
f0104326:	89 f2                	mov    %esi,%edx
f0104328:	89 f8                	mov    %edi,%eax
f010432a:	e8 85 ff ff ff       	call   f01042b4 <printnum>
f010432f:	83 c4 20             	add    $0x20,%esp
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0104332:	83 ec 08             	sub    $0x8,%esp
f0104335:	56                   	push   %esi
f0104336:	83 ec 04             	sub    $0x4,%esp
f0104339:	ff 75 e4             	pushl  -0x1c(%ebp)
f010433c:	ff 75 e0             	pushl  -0x20(%ebp)
f010433f:	ff 75 dc             	pushl  -0x24(%ebp)
f0104342:	ff 75 d8             	pushl  -0x28(%ebp)
f0104345:	e8 66 12 00 00       	call   f01055b0 <__umoddi3>
f010434a:	83 c4 14             	add    $0x14,%esp
f010434d:	0f be 80 76 6e 10 f0 	movsbl -0xfef918a(%eax),%eax
f0104354:	50                   	push   %eax
f0104355:	ff d7                	call   *%edi
}
f0104357:	83 c4 10             	add    $0x10,%esp
f010435a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010435d:	5b                   	pop    %ebx
f010435e:	5e                   	pop    %esi
f010435f:	5f                   	pop    %edi
f0104360:	5d                   	pop    %ebp
f0104361:	c3                   	ret    

f0104362 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0104362:	55                   	push   %ebp
f0104363:	89 e5                	mov    %esp,%ebp
f0104365:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0104368:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f010436c:	8b 10                	mov    (%eax),%edx
f010436e:	3b 50 04             	cmp    0x4(%eax),%edx
f0104371:	73 0a                	jae    f010437d <sprintputch+0x1b>
		*b->buf++ = ch;
f0104373:	8d 4a 01             	lea    0x1(%edx),%ecx
f0104376:	89 08                	mov    %ecx,(%eax)
f0104378:	8b 45 08             	mov    0x8(%ebp),%eax
f010437b:	88 02                	mov    %al,(%edx)
}
f010437d:	5d                   	pop    %ebp
f010437e:	c3                   	ret    

f010437f <printfmt>:
{
f010437f:	55                   	push   %ebp
f0104380:	89 e5                	mov    %esp,%ebp
f0104382:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f0104385:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0104388:	50                   	push   %eax
f0104389:	ff 75 10             	pushl  0x10(%ebp)
f010438c:	ff 75 0c             	pushl  0xc(%ebp)
f010438f:	ff 75 08             	pushl  0x8(%ebp)
f0104392:	e8 05 00 00 00       	call   f010439c <vprintfmt>
}
f0104397:	83 c4 10             	add    $0x10,%esp
f010439a:	c9                   	leave  
f010439b:	c3                   	ret    

f010439c <vprintfmt>:
{
f010439c:	55                   	push   %ebp
f010439d:	89 e5                	mov    %esp,%ebp
f010439f:	57                   	push   %edi
f01043a0:	56                   	push   %esi
f01043a1:	53                   	push   %ebx
f01043a2:	83 ec 3c             	sub    $0x3c,%esp
f01043a5:	8b 75 08             	mov    0x8(%ebp),%esi
f01043a8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01043ab:	8b 7d 10             	mov    0x10(%ebp),%edi
f01043ae:	eb 0a                	jmp    f01043ba <vprintfmt+0x1e>
			putch(ch, putdat);
f01043b0:	83 ec 08             	sub    $0x8,%esp
f01043b3:	53                   	push   %ebx
f01043b4:	50                   	push   %eax
f01043b5:	ff d6                	call   *%esi
f01043b7:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01043ba:	83 c7 01             	add    $0x1,%edi
f01043bd:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f01043c1:	83 f8 25             	cmp    $0x25,%eax
f01043c4:	74 0c                	je     f01043d2 <vprintfmt+0x36>
			if (ch == '\0')
f01043c6:	85 c0                	test   %eax,%eax
f01043c8:	75 e6                	jne    f01043b0 <vprintfmt+0x14>
}
f01043ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01043cd:	5b                   	pop    %ebx
f01043ce:	5e                   	pop    %esi
f01043cf:	5f                   	pop    %edi
f01043d0:	5d                   	pop    %ebp
f01043d1:	c3                   	ret    
		padc = ' ';
f01043d2:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
f01043d6:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;//精度
f01043dd:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;//总宽度
f01043e4:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f01043eb:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f01043f0:	8d 47 01             	lea    0x1(%edi),%eax
f01043f3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01043f6:	0f b6 17             	movzbl (%edi),%edx
f01043f9:	8d 42 dd             	lea    -0x23(%edx),%eax
f01043fc:	3c 55                	cmp    $0x55,%al
f01043fe:	0f 87 ba 03 00 00    	ja     f01047be <vprintfmt+0x422>
f0104404:	0f b6 c0             	movzbl %al,%eax
f0104407:	ff 24 85 40 6f 10 f0 	jmp    *-0xfef90c0(,%eax,4)
f010440e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
f0104411:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
f0104415:	eb d9                	jmp    f01043f0 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
f0104417:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
f010441a:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
f010441e:	eb d0                	jmp    f01043f0 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
f0104420:	0f b6 d2             	movzbl %dl,%edx
f0104423:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {//依次读取数据宽度
f0104426:	b8 00 00 00 00       	mov    $0x0,%eax
f010442b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
f010442e:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0104431:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f0104435:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f0104438:	8d 4a d0             	lea    -0x30(%edx),%ecx
f010443b:	83 f9 09             	cmp    $0x9,%ecx
f010443e:	77 55                	ja     f0104495 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {//依次读取数据宽度
f0104440:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
f0104443:	eb e9                	jmp    f010442e <vprintfmt+0x92>
			precision = va_arg(ap, int);
f0104445:	8b 45 14             	mov    0x14(%ebp),%eax
f0104448:	8b 00                	mov    (%eax),%eax
f010444a:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010444d:	8b 45 14             	mov    0x14(%ebp),%eax
f0104450:	8d 40 04             	lea    0x4(%eax),%eax
f0104453:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0104456:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
f0104459:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f010445d:	79 91                	jns    f01043f0 <vprintfmt+0x54>
				width = precision, precision = -1;
f010445f:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0104462:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104465:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
f010446c:	eb 82                	jmp    f01043f0 <vprintfmt+0x54>
f010446e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104471:	85 c0                	test   %eax,%eax
f0104473:	ba 00 00 00 00       	mov    $0x0,%edx
f0104478:	0f 49 d0             	cmovns %eax,%edx
f010447b:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f010447e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104481:	e9 6a ff ff ff       	jmp    f01043f0 <vprintfmt+0x54>
f0104486:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
f0104489:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
f0104490:	e9 5b ff ff ff       	jmp    f01043f0 <vprintfmt+0x54>
f0104495:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0104498:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010449b:	eb bc                	jmp    f0104459 <vprintfmt+0xbd>
			lflag++;
f010449d:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f01044a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f01044a3:	e9 48 ff ff ff       	jmp    f01043f0 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
f01044a8:	8b 45 14             	mov    0x14(%ebp),%eax
f01044ab:	8d 78 04             	lea    0x4(%eax),%edi
f01044ae:	83 ec 08             	sub    $0x8,%esp
f01044b1:	53                   	push   %ebx
f01044b2:	ff 30                	pushl  (%eax)
f01044b4:	ff d6                	call   *%esi
			break;
f01044b6:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f01044b9:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
f01044bc:	e9 9c 02 00 00       	jmp    f010475d <vprintfmt+0x3c1>
			err = va_arg(ap, int);
f01044c1:	8b 45 14             	mov    0x14(%ebp),%eax
f01044c4:	8d 78 04             	lea    0x4(%eax),%edi
f01044c7:	8b 00                	mov    (%eax),%eax
f01044c9:	99                   	cltd   
f01044ca:	31 d0                	xor    %edx,%eax
f01044cc:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01044ce:	83 f8 08             	cmp    $0x8,%eax
f01044d1:	7f 23                	jg     f01044f6 <vprintfmt+0x15a>
f01044d3:	8b 14 85 a0 70 10 f0 	mov    -0xfef8f60(,%eax,4),%edx
f01044da:	85 d2                	test   %edx,%edx
f01044dc:	74 18                	je     f01044f6 <vprintfmt+0x15a>
				printfmt(putch, putdat, "%s", p);
f01044de:	52                   	push   %edx
f01044df:	68 44 66 10 f0       	push   $0xf0106644
f01044e4:	53                   	push   %ebx
f01044e5:	56                   	push   %esi
f01044e6:	e8 94 fe ff ff       	call   f010437f <printfmt>
f01044eb:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f01044ee:	89 7d 14             	mov    %edi,0x14(%ebp)
f01044f1:	e9 67 02 00 00       	jmp    f010475d <vprintfmt+0x3c1>
				printfmt(putch, putdat, "error %d", err);
f01044f6:	50                   	push   %eax
f01044f7:	68 8e 6e 10 f0       	push   $0xf0106e8e
f01044fc:	53                   	push   %ebx
f01044fd:	56                   	push   %esi
f01044fe:	e8 7c fe ff ff       	call   f010437f <printfmt>
f0104503:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0104506:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f0104509:	e9 4f 02 00 00       	jmp    f010475d <vprintfmt+0x3c1>
			if ((p = va_arg(ap, char *)) == NULL)
f010450e:	8b 45 14             	mov    0x14(%ebp),%eax
f0104511:	83 c0 04             	add    $0x4,%eax
f0104514:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0104517:	8b 45 14             	mov    0x14(%ebp),%eax
f010451a:	8b 10                	mov    (%eax),%edx
				p = "(null)";
f010451c:	85 d2                	test   %edx,%edx
f010451e:	b8 87 6e 10 f0       	mov    $0xf0106e87,%eax
f0104523:	0f 45 c2             	cmovne %edx,%eax
f0104526:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
f0104529:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f010452d:	7e 06                	jle    f0104535 <vprintfmt+0x199>
f010452f:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
f0104533:	75 0d                	jne    f0104542 <vprintfmt+0x1a6>
				for (width -= strnlen(p, precision); width > 0; width--)
f0104535:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0104538:	89 c7                	mov    %eax,%edi
f010453a:	03 45 e0             	add    -0x20(%ebp),%eax
f010453d:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104540:	eb 3f                	jmp    f0104581 <vprintfmt+0x1e5>
f0104542:	83 ec 08             	sub    $0x8,%esp
f0104545:	ff 75 d8             	pushl  -0x28(%ebp)
f0104548:	50                   	push   %eax
f0104549:	e8 ef 03 00 00       	call   f010493d <strnlen>
f010454e:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104551:	29 c2                	sub    %eax,%edx
f0104553:	89 55 c4             	mov    %edx,-0x3c(%ebp)
f0104556:	83 c4 10             	add    $0x10,%esp
f0104559:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
f010455b:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
f010455f:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f0104562:	85 ff                	test   %edi,%edi
f0104564:	7e 58                	jle    f01045be <vprintfmt+0x222>
					putch(padc, putdat);
f0104566:	83 ec 08             	sub    $0x8,%esp
f0104569:	53                   	push   %ebx
f010456a:	ff 75 e0             	pushl  -0x20(%ebp)
f010456d:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f010456f:	83 ef 01             	sub    $0x1,%edi
f0104572:	83 c4 10             	add    $0x10,%esp
f0104575:	eb eb                	jmp    f0104562 <vprintfmt+0x1c6>
					putch(ch, putdat);
f0104577:	83 ec 08             	sub    $0x8,%esp
f010457a:	53                   	push   %ebx
f010457b:	52                   	push   %edx
f010457c:	ff d6                	call   *%esi
f010457e:	83 c4 10             	add    $0x10,%esp
f0104581:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0104584:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0104586:	83 c7 01             	add    $0x1,%edi
f0104589:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f010458d:	0f be d0             	movsbl %al,%edx
f0104590:	85 d2                	test   %edx,%edx
f0104592:	74 45                	je     f01045d9 <vprintfmt+0x23d>
f0104594:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0104598:	78 06                	js     f01045a0 <vprintfmt+0x204>
f010459a:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
f010459e:	78 35                	js     f01045d5 <vprintfmt+0x239>
				if (altflag && (ch < ' ' || ch > '~'))
f01045a0:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f01045a4:	74 d1                	je     f0104577 <vprintfmt+0x1db>
f01045a6:	0f be c0             	movsbl %al,%eax
f01045a9:	83 e8 20             	sub    $0x20,%eax
f01045ac:	83 f8 5e             	cmp    $0x5e,%eax
f01045af:	76 c6                	jbe    f0104577 <vprintfmt+0x1db>
					putch('?', putdat);
f01045b1:	83 ec 08             	sub    $0x8,%esp
f01045b4:	53                   	push   %ebx
f01045b5:	6a 3f                	push   $0x3f
f01045b7:	ff d6                	call   *%esi
f01045b9:	83 c4 10             	add    $0x10,%esp
f01045bc:	eb c3                	jmp    f0104581 <vprintfmt+0x1e5>
f01045be:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f01045c1:	85 d2                	test   %edx,%edx
f01045c3:	b8 00 00 00 00       	mov    $0x0,%eax
f01045c8:	0f 49 c2             	cmovns %edx,%eax
f01045cb:	29 c2                	sub    %eax,%edx
f01045cd:	89 55 e0             	mov    %edx,-0x20(%ebp)
f01045d0:	e9 60 ff ff ff       	jmp    f0104535 <vprintfmt+0x199>
f01045d5:	89 cf                	mov    %ecx,%edi
f01045d7:	eb 02                	jmp    f01045db <vprintfmt+0x23f>
f01045d9:	89 cf                	mov    %ecx,%edi
			for (; width > 0; width--)
f01045db:	85 ff                	test   %edi,%edi
f01045dd:	7e 10                	jle    f01045ef <vprintfmt+0x253>
				putch(' ', putdat);
f01045df:	83 ec 08             	sub    $0x8,%esp
f01045e2:	53                   	push   %ebx
f01045e3:	6a 20                	push   $0x20
f01045e5:	ff d6                	call   *%esi
			for (; width > 0; width--)
f01045e7:	83 ef 01             	sub    $0x1,%edi
f01045ea:	83 c4 10             	add    $0x10,%esp
f01045ed:	eb ec                	jmp    f01045db <vprintfmt+0x23f>
			if ((p = va_arg(ap, char *)) == NULL)
f01045ef:	8b 45 c8             	mov    -0x38(%ebp),%eax
f01045f2:	89 45 14             	mov    %eax,0x14(%ebp)
f01045f5:	e9 63 01 00 00       	jmp    f010475d <vprintfmt+0x3c1>
	if (lflag >= 2)
f01045fa:	83 f9 01             	cmp    $0x1,%ecx
f01045fd:	7f 1b                	jg     f010461a <vprintfmt+0x27e>
	else if (lflag)
f01045ff:	85 c9                	test   %ecx,%ecx
f0104601:	74 63                	je     f0104666 <vprintfmt+0x2ca>
		return va_arg(*ap, long);
f0104603:	8b 45 14             	mov    0x14(%ebp),%eax
f0104606:	8b 00                	mov    (%eax),%eax
f0104608:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010460b:	99                   	cltd   
f010460c:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010460f:	8b 45 14             	mov    0x14(%ebp),%eax
f0104612:	8d 40 04             	lea    0x4(%eax),%eax
f0104615:	89 45 14             	mov    %eax,0x14(%ebp)
f0104618:	eb 17                	jmp    f0104631 <vprintfmt+0x295>
		return va_arg(*ap, long long);
f010461a:	8b 45 14             	mov    0x14(%ebp),%eax
f010461d:	8b 50 04             	mov    0x4(%eax),%edx
f0104620:	8b 00                	mov    (%eax),%eax
f0104622:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104625:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0104628:	8b 45 14             	mov    0x14(%ebp),%eax
f010462b:	8d 40 08             	lea    0x8(%eax),%eax
f010462e:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f0104631:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104634:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f0104637:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
f010463c:	85 c9                	test   %ecx,%ecx
f010463e:	0f 89 ff 00 00 00    	jns    f0104743 <vprintfmt+0x3a7>
				putch('-', putdat);
f0104644:	83 ec 08             	sub    $0x8,%esp
f0104647:	53                   	push   %ebx
f0104648:	6a 2d                	push   $0x2d
f010464a:	ff d6                	call   *%esi
				num = -(long long) num;
f010464c:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010464f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0104652:	f7 da                	neg    %edx
f0104654:	83 d1 00             	adc    $0x0,%ecx
f0104657:	f7 d9                	neg    %ecx
f0104659:	83 c4 10             	add    $0x10,%esp
			base = 10;
f010465c:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104661:	e9 dd 00 00 00       	jmp    f0104743 <vprintfmt+0x3a7>
		return va_arg(*ap, int);
f0104666:	8b 45 14             	mov    0x14(%ebp),%eax
f0104669:	8b 00                	mov    (%eax),%eax
f010466b:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010466e:	99                   	cltd   
f010466f:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0104672:	8b 45 14             	mov    0x14(%ebp),%eax
f0104675:	8d 40 04             	lea    0x4(%eax),%eax
f0104678:	89 45 14             	mov    %eax,0x14(%ebp)
f010467b:	eb b4                	jmp    f0104631 <vprintfmt+0x295>
	if (lflag >= 2)
f010467d:	83 f9 01             	cmp    $0x1,%ecx
f0104680:	7f 1e                	jg     f01046a0 <vprintfmt+0x304>
	else if (lflag)
f0104682:	85 c9                	test   %ecx,%ecx
f0104684:	74 32                	je     f01046b8 <vprintfmt+0x31c>
		return va_arg(*ap, unsigned long);
f0104686:	8b 45 14             	mov    0x14(%ebp),%eax
f0104689:	8b 10                	mov    (%eax),%edx
f010468b:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104690:	8d 40 04             	lea    0x4(%eax),%eax
f0104693:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0104696:	b8 0a 00 00 00       	mov    $0xa,%eax
f010469b:	e9 a3 00 00 00       	jmp    f0104743 <vprintfmt+0x3a7>
		return va_arg(*ap, unsigned long long);
f01046a0:	8b 45 14             	mov    0x14(%ebp),%eax
f01046a3:	8b 10                	mov    (%eax),%edx
f01046a5:	8b 48 04             	mov    0x4(%eax),%ecx
f01046a8:	8d 40 08             	lea    0x8(%eax),%eax
f01046ab:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01046ae:	b8 0a 00 00 00       	mov    $0xa,%eax
f01046b3:	e9 8b 00 00 00       	jmp    f0104743 <vprintfmt+0x3a7>
		return va_arg(*ap, unsigned int);
f01046b8:	8b 45 14             	mov    0x14(%ebp),%eax
f01046bb:	8b 10                	mov    (%eax),%edx
f01046bd:	b9 00 00 00 00       	mov    $0x0,%ecx
f01046c2:	8d 40 04             	lea    0x4(%eax),%eax
f01046c5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01046c8:	b8 0a 00 00 00       	mov    $0xa,%eax
f01046cd:	eb 74                	jmp    f0104743 <vprintfmt+0x3a7>
	if (lflag >= 2)
f01046cf:	83 f9 01             	cmp    $0x1,%ecx
f01046d2:	7f 1b                	jg     f01046ef <vprintfmt+0x353>
	else if (lflag)
f01046d4:	85 c9                	test   %ecx,%ecx
f01046d6:	74 2c                	je     f0104704 <vprintfmt+0x368>
		return va_arg(*ap, unsigned long);
f01046d8:	8b 45 14             	mov    0x14(%ebp),%eax
f01046db:	8b 10                	mov    (%eax),%edx
f01046dd:	b9 00 00 00 00       	mov    $0x0,%ecx
f01046e2:	8d 40 04             	lea    0x4(%eax),%eax
f01046e5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f01046e8:	b8 08 00 00 00       	mov    $0x8,%eax
f01046ed:	eb 54                	jmp    f0104743 <vprintfmt+0x3a7>
		return va_arg(*ap, unsigned long long);
f01046ef:	8b 45 14             	mov    0x14(%ebp),%eax
f01046f2:	8b 10                	mov    (%eax),%edx
f01046f4:	8b 48 04             	mov    0x4(%eax),%ecx
f01046f7:	8d 40 08             	lea    0x8(%eax),%eax
f01046fa:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f01046fd:	b8 08 00 00 00       	mov    $0x8,%eax
f0104702:	eb 3f                	jmp    f0104743 <vprintfmt+0x3a7>
		return va_arg(*ap, unsigned int);
f0104704:	8b 45 14             	mov    0x14(%ebp),%eax
f0104707:	8b 10                	mov    (%eax),%edx
f0104709:	b9 00 00 00 00       	mov    $0x0,%ecx
f010470e:	8d 40 04             	lea    0x4(%eax),%eax
f0104711:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0104714:	b8 08 00 00 00       	mov    $0x8,%eax
f0104719:	eb 28                	jmp    f0104743 <vprintfmt+0x3a7>
			putch('0', putdat);
f010471b:	83 ec 08             	sub    $0x8,%esp
f010471e:	53                   	push   %ebx
f010471f:	6a 30                	push   $0x30
f0104721:	ff d6                	call   *%esi
			putch('x', putdat);
f0104723:	83 c4 08             	add    $0x8,%esp
f0104726:	53                   	push   %ebx
f0104727:	6a 78                	push   $0x78
f0104729:	ff d6                	call   *%esi
			num = (unsigned long long)
f010472b:	8b 45 14             	mov    0x14(%ebp),%eax
f010472e:	8b 10                	mov    (%eax),%edx
f0104730:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f0104735:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f0104738:	8d 40 04             	lea    0x4(%eax),%eax
f010473b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010473e:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
f0104743:	83 ec 0c             	sub    $0xc,%esp
f0104746:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
f010474a:	57                   	push   %edi
f010474b:	ff 75 e0             	pushl  -0x20(%ebp)
f010474e:	50                   	push   %eax
f010474f:	51                   	push   %ecx
f0104750:	52                   	push   %edx
f0104751:	89 da                	mov    %ebx,%edx
f0104753:	89 f0                	mov    %esi,%eax
f0104755:	e8 5a fb ff ff       	call   f01042b4 <printnum>
			break;
f010475a:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
f010475d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0104760:	e9 55 fc ff ff       	jmp    f01043ba <vprintfmt+0x1e>
	if (lflag >= 2)
f0104765:	83 f9 01             	cmp    $0x1,%ecx
f0104768:	7f 1b                	jg     f0104785 <vprintfmt+0x3e9>
	else if (lflag)
f010476a:	85 c9                	test   %ecx,%ecx
f010476c:	74 2c                	je     f010479a <vprintfmt+0x3fe>
		return va_arg(*ap, unsigned long);
f010476e:	8b 45 14             	mov    0x14(%ebp),%eax
f0104771:	8b 10                	mov    (%eax),%edx
f0104773:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104778:	8d 40 04             	lea    0x4(%eax),%eax
f010477b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010477e:	b8 10 00 00 00       	mov    $0x10,%eax
f0104783:	eb be                	jmp    f0104743 <vprintfmt+0x3a7>
		return va_arg(*ap, unsigned long long);
f0104785:	8b 45 14             	mov    0x14(%ebp),%eax
f0104788:	8b 10                	mov    (%eax),%edx
f010478a:	8b 48 04             	mov    0x4(%eax),%ecx
f010478d:	8d 40 08             	lea    0x8(%eax),%eax
f0104790:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0104793:	b8 10 00 00 00       	mov    $0x10,%eax
f0104798:	eb a9                	jmp    f0104743 <vprintfmt+0x3a7>
		return va_arg(*ap, unsigned int);
f010479a:	8b 45 14             	mov    0x14(%ebp),%eax
f010479d:	8b 10                	mov    (%eax),%edx
f010479f:	b9 00 00 00 00       	mov    $0x0,%ecx
f01047a4:	8d 40 04             	lea    0x4(%eax),%eax
f01047a7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01047aa:	b8 10 00 00 00       	mov    $0x10,%eax
f01047af:	eb 92                	jmp    f0104743 <vprintfmt+0x3a7>
			putch(ch, putdat);
f01047b1:	83 ec 08             	sub    $0x8,%esp
f01047b4:	53                   	push   %ebx
f01047b5:	6a 25                	push   $0x25
f01047b7:	ff d6                	call   *%esi
			break;
f01047b9:	83 c4 10             	add    $0x10,%esp
f01047bc:	eb 9f                	jmp    f010475d <vprintfmt+0x3c1>
			putch('%', putdat);
f01047be:	83 ec 08             	sub    $0x8,%esp
f01047c1:	53                   	push   %ebx
f01047c2:	6a 25                	push   $0x25
f01047c4:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f01047c6:	83 c4 10             	add    $0x10,%esp
f01047c9:	89 f8                	mov    %edi,%eax
f01047cb:	eb 03                	jmp    f01047d0 <vprintfmt+0x434>
f01047cd:	83 e8 01             	sub    $0x1,%eax
f01047d0:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f01047d4:	75 f7                	jne    f01047cd <vprintfmt+0x431>
f01047d6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01047d9:	eb 82                	jmp    f010475d <vprintfmt+0x3c1>

f01047db <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01047db:	55                   	push   %ebp
f01047dc:	89 e5                	mov    %esp,%ebp
f01047de:	83 ec 18             	sub    $0x18,%esp
f01047e1:	8b 45 08             	mov    0x8(%ebp),%eax
f01047e4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01047e7:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01047ea:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01047ee:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01047f1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01047f8:	85 c0                	test   %eax,%eax
f01047fa:	74 26                	je     f0104822 <vsnprintf+0x47>
f01047fc:	85 d2                	test   %edx,%edx
f01047fe:	7e 22                	jle    f0104822 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0104800:	ff 75 14             	pushl  0x14(%ebp)
f0104803:	ff 75 10             	pushl  0x10(%ebp)
f0104806:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0104809:	50                   	push   %eax
f010480a:	68 62 43 10 f0       	push   $0xf0104362
f010480f:	e8 88 fb ff ff       	call   f010439c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0104814:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104817:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010481a:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010481d:	83 c4 10             	add    $0x10,%esp
}
f0104820:	c9                   	leave  
f0104821:	c3                   	ret    
		return -E_INVAL;
f0104822:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104827:	eb f7                	jmp    f0104820 <vsnprintf+0x45>

f0104829 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0104829:	55                   	push   %ebp
f010482a:	89 e5                	mov    %esp,%ebp
f010482c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f010482f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0104832:	50                   	push   %eax
f0104833:	ff 75 10             	pushl  0x10(%ebp)
f0104836:	ff 75 0c             	pushl  0xc(%ebp)
f0104839:	ff 75 08             	pushl  0x8(%ebp)
f010483c:	e8 9a ff ff ff       	call   f01047db <vsnprintf>
	va_end(ap);

	return rc;
}
f0104841:	c9                   	leave  
f0104842:	c3                   	ret    

f0104843 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0104843:	55                   	push   %ebp
f0104844:	89 e5                	mov    %esp,%ebp
f0104846:	57                   	push   %edi
f0104847:	56                   	push   %esi
f0104848:	53                   	push   %ebx
f0104849:	83 ec 0c             	sub    $0xc,%esp
f010484c:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f010484f:	85 c0                	test   %eax,%eax
f0104851:	74 11                	je     f0104864 <readline+0x21>
		cprintf("%s", prompt);
f0104853:	83 ec 08             	sub    $0x8,%esp
f0104856:	50                   	push   %eax
f0104857:	68 44 66 10 f0       	push   $0xf0106644
f010485c:	e8 91 ef ff ff       	call   f01037f2 <cprintf>
f0104861:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0104864:	83 ec 0c             	sub    $0xc,%esp
f0104867:	6a 00                	push   $0x0
f0104869:	e8 8e bf ff ff       	call   f01007fc <iscons>
f010486e:	89 c7                	mov    %eax,%edi
f0104870:	83 c4 10             	add    $0x10,%esp
	i = 0;
f0104873:	be 00 00 00 00       	mov    $0x0,%esi
f0104878:	eb 4b                	jmp    f01048c5 <readline+0x82>
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
f010487a:	83 ec 08             	sub    $0x8,%esp
f010487d:	50                   	push   %eax
f010487e:	68 c4 70 10 f0       	push   $0xf01070c4
f0104883:	e8 6a ef ff ff       	call   f01037f2 <cprintf>
			return NULL;
f0104888:	83 c4 10             	add    $0x10,%esp
f010488b:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f0104890:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104893:	5b                   	pop    %ebx
f0104894:	5e                   	pop    %esi
f0104895:	5f                   	pop    %edi
f0104896:	5d                   	pop    %ebp
f0104897:	c3                   	ret    
			if (echoing)
f0104898:	85 ff                	test   %edi,%edi
f010489a:	75 05                	jne    f01048a1 <readline+0x5e>
			i--;
f010489c:	83 ee 01             	sub    $0x1,%esi
f010489f:	eb 24                	jmp    f01048c5 <readline+0x82>
				cputchar('\b');
f01048a1:	83 ec 0c             	sub    $0xc,%esp
f01048a4:	6a 08                	push   $0x8
f01048a6:	e8 30 bf ff ff       	call   f01007db <cputchar>
f01048ab:	83 c4 10             	add    $0x10,%esp
f01048ae:	eb ec                	jmp    f010489c <readline+0x59>
				cputchar(c);
f01048b0:	83 ec 0c             	sub    $0xc,%esp
f01048b3:	53                   	push   %ebx
f01048b4:	e8 22 bf ff ff       	call   f01007db <cputchar>
f01048b9:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f01048bc:	88 9e 80 1a 23 f0    	mov    %bl,-0xfdce580(%esi)
f01048c2:	8d 76 01             	lea    0x1(%esi),%esi
		c = getchar();
f01048c5:	e8 21 bf ff ff       	call   f01007eb <getchar>
f01048ca:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01048cc:	85 c0                	test   %eax,%eax
f01048ce:	78 aa                	js     f010487a <readline+0x37>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01048d0:	83 f8 08             	cmp    $0x8,%eax
f01048d3:	0f 94 c2             	sete   %dl
f01048d6:	83 f8 7f             	cmp    $0x7f,%eax
f01048d9:	0f 94 c0             	sete   %al
f01048dc:	08 c2                	or     %al,%dl
f01048de:	74 04                	je     f01048e4 <readline+0xa1>
f01048e0:	85 f6                	test   %esi,%esi
f01048e2:	7f b4                	jg     f0104898 <readline+0x55>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01048e4:	83 fb 1f             	cmp    $0x1f,%ebx
f01048e7:	7e 0e                	jle    f01048f7 <readline+0xb4>
f01048e9:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f01048ef:	7f 06                	jg     f01048f7 <readline+0xb4>
			if (echoing)
f01048f1:	85 ff                	test   %edi,%edi
f01048f3:	74 c7                	je     f01048bc <readline+0x79>
f01048f5:	eb b9                	jmp    f01048b0 <readline+0x6d>
		} else if (c == '\n' || c == '\r') {
f01048f7:	83 fb 0a             	cmp    $0xa,%ebx
f01048fa:	74 05                	je     f0104901 <readline+0xbe>
f01048fc:	83 fb 0d             	cmp    $0xd,%ebx
f01048ff:	75 c4                	jne    f01048c5 <readline+0x82>
			if (echoing)
f0104901:	85 ff                	test   %edi,%edi
f0104903:	75 11                	jne    f0104916 <readline+0xd3>
			buf[i] = 0;
f0104905:	c6 86 80 1a 23 f0 00 	movb   $0x0,-0xfdce580(%esi)
			return buf;
f010490c:	b8 80 1a 23 f0       	mov    $0xf0231a80,%eax
f0104911:	e9 7a ff ff ff       	jmp    f0104890 <readline+0x4d>
				cputchar('\n');
f0104916:	83 ec 0c             	sub    $0xc,%esp
f0104919:	6a 0a                	push   $0xa
f010491b:	e8 bb be ff ff       	call   f01007db <cputchar>
f0104920:	83 c4 10             	add    $0x10,%esp
f0104923:	eb e0                	jmp    f0104905 <readline+0xc2>

f0104925 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0104925:	55                   	push   %ebp
f0104926:	89 e5                	mov    %esp,%ebp
f0104928:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f010492b:	b8 00 00 00 00       	mov    $0x0,%eax
f0104930:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0104934:	74 05                	je     f010493b <strlen+0x16>
		n++;
f0104936:	83 c0 01             	add    $0x1,%eax
f0104939:	eb f5                	jmp    f0104930 <strlen+0xb>
	return n;
}
f010493b:	5d                   	pop    %ebp
f010493c:	c3                   	ret    

f010493d <strnlen>:

int
strnlen(const char *s, size_t size)
{
f010493d:	55                   	push   %ebp
f010493e:	89 e5                	mov    %esp,%ebp
f0104940:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104943:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0104946:	ba 00 00 00 00       	mov    $0x0,%edx
f010494b:	39 c2                	cmp    %eax,%edx
f010494d:	74 0d                	je     f010495c <strnlen+0x1f>
f010494f:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f0104953:	74 05                	je     f010495a <strnlen+0x1d>
		n++;
f0104955:	83 c2 01             	add    $0x1,%edx
f0104958:	eb f1                	jmp    f010494b <strnlen+0xe>
f010495a:	89 d0                	mov    %edx,%eax
	return n;
}
f010495c:	5d                   	pop    %ebp
f010495d:	c3                   	ret    

f010495e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f010495e:	55                   	push   %ebp
f010495f:	89 e5                	mov    %esp,%ebp
f0104961:	53                   	push   %ebx
f0104962:	8b 45 08             	mov    0x8(%ebp),%eax
f0104965:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0104968:	ba 00 00 00 00       	mov    $0x0,%edx
f010496d:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f0104971:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0104974:	83 c2 01             	add    $0x1,%edx
f0104977:	84 c9                	test   %cl,%cl
f0104979:	75 f2                	jne    f010496d <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f010497b:	5b                   	pop    %ebx
f010497c:	5d                   	pop    %ebp
f010497d:	c3                   	ret    

f010497e <strcat>:

char *
strcat(char *dst, const char *src)
{
f010497e:	55                   	push   %ebp
f010497f:	89 e5                	mov    %esp,%ebp
f0104981:	53                   	push   %ebx
f0104982:	83 ec 10             	sub    $0x10,%esp
f0104985:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0104988:	53                   	push   %ebx
f0104989:	e8 97 ff ff ff       	call   f0104925 <strlen>
f010498e:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
f0104991:	ff 75 0c             	pushl  0xc(%ebp)
f0104994:	01 d8                	add    %ebx,%eax
f0104996:	50                   	push   %eax
f0104997:	e8 c2 ff ff ff       	call   f010495e <strcpy>
	return dst;
}
f010499c:	89 d8                	mov    %ebx,%eax
f010499e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01049a1:	c9                   	leave  
f01049a2:	c3                   	ret    

f01049a3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01049a3:	55                   	push   %ebp
f01049a4:	89 e5                	mov    %esp,%ebp
f01049a6:	56                   	push   %esi
f01049a7:	53                   	push   %ebx
f01049a8:	8b 45 08             	mov    0x8(%ebp),%eax
f01049ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01049ae:	89 c6                	mov    %eax,%esi
f01049b0:	03 75 10             	add    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01049b3:	89 c2                	mov    %eax,%edx
f01049b5:	39 f2                	cmp    %esi,%edx
f01049b7:	74 11                	je     f01049ca <strncpy+0x27>
		*dst++ = *src;
f01049b9:	83 c2 01             	add    $0x1,%edx
f01049bc:	0f b6 19             	movzbl (%ecx),%ebx
f01049bf:	88 5a ff             	mov    %bl,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01049c2:	80 fb 01             	cmp    $0x1,%bl
f01049c5:	83 d9 ff             	sbb    $0xffffffff,%ecx
f01049c8:	eb eb                	jmp    f01049b5 <strncpy+0x12>
	}
	return ret;
}
f01049ca:	5b                   	pop    %ebx
f01049cb:	5e                   	pop    %esi
f01049cc:	5d                   	pop    %ebp
f01049cd:	c3                   	ret    

f01049ce <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01049ce:	55                   	push   %ebp
f01049cf:	89 e5                	mov    %esp,%ebp
f01049d1:	56                   	push   %esi
f01049d2:	53                   	push   %ebx
f01049d3:	8b 75 08             	mov    0x8(%ebp),%esi
f01049d6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01049d9:	8b 55 10             	mov    0x10(%ebp),%edx
f01049dc:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01049de:	85 d2                	test   %edx,%edx
f01049e0:	74 21                	je     f0104a03 <strlcpy+0x35>
f01049e2:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f01049e6:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
f01049e8:	39 c2                	cmp    %eax,%edx
f01049ea:	74 14                	je     f0104a00 <strlcpy+0x32>
f01049ec:	0f b6 19             	movzbl (%ecx),%ebx
f01049ef:	84 db                	test   %bl,%bl
f01049f1:	74 0b                	je     f01049fe <strlcpy+0x30>
			*dst++ = *src++;
f01049f3:	83 c1 01             	add    $0x1,%ecx
f01049f6:	83 c2 01             	add    $0x1,%edx
f01049f9:	88 5a ff             	mov    %bl,-0x1(%edx)
f01049fc:	eb ea                	jmp    f01049e8 <strlcpy+0x1a>
f01049fe:	89 d0                	mov    %edx,%eax
		*dst = '\0';
f0104a00:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0104a03:	29 f0                	sub    %esi,%eax
}
f0104a05:	5b                   	pop    %ebx
f0104a06:	5e                   	pop    %esi
f0104a07:	5d                   	pop    %ebp
f0104a08:	c3                   	ret    

f0104a09 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0104a09:	55                   	push   %ebp
f0104a0a:	89 e5                	mov    %esp,%ebp
f0104a0c:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104a0f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0104a12:	0f b6 01             	movzbl (%ecx),%eax
f0104a15:	84 c0                	test   %al,%al
f0104a17:	74 0c                	je     f0104a25 <strcmp+0x1c>
f0104a19:	3a 02                	cmp    (%edx),%al
f0104a1b:	75 08                	jne    f0104a25 <strcmp+0x1c>
		p++, q++;
f0104a1d:	83 c1 01             	add    $0x1,%ecx
f0104a20:	83 c2 01             	add    $0x1,%edx
f0104a23:	eb ed                	jmp    f0104a12 <strcmp+0x9>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0104a25:	0f b6 c0             	movzbl %al,%eax
f0104a28:	0f b6 12             	movzbl (%edx),%edx
f0104a2b:	29 d0                	sub    %edx,%eax
}
f0104a2d:	5d                   	pop    %ebp
f0104a2e:	c3                   	ret    

f0104a2f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0104a2f:	55                   	push   %ebp
f0104a30:	89 e5                	mov    %esp,%ebp
f0104a32:	53                   	push   %ebx
f0104a33:	8b 45 08             	mov    0x8(%ebp),%eax
f0104a36:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104a39:	89 c3                	mov    %eax,%ebx
f0104a3b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0104a3e:	eb 06                	jmp    f0104a46 <strncmp+0x17>
		n--, p++, q++;
f0104a40:	83 c0 01             	add    $0x1,%eax
f0104a43:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f0104a46:	39 d8                	cmp    %ebx,%eax
f0104a48:	74 16                	je     f0104a60 <strncmp+0x31>
f0104a4a:	0f b6 08             	movzbl (%eax),%ecx
f0104a4d:	84 c9                	test   %cl,%cl
f0104a4f:	74 04                	je     f0104a55 <strncmp+0x26>
f0104a51:	3a 0a                	cmp    (%edx),%cl
f0104a53:	74 eb                	je     f0104a40 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0104a55:	0f b6 00             	movzbl (%eax),%eax
f0104a58:	0f b6 12             	movzbl (%edx),%edx
f0104a5b:	29 d0                	sub    %edx,%eax
}
f0104a5d:	5b                   	pop    %ebx
f0104a5e:	5d                   	pop    %ebp
f0104a5f:	c3                   	ret    
		return 0;
f0104a60:	b8 00 00 00 00       	mov    $0x0,%eax
f0104a65:	eb f6                	jmp    f0104a5d <strncmp+0x2e>

f0104a67 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0104a67:	55                   	push   %ebp
f0104a68:	89 e5                	mov    %esp,%ebp
f0104a6a:	8b 45 08             	mov    0x8(%ebp),%eax
f0104a6d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0104a71:	0f b6 10             	movzbl (%eax),%edx
f0104a74:	84 d2                	test   %dl,%dl
f0104a76:	74 09                	je     f0104a81 <strchr+0x1a>
		if (*s == c)
f0104a78:	38 ca                	cmp    %cl,%dl
f0104a7a:	74 0a                	je     f0104a86 <strchr+0x1f>
	for (; *s; s++)
f0104a7c:	83 c0 01             	add    $0x1,%eax
f0104a7f:	eb f0                	jmp    f0104a71 <strchr+0xa>
			return (char *) s;
	return 0;
f0104a81:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104a86:	5d                   	pop    %ebp
f0104a87:	c3                   	ret    

f0104a88 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0104a88:	55                   	push   %ebp
f0104a89:	89 e5                	mov    %esp,%ebp
f0104a8b:	8b 45 08             	mov    0x8(%ebp),%eax
f0104a8e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0104a92:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0104a95:	38 ca                	cmp    %cl,%dl
f0104a97:	74 09                	je     f0104aa2 <strfind+0x1a>
f0104a99:	84 d2                	test   %dl,%dl
f0104a9b:	74 05                	je     f0104aa2 <strfind+0x1a>
	for (; *s; s++)
f0104a9d:	83 c0 01             	add    $0x1,%eax
f0104aa0:	eb f0                	jmp    f0104a92 <strfind+0xa>
			break;
	return (char *) s;
}
f0104aa2:	5d                   	pop    %ebp
f0104aa3:	c3                   	ret    

f0104aa4 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0104aa4:	55                   	push   %ebp
f0104aa5:	89 e5                	mov    %esp,%ebp
f0104aa7:	57                   	push   %edi
f0104aa8:	56                   	push   %esi
f0104aa9:	53                   	push   %ebx
f0104aaa:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104aad:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0104ab0:	85 c9                	test   %ecx,%ecx
f0104ab2:	74 31                	je     f0104ae5 <memset+0x41>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0104ab4:	89 f8                	mov    %edi,%eax
f0104ab6:	09 c8                	or     %ecx,%eax
f0104ab8:	a8 03                	test   $0x3,%al
f0104aba:	75 23                	jne    f0104adf <memset+0x3b>
		c &= 0xFF;
f0104abc:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0104ac0:	89 d3                	mov    %edx,%ebx
f0104ac2:	c1 e3 08             	shl    $0x8,%ebx
f0104ac5:	89 d0                	mov    %edx,%eax
f0104ac7:	c1 e0 18             	shl    $0x18,%eax
f0104aca:	89 d6                	mov    %edx,%esi
f0104acc:	c1 e6 10             	shl    $0x10,%esi
f0104acf:	09 f0                	or     %esi,%eax
f0104ad1:	09 c2                	or     %eax,%edx
f0104ad3:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0104ad5:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f0104ad8:	89 d0                	mov    %edx,%eax
f0104ada:	fc                   	cld    
f0104adb:	f3 ab                	rep stos %eax,%es:(%edi)
f0104add:	eb 06                	jmp    f0104ae5 <memset+0x41>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0104adf:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104ae2:	fc                   	cld    
f0104ae3:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0104ae5:	89 f8                	mov    %edi,%eax
f0104ae7:	5b                   	pop    %ebx
f0104ae8:	5e                   	pop    %esi
f0104ae9:	5f                   	pop    %edi
f0104aea:	5d                   	pop    %ebp
f0104aeb:	c3                   	ret    

f0104aec <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0104aec:	55                   	push   %ebp
f0104aed:	89 e5                	mov    %esp,%ebp
f0104aef:	57                   	push   %edi
f0104af0:	56                   	push   %esi
f0104af1:	8b 45 08             	mov    0x8(%ebp),%eax
f0104af4:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104af7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0104afa:	39 c6                	cmp    %eax,%esi
f0104afc:	73 32                	jae    f0104b30 <memmove+0x44>
f0104afe:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0104b01:	39 c2                	cmp    %eax,%edx
f0104b03:	76 2b                	jbe    f0104b30 <memmove+0x44>
		s += n;
		d += n;
f0104b05:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104b08:	89 fe                	mov    %edi,%esi
f0104b0a:	09 ce                	or     %ecx,%esi
f0104b0c:	09 d6                	or     %edx,%esi
f0104b0e:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0104b14:	75 0e                	jne    f0104b24 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0104b16:	83 ef 04             	sub    $0x4,%edi
f0104b19:	8d 72 fc             	lea    -0x4(%edx),%esi
f0104b1c:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f0104b1f:	fd                   	std    
f0104b20:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104b22:	eb 09                	jmp    f0104b2d <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0104b24:	83 ef 01             	sub    $0x1,%edi
f0104b27:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f0104b2a:	fd                   	std    
f0104b2b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0104b2d:	fc                   	cld    
f0104b2e:	eb 1a                	jmp    f0104b4a <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104b30:	89 c2                	mov    %eax,%edx
f0104b32:	09 ca                	or     %ecx,%edx
f0104b34:	09 f2                	or     %esi,%edx
f0104b36:	f6 c2 03             	test   $0x3,%dl
f0104b39:	75 0a                	jne    f0104b45 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0104b3b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f0104b3e:	89 c7                	mov    %eax,%edi
f0104b40:	fc                   	cld    
f0104b41:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104b43:	eb 05                	jmp    f0104b4a <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
f0104b45:	89 c7                	mov    %eax,%edi
f0104b47:	fc                   	cld    
f0104b48:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0104b4a:	5e                   	pop    %esi
f0104b4b:	5f                   	pop    %edi
f0104b4c:	5d                   	pop    %ebp
f0104b4d:	c3                   	ret    

f0104b4e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0104b4e:	55                   	push   %ebp
f0104b4f:	89 e5                	mov    %esp,%ebp
f0104b51:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0104b54:	ff 75 10             	pushl  0x10(%ebp)
f0104b57:	ff 75 0c             	pushl  0xc(%ebp)
f0104b5a:	ff 75 08             	pushl  0x8(%ebp)
f0104b5d:	e8 8a ff ff ff       	call   f0104aec <memmove>
}
f0104b62:	c9                   	leave  
f0104b63:	c3                   	ret    

f0104b64 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0104b64:	55                   	push   %ebp
f0104b65:	89 e5                	mov    %esp,%ebp
f0104b67:	56                   	push   %esi
f0104b68:	53                   	push   %ebx
f0104b69:	8b 45 08             	mov    0x8(%ebp),%eax
f0104b6c:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104b6f:	89 c6                	mov    %eax,%esi
f0104b71:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0104b74:	39 f0                	cmp    %esi,%eax
f0104b76:	74 1c                	je     f0104b94 <memcmp+0x30>
		if (*s1 != *s2)
f0104b78:	0f b6 08             	movzbl (%eax),%ecx
f0104b7b:	0f b6 1a             	movzbl (%edx),%ebx
f0104b7e:	38 d9                	cmp    %bl,%cl
f0104b80:	75 08                	jne    f0104b8a <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f0104b82:	83 c0 01             	add    $0x1,%eax
f0104b85:	83 c2 01             	add    $0x1,%edx
f0104b88:	eb ea                	jmp    f0104b74 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
f0104b8a:	0f b6 c1             	movzbl %cl,%eax
f0104b8d:	0f b6 db             	movzbl %bl,%ebx
f0104b90:	29 d8                	sub    %ebx,%eax
f0104b92:	eb 05                	jmp    f0104b99 <memcmp+0x35>
	}

	return 0;
f0104b94:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104b99:	5b                   	pop    %ebx
f0104b9a:	5e                   	pop    %esi
f0104b9b:	5d                   	pop    %ebp
f0104b9c:	c3                   	ret    

f0104b9d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0104b9d:	55                   	push   %ebp
f0104b9e:	89 e5                	mov    %esp,%ebp
f0104ba0:	8b 45 08             	mov    0x8(%ebp),%eax
f0104ba3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0104ba6:	89 c2                	mov    %eax,%edx
f0104ba8:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0104bab:	39 d0                	cmp    %edx,%eax
f0104bad:	73 09                	jae    f0104bb8 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
f0104baf:	38 08                	cmp    %cl,(%eax)
f0104bb1:	74 05                	je     f0104bb8 <memfind+0x1b>
	for (; s < ends; s++)
f0104bb3:	83 c0 01             	add    $0x1,%eax
f0104bb6:	eb f3                	jmp    f0104bab <memfind+0xe>
			break;
	return (void *) s;
}
f0104bb8:	5d                   	pop    %ebp
f0104bb9:	c3                   	ret    

f0104bba <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0104bba:	55                   	push   %ebp
f0104bbb:	89 e5                	mov    %esp,%ebp
f0104bbd:	57                   	push   %edi
f0104bbe:	56                   	push   %esi
f0104bbf:	53                   	push   %ebx
f0104bc0:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104bc3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0104bc6:	eb 03                	jmp    f0104bcb <strtol+0x11>
		s++;
f0104bc8:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
f0104bcb:	0f b6 01             	movzbl (%ecx),%eax
f0104bce:	3c 20                	cmp    $0x20,%al
f0104bd0:	74 f6                	je     f0104bc8 <strtol+0xe>
f0104bd2:	3c 09                	cmp    $0x9,%al
f0104bd4:	74 f2                	je     f0104bc8 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f0104bd6:	3c 2b                	cmp    $0x2b,%al
f0104bd8:	74 2a                	je     f0104c04 <strtol+0x4a>
	int neg = 0;
f0104bda:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f0104bdf:	3c 2d                	cmp    $0x2d,%al
f0104be1:	74 2b                	je     f0104c0e <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0104be3:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0104be9:	75 0f                	jne    f0104bfa <strtol+0x40>
f0104beb:	80 39 30             	cmpb   $0x30,(%ecx)
f0104bee:	74 28                	je     f0104c18 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0104bf0:	85 db                	test   %ebx,%ebx
f0104bf2:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104bf7:	0f 44 d8             	cmove  %eax,%ebx
f0104bfa:	b8 00 00 00 00       	mov    $0x0,%eax
f0104bff:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0104c02:	eb 50                	jmp    f0104c54 <strtol+0x9a>
		s++;
f0104c04:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
f0104c07:	bf 00 00 00 00       	mov    $0x0,%edi
f0104c0c:	eb d5                	jmp    f0104be3 <strtol+0x29>
		s++, neg = 1;
f0104c0e:	83 c1 01             	add    $0x1,%ecx
f0104c11:	bf 01 00 00 00       	mov    $0x1,%edi
f0104c16:	eb cb                	jmp    f0104be3 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0104c18:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0104c1c:	74 0e                	je     f0104c2c <strtol+0x72>
	else if (base == 0 && s[0] == '0')
f0104c1e:	85 db                	test   %ebx,%ebx
f0104c20:	75 d8                	jne    f0104bfa <strtol+0x40>
		s++, base = 8;
f0104c22:	83 c1 01             	add    $0x1,%ecx
f0104c25:	bb 08 00 00 00       	mov    $0x8,%ebx
f0104c2a:	eb ce                	jmp    f0104bfa <strtol+0x40>
		s += 2, base = 16;
f0104c2c:	83 c1 02             	add    $0x2,%ecx
f0104c2f:	bb 10 00 00 00       	mov    $0x10,%ebx
f0104c34:	eb c4                	jmp    f0104bfa <strtol+0x40>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
f0104c36:	8d 72 9f             	lea    -0x61(%edx),%esi
f0104c39:	89 f3                	mov    %esi,%ebx
f0104c3b:	80 fb 19             	cmp    $0x19,%bl
f0104c3e:	77 29                	ja     f0104c69 <strtol+0xaf>
			dig = *s - 'a' + 10;
f0104c40:	0f be d2             	movsbl %dl,%edx
f0104c43:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0104c46:	3b 55 10             	cmp    0x10(%ebp),%edx
f0104c49:	7d 30                	jge    f0104c7b <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
f0104c4b:	83 c1 01             	add    $0x1,%ecx
f0104c4e:	0f af 45 10          	imul   0x10(%ebp),%eax
f0104c52:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f0104c54:	0f b6 11             	movzbl (%ecx),%edx
f0104c57:	8d 72 d0             	lea    -0x30(%edx),%esi
f0104c5a:	89 f3                	mov    %esi,%ebx
f0104c5c:	80 fb 09             	cmp    $0x9,%bl
f0104c5f:	77 d5                	ja     f0104c36 <strtol+0x7c>
			dig = *s - '0';
f0104c61:	0f be d2             	movsbl %dl,%edx
f0104c64:	83 ea 30             	sub    $0x30,%edx
f0104c67:	eb dd                	jmp    f0104c46 <strtol+0x8c>
		else if (*s >= 'A' && *s <= 'Z')
f0104c69:	8d 72 bf             	lea    -0x41(%edx),%esi
f0104c6c:	89 f3                	mov    %esi,%ebx
f0104c6e:	80 fb 19             	cmp    $0x19,%bl
f0104c71:	77 08                	ja     f0104c7b <strtol+0xc1>
			dig = *s - 'A' + 10;
f0104c73:	0f be d2             	movsbl %dl,%edx
f0104c76:	83 ea 37             	sub    $0x37,%edx
f0104c79:	eb cb                	jmp    f0104c46 <strtol+0x8c>
		// we don't properly detect overflow!
	}

	if (endptr)
f0104c7b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0104c7f:	74 05                	je     f0104c86 <strtol+0xcc>
		*endptr = (char *) s;
f0104c81:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104c84:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f0104c86:	89 c2                	mov    %eax,%edx
f0104c88:	f7 da                	neg    %edx
f0104c8a:	85 ff                	test   %edi,%edi
f0104c8c:	0f 45 c2             	cmovne %edx,%eax
}
f0104c8f:	5b                   	pop    %ebx
f0104c90:	5e                   	pop    %esi
f0104c91:	5f                   	pop    %edi
f0104c92:	5d                   	pop    %ebp
f0104c93:	c3                   	ret    

f0104c94 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0104c94:	fa                   	cli    

	xorw    %ax, %ax
f0104c95:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f0104c97:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0104c99:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0104c9b:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0104c9d:	0f 01 16             	lgdtl  (%esi)
f0104ca0:	74 70                	je     f0104d12 <mpsearch1+0x3>
	movl    %cr0, %eax
f0104ca2:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0104ca5:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0104ca9:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0104cac:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0104cb2:	08 00                	or     %al,(%eax)

f0104cb4 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0104cb4:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0104cb8:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0104cba:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0104cbc:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0104cbe:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0104cc2:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0104cc4:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0104cc6:	b8 00 f0 11 00       	mov    $0x11f000,%eax
	movl    %eax, %cr3
f0104ccb:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0104cce:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0104cd1:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0104cd6:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0104cd9:	8b 25 84 1e 23 f0    	mov    0xf0231e84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0104cdf:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0104ce4:	b8 2e 02 10 f0       	mov    $0xf010022e,%eax
	call    *%eax
f0104ce9:	ff d0                	call   *%eax

f0104ceb <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0104ceb:	eb fe                	jmp    f0104ceb <spin>
f0104ced:	8d 76 00             	lea    0x0(%esi),%esi

f0104cf0 <gdt>:
	...
f0104cf8:	ff                   	(bad)  
f0104cf9:	ff 00                	incl   (%eax)
f0104cfb:	00 00                	add    %al,(%eax)
f0104cfd:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0104d04:	00                   	.byte 0x0
f0104d05:	92                   	xchg   %eax,%edx
f0104d06:	cf                   	iret   
	...

f0104d08 <gdtdesc>:
f0104d08:	17                   	pop    %ss
f0104d09:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0104d0e <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0104d0e:	90                   	nop

f0104d0f <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0104d0f:	55                   	push   %ebp
f0104d10:	89 e5                	mov    %esp,%ebp
f0104d12:	57                   	push   %edi
f0104d13:	56                   	push   %esi
f0104d14:	53                   	push   %ebx
f0104d15:	83 ec 0c             	sub    $0xc,%esp
	if (PGNUM(pa) >= npages)
f0104d18:	8b 0d 88 1e 23 f0    	mov    0xf0231e88,%ecx
f0104d1e:	89 c3                	mov    %eax,%ebx
f0104d20:	c1 eb 0c             	shr    $0xc,%ebx
f0104d23:	39 cb                	cmp    %ecx,%ebx
f0104d25:	73 1a                	jae    f0104d41 <mpsearch1+0x32>
	return (void *)(pa + KERNBASE);
f0104d27:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0104d2d:	8d 3c 02             	lea    (%edx,%eax,1),%edi
	if (PGNUM(pa) >= npages)
f0104d30:	89 f8                	mov    %edi,%eax
f0104d32:	c1 e8 0c             	shr    $0xc,%eax
f0104d35:	39 c8                	cmp    %ecx,%eax
f0104d37:	73 1a                	jae    f0104d53 <mpsearch1+0x44>
	return (void *)(pa + KERNBASE);
f0104d39:	81 ef 00 00 00 10    	sub    $0x10000000,%edi

	for (; mp < end; mp++)
f0104d3f:	eb 27                	jmp    f0104d68 <mpsearch1+0x59>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0104d41:	50                   	push   %eax
f0104d42:	68 b4 57 10 f0       	push   $0xf01057b4
f0104d47:	6a 57                	push   $0x57
f0104d49:	68 61 72 10 f0       	push   $0xf0107261
f0104d4e:	e8 41 b3 ff ff       	call   f0100094 <_panic>
f0104d53:	57                   	push   %edi
f0104d54:	68 b4 57 10 f0       	push   $0xf01057b4
f0104d59:	6a 57                	push   $0x57
f0104d5b:	68 61 72 10 f0       	push   $0xf0107261
f0104d60:	e8 2f b3 ff ff       	call   f0100094 <_panic>
f0104d65:	83 c3 10             	add    $0x10,%ebx
f0104d68:	39 fb                	cmp    %edi,%ebx
f0104d6a:	73 30                	jae    f0104d9c <mpsearch1+0x8d>
f0104d6c:	89 de                	mov    %ebx,%esi
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0104d6e:	83 ec 04             	sub    $0x4,%esp
f0104d71:	6a 04                	push   $0x4
f0104d73:	68 71 72 10 f0       	push   $0xf0107271
f0104d78:	53                   	push   %ebx
f0104d79:	e8 e6 fd ff ff       	call   f0104b64 <memcmp>
f0104d7e:	83 c4 10             	add    $0x10,%esp
f0104d81:	85 c0                	test   %eax,%eax
f0104d83:	75 e0                	jne    f0104d65 <mpsearch1+0x56>
f0104d85:	89 da                	mov    %ebx,%edx
	for (i = 0; i < len; i++)
f0104d87:	83 c6 10             	add    $0x10,%esi
		sum += ((uint8_t *)addr)[i];
f0104d8a:	0f b6 0a             	movzbl (%edx),%ecx
f0104d8d:	01 c8                	add    %ecx,%eax
f0104d8f:	83 c2 01             	add    $0x1,%edx
	for (i = 0; i < len; i++)
f0104d92:	39 f2                	cmp    %esi,%edx
f0104d94:	75 f4                	jne    f0104d8a <mpsearch1+0x7b>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0104d96:	84 c0                	test   %al,%al
f0104d98:	75 cb                	jne    f0104d65 <mpsearch1+0x56>
f0104d9a:	eb 05                	jmp    f0104da1 <mpsearch1+0x92>
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f0104d9c:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f0104da1:	89 d8                	mov    %ebx,%eax
f0104da3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104da6:	5b                   	pop    %ebx
f0104da7:	5e                   	pop    %esi
f0104da8:	5f                   	pop    %edi
f0104da9:	5d                   	pop    %ebp
f0104daa:	c3                   	ret    

f0104dab <mp_init>:
	return conf;
}

void
mp_init(void)
{
f0104dab:	55                   	push   %ebp
f0104dac:	89 e5                	mov    %esp,%ebp
f0104dae:	57                   	push   %edi
f0104daf:	56                   	push   %esi
f0104db0:	53                   	push   %ebx
f0104db1:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0104db4:	c7 05 c0 23 23 f0 20 	movl   $0xf0232020,0xf02323c0
f0104dbb:	20 23 f0 
	if (PGNUM(pa) >= npages)
f0104dbe:	83 3d 88 1e 23 f0 00 	cmpl   $0x0,0xf0231e88
f0104dc5:	0f 84 a3 00 00 00    	je     f0104e6e <mp_init+0xc3>
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0104dcb:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0104dd2:	85 c0                	test   %eax,%eax
f0104dd4:	0f 84 aa 00 00 00    	je     f0104e84 <mp_init+0xd9>
		p <<= 4;	// Translate from segment to PA
f0104dda:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f0104ddd:	ba 00 04 00 00       	mov    $0x400,%edx
f0104de2:	e8 28 ff ff ff       	call   f0104d0f <mpsearch1>
f0104de7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104dea:	85 c0                	test   %eax,%eax
f0104dec:	75 1a                	jne    f0104e08 <mp_init+0x5d>
	return mpsearch1(0xF0000, 0x10000);
f0104dee:	ba 00 00 01 00       	mov    $0x10000,%edx
f0104df3:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0104df8:	e8 12 ff ff ff       	call   f0104d0f <mpsearch1>
f0104dfd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if ((mp = mpsearch()) == 0)
f0104e00:	85 c0                	test   %eax,%eax
f0104e02:	0f 84 31 02 00 00    	je     f0105039 <mp_init+0x28e>
	if (mp->physaddr == 0 || mp->type != 0) {
f0104e08:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104e0b:	8b 58 04             	mov    0x4(%eax),%ebx
f0104e0e:	85 db                	test   %ebx,%ebx
f0104e10:	0f 84 97 00 00 00    	je     f0104ead <mp_init+0x102>
f0104e16:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0104e1a:	0f 85 8d 00 00 00    	jne    f0104ead <mp_init+0x102>
f0104e20:	89 d8                	mov    %ebx,%eax
f0104e22:	c1 e8 0c             	shr    $0xc,%eax
f0104e25:	3b 05 88 1e 23 f0    	cmp    0xf0231e88,%eax
f0104e2b:	0f 83 91 00 00 00    	jae    f0104ec2 <mp_init+0x117>
	return (void *)(pa + KERNBASE);
f0104e31:	81 eb 00 00 00 10    	sub    $0x10000000,%ebx
f0104e37:	89 de                	mov    %ebx,%esi
	if (memcmp(conf, "PCMP", 4) != 0) {
f0104e39:	83 ec 04             	sub    $0x4,%esp
f0104e3c:	6a 04                	push   $0x4
f0104e3e:	68 76 72 10 f0       	push   $0xf0107276
f0104e43:	53                   	push   %ebx
f0104e44:	e8 1b fd ff ff       	call   f0104b64 <memcmp>
f0104e49:	83 c4 10             	add    $0x10,%esp
f0104e4c:	85 c0                	test   %eax,%eax
f0104e4e:	0f 85 83 00 00 00    	jne    f0104ed7 <mp_init+0x12c>
f0104e54:	0f b7 7b 04          	movzwl 0x4(%ebx),%edi
f0104e58:	01 df                	add    %ebx,%edi
	sum = 0;
f0104e5a:	89 c2                	mov    %eax,%edx
	for (i = 0; i < len; i++)
f0104e5c:	39 fb                	cmp    %edi,%ebx
f0104e5e:	0f 84 88 00 00 00    	je     f0104eec <mp_init+0x141>
		sum += ((uint8_t *)addr)[i];
f0104e64:	0f b6 0b             	movzbl (%ebx),%ecx
f0104e67:	01 ca                	add    %ecx,%edx
f0104e69:	83 c3 01             	add    $0x1,%ebx
f0104e6c:	eb ee                	jmp    f0104e5c <mp_init+0xb1>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0104e6e:	68 00 04 00 00       	push   $0x400
f0104e73:	68 b4 57 10 f0       	push   $0xf01057b4
f0104e78:	6a 6f                	push   $0x6f
f0104e7a:	68 61 72 10 f0       	push   $0xf0107261
f0104e7f:	e8 10 b2 ff ff       	call   f0100094 <_panic>
		p = *(uint16_t *) (bda + 0x13) * 1024;
f0104e84:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0104e8b:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f0104e8e:	2d 00 04 00 00       	sub    $0x400,%eax
f0104e93:	ba 00 04 00 00       	mov    $0x400,%edx
f0104e98:	e8 72 fe ff ff       	call   f0104d0f <mpsearch1>
f0104e9d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104ea0:	85 c0                	test   %eax,%eax
f0104ea2:	0f 85 60 ff ff ff    	jne    f0104e08 <mp_init+0x5d>
f0104ea8:	e9 41 ff ff ff       	jmp    f0104dee <mp_init+0x43>
		cprintf("SMP: Default configurations not implemented\n");
f0104ead:	83 ec 0c             	sub    $0xc,%esp
f0104eb0:	68 d4 70 10 f0       	push   $0xf01070d4
f0104eb5:	e8 38 e9 ff ff       	call   f01037f2 <cprintf>
f0104eba:	83 c4 10             	add    $0x10,%esp
f0104ebd:	e9 77 01 00 00       	jmp    f0105039 <mp_init+0x28e>
f0104ec2:	53                   	push   %ebx
f0104ec3:	68 b4 57 10 f0       	push   $0xf01057b4
f0104ec8:	68 90 00 00 00       	push   $0x90
f0104ecd:	68 61 72 10 f0       	push   $0xf0107261
f0104ed2:	e8 bd b1 ff ff       	call   f0100094 <_panic>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0104ed7:	83 ec 0c             	sub    $0xc,%esp
f0104eda:	68 04 71 10 f0       	push   $0xf0107104
f0104edf:	e8 0e e9 ff ff       	call   f01037f2 <cprintf>
f0104ee4:	83 c4 10             	add    $0x10,%esp
f0104ee7:	e9 4d 01 00 00       	jmp    f0105039 <mp_init+0x28e>
	if (sum(conf, conf->length) != 0) {
f0104eec:	84 d2                	test   %dl,%dl
f0104eee:	75 16                	jne    f0104f06 <mp_init+0x15b>
	if (conf->version != 1 && conf->version != 4) {
f0104ef0:	0f b6 56 06          	movzbl 0x6(%esi),%edx
f0104ef4:	80 fa 01             	cmp    $0x1,%dl
f0104ef7:	74 05                	je     f0104efe <mp_init+0x153>
f0104ef9:	80 fa 04             	cmp    $0x4,%dl
f0104efc:	75 1d                	jne    f0104f1b <mp_init+0x170>
f0104efe:	0f b7 4e 28          	movzwl 0x28(%esi),%ecx
f0104f02:	01 d9                	add    %ebx,%ecx
f0104f04:	eb 36                	jmp    f0104f3c <mp_init+0x191>
		cprintf("SMP: Bad MP configuration checksum\n");
f0104f06:	83 ec 0c             	sub    $0xc,%esp
f0104f09:	68 38 71 10 f0       	push   $0xf0107138
f0104f0e:	e8 df e8 ff ff       	call   f01037f2 <cprintf>
f0104f13:	83 c4 10             	add    $0x10,%esp
f0104f16:	e9 1e 01 00 00       	jmp    f0105039 <mp_init+0x28e>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0104f1b:	83 ec 08             	sub    $0x8,%esp
f0104f1e:	0f b6 d2             	movzbl %dl,%edx
f0104f21:	52                   	push   %edx
f0104f22:	68 5c 71 10 f0       	push   $0xf010715c
f0104f27:	e8 c6 e8 ff ff       	call   f01037f2 <cprintf>
f0104f2c:	83 c4 10             	add    $0x10,%esp
f0104f2f:	e9 05 01 00 00       	jmp    f0105039 <mp_init+0x28e>
		sum += ((uint8_t *)addr)[i];
f0104f34:	0f b6 13             	movzbl (%ebx),%edx
f0104f37:	01 d0                	add    %edx,%eax
f0104f39:	83 c3 01             	add    $0x1,%ebx
	for (i = 0; i < len; i++)
f0104f3c:	39 d9                	cmp    %ebx,%ecx
f0104f3e:	75 f4                	jne    f0104f34 <mp_init+0x189>
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0104f40:	02 46 2a             	add    0x2a(%esi),%al
f0104f43:	75 1c                	jne    f0104f61 <mp_init+0x1b6>
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
f0104f45:	c7 05 00 20 23 f0 01 	movl   $0x1,0xf0232000
f0104f4c:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0104f4f:	8b 46 24             	mov    0x24(%esi),%eax
f0104f52:	a3 00 30 27 f0       	mov    %eax,0xf0273000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0104f57:	8d 7e 2c             	lea    0x2c(%esi),%edi
f0104f5a:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104f5f:	eb 4d                	jmp    f0104fae <mp_init+0x203>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0104f61:	83 ec 0c             	sub    $0xc,%esp
f0104f64:	68 7c 71 10 f0       	push   $0xf010717c
f0104f69:	e8 84 e8 ff ff       	call   f01037f2 <cprintf>
f0104f6e:	83 c4 10             	add    $0x10,%esp
f0104f71:	e9 c3 00 00 00       	jmp    f0105039 <mp_init+0x28e>
		switch (*p) {
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0104f76:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f0104f7a:	74 11                	je     f0104f8d <mp_init+0x1e2>
				bootcpu = &cpus[ncpu];
f0104f7c:	6b 05 c4 23 23 f0 74 	imul   $0x74,0xf02323c4,%eax
f0104f83:	05 20 20 23 f0       	add    $0xf0232020,%eax
f0104f88:	a3 c0 23 23 f0       	mov    %eax,0xf02323c0
			if (ncpu < NCPU) {
f0104f8d:	a1 c4 23 23 f0       	mov    0xf02323c4,%eax
f0104f92:	83 f8 07             	cmp    $0x7,%eax
f0104f95:	7f 2f                	jg     f0104fc6 <mp_init+0x21b>
				cpus[ncpu].cpu_id = ncpu;
f0104f97:	6b d0 74             	imul   $0x74,%eax,%edx
f0104f9a:	88 82 20 20 23 f0    	mov    %al,-0xfdcdfe0(%edx)
				ncpu++;
f0104fa0:	83 c0 01             	add    $0x1,%eax
f0104fa3:	a3 c4 23 23 f0       	mov    %eax,0xf02323c4
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0104fa8:	83 c7 14             	add    $0x14,%edi
	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0104fab:	83 c3 01             	add    $0x1,%ebx
f0104fae:	0f b7 46 22          	movzwl 0x22(%esi),%eax
f0104fb2:	39 d8                	cmp    %ebx,%eax
f0104fb4:	76 4b                	jbe    f0105001 <mp_init+0x256>
		switch (*p) {
f0104fb6:	0f b6 07             	movzbl (%edi),%eax
f0104fb9:	84 c0                	test   %al,%al
f0104fbb:	74 b9                	je     f0104f76 <mp_init+0x1cb>
f0104fbd:	3c 04                	cmp    $0x4,%al
f0104fbf:	77 1c                	ja     f0104fdd <mp_init+0x232>
			continue;
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0104fc1:	83 c7 08             	add    $0x8,%edi
			continue;
f0104fc4:	eb e5                	jmp    f0104fab <mp_init+0x200>
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0104fc6:	83 ec 08             	sub    $0x8,%esp
f0104fc9:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f0104fcd:	50                   	push   %eax
f0104fce:	68 ac 71 10 f0       	push   $0xf01071ac
f0104fd3:	e8 1a e8 ff ff       	call   f01037f2 <cprintf>
f0104fd8:	83 c4 10             	add    $0x10,%esp
f0104fdb:	eb cb                	jmp    f0104fa8 <mp_init+0x1fd>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0104fdd:	83 ec 08             	sub    $0x8,%esp
		switch (*p) {
f0104fe0:	0f b6 c0             	movzbl %al,%eax
			cprintf("mpinit: unknown config type %x\n", *p);
f0104fe3:	50                   	push   %eax
f0104fe4:	68 d4 71 10 f0       	push   $0xf01071d4
f0104fe9:	e8 04 e8 ff ff       	call   f01037f2 <cprintf>
			ismp = 0;
f0104fee:	c7 05 00 20 23 f0 00 	movl   $0x0,0xf0232000
f0104ff5:	00 00 00 
			i = conf->entry;
f0104ff8:	0f b7 5e 22          	movzwl 0x22(%esi),%ebx
f0104ffc:	83 c4 10             	add    $0x10,%esp
f0104fff:	eb aa                	jmp    f0104fab <mp_init+0x200>
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0105001:	a1 c0 23 23 f0       	mov    0xf02323c0,%eax
f0105006:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f010500d:	83 3d 00 20 23 f0 00 	cmpl   $0x0,0xf0232000
f0105014:	74 2b                	je     f0105041 <mp_init+0x296>
		ncpu = 1;
		lapicaddr = 0;
		cprintf("SMP: configuration not found, SMP disabled\n");
		return;
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0105016:	83 ec 04             	sub    $0x4,%esp
f0105019:	ff 35 c4 23 23 f0    	pushl  0xf02323c4
f010501f:	0f b6 00             	movzbl (%eax),%eax
f0105022:	50                   	push   %eax
f0105023:	68 7b 72 10 f0       	push   $0xf010727b
f0105028:	e8 c5 e7 ff ff       	call   f01037f2 <cprintf>

	if (mp->imcrp) {
f010502d:	83 c4 10             	add    $0x10,%esp
f0105030:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105033:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0105037:	75 2e                	jne    f0105067 <mp_init+0x2bc>
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f0105039:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010503c:	5b                   	pop    %ebx
f010503d:	5e                   	pop    %esi
f010503e:	5f                   	pop    %edi
f010503f:	5d                   	pop    %ebp
f0105040:	c3                   	ret    
		ncpu = 1;
f0105041:	c7 05 c4 23 23 f0 01 	movl   $0x1,0xf02323c4
f0105048:	00 00 00 
		lapicaddr = 0;
f010504b:	c7 05 00 30 27 f0 00 	movl   $0x0,0xf0273000
f0105052:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0105055:	83 ec 0c             	sub    $0xc,%esp
f0105058:	68 f4 71 10 f0       	push   $0xf01071f4
f010505d:	e8 90 e7 ff ff       	call   f01037f2 <cprintf>
		return;
f0105062:	83 c4 10             	add    $0x10,%esp
f0105065:	eb d2                	jmp    f0105039 <mp_init+0x28e>
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0105067:	83 ec 0c             	sub    $0xc,%esp
f010506a:	68 20 72 10 f0       	push   $0xf0107220
f010506f:	e8 7e e7 ff ff       	call   f01037f2 <cprintf>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105074:	b8 70 00 00 00       	mov    $0x70,%eax
f0105079:	ba 22 00 00 00       	mov    $0x22,%edx
f010507e:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010507f:	ba 23 00 00 00       	mov    $0x23,%edx
f0105084:	ec                   	in     (%dx),%al
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f0105085:	83 c8 01             	or     $0x1,%eax
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105088:	ee                   	out    %al,(%dx)
f0105089:	83 c4 10             	add    $0x10,%esp
f010508c:	eb ab                	jmp    f0105039 <mp_init+0x28e>

f010508e <lapicw>:
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
	lapic[index] = value;
f010508e:	8b 0d 04 30 27 f0    	mov    0xf0273004,%ecx
f0105094:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0105097:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0105099:	a1 04 30 27 f0       	mov    0xf0273004,%eax
f010509e:	8b 40 20             	mov    0x20(%eax),%eax
}
f01050a1:	c3                   	ret    

f01050a2 <cpunum>:
}

int
cpunum(void)
{
	if (lapic)
f01050a2:	8b 15 04 30 27 f0    	mov    0xf0273004,%edx
		return lapic[ID] >> 24;
	return 0;
f01050a8:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lapic)
f01050ad:	85 d2                	test   %edx,%edx
f01050af:	74 06                	je     f01050b7 <cpunum+0x15>
		return lapic[ID] >> 24;
f01050b1:	8b 42 20             	mov    0x20(%edx),%eax
f01050b4:	c1 e8 18             	shr    $0x18,%eax
}
f01050b7:	c3                   	ret    

f01050b8 <lapic_init>:
	if (!lapicaddr)
f01050b8:	a1 00 30 27 f0       	mov    0xf0273000,%eax
f01050bd:	85 c0                	test   %eax,%eax
f01050bf:	75 01                	jne    f01050c2 <lapic_init+0xa>
f01050c1:	c3                   	ret    
{
f01050c2:	55                   	push   %ebp
f01050c3:	89 e5                	mov    %esp,%ebp
f01050c5:	83 ec 10             	sub    $0x10,%esp
	lapic = mmio_map_region(lapicaddr, 4096);
f01050c8:	68 00 10 00 00       	push   $0x1000
f01050cd:	50                   	push   %eax
f01050ce:	e8 ea c1 ff ff       	call   f01012bd <mmio_map_region>
f01050d3:	a3 04 30 27 f0       	mov    %eax,0xf0273004
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f01050d8:	ba 27 01 00 00       	mov    $0x127,%edx
f01050dd:	b8 3c 00 00 00       	mov    $0x3c,%eax
f01050e2:	e8 a7 ff ff ff       	call   f010508e <lapicw>
	lapicw(TDCR, X1);
f01050e7:	ba 0b 00 00 00       	mov    $0xb,%edx
f01050ec:	b8 f8 00 00 00       	mov    $0xf8,%eax
f01050f1:	e8 98 ff ff ff       	call   f010508e <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f01050f6:	ba 20 00 02 00       	mov    $0x20020,%edx
f01050fb:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0105100:	e8 89 ff ff ff       	call   f010508e <lapicw>
	lapicw(TICR, 10000000); 
f0105105:	ba 80 96 98 00       	mov    $0x989680,%edx
f010510a:	b8 e0 00 00 00       	mov    $0xe0,%eax
f010510f:	e8 7a ff ff ff       	call   f010508e <lapicw>
	if (thiscpu != bootcpu)
f0105114:	e8 89 ff ff ff       	call   f01050a2 <cpunum>
f0105119:	6b c0 74             	imul   $0x74,%eax,%eax
f010511c:	05 20 20 23 f0       	add    $0xf0232020,%eax
f0105121:	83 c4 10             	add    $0x10,%esp
f0105124:	39 05 c0 23 23 f0    	cmp    %eax,0xf02323c0
f010512a:	74 0f                	je     f010513b <lapic_init+0x83>
		lapicw(LINT0, MASKED);
f010512c:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105131:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0105136:	e8 53 ff ff ff       	call   f010508e <lapicw>
	lapicw(LINT1, MASKED);
f010513b:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105140:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0105145:	e8 44 ff ff ff       	call   f010508e <lapicw>
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f010514a:	a1 04 30 27 f0       	mov    0xf0273004,%eax
f010514f:	8b 40 30             	mov    0x30(%eax),%eax
f0105152:	c1 e8 10             	shr    $0x10,%eax
f0105155:	a8 fc                	test   $0xfc,%al
f0105157:	75 7c                	jne    f01051d5 <lapic_init+0x11d>
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0105159:	ba 33 00 00 00       	mov    $0x33,%edx
f010515e:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0105163:	e8 26 ff ff ff       	call   f010508e <lapicw>
	lapicw(ESR, 0);
f0105168:	ba 00 00 00 00       	mov    $0x0,%edx
f010516d:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105172:	e8 17 ff ff ff       	call   f010508e <lapicw>
	lapicw(ESR, 0);
f0105177:	ba 00 00 00 00       	mov    $0x0,%edx
f010517c:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105181:	e8 08 ff ff ff       	call   f010508e <lapicw>
	lapicw(EOI, 0);
f0105186:	ba 00 00 00 00       	mov    $0x0,%edx
f010518b:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105190:	e8 f9 fe ff ff       	call   f010508e <lapicw>
	lapicw(ICRHI, 0);
f0105195:	ba 00 00 00 00       	mov    $0x0,%edx
f010519a:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010519f:	e8 ea fe ff ff       	call   f010508e <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f01051a4:	ba 00 85 08 00       	mov    $0x88500,%edx
f01051a9:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01051ae:	e8 db fe ff ff       	call   f010508e <lapicw>
	while(lapic[ICRLO] & DELIVS)
f01051b3:	8b 15 04 30 27 f0    	mov    0xf0273004,%edx
f01051b9:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f01051bf:	f6 c4 10             	test   $0x10,%ah
f01051c2:	75 f5                	jne    f01051b9 <lapic_init+0x101>
	lapicw(TPR, 0);
f01051c4:	ba 00 00 00 00       	mov    $0x0,%edx
f01051c9:	b8 20 00 00 00       	mov    $0x20,%eax
f01051ce:	e8 bb fe ff ff       	call   f010508e <lapicw>
}
f01051d3:	c9                   	leave  
f01051d4:	c3                   	ret    
		lapicw(PCINT, MASKED);
f01051d5:	ba 00 00 01 00       	mov    $0x10000,%edx
f01051da:	b8 d0 00 00 00       	mov    $0xd0,%eax
f01051df:	e8 aa fe ff ff       	call   f010508e <lapicw>
f01051e4:	e9 70 ff ff ff       	jmp    f0105159 <lapic_init+0xa1>

f01051e9 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f01051e9:	83 3d 04 30 27 f0 00 	cmpl   $0x0,0xf0273004
f01051f0:	74 17                	je     f0105209 <lapic_eoi+0x20>
{
f01051f2:	55                   	push   %ebp
f01051f3:	89 e5                	mov    %esp,%ebp
f01051f5:	83 ec 08             	sub    $0x8,%esp
		lapicw(EOI, 0);
f01051f8:	ba 00 00 00 00       	mov    $0x0,%edx
f01051fd:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105202:	e8 87 fe ff ff       	call   f010508e <lapicw>
}
f0105207:	c9                   	leave  
f0105208:	c3                   	ret    
f0105209:	c3                   	ret    

f010520a <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f010520a:	55                   	push   %ebp
f010520b:	89 e5                	mov    %esp,%ebp
f010520d:	56                   	push   %esi
f010520e:	53                   	push   %ebx
f010520f:	8b 75 08             	mov    0x8(%ebp),%esi
f0105212:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105215:	b8 0f 00 00 00       	mov    $0xf,%eax
f010521a:	ba 70 00 00 00       	mov    $0x70,%edx
f010521f:	ee                   	out    %al,(%dx)
f0105220:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105225:	ba 71 00 00 00       	mov    $0x71,%edx
f010522a:	ee                   	out    %al,(%dx)
	if (PGNUM(pa) >= npages)
f010522b:	83 3d 88 1e 23 f0 00 	cmpl   $0x0,0xf0231e88
f0105232:	74 7e                	je     f01052b2 <lapic_startap+0xa8>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0105234:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f010523b:	00 00 
	wrv[1] = addr >> 4;
f010523d:	89 d8                	mov    %ebx,%eax
f010523f:	c1 e8 04             	shr    $0x4,%eax
f0105242:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0105248:	c1 e6 18             	shl    $0x18,%esi
f010524b:	89 f2                	mov    %esi,%edx
f010524d:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105252:	e8 37 fe ff ff       	call   f010508e <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0105257:	ba 00 c5 00 00       	mov    $0xc500,%edx
f010525c:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105261:	e8 28 fe ff ff       	call   f010508e <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0105266:	ba 00 85 00 00       	mov    $0x8500,%edx
f010526b:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105270:	e8 19 fe ff ff       	call   f010508e <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105275:	c1 eb 0c             	shr    $0xc,%ebx
f0105278:	80 cf 06             	or     $0x6,%bh
		lapicw(ICRHI, apicid << 24);
f010527b:	89 f2                	mov    %esi,%edx
f010527d:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105282:	e8 07 fe ff ff       	call   f010508e <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105287:	89 da                	mov    %ebx,%edx
f0105289:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010528e:	e8 fb fd ff ff       	call   f010508e <lapicw>
		lapicw(ICRHI, apicid << 24);
f0105293:	89 f2                	mov    %esi,%edx
f0105295:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010529a:	e8 ef fd ff ff       	call   f010508e <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f010529f:	89 da                	mov    %ebx,%edx
f01052a1:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01052a6:	e8 e3 fd ff ff       	call   f010508e <lapicw>
		microdelay(200);
	}
}
f01052ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01052ae:	5b                   	pop    %ebx
f01052af:	5e                   	pop    %esi
f01052b0:	5d                   	pop    %ebp
f01052b1:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01052b2:	68 67 04 00 00       	push   $0x467
f01052b7:	68 b4 57 10 f0       	push   $0xf01057b4
f01052bc:	68 98 00 00 00       	push   $0x98
f01052c1:	68 98 72 10 f0       	push   $0xf0107298
f01052c6:	e8 c9 ad ff ff       	call   f0100094 <_panic>

f01052cb <lapic_ipi>:

void
lapic_ipi(int vector)
{
f01052cb:	55                   	push   %ebp
f01052cc:	89 e5                	mov    %esp,%ebp
f01052ce:	83 ec 08             	sub    $0x8,%esp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f01052d1:	8b 55 08             	mov    0x8(%ebp),%edx
f01052d4:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f01052da:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01052df:	e8 aa fd ff ff       	call   f010508e <lapicw>
	while (lapic[ICRLO] & DELIVS)
f01052e4:	8b 15 04 30 27 f0    	mov    0xf0273004,%edx
f01052ea:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f01052f0:	f6 c4 10             	test   $0x10,%ah
f01052f3:	75 f5                	jne    f01052ea <lapic_ipi+0x1f>
		;
}
f01052f5:	c9                   	leave  
f01052f6:	c3                   	ret    

f01052f7 <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f01052f7:	55                   	push   %ebp
f01052f8:	89 e5                	mov    %esp,%ebp
f01052fa:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f01052fd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0105303:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105306:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0105309:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0105310:	5d                   	pop    %ebp
f0105311:	c3                   	ret    

f0105312 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0105312:	55                   	push   %ebp
f0105313:	89 e5                	mov    %esp,%ebp
f0105315:	56                   	push   %esi
f0105316:	53                   	push   %ebx
f0105317:	8b 5d 08             	mov    0x8(%ebp),%ebx
	return lock->locked && lock->cpu == thiscpu;
f010531a:	83 3b 00             	cmpl   $0x0,(%ebx)
f010531d:	75 12                	jne    f0105331 <spin_lock+0x1f>
	asm volatile("lock; xchgl %0, %1"
f010531f:	ba 01 00 00 00       	mov    $0x1,%edx
f0105324:	89 d0                	mov    %edx,%eax
f0105326:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0105329:	85 c0                	test   %eax,%eax
f010532b:	74 36                	je     f0105363 <spin_lock+0x51>
		asm volatile ("pause");
f010532d:	f3 90                	pause  
f010532f:	eb f3                	jmp    f0105324 <spin_lock+0x12>
	return lock->locked && lock->cpu == thiscpu;
f0105331:	8b 73 08             	mov    0x8(%ebx),%esi
f0105334:	e8 69 fd ff ff       	call   f01050a2 <cpunum>
f0105339:	6b c0 74             	imul   $0x74,%eax,%eax
f010533c:	05 20 20 23 f0       	add    $0xf0232020,%eax
	if (holding(lk))
f0105341:	39 c6                	cmp    %eax,%esi
f0105343:	75 da                	jne    f010531f <spin_lock+0xd>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0105345:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0105348:	e8 55 fd ff ff       	call   f01050a2 <cpunum>
f010534d:	83 ec 0c             	sub    $0xc,%esp
f0105350:	53                   	push   %ebx
f0105351:	50                   	push   %eax
f0105352:	68 a8 72 10 f0       	push   $0xf01072a8
f0105357:	6a 41                	push   $0x41
f0105359:	68 0c 73 10 f0       	push   $0xf010730c
f010535e:	e8 31 ad ff ff       	call   f0100094 <_panic>

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0105363:	e8 3a fd ff ff       	call   f01050a2 <cpunum>
f0105368:	6b c0 74             	imul   $0x74,%eax,%eax
f010536b:	05 20 20 23 f0       	add    $0xf0232020,%eax
f0105370:	89 43 08             	mov    %eax,0x8(%ebx)
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0105373:	89 ea                	mov    %ebp,%edx
	for (i = 0; i < 10; i++){
f0105375:	b8 00 00 00 00       	mov    $0x0,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f010537a:	83 f8 09             	cmp    $0x9,%eax
f010537d:	7f 16                	jg     f0105395 <spin_lock+0x83>
f010537f:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0105385:	76 0e                	jbe    f0105395 <spin_lock+0x83>
		pcs[i] = ebp[1];          // saved %eip
f0105387:	8b 4a 04             	mov    0x4(%edx),%ecx
f010538a:	89 4c 83 0c          	mov    %ecx,0xc(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f010538e:	8b 12                	mov    (%edx),%edx
	for (i = 0; i < 10; i++){
f0105390:	83 c0 01             	add    $0x1,%eax
f0105393:	eb e5                	jmp    f010537a <spin_lock+0x68>
	for (; i < 10; i++)
f0105395:	83 f8 09             	cmp    $0x9,%eax
f0105398:	7f 0d                	jg     f01053a7 <spin_lock+0x95>
		pcs[i] = 0;
f010539a:	c7 44 83 0c 00 00 00 	movl   $0x0,0xc(%ebx,%eax,4)
f01053a1:	00 
	for (; i < 10; i++)
f01053a2:	83 c0 01             	add    $0x1,%eax
f01053a5:	eb ee                	jmp    f0105395 <spin_lock+0x83>
	get_caller_pcs(lk->pcs);
#endif
}
f01053a7:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01053aa:	5b                   	pop    %ebx
f01053ab:	5e                   	pop    %esi
f01053ac:	5d                   	pop    %ebp
f01053ad:	c3                   	ret    

f01053ae <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f01053ae:	55                   	push   %ebp
f01053af:	89 e5                	mov    %esp,%ebp
f01053b1:	57                   	push   %edi
f01053b2:	56                   	push   %esi
f01053b3:	53                   	push   %ebx
f01053b4:	83 ec 4c             	sub    $0x4c,%esp
f01053b7:	8b 75 08             	mov    0x8(%ebp),%esi
	return lock->locked && lock->cpu == thiscpu;
f01053ba:	83 3e 00             	cmpl   $0x0,(%esi)
f01053bd:	75 35                	jne    f01053f4 <spin_unlock+0x46>
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f01053bf:	83 ec 04             	sub    $0x4,%esp
f01053c2:	6a 28                	push   $0x28
f01053c4:	8d 46 0c             	lea    0xc(%esi),%eax
f01053c7:	50                   	push   %eax
f01053c8:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f01053cb:	53                   	push   %ebx
f01053cc:	e8 1b f7 ff ff       	call   f0104aec <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f01053d1:	8b 46 08             	mov    0x8(%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f01053d4:	0f b6 38             	movzbl (%eax),%edi
f01053d7:	8b 76 04             	mov    0x4(%esi),%esi
f01053da:	e8 c3 fc ff ff       	call   f01050a2 <cpunum>
f01053df:	57                   	push   %edi
f01053e0:	56                   	push   %esi
f01053e1:	50                   	push   %eax
f01053e2:	68 d4 72 10 f0       	push   $0xf01072d4
f01053e7:	e8 06 e4 ff ff       	call   f01037f2 <cprintf>
f01053ec:	83 c4 20             	add    $0x20,%esp
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f01053ef:	8d 7d a8             	lea    -0x58(%ebp),%edi
f01053f2:	eb 4e                	jmp    f0105442 <spin_unlock+0x94>
	return lock->locked && lock->cpu == thiscpu;
f01053f4:	8b 5e 08             	mov    0x8(%esi),%ebx
f01053f7:	e8 a6 fc ff ff       	call   f01050a2 <cpunum>
f01053fc:	6b c0 74             	imul   $0x74,%eax,%eax
f01053ff:	05 20 20 23 f0       	add    $0xf0232020,%eax
	if (!holding(lk)) {
f0105404:	39 c3                	cmp    %eax,%ebx
f0105406:	75 b7                	jne    f01053bf <spin_unlock+0x11>
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
	}

	lk->pcs[0] = 0;
f0105408:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f010540f:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
	asm volatile("lock; xchgl %0, %1"
f0105416:	b8 00 00 00 00       	mov    $0x0,%eax
f010541b:	f0 87 06             	lock xchg %eax,(%esi)
	// respect to any other instruction which references the same memory.
	// x86 CPUs will not reorder loads/stores across locked instructions
	// (vol 3, 8.2.2). Because xchg() is implemented using asm volatile,
	// gcc will not reorder C statements across the xchg.
	xchg(&lk->locked, 0);
}
f010541e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105421:	5b                   	pop    %ebx
f0105422:	5e                   	pop    %esi
f0105423:	5f                   	pop    %edi
f0105424:	5d                   	pop    %ebp
f0105425:	c3                   	ret    
				cprintf("  %08x\n", pcs[i]);
f0105426:	83 ec 08             	sub    $0x8,%esp
f0105429:	ff 36                	pushl  (%esi)
f010542b:	68 33 73 10 f0       	push   $0xf0107333
f0105430:	e8 bd e3 ff ff       	call   f01037f2 <cprintf>
f0105435:	83 c4 10             	add    $0x10,%esp
f0105438:	83 c3 04             	add    $0x4,%ebx
		for (i = 0; i < 10 && pcs[i]; i++) {
f010543b:	8d 45 e8             	lea    -0x18(%ebp),%eax
f010543e:	39 c3                	cmp    %eax,%ebx
f0105440:	74 40                	je     f0105482 <spin_unlock+0xd4>
f0105442:	89 de                	mov    %ebx,%esi
f0105444:	8b 03                	mov    (%ebx),%eax
f0105446:	85 c0                	test   %eax,%eax
f0105448:	74 38                	je     f0105482 <spin_unlock+0xd4>
			if (debuginfo_eip(pcs[i], &info) >= 0)
f010544a:	83 ec 08             	sub    $0x8,%esp
f010544d:	57                   	push   %edi
f010544e:	50                   	push   %eax
f010544f:	e8 11 ec ff ff       	call   f0104065 <debuginfo_eip>
f0105454:	83 c4 10             	add    $0x10,%esp
f0105457:	85 c0                	test   %eax,%eax
f0105459:	78 cb                	js     f0105426 <spin_unlock+0x78>
					pcs[i] - info.eip_fn_addr);
f010545b:	8b 06                	mov    (%esi),%eax
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f010545d:	83 ec 04             	sub    $0x4,%esp
f0105460:	89 c2                	mov    %eax,%edx
f0105462:	2b 55 b8             	sub    -0x48(%ebp),%edx
f0105465:	52                   	push   %edx
f0105466:	ff 75 b0             	pushl  -0x50(%ebp)
f0105469:	ff 75 b4             	pushl  -0x4c(%ebp)
f010546c:	ff 75 ac             	pushl  -0x54(%ebp)
f010546f:	ff 75 a8             	pushl  -0x58(%ebp)
f0105472:	50                   	push   %eax
f0105473:	68 1c 73 10 f0       	push   $0xf010731c
f0105478:	e8 75 e3 ff ff       	call   f01037f2 <cprintf>
f010547d:	83 c4 20             	add    $0x20,%esp
f0105480:	eb b6                	jmp    f0105438 <spin_unlock+0x8a>
		panic("spin_unlock");
f0105482:	83 ec 04             	sub    $0x4,%esp
f0105485:	68 3b 73 10 f0       	push   $0xf010733b
f010548a:	6a 67                	push   $0x67
f010548c:	68 0c 73 10 f0       	push   $0xf010730c
f0105491:	e8 fe ab ff ff       	call   f0100094 <_panic>
f0105496:	66 90                	xchg   %ax,%ax
f0105498:	66 90                	xchg   %ax,%ax
f010549a:	66 90                	xchg   %ax,%ax
f010549c:	66 90                	xchg   %ax,%ax
f010549e:	66 90                	xchg   %ax,%ax

f01054a0 <__udivdi3>:
f01054a0:	f3 0f 1e fb          	endbr32 
f01054a4:	55                   	push   %ebp
f01054a5:	57                   	push   %edi
f01054a6:	56                   	push   %esi
f01054a7:	53                   	push   %ebx
f01054a8:	83 ec 1c             	sub    $0x1c,%esp
f01054ab:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f01054af:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f01054b3:	8b 74 24 34          	mov    0x34(%esp),%esi
f01054b7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f01054bb:	85 d2                	test   %edx,%edx
f01054bd:	75 49                	jne    f0105508 <__udivdi3+0x68>
f01054bf:	39 f3                	cmp    %esi,%ebx
f01054c1:	76 15                	jbe    f01054d8 <__udivdi3+0x38>
f01054c3:	31 ff                	xor    %edi,%edi
f01054c5:	89 e8                	mov    %ebp,%eax
f01054c7:	89 f2                	mov    %esi,%edx
f01054c9:	f7 f3                	div    %ebx
f01054cb:	89 fa                	mov    %edi,%edx
f01054cd:	83 c4 1c             	add    $0x1c,%esp
f01054d0:	5b                   	pop    %ebx
f01054d1:	5e                   	pop    %esi
f01054d2:	5f                   	pop    %edi
f01054d3:	5d                   	pop    %ebp
f01054d4:	c3                   	ret    
f01054d5:	8d 76 00             	lea    0x0(%esi),%esi
f01054d8:	89 d9                	mov    %ebx,%ecx
f01054da:	85 db                	test   %ebx,%ebx
f01054dc:	75 0b                	jne    f01054e9 <__udivdi3+0x49>
f01054de:	b8 01 00 00 00       	mov    $0x1,%eax
f01054e3:	31 d2                	xor    %edx,%edx
f01054e5:	f7 f3                	div    %ebx
f01054e7:	89 c1                	mov    %eax,%ecx
f01054e9:	31 d2                	xor    %edx,%edx
f01054eb:	89 f0                	mov    %esi,%eax
f01054ed:	f7 f1                	div    %ecx
f01054ef:	89 c6                	mov    %eax,%esi
f01054f1:	89 e8                	mov    %ebp,%eax
f01054f3:	89 f7                	mov    %esi,%edi
f01054f5:	f7 f1                	div    %ecx
f01054f7:	89 fa                	mov    %edi,%edx
f01054f9:	83 c4 1c             	add    $0x1c,%esp
f01054fc:	5b                   	pop    %ebx
f01054fd:	5e                   	pop    %esi
f01054fe:	5f                   	pop    %edi
f01054ff:	5d                   	pop    %ebp
f0105500:	c3                   	ret    
f0105501:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105508:	39 f2                	cmp    %esi,%edx
f010550a:	77 1c                	ja     f0105528 <__udivdi3+0x88>
f010550c:	0f bd fa             	bsr    %edx,%edi
f010550f:	83 f7 1f             	xor    $0x1f,%edi
f0105512:	75 2c                	jne    f0105540 <__udivdi3+0xa0>
f0105514:	39 f2                	cmp    %esi,%edx
f0105516:	72 06                	jb     f010551e <__udivdi3+0x7e>
f0105518:	31 c0                	xor    %eax,%eax
f010551a:	39 eb                	cmp    %ebp,%ebx
f010551c:	77 ad                	ja     f01054cb <__udivdi3+0x2b>
f010551e:	b8 01 00 00 00       	mov    $0x1,%eax
f0105523:	eb a6                	jmp    f01054cb <__udivdi3+0x2b>
f0105525:	8d 76 00             	lea    0x0(%esi),%esi
f0105528:	31 ff                	xor    %edi,%edi
f010552a:	31 c0                	xor    %eax,%eax
f010552c:	89 fa                	mov    %edi,%edx
f010552e:	83 c4 1c             	add    $0x1c,%esp
f0105531:	5b                   	pop    %ebx
f0105532:	5e                   	pop    %esi
f0105533:	5f                   	pop    %edi
f0105534:	5d                   	pop    %ebp
f0105535:	c3                   	ret    
f0105536:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f010553d:	8d 76 00             	lea    0x0(%esi),%esi
f0105540:	89 f9                	mov    %edi,%ecx
f0105542:	b8 20 00 00 00       	mov    $0x20,%eax
f0105547:	29 f8                	sub    %edi,%eax
f0105549:	d3 e2                	shl    %cl,%edx
f010554b:	89 54 24 08          	mov    %edx,0x8(%esp)
f010554f:	89 c1                	mov    %eax,%ecx
f0105551:	89 da                	mov    %ebx,%edx
f0105553:	d3 ea                	shr    %cl,%edx
f0105555:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0105559:	09 d1                	or     %edx,%ecx
f010555b:	89 f2                	mov    %esi,%edx
f010555d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0105561:	89 f9                	mov    %edi,%ecx
f0105563:	d3 e3                	shl    %cl,%ebx
f0105565:	89 c1                	mov    %eax,%ecx
f0105567:	d3 ea                	shr    %cl,%edx
f0105569:	89 f9                	mov    %edi,%ecx
f010556b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f010556f:	89 eb                	mov    %ebp,%ebx
f0105571:	d3 e6                	shl    %cl,%esi
f0105573:	89 c1                	mov    %eax,%ecx
f0105575:	d3 eb                	shr    %cl,%ebx
f0105577:	09 de                	or     %ebx,%esi
f0105579:	89 f0                	mov    %esi,%eax
f010557b:	f7 74 24 08          	divl   0x8(%esp)
f010557f:	89 d6                	mov    %edx,%esi
f0105581:	89 c3                	mov    %eax,%ebx
f0105583:	f7 64 24 0c          	mull   0xc(%esp)
f0105587:	39 d6                	cmp    %edx,%esi
f0105589:	72 15                	jb     f01055a0 <__udivdi3+0x100>
f010558b:	89 f9                	mov    %edi,%ecx
f010558d:	d3 e5                	shl    %cl,%ebp
f010558f:	39 c5                	cmp    %eax,%ebp
f0105591:	73 04                	jae    f0105597 <__udivdi3+0xf7>
f0105593:	39 d6                	cmp    %edx,%esi
f0105595:	74 09                	je     f01055a0 <__udivdi3+0x100>
f0105597:	89 d8                	mov    %ebx,%eax
f0105599:	31 ff                	xor    %edi,%edi
f010559b:	e9 2b ff ff ff       	jmp    f01054cb <__udivdi3+0x2b>
f01055a0:	8d 43 ff             	lea    -0x1(%ebx),%eax
f01055a3:	31 ff                	xor    %edi,%edi
f01055a5:	e9 21 ff ff ff       	jmp    f01054cb <__udivdi3+0x2b>
f01055aa:	66 90                	xchg   %ax,%ax
f01055ac:	66 90                	xchg   %ax,%ax
f01055ae:	66 90                	xchg   %ax,%ax

f01055b0 <__umoddi3>:
f01055b0:	f3 0f 1e fb          	endbr32 
f01055b4:	55                   	push   %ebp
f01055b5:	57                   	push   %edi
f01055b6:	56                   	push   %esi
f01055b7:	53                   	push   %ebx
f01055b8:	83 ec 1c             	sub    $0x1c,%esp
f01055bb:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f01055bf:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f01055c3:	8b 74 24 30          	mov    0x30(%esp),%esi
f01055c7:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01055cb:	89 da                	mov    %ebx,%edx
f01055cd:	85 c0                	test   %eax,%eax
f01055cf:	75 3f                	jne    f0105610 <__umoddi3+0x60>
f01055d1:	39 df                	cmp    %ebx,%edi
f01055d3:	76 13                	jbe    f01055e8 <__umoddi3+0x38>
f01055d5:	89 f0                	mov    %esi,%eax
f01055d7:	f7 f7                	div    %edi
f01055d9:	89 d0                	mov    %edx,%eax
f01055db:	31 d2                	xor    %edx,%edx
f01055dd:	83 c4 1c             	add    $0x1c,%esp
f01055e0:	5b                   	pop    %ebx
f01055e1:	5e                   	pop    %esi
f01055e2:	5f                   	pop    %edi
f01055e3:	5d                   	pop    %ebp
f01055e4:	c3                   	ret    
f01055e5:	8d 76 00             	lea    0x0(%esi),%esi
f01055e8:	89 fd                	mov    %edi,%ebp
f01055ea:	85 ff                	test   %edi,%edi
f01055ec:	75 0b                	jne    f01055f9 <__umoddi3+0x49>
f01055ee:	b8 01 00 00 00       	mov    $0x1,%eax
f01055f3:	31 d2                	xor    %edx,%edx
f01055f5:	f7 f7                	div    %edi
f01055f7:	89 c5                	mov    %eax,%ebp
f01055f9:	89 d8                	mov    %ebx,%eax
f01055fb:	31 d2                	xor    %edx,%edx
f01055fd:	f7 f5                	div    %ebp
f01055ff:	89 f0                	mov    %esi,%eax
f0105601:	f7 f5                	div    %ebp
f0105603:	89 d0                	mov    %edx,%eax
f0105605:	eb d4                	jmp    f01055db <__umoddi3+0x2b>
f0105607:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f010560e:	66 90                	xchg   %ax,%ax
f0105610:	89 f1                	mov    %esi,%ecx
f0105612:	39 d8                	cmp    %ebx,%eax
f0105614:	76 0a                	jbe    f0105620 <__umoddi3+0x70>
f0105616:	89 f0                	mov    %esi,%eax
f0105618:	83 c4 1c             	add    $0x1c,%esp
f010561b:	5b                   	pop    %ebx
f010561c:	5e                   	pop    %esi
f010561d:	5f                   	pop    %edi
f010561e:	5d                   	pop    %ebp
f010561f:	c3                   	ret    
f0105620:	0f bd e8             	bsr    %eax,%ebp
f0105623:	83 f5 1f             	xor    $0x1f,%ebp
f0105626:	75 20                	jne    f0105648 <__umoddi3+0x98>
f0105628:	39 d8                	cmp    %ebx,%eax
f010562a:	0f 82 b0 00 00 00    	jb     f01056e0 <__umoddi3+0x130>
f0105630:	39 f7                	cmp    %esi,%edi
f0105632:	0f 86 a8 00 00 00    	jbe    f01056e0 <__umoddi3+0x130>
f0105638:	89 c8                	mov    %ecx,%eax
f010563a:	83 c4 1c             	add    $0x1c,%esp
f010563d:	5b                   	pop    %ebx
f010563e:	5e                   	pop    %esi
f010563f:	5f                   	pop    %edi
f0105640:	5d                   	pop    %ebp
f0105641:	c3                   	ret    
f0105642:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0105648:	89 e9                	mov    %ebp,%ecx
f010564a:	ba 20 00 00 00       	mov    $0x20,%edx
f010564f:	29 ea                	sub    %ebp,%edx
f0105651:	d3 e0                	shl    %cl,%eax
f0105653:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105657:	89 d1                	mov    %edx,%ecx
f0105659:	89 f8                	mov    %edi,%eax
f010565b:	d3 e8                	shr    %cl,%eax
f010565d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0105661:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105665:	8b 54 24 04          	mov    0x4(%esp),%edx
f0105669:	09 c1                	or     %eax,%ecx
f010566b:	89 d8                	mov    %ebx,%eax
f010566d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0105671:	89 e9                	mov    %ebp,%ecx
f0105673:	d3 e7                	shl    %cl,%edi
f0105675:	89 d1                	mov    %edx,%ecx
f0105677:	d3 e8                	shr    %cl,%eax
f0105679:	89 e9                	mov    %ebp,%ecx
f010567b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f010567f:	d3 e3                	shl    %cl,%ebx
f0105681:	89 c7                	mov    %eax,%edi
f0105683:	89 d1                	mov    %edx,%ecx
f0105685:	89 f0                	mov    %esi,%eax
f0105687:	d3 e8                	shr    %cl,%eax
f0105689:	89 e9                	mov    %ebp,%ecx
f010568b:	89 fa                	mov    %edi,%edx
f010568d:	d3 e6                	shl    %cl,%esi
f010568f:	09 d8                	or     %ebx,%eax
f0105691:	f7 74 24 08          	divl   0x8(%esp)
f0105695:	89 d1                	mov    %edx,%ecx
f0105697:	89 f3                	mov    %esi,%ebx
f0105699:	f7 64 24 0c          	mull   0xc(%esp)
f010569d:	89 c6                	mov    %eax,%esi
f010569f:	89 d7                	mov    %edx,%edi
f01056a1:	39 d1                	cmp    %edx,%ecx
f01056a3:	72 06                	jb     f01056ab <__umoddi3+0xfb>
f01056a5:	75 10                	jne    f01056b7 <__umoddi3+0x107>
f01056a7:	39 c3                	cmp    %eax,%ebx
f01056a9:	73 0c                	jae    f01056b7 <__umoddi3+0x107>
f01056ab:	2b 44 24 0c          	sub    0xc(%esp),%eax
f01056af:	1b 54 24 08          	sbb    0x8(%esp),%edx
f01056b3:	89 d7                	mov    %edx,%edi
f01056b5:	89 c6                	mov    %eax,%esi
f01056b7:	89 ca                	mov    %ecx,%edx
f01056b9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01056be:	29 f3                	sub    %esi,%ebx
f01056c0:	19 fa                	sbb    %edi,%edx
f01056c2:	89 d0                	mov    %edx,%eax
f01056c4:	d3 e0                	shl    %cl,%eax
f01056c6:	89 e9                	mov    %ebp,%ecx
f01056c8:	d3 eb                	shr    %cl,%ebx
f01056ca:	d3 ea                	shr    %cl,%edx
f01056cc:	09 d8                	or     %ebx,%eax
f01056ce:	83 c4 1c             	add    $0x1c,%esp
f01056d1:	5b                   	pop    %ebx
f01056d2:	5e                   	pop    %esi
f01056d3:	5f                   	pop    %edi
f01056d4:	5d                   	pop    %ebp
f01056d5:	c3                   	ret    
f01056d6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01056dd:	8d 76 00             	lea    0x0(%esi),%esi
f01056e0:	89 da                	mov    %ebx,%edx
f01056e2:	29 fe                	sub    %edi,%esi
f01056e4:	19 c2                	sbb    %eax,%edx
f01056e6:	89 f1                	mov    %esi,%ecx
f01056e8:	89 c8                	mov    %ecx,%eax
f01056ea:	e9 4b ff ff ff       	jmp    f010563a <__umoddi3+0x8a>
