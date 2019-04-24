
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
f010004b:	68 a0 5f 10 f0       	push   $0xf0105fa0
f0100050:	e8 cb 37 00 00       	call   f0103820 <cprintf>
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
f010006f:	68 bc 5f 10 f0       	push   $0xf0105fbc
f0100074:	e8 a7 37 00 00       	call   f0103820 <cprintf>
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
f010008a:	e8 35 08 00 00       	call   f01008c4 <mon_backtrace>
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
f010009c:	83 3d 80 5e 23 f0 00 	cmpl   $0x0,0xf0235e80
f01000a3:	74 0f                	je     f01000b4 <_panic+0x20>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000a5:	83 ec 0c             	sub    $0xc,%esp
f01000a8:	6a 00                	push   $0x0
f01000aa:	e8 9c 08 00 00       	call   f010094b <monitor>
f01000af:	83 c4 10             	add    $0x10,%esp
f01000b2:	eb f1                	jmp    f01000a5 <_panic+0x11>
	panicstr = fmt;
f01000b4:	89 35 80 5e 23 f0    	mov    %esi,0xf0235e80
	asm volatile("cli; cld");
f01000ba:	fa                   	cli    
f01000bb:	fc                   	cld    
	va_start(ap, fmt);
f01000bc:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f01000bf:	e8 96 58 00 00       	call   f010595a <cpunum>
f01000c4:	ff 75 0c             	pushl  0xc(%ebp)
f01000c7:	ff 75 08             	pushl  0x8(%ebp)
f01000ca:	50                   	push   %eax
f01000cb:	68 30 60 10 f0       	push   $0xf0106030
f01000d0:	e8 4b 37 00 00       	call   f0103820 <cprintf>
	vcprintf(fmt, ap);
f01000d5:	83 c4 08             	add    $0x8,%esp
f01000d8:	53                   	push   %ebx
f01000d9:	56                   	push   %esi
f01000da:	e8 1b 37 00 00       	call   f01037fa <vcprintf>
	cprintf("\n");
f01000df:	c7 04 24 8a 68 10 f0 	movl   $0xf010688a,(%esp)
f01000e6:	e8 35 37 00 00       	call   f0103820 <cprintf>
f01000eb:	83 c4 10             	add    $0x10,%esp
f01000ee:	eb b5                	jmp    f01000a5 <_panic+0x11>

f01000f0 <i386_init>:
{
f01000f0:	55                   	push   %ebp
f01000f1:	89 e5                	mov    %esp,%ebp
f01000f3:	53                   	push   %ebx
f01000f4:	83 ec 04             	sub    $0x4,%esp
	cons_init();
f01000f7:	e8 87 05 00 00       	call   f0100683 <cons_init>
	cprintf("6828 decimal is %o octal!\n", 6828);
f01000fc:	83 ec 08             	sub    $0x8,%esp
f01000ff:	68 ac 1a 00 00       	push   $0x1aac
f0100104:	68 d7 5f 10 f0       	push   $0xf0105fd7
f0100109:	e8 12 37 00 00       	call   f0103820 <cprintf>
	test_backtrace(5);
f010010e:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f0100115:	e8 26 ff ff ff       	call   f0100040 <test_backtrace>
	mem_init();
f010011a:	e8 ff 11 00 00       	call   f010131e <mem_init>
	env_init();
f010011f:	e8 1e 2f 00 00       	call   f0103042 <env_init>
	trap_init();
f0100124:	e8 d5 37 00 00       	call   f01038fe <trap_init>
	mp_init();
f0100129:	e8 35 55 00 00       	call   f0105663 <mp_init>
	lapic_init();
f010012e:	e8 3d 58 00 00       	call   f0105970 <lapic_init>
	pic_init();
f0100133:	e8 09 36 00 00       	call   f0103741 <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0100138:	c7 04 24 c0 23 12 f0 	movl   $0xf01223c0,(%esp)
f010013f:	e8 86 5a 00 00       	call   f0105bca <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100144:	83 c4 10             	add    $0x10,%esp
f0100147:	83 3d 88 5e 23 f0 07 	cmpl   $0x7,0xf0235e88
f010014e:	76 27                	jbe    f0100177 <i386_init+0x87>
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f0100150:	83 ec 04             	sub    $0x4,%esp
f0100153:	b8 c6 55 10 f0       	mov    $0xf01055c6,%eax
f0100158:	2d 4c 55 10 f0       	sub    $0xf010554c,%eax
f010015d:	50                   	push   %eax
f010015e:	68 4c 55 10 f0       	push   $0xf010554c
f0100163:	68 00 70 00 f0       	push   $0xf0007000
f0100168:	e8 36 52 00 00       	call   f01053a3 <memmove>
f010016d:	83 c4 10             	add    $0x10,%esp
	for (c = cpus; c < cpus + ncpu; c++) {
f0100170:	bb 20 60 23 f0       	mov    $0xf0236020,%ebx
f0100175:	eb 19                	jmp    f0100190 <i386_init+0xa0>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100177:	68 00 70 00 00       	push   $0x7000
f010017c:	68 54 60 10 f0       	push   $0xf0106054
f0100181:	6a 5e                	push   $0x5e
f0100183:	68 f2 5f 10 f0       	push   $0xf0105ff2
f0100188:	e8 07 ff ff ff       	call   f0100094 <_panic>
f010018d:	83 c3 74             	add    $0x74,%ebx
f0100190:	6b 05 c4 63 23 f0 74 	imul   $0x74,0xf02363c4,%eax
f0100197:	05 20 60 23 f0       	add    $0xf0236020,%eax
f010019c:	39 c3                	cmp    %eax,%ebx
f010019e:	73 4d                	jae    f01001ed <i386_init+0xfd>
		if (c == cpus + cpunum())  // We've started already.
f01001a0:	e8 b5 57 00 00       	call   f010595a <cpunum>
f01001a5:	6b c0 74             	imul   $0x74,%eax,%eax
f01001a8:	05 20 60 23 f0       	add    $0xf0236020,%eax
f01001ad:	39 c3                	cmp    %eax,%ebx
f01001af:	74 dc                	je     f010018d <i386_init+0x9d>
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f01001b1:	89 d8                	mov    %ebx,%eax
f01001b3:	2d 20 60 23 f0       	sub    $0xf0236020,%eax
f01001b8:	c1 f8 02             	sar    $0x2,%eax
f01001bb:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f01001c1:	c1 e0 0f             	shl    $0xf,%eax
f01001c4:	8d 80 00 f0 23 f0    	lea    -0xfdc1000(%eax),%eax
f01001ca:	a3 84 5e 23 f0       	mov    %eax,0xf0235e84
		lapic_startap(c->cpu_id, PADDR(code));
f01001cf:	83 ec 08             	sub    $0x8,%esp
f01001d2:	68 00 70 00 00       	push   $0x7000
f01001d7:	0f b6 03             	movzbl (%ebx),%eax
f01001da:	50                   	push   %eax
f01001db:	e8 e2 58 00 00       	call   f0105ac2 <lapic_startap>
f01001e0:	83 c4 10             	add    $0x10,%esp
		while(c->cpu_status != CPU_STARTED)
f01001e3:	8b 43 04             	mov    0x4(%ebx),%eax
f01001e6:	83 f8 01             	cmp    $0x1,%eax
f01001e9:	75 f8                	jne    f01001e3 <i386_init+0xf3>
f01001eb:	eb a0                	jmp    f010018d <i386_init+0x9d>
	ENV_CREATE(TEST, ENV_TYPE_USER);
f01001ed:	83 ec 08             	sub    $0x8,%esp
f01001f0:	6a 00                	push   $0x0
f01001f2:	68 80 27 1f f0       	push   $0xf01f2780
f01001f7:	e8 39 30 00 00       	call   f0103235 <env_create>
	sched_yield();
f01001fc:	e8 26 41 00 00       	call   f0104327 <sched_yield>

f0100201 <mp_main>:
{
f0100201:	55                   	push   %ebp
f0100202:	89 e5                	mov    %esp,%ebp
f0100204:	83 ec 08             	sub    $0x8,%esp
	lcr3(PADDR(kern_pgdir));
f0100207:	a1 8c 5e 23 f0       	mov    0xf0235e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f010020c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100211:	76 52                	jbe    f0100265 <mp_main+0x64>
	return (physaddr_t)kva - KERNBASE;
f0100213:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0100218:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f010021b:	e8 3a 57 00 00       	call   f010595a <cpunum>
f0100220:	83 ec 08             	sub    $0x8,%esp
f0100223:	50                   	push   %eax
f0100224:	68 fe 5f 10 f0       	push   $0xf0105ffe
f0100229:	e8 f2 35 00 00       	call   f0103820 <cprintf>
	lapic_init();
f010022e:	e8 3d 57 00 00       	call   f0105970 <lapic_init>
	env_init_percpu();
f0100233:	e8 de 2d 00 00       	call   f0103016 <env_init_percpu>
	trap_init_percpu();
f0100238:	e8 f7 35 00 00       	call   f0103834 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f010023d:	e8 18 57 00 00       	call   f010595a <cpunum>
f0100242:	6b d0 74             	imul   $0x74,%eax,%edx
f0100245:	83 c2 04             	add    $0x4,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0100248:	b8 01 00 00 00       	mov    $0x1,%eax
f010024d:	f0 87 82 20 60 23 f0 	lock xchg %eax,-0xfdc9fe0(%edx)
f0100254:	c7 04 24 c0 23 12 f0 	movl   $0xf01223c0,(%esp)
f010025b:	e8 6a 59 00 00       	call   f0105bca <spin_lock>
	sched_yield();
f0100260:	e8 c2 40 00 00       	call   f0104327 <sched_yield>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100265:	50                   	push   %eax
f0100266:	68 78 60 10 f0       	push   $0xf0106078
f010026b:	6a 75                	push   $0x75
f010026d:	68 f2 5f 10 f0       	push   $0xf0105ff2
f0100272:	e8 1d fe ff ff       	call   f0100094 <_panic>

f0100277 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100277:	55                   	push   %ebp
f0100278:	89 e5                	mov    %esp,%ebp
f010027a:	53                   	push   %ebx
f010027b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f010027e:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100281:	ff 75 0c             	pushl  0xc(%ebp)
f0100284:	ff 75 08             	pushl  0x8(%ebp)
f0100287:	68 14 60 10 f0       	push   $0xf0106014
f010028c:	e8 8f 35 00 00       	call   f0103820 <cprintf>
	vcprintf(fmt, ap);
f0100291:	83 c4 08             	add    $0x8,%esp
f0100294:	53                   	push   %ebx
f0100295:	ff 75 10             	pushl  0x10(%ebp)
f0100298:	e8 5d 35 00 00       	call   f01037fa <vcprintf>
	cprintf("\n");
f010029d:	c7 04 24 8a 68 10 f0 	movl   $0xf010688a,(%esp)
f01002a4:	e8 77 35 00 00       	call   f0103820 <cprintf>
	va_end(ap);
}
f01002a9:	83 c4 10             	add    $0x10,%esp
f01002ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01002af:	c9                   	leave  
f01002b0:	c3                   	ret    

f01002b1 <serial_proc_data>:
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002b1:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01002b6:	ec                   	in     (%dx),%al
static bool serial_exists;

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01002b7:	a8 01                	test   $0x1,%al
f01002b9:	74 0a                	je     f01002c5 <serial_proc_data+0x14>
f01002bb:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01002c0:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01002c1:	0f b6 c0             	movzbl %al,%eax
f01002c4:	c3                   	ret    
		return -1;
f01002c5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f01002ca:	c3                   	ret    

f01002cb <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01002cb:	55                   	push   %ebp
f01002cc:	89 e5                	mov    %esp,%ebp
f01002ce:	53                   	push   %ebx
f01002cf:	83 ec 04             	sub    $0x4,%esp
f01002d2:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f01002d4:	ff d3                	call   *%ebx
f01002d6:	83 f8 ff             	cmp    $0xffffffff,%eax
f01002d9:	74 29                	je     f0100304 <cons_intr+0x39>
		if (c == 0)
f01002db:	85 c0                	test   %eax,%eax
f01002dd:	74 f5                	je     f01002d4 <cons_intr+0x9>
			continue;
		cons.buf[cons.wpos++] = c;
f01002df:	8b 0d 24 52 23 f0    	mov    0xf0235224,%ecx
f01002e5:	8d 51 01             	lea    0x1(%ecx),%edx
f01002e8:	88 81 20 50 23 f0    	mov    %al,-0xfdcafe0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f01002ee:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.wpos = 0;
f01002f4:	b8 00 00 00 00       	mov    $0x0,%eax
f01002f9:	0f 44 d0             	cmove  %eax,%edx
f01002fc:	89 15 24 52 23 f0    	mov    %edx,0xf0235224
f0100302:	eb d0                	jmp    f01002d4 <cons_intr+0x9>
	}
}
f0100304:	83 c4 04             	add    $0x4,%esp
f0100307:	5b                   	pop    %ebx
f0100308:	5d                   	pop    %ebp
f0100309:	c3                   	ret    

f010030a <kbd_proc_data>:
{
f010030a:	55                   	push   %ebp
f010030b:	89 e5                	mov    %esp,%ebp
f010030d:	53                   	push   %ebx
f010030e:	83 ec 04             	sub    $0x4,%esp
f0100311:	ba 64 00 00 00       	mov    $0x64,%edx
f0100316:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f0100317:	a8 01                	test   $0x1,%al
f0100319:	0f 84 f2 00 00 00    	je     f0100411 <kbd_proc_data+0x107>
	if (stat & KBS_TERR)
f010031f:	a8 20                	test   $0x20,%al
f0100321:	0f 85 f1 00 00 00    	jne    f0100418 <kbd_proc_data+0x10e>
f0100327:	ba 60 00 00 00       	mov    $0x60,%edx
f010032c:	ec                   	in     (%dx),%al
f010032d:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f010032f:	3c e0                	cmp    $0xe0,%al
f0100331:	74 61                	je     f0100394 <kbd_proc_data+0x8a>
	} else if (data & 0x80) {
f0100333:	84 c0                	test   %al,%al
f0100335:	78 70                	js     f01003a7 <kbd_proc_data+0x9d>
	} else if (shift & E0ESC) {
f0100337:	8b 0d 00 50 23 f0    	mov    0xf0235000,%ecx
f010033d:	f6 c1 40             	test   $0x40,%cl
f0100340:	74 0e                	je     f0100350 <kbd_proc_data+0x46>
		data |= 0x80;
f0100342:	83 c8 80             	or     $0xffffff80,%eax
f0100345:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100347:	83 e1 bf             	and    $0xffffffbf,%ecx
f010034a:	89 0d 00 50 23 f0    	mov    %ecx,0xf0235000
	shift |= shiftcode[data];
f0100350:	0f b6 d2             	movzbl %dl,%edx
f0100353:	0f b6 82 00 62 10 f0 	movzbl -0xfef9e00(%edx),%eax
f010035a:	0b 05 00 50 23 f0    	or     0xf0235000,%eax
	shift ^= togglecode[data];
f0100360:	0f b6 8a 00 61 10 f0 	movzbl -0xfef9f00(%edx),%ecx
f0100367:	31 c8                	xor    %ecx,%eax
f0100369:	a3 00 50 23 f0       	mov    %eax,0xf0235000
	c = charcode[shift & (CTL | SHIFT)][data];
f010036e:	89 c1                	mov    %eax,%ecx
f0100370:	83 e1 03             	and    $0x3,%ecx
f0100373:	8b 0c 8d e0 60 10 f0 	mov    -0xfef9f20(,%ecx,4),%ecx
f010037a:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f010037e:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f0100381:	a8 08                	test   $0x8,%al
f0100383:	74 61                	je     f01003e6 <kbd_proc_data+0xdc>
		if ('a' <= c && c <= 'z')
f0100385:	89 da                	mov    %ebx,%edx
f0100387:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f010038a:	83 f9 19             	cmp    $0x19,%ecx
f010038d:	77 4b                	ja     f01003da <kbd_proc_data+0xd0>
			c += 'A' - 'a';
f010038f:	83 eb 20             	sub    $0x20,%ebx
f0100392:	eb 0c                	jmp    f01003a0 <kbd_proc_data+0x96>
		shift |= E0ESC;
f0100394:	83 0d 00 50 23 f0 40 	orl    $0x40,0xf0235000
		return 0;
f010039b:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f01003a0:	89 d8                	mov    %ebx,%eax
f01003a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01003a5:	c9                   	leave  
f01003a6:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f01003a7:	8b 0d 00 50 23 f0    	mov    0xf0235000,%ecx
f01003ad:	89 cb                	mov    %ecx,%ebx
f01003af:	83 e3 40             	and    $0x40,%ebx
f01003b2:	83 e0 7f             	and    $0x7f,%eax
f01003b5:	85 db                	test   %ebx,%ebx
f01003b7:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01003ba:	0f b6 d2             	movzbl %dl,%edx
f01003bd:	0f b6 82 00 62 10 f0 	movzbl -0xfef9e00(%edx),%eax
f01003c4:	83 c8 40             	or     $0x40,%eax
f01003c7:	0f b6 c0             	movzbl %al,%eax
f01003ca:	f7 d0                	not    %eax
f01003cc:	21 c8                	and    %ecx,%eax
f01003ce:	a3 00 50 23 f0       	mov    %eax,0xf0235000
		return 0;
f01003d3:	bb 00 00 00 00       	mov    $0x0,%ebx
f01003d8:	eb c6                	jmp    f01003a0 <kbd_proc_data+0x96>
		else if ('A' <= c && c <= 'Z')
f01003da:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01003dd:	8d 4b 20             	lea    0x20(%ebx),%ecx
f01003e0:	83 fa 1a             	cmp    $0x1a,%edx
f01003e3:	0f 42 d9             	cmovb  %ecx,%ebx
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01003e6:	f7 d0                	not    %eax
f01003e8:	a8 06                	test   $0x6,%al
f01003ea:	75 b4                	jne    f01003a0 <kbd_proc_data+0x96>
f01003ec:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01003f2:	75 ac                	jne    f01003a0 <kbd_proc_data+0x96>
		cprintf("Rebooting!\n");
f01003f4:	83 ec 0c             	sub    $0xc,%esp
f01003f7:	68 9c 60 10 f0       	push   $0xf010609c
f01003fc:	e8 1f 34 00 00       	call   f0103820 <cprintf>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100401:	b8 03 00 00 00       	mov    $0x3,%eax
f0100406:	ba 92 00 00 00       	mov    $0x92,%edx
f010040b:	ee                   	out    %al,(%dx)
f010040c:	83 c4 10             	add    $0x10,%esp
f010040f:	eb 8f                	jmp    f01003a0 <kbd_proc_data+0x96>
		return -1;
f0100411:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f0100416:	eb 88                	jmp    f01003a0 <kbd_proc_data+0x96>
		return -1;
f0100418:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f010041d:	eb 81                	jmp    f01003a0 <kbd_proc_data+0x96>

f010041f <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f010041f:	55                   	push   %ebp
f0100420:	89 e5                	mov    %esp,%ebp
f0100422:	57                   	push   %edi
f0100423:	56                   	push   %esi
f0100424:	53                   	push   %ebx
f0100425:	83 ec 1c             	sub    $0x1c,%esp
f0100428:	89 c1                	mov    %eax,%ecx
	for (i = 0;
f010042a:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010042f:	bf fd 03 00 00       	mov    $0x3fd,%edi
f0100434:	bb 84 00 00 00       	mov    $0x84,%ebx
f0100439:	89 fa                	mov    %edi,%edx
f010043b:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f010043c:	a8 20                	test   $0x20,%al
f010043e:	75 13                	jne    f0100453 <cons_putc+0x34>
f0100440:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f0100446:	7f 0b                	jg     f0100453 <cons_putc+0x34>
f0100448:	89 da                	mov    %ebx,%edx
f010044a:	ec                   	in     (%dx),%al
f010044b:	ec                   	in     (%dx),%al
f010044c:	ec                   	in     (%dx),%al
f010044d:	ec                   	in     (%dx),%al
	     i++)
f010044e:	83 c6 01             	add    $0x1,%esi
f0100451:	eb e6                	jmp    f0100439 <cons_putc+0x1a>
	outb(COM1 + COM_TX, c);
f0100453:	88 4d e7             	mov    %cl,-0x19(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100456:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010045b:	89 c8                	mov    %ecx,%eax
f010045d:	ee                   	out    %al,(%dx)
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010045e:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100463:	bf 79 03 00 00       	mov    $0x379,%edi
f0100468:	bb 84 00 00 00       	mov    $0x84,%ebx
f010046d:	89 fa                	mov    %edi,%edx
f010046f:	ec                   	in     (%dx),%al
f0100470:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f0100476:	7f 0f                	jg     f0100487 <cons_putc+0x68>
f0100478:	84 c0                	test   %al,%al
f010047a:	78 0b                	js     f0100487 <cons_putc+0x68>
f010047c:	89 da                	mov    %ebx,%edx
f010047e:	ec                   	in     (%dx),%al
f010047f:	ec                   	in     (%dx),%al
f0100480:	ec                   	in     (%dx),%al
f0100481:	ec                   	in     (%dx),%al
f0100482:	83 c6 01             	add    $0x1,%esi
f0100485:	eb e6                	jmp    f010046d <cons_putc+0x4e>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100487:	ba 78 03 00 00       	mov    $0x378,%edx
f010048c:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100490:	ee                   	out    %al,(%dx)
f0100491:	ba 7a 03 00 00       	mov    $0x37a,%edx
f0100496:	b8 0d 00 00 00       	mov    $0xd,%eax
f010049b:	ee                   	out    %al,(%dx)
f010049c:	b8 08 00 00 00       	mov    $0x8,%eax
f01004a1:	ee                   	out    %al,(%dx)
	if (!(c & ~0xFF))
f01004a2:	89 ca                	mov    %ecx,%edx
f01004a4:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f01004aa:	89 c8                	mov    %ecx,%eax
f01004ac:	80 cc 07             	or     $0x7,%ah
f01004af:	85 d2                	test   %edx,%edx
f01004b1:	0f 44 c8             	cmove  %eax,%ecx
	switch (c & 0xff) {
f01004b4:	0f b6 c1             	movzbl %cl,%eax
f01004b7:	83 f8 09             	cmp    $0x9,%eax
f01004ba:	0f 84 b0 00 00 00    	je     f0100570 <cons_putc+0x151>
f01004c0:	7e 73                	jle    f0100535 <cons_putc+0x116>
f01004c2:	83 f8 0a             	cmp    $0xa,%eax
f01004c5:	0f 84 98 00 00 00    	je     f0100563 <cons_putc+0x144>
f01004cb:	83 f8 0d             	cmp    $0xd,%eax
f01004ce:	0f 85 d3 00 00 00    	jne    f01005a7 <cons_putc+0x188>
		crt_pos -= (crt_pos % CRT_COLS);
f01004d4:	0f b7 05 28 52 23 f0 	movzwl 0xf0235228,%eax
f01004db:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01004e1:	c1 e8 16             	shr    $0x16,%eax
f01004e4:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01004e7:	c1 e0 04             	shl    $0x4,%eax
f01004ea:	66 a3 28 52 23 f0    	mov    %ax,0xf0235228
	if (crt_pos >= CRT_SIZE) {
f01004f0:	66 81 3d 28 52 23 f0 	cmpw   $0x7cf,0xf0235228
f01004f7:	cf 07 
f01004f9:	0f 87 cb 00 00 00    	ja     f01005ca <cons_putc+0x1ab>
	outb(addr_6845, 14);
f01004ff:	8b 0d 30 52 23 f0    	mov    0xf0235230,%ecx
f0100505:	b8 0e 00 00 00       	mov    $0xe,%eax
f010050a:	89 ca                	mov    %ecx,%edx
f010050c:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f010050d:	0f b7 1d 28 52 23 f0 	movzwl 0xf0235228,%ebx
f0100514:	8d 71 01             	lea    0x1(%ecx),%esi
f0100517:	89 d8                	mov    %ebx,%eax
f0100519:	66 c1 e8 08          	shr    $0x8,%ax
f010051d:	89 f2                	mov    %esi,%edx
f010051f:	ee                   	out    %al,(%dx)
f0100520:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100525:	89 ca                	mov    %ecx,%edx
f0100527:	ee                   	out    %al,(%dx)
f0100528:	89 d8                	mov    %ebx,%eax
f010052a:	89 f2                	mov    %esi,%edx
f010052c:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f010052d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100530:	5b                   	pop    %ebx
f0100531:	5e                   	pop    %esi
f0100532:	5f                   	pop    %edi
f0100533:	5d                   	pop    %ebp
f0100534:	c3                   	ret    
	switch (c & 0xff) {
f0100535:	83 f8 08             	cmp    $0x8,%eax
f0100538:	75 6d                	jne    f01005a7 <cons_putc+0x188>
		if (crt_pos > 0) {
f010053a:	0f b7 05 28 52 23 f0 	movzwl 0xf0235228,%eax
f0100541:	66 85 c0             	test   %ax,%ax
f0100544:	74 b9                	je     f01004ff <cons_putc+0xe0>
			crt_pos--;
f0100546:	83 e8 01             	sub    $0x1,%eax
f0100549:	66 a3 28 52 23 f0    	mov    %ax,0xf0235228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010054f:	0f b7 c0             	movzwl %ax,%eax
f0100552:	b1 00                	mov    $0x0,%cl
f0100554:	83 c9 20             	or     $0x20,%ecx
f0100557:	8b 15 2c 52 23 f0    	mov    0xf023522c,%edx
f010055d:	66 89 0c 42          	mov    %cx,(%edx,%eax,2)
f0100561:	eb 8d                	jmp    f01004f0 <cons_putc+0xd1>
		crt_pos += CRT_COLS;
f0100563:	66 83 05 28 52 23 f0 	addw   $0x50,0xf0235228
f010056a:	50 
f010056b:	e9 64 ff ff ff       	jmp    f01004d4 <cons_putc+0xb5>
		cons_putc(' ');
f0100570:	b8 20 00 00 00       	mov    $0x20,%eax
f0100575:	e8 a5 fe ff ff       	call   f010041f <cons_putc>
		cons_putc(' ');
f010057a:	b8 20 00 00 00       	mov    $0x20,%eax
f010057f:	e8 9b fe ff ff       	call   f010041f <cons_putc>
		cons_putc(' ');
f0100584:	b8 20 00 00 00       	mov    $0x20,%eax
f0100589:	e8 91 fe ff ff       	call   f010041f <cons_putc>
		cons_putc(' ');
f010058e:	b8 20 00 00 00       	mov    $0x20,%eax
f0100593:	e8 87 fe ff ff       	call   f010041f <cons_putc>
		cons_putc(' ');
f0100598:	b8 20 00 00 00       	mov    $0x20,%eax
f010059d:	e8 7d fe ff ff       	call   f010041f <cons_putc>
f01005a2:	e9 49 ff ff ff       	jmp    f01004f0 <cons_putc+0xd1>
		crt_buf[crt_pos++] = c;		/* write the character */
f01005a7:	0f b7 05 28 52 23 f0 	movzwl 0xf0235228,%eax
f01005ae:	8d 50 01             	lea    0x1(%eax),%edx
f01005b1:	66 89 15 28 52 23 f0 	mov    %dx,0xf0235228
f01005b8:	0f b7 c0             	movzwl %ax,%eax
f01005bb:	8b 15 2c 52 23 f0    	mov    0xf023522c,%edx
f01005c1:	66 89 0c 42          	mov    %cx,(%edx,%eax,2)
f01005c5:	e9 26 ff ff ff       	jmp    f01004f0 <cons_putc+0xd1>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01005ca:	a1 2c 52 23 f0       	mov    0xf023522c,%eax
f01005cf:	83 ec 04             	sub    $0x4,%esp
f01005d2:	68 00 0f 00 00       	push   $0xf00
f01005d7:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01005dd:	52                   	push   %edx
f01005de:	50                   	push   %eax
f01005df:	e8 bf 4d 00 00       	call   f01053a3 <memmove>
			crt_buf[i] = 0x0700 | ' ';
f01005e4:	8b 15 2c 52 23 f0    	mov    0xf023522c,%edx
f01005ea:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f01005f0:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f01005f6:	83 c4 10             	add    $0x10,%esp
f01005f9:	66 c7 00 20 07       	movw   $0x720,(%eax)
f01005fe:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100601:	39 d0                	cmp    %edx,%eax
f0100603:	75 f4                	jne    f01005f9 <cons_putc+0x1da>
		crt_pos -= CRT_COLS;
f0100605:	66 83 2d 28 52 23 f0 	subw   $0x50,0xf0235228
f010060c:	50 
f010060d:	e9 ed fe ff ff       	jmp    f01004ff <cons_putc+0xe0>

f0100612 <serial_intr>:
	if (serial_exists)
f0100612:	80 3d 34 52 23 f0 00 	cmpb   $0x0,0xf0235234
f0100619:	75 01                	jne    f010061c <serial_intr+0xa>
f010061b:	c3                   	ret    
{
f010061c:	55                   	push   %ebp
f010061d:	89 e5                	mov    %esp,%ebp
f010061f:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f0100622:	b8 b1 02 10 f0       	mov    $0xf01002b1,%eax
f0100627:	e8 9f fc ff ff       	call   f01002cb <cons_intr>
}
f010062c:	c9                   	leave  
f010062d:	c3                   	ret    

f010062e <kbd_intr>:
{
f010062e:	55                   	push   %ebp
f010062f:	89 e5                	mov    %esp,%ebp
f0100631:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100634:	b8 0a 03 10 f0       	mov    $0xf010030a,%eax
f0100639:	e8 8d fc ff ff       	call   f01002cb <cons_intr>
}
f010063e:	c9                   	leave  
f010063f:	c3                   	ret    

f0100640 <cons_getc>:
{
f0100640:	55                   	push   %ebp
f0100641:	89 e5                	mov    %esp,%ebp
f0100643:	83 ec 08             	sub    $0x8,%esp
	serial_intr();
f0100646:	e8 c7 ff ff ff       	call   f0100612 <serial_intr>
	kbd_intr();
f010064b:	e8 de ff ff ff       	call   f010062e <kbd_intr>
	if (cons.rpos != cons.wpos) {
f0100650:	8b 15 20 52 23 f0    	mov    0xf0235220,%edx
	return 0;
f0100656:	b8 00 00 00 00       	mov    $0x0,%eax
	if (cons.rpos != cons.wpos) {
f010065b:	3b 15 24 52 23 f0    	cmp    0xf0235224,%edx
f0100661:	74 1e                	je     f0100681 <cons_getc+0x41>
		c = cons.buf[cons.rpos++];
f0100663:	8d 4a 01             	lea    0x1(%edx),%ecx
f0100666:	0f b6 82 20 50 23 f0 	movzbl -0xfdcafe0(%edx),%eax
			cons.rpos = 0;
f010066d:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f0100673:	ba 00 00 00 00       	mov    $0x0,%edx
f0100678:	0f 44 ca             	cmove  %edx,%ecx
f010067b:	89 0d 20 52 23 f0    	mov    %ecx,0xf0235220
}
f0100681:	c9                   	leave  
f0100682:	c3                   	ret    

f0100683 <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f0100683:	55                   	push   %ebp
f0100684:	89 e5                	mov    %esp,%ebp
f0100686:	57                   	push   %edi
f0100687:	56                   	push   %esi
f0100688:	53                   	push   %ebx
f0100689:	83 ec 0c             	sub    $0xc,%esp
	was = *cp;
f010068c:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100693:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f010069a:	5a a5 
	if (*cp != 0xA55A) {
f010069c:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f01006a3:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01006a7:	0f 84 d4 00 00 00    	je     f0100781 <cons_init+0xfe>
		addr_6845 = MONO_BASE;
f01006ad:	c7 05 30 52 23 f0 b4 	movl   $0x3b4,0xf0235230
f01006b4:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f01006b7:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
	outb(addr_6845, 14);
f01006bc:	8b 3d 30 52 23 f0    	mov    0xf0235230,%edi
f01006c2:	b8 0e 00 00 00       	mov    $0xe,%eax
f01006c7:	89 fa                	mov    %edi,%edx
f01006c9:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01006ca:	8d 4f 01             	lea    0x1(%edi),%ecx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006cd:	89 ca                	mov    %ecx,%edx
f01006cf:	ec                   	in     (%dx),%al
f01006d0:	0f b6 c0             	movzbl %al,%eax
f01006d3:	c1 e0 08             	shl    $0x8,%eax
f01006d6:	89 c3                	mov    %eax,%ebx
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006d8:	b8 0f 00 00 00       	mov    $0xf,%eax
f01006dd:	89 fa                	mov    %edi,%edx
f01006df:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006e0:	89 ca                	mov    %ecx,%edx
f01006e2:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f01006e3:	89 35 2c 52 23 f0    	mov    %esi,0xf023522c
	pos |= inb(addr_6845 + 1);
f01006e9:	0f b6 c0             	movzbl %al,%eax
f01006ec:	09 d8                	or     %ebx,%eax
	crt_pos = pos;
f01006ee:	66 a3 28 52 23 f0    	mov    %ax,0xf0235228
	kbd_intr();
f01006f4:	e8 35 ff ff ff       	call   f010062e <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_KBD));
f01006f9:	83 ec 0c             	sub    $0xc,%esp
f01006fc:	0f b7 05 a8 23 12 f0 	movzwl 0xf01223a8,%eax
f0100703:	25 fd ff 00 00       	and    $0xfffd,%eax
f0100708:	50                   	push   %eax
f0100709:	e8 b5 2f 00 00       	call   f01036c3 <irq_setmask_8259A>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010070e:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100713:	b9 fa 03 00 00       	mov    $0x3fa,%ecx
f0100718:	89 d8                	mov    %ebx,%eax
f010071a:	89 ca                	mov    %ecx,%edx
f010071c:	ee                   	out    %al,(%dx)
f010071d:	bf fb 03 00 00       	mov    $0x3fb,%edi
f0100722:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100727:	89 fa                	mov    %edi,%edx
f0100729:	ee                   	out    %al,(%dx)
f010072a:	b8 0c 00 00 00       	mov    $0xc,%eax
f010072f:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100734:	ee                   	out    %al,(%dx)
f0100735:	be f9 03 00 00       	mov    $0x3f9,%esi
f010073a:	89 d8                	mov    %ebx,%eax
f010073c:	89 f2                	mov    %esi,%edx
f010073e:	ee                   	out    %al,(%dx)
f010073f:	b8 03 00 00 00       	mov    $0x3,%eax
f0100744:	89 fa                	mov    %edi,%edx
f0100746:	ee                   	out    %al,(%dx)
f0100747:	ba fc 03 00 00       	mov    $0x3fc,%edx
f010074c:	89 d8                	mov    %ebx,%eax
f010074e:	ee                   	out    %al,(%dx)
f010074f:	b8 01 00 00 00       	mov    $0x1,%eax
f0100754:	89 f2                	mov    %esi,%edx
f0100756:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100757:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010075c:	ec                   	in     (%dx),%al
f010075d:	89 c3                	mov    %eax,%ebx
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f010075f:	83 c4 10             	add    $0x10,%esp
f0100762:	3c ff                	cmp    $0xff,%al
f0100764:	0f 95 05 34 52 23 f0 	setne  0xf0235234
f010076b:	89 ca                	mov    %ecx,%edx
f010076d:	ec                   	in     (%dx),%al
f010076e:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100773:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100774:	80 fb ff             	cmp    $0xff,%bl
f0100777:	74 23                	je     f010079c <cons_init+0x119>
		cprintf("Serial port does not exist!\n");
}
f0100779:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010077c:	5b                   	pop    %ebx
f010077d:	5e                   	pop    %esi
f010077e:	5f                   	pop    %edi
f010077f:	5d                   	pop    %ebp
f0100780:	c3                   	ret    
		*cp = was;
f0100781:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100788:	c7 05 30 52 23 f0 d4 	movl   $0x3d4,0xf0235230
f010078f:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100792:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
f0100797:	e9 20 ff ff ff       	jmp    f01006bc <cons_init+0x39>
		cprintf("Serial port does not exist!\n");
f010079c:	83 ec 0c             	sub    $0xc,%esp
f010079f:	68 a8 60 10 f0       	push   $0xf01060a8
f01007a4:	e8 77 30 00 00       	call   f0103820 <cprintf>
f01007a9:	83 c4 10             	add    $0x10,%esp
}
f01007ac:	eb cb                	jmp    f0100779 <cons_init+0xf6>

f01007ae <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01007ae:	55                   	push   %ebp
f01007af:	89 e5                	mov    %esp,%ebp
f01007b1:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01007b4:	8b 45 08             	mov    0x8(%ebp),%eax
f01007b7:	e8 63 fc ff ff       	call   f010041f <cons_putc>
}
f01007bc:	c9                   	leave  
f01007bd:	c3                   	ret    

f01007be <getchar>:

int
getchar(void)
{
f01007be:	55                   	push   %ebp
f01007bf:	89 e5                	mov    %esp,%ebp
f01007c1:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01007c4:	e8 77 fe ff ff       	call   f0100640 <cons_getc>
f01007c9:	85 c0                	test   %eax,%eax
f01007cb:	74 f7                	je     f01007c4 <getchar+0x6>
		/* do nothing */;
	return c;
}
f01007cd:	c9                   	leave  
f01007ce:	c3                   	ret    

f01007cf <iscons>:
int
iscons(int fdnum)
{
	// used by readline
	return 1;
}
f01007cf:	b8 01 00 00 00       	mov    $0x1,%eax
f01007d4:	c3                   	ret    

f01007d5 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01007d5:	55                   	push   %ebp
f01007d6:	89 e5                	mov    %esp,%ebp
f01007d8:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01007db:	68 00 63 10 f0       	push   $0xf0106300
f01007e0:	68 1e 63 10 f0       	push   $0xf010631e
f01007e5:	68 23 63 10 f0       	push   $0xf0106323
f01007ea:	e8 31 30 00 00       	call   f0103820 <cprintf>
f01007ef:	83 c4 0c             	add    $0xc,%esp
f01007f2:	68 d0 63 10 f0       	push   $0xf01063d0
f01007f7:	68 2c 63 10 f0       	push   $0xf010632c
f01007fc:	68 23 63 10 f0       	push   $0xf0106323
f0100801:	e8 1a 30 00 00       	call   f0103820 <cprintf>
f0100806:	83 c4 0c             	add    $0xc,%esp
f0100809:	68 35 63 10 f0       	push   $0xf0106335
f010080e:	68 4c 63 10 f0       	push   $0xf010634c
f0100813:	68 23 63 10 f0       	push   $0xf0106323
f0100818:	e8 03 30 00 00       	call   f0103820 <cprintf>
	return 0;
}
f010081d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100822:	c9                   	leave  
f0100823:	c3                   	ret    

f0100824 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100824:	55                   	push   %ebp
f0100825:	89 e5                	mov    %esp,%ebp
f0100827:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f010082a:	68 56 63 10 f0       	push   $0xf0106356
f010082f:	e8 ec 2f 00 00       	call   f0103820 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100834:	83 c4 08             	add    $0x8,%esp
f0100837:	68 0c 00 10 00       	push   $0x10000c
f010083c:	68 f8 63 10 f0       	push   $0xf01063f8
f0100841:	e8 da 2f 00 00       	call   f0103820 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100846:	83 c4 0c             	add    $0xc,%esp
f0100849:	68 0c 00 10 00       	push   $0x10000c
f010084e:	68 0c 00 10 f0       	push   $0xf010000c
f0100853:	68 20 64 10 f0       	push   $0xf0106420
f0100858:	e8 c3 2f 00 00       	call   f0103820 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010085d:	83 c4 0c             	add    $0xc,%esp
f0100860:	68 9f 5f 10 00       	push   $0x105f9f
f0100865:	68 9f 5f 10 f0       	push   $0xf0105f9f
f010086a:	68 44 64 10 f0       	push   $0xf0106444
f010086f:	e8 ac 2f 00 00       	call   f0103820 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100874:	83 c4 0c             	add    $0xc,%esp
f0100877:	68 00 50 23 00       	push   $0x235000
f010087c:	68 00 50 23 f0       	push   $0xf0235000
f0100881:	68 68 64 10 f0       	push   $0xf0106468
f0100886:	e8 95 2f 00 00       	call   f0103820 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010088b:	83 c4 0c             	add    $0xc,%esp
f010088e:	68 08 70 27 00       	push   $0x277008
f0100893:	68 08 70 27 f0       	push   $0xf0277008
f0100898:	68 8c 64 10 f0       	push   $0xf010648c
f010089d:	e8 7e 2f 00 00       	call   f0103820 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f01008a2:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f01008a5:	b8 08 70 27 f0       	mov    $0xf0277008,%eax
f01008aa:	2d 0d fc 0f f0       	sub    $0xf00ffc0d,%eax
	cprintf("Kernel executable memory footprint: %dKB\n",
f01008af:	c1 f8 0a             	sar    $0xa,%eax
f01008b2:	50                   	push   %eax
f01008b3:	68 b0 64 10 f0       	push   $0xf01064b0
f01008b8:	e8 63 2f 00 00       	call   f0103820 <cprintf>
	return 0;
}
f01008bd:	b8 00 00 00 00       	mov    $0x0,%eax
f01008c2:	c9                   	leave  
f01008c3:	c3                   	ret    

f01008c4 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01008c4:	55                   	push   %ebp
f01008c5:	89 e5                	mov    %esp,%ebp
f01008c7:	57                   	push   %edi
f01008c8:	56                   	push   %esi
f01008c9:	53                   	push   %ebx
f01008ca:	83 ec 38             	sub    $0x38,%esp
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f01008cd:	89 eb                	mov    %ebp,%ebx
	// Your code here.
	uint32_t ebp, *ptr_ebp;
	ebp = read_ebp();
	cprintf("Stack backtrace:\n");
f01008cf:	68 6f 63 10 f0       	push   $0xf010636f
f01008d4:	e8 47 2f 00 00       	call   f0103820 <cprintf>
	while (ebp != 0) {
f01008d9:	83 c4 10             	add    $0x10,%esp
		ptr_ebp = (uint32_t *)ebp;
		cprintf(" ebp %x  eip %x  args %08x %08x %08x %08x %08x\n", 
        		ebp, ptr_ebp[1], ptr_ebp[2], ptr_ebp[3], ptr_ebp[4], ptr_ebp[5], ptr_ebp[6]);
		struct Eipdebuginfo info;
		if (debuginfo_eip(ptr_ebp[1], &info) == 0) {
f01008dc:	8d 7d d0             	lea    -0x30(%ebp),%edi
	while (ebp != 0) {
f01008df:	eb 25                	jmp    f0100906 <mon_backtrace+0x42>
			uint32_t fn_offset = ptr_ebp[1] - info.eip_fn_addr; 
			cprintf(" \t%s:%d: %.*s+%d\n", info.eip_file, info.eip_line\
f01008e1:	83 ec 08             	sub    $0x8,%esp
			uint32_t fn_offset = ptr_ebp[1] - info.eip_fn_addr; 
f01008e4:	8b 43 04             	mov    0x4(%ebx),%eax
f01008e7:	2b 45 e0             	sub    -0x20(%ebp),%eax
			cprintf(" \t%s:%d: %.*s+%d\n", info.eip_file, info.eip_line\
f01008ea:	50                   	push   %eax
f01008eb:	ff 75 d8             	pushl  -0x28(%ebp)
f01008ee:	ff 75 dc             	pushl  -0x24(%ebp)
f01008f1:	ff 75 d4             	pushl  -0x2c(%ebp)
f01008f4:	ff 75 d0             	pushl  -0x30(%ebp)
f01008f7:	68 81 63 10 f0       	push   $0xf0106381
f01008fc:	e8 1f 2f 00 00       	call   f0103820 <cprintf>
f0100901:	83 c4 20             	add    $0x20,%esp
							, info.eip_fn_namelen, info.eip_fn_name, fn_offset);
		}
		ebp = *ptr_ebp;
f0100904:	8b 1e                	mov    (%esi),%ebx
	while (ebp != 0) {
f0100906:	85 db                	test   %ebx,%ebx
f0100908:	74 34                	je     f010093e <mon_backtrace+0x7a>
		ptr_ebp = (uint32_t *)ebp;
f010090a:	89 de                	mov    %ebx,%esi
		cprintf(" ebp %x  eip %x  args %08x %08x %08x %08x %08x\n", 
f010090c:	ff 73 18             	pushl  0x18(%ebx)
f010090f:	ff 73 14             	pushl  0x14(%ebx)
f0100912:	ff 73 10             	pushl  0x10(%ebx)
f0100915:	ff 73 0c             	pushl  0xc(%ebx)
f0100918:	ff 73 08             	pushl  0x8(%ebx)
f010091b:	ff 73 04             	pushl  0x4(%ebx)
f010091e:	53                   	push   %ebx
f010091f:	68 dc 64 10 f0       	push   $0xf01064dc
f0100924:	e8 f7 2e 00 00       	call   f0103820 <cprintf>
		if (debuginfo_eip(ptr_ebp[1], &info) == 0) {
f0100929:	83 c4 18             	add    $0x18,%esp
f010092c:	57                   	push   %edi
f010092d:	ff 73 04             	pushl  0x4(%ebx)
f0100930:	e8 e7 3f 00 00       	call   f010491c <debuginfo_eip>
f0100935:	83 c4 10             	add    $0x10,%esp
f0100938:	85 c0                	test   %eax,%eax
f010093a:	75 c8                	jne    f0100904 <mon_backtrace+0x40>
f010093c:	eb a3                	jmp    f01008e1 <mon_backtrace+0x1d>
	}
	return 0;
}
f010093e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100943:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100946:	5b                   	pop    %ebx
f0100947:	5e                   	pop    %esi
f0100948:	5f                   	pop    %edi
f0100949:	5d                   	pop    %ebp
f010094a:	c3                   	ret    

f010094b <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f010094b:	55                   	push   %ebp
f010094c:	89 e5                	mov    %esp,%ebp
f010094e:	57                   	push   %edi
f010094f:	56                   	push   %esi
f0100950:	53                   	push   %ebx
f0100951:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100954:	68 0c 65 10 f0       	push   $0xf010650c
f0100959:	e8 c2 2e 00 00       	call   f0103820 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f010095e:	c7 04 24 30 65 10 f0 	movl   $0xf0106530,(%esp)
f0100965:	e8 b6 2e 00 00       	call   f0103820 <cprintf>

	if (tf != NULL)
f010096a:	83 c4 10             	add    $0x10,%esp
f010096d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100971:	0f 84 d9 00 00 00    	je     f0100a50 <monitor+0x105>
		print_trapframe(tf);
f0100977:	83 ec 0c             	sub    $0xc,%esp
f010097a:	ff 75 08             	pushl  0x8(%ebp)
f010097d:	e8 73 33 00 00       	call   f0103cf5 <print_trapframe>
f0100982:	83 c4 10             	add    $0x10,%esp
f0100985:	e9 c6 00 00 00       	jmp    f0100a50 <monitor+0x105>
		while (*buf && strchr(WHITESPACE, *buf))
f010098a:	83 ec 08             	sub    $0x8,%esp
f010098d:	0f be c0             	movsbl %al,%eax
f0100990:	50                   	push   %eax
f0100991:	68 97 63 10 f0       	push   $0xf0106397
f0100996:	e8 83 49 00 00       	call   f010531e <strchr>
f010099b:	83 c4 10             	add    $0x10,%esp
f010099e:	85 c0                	test   %eax,%eax
f01009a0:	74 63                	je     f0100a05 <monitor+0xba>
			*buf++ = 0;
f01009a2:	c6 03 00             	movb   $0x0,(%ebx)
f01009a5:	89 f7                	mov    %esi,%edi
f01009a7:	8d 5b 01             	lea    0x1(%ebx),%ebx
f01009aa:	89 fe                	mov    %edi,%esi
		while (*buf && strchr(WHITESPACE, *buf))
f01009ac:	0f b6 03             	movzbl (%ebx),%eax
f01009af:	84 c0                	test   %al,%al
f01009b1:	75 d7                	jne    f010098a <monitor+0x3f>
	argv[argc] = 0;
f01009b3:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f01009ba:	00 
	if (argc == 0)
f01009bb:	85 f6                	test   %esi,%esi
f01009bd:	0f 84 8d 00 00 00    	je     f0100a50 <monitor+0x105>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f01009c3:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (strcmp(argv[0], commands[i].name) == 0)
f01009c8:	83 ec 08             	sub    $0x8,%esp
f01009cb:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f01009ce:	ff 34 85 60 65 10 f0 	pushl  -0xfef9aa0(,%eax,4)
f01009d5:	ff 75 a8             	pushl  -0x58(%ebp)
f01009d8:	e8 e3 48 00 00       	call   f01052c0 <strcmp>
f01009dd:	83 c4 10             	add    $0x10,%esp
f01009e0:	85 c0                	test   %eax,%eax
f01009e2:	0f 84 8f 00 00 00    	je     f0100a77 <monitor+0x12c>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f01009e8:	83 c3 01             	add    $0x1,%ebx
f01009eb:	83 fb 03             	cmp    $0x3,%ebx
f01009ee:	75 d8                	jne    f01009c8 <monitor+0x7d>
	cprintf("Unknown command '%s'\n", argv[0]);
f01009f0:	83 ec 08             	sub    $0x8,%esp
f01009f3:	ff 75 a8             	pushl  -0x58(%ebp)
f01009f6:	68 b9 63 10 f0       	push   $0xf01063b9
f01009fb:	e8 20 2e 00 00       	call   f0103820 <cprintf>
f0100a00:	83 c4 10             	add    $0x10,%esp
f0100a03:	eb 4b                	jmp    f0100a50 <monitor+0x105>
		if (*buf == 0)
f0100a05:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100a08:	74 a9                	je     f01009b3 <monitor+0x68>
		if (argc == MAXARGS-1) {
f0100a0a:	83 fe 0f             	cmp    $0xf,%esi
f0100a0d:	74 2f                	je     f0100a3e <monitor+0xf3>
		argv[argc++] = buf;
f0100a0f:	8d 7e 01             	lea    0x1(%esi),%edi
f0100a12:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
		while (*buf && !strchr(WHITESPACE, *buf))
f0100a16:	0f b6 03             	movzbl (%ebx),%eax
f0100a19:	84 c0                	test   %al,%al
f0100a1b:	74 8d                	je     f01009aa <monitor+0x5f>
f0100a1d:	83 ec 08             	sub    $0x8,%esp
f0100a20:	0f be c0             	movsbl %al,%eax
f0100a23:	50                   	push   %eax
f0100a24:	68 97 63 10 f0       	push   $0xf0106397
f0100a29:	e8 f0 48 00 00       	call   f010531e <strchr>
f0100a2e:	83 c4 10             	add    $0x10,%esp
f0100a31:	85 c0                	test   %eax,%eax
f0100a33:	0f 85 71 ff ff ff    	jne    f01009aa <monitor+0x5f>
			buf++;
f0100a39:	83 c3 01             	add    $0x1,%ebx
f0100a3c:	eb d8                	jmp    f0100a16 <monitor+0xcb>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100a3e:	83 ec 08             	sub    $0x8,%esp
f0100a41:	6a 10                	push   $0x10
f0100a43:	68 9c 63 10 f0       	push   $0xf010639c
f0100a48:	e8 d3 2d 00 00       	call   f0103820 <cprintf>
f0100a4d:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f0100a50:	83 ec 0c             	sub    $0xc,%esp
f0100a53:	68 93 63 10 f0       	push   $0xf0106393
f0100a58:	e8 9d 46 00 00       	call   f01050fa <readline>
f0100a5d:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100a5f:	83 c4 10             	add    $0x10,%esp
f0100a62:	85 c0                	test   %eax,%eax
f0100a64:	74 ea                	je     f0100a50 <monitor+0x105>
	argv[argc] = 0;
f0100a66:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f0100a6d:	be 00 00 00 00       	mov    $0x0,%esi
f0100a72:	e9 35 ff ff ff       	jmp    f01009ac <monitor+0x61>
			return commands[i].func(argc, argv, tf);
f0100a77:	83 ec 04             	sub    $0x4,%esp
f0100a7a:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100a7d:	ff 75 08             	pushl  0x8(%ebp)
f0100a80:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100a83:	52                   	push   %edx
f0100a84:	56                   	push   %esi
f0100a85:	ff 14 85 68 65 10 f0 	call   *-0xfef9a98(,%eax,4)
			if (runcmd(buf, tf) < 0)
f0100a8c:	83 c4 10             	add    $0x10,%esp
f0100a8f:	85 c0                	test   %eax,%eax
f0100a91:	79 bd                	jns    f0100a50 <monitor+0x105>
				break;
	}
}
f0100a93:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100a96:	5b                   	pop    %ebx
f0100a97:	5e                   	pop    %esi
f0100a98:	5f                   	pop    %edi
f0100a99:	5d                   	pop    %ebp
f0100a9a:	c3                   	ret    

f0100a9b <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100a9b:	55                   	push   %ebp
f0100a9c:	89 e5                	mov    %esp,%ebp
f0100a9e:	53                   	push   %ebx
f0100a9f:	83 ec 0c             	sub    $0xc,%esp
f0100aa2:	89 c3                	mov    %eax,%ebx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	cprintf("nextfree:%p\n", nextfree);
f0100aa4:	ff 35 38 52 23 f0    	pushl  0xf0235238
f0100aaa:	68 84 65 10 f0       	push   $0xf0106584
f0100aaf:	e8 6c 2d 00 00       	call   f0103820 <cprintf>
	if (!nextfree) {
f0100ab4:	83 c4 10             	add    $0x10,%esp
f0100ab7:	83 3d 38 52 23 f0 00 	cmpl   $0x0,0xf0235238
f0100abe:	74 1e                	je     f0100ade <boot_alloc+0x43>
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	//cprintf("nextfree:%p\n", nextfree);
	result = nextfree;
f0100ac0:	a1 38 52 23 f0       	mov    0xf0235238,%eax
	nextfree += ROUNDUP(n, PGSIZE);
f0100ac5:	81 c3 ff 0f 00 00    	add    $0xfff,%ebx
f0100acb:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0100ad1:	01 c3                	add    %eax,%ebx
f0100ad3:	89 1d 38 52 23 f0    	mov    %ebx,0xf0235238
	return result;
}
f0100ad9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100adc:	c9                   	leave  
f0100add:	c3                   	ret    
		nextfree = ROUNDUP((char *) end, PGSIZE);		
f0100ade:	b8 07 80 27 f0       	mov    $0xf0278007,%eax
f0100ae3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100ae8:	a3 38 52 23 f0       	mov    %eax,0xf0235238
f0100aed:	eb d1                	jmp    f0100ac0 <boot_alloc+0x25>

f0100aef <nvram_read>:
{
f0100aef:	55                   	push   %ebp
f0100af0:	89 e5                	mov    %esp,%ebp
f0100af2:	56                   	push   %esi
f0100af3:	53                   	push   %ebx
f0100af4:	89 c6                	mov    %eax,%esi
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100af6:	83 ec 0c             	sub    $0xc,%esp
f0100af9:	50                   	push   %eax
f0100afa:	e8 96 2b 00 00       	call   f0103695 <mc146818_read>
f0100aff:	89 c3                	mov    %eax,%ebx
f0100b01:	83 c6 01             	add    $0x1,%esi
f0100b04:	89 34 24             	mov    %esi,(%esp)
f0100b07:	e8 89 2b 00 00       	call   f0103695 <mc146818_read>
f0100b0c:	c1 e0 08             	shl    $0x8,%eax
f0100b0f:	09 d8                	or     %ebx,%eax
}
f0100b11:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100b14:	5b                   	pop    %ebx
f0100b15:	5e                   	pop    %esi
f0100b16:	5d                   	pop    %ebp
f0100b17:	c3                   	ret    

f0100b18 <check_va2pa>:

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;
	pgdir = &pgdir[PDX(va)];
f0100b18:	89 d1                	mov    %edx,%ecx
f0100b1a:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100b1d:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100b20:	a8 01                	test   $0x1,%al
f0100b22:	74 52                	je     f0100b76 <check_va2pa+0x5e>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100b24:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0100b29:	89 c1                	mov    %eax,%ecx
f0100b2b:	c1 e9 0c             	shr    $0xc,%ecx
f0100b2e:	3b 0d 88 5e 23 f0    	cmp    0xf0235e88,%ecx
f0100b34:	73 25                	jae    f0100b5b <check_va2pa+0x43>
	if (!(p[PTX(va)] & PTE_P))
f0100b36:	c1 ea 0c             	shr    $0xc,%edx
f0100b39:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100b3f:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100b46:	89 c2                	mov    %eax,%edx
f0100b48:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100b4b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b50:	85 d2                	test   %edx,%edx
f0100b52:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100b57:	0f 44 c2             	cmove  %edx,%eax
f0100b5a:	c3                   	ret    
{
f0100b5b:	55                   	push   %ebp
f0100b5c:	89 e5                	mov    %esp,%ebp
f0100b5e:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100b61:	50                   	push   %eax
f0100b62:	68 54 60 10 f0       	push   $0xf0106054
f0100b67:	68 a3 03 00 00       	push   $0x3a3
f0100b6c:	68 91 65 10 f0       	push   $0xf0106591
f0100b71:	e8 1e f5 ff ff       	call   f0100094 <_panic>
		return ~0;
f0100b76:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f0100b7b:	c3                   	ret    

f0100b7c <check_page_free_list>:
{
f0100b7c:	55                   	push   %ebp
f0100b7d:	89 e5                	mov    %esp,%ebp
f0100b7f:	57                   	push   %edi
f0100b80:	56                   	push   %esi
f0100b81:	53                   	push   %ebx
f0100b82:	83 ec 2c             	sub    $0x2c,%esp
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100b85:	84 c0                	test   %al,%al
f0100b87:	0f 85 77 02 00 00    	jne    f0100e04 <check_page_free_list+0x288>
	if (!page_free_list)
f0100b8d:	83 3d 3c 52 23 f0 00 	cmpl   $0x0,0xf023523c
f0100b94:	74 0a                	je     f0100ba0 <check_page_free_list+0x24>
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100b96:	be 00 04 00 00       	mov    $0x400,%esi
f0100b9b:	e9 d1 02 00 00       	jmp    f0100e71 <check_page_free_list+0x2f5>
		panic("'page_free_list' is a null pointer!");
f0100ba0:	83 ec 04             	sub    $0x4,%esp
f0100ba3:	68 bc 68 10 f0       	push   $0xf01068bc
f0100ba8:	68 cd 02 00 00       	push   $0x2cd
f0100bad:	68 91 65 10 f0       	push   $0xf0106591
f0100bb2:	e8 dd f4 ff ff       	call   f0100094 <_panic>
f0100bb7:	50                   	push   %eax
f0100bb8:	68 54 60 10 f0       	push   $0xf0106054
f0100bbd:	6a 58                	push   $0x58
f0100bbf:	68 a4 65 10 f0       	push   $0xf01065a4
f0100bc4:	e8 cb f4 ff ff       	call   f0100094 <_panic>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100bc9:	8b 1b                	mov    (%ebx),%ebx
f0100bcb:	85 db                	test   %ebx,%ebx
f0100bcd:	74 41                	je     f0100c10 <check_page_free_list+0x94>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100bcf:	89 d8                	mov    %ebx,%eax
f0100bd1:	2b 05 90 5e 23 f0    	sub    0xf0235e90,%eax
f0100bd7:	c1 f8 03             	sar    $0x3,%eax
f0100bda:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100bdd:	89 c2                	mov    %eax,%edx
f0100bdf:	c1 ea 16             	shr    $0x16,%edx
f0100be2:	39 f2                	cmp    %esi,%edx
f0100be4:	73 e3                	jae    f0100bc9 <check_page_free_list+0x4d>
	if (PGNUM(pa) >= npages)
f0100be6:	89 c2                	mov    %eax,%edx
f0100be8:	c1 ea 0c             	shr    $0xc,%edx
f0100beb:	3b 15 88 5e 23 f0    	cmp    0xf0235e88,%edx
f0100bf1:	73 c4                	jae    f0100bb7 <check_page_free_list+0x3b>
			memset(page2kva(pp), 0x97, 128);
f0100bf3:	83 ec 04             	sub    $0x4,%esp
f0100bf6:	68 80 00 00 00       	push   $0x80
f0100bfb:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0100c00:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c05:	50                   	push   %eax
f0100c06:	e8 50 47 00 00       	call   f010535b <memset>
f0100c0b:	83 c4 10             	add    $0x10,%esp
f0100c0e:	eb b9                	jmp    f0100bc9 <check_page_free_list+0x4d>
	first_free_page = (char *) boot_alloc(0);
f0100c10:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c15:	e8 81 fe ff ff       	call   f0100a9b <boot_alloc>
f0100c1a:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c1d:	8b 15 3c 52 23 f0    	mov    0xf023523c,%edx
		assert(pp >= pages);
f0100c23:	8b 0d 90 5e 23 f0    	mov    0xf0235e90,%ecx
		assert(pp < pages + npages);
f0100c29:	a1 88 5e 23 f0       	mov    0xf0235e88,%eax
f0100c2e:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100c31:	8d 34 c1             	lea    (%ecx,%eax,8),%esi
	int nfree_basemem = 0, nfree_extmem = 0;
f0100c34:	bf 00 00 00 00       	mov    $0x0,%edi
f0100c39:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c3c:	e9 f9 00 00 00       	jmp    f0100d3a <check_page_free_list+0x1be>
		assert(pp >= pages);
f0100c41:	68 b2 65 10 f0       	push   $0xf01065b2
f0100c46:	68 be 65 10 f0       	push   $0xf01065be
f0100c4b:	68 ea 02 00 00       	push   $0x2ea
f0100c50:	68 91 65 10 f0       	push   $0xf0106591
f0100c55:	e8 3a f4 ff ff       	call   f0100094 <_panic>
		assert(pp < pages + npages);
f0100c5a:	68 d3 65 10 f0       	push   $0xf01065d3
f0100c5f:	68 be 65 10 f0       	push   $0xf01065be
f0100c64:	68 eb 02 00 00       	push   $0x2eb
f0100c69:	68 91 65 10 f0       	push   $0xf0106591
f0100c6e:	e8 21 f4 ff ff       	call   f0100094 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100c73:	68 e0 68 10 f0       	push   $0xf01068e0
f0100c78:	68 be 65 10 f0       	push   $0xf01065be
f0100c7d:	68 ec 02 00 00       	push   $0x2ec
f0100c82:	68 91 65 10 f0       	push   $0xf0106591
f0100c87:	e8 08 f4 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != 0);
f0100c8c:	68 e7 65 10 f0       	push   $0xf01065e7
f0100c91:	68 be 65 10 f0       	push   $0xf01065be
f0100c96:	68 ef 02 00 00       	push   $0x2ef
f0100c9b:	68 91 65 10 f0       	push   $0xf0106591
f0100ca0:	e8 ef f3 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100ca5:	68 f8 65 10 f0       	push   $0xf01065f8
f0100caa:	68 be 65 10 f0       	push   $0xf01065be
f0100caf:	68 f0 02 00 00       	push   $0x2f0
f0100cb4:	68 91 65 10 f0       	push   $0xf0106591
f0100cb9:	e8 d6 f3 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100cbe:	68 14 69 10 f0       	push   $0xf0106914
f0100cc3:	68 be 65 10 f0       	push   $0xf01065be
f0100cc8:	68 f1 02 00 00       	push   $0x2f1
f0100ccd:	68 91 65 10 f0       	push   $0xf0106591
f0100cd2:	e8 bd f3 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100cd7:	68 11 66 10 f0       	push   $0xf0106611
f0100cdc:	68 be 65 10 f0       	push   $0xf01065be
f0100ce1:	68 f2 02 00 00       	push   $0x2f2
f0100ce6:	68 91 65 10 f0       	push   $0xf0106591
f0100ceb:	e8 a4 f3 ff ff       	call   f0100094 <_panic>
	if (PGNUM(pa) >= npages)
f0100cf0:	89 c3                	mov    %eax,%ebx
f0100cf2:	c1 eb 0c             	shr    $0xc,%ebx
f0100cf5:	39 5d d0             	cmp    %ebx,-0x30(%ebp)
f0100cf8:	76 0f                	jbe    f0100d09 <check_page_free_list+0x18d>
	return (void *)(pa + KERNBASE);
f0100cfa:	2d 00 00 00 10       	sub    $0x10000000,%eax
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100cff:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0100d02:	77 17                	ja     f0100d1b <check_page_free_list+0x19f>
			++nfree_extmem;
f0100d04:	83 c7 01             	add    $0x1,%edi
f0100d07:	eb 2f                	jmp    f0100d38 <check_page_free_list+0x1bc>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100d09:	50                   	push   %eax
f0100d0a:	68 54 60 10 f0       	push   $0xf0106054
f0100d0f:	6a 58                	push   $0x58
f0100d11:	68 a4 65 10 f0       	push   $0xf01065a4
f0100d16:	e8 79 f3 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100d1b:	68 38 69 10 f0       	push   $0xf0106938
f0100d20:	68 be 65 10 f0       	push   $0xf01065be
f0100d25:	68 f3 02 00 00       	push   $0x2f3
f0100d2a:	68 91 65 10 f0       	push   $0xf0106591
f0100d2f:	e8 60 f3 ff ff       	call   f0100094 <_panic>
			++nfree_basemem;
f0100d34:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100d38:	8b 12                	mov    (%edx),%edx
f0100d3a:	85 d2                	test   %edx,%edx
f0100d3c:	74 74                	je     f0100db2 <check_page_free_list+0x236>
		assert(pp >= pages);
f0100d3e:	39 d1                	cmp    %edx,%ecx
f0100d40:	0f 87 fb fe ff ff    	ja     f0100c41 <check_page_free_list+0xc5>
		assert(pp < pages + npages);
f0100d46:	39 d6                	cmp    %edx,%esi
f0100d48:	0f 86 0c ff ff ff    	jbe    f0100c5a <check_page_free_list+0xde>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100d4e:	89 d0                	mov    %edx,%eax
f0100d50:	29 c8                	sub    %ecx,%eax
f0100d52:	a8 07                	test   $0x7,%al
f0100d54:	0f 85 19 ff ff ff    	jne    f0100c73 <check_page_free_list+0xf7>
	return (pp - pages) << PGSHIFT;
f0100d5a:	c1 f8 03             	sar    $0x3,%eax
		assert(page2pa(pp) != 0);
f0100d5d:	c1 e0 0c             	shl    $0xc,%eax
f0100d60:	0f 84 26 ff ff ff    	je     f0100c8c <check_page_free_list+0x110>
		assert(page2pa(pp) != IOPHYSMEM);
f0100d66:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100d6b:	0f 84 34 ff ff ff    	je     f0100ca5 <check_page_free_list+0x129>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100d71:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100d76:	0f 84 42 ff ff ff    	je     f0100cbe <check_page_free_list+0x142>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100d7c:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100d81:	0f 84 50 ff ff ff    	je     f0100cd7 <check_page_free_list+0x15b>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100d87:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100d8c:	0f 87 5e ff ff ff    	ja     f0100cf0 <check_page_free_list+0x174>
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100d92:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100d97:	75 9b                	jne    f0100d34 <check_page_free_list+0x1b8>
f0100d99:	68 2b 66 10 f0       	push   $0xf010662b
f0100d9e:	68 be 65 10 f0       	push   $0xf01065be
f0100da3:	68 f5 02 00 00       	push   $0x2f5
f0100da8:	68 91 65 10 f0       	push   $0xf0106591
f0100dad:	e8 e2 f2 ff ff       	call   f0100094 <_panic>
f0100db2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
	assert(nfree_basemem > 0);
f0100db5:	85 db                	test   %ebx,%ebx
f0100db7:	7e 19                	jle    f0100dd2 <check_page_free_list+0x256>
	assert(nfree_extmem > 0);
f0100db9:	85 ff                	test   %edi,%edi
f0100dbb:	7e 2e                	jle    f0100deb <check_page_free_list+0x26f>
	cprintf("check_page_free_list() succeeded!\n");
f0100dbd:	83 ec 0c             	sub    $0xc,%esp
f0100dc0:	68 80 69 10 f0       	push   $0xf0106980
f0100dc5:	e8 56 2a 00 00       	call   f0103820 <cprintf>
}
f0100dca:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100dcd:	5b                   	pop    %ebx
f0100dce:	5e                   	pop    %esi
f0100dcf:	5f                   	pop    %edi
f0100dd0:	5d                   	pop    %ebp
f0100dd1:	c3                   	ret    
	assert(nfree_basemem > 0);
f0100dd2:	68 48 66 10 f0       	push   $0xf0106648
f0100dd7:	68 be 65 10 f0       	push   $0xf01065be
f0100ddc:	68 fd 02 00 00       	push   $0x2fd
f0100de1:	68 91 65 10 f0       	push   $0xf0106591
f0100de6:	e8 a9 f2 ff ff       	call   f0100094 <_panic>
	assert(nfree_extmem > 0);
f0100deb:	68 5a 66 10 f0       	push   $0xf010665a
f0100df0:	68 be 65 10 f0       	push   $0xf01065be
f0100df5:	68 fe 02 00 00       	push   $0x2fe
f0100dfa:	68 91 65 10 f0       	push   $0xf0106591
f0100dff:	e8 90 f2 ff ff       	call   f0100094 <_panic>
	if (!page_free_list)
f0100e04:	a1 3c 52 23 f0       	mov    0xf023523c,%eax
f0100e09:	85 c0                	test   %eax,%eax
f0100e0b:	0f 84 8f fd ff ff    	je     f0100ba0 <check_page_free_list+0x24>
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100e11:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100e14:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100e17:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100e1a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100e1d:	89 c2                	mov    %eax,%edx
f0100e1f:	2b 15 90 5e 23 f0    	sub    0xf0235e90,%edx
			pagetype = (PDX(page2pa(pp)) >= pdx_limit);
f0100e25:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100e2b:	0f 95 c2             	setne  %dl
f0100e2e:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100e31:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100e35:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100e37:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100e3b:	8b 00                	mov    (%eax),%eax
f0100e3d:	85 c0                	test   %eax,%eax
f0100e3f:	75 dc                	jne    f0100e1d <check_page_free_list+0x2a1>
		cprintf("end%p\n",pp);
f0100e41:	83 ec 08             	sub    $0x8,%esp
f0100e44:	6a 00                	push   $0x0
f0100e46:	68 9d 65 10 f0       	push   $0xf010659d
f0100e4b:	e8 d0 29 00 00       	call   f0103820 <cprintf>
		*tp[1] = 0;
f0100e50:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100e53:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100e59:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100e5c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100e5f:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100e61:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100e64:	a3 3c 52 23 f0       	mov    %eax,0xf023523c
f0100e69:	83 c4 10             	add    $0x10,%esp
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100e6c:	be 01 00 00 00       	mov    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100e71:	8b 1d 3c 52 23 f0    	mov    0xf023523c,%ebx
f0100e77:	e9 4f fd ff ff       	jmp    f0100bcb <check_page_free_list+0x4f>

f0100e7c <page_init>:
{
f0100e7c:	55                   	push   %ebp
f0100e7d:	89 e5                	mov    %esp,%ebp
f0100e7f:	57                   	push   %edi
f0100e80:	56                   	push   %esi
f0100e81:	53                   	push   %ebx
f0100e82:	83 ec 0c             	sub    $0xc,%esp
	pages[0].pp_ref = 1;
f0100e85:	a1 90 5e 23 f0       	mov    0xf0235e90,%eax
f0100e8a:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
    for (i = 1; i < npages_basemem; i++) {
f0100e90:	8b 35 40 52 23 f0    	mov    0xf0235240,%esi
f0100e96:	8b 1d 3c 52 23 f0    	mov    0xf023523c,%ebx
f0100e9c:	ba 00 00 00 00       	mov    $0x0,%edx
f0100ea1:	b8 01 00 00 00       	mov    $0x1,%eax
        page_free_list = &pages[i];
f0100ea6:	bf 01 00 00 00       	mov    $0x1,%edi
    for (i = 1; i < npages_basemem; i++) {
f0100eab:	eb 0f                	jmp    f0100ebc <page_init+0x40>
			 pages[i].pp_ref = 1;
f0100ead:	8b 0d 90 5e 23 f0    	mov    0xf0235e90,%ecx
f0100eb3:	66 c7 41 3c 01 00    	movw   $0x1,0x3c(%ecx)
    for (i = 1; i < npages_basemem; i++) {
f0100eb9:	83 c0 01             	add    $0x1,%eax
f0100ebc:	39 c6                	cmp    %eax,%esi
f0100ebe:	76 28                	jbe    f0100ee8 <page_init+0x6c>
		if (i == mp_page) {
f0100ec0:	83 f8 07             	cmp    $0x7,%eax
f0100ec3:	74 e8                	je     f0100ead <page_init+0x31>
f0100ec5:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
        pages[i].pp_ref = 0;
f0100ecc:	89 d1                	mov    %edx,%ecx
f0100ece:	03 0d 90 5e 23 f0    	add    0xf0235e90,%ecx
f0100ed4:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
        pages[i].pp_link = page_free_list;
f0100eda:	89 19                	mov    %ebx,(%ecx)
        page_free_list = &pages[i];
f0100edc:	89 d3                	mov    %edx,%ebx
f0100ede:	03 1d 90 5e 23 f0    	add    0xf0235e90,%ebx
f0100ee4:	89 fa                	mov    %edi,%edx
f0100ee6:	eb d1                	jmp    f0100eb9 <page_init+0x3d>
f0100ee8:	84 d2                	test   %dl,%dl
f0100eea:	74 06                	je     f0100ef2 <page_init+0x76>
f0100eec:	89 1d 3c 52 23 f0    	mov    %ebx,0xf023523c
	size_t first_free_address = PADDR(boot_alloc(0));
f0100ef2:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ef7:	e8 9f fb ff ff       	call   f0100a9b <boot_alloc>
	if ((uint32_t)kva < KERNBASE)
f0100efc:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100f01:	76 3b                	jbe    f0100f3e <page_init+0xc2>
	return (physaddr_t)kva - KERNBASE;
f0100f03:	8d 88 00 00 00 10    	lea    0x10000000(%eax),%ecx
        pages[i].pp_ref = 1;
f0100f09:	8b 15 90 5e 23 f0    	mov    0xf0235e90,%edx
f0100f0f:	8d 82 04 05 00 00    	lea    0x504(%edx),%eax
f0100f15:	81 c2 04 08 00 00    	add    $0x804,%edx
f0100f1b:	66 c7 00 01 00       	movw   $0x1,(%eax)
f0100f20:	83 c0 08             	add    $0x8,%eax
    for (i = IOPHYSMEM/PGSIZE; i < EXTPHYSMEM/PGSIZE; i++) {
f0100f23:	39 d0                	cmp    %edx,%eax
f0100f25:	75 f4                	jne    f0100f1b <page_init+0x9f>
    for (i = first_free_address/PGSIZE; i < npages; i++) {
f0100f27:	89 c8                	mov    %ecx,%eax
f0100f29:	c1 e8 0c             	shr    $0xc,%eax
f0100f2c:	8b 1d 3c 52 23 f0    	mov    0xf023523c,%ebx
f0100f32:	ba 00 00 00 00       	mov    $0x0,%edx
f0100f37:	be 01 00 00 00       	mov    $0x1,%esi
f0100f3c:	eb 39                	jmp    f0100f77 <page_init+0xfb>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100f3e:	50                   	push   %eax
f0100f3f:	68 78 60 10 f0       	push   $0xf0106078
f0100f44:	68 5d 01 00 00       	push   $0x15d
f0100f49:	68 91 65 10 f0       	push   $0xf0106591
f0100f4e:	e8 41 f1 ff ff       	call   f0100094 <_panic>
f0100f53:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
        pages[i].pp_ref = 0;
f0100f5a:	89 d1                	mov    %edx,%ecx
f0100f5c:	03 0d 90 5e 23 f0    	add    0xf0235e90,%ecx
f0100f62:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
        pages[i].pp_link = page_free_list;
f0100f68:	89 19                	mov    %ebx,(%ecx)
    for (i = first_free_address/PGSIZE; i < npages; i++) {
f0100f6a:	83 c0 01             	add    $0x1,%eax
        page_free_list = &pages[i];
f0100f6d:	89 d3                	mov    %edx,%ebx
f0100f6f:	03 1d 90 5e 23 f0    	add    0xf0235e90,%ebx
f0100f75:	89 f2                	mov    %esi,%edx
    for (i = first_free_address/PGSIZE; i < npages; i++) {
f0100f77:	39 05 88 5e 23 f0    	cmp    %eax,0xf0235e88
f0100f7d:	77 d4                	ja     f0100f53 <page_init+0xd7>
f0100f7f:	84 d2                	test   %dl,%dl
f0100f81:	74 06                	je     f0100f89 <page_init+0x10d>
f0100f83:	89 1d 3c 52 23 f0    	mov    %ebx,0xf023523c
}
f0100f89:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100f8c:	5b                   	pop    %ebx
f0100f8d:	5e                   	pop    %esi
f0100f8e:	5f                   	pop    %edi
f0100f8f:	5d                   	pop    %ebp
f0100f90:	c3                   	ret    

f0100f91 <page_alloc>:
{
f0100f91:	55                   	push   %ebp
f0100f92:	89 e5                	mov    %esp,%ebp
f0100f94:	53                   	push   %ebx
f0100f95:	83 ec 04             	sub    $0x4,%esp
	if (!page_free_list) {
f0100f98:	8b 1d 3c 52 23 f0    	mov    0xf023523c,%ebx
f0100f9e:	85 db                	test   %ebx,%ebx
f0100fa0:	74 13                	je     f0100fb5 <page_alloc+0x24>
	page_free_list = page->pp_link;
f0100fa2:	8b 03                	mov    (%ebx),%eax
f0100fa4:	a3 3c 52 23 f0       	mov    %eax,0xf023523c
	page->pp_link = NULL;
f0100fa9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (alloc_flags & ALLOC_ZERO) {
f0100faf:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100fb3:	75 07                	jne    f0100fbc <page_alloc+0x2b>
}
f0100fb5:	89 d8                	mov    %ebx,%eax
f0100fb7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100fba:	c9                   	leave  
f0100fbb:	c3                   	ret    
	return (pp - pages) << PGSHIFT;
f0100fbc:	89 d8                	mov    %ebx,%eax
f0100fbe:	2b 05 90 5e 23 f0    	sub    0xf0235e90,%eax
f0100fc4:	c1 f8 03             	sar    $0x3,%eax
f0100fc7:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0100fca:	89 c2                	mov    %eax,%edx
f0100fcc:	c1 ea 0c             	shr    $0xc,%edx
f0100fcf:	3b 15 88 5e 23 f0    	cmp    0xf0235e88,%edx
f0100fd5:	73 1a                	jae    f0100ff1 <page_alloc+0x60>
		memset(page2kva(page), 0, PGSIZE); 
f0100fd7:	83 ec 04             	sub    $0x4,%esp
f0100fda:	68 00 10 00 00       	push   $0x1000
f0100fdf:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f0100fe1:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100fe6:	50                   	push   %eax
f0100fe7:	e8 6f 43 00 00       	call   f010535b <memset>
f0100fec:	83 c4 10             	add    $0x10,%esp
f0100fef:	eb c4                	jmp    f0100fb5 <page_alloc+0x24>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ff1:	50                   	push   %eax
f0100ff2:	68 54 60 10 f0       	push   $0xf0106054
f0100ff7:	6a 58                	push   $0x58
f0100ff9:	68 a4 65 10 f0       	push   $0xf01065a4
f0100ffe:	e8 91 f0 ff ff       	call   f0100094 <_panic>

f0101003 <page_free>:
{
f0101003:	55                   	push   %ebp
f0101004:	89 e5                	mov    %esp,%ebp
f0101006:	83 ec 08             	sub    $0x8,%esp
f0101009:	8b 45 08             	mov    0x8(%ebp),%eax
	if (pp->pp_ref || pp->pp_link) {
f010100c:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101011:	75 14                	jne    f0101027 <page_free+0x24>
f0101013:	83 38 00             	cmpl   $0x0,(%eax)
f0101016:	75 0f                	jne    f0101027 <page_free+0x24>
	pp->pp_link = page_free_list;
f0101018:	8b 15 3c 52 23 f0    	mov    0xf023523c,%edx
f010101e:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0101020:	a3 3c 52 23 f0       	mov    %eax,0xf023523c
}
f0101025:	c9                   	leave  
f0101026:	c3                   	ret    
		panic("page_free: double check failed when dealloc page. '\n");
f0101027:	83 ec 04             	sub    $0x4,%esp
f010102a:	68 a4 69 10 f0       	push   $0xf01069a4
f010102f:	68 98 01 00 00       	push   $0x198
f0101034:	68 91 65 10 f0       	push   $0xf0106591
f0101039:	e8 56 f0 ff ff       	call   f0100094 <_panic>

f010103e <page_decref>:
{
f010103e:	55                   	push   %ebp
f010103f:	89 e5                	mov    %esp,%ebp
f0101041:	83 ec 08             	sub    $0x8,%esp
f0101044:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0101047:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f010104b:	83 e8 01             	sub    $0x1,%eax
f010104e:	66 89 42 04          	mov    %ax,0x4(%edx)
f0101052:	66 85 c0             	test   %ax,%ax
f0101055:	74 02                	je     f0101059 <page_decref+0x1b>
}
f0101057:	c9                   	leave  
f0101058:	c3                   	ret    
		page_free(pp);
f0101059:	83 ec 0c             	sub    $0xc,%esp
f010105c:	52                   	push   %edx
f010105d:	e8 a1 ff ff ff       	call   f0101003 <page_free>
f0101062:	83 c4 10             	add    $0x10,%esp
}
f0101065:	eb f0                	jmp    f0101057 <page_decref+0x19>

f0101067 <pgdir_walk>:
{
f0101067:	55                   	push   %ebp
f0101068:	89 e5                	mov    %esp,%ebp
f010106a:	56                   	push   %esi
f010106b:	53                   	push   %ebx
f010106c:	8b 45 0c             	mov    0xc(%ebp),%eax
	uint32_t ptx = PTX(va);		
f010106f:	89 c6                	mov    %eax,%esi
f0101071:	c1 ee 0c             	shr    $0xc,%esi
f0101074:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
	uint32_t pdx = PDX(va);		
f010107a:	c1 e8 16             	shr    $0x16,%eax
	if (pgdir[pdx] & PTE_P) {
f010107d:	8d 1c 85 00 00 00 00 	lea    0x0(,%eax,4),%ebx
f0101084:	03 5d 08             	add    0x8(%ebp),%ebx
f0101087:	8b 03                	mov    (%ebx),%eax
f0101089:	a8 01                	test   $0x1,%al
f010108b:	74 36                	je     f01010c3 <pgdir_walk+0x5c>
		pgtab = KADDR(PTE_ADDR(pgdir[pdx]));
f010108d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0101092:	89 c2                	mov    %eax,%edx
f0101094:	c1 ea 0c             	shr    $0xc,%edx
f0101097:	39 15 88 5e 23 f0    	cmp    %edx,0xf0235e88
f010109d:	76 0f                	jbe    f01010ae <pgdir_walk+0x47>
	return (void *)(pa + KERNBASE);
f010109f:	2d 00 00 00 10       	sub    $0x10000000,%eax
	return &pgtab[ptx];
f01010a4:	8d 04 b0             	lea    (%eax,%esi,4),%eax
}
f01010a7:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01010aa:	5b                   	pop    %ebx
f01010ab:	5e                   	pop    %esi
f01010ac:	5d                   	pop    %ebp
f01010ad:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01010ae:	50                   	push   %eax
f01010af:	68 54 60 10 f0       	push   $0xf0106054
f01010b4:	68 c8 01 00 00       	push   $0x1c8
f01010b9:	68 91 65 10 f0       	push   $0xf0106591
f01010be:	e8 d1 ef ff ff       	call   f0100094 <_panic>
		if (create) {
f01010c3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01010c7:	74 50                	je     f0101119 <pgdir_walk+0xb2>
			struct PageInfo *new_pginfo = page_alloc(ALLOC_ZERO);	
f01010c9:	83 ec 0c             	sub    $0xc,%esp
f01010cc:	6a 01                	push   $0x1
f01010ce:	e8 be fe ff ff       	call   f0100f91 <page_alloc>
			if (new_pginfo) {
f01010d3:	83 c4 10             	add    $0x10,%esp
f01010d6:	85 c0                	test   %eax,%eax
f01010d8:	74 46                	je     f0101120 <pgdir_walk+0xb9>
				new_pginfo->pp_ref += 1;
f01010da:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f01010df:	2b 05 90 5e 23 f0    	sub    0xf0235e90,%eax
f01010e5:	89 c2                	mov    %eax,%edx
f01010e7:	c1 fa 03             	sar    $0x3,%edx
f01010ea:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f01010ed:	89 d0                	mov    %edx,%eax
f01010ef:	c1 e8 0c             	shr    $0xc,%eax
f01010f2:	3b 05 88 5e 23 f0    	cmp    0xf0235e88,%eax
f01010f8:	73 0d                	jae    f0101107 <pgdir_walk+0xa0>
	return (void *)(pa + KERNBASE);
f01010fa:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
				pgdir[pdx] = page2pa(new_pginfo) | PTE_P | PTE_W | PTE_U;
f0101100:	83 ca 07             	or     $0x7,%edx
f0101103:	89 13                	mov    %edx,(%ebx)
f0101105:	eb 9d                	jmp    f01010a4 <pgdir_walk+0x3d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101107:	52                   	push   %edx
f0101108:	68 54 60 10 f0       	push   $0xf0106054
f010110d:	6a 58                	push   $0x58
f010110f:	68 a4 65 10 f0       	push   $0xf01065a4
f0101114:	e8 7b ef ff ff       	call   f0100094 <_panic>
			return NULL;
f0101119:	b8 00 00 00 00       	mov    $0x0,%eax
f010111e:	eb 87                	jmp    f01010a7 <pgdir_walk+0x40>
			return NULL; 
f0101120:	b8 00 00 00 00       	mov    $0x0,%eax
f0101125:	eb 80                	jmp    f01010a7 <pgdir_walk+0x40>

f0101127 <boot_map_region>:
{
f0101127:	55                   	push   %ebp
f0101128:	89 e5                	mov    %esp,%ebp
f010112a:	57                   	push   %edi
f010112b:	56                   	push   %esi
f010112c:	53                   	push   %ebx
f010112d:	83 ec 1c             	sub    $0x1c,%esp
f0101130:	89 c7                	mov    %eax,%edi
f0101132:	8b 45 08             	mov    0x8(%ebp),%eax
f0101135:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f010113b:	01 c1                	add    %eax,%ecx
f010113d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	for (size_t i = 0;i < pg_num; i++) {
f0101140:	89 c3                	mov    %eax,%ebx
		pte = pgdir_walk(pgdir, (void *)va, 1);		 
f0101142:	89 d6                	mov    %edx,%esi
f0101144:	29 c6                	sub    %eax,%esi
	for (size_t i = 0;i < pg_num; i++) {
f0101146:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0101149:	74 28                	je     f0101173 <boot_map_region+0x4c>
		pte = pgdir_walk(pgdir, (void *)va, 1);		 
f010114b:	83 ec 04             	sub    $0x4,%esp
f010114e:	6a 01                	push   $0x1
f0101150:	8d 04 1e             	lea    (%esi,%ebx,1),%eax
f0101153:	50                   	push   %eax
f0101154:	57                   	push   %edi
f0101155:	e8 0d ff ff ff       	call   f0101067 <pgdir_walk>
		if (!pte) {
f010115a:	83 c4 10             	add    $0x10,%esp
f010115d:	85 c0                	test   %eax,%eax
f010115f:	74 12                	je     f0101173 <boot_map_region+0x4c>
		*pte = pa | perm | PTE_P;
f0101161:	89 da                	mov    %ebx,%edx
f0101163:	0b 55 0c             	or     0xc(%ebp),%edx
f0101166:	83 ca 01             	or     $0x1,%edx
f0101169:	89 10                	mov    %edx,(%eax)
		pa += PGSIZE;
f010116b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0101171:	eb d3                	jmp    f0101146 <boot_map_region+0x1f>
}
f0101173:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101176:	5b                   	pop    %ebx
f0101177:	5e                   	pop    %esi
f0101178:	5f                   	pop    %edi
f0101179:	5d                   	pop    %ebp
f010117a:	c3                   	ret    

f010117b <page_lookup>:
{
f010117b:	55                   	push   %ebp
f010117c:	89 e5                	mov    %esp,%ebp
f010117e:	83 ec 0c             	sub    $0xc,%esp
	pte_t *pte = pgdir_walk(pgdir, va, 0);
f0101181:	6a 00                	push   $0x0
f0101183:	ff 75 0c             	pushl  0xc(%ebp)
f0101186:	ff 75 08             	pushl  0x8(%ebp)
f0101189:	e8 d9 fe ff ff       	call   f0101067 <pgdir_walk>
	if (!pte) {
f010118e:	83 c4 10             	add    $0x10,%esp
f0101191:	85 c0                	test   %eax,%eax
f0101193:	74 3b                	je     f01011d0 <page_lookup+0x55>
		*pte_store = pte;
f0101195:	8b 55 10             	mov    0x10(%ebp),%edx
f0101198:	89 02                	mov    %eax,(%edx)
	 	if (*pte) {
f010119a:	8b 10                	mov    (%eax),%edx
	return NULL;
f010119c:	b8 00 00 00 00       	mov    $0x0,%eax
	 	if (*pte) {
f01011a1:	85 d2                	test   %edx,%edx
f01011a3:	75 02                	jne    f01011a7 <page_lookup+0x2c>
}
f01011a5:	c9                   	leave  
f01011a6:	c3                   	ret    
f01011a7:	c1 ea 0c             	shr    $0xc,%edx
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01011aa:	39 15 88 5e 23 f0    	cmp    %edx,0xf0235e88
f01011b0:	76 0a                	jbe    f01011bc <page_lookup+0x41>
		panic("pa2page called with invalid pa");
	return &pages[PGNUM(pa)];
f01011b2:	a1 90 5e 23 f0       	mov    0xf0235e90,%eax
f01011b7:	8d 04 d0             	lea    (%eax,%edx,8),%eax
			return pa2page(PTE_ADDR(*pte)); 
f01011ba:	eb e9                	jmp    f01011a5 <page_lookup+0x2a>
		panic("pa2page called with invalid pa");
f01011bc:	83 ec 04             	sub    $0x4,%esp
f01011bf:	68 dc 69 10 f0       	push   $0xf01069dc
f01011c4:	6a 51                	push   $0x51
f01011c6:	68 a4 65 10 f0       	push   $0xf01065a4
f01011cb:	e8 c4 ee ff ff       	call   f0100094 <_panic>
		 return NULL;
f01011d0:	b8 00 00 00 00       	mov    $0x0,%eax
f01011d5:	eb ce                	jmp    f01011a5 <page_lookup+0x2a>

f01011d7 <tlb_invalidate>:
{
f01011d7:	55                   	push   %ebp
f01011d8:	89 e5                	mov    %esp,%ebp
f01011da:	83 ec 08             	sub    $0x8,%esp
	if (!curenv || curenv->env_pgdir == pgdir)
f01011dd:	e8 78 47 00 00       	call   f010595a <cpunum>
f01011e2:	6b c0 74             	imul   $0x74,%eax,%eax
f01011e5:	83 b8 28 60 23 f0 00 	cmpl   $0x0,-0xfdc9fd8(%eax)
f01011ec:	74 16                	je     f0101204 <tlb_invalidate+0x2d>
f01011ee:	e8 67 47 00 00       	call   f010595a <cpunum>
f01011f3:	6b c0 74             	imul   $0x74,%eax,%eax
f01011f6:	8b 80 28 60 23 f0    	mov    -0xfdc9fd8(%eax),%eax
f01011fc:	8b 55 08             	mov    0x8(%ebp),%edx
f01011ff:	39 50 60             	cmp    %edx,0x60(%eax)
f0101202:	75 06                	jne    f010120a <tlb_invalidate+0x33>
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101204:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101207:	0f 01 38             	invlpg (%eax)
}
f010120a:	c9                   	leave  
f010120b:	c3                   	ret    

f010120c <page_remove>:
{
f010120c:	55                   	push   %ebp
f010120d:	89 e5                	mov    %esp,%ebp
f010120f:	56                   	push   %esi
f0101210:	53                   	push   %ebx
f0101211:	83 ec 14             	sub    $0x14,%esp
f0101214:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0101217:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct PageInfo *pginfo = page_lookup(pgdir, va, pte_store);
f010121a:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010121d:	50                   	push   %eax
f010121e:	56                   	push   %esi
f010121f:	53                   	push   %ebx
f0101220:	e8 56 ff ff ff       	call   f010117b <page_lookup>
	if (pginfo) {
f0101225:	83 c4 10             	add    $0x10,%esp
f0101228:	85 c0                	test   %eax,%eax
f010122a:	74 1f                	je     f010124b <page_remove+0x3f>
		page_decref(pginfo);
f010122c:	83 ec 0c             	sub    $0xc,%esp
f010122f:	50                   	push   %eax
f0101230:	e8 09 fe ff ff       	call   f010103e <page_decref>
		*pte = 0;	 
f0101235:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101238:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		tlb_invalidate(pgdir, va);
f010123e:	83 c4 08             	add    $0x8,%esp
f0101241:	56                   	push   %esi
f0101242:	53                   	push   %ebx
f0101243:	e8 8f ff ff ff       	call   f01011d7 <tlb_invalidate>
f0101248:	83 c4 10             	add    $0x10,%esp
}
f010124b:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010124e:	5b                   	pop    %ebx
f010124f:	5e                   	pop    %esi
f0101250:	5d                   	pop    %ebp
f0101251:	c3                   	ret    

f0101252 <page_insert>:
{
f0101252:	55                   	push   %ebp
f0101253:	89 e5                	mov    %esp,%ebp
f0101255:	57                   	push   %edi
f0101256:	56                   	push   %esi
f0101257:	53                   	push   %ebx
f0101258:	83 ec 10             	sub    $0x10,%esp
f010125b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010125e:	8b 7d 10             	mov    0x10(%ebp),%edi
	pte_t *pte = pgdir_walk(pgdir, va, 1);	
f0101261:	6a 01                	push   $0x1
f0101263:	57                   	push   %edi
f0101264:	ff 75 08             	pushl  0x8(%ebp)
f0101267:	e8 fb fd ff ff       	call   f0101067 <pgdir_walk>
	if (!pte) {
f010126c:	83 c4 10             	add    $0x10,%esp
f010126f:	85 c0                	test   %eax,%eax
f0101271:	74 3e                	je     f01012b1 <page_insert+0x5f>
f0101273:	89 c6                	mov    %eax,%esi
	pp->pp_ref++;
f0101275:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
	if (*pte & PTE_P) {
f010127a:	f6 00 01             	testb  $0x1,(%eax)
f010127d:	75 21                	jne    f01012a0 <page_insert+0x4e>
	return (pp - pages) << PGSHIFT;
f010127f:	2b 1d 90 5e 23 f0    	sub    0xf0235e90,%ebx
f0101285:	c1 fb 03             	sar    $0x3,%ebx
f0101288:	c1 e3 0c             	shl    $0xc,%ebx
	*pte = page2pa(pp) | perm | PTE_P;
f010128b:	0b 5d 14             	or     0x14(%ebp),%ebx
f010128e:	83 cb 01             	or     $0x1,%ebx
f0101291:	89 1e                	mov    %ebx,(%esi)
	return 0;
f0101293:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101298:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010129b:	5b                   	pop    %ebx
f010129c:	5e                   	pop    %esi
f010129d:	5f                   	pop    %edi
f010129e:	5d                   	pop    %ebp
f010129f:	c3                   	ret    
		 page_remove(pgdir, va);
f01012a0:	83 ec 08             	sub    $0x8,%esp
f01012a3:	57                   	push   %edi
f01012a4:	ff 75 08             	pushl  0x8(%ebp)
f01012a7:	e8 60 ff ff ff       	call   f010120c <page_remove>
f01012ac:	83 c4 10             	add    $0x10,%esp
f01012af:	eb ce                	jmp    f010127f <page_insert+0x2d>
		 return -E_NO_MEM;
f01012b1:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01012b6:	eb e0                	jmp    f0101298 <page_insert+0x46>

f01012b8 <mmio_map_region>:
{
f01012b8:	55                   	push   %ebp
f01012b9:	89 e5                	mov    %esp,%ebp
f01012bb:	53                   	push   %ebx
f01012bc:	83 ec 04             	sub    $0x4,%esp
    size_t rounded_size = ROUNDUP(size, PGSIZE);
f01012bf:	8b 45 0c             	mov    0xc(%ebp),%eax
f01012c2:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
f01012c8:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    if (base + rounded_size > MMIOLIM || base + rounded_size < base) panic("memory overflow\n ");
f01012ce:	8b 15 00 23 12 f0    	mov    0xf0122300,%edx
f01012d4:	89 d0                	mov    %edx,%eax
f01012d6:	01 d8                	add    %ebx,%eax
f01012d8:	72 2d                	jb     f0101307 <mmio_map_region+0x4f>
f01012da:	3d 00 00 c0 ef       	cmp    $0xefc00000,%eax
f01012df:	77 26                	ja     f0101307 <mmio_map_region+0x4f>
    boot_map_region(kern_pgdir, base, rounded_size, pa, PTE_W|PTE_PCD|PTE_PWT);
f01012e1:	83 ec 08             	sub    $0x8,%esp
f01012e4:	6a 1a                	push   $0x1a
f01012e6:	ff 75 08             	pushl  0x8(%ebp)
f01012e9:	89 d9                	mov    %ebx,%ecx
f01012eb:	a1 8c 5e 23 f0       	mov    0xf0235e8c,%eax
f01012f0:	e8 32 fe ff ff       	call   f0101127 <boot_map_region>
    uintptr_t return_base = base;
f01012f5:	a1 00 23 12 f0       	mov    0xf0122300,%eax
    base += rounded_size;
f01012fa:	01 c3                	add    %eax,%ebx
f01012fc:	89 1d 00 23 12 f0    	mov    %ebx,0xf0122300
}
f0101302:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101305:	c9                   	leave  
f0101306:	c3                   	ret    
    if (base + rounded_size > MMIOLIM || base + rounded_size < base) panic("memory overflow\n ");
f0101307:	83 ec 04             	sub    $0x4,%esp
f010130a:	68 6b 66 10 f0       	push   $0xf010666b
f010130f:	68 86 02 00 00       	push   $0x286
f0101314:	68 91 65 10 f0       	push   $0xf0106591
f0101319:	e8 76 ed ff ff       	call   f0100094 <_panic>

f010131e <mem_init>:
{
f010131e:	55                   	push   %ebp
f010131f:	89 e5                	mov    %esp,%ebp
f0101321:	57                   	push   %edi
f0101322:	56                   	push   %esi
f0101323:	53                   	push   %ebx
f0101324:	83 ec 3c             	sub    $0x3c,%esp
	basemem = nvram_read(NVRAM_BASELO);
f0101327:	b8 15 00 00 00       	mov    $0x15,%eax
f010132c:	e8 be f7 ff ff       	call   f0100aef <nvram_read>
f0101331:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f0101333:	b8 17 00 00 00       	mov    $0x17,%eax
f0101338:	e8 b2 f7 ff ff       	call   f0100aef <nvram_read>
f010133d:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f010133f:	b8 34 00 00 00       	mov    $0x34,%eax
f0101344:	e8 a6 f7 ff ff       	call   f0100aef <nvram_read>
	if (ext16mem)
f0101349:	c1 e0 06             	shl    $0x6,%eax
f010134c:	0f 84 ea 00 00 00    	je     f010143c <mem_init+0x11e>
		totalmem = 16 * 1024 + ext16mem;
f0101352:	05 00 40 00 00       	add    $0x4000,%eax
	npages = totalmem / (PGSIZE / 1024);
f0101357:	89 c2                	mov    %eax,%edx
f0101359:	c1 ea 02             	shr    $0x2,%edx
f010135c:	89 15 88 5e 23 f0    	mov    %edx,0xf0235e88
	npages_basemem = basemem / (PGSIZE / 1024);
f0101362:	89 da                	mov    %ebx,%edx
f0101364:	c1 ea 02             	shr    $0x2,%edx
f0101367:	89 15 40 52 23 f0    	mov    %edx,0xf0235240
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010136d:	89 c2                	mov    %eax,%edx
f010136f:	29 da                	sub    %ebx,%edx
f0101371:	52                   	push   %edx
f0101372:	53                   	push   %ebx
f0101373:	50                   	push   %eax
f0101374:	68 fc 69 10 f0       	push   $0xf01069fc
f0101379:	e8 a2 24 00 00       	call   f0103820 <cprintf>
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f010137e:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101383:	e8 13 f7 ff ff       	call   f0100a9b <boot_alloc>
f0101388:	a3 8c 5e 23 f0       	mov    %eax,0xf0235e8c
	memset(kern_pgdir, 0, PGSIZE);
f010138d:	83 c4 0c             	add    $0xc,%esp
f0101390:	68 00 10 00 00       	push   $0x1000
f0101395:	6a 00                	push   $0x0
f0101397:	50                   	push   %eax
f0101398:	e8 be 3f 00 00       	call   f010535b <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f010139d:	a1 8c 5e 23 f0       	mov    0xf0235e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f01013a2:	83 c4 10             	add    $0x10,%esp
f01013a5:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01013aa:	0f 86 9c 00 00 00    	jbe    f010144c <mem_init+0x12e>
	return (physaddr_t)kva - KERNBASE;
f01013b0:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01013b6:	83 ca 05             	or     $0x5,%edx
f01013b9:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	pages = (struct PageInfo*) boot_alloc(npages * sizeof(struct PageInfo));
f01013bf:	a1 88 5e 23 f0       	mov    0xf0235e88,%eax
f01013c4:	c1 e0 03             	shl    $0x3,%eax
f01013c7:	e8 cf f6 ff ff       	call   f0100a9b <boot_alloc>
f01013cc:	a3 90 5e 23 f0       	mov    %eax,0xf0235e90
	memset(pages, 0, npages * sizeof(struct PageInfo));
f01013d1:	83 ec 04             	sub    $0x4,%esp
f01013d4:	8b 0d 88 5e 23 f0    	mov    0xf0235e88,%ecx
f01013da:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f01013e1:	52                   	push   %edx
f01013e2:	6a 00                	push   $0x0
f01013e4:	50                   	push   %eax
f01013e5:	e8 71 3f 00 00       	call   f010535b <memset>
	envs = (struct Env*) boot_alloc(NENV * sizeof(struct Env));
f01013ea:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f01013ef:	e8 a7 f6 ff ff       	call   f0100a9b <boot_alloc>
f01013f4:	a3 44 52 23 f0       	mov    %eax,0xf0235244
	memset(envs, 0, NENV * sizeof(struct Env));
f01013f9:	83 c4 0c             	add    $0xc,%esp
f01013fc:	68 00 f0 01 00       	push   $0x1f000
f0101401:	6a 00                	push   $0x0
f0101403:	50                   	push   %eax
f0101404:	e8 52 3f 00 00       	call   f010535b <memset>
	page_init();
f0101409:	e8 6e fa ff ff       	call   f0100e7c <page_init>
	check_page_free_list(1);
f010140e:	b8 01 00 00 00       	mov    $0x1,%eax
f0101413:	e8 64 f7 ff ff       	call   f0100b7c <check_page_free_list>
	if (!pages)
f0101418:	83 c4 10             	add    $0x10,%esp
f010141b:	83 3d 90 5e 23 f0 00 	cmpl   $0x0,0xf0235e90
f0101422:	74 3d                	je     f0101461 <mem_init+0x143>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101424:	a1 3c 52 23 f0       	mov    0xf023523c,%eax
f0101429:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f0101430:	85 c0                	test   %eax,%eax
f0101432:	74 44                	je     f0101478 <mem_init+0x15a>
		++nfree;
f0101434:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101438:	8b 00                	mov    (%eax),%eax
f010143a:	eb f4                	jmp    f0101430 <mem_init+0x112>
		totalmem = 1 * 1024 + extmem;
f010143c:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f0101442:	85 f6                	test   %esi,%esi
f0101444:	0f 44 c3             	cmove  %ebx,%eax
f0101447:	e9 0b ff ff ff       	jmp    f0101357 <mem_init+0x39>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010144c:	50                   	push   %eax
f010144d:	68 78 60 10 f0       	push   $0xf0106078
f0101452:	68 a4 00 00 00       	push   $0xa4
f0101457:	68 91 65 10 f0       	push   $0xf0106591
f010145c:	e8 33 ec ff ff       	call   f0100094 <_panic>
		panic("'pages' is a null pointer!");
f0101461:	83 ec 04             	sub    $0x4,%esp
f0101464:	68 7d 66 10 f0       	push   $0xf010667d
f0101469:	68 11 03 00 00       	push   $0x311
f010146e:	68 91 65 10 f0       	push   $0xf0106591
f0101473:	e8 1c ec ff ff       	call   f0100094 <_panic>
	assert((pp0 = page_alloc(0)));
f0101478:	83 ec 0c             	sub    $0xc,%esp
f010147b:	6a 00                	push   $0x0
f010147d:	e8 0f fb ff ff       	call   f0100f91 <page_alloc>
f0101482:	89 c3                	mov    %eax,%ebx
f0101484:	83 c4 10             	add    $0x10,%esp
f0101487:	85 c0                	test   %eax,%eax
f0101489:	0f 84 00 02 00 00    	je     f010168f <mem_init+0x371>
	assert((pp1 = page_alloc(0)));
f010148f:	83 ec 0c             	sub    $0xc,%esp
f0101492:	6a 00                	push   $0x0
f0101494:	e8 f8 fa ff ff       	call   f0100f91 <page_alloc>
f0101499:	89 c6                	mov    %eax,%esi
f010149b:	83 c4 10             	add    $0x10,%esp
f010149e:	85 c0                	test   %eax,%eax
f01014a0:	0f 84 02 02 00 00    	je     f01016a8 <mem_init+0x38a>
	assert((pp2 = page_alloc(0)));
f01014a6:	83 ec 0c             	sub    $0xc,%esp
f01014a9:	6a 00                	push   $0x0
f01014ab:	e8 e1 fa ff ff       	call   f0100f91 <page_alloc>
f01014b0:	89 c7                	mov    %eax,%edi
f01014b2:	83 c4 10             	add    $0x10,%esp
f01014b5:	85 c0                	test   %eax,%eax
f01014b7:	0f 84 04 02 00 00    	je     f01016c1 <mem_init+0x3a3>
	assert(pp1 && pp1 != pp0);
f01014bd:	39 f3                	cmp    %esi,%ebx
f01014bf:	0f 84 15 02 00 00    	je     f01016da <mem_init+0x3bc>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01014c5:	39 c6                	cmp    %eax,%esi
f01014c7:	0f 84 26 02 00 00    	je     f01016f3 <mem_init+0x3d5>
f01014cd:	39 c3                	cmp    %eax,%ebx
f01014cf:	0f 84 1e 02 00 00    	je     f01016f3 <mem_init+0x3d5>
	return (pp - pages) << PGSHIFT;
f01014d5:	8b 0d 90 5e 23 f0    	mov    0xf0235e90,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f01014db:	8b 15 88 5e 23 f0    	mov    0xf0235e88,%edx
f01014e1:	c1 e2 0c             	shl    $0xc,%edx
f01014e4:	89 d8                	mov    %ebx,%eax
f01014e6:	29 c8                	sub    %ecx,%eax
f01014e8:	c1 f8 03             	sar    $0x3,%eax
f01014eb:	c1 e0 0c             	shl    $0xc,%eax
f01014ee:	39 d0                	cmp    %edx,%eax
f01014f0:	0f 83 16 02 00 00    	jae    f010170c <mem_init+0x3ee>
f01014f6:	89 f0                	mov    %esi,%eax
f01014f8:	29 c8                	sub    %ecx,%eax
f01014fa:	c1 f8 03             	sar    $0x3,%eax
f01014fd:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp1) < npages*PGSIZE);
f0101500:	39 c2                	cmp    %eax,%edx
f0101502:	0f 86 1d 02 00 00    	jbe    f0101725 <mem_init+0x407>
f0101508:	89 f8                	mov    %edi,%eax
f010150a:	29 c8                	sub    %ecx,%eax
f010150c:	c1 f8 03             	sar    $0x3,%eax
f010150f:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp2) < npages*PGSIZE);
f0101512:	39 c2                	cmp    %eax,%edx
f0101514:	0f 86 24 02 00 00    	jbe    f010173e <mem_init+0x420>
	fl = page_free_list;
f010151a:	a1 3c 52 23 f0       	mov    0xf023523c,%eax
f010151f:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101522:	c7 05 3c 52 23 f0 00 	movl   $0x0,0xf023523c
f0101529:	00 00 00 
	assert(!page_alloc(0));
f010152c:	83 ec 0c             	sub    $0xc,%esp
f010152f:	6a 00                	push   $0x0
f0101531:	e8 5b fa ff ff       	call   f0100f91 <page_alloc>
f0101536:	83 c4 10             	add    $0x10,%esp
f0101539:	85 c0                	test   %eax,%eax
f010153b:	0f 85 16 02 00 00    	jne    f0101757 <mem_init+0x439>
	page_free(pp0);
f0101541:	83 ec 0c             	sub    $0xc,%esp
f0101544:	53                   	push   %ebx
f0101545:	e8 b9 fa ff ff       	call   f0101003 <page_free>
	page_free(pp1);
f010154a:	89 34 24             	mov    %esi,(%esp)
f010154d:	e8 b1 fa ff ff       	call   f0101003 <page_free>
	page_free(pp2);
f0101552:	89 3c 24             	mov    %edi,(%esp)
f0101555:	e8 a9 fa ff ff       	call   f0101003 <page_free>
	assert((pp0 = page_alloc(0)));
f010155a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101561:	e8 2b fa ff ff       	call   f0100f91 <page_alloc>
f0101566:	89 c3                	mov    %eax,%ebx
f0101568:	83 c4 10             	add    $0x10,%esp
f010156b:	85 c0                	test   %eax,%eax
f010156d:	0f 84 fd 01 00 00    	je     f0101770 <mem_init+0x452>
	assert((pp1 = page_alloc(0)));
f0101573:	83 ec 0c             	sub    $0xc,%esp
f0101576:	6a 00                	push   $0x0
f0101578:	e8 14 fa ff ff       	call   f0100f91 <page_alloc>
f010157d:	89 c6                	mov    %eax,%esi
f010157f:	83 c4 10             	add    $0x10,%esp
f0101582:	85 c0                	test   %eax,%eax
f0101584:	0f 84 ff 01 00 00    	je     f0101789 <mem_init+0x46b>
	assert((pp2 = page_alloc(0)));
f010158a:	83 ec 0c             	sub    $0xc,%esp
f010158d:	6a 00                	push   $0x0
f010158f:	e8 fd f9 ff ff       	call   f0100f91 <page_alloc>
f0101594:	89 c7                	mov    %eax,%edi
f0101596:	83 c4 10             	add    $0x10,%esp
f0101599:	85 c0                	test   %eax,%eax
f010159b:	0f 84 01 02 00 00    	je     f01017a2 <mem_init+0x484>
	assert(pp1 && pp1 != pp0);
f01015a1:	39 f3                	cmp    %esi,%ebx
f01015a3:	0f 84 12 02 00 00    	je     f01017bb <mem_init+0x49d>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01015a9:	39 c3                	cmp    %eax,%ebx
f01015ab:	0f 84 23 02 00 00    	je     f01017d4 <mem_init+0x4b6>
f01015b1:	39 c6                	cmp    %eax,%esi
f01015b3:	0f 84 1b 02 00 00    	je     f01017d4 <mem_init+0x4b6>
	assert(!page_alloc(0));
f01015b9:	83 ec 0c             	sub    $0xc,%esp
f01015bc:	6a 00                	push   $0x0
f01015be:	e8 ce f9 ff ff       	call   f0100f91 <page_alloc>
f01015c3:	83 c4 10             	add    $0x10,%esp
f01015c6:	85 c0                	test   %eax,%eax
f01015c8:	0f 85 1f 02 00 00    	jne    f01017ed <mem_init+0x4cf>
f01015ce:	89 d8                	mov    %ebx,%eax
f01015d0:	2b 05 90 5e 23 f0    	sub    0xf0235e90,%eax
f01015d6:	c1 f8 03             	sar    $0x3,%eax
f01015d9:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f01015dc:	89 c2                	mov    %eax,%edx
f01015de:	c1 ea 0c             	shr    $0xc,%edx
f01015e1:	3b 15 88 5e 23 f0    	cmp    0xf0235e88,%edx
f01015e7:	0f 83 19 02 00 00    	jae    f0101806 <mem_init+0x4e8>
	memset(page2kva(pp0), 1, PGSIZE);
f01015ed:	83 ec 04             	sub    $0x4,%esp
f01015f0:	68 00 10 00 00       	push   $0x1000
f01015f5:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f01015f7:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01015fc:	50                   	push   %eax
f01015fd:	e8 59 3d 00 00       	call   f010535b <memset>
	page_free(pp0);
f0101602:	89 1c 24             	mov    %ebx,(%esp)
f0101605:	e8 f9 f9 ff ff       	call   f0101003 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f010160a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101611:	e8 7b f9 ff ff       	call   f0100f91 <page_alloc>
f0101616:	83 c4 10             	add    $0x10,%esp
f0101619:	85 c0                	test   %eax,%eax
f010161b:	0f 84 f7 01 00 00    	je     f0101818 <mem_init+0x4fa>
	assert(pp && pp0 == pp);
f0101621:	39 c3                	cmp    %eax,%ebx
f0101623:	0f 85 08 02 00 00    	jne    f0101831 <mem_init+0x513>
	return (pp - pages) << PGSHIFT;
f0101629:	2b 05 90 5e 23 f0    	sub    0xf0235e90,%eax
f010162f:	c1 f8 03             	sar    $0x3,%eax
f0101632:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0101635:	89 c2                	mov    %eax,%edx
f0101637:	c1 ea 0c             	shr    $0xc,%edx
f010163a:	3b 15 88 5e 23 f0    	cmp    0xf0235e88,%edx
f0101640:	0f 83 04 02 00 00    	jae    f010184a <mem_init+0x52c>
	return (void *)(pa + KERNBASE);
f0101646:	8d 90 00 00 00 f0    	lea    -0x10000000(%eax),%edx
f010164c:	2d 00 f0 ff 0f       	sub    $0xffff000,%eax
		assert(c[i] == 0);
f0101651:	80 3a 00             	cmpb   $0x0,(%edx)
f0101654:	0f 85 02 02 00 00    	jne    f010185c <mem_init+0x53e>
f010165a:	83 c2 01             	add    $0x1,%edx
	for (i = 0; i < PGSIZE; i++)
f010165d:	39 c2                	cmp    %eax,%edx
f010165f:	75 f0                	jne    f0101651 <mem_init+0x333>
	page_free_list = fl;
f0101661:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101664:	a3 3c 52 23 f0       	mov    %eax,0xf023523c
	page_free(pp0);
f0101669:	83 ec 0c             	sub    $0xc,%esp
f010166c:	53                   	push   %ebx
f010166d:	e8 91 f9 ff ff       	call   f0101003 <page_free>
	page_free(pp1);
f0101672:	89 34 24             	mov    %esi,(%esp)
f0101675:	e8 89 f9 ff ff       	call   f0101003 <page_free>
	page_free(pp2);
f010167a:	89 3c 24             	mov    %edi,(%esp)
f010167d:	e8 81 f9 ff ff       	call   f0101003 <page_free>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101682:	a1 3c 52 23 f0       	mov    0xf023523c,%eax
f0101687:	83 c4 10             	add    $0x10,%esp
f010168a:	e9 ec 01 00 00       	jmp    f010187b <mem_init+0x55d>
	assert((pp0 = page_alloc(0)));
f010168f:	68 98 66 10 f0       	push   $0xf0106698
f0101694:	68 be 65 10 f0       	push   $0xf01065be
f0101699:	68 19 03 00 00       	push   $0x319
f010169e:	68 91 65 10 f0       	push   $0xf0106591
f01016a3:	e8 ec e9 ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f01016a8:	68 ae 66 10 f0       	push   $0xf01066ae
f01016ad:	68 be 65 10 f0       	push   $0xf01065be
f01016b2:	68 1a 03 00 00       	push   $0x31a
f01016b7:	68 91 65 10 f0       	push   $0xf0106591
f01016bc:	e8 d3 e9 ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f01016c1:	68 c4 66 10 f0       	push   $0xf01066c4
f01016c6:	68 be 65 10 f0       	push   $0xf01065be
f01016cb:	68 1b 03 00 00       	push   $0x31b
f01016d0:	68 91 65 10 f0       	push   $0xf0106591
f01016d5:	e8 ba e9 ff ff       	call   f0100094 <_panic>
	assert(pp1 && pp1 != pp0);
f01016da:	68 da 66 10 f0       	push   $0xf01066da
f01016df:	68 be 65 10 f0       	push   $0xf01065be
f01016e4:	68 1e 03 00 00       	push   $0x31e
f01016e9:	68 91 65 10 f0       	push   $0xf0106591
f01016ee:	e8 a1 e9 ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01016f3:	68 38 6a 10 f0       	push   $0xf0106a38
f01016f8:	68 be 65 10 f0       	push   $0xf01065be
f01016fd:	68 1f 03 00 00       	push   $0x31f
f0101702:	68 91 65 10 f0       	push   $0xf0106591
f0101707:	e8 88 e9 ff ff       	call   f0100094 <_panic>
	assert(page2pa(pp0) < npages*PGSIZE);
f010170c:	68 ec 66 10 f0       	push   $0xf01066ec
f0101711:	68 be 65 10 f0       	push   $0xf01065be
f0101716:	68 20 03 00 00       	push   $0x320
f010171b:	68 91 65 10 f0       	push   $0xf0106591
f0101720:	e8 6f e9 ff ff       	call   f0100094 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0101725:	68 09 67 10 f0       	push   $0xf0106709
f010172a:	68 be 65 10 f0       	push   $0xf01065be
f010172f:	68 21 03 00 00       	push   $0x321
f0101734:	68 91 65 10 f0       	push   $0xf0106591
f0101739:	e8 56 e9 ff ff       	call   f0100094 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f010173e:	68 26 67 10 f0       	push   $0xf0106726
f0101743:	68 be 65 10 f0       	push   $0xf01065be
f0101748:	68 22 03 00 00       	push   $0x322
f010174d:	68 91 65 10 f0       	push   $0xf0106591
f0101752:	e8 3d e9 ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f0101757:	68 43 67 10 f0       	push   $0xf0106743
f010175c:	68 be 65 10 f0       	push   $0xf01065be
f0101761:	68 29 03 00 00       	push   $0x329
f0101766:	68 91 65 10 f0       	push   $0xf0106591
f010176b:	e8 24 e9 ff ff       	call   f0100094 <_panic>
	assert((pp0 = page_alloc(0)));
f0101770:	68 98 66 10 f0       	push   $0xf0106698
f0101775:	68 be 65 10 f0       	push   $0xf01065be
f010177a:	68 30 03 00 00       	push   $0x330
f010177f:	68 91 65 10 f0       	push   $0xf0106591
f0101784:	e8 0b e9 ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f0101789:	68 ae 66 10 f0       	push   $0xf01066ae
f010178e:	68 be 65 10 f0       	push   $0xf01065be
f0101793:	68 31 03 00 00       	push   $0x331
f0101798:	68 91 65 10 f0       	push   $0xf0106591
f010179d:	e8 f2 e8 ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f01017a2:	68 c4 66 10 f0       	push   $0xf01066c4
f01017a7:	68 be 65 10 f0       	push   $0xf01065be
f01017ac:	68 32 03 00 00       	push   $0x332
f01017b1:	68 91 65 10 f0       	push   $0xf0106591
f01017b6:	e8 d9 e8 ff ff       	call   f0100094 <_panic>
	assert(pp1 && pp1 != pp0);
f01017bb:	68 da 66 10 f0       	push   $0xf01066da
f01017c0:	68 be 65 10 f0       	push   $0xf01065be
f01017c5:	68 34 03 00 00       	push   $0x334
f01017ca:	68 91 65 10 f0       	push   $0xf0106591
f01017cf:	e8 c0 e8 ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01017d4:	68 38 6a 10 f0       	push   $0xf0106a38
f01017d9:	68 be 65 10 f0       	push   $0xf01065be
f01017de:	68 35 03 00 00       	push   $0x335
f01017e3:	68 91 65 10 f0       	push   $0xf0106591
f01017e8:	e8 a7 e8 ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f01017ed:	68 43 67 10 f0       	push   $0xf0106743
f01017f2:	68 be 65 10 f0       	push   $0xf01065be
f01017f7:	68 36 03 00 00       	push   $0x336
f01017fc:	68 91 65 10 f0       	push   $0xf0106591
f0101801:	e8 8e e8 ff ff       	call   f0100094 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101806:	50                   	push   %eax
f0101807:	68 54 60 10 f0       	push   $0xf0106054
f010180c:	6a 58                	push   $0x58
f010180e:	68 a4 65 10 f0       	push   $0xf01065a4
f0101813:	e8 7c e8 ff ff       	call   f0100094 <_panic>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101818:	68 52 67 10 f0       	push   $0xf0106752
f010181d:	68 be 65 10 f0       	push   $0xf01065be
f0101822:	68 3b 03 00 00       	push   $0x33b
f0101827:	68 91 65 10 f0       	push   $0xf0106591
f010182c:	e8 63 e8 ff ff       	call   f0100094 <_panic>
	assert(pp && pp0 == pp);
f0101831:	68 70 67 10 f0       	push   $0xf0106770
f0101836:	68 be 65 10 f0       	push   $0xf01065be
f010183b:	68 3c 03 00 00       	push   $0x33c
f0101840:	68 91 65 10 f0       	push   $0xf0106591
f0101845:	e8 4a e8 ff ff       	call   f0100094 <_panic>
f010184a:	50                   	push   %eax
f010184b:	68 54 60 10 f0       	push   $0xf0106054
f0101850:	6a 58                	push   $0x58
f0101852:	68 a4 65 10 f0       	push   $0xf01065a4
f0101857:	e8 38 e8 ff ff       	call   f0100094 <_panic>
		assert(c[i] == 0);
f010185c:	68 80 67 10 f0       	push   $0xf0106780
f0101861:	68 be 65 10 f0       	push   $0xf01065be
f0101866:	68 3f 03 00 00       	push   $0x33f
f010186b:	68 91 65 10 f0       	push   $0xf0106591
f0101870:	e8 1f e8 ff ff       	call   f0100094 <_panic>
		--nfree;
f0101875:	83 6d d4 01          	subl   $0x1,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101879:	8b 00                	mov    (%eax),%eax
f010187b:	85 c0                	test   %eax,%eax
f010187d:	75 f6                	jne    f0101875 <mem_init+0x557>
	assert(nfree == 0);
f010187f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0101883:	0f 85 65 09 00 00    	jne    f01021ee <mem_init+0xed0>
	cprintf("check_page_alloc() succeeded!\n");
f0101889:	83 ec 0c             	sub    $0xc,%esp
f010188c:	68 58 6a 10 f0       	push   $0xf0106a58
f0101891:	e8 8a 1f 00 00       	call   f0103820 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101896:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010189d:	e8 ef f6 ff ff       	call   f0100f91 <page_alloc>
f01018a2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01018a5:	83 c4 10             	add    $0x10,%esp
f01018a8:	85 c0                	test   %eax,%eax
f01018aa:	0f 84 57 09 00 00    	je     f0102207 <mem_init+0xee9>
	assert((pp1 = page_alloc(0)));
f01018b0:	83 ec 0c             	sub    $0xc,%esp
f01018b3:	6a 00                	push   $0x0
f01018b5:	e8 d7 f6 ff ff       	call   f0100f91 <page_alloc>
f01018ba:	89 c7                	mov    %eax,%edi
f01018bc:	83 c4 10             	add    $0x10,%esp
f01018bf:	85 c0                	test   %eax,%eax
f01018c1:	0f 84 59 09 00 00    	je     f0102220 <mem_init+0xf02>
	assert((pp2 = page_alloc(0)));
f01018c7:	83 ec 0c             	sub    $0xc,%esp
f01018ca:	6a 00                	push   $0x0
f01018cc:	e8 c0 f6 ff ff       	call   f0100f91 <page_alloc>
f01018d1:	89 c3                	mov    %eax,%ebx
f01018d3:	83 c4 10             	add    $0x10,%esp
f01018d6:	85 c0                	test   %eax,%eax
f01018d8:	0f 84 5b 09 00 00    	je     f0102239 <mem_init+0xf1b>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01018de:	39 7d d4             	cmp    %edi,-0x2c(%ebp)
f01018e1:	0f 84 6b 09 00 00    	je     f0102252 <mem_init+0xf34>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01018e7:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f01018ea:	0f 84 7b 09 00 00    	je     f010226b <mem_init+0xf4d>
f01018f0:	39 c7                	cmp    %eax,%edi
f01018f2:	0f 84 73 09 00 00    	je     f010226b <mem_init+0xf4d>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01018f8:	a1 3c 52 23 f0       	mov    0xf023523c,%eax
f01018fd:	89 45 cc             	mov    %eax,-0x34(%ebp)
	page_free_list = 0;
f0101900:	c7 05 3c 52 23 f0 00 	movl   $0x0,0xf023523c
f0101907:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f010190a:	83 ec 0c             	sub    $0xc,%esp
f010190d:	6a 00                	push   $0x0
f010190f:	e8 7d f6 ff ff       	call   f0100f91 <page_alloc>
f0101914:	83 c4 10             	add    $0x10,%esp
f0101917:	85 c0                	test   %eax,%eax
f0101919:	0f 85 65 09 00 00    	jne    f0102284 <mem_init+0xf66>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f010191f:	83 ec 04             	sub    $0x4,%esp
f0101922:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101925:	50                   	push   %eax
f0101926:	6a 00                	push   $0x0
f0101928:	ff 35 8c 5e 23 f0    	pushl  0xf0235e8c
f010192e:	e8 48 f8 ff ff       	call   f010117b <page_lookup>
f0101933:	83 c4 10             	add    $0x10,%esp
f0101936:	85 c0                	test   %eax,%eax
f0101938:	0f 85 5f 09 00 00    	jne    f010229d <mem_init+0xf7f>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f010193e:	6a 02                	push   $0x2
f0101940:	6a 00                	push   $0x0
f0101942:	57                   	push   %edi
f0101943:	ff 35 8c 5e 23 f0    	pushl  0xf0235e8c
f0101949:	e8 04 f9 ff ff       	call   f0101252 <page_insert>
f010194e:	83 c4 10             	add    $0x10,%esp
f0101951:	85 c0                	test   %eax,%eax
f0101953:	0f 89 5d 09 00 00    	jns    f01022b6 <mem_init+0xf98>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101959:	83 ec 0c             	sub    $0xc,%esp
f010195c:	ff 75 d4             	pushl  -0x2c(%ebp)
f010195f:	e8 9f f6 ff ff       	call   f0101003 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101964:	6a 02                	push   $0x2
f0101966:	6a 00                	push   $0x0
f0101968:	57                   	push   %edi
f0101969:	ff 35 8c 5e 23 f0    	pushl  0xf0235e8c
f010196f:	e8 de f8 ff ff       	call   f0101252 <page_insert>
f0101974:	83 c4 20             	add    $0x20,%esp
f0101977:	85 c0                	test   %eax,%eax
f0101979:	0f 85 50 09 00 00    	jne    f01022cf <mem_init+0xfb1>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010197f:	8b 35 8c 5e 23 f0    	mov    0xf0235e8c,%esi
	return (pp - pages) << PGSHIFT;
f0101985:	8b 0d 90 5e 23 f0    	mov    0xf0235e90,%ecx
f010198b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f010198e:	8b 16                	mov    (%esi),%edx
f0101990:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101996:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101999:	29 c8                	sub    %ecx,%eax
f010199b:	c1 f8 03             	sar    $0x3,%eax
f010199e:	c1 e0 0c             	shl    $0xc,%eax
f01019a1:	39 c2                	cmp    %eax,%edx
f01019a3:	0f 85 3f 09 00 00    	jne    f01022e8 <mem_init+0xfca>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f01019a9:	ba 00 00 00 00       	mov    $0x0,%edx
f01019ae:	89 f0                	mov    %esi,%eax
f01019b0:	e8 63 f1 ff ff       	call   f0100b18 <check_va2pa>
f01019b5:	89 fa                	mov    %edi,%edx
f01019b7:	2b 55 d0             	sub    -0x30(%ebp),%edx
f01019ba:	c1 fa 03             	sar    $0x3,%edx
f01019bd:	c1 e2 0c             	shl    $0xc,%edx
f01019c0:	39 d0                	cmp    %edx,%eax
f01019c2:	0f 85 39 09 00 00    	jne    f0102301 <mem_init+0xfe3>
	assert(pp1->pp_ref == 1);
f01019c8:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01019cd:	0f 85 47 09 00 00    	jne    f010231a <mem_init+0xffc>
	assert(pp0->pp_ref == 1);
f01019d3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01019d6:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f01019db:	0f 85 52 09 00 00    	jne    f0102333 <mem_init+0x1015>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01019e1:	6a 02                	push   $0x2
f01019e3:	68 00 10 00 00       	push   $0x1000
f01019e8:	53                   	push   %ebx
f01019e9:	56                   	push   %esi
f01019ea:	e8 63 f8 ff ff       	call   f0101252 <page_insert>
f01019ef:	83 c4 10             	add    $0x10,%esp
f01019f2:	85 c0                	test   %eax,%eax
f01019f4:	0f 85 52 09 00 00    	jne    f010234c <mem_init+0x102e>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01019fa:	ba 00 10 00 00       	mov    $0x1000,%edx
f01019ff:	a1 8c 5e 23 f0       	mov    0xf0235e8c,%eax
f0101a04:	e8 0f f1 ff ff       	call   f0100b18 <check_va2pa>
f0101a09:	89 da                	mov    %ebx,%edx
f0101a0b:	2b 15 90 5e 23 f0    	sub    0xf0235e90,%edx
f0101a11:	c1 fa 03             	sar    $0x3,%edx
f0101a14:	c1 e2 0c             	shl    $0xc,%edx
f0101a17:	39 d0                	cmp    %edx,%eax
f0101a19:	0f 85 46 09 00 00    	jne    f0102365 <mem_init+0x1047>
	assert(pp2->pp_ref == 1);
f0101a1f:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101a24:	0f 85 54 09 00 00    	jne    f010237e <mem_init+0x1060>

	// should be no free memory
	assert(!page_alloc(0));
f0101a2a:	83 ec 0c             	sub    $0xc,%esp
f0101a2d:	6a 00                	push   $0x0
f0101a2f:	e8 5d f5 ff ff       	call   f0100f91 <page_alloc>
f0101a34:	83 c4 10             	add    $0x10,%esp
f0101a37:	85 c0                	test   %eax,%eax
f0101a39:	0f 85 58 09 00 00    	jne    f0102397 <mem_init+0x1079>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101a3f:	6a 02                	push   $0x2
f0101a41:	68 00 10 00 00       	push   $0x1000
f0101a46:	53                   	push   %ebx
f0101a47:	ff 35 8c 5e 23 f0    	pushl  0xf0235e8c
f0101a4d:	e8 00 f8 ff ff       	call   f0101252 <page_insert>
f0101a52:	83 c4 10             	add    $0x10,%esp
f0101a55:	85 c0                	test   %eax,%eax
f0101a57:	0f 85 53 09 00 00    	jne    f01023b0 <mem_init+0x1092>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101a5d:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101a62:	a1 8c 5e 23 f0       	mov    0xf0235e8c,%eax
f0101a67:	e8 ac f0 ff ff       	call   f0100b18 <check_va2pa>
f0101a6c:	89 da                	mov    %ebx,%edx
f0101a6e:	2b 15 90 5e 23 f0    	sub    0xf0235e90,%edx
f0101a74:	c1 fa 03             	sar    $0x3,%edx
f0101a77:	c1 e2 0c             	shl    $0xc,%edx
f0101a7a:	39 d0                	cmp    %edx,%eax
f0101a7c:	0f 85 47 09 00 00    	jne    f01023c9 <mem_init+0x10ab>
	assert(pp2->pp_ref == 1);
f0101a82:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101a87:	0f 85 55 09 00 00    	jne    f01023e2 <mem_init+0x10c4>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101a8d:	83 ec 0c             	sub    $0xc,%esp
f0101a90:	6a 00                	push   $0x0
f0101a92:	e8 fa f4 ff ff       	call   f0100f91 <page_alloc>
f0101a97:	83 c4 10             	add    $0x10,%esp
f0101a9a:	85 c0                	test   %eax,%eax
f0101a9c:	0f 85 59 09 00 00    	jne    f01023fb <mem_init+0x10dd>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101aa2:	8b 15 8c 5e 23 f0    	mov    0xf0235e8c,%edx
f0101aa8:	8b 02                	mov    (%edx),%eax
f0101aaa:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0101aaf:	89 c1                	mov    %eax,%ecx
f0101ab1:	c1 e9 0c             	shr    $0xc,%ecx
f0101ab4:	3b 0d 88 5e 23 f0    	cmp    0xf0235e88,%ecx
f0101aba:	0f 83 54 09 00 00    	jae    f0102414 <mem_init+0x10f6>
	return (void *)(pa + KERNBASE);
f0101ac0:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101ac5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101ac8:	83 ec 04             	sub    $0x4,%esp
f0101acb:	6a 00                	push   $0x0
f0101acd:	68 00 10 00 00       	push   $0x1000
f0101ad2:	52                   	push   %edx
f0101ad3:	e8 8f f5 ff ff       	call   f0101067 <pgdir_walk>
f0101ad8:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101adb:	8d 51 04             	lea    0x4(%ecx),%edx
f0101ade:	83 c4 10             	add    $0x10,%esp
f0101ae1:	39 d0                	cmp    %edx,%eax
f0101ae3:	0f 85 40 09 00 00    	jne    f0102429 <mem_init+0x110b>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101ae9:	6a 06                	push   $0x6
f0101aeb:	68 00 10 00 00       	push   $0x1000
f0101af0:	53                   	push   %ebx
f0101af1:	ff 35 8c 5e 23 f0    	pushl  0xf0235e8c
f0101af7:	e8 56 f7 ff ff       	call   f0101252 <page_insert>
f0101afc:	83 c4 10             	add    $0x10,%esp
f0101aff:	85 c0                	test   %eax,%eax
f0101b01:	0f 85 3b 09 00 00    	jne    f0102442 <mem_init+0x1124>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101b07:	8b 35 8c 5e 23 f0    	mov    0xf0235e8c,%esi
f0101b0d:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101b12:	89 f0                	mov    %esi,%eax
f0101b14:	e8 ff ef ff ff       	call   f0100b18 <check_va2pa>
	return (pp - pages) << PGSHIFT;
f0101b19:	89 da                	mov    %ebx,%edx
f0101b1b:	2b 15 90 5e 23 f0    	sub    0xf0235e90,%edx
f0101b21:	c1 fa 03             	sar    $0x3,%edx
f0101b24:	c1 e2 0c             	shl    $0xc,%edx
f0101b27:	39 d0                	cmp    %edx,%eax
f0101b29:	0f 85 2c 09 00 00    	jne    f010245b <mem_init+0x113d>
	assert(pp2->pp_ref == 1);
f0101b2f:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101b34:	0f 85 3a 09 00 00    	jne    f0102474 <mem_init+0x1156>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101b3a:	83 ec 04             	sub    $0x4,%esp
f0101b3d:	6a 00                	push   $0x0
f0101b3f:	68 00 10 00 00       	push   $0x1000
f0101b44:	56                   	push   %esi
f0101b45:	e8 1d f5 ff ff       	call   f0101067 <pgdir_walk>
f0101b4a:	83 c4 10             	add    $0x10,%esp
f0101b4d:	f6 00 04             	testb  $0x4,(%eax)
f0101b50:	0f 84 37 09 00 00    	je     f010248d <mem_init+0x116f>
	assert(kern_pgdir[0] & PTE_U);
f0101b56:	a1 8c 5e 23 f0       	mov    0xf0235e8c,%eax
f0101b5b:	f6 00 04             	testb  $0x4,(%eax)
f0101b5e:	0f 84 42 09 00 00    	je     f01024a6 <mem_init+0x1188>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101b64:	6a 02                	push   $0x2
f0101b66:	68 00 10 00 00       	push   $0x1000
f0101b6b:	53                   	push   %ebx
f0101b6c:	50                   	push   %eax
f0101b6d:	e8 e0 f6 ff ff       	call   f0101252 <page_insert>
f0101b72:	83 c4 10             	add    $0x10,%esp
f0101b75:	85 c0                	test   %eax,%eax
f0101b77:	0f 85 42 09 00 00    	jne    f01024bf <mem_init+0x11a1>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101b7d:	83 ec 04             	sub    $0x4,%esp
f0101b80:	6a 00                	push   $0x0
f0101b82:	68 00 10 00 00       	push   $0x1000
f0101b87:	ff 35 8c 5e 23 f0    	pushl  0xf0235e8c
f0101b8d:	e8 d5 f4 ff ff       	call   f0101067 <pgdir_walk>
f0101b92:	83 c4 10             	add    $0x10,%esp
f0101b95:	f6 00 02             	testb  $0x2,(%eax)
f0101b98:	0f 84 3a 09 00 00    	je     f01024d8 <mem_init+0x11ba>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101b9e:	83 ec 04             	sub    $0x4,%esp
f0101ba1:	6a 00                	push   $0x0
f0101ba3:	68 00 10 00 00       	push   $0x1000
f0101ba8:	ff 35 8c 5e 23 f0    	pushl  0xf0235e8c
f0101bae:	e8 b4 f4 ff ff       	call   f0101067 <pgdir_walk>
f0101bb3:	83 c4 10             	add    $0x10,%esp
f0101bb6:	f6 00 04             	testb  $0x4,(%eax)
f0101bb9:	0f 85 32 09 00 00    	jne    f01024f1 <mem_init+0x11d3>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101bbf:	6a 02                	push   $0x2
f0101bc1:	68 00 00 40 00       	push   $0x400000
f0101bc6:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101bc9:	ff 35 8c 5e 23 f0    	pushl  0xf0235e8c
f0101bcf:	e8 7e f6 ff ff       	call   f0101252 <page_insert>
f0101bd4:	83 c4 10             	add    $0x10,%esp
f0101bd7:	85 c0                	test   %eax,%eax
f0101bd9:	0f 89 2b 09 00 00    	jns    f010250a <mem_init+0x11ec>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101bdf:	6a 02                	push   $0x2
f0101be1:	68 00 10 00 00       	push   $0x1000
f0101be6:	57                   	push   %edi
f0101be7:	ff 35 8c 5e 23 f0    	pushl  0xf0235e8c
f0101bed:	e8 60 f6 ff ff       	call   f0101252 <page_insert>
f0101bf2:	83 c4 10             	add    $0x10,%esp
f0101bf5:	85 c0                	test   %eax,%eax
f0101bf7:	0f 85 26 09 00 00    	jne    f0102523 <mem_init+0x1205>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101bfd:	83 ec 04             	sub    $0x4,%esp
f0101c00:	6a 00                	push   $0x0
f0101c02:	68 00 10 00 00       	push   $0x1000
f0101c07:	ff 35 8c 5e 23 f0    	pushl  0xf0235e8c
f0101c0d:	e8 55 f4 ff ff       	call   f0101067 <pgdir_walk>
f0101c12:	83 c4 10             	add    $0x10,%esp
f0101c15:	f6 00 04             	testb  $0x4,(%eax)
f0101c18:	0f 85 1e 09 00 00    	jne    f010253c <mem_init+0x121e>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101c1e:	a1 8c 5e 23 f0       	mov    0xf0235e8c,%eax
f0101c23:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101c26:	ba 00 00 00 00       	mov    $0x0,%edx
f0101c2b:	e8 e8 ee ff ff       	call   f0100b18 <check_va2pa>
f0101c30:	89 fe                	mov    %edi,%esi
f0101c32:	2b 35 90 5e 23 f0    	sub    0xf0235e90,%esi
f0101c38:	c1 fe 03             	sar    $0x3,%esi
f0101c3b:	c1 e6 0c             	shl    $0xc,%esi
f0101c3e:	39 f0                	cmp    %esi,%eax
f0101c40:	0f 85 0f 09 00 00    	jne    f0102555 <mem_init+0x1237>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101c46:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c4b:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101c4e:	e8 c5 ee ff ff       	call   f0100b18 <check_va2pa>
f0101c53:	39 c6                	cmp    %eax,%esi
f0101c55:	0f 85 13 09 00 00    	jne    f010256e <mem_init+0x1250>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101c5b:	66 83 7f 04 02       	cmpw   $0x2,0x4(%edi)
f0101c60:	0f 85 21 09 00 00    	jne    f0102587 <mem_init+0x1269>
	assert(pp2->pp_ref == 0);
f0101c66:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101c6b:	0f 85 2f 09 00 00    	jne    f01025a0 <mem_init+0x1282>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101c71:	83 ec 0c             	sub    $0xc,%esp
f0101c74:	6a 00                	push   $0x0
f0101c76:	e8 16 f3 ff ff       	call   f0100f91 <page_alloc>
f0101c7b:	83 c4 10             	add    $0x10,%esp
f0101c7e:	85 c0                	test   %eax,%eax
f0101c80:	0f 84 33 09 00 00    	je     f01025b9 <mem_init+0x129b>
f0101c86:	39 c3                	cmp    %eax,%ebx
f0101c88:	0f 85 2b 09 00 00    	jne    f01025b9 <mem_init+0x129b>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101c8e:	83 ec 08             	sub    $0x8,%esp
f0101c91:	6a 00                	push   $0x0
f0101c93:	ff 35 8c 5e 23 f0    	pushl  0xf0235e8c
f0101c99:	e8 6e f5 ff ff       	call   f010120c <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101c9e:	8b 35 8c 5e 23 f0    	mov    0xf0235e8c,%esi
f0101ca4:	ba 00 00 00 00       	mov    $0x0,%edx
f0101ca9:	89 f0                	mov    %esi,%eax
f0101cab:	e8 68 ee ff ff       	call   f0100b18 <check_va2pa>
f0101cb0:	83 c4 10             	add    $0x10,%esp
f0101cb3:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101cb6:	0f 85 16 09 00 00    	jne    f01025d2 <mem_init+0x12b4>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101cbc:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101cc1:	89 f0                	mov    %esi,%eax
f0101cc3:	e8 50 ee ff ff       	call   f0100b18 <check_va2pa>
f0101cc8:	89 fa                	mov    %edi,%edx
f0101cca:	2b 15 90 5e 23 f0    	sub    0xf0235e90,%edx
f0101cd0:	c1 fa 03             	sar    $0x3,%edx
f0101cd3:	c1 e2 0c             	shl    $0xc,%edx
f0101cd6:	39 d0                	cmp    %edx,%eax
f0101cd8:	0f 85 0d 09 00 00    	jne    f01025eb <mem_init+0x12cd>
	assert(pp1->pp_ref == 1);
f0101cde:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101ce3:	0f 85 1b 09 00 00    	jne    f0102604 <mem_init+0x12e6>
	assert(pp2->pp_ref == 0);
f0101ce9:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101cee:	0f 85 29 09 00 00    	jne    f010261d <mem_init+0x12ff>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101cf4:	6a 00                	push   $0x0
f0101cf6:	68 00 10 00 00       	push   $0x1000
f0101cfb:	57                   	push   %edi
f0101cfc:	56                   	push   %esi
f0101cfd:	e8 50 f5 ff ff       	call   f0101252 <page_insert>
f0101d02:	83 c4 10             	add    $0x10,%esp
f0101d05:	85 c0                	test   %eax,%eax
f0101d07:	0f 85 29 09 00 00    	jne    f0102636 <mem_init+0x1318>
	assert(pp1->pp_ref);
f0101d0d:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101d12:	0f 84 37 09 00 00    	je     f010264f <mem_init+0x1331>
	assert(pp1->pp_link == NULL);
f0101d18:	83 3f 00             	cmpl   $0x0,(%edi)
f0101d1b:	0f 85 47 09 00 00    	jne    f0102668 <mem_init+0x134a>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101d21:	83 ec 08             	sub    $0x8,%esp
f0101d24:	68 00 10 00 00       	push   $0x1000
f0101d29:	ff 35 8c 5e 23 f0    	pushl  0xf0235e8c
f0101d2f:	e8 d8 f4 ff ff       	call   f010120c <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101d34:	8b 35 8c 5e 23 f0    	mov    0xf0235e8c,%esi
f0101d3a:	ba 00 00 00 00       	mov    $0x0,%edx
f0101d3f:	89 f0                	mov    %esi,%eax
f0101d41:	e8 d2 ed ff ff       	call   f0100b18 <check_va2pa>
f0101d46:	83 c4 10             	add    $0x10,%esp
f0101d49:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101d4c:	0f 85 2f 09 00 00    	jne    f0102681 <mem_init+0x1363>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101d52:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d57:	89 f0                	mov    %esi,%eax
f0101d59:	e8 ba ed ff ff       	call   f0100b18 <check_va2pa>
f0101d5e:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101d61:	0f 85 33 09 00 00    	jne    f010269a <mem_init+0x137c>
	assert(pp1->pp_ref == 0);
f0101d67:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101d6c:	0f 85 41 09 00 00    	jne    f01026b3 <mem_init+0x1395>
	assert(pp2->pp_ref == 0);
f0101d72:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101d77:	0f 85 4f 09 00 00    	jne    f01026cc <mem_init+0x13ae>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101d7d:	83 ec 0c             	sub    $0xc,%esp
f0101d80:	6a 00                	push   $0x0
f0101d82:	e8 0a f2 ff ff       	call   f0100f91 <page_alloc>
f0101d87:	83 c4 10             	add    $0x10,%esp
f0101d8a:	39 c7                	cmp    %eax,%edi
f0101d8c:	0f 85 53 09 00 00    	jne    f01026e5 <mem_init+0x13c7>
f0101d92:	85 c0                	test   %eax,%eax
f0101d94:	0f 84 4b 09 00 00    	je     f01026e5 <mem_init+0x13c7>

	// should be no free memory
	assert(!page_alloc(0));
f0101d9a:	83 ec 0c             	sub    $0xc,%esp
f0101d9d:	6a 00                	push   $0x0
f0101d9f:	e8 ed f1 ff ff       	call   f0100f91 <page_alloc>
f0101da4:	83 c4 10             	add    $0x10,%esp
f0101da7:	85 c0                	test   %eax,%eax
f0101da9:	0f 85 4f 09 00 00    	jne    f01026fe <mem_init+0x13e0>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101daf:	8b 0d 8c 5e 23 f0    	mov    0xf0235e8c,%ecx
f0101db5:	8b 11                	mov    (%ecx),%edx
f0101db7:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101dbd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101dc0:	2b 05 90 5e 23 f0    	sub    0xf0235e90,%eax
f0101dc6:	c1 f8 03             	sar    $0x3,%eax
f0101dc9:	c1 e0 0c             	shl    $0xc,%eax
f0101dcc:	39 c2                	cmp    %eax,%edx
f0101dce:	0f 85 43 09 00 00    	jne    f0102717 <mem_init+0x13f9>
	kern_pgdir[0] = 0;
f0101dd4:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0101dda:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ddd:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101de2:	0f 85 48 09 00 00    	jne    f0102730 <mem_init+0x1412>
	pp0->pp_ref = 0;
f0101de8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101deb:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0101df1:	83 ec 0c             	sub    $0xc,%esp
f0101df4:	50                   	push   %eax
f0101df5:	e8 09 f2 ff ff       	call   f0101003 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0101dfa:	83 c4 0c             	add    $0xc,%esp
f0101dfd:	6a 01                	push   $0x1
f0101dff:	68 00 10 40 00       	push   $0x401000
f0101e04:	ff 35 8c 5e 23 f0    	pushl  0xf0235e8c
f0101e0a:	e8 58 f2 ff ff       	call   f0101067 <pgdir_walk>
f0101e0f:	89 c1                	mov    %eax,%ecx
f0101e11:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0101e14:	a1 8c 5e 23 f0       	mov    0xf0235e8c,%eax
f0101e19:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101e1c:	8b 40 04             	mov    0x4(%eax),%eax
f0101e1f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0101e24:	8b 35 88 5e 23 f0    	mov    0xf0235e88,%esi
f0101e2a:	89 c2                	mov    %eax,%edx
f0101e2c:	c1 ea 0c             	shr    $0xc,%edx
f0101e2f:	83 c4 10             	add    $0x10,%esp
f0101e32:	39 f2                	cmp    %esi,%edx
f0101e34:	0f 83 0f 09 00 00    	jae    f0102749 <mem_init+0x142b>
	assert(ptep == ptep1 + PTX(va));
f0101e3a:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f0101e3f:	39 c1                	cmp    %eax,%ecx
f0101e41:	0f 85 17 09 00 00    	jne    f010275e <mem_init+0x1440>
	kern_pgdir[PDX(va)] = 0;
f0101e47:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101e4a:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f0101e51:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e54:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f0101e5a:	2b 05 90 5e 23 f0    	sub    0xf0235e90,%eax
f0101e60:	c1 f8 03             	sar    $0x3,%eax
f0101e63:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0101e66:	89 c2                	mov    %eax,%edx
f0101e68:	c1 ea 0c             	shr    $0xc,%edx
f0101e6b:	39 d6                	cmp    %edx,%esi
f0101e6d:	0f 86 04 09 00 00    	jbe    f0102777 <mem_init+0x1459>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0101e73:	83 ec 04             	sub    $0x4,%esp
f0101e76:	68 00 10 00 00       	push   $0x1000
f0101e7b:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f0101e80:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101e85:	50                   	push   %eax
f0101e86:	e8 d0 34 00 00       	call   f010535b <memset>
	page_free(pp0);
f0101e8b:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0101e8e:	89 34 24             	mov    %esi,(%esp)
f0101e91:	e8 6d f1 ff ff       	call   f0101003 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0101e96:	83 c4 0c             	add    $0xc,%esp
f0101e99:	6a 01                	push   $0x1
f0101e9b:	6a 00                	push   $0x0
f0101e9d:	ff 35 8c 5e 23 f0    	pushl  0xf0235e8c
f0101ea3:	e8 bf f1 ff ff       	call   f0101067 <pgdir_walk>
	return (pp - pages) << PGSHIFT;
f0101ea8:	89 f0                	mov    %esi,%eax
f0101eaa:	2b 05 90 5e 23 f0    	sub    0xf0235e90,%eax
f0101eb0:	c1 f8 03             	sar    $0x3,%eax
f0101eb3:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0101eb6:	89 c2                	mov    %eax,%edx
f0101eb8:	c1 ea 0c             	shr    $0xc,%edx
f0101ebb:	83 c4 10             	add    $0x10,%esp
f0101ebe:	3b 15 88 5e 23 f0    	cmp    0xf0235e88,%edx
f0101ec4:	0f 83 bf 08 00 00    	jae    f0102789 <mem_init+0x146b>
	return (void *)(pa + KERNBASE);
f0101eca:	8d 90 00 00 00 f0    	lea    -0x10000000(%eax),%edx
	ptep = (pte_t *) page2kva(pp0);
f0101ed0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0101ed3:	2d 00 f0 ff 0f       	sub    $0xffff000,%eax
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0101ed8:	f6 02 01             	testb  $0x1,(%edx)
f0101edb:	0f 85 ba 08 00 00    	jne    f010279b <mem_init+0x147d>
f0101ee1:	83 c2 04             	add    $0x4,%edx
	for(i=0; i<NPTENTRIES; i++)
f0101ee4:	39 c2                	cmp    %eax,%edx
f0101ee6:	75 f0                	jne    f0101ed8 <mem_init+0xbba>
	kern_pgdir[0] = 0;
f0101ee8:	a1 8c 5e 23 f0       	mov    0xf0235e8c,%eax
f0101eed:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0101ef3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ef6:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0101efc:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0101eff:	89 0d 3c 52 23 f0    	mov    %ecx,0xf023523c

	// free the pages we took
	page_free(pp0);
f0101f05:	83 ec 0c             	sub    $0xc,%esp
f0101f08:	50                   	push   %eax
f0101f09:	e8 f5 f0 ff ff       	call   f0101003 <page_free>
	page_free(pp1);
f0101f0e:	89 3c 24             	mov    %edi,(%esp)
f0101f11:	e8 ed f0 ff ff       	call   f0101003 <page_free>
	page_free(pp2);
f0101f16:	89 1c 24             	mov    %ebx,(%esp)
f0101f19:	e8 e5 f0 ff ff       	call   f0101003 <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f0101f1e:	83 c4 08             	add    $0x8,%esp
f0101f21:	68 01 10 00 00       	push   $0x1001
f0101f26:	6a 00                	push   $0x0
f0101f28:	e8 8b f3 ff ff       	call   f01012b8 <mmio_map_region>
f0101f2d:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f0101f2f:	83 c4 08             	add    $0x8,%esp
f0101f32:	68 00 10 00 00       	push   $0x1000
f0101f37:	6a 00                	push   $0x0
f0101f39:	e8 7a f3 ff ff       	call   f01012b8 <mmio_map_region>
f0101f3e:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8192 < MMIOLIM);
f0101f40:	8d 83 00 20 00 00    	lea    0x2000(%ebx),%eax
f0101f46:	83 c4 10             	add    $0x10,%esp
f0101f49:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0101f4f:	0f 86 5f 08 00 00    	jbe    f01027b4 <mem_init+0x1496>
f0101f55:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0101f5a:	0f 87 54 08 00 00    	ja     f01027b4 <mem_init+0x1496>
	assert(mm2 >= MMIOBASE && mm2 + 8192 < MMIOLIM);
f0101f60:	8d 96 00 20 00 00    	lea    0x2000(%esi),%edx
f0101f66:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f0101f6c:	0f 87 5b 08 00 00    	ja     f01027cd <mem_init+0x14af>
f0101f72:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0101f78:	0f 86 4f 08 00 00    	jbe    f01027cd <mem_init+0x14af>
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0101f7e:	89 da                	mov    %ebx,%edx
f0101f80:	09 f2                	or     %esi,%edx
f0101f82:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0101f88:	0f 85 58 08 00 00    	jne    f01027e6 <mem_init+0x14c8>
	// check that they don't overlap
	assert(mm1 + 8192 <= mm2);
f0101f8e:	39 c6                	cmp    %eax,%esi
f0101f90:	0f 82 69 08 00 00    	jb     f01027ff <mem_init+0x14e1>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0101f96:	8b 3d 8c 5e 23 f0    	mov    0xf0235e8c,%edi
f0101f9c:	89 da                	mov    %ebx,%edx
f0101f9e:	89 f8                	mov    %edi,%eax
f0101fa0:	e8 73 eb ff ff       	call   f0100b18 <check_va2pa>
f0101fa5:	85 c0                	test   %eax,%eax
f0101fa7:	0f 85 6b 08 00 00    	jne    f0102818 <mem_init+0x14fa>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0101fad:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f0101fb3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101fb6:	89 c2                	mov    %eax,%edx
f0101fb8:	89 f8                	mov    %edi,%eax
f0101fba:	e8 59 eb ff ff       	call   f0100b18 <check_va2pa>
f0101fbf:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0101fc4:	0f 85 67 08 00 00    	jne    f0102831 <mem_init+0x1513>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0101fca:	89 f2                	mov    %esi,%edx
f0101fcc:	89 f8                	mov    %edi,%eax
f0101fce:	e8 45 eb ff ff       	call   f0100b18 <check_va2pa>
f0101fd3:	85 c0                	test   %eax,%eax
f0101fd5:	0f 85 6f 08 00 00    	jne    f010284a <mem_init+0x152c>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0101fdb:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f0101fe1:	89 f8                	mov    %edi,%eax
f0101fe3:	e8 30 eb ff ff       	call   f0100b18 <check_va2pa>
f0101fe8:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101feb:	0f 85 72 08 00 00    	jne    f0102863 <mem_init+0x1545>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f0101ff1:	83 ec 04             	sub    $0x4,%esp
f0101ff4:	6a 00                	push   $0x0
f0101ff6:	53                   	push   %ebx
f0101ff7:	57                   	push   %edi
f0101ff8:	e8 6a f0 ff ff       	call   f0101067 <pgdir_walk>
f0101ffd:	83 c4 10             	add    $0x10,%esp
f0102000:	f6 00 1a             	testb  $0x1a,(%eax)
f0102003:	0f 84 73 08 00 00    	je     f010287c <mem_init+0x155e>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102009:	83 ec 04             	sub    $0x4,%esp
f010200c:	6a 00                	push   $0x0
f010200e:	53                   	push   %ebx
f010200f:	ff 35 8c 5e 23 f0    	pushl  0xf0235e8c
f0102015:	e8 4d f0 ff ff       	call   f0101067 <pgdir_walk>
f010201a:	83 c4 10             	add    $0x10,%esp
f010201d:	f6 00 04             	testb  $0x4,(%eax)
f0102020:	0f 85 6f 08 00 00    	jne    f0102895 <mem_init+0x1577>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f0102026:	83 ec 04             	sub    $0x4,%esp
f0102029:	6a 00                	push   $0x0
f010202b:	53                   	push   %ebx
f010202c:	ff 35 8c 5e 23 f0    	pushl  0xf0235e8c
f0102032:	e8 30 f0 ff ff       	call   f0101067 <pgdir_walk>
f0102037:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f010203d:	83 c4 0c             	add    $0xc,%esp
f0102040:	6a 00                	push   $0x0
f0102042:	ff 75 d4             	pushl  -0x2c(%ebp)
f0102045:	ff 35 8c 5e 23 f0    	pushl  0xf0235e8c
f010204b:	e8 17 f0 ff ff       	call   f0101067 <pgdir_walk>
f0102050:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f0102056:	83 c4 0c             	add    $0xc,%esp
f0102059:	6a 00                	push   $0x0
f010205b:	56                   	push   %esi
f010205c:	ff 35 8c 5e 23 f0    	pushl  0xf0235e8c
f0102062:	e8 00 f0 ff ff       	call   f0101067 <pgdir_walk>
f0102067:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f010206d:	c7 04 24 73 68 10 f0 	movl   $0xf0106873,(%esp)
f0102074:	e8 a7 17 00 00       	call   f0103820 <cprintf>
	boot_map_region(kern_pgdir, (uintptr_t) UPAGES, npages*sizeof(struct PageInfo), PADDR(pages), PTE_U | PTE_P);
f0102079:	a1 90 5e 23 f0       	mov    0xf0235e90,%eax
	if ((uint32_t)kva < KERNBASE)
f010207e:	83 c4 10             	add    $0x10,%esp
f0102081:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102086:	0f 86 22 08 00 00    	jbe    f01028ae <mem_init+0x1590>
f010208c:	8b 0d 88 5e 23 f0    	mov    0xf0235e88,%ecx
f0102092:	c1 e1 03             	shl    $0x3,%ecx
f0102095:	83 ec 08             	sub    $0x8,%esp
f0102098:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f010209a:	05 00 00 00 10       	add    $0x10000000,%eax
f010209f:	50                   	push   %eax
f01020a0:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f01020a5:	a1 8c 5e 23 f0       	mov    0xf0235e8c,%eax
f01020aa:	e8 78 f0 ff ff       	call   f0101127 <boot_map_region>
	boot_map_region(kern_pgdir, (uintptr_t) UENVS, ROUNDUP(NENV * sizeof(struct Env), PGSIZE), PADDR(envs), PTE_U | PTE_P);
f01020af:	a1 44 52 23 f0       	mov    0xf0235244,%eax
	if ((uint32_t)kva < KERNBASE)
f01020b4:	83 c4 10             	add    $0x10,%esp
f01020b7:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01020bc:	0f 86 01 08 00 00    	jbe    f01028c3 <mem_init+0x15a5>
f01020c2:	83 ec 08             	sub    $0x8,%esp
f01020c5:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f01020c7:	05 00 00 00 10       	add    $0x10000000,%eax
f01020cc:	50                   	push   %eax
f01020cd:	b9 00 f0 01 00       	mov    $0x1f000,%ecx
f01020d2:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f01020d7:	a1 8c 5e 23 f0       	mov    0xf0235e8c,%eax
f01020dc:	e8 46 f0 ff ff       	call   f0101127 <boot_map_region>
	if ((uint32_t)kva < KERNBASE)
f01020e1:	83 c4 10             	add    $0x10,%esp
f01020e4:	b8 00 80 11 f0       	mov    $0xf0118000,%eax
f01020e9:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01020ee:	0f 86 e4 07 00 00    	jbe    f01028d8 <mem_init+0x15ba>
	boot_map_region(kern_pgdir, (uintptr_t) (KSTACKTOP-KSTKSIZE), KSTKSIZE, PADDR(bootstack), PTE_W | PTE_P);
f01020f4:	83 ec 08             	sub    $0x8,%esp
f01020f7:	6a 03                	push   $0x3
f01020f9:	68 00 80 11 00       	push   $0x118000
f01020fe:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102103:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102108:	a1 8c 5e 23 f0       	mov    0xf0235e8c,%eax
f010210d:	e8 15 f0 ff ff       	call   f0101127 <boot_map_region>
	boot_map_region(kern_pgdir, (uintptr_t) KERNBASE, ROUNDUP(0xffffffff - KERNBASE, PGSIZE), 0, PTE_W | PTE_P);
f0102112:	83 c4 08             	add    $0x8,%esp
f0102115:	6a 03                	push   $0x3
f0102117:	6a 00                	push   $0x0
f0102119:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f010211e:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102123:	a1 8c 5e 23 f0       	mov    0xf0235e8c,%eax
f0102128:	e8 fa ef ff ff       	call   f0101127 <boot_map_region>
f010212d:	c7 45 d0 00 70 23 f0 	movl   $0xf0237000,-0x30(%ebp)
f0102134:	83 c4 10             	add    $0x10,%esp
f0102137:	bb 00 70 23 f0       	mov    $0xf0237000,%ebx
    uintptr_t start_addr = KSTACKTOP - KSTKSIZE;    
f010213c:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f0102141:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102147:	0f 86 a0 07 00 00    	jbe    f01028ed <mem_init+0x15cf>
        boot_map_region(kern_pgdir, (uintptr_t) start_addr, KSTKSIZE, PADDR(percpu_kstacks[i]), PTE_W | PTE_P);
f010214d:	83 ec 08             	sub    $0x8,%esp
f0102150:	6a 03                	push   $0x3
f0102152:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f0102158:	50                   	push   %eax
f0102159:	b9 00 80 00 00       	mov    $0x8000,%ecx
f010215e:	89 f2                	mov    %esi,%edx
f0102160:	a1 8c 5e 23 f0       	mov    0xf0235e8c,%eax
f0102165:	e8 bd ef ff ff       	call   f0101127 <boot_map_region>
        start_addr -= KSTKSIZE + KSTKGAP;
f010216a:	81 ee 00 00 01 00    	sub    $0x10000,%esi
f0102170:	81 c3 00 80 00 00    	add    $0x8000,%ebx
    for (i = 0; i < NCPU; i++) {
f0102176:	83 c4 10             	add    $0x10,%esp
f0102179:	81 fe 00 80 f7 ef    	cmp    $0xeff78000,%esi
f010217f:	75 c0                	jne    f0102141 <mem_init+0xe23>
	pgdir = kern_pgdir;
f0102181:	8b 3d 8c 5e 23 f0    	mov    0xf0235e8c,%edi
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102187:	a1 88 5e 23 f0       	mov    0xf0235e88,%eax
f010218c:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f010218f:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0102196:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010219b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010219e:	8b 35 90 5e 23 f0    	mov    0xf0235e90,%esi
f01021a4:	89 75 cc             	mov    %esi,-0x34(%ebp)
	return (physaddr_t)kva - KERNBASE;
f01021a7:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f01021ad:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (i = 0; i < n; i += PGSIZE)
f01021b0:	bb 00 00 00 00       	mov    $0x0,%ebx
f01021b5:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f01021b8:	0f 86 72 07 00 00    	jbe    f0102930 <mem_init+0x1612>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01021be:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f01021c4:	89 f8                	mov    %edi,%eax
f01021c6:	e8 4d e9 ff ff       	call   f0100b18 <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f01021cb:	81 7d cc ff ff ff ef 	cmpl   $0xefffffff,-0x34(%ebp)
f01021d2:	0f 86 2a 07 00 00    	jbe    f0102902 <mem_init+0x15e4>
f01021d8:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f01021db:	8d 14 0b             	lea    (%ebx,%ecx,1),%edx
f01021de:	39 d0                	cmp    %edx,%eax
f01021e0:	0f 85 31 07 00 00    	jne    f0102917 <mem_init+0x15f9>
	for (i = 0; i < n; i += PGSIZE)
f01021e6:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01021ec:	eb c7                	jmp    f01021b5 <mem_init+0xe97>
	assert(nfree == 0);
f01021ee:	68 8a 67 10 f0       	push   $0xf010678a
f01021f3:	68 be 65 10 f0       	push   $0xf01065be
f01021f8:	68 4c 03 00 00       	push   $0x34c
f01021fd:	68 91 65 10 f0       	push   $0xf0106591
f0102202:	e8 8d de ff ff       	call   f0100094 <_panic>
	assert((pp0 = page_alloc(0)));
f0102207:	68 98 66 10 f0       	push   $0xf0106698
f010220c:	68 be 65 10 f0       	push   $0xf01065be
f0102211:	68 b8 03 00 00       	push   $0x3b8
f0102216:	68 91 65 10 f0       	push   $0xf0106591
f010221b:	e8 74 de ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f0102220:	68 ae 66 10 f0       	push   $0xf01066ae
f0102225:	68 be 65 10 f0       	push   $0xf01065be
f010222a:	68 b9 03 00 00       	push   $0x3b9
f010222f:	68 91 65 10 f0       	push   $0xf0106591
f0102234:	e8 5b de ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f0102239:	68 c4 66 10 f0       	push   $0xf01066c4
f010223e:	68 be 65 10 f0       	push   $0xf01065be
f0102243:	68 ba 03 00 00       	push   $0x3ba
f0102248:	68 91 65 10 f0       	push   $0xf0106591
f010224d:	e8 42 de ff ff       	call   f0100094 <_panic>
	assert(pp1 && pp1 != pp0);
f0102252:	68 da 66 10 f0       	push   $0xf01066da
f0102257:	68 be 65 10 f0       	push   $0xf01065be
f010225c:	68 bd 03 00 00       	push   $0x3bd
f0102261:	68 91 65 10 f0       	push   $0xf0106591
f0102266:	e8 29 de ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010226b:	68 38 6a 10 f0       	push   $0xf0106a38
f0102270:	68 be 65 10 f0       	push   $0xf01065be
f0102275:	68 be 03 00 00       	push   $0x3be
f010227a:	68 91 65 10 f0       	push   $0xf0106591
f010227f:	e8 10 de ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f0102284:	68 43 67 10 f0       	push   $0xf0106743
f0102289:	68 be 65 10 f0       	push   $0xf01065be
f010228e:	68 c5 03 00 00       	push   $0x3c5
f0102293:	68 91 65 10 f0       	push   $0xf0106591
f0102298:	e8 f7 dd ff ff       	call   f0100094 <_panic>
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f010229d:	68 78 6a 10 f0       	push   $0xf0106a78
f01022a2:	68 be 65 10 f0       	push   $0xf01065be
f01022a7:	68 c8 03 00 00       	push   $0x3c8
f01022ac:	68 91 65 10 f0       	push   $0xf0106591
f01022b1:	e8 de dd ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01022b6:	68 b0 6a 10 f0       	push   $0xf0106ab0
f01022bb:	68 be 65 10 f0       	push   $0xf01065be
f01022c0:	68 cb 03 00 00       	push   $0x3cb
f01022c5:	68 91 65 10 f0       	push   $0xf0106591
f01022ca:	e8 c5 dd ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f01022cf:	68 e0 6a 10 f0       	push   $0xf0106ae0
f01022d4:	68 be 65 10 f0       	push   $0xf01065be
f01022d9:	68 cf 03 00 00       	push   $0x3cf
f01022de:	68 91 65 10 f0       	push   $0xf0106591
f01022e3:	e8 ac dd ff ff       	call   f0100094 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01022e8:	68 10 6b 10 f0       	push   $0xf0106b10
f01022ed:	68 be 65 10 f0       	push   $0xf01065be
f01022f2:	68 d0 03 00 00       	push   $0x3d0
f01022f7:	68 91 65 10 f0       	push   $0xf0106591
f01022fc:	e8 93 dd ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0102301:	68 38 6b 10 f0       	push   $0xf0106b38
f0102306:	68 be 65 10 f0       	push   $0xf01065be
f010230b:	68 d1 03 00 00       	push   $0x3d1
f0102310:	68 91 65 10 f0       	push   $0xf0106591
f0102315:	e8 7a dd ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 1);
f010231a:	68 95 67 10 f0       	push   $0xf0106795
f010231f:	68 be 65 10 f0       	push   $0xf01065be
f0102324:	68 d2 03 00 00       	push   $0x3d2
f0102329:	68 91 65 10 f0       	push   $0xf0106591
f010232e:	e8 61 dd ff ff       	call   f0100094 <_panic>
	assert(pp0->pp_ref == 1);
f0102333:	68 a6 67 10 f0       	push   $0xf01067a6
f0102338:	68 be 65 10 f0       	push   $0xf01065be
f010233d:	68 d3 03 00 00       	push   $0x3d3
f0102342:	68 91 65 10 f0       	push   $0xf0106591
f0102347:	e8 48 dd ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010234c:	68 68 6b 10 f0       	push   $0xf0106b68
f0102351:	68 be 65 10 f0       	push   $0xf01065be
f0102356:	68 d6 03 00 00       	push   $0x3d6
f010235b:	68 91 65 10 f0       	push   $0xf0106591
f0102360:	e8 2f dd ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102365:	68 a4 6b 10 f0       	push   $0xf0106ba4
f010236a:	68 be 65 10 f0       	push   $0xf01065be
f010236f:	68 d7 03 00 00       	push   $0x3d7
f0102374:	68 91 65 10 f0       	push   $0xf0106591
f0102379:	e8 16 dd ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f010237e:	68 b7 67 10 f0       	push   $0xf01067b7
f0102383:	68 be 65 10 f0       	push   $0xf01065be
f0102388:	68 d8 03 00 00       	push   $0x3d8
f010238d:	68 91 65 10 f0       	push   $0xf0106591
f0102392:	e8 fd dc ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f0102397:	68 43 67 10 f0       	push   $0xf0106743
f010239c:	68 be 65 10 f0       	push   $0xf01065be
f01023a1:	68 db 03 00 00       	push   $0x3db
f01023a6:	68 91 65 10 f0       	push   $0xf0106591
f01023ab:	e8 e4 dc ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01023b0:	68 68 6b 10 f0       	push   $0xf0106b68
f01023b5:	68 be 65 10 f0       	push   $0xf01065be
f01023ba:	68 de 03 00 00       	push   $0x3de
f01023bf:	68 91 65 10 f0       	push   $0xf0106591
f01023c4:	e8 cb dc ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01023c9:	68 a4 6b 10 f0       	push   $0xf0106ba4
f01023ce:	68 be 65 10 f0       	push   $0xf01065be
f01023d3:	68 df 03 00 00       	push   $0x3df
f01023d8:	68 91 65 10 f0       	push   $0xf0106591
f01023dd:	e8 b2 dc ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f01023e2:	68 b7 67 10 f0       	push   $0xf01067b7
f01023e7:	68 be 65 10 f0       	push   $0xf01065be
f01023ec:	68 e0 03 00 00       	push   $0x3e0
f01023f1:	68 91 65 10 f0       	push   $0xf0106591
f01023f6:	e8 99 dc ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f01023fb:	68 43 67 10 f0       	push   $0xf0106743
f0102400:	68 be 65 10 f0       	push   $0xf01065be
f0102405:	68 e4 03 00 00       	push   $0x3e4
f010240a:	68 91 65 10 f0       	push   $0xf0106591
f010240f:	e8 80 dc ff ff       	call   f0100094 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102414:	50                   	push   %eax
f0102415:	68 54 60 10 f0       	push   $0xf0106054
f010241a:	68 e7 03 00 00       	push   $0x3e7
f010241f:	68 91 65 10 f0       	push   $0xf0106591
f0102424:	e8 6b dc ff ff       	call   f0100094 <_panic>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0102429:	68 d4 6b 10 f0       	push   $0xf0106bd4
f010242e:	68 be 65 10 f0       	push   $0xf01065be
f0102433:	68 e8 03 00 00       	push   $0x3e8
f0102438:	68 91 65 10 f0       	push   $0xf0106591
f010243d:	e8 52 dc ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0102442:	68 14 6c 10 f0       	push   $0xf0106c14
f0102447:	68 be 65 10 f0       	push   $0xf01065be
f010244c:	68 eb 03 00 00       	push   $0x3eb
f0102451:	68 91 65 10 f0       	push   $0xf0106591
f0102456:	e8 39 dc ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010245b:	68 a4 6b 10 f0       	push   $0xf0106ba4
f0102460:	68 be 65 10 f0       	push   $0xf01065be
f0102465:	68 ec 03 00 00       	push   $0x3ec
f010246a:	68 91 65 10 f0       	push   $0xf0106591
f010246f:	e8 20 dc ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f0102474:	68 b7 67 10 f0       	push   $0xf01067b7
f0102479:	68 be 65 10 f0       	push   $0xf01065be
f010247e:	68 ed 03 00 00       	push   $0x3ed
f0102483:	68 91 65 10 f0       	push   $0xf0106591
f0102488:	e8 07 dc ff ff       	call   f0100094 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f010248d:	68 54 6c 10 f0       	push   $0xf0106c54
f0102492:	68 be 65 10 f0       	push   $0xf01065be
f0102497:	68 ee 03 00 00       	push   $0x3ee
f010249c:	68 91 65 10 f0       	push   $0xf0106591
f01024a1:	e8 ee db ff ff       	call   f0100094 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f01024a6:	68 c8 67 10 f0       	push   $0xf01067c8
f01024ab:	68 be 65 10 f0       	push   $0xf01065be
f01024b0:	68 ef 03 00 00       	push   $0x3ef
f01024b5:	68 91 65 10 f0       	push   $0xf0106591
f01024ba:	e8 d5 db ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01024bf:	68 68 6b 10 f0       	push   $0xf0106b68
f01024c4:	68 be 65 10 f0       	push   $0xf01065be
f01024c9:	68 f2 03 00 00       	push   $0x3f2
f01024ce:	68 91 65 10 f0       	push   $0xf0106591
f01024d3:	e8 bc db ff ff       	call   f0100094 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f01024d8:	68 88 6c 10 f0       	push   $0xf0106c88
f01024dd:	68 be 65 10 f0       	push   $0xf01065be
f01024e2:	68 f3 03 00 00       	push   $0x3f3
f01024e7:	68 91 65 10 f0       	push   $0xf0106591
f01024ec:	e8 a3 db ff ff       	call   f0100094 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01024f1:	68 bc 6c 10 f0       	push   $0xf0106cbc
f01024f6:	68 be 65 10 f0       	push   $0xf01065be
f01024fb:	68 f4 03 00 00       	push   $0x3f4
f0102500:	68 91 65 10 f0       	push   $0xf0106591
f0102505:	e8 8a db ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f010250a:	68 f4 6c 10 f0       	push   $0xf0106cf4
f010250f:	68 be 65 10 f0       	push   $0xf01065be
f0102514:	68 f7 03 00 00       	push   $0x3f7
f0102519:	68 91 65 10 f0       	push   $0xf0106591
f010251e:	e8 71 db ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0102523:	68 2c 6d 10 f0       	push   $0xf0106d2c
f0102528:	68 be 65 10 f0       	push   $0xf01065be
f010252d:	68 fa 03 00 00       	push   $0x3fa
f0102532:	68 91 65 10 f0       	push   $0xf0106591
f0102537:	e8 58 db ff ff       	call   f0100094 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f010253c:	68 bc 6c 10 f0       	push   $0xf0106cbc
f0102541:	68 be 65 10 f0       	push   $0xf01065be
f0102546:	68 fb 03 00 00       	push   $0x3fb
f010254b:	68 91 65 10 f0       	push   $0xf0106591
f0102550:	e8 3f db ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102555:	68 68 6d 10 f0       	push   $0xf0106d68
f010255a:	68 be 65 10 f0       	push   $0xf01065be
f010255f:	68 fe 03 00 00       	push   $0x3fe
f0102564:	68 91 65 10 f0       	push   $0xf0106591
f0102569:	e8 26 db ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010256e:	68 94 6d 10 f0       	push   $0xf0106d94
f0102573:	68 be 65 10 f0       	push   $0xf01065be
f0102578:	68 ff 03 00 00       	push   $0x3ff
f010257d:	68 91 65 10 f0       	push   $0xf0106591
f0102582:	e8 0d db ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 2);
f0102587:	68 de 67 10 f0       	push   $0xf01067de
f010258c:	68 be 65 10 f0       	push   $0xf01065be
f0102591:	68 01 04 00 00       	push   $0x401
f0102596:	68 91 65 10 f0       	push   $0xf0106591
f010259b:	e8 f4 da ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f01025a0:	68 ef 67 10 f0       	push   $0xf01067ef
f01025a5:	68 be 65 10 f0       	push   $0xf01065be
f01025aa:	68 02 04 00 00       	push   $0x402
f01025af:	68 91 65 10 f0       	push   $0xf0106591
f01025b4:	e8 db da ff ff       	call   f0100094 <_panic>
	assert((pp = page_alloc(0)) && pp == pp2);
f01025b9:	68 c4 6d 10 f0       	push   $0xf0106dc4
f01025be:	68 be 65 10 f0       	push   $0xf01065be
f01025c3:	68 05 04 00 00       	push   $0x405
f01025c8:	68 91 65 10 f0       	push   $0xf0106591
f01025cd:	e8 c2 da ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01025d2:	68 e8 6d 10 f0       	push   $0xf0106de8
f01025d7:	68 be 65 10 f0       	push   $0xf01065be
f01025dc:	68 09 04 00 00       	push   $0x409
f01025e1:	68 91 65 10 f0       	push   $0xf0106591
f01025e6:	e8 a9 da ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01025eb:	68 94 6d 10 f0       	push   $0xf0106d94
f01025f0:	68 be 65 10 f0       	push   $0xf01065be
f01025f5:	68 0a 04 00 00       	push   $0x40a
f01025fa:	68 91 65 10 f0       	push   $0xf0106591
f01025ff:	e8 90 da ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 1);
f0102604:	68 95 67 10 f0       	push   $0xf0106795
f0102609:	68 be 65 10 f0       	push   $0xf01065be
f010260e:	68 0b 04 00 00       	push   $0x40b
f0102613:	68 91 65 10 f0       	push   $0xf0106591
f0102618:	e8 77 da ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f010261d:	68 ef 67 10 f0       	push   $0xf01067ef
f0102622:	68 be 65 10 f0       	push   $0xf01065be
f0102627:	68 0c 04 00 00       	push   $0x40c
f010262c:	68 91 65 10 f0       	push   $0xf0106591
f0102631:	e8 5e da ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0102636:	68 0c 6e 10 f0       	push   $0xf0106e0c
f010263b:	68 be 65 10 f0       	push   $0xf01065be
f0102640:	68 0f 04 00 00       	push   $0x40f
f0102645:	68 91 65 10 f0       	push   $0xf0106591
f010264a:	e8 45 da ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref);
f010264f:	68 00 68 10 f0       	push   $0xf0106800
f0102654:	68 be 65 10 f0       	push   $0xf01065be
f0102659:	68 10 04 00 00       	push   $0x410
f010265e:	68 91 65 10 f0       	push   $0xf0106591
f0102663:	e8 2c da ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_link == NULL);
f0102668:	68 0c 68 10 f0       	push   $0xf010680c
f010266d:	68 be 65 10 f0       	push   $0xf01065be
f0102672:	68 11 04 00 00       	push   $0x411
f0102677:	68 91 65 10 f0       	push   $0xf0106591
f010267c:	e8 13 da ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102681:	68 e8 6d 10 f0       	push   $0xf0106de8
f0102686:	68 be 65 10 f0       	push   $0xf01065be
f010268b:	68 15 04 00 00       	push   $0x415
f0102690:	68 91 65 10 f0       	push   $0xf0106591
f0102695:	e8 fa d9 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f010269a:	68 44 6e 10 f0       	push   $0xf0106e44
f010269f:	68 be 65 10 f0       	push   $0xf01065be
f01026a4:	68 16 04 00 00       	push   $0x416
f01026a9:	68 91 65 10 f0       	push   $0xf0106591
f01026ae:	e8 e1 d9 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 0);
f01026b3:	68 21 68 10 f0       	push   $0xf0106821
f01026b8:	68 be 65 10 f0       	push   $0xf01065be
f01026bd:	68 17 04 00 00       	push   $0x417
f01026c2:	68 91 65 10 f0       	push   $0xf0106591
f01026c7:	e8 c8 d9 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f01026cc:	68 ef 67 10 f0       	push   $0xf01067ef
f01026d1:	68 be 65 10 f0       	push   $0xf01065be
f01026d6:	68 18 04 00 00       	push   $0x418
f01026db:	68 91 65 10 f0       	push   $0xf0106591
f01026e0:	e8 af d9 ff ff       	call   f0100094 <_panic>
	assert((pp = page_alloc(0)) && pp == pp1);
f01026e5:	68 6c 6e 10 f0       	push   $0xf0106e6c
f01026ea:	68 be 65 10 f0       	push   $0xf01065be
f01026ef:	68 1b 04 00 00       	push   $0x41b
f01026f4:	68 91 65 10 f0       	push   $0xf0106591
f01026f9:	e8 96 d9 ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f01026fe:	68 43 67 10 f0       	push   $0xf0106743
f0102703:	68 be 65 10 f0       	push   $0xf01065be
f0102708:	68 1e 04 00 00       	push   $0x41e
f010270d:	68 91 65 10 f0       	push   $0xf0106591
f0102712:	e8 7d d9 ff ff       	call   f0100094 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102717:	68 10 6b 10 f0       	push   $0xf0106b10
f010271c:	68 be 65 10 f0       	push   $0xf01065be
f0102721:	68 21 04 00 00       	push   $0x421
f0102726:	68 91 65 10 f0       	push   $0xf0106591
f010272b:	e8 64 d9 ff ff       	call   f0100094 <_panic>
	assert(pp0->pp_ref == 1);
f0102730:	68 a6 67 10 f0       	push   $0xf01067a6
f0102735:	68 be 65 10 f0       	push   $0xf01065be
f010273a:	68 23 04 00 00       	push   $0x423
f010273f:	68 91 65 10 f0       	push   $0xf0106591
f0102744:	e8 4b d9 ff ff       	call   f0100094 <_panic>
f0102749:	50                   	push   %eax
f010274a:	68 54 60 10 f0       	push   $0xf0106054
f010274f:	68 2a 04 00 00       	push   $0x42a
f0102754:	68 91 65 10 f0       	push   $0xf0106591
f0102759:	e8 36 d9 ff ff       	call   f0100094 <_panic>
	assert(ptep == ptep1 + PTX(va));
f010275e:	68 32 68 10 f0       	push   $0xf0106832
f0102763:	68 be 65 10 f0       	push   $0xf01065be
f0102768:	68 2b 04 00 00       	push   $0x42b
f010276d:	68 91 65 10 f0       	push   $0xf0106591
f0102772:	e8 1d d9 ff ff       	call   f0100094 <_panic>
f0102777:	50                   	push   %eax
f0102778:	68 54 60 10 f0       	push   $0xf0106054
f010277d:	6a 58                	push   $0x58
f010277f:	68 a4 65 10 f0       	push   $0xf01065a4
f0102784:	e8 0b d9 ff ff       	call   f0100094 <_panic>
f0102789:	50                   	push   %eax
f010278a:	68 54 60 10 f0       	push   $0xf0106054
f010278f:	6a 58                	push   $0x58
f0102791:	68 a4 65 10 f0       	push   $0xf01065a4
f0102796:	e8 f9 d8 ff ff       	call   f0100094 <_panic>
		assert((ptep[i] & PTE_P) == 0);
f010279b:	68 4a 68 10 f0       	push   $0xf010684a
f01027a0:	68 be 65 10 f0       	push   $0xf01065be
f01027a5:	68 35 04 00 00       	push   $0x435
f01027aa:	68 91 65 10 f0       	push   $0xf0106591
f01027af:	e8 e0 d8 ff ff       	call   f0100094 <_panic>
	assert(mm1 >= MMIOBASE && mm1 + 8192 < MMIOLIM);
f01027b4:	68 90 6e 10 f0       	push   $0xf0106e90
f01027b9:	68 be 65 10 f0       	push   $0xf01065be
f01027be:	68 45 04 00 00       	push   $0x445
f01027c3:	68 91 65 10 f0       	push   $0xf0106591
f01027c8:	e8 c7 d8 ff ff       	call   f0100094 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8192 < MMIOLIM);
f01027cd:	68 b8 6e 10 f0       	push   $0xf0106eb8
f01027d2:	68 be 65 10 f0       	push   $0xf01065be
f01027d7:	68 46 04 00 00       	push   $0x446
f01027dc:	68 91 65 10 f0       	push   $0xf0106591
f01027e1:	e8 ae d8 ff ff       	call   f0100094 <_panic>
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f01027e6:	68 e0 6e 10 f0       	push   $0xf0106ee0
f01027eb:	68 be 65 10 f0       	push   $0xf01065be
f01027f0:	68 48 04 00 00       	push   $0x448
f01027f5:	68 91 65 10 f0       	push   $0xf0106591
f01027fa:	e8 95 d8 ff ff       	call   f0100094 <_panic>
	assert(mm1 + 8192 <= mm2);
f01027ff:	68 61 68 10 f0       	push   $0xf0106861
f0102804:	68 be 65 10 f0       	push   $0xf01065be
f0102809:	68 4a 04 00 00       	push   $0x44a
f010280e:	68 91 65 10 f0       	push   $0xf0106591
f0102813:	e8 7c d8 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0102818:	68 08 6f 10 f0       	push   $0xf0106f08
f010281d:	68 be 65 10 f0       	push   $0xf01065be
f0102822:	68 4c 04 00 00       	push   $0x44c
f0102827:	68 91 65 10 f0       	push   $0xf0106591
f010282c:	e8 63 d8 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0102831:	68 2c 6f 10 f0       	push   $0xf0106f2c
f0102836:	68 be 65 10 f0       	push   $0xf01065be
f010283b:	68 4d 04 00 00       	push   $0x44d
f0102840:	68 91 65 10 f0       	push   $0xf0106591
f0102845:	e8 4a d8 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f010284a:	68 5c 6f 10 f0       	push   $0xf0106f5c
f010284f:	68 be 65 10 f0       	push   $0xf01065be
f0102854:	68 4e 04 00 00       	push   $0x44e
f0102859:	68 91 65 10 f0       	push   $0xf0106591
f010285e:	e8 31 d8 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0102863:	68 80 6f 10 f0       	push   $0xf0106f80
f0102868:	68 be 65 10 f0       	push   $0xf01065be
f010286d:	68 4f 04 00 00       	push   $0x44f
f0102872:	68 91 65 10 f0       	push   $0xf0106591
f0102877:	e8 18 d8 ff ff       	call   f0100094 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f010287c:	68 ac 6f 10 f0       	push   $0xf0106fac
f0102881:	68 be 65 10 f0       	push   $0xf01065be
f0102886:	68 51 04 00 00       	push   $0x451
f010288b:	68 91 65 10 f0       	push   $0xf0106591
f0102890:	e8 ff d7 ff ff       	call   f0100094 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102895:	68 f0 6f 10 f0       	push   $0xf0106ff0
f010289a:	68 be 65 10 f0       	push   $0xf01065be
f010289f:	68 52 04 00 00       	push   $0x452
f01028a4:	68 91 65 10 f0       	push   $0xf0106591
f01028a9:	e8 e6 d7 ff ff       	call   f0100094 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01028ae:	50                   	push   %eax
f01028af:	68 78 60 10 f0       	push   $0xf0106078
f01028b4:	68 d2 00 00 00       	push   $0xd2
f01028b9:	68 91 65 10 f0       	push   $0xf0106591
f01028be:	e8 d1 d7 ff ff       	call   f0100094 <_panic>
f01028c3:	50                   	push   %eax
f01028c4:	68 78 60 10 f0       	push   $0xf0106078
f01028c9:	68 db 00 00 00       	push   $0xdb
f01028ce:	68 91 65 10 f0       	push   $0xf0106591
f01028d3:	e8 bc d7 ff ff       	call   f0100094 <_panic>
f01028d8:	50                   	push   %eax
f01028d9:	68 78 60 10 f0       	push   $0xf0106078
f01028de:	68 e8 00 00 00       	push   $0xe8
f01028e3:	68 91 65 10 f0       	push   $0xf0106591
f01028e8:	e8 a7 d7 ff ff       	call   f0100094 <_panic>
f01028ed:	53                   	push   %ebx
f01028ee:	68 78 60 10 f0       	push   $0xf0106078
f01028f3:	68 2c 01 00 00       	push   $0x12c
f01028f8:	68 91 65 10 f0       	push   $0xf0106591
f01028fd:	e8 92 d7 ff ff       	call   f0100094 <_panic>
f0102902:	56                   	push   %esi
f0102903:	68 78 60 10 f0       	push   $0xf0106078
f0102908:	68 65 03 00 00       	push   $0x365
f010290d:	68 91 65 10 f0       	push   $0xf0106591
f0102912:	e8 7d d7 ff ff       	call   f0100094 <_panic>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102917:	68 24 70 10 f0       	push   $0xf0107024
f010291c:	68 be 65 10 f0       	push   $0xf01065be
f0102921:	68 65 03 00 00       	push   $0x365
f0102926:	68 91 65 10 f0       	push   $0xf0106591
f010292b:	e8 64 d7 ff ff       	call   f0100094 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102930:	a1 44 52 23 f0       	mov    0xf0235244,%eax
f0102935:	89 45 cc             	mov    %eax,-0x34(%ebp)
	if ((uint32_t)kva < KERNBASE)
f0102938:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010293b:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f0102940:	8d b0 00 00 40 21    	lea    0x21400000(%eax),%esi
f0102946:	89 da                	mov    %ebx,%edx
f0102948:	89 f8                	mov    %edi,%eax
f010294a:	e8 c9 e1 ff ff       	call   f0100b18 <check_va2pa>
f010294f:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f0102956:	76 3d                	jbe    f0102995 <mem_init+0x1677>
f0102958:	8d 14 1e             	lea    (%esi,%ebx,1),%edx
f010295b:	39 d0                	cmp    %edx,%eax
f010295d:	75 4d                	jne    f01029ac <mem_init+0x168e>
f010295f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE) {
f0102965:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f010296b:	75 d9                	jne    f0102946 <mem_init+0x1628>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f010296d:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0102970:	c1 e6 0c             	shl    $0xc,%esi
f0102973:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102978:	39 f3                	cmp    %esi,%ebx
f010297a:	73 62                	jae    f01029de <mem_init+0x16c0>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f010297c:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f0102982:	89 f8                	mov    %edi,%eax
f0102984:	e8 8f e1 ff ff       	call   f0100b18 <check_va2pa>
f0102989:	39 c3                	cmp    %eax,%ebx
f010298b:	75 38                	jne    f01029c5 <mem_init+0x16a7>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f010298d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102993:	eb e3                	jmp    f0102978 <mem_init+0x165a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102995:	ff 75 cc             	pushl  -0x34(%ebp)
f0102998:	68 78 60 10 f0       	push   $0xf0106078
f010299d:	68 6c 03 00 00       	push   $0x36c
f01029a2:	68 91 65 10 f0       	push   $0xf0106591
f01029a7:	e8 e8 d6 ff ff       	call   f0100094 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f01029ac:	68 58 70 10 f0       	push   $0xf0107058
f01029b1:	68 be 65 10 f0       	push   $0xf01065be
f01029b6:	68 6c 03 00 00       	push   $0x36c
f01029bb:	68 91 65 10 f0       	push   $0xf0106591
f01029c0:	e8 cf d6 ff ff       	call   f0100094 <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f01029c5:	68 8c 70 10 f0       	push   $0xf010708c
f01029ca:	68 be 65 10 f0       	push   $0xf01065be
f01029cf:	68 73 03 00 00       	push   $0x373
f01029d4:	68 91 65 10 f0       	push   $0xf0106591
f01029d9:	e8 b6 d6 ff ff       	call   f0100094 <_panic>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01029de:	b8 00 70 23 f0       	mov    $0xf0237000,%eax
f01029e3:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f01029e8:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f01029eb:	89 c7                	mov    %eax,%edi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f01029ed:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f01029f0:	89 f3                	mov    %esi,%ebx
f01029f2:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01029f5:	05 00 80 00 20       	add    $0x20008000,%eax
f01029fa:	89 45 cc             	mov    %eax,-0x34(%ebp)
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f01029fd:	8d 86 00 80 00 00    	lea    0x8000(%esi),%eax
f0102a03:	89 45 c8             	mov    %eax,-0x38(%ebp)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102a06:	89 da                	mov    %ebx,%edx
f0102a08:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102a0b:	e8 08 e1 ff ff       	call   f0100b18 <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f0102a10:	81 ff ff ff ff ef    	cmp    $0xefffffff,%edi
f0102a16:	76 59                	jbe    f0102a71 <mem_init+0x1753>
f0102a18:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0102a1b:	8d 14 19             	lea    (%ecx,%ebx,1),%edx
f0102a1e:	39 d0                	cmp    %edx,%eax
f0102a20:	75 66                	jne    f0102a88 <mem_init+0x176a>
f0102a22:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102a28:	3b 5d c8             	cmp    -0x38(%ebp),%ebx
f0102a2b:	75 d9                	jne    f0102a06 <mem_init+0x16e8>
f0102a2d:	8d 9e 00 80 ff ff    	lea    -0x8000(%esi),%ebx
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102a33:	89 da                	mov    %ebx,%edx
f0102a35:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102a38:	e8 db e0 ff ff       	call   f0100b18 <check_va2pa>
f0102a3d:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102a40:	75 5f                	jne    f0102aa1 <mem_init+0x1783>
f0102a42:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0102a48:	39 f3                	cmp    %esi,%ebx
f0102a4a:	75 e7                	jne    f0102a33 <mem_init+0x1715>
f0102a4c:	81 ee 00 00 01 00    	sub    $0x10000,%esi
f0102a52:	81 45 d0 00 80 01 00 	addl   $0x18000,-0x30(%ebp)
f0102a59:	81 c7 00 80 00 00    	add    $0x8000,%edi
	for (n = 0; n < NCPU; n++) {
f0102a5f:	81 ff 00 70 27 f0    	cmp    $0xf0277000,%edi
f0102a65:	75 86                	jne    f01029ed <mem_init+0x16cf>
f0102a67:	8b 7d d4             	mov    -0x2c(%ebp),%edi
	for (i = 0; i < NPDENTRIES; i++) {
f0102a6a:	b8 00 00 00 00       	mov    $0x0,%eax
f0102a6f:	eb 7f                	jmp    f0102af0 <mem_init+0x17d2>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102a71:	ff 75 c4             	pushl  -0x3c(%ebp)
f0102a74:	68 78 60 10 f0       	push   $0xf0106078
f0102a79:	68 7c 03 00 00       	push   $0x37c
f0102a7e:	68 91 65 10 f0       	push   $0xf0106591
f0102a83:	e8 0c d6 ff ff       	call   f0100094 <_panic>
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102a88:	68 b4 70 10 f0       	push   $0xf01070b4
f0102a8d:	68 be 65 10 f0       	push   $0xf01065be
f0102a92:	68 7c 03 00 00       	push   $0x37c
f0102a97:	68 91 65 10 f0       	push   $0xf0106591
f0102a9c:	e8 f3 d5 ff ff       	call   f0100094 <_panic>
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102aa1:	68 fc 70 10 f0       	push   $0xf01070fc
f0102aa6:	68 be 65 10 f0       	push   $0xf01065be
f0102aab:	68 7e 03 00 00       	push   $0x37e
f0102ab0:	68 91 65 10 f0       	push   $0xf0106591
f0102ab5:	e8 da d5 ff ff       	call   f0100094 <_panic>
			assert(pgdir[i] & PTE_P);
f0102aba:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f0102abe:	75 48                	jne    f0102b08 <mem_init+0x17ea>
f0102ac0:	68 8c 68 10 f0       	push   $0xf010688c
f0102ac5:	68 be 65 10 f0       	push   $0xf01065be
f0102aca:	68 89 03 00 00       	push   $0x389
f0102acf:	68 91 65 10 f0       	push   $0xf0106591
f0102ad4:	e8 bb d5 ff ff       	call   f0100094 <_panic>
				assert(pgdir[i] & PTE_P);
f0102ad9:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0102adc:	f6 c2 01             	test   $0x1,%dl
f0102adf:	74 2c                	je     f0102b0d <mem_init+0x17ef>
				assert(pgdir[i] & PTE_W);
f0102ae1:	f6 c2 02             	test   $0x2,%dl
f0102ae4:	74 40                	je     f0102b26 <mem_init+0x1808>
	for (i = 0; i < NPDENTRIES; i++) {
f0102ae6:	83 c0 01             	add    $0x1,%eax
f0102ae9:	3d 00 04 00 00       	cmp    $0x400,%eax
f0102aee:	74 68                	je     f0102b58 <mem_init+0x183a>
		switch (i) {
f0102af0:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0102af6:	83 fa 04             	cmp    $0x4,%edx
f0102af9:	76 bf                	jbe    f0102aba <mem_init+0x179c>
			if (i >= PDX(KERNBASE)) {
f0102afb:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102b00:	77 d7                	ja     f0102ad9 <mem_init+0x17bb>
				assert(pgdir[i] == 0);
f0102b02:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f0102b06:	75 37                	jne    f0102b3f <mem_init+0x1821>
	for (i = 0; i < NPDENTRIES; i++) {
f0102b08:	83 c0 01             	add    $0x1,%eax
f0102b0b:	eb e3                	jmp    f0102af0 <mem_init+0x17d2>
				assert(pgdir[i] & PTE_P);
f0102b0d:	68 8c 68 10 f0       	push   $0xf010688c
f0102b12:	68 be 65 10 f0       	push   $0xf01065be
f0102b17:	68 8d 03 00 00       	push   $0x38d
f0102b1c:	68 91 65 10 f0       	push   $0xf0106591
f0102b21:	e8 6e d5 ff ff       	call   f0100094 <_panic>
				assert(pgdir[i] & PTE_W);
f0102b26:	68 9d 68 10 f0       	push   $0xf010689d
f0102b2b:	68 be 65 10 f0       	push   $0xf01065be
f0102b30:	68 8e 03 00 00       	push   $0x38e
f0102b35:	68 91 65 10 f0       	push   $0xf0106591
f0102b3a:	e8 55 d5 ff ff       	call   f0100094 <_panic>
				assert(pgdir[i] == 0);
f0102b3f:	68 ae 68 10 f0       	push   $0xf01068ae
f0102b44:	68 be 65 10 f0       	push   $0xf01065be
f0102b49:	68 90 03 00 00       	push   $0x390
f0102b4e:	68 91 65 10 f0       	push   $0xf0106591
f0102b53:	e8 3c d5 ff ff       	call   f0100094 <_panic>
	cprintf("check_kern_pgdir() succeeded!\n");
f0102b58:	83 ec 0c             	sub    $0xc,%esp
f0102b5b:	68 20 71 10 f0       	push   $0xf0107120
f0102b60:	e8 bb 0c 00 00       	call   f0103820 <cprintf>
	lcr3(PADDR(kern_pgdir));
f0102b65:	a1 8c 5e 23 f0       	mov    0xf0235e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f0102b6a:	83 c4 10             	add    $0x10,%esp
f0102b6d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102b72:	0f 86 fb 01 00 00    	jbe    f0102d73 <mem_init+0x1a55>
	return (physaddr_t)kva - KERNBASE;
f0102b78:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102b7d:	0f 22 d8             	mov    %eax,%cr3
	check_page_free_list(0);
f0102b80:	b8 00 00 00 00       	mov    $0x0,%eax
f0102b85:	e8 f2 df ff ff       	call   f0100b7c <check_page_free_list>
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0102b8a:	0f 20 c0             	mov    %cr0,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f0102b8d:	83 e0 f3             	and    $0xfffffff3,%eax
f0102b90:	0d 23 00 05 80       	or     $0x80050023,%eax
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0102b95:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102b98:	83 ec 0c             	sub    $0xc,%esp
f0102b9b:	6a 00                	push   $0x0
f0102b9d:	e8 ef e3 ff ff       	call   f0100f91 <page_alloc>
f0102ba2:	89 c6                	mov    %eax,%esi
f0102ba4:	83 c4 10             	add    $0x10,%esp
f0102ba7:	85 c0                	test   %eax,%eax
f0102ba9:	0f 84 d9 01 00 00    	je     f0102d88 <mem_init+0x1a6a>
	assert((pp1 = page_alloc(0)));
f0102baf:	83 ec 0c             	sub    $0xc,%esp
f0102bb2:	6a 00                	push   $0x0
f0102bb4:	e8 d8 e3 ff ff       	call   f0100f91 <page_alloc>
f0102bb9:	89 c7                	mov    %eax,%edi
f0102bbb:	83 c4 10             	add    $0x10,%esp
f0102bbe:	85 c0                	test   %eax,%eax
f0102bc0:	0f 84 db 01 00 00    	je     f0102da1 <mem_init+0x1a83>
	assert((pp2 = page_alloc(0)));
f0102bc6:	83 ec 0c             	sub    $0xc,%esp
f0102bc9:	6a 00                	push   $0x0
f0102bcb:	e8 c1 e3 ff ff       	call   f0100f91 <page_alloc>
f0102bd0:	89 c3                	mov    %eax,%ebx
f0102bd2:	83 c4 10             	add    $0x10,%esp
f0102bd5:	85 c0                	test   %eax,%eax
f0102bd7:	0f 84 dd 01 00 00    	je     f0102dba <mem_init+0x1a9c>
	page_free(pp0);
f0102bdd:	83 ec 0c             	sub    $0xc,%esp
f0102be0:	56                   	push   %esi
f0102be1:	e8 1d e4 ff ff       	call   f0101003 <page_free>
	return (pp - pages) << PGSHIFT;
f0102be6:	89 f8                	mov    %edi,%eax
f0102be8:	2b 05 90 5e 23 f0    	sub    0xf0235e90,%eax
f0102bee:	c1 f8 03             	sar    $0x3,%eax
f0102bf1:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102bf4:	89 c2                	mov    %eax,%edx
f0102bf6:	c1 ea 0c             	shr    $0xc,%edx
f0102bf9:	83 c4 10             	add    $0x10,%esp
f0102bfc:	3b 15 88 5e 23 f0    	cmp    0xf0235e88,%edx
f0102c02:	0f 83 cb 01 00 00    	jae    f0102dd3 <mem_init+0x1ab5>
	memset(page2kva(pp1), 1, PGSIZE);
f0102c08:	83 ec 04             	sub    $0x4,%esp
f0102c0b:	68 00 10 00 00       	push   $0x1000
f0102c10:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0102c12:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102c17:	50                   	push   %eax
f0102c18:	e8 3e 27 00 00       	call   f010535b <memset>
	return (pp - pages) << PGSHIFT;
f0102c1d:	89 d8                	mov    %ebx,%eax
f0102c1f:	2b 05 90 5e 23 f0    	sub    0xf0235e90,%eax
f0102c25:	c1 f8 03             	sar    $0x3,%eax
f0102c28:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102c2b:	89 c2                	mov    %eax,%edx
f0102c2d:	c1 ea 0c             	shr    $0xc,%edx
f0102c30:	83 c4 10             	add    $0x10,%esp
f0102c33:	3b 15 88 5e 23 f0    	cmp    0xf0235e88,%edx
f0102c39:	0f 83 a6 01 00 00    	jae    f0102de5 <mem_init+0x1ac7>
	memset(page2kva(pp2), 2, PGSIZE);
f0102c3f:	83 ec 04             	sub    $0x4,%esp
f0102c42:	68 00 10 00 00       	push   $0x1000
f0102c47:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f0102c49:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102c4e:	50                   	push   %eax
f0102c4f:	e8 07 27 00 00       	call   f010535b <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102c54:	6a 02                	push   $0x2
f0102c56:	68 00 10 00 00       	push   $0x1000
f0102c5b:	57                   	push   %edi
f0102c5c:	ff 35 8c 5e 23 f0    	pushl  0xf0235e8c
f0102c62:	e8 eb e5 ff ff       	call   f0101252 <page_insert>
	assert(pp1->pp_ref == 1);
f0102c67:	83 c4 20             	add    $0x20,%esp
f0102c6a:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102c6f:	0f 85 82 01 00 00    	jne    f0102df7 <mem_init+0x1ad9>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102c75:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102c7c:	01 01 01 
f0102c7f:	0f 85 8b 01 00 00    	jne    f0102e10 <mem_init+0x1af2>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102c85:	6a 02                	push   $0x2
f0102c87:	68 00 10 00 00       	push   $0x1000
f0102c8c:	53                   	push   %ebx
f0102c8d:	ff 35 8c 5e 23 f0    	pushl  0xf0235e8c
f0102c93:	e8 ba e5 ff ff       	call   f0101252 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102c98:	83 c4 10             	add    $0x10,%esp
f0102c9b:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102ca2:	02 02 02 
f0102ca5:	0f 85 7e 01 00 00    	jne    f0102e29 <mem_init+0x1b0b>
	assert(pp2->pp_ref == 1);
f0102cab:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102cb0:	0f 85 8c 01 00 00    	jne    f0102e42 <mem_init+0x1b24>
	assert(pp1->pp_ref == 0);
f0102cb6:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102cbb:	0f 85 9a 01 00 00    	jne    f0102e5b <mem_init+0x1b3d>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102cc1:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102cc8:	03 03 03 
	return (pp - pages) << PGSHIFT;
f0102ccb:	89 d8                	mov    %ebx,%eax
f0102ccd:	2b 05 90 5e 23 f0    	sub    0xf0235e90,%eax
f0102cd3:	c1 f8 03             	sar    $0x3,%eax
f0102cd6:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102cd9:	89 c2                	mov    %eax,%edx
f0102cdb:	c1 ea 0c             	shr    $0xc,%edx
f0102cde:	3b 15 88 5e 23 f0    	cmp    0xf0235e88,%edx
f0102ce4:	0f 83 8a 01 00 00    	jae    f0102e74 <mem_init+0x1b56>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102cea:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102cf1:	03 03 03 
f0102cf4:	0f 85 8c 01 00 00    	jne    f0102e86 <mem_init+0x1b68>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102cfa:	83 ec 08             	sub    $0x8,%esp
f0102cfd:	68 00 10 00 00       	push   $0x1000
f0102d02:	ff 35 8c 5e 23 f0    	pushl  0xf0235e8c
f0102d08:	e8 ff e4 ff ff       	call   f010120c <page_remove>
	assert(pp2->pp_ref == 0);
f0102d0d:	83 c4 10             	add    $0x10,%esp
f0102d10:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102d15:	0f 85 84 01 00 00    	jne    f0102e9f <mem_init+0x1b81>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102d1b:	8b 0d 8c 5e 23 f0    	mov    0xf0235e8c,%ecx
f0102d21:	8b 11                	mov    (%ecx),%edx
f0102d23:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	return (pp - pages) << PGSHIFT;
f0102d29:	89 f0                	mov    %esi,%eax
f0102d2b:	2b 05 90 5e 23 f0    	sub    0xf0235e90,%eax
f0102d31:	c1 f8 03             	sar    $0x3,%eax
f0102d34:	c1 e0 0c             	shl    $0xc,%eax
f0102d37:	39 c2                	cmp    %eax,%edx
f0102d39:	0f 85 79 01 00 00    	jne    f0102eb8 <mem_init+0x1b9a>
	kern_pgdir[0] = 0;
f0102d3f:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102d45:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102d4a:	0f 85 81 01 00 00    	jne    f0102ed1 <mem_init+0x1bb3>
	pp0->pp_ref = 0;
f0102d50:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f0102d56:	83 ec 0c             	sub    $0xc,%esp
f0102d59:	56                   	push   %esi
f0102d5a:	e8 a4 e2 ff ff       	call   f0101003 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102d5f:	c7 04 24 b4 71 10 f0 	movl   $0xf01071b4,(%esp)
f0102d66:	e8 b5 0a 00 00       	call   f0103820 <cprintf>
}
f0102d6b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102d6e:	5b                   	pop    %ebx
f0102d6f:	5e                   	pop    %esi
f0102d70:	5f                   	pop    %edi
f0102d71:	5d                   	pop    %ebp
f0102d72:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102d73:	50                   	push   %eax
f0102d74:	68 78 60 10 f0       	push   $0xf0106078
f0102d79:	68 04 01 00 00       	push   $0x104
f0102d7e:	68 91 65 10 f0       	push   $0xf0106591
f0102d83:	e8 0c d3 ff ff       	call   f0100094 <_panic>
	assert((pp0 = page_alloc(0)));
f0102d88:	68 98 66 10 f0       	push   $0xf0106698
f0102d8d:	68 be 65 10 f0       	push   $0xf01065be
f0102d92:	68 67 04 00 00       	push   $0x467
f0102d97:	68 91 65 10 f0       	push   $0xf0106591
f0102d9c:	e8 f3 d2 ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f0102da1:	68 ae 66 10 f0       	push   $0xf01066ae
f0102da6:	68 be 65 10 f0       	push   $0xf01065be
f0102dab:	68 68 04 00 00       	push   $0x468
f0102db0:	68 91 65 10 f0       	push   $0xf0106591
f0102db5:	e8 da d2 ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f0102dba:	68 c4 66 10 f0       	push   $0xf01066c4
f0102dbf:	68 be 65 10 f0       	push   $0xf01065be
f0102dc4:	68 69 04 00 00       	push   $0x469
f0102dc9:	68 91 65 10 f0       	push   $0xf0106591
f0102dce:	e8 c1 d2 ff ff       	call   f0100094 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102dd3:	50                   	push   %eax
f0102dd4:	68 54 60 10 f0       	push   $0xf0106054
f0102dd9:	6a 58                	push   $0x58
f0102ddb:	68 a4 65 10 f0       	push   $0xf01065a4
f0102de0:	e8 af d2 ff ff       	call   f0100094 <_panic>
f0102de5:	50                   	push   %eax
f0102de6:	68 54 60 10 f0       	push   $0xf0106054
f0102deb:	6a 58                	push   $0x58
f0102ded:	68 a4 65 10 f0       	push   $0xf01065a4
f0102df2:	e8 9d d2 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 1);
f0102df7:	68 95 67 10 f0       	push   $0xf0106795
f0102dfc:	68 be 65 10 f0       	push   $0xf01065be
f0102e01:	68 6e 04 00 00       	push   $0x46e
f0102e06:	68 91 65 10 f0       	push   $0xf0106591
f0102e0b:	e8 84 d2 ff ff       	call   f0100094 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102e10:	68 40 71 10 f0       	push   $0xf0107140
f0102e15:	68 be 65 10 f0       	push   $0xf01065be
f0102e1a:	68 6f 04 00 00       	push   $0x46f
f0102e1f:	68 91 65 10 f0       	push   $0xf0106591
f0102e24:	e8 6b d2 ff ff       	call   f0100094 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102e29:	68 64 71 10 f0       	push   $0xf0107164
f0102e2e:	68 be 65 10 f0       	push   $0xf01065be
f0102e33:	68 71 04 00 00       	push   $0x471
f0102e38:	68 91 65 10 f0       	push   $0xf0106591
f0102e3d:	e8 52 d2 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f0102e42:	68 b7 67 10 f0       	push   $0xf01067b7
f0102e47:	68 be 65 10 f0       	push   $0xf01065be
f0102e4c:	68 72 04 00 00       	push   $0x472
f0102e51:	68 91 65 10 f0       	push   $0xf0106591
f0102e56:	e8 39 d2 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 0);
f0102e5b:	68 21 68 10 f0       	push   $0xf0106821
f0102e60:	68 be 65 10 f0       	push   $0xf01065be
f0102e65:	68 73 04 00 00       	push   $0x473
f0102e6a:	68 91 65 10 f0       	push   $0xf0106591
f0102e6f:	e8 20 d2 ff ff       	call   f0100094 <_panic>
f0102e74:	50                   	push   %eax
f0102e75:	68 54 60 10 f0       	push   $0xf0106054
f0102e7a:	6a 58                	push   $0x58
f0102e7c:	68 a4 65 10 f0       	push   $0xf01065a4
f0102e81:	e8 0e d2 ff ff       	call   f0100094 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102e86:	68 88 71 10 f0       	push   $0xf0107188
f0102e8b:	68 be 65 10 f0       	push   $0xf01065be
f0102e90:	68 75 04 00 00       	push   $0x475
f0102e95:	68 91 65 10 f0       	push   $0xf0106591
f0102e9a:	e8 f5 d1 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f0102e9f:	68 ef 67 10 f0       	push   $0xf01067ef
f0102ea4:	68 be 65 10 f0       	push   $0xf01065be
f0102ea9:	68 77 04 00 00       	push   $0x477
f0102eae:	68 91 65 10 f0       	push   $0xf0106591
f0102eb3:	e8 dc d1 ff ff       	call   f0100094 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102eb8:	68 10 6b 10 f0       	push   $0xf0106b10
f0102ebd:	68 be 65 10 f0       	push   $0xf01065be
f0102ec2:	68 7a 04 00 00       	push   $0x47a
f0102ec7:	68 91 65 10 f0       	push   $0xf0106591
f0102ecc:	e8 c3 d1 ff ff       	call   f0100094 <_panic>
	assert(pp0->pp_ref == 1);
f0102ed1:	68 a6 67 10 f0       	push   $0xf01067a6
f0102ed6:	68 be 65 10 f0       	push   $0xf01065be
f0102edb:	68 7c 04 00 00       	push   $0x47c
f0102ee0:	68 91 65 10 f0       	push   $0xf0106591
f0102ee5:	e8 aa d1 ff ff       	call   f0100094 <_panic>

f0102eea <user_mem_check>:
}
f0102eea:	b8 00 00 00 00       	mov    $0x0,%eax
f0102eef:	c3                   	ret    

f0102ef0 <user_mem_assert>:
}
f0102ef0:	c3                   	ret    

f0102ef1 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0102ef1:	55                   	push   %ebp
f0102ef2:	89 e5                	mov    %esp,%ebp
f0102ef4:	57                   	push   %edi
f0102ef5:	56                   	push   %esi
f0102ef6:	53                   	push   %ebx
f0102ef7:	83 ec 0c             	sub    $0xc,%esp
f0102efa:	89 c7                	mov    %eax,%edi
	// LAB 3: Your code here.
	void* i;
	for (i = ROUNDDOWN(va, PGSIZE); i < ROUNDUP(va + len, PGSIZE); i+=PGSIZE){
f0102efc:	89 d3                	mov    %edx,%ebx
f0102efe:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0102f04:	8d b4 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%esi
f0102f0b:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
f0102f11:	39 f3                	cmp    %esi,%ebx
f0102f13:	73 5c                	jae    f0102f71 <region_alloc+0x80>
		struct PageInfo *pginfo = page_alloc(0);
f0102f15:	83 ec 0c             	sub    $0xc,%esp
f0102f18:	6a 00                	push   $0x0
f0102f1a:	e8 72 e0 ff ff       	call   f0100f91 <page_alloc>
		if (!pginfo) {
f0102f1f:	83 c4 10             	add    $0x10,%esp
f0102f22:	85 c0                	test   %eax,%eax
f0102f24:	74 20                	je     f0102f46 <region_alloc+0x55>
			 panic("region_alloc:%e", -E_NO_MEM);
		}
		pginfo->pp_ref++;
f0102f26:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
		int r = page_insert(e->env_pgdir, pginfo, i, PTE_W | PTE_U | PTE_P);
f0102f2b:	6a 07                	push   $0x7
f0102f2d:	53                   	push   %ebx
f0102f2e:	50                   	push   %eax
f0102f2f:	ff 77 60             	pushl  0x60(%edi)
f0102f32:	e8 1b e3 ff ff       	call   f0101252 <page_insert>
		if (r < 0) {
f0102f37:	83 c4 10             	add    $0x10,%esp
f0102f3a:	85 c0                	test   %eax,%eax
f0102f3c:	78 1e                	js     f0102f5c <region_alloc+0x6b>
	for (i = ROUNDDOWN(va, PGSIZE); i < ROUNDUP(va + len, PGSIZE); i+=PGSIZE){
f0102f3e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102f44:	eb cb                	jmp    f0102f11 <region_alloc+0x20>
			 panic("region_alloc:%e", -E_NO_MEM);
f0102f46:	6a fc                	push   $0xfffffffc
f0102f48:	68 dd 71 10 f0       	push   $0xf01071dd
f0102f4d:	68 2c 01 00 00       	push   $0x12c
f0102f52:	68 ed 71 10 f0       	push   $0xf01071ed
f0102f57:	e8 38 d1 ff ff       	call   f0100094 <_panic>
			 panic("region_alloc:%e", r);
f0102f5c:	50                   	push   %eax
f0102f5d:	68 dd 71 10 f0       	push   $0xf01071dd
f0102f62:	68 31 01 00 00       	push   $0x131
f0102f67:	68 ed 71 10 f0       	push   $0xf01071ed
f0102f6c:	e8 23 d1 ff ff       	call   f0100094 <_panic>
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
}
f0102f71:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102f74:	5b                   	pop    %ebx
f0102f75:	5e                   	pop    %esi
f0102f76:	5f                   	pop    %edi
f0102f77:	5d                   	pop    %ebp
f0102f78:	c3                   	ret    

f0102f79 <envid2env>:
{
f0102f79:	55                   	push   %ebp
f0102f7a:	89 e5                	mov    %esp,%ebp
f0102f7c:	56                   	push   %esi
f0102f7d:	53                   	push   %ebx
f0102f7e:	8b 45 08             	mov    0x8(%ebp),%eax
f0102f81:	8b 55 10             	mov    0x10(%ebp),%edx
	if (envid == 0) {
f0102f84:	85 c0                	test   %eax,%eax
f0102f86:	74 2e                	je     f0102fb6 <envid2env+0x3d>
	e = &envs[ENVX(envid)];
f0102f88:	89 c3                	mov    %eax,%ebx
f0102f8a:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0102f90:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f0102f93:	03 1d 44 52 23 f0    	add    0xf0235244,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0102f99:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0102f9d:	74 31                	je     f0102fd0 <envid2env+0x57>
f0102f9f:	39 43 48             	cmp    %eax,0x48(%ebx)
f0102fa2:	75 2c                	jne    f0102fd0 <envid2env+0x57>
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0102fa4:	84 d2                	test   %dl,%dl
f0102fa6:	75 38                	jne    f0102fe0 <envid2env+0x67>
	*env_store = e;
f0102fa8:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102fab:	89 18                	mov    %ebx,(%eax)
	return 0;
f0102fad:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102fb2:	5b                   	pop    %ebx
f0102fb3:	5e                   	pop    %esi
f0102fb4:	5d                   	pop    %ebp
f0102fb5:	c3                   	ret    
		*env_store = curenv;
f0102fb6:	e8 9f 29 00 00       	call   f010595a <cpunum>
f0102fbb:	6b c0 74             	imul   $0x74,%eax,%eax
f0102fbe:	8b 80 28 60 23 f0    	mov    -0xfdc9fd8(%eax),%eax
f0102fc4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102fc7:	89 01                	mov    %eax,(%ecx)
		return 0;
f0102fc9:	b8 00 00 00 00       	mov    $0x0,%eax
f0102fce:	eb e2                	jmp    f0102fb2 <envid2env+0x39>
		*env_store = 0;
f0102fd0:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102fd3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102fd9:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102fde:	eb d2                	jmp    f0102fb2 <envid2env+0x39>
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0102fe0:	e8 75 29 00 00       	call   f010595a <cpunum>
f0102fe5:	6b c0 74             	imul   $0x74,%eax,%eax
f0102fe8:	39 98 28 60 23 f0    	cmp    %ebx,-0xfdc9fd8(%eax)
f0102fee:	74 b8                	je     f0102fa8 <envid2env+0x2f>
f0102ff0:	8b 73 4c             	mov    0x4c(%ebx),%esi
f0102ff3:	e8 62 29 00 00       	call   f010595a <cpunum>
f0102ff8:	6b c0 74             	imul   $0x74,%eax,%eax
f0102ffb:	8b 80 28 60 23 f0    	mov    -0xfdc9fd8(%eax),%eax
f0103001:	3b 70 48             	cmp    0x48(%eax),%esi
f0103004:	74 a2                	je     f0102fa8 <envid2env+0x2f>
		*env_store = 0;
f0103006:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103009:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f010300f:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103014:	eb 9c                	jmp    f0102fb2 <envid2env+0x39>

f0103016 <env_init_percpu>:
	asm volatile("lgdt (%0)" : : "r" (p));
f0103016:	b8 20 23 12 f0       	mov    $0xf0122320,%eax
f010301b:	0f 01 10             	lgdtl  (%eax)
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f010301e:	b8 23 00 00 00       	mov    $0x23,%eax
f0103023:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f0103025:	8e e0                	mov    %eax,%fs
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f0103027:	b8 10 00 00 00       	mov    $0x10,%eax
f010302c:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f010302e:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f0103030:	8e d0                	mov    %eax,%ss
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f0103032:	ea 39 30 10 f0 08 00 	ljmp   $0x8,$0xf0103039
	asm volatile("lldt %0" : : "r" (sel));
f0103039:	b8 00 00 00 00       	mov    $0x0,%eax
f010303e:	0f 00 d0             	lldt   %ax
}
f0103041:	c3                   	ret    

f0103042 <env_init>:
{
f0103042:	55                   	push   %ebp
f0103043:	89 e5                	mov    %esp,%ebp
f0103045:	56                   	push   %esi
f0103046:	53                   	push   %ebx
		envs[i].env_id = 0;
f0103047:	8b 35 44 52 23 f0    	mov    0xf0235244,%esi
f010304d:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f0103053:	89 f3                	mov    %esi,%ebx
f0103055:	ba 00 00 00 00       	mov    $0x0,%edx
f010305a:	eb 02                	jmp    f010305e <env_init+0x1c>
f010305c:	89 c8                	mov    %ecx,%eax
f010305e:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_status = ENV_FREE;
f0103065:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
		envs[i].env_link = env_free_list;
f010306c:	89 50 44             	mov    %edx,0x44(%eax)
f010306f:	8d 48 84             	lea    -0x7c(%eax),%ecx
		env_free_list = &envs[i];
f0103072:	89 c2                	mov    %eax,%edx
	for (i = NENV - 1; i >= 0; i--) {
f0103074:	39 d8                	cmp    %ebx,%eax
f0103076:	75 e4                	jne    f010305c <env_init+0x1a>
f0103078:	89 35 48 52 23 f0    	mov    %esi,0xf0235248
	env_init_percpu();
f010307e:	e8 93 ff ff ff       	call   f0103016 <env_init_percpu>
}
f0103083:	5b                   	pop    %ebx
f0103084:	5e                   	pop    %esi
f0103085:	5d                   	pop    %ebp
f0103086:	c3                   	ret    

f0103087 <env_alloc>:
{
f0103087:	55                   	push   %ebp
f0103088:	89 e5                	mov    %esp,%ebp
f010308a:	53                   	push   %ebx
f010308b:	83 ec 04             	sub    $0x4,%esp
	if (!(e = env_free_list))
f010308e:	8b 1d 48 52 23 f0    	mov    0xf0235248,%ebx
f0103094:	85 db                	test   %ebx,%ebx
f0103096:	0f 84 8b 01 00 00    	je     f0103227 <env_alloc+0x1a0>
	if (!(p = page_alloc(ALLOC_ZERO)))
f010309c:	83 ec 0c             	sub    $0xc,%esp
f010309f:	6a 01                	push   $0x1
f01030a1:	e8 eb de ff ff       	call   f0100f91 <page_alloc>
f01030a6:	83 c4 10             	add    $0x10,%esp
f01030a9:	85 c0                	test   %eax,%eax
f01030ab:	0f 84 7d 01 00 00    	je     f010322e <env_alloc+0x1a7>
	return (pp - pages) << PGSHIFT;
f01030b1:	89 c2                	mov    %eax,%edx
f01030b3:	2b 15 90 5e 23 f0    	sub    0xf0235e90,%edx
f01030b9:	c1 fa 03             	sar    $0x3,%edx
f01030bc:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f01030bf:	89 d1                	mov    %edx,%ecx
f01030c1:	c1 e9 0c             	shr    $0xc,%ecx
f01030c4:	3b 0d 88 5e 23 f0    	cmp    0xf0235e88,%ecx
f01030ca:	0f 83 30 01 00 00    	jae    f0103200 <env_alloc+0x179>
	return (void *)(pa + KERNBASE);
f01030d0:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f01030d6:	89 53 60             	mov    %edx,0x60(%ebx)
	p->pp_ref++;
f01030d9:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
f01030de:	b8 00 00 00 00       	mov    $0x0,%eax
		e->env_pgdir[i] = 0;
f01030e3:	8b 53 60             	mov    0x60(%ebx),%edx
f01030e6:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
f01030ed:	83 c0 04             	add    $0x4,%eax
	for(i = 0; i < PDX(UTOP); i++) {
f01030f0:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f01030f5:	75 ec                	jne    f01030e3 <env_alloc+0x5c>
		e->env_pgdir[i] = kern_pgdir[i];
f01030f7:	8b 15 8c 5e 23 f0    	mov    0xf0235e8c,%edx
f01030fd:	8b 0c 02             	mov    (%edx,%eax,1),%ecx
f0103100:	8b 53 60             	mov    0x60(%ebx),%edx
f0103103:	89 0c 02             	mov    %ecx,(%edx,%eax,1)
f0103106:	83 c0 04             	add    $0x4,%eax
	for(i = PDX(UTOP); i < NPDENTRIES; i++) {
f0103109:	3d 00 10 00 00       	cmp    $0x1000,%eax
f010310e:	75 e7                	jne    f01030f7 <env_alloc+0x70>
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0103110:	8b 43 60             	mov    0x60(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f0103113:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103118:	0f 86 f4 00 00 00    	jbe    f0103212 <env_alloc+0x18b>
	return (physaddr_t)kva - KERNBASE;
f010311e:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0103124:	83 ca 05             	or     $0x5,%edx
f0103127:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f010312d:	8b 43 48             	mov    0x48(%ebx),%eax
f0103130:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0103135:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f010313a:	ba 00 10 00 00       	mov    $0x1000,%edx
f010313f:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f0103142:	89 da                	mov    %ebx,%edx
f0103144:	2b 15 44 52 23 f0    	sub    0xf0235244,%edx
f010314a:	c1 fa 02             	sar    $0x2,%edx
f010314d:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f0103153:	09 d0                	or     %edx,%eax
f0103155:	89 43 48             	mov    %eax,0x48(%ebx)
	e->env_parent_id = parent_id;
f0103158:	8b 45 0c             	mov    0xc(%ebp),%eax
f010315b:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f010315e:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0103165:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f010316c:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0103173:	83 ec 04             	sub    $0x4,%esp
f0103176:	6a 44                	push   $0x44
f0103178:	6a 00                	push   $0x0
f010317a:	53                   	push   %ebx
f010317b:	e8 db 21 00 00       	call   f010535b <memset>
	e->env_tf.tf_ds = GD_UD | 3;
f0103180:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0103186:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f010318c:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0103192:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0103199:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	e->env_pgfault_upcall = 0;
f010319f:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)
	e->env_ipc_recving = 0;
f01031a6:	c6 43 68 00          	movb   $0x0,0x68(%ebx)
	env_free_list = e->env_link;
f01031aa:	8b 43 44             	mov    0x44(%ebx),%eax
f01031ad:	a3 48 52 23 f0       	mov    %eax,0xf0235248
	*newenv_store = e;
f01031b2:	8b 45 08             	mov    0x8(%ebp),%eax
f01031b5:	89 18                	mov    %ebx,(%eax)
	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01031b7:	8b 5b 48             	mov    0x48(%ebx),%ebx
f01031ba:	e8 9b 27 00 00       	call   f010595a <cpunum>
f01031bf:	6b c0 74             	imul   $0x74,%eax,%eax
f01031c2:	83 c4 10             	add    $0x10,%esp
f01031c5:	ba 00 00 00 00       	mov    $0x0,%edx
f01031ca:	83 b8 28 60 23 f0 00 	cmpl   $0x0,-0xfdc9fd8(%eax)
f01031d1:	74 11                	je     f01031e4 <env_alloc+0x15d>
f01031d3:	e8 82 27 00 00       	call   f010595a <cpunum>
f01031d8:	6b c0 74             	imul   $0x74,%eax,%eax
f01031db:	8b 80 28 60 23 f0    	mov    -0xfdc9fd8(%eax),%eax
f01031e1:	8b 50 48             	mov    0x48(%eax),%edx
f01031e4:	83 ec 04             	sub    $0x4,%esp
f01031e7:	53                   	push   %ebx
f01031e8:	52                   	push   %edx
f01031e9:	68 f8 71 10 f0       	push   $0xf01071f8
f01031ee:	e8 2d 06 00 00       	call   f0103820 <cprintf>
	return 0;
f01031f3:	83 c4 10             	add    $0x10,%esp
f01031f6:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01031fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01031fe:	c9                   	leave  
f01031ff:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103200:	52                   	push   %edx
f0103201:	68 54 60 10 f0       	push   $0xf0106054
f0103206:	6a 58                	push   $0x58
f0103208:	68 a4 65 10 f0       	push   $0xf01065a4
f010320d:	e8 82 ce ff ff       	call   f0100094 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103212:	50                   	push   %eax
f0103213:	68 78 60 10 f0       	push   $0xf0106078
f0103218:	68 d0 00 00 00       	push   $0xd0
f010321d:	68 ed 71 10 f0       	push   $0xf01071ed
f0103222:	e8 6d ce ff ff       	call   f0100094 <_panic>
		return -E_NO_FREE_ENV;
f0103227:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f010322c:	eb cd                	jmp    f01031fb <env_alloc+0x174>
		return -E_NO_MEM;
f010322e:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0103233:	eb c6                	jmp    f01031fb <env_alloc+0x174>

f0103235 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f0103235:	55                   	push   %ebp
f0103236:	89 e5                	mov    %esp,%ebp
f0103238:	57                   	push   %edi
f0103239:	56                   	push   %esi
f010323a:	53                   	push   %ebx
f010323b:	83 ec 34             	sub    $0x34,%esp
f010323e:	8b 75 08             	mov    0x8(%ebp),%esi
	// LAB 3: Your code here.
	struct 	Env *e;	
	int r = env_alloc(&e, (envid_t)0);
f0103241:	6a 00                	push   $0x0
f0103243:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103246:	50                   	push   %eax
f0103247:	e8 3b fe ff ff       	call   f0103087 <env_alloc>
	if (r < 0) {
f010324c:	83 c4 10             	add    $0x10,%esp
f010324f:	85 c0                	test   %eax,%eax
f0103251:	78 36                	js     f0103289 <env_create+0x54>
		 panic("env_create: %e", r);
	}
//	cprintf("new_env:%p\n",e);
	e->env_type = type;
f0103253:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103256:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103259:	89 47 50             	mov    %eax,0x50(%edi)
	if (elf->e_magic != ELF_MAGIC) {
f010325c:	81 3e 7f 45 4c 46    	cmpl   $0x464c457f,(%esi)
f0103262:	75 3a                	jne    f010329e <env_create+0x69>
	ph = (struct Proghdr *) (binary + elf->e_phoff);
f0103264:	89 f3                	mov    %esi,%ebx
f0103266:	03 5e 1c             	add    0x1c(%esi),%ebx
	eph = ph + elf->e_phnum;
f0103269:	0f b7 46 2c          	movzwl 0x2c(%esi),%eax
f010326d:	c1 e0 05             	shl    $0x5,%eax
f0103270:	01 d8                	add    %ebx,%eax
f0103272:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	lcr3(PADDR(e->env_pgdir));
f0103275:	8b 47 60             	mov    0x60(%edi),%eax
	if ((uint32_t)kva < KERNBASE)
f0103278:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010327d:	76 36                	jbe    f01032b5 <env_create+0x80>
	return (physaddr_t)kva - KERNBASE;
f010327f:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0103284:	0f 22 d8             	mov    %eax,%cr3
f0103287:	eb 5b                	jmp    f01032e4 <env_create+0xaf>
		 panic("env_create: %e", r);
f0103289:	50                   	push   %eax
f010328a:	68 0d 72 10 f0       	push   $0xf010720d
f010328f:	68 9f 01 00 00       	push   $0x19f
f0103294:	68 ed 71 10 f0       	push   $0xf01071ed
f0103299:	e8 f6 cd ff ff       	call   f0100094 <_panic>
		 panic("load_icode: not an Elf file");
f010329e:	83 ec 04             	sub    $0x4,%esp
f01032a1:	68 1c 72 10 f0       	push   $0xf010721c
f01032a6:	68 76 01 00 00       	push   $0x176
f01032ab:	68 ed 71 10 f0       	push   $0xf01071ed
f01032b0:	e8 df cd ff ff       	call   f0100094 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01032b5:	50                   	push   %eax
f01032b6:	68 78 60 10 f0       	push   $0xf0106078
f01032bb:	68 7b 01 00 00       	push   $0x17b
f01032c0:	68 ed 71 10 f0       	push   $0xf01071ed
f01032c5:	e8 ca cd ff ff       	call   f0100094 <_panic>
					 panic("load_icode: file size is greater than memory size");
f01032ca:	83 ec 04             	sub    $0x4,%esp
f01032cd:	68 5c 72 10 f0       	push   $0xf010725c
f01032d2:	68 7f 01 00 00       	push   $0x17f
f01032d7:	68 ed 71 10 f0       	push   $0xf01071ed
f01032dc:	e8 b3 cd ff ff       	call   f0100094 <_panic>
	for (; ph<eph; ph++) {
f01032e1:	83 c3 20             	add    $0x20,%ebx
f01032e4:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f01032e7:	76 47                	jbe    f0103330 <env_create+0xfb>
		if (ph->p_type == ELF_PROG_LOAD) {
f01032e9:	83 3b 01             	cmpl   $0x1,(%ebx)
f01032ec:	75 f3                	jne    f01032e1 <env_create+0xac>
			 if (ph->p_filesz > ph->p_memsz) {
f01032ee:	8b 4b 14             	mov    0x14(%ebx),%ecx
f01032f1:	39 4b 10             	cmp    %ecx,0x10(%ebx)
f01032f4:	77 d4                	ja     f01032ca <env_create+0x95>
			 region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f01032f6:	8b 53 08             	mov    0x8(%ebx),%edx
f01032f9:	89 f8                	mov    %edi,%eax
f01032fb:	e8 f1 fb ff ff       	call   f0102ef1 <region_alloc>
			 memcpy((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
f0103300:	83 ec 04             	sub    $0x4,%esp
f0103303:	ff 73 10             	pushl  0x10(%ebx)
f0103306:	89 f0                	mov    %esi,%eax
f0103308:	03 43 04             	add    0x4(%ebx),%eax
f010330b:	50                   	push   %eax
f010330c:	ff 73 08             	pushl  0x8(%ebx)
f010330f:	e8 f1 20 00 00       	call   f0105405 <memcpy>
			 memset((void *)ph->p_va + ph->p_filesz, 0, ph->p_memsz - ph->p_filesz);
f0103314:	8b 43 10             	mov    0x10(%ebx),%eax
f0103317:	83 c4 0c             	add    $0xc,%esp
f010331a:	8b 53 14             	mov    0x14(%ebx),%edx
f010331d:	29 c2                	sub    %eax,%edx
f010331f:	52                   	push   %edx
f0103320:	6a 00                	push   $0x0
f0103322:	03 43 08             	add    0x8(%ebx),%eax
f0103325:	50                   	push   %eax
f0103326:	e8 30 20 00 00       	call   f010535b <memset>
f010332b:	83 c4 10             	add    $0x10,%esp
f010332e:	eb b1                	jmp    f01032e1 <env_create+0xac>
	e->env_tf.tf_eip = elf->e_entry;
f0103330:	8b 46 18             	mov    0x18(%esi),%eax
f0103333:	89 47 30             	mov    %eax,0x30(%edi)
	region_alloc(e, (void *)USTACKTOP - PGSIZE, PGSIZE);
f0103336:	b9 00 10 00 00       	mov    $0x1000,%ecx
f010333b:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0103340:	89 f8                	mov    %edi,%eax
f0103342:	e8 aa fb ff ff       	call   f0102ef1 <region_alloc>
	lcr3(PADDR(kern_pgdir));
f0103347:	a1 8c 5e 23 f0       	mov    0xf0235e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f010334c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103351:	76 10                	jbe    f0103363 <env_create+0x12e>
	return (physaddr_t)kva - KERNBASE;
f0103353:	05 00 00 00 10       	add    $0x10000000,%eax
f0103358:	0f 22 d8             	mov    %eax,%cr3
//	cprintf("binary:%p\n", binary);
	load_icode(e, binary);
}
f010335b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010335e:	5b                   	pop    %ebx
f010335f:	5e                   	pop    %esi
f0103360:	5f                   	pop    %edi
f0103361:	5d                   	pop    %ebp
f0103362:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103363:	50                   	push   %eax
f0103364:	68 78 60 10 f0       	push   $0xf0106078
f0103369:	68 8e 01 00 00       	push   $0x18e
f010336e:	68 ed 71 10 f0       	push   $0xf01071ed
f0103373:	e8 1c cd ff ff       	call   f0100094 <_panic>

f0103378 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0103378:	55                   	push   %ebp
f0103379:	89 e5                	mov    %esp,%ebp
f010337b:	57                   	push   %edi
f010337c:	56                   	push   %esi
f010337d:	53                   	push   %ebx
f010337e:	83 ec 1c             	sub    $0x1c,%esp
f0103381:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103384:	e8 d1 25 00 00       	call   f010595a <cpunum>
f0103389:	6b c0 74             	imul   $0x74,%eax,%eax
f010338c:	39 b8 28 60 23 f0    	cmp    %edi,-0xfdc9fd8(%eax)
f0103392:	74 48                	je     f01033dc <env_free+0x64>
		lcr3(PADDR(kern_pgdir));

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103394:	8b 5f 48             	mov    0x48(%edi),%ebx
f0103397:	e8 be 25 00 00       	call   f010595a <cpunum>
f010339c:	6b c0 74             	imul   $0x74,%eax,%eax
f010339f:	ba 00 00 00 00       	mov    $0x0,%edx
f01033a4:	83 b8 28 60 23 f0 00 	cmpl   $0x0,-0xfdc9fd8(%eax)
f01033ab:	74 11                	je     f01033be <env_free+0x46>
f01033ad:	e8 a8 25 00 00       	call   f010595a <cpunum>
f01033b2:	6b c0 74             	imul   $0x74,%eax,%eax
f01033b5:	8b 80 28 60 23 f0    	mov    -0xfdc9fd8(%eax),%eax
f01033bb:	8b 50 48             	mov    0x48(%eax),%edx
f01033be:	83 ec 04             	sub    $0x4,%esp
f01033c1:	53                   	push   %ebx
f01033c2:	52                   	push   %edx
f01033c3:	68 38 72 10 f0       	push   $0xf0107238
f01033c8:	e8 53 04 00 00       	call   f0103820 <cprintf>
f01033cd:	83 c4 10             	add    $0x10,%esp
f01033d0:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f01033d7:	e9 a9 00 00 00       	jmp    f0103485 <env_free+0x10d>
		lcr3(PADDR(kern_pgdir));
f01033dc:	a1 8c 5e 23 f0       	mov    0xf0235e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f01033e1:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01033e6:	76 0a                	jbe    f01033f2 <env_free+0x7a>
	return (physaddr_t)kva - KERNBASE;
f01033e8:	05 00 00 00 10       	add    $0x10000000,%eax
f01033ed:	0f 22 d8             	mov    %eax,%cr3
f01033f0:	eb a2                	jmp    f0103394 <env_free+0x1c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01033f2:	50                   	push   %eax
f01033f3:	68 78 60 10 f0       	push   $0xf0106078
f01033f8:	68 b5 01 00 00       	push   $0x1b5
f01033fd:	68 ed 71 10 f0       	push   $0xf01071ed
f0103402:	e8 8d cc ff ff       	call   f0100094 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103407:	56                   	push   %esi
f0103408:	68 54 60 10 f0       	push   $0xf0106054
f010340d:	68 c4 01 00 00       	push   $0x1c4
f0103412:	68 ed 71 10 f0       	push   $0xf01071ed
f0103417:	e8 78 cc ff ff       	call   f0100094 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f010341c:	83 ec 08             	sub    $0x8,%esp
f010341f:	89 d8                	mov    %ebx,%eax
f0103421:	c1 e0 0c             	shl    $0xc,%eax
f0103424:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103427:	50                   	push   %eax
f0103428:	ff 77 60             	pushl  0x60(%edi)
f010342b:	e8 dc dd ff ff       	call   f010120c <page_remove>
f0103430:	83 c4 10             	add    $0x10,%esp
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103433:	83 c3 01             	add    $0x1,%ebx
f0103436:	83 c6 04             	add    $0x4,%esi
f0103439:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f010343f:	74 07                	je     f0103448 <env_free+0xd0>
			if (pt[pteno] & PTE_P)
f0103441:	f6 06 01             	testb  $0x1,(%esi)
f0103444:	74 ed                	je     f0103433 <env_free+0xbb>
f0103446:	eb d4                	jmp    f010341c <env_free+0xa4>
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103448:	8b 47 60             	mov    0x60(%edi),%eax
f010344b:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010344e:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
	if (PGNUM(pa) >= npages)
f0103455:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103458:	3b 05 88 5e 23 f0    	cmp    0xf0235e88,%eax
f010345e:	73 69                	jae    f01034c9 <env_free+0x151>
		page_decref(pa2page(pa));
f0103460:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f0103463:	a1 90 5e 23 f0       	mov    0xf0235e90,%eax
f0103468:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010346b:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f010346e:	50                   	push   %eax
f010346f:	e8 ca db ff ff       	call   f010103e <page_decref>
f0103474:	83 c4 10             	add    $0x10,%esp
f0103477:	83 45 e0 04          	addl   $0x4,-0x20(%ebp)
f010347b:	8b 45 e0             	mov    -0x20(%ebp),%eax
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f010347e:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f0103483:	74 58                	je     f01034dd <env_free+0x165>
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103485:	8b 47 60             	mov    0x60(%edi),%eax
f0103488:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010348b:	8b 34 10             	mov    (%eax,%edx,1),%esi
f010348e:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0103494:	74 e1                	je     f0103477 <env_free+0xff>
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103496:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	if (PGNUM(pa) >= npages)
f010349c:	89 f0                	mov    %esi,%eax
f010349e:	c1 e8 0c             	shr    $0xc,%eax
f01034a1:	89 45 dc             	mov    %eax,-0x24(%ebp)
f01034a4:	39 05 88 5e 23 f0    	cmp    %eax,0xf0235e88
f01034aa:	0f 86 57 ff ff ff    	jbe    f0103407 <env_free+0x8f>
	return (void *)(pa + KERNBASE);
f01034b0:	81 ee 00 00 00 10    	sub    $0x10000000,%esi
f01034b6:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01034b9:	c1 e0 14             	shl    $0x14,%eax
f01034bc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01034bf:	bb 00 00 00 00       	mov    $0x0,%ebx
f01034c4:	e9 78 ff ff ff       	jmp    f0103441 <env_free+0xc9>
		panic("pa2page called with invalid pa");
f01034c9:	83 ec 04             	sub    $0x4,%esp
f01034cc:	68 dc 69 10 f0       	push   $0xf01069dc
f01034d1:	6a 51                	push   $0x51
f01034d3:	68 a4 65 10 f0       	push   $0xf01065a4
f01034d8:	e8 b7 cb ff ff       	call   f0100094 <_panic>
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f01034dd:	8b 47 60             	mov    0x60(%edi),%eax
	if ((uint32_t)kva < KERNBASE)
f01034e0:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01034e5:	76 49                	jbe    f0103530 <env_free+0x1b8>
	e->env_pgdir = 0;
f01034e7:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
	return (physaddr_t)kva - KERNBASE;
f01034ee:	05 00 00 00 10       	add    $0x10000000,%eax
	if (PGNUM(pa) >= npages)
f01034f3:	c1 e8 0c             	shr    $0xc,%eax
f01034f6:	3b 05 88 5e 23 f0    	cmp    0xf0235e88,%eax
f01034fc:	73 47                	jae    f0103545 <env_free+0x1cd>
	page_decref(pa2page(pa));
f01034fe:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f0103501:	8b 15 90 5e 23 f0    	mov    0xf0235e90,%edx
f0103507:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f010350a:	50                   	push   %eax
f010350b:	e8 2e db ff ff       	call   f010103e <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103510:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103517:	a1 48 52 23 f0       	mov    0xf0235248,%eax
f010351c:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f010351f:	89 3d 48 52 23 f0    	mov    %edi,0xf0235248
}
f0103525:	83 c4 10             	add    $0x10,%esp
f0103528:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010352b:	5b                   	pop    %ebx
f010352c:	5e                   	pop    %esi
f010352d:	5f                   	pop    %edi
f010352e:	5d                   	pop    %ebp
f010352f:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103530:	50                   	push   %eax
f0103531:	68 78 60 10 f0       	push   $0xf0106078
f0103536:	68 d2 01 00 00       	push   $0x1d2
f010353b:	68 ed 71 10 f0       	push   $0xf01071ed
f0103540:	e8 4f cb ff ff       	call   f0100094 <_panic>
		panic("pa2page called with invalid pa");
f0103545:	83 ec 04             	sub    $0x4,%esp
f0103548:	68 dc 69 10 f0       	push   $0xf01069dc
f010354d:	6a 51                	push   $0x51
f010354f:	68 a4 65 10 f0       	push   $0xf01065a4
f0103554:	e8 3b cb ff ff       	call   f0100094 <_panic>

f0103559 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0103559:	55                   	push   %ebp
f010355a:	89 e5                	mov    %esp,%ebp
f010355c:	53                   	push   %ebx
f010355d:	83 ec 04             	sub    $0x4,%esp
f0103560:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103563:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0103567:	74 21                	je     f010358a <env_destroy+0x31>
		e->env_status = ENV_DYING;
		return;
	}

	env_free(e);
f0103569:	83 ec 0c             	sub    $0xc,%esp
f010356c:	53                   	push   %ebx
f010356d:	e8 06 fe ff ff       	call   f0103378 <env_free>

	if (curenv == e) {
f0103572:	e8 e3 23 00 00       	call   f010595a <cpunum>
f0103577:	6b c0 74             	imul   $0x74,%eax,%eax
f010357a:	83 c4 10             	add    $0x10,%esp
f010357d:	39 98 28 60 23 f0    	cmp    %ebx,-0xfdc9fd8(%eax)
f0103583:	74 1e                	je     f01035a3 <env_destroy+0x4a>
		curenv = NULL;
		sched_yield();
	}
}
f0103585:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103588:	c9                   	leave  
f0103589:	c3                   	ret    
	if (e->env_status == ENV_RUNNING && curenv != e) {
f010358a:	e8 cb 23 00 00       	call   f010595a <cpunum>
f010358f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103592:	39 98 28 60 23 f0    	cmp    %ebx,-0xfdc9fd8(%eax)
f0103598:	74 cf                	je     f0103569 <env_destroy+0x10>
		e->env_status = ENV_DYING;
f010359a:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f01035a1:	eb e2                	jmp    f0103585 <env_destroy+0x2c>
		curenv = NULL;
f01035a3:	e8 b2 23 00 00       	call   f010595a <cpunum>
f01035a8:	6b c0 74             	imul   $0x74,%eax,%eax
f01035ab:	c7 80 28 60 23 f0 00 	movl   $0x0,-0xfdc9fd8(%eax)
f01035b2:	00 00 00 
		sched_yield();
f01035b5:	e8 6d 0d 00 00       	call   f0104327 <sched_yield>

f01035ba <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f01035ba:	55                   	push   %ebp
f01035bb:	89 e5                	mov    %esp,%ebp
f01035bd:	53                   	push   %ebx
f01035be:	83 ec 04             	sub    $0x4,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f01035c1:	e8 94 23 00 00       	call   f010595a <cpunum>
f01035c6:	6b c0 74             	imul   $0x74,%eax,%eax
f01035c9:	8b 98 28 60 23 f0    	mov    -0xfdc9fd8(%eax),%ebx
f01035cf:	e8 86 23 00 00       	call   f010595a <cpunum>
f01035d4:	89 43 5c             	mov    %eax,0x5c(%ebx)

	asm volatile(
f01035d7:	8b 65 08             	mov    0x8(%ebp),%esp
f01035da:	61                   	popa   
f01035db:	07                   	pop    %es
f01035dc:	1f                   	pop    %ds
f01035dd:	83 c4 08             	add    $0x8,%esp
f01035e0:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f01035e1:	83 ec 04             	sub    $0x4,%esp
f01035e4:	68 4e 72 10 f0       	push   $0xf010724e
f01035e9:	68 09 02 00 00       	push   $0x209
f01035ee:	68 ed 71 10 f0       	push   $0xf01071ed
f01035f3:	e8 9c ca ff ff       	call   f0100094 <_panic>

f01035f8 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f01035f8:	55                   	push   %ebp
f01035f9:	89 e5                	mov    %esp,%ebp
f01035fb:	53                   	push   %ebx
f01035fc:	83 ec 04             	sub    $0x4,%esp
f01035ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	if (curenv && curenv->env_status == ENV_RUNNING) {
f0103602:	e8 53 23 00 00       	call   f010595a <cpunum>
f0103607:	6b c0 74             	imul   $0x74,%eax,%eax
f010360a:	83 b8 28 60 23 f0 00 	cmpl   $0x0,-0xfdc9fd8(%eax)
f0103611:	74 14                	je     f0103627 <env_run+0x2f>
f0103613:	e8 42 23 00 00       	call   f010595a <cpunum>
f0103618:	6b c0 74             	imul   $0x74,%eax,%eax
f010361b:	8b 80 28 60 23 f0    	mov    -0xfdc9fd8(%eax),%eax
f0103621:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103625:	74 42                	je     f0103669 <env_run+0x71>
		 curenv->env_status = ENV_RUNNABLE;
	}
		 curenv = e;
f0103627:	e8 2e 23 00 00       	call   f010595a <cpunum>
f010362c:	6b c0 74             	imul   $0x74,%eax,%eax
f010362f:	89 98 28 60 23 f0    	mov    %ebx,-0xfdc9fd8(%eax)
		 e->env_status = ENV_RUNNING;
f0103635:	c7 43 54 03 00 00 00 	movl   $0x3,0x54(%ebx)
		 e->env_runs++ ;
f010363c:	83 43 58 01          	addl   $0x1,0x58(%ebx)
		 lcr3(PADDR(e->env_pgdir));
f0103640:	8b 43 60             	mov    0x60(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f0103643:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103648:	76 36                	jbe    f0103680 <env_run+0x88>
	return (physaddr_t)kva - KERNBASE;
f010364a:	05 00 00 00 10       	add    $0x10000000,%eax
f010364f:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0103652:	83 ec 0c             	sub    $0xc,%esp
f0103655:	68 c0 23 12 f0       	push   $0xf01223c0
f010365a:	e8 07 26 00 00       	call   f0105c66 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f010365f:	f3 90                	pause  
		 unlock_kernel();
//		 cprintf("tf:%p\n", &e->env_tf);
//		 cprintf("esp:%p\n", e->env_tf.tf_esp);
//		 cprintf("pgdir:%p\n", e->env_pgdir);
		 env_pop_tf(&e->env_tf);
f0103661:	89 1c 24             	mov    %ebx,(%esp)
f0103664:	e8 51 ff ff ff       	call   f01035ba <env_pop_tf>
		 curenv->env_status = ENV_RUNNABLE;
f0103669:	e8 ec 22 00 00       	call   f010595a <cpunum>
f010366e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103671:	8b 80 28 60 23 f0    	mov    -0xfdc9fd8(%eax),%eax
f0103677:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
f010367e:	eb a7                	jmp    f0103627 <env_run+0x2f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103680:	50                   	push   %eax
f0103681:	68 78 60 10 f0       	push   $0xf0106078
f0103686:	68 2d 02 00 00       	push   $0x22d
f010368b:	68 ed 71 10 f0       	push   $0xf01071ed
f0103690:	e8 ff c9 ff ff       	call   f0100094 <_panic>

f0103695 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103695:	55                   	push   %ebp
f0103696:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103698:	8b 45 08             	mov    0x8(%ebp),%eax
f010369b:	ba 70 00 00 00       	mov    $0x70,%edx
f01036a0:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01036a1:	ba 71 00 00 00       	mov    $0x71,%edx
f01036a6:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f01036a7:	0f b6 c0             	movzbl %al,%eax
}
f01036aa:	5d                   	pop    %ebp
f01036ab:	c3                   	ret    

f01036ac <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f01036ac:	55                   	push   %ebp
f01036ad:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01036af:	8b 45 08             	mov    0x8(%ebp),%eax
f01036b2:	ba 70 00 00 00       	mov    $0x70,%edx
f01036b7:	ee                   	out    %al,(%dx)
f01036b8:	8b 45 0c             	mov    0xc(%ebp),%eax
f01036bb:	ba 71 00 00 00       	mov    $0x71,%edx
f01036c0:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f01036c1:	5d                   	pop    %ebp
f01036c2:	c3                   	ret    

f01036c3 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f01036c3:	55                   	push   %ebp
f01036c4:	89 e5                	mov    %esp,%ebp
f01036c6:	56                   	push   %esi
f01036c7:	53                   	push   %ebx
f01036c8:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f01036cb:	66 a3 a8 23 12 f0    	mov    %ax,0xf01223a8
	if (!didinit)
f01036d1:	80 3d 4c 52 23 f0 00 	cmpb   $0x0,0xf023524c
f01036d8:	75 07                	jne    f01036e1 <irq_setmask_8259A+0x1e>
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
}
f01036da:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01036dd:	5b                   	pop    %ebx
f01036de:	5e                   	pop    %esi
f01036df:	5d                   	pop    %ebp
f01036e0:	c3                   	ret    
f01036e1:	89 c6                	mov    %eax,%esi
f01036e3:	ba 21 00 00 00       	mov    $0x21,%edx
f01036e8:	ee                   	out    %al,(%dx)
	outb(IO_PIC2+1, (char)(mask >> 8));
f01036e9:	66 c1 e8 08          	shr    $0x8,%ax
f01036ed:	ba a1 00 00 00       	mov    $0xa1,%edx
f01036f2:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f01036f3:	83 ec 0c             	sub    $0xc,%esp
f01036f6:	68 8e 72 10 f0       	push   $0xf010728e
f01036fb:	e8 20 01 00 00       	call   f0103820 <cprintf>
f0103700:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f0103703:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0103708:	0f b7 f6             	movzwl %si,%esi
f010370b:	f7 d6                	not    %esi
f010370d:	eb 19                	jmp    f0103728 <irq_setmask_8259A+0x65>
			cprintf(" %d", i);
f010370f:	83 ec 08             	sub    $0x8,%esp
f0103712:	53                   	push   %ebx
f0103713:	68 ef 77 10 f0       	push   $0xf01077ef
f0103718:	e8 03 01 00 00       	call   f0103820 <cprintf>
f010371d:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f0103720:	83 c3 01             	add    $0x1,%ebx
f0103723:	83 fb 10             	cmp    $0x10,%ebx
f0103726:	74 07                	je     f010372f <irq_setmask_8259A+0x6c>
		if (~mask & (1<<i))
f0103728:	0f a3 de             	bt     %ebx,%esi
f010372b:	73 f3                	jae    f0103720 <irq_setmask_8259A+0x5d>
f010372d:	eb e0                	jmp    f010370f <irq_setmask_8259A+0x4c>
	cprintf("\n");
f010372f:	83 ec 0c             	sub    $0xc,%esp
f0103732:	68 8a 68 10 f0       	push   $0xf010688a
f0103737:	e8 e4 00 00 00       	call   f0103820 <cprintf>
f010373c:	83 c4 10             	add    $0x10,%esp
f010373f:	eb 99                	jmp    f01036da <irq_setmask_8259A+0x17>

f0103741 <pic_init>:
{
f0103741:	55                   	push   %ebp
f0103742:	89 e5                	mov    %esp,%ebp
f0103744:	57                   	push   %edi
f0103745:	56                   	push   %esi
f0103746:	53                   	push   %ebx
f0103747:	83 ec 0c             	sub    $0xc,%esp
	didinit = 1;
f010374a:	c6 05 4c 52 23 f0 01 	movb   $0x1,0xf023524c
f0103751:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103756:	bb 21 00 00 00       	mov    $0x21,%ebx
f010375b:	89 da                	mov    %ebx,%edx
f010375d:	ee                   	out    %al,(%dx)
f010375e:	b9 a1 00 00 00       	mov    $0xa1,%ecx
f0103763:	89 ca                	mov    %ecx,%edx
f0103765:	ee                   	out    %al,(%dx)
f0103766:	bf 11 00 00 00       	mov    $0x11,%edi
f010376b:	be 20 00 00 00       	mov    $0x20,%esi
f0103770:	89 f8                	mov    %edi,%eax
f0103772:	89 f2                	mov    %esi,%edx
f0103774:	ee                   	out    %al,(%dx)
f0103775:	b8 20 00 00 00       	mov    $0x20,%eax
f010377a:	89 da                	mov    %ebx,%edx
f010377c:	ee                   	out    %al,(%dx)
f010377d:	b8 04 00 00 00       	mov    $0x4,%eax
f0103782:	ee                   	out    %al,(%dx)
f0103783:	b8 03 00 00 00       	mov    $0x3,%eax
f0103788:	ee                   	out    %al,(%dx)
f0103789:	bb a0 00 00 00       	mov    $0xa0,%ebx
f010378e:	89 f8                	mov    %edi,%eax
f0103790:	89 da                	mov    %ebx,%edx
f0103792:	ee                   	out    %al,(%dx)
f0103793:	b8 28 00 00 00       	mov    $0x28,%eax
f0103798:	89 ca                	mov    %ecx,%edx
f010379a:	ee                   	out    %al,(%dx)
f010379b:	b8 02 00 00 00       	mov    $0x2,%eax
f01037a0:	ee                   	out    %al,(%dx)
f01037a1:	b8 01 00 00 00       	mov    $0x1,%eax
f01037a6:	ee                   	out    %al,(%dx)
f01037a7:	bf 68 00 00 00       	mov    $0x68,%edi
f01037ac:	89 f8                	mov    %edi,%eax
f01037ae:	89 f2                	mov    %esi,%edx
f01037b0:	ee                   	out    %al,(%dx)
f01037b1:	b9 0a 00 00 00       	mov    $0xa,%ecx
f01037b6:	89 c8                	mov    %ecx,%eax
f01037b8:	ee                   	out    %al,(%dx)
f01037b9:	89 f8                	mov    %edi,%eax
f01037bb:	89 da                	mov    %ebx,%edx
f01037bd:	ee                   	out    %al,(%dx)
f01037be:	89 c8                	mov    %ecx,%eax
f01037c0:	ee                   	out    %al,(%dx)
	if (irq_mask_8259A != 0xFFFF)
f01037c1:	0f b7 05 a8 23 12 f0 	movzwl 0xf01223a8,%eax
f01037c8:	66 83 f8 ff          	cmp    $0xffff,%ax
f01037cc:	75 08                	jne    f01037d6 <pic_init+0x95>
}
f01037ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01037d1:	5b                   	pop    %ebx
f01037d2:	5e                   	pop    %esi
f01037d3:	5f                   	pop    %edi
f01037d4:	5d                   	pop    %ebp
f01037d5:	c3                   	ret    
		irq_setmask_8259A(irq_mask_8259A);
f01037d6:	83 ec 0c             	sub    $0xc,%esp
f01037d9:	0f b7 c0             	movzwl %ax,%eax
f01037dc:	50                   	push   %eax
f01037dd:	e8 e1 fe ff ff       	call   f01036c3 <irq_setmask_8259A>
f01037e2:	83 c4 10             	add    $0x10,%esp
}
f01037e5:	eb e7                	jmp    f01037ce <pic_init+0x8d>

f01037e7 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01037e7:	55                   	push   %ebp
f01037e8:	89 e5                	mov    %esp,%ebp
f01037ea:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f01037ed:	ff 75 08             	pushl  0x8(%ebp)
f01037f0:	e8 b9 cf ff ff       	call   f01007ae <cputchar>
	*cnt++;
}
f01037f5:	83 c4 10             	add    $0x10,%esp
f01037f8:	c9                   	leave  
f01037f9:	c3                   	ret    

f01037fa <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01037fa:	55                   	push   %ebp
f01037fb:	89 e5                	mov    %esp,%ebp
f01037fd:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0103800:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103807:	ff 75 0c             	pushl  0xc(%ebp)
f010380a:	ff 75 08             	pushl  0x8(%ebp)
f010380d:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103810:	50                   	push   %eax
f0103811:	68 e7 37 10 f0       	push   $0xf01037e7
f0103816:	e8 38 14 00 00       	call   f0104c53 <vprintfmt>
	return cnt;
}
f010381b:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010381e:	c9                   	leave  
f010381f:	c3                   	ret    

f0103820 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103820:	55                   	push   %ebp
f0103821:	89 e5                	mov    %esp,%ebp
f0103823:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103826:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103829:	50                   	push   %eax
f010382a:	ff 75 08             	pushl  0x8(%ebp)
f010382d:	e8 c8 ff ff ff       	call   f01037fa <vcprintf>
	va_end(ap);

	return cnt;
}
f0103832:	c9                   	leave  
f0103833:	c3                   	ret    

f0103834 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103834:	55                   	push   %ebp
f0103835:	89 e5                	mov    %esp,%ebp
f0103837:	56                   	push   %esi
f0103838:	53                   	push   %ebx
	// get a triple fault.  If you set up an individual CPU's TSS
	// wrong, you may not get a fault until you try to return from
	// user space on that CPU.
	//
	// LAB 4: Your code here:
	struct Taskstate *this_ts = &thiscpu->cpu_ts;
f0103839:	e8 1c 21 00 00       	call   f010595a <cpunum>
f010383e:	6b f0 74             	imul   $0x74,%eax,%esi
f0103841:	8d 9e 2c 60 23 f0    	lea    -0xfdc9fd4(%esi),%ebx
	this_ts->ts_esp0 = KSTACKTOP - thiscpu->cpu_id*(KSTKSIZE + KSTKGAP);
f0103847:	e8 0e 21 00 00       	call   f010595a <cpunum>
f010384c:	6b c0 74             	imul   $0x74,%eax,%eax
f010384f:	0f b6 88 20 60 23 f0 	movzbl -0xfdc9fe0(%eax),%ecx
f0103856:	c1 e1 10             	shl    $0x10,%ecx
f0103859:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
f010385e:	29 c8                	sub    %ecx,%eax
f0103860:	89 86 30 60 23 f0    	mov    %eax,-0xfdc9fd0(%esi)
	this_ts->ts_ss0 = GD_KD;
f0103866:	66 c7 86 34 60 23 f0 	movw   $0x10,-0xfdc9fcc(%esi)
f010386d:	10 00 
	this_ts->ts_iomb = sizeof(struct Taskstate);
f010386f:	66 c7 86 92 60 23 f0 	movw   $0x68,-0xfdc9f6e(%esi)
f0103876:	68 00 
//	ts.ts_esp0 = KSTACKTOP;
//	ts.ts_ss0 = GD_KD;
//	ts.ts_iomb = sizeof(struct Taskstate);

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3) + thiscpu->cpu_id] = SEG16(STS_T32A, (uint32_t) (this_ts),
f0103878:	e8 dd 20 00 00       	call   f010595a <cpunum>
f010387d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103880:	0f b6 80 20 60 23 f0 	movzbl -0xfdc9fe0(%eax),%eax
f0103887:	83 c0 05             	add    $0x5,%eax
f010388a:	66 c7 04 c5 40 23 12 	movw   $0x67,-0xfeddcc0(,%eax,8)
f0103891:	f0 67 00 
f0103894:	66 89 1c c5 42 23 12 	mov    %bx,-0xfeddcbe(,%eax,8)
f010389b:	f0 
f010389c:	89 da                	mov    %ebx,%edx
f010389e:	c1 ea 10             	shr    $0x10,%edx
f01038a1:	88 14 c5 44 23 12 f0 	mov    %dl,-0xfeddcbc(,%eax,8)
f01038a8:	c6 04 c5 45 23 12 f0 	movb   $0x99,-0xfeddcbb(,%eax,8)
f01038af:	99 
f01038b0:	c6 04 c5 46 23 12 f0 	movb   $0x40,-0xfeddcba(,%eax,8)
f01038b7:	40 
f01038b8:	c1 eb 18             	shr    $0x18,%ebx
f01038bb:	88 1c c5 47 23 12 f0 	mov    %bl,-0xfeddcb9(,%eax,8)
					sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3) + thiscpu->cpu_id].sd_s = 0;
f01038c2:	e8 93 20 00 00       	call   f010595a <cpunum>
f01038c7:	6b c0 74             	imul   $0x74,%eax,%eax
f01038ca:	0f b6 80 20 60 23 f0 	movzbl -0xfdc9fe0(%eax),%eax
f01038d1:	80 24 c5 6d 23 12 f0 	andb   $0xef,-0xfeddc93(,%eax,8)
f01038d8:	ef 

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0 + (thiscpu->cpu_id << 3));
f01038d9:	e8 7c 20 00 00       	call   f010595a <cpunum>
f01038de:	6b c0 74             	imul   $0x74,%eax,%eax
f01038e1:	0f b6 80 20 60 23 f0 	movzbl -0xfdc9fe0(%eax),%eax
f01038e8:	8d 04 c5 28 00 00 00 	lea    0x28(,%eax,8),%eax
	asm volatile("ltr %0" : : "r" (sel));
f01038ef:	0f 00 d8             	ltr    %ax
	asm volatile("lidt (%0)" : : "r" (p));
f01038f2:	b8 ac 23 12 f0       	mov    $0xf01223ac,%eax
f01038f7:	0f 01 18             	lidtl  (%eax)

	// Load the IDT
	lidt(&idt_pd);
}
f01038fa:	5b                   	pop    %ebx
f01038fb:	5e                   	pop    %esi
f01038fc:	5d                   	pop    %ebp
f01038fd:	c3                   	ret    

f01038fe <trap_init>:
{
f01038fe:	55                   	push   %ebp
f01038ff:	89 e5                	mov    %esp,%ebp
f0103901:	83 ec 08             	sub    $0x8,%esp
    void traphandler500(); SETGATE(idt[T_DIVIDE], 1, GD_KT, traphandler0, 0);
f0103904:	b8 e0 41 10 f0       	mov    $0xf01041e0,%eax
f0103909:	66 a3 60 52 23 f0    	mov    %ax,0xf0235260
f010390f:	66 c7 05 62 52 23 f0 	movw   $0x8,0xf0235262
f0103916:	08 00 
f0103918:	c6 05 64 52 23 f0 00 	movb   $0x0,0xf0235264
f010391f:	c6 05 65 52 23 f0 8f 	movb   $0x8f,0xf0235265
f0103926:	c1 e8 10             	shr    $0x10,%eax
f0103929:	66 a3 66 52 23 f0    	mov    %ax,0xf0235266
    SETGATE(idt[T_DEBUG], 1, GD_KT, traphandler1, 0);
f010392f:	b8 e6 41 10 f0       	mov    $0xf01041e6,%eax
f0103934:	66 a3 68 52 23 f0    	mov    %ax,0xf0235268
f010393a:	66 c7 05 6a 52 23 f0 	movw   $0x8,0xf023526a
f0103941:	08 00 
f0103943:	c6 05 6c 52 23 f0 00 	movb   $0x0,0xf023526c
f010394a:	c6 05 6d 52 23 f0 8f 	movb   $0x8f,0xf023526d
f0103951:	c1 e8 10             	shr    $0x10,%eax
f0103954:	66 a3 6e 52 23 f0    	mov    %ax,0xf023526e
    SETGATE(idt[T_NMI], 1, GD_KT, traphandler2, 0);
f010395a:	b8 ec 41 10 f0       	mov    $0xf01041ec,%eax
f010395f:	66 a3 70 52 23 f0    	mov    %ax,0xf0235270
f0103965:	66 c7 05 72 52 23 f0 	movw   $0x8,0xf0235272
f010396c:	08 00 
f010396e:	c6 05 74 52 23 f0 00 	movb   $0x0,0xf0235274
f0103975:	c6 05 75 52 23 f0 8f 	movb   $0x8f,0xf0235275
f010397c:	c1 e8 10             	shr    $0x10,%eax
f010397f:	66 a3 76 52 23 f0    	mov    %ax,0xf0235276
    SETGATE(idt[T_BRKPT], 1, GD_KT, traphandler3, 3);
f0103985:	b8 f2 41 10 f0       	mov    $0xf01041f2,%eax
f010398a:	66 a3 78 52 23 f0    	mov    %ax,0xf0235278
f0103990:	66 c7 05 7a 52 23 f0 	movw   $0x8,0xf023527a
f0103997:	08 00 
f0103999:	c6 05 7c 52 23 f0 00 	movb   $0x0,0xf023527c
f01039a0:	c6 05 7d 52 23 f0 ef 	movb   $0xef,0xf023527d
f01039a7:	c1 e8 10             	shr    $0x10,%eax
f01039aa:	66 a3 7e 52 23 f0    	mov    %ax,0xf023527e
    SETGATE(idt[T_OFLOW], 1, GD_KT, traphandler4, 0);
f01039b0:	b8 f8 41 10 f0       	mov    $0xf01041f8,%eax
f01039b5:	66 a3 80 52 23 f0    	mov    %ax,0xf0235280
f01039bb:	66 c7 05 82 52 23 f0 	movw   $0x8,0xf0235282
f01039c2:	08 00 
f01039c4:	c6 05 84 52 23 f0 00 	movb   $0x0,0xf0235284
f01039cb:	c6 05 85 52 23 f0 8f 	movb   $0x8f,0xf0235285
f01039d2:	c1 e8 10             	shr    $0x10,%eax
f01039d5:	66 a3 86 52 23 f0    	mov    %ax,0xf0235286
    SETGATE(idt[T_BOUND], 1, GD_KT, traphandler5, 0);
f01039db:	b8 fe 41 10 f0       	mov    $0xf01041fe,%eax
f01039e0:	66 a3 88 52 23 f0    	mov    %ax,0xf0235288
f01039e6:	66 c7 05 8a 52 23 f0 	movw   $0x8,0xf023528a
f01039ed:	08 00 
f01039ef:	c6 05 8c 52 23 f0 00 	movb   $0x0,0xf023528c
f01039f6:	c6 05 8d 52 23 f0 8f 	movb   $0x8f,0xf023528d
f01039fd:	c1 e8 10             	shr    $0x10,%eax
f0103a00:	66 a3 8e 52 23 f0    	mov    %ax,0xf023528e
    SETGATE(idt[T_ILLOP], 1, GD_KT, traphandler6, 0);
f0103a06:	b8 04 42 10 f0       	mov    $0xf0104204,%eax
f0103a0b:	66 a3 90 52 23 f0    	mov    %ax,0xf0235290
f0103a11:	66 c7 05 92 52 23 f0 	movw   $0x8,0xf0235292
f0103a18:	08 00 
f0103a1a:	c6 05 94 52 23 f0 00 	movb   $0x0,0xf0235294
f0103a21:	c6 05 95 52 23 f0 8f 	movb   $0x8f,0xf0235295
f0103a28:	c1 e8 10             	shr    $0x10,%eax
f0103a2b:	66 a3 96 52 23 f0    	mov    %ax,0xf0235296
    SETGATE(idt[T_DEVICE], 1, GD_KT, traphandler7, 0);
f0103a31:	b8 0a 42 10 f0       	mov    $0xf010420a,%eax
f0103a36:	66 a3 98 52 23 f0    	mov    %ax,0xf0235298
f0103a3c:	66 c7 05 9a 52 23 f0 	movw   $0x8,0xf023529a
f0103a43:	08 00 
f0103a45:	c6 05 9c 52 23 f0 00 	movb   $0x0,0xf023529c
f0103a4c:	c6 05 9d 52 23 f0 8f 	movb   $0x8f,0xf023529d
f0103a53:	c1 e8 10             	shr    $0x10,%eax
f0103a56:	66 a3 9e 52 23 f0    	mov    %ax,0xf023529e
    SETGATE(idt[T_DBLFLT], 1, GD_KT, traphandler8, 0);
f0103a5c:	b8 10 42 10 f0       	mov    $0xf0104210,%eax
f0103a61:	66 a3 a0 52 23 f0    	mov    %ax,0xf02352a0
f0103a67:	66 c7 05 a2 52 23 f0 	movw   $0x8,0xf02352a2
f0103a6e:	08 00 
f0103a70:	c6 05 a4 52 23 f0 00 	movb   $0x0,0xf02352a4
f0103a77:	c6 05 a5 52 23 f0 8f 	movb   $0x8f,0xf02352a5
f0103a7e:	c1 e8 10             	shr    $0x10,%eax
f0103a81:	66 a3 a6 52 23 f0    	mov    %ax,0xf02352a6
    SETGATE(idt[T_TSS], 1, GD_KT, traphandler10, 0);
f0103a87:	b8 14 42 10 f0       	mov    $0xf0104214,%eax
f0103a8c:	66 a3 b0 52 23 f0    	mov    %ax,0xf02352b0
f0103a92:	66 c7 05 b2 52 23 f0 	movw   $0x8,0xf02352b2
f0103a99:	08 00 
f0103a9b:	c6 05 b4 52 23 f0 00 	movb   $0x0,0xf02352b4
f0103aa2:	c6 05 b5 52 23 f0 8f 	movb   $0x8f,0xf02352b5
f0103aa9:	c1 e8 10             	shr    $0x10,%eax
f0103aac:	66 a3 b6 52 23 f0    	mov    %ax,0xf02352b6
    SETGATE(idt[T_SEGNP], 1, GD_KT, traphandler11, 0);
f0103ab2:	b8 18 42 10 f0       	mov    $0xf0104218,%eax
f0103ab7:	66 a3 b8 52 23 f0    	mov    %ax,0xf02352b8
f0103abd:	66 c7 05 ba 52 23 f0 	movw   $0x8,0xf02352ba
f0103ac4:	08 00 
f0103ac6:	c6 05 bc 52 23 f0 00 	movb   $0x0,0xf02352bc
f0103acd:	c6 05 bd 52 23 f0 8f 	movb   $0x8f,0xf02352bd
f0103ad4:	c1 e8 10             	shr    $0x10,%eax
f0103ad7:	66 a3 be 52 23 f0    	mov    %ax,0xf02352be
    SETGATE(idt[T_STACK], 1, GD_KT, traphandler12, 0);
f0103add:	b8 1c 42 10 f0       	mov    $0xf010421c,%eax
f0103ae2:	66 a3 c0 52 23 f0    	mov    %ax,0xf02352c0
f0103ae8:	66 c7 05 c2 52 23 f0 	movw   $0x8,0xf02352c2
f0103aef:	08 00 
f0103af1:	c6 05 c4 52 23 f0 00 	movb   $0x0,0xf02352c4
f0103af8:	c6 05 c5 52 23 f0 8f 	movb   $0x8f,0xf02352c5
f0103aff:	c1 e8 10             	shr    $0x10,%eax
f0103b02:	66 a3 c6 52 23 f0    	mov    %ax,0xf02352c6
    SETGATE(idt[T_GPFLT], 1, GD_KT, traphandler13, 0);
f0103b08:	b8 20 42 10 f0       	mov    $0xf0104220,%eax
f0103b0d:	66 a3 c8 52 23 f0    	mov    %ax,0xf02352c8
f0103b13:	66 c7 05 ca 52 23 f0 	movw   $0x8,0xf02352ca
f0103b1a:	08 00 
f0103b1c:	c6 05 cc 52 23 f0 00 	movb   $0x0,0xf02352cc
f0103b23:	c6 05 cd 52 23 f0 8f 	movb   $0x8f,0xf02352cd
f0103b2a:	c1 e8 10             	shr    $0x10,%eax
f0103b2d:	66 a3 ce 52 23 f0    	mov    %ax,0xf02352ce
    SETGATE(idt[T_PGFLT], 1, GD_KT, traphandler14, 0);
f0103b33:	b8 24 42 10 f0       	mov    $0xf0104224,%eax
f0103b38:	66 a3 d0 52 23 f0    	mov    %ax,0xf02352d0
f0103b3e:	66 c7 05 d2 52 23 f0 	movw   $0x8,0xf02352d2
f0103b45:	08 00 
f0103b47:	c6 05 d4 52 23 f0 00 	movb   $0x0,0xf02352d4
f0103b4e:	c6 05 d5 52 23 f0 8f 	movb   $0x8f,0xf02352d5
f0103b55:	c1 e8 10             	shr    $0x10,%eax
f0103b58:	66 a3 d6 52 23 f0    	mov    %ax,0xf02352d6
    SETGATE(idt[T_FPERR], 1, GD_KT, traphandler16, 0);
f0103b5e:	b8 28 42 10 f0       	mov    $0xf0104228,%eax
f0103b63:	66 a3 e0 52 23 f0    	mov    %ax,0xf02352e0
f0103b69:	66 c7 05 e2 52 23 f0 	movw   $0x8,0xf02352e2
f0103b70:	08 00 
f0103b72:	c6 05 e4 52 23 f0 00 	movb   $0x0,0xf02352e4
f0103b79:	c6 05 e5 52 23 f0 8f 	movb   $0x8f,0xf02352e5
f0103b80:	c1 e8 10             	shr    $0x10,%eax
f0103b83:	66 a3 e6 52 23 f0    	mov    %ax,0xf02352e6
    SETGATE(idt[T_ALIGN], 1, GD_KT, traphandler17, 0);
f0103b89:	b8 2e 42 10 f0       	mov    $0xf010422e,%eax
f0103b8e:	66 a3 e8 52 23 f0    	mov    %ax,0xf02352e8
f0103b94:	66 c7 05 ea 52 23 f0 	movw   $0x8,0xf02352ea
f0103b9b:	08 00 
f0103b9d:	c6 05 ec 52 23 f0 00 	movb   $0x0,0xf02352ec
f0103ba4:	c6 05 ed 52 23 f0 8f 	movb   $0x8f,0xf02352ed
f0103bab:	c1 e8 10             	shr    $0x10,%eax
f0103bae:	66 a3 ee 52 23 f0    	mov    %ax,0xf02352ee
    SETGATE(idt[T_MCHK], 1, GD_KT, traphandler18, 0);
f0103bb4:	b8 32 42 10 f0       	mov    $0xf0104232,%eax
f0103bb9:	66 a3 f0 52 23 f0    	mov    %ax,0xf02352f0
f0103bbf:	66 c7 05 f2 52 23 f0 	movw   $0x8,0xf02352f2
f0103bc6:	08 00 
f0103bc8:	c6 05 f4 52 23 f0 00 	movb   $0x0,0xf02352f4
f0103bcf:	c6 05 f5 52 23 f0 8f 	movb   $0x8f,0xf02352f5
f0103bd6:	c1 e8 10             	shr    $0x10,%eax
f0103bd9:	66 a3 f6 52 23 f0    	mov    %ax,0xf02352f6
    SETGATE(idt[T_SIMDERR], 1, GD_KT, traphandler19, 0);
f0103bdf:	b8 38 42 10 f0       	mov    $0xf0104238,%eax
f0103be4:	66 a3 f8 52 23 f0    	mov    %ax,0xf02352f8
f0103bea:	66 c7 05 fa 52 23 f0 	movw   $0x8,0xf02352fa
f0103bf1:	08 00 
f0103bf3:	c6 05 fc 52 23 f0 00 	movb   $0x0,0xf02352fc
f0103bfa:	c6 05 fd 52 23 f0 8f 	movb   $0x8f,0xf02352fd
f0103c01:	c1 e8 10             	shr    $0x10,%eax
f0103c04:	66 a3 fe 52 23 f0    	mov    %ax,0xf02352fe
    SETGATE(idt[T_SYSCALL], 0, GD_KT, traphandler48, 3);
f0103c0a:	b8 3e 42 10 f0       	mov    $0xf010423e,%eax
f0103c0f:	66 a3 e0 53 23 f0    	mov    %ax,0xf02353e0
f0103c15:	66 c7 05 e2 53 23 f0 	movw   $0x8,0xf02353e2
f0103c1c:	08 00 
f0103c1e:	c6 05 e4 53 23 f0 00 	movb   $0x0,0xf02353e4
f0103c25:	c6 05 e5 53 23 f0 ee 	movb   $0xee,0xf02353e5
f0103c2c:	c1 e8 10             	shr    $0x10,%eax
f0103c2f:	66 a3 e6 53 23 f0    	mov    %ax,0xf02353e6
    SETGATE(idt[T_DEFAULT], 0, GD_KT, traphandler500, 0);
f0103c35:	b8 44 42 10 f0       	mov    $0xf0104244,%eax
f0103c3a:	66 a3 00 62 23 f0    	mov    %ax,0xf0236200
f0103c40:	66 c7 05 02 62 23 f0 	movw   $0x8,0xf0236202
f0103c47:	08 00 
f0103c49:	c6 05 04 62 23 f0 00 	movb   $0x0,0xf0236204
f0103c50:	c6 05 05 62 23 f0 8e 	movb   $0x8e,0xf0236205
f0103c57:	c1 e8 10             	shr    $0x10,%eax
f0103c5a:	66 a3 06 62 23 f0    	mov    %ax,0xf0236206
	trap_init_percpu();
f0103c60:	e8 cf fb ff ff       	call   f0103834 <trap_init_percpu>
}
f0103c65:	c9                   	leave  
f0103c66:	c3                   	ret    

f0103c67 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103c67:	55                   	push   %ebp
f0103c68:	89 e5                	mov    %esp,%ebp
f0103c6a:	53                   	push   %ebx
f0103c6b:	83 ec 0c             	sub    $0xc,%esp
f0103c6e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103c71:	ff 33                	pushl  (%ebx)
f0103c73:	68 a2 72 10 f0       	push   $0xf01072a2
f0103c78:	e8 a3 fb ff ff       	call   f0103820 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103c7d:	83 c4 08             	add    $0x8,%esp
f0103c80:	ff 73 04             	pushl  0x4(%ebx)
f0103c83:	68 b1 72 10 f0       	push   $0xf01072b1
f0103c88:	e8 93 fb ff ff       	call   f0103820 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103c8d:	83 c4 08             	add    $0x8,%esp
f0103c90:	ff 73 08             	pushl  0x8(%ebx)
f0103c93:	68 c0 72 10 f0       	push   $0xf01072c0
f0103c98:	e8 83 fb ff ff       	call   f0103820 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103c9d:	83 c4 08             	add    $0x8,%esp
f0103ca0:	ff 73 0c             	pushl  0xc(%ebx)
f0103ca3:	68 cf 72 10 f0       	push   $0xf01072cf
f0103ca8:	e8 73 fb ff ff       	call   f0103820 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103cad:	83 c4 08             	add    $0x8,%esp
f0103cb0:	ff 73 10             	pushl  0x10(%ebx)
f0103cb3:	68 de 72 10 f0       	push   $0xf01072de
f0103cb8:	e8 63 fb ff ff       	call   f0103820 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103cbd:	83 c4 08             	add    $0x8,%esp
f0103cc0:	ff 73 14             	pushl  0x14(%ebx)
f0103cc3:	68 ed 72 10 f0       	push   $0xf01072ed
f0103cc8:	e8 53 fb ff ff       	call   f0103820 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103ccd:	83 c4 08             	add    $0x8,%esp
f0103cd0:	ff 73 18             	pushl  0x18(%ebx)
f0103cd3:	68 fc 72 10 f0       	push   $0xf01072fc
f0103cd8:	e8 43 fb ff ff       	call   f0103820 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103cdd:	83 c4 08             	add    $0x8,%esp
f0103ce0:	ff 73 1c             	pushl  0x1c(%ebx)
f0103ce3:	68 0b 73 10 f0       	push   $0xf010730b
f0103ce8:	e8 33 fb ff ff       	call   f0103820 <cprintf>
}
f0103ced:	83 c4 10             	add    $0x10,%esp
f0103cf0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103cf3:	c9                   	leave  
f0103cf4:	c3                   	ret    

f0103cf5 <print_trapframe>:
{
f0103cf5:	55                   	push   %ebp
f0103cf6:	89 e5                	mov    %esp,%ebp
f0103cf8:	56                   	push   %esi
f0103cf9:	53                   	push   %ebx
f0103cfa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0103cfd:	e8 58 1c 00 00       	call   f010595a <cpunum>
f0103d02:	83 ec 04             	sub    $0x4,%esp
f0103d05:	50                   	push   %eax
f0103d06:	53                   	push   %ebx
f0103d07:	68 6f 73 10 f0       	push   $0xf010736f
f0103d0c:	e8 0f fb ff ff       	call   f0103820 <cprintf>
	print_regs(&tf->tf_regs);
f0103d11:	89 1c 24             	mov    %ebx,(%esp)
f0103d14:	e8 4e ff ff ff       	call   f0103c67 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103d19:	83 c4 08             	add    $0x8,%esp
f0103d1c:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103d20:	50                   	push   %eax
f0103d21:	68 8d 73 10 f0       	push   $0xf010738d
f0103d26:	e8 f5 fa ff ff       	call   f0103820 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103d2b:	83 c4 08             	add    $0x8,%esp
f0103d2e:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103d32:	50                   	push   %eax
f0103d33:	68 a0 73 10 f0       	push   $0xf01073a0
f0103d38:	e8 e3 fa ff ff       	call   f0103820 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103d3d:	8b 43 28             	mov    0x28(%ebx),%eax
	if (trapno < ARRAY_SIZE(excnames))
f0103d40:	83 c4 10             	add    $0x10,%esp
f0103d43:	83 f8 13             	cmp    $0x13,%eax
f0103d46:	0f 86 e1 00 00 00    	jbe    f0103e2d <print_trapframe+0x138>
		return "System call";
f0103d4c:	ba 1a 73 10 f0       	mov    $0xf010731a,%edx
	if (trapno == T_SYSCALL)
f0103d51:	83 f8 30             	cmp    $0x30,%eax
f0103d54:	74 13                	je     f0103d69 <print_trapframe+0x74>
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0103d56:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
f0103d59:	83 fa 0f             	cmp    $0xf,%edx
f0103d5c:	ba 26 73 10 f0       	mov    $0xf0107326,%edx
f0103d61:	b9 35 73 10 f0       	mov    $0xf0107335,%ecx
f0103d66:	0f 46 d1             	cmovbe %ecx,%edx
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103d69:	83 ec 04             	sub    $0x4,%esp
f0103d6c:	52                   	push   %edx
f0103d6d:	50                   	push   %eax
f0103d6e:	68 b3 73 10 f0       	push   $0xf01073b3
f0103d73:	e8 a8 fa ff ff       	call   f0103820 <cprintf>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103d78:	83 c4 10             	add    $0x10,%esp
f0103d7b:	39 1d 60 5a 23 f0    	cmp    %ebx,0xf0235a60
f0103d81:	0f 84 b2 00 00 00    	je     f0103e39 <print_trapframe+0x144>
	cprintf("  err  0x%08x", tf->tf_err);
f0103d87:	83 ec 08             	sub    $0x8,%esp
f0103d8a:	ff 73 2c             	pushl  0x2c(%ebx)
f0103d8d:	68 d4 73 10 f0       	push   $0xf01073d4
f0103d92:	e8 89 fa ff ff       	call   f0103820 <cprintf>
	if (tf->tf_trapno == T_PGFLT)
f0103d97:	83 c4 10             	add    $0x10,%esp
f0103d9a:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103d9e:	0f 85 b8 00 00 00    	jne    f0103e5c <print_trapframe+0x167>
			tf->tf_err & 1 ? "protection" : "not-present");
f0103da4:	8b 43 2c             	mov    0x2c(%ebx),%eax
		cprintf(" [%s, %s, %s]\n",
f0103da7:	89 c2                	mov    %eax,%edx
f0103da9:	83 e2 01             	and    $0x1,%edx
f0103dac:	b9 48 73 10 f0       	mov    $0xf0107348,%ecx
f0103db1:	ba 53 73 10 f0       	mov    $0xf0107353,%edx
f0103db6:	0f 44 ca             	cmove  %edx,%ecx
f0103db9:	89 c2                	mov    %eax,%edx
f0103dbb:	83 e2 02             	and    $0x2,%edx
f0103dbe:	be 5f 73 10 f0       	mov    $0xf010735f,%esi
f0103dc3:	ba 65 73 10 f0       	mov    $0xf0107365,%edx
f0103dc8:	0f 45 d6             	cmovne %esi,%edx
f0103dcb:	83 e0 04             	and    $0x4,%eax
f0103dce:	b8 6a 73 10 f0       	mov    $0xf010736a,%eax
f0103dd3:	be b9 74 10 f0       	mov    $0xf01074b9,%esi
f0103dd8:	0f 44 c6             	cmove  %esi,%eax
f0103ddb:	51                   	push   %ecx
f0103ddc:	52                   	push   %edx
f0103ddd:	50                   	push   %eax
f0103dde:	68 e2 73 10 f0       	push   $0xf01073e2
f0103de3:	e8 38 fa ff ff       	call   f0103820 <cprintf>
f0103de8:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103deb:	83 ec 08             	sub    $0x8,%esp
f0103dee:	ff 73 30             	pushl  0x30(%ebx)
f0103df1:	68 f1 73 10 f0       	push   $0xf01073f1
f0103df6:	e8 25 fa ff ff       	call   f0103820 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103dfb:	83 c4 08             	add    $0x8,%esp
f0103dfe:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103e02:	50                   	push   %eax
f0103e03:	68 00 74 10 f0       	push   $0xf0107400
f0103e08:	e8 13 fa ff ff       	call   f0103820 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103e0d:	83 c4 08             	add    $0x8,%esp
f0103e10:	ff 73 38             	pushl  0x38(%ebx)
f0103e13:	68 13 74 10 f0       	push   $0xf0107413
f0103e18:	e8 03 fa ff ff       	call   f0103820 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0103e1d:	83 c4 10             	add    $0x10,%esp
f0103e20:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103e24:	75 4b                	jne    f0103e71 <print_trapframe+0x17c>
}
f0103e26:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103e29:	5b                   	pop    %ebx
f0103e2a:	5e                   	pop    %esi
f0103e2b:	5d                   	pop    %ebp
f0103e2c:	c3                   	ret    
		return excnames[trapno];
f0103e2d:	8b 14 85 40 76 10 f0 	mov    -0xfef89c0(,%eax,4),%edx
f0103e34:	e9 30 ff ff ff       	jmp    f0103d69 <print_trapframe+0x74>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103e39:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103e3d:	0f 85 44 ff ff ff    	jne    f0103d87 <print_trapframe+0x92>
	asm volatile("movl %%cr2,%0" : "=r" (val));
f0103e43:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0103e46:	83 ec 08             	sub    $0x8,%esp
f0103e49:	50                   	push   %eax
f0103e4a:	68 c5 73 10 f0       	push   $0xf01073c5
f0103e4f:	e8 cc f9 ff ff       	call   f0103820 <cprintf>
f0103e54:	83 c4 10             	add    $0x10,%esp
f0103e57:	e9 2b ff ff ff       	jmp    f0103d87 <print_trapframe+0x92>
		cprintf("\n");
f0103e5c:	83 ec 0c             	sub    $0xc,%esp
f0103e5f:	68 8a 68 10 f0       	push   $0xf010688a
f0103e64:	e8 b7 f9 ff ff       	call   f0103820 <cprintf>
f0103e69:	83 c4 10             	add    $0x10,%esp
f0103e6c:	e9 7a ff ff ff       	jmp    f0103deb <print_trapframe+0xf6>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0103e71:	83 ec 08             	sub    $0x8,%esp
f0103e74:	ff 73 3c             	pushl  0x3c(%ebx)
f0103e77:	68 22 74 10 f0       	push   $0xf0107422
f0103e7c:	e8 9f f9 ff ff       	call   f0103820 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0103e81:	83 c4 08             	add    $0x8,%esp
f0103e84:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0103e88:	50                   	push   %eax
f0103e89:	68 31 74 10 f0       	push   $0xf0107431
f0103e8e:	e8 8d f9 ff ff       	call   f0103820 <cprintf>
f0103e93:	83 c4 10             	add    $0x10,%esp
}
f0103e96:	eb 8e                	jmp    f0103e26 <print_trapframe+0x131>

f0103e98 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0103e98:	55                   	push   %ebp
f0103e99:	89 e5                	mov    %esp,%ebp
f0103e9b:	57                   	push   %edi
f0103e9c:	56                   	push   %esi
f0103e9d:	53                   	push   %ebx
f0103e9e:	83 ec 1c             	sub    $0x1c,%esp
f0103ea1:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103ea4:	0f 20 d6             	mov    %cr2,%esi
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if ((tf->tf_cs & 3) == 0)
f0103ea7:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103eab:	74 5d                	je     f0103f0a <page_fault_handler+0x72>
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	struct UTrapframe *utf;

	if (curenv->env_pgfault_upcall) {
f0103ead:	e8 a8 1a 00 00       	call   f010595a <cpunum>
f0103eb2:	6b c0 74             	imul   $0x74,%eax,%eax
f0103eb5:	8b 80 28 60 23 f0    	mov    -0xfdc9fd8(%eax),%eax
f0103ebb:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f0103ebf:	75 60                	jne    f0103f21 <page_fault_handler+0x89>
		tf->tf_esp = (uint32_t)utf;
		env_run(curenv);
	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103ec1:	8b 7b 30             	mov    0x30(%ebx),%edi
		curenv->env_id, fault_va, tf->tf_eip);
f0103ec4:	e8 91 1a 00 00       	call   f010595a <cpunum>
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103ec9:	57                   	push   %edi
f0103eca:	56                   	push   %esi
		curenv->env_id, fault_va, tf->tf_eip);
f0103ecb:	6b c0 74             	imul   $0x74,%eax,%eax
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103ece:	8b 80 28 60 23 f0    	mov    -0xfdc9fd8(%eax),%eax
f0103ed4:	ff 70 48             	pushl  0x48(%eax)
f0103ed7:	68 04 76 10 f0       	push   $0xf0107604
f0103edc:	e8 3f f9 ff ff       	call   f0103820 <cprintf>
	print_trapframe(tf);
f0103ee1:	89 1c 24             	mov    %ebx,(%esp)
f0103ee4:	e8 0c fe ff ff       	call   f0103cf5 <print_trapframe>
	env_destroy(curenv);
f0103ee9:	e8 6c 1a 00 00       	call   f010595a <cpunum>
f0103eee:	83 c4 04             	add    $0x4,%esp
f0103ef1:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ef4:	ff b0 28 60 23 f0    	pushl  -0xfdc9fd8(%eax)
f0103efa:	e8 5a f6 ff ff       	call   f0103559 <env_destroy>
}
f0103eff:	83 c4 10             	add    $0x10,%esp
f0103f02:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103f05:	5b                   	pop    %ebx
f0103f06:	5e                   	pop    %esi
f0103f07:	5f                   	pop    %edi
f0103f08:	5d                   	pop    %ebp
f0103f09:	c3                   	ret    
			panic("Page fault in kernel_mode");
f0103f0a:	83 ec 04             	sub    $0x4,%esp
f0103f0d:	68 44 74 10 f0       	push   $0xf0107444
f0103f12:	68 5b 01 00 00       	push   $0x15b
f0103f17:	68 5e 74 10 f0       	push   $0xf010745e
f0103f1c:	e8 73 c1 ff ff       	call   f0100094 <_panic>
		if (UXSTACKTOP - PGSIZE <= tf->tf_esp && tf->tf_esp <= UXSTACKTOP - 1)
f0103f21:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0103f24:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
			utf = (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe));
f0103f2a:	c7 45 e4 cc ff bf ee 	movl   $0xeebfffcc,-0x1c(%ebp)
		if (UXSTACKTOP - PGSIZE <= tf->tf_esp && tf->tf_esp <= UXSTACKTOP - 1)
f0103f31:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f0103f37:	77 06                	ja     f0103f3f <page_fault_handler+0xa7>
			utf = (struct UTrapframe *)(tf->tf_esp - sizeof(struct UTrapframe) - 4);
f0103f39:	83 e8 38             	sub    $0x38,%eax
f0103f3c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		user_mem_assert(curenv, (void *)utf, sizeof(struct UTrapframe), PTE_U | PTE_W);
f0103f3f:	e8 16 1a 00 00       	call   f010595a <cpunum>
f0103f44:	6a 06                	push   $0x6
f0103f46:	6a 34                	push   $0x34
f0103f48:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103f4b:	57                   	push   %edi
f0103f4c:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f4f:	ff b0 28 60 23 f0    	pushl  -0xfdc9fd8(%eax)
f0103f55:	e8 96 ef ff ff       	call   f0102ef0 <user_mem_assert>
		utf->utf_fault_va = fault_va;
f0103f5a:	89 37                	mov    %esi,(%edi)
		utf->utf_err = tf->tf_trapno;
f0103f5c:	8b 43 28             	mov    0x28(%ebx),%eax
f0103f5f:	89 47 04             	mov    %eax,0x4(%edi)
		utf->utf_eip = tf->tf_eip;
f0103f62:	8b 43 30             	mov    0x30(%ebx),%eax
f0103f65:	89 47 28             	mov    %eax,0x28(%edi)
		utf->utf_eflags = tf->tf_eflags;
f0103f68:	8b 43 38             	mov    0x38(%ebx),%eax
f0103f6b:	89 47 2c             	mov    %eax,0x2c(%edi)
		utf->utf_esp = tf->tf_esp;
f0103f6e:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0103f71:	89 47 30             	mov    %eax,0x30(%edi)
		utf->utf_regs = tf->tf_regs;
f0103f74:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f0103f77:	8d 7f 08             	lea    0x8(%edi),%edi
f0103f7a:	b9 08 00 00 00       	mov    $0x8,%ecx
f0103f7f:	89 de                	mov    %ebx,%esi
f0103f81:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		tf->tf_eip = (uint32_t)curenv->env_pgfault_upcall;
f0103f83:	e8 d2 19 00 00       	call   f010595a <cpunum>
f0103f88:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f8b:	8b 80 28 60 23 f0    	mov    -0xfdc9fd8(%eax),%eax
f0103f91:	8b 40 64             	mov    0x64(%eax),%eax
f0103f94:	89 43 30             	mov    %eax,0x30(%ebx)
		tf->tf_esp = (uint32_t)utf;
f0103f97:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0103f9a:	89 53 3c             	mov    %edx,0x3c(%ebx)
		env_run(curenv);
f0103f9d:	e8 b8 19 00 00       	call   f010595a <cpunum>
f0103fa2:	83 c4 04             	add    $0x4,%esp
f0103fa5:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fa8:	ff b0 28 60 23 f0    	pushl  -0xfdc9fd8(%eax)
f0103fae:	e8 45 f6 ff ff       	call   f01035f8 <env_run>

f0103fb3 <trap>:
{
f0103fb3:	55                   	push   %ebp
f0103fb4:	89 e5                	mov    %esp,%ebp
f0103fb6:	57                   	push   %edi
f0103fb7:	56                   	push   %esi
f0103fb8:	8b 75 08             	mov    0x8(%ebp),%esi
	asm volatile("cld" ::: "cc");
f0103fbb:	fc                   	cld    
	if (panicstr)
f0103fbc:	83 3d 80 5e 23 f0 00 	cmpl   $0x0,0xf0235e80
f0103fc3:	74 01                	je     f0103fc6 <trap+0x13>
		asm volatile("hlt");
f0103fc5:	f4                   	hlt    
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f0103fc6:	e8 8f 19 00 00       	call   f010595a <cpunum>
f0103fcb:	6b d0 74             	imul   $0x74,%eax,%edx
f0103fce:	83 c2 04             	add    $0x4,%edx
	asm volatile("lock; xchgl %0, %1"
f0103fd1:	b8 01 00 00 00       	mov    $0x1,%eax
f0103fd6:	f0 87 82 20 60 23 f0 	lock xchg %eax,-0xfdc9fe0(%edx)
f0103fdd:	83 f8 02             	cmp    $0x2,%eax
f0103fe0:	74 7e                	je     f0104060 <trap+0xad>
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f0103fe2:	9c                   	pushf  
f0103fe3:	58                   	pop    %eax
	assert(!(read_eflags() & FL_IF));
f0103fe4:	f6 c4 02             	test   $0x2,%ah
f0103fe7:	0f 85 88 00 00 00    	jne    f0104075 <trap+0xc2>
	if ((tf->tf_cs & 3) == 3) {
f0103fed:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0103ff1:	83 e0 03             	and    $0x3,%eax
f0103ff4:	66 83 f8 03          	cmp    $0x3,%ax
f0103ff8:	0f 84 90 00 00 00    	je     f010408e <trap+0xdb>
	last_tf = tf;
f0103ffe:	89 35 60 5a 23 f0    	mov    %esi,0xf0235a60
	switch (tf->tf_trapno) {
f0104004:	8b 46 28             	mov    0x28(%esi),%eax
f0104007:	83 f8 0e             	cmp    $0xe,%eax
f010400a:	0f 84 23 01 00 00    	je     f0104133 <trap+0x180>
f0104010:	83 f8 30             	cmp    $0x30,%eax
f0104013:	0f 84 5e 01 00 00    	je     f0104177 <trap+0x1c4>
f0104019:	83 f8 03             	cmp    $0x3,%eax
f010401c:	0f 84 47 01 00 00    	je     f0104169 <trap+0x1b6>
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f0104022:	83 f8 27             	cmp    $0x27,%eax
f0104025:	0f 84 6d 01 00 00    	je     f0104198 <trap+0x1e5>
	print_trapframe(tf);
f010402b:	83 ec 0c             	sub    $0xc,%esp
f010402e:	56                   	push   %esi
f010402f:	e8 c1 fc ff ff       	call   f0103cf5 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0104034:	83 c4 10             	add    $0x10,%esp
f0104037:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f010403c:	0f 84 70 01 00 00    	je     f01041b2 <trap+0x1ff>
		env_destroy(curenv);
f0104042:	e8 13 19 00 00       	call   f010595a <cpunum>
f0104047:	83 ec 0c             	sub    $0xc,%esp
f010404a:	6b c0 74             	imul   $0x74,%eax,%eax
f010404d:	ff b0 28 60 23 f0    	pushl  -0xfdc9fd8(%eax)
f0104053:	e8 01 f5 ff ff       	call   f0103559 <env_destroy>
f0104058:	83 c4 10             	add    $0x10,%esp
f010405b:	e9 df 00 00 00       	jmp    f010413f <trap+0x18c>
	spin_lock(&kernel_lock);
f0104060:	83 ec 0c             	sub    $0xc,%esp
f0104063:	68 c0 23 12 f0       	push   $0xf01223c0
f0104068:	e8 5d 1b 00 00       	call   f0105bca <spin_lock>
f010406d:	83 c4 10             	add    $0x10,%esp
f0104070:	e9 6d ff ff ff       	jmp    f0103fe2 <trap+0x2f>
	assert(!(read_eflags() & FL_IF));
f0104075:	68 6a 74 10 f0       	push   $0xf010746a
f010407a:	68 be 65 10 f0       	push   $0xf01065be
f010407f:	68 25 01 00 00       	push   $0x125
f0104084:	68 5e 74 10 f0       	push   $0xf010745e
f0104089:	e8 06 c0 ff ff       	call   f0100094 <_panic>
f010408e:	83 ec 0c             	sub    $0xc,%esp
f0104091:	68 c0 23 12 f0       	push   $0xf01223c0
f0104096:	e8 2f 1b 00 00       	call   f0105bca <spin_lock>
		assert(curenv);
f010409b:	e8 ba 18 00 00       	call   f010595a <cpunum>
f01040a0:	6b c0 74             	imul   $0x74,%eax,%eax
f01040a3:	83 c4 10             	add    $0x10,%esp
f01040a6:	83 b8 28 60 23 f0 00 	cmpl   $0x0,-0xfdc9fd8(%eax)
f01040ad:	74 3e                	je     f01040ed <trap+0x13a>
		if (curenv->env_status == ENV_DYING) {
f01040af:	e8 a6 18 00 00       	call   f010595a <cpunum>
f01040b4:	6b c0 74             	imul   $0x74,%eax,%eax
f01040b7:	8b 80 28 60 23 f0    	mov    -0xfdc9fd8(%eax),%eax
f01040bd:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f01040c1:	74 43                	je     f0104106 <trap+0x153>
		curenv->env_tf = *tf;
f01040c3:	e8 92 18 00 00       	call   f010595a <cpunum>
f01040c8:	6b c0 74             	imul   $0x74,%eax,%eax
f01040cb:	8b 80 28 60 23 f0    	mov    -0xfdc9fd8(%eax),%eax
f01040d1:	b9 11 00 00 00       	mov    $0x11,%ecx
f01040d6:	89 c7                	mov    %eax,%edi
f01040d8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		tf = &curenv->env_tf;
f01040da:	e8 7b 18 00 00       	call   f010595a <cpunum>
f01040df:	6b c0 74             	imul   $0x74,%eax,%eax
f01040e2:	8b b0 28 60 23 f0    	mov    -0xfdc9fd8(%eax),%esi
f01040e8:	e9 11 ff ff ff       	jmp    f0103ffe <trap+0x4b>
		assert(curenv);
f01040ed:	68 83 74 10 f0       	push   $0xf0107483
f01040f2:	68 be 65 10 f0       	push   $0xf01065be
f01040f7:	68 2d 01 00 00       	push   $0x12d
f01040fc:	68 5e 74 10 f0       	push   $0xf010745e
f0104101:	e8 8e bf ff ff       	call   f0100094 <_panic>
			env_free(curenv);
f0104106:	e8 4f 18 00 00       	call   f010595a <cpunum>
f010410b:	83 ec 0c             	sub    $0xc,%esp
f010410e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104111:	ff b0 28 60 23 f0    	pushl  -0xfdc9fd8(%eax)
f0104117:	e8 5c f2 ff ff       	call   f0103378 <env_free>
			curenv = NULL;
f010411c:	e8 39 18 00 00       	call   f010595a <cpunum>
f0104121:	6b c0 74             	imul   $0x74,%eax,%eax
f0104124:	c7 80 28 60 23 f0 00 	movl   $0x0,-0xfdc9fd8(%eax)
f010412b:	00 00 00 
			sched_yield();
f010412e:	e8 f4 01 00 00       	call   f0104327 <sched_yield>
			page_fault_handler(tf);
f0104133:	83 ec 0c             	sub    $0xc,%esp
f0104136:	56                   	push   %esi
f0104137:	e8 5c fd ff ff       	call   f0103e98 <page_fault_handler>
f010413c:	83 c4 10             	add    $0x10,%esp
	if (curenv && curenv->env_status == ENV_RUNNING)
f010413f:	e8 16 18 00 00       	call   f010595a <cpunum>
f0104144:	6b c0 74             	imul   $0x74,%eax,%eax
f0104147:	83 b8 28 60 23 f0 00 	cmpl   $0x0,-0xfdc9fd8(%eax)
f010414e:	74 14                	je     f0104164 <trap+0x1b1>
f0104150:	e8 05 18 00 00       	call   f010595a <cpunum>
f0104155:	6b c0 74             	imul   $0x74,%eax,%eax
f0104158:	8b 80 28 60 23 f0    	mov    -0xfdc9fd8(%eax),%eax
f010415e:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104162:	74 65                	je     f01041c9 <trap+0x216>
		sched_yield();
f0104164:	e8 be 01 00 00       	call   f0104327 <sched_yield>
			monitor(tf);
f0104169:	83 ec 0c             	sub    $0xc,%esp
f010416c:	56                   	push   %esi
f010416d:	e8 d9 c7 ff ff       	call   f010094b <monitor>
f0104172:	83 c4 10             	add    $0x10,%esp
f0104175:	eb c8                	jmp    f010413f <trap+0x18c>
			tf->tf_regs.reg_eax = syscall (tf->tf_regs.reg_eax,
f0104177:	83 ec 08             	sub    $0x8,%esp
f010417a:	ff 76 04             	pushl  0x4(%esi)
f010417d:	ff 36                	pushl  (%esi)
f010417f:	ff 76 10             	pushl  0x10(%esi)
f0104182:	ff 76 18             	pushl  0x18(%esi)
f0104185:	ff 76 14             	pushl  0x14(%esi)
f0104188:	ff 76 1c             	pushl  0x1c(%esi)
f010418b:	e8 03 02 00 00       	call   f0104393 <syscall>
f0104190:	89 46 1c             	mov    %eax,0x1c(%esi)
f0104193:	83 c4 20             	add    $0x20,%esp
f0104196:	eb a7                	jmp    f010413f <trap+0x18c>
		cprintf("Spurious interrupt on irq 7\n");
f0104198:	83 ec 0c             	sub    $0xc,%esp
f010419b:	68 8a 74 10 f0       	push   $0xf010748a
f01041a0:	e8 7b f6 ff ff       	call   f0103820 <cprintf>
		print_trapframe(tf);
f01041a5:	89 34 24             	mov    %esi,(%esp)
f01041a8:	e8 48 fb ff ff       	call   f0103cf5 <print_trapframe>
f01041ad:	83 c4 10             	add    $0x10,%esp
f01041b0:	eb 8d                	jmp    f010413f <trap+0x18c>
		panic("unhandled trap in kernel");
f01041b2:	83 ec 04             	sub    $0x4,%esp
f01041b5:	68 a7 74 10 f0       	push   $0xf01074a7
f01041ba:	68 0a 01 00 00       	push   $0x10a
f01041bf:	68 5e 74 10 f0       	push   $0xf010745e
f01041c4:	e8 cb be ff ff       	call   f0100094 <_panic>
		env_run(curenv);
f01041c9:	e8 8c 17 00 00       	call   f010595a <cpunum>
f01041ce:	83 ec 0c             	sub    $0xc,%esp
f01041d1:	6b c0 74             	imul   $0x74,%eax,%eax
f01041d4:	ff b0 28 60 23 f0    	pushl  -0xfdc9fd8(%eax)
f01041da:	e8 19 f4 ff ff       	call   f01035f8 <env_run>
f01041df:	90                   	nop

f01041e0 <traphandler0>:
.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
TRAPHANDLER_NOEC(traphandler0, T_DIVIDE)
f01041e0:	6a 00                	push   $0x0
f01041e2:	6a 00                	push   $0x0
f01041e4:	eb 67                	jmp    f010424d <_alltraps>

f01041e6 <traphandler1>:
TRAPHANDLER_NOEC(traphandler1, T_DEBUG)
f01041e6:	6a 00                	push   $0x0
f01041e8:	6a 01                	push   $0x1
f01041ea:	eb 61                	jmp    f010424d <_alltraps>

f01041ec <traphandler2>:
TRAPHANDLER_NOEC(traphandler2, T_NMI)
f01041ec:	6a 00                	push   $0x0
f01041ee:	6a 02                	push   $0x2
f01041f0:	eb 5b                	jmp    f010424d <_alltraps>

f01041f2 <traphandler3>:
TRAPHANDLER_NOEC(traphandler3, T_BRKPT)
f01041f2:	6a 00                	push   $0x0
f01041f4:	6a 03                	push   $0x3
f01041f6:	eb 55                	jmp    f010424d <_alltraps>

f01041f8 <traphandler4>:
TRAPHANDLER_NOEC(traphandler4, T_OFLOW)
f01041f8:	6a 00                	push   $0x0
f01041fa:	6a 04                	push   $0x4
f01041fc:	eb 4f                	jmp    f010424d <_alltraps>

f01041fe <traphandler5>:
TRAPHANDLER_NOEC(traphandler5, T_BOUND)
f01041fe:	6a 00                	push   $0x0
f0104200:	6a 05                	push   $0x5
f0104202:	eb 49                	jmp    f010424d <_alltraps>

f0104204 <traphandler6>:
TRAPHANDLER_NOEC(traphandler6, T_ILLOP)
f0104204:	6a 00                	push   $0x0
f0104206:	6a 06                	push   $0x6
f0104208:	eb 43                	jmp    f010424d <_alltraps>

f010420a <traphandler7>:
TRAPHANDLER_NOEC(traphandler7, T_DEVICE)
f010420a:	6a 00                	push   $0x0
f010420c:	6a 07                	push   $0x7
f010420e:	eb 3d                	jmp    f010424d <_alltraps>

f0104210 <traphandler8>:
TRAPHANDLER(traphandler8, T_DBLFLT)
f0104210:	6a 08                	push   $0x8
f0104212:	eb 39                	jmp    f010424d <_alltraps>

f0104214 <traphandler10>:
// 9 deprecated since 386
TRAPHANDLER(traphandler10, T_TSS)
f0104214:	6a 0a                	push   $0xa
f0104216:	eb 35                	jmp    f010424d <_alltraps>

f0104218 <traphandler11>:
TRAPHANDLER(traphandler11, T_SEGNP)
f0104218:	6a 0b                	push   $0xb
f010421a:	eb 31                	jmp    f010424d <_alltraps>

f010421c <traphandler12>:
TRAPHANDLER(traphandler12, T_STACK)
f010421c:	6a 0c                	push   $0xc
f010421e:	eb 2d                	jmp    f010424d <_alltraps>

f0104220 <traphandler13>:
TRAPHANDLER(traphandler13, T_GPFLT)
f0104220:	6a 0d                	push   $0xd
f0104222:	eb 29                	jmp    f010424d <_alltraps>

f0104224 <traphandler14>:
TRAPHANDLER(traphandler14, T_PGFLT)
f0104224:	6a 0e                	push   $0xe
f0104226:	eb 25                	jmp    f010424d <_alltraps>

f0104228 <traphandler16>:
// 15 reserved by intel
TRAPHANDLER_NOEC(traphandler16, T_FPERR)
f0104228:	6a 00                	push   $0x0
f010422a:	6a 10                	push   $0x10
f010422c:	eb 1f                	jmp    f010424d <_alltraps>

f010422e <traphandler17>:
TRAPHANDLER(traphandler17, T_ALIGN)
f010422e:	6a 11                	push   $0x11
f0104230:	eb 1b                	jmp    f010424d <_alltraps>

f0104232 <traphandler18>:
TRAPHANDLER_NOEC(traphandler18, T_MCHK)
f0104232:	6a 00                	push   $0x0
f0104234:	6a 12                	push   $0x12
f0104236:	eb 15                	jmp    f010424d <_alltraps>

f0104238 <traphandler19>:
TRAPHANDLER_NOEC(traphandler19, T_SIMDERR)
f0104238:	6a 00                	push   $0x0
f010423a:	6a 13                	push   $0x13
f010423c:	eb 0f                	jmp    f010424d <_alltraps>

f010423e <traphandler48>:

// system call (interrupt)
TRAPHANDLER_NOEC(traphandler48, T_SYSCALL)
f010423e:	6a 00                	push   $0x0
f0104240:	6a 30                	push   $0x30
f0104242:	eb 09                	jmp    f010424d <_alltraps>

f0104244 <traphandler500>:
TRAPHANDLER_NOEC(traphandler500, T_DEFAULT)	
f0104244:	6a 00                	push   $0x0
f0104246:	68 f4 01 00 00       	push   $0x1f4
f010424b:	eb 00                	jmp    f010424d <_alltraps>

f010424d <_alltraps>:

/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
	pushl %ds	
f010424d:	1e                   	push   %ds
	pushl %es	
f010424e:	06                   	push   %es
	pushal
f010424f:	60                   	pusha  
	
	movw $GD_KD, %ax
f0104250:	66 b8 10 00          	mov    $0x10,%ax
	movw %ax, %ds
f0104254:	8e d8                	mov    %eax,%ds
	movw %ax, %es
f0104256:	8e c0                	mov    %eax,%es
	pushl %esp
f0104258:	54                   	push   %esp
	call trap
f0104259:	e8 55 fd ff ff       	call   f0103fb3 <trap>

f010425e <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f010425e:	55                   	push   %ebp
f010425f:	89 e5                	mov    %esp,%ebp
f0104261:	83 ec 08             	sub    $0x8,%esp
f0104264:	a1 44 52 23 f0       	mov    0xf0235244,%eax
f0104269:	8d 50 54             	lea    0x54(%eax),%edx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f010426c:	b9 00 00 00 00       	mov    $0x0,%ecx
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
f0104271:	8b 02                	mov    (%edx),%eax
f0104273:	83 e8 01             	sub    $0x1,%eax
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0104276:	83 f8 02             	cmp    $0x2,%eax
f0104279:	76 2d                	jbe    f01042a8 <sched_halt+0x4a>
	for (i = 0; i < NENV; i++) {
f010427b:	83 c1 01             	add    $0x1,%ecx
f010427e:	83 c2 7c             	add    $0x7c,%edx
f0104281:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f0104287:	75 e8                	jne    f0104271 <sched_halt+0x13>
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
		cprintf("No runnable environments in the system!\n");
f0104289:	83 ec 0c             	sub    $0xc,%esp
f010428c:	68 90 76 10 f0       	push   $0xf0107690
f0104291:	e8 8a f5 ff ff       	call   f0103820 <cprintf>
f0104296:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f0104299:	83 ec 0c             	sub    $0xc,%esp
f010429c:	6a 00                	push   $0x0
f010429e:	e8 a8 c6 ff ff       	call   f010094b <monitor>
f01042a3:	83 c4 10             	add    $0x10,%esp
f01042a6:	eb f1                	jmp    f0104299 <sched_halt+0x3b>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f01042a8:	e8 ad 16 00 00       	call   f010595a <cpunum>
f01042ad:	6b c0 74             	imul   $0x74,%eax,%eax
f01042b0:	c7 80 28 60 23 f0 00 	movl   $0x0,-0xfdc9fd8(%eax)
f01042b7:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f01042ba:	a1 8c 5e 23 f0       	mov    0xf0235e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f01042bf:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01042c4:	76 4f                	jbe    f0104315 <sched_halt+0xb7>
	return (physaddr_t)kva - KERNBASE;
f01042c6:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01042cb:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f01042ce:	e8 87 16 00 00       	call   f010595a <cpunum>
f01042d3:	6b d0 74             	imul   $0x74,%eax,%edx
f01042d6:	83 c2 04             	add    $0x4,%edx
	asm volatile("lock; xchgl %0, %1"
f01042d9:	b8 02 00 00 00       	mov    $0x2,%eax
f01042de:	f0 87 82 20 60 23 f0 	lock xchg %eax,-0xfdc9fe0(%edx)
	spin_unlock(&kernel_lock);
f01042e5:	83 ec 0c             	sub    $0xc,%esp
f01042e8:	68 c0 23 12 f0       	push   $0xf01223c0
f01042ed:	e8 74 19 00 00       	call   f0105c66 <spin_unlock>
	asm volatile("pause");
f01042f2:	f3 90                	pause  
		// Uncomment the following line after completing exercise 13
		//"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f01042f4:	e8 61 16 00 00       	call   f010595a <cpunum>
f01042f9:	6b c0 74             	imul   $0x74,%eax,%eax
	asm volatile (
f01042fc:	8b 80 30 60 23 f0    	mov    -0xfdc9fd0(%eax),%eax
f0104302:	bd 00 00 00 00       	mov    $0x0,%ebp
f0104307:	89 c4                	mov    %eax,%esp
f0104309:	6a 00                	push   $0x0
f010430b:	6a 00                	push   $0x0
f010430d:	f4                   	hlt    
f010430e:	eb fd                	jmp    f010430d <sched_halt+0xaf>
}
f0104310:	83 c4 10             	add    $0x10,%esp
f0104313:	c9                   	leave  
f0104314:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104315:	50                   	push   %eax
f0104316:	68 78 60 10 f0       	push   $0xf0106078
f010431b:	6a 4f                	push   $0x4f
f010431d:	68 b9 76 10 f0       	push   $0xf01076b9
f0104322:	e8 6d bd ff ff       	call   f0100094 <_panic>

f0104327 <sched_yield>:
{
f0104327:	55                   	push   %ebp
f0104328:	89 e5                	mov    %esp,%ebp
f010432a:	56                   	push   %esi
f010432b:	53                   	push   %ebx
	idle = thiscpu->cpu_env;
f010432c:	e8 29 16 00 00       	call   f010595a <cpunum>
f0104331:	6b c0 74             	imul   $0x74,%eax,%eax
f0104334:	8b b0 28 60 23 f0    	mov    -0xfdc9fd8(%eax),%esi
    uint32_t start = (idle != NULL) ? ENVX( idle->env_id) : 0;
f010433a:	b9 00 00 00 00       	mov    $0x0,%ecx
f010433f:	85 f6                	test   %esi,%esi
f0104341:	74 09                	je     f010434c <sched_yield+0x25>
f0104343:	8b 4e 48             	mov    0x48(%esi),%ecx
f0104346:	81 e1 ff 03 00 00    	and    $0x3ff,%ecx
        if(envs[i].env_status == ENV_RUNNABLE)
f010434c:	8b 1d 44 52 23 f0    	mov    0xf0235244,%ebx
    uint32_t i = start;
f0104352:	89 c8                	mov    %ecx,%eax
        if(envs[i].env_status == ENV_RUNNABLE)
f0104354:	6b d0 7c             	imul   $0x7c,%eax,%edx
f0104357:	01 da                	add    %ebx,%edx
f0104359:	83 7a 54 02          	cmpl   $0x2,0x54(%edx)
f010435d:	74 22                	je     f0104381 <sched_yield+0x5a>
    for (; i != start || first; i = (i+1) % NENV, first = false)
f010435f:	83 c0 01             	add    $0x1,%eax
f0104362:	25 ff 03 00 00       	and    $0x3ff,%eax
f0104367:	39 c1                	cmp    %eax,%ecx
f0104369:	75 e9                	jne    f0104354 <sched_yield+0x2d>
    if (idle && idle->env_status == ENV_RUNNING)
f010436b:	85 f6                	test   %esi,%esi
f010436d:	74 06                	je     f0104375 <sched_yield+0x4e>
f010436f:	83 7e 54 03          	cmpl   $0x3,0x54(%esi)
f0104373:	74 15                	je     f010438a <sched_yield+0x63>
	sched_halt();
f0104375:	e8 e4 fe ff ff       	call   f010425e <sched_halt>
}
f010437a:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010437d:	5b                   	pop    %ebx
f010437e:	5e                   	pop    %esi
f010437f:	5d                   	pop    %ebp
f0104380:	c3                   	ret    
            env_run(&envs[i]);
f0104381:	83 ec 0c             	sub    $0xc,%esp
f0104384:	52                   	push   %edx
f0104385:	e8 6e f2 ff ff       	call   f01035f8 <env_run>
        env_run(idle);
f010438a:	83 ec 0c             	sub    $0xc,%esp
f010438d:	56                   	push   %esi
f010438e:	e8 65 f2 ff ff       	call   f01035f8 <env_run>

f0104393 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104393:	55                   	push   %ebp
f0104394:	89 e5                	mov    %esp,%ebp
f0104396:	57                   	push   %edi
f0104397:	56                   	push   %esi
f0104398:	53                   	push   %ebx
f0104399:	83 ec 1c             	sub    $0x1c,%esp
f010439c:	8b 45 08             	mov    0x8(%ebp),%eax
f010439f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
	int32_t ret = 0;
	switch (syscallno) {
f01043a2:	83 f8 0a             	cmp    $0xa,%eax
f01043a5:	0f 87 77 04 00 00    	ja     f0104822 <syscall+0x48f>
f01043ab:	ff 24 85 9c 77 10 f0 	jmp    *-0xfef8864(,%eax,4)
	user_mem_assert(curenv, s, len, PTE_U);
f01043b2:	e8 a3 15 00 00       	call   f010595a <cpunum>
f01043b7:	6a 04                	push   $0x4
f01043b9:	53                   	push   %ebx
f01043ba:	ff 75 0c             	pushl  0xc(%ebp)
f01043bd:	6b c0 74             	imul   $0x74,%eax,%eax
f01043c0:	ff b0 28 60 23 f0    	pushl  -0xfdc9fd8(%eax)
f01043c6:	e8 25 eb ff ff       	call   f0102ef0 <user_mem_assert>
	cprintf("%.*s", len, s);
f01043cb:	83 c4 0c             	add    $0xc,%esp
f01043ce:	ff 75 0c             	pushl  0xc(%ebp)
f01043d1:	53                   	push   %ebx
f01043d2:	68 c6 76 10 f0       	push   $0xf01076c6
f01043d7:	e8 44 f4 ff ff       	call   f0103820 <cprintf>
f01043dc:	83 c4 10             	add    $0x10,%esp
	int32_t ret = 0;
f01043df:	b8 00 00 00 00       	mov    $0x0,%eax
		 default:
			return -E_INVAL;

	}
	return ret;	
}
f01043e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01043e7:	5b                   	pop    %ebx
f01043e8:	5e                   	pop    %esi
f01043e9:	5f                   	pop    %edi
f01043ea:	5d                   	pop    %ebp
f01043eb:	c3                   	ret    
	return cons_getc();
f01043ec:	e8 4f c2 ff ff       	call   f0100640 <cons_getc>
			break;
f01043f1:	eb f1                	jmp    f01043e4 <syscall+0x51>
	if ((r = envid2env(envid, &e, 1)) < 0)
f01043f3:	83 ec 04             	sub    $0x4,%esp
f01043f6:	6a 01                	push   $0x1
f01043f8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01043fb:	50                   	push   %eax
f01043fc:	ff 75 0c             	pushl  0xc(%ebp)
f01043ff:	e8 75 eb ff ff       	call   f0102f79 <envid2env>
f0104404:	83 c4 10             	add    $0x10,%esp
f0104407:	85 c0                	test   %eax,%eax
f0104409:	78 d9                	js     f01043e4 <syscall+0x51>
	if (e == curenv)
f010440b:	e8 4a 15 00 00       	call   f010595a <cpunum>
f0104410:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104413:	6b c0 74             	imul   $0x74,%eax,%eax
f0104416:	39 90 28 60 23 f0    	cmp    %edx,-0xfdc9fd8(%eax)
f010441c:	74 3a                	je     f0104458 <syscall+0xc5>
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f010441e:	8b 5a 48             	mov    0x48(%edx),%ebx
f0104421:	e8 34 15 00 00       	call   f010595a <cpunum>
f0104426:	83 ec 04             	sub    $0x4,%esp
f0104429:	53                   	push   %ebx
f010442a:	6b c0 74             	imul   $0x74,%eax,%eax
f010442d:	8b 80 28 60 23 f0    	mov    -0xfdc9fd8(%eax),%eax
f0104433:	ff 70 48             	pushl  0x48(%eax)
f0104436:	68 e6 76 10 f0       	push   $0xf01076e6
f010443b:	e8 e0 f3 ff ff       	call   f0103820 <cprintf>
f0104440:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f0104443:	83 ec 0c             	sub    $0xc,%esp
f0104446:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104449:	e8 0b f1 ff ff       	call   f0103559 <env_destroy>
f010444e:	83 c4 10             	add    $0x10,%esp
	return 0;
f0104451:	b8 00 00 00 00       	mov    $0x0,%eax
			break;
f0104456:	eb 8c                	jmp    f01043e4 <syscall+0x51>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0104458:	e8 fd 14 00 00       	call   f010595a <cpunum>
f010445d:	83 ec 08             	sub    $0x8,%esp
f0104460:	6b c0 74             	imul   $0x74,%eax,%eax
f0104463:	8b 80 28 60 23 f0    	mov    -0xfdc9fd8(%eax),%eax
f0104469:	ff 70 48             	pushl  0x48(%eax)
f010446c:	68 cb 76 10 f0       	push   $0xf01076cb
f0104471:	e8 aa f3 ff ff       	call   f0103820 <cprintf>
f0104476:	83 c4 10             	add    $0x10,%esp
f0104479:	eb c8                	jmp    f0104443 <syscall+0xb0>
	return curenv->env_id;
f010447b:	e8 da 14 00 00       	call   f010595a <cpunum>
f0104480:	6b c0 74             	imul   $0x74,%eax,%eax
f0104483:	8b 80 28 60 23 f0    	mov    -0xfdc9fd8(%eax),%eax
f0104489:	8b 40 48             	mov    0x48(%eax),%eax
			break;
f010448c:	e9 53 ff ff ff       	jmp    f01043e4 <syscall+0x51>
	sched_yield();
f0104491:	e8 91 fe ff ff       	call   f0104327 <sched_yield>
	if ((r = env_alloc(&e, curenv->env_id)) < 0) {
f0104496:	e8 bf 14 00 00       	call   f010595a <cpunum>
f010449b:	83 ec 08             	sub    $0x8,%esp
f010449e:	6b c0 74             	imul   $0x74,%eax,%eax
f01044a1:	8b 80 28 60 23 f0    	mov    -0xfdc9fd8(%eax),%eax
f01044a7:	ff 70 48             	pushl  0x48(%eax)
f01044aa:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01044ad:	50                   	push   %eax
f01044ae:	e8 d4 eb ff ff       	call   f0103087 <env_alloc>
f01044b3:	83 c4 10             	add    $0x10,%esp
f01044b6:	85 c0                	test   %eax,%eax
f01044b8:	0f 88 26 ff ff ff    	js     f01043e4 <syscall+0x51>
		e->env_status = ENV_NOT_RUNNABLE;
f01044be:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01044c1:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
		e->env_tf = curenv->env_tf;
f01044c8:	e8 8d 14 00 00       	call   f010595a <cpunum>
f01044cd:	6b c0 74             	imul   $0x74,%eax,%eax
f01044d0:	8b b0 28 60 23 f0    	mov    -0xfdc9fd8(%eax),%esi
f01044d6:	b9 11 00 00 00       	mov    $0x11,%ecx
f01044db:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01044de:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		e->env_tf.tf_regs.reg_eax = 0;
f01044e0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01044e3:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
		return e->env_id;
f01044ea:	8b 40 48             	mov    0x48(%eax),%eax
			break;
f01044ed:	e9 f2 fe ff ff       	jmp    f01043e4 <syscall+0x51>
    if (envid2env(envid, &e, 1) < 0) 
f01044f2:	83 ec 04             	sub    $0x4,%esp
f01044f5:	6a 01                	push   $0x1
f01044f7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01044fa:	50                   	push   %eax
f01044fb:	ff 75 0c             	pushl  0xc(%ebp)
f01044fe:	e8 76 ea ff ff       	call   f0102f79 <envid2env>
f0104503:	83 c4 10             	add    $0x10,%esp
f0104506:	85 c0                	test   %eax,%eax
f0104508:	78 1a                	js     f0104524 <syscall+0x191>
    if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE) 
f010450a:	8d 43 fe             	lea    -0x2(%ebx),%eax
f010450d:	a9 fd ff ff ff       	test   $0xfffffffd,%eax
f0104512:	75 1a                	jne    f010452e <syscall+0x19b>
    e->env_status = status;
f0104514:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104517:	89 58 54             	mov    %ebx,0x54(%eax)
    return 0;
f010451a:	b8 00 00 00 00       	mov    $0x0,%eax
f010451f:	e9 c0 fe ff ff       	jmp    f01043e4 <syscall+0x51>
		return -E_BAD_ENV;
f0104524:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104529:	e9 b6 fe ff ff       	jmp    f01043e4 <syscall+0x51>
		return -E_INVAL;
f010452e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
   		     break;
f0104533:	e9 ac fe ff ff       	jmp    f01043e4 <syscall+0x51>
	int r = envid2env(envid, &e, true);
f0104538:	83 ec 04             	sub    $0x4,%esp
f010453b:	6a 01                	push   $0x1
f010453d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104540:	50                   	push   %eax
f0104541:	ff 75 0c             	pushl  0xc(%ebp)
f0104544:	e8 30 ea ff ff       	call   f0102f79 <envid2env>
	if (r != 0) {
f0104549:	83 c4 10             	add    $0x10,%esp
f010454c:	85 c0                	test   %eax,%eax
f010454e:	0f 85 90 fe ff ff    	jne    f01043e4 <syscall+0x51>
	assert(func != NULL);
f0104554:	85 db                	test   %ebx,%ebx
f0104556:	74 0b                	je     f0104563 <syscall+0x1d0>
	e->env_pgfault_upcall = func;
f0104558:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010455b:	89 5a 64             	mov    %ebx,0x64(%edx)
			break;
f010455e:	e9 81 fe ff ff       	jmp    f01043e4 <syscall+0x51>
	assert(func != NULL);
f0104563:	68 fe 76 10 f0       	push   $0xf01076fe
f0104568:	68 be 65 10 f0       	push   $0xf01065be
f010456d:	68 90 00 00 00       	push   $0x90
f0104572:	68 0b 77 10 f0       	push   $0xf010770b
f0104577:	e8 18 bb ff ff       	call   f0100094 <_panic>
	   (perm & (~(PTE_U|PTE_AVAIL|PTE_P|PTE_W))) != 0 ||
f010457c:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
f0104582:	77 7d                	ja     f0104601 <syscall+0x26e>
	   (uintptr_t)va >= UTOP || 
f0104584:	8b 45 14             	mov    0x14(%ebp),%eax
f0104587:	25 fd f1 ff ff       	and    $0xfffff1fd,%eax
f010458c:	83 f0 05             	xor    $0x5,%eax
	   PGOFF(va) != 0)
f010458f:	89 da                	mov    %ebx,%edx
f0104591:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
	   (uintptr_t)va >= UTOP || 
f0104597:	09 d0                	or     %edx,%eax
f0104599:	75 70                	jne    f010460b <syscall+0x278>
	struct PageInfo *pginfo = page_alloc(ALLOC_ZERO);
f010459b:	83 ec 0c             	sub    $0xc,%esp
f010459e:	6a 01                	push   $0x1
f01045a0:	e8 ec c9 ff ff       	call   f0100f91 <page_alloc>
f01045a5:	89 c6                	mov    %eax,%esi
	if (!pginfo) return -E_NO_MEM;
f01045a7:	83 c4 10             	add    $0x10,%esp
f01045aa:	85 c0                	test   %eax,%eax
f01045ac:	74 67                	je     f0104615 <syscall+0x282>
	if((r = envid2env(envid, &e, 1)) < 0) return r;
f01045ae:	83 ec 04             	sub    $0x4,%esp
f01045b1:	6a 01                	push   $0x1
f01045b3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01045b6:	50                   	push   %eax
f01045b7:	ff 75 0c             	pushl  0xc(%ebp)
f01045ba:	e8 ba e9 ff ff       	call   f0102f79 <envid2env>
f01045bf:	83 c4 10             	add    $0x10,%esp
f01045c2:	85 c0                	test   %eax,%eax
f01045c4:	0f 88 1a fe ff ff    	js     f01043e4 <syscall+0x51>
	r = page_insert(e->env_pgdir, pginfo, va, perm);
f01045ca:	ff 75 14             	pushl  0x14(%ebp)
f01045cd:	53                   	push   %ebx
f01045ce:	56                   	push   %esi
f01045cf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01045d2:	ff 70 60             	pushl  0x60(%eax)
f01045d5:	e8 78 cc ff ff       	call   f0101252 <page_insert>
	if (r<0) {
f01045da:	83 c4 10             	add    $0x10,%esp
f01045dd:	85 c0                	test   %eax,%eax
f01045df:	78 0a                	js     f01045eb <syscall+0x258>
	return 0;
f01045e1:	b8 00 00 00 00       	mov    $0x0,%eax
       	    break;
f01045e6:	e9 f9 fd ff ff       	jmp    f01043e4 <syscall+0x51>
		 page_free(pginfo);
f01045eb:	83 ec 0c             	sub    $0xc,%esp
f01045ee:	56                   	push   %esi
f01045ef:	e8 0f ca ff ff       	call   f0101003 <page_free>
f01045f4:	83 c4 10             	add    $0x10,%esp
		 return -E_NO_MEM;
f01045f7:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01045fc:	e9 e3 fd ff ff       	jmp    f01043e4 <syscall+0x51>
		 return -E_INVAL;
f0104601:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104606:	e9 d9 fd ff ff       	jmp    f01043e4 <syscall+0x51>
f010460b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104610:	e9 cf fd ff ff       	jmp    f01043e4 <syscall+0x51>
	if (!pginfo) return -E_NO_MEM;
f0104615:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f010461a:	e9 c5 fd ff ff       	jmp    f01043e4 <syscall+0x51>
	struct Env *src_env = NULL;
f010461f:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	int r = envid2env(srcenvid, &src_env, true);
f0104626:	83 ec 04             	sub    $0x4,%esp
f0104629:	6a 01                	push   $0x1
f010462b:	8d 45 dc             	lea    -0x24(%ebp),%eax
f010462e:	50                   	push   %eax
f010462f:	ff 75 0c             	pushl  0xc(%ebp)
f0104632:	e8 42 e9 ff ff       	call   f0102f79 <envid2env>
	if( r != 0 ) { 
f0104637:	83 c4 10             	add    $0x10,%esp
f010463a:	85 c0                	test   %eax,%eax
f010463c:	0f 85 a2 fd ff ff    	jne    f01043e4 <syscall+0x51>
	assert(src_env != NULL);
f0104642:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104645:	85 c0                	test   %eax,%eax
f0104647:	0f 84 dd 00 00 00    	je     f010472a <syscall+0x397>
	assert(srcenvid == 0 || src_env->env_id == srcenvid);
f010464d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0104651:	74 0c                	je     f010465f <syscall+0x2cc>
f0104653:	8b 40 48             	mov    0x48(%eax),%eax
f0104656:	39 45 0c             	cmp    %eax,0xc(%ebp)
f0104659:	0f 85 e4 00 00 00    	jne    f0104743 <syscall+0x3b0>
	struct Env *dst_env = NULL;
f010465f:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
	r = envid2env(dstenvid, &dst_env, true);
f0104666:	83 ec 04             	sub    $0x4,%esp
f0104669:	6a 01                	push   $0x1
f010466b:	8d 45 e0             	lea    -0x20(%ebp),%eax
f010466e:	50                   	push   %eax
f010466f:	ff 75 14             	pushl  0x14(%ebp)
f0104672:	e8 02 e9 ff ff       	call   f0102f79 <envid2env>
	if( r != 0 ) { 
f0104677:	83 c4 10             	add    $0x10,%esp
f010467a:	85 c0                	test   %eax,%eax
f010467c:	0f 85 62 fd ff ff    	jne    f01043e4 <syscall+0x51>
	assert(dst_env != NULL);
f0104682:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104685:	85 c0                	test   %eax,%eax
f0104687:	0f 84 cf 00 00 00    	je     f010475c <syscall+0x3c9>
	assert(dstenvid == 0 || dst_env->env_id == dstenvid);
f010468d:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
f0104691:	74 0c                	je     f010469f <syscall+0x30c>
f0104693:	8b 40 48             	mov    0x48(%eax),%eax
f0104696:	39 45 14             	cmp    %eax,0x14(%ebp)
f0104699:	0f 85 d6 00 00 00    	jne    f0104775 <syscall+0x3e2>
	if((uint32_t)srcva >= UTOP || (uint32_t)dstva >= UTOP || \
f010469f:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
f01046a5:	0f 87 e3 00 00 00    	ja     f010478e <syscall+0x3fb>
f01046ab:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f01046b2:	0f 87 d6 00 00 00    	ja     f010478e <syscall+0x3fb>
		PGOFF(srcva) != 0 || PGOFF(dstva) != 0) {
f01046b8:	89 d8                	mov    %ebx,%eax
f01046ba:	0b 45 18             	or     0x18(%ebp),%eax
f01046bd:	a9 ff 0f 00 00       	test   $0xfff,%eax
f01046c2:	0f 85 d0 00 00 00    	jne    f0104798 <syscall+0x405>
	if(( perm & PTE_U) == 0 || (perm & PTE_P) == 0 || (perm & ~PTE_SYSCALL) != 0) {
f01046c8:	8b 45 1c             	mov    0x1c(%ebp),%eax
f01046cb:	25 fd f1 ff ff       	and    $0xfffff1fd,%eax
f01046d0:	83 f8 05             	cmp    $0x5,%eax
f01046d3:	0f 85 c9 00 00 00    	jne    f01047a2 <syscall+0x40f>
	pte_t *src_ptep = NULL;
f01046d9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	struct PageInfo *pp = page_lookup(src_env->env_pgdir, srcva, &src_ptep);
f01046e0:	83 ec 04             	sub    $0x4,%esp
f01046e3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01046e6:	50                   	push   %eax
f01046e7:	53                   	push   %ebx
f01046e8:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01046eb:	ff 70 60             	pushl  0x60(%eax)
f01046ee:	e8 88 ca ff ff       	call   f010117b <page_lookup>
	if(!pp || ((perm & PTE_W) && ((*src_ptep & PTE_W) != PTE_W))) {
f01046f3:	83 c4 10             	add    $0x10,%esp
f01046f6:	85 c0                	test   %eax,%eax
f01046f8:	0f 84 ae 00 00 00    	je     f01047ac <syscall+0x419>
f01046fe:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f0104702:	74 0c                	je     f0104710 <syscall+0x37d>
f0104704:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104707:	f6 02 02             	testb  $0x2,(%edx)
f010470a:	0f 84 a6 00 00 00    	je     f01047b6 <syscall+0x423>
	return page_insert(dst_env->env_pgdir, pp, dstva, perm);
f0104710:	ff 75 1c             	pushl  0x1c(%ebp)
f0104713:	ff 75 18             	pushl  0x18(%ebp)
f0104716:	50                   	push   %eax
f0104717:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010471a:	ff 70 60             	pushl  0x60(%eax)
f010471d:	e8 30 cb ff ff       	call   f0101252 <page_insert>
f0104722:	83 c4 10             	add    $0x10,%esp
f0104725:	e9 ba fc ff ff       	jmp    f01043e4 <syscall+0x51>
	assert(src_env != NULL);
f010472a:	68 1a 77 10 f0       	push   $0xf010771a
f010472f:	68 be 65 10 f0       	push   $0xf01065be
f0104734:	68 e9 00 00 00       	push   $0xe9
f0104739:	68 0b 77 10 f0       	push   $0xf010770b
f010473e:	e8 51 b9 ff ff       	call   f0100094 <_panic>
	assert(srcenvid == 0 || src_env->env_id == srcenvid);
f0104743:	68 3c 77 10 f0       	push   $0xf010773c
f0104748:	68 be 65 10 f0       	push   $0xf01065be
f010474d:	68 ea 00 00 00       	push   $0xea
f0104752:	68 0b 77 10 f0       	push   $0xf010770b
f0104757:	e8 38 b9 ff ff       	call   f0100094 <_panic>
	assert(dst_env != NULL);
f010475c:	68 2a 77 10 f0       	push   $0xf010772a
f0104761:	68 be 65 10 f0       	push   $0xf01065be
f0104766:	68 f0 00 00 00       	push   $0xf0
f010476b:	68 0b 77 10 f0       	push   $0xf010770b
f0104770:	e8 1f b9 ff ff       	call   f0100094 <_panic>
	assert(dstenvid == 0 || dst_env->env_id == dstenvid);
f0104775:	68 6c 77 10 f0       	push   $0xf010776c
f010477a:	68 be 65 10 f0       	push   $0xf01065be
f010477f:	68 f1 00 00 00       	push   $0xf1
f0104784:	68 0b 77 10 f0       	push   $0xf010770b
f0104789:	e8 06 b9 ff ff       	call   f0100094 <_panic>
		return -E_INVAL;
f010478e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104793:	e9 4c fc ff ff       	jmp    f01043e4 <syscall+0x51>
f0104798:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010479d:	e9 42 fc ff ff       	jmp    f01043e4 <syscall+0x51>
		return -E_INVAL;
f01047a2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01047a7:	e9 38 fc ff ff       	jmp    f01043e4 <syscall+0x51>
		return -E_INVAL;
f01047ac:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01047b1:	e9 2e fc ff ff       	jmp    f01043e4 <syscall+0x51>
f01047b6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
            break;
f01047bb:	e9 24 fc ff ff       	jmp    f01043e4 <syscall+0x51>
    if (envid2env(envid, &e, 1) < 0) 
f01047c0:	83 ec 04             	sub    $0x4,%esp
f01047c3:	6a 01                	push   $0x1
f01047c5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01047c8:	50                   	push   %eax
f01047c9:	ff 75 0c             	pushl  0xc(%ebp)
f01047cc:	e8 a8 e7 ff ff       	call   f0102f79 <envid2env>
f01047d1:	83 c4 10             	add    $0x10,%esp
f01047d4:	85 c0                	test   %eax,%eax
f01047d6:	78 2c                	js     f0104804 <syscall+0x471>
	if ((uintptr_t)va >= UTOP || PGOFF(va) != 0) 
f01047d8:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
f01047de:	77 2e                	ja     f010480e <syscall+0x47b>
f01047e0:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
f01047e6:	75 30                	jne    f0104818 <syscall+0x485>
    page_remove(e->env_pgdir, va);
f01047e8:	83 ec 08             	sub    $0x8,%esp
f01047eb:	53                   	push   %ebx
f01047ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01047ef:	ff 70 60             	pushl  0x60(%eax)
f01047f2:	e8 15 ca ff ff       	call   f010120c <page_remove>
f01047f7:	83 c4 10             	add    $0x10,%esp
    return 0;	
f01047fa:	b8 00 00 00 00       	mov    $0x0,%eax
f01047ff:	e9 e0 fb ff ff       	jmp    f01043e4 <syscall+0x51>
		return -E_BAD_ENV;
f0104804:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104809:	e9 d6 fb ff ff       	jmp    f01043e4 <syscall+0x51>
		return -E_INVAL;
f010480e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104813:	e9 cc fb ff ff       	jmp    f01043e4 <syscall+0x51>
f0104818:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
       	    break;
f010481d:	e9 c2 fb ff ff       	jmp    f01043e4 <syscall+0x51>
			return -E_INVAL;
f0104822:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104827:	e9 b8 fb ff ff       	jmp    f01043e4 <syscall+0x51>

f010482c <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f010482c:	55                   	push   %ebp
f010482d:	89 e5                	mov    %esp,%ebp
f010482f:	57                   	push   %edi
f0104830:	56                   	push   %esi
f0104831:	53                   	push   %ebx
f0104832:	83 ec 14             	sub    $0x14,%esp
f0104835:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104838:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f010483b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f010483e:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0104841:	8b 1a                	mov    (%edx),%ebx
f0104843:	8b 01                	mov    (%ecx),%eax
f0104845:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104848:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f010484f:	eb 23                	jmp    f0104874 <stab_binsearch+0x48>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0104851:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0104854:	eb 1e                	jmp    f0104874 <stab_binsearch+0x48>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0104856:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104859:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010485c:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0104860:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0104863:	73 41                	jae    f01048a6 <stab_binsearch+0x7a>
			*region_left = m;
f0104865:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104868:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f010486a:	8d 5f 01             	lea    0x1(%edi),%ebx
		any_matches = 1;
f010486d:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0104874:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0104877:	7f 5a                	jg     f01048d3 <stab_binsearch+0xa7>
		int true_m = (l + r) / 2, m = true_m;
f0104879:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010487c:	01 d8                	add    %ebx,%eax
f010487e:	89 c7                	mov    %eax,%edi
f0104880:	c1 ef 1f             	shr    $0x1f,%edi
f0104883:	01 c7                	add    %eax,%edi
f0104885:	d1 ff                	sar    %edi
f0104887:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f010488a:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010488d:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0104891:	89 f8                	mov    %edi,%eax
		while (m >= l && stabs[m].n_type != type)
f0104893:	39 c3                	cmp    %eax,%ebx
f0104895:	7f ba                	jg     f0104851 <stab_binsearch+0x25>
f0104897:	0f b6 0a             	movzbl (%edx),%ecx
f010489a:	83 ea 0c             	sub    $0xc,%edx
f010489d:	39 f1                	cmp    %esi,%ecx
f010489f:	74 b5                	je     f0104856 <stab_binsearch+0x2a>
			m--;
f01048a1:	83 e8 01             	sub    $0x1,%eax
f01048a4:	eb ed                	jmp    f0104893 <stab_binsearch+0x67>
		} else if (stabs[m].n_value > addr) {
f01048a6:	3b 55 0c             	cmp    0xc(%ebp),%edx
f01048a9:	76 14                	jbe    f01048bf <stab_binsearch+0x93>
			*region_right = m - 1;
f01048ab:	83 e8 01             	sub    $0x1,%eax
f01048ae:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01048b1:	8b 7d e0             	mov    -0x20(%ebp),%edi
f01048b4:	89 07                	mov    %eax,(%edi)
		any_matches = 1;
f01048b6:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01048bd:	eb b5                	jmp    f0104874 <stab_binsearch+0x48>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f01048bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01048c2:	89 07                	mov    %eax,(%edi)
			l = m;
			addr++;
f01048c4:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f01048c8:	89 c3                	mov    %eax,%ebx
		any_matches = 1;
f01048ca:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01048d1:	eb a1                	jmp    f0104874 <stab_binsearch+0x48>
		}
	}

	if (!any_matches)
f01048d3:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f01048d7:	75 15                	jne    f01048ee <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f01048d9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01048dc:	8b 00                	mov    (%eax),%eax
f01048de:	83 e8 01             	sub    $0x1,%eax
f01048e1:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01048e4:	89 06                	mov    %eax,(%esi)
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f01048e6:	83 c4 14             	add    $0x14,%esp
f01048e9:	5b                   	pop    %ebx
f01048ea:	5e                   	pop    %esi
f01048eb:	5f                   	pop    %edi
f01048ec:	5d                   	pop    %ebp
f01048ed:	c3                   	ret    
		for (l = *region_right;
f01048ee:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01048f1:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f01048f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01048f6:	8b 0f                	mov    (%edi),%ecx
f01048f8:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01048fb:	8b 7d ec             	mov    -0x14(%ebp),%edi
f01048fe:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
		for (l = *region_right;
f0104902:	eb 03                	jmp    f0104907 <stab_binsearch+0xdb>
		     l--)
f0104904:	83 e8 01             	sub    $0x1,%eax
		for (l = *region_right;
f0104907:	39 c1                	cmp    %eax,%ecx
f0104909:	7d 0a                	jge    f0104915 <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f010490b:	0f b6 1a             	movzbl (%edx),%ebx
f010490e:	83 ea 0c             	sub    $0xc,%edx
f0104911:	39 f3                	cmp    %esi,%ebx
f0104913:	75 ef                	jne    f0104904 <stab_binsearch+0xd8>
		*region_left = l;
f0104915:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104918:	89 06                	mov    %eax,(%esi)
}
f010491a:	eb ca                	jmp    f01048e6 <stab_binsearch+0xba>

f010491c <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f010491c:	55                   	push   %ebp
f010491d:	89 e5                	mov    %esp,%ebp
f010491f:	57                   	push   %edi
f0104920:	56                   	push   %esi
f0104921:	53                   	push   %ebx
f0104922:	83 ec 4c             	sub    $0x4c,%esp
f0104925:	8b 75 08             	mov    0x8(%ebp),%esi
f0104928:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f010492b:	c7 03 c8 77 10 f0    	movl   $0xf01077c8,(%ebx)
	info->eip_line = 0;
f0104931:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0104938:	c7 43 08 c8 77 10 f0 	movl   $0xf01077c8,0x8(%ebx)
	info->eip_fn_namelen = 9;
f010493f:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0104946:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0104949:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0104950:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0104956:	0f 87 1d 01 00 00    	ja     f0104a79 <debuginfo_eip+0x15d>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f010495c:	a1 00 00 20 00       	mov    0x200000,%eax
f0104961:	89 45 b8             	mov    %eax,-0x48(%ebp)
		stab_end = usd->stab_end;
f0104964:	a1 04 00 20 00       	mov    0x200004,%eax
		stabstr = usd->stabstr;
f0104969:	8b 3d 08 00 20 00    	mov    0x200008,%edi
f010496f:	89 7d b4             	mov    %edi,-0x4c(%ebp)
		stabstr_end = usd->stabstr_end;
f0104972:	8b 3d 0c 00 20 00    	mov    0x20000c,%edi
f0104978:	89 7d bc             	mov    %edi,-0x44(%ebp)
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f010497b:	8b 7d bc             	mov    -0x44(%ebp),%edi
f010497e:	39 7d b4             	cmp    %edi,-0x4c(%ebp)
f0104981:	0f 83 bb 01 00 00    	jae    f0104b42 <debuginfo_eip+0x226>
f0104987:	80 7f ff 00          	cmpb   $0x0,-0x1(%edi)
f010498b:	0f 85 b8 01 00 00    	jne    f0104b49 <debuginfo_eip+0x22d>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0104991:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0104998:	8b 7d b8             	mov    -0x48(%ebp),%edi
f010499b:	29 f8                	sub    %edi,%eax
f010499d:	c1 f8 02             	sar    $0x2,%eax
f01049a0:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f01049a6:	83 e8 01             	sub    $0x1,%eax
f01049a9:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f01049ac:	56                   	push   %esi
f01049ad:	6a 64                	push   $0x64
f01049af:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01049b2:	89 c1                	mov    %eax,%ecx
f01049b4:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f01049b7:	89 f8                	mov    %edi,%eax
f01049b9:	e8 6e fe ff ff       	call   f010482c <stab_binsearch>
	if (lfile == 0)
f01049be:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01049c1:	83 c4 08             	add    $0x8,%esp
f01049c4:	85 c0                	test   %eax,%eax
f01049c6:	0f 84 84 01 00 00    	je     f0104b50 <debuginfo_eip+0x234>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f01049cc:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f01049cf:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01049d2:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f01049d5:	56                   	push   %esi
f01049d6:	6a 24                	push   $0x24
f01049d8:	8d 45 d8             	lea    -0x28(%ebp),%eax
f01049db:	89 c1                	mov    %eax,%ecx
f01049dd:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01049e0:	89 f8                	mov    %edi,%eax
f01049e2:	e8 45 fe ff ff       	call   f010482c <stab_binsearch>

	if (lfun <= rfun) {
f01049e7:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01049ea:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f01049ed:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
f01049f0:	83 c4 08             	add    $0x8,%esp
f01049f3:	39 c8                	cmp    %ecx,%eax
f01049f5:	0f 8f 9d 00 00 00    	jg     f0104a98 <debuginfo_eip+0x17c>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f01049fb:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01049fe:	8d 0c 97             	lea    (%edi,%edx,4),%ecx
f0104a01:	8b 11                	mov    (%ecx),%edx
f0104a03:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0104a06:	2b 7d b4             	sub    -0x4c(%ebp),%edi
f0104a09:	39 fa                	cmp    %edi,%edx
f0104a0b:	73 06                	jae    f0104a13 <debuginfo_eip+0xf7>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0104a0d:	03 55 b4             	add    -0x4c(%ebp),%edx
f0104a10:	89 53 08             	mov    %edx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0104a13:	8b 51 08             	mov    0x8(%ecx),%edx
f0104a16:	89 53 10             	mov    %edx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0104a19:	29 d6                	sub    %edx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0104a1b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0104a1e:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0104a21:	89 45 d0             	mov    %eax,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0104a24:	83 ec 08             	sub    $0x8,%esp
f0104a27:	6a 3a                	push   $0x3a
f0104a29:	ff 73 08             	pushl  0x8(%ebx)
f0104a2c:	e8 0e 09 00 00       	call   f010533f <strfind>
f0104a31:	2b 43 08             	sub    0x8(%ebx),%eax
f0104a34:	89 43 0c             	mov    %eax,0xc(%ebx)
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0104a37:	83 c4 08             	add    $0x8,%esp
f0104a3a:	56                   	push   %esi
f0104a3b:	6a 44                	push   $0x44
f0104a3d:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0104a40:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0104a43:	8b 75 b8             	mov    -0x48(%ebp),%esi
f0104a46:	89 f0                	mov    %esi,%eax
f0104a48:	e8 df fd ff ff       	call   f010482c <stab_binsearch>
	if (lline <= rline) {
f0104a4d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0104a50:	83 c4 10             	add    $0x10,%esp
f0104a53:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f0104a56:	0f 8f fb 00 00 00    	jg     f0104b57 <debuginfo_eip+0x23b>
		 info->eip_line = stabs[lline].n_desc;
f0104a5c:	89 d0                	mov    %edx,%eax
f0104a5e:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0104a61:	c1 e2 02             	shl    $0x2,%edx
f0104a64:	0f b7 4c 16 06       	movzwl 0x6(%esi,%edx,1),%ecx
f0104a69:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104a6c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104a6f:	8d 54 16 04          	lea    0x4(%esi,%edx,1),%edx
f0104a73:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f0104a77:	eb 3d                	jmp    f0104ab6 <debuginfo_eip+0x19a>
		stabstr_end = __STABSTR_END__;
f0104a79:	c7 45 bc 4f 7a 11 f0 	movl   $0xf0117a4f,-0x44(%ebp)
		stabstr = __STABSTR_BEGIN__;
f0104a80:	c7 45 b4 a9 42 11 f0 	movl   $0xf01142a9,-0x4c(%ebp)
		stab_end = __STAB_END__;
f0104a87:	b8 a8 42 11 f0       	mov    $0xf01142a8,%eax
		stabs = __STAB_BEGIN__;
f0104a8c:	c7 45 b8 b4 7c 10 f0 	movl   $0xf0107cb4,-0x48(%ebp)
f0104a93:	e9 e3 fe ff ff       	jmp    f010497b <debuginfo_eip+0x5f>
		info->eip_fn_addr = addr;
f0104a98:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0104a9b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104a9e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0104aa1:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104aa4:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0104aa7:	e9 78 ff ff ff       	jmp    f0104a24 <debuginfo_eip+0x108>
f0104aac:	83 e8 01             	sub    $0x1,%eax
f0104aaf:	83 ea 0c             	sub    $0xc,%edx
f0104ab2:	c6 45 c4 01          	movb   $0x1,-0x3c(%ebp)
f0104ab6:	89 45 c0             	mov    %eax,-0x40(%ebp)
	while (lline >= lfile
f0104ab9:	39 c7                	cmp    %eax,%edi
f0104abb:	7f 45                	jg     f0104b02 <debuginfo_eip+0x1e6>
	       && stabs[lline].n_type != N_SOL
f0104abd:	0f b6 0a             	movzbl (%edx),%ecx
f0104ac0:	80 f9 84             	cmp    $0x84,%cl
f0104ac3:	74 19                	je     f0104ade <debuginfo_eip+0x1c2>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104ac5:	80 f9 64             	cmp    $0x64,%cl
f0104ac8:	75 e2                	jne    f0104aac <debuginfo_eip+0x190>
f0104aca:	83 7a 04 00          	cmpl   $0x0,0x4(%edx)
f0104ace:	74 dc                	je     f0104aac <debuginfo_eip+0x190>
f0104ad0:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0104ad4:	74 11                	je     f0104ae7 <debuginfo_eip+0x1cb>
f0104ad6:	8b 75 c0             	mov    -0x40(%ebp),%esi
f0104ad9:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0104adc:	eb 09                	jmp    f0104ae7 <debuginfo_eip+0x1cb>
f0104ade:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0104ae2:	74 03                	je     f0104ae7 <debuginfo_eip+0x1cb>
f0104ae4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0104ae7:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0104aea:	8b 7d b8             	mov    -0x48(%ebp),%edi
f0104aed:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0104af0:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0104af3:	8b 7d b4             	mov    -0x4c(%ebp),%edi
f0104af6:	29 f8                	sub    %edi,%eax
f0104af8:	39 c2                	cmp    %eax,%edx
f0104afa:	73 06                	jae    f0104b02 <debuginfo_eip+0x1e6>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0104afc:	89 f8                	mov    %edi,%eax
f0104afe:	01 d0                	add    %edx,%eax
f0104b00:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104b02:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104b05:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104b08:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f0104b0d:	39 f2                	cmp    %esi,%edx
f0104b0f:	7d 52                	jge    f0104b63 <debuginfo_eip+0x247>
		for (lline = lfun + 1;
f0104b11:	83 c2 01             	add    $0x1,%edx
f0104b14:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0104b17:	89 d0                	mov    %edx,%eax
f0104b19:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0104b1c:	8b 7d b8             	mov    -0x48(%ebp),%edi
f0104b1f:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
f0104b23:	eb 04                	jmp    f0104b29 <debuginfo_eip+0x20d>
			info->eip_fn_narg++;
f0104b25:	83 43 14 01          	addl   $0x1,0x14(%ebx)
		for (lline = lfun + 1;
f0104b29:	39 c6                	cmp    %eax,%esi
f0104b2b:	7e 31                	jle    f0104b5e <debuginfo_eip+0x242>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0104b2d:	0f b6 0a             	movzbl (%edx),%ecx
f0104b30:	83 c0 01             	add    $0x1,%eax
f0104b33:	83 c2 0c             	add    $0xc,%edx
f0104b36:	80 f9 a0             	cmp    $0xa0,%cl
f0104b39:	74 ea                	je     f0104b25 <debuginfo_eip+0x209>
	return 0;
f0104b3b:	b8 00 00 00 00       	mov    $0x0,%eax
f0104b40:	eb 21                	jmp    f0104b63 <debuginfo_eip+0x247>
		return -1;
f0104b42:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104b47:	eb 1a                	jmp    f0104b63 <debuginfo_eip+0x247>
f0104b49:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104b4e:	eb 13                	jmp    f0104b63 <debuginfo_eip+0x247>
		return -1;
f0104b50:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104b55:	eb 0c                	jmp    f0104b63 <debuginfo_eip+0x247>
		 return -1;
f0104b57:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104b5c:	eb 05                	jmp    f0104b63 <debuginfo_eip+0x247>
	return 0;
f0104b5e:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104b63:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104b66:	5b                   	pop    %ebx
f0104b67:	5e                   	pop    %esi
f0104b68:	5f                   	pop    %edi
f0104b69:	5d                   	pop    %ebp
f0104b6a:	c3                   	ret    

f0104b6b <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0104b6b:	55                   	push   %ebp
f0104b6c:	89 e5                	mov    %esp,%ebp
f0104b6e:	57                   	push   %edi
f0104b6f:	56                   	push   %esi
f0104b70:	53                   	push   %ebx
f0104b71:	83 ec 1c             	sub    $0x1c,%esp
f0104b74:	89 c7                	mov    %eax,%edi
f0104b76:	89 d6                	mov    %edx,%esi
f0104b78:	8b 45 08             	mov    0x8(%ebp),%eax
f0104b7b:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104b7e:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104b81:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0104b84:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104b87:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104b8c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104b8f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0104b92:	3b 45 10             	cmp    0x10(%ebp),%eax
f0104b95:	89 d0                	mov    %edx,%eax
f0104b97:	1b 45 e4             	sbb    -0x1c(%ebp),%eax
f0104b9a:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0104b9d:	73 15                	jae    f0104bb4 <printnum+0x49>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0104b9f:	83 eb 01             	sub    $0x1,%ebx
f0104ba2:	85 db                	test   %ebx,%ebx
f0104ba4:	7e 43                	jle    f0104be9 <printnum+0x7e>
			putch(padc, putdat);
f0104ba6:	83 ec 08             	sub    $0x8,%esp
f0104ba9:	56                   	push   %esi
f0104baa:	ff 75 18             	pushl  0x18(%ebp)
f0104bad:	ff d7                	call   *%edi
f0104baf:	83 c4 10             	add    $0x10,%esp
f0104bb2:	eb eb                	jmp    f0104b9f <printnum+0x34>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0104bb4:	83 ec 0c             	sub    $0xc,%esp
f0104bb7:	ff 75 18             	pushl  0x18(%ebp)
f0104bba:	8b 45 14             	mov    0x14(%ebp),%eax
f0104bbd:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0104bc0:	53                   	push   %ebx
f0104bc1:	ff 75 10             	pushl  0x10(%ebp)
f0104bc4:	83 ec 08             	sub    $0x8,%esp
f0104bc7:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104bca:	ff 75 e0             	pushl  -0x20(%ebp)
f0104bcd:	ff 75 dc             	pushl  -0x24(%ebp)
f0104bd0:	ff 75 d8             	pushl  -0x28(%ebp)
f0104bd3:	e8 78 11 00 00       	call   f0105d50 <__udivdi3>
f0104bd8:	83 c4 18             	add    $0x18,%esp
f0104bdb:	52                   	push   %edx
f0104bdc:	50                   	push   %eax
f0104bdd:	89 f2                	mov    %esi,%edx
f0104bdf:	89 f8                	mov    %edi,%eax
f0104be1:	e8 85 ff ff ff       	call   f0104b6b <printnum>
f0104be6:	83 c4 20             	add    $0x20,%esp
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0104be9:	83 ec 08             	sub    $0x8,%esp
f0104bec:	56                   	push   %esi
f0104bed:	83 ec 04             	sub    $0x4,%esp
f0104bf0:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104bf3:	ff 75 e0             	pushl  -0x20(%ebp)
f0104bf6:	ff 75 dc             	pushl  -0x24(%ebp)
f0104bf9:	ff 75 d8             	pushl  -0x28(%ebp)
f0104bfc:	e8 5f 12 00 00       	call   f0105e60 <__umoddi3>
f0104c01:	83 c4 14             	add    $0x14,%esp
f0104c04:	0f be 80 d2 77 10 f0 	movsbl -0xfef882e(%eax),%eax
f0104c0b:	50                   	push   %eax
f0104c0c:	ff d7                	call   *%edi
}
f0104c0e:	83 c4 10             	add    $0x10,%esp
f0104c11:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104c14:	5b                   	pop    %ebx
f0104c15:	5e                   	pop    %esi
f0104c16:	5f                   	pop    %edi
f0104c17:	5d                   	pop    %ebp
f0104c18:	c3                   	ret    

f0104c19 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0104c19:	55                   	push   %ebp
f0104c1a:	89 e5                	mov    %esp,%ebp
f0104c1c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0104c1f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0104c23:	8b 10                	mov    (%eax),%edx
f0104c25:	3b 50 04             	cmp    0x4(%eax),%edx
f0104c28:	73 0a                	jae    f0104c34 <sprintputch+0x1b>
		*b->buf++ = ch;
f0104c2a:	8d 4a 01             	lea    0x1(%edx),%ecx
f0104c2d:	89 08                	mov    %ecx,(%eax)
f0104c2f:	8b 45 08             	mov    0x8(%ebp),%eax
f0104c32:	88 02                	mov    %al,(%edx)
}
f0104c34:	5d                   	pop    %ebp
f0104c35:	c3                   	ret    

f0104c36 <printfmt>:
{
f0104c36:	55                   	push   %ebp
f0104c37:	89 e5                	mov    %esp,%ebp
f0104c39:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f0104c3c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0104c3f:	50                   	push   %eax
f0104c40:	ff 75 10             	pushl  0x10(%ebp)
f0104c43:	ff 75 0c             	pushl  0xc(%ebp)
f0104c46:	ff 75 08             	pushl  0x8(%ebp)
f0104c49:	e8 05 00 00 00       	call   f0104c53 <vprintfmt>
}
f0104c4e:	83 c4 10             	add    $0x10,%esp
f0104c51:	c9                   	leave  
f0104c52:	c3                   	ret    

f0104c53 <vprintfmt>:
{
f0104c53:	55                   	push   %ebp
f0104c54:	89 e5                	mov    %esp,%ebp
f0104c56:	57                   	push   %edi
f0104c57:	56                   	push   %esi
f0104c58:	53                   	push   %ebx
f0104c59:	83 ec 3c             	sub    $0x3c,%esp
f0104c5c:	8b 75 08             	mov    0x8(%ebp),%esi
f0104c5f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104c62:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104c65:	eb 0a                	jmp    f0104c71 <vprintfmt+0x1e>
			putch(ch, putdat);
f0104c67:	83 ec 08             	sub    $0x8,%esp
f0104c6a:	53                   	push   %ebx
f0104c6b:	50                   	push   %eax
f0104c6c:	ff d6                	call   *%esi
f0104c6e:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0104c71:	83 c7 01             	add    $0x1,%edi
f0104c74:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0104c78:	83 f8 25             	cmp    $0x25,%eax
f0104c7b:	74 0c                	je     f0104c89 <vprintfmt+0x36>
			if (ch == '\0')
f0104c7d:	85 c0                	test   %eax,%eax
f0104c7f:	75 e6                	jne    f0104c67 <vprintfmt+0x14>
}
f0104c81:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104c84:	5b                   	pop    %ebx
f0104c85:	5e                   	pop    %esi
f0104c86:	5f                   	pop    %edi
f0104c87:	5d                   	pop    %ebp
f0104c88:	c3                   	ret    
		padc = ' ';
f0104c89:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
f0104c8d:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;//精度
f0104c94:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;//总宽度
f0104c9b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f0104ca2:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f0104ca7:	8d 47 01             	lea    0x1(%edi),%eax
f0104caa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104cad:	0f b6 17             	movzbl (%edi),%edx
f0104cb0:	8d 42 dd             	lea    -0x23(%edx),%eax
f0104cb3:	3c 55                	cmp    $0x55,%al
f0104cb5:	0f 87 ba 03 00 00    	ja     f0105075 <vprintfmt+0x422>
f0104cbb:	0f b6 c0             	movzbl %al,%eax
f0104cbe:	ff 24 85 a0 78 10 f0 	jmp    *-0xfef8760(,%eax,4)
f0104cc5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
f0104cc8:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
f0104ccc:	eb d9                	jmp    f0104ca7 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
f0104cce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
f0104cd1:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
f0104cd5:	eb d0                	jmp    f0104ca7 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
f0104cd7:	0f b6 d2             	movzbl %dl,%edx
f0104cda:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {//依次读取数据宽度
f0104cdd:	b8 00 00 00 00       	mov    $0x0,%eax
f0104ce2:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
f0104ce5:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0104ce8:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f0104cec:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f0104cef:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0104cf2:	83 f9 09             	cmp    $0x9,%ecx
f0104cf5:	77 55                	ja     f0104d4c <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {//依次读取数据宽度
f0104cf7:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
f0104cfa:	eb e9                	jmp    f0104ce5 <vprintfmt+0x92>
			precision = va_arg(ap, int);
f0104cfc:	8b 45 14             	mov    0x14(%ebp),%eax
f0104cff:	8b 00                	mov    (%eax),%eax
f0104d01:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104d04:	8b 45 14             	mov    0x14(%ebp),%eax
f0104d07:	8d 40 04             	lea    0x4(%eax),%eax
f0104d0a:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0104d0d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
f0104d10:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0104d14:	79 91                	jns    f0104ca7 <vprintfmt+0x54>
				width = precision, precision = -1;
f0104d16:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0104d19:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104d1c:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
f0104d23:	eb 82                	jmp    f0104ca7 <vprintfmt+0x54>
f0104d25:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104d28:	85 c0                	test   %eax,%eax
f0104d2a:	ba 00 00 00 00       	mov    $0x0,%edx
f0104d2f:	0f 49 d0             	cmovns %eax,%edx
f0104d32:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0104d35:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104d38:	e9 6a ff ff ff       	jmp    f0104ca7 <vprintfmt+0x54>
f0104d3d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
f0104d40:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
f0104d47:	e9 5b ff ff ff       	jmp    f0104ca7 <vprintfmt+0x54>
f0104d4c:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0104d4f:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104d52:	eb bc                	jmp    f0104d10 <vprintfmt+0xbd>
			lflag++;
f0104d54:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f0104d57:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f0104d5a:	e9 48 ff ff ff       	jmp    f0104ca7 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
f0104d5f:	8b 45 14             	mov    0x14(%ebp),%eax
f0104d62:	8d 78 04             	lea    0x4(%eax),%edi
f0104d65:	83 ec 08             	sub    $0x8,%esp
f0104d68:	53                   	push   %ebx
f0104d69:	ff 30                	pushl  (%eax)
f0104d6b:	ff d6                	call   *%esi
			break;
f0104d6d:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f0104d70:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
f0104d73:	e9 9c 02 00 00       	jmp    f0105014 <vprintfmt+0x3c1>
			err = va_arg(ap, int);
f0104d78:	8b 45 14             	mov    0x14(%ebp),%eax
f0104d7b:	8d 78 04             	lea    0x4(%eax),%edi
f0104d7e:	8b 00                	mov    (%eax),%eax
f0104d80:	99                   	cltd   
f0104d81:	31 d0                	xor    %edx,%eax
f0104d83:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0104d85:	83 f8 08             	cmp    $0x8,%eax
f0104d88:	7f 23                	jg     f0104dad <vprintfmt+0x15a>
f0104d8a:	8b 14 85 00 7a 10 f0 	mov    -0xfef8600(,%eax,4),%edx
f0104d91:	85 d2                	test   %edx,%edx
f0104d93:	74 18                	je     f0104dad <vprintfmt+0x15a>
				printfmt(putch, putdat, "%s", p);
f0104d95:	52                   	push   %edx
f0104d96:	68 d0 65 10 f0       	push   $0xf01065d0
f0104d9b:	53                   	push   %ebx
f0104d9c:	56                   	push   %esi
f0104d9d:	e8 94 fe ff ff       	call   f0104c36 <printfmt>
f0104da2:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0104da5:	89 7d 14             	mov    %edi,0x14(%ebp)
f0104da8:	e9 67 02 00 00       	jmp    f0105014 <vprintfmt+0x3c1>
				printfmt(putch, putdat, "error %d", err);
f0104dad:	50                   	push   %eax
f0104dae:	68 ea 77 10 f0       	push   $0xf01077ea
f0104db3:	53                   	push   %ebx
f0104db4:	56                   	push   %esi
f0104db5:	e8 7c fe ff ff       	call   f0104c36 <printfmt>
f0104dba:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0104dbd:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f0104dc0:	e9 4f 02 00 00       	jmp    f0105014 <vprintfmt+0x3c1>
			if ((p = va_arg(ap, char *)) == NULL)
f0104dc5:	8b 45 14             	mov    0x14(%ebp),%eax
f0104dc8:	83 c0 04             	add    $0x4,%eax
f0104dcb:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0104dce:	8b 45 14             	mov    0x14(%ebp),%eax
f0104dd1:	8b 10                	mov    (%eax),%edx
				p = "(null)";
f0104dd3:	85 d2                	test   %edx,%edx
f0104dd5:	b8 e3 77 10 f0       	mov    $0xf01077e3,%eax
f0104dda:	0f 45 c2             	cmovne %edx,%eax
f0104ddd:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
f0104de0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0104de4:	7e 06                	jle    f0104dec <vprintfmt+0x199>
f0104de6:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
f0104dea:	75 0d                	jne    f0104df9 <vprintfmt+0x1a6>
				for (width -= strnlen(p, precision); width > 0; width--)
f0104dec:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0104def:	89 c7                	mov    %eax,%edi
f0104df1:	03 45 e0             	add    -0x20(%ebp),%eax
f0104df4:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104df7:	eb 3f                	jmp    f0104e38 <vprintfmt+0x1e5>
f0104df9:	83 ec 08             	sub    $0x8,%esp
f0104dfc:	ff 75 d8             	pushl  -0x28(%ebp)
f0104dff:	50                   	push   %eax
f0104e00:	e8 ef 03 00 00       	call   f01051f4 <strnlen>
f0104e05:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104e08:	29 c2                	sub    %eax,%edx
f0104e0a:	89 55 c4             	mov    %edx,-0x3c(%ebp)
f0104e0d:	83 c4 10             	add    $0x10,%esp
f0104e10:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
f0104e12:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
f0104e16:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f0104e19:	85 ff                	test   %edi,%edi
f0104e1b:	7e 58                	jle    f0104e75 <vprintfmt+0x222>
					putch(padc, putdat);
f0104e1d:	83 ec 08             	sub    $0x8,%esp
f0104e20:	53                   	push   %ebx
f0104e21:	ff 75 e0             	pushl  -0x20(%ebp)
f0104e24:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f0104e26:	83 ef 01             	sub    $0x1,%edi
f0104e29:	83 c4 10             	add    $0x10,%esp
f0104e2c:	eb eb                	jmp    f0104e19 <vprintfmt+0x1c6>
					putch(ch, putdat);
f0104e2e:	83 ec 08             	sub    $0x8,%esp
f0104e31:	53                   	push   %ebx
f0104e32:	52                   	push   %edx
f0104e33:	ff d6                	call   *%esi
f0104e35:	83 c4 10             	add    $0x10,%esp
f0104e38:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0104e3b:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0104e3d:	83 c7 01             	add    $0x1,%edi
f0104e40:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0104e44:	0f be d0             	movsbl %al,%edx
f0104e47:	85 d2                	test   %edx,%edx
f0104e49:	74 45                	je     f0104e90 <vprintfmt+0x23d>
f0104e4b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0104e4f:	78 06                	js     f0104e57 <vprintfmt+0x204>
f0104e51:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
f0104e55:	78 35                	js     f0104e8c <vprintfmt+0x239>
				if (altflag && (ch < ' ' || ch > '~'))
f0104e57:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0104e5b:	74 d1                	je     f0104e2e <vprintfmt+0x1db>
f0104e5d:	0f be c0             	movsbl %al,%eax
f0104e60:	83 e8 20             	sub    $0x20,%eax
f0104e63:	83 f8 5e             	cmp    $0x5e,%eax
f0104e66:	76 c6                	jbe    f0104e2e <vprintfmt+0x1db>
					putch('?', putdat);
f0104e68:	83 ec 08             	sub    $0x8,%esp
f0104e6b:	53                   	push   %ebx
f0104e6c:	6a 3f                	push   $0x3f
f0104e6e:	ff d6                	call   *%esi
f0104e70:	83 c4 10             	add    $0x10,%esp
f0104e73:	eb c3                	jmp    f0104e38 <vprintfmt+0x1e5>
f0104e75:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0104e78:	85 d2                	test   %edx,%edx
f0104e7a:	b8 00 00 00 00       	mov    $0x0,%eax
f0104e7f:	0f 49 c2             	cmovns %edx,%eax
f0104e82:	29 c2                	sub    %eax,%edx
f0104e84:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0104e87:	e9 60 ff ff ff       	jmp    f0104dec <vprintfmt+0x199>
f0104e8c:	89 cf                	mov    %ecx,%edi
f0104e8e:	eb 02                	jmp    f0104e92 <vprintfmt+0x23f>
f0104e90:	89 cf                	mov    %ecx,%edi
			for (; width > 0; width--)
f0104e92:	85 ff                	test   %edi,%edi
f0104e94:	7e 10                	jle    f0104ea6 <vprintfmt+0x253>
				putch(' ', putdat);
f0104e96:	83 ec 08             	sub    $0x8,%esp
f0104e99:	53                   	push   %ebx
f0104e9a:	6a 20                	push   $0x20
f0104e9c:	ff d6                	call   *%esi
			for (; width > 0; width--)
f0104e9e:	83 ef 01             	sub    $0x1,%edi
f0104ea1:	83 c4 10             	add    $0x10,%esp
f0104ea4:	eb ec                	jmp    f0104e92 <vprintfmt+0x23f>
			if ((p = va_arg(ap, char *)) == NULL)
f0104ea6:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0104ea9:	89 45 14             	mov    %eax,0x14(%ebp)
f0104eac:	e9 63 01 00 00       	jmp    f0105014 <vprintfmt+0x3c1>
	if (lflag >= 2)
f0104eb1:	83 f9 01             	cmp    $0x1,%ecx
f0104eb4:	7f 1b                	jg     f0104ed1 <vprintfmt+0x27e>
	else if (lflag)
f0104eb6:	85 c9                	test   %ecx,%ecx
f0104eb8:	74 63                	je     f0104f1d <vprintfmt+0x2ca>
		return va_arg(*ap, long);
f0104eba:	8b 45 14             	mov    0x14(%ebp),%eax
f0104ebd:	8b 00                	mov    (%eax),%eax
f0104ebf:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104ec2:	99                   	cltd   
f0104ec3:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0104ec6:	8b 45 14             	mov    0x14(%ebp),%eax
f0104ec9:	8d 40 04             	lea    0x4(%eax),%eax
f0104ecc:	89 45 14             	mov    %eax,0x14(%ebp)
f0104ecf:	eb 17                	jmp    f0104ee8 <vprintfmt+0x295>
		return va_arg(*ap, long long);
f0104ed1:	8b 45 14             	mov    0x14(%ebp),%eax
f0104ed4:	8b 50 04             	mov    0x4(%eax),%edx
f0104ed7:	8b 00                	mov    (%eax),%eax
f0104ed9:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104edc:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0104edf:	8b 45 14             	mov    0x14(%ebp),%eax
f0104ee2:	8d 40 08             	lea    0x8(%eax),%eax
f0104ee5:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f0104ee8:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104eeb:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f0104eee:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
f0104ef3:	85 c9                	test   %ecx,%ecx
f0104ef5:	0f 89 ff 00 00 00    	jns    f0104ffa <vprintfmt+0x3a7>
				putch('-', putdat);
f0104efb:	83 ec 08             	sub    $0x8,%esp
f0104efe:	53                   	push   %ebx
f0104eff:	6a 2d                	push   $0x2d
f0104f01:	ff d6                	call   *%esi
				num = -(long long) num;
f0104f03:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104f06:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0104f09:	f7 da                	neg    %edx
f0104f0b:	83 d1 00             	adc    $0x0,%ecx
f0104f0e:	f7 d9                	neg    %ecx
f0104f10:	83 c4 10             	add    $0x10,%esp
			base = 10;
f0104f13:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104f18:	e9 dd 00 00 00       	jmp    f0104ffa <vprintfmt+0x3a7>
		return va_arg(*ap, int);
f0104f1d:	8b 45 14             	mov    0x14(%ebp),%eax
f0104f20:	8b 00                	mov    (%eax),%eax
f0104f22:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104f25:	99                   	cltd   
f0104f26:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0104f29:	8b 45 14             	mov    0x14(%ebp),%eax
f0104f2c:	8d 40 04             	lea    0x4(%eax),%eax
f0104f2f:	89 45 14             	mov    %eax,0x14(%ebp)
f0104f32:	eb b4                	jmp    f0104ee8 <vprintfmt+0x295>
	if (lflag >= 2)
f0104f34:	83 f9 01             	cmp    $0x1,%ecx
f0104f37:	7f 1e                	jg     f0104f57 <vprintfmt+0x304>
	else if (lflag)
f0104f39:	85 c9                	test   %ecx,%ecx
f0104f3b:	74 32                	je     f0104f6f <vprintfmt+0x31c>
		return va_arg(*ap, unsigned long);
f0104f3d:	8b 45 14             	mov    0x14(%ebp),%eax
f0104f40:	8b 10                	mov    (%eax),%edx
f0104f42:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104f47:	8d 40 04             	lea    0x4(%eax),%eax
f0104f4a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0104f4d:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104f52:	e9 a3 00 00 00       	jmp    f0104ffa <vprintfmt+0x3a7>
		return va_arg(*ap, unsigned long long);
f0104f57:	8b 45 14             	mov    0x14(%ebp),%eax
f0104f5a:	8b 10                	mov    (%eax),%edx
f0104f5c:	8b 48 04             	mov    0x4(%eax),%ecx
f0104f5f:	8d 40 08             	lea    0x8(%eax),%eax
f0104f62:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0104f65:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104f6a:	e9 8b 00 00 00       	jmp    f0104ffa <vprintfmt+0x3a7>
		return va_arg(*ap, unsigned int);
f0104f6f:	8b 45 14             	mov    0x14(%ebp),%eax
f0104f72:	8b 10                	mov    (%eax),%edx
f0104f74:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104f79:	8d 40 04             	lea    0x4(%eax),%eax
f0104f7c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0104f7f:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104f84:	eb 74                	jmp    f0104ffa <vprintfmt+0x3a7>
	if (lflag >= 2)
f0104f86:	83 f9 01             	cmp    $0x1,%ecx
f0104f89:	7f 1b                	jg     f0104fa6 <vprintfmt+0x353>
	else if (lflag)
f0104f8b:	85 c9                	test   %ecx,%ecx
f0104f8d:	74 2c                	je     f0104fbb <vprintfmt+0x368>
		return va_arg(*ap, unsigned long);
f0104f8f:	8b 45 14             	mov    0x14(%ebp),%eax
f0104f92:	8b 10                	mov    (%eax),%edx
f0104f94:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104f99:	8d 40 04             	lea    0x4(%eax),%eax
f0104f9c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0104f9f:	b8 08 00 00 00       	mov    $0x8,%eax
f0104fa4:	eb 54                	jmp    f0104ffa <vprintfmt+0x3a7>
		return va_arg(*ap, unsigned long long);
f0104fa6:	8b 45 14             	mov    0x14(%ebp),%eax
f0104fa9:	8b 10                	mov    (%eax),%edx
f0104fab:	8b 48 04             	mov    0x4(%eax),%ecx
f0104fae:	8d 40 08             	lea    0x8(%eax),%eax
f0104fb1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0104fb4:	b8 08 00 00 00       	mov    $0x8,%eax
f0104fb9:	eb 3f                	jmp    f0104ffa <vprintfmt+0x3a7>
		return va_arg(*ap, unsigned int);
f0104fbb:	8b 45 14             	mov    0x14(%ebp),%eax
f0104fbe:	8b 10                	mov    (%eax),%edx
f0104fc0:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104fc5:	8d 40 04             	lea    0x4(%eax),%eax
f0104fc8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0104fcb:	b8 08 00 00 00       	mov    $0x8,%eax
f0104fd0:	eb 28                	jmp    f0104ffa <vprintfmt+0x3a7>
			putch('0', putdat);
f0104fd2:	83 ec 08             	sub    $0x8,%esp
f0104fd5:	53                   	push   %ebx
f0104fd6:	6a 30                	push   $0x30
f0104fd8:	ff d6                	call   *%esi
			putch('x', putdat);
f0104fda:	83 c4 08             	add    $0x8,%esp
f0104fdd:	53                   	push   %ebx
f0104fde:	6a 78                	push   $0x78
f0104fe0:	ff d6                	call   *%esi
			num = (unsigned long long)
f0104fe2:	8b 45 14             	mov    0x14(%ebp),%eax
f0104fe5:	8b 10                	mov    (%eax),%edx
f0104fe7:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f0104fec:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f0104fef:	8d 40 04             	lea    0x4(%eax),%eax
f0104ff2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0104ff5:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
f0104ffa:	83 ec 0c             	sub    $0xc,%esp
f0104ffd:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
f0105001:	57                   	push   %edi
f0105002:	ff 75 e0             	pushl  -0x20(%ebp)
f0105005:	50                   	push   %eax
f0105006:	51                   	push   %ecx
f0105007:	52                   	push   %edx
f0105008:	89 da                	mov    %ebx,%edx
f010500a:	89 f0                	mov    %esi,%eax
f010500c:	e8 5a fb ff ff       	call   f0104b6b <printnum>
			break;
f0105011:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
f0105014:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0105017:	e9 55 fc ff ff       	jmp    f0104c71 <vprintfmt+0x1e>
	if (lflag >= 2)
f010501c:	83 f9 01             	cmp    $0x1,%ecx
f010501f:	7f 1b                	jg     f010503c <vprintfmt+0x3e9>
	else if (lflag)
f0105021:	85 c9                	test   %ecx,%ecx
f0105023:	74 2c                	je     f0105051 <vprintfmt+0x3fe>
		return va_arg(*ap, unsigned long);
f0105025:	8b 45 14             	mov    0x14(%ebp),%eax
f0105028:	8b 10                	mov    (%eax),%edx
f010502a:	b9 00 00 00 00       	mov    $0x0,%ecx
f010502f:	8d 40 04             	lea    0x4(%eax),%eax
f0105032:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0105035:	b8 10 00 00 00       	mov    $0x10,%eax
f010503a:	eb be                	jmp    f0104ffa <vprintfmt+0x3a7>
		return va_arg(*ap, unsigned long long);
f010503c:	8b 45 14             	mov    0x14(%ebp),%eax
f010503f:	8b 10                	mov    (%eax),%edx
f0105041:	8b 48 04             	mov    0x4(%eax),%ecx
f0105044:	8d 40 08             	lea    0x8(%eax),%eax
f0105047:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010504a:	b8 10 00 00 00       	mov    $0x10,%eax
f010504f:	eb a9                	jmp    f0104ffa <vprintfmt+0x3a7>
		return va_arg(*ap, unsigned int);
f0105051:	8b 45 14             	mov    0x14(%ebp),%eax
f0105054:	8b 10                	mov    (%eax),%edx
f0105056:	b9 00 00 00 00       	mov    $0x0,%ecx
f010505b:	8d 40 04             	lea    0x4(%eax),%eax
f010505e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0105061:	b8 10 00 00 00       	mov    $0x10,%eax
f0105066:	eb 92                	jmp    f0104ffa <vprintfmt+0x3a7>
			putch(ch, putdat);
f0105068:	83 ec 08             	sub    $0x8,%esp
f010506b:	53                   	push   %ebx
f010506c:	6a 25                	push   $0x25
f010506e:	ff d6                	call   *%esi
			break;
f0105070:	83 c4 10             	add    $0x10,%esp
f0105073:	eb 9f                	jmp    f0105014 <vprintfmt+0x3c1>
			putch('%', putdat);
f0105075:	83 ec 08             	sub    $0x8,%esp
f0105078:	53                   	push   %ebx
f0105079:	6a 25                	push   $0x25
f010507b:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f010507d:	83 c4 10             	add    $0x10,%esp
f0105080:	89 f8                	mov    %edi,%eax
f0105082:	eb 03                	jmp    f0105087 <vprintfmt+0x434>
f0105084:	83 e8 01             	sub    $0x1,%eax
f0105087:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f010508b:	75 f7                	jne    f0105084 <vprintfmt+0x431>
f010508d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105090:	eb 82                	jmp    f0105014 <vprintfmt+0x3c1>

f0105092 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0105092:	55                   	push   %ebp
f0105093:	89 e5                	mov    %esp,%ebp
f0105095:	83 ec 18             	sub    $0x18,%esp
f0105098:	8b 45 08             	mov    0x8(%ebp),%eax
f010509b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f010509e:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01050a1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01050a5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01050a8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01050af:	85 c0                	test   %eax,%eax
f01050b1:	74 26                	je     f01050d9 <vsnprintf+0x47>
f01050b3:	85 d2                	test   %edx,%edx
f01050b5:	7e 22                	jle    f01050d9 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01050b7:	ff 75 14             	pushl  0x14(%ebp)
f01050ba:	ff 75 10             	pushl  0x10(%ebp)
f01050bd:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01050c0:	50                   	push   %eax
f01050c1:	68 19 4c 10 f0       	push   $0xf0104c19
f01050c6:	e8 88 fb ff ff       	call   f0104c53 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01050cb:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01050ce:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01050d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01050d4:	83 c4 10             	add    $0x10,%esp
}
f01050d7:	c9                   	leave  
f01050d8:	c3                   	ret    
		return -E_INVAL;
f01050d9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01050de:	eb f7                	jmp    f01050d7 <vsnprintf+0x45>

f01050e0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01050e0:	55                   	push   %ebp
f01050e1:	89 e5                	mov    %esp,%ebp
f01050e3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01050e6:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01050e9:	50                   	push   %eax
f01050ea:	ff 75 10             	pushl  0x10(%ebp)
f01050ed:	ff 75 0c             	pushl  0xc(%ebp)
f01050f0:	ff 75 08             	pushl  0x8(%ebp)
f01050f3:	e8 9a ff ff ff       	call   f0105092 <vsnprintf>
	va_end(ap);

	return rc;
}
f01050f8:	c9                   	leave  
f01050f9:	c3                   	ret    

f01050fa <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01050fa:	55                   	push   %ebp
f01050fb:	89 e5                	mov    %esp,%ebp
f01050fd:	57                   	push   %edi
f01050fe:	56                   	push   %esi
f01050ff:	53                   	push   %ebx
f0105100:	83 ec 0c             	sub    $0xc,%esp
f0105103:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0105106:	85 c0                	test   %eax,%eax
f0105108:	74 11                	je     f010511b <readline+0x21>
		cprintf("%s", prompt);
f010510a:	83 ec 08             	sub    $0x8,%esp
f010510d:	50                   	push   %eax
f010510e:	68 d0 65 10 f0       	push   $0xf01065d0
f0105113:	e8 08 e7 ff ff       	call   f0103820 <cprintf>
f0105118:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f010511b:	83 ec 0c             	sub    $0xc,%esp
f010511e:	6a 00                	push   $0x0
f0105120:	e8 aa b6 ff ff       	call   f01007cf <iscons>
f0105125:	89 c7                	mov    %eax,%edi
f0105127:	83 c4 10             	add    $0x10,%esp
	i = 0;
f010512a:	be 00 00 00 00       	mov    $0x0,%esi
f010512f:	eb 4b                	jmp    f010517c <readline+0x82>
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
f0105131:	83 ec 08             	sub    $0x8,%esp
f0105134:	50                   	push   %eax
f0105135:	68 24 7a 10 f0       	push   $0xf0107a24
f010513a:	e8 e1 e6 ff ff       	call   f0103820 <cprintf>
			return NULL;
f010513f:	83 c4 10             	add    $0x10,%esp
f0105142:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f0105147:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010514a:	5b                   	pop    %ebx
f010514b:	5e                   	pop    %esi
f010514c:	5f                   	pop    %edi
f010514d:	5d                   	pop    %ebp
f010514e:	c3                   	ret    
			if (echoing)
f010514f:	85 ff                	test   %edi,%edi
f0105151:	75 05                	jne    f0105158 <readline+0x5e>
			i--;
f0105153:	83 ee 01             	sub    $0x1,%esi
f0105156:	eb 24                	jmp    f010517c <readline+0x82>
				cputchar('\b');
f0105158:	83 ec 0c             	sub    $0xc,%esp
f010515b:	6a 08                	push   $0x8
f010515d:	e8 4c b6 ff ff       	call   f01007ae <cputchar>
f0105162:	83 c4 10             	add    $0x10,%esp
f0105165:	eb ec                	jmp    f0105153 <readline+0x59>
				cputchar(c);
f0105167:	83 ec 0c             	sub    $0xc,%esp
f010516a:	53                   	push   %ebx
f010516b:	e8 3e b6 ff ff       	call   f01007ae <cputchar>
f0105170:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0105173:	88 9e 80 5a 23 f0    	mov    %bl,-0xfdca580(%esi)
f0105179:	8d 76 01             	lea    0x1(%esi),%esi
		c = getchar();
f010517c:	e8 3d b6 ff ff       	call   f01007be <getchar>
f0105181:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0105183:	85 c0                	test   %eax,%eax
f0105185:	78 aa                	js     f0105131 <readline+0x37>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0105187:	83 f8 08             	cmp    $0x8,%eax
f010518a:	0f 94 c2             	sete   %dl
f010518d:	83 f8 7f             	cmp    $0x7f,%eax
f0105190:	0f 94 c0             	sete   %al
f0105193:	08 c2                	or     %al,%dl
f0105195:	74 04                	je     f010519b <readline+0xa1>
f0105197:	85 f6                	test   %esi,%esi
f0105199:	7f b4                	jg     f010514f <readline+0x55>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010519b:	83 fb 1f             	cmp    $0x1f,%ebx
f010519e:	7e 0e                	jle    f01051ae <readline+0xb4>
f01051a0:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f01051a6:	7f 06                	jg     f01051ae <readline+0xb4>
			if (echoing)
f01051a8:	85 ff                	test   %edi,%edi
f01051aa:	74 c7                	je     f0105173 <readline+0x79>
f01051ac:	eb b9                	jmp    f0105167 <readline+0x6d>
		} else if (c == '\n' || c == '\r') {
f01051ae:	83 fb 0a             	cmp    $0xa,%ebx
f01051b1:	74 05                	je     f01051b8 <readline+0xbe>
f01051b3:	83 fb 0d             	cmp    $0xd,%ebx
f01051b6:	75 c4                	jne    f010517c <readline+0x82>
			if (echoing)
f01051b8:	85 ff                	test   %edi,%edi
f01051ba:	75 11                	jne    f01051cd <readline+0xd3>
			buf[i] = 0;
f01051bc:	c6 86 80 5a 23 f0 00 	movb   $0x0,-0xfdca580(%esi)
			return buf;
f01051c3:	b8 80 5a 23 f0       	mov    $0xf0235a80,%eax
f01051c8:	e9 7a ff ff ff       	jmp    f0105147 <readline+0x4d>
				cputchar('\n');
f01051cd:	83 ec 0c             	sub    $0xc,%esp
f01051d0:	6a 0a                	push   $0xa
f01051d2:	e8 d7 b5 ff ff       	call   f01007ae <cputchar>
f01051d7:	83 c4 10             	add    $0x10,%esp
f01051da:	eb e0                	jmp    f01051bc <readline+0xc2>

f01051dc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01051dc:	55                   	push   %ebp
f01051dd:	89 e5                	mov    %esp,%ebp
f01051df:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01051e2:	b8 00 00 00 00       	mov    $0x0,%eax
f01051e7:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01051eb:	74 05                	je     f01051f2 <strlen+0x16>
		n++;
f01051ed:	83 c0 01             	add    $0x1,%eax
f01051f0:	eb f5                	jmp    f01051e7 <strlen+0xb>
	return n;
}
f01051f2:	5d                   	pop    %ebp
f01051f3:	c3                   	ret    

f01051f4 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01051f4:	55                   	push   %ebp
f01051f5:	89 e5                	mov    %esp,%ebp
f01051f7:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01051fa:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01051fd:	ba 00 00 00 00       	mov    $0x0,%edx
f0105202:	39 c2                	cmp    %eax,%edx
f0105204:	74 0d                	je     f0105213 <strnlen+0x1f>
f0105206:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f010520a:	74 05                	je     f0105211 <strnlen+0x1d>
		n++;
f010520c:	83 c2 01             	add    $0x1,%edx
f010520f:	eb f1                	jmp    f0105202 <strnlen+0xe>
f0105211:	89 d0                	mov    %edx,%eax
	return n;
}
f0105213:	5d                   	pop    %ebp
f0105214:	c3                   	ret    

f0105215 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0105215:	55                   	push   %ebp
f0105216:	89 e5                	mov    %esp,%ebp
f0105218:	53                   	push   %ebx
f0105219:	8b 45 08             	mov    0x8(%ebp),%eax
f010521c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f010521f:	ba 00 00 00 00       	mov    $0x0,%edx
f0105224:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f0105228:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f010522b:	83 c2 01             	add    $0x1,%edx
f010522e:	84 c9                	test   %cl,%cl
f0105230:	75 f2                	jne    f0105224 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0105232:	5b                   	pop    %ebx
f0105233:	5d                   	pop    %ebp
f0105234:	c3                   	ret    

f0105235 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0105235:	55                   	push   %ebp
f0105236:	89 e5                	mov    %esp,%ebp
f0105238:	53                   	push   %ebx
f0105239:	83 ec 10             	sub    $0x10,%esp
f010523c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f010523f:	53                   	push   %ebx
f0105240:	e8 97 ff ff ff       	call   f01051dc <strlen>
f0105245:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
f0105248:	ff 75 0c             	pushl  0xc(%ebp)
f010524b:	01 d8                	add    %ebx,%eax
f010524d:	50                   	push   %eax
f010524e:	e8 c2 ff ff ff       	call   f0105215 <strcpy>
	return dst;
}
f0105253:	89 d8                	mov    %ebx,%eax
f0105255:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0105258:	c9                   	leave  
f0105259:	c3                   	ret    

f010525a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f010525a:	55                   	push   %ebp
f010525b:	89 e5                	mov    %esp,%ebp
f010525d:	56                   	push   %esi
f010525e:	53                   	push   %ebx
f010525f:	8b 45 08             	mov    0x8(%ebp),%eax
f0105262:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105265:	89 c6                	mov    %eax,%esi
f0105267:	03 75 10             	add    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010526a:	89 c2                	mov    %eax,%edx
f010526c:	39 f2                	cmp    %esi,%edx
f010526e:	74 11                	je     f0105281 <strncpy+0x27>
		*dst++ = *src;
f0105270:	83 c2 01             	add    $0x1,%edx
f0105273:	0f b6 19             	movzbl (%ecx),%ebx
f0105276:	88 5a ff             	mov    %bl,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0105279:	80 fb 01             	cmp    $0x1,%bl
f010527c:	83 d9 ff             	sbb    $0xffffffff,%ecx
f010527f:	eb eb                	jmp    f010526c <strncpy+0x12>
	}
	return ret;
}
f0105281:	5b                   	pop    %ebx
f0105282:	5e                   	pop    %esi
f0105283:	5d                   	pop    %ebp
f0105284:	c3                   	ret    

f0105285 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0105285:	55                   	push   %ebp
f0105286:	89 e5                	mov    %esp,%ebp
f0105288:	56                   	push   %esi
f0105289:	53                   	push   %ebx
f010528a:	8b 75 08             	mov    0x8(%ebp),%esi
f010528d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105290:	8b 55 10             	mov    0x10(%ebp),%edx
f0105293:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105295:	85 d2                	test   %edx,%edx
f0105297:	74 21                	je     f01052ba <strlcpy+0x35>
f0105299:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f010529d:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
f010529f:	39 c2                	cmp    %eax,%edx
f01052a1:	74 14                	je     f01052b7 <strlcpy+0x32>
f01052a3:	0f b6 19             	movzbl (%ecx),%ebx
f01052a6:	84 db                	test   %bl,%bl
f01052a8:	74 0b                	je     f01052b5 <strlcpy+0x30>
			*dst++ = *src++;
f01052aa:	83 c1 01             	add    $0x1,%ecx
f01052ad:	83 c2 01             	add    $0x1,%edx
f01052b0:	88 5a ff             	mov    %bl,-0x1(%edx)
f01052b3:	eb ea                	jmp    f010529f <strlcpy+0x1a>
f01052b5:	89 d0                	mov    %edx,%eax
		*dst = '\0';
f01052b7:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f01052ba:	29 f0                	sub    %esi,%eax
}
f01052bc:	5b                   	pop    %ebx
f01052bd:	5e                   	pop    %esi
f01052be:	5d                   	pop    %ebp
f01052bf:	c3                   	ret    

f01052c0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01052c0:	55                   	push   %ebp
f01052c1:	89 e5                	mov    %esp,%ebp
f01052c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01052c6:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01052c9:	0f b6 01             	movzbl (%ecx),%eax
f01052cc:	84 c0                	test   %al,%al
f01052ce:	74 0c                	je     f01052dc <strcmp+0x1c>
f01052d0:	3a 02                	cmp    (%edx),%al
f01052d2:	75 08                	jne    f01052dc <strcmp+0x1c>
		p++, q++;
f01052d4:	83 c1 01             	add    $0x1,%ecx
f01052d7:	83 c2 01             	add    $0x1,%edx
f01052da:	eb ed                	jmp    f01052c9 <strcmp+0x9>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01052dc:	0f b6 c0             	movzbl %al,%eax
f01052df:	0f b6 12             	movzbl (%edx),%edx
f01052e2:	29 d0                	sub    %edx,%eax
}
f01052e4:	5d                   	pop    %ebp
f01052e5:	c3                   	ret    

f01052e6 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01052e6:	55                   	push   %ebp
f01052e7:	89 e5                	mov    %esp,%ebp
f01052e9:	53                   	push   %ebx
f01052ea:	8b 45 08             	mov    0x8(%ebp),%eax
f01052ed:	8b 55 0c             	mov    0xc(%ebp),%edx
f01052f0:	89 c3                	mov    %eax,%ebx
f01052f2:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f01052f5:	eb 06                	jmp    f01052fd <strncmp+0x17>
		n--, p++, q++;
f01052f7:	83 c0 01             	add    $0x1,%eax
f01052fa:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f01052fd:	39 d8                	cmp    %ebx,%eax
f01052ff:	74 16                	je     f0105317 <strncmp+0x31>
f0105301:	0f b6 08             	movzbl (%eax),%ecx
f0105304:	84 c9                	test   %cl,%cl
f0105306:	74 04                	je     f010530c <strncmp+0x26>
f0105308:	3a 0a                	cmp    (%edx),%cl
f010530a:	74 eb                	je     f01052f7 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f010530c:	0f b6 00             	movzbl (%eax),%eax
f010530f:	0f b6 12             	movzbl (%edx),%edx
f0105312:	29 d0                	sub    %edx,%eax
}
f0105314:	5b                   	pop    %ebx
f0105315:	5d                   	pop    %ebp
f0105316:	c3                   	ret    
		return 0;
f0105317:	b8 00 00 00 00       	mov    $0x0,%eax
f010531c:	eb f6                	jmp    f0105314 <strncmp+0x2e>

f010531e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010531e:	55                   	push   %ebp
f010531f:	89 e5                	mov    %esp,%ebp
f0105321:	8b 45 08             	mov    0x8(%ebp),%eax
f0105324:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105328:	0f b6 10             	movzbl (%eax),%edx
f010532b:	84 d2                	test   %dl,%dl
f010532d:	74 09                	je     f0105338 <strchr+0x1a>
		if (*s == c)
f010532f:	38 ca                	cmp    %cl,%dl
f0105331:	74 0a                	je     f010533d <strchr+0x1f>
	for (; *s; s++)
f0105333:	83 c0 01             	add    $0x1,%eax
f0105336:	eb f0                	jmp    f0105328 <strchr+0xa>
			return (char *) s;
	return 0;
f0105338:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010533d:	5d                   	pop    %ebp
f010533e:	c3                   	ret    

f010533f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010533f:	55                   	push   %ebp
f0105340:	89 e5                	mov    %esp,%ebp
f0105342:	8b 45 08             	mov    0x8(%ebp),%eax
f0105345:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105349:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f010534c:	38 ca                	cmp    %cl,%dl
f010534e:	74 09                	je     f0105359 <strfind+0x1a>
f0105350:	84 d2                	test   %dl,%dl
f0105352:	74 05                	je     f0105359 <strfind+0x1a>
	for (; *s; s++)
f0105354:	83 c0 01             	add    $0x1,%eax
f0105357:	eb f0                	jmp    f0105349 <strfind+0xa>
			break;
	return (char *) s;
}
f0105359:	5d                   	pop    %ebp
f010535a:	c3                   	ret    

f010535b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f010535b:	55                   	push   %ebp
f010535c:	89 e5                	mov    %esp,%ebp
f010535e:	57                   	push   %edi
f010535f:	56                   	push   %esi
f0105360:	53                   	push   %ebx
f0105361:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105364:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0105367:	85 c9                	test   %ecx,%ecx
f0105369:	74 31                	je     f010539c <memset+0x41>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f010536b:	89 f8                	mov    %edi,%eax
f010536d:	09 c8                	or     %ecx,%eax
f010536f:	a8 03                	test   $0x3,%al
f0105371:	75 23                	jne    f0105396 <memset+0x3b>
		c &= 0xFF;
f0105373:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0105377:	89 d3                	mov    %edx,%ebx
f0105379:	c1 e3 08             	shl    $0x8,%ebx
f010537c:	89 d0                	mov    %edx,%eax
f010537e:	c1 e0 18             	shl    $0x18,%eax
f0105381:	89 d6                	mov    %edx,%esi
f0105383:	c1 e6 10             	shl    $0x10,%esi
f0105386:	09 f0                	or     %esi,%eax
f0105388:	09 c2                	or     %eax,%edx
f010538a:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f010538c:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f010538f:	89 d0                	mov    %edx,%eax
f0105391:	fc                   	cld    
f0105392:	f3 ab                	rep stos %eax,%es:(%edi)
f0105394:	eb 06                	jmp    f010539c <memset+0x41>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0105396:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105399:	fc                   	cld    
f010539a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010539c:	89 f8                	mov    %edi,%eax
f010539e:	5b                   	pop    %ebx
f010539f:	5e                   	pop    %esi
f01053a0:	5f                   	pop    %edi
f01053a1:	5d                   	pop    %ebp
f01053a2:	c3                   	ret    

f01053a3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01053a3:	55                   	push   %ebp
f01053a4:	89 e5                	mov    %esp,%ebp
f01053a6:	57                   	push   %edi
f01053a7:	56                   	push   %esi
f01053a8:	8b 45 08             	mov    0x8(%ebp),%eax
f01053ab:	8b 75 0c             	mov    0xc(%ebp),%esi
f01053ae:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01053b1:	39 c6                	cmp    %eax,%esi
f01053b3:	73 32                	jae    f01053e7 <memmove+0x44>
f01053b5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01053b8:	39 c2                	cmp    %eax,%edx
f01053ba:	76 2b                	jbe    f01053e7 <memmove+0x44>
		s += n;
		d += n;
f01053bc:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01053bf:	89 fe                	mov    %edi,%esi
f01053c1:	09 ce                	or     %ecx,%esi
f01053c3:	09 d6                	or     %edx,%esi
f01053c5:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01053cb:	75 0e                	jne    f01053db <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f01053cd:	83 ef 04             	sub    $0x4,%edi
f01053d0:	8d 72 fc             	lea    -0x4(%edx),%esi
f01053d3:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f01053d6:	fd                   	std    
f01053d7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01053d9:	eb 09                	jmp    f01053e4 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f01053db:	83 ef 01             	sub    $0x1,%edi
f01053de:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f01053e1:	fd                   	std    
f01053e2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01053e4:	fc                   	cld    
f01053e5:	eb 1a                	jmp    f0105401 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01053e7:	89 c2                	mov    %eax,%edx
f01053e9:	09 ca                	or     %ecx,%edx
f01053eb:	09 f2                	or     %esi,%edx
f01053ed:	f6 c2 03             	test   $0x3,%dl
f01053f0:	75 0a                	jne    f01053fc <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f01053f2:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f01053f5:	89 c7                	mov    %eax,%edi
f01053f7:	fc                   	cld    
f01053f8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01053fa:	eb 05                	jmp    f0105401 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
f01053fc:	89 c7                	mov    %eax,%edi
f01053fe:	fc                   	cld    
f01053ff:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0105401:	5e                   	pop    %esi
f0105402:	5f                   	pop    %edi
f0105403:	5d                   	pop    %ebp
f0105404:	c3                   	ret    

f0105405 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0105405:	55                   	push   %ebp
f0105406:	89 e5                	mov    %esp,%ebp
f0105408:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f010540b:	ff 75 10             	pushl  0x10(%ebp)
f010540e:	ff 75 0c             	pushl  0xc(%ebp)
f0105411:	ff 75 08             	pushl  0x8(%ebp)
f0105414:	e8 8a ff ff ff       	call   f01053a3 <memmove>
}
f0105419:	c9                   	leave  
f010541a:	c3                   	ret    

f010541b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f010541b:	55                   	push   %ebp
f010541c:	89 e5                	mov    %esp,%ebp
f010541e:	56                   	push   %esi
f010541f:	53                   	push   %ebx
f0105420:	8b 45 08             	mov    0x8(%ebp),%eax
f0105423:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105426:	89 c6                	mov    %eax,%esi
f0105428:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010542b:	39 f0                	cmp    %esi,%eax
f010542d:	74 1c                	je     f010544b <memcmp+0x30>
		if (*s1 != *s2)
f010542f:	0f b6 08             	movzbl (%eax),%ecx
f0105432:	0f b6 1a             	movzbl (%edx),%ebx
f0105435:	38 d9                	cmp    %bl,%cl
f0105437:	75 08                	jne    f0105441 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f0105439:	83 c0 01             	add    $0x1,%eax
f010543c:	83 c2 01             	add    $0x1,%edx
f010543f:	eb ea                	jmp    f010542b <memcmp+0x10>
			return (int) *s1 - (int) *s2;
f0105441:	0f b6 c1             	movzbl %cl,%eax
f0105444:	0f b6 db             	movzbl %bl,%ebx
f0105447:	29 d8                	sub    %ebx,%eax
f0105449:	eb 05                	jmp    f0105450 <memcmp+0x35>
	}

	return 0;
f010544b:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105450:	5b                   	pop    %ebx
f0105451:	5e                   	pop    %esi
f0105452:	5d                   	pop    %ebp
f0105453:	c3                   	ret    

f0105454 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0105454:	55                   	push   %ebp
f0105455:	89 e5                	mov    %esp,%ebp
f0105457:	8b 45 08             	mov    0x8(%ebp),%eax
f010545a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f010545d:	89 c2                	mov    %eax,%edx
f010545f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0105462:	39 d0                	cmp    %edx,%eax
f0105464:	73 09                	jae    f010546f <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
f0105466:	38 08                	cmp    %cl,(%eax)
f0105468:	74 05                	je     f010546f <memfind+0x1b>
	for (; s < ends; s++)
f010546a:	83 c0 01             	add    $0x1,%eax
f010546d:	eb f3                	jmp    f0105462 <memfind+0xe>
			break;
	return (void *) s;
}
f010546f:	5d                   	pop    %ebp
f0105470:	c3                   	ret    

f0105471 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0105471:	55                   	push   %ebp
f0105472:	89 e5                	mov    %esp,%ebp
f0105474:	57                   	push   %edi
f0105475:	56                   	push   %esi
f0105476:	53                   	push   %ebx
f0105477:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010547a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010547d:	eb 03                	jmp    f0105482 <strtol+0x11>
		s++;
f010547f:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
f0105482:	0f b6 01             	movzbl (%ecx),%eax
f0105485:	3c 20                	cmp    $0x20,%al
f0105487:	74 f6                	je     f010547f <strtol+0xe>
f0105489:	3c 09                	cmp    $0x9,%al
f010548b:	74 f2                	je     f010547f <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f010548d:	3c 2b                	cmp    $0x2b,%al
f010548f:	74 2a                	je     f01054bb <strtol+0x4a>
	int neg = 0;
f0105491:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f0105496:	3c 2d                	cmp    $0x2d,%al
f0105498:	74 2b                	je     f01054c5 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010549a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f01054a0:	75 0f                	jne    f01054b1 <strtol+0x40>
f01054a2:	80 39 30             	cmpb   $0x30,(%ecx)
f01054a5:	74 28                	je     f01054cf <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01054a7:	85 db                	test   %ebx,%ebx
f01054a9:	b8 0a 00 00 00       	mov    $0xa,%eax
f01054ae:	0f 44 d8             	cmove  %eax,%ebx
f01054b1:	b8 00 00 00 00       	mov    $0x0,%eax
f01054b6:	89 5d 10             	mov    %ebx,0x10(%ebp)
f01054b9:	eb 50                	jmp    f010550b <strtol+0x9a>
		s++;
f01054bb:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
f01054be:	bf 00 00 00 00       	mov    $0x0,%edi
f01054c3:	eb d5                	jmp    f010549a <strtol+0x29>
		s++, neg = 1;
f01054c5:	83 c1 01             	add    $0x1,%ecx
f01054c8:	bf 01 00 00 00       	mov    $0x1,%edi
f01054cd:	eb cb                	jmp    f010549a <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01054cf:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f01054d3:	74 0e                	je     f01054e3 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
f01054d5:	85 db                	test   %ebx,%ebx
f01054d7:	75 d8                	jne    f01054b1 <strtol+0x40>
		s++, base = 8;
f01054d9:	83 c1 01             	add    $0x1,%ecx
f01054dc:	bb 08 00 00 00       	mov    $0x8,%ebx
f01054e1:	eb ce                	jmp    f01054b1 <strtol+0x40>
		s += 2, base = 16;
f01054e3:	83 c1 02             	add    $0x2,%ecx
f01054e6:	bb 10 00 00 00       	mov    $0x10,%ebx
f01054eb:	eb c4                	jmp    f01054b1 <strtol+0x40>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
f01054ed:	8d 72 9f             	lea    -0x61(%edx),%esi
f01054f0:	89 f3                	mov    %esi,%ebx
f01054f2:	80 fb 19             	cmp    $0x19,%bl
f01054f5:	77 29                	ja     f0105520 <strtol+0xaf>
			dig = *s - 'a' + 10;
f01054f7:	0f be d2             	movsbl %dl,%edx
f01054fa:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f01054fd:	3b 55 10             	cmp    0x10(%ebp),%edx
f0105500:	7d 30                	jge    f0105532 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
f0105502:	83 c1 01             	add    $0x1,%ecx
f0105505:	0f af 45 10          	imul   0x10(%ebp),%eax
f0105509:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f010550b:	0f b6 11             	movzbl (%ecx),%edx
f010550e:	8d 72 d0             	lea    -0x30(%edx),%esi
f0105511:	89 f3                	mov    %esi,%ebx
f0105513:	80 fb 09             	cmp    $0x9,%bl
f0105516:	77 d5                	ja     f01054ed <strtol+0x7c>
			dig = *s - '0';
f0105518:	0f be d2             	movsbl %dl,%edx
f010551b:	83 ea 30             	sub    $0x30,%edx
f010551e:	eb dd                	jmp    f01054fd <strtol+0x8c>
		else if (*s >= 'A' && *s <= 'Z')
f0105520:	8d 72 bf             	lea    -0x41(%edx),%esi
f0105523:	89 f3                	mov    %esi,%ebx
f0105525:	80 fb 19             	cmp    $0x19,%bl
f0105528:	77 08                	ja     f0105532 <strtol+0xc1>
			dig = *s - 'A' + 10;
f010552a:	0f be d2             	movsbl %dl,%edx
f010552d:	83 ea 37             	sub    $0x37,%edx
f0105530:	eb cb                	jmp    f01054fd <strtol+0x8c>
		// we don't properly detect overflow!
	}

	if (endptr)
f0105532:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0105536:	74 05                	je     f010553d <strtol+0xcc>
		*endptr = (char *) s;
f0105538:	8b 75 0c             	mov    0xc(%ebp),%esi
f010553b:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f010553d:	89 c2                	mov    %eax,%edx
f010553f:	f7 da                	neg    %edx
f0105541:	85 ff                	test   %edi,%edi
f0105543:	0f 45 c2             	cmovne %edx,%eax
}
f0105546:	5b                   	pop    %ebx
f0105547:	5e                   	pop    %esi
f0105548:	5f                   	pop    %edi
f0105549:	5d                   	pop    %ebp
f010554a:	c3                   	ret    
f010554b:	90                   	nop

f010554c <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f010554c:	fa                   	cli    

	xorw    %ax, %ax
f010554d:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f010554f:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105551:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105553:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0105555:	0f 01 16             	lgdtl  (%esi)
f0105558:	74 70                	je     f01055ca <mpsearch1+0x3>
	movl    %cr0, %eax
f010555a:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f010555d:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0105561:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0105564:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f010556a:	08 00                	or     %al,(%eax)

f010556c <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f010556c:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0105570:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105572:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105574:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0105576:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f010557a:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f010557c:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f010557e:	b8 00 00 12 00       	mov    $0x120000,%eax
	movl    %eax, %cr3
f0105583:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0105586:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0105589:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f010558e:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0105591:	8b 25 84 5e 23 f0    	mov    0xf0235e84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0105597:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f010559c:	b8 01 02 10 f0       	mov    $0xf0100201,%eax
	call    *%eax
f01055a1:	ff d0                	call   *%eax

f01055a3 <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f01055a3:	eb fe                	jmp    f01055a3 <spin>
f01055a5:	8d 76 00             	lea    0x0(%esi),%esi

f01055a8 <gdt>:
	...
f01055b0:	ff                   	(bad)  
f01055b1:	ff 00                	incl   (%eax)
f01055b3:	00 00                	add    %al,(%eax)
f01055b5:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f01055bc:	00                   	.byte 0x0
f01055bd:	92                   	xchg   %eax,%edx
f01055be:	cf                   	iret   
	...

f01055c0 <gdtdesc>:
f01055c0:	17                   	pop    %ss
f01055c1:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f01055c6 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f01055c6:	90                   	nop

f01055c7 <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f01055c7:	55                   	push   %ebp
f01055c8:	89 e5                	mov    %esp,%ebp
f01055ca:	57                   	push   %edi
f01055cb:	56                   	push   %esi
f01055cc:	53                   	push   %ebx
f01055cd:	83 ec 0c             	sub    $0xc,%esp
	if (PGNUM(pa) >= npages)
f01055d0:	8b 0d 88 5e 23 f0    	mov    0xf0235e88,%ecx
f01055d6:	89 c3                	mov    %eax,%ebx
f01055d8:	c1 eb 0c             	shr    $0xc,%ebx
f01055db:	39 cb                	cmp    %ecx,%ebx
f01055dd:	73 1a                	jae    f01055f9 <mpsearch1+0x32>
	return (void *)(pa + KERNBASE);
f01055df:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f01055e5:	8d 3c 02             	lea    (%edx,%eax,1),%edi
	if (PGNUM(pa) >= npages)
f01055e8:	89 f8                	mov    %edi,%eax
f01055ea:	c1 e8 0c             	shr    $0xc,%eax
f01055ed:	39 c8                	cmp    %ecx,%eax
f01055ef:	73 1a                	jae    f010560b <mpsearch1+0x44>
	return (void *)(pa + KERNBASE);
f01055f1:	81 ef 00 00 00 10    	sub    $0x10000000,%edi

	for (; mp < end; mp++)
f01055f7:	eb 27                	jmp    f0105620 <mpsearch1+0x59>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01055f9:	50                   	push   %eax
f01055fa:	68 54 60 10 f0       	push   $0xf0106054
f01055ff:	6a 57                	push   $0x57
f0105601:	68 c1 7b 10 f0       	push   $0xf0107bc1
f0105606:	e8 89 aa ff ff       	call   f0100094 <_panic>
f010560b:	57                   	push   %edi
f010560c:	68 54 60 10 f0       	push   $0xf0106054
f0105611:	6a 57                	push   $0x57
f0105613:	68 c1 7b 10 f0       	push   $0xf0107bc1
f0105618:	e8 77 aa ff ff       	call   f0100094 <_panic>
f010561d:	83 c3 10             	add    $0x10,%ebx
f0105620:	39 fb                	cmp    %edi,%ebx
f0105622:	73 30                	jae    f0105654 <mpsearch1+0x8d>
f0105624:	89 de                	mov    %ebx,%esi
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105626:	83 ec 04             	sub    $0x4,%esp
f0105629:	6a 04                	push   $0x4
f010562b:	68 d1 7b 10 f0       	push   $0xf0107bd1
f0105630:	53                   	push   %ebx
f0105631:	e8 e5 fd ff ff       	call   f010541b <memcmp>
f0105636:	83 c4 10             	add    $0x10,%esp
f0105639:	85 c0                	test   %eax,%eax
f010563b:	75 e0                	jne    f010561d <mpsearch1+0x56>
f010563d:	89 da                	mov    %ebx,%edx
	for (i = 0; i < len; i++)
f010563f:	83 c6 10             	add    $0x10,%esi
		sum += ((uint8_t *)addr)[i];
f0105642:	0f b6 0a             	movzbl (%edx),%ecx
f0105645:	01 c8                	add    %ecx,%eax
f0105647:	83 c2 01             	add    $0x1,%edx
	for (i = 0; i < len; i++)
f010564a:	39 f2                	cmp    %esi,%edx
f010564c:	75 f4                	jne    f0105642 <mpsearch1+0x7b>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f010564e:	84 c0                	test   %al,%al
f0105650:	75 cb                	jne    f010561d <mpsearch1+0x56>
f0105652:	eb 05                	jmp    f0105659 <mpsearch1+0x92>
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f0105654:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f0105659:	89 d8                	mov    %ebx,%eax
f010565b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010565e:	5b                   	pop    %ebx
f010565f:	5e                   	pop    %esi
f0105660:	5f                   	pop    %edi
f0105661:	5d                   	pop    %ebp
f0105662:	c3                   	ret    

f0105663 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f0105663:	55                   	push   %ebp
f0105664:	89 e5                	mov    %esp,%ebp
f0105666:	57                   	push   %edi
f0105667:	56                   	push   %esi
f0105668:	53                   	push   %ebx
f0105669:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f010566c:	c7 05 c0 63 23 f0 20 	movl   $0xf0236020,0xf02363c0
f0105673:	60 23 f0 
	if (PGNUM(pa) >= npages)
f0105676:	83 3d 88 5e 23 f0 00 	cmpl   $0x0,0xf0235e88
f010567d:	0f 84 a3 00 00 00    	je     f0105726 <mp_init+0xc3>
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0105683:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f010568a:	85 c0                	test   %eax,%eax
f010568c:	0f 84 aa 00 00 00    	je     f010573c <mp_init+0xd9>
		p <<= 4;	// Translate from segment to PA
f0105692:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f0105695:	ba 00 04 00 00       	mov    $0x400,%edx
f010569a:	e8 28 ff ff ff       	call   f01055c7 <mpsearch1>
f010569f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01056a2:	85 c0                	test   %eax,%eax
f01056a4:	75 1a                	jne    f01056c0 <mp_init+0x5d>
	return mpsearch1(0xF0000, 0x10000);
f01056a6:	ba 00 00 01 00       	mov    $0x10000,%edx
f01056ab:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f01056b0:	e8 12 ff ff ff       	call   f01055c7 <mpsearch1>
f01056b5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if ((mp = mpsearch()) == 0)
f01056b8:	85 c0                	test   %eax,%eax
f01056ba:	0f 84 31 02 00 00    	je     f01058f1 <mp_init+0x28e>
	if (mp->physaddr == 0 || mp->type != 0) {
f01056c0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01056c3:	8b 58 04             	mov    0x4(%eax),%ebx
f01056c6:	85 db                	test   %ebx,%ebx
f01056c8:	0f 84 97 00 00 00    	je     f0105765 <mp_init+0x102>
f01056ce:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f01056d2:	0f 85 8d 00 00 00    	jne    f0105765 <mp_init+0x102>
f01056d8:	89 d8                	mov    %ebx,%eax
f01056da:	c1 e8 0c             	shr    $0xc,%eax
f01056dd:	3b 05 88 5e 23 f0    	cmp    0xf0235e88,%eax
f01056e3:	0f 83 91 00 00 00    	jae    f010577a <mp_init+0x117>
	return (void *)(pa + KERNBASE);
f01056e9:	81 eb 00 00 00 10    	sub    $0x10000000,%ebx
f01056ef:	89 de                	mov    %ebx,%esi
	if (memcmp(conf, "PCMP", 4) != 0) {
f01056f1:	83 ec 04             	sub    $0x4,%esp
f01056f4:	6a 04                	push   $0x4
f01056f6:	68 d6 7b 10 f0       	push   $0xf0107bd6
f01056fb:	53                   	push   %ebx
f01056fc:	e8 1a fd ff ff       	call   f010541b <memcmp>
f0105701:	83 c4 10             	add    $0x10,%esp
f0105704:	85 c0                	test   %eax,%eax
f0105706:	0f 85 83 00 00 00    	jne    f010578f <mp_init+0x12c>
f010570c:	0f b7 7b 04          	movzwl 0x4(%ebx),%edi
f0105710:	01 df                	add    %ebx,%edi
	sum = 0;
f0105712:	89 c2                	mov    %eax,%edx
	for (i = 0; i < len; i++)
f0105714:	39 fb                	cmp    %edi,%ebx
f0105716:	0f 84 88 00 00 00    	je     f01057a4 <mp_init+0x141>
		sum += ((uint8_t *)addr)[i];
f010571c:	0f b6 0b             	movzbl (%ebx),%ecx
f010571f:	01 ca                	add    %ecx,%edx
f0105721:	83 c3 01             	add    $0x1,%ebx
f0105724:	eb ee                	jmp    f0105714 <mp_init+0xb1>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105726:	68 00 04 00 00       	push   $0x400
f010572b:	68 54 60 10 f0       	push   $0xf0106054
f0105730:	6a 6f                	push   $0x6f
f0105732:	68 c1 7b 10 f0       	push   $0xf0107bc1
f0105737:	e8 58 a9 ff ff       	call   f0100094 <_panic>
		p = *(uint16_t *) (bda + 0x13) * 1024;
f010573c:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0105743:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f0105746:	2d 00 04 00 00       	sub    $0x400,%eax
f010574b:	ba 00 04 00 00       	mov    $0x400,%edx
f0105750:	e8 72 fe ff ff       	call   f01055c7 <mpsearch1>
f0105755:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105758:	85 c0                	test   %eax,%eax
f010575a:	0f 85 60 ff ff ff    	jne    f01056c0 <mp_init+0x5d>
f0105760:	e9 41 ff ff ff       	jmp    f01056a6 <mp_init+0x43>
		cprintf("SMP: Default configurations not implemented\n");
f0105765:	83 ec 0c             	sub    $0xc,%esp
f0105768:	68 34 7a 10 f0       	push   $0xf0107a34
f010576d:	e8 ae e0 ff ff       	call   f0103820 <cprintf>
f0105772:	83 c4 10             	add    $0x10,%esp
f0105775:	e9 77 01 00 00       	jmp    f01058f1 <mp_init+0x28e>
f010577a:	53                   	push   %ebx
f010577b:	68 54 60 10 f0       	push   $0xf0106054
f0105780:	68 90 00 00 00       	push   $0x90
f0105785:	68 c1 7b 10 f0       	push   $0xf0107bc1
f010578a:	e8 05 a9 ff ff       	call   f0100094 <_panic>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f010578f:	83 ec 0c             	sub    $0xc,%esp
f0105792:	68 64 7a 10 f0       	push   $0xf0107a64
f0105797:	e8 84 e0 ff ff       	call   f0103820 <cprintf>
f010579c:	83 c4 10             	add    $0x10,%esp
f010579f:	e9 4d 01 00 00       	jmp    f01058f1 <mp_init+0x28e>
	if (sum(conf, conf->length) != 0) {
f01057a4:	84 d2                	test   %dl,%dl
f01057a6:	75 16                	jne    f01057be <mp_init+0x15b>
	if (conf->version != 1 && conf->version != 4) {
f01057a8:	0f b6 56 06          	movzbl 0x6(%esi),%edx
f01057ac:	80 fa 01             	cmp    $0x1,%dl
f01057af:	74 05                	je     f01057b6 <mp_init+0x153>
f01057b1:	80 fa 04             	cmp    $0x4,%dl
f01057b4:	75 1d                	jne    f01057d3 <mp_init+0x170>
f01057b6:	0f b7 4e 28          	movzwl 0x28(%esi),%ecx
f01057ba:	01 d9                	add    %ebx,%ecx
f01057bc:	eb 36                	jmp    f01057f4 <mp_init+0x191>
		cprintf("SMP: Bad MP configuration checksum\n");
f01057be:	83 ec 0c             	sub    $0xc,%esp
f01057c1:	68 98 7a 10 f0       	push   $0xf0107a98
f01057c6:	e8 55 e0 ff ff       	call   f0103820 <cprintf>
f01057cb:	83 c4 10             	add    $0x10,%esp
f01057ce:	e9 1e 01 00 00       	jmp    f01058f1 <mp_init+0x28e>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f01057d3:	83 ec 08             	sub    $0x8,%esp
f01057d6:	0f b6 d2             	movzbl %dl,%edx
f01057d9:	52                   	push   %edx
f01057da:	68 bc 7a 10 f0       	push   $0xf0107abc
f01057df:	e8 3c e0 ff ff       	call   f0103820 <cprintf>
f01057e4:	83 c4 10             	add    $0x10,%esp
f01057e7:	e9 05 01 00 00       	jmp    f01058f1 <mp_init+0x28e>
		sum += ((uint8_t *)addr)[i];
f01057ec:	0f b6 13             	movzbl (%ebx),%edx
f01057ef:	01 d0                	add    %edx,%eax
f01057f1:	83 c3 01             	add    $0x1,%ebx
	for (i = 0; i < len; i++)
f01057f4:	39 d9                	cmp    %ebx,%ecx
f01057f6:	75 f4                	jne    f01057ec <mp_init+0x189>
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f01057f8:	02 46 2a             	add    0x2a(%esi),%al
f01057fb:	75 1c                	jne    f0105819 <mp_init+0x1b6>
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
f01057fd:	c7 05 00 60 23 f0 01 	movl   $0x1,0xf0236000
f0105804:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0105807:	8b 46 24             	mov    0x24(%esi),%eax
f010580a:	a3 00 70 27 f0       	mov    %eax,0xf0277000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f010580f:	8d 7e 2c             	lea    0x2c(%esi),%edi
f0105812:	bb 00 00 00 00       	mov    $0x0,%ebx
f0105817:	eb 4d                	jmp    f0105866 <mp_init+0x203>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0105819:	83 ec 0c             	sub    $0xc,%esp
f010581c:	68 dc 7a 10 f0       	push   $0xf0107adc
f0105821:	e8 fa df ff ff       	call   f0103820 <cprintf>
f0105826:	83 c4 10             	add    $0x10,%esp
f0105829:	e9 c3 00 00 00       	jmp    f01058f1 <mp_init+0x28e>
		switch (*p) {
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f010582e:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f0105832:	74 11                	je     f0105845 <mp_init+0x1e2>
				bootcpu = &cpus[ncpu];
f0105834:	6b 05 c4 63 23 f0 74 	imul   $0x74,0xf02363c4,%eax
f010583b:	05 20 60 23 f0       	add    $0xf0236020,%eax
f0105840:	a3 c0 63 23 f0       	mov    %eax,0xf02363c0
			if (ncpu < NCPU) {
f0105845:	a1 c4 63 23 f0       	mov    0xf02363c4,%eax
f010584a:	83 f8 07             	cmp    $0x7,%eax
f010584d:	7f 2f                	jg     f010587e <mp_init+0x21b>
				cpus[ncpu].cpu_id = ncpu;
f010584f:	6b d0 74             	imul   $0x74,%eax,%edx
f0105852:	88 82 20 60 23 f0    	mov    %al,-0xfdc9fe0(%edx)
				ncpu++;
f0105858:	83 c0 01             	add    $0x1,%eax
f010585b:	a3 c4 63 23 f0       	mov    %eax,0xf02363c4
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0105860:	83 c7 14             	add    $0x14,%edi
	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105863:	83 c3 01             	add    $0x1,%ebx
f0105866:	0f b7 46 22          	movzwl 0x22(%esi),%eax
f010586a:	39 d8                	cmp    %ebx,%eax
f010586c:	76 4b                	jbe    f01058b9 <mp_init+0x256>
		switch (*p) {
f010586e:	0f b6 07             	movzbl (%edi),%eax
f0105871:	84 c0                	test   %al,%al
f0105873:	74 b9                	je     f010582e <mp_init+0x1cb>
f0105875:	3c 04                	cmp    $0x4,%al
f0105877:	77 1c                	ja     f0105895 <mp_init+0x232>
			continue;
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0105879:	83 c7 08             	add    $0x8,%edi
			continue;
f010587c:	eb e5                	jmp    f0105863 <mp_init+0x200>
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f010587e:	83 ec 08             	sub    $0x8,%esp
f0105881:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f0105885:	50                   	push   %eax
f0105886:	68 0c 7b 10 f0       	push   $0xf0107b0c
f010588b:	e8 90 df ff ff       	call   f0103820 <cprintf>
f0105890:	83 c4 10             	add    $0x10,%esp
f0105893:	eb cb                	jmp    f0105860 <mp_init+0x1fd>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0105895:	83 ec 08             	sub    $0x8,%esp
		switch (*p) {
f0105898:	0f b6 c0             	movzbl %al,%eax
			cprintf("mpinit: unknown config type %x\n", *p);
f010589b:	50                   	push   %eax
f010589c:	68 34 7b 10 f0       	push   $0xf0107b34
f01058a1:	e8 7a df ff ff       	call   f0103820 <cprintf>
			ismp = 0;
f01058a6:	c7 05 00 60 23 f0 00 	movl   $0x0,0xf0236000
f01058ad:	00 00 00 
			i = conf->entry;
f01058b0:	0f b7 5e 22          	movzwl 0x22(%esi),%ebx
f01058b4:	83 c4 10             	add    $0x10,%esp
f01058b7:	eb aa                	jmp    f0105863 <mp_init+0x200>
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f01058b9:	a1 c0 63 23 f0       	mov    0xf02363c0,%eax
f01058be:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f01058c5:	83 3d 00 60 23 f0 00 	cmpl   $0x0,0xf0236000
f01058cc:	74 2b                	je     f01058f9 <mp_init+0x296>
		ncpu = 1;
		lapicaddr = 0;
		cprintf("SMP: configuration not found, SMP disabled\n");
		return;
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f01058ce:	83 ec 04             	sub    $0x4,%esp
f01058d1:	ff 35 c4 63 23 f0    	pushl  0xf02363c4
f01058d7:	0f b6 00             	movzbl (%eax),%eax
f01058da:	50                   	push   %eax
f01058db:	68 db 7b 10 f0       	push   $0xf0107bdb
f01058e0:	e8 3b df ff ff       	call   f0103820 <cprintf>

	if (mp->imcrp) {
f01058e5:	83 c4 10             	add    $0x10,%esp
f01058e8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01058eb:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f01058ef:	75 2e                	jne    f010591f <mp_init+0x2bc>
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f01058f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01058f4:	5b                   	pop    %ebx
f01058f5:	5e                   	pop    %esi
f01058f6:	5f                   	pop    %edi
f01058f7:	5d                   	pop    %ebp
f01058f8:	c3                   	ret    
		ncpu = 1;
f01058f9:	c7 05 c4 63 23 f0 01 	movl   $0x1,0xf02363c4
f0105900:	00 00 00 
		lapicaddr = 0;
f0105903:	c7 05 00 70 27 f0 00 	movl   $0x0,0xf0277000
f010590a:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f010590d:	83 ec 0c             	sub    $0xc,%esp
f0105910:	68 54 7b 10 f0       	push   $0xf0107b54
f0105915:	e8 06 df ff ff       	call   f0103820 <cprintf>
		return;
f010591a:	83 c4 10             	add    $0x10,%esp
f010591d:	eb d2                	jmp    f01058f1 <mp_init+0x28e>
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f010591f:	83 ec 0c             	sub    $0xc,%esp
f0105922:	68 80 7b 10 f0       	push   $0xf0107b80
f0105927:	e8 f4 de ff ff       	call   f0103820 <cprintf>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010592c:	b8 70 00 00 00       	mov    $0x70,%eax
f0105931:	ba 22 00 00 00       	mov    $0x22,%edx
f0105936:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0105937:	ba 23 00 00 00       	mov    $0x23,%edx
f010593c:	ec                   	in     (%dx),%al
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f010593d:	83 c8 01             	or     $0x1,%eax
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105940:	ee                   	out    %al,(%dx)
f0105941:	83 c4 10             	add    $0x10,%esp
f0105944:	eb ab                	jmp    f01058f1 <mp_init+0x28e>

f0105946 <lapicw>:
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
	lapic[index] = value;
f0105946:	8b 0d 04 70 27 f0    	mov    0xf0277004,%ecx
f010594c:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f010594f:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0105951:	a1 04 70 27 f0       	mov    0xf0277004,%eax
f0105956:	8b 40 20             	mov    0x20(%eax),%eax
}
f0105959:	c3                   	ret    

f010595a <cpunum>:
}

int
cpunum(void)
{
	if (lapic)
f010595a:	8b 15 04 70 27 f0    	mov    0xf0277004,%edx
		return lapic[ID] >> 24;
	return 0;
f0105960:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lapic)
f0105965:	85 d2                	test   %edx,%edx
f0105967:	74 06                	je     f010596f <cpunum+0x15>
		return lapic[ID] >> 24;
f0105969:	8b 42 20             	mov    0x20(%edx),%eax
f010596c:	c1 e8 18             	shr    $0x18,%eax
}
f010596f:	c3                   	ret    

f0105970 <lapic_init>:
	if (!lapicaddr)
f0105970:	a1 00 70 27 f0       	mov    0xf0277000,%eax
f0105975:	85 c0                	test   %eax,%eax
f0105977:	75 01                	jne    f010597a <lapic_init+0xa>
f0105979:	c3                   	ret    
{
f010597a:	55                   	push   %ebp
f010597b:	89 e5                	mov    %esp,%ebp
f010597d:	83 ec 10             	sub    $0x10,%esp
	lapic = mmio_map_region(lapicaddr, 4096);
f0105980:	68 00 10 00 00       	push   $0x1000
f0105985:	50                   	push   %eax
f0105986:	e8 2d b9 ff ff       	call   f01012b8 <mmio_map_region>
f010598b:	a3 04 70 27 f0       	mov    %eax,0xf0277004
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0105990:	ba 27 01 00 00       	mov    $0x127,%edx
f0105995:	b8 3c 00 00 00       	mov    $0x3c,%eax
f010599a:	e8 a7 ff ff ff       	call   f0105946 <lapicw>
	lapicw(TDCR, X1);
f010599f:	ba 0b 00 00 00       	mov    $0xb,%edx
f01059a4:	b8 f8 00 00 00       	mov    $0xf8,%eax
f01059a9:	e8 98 ff ff ff       	call   f0105946 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f01059ae:	ba 20 00 02 00       	mov    $0x20020,%edx
f01059b3:	b8 c8 00 00 00       	mov    $0xc8,%eax
f01059b8:	e8 89 ff ff ff       	call   f0105946 <lapicw>
	lapicw(TICR, 10000000); 
f01059bd:	ba 80 96 98 00       	mov    $0x989680,%edx
f01059c2:	b8 e0 00 00 00       	mov    $0xe0,%eax
f01059c7:	e8 7a ff ff ff       	call   f0105946 <lapicw>
	if (thiscpu != bootcpu)
f01059cc:	e8 89 ff ff ff       	call   f010595a <cpunum>
f01059d1:	6b c0 74             	imul   $0x74,%eax,%eax
f01059d4:	05 20 60 23 f0       	add    $0xf0236020,%eax
f01059d9:	83 c4 10             	add    $0x10,%esp
f01059dc:	39 05 c0 63 23 f0    	cmp    %eax,0xf02363c0
f01059e2:	74 0f                	je     f01059f3 <lapic_init+0x83>
		lapicw(LINT0, MASKED);
f01059e4:	ba 00 00 01 00       	mov    $0x10000,%edx
f01059e9:	b8 d4 00 00 00       	mov    $0xd4,%eax
f01059ee:	e8 53 ff ff ff       	call   f0105946 <lapicw>
	lapicw(LINT1, MASKED);
f01059f3:	ba 00 00 01 00       	mov    $0x10000,%edx
f01059f8:	b8 d8 00 00 00       	mov    $0xd8,%eax
f01059fd:	e8 44 ff ff ff       	call   f0105946 <lapicw>
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0105a02:	a1 04 70 27 f0       	mov    0xf0277004,%eax
f0105a07:	8b 40 30             	mov    0x30(%eax),%eax
f0105a0a:	c1 e8 10             	shr    $0x10,%eax
f0105a0d:	a8 fc                	test   $0xfc,%al
f0105a0f:	75 7c                	jne    f0105a8d <lapic_init+0x11d>
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0105a11:	ba 33 00 00 00       	mov    $0x33,%edx
f0105a16:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0105a1b:	e8 26 ff ff ff       	call   f0105946 <lapicw>
	lapicw(ESR, 0);
f0105a20:	ba 00 00 00 00       	mov    $0x0,%edx
f0105a25:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105a2a:	e8 17 ff ff ff       	call   f0105946 <lapicw>
	lapicw(ESR, 0);
f0105a2f:	ba 00 00 00 00       	mov    $0x0,%edx
f0105a34:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105a39:	e8 08 ff ff ff       	call   f0105946 <lapicw>
	lapicw(EOI, 0);
f0105a3e:	ba 00 00 00 00       	mov    $0x0,%edx
f0105a43:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105a48:	e8 f9 fe ff ff       	call   f0105946 <lapicw>
	lapicw(ICRHI, 0);
f0105a4d:	ba 00 00 00 00       	mov    $0x0,%edx
f0105a52:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105a57:	e8 ea fe ff ff       	call   f0105946 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0105a5c:	ba 00 85 08 00       	mov    $0x88500,%edx
f0105a61:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105a66:	e8 db fe ff ff       	call   f0105946 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0105a6b:	8b 15 04 70 27 f0    	mov    0xf0277004,%edx
f0105a71:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105a77:	f6 c4 10             	test   $0x10,%ah
f0105a7a:	75 f5                	jne    f0105a71 <lapic_init+0x101>
	lapicw(TPR, 0);
f0105a7c:	ba 00 00 00 00       	mov    $0x0,%edx
f0105a81:	b8 20 00 00 00       	mov    $0x20,%eax
f0105a86:	e8 bb fe ff ff       	call   f0105946 <lapicw>
}
f0105a8b:	c9                   	leave  
f0105a8c:	c3                   	ret    
		lapicw(PCINT, MASKED);
f0105a8d:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105a92:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0105a97:	e8 aa fe ff ff       	call   f0105946 <lapicw>
f0105a9c:	e9 70 ff ff ff       	jmp    f0105a11 <lapic_init+0xa1>

f0105aa1 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f0105aa1:	83 3d 04 70 27 f0 00 	cmpl   $0x0,0xf0277004
f0105aa8:	74 17                	je     f0105ac1 <lapic_eoi+0x20>
{
f0105aaa:	55                   	push   %ebp
f0105aab:	89 e5                	mov    %esp,%ebp
f0105aad:	83 ec 08             	sub    $0x8,%esp
		lapicw(EOI, 0);
f0105ab0:	ba 00 00 00 00       	mov    $0x0,%edx
f0105ab5:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105aba:	e8 87 fe ff ff       	call   f0105946 <lapicw>
}
f0105abf:	c9                   	leave  
f0105ac0:	c3                   	ret    
f0105ac1:	c3                   	ret    

f0105ac2 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0105ac2:	55                   	push   %ebp
f0105ac3:	89 e5                	mov    %esp,%ebp
f0105ac5:	56                   	push   %esi
f0105ac6:	53                   	push   %ebx
f0105ac7:	8b 75 08             	mov    0x8(%ebp),%esi
f0105aca:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105acd:	b8 0f 00 00 00       	mov    $0xf,%eax
f0105ad2:	ba 70 00 00 00       	mov    $0x70,%edx
f0105ad7:	ee                   	out    %al,(%dx)
f0105ad8:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105add:	ba 71 00 00 00       	mov    $0x71,%edx
f0105ae2:	ee                   	out    %al,(%dx)
	if (PGNUM(pa) >= npages)
f0105ae3:	83 3d 88 5e 23 f0 00 	cmpl   $0x0,0xf0235e88
f0105aea:	74 7e                	je     f0105b6a <lapic_startap+0xa8>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0105aec:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0105af3:	00 00 
	wrv[1] = addr >> 4;
f0105af5:	89 d8                	mov    %ebx,%eax
f0105af7:	c1 e8 04             	shr    $0x4,%eax
f0105afa:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0105b00:	c1 e6 18             	shl    $0x18,%esi
f0105b03:	89 f2                	mov    %esi,%edx
f0105b05:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105b0a:	e8 37 fe ff ff       	call   f0105946 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0105b0f:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0105b14:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105b19:	e8 28 fe ff ff       	call   f0105946 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0105b1e:	ba 00 85 00 00       	mov    $0x8500,%edx
f0105b23:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105b28:	e8 19 fe ff ff       	call   f0105946 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105b2d:	c1 eb 0c             	shr    $0xc,%ebx
f0105b30:	80 cf 06             	or     $0x6,%bh
		lapicw(ICRHI, apicid << 24);
f0105b33:	89 f2                	mov    %esi,%edx
f0105b35:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105b3a:	e8 07 fe ff ff       	call   f0105946 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105b3f:	89 da                	mov    %ebx,%edx
f0105b41:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105b46:	e8 fb fd ff ff       	call   f0105946 <lapicw>
		lapicw(ICRHI, apicid << 24);
f0105b4b:	89 f2                	mov    %esi,%edx
f0105b4d:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105b52:	e8 ef fd ff ff       	call   f0105946 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105b57:	89 da                	mov    %ebx,%edx
f0105b59:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105b5e:	e8 e3 fd ff ff       	call   f0105946 <lapicw>
		microdelay(200);
	}
}
f0105b63:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105b66:	5b                   	pop    %ebx
f0105b67:	5e                   	pop    %esi
f0105b68:	5d                   	pop    %ebp
f0105b69:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105b6a:	68 67 04 00 00       	push   $0x467
f0105b6f:	68 54 60 10 f0       	push   $0xf0106054
f0105b74:	68 98 00 00 00       	push   $0x98
f0105b79:	68 f8 7b 10 f0       	push   $0xf0107bf8
f0105b7e:	e8 11 a5 ff ff       	call   f0100094 <_panic>

f0105b83 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0105b83:	55                   	push   %ebp
f0105b84:	89 e5                	mov    %esp,%ebp
f0105b86:	83 ec 08             	sub    $0x8,%esp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0105b89:	8b 55 08             	mov    0x8(%ebp),%edx
f0105b8c:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0105b92:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105b97:	e8 aa fd ff ff       	call   f0105946 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0105b9c:	8b 15 04 70 27 f0    	mov    0xf0277004,%edx
f0105ba2:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105ba8:	f6 c4 10             	test   $0x10,%ah
f0105bab:	75 f5                	jne    f0105ba2 <lapic_ipi+0x1f>
		;
}
f0105bad:	c9                   	leave  
f0105bae:	c3                   	ret    

f0105baf <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0105baf:	55                   	push   %ebp
f0105bb0:	89 e5                	mov    %esp,%ebp
f0105bb2:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0105bb5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0105bbb:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105bbe:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0105bc1:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0105bc8:	5d                   	pop    %ebp
f0105bc9:	c3                   	ret    

f0105bca <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0105bca:	55                   	push   %ebp
f0105bcb:	89 e5                	mov    %esp,%ebp
f0105bcd:	56                   	push   %esi
f0105bce:	53                   	push   %ebx
f0105bcf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	return lock->locked && lock->cpu == thiscpu;
f0105bd2:	83 3b 00             	cmpl   $0x0,(%ebx)
f0105bd5:	75 12                	jne    f0105be9 <spin_lock+0x1f>
	asm volatile("lock; xchgl %0, %1"
f0105bd7:	ba 01 00 00 00       	mov    $0x1,%edx
f0105bdc:	89 d0                	mov    %edx,%eax
f0105bde:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0105be1:	85 c0                	test   %eax,%eax
f0105be3:	74 36                	je     f0105c1b <spin_lock+0x51>
		asm volatile ("pause");
f0105be5:	f3 90                	pause  
f0105be7:	eb f3                	jmp    f0105bdc <spin_lock+0x12>
	return lock->locked && lock->cpu == thiscpu;
f0105be9:	8b 73 08             	mov    0x8(%ebx),%esi
f0105bec:	e8 69 fd ff ff       	call   f010595a <cpunum>
f0105bf1:	6b c0 74             	imul   $0x74,%eax,%eax
f0105bf4:	05 20 60 23 f0       	add    $0xf0236020,%eax
	if (holding(lk))
f0105bf9:	39 c6                	cmp    %eax,%esi
f0105bfb:	75 da                	jne    f0105bd7 <spin_lock+0xd>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0105bfd:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0105c00:	e8 55 fd ff ff       	call   f010595a <cpunum>
f0105c05:	83 ec 0c             	sub    $0xc,%esp
f0105c08:	53                   	push   %ebx
f0105c09:	50                   	push   %eax
f0105c0a:	68 08 7c 10 f0       	push   $0xf0107c08
f0105c0f:	6a 41                	push   $0x41
f0105c11:	68 6c 7c 10 f0       	push   $0xf0107c6c
f0105c16:	e8 79 a4 ff ff       	call   f0100094 <_panic>

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0105c1b:	e8 3a fd ff ff       	call   f010595a <cpunum>
f0105c20:	6b c0 74             	imul   $0x74,%eax,%eax
f0105c23:	05 20 60 23 f0       	add    $0xf0236020,%eax
f0105c28:	89 43 08             	mov    %eax,0x8(%ebx)
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0105c2b:	89 ea                	mov    %ebp,%edx
	for (i = 0; i < 10; i++){
f0105c2d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0105c32:	83 f8 09             	cmp    $0x9,%eax
f0105c35:	7f 16                	jg     f0105c4d <spin_lock+0x83>
f0105c37:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0105c3d:	76 0e                	jbe    f0105c4d <spin_lock+0x83>
		pcs[i] = ebp[1];          // saved %eip
f0105c3f:	8b 4a 04             	mov    0x4(%edx),%ecx
f0105c42:	89 4c 83 0c          	mov    %ecx,0xc(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0105c46:	8b 12                	mov    (%edx),%edx
	for (i = 0; i < 10; i++){
f0105c48:	83 c0 01             	add    $0x1,%eax
f0105c4b:	eb e5                	jmp    f0105c32 <spin_lock+0x68>
	for (; i < 10; i++)
f0105c4d:	83 f8 09             	cmp    $0x9,%eax
f0105c50:	7f 0d                	jg     f0105c5f <spin_lock+0x95>
		pcs[i] = 0;
f0105c52:	c7 44 83 0c 00 00 00 	movl   $0x0,0xc(%ebx,%eax,4)
f0105c59:	00 
	for (; i < 10; i++)
f0105c5a:	83 c0 01             	add    $0x1,%eax
f0105c5d:	eb ee                	jmp    f0105c4d <spin_lock+0x83>
	get_caller_pcs(lk->pcs);
#endif
}
f0105c5f:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105c62:	5b                   	pop    %ebx
f0105c63:	5e                   	pop    %esi
f0105c64:	5d                   	pop    %ebp
f0105c65:	c3                   	ret    

f0105c66 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0105c66:	55                   	push   %ebp
f0105c67:	89 e5                	mov    %esp,%ebp
f0105c69:	57                   	push   %edi
f0105c6a:	56                   	push   %esi
f0105c6b:	53                   	push   %ebx
f0105c6c:	83 ec 4c             	sub    $0x4c,%esp
f0105c6f:	8b 75 08             	mov    0x8(%ebp),%esi
	return lock->locked && lock->cpu == thiscpu;
f0105c72:	83 3e 00             	cmpl   $0x0,(%esi)
f0105c75:	75 35                	jne    f0105cac <spin_unlock+0x46>
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f0105c77:	83 ec 04             	sub    $0x4,%esp
f0105c7a:	6a 28                	push   $0x28
f0105c7c:	8d 46 0c             	lea    0xc(%esi),%eax
f0105c7f:	50                   	push   %eax
f0105c80:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f0105c83:	53                   	push   %ebx
f0105c84:	e8 1a f7 ff ff       	call   f01053a3 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f0105c89:	8b 46 08             	mov    0x8(%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0105c8c:	0f b6 38             	movzbl (%eax),%edi
f0105c8f:	8b 76 04             	mov    0x4(%esi),%esi
f0105c92:	e8 c3 fc ff ff       	call   f010595a <cpunum>
f0105c97:	57                   	push   %edi
f0105c98:	56                   	push   %esi
f0105c99:	50                   	push   %eax
f0105c9a:	68 34 7c 10 f0       	push   $0xf0107c34
f0105c9f:	e8 7c db ff ff       	call   f0103820 <cprintf>
f0105ca4:	83 c4 20             	add    $0x20,%esp
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0105ca7:	8d 7d a8             	lea    -0x58(%ebp),%edi
f0105caa:	eb 4e                	jmp    f0105cfa <spin_unlock+0x94>
	return lock->locked && lock->cpu == thiscpu;
f0105cac:	8b 5e 08             	mov    0x8(%esi),%ebx
f0105caf:	e8 a6 fc ff ff       	call   f010595a <cpunum>
f0105cb4:	6b c0 74             	imul   $0x74,%eax,%eax
f0105cb7:	05 20 60 23 f0       	add    $0xf0236020,%eax
	if (!holding(lk)) {
f0105cbc:	39 c3                	cmp    %eax,%ebx
f0105cbe:	75 b7                	jne    f0105c77 <spin_unlock+0x11>
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
	}

	lk->pcs[0] = 0;
f0105cc0:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f0105cc7:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
	asm volatile("lock; xchgl %0, %1"
f0105cce:	b8 00 00 00 00       	mov    $0x0,%eax
f0105cd3:	f0 87 06             	lock xchg %eax,(%esi)
	// respect to any other instruction which references the same memory.
	// x86 CPUs will not reorder loads/stores across locked instructions
	// (vol 3, 8.2.2). Because xchg() is implemented using asm volatile,
	// gcc will not reorder C statements across the xchg.
	xchg(&lk->locked, 0);
}
f0105cd6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105cd9:	5b                   	pop    %ebx
f0105cda:	5e                   	pop    %esi
f0105cdb:	5f                   	pop    %edi
f0105cdc:	5d                   	pop    %ebp
f0105cdd:	c3                   	ret    
				cprintf("  %08x\n", pcs[i]);
f0105cde:	83 ec 08             	sub    $0x8,%esp
f0105ce1:	ff 36                	pushl  (%esi)
f0105ce3:	68 93 7c 10 f0       	push   $0xf0107c93
f0105ce8:	e8 33 db ff ff       	call   f0103820 <cprintf>
f0105ced:	83 c4 10             	add    $0x10,%esp
f0105cf0:	83 c3 04             	add    $0x4,%ebx
		for (i = 0; i < 10 && pcs[i]; i++) {
f0105cf3:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0105cf6:	39 c3                	cmp    %eax,%ebx
f0105cf8:	74 40                	je     f0105d3a <spin_unlock+0xd4>
f0105cfa:	89 de                	mov    %ebx,%esi
f0105cfc:	8b 03                	mov    (%ebx),%eax
f0105cfe:	85 c0                	test   %eax,%eax
f0105d00:	74 38                	je     f0105d3a <spin_unlock+0xd4>
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0105d02:	83 ec 08             	sub    $0x8,%esp
f0105d05:	57                   	push   %edi
f0105d06:	50                   	push   %eax
f0105d07:	e8 10 ec ff ff       	call   f010491c <debuginfo_eip>
f0105d0c:	83 c4 10             	add    $0x10,%esp
f0105d0f:	85 c0                	test   %eax,%eax
f0105d11:	78 cb                	js     f0105cde <spin_unlock+0x78>
					pcs[i] - info.eip_fn_addr);
f0105d13:	8b 06                	mov    (%esi),%eax
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0105d15:	83 ec 04             	sub    $0x4,%esp
f0105d18:	89 c2                	mov    %eax,%edx
f0105d1a:	2b 55 b8             	sub    -0x48(%ebp),%edx
f0105d1d:	52                   	push   %edx
f0105d1e:	ff 75 b0             	pushl  -0x50(%ebp)
f0105d21:	ff 75 b4             	pushl  -0x4c(%ebp)
f0105d24:	ff 75 ac             	pushl  -0x54(%ebp)
f0105d27:	ff 75 a8             	pushl  -0x58(%ebp)
f0105d2a:	50                   	push   %eax
f0105d2b:	68 7c 7c 10 f0       	push   $0xf0107c7c
f0105d30:	e8 eb da ff ff       	call   f0103820 <cprintf>
f0105d35:	83 c4 20             	add    $0x20,%esp
f0105d38:	eb b6                	jmp    f0105cf0 <spin_unlock+0x8a>
		panic("spin_unlock");
f0105d3a:	83 ec 04             	sub    $0x4,%esp
f0105d3d:	68 9b 7c 10 f0       	push   $0xf0107c9b
f0105d42:	6a 67                	push   $0x67
f0105d44:	68 6c 7c 10 f0       	push   $0xf0107c6c
f0105d49:	e8 46 a3 ff ff       	call   f0100094 <_panic>
f0105d4e:	66 90                	xchg   %ax,%ax

f0105d50 <__udivdi3>:
f0105d50:	f3 0f 1e fb          	endbr32 
f0105d54:	55                   	push   %ebp
f0105d55:	57                   	push   %edi
f0105d56:	56                   	push   %esi
f0105d57:	53                   	push   %ebx
f0105d58:	83 ec 1c             	sub    $0x1c,%esp
f0105d5b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f0105d5f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f0105d63:	8b 74 24 34          	mov    0x34(%esp),%esi
f0105d67:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f0105d6b:	85 d2                	test   %edx,%edx
f0105d6d:	75 49                	jne    f0105db8 <__udivdi3+0x68>
f0105d6f:	39 f3                	cmp    %esi,%ebx
f0105d71:	76 15                	jbe    f0105d88 <__udivdi3+0x38>
f0105d73:	31 ff                	xor    %edi,%edi
f0105d75:	89 e8                	mov    %ebp,%eax
f0105d77:	89 f2                	mov    %esi,%edx
f0105d79:	f7 f3                	div    %ebx
f0105d7b:	89 fa                	mov    %edi,%edx
f0105d7d:	83 c4 1c             	add    $0x1c,%esp
f0105d80:	5b                   	pop    %ebx
f0105d81:	5e                   	pop    %esi
f0105d82:	5f                   	pop    %edi
f0105d83:	5d                   	pop    %ebp
f0105d84:	c3                   	ret    
f0105d85:	8d 76 00             	lea    0x0(%esi),%esi
f0105d88:	89 d9                	mov    %ebx,%ecx
f0105d8a:	85 db                	test   %ebx,%ebx
f0105d8c:	75 0b                	jne    f0105d99 <__udivdi3+0x49>
f0105d8e:	b8 01 00 00 00       	mov    $0x1,%eax
f0105d93:	31 d2                	xor    %edx,%edx
f0105d95:	f7 f3                	div    %ebx
f0105d97:	89 c1                	mov    %eax,%ecx
f0105d99:	31 d2                	xor    %edx,%edx
f0105d9b:	89 f0                	mov    %esi,%eax
f0105d9d:	f7 f1                	div    %ecx
f0105d9f:	89 c6                	mov    %eax,%esi
f0105da1:	89 e8                	mov    %ebp,%eax
f0105da3:	89 f7                	mov    %esi,%edi
f0105da5:	f7 f1                	div    %ecx
f0105da7:	89 fa                	mov    %edi,%edx
f0105da9:	83 c4 1c             	add    $0x1c,%esp
f0105dac:	5b                   	pop    %ebx
f0105dad:	5e                   	pop    %esi
f0105dae:	5f                   	pop    %edi
f0105daf:	5d                   	pop    %ebp
f0105db0:	c3                   	ret    
f0105db1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105db8:	39 f2                	cmp    %esi,%edx
f0105dba:	77 1c                	ja     f0105dd8 <__udivdi3+0x88>
f0105dbc:	0f bd fa             	bsr    %edx,%edi
f0105dbf:	83 f7 1f             	xor    $0x1f,%edi
f0105dc2:	75 2c                	jne    f0105df0 <__udivdi3+0xa0>
f0105dc4:	39 f2                	cmp    %esi,%edx
f0105dc6:	72 06                	jb     f0105dce <__udivdi3+0x7e>
f0105dc8:	31 c0                	xor    %eax,%eax
f0105dca:	39 eb                	cmp    %ebp,%ebx
f0105dcc:	77 ad                	ja     f0105d7b <__udivdi3+0x2b>
f0105dce:	b8 01 00 00 00       	mov    $0x1,%eax
f0105dd3:	eb a6                	jmp    f0105d7b <__udivdi3+0x2b>
f0105dd5:	8d 76 00             	lea    0x0(%esi),%esi
f0105dd8:	31 ff                	xor    %edi,%edi
f0105dda:	31 c0                	xor    %eax,%eax
f0105ddc:	89 fa                	mov    %edi,%edx
f0105dde:	83 c4 1c             	add    $0x1c,%esp
f0105de1:	5b                   	pop    %ebx
f0105de2:	5e                   	pop    %esi
f0105de3:	5f                   	pop    %edi
f0105de4:	5d                   	pop    %ebp
f0105de5:	c3                   	ret    
f0105de6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105ded:	8d 76 00             	lea    0x0(%esi),%esi
f0105df0:	89 f9                	mov    %edi,%ecx
f0105df2:	b8 20 00 00 00       	mov    $0x20,%eax
f0105df7:	29 f8                	sub    %edi,%eax
f0105df9:	d3 e2                	shl    %cl,%edx
f0105dfb:	89 54 24 08          	mov    %edx,0x8(%esp)
f0105dff:	89 c1                	mov    %eax,%ecx
f0105e01:	89 da                	mov    %ebx,%edx
f0105e03:	d3 ea                	shr    %cl,%edx
f0105e05:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0105e09:	09 d1                	or     %edx,%ecx
f0105e0b:	89 f2                	mov    %esi,%edx
f0105e0d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0105e11:	89 f9                	mov    %edi,%ecx
f0105e13:	d3 e3                	shl    %cl,%ebx
f0105e15:	89 c1                	mov    %eax,%ecx
f0105e17:	d3 ea                	shr    %cl,%edx
f0105e19:	89 f9                	mov    %edi,%ecx
f0105e1b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0105e1f:	89 eb                	mov    %ebp,%ebx
f0105e21:	d3 e6                	shl    %cl,%esi
f0105e23:	89 c1                	mov    %eax,%ecx
f0105e25:	d3 eb                	shr    %cl,%ebx
f0105e27:	09 de                	or     %ebx,%esi
f0105e29:	89 f0                	mov    %esi,%eax
f0105e2b:	f7 74 24 08          	divl   0x8(%esp)
f0105e2f:	89 d6                	mov    %edx,%esi
f0105e31:	89 c3                	mov    %eax,%ebx
f0105e33:	f7 64 24 0c          	mull   0xc(%esp)
f0105e37:	39 d6                	cmp    %edx,%esi
f0105e39:	72 15                	jb     f0105e50 <__udivdi3+0x100>
f0105e3b:	89 f9                	mov    %edi,%ecx
f0105e3d:	d3 e5                	shl    %cl,%ebp
f0105e3f:	39 c5                	cmp    %eax,%ebp
f0105e41:	73 04                	jae    f0105e47 <__udivdi3+0xf7>
f0105e43:	39 d6                	cmp    %edx,%esi
f0105e45:	74 09                	je     f0105e50 <__udivdi3+0x100>
f0105e47:	89 d8                	mov    %ebx,%eax
f0105e49:	31 ff                	xor    %edi,%edi
f0105e4b:	e9 2b ff ff ff       	jmp    f0105d7b <__udivdi3+0x2b>
f0105e50:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0105e53:	31 ff                	xor    %edi,%edi
f0105e55:	e9 21 ff ff ff       	jmp    f0105d7b <__udivdi3+0x2b>
f0105e5a:	66 90                	xchg   %ax,%ax
f0105e5c:	66 90                	xchg   %ax,%ax
f0105e5e:	66 90                	xchg   %ax,%ax

f0105e60 <__umoddi3>:
f0105e60:	f3 0f 1e fb          	endbr32 
f0105e64:	55                   	push   %ebp
f0105e65:	57                   	push   %edi
f0105e66:	56                   	push   %esi
f0105e67:	53                   	push   %ebx
f0105e68:	83 ec 1c             	sub    $0x1c,%esp
f0105e6b:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f0105e6f:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f0105e73:	8b 74 24 30          	mov    0x30(%esp),%esi
f0105e77:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0105e7b:	89 da                	mov    %ebx,%edx
f0105e7d:	85 c0                	test   %eax,%eax
f0105e7f:	75 3f                	jne    f0105ec0 <__umoddi3+0x60>
f0105e81:	39 df                	cmp    %ebx,%edi
f0105e83:	76 13                	jbe    f0105e98 <__umoddi3+0x38>
f0105e85:	89 f0                	mov    %esi,%eax
f0105e87:	f7 f7                	div    %edi
f0105e89:	89 d0                	mov    %edx,%eax
f0105e8b:	31 d2                	xor    %edx,%edx
f0105e8d:	83 c4 1c             	add    $0x1c,%esp
f0105e90:	5b                   	pop    %ebx
f0105e91:	5e                   	pop    %esi
f0105e92:	5f                   	pop    %edi
f0105e93:	5d                   	pop    %ebp
f0105e94:	c3                   	ret    
f0105e95:	8d 76 00             	lea    0x0(%esi),%esi
f0105e98:	89 fd                	mov    %edi,%ebp
f0105e9a:	85 ff                	test   %edi,%edi
f0105e9c:	75 0b                	jne    f0105ea9 <__umoddi3+0x49>
f0105e9e:	b8 01 00 00 00       	mov    $0x1,%eax
f0105ea3:	31 d2                	xor    %edx,%edx
f0105ea5:	f7 f7                	div    %edi
f0105ea7:	89 c5                	mov    %eax,%ebp
f0105ea9:	89 d8                	mov    %ebx,%eax
f0105eab:	31 d2                	xor    %edx,%edx
f0105ead:	f7 f5                	div    %ebp
f0105eaf:	89 f0                	mov    %esi,%eax
f0105eb1:	f7 f5                	div    %ebp
f0105eb3:	89 d0                	mov    %edx,%eax
f0105eb5:	eb d4                	jmp    f0105e8b <__umoddi3+0x2b>
f0105eb7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105ebe:	66 90                	xchg   %ax,%ax
f0105ec0:	89 f1                	mov    %esi,%ecx
f0105ec2:	39 d8                	cmp    %ebx,%eax
f0105ec4:	76 0a                	jbe    f0105ed0 <__umoddi3+0x70>
f0105ec6:	89 f0                	mov    %esi,%eax
f0105ec8:	83 c4 1c             	add    $0x1c,%esp
f0105ecb:	5b                   	pop    %ebx
f0105ecc:	5e                   	pop    %esi
f0105ecd:	5f                   	pop    %edi
f0105ece:	5d                   	pop    %ebp
f0105ecf:	c3                   	ret    
f0105ed0:	0f bd e8             	bsr    %eax,%ebp
f0105ed3:	83 f5 1f             	xor    $0x1f,%ebp
f0105ed6:	75 20                	jne    f0105ef8 <__umoddi3+0x98>
f0105ed8:	39 d8                	cmp    %ebx,%eax
f0105eda:	0f 82 b0 00 00 00    	jb     f0105f90 <__umoddi3+0x130>
f0105ee0:	39 f7                	cmp    %esi,%edi
f0105ee2:	0f 86 a8 00 00 00    	jbe    f0105f90 <__umoddi3+0x130>
f0105ee8:	89 c8                	mov    %ecx,%eax
f0105eea:	83 c4 1c             	add    $0x1c,%esp
f0105eed:	5b                   	pop    %ebx
f0105eee:	5e                   	pop    %esi
f0105eef:	5f                   	pop    %edi
f0105ef0:	5d                   	pop    %ebp
f0105ef1:	c3                   	ret    
f0105ef2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0105ef8:	89 e9                	mov    %ebp,%ecx
f0105efa:	ba 20 00 00 00       	mov    $0x20,%edx
f0105eff:	29 ea                	sub    %ebp,%edx
f0105f01:	d3 e0                	shl    %cl,%eax
f0105f03:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105f07:	89 d1                	mov    %edx,%ecx
f0105f09:	89 f8                	mov    %edi,%eax
f0105f0b:	d3 e8                	shr    %cl,%eax
f0105f0d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0105f11:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105f15:	8b 54 24 04          	mov    0x4(%esp),%edx
f0105f19:	09 c1                	or     %eax,%ecx
f0105f1b:	89 d8                	mov    %ebx,%eax
f0105f1d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0105f21:	89 e9                	mov    %ebp,%ecx
f0105f23:	d3 e7                	shl    %cl,%edi
f0105f25:	89 d1                	mov    %edx,%ecx
f0105f27:	d3 e8                	shr    %cl,%eax
f0105f29:	89 e9                	mov    %ebp,%ecx
f0105f2b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0105f2f:	d3 e3                	shl    %cl,%ebx
f0105f31:	89 c7                	mov    %eax,%edi
f0105f33:	89 d1                	mov    %edx,%ecx
f0105f35:	89 f0                	mov    %esi,%eax
f0105f37:	d3 e8                	shr    %cl,%eax
f0105f39:	89 e9                	mov    %ebp,%ecx
f0105f3b:	89 fa                	mov    %edi,%edx
f0105f3d:	d3 e6                	shl    %cl,%esi
f0105f3f:	09 d8                	or     %ebx,%eax
f0105f41:	f7 74 24 08          	divl   0x8(%esp)
f0105f45:	89 d1                	mov    %edx,%ecx
f0105f47:	89 f3                	mov    %esi,%ebx
f0105f49:	f7 64 24 0c          	mull   0xc(%esp)
f0105f4d:	89 c6                	mov    %eax,%esi
f0105f4f:	89 d7                	mov    %edx,%edi
f0105f51:	39 d1                	cmp    %edx,%ecx
f0105f53:	72 06                	jb     f0105f5b <__umoddi3+0xfb>
f0105f55:	75 10                	jne    f0105f67 <__umoddi3+0x107>
f0105f57:	39 c3                	cmp    %eax,%ebx
f0105f59:	73 0c                	jae    f0105f67 <__umoddi3+0x107>
f0105f5b:	2b 44 24 0c          	sub    0xc(%esp),%eax
f0105f5f:	1b 54 24 08          	sbb    0x8(%esp),%edx
f0105f63:	89 d7                	mov    %edx,%edi
f0105f65:	89 c6                	mov    %eax,%esi
f0105f67:	89 ca                	mov    %ecx,%edx
f0105f69:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0105f6e:	29 f3                	sub    %esi,%ebx
f0105f70:	19 fa                	sbb    %edi,%edx
f0105f72:	89 d0                	mov    %edx,%eax
f0105f74:	d3 e0                	shl    %cl,%eax
f0105f76:	89 e9                	mov    %ebp,%ecx
f0105f78:	d3 eb                	shr    %cl,%ebx
f0105f7a:	d3 ea                	shr    %cl,%edx
f0105f7c:	09 d8                	or     %ebx,%eax
f0105f7e:	83 c4 1c             	add    $0x1c,%esp
f0105f81:	5b                   	pop    %ebx
f0105f82:	5e                   	pop    %esi
f0105f83:	5f                   	pop    %edi
f0105f84:	5d                   	pop    %ebp
f0105f85:	c3                   	ret    
f0105f86:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105f8d:	8d 76 00             	lea    0x0(%esi),%esi
f0105f90:	89 da                	mov    %ebx,%edx
f0105f92:	29 fe                	sub    %edi,%esi
f0105f94:	19 c2                	sbb    %eax,%edx
f0105f96:	89 f1                	mov    %esi,%ecx
f0105f98:	89 c8                	mov    %ecx,%eax
f0105f9a:	e9 4b ff ff ff       	jmp    f0105eea <__umoddi3+0x8a>
