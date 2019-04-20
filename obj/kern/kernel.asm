
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
f0100015:	b8 00 00 12 00       	mov    $0x120000,%eax
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
f0100034:	bc 00 00 12 f0       	mov    $0xf0120000,%esp

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
f010004b:	68 20 5c 10 f0       	push   $0xf0105c20
f0100050:	e8 e9 37 00 00       	call   f010383e <cprintf>
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
f010006f:	68 3c 5c 10 f0       	push   $0xf0105c3c
f0100074:	e8 c5 37 00 00       	call   f010383e <cprintf>
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
f010008a:	e8 53 08 00 00       	call   f01008e2 <mon_backtrace>
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
f010009c:	83 3d 80 2e 23 f0 00 	cmpl   $0x0,0xf0232e80
f01000a3:	74 0f                	je     f01000b4 <_panic+0x20>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000a5:	83 ec 0c             	sub    $0xc,%esp
f01000a8:	6a 00                	push   $0x0
f01000aa:	e8 ba 08 00 00       	call   f0100969 <monitor>
f01000af:	83 c4 10             	add    $0x10,%esp
f01000b2:	eb f1                	jmp    f01000a5 <_panic+0x11>
	panicstr = fmt;
f01000b4:	89 35 80 2e 23 f0    	mov    %esi,0xf0232e80
	asm volatile("cli; cld");
f01000ba:	fa                   	cli    
f01000bb:	fc                   	cld    
	va_start(ap, fmt);
f01000bc:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f01000bf:	e8 0a 55 00 00       	call   f01055ce <cpunum>
f01000c4:	ff 75 0c             	pushl  0xc(%ebp)
f01000c7:	ff 75 08             	pushl  0x8(%ebp)
f01000ca:	50                   	push   %eax
f01000cb:	68 b0 5c 10 f0       	push   $0xf0105cb0
f01000d0:	e8 69 37 00 00       	call   f010383e <cprintf>
	vcprintf(fmt, ap);
f01000d5:	83 c4 08             	add    $0x8,%esp
f01000d8:	53                   	push   %ebx
f01000d9:	56                   	push   %esi
f01000da:	e8 39 37 00 00       	call   f0103818 <vcprintf>
	cprintf("\n");
f01000df:	c7 04 24 0a 65 10 f0 	movl   $0xf010650a,(%esp)
f01000e6:	e8 53 37 00 00       	call   f010383e <cprintf>
f01000eb:	83 c4 10             	add    $0x10,%esp
f01000ee:	eb b5                	jmp    f01000a5 <_panic+0x11>

f01000f0 <i386_init>:
{
f01000f0:	55                   	push   %ebp
f01000f1:	89 e5                	mov    %esp,%ebp
f01000f3:	53                   	push   %ebx
f01000f4:	83 ec 04             	sub    $0x4,%esp
	cons_init();
f01000f7:	e8 a5 05 00 00       	call   f01006a1 <cons_init>
	cprintf("6828 decimal is %o octal!\n", 6828);
f01000fc:	83 ec 08             	sub    $0x8,%esp
f01000ff:	68 ac 1a 00 00       	push   $0x1aac
f0100104:	68 57 5c 10 f0       	push   $0xf0105c57
f0100109:	e8 30 37 00 00       	call   f010383e <cprintf>
	test_backtrace(5);
f010010e:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f0100115:	e8 26 ff ff ff       	call   f0100040 <test_backtrace>
	mem_init();
f010011a:	e8 1d 12 00 00       	call   f010133c <mem_init>
	env_init();
f010011f:	e8 3c 2f 00 00       	call   f0103060 <env_init>
	trap_init();
f0100124:	e8 f3 37 00 00       	call   f010391c <trap_init>
	mp_init();
f0100129:	e8 a9 51 00 00       	call   f01052d7 <mp_init>
	lapic_init();
f010012e:	e8 b1 54 00 00       	call   f01055e4 <lapic_init>
	pic_init();
f0100133:	e8 27 36 00 00       	call   f010375f <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0100138:	c7 04 24 c0 23 12 f0 	movl   $0xf01223c0,(%esp)
f010013f:	e8 fa 56 00 00       	call   f010583e <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100144:	83 c4 10             	add    $0x10,%esp
f0100147:	83 3d 88 2e 23 f0 07 	cmpl   $0x7,0xf0232e88
f010014e:	76 27                	jbe    f0100177 <i386_init+0x87>
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f0100150:	83 ec 04             	sub    $0x4,%esp
f0100153:	b8 3a 52 10 f0       	mov    $0xf010523a,%eax
f0100158:	2d c0 51 10 f0       	sub    $0xf01051c0,%eax
f010015d:	50                   	push   %eax
f010015e:	68 c0 51 10 f0       	push   $0xf01051c0
f0100163:	68 00 70 00 f0       	push   $0xf0007000
f0100168:	e8 a9 4e 00 00       	call   f0105016 <memmove>
f010016d:	83 c4 10             	add    $0x10,%esp
	for (c = cpus; c < cpus + ncpu; c++) {
f0100170:	bb 20 30 23 f0       	mov    $0xf0233020,%ebx
f0100175:	eb 19                	jmp    f0100190 <i386_init+0xa0>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100177:	68 00 70 00 00       	push   $0x7000
f010017c:	68 d4 5c 10 f0       	push   $0xf0105cd4
f0100181:	6a 5e                	push   $0x5e
f0100183:	68 72 5c 10 f0       	push   $0xf0105c72
f0100188:	e8 07 ff ff ff       	call   f0100094 <_panic>
f010018d:	83 c3 74             	add    $0x74,%ebx
f0100190:	6b 05 c4 33 23 f0 74 	imul   $0x74,0xf02333c4,%eax
f0100197:	05 20 30 23 f0       	add    $0xf0233020,%eax
f010019c:	39 c3                	cmp    %eax,%ebx
f010019e:	73 4d                	jae    f01001ed <i386_init+0xfd>
		if (c == cpus + cpunum())  // We've started already.
f01001a0:	e8 29 54 00 00       	call   f01055ce <cpunum>
f01001a5:	6b c0 74             	imul   $0x74,%eax,%eax
f01001a8:	05 20 30 23 f0       	add    $0xf0233020,%eax
f01001ad:	39 c3                	cmp    %eax,%ebx
f01001af:	74 dc                	je     f010018d <i386_init+0x9d>
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f01001b1:	89 d8                	mov    %ebx,%eax
f01001b3:	2d 20 30 23 f0       	sub    $0xf0233020,%eax
f01001b8:	c1 f8 02             	sar    $0x2,%eax
f01001bb:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f01001c1:	c1 e0 0f             	shl    $0xf,%eax
f01001c4:	8d 80 00 c0 23 f0    	lea    -0xfdc4000(%eax),%eax
f01001ca:	a3 84 2e 23 f0       	mov    %eax,0xf0232e84
		lapic_startap(c->cpu_id, PADDR(code));
f01001cf:	83 ec 08             	sub    $0x8,%esp
f01001d2:	68 00 70 00 00       	push   $0x7000
f01001d7:	0f b6 03             	movzbl (%ebx),%eax
f01001da:	50                   	push   %eax
f01001db:	e8 56 55 00 00       	call   f0105736 <lapic_startap>
f01001e0:	83 c4 10             	add    $0x10,%esp
		while(c->cpu_status != CPU_STARTED)
f01001e3:	8b 43 04             	mov    0x4(%ebx),%eax
f01001e6:	83 f8 01             	cmp    $0x1,%eax
f01001e9:	75 f8                	jne    f01001e3 <i386_init+0xf3>
f01001eb:	eb a0                	jmp    f010018d <i386_init+0x9d>
	ENV_CREATE(user_yield, ENV_TYPE_USER);
f01001ed:	83 ec 08             	sub    $0x8,%esp
f01001f0:	6a 00                	push   $0x0
f01001f2:	68 b4 a6 19 f0       	push   $0xf019a6b4
f01001f7:	e8 57 30 00 00       	call   f0103253 <env_create>
	ENV_CREATE(user_yield, ENV_TYPE_USER);
f01001fc:	83 c4 08             	add    $0x8,%esp
f01001ff:	6a 00                	push   $0x0
f0100201:	68 b4 a6 19 f0       	push   $0xf019a6b4
f0100206:	e8 48 30 00 00       	call   f0103253 <env_create>
	ENV_CREATE(user_yield, ENV_TYPE_USER);
f010020b:	83 c4 08             	add    $0x8,%esp
f010020e:	6a 00                	push   $0x0
f0100210:	68 b4 a6 19 f0       	push   $0xf019a6b4
f0100215:	e8 39 30 00 00       	call   f0103253 <env_create>
	sched_yield();
f010021a:	e8 26 41 00 00       	call   f0104345 <sched_yield>

f010021f <mp_main>:
{
f010021f:	55                   	push   %ebp
f0100220:	89 e5                	mov    %esp,%ebp
f0100222:	83 ec 08             	sub    $0x8,%esp
	lcr3(PADDR(kern_pgdir));
f0100225:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f010022a:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010022f:	76 52                	jbe    f0100283 <mp_main+0x64>
	return (physaddr_t)kva - KERNBASE;
f0100231:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0100236:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f0100239:	e8 90 53 00 00       	call   f01055ce <cpunum>
f010023e:	83 ec 08             	sub    $0x8,%esp
f0100241:	50                   	push   %eax
f0100242:	68 7e 5c 10 f0       	push   $0xf0105c7e
f0100247:	e8 f2 35 00 00       	call   f010383e <cprintf>
	lapic_init();
f010024c:	e8 93 53 00 00       	call   f01055e4 <lapic_init>
	env_init_percpu();
f0100251:	e8 de 2d 00 00       	call   f0103034 <env_init_percpu>
	trap_init_percpu();
f0100256:	e8 f7 35 00 00       	call   f0103852 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f010025b:	e8 6e 53 00 00       	call   f01055ce <cpunum>
f0100260:	6b d0 74             	imul   $0x74,%eax,%edx
f0100263:	83 c2 04             	add    $0x4,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0100266:	b8 01 00 00 00       	mov    $0x1,%eax
f010026b:	f0 87 82 20 30 23 f0 	lock xchg %eax,-0xfdccfe0(%edx)
f0100272:	c7 04 24 c0 23 12 f0 	movl   $0xf01223c0,(%esp)
f0100279:	e8 c0 55 00 00       	call   f010583e <spin_lock>
	sched_yield();
f010027e:	e8 c2 40 00 00       	call   f0104345 <sched_yield>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100283:	50                   	push   %eax
f0100284:	68 f8 5c 10 f0       	push   $0xf0105cf8
f0100289:	6a 75                	push   $0x75
f010028b:	68 72 5c 10 f0       	push   $0xf0105c72
f0100290:	e8 ff fd ff ff       	call   f0100094 <_panic>

f0100295 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100295:	55                   	push   %ebp
f0100296:	89 e5                	mov    %esp,%ebp
f0100298:	53                   	push   %ebx
f0100299:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f010029c:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f010029f:	ff 75 0c             	pushl  0xc(%ebp)
f01002a2:	ff 75 08             	pushl  0x8(%ebp)
f01002a5:	68 94 5c 10 f0       	push   $0xf0105c94
f01002aa:	e8 8f 35 00 00       	call   f010383e <cprintf>
	vcprintf(fmt, ap);
f01002af:	83 c4 08             	add    $0x8,%esp
f01002b2:	53                   	push   %ebx
f01002b3:	ff 75 10             	pushl  0x10(%ebp)
f01002b6:	e8 5d 35 00 00       	call   f0103818 <vcprintf>
	cprintf("\n");
f01002bb:	c7 04 24 0a 65 10 f0 	movl   $0xf010650a,(%esp)
f01002c2:	e8 77 35 00 00       	call   f010383e <cprintf>
	va_end(ap);
}
f01002c7:	83 c4 10             	add    $0x10,%esp
f01002ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01002cd:	c9                   	leave  
f01002ce:	c3                   	ret    

f01002cf <serial_proc_data>:
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002cf:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01002d4:	ec                   	in     (%dx),%al
static bool serial_exists;

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01002d5:	a8 01                	test   $0x1,%al
f01002d7:	74 0a                	je     f01002e3 <serial_proc_data+0x14>
f01002d9:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01002de:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01002df:	0f b6 c0             	movzbl %al,%eax
f01002e2:	c3                   	ret    
		return -1;
f01002e3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f01002e8:	c3                   	ret    

f01002e9 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01002e9:	55                   	push   %ebp
f01002ea:	89 e5                	mov    %esp,%ebp
f01002ec:	53                   	push   %ebx
f01002ed:	83 ec 04             	sub    $0x4,%esp
f01002f0:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f01002f2:	ff d3                	call   *%ebx
f01002f4:	83 f8 ff             	cmp    $0xffffffff,%eax
f01002f7:	74 29                	je     f0100322 <cons_intr+0x39>
		if (c == 0)
f01002f9:	85 c0                	test   %eax,%eax
f01002fb:	74 f5                	je     f01002f2 <cons_intr+0x9>
			continue;
		cons.buf[cons.wpos++] = c;
f01002fd:	8b 0d 24 22 23 f0    	mov    0xf0232224,%ecx
f0100303:	8d 51 01             	lea    0x1(%ecx),%edx
f0100306:	88 81 20 20 23 f0    	mov    %al,-0xfdcdfe0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f010030c:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.wpos = 0;
f0100312:	b8 00 00 00 00       	mov    $0x0,%eax
f0100317:	0f 44 d0             	cmove  %eax,%edx
f010031a:	89 15 24 22 23 f0    	mov    %edx,0xf0232224
f0100320:	eb d0                	jmp    f01002f2 <cons_intr+0x9>
	}
}
f0100322:	83 c4 04             	add    $0x4,%esp
f0100325:	5b                   	pop    %ebx
f0100326:	5d                   	pop    %ebp
f0100327:	c3                   	ret    

f0100328 <kbd_proc_data>:
{
f0100328:	55                   	push   %ebp
f0100329:	89 e5                	mov    %esp,%ebp
f010032b:	53                   	push   %ebx
f010032c:	83 ec 04             	sub    $0x4,%esp
f010032f:	ba 64 00 00 00       	mov    $0x64,%edx
f0100334:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f0100335:	a8 01                	test   $0x1,%al
f0100337:	0f 84 f2 00 00 00    	je     f010042f <kbd_proc_data+0x107>
	if (stat & KBS_TERR)
f010033d:	a8 20                	test   $0x20,%al
f010033f:	0f 85 f1 00 00 00    	jne    f0100436 <kbd_proc_data+0x10e>
f0100345:	ba 60 00 00 00       	mov    $0x60,%edx
f010034a:	ec                   	in     (%dx),%al
f010034b:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f010034d:	3c e0                	cmp    $0xe0,%al
f010034f:	74 61                	je     f01003b2 <kbd_proc_data+0x8a>
	} else if (data & 0x80) {
f0100351:	84 c0                	test   %al,%al
f0100353:	78 70                	js     f01003c5 <kbd_proc_data+0x9d>
	} else if (shift & E0ESC) {
f0100355:	8b 0d 00 20 23 f0    	mov    0xf0232000,%ecx
f010035b:	f6 c1 40             	test   $0x40,%cl
f010035e:	74 0e                	je     f010036e <kbd_proc_data+0x46>
		data |= 0x80;
f0100360:	83 c8 80             	or     $0xffffff80,%eax
f0100363:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100365:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100368:	89 0d 00 20 23 f0    	mov    %ecx,0xf0232000
	shift |= shiftcode[data];
f010036e:	0f b6 d2             	movzbl %dl,%edx
f0100371:	0f b6 82 80 5e 10 f0 	movzbl -0xfefa180(%edx),%eax
f0100378:	0b 05 00 20 23 f0    	or     0xf0232000,%eax
	shift ^= togglecode[data];
f010037e:	0f b6 8a 80 5d 10 f0 	movzbl -0xfefa280(%edx),%ecx
f0100385:	31 c8                	xor    %ecx,%eax
f0100387:	a3 00 20 23 f0       	mov    %eax,0xf0232000
	c = charcode[shift & (CTL | SHIFT)][data];
f010038c:	89 c1                	mov    %eax,%ecx
f010038e:	83 e1 03             	and    $0x3,%ecx
f0100391:	8b 0c 8d 60 5d 10 f0 	mov    -0xfefa2a0(,%ecx,4),%ecx
f0100398:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f010039c:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f010039f:	a8 08                	test   $0x8,%al
f01003a1:	74 61                	je     f0100404 <kbd_proc_data+0xdc>
		if ('a' <= c && c <= 'z')
f01003a3:	89 da                	mov    %ebx,%edx
f01003a5:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f01003a8:	83 f9 19             	cmp    $0x19,%ecx
f01003ab:	77 4b                	ja     f01003f8 <kbd_proc_data+0xd0>
			c += 'A' - 'a';
f01003ad:	83 eb 20             	sub    $0x20,%ebx
f01003b0:	eb 0c                	jmp    f01003be <kbd_proc_data+0x96>
		shift |= E0ESC;
f01003b2:	83 0d 00 20 23 f0 40 	orl    $0x40,0xf0232000
		return 0;
f01003b9:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f01003be:	89 d8                	mov    %ebx,%eax
f01003c0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01003c3:	c9                   	leave  
f01003c4:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f01003c5:	8b 0d 00 20 23 f0    	mov    0xf0232000,%ecx
f01003cb:	89 cb                	mov    %ecx,%ebx
f01003cd:	83 e3 40             	and    $0x40,%ebx
f01003d0:	83 e0 7f             	and    $0x7f,%eax
f01003d3:	85 db                	test   %ebx,%ebx
f01003d5:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01003d8:	0f b6 d2             	movzbl %dl,%edx
f01003db:	0f b6 82 80 5e 10 f0 	movzbl -0xfefa180(%edx),%eax
f01003e2:	83 c8 40             	or     $0x40,%eax
f01003e5:	0f b6 c0             	movzbl %al,%eax
f01003e8:	f7 d0                	not    %eax
f01003ea:	21 c8                	and    %ecx,%eax
f01003ec:	a3 00 20 23 f0       	mov    %eax,0xf0232000
		return 0;
f01003f1:	bb 00 00 00 00       	mov    $0x0,%ebx
f01003f6:	eb c6                	jmp    f01003be <kbd_proc_data+0x96>
		else if ('A' <= c && c <= 'Z')
f01003f8:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01003fb:	8d 4b 20             	lea    0x20(%ebx),%ecx
f01003fe:	83 fa 1a             	cmp    $0x1a,%edx
f0100401:	0f 42 d9             	cmovb  %ecx,%ebx
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100404:	f7 d0                	not    %eax
f0100406:	a8 06                	test   $0x6,%al
f0100408:	75 b4                	jne    f01003be <kbd_proc_data+0x96>
f010040a:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100410:	75 ac                	jne    f01003be <kbd_proc_data+0x96>
		cprintf("Rebooting!\n");
f0100412:	83 ec 0c             	sub    $0xc,%esp
f0100415:	68 1c 5d 10 f0       	push   $0xf0105d1c
f010041a:	e8 1f 34 00 00       	call   f010383e <cprintf>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010041f:	b8 03 00 00 00       	mov    $0x3,%eax
f0100424:	ba 92 00 00 00       	mov    $0x92,%edx
f0100429:	ee                   	out    %al,(%dx)
f010042a:	83 c4 10             	add    $0x10,%esp
f010042d:	eb 8f                	jmp    f01003be <kbd_proc_data+0x96>
		return -1;
f010042f:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f0100434:	eb 88                	jmp    f01003be <kbd_proc_data+0x96>
		return -1;
f0100436:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f010043b:	eb 81                	jmp    f01003be <kbd_proc_data+0x96>

f010043d <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f010043d:	55                   	push   %ebp
f010043e:	89 e5                	mov    %esp,%ebp
f0100440:	57                   	push   %edi
f0100441:	56                   	push   %esi
f0100442:	53                   	push   %ebx
f0100443:	83 ec 1c             	sub    $0x1c,%esp
f0100446:	89 c1                	mov    %eax,%ecx
	for (i = 0;
f0100448:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010044d:	bf fd 03 00 00       	mov    $0x3fd,%edi
f0100452:	bb 84 00 00 00       	mov    $0x84,%ebx
f0100457:	89 fa                	mov    %edi,%edx
f0100459:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f010045a:	a8 20                	test   $0x20,%al
f010045c:	75 13                	jne    f0100471 <cons_putc+0x34>
f010045e:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f0100464:	7f 0b                	jg     f0100471 <cons_putc+0x34>
f0100466:	89 da                	mov    %ebx,%edx
f0100468:	ec                   	in     (%dx),%al
f0100469:	ec                   	in     (%dx),%al
f010046a:	ec                   	in     (%dx),%al
f010046b:	ec                   	in     (%dx),%al
	     i++)
f010046c:	83 c6 01             	add    $0x1,%esi
f010046f:	eb e6                	jmp    f0100457 <cons_putc+0x1a>
	outb(COM1 + COM_TX, c);
f0100471:	88 4d e7             	mov    %cl,-0x19(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100474:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100479:	89 c8                	mov    %ecx,%eax
f010047b:	ee                   	out    %al,(%dx)
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010047c:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100481:	bf 79 03 00 00       	mov    $0x379,%edi
f0100486:	bb 84 00 00 00       	mov    $0x84,%ebx
f010048b:	89 fa                	mov    %edi,%edx
f010048d:	ec                   	in     (%dx),%al
f010048e:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f0100494:	7f 0f                	jg     f01004a5 <cons_putc+0x68>
f0100496:	84 c0                	test   %al,%al
f0100498:	78 0b                	js     f01004a5 <cons_putc+0x68>
f010049a:	89 da                	mov    %ebx,%edx
f010049c:	ec                   	in     (%dx),%al
f010049d:	ec                   	in     (%dx),%al
f010049e:	ec                   	in     (%dx),%al
f010049f:	ec                   	in     (%dx),%al
f01004a0:	83 c6 01             	add    $0x1,%esi
f01004a3:	eb e6                	jmp    f010048b <cons_putc+0x4e>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01004a5:	ba 78 03 00 00       	mov    $0x378,%edx
f01004aa:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f01004ae:	ee                   	out    %al,(%dx)
f01004af:	ba 7a 03 00 00       	mov    $0x37a,%edx
f01004b4:	b8 0d 00 00 00       	mov    $0xd,%eax
f01004b9:	ee                   	out    %al,(%dx)
f01004ba:	b8 08 00 00 00       	mov    $0x8,%eax
f01004bf:	ee                   	out    %al,(%dx)
	if (!(c & ~0xFF))
f01004c0:	89 ca                	mov    %ecx,%edx
f01004c2:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f01004c8:	89 c8                	mov    %ecx,%eax
f01004ca:	80 cc 07             	or     $0x7,%ah
f01004cd:	85 d2                	test   %edx,%edx
f01004cf:	0f 44 c8             	cmove  %eax,%ecx
	switch (c & 0xff) {
f01004d2:	0f b6 c1             	movzbl %cl,%eax
f01004d5:	83 f8 09             	cmp    $0x9,%eax
f01004d8:	0f 84 b0 00 00 00    	je     f010058e <cons_putc+0x151>
f01004de:	7e 73                	jle    f0100553 <cons_putc+0x116>
f01004e0:	83 f8 0a             	cmp    $0xa,%eax
f01004e3:	0f 84 98 00 00 00    	je     f0100581 <cons_putc+0x144>
f01004e9:	83 f8 0d             	cmp    $0xd,%eax
f01004ec:	0f 85 d3 00 00 00    	jne    f01005c5 <cons_putc+0x188>
		crt_pos -= (crt_pos % CRT_COLS);
f01004f2:	0f b7 05 28 22 23 f0 	movzwl 0xf0232228,%eax
f01004f9:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01004ff:	c1 e8 16             	shr    $0x16,%eax
f0100502:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100505:	c1 e0 04             	shl    $0x4,%eax
f0100508:	66 a3 28 22 23 f0    	mov    %ax,0xf0232228
	if (crt_pos >= CRT_SIZE) {
f010050e:	66 81 3d 28 22 23 f0 	cmpw   $0x7cf,0xf0232228
f0100515:	cf 07 
f0100517:	0f 87 cb 00 00 00    	ja     f01005e8 <cons_putc+0x1ab>
	outb(addr_6845, 14);
f010051d:	8b 0d 30 22 23 f0    	mov    0xf0232230,%ecx
f0100523:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100528:	89 ca                	mov    %ecx,%edx
f010052a:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f010052b:	0f b7 1d 28 22 23 f0 	movzwl 0xf0232228,%ebx
f0100532:	8d 71 01             	lea    0x1(%ecx),%esi
f0100535:	89 d8                	mov    %ebx,%eax
f0100537:	66 c1 e8 08          	shr    $0x8,%ax
f010053b:	89 f2                	mov    %esi,%edx
f010053d:	ee                   	out    %al,(%dx)
f010053e:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100543:	89 ca                	mov    %ecx,%edx
f0100545:	ee                   	out    %al,(%dx)
f0100546:	89 d8                	mov    %ebx,%eax
f0100548:	89 f2                	mov    %esi,%edx
f010054a:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f010054b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010054e:	5b                   	pop    %ebx
f010054f:	5e                   	pop    %esi
f0100550:	5f                   	pop    %edi
f0100551:	5d                   	pop    %ebp
f0100552:	c3                   	ret    
	switch (c & 0xff) {
f0100553:	83 f8 08             	cmp    $0x8,%eax
f0100556:	75 6d                	jne    f01005c5 <cons_putc+0x188>
		if (crt_pos > 0) {
f0100558:	0f b7 05 28 22 23 f0 	movzwl 0xf0232228,%eax
f010055f:	66 85 c0             	test   %ax,%ax
f0100562:	74 b9                	je     f010051d <cons_putc+0xe0>
			crt_pos--;
f0100564:	83 e8 01             	sub    $0x1,%eax
f0100567:	66 a3 28 22 23 f0    	mov    %ax,0xf0232228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010056d:	0f b7 c0             	movzwl %ax,%eax
f0100570:	b1 00                	mov    $0x0,%cl
f0100572:	83 c9 20             	or     $0x20,%ecx
f0100575:	8b 15 2c 22 23 f0    	mov    0xf023222c,%edx
f010057b:	66 89 0c 42          	mov    %cx,(%edx,%eax,2)
f010057f:	eb 8d                	jmp    f010050e <cons_putc+0xd1>
		crt_pos += CRT_COLS;
f0100581:	66 83 05 28 22 23 f0 	addw   $0x50,0xf0232228
f0100588:	50 
f0100589:	e9 64 ff ff ff       	jmp    f01004f2 <cons_putc+0xb5>
		cons_putc(' ');
f010058e:	b8 20 00 00 00       	mov    $0x20,%eax
f0100593:	e8 a5 fe ff ff       	call   f010043d <cons_putc>
		cons_putc(' ');
f0100598:	b8 20 00 00 00       	mov    $0x20,%eax
f010059d:	e8 9b fe ff ff       	call   f010043d <cons_putc>
		cons_putc(' ');
f01005a2:	b8 20 00 00 00       	mov    $0x20,%eax
f01005a7:	e8 91 fe ff ff       	call   f010043d <cons_putc>
		cons_putc(' ');
f01005ac:	b8 20 00 00 00       	mov    $0x20,%eax
f01005b1:	e8 87 fe ff ff       	call   f010043d <cons_putc>
		cons_putc(' ');
f01005b6:	b8 20 00 00 00       	mov    $0x20,%eax
f01005bb:	e8 7d fe ff ff       	call   f010043d <cons_putc>
f01005c0:	e9 49 ff ff ff       	jmp    f010050e <cons_putc+0xd1>
		crt_buf[crt_pos++] = c;		/* write the character */
f01005c5:	0f b7 05 28 22 23 f0 	movzwl 0xf0232228,%eax
f01005cc:	8d 50 01             	lea    0x1(%eax),%edx
f01005cf:	66 89 15 28 22 23 f0 	mov    %dx,0xf0232228
f01005d6:	0f b7 c0             	movzwl %ax,%eax
f01005d9:	8b 15 2c 22 23 f0    	mov    0xf023222c,%edx
f01005df:	66 89 0c 42          	mov    %cx,(%edx,%eax,2)
f01005e3:	e9 26 ff ff ff       	jmp    f010050e <cons_putc+0xd1>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01005e8:	a1 2c 22 23 f0       	mov    0xf023222c,%eax
f01005ed:	83 ec 04             	sub    $0x4,%esp
f01005f0:	68 00 0f 00 00       	push   $0xf00
f01005f5:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01005fb:	52                   	push   %edx
f01005fc:	50                   	push   %eax
f01005fd:	e8 14 4a 00 00       	call   f0105016 <memmove>
			crt_buf[i] = 0x0700 | ' ';
f0100602:	8b 15 2c 22 23 f0    	mov    0xf023222c,%edx
f0100608:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f010060e:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100614:	83 c4 10             	add    $0x10,%esp
f0100617:	66 c7 00 20 07       	movw   $0x720,(%eax)
f010061c:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010061f:	39 d0                	cmp    %edx,%eax
f0100621:	75 f4                	jne    f0100617 <cons_putc+0x1da>
		crt_pos -= CRT_COLS;
f0100623:	66 83 2d 28 22 23 f0 	subw   $0x50,0xf0232228
f010062a:	50 
f010062b:	e9 ed fe ff ff       	jmp    f010051d <cons_putc+0xe0>

f0100630 <serial_intr>:
	if (serial_exists)
f0100630:	80 3d 34 22 23 f0 00 	cmpb   $0x0,0xf0232234
f0100637:	75 01                	jne    f010063a <serial_intr+0xa>
f0100639:	c3                   	ret    
{
f010063a:	55                   	push   %ebp
f010063b:	89 e5                	mov    %esp,%ebp
f010063d:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f0100640:	b8 cf 02 10 f0       	mov    $0xf01002cf,%eax
f0100645:	e8 9f fc ff ff       	call   f01002e9 <cons_intr>
}
f010064a:	c9                   	leave  
f010064b:	c3                   	ret    

f010064c <kbd_intr>:
{
f010064c:	55                   	push   %ebp
f010064d:	89 e5                	mov    %esp,%ebp
f010064f:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100652:	b8 28 03 10 f0       	mov    $0xf0100328,%eax
f0100657:	e8 8d fc ff ff       	call   f01002e9 <cons_intr>
}
f010065c:	c9                   	leave  
f010065d:	c3                   	ret    

f010065e <cons_getc>:
{
f010065e:	55                   	push   %ebp
f010065f:	89 e5                	mov    %esp,%ebp
f0100661:	83 ec 08             	sub    $0x8,%esp
	serial_intr();
f0100664:	e8 c7 ff ff ff       	call   f0100630 <serial_intr>
	kbd_intr();
f0100669:	e8 de ff ff ff       	call   f010064c <kbd_intr>
	if (cons.rpos != cons.wpos) {
f010066e:	8b 15 20 22 23 f0    	mov    0xf0232220,%edx
	return 0;
f0100674:	b8 00 00 00 00       	mov    $0x0,%eax
	if (cons.rpos != cons.wpos) {
f0100679:	3b 15 24 22 23 f0    	cmp    0xf0232224,%edx
f010067f:	74 1e                	je     f010069f <cons_getc+0x41>
		c = cons.buf[cons.rpos++];
f0100681:	8d 4a 01             	lea    0x1(%edx),%ecx
f0100684:	0f b6 82 20 20 23 f0 	movzbl -0xfdcdfe0(%edx),%eax
			cons.rpos = 0;
f010068b:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f0100691:	ba 00 00 00 00       	mov    $0x0,%edx
f0100696:	0f 44 ca             	cmove  %edx,%ecx
f0100699:	89 0d 20 22 23 f0    	mov    %ecx,0xf0232220
}
f010069f:	c9                   	leave  
f01006a0:	c3                   	ret    

f01006a1 <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f01006a1:	55                   	push   %ebp
f01006a2:	89 e5                	mov    %esp,%ebp
f01006a4:	57                   	push   %edi
f01006a5:	56                   	push   %esi
f01006a6:	53                   	push   %ebx
f01006a7:	83 ec 0c             	sub    $0xc,%esp
	was = *cp;
f01006aa:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f01006b1:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f01006b8:	5a a5 
	if (*cp != 0xA55A) {
f01006ba:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f01006c1:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01006c5:	0f 84 d4 00 00 00    	je     f010079f <cons_init+0xfe>
		addr_6845 = MONO_BASE;
f01006cb:	c7 05 30 22 23 f0 b4 	movl   $0x3b4,0xf0232230
f01006d2:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f01006d5:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
	outb(addr_6845, 14);
f01006da:	8b 3d 30 22 23 f0    	mov    0xf0232230,%edi
f01006e0:	b8 0e 00 00 00       	mov    $0xe,%eax
f01006e5:	89 fa                	mov    %edi,%edx
f01006e7:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01006e8:	8d 4f 01             	lea    0x1(%edi),%ecx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006eb:	89 ca                	mov    %ecx,%edx
f01006ed:	ec                   	in     (%dx),%al
f01006ee:	0f b6 c0             	movzbl %al,%eax
f01006f1:	c1 e0 08             	shl    $0x8,%eax
f01006f4:	89 c3                	mov    %eax,%ebx
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006f6:	b8 0f 00 00 00       	mov    $0xf,%eax
f01006fb:	89 fa                	mov    %edi,%edx
f01006fd:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006fe:	89 ca                	mov    %ecx,%edx
f0100700:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f0100701:	89 35 2c 22 23 f0    	mov    %esi,0xf023222c
	pos |= inb(addr_6845 + 1);
f0100707:	0f b6 c0             	movzbl %al,%eax
f010070a:	09 d8                	or     %ebx,%eax
	crt_pos = pos;
f010070c:	66 a3 28 22 23 f0    	mov    %ax,0xf0232228
	kbd_intr();
f0100712:	e8 35 ff ff ff       	call   f010064c <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_KBD));
f0100717:	83 ec 0c             	sub    $0xc,%esp
f010071a:	0f b7 05 a8 23 12 f0 	movzwl 0xf01223a8,%eax
f0100721:	25 fd ff 00 00       	and    $0xfffd,%eax
f0100726:	50                   	push   %eax
f0100727:	e8 b5 2f 00 00       	call   f01036e1 <irq_setmask_8259A>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010072c:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100731:	b9 fa 03 00 00       	mov    $0x3fa,%ecx
f0100736:	89 d8                	mov    %ebx,%eax
f0100738:	89 ca                	mov    %ecx,%edx
f010073a:	ee                   	out    %al,(%dx)
f010073b:	bf fb 03 00 00       	mov    $0x3fb,%edi
f0100740:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100745:	89 fa                	mov    %edi,%edx
f0100747:	ee                   	out    %al,(%dx)
f0100748:	b8 0c 00 00 00       	mov    $0xc,%eax
f010074d:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100752:	ee                   	out    %al,(%dx)
f0100753:	be f9 03 00 00       	mov    $0x3f9,%esi
f0100758:	89 d8                	mov    %ebx,%eax
f010075a:	89 f2                	mov    %esi,%edx
f010075c:	ee                   	out    %al,(%dx)
f010075d:	b8 03 00 00 00       	mov    $0x3,%eax
f0100762:	89 fa                	mov    %edi,%edx
f0100764:	ee                   	out    %al,(%dx)
f0100765:	ba fc 03 00 00       	mov    $0x3fc,%edx
f010076a:	89 d8                	mov    %ebx,%eax
f010076c:	ee                   	out    %al,(%dx)
f010076d:	b8 01 00 00 00       	mov    $0x1,%eax
f0100772:	89 f2                	mov    %esi,%edx
f0100774:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100775:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010077a:	ec                   	in     (%dx),%al
f010077b:	89 c3                	mov    %eax,%ebx
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f010077d:	83 c4 10             	add    $0x10,%esp
f0100780:	3c ff                	cmp    $0xff,%al
f0100782:	0f 95 05 34 22 23 f0 	setne  0xf0232234
f0100789:	89 ca                	mov    %ecx,%edx
f010078b:	ec                   	in     (%dx),%al
f010078c:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100791:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100792:	80 fb ff             	cmp    $0xff,%bl
f0100795:	74 23                	je     f01007ba <cons_init+0x119>
		cprintf("Serial port does not exist!\n");
}
f0100797:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010079a:	5b                   	pop    %ebx
f010079b:	5e                   	pop    %esi
f010079c:	5f                   	pop    %edi
f010079d:	5d                   	pop    %ebp
f010079e:	c3                   	ret    
		*cp = was;
f010079f:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01007a6:	c7 05 30 22 23 f0 d4 	movl   $0x3d4,0xf0232230
f01007ad:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01007b0:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
f01007b5:	e9 20 ff ff ff       	jmp    f01006da <cons_init+0x39>
		cprintf("Serial port does not exist!\n");
f01007ba:	83 ec 0c             	sub    $0xc,%esp
f01007bd:	68 28 5d 10 f0       	push   $0xf0105d28
f01007c2:	e8 77 30 00 00       	call   f010383e <cprintf>
f01007c7:	83 c4 10             	add    $0x10,%esp
}
f01007ca:	eb cb                	jmp    f0100797 <cons_init+0xf6>

f01007cc <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01007cc:	55                   	push   %ebp
f01007cd:	89 e5                	mov    %esp,%ebp
f01007cf:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01007d2:	8b 45 08             	mov    0x8(%ebp),%eax
f01007d5:	e8 63 fc ff ff       	call   f010043d <cons_putc>
}
f01007da:	c9                   	leave  
f01007db:	c3                   	ret    

f01007dc <getchar>:

int
getchar(void)
{
f01007dc:	55                   	push   %ebp
f01007dd:	89 e5                	mov    %esp,%ebp
f01007df:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01007e2:	e8 77 fe ff ff       	call   f010065e <cons_getc>
f01007e7:	85 c0                	test   %eax,%eax
f01007e9:	74 f7                	je     f01007e2 <getchar+0x6>
		/* do nothing */;
	return c;
}
f01007eb:	c9                   	leave  
f01007ec:	c3                   	ret    

f01007ed <iscons>:
int
iscons(int fdnum)
{
	// used by readline
	return 1;
}
f01007ed:	b8 01 00 00 00       	mov    $0x1,%eax
f01007f2:	c3                   	ret    

f01007f3 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01007f3:	55                   	push   %ebp
f01007f4:	89 e5                	mov    %esp,%ebp
f01007f6:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01007f9:	68 80 5f 10 f0       	push   $0xf0105f80
f01007fe:	68 9e 5f 10 f0       	push   $0xf0105f9e
f0100803:	68 a3 5f 10 f0       	push   $0xf0105fa3
f0100808:	e8 31 30 00 00       	call   f010383e <cprintf>
f010080d:	83 c4 0c             	add    $0xc,%esp
f0100810:	68 50 60 10 f0       	push   $0xf0106050
f0100815:	68 ac 5f 10 f0       	push   $0xf0105fac
f010081a:	68 a3 5f 10 f0       	push   $0xf0105fa3
f010081f:	e8 1a 30 00 00       	call   f010383e <cprintf>
f0100824:	83 c4 0c             	add    $0xc,%esp
f0100827:	68 b5 5f 10 f0       	push   $0xf0105fb5
f010082c:	68 cc 5f 10 f0       	push   $0xf0105fcc
f0100831:	68 a3 5f 10 f0       	push   $0xf0105fa3
f0100836:	e8 03 30 00 00       	call   f010383e <cprintf>
	return 0;
}
f010083b:	b8 00 00 00 00       	mov    $0x0,%eax
f0100840:	c9                   	leave  
f0100841:	c3                   	ret    

f0100842 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100842:	55                   	push   %ebp
f0100843:	89 e5                	mov    %esp,%ebp
f0100845:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100848:	68 d6 5f 10 f0       	push   $0xf0105fd6
f010084d:	e8 ec 2f 00 00       	call   f010383e <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100852:	83 c4 08             	add    $0x8,%esp
f0100855:	68 0c 00 10 00       	push   $0x10000c
f010085a:	68 78 60 10 f0       	push   $0xf0106078
f010085f:	e8 da 2f 00 00       	call   f010383e <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100864:	83 c4 0c             	add    $0xc,%esp
f0100867:	68 0c 00 10 00       	push   $0x10000c
f010086c:	68 0c 00 10 f0       	push   $0xf010000c
f0100871:	68 a0 60 10 f0       	push   $0xf01060a0
f0100876:	e8 c3 2f 00 00       	call   f010383e <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010087b:	83 c4 0c             	add    $0xc,%esp
f010087e:	68 1f 5c 10 00       	push   $0x105c1f
f0100883:	68 1f 5c 10 f0       	push   $0xf0105c1f
f0100888:	68 c4 60 10 f0       	push   $0xf01060c4
f010088d:	e8 ac 2f 00 00       	call   f010383e <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100892:	83 c4 0c             	add    $0xc,%esp
f0100895:	68 00 20 23 00       	push   $0x232000
f010089a:	68 00 20 23 f0       	push   $0xf0232000
f010089f:	68 e8 60 10 f0       	push   $0xf01060e8
f01008a4:	e8 95 2f 00 00       	call   f010383e <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01008a9:	83 c4 0c             	add    $0xc,%esp
f01008ac:	68 08 40 27 00       	push   $0x274008
f01008b1:	68 08 40 27 f0       	push   $0xf0274008
f01008b6:	68 0c 61 10 f0       	push   $0xf010610c
f01008bb:	e8 7e 2f 00 00       	call   f010383e <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f01008c0:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f01008c3:	b8 08 40 27 f0       	mov    $0xf0274008,%eax
f01008c8:	2d 0d fc 0f f0       	sub    $0xf00ffc0d,%eax
	cprintf("Kernel executable memory footprint: %dKB\n",
f01008cd:	c1 f8 0a             	sar    $0xa,%eax
f01008d0:	50                   	push   %eax
f01008d1:	68 30 61 10 f0       	push   $0xf0106130
f01008d6:	e8 63 2f 00 00       	call   f010383e <cprintf>
	return 0;
}
f01008db:	b8 00 00 00 00       	mov    $0x0,%eax
f01008e0:	c9                   	leave  
f01008e1:	c3                   	ret    

f01008e2 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01008e2:	55                   	push   %ebp
f01008e3:	89 e5                	mov    %esp,%ebp
f01008e5:	57                   	push   %edi
f01008e6:	56                   	push   %esi
f01008e7:	53                   	push   %ebx
f01008e8:	83 ec 38             	sub    $0x38,%esp
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f01008eb:	89 eb                	mov    %ebp,%ebx
	// Your code here.
	uint32_t ebp, *ptr_ebp;
	ebp = read_ebp();
	cprintf("Stack backtrace:\n");
f01008ed:	68 ef 5f 10 f0       	push   $0xf0105fef
f01008f2:	e8 47 2f 00 00       	call   f010383e <cprintf>
	while (ebp != 0) {
f01008f7:	83 c4 10             	add    $0x10,%esp
		ptr_ebp = (uint32_t *)ebp;
		cprintf(" ebp %x  eip %x  args %08x %08x %08x %08x %08x\n", 
        		ebp, ptr_ebp[1], ptr_ebp[2], ptr_ebp[3], ptr_ebp[4], ptr_ebp[5], ptr_ebp[6]);
		struct Eipdebuginfo info;
		if (debuginfo_eip(ptr_ebp[1], &info) == 0) {
f01008fa:	8d 7d d0             	lea    -0x30(%ebp),%edi
	while (ebp != 0) {
f01008fd:	eb 25                	jmp    f0100924 <mon_backtrace+0x42>
			uint32_t fn_offset = ptr_ebp[1] - info.eip_fn_addr; 
			cprintf(" \t%s:%d: %.*s+%d\n", info.eip_file, info.eip_line\
f01008ff:	83 ec 08             	sub    $0x8,%esp
			uint32_t fn_offset = ptr_ebp[1] - info.eip_fn_addr; 
f0100902:	8b 43 04             	mov    0x4(%ebx),%eax
f0100905:	2b 45 e0             	sub    -0x20(%ebp),%eax
			cprintf(" \t%s:%d: %.*s+%d\n", info.eip_file, info.eip_line\
f0100908:	50                   	push   %eax
f0100909:	ff 75 d8             	pushl  -0x28(%ebp)
f010090c:	ff 75 dc             	pushl  -0x24(%ebp)
f010090f:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100912:	ff 75 d0             	pushl  -0x30(%ebp)
f0100915:	68 01 60 10 f0       	push   $0xf0106001
f010091a:	e8 1f 2f 00 00       	call   f010383e <cprintf>
f010091f:	83 c4 20             	add    $0x20,%esp
							, info.eip_fn_namelen, info.eip_fn_name, fn_offset);
		}
		ebp = *ptr_ebp;
f0100922:	8b 1e                	mov    (%esi),%ebx
	while (ebp != 0) {
f0100924:	85 db                	test   %ebx,%ebx
f0100926:	74 34                	je     f010095c <mon_backtrace+0x7a>
		ptr_ebp = (uint32_t *)ebp;
f0100928:	89 de                	mov    %ebx,%esi
		cprintf(" ebp %x  eip %x  args %08x %08x %08x %08x %08x\n", 
f010092a:	ff 73 18             	pushl  0x18(%ebx)
f010092d:	ff 73 14             	pushl  0x14(%ebx)
f0100930:	ff 73 10             	pushl  0x10(%ebx)
f0100933:	ff 73 0c             	pushl  0xc(%ebx)
f0100936:	ff 73 08             	pushl  0x8(%ebx)
f0100939:	ff 73 04             	pushl  0x4(%ebx)
f010093c:	53                   	push   %ebx
f010093d:	68 5c 61 10 f0       	push   $0xf010615c
f0100942:	e8 f7 2e 00 00       	call   f010383e <cprintf>
		if (debuginfo_eip(ptr_ebp[1], &info) == 0) {
f0100947:	83 c4 18             	add    $0x18,%esp
f010094a:	57                   	push   %edi
f010094b:	ff 73 04             	pushl  0x4(%ebx)
f010094e:	e8 3c 3c 00 00       	call   f010458f <debuginfo_eip>
f0100953:	83 c4 10             	add    $0x10,%esp
f0100956:	85 c0                	test   %eax,%eax
f0100958:	75 c8                	jne    f0100922 <mon_backtrace+0x40>
f010095a:	eb a3                	jmp    f01008ff <mon_backtrace+0x1d>
	}
	return 0;
}
f010095c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100961:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100964:	5b                   	pop    %ebx
f0100965:	5e                   	pop    %esi
f0100966:	5f                   	pop    %edi
f0100967:	5d                   	pop    %ebp
f0100968:	c3                   	ret    

f0100969 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100969:	55                   	push   %ebp
f010096a:	89 e5                	mov    %esp,%ebp
f010096c:	57                   	push   %edi
f010096d:	56                   	push   %esi
f010096e:	53                   	push   %ebx
f010096f:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100972:	68 8c 61 10 f0       	push   $0xf010618c
f0100977:	e8 c2 2e 00 00       	call   f010383e <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f010097c:	c7 04 24 b0 61 10 f0 	movl   $0xf01061b0,(%esp)
f0100983:	e8 b6 2e 00 00       	call   f010383e <cprintf>

	if (tf != NULL)
f0100988:	83 c4 10             	add    $0x10,%esp
f010098b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f010098f:	0f 84 d9 00 00 00    	je     f0100a6e <monitor+0x105>
		print_trapframe(tf);
f0100995:	83 ec 0c             	sub    $0xc,%esp
f0100998:	ff 75 08             	pushl  0x8(%ebp)
f010099b:	e8 73 33 00 00       	call   f0103d13 <print_trapframe>
f01009a0:	83 c4 10             	add    $0x10,%esp
f01009a3:	e9 c6 00 00 00       	jmp    f0100a6e <monitor+0x105>
		while (*buf && strchr(WHITESPACE, *buf))
f01009a8:	83 ec 08             	sub    $0x8,%esp
f01009ab:	0f be c0             	movsbl %al,%eax
f01009ae:	50                   	push   %eax
f01009af:	68 17 60 10 f0       	push   $0xf0106017
f01009b4:	e8 d8 45 00 00       	call   f0104f91 <strchr>
f01009b9:	83 c4 10             	add    $0x10,%esp
f01009bc:	85 c0                	test   %eax,%eax
f01009be:	74 63                	je     f0100a23 <monitor+0xba>
			*buf++ = 0;
f01009c0:	c6 03 00             	movb   $0x0,(%ebx)
f01009c3:	89 f7                	mov    %esi,%edi
f01009c5:	8d 5b 01             	lea    0x1(%ebx),%ebx
f01009c8:	89 fe                	mov    %edi,%esi
		while (*buf && strchr(WHITESPACE, *buf))
f01009ca:	0f b6 03             	movzbl (%ebx),%eax
f01009cd:	84 c0                	test   %al,%al
f01009cf:	75 d7                	jne    f01009a8 <monitor+0x3f>
	argv[argc] = 0;
f01009d1:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f01009d8:	00 
	if (argc == 0)
f01009d9:	85 f6                	test   %esi,%esi
f01009db:	0f 84 8d 00 00 00    	je     f0100a6e <monitor+0x105>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f01009e1:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (strcmp(argv[0], commands[i].name) == 0)
f01009e6:	83 ec 08             	sub    $0x8,%esp
f01009e9:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f01009ec:	ff 34 85 e0 61 10 f0 	pushl  -0xfef9e20(,%eax,4)
f01009f3:	ff 75 a8             	pushl  -0x58(%ebp)
f01009f6:	e8 38 45 00 00       	call   f0104f33 <strcmp>
f01009fb:	83 c4 10             	add    $0x10,%esp
f01009fe:	85 c0                	test   %eax,%eax
f0100a00:	0f 84 8f 00 00 00    	je     f0100a95 <monitor+0x12c>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100a06:	83 c3 01             	add    $0x1,%ebx
f0100a09:	83 fb 03             	cmp    $0x3,%ebx
f0100a0c:	75 d8                	jne    f01009e6 <monitor+0x7d>
	cprintf("Unknown command '%s'\n", argv[0]);
f0100a0e:	83 ec 08             	sub    $0x8,%esp
f0100a11:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a14:	68 39 60 10 f0       	push   $0xf0106039
f0100a19:	e8 20 2e 00 00       	call   f010383e <cprintf>
f0100a1e:	83 c4 10             	add    $0x10,%esp
f0100a21:	eb 4b                	jmp    f0100a6e <monitor+0x105>
		if (*buf == 0)
f0100a23:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100a26:	74 a9                	je     f01009d1 <monitor+0x68>
		if (argc == MAXARGS-1) {
f0100a28:	83 fe 0f             	cmp    $0xf,%esi
f0100a2b:	74 2f                	je     f0100a5c <monitor+0xf3>
		argv[argc++] = buf;
f0100a2d:	8d 7e 01             	lea    0x1(%esi),%edi
f0100a30:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
		while (*buf && !strchr(WHITESPACE, *buf))
f0100a34:	0f b6 03             	movzbl (%ebx),%eax
f0100a37:	84 c0                	test   %al,%al
f0100a39:	74 8d                	je     f01009c8 <monitor+0x5f>
f0100a3b:	83 ec 08             	sub    $0x8,%esp
f0100a3e:	0f be c0             	movsbl %al,%eax
f0100a41:	50                   	push   %eax
f0100a42:	68 17 60 10 f0       	push   $0xf0106017
f0100a47:	e8 45 45 00 00       	call   f0104f91 <strchr>
f0100a4c:	83 c4 10             	add    $0x10,%esp
f0100a4f:	85 c0                	test   %eax,%eax
f0100a51:	0f 85 71 ff ff ff    	jne    f01009c8 <monitor+0x5f>
			buf++;
f0100a57:	83 c3 01             	add    $0x1,%ebx
f0100a5a:	eb d8                	jmp    f0100a34 <monitor+0xcb>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100a5c:	83 ec 08             	sub    $0x8,%esp
f0100a5f:	6a 10                	push   $0x10
f0100a61:	68 1c 60 10 f0       	push   $0xf010601c
f0100a66:	e8 d3 2d 00 00       	call   f010383e <cprintf>
f0100a6b:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f0100a6e:	83 ec 0c             	sub    $0xc,%esp
f0100a71:	68 13 60 10 f0       	push   $0xf0106013
f0100a76:	e8 f2 42 00 00       	call   f0104d6d <readline>
f0100a7b:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100a7d:	83 c4 10             	add    $0x10,%esp
f0100a80:	85 c0                	test   %eax,%eax
f0100a82:	74 ea                	je     f0100a6e <monitor+0x105>
	argv[argc] = 0;
f0100a84:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f0100a8b:	be 00 00 00 00       	mov    $0x0,%esi
f0100a90:	e9 35 ff ff ff       	jmp    f01009ca <monitor+0x61>
			return commands[i].func(argc, argv, tf);
f0100a95:	83 ec 04             	sub    $0x4,%esp
f0100a98:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100a9b:	ff 75 08             	pushl  0x8(%ebp)
f0100a9e:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100aa1:	52                   	push   %edx
f0100aa2:	56                   	push   %esi
f0100aa3:	ff 14 85 e8 61 10 f0 	call   *-0xfef9e18(,%eax,4)
			if (runcmd(buf, tf) < 0)
f0100aaa:	83 c4 10             	add    $0x10,%esp
f0100aad:	85 c0                	test   %eax,%eax
f0100aaf:	79 bd                	jns    f0100a6e <monitor+0x105>
				break;
	}
}
f0100ab1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100ab4:	5b                   	pop    %ebx
f0100ab5:	5e                   	pop    %esi
f0100ab6:	5f                   	pop    %edi
f0100ab7:	5d                   	pop    %ebp
f0100ab8:	c3                   	ret    

f0100ab9 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100ab9:	55                   	push   %ebp
f0100aba:	89 e5                	mov    %esp,%ebp
f0100abc:	53                   	push   %ebx
f0100abd:	83 ec 0c             	sub    $0xc,%esp
f0100ac0:	89 c3                	mov    %eax,%ebx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	cprintf("nextfree:%p\n", nextfree);
f0100ac2:	ff 35 38 22 23 f0    	pushl  0xf0232238
f0100ac8:	68 04 62 10 f0       	push   $0xf0106204
f0100acd:	e8 6c 2d 00 00       	call   f010383e <cprintf>
	if (!nextfree) {
f0100ad2:	83 c4 10             	add    $0x10,%esp
f0100ad5:	83 3d 38 22 23 f0 00 	cmpl   $0x0,0xf0232238
f0100adc:	74 1e                	je     f0100afc <boot_alloc+0x43>
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	//cprintf("nextfree:%p\n", nextfree);
	result = nextfree;
f0100ade:	a1 38 22 23 f0       	mov    0xf0232238,%eax
	nextfree += ROUNDUP(n, PGSIZE);
f0100ae3:	81 c3 ff 0f 00 00    	add    $0xfff,%ebx
f0100ae9:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0100aef:	01 c3                	add    %eax,%ebx
f0100af1:	89 1d 38 22 23 f0    	mov    %ebx,0xf0232238
	return result;
}
f0100af7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100afa:	c9                   	leave  
f0100afb:	c3                   	ret    
		nextfree = ROUNDUP((char *) end, PGSIZE);		
f0100afc:	b8 07 50 27 f0       	mov    $0xf0275007,%eax
f0100b01:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b06:	a3 38 22 23 f0       	mov    %eax,0xf0232238
f0100b0b:	eb d1                	jmp    f0100ade <boot_alloc+0x25>

f0100b0d <nvram_read>:
{
f0100b0d:	55                   	push   %ebp
f0100b0e:	89 e5                	mov    %esp,%ebp
f0100b10:	56                   	push   %esi
f0100b11:	53                   	push   %ebx
f0100b12:	89 c6                	mov    %eax,%esi
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100b14:	83 ec 0c             	sub    $0xc,%esp
f0100b17:	50                   	push   %eax
f0100b18:	e8 96 2b 00 00       	call   f01036b3 <mc146818_read>
f0100b1d:	89 c3                	mov    %eax,%ebx
f0100b1f:	83 c6 01             	add    $0x1,%esi
f0100b22:	89 34 24             	mov    %esi,(%esp)
f0100b25:	e8 89 2b 00 00       	call   f01036b3 <mc146818_read>
f0100b2a:	c1 e0 08             	shl    $0x8,%eax
f0100b2d:	09 d8                	or     %ebx,%eax
}
f0100b2f:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100b32:	5b                   	pop    %ebx
f0100b33:	5e                   	pop    %esi
f0100b34:	5d                   	pop    %ebp
f0100b35:	c3                   	ret    

f0100b36 <check_va2pa>:

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;
	pgdir = &pgdir[PDX(va)];
f0100b36:	89 d1                	mov    %edx,%ecx
f0100b38:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100b3b:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100b3e:	a8 01                	test   $0x1,%al
f0100b40:	74 52                	je     f0100b94 <check_va2pa+0x5e>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100b42:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0100b47:	89 c1                	mov    %eax,%ecx
f0100b49:	c1 e9 0c             	shr    $0xc,%ecx
f0100b4c:	3b 0d 88 2e 23 f0    	cmp    0xf0232e88,%ecx
f0100b52:	73 25                	jae    f0100b79 <check_va2pa+0x43>
	if (!(p[PTX(va)] & PTE_P))
f0100b54:	c1 ea 0c             	shr    $0xc,%edx
f0100b57:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100b5d:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100b64:	89 c2                	mov    %eax,%edx
f0100b66:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100b69:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b6e:	85 d2                	test   %edx,%edx
f0100b70:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100b75:	0f 44 c2             	cmove  %edx,%eax
f0100b78:	c3                   	ret    
{
f0100b79:	55                   	push   %ebp
f0100b7a:	89 e5                	mov    %esp,%ebp
f0100b7c:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100b7f:	50                   	push   %eax
f0100b80:	68 d4 5c 10 f0       	push   $0xf0105cd4
f0100b85:	68 a3 03 00 00       	push   $0x3a3
f0100b8a:	68 11 62 10 f0       	push   $0xf0106211
f0100b8f:	e8 00 f5 ff ff       	call   f0100094 <_panic>
		return ~0;
f0100b94:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f0100b99:	c3                   	ret    

f0100b9a <check_page_free_list>:
{
f0100b9a:	55                   	push   %ebp
f0100b9b:	89 e5                	mov    %esp,%ebp
f0100b9d:	57                   	push   %edi
f0100b9e:	56                   	push   %esi
f0100b9f:	53                   	push   %ebx
f0100ba0:	83 ec 2c             	sub    $0x2c,%esp
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100ba3:	84 c0                	test   %al,%al
f0100ba5:	0f 85 77 02 00 00    	jne    f0100e22 <check_page_free_list+0x288>
	if (!page_free_list)
f0100bab:	83 3d 3c 22 23 f0 00 	cmpl   $0x0,0xf023223c
f0100bb2:	74 0a                	je     f0100bbe <check_page_free_list+0x24>
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100bb4:	be 00 04 00 00       	mov    $0x400,%esi
f0100bb9:	e9 d1 02 00 00       	jmp    f0100e8f <check_page_free_list+0x2f5>
		panic("'page_free_list' is a null pointer!");
f0100bbe:	83 ec 04             	sub    $0x4,%esp
f0100bc1:	68 3c 65 10 f0       	push   $0xf010653c
f0100bc6:	68 cd 02 00 00       	push   $0x2cd
f0100bcb:	68 11 62 10 f0       	push   $0xf0106211
f0100bd0:	e8 bf f4 ff ff       	call   f0100094 <_panic>
f0100bd5:	50                   	push   %eax
f0100bd6:	68 d4 5c 10 f0       	push   $0xf0105cd4
f0100bdb:	6a 58                	push   $0x58
f0100bdd:	68 24 62 10 f0       	push   $0xf0106224
f0100be2:	e8 ad f4 ff ff       	call   f0100094 <_panic>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100be7:	8b 1b                	mov    (%ebx),%ebx
f0100be9:	85 db                	test   %ebx,%ebx
f0100beb:	74 41                	je     f0100c2e <check_page_free_list+0x94>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100bed:	89 d8                	mov    %ebx,%eax
f0100bef:	2b 05 90 2e 23 f0    	sub    0xf0232e90,%eax
f0100bf5:	c1 f8 03             	sar    $0x3,%eax
f0100bf8:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100bfb:	89 c2                	mov    %eax,%edx
f0100bfd:	c1 ea 16             	shr    $0x16,%edx
f0100c00:	39 f2                	cmp    %esi,%edx
f0100c02:	73 e3                	jae    f0100be7 <check_page_free_list+0x4d>
	if (PGNUM(pa) >= npages)
f0100c04:	89 c2                	mov    %eax,%edx
f0100c06:	c1 ea 0c             	shr    $0xc,%edx
f0100c09:	3b 15 88 2e 23 f0    	cmp    0xf0232e88,%edx
f0100c0f:	73 c4                	jae    f0100bd5 <check_page_free_list+0x3b>
			memset(page2kva(pp), 0x97, 128);
f0100c11:	83 ec 04             	sub    $0x4,%esp
f0100c14:	68 80 00 00 00       	push   $0x80
f0100c19:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0100c1e:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c23:	50                   	push   %eax
f0100c24:	e8 a5 43 00 00       	call   f0104fce <memset>
f0100c29:	83 c4 10             	add    $0x10,%esp
f0100c2c:	eb b9                	jmp    f0100be7 <check_page_free_list+0x4d>
	first_free_page = (char *) boot_alloc(0);
f0100c2e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c33:	e8 81 fe ff ff       	call   f0100ab9 <boot_alloc>
f0100c38:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c3b:	8b 15 3c 22 23 f0    	mov    0xf023223c,%edx
		assert(pp >= pages);
f0100c41:	8b 0d 90 2e 23 f0    	mov    0xf0232e90,%ecx
		assert(pp < pages + npages);
f0100c47:	a1 88 2e 23 f0       	mov    0xf0232e88,%eax
f0100c4c:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100c4f:	8d 34 c1             	lea    (%ecx,%eax,8),%esi
	int nfree_basemem = 0, nfree_extmem = 0;
f0100c52:	bf 00 00 00 00       	mov    $0x0,%edi
f0100c57:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c5a:	e9 f9 00 00 00       	jmp    f0100d58 <check_page_free_list+0x1be>
		assert(pp >= pages);
f0100c5f:	68 32 62 10 f0       	push   $0xf0106232
f0100c64:	68 3e 62 10 f0       	push   $0xf010623e
f0100c69:	68 ea 02 00 00       	push   $0x2ea
f0100c6e:	68 11 62 10 f0       	push   $0xf0106211
f0100c73:	e8 1c f4 ff ff       	call   f0100094 <_panic>
		assert(pp < pages + npages);
f0100c78:	68 53 62 10 f0       	push   $0xf0106253
f0100c7d:	68 3e 62 10 f0       	push   $0xf010623e
f0100c82:	68 eb 02 00 00       	push   $0x2eb
f0100c87:	68 11 62 10 f0       	push   $0xf0106211
f0100c8c:	e8 03 f4 ff ff       	call   f0100094 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100c91:	68 60 65 10 f0       	push   $0xf0106560
f0100c96:	68 3e 62 10 f0       	push   $0xf010623e
f0100c9b:	68 ec 02 00 00       	push   $0x2ec
f0100ca0:	68 11 62 10 f0       	push   $0xf0106211
f0100ca5:	e8 ea f3 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != 0);
f0100caa:	68 67 62 10 f0       	push   $0xf0106267
f0100caf:	68 3e 62 10 f0       	push   $0xf010623e
f0100cb4:	68 ef 02 00 00       	push   $0x2ef
f0100cb9:	68 11 62 10 f0       	push   $0xf0106211
f0100cbe:	e8 d1 f3 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100cc3:	68 78 62 10 f0       	push   $0xf0106278
f0100cc8:	68 3e 62 10 f0       	push   $0xf010623e
f0100ccd:	68 f0 02 00 00       	push   $0x2f0
f0100cd2:	68 11 62 10 f0       	push   $0xf0106211
f0100cd7:	e8 b8 f3 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100cdc:	68 94 65 10 f0       	push   $0xf0106594
f0100ce1:	68 3e 62 10 f0       	push   $0xf010623e
f0100ce6:	68 f1 02 00 00       	push   $0x2f1
f0100ceb:	68 11 62 10 f0       	push   $0xf0106211
f0100cf0:	e8 9f f3 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100cf5:	68 91 62 10 f0       	push   $0xf0106291
f0100cfa:	68 3e 62 10 f0       	push   $0xf010623e
f0100cff:	68 f2 02 00 00       	push   $0x2f2
f0100d04:	68 11 62 10 f0       	push   $0xf0106211
f0100d09:	e8 86 f3 ff ff       	call   f0100094 <_panic>
	if (PGNUM(pa) >= npages)
f0100d0e:	89 c3                	mov    %eax,%ebx
f0100d10:	c1 eb 0c             	shr    $0xc,%ebx
f0100d13:	39 5d d0             	cmp    %ebx,-0x30(%ebp)
f0100d16:	76 0f                	jbe    f0100d27 <check_page_free_list+0x18d>
	return (void *)(pa + KERNBASE);
f0100d18:	2d 00 00 00 10       	sub    $0x10000000,%eax
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100d1d:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0100d20:	77 17                	ja     f0100d39 <check_page_free_list+0x19f>
			++nfree_extmem;
f0100d22:	83 c7 01             	add    $0x1,%edi
f0100d25:	eb 2f                	jmp    f0100d56 <check_page_free_list+0x1bc>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100d27:	50                   	push   %eax
f0100d28:	68 d4 5c 10 f0       	push   $0xf0105cd4
f0100d2d:	6a 58                	push   $0x58
f0100d2f:	68 24 62 10 f0       	push   $0xf0106224
f0100d34:	e8 5b f3 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100d39:	68 b8 65 10 f0       	push   $0xf01065b8
f0100d3e:	68 3e 62 10 f0       	push   $0xf010623e
f0100d43:	68 f3 02 00 00       	push   $0x2f3
f0100d48:	68 11 62 10 f0       	push   $0xf0106211
f0100d4d:	e8 42 f3 ff ff       	call   f0100094 <_panic>
			++nfree_basemem;
f0100d52:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100d56:	8b 12                	mov    (%edx),%edx
f0100d58:	85 d2                	test   %edx,%edx
f0100d5a:	74 74                	je     f0100dd0 <check_page_free_list+0x236>
		assert(pp >= pages);
f0100d5c:	39 d1                	cmp    %edx,%ecx
f0100d5e:	0f 87 fb fe ff ff    	ja     f0100c5f <check_page_free_list+0xc5>
		assert(pp < pages + npages);
f0100d64:	39 d6                	cmp    %edx,%esi
f0100d66:	0f 86 0c ff ff ff    	jbe    f0100c78 <check_page_free_list+0xde>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100d6c:	89 d0                	mov    %edx,%eax
f0100d6e:	29 c8                	sub    %ecx,%eax
f0100d70:	a8 07                	test   $0x7,%al
f0100d72:	0f 85 19 ff ff ff    	jne    f0100c91 <check_page_free_list+0xf7>
	return (pp - pages) << PGSHIFT;
f0100d78:	c1 f8 03             	sar    $0x3,%eax
		assert(page2pa(pp) != 0);
f0100d7b:	c1 e0 0c             	shl    $0xc,%eax
f0100d7e:	0f 84 26 ff ff ff    	je     f0100caa <check_page_free_list+0x110>
		assert(page2pa(pp) != IOPHYSMEM);
f0100d84:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100d89:	0f 84 34 ff ff ff    	je     f0100cc3 <check_page_free_list+0x129>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100d8f:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100d94:	0f 84 42 ff ff ff    	je     f0100cdc <check_page_free_list+0x142>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100d9a:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100d9f:	0f 84 50 ff ff ff    	je     f0100cf5 <check_page_free_list+0x15b>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100da5:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100daa:	0f 87 5e ff ff ff    	ja     f0100d0e <check_page_free_list+0x174>
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100db0:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100db5:	75 9b                	jne    f0100d52 <check_page_free_list+0x1b8>
f0100db7:	68 ab 62 10 f0       	push   $0xf01062ab
f0100dbc:	68 3e 62 10 f0       	push   $0xf010623e
f0100dc1:	68 f5 02 00 00       	push   $0x2f5
f0100dc6:	68 11 62 10 f0       	push   $0xf0106211
f0100dcb:	e8 c4 f2 ff ff       	call   f0100094 <_panic>
f0100dd0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
	assert(nfree_basemem > 0);
f0100dd3:	85 db                	test   %ebx,%ebx
f0100dd5:	7e 19                	jle    f0100df0 <check_page_free_list+0x256>
	assert(nfree_extmem > 0);
f0100dd7:	85 ff                	test   %edi,%edi
f0100dd9:	7e 2e                	jle    f0100e09 <check_page_free_list+0x26f>
	cprintf("check_page_free_list() succeeded!\n");
f0100ddb:	83 ec 0c             	sub    $0xc,%esp
f0100dde:	68 00 66 10 f0       	push   $0xf0106600
f0100de3:	e8 56 2a 00 00       	call   f010383e <cprintf>
}
f0100de8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100deb:	5b                   	pop    %ebx
f0100dec:	5e                   	pop    %esi
f0100ded:	5f                   	pop    %edi
f0100dee:	5d                   	pop    %ebp
f0100def:	c3                   	ret    
	assert(nfree_basemem > 0);
f0100df0:	68 c8 62 10 f0       	push   $0xf01062c8
f0100df5:	68 3e 62 10 f0       	push   $0xf010623e
f0100dfa:	68 fd 02 00 00       	push   $0x2fd
f0100dff:	68 11 62 10 f0       	push   $0xf0106211
f0100e04:	e8 8b f2 ff ff       	call   f0100094 <_panic>
	assert(nfree_extmem > 0);
f0100e09:	68 da 62 10 f0       	push   $0xf01062da
f0100e0e:	68 3e 62 10 f0       	push   $0xf010623e
f0100e13:	68 fe 02 00 00       	push   $0x2fe
f0100e18:	68 11 62 10 f0       	push   $0xf0106211
f0100e1d:	e8 72 f2 ff ff       	call   f0100094 <_panic>
	if (!page_free_list)
f0100e22:	a1 3c 22 23 f0       	mov    0xf023223c,%eax
f0100e27:	85 c0                	test   %eax,%eax
f0100e29:	0f 84 8f fd ff ff    	je     f0100bbe <check_page_free_list+0x24>
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100e2f:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100e32:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100e35:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100e38:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100e3b:	89 c2                	mov    %eax,%edx
f0100e3d:	2b 15 90 2e 23 f0    	sub    0xf0232e90,%edx
			pagetype = (PDX(page2pa(pp)) >= pdx_limit);
f0100e43:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100e49:	0f 95 c2             	setne  %dl
f0100e4c:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100e4f:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100e53:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100e55:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100e59:	8b 00                	mov    (%eax),%eax
f0100e5b:	85 c0                	test   %eax,%eax
f0100e5d:	75 dc                	jne    f0100e3b <check_page_free_list+0x2a1>
		cprintf("end%p\n",pp);
f0100e5f:	83 ec 08             	sub    $0x8,%esp
f0100e62:	6a 00                	push   $0x0
f0100e64:	68 1d 62 10 f0       	push   $0xf010621d
f0100e69:	e8 d0 29 00 00       	call   f010383e <cprintf>
		*tp[1] = 0;
f0100e6e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100e71:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100e77:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100e7a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100e7d:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100e7f:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100e82:	a3 3c 22 23 f0       	mov    %eax,0xf023223c
f0100e87:	83 c4 10             	add    $0x10,%esp
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100e8a:	be 01 00 00 00       	mov    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100e8f:	8b 1d 3c 22 23 f0    	mov    0xf023223c,%ebx
f0100e95:	e9 4f fd ff ff       	jmp    f0100be9 <check_page_free_list+0x4f>

f0100e9a <page_init>:
{
f0100e9a:	55                   	push   %ebp
f0100e9b:	89 e5                	mov    %esp,%ebp
f0100e9d:	57                   	push   %edi
f0100e9e:	56                   	push   %esi
f0100e9f:	53                   	push   %ebx
f0100ea0:	83 ec 0c             	sub    $0xc,%esp
	pages[0].pp_ref = 1;
f0100ea3:	a1 90 2e 23 f0       	mov    0xf0232e90,%eax
f0100ea8:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
    for (i = 1; i < npages_basemem; i++) {
f0100eae:	8b 35 40 22 23 f0    	mov    0xf0232240,%esi
f0100eb4:	8b 1d 3c 22 23 f0    	mov    0xf023223c,%ebx
f0100eba:	ba 00 00 00 00       	mov    $0x0,%edx
f0100ebf:	b8 01 00 00 00       	mov    $0x1,%eax
        page_free_list = &pages[i];
f0100ec4:	bf 01 00 00 00       	mov    $0x1,%edi
    for (i = 1; i < npages_basemem; i++) {
f0100ec9:	eb 0f                	jmp    f0100eda <page_init+0x40>
			 pages[i].pp_ref = 1;
f0100ecb:	8b 0d 90 2e 23 f0    	mov    0xf0232e90,%ecx
f0100ed1:	66 c7 41 3c 01 00    	movw   $0x1,0x3c(%ecx)
    for (i = 1; i < npages_basemem; i++) {
f0100ed7:	83 c0 01             	add    $0x1,%eax
f0100eda:	39 c6                	cmp    %eax,%esi
f0100edc:	76 28                	jbe    f0100f06 <page_init+0x6c>
		if (i == mp_page) {
f0100ede:	83 f8 07             	cmp    $0x7,%eax
f0100ee1:	74 e8                	je     f0100ecb <page_init+0x31>
f0100ee3:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
        pages[i].pp_ref = 0;
f0100eea:	89 d1                	mov    %edx,%ecx
f0100eec:	03 0d 90 2e 23 f0    	add    0xf0232e90,%ecx
f0100ef2:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
        pages[i].pp_link = page_free_list;
f0100ef8:	89 19                	mov    %ebx,(%ecx)
        page_free_list = &pages[i];
f0100efa:	89 d3                	mov    %edx,%ebx
f0100efc:	03 1d 90 2e 23 f0    	add    0xf0232e90,%ebx
f0100f02:	89 fa                	mov    %edi,%edx
f0100f04:	eb d1                	jmp    f0100ed7 <page_init+0x3d>
f0100f06:	84 d2                	test   %dl,%dl
f0100f08:	74 06                	je     f0100f10 <page_init+0x76>
f0100f0a:	89 1d 3c 22 23 f0    	mov    %ebx,0xf023223c
	size_t first_free_address = PADDR(boot_alloc(0));
f0100f10:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f15:	e8 9f fb ff ff       	call   f0100ab9 <boot_alloc>
	if ((uint32_t)kva < KERNBASE)
f0100f1a:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100f1f:	76 3b                	jbe    f0100f5c <page_init+0xc2>
	return (physaddr_t)kva - KERNBASE;
f0100f21:	8d 88 00 00 00 10    	lea    0x10000000(%eax),%ecx
        pages[i].pp_ref = 1;
f0100f27:	8b 15 90 2e 23 f0    	mov    0xf0232e90,%edx
f0100f2d:	8d 82 04 05 00 00    	lea    0x504(%edx),%eax
f0100f33:	81 c2 04 08 00 00    	add    $0x804,%edx
f0100f39:	66 c7 00 01 00       	movw   $0x1,(%eax)
f0100f3e:	83 c0 08             	add    $0x8,%eax
    for (i = IOPHYSMEM/PGSIZE; i < EXTPHYSMEM/PGSIZE; i++) {
f0100f41:	39 d0                	cmp    %edx,%eax
f0100f43:	75 f4                	jne    f0100f39 <page_init+0x9f>
    for (i = first_free_address/PGSIZE; i < npages; i++) {
f0100f45:	89 c8                	mov    %ecx,%eax
f0100f47:	c1 e8 0c             	shr    $0xc,%eax
f0100f4a:	8b 1d 3c 22 23 f0    	mov    0xf023223c,%ebx
f0100f50:	ba 00 00 00 00       	mov    $0x0,%edx
f0100f55:	be 01 00 00 00       	mov    $0x1,%esi
f0100f5a:	eb 39                	jmp    f0100f95 <page_init+0xfb>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100f5c:	50                   	push   %eax
f0100f5d:	68 f8 5c 10 f0       	push   $0xf0105cf8
f0100f62:	68 5d 01 00 00       	push   $0x15d
f0100f67:	68 11 62 10 f0       	push   $0xf0106211
f0100f6c:	e8 23 f1 ff ff       	call   f0100094 <_panic>
f0100f71:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
        pages[i].pp_ref = 0;
f0100f78:	89 d1                	mov    %edx,%ecx
f0100f7a:	03 0d 90 2e 23 f0    	add    0xf0232e90,%ecx
f0100f80:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
        pages[i].pp_link = page_free_list;
f0100f86:	89 19                	mov    %ebx,(%ecx)
    for (i = first_free_address/PGSIZE; i < npages; i++) {
f0100f88:	83 c0 01             	add    $0x1,%eax
        page_free_list = &pages[i];
f0100f8b:	89 d3                	mov    %edx,%ebx
f0100f8d:	03 1d 90 2e 23 f0    	add    0xf0232e90,%ebx
f0100f93:	89 f2                	mov    %esi,%edx
    for (i = first_free_address/PGSIZE; i < npages; i++) {
f0100f95:	39 05 88 2e 23 f0    	cmp    %eax,0xf0232e88
f0100f9b:	77 d4                	ja     f0100f71 <page_init+0xd7>
f0100f9d:	84 d2                	test   %dl,%dl
f0100f9f:	74 06                	je     f0100fa7 <page_init+0x10d>
f0100fa1:	89 1d 3c 22 23 f0    	mov    %ebx,0xf023223c
}
f0100fa7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100faa:	5b                   	pop    %ebx
f0100fab:	5e                   	pop    %esi
f0100fac:	5f                   	pop    %edi
f0100fad:	5d                   	pop    %ebp
f0100fae:	c3                   	ret    

f0100faf <page_alloc>:
{
f0100faf:	55                   	push   %ebp
f0100fb0:	89 e5                	mov    %esp,%ebp
f0100fb2:	53                   	push   %ebx
f0100fb3:	83 ec 04             	sub    $0x4,%esp
	if (!page_free_list) {
f0100fb6:	8b 1d 3c 22 23 f0    	mov    0xf023223c,%ebx
f0100fbc:	85 db                	test   %ebx,%ebx
f0100fbe:	74 13                	je     f0100fd3 <page_alloc+0x24>
	page_free_list = page->pp_link;
f0100fc0:	8b 03                	mov    (%ebx),%eax
f0100fc2:	a3 3c 22 23 f0       	mov    %eax,0xf023223c
	page->pp_link = NULL;
f0100fc7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (alloc_flags & ALLOC_ZERO) {
f0100fcd:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100fd1:	75 07                	jne    f0100fda <page_alloc+0x2b>
}
f0100fd3:	89 d8                	mov    %ebx,%eax
f0100fd5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100fd8:	c9                   	leave  
f0100fd9:	c3                   	ret    
	return (pp - pages) << PGSHIFT;
f0100fda:	89 d8                	mov    %ebx,%eax
f0100fdc:	2b 05 90 2e 23 f0    	sub    0xf0232e90,%eax
f0100fe2:	c1 f8 03             	sar    $0x3,%eax
f0100fe5:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0100fe8:	89 c2                	mov    %eax,%edx
f0100fea:	c1 ea 0c             	shr    $0xc,%edx
f0100fed:	3b 15 88 2e 23 f0    	cmp    0xf0232e88,%edx
f0100ff3:	73 1a                	jae    f010100f <page_alloc+0x60>
		memset(page2kva(page), 0, PGSIZE); 
f0100ff5:	83 ec 04             	sub    $0x4,%esp
f0100ff8:	68 00 10 00 00       	push   $0x1000
f0100ffd:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f0100fff:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101004:	50                   	push   %eax
f0101005:	e8 c4 3f 00 00       	call   f0104fce <memset>
f010100a:	83 c4 10             	add    $0x10,%esp
f010100d:	eb c4                	jmp    f0100fd3 <page_alloc+0x24>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010100f:	50                   	push   %eax
f0101010:	68 d4 5c 10 f0       	push   $0xf0105cd4
f0101015:	6a 58                	push   $0x58
f0101017:	68 24 62 10 f0       	push   $0xf0106224
f010101c:	e8 73 f0 ff ff       	call   f0100094 <_panic>

f0101021 <page_free>:
{
f0101021:	55                   	push   %ebp
f0101022:	89 e5                	mov    %esp,%ebp
f0101024:	83 ec 08             	sub    $0x8,%esp
f0101027:	8b 45 08             	mov    0x8(%ebp),%eax
	if (pp->pp_ref || pp->pp_link) {
f010102a:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f010102f:	75 14                	jne    f0101045 <page_free+0x24>
f0101031:	83 38 00             	cmpl   $0x0,(%eax)
f0101034:	75 0f                	jne    f0101045 <page_free+0x24>
	pp->pp_link = page_free_list;
f0101036:	8b 15 3c 22 23 f0    	mov    0xf023223c,%edx
f010103c:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f010103e:	a3 3c 22 23 f0       	mov    %eax,0xf023223c
}
f0101043:	c9                   	leave  
f0101044:	c3                   	ret    
		panic("page_free: double check failed when dealloc page. '\n");
f0101045:	83 ec 04             	sub    $0x4,%esp
f0101048:	68 24 66 10 f0       	push   $0xf0106624
f010104d:	68 98 01 00 00       	push   $0x198
f0101052:	68 11 62 10 f0       	push   $0xf0106211
f0101057:	e8 38 f0 ff ff       	call   f0100094 <_panic>

f010105c <page_decref>:
{
f010105c:	55                   	push   %ebp
f010105d:	89 e5                	mov    %esp,%ebp
f010105f:	83 ec 08             	sub    $0x8,%esp
f0101062:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0101065:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0101069:	83 e8 01             	sub    $0x1,%eax
f010106c:	66 89 42 04          	mov    %ax,0x4(%edx)
f0101070:	66 85 c0             	test   %ax,%ax
f0101073:	74 02                	je     f0101077 <page_decref+0x1b>
}
f0101075:	c9                   	leave  
f0101076:	c3                   	ret    
		page_free(pp);
f0101077:	83 ec 0c             	sub    $0xc,%esp
f010107a:	52                   	push   %edx
f010107b:	e8 a1 ff ff ff       	call   f0101021 <page_free>
f0101080:	83 c4 10             	add    $0x10,%esp
}
f0101083:	eb f0                	jmp    f0101075 <page_decref+0x19>

f0101085 <pgdir_walk>:
{
f0101085:	55                   	push   %ebp
f0101086:	89 e5                	mov    %esp,%ebp
f0101088:	56                   	push   %esi
f0101089:	53                   	push   %ebx
f010108a:	8b 45 0c             	mov    0xc(%ebp),%eax
	uint32_t ptx = PTX(va);		
f010108d:	89 c6                	mov    %eax,%esi
f010108f:	c1 ee 0c             	shr    $0xc,%esi
f0101092:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
	uint32_t pdx = PDX(va);		
f0101098:	c1 e8 16             	shr    $0x16,%eax
	if (pgdir[pdx] & PTE_P) {
f010109b:	8d 1c 85 00 00 00 00 	lea    0x0(,%eax,4),%ebx
f01010a2:	03 5d 08             	add    0x8(%ebp),%ebx
f01010a5:	8b 03                	mov    (%ebx),%eax
f01010a7:	a8 01                	test   $0x1,%al
f01010a9:	74 36                	je     f01010e1 <pgdir_walk+0x5c>
		pgtab = KADDR(PTE_ADDR(pgdir[pdx]));
f01010ab:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f01010b0:	89 c2                	mov    %eax,%edx
f01010b2:	c1 ea 0c             	shr    $0xc,%edx
f01010b5:	39 15 88 2e 23 f0    	cmp    %edx,0xf0232e88
f01010bb:	76 0f                	jbe    f01010cc <pgdir_walk+0x47>
	return (void *)(pa + KERNBASE);
f01010bd:	2d 00 00 00 10       	sub    $0x10000000,%eax
	return &pgtab[ptx];
f01010c2:	8d 04 b0             	lea    (%eax,%esi,4),%eax
}
f01010c5:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01010c8:	5b                   	pop    %ebx
f01010c9:	5e                   	pop    %esi
f01010ca:	5d                   	pop    %ebp
f01010cb:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01010cc:	50                   	push   %eax
f01010cd:	68 d4 5c 10 f0       	push   $0xf0105cd4
f01010d2:	68 c8 01 00 00       	push   $0x1c8
f01010d7:	68 11 62 10 f0       	push   $0xf0106211
f01010dc:	e8 b3 ef ff ff       	call   f0100094 <_panic>
		if (create) {
f01010e1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01010e5:	74 50                	je     f0101137 <pgdir_walk+0xb2>
			struct PageInfo *new_pginfo = page_alloc(ALLOC_ZERO);	
f01010e7:	83 ec 0c             	sub    $0xc,%esp
f01010ea:	6a 01                	push   $0x1
f01010ec:	e8 be fe ff ff       	call   f0100faf <page_alloc>
			if (new_pginfo) {
f01010f1:	83 c4 10             	add    $0x10,%esp
f01010f4:	85 c0                	test   %eax,%eax
f01010f6:	74 46                	je     f010113e <pgdir_walk+0xb9>
				new_pginfo->pp_ref += 1;
f01010f8:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f01010fd:	2b 05 90 2e 23 f0    	sub    0xf0232e90,%eax
f0101103:	89 c2                	mov    %eax,%edx
f0101105:	c1 fa 03             	sar    $0x3,%edx
f0101108:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f010110b:	89 d0                	mov    %edx,%eax
f010110d:	c1 e8 0c             	shr    $0xc,%eax
f0101110:	3b 05 88 2e 23 f0    	cmp    0xf0232e88,%eax
f0101116:	73 0d                	jae    f0101125 <pgdir_walk+0xa0>
	return (void *)(pa + KERNBASE);
f0101118:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
				pgdir[pdx] = page2pa(new_pginfo) | PTE_P | PTE_W | PTE_U;
f010111e:	83 ca 07             	or     $0x7,%edx
f0101121:	89 13                	mov    %edx,(%ebx)
f0101123:	eb 9d                	jmp    f01010c2 <pgdir_walk+0x3d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101125:	52                   	push   %edx
f0101126:	68 d4 5c 10 f0       	push   $0xf0105cd4
f010112b:	6a 58                	push   $0x58
f010112d:	68 24 62 10 f0       	push   $0xf0106224
f0101132:	e8 5d ef ff ff       	call   f0100094 <_panic>
			return NULL;
f0101137:	b8 00 00 00 00       	mov    $0x0,%eax
f010113c:	eb 87                	jmp    f01010c5 <pgdir_walk+0x40>
			return NULL; 
f010113e:	b8 00 00 00 00       	mov    $0x0,%eax
f0101143:	eb 80                	jmp    f01010c5 <pgdir_walk+0x40>

f0101145 <boot_map_region>:
{
f0101145:	55                   	push   %ebp
f0101146:	89 e5                	mov    %esp,%ebp
f0101148:	57                   	push   %edi
f0101149:	56                   	push   %esi
f010114a:	53                   	push   %ebx
f010114b:	83 ec 1c             	sub    $0x1c,%esp
f010114e:	89 c7                	mov    %eax,%edi
f0101150:	8b 45 08             	mov    0x8(%ebp),%eax
f0101153:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0101159:	01 c1                	add    %eax,%ecx
f010115b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	for (size_t i = 0;i < pg_num; i++) {
f010115e:	89 c3                	mov    %eax,%ebx
		pte = pgdir_walk(pgdir, (void *)va, 1);		 
f0101160:	89 d6                	mov    %edx,%esi
f0101162:	29 c6                	sub    %eax,%esi
	for (size_t i = 0;i < pg_num; i++) {
f0101164:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0101167:	74 28                	je     f0101191 <boot_map_region+0x4c>
		pte = pgdir_walk(pgdir, (void *)va, 1);		 
f0101169:	83 ec 04             	sub    $0x4,%esp
f010116c:	6a 01                	push   $0x1
f010116e:	8d 04 1e             	lea    (%esi,%ebx,1),%eax
f0101171:	50                   	push   %eax
f0101172:	57                   	push   %edi
f0101173:	e8 0d ff ff ff       	call   f0101085 <pgdir_walk>
		if (!pte) {
f0101178:	83 c4 10             	add    $0x10,%esp
f010117b:	85 c0                	test   %eax,%eax
f010117d:	74 12                	je     f0101191 <boot_map_region+0x4c>
		*pte = pa | perm | PTE_P;
f010117f:	89 da                	mov    %ebx,%edx
f0101181:	0b 55 0c             	or     0xc(%ebp),%edx
f0101184:	83 ca 01             	or     $0x1,%edx
f0101187:	89 10                	mov    %edx,(%eax)
		pa += PGSIZE;
f0101189:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010118f:	eb d3                	jmp    f0101164 <boot_map_region+0x1f>
}
f0101191:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101194:	5b                   	pop    %ebx
f0101195:	5e                   	pop    %esi
f0101196:	5f                   	pop    %edi
f0101197:	5d                   	pop    %ebp
f0101198:	c3                   	ret    

f0101199 <page_lookup>:
{
f0101199:	55                   	push   %ebp
f010119a:	89 e5                	mov    %esp,%ebp
f010119c:	83 ec 0c             	sub    $0xc,%esp
	pte_t *pte = pgdir_walk(pgdir, va, 0);
f010119f:	6a 00                	push   $0x0
f01011a1:	ff 75 0c             	pushl  0xc(%ebp)
f01011a4:	ff 75 08             	pushl  0x8(%ebp)
f01011a7:	e8 d9 fe ff ff       	call   f0101085 <pgdir_walk>
	if (!pte) {
f01011ac:	83 c4 10             	add    $0x10,%esp
f01011af:	85 c0                	test   %eax,%eax
f01011b1:	74 3b                	je     f01011ee <page_lookup+0x55>
		*pte_store = pte;
f01011b3:	8b 55 10             	mov    0x10(%ebp),%edx
f01011b6:	89 02                	mov    %eax,(%edx)
	 	if (*pte) {
f01011b8:	8b 10                	mov    (%eax),%edx
	return NULL;
f01011ba:	b8 00 00 00 00       	mov    $0x0,%eax
	 	if (*pte) {
f01011bf:	85 d2                	test   %edx,%edx
f01011c1:	75 02                	jne    f01011c5 <page_lookup+0x2c>
}
f01011c3:	c9                   	leave  
f01011c4:	c3                   	ret    
f01011c5:	c1 ea 0c             	shr    $0xc,%edx
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01011c8:	39 15 88 2e 23 f0    	cmp    %edx,0xf0232e88
f01011ce:	76 0a                	jbe    f01011da <page_lookup+0x41>
		panic("pa2page called with invalid pa");
	return &pages[PGNUM(pa)];
f01011d0:	a1 90 2e 23 f0       	mov    0xf0232e90,%eax
f01011d5:	8d 04 d0             	lea    (%eax,%edx,8),%eax
			return pa2page(PTE_ADDR(*pte)); 
f01011d8:	eb e9                	jmp    f01011c3 <page_lookup+0x2a>
		panic("pa2page called with invalid pa");
f01011da:	83 ec 04             	sub    $0x4,%esp
f01011dd:	68 5c 66 10 f0       	push   $0xf010665c
f01011e2:	6a 51                	push   $0x51
f01011e4:	68 24 62 10 f0       	push   $0xf0106224
f01011e9:	e8 a6 ee ff ff       	call   f0100094 <_panic>
		 return NULL;
f01011ee:	b8 00 00 00 00       	mov    $0x0,%eax
f01011f3:	eb ce                	jmp    f01011c3 <page_lookup+0x2a>

f01011f5 <tlb_invalidate>:
{
f01011f5:	55                   	push   %ebp
f01011f6:	89 e5                	mov    %esp,%ebp
f01011f8:	83 ec 08             	sub    $0x8,%esp
	if (!curenv || curenv->env_pgdir == pgdir)
f01011fb:	e8 ce 43 00 00       	call   f01055ce <cpunum>
f0101200:	6b c0 74             	imul   $0x74,%eax,%eax
f0101203:	83 b8 28 30 23 f0 00 	cmpl   $0x0,-0xfdccfd8(%eax)
f010120a:	74 16                	je     f0101222 <tlb_invalidate+0x2d>
f010120c:	e8 bd 43 00 00       	call   f01055ce <cpunum>
f0101211:	6b c0 74             	imul   $0x74,%eax,%eax
f0101214:	8b 80 28 30 23 f0    	mov    -0xfdccfd8(%eax),%eax
f010121a:	8b 55 08             	mov    0x8(%ebp),%edx
f010121d:	39 50 60             	cmp    %edx,0x60(%eax)
f0101220:	75 06                	jne    f0101228 <tlb_invalidate+0x33>
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101222:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101225:	0f 01 38             	invlpg (%eax)
}
f0101228:	c9                   	leave  
f0101229:	c3                   	ret    

f010122a <page_remove>:
{
f010122a:	55                   	push   %ebp
f010122b:	89 e5                	mov    %esp,%ebp
f010122d:	56                   	push   %esi
f010122e:	53                   	push   %ebx
f010122f:	83 ec 14             	sub    $0x14,%esp
f0101232:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0101235:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct PageInfo *pginfo = page_lookup(pgdir, va, pte_store);
f0101238:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010123b:	50                   	push   %eax
f010123c:	56                   	push   %esi
f010123d:	53                   	push   %ebx
f010123e:	e8 56 ff ff ff       	call   f0101199 <page_lookup>
	if (pginfo) {
f0101243:	83 c4 10             	add    $0x10,%esp
f0101246:	85 c0                	test   %eax,%eax
f0101248:	74 1f                	je     f0101269 <page_remove+0x3f>
		page_decref(pginfo);
f010124a:	83 ec 0c             	sub    $0xc,%esp
f010124d:	50                   	push   %eax
f010124e:	e8 09 fe ff ff       	call   f010105c <page_decref>
		*pte = 0;	 
f0101253:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101256:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		tlb_invalidate(pgdir, va);
f010125c:	83 c4 08             	add    $0x8,%esp
f010125f:	56                   	push   %esi
f0101260:	53                   	push   %ebx
f0101261:	e8 8f ff ff ff       	call   f01011f5 <tlb_invalidate>
f0101266:	83 c4 10             	add    $0x10,%esp
}
f0101269:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010126c:	5b                   	pop    %ebx
f010126d:	5e                   	pop    %esi
f010126e:	5d                   	pop    %ebp
f010126f:	c3                   	ret    

f0101270 <page_insert>:
{
f0101270:	55                   	push   %ebp
f0101271:	89 e5                	mov    %esp,%ebp
f0101273:	57                   	push   %edi
f0101274:	56                   	push   %esi
f0101275:	53                   	push   %ebx
f0101276:	83 ec 10             	sub    $0x10,%esp
f0101279:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010127c:	8b 7d 10             	mov    0x10(%ebp),%edi
	pte_t *pte = pgdir_walk(pgdir, va, 1);	
f010127f:	6a 01                	push   $0x1
f0101281:	57                   	push   %edi
f0101282:	ff 75 08             	pushl  0x8(%ebp)
f0101285:	e8 fb fd ff ff       	call   f0101085 <pgdir_walk>
	if (!pte) {
f010128a:	83 c4 10             	add    $0x10,%esp
f010128d:	85 c0                	test   %eax,%eax
f010128f:	74 3e                	je     f01012cf <page_insert+0x5f>
f0101291:	89 c6                	mov    %eax,%esi
	pp->pp_ref++;
f0101293:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
	if (*pte & PTE_P) {
f0101298:	f6 00 01             	testb  $0x1,(%eax)
f010129b:	75 21                	jne    f01012be <page_insert+0x4e>
	return (pp - pages) << PGSHIFT;
f010129d:	2b 1d 90 2e 23 f0    	sub    0xf0232e90,%ebx
f01012a3:	c1 fb 03             	sar    $0x3,%ebx
f01012a6:	c1 e3 0c             	shl    $0xc,%ebx
	*pte = page2pa(pp) | perm | PTE_P;
f01012a9:	0b 5d 14             	or     0x14(%ebp),%ebx
f01012ac:	83 cb 01             	or     $0x1,%ebx
f01012af:	89 1e                	mov    %ebx,(%esi)
	return 0;
f01012b1:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01012b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01012b9:	5b                   	pop    %ebx
f01012ba:	5e                   	pop    %esi
f01012bb:	5f                   	pop    %edi
f01012bc:	5d                   	pop    %ebp
f01012bd:	c3                   	ret    
		 page_remove(pgdir, va);
f01012be:	83 ec 08             	sub    $0x8,%esp
f01012c1:	57                   	push   %edi
f01012c2:	ff 75 08             	pushl  0x8(%ebp)
f01012c5:	e8 60 ff ff ff       	call   f010122a <page_remove>
f01012ca:	83 c4 10             	add    $0x10,%esp
f01012cd:	eb ce                	jmp    f010129d <page_insert+0x2d>
		 return -E_NO_MEM;
f01012cf:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01012d4:	eb e0                	jmp    f01012b6 <page_insert+0x46>

f01012d6 <mmio_map_region>:
{
f01012d6:	55                   	push   %ebp
f01012d7:	89 e5                	mov    %esp,%ebp
f01012d9:	53                   	push   %ebx
f01012da:	83 ec 04             	sub    $0x4,%esp
    size_t rounded_size = ROUNDUP(size, PGSIZE);
f01012dd:	8b 45 0c             	mov    0xc(%ebp),%eax
f01012e0:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
f01012e6:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    if (base + rounded_size > MMIOLIM || base + rounded_size < base) panic("memory overflow\n ");
f01012ec:	8b 15 00 23 12 f0    	mov    0xf0122300,%edx
f01012f2:	89 d0                	mov    %edx,%eax
f01012f4:	01 d8                	add    %ebx,%eax
f01012f6:	72 2d                	jb     f0101325 <mmio_map_region+0x4f>
f01012f8:	3d 00 00 c0 ef       	cmp    $0xefc00000,%eax
f01012fd:	77 26                	ja     f0101325 <mmio_map_region+0x4f>
    boot_map_region(kern_pgdir, base, rounded_size, pa, PTE_W|PTE_PCD|PTE_PWT);
f01012ff:	83 ec 08             	sub    $0x8,%esp
f0101302:	6a 1a                	push   $0x1a
f0101304:	ff 75 08             	pushl  0x8(%ebp)
f0101307:	89 d9                	mov    %ebx,%ecx
f0101309:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f010130e:	e8 32 fe ff ff       	call   f0101145 <boot_map_region>
    uintptr_t return_base = base;
f0101313:	a1 00 23 12 f0       	mov    0xf0122300,%eax
    base += rounded_size;
f0101318:	01 c3                	add    %eax,%ebx
f010131a:	89 1d 00 23 12 f0    	mov    %ebx,0xf0122300
}
f0101320:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101323:	c9                   	leave  
f0101324:	c3                   	ret    
    if (base + rounded_size > MMIOLIM || base + rounded_size < base) panic("memory overflow\n ");
f0101325:	83 ec 04             	sub    $0x4,%esp
f0101328:	68 eb 62 10 f0       	push   $0xf01062eb
f010132d:	68 86 02 00 00       	push   $0x286
f0101332:	68 11 62 10 f0       	push   $0xf0106211
f0101337:	e8 58 ed ff ff       	call   f0100094 <_panic>

f010133c <mem_init>:
{
f010133c:	55                   	push   %ebp
f010133d:	89 e5                	mov    %esp,%ebp
f010133f:	57                   	push   %edi
f0101340:	56                   	push   %esi
f0101341:	53                   	push   %ebx
f0101342:	83 ec 3c             	sub    $0x3c,%esp
	basemem = nvram_read(NVRAM_BASELO);
f0101345:	b8 15 00 00 00       	mov    $0x15,%eax
f010134a:	e8 be f7 ff ff       	call   f0100b0d <nvram_read>
f010134f:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f0101351:	b8 17 00 00 00       	mov    $0x17,%eax
f0101356:	e8 b2 f7 ff ff       	call   f0100b0d <nvram_read>
f010135b:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f010135d:	b8 34 00 00 00       	mov    $0x34,%eax
f0101362:	e8 a6 f7 ff ff       	call   f0100b0d <nvram_read>
	if (ext16mem)
f0101367:	c1 e0 06             	shl    $0x6,%eax
f010136a:	0f 84 ea 00 00 00    	je     f010145a <mem_init+0x11e>
		totalmem = 16 * 1024 + ext16mem;
f0101370:	05 00 40 00 00       	add    $0x4000,%eax
	npages = totalmem / (PGSIZE / 1024);
f0101375:	89 c2                	mov    %eax,%edx
f0101377:	c1 ea 02             	shr    $0x2,%edx
f010137a:	89 15 88 2e 23 f0    	mov    %edx,0xf0232e88
	npages_basemem = basemem / (PGSIZE / 1024);
f0101380:	89 da                	mov    %ebx,%edx
f0101382:	c1 ea 02             	shr    $0x2,%edx
f0101385:	89 15 40 22 23 f0    	mov    %edx,0xf0232240
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010138b:	89 c2                	mov    %eax,%edx
f010138d:	29 da                	sub    %ebx,%edx
f010138f:	52                   	push   %edx
f0101390:	53                   	push   %ebx
f0101391:	50                   	push   %eax
f0101392:	68 7c 66 10 f0       	push   $0xf010667c
f0101397:	e8 a2 24 00 00       	call   f010383e <cprintf>
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f010139c:	b8 00 10 00 00       	mov    $0x1000,%eax
f01013a1:	e8 13 f7 ff ff       	call   f0100ab9 <boot_alloc>
f01013a6:	a3 8c 2e 23 f0       	mov    %eax,0xf0232e8c
	memset(kern_pgdir, 0, PGSIZE);
f01013ab:	83 c4 0c             	add    $0xc,%esp
f01013ae:	68 00 10 00 00       	push   $0x1000
f01013b3:	6a 00                	push   $0x0
f01013b5:	50                   	push   %eax
f01013b6:	e8 13 3c 00 00       	call   f0104fce <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01013bb:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f01013c0:	83 c4 10             	add    $0x10,%esp
f01013c3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01013c8:	0f 86 9c 00 00 00    	jbe    f010146a <mem_init+0x12e>
	return (physaddr_t)kva - KERNBASE;
f01013ce:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01013d4:	83 ca 05             	or     $0x5,%edx
f01013d7:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	pages = (struct PageInfo*) boot_alloc(npages * sizeof(struct PageInfo));
f01013dd:	a1 88 2e 23 f0       	mov    0xf0232e88,%eax
f01013e2:	c1 e0 03             	shl    $0x3,%eax
f01013e5:	e8 cf f6 ff ff       	call   f0100ab9 <boot_alloc>
f01013ea:	a3 90 2e 23 f0       	mov    %eax,0xf0232e90
	memset(pages, 0, npages * sizeof(struct PageInfo));
f01013ef:	83 ec 04             	sub    $0x4,%esp
f01013f2:	8b 0d 88 2e 23 f0    	mov    0xf0232e88,%ecx
f01013f8:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f01013ff:	52                   	push   %edx
f0101400:	6a 00                	push   $0x0
f0101402:	50                   	push   %eax
f0101403:	e8 c6 3b 00 00       	call   f0104fce <memset>
	envs = (struct Env*) boot_alloc(NENV * sizeof(struct Env));
f0101408:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f010140d:	e8 a7 f6 ff ff       	call   f0100ab9 <boot_alloc>
f0101412:	a3 44 22 23 f0       	mov    %eax,0xf0232244
	memset(envs, 0, NENV * sizeof(struct Env));
f0101417:	83 c4 0c             	add    $0xc,%esp
f010141a:	68 00 f0 01 00       	push   $0x1f000
f010141f:	6a 00                	push   $0x0
f0101421:	50                   	push   %eax
f0101422:	e8 a7 3b 00 00       	call   f0104fce <memset>
	page_init();
f0101427:	e8 6e fa ff ff       	call   f0100e9a <page_init>
	check_page_free_list(1);
f010142c:	b8 01 00 00 00       	mov    $0x1,%eax
f0101431:	e8 64 f7 ff ff       	call   f0100b9a <check_page_free_list>
	if (!pages)
f0101436:	83 c4 10             	add    $0x10,%esp
f0101439:	83 3d 90 2e 23 f0 00 	cmpl   $0x0,0xf0232e90
f0101440:	74 3d                	je     f010147f <mem_init+0x143>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101442:	a1 3c 22 23 f0       	mov    0xf023223c,%eax
f0101447:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f010144e:	85 c0                	test   %eax,%eax
f0101450:	74 44                	je     f0101496 <mem_init+0x15a>
		++nfree;
f0101452:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101456:	8b 00                	mov    (%eax),%eax
f0101458:	eb f4                	jmp    f010144e <mem_init+0x112>
		totalmem = 1 * 1024 + extmem;
f010145a:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f0101460:	85 f6                	test   %esi,%esi
f0101462:	0f 44 c3             	cmove  %ebx,%eax
f0101465:	e9 0b ff ff ff       	jmp    f0101375 <mem_init+0x39>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010146a:	50                   	push   %eax
f010146b:	68 f8 5c 10 f0       	push   $0xf0105cf8
f0101470:	68 a4 00 00 00       	push   $0xa4
f0101475:	68 11 62 10 f0       	push   $0xf0106211
f010147a:	e8 15 ec ff ff       	call   f0100094 <_panic>
		panic("'pages' is a null pointer!");
f010147f:	83 ec 04             	sub    $0x4,%esp
f0101482:	68 fd 62 10 f0       	push   $0xf01062fd
f0101487:	68 11 03 00 00       	push   $0x311
f010148c:	68 11 62 10 f0       	push   $0xf0106211
f0101491:	e8 fe eb ff ff       	call   f0100094 <_panic>
	assert((pp0 = page_alloc(0)));
f0101496:	83 ec 0c             	sub    $0xc,%esp
f0101499:	6a 00                	push   $0x0
f010149b:	e8 0f fb ff ff       	call   f0100faf <page_alloc>
f01014a0:	89 c3                	mov    %eax,%ebx
f01014a2:	83 c4 10             	add    $0x10,%esp
f01014a5:	85 c0                	test   %eax,%eax
f01014a7:	0f 84 00 02 00 00    	je     f01016ad <mem_init+0x371>
	assert((pp1 = page_alloc(0)));
f01014ad:	83 ec 0c             	sub    $0xc,%esp
f01014b0:	6a 00                	push   $0x0
f01014b2:	e8 f8 fa ff ff       	call   f0100faf <page_alloc>
f01014b7:	89 c6                	mov    %eax,%esi
f01014b9:	83 c4 10             	add    $0x10,%esp
f01014bc:	85 c0                	test   %eax,%eax
f01014be:	0f 84 02 02 00 00    	je     f01016c6 <mem_init+0x38a>
	assert((pp2 = page_alloc(0)));
f01014c4:	83 ec 0c             	sub    $0xc,%esp
f01014c7:	6a 00                	push   $0x0
f01014c9:	e8 e1 fa ff ff       	call   f0100faf <page_alloc>
f01014ce:	89 c7                	mov    %eax,%edi
f01014d0:	83 c4 10             	add    $0x10,%esp
f01014d3:	85 c0                	test   %eax,%eax
f01014d5:	0f 84 04 02 00 00    	je     f01016df <mem_init+0x3a3>
	assert(pp1 && pp1 != pp0);
f01014db:	39 f3                	cmp    %esi,%ebx
f01014dd:	0f 84 15 02 00 00    	je     f01016f8 <mem_init+0x3bc>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01014e3:	39 c6                	cmp    %eax,%esi
f01014e5:	0f 84 26 02 00 00    	je     f0101711 <mem_init+0x3d5>
f01014eb:	39 c3                	cmp    %eax,%ebx
f01014ed:	0f 84 1e 02 00 00    	je     f0101711 <mem_init+0x3d5>
	return (pp - pages) << PGSHIFT;
f01014f3:	8b 0d 90 2e 23 f0    	mov    0xf0232e90,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f01014f9:	8b 15 88 2e 23 f0    	mov    0xf0232e88,%edx
f01014ff:	c1 e2 0c             	shl    $0xc,%edx
f0101502:	89 d8                	mov    %ebx,%eax
f0101504:	29 c8                	sub    %ecx,%eax
f0101506:	c1 f8 03             	sar    $0x3,%eax
f0101509:	c1 e0 0c             	shl    $0xc,%eax
f010150c:	39 d0                	cmp    %edx,%eax
f010150e:	0f 83 16 02 00 00    	jae    f010172a <mem_init+0x3ee>
f0101514:	89 f0                	mov    %esi,%eax
f0101516:	29 c8                	sub    %ecx,%eax
f0101518:	c1 f8 03             	sar    $0x3,%eax
f010151b:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp1) < npages*PGSIZE);
f010151e:	39 c2                	cmp    %eax,%edx
f0101520:	0f 86 1d 02 00 00    	jbe    f0101743 <mem_init+0x407>
f0101526:	89 f8                	mov    %edi,%eax
f0101528:	29 c8                	sub    %ecx,%eax
f010152a:	c1 f8 03             	sar    $0x3,%eax
f010152d:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp2) < npages*PGSIZE);
f0101530:	39 c2                	cmp    %eax,%edx
f0101532:	0f 86 24 02 00 00    	jbe    f010175c <mem_init+0x420>
	fl = page_free_list;
f0101538:	a1 3c 22 23 f0       	mov    0xf023223c,%eax
f010153d:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101540:	c7 05 3c 22 23 f0 00 	movl   $0x0,0xf023223c
f0101547:	00 00 00 
	assert(!page_alloc(0));
f010154a:	83 ec 0c             	sub    $0xc,%esp
f010154d:	6a 00                	push   $0x0
f010154f:	e8 5b fa ff ff       	call   f0100faf <page_alloc>
f0101554:	83 c4 10             	add    $0x10,%esp
f0101557:	85 c0                	test   %eax,%eax
f0101559:	0f 85 16 02 00 00    	jne    f0101775 <mem_init+0x439>
	page_free(pp0);
f010155f:	83 ec 0c             	sub    $0xc,%esp
f0101562:	53                   	push   %ebx
f0101563:	e8 b9 fa ff ff       	call   f0101021 <page_free>
	page_free(pp1);
f0101568:	89 34 24             	mov    %esi,(%esp)
f010156b:	e8 b1 fa ff ff       	call   f0101021 <page_free>
	page_free(pp2);
f0101570:	89 3c 24             	mov    %edi,(%esp)
f0101573:	e8 a9 fa ff ff       	call   f0101021 <page_free>
	assert((pp0 = page_alloc(0)));
f0101578:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010157f:	e8 2b fa ff ff       	call   f0100faf <page_alloc>
f0101584:	89 c3                	mov    %eax,%ebx
f0101586:	83 c4 10             	add    $0x10,%esp
f0101589:	85 c0                	test   %eax,%eax
f010158b:	0f 84 fd 01 00 00    	je     f010178e <mem_init+0x452>
	assert((pp1 = page_alloc(0)));
f0101591:	83 ec 0c             	sub    $0xc,%esp
f0101594:	6a 00                	push   $0x0
f0101596:	e8 14 fa ff ff       	call   f0100faf <page_alloc>
f010159b:	89 c6                	mov    %eax,%esi
f010159d:	83 c4 10             	add    $0x10,%esp
f01015a0:	85 c0                	test   %eax,%eax
f01015a2:	0f 84 ff 01 00 00    	je     f01017a7 <mem_init+0x46b>
	assert((pp2 = page_alloc(0)));
f01015a8:	83 ec 0c             	sub    $0xc,%esp
f01015ab:	6a 00                	push   $0x0
f01015ad:	e8 fd f9 ff ff       	call   f0100faf <page_alloc>
f01015b2:	89 c7                	mov    %eax,%edi
f01015b4:	83 c4 10             	add    $0x10,%esp
f01015b7:	85 c0                	test   %eax,%eax
f01015b9:	0f 84 01 02 00 00    	je     f01017c0 <mem_init+0x484>
	assert(pp1 && pp1 != pp0);
f01015bf:	39 f3                	cmp    %esi,%ebx
f01015c1:	0f 84 12 02 00 00    	je     f01017d9 <mem_init+0x49d>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01015c7:	39 c3                	cmp    %eax,%ebx
f01015c9:	0f 84 23 02 00 00    	je     f01017f2 <mem_init+0x4b6>
f01015cf:	39 c6                	cmp    %eax,%esi
f01015d1:	0f 84 1b 02 00 00    	je     f01017f2 <mem_init+0x4b6>
	assert(!page_alloc(0));
f01015d7:	83 ec 0c             	sub    $0xc,%esp
f01015da:	6a 00                	push   $0x0
f01015dc:	e8 ce f9 ff ff       	call   f0100faf <page_alloc>
f01015e1:	83 c4 10             	add    $0x10,%esp
f01015e4:	85 c0                	test   %eax,%eax
f01015e6:	0f 85 1f 02 00 00    	jne    f010180b <mem_init+0x4cf>
f01015ec:	89 d8                	mov    %ebx,%eax
f01015ee:	2b 05 90 2e 23 f0    	sub    0xf0232e90,%eax
f01015f4:	c1 f8 03             	sar    $0x3,%eax
f01015f7:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f01015fa:	89 c2                	mov    %eax,%edx
f01015fc:	c1 ea 0c             	shr    $0xc,%edx
f01015ff:	3b 15 88 2e 23 f0    	cmp    0xf0232e88,%edx
f0101605:	0f 83 19 02 00 00    	jae    f0101824 <mem_init+0x4e8>
	memset(page2kva(pp0), 1, PGSIZE);
f010160b:	83 ec 04             	sub    $0x4,%esp
f010160e:	68 00 10 00 00       	push   $0x1000
f0101613:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0101615:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010161a:	50                   	push   %eax
f010161b:	e8 ae 39 00 00       	call   f0104fce <memset>
	page_free(pp0);
f0101620:	89 1c 24             	mov    %ebx,(%esp)
f0101623:	e8 f9 f9 ff ff       	call   f0101021 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101628:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010162f:	e8 7b f9 ff ff       	call   f0100faf <page_alloc>
f0101634:	83 c4 10             	add    $0x10,%esp
f0101637:	85 c0                	test   %eax,%eax
f0101639:	0f 84 f7 01 00 00    	je     f0101836 <mem_init+0x4fa>
	assert(pp && pp0 == pp);
f010163f:	39 c3                	cmp    %eax,%ebx
f0101641:	0f 85 08 02 00 00    	jne    f010184f <mem_init+0x513>
	return (pp - pages) << PGSHIFT;
f0101647:	2b 05 90 2e 23 f0    	sub    0xf0232e90,%eax
f010164d:	c1 f8 03             	sar    $0x3,%eax
f0101650:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0101653:	89 c2                	mov    %eax,%edx
f0101655:	c1 ea 0c             	shr    $0xc,%edx
f0101658:	3b 15 88 2e 23 f0    	cmp    0xf0232e88,%edx
f010165e:	0f 83 04 02 00 00    	jae    f0101868 <mem_init+0x52c>
	return (void *)(pa + KERNBASE);
f0101664:	8d 90 00 00 00 f0    	lea    -0x10000000(%eax),%edx
f010166a:	2d 00 f0 ff 0f       	sub    $0xffff000,%eax
		assert(c[i] == 0);
f010166f:	80 3a 00             	cmpb   $0x0,(%edx)
f0101672:	0f 85 02 02 00 00    	jne    f010187a <mem_init+0x53e>
f0101678:	83 c2 01             	add    $0x1,%edx
	for (i = 0; i < PGSIZE; i++)
f010167b:	39 c2                	cmp    %eax,%edx
f010167d:	75 f0                	jne    f010166f <mem_init+0x333>
	page_free_list = fl;
f010167f:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101682:	a3 3c 22 23 f0       	mov    %eax,0xf023223c
	page_free(pp0);
f0101687:	83 ec 0c             	sub    $0xc,%esp
f010168a:	53                   	push   %ebx
f010168b:	e8 91 f9 ff ff       	call   f0101021 <page_free>
	page_free(pp1);
f0101690:	89 34 24             	mov    %esi,(%esp)
f0101693:	e8 89 f9 ff ff       	call   f0101021 <page_free>
	page_free(pp2);
f0101698:	89 3c 24             	mov    %edi,(%esp)
f010169b:	e8 81 f9 ff ff       	call   f0101021 <page_free>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01016a0:	a1 3c 22 23 f0       	mov    0xf023223c,%eax
f01016a5:	83 c4 10             	add    $0x10,%esp
f01016a8:	e9 ec 01 00 00       	jmp    f0101899 <mem_init+0x55d>
	assert((pp0 = page_alloc(0)));
f01016ad:	68 18 63 10 f0       	push   $0xf0106318
f01016b2:	68 3e 62 10 f0       	push   $0xf010623e
f01016b7:	68 19 03 00 00       	push   $0x319
f01016bc:	68 11 62 10 f0       	push   $0xf0106211
f01016c1:	e8 ce e9 ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f01016c6:	68 2e 63 10 f0       	push   $0xf010632e
f01016cb:	68 3e 62 10 f0       	push   $0xf010623e
f01016d0:	68 1a 03 00 00       	push   $0x31a
f01016d5:	68 11 62 10 f0       	push   $0xf0106211
f01016da:	e8 b5 e9 ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f01016df:	68 44 63 10 f0       	push   $0xf0106344
f01016e4:	68 3e 62 10 f0       	push   $0xf010623e
f01016e9:	68 1b 03 00 00       	push   $0x31b
f01016ee:	68 11 62 10 f0       	push   $0xf0106211
f01016f3:	e8 9c e9 ff ff       	call   f0100094 <_panic>
	assert(pp1 && pp1 != pp0);
f01016f8:	68 5a 63 10 f0       	push   $0xf010635a
f01016fd:	68 3e 62 10 f0       	push   $0xf010623e
f0101702:	68 1e 03 00 00       	push   $0x31e
f0101707:	68 11 62 10 f0       	push   $0xf0106211
f010170c:	e8 83 e9 ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101711:	68 b8 66 10 f0       	push   $0xf01066b8
f0101716:	68 3e 62 10 f0       	push   $0xf010623e
f010171b:	68 1f 03 00 00       	push   $0x31f
f0101720:	68 11 62 10 f0       	push   $0xf0106211
f0101725:	e8 6a e9 ff ff       	call   f0100094 <_panic>
	assert(page2pa(pp0) < npages*PGSIZE);
f010172a:	68 6c 63 10 f0       	push   $0xf010636c
f010172f:	68 3e 62 10 f0       	push   $0xf010623e
f0101734:	68 20 03 00 00       	push   $0x320
f0101739:	68 11 62 10 f0       	push   $0xf0106211
f010173e:	e8 51 e9 ff ff       	call   f0100094 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0101743:	68 89 63 10 f0       	push   $0xf0106389
f0101748:	68 3e 62 10 f0       	push   $0xf010623e
f010174d:	68 21 03 00 00       	push   $0x321
f0101752:	68 11 62 10 f0       	push   $0xf0106211
f0101757:	e8 38 e9 ff ff       	call   f0100094 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f010175c:	68 a6 63 10 f0       	push   $0xf01063a6
f0101761:	68 3e 62 10 f0       	push   $0xf010623e
f0101766:	68 22 03 00 00       	push   $0x322
f010176b:	68 11 62 10 f0       	push   $0xf0106211
f0101770:	e8 1f e9 ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f0101775:	68 c3 63 10 f0       	push   $0xf01063c3
f010177a:	68 3e 62 10 f0       	push   $0xf010623e
f010177f:	68 29 03 00 00       	push   $0x329
f0101784:	68 11 62 10 f0       	push   $0xf0106211
f0101789:	e8 06 e9 ff ff       	call   f0100094 <_panic>
	assert((pp0 = page_alloc(0)));
f010178e:	68 18 63 10 f0       	push   $0xf0106318
f0101793:	68 3e 62 10 f0       	push   $0xf010623e
f0101798:	68 30 03 00 00       	push   $0x330
f010179d:	68 11 62 10 f0       	push   $0xf0106211
f01017a2:	e8 ed e8 ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f01017a7:	68 2e 63 10 f0       	push   $0xf010632e
f01017ac:	68 3e 62 10 f0       	push   $0xf010623e
f01017b1:	68 31 03 00 00       	push   $0x331
f01017b6:	68 11 62 10 f0       	push   $0xf0106211
f01017bb:	e8 d4 e8 ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f01017c0:	68 44 63 10 f0       	push   $0xf0106344
f01017c5:	68 3e 62 10 f0       	push   $0xf010623e
f01017ca:	68 32 03 00 00       	push   $0x332
f01017cf:	68 11 62 10 f0       	push   $0xf0106211
f01017d4:	e8 bb e8 ff ff       	call   f0100094 <_panic>
	assert(pp1 && pp1 != pp0);
f01017d9:	68 5a 63 10 f0       	push   $0xf010635a
f01017de:	68 3e 62 10 f0       	push   $0xf010623e
f01017e3:	68 34 03 00 00       	push   $0x334
f01017e8:	68 11 62 10 f0       	push   $0xf0106211
f01017ed:	e8 a2 e8 ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01017f2:	68 b8 66 10 f0       	push   $0xf01066b8
f01017f7:	68 3e 62 10 f0       	push   $0xf010623e
f01017fc:	68 35 03 00 00       	push   $0x335
f0101801:	68 11 62 10 f0       	push   $0xf0106211
f0101806:	e8 89 e8 ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f010180b:	68 c3 63 10 f0       	push   $0xf01063c3
f0101810:	68 3e 62 10 f0       	push   $0xf010623e
f0101815:	68 36 03 00 00       	push   $0x336
f010181a:	68 11 62 10 f0       	push   $0xf0106211
f010181f:	e8 70 e8 ff ff       	call   f0100094 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101824:	50                   	push   %eax
f0101825:	68 d4 5c 10 f0       	push   $0xf0105cd4
f010182a:	6a 58                	push   $0x58
f010182c:	68 24 62 10 f0       	push   $0xf0106224
f0101831:	e8 5e e8 ff ff       	call   f0100094 <_panic>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101836:	68 d2 63 10 f0       	push   $0xf01063d2
f010183b:	68 3e 62 10 f0       	push   $0xf010623e
f0101840:	68 3b 03 00 00       	push   $0x33b
f0101845:	68 11 62 10 f0       	push   $0xf0106211
f010184a:	e8 45 e8 ff ff       	call   f0100094 <_panic>
	assert(pp && pp0 == pp);
f010184f:	68 f0 63 10 f0       	push   $0xf01063f0
f0101854:	68 3e 62 10 f0       	push   $0xf010623e
f0101859:	68 3c 03 00 00       	push   $0x33c
f010185e:	68 11 62 10 f0       	push   $0xf0106211
f0101863:	e8 2c e8 ff ff       	call   f0100094 <_panic>
f0101868:	50                   	push   %eax
f0101869:	68 d4 5c 10 f0       	push   $0xf0105cd4
f010186e:	6a 58                	push   $0x58
f0101870:	68 24 62 10 f0       	push   $0xf0106224
f0101875:	e8 1a e8 ff ff       	call   f0100094 <_panic>
		assert(c[i] == 0);
f010187a:	68 00 64 10 f0       	push   $0xf0106400
f010187f:	68 3e 62 10 f0       	push   $0xf010623e
f0101884:	68 3f 03 00 00       	push   $0x33f
f0101889:	68 11 62 10 f0       	push   $0xf0106211
f010188e:	e8 01 e8 ff ff       	call   f0100094 <_panic>
		--nfree;
f0101893:	83 6d d4 01          	subl   $0x1,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101897:	8b 00                	mov    (%eax),%eax
f0101899:	85 c0                	test   %eax,%eax
f010189b:	75 f6                	jne    f0101893 <mem_init+0x557>
	assert(nfree == 0);
f010189d:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f01018a1:	0f 85 65 09 00 00    	jne    f010220c <mem_init+0xed0>
	cprintf("check_page_alloc() succeeded!\n");
f01018a7:	83 ec 0c             	sub    $0xc,%esp
f01018aa:	68 d8 66 10 f0       	push   $0xf01066d8
f01018af:	e8 8a 1f 00 00       	call   f010383e <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01018b4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01018bb:	e8 ef f6 ff ff       	call   f0100faf <page_alloc>
f01018c0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01018c3:	83 c4 10             	add    $0x10,%esp
f01018c6:	85 c0                	test   %eax,%eax
f01018c8:	0f 84 57 09 00 00    	je     f0102225 <mem_init+0xee9>
	assert((pp1 = page_alloc(0)));
f01018ce:	83 ec 0c             	sub    $0xc,%esp
f01018d1:	6a 00                	push   $0x0
f01018d3:	e8 d7 f6 ff ff       	call   f0100faf <page_alloc>
f01018d8:	89 c7                	mov    %eax,%edi
f01018da:	83 c4 10             	add    $0x10,%esp
f01018dd:	85 c0                	test   %eax,%eax
f01018df:	0f 84 59 09 00 00    	je     f010223e <mem_init+0xf02>
	assert((pp2 = page_alloc(0)));
f01018e5:	83 ec 0c             	sub    $0xc,%esp
f01018e8:	6a 00                	push   $0x0
f01018ea:	e8 c0 f6 ff ff       	call   f0100faf <page_alloc>
f01018ef:	89 c3                	mov    %eax,%ebx
f01018f1:	83 c4 10             	add    $0x10,%esp
f01018f4:	85 c0                	test   %eax,%eax
f01018f6:	0f 84 5b 09 00 00    	je     f0102257 <mem_init+0xf1b>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01018fc:	39 7d d4             	cmp    %edi,-0x2c(%ebp)
f01018ff:	0f 84 6b 09 00 00    	je     f0102270 <mem_init+0xf34>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101905:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101908:	0f 84 7b 09 00 00    	je     f0102289 <mem_init+0xf4d>
f010190e:	39 c7                	cmp    %eax,%edi
f0101910:	0f 84 73 09 00 00    	je     f0102289 <mem_init+0xf4d>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101916:	a1 3c 22 23 f0       	mov    0xf023223c,%eax
f010191b:	89 45 cc             	mov    %eax,-0x34(%ebp)
	page_free_list = 0;
f010191e:	c7 05 3c 22 23 f0 00 	movl   $0x0,0xf023223c
f0101925:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101928:	83 ec 0c             	sub    $0xc,%esp
f010192b:	6a 00                	push   $0x0
f010192d:	e8 7d f6 ff ff       	call   f0100faf <page_alloc>
f0101932:	83 c4 10             	add    $0x10,%esp
f0101935:	85 c0                	test   %eax,%eax
f0101937:	0f 85 65 09 00 00    	jne    f01022a2 <mem_init+0xf66>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f010193d:	83 ec 04             	sub    $0x4,%esp
f0101940:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101943:	50                   	push   %eax
f0101944:	6a 00                	push   $0x0
f0101946:	ff 35 8c 2e 23 f0    	pushl  0xf0232e8c
f010194c:	e8 48 f8 ff ff       	call   f0101199 <page_lookup>
f0101951:	83 c4 10             	add    $0x10,%esp
f0101954:	85 c0                	test   %eax,%eax
f0101956:	0f 85 5f 09 00 00    	jne    f01022bb <mem_init+0xf7f>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f010195c:	6a 02                	push   $0x2
f010195e:	6a 00                	push   $0x0
f0101960:	57                   	push   %edi
f0101961:	ff 35 8c 2e 23 f0    	pushl  0xf0232e8c
f0101967:	e8 04 f9 ff ff       	call   f0101270 <page_insert>
f010196c:	83 c4 10             	add    $0x10,%esp
f010196f:	85 c0                	test   %eax,%eax
f0101971:	0f 89 5d 09 00 00    	jns    f01022d4 <mem_init+0xf98>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101977:	83 ec 0c             	sub    $0xc,%esp
f010197a:	ff 75 d4             	pushl  -0x2c(%ebp)
f010197d:	e8 9f f6 ff ff       	call   f0101021 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101982:	6a 02                	push   $0x2
f0101984:	6a 00                	push   $0x0
f0101986:	57                   	push   %edi
f0101987:	ff 35 8c 2e 23 f0    	pushl  0xf0232e8c
f010198d:	e8 de f8 ff ff       	call   f0101270 <page_insert>
f0101992:	83 c4 20             	add    $0x20,%esp
f0101995:	85 c0                	test   %eax,%eax
f0101997:	0f 85 50 09 00 00    	jne    f01022ed <mem_init+0xfb1>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010199d:	8b 35 8c 2e 23 f0    	mov    0xf0232e8c,%esi
	return (pp - pages) << PGSHIFT;
f01019a3:	8b 0d 90 2e 23 f0    	mov    0xf0232e90,%ecx
f01019a9:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f01019ac:	8b 16                	mov    (%esi),%edx
f01019ae:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01019b4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01019b7:	29 c8                	sub    %ecx,%eax
f01019b9:	c1 f8 03             	sar    $0x3,%eax
f01019bc:	c1 e0 0c             	shl    $0xc,%eax
f01019bf:	39 c2                	cmp    %eax,%edx
f01019c1:	0f 85 3f 09 00 00    	jne    f0102306 <mem_init+0xfca>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f01019c7:	ba 00 00 00 00       	mov    $0x0,%edx
f01019cc:	89 f0                	mov    %esi,%eax
f01019ce:	e8 63 f1 ff ff       	call   f0100b36 <check_va2pa>
f01019d3:	89 fa                	mov    %edi,%edx
f01019d5:	2b 55 d0             	sub    -0x30(%ebp),%edx
f01019d8:	c1 fa 03             	sar    $0x3,%edx
f01019db:	c1 e2 0c             	shl    $0xc,%edx
f01019de:	39 d0                	cmp    %edx,%eax
f01019e0:	0f 85 39 09 00 00    	jne    f010231f <mem_init+0xfe3>
	assert(pp1->pp_ref == 1);
f01019e6:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01019eb:	0f 85 47 09 00 00    	jne    f0102338 <mem_init+0xffc>
	assert(pp0->pp_ref == 1);
f01019f1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01019f4:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f01019f9:	0f 85 52 09 00 00    	jne    f0102351 <mem_init+0x1015>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01019ff:	6a 02                	push   $0x2
f0101a01:	68 00 10 00 00       	push   $0x1000
f0101a06:	53                   	push   %ebx
f0101a07:	56                   	push   %esi
f0101a08:	e8 63 f8 ff ff       	call   f0101270 <page_insert>
f0101a0d:	83 c4 10             	add    $0x10,%esp
f0101a10:	85 c0                	test   %eax,%eax
f0101a12:	0f 85 52 09 00 00    	jne    f010236a <mem_init+0x102e>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101a18:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101a1d:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f0101a22:	e8 0f f1 ff ff       	call   f0100b36 <check_va2pa>
f0101a27:	89 da                	mov    %ebx,%edx
f0101a29:	2b 15 90 2e 23 f0    	sub    0xf0232e90,%edx
f0101a2f:	c1 fa 03             	sar    $0x3,%edx
f0101a32:	c1 e2 0c             	shl    $0xc,%edx
f0101a35:	39 d0                	cmp    %edx,%eax
f0101a37:	0f 85 46 09 00 00    	jne    f0102383 <mem_init+0x1047>
	assert(pp2->pp_ref == 1);
f0101a3d:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101a42:	0f 85 54 09 00 00    	jne    f010239c <mem_init+0x1060>

	// should be no free memory
	assert(!page_alloc(0));
f0101a48:	83 ec 0c             	sub    $0xc,%esp
f0101a4b:	6a 00                	push   $0x0
f0101a4d:	e8 5d f5 ff ff       	call   f0100faf <page_alloc>
f0101a52:	83 c4 10             	add    $0x10,%esp
f0101a55:	85 c0                	test   %eax,%eax
f0101a57:	0f 85 58 09 00 00    	jne    f01023b5 <mem_init+0x1079>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101a5d:	6a 02                	push   $0x2
f0101a5f:	68 00 10 00 00       	push   $0x1000
f0101a64:	53                   	push   %ebx
f0101a65:	ff 35 8c 2e 23 f0    	pushl  0xf0232e8c
f0101a6b:	e8 00 f8 ff ff       	call   f0101270 <page_insert>
f0101a70:	83 c4 10             	add    $0x10,%esp
f0101a73:	85 c0                	test   %eax,%eax
f0101a75:	0f 85 53 09 00 00    	jne    f01023ce <mem_init+0x1092>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101a7b:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101a80:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f0101a85:	e8 ac f0 ff ff       	call   f0100b36 <check_va2pa>
f0101a8a:	89 da                	mov    %ebx,%edx
f0101a8c:	2b 15 90 2e 23 f0    	sub    0xf0232e90,%edx
f0101a92:	c1 fa 03             	sar    $0x3,%edx
f0101a95:	c1 e2 0c             	shl    $0xc,%edx
f0101a98:	39 d0                	cmp    %edx,%eax
f0101a9a:	0f 85 47 09 00 00    	jne    f01023e7 <mem_init+0x10ab>
	assert(pp2->pp_ref == 1);
f0101aa0:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101aa5:	0f 85 55 09 00 00    	jne    f0102400 <mem_init+0x10c4>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101aab:	83 ec 0c             	sub    $0xc,%esp
f0101aae:	6a 00                	push   $0x0
f0101ab0:	e8 fa f4 ff ff       	call   f0100faf <page_alloc>
f0101ab5:	83 c4 10             	add    $0x10,%esp
f0101ab8:	85 c0                	test   %eax,%eax
f0101aba:	0f 85 59 09 00 00    	jne    f0102419 <mem_init+0x10dd>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101ac0:	8b 15 8c 2e 23 f0    	mov    0xf0232e8c,%edx
f0101ac6:	8b 02                	mov    (%edx),%eax
f0101ac8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0101acd:	89 c1                	mov    %eax,%ecx
f0101acf:	c1 e9 0c             	shr    $0xc,%ecx
f0101ad2:	3b 0d 88 2e 23 f0    	cmp    0xf0232e88,%ecx
f0101ad8:	0f 83 54 09 00 00    	jae    f0102432 <mem_init+0x10f6>
	return (void *)(pa + KERNBASE);
f0101ade:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101ae3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101ae6:	83 ec 04             	sub    $0x4,%esp
f0101ae9:	6a 00                	push   $0x0
f0101aeb:	68 00 10 00 00       	push   $0x1000
f0101af0:	52                   	push   %edx
f0101af1:	e8 8f f5 ff ff       	call   f0101085 <pgdir_walk>
f0101af6:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101af9:	8d 51 04             	lea    0x4(%ecx),%edx
f0101afc:	83 c4 10             	add    $0x10,%esp
f0101aff:	39 d0                	cmp    %edx,%eax
f0101b01:	0f 85 40 09 00 00    	jne    f0102447 <mem_init+0x110b>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101b07:	6a 06                	push   $0x6
f0101b09:	68 00 10 00 00       	push   $0x1000
f0101b0e:	53                   	push   %ebx
f0101b0f:	ff 35 8c 2e 23 f0    	pushl  0xf0232e8c
f0101b15:	e8 56 f7 ff ff       	call   f0101270 <page_insert>
f0101b1a:	83 c4 10             	add    $0x10,%esp
f0101b1d:	85 c0                	test   %eax,%eax
f0101b1f:	0f 85 3b 09 00 00    	jne    f0102460 <mem_init+0x1124>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101b25:	8b 35 8c 2e 23 f0    	mov    0xf0232e8c,%esi
f0101b2b:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101b30:	89 f0                	mov    %esi,%eax
f0101b32:	e8 ff ef ff ff       	call   f0100b36 <check_va2pa>
	return (pp - pages) << PGSHIFT;
f0101b37:	89 da                	mov    %ebx,%edx
f0101b39:	2b 15 90 2e 23 f0    	sub    0xf0232e90,%edx
f0101b3f:	c1 fa 03             	sar    $0x3,%edx
f0101b42:	c1 e2 0c             	shl    $0xc,%edx
f0101b45:	39 d0                	cmp    %edx,%eax
f0101b47:	0f 85 2c 09 00 00    	jne    f0102479 <mem_init+0x113d>
	assert(pp2->pp_ref == 1);
f0101b4d:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101b52:	0f 85 3a 09 00 00    	jne    f0102492 <mem_init+0x1156>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101b58:	83 ec 04             	sub    $0x4,%esp
f0101b5b:	6a 00                	push   $0x0
f0101b5d:	68 00 10 00 00       	push   $0x1000
f0101b62:	56                   	push   %esi
f0101b63:	e8 1d f5 ff ff       	call   f0101085 <pgdir_walk>
f0101b68:	83 c4 10             	add    $0x10,%esp
f0101b6b:	f6 00 04             	testb  $0x4,(%eax)
f0101b6e:	0f 84 37 09 00 00    	je     f01024ab <mem_init+0x116f>
	assert(kern_pgdir[0] & PTE_U);
f0101b74:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f0101b79:	f6 00 04             	testb  $0x4,(%eax)
f0101b7c:	0f 84 42 09 00 00    	je     f01024c4 <mem_init+0x1188>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101b82:	6a 02                	push   $0x2
f0101b84:	68 00 10 00 00       	push   $0x1000
f0101b89:	53                   	push   %ebx
f0101b8a:	50                   	push   %eax
f0101b8b:	e8 e0 f6 ff ff       	call   f0101270 <page_insert>
f0101b90:	83 c4 10             	add    $0x10,%esp
f0101b93:	85 c0                	test   %eax,%eax
f0101b95:	0f 85 42 09 00 00    	jne    f01024dd <mem_init+0x11a1>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101b9b:	83 ec 04             	sub    $0x4,%esp
f0101b9e:	6a 00                	push   $0x0
f0101ba0:	68 00 10 00 00       	push   $0x1000
f0101ba5:	ff 35 8c 2e 23 f0    	pushl  0xf0232e8c
f0101bab:	e8 d5 f4 ff ff       	call   f0101085 <pgdir_walk>
f0101bb0:	83 c4 10             	add    $0x10,%esp
f0101bb3:	f6 00 02             	testb  $0x2,(%eax)
f0101bb6:	0f 84 3a 09 00 00    	je     f01024f6 <mem_init+0x11ba>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101bbc:	83 ec 04             	sub    $0x4,%esp
f0101bbf:	6a 00                	push   $0x0
f0101bc1:	68 00 10 00 00       	push   $0x1000
f0101bc6:	ff 35 8c 2e 23 f0    	pushl  0xf0232e8c
f0101bcc:	e8 b4 f4 ff ff       	call   f0101085 <pgdir_walk>
f0101bd1:	83 c4 10             	add    $0x10,%esp
f0101bd4:	f6 00 04             	testb  $0x4,(%eax)
f0101bd7:	0f 85 32 09 00 00    	jne    f010250f <mem_init+0x11d3>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101bdd:	6a 02                	push   $0x2
f0101bdf:	68 00 00 40 00       	push   $0x400000
f0101be4:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101be7:	ff 35 8c 2e 23 f0    	pushl  0xf0232e8c
f0101bed:	e8 7e f6 ff ff       	call   f0101270 <page_insert>
f0101bf2:	83 c4 10             	add    $0x10,%esp
f0101bf5:	85 c0                	test   %eax,%eax
f0101bf7:	0f 89 2b 09 00 00    	jns    f0102528 <mem_init+0x11ec>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101bfd:	6a 02                	push   $0x2
f0101bff:	68 00 10 00 00       	push   $0x1000
f0101c04:	57                   	push   %edi
f0101c05:	ff 35 8c 2e 23 f0    	pushl  0xf0232e8c
f0101c0b:	e8 60 f6 ff ff       	call   f0101270 <page_insert>
f0101c10:	83 c4 10             	add    $0x10,%esp
f0101c13:	85 c0                	test   %eax,%eax
f0101c15:	0f 85 26 09 00 00    	jne    f0102541 <mem_init+0x1205>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101c1b:	83 ec 04             	sub    $0x4,%esp
f0101c1e:	6a 00                	push   $0x0
f0101c20:	68 00 10 00 00       	push   $0x1000
f0101c25:	ff 35 8c 2e 23 f0    	pushl  0xf0232e8c
f0101c2b:	e8 55 f4 ff ff       	call   f0101085 <pgdir_walk>
f0101c30:	83 c4 10             	add    $0x10,%esp
f0101c33:	f6 00 04             	testb  $0x4,(%eax)
f0101c36:	0f 85 1e 09 00 00    	jne    f010255a <mem_init+0x121e>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101c3c:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f0101c41:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101c44:	ba 00 00 00 00       	mov    $0x0,%edx
f0101c49:	e8 e8 ee ff ff       	call   f0100b36 <check_va2pa>
f0101c4e:	89 fe                	mov    %edi,%esi
f0101c50:	2b 35 90 2e 23 f0    	sub    0xf0232e90,%esi
f0101c56:	c1 fe 03             	sar    $0x3,%esi
f0101c59:	c1 e6 0c             	shl    $0xc,%esi
f0101c5c:	39 f0                	cmp    %esi,%eax
f0101c5e:	0f 85 0f 09 00 00    	jne    f0102573 <mem_init+0x1237>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101c64:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c69:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101c6c:	e8 c5 ee ff ff       	call   f0100b36 <check_va2pa>
f0101c71:	39 c6                	cmp    %eax,%esi
f0101c73:	0f 85 13 09 00 00    	jne    f010258c <mem_init+0x1250>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101c79:	66 83 7f 04 02       	cmpw   $0x2,0x4(%edi)
f0101c7e:	0f 85 21 09 00 00    	jne    f01025a5 <mem_init+0x1269>
	assert(pp2->pp_ref == 0);
f0101c84:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101c89:	0f 85 2f 09 00 00    	jne    f01025be <mem_init+0x1282>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101c8f:	83 ec 0c             	sub    $0xc,%esp
f0101c92:	6a 00                	push   $0x0
f0101c94:	e8 16 f3 ff ff       	call   f0100faf <page_alloc>
f0101c99:	83 c4 10             	add    $0x10,%esp
f0101c9c:	85 c0                	test   %eax,%eax
f0101c9e:	0f 84 33 09 00 00    	je     f01025d7 <mem_init+0x129b>
f0101ca4:	39 c3                	cmp    %eax,%ebx
f0101ca6:	0f 85 2b 09 00 00    	jne    f01025d7 <mem_init+0x129b>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101cac:	83 ec 08             	sub    $0x8,%esp
f0101caf:	6a 00                	push   $0x0
f0101cb1:	ff 35 8c 2e 23 f0    	pushl  0xf0232e8c
f0101cb7:	e8 6e f5 ff ff       	call   f010122a <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101cbc:	8b 35 8c 2e 23 f0    	mov    0xf0232e8c,%esi
f0101cc2:	ba 00 00 00 00       	mov    $0x0,%edx
f0101cc7:	89 f0                	mov    %esi,%eax
f0101cc9:	e8 68 ee ff ff       	call   f0100b36 <check_va2pa>
f0101cce:	83 c4 10             	add    $0x10,%esp
f0101cd1:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101cd4:	0f 85 16 09 00 00    	jne    f01025f0 <mem_init+0x12b4>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101cda:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101cdf:	89 f0                	mov    %esi,%eax
f0101ce1:	e8 50 ee ff ff       	call   f0100b36 <check_va2pa>
f0101ce6:	89 fa                	mov    %edi,%edx
f0101ce8:	2b 15 90 2e 23 f0    	sub    0xf0232e90,%edx
f0101cee:	c1 fa 03             	sar    $0x3,%edx
f0101cf1:	c1 e2 0c             	shl    $0xc,%edx
f0101cf4:	39 d0                	cmp    %edx,%eax
f0101cf6:	0f 85 0d 09 00 00    	jne    f0102609 <mem_init+0x12cd>
	assert(pp1->pp_ref == 1);
f0101cfc:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101d01:	0f 85 1b 09 00 00    	jne    f0102622 <mem_init+0x12e6>
	assert(pp2->pp_ref == 0);
f0101d07:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101d0c:	0f 85 29 09 00 00    	jne    f010263b <mem_init+0x12ff>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101d12:	6a 00                	push   $0x0
f0101d14:	68 00 10 00 00       	push   $0x1000
f0101d19:	57                   	push   %edi
f0101d1a:	56                   	push   %esi
f0101d1b:	e8 50 f5 ff ff       	call   f0101270 <page_insert>
f0101d20:	83 c4 10             	add    $0x10,%esp
f0101d23:	85 c0                	test   %eax,%eax
f0101d25:	0f 85 29 09 00 00    	jne    f0102654 <mem_init+0x1318>
	assert(pp1->pp_ref);
f0101d2b:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101d30:	0f 84 37 09 00 00    	je     f010266d <mem_init+0x1331>
	assert(pp1->pp_link == NULL);
f0101d36:	83 3f 00             	cmpl   $0x0,(%edi)
f0101d39:	0f 85 47 09 00 00    	jne    f0102686 <mem_init+0x134a>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101d3f:	83 ec 08             	sub    $0x8,%esp
f0101d42:	68 00 10 00 00       	push   $0x1000
f0101d47:	ff 35 8c 2e 23 f0    	pushl  0xf0232e8c
f0101d4d:	e8 d8 f4 ff ff       	call   f010122a <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101d52:	8b 35 8c 2e 23 f0    	mov    0xf0232e8c,%esi
f0101d58:	ba 00 00 00 00       	mov    $0x0,%edx
f0101d5d:	89 f0                	mov    %esi,%eax
f0101d5f:	e8 d2 ed ff ff       	call   f0100b36 <check_va2pa>
f0101d64:	83 c4 10             	add    $0x10,%esp
f0101d67:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101d6a:	0f 85 2f 09 00 00    	jne    f010269f <mem_init+0x1363>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101d70:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d75:	89 f0                	mov    %esi,%eax
f0101d77:	e8 ba ed ff ff       	call   f0100b36 <check_va2pa>
f0101d7c:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101d7f:	0f 85 33 09 00 00    	jne    f01026b8 <mem_init+0x137c>
	assert(pp1->pp_ref == 0);
f0101d85:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101d8a:	0f 85 41 09 00 00    	jne    f01026d1 <mem_init+0x1395>
	assert(pp2->pp_ref == 0);
f0101d90:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101d95:	0f 85 4f 09 00 00    	jne    f01026ea <mem_init+0x13ae>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101d9b:	83 ec 0c             	sub    $0xc,%esp
f0101d9e:	6a 00                	push   $0x0
f0101da0:	e8 0a f2 ff ff       	call   f0100faf <page_alloc>
f0101da5:	83 c4 10             	add    $0x10,%esp
f0101da8:	39 c7                	cmp    %eax,%edi
f0101daa:	0f 85 53 09 00 00    	jne    f0102703 <mem_init+0x13c7>
f0101db0:	85 c0                	test   %eax,%eax
f0101db2:	0f 84 4b 09 00 00    	je     f0102703 <mem_init+0x13c7>

	// should be no free memory
	assert(!page_alloc(0));
f0101db8:	83 ec 0c             	sub    $0xc,%esp
f0101dbb:	6a 00                	push   $0x0
f0101dbd:	e8 ed f1 ff ff       	call   f0100faf <page_alloc>
f0101dc2:	83 c4 10             	add    $0x10,%esp
f0101dc5:	85 c0                	test   %eax,%eax
f0101dc7:	0f 85 4f 09 00 00    	jne    f010271c <mem_init+0x13e0>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101dcd:	8b 0d 8c 2e 23 f0    	mov    0xf0232e8c,%ecx
f0101dd3:	8b 11                	mov    (%ecx),%edx
f0101dd5:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101ddb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101dde:	2b 05 90 2e 23 f0    	sub    0xf0232e90,%eax
f0101de4:	c1 f8 03             	sar    $0x3,%eax
f0101de7:	c1 e0 0c             	shl    $0xc,%eax
f0101dea:	39 c2                	cmp    %eax,%edx
f0101dec:	0f 85 43 09 00 00    	jne    f0102735 <mem_init+0x13f9>
	kern_pgdir[0] = 0;
f0101df2:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0101df8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101dfb:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101e00:	0f 85 48 09 00 00    	jne    f010274e <mem_init+0x1412>
	pp0->pp_ref = 0;
f0101e06:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e09:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0101e0f:	83 ec 0c             	sub    $0xc,%esp
f0101e12:	50                   	push   %eax
f0101e13:	e8 09 f2 ff ff       	call   f0101021 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0101e18:	83 c4 0c             	add    $0xc,%esp
f0101e1b:	6a 01                	push   $0x1
f0101e1d:	68 00 10 40 00       	push   $0x401000
f0101e22:	ff 35 8c 2e 23 f0    	pushl  0xf0232e8c
f0101e28:	e8 58 f2 ff ff       	call   f0101085 <pgdir_walk>
f0101e2d:	89 c1                	mov    %eax,%ecx
f0101e2f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0101e32:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f0101e37:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101e3a:	8b 40 04             	mov    0x4(%eax),%eax
f0101e3d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0101e42:	8b 35 88 2e 23 f0    	mov    0xf0232e88,%esi
f0101e48:	89 c2                	mov    %eax,%edx
f0101e4a:	c1 ea 0c             	shr    $0xc,%edx
f0101e4d:	83 c4 10             	add    $0x10,%esp
f0101e50:	39 f2                	cmp    %esi,%edx
f0101e52:	0f 83 0f 09 00 00    	jae    f0102767 <mem_init+0x142b>
	assert(ptep == ptep1 + PTX(va));
f0101e58:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f0101e5d:	39 c1                	cmp    %eax,%ecx
f0101e5f:	0f 85 17 09 00 00    	jne    f010277c <mem_init+0x1440>
	kern_pgdir[PDX(va)] = 0;
f0101e65:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101e68:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f0101e6f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e72:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f0101e78:	2b 05 90 2e 23 f0    	sub    0xf0232e90,%eax
f0101e7e:	c1 f8 03             	sar    $0x3,%eax
f0101e81:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0101e84:	89 c2                	mov    %eax,%edx
f0101e86:	c1 ea 0c             	shr    $0xc,%edx
f0101e89:	39 d6                	cmp    %edx,%esi
f0101e8b:	0f 86 04 09 00 00    	jbe    f0102795 <mem_init+0x1459>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0101e91:	83 ec 04             	sub    $0x4,%esp
f0101e94:	68 00 10 00 00       	push   $0x1000
f0101e99:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f0101e9e:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101ea3:	50                   	push   %eax
f0101ea4:	e8 25 31 00 00       	call   f0104fce <memset>
	page_free(pp0);
f0101ea9:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0101eac:	89 34 24             	mov    %esi,(%esp)
f0101eaf:	e8 6d f1 ff ff       	call   f0101021 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0101eb4:	83 c4 0c             	add    $0xc,%esp
f0101eb7:	6a 01                	push   $0x1
f0101eb9:	6a 00                	push   $0x0
f0101ebb:	ff 35 8c 2e 23 f0    	pushl  0xf0232e8c
f0101ec1:	e8 bf f1 ff ff       	call   f0101085 <pgdir_walk>
	return (pp - pages) << PGSHIFT;
f0101ec6:	89 f0                	mov    %esi,%eax
f0101ec8:	2b 05 90 2e 23 f0    	sub    0xf0232e90,%eax
f0101ece:	c1 f8 03             	sar    $0x3,%eax
f0101ed1:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0101ed4:	89 c2                	mov    %eax,%edx
f0101ed6:	c1 ea 0c             	shr    $0xc,%edx
f0101ed9:	83 c4 10             	add    $0x10,%esp
f0101edc:	3b 15 88 2e 23 f0    	cmp    0xf0232e88,%edx
f0101ee2:	0f 83 bf 08 00 00    	jae    f01027a7 <mem_init+0x146b>
	return (void *)(pa + KERNBASE);
f0101ee8:	8d 90 00 00 00 f0    	lea    -0x10000000(%eax),%edx
	ptep = (pte_t *) page2kva(pp0);
f0101eee:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0101ef1:	2d 00 f0 ff 0f       	sub    $0xffff000,%eax
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0101ef6:	f6 02 01             	testb  $0x1,(%edx)
f0101ef9:	0f 85 ba 08 00 00    	jne    f01027b9 <mem_init+0x147d>
f0101eff:	83 c2 04             	add    $0x4,%edx
	for(i=0; i<NPTENTRIES; i++)
f0101f02:	39 c2                	cmp    %eax,%edx
f0101f04:	75 f0                	jne    f0101ef6 <mem_init+0xbba>
	kern_pgdir[0] = 0;
f0101f06:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f0101f0b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0101f11:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101f14:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0101f1a:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0101f1d:	89 0d 3c 22 23 f0    	mov    %ecx,0xf023223c

	// free the pages we took
	page_free(pp0);
f0101f23:	83 ec 0c             	sub    $0xc,%esp
f0101f26:	50                   	push   %eax
f0101f27:	e8 f5 f0 ff ff       	call   f0101021 <page_free>
	page_free(pp1);
f0101f2c:	89 3c 24             	mov    %edi,(%esp)
f0101f2f:	e8 ed f0 ff ff       	call   f0101021 <page_free>
	page_free(pp2);
f0101f34:	89 1c 24             	mov    %ebx,(%esp)
f0101f37:	e8 e5 f0 ff ff       	call   f0101021 <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f0101f3c:	83 c4 08             	add    $0x8,%esp
f0101f3f:	68 01 10 00 00       	push   $0x1001
f0101f44:	6a 00                	push   $0x0
f0101f46:	e8 8b f3 ff ff       	call   f01012d6 <mmio_map_region>
f0101f4b:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f0101f4d:	83 c4 08             	add    $0x8,%esp
f0101f50:	68 00 10 00 00       	push   $0x1000
f0101f55:	6a 00                	push   $0x0
f0101f57:	e8 7a f3 ff ff       	call   f01012d6 <mmio_map_region>
f0101f5c:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8192 < MMIOLIM);
f0101f5e:	8d 83 00 20 00 00    	lea    0x2000(%ebx),%eax
f0101f64:	83 c4 10             	add    $0x10,%esp
f0101f67:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0101f6d:	0f 86 5f 08 00 00    	jbe    f01027d2 <mem_init+0x1496>
f0101f73:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0101f78:	0f 87 54 08 00 00    	ja     f01027d2 <mem_init+0x1496>
	assert(mm2 >= MMIOBASE && mm2 + 8192 < MMIOLIM);
f0101f7e:	8d 96 00 20 00 00    	lea    0x2000(%esi),%edx
f0101f84:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f0101f8a:	0f 87 5b 08 00 00    	ja     f01027eb <mem_init+0x14af>
f0101f90:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0101f96:	0f 86 4f 08 00 00    	jbe    f01027eb <mem_init+0x14af>
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0101f9c:	89 da                	mov    %ebx,%edx
f0101f9e:	09 f2                	or     %esi,%edx
f0101fa0:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0101fa6:	0f 85 58 08 00 00    	jne    f0102804 <mem_init+0x14c8>
	// check that they don't overlap
	assert(mm1 + 8192 <= mm2);
f0101fac:	39 c6                	cmp    %eax,%esi
f0101fae:	0f 82 69 08 00 00    	jb     f010281d <mem_init+0x14e1>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0101fb4:	8b 3d 8c 2e 23 f0    	mov    0xf0232e8c,%edi
f0101fba:	89 da                	mov    %ebx,%edx
f0101fbc:	89 f8                	mov    %edi,%eax
f0101fbe:	e8 73 eb ff ff       	call   f0100b36 <check_va2pa>
f0101fc3:	85 c0                	test   %eax,%eax
f0101fc5:	0f 85 6b 08 00 00    	jne    f0102836 <mem_init+0x14fa>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0101fcb:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f0101fd1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101fd4:	89 c2                	mov    %eax,%edx
f0101fd6:	89 f8                	mov    %edi,%eax
f0101fd8:	e8 59 eb ff ff       	call   f0100b36 <check_va2pa>
f0101fdd:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0101fe2:	0f 85 67 08 00 00    	jne    f010284f <mem_init+0x1513>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0101fe8:	89 f2                	mov    %esi,%edx
f0101fea:	89 f8                	mov    %edi,%eax
f0101fec:	e8 45 eb ff ff       	call   f0100b36 <check_va2pa>
f0101ff1:	85 c0                	test   %eax,%eax
f0101ff3:	0f 85 6f 08 00 00    	jne    f0102868 <mem_init+0x152c>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0101ff9:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f0101fff:	89 f8                	mov    %edi,%eax
f0102001:	e8 30 eb ff ff       	call   f0100b36 <check_va2pa>
f0102006:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102009:	0f 85 72 08 00 00    	jne    f0102881 <mem_init+0x1545>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f010200f:	83 ec 04             	sub    $0x4,%esp
f0102012:	6a 00                	push   $0x0
f0102014:	53                   	push   %ebx
f0102015:	57                   	push   %edi
f0102016:	e8 6a f0 ff ff       	call   f0101085 <pgdir_walk>
f010201b:	83 c4 10             	add    $0x10,%esp
f010201e:	f6 00 1a             	testb  $0x1a,(%eax)
f0102021:	0f 84 73 08 00 00    	je     f010289a <mem_init+0x155e>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102027:	83 ec 04             	sub    $0x4,%esp
f010202a:	6a 00                	push   $0x0
f010202c:	53                   	push   %ebx
f010202d:	ff 35 8c 2e 23 f0    	pushl  0xf0232e8c
f0102033:	e8 4d f0 ff ff       	call   f0101085 <pgdir_walk>
f0102038:	83 c4 10             	add    $0x10,%esp
f010203b:	f6 00 04             	testb  $0x4,(%eax)
f010203e:	0f 85 6f 08 00 00    	jne    f01028b3 <mem_init+0x1577>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f0102044:	83 ec 04             	sub    $0x4,%esp
f0102047:	6a 00                	push   $0x0
f0102049:	53                   	push   %ebx
f010204a:	ff 35 8c 2e 23 f0    	pushl  0xf0232e8c
f0102050:	e8 30 f0 ff ff       	call   f0101085 <pgdir_walk>
f0102055:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f010205b:	83 c4 0c             	add    $0xc,%esp
f010205e:	6a 00                	push   $0x0
f0102060:	ff 75 d4             	pushl  -0x2c(%ebp)
f0102063:	ff 35 8c 2e 23 f0    	pushl  0xf0232e8c
f0102069:	e8 17 f0 ff ff       	call   f0101085 <pgdir_walk>
f010206e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f0102074:	83 c4 0c             	add    $0xc,%esp
f0102077:	6a 00                	push   $0x0
f0102079:	56                   	push   %esi
f010207a:	ff 35 8c 2e 23 f0    	pushl  0xf0232e8c
f0102080:	e8 00 f0 ff ff       	call   f0101085 <pgdir_walk>
f0102085:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f010208b:	c7 04 24 f3 64 10 f0 	movl   $0xf01064f3,(%esp)
f0102092:	e8 a7 17 00 00       	call   f010383e <cprintf>
	boot_map_region(kern_pgdir, (uintptr_t) UPAGES, npages*sizeof(struct PageInfo), PADDR(pages), PTE_U | PTE_P);
f0102097:	a1 90 2e 23 f0       	mov    0xf0232e90,%eax
	if ((uint32_t)kva < KERNBASE)
f010209c:	83 c4 10             	add    $0x10,%esp
f010209f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01020a4:	0f 86 22 08 00 00    	jbe    f01028cc <mem_init+0x1590>
f01020aa:	8b 0d 88 2e 23 f0    	mov    0xf0232e88,%ecx
f01020b0:	c1 e1 03             	shl    $0x3,%ecx
f01020b3:	83 ec 08             	sub    $0x8,%esp
f01020b6:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f01020b8:	05 00 00 00 10       	add    $0x10000000,%eax
f01020bd:	50                   	push   %eax
f01020be:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f01020c3:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f01020c8:	e8 78 f0 ff ff       	call   f0101145 <boot_map_region>
	boot_map_region(kern_pgdir, (uintptr_t) UENVS, ROUNDUP(NENV * sizeof(struct Env), PGSIZE), PADDR(envs), PTE_U | PTE_P);
f01020cd:	a1 44 22 23 f0       	mov    0xf0232244,%eax
	if ((uint32_t)kva < KERNBASE)
f01020d2:	83 c4 10             	add    $0x10,%esp
f01020d5:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01020da:	0f 86 01 08 00 00    	jbe    f01028e1 <mem_init+0x15a5>
f01020e0:	83 ec 08             	sub    $0x8,%esp
f01020e3:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f01020e5:	05 00 00 00 10       	add    $0x10000000,%eax
f01020ea:	50                   	push   %eax
f01020eb:	b9 00 f0 01 00       	mov    $0x1f000,%ecx
f01020f0:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f01020f5:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f01020fa:	e8 46 f0 ff ff       	call   f0101145 <boot_map_region>
	if ((uint32_t)kva < KERNBASE)
f01020ff:	83 c4 10             	add    $0x10,%esp
f0102102:	b8 00 80 11 f0       	mov    $0xf0118000,%eax
f0102107:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010210c:	0f 86 e4 07 00 00    	jbe    f01028f6 <mem_init+0x15ba>
	boot_map_region(kern_pgdir, (uintptr_t) (KSTACKTOP-KSTKSIZE), KSTKSIZE, PADDR(bootstack), PTE_W | PTE_P);
f0102112:	83 ec 08             	sub    $0x8,%esp
f0102115:	6a 03                	push   $0x3
f0102117:	68 00 80 11 00       	push   $0x118000
f010211c:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102121:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102126:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f010212b:	e8 15 f0 ff ff       	call   f0101145 <boot_map_region>
	boot_map_region(kern_pgdir, (uintptr_t) KERNBASE, ROUNDUP(0xffffffff - KERNBASE, PGSIZE), 0, PTE_W | PTE_P);
f0102130:	83 c4 08             	add    $0x8,%esp
f0102133:	6a 03                	push   $0x3
f0102135:	6a 00                	push   $0x0
f0102137:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f010213c:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102141:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f0102146:	e8 fa ef ff ff       	call   f0101145 <boot_map_region>
f010214b:	c7 45 d0 00 40 23 f0 	movl   $0xf0234000,-0x30(%ebp)
f0102152:	83 c4 10             	add    $0x10,%esp
f0102155:	bb 00 40 23 f0       	mov    $0xf0234000,%ebx
    uintptr_t start_addr = KSTACKTOP - KSTKSIZE;    
f010215a:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f010215f:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102165:	0f 86 a0 07 00 00    	jbe    f010290b <mem_init+0x15cf>
        boot_map_region(kern_pgdir, (uintptr_t) start_addr, KSTKSIZE, PADDR(percpu_kstacks[i]), PTE_W | PTE_P);
f010216b:	83 ec 08             	sub    $0x8,%esp
f010216e:	6a 03                	push   $0x3
f0102170:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f0102176:	50                   	push   %eax
f0102177:	b9 00 80 00 00       	mov    $0x8000,%ecx
f010217c:	89 f2                	mov    %esi,%edx
f010217e:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f0102183:	e8 bd ef ff ff       	call   f0101145 <boot_map_region>
        start_addr -= KSTKSIZE + KSTKGAP;
f0102188:	81 ee 00 00 01 00    	sub    $0x10000,%esi
f010218e:	81 c3 00 80 00 00    	add    $0x8000,%ebx
    for (i = 0; i < NCPU; i++) {
f0102194:	83 c4 10             	add    $0x10,%esp
f0102197:	81 fe 00 80 f7 ef    	cmp    $0xeff78000,%esi
f010219d:	75 c0                	jne    f010215f <mem_init+0xe23>
	pgdir = kern_pgdir;
f010219f:	8b 3d 8c 2e 23 f0    	mov    0xf0232e8c,%edi
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f01021a5:	a1 88 2e 23 f0       	mov    0xf0232e88,%eax
f01021aa:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f01021ad:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f01021b4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01021b9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01021bc:	8b 35 90 2e 23 f0    	mov    0xf0232e90,%esi
f01021c2:	89 75 cc             	mov    %esi,-0x34(%ebp)
	return (physaddr_t)kva - KERNBASE;
f01021c5:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f01021cb:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (i = 0; i < n; i += PGSIZE)
f01021ce:	bb 00 00 00 00       	mov    $0x0,%ebx
f01021d3:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f01021d6:	0f 86 72 07 00 00    	jbe    f010294e <mem_init+0x1612>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01021dc:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f01021e2:	89 f8                	mov    %edi,%eax
f01021e4:	e8 4d e9 ff ff       	call   f0100b36 <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f01021e9:	81 7d cc ff ff ff ef 	cmpl   $0xefffffff,-0x34(%ebp)
f01021f0:	0f 86 2a 07 00 00    	jbe    f0102920 <mem_init+0x15e4>
f01021f6:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f01021f9:	8d 14 0b             	lea    (%ebx,%ecx,1),%edx
f01021fc:	39 d0                	cmp    %edx,%eax
f01021fe:	0f 85 31 07 00 00    	jne    f0102935 <mem_init+0x15f9>
	for (i = 0; i < n; i += PGSIZE)
f0102204:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010220a:	eb c7                	jmp    f01021d3 <mem_init+0xe97>
	assert(nfree == 0);
f010220c:	68 0a 64 10 f0       	push   $0xf010640a
f0102211:	68 3e 62 10 f0       	push   $0xf010623e
f0102216:	68 4c 03 00 00       	push   $0x34c
f010221b:	68 11 62 10 f0       	push   $0xf0106211
f0102220:	e8 6f de ff ff       	call   f0100094 <_panic>
	assert((pp0 = page_alloc(0)));
f0102225:	68 18 63 10 f0       	push   $0xf0106318
f010222a:	68 3e 62 10 f0       	push   $0xf010623e
f010222f:	68 b8 03 00 00       	push   $0x3b8
f0102234:	68 11 62 10 f0       	push   $0xf0106211
f0102239:	e8 56 de ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f010223e:	68 2e 63 10 f0       	push   $0xf010632e
f0102243:	68 3e 62 10 f0       	push   $0xf010623e
f0102248:	68 b9 03 00 00       	push   $0x3b9
f010224d:	68 11 62 10 f0       	push   $0xf0106211
f0102252:	e8 3d de ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f0102257:	68 44 63 10 f0       	push   $0xf0106344
f010225c:	68 3e 62 10 f0       	push   $0xf010623e
f0102261:	68 ba 03 00 00       	push   $0x3ba
f0102266:	68 11 62 10 f0       	push   $0xf0106211
f010226b:	e8 24 de ff ff       	call   f0100094 <_panic>
	assert(pp1 && pp1 != pp0);
f0102270:	68 5a 63 10 f0       	push   $0xf010635a
f0102275:	68 3e 62 10 f0       	push   $0xf010623e
f010227a:	68 bd 03 00 00       	push   $0x3bd
f010227f:	68 11 62 10 f0       	push   $0xf0106211
f0102284:	e8 0b de ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0102289:	68 b8 66 10 f0       	push   $0xf01066b8
f010228e:	68 3e 62 10 f0       	push   $0xf010623e
f0102293:	68 be 03 00 00       	push   $0x3be
f0102298:	68 11 62 10 f0       	push   $0xf0106211
f010229d:	e8 f2 dd ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f01022a2:	68 c3 63 10 f0       	push   $0xf01063c3
f01022a7:	68 3e 62 10 f0       	push   $0xf010623e
f01022ac:	68 c5 03 00 00       	push   $0x3c5
f01022b1:	68 11 62 10 f0       	push   $0xf0106211
f01022b6:	e8 d9 dd ff ff       	call   f0100094 <_panic>
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f01022bb:	68 f8 66 10 f0       	push   $0xf01066f8
f01022c0:	68 3e 62 10 f0       	push   $0xf010623e
f01022c5:	68 c8 03 00 00       	push   $0x3c8
f01022ca:	68 11 62 10 f0       	push   $0xf0106211
f01022cf:	e8 c0 dd ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01022d4:	68 30 67 10 f0       	push   $0xf0106730
f01022d9:	68 3e 62 10 f0       	push   $0xf010623e
f01022de:	68 cb 03 00 00       	push   $0x3cb
f01022e3:	68 11 62 10 f0       	push   $0xf0106211
f01022e8:	e8 a7 dd ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f01022ed:	68 60 67 10 f0       	push   $0xf0106760
f01022f2:	68 3e 62 10 f0       	push   $0xf010623e
f01022f7:	68 cf 03 00 00       	push   $0x3cf
f01022fc:	68 11 62 10 f0       	push   $0xf0106211
f0102301:	e8 8e dd ff ff       	call   f0100094 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102306:	68 90 67 10 f0       	push   $0xf0106790
f010230b:	68 3e 62 10 f0       	push   $0xf010623e
f0102310:	68 d0 03 00 00       	push   $0x3d0
f0102315:	68 11 62 10 f0       	push   $0xf0106211
f010231a:	e8 75 dd ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f010231f:	68 b8 67 10 f0       	push   $0xf01067b8
f0102324:	68 3e 62 10 f0       	push   $0xf010623e
f0102329:	68 d1 03 00 00       	push   $0x3d1
f010232e:	68 11 62 10 f0       	push   $0xf0106211
f0102333:	e8 5c dd ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 1);
f0102338:	68 15 64 10 f0       	push   $0xf0106415
f010233d:	68 3e 62 10 f0       	push   $0xf010623e
f0102342:	68 d2 03 00 00       	push   $0x3d2
f0102347:	68 11 62 10 f0       	push   $0xf0106211
f010234c:	e8 43 dd ff ff       	call   f0100094 <_panic>
	assert(pp0->pp_ref == 1);
f0102351:	68 26 64 10 f0       	push   $0xf0106426
f0102356:	68 3e 62 10 f0       	push   $0xf010623e
f010235b:	68 d3 03 00 00       	push   $0x3d3
f0102360:	68 11 62 10 f0       	push   $0xf0106211
f0102365:	e8 2a dd ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010236a:	68 e8 67 10 f0       	push   $0xf01067e8
f010236f:	68 3e 62 10 f0       	push   $0xf010623e
f0102374:	68 d6 03 00 00       	push   $0x3d6
f0102379:	68 11 62 10 f0       	push   $0xf0106211
f010237e:	e8 11 dd ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102383:	68 24 68 10 f0       	push   $0xf0106824
f0102388:	68 3e 62 10 f0       	push   $0xf010623e
f010238d:	68 d7 03 00 00       	push   $0x3d7
f0102392:	68 11 62 10 f0       	push   $0xf0106211
f0102397:	e8 f8 dc ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f010239c:	68 37 64 10 f0       	push   $0xf0106437
f01023a1:	68 3e 62 10 f0       	push   $0xf010623e
f01023a6:	68 d8 03 00 00       	push   $0x3d8
f01023ab:	68 11 62 10 f0       	push   $0xf0106211
f01023b0:	e8 df dc ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f01023b5:	68 c3 63 10 f0       	push   $0xf01063c3
f01023ba:	68 3e 62 10 f0       	push   $0xf010623e
f01023bf:	68 db 03 00 00       	push   $0x3db
f01023c4:	68 11 62 10 f0       	push   $0xf0106211
f01023c9:	e8 c6 dc ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01023ce:	68 e8 67 10 f0       	push   $0xf01067e8
f01023d3:	68 3e 62 10 f0       	push   $0xf010623e
f01023d8:	68 de 03 00 00       	push   $0x3de
f01023dd:	68 11 62 10 f0       	push   $0xf0106211
f01023e2:	e8 ad dc ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01023e7:	68 24 68 10 f0       	push   $0xf0106824
f01023ec:	68 3e 62 10 f0       	push   $0xf010623e
f01023f1:	68 df 03 00 00       	push   $0x3df
f01023f6:	68 11 62 10 f0       	push   $0xf0106211
f01023fb:	e8 94 dc ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f0102400:	68 37 64 10 f0       	push   $0xf0106437
f0102405:	68 3e 62 10 f0       	push   $0xf010623e
f010240a:	68 e0 03 00 00       	push   $0x3e0
f010240f:	68 11 62 10 f0       	push   $0xf0106211
f0102414:	e8 7b dc ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f0102419:	68 c3 63 10 f0       	push   $0xf01063c3
f010241e:	68 3e 62 10 f0       	push   $0xf010623e
f0102423:	68 e4 03 00 00       	push   $0x3e4
f0102428:	68 11 62 10 f0       	push   $0xf0106211
f010242d:	e8 62 dc ff ff       	call   f0100094 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102432:	50                   	push   %eax
f0102433:	68 d4 5c 10 f0       	push   $0xf0105cd4
f0102438:	68 e7 03 00 00       	push   $0x3e7
f010243d:	68 11 62 10 f0       	push   $0xf0106211
f0102442:	e8 4d dc ff ff       	call   f0100094 <_panic>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0102447:	68 54 68 10 f0       	push   $0xf0106854
f010244c:	68 3e 62 10 f0       	push   $0xf010623e
f0102451:	68 e8 03 00 00       	push   $0x3e8
f0102456:	68 11 62 10 f0       	push   $0xf0106211
f010245b:	e8 34 dc ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0102460:	68 94 68 10 f0       	push   $0xf0106894
f0102465:	68 3e 62 10 f0       	push   $0xf010623e
f010246a:	68 eb 03 00 00       	push   $0x3eb
f010246f:	68 11 62 10 f0       	push   $0xf0106211
f0102474:	e8 1b dc ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102479:	68 24 68 10 f0       	push   $0xf0106824
f010247e:	68 3e 62 10 f0       	push   $0xf010623e
f0102483:	68 ec 03 00 00       	push   $0x3ec
f0102488:	68 11 62 10 f0       	push   $0xf0106211
f010248d:	e8 02 dc ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f0102492:	68 37 64 10 f0       	push   $0xf0106437
f0102497:	68 3e 62 10 f0       	push   $0xf010623e
f010249c:	68 ed 03 00 00       	push   $0x3ed
f01024a1:	68 11 62 10 f0       	push   $0xf0106211
f01024a6:	e8 e9 db ff ff       	call   f0100094 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f01024ab:	68 d4 68 10 f0       	push   $0xf01068d4
f01024b0:	68 3e 62 10 f0       	push   $0xf010623e
f01024b5:	68 ee 03 00 00       	push   $0x3ee
f01024ba:	68 11 62 10 f0       	push   $0xf0106211
f01024bf:	e8 d0 db ff ff       	call   f0100094 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f01024c4:	68 48 64 10 f0       	push   $0xf0106448
f01024c9:	68 3e 62 10 f0       	push   $0xf010623e
f01024ce:	68 ef 03 00 00       	push   $0x3ef
f01024d3:	68 11 62 10 f0       	push   $0xf0106211
f01024d8:	e8 b7 db ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01024dd:	68 e8 67 10 f0       	push   $0xf01067e8
f01024e2:	68 3e 62 10 f0       	push   $0xf010623e
f01024e7:	68 f2 03 00 00       	push   $0x3f2
f01024ec:	68 11 62 10 f0       	push   $0xf0106211
f01024f1:	e8 9e db ff ff       	call   f0100094 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f01024f6:	68 08 69 10 f0       	push   $0xf0106908
f01024fb:	68 3e 62 10 f0       	push   $0xf010623e
f0102500:	68 f3 03 00 00       	push   $0x3f3
f0102505:	68 11 62 10 f0       	push   $0xf0106211
f010250a:	e8 85 db ff ff       	call   f0100094 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f010250f:	68 3c 69 10 f0       	push   $0xf010693c
f0102514:	68 3e 62 10 f0       	push   $0xf010623e
f0102519:	68 f4 03 00 00       	push   $0x3f4
f010251e:	68 11 62 10 f0       	push   $0xf0106211
f0102523:	e8 6c db ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0102528:	68 74 69 10 f0       	push   $0xf0106974
f010252d:	68 3e 62 10 f0       	push   $0xf010623e
f0102532:	68 f7 03 00 00       	push   $0x3f7
f0102537:	68 11 62 10 f0       	push   $0xf0106211
f010253c:	e8 53 db ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0102541:	68 ac 69 10 f0       	push   $0xf01069ac
f0102546:	68 3e 62 10 f0       	push   $0xf010623e
f010254b:	68 fa 03 00 00       	push   $0x3fa
f0102550:	68 11 62 10 f0       	push   $0xf0106211
f0102555:	e8 3a db ff ff       	call   f0100094 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f010255a:	68 3c 69 10 f0       	push   $0xf010693c
f010255f:	68 3e 62 10 f0       	push   $0xf010623e
f0102564:	68 fb 03 00 00       	push   $0x3fb
f0102569:	68 11 62 10 f0       	push   $0xf0106211
f010256e:	e8 21 db ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102573:	68 e8 69 10 f0       	push   $0xf01069e8
f0102578:	68 3e 62 10 f0       	push   $0xf010623e
f010257d:	68 fe 03 00 00       	push   $0x3fe
f0102582:	68 11 62 10 f0       	push   $0xf0106211
f0102587:	e8 08 db ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010258c:	68 14 6a 10 f0       	push   $0xf0106a14
f0102591:	68 3e 62 10 f0       	push   $0xf010623e
f0102596:	68 ff 03 00 00       	push   $0x3ff
f010259b:	68 11 62 10 f0       	push   $0xf0106211
f01025a0:	e8 ef da ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 2);
f01025a5:	68 5e 64 10 f0       	push   $0xf010645e
f01025aa:	68 3e 62 10 f0       	push   $0xf010623e
f01025af:	68 01 04 00 00       	push   $0x401
f01025b4:	68 11 62 10 f0       	push   $0xf0106211
f01025b9:	e8 d6 da ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f01025be:	68 6f 64 10 f0       	push   $0xf010646f
f01025c3:	68 3e 62 10 f0       	push   $0xf010623e
f01025c8:	68 02 04 00 00       	push   $0x402
f01025cd:	68 11 62 10 f0       	push   $0xf0106211
f01025d2:	e8 bd da ff ff       	call   f0100094 <_panic>
	assert((pp = page_alloc(0)) && pp == pp2);
f01025d7:	68 44 6a 10 f0       	push   $0xf0106a44
f01025dc:	68 3e 62 10 f0       	push   $0xf010623e
f01025e1:	68 05 04 00 00       	push   $0x405
f01025e6:	68 11 62 10 f0       	push   $0xf0106211
f01025eb:	e8 a4 da ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01025f0:	68 68 6a 10 f0       	push   $0xf0106a68
f01025f5:	68 3e 62 10 f0       	push   $0xf010623e
f01025fa:	68 09 04 00 00       	push   $0x409
f01025ff:	68 11 62 10 f0       	push   $0xf0106211
f0102604:	e8 8b da ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102609:	68 14 6a 10 f0       	push   $0xf0106a14
f010260e:	68 3e 62 10 f0       	push   $0xf010623e
f0102613:	68 0a 04 00 00       	push   $0x40a
f0102618:	68 11 62 10 f0       	push   $0xf0106211
f010261d:	e8 72 da ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 1);
f0102622:	68 15 64 10 f0       	push   $0xf0106415
f0102627:	68 3e 62 10 f0       	push   $0xf010623e
f010262c:	68 0b 04 00 00       	push   $0x40b
f0102631:	68 11 62 10 f0       	push   $0xf0106211
f0102636:	e8 59 da ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f010263b:	68 6f 64 10 f0       	push   $0xf010646f
f0102640:	68 3e 62 10 f0       	push   $0xf010623e
f0102645:	68 0c 04 00 00       	push   $0x40c
f010264a:	68 11 62 10 f0       	push   $0xf0106211
f010264f:	e8 40 da ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0102654:	68 8c 6a 10 f0       	push   $0xf0106a8c
f0102659:	68 3e 62 10 f0       	push   $0xf010623e
f010265e:	68 0f 04 00 00       	push   $0x40f
f0102663:	68 11 62 10 f0       	push   $0xf0106211
f0102668:	e8 27 da ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref);
f010266d:	68 80 64 10 f0       	push   $0xf0106480
f0102672:	68 3e 62 10 f0       	push   $0xf010623e
f0102677:	68 10 04 00 00       	push   $0x410
f010267c:	68 11 62 10 f0       	push   $0xf0106211
f0102681:	e8 0e da ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_link == NULL);
f0102686:	68 8c 64 10 f0       	push   $0xf010648c
f010268b:	68 3e 62 10 f0       	push   $0xf010623e
f0102690:	68 11 04 00 00       	push   $0x411
f0102695:	68 11 62 10 f0       	push   $0xf0106211
f010269a:	e8 f5 d9 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010269f:	68 68 6a 10 f0       	push   $0xf0106a68
f01026a4:	68 3e 62 10 f0       	push   $0xf010623e
f01026a9:	68 15 04 00 00       	push   $0x415
f01026ae:	68 11 62 10 f0       	push   $0xf0106211
f01026b3:	e8 dc d9 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f01026b8:	68 c4 6a 10 f0       	push   $0xf0106ac4
f01026bd:	68 3e 62 10 f0       	push   $0xf010623e
f01026c2:	68 16 04 00 00       	push   $0x416
f01026c7:	68 11 62 10 f0       	push   $0xf0106211
f01026cc:	e8 c3 d9 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 0);
f01026d1:	68 a1 64 10 f0       	push   $0xf01064a1
f01026d6:	68 3e 62 10 f0       	push   $0xf010623e
f01026db:	68 17 04 00 00       	push   $0x417
f01026e0:	68 11 62 10 f0       	push   $0xf0106211
f01026e5:	e8 aa d9 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f01026ea:	68 6f 64 10 f0       	push   $0xf010646f
f01026ef:	68 3e 62 10 f0       	push   $0xf010623e
f01026f4:	68 18 04 00 00       	push   $0x418
f01026f9:	68 11 62 10 f0       	push   $0xf0106211
f01026fe:	e8 91 d9 ff ff       	call   f0100094 <_panic>
	assert((pp = page_alloc(0)) && pp == pp1);
f0102703:	68 ec 6a 10 f0       	push   $0xf0106aec
f0102708:	68 3e 62 10 f0       	push   $0xf010623e
f010270d:	68 1b 04 00 00       	push   $0x41b
f0102712:	68 11 62 10 f0       	push   $0xf0106211
f0102717:	e8 78 d9 ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f010271c:	68 c3 63 10 f0       	push   $0xf01063c3
f0102721:	68 3e 62 10 f0       	push   $0xf010623e
f0102726:	68 1e 04 00 00       	push   $0x41e
f010272b:	68 11 62 10 f0       	push   $0xf0106211
f0102730:	e8 5f d9 ff ff       	call   f0100094 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102735:	68 90 67 10 f0       	push   $0xf0106790
f010273a:	68 3e 62 10 f0       	push   $0xf010623e
f010273f:	68 21 04 00 00       	push   $0x421
f0102744:	68 11 62 10 f0       	push   $0xf0106211
f0102749:	e8 46 d9 ff ff       	call   f0100094 <_panic>
	assert(pp0->pp_ref == 1);
f010274e:	68 26 64 10 f0       	push   $0xf0106426
f0102753:	68 3e 62 10 f0       	push   $0xf010623e
f0102758:	68 23 04 00 00       	push   $0x423
f010275d:	68 11 62 10 f0       	push   $0xf0106211
f0102762:	e8 2d d9 ff ff       	call   f0100094 <_panic>
f0102767:	50                   	push   %eax
f0102768:	68 d4 5c 10 f0       	push   $0xf0105cd4
f010276d:	68 2a 04 00 00       	push   $0x42a
f0102772:	68 11 62 10 f0       	push   $0xf0106211
f0102777:	e8 18 d9 ff ff       	call   f0100094 <_panic>
	assert(ptep == ptep1 + PTX(va));
f010277c:	68 b2 64 10 f0       	push   $0xf01064b2
f0102781:	68 3e 62 10 f0       	push   $0xf010623e
f0102786:	68 2b 04 00 00       	push   $0x42b
f010278b:	68 11 62 10 f0       	push   $0xf0106211
f0102790:	e8 ff d8 ff ff       	call   f0100094 <_panic>
f0102795:	50                   	push   %eax
f0102796:	68 d4 5c 10 f0       	push   $0xf0105cd4
f010279b:	6a 58                	push   $0x58
f010279d:	68 24 62 10 f0       	push   $0xf0106224
f01027a2:	e8 ed d8 ff ff       	call   f0100094 <_panic>
f01027a7:	50                   	push   %eax
f01027a8:	68 d4 5c 10 f0       	push   $0xf0105cd4
f01027ad:	6a 58                	push   $0x58
f01027af:	68 24 62 10 f0       	push   $0xf0106224
f01027b4:	e8 db d8 ff ff       	call   f0100094 <_panic>
		assert((ptep[i] & PTE_P) == 0);
f01027b9:	68 ca 64 10 f0       	push   $0xf01064ca
f01027be:	68 3e 62 10 f0       	push   $0xf010623e
f01027c3:	68 35 04 00 00       	push   $0x435
f01027c8:	68 11 62 10 f0       	push   $0xf0106211
f01027cd:	e8 c2 d8 ff ff       	call   f0100094 <_panic>
	assert(mm1 >= MMIOBASE && mm1 + 8192 < MMIOLIM);
f01027d2:	68 10 6b 10 f0       	push   $0xf0106b10
f01027d7:	68 3e 62 10 f0       	push   $0xf010623e
f01027dc:	68 45 04 00 00       	push   $0x445
f01027e1:	68 11 62 10 f0       	push   $0xf0106211
f01027e6:	e8 a9 d8 ff ff       	call   f0100094 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8192 < MMIOLIM);
f01027eb:	68 38 6b 10 f0       	push   $0xf0106b38
f01027f0:	68 3e 62 10 f0       	push   $0xf010623e
f01027f5:	68 46 04 00 00       	push   $0x446
f01027fa:	68 11 62 10 f0       	push   $0xf0106211
f01027ff:	e8 90 d8 ff ff       	call   f0100094 <_panic>
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0102804:	68 60 6b 10 f0       	push   $0xf0106b60
f0102809:	68 3e 62 10 f0       	push   $0xf010623e
f010280e:	68 48 04 00 00       	push   $0x448
f0102813:	68 11 62 10 f0       	push   $0xf0106211
f0102818:	e8 77 d8 ff ff       	call   f0100094 <_panic>
	assert(mm1 + 8192 <= mm2);
f010281d:	68 e1 64 10 f0       	push   $0xf01064e1
f0102822:	68 3e 62 10 f0       	push   $0xf010623e
f0102827:	68 4a 04 00 00       	push   $0x44a
f010282c:	68 11 62 10 f0       	push   $0xf0106211
f0102831:	e8 5e d8 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0102836:	68 88 6b 10 f0       	push   $0xf0106b88
f010283b:	68 3e 62 10 f0       	push   $0xf010623e
f0102840:	68 4c 04 00 00       	push   $0x44c
f0102845:	68 11 62 10 f0       	push   $0xf0106211
f010284a:	e8 45 d8 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f010284f:	68 ac 6b 10 f0       	push   $0xf0106bac
f0102854:	68 3e 62 10 f0       	push   $0xf010623e
f0102859:	68 4d 04 00 00       	push   $0x44d
f010285e:	68 11 62 10 f0       	push   $0xf0106211
f0102863:	e8 2c d8 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0102868:	68 dc 6b 10 f0       	push   $0xf0106bdc
f010286d:	68 3e 62 10 f0       	push   $0xf010623e
f0102872:	68 4e 04 00 00       	push   $0x44e
f0102877:	68 11 62 10 f0       	push   $0xf0106211
f010287c:	e8 13 d8 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0102881:	68 00 6c 10 f0       	push   $0xf0106c00
f0102886:	68 3e 62 10 f0       	push   $0xf010623e
f010288b:	68 4f 04 00 00       	push   $0x44f
f0102890:	68 11 62 10 f0       	push   $0xf0106211
f0102895:	e8 fa d7 ff ff       	call   f0100094 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f010289a:	68 2c 6c 10 f0       	push   $0xf0106c2c
f010289f:	68 3e 62 10 f0       	push   $0xf010623e
f01028a4:	68 51 04 00 00       	push   $0x451
f01028a9:	68 11 62 10 f0       	push   $0xf0106211
f01028ae:	e8 e1 d7 ff ff       	call   f0100094 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f01028b3:	68 70 6c 10 f0       	push   $0xf0106c70
f01028b8:	68 3e 62 10 f0       	push   $0xf010623e
f01028bd:	68 52 04 00 00       	push   $0x452
f01028c2:	68 11 62 10 f0       	push   $0xf0106211
f01028c7:	e8 c8 d7 ff ff       	call   f0100094 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01028cc:	50                   	push   %eax
f01028cd:	68 f8 5c 10 f0       	push   $0xf0105cf8
f01028d2:	68 d2 00 00 00       	push   $0xd2
f01028d7:	68 11 62 10 f0       	push   $0xf0106211
f01028dc:	e8 b3 d7 ff ff       	call   f0100094 <_panic>
f01028e1:	50                   	push   %eax
f01028e2:	68 f8 5c 10 f0       	push   $0xf0105cf8
f01028e7:	68 db 00 00 00       	push   $0xdb
f01028ec:	68 11 62 10 f0       	push   $0xf0106211
f01028f1:	e8 9e d7 ff ff       	call   f0100094 <_panic>
f01028f6:	50                   	push   %eax
f01028f7:	68 f8 5c 10 f0       	push   $0xf0105cf8
f01028fc:	68 e8 00 00 00       	push   $0xe8
f0102901:	68 11 62 10 f0       	push   $0xf0106211
f0102906:	e8 89 d7 ff ff       	call   f0100094 <_panic>
f010290b:	53                   	push   %ebx
f010290c:	68 f8 5c 10 f0       	push   $0xf0105cf8
f0102911:	68 2c 01 00 00       	push   $0x12c
f0102916:	68 11 62 10 f0       	push   $0xf0106211
f010291b:	e8 74 d7 ff ff       	call   f0100094 <_panic>
f0102920:	56                   	push   %esi
f0102921:	68 f8 5c 10 f0       	push   $0xf0105cf8
f0102926:	68 65 03 00 00       	push   $0x365
f010292b:	68 11 62 10 f0       	push   $0xf0106211
f0102930:	e8 5f d7 ff ff       	call   f0100094 <_panic>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102935:	68 a4 6c 10 f0       	push   $0xf0106ca4
f010293a:	68 3e 62 10 f0       	push   $0xf010623e
f010293f:	68 65 03 00 00       	push   $0x365
f0102944:	68 11 62 10 f0       	push   $0xf0106211
f0102949:	e8 46 d7 ff ff       	call   f0100094 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f010294e:	a1 44 22 23 f0       	mov    0xf0232244,%eax
f0102953:	89 45 cc             	mov    %eax,-0x34(%ebp)
	if ((uint32_t)kva < KERNBASE)
f0102956:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102959:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f010295e:	8d b0 00 00 40 21    	lea    0x21400000(%eax),%esi
f0102964:	89 da                	mov    %ebx,%edx
f0102966:	89 f8                	mov    %edi,%eax
f0102968:	e8 c9 e1 ff ff       	call   f0100b36 <check_va2pa>
f010296d:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f0102974:	76 3d                	jbe    f01029b3 <mem_init+0x1677>
f0102976:	8d 14 1e             	lea    (%esi,%ebx,1),%edx
f0102979:	39 d0                	cmp    %edx,%eax
f010297b:	75 4d                	jne    f01029ca <mem_init+0x168e>
f010297d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE) {
f0102983:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f0102989:	75 d9                	jne    f0102964 <mem_init+0x1628>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f010298b:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f010298e:	c1 e6 0c             	shl    $0xc,%esi
f0102991:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102996:	39 f3                	cmp    %esi,%ebx
f0102998:	73 62                	jae    f01029fc <mem_init+0x16c0>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f010299a:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f01029a0:	89 f8                	mov    %edi,%eax
f01029a2:	e8 8f e1 ff ff       	call   f0100b36 <check_va2pa>
f01029a7:	39 c3                	cmp    %eax,%ebx
f01029a9:	75 38                	jne    f01029e3 <mem_init+0x16a7>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01029ab:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01029b1:	eb e3                	jmp    f0102996 <mem_init+0x165a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01029b3:	ff 75 cc             	pushl  -0x34(%ebp)
f01029b6:	68 f8 5c 10 f0       	push   $0xf0105cf8
f01029bb:	68 6c 03 00 00       	push   $0x36c
f01029c0:	68 11 62 10 f0       	push   $0xf0106211
f01029c5:	e8 ca d6 ff ff       	call   f0100094 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f01029ca:	68 d8 6c 10 f0       	push   $0xf0106cd8
f01029cf:	68 3e 62 10 f0       	push   $0xf010623e
f01029d4:	68 6c 03 00 00       	push   $0x36c
f01029d9:	68 11 62 10 f0       	push   $0xf0106211
f01029de:	e8 b1 d6 ff ff       	call   f0100094 <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f01029e3:	68 0c 6d 10 f0       	push   $0xf0106d0c
f01029e8:	68 3e 62 10 f0       	push   $0xf010623e
f01029ed:	68 73 03 00 00       	push   $0x373
f01029f2:	68 11 62 10 f0       	push   $0xf0106211
f01029f7:	e8 98 d6 ff ff       	call   f0100094 <_panic>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01029fc:	b8 00 40 23 f0       	mov    $0xf0234000,%eax
f0102a01:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f0102a06:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0102a09:	89 c7                	mov    %eax,%edi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102a0b:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f0102a0e:	89 f3                	mov    %esi,%ebx
f0102a10:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102a13:	05 00 80 00 20       	add    $0x20008000,%eax
f0102a18:	89 45 cc             	mov    %eax,-0x34(%ebp)
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102a1b:	8d 86 00 80 00 00    	lea    0x8000(%esi),%eax
f0102a21:	89 45 c8             	mov    %eax,-0x38(%ebp)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102a24:	89 da                	mov    %ebx,%edx
f0102a26:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102a29:	e8 08 e1 ff ff       	call   f0100b36 <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f0102a2e:	81 ff ff ff ff ef    	cmp    $0xefffffff,%edi
f0102a34:	76 59                	jbe    f0102a8f <mem_init+0x1753>
f0102a36:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0102a39:	8d 14 19             	lea    (%ecx,%ebx,1),%edx
f0102a3c:	39 d0                	cmp    %edx,%eax
f0102a3e:	75 66                	jne    f0102aa6 <mem_init+0x176a>
f0102a40:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102a46:	3b 5d c8             	cmp    -0x38(%ebp),%ebx
f0102a49:	75 d9                	jne    f0102a24 <mem_init+0x16e8>
f0102a4b:	8d 9e 00 80 ff ff    	lea    -0x8000(%esi),%ebx
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102a51:	89 da                	mov    %ebx,%edx
f0102a53:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102a56:	e8 db e0 ff ff       	call   f0100b36 <check_va2pa>
f0102a5b:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102a5e:	75 5f                	jne    f0102abf <mem_init+0x1783>
f0102a60:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0102a66:	39 f3                	cmp    %esi,%ebx
f0102a68:	75 e7                	jne    f0102a51 <mem_init+0x1715>
f0102a6a:	81 ee 00 00 01 00    	sub    $0x10000,%esi
f0102a70:	81 45 d0 00 80 01 00 	addl   $0x18000,-0x30(%ebp)
f0102a77:	81 c7 00 80 00 00    	add    $0x8000,%edi
	for (n = 0; n < NCPU; n++) {
f0102a7d:	81 ff 00 40 27 f0    	cmp    $0xf0274000,%edi
f0102a83:	75 86                	jne    f0102a0b <mem_init+0x16cf>
f0102a85:	8b 7d d4             	mov    -0x2c(%ebp),%edi
	for (i = 0; i < NPDENTRIES; i++) {
f0102a88:	b8 00 00 00 00       	mov    $0x0,%eax
f0102a8d:	eb 7f                	jmp    f0102b0e <mem_init+0x17d2>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102a8f:	ff 75 c4             	pushl  -0x3c(%ebp)
f0102a92:	68 f8 5c 10 f0       	push   $0xf0105cf8
f0102a97:	68 7c 03 00 00       	push   $0x37c
f0102a9c:	68 11 62 10 f0       	push   $0xf0106211
f0102aa1:	e8 ee d5 ff ff       	call   f0100094 <_panic>
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102aa6:	68 34 6d 10 f0       	push   $0xf0106d34
f0102aab:	68 3e 62 10 f0       	push   $0xf010623e
f0102ab0:	68 7c 03 00 00       	push   $0x37c
f0102ab5:	68 11 62 10 f0       	push   $0xf0106211
f0102aba:	e8 d5 d5 ff ff       	call   f0100094 <_panic>
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102abf:	68 7c 6d 10 f0       	push   $0xf0106d7c
f0102ac4:	68 3e 62 10 f0       	push   $0xf010623e
f0102ac9:	68 7e 03 00 00       	push   $0x37e
f0102ace:	68 11 62 10 f0       	push   $0xf0106211
f0102ad3:	e8 bc d5 ff ff       	call   f0100094 <_panic>
			assert(pgdir[i] & PTE_P);
f0102ad8:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f0102adc:	75 48                	jne    f0102b26 <mem_init+0x17ea>
f0102ade:	68 0c 65 10 f0       	push   $0xf010650c
f0102ae3:	68 3e 62 10 f0       	push   $0xf010623e
f0102ae8:	68 89 03 00 00       	push   $0x389
f0102aed:	68 11 62 10 f0       	push   $0xf0106211
f0102af2:	e8 9d d5 ff ff       	call   f0100094 <_panic>
				assert(pgdir[i] & PTE_P);
f0102af7:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0102afa:	f6 c2 01             	test   $0x1,%dl
f0102afd:	74 2c                	je     f0102b2b <mem_init+0x17ef>
				assert(pgdir[i] & PTE_W);
f0102aff:	f6 c2 02             	test   $0x2,%dl
f0102b02:	74 40                	je     f0102b44 <mem_init+0x1808>
	for (i = 0; i < NPDENTRIES; i++) {
f0102b04:	83 c0 01             	add    $0x1,%eax
f0102b07:	3d 00 04 00 00       	cmp    $0x400,%eax
f0102b0c:	74 68                	je     f0102b76 <mem_init+0x183a>
		switch (i) {
f0102b0e:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0102b14:	83 fa 04             	cmp    $0x4,%edx
f0102b17:	76 bf                	jbe    f0102ad8 <mem_init+0x179c>
			if (i >= PDX(KERNBASE)) {
f0102b19:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102b1e:	77 d7                	ja     f0102af7 <mem_init+0x17bb>
				assert(pgdir[i] == 0);
f0102b20:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f0102b24:	75 37                	jne    f0102b5d <mem_init+0x1821>
	for (i = 0; i < NPDENTRIES; i++) {
f0102b26:	83 c0 01             	add    $0x1,%eax
f0102b29:	eb e3                	jmp    f0102b0e <mem_init+0x17d2>
				assert(pgdir[i] & PTE_P);
f0102b2b:	68 0c 65 10 f0       	push   $0xf010650c
f0102b30:	68 3e 62 10 f0       	push   $0xf010623e
f0102b35:	68 8d 03 00 00       	push   $0x38d
f0102b3a:	68 11 62 10 f0       	push   $0xf0106211
f0102b3f:	e8 50 d5 ff ff       	call   f0100094 <_panic>
				assert(pgdir[i] & PTE_W);
f0102b44:	68 1d 65 10 f0       	push   $0xf010651d
f0102b49:	68 3e 62 10 f0       	push   $0xf010623e
f0102b4e:	68 8e 03 00 00       	push   $0x38e
f0102b53:	68 11 62 10 f0       	push   $0xf0106211
f0102b58:	e8 37 d5 ff ff       	call   f0100094 <_panic>
				assert(pgdir[i] == 0);
f0102b5d:	68 2e 65 10 f0       	push   $0xf010652e
f0102b62:	68 3e 62 10 f0       	push   $0xf010623e
f0102b67:	68 90 03 00 00       	push   $0x390
f0102b6c:	68 11 62 10 f0       	push   $0xf0106211
f0102b71:	e8 1e d5 ff ff       	call   f0100094 <_panic>
	cprintf("check_kern_pgdir() succeeded!\n");
f0102b76:	83 ec 0c             	sub    $0xc,%esp
f0102b79:	68 a0 6d 10 f0       	push   $0xf0106da0
f0102b7e:	e8 bb 0c 00 00       	call   f010383e <cprintf>
	lcr3(PADDR(kern_pgdir));
f0102b83:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f0102b88:	83 c4 10             	add    $0x10,%esp
f0102b8b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102b90:	0f 86 fb 01 00 00    	jbe    f0102d91 <mem_init+0x1a55>
	return (physaddr_t)kva - KERNBASE;
f0102b96:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102b9b:	0f 22 d8             	mov    %eax,%cr3
	check_page_free_list(0);
f0102b9e:	b8 00 00 00 00       	mov    $0x0,%eax
f0102ba3:	e8 f2 df ff ff       	call   f0100b9a <check_page_free_list>
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0102ba8:	0f 20 c0             	mov    %cr0,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f0102bab:	83 e0 f3             	and    $0xfffffff3,%eax
f0102bae:	0d 23 00 05 80       	or     $0x80050023,%eax
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0102bb3:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102bb6:	83 ec 0c             	sub    $0xc,%esp
f0102bb9:	6a 00                	push   $0x0
f0102bbb:	e8 ef e3 ff ff       	call   f0100faf <page_alloc>
f0102bc0:	89 c6                	mov    %eax,%esi
f0102bc2:	83 c4 10             	add    $0x10,%esp
f0102bc5:	85 c0                	test   %eax,%eax
f0102bc7:	0f 84 d9 01 00 00    	je     f0102da6 <mem_init+0x1a6a>
	assert((pp1 = page_alloc(0)));
f0102bcd:	83 ec 0c             	sub    $0xc,%esp
f0102bd0:	6a 00                	push   $0x0
f0102bd2:	e8 d8 e3 ff ff       	call   f0100faf <page_alloc>
f0102bd7:	89 c7                	mov    %eax,%edi
f0102bd9:	83 c4 10             	add    $0x10,%esp
f0102bdc:	85 c0                	test   %eax,%eax
f0102bde:	0f 84 db 01 00 00    	je     f0102dbf <mem_init+0x1a83>
	assert((pp2 = page_alloc(0)));
f0102be4:	83 ec 0c             	sub    $0xc,%esp
f0102be7:	6a 00                	push   $0x0
f0102be9:	e8 c1 e3 ff ff       	call   f0100faf <page_alloc>
f0102bee:	89 c3                	mov    %eax,%ebx
f0102bf0:	83 c4 10             	add    $0x10,%esp
f0102bf3:	85 c0                	test   %eax,%eax
f0102bf5:	0f 84 dd 01 00 00    	je     f0102dd8 <mem_init+0x1a9c>
	page_free(pp0);
f0102bfb:	83 ec 0c             	sub    $0xc,%esp
f0102bfe:	56                   	push   %esi
f0102bff:	e8 1d e4 ff ff       	call   f0101021 <page_free>
	return (pp - pages) << PGSHIFT;
f0102c04:	89 f8                	mov    %edi,%eax
f0102c06:	2b 05 90 2e 23 f0    	sub    0xf0232e90,%eax
f0102c0c:	c1 f8 03             	sar    $0x3,%eax
f0102c0f:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102c12:	89 c2                	mov    %eax,%edx
f0102c14:	c1 ea 0c             	shr    $0xc,%edx
f0102c17:	83 c4 10             	add    $0x10,%esp
f0102c1a:	3b 15 88 2e 23 f0    	cmp    0xf0232e88,%edx
f0102c20:	0f 83 cb 01 00 00    	jae    f0102df1 <mem_init+0x1ab5>
	memset(page2kva(pp1), 1, PGSIZE);
f0102c26:	83 ec 04             	sub    $0x4,%esp
f0102c29:	68 00 10 00 00       	push   $0x1000
f0102c2e:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0102c30:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102c35:	50                   	push   %eax
f0102c36:	e8 93 23 00 00       	call   f0104fce <memset>
	return (pp - pages) << PGSHIFT;
f0102c3b:	89 d8                	mov    %ebx,%eax
f0102c3d:	2b 05 90 2e 23 f0    	sub    0xf0232e90,%eax
f0102c43:	c1 f8 03             	sar    $0x3,%eax
f0102c46:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102c49:	89 c2                	mov    %eax,%edx
f0102c4b:	c1 ea 0c             	shr    $0xc,%edx
f0102c4e:	83 c4 10             	add    $0x10,%esp
f0102c51:	3b 15 88 2e 23 f0    	cmp    0xf0232e88,%edx
f0102c57:	0f 83 a6 01 00 00    	jae    f0102e03 <mem_init+0x1ac7>
	memset(page2kva(pp2), 2, PGSIZE);
f0102c5d:	83 ec 04             	sub    $0x4,%esp
f0102c60:	68 00 10 00 00       	push   $0x1000
f0102c65:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f0102c67:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102c6c:	50                   	push   %eax
f0102c6d:	e8 5c 23 00 00       	call   f0104fce <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102c72:	6a 02                	push   $0x2
f0102c74:	68 00 10 00 00       	push   $0x1000
f0102c79:	57                   	push   %edi
f0102c7a:	ff 35 8c 2e 23 f0    	pushl  0xf0232e8c
f0102c80:	e8 eb e5 ff ff       	call   f0101270 <page_insert>
	assert(pp1->pp_ref == 1);
f0102c85:	83 c4 20             	add    $0x20,%esp
f0102c88:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102c8d:	0f 85 82 01 00 00    	jne    f0102e15 <mem_init+0x1ad9>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102c93:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102c9a:	01 01 01 
f0102c9d:	0f 85 8b 01 00 00    	jne    f0102e2e <mem_init+0x1af2>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102ca3:	6a 02                	push   $0x2
f0102ca5:	68 00 10 00 00       	push   $0x1000
f0102caa:	53                   	push   %ebx
f0102cab:	ff 35 8c 2e 23 f0    	pushl  0xf0232e8c
f0102cb1:	e8 ba e5 ff ff       	call   f0101270 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102cb6:	83 c4 10             	add    $0x10,%esp
f0102cb9:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102cc0:	02 02 02 
f0102cc3:	0f 85 7e 01 00 00    	jne    f0102e47 <mem_init+0x1b0b>
	assert(pp2->pp_ref == 1);
f0102cc9:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102cce:	0f 85 8c 01 00 00    	jne    f0102e60 <mem_init+0x1b24>
	assert(pp1->pp_ref == 0);
f0102cd4:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102cd9:	0f 85 9a 01 00 00    	jne    f0102e79 <mem_init+0x1b3d>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102cdf:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102ce6:	03 03 03 
	return (pp - pages) << PGSHIFT;
f0102ce9:	89 d8                	mov    %ebx,%eax
f0102ceb:	2b 05 90 2e 23 f0    	sub    0xf0232e90,%eax
f0102cf1:	c1 f8 03             	sar    $0x3,%eax
f0102cf4:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102cf7:	89 c2                	mov    %eax,%edx
f0102cf9:	c1 ea 0c             	shr    $0xc,%edx
f0102cfc:	3b 15 88 2e 23 f0    	cmp    0xf0232e88,%edx
f0102d02:	0f 83 8a 01 00 00    	jae    f0102e92 <mem_init+0x1b56>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102d08:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102d0f:	03 03 03 
f0102d12:	0f 85 8c 01 00 00    	jne    f0102ea4 <mem_init+0x1b68>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102d18:	83 ec 08             	sub    $0x8,%esp
f0102d1b:	68 00 10 00 00       	push   $0x1000
f0102d20:	ff 35 8c 2e 23 f0    	pushl  0xf0232e8c
f0102d26:	e8 ff e4 ff ff       	call   f010122a <page_remove>
	assert(pp2->pp_ref == 0);
f0102d2b:	83 c4 10             	add    $0x10,%esp
f0102d2e:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102d33:	0f 85 84 01 00 00    	jne    f0102ebd <mem_init+0x1b81>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102d39:	8b 0d 8c 2e 23 f0    	mov    0xf0232e8c,%ecx
f0102d3f:	8b 11                	mov    (%ecx),%edx
f0102d41:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	return (pp - pages) << PGSHIFT;
f0102d47:	89 f0                	mov    %esi,%eax
f0102d49:	2b 05 90 2e 23 f0    	sub    0xf0232e90,%eax
f0102d4f:	c1 f8 03             	sar    $0x3,%eax
f0102d52:	c1 e0 0c             	shl    $0xc,%eax
f0102d55:	39 c2                	cmp    %eax,%edx
f0102d57:	0f 85 79 01 00 00    	jne    f0102ed6 <mem_init+0x1b9a>
	kern_pgdir[0] = 0;
f0102d5d:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102d63:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102d68:	0f 85 81 01 00 00    	jne    f0102eef <mem_init+0x1bb3>
	pp0->pp_ref = 0;
f0102d6e:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f0102d74:	83 ec 0c             	sub    $0xc,%esp
f0102d77:	56                   	push   %esi
f0102d78:	e8 a4 e2 ff ff       	call   f0101021 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102d7d:	c7 04 24 34 6e 10 f0 	movl   $0xf0106e34,(%esp)
f0102d84:	e8 b5 0a 00 00       	call   f010383e <cprintf>
}
f0102d89:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102d8c:	5b                   	pop    %ebx
f0102d8d:	5e                   	pop    %esi
f0102d8e:	5f                   	pop    %edi
f0102d8f:	5d                   	pop    %ebp
f0102d90:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102d91:	50                   	push   %eax
f0102d92:	68 f8 5c 10 f0       	push   $0xf0105cf8
f0102d97:	68 04 01 00 00       	push   $0x104
f0102d9c:	68 11 62 10 f0       	push   $0xf0106211
f0102da1:	e8 ee d2 ff ff       	call   f0100094 <_panic>
	assert((pp0 = page_alloc(0)));
f0102da6:	68 18 63 10 f0       	push   $0xf0106318
f0102dab:	68 3e 62 10 f0       	push   $0xf010623e
f0102db0:	68 67 04 00 00       	push   $0x467
f0102db5:	68 11 62 10 f0       	push   $0xf0106211
f0102dba:	e8 d5 d2 ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f0102dbf:	68 2e 63 10 f0       	push   $0xf010632e
f0102dc4:	68 3e 62 10 f0       	push   $0xf010623e
f0102dc9:	68 68 04 00 00       	push   $0x468
f0102dce:	68 11 62 10 f0       	push   $0xf0106211
f0102dd3:	e8 bc d2 ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f0102dd8:	68 44 63 10 f0       	push   $0xf0106344
f0102ddd:	68 3e 62 10 f0       	push   $0xf010623e
f0102de2:	68 69 04 00 00       	push   $0x469
f0102de7:	68 11 62 10 f0       	push   $0xf0106211
f0102dec:	e8 a3 d2 ff ff       	call   f0100094 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102df1:	50                   	push   %eax
f0102df2:	68 d4 5c 10 f0       	push   $0xf0105cd4
f0102df7:	6a 58                	push   $0x58
f0102df9:	68 24 62 10 f0       	push   $0xf0106224
f0102dfe:	e8 91 d2 ff ff       	call   f0100094 <_panic>
f0102e03:	50                   	push   %eax
f0102e04:	68 d4 5c 10 f0       	push   $0xf0105cd4
f0102e09:	6a 58                	push   $0x58
f0102e0b:	68 24 62 10 f0       	push   $0xf0106224
f0102e10:	e8 7f d2 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 1);
f0102e15:	68 15 64 10 f0       	push   $0xf0106415
f0102e1a:	68 3e 62 10 f0       	push   $0xf010623e
f0102e1f:	68 6e 04 00 00       	push   $0x46e
f0102e24:	68 11 62 10 f0       	push   $0xf0106211
f0102e29:	e8 66 d2 ff ff       	call   f0100094 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102e2e:	68 c0 6d 10 f0       	push   $0xf0106dc0
f0102e33:	68 3e 62 10 f0       	push   $0xf010623e
f0102e38:	68 6f 04 00 00       	push   $0x46f
f0102e3d:	68 11 62 10 f0       	push   $0xf0106211
f0102e42:	e8 4d d2 ff ff       	call   f0100094 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102e47:	68 e4 6d 10 f0       	push   $0xf0106de4
f0102e4c:	68 3e 62 10 f0       	push   $0xf010623e
f0102e51:	68 71 04 00 00       	push   $0x471
f0102e56:	68 11 62 10 f0       	push   $0xf0106211
f0102e5b:	e8 34 d2 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f0102e60:	68 37 64 10 f0       	push   $0xf0106437
f0102e65:	68 3e 62 10 f0       	push   $0xf010623e
f0102e6a:	68 72 04 00 00       	push   $0x472
f0102e6f:	68 11 62 10 f0       	push   $0xf0106211
f0102e74:	e8 1b d2 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 0);
f0102e79:	68 a1 64 10 f0       	push   $0xf01064a1
f0102e7e:	68 3e 62 10 f0       	push   $0xf010623e
f0102e83:	68 73 04 00 00       	push   $0x473
f0102e88:	68 11 62 10 f0       	push   $0xf0106211
f0102e8d:	e8 02 d2 ff ff       	call   f0100094 <_panic>
f0102e92:	50                   	push   %eax
f0102e93:	68 d4 5c 10 f0       	push   $0xf0105cd4
f0102e98:	6a 58                	push   $0x58
f0102e9a:	68 24 62 10 f0       	push   $0xf0106224
f0102e9f:	e8 f0 d1 ff ff       	call   f0100094 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102ea4:	68 08 6e 10 f0       	push   $0xf0106e08
f0102ea9:	68 3e 62 10 f0       	push   $0xf010623e
f0102eae:	68 75 04 00 00       	push   $0x475
f0102eb3:	68 11 62 10 f0       	push   $0xf0106211
f0102eb8:	e8 d7 d1 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f0102ebd:	68 6f 64 10 f0       	push   $0xf010646f
f0102ec2:	68 3e 62 10 f0       	push   $0xf010623e
f0102ec7:	68 77 04 00 00       	push   $0x477
f0102ecc:	68 11 62 10 f0       	push   $0xf0106211
f0102ed1:	e8 be d1 ff ff       	call   f0100094 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102ed6:	68 90 67 10 f0       	push   $0xf0106790
f0102edb:	68 3e 62 10 f0       	push   $0xf010623e
f0102ee0:	68 7a 04 00 00       	push   $0x47a
f0102ee5:	68 11 62 10 f0       	push   $0xf0106211
f0102eea:	e8 a5 d1 ff ff       	call   f0100094 <_panic>
	assert(pp0->pp_ref == 1);
f0102eef:	68 26 64 10 f0       	push   $0xf0106426
f0102ef4:	68 3e 62 10 f0       	push   $0xf010623e
f0102ef9:	68 7c 04 00 00       	push   $0x47c
f0102efe:	68 11 62 10 f0       	push   $0xf0106211
f0102f03:	e8 8c d1 ff ff       	call   f0100094 <_panic>

f0102f08 <user_mem_check>:
}
f0102f08:	b8 00 00 00 00       	mov    $0x0,%eax
f0102f0d:	c3                   	ret    

f0102f0e <user_mem_assert>:
}
f0102f0e:	c3                   	ret    

f0102f0f <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0102f0f:	55                   	push   %ebp
f0102f10:	89 e5                	mov    %esp,%ebp
f0102f12:	57                   	push   %edi
f0102f13:	56                   	push   %esi
f0102f14:	53                   	push   %ebx
f0102f15:	83 ec 0c             	sub    $0xc,%esp
f0102f18:	89 c7                	mov    %eax,%edi
	// LAB 3: Your code here.
	void* i;
	for (i = ROUNDDOWN(va, PGSIZE); i < ROUNDUP(va + len, PGSIZE); i+=PGSIZE){
f0102f1a:	89 d3                	mov    %edx,%ebx
f0102f1c:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0102f22:	8d b4 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%esi
f0102f29:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
f0102f2f:	39 f3                	cmp    %esi,%ebx
f0102f31:	73 5c                	jae    f0102f8f <region_alloc+0x80>
		struct PageInfo *pginfo = page_alloc(0);
f0102f33:	83 ec 0c             	sub    $0xc,%esp
f0102f36:	6a 00                	push   $0x0
f0102f38:	e8 72 e0 ff ff       	call   f0100faf <page_alloc>
		if (!pginfo) {
f0102f3d:	83 c4 10             	add    $0x10,%esp
f0102f40:	85 c0                	test   %eax,%eax
f0102f42:	74 20                	je     f0102f64 <region_alloc+0x55>
			 panic("region_alloc:%e", -E_NO_MEM);
		}
		pginfo->pp_ref++;
f0102f44:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
		int r = page_insert(e->env_pgdir, pginfo, i, PTE_W | PTE_U | PTE_P);
f0102f49:	6a 07                	push   $0x7
f0102f4b:	53                   	push   %ebx
f0102f4c:	50                   	push   %eax
f0102f4d:	ff 77 60             	pushl  0x60(%edi)
f0102f50:	e8 1b e3 ff ff       	call   f0101270 <page_insert>
		if (r < 0) {
f0102f55:	83 c4 10             	add    $0x10,%esp
f0102f58:	85 c0                	test   %eax,%eax
f0102f5a:	78 1e                	js     f0102f7a <region_alloc+0x6b>
	for (i = ROUNDDOWN(va, PGSIZE); i < ROUNDUP(va + len, PGSIZE); i+=PGSIZE){
f0102f5c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102f62:	eb cb                	jmp    f0102f2f <region_alloc+0x20>
			 panic("region_alloc:%e", -E_NO_MEM);
f0102f64:	6a fc                	push   $0xfffffffc
f0102f66:	68 5d 6e 10 f0       	push   $0xf0106e5d
f0102f6b:	68 2c 01 00 00       	push   $0x12c
f0102f70:	68 6d 6e 10 f0       	push   $0xf0106e6d
f0102f75:	e8 1a d1 ff ff       	call   f0100094 <_panic>
			 panic("region_alloc:%e", r);
f0102f7a:	50                   	push   %eax
f0102f7b:	68 5d 6e 10 f0       	push   $0xf0106e5d
f0102f80:	68 31 01 00 00       	push   $0x131
f0102f85:	68 6d 6e 10 f0       	push   $0xf0106e6d
f0102f8a:	e8 05 d1 ff ff       	call   f0100094 <_panic>
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
}
f0102f8f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102f92:	5b                   	pop    %ebx
f0102f93:	5e                   	pop    %esi
f0102f94:	5f                   	pop    %edi
f0102f95:	5d                   	pop    %ebp
f0102f96:	c3                   	ret    

f0102f97 <envid2env>:
{
f0102f97:	55                   	push   %ebp
f0102f98:	89 e5                	mov    %esp,%ebp
f0102f9a:	56                   	push   %esi
f0102f9b:	53                   	push   %ebx
f0102f9c:	8b 45 08             	mov    0x8(%ebp),%eax
f0102f9f:	8b 55 10             	mov    0x10(%ebp),%edx
	if (envid == 0) {
f0102fa2:	85 c0                	test   %eax,%eax
f0102fa4:	74 2e                	je     f0102fd4 <envid2env+0x3d>
	e = &envs[ENVX(envid)];
f0102fa6:	89 c3                	mov    %eax,%ebx
f0102fa8:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0102fae:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f0102fb1:	03 1d 44 22 23 f0    	add    0xf0232244,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0102fb7:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0102fbb:	74 31                	je     f0102fee <envid2env+0x57>
f0102fbd:	39 43 48             	cmp    %eax,0x48(%ebx)
f0102fc0:	75 2c                	jne    f0102fee <envid2env+0x57>
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0102fc2:	84 d2                	test   %dl,%dl
f0102fc4:	75 38                	jne    f0102ffe <envid2env+0x67>
	*env_store = e;
f0102fc6:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102fc9:	89 18                	mov    %ebx,(%eax)
	return 0;
f0102fcb:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102fd0:	5b                   	pop    %ebx
f0102fd1:	5e                   	pop    %esi
f0102fd2:	5d                   	pop    %ebp
f0102fd3:	c3                   	ret    
		*env_store = curenv;
f0102fd4:	e8 f5 25 00 00       	call   f01055ce <cpunum>
f0102fd9:	6b c0 74             	imul   $0x74,%eax,%eax
f0102fdc:	8b 80 28 30 23 f0    	mov    -0xfdccfd8(%eax),%eax
f0102fe2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102fe5:	89 01                	mov    %eax,(%ecx)
		return 0;
f0102fe7:	b8 00 00 00 00       	mov    $0x0,%eax
f0102fec:	eb e2                	jmp    f0102fd0 <envid2env+0x39>
		*env_store = 0;
f0102fee:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102ff1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102ff7:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102ffc:	eb d2                	jmp    f0102fd0 <envid2env+0x39>
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0102ffe:	e8 cb 25 00 00       	call   f01055ce <cpunum>
f0103003:	6b c0 74             	imul   $0x74,%eax,%eax
f0103006:	39 98 28 30 23 f0    	cmp    %ebx,-0xfdccfd8(%eax)
f010300c:	74 b8                	je     f0102fc6 <envid2env+0x2f>
f010300e:	8b 73 4c             	mov    0x4c(%ebx),%esi
f0103011:	e8 b8 25 00 00       	call   f01055ce <cpunum>
f0103016:	6b c0 74             	imul   $0x74,%eax,%eax
f0103019:	8b 80 28 30 23 f0    	mov    -0xfdccfd8(%eax),%eax
f010301f:	3b 70 48             	cmp    0x48(%eax),%esi
f0103022:	74 a2                	je     f0102fc6 <envid2env+0x2f>
		*env_store = 0;
f0103024:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103027:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f010302d:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103032:	eb 9c                	jmp    f0102fd0 <envid2env+0x39>

f0103034 <env_init_percpu>:
	asm volatile("lgdt (%0)" : : "r" (p));
f0103034:	b8 20 23 12 f0       	mov    $0xf0122320,%eax
f0103039:	0f 01 10             	lgdtl  (%eax)
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f010303c:	b8 23 00 00 00       	mov    $0x23,%eax
f0103041:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f0103043:	8e e0                	mov    %eax,%fs
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f0103045:	b8 10 00 00 00       	mov    $0x10,%eax
f010304a:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f010304c:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f010304e:	8e d0                	mov    %eax,%ss
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f0103050:	ea 57 30 10 f0 08 00 	ljmp   $0x8,$0xf0103057
	asm volatile("lldt %0" : : "r" (sel));
f0103057:	b8 00 00 00 00       	mov    $0x0,%eax
f010305c:	0f 00 d0             	lldt   %ax
}
f010305f:	c3                   	ret    

f0103060 <env_init>:
{
f0103060:	55                   	push   %ebp
f0103061:	89 e5                	mov    %esp,%ebp
f0103063:	56                   	push   %esi
f0103064:	53                   	push   %ebx
		envs[i].env_id = 0;
f0103065:	8b 35 44 22 23 f0    	mov    0xf0232244,%esi
f010306b:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f0103071:	89 f3                	mov    %esi,%ebx
f0103073:	ba 00 00 00 00       	mov    $0x0,%edx
f0103078:	eb 02                	jmp    f010307c <env_init+0x1c>
f010307a:	89 c8                	mov    %ecx,%eax
f010307c:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_status = ENV_FREE;
f0103083:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
		envs[i].env_link = env_free_list;
f010308a:	89 50 44             	mov    %edx,0x44(%eax)
f010308d:	8d 48 84             	lea    -0x7c(%eax),%ecx
		env_free_list = &envs[i];
f0103090:	89 c2                	mov    %eax,%edx
	for (i = NENV - 1; i >= 0; i--) {
f0103092:	39 d8                	cmp    %ebx,%eax
f0103094:	75 e4                	jne    f010307a <env_init+0x1a>
f0103096:	89 35 48 22 23 f0    	mov    %esi,0xf0232248
	env_init_percpu();
f010309c:	e8 93 ff ff ff       	call   f0103034 <env_init_percpu>
}
f01030a1:	5b                   	pop    %ebx
f01030a2:	5e                   	pop    %esi
f01030a3:	5d                   	pop    %ebp
f01030a4:	c3                   	ret    

f01030a5 <env_alloc>:
{
f01030a5:	55                   	push   %ebp
f01030a6:	89 e5                	mov    %esp,%ebp
f01030a8:	53                   	push   %ebx
f01030a9:	83 ec 04             	sub    $0x4,%esp
	if (!(e = env_free_list))
f01030ac:	8b 1d 48 22 23 f0    	mov    0xf0232248,%ebx
f01030b2:	85 db                	test   %ebx,%ebx
f01030b4:	0f 84 8b 01 00 00    	je     f0103245 <env_alloc+0x1a0>
	if (!(p = page_alloc(ALLOC_ZERO)))
f01030ba:	83 ec 0c             	sub    $0xc,%esp
f01030bd:	6a 01                	push   $0x1
f01030bf:	e8 eb de ff ff       	call   f0100faf <page_alloc>
f01030c4:	83 c4 10             	add    $0x10,%esp
f01030c7:	85 c0                	test   %eax,%eax
f01030c9:	0f 84 7d 01 00 00    	je     f010324c <env_alloc+0x1a7>
	return (pp - pages) << PGSHIFT;
f01030cf:	89 c2                	mov    %eax,%edx
f01030d1:	2b 15 90 2e 23 f0    	sub    0xf0232e90,%edx
f01030d7:	c1 fa 03             	sar    $0x3,%edx
f01030da:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f01030dd:	89 d1                	mov    %edx,%ecx
f01030df:	c1 e9 0c             	shr    $0xc,%ecx
f01030e2:	3b 0d 88 2e 23 f0    	cmp    0xf0232e88,%ecx
f01030e8:	0f 83 30 01 00 00    	jae    f010321e <env_alloc+0x179>
	return (void *)(pa + KERNBASE);
f01030ee:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f01030f4:	89 53 60             	mov    %edx,0x60(%ebx)
	p->pp_ref++;
f01030f7:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
f01030fc:	b8 00 00 00 00       	mov    $0x0,%eax
		e->env_pgdir[i] = 0;
f0103101:	8b 53 60             	mov    0x60(%ebx),%edx
f0103104:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
f010310b:	83 c0 04             	add    $0x4,%eax
	for(i = 0; i < PDX(UTOP); i++) {
f010310e:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f0103113:	75 ec                	jne    f0103101 <env_alloc+0x5c>
		e->env_pgdir[i] = kern_pgdir[i];
f0103115:	8b 15 8c 2e 23 f0    	mov    0xf0232e8c,%edx
f010311b:	8b 0c 02             	mov    (%edx,%eax,1),%ecx
f010311e:	8b 53 60             	mov    0x60(%ebx),%edx
f0103121:	89 0c 02             	mov    %ecx,(%edx,%eax,1)
f0103124:	83 c0 04             	add    $0x4,%eax
	for(i = PDX(UTOP); i < NPDENTRIES; i++) {
f0103127:	3d 00 10 00 00       	cmp    $0x1000,%eax
f010312c:	75 e7                	jne    f0103115 <env_alloc+0x70>
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f010312e:	8b 43 60             	mov    0x60(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f0103131:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103136:	0f 86 f4 00 00 00    	jbe    f0103230 <env_alloc+0x18b>
	return (physaddr_t)kva - KERNBASE;
f010313c:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0103142:	83 ca 05             	or     $0x5,%edx
f0103145:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f010314b:	8b 43 48             	mov    0x48(%ebx),%eax
f010314e:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0103153:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f0103158:	ba 00 10 00 00       	mov    $0x1000,%edx
f010315d:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f0103160:	89 da                	mov    %ebx,%edx
f0103162:	2b 15 44 22 23 f0    	sub    0xf0232244,%edx
f0103168:	c1 fa 02             	sar    $0x2,%edx
f010316b:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f0103171:	09 d0                	or     %edx,%eax
f0103173:	89 43 48             	mov    %eax,0x48(%ebx)
	e->env_parent_id = parent_id;
f0103176:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103179:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f010317c:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0103183:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f010318a:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0103191:	83 ec 04             	sub    $0x4,%esp
f0103194:	6a 44                	push   $0x44
f0103196:	6a 00                	push   $0x0
f0103198:	53                   	push   %ebx
f0103199:	e8 30 1e 00 00       	call   f0104fce <memset>
	e->env_tf.tf_ds = GD_UD | 3;
f010319e:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f01031a4:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f01031aa:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f01031b0:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f01031b7:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	e->env_pgfault_upcall = 0;
f01031bd:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)
	e->env_ipc_recving = 0;
f01031c4:	c6 43 68 00          	movb   $0x0,0x68(%ebx)
	env_free_list = e->env_link;
f01031c8:	8b 43 44             	mov    0x44(%ebx),%eax
f01031cb:	a3 48 22 23 f0       	mov    %eax,0xf0232248
	*newenv_store = e;
f01031d0:	8b 45 08             	mov    0x8(%ebp),%eax
f01031d3:	89 18                	mov    %ebx,(%eax)
	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01031d5:	8b 5b 48             	mov    0x48(%ebx),%ebx
f01031d8:	e8 f1 23 00 00       	call   f01055ce <cpunum>
f01031dd:	6b c0 74             	imul   $0x74,%eax,%eax
f01031e0:	83 c4 10             	add    $0x10,%esp
f01031e3:	ba 00 00 00 00       	mov    $0x0,%edx
f01031e8:	83 b8 28 30 23 f0 00 	cmpl   $0x0,-0xfdccfd8(%eax)
f01031ef:	74 11                	je     f0103202 <env_alloc+0x15d>
f01031f1:	e8 d8 23 00 00       	call   f01055ce <cpunum>
f01031f6:	6b c0 74             	imul   $0x74,%eax,%eax
f01031f9:	8b 80 28 30 23 f0    	mov    -0xfdccfd8(%eax),%eax
f01031ff:	8b 50 48             	mov    0x48(%eax),%edx
f0103202:	83 ec 04             	sub    $0x4,%esp
f0103205:	53                   	push   %ebx
f0103206:	52                   	push   %edx
f0103207:	68 78 6e 10 f0       	push   $0xf0106e78
f010320c:	e8 2d 06 00 00       	call   f010383e <cprintf>
	return 0;
f0103211:	83 c4 10             	add    $0x10,%esp
f0103214:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103219:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010321c:	c9                   	leave  
f010321d:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010321e:	52                   	push   %edx
f010321f:	68 d4 5c 10 f0       	push   $0xf0105cd4
f0103224:	6a 58                	push   $0x58
f0103226:	68 24 62 10 f0       	push   $0xf0106224
f010322b:	e8 64 ce ff ff       	call   f0100094 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103230:	50                   	push   %eax
f0103231:	68 f8 5c 10 f0       	push   $0xf0105cf8
f0103236:	68 d0 00 00 00       	push   $0xd0
f010323b:	68 6d 6e 10 f0       	push   $0xf0106e6d
f0103240:	e8 4f ce ff ff       	call   f0100094 <_panic>
		return -E_NO_FREE_ENV;
f0103245:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f010324a:	eb cd                	jmp    f0103219 <env_alloc+0x174>
		return -E_NO_MEM;
f010324c:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0103251:	eb c6                	jmp    f0103219 <env_alloc+0x174>

f0103253 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f0103253:	55                   	push   %ebp
f0103254:	89 e5                	mov    %esp,%ebp
f0103256:	57                   	push   %edi
f0103257:	56                   	push   %esi
f0103258:	53                   	push   %ebx
f0103259:	83 ec 34             	sub    $0x34,%esp
f010325c:	8b 75 08             	mov    0x8(%ebp),%esi
	// LAB 3: Your code here.
	struct 	Env *e;	
	int r = env_alloc(&e, (envid_t)0);
f010325f:	6a 00                	push   $0x0
f0103261:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103264:	50                   	push   %eax
f0103265:	e8 3b fe ff ff       	call   f01030a5 <env_alloc>
	if (r < 0) {
f010326a:	83 c4 10             	add    $0x10,%esp
f010326d:	85 c0                	test   %eax,%eax
f010326f:	78 36                	js     f01032a7 <env_create+0x54>
		 panic("env_create: %e", r);
	}
//	cprintf("new_env:%p\n",e);
	e->env_type = type;
f0103271:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103274:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103277:	89 47 50             	mov    %eax,0x50(%edi)
	if (elf->e_magic != ELF_MAGIC) {
f010327a:	81 3e 7f 45 4c 46    	cmpl   $0x464c457f,(%esi)
f0103280:	75 3a                	jne    f01032bc <env_create+0x69>
	ph = (struct Proghdr *) (binary + elf->e_phoff);
f0103282:	89 f3                	mov    %esi,%ebx
f0103284:	03 5e 1c             	add    0x1c(%esi),%ebx
	eph = ph + elf->e_phnum;
f0103287:	0f b7 46 2c          	movzwl 0x2c(%esi),%eax
f010328b:	c1 e0 05             	shl    $0x5,%eax
f010328e:	01 d8                	add    %ebx,%eax
f0103290:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	lcr3(PADDR(e->env_pgdir));
f0103293:	8b 47 60             	mov    0x60(%edi),%eax
	if ((uint32_t)kva < KERNBASE)
f0103296:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010329b:	76 36                	jbe    f01032d3 <env_create+0x80>
	return (physaddr_t)kva - KERNBASE;
f010329d:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01032a2:	0f 22 d8             	mov    %eax,%cr3
f01032a5:	eb 5b                	jmp    f0103302 <env_create+0xaf>
		 panic("env_create: %e", r);
f01032a7:	50                   	push   %eax
f01032a8:	68 8d 6e 10 f0       	push   $0xf0106e8d
f01032ad:	68 9f 01 00 00       	push   $0x19f
f01032b2:	68 6d 6e 10 f0       	push   $0xf0106e6d
f01032b7:	e8 d8 cd ff ff       	call   f0100094 <_panic>
		 panic("load_icode: not an Elf file");
f01032bc:	83 ec 04             	sub    $0x4,%esp
f01032bf:	68 9c 6e 10 f0       	push   $0xf0106e9c
f01032c4:	68 76 01 00 00       	push   $0x176
f01032c9:	68 6d 6e 10 f0       	push   $0xf0106e6d
f01032ce:	e8 c1 cd ff ff       	call   f0100094 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01032d3:	50                   	push   %eax
f01032d4:	68 f8 5c 10 f0       	push   $0xf0105cf8
f01032d9:	68 7b 01 00 00       	push   $0x17b
f01032de:	68 6d 6e 10 f0       	push   $0xf0106e6d
f01032e3:	e8 ac cd ff ff       	call   f0100094 <_panic>
					 panic("load_icode: file size is greater than memory size");
f01032e8:	83 ec 04             	sub    $0x4,%esp
f01032eb:	68 dc 6e 10 f0       	push   $0xf0106edc
f01032f0:	68 7f 01 00 00       	push   $0x17f
f01032f5:	68 6d 6e 10 f0       	push   $0xf0106e6d
f01032fa:	e8 95 cd ff ff       	call   f0100094 <_panic>
	for (; ph<eph; ph++) {
f01032ff:	83 c3 20             	add    $0x20,%ebx
f0103302:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0103305:	76 47                	jbe    f010334e <env_create+0xfb>
		if (ph->p_type == ELF_PROG_LOAD) {
f0103307:	83 3b 01             	cmpl   $0x1,(%ebx)
f010330a:	75 f3                	jne    f01032ff <env_create+0xac>
			 if (ph->p_filesz > ph->p_memsz) {
f010330c:	8b 4b 14             	mov    0x14(%ebx),%ecx
f010330f:	39 4b 10             	cmp    %ecx,0x10(%ebx)
f0103312:	77 d4                	ja     f01032e8 <env_create+0x95>
			 region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f0103314:	8b 53 08             	mov    0x8(%ebx),%edx
f0103317:	89 f8                	mov    %edi,%eax
f0103319:	e8 f1 fb ff ff       	call   f0102f0f <region_alloc>
			 memcpy((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
f010331e:	83 ec 04             	sub    $0x4,%esp
f0103321:	ff 73 10             	pushl  0x10(%ebx)
f0103324:	89 f0                	mov    %esi,%eax
f0103326:	03 43 04             	add    0x4(%ebx),%eax
f0103329:	50                   	push   %eax
f010332a:	ff 73 08             	pushl  0x8(%ebx)
f010332d:	e8 46 1d 00 00       	call   f0105078 <memcpy>
			 memset((void *)ph->p_va + ph->p_filesz, 0, ph->p_memsz - ph->p_filesz);
f0103332:	8b 43 10             	mov    0x10(%ebx),%eax
f0103335:	83 c4 0c             	add    $0xc,%esp
f0103338:	8b 53 14             	mov    0x14(%ebx),%edx
f010333b:	29 c2                	sub    %eax,%edx
f010333d:	52                   	push   %edx
f010333e:	6a 00                	push   $0x0
f0103340:	03 43 08             	add    0x8(%ebx),%eax
f0103343:	50                   	push   %eax
f0103344:	e8 85 1c 00 00       	call   f0104fce <memset>
f0103349:	83 c4 10             	add    $0x10,%esp
f010334c:	eb b1                	jmp    f01032ff <env_create+0xac>
	e->env_tf.tf_eip = elf->e_entry;
f010334e:	8b 46 18             	mov    0x18(%esi),%eax
f0103351:	89 47 30             	mov    %eax,0x30(%edi)
	region_alloc(e, (void *)USTACKTOP - PGSIZE, PGSIZE);
f0103354:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0103359:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f010335e:	89 f8                	mov    %edi,%eax
f0103360:	e8 aa fb ff ff       	call   f0102f0f <region_alloc>
	lcr3(PADDR(kern_pgdir));
f0103365:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f010336a:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010336f:	76 10                	jbe    f0103381 <env_create+0x12e>
	return (physaddr_t)kva - KERNBASE;
f0103371:	05 00 00 00 10       	add    $0x10000000,%eax
f0103376:	0f 22 d8             	mov    %eax,%cr3
//	cprintf("binary:%p\n", binary);
	load_icode(e, binary);
}
f0103379:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010337c:	5b                   	pop    %ebx
f010337d:	5e                   	pop    %esi
f010337e:	5f                   	pop    %edi
f010337f:	5d                   	pop    %ebp
f0103380:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103381:	50                   	push   %eax
f0103382:	68 f8 5c 10 f0       	push   $0xf0105cf8
f0103387:	68 8e 01 00 00       	push   $0x18e
f010338c:	68 6d 6e 10 f0       	push   $0xf0106e6d
f0103391:	e8 fe cc ff ff       	call   f0100094 <_panic>

f0103396 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0103396:	55                   	push   %ebp
f0103397:	89 e5                	mov    %esp,%ebp
f0103399:	57                   	push   %edi
f010339a:	56                   	push   %esi
f010339b:	53                   	push   %ebx
f010339c:	83 ec 1c             	sub    $0x1c,%esp
f010339f:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f01033a2:	e8 27 22 00 00       	call   f01055ce <cpunum>
f01033a7:	6b c0 74             	imul   $0x74,%eax,%eax
f01033aa:	39 b8 28 30 23 f0    	cmp    %edi,-0xfdccfd8(%eax)
f01033b0:	74 48                	je     f01033fa <env_free+0x64>
		lcr3(PADDR(kern_pgdir));

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01033b2:	8b 5f 48             	mov    0x48(%edi),%ebx
f01033b5:	e8 14 22 00 00       	call   f01055ce <cpunum>
f01033ba:	6b c0 74             	imul   $0x74,%eax,%eax
f01033bd:	ba 00 00 00 00       	mov    $0x0,%edx
f01033c2:	83 b8 28 30 23 f0 00 	cmpl   $0x0,-0xfdccfd8(%eax)
f01033c9:	74 11                	je     f01033dc <env_free+0x46>
f01033cb:	e8 fe 21 00 00       	call   f01055ce <cpunum>
f01033d0:	6b c0 74             	imul   $0x74,%eax,%eax
f01033d3:	8b 80 28 30 23 f0    	mov    -0xfdccfd8(%eax),%eax
f01033d9:	8b 50 48             	mov    0x48(%eax),%edx
f01033dc:	83 ec 04             	sub    $0x4,%esp
f01033df:	53                   	push   %ebx
f01033e0:	52                   	push   %edx
f01033e1:	68 b8 6e 10 f0       	push   $0xf0106eb8
f01033e6:	e8 53 04 00 00       	call   f010383e <cprintf>
f01033eb:	83 c4 10             	add    $0x10,%esp
f01033ee:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f01033f5:	e9 a9 00 00 00       	jmp    f01034a3 <env_free+0x10d>
		lcr3(PADDR(kern_pgdir));
f01033fa:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f01033ff:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103404:	76 0a                	jbe    f0103410 <env_free+0x7a>
	return (physaddr_t)kva - KERNBASE;
f0103406:	05 00 00 00 10       	add    $0x10000000,%eax
f010340b:	0f 22 d8             	mov    %eax,%cr3
f010340e:	eb a2                	jmp    f01033b2 <env_free+0x1c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103410:	50                   	push   %eax
f0103411:	68 f8 5c 10 f0       	push   $0xf0105cf8
f0103416:	68 b5 01 00 00       	push   $0x1b5
f010341b:	68 6d 6e 10 f0       	push   $0xf0106e6d
f0103420:	e8 6f cc ff ff       	call   f0100094 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103425:	56                   	push   %esi
f0103426:	68 d4 5c 10 f0       	push   $0xf0105cd4
f010342b:	68 c4 01 00 00       	push   $0x1c4
f0103430:	68 6d 6e 10 f0       	push   $0xf0106e6d
f0103435:	e8 5a cc ff ff       	call   f0100094 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f010343a:	83 ec 08             	sub    $0x8,%esp
f010343d:	89 d8                	mov    %ebx,%eax
f010343f:	c1 e0 0c             	shl    $0xc,%eax
f0103442:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103445:	50                   	push   %eax
f0103446:	ff 77 60             	pushl  0x60(%edi)
f0103449:	e8 dc dd ff ff       	call   f010122a <page_remove>
f010344e:	83 c4 10             	add    $0x10,%esp
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103451:	83 c3 01             	add    $0x1,%ebx
f0103454:	83 c6 04             	add    $0x4,%esi
f0103457:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f010345d:	74 07                	je     f0103466 <env_free+0xd0>
			if (pt[pteno] & PTE_P)
f010345f:	f6 06 01             	testb  $0x1,(%esi)
f0103462:	74 ed                	je     f0103451 <env_free+0xbb>
f0103464:	eb d4                	jmp    f010343a <env_free+0xa4>
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103466:	8b 47 60             	mov    0x60(%edi),%eax
f0103469:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010346c:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
	if (PGNUM(pa) >= npages)
f0103473:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103476:	3b 05 88 2e 23 f0    	cmp    0xf0232e88,%eax
f010347c:	73 69                	jae    f01034e7 <env_free+0x151>
		page_decref(pa2page(pa));
f010347e:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f0103481:	a1 90 2e 23 f0       	mov    0xf0232e90,%eax
f0103486:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103489:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f010348c:	50                   	push   %eax
f010348d:	e8 ca db ff ff       	call   f010105c <page_decref>
f0103492:	83 c4 10             	add    $0x10,%esp
f0103495:	83 45 e0 04          	addl   $0x4,-0x20(%ebp)
f0103499:	8b 45 e0             	mov    -0x20(%ebp),%eax
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f010349c:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f01034a1:	74 58                	je     f01034fb <env_free+0x165>
		if (!(e->env_pgdir[pdeno] & PTE_P))
f01034a3:	8b 47 60             	mov    0x60(%edi),%eax
f01034a6:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01034a9:	8b 34 10             	mov    (%eax,%edx,1),%esi
f01034ac:	f7 c6 01 00 00 00    	test   $0x1,%esi
f01034b2:	74 e1                	je     f0103495 <env_free+0xff>
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f01034b4:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	if (PGNUM(pa) >= npages)
f01034ba:	89 f0                	mov    %esi,%eax
f01034bc:	c1 e8 0c             	shr    $0xc,%eax
f01034bf:	89 45 dc             	mov    %eax,-0x24(%ebp)
f01034c2:	39 05 88 2e 23 f0    	cmp    %eax,0xf0232e88
f01034c8:	0f 86 57 ff ff ff    	jbe    f0103425 <env_free+0x8f>
	return (void *)(pa + KERNBASE);
f01034ce:	81 ee 00 00 00 10    	sub    $0x10000000,%esi
f01034d4:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01034d7:	c1 e0 14             	shl    $0x14,%eax
f01034da:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01034dd:	bb 00 00 00 00       	mov    $0x0,%ebx
f01034e2:	e9 78 ff ff ff       	jmp    f010345f <env_free+0xc9>
		panic("pa2page called with invalid pa");
f01034e7:	83 ec 04             	sub    $0x4,%esp
f01034ea:	68 5c 66 10 f0       	push   $0xf010665c
f01034ef:	6a 51                	push   $0x51
f01034f1:	68 24 62 10 f0       	push   $0xf0106224
f01034f6:	e8 99 cb ff ff       	call   f0100094 <_panic>
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f01034fb:	8b 47 60             	mov    0x60(%edi),%eax
	if ((uint32_t)kva < KERNBASE)
f01034fe:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103503:	76 49                	jbe    f010354e <env_free+0x1b8>
	e->env_pgdir = 0;
f0103505:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
	return (physaddr_t)kva - KERNBASE;
f010350c:	05 00 00 00 10       	add    $0x10000000,%eax
	if (PGNUM(pa) >= npages)
f0103511:	c1 e8 0c             	shr    $0xc,%eax
f0103514:	3b 05 88 2e 23 f0    	cmp    0xf0232e88,%eax
f010351a:	73 47                	jae    f0103563 <env_free+0x1cd>
	page_decref(pa2page(pa));
f010351c:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f010351f:	8b 15 90 2e 23 f0    	mov    0xf0232e90,%edx
f0103525:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f0103528:	50                   	push   %eax
f0103529:	e8 2e db ff ff       	call   f010105c <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f010352e:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103535:	a1 48 22 23 f0       	mov    0xf0232248,%eax
f010353a:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f010353d:	89 3d 48 22 23 f0    	mov    %edi,0xf0232248
}
f0103543:	83 c4 10             	add    $0x10,%esp
f0103546:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103549:	5b                   	pop    %ebx
f010354a:	5e                   	pop    %esi
f010354b:	5f                   	pop    %edi
f010354c:	5d                   	pop    %ebp
f010354d:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010354e:	50                   	push   %eax
f010354f:	68 f8 5c 10 f0       	push   $0xf0105cf8
f0103554:	68 d2 01 00 00       	push   $0x1d2
f0103559:	68 6d 6e 10 f0       	push   $0xf0106e6d
f010355e:	e8 31 cb ff ff       	call   f0100094 <_panic>
		panic("pa2page called with invalid pa");
f0103563:	83 ec 04             	sub    $0x4,%esp
f0103566:	68 5c 66 10 f0       	push   $0xf010665c
f010356b:	6a 51                	push   $0x51
f010356d:	68 24 62 10 f0       	push   $0xf0106224
f0103572:	e8 1d cb ff ff       	call   f0100094 <_panic>

f0103577 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0103577:	55                   	push   %ebp
f0103578:	89 e5                	mov    %esp,%ebp
f010357a:	53                   	push   %ebx
f010357b:	83 ec 04             	sub    $0x4,%esp
f010357e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103581:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0103585:	74 21                	je     f01035a8 <env_destroy+0x31>
		e->env_status = ENV_DYING;
		return;
	}

	env_free(e);
f0103587:	83 ec 0c             	sub    $0xc,%esp
f010358a:	53                   	push   %ebx
f010358b:	e8 06 fe ff ff       	call   f0103396 <env_free>

	if (curenv == e) {
f0103590:	e8 39 20 00 00       	call   f01055ce <cpunum>
f0103595:	6b c0 74             	imul   $0x74,%eax,%eax
f0103598:	83 c4 10             	add    $0x10,%esp
f010359b:	39 98 28 30 23 f0    	cmp    %ebx,-0xfdccfd8(%eax)
f01035a1:	74 1e                	je     f01035c1 <env_destroy+0x4a>
		curenv = NULL;
		sched_yield();
	}
}
f01035a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01035a6:	c9                   	leave  
f01035a7:	c3                   	ret    
	if (e->env_status == ENV_RUNNING && curenv != e) {
f01035a8:	e8 21 20 00 00       	call   f01055ce <cpunum>
f01035ad:	6b c0 74             	imul   $0x74,%eax,%eax
f01035b0:	39 98 28 30 23 f0    	cmp    %ebx,-0xfdccfd8(%eax)
f01035b6:	74 cf                	je     f0103587 <env_destroy+0x10>
		e->env_status = ENV_DYING;
f01035b8:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f01035bf:	eb e2                	jmp    f01035a3 <env_destroy+0x2c>
		curenv = NULL;
f01035c1:	e8 08 20 00 00       	call   f01055ce <cpunum>
f01035c6:	6b c0 74             	imul   $0x74,%eax,%eax
f01035c9:	c7 80 28 30 23 f0 00 	movl   $0x0,-0xfdccfd8(%eax)
f01035d0:	00 00 00 
		sched_yield();
f01035d3:	e8 6d 0d 00 00       	call   f0104345 <sched_yield>

f01035d8 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f01035d8:	55                   	push   %ebp
f01035d9:	89 e5                	mov    %esp,%ebp
f01035db:	53                   	push   %ebx
f01035dc:	83 ec 04             	sub    $0x4,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f01035df:	e8 ea 1f 00 00       	call   f01055ce <cpunum>
f01035e4:	6b c0 74             	imul   $0x74,%eax,%eax
f01035e7:	8b 98 28 30 23 f0    	mov    -0xfdccfd8(%eax),%ebx
f01035ed:	e8 dc 1f 00 00       	call   f01055ce <cpunum>
f01035f2:	89 43 5c             	mov    %eax,0x5c(%ebx)

	asm volatile(
f01035f5:	8b 65 08             	mov    0x8(%ebp),%esp
f01035f8:	61                   	popa   
f01035f9:	07                   	pop    %es
f01035fa:	1f                   	pop    %ds
f01035fb:	83 c4 08             	add    $0x8,%esp
f01035fe:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f01035ff:	83 ec 04             	sub    $0x4,%esp
f0103602:	68 ce 6e 10 f0       	push   $0xf0106ece
f0103607:	68 09 02 00 00       	push   $0x209
f010360c:	68 6d 6e 10 f0       	push   $0xf0106e6d
f0103611:	e8 7e ca ff ff       	call   f0100094 <_panic>

f0103616 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103616:	55                   	push   %ebp
f0103617:	89 e5                	mov    %esp,%ebp
f0103619:	53                   	push   %ebx
f010361a:	83 ec 04             	sub    $0x4,%esp
f010361d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	if (curenv && curenv->env_status == ENV_RUNNING) {
f0103620:	e8 a9 1f 00 00       	call   f01055ce <cpunum>
f0103625:	6b c0 74             	imul   $0x74,%eax,%eax
f0103628:	83 b8 28 30 23 f0 00 	cmpl   $0x0,-0xfdccfd8(%eax)
f010362f:	74 14                	je     f0103645 <env_run+0x2f>
f0103631:	e8 98 1f 00 00       	call   f01055ce <cpunum>
f0103636:	6b c0 74             	imul   $0x74,%eax,%eax
f0103639:	8b 80 28 30 23 f0    	mov    -0xfdccfd8(%eax),%eax
f010363f:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103643:	74 42                	je     f0103687 <env_run+0x71>
		 curenv->env_status = ENV_RUNNABLE;
	}
		 curenv = e;
f0103645:	e8 84 1f 00 00       	call   f01055ce <cpunum>
f010364a:	6b c0 74             	imul   $0x74,%eax,%eax
f010364d:	89 98 28 30 23 f0    	mov    %ebx,-0xfdccfd8(%eax)
		 e->env_status = ENV_RUNNING;
f0103653:	c7 43 54 03 00 00 00 	movl   $0x3,0x54(%ebx)
		 e->env_runs++ ;
f010365a:	83 43 58 01          	addl   $0x1,0x58(%ebx)
		 lcr3(PADDR(e->env_pgdir));
f010365e:	8b 43 60             	mov    0x60(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f0103661:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103666:	76 36                	jbe    f010369e <env_run+0x88>
	return (physaddr_t)kva - KERNBASE;
f0103668:	05 00 00 00 10       	add    $0x10000000,%eax
f010366d:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0103670:	83 ec 0c             	sub    $0xc,%esp
f0103673:	68 c0 23 12 f0       	push   $0xf01223c0
f0103678:	e8 5d 22 00 00       	call   f01058da <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f010367d:	f3 90                	pause  
		 unlock_kernel();
//		 cprintf("tf:%p\n", &e->env_tf);
//		 cprintf("esp:%p\n", e->env_tf.tf_esp);
//		 cprintf("pgdir:%p\n", e->env_pgdir);
		 env_pop_tf(&e->env_tf);
f010367f:	89 1c 24             	mov    %ebx,(%esp)
f0103682:	e8 51 ff ff ff       	call   f01035d8 <env_pop_tf>
		 curenv->env_status = ENV_RUNNABLE;
f0103687:	e8 42 1f 00 00       	call   f01055ce <cpunum>
f010368c:	6b c0 74             	imul   $0x74,%eax,%eax
f010368f:	8b 80 28 30 23 f0    	mov    -0xfdccfd8(%eax),%eax
f0103695:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
f010369c:	eb a7                	jmp    f0103645 <env_run+0x2f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010369e:	50                   	push   %eax
f010369f:	68 f8 5c 10 f0       	push   $0xf0105cf8
f01036a4:	68 2d 02 00 00       	push   $0x22d
f01036a9:	68 6d 6e 10 f0       	push   $0xf0106e6d
f01036ae:	e8 e1 c9 ff ff       	call   f0100094 <_panic>

f01036b3 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f01036b3:	55                   	push   %ebp
f01036b4:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01036b6:	8b 45 08             	mov    0x8(%ebp),%eax
f01036b9:	ba 70 00 00 00       	mov    $0x70,%edx
f01036be:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01036bf:	ba 71 00 00 00       	mov    $0x71,%edx
f01036c4:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f01036c5:	0f b6 c0             	movzbl %al,%eax
}
f01036c8:	5d                   	pop    %ebp
f01036c9:	c3                   	ret    

f01036ca <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f01036ca:	55                   	push   %ebp
f01036cb:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01036cd:	8b 45 08             	mov    0x8(%ebp),%eax
f01036d0:	ba 70 00 00 00       	mov    $0x70,%edx
f01036d5:	ee                   	out    %al,(%dx)
f01036d6:	8b 45 0c             	mov    0xc(%ebp),%eax
f01036d9:	ba 71 00 00 00       	mov    $0x71,%edx
f01036de:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f01036df:	5d                   	pop    %ebp
f01036e0:	c3                   	ret    

f01036e1 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f01036e1:	55                   	push   %ebp
f01036e2:	89 e5                	mov    %esp,%ebp
f01036e4:	56                   	push   %esi
f01036e5:	53                   	push   %ebx
f01036e6:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f01036e9:	66 a3 a8 23 12 f0    	mov    %ax,0xf01223a8
	if (!didinit)
f01036ef:	80 3d 4c 22 23 f0 00 	cmpb   $0x0,0xf023224c
f01036f6:	75 07                	jne    f01036ff <irq_setmask_8259A+0x1e>
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
}
f01036f8:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01036fb:	5b                   	pop    %ebx
f01036fc:	5e                   	pop    %esi
f01036fd:	5d                   	pop    %ebp
f01036fe:	c3                   	ret    
f01036ff:	89 c6                	mov    %eax,%esi
f0103701:	ba 21 00 00 00       	mov    $0x21,%edx
f0103706:	ee                   	out    %al,(%dx)
	outb(IO_PIC2+1, (char)(mask >> 8));
f0103707:	66 c1 e8 08          	shr    $0x8,%ax
f010370b:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103710:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f0103711:	83 ec 0c             	sub    $0xc,%esp
f0103714:	68 0e 6f 10 f0       	push   $0xf0106f0e
f0103719:	e8 20 01 00 00       	call   f010383e <cprintf>
f010371e:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f0103721:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0103726:	0f b7 f6             	movzwl %si,%esi
f0103729:	f7 d6                	not    %esi
f010372b:	eb 19                	jmp    f0103746 <irq_setmask_8259A+0x65>
			cprintf(" %d", i);
f010372d:	83 ec 08             	sub    $0x8,%esp
f0103730:	53                   	push   %ebx
f0103731:	68 d3 73 10 f0       	push   $0xf01073d3
f0103736:	e8 03 01 00 00       	call   f010383e <cprintf>
f010373b:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f010373e:	83 c3 01             	add    $0x1,%ebx
f0103741:	83 fb 10             	cmp    $0x10,%ebx
f0103744:	74 07                	je     f010374d <irq_setmask_8259A+0x6c>
		if (~mask & (1<<i))
f0103746:	0f a3 de             	bt     %ebx,%esi
f0103749:	73 f3                	jae    f010373e <irq_setmask_8259A+0x5d>
f010374b:	eb e0                	jmp    f010372d <irq_setmask_8259A+0x4c>
	cprintf("\n");
f010374d:	83 ec 0c             	sub    $0xc,%esp
f0103750:	68 0a 65 10 f0       	push   $0xf010650a
f0103755:	e8 e4 00 00 00       	call   f010383e <cprintf>
f010375a:	83 c4 10             	add    $0x10,%esp
f010375d:	eb 99                	jmp    f01036f8 <irq_setmask_8259A+0x17>

f010375f <pic_init>:
{
f010375f:	55                   	push   %ebp
f0103760:	89 e5                	mov    %esp,%ebp
f0103762:	57                   	push   %edi
f0103763:	56                   	push   %esi
f0103764:	53                   	push   %ebx
f0103765:	83 ec 0c             	sub    $0xc,%esp
	didinit = 1;
f0103768:	c6 05 4c 22 23 f0 01 	movb   $0x1,0xf023224c
f010376f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103774:	bb 21 00 00 00       	mov    $0x21,%ebx
f0103779:	89 da                	mov    %ebx,%edx
f010377b:	ee                   	out    %al,(%dx)
f010377c:	b9 a1 00 00 00       	mov    $0xa1,%ecx
f0103781:	89 ca                	mov    %ecx,%edx
f0103783:	ee                   	out    %al,(%dx)
f0103784:	bf 11 00 00 00       	mov    $0x11,%edi
f0103789:	be 20 00 00 00       	mov    $0x20,%esi
f010378e:	89 f8                	mov    %edi,%eax
f0103790:	89 f2                	mov    %esi,%edx
f0103792:	ee                   	out    %al,(%dx)
f0103793:	b8 20 00 00 00       	mov    $0x20,%eax
f0103798:	89 da                	mov    %ebx,%edx
f010379a:	ee                   	out    %al,(%dx)
f010379b:	b8 04 00 00 00       	mov    $0x4,%eax
f01037a0:	ee                   	out    %al,(%dx)
f01037a1:	b8 03 00 00 00       	mov    $0x3,%eax
f01037a6:	ee                   	out    %al,(%dx)
f01037a7:	bb a0 00 00 00       	mov    $0xa0,%ebx
f01037ac:	89 f8                	mov    %edi,%eax
f01037ae:	89 da                	mov    %ebx,%edx
f01037b0:	ee                   	out    %al,(%dx)
f01037b1:	b8 28 00 00 00       	mov    $0x28,%eax
f01037b6:	89 ca                	mov    %ecx,%edx
f01037b8:	ee                   	out    %al,(%dx)
f01037b9:	b8 02 00 00 00       	mov    $0x2,%eax
f01037be:	ee                   	out    %al,(%dx)
f01037bf:	b8 01 00 00 00       	mov    $0x1,%eax
f01037c4:	ee                   	out    %al,(%dx)
f01037c5:	bf 68 00 00 00       	mov    $0x68,%edi
f01037ca:	89 f8                	mov    %edi,%eax
f01037cc:	89 f2                	mov    %esi,%edx
f01037ce:	ee                   	out    %al,(%dx)
f01037cf:	b9 0a 00 00 00       	mov    $0xa,%ecx
f01037d4:	89 c8                	mov    %ecx,%eax
f01037d6:	ee                   	out    %al,(%dx)
f01037d7:	89 f8                	mov    %edi,%eax
f01037d9:	89 da                	mov    %ebx,%edx
f01037db:	ee                   	out    %al,(%dx)
f01037dc:	89 c8                	mov    %ecx,%eax
f01037de:	ee                   	out    %al,(%dx)
	if (irq_mask_8259A != 0xFFFF)
f01037df:	0f b7 05 a8 23 12 f0 	movzwl 0xf01223a8,%eax
f01037e6:	66 83 f8 ff          	cmp    $0xffff,%ax
f01037ea:	75 08                	jne    f01037f4 <pic_init+0x95>
}
f01037ec:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01037ef:	5b                   	pop    %ebx
f01037f0:	5e                   	pop    %esi
f01037f1:	5f                   	pop    %edi
f01037f2:	5d                   	pop    %ebp
f01037f3:	c3                   	ret    
		irq_setmask_8259A(irq_mask_8259A);
f01037f4:	83 ec 0c             	sub    $0xc,%esp
f01037f7:	0f b7 c0             	movzwl %ax,%eax
f01037fa:	50                   	push   %eax
f01037fb:	e8 e1 fe ff ff       	call   f01036e1 <irq_setmask_8259A>
f0103800:	83 c4 10             	add    $0x10,%esp
}
f0103803:	eb e7                	jmp    f01037ec <pic_init+0x8d>

f0103805 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103805:	55                   	push   %ebp
f0103806:	89 e5                	mov    %esp,%ebp
f0103808:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f010380b:	ff 75 08             	pushl  0x8(%ebp)
f010380e:	e8 b9 cf ff ff       	call   f01007cc <cputchar>
	*cnt++;
}
f0103813:	83 c4 10             	add    $0x10,%esp
f0103816:	c9                   	leave  
f0103817:	c3                   	ret    

f0103818 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103818:	55                   	push   %ebp
f0103819:	89 e5                	mov    %esp,%ebp
f010381b:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f010381e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103825:	ff 75 0c             	pushl  0xc(%ebp)
f0103828:	ff 75 08             	pushl  0x8(%ebp)
f010382b:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010382e:	50                   	push   %eax
f010382f:	68 05 38 10 f0       	push   $0xf0103805
f0103834:	e8 8d 10 00 00       	call   f01048c6 <vprintfmt>
	return cnt;
}
f0103839:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010383c:	c9                   	leave  
f010383d:	c3                   	ret    

f010383e <cprintf>:

int
cprintf(const char *fmt, ...)
{
f010383e:	55                   	push   %ebp
f010383f:	89 e5                	mov    %esp,%ebp
f0103841:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103844:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103847:	50                   	push   %eax
f0103848:	ff 75 08             	pushl  0x8(%ebp)
f010384b:	e8 c8 ff ff ff       	call   f0103818 <vcprintf>
	va_end(ap);

	return cnt;
}
f0103850:	c9                   	leave  
f0103851:	c3                   	ret    

f0103852 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103852:	55                   	push   %ebp
f0103853:	89 e5                	mov    %esp,%ebp
f0103855:	56                   	push   %esi
f0103856:	53                   	push   %ebx
	// get a triple fault.  If you set up an individual CPU's TSS
	// wrong, you may not get a fault until you try to return from
	// user space on that CPU.
	//
	// LAB 4: Your code here:
	struct Taskstate *this_ts = &thiscpu->cpu_ts;
f0103857:	e8 72 1d 00 00       	call   f01055ce <cpunum>
f010385c:	6b f0 74             	imul   $0x74,%eax,%esi
f010385f:	8d 9e 2c 30 23 f0    	lea    -0xfdccfd4(%esi),%ebx
	this_ts->ts_esp0 = KSTACKTOP - thiscpu->cpu_id*(KSTKSIZE + KSTKGAP);
f0103865:	e8 64 1d 00 00       	call   f01055ce <cpunum>
f010386a:	6b c0 74             	imul   $0x74,%eax,%eax
f010386d:	0f b6 88 20 30 23 f0 	movzbl -0xfdccfe0(%eax),%ecx
f0103874:	c1 e1 10             	shl    $0x10,%ecx
f0103877:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
f010387c:	29 c8                	sub    %ecx,%eax
f010387e:	89 86 30 30 23 f0    	mov    %eax,-0xfdccfd0(%esi)
	this_ts->ts_ss0 = GD_KD;
f0103884:	66 c7 86 34 30 23 f0 	movw   $0x10,-0xfdccfcc(%esi)
f010388b:	10 00 
	this_ts->ts_iomb = sizeof(struct Taskstate);
f010388d:	66 c7 86 92 30 23 f0 	movw   $0x68,-0xfdccf6e(%esi)
f0103894:	68 00 
//	ts.ts_esp0 = KSTACKTOP;
//	ts.ts_ss0 = GD_KD;
//	ts.ts_iomb = sizeof(struct Taskstate);

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3) + thiscpu->cpu_id] = SEG16(STS_T32A, (uint32_t) (this_ts),
f0103896:	e8 33 1d 00 00       	call   f01055ce <cpunum>
f010389b:	6b c0 74             	imul   $0x74,%eax,%eax
f010389e:	0f b6 80 20 30 23 f0 	movzbl -0xfdccfe0(%eax),%eax
f01038a5:	83 c0 05             	add    $0x5,%eax
f01038a8:	66 c7 04 c5 40 23 12 	movw   $0x67,-0xfeddcc0(,%eax,8)
f01038af:	f0 67 00 
f01038b2:	66 89 1c c5 42 23 12 	mov    %bx,-0xfeddcbe(,%eax,8)
f01038b9:	f0 
f01038ba:	89 da                	mov    %ebx,%edx
f01038bc:	c1 ea 10             	shr    $0x10,%edx
f01038bf:	88 14 c5 44 23 12 f0 	mov    %dl,-0xfeddcbc(,%eax,8)
f01038c6:	c6 04 c5 45 23 12 f0 	movb   $0x99,-0xfeddcbb(,%eax,8)
f01038cd:	99 
f01038ce:	c6 04 c5 46 23 12 f0 	movb   $0x40,-0xfeddcba(,%eax,8)
f01038d5:	40 
f01038d6:	c1 eb 18             	shr    $0x18,%ebx
f01038d9:	88 1c c5 47 23 12 f0 	mov    %bl,-0xfeddcb9(,%eax,8)
					sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3) + thiscpu->cpu_id].sd_s = 0;
f01038e0:	e8 e9 1c 00 00       	call   f01055ce <cpunum>
f01038e5:	6b c0 74             	imul   $0x74,%eax,%eax
f01038e8:	0f b6 80 20 30 23 f0 	movzbl -0xfdccfe0(%eax),%eax
f01038ef:	80 24 c5 6d 23 12 f0 	andb   $0xef,-0xfeddc93(,%eax,8)
f01038f6:	ef 

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0 + (thiscpu->cpu_id << 3));
f01038f7:	e8 d2 1c 00 00       	call   f01055ce <cpunum>
f01038fc:	6b c0 74             	imul   $0x74,%eax,%eax
f01038ff:	0f b6 80 20 30 23 f0 	movzbl -0xfdccfe0(%eax),%eax
f0103906:	8d 04 c5 28 00 00 00 	lea    0x28(,%eax,8),%eax
	asm volatile("ltr %0" : : "r" (sel));
f010390d:	0f 00 d8             	ltr    %ax
	asm volatile("lidt (%0)" : : "r" (p));
f0103910:	b8 ac 23 12 f0       	mov    $0xf01223ac,%eax
f0103915:	0f 01 18             	lidtl  (%eax)

	// Load the IDT
	lidt(&idt_pd);
}
f0103918:	5b                   	pop    %ebx
f0103919:	5e                   	pop    %esi
f010391a:	5d                   	pop    %ebp
f010391b:	c3                   	ret    

f010391c <trap_init>:
{
f010391c:	55                   	push   %ebp
f010391d:	89 e5                	mov    %esp,%ebp
f010391f:	83 ec 08             	sub    $0x8,%esp
    SETGATE(idt[T_DIVIDE], 1, GD_KT, traphandler0, 0);
f0103922:	b8 fe 41 10 f0       	mov    $0xf01041fe,%eax
f0103927:	66 a3 60 22 23 f0    	mov    %ax,0xf0232260
f010392d:	66 c7 05 62 22 23 f0 	movw   $0x8,0xf0232262
f0103934:	08 00 
f0103936:	c6 05 64 22 23 f0 00 	movb   $0x0,0xf0232264
f010393d:	c6 05 65 22 23 f0 8f 	movb   $0x8f,0xf0232265
f0103944:	c1 e8 10             	shr    $0x10,%eax
f0103947:	66 a3 66 22 23 f0    	mov    %ax,0xf0232266
    SETGATE(idt[T_DEBUG], 1, GD_KT, traphandler1, 0);
f010394d:	b8 04 42 10 f0       	mov    $0xf0104204,%eax
f0103952:	66 a3 68 22 23 f0    	mov    %ax,0xf0232268
f0103958:	66 c7 05 6a 22 23 f0 	movw   $0x8,0xf023226a
f010395f:	08 00 
f0103961:	c6 05 6c 22 23 f0 00 	movb   $0x0,0xf023226c
f0103968:	c6 05 6d 22 23 f0 8f 	movb   $0x8f,0xf023226d
f010396f:	c1 e8 10             	shr    $0x10,%eax
f0103972:	66 a3 6e 22 23 f0    	mov    %ax,0xf023226e
    SETGATE(idt[T_NMI], 1, GD_KT, traphandler2, 0);
f0103978:	b8 0a 42 10 f0       	mov    $0xf010420a,%eax
f010397d:	66 a3 70 22 23 f0    	mov    %ax,0xf0232270
f0103983:	66 c7 05 72 22 23 f0 	movw   $0x8,0xf0232272
f010398a:	08 00 
f010398c:	c6 05 74 22 23 f0 00 	movb   $0x0,0xf0232274
f0103993:	c6 05 75 22 23 f0 8f 	movb   $0x8f,0xf0232275
f010399a:	c1 e8 10             	shr    $0x10,%eax
f010399d:	66 a3 76 22 23 f0    	mov    %ax,0xf0232276
    SETGATE(idt[T_BRKPT], 1, GD_KT, traphandler3, 3);
f01039a3:	b8 10 42 10 f0       	mov    $0xf0104210,%eax
f01039a8:	66 a3 78 22 23 f0    	mov    %ax,0xf0232278
f01039ae:	66 c7 05 7a 22 23 f0 	movw   $0x8,0xf023227a
f01039b5:	08 00 
f01039b7:	c6 05 7c 22 23 f0 00 	movb   $0x0,0xf023227c
f01039be:	c6 05 7d 22 23 f0 ef 	movb   $0xef,0xf023227d
f01039c5:	c1 e8 10             	shr    $0x10,%eax
f01039c8:	66 a3 7e 22 23 f0    	mov    %ax,0xf023227e
    SETGATE(idt[T_OFLOW], 1, GD_KT, traphandler4, 0);
f01039ce:	b8 16 42 10 f0       	mov    $0xf0104216,%eax
f01039d3:	66 a3 80 22 23 f0    	mov    %ax,0xf0232280
f01039d9:	66 c7 05 82 22 23 f0 	movw   $0x8,0xf0232282
f01039e0:	08 00 
f01039e2:	c6 05 84 22 23 f0 00 	movb   $0x0,0xf0232284
f01039e9:	c6 05 85 22 23 f0 8f 	movb   $0x8f,0xf0232285
f01039f0:	c1 e8 10             	shr    $0x10,%eax
f01039f3:	66 a3 86 22 23 f0    	mov    %ax,0xf0232286
    SETGATE(idt[T_BOUND], 1, GD_KT, traphandler5, 0);
f01039f9:	b8 1c 42 10 f0       	mov    $0xf010421c,%eax
f01039fe:	66 a3 88 22 23 f0    	mov    %ax,0xf0232288
f0103a04:	66 c7 05 8a 22 23 f0 	movw   $0x8,0xf023228a
f0103a0b:	08 00 
f0103a0d:	c6 05 8c 22 23 f0 00 	movb   $0x0,0xf023228c
f0103a14:	c6 05 8d 22 23 f0 8f 	movb   $0x8f,0xf023228d
f0103a1b:	c1 e8 10             	shr    $0x10,%eax
f0103a1e:	66 a3 8e 22 23 f0    	mov    %ax,0xf023228e
    SETGATE(idt[T_ILLOP], 1, GD_KT, traphandler6, 0);
f0103a24:	b8 22 42 10 f0       	mov    $0xf0104222,%eax
f0103a29:	66 a3 90 22 23 f0    	mov    %ax,0xf0232290
f0103a2f:	66 c7 05 92 22 23 f0 	movw   $0x8,0xf0232292
f0103a36:	08 00 
f0103a38:	c6 05 94 22 23 f0 00 	movb   $0x0,0xf0232294
f0103a3f:	c6 05 95 22 23 f0 8f 	movb   $0x8f,0xf0232295
f0103a46:	c1 e8 10             	shr    $0x10,%eax
f0103a49:	66 a3 96 22 23 f0    	mov    %ax,0xf0232296
    SETGATE(idt[T_DEVICE], 1, GD_KT, traphandler7, 0);
f0103a4f:	b8 28 42 10 f0       	mov    $0xf0104228,%eax
f0103a54:	66 a3 98 22 23 f0    	mov    %ax,0xf0232298
f0103a5a:	66 c7 05 9a 22 23 f0 	movw   $0x8,0xf023229a
f0103a61:	08 00 
f0103a63:	c6 05 9c 22 23 f0 00 	movb   $0x0,0xf023229c
f0103a6a:	c6 05 9d 22 23 f0 8f 	movb   $0x8f,0xf023229d
f0103a71:	c1 e8 10             	shr    $0x10,%eax
f0103a74:	66 a3 9e 22 23 f0    	mov    %ax,0xf023229e
    SETGATE(idt[T_DBLFLT], 1, GD_KT, traphandler8, 0);
f0103a7a:	b8 2e 42 10 f0       	mov    $0xf010422e,%eax
f0103a7f:	66 a3 a0 22 23 f0    	mov    %ax,0xf02322a0
f0103a85:	66 c7 05 a2 22 23 f0 	movw   $0x8,0xf02322a2
f0103a8c:	08 00 
f0103a8e:	c6 05 a4 22 23 f0 00 	movb   $0x0,0xf02322a4
f0103a95:	c6 05 a5 22 23 f0 8f 	movb   $0x8f,0xf02322a5
f0103a9c:	c1 e8 10             	shr    $0x10,%eax
f0103a9f:	66 a3 a6 22 23 f0    	mov    %ax,0xf02322a6
    SETGATE(idt[T_TSS], 1, GD_KT, traphandler10, 0);
f0103aa5:	b8 32 42 10 f0       	mov    $0xf0104232,%eax
f0103aaa:	66 a3 b0 22 23 f0    	mov    %ax,0xf02322b0
f0103ab0:	66 c7 05 b2 22 23 f0 	movw   $0x8,0xf02322b2
f0103ab7:	08 00 
f0103ab9:	c6 05 b4 22 23 f0 00 	movb   $0x0,0xf02322b4
f0103ac0:	c6 05 b5 22 23 f0 8f 	movb   $0x8f,0xf02322b5
f0103ac7:	c1 e8 10             	shr    $0x10,%eax
f0103aca:	66 a3 b6 22 23 f0    	mov    %ax,0xf02322b6
    SETGATE(idt[T_SEGNP], 1, GD_KT, traphandler11, 0);
f0103ad0:	b8 36 42 10 f0       	mov    $0xf0104236,%eax
f0103ad5:	66 a3 b8 22 23 f0    	mov    %ax,0xf02322b8
f0103adb:	66 c7 05 ba 22 23 f0 	movw   $0x8,0xf02322ba
f0103ae2:	08 00 
f0103ae4:	c6 05 bc 22 23 f0 00 	movb   $0x0,0xf02322bc
f0103aeb:	c6 05 bd 22 23 f0 8f 	movb   $0x8f,0xf02322bd
f0103af2:	c1 e8 10             	shr    $0x10,%eax
f0103af5:	66 a3 be 22 23 f0    	mov    %ax,0xf02322be
    SETGATE(idt[T_STACK], 1, GD_KT, traphandler12, 0);
f0103afb:	b8 3a 42 10 f0       	mov    $0xf010423a,%eax
f0103b00:	66 a3 c0 22 23 f0    	mov    %ax,0xf02322c0
f0103b06:	66 c7 05 c2 22 23 f0 	movw   $0x8,0xf02322c2
f0103b0d:	08 00 
f0103b0f:	c6 05 c4 22 23 f0 00 	movb   $0x0,0xf02322c4
f0103b16:	c6 05 c5 22 23 f0 8f 	movb   $0x8f,0xf02322c5
f0103b1d:	c1 e8 10             	shr    $0x10,%eax
f0103b20:	66 a3 c6 22 23 f0    	mov    %ax,0xf02322c6
    SETGATE(idt[T_GPFLT], 1, GD_KT, traphandler13, 0);
f0103b26:	b8 3e 42 10 f0       	mov    $0xf010423e,%eax
f0103b2b:	66 a3 c8 22 23 f0    	mov    %ax,0xf02322c8
f0103b31:	66 c7 05 ca 22 23 f0 	movw   $0x8,0xf02322ca
f0103b38:	08 00 
f0103b3a:	c6 05 cc 22 23 f0 00 	movb   $0x0,0xf02322cc
f0103b41:	c6 05 cd 22 23 f0 8f 	movb   $0x8f,0xf02322cd
f0103b48:	c1 e8 10             	shr    $0x10,%eax
f0103b4b:	66 a3 ce 22 23 f0    	mov    %ax,0xf02322ce
    SETGATE(idt[T_PGFLT], 1, GD_KT, traphandler14, 0);
f0103b51:	b8 42 42 10 f0       	mov    $0xf0104242,%eax
f0103b56:	66 a3 d0 22 23 f0    	mov    %ax,0xf02322d0
f0103b5c:	66 c7 05 d2 22 23 f0 	movw   $0x8,0xf02322d2
f0103b63:	08 00 
f0103b65:	c6 05 d4 22 23 f0 00 	movb   $0x0,0xf02322d4
f0103b6c:	c6 05 d5 22 23 f0 8f 	movb   $0x8f,0xf02322d5
f0103b73:	c1 e8 10             	shr    $0x10,%eax
f0103b76:	66 a3 d6 22 23 f0    	mov    %ax,0xf02322d6
    SETGATE(idt[T_FPERR], 1, GD_KT, traphandler16, 0);
f0103b7c:	b8 46 42 10 f0       	mov    $0xf0104246,%eax
f0103b81:	66 a3 e0 22 23 f0    	mov    %ax,0xf02322e0
f0103b87:	66 c7 05 e2 22 23 f0 	movw   $0x8,0xf02322e2
f0103b8e:	08 00 
f0103b90:	c6 05 e4 22 23 f0 00 	movb   $0x0,0xf02322e4
f0103b97:	c6 05 e5 22 23 f0 8f 	movb   $0x8f,0xf02322e5
f0103b9e:	c1 e8 10             	shr    $0x10,%eax
f0103ba1:	66 a3 e6 22 23 f0    	mov    %ax,0xf02322e6
    SETGATE(idt[T_ALIGN], 1, GD_KT, traphandler17, 0);
f0103ba7:	b8 4c 42 10 f0       	mov    $0xf010424c,%eax
f0103bac:	66 a3 e8 22 23 f0    	mov    %ax,0xf02322e8
f0103bb2:	66 c7 05 ea 22 23 f0 	movw   $0x8,0xf02322ea
f0103bb9:	08 00 
f0103bbb:	c6 05 ec 22 23 f0 00 	movb   $0x0,0xf02322ec
f0103bc2:	c6 05 ed 22 23 f0 8f 	movb   $0x8f,0xf02322ed
f0103bc9:	c1 e8 10             	shr    $0x10,%eax
f0103bcc:	66 a3 ee 22 23 f0    	mov    %ax,0xf02322ee
    SETGATE(idt[T_MCHK], 1, GD_KT, traphandler18, 0);
f0103bd2:	b8 50 42 10 f0       	mov    $0xf0104250,%eax
f0103bd7:	66 a3 f0 22 23 f0    	mov    %ax,0xf02322f0
f0103bdd:	66 c7 05 f2 22 23 f0 	movw   $0x8,0xf02322f2
f0103be4:	08 00 
f0103be6:	c6 05 f4 22 23 f0 00 	movb   $0x0,0xf02322f4
f0103bed:	c6 05 f5 22 23 f0 8f 	movb   $0x8f,0xf02322f5
f0103bf4:	c1 e8 10             	shr    $0x10,%eax
f0103bf7:	66 a3 f6 22 23 f0    	mov    %ax,0xf02322f6
    SETGATE(idt[T_SIMDERR], 1, GD_KT, traphandler19, 0);
f0103bfd:	b8 56 42 10 f0       	mov    $0xf0104256,%eax
f0103c02:	66 a3 f8 22 23 f0    	mov    %ax,0xf02322f8
f0103c08:	66 c7 05 fa 22 23 f0 	movw   $0x8,0xf02322fa
f0103c0f:	08 00 
f0103c11:	c6 05 fc 22 23 f0 00 	movb   $0x0,0xf02322fc
f0103c18:	c6 05 fd 22 23 f0 8f 	movb   $0x8f,0xf02322fd
f0103c1f:	c1 e8 10             	shr    $0x10,%eax
f0103c22:	66 a3 fe 22 23 f0    	mov    %ax,0xf02322fe
    SETGATE(idt[T_SYSCALL], 0, GD_KT, traphandler48, 3);
f0103c28:	b8 5c 42 10 f0       	mov    $0xf010425c,%eax
f0103c2d:	66 a3 e0 23 23 f0    	mov    %ax,0xf02323e0
f0103c33:	66 c7 05 e2 23 23 f0 	movw   $0x8,0xf02323e2
f0103c3a:	08 00 
f0103c3c:	c6 05 e4 23 23 f0 00 	movb   $0x0,0xf02323e4
f0103c43:	c6 05 e5 23 23 f0 ee 	movb   $0xee,0xf02323e5
f0103c4a:	c1 e8 10             	shr    $0x10,%eax
f0103c4d:	66 a3 e6 23 23 f0    	mov    %ax,0xf02323e6
    SETGATE(idt[T_DEFAULT], 0, GD_KT, traphandler500, 0);
f0103c53:	b8 62 42 10 f0       	mov    $0xf0104262,%eax
f0103c58:	66 a3 00 32 23 f0    	mov    %ax,0xf0233200
f0103c5e:	66 c7 05 02 32 23 f0 	movw   $0x8,0xf0233202
f0103c65:	08 00 
f0103c67:	c6 05 04 32 23 f0 00 	movb   $0x0,0xf0233204
f0103c6e:	c6 05 05 32 23 f0 8e 	movb   $0x8e,0xf0233205
f0103c75:	c1 e8 10             	shr    $0x10,%eax
f0103c78:	66 a3 06 32 23 f0    	mov    %ax,0xf0233206
	trap_init_percpu();
f0103c7e:	e8 cf fb ff ff       	call   f0103852 <trap_init_percpu>
}
f0103c83:	c9                   	leave  
f0103c84:	c3                   	ret    

f0103c85 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103c85:	55                   	push   %ebp
f0103c86:	89 e5                	mov    %esp,%ebp
f0103c88:	53                   	push   %ebx
f0103c89:	83 ec 0c             	sub    $0xc,%esp
f0103c8c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103c8f:	ff 33                	pushl  (%ebx)
f0103c91:	68 22 6f 10 f0       	push   $0xf0106f22
f0103c96:	e8 a3 fb ff ff       	call   f010383e <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103c9b:	83 c4 08             	add    $0x8,%esp
f0103c9e:	ff 73 04             	pushl  0x4(%ebx)
f0103ca1:	68 31 6f 10 f0       	push   $0xf0106f31
f0103ca6:	e8 93 fb ff ff       	call   f010383e <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103cab:	83 c4 08             	add    $0x8,%esp
f0103cae:	ff 73 08             	pushl  0x8(%ebx)
f0103cb1:	68 40 6f 10 f0       	push   $0xf0106f40
f0103cb6:	e8 83 fb ff ff       	call   f010383e <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103cbb:	83 c4 08             	add    $0x8,%esp
f0103cbe:	ff 73 0c             	pushl  0xc(%ebx)
f0103cc1:	68 4f 6f 10 f0       	push   $0xf0106f4f
f0103cc6:	e8 73 fb ff ff       	call   f010383e <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103ccb:	83 c4 08             	add    $0x8,%esp
f0103cce:	ff 73 10             	pushl  0x10(%ebx)
f0103cd1:	68 5e 6f 10 f0       	push   $0xf0106f5e
f0103cd6:	e8 63 fb ff ff       	call   f010383e <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103cdb:	83 c4 08             	add    $0x8,%esp
f0103cde:	ff 73 14             	pushl  0x14(%ebx)
f0103ce1:	68 6d 6f 10 f0       	push   $0xf0106f6d
f0103ce6:	e8 53 fb ff ff       	call   f010383e <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103ceb:	83 c4 08             	add    $0x8,%esp
f0103cee:	ff 73 18             	pushl  0x18(%ebx)
f0103cf1:	68 7c 6f 10 f0       	push   $0xf0106f7c
f0103cf6:	e8 43 fb ff ff       	call   f010383e <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103cfb:	83 c4 08             	add    $0x8,%esp
f0103cfe:	ff 73 1c             	pushl  0x1c(%ebx)
f0103d01:	68 8b 6f 10 f0       	push   $0xf0106f8b
f0103d06:	e8 33 fb ff ff       	call   f010383e <cprintf>
}
f0103d0b:	83 c4 10             	add    $0x10,%esp
f0103d0e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103d11:	c9                   	leave  
f0103d12:	c3                   	ret    

f0103d13 <print_trapframe>:
{
f0103d13:	55                   	push   %ebp
f0103d14:	89 e5                	mov    %esp,%ebp
f0103d16:	56                   	push   %esi
f0103d17:	53                   	push   %ebx
f0103d18:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0103d1b:	e8 ae 18 00 00       	call   f01055ce <cpunum>
f0103d20:	83 ec 04             	sub    $0x4,%esp
f0103d23:	50                   	push   %eax
f0103d24:	53                   	push   %ebx
f0103d25:	68 ef 6f 10 f0       	push   $0xf0106fef
f0103d2a:	e8 0f fb ff ff       	call   f010383e <cprintf>
	print_regs(&tf->tf_regs);
f0103d2f:	89 1c 24             	mov    %ebx,(%esp)
f0103d32:	e8 4e ff ff ff       	call   f0103c85 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103d37:	83 c4 08             	add    $0x8,%esp
f0103d3a:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103d3e:	50                   	push   %eax
f0103d3f:	68 0d 70 10 f0       	push   $0xf010700d
f0103d44:	e8 f5 fa ff ff       	call   f010383e <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103d49:	83 c4 08             	add    $0x8,%esp
f0103d4c:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103d50:	50                   	push   %eax
f0103d51:	68 20 70 10 f0       	push   $0xf0107020
f0103d56:	e8 e3 fa ff ff       	call   f010383e <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103d5b:	8b 43 28             	mov    0x28(%ebx),%eax
	if (trapno < ARRAY_SIZE(excnames))
f0103d5e:	83 c4 10             	add    $0x10,%esp
f0103d61:	83 f8 13             	cmp    $0x13,%eax
f0103d64:	0f 86 e1 00 00 00    	jbe    f0103e4b <print_trapframe+0x138>
		return "System call";
f0103d6a:	ba 9a 6f 10 f0       	mov    $0xf0106f9a,%edx
	if (trapno == T_SYSCALL)
f0103d6f:	83 f8 30             	cmp    $0x30,%eax
f0103d72:	74 13                	je     f0103d87 <print_trapframe+0x74>
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0103d74:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
f0103d77:	83 fa 0f             	cmp    $0xf,%edx
f0103d7a:	ba a6 6f 10 f0       	mov    $0xf0106fa6,%edx
f0103d7f:	b9 b5 6f 10 f0       	mov    $0xf0106fb5,%ecx
f0103d84:	0f 46 d1             	cmovbe %ecx,%edx
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103d87:	83 ec 04             	sub    $0x4,%esp
f0103d8a:	52                   	push   %edx
f0103d8b:	50                   	push   %eax
f0103d8c:	68 33 70 10 f0       	push   $0xf0107033
f0103d91:	e8 a8 fa ff ff       	call   f010383e <cprintf>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103d96:	83 c4 10             	add    $0x10,%esp
f0103d99:	39 1d 60 2a 23 f0    	cmp    %ebx,0xf0232a60
f0103d9f:	0f 84 b2 00 00 00    	je     f0103e57 <print_trapframe+0x144>
	cprintf("  err  0x%08x", tf->tf_err);
f0103da5:	83 ec 08             	sub    $0x8,%esp
f0103da8:	ff 73 2c             	pushl  0x2c(%ebx)
f0103dab:	68 54 70 10 f0       	push   $0xf0107054
f0103db0:	e8 89 fa ff ff       	call   f010383e <cprintf>
	if (tf->tf_trapno == T_PGFLT)
f0103db5:	83 c4 10             	add    $0x10,%esp
f0103db8:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103dbc:	0f 85 b8 00 00 00    	jne    f0103e7a <print_trapframe+0x167>
			tf->tf_err & 1 ? "protection" : "not-present");
f0103dc2:	8b 43 2c             	mov    0x2c(%ebx),%eax
		cprintf(" [%s, %s, %s]\n",
f0103dc5:	89 c2                	mov    %eax,%edx
f0103dc7:	83 e2 01             	and    $0x1,%edx
f0103dca:	b9 c8 6f 10 f0       	mov    $0xf0106fc8,%ecx
f0103dcf:	ba d3 6f 10 f0       	mov    $0xf0106fd3,%edx
f0103dd4:	0f 44 ca             	cmove  %edx,%ecx
f0103dd7:	89 c2                	mov    %eax,%edx
f0103dd9:	83 e2 02             	and    $0x2,%edx
f0103ddc:	be df 6f 10 f0       	mov    $0xf0106fdf,%esi
f0103de1:	ba e5 6f 10 f0       	mov    $0xf0106fe5,%edx
f0103de6:	0f 45 d6             	cmovne %esi,%edx
f0103de9:	83 e0 04             	and    $0x4,%eax
f0103dec:	b8 ea 6f 10 f0       	mov    $0xf0106fea,%eax
f0103df1:	be 39 71 10 f0       	mov    $0xf0107139,%esi
f0103df6:	0f 44 c6             	cmove  %esi,%eax
f0103df9:	51                   	push   %ecx
f0103dfa:	52                   	push   %edx
f0103dfb:	50                   	push   %eax
f0103dfc:	68 62 70 10 f0       	push   $0xf0107062
f0103e01:	e8 38 fa ff ff       	call   f010383e <cprintf>
f0103e06:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103e09:	83 ec 08             	sub    $0x8,%esp
f0103e0c:	ff 73 30             	pushl  0x30(%ebx)
f0103e0f:	68 71 70 10 f0       	push   $0xf0107071
f0103e14:	e8 25 fa ff ff       	call   f010383e <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103e19:	83 c4 08             	add    $0x8,%esp
f0103e1c:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103e20:	50                   	push   %eax
f0103e21:	68 80 70 10 f0       	push   $0xf0107080
f0103e26:	e8 13 fa ff ff       	call   f010383e <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103e2b:	83 c4 08             	add    $0x8,%esp
f0103e2e:	ff 73 38             	pushl  0x38(%ebx)
f0103e31:	68 93 70 10 f0       	push   $0xf0107093
f0103e36:	e8 03 fa ff ff       	call   f010383e <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0103e3b:	83 c4 10             	add    $0x10,%esp
f0103e3e:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103e42:	75 4b                	jne    f0103e8f <print_trapframe+0x17c>
}
f0103e44:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103e47:	5b                   	pop    %ebx
f0103e48:	5e                   	pop    %esi
f0103e49:	5d                   	pop    %ebp
f0103e4a:	c3                   	ret    
		return excnames[trapno];
f0103e4b:	8b 14 85 c0 72 10 f0 	mov    -0xfef8d40(,%eax,4),%edx
f0103e52:	e9 30 ff ff ff       	jmp    f0103d87 <print_trapframe+0x74>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103e57:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103e5b:	0f 85 44 ff ff ff    	jne    f0103da5 <print_trapframe+0x92>
	asm volatile("movl %%cr2,%0" : "=r" (val));
f0103e61:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0103e64:	83 ec 08             	sub    $0x8,%esp
f0103e67:	50                   	push   %eax
f0103e68:	68 45 70 10 f0       	push   $0xf0107045
f0103e6d:	e8 cc f9 ff ff       	call   f010383e <cprintf>
f0103e72:	83 c4 10             	add    $0x10,%esp
f0103e75:	e9 2b ff ff ff       	jmp    f0103da5 <print_trapframe+0x92>
		cprintf("\n");
f0103e7a:	83 ec 0c             	sub    $0xc,%esp
f0103e7d:	68 0a 65 10 f0       	push   $0xf010650a
f0103e82:	e8 b7 f9 ff ff       	call   f010383e <cprintf>
f0103e87:	83 c4 10             	add    $0x10,%esp
f0103e8a:	e9 7a ff ff ff       	jmp    f0103e09 <print_trapframe+0xf6>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0103e8f:	83 ec 08             	sub    $0x8,%esp
f0103e92:	ff 73 3c             	pushl  0x3c(%ebx)
f0103e95:	68 a2 70 10 f0       	push   $0xf01070a2
f0103e9a:	e8 9f f9 ff ff       	call   f010383e <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0103e9f:	83 c4 08             	add    $0x8,%esp
f0103ea2:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0103ea6:	50                   	push   %eax
f0103ea7:	68 b1 70 10 f0       	push   $0xf01070b1
f0103eac:	e8 8d f9 ff ff       	call   f010383e <cprintf>
f0103eb1:	83 c4 10             	add    $0x10,%esp
}
f0103eb4:	eb 8e                	jmp    f0103e44 <print_trapframe+0x131>

f0103eb6 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0103eb6:	55                   	push   %ebp
f0103eb7:	89 e5                	mov    %esp,%ebp
f0103eb9:	57                   	push   %edi
f0103eba:	56                   	push   %esi
f0103ebb:	53                   	push   %ebx
f0103ebc:	83 ec 1c             	sub    $0x1c,%esp
f0103ebf:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103ec2:	0f 20 d6             	mov    %cr2,%esi
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if ((tf->tf_cs & 3) == 0)
f0103ec5:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103ec9:	74 5d                	je     f0103f28 <page_fault_handler+0x72>
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	struct UTrapframe *utf;

	if (curenv->env_pgfault_upcall) {
f0103ecb:	e8 fe 16 00 00       	call   f01055ce <cpunum>
f0103ed0:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ed3:	8b 80 28 30 23 f0    	mov    -0xfdccfd8(%eax),%eax
f0103ed9:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f0103edd:	75 60                	jne    f0103f3f <page_fault_handler+0x89>
		tf->tf_esp = (uint32_t)utf;
		env_run(curenv);
	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103edf:	8b 7b 30             	mov    0x30(%ebx),%edi
		curenv->env_id, fault_va, tf->tf_eip);
f0103ee2:	e8 e7 16 00 00       	call   f01055ce <cpunum>
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103ee7:	57                   	push   %edi
f0103ee8:	56                   	push   %esi
		curenv->env_id, fault_va, tf->tf_eip);
f0103ee9:	6b c0 74             	imul   $0x74,%eax,%eax
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103eec:	8b 80 28 30 23 f0    	mov    -0xfdccfd8(%eax),%eax
f0103ef2:	ff 70 48             	pushl  0x48(%eax)
f0103ef5:	68 84 72 10 f0       	push   $0xf0107284
f0103efa:	e8 3f f9 ff ff       	call   f010383e <cprintf>
	print_trapframe(tf);
f0103eff:	89 1c 24             	mov    %ebx,(%esp)
f0103f02:	e8 0c fe ff ff       	call   f0103d13 <print_trapframe>
	env_destroy(curenv);
f0103f07:	e8 c2 16 00 00       	call   f01055ce <cpunum>
f0103f0c:	83 c4 04             	add    $0x4,%esp
f0103f0f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f12:	ff b0 28 30 23 f0    	pushl  -0xfdccfd8(%eax)
f0103f18:	e8 5a f6 ff ff       	call   f0103577 <env_destroy>
}
f0103f1d:	83 c4 10             	add    $0x10,%esp
f0103f20:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103f23:	5b                   	pop    %ebx
f0103f24:	5e                   	pop    %esi
f0103f25:	5f                   	pop    %edi
f0103f26:	5d                   	pop    %ebp
f0103f27:	c3                   	ret    
			panic("Page fault in kernel_mode");
f0103f28:	83 ec 04             	sub    $0x4,%esp
f0103f2b:	68 c4 70 10 f0       	push   $0xf01070c4
f0103f30:	68 5d 01 00 00       	push   $0x15d
f0103f35:	68 de 70 10 f0       	push   $0xf01070de
f0103f3a:	e8 55 c1 ff ff       	call   f0100094 <_panic>
		if (UXSTACKTOP - PGSIZE <= tf->tf_esp && tf->tf_esp <= UXSTACKTOP - 1)
f0103f3f:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0103f42:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
			utf = (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe));
f0103f48:	c7 45 e4 cc ff bf ee 	movl   $0xeebfffcc,-0x1c(%ebp)
		if (UXSTACKTOP - PGSIZE <= tf->tf_esp && tf->tf_esp <= UXSTACKTOP - 1)
f0103f4f:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f0103f55:	77 06                	ja     f0103f5d <page_fault_handler+0xa7>
			utf = (struct UTrapframe *)(tf->tf_esp - sizeof(struct UTrapframe) - 4);
f0103f57:	83 e8 38             	sub    $0x38,%eax
f0103f5a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		user_mem_assert(curenv, (void *)utf, sizeof(struct UTrapframe), PTE_U | PTE_W);
f0103f5d:	e8 6c 16 00 00       	call   f01055ce <cpunum>
f0103f62:	6a 06                	push   $0x6
f0103f64:	6a 34                	push   $0x34
f0103f66:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103f69:	57                   	push   %edi
f0103f6a:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f6d:	ff b0 28 30 23 f0    	pushl  -0xfdccfd8(%eax)
f0103f73:	e8 96 ef ff ff       	call   f0102f0e <user_mem_assert>
		utf->utf_fault_va = fault_va;
f0103f78:	89 37                	mov    %esi,(%edi)
		utf->utf_err = tf->tf_trapno;
f0103f7a:	8b 43 28             	mov    0x28(%ebx),%eax
f0103f7d:	89 47 04             	mov    %eax,0x4(%edi)
		utf->utf_eip = tf->tf_eip;
f0103f80:	8b 43 30             	mov    0x30(%ebx),%eax
f0103f83:	89 47 28             	mov    %eax,0x28(%edi)
		utf->utf_eflags = tf->tf_eflags;
f0103f86:	8b 43 38             	mov    0x38(%ebx),%eax
f0103f89:	89 47 2c             	mov    %eax,0x2c(%edi)
		utf->utf_esp = tf->tf_esp;
f0103f8c:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0103f8f:	89 47 30             	mov    %eax,0x30(%edi)
		utf->utf_regs = tf->tf_regs;
f0103f92:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f0103f95:	8d 7f 08             	lea    0x8(%edi),%edi
f0103f98:	b9 08 00 00 00       	mov    $0x8,%ecx
f0103f9d:	89 de                	mov    %ebx,%esi
f0103f9f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		tf->tf_eip = (uint32_t)curenv->env_pgfault_upcall;
f0103fa1:	e8 28 16 00 00       	call   f01055ce <cpunum>
f0103fa6:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fa9:	8b 80 28 30 23 f0    	mov    -0xfdccfd8(%eax),%eax
f0103faf:	8b 40 64             	mov    0x64(%eax),%eax
f0103fb2:	89 43 30             	mov    %eax,0x30(%ebx)
		tf->tf_esp = (uint32_t)utf;
f0103fb5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0103fb8:	89 53 3c             	mov    %edx,0x3c(%ebx)
		env_run(curenv);
f0103fbb:	e8 0e 16 00 00       	call   f01055ce <cpunum>
f0103fc0:	83 c4 04             	add    $0x4,%esp
f0103fc3:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fc6:	ff b0 28 30 23 f0    	pushl  -0xfdccfd8(%eax)
f0103fcc:	e8 45 f6 ff ff       	call   f0103616 <env_run>

f0103fd1 <trap>:
{
f0103fd1:	55                   	push   %ebp
f0103fd2:	89 e5                	mov    %esp,%ebp
f0103fd4:	57                   	push   %edi
f0103fd5:	56                   	push   %esi
f0103fd6:	8b 75 08             	mov    0x8(%ebp),%esi
	asm volatile("cld" ::: "cc");
f0103fd9:	fc                   	cld    
	if (panicstr)
f0103fda:	83 3d 80 2e 23 f0 00 	cmpl   $0x0,0xf0232e80
f0103fe1:	74 01                	je     f0103fe4 <trap+0x13>
		asm volatile("hlt");
f0103fe3:	f4                   	hlt    
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f0103fe4:	e8 e5 15 00 00       	call   f01055ce <cpunum>
f0103fe9:	6b d0 74             	imul   $0x74,%eax,%edx
f0103fec:	83 c2 04             	add    $0x4,%edx
	asm volatile("lock; xchgl %0, %1"
f0103fef:	b8 01 00 00 00       	mov    $0x1,%eax
f0103ff4:	f0 87 82 20 30 23 f0 	lock xchg %eax,-0xfdccfe0(%edx)
f0103ffb:	83 f8 02             	cmp    $0x2,%eax
f0103ffe:	74 7e                	je     f010407e <trap+0xad>
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f0104000:	9c                   	pushf  
f0104001:	58                   	pop    %eax
	assert(!(read_eflags() & FL_IF));
f0104002:	f6 c4 02             	test   $0x2,%ah
f0104005:	0f 85 88 00 00 00    	jne    f0104093 <trap+0xc2>
	if ((tf->tf_cs & 3) == 3) {
f010400b:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f010400f:	83 e0 03             	and    $0x3,%eax
f0104012:	66 83 f8 03          	cmp    $0x3,%ax
f0104016:	0f 84 90 00 00 00    	je     f01040ac <trap+0xdb>
	last_tf = tf;
f010401c:	89 35 60 2a 23 f0    	mov    %esi,0xf0232a60
	switch (tf->tf_trapno) {
f0104022:	8b 46 28             	mov    0x28(%esi),%eax
f0104025:	83 f8 0e             	cmp    $0xe,%eax
f0104028:	0f 84 23 01 00 00    	je     f0104151 <trap+0x180>
f010402e:	83 f8 30             	cmp    $0x30,%eax
f0104031:	0f 84 5e 01 00 00    	je     f0104195 <trap+0x1c4>
f0104037:	83 f8 03             	cmp    $0x3,%eax
f010403a:	0f 84 47 01 00 00    	je     f0104187 <trap+0x1b6>
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f0104040:	83 f8 27             	cmp    $0x27,%eax
f0104043:	0f 84 6d 01 00 00    	je     f01041b6 <trap+0x1e5>
	print_trapframe(tf);
f0104049:	83 ec 0c             	sub    $0xc,%esp
f010404c:	56                   	push   %esi
f010404d:	e8 c1 fc ff ff       	call   f0103d13 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0104052:	83 c4 10             	add    $0x10,%esp
f0104055:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f010405a:	0f 84 70 01 00 00    	je     f01041d0 <trap+0x1ff>
		env_destroy(curenv);
f0104060:	e8 69 15 00 00       	call   f01055ce <cpunum>
f0104065:	83 ec 0c             	sub    $0xc,%esp
f0104068:	6b c0 74             	imul   $0x74,%eax,%eax
f010406b:	ff b0 28 30 23 f0    	pushl  -0xfdccfd8(%eax)
f0104071:	e8 01 f5 ff ff       	call   f0103577 <env_destroy>
f0104076:	83 c4 10             	add    $0x10,%esp
f0104079:	e9 df 00 00 00       	jmp    f010415d <trap+0x18c>
	spin_lock(&kernel_lock);
f010407e:	83 ec 0c             	sub    $0xc,%esp
f0104081:	68 c0 23 12 f0       	push   $0xf01223c0
f0104086:	e8 b3 17 00 00       	call   f010583e <spin_lock>
f010408b:	83 c4 10             	add    $0x10,%esp
f010408e:	e9 6d ff ff ff       	jmp    f0104000 <trap+0x2f>
	assert(!(read_eflags() & FL_IF));
f0104093:	68 ea 70 10 f0       	push   $0xf01070ea
f0104098:	68 3e 62 10 f0       	push   $0xf010623e
f010409d:	68 27 01 00 00       	push   $0x127
f01040a2:	68 de 70 10 f0       	push   $0xf01070de
f01040a7:	e8 e8 bf ff ff       	call   f0100094 <_panic>
f01040ac:	83 ec 0c             	sub    $0xc,%esp
f01040af:	68 c0 23 12 f0       	push   $0xf01223c0
f01040b4:	e8 85 17 00 00       	call   f010583e <spin_lock>
		assert(curenv);
f01040b9:	e8 10 15 00 00       	call   f01055ce <cpunum>
f01040be:	6b c0 74             	imul   $0x74,%eax,%eax
f01040c1:	83 c4 10             	add    $0x10,%esp
f01040c4:	83 b8 28 30 23 f0 00 	cmpl   $0x0,-0xfdccfd8(%eax)
f01040cb:	74 3e                	je     f010410b <trap+0x13a>
		if (curenv->env_status == ENV_DYING) {
f01040cd:	e8 fc 14 00 00       	call   f01055ce <cpunum>
f01040d2:	6b c0 74             	imul   $0x74,%eax,%eax
f01040d5:	8b 80 28 30 23 f0    	mov    -0xfdccfd8(%eax),%eax
f01040db:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f01040df:	74 43                	je     f0104124 <trap+0x153>
		curenv->env_tf = *tf;
f01040e1:	e8 e8 14 00 00       	call   f01055ce <cpunum>
f01040e6:	6b c0 74             	imul   $0x74,%eax,%eax
f01040e9:	8b 80 28 30 23 f0    	mov    -0xfdccfd8(%eax),%eax
f01040ef:	b9 11 00 00 00       	mov    $0x11,%ecx
f01040f4:	89 c7                	mov    %eax,%edi
f01040f6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		tf = &curenv->env_tf;
f01040f8:	e8 d1 14 00 00       	call   f01055ce <cpunum>
f01040fd:	6b c0 74             	imul   $0x74,%eax,%eax
f0104100:	8b b0 28 30 23 f0    	mov    -0xfdccfd8(%eax),%esi
f0104106:	e9 11 ff ff ff       	jmp    f010401c <trap+0x4b>
		assert(curenv);
f010410b:	68 03 71 10 f0       	push   $0xf0107103
f0104110:	68 3e 62 10 f0       	push   $0xf010623e
f0104115:	68 2f 01 00 00       	push   $0x12f
f010411a:	68 de 70 10 f0       	push   $0xf01070de
f010411f:	e8 70 bf ff ff       	call   f0100094 <_panic>
			env_free(curenv);
f0104124:	e8 a5 14 00 00       	call   f01055ce <cpunum>
f0104129:	83 ec 0c             	sub    $0xc,%esp
f010412c:	6b c0 74             	imul   $0x74,%eax,%eax
f010412f:	ff b0 28 30 23 f0    	pushl  -0xfdccfd8(%eax)
f0104135:	e8 5c f2 ff ff       	call   f0103396 <env_free>
			curenv = NULL;
f010413a:	e8 8f 14 00 00       	call   f01055ce <cpunum>
f010413f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104142:	c7 80 28 30 23 f0 00 	movl   $0x0,-0xfdccfd8(%eax)
f0104149:	00 00 00 
			sched_yield();
f010414c:	e8 f4 01 00 00       	call   f0104345 <sched_yield>
			page_fault_handler(tf);
f0104151:	83 ec 0c             	sub    $0xc,%esp
f0104154:	56                   	push   %esi
f0104155:	e8 5c fd ff ff       	call   f0103eb6 <page_fault_handler>
f010415a:	83 c4 10             	add    $0x10,%esp
	if (curenv && curenv->env_status == ENV_RUNNING)
f010415d:	e8 6c 14 00 00       	call   f01055ce <cpunum>
f0104162:	6b c0 74             	imul   $0x74,%eax,%eax
f0104165:	83 b8 28 30 23 f0 00 	cmpl   $0x0,-0xfdccfd8(%eax)
f010416c:	74 14                	je     f0104182 <trap+0x1b1>
f010416e:	e8 5b 14 00 00       	call   f01055ce <cpunum>
f0104173:	6b c0 74             	imul   $0x74,%eax,%eax
f0104176:	8b 80 28 30 23 f0    	mov    -0xfdccfd8(%eax),%eax
f010417c:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104180:	74 65                	je     f01041e7 <trap+0x216>
		sched_yield();
f0104182:	e8 be 01 00 00       	call   f0104345 <sched_yield>
			monitor(tf);
f0104187:	83 ec 0c             	sub    $0xc,%esp
f010418a:	56                   	push   %esi
f010418b:	e8 d9 c7 ff ff       	call   f0100969 <monitor>
f0104190:	83 c4 10             	add    $0x10,%esp
f0104193:	eb c8                	jmp    f010415d <trap+0x18c>
			tf->tf_regs.reg_eax = syscall (tf->tf_regs.reg_eax,
f0104195:	83 ec 08             	sub    $0x8,%esp
f0104198:	ff 76 04             	pushl  0x4(%esi)
f010419b:	ff 36                	pushl  (%esi)
f010419d:	ff 76 10             	pushl  0x10(%esi)
f01041a0:	ff 76 18             	pushl  0x18(%esi)
f01041a3:	ff 76 14             	pushl  0x14(%esi)
f01041a6:	ff 76 1c             	pushl  0x1c(%esi)
f01041a9:	e8 03 02 00 00       	call   f01043b1 <syscall>
f01041ae:	89 46 1c             	mov    %eax,0x1c(%esi)
f01041b1:	83 c4 20             	add    $0x20,%esp
f01041b4:	eb a7                	jmp    f010415d <trap+0x18c>
		cprintf("Spurious interrupt on irq 7\n");
f01041b6:	83 ec 0c             	sub    $0xc,%esp
f01041b9:	68 0a 71 10 f0       	push   $0xf010710a
f01041be:	e8 7b f6 ff ff       	call   f010383e <cprintf>
		print_trapframe(tf);
f01041c3:	89 34 24             	mov    %esi,(%esp)
f01041c6:	e8 48 fb ff ff       	call   f0103d13 <print_trapframe>
f01041cb:	83 c4 10             	add    $0x10,%esp
f01041ce:	eb 8d                	jmp    f010415d <trap+0x18c>
		panic("unhandled trap in kernel");
f01041d0:	83 ec 04             	sub    $0x4,%esp
f01041d3:	68 27 71 10 f0       	push   $0xf0107127
f01041d8:	68 0c 01 00 00       	push   $0x10c
f01041dd:	68 de 70 10 f0       	push   $0xf01070de
f01041e2:	e8 ad be ff ff       	call   f0100094 <_panic>
		env_run(curenv);
f01041e7:	e8 e2 13 00 00       	call   f01055ce <cpunum>
f01041ec:	83 ec 0c             	sub    $0xc,%esp
f01041ef:	6b c0 74             	imul   $0x74,%eax,%eax
f01041f2:	ff b0 28 30 23 f0    	pushl  -0xfdccfd8(%eax)
f01041f8:	e8 19 f4 ff ff       	call   f0103616 <env_run>
f01041fd:	90                   	nop

f01041fe <traphandler0>:
.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
TRAPHANDLER_NOEC(traphandler0, T_DIVIDE)
f01041fe:	6a 00                	push   $0x0
f0104200:	6a 00                	push   $0x0
f0104202:	eb 67                	jmp    f010426b <_alltraps>

f0104204 <traphandler1>:
TRAPHANDLER_NOEC(traphandler1, T_DEBUG)
f0104204:	6a 00                	push   $0x0
f0104206:	6a 01                	push   $0x1
f0104208:	eb 61                	jmp    f010426b <_alltraps>

f010420a <traphandler2>:
TRAPHANDLER_NOEC(traphandler2, T_NMI)
f010420a:	6a 00                	push   $0x0
f010420c:	6a 02                	push   $0x2
f010420e:	eb 5b                	jmp    f010426b <_alltraps>

f0104210 <traphandler3>:
TRAPHANDLER_NOEC(traphandler3, T_BRKPT)
f0104210:	6a 00                	push   $0x0
f0104212:	6a 03                	push   $0x3
f0104214:	eb 55                	jmp    f010426b <_alltraps>

f0104216 <traphandler4>:
TRAPHANDLER_NOEC(traphandler4, T_OFLOW)
f0104216:	6a 00                	push   $0x0
f0104218:	6a 04                	push   $0x4
f010421a:	eb 4f                	jmp    f010426b <_alltraps>

f010421c <traphandler5>:
TRAPHANDLER_NOEC(traphandler5, T_BOUND)
f010421c:	6a 00                	push   $0x0
f010421e:	6a 05                	push   $0x5
f0104220:	eb 49                	jmp    f010426b <_alltraps>

f0104222 <traphandler6>:
TRAPHANDLER_NOEC(traphandler6, T_ILLOP)
f0104222:	6a 00                	push   $0x0
f0104224:	6a 06                	push   $0x6
f0104226:	eb 43                	jmp    f010426b <_alltraps>

f0104228 <traphandler7>:
TRAPHANDLER_NOEC(traphandler7, T_DEVICE)
f0104228:	6a 00                	push   $0x0
f010422a:	6a 07                	push   $0x7
f010422c:	eb 3d                	jmp    f010426b <_alltraps>

f010422e <traphandler8>:
TRAPHANDLER(traphandler8, T_DBLFLT)
f010422e:	6a 08                	push   $0x8
f0104230:	eb 39                	jmp    f010426b <_alltraps>

f0104232 <traphandler10>:
// 9 deprecated since 386
TRAPHANDLER(traphandler10, T_TSS)
f0104232:	6a 0a                	push   $0xa
f0104234:	eb 35                	jmp    f010426b <_alltraps>

f0104236 <traphandler11>:
TRAPHANDLER(traphandler11, T_SEGNP)
f0104236:	6a 0b                	push   $0xb
f0104238:	eb 31                	jmp    f010426b <_alltraps>

f010423a <traphandler12>:
TRAPHANDLER(traphandler12, T_STACK)
f010423a:	6a 0c                	push   $0xc
f010423c:	eb 2d                	jmp    f010426b <_alltraps>

f010423e <traphandler13>:
TRAPHANDLER(traphandler13, T_GPFLT)
f010423e:	6a 0d                	push   $0xd
f0104240:	eb 29                	jmp    f010426b <_alltraps>

f0104242 <traphandler14>:
TRAPHANDLER(traphandler14, T_PGFLT)
f0104242:	6a 0e                	push   $0xe
f0104244:	eb 25                	jmp    f010426b <_alltraps>

f0104246 <traphandler16>:
// 15 reserved by intel
TRAPHANDLER_NOEC(traphandler16, T_FPERR)
f0104246:	6a 00                	push   $0x0
f0104248:	6a 10                	push   $0x10
f010424a:	eb 1f                	jmp    f010426b <_alltraps>

f010424c <traphandler17>:
TRAPHANDLER(traphandler17, T_ALIGN)
f010424c:	6a 11                	push   $0x11
f010424e:	eb 1b                	jmp    f010426b <_alltraps>

f0104250 <traphandler18>:
TRAPHANDLER_NOEC(traphandler18, T_MCHK)
f0104250:	6a 00                	push   $0x0
f0104252:	6a 12                	push   $0x12
f0104254:	eb 15                	jmp    f010426b <_alltraps>

f0104256 <traphandler19>:
TRAPHANDLER_NOEC(traphandler19, T_SIMDERR)
f0104256:	6a 00                	push   $0x0
f0104258:	6a 13                	push   $0x13
f010425a:	eb 0f                	jmp    f010426b <_alltraps>

f010425c <traphandler48>:

// system call (interrupt)
TRAPHANDLER_NOEC(traphandler48, T_SYSCALL)
f010425c:	6a 00                	push   $0x0
f010425e:	6a 30                	push   $0x30
f0104260:	eb 09                	jmp    f010426b <_alltraps>

f0104262 <traphandler500>:
TRAPHANDLER_NOEC(traphandler500, T_DEFAULT)	
f0104262:	6a 00                	push   $0x0
f0104264:	68 f4 01 00 00       	push   $0x1f4
f0104269:	eb 00                	jmp    f010426b <_alltraps>

f010426b <_alltraps>:

/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
	pushl %ds	
f010426b:	1e                   	push   %ds
	pushl %es	
f010426c:	06                   	push   %es
	pushal
f010426d:	60                   	pusha  
	
	movw $GD_KD, %ax
f010426e:	66 b8 10 00          	mov    $0x10,%ax
	movw %ax, %ds
f0104272:	8e d8                	mov    %eax,%ds
	movw %ax, %es
f0104274:	8e c0                	mov    %eax,%es
	pushl %esp
f0104276:	54                   	push   %esp
	call trap
f0104277:	e8 55 fd ff ff       	call   f0103fd1 <trap>

f010427c <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f010427c:	55                   	push   %ebp
f010427d:	89 e5                	mov    %esp,%ebp
f010427f:	83 ec 08             	sub    $0x8,%esp
f0104282:	a1 44 22 23 f0       	mov    0xf0232244,%eax
f0104287:	8d 50 54             	lea    0x54(%eax),%edx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f010428a:	b9 00 00 00 00       	mov    $0x0,%ecx
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
f010428f:	8b 02                	mov    (%edx),%eax
f0104291:	83 e8 01             	sub    $0x1,%eax
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0104294:	83 f8 02             	cmp    $0x2,%eax
f0104297:	76 2d                	jbe    f01042c6 <sched_halt+0x4a>
	for (i = 0; i < NENV; i++) {
f0104299:	83 c1 01             	add    $0x1,%ecx
f010429c:	83 c2 7c             	add    $0x7c,%edx
f010429f:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f01042a5:	75 e8                	jne    f010428f <sched_halt+0x13>
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
		cprintf("No runnable environments in the system!\n");
f01042a7:	83 ec 0c             	sub    $0xc,%esp
f01042aa:	68 10 73 10 f0       	push   $0xf0107310
f01042af:	e8 8a f5 ff ff       	call   f010383e <cprintf>
f01042b4:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f01042b7:	83 ec 0c             	sub    $0xc,%esp
f01042ba:	6a 00                	push   $0x0
f01042bc:	e8 a8 c6 ff ff       	call   f0100969 <monitor>
f01042c1:	83 c4 10             	add    $0x10,%esp
f01042c4:	eb f1                	jmp    f01042b7 <sched_halt+0x3b>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f01042c6:	e8 03 13 00 00       	call   f01055ce <cpunum>
f01042cb:	6b c0 74             	imul   $0x74,%eax,%eax
f01042ce:	c7 80 28 30 23 f0 00 	movl   $0x0,-0xfdccfd8(%eax)
f01042d5:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f01042d8:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f01042dd:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01042e2:	76 4f                	jbe    f0104333 <sched_halt+0xb7>
	return (physaddr_t)kva - KERNBASE;
f01042e4:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01042e9:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f01042ec:	e8 dd 12 00 00       	call   f01055ce <cpunum>
f01042f1:	6b d0 74             	imul   $0x74,%eax,%edx
f01042f4:	83 c2 04             	add    $0x4,%edx
	asm volatile("lock; xchgl %0, %1"
f01042f7:	b8 02 00 00 00       	mov    $0x2,%eax
f01042fc:	f0 87 82 20 30 23 f0 	lock xchg %eax,-0xfdccfe0(%edx)
	spin_unlock(&kernel_lock);
f0104303:	83 ec 0c             	sub    $0xc,%esp
f0104306:	68 c0 23 12 f0       	push   $0xf01223c0
f010430b:	e8 ca 15 00 00       	call   f01058da <spin_unlock>
	asm volatile("pause");
f0104310:	f3 90                	pause  
		// Uncomment the following line after completing exercise 13
		//"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f0104312:	e8 b7 12 00 00       	call   f01055ce <cpunum>
f0104317:	6b c0 74             	imul   $0x74,%eax,%eax
	asm volatile (
f010431a:	8b 80 30 30 23 f0    	mov    -0xfdccfd0(%eax),%eax
f0104320:	bd 00 00 00 00       	mov    $0x0,%ebp
f0104325:	89 c4                	mov    %eax,%esp
f0104327:	6a 00                	push   $0x0
f0104329:	6a 00                	push   $0x0
f010432b:	f4                   	hlt    
f010432c:	eb fd                	jmp    f010432b <sched_halt+0xaf>
}
f010432e:	83 c4 10             	add    $0x10,%esp
f0104331:	c9                   	leave  
f0104332:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104333:	50                   	push   %eax
f0104334:	68 f8 5c 10 f0       	push   $0xf0105cf8
f0104339:	6a 4f                	push   $0x4f
f010433b:	68 39 73 10 f0       	push   $0xf0107339
f0104340:	e8 4f bd ff ff       	call   f0100094 <_panic>

f0104345 <sched_yield>:
{
f0104345:	55                   	push   %ebp
f0104346:	89 e5                	mov    %esp,%ebp
f0104348:	56                   	push   %esi
f0104349:	53                   	push   %ebx
	idle = thiscpu->cpu_env;
f010434a:	e8 7f 12 00 00       	call   f01055ce <cpunum>
f010434f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104352:	8b b0 28 30 23 f0    	mov    -0xfdccfd8(%eax),%esi
    uint32_t start = (idle != NULL) ? ENVX( idle->env_id) : 0;
f0104358:	b9 00 00 00 00       	mov    $0x0,%ecx
f010435d:	85 f6                	test   %esi,%esi
f010435f:	74 09                	je     f010436a <sched_yield+0x25>
f0104361:	8b 4e 48             	mov    0x48(%esi),%ecx
f0104364:	81 e1 ff 03 00 00    	and    $0x3ff,%ecx
        if(envs[i].env_status == ENV_RUNNABLE)
f010436a:	8b 1d 44 22 23 f0    	mov    0xf0232244,%ebx
    uint32_t i = start;
f0104370:	89 c8                	mov    %ecx,%eax
        if(envs[i].env_status == ENV_RUNNABLE)
f0104372:	6b d0 7c             	imul   $0x7c,%eax,%edx
f0104375:	01 da                	add    %ebx,%edx
f0104377:	83 7a 54 02          	cmpl   $0x2,0x54(%edx)
f010437b:	74 22                	je     f010439f <sched_yield+0x5a>
    for (; i != start || first; i = (i+1) % NENV, first = false)
f010437d:	83 c0 01             	add    $0x1,%eax
f0104380:	25 ff 03 00 00       	and    $0x3ff,%eax
f0104385:	39 c1                	cmp    %eax,%ecx
f0104387:	75 e9                	jne    f0104372 <sched_yield+0x2d>
    if (idle && idle->env_status == ENV_RUNNING)
f0104389:	85 f6                	test   %esi,%esi
f010438b:	74 06                	je     f0104393 <sched_yield+0x4e>
f010438d:	83 7e 54 03          	cmpl   $0x3,0x54(%esi)
f0104391:	74 15                	je     f01043a8 <sched_yield+0x63>
	sched_halt();
f0104393:	e8 e4 fe ff ff       	call   f010427c <sched_halt>
}
f0104398:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010439b:	5b                   	pop    %ebx
f010439c:	5e                   	pop    %esi
f010439d:	5d                   	pop    %ebp
f010439e:	c3                   	ret    
            env_run(&envs[i]);
f010439f:	83 ec 0c             	sub    $0xc,%esp
f01043a2:	52                   	push   %edx
f01043a3:	e8 6e f2 ff ff       	call   f0103616 <env_run>
        env_run(idle);
f01043a8:	83 ec 0c             	sub    $0xc,%esp
f01043ab:	56                   	push   %esi
f01043ac:	e8 65 f2 ff ff       	call   f0103616 <env_run>

f01043b1 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f01043b1:	55                   	push   %ebp
f01043b2:	89 e5                	mov    %esp,%ebp
f01043b4:	53                   	push   %ebx
f01043b5:	83 ec 14             	sub    $0x14,%esp
f01043b8:	8b 45 08             	mov    0x8(%ebp),%eax
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
	int32_t ret = 0;
	switch (syscallno) {
f01043bb:	83 f8 0a             	cmp    $0xa,%eax
f01043be:	0f 87 d1 00 00 00    	ja     f0104495 <syscall+0xe4>
f01043c4:	ff 24 85 80 73 10 f0 	jmp    *-0xfef8c80(,%eax,4)
	cprintf("%.*s", len, s);
f01043cb:	83 ec 04             	sub    $0x4,%esp
f01043ce:	ff 75 0c             	pushl  0xc(%ebp)
f01043d1:	ff 75 10             	pushl  0x10(%ebp)
f01043d4:	68 46 73 10 f0       	push   $0xf0107346
f01043d9:	e8 60 f4 ff ff       	call   f010383e <cprintf>
f01043de:	83 c4 10             	add    $0x10,%esp
	int32_t ret = 0;
f01043e1:	b8 00 00 00 00       	mov    $0x0,%eax
		 default:
			return -E_INVAL;

	}
	return ret;	
}
f01043e6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01043e9:	c9                   	leave  
f01043ea:	c3                   	ret    
	return cons_getc();
f01043eb:	e8 6e c2 ff ff       	call   f010065e <cons_getc>
			break;
f01043f0:	eb f4                	jmp    f01043e6 <syscall+0x35>
	if ((r = envid2env(envid, &e, 1)) < 0)
f01043f2:	83 ec 04             	sub    $0x4,%esp
f01043f5:	6a 01                	push   $0x1
f01043f7:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01043fa:	50                   	push   %eax
f01043fb:	ff 75 0c             	pushl  0xc(%ebp)
f01043fe:	e8 94 eb ff ff       	call   f0102f97 <envid2env>
f0104403:	83 c4 10             	add    $0x10,%esp
f0104406:	85 c0                	test   %eax,%eax
f0104408:	78 dc                	js     f01043e6 <syscall+0x35>
	if (e == curenv)
f010440a:	e8 bf 11 00 00       	call   f01055ce <cpunum>
f010440f:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0104412:	6b c0 74             	imul   $0x74,%eax,%eax
f0104415:	39 90 28 30 23 f0    	cmp    %edx,-0xfdccfd8(%eax)
f010441b:	74 3a                	je     f0104457 <syscall+0xa6>
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f010441d:	8b 5a 48             	mov    0x48(%edx),%ebx
f0104420:	e8 a9 11 00 00       	call   f01055ce <cpunum>
f0104425:	83 ec 04             	sub    $0x4,%esp
f0104428:	53                   	push   %ebx
f0104429:	6b c0 74             	imul   $0x74,%eax,%eax
f010442c:	8b 80 28 30 23 f0    	mov    -0xfdccfd8(%eax),%eax
f0104432:	ff 70 48             	pushl  0x48(%eax)
f0104435:	68 66 73 10 f0       	push   $0xf0107366
f010443a:	e8 ff f3 ff ff       	call   f010383e <cprintf>
f010443f:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f0104442:	83 ec 0c             	sub    $0xc,%esp
f0104445:	ff 75 f4             	pushl  -0xc(%ebp)
f0104448:	e8 2a f1 ff ff       	call   f0103577 <env_destroy>
f010444d:	83 c4 10             	add    $0x10,%esp
	return 0;
f0104450:	b8 00 00 00 00       	mov    $0x0,%eax
			break;
f0104455:	eb 8f                	jmp    f01043e6 <syscall+0x35>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0104457:	e8 72 11 00 00       	call   f01055ce <cpunum>
f010445c:	83 ec 08             	sub    $0x8,%esp
f010445f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104462:	8b 80 28 30 23 f0    	mov    -0xfdccfd8(%eax),%eax
f0104468:	ff 70 48             	pushl  0x48(%eax)
f010446b:	68 4b 73 10 f0       	push   $0xf010734b
f0104470:	e8 c9 f3 ff ff       	call   f010383e <cprintf>
f0104475:	83 c4 10             	add    $0x10,%esp
f0104478:	eb c8                	jmp    f0104442 <syscall+0x91>
	return curenv->env_id;
f010447a:	e8 4f 11 00 00       	call   f01055ce <cpunum>
f010447f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104482:	8b 80 28 30 23 f0    	mov    -0xfdccfd8(%eax),%eax
f0104488:	8b 40 48             	mov    0x48(%eax),%eax
			break;
f010448b:	e9 56 ff ff ff       	jmp    f01043e6 <syscall+0x35>
	sched_yield();
f0104490:	e8 b0 fe ff ff       	call   f0104345 <sched_yield>
			return -E_INVAL;
f0104495:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010449a:	e9 47 ff ff ff       	jmp    f01043e6 <syscall+0x35>

f010449f <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f010449f:	55                   	push   %ebp
f01044a0:	89 e5                	mov    %esp,%ebp
f01044a2:	57                   	push   %edi
f01044a3:	56                   	push   %esi
f01044a4:	53                   	push   %ebx
f01044a5:	83 ec 14             	sub    $0x14,%esp
f01044a8:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01044ab:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01044ae:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01044b1:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f01044b4:	8b 1a                	mov    (%edx),%ebx
f01044b6:	8b 01                	mov    (%ecx),%eax
f01044b8:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01044bb:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f01044c2:	eb 23                	jmp    f01044e7 <stab_binsearch+0x48>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f01044c4:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f01044c7:	eb 1e                	jmp    f01044e7 <stab_binsearch+0x48>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f01044c9:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01044cc:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01044cf:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f01044d3:	3b 55 0c             	cmp    0xc(%ebp),%edx
f01044d6:	73 41                	jae    f0104519 <stab_binsearch+0x7a>
			*region_left = m;
f01044d8:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01044db:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f01044dd:	8d 5f 01             	lea    0x1(%edi),%ebx
		any_matches = 1;
f01044e0:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f01044e7:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f01044ea:	7f 5a                	jg     f0104546 <stab_binsearch+0xa7>
		int true_m = (l + r) / 2, m = true_m;
f01044ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01044ef:	01 d8                	add    %ebx,%eax
f01044f1:	89 c7                	mov    %eax,%edi
f01044f3:	c1 ef 1f             	shr    $0x1f,%edi
f01044f6:	01 c7                	add    %eax,%edi
f01044f8:	d1 ff                	sar    %edi
f01044fa:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f01044fd:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104500:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0104504:	89 f8                	mov    %edi,%eax
		while (m >= l && stabs[m].n_type != type)
f0104506:	39 c3                	cmp    %eax,%ebx
f0104508:	7f ba                	jg     f01044c4 <stab_binsearch+0x25>
f010450a:	0f b6 0a             	movzbl (%edx),%ecx
f010450d:	83 ea 0c             	sub    $0xc,%edx
f0104510:	39 f1                	cmp    %esi,%ecx
f0104512:	74 b5                	je     f01044c9 <stab_binsearch+0x2a>
			m--;
f0104514:	83 e8 01             	sub    $0x1,%eax
f0104517:	eb ed                	jmp    f0104506 <stab_binsearch+0x67>
		} else if (stabs[m].n_value > addr) {
f0104519:	3b 55 0c             	cmp    0xc(%ebp),%edx
f010451c:	76 14                	jbe    f0104532 <stab_binsearch+0x93>
			*region_right = m - 1;
f010451e:	83 e8 01             	sub    $0x1,%eax
f0104521:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104524:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0104527:	89 07                	mov    %eax,(%edi)
		any_matches = 1;
f0104529:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104530:	eb b5                	jmp    f01044e7 <stab_binsearch+0x48>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0104532:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104535:	89 07                	mov    %eax,(%edi)
			l = m;
			addr++;
f0104537:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f010453b:	89 c3                	mov    %eax,%ebx
		any_matches = 1;
f010453d:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104544:	eb a1                	jmp    f01044e7 <stab_binsearch+0x48>
		}
	}

	if (!any_matches)
f0104546:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f010454a:	75 15                	jne    f0104561 <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f010454c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010454f:	8b 00                	mov    (%eax),%eax
f0104551:	83 e8 01             	sub    $0x1,%eax
f0104554:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104557:	89 06                	mov    %eax,(%esi)
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0104559:	83 c4 14             	add    $0x14,%esp
f010455c:	5b                   	pop    %ebx
f010455d:	5e                   	pop    %esi
f010455e:	5f                   	pop    %edi
f010455f:	5d                   	pop    %ebp
f0104560:	c3                   	ret    
		for (l = *region_right;
f0104561:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104564:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0104566:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104569:	8b 0f                	mov    (%edi),%ecx
f010456b:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010456e:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0104571:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
		for (l = *region_right;
f0104575:	eb 03                	jmp    f010457a <stab_binsearch+0xdb>
		     l--)
f0104577:	83 e8 01             	sub    $0x1,%eax
		for (l = *region_right;
f010457a:	39 c1                	cmp    %eax,%ecx
f010457c:	7d 0a                	jge    f0104588 <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f010457e:	0f b6 1a             	movzbl (%edx),%ebx
f0104581:	83 ea 0c             	sub    $0xc,%edx
f0104584:	39 f3                	cmp    %esi,%ebx
f0104586:	75 ef                	jne    f0104577 <stab_binsearch+0xd8>
		*region_left = l;
f0104588:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f010458b:	89 06                	mov    %eax,(%esi)
}
f010458d:	eb ca                	jmp    f0104559 <stab_binsearch+0xba>

f010458f <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f010458f:	55                   	push   %ebp
f0104590:	89 e5                	mov    %esp,%ebp
f0104592:	57                   	push   %edi
f0104593:	56                   	push   %esi
f0104594:	53                   	push   %ebx
f0104595:	83 ec 4c             	sub    $0x4c,%esp
f0104598:	8b 75 08             	mov    0x8(%ebp),%esi
f010459b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f010459e:	c7 03 ac 73 10 f0    	movl   $0xf01073ac,(%ebx)
	info->eip_line = 0;
f01045a4:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f01045ab:	c7 43 08 ac 73 10 f0 	movl   $0xf01073ac,0x8(%ebx)
	info->eip_fn_namelen = 9;
f01045b2:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f01045b9:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f01045bc:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f01045c3:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f01045c9:	0f 87 1d 01 00 00    	ja     f01046ec <debuginfo_eip+0x15d>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f01045cf:	a1 00 00 20 00       	mov    0x200000,%eax
f01045d4:	89 45 b8             	mov    %eax,-0x48(%ebp)
		stab_end = usd->stab_end;
f01045d7:	a1 04 00 20 00       	mov    0x200004,%eax
		stabstr = usd->stabstr;
f01045dc:	8b 3d 08 00 20 00    	mov    0x200008,%edi
f01045e2:	89 7d b4             	mov    %edi,-0x4c(%ebp)
		stabstr_end = usd->stabstr_end;
f01045e5:	8b 3d 0c 00 20 00    	mov    0x20000c,%edi
f01045eb:	89 7d bc             	mov    %edi,-0x44(%ebp)
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01045ee:	8b 7d bc             	mov    -0x44(%ebp),%edi
f01045f1:	39 7d b4             	cmp    %edi,-0x4c(%ebp)
f01045f4:	0f 83 bb 01 00 00    	jae    f01047b5 <debuginfo_eip+0x226>
f01045fa:	80 7f ff 00          	cmpb   $0x0,-0x1(%edi)
f01045fe:	0f 85 b8 01 00 00    	jne    f01047bc <debuginfo_eip+0x22d>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0104604:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f010460b:	8b 7d b8             	mov    -0x48(%ebp),%edi
f010460e:	29 f8                	sub    %edi,%eax
f0104610:	c1 f8 02             	sar    $0x2,%eax
f0104613:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0104619:	83 e8 01             	sub    $0x1,%eax
f010461c:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f010461f:	56                   	push   %esi
f0104620:	6a 64                	push   $0x64
f0104622:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104625:	89 c1                	mov    %eax,%ecx
f0104627:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f010462a:	89 f8                	mov    %edi,%eax
f010462c:	e8 6e fe ff ff       	call   f010449f <stab_binsearch>
	if (lfile == 0)
f0104631:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104634:	83 c4 08             	add    $0x8,%esp
f0104637:	85 c0                	test   %eax,%eax
f0104639:	0f 84 84 01 00 00    	je     f01047c3 <debuginfo_eip+0x234>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f010463f:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0104642:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104645:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0104648:	56                   	push   %esi
f0104649:	6a 24                	push   $0x24
f010464b:	8d 45 d8             	lea    -0x28(%ebp),%eax
f010464e:	89 c1                	mov    %eax,%ecx
f0104650:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0104653:	89 f8                	mov    %edi,%eax
f0104655:	e8 45 fe ff ff       	call   f010449f <stab_binsearch>

	if (lfun <= rfun) {
f010465a:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010465d:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0104660:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
f0104663:	83 c4 08             	add    $0x8,%esp
f0104666:	39 c8                	cmp    %ecx,%eax
f0104668:	0f 8f 9d 00 00 00    	jg     f010470b <debuginfo_eip+0x17c>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f010466e:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104671:	8d 0c 97             	lea    (%edi,%edx,4),%ecx
f0104674:	8b 11                	mov    (%ecx),%edx
f0104676:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0104679:	2b 7d b4             	sub    -0x4c(%ebp),%edi
f010467c:	39 fa                	cmp    %edi,%edx
f010467e:	73 06                	jae    f0104686 <debuginfo_eip+0xf7>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0104680:	03 55 b4             	add    -0x4c(%ebp),%edx
f0104683:	89 53 08             	mov    %edx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0104686:	8b 51 08             	mov    0x8(%ecx),%edx
f0104689:	89 53 10             	mov    %edx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f010468c:	29 d6                	sub    %edx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f010468e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0104691:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0104694:	89 45 d0             	mov    %eax,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0104697:	83 ec 08             	sub    $0x8,%esp
f010469a:	6a 3a                	push   $0x3a
f010469c:	ff 73 08             	pushl  0x8(%ebx)
f010469f:	e8 0e 09 00 00       	call   f0104fb2 <strfind>
f01046a4:	2b 43 08             	sub    0x8(%ebx),%eax
f01046a7:	89 43 0c             	mov    %eax,0xc(%ebx)
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f01046aa:	83 c4 08             	add    $0x8,%esp
f01046ad:	56                   	push   %esi
f01046ae:	6a 44                	push   $0x44
f01046b0:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f01046b3:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f01046b6:	8b 75 b8             	mov    -0x48(%ebp),%esi
f01046b9:	89 f0                	mov    %esi,%eax
f01046bb:	e8 df fd ff ff       	call   f010449f <stab_binsearch>
	if (lline <= rline) {
f01046c0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01046c3:	83 c4 10             	add    $0x10,%esp
f01046c6:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f01046c9:	0f 8f fb 00 00 00    	jg     f01047ca <debuginfo_eip+0x23b>
		 info->eip_line = stabs[lline].n_desc;
f01046cf:	89 d0                	mov    %edx,%eax
f01046d1:	8d 14 52             	lea    (%edx,%edx,2),%edx
f01046d4:	c1 e2 02             	shl    $0x2,%edx
f01046d7:	0f b7 4c 16 06       	movzwl 0x6(%esi,%edx,1),%ecx
f01046dc:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01046df:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01046e2:	8d 54 16 04          	lea    0x4(%esi,%edx,1),%edx
f01046e6:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f01046ea:	eb 3d                	jmp    f0104729 <debuginfo_eip+0x19a>
		stabstr_end = __STABSTR_END__;
f01046ec:	c7 45 bc 7f 70 11 f0 	movl   $0xf011707f,-0x44(%ebp)
		stabstr = __STABSTR_BEGIN__;
f01046f3:	c7 45 b4 31 39 11 f0 	movl   $0xf0113931,-0x4c(%ebp)
		stab_end = __STAB_END__;
f01046fa:	b8 30 39 11 f0       	mov    $0xf0113930,%eax
		stabs = __STAB_BEGIN__;
f01046ff:	c7 45 b8 94 78 10 f0 	movl   $0xf0107894,-0x48(%ebp)
f0104706:	e9 e3 fe ff ff       	jmp    f01045ee <debuginfo_eip+0x5f>
		info->eip_fn_addr = addr;
f010470b:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f010470e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104711:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0104714:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104717:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010471a:	e9 78 ff ff ff       	jmp    f0104697 <debuginfo_eip+0x108>
f010471f:	83 e8 01             	sub    $0x1,%eax
f0104722:	83 ea 0c             	sub    $0xc,%edx
f0104725:	c6 45 c4 01          	movb   $0x1,-0x3c(%ebp)
f0104729:	89 45 c0             	mov    %eax,-0x40(%ebp)
	while (lline >= lfile
f010472c:	39 c7                	cmp    %eax,%edi
f010472e:	7f 45                	jg     f0104775 <debuginfo_eip+0x1e6>
	       && stabs[lline].n_type != N_SOL
f0104730:	0f b6 0a             	movzbl (%edx),%ecx
f0104733:	80 f9 84             	cmp    $0x84,%cl
f0104736:	74 19                	je     f0104751 <debuginfo_eip+0x1c2>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104738:	80 f9 64             	cmp    $0x64,%cl
f010473b:	75 e2                	jne    f010471f <debuginfo_eip+0x190>
f010473d:	83 7a 04 00          	cmpl   $0x0,0x4(%edx)
f0104741:	74 dc                	je     f010471f <debuginfo_eip+0x190>
f0104743:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0104747:	74 11                	je     f010475a <debuginfo_eip+0x1cb>
f0104749:	8b 75 c0             	mov    -0x40(%ebp),%esi
f010474c:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f010474f:	eb 09                	jmp    f010475a <debuginfo_eip+0x1cb>
f0104751:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0104755:	74 03                	je     f010475a <debuginfo_eip+0x1cb>
f0104757:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f010475a:	8d 04 40             	lea    (%eax,%eax,2),%eax
f010475d:	8b 7d b8             	mov    -0x48(%ebp),%edi
f0104760:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0104763:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0104766:	8b 7d b4             	mov    -0x4c(%ebp),%edi
f0104769:	29 f8                	sub    %edi,%eax
f010476b:	39 c2                	cmp    %eax,%edx
f010476d:	73 06                	jae    f0104775 <debuginfo_eip+0x1e6>
		info->eip_file = stabstr + stabs[lline].n_strx;
f010476f:	89 f8                	mov    %edi,%eax
f0104771:	01 d0                	add    %edx,%eax
f0104773:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104775:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104778:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f010477b:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f0104780:	39 f2                	cmp    %esi,%edx
f0104782:	7d 52                	jge    f01047d6 <debuginfo_eip+0x247>
		for (lline = lfun + 1;
f0104784:	83 c2 01             	add    $0x1,%edx
f0104787:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f010478a:	89 d0                	mov    %edx,%eax
f010478c:	8d 14 52             	lea    (%edx,%edx,2),%edx
f010478f:	8b 7d b8             	mov    -0x48(%ebp),%edi
f0104792:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
f0104796:	eb 04                	jmp    f010479c <debuginfo_eip+0x20d>
			info->eip_fn_narg++;
f0104798:	83 43 14 01          	addl   $0x1,0x14(%ebx)
		for (lline = lfun + 1;
f010479c:	39 c6                	cmp    %eax,%esi
f010479e:	7e 31                	jle    f01047d1 <debuginfo_eip+0x242>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01047a0:	0f b6 0a             	movzbl (%edx),%ecx
f01047a3:	83 c0 01             	add    $0x1,%eax
f01047a6:	83 c2 0c             	add    $0xc,%edx
f01047a9:	80 f9 a0             	cmp    $0xa0,%cl
f01047ac:	74 ea                	je     f0104798 <debuginfo_eip+0x209>
	return 0;
f01047ae:	b8 00 00 00 00       	mov    $0x0,%eax
f01047b3:	eb 21                	jmp    f01047d6 <debuginfo_eip+0x247>
		return -1;
f01047b5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01047ba:	eb 1a                	jmp    f01047d6 <debuginfo_eip+0x247>
f01047bc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01047c1:	eb 13                	jmp    f01047d6 <debuginfo_eip+0x247>
		return -1;
f01047c3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01047c8:	eb 0c                	jmp    f01047d6 <debuginfo_eip+0x247>
		 return -1;
f01047ca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01047cf:	eb 05                	jmp    f01047d6 <debuginfo_eip+0x247>
	return 0;
f01047d1:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01047d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01047d9:	5b                   	pop    %ebx
f01047da:	5e                   	pop    %esi
f01047db:	5f                   	pop    %edi
f01047dc:	5d                   	pop    %ebp
f01047dd:	c3                   	ret    

f01047de <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f01047de:	55                   	push   %ebp
f01047df:	89 e5                	mov    %esp,%ebp
f01047e1:	57                   	push   %edi
f01047e2:	56                   	push   %esi
f01047e3:	53                   	push   %ebx
f01047e4:	83 ec 1c             	sub    $0x1c,%esp
f01047e7:	89 c7                	mov    %eax,%edi
f01047e9:	89 d6                	mov    %edx,%esi
f01047eb:	8b 45 08             	mov    0x8(%ebp),%eax
f01047ee:	8b 55 0c             	mov    0xc(%ebp),%edx
f01047f1:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01047f4:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f01047f7:	8b 4d 10             	mov    0x10(%ebp),%ecx
f01047fa:	bb 00 00 00 00       	mov    $0x0,%ebx
f01047ff:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104802:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0104805:	3b 45 10             	cmp    0x10(%ebp),%eax
f0104808:	89 d0                	mov    %edx,%eax
f010480a:	1b 45 e4             	sbb    -0x1c(%ebp),%eax
f010480d:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0104810:	73 15                	jae    f0104827 <printnum+0x49>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0104812:	83 eb 01             	sub    $0x1,%ebx
f0104815:	85 db                	test   %ebx,%ebx
f0104817:	7e 43                	jle    f010485c <printnum+0x7e>
			putch(padc, putdat);
f0104819:	83 ec 08             	sub    $0x8,%esp
f010481c:	56                   	push   %esi
f010481d:	ff 75 18             	pushl  0x18(%ebp)
f0104820:	ff d7                	call   *%edi
f0104822:	83 c4 10             	add    $0x10,%esp
f0104825:	eb eb                	jmp    f0104812 <printnum+0x34>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0104827:	83 ec 0c             	sub    $0xc,%esp
f010482a:	ff 75 18             	pushl  0x18(%ebp)
f010482d:	8b 45 14             	mov    0x14(%ebp),%eax
f0104830:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0104833:	53                   	push   %ebx
f0104834:	ff 75 10             	pushl  0x10(%ebp)
f0104837:	83 ec 08             	sub    $0x8,%esp
f010483a:	ff 75 e4             	pushl  -0x1c(%ebp)
f010483d:	ff 75 e0             	pushl  -0x20(%ebp)
f0104840:	ff 75 dc             	pushl  -0x24(%ebp)
f0104843:	ff 75 d8             	pushl  -0x28(%ebp)
f0104846:	e8 85 11 00 00       	call   f01059d0 <__udivdi3>
f010484b:	83 c4 18             	add    $0x18,%esp
f010484e:	52                   	push   %edx
f010484f:	50                   	push   %eax
f0104850:	89 f2                	mov    %esi,%edx
f0104852:	89 f8                	mov    %edi,%eax
f0104854:	e8 85 ff ff ff       	call   f01047de <printnum>
f0104859:	83 c4 20             	add    $0x20,%esp
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f010485c:	83 ec 08             	sub    $0x8,%esp
f010485f:	56                   	push   %esi
f0104860:	83 ec 04             	sub    $0x4,%esp
f0104863:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104866:	ff 75 e0             	pushl  -0x20(%ebp)
f0104869:	ff 75 dc             	pushl  -0x24(%ebp)
f010486c:	ff 75 d8             	pushl  -0x28(%ebp)
f010486f:	e8 6c 12 00 00       	call   f0105ae0 <__umoddi3>
f0104874:	83 c4 14             	add    $0x14,%esp
f0104877:	0f be 80 b6 73 10 f0 	movsbl -0xfef8c4a(%eax),%eax
f010487e:	50                   	push   %eax
f010487f:	ff d7                	call   *%edi
}
f0104881:	83 c4 10             	add    $0x10,%esp
f0104884:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104887:	5b                   	pop    %ebx
f0104888:	5e                   	pop    %esi
f0104889:	5f                   	pop    %edi
f010488a:	5d                   	pop    %ebp
f010488b:	c3                   	ret    

f010488c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f010488c:	55                   	push   %ebp
f010488d:	89 e5                	mov    %esp,%ebp
f010488f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0104892:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0104896:	8b 10                	mov    (%eax),%edx
f0104898:	3b 50 04             	cmp    0x4(%eax),%edx
f010489b:	73 0a                	jae    f01048a7 <sprintputch+0x1b>
		*b->buf++ = ch;
f010489d:	8d 4a 01             	lea    0x1(%edx),%ecx
f01048a0:	89 08                	mov    %ecx,(%eax)
f01048a2:	8b 45 08             	mov    0x8(%ebp),%eax
f01048a5:	88 02                	mov    %al,(%edx)
}
f01048a7:	5d                   	pop    %ebp
f01048a8:	c3                   	ret    

f01048a9 <printfmt>:
{
f01048a9:	55                   	push   %ebp
f01048aa:	89 e5                	mov    %esp,%ebp
f01048ac:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f01048af:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f01048b2:	50                   	push   %eax
f01048b3:	ff 75 10             	pushl  0x10(%ebp)
f01048b6:	ff 75 0c             	pushl  0xc(%ebp)
f01048b9:	ff 75 08             	pushl  0x8(%ebp)
f01048bc:	e8 05 00 00 00       	call   f01048c6 <vprintfmt>
}
f01048c1:	83 c4 10             	add    $0x10,%esp
f01048c4:	c9                   	leave  
f01048c5:	c3                   	ret    

f01048c6 <vprintfmt>:
{
f01048c6:	55                   	push   %ebp
f01048c7:	89 e5                	mov    %esp,%ebp
f01048c9:	57                   	push   %edi
f01048ca:	56                   	push   %esi
f01048cb:	53                   	push   %ebx
f01048cc:	83 ec 3c             	sub    $0x3c,%esp
f01048cf:	8b 75 08             	mov    0x8(%ebp),%esi
f01048d2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01048d5:	8b 7d 10             	mov    0x10(%ebp),%edi
f01048d8:	eb 0a                	jmp    f01048e4 <vprintfmt+0x1e>
			putch(ch, putdat);
f01048da:	83 ec 08             	sub    $0x8,%esp
f01048dd:	53                   	push   %ebx
f01048de:	50                   	push   %eax
f01048df:	ff d6                	call   *%esi
f01048e1:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01048e4:	83 c7 01             	add    $0x1,%edi
f01048e7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f01048eb:	83 f8 25             	cmp    $0x25,%eax
f01048ee:	74 0c                	je     f01048fc <vprintfmt+0x36>
			if (ch == '\0')
f01048f0:	85 c0                	test   %eax,%eax
f01048f2:	75 e6                	jne    f01048da <vprintfmt+0x14>
}
f01048f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01048f7:	5b                   	pop    %ebx
f01048f8:	5e                   	pop    %esi
f01048f9:	5f                   	pop    %edi
f01048fa:	5d                   	pop    %ebp
f01048fb:	c3                   	ret    
		padc = ' ';
f01048fc:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
f0104900:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;//精度
f0104907:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;//总宽度
f010490e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f0104915:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f010491a:	8d 47 01             	lea    0x1(%edi),%eax
f010491d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104920:	0f b6 17             	movzbl (%edi),%edx
f0104923:	8d 42 dd             	lea    -0x23(%edx),%eax
f0104926:	3c 55                	cmp    $0x55,%al
f0104928:	0f 87 ba 03 00 00    	ja     f0104ce8 <vprintfmt+0x422>
f010492e:	0f b6 c0             	movzbl %al,%eax
f0104931:	ff 24 85 80 74 10 f0 	jmp    *-0xfef8b80(,%eax,4)
f0104938:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
f010493b:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
f010493f:	eb d9                	jmp    f010491a <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
f0104941:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
f0104944:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
f0104948:	eb d0                	jmp    f010491a <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
f010494a:	0f b6 d2             	movzbl %dl,%edx
f010494d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {//依次读取数据宽度
f0104950:	b8 00 00 00 00       	mov    $0x0,%eax
f0104955:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
f0104958:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010495b:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f010495f:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f0104962:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0104965:	83 f9 09             	cmp    $0x9,%ecx
f0104968:	77 55                	ja     f01049bf <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {//依次读取数据宽度
f010496a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
f010496d:	eb e9                	jmp    f0104958 <vprintfmt+0x92>
			precision = va_arg(ap, int);
f010496f:	8b 45 14             	mov    0x14(%ebp),%eax
f0104972:	8b 00                	mov    (%eax),%eax
f0104974:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104977:	8b 45 14             	mov    0x14(%ebp),%eax
f010497a:	8d 40 04             	lea    0x4(%eax),%eax
f010497d:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0104980:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
f0104983:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0104987:	79 91                	jns    f010491a <vprintfmt+0x54>
				width = precision, precision = -1;
f0104989:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010498c:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010498f:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
f0104996:	eb 82                	jmp    f010491a <vprintfmt+0x54>
f0104998:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010499b:	85 c0                	test   %eax,%eax
f010499d:	ba 00 00 00 00       	mov    $0x0,%edx
f01049a2:	0f 49 d0             	cmovns %eax,%edx
f01049a5:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01049a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01049ab:	e9 6a ff ff ff       	jmp    f010491a <vprintfmt+0x54>
f01049b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
f01049b3:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
f01049ba:	e9 5b ff ff ff       	jmp    f010491a <vprintfmt+0x54>
f01049bf:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01049c2:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01049c5:	eb bc                	jmp    f0104983 <vprintfmt+0xbd>
			lflag++;
f01049c7:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f01049ca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f01049cd:	e9 48 ff ff ff       	jmp    f010491a <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
f01049d2:	8b 45 14             	mov    0x14(%ebp),%eax
f01049d5:	8d 78 04             	lea    0x4(%eax),%edi
f01049d8:	83 ec 08             	sub    $0x8,%esp
f01049db:	53                   	push   %ebx
f01049dc:	ff 30                	pushl  (%eax)
f01049de:	ff d6                	call   *%esi
			break;
f01049e0:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f01049e3:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
f01049e6:	e9 9c 02 00 00       	jmp    f0104c87 <vprintfmt+0x3c1>
			err = va_arg(ap, int);
f01049eb:	8b 45 14             	mov    0x14(%ebp),%eax
f01049ee:	8d 78 04             	lea    0x4(%eax),%edi
f01049f1:	8b 00                	mov    (%eax),%eax
f01049f3:	99                   	cltd   
f01049f4:	31 d0                	xor    %edx,%eax
f01049f6:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01049f8:	83 f8 08             	cmp    $0x8,%eax
f01049fb:	7f 23                	jg     f0104a20 <vprintfmt+0x15a>
f01049fd:	8b 14 85 e0 75 10 f0 	mov    -0xfef8a20(,%eax,4),%edx
f0104a04:	85 d2                	test   %edx,%edx
f0104a06:	74 18                	je     f0104a20 <vprintfmt+0x15a>
				printfmt(putch, putdat, "%s", p);
f0104a08:	52                   	push   %edx
f0104a09:	68 50 62 10 f0       	push   $0xf0106250
f0104a0e:	53                   	push   %ebx
f0104a0f:	56                   	push   %esi
f0104a10:	e8 94 fe ff ff       	call   f01048a9 <printfmt>
f0104a15:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0104a18:	89 7d 14             	mov    %edi,0x14(%ebp)
f0104a1b:	e9 67 02 00 00       	jmp    f0104c87 <vprintfmt+0x3c1>
				printfmt(putch, putdat, "error %d", err);
f0104a20:	50                   	push   %eax
f0104a21:	68 ce 73 10 f0       	push   $0xf01073ce
f0104a26:	53                   	push   %ebx
f0104a27:	56                   	push   %esi
f0104a28:	e8 7c fe ff ff       	call   f01048a9 <printfmt>
f0104a2d:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0104a30:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f0104a33:	e9 4f 02 00 00       	jmp    f0104c87 <vprintfmt+0x3c1>
			if ((p = va_arg(ap, char *)) == NULL)
f0104a38:	8b 45 14             	mov    0x14(%ebp),%eax
f0104a3b:	83 c0 04             	add    $0x4,%eax
f0104a3e:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0104a41:	8b 45 14             	mov    0x14(%ebp),%eax
f0104a44:	8b 10                	mov    (%eax),%edx
				p = "(null)";
f0104a46:	85 d2                	test   %edx,%edx
f0104a48:	b8 c7 73 10 f0       	mov    $0xf01073c7,%eax
f0104a4d:	0f 45 c2             	cmovne %edx,%eax
f0104a50:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
f0104a53:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0104a57:	7e 06                	jle    f0104a5f <vprintfmt+0x199>
f0104a59:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
f0104a5d:	75 0d                	jne    f0104a6c <vprintfmt+0x1a6>
				for (width -= strnlen(p, precision); width > 0; width--)
f0104a5f:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0104a62:	89 c7                	mov    %eax,%edi
f0104a64:	03 45 e0             	add    -0x20(%ebp),%eax
f0104a67:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104a6a:	eb 3f                	jmp    f0104aab <vprintfmt+0x1e5>
f0104a6c:	83 ec 08             	sub    $0x8,%esp
f0104a6f:	ff 75 d8             	pushl  -0x28(%ebp)
f0104a72:	50                   	push   %eax
f0104a73:	e8 ef 03 00 00       	call   f0104e67 <strnlen>
f0104a78:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104a7b:	29 c2                	sub    %eax,%edx
f0104a7d:	89 55 c4             	mov    %edx,-0x3c(%ebp)
f0104a80:	83 c4 10             	add    $0x10,%esp
f0104a83:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
f0104a85:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
f0104a89:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f0104a8c:	85 ff                	test   %edi,%edi
f0104a8e:	7e 58                	jle    f0104ae8 <vprintfmt+0x222>
					putch(padc, putdat);
f0104a90:	83 ec 08             	sub    $0x8,%esp
f0104a93:	53                   	push   %ebx
f0104a94:	ff 75 e0             	pushl  -0x20(%ebp)
f0104a97:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f0104a99:	83 ef 01             	sub    $0x1,%edi
f0104a9c:	83 c4 10             	add    $0x10,%esp
f0104a9f:	eb eb                	jmp    f0104a8c <vprintfmt+0x1c6>
					putch(ch, putdat);
f0104aa1:	83 ec 08             	sub    $0x8,%esp
f0104aa4:	53                   	push   %ebx
f0104aa5:	52                   	push   %edx
f0104aa6:	ff d6                	call   *%esi
f0104aa8:	83 c4 10             	add    $0x10,%esp
f0104aab:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0104aae:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0104ab0:	83 c7 01             	add    $0x1,%edi
f0104ab3:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0104ab7:	0f be d0             	movsbl %al,%edx
f0104aba:	85 d2                	test   %edx,%edx
f0104abc:	74 45                	je     f0104b03 <vprintfmt+0x23d>
f0104abe:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0104ac2:	78 06                	js     f0104aca <vprintfmt+0x204>
f0104ac4:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
f0104ac8:	78 35                	js     f0104aff <vprintfmt+0x239>
				if (altflag && (ch < ' ' || ch > '~'))
f0104aca:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0104ace:	74 d1                	je     f0104aa1 <vprintfmt+0x1db>
f0104ad0:	0f be c0             	movsbl %al,%eax
f0104ad3:	83 e8 20             	sub    $0x20,%eax
f0104ad6:	83 f8 5e             	cmp    $0x5e,%eax
f0104ad9:	76 c6                	jbe    f0104aa1 <vprintfmt+0x1db>
					putch('?', putdat);
f0104adb:	83 ec 08             	sub    $0x8,%esp
f0104ade:	53                   	push   %ebx
f0104adf:	6a 3f                	push   $0x3f
f0104ae1:	ff d6                	call   *%esi
f0104ae3:	83 c4 10             	add    $0x10,%esp
f0104ae6:	eb c3                	jmp    f0104aab <vprintfmt+0x1e5>
f0104ae8:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0104aeb:	85 d2                	test   %edx,%edx
f0104aed:	b8 00 00 00 00       	mov    $0x0,%eax
f0104af2:	0f 49 c2             	cmovns %edx,%eax
f0104af5:	29 c2                	sub    %eax,%edx
f0104af7:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0104afa:	e9 60 ff ff ff       	jmp    f0104a5f <vprintfmt+0x199>
f0104aff:	89 cf                	mov    %ecx,%edi
f0104b01:	eb 02                	jmp    f0104b05 <vprintfmt+0x23f>
f0104b03:	89 cf                	mov    %ecx,%edi
			for (; width > 0; width--)
f0104b05:	85 ff                	test   %edi,%edi
f0104b07:	7e 10                	jle    f0104b19 <vprintfmt+0x253>
				putch(' ', putdat);
f0104b09:	83 ec 08             	sub    $0x8,%esp
f0104b0c:	53                   	push   %ebx
f0104b0d:	6a 20                	push   $0x20
f0104b0f:	ff d6                	call   *%esi
			for (; width > 0; width--)
f0104b11:	83 ef 01             	sub    $0x1,%edi
f0104b14:	83 c4 10             	add    $0x10,%esp
f0104b17:	eb ec                	jmp    f0104b05 <vprintfmt+0x23f>
			if ((p = va_arg(ap, char *)) == NULL)
f0104b19:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0104b1c:	89 45 14             	mov    %eax,0x14(%ebp)
f0104b1f:	e9 63 01 00 00       	jmp    f0104c87 <vprintfmt+0x3c1>
	if (lflag >= 2)
f0104b24:	83 f9 01             	cmp    $0x1,%ecx
f0104b27:	7f 1b                	jg     f0104b44 <vprintfmt+0x27e>
	else if (lflag)
f0104b29:	85 c9                	test   %ecx,%ecx
f0104b2b:	74 63                	je     f0104b90 <vprintfmt+0x2ca>
		return va_arg(*ap, long);
f0104b2d:	8b 45 14             	mov    0x14(%ebp),%eax
f0104b30:	8b 00                	mov    (%eax),%eax
f0104b32:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104b35:	99                   	cltd   
f0104b36:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0104b39:	8b 45 14             	mov    0x14(%ebp),%eax
f0104b3c:	8d 40 04             	lea    0x4(%eax),%eax
f0104b3f:	89 45 14             	mov    %eax,0x14(%ebp)
f0104b42:	eb 17                	jmp    f0104b5b <vprintfmt+0x295>
		return va_arg(*ap, long long);
f0104b44:	8b 45 14             	mov    0x14(%ebp),%eax
f0104b47:	8b 50 04             	mov    0x4(%eax),%edx
f0104b4a:	8b 00                	mov    (%eax),%eax
f0104b4c:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104b4f:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0104b52:	8b 45 14             	mov    0x14(%ebp),%eax
f0104b55:	8d 40 08             	lea    0x8(%eax),%eax
f0104b58:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f0104b5b:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104b5e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f0104b61:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
f0104b66:	85 c9                	test   %ecx,%ecx
f0104b68:	0f 89 ff 00 00 00    	jns    f0104c6d <vprintfmt+0x3a7>
				putch('-', putdat);
f0104b6e:	83 ec 08             	sub    $0x8,%esp
f0104b71:	53                   	push   %ebx
f0104b72:	6a 2d                	push   $0x2d
f0104b74:	ff d6                	call   *%esi
				num = -(long long) num;
f0104b76:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104b79:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0104b7c:	f7 da                	neg    %edx
f0104b7e:	83 d1 00             	adc    $0x0,%ecx
f0104b81:	f7 d9                	neg    %ecx
f0104b83:	83 c4 10             	add    $0x10,%esp
			base = 10;
f0104b86:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104b8b:	e9 dd 00 00 00       	jmp    f0104c6d <vprintfmt+0x3a7>
		return va_arg(*ap, int);
f0104b90:	8b 45 14             	mov    0x14(%ebp),%eax
f0104b93:	8b 00                	mov    (%eax),%eax
f0104b95:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104b98:	99                   	cltd   
f0104b99:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0104b9c:	8b 45 14             	mov    0x14(%ebp),%eax
f0104b9f:	8d 40 04             	lea    0x4(%eax),%eax
f0104ba2:	89 45 14             	mov    %eax,0x14(%ebp)
f0104ba5:	eb b4                	jmp    f0104b5b <vprintfmt+0x295>
	if (lflag >= 2)
f0104ba7:	83 f9 01             	cmp    $0x1,%ecx
f0104baa:	7f 1e                	jg     f0104bca <vprintfmt+0x304>
	else if (lflag)
f0104bac:	85 c9                	test   %ecx,%ecx
f0104bae:	74 32                	je     f0104be2 <vprintfmt+0x31c>
		return va_arg(*ap, unsigned long);
f0104bb0:	8b 45 14             	mov    0x14(%ebp),%eax
f0104bb3:	8b 10                	mov    (%eax),%edx
f0104bb5:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104bba:	8d 40 04             	lea    0x4(%eax),%eax
f0104bbd:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0104bc0:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104bc5:	e9 a3 00 00 00       	jmp    f0104c6d <vprintfmt+0x3a7>
		return va_arg(*ap, unsigned long long);
f0104bca:	8b 45 14             	mov    0x14(%ebp),%eax
f0104bcd:	8b 10                	mov    (%eax),%edx
f0104bcf:	8b 48 04             	mov    0x4(%eax),%ecx
f0104bd2:	8d 40 08             	lea    0x8(%eax),%eax
f0104bd5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0104bd8:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104bdd:	e9 8b 00 00 00       	jmp    f0104c6d <vprintfmt+0x3a7>
		return va_arg(*ap, unsigned int);
f0104be2:	8b 45 14             	mov    0x14(%ebp),%eax
f0104be5:	8b 10                	mov    (%eax),%edx
f0104be7:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104bec:	8d 40 04             	lea    0x4(%eax),%eax
f0104bef:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0104bf2:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104bf7:	eb 74                	jmp    f0104c6d <vprintfmt+0x3a7>
	if (lflag >= 2)
f0104bf9:	83 f9 01             	cmp    $0x1,%ecx
f0104bfc:	7f 1b                	jg     f0104c19 <vprintfmt+0x353>
	else if (lflag)
f0104bfe:	85 c9                	test   %ecx,%ecx
f0104c00:	74 2c                	je     f0104c2e <vprintfmt+0x368>
		return va_arg(*ap, unsigned long);
f0104c02:	8b 45 14             	mov    0x14(%ebp),%eax
f0104c05:	8b 10                	mov    (%eax),%edx
f0104c07:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104c0c:	8d 40 04             	lea    0x4(%eax),%eax
f0104c0f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0104c12:	b8 08 00 00 00       	mov    $0x8,%eax
f0104c17:	eb 54                	jmp    f0104c6d <vprintfmt+0x3a7>
		return va_arg(*ap, unsigned long long);
f0104c19:	8b 45 14             	mov    0x14(%ebp),%eax
f0104c1c:	8b 10                	mov    (%eax),%edx
f0104c1e:	8b 48 04             	mov    0x4(%eax),%ecx
f0104c21:	8d 40 08             	lea    0x8(%eax),%eax
f0104c24:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0104c27:	b8 08 00 00 00       	mov    $0x8,%eax
f0104c2c:	eb 3f                	jmp    f0104c6d <vprintfmt+0x3a7>
		return va_arg(*ap, unsigned int);
f0104c2e:	8b 45 14             	mov    0x14(%ebp),%eax
f0104c31:	8b 10                	mov    (%eax),%edx
f0104c33:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104c38:	8d 40 04             	lea    0x4(%eax),%eax
f0104c3b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0104c3e:	b8 08 00 00 00       	mov    $0x8,%eax
f0104c43:	eb 28                	jmp    f0104c6d <vprintfmt+0x3a7>
			putch('0', putdat);
f0104c45:	83 ec 08             	sub    $0x8,%esp
f0104c48:	53                   	push   %ebx
f0104c49:	6a 30                	push   $0x30
f0104c4b:	ff d6                	call   *%esi
			putch('x', putdat);
f0104c4d:	83 c4 08             	add    $0x8,%esp
f0104c50:	53                   	push   %ebx
f0104c51:	6a 78                	push   $0x78
f0104c53:	ff d6                	call   *%esi
			num = (unsigned long long)
f0104c55:	8b 45 14             	mov    0x14(%ebp),%eax
f0104c58:	8b 10                	mov    (%eax),%edx
f0104c5a:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f0104c5f:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f0104c62:	8d 40 04             	lea    0x4(%eax),%eax
f0104c65:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0104c68:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
f0104c6d:	83 ec 0c             	sub    $0xc,%esp
f0104c70:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
f0104c74:	57                   	push   %edi
f0104c75:	ff 75 e0             	pushl  -0x20(%ebp)
f0104c78:	50                   	push   %eax
f0104c79:	51                   	push   %ecx
f0104c7a:	52                   	push   %edx
f0104c7b:	89 da                	mov    %ebx,%edx
f0104c7d:	89 f0                	mov    %esi,%eax
f0104c7f:	e8 5a fb ff ff       	call   f01047de <printnum>
			break;
f0104c84:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
f0104c87:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0104c8a:	e9 55 fc ff ff       	jmp    f01048e4 <vprintfmt+0x1e>
	if (lflag >= 2)
f0104c8f:	83 f9 01             	cmp    $0x1,%ecx
f0104c92:	7f 1b                	jg     f0104caf <vprintfmt+0x3e9>
	else if (lflag)
f0104c94:	85 c9                	test   %ecx,%ecx
f0104c96:	74 2c                	je     f0104cc4 <vprintfmt+0x3fe>
		return va_arg(*ap, unsigned long);
f0104c98:	8b 45 14             	mov    0x14(%ebp),%eax
f0104c9b:	8b 10                	mov    (%eax),%edx
f0104c9d:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104ca2:	8d 40 04             	lea    0x4(%eax),%eax
f0104ca5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0104ca8:	b8 10 00 00 00       	mov    $0x10,%eax
f0104cad:	eb be                	jmp    f0104c6d <vprintfmt+0x3a7>
		return va_arg(*ap, unsigned long long);
f0104caf:	8b 45 14             	mov    0x14(%ebp),%eax
f0104cb2:	8b 10                	mov    (%eax),%edx
f0104cb4:	8b 48 04             	mov    0x4(%eax),%ecx
f0104cb7:	8d 40 08             	lea    0x8(%eax),%eax
f0104cba:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0104cbd:	b8 10 00 00 00       	mov    $0x10,%eax
f0104cc2:	eb a9                	jmp    f0104c6d <vprintfmt+0x3a7>
		return va_arg(*ap, unsigned int);
f0104cc4:	8b 45 14             	mov    0x14(%ebp),%eax
f0104cc7:	8b 10                	mov    (%eax),%edx
f0104cc9:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104cce:	8d 40 04             	lea    0x4(%eax),%eax
f0104cd1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0104cd4:	b8 10 00 00 00       	mov    $0x10,%eax
f0104cd9:	eb 92                	jmp    f0104c6d <vprintfmt+0x3a7>
			putch(ch, putdat);
f0104cdb:	83 ec 08             	sub    $0x8,%esp
f0104cde:	53                   	push   %ebx
f0104cdf:	6a 25                	push   $0x25
f0104ce1:	ff d6                	call   *%esi
			break;
f0104ce3:	83 c4 10             	add    $0x10,%esp
f0104ce6:	eb 9f                	jmp    f0104c87 <vprintfmt+0x3c1>
			putch('%', putdat);
f0104ce8:	83 ec 08             	sub    $0x8,%esp
f0104ceb:	53                   	push   %ebx
f0104cec:	6a 25                	push   $0x25
f0104cee:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0104cf0:	83 c4 10             	add    $0x10,%esp
f0104cf3:	89 f8                	mov    %edi,%eax
f0104cf5:	eb 03                	jmp    f0104cfa <vprintfmt+0x434>
f0104cf7:	83 e8 01             	sub    $0x1,%eax
f0104cfa:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f0104cfe:	75 f7                	jne    f0104cf7 <vprintfmt+0x431>
f0104d00:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104d03:	eb 82                	jmp    f0104c87 <vprintfmt+0x3c1>

f0104d05 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0104d05:	55                   	push   %ebp
f0104d06:	89 e5                	mov    %esp,%ebp
f0104d08:	83 ec 18             	sub    $0x18,%esp
f0104d0b:	8b 45 08             	mov    0x8(%ebp),%eax
f0104d0e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0104d11:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104d14:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0104d18:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0104d1b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0104d22:	85 c0                	test   %eax,%eax
f0104d24:	74 26                	je     f0104d4c <vsnprintf+0x47>
f0104d26:	85 d2                	test   %edx,%edx
f0104d28:	7e 22                	jle    f0104d4c <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0104d2a:	ff 75 14             	pushl  0x14(%ebp)
f0104d2d:	ff 75 10             	pushl  0x10(%ebp)
f0104d30:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0104d33:	50                   	push   %eax
f0104d34:	68 8c 48 10 f0       	push   $0xf010488c
f0104d39:	e8 88 fb ff ff       	call   f01048c6 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0104d3e:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104d41:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0104d44:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104d47:	83 c4 10             	add    $0x10,%esp
}
f0104d4a:	c9                   	leave  
f0104d4b:	c3                   	ret    
		return -E_INVAL;
f0104d4c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104d51:	eb f7                	jmp    f0104d4a <vsnprintf+0x45>

f0104d53 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0104d53:	55                   	push   %ebp
f0104d54:	89 e5                	mov    %esp,%ebp
f0104d56:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0104d59:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0104d5c:	50                   	push   %eax
f0104d5d:	ff 75 10             	pushl  0x10(%ebp)
f0104d60:	ff 75 0c             	pushl  0xc(%ebp)
f0104d63:	ff 75 08             	pushl  0x8(%ebp)
f0104d66:	e8 9a ff ff ff       	call   f0104d05 <vsnprintf>
	va_end(ap);

	return rc;
}
f0104d6b:	c9                   	leave  
f0104d6c:	c3                   	ret    

f0104d6d <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0104d6d:	55                   	push   %ebp
f0104d6e:	89 e5                	mov    %esp,%ebp
f0104d70:	57                   	push   %edi
f0104d71:	56                   	push   %esi
f0104d72:	53                   	push   %ebx
f0104d73:	83 ec 0c             	sub    $0xc,%esp
f0104d76:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0104d79:	85 c0                	test   %eax,%eax
f0104d7b:	74 11                	je     f0104d8e <readline+0x21>
		cprintf("%s", prompt);
f0104d7d:	83 ec 08             	sub    $0x8,%esp
f0104d80:	50                   	push   %eax
f0104d81:	68 50 62 10 f0       	push   $0xf0106250
f0104d86:	e8 b3 ea ff ff       	call   f010383e <cprintf>
f0104d8b:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0104d8e:	83 ec 0c             	sub    $0xc,%esp
f0104d91:	6a 00                	push   $0x0
f0104d93:	e8 55 ba ff ff       	call   f01007ed <iscons>
f0104d98:	89 c7                	mov    %eax,%edi
f0104d9a:	83 c4 10             	add    $0x10,%esp
	i = 0;
f0104d9d:	be 00 00 00 00       	mov    $0x0,%esi
f0104da2:	eb 4b                	jmp    f0104def <readline+0x82>
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
f0104da4:	83 ec 08             	sub    $0x8,%esp
f0104da7:	50                   	push   %eax
f0104da8:	68 04 76 10 f0       	push   $0xf0107604
f0104dad:	e8 8c ea ff ff       	call   f010383e <cprintf>
			return NULL;
f0104db2:	83 c4 10             	add    $0x10,%esp
f0104db5:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f0104dba:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104dbd:	5b                   	pop    %ebx
f0104dbe:	5e                   	pop    %esi
f0104dbf:	5f                   	pop    %edi
f0104dc0:	5d                   	pop    %ebp
f0104dc1:	c3                   	ret    
			if (echoing)
f0104dc2:	85 ff                	test   %edi,%edi
f0104dc4:	75 05                	jne    f0104dcb <readline+0x5e>
			i--;
f0104dc6:	83 ee 01             	sub    $0x1,%esi
f0104dc9:	eb 24                	jmp    f0104def <readline+0x82>
				cputchar('\b');
f0104dcb:	83 ec 0c             	sub    $0xc,%esp
f0104dce:	6a 08                	push   $0x8
f0104dd0:	e8 f7 b9 ff ff       	call   f01007cc <cputchar>
f0104dd5:	83 c4 10             	add    $0x10,%esp
f0104dd8:	eb ec                	jmp    f0104dc6 <readline+0x59>
				cputchar(c);
f0104dda:	83 ec 0c             	sub    $0xc,%esp
f0104ddd:	53                   	push   %ebx
f0104dde:	e8 e9 b9 ff ff       	call   f01007cc <cputchar>
f0104de3:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0104de6:	88 9e 80 2a 23 f0    	mov    %bl,-0xfdcd580(%esi)
f0104dec:	8d 76 01             	lea    0x1(%esi),%esi
		c = getchar();
f0104def:	e8 e8 b9 ff ff       	call   f01007dc <getchar>
f0104df4:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0104df6:	85 c0                	test   %eax,%eax
f0104df8:	78 aa                	js     f0104da4 <readline+0x37>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0104dfa:	83 f8 08             	cmp    $0x8,%eax
f0104dfd:	0f 94 c2             	sete   %dl
f0104e00:	83 f8 7f             	cmp    $0x7f,%eax
f0104e03:	0f 94 c0             	sete   %al
f0104e06:	08 c2                	or     %al,%dl
f0104e08:	74 04                	je     f0104e0e <readline+0xa1>
f0104e0a:	85 f6                	test   %esi,%esi
f0104e0c:	7f b4                	jg     f0104dc2 <readline+0x55>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0104e0e:	83 fb 1f             	cmp    $0x1f,%ebx
f0104e11:	7e 0e                	jle    f0104e21 <readline+0xb4>
f0104e13:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0104e19:	7f 06                	jg     f0104e21 <readline+0xb4>
			if (echoing)
f0104e1b:	85 ff                	test   %edi,%edi
f0104e1d:	74 c7                	je     f0104de6 <readline+0x79>
f0104e1f:	eb b9                	jmp    f0104dda <readline+0x6d>
		} else if (c == '\n' || c == '\r') {
f0104e21:	83 fb 0a             	cmp    $0xa,%ebx
f0104e24:	74 05                	je     f0104e2b <readline+0xbe>
f0104e26:	83 fb 0d             	cmp    $0xd,%ebx
f0104e29:	75 c4                	jne    f0104def <readline+0x82>
			if (echoing)
f0104e2b:	85 ff                	test   %edi,%edi
f0104e2d:	75 11                	jne    f0104e40 <readline+0xd3>
			buf[i] = 0;
f0104e2f:	c6 86 80 2a 23 f0 00 	movb   $0x0,-0xfdcd580(%esi)
			return buf;
f0104e36:	b8 80 2a 23 f0       	mov    $0xf0232a80,%eax
f0104e3b:	e9 7a ff ff ff       	jmp    f0104dba <readline+0x4d>
				cputchar('\n');
f0104e40:	83 ec 0c             	sub    $0xc,%esp
f0104e43:	6a 0a                	push   $0xa
f0104e45:	e8 82 b9 ff ff       	call   f01007cc <cputchar>
f0104e4a:	83 c4 10             	add    $0x10,%esp
f0104e4d:	eb e0                	jmp    f0104e2f <readline+0xc2>

f0104e4f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0104e4f:	55                   	push   %ebp
f0104e50:	89 e5                	mov    %esp,%ebp
f0104e52:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0104e55:	b8 00 00 00 00       	mov    $0x0,%eax
f0104e5a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0104e5e:	74 05                	je     f0104e65 <strlen+0x16>
		n++;
f0104e60:	83 c0 01             	add    $0x1,%eax
f0104e63:	eb f5                	jmp    f0104e5a <strlen+0xb>
	return n;
}
f0104e65:	5d                   	pop    %ebp
f0104e66:	c3                   	ret    

f0104e67 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0104e67:	55                   	push   %ebp
f0104e68:	89 e5                	mov    %esp,%ebp
f0104e6a:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104e6d:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0104e70:	ba 00 00 00 00       	mov    $0x0,%edx
f0104e75:	39 c2                	cmp    %eax,%edx
f0104e77:	74 0d                	je     f0104e86 <strnlen+0x1f>
f0104e79:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f0104e7d:	74 05                	je     f0104e84 <strnlen+0x1d>
		n++;
f0104e7f:	83 c2 01             	add    $0x1,%edx
f0104e82:	eb f1                	jmp    f0104e75 <strnlen+0xe>
f0104e84:	89 d0                	mov    %edx,%eax
	return n;
}
f0104e86:	5d                   	pop    %ebp
f0104e87:	c3                   	ret    

f0104e88 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0104e88:	55                   	push   %ebp
f0104e89:	89 e5                	mov    %esp,%ebp
f0104e8b:	53                   	push   %ebx
f0104e8c:	8b 45 08             	mov    0x8(%ebp),%eax
f0104e8f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0104e92:	ba 00 00 00 00       	mov    $0x0,%edx
f0104e97:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f0104e9b:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0104e9e:	83 c2 01             	add    $0x1,%edx
f0104ea1:	84 c9                	test   %cl,%cl
f0104ea3:	75 f2                	jne    f0104e97 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0104ea5:	5b                   	pop    %ebx
f0104ea6:	5d                   	pop    %ebp
f0104ea7:	c3                   	ret    

f0104ea8 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0104ea8:	55                   	push   %ebp
f0104ea9:	89 e5                	mov    %esp,%ebp
f0104eab:	53                   	push   %ebx
f0104eac:	83 ec 10             	sub    $0x10,%esp
f0104eaf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0104eb2:	53                   	push   %ebx
f0104eb3:	e8 97 ff ff ff       	call   f0104e4f <strlen>
f0104eb8:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
f0104ebb:	ff 75 0c             	pushl  0xc(%ebp)
f0104ebe:	01 d8                	add    %ebx,%eax
f0104ec0:	50                   	push   %eax
f0104ec1:	e8 c2 ff ff ff       	call   f0104e88 <strcpy>
	return dst;
}
f0104ec6:	89 d8                	mov    %ebx,%eax
f0104ec8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104ecb:	c9                   	leave  
f0104ecc:	c3                   	ret    

f0104ecd <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0104ecd:	55                   	push   %ebp
f0104ece:	89 e5                	mov    %esp,%ebp
f0104ed0:	56                   	push   %esi
f0104ed1:	53                   	push   %ebx
f0104ed2:	8b 45 08             	mov    0x8(%ebp),%eax
f0104ed5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104ed8:	89 c6                	mov    %eax,%esi
f0104eda:	03 75 10             	add    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0104edd:	89 c2                	mov    %eax,%edx
f0104edf:	39 f2                	cmp    %esi,%edx
f0104ee1:	74 11                	je     f0104ef4 <strncpy+0x27>
		*dst++ = *src;
f0104ee3:	83 c2 01             	add    $0x1,%edx
f0104ee6:	0f b6 19             	movzbl (%ecx),%ebx
f0104ee9:	88 5a ff             	mov    %bl,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0104eec:	80 fb 01             	cmp    $0x1,%bl
f0104eef:	83 d9 ff             	sbb    $0xffffffff,%ecx
f0104ef2:	eb eb                	jmp    f0104edf <strncpy+0x12>
	}
	return ret;
}
f0104ef4:	5b                   	pop    %ebx
f0104ef5:	5e                   	pop    %esi
f0104ef6:	5d                   	pop    %ebp
f0104ef7:	c3                   	ret    

f0104ef8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0104ef8:	55                   	push   %ebp
f0104ef9:	89 e5                	mov    %esp,%ebp
f0104efb:	56                   	push   %esi
f0104efc:	53                   	push   %ebx
f0104efd:	8b 75 08             	mov    0x8(%ebp),%esi
f0104f00:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104f03:	8b 55 10             	mov    0x10(%ebp),%edx
f0104f06:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0104f08:	85 d2                	test   %edx,%edx
f0104f0a:	74 21                	je     f0104f2d <strlcpy+0x35>
f0104f0c:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0104f10:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
f0104f12:	39 c2                	cmp    %eax,%edx
f0104f14:	74 14                	je     f0104f2a <strlcpy+0x32>
f0104f16:	0f b6 19             	movzbl (%ecx),%ebx
f0104f19:	84 db                	test   %bl,%bl
f0104f1b:	74 0b                	je     f0104f28 <strlcpy+0x30>
			*dst++ = *src++;
f0104f1d:	83 c1 01             	add    $0x1,%ecx
f0104f20:	83 c2 01             	add    $0x1,%edx
f0104f23:	88 5a ff             	mov    %bl,-0x1(%edx)
f0104f26:	eb ea                	jmp    f0104f12 <strlcpy+0x1a>
f0104f28:	89 d0                	mov    %edx,%eax
		*dst = '\0';
f0104f2a:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0104f2d:	29 f0                	sub    %esi,%eax
}
f0104f2f:	5b                   	pop    %ebx
f0104f30:	5e                   	pop    %esi
f0104f31:	5d                   	pop    %ebp
f0104f32:	c3                   	ret    

f0104f33 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0104f33:	55                   	push   %ebp
f0104f34:	89 e5                	mov    %esp,%ebp
f0104f36:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104f39:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0104f3c:	0f b6 01             	movzbl (%ecx),%eax
f0104f3f:	84 c0                	test   %al,%al
f0104f41:	74 0c                	je     f0104f4f <strcmp+0x1c>
f0104f43:	3a 02                	cmp    (%edx),%al
f0104f45:	75 08                	jne    f0104f4f <strcmp+0x1c>
		p++, q++;
f0104f47:	83 c1 01             	add    $0x1,%ecx
f0104f4a:	83 c2 01             	add    $0x1,%edx
f0104f4d:	eb ed                	jmp    f0104f3c <strcmp+0x9>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0104f4f:	0f b6 c0             	movzbl %al,%eax
f0104f52:	0f b6 12             	movzbl (%edx),%edx
f0104f55:	29 d0                	sub    %edx,%eax
}
f0104f57:	5d                   	pop    %ebp
f0104f58:	c3                   	ret    

f0104f59 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0104f59:	55                   	push   %ebp
f0104f5a:	89 e5                	mov    %esp,%ebp
f0104f5c:	53                   	push   %ebx
f0104f5d:	8b 45 08             	mov    0x8(%ebp),%eax
f0104f60:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104f63:	89 c3                	mov    %eax,%ebx
f0104f65:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0104f68:	eb 06                	jmp    f0104f70 <strncmp+0x17>
		n--, p++, q++;
f0104f6a:	83 c0 01             	add    $0x1,%eax
f0104f6d:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f0104f70:	39 d8                	cmp    %ebx,%eax
f0104f72:	74 16                	je     f0104f8a <strncmp+0x31>
f0104f74:	0f b6 08             	movzbl (%eax),%ecx
f0104f77:	84 c9                	test   %cl,%cl
f0104f79:	74 04                	je     f0104f7f <strncmp+0x26>
f0104f7b:	3a 0a                	cmp    (%edx),%cl
f0104f7d:	74 eb                	je     f0104f6a <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0104f7f:	0f b6 00             	movzbl (%eax),%eax
f0104f82:	0f b6 12             	movzbl (%edx),%edx
f0104f85:	29 d0                	sub    %edx,%eax
}
f0104f87:	5b                   	pop    %ebx
f0104f88:	5d                   	pop    %ebp
f0104f89:	c3                   	ret    
		return 0;
f0104f8a:	b8 00 00 00 00       	mov    $0x0,%eax
f0104f8f:	eb f6                	jmp    f0104f87 <strncmp+0x2e>

f0104f91 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0104f91:	55                   	push   %ebp
f0104f92:	89 e5                	mov    %esp,%ebp
f0104f94:	8b 45 08             	mov    0x8(%ebp),%eax
f0104f97:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0104f9b:	0f b6 10             	movzbl (%eax),%edx
f0104f9e:	84 d2                	test   %dl,%dl
f0104fa0:	74 09                	je     f0104fab <strchr+0x1a>
		if (*s == c)
f0104fa2:	38 ca                	cmp    %cl,%dl
f0104fa4:	74 0a                	je     f0104fb0 <strchr+0x1f>
	for (; *s; s++)
f0104fa6:	83 c0 01             	add    $0x1,%eax
f0104fa9:	eb f0                	jmp    f0104f9b <strchr+0xa>
			return (char *) s;
	return 0;
f0104fab:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104fb0:	5d                   	pop    %ebp
f0104fb1:	c3                   	ret    

f0104fb2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0104fb2:	55                   	push   %ebp
f0104fb3:	89 e5                	mov    %esp,%ebp
f0104fb5:	8b 45 08             	mov    0x8(%ebp),%eax
f0104fb8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0104fbc:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0104fbf:	38 ca                	cmp    %cl,%dl
f0104fc1:	74 09                	je     f0104fcc <strfind+0x1a>
f0104fc3:	84 d2                	test   %dl,%dl
f0104fc5:	74 05                	je     f0104fcc <strfind+0x1a>
	for (; *s; s++)
f0104fc7:	83 c0 01             	add    $0x1,%eax
f0104fca:	eb f0                	jmp    f0104fbc <strfind+0xa>
			break;
	return (char *) s;
}
f0104fcc:	5d                   	pop    %ebp
f0104fcd:	c3                   	ret    

f0104fce <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0104fce:	55                   	push   %ebp
f0104fcf:	89 e5                	mov    %esp,%ebp
f0104fd1:	57                   	push   %edi
f0104fd2:	56                   	push   %esi
f0104fd3:	53                   	push   %ebx
f0104fd4:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104fd7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0104fda:	85 c9                	test   %ecx,%ecx
f0104fdc:	74 31                	je     f010500f <memset+0x41>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0104fde:	89 f8                	mov    %edi,%eax
f0104fe0:	09 c8                	or     %ecx,%eax
f0104fe2:	a8 03                	test   $0x3,%al
f0104fe4:	75 23                	jne    f0105009 <memset+0x3b>
		c &= 0xFF;
f0104fe6:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0104fea:	89 d3                	mov    %edx,%ebx
f0104fec:	c1 e3 08             	shl    $0x8,%ebx
f0104fef:	89 d0                	mov    %edx,%eax
f0104ff1:	c1 e0 18             	shl    $0x18,%eax
f0104ff4:	89 d6                	mov    %edx,%esi
f0104ff6:	c1 e6 10             	shl    $0x10,%esi
f0104ff9:	09 f0                	or     %esi,%eax
f0104ffb:	09 c2                	or     %eax,%edx
f0104ffd:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0104fff:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f0105002:	89 d0                	mov    %edx,%eax
f0105004:	fc                   	cld    
f0105005:	f3 ab                	rep stos %eax,%es:(%edi)
f0105007:	eb 06                	jmp    f010500f <memset+0x41>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0105009:	8b 45 0c             	mov    0xc(%ebp),%eax
f010500c:	fc                   	cld    
f010500d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010500f:	89 f8                	mov    %edi,%eax
f0105011:	5b                   	pop    %ebx
f0105012:	5e                   	pop    %esi
f0105013:	5f                   	pop    %edi
f0105014:	5d                   	pop    %ebp
f0105015:	c3                   	ret    

f0105016 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0105016:	55                   	push   %ebp
f0105017:	89 e5                	mov    %esp,%ebp
f0105019:	57                   	push   %edi
f010501a:	56                   	push   %esi
f010501b:	8b 45 08             	mov    0x8(%ebp),%eax
f010501e:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105021:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0105024:	39 c6                	cmp    %eax,%esi
f0105026:	73 32                	jae    f010505a <memmove+0x44>
f0105028:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f010502b:	39 c2                	cmp    %eax,%edx
f010502d:	76 2b                	jbe    f010505a <memmove+0x44>
		s += n;
		d += n;
f010502f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105032:	89 fe                	mov    %edi,%esi
f0105034:	09 ce                	or     %ecx,%esi
f0105036:	09 d6                	or     %edx,%esi
f0105038:	f7 c6 03 00 00 00    	test   $0x3,%esi
f010503e:	75 0e                	jne    f010504e <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0105040:	83 ef 04             	sub    $0x4,%edi
f0105043:	8d 72 fc             	lea    -0x4(%edx),%esi
f0105046:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f0105049:	fd                   	std    
f010504a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010504c:	eb 09                	jmp    f0105057 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f010504e:	83 ef 01             	sub    $0x1,%edi
f0105051:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f0105054:	fd                   	std    
f0105055:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0105057:	fc                   	cld    
f0105058:	eb 1a                	jmp    f0105074 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010505a:	89 c2                	mov    %eax,%edx
f010505c:	09 ca                	or     %ecx,%edx
f010505e:	09 f2                	or     %esi,%edx
f0105060:	f6 c2 03             	test   $0x3,%dl
f0105063:	75 0a                	jne    f010506f <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0105065:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f0105068:	89 c7                	mov    %eax,%edi
f010506a:	fc                   	cld    
f010506b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010506d:	eb 05                	jmp    f0105074 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
f010506f:	89 c7                	mov    %eax,%edi
f0105071:	fc                   	cld    
f0105072:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0105074:	5e                   	pop    %esi
f0105075:	5f                   	pop    %edi
f0105076:	5d                   	pop    %ebp
f0105077:	c3                   	ret    

f0105078 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0105078:	55                   	push   %ebp
f0105079:	89 e5                	mov    %esp,%ebp
f010507b:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f010507e:	ff 75 10             	pushl  0x10(%ebp)
f0105081:	ff 75 0c             	pushl  0xc(%ebp)
f0105084:	ff 75 08             	pushl  0x8(%ebp)
f0105087:	e8 8a ff ff ff       	call   f0105016 <memmove>
}
f010508c:	c9                   	leave  
f010508d:	c3                   	ret    

f010508e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f010508e:	55                   	push   %ebp
f010508f:	89 e5                	mov    %esp,%ebp
f0105091:	56                   	push   %esi
f0105092:	53                   	push   %ebx
f0105093:	8b 45 08             	mov    0x8(%ebp),%eax
f0105096:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105099:	89 c6                	mov    %eax,%esi
f010509b:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010509e:	39 f0                	cmp    %esi,%eax
f01050a0:	74 1c                	je     f01050be <memcmp+0x30>
		if (*s1 != *s2)
f01050a2:	0f b6 08             	movzbl (%eax),%ecx
f01050a5:	0f b6 1a             	movzbl (%edx),%ebx
f01050a8:	38 d9                	cmp    %bl,%cl
f01050aa:	75 08                	jne    f01050b4 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f01050ac:	83 c0 01             	add    $0x1,%eax
f01050af:	83 c2 01             	add    $0x1,%edx
f01050b2:	eb ea                	jmp    f010509e <memcmp+0x10>
			return (int) *s1 - (int) *s2;
f01050b4:	0f b6 c1             	movzbl %cl,%eax
f01050b7:	0f b6 db             	movzbl %bl,%ebx
f01050ba:	29 d8                	sub    %ebx,%eax
f01050bc:	eb 05                	jmp    f01050c3 <memcmp+0x35>
	}

	return 0;
f01050be:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01050c3:	5b                   	pop    %ebx
f01050c4:	5e                   	pop    %esi
f01050c5:	5d                   	pop    %ebp
f01050c6:	c3                   	ret    

f01050c7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01050c7:	55                   	push   %ebp
f01050c8:	89 e5                	mov    %esp,%ebp
f01050ca:	8b 45 08             	mov    0x8(%ebp),%eax
f01050cd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f01050d0:	89 c2                	mov    %eax,%edx
f01050d2:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f01050d5:	39 d0                	cmp    %edx,%eax
f01050d7:	73 09                	jae    f01050e2 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
f01050d9:	38 08                	cmp    %cl,(%eax)
f01050db:	74 05                	je     f01050e2 <memfind+0x1b>
	for (; s < ends; s++)
f01050dd:	83 c0 01             	add    $0x1,%eax
f01050e0:	eb f3                	jmp    f01050d5 <memfind+0xe>
			break;
	return (void *) s;
}
f01050e2:	5d                   	pop    %ebp
f01050e3:	c3                   	ret    

f01050e4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01050e4:	55                   	push   %ebp
f01050e5:	89 e5                	mov    %esp,%ebp
f01050e7:	57                   	push   %edi
f01050e8:	56                   	push   %esi
f01050e9:	53                   	push   %ebx
f01050ea:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01050ed:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01050f0:	eb 03                	jmp    f01050f5 <strtol+0x11>
		s++;
f01050f2:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
f01050f5:	0f b6 01             	movzbl (%ecx),%eax
f01050f8:	3c 20                	cmp    $0x20,%al
f01050fa:	74 f6                	je     f01050f2 <strtol+0xe>
f01050fc:	3c 09                	cmp    $0x9,%al
f01050fe:	74 f2                	je     f01050f2 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f0105100:	3c 2b                	cmp    $0x2b,%al
f0105102:	74 2a                	je     f010512e <strtol+0x4a>
	int neg = 0;
f0105104:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f0105109:	3c 2d                	cmp    $0x2d,%al
f010510b:	74 2b                	je     f0105138 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010510d:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0105113:	75 0f                	jne    f0105124 <strtol+0x40>
f0105115:	80 39 30             	cmpb   $0x30,(%ecx)
f0105118:	74 28                	je     f0105142 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
f010511a:	85 db                	test   %ebx,%ebx
f010511c:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105121:	0f 44 d8             	cmove  %eax,%ebx
f0105124:	b8 00 00 00 00       	mov    $0x0,%eax
f0105129:	89 5d 10             	mov    %ebx,0x10(%ebp)
f010512c:	eb 50                	jmp    f010517e <strtol+0x9a>
		s++;
f010512e:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
f0105131:	bf 00 00 00 00       	mov    $0x0,%edi
f0105136:	eb d5                	jmp    f010510d <strtol+0x29>
		s++, neg = 1;
f0105138:	83 c1 01             	add    $0x1,%ecx
f010513b:	bf 01 00 00 00       	mov    $0x1,%edi
f0105140:	eb cb                	jmp    f010510d <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105142:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0105146:	74 0e                	je     f0105156 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
f0105148:	85 db                	test   %ebx,%ebx
f010514a:	75 d8                	jne    f0105124 <strtol+0x40>
		s++, base = 8;
f010514c:	83 c1 01             	add    $0x1,%ecx
f010514f:	bb 08 00 00 00       	mov    $0x8,%ebx
f0105154:	eb ce                	jmp    f0105124 <strtol+0x40>
		s += 2, base = 16;
f0105156:	83 c1 02             	add    $0x2,%ecx
f0105159:	bb 10 00 00 00       	mov    $0x10,%ebx
f010515e:	eb c4                	jmp    f0105124 <strtol+0x40>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
f0105160:	8d 72 9f             	lea    -0x61(%edx),%esi
f0105163:	89 f3                	mov    %esi,%ebx
f0105165:	80 fb 19             	cmp    $0x19,%bl
f0105168:	77 29                	ja     f0105193 <strtol+0xaf>
			dig = *s - 'a' + 10;
f010516a:	0f be d2             	movsbl %dl,%edx
f010516d:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0105170:	3b 55 10             	cmp    0x10(%ebp),%edx
f0105173:	7d 30                	jge    f01051a5 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
f0105175:	83 c1 01             	add    $0x1,%ecx
f0105178:	0f af 45 10          	imul   0x10(%ebp),%eax
f010517c:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f010517e:	0f b6 11             	movzbl (%ecx),%edx
f0105181:	8d 72 d0             	lea    -0x30(%edx),%esi
f0105184:	89 f3                	mov    %esi,%ebx
f0105186:	80 fb 09             	cmp    $0x9,%bl
f0105189:	77 d5                	ja     f0105160 <strtol+0x7c>
			dig = *s - '0';
f010518b:	0f be d2             	movsbl %dl,%edx
f010518e:	83 ea 30             	sub    $0x30,%edx
f0105191:	eb dd                	jmp    f0105170 <strtol+0x8c>
		else if (*s >= 'A' && *s <= 'Z')
f0105193:	8d 72 bf             	lea    -0x41(%edx),%esi
f0105196:	89 f3                	mov    %esi,%ebx
f0105198:	80 fb 19             	cmp    $0x19,%bl
f010519b:	77 08                	ja     f01051a5 <strtol+0xc1>
			dig = *s - 'A' + 10;
f010519d:	0f be d2             	movsbl %dl,%edx
f01051a0:	83 ea 37             	sub    $0x37,%edx
f01051a3:	eb cb                	jmp    f0105170 <strtol+0x8c>
		// we don't properly detect overflow!
	}

	if (endptr)
f01051a5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01051a9:	74 05                	je     f01051b0 <strtol+0xcc>
		*endptr = (char *) s;
f01051ab:	8b 75 0c             	mov    0xc(%ebp),%esi
f01051ae:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f01051b0:	89 c2                	mov    %eax,%edx
f01051b2:	f7 da                	neg    %edx
f01051b4:	85 ff                	test   %edi,%edi
f01051b6:	0f 45 c2             	cmovne %edx,%eax
}
f01051b9:	5b                   	pop    %ebx
f01051ba:	5e                   	pop    %esi
f01051bb:	5f                   	pop    %edi
f01051bc:	5d                   	pop    %ebp
f01051bd:	c3                   	ret    
f01051be:	66 90                	xchg   %ax,%ax

f01051c0 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f01051c0:	fa                   	cli    

	xorw    %ax, %ax
f01051c1:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f01051c3:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f01051c5:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f01051c7:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f01051c9:	0f 01 16             	lgdtl  (%esi)
f01051cc:	74 70                	je     f010523e <mpsearch1+0x3>
	movl    %cr0, %eax
f01051ce:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f01051d1:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f01051d5:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f01051d8:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f01051de:	08 00                	or     %al,(%eax)

f01051e0 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f01051e0:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f01051e4:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f01051e6:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f01051e8:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f01051ea:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f01051ee:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f01051f0:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f01051f2:	b8 00 00 12 00       	mov    $0x120000,%eax
	movl    %eax, %cr3
f01051f7:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f01051fa:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f01051fd:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0105202:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0105205:	8b 25 84 2e 23 f0    	mov    0xf0232e84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f010520b:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0105210:	b8 1f 02 10 f0       	mov    $0xf010021f,%eax
	call    *%eax
f0105215:	ff d0                	call   *%eax

f0105217 <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0105217:	eb fe                	jmp    f0105217 <spin>
f0105219:	8d 76 00             	lea    0x0(%esi),%esi

f010521c <gdt>:
	...
f0105224:	ff                   	(bad)  
f0105225:	ff 00                	incl   (%eax)
f0105227:	00 00                	add    %al,(%eax)
f0105229:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0105230:	00                   	.byte 0x0
f0105231:	92                   	xchg   %eax,%edx
f0105232:	cf                   	iret   
	...

f0105234 <gdtdesc>:
f0105234:	17                   	pop    %ss
f0105235:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f010523a <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f010523a:	90                   	nop

f010523b <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f010523b:	55                   	push   %ebp
f010523c:	89 e5                	mov    %esp,%ebp
f010523e:	57                   	push   %edi
f010523f:	56                   	push   %esi
f0105240:	53                   	push   %ebx
f0105241:	83 ec 0c             	sub    $0xc,%esp
	if (PGNUM(pa) >= npages)
f0105244:	8b 0d 88 2e 23 f0    	mov    0xf0232e88,%ecx
f010524a:	89 c3                	mov    %eax,%ebx
f010524c:	c1 eb 0c             	shr    $0xc,%ebx
f010524f:	39 cb                	cmp    %ecx,%ebx
f0105251:	73 1a                	jae    f010526d <mpsearch1+0x32>
	return (void *)(pa + KERNBASE);
f0105253:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0105259:	8d 3c 02             	lea    (%edx,%eax,1),%edi
	if (PGNUM(pa) >= npages)
f010525c:	89 f8                	mov    %edi,%eax
f010525e:	c1 e8 0c             	shr    $0xc,%eax
f0105261:	39 c8                	cmp    %ecx,%eax
f0105263:	73 1a                	jae    f010527f <mpsearch1+0x44>
	return (void *)(pa + KERNBASE);
f0105265:	81 ef 00 00 00 10    	sub    $0x10000000,%edi

	for (; mp < end; mp++)
f010526b:	eb 27                	jmp    f0105294 <mpsearch1+0x59>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010526d:	50                   	push   %eax
f010526e:	68 d4 5c 10 f0       	push   $0xf0105cd4
f0105273:	6a 57                	push   $0x57
f0105275:	68 a1 77 10 f0       	push   $0xf01077a1
f010527a:	e8 15 ae ff ff       	call   f0100094 <_panic>
f010527f:	57                   	push   %edi
f0105280:	68 d4 5c 10 f0       	push   $0xf0105cd4
f0105285:	6a 57                	push   $0x57
f0105287:	68 a1 77 10 f0       	push   $0xf01077a1
f010528c:	e8 03 ae ff ff       	call   f0100094 <_panic>
f0105291:	83 c3 10             	add    $0x10,%ebx
f0105294:	39 fb                	cmp    %edi,%ebx
f0105296:	73 30                	jae    f01052c8 <mpsearch1+0x8d>
f0105298:	89 de                	mov    %ebx,%esi
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f010529a:	83 ec 04             	sub    $0x4,%esp
f010529d:	6a 04                	push   $0x4
f010529f:	68 b1 77 10 f0       	push   $0xf01077b1
f01052a4:	53                   	push   %ebx
f01052a5:	e8 e4 fd ff ff       	call   f010508e <memcmp>
f01052aa:	83 c4 10             	add    $0x10,%esp
f01052ad:	85 c0                	test   %eax,%eax
f01052af:	75 e0                	jne    f0105291 <mpsearch1+0x56>
f01052b1:	89 da                	mov    %ebx,%edx
	for (i = 0; i < len; i++)
f01052b3:	83 c6 10             	add    $0x10,%esi
		sum += ((uint8_t *)addr)[i];
f01052b6:	0f b6 0a             	movzbl (%edx),%ecx
f01052b9:	01 c8                	add    %ecx,%eax
f01052bb:	83 c2 01             	add    $0x1,%edx
	for (i = 0; i < len; i++)
f01052be:	39 f2                	cmp    %esi,%edx
f01052c0:	75 f4                	jne    f01052b6 <mpsearch1+0x7b>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f01052c2:	84 c0                	test   %al,%al
f01052c4:	75 cb                	jne    f0105291 <mpsearch1+0x56>
f01052c6:	eb 05                	jmp    f01052cd <mpsearch1+0x92>
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f01052c8:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f01052cd:	89 d8                	mov    %ebx,%eax
f01052cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01052d2:	5b                   	pop    %ebx
f01052d3:	5e                   	pop    %esi
f01052d4:	5f                   	pop    %edi
f01052d5:	5d                   	pop    %ebp
f01052d6:	c3                   	ret    

f01052d7 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f01052d7:	55                   	push   %ebp
f01052d8:	89 e5                	mov    %esp,%ebp
f01052da:	57                   	push   %edi
f01052db:	56                   	push   %esi
f01052dc:	53                   	push   %ebx
f01052dd:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f01052e0:	c7 05 c0 33 23 f0 20 	movl   $0xf0233020,0xf02333c0
f01052e7:	30 23 f0 
	if (PGNUM(pa) >= npages)
f01052ea:	83 3d 88 2e 23 f0 00 	cmpl   $0x0,0xf0232e88
f01052f1:	0f 84 a3 00 00 00    	je     f010539a <mp_init+0xc3>
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f01052f7:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f01052fe:	85 c0                	test   %eax,%eax
f0105300:	0f 84 aa 00 00 00    	je     f01053b0 <mp_init+0xd9>
		p <<= 4;	// Translate from segment to PA
f0105306:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f0105309:	ba 00 04 00 00       	mov    $0x400,%edx
f010530e:	e8 28 ff ff ff       	call   f010523b <mpsearch1>
f0105313:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105316:	85 c0                	test   %eax,%eax
f0105318:	75 1a                	jne    f0105334 <mp_init+0x5d>
	return mpsearch1(0xF0000, 0x10000);
f010531a:	ba 00 00 01 00       	mov    $0x10000,%edx
f010531f:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0105324:	e8 12 ff ff ff       	call   f010523b <mpsearch1>
f0105329:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if ((mp = mpsearch()) == 0)
f010532c:	85 c0                	test   %eax,%eax
f010532e:	0f 84 31 02 00 00    	je     f0105565 <mp_init+0x28e>
	if (mp->physaddr == 0 || mp->type != 0) {
f0105334:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105337:	8b 58 04             	mov    0x4(%eax),%ebx
f010533a:	85 db                	test   %ebx,%ebx
f010533c:	0f 84 97 00 00 00    	je     f01053d9 <mp_init+0x102>
f0105342:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0105346:	0f 85 8d 00 00 00    	jne    f01053d9 <mp_init+0x102>
f010534c:	89 d8                	mov    %ebx,%eax
f010534e:	c1 e8 0c             	shr    $0xc,%eax
f0105351:	3b 05 88 2e 23 f0    	cmp    0xf0232e88,%eax
f0105357:	0f 83 91 00 00 00    	jae    f01053ee <mp_init+0x117>
	return (void *)(pa + KERNBASE);
f010535d:	81 eb 00 00 00 10    	sub    $0x10000000,%ebx
f0105363:	89 de                	mov    %ebx,%esi
	if (memcmp(conf, "PCMP", 4) != 0) {
f0105365:	83 ec 04             	sub    $0x4,%esp
f0105368:	6a 04                	push   $0x4
f010536a:	68 b6 77 10 f0       	push   $0xf01077b6
f010536f:	53                   	push   %ebx
f0105370:	e8 19 fd ff ff       	call   f010508e <memcmp>
f0105375:	83 c4 10             	add    $0x10,%esp
f0105378:	85 c0                	test   %eax,%eax
f010537a:	0f 85 83 00 00 00    	jne    f0105403 <mp_init+0x12c>
f0105380:	0f b7 7b 04          	movzwl 0x4(%ebx),%edi
f0105384:	01 df                	add    %ebx,%edi
	sum = 0;
f0105386:	89 c2                	mov    %eax,%edx
	for (i = 0; i < len; i++)
f0105388:	39 fb                	cmp    %edi,%ebx
f010538a:	0f 84 88 00 00 00    	je     f0105418 <mp_init+0x141>
		sum += ((uint8_t *)addr)[i];
f0105390:	0f b6 0b             	movzbl (%ebx),%ecx
f0105393:	01 ca                	add    %ecx,%edx
f0105395:	83 c3 01             	add    $0x1,%ebx
f0105398:	eb ee                	jmp    f0105388 <mp_init+0xb1>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010539a:	68 00 04 00 00       	push   $0x400
f010539f:	68 d4 5c 10 f0       	push   $0xf0105cd4
f01053a4:	6a 6f                	push   $0x6f
f01053a6:	68 a1 77 10 f0       	push   $0xf01077a1
f01053ab:	e8 e4 ac ff ff       	call   f0100094 <_panic>
		p = *(uint16_t *) (bda + 0x13) * 1024;
f01053b0:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f01053b7:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f01053ba:	2d 00 04 00 00       	sub    $0x400,%eax
f01053bf:	ba 00 04 00 00       	mov    $0x400,%edx
f01053c4:	e8 72 fe ff ff       	call   f010523b <mpsearch1>
f01053c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01053cc:	85 c0                	test   %eax,%eax
f01053ce:	0f 85 60 ff ff ff    	jne    f0105334 <mp_init+0x5d>
f01053d4:	e9 41 ff ff ff       	jmp    f010531a <mp_init+0x43>
		cprintf("SMP: Default configurations not implemented\n");
f01053d9:	83 ec 0c             	sub    $0xc,%esp
f01053dc:	68 14 76 10 f0       	push   $0xf0107614
f01053e1:	e8 58 e4 ff ff       	call   f010383e <cprintf>
f01053e6:	83 c4 10             	add    $0x10,%esp
f01053e9:	e9 77 01 00 00       	jmp    f0105565 <mp_init+0x28e>
f01053ee:	53                   	push   %ebx
f01053ef:	68 d4 5c 10 f0       	push   $0xf0105cd4
f01053f4:	68 90 00 00 00       	push   $0x90
f01053f9:	68 a1 77 10 f0       	push   $0xf01077a1
f01053fe:	e8 91 ac ff ff       	call   f0100094 <_panic>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0105403:	83 ec 0c             	sub    $0xc,%esp
f0105406:	68 44 76 10 f0       	push   $0xf0107644
f010540b:	e8 2e e4 ff ff       	call   f010383e <cprintf>
f0105410:	83 c4 10             	add    $0x10,%esp
f0105413:	e9 4d 01 00 00       	jmp    f0105565 <mp_init+0x28e>
	if (sum(conf, conf->length) != 0) {
f0105418:	84 d2                	test   %dl,%dl
f010541a:	75 16                	jne    f0105432 <mp_init+0x15b>
	if (conf->version != 1 && conf->version != 4) {
f010541c:	0f b6 56 06          	movzbl 0x6(%esi),%edx
f0105420:	80 fa 01             	cmp    $0x1,%dl
f0105423:	74 05                	je     f010542a <mp_init+0x153>
f0105425:	80 fa 04             	cmp    $0x4,%dl
f0105428:	75 1d                	jne    f0105447 <mp_init+0x170>
f010542a:	0f b7 4e 28          	movzwl 0x28(%esi),%ecx
f010542e:	01 d9                	add    %ebx,%ecx
f0105430:	eb 36                	jmp    f0105468 <mp_init+0x191>
		cprintf("SMP: Bad MP configuration checksum\n");
f0105432:	83 ec 0c             	sub    $0xc,%esp
f0105435:	68 78 76 10 f0       	push   $0xf0107678
f010543a:	e8 ff e3 ff ff       	call   f010383e <cprintf>
f010543f:	83 c4 10             	add    $0x10,%esp
f0105442:	e9 1e 01 00 00       	jmp    f0105565 <mp_init+0x28e>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0105447:	83 ec 08             	sub    $0x8,%esp
f010544a:	0f b6 d2             	movzbl %dl,%edx
f010544d:	52                   	push   %edx
f010544e:	68 9c 76 10 f0       	push   $0xf010769c
f0105453:	e8 e6 e3 ff ff       	call   f010383e <cprintf>
f0105458:	83 c4 10             	add    $0x10,%esp
f010545b:	e9 05 01 00 00       	jmp    f0105565 <mp_init+0x28e>
		sum += ((uint8_t *)addr)[i];
f0105460:	0f b6 13             	movzbl (%ebx),%edx
f0105463:	01 d0                	add    %edx,%eax
f0105465:	83 c3 01             	add    $0x1,%ebx
	for (i = 0; i < len; i++)
f0105468:	39 d9                	cmp    %ebx,%ecx
f010546a:	75 f4                	jne    f0105460 <mp_init+0x189>
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f010546c:	02 46 2a             	add    0x2a(%esi),%al
f010546f:	75 1c                	jne    f010548d <mp_init+0x1b6>
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
f0105471:	c7 05 00 30 23 f0 01 	movl   $0x1,0xf0233000
f0105478:	00 00 00 
	lapicaddr = conf->lapicaddr;
f010547b:	8b 46 24             	mov    0x24(%esi),%eax
f010547e:	a3 00 40 27 f0       	mov    %eax,0xf0274000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105483:	8d 7e 2c             	lea    0x2c(%esi),%edi
f0105486:	bb 00 00 00 00       	mov    $0x0,%ebx
f010548b:	eb 4d                	jmp    f01054da <mp_init+0x203>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f010548d:	83 ec 0c             	sub    $0xc,%esp
f0105490:	68 bc 76 10 f0       	push   $0xf01076bc
f0105495:	e8 a4 e3 ff ff       	call   f010383e <cprintf>
f010549a:	83 c4 10             	add    $0x10,%esp
f010549d:	e9 c3 00 00 00       	jmp    f0105565 <mp_init+0x28e>
		switch (*p) {
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f01054a2:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f01054a6:	74 11                	je     f01054b9 <mp_init+0x1e2>
				bootcpu = &cpus[ncpu];
f01054a8:	6b 05 c4 33 23 f0 74 	imul   $0x74,0xf02333c4,%eax
f01054af:	05 20 30 23 f0       	add    $0xf0233020,%eax
f01054b4:	a3 c0 33 23 f0       	mov    %eax,0xf02333c0
			if (ncpu < NCPU) {
f01054b9:	a1 c4 33 23 f0       	mov    0xf02333c4,%eax
f01054be:	83 f8 07             	cmp    $0x7,%eax
f01054c1:	7f 2f                	jg     f01054f2 <mp_init+0x21b>
				cpus[ncpu].cpu_id = ncpu;
f01054c3:	6b d0 74             	imul   $0x74,%eax,%edx
f01054c6:	88 82 20 30 23 f0    	mov    %al,-0xfdccfe0(%edx)
				ncpu++;
f01054cc:	83 c0 01             	add    $0x1,%eax
f01054cf:	a3 c4 33 23 f0       	mov    %eax,0xf02333c4
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f01054d4:	83 c7 14             	add    $0x14,%edi
	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f01054d7:	83 c3 01             	add    $0x1,%ebx
f01054da:	0f b7 46 22          	movzwl 0x22(%esi),%eax
f01054de:	39 d8                	cmp    %ebx,%eax
f01054e0:	76 4b                	jbe    f010552d <mp_init+0x256>
		switch (*p) {
f01054e2:	0f b6 07             	movzbl (%edi),%eax
f01054e5:	84 c0                	test   %al,%al
f01054e7:	74 b9                	je     f01054a2 <mp_init+0x1cb>
f01054e9:	3c 04                	cmp    $0x4,%al
f01054eb:	77 1c                	ja     f0105509 <mp_init+0x232>
			continue;
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f01054ed:	83 c7 08             	add    $0x8,%edi
			continue;
f01054f0:	eb e5                	jmp    f01054d7 <mp_init+0x200>
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f01054f2:	83 ec 08             	sub    $0x8,%esp
f01054f5:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f01054f9:	50                   	push   %eax
f01054fa:	68 ec 76 10 f0       	push   $0xf01076ec
f01054ff:	e8 3a e3 ff ff       	call   f010383e <cprintf>
f0105504:	83 c4 10             	add    $0x10,%esp
f0105507:	eb cb                	jmp    f01054d4 <mp_init+0x1fd>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0105509:	83 ec 08             	sub    $0x8,%esp
		switch (*p) {
f010550c:	0f b6 c0             	movzbl %al,%eax
			cprintf("mpinit: unknown config type %x\n", *p);
f010550f:	50                   	push   %eax
f0105510:	68 14 77 10 f0       	push   $0xf0107714
f0105515:	e8 24 e3 ff ff       	call   f010383e <cprintf>
			ismp = 0;
f010551a:	c7 05 00 30 23 f0 00 	movl   $0x0,0xf0233000
f0105521:	00 00 00 
			i = conf->entry;
f0105524:	0f b7 5e 22          	movzwl 0x22(%esi),%ebx
f0105528:	83 c4 10             	add    $0x10,%esp
f010552b:	eb aa                	jmp    f01054d7 <mp_init+0x200>
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f010552d:	a1 c0 33 23 f0       	mov    0xf02333c0,%eax
f0105532:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0105539:	83 3d 00 30 23 f0 00 	cmpl   $0x0,0xf0233000
f0105540:	74 2b                	je     f010556d <mp_init+0x296>
		ncpu = 1;
		lapicaddr = 0;
		cprintf("SMP: configuration not found, SMP disabled\n");
		return;
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0105542:	83 ec 04             	sub    $0x4,%esp
f0105545:	ff 35 c4 33 23 f0    	pushl  0xf02333c4
f010554b:	0f b6 00             	movzbl (%eax),%eax
f010554e:	50                   	push   %eax
f010554f:	68 bb 77 10 f0       	push   $0xf01077bb
f0105554:	e8 e5 e2 ff ff       	call   f010383e <cprintf>

	if (mp->imcrp) {
f0105559:	83 c4 10             	add    $0x10,%esp
f010555c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010555f:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0105563:	75 2e                	jne    f0105593 <mp_init+0x2bc>
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f0105565:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105568:	5b                   	pop    %ebx
f0105569:	5e                   	pop    %esi
f010556a:	5f                   	pop    %edi
f010556b:	5d                   	pop    %ebp
f010556c:	c3                   	ret    
		ncpu = 1;
f010556d:	c7 05 c4 33 23 f0 01 	movl   $0x1,0xf02333c4
f0105574:	00 00 00 
		lapicaddr = 0;
f0105577:	c7 05 00 40 27 f0 00 	movl   $0x0,0xf0274000
f010557e:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0105581:	83 ec 0c             	sub    $0xc,%esp
f0105584:	68 34 77 10 f0       	push   $0xf0107734
f0105589:	e8 b0 e2 ff ff       	call   f010383e <cprintf>
		return;
f010558e:	83 c4 10             	add    $0x10,%esp
f0105591:	eb d2                	jmp    f0105565 <mp_init+0x28e>
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0105593:	83 ec 0c             	sub    $0xc,%esp
f0105596:	68 60 77 10 f0       	push   $0xf0107760
f010559b:	e8 9e e2 ff ff       	call   f010383e <cprintf>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01055a0:	b8 70 00 00 00       	mov    $0x70,%eax
f01055a5:	ba 22 00 00 00       	mov    $0x22,%edx
f01055aa:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01055ab:	ba 23 00 00 00       	mov    $0x23,%edx
f01055b0:	ec                   	in     (%dx),%al
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f01055b1:	83 c8 01             	or     $0x1,%eax
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01055b4:	ee                   	out    %al,(%dx)
f01055b5:	83 c4 10             	add    $0x10,%esp
f01055b8:	eb ab                	jmp    f0105565 <mp_init+0x28e>

f01055ba <lapicw>:
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
	lapic[index] = value;
f01055ba:	8b 0d 04 40 27 f0    	mov    0xf0274004,%ecx
f01055c0:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f01055c3:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f01055c5:	a1 04 40 27 f0       	mov    0xf0274004,%eax
f01055ca:	8b 40 20             	mov    0x20(%eax),%eax
}
f01055cd:	c3                   	ret    

f01055ce <cpunum>:
}

int
cpunum(void)
{
	if (lapic)
f01055ce:	8b 15 04 40 27 f0    	mov    0xf0274004,%edx
		return lapic[ID] >> 24;
	return 0;
f01055d4:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lapic)
f01055d9:	85 d2                	test   %edx,%edx
f01055db:	74 06                	je     f01055e3 <cpunum+0x15>
		return lapic[ID] >> 24;
f01055dd:	8b 42 20             	mov    0x20(%edx),%eax
f01055e0:	c1 e8 18             	shr    $0x18,%eax
}
f01055e3:	c3                   	ret    

f01055e4 <lapic_init>:
	if (!lapicaddr)
f01055e4:	a1 00 40 27 f0       	mov    0xf0274000,%eax
f01055e9:	85 c0                	test   %eax,%eax
f01055eb:	75 01                	jne    f01055ee <lapic_init+0xa>
f01055ed:	c3                   	ret    
{
f01055ee:	55                   	push   %ebp
f01055ef:	89 e5                	mov    %esp,%ebp
f01055f1:	83 ec 10             	sub    $0x10,%esp
	lapic = mmio_map_region(lapicaddr, 4096);
f01055f4:	68 00 10 00 00       	push   $0x1000
f01055f9:	50                   	push   %eax
f01055fa:	e8 d7 bc ff ff       	call   f01012d6 <mmio_map_region>
f01055ff:	a3 04 40 27 f0       	mov    %eax,0xf0274004
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0105604:	ba 27 01 00 00       	mov    $0x127,%edx
f0105609:	b8 3c 00 00 00       	mov    $0x3c,%eax
f010560e:	e8 a7 ff ff ff       	call   f01055ba <lapicw>
	lapicw(TDCR, X1);
f0105613:	ba 0b 00 00 00       	mov    $0xb,%edx
f0105618:	b8 f8 00 00 00       	mov    $0xf8,%eax
f010561d:	e8 98 ff ff ff       	call   f01055ba <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0105622:	ba 20 00 02 00       	mov    $0x20020,%edx
f0105627:	b8 c8 00 00 00       	mov    $0xc8,%eax
f010562c:	e8 89 ff ff ff       	call   f01055ba <lapicw>
	lapicw(TICR, 10000000); 
f0105631:	ba 80 96 98 00       	mov    $0x989680,%edx
f0105636:	b8 e0 00 00 00       	mov    $0xe0,%eax
f010563b:	e8 7a ff ff ff       	call   f01055ba <lapicw>
	if (thiscpu != bootcpu)
f0105640:	e8 89 ff ff ff       	call   f01055ce <cpunum>
f0105645:	6b c0 74             	imul   $0x74,%eax,%eax
f0105648:	05 20 30 23 f0       	add    $0xf0233020,%eax
f010564d:	83 c4 10             	add    $0x10,%esp
f0105650:	39 05 c0 33 23 f0    	cmp    %eax,0xf02333c0
f0105656:	74 0f                	je     f0105667 <lapic_init+0x83>
		lapicw(LINT0, MASKED);
f0105658:	ba 00 00 01 00       	mov    $0x10000,%edx
f010565d:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0105662:	e8 53 ff ff ff       	call   f01055ba <lapicw>
	lapicw(LINT1, MASKED);
f0105667:	ba 00 00 01 00       	mov    $0x10000,%edx
f010566c:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0105671:	e8 44 ff ff ff       	call   f01055ba <lapicw>
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0105676:	a1 04 40 27 f0       	mov    0xf0274004,%eax
f010567b:	8b 40 30             	mov    0x30(%eax),%eax
f010567e:	c1 e8 10             	shr    $0x10,%eax
f0105681:	a8 fc                	test   $0xfc,%al
f0105683:	75 7c                	jne    f0105701 <lapic_init+0x11d>
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0105685:	ba 33 00 00 00       	mov    $0x33,%edx
f010568a:	b8 dc 00 00 00       	mov    $0xdc,%eax
f010568f:	e8 26 ff ff ff       	call   f01055ba <lapicw>
	lapicw(ESR, 0);
f0105694:	ba 00 00 00 00       	mov    $0x0,%edx
f0105699:	b8 a0 00 00 00       	mov    $0xa0,%eax
f010569e:	e8 17 ff ff ff       	call   f01055ba <lapicw>
	lapicw(ESR, 0);
f01056a3:	ba 00 00 00 00       	mov    $0x0,%edx
f01056a8:	b8 a0 00 00 00       	mov    $0xa0,%eax
f01056ad:	e8 08 ff ff ff       	call   f01055ba <lapicw>
	lapicw(EOI, 0);
f01056b2:	ba 00 00 00 00       	mov    $0x0,%edx
f01056b7:	b8 2c 00 00 00       	mov    $0x2c,%eax
f01056bc:	e8 f9 fe ff ff       	call   f01055ba <lapicw>
	lapicw(ICRHI, 0);
f01056c1:	ba 00 00 00 00       	mov    $0x0,%edx
f01056c6:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01056cb:	e8 ea fe ff ff       	call   f01055ba <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f01056d0:	ba 00 85 08 00       	mov    $0x88500,%edx
f01056d5:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01056da:	e8 db fe ff ff       	call   f01055ba <lapicw>
	while(lapic[ICRLO] & DELIVS)
f01056df:	8b 15 04 40 27 f0    	mov    0xf0274004,%edx
f01056e5:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f01056eb:	f6 c4 10             	test   $0x10,%ah
f01056ee:	75 f5                	jne    f01056e5 <lapic_init+0x101>
	lapicw(TPR, 0);
f01056f0:	ba 00 00 00 00       	mov    $0x0,%edx
f01056f5:	b8 20 00 00 00       	mov    $0x20,%eax
f01056fa:	e8 bb fe ff ff       	call   f01055ba <lapicw>
}
f01056ff:	c9                   	leave  
f0105700:	c3                   	ret    
		lapicw(PCINT, MASKED);
f0105701:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105706:	b8 d0 00 00 00       	mov    $0xd0,%eax
f010570b:	e8 aa fe ff ff       	call   f01055ba <lapicw>
f0105710:	e9 70 ff ff ff       	jmp    f0105685 <lapic_init+0xa1>

f0105715 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f0105715:	83 3d 04 40 27 f0 00 	cmpl   $0x0,0xf0274004
f010571c:	74 17                	je     f0105735 <lapic_eoi+0x20>
{
f010571e:	55                   	push   %ebp
f010571f:	89 e5                	mov    %esp,%ebp
f0105721:	83 ec 08             	sub    $0x8,%esp
		lapicw(EOI, 0);
f0105724:	ba 00 00 00 00       	mov    $0x0,%edx
f0105729:	b8 2c 00 00 00       	mov    $0x2c,%eax
f010572e:	e8 87 fe ff ff       	call   f01055ba <lapicw>
}
f0105733:	c9                   	leave  
f0105734:	c3                   	ret    
f0105735:	c3                   	ret    

f0105736 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0105736:	55                   	push   %ebp
f0105737:	89 e5                	mov    %esp,%ebp
f0105739:	56                   	push   %esi
f010573a:	53                   	push   %ebx
f010573b:	8b 75 08             	mov    0x8(%ebp),%esi
f010573e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105741:	b8 0f 00 00 00       	mov    $0xf,%eax
f0105746:	ba 70 00 00 00       	mov    $0x70,%edx
f010574b:	ee                   	out    %al,(%dx)
f010574c:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105751:	ba 71 00 00 00       	mov    $0x71,%edx
f0105756:	ee                   	out    %al,(%dx)
	if (PGNUM(pa) >= npages)
f0105757:	83 3d 88 2e 23 f0 00 	cmpl   $0x0,0xf0232e88
f010575e:	74 7e                	je     f01057de <lapic_startap+0xa8>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0105760:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0105767:	00 00 
	wrv[1] = addr >> 4;
f0105769:	89 d8                	mov    %ebx,%eax
f010576b:	c1 e8 04             	shr    $0x4,%eax
f010576e:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0105774:	c1 e6 18             	shl    $0x18,%esi
f0105777:	89 f2                	mov    %esi,%edx
f0105779:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010577e:	e8 37 fe ff ff       	call   f01055ba <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0105783:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0105788:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010578d:	e8 28 fe ff ff       	call   f01055ba <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0105792:	ba 00 85 00 00       	mov    $0x8500,%edx
f0105797:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010579c:	e8 19 fe ff ff       	call   f01055ba <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01057a1:	c1 eb 0c             	shr    $0xc,%ebx
f01057a4:	80 cf 06             	or     $0x6,%bh
		lapicw(ICRHI, apicid << 24);
f01057a7:	89 f2                	mov    %esi,%edx
f01057a9:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01057ae:	e8 07 fe ff ff       	call   f01055ba <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01057b3:	89 da                	mov    %ebx,%edx
f01057b5:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01057ba:	e8 fb fd ff ff       	call   f01055ba <lapicw>
		lapicw(ICRHI, apicid << 24);
f01057bf:	89 f2                	mov    %esi,%edx
f01057c1:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01057c6:	e8 ef fd ff ff       	call   f01055ba <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01057cb:	89 da                	mov    %ebx,%edx
f01057cd:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01057d2:	e8 e3 fd ff ff       	call   f01055ba <lapicw>
		microdelay(200);
	}
}
f01057d7:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01057da:	5b                   	pop    %ebx
f01057db:	5e                   	pop    %esi
f01057dc:	5d                   	pop    %ebp
f01057dd:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01057de:	68 67 04 00 00       	push   $0x467
f01057e3:	68 d4 5c 10 f0       	push   $0xf0105cd4
f01057e8:	68 98 00 00 00       	push   $0x98
f01057ed:	68 d8 77 10 f0       	push   $0xf01077d8
f01057f2:	e8 9d a8 ff ff       	call   f0100094 <_panic>

f01057f7 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f01057f7:	55                   	push   %ebp
f01057f8:	89 e5                	mov    %esp,%ebp
f01057fa:	83 ec 08             	sub    $0x8,%esp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f01057fd:	8b 55 08             	mov    0x8(%ebp),%edx
f0105800:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0105806:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010580b:	e8 aa fd ff ff       	call   f01055ba <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0105810:	8b 15 04 40 27 f0    	mov    0xf0274004,%edx
f0105816:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f010581c:	f6 c4 10             	test   $0x10,%ah
f010581f:	75 f5                	jne    f0105816 <lapic_ipi+0x1f>
		;
}
f0105821:	c9                   	leave  
f0105822:	c3                   	ret    

f0105823 <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0105823:	55                   	push   %ebp
f0105824:	89 e5                	mov    %esp,%ebp
f0105826:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0105829:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f010582f:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105832:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0105835:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f010583c:	5d                   	pop    %ebp
f010583d:	c3                   	ret    

f010583e <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f010583e:	55                   	push   %ebp
f010583f:	89 e5                	mov    %esp,%ebp
f0105841:	56                   	push   %esi
f0105842:	53                   	push   %ebx
f0105843:	8b 5d 08             	mov    0x8(%ebp),%ebx
	return lock->locked && lock->cpu == thiscpu;
f0105846:	83 3b 00             	cmpl   $0x0,(%ebx)
f0105849:	75 12                	jne    f010585d <spin_lock+0x1f>
	asm volatile("lock; xchgl %0, %1"
f010584b:	ba 01 00 00 00       	mov    $0x1,%edx
f0105850:	89 d0                	mov    %edx,%eax
f0105852:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0105855:	85 c0                	test   %eax,%eax
f0105857:	74 36                	je     f010588f <spin_lock+0x51>
		asm volatile ("pause");
f0105859:	f3 90                	pause  
f010585b:	eb f3                	jmp    f0105850 <spin_lock+0x12>
	return lock->locked && lock->cpu == thiscpu;
f010585d:	8b 73 08             	mov    0x8(%ebx),%esi
f0105860:	e8 69 fd ff ff       	call   f01055ce <cpunum>
f0105865:	6b c0 74             	imul   $0x74,%eax,%eax
f0105868:	05 20 30 23 f0       	add    $0xf0233020,%eax
	if (holding(lk))
f010586d:	39 c6                	cmp    %eax,%esi
f010586f:	75 da                	jne    f010584b <spin_lock+0xd>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0105871:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0105874:	e8 55 fd ff ff       	call   f01055ce <cpunum>
f0105879:	83 ec 0c             	sub    $0xc,%esp
f010587c:	53                   	push   %ebx
f010587d:	50                   	push   %eax
f010587e:	68 e8 77 10 f0       	push   $0xf01077e8
f0105883:	6a 41                	push   $0x41
f0105885:	68 4c 78 10 f0       	push   $0xf010784c
f010588a:	e8 05 a8 ff ff       	call   f0100094 <_panic>

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f010588f:	e8 3a fd ff ff       	call   f01055ce <cpunum>
f0105894:	6b c0 74             	imul   $0x74,%eax,%eax
f0105897:	05 20 30 23 f0       	add    $0xf0233020,%eax
f010589c:	89 43 08             	mov    %eax,0x8(%ebx)
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f010589f:	89 ea                	mov    %ebp,%edx
	for (i = 0; i < 10; i++){
f01058a1:	b8 00 00 00 00       	mov    $0x0,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f01058a6:	83 f8 09             	cmp    $0x9,%eax
f01058a9:	7f 16                	jg     f01058c1 <spin_lock+0x83>
f01058ab:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f01058b1:	76 0e                	jbe    f01058c1 <spin_lock+0x83>
		pcs[i] = ebp[1];          // saved %eip
f01058b3:	8b 4a 04             	mov    0x4(%edx),%ecx
f01058b6:	89 4c 83 0c          	mov    %ecx,0xc(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f01058ba:	8b 12                	mov    (%edx),%edx
	for (i = 0; i < 10; i++){
f01058bc:	83 c0 01             	add    $0x1,%eax
f01058bf:	eb e5                	jmp    f01058a6 <spin_lock+0x68>
	for (; i < 10; i++)
f01058c1:	83 f8 09             	cmp    $0x9,%eax
f01058c4:	7f 0d                	jg     f01058d3 <spin_lock+0x95>
		pcs[i] = 0;
f01058c6:	c7 44 83 0c 00 00 00 	movl   $0x0,0xc(%ebx,%eax,4)
f01058cd:	00 
	for (; i < 10; i++)
f01058ce:	83 c0 01             	add    $0x1,%eax
f01058d1:	eb ee                	jmp    f01058c1 <spin_lock+0x83>
	get_caller_pcs(lk->pcs);
#endif
}
f01058d3:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01058d6:	5b                   	pop    %ebx
f01058d7:	5e                   	pop    %esi
f01058d8:	5d                   	pop    %ebp
f01058d9:	c3                   	ret    

f01058da <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f01058da:	55                   	push   %ebp
f01058db:	89 e5                	mov    %esp,%ebp
f01058dd:	57                   	push   %edi
f01058de:	56                   	push   %esi
f01058df:	53                   	push   %ebx
f01058e0:	83 ec 4c             	sub    $0x4c,%esp
f01058e3:	8b 75 08             	mov    0x8(%ebp),%esi
	return lock->locked && lock->cpu == thiscpu;
f01058e6:	83 3e 00             	cmpl   $0x0,(%esi)
f01058e9:	75 35                	jne    f0105920 <spin_unlock+0x46>
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f01058eb:	83 ec 04             	sub    $0x4,%esp
f01058ee:	6a 28                	push   $0x28
f01058f0:	8d 46 0c             	lea    0xc(%esi),%eax
f01058f3:	50                   	push   %eax
f01058f4:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f01058f7:	53                   	push   %ebx
f01058f8:	e8 19 f7 ff ff       	call   f0105016 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f01058fd:	8b 46 08             	mov    0x8(%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0105900:	0f b6 38             	movzbl (%eax),%edi
f0105903:	8b 76 04             	mov    0x4(%esi),%esi
f0105906:	e8 c3 fc ff ff       	call   f01055ce <cpunum>
f010590b:	57                   	push   %edi
f010590c:	56                   	push   %esi
f010590d:	50                   	push   %eax
f010590e:	68 14 78 10 f0       	push   $0xf0107814
f0105913:	e8 26 df ff ff       	call   f010383e <cprintf>
f0105918:	83 c4 20             	add    $0x20,%esp
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f010591b:	8d 7d a8             	lea    -0x58(%ebp),%edi
f010591e:	eb 4e                	jmp    f010596e <spin_unlock+0x94>
	return lock->locked && lock->cpu == thiscpu;
f0105920:	8b 5e 08             	mov    0x8(%esi),%ebx
f0105923:	e8 a6 fc ff ff       	call   f01055ce <cpunum>
f0105928:	6b c0 74             	imul   $0x74,%eax,%eax
f010592b:	05 20 30 23 f0       	add    $0xf0233020,%eax
	if (!holding(lk)) {
f0105930:	39 c3                	cmp    %eax,%ebx
f0105932:	75 b7                	jne    f01058eb <spin_unlock+0x11>
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
	}

	lk->pcs[0] = 0;
f0105934:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f010593b:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
	asm volatile("lock; xchgl %0, %1"
f0105942:	b8 00 00 00 00       	mov    $0x0,%eax
f0105947:	f0 87 06             	lock xchg %eax,(%esi)
	// respect to any other instruction which references the same memory.
	// x86 CPUs will not reorder loads/stores across locked instructions
	// (vol 3, 8.2.2). Because xchg() is implemented using asm volatile,
	// gcc will not reorder C statements across the xchg.
	xchg(&lk->locked, 0);
}
f010594a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010594d:	5b                   	pop    %ebx
f010594e:	5e                   	pop    %esi
f010594f:	5f                   	pop    %edi
f0105950:	5d                   	pop    %ebp
f0105951:	c3                   	ret    
				cprintf("  %08x\n", pcs[i]);
f0105952:	83 ec 08             	sub    $0x8,%esp
f0105955:	ff 36                	pushl  (%esi)
f0105957:	68 73 78 10 f0       	push   $0xf0107873
f010595c:	e8 dd de ff ff       	call   f010383e <cprintf>
f0105961:	83 c4 10             	add    $0x10,%esp
f0105964:	83 c3 04             	add    $0x4,%ebx
		for (i = 0; i < 10 && pcs[i]; i++) {
f0105967:	8d 45 e8             	lea    -0x18(%ebp),%eax
f010596a:	39 c3                	cmp    %eax,%ebx
f010596c:	74 40                	je     f01059ae <spin_unlock+0xd4>
f010596e:	89 de                	mov    %ebx,%esi
f0105970:	8b 03                	mov    (%ebx),%eax
f0105972:	85 c0                	test   %eax,%eax
f0105974:	74 38                	je     f01059ae <spin_unlock+0xd4>
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0105976:	83 ec 08             	sub    $0x8,%esp
f0105979:	57                   	push   %edi
f010597a:	50                   	push   %eax
f010597b:	e8 0f ec ff ff       	call   f010458f <debuginfo_eip>
f0105980:	83 c4 10             	add    $0x10,%esp
f0105983:	85 c0                	test   %eax,%eax
f0105985:	78 cb                	js     f0105952 <spin_unlock+0x78>
					pcs[i] - info.eip_fn_addr);
f0105987:	8b 06                	mov    (%esi),%eax
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0105989:	83 ec 04             	sub    $0x4,%esp
f010598c:	89 c2                	mov    %eax,%edx
f010598e:	2b 55 b8             	sub    -0x48(%ebp),%edx
f0105991:	52                   	push   %edx
f0105992:	ff 75 b0             	pushl  -0x50(%ebp)
f0105995:	ff 75 b4             	pushl  -0x4c(%ebp)
f0105998:	ff 75 ac             	pushl  -0x54(%ebp)
f010599b:	ff 75 a8             	pushl  -0x58(%ebp)
f010599e:	50                   	push   %eax
f010599f:	68 5c 78 10 f0       	push   $0xf010785c
f01059a4:	e8 95 de ff ff       	call   f010383e <cprintf>
f01059a9:	83 c4 20             	add    $0x20,%esp
f01059ac:	eb b6                	jmp    f0105964 <spin_unlock+0x8a>
		panic("spin_unlock");
f01059ae:	83 ec 04             	sub    $0x4,%esp
f01059b1:	68 7b 78 10 f0       	push   $0xf010787b
f01059b6:	6a 67                	push   $0x67
f01059b8:	68 4c 78 10 f0       	push   $0xf010784c
f01059bd:	e8 d2 a6 ff ff       	call   f0100094 <_panic>
f01059c2:	66 90                	xchg   %ax,%ax
f01059c4:	66 90                	xchg   %ax,%ax
f01059c6:	66 90                	xchg   %ax,%ax
f01059c8:	66 90                	xchg   %ax,%ax
f01059ca:	66 90                	xchg   %ax,%ax
f01059cc:	66 90                	xchg   %ax,%ax
f01059ce:	66 90                	xchg   %ax,%ax

f01059d0 <__udivdi3>:
f01059d0:	f3 0f 1e fb          	endbr32 
f01059d4:	55                   	push   %ebp
f01059d5:	57                   	push   %edi
f01059d6:	56                   	push   %esi
f01059d7:	53                   	push   %ebx
f01059d8:	83 ec 1c             	sub    $0x1c,%esp
f01059db:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f01059df:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f01059e3:	8b 74 24 34          	mov    0x34(%esp),%esi
f01059e7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f01059eb:	85 d2                	test   %edx,%edx
f01059ed:	75 49                	jne    f0105a38 <__udivdi3+0x68>
f01059ef:	39 f3                	cmp    %esi,%ebx
f01059f1:	76 15                	jbe    f0105a08 <__udivdi3+0x38>
f01059f3:	31 ff                	xor    %edi,%edi
f01059f5:	89 e8                	mov    %ebp,%eax
f01059f7:	89 f2                	mov    %esi,%edx
f01059f9:	f7 f3                	div    %ebx
f01059fb:	89 fa                	mov    %edi,%edx
f01059fd:	83 c4 1c             	add    $0x1c,%esp
f0105a00:	5b                   	pop    %ebx
f0105a01:	5e                   	pop    %esi
f0105a02:	5f                   	pop    %edi
f0105a03:	5d                   	pop    %ebp
f0105a04:	c3                   	ret    
f0105a05:	8d 76 00             	lea    0x0(%esi),%esi
f0105a08:	89 d9                	mov    %ebx,%ecx
f0105a0a:	85 db                	test   %ebx,%ebx
f0105a0c:	75 0b                	jne    f0105a19 <__udivdi3+0x49>
f0105a0e:	b8 01 00 00 00       	mov    $0x1,%eax
f0105a13:	31 d2                	xor    %edx,%edx
f0105a15:	f7 f3                	div    %ebx
f0105a17:	89 c1                	mov    %eax,%ecx
f0105a19:	31 d2                	xor    %edx,%edx
f0105a1b:	89 f0                	mov    %esi,%eax
f0105a1d:	f7 f1                	div    %ecx
f0105a1f:	89 c6                	mov    %eax,%esi
f0105a21:	89 e8                	mov    %ebp,%eax
f0105a23:	89 f7                	mov    %esi,%edi
f0105a25:	f7 f1                	div    %ecx
f0105a27:	89 fa                	mov    %edi,%edx
f0105a29:	83 c4 1c             	add    $0x1c,%esp
f0105a2c:	5b                   	pop    %ebx
f0105a2d:	5e                   	pop    %esi
f0105a2e:	5f                   	pop    %edi
f0105a2f:	5d                   	pop    %ebp
f0105a30:	c3                   	ret    
f0105a31:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105a38:	39 f2                	cmp    %esi,%edx
f0105a3a:	77 1c                	ja     f0105a58 <__udivdi3+0x88>
f0105a3c:	0f bd fa             	bsr    %edx,%edi
f0105a3f:	83 f7 1f             	xor    $0x1f,%edi
f0105a42:	75 2c                	jne    f0105a70 <__udivdi3+0xa0>
f0105a44:	39 f2                	cmp    %esi,%edx
f0105a46:	72 06                	jb     f0105a4e <__udivdi3+0x7e>
f0105a48:	31 c0                	xor    %eax,%eax
f0105a4a:	39 eb                	cmp    %ebp,%ebx
f0105a4c:	77 ad                	ja     f01059fb <__udivdi3+0x2b>
f0105a4e:	b8 01 00 00 00       	mov    $0x1,%eax
f0105a53:	eb a6                	jmp    f01059fb <__udivdi3+0x2b>
f0105a55:	8d 76 00             	lea    0x0(%esi),%esi
f0105a58:	31 ff                	xor    %edi,%edi
f0105a5a:	31 c0                	xor    %eax,%eax
f0105a5c:	89 fa                	mov    %edi,%edx
f0105a5e:	83 c4 1c             	add    $0x1c,%esp
f0105a61:	5b                   	pop    %ebx
f0105a62:	5e                   	pop    %esi
f0105a63:	5f                   	pop    %edi
f0105a64:	5d                   	pop    %ebp
f0105a65:	c3                   	ret    
f0105a66:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105a6d:	8d 76 00             	lea    0x0(%esi),%esi
f0105a70:	89 f9                	mov    %edi,%ecx
f0105a72:	b8 20 00 00 00       	mov    $0x20,%eax
f0105a77:	29 f8                	sub    %edi,%eax
f0105a79:	d3 e2                	shl    %cl,%edx
f0105a7b:	89 54 24 08          	mov    %edx,0x8(%esp)
f0105a7f:	89 c1                	mov    %eax,%ecx
f0105a81:	89 da                	mov    %ebx,%edx
f0105a83:	d3 ea                	shr    %cl,%edx
f0105a85:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0105a89:	09 d1                	or     %edx,%ecx
f0105a8b:	89 f2                	mov    %esi,%edx
f0105a8d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0105a91:	89 f9                	mov    %edi,%ecx
f0105a93:	d3 e3                	shl    %cl,%ebx
f0105a95:	89 c1                	mov    %eax,%ecx
f0105a97:	d3 ea                	shr    %cl,%edx
f0105a99:	89 f9                	mov    %edi,%ecx
f0105a9b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0105a9f:	89 eb                	mov    %ebp,%ebx
f0105aa1:	d3 e6                	shl    %cl,%esi
f0105aa3:	89 c1                	mov    %eax,%ecx
f0105aa5:	d3 eb                	shr    %cl,%ebx
f0105aa7:	09 de                	or     %ebx,%esi
f0105aa9:	89 f0                	mov    %esi,%eax
f0105aab:	f7 74 24 08          	divl   0x8(%esp)
f0105aaf:	89 d6                	mov    %edx,%esi
f0105ab1:	89 c3                	mov    %eax,%ebx
f0105ab3:	f7 64 24 0c          	mull   0xc(%esp)
f0105ab7:	39 d6                	cmp    %edx,%esi
f0105ab9:	72 15                	jb     f0105ad0 <__udivdi3+0x100>
f0105abb:	89 f9                	mov    %edi,%ecx
f0105abd:	d3 e5                	shl    %cl,%ebp
f0105abf:	39 c5                	cmp    %eax,%ebp
f0105ac1:	73 04                	jae    f0105ac7 <__udivdi3+0xf7>
f0105ac3:	39 d6                	cmp    %edx,%esi
f0105ac5:	74 09                	je     f0105ad0 <__udivdi3+0x100>
f0105ac7:	89 d8                	mov    %ebx,%eax
f0105ac9:	31 ff                	xor    %edi,%edi
f0105acb:	e9 2b ff ff ff       	jmp    f01059fb <__udivdi3+0x2b>
f0105ad0:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0105ad3:	31 ff                	xor    %edi,%edi
f0105ad5:	e9 21 ff ff ff       	jmp    f01059fb <__udivdi3+0x2b>
f0105ada:	66 90                	xchg   %ax,%ax
f0105adc:	66 90                	xchg   %ax,%ax
f0105ade:	66 90                	xchg   %ax,%ax

f0105ae0 <__umoddi3>:
f0105ae0:	f3 0f 1e fb          	endbr32 
f0105ae4:	55                   	push   %ebp
f0105ae5:	57                   	push   %edi
f0105ae6:	56                   	push   %esi
f0105ae7:	53                   	push   %ebx
f0105ae8:	83 ec 1c             	sub    $0x1c,%esp
f0105aeb:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f0105aef:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f0105af3:	8b 74 24 30          	mov    0x30(%esp),%esi
f0105af7:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0105afb:	89 da                	mov    %ebx,%edx
f0105afd:	85 c0                	test   %eax,%eax
f0105aff:	75 3f                	jne    f0105b40 <__umoddi3+0x60>
f0105b01:	39 df                	cmp    %ebx,%edi
f0105b03:	76 13                	jbe    f0105b18 <__umoddi3+0x38>
f0105b05:	89 f0                	mov    %esi,%eax
f0105b07:	f7 f7                	div    %edi
f0105b09:	89 d0                	mov    %edx,%eax
f0105b0b:	31 d2                	xor    %edx,%edx
f0105b0d:	83 c4 1c             	add    $0x1c,%esp
f0105b10:	5b                   	pop    %ebx
f0105b11:	5e                   	pop    %esi
f0105b12:	5f                   	pop    %edi
f0105b13:	5d                   	pop    %ebp
f0105b14:	c3                   	ret    
f0105b15:	8d 76 00             	lea    0x0(%esi),%esi
f0105b18:	89 fd                	mov    %edi,%ebp
f0105b1a:	85 ff                	test   %edi,%edi
f0105b1c:	75 0b                	jne    f0105b29 <__umoddi3+0x49>
f0105b1e:	b8 01 00 00 00       	mov    $0x1,%eax
f0105b23:	31 d2                	xor    %edx,%edx
f0105b25:	f7 f7                	div    %edi
f0105b27:	89 c5                	mov    %eax,%ebp
f0105b29:	89 d8                	mov    %ebx,%eax
f0105b2b:	31 d2                	xor    %edx,%edx
f0105b2d:	f7 f5                	div    %ebp
f0105b2f:	89 f0                	mov    %esi,%eax
f0105b31:	f7 f5                	div    %ebp
f0105b33:	89 d0                	mov    %edx,%eax
f0105b35:	eb d4                	jmp    f0105b0b <__umoddi3+0x2b>
f0105b37:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105b3e:	66 90                	xchg   %ax,%ax
f0105b40:	89 f1                	mov    %esi,%ecx
f0105b42:	39 d8                	cmp    %ebx,%eax
f0105b44:	76 0a                	jbe    f0105b50 <__umoddi3+0x70>
f0105b46:	89 f0                	mov    %esi,%eax
f0105b48:	83 c4 1c             	add    $0x1c,%esp
f0105b4b:	5b                   	pop    %ebx
f0105b4c:	5e                   	pop    %esi
f0105b4d:	5f                   	pop    %edi
f0105b4e:	5d                   	pop    %ebp
f0105b4f:	c3                   	ret    
f0105b50:	0f bd e8             	bsr    %eax,%ebp
f0105b53:	83 f5 1f             	xor    $0x1f,%ebp
f0105b56:	75 20                	jne    f0105b78 <__umoddi3+0x98>
f0105b58:	39 d8                	cmp    %ebx,%eax
f0105b5a:	0f 82 b0 00 00 00    	jb     f0105c10 <__umoddi3+0x130>
f0105b60:	39 f7                	cmp    %esi,%edi
f0105b62:	0f 86 a8 00 00 00    	jbe    f0105c10 <__umoddi3+0x130>
f0105b68:	89 c8                	mov    %ecx,%eax
f0105b6a:	83 c4 1c             	add    $0x1c,%esp
f0105b6d:	5b                   	pop    %ebx
f0105b6e:	5e                   	pop    %esi
f0105b6f:	5f                   	pop    %edi
f0105b70:	5d                   	pop    %ebp
f0105b71:	c3                   	ret    
f0105b72:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0105b78:	89 e9                	mov    %ebp,%ecx
f0105b7a:	ba 20 00 00 00       	mov    $0x20,%edx
f0105b7f:	29 ea                	sub    %ebp,%edx
f0105b81:	d3 e0                	shl    %cl,%eax
f0105b83:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105b87:	89 d1                	mov    %edx,%ecx
f0105b89:	89 f8                	mov    %edi,%eax
f0105b8b:	d3 e8                	shr    %cl,%eax
f0105b8d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0105b91:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105b95:	8b 54 24 04          	mov    0x4(%esp),%edx
f0105b99:	09 c1                	or     %eax,%ecx
f0105b9b:	89 d8                	mov    %ebx,%eax
f0105b9d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0105ba1:	89 e9                	mov    %ebp,%ecx
f0105ba3:	d3 e7                	shl    %cl,%edi
f0105ba5:	89 d1                	mov    %edx,%ecx
f0105ba7:	d3 e8                	shr    %cl,%eax
f0105ba9:	89 e9                	mov    %ebp,%ecx
f0105bab:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0105baf:	d3 e3                	shl    %cl,%ebx
f0105bb1:	89 c7                	mov    %eax,%edi
f0105bb3:	89 d1                	mov    %edx,%ecx
f0105bb5:	89 f0                	mov    %esi,%eax
f0105bb7:	d3 e8                	shr    %cl,%eax
f0105bb9:	89 e9                	mov    %ebp,%ecx
f0105bbb:	89 fa                	mov    %edi,%edx
f0105bbd:	d3 e6                	shl    %cl,%esi
f0105bbf:	09 d8                	or     %ebx,%eax
f0105bc1:	f7 74 24 08          	divl   0x8(%esp)
f0105bc5:	89 d1                	mov    %edx,%ecx
f0105bc7:	89 f3                	mov    %esi,%ebx
f0105bc9:	f7 64 24 0c          	mull   0xc(%esp)
f0105bcd:	89 c6                	mov    %eax,%esi
f0105bcf:	89 d7                	mov    %edx,%edi
f0105bd1:	39 d1                	cmp    %edx,%ecx
f0105bd3:	72 06                	jb     f0105bdb <__umoddi3+0xfb>
f0105bd5:	75 10                	jne    f0105be7 <__umoddi3+0x107>
f0105bd7:	39 c3                	cmp    %eax,%ebx
f0105bd9:	73 0c                	jae    f0105be7 <__umoddi3+0x107>
f0105bdb:	2b 44 24 0c          	sub    0xc(%esp),%eax
f0105bdf:	1b 54 24 08          	sbb    0x8(%esp),%edx
f0105be3:	89 d7                	mov    %edx,%edi
f0105be5:	89 c6                	mov    %eax,%esi
f0105be7:	89 ca                	mov    %ecx,%edx
f0105be9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0105bee:	29 f3                	sub    %esi,%ebx
f0105bf0:	19 fa                	sbb    %edi,%edx
f0105bf2:	89 d0                	mov    %edx,%eax
f0105bf4:	d3 e0                	shl    %cl,%eax
f0105bf6:	89 e9                	mov    %ebp,%ecx
f0105bf8:	d3 eb                	shr    %cl,%ebx
f0105bfa:	d3 ea                	shr    %cl,%edx
f0105bfc:	09 d8                	or     %ebx,%eax
f0105bfe:	83 c4 1c             	add    $0x1c,%esp
f0105c01:	5b                   	pop    %ebx
f0105c02:	5e                   	pop    %esi
f0105c03:	5f                   	pop    %edi
f0105c04:	5d                   	pop    %ebp
f0105c05:	c3                   	ret    
f0105c06:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105c0d:	8d 76 00             	lea    0x0(%esi),%esi
f0105c10:	89 da                	mov    %ebx,%edx
f0105c12:	29 fe                	sub    %edi,%esi
f0105c14:	19 c2                	sbb    %eax,%edx
f0105c16:	89 f1                	mov    %esi,%ecx
f0105c18:	89 c8                	mov    %ecx,%eax
f0105c1a:	e9 4b ff ff ff       	jmp    f0105b6a <__umoddi3+0x8a>
