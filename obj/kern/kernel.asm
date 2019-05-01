
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
f0100015:	b8 00 10 12 00       	mov    $0x121000,%eax
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
f0100034:	bc 00 10 12 f0       	mov    $0xf0121000,%esp

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
f010004b:	68 a0 63 10 f0       	push   $0xf01063a0
f0100050:	e8 a7 38 00 00       	call   f01038fc <cprintf>
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
f010006f:	68 bc 63 10 f0       	push   $0xf01063bc
f0100074:	e8 83 38 00 00       	call   f01038fc <cprintf>
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
f010009c:	83 3d 80 7e 23 f0 00 	cmpl   $0x0,0xf0237e80
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
f01000b4:	89 35 80 7e 23 f0    	mov    %esi,0xf0237e80
	asm volatile("cli; cld");
f01000ba:	fa                   	cli    
f01000bb:	fc                   	cld    
	va_start(ap, fmt);
f01000bc:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f01000bf:	e8 96 5c 00 00       	call   f0105d5a <cpunum>
f01000c4:	ff 75 0c             	pushl  0xc(%ebp)
f01000c7:	ff 75 08             	pushl  0x8(%ebp)
f01000ca:	50                   	push   %eax
f01000cb:	68 30 64 10 f0       	push   $0xf0106430
f01000d0:	e8 27 38 00 00       	call   f01038fc <cprintf>
	vcprintf(fmt, ap);
f01000d5:	83 c4 08             	add    $0x8,%esp
f01000d8:	53                   	push   %ebx
f01000d9:	56                   	push   %esi
f01000da:	e8 f7 37 00 00       	call   f01038d6 <vcprintf>
	cprintf("\n");
f01000df:	c7 04 24 8a 6c 10 f0 	movl   $0xf0106c8a,(%esp)
f01000e6:	e8 11 38 00 00       	call   f01038fc <cprintf>
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
f0100104:	68 d7 63 10 f0       	push   $0xf01063d7
f0100109:	e8 ee 37 00 00       	call   f01038fc <cprintf>
	test_backtrace(5);
f010010e:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f0100115:	e8 26 ff ff ff       	call   f0100040 <test_backtrace>
	mem_init();
f010011a:	e8 ff 11 00 00       	call   f010131e <mem_init>
	env_init();
f010011f:	e8 f3 2f 00 00       	call   f0103117 <env_init>
	trap_init();
f0100124:	e8 b1 38 00 00       	call   f01039da <trap_init>
	mp_init();
f0100129:	e8 35 59 00 00       	call   f0105a63 <mp_init>
	lapic_init();
f010012e:	e8 3d 5c 00 00       	call   f0105d70 <lapic_init>
	pic_init();
f0100133:	e8 e5 36 00 00       	call   f010381d <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0100138:	c7 04 24 c0 33 12 f0 	movl   $0xf01233c0,(%esp)
f010013f:	e8 86 5e 00 00       	call   f0105fca <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100144:	83 c4 10             	add    $0x10,%esp
f0100147:	83 3d 88 7e 23 f0 07 	cmpl   $0x7,0xf0237e88
f010014e:	76 27                	jbe    f0100177 <i386_init+0x87>
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f0100150:	83 ec 04             	sub    $0x4,%esp
f0100153:	b8 c6 59 10 f0       	mov    $0xf01059c6,%eax
f0100158:	2d 4c 59 10 f0       	sub    $0xf010594c,%eax
f010015d:	50                   	push   %eax
f010015e:	68 4c 59 10 f0       	push   $0xf010594c
f0100163:	68 00 70 00 f0       	push   $0xf0007000
f0100168:	e8 35 56 00 00       	call   f01057a2 <memmove>
f010016d:	83 c4 10             	add    $0x10,%esp
	for (c = cpus; c < cpus + ncpu; c++) {
f0100170:	bb 20 80 23 f0       	mov    $0xf0238020,%ebx
f0100175:	eb 19                	jmp    f0100190 <i386_init+0xa0>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100177:	68 00 70 00 00       	push   $0x7000
f010017c:	68 54 64 10 f0       	push   $0xf0106454
f0100181:	6a 5f                	push   $0x5f
f0100183:	68 f2 63 10 f0       	push   $0xf01063f2
f0100188:	e8 07 ff ff ff       	call   f0100094 <_panic>
f010018d:	83 c3 74             	add    $0x74,%ebx
f0100190:	6b 05 c4 83 23 f0 74 	imul   $0x74,0xf02383c4,%eax
f0100197:	05 20 80 23 f0       	add    $0xf0238020,%eax
f010019c:	39 c3                	cmp    %eax,%ebx
f010019e:	73 4d                	jae    f01001ed <i386_init+0xfd>
		if (c == cpus + cpunum())  // We've started already.
f01001a0:	e8 b5 5b 00 00       	call   f0105d5a <cpunum>
f01001a5:	6b c0 74             	imul   $0x74,%eax,%eax
f01001a8:	05 20 80 23 f0       	add    $0xf0238020,%eax
f01001ad:	39 c3                	cmp    %eax,%ebx
f01001af:	74 dc                	je     f010018d <i386_init+0x9d>
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f01001b1:	89 d8                	mov    %ebx,%eax
f01001b3:	2d 20 80 23 f0       	sub    $0xf0238020,%eax
f01001b8:	c1 f8 02             	sar    $0x2,%eax
f01001bb:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f01001c1:	c1 e0 0f             	shl    $0xf,%eax
f01001c4:	8d 80 00 10 24 f0    	lea    -0xfdbf000(%eax),%eax
f01001ca:	a3 84 7e 23 f0       	mov    %eax,0xf0237e84
		lapic_startap(c->cpu_id, PADDR(code));
f01001cf:	83 ec 08             	sub    $0x8,%esp
f01001d2:	68 00 70 00 00       	push   $0x7000
f01001d7:	0f b6 03             	movzbl (%ebx),%eax
f01001da:	50                   	push   %eax
f01001db:	e8 e2 5c 00 00       	call   f0105ec2 <lapic_startap>
f01001e0:	83 c4 10             	add    $0x10,%esp
		while(c->cpu_status != CPU_STARTED)
f01001e3:	8b 43 04             	mov    0x4(%ebx),%eax
f01001e6:	83 f8 01             	cmp    $0x1,%eax
f01001e9:	75 f8                	jne    f01001e3 <i386_init+0xf3>
f01001eb:	eb a0                	jmp    f010018d <i386_init+0x9d>
	ENV_CREATE(TEST, ENV_TYPE_USER);
f01001ed:	83 ec 08             	sub    $0x8,%esp
f01001f0:	6a 00                	push   $0x0
f01001f2:	68 c8 d4 22 f0       	push   $0xf022d4c8
f01001f7:	e8 15 31 00 00       	call   f0103311 <env_create>
	sched_yield();
f01001fc:	e8 4e 43 00 00       	call   f010454f <sched_yield>

f0100201 <mp_main>:
{
f0100201:	55                   	push   %ebp
f0100202:	89 e5                	mov    %esp,%ebp
f0100204:	83 ec 08             	sub    $0x8,%esp
	lcr3(PADDR(kern_pgdir));
f0100207:	a1 8c 7e 23 f0       	mov    0xf0237e8c,%eax
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
f010021b:	e8 3a 5b 00 00       	call   f0105d5a <cpunum>
f0100220:	83 ec 08             	sub    $0x8,%esp
f0100223:	50                   	push   %eax
f0100224:	68 fe 63 10 f0       	push   $0xf01063fe
f0100229:	e8 ce 36 00 00       	call   f01038fc <cprintf>
	lapic_init();
f010022e:	e8 3d 5b 00 00       	call   f0105d70 <lapic_init>
	env_init_percpu();
f0100233:	e8 b3 2e 00 00       	call   f01030eb <env_init_percpu>
	trap_init_percpu();
f0100238:	e8 d3 36 00 00       	call   f0103910 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f010023d:	e8 18 5b 00 00       	call   f0105d5a <cpunum>
f0100242:	6b d0 74             	imul   $0x74,%eax,%edx
f0100245:	83 c2 04             	add    $0x4,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0100248:	b8 01 00 00 00       	mov    $0x1,%eax
f010024d:	f0 87 82 20 80 23 f0 	lock xchg %eax,-0xfdc7fe0(%edx)
f0100254:	c7 04 24 c0 33 12 f0 	movl   $0xf01233c0,(%esp)
f010025b:	e8 6a 5d 00 00       	call   f0105fca <spin_lock>
	sched_yield();
f0100260:	e8 ea 42 00 00       	call   f010454f <sched_yield>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100265:	50                   	push   %eax
f0100266:	68 78 64 10 f0       	push   $0xf0106478
f010026b:	6a 76                	push   $0x76
f010026d:	68 f2 63 10 f0       	push   $0xf01063f2
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
f0100287:	68 14 64 10 f0       	push   $0xf0106414
f010028c:	e8 6b 36 00 00       	call   f01038fc <cprintf>
	vcprintf(fmt, ap);
f0100291:	83 c4 08             	add    $0x8,%esp
f0100294:	53                   	push   %ebx
f0100295:	ff 75 10             	pushl  0x10(%ebp)
f0100298:	e8 39 36 00 00       	call   f01038d6 <vcprintf>
	cprintf("\n");
f010029d:	c7 04 24 8a 6c 10 f0 	movl   $0xf0106c8a,(%esp)
f01002a4:	e8 53 36 00 00       	call   f01038fc <cprintf>
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
f01002df:	8b 0d 24 72 23 f0    	mov    0xf0237224,%ecx
f01002e5:	8d 51 01             	lea    0x1(%ecx),%edx
f01002e8:	88 81 20 70 23 f0    	mov    %al,-0xfdc8fe0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f01002ee:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.wpos = 0;
f01002f4:	b8 00 00 00 00       	mov    $0x0,%eax
f01002f9:	0f 44 d0             	cmove  %eax,%edx
f01002fc:	89 15 24 72 23 f0    	mov    %edx,0xf0237224
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
f0100337:	8b 0d 00 70 23 f0    	mov    0xf0237000,%ecx
f010033d:	f6 c1 40             	test   $0x40,%cl
f0100340:	74 0e                	je     f0100350 <kbd_proc_data+0x46>
		data |= 0x80;
f0100342:	83 c8 80             	or     $0xffffff80,%eax
f0100345:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100347:	83 e1 bf             	and    $0xffffffbf,%ecx
f010034a:	89 0d 00 70 23 f0    	mov    %ecx,0xf0237000
	shift |= shiftcode[data];
f0100350:	0f b6 d2             	movzbl %dl,%edx
f0100353:	0f b6 82 00 66 10 f0 	movzbl -0xfef9a00(%edx),%eax
f010035a:	0b 05 00 70 23 f0    	or     0xf0237000,%eax
	shift ^= togglecode[data];
f0100360:	0f b6 8a 00 65 10 f0 	movzbl -0xfef9b00(%edx),%ecx
f0100367:	31 c8                	xor    %ecx,%eax
f0100369:	a3 00 70 23 f0       	mov    %eax,0xf0237000
	c = charcode[shift & (CTL | SHIFT)][data];
f010036e:	89 c1                	mov    %eax,%ecx
f0100370:	83 e1 03             	and    $0x3,%ecx
f0100373:	8b 0c 8d e0 64 10 f0 	mov    -0xfef9b20(,%ecx,4),%ecx
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
f0100394:	83 0d 00 70 23 f0 40 	orl    $0x40,0xf0237000
		return 0;
f010039b:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f01003a0:	89 d8                	mov    %ebx,%eax
f01003a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01003a5:	c9                   	leave  
f01003a6:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f01003a7:	8b 0d 00 70 23 f0    	mov    0xf0237000,%ecx
f01003ad:	89 cb                	mov    %ecx,%ebx
f01003af:	83 e3 40             	and    $0x40,%ebx
f01003b2:	83 e0 7f             	and    $0x7f,%eax
f01003b5:	85 db                	test   %ebx,%ebx
f01003b7:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01003ba:	0f b6 d2             	movzbl %dl,%edx
f01003bd:	0f b6 82 00 66 10 f0 	movzbl -0xfef9a00(%edx),%eax
f01003c4:	83 c8 40             	or     $0x40,%eax
f01003c7:	0f b6 c0             	movzbl %al,%eax
f01003ca:	f7 d0                	not    %eax
f01003cc:	21 c8                	and    %ecx,%eax
f01003ce:	a3 00 70 23 f0       	mov    %eax,0xf0237000
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
f01003f7:	68 9c 64 10 f0       	push   $0xf010649c
f01003fc:	e8 fb 34 00 00       	call   f01038fc <cprintf>
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
f01004d4:	0f b7 05 28 72 23 f0 	movzwl 0xf0237228,%eax
f01004db:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01004e1:	c1 e8 16             	shr    $0x16,%eax
f01004e4:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01004e7:	c1 e0 04             	shl    $0x4,%eax
f01004ea:	66 a3 28 72 23 f0    	mov    %ax,0xf0237228
	if (crt_pos >= CRT_SIZE) {
f01004f0:	66 81 3d 28 72 23 f0 	cmpw   $0x7cf,0xf0237228
f01004f7:	cf 07 
f01004f9:	0f 87 cb 00 00 00    	ja     f01005ca <cons_putc+0x1ab>
	outb(addr_6845, 14);
f01004ff:	8b 0d 30 72 23 f0    	mov    0xf0237230,%ecx
f0100505:	b8 0e 00 00 00       	mov    $0xe,%eax
f010050a:	89 ca                	mov    %ecx,%edx
f010050c:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f010050d:	0f b7 1d 28 72 23 f0 	movzwl 0xf0237228,%ebx
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
f010053a:	0f b7 05 28 72 23 f0 	movzwl 0xf0237228,%eax
f0100541:	66 85 c0             	test   %ax,%ax
f0100544:	74 b9                	je     f01004ff <cons_putc+0xe0>
			crt_pos--;
f0100546:	83 e8 01             	sub    $0x1,%eax
f0100549:	66 a3 28 72 23 f0    	mov    %ax,0xf0237228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010054f:	0f b7 c0             	movzwl %ax,%eax
f0100552:	b1 00                	mov    $0x0,%cl
f0100554:	83 c9 20             	or     $0x20,%ecx
f0100557:	8b 15 2c 72 23 f0    	mov    0xf023722c,%edx
f010055d:	66 89 0c 42          	mov    %cx,(%edx,%eax,2)
f0100561:	eb 8d                	jmp    f01004f0 <cons_putc+0xd1>
		crt_pos += CRT_COLS;
f0100563:	66 83 05 28 72 23 f0 	addw   $0x50,0xf0237228
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
f01005a7:	0f b7 05 28 72 23 f0 	movzwl 0xf0237228,%eax
f01005ae:	8d 50 01             	lea    0x1(%eax),%edx
f01005b1:	66 89 15 28 72 23 f0 	mov    %dx,0xf0237228
f01005b8:	0f b7 c0             	movzwl %ax,%eax
f01005bb:	8b 15 2c 72 23 f0    	mov    0xf023722c,%edx
f01005c1:	66 89 0c 42          	mov    %cx,(%edx,%eax,2)
f01005c5:	e9 26 ff ff ff       	jmp    f01004f0 <cons_putc+0xd1>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01005ca:	a1 2c 72 23 f0       	mov    0xf023722c,%eax
f01005cf:	83 ec 04             	sub    $0x4,%esp
f01005d2:	68 00 0f 00 00       	push   $0xf00
f01005d7:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01005dd:	52                   	push   %edx
f01005de:	50                   	push   %eax
f01005df:	e8 be 51 00 00       	call   f01057a2 <memmove>
			crt_buf[i] = 0x0700 | ' ';
f01005e4:	8b 15 2c 72 23 f0    	mov    0xf023722c,%edx
f01005ea:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f01005f0:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f01005f6:	83 c4 10             	add    $0x10,%esp
f01005f9:	66 c7 00 20 07       	movw   $0x720,(%eax)
f01005fe:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100601:	39 d0                	cmp    %edx,%eax
f0100603:	75 f4                	jne    f01005f9 <cons_putc+0x1da>
		crt_pos -= CRT_COLS;
f0100605:	66 83 2d 28 72 23 f0 	subw   $0x50,0xf0237228
f010060c:	50 
f010060d:	e9 ed fe ff ff       	jmp    f01004ff <cons_putc+0xe0>

f0100612 <serial_intr>:
	if (serial_exists)
f0100612:	80 3d 34 72 23 f0 00 	cmpb   $0x0,0xf0237234
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
f0100650:	8b 15 20 72 23 f0    	mov    0xf0237220,%edx
	return 0;
f0100656:	b8 00 00 00 00       	mov    $0x0,%eax
	if (cons.rpos != cons.wpos) {
f010065b:	3b 15 24 72 23 f0    	cmp    0xf0237224,%edx
f0100661:	74 1e                	je     f0100681 <cons_getc+0x41>
		c = cons.buf[cons.rpos++];
f0100663:	8d 4a 01             	lea    0x1(%edx),%ecx
f0100666:	0f b6 82 20 70 23 f0 	movzbl -0xfdc8fe0(%edx),%eax
			cons.rpos = 0;
f010066d:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f0100673:	ba 00 00 00 00       	mov    $0x0,%edx
f0100678:	0f 44 ca             	cmove  %edx,%ecx
f010067b:	89 0d 20 72 23 f0    	mov    %ecx,0xf0237220
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
f01006ad:	c7 05 30 72 23 f0 b4 	movl   $0x3b4,0xf0237230
f01006b4:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f01006b7:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
	outb(addr_6845, 14);
f01006bc:	8b 3d 30 72 23 f0    	mov    0xf0237230,%edi
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
f01006e3:	89 35 2c 72 23 f0    	mov    %esi,0xf023722c
	pos |= inb(addr_6845 + 1);
f01006e9:	0f b6 c0             	movzbl %al,%eax
f01006ec:	09 d8                	or     %ebx,%eax
	crt_pos = pos;
f01006ee:	66 a3 28 72 23 f0    	mov    %ax,0xf0237228
	kbd_intr();
f01006f4:	e8 35 ff ff ff       	call   f010062e <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_KBD));
f01006f9:	83 ec 0c             	sub    $0xc,%esp
f01006fc:	0f b7 05 a8 33 12 f0 	movzwl 0xf01233a8,%eax
f0100703:	25 fd ff 00 00       	and    $0xfffd,%eax
f0100708:	50                   	push   %eax
f0100709:	e8 91 30 00 00       	call   f010379f <irq_setmask_8259A>
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
f0100764:	0f 95 05 34 72 23 f0 	setne  0xf0237234
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
f0100788:	c7 05 30 72 23 f0 d4 	movl   $0x3d4,0xf0237230
f010078f:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100792:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
f0100797:	e9 20 ff ff ff       	jmp    f01006bc <cons_init+0x39>
		cprintf("Serial port does not exist!\n");
f010079c:	83 ec 0c             	sub    $0xc,%esp
f010079f:	68 a8 64 10 f0       	push   $0xf01064a8
f01007a4:	e8 53 31 00 00       	call   f01038fc <cprintf>
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
f01007db:	68 00 67 10 f0       	push   $0xf0106700
f01007e0:	68 1e 67 10 f0       	push   $0xf010671e
f01007e5:	68 23 67 10 f0       	push   $0xf0106723
f01007ea:	e8 0d 31 00 00       	call   f01038fc <cprintf>
f01007ef:	83 c4 0c             	add    $0xc,%esp
f01007f2:	68 d0 67 10 f0       	push   $0xf01067d0
f01007f7:	68 2c 67 10 f0       	push   $0xf010672c
f01007fc:	68 23 67 10 f0       	push   $0xf0106723
f0100801:	e8 f6 30 00 00       	call   f01038fc <cprintf>
f0100806:	83 c4 0c             	add    $0xc,%esp
f0100809:	68 35 67 10 f0       	push   $0xf0106735
f010080e:	68 4c 67 10 f0       	push   $0xf010674c
f0100813:	68 23 67 10 f0       	push   $0xf0106723
f0100818:	e8 df 30 00 00       	call   f01038fc <cprintf>
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
f010082a:	68 56 67 10 f0       	push   $0xf0106756
f010082f:	e8 c8 30 00 00       	call   f01038fc <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100834:	83 c4 08             	add    $0x8,%esp
f0100837:	68 0c 00 10 00       	push   $0x10000c
f010083c:	68 f8 67 10 f0       	push   $0xf01067f8
f0100841:	e8 b6 30 00 00       	call   f01038fc <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100846:	83 c4 0c             	add    $0xc,%esp
f0100849:	68 0c 00 10 00       	push   $0x10000c
f010084e:	68 0c 00 10 f0       	push   $0xf010000c
f0100853:	68 20 68 10 f0       	push   $0xf0106820
f0100858:	e8 9f 30 00 00       	call   f01038fc <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010085d:	83 c4 0c             	add    $0xc,%esp
f0100860:	68 9f 63 10 00       	push   $0x10639f
f0100865:	68 9f 63 10 f0       	push   $0xf010639f
f010086a:	68 44 68 10 f0       	push   $0xf0106844
f010086f:	e8 88 30 00 00       	call   f01038fc <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100874:	83 c4 0c             	add    $0xc,%esp
f0100877:	68 00 70 23 00       	push   $0x237000
f010087c:	68 00 70 23 f0       	push   $0xf0237000
f0100881:	68 68 68 10 f0       	push   $0xf0106868
f0100886:	e8 71 30 00 00       	call   f01038fc <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010088b:	83 c4 0c             	add    $0xc,%esp
f010088e:	68 08 90 27 00       	push   $0x279008
f0100893:	68 08 90 27 f0       	push   $0xf0279008
f0100898:	68 8c 68 10 f0       	push   $0xf010688c
f010089d:	e8 5a 30 00 00       	call   f01038fc <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f01008a2:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f01008a5:	b8 08 90 27 f0       	mov    $0xf0279008,%eax
f01008aa:	2d 0d fc 0f f0       	sub    $0xf00ffc0d,%eax
	cprintf("Kernel executable memory footprint: %dKB\n",
f01008af:	c1 f8 0a             	sar    $0xa,%eax
f01008b2:	50                   	push   %eax
f01008b3:	68 b0 68 10 f0       	push   $0xf01068b0
f01008b8:	e8 3f 30 00 00       	call   f01038fc <cprintf>
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
f01008cf:	68 6f 67 10 f0       	push   $0xf010676f
f01008d4:	e8 23 30 00 00       	call   f01038fc <cprintf>
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
f01008f7:	68 81 67 10 f0       	push   $0xf0106781
f01008fc:	e8 fb 2f 00 00       	call   f01038fc <cprintf>
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
f010091f:	68 dc 68 10 f0       	push   $0xf01068dc
f0100924:	e8 d3 2f 00 00       	call   f01038fc <cprintf>
		if (debuginfo_eip(ptr_ebp[1], &info) == 0) {
f0100929:	83 c4 18             	add    $0x18,%esp
f010092c:	57                   	push   %edi
f010092d:	ff 73 04             	pushl  0x4(%ebx)
f0100930:	e8 e6 43 00 00       	call   f0104d1b <debuginfo_eip>
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
f0100954:	68 0c 69 10 f0       	push   $0xf010690c
f0100959:	e8 9e 2f 00 00       	call   f01038fc <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f010095e:	c7 04 24 30 69 10 f0 	movl   $0xf0106930,(%esp)
f0100965:	e8 92 2f 00 00       	call   f01038fc <cprintf>

	if (tf != NULL)
f010096a:	83 c4 10             	add    $0x10,%esp
f010096d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100971:	0f 84 d9 00 00 00    	je     f0100a50 <monitor+0x105>
		print_trapframe(tf);
f0100977:	83 ec 0c             	sub    $0xc,%esp
f010097a:	ff 75 08             	pushl  0x8(%ebp)
f010097d:	e8 51 35 00 00       	call   f0103ed3 <print_trapframe>
f0100982:	83 c4 10             	add    $0x10,%esp
f0100985:	e9 c6 00 00 00       	jmp    f0100a50 <monitor+0x105>
		while (*buf && strchr(WHITESPACE, *buf))
f010098a:	83 ec 08             	sub    $0x8,%esp
f010098d:	0f be c0             	movsbl %al,%eax
f0100990:	50                   	push   %eax
f0100991:	68 97 67 10 f0       	push   $0xf0106797
f0100996:	e8 82 4d 00 00       	call   f010571d <strchr>
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
f01009ce:	ff 34 85 60 69 10 f0 	pushl  -0xfef96a0(,%eax,4)
f01009d5:	ff 75 a8             	pushl  -0x58(%ebp)
f01009d8:	e8 e2 4c 00 00       	call   f01056bf <strcmp>
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
f01009f6:	68 b9 67 10 f0       	push   $0xf01067b9
f01009fb:	e8 fc 2e 00 00       	call   f01038fc <cprintf>
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
f0100a24:	68 97 67 10 f0       	push   $0xf0106797
f0100a29:	e8 ef 4c 00 00       	call   f010571d <strchr>
f0100a2e:	83 c4 10             	add    $0x10,%esp
f0100a31:	85 c0                	test   %eax,%eax
f0100a33:	0f 85 71 ff ff ff    	jne    f01009aa <monitor+0x5f>
			buf++;
f0100a39:	83 c3 01             	add    $0x1,%ebx
f0100a3c:	eb d8                	jmp    f0100a16 <monitor+0xcb>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100a3e:	83 ec 08             	sub    $0x8,%esp
f0100a41:	6a 10                	push   $0x10
f0100a43:	68 9c 67 10 f0       	push   $0xf010679c
f0100a48:	e8 af 2e 00 00       	call   f01038fc <cprintf>
f0100a4d:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f0100a50:	83 ec 0c             	sub    $0xc,%esp
f0100a53:	68 93 67 10 f0       	push   $0xf0106793
f0100a58:	e8 9c 4a 00 00       	call   f01054f9 <readline>
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
f0100a85:	ff 14 85 68 69 10 f0 	call   *-0xfef9698(,%eax,4)
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
f0100aa4:	ff 35 38 72 23 f0    	pushl  0xf0237238
f0100aaa:	68 84 69 10 f0       	push   $0xf0106984
f0100aaf:	e8 48 2e 00 00       	call   f01038fc <cprintf>
	if (!nextfree) {
f0100ab4:	83 c4 10             	add    $0x10,%esp
f0100ab7:	83 3d 38 72 23 f0 00 	cmpl   $0x0,0xf0237238
f0100abe:	74 1e                	je     f0100ade <boot_alloc+0x43>
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	//cprintf("nextfree:%p\n", nextfree);
	result = nextfree;
f0100ac0:	a1 38 72 23 f0       	mov    0xf0237238,%eax
	nextfree += ROUNDUP(n, PGSIZE);
f0100ac5:	81 c3 ff 0f 00 00    	add    $0xfff,%ebx
f0100acb:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0100ad1:	01 c3                	add    %eax,%ebx
f0100ad3:	89 1d 38 72 23 f0    	mov    %ebx,0xf0237238
	return result;
}
f0100ad9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100adc:	c9                   	leave  
f0100add:	c3                   	ret    
		nextfree = ROUNDUP((char *) end, PGSIZE);		
f0100ade:	b8 07 a0 27 f0       	mov    $0xf027a007,%eax
f0100ae3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100ae8:	a3 38 72 23 f0       	mov    %eax,0xf0237238
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
f0100afa:	e8 72 2c 00 00       	call   f0103771 <mc146818_read>
f0100aff:	89 c3                	mov    %eax,%ebx
f0100b01:	83 c6 01             	add    $0x1,%esi
f0100b04:	89 34 24             	mov    %esi,(%esp)
f0100b07:	e8 65 2c 00 00       	call   f0103771 <mc146818_read>
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
f0100b2e:	3b 0d 88 7e 23 f0    	cmp    0xf0237e88,%ecx
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
f0100b62:	68 54 64 10 f0       	push   $0xf0106454
f0100b67:	68 b2 03 00 00       	push   $0x3b2
f0100b6c:	68 91 69 10 f0       	push   $0xf0106991
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
f0100b8d:	83 3d 40 72 23 f0 00 	cmpl   $0x0,0xf0237240
f0100b94:	74 0a                	je     f0100ba0 <check_page_free_list+0x24>
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100b96:	be 00 04 00 00       	mov    $0x400,%esi
f0100b9b:	e9 d1 02 00 00       	jmp    f0100e71 <check_page_free_list+0x2f5>
		panic("'page_free_list' is a null pointer!");
f0100ba0:	83 ec 04             	sub    $0x4,%esp
f0100ba3:	68 bc 6c 10 f0       	push   $0xf0106cbc
f0100ba8:	68 dc 02 00 00       	push   $0x2dc
f0100bad:	68 91 69 10 f0       	push   $0xf0106991
f0100bb2:	e8 dd f4 ff ff       	call   f0100094 <_panic>
f0100bb7:	50                   	push   %eax
f0100bb8:	68 54 64 10 f0       	push   $0xf0106454
f0100bbd:	6a 58                	push   $0x58
f0100bbf:	68 a4 69 10 f0       	push   $0xf01069a4
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
f0100bd1:	2b 05 90 7e 23 f0    	sub    0xf0237e90,%eax
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
f0100beb:	3b 15 88 7e 23 f0    	cmp    0xf0237e88,%edx
f0100bf1:	73 c4                	jae    f0100bb7 <check_page_free_list+0x3b>
			memset(page2kva(pp), 0x97, 128);
f0100bf3:	83 ec 04             	sub    $0x4,%esp
f0100bf6:	68 80 00 00 00       	push   $0x80
f0100bfb:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0100c00:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c05:	50                   	push   %eax
f0100c06:	e8 4f 4b 00 00       	call   f010575a <memset>
f0100c0b:	83 c4 10             	add    $0x10,%esp
f0100c0e:	eb b9                	jmp    f0100bc9 <check_page_free_list+0x4d>
	first_free_page = (char *) boot_alloc(0);
f0100c10:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c15:	e8 81 fe ff ff       	call   f0100a9b <boot_alloc>
f0100c1a:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c1d:	8b 15 40 72 23 f0    	mov    0xf0237240,%edx
		assert(pp >= pages);
f0100c23:	8b 0d 90 7e 23 f0    	mov    0xf0237e90,%ecx
		assert(pp < pages + npages);
f0100c29:	a1 88 7e 23 f0       	mov    0xf0237e88,%eax
f0100c2e:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100c31:	8d 34 c1             	lea    (%ecx,%eax,8),%esi
	int nfree_basemem = 0, nfree_extmem = 0;
f0100c34:	bf 00 00 00 00       	mov    $0x0,%edi
f0100c39:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c3c:	e9 f9 00 00 00       	jmp    f0100d3a <check_page_free_list+0x1be>
		assert(pp >= pages);
f0100c41:	68 b2 69 10 f0       	push   $0xf01069b2
f0100c46:	68 be 69 10 f0       	push   $0xf01069be
f0100c4b:	68 f9 02 00 00       	push   $0x2f9
f0100c50:	68 91 69 10 f0       	push   $0xf0106991
f0100c55:	e8 3a f4 ff ff       	call   f0100094 <_panic>
		assert(pp < pages + npages);
f0100c5a:	68 d3 69 10 f0       	push   $0xf01069d3
f0100c5f:	68 be 69 10 f0       	push   $0xf01069be
f0100c64:	68 fa 02 00 00       	push   $0x2fa
f0100c69:	68 91 69 10 f0       	push   $0xf0106991
f0100c6e:	e8 21 f4 ff ff       	call   f0100094 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100c73:	68 e0 6c 10 f0       	push   $0xf0106ce0
f0100c78:	68 be 69 10 f0       	push   $0xf01069be
f0100c7d:	68 fb 02 00 00       	push   $0x2fb
f0100c82:	68 91 69 10 f0       	push   $0xf0106991
f0100c87:	e8 08 f4 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != 0);
f0100c8c:	68 e7 69 10 f0       	push   $0xf01069e7
f0100c91:	68 be 69 10 f0       	push   $0xf01069be
f0100c96:	68 fe 02 00 00       	push   $0x2fe
f0100c9b:	68 91 69 10 f0       	push   $0xf0106991
f0100ca0:	e8 ef f3 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100ca5:	68 f8 69 10 f0       	push   $0xf01069f8
f0100caa:	68 be 69 10 f0       	push   $0xf01069be
f0100caf:	68 ff 02 00 00       	push   $0x2ff
f0100cb4:	68 91 69 10 f0       	push   $0xf0106991
f0100cb9:	e8 d6 f3 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100cbe:	68 14 6d 10 f0       	push   $0xf0106d14
f0100cc3:	68 be 69 10 f0       	push   $0xf01069be
f0100cc8:	68 00 03 00 00       	push   $0x300
f0100ccd:	68 91 69 10 f0       	push   $0xf0106991
f0100cd2:	e8 bd f3 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100cd7:	68 11 6a 10 f0       	push   $0xf0106a11
f0100cdc:	68 be 69 10 f0       	push   $0xf01069be
f0100ce1:	68 01 03 00 00       	push   $0x301
f0100ce6:	68 91 69 10 f0       	push   $0xf0106991
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
f0100d0a:	68 54 64 10 f0       	push   $0xf0106454
f0100d0f:	6a 58                	push   $0x58
f0100d11:	68 a4 69 10 f0       	push   $0xf01069a4
f0100d16:	e8 79 f3 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100d1b:	68 38 6d 10 f0       	push   $0xf0106d38
f0100d20:	68 be 69 10 f0       	push   $0xf01069be
f0100d25:	68 02 03 00 00       	push   $0x302
f0100d2a:	68 91 69 10 f0       	push   $0xf0106991
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
f0100d99:	68 2b 6a 10 f0       	push   $0xf0106a2b
f0100d9e:	68 be 69 10 f0       	push   $0xf01069be
f0100da3:	68 04 03 00 00       	push   $0x304
f0100da8:	68 91 69 10 f0       	push   $0xf0106991
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
f0100dc0:	68 80 6d 10 f0       	push   $0xf0106d80
f0100dc5:	e8 32 2b 00 00       	call   f01038fc <cprintf>
}
f0100dca:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100dcd:	5b                   	pop    %ebx
f0100dce:	5e                   	pop    %esi
f0100dcf:	5f                   	pop    %edi
f0100dd0:	5d                   	pop    %ebp
f0100dd1:	c3                   	ret    
	assert(nfree_basemem > 0);
f0100dd2:	68 48 6a 10 f0       	push   $0xf0106a48
f0100dd7:	68 be 69 10 f0       	push   $0xf01069be
f0100ddc:	68 0c 03 00 00       	push   $0x30c
f0100de1:	68 91 69 10 f0       	push   $0xf0106991
f0100de6:	e8 a9 f2 ff ff       	call   f0100094 <_panic>
	assert(nfree_extmem > 0);
f0100deb:	68 5a 6a 10 f0       	push   $0xf0106a5a
f0100df0:	68 be 69 10 f0       	push   $0xf01069be
f0100df5:	68 0d 03 00 00       	push   $0x30d
f0100dfa:	68 91 69 10 f0       	push   $0xf0106991
f0100dff:	e8 90 f2 ff ff       	call   f0100094 <_panic>
	if (!page_free_list)
f0100e04:	a1 40 72 23 f0       	mov    0xf0237240,%eax
f0100e09:	85 c0                	test   %eax,%eax
f0100e0b:	0f 84 8f fd ff ff    	je     f0100ba0 <check_page_free_list+0x24>
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100e11:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100e14:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100e17:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100e1a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100e1d:	89 c2                	mov    %eax,%edx
f0100e1f:	2b 15 90 7e 23 f0    	sub    0xf0237e90,%edx
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
f0100e46:	68 9d 69 10 f0       	push   $0xf010699d
f0100e4b:	e8 ac 2a 00 00       	call   f01038fc <cprintf>
		*tp[1] = 0;
f0100e50:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100e53:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100e59:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100e5c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100e5f:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100e61:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100e64:	a3 40 72 23 f0       	mov    %eax,0xf0237240
f0100e69:	83 c4 10             	add    $0x10,%esp
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100e6c:	be 01 00 00 00       	mov    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100e71:	8b 1d 40 72 23 f0    	mov    0xf0237240,%ebx
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
f0100e85:	a1 90 7e 23 f0       	mov    0xf0237e90,%eax
f0100e8a:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
    for (i = 1; i < npages_basemem; i++) {
f0100e90:	8b 35 44 72 23 f0    	mov    0xf0237244,%esi
f0100e96:	8b 1d 40 72 23 f0    	mov    0xf0237240,%ebx
f0100e9c:	ba 00 00 00 00       	mov    $0x0,%edx
f0100ea1:	b8 01 00 00 00       	mov    $0x1,%eax
        page_free_list = &pages[i];
f0100ea6:	bf 01 00 00 00       	mov    $0x1,%edi
    for (i = 1; i < npages_basemem; i++) {
f0100eab:	eb 0f                	jmp    f0100ebc <page_init+0x40>
			 pages[i].pp_ref = 1;
f0100ead:	8b 0d 90 7e 23 f0    	mov    0xf0237e90,%ecx
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
f0100ece:	03 0d 90 7e 23 f0    	add    0xf0237e90,%ecx
f0100ed4:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
        pages[i].pp_link = page_free_list;
f0100eda:	89 19                	mov    %ebx,(%ecx)
        page_free_list = &pages[i];
f0100edc:	89 d3                	mov    %edx,%ebx
f0100ede:	03 1d 90 7e 23 f0    	add    0xf0237e90,%ebx
f0100ee4:	89 fa                	mov    %edi,%edx
f0100ee6:	eb d1                	jmp    f0100eb9 <page_init+0x3d>
f0100ee8:	84 d2                	test   %dl,%dl
f0100eea:	74 06                	je     f0100ef2 <page_init+0x76>
f0100eec:	89 1d 40 72 23 f0    	mov    %ebx,0xf0237240
	size_t first_free_address = PADDR(boot_alloc(0));
f0100ef2:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ef7:	e8 9f fb ff ff       	call   f0100a9b <boot_alloc>
	if ((uint32_t)kva < KERNBASE)
f0100efc:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100f01:	76 3b                	jbe    f0100f3e <page_init+0xc2>
	return (physaddr_t)kva - KERNBASE;
f0100f03:	8d 88 00 00 00 10    	lea    0x10000000(%eax),%ecx
        pages[i].pp_ref = 1;
f0100f09:	8b 15 90 7e 23 f0    	mov    0xf0237e90,%edx
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
f0100f2c:	8b 1d 40 72 23 f0    	mov    0xf0237240,%ebx
f0100f32:	ba 00 00 00 00       	mov    $0x0,%edx
f0100f37:	be 01 00 00 00       	mov    $0x1,%esi
f0100f3c:	eb 39                	jmp    f0100f77 <page_init+0xfb>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100f3e:	50                   	push   %eax
f0100f3f:	68 78 64 10 f0       	push   $0xf0106478
f0100f44:	68 5d 01 00 00       	push   $0x15d
f0100f49:	68 91 69 10 f0       	push   $0xf0106991
f0100f4e:	e8 41 f1 ff ff       	call   f0100094 <_panic>
f0100f53:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
        pages[i].pp_ref = 0;
f0100f5a:	89 d1                	mov    %edx,%ecx
f0100f5c:	03 0d 90 7e 23 f0    	add    0xf0237e90,%ecx
f0100f62:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
        pages[i].pp_link = page_free_list;
f0100f68:	89 19                	mov    %ebx,(%ecx)
    for (i = first_free_address/PGSIZE; i < npages; i++) {
f0100f6a:	83 c0 01             	add    $0x1,%eax
        page_free_list = &pages[i];
f0100f6d:	89 d3                	mov    %edx,%ebx
f0100f6f:	03 1d 90 7e 23 f0    	add    0xf0237e90,%ebx
f0100f75:	89 f2                	mov    %esi,%edx
    for (i = first_free_address/PGSIZE; i < npages; i++) {
f0100f77:	39 05 88 7e 23 f0    	cmp    %eax,0xf0237e88
f0100f7d:	77 d4                	ja     f0100f53 <page_init+0xd7>
f0100f7f:	84 d2                	test   %dl,%dl
f0100f81:	74 06                	je     f0100f89 <page_init+0x10d>
f0100f83:	89 1d 40 72 23 f0    	mov    %ebx,0xf0237240
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
f0100f98:	8b 1d 40 72 23 f0    	mov    0xf0237240,%ebx
f0100f9e:	85 db                	test   %ebx,%ebx
f0100fa0:	74 13                	je     f0100fb5 <page_alloc+0x24>
	page_free_list = page->pp_link;
f0100fa2:	8b 03                	mov    (%ebx),%eax
f0100fa4:	a3 40 72 23 f0       	mov    %eax,0xf0237240
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
f0100fbe:	2b 05 90 7e 23 f0    	sub    0xf0237e90,%eax
f0100fc4:	c1 f8 03             	sar    $0x3,%eax
f0100fc7:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0100fca:	89 c2                	mov    %eax,%edx
f0100fcc:	c1 ea 0c             	shr    $0xc,%edx
f0100fcf:	3b 15 88 7e 23 f0    	cmp    0xf0237e88,%edx
f0100fd5:	73 1a                	jae    f0100ff1 <page_alloc+0x60>
		memset(page2kva(page), 0, PGSIZE); 
f0100fd7:	83 ec 04             	sub    $0x4,%esp
f0100fda:	68 00 10 00 00       	push   $0x1000
f0100fdf:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f0100fe1:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100fe6:	50                   	push   %eax
f0100fe7:	e8 6e 47 00 00       	call   f010575a <memset>
f0100fec:	83 c4 10             	add    $0x10,%esp
f0100fef:	eb c4                	jmp    f0100fb5 <page_alloc+0x24>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ff1:	50                   	push   %eax
f0100ff2:	68 54 64 10 f0       	push   $0xf0106454
f0100ff7:	6a 58                	push   $0x58
f0100ff9:	68 a4 69 10 f0       	push   $0xf01069a4
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
f0101018:	8b 15 40 72 23 f0    	mov    0xf0237240,%edx
f010101e:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0101020:	a3 40 72 23 f0       	mov    %eax,0xf0237240
}
f0101025:	c9                   	leave  
f0101026:	c3                   	ret    
		panic("page_free: double check failed when dealloc page. '\n");
f0101027:	83 ec 04             	sub    $0x4,%esp
f010102a:	68 a4 6d 10 f0       	push   $0xf0106da4
f010102f:	68 98 01 00 00       	push   $0x198
f0101034:	68 91 69 10 f0       	push   $0xf0106991
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
f0101097:	39 15 88 7e 23 f0    	cmp    %edx,0xf0237e88
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
f01010af:	68 54 64 10 f0       	push   $0xf0106454
f01010b4:	68 c8 01 00 00       	push   $0x1c8
f01010b9:	68 91 69 10 f0       	push   $0xf0106991
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
f01010df:	2b 05 90 7e 23 f0    	sub    0xf0237e90,%eax
f01010e5:	89 c2                	mov    %eax,%edx
f01010e7:	c1 fa 03             	sar    $0x3,%edx
f01010ea:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f01010ed:	89 d0                	mov    %edx,%eax
f01010ef:	c1 e8 0c             	shr    $0xc,%eax
f01010f2:	3b 05 88 7e 23 f0    	cmp    0xf0237e88,%eax
f01010f8:	73 0d                	jae    f0101107 <pgdir_walk+0xa0>
	return (void *)(pa + KERNBASE);
f01010fa:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
				pgdir[pdx] = page2pa(new_pginfo) | PTE_P | PTE_W | PTE_U;
f0101100:	83 ca 07             	or     $0x7,%edx
f0101103:	89 13                	mov    %edx,(%ebx)
f0101105:	eb 9d                	jmp    f01010a4 <pgdir_walk+0x3d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101107:	52                   	push   %edx
f0101108:	68 54 64 10 f0       	push   $0xf0106454
f010110d:	6a 58                	push   $0x58
f010110f:	68 a4 69 10 f0       	push   $0xf01069a4
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
f01011aa:	39 15 88 7e 23 f0    	cmp    %edx,0xf0237e88
f01011b0:	76 0a                	jbe    f01011bc <page_lookup+0x41>
		panic("pa2page called with invalid pa");
	return &pages[PGNUM(pa)];
f01011b2:	a1 90 7e 23 f0       	mov    0xf0237e90,%eax
f01011b7:	8d 04 d0             	lea    (%eax,%edx,8),%eax
			return pa2page(PTE_ADDR(*pte)); 
f01011ba:	eb e9                	jmp    f01011a5 <page_lookup+0x2a>
		panic("pa2page called with invalid pa");
f01011bc:	83 ec 04             	sub    $0x4,%esp
f01011bf:	68 dc 6d 10 f0       	push   $0xf0106ddc
f01011c4:	6a 51                	push   $0x51
f01011c6:	68 a4 69 10 f0       	push   $0xf01069a4
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
f01011dd:	e8 78 4b 00 00       	call   f0105d5a <cpunum>
f01011e2:	6b c0 74             	imul   $0x74,%eax,%eax
f01011e5:	83 b8 28 80 23 f0 00 	cmpl   $0x0,-0xfdc7fd8(%eax)
f01011ec:	74 16                	je     f0101204 <tlb_invalidate+0x2d>
f01011ee:	e8 67 4b 00 00       	call   f0105d5a <cpunum>
f01011f3:	6b c0 74             	imul   $0x74,%eax,%eax
f01011f6:	8b 80 28 80 23 f0    	mov    -0xfdc7fd8(%eax),%eax
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
f010127f:	2b 1d 90 7e 23 f0    	sub    0xf0237e90,%ebx
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
f01012ce:	8b 15 00 33 12 f0    	mov    0xf0123300,%edx
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
f01012eb:	a1 8c 7e 23 f0       	mov    0xf0237e8c,%eax
f01012f0:	e8 32 fe ff ff       	call   f0101127 <boot_map_region>
    uintptr_t return_base = base;
f01012f5:	a1 00 33 12 f0       	mov    0xf0123300,%eax
    base += rounded_size;
f01012fa:	01 c3                	add    %eax,%ebx
f01012fc:	89 1d 00 33 12 f0    	mov    %ebx,0xf0123300
}
f0101302:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101305:	c9                   	leave  
f0101306:	c3                   	ret    
    if (base + rounded_size > MMIOLIM || base + rounded_size < base) panic("memory overflow\n ");
f0101307:	83 ec 04             	sub    $0x4,%esp
f010130a:	68 6b 6a 10 f0       	push   $0xf0106a6b
f010130f:	68 86 02 00 00       	push   $0x286
f0101314:	68 91 69 10 f0       	push   $0xf0106991
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
f010135c:	89 15 88 7e 23 f0    	mov    %edx,0xf0237e88
	npages_basemem = basemem / (PGSIZE / 1024);
f0101362:	89 da                	mov    %ebx,%edx
f0101364:	c1 ea 02             	shr    $0x2,%edx
f0101367:	89 15 44 72 23 f0    	mov    %edx,0xf0237244
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010136d:	89 c2                	mov    %eax,%edx
f010136f:	29 da                	sub    %ebx,%edx
f0101371:	52                   	push   %edx
f0101372:	53                   	push   %ebx
f0101373:	50                   	push   %eax
f0101374:	68 fc 6d 10 f0       	push   $0xf0106dfc
f0101379:	e8 7e 25 00 00       	call   f01038fc <cprintf>
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f010137e:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101383:	e8 13 f7 ff ff       	call   f0100a9b <boot_alloc>
f0101388:	a3 8c 7e 23 f0       	mov    %eax,0xf0237e8c
	memset(kern_pgdir, 0, PGSIZE);
f010138d:	83 c4 0c             	add    $0xc,%esp
f0101390:	68 00 10 00 00       	push   $0x1000
f0101395:	6a 00                	push   $0x0
f0101397:	50                   	push   %eax
f0101398:	e8 bd 43 00 00       	call   f010575a <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f010139d:	a1 8c 7e 23 f0       	mov    0xf0237e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f01013a2:	83 c4 10             	add    $0x10,%esp
f01013a5:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01013aa:	0f 86 9c 00 00 00    	jbe    f010144c <mem_init+0x12e>
	return (physaddr_t)kva - KERNBASE;
f01013b0:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01013b6:	83 ca 05             	or     $0x5,%edx
f01013b9:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	pages = (struct PageInfo*) boot_alloc(npages * sizeof(struct PageInfo));
f01013bf:	a1 88 7e 23 f0       	mov    0xf0237e88,%eax
f01013c4:	c1 e0 03             	shl    $0x3,%eax
f01013c7:	e8 cf f6 ff ff       	call   f0100a9b <boot_alloc>
f01013cc:	a3 90 7e 23 f0       	mov    %eax,0xf0237e90
	memset(pages, 0, npages * sizeof(struct PageInfo));
f01013d1:	83 ec 04             	sub    $0x4,%esp
f01013d4:	8b 0d 88 7e 23 f0    	mov    0xf0237e88,%ecx
f01013da:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f01013e1:	52                   	push   %edx
f01013e2:	6a 00                	push   $0x0
f01013e4:	50                   	push   %eax
f01013e5:	e8 70 43 00 00       	call   f010575a <memset>
	envs = (struct Env*) boot_alloc(NENV * sizeof(struct Env));
f01013ea:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f01013ef:	e8 a7 f6 ff ff       	call   f0100a9b <boot_alloc>
f01013f4:	a3 48 72 23 f0       	mov    %eax,0xf0237248
	memset(envs, 0, NENV * sizeof(struct Env));
f01013f9:	83 c4 0c             	add    $0xc,%esp
f01013fc:	68 00 f0 01 00       	push   $0x1f000
f0101401:	6a 00                	push   $0x0
f0101403:	50                   	push   %eax
f0101404:	e8 51 43 00 00       	call   f010575a <memset>
	page_init();
f0101409:	e8 6e fa ff ff       	call   f0100e7c <page_init>
	check_page_free_list(1);
f010140e:	b8 01 00 00 00       	mov    $0x1,%eax
f0101413:	e8 64 f7 ff ff       	call   f0100b7c <check_page_free_list>
	if (!pages)
f0101418:	83 c4 10             	add    $0x10,%esp
f010141b:	83 3d 90 7e 23 f0 00 	cmpl   $0x0,0xf0237e90
f0101422:	74 3d                	je     f0101461 <mem_init+0x143>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101424:	a1 40 72 23 f0       	mov    0xf0237240,%eax
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
f010144d:	68 78 64 10 f0       	push   $0xf0106478
f0101452:	68 a4 00 00 00       	push   $0xa4
f0101457:	68 91 69 10 f0       	push   $0xf0106991
f010145c:	e8 33 ec ff ff       	call   f0100094 <_panic>
		panic("'pages' is a null pointer!");
f0101461:	83 ec 04             	sub    $0x4,%esp
f0101464:	68 7d 6a 10 f0       	push   $0xf0106a7d
f0101469:	68 20 03 00 00       	push   $0x320
f010146e:	68 91 69 10 f0       	push   $0xf0106991
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
f01014d5:	8b 0d 90 7e 23 f0    	mov    0xf0237e90,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f01014db:	8b 15 88 7e 23 f0    	mov    0xf0237e88,%edx
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
f010151a:	a1 40 72 23 f0       	mov    0xf0237240,%eax
f010151f:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101522:	c7 05 40 72 23 f0 00 	movl   $0x0,0xf0237240
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
f01015d0:	2b 05 90 7e 23 f0    	sub    0xf0237e90,%eax
f01015d6:	c1 f8 03             	sar    $0x3,%eax
f01015d9:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f01015dc:	89 c2                	mov    %eax,%edx
f01015de:	c1 ea 0c             	shr    $0xc,%edx
f01015e1:	3b 15 88 7e 23 f0    	cmp    0xf0237e88,%edx
f01015e7:	0f 83 19 02 00 00    	jae    f0101806 <mem_init+0x4e8>
	memset(page2kva(pp0), 1, PGSIZE);
f01015ed:	83 ec 04             	sub    $0x4,%esp
f01015f0:	68 00 10 00 00       	push   $0x1000
f01015f5:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f01015f7:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01015fc:	50                   	push   %eax
f01015fd:	e8 58 41 00 00       	call   f010575a <memset>
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
f0101629:	2b 05 90 7e 23 f0    	sub    0xf0237e90,%eax
f010162f:	c1 f8 03             	sar    $0x3,%eax
f0101632:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0101635:	89 c2                	mov    %eax,%edx
f0101637:	c1 ea 0c             	shr    $0xc,%edx
f010163a:	3b 15 88 7e 23 f0    	cmp    0xf0237e88,%edx
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
f0101664:	a3 40 72 23 f0       	mov    %eax,0xf0237240
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
f0101682:	a1 40 72 23 f0       	mov    0xf0237240,%eax
f0101687:	83 c4 10             	add    $0x10,%esp
f010168a:	e9 ec 01 00 00       	jmp    f010187b <mem_init+0x55d>
	assert((pp0 = page_alloc(0)));
f010168f:	68 98 6a 10 f0       	push   $0xf0106a98
f0101694:	68 be 69 10 f0       	push   $0xf01069be
f0101699:	68 28 03 00 00       	push   $0x328
f010169e:	68 91 69 10 f0       	push   $0xf0106991
f01016a3:	e8 ec e9 ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f01016a8:	68 ae 6a 10 f0       	push   $0xf0106aae
f01016ad:	68 be 69 10 f0       	push   $0xf01069be
f01016b2:	68 29 03 00 00       	push   $0x329
f01016b7:	68 91 69 10 f0       	push   $0xf0106991
f01016bc:	e8 d3 e9 ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f01016c1:	68 c4 6a 10 f0       	push   $0xf0106ac4
f01016c6:	68 be 69 10 f0       	push   $0xf01069be
f01016cb:	68 2a 03 00 00       	push   $0x32a
f01016d0:	68 91 69 10 f0       	push   $0xf0106991
f01016d5:	e8 ba e9 ff ff       	call   f0100094 <_panic>
	assert(pp1 && pp1 != pp0);
f01016da:	68 da 6a 10 f0       	push   $0xf0106ada
f01016df:	68 be 69 10 f0       	push   $0xf01069be
f01016e4:	68 2d 03 00 00       	push   $0x32d
f01016e9:	68 91 69 10 f0       	push   $0xf0106991
f01016ee:	e8 a1 e9 ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01016f3:	68 38 6e 10 f0       	push   $0xf0106e38
f01016f8:	68 be 69 10 f0       	push   $0xf01069be
f01016fd:	68 2e 03 00 00       	push   $0x32e
f0101702:	68 91 69 10 f0       	push   $0xf0106991
f0101707:	e8 88 e9 ff ff       	call   f0100094 <_panic>
	assert(page2pa(pp0) < npages*PGSIZE);
f010170c:	68 ec 6a 10 f0       	push   $0xf0106aec
f0101711:	68 be 69 10 f0       	push   $0xf01069be
f0101716:	68 2f 03 00 00       	push   $0x32f
f010171b:	68 91 69 10 f0       	push   $0xf0106991
f0101720:	e8 6f e9 ff ff       	call   f0100094 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0101725:	68 09 6b 10 f0       	push   $0xf0106b09
f010172a:	68 be 69 10 f0       	push   $0xf01069be
f010172f:	68 30 03 00 00       	push   $0x330
f0101734:	68 91 69 10 f0       	push   $0xf0106991
f0101739:	e8 56 e9 ff ff       	call   f0100094 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f010173e:	68 26 6b 10 f0       	push   $0xf0106b26
f0101743:	68 be 69 10 f0       	push   $0xf01069be
f0101748:	68 31 03 00 00       	push   $0x331
f010174d:	68 91 69 10 f0       	push   $0xf0106991
f0101752:	e8 3d e9 ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f0101757:	68 43 6b 10 f0       	push   $0xf0106b43
f010175c:	68 be 69 10 f0       	push   $0xf01069be
f0101761:	68 38 03 00 00       	push   $0x338
f0101766:	68 91 69 10 f0       	push   $0xf0106991
f010176b:	e8 24 e9 ff ff       	call   f0100094 <_panic>
	assert((pp0 = page_alloc(0)));
f0101770:	68 98 6a 10 f0       	push   $0xf0106a98
f0101775:	68 be 69 10 f0       	push   $0xf01069be
f010177a:	68 3f 03 00 00       	push   $0x33f
f010177f:	68 91 69 10 f0       	push   $0xf0106991
f0101784:	e8 0b e9 ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f0101789:	68 ae 6a 10 f0       	push   $0xf0106aae
f010178e:	68 be 69 10 f0       	push   $0xf01069be
f0101793:	68 40 03 00 00       	push   $0x340
f0101798:	68 91 69 10 f0       	push   $0xf0106991
f010179d:	e8 f2 e8 ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f01017a2:	68 c4 6a 10 f0       	push   $0xf0106ac4
f01017a7:	68 be 69 10 f0       	push   $0xf01069be
f01017ac:	68 41 03 00 00       	push   $0x341
f01017b1:	68 91 69 10 f0       	push   $0xf0106991
f01017b6:	e8 d9 e8 ff ff       	call   f0100094 <_panic>
	assert(pp1 && pp1 != pp0);
f01017bb:	68 da 6a 10 f0       	push   $0xf0106ada
f01017c0:	68 be 69 10 f0       	push   $0xf01069be
f01017c5:	68 43 03 00 00       	push   $0x343
f01017ca:	68 91 69 10 f0       	push   $0xf0106991
f01017cf:	e8 c0 e8 ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01017d4:	68 38 6e 10 f0       	push   $0xf0106e38
f01017d9:	68 be 69 10 f0       	push   $0xf01069be
f01017de:	68 44 03 00 00       	push   $0x344
f01017e3:	68 91 69 10 f0       	push   $0xf0106991
f01017e8:	e8 a7 e8 ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f01017ed:	68 43 6b 10 f0       	push   $0xf0106b43
f01017f2:	68 be 69 10 f0       	push   $0xf01069be
f01017f7:	68 45 03 00 00       	push   $0x345
f01017fc:	68 91 69 10 f0       	push   $0xf0106991
f0101801:	e8 8e e8 ff ff       	call   f0100094 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101806:	50                   	push   %eax
f0101807:	68 54 64 10 f0       	push   $0xf0106454
f010180c:	6a 58                	push   $0x58
f010180e:	68 a4 69 10 f0       	push   $0xf01069a4
f0101813:	e8 7c e8 ff ff       	call   f0100094 <_panic>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101818:	68 52 6b 10 f0       	push   $0xf0106b52
f010181d:	68 be 69 10 f0       	push   $0xf01069be
f0101822:	68 4a 03 00 00       	push   $0x34a
f0101827:	68 91 69 10 f0       	push   $0xf0106991
f010182c:	e8 63 e8 ff ff       	call   f0100094 <_panic>
	assert(pp && pp0 == pp);
f0101831:	68 70 6b 10 f0       	push   $0xf0106b70
f0101836:	68 be 69 10 f0       	push   $0xf01069be
f010183b:	68 4b 03 00 00       	push   $0x34b
f0101840:	68 91 69 10 f0       	push   $0xf0106991
f0101845:	e8 4a e8 ff ff       	call   f0100094 <_panic>
f010184a:	50                   	push   %eax
f010184b:	68 54 64 10 f0       	push   $0xf0106454
f0101850:	6a 58                	push   $0x58
f0101852:	68 a4 69 10 f0       	push   $0xf01069a4
f0101857:	e8 38 e8 ff ff       	call   f0100094 <_panic>
		assert(c[i] == 0);
f010185c:	68 80 6b 10 f0       	push   $0xf0106b80
f0101861:	68 be 69 10 f0       	push   $0xf01069be
f0101866:	68 4e 03 00 00       	push   $0x34e
f010186b:	68 91 69 10 f0       	push   $0xf0106991
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
f010188c:	68 58 6e 10 f0       	push   $0xf0106e58
f0101891:	e8 66 20 00 00       	call   f01038fc <cprintf>
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
f01018f8:	a1 40 72 23 f0       	mov    0xf0237240,%eax
f01018fd:	89 45 cc             	mov    %eax,-0x34(%ebp)
	page_free_list = 0;
f0101900:	c7 05 40 72 23 f0 00 	movl   $0x0,0xf0237240
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
f0101928:	ff 35 8c 7e 23 f0    	pushl  0xf0237e8c
f010192e:	e8 48 f8 ff ff       	call   f010117b <page_lookup>
f0101933:	83 c4 10             	add    $0x10,%esp
f0101936:	85 c0                	test   %eax,%eax
f0101938:	0f 85 5f 09 00 00    	jne    f010229d <mem_init+0xf7f>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f010193e:	6a 02                	push   $0x2
f0101940:	6a 00                	push   $0x0
f0101942:	57                   	push   %edi
f0101943:	ff 35 8c 7e 23 f0    	pushl  0xf0237e8c
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
f0101969:	ff 35 8c 7e 23 f0    	pushl  0xf0237e8c
f010196f:	e8 de f8 ff ff       	call   f0101252 <page_insert>
f0101974:	83 c4 20             	add    $0x20,%esp
f0101977:	85 c0                	test   %eax,%eax
f0101979:	0f 85 50 09 00 00    	jne    f01022cf <mem_init+0xfb1>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010197f:	8b 35 8c 7e 23 f0    	mov    0xf0237e8c,%esi
	return (pp - pages) << PGSHIFT;
f0101985:	8b 0d 90 7e 23 f0    	mov    0xf0237e90,%ecx
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
f01019ff:	a1 8c 7e 23 f0       	mov    0xf0237e8c,%eax
f0101a04:	e8 0f f1 ff ff       	call   f0100b18 <check_va2pa>
f0101a09:	89 da                	mov    %ebx,%edx
f0101a0b:	2b 15 90 7e 23 f0    	sub    0xf0237e90,%edx
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
f0101a47:	ff 35 8c 7e 23 f0    	pushl  0xf0237e8c
f0101a4d:	e8 00 f8 ff ff       	call   f0101252 <page_insert>
f0101a52:	83 c4 10             	add    $0x10,%esp
f0101a55:	85 c0                	test   %eax,%eax
f0101a57:	0f 85 53 09 00 00    	jne    f01023b0 <mem_init+0x1092>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101a5d:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101a62:	a1 8c 7e 23 f0       	mov    0xf0237e8c,%eax
f0101a67:	e8 ac f0 ff ff       	call   f0100b18 <check_va2pa>
f0101a6c:	89 da                	mov    %ebx,%edx
f0101a6e:	2b 15 90 7e 23 f0    	sub    0xf0237e90,%edx
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
f0101aa2:	8b 15 8c 7e 23 f0    	mov    0xf0237e8c,%edx
f0101aa8:	8b 02                	mov    (%edx),%eax
f0101aaa:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0101aaf:	89 c1                	mov    %eax,%ecx
f0101ab1:	c1 e9 0c             	shr    $0xc,%ecx
f0101ab4:	3b 0d 88 7e 23 f0    	cmp    0xf0237e88,%ecx
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
f0101af1:	ff 35 8c 7e 23 f0    	pushl  0xf0237e8c
f0101af7:	e8 56 f7 ff ff       	call   f0101252 <page_insert>
f0101afc:	83 c4 10             	add    $0x10,%esp
f0101aff:	85 c0                	test   %eax,%eax
f0101b01:	0f 85 3b 09 00 00    	jne    f0102442 <mem_init+0x1124>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101b07:	8b 35 8c 7e 23 f0    	mov    0xf0237e8c,%esi
f0101b0d:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101b12:	89 f0                	mov    %esi,%eax
f0101b14:	e8 ff ef ff ff       	call   f0100b18 <check_va2pa>
	return (pp - pages) << PGSHIFT;
f0101b19:	89 da                	mov    %ebx,%edx
f0101b1b:	2b 15 90 7e 23 f0    	sub    0xf0237e90,%edx
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
f0101b56:	a1 8c 7e 23 f0       	mov    0xf0237e8c,%eax
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
f0101b87:	ff 35 8c 7e 23 f0    	pushl  0xf0237e8c
f0101b8d:	e8 d5 f4 ff ff       	call   f0101067 <pgdir_walk>
f0101b92:	83 c4 10             	add    $0x10,%esp
f0101b95:	f6 00 02             	testb  $0x2,(%eax)
f0101b98:	0f 84 3a 09 00 00    	je     f01024d8 <mem_init+0x11ba>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101b9e:	83 ec 04             	sub    $0x4,%esp
f0101ba1:	6a 00                	push   $0x0
f0101ba3:	68 00 10 00 00       	push   $0x1000
f0101ba8:	ff 35 8c 7e 23 f0    	pushl  0xf0237e8c
f0101bae:	e8 b4 f4 ff ff       	call   f0101067 <pgdir_walk>
f0101bb3:	83 c4 10             	add    $0x10,%esp
f0101bb6:	f6 00 04             	testb  $0x4,(%eax)
f0101bb9:	0f 85 32 09 00 00    	jne    f01024f1 <mem_init+0x11d3>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101bbf:	6a 02                	push   $0x2
f0101bc1:	68 00 00 40 00       	push   $0x400000
f0101bc6:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101bc9:	ff 35 8c 7e 23 f0    	pushl  0xf0237e8c
f0101bcf:	e8 7e f6 ff ff       	call   f0101252 <page_insert>
f0101bd4:	83 c4 10             	add    $0x10,%esp
f0101bd7:	85 c0                	test   %eax,%eax
f0101bd9:	0f 89 2b 09 00 00    	jns    f010250a <mem_init+0x11ec>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101bdf:	6a 02                	push   $0x2
f0101be1:	68 00 10 00 00       	push   $0x1000
f0101be6:	57                   	push   %edi
f0101be7:	ff 35 8c 7e 23 f0    	pushl  0xf0237e8c
f0101bed:	e8 60 f6 ff ff       	call   f0101252 <page_insert>
f0101bf2:	83 c4 10             	add    $0x10,%esp
f0101bf5:	85 c0                	test   %eax,%eax
f0101bf7:	0f 85 26 09 00 00    	jne    f0102523 <mem_init+0x1205>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101bfd:	83 ec 04             	sub    $0x4,%esp
f0101c00:	6a 00                	push   $0x0
f0101c02:	68 00 10 00 00       	push   $0x1000
f0101c07:	ff 35 8c 7e 23 f0    	pushl  0xf0237e8c
f0101c0d:	e8 55 f4 ff ff       	call   f0101067 <pgdir_walk>
f0101c12:	83 c4 10             	add    $0x10,%esp
f0101c15:	f6 00 04             	testb  $0x4,(%eax)
f0101c18:	0f 85 1e 09 00 00    	jne    f010253c <mem_init+0x121e>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101c1e:	a1 8c 7e 23 f0       	mov    0xf0237e8c,%eax
f0101c23:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101c26:	ba 00 00 00 00       	mov    $0x0,%edx
f0101c2b:	e8 e8 ee ff ff       	call   f0100b18 <check_va2pa>
f0101c30:	89 fe                	mov    %edi,%esi
f0101c32:	2b 35 90 7e 23 f0    	sub    0xf0237e90,%esi
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
f0101c93:	ff 35 8c 7e 23 f0    	pushl  0xf0237e8c
f0101c99:	e8 6e f5 ff ff       	call   f010120c <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101c9e:	8b 35 8c 7e 23 f0    	mov    0xf0237e8c,%esi
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
f0101cca:	2b 15 90 7e 23 f0    	sub    0xf0237e90,%edx
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
f0101d29:	ff 35 8c 7e 23 f0    	pushl  0xf0237e8c
f0101d2f:	e8 d8 f4 ff ff       	call   f010120c <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101d34:	8b 35 8c 7e 23 f0    	mov    0xf0237e8c,%esi
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
f0101daf:	8b 0d 8c 7e 23 f0    	mov    0xf0237e8c,%ecx
f0101db5:	8b 11                	mov    (%ecx),%edx
f0101db7:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101dbd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101dc0:	2b 05 90 7e 23 f0    	sub    0xf0237e90,%eax
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
f0101e04:	ff 35 8c 7e 23 f0    	pushl  0xf0237e8c
f0101e0a:	e8 58 f2 ff ff       	call   f0101067 <pgdir_walk>
f0101e0f:	89 c1                	mov    %eax,%ecx
f0101e11:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0101e14:	a1 8c 7e 23 f0       	mov    0xf0237e8c,%eax
f0101e19:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101e1c:	8b 40 04             	mov    0x4(%eax),%eax
f0101e1f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0101e24:	8b 35 88 7e 23 f0    	mov    0xf0237e88,%esi
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
f0101e5a:	2b 05 90 7e 23 f0    	sub    0xf0237e90,%eax
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
f0101e86:	e8 cf 38 00 00       	call   f010575a <memset>
	page_free(pp0);
f0101e8b:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0101e8e:	89 34 24             	mov    %esi,(%esp)
f0101e91:	e8 6d f1 ff ff       	call   f0101003 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0101e96:	83 c4 0c             	add    $0xc,%esp
f0101e99:	6a 01                	push   $0x1
f0101e9b:	6a 00                	push   $0x0
f0101e9d:	ff 35 8c 7e 23 f0    	pushl  0xf0237e8c
f0101ea3:	e8 bf f1 ff ff       	call   f0101067 <pgdir_walk>
	return (pp - pages) << PGSHIFT;
f0101ea8:	89 f0                	mov    %esi,%eax
f0101eaa:	2b 05 90 7e 23 f0    	sub    0xf0237e90,%eax
f0101eb0:	c1 f8 03             	sar    $0x3,%eax
f0101eb3:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0101eb6:	89 c2                	mov    %eax,%edx
f0101eb8:	c1 ea 0c             	shr    $0xc,%edx
f0101ebb:	83 c4 10             	add    $0x10,%esp
f0101ebe:	3b 15 88 7e 23 f0    	cmp    0xf0237e88,%edx
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
f0101ee8:	a1 8c 7e 23 f0       	mov    0xf0237e8c,%eax
f0101eed:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0101ef3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ef6:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0101efc:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0101eff:	89 0d 40 72 23 f0    	mov    %ecx,0xf0237240

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
f0101f96:	8b 3d 8c 7e 23 f0    	mov    0xf0237e8c,%edi
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
f010200f:	ff 35 8c 7e 23 f0    	pushl  0xf0237e8c
f0102015:	e8 4d f0 ff ff       	call   f0101067 <pgdir_walk>
f010201a:	83 c4 10             	add    $0x10,%esp
f010201d:	f6 00 04             	testb  $0x4,(%eax)
f0102020:	0f 85 6f 08 00 00    	jne    f0102895 <mem_init+0x1577>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f0102026:	83 ec 04             	sub    $0x4,%esp
f0102029:	6a 00                	push   $0x0
f010202b:	53                   	push   %ebx
f010202c:	ff 35 8c 7e 23 f0    	pushl  0xf0237e8c
f0102032:	e8 30 f0 ff ff       	call   f0101067 <pgdir_walk>
f0102037:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f010203d:	83 c4 0c             	add    $0xc,%esp
f0102040:	6a 00                	push   $0x0
f0102042:	ff 75 d4             	pushl  -0x2c(%ebp)
f0102045:	ff 35 8c 7e 23 f0    	pushl  0xf0237e8c
f010204b:	e8 17 f0 ff ff       	call   f0101067 <pgdir_walk>
f0102050:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f0102056:	83 c4 0c             	add    $0xc,%esp
f0102059:	6a 00                	push   $0x0
f010205b:	56                   	push   %esi
f010205c:	ff 35 8c 7e 23 f0    	pushl  0xf0237e8c
f0102062:	e8 00 f0 ff ff       	call   f0101067 <pgdir_walk>
f0102067:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f010206d:	c7 04 24 73 6c 10 f0 	movl   $0xf0106c73,(%esp)
f0102074:	e8 83 18 00 00       	call   f01038fc <cprintf>
	boot_map_region(kern_pgdir, (uintptr_t) UPAGES, npages*sizeof(struct PageInfo), PADDR(pages), PTE_U | PTE_P);
f0102079:	a1 90 7e 23 f0       	mov    0xf0237e90,%eax
	if ((uint32_t)kva < KERNBASE)
f010207e:	83 c4 10             	add    $0x10,%esp
f0102081:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102086:	0f 86 22 08 00 00    	jbe    f01028ae <mem_init+0x1590>
f010208c:	8b 0d 88 7e 23 f0    	mov    0xf0237e88,%ecx
f0102092:	c1 e1 03             	shl    $0x3,%ecx
f0102095:	83 ec 08             	sub    $0x8,%esp
f0102098:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f010209a:	05 00 00 00 10       	add    $0x10000000,%eax
f010209f:	50                   	push   %eax
f01020a0:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f01020a5:	a1 8c 7e 23 f0       	mov    0xf0237e8c,%eax
f01020aa:	e8 78 f0 ff ff       	call   f0101127 <boot_map_region>
	boot_map_region(kern_pgdir, (uintptr_t) UENVS, ROUNDUP(NENV * sizeof(struct Env), PGSIZE), PADDR(envs), PTE_U | PTE_P);
f01020af:	a1 48 72 23 f0       	mov    0xf0237248,%eax
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
f01020d7:	a1 8c 7e 23 f0       	mov    0xf0237e8c,%eax
f01020dc:	e8 46 f0 ff ff       	call   f0101127 <boot_map_region>
	if ((uint32_t)kva < KERNBASE)
f01020e1:	83 c4 10             	add    $0x10,%esp
f01020e4:	b8 00 90 11 f0       	mov    $0xf0119000,%eax
f01020e9:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01020ee:	0f 86 e4 07 00 00    	jbe    f01028d8 <mem_init+0x15ba>
	boot_map_region(kern_pgdir, (uintptr_t) (KSTACKTOP-KSTKSIZE), KSTKSIZE, PADDR(bootstack), PTE_W | PTE_P);
f01020f4:	83 ec 08             	sub    $0x8,%esp
f01020f7:	6a 03                	push   $0x3
f01020f9:	68 00 90 11 00       	push   $0x119000
f01020fe:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102103:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102108:	a1 8c 7e 23 f0       	mov    0xf0237e8c,%eax
f010210d:	e8 15 f0 ff ff       	call   f0101127 <boot_map_region>
	boot_map_region(kern_pgdir, (uintptr_t) KERNBASE, ROUNDUP(0xffffffff - KERNBASE, PGSIZE), 0, PTE_W | PTE_P);
f0102112:	83 c4 08             	add    $0x8,%esp
f0102115:	6a 03                	push   $0x3
f0102117:	6a 00                	push   $0x0
f0102119:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f010211e:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102123:	a1 8c 7e 23 f0       	mov    0xf0237e8c,%eax
f0102128:	e8 fa ef ff ff       	call   f0101127 <boot_map_region>
f010212d:	c7 45 d0 00 90 23 f0 	movl   $0xf0239000,-0x30(%ebp)
f0102134:	83 c4 10             	add    $0x10,%esp
f0102137:	bb 00 90 23 f0       	mov    $0xf0239000,%ebx
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
f0102160:	a1 8c 7e 23 f0       	mov    0xf0237e8c,%eax
f0102165:	e8 bd ef ff ff       	call   f0101127 <boot_map_region>
        start_addr -= KSTKSIZE + KSTKGAP;
f010216a:	81 ee 00 00 01 00    	sub    $0x10000,%esi
f0102170:	81 c3 00 80 00 00    	add    $0x8000,%ebx
    for (i = 0; i < NCPU; i++) {
f0102176:	83 c4 10             	add    $0x10,%esp
f0102179:	81 fe 00 80 f7 ef    	cmp    $0xeff78000,%esi
f010217f:	75 c0                	jne    f0102141 <mem_init+0xe23>
	pgdir = kern_pgdir;
f0102181:	8b 3d 8c 7e 23 f0    	mov    0xf0237e8c,%edi
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102187:	a1 88 7e 23 f0       	mov    0xf0237e88,%eax
f010218c:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f010218f:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0102196:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010219b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010219e:	8b 35 90 7e 23 f0    	mov    0xf0237e90,%esi
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
f01021ee:	68 8a 6b 10 f0       	push   $0xf0106b8a
f01021f3:	68 be 69 10 f0       	push   $0xf01069be
f01021f8:	68 5b 03 00 00       	push   $0x35b
f01021fd:	68 91 69 10 f0       	push   $0xf0106991
f0102202:	e8 8d de ff ff       	call   f0100094 <_panic>
	assert((pp0 = page_alloc(0)));
f0102207:	68 98 6a 10 f0       	push   $0xf0106a98
f010220c:	68 be 69 10 f0       	push   $0xf01069be
f0102211:	68 c7 03 00 00       	push   $0x3c7
f0102216:	68 91 69 10 f0       	push   $0xf0106991
f010221b:	e8 74 de ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f0102220:	68 ae 6a 10 f0       	push   $0xf0106aae
f0102225:	68 be 69 10 f0       	push   $0xf01069be
f010222a:	68 c8 03 00 00       	push   $0x3c8
f010222f:	68 91 69 10 f0       	push   $0xf0106991
f0102234:	e8 5b de ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f0102239:	68 c4 6a 10 f0       	push   $0xf0106ac4
f010223e:	68 be 69 10 f0       	push   $0xf01069be
f0102243:	68 c9 03 00 00       	push   $0x3c9
f0102248:	68 91 69 10 f0       	push   $0xf0106991
f010224d:	e8 42 de ff ff       	call   f0100094 <_panic>
	assert(pp1 && pp1 != pp0);
f0102252:	68 da 6a 10 f0       	push   $0xf0106ada
f0102257:	68 be 69 10 f0       	push   $0xf01069be
f010225c:	68 cc 03 00 00       	push   $0x3cc
f0102261:	68 91 69 10 f0       	push   $0xf0106991
f0102266:	e8 29 de ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010226b:	68 38 6e 10 f0       	push   $0xf0106e38
f0102270:	68 be 69 10 f0       	push   $0xf01069be
f0102275:	68 cd 03 00 00       	push   $0x3cd
f010227a:	68 91 69 10 f0       	push   $0xf0106991
f010227f:	e8 10 de ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f0102284:	68 43 6b 10 f0       	push   $0xf0106b43
f0102289:	68 be 69 10 f0       	push   $0xf01069be
f010228e:	68 d4 03 00 00       	push   $0x3d4
f0102293:	68 91 69 10 f0       	push   $0xf0106991
f0102298:	e8 f7 dd ff ff       	call   f0100094 <_panic>
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f010229d:	68 78 6e 10 f0       	push   $0xf0106e78
f01022a2:	68 be 69 10 f0       	push   $0xf01069be
f01022a7:	68 d7 03 00 00       	push   $0x3d7
f01022ac:	68 91 69 10 f0       	push   $0xf0106991
f01022b1:	e8 de dd ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01022b6:	68 b0 6e 10 f0       	push   $0xf0106eb0
f01022bb:	68 be 69 10 f0       	push   $0xf01069be
f01022c0:	68 da 03 00 00       	push   $0x3da
f01022c5:	68 91 69 10 f0       	push   $0xf0106991
f01022ca:	e8 c5 dd ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f01022cf:	68 e0 6e 10 f0       	push   $0xf0106ee0
f01022d4:	68 be 69 10 f0       	push   $0xf01069be
f01022d9:	68 de 03 00 00       	push   $0x3de
f01022de:	68 91 69 10 f0       	push   $0xf0106991
f01022e3:	e8 ac dd ff ff       	call   f0100094 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01022e8:	68 10 6f 10 f0       	push   $0xf0106f10
f01022ed:	68 be 69 10 f0       	push   $0xf01069be
f01022f2:	68 df 03 00 00       	push   $0x3df
f01022f7:	68 91 69 10 f0       	push   $0xf0106991
f01022fc:	e8 93 dd ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0102301:	68 38 6f 10 f0       	push   $0xf0106f38
f0102306:	68 be 69 10 f0       	push   $0xf01069be
f010230b:	68 e0 03 00 00       	push   $0x3e0
f0102310:	68 91 69 10 f0       	push   $0xf0106991
f0102315:	e8 7a dd ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 1);
f010231a:	68 95 6b 10 f0       	push   $0xf0106b95
f010231f:	68 be 69 10 f0       	push   $0xf01069be
f0102324:	68 e1 03 00 00       	push   $0x3e1
f0102329:	68 91 69 10 f0       	push   $0xf0106991
f010232e:	e8 61 dd ff ff       	call   f0100094 <_panic>
	assert(pp0->pp_ref == 1);
f0102333:	68 a6 6b 10 f0       	push   $0xf0106ba6
f0102338:	68 be 69 10 f0       	push   $0xf01069be
f010233d:	68 e2 03 00 00       	push   $0x3e2
f0102342:	68 91 69 10 f0       	push   $0xf0106991
f0102347:	e8 48 dd ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010234c:	68 68 6f 10 f0       	push   $0xf0106f68
f0102351:	68 be 69 10 f0       	push   $0xf01069be
f0102356:	68 e5 03 00 00       	push   $0x3e5
f010235b:	68 91 69 10 f0       	push   $0xf0106991
f0102360:	e8 2f dd ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102365:	68 a4 6f 10 f0       	push   $0xf0106fa4
f010236a:	68 be 69 10 f0       	push   $0xf01069be
f010236f:	68 e6 03 00 00       	push   $0x3e6
f0102374:	68 91 69 10 f0       	push   $0xf0106991
f0102379:	e8 16 dd ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f010237e:	68 b7 6b 10 f0       	push   $0xf0106bb7
f0102383:	68 be 69 10 f0       	push   $0xf01069be
f0102388:	68 e7 03 00 00       	push   $0x3e7
f010238d:	68 91 69 10 f0       	push   $0xf0106991
f0102392:	e8 fd dc ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f0102397:	68 43 6b 10 f0       	push   $0xf0106b43
f010239c:	68 be 69 10 f0       	push   $0xf01069be
f01023a1:	68 ea 03 00 00       	push   $0x3ea
f01023a6:	68 91 69 10 f0       	push   $0xf0106991
f01023ab:	e8 e4 dc ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01023b0:	68 68 6f 10 f0       	push   $0xf0106f68
f01023b5:	68 be 69 10 f0       	push   $0xf01069be
f01023ba:	68 ed 03 00 00       	push   $0x3ed
f01023bf:	68 91 69 10 f0       	push   $0xf0106991
f01023c4:	e8 cb dc ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01023c9:	68 a4 6f 10 f0       	push   $0xf0106fa4
f01023ce:	68 be 69 10 f0       	push   $0xf01069be
f01023d3:	68 ee 03 00 00       	push   $0x3ee
f01023d8:	68 91 69 10 f0       	push   $0xf0106991
f01023dd:	e8 b2 dc ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f01023e2:	68 b7 6b 10 f0       	push   $0xf0106bb7
f01023e7:	68 be 69 10 f0       	push   $0xf01069be
f01023ec:	68 ef 03 00 00       	push   $0x3ef
f01023f1:	68 91 69 10 f0       	push   $0xf0106991
f01023f6:	e8 99 dc ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f01023fb:	68 43 6b 10 f0       	push   $0xf0106b43
f0102400:	68 be 69 10 f0       	push   $0xf01069be
f0102405:	68 f3 03 00 00       	push   $0x3f3
f010240a:	68 91 69 10 f0       	push   $0xf0106991
f010240f:	e8 80 dc ff ff       	call   f0100094 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102414:	50                   	push   %eax
f0102415:	68 54 64 10 f0       	push   $0xf0106454
f010241a:	68 f6 03 00 00       	push   $0x3f6
f010241f:	68 91 69 10 f0       	push   $0xf0106991
f0102424:	e8 6b dc ff ff       	call   f0100094 <_panic>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0102429:	68 d4 6f 10 f0       	push   $0xf0106fd4
f010242e:	68 be 69 10 f0       	push   $0xf01069be
f0102433:	68 f7 03 00 00       	push   $0x3f7
f0102438:	68 91 69 10 f0       	push   $0xf0106991
f010243d:	e8 52 dc ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0102442:	68 14 70 10 f0       	push   $0xf0107014
f0102447:	68 be 69 10 f0       	push   $0xf01069be
f010244c:	68 fa 03 00 00       	push   $0x3fa
f0102451:	68 91 69 10 f0       	push   $0xf0106991
f0102456:	e8 39 dc ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010245b:	68 a4 6f 10 f0       	push   $0xf0106fa4
f0102460:	68 be 69 10 f0       	push   $0xf01069be
f0102465:	68 fb 03 00 00       	push   $0x3fb
f010246a:	68 91 69 10 f0       	push   $0xf0106991
f010246f:	e8 20 dc ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f0102474:	68 b7 6b 10 f0       	push   $0xf0106bb7
f0102479:	68 be 69 10 f0       	push   $0xf01069be
f010247e:	68 fc 03 00 00       	push   $0x3fc
f0102483:	68 91 69 10 f0       	push   $0xf0106991
f0102488:	e8 07 dc ff ff       	call   f0100094 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f010248d:	68 54 70 10 f0       	push   $0xf0107054
f0102492:	68 be 69 10 f0       	push   $0xf01069be
f0102497:	68 fd 03 00 00       	push   $0x3fd
f010249c:	68 91 69 10 f0       	push   $0xf0106991
f01024a1:	e8 ee db ff ff       	call   f0100094 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f01024a6:	68 c8 6b 10 f0       	push   $0xf0106bc8
f01024ab:	68 be 69 10 f0       	push   $0xf01069be
f01024b0:	68 fe 03 00 00       	push   $0x3fe
f01024b5:	68 91 69 10 f0       	push   $0xf0106991
f01024ba:	e8 d5 db ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01024bf:	68 68 6f 10 f0       	push   $0xf0106f68
f01024c4:	68 be 69 10 f0       	push   $0xf01069be
f01024c9:	68 01 04 00 00       	push   $0x401
f01024ce:	68 91 69 10 f0       	push   $0xf0106991
f01024d3:	e8 bc db ff ff       	call   f0100094 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f01024d8:	68 88 70 10 f0       	push   $0xf0107088
f01024dd:	68 be 69 10 f0       	push   $0xf01069be
f01024e2:	68 02 04 00 00       	push   $0x402
f01024e7:	68 91 69 10 f0       	push   $0xf0106991
f01024ec:	e8 a3 db ff ff       	call   f0100094 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01024f1:	68 bc 70 10 f0       	push   $0xf01070bc
f01024f6:	68 be 69 10 f0       	push   $0xf01069be
f01024fb:	68 03 04 00 00       	push   $0x403
f0102500:	68 91 69 10 f0       	push   $0xf0106991
f0102505:	e8 8a db ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f010250a:	68 f4 70 10 f0       	push   $0xf01070f4
f010250f:	68 be 69 10 f0       	push   $0xf01069be
f0102514:	68 06 04 00 00       	push   $0x406
f0102519:	68 91 69 10 f0       	push   $0xf0106991
f010251e:	e8 71 db ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0102523:	68 2c 71 10 f0       	push   $0xf010712c
f0102528:	68 be 69 10 f0       	push   $0xf01069be
f010252d:	68 09 04 00 00       	push   $0x409
f0102532:	68 91 69 10 f0       	push   $0xf0106991
f0102537:	e8 58 db ff ff       	call   f0100094 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f010253c:	68 bc 70 10 f0       	push   $0xf01070bc
f0102541:	68 be 69 10 f0       	push   $0xf01069be
f0102546:	68 0a 04 00 00       	push   $0x40a
f010254b:	68 91 69 10 f0       	push   $0xf0106991
f0102550:	e8 3f db ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102555:	68 68 71 10 f0       	push   $0xf0107168
f010255a:	68 be 69 10 f0       	push   $0xf01069be
f010255f:	68 0d 04 00 00       	push   $0x40d
f0102564:	68 91 69 10 f0       	push   $0xf0106991
f0102569:	e8 26 db ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010256e:	68 94 71 10 f0       	push   $0xf0107194
f0102573:	68 be 69 10 f0       	push   $0xf01069be
f0102578:	68 0e 04 00 00       	push   $0x40e
f010257d:	68 91 69 10 f0       	push   $0xf0106991
f0102582:	e8 0d db ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 2);
f0102587:	68 de 6b 10 f0       	push   $0xf0106bde
f010258c:	68 be 69 10 f0       	push   $0xf01069be
f0102591:	68 10 04 00 00       	push   $0x410
f0102596:	68 91 69 10 f0       	push   $0xf0106991
f010259b:	e8 f4 da ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f01025a0:	68 ef 6b 10 f0       	push   $0xf0106bef
f01025a5:	68 be 69 10 f0       	push   $0xf01069be
f01025aa:	68 11 04 00 00       	push   $0x411
f01025af:	68 91 69 10 f0       	push   $0xf0106991
f01025b4:	e8 db da ff ff       	call   f0100094 <_panic>
	assert((pp = page_alloc(0)) && pp == pp2);
f01025b9:	68 c4 71 10 f0       	push   $0xf01071c4
f01025be:	68 be 69 10 f0       	push   $0xf01069be
f01025c3:	68 14 04 00 00       	push   $0x414
f01025c8:	68 91 69 10 f0       	push   $0xf0106991
f01025cd:	e8 c2 da ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01025d2:	68 e8 71 10 f0       	push   $0xf01071e8
f01025d7:	68 be 69 10 f0       	push   $0xf01069be
f01025dc:	68 18 04 00 00       	push   $0x418
f01025e1:	68 91 69 10 f0       	push   $0xf0106991
f01025e6:	e8 a9 da ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01025eb:	68 94 71 10 f0       	push   $0xf0107194
f01025f0:	68 be 69 10 f0       	push   $0xf01069be
f01025f5:	68 19 04 00 00       	push   $0x419
f01025fa:	68 91 69 10 f0       	push   $0xf0106991
f01025ff:	e8 90 da ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 1);
f0102604:	68 95 6b 10 f0       	push   $0xf0106b95
f0102609:	68 be 69 10 f0       	push   $0xf01069be
f010260e:	68 1a 04 00 00       	push   $0x41a
f0102613:	68 91 69 10 f0       	push   $0xf0106991
f0102618:	e8 77 da ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f010261d:	68 ef 6b 10 f0       	push   $0xf0106bef
f0102622:	68 be 69 10 f0       	push   $0xf01069be
f0102627:	68 1b 04 00 00       	push   $0x41b
f010262c:	68 91 69 10 f0       	push   $0xf0106991
f0102631:	e8 5e da ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0102636:	68 0c 72 10 f0       	push   $0xf010720c
f010263b:	68 be 69 10 f0       	push   $0xf01069be
f0102640:	68 1e 04 00 00       	push   $0x41e
f0102645:	68 91 69 10 f0       	push   $0xf0106991
f010264a:	e8 45 da ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref);
f010264f:	68 00 6c 10 f0       	push   $0xf0106c00
f0102654:	68 be 69 10 f0       	push   $0xf01069be
f0102659:	68 1f 04 00 00       	push   $0x41f
f010265e:	68 91 69 10 f0       	push   $0xf0106991
f0102663:	e8 2c da ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_link == NULL);
f0102668:	68 0c 6c 10 f0       	push   $0xf0106c0c
f010266d:	68 be 69 10 f0       	push   $0xf01069be
f0102672:	68 20 04 00 00       	push   $0x420
f0102677:	68 91 69 10 f0       	push   $0xf0106991
f010267c:	e8 13 da ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102681:	68 e8 71 10 f0       	push   $0xf01071e8
f0102686:	68 be 69 10 f0       	push   $0xf01069be
f010268b:	68 24 04 00 00       	push   $0x424
f0102690:	68 91 69 10 f0       	push   $0xf0106991
f0102695:	e8 fa d9 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f010269a:	68 44 72 10 f0       	push   $0xf0107244
f010269f:	68 be 69 10 f0       	push   $0xf01069be
f01026a4:	68 25 04 00 00       	push   $0x425
f01026a9:	68 91 69 10 f0       	push   $0xf0106991
f01026ae:	e8 e1 d9 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 0);
f01026b3:	68 21 6c 10 f0       	push   $0xf0106c21
f01026b8:	68 be 69 10 f0       	push   $0xf01069be
f01026bd:	68 26 04 00 00       	push   $0x426
f01026c2:	68 91 69 10 f0       	push   $0xf0106991
f01026c7:	e8 c8 d9 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f01026cc:	68 ef 6b 10 f0       	push   $0xf0106bef
f01026d1:	68 be 69 10 f0       	push   $0xf01069be
f01026d6:	68 27 04 00 00       	push   $0x427
f01026db:	68 91 69 10 f0       	push   $0xf0106991
f01026e0:	e8 af d9 ff ff       	call   f0100094 <_panic>
	assert((pp = page_alloc(0)) && pp == pp1);
f01026e5:	68 6c 72 10 f0       	push   $0xf010726c
f01026ea:	68 be 69 10 f0       	push   $0xf01069be
f01026ef:	68 2a 04 00 00       	push   $0x42a
f01026f4:	68 91 69 10 f0       	push   $0xf0106991
f01026f9:	e8 96 d9 ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f01026fe:	68 43 6b 10 f0       	push   $0xf0106b43
f0102703:	68 be 69 10 f0       	push   $0xf01069be
f0102708:	68 2d 04 00 00       	push   $0x42d
f010270d:	68 91 69 10 f0       	push   $0xf0106991
f0102712:	e8 7d d9 ff ff       	call   f0100094 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102717:	68 10 6f 10 f0       	push   $0xf0106f10
f010271c:	68 be 69 10 f0       	push   $0xf01069be
f0102721:	68 30 04 00 00       	push   $0x430
f0102726:	68 91 69 10 f0       	push   $0xf0106991
f010272b:	e8 64 d9 ff ff       	call   f0100094 <_panic>
	assert(pp0->pp_ref == 1);
f0102730:	68 a6 6b 10 f0       	push   $0xf0106ba6
f0102735:	68 be 69 10 f0       	push   $0xf01069be
f010273a:	68 32 04 00 00       	push   $0x432
f010273f:	68 91 69 10 f0       	push   $0xf0106991
f0102744:	e8 4b d9 ff ff       	call   f0100094 <_panic>
f0102749:	50                   	push   %eax
f010274a:	68 54 64 10 f0       	push   $0xf0106454
f010274f:	68 39 04 00 00       	push   $0x439
f0102754:	68 91 69 10 f0       	push   $0xf0106991
f0102759:	e8 36 d9 ff ff       	call   f0100094 <_panic>
	assert(ptep == ptep1 + PTX(va));
f010275e:	68 32 6c 10 f0       	push   $0xf0106c32
f0102763:	68 be 69 10 f0       	push   $0xf01069be
f0102768:	68 3a 04 00 00       	push   $0x43a
f010276d:	68 91 69 10 f0       	push   $0xf0106991
f0102772:	e8 1d d9 ff ff       	call   f0100094 <_panic>
f0102777:	50                   	push   %eax
f0102778:	68 54 64 10 f0       	push   $0xf0106454
f010277d:	6a 58                	push   $0x58
f010277f:	68 a4 69 10 f0       	push   $0xf01069a4
f0102784:	e8 0b d9 ff ff       	call   f0100094 <_panic>
f0102789:	50                   	push   %eax
f010278a:	68 54 64 10 f0       	push   $0xf0106454
f010278f:	6a 58                	push   $0x58
f0102791:	68 a4 69 10 f0       	push   $0xf01069a4
f0102796:	e8 f9 d8 ff ff       	call   f0100094 <_panic>
		assert((ptep[i] & PTE_P) == 0);
f010279b:	68 4a 6c 10 f0       	push   $0xf0106c4a
f01027a0:	68 be 69 10 f0       	push   $0xf01069be
f01027a5:	68 44 04 00 00       	push   $0x444
f01027aa:	68 91 69 10 f0       	push   $0xf0106991
f01027af:	e8 e0 d8 ff ff       	call   f0100094 <_panic>
	assert(mm1 >= MMIOBASE && mm1 + 8192 < MMIOLIM);
f01027b4:	68 90 72 10 f0       	push   $0xf0107290
f01027b9:	68 be 69 10 f0       	push   $0xf01069be
f01027be:	68 54 04 00 00       	push   $0x454
f01027c3:	68 91 69 10 f0       	push   $0xf0106991
f01027c8:	e8 c7 d8 ff ff       	call   f0100094 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8192 < MMIOLIM);
f01027cd:	68 b8 72 10 f0       	push   $0xf01072b8
f01027d2:	68 be 69 10 f0       	push   $0xf01069be
f01027d7:	68 55 04 00 00       	push   $0x455
f01027dc:	68 91 69 10 f0       	push   $0xf0106991
f01027e1:	e8 ae d8 ff ff       	call   f0100094 <_panic>
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f01027e6:	68 e0 72 10 f0       	push   $0xf01072e0
f01027eb:	68 be 69 10 f0       	push   $0xf01069be
f01027f0:	68 57 04 00 00       	push   $0x457
f01027f5:	68 91 69 10 f0       	push   $0xf0106991
f01027fa:	e8 95 d8 ff ff       	call   f0100094 <_panic>
	assert(mm1 + 8192 <= mm2);
f01027ff:	68 61 6c 10 f0       	push   $0xf0106c61
f0102804:	68 be 69 10 f0       	push   $0xf01069be
f0102809:	68 59 04 00 00       	push   $0x459
f010280e:	68 91 69 10 f0       	push   $0xf0106991
f0102813:	e8 7c d8 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0102818:	68 08 73 10 f0       	push   $0xf0107308
f010281d:	68 be 69 10 f0       	push   $0xf01069be
f0102822:	68 5b 04 00 00       	push   $0x45b
f0102827:	68 91 69 10 f0       	push   $0xf0106991
f010282c:	e8 63 d8 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0102831:	68 2c 73 10 f0       	push   $0xf010732c
f0102836:	68 be 69 10 f0       	push   $0xf01069be
f010283b:	68 5c 04 00 00       	push   $0x45c
f0102840:	68 91 69 10 f0       	push   $0xf0106991
f0102845:	e8 4a d8 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f010284a:	68 5c 73 10 f0       	push   $0xf010735c
f010284f:	68 be 69 10 f0       	push   $0xf01069be
f0102854:	68 5d 04 00 00       	push   $0x45d
f0102859:	68 91 69 10 f0       	push   $0xf0106991
f010285e:	e8 31 d8 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0102863:	68 80 73 10 f0       	push   $0xf0107380
f0102868:	68 be 69 10 f0       	push   $0xf01069be
f010286d:	68 5e 04 00 00       	push   $0x45e
f0102872:	68 91 69 10 f0       	push   $0xf0106991
f0102877:	e8 18 d8 ff ff       	call   f0100094 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f010287c:	68 ac 73 10 f0       	push   $0xf01073ac
f0102881:	68 be 69 10 f0       	push   $0xf01069be
f0102886:	68 60 04 00 00       	push   $0x460
f010288b:	68 91 69 10 f0       	push   $0xf0106991
f0102890:	e8 ff d7 ff ff       	call   f0100094 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102895:	68 f0 73 10 f0       	push   $0xf01073f0
f010289a:	68 be 69 10 f0       	push   $0xf01069be
f010289f:	68 61 04 00 00       	push   $0x461
f01028a4:	68 91 69 10 f0       	push   $0xf0106991
f01028a9:	e8 e6 d7 ff ff       	call   f0100094 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01028ae:	50                   	push   %eax
f01028af:	68 78 64 10 f0       	push   $0xf0106478
f01028b4:	68 d2 00 00 00       	push   $0xd2
f01028b9:	68 91 69 10 f0       	push   $0xf0106991
f01028be:	e8 d1 d7 ff ff       	call   f0100094 <_panic>
f01028c3:	50                   	push   %eax
f01028c4:	68 78 64 10 f0       	push   $0xf0106478
f01028c9:	68 db 00 00 00       	push   $0xdb
f01028ce:	68 91 69 10 f0       	push   $0xf0106991
f01028d3:	e8 bc d7 ff ff       	call   f0100094 <_panic>
f01028d8:	50                   	push   %eax
f01028d9:	68 78 64 10 f0       	push   $0xf0106478
f01028de:	68 e8 00 00 00       	push   $0xe8
f01028e3:	68 91 69 10 f0       	push   $0xf0106991
f01028e8:	e8 a7 d7 ff ff       	call   f0100094 <_panic>
f01028ed:	53                   	push   %ebx
f01028ee:	68 78 64 10 f0       	push   $0xf0106478
f01028f3:	68 2c 01 00 00       	push   $0x12c
f01028f8:	68 91 69 10 f0       	push   $0xf0106991
f01028fd:	e8 92 d7 ff ff       	call   f0100094 <_panic>
f0102902:	56                   	push   %esi
f0102903:	68 78 64 10 f0       	push   $0xf0106478
f0102908:	68 74 03 00 00       	push   $0x374
f010290d:	68 91 69 10 f0       	push   $0xf0106991
f0102912:	e8 7d d7 ff ff       	call   f0100094 <_panic>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102917:	68 24 74 10 f0       	push   $0xf0107424
f010291c:	68 be 69 10 f0       	push   $0xf01069be
f0102921:	68 74 03 00 00       	push   $0x374
f0102926:	68 91 69 10 f0       	push   $0xf0106991
f010292b:	e8 64 d7 ff ff       	call   f0100094 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102930:	a1 48 72 23 f0       	mov    0xf0237248,%eax
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
f0102998:	68 78 64 10 f0       	push   $0xf0106478
f010299d:	68 7b 03 00 00       	push   $0x37b
f01029a2:	68 91 69 10 f0       	push   $0xf0106991
f01029a7:	e8 e8 d6 ff ff       	call   f0100094 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f01029ac:	68 58 74 10 f0       	push   $0xf0107458
f01029b1:	68 be 69 10 f0       	push   $0xf01069be
f01029b6:	68 7b 03 00 00       	push   $0x37b
f01029bb:	68 91 69 10 f0       	push   $0xf0106991
f01029c0:	e8 cf d6 ff ff       	call   f0100094 <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f01029c5:	68 8c 74 10 f0       	push   $0xf010748c
f01029ca:	68 be 69 10 f0       	push   $0xf01069be
f01029cf:	68 82 03 00 00       	push   $0x382
f01029d4:	68 91 69 10 f0       	push   $0xf0106991
f01029d9:	e8 b6 d6 ff ff       	call   f0100094 <_panic>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01029de:	b8 00 90 23 f0       	mov    $0xf0239000,%eax
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
f0102a5f:	81 ff 00 90 27 f0    	cmp    $0xf0279000,%edi
f0102a65:	75 86                	jne    f01029ed <mem_init+0x16cf>
f0102a67:	8b 7d d4             	mov    -0x2c(%ebp),%edi
	for (i = 0; i < NPDENTRIES; i++) {
f0102a6a:	b8 00 00 00 00       	mov    $0x0,%eax
f0102a6f:	eb 7f                	jmp    f0102af0 <mem_init+0x17d2>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102a71:	ff 75 c4             	pushl  -0x3c(%ebp)
f0102a74:	68 78 64 10 f0       	push   $0xf0106478
f0102a79:	68 8b 03 00 00       	push   $0x38b
f0102a7e:	68 91 69 10 f0       	push   $0xf0106991
f0102a83:	e8 0c d6 ff ff       	call   f0100094 <_panic>
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102a88:	68 b4 74 10 f0       	push   $0xf01074b4
f0102a8d:	68 be 69 10 f0       	push   $0xf01069be
f0102a92:	68 8b 03 00 00       	push   $0x38b
f0102a97:	68 91 69 10 f0       	push   $0xf0106991
f0102a9c:	e8 f3 d5 ff ff       	call   f0100094 <_panic>
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102aa1:	68 fc 74 10 f0       	push   $0xf01074fc
f0102aa6:	68 be 69 10 f0       	push   $0xf01069be
f0102aab:	68 8d 03 00 00       	push   $0x38d
f0102ab0:	68 91 69 10 f0       	push   $0xf0106991
f0102ab5:	e8 da d5 ff ff       	call   f0100094 <_panic>
			assert(pgdir[i] & PTE_P);
f0102aba:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f0102abe:	75 48                	jne    f0102b08 <mem_init+0x17ea>
f0102ac0:	68 8c 6c 10 f0       	push   $0xf0106c8c
f0102ac5:	68 be 69 10 f0       	push   $0xf01069be
f0102aca:	68 98 03 00 00       	push   $0x398
f0102acf:	68 91 69 10 f0       	push   $0xf0106991
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
f0102b0d:	68 8c 6c 10 f0       	push   $0xf0106c8c
f0102b12:	68 be 69 10 f0       	push   $0xf01069be
f0102b17:	68 9c 03 00 00       	push   $0x39c
f0102b1c:	68 91 69 10 f0       	push   $0xf0106991
f0102b21:	e8 6e d5 ff ff       	call   f0100094 <_panic>
				assert(pgdir[i] & PTE_W);
f0102b26:	68 9d 6c 10 f0       	push   $0xf0106c9d
f0102b2b:	68 be 69 10 f0       	push   $0xf01069be
f0102b30:	68 9d 03 00 00       	push   $0x39d
f0102b35:	68 91 69 10 f0       	push   $0xf0106991
f0102b3a:	e8 55 d5 ff ff       	call   f0100094 <_panic>
				assert(pgdir[i] == 0);
f0102b3f:	68 ae 6c 10 f0       	push   $0xf0106cae
f0102b44:	68 be 69 10 f0       	push   $0xf01069be
f0102b49:	68 9f 03 00 00       	push   $0x39f
f0102b4e:	68 91 69 10 f0       	push   $0xf0106991
f0102b53:	e8 3c d5 ff ff       	call   f0100094 <_panic>
	cprintf("check_kern_pgdir() succeeded!\n");
f0102b58:	83 ec 0c             	sub    $0xc,%esp
f0102b5b:	68 20 75 10 f0       	push   $0xf0107520
f0102b60:	e8 97 0d 00 00       	call   f01038fc <cprintf>
	lcr3(PADDR(kern_pgdir));
f0102b65:	a1 8c 7e 23 f0       	mov    0xf0237e8c,%eax
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
f0102be8:	2b 05 90 7e 23 f0    	sub    0xf0237e90,%eax
f0102bee:	c1 f8 03             	sar    $0x3,%eax
f0102bf1:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102bf4:	89 c2                	mov    %eax,%edx
f0102bf6:	c1 ea 0c             	shr    $0xc,%edx
f0102bf9:	83 c4 10             	add    $0x10,%esp
f0102bfc:	3b 15 88 7e 23 f0    	cmp    0xf0237e88,%edx
f0102c02:	0f 83 cb 01 00 00    	jae    f0102dd3 <mem_init+0x1ab5>
	memset(page2kva(pp1), 1, PGSIZE);
f0102c08:	83 ec 04             	sub    $0x4,%esp
f0102c0b:	68 00 10 00 00       	push   $0x1000
f0102c10:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0102c12:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102c17:	50                   	push   %eax
f0102c18:	e8 3d 2b 00 00       	call   f010575a <memset>
	return (pp - pages) << PGSHIFT;
f0102c1d:	89 d8                	mov    %ebx,%eax
f0102c1f:	2b 05 90 7e 23 f0    	sub    0xf0237e90,%eax
f0102c25:	c1 f8 03             	sar    $0x3,%eax
f0102c28:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102c2b:	89 c2                	mov    %eax,%edx
f0102c2d:	c1 ea 0c             	shr    $0xc,%edx
f0102c30:	83 c4 10             	add    $0x10,%esp
f0102c33:	3b 15 88 7e 23 f0    	cmp    0xf0237e88,%edx
f0102c39:	0f 83 a6 01 00 00    	jae    f0102de5 <mem_init+0x1ac7>
	memset(page2kva(pp2), 2, PGSIZE);
f0102c3f:	83 ec 04             	sub    $0x4,%esp
f0102c42:	68 00 10 00 00       	push   $0x1000
f0102c47:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f0102c49:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102c4e:	50                   	push   %eax
f0102c4f:	e8 06 2b 00 00       	call   f010575a <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102c54:	6a 02                	push   $0x2
f0102c56:	68 00 10 00 00       	push   $0x1000
f0102c5b:	57                   	push   %edi
f0102c5c:	ff 35 8c 7e 23 f0    	pushl  0xf0237e8c
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
f0102c8d:	ff 35 8c 7e 23 f0    	pushl  0xf0237e8c
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
f0102ccd:	2b 05 90 7e 23 f0    	sub    0xf0237e90,%eax
f0102cd3:	c1 f8 03             	sar    $0x3,%eax
f0102cd6:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102cd9:	89 c2                	mov    %eax,%edx
f0102cdb:	c1 ea 0c             	shr    $0xc,%edx
f0102cde:	3b 15 88 7e 23 f0    	cmp    0xf0237e88,%edx
f0102ce4:	0f 83 8a 01 00 00    	jae    f0102e74 <mem_init+0x1b56>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102cea:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102cf1:	03 03 03 
f0102cf4:	0f 85 8c 01 00 00    	jne    f0102e86 <mem_init+0x1b68>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102cfa:	83 ec 08             	sub    $0x8,%esp
f0102cfd:	68 00 10 00 00       	push   $0x1000
f0102d02:	ff 35 8c 7e 23 f0    	pushl  0xf0237e8c
f0102d08:	e8 ff e4 ff ff       	call   f010120c <page_remove>
	assert(pp2->pp_ref == 0);
f0102d0d:	83 c4 10             	add    $0x10,%esp
f0102d10:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102d15:	0f 85 84 01 00 00    	jne    f0102e9f <mem_init+0x1b81>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102d1b:	8b 0d 8c 7e 23 f0    	mov    0xf0237e8c,%ecx
f0102d21:	8b 11                	mov    (%ecx),%edx
f0102d23:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	return (pp - pages) << PGSHIFT;
f0102d29:	89 f0                	mov    %esi,%eax
f0102d2b:	2b 05 90 7e 23 f0    	sub    0xf0237e90,%eax
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
f0102d5f:	c7 04 24 b4 75 10 f0 	movl   $0xf01075b4,(%esp)
f0102d66:	e8 91 0b 00 00       	call   f01038fc <cprintf>
}
f0102d6b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102d6e:	5b                   	pop    %ebx
f0102d6f:	5e                   	pop    %esi
f0102d70:	5f                   	pop    %edi
f0102d71:	5d                   	pop    %ebp
f0102d72:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102d73:	50                   	push   %eax
f0102d74:	68 78 64 10 f0       	push   $0xf0106478
f0102d79:	68 04 01 00 00       	push   $0x104
f0102d7e:	68 91 69 10 f0       	push   $0xf0106991
f0102d83:	e8 0c d3 ff ff       	call   f0100094 <_panic>
	assert((pp0 = page_alloc(0)));
f0102d88:	68 98 6a 10 f0       	push   $0xf0106a98
f0102d8d:	68 be 69 10 f0       	push   $0xf01069be
f0102d92:	68 76 04 00 00       	push   $0x476
f0102d97:	68 91 69 10 f0       	push   $0xf0106991
f0102d9c:	e8 f3 d2 ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f0102da1:	68 ae 6a 10 f0       	push   $0xf0106aae
f0102da6:	68 be 69 10 f0       	push   $0xf01069be
f0102dab:	68 77 04 00 00       	push   $0x477
f0102db0:	68 91 69 10 f0       	push   $0xf0106991
f0102db5:	e8 da d2 ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f0102dba:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0102dbf:	68 be 69 10 f0       	push   $0xf01069be
f0102dc4:	68 78 04 00 00       	push   $0x478
f0102dc9:	68 91 69 10 f0       	push   $0xf0106991
f0102dce:	e8 c1 d2 ff ff       	call   f0100094 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102dd3:	50                   	push   %eax
f0102dd4:	68 54 64 10 f0       	push   $0xf0106454
f0102dd9:	6a 58                	push   $0x58
f0102ddb:	68 a4 69 10 f0       	push   $0xf01069a4
f0102de0:	e8 af d2 ff ff       	call   f0100094 <_panic>
f0102de5:	50                   	push   %eax
f0102de6:	68 54 64 10 f0       	push   $0xf0106454
f0102deb:	6a 58                	push   $0x58
f0102ded:	68 a4 69 10 f0       	push   $0xf01069a4
f0102df2:	e8 9d d2 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 1);
f0102df7:	68 95 6b 10 f0       	push   $0xf0106b95
f0102dfc:	68 be 69 10 f0       	push   $0xf01069be
f0102e01:	68 7d 04 00 00       	push   $0x47d
f0102e06:	68 91 69 10 f0       	push   $0xf0106991
f0102e0b:	e8 84 d2 ff ff       	call   f0100094 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102e10:	68 40 75 10 f0       	push   $0xf0107540
f0102e15:	68 be 69 10 f0       	push   $0xf01069be
f0102e1a:	68 7e 04 00 00       	push   $0x47e
f0102e1f:	68 91 69 10 f0       	push   $0xf0106991
f0102e24:	e8 6b d2 ff ff       	call   f0100094 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102e29:	68 64 75 10 f0       	push   $0xf0107564
f0102e2e:	68 be 69 10 f0       	push   $0xf01069be
f0102e33:	68 80 04 00 00       	push   $0x480
f0102e38:	68 91 69 10 f0       	push   $0xf0106991
f0102e3d:	e8 52 d2 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f0102e42:	68 b7 6b 10 f0       	push   $0xf0106bb7
f0102e47:	68 be 69 10 f0       	push   $0xf01069be
f0102e4c:	68 81 04 00 00       	push   $0x481
f0102e51:	68 91 69 10 f0       	push   $0xf0106991
f0102e56:	e8 39 d2 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 0);
f0102e5b:	68 21 6c 10 f0       	push   $0xf0106c21
f0102e60:	68 be 69 10 f0       	push   $0xf01069be
f0102e65:	68 82 04 00 00       	push   $0x482
f0102e6a:	68 91 69 10 f0       	push   $0xf0106991
f0102e6f:	e8 20 d2 ff ff       	call   f0100094 <_panic>
f0102e74:	50                   	push   %eax
f0102e75:	68 54 64 10 f0       	push   $0xf0106454
f0102e7a:	6a 58                	push   $0x58
f0102e7c:	68 a4 69 10 f0       	push   $0xf01069a4
f0102e81:	e8 0e d2 ff ff       	call   f0100094 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102e86:	68 88 75 10 f0       	push   $0xf0107588
f0102e8b:	68 be 69 10 f0       	push   $0xf01069be
f0102e90:	68 84 04 00 00       	push   $0x484
f0102e95:	68 91 69 10 f0       	push   $0xf0106991
f0102e9a:	e8 f5 d1 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f0102e9f:	68 ef 6b 10 f0       	push   $0xf0106bef
f0102ea4:	68 be 69 10 f0       	push   $0xf01069be
f0102ea9:	68 86 04 00 00       	push   $0x486
f0102eae:	68 91 69 10 f0       	push   $0xf0106991
f0102eb3:	e8 dc d1 ff ff       	call   f0100094 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102eb8:	68 10 6f 10 f0       	push   $0xf0106f10
f0102ebd:	68 be 69 10 f0       	push   $0xf01069be
f0102ec2:	68 89 04 00 00       	push   $0x489
f0102ec7:	68 91 69 10 f0       	push   $0xf0106991
f0102ecc:	e8 c3 d1 ff ff       	call   f0100094 <_panic>
	assert(pp0->pp_ref == 1);
f0102ed1:	68 a6 6b 10 f0       	push   $0xf0106ba6
f0102ed6:	68 be 69 10 f0       	push   $0xf01069be
f0102edb:	68 8b 04 00 00       	push   $0x48b
f0102ee0:	68 91 69 10 f0       	push   $0xf0106991
f0102ee5:	e8 aa d1 ff ff       	call   f0100094 <_panic>

f0102eea <user_mem_check>:
{
f0102eea:	55                   	push   %ebp
f0102eeb:	89 e5                	mov    %esp,%ebp
f0102eed:	57                   	push   %edi
f0102eee:	56                   	push   %esi
f0102eef:	53                   	push   %ebx
f0102ef0:	83 ec 1c             	sub    $0x1c,%esp
    uintptr_t start_va = ROUNDDOWN((uintptr_t)va, PGSIZE);
f0102ef3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102ef6:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0102efc:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
    uintptr_t end_va = ROUNDUP((uintptr_t)va + len, PGSIZE);
f0102eff:	8b 45 10             	mov    0x10(%ebp),%eax
f0102f02:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102f05:	8d bc 01 ff 0f 00 00 	lea    0xfff(%ecx,%eax,1),%edi
f0102f0c:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
							|| (*cur_pte & (perm|PTE_P)) != (perm|PTE_P) ) 
f0102f12:	8b 75 14             	mov    0x14(%ebp),%esi
f0102f15:	83 ce 01             	or     $0x1,%esi
    for (uintptr_t cur_va = start_va; cur_va < end_va; cur_va+=PGSIZE) {
f0102f18:	39 fb                	cmp    %edi,%ebx
f0102f1a:	73 57                	jae    f0102f73 <user_mem_check+0x89>
        pte_t *cur_pte = pgdir_walk(env->env_pgdir, (void *)cur_va, 0);
f0102f1c:	83 ec 04             	sub    $0x4,%esp
f0102f1f:	6a 00                	push   $0x0
f0102f21:	53                   	push   %ebx
f0102f22:	8b 45 08             	mov    0x8(%ebp),%eax
f0102f25:	ff 70 60             	pushl  0x60(%eax)
f0102f28:	e8 3a e1 ff ff       	call   f0101067 <pgdir_walk>
        if (cur_pte == NULL ||  cur_va >= ULIM \
f0102f2d:	83 c4 10             	add    $0x10,%esp
f0102f30:	85 c0                	test   %eax,%eax
f0102f32:	74 18                	je     f0102f4c <user_mem_check+0x62>
f0102f34:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102f3a:	77 10                	ja     f0102f4c <user_mem_check+0x62>
							|| (*cur_pte & (perm|PTE_P)) != (perm|PTE_P) ) 
f0102f3c:	89 f2                	mov    %esi,%edx
f0102f3e:	23 10                	and    (%eax),%edx
f0102f40:	39 d6                	cmp    %edx,%esi
f0102f42:	75 08                	jne    f0102f4c <user_mem_check+0x62>
    for (uintptr_t cur_va = start_va; cur_va < end_va; cur_va+=PGSIZE) {
f0102f44:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102f4a:	eb cc                	jmp    f0102f18 <user_mem_check+0x2e>
            if (cur_va == start_va) {
f0102f4c:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0102f4f:	74 13                	je     f0102f64 <user_mem_check+0x7a>
                user_mem_check_addr = cur_va;
f0102f51:	89 1d 3c 72 23 f0    	mov    %ebx,0xf023723c
            return -E_FAULT;
f0102f57:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
}
f0102f5c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102f5f:	5b                   	pop    %ebx
f0102f60:	5e                   	pop    %esi
f0102f61:	5f                   	pop    %edi
f0102f62:	5d                   	pop    %ebp
f0102f63:	c3                   	ret    
                user_mem_check_addr = (uintptr_t)va;
f0102f64:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102f67:	a3 3c 72 23 f0       	mov    %eax,0xf023723c
            return -E_FAULT;
f0102f6c:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102f71:	eb e9                	jmp    f0102f5c <user_mem_check+0x72>
	return 0;
f0102f73:	b8 00 00 00 00       	mov    $0x0,%eax
f0102f78:	eb e2                	jmp    f0102f5c <user_mem_check+0x72>

f0102f7a <user_mem_assert>:
{
f0102f7a:	55                   	push   %ebp
f0102f7b:	89 e5                	mov    %esp,%ebp
f0102f7d:	53                   	push   %ebx
f0102f7e:	83 ec 04             	sub    $0x4,%esp
f0102f81:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0102f84:	8b 45 14             	mov    0x14(%ebp),%eax
f0102f87:	83 c8 04             	or     $0x4,%eax
f0102f8a:	50                   	push   %eax
f0102f8b:	ff 75 10             	pushl  0x10(%ebp)
f0102f8e:	ff 75 0c             	pushl  0xc(%ebp)
f0102f91:	53                   	push   %ebx
f0102f92:	e8 53 ff ff ff       	call   f0102eea <user_mem_check>
f0102f97:	83 c4 10             	add    $0x10,%esp
f0102f9a:	85 c0                	test   %eax,%eax
f0102f9c:	78 05                	js     f0102fa3 <user_mem_assert+0x29>
}
f0102f9e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102fa1:	c9                   	leave  
f0102fa2:	c3                   	ret    
		cprintf("[%08x] user_mem_check assertion failure for "
f0102fa3:	83 ec 04             	sub    $0x4,%esp
f0102fa6:	ff 35 3c 72 23 f0    	pushl  0xf023723c
f0102fac:	ff 73 48             	pushl  0x48(%ebx)
f0102faf:	68 e0 75 10 f0       	push   $0xf01075e0
f0102fb4:	e8 43 09 00 00       	call   f01038fc <cprintf>
		env_destroy(env);	// may not return
f0102fb9:	89 1c 24             	mov    %ebx,(%esp)
f0102fbc:	e8 74 06 00 00       	call   f0103635 <env_destroy>
f0102fc1:	83 c4 10             	add    $0x10,%esp
}
f0102fc4:	eb d8                	jmp    f0102f9e <user_mem_assert+0x24>

f0102fc6 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0102fc6:	55                   	push   %ebp
f0102fc7:	89 e5                	mov    %esp,%ebp
f0102fc9:	57                   	push   %edi
f0102fca:	56                   	push   %esi
f0102fcb:	53                   	push   %ebx
f0102fcc:	83 ec 0c             	sub    $0xc,%esp
f0102fcf:	89 c7                	mov    %eax,%edi
	// LAB 3: Your code here.
	void* i;
	for (i = ROUNDDOWN(va, PGSIZE); i < ROUNDUP(va + len, PGSIZE); i+=PGSIZE){
f0102fd1:	89 d3                	mov    %edx,%ebx
f0102fd3:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0102fd9:	8d b4 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%esi
f0102fe0:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
f0102fe6:	39 f3                	cmp    %esi,%ebx
f0102fe8:	73 5c                	jae    f0103046 <region_alloc+0x80>
		struct PageInfo *pginfo = page_alloc(0);
f0102fea:	83 ec 0c             	sub    $0xc,%esp
f0102fed:	6a 00                	push   $0x0
f0102fef:	e8 9d df ff ff       	call   f0100f91 <page_alloc>
		if (!pginfo) {
f0102ff4:	83 c4 10             	add    $0x10,%esp
f0102ff7:	85 c0                	test   %eax,%eax
f0102ff9:	74 20                	je     f010301b <region_alloc+0x55>
			 panic("region_alloc:%e", -E_NO_MEM);
		}
		pginfo->pp_ref++;
f0102ffb:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
		int r = page_insert(e->env_pgdir, pginfo, i, PTE_W | PTE_U | PTE_P);
f0103000:	6a 07                	push   $0x7
f0103002:	53                   	push   %ebx
f0103003:	50                   	push   %eax
f0103004:	ff 77 60             	pushl  0x60(%edi)
f0103007:	e8 46 e2 ff ff       	call   f0101252 <page_insert>
		if (r < 0) {
f010300c:	83 c4 10             	add    $0x10,%esp
f010300f:	85 c0                	test   %eax,%eax
f0103011:	78 1e                	js     f0103031 <region_alloc+0x6b>
	for (i = ROUNDDOWN(va, PGSIZE); i < ROUNDUP(va + len, PGSIZE); i+=PGSIZE){
f0103013:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103019:	eb cb                	jmp    f0102fe6 <region_alloc+0x20>
			 panic("region_alloc:%e", -E_NO_MEM);
f010301b:	6a fc                	push   $0xfffffffc
f010301d:	68 15 76 10 f0       	push   $0xf0107615
f0103022:	68 2b 01 00 00       	push   $0x12b
f0103027:	68 25 76 10 f0       	push   $0xf0107625
f010302c:	e8 63 d0 ff ff       	call   f0100094 <_panic>
			 panic("region_alloc:%e", r);
f0103031:	50                   	push   %eax
f0103032:	68 15 76 10 f0       	push   $0xf0107615
f0103037:	68 30 01 00 00       	push   $0x130
f010303c:	68 25 76 10 f0       	push   $0xf0107625
f0103041:	e8 4e d0 ff ff       	call   f0100094 <_panic>
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
}
f0103046:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103049:	5b                   	pop    %ebx
f010304a:	5e                   	pop    %esi
f010304b:	5f                   	pop    %edi
f010304c:	5d                   	pop    %ebp
f010304d:	c3                   	ret    

f010304e <envid2env>:
{
f010304e:	55                   	push   %ebp
f010304f:	89 e5                	mov    %esp,%ebp
f0103051:	56                   	push   %esi
f0103052:	53                   	push   %ebx
f0103053:	8b 45 08             	mov    0x8(%ebp),%eax
f0103056:	8b 55 10             	mov    0x10(%ebp),%edx
	if (envid == 0) {
f0103059:	85 c0                	test   %eax,%eax
f010305b:	74 2e                	je     f010308b <envid2env+0x3d>
	e = &envs[ENVX(envid)];
f010305d:	89 c3                	mov    %eax,%ebx
f010305f:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0103065:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f0103068:	03 1d 48 72 23 f0    	add    0xf0237248,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f010306e:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0103072:	74 31                	je     f01030a5 <envid2env+0x57>
f0103074:	39 43 48             	cmp    %eax,0x48(%ebx)
f0103077:	75 2c                	jne    f01030a5 <envid2env+0x57>
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0103079:	84 d2                	test   %dl,%dl
f010307b:	75 38                	jne    f01030b5 <envid2env+0x67>
	*env_store = e;
f010307d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103080:	89 18                	mov    %ebx,(%eax)
	return 0;
f0103082:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103087:	5b                   	pop    %ebx
f0103088:	5e                   	pop    %esi
f0103089:	5d                   	pop    %ebp
f010308a:	c3                   	ret    
		*env_store = curenv;
f010308b:	e8 ca 2c 00 00       	call   f0105d5a <cpunum>
f0103090:	6b c0 74             	imul   $0x74,%eax,%eax
f0103093:	8b 80 28 80 23 f0    	mov    -0xfdc7fd8(%eax),%eax
f0103099:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010309c:	89 01                	mov    %eax,(%ecx)
		return 0;
f010309e:	b8 00 00 00 00       	mov    $0x0,%eax
f01030a3:	eb e2                	jmp    f0103087 <envid2env+0x39>
		*env_store = 0;
f01030a5:	8b 45 0c             	mov    0xc(%ebp),%eax
f01030a8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f01030ae:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01030b3:	eb d2                	jmp    f0103087 <envid2env+0x39>
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f01030b5:	e8 a0 2c 00 00       	call   f0105d5a <cpunum>
f01030ba:	6b c0 74             	imul   $0x74,%eax,%eax
f01030bd:	39 98 28 80 23 f0    	cmp    %ebx,-0xfdc7fd8(%eax)
f01030c3:	74 b8                	je     f010307d <envid2env+0x2f>
f01030c5:	8b 73 4c             	mov    0x4c(%ebx),%esi
f01030c8:	e8 8d 2c 00 00       	call   f0105d5a <cpunum>
f01030cd:	6b c0 74             	imul   $0x74,%eax,%eax
f01030d0:	8b 80 28 80 23 f0    	mov    -0xfdc7fd8(%eax),%eax
f01030d6:	3b 70 48             	cmp    0x48(%eax),%esi
f01030d9:	74 a2                	je     f010307d <envid2env+0x2f>
		*env_store = 0;
f01030db:	8b 45 0c             	mov    0xc(%ebp),%eax
f01030de:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f01030e4:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01030e9:	eb 9c                	jmp    f0103087 <envid2env+0x39>

f01030eb <env_init_percpu>:
	asm volatile("lgdt (%0)" : : "r" (p));
f01030eb:	b8 20 33 12 f0       	mov    $0xf0123320,%eax
f01030f0:	0f 01 10             	lgdtl  (%eax)
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f01030f3:	b8 23 00 00 00       	mov    $0x23,%eax
f01030f8:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f01030fa:	8e e0                	mov    %eax,%fs
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f01030fc:	b8 10 00 00 00       	mov    $0x10,%eax
f0103101:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f0103103:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f0103105:	8e d0                	mov    %eax,%ss
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f0103107:	ea 0e 31 10 f0 08 00 	ljmp   $0x8,$0xf010310e
	asm volatile("lldt %0" : : "r" (sel));
f010310e:	b8 00 00 00 00       	mov    $0x0,%eax
f0103113:	0f 00 d0             	lldt   %ax
}
f0103116:	c3                   	ret    

f0103117 <env_init>:
{
f0103117:	55                   	push   %ebp
f0103118:	89 e5                	mov    %esp,%ebp
f010311a:	56                   	push   %esi
f010311b:	53                   	push   %ebx
		envs[i].env_id = 0;
f010311c:	8b 35 48 72 23 f0    	mov    0xf0237248,%esi
f0103122:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f0103128:	89 f3                	mov    %esi,%ebx
f010312a:	ba 00 00 00 00       	mov    $0x0,%edx
f010312f:	eb 02                	jmp    f0103133 <env_init+0x1c>
f0103131:	89 c8                	mov    %ecx,%eax
f0103133:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_status = ENV_FREE;
f010313a:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
		envs[i].env_link = env_free_list;
f0103141:	89 50 44             	mov    %edx,0x44(%eax)
f0103144:	8d 48 84             	lea    -0x7c(%eax),%ecx
		env_free_list = &envs[i];
f0103147:	89 c2                	mov    %eax,%edx
	for (i = NENV - 1; i >= 0; i--) {
f0103149:	39 d8                	cmp    %ebx,%eax
f010314b:	75 e4                	jne    f0103131 <env_init+0x1a>
f010314d:	89 35 4c 72 23 f0    	mov    %esi,0xf023724c
	env_init_percpu();
f0103153:	e8 93 ff ff ff       	call   f01030eb <env_init_percpu>
}
f0103158:	5b                   	pop    %ebx
f0103159:	5e                   	pop    %esi
f010315a:	5d                   	pop    %ebp
f010315b:	c3                   	ret    

f010315c <env_alloc>:
{
f010315c:	55                   	push   %ebp
f010315d:	89 e5                	mov    %esp,%ebp
f010315f:	53                   	push   %ebx
f0103160:	83 ec 04             	sub    $0x4,%esp
	if (!(e = env_free_list))
f0103163:	8b 1d 4c 72 23 f0    	mov    0xf023724c,%ebx
f0103169:	85 db                	test   %ebx,%ebx
f010316b:	0f 84 92 01 00 00    	je     f0103303 <env_alloc+0x1a7>
	if (!(p = page_alloc(ALLOC_ZERO)))
f0103171:	83 ec 0c             	sub    $0xc,%esp
f0103174:	6a 01                	push   $0x1
f0103176:	e8 16 de ff ff       	call   f0100f91 <page_alloc>
f010317b:	83 c4 10             	add    $0x10,%esp
f010317e:	85 c0                	test   %eax,%eax
f0103180:	0f 84 84 01 00 00    	je     f010330a <env_alloc+0x1ae>
	return (pp - pages) << PGSHIFT;
f0103186:	89 c2                	mov    %eax,%edx
f0103188:	2b 15 90 7e 23 f0    	sub    0xf0237e90,%edx
f010318e:	c1 fa 03             	sar    $0x3,%edx
f0103191:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0103194:	89 d1                	mov    %edx,%ecx
f0103196:	c1 e9 0c             	shr    $0xc,%ecx
f0103199:	3b 0d 88 7e 23 f0    	cmp    0xf0237e88,%ecx
f010319f:	0f 83 37 01 00 00    	jae    f01032dc <env_alloc+0x180>
	return (void *)(pa + KERNBASE);
f01031a5:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f01031ab:	89 53 60             	mov    %edx,0x60(%ebx)
	p->pp_ref++;
f01031ae:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
f01031b3:	b8 00 00 00 00       	mov    $0x0,%eax
		e->env_pgdir[i] = 0;
f01031b8:	8b 53 60             	mov    0x60(%ebx),%edx
f01031bb:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
f01031c2:	83 c0 04             	add    $0x4,%eax
	for(i = 0; i < PDX(UTOP); i++) {
f01031c5:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f01031ca:	75 ec                	jne    f01031b8 <env_alloc+0x5c>
		e->env_pgdir[i] = kern_pgdir[i];
f01031cc:	8b 15 8c 7e 23 f0    	mov    0xf0237e8c,%edx
f01031d2:	8b 0c 02             	mov    (%edx,%eax,1),%ecx
f01031d5:	8b 53 60             	mov    0x60(%ebx),%edx
f01031d8:	89 0c 02             	mov    %ecx,(%edx,%eax,1)
f01031db:	83 c0 04             	add    $0x4,%eax
	for(i = PDX(UTOP); i < NPDENTRIES; i++) {
f01031de:	3d 00 10 00 00       	cmp    $0x1000,%eax
f01031e3:	75 e7                	jne    f01031cc <env_alloc+0x70>
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f01031e5:	8b 43 60             	mov    0x60(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f01031e8:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01031ed:	0f 86 fb 00 00 00    	jbe    f01032ee <env_alloc+0x192>
	return (physaddr_t)kva - KERNBASE;
f01031f3:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01031f9:	83 ca 05             	or     $0x5,%edx
f01031fc:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0103202:	8b 43 48             	mov    0x48(%ebx),%eax
f0103205:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f010320a:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f010320f:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103214:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f0103217:	89 da                	mov    %ebx,%edx
f0103219:	2b 15 48 72 23 f0    	sub    0xf0237248,%edx
f010321f:	c1 fa 02             	sar    $0x2,%edx
f0103222:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f0103228:	09 d0                	or     %edx,%eax
f010322a:	89 43 48             	mov    %eax,0x48(%ebx)
	e->env_parent_id = parent_id;
f010322d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103230:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0103233:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f010323a:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0103241:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0103248:	83 ec 04             	sub    $0x4,%esp
f010324b:	6a 44                	push   $0x44
f010324d:	6a 00                	push   $0x0
f010324f:	53                   	push   %ebx
f0103250:	e8 05 25 00 00       	call   f010575a <memset>
	e->env_tf.tf_ds = GD_UD | 3;
f0103255:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f010325b:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0103261:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0103267:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f010326e:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	e->env_tf.tf_eflags |= FL_IF;
f0103274:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)
	e->env_pgfault_upcall = 0;
f010327b:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)
	e->env_ipc_recving = 0;
f0103282:	c6 43 68 00          	movb   $0x0,0x68(%ebx)
	env_free_list = e->env_link;
f0103286:	8b 43 44             	mov    0x44(%ebx),%eax
f0103289:	a3 4c 72 23 f0       	mov    %eax,0xf023724c
	*newenv_store = e;
f010328e:	8b 45 08             	mov    0x8(%ebp),%eax
f0103291:	89 18                	mov    %ebx,(%eax)
	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103293:	8b 5b 48             	mov    0x48(%ebx),%ebx
f0103296:	e8 bf 2a 00 00       	call   f0105d5a <cpunum>
f010329b:	6b c0 74             	imul   $0x74,%eax,%eax
f010329e:	83 c4 10             	add    $0x10,%esp
f01032a1:	ba 00 00 00 00       	mov    $0x0,%edx
f01032a6:	83 b8 28 80 23 f0 00 	cmpl   $0x0,-0xfdc7fd8(%eax)
f01032ad:	74 11                	je     f01032c0 <env_alloc+0x164>
f01032af:	e8 a6 2a 00 00       	call   f0105d5a <cpunum>
f01032b4:	6b c0 74             	imul   $0x74,%eax,%eax
f01032b7:	8b 80 28 80 23 f0    	mov    -0xfdc7fd8(%eax),%eax
f01032bd:	8b 50 48             	mov    0x48(%eax),%edx
f01032c0:	83 ec 04             	sub    $0x4,%esp
f01032c3:	53                   	push   %ebx
f01032c4:	52                   	push   %edx
f01032c5:	68 30 76 10 f0       	push   $0xf0107630
f01032ca:	e8 2d 06 00 00       	call   f01038fc <cprintf>
	return 0;
f01032cf:	83 c4 10             	add    $0x10,%esp
f01032d2:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01032d7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01032da:	c9                   	leave  
f01032db:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01032dc:	52                   	push   %edx
f01032dd:	68 54 64 10 f0       	push   $0xf0106454
f01032e2:	6a 58                	push   $0x58
f01032e4:	68 a4 69 10 f0       	push   $0xf01069a4
f01032e9:	e8 a6 cd ff ff       	call   f0100094 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01032ee:	50                   	push   %eax
f01032ef:	68 78 64 10 f0       	push   $0xf0106478
f01032f4:	68 ce 00 00 00       	push   $0xce
f01032f9:	68 25 76 10 f0       	push   $0xf0107625
f01032fe:	e8 91 cd ff ff       	call   f0100094 <_panic>
		return -E_NO_FREE_ENV;
f0103303:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0103308:	eb cd                	jmp    f01032d7 <env_alloc+0x17b>
		return -E_NO_MEM;
f010330a:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f010330f:	eb c6                	jmp    f01032d7 <env_alloc+0x17b>

f0103311 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f0103311:	55                   	push   %ebp
f0103312:	89 e5                	mov    %esp,%ebp
f0103314:	57                   	push   %edi
f0103315:	56                   	push   %esi
f0103316:	53                   	push   %ebx
f0103317:	83 ec 34             	sub    $0x34,%esp
f010331a:	8b 75 08             	mov    0x8(%ebp),%esi
	// LAB 3: Your code here.
	struct 	Env *e;	
	int r = env_alloc(&e, (envid_t)0);
f010331d:	6a 00                	push   $0x0
f010331f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103322:	50                   	push   %eax
f0103323:	e8 34 fe ff ff       	call   f010315c <env_alloc>
	if (r < 0) {
f0103328:	83 c4 10             	add    $0x10,%esp
f010332b:	85 c0                	test   %eax,%eax
f010332d:	78 36                	js     f0103365 <env_create+0x54>
		 panic("env_create: %e", r);
	}
//	cprintf("new_env:%p\n",e);
	e->env_type = type;
f010332f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103332:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103335:	89 47 50             	mov    %eax,0x50(%edi)
	if (elf->e_magic != ELF_MAGIC) {
f0103338:	81 3e 7f 45 4c 46    	cmpl   $0x464c457f,(%esi)
f010333e:	75 3a                	jne    f010337a <env_create+0x69>
	ph = (struct Proghdr *) ((uint8_t *)elf + elf->e_phoff);
f0103340:	89 f3                	mov    %esi,%ebx
f0103342:	03 5e 1c             	add    0x1c(%esi),%ebx
	eph = ph + elf->e_phnum;
f0103345:	0f b7 46 2c          	movzwl 0x2c(%esi),%eax
f0103349:	c1 e0 05             	shl    $0x5,%eax
f010334c:	01 d8                	add    %ebx,%eax
f010334e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	lcr3(PADDR(e->env_pgdir));
f0103351:	8b 47 60             	mov    0x60(%edi),%eax
	if ((uint32_t)kva < KERNBASE)
f0103354:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103359:	76 36                	jbe    f0103391 <env_create+0x80>
	return (physaddr_t)kva - KERNBASE;
f010335b:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0103360:	0f 22 d8             	mov    %eax,%cr3
f0103363:	eb 5b                	jmp    f01033c0 <env_create+0xaf>
		 panic("env_create: %e", r);
f0103365:	50                   	push   %eax
f0103366:	68 45 76 10 f0       	push   $0xf0107645
f010336b:	68 9e 01 00 00       	push   $0x19e
f0103370:	68 25 76 10 f0       	push   $0xf0107625
f0103375:	e8 1a cd ff ff       	call   f0100094 <_panic>
		 panic("load_icode: not an Elf file");
f010337a:	83 ec 04             	sub    $0x4,%esp
f010337d:	68 54 76 10 f0       	push   $0xf0107654
f0103382:	68 75 01 00 00       	push   $0x175
f0103387:	68 25 76 10 f0       	push   $0xf0107625
f010338c:	e8 03 cd ff ff       	call   f0100094 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103391:	50                   	push   %eax
f0103392:	68 78 64 10 f0       	push   $0xf0106478
f0103397:	68 7a 01 00 00       	push   $0x17a
f010339c:	68 25 76 10 f0       	push   $0xf0107625
f01033a1:	e8 ee cc ff ff       	call   f0100094 <_panic>
					 panic("load_icode: file size is greater than memory size");
f01033a6:	83 ec 04             	sub    $0x4,%esp
f01033a9:	68 94 76 10 f0       	push   $0xf0107694
f01033ae:	68 7e 01 00 00       	push   $0x17e
f01033b3:	68 25 76 10 f0       	push   $0xf0107625
f01033b8:	e8 d7 cc ff ff       	call   f0100094 <_panic>
	for (; ph<eph; ph++) {
f01033bd:	83 c3 20             	add    $0x20,%ebx
f01033c0:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f01033c3:	76 47                	jbe    f010340c <env_create+0xfb>
		if (ph->p_type == ELF_PROG_LOAD) {
f01033c5:	83 3b 01             	cmpl   $0x1,(%ebx)
f01033c8:	75 f3                	jne    f01033bd <env_create+0xac>
			 if (ph->p_filesz > ph->p_memsz) {
f01033ca:	8b 4b 14             	mov    0x14(%ebx),%ecx
f01033cd:	39 4b 10             	cmp    %ecx,0x10(%ebx)
f01033d0:	77 d4                	ja     f01033a6 <env_create+0x95>
			 region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f01033d2:	8b 53 08             	mov    0x8(%ebx),%edx
f01033d5:	89 f8                	mov    %edi,%eax
f01033d7:	e8 ea fb ff ff       	call   f0102fc6 <region_alloc>
			 memcpy((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
f01033dc:	83 ec 04             	sub    $0x4,%esp
f01033df:	ff 73 10             	pushl  0x10(%ebx)
f01033e2:	89 f0                	mov    %esi,%eax
f01033e4:	03 43 04             	add    0x4(%ebx),%eax
f01033e7:	50                   	push   %eax
f01033e8:	ff 73 08             	pushl  0x8(%ebx)
f01033eb:	e8 14 24 00 00       	call   f0105804 <memcpy>
			 memset((void *)ph->p_va + ph->p_filesz, 0, ph->p_memsz - ph->p_filesz);
f01033f0:	8b 43 10             	mov    0x10(%ebx),%eax
f01033f3:	83 c4 0c             	add    $0xc,%esp
f01033f6:	8b 53 14             	mov    0x14(%ebx),%edx
f01033f9:	29 c2                	sub    %eax,%edx
f01033fb:	52                   	push   %edx
f01033fc:	6a 00                	push   $0x0
f01033fe:	03 43 08             	add    0x8(%ebx),%eax
f0103401:	50                   	push   %eax
f0103402:	e8 53 23 00 00       	call   f010575a <memset>
f0103407:	83 c4 10             	add    $0x10,%esp
f010340a:	eb b1                	jmp    f01033bd <env_create+0xac>
	e->env_tf.tf_eip = elf->e_entry;
f010340c:	8b 46 18             	mov    0x18(%esi),%eax
f010340f:	89 47 30             	mov    %eax,0x30(%edi)
	region_alloc(e, (void *)USTACKTOP - PGSIZE, PGSIZE);
f0103412:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0103417:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f010341c:	89 f8                	mov    %edi,%eax
f010341e:	e8 a3 fb ff ff       	call   f0102fc6 <region_alloc>
	lcr3(PADDR(kern_pgdir));
f0103423:	a1 8c 7e 23 f0       	mov    0xf0237e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f0103428:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010342d:	76 10                	jbe    f010343f <env_create+0x12e>
	return (physaddr_t)kva - KERNBASE;
f010342f:	05 00 00 00 10       	add    $0x10000000,%eax
f0103434:	0f 22 d8             	mov    %eax,%cr3
//	cprintf("binary:%p\n", binary);
	load_icode(e, binary);
}
f0103437:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010343a:	5b                   	pop    %ebx
f010343b:	5e                   	pop    %esi
f010343c:	5f                   	pop    %edi
f010343d:	5d                   	pop    %ebp
f010343e:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010343f:	50                   	push   %eax
f0103440:	68 78 64 10 f0       	push   $0xf0106478
f0103445:	68 8d 01 00 00       	push   $0x18d
f010344a:	68 25 76 10 f0       	push   $0xf0107625
f010344f:	e8 40 cc ff ff       	call   f0100094 <_panic>

f0103454 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0103454:	55                   	push   %ebp
f0103455:	89 e5                	mov    %esp,%ebp
f0103457:	57                   	push   %edi
f0103458:	56                   	push   %esi
f0103459:	53                   	push   %ebx
f010345a:	83 ec 1c             	sub    $0x1c,%esp
f010345d:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103460:	e8 f5 28 00 00       	call   f0105d5a <cpunum>
f0103465:	6b c0 74             	imul   $0x74,%eax,%eax
f0103468:	39 b8 28 80 23 f0    	cmp    %edi,-0xfdc7fd8(%eax)
f010346e:	74 48                	je     f01034b8 <env_free+0x64>
		lcr3(PADDR(kern_pgdir));

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103470:	8b 5f 48             	mov    0x48(%edi),%ebx
f0103473:	e8 e2 28 00 00       	call   f0105d5a <cpunum>
f0103478:	6b c0 74             	imul   $0x74,%eax,%eax
f010347b:	ba 00 00 00 00       	mov    $0x0,%edx
f0103480:	83 b8 28 80 23 f0 00 	cmpl   $0x0,-0xfdc7fd8(%eax)
f0103487:	74 11                	je     f010349a <env_free+0x46>
f0103489:	e8 cc 28 00 00       	call   f0105d5a <cpunum>
f010348e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103491:	8b 80 28 80 23 f0    	mov    -0xfdc7fd8(%eax),%eax
f0103497:	8b 50 48             	mov    0x48(%eax),%edx
f010349a:	83 ec 04             	sub    $0x4,%esp
f010349d:	53                   	push   %ebx
f010349e:	52                   	push   %edx
f010349f:	68 70 76 10 f0       	push   $0xf0107670
f01034a4:	e8 53 04 00 00       	call   f01038fc <cprintf>
f01034a9:	83 c4 10             	add    $0x10,%esp
f01034ac:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f01034b3:	e9 a9 00 00 00       	jmp    f0103561 <env_free+0x10d>
		lcr3(PADDR(kern_pgdir));
f01034b8:	a1 8c 7e 23 f0       	mov    0xf0237e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f01034bd:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01034c2:	76 0a                	jbe    f01034ce <env_free+0x7a>
	return (physaddr_t)kva - KERNBASE;
f01034c4:	05 00 00 00 10       	add    $0x10000000,%eax
f01034c9:	0f 22 d8             	mov    %eax,%cr3
f01034cc:	eb a2                	jmp    f0103470 <env_free+0x1c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01034ce:	50                   	push   %eax
f01034cf:	68 78 64 10 f0       	push   $0xf0106478
f01034d4:	68 b4 01 00 00       	push   $0x1b4
f01034d9:	68 25 76 10 f0       	push   $0xf0107625
f01034de:	e8 b1 cb ff ff       	call   f0100094 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01034e3:	56                   	push   %esi
f01034e4:	68 54 64 10 f0       	push   $0xf0106454
f01034e9:	68 c3 01 00 00       	push   $0x1c3
f01034ee:	68 25 76 10 f0       	push   $0xf0107625
f01034f3:	e8 9c cb ff ff       	call   f0100094 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01034f8:	83 ec 08             	sub    $0x8,%esp
f01034fb:	89 d8                	mov    %ebx,%eax
f01034fd:	c1 e0 0c             	shl    $0xc,%eax
f0103500:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103503:	50                   	push   %eax
f0103504:	ff 77 60             	pushl  0x60(%edi)
f0103507:	e8 00 dd ff ff       	call   f010120c <page_remove>
f010350c:	83 c4 10             	add    $0x10,%esp
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f010350f:	83 c3 01             	add    $0x1,%ebx
f0103512:	83 c6 04             	add    $0x4,%esi
f0103515:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f010351b:	74 07                	je     f0103524 <env_free+0xd0>
			if (pt[pteno] & PTE_P)
f010351d:	f6 06 01             	testb  $0x1,(%esi)
f0103520:	74 ed                	je     f010350f <env_free+0xbb>
f0103522:	eb d4                	jmp    f01034f8 <env_free+0xa4>
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103524:	8b 47 60             	mov    0x60(%edi),%eax
f0103527:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010352a:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
	if (PGNUM(pa) >= npages)
f0103531:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103534:	3b 05 88 7e 23 f0    	cmp    0xf0237e88,%eax
f010353a:	73 69                	jae    f01035a5 <env_free+0x151>
		page_decref(pa2page(pa));
f010353c:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f010353f:	a1 90 7e 23 f0       	mov    0xf0237e90,%eax
f0103544:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103547:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f010354a:	50                   	push   %eax
f010354b:	e8 ee da ff ff       	call   f010103e <page_decref>
f0103550:	83 c4 10             	add    $0x10,%esp
f0103553:	83 45 e0 04          	addl   $0x4,-0x20(%ebp)
f0103557:	8b 45 e0             	mov    -0x20(%ebp),%eax
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f010355a:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f010355f:	74 58                	je     f01035b9 <env_free+0x165>
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103561:	8b 47 60             	mov    0x60(%edi),%eax
f0103564:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103567:	8b 34 10             	mov    (%eax,%edx,1),%esi
f010356a:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0103570:	74 e1                	je     f0103553 <env_free+0xff>
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103572:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	if (PGNUM(pa) >= npages)
f0103578:	89 f0                	mov    %esi,%eax
f010357a:	c1 e8 0c             	shr    $0xc,%eax
f010357d:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0103580:	39 05 88 7e 23 f0    	cmp    %eax,0xf0237e88
f0103586:	0f 86 57 ff ff ff    	jbe    f01034e3 <env_free+0x8f>
	return (void *)(pa + KERNBASE);
f010358c:	81 ee 00 00 00 10    	sub    $0x10000000,%esi
f0103592:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103595:	c1 e0 14             	shl    $0x14,%eax
f0103598:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f010359b:	bb 00 00 00 00       	mov    $0x0,%ebx
f01035a0:	e9 78 ff ff ff       	jmp    f010351d <env_free+0xc9>
		panic("pa2page called with invalid pa");
f01035a5:	83 ec 04             	sub    $0x4,%esp
f01035a8:	68 dc 6d 10 f0       	push   $0xf0106ddc
f01035ad:	6a 51                	push   $0x51
f01035af:	68 a4 69 10 f0       	push   $0xf01069a4
f01035b4:	e8 db ca ff ff       	call   f0100094 <_panic>
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f01035b9:	8b 47 60             	mov    0x60(%edi),%eax
	if ((uint32_t)kva < KERNBASE)
f01035bc:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01035c1:	76 49                	jbe    f010360c <env_free+0x1b8>
	e->env_pgdir = 0;
f01035c3:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
	return (physaddr_t)kva - KERNBASE;
f01035ca:	05 00 00 00 10       	add    $0x10000000,%eax
	if (PGNUM(pa) >= npages)
f01035cf:	c1 e8 0c             	shr    $0xc,%eax
f01035d2:	3b 05 88 7e 23 f0    	cmp    0xf0237e88,%eax
f01035d8:	73 47                	jae    f0103621 <env_free+0x1cd>
	page_decref(pa2page(pa));
f01035da:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f01035dd:	8b 15 90 7e 23 f0    	mov    0xf0237e90,%edx
f01035e3:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f01035e6:	50                   	push   %eax
f01035e7:	e8 52 da ff ff       	call   f010103e <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f01035ec:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f01035f3:	a1 4c 72 23 f0       	mov    0xf023724c,%eax
f01035f8:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f01035fb:	89 3d 4c 72 23 f0    	mov    %edi,0xf023724c
}
f0103601:	83 c4 10             	add    $0x10,%esp
f0103604:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103607:	5b                   	pop    %ebx
f0103608:	5e                   	pop    %esi
f0103609:	5f                   	pop    %edi
f010360a:	5d                   	pop    %ebp
f010360b:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010360c:	50                   	push   %eax
f010360d:	68 78 64 10 f0       	push   $0xf0106478
f0103612:	68 d1 01 00 00       	push   $0x1d1
f0103617:	68 25 76 10 f0       	push   $0xf0107625
f010361c:	e8 73 ca ff ff       	call   f0100094 <_panic>
		panic("pa2page called with invalid pa");
f0103621:	83 ec 04             	sub    $0x4,%esp
f0103624:	68 dc 6d 10 f0       	push   $0xf0106ddc
f0103629:	6a 51                	push   $0x51
f010362b:	68 a4 69 10 f0       	push   $0xf01069a4
f0103630:	e8 5f ca ff ff       	call   f0100094 <_panic>

f0103635 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0103635:	55                   	push   %ebp
f0103636:	89 e5                	mov    %esp,%ebp
f0103638:	53                   	push   %ebx
f0103639:	83 ec 04             	sub    $0x4,%esp
f010363c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f010363f:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0103643:	74 21                	je     f0103666 <env_destroy+0x31>
		e->env_status = ENV_DYING;
		return;
	}

	env_free(e);
f0103645:	83 ec 0c             	sub    $0xc,%esp
f0103648:	53                   	push   %ebx
f0103649:	e8 06 fe ff ff       	call   f0103454 <env_free>

	if (curenv == e) {
f010364e:	e8 07 27 00 00       	call   f0105d5a <cpunum>
f0103653:	6b c0 74             	imul   $0x74,%eax,%eax
f0103656:	83 c4 10             	add    $0x10,%esp
f0103659:	39 98 28 80 23 f0    	cmp    %ebx,-0xfdc7fd8(%eax)
f010365f:	74 1e                	je     f010367f <env_destroy+0x4a>
		curenv = NULL;
		sched_yield();
	}
}
f0103661:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103664:	c9                   	leave  
f0103665:	c3                   	ret    
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103666:	e8 ef 26 00 00       	call   f0105d5a <cpunum>
f010366b:	6b c0 74             	imul   $0x74,%eax,%eax
f010366e:	39 98 28 80 23 f0    	cmp    %ebx,-0xfdc7fd8(%eax)
f0103674:	74 cf                	je     f0103645 <env_destroy+0x10>
		e->env_status = ENV_DYING;
f0103676:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f010367d:	eb e2                	jmp    f0103661 <env_destroy+0x2c>
		curenv = NULL;
f010367f:	e8 d6 26 00 00       	call   f0105d5a <cpunum>
f0103684:	6b c0 74             	imul   $0x74,%eax,%eax
f0103687:	c7 80 28 80 23 f0 00 	movl   $0x0,-0xfdc7fd8(%eax)
f010368e:	00 00 00 
		sched_yield();
f0103691:	e8 b9 0e 00 00       	call   f010454f <sched_yield>

f0103696 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103696:	55                   	push   %ebp
f0103697:	89 e5                	mov    %esp,%ebp
f0103699:	53                   	push   %ebx
f010369a:	83 ec 04             	sub    $0x4,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f010369d:	e8 b8 26 00 00       	call   f0105d5a <cpunum>
f01036a2:	6b c0 74             	imul   $0x74,%eax,%eax
f01036a5:	8b 98 28 80 23 f0    	mov    -0xfdc7fd8(%eax),%ebx
f01036ab:	e8 aa 26 00 00       	call   f0105d5a <cpunum>
f01036b0:	89 43 5c             	mov    %eax,0x5c(%ebx)

	asm volatile(
f01036b3:	8b 65 08             	mov    0x8(%ebp),%esp
f01036b6:	61                   	popa   
f01036b7:	07                   	pop    %es
f01036b8:	1f                   	pop    %ds
f01036b9:	83 c4 08             	add    $0x8,%esp
f01036bc:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f01036bd:	83 ec 04             	sub    $0x4,%esp
f01036c0:	68 86 76 10 f0       	push   $0xf0107686
f01036c5:	68 08 02 00 00       	push   $0x208
f01036ca:	68 25 76 10 f0       	push   $0xf0107625
f01036cf:	e8 c0 c9 ff ff       	call   f0100094 <_panic>

f01036d4 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f01036d4:	55                   	push   %ebp
f01036d5:	89 e5                	mov    %esp,%ebp
f01036d7:	53                   	push   %ebx
f01036d8:	83 ec 04             	sub    $0x4,%esp
f01036db:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	if (curenv && curenv->env_status == ENV_RUNNING) {
f01036de:	e8 77 26 00 00       	call   f0105d5a <cpunum>
f01036e3:	6b c0 74             	imul   $0x74,%eax,%eax
f01036e6:	83 b8 28 80 23 f0 00 	cmpl   $0x0,-0xfdc7fd8(%eax)
f01036ed:	74 14                	je     f0103703 <env_run+0x2f>
f01036ef:	e8 66 26 00 00       	call   f0105d5a <cpunum>
f01036f4:	6b c0 74             	imul   $0x74,%eax,%eax
f01036f7:	8b 80 28 80 23 f0    	mov    -0xfdc7fd8(%eax),%eax
f01036fd:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103701:	74 42                	je     f0103745 <env_run+0x71>
		 curenv->env_status = ENV_RUNNABLE;
	}
		 curenv = e;
f0103703:	e8 52 26 00 00       	call   f0105d5a <cpunum>
f0103708:	6b c0 74             	imul   $0x74,%eax,%eax
f010370b:	89 98 28 80 23 f0    	mov    %ebx,-0xfdc7fd8(%eax)
		 e->env_status = ENV_RUNNING;
f0103711:	c7 43 54 03 00 00 00 	movl   $0x3,0x54(%ebx)
		 e->env_runs++ ;
f0103718:	83 43 58 01          	addl   $0x1,0x58(%ebx)
		 lcr3(PADDR(e->env_pgdir));
f010371c:	8b 43 60             	mov    0x60(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f010371f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103724:	76 36                	jbe    f010375c <env_run+0x88>
	return (physaddr_t)kva - KERNBASE;
f0103726:	05 00 00 00 10       	add    $0x10000000,%eax
f010372b:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f010372e:	83 ec 0c             	sub    $0xc,%esp
f0103731:	68 c0 33 12 f0       	push   $0xf01233c0
f0103736:	e8 2b 29 00 00       	call   f0106066 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f010373b:	f3 90                	pause  
//		 cprintf("kern_env.env_run:eip:%p\n", e->env_tf.tf_eip);
//		 cprintf("pgdir:%p\n", e->env_pgdir);
		 //bug 记录，调了一天半，这个bug原因是trapentry.S中对时钟中断的初始化用了TRAPHANDER而不是TRAPHANLDER_NOEC导致异常栈数据格式不对。
//		 if (kernel_lock.cpu) 
         unlock_kernel();
		 env_pop_tf(&e->env_tf);
f010373d:	89 1c 24             	mov    %ebx,(%esp)
f0103740:	e8 51 ff ff ff       	call   f0103696 <env_pop_tf>
		 curenv->env_status = ENV_RUNNABLE;
f0103745:	e8 10 26 00 00       	call   f0105d5a <cpunum>
f010374a:	6b c0 74             	imul   $0x74,%eax,%eax
f010374d:	8b 80 28 80 23 f0    	mov    -0xfdc7fd8(%eax),%eax
f0103753:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
f010375a:	eb a7                	jmp    f0103703 <env_run+0x2f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010375c:	50                   	push   %eax
f010375d:	68 78 64 10 f0       	push   $0xf0106478
f0103762:	68 2c 02 00 00       	push   $0x22c
f0103767:	68 25 76 10 f0       	push   $0xf0107625
f010376c:	e8 23 c9 ff ff       	call   f0100094 <_panic>

f0103771 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103771:	55                   	push   %ebp
f0103772:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103774:	8b 45 08             	mov    0x8(%ebp),%eax
f0103777:	ba 70 00 00 00       	mov    $0x70,%edx
f010377c:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010377d:	ba 71 00 00 00       	mov    $0x71,%edx
f0103782:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103783:	0f b6 c0             	movzbl %al,%eax
}
f0103786:	5d                   	pop    %ebp
f0103787:	c3                   	ret    

f0103788 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103788:	55                   	push   %ebp
f0103789:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010378b:	8b 45 08             	mov    0x8(%ebp),%eax
f010378e:	ba 70 00 00 00       	mov    $0x70,%edx
f0103793:	ee                   	out    %al,(%dx)
f0103794:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103797:	ba 71 00 00 00       	mov    $0x71,%edx
f010379c:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f010379d:	5d                   	pop    %ebp
f010379e:	c3                   	ret    

f010379f <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f010379f:	55                   	push   %ebp
f01037a0:	89 e5                	mov    %esp,%ebp
f01037a2:	56                   	push   %esi
f01037a3:	53                   	push   %ebx
f01037a4:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f01037a7:	66 a3 a8 33 12 f0    	mov    %ax,0xf01233a8
	if (!didinit)
f01037ad:	80 3d 50 72 23 f0 00 	cmpb   $0x0,0xf0237250
f01037b4:	75 07                	jne    f01037bd <irq_setmask_8259A+0x1e>
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
}
f01037b6:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01037b9:	5b                   	pop    %ebx
f01037ba:	5e                   	pop    %esi
f01037bb:	5d                   	pop    %ebp
f01037bc:	c3                   	ret    
f01037bd:	89 c6                	mov    %eax,%esi
f01037bf:	ba 21 00 00 00       	mov    $0x21,%edx
f01037c4:	ee                   	out    %al,(%dx)
	outb(IO_PIC2+1, (char)(mask >> 8));
f01037c5:	66 c1 e8 08          	shr    $0x8,%ax
f01037c9:	ba a1 00 00 00       	mov    $0xa1,%edx
f01037ce:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f01037cf:	83 ec 0c             	sub    $0xc,%esp
f01037d2:	68 c6 76 10 f0       	push   $0xf01076c6
f01037d7:	e8 20 01 00 00       	call   f01038fc <cprintf>
f01037dc:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f01037df:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f01037e4:	0f b7 f6             	movzwl %si,%esi
f01037e7:	f7 d6                	not    %esi
f01037e9:	eb 19                	jmp    f0103804 <irq_setmask_8259A+0x65>
			cprintf(" %d", i);
f01037eb:	83 ec 08             	sub    $0x8,%esp
f01037ee:	53                   	push   %ebx
f01037ef:	68 17 7c 10 f0       	push   $0xf0107c17
f01037f4:	e8 03 01 00 00       	call   f01038fc <cprintf>
f01037f9:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f01037fc:	83 c3 01             	add    $0x1,%ebx
f01037ff:	83 fb 10             	cmp    $0x10,%ebx
f0103802:	74 07                	je     f010380b <irq_setmask_8259A+0x6c>
		if (~mask & (1<<i))
f0103804:	0f a3 de             	bt     %ebx,%esi
f0103807:	73 f3                	jae    f01037fc <irq_setmask_8259A+0x5d>
f0103809:	eb e0                	jmp    f01037eb <irq_setmask_8259A+0x4c>
	cprintf("\n");
f010380b:	83 ec 0c             	sub    $0xc,%esp
f010380e:	68 8a 6c 10 f0       	push   $0xf0106c8a
f0103813:	e8 e4 00 00 00       	call   f01038fc <cprintf>
f0103818:	83 c4 10             	add    $0x10,%esp
f010381b:	eb 99                	jmp    f01037b6 <irq_setmask_8259A+0x17>

f010381d <pic_init>:
{
f010381d:	55                   	push   %ebp
f010381e:	89 e5                	mov    %esp,%ebp
f0103820:	57                   	push   %edi
f0103821:	56                   	push   %esi
f0103822:	53                   	push   %ebx
f0103823:	83 ec 0c             	sub    $0xc,%esp
	didinit = 1;
f0103826:	c6 05 50 72 23 f0 01 	movb   $0x1,0xf0237250
f010382d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103832:	bb 21 00 00 00       	mov    $0x21,%ebx
f0103837:	89 da                	mov    %ebx,%edx
f0103839:	ee                   	out    %al,(%dx)
f010383a:	b9 a1 00 00 00       	mov    $0xa1,%ecx
f010383f:	89 ca                	mov    %ecx,%edx
f0103841:	ee                   	out    %al,(%dx)
f0103842:	bf 11 00 00 00       	mov    $0x11,%edi
f0103847:	be 20 00 00 00       	mov    $0x20,%esi
f010384c:	89 f8                	mov    %edi,%eax
f010384e:	89 f2                	mov    %esi,%edx
f0103850:	ee                   	out    %al,(%dx)
f0103851:	b8 20 00 00 00       	mov    $0x20,%eax
f0103856:	89 da                	mov    %ebx,%edx
f0103858:	ee                   	out    %al,(%dx)
f0103859:	b8 04 00 00 00       	mov    $0x4,%eax
f010385e:	ee                   	out    %al,(%dx)
f010385f:	b8 03 00 00 00       	mov    $0x3,%eax
f0103864:	ee                   	out    %al,(%dx)
f0103865:	bb a0 00 00 00       	mov    $0xa0,%ebx
f010386a:	89 f8                	mov    %edi,%eax
f010386c:	89 da                	mov    %ebx,%edx
f010386e:	ee                   	out    %al,(%dx)
f010386f:	b8 28 00 00 00       	mov    $0x28,%eax
f0103874:	89 ca                	mov    %ecx,%edx
f0103876:	ee                   	out    %al,(%dx)
f0103877:	b8 02 00 00 00       	mov    $0x2,%eax
f010387c:	ee                   	out    %al,(%dx)
f010387d:	b8 01 00 00 00       	mov    $0x1,%eax
f0103882:	ee                   	out    %al,(%dx)
f0103883:	bf 68 00 00 00       	mov    $0x68,%edi
f0103888:	89 f8                	mov    %edi,%eax
f010388a:	89 f2                	mov    %esi,%edx
f010388c:	ee                   	out    %al,(%dx)
f010388d:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0103892:	89 c8                	mov    %ecx,%eax
f0103894:	ee                   	out    %al,(%dx)
f0103895:	89 f8                	mov    %edi,%eax
f0103897:	89 da                	mov    %ebx,%edx
f0103899:	ee                   	out    %al,(%dx)
f010389a:	89 c8                	mov    %ecx,%eax
f010389c:	ee                   	out    %al,(%dx)
	if (irq_mask_8259A != 0xFFFF)
f010389d:	0f b7 05 a8 33 12 f0 	movzwl 0xf01233a8,%eax
f01038a4:	66 83 f8 ff          	cmp    $0xffff,%ax
f01038a8:	75 08                	jne    f01038b2 <pic_init+0x95>
}
f01038aa:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01038ad:	5b                   	pop    %ebx
f01038ae:	5e                   	pop    %esi
f01038af:	5f                   	pop    %edi
f01038b0:	5d                   	pop    %ebp
f01038b1:	c3                   	ret    
		irq_setmask_8259A(irq_mask_8259A);
f01038b2:	83 ec 0c             	sub    $0xc,%esp
f01038b5:	0f b7 c0             	movzwl %ax,%eax
f01038b8:	50                   	push   %eax
f01038b9:	e8 e1 fe ff ff       	call   f010379f <irq_setmask_8259A>
f01038be:	83 c4 10             	add    $0x10,%esp
}
f01038c1:	eb e7                	jmp    f01038aa <pic_init+0x8d>

f01038c3 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01038c3:	55                   	push   %ebp
f01038c4:	89 e5                	mov    %esp,%ebp
f01038c6:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f01038c9:	ff 75 08             	pushl  0x8(%ebp)
f01038cc:	e8 dd ce ff ff       	call   f01007ae <cputchar>
	*cnt++;
}
f01038d1:	83 c4 10             	add    $0x10,%esp
f01038d4:	c9                   	leave  
f01038d5:	c3                   	ret    

f01038d6 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01038d6:	55                   	push   %ebp
f01038d7:	89 e5                	mov    %esp,%ebp
f01038d9:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f01038dc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01038e3:	ff 75 0c             	pushl  0xc(%ebp)
f01038e6:	ff 75 08             	pushl  0x8(%ebp)
f01038e9:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01038ec:	50                   	push   %eax
f01038ed:	68 c3 38 10 f0       	push   $0xf01038c3
f01038f2:	e8 5b 17 00 00       	call   f0105052 <vprintfmt>
	return cnt;
}
f01038f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01038fa:	c9                   	leave  
f01038fb:	c3                   	ret    

f01038fc <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01038fc:	55                   	push   %ebp
f01038fd:	89 e5                	mov    %esp,%ebp
f01038ff:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103902:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103905:	50                   	push   %eax
f0103906:	ff 75 08             	pushl  0x8(%ebp)
f0103909:	e8 c8 ff ff ff       	call   f01038d6 <vcprintf>
	va_end(ap);

	return cnt;
}
f010390e:	c9                   	leave  
f010390f:	c3                   	ret    

f0103910 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103910:	55                   	push   %ebp
f0103911:	89 e5                	mov    %esp,%ebp
f0103913:	56                   	push   %esi
f0103914:	53                   	push   %ebx
	// get a triple fault.  If you set up an individual CPU's TSS
	// wrong, you may not get a fault until you try to return from
	// user space on that CPU.
	//
	// LAB 4: Your code here:
	struct Taskstate *this_ts = &thiscpu->cpu_ts;
f0103915:	e8 40 24 00 00       	call   f0105d5a <cpunum>
f010391a:	6b f0 74             	imul   $0x74,%eax,%esi
f010391d:	8d 9e 2c 80 23 f0    	lea    -0xfdc7fd4(%esi),%ebx
	this_ts->ts_esp0 = KSTACKTOP - thiscpu->cpu_id*(KSTKSIZE + KSTKGAP);
f0103923:	e8 32 24 00 00       	call   f0105d5a <cpunum>
f0103928:	6b c0 74             	imul   $0x74,%eax,%eax
f010392b:	0f b6 88 20 80 23 f0 	movzbl -0xfdc7fe0(%eax),%ecx
f0103932:	c1 e1 10             	shl    $0x10,%ecx
f0103935:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
f010393a:	29 c8                	sub    %ecx,%eax
f010393c:	89 86 30 80 23 f0    	mov    %eax,-0xfdc7fd0(%esi)
	this_ts->ts_ss0 = GD_KD;
f0103942:	66 c7 86 34 80 23 f0 	movw   $0x10,-0xfdc7fcc(%esi)
f0103949:	10 00 
	this_ts->ts_iomb = sizeof(struct Taskstate);
f010394b:	66 c7 86 92 80 23 f0 	movw   $0x68,-0xfdc7f6e(%esi)
f0103952:	68 00 
//	ts.ts_esp0 = KSTACKTOP;
//	ts.ts_ss0 = GD_KD;
//	ts.ts_iomb = sizeof(struct Taskstate);

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3) + thiscpu->cpu_id] = SEG16(STS_T32A, (uint32_t) (this_ts),
f0103954:	e8 01 24 00 00       	call   f0105d5a <cpunum>
f0103959:	6b c0 74             	imul   $0x74,%eax,%eax
f010395c:	0f b6 80 20 80 23 f0 	movzbl -0xfdc7fe0(%eax),%eax
f0103963:	83 c0 05             	add    $0x5,%eax
f0103966:	66 c7 04 c5 40 33 12 	movw   $0x67,-0xfedccc0(,%eax,8)
f010396d:	f0 67 00 
f0103970:	66 89 1c c5 42 33 12 	mov    %bx,-0xfedccbe(,%eax,8)
f0103977:	f0 
f0103978:	89 da                	mov    %ebx,%edx
f010397a:	c1 ea 10             	shr    $0x10,%edx
f010397d:	88 14 c5 44 33 12 f0 	mov    %dl,-0xfedccbc(,%eax,8)
f0103984:	c6 04 c5 45 33 12 f0 	movb   $0x99,-0xfedccbb(,%eax,8)
f010398b:	99 
f010398c:	c6 04 c5 46 33 12 f0 	movb   $0x40,-0xfedccba(,%eax,8)
f0103993:	40 
f0103994:	c1 eb 18             	shr    $0x18,%ebx
f0103997:	88 1c c5 47 33 12 f0 	mov    %bl,-0xfedccb9(,%eax,8)
					sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3) + thiscpu->cpu_id].sd_s = 0;
f010399e:	e8 b7 23 00 00       	call   f0105d5a <cpunum>
f01039a3:	6b c0 74             	imul   $0x74,%eax,%eax
f01039a6:	0f b6 80 20 80 23 f0 	movzbl -0xfdc7fe0(%eax),%eax
f01039ad:	80 24 c5 6d 33 12 f0 	andb   $0xef,-0xfedcc93(,%eax,8)
f01039b4:	ef 

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0 + (thiscpu->cpu_id << 3));
f01039b5:	e8 a0 23 00 00       	call   f0105d5a <cpunum>
f01039ba:	6b c0 74             	imul   $0x74,%eax,%eax
f01039bd:	0f b6 80 20 80 23 f0 	movzbl -0xfdc7fe0(%eax),%eax
f01039c4:	8d 04 c5 28 00 00 00 	lea    0x28(,%eax,8),%eax
	asm volatile("ltr %0" : : "r" (sel));
f01039cb:	0f 00 d8             	ltr    %ax
	asm volatile("lidt (%0)" : : "r" (p));
f01039ce:	b8 ac 33 12 f0       	mov    $0xf01233ac,%eax
f01039d3:	0f 01 18             	lidtl  (%eax)

	// Load the IDT
	lidt(&idt_pd);
}
f01039d6:	5b                   	pop    %ebx
f01039d7:	5e                   	pop    %esi
f01039d8:	5d                   	pop    %ebp
f01039d9:	c3                   	ret    

f01039da <trap_init>:
{
f01039da:	55                   	push   %ebp
f01039db:	89 e5                	mov    %esp,%ebp
f01039dd:	83 ec 08             	sub    $0x8,%esp
	SETGATE(idt[T_DIVIDE], 0, GD_KT, traphandler0, 0);
f01039e0:	b8 d6 43 10 f0       	mov    $0xf01043d6,%eax
f01039e5:	66 a3 60 72 23 f0    	mov    %ax,0xf0237260
f01039eb:	66 c7 05 62 72 23 f0 	movw   $0x8,0xf0237262
f01039f2:	08 00 
f01039f4:	c6 05 64 72 23 f0 00 	movb   $0x0,0xf0237264
f01039fb:	c6 05 65 72 23 f0 8e 	movb   $0x8e,0xf0237265
f0103a02:	c1 e8 10             	shr    $0x10,%eax
f0103a05:	66 a3 66 72 23 f0    	mov    %ax,0xf0237266
    SETGATE(idt[T_DEBUG], 0, GD_KT, traphandler1, 0);
f0103a0b:	b8 e0 43 10 f0       	mov    $0xf01043e0,%eax
f0103a10:	66 a3 68 72 23 f0    	mov    %ax,0xf0237268
f0103a16:	66 c7 05 6a 72 23 f0 	movw   $0x8,0xf023726a
f0103a1d:	08 00 
f0103a1f:	c6 05 6c 72 23 f0 00 	movb   $0x0,0xf023726c
f0103a26:	c6 05 6d 72 23 f0 8e 	movb   $0x8e,0xf023726d
f0103a2d:	c1 e8 10             	shr    $0x10,%eax
f0103a30:	66 a3 6e 72 23 f0    	mov    %ax,0xf023726e
    SETGATE(idt[T_NMI], 0, GD_KT, traphandler2, 0);
f0103a36:	b8 ea 43 10 f0       	mov    $0xf01043ea,%eax
f0103a3b:	66 a3 70 72 23 f0    	mov    %ax,0xf0237270
f0103a41:	66 c7 05 72 72 23 f0 	movw   $0x8,0xf0237272
f0103a48:	08 00 
f0103a4a:	c6 05 74 72 23 f0 00 	movb   $0x0,0xf0237274
f0103a51:	c6 05 75 72 23 f0 8e 	movb   $0x8e,0xf0237275
f0103a58:	c1 e8 10             	shr    $0x10,%eax
f0103a5b:	66 a3 76 72 23 f0    	mov    %ax,0xf0237276
    SETGATE(idt[T_BRKPT], 0, GD_KT, traphandler3, 3);
f0103a61:	b8 f4 43 10 f0       	mov    $0xf01043f4,%eax
f0103a66:	66 a3 78 72 23 f0    	mov    %ax,0xf0237278
f0103a6c:	66 c7 05 7a 72 23 f0 	movw   $0x8,0xf023727a
f0103a73:	08 00 
f0103a75:	c6 05 7c 72 23 f0 00 	movb   $0x0,0xf023727c
f0103a7c:	c6 05 7d 72 23 f0 ee 	movb   $0xee,0xf023727d
f0103a83:	c1 e8 10             	shr    $0x10,%eax
f0103a86:	66 a3 7e 72 23 f0    	mov    %ax,0xf023727e
    SETGATE(idt[T_OFLOW], 0, GD_KT, traphandler4, 0);
f0103a8c:	b8 fa 43 10 f0       	mov    $0xf01043fa,%eax
f0103a91:	66 a3 80 72 23 f0    	mov    %ax,0xf0237280
f0103a97:	66 c7 05 82 72 23 f0 	movw   $0x8,0xf0237282
f0103a9e:	08 00 
f0103aa0:	c6 05 84 72 23 f0 00 	movb   $0x0,0xf0237284
f0103aa7:	c6 05 85 72 23 f0 8e 	movb   $0x8e,0xf0237285
f0103aae:	c1 e8 10             	shr    $0x10,%eax
f0103ab1:	66 a3 86 72 23 f0    	mov    %ax,0xf0237286
    SETGATE(idt[T_BOUND], 0, GD_KT, traphandler5, 0);
f0103ab7:	b8 00 44 10 f0       	mov    $0xf0104400,%eax
f0103abc:	66 a3 88 72 23 f0    	mov    %ax,0xf0237288
f0103ac2:	66 c7 05 8a 72 23 f0 	movw   $0x8,0xf023728a
f0103ac9:	08 00 
f0103acb:	c6 05 8c 72 23 f0 00 	movb   $0x0,0xf023728c
f0103ad2:	c6 05 8d 72 23 f0 8e 	movb   $0x8e,0xf023728d
f0103ad9:	c1 e8 10             	shr    $0x10,%eax
f0103adc:	66 a3 8e 72 23 f0    	mov    %ax,0xf023728e
    SETGATE(idt[T_ILLOP], 0, GD_KT, traphandler6, 0);
f0103ae2:	b8 06 44 10 f0       	mov    $0xf0104406,%eax
f0103ae7:	66 a3 90 72 23 f0    	mov    %ax,0xf0237290
f0103aed:	66 c7 05 92 72 23 f0 	movw   $0x8,0xf0237292
f0103af4:	08 00 
f0103af6:	c6 05 94 72 23 f0 00 	movb   $0x0,0xf0237294
f0103afd:	c6 05 95 72 23 f0 8e 	movb   $0x8e,0xf0237295
f0103b04:	c1 e8 10             	shr    $0x10,%eax
f0103b07:	66 a3 96 72 23 f0    	mov    %ax,0xf0237296
    SETGATE(idt[T_DEVICE], 0, GD_KT, traphandler7, 0);
f0103b0d:	b8 0c 44 10 f0       	mov    $0xf010440c,%eax
f0103b12:	66 a3 98 72 23 f0    	mov    %ax,0xf0237298
f0103b18:	66 c7 05 9a 72 23 f0 	movw   $0x8,0xf023729a
f0103b1f:	08 00 
f0103b21:	c6 05 9c 72 23 f0 00 	movb   $0x0,0xf023729c
f0103b28:	c6 05 9d 72 23 f0 8e 	movb   $0x8e,0xf023729d
f0103b2f:	c1 e8 10             	shr    $0x10,%eax
f0103b32:	66 a3 9e 72 23 f0    	mov    %ax,0xf023729e
    SETGATE(idt[T_DBLFLT], 0, GD_KT, traphandler8, 0);
f0103b38:	b8 12 44 10 f0       	mov    $0xf0104412,%eax
f0103b3d:	66 a3 a0 72 23 f0    	mov    %ax,0xf02372a0
f0103b43:	66 c7 05 a2 72 23 f0 	movw   $0x8,0xf02372a2
f0103b4a:	08 00 
f0103b4c:	c6 05 a4 72 23 f0 00 	movb   $0x0,0xf02372a4
f0103b53:	c6 05 a5 72 23 f0 8e 	movb   $0x8e,0xf02372a5
f0103b5a:	c1 e8 10             	shr    $0x10,%eax
f0103b5d:	66 a3 a6 72 23 f0    	mov    %ax,0xf02372a6
    SETGATE(idt[T_TSS], 0, GD_KT, traphandler10, 0);
f0103b63:	b8 16 44 10 f0       	mov    $0xf0104416,%eax
f0103b68:	66 a3 b0 72 23 f0    	mov    %ax,0xf02372b0
f0103b6e:	66 c7 05 b2 72 23 f0 	movw   $0x8,0xf02372b2
f0103b75:	08 00 
f0103b77:	c6 05 b4 72 23 f0 00 	movb   $0x0,0xf02372b4
f0103b7e:	c6 05 b5 72 23 f0 8e 	movb   $0x8e,0xf02372b5
f0103b85:	c1 e8 10             	shr    $0x10,%eax
f0103b88:	66 a3 b6 72 23 f0    	mov    %ax,0xf02372b6
    SETGATE(idt[T_SEGNP], 0, GD_KT, traphandler11, 0);
f0103b8e:	b8 1a 44 10 f0       	mov    $0xf010441a,%eax
f0103b93:	66 a3 b8 72 23 f0    	mov    %ax,0xf02372b8
f0103b99:	66 c7 05 ba 72 23 f0 	movw   $0x8,0xf02372ba
f0103ba0:	08 00 
f0103ba2:	c6 05 bc 72 23 f0 00 	movb   $0x0,0xf02372bc
f0103ba9:	c6 05 bd 72 23 f0 8e 	movb   $0x8e,0xf02372bd
f0103bb0:	c1 e8 10             	shr    $0x10,%eax
f0103bb3:	66 a3 be 72 23 f0    	mov    %ax,0xf02372be
    SETGATE(idt[T_STACK], 0, GD_KT, traphandler12, 0);
f0103bb9:	b8 1e 44 10 f0       	mov    $0xf010441e,%eax
f0103bbe:	66 a3 c0 72 23 f0    	mov    %ax,0xf02372c0
f0103bc4:	66 c7 05 c2 72 23 f0 	movw   $0x8,0xf02372c2
f0103bcb:	08 00 
f0103bcd:	c6 05 c4 72 23 f0 00 	movb   $0x0,0xf02372c4
f0103bd4:	c6 05 c5 72 23 f0 8e 	movb   $0x8e,0xf02372c5
f0103bdb:	c1 e8 10             	shr    $0x10,%eax
f0103bde:	66 a3 c6 72 23 f0    	mov    %ax,0xf02372c6
    SETGATE(idt[T_GPFLT], 0, GD_KT, traphandler13, 0);
f0103be4:	b8 22 44 10 f0       	mov    $0xf0104422,%eax
f0103be9:	66 a3 c8 72 23 f0    	mov    %ax,0xf02372c8
f0103bef:	66 c7 05 ca 72 23 f0 	movw   $0x8,0xf02372ca
f0103bf6:	08 00 
f0103bf8:	c6 05 cc 72 23 f0 00 	movb   $0x0,0xf02372cc
f0103bff:	c6 05 cd 72 23 f0 8e 	movb   $0x8e,0xf02372cd
f0103c06:	c1 e8 10             	shr    $0x10,%eax
f0103c09:	66 a3 ce 72 23 f0    	mov    %ax,0xf02372ce
    SETGATE(idt[T_PGFLT], 0, GD_KT, traphandler14, 0);
f0103c0f:	b8 26 44 10 f0       	mov    $0xf0104426,%eax
f0103c14:	66 a3 d0 72 23 f0    	mov    %ax,0xf02372d0
f0103c1a:	66 c7 05 d2 72 23 f0 	movw   $0x8,0xf02372d2
f0103c21:	08 00 
f0103c23:	c6 05 d4 72 23 f0 00 	movb   $0x0,0xf02372d4
f0103c2a:	c6 05 d5 72 23 f0 8e 	movb   $0x8e,0xf02372d5
f0103c31:	c1 e8 10             	shr    $0x10,%eax
f0103c34:	66 a3 d6 72 23 f0    	mov    %ax,0xf02372d6
    SETGATE(idt[T_FPERR], 0, GD_KT, traphandler16, 0);
f0103c3a:	b8 2a 44 10 f0       	mov    $0xf010442a,%eax
f0103c3f:	66 a3 e0 72 23 f0    	mov    %ax,0xf02372e0
f0103c45:	66 c7 05 e2 72 23 f0 	movw   $0x8,0xf02372e2
f0103c4c:	08 00 
f0103c4e:	c6 05 e4 72 23 f0 00 	movb   $0x0,0xf02372e4
f0103c55:	c6 05 e5 72 23 f0 8e 	movb   $0x8e,0xf02372e5
f0103c5c:	c1 e8 10             	shr    $0x10,%eax
f0103c5f:	66 a3 e6 72 23 f0    	mov    %ax,0xf02372e6
    SETGATE(idt[T_ALIGN], 0, GD_KT, traphandler17, 0);
f0103c65:	b8 30 44 10 f0       	mov    $0xf0104430,%eax
f0103c6a:	66 a3 e8 72 23 f0    	mov    %ax,0xf02372e8
f0103c70:	66 c7 05 ea 72 23 f0 	movw   $0x8,0xf02372ea
f0103c77:	08 00 
f0103c79:	c6 05 ec 72 23 f0 00 	movb   $0x0,0xf02372ec
f0103c80:	c6 05 ed 72 23 f0 8e 	movb   $0x8e,0xf02372ed
f0103c87:	c1 e8 10             	shr    $0x10,%eax
f0103c8a:	66 a3 ee 72 23 f0    	mov    %ax,0xf02372ee
    SETGATE(idt[T_MCHK], 0, GD_KT, traphandler18, 0);
f0103c90:	b8 34 44 10 f0       	mov    $0xf0104434,%eax
f0103c95:	66 a3 f0 72 23 f0    	mov    %ax,0xf02372f0
f0103c9b:	66 c7 05 f2 72 23 f0 	movw   $0x8,0xf02372f2
f0103ca2:	08 00 
f0103ca4:	c6 05 f4 72 23 f0 00 	movb   $0x0,0xf02372f4
f0103cab:	c6 05 f5 72 23 f0 8e 	movb   $0x8e,0xf02372f5
f0103cb2:	c1 e8 10             	shr    $0x10,%eax
f0103cb5:	66 a3 f6 72 23 f0    	mov    %ax,0xf02372f6
    SETGATE(idt[T_SIMDERR], 0, GD_KT, traphandler19, 0);
f0103cbb:	b8 3a 44 10 f0       	mov    $0xf010443a,%eax
f0103cc0:	66 a3 f8 72 23 f0    	mov    %ax,0xf02372f8
f0103cc6:	66 c7 05 fa 72 23 f0 	movw   $0x8,0xf02372fa
f0103ccd:	08 00 
f0103ccf:	c6 05 fc 72 23 f0 00 	movb   $0x0,0xf02372fc
f0103cd6:	c6 05 fd 72 23 f0 8e 	movb   $0x8e,0xf02372fd
f0103cdd:	c1 e8 10             	shr    $0x10,%eax
f0103ce0:	66 a3 fe 72 23 f0    	mov    %ax,0xf02372fe
    SETGATE(idt[T_SYSCALL], 0, GD_KT, traphandler48, 3);
f0103ce6:	b8 40 44 10 f0       	mov    $0xf0104440,%eax
f0103ceb:	66 a3 e0 73 23 f0    	mov    %ax,0xf02373e0
f0103cf1:	66 c7 05 e2 73 23 f0 	movw   $0x8,0xf02373e2
f0103cf8:	08 00 
f0103cfa:	c6 05 e4 73 23 f0 00 	movb   $0x0,0xf02373e4
f0103d01:	c6 05 e5 73 23 f0 ee 	movb   $0xee,0xf02373e5
f0103d08:	c1 e8 10             	shr    $0x10,%eax
f0103d0b:	66 a3 e6 73 23 f0    	mov    %ax,0xf02373e6
    SETGATE(idt[T_DEFAULT], 0, GD_KT, traphandler500, 0);
f0103d11:	b8 46 44 10 f0       	mov    $0xf0104446,%eax
f0103d16:	66 a3 00 82 23 f0    	mov    %ax,0xf0238200
f0103d1c:	66 c7 05 02 82 23 f0 	movw   $0x8,0xf0238202
f0103d23:	08 00 
f0103d25:	c6 05 04 82 23 f0 00 	movb   $0x0,0xf0238204
f0103d2c:	c6 05 05 82 23 f0 8e 	movb   $0x8e,0xf0238205
f0103d33:	c1 e8 10             	shr    $0x10,%eax
f0103d36:	66 a3 06 82 23 f0    	mov    %ax,0xf0238206
    SETGATE(idt[IRQ_OFFSET + IRQ_TIMER], 0, GD_KT, traphandler32, 0);
f0103d3c:	b8 50 44 10 f0       	mov    $0xf0104450,%eax
f0103d41:	66 a3 60 73 23 f0    	mov    %ax,0xf0237360
f0103d47:	66 c7 05 62 73 23 f0 	movw   $0x8,0xf0237362
f0103d4e:	08 00 
f0103d50:	c6 05 64 73 23 f0 00 	movb   $0x0,0xf0237364
f0103d57:	c6 05 65 73 23 f0 8e 	movb   $0x8e,0xf0237365
f0103d5e:	c1 e8 10             	shr    $0x10,%eax
f0103d61:	66 a3 66 73 23 f0    	mov    %ax,0xf0237366
    SETGATE(idt[IRQ_OFFSET + IRQ_KBD], 0, GD_KT, traphandler33, 0);
f0103d67:	b8 56 44 10 f0       	mov    $0xf0104456,%eax
f0103d6c:	66 a3 68 73 23 f0    	mov    %ax,0xf0237368
f0103d72:	66 c7 05 6a 73 23 f0 	movw   $0x8,0xf023736a
f0103d79:	08 00 
f0103d7b:	c6 05 6c 73 23 f0 00 	movb   $0x0,0xf023736c
f0103d82:	c6 05 6d 73 23 f0 8e 	movb   $0x8e,0xf023736d
f0103d89:	c1 e8 10             	shr    $0x10,%eax
f0103d8c:	66 a3 6e 73 23 f0    	mov    %ax,0xf023736e
    SETGATE(idt[IRQ_OFFSET + IRQ_SERIAL], 0, GD_KT, traphandler36, 0);
f0103d92:	b8 5c 44 10 f0       	mov    $0xf010445c,%eax
f0103d97:	66 a3 80 73 23 f0    	mov    %ax,0xf0237380
f0103d9d:	66 c7 05 82 73 23 f0 	movw   $0x8,0xf0237382
f0103da4:	08 00 
f0103da6:	c6 05 84 73 23 f0 00 	movb   $0x0,0xf0237384
f0103dad:	c6 05 85 73 23 f0 8e 	movb   $0x8e,0xf0237385
f0103db4:	c1 e8 10             	shr    $0x10,%eax
f0103db7:	66 a3 86 73 23 f0    	mov    %ax,0xf0237386
    SETGATE(idt[IRQ_OFFSET + IRQ_SPURIOUS], 0, GD_KT, traphandler39, 0);
f0103dbd:	b8 62 44 10 f0       	mov    $0xf0104462,%eax
f0103dc2:	66 a3 98 73 23 f0    	mov    %ax,0xf0237398
f0103dc8:	66 c7 05 9a 73 23 f0 	movw   $0x8,0xf023739a
f0103dcf:	08 00 
f0103dd1:	c6 05 9c 73 23 f0 00 	movb   $0x0,0xf023739c
f0103dd8:	c6 05 9d 73 23 f0 8e 	movb   $0x8e,0xf023739d
f0103ddf:	c1 e8 10             	shr    $0x10,%eax
f0103de2:	66 a3 9e 73 23 f0    	mov    %ax,0xf023739e
    SETGATE(idt[IRQ_OFFSET + IRQ_IDE], 0, GD_KT, traphandler46, 0);
f0103de8:	b8 68 44 10 f0       	mov    $0xf0104468,%eax
f0103ded:	66 a3 d0 73 23 f0    	mov    %ax,0xf02373d0
f0103df3:	66 c7 05 d2 73 23 f0 	movw   $0x8,0xf02373d2
f0103dfa:	08 00 
f0103dfc:	c6 05 d4 73 23 f0 00 	movb   $0x0,0xf02373d4
f0103e03:	c6 05 d5 73 23 f0 8e 	movb   $0x8e,0xf02373d5
f0103e0a:	c1 e8 10             	shr    $0x10,%eax
f0103e0d:	66 a3 d6 73 23 f0    	mov    %ax,0xf02373d6
    SETGATE(idt[IRQ_OFFSET + IRQ_ERROR], 0, GD_KT, traphandler51, 0);	
f0103e13:	b8 6e 44 10 f0       	mov    $0xf010446e,%eax
f0103e18:	66 a3 f8 73 23 f0    	mov    %ax,0xf02373f8
f0103e1e:	66 c7 05 fa 73 23 f0 	movw   $0x8,0xf02373fa
f0103e25:	08 00 
f0103e27:	c6 05 fc 73 23 f0 00 	movb   $0x0,0xf02373fc
f0103e2e:	c6 05 fd 73 23 f0 8e 	movb   $0x8e,0xf02373fd
f0103e35:	c1 e8 10             	shr    $0x10,%eax
f0103e38:	66 a3 fe 73 23 f0    	mov    %ax,0xf02373fe
	trap_init_percpu();
f0103e3e:	e8 cd fa ff ff       	call   f0103910 <trap_init_percpu>
}
f0103e43:	c9                   	leave  
f0103e44:	c3                   	ret    

f0103e45 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103e45:	55                   	push   %ebp
f0103e46:	89 e5                	mov    %esp,%ebp
f0103e48:	53                   	push   %ebx
f0103e49:	83 ec 0c             	sub    $0xc,%esp
f0103e4c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103e4f:	ff 33                	pushl  (%ebx)
f0103e51:	68 da 76 10 f0       	push   $0xf01076da
f0103e56:	e8 a1 fa ff ff       	call   f01038fc <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103e5b:	83 c4 08             	add    $0x8,%esp
f0103e5e:	ff 73 04             	pushl  0x4(%ebx)
f0103e61:	68 e9 76 10 f0       	push   $0xf01076e9
f0103e66:	e8 91 fa ff ff       	call   f01038fc <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103e6b:	83 c4 08             	add    $0x8,%esp
f0103e6e:	ff 73 08             	pushl  0x8(%ebx)
f0103e71:	68 f8 76 10 f0       	push   $0xf01076f8
f0103e76:	e8 81 fa ff ff       	call   f01038fc <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103e7b:	83 c4 08             	add    $0x8,%esp
f0103e7e:	ff 73 0c             	pushl  0xc(%ebx)
f0103e81:	68 07 77 10 f0       	push   $0xf0107707
f0103e86:	e8 71 fa ff ff       	call   f01038fc <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103e8b:	83 c4 08             	add    $0x8,%esp
f0103e8e:	ff 73 10             	pushl  0x10(%ebx)
f0103e91:	68 16 77 10 f0       	push   $0xf0107716
f0103e96:	e8 61 fa ff ff       	call   f01038fc <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103e9b:	83 c4 08             	add    $0x8,%esp
f0103e9e:	ff 73 14             	pushl  0x14(%ebx)
f0103ea1:	68 25 77 10 f0       	push   $0xf0107725
f0103ea6:	e8 51 fa ff ff       	call   f01038fc <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103eab:	83 c4 08             	add    $0x8,%esp
f0103eae:	ff 73 18             	pushl  0x18(%ebx)
f0103eb1:	68 34 77 10 f0       	push   $0xf0107734
f0103eb6:	e8 41 fa ff ff       	call   f01038fc <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103ebb:	83 c4 08             	add    $0x8,%esp
f0103ebe:	ff 73 1c             	pushl  0x1c(%ebx)
f0103ec1:	68 43 77 10 f0       	push   $0xf0107743
f0103ec6:	e8 31 fa ff ff       	call   f01038fc <cprintf>
}
f0103ecb:	83 c4 10             	add    $0x10,%esp
f0103ece:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103ed1:	c9                   	leave  
f0103ed2:	c3                   	ret    

f0103ed3 <print_trapframe>:
{
f0103ed3:	55                   	push   %ebp
f0103ed4:	89 e5                	mov    %esp,%ebp
f0103ed6:	56                   	push   %esi
f0103ed7:	53                   	push   %ebx
f0103ed8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0103edb:	e8 7a 1e 00 00       	call   f0105d5a <cpunum>
f0103ee0:	83 ec 04             	sub    $0x4,%esp
f0103ee3:	50                   	push   %eax
f0103ee4:	53                   	push   %ebx
f0103ee5:	68 a7 77 10 f0       	push   $0xf01077a7
f0103eea:	e8 0d fa ff ff       	call   f01038fc <cprintf>
	print_regs(&tf->tf_regs);
f0103eef:	89 1c 24             	mov    %ebx,(%esp)
f0103ef2:	e8 4e ff ff ff       	call   f0103e45 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103ef7:	83 c4 08             	add    $0x8,%esp
f0103efa:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103efe:	50                   	push   %eax
f0103eff:	68 c5 77 10 f0       	push   $0xf01077c5
f0103f04:	e8 f3 f9 ff ff       	call   f01038fc <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103f09:	83 c4 08             	add    $0x8,%esp
f0103f0c:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103f10:	50                   	push   %eax
f0103f11:	68 d8 77 10 f0       	push   $0xf01077d8
f0103f16:	e8 e1 f9 ff ff       	call   f01038fc <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103f1b:	8b 43 28             	mov    0x28(%ebx),%eax
	if (trapno < ARRAY_SIZE(excnames))
f0103f1e:	83 c4 10             	add    $0x10,%esp
f0103f21:	83 f8 13             	cmp    $0x13,%eax
f0103f24:	0f 86 e1 00 00 00    	jbe    f010400b <print_trapframe+0x138>
		return "System call";
f0103f2a:	ba 52 77 10 f0       	mov    $0xf0107752,%edx
	if (trapno == T_SYSCALL)
f0103f2f:	83 f8 30             	cmp    $0x30,%eax
f0103f32:	74 13                	je     f0103f47 <print_trapframe+0x74>
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0103f34:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
f0103f37:	83 fa 0f             	cmp    $0xf,%edx
f0103f3a:	ba 5e 77 10 f0       	mov    $0xf010775e,%edx
f0103f3f:	b9 6d 77 10 f0       	mov    $0xf010776d,%ecx
f0103f44:	0f 46 d1             	cmovbe %ecx,%edx
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103f47:	83 ec 04             	sub    $0x4,%esp
f0103f4a:	52                   	push   %edx
f0103f4b:	50                   	push   %eax
f0103f4c:	68 eb 77 10 f0       	push   $0xf01077eb
f0103f51:	e8 a6 f9 ff ff       	call   f01038fc <cprintf>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103f56:	83 c4 10             	add    $0x10,%esp
f0103f59:	39 1d 60 7a 23 f0    	cmp    %ebx,0xf0237a60
f0103f5f:	0f 84 b2 00 00 00    	je     f0104017 <print_trapframe+0x144>
	cprintf("  err  0x%08x", tf->tf_err);
f0103f65:	83 ec 08             	sub    $0x8,%esp
f0103f68:	ff 73 2c             	pushl  0x2c(%ebx)
f0103f6b:	68 0c 78 10 f0       	push   $0xf010780c
f0103f70:	e8 87 f9 ff ff       	call   f01038fc <cprintf>
	if (tf->tf_trapno == T_PGFLT)
f0103f75:	83 c4 10             	add    $0x10,%esp
f0103f78:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103f7c:	0f 85 b8 00 00 00    	jne    f010403a <print_trapframe+0x167>
			tf->tf_err & 1 ? "protection" : "not-present");
f0103f82:	8b 43 2c             	mov    0x2c(%ebx),%eax
		cprintf(" [%s, %s, %s]\n",
f0103f85:	89 c2                	mov    %eax,%edx
f0103f87:	83 e2 01             	and    $0x1,%edx
f0103f8a:	b9 80 77 10 f0       	mov    $0xf0107780,%ecx
f0103f8f:	ba 8b 77 10 f0       	mov    $0xf010778b,%edx
f0103f94:	0f 44 ca             	cmove  %edx,%ecx
f0103f97:	89 c2                	mov    %eax,%edx
f0103f99:	83 e2 02             	and    $0x2,%edx
f0103f9c:	be 97 77 10 f0       	mov    $0xf0107797,%esi
f0103fa1:	ba 9d 77 10 f0       	mov    $0xf010779d,%edx
f0103fa6:	0f 45 d6             	cmovne %esi,%edx
f0103fa9:	83 e0 04             	and    $0x4,%eax
f0103fac:	b8 a2 77 10 f0       	mov    $0xf01077a2,%eax
f0103fb1:	be f1 78 10 f0       	mov    $0xf01078f1,%esi
f0103fb6:	0f 44 c6             	cmove  %esi,%eax
f0103fb9:	51                   	push   %ecx
f0103fba:	52                   	push   %edx
f0103fbb:	50                   	push   %eax
f0103fbc:	68 1a 78 10 f0       	push   $0xf010781a
f0103fc1:	e8 36 f9 ff ff       	call   f01038fc <cprintf>
f0103fc6:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103fc9:	83 ec 08             	sub    $0x8,%esp
f0103fcc:	ff 73 30             	pushl  0x30(%ebx)
f0103fcf:	68 29 78 10 f0       	push   $0xf0107829
f0103fd4:	e8 23 f9 ff ff       	call   f01038fc <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103fd9:	83 c4 08             	add    $0x8,%esp
f0103fdc:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103fe0:	50                   	push   %eax
f0103fe1:	68 38 78 10 f0       	push   $0xf0107838
f0103fe6:	e8 11 f9 ff ff       	call   f01038fc <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103feb:	83 c4 08             	add    $0x8,%esp
f0103fee:	ff 73 38             	pushl  0x38(%ebx)
f0103ff1:	68 4b 78 10 f0       	push   $0xf010784b
f0103ff6:	e8 01 f9 ff ff       	call   f01038fc <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0103ffb:	83 c4 10             	add    $0x10,%esp
f0103ffe:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0104002:	75 4b                	jne    f010404f <print_trapframe+0x17c>
}
f0104004:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0104007:	5b                   	pop    %ebx
f0104008:	5e                   	pop    %esi
f0104009:	5d                   	pop    %ebp
f010400a:	c3                   	ret    
		return excnames[trapno];
f010400b:	8b 14 85 60 7a 10 f0 	mov    -0xfef85a0(,%eax,4),%edx
f0104012:	e9 30 ff ff ff       	jmp    f0103f47 <print_trapframe+0x74>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0104017:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f010401b:	0f 85 44 ff ff ff    	jne    f0103f65 <print_trapframe+0x92>
	asm volatile("movl %%cr2,%0" : "=r" (val));
f0104021:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0104024:	83 ec 08             	sub    $0x8,%esp
f0104027:	50                   	push   %eax
f0104028:	68 fd 77 10 f0       	push   $0xf01077fd
f010402d:	e8 ca f8 ff ff       	call   f01038fc <cprintf>
f0104032:	83 c4 10             	add    $0x10,%esp
f0104035:	e9 2b ff ff ff       	jmp    f0103f65 <print_trapframe+0x92>
		cprintf("\n");
f010403a:	83 ec 0c             	sub    $0xc,%esp
f010403d:	68 8a 6c 10 f0       	push   $0xf0106c8a
f0104042:	e8 b5 f8 ff ff       	call   f01038fc <cprintf>
f0104047:	83 c4 10             	add    $0x10,%esp
f010404a:	e9 7a ff ff ff       	jmp    f0103fc9 <print_trapframe+0xf6>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f010404f:	83 ec 08             	sub    $0x8,%esp
f0104052:	ff 73 3c             	pushl  0x3c(%ebx)
f0104055:	68 5a 78 10 f0       	push   $0xf010785a
f010405a:	e8 9d f8 ff ff       	call   f01038fc <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f010405f:	83 c4 08             	add    $0x8,%esp
f0104062:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0104066:	50                   	push   %eax
f0104067:	68 69 78 10 f0       	push   $0xf0107869
f010406c:	e8 8b f8 ff ff       	call   f01038fc <cprintf>
f0104071:	83 c4 10             	add    $0x10,%esp
}
f0104074:	eb 8e                	jmp    f0104004 <print_trapframe+0x131>

f0104076 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0104076:	55                   	push   %ebp
f0104077:	89 e5                	mov    %esp,%ebp
f0104079:	57                   	push   %edi
f010407a:	56                   	push   %esi
f010407b:	53                   	push   %ebx
f010407c:	83 ec 18             	sub    $0x18,%esp
f010407f:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0104082:	0f 20 d6             	mov    %cr2,%esi

	// Read processor's CR2 register to find the faulting address
	fault_va = rcr2();

	// Handle kernel-mode page faults.
	print_trapframe(tf);
f0104085:	53                   	push   %ebx
f0104086:	e8 48 fe ff ff       	call   f0103ed3 <print_trapframe>

	// LAB 3: Your code here.
	if (tf->tf_cs == GD_KT)
f010408b:	83 c4 10             	add    $0x10,%esp
f010408e:	66 83 7b 34 08       	cmpw   $0x8,0x34(%ebx)
f0104093:	74 5d                	je     f01040f2 <page_fault_handler+0x7c>
	//   user_mem_assert() and env_run() are useful here.
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	 if (curenv->env_pgfault_upcall) {
f0104095:	e8 c0 1c 00 00       	call   f0105d5a <cpunum>
f010409a:	6b c0 74             	imul   $0x74,%eax,%eax
f010409d:	8b 80 28 80 23 f0    	mov    -0xfdc7fd8(%eax),%eax
f01040a3:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f01040a7:	75 60                	jne    f0104109 <page_fault_handler+0x93>
        tf->tf_eip = (uintptr_t)curenv->env_pgfault_upcall;
        tf->tf_esp = (uintptr_t)utf;
        env_run(curenv);
    }
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01040a9:	8b 7b 30             	mov    0x30(%ebx),%edi
		curenv->env_id, fault_va, tf->tf_eip);
f01040ac:	e8 a9 1c 00 00       	call   f0105d5a <cpunum>
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01040b1:	57                   	push   %edi
f01040b2:	56                   	push   %esi
		curenv->env_id, fault_va, tf->tf_eip);
f01040b3:	6b c0 74             	imul   $0x74,%eax,%eax
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01040b6:	8b 80 28 80 23 f0    	mov    -0xfdc7fd8(%eax),%eax
f01040bc:	ff 70 48             	pushl  0x48(%eax)
f01040bf:	68 3c 7a 10 f0       	push   $0xf0107a3c
f01040c4:	e8 33 f8 ff ff       	call   f01038fc <cprintf>
	print_trapframe(tf);
f01040c9:	89 1c 24             	mov    %ebx,(%esp)
f01040cc:	e8 02 fe ff ff       	call   f0103ed3 <print_trapframe>
	env_destroy(curenv);
f01040d1:	e8 84 1c 00 00       	call   f0105d5a <cpunum>
f01040d6:	83 c4 04             	add    $0x4,%esp
f01040d9:	6b c0 74             	imul   $0x74,%eax,%eax
f01040dc:	ff b0 28 80 23 f0    	pushl  -0xfdc7fd8(%eax)
f01040e2:	e8 4e f5 ff ff       	call   f0103635 <env_destroy>
}
f01040e7:	83 c4 10             	add    $0x10,%esp
f01040ea:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01040ed:	5b                   	pop    %ebx
f01040ee:	5e                   	pop    %esi
f01040ef:	5f                   	pop    %edi
f01040f0:	5d                   	pop    %ebp
f01040f1:	c3                   	ret    
			panic("Page fault in kernel_mode");
f01040f2:	83 ec 04             	sub    $0x4,%esp
f01040f5:	68 7c 78 10 f0       	push   $0xf010787c
f01040fa:	68 74 01 00 00       	push   $0x174
f01040ff:	68 96 78 10 f0       	push   $0xf0107896
f0104104:	e8 8b bf ff ff       	call   f0100094 <_panic>
        if (tf->tf_esp >= UXSTACKTOP-PGSIZE && tf->tf_esp < UXSTACKTOP) {
f0104109:	8b 43 3c             	mov    0x3c(%ebx),%eax
f010410c:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
            utf = (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe));
f0104112:	bf cc ff bf ee       	mov    $0xeebfffcc,%edi
        if (tf->tf_esp >= UXSTACKTOP-PGSIZE && tf->tf_esp < UXSTACKTOP) {
f0104117:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f010411d:	77 05                	ja     f0104124 <page_fault_handler+0xae>
            utf = (struct UTrapframe *)(tf->tf_esp - 4 - sizeof(struct UTrapframe));
f010411f:	83 e8 38             	sub    $0x38,%eax
f0104122:	89 c7                	mov    %eax,%edi
        user_mem_assert(curenv, (void *)utf, sizeof(struct UTrapframe), PTE_U | PTE_W | PTE_P);
f0104124:	e8 31 1c 00 00       	call   f0105d5a <cpunum>
f0104129:	6a 07                	push   $0x7
f010412b:	6a 34                	push   $0x34
f010412d:	57                   	push   %edi
f010412e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104131:	ff b0 28 80 23 f0    	pushl  -0xfdc7fd8(%eax)
f0104137:	e8 3e ee ff ff       	call   f0102f7a <user_mem_assert>
        utf->utf_fault_va = fault_va;
f010413c:	89 fa                	mov    %edi,%edx
f010413e:	89 37                	mov    %esi,(%edi)
        utf->utf_err = tf->tf_trapno;
f0104140:	8b 43 28             	mov    0x28(%ebx),%eax
f0104143:	89 47 04             	mov    %eax,0x4(%edi)
        utf->utf_regs = tf->tf_regs;
f0104146:	8d 7f 08             	lea    0x8(%edi),%edi
f0104149:	b9 08 00 00 00       	mov    $0x8,%ecx
f010414e:	89 de                	mov    %ebx,%esi
f0104150:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
        utf->utf_eip = tf->tf_eip;
f0104152:	8b 43 30             	mov    0x30(%ebx),%eax
f0104155:	89 42 28             	mov    %eax,0x28(%edx)
        utf->utf_eflags = tf->tf_eflags;
f0104158:	8b 43 38             	mov    0x38(%ebx),%eax
f010415b:	89 d7                	mov    %edx,%edi
f010415d:	89 42 2c             	mov    %eax,0x2c(%edx)
        utf->utf_esp = tf->tf_esp;
f0104160:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104163:	89 42 30             	mov    %eax,0x30(%edx)
        tf->tf_eip = (uintptr_t)curenv->env_pgfault_upcall;
f0104166:	e8 ef 1b 00 00       	call   f0105d5a <cpunum>
f010416b:	6b c0 74             	imul   $0x74,%eax,%eax
f010416e:	8b 80 28 80 23 f0    	mov    -0xfdc7fd8(%eax),%eax
f0104174:	8b 40 64             	mov    0x64(%eax),%eax
f0104177:	89 43 30             	mov    %eax,0x30(%ebx)
        tf->tf_esp = (uintptr_t)utf;
f010417a:	89 7b 3c             	mov    %edi,0x3c(%ebx)
        env_run(curenv);
f010417d:	e8 d8 1b 00 00       	call   f0105d5a <cpunum>
f0104182:	83 c4 04             	add    $0x4,%esp
f0104185:	6b c0 74             	imul   $0x74,%eax,%eax
f0104188:	ff b0 28 80 23 f0    	pushl  -0xfdc7fd8(%eax)
f010418e:	e8 41 f5 ff ff       	call   f01036d4 <env_run>

f0104193 <trap>:
{
f0104193:	55                   	push   %ebp
f0104194:	89 e5                	mov    %esp,%ebp
f0104196:	57                   	push   %edi
f0104197:	56                   	push   %esi
f0104198:	8b 75 08             	mov    0x8(%ebp),%esi
	asm volatile("cld" ::: "cc");
f010419b:	fc                   	cld    
	if (panicstr)
f010419c:	83 3d 80 7e 23 f0 00 	cmpl   $0x0,0xf0237e80
f01041a3:	74 01                	je     f01041a6 <trap+0x13>
		asm volatile("hlt");
f01041a5:	f4                   	hlt    
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f01041a6:	e8 af 1b 00 00       	call   f0105d5a <cpunum>
f01041ab:	6b d0 74             	imul   $0x74,%eax,%edx
f01041ae:	83 c2 04             	add    $0x4,%edx
	asm volatile("lock; xchgl %0, %1"
f01041b1:	b8 01 00 00 00       	mov    $0x1,%eax
f01041b6:	f0 87 82 20 80 23 f0 	lock xchg %eax,-0xfdc7fe0(%edx)
f01041bd:	83 f8 02             	cmp    $0x2,%eax
f01041c0:	0f 84 87 00 00 00    	je     f010424d <trap+0xba>
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f01041c6:	9c                   	pushf  
f01041c7:	58                   	pop    %eax
	assert(!(read_eflags() & FL_IF));
f01041c8:	f6 c4 02             	test   $0x2,%ah
f01041cb:	0f 85 91 00 00 00    	jne    f0104262 <trap+0xcf>
	if ((tf->tf_cs & 3) == 3) {
f01041d1:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f01041d5:	83 e0 03             	and    $0x3,%eax
f01041d8:	66 83 f8 03          	cmp    $0x3,%ax
f01041dc:	0f 84 99 00 00 00    	je     f010427b <trap+0xe8>
	last_tf = tf;
f01041e2:	89 35 60 7a 23 f0    	mov    %esi,0xf0237a60
	switch (tf->tf_trapno) {
f01041e8:	8b 46 28             	mov    0x28(%esi),%eax
f01041eb:	83 f8 0e             	cmp    $0xe,%eax
f01041ee:	0f 84 2c 01 00 00    	je     f0104320 <trap+0x18d>
f01041f4:	83 f8 30             	cmp    $0x30,%eax
f01041f7:	0f 84 67 01 00 00    	je     f0104364 <trap+0x1d1>
f01041fd:	83 f8 03             	cmp    $0x3,%eax
f0104200:	0f 84 50 01 00 00    	je     f0104356 <trap+0x1c3>
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f0104206:	83 f8 27             	cmp    $0x27,%eax
f0104209:	0f 84 76 01 00 00    	je     f0104385 <trap+0x1f2>
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER) {
f010420f:	83 f8 20             	cmp    $0x20,%eax
f0104212:	0f 84 87 01 00 00    	je     f010439f <trap+0x20c>
	print_trapframe(tf);
f0104218:	83 ec 0c             	sub    $0xc,%esp
f010421b:	56                   	push   %esi
f010421c:	e8 b2 fc ff ff       	call   f0103ed3 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0104221:	83 c4 10             	add    $0x10,%esp
f0104224:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0104229:	0f 84 7a 01 00 00    	je     f01043a9 <trap+0x216>
		env_destroy(curenv);
f010422f:	e8 26 1b 00 00       	call   f0105d5a <cpunum>
f0104234:	83 ec 0c             	sub    $0xc,%esp
f0104237:	6b c0 74             	imul   $0x74,%eax,%eax
f010423a:	ff b0 28 80 23 f0    	pushl  -0xfdc7fd8(%eax)
f0104240:	e8 f0 f3 ff ff       	call   f0103635 <env_destroy>
f0104245:	83 c4 10             	add    $0x10,%esp
f0104248:	e9 df 00 00 00       	jmp    f010432c <trap+0x199>
	spin_lock(&kernel_lock);
f010424d:	83 ec 0c             	sub    $0xc,%esp
f0104250:	68 c0 33 12 f0       	push   $0xf01233c0
f0104255:	e8 70 1d 00 00       	call   f0105fca <spin_lock>
f010425a:	83 c4 10             	add    $0x10,%esp
f010425d:	e9 64 ff ff ff       	jmp    f01041c6 <trap+0x33>
	assert(!(read_eflags() & FL_IF));
f0104262:	68 a2 78 10 f0       	push   $0xf01078a2
f0104267:	68 be 69 10 f0       	push   $0xf01069be
f010426c:	68 3d 01 00 00       	push   $0x13d
f0104271:	68 96 78 10 f0       	push   $0xf0107896
f0104276:	e8 19 be ff ff       	call   f0100094 <_panic>
f010427b:	83 ec 0c             	sub    $0xc,%esp
f010427e:	68 c0 33 12 f0       	push   $0xf01233c0
f0104283:	e8 42 1d 00 00       	call   f0105fca <spin_lock>
		assert(curenv);
f0104288:	e8 cd 1a 00 00       	call   f0105d5a <cpunum>
f010428d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104290:	83 c4 10             	add    $0x10,%esp
f0104293:	83 b8 28 80 23 f0 00 	cmpl   $0x0,-0xfdc7fd8(%eax)
f010429a:	74 3e                	je     f01042da <trap+0x147>
		if (curenv->env_status == ENV_DYING) {
f010429c:	e8 b9 1a 00 00       	call   f0105d5a <cpunum>
f01042a1:	6b c0 74             	imul   $0x74,%eax,%eax
f01042a4:	8b 80 28 80 23 f0    	mov    -0xfdc7fd8(%eax),%eax
f01042aa:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f01042ae:	74 43                	je     f01042f3 <trap+0x160>
		curenv->env_tf = *tf;
f01042b0:	e8 a5 1a 00 00       	call   f0105d5a <cpunum>
f01042b5:	6b c0 74             	imul   $0x74,%eax,%eax
f01042b8:	8b 80 28 80 23 f0    	mov    -0xfdc7fd8(%eax),%eax
f01042be:	b9 11 00 00 00       	mov    $0x11,%ecx
f01042c3:	89 c7                	mov    %eax,%edi
f01042c5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		tf = &curenv->env_tf;
f01042c7:	e8 8e 1a 00 00       	call   f0105d5a <cpunum>
f01042cc:	6b c0 74             	imul   $0x74,%eax,%eax
f01042cf:	8b b0 28 80 23 f0    	mov    -0xfdc7fd8(%eax),%esi
f01042d5:	e9 08 ff ff ff       	jmp    f01041e2 <trap+0x4f>
		assert(curenv);
f01042da:	68 bb 78 10 f0       	push   $0xf01078bb
f01042df:	68 be 69 10 f0       	push   $0xf01069be
f01042e4:	68 45 01 00 00       	push   $0x145
f01042e9:	68 96 78 10 f0       	push   $0xf0107896
f01042ee:	e8 a1 bd ff ff       	call   f0100094 <_panic>
			env_free(curenv);
f01042f3:	e8 62 1a 00 00       	call   f0105d5a <cpunum>
f01042f8:	83 ec 0c             	sub    $0xc,%esp
f01042fb:	6b c0 74             	imul   $0x74,%eax,%eax
f01042fe:	ff b0 28 80 23 f0    	pushl  -0xfdc7fd8(%eax)
f0104304:	e8 4b f1 ff ff       	call   f0103454 <env_free>
			curenv = NULL;
f0104309:	e8 4c 1a 00 00       	call   f0105d5a <cpunum>
f010430e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104311:	c7 80 28 80 23 f0 00 	movl   $0x0,-0xfdc7fd8(%eax)
f0104318:	00 00 00 
			sched_yield();
f010431b:	e8 2f 02 00 00       	call   f010454f <sched_yield>
			page_fault_handler(tf);
f0104320:	83 ec 0c             	sub    $0xc,%esp
f0104323:	56                   	push   %esi
f0104324:	e8 4d fd ff ff       	call   f0104076 <page_fault_handler>
f0104329:	83 c4 10             	add    $0x10,%esp
	if (curenv && curenv->env_status == ENV_RUNNING)
f010432c:	e8 29 1a 00 00       	call   f0105d5a <cpunum>
f0104331:	6b c0 74             	imul   $0x74,%eax,%eax
f0104334:	83 b8 28 80 23 f0 00 	cmpl   $0x0,-0xfdc7fd8(%eax)
f010433b:	74 14                	je     f0104351 <trap+0x1be>
f010433d:	e8 18 1a 00 00       	call   f0105d5a <cpunum>
f0104342:	6b c0 74             	imul   $0x74,%eax,%eax
f0104345:	8b 80 28 80 23 f0    	mov    -0xfdc7fd8(%eax),%eax
f010434b:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f010434f:	74 6f                	je     f01043c0 <trap+0x22d>
		sched_yield();
f0104351:	e8 f9 01 00 00       	call   f010454f <sched_yield>
			monitor(tf);
f0104356:	83 ec 0c             	sub    $0xc,%esp
f0104359:	56                   	push   %esi
f010435a:	e8 ec c5 ff ff       	call   f010094b <monitor>
f010435f:	83 c4 10             	add    $0x10,%esp
f0104362:	eb c8                	jmp    f010432c <trap+0x199>
			tf->tf_regs.reg_eax = syscall (tf->tf_regs.reg_eax,
f0104364:	83 ec 08             	sub    $0x8,%esp
f0104367:	ff 76 04             	pushl  0x4(%esi)
f010436a:	ff 36                	pushl  (%esi)
f010436c:	ff 76 10             	pushl  0x10(%esi)
f010436f:	ff 76 18             	pushl  0x18(%esi)
f0104372:	ff 76 14             	pushl  0x14(%esi)
f0104375:	ff 76 1c             	pushl  0x1c(%esi)
f0104378:	e8 3e 02 00 00       	call   f01045bb <syscall>
f010437d:	89 46 1c             	mov    %eax,0x1c(%esi)
f0104380:	83 c4 20             	add    $0x20,%esp
f0104383:	eb a7                	jmp    f010432c <trap+0x199>
		cprintf("Spurious interrupt on irq 7\n");
f0104385:	83 ec 0c             	sub    $0xc,%esp
f0104388:	68 c2 78 10 f0       	push   $0xf01078c2
f010438d:	e8 6a f5 ff ff       	call   f01038fc <cprintf>
		print_trapframe(tf);
f0104392:	89 34 24             	mov    %esi,(%esp)
f0104395:	e8 39 fb ff ff       	call   f0103ed3 <print_trapframe>
f010439a:	83 c4 10             	add    $0x10,%esp
f010439d:	eb 8d                	jmp    f010432c <trap+0x199>
		 lapic_eoi();
f010439f:	e8 fd 1a 00 00       	call   f0105ea1 <lapic_eoi>
		 sched_yield();	
f01043a4:	e8 a6 01 00 00       	call   f010454f <sched_yield>
		panic("unhandled trap in kernel");
f01043a9:	83 ec 04             	sub    $0x4,%esp
f01043ac:	68 df 78 10 f0       	push   $0xf01078df
f01043b1:	68 22 01 00 00       	push   $0x122
f01043b6:	68 96 78 10 f0       	push   $0xf0107896
f01043bb:	e8 d4 bc ff ff       	call   f0100094 <_panic>
		env_run(curenv);
f01043c0:	e8 95 19 00 00       	call   f0105d5a <cpunum>
f01043c5:	83 ec 0c             	sub    $0xc,%esp
f01043c8:	6b c0 74             	imul   $0x74,%eax,%eax
f01043cb:	ff b0 28 80 23 f0    	pushl  -0xfdc7fd8(%eax)
f01043d1:	e8 fe f2 ff ff       	call   f01036d4 <env_run>

f01043d6 <traphandler0>:
.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
TRAPHANDLER_NOEC(traphandler0, T_DIVIDE)
f01043d6:	6a 00                	push   $0x0
f01043d8:	6a 00                	push   $0x0
f01043da:	e9 95 00 00 00       	jmp    f0104474 <_alltraps>
f01043df:	90                   	nop

f01043e0 <traphandler1>:
TRAPHANDLER_NOEC(traphandler1, T_DEBUG)
f01043e0:	6a 00                	push   $0x0
f01043e2:	6a 01                	push   $0x1
f01043e4:	e9 8b 00 00 00       	jmp    f0104474 <_alltraps>
f01043e9:	90                   	nop

f01043ea <traphandler2>:
TRAPHANDLER_NOEC(traphandler2, T_NMI)
f01043ea:	6a 00                	push   $0x0
f01043ec:	6a 02                	push   $0x2
f01043ee:	e9 81 00 00 00       	jmp    f0104474 <_alltraps>
f01043f3:	90                   	nop

f01043f4 <traphandler3>:
TRAPHANDLER_NOEC(traphandler3, T_BRKPT)
f01043f4:	6a 00                	push   $0x0
f01043f6:	6a 03                	push   $0x3
f01043f8:	eb 7a                	jmp    f0104474 <_alltraps>

f01043fa <traphandler4>:
TRAPHANDLER_NOEC(traphandler4, T_OFLOW)
f01043fa:	6a 00                	push   $0x0
f01043fc:	6a 04                	push   $0x4
f01043fe:	eb 74                	jmp    f0104474 <_alltraps>

f0104400 <traphandler5>:
TRAPHANDLER_NOEC(traphandler5, T_BOUND)
f0104400:	6a 00                	push   $0x0
f0104402:	6a 05                	push   $0x5
f0104404:	eb 6e                	jmp    f0104474 <_alltraps>

f0104406 <traphandler6>:
TRAPHANDLER_NOEC(traphandler6, T_ILLOP)
f0104406:	6a 00                	push   $0x0
f0104408:	6a 06                	push   $0x6
f010440a:	eb 68                	jmp    f0104474 <_alltraps>

f010440c <traphandler7>:
TRAPHANDLER_NOEC(traphandler7, T_DEVICE)
f010440c:	6a 00                	push   $0x0
f010440e:	6a 07                	push   $0x7
f0104410:	eb 62                	jmp    f0104474 <_alltraps>

f0104412 <traphandler8>:
TRAPHANDLER(traphandler8, T_DBLFLT)
f0104412:	6a 08                	push   $0x8
f0104414:	eb 5e                	jmp    f0104474 <_alltraps>

f0104416 <traphandler10>:
// 9 deprecated since 386
TRAPHANDLER(traphandler10, T_TSS)
f0104416:	6a 0a                	push   $0xa
f0104418:	eb 5a                	jmp    f0104474 <_alltraps>

f010441a <traphandler11>:
TRAPHANDLER(traphandler11, T_SEGNP)
f010441a:	6a 0b                	push   $0xb
f010441c:	eb 56                	jmp    f0104474 <_alltraps>

f010441e <traphandler12>:
TRAPHANDLER(traphandler12, T_STACK)
f010441e:	6a 0c                	push   $0xc
f0104420:	eb 52                	jmp    f0104474 <_alltraps>

f0104422 <traphandler13>:
TRAPHANDLER(traphandler13, T_GPFLT)
f0104422:	6a 0d                	push   $0xd
f0104424:	eb 4e                	jmp    f0104474 <_alltraps>

f0104426 <traphandler14>:
TRAPHANDLER(traphandler14, T_PGFLT)
f0104426:	6a 0e                	push   $0xe
f0104428:	eb 4a                	jmp    f0104474 <_alltraps>

f010442a <traphandler16>:
// 15 reserved by intel
TRAPHANDLER_NOEC(traphandler16, T_FPERR)
f010442a:	6a 00                	push   $0x0
f010442c:	6a 10                	push   $0x10
f010442e:	eb 44                	jmp    f0104474 <_alltraps>

f0104430 <traphandler17>:
TRAPHANDLER(traphandler17, T_ALIGN)
f0104430:	6a 11                	push   $0x11
f0104432:	eb 40                	jmp    f0104474 <_alltraps>

f0104434 <traphandler18>:
TRAPHANDLER_NOEC(traphandler18, T_MCHK)
f0104434:	6a 00                	push   $0x0
f0104436:	6a 12                	push   $0x12
f0104438:	eb 3a                	jmp    f0104474 <_alltraps>

f010443a <traphandler19>:
TRAPHANDLER_NOEC(traphandler19, T_SIMDERR)
f010443a:	6a 00                	push   $0x0
f010443c:	6a 13                	push   $0x13
f010443e:	eb 34                	jmp    f0104474 <_alltraps>

f0104440 <traphandler48>:

// system call (interrupt)
TRAPHANDLER_NOEC(traphandler48, T_SYSCALL)
f0104440:	6a 00                	push   $0x0
f0104442:	6a 30                	push   $0x30
f0104444:	eb 2e                	jmp    f0104474 <_alltraps>

f0104446 <traphandler500>:
TRAPHANDLER_NOEC(traphandler500, T_DEFAULT)	
f0104446:	6a 00                	push   $0x0
f0104448:	68 f4 01 00 00       	push   $0x1f4
f010444d:	eb 25                	jmp    f0104474 <_alltraps>
f010444f:	90                   	nop

f0104450 <traphandler32>:

//IRQS
//必须用TRAPHANDLER_NOEC而不是TRAPHANDLER
TRAPHANDLER_NOEC(traphandler32, IRQ_OFFSET + IRQ_TIMER)
f0104450:	6a 00                	push   $0x0
f0104452:	6a 20                	push   $0x20
f0104454:	eb 1e                	jmp    f0104474 <_alltraps>

f0104456 <traphandler33>:
TRAPHANDLER_NOEC(traphandler33, IRQ_OFFSET + IRQ_KBD)
f0104456:	6a 00                	push   $0x0
f0104458:	6a 21                	push   $0x21
f010445a:	eb 18                	jmp    f0104474 <_alltraps>

f010445c <traphandler36>:
TRAPHANDLER_NOEC(traphandler36, IRQ_OFFSET + IRQ_SERIAL)
f010445c:	6a 00                	push   $0x0
f010445e:	6a 24                	push   $0x24
f0104460:	eb 12                	jmp    f0104474 <_alltraps>

f0104462 <traphandler39>:
TRAPHANDLER_NOEC(traphandler39, IRQ_OFFSET + IRQ_SPURIOUS)
f0104462:	6a 00                	push   $0x0
f0104464:	6a 27                	push   $0x27
f0104466:	eb 0c                	jmp    f0104474 <_alltraps>

f0104468 <traphandler46>:
TRAPHANDLER_NOEC(traphandler46, IRQ_OFFSET + IRQ_IDE)
f0104468:	6a 00                	push   $0x0
f010446a:	6a 2e                	push   $0x2e
f010446c:	eb 06                	jmp    f0104474 <_alltraps>

f010446e <traphandler51>:
TRAPHANDLER_NOEC(traphandler51, IRQ_OFFSET + IRQ_ERROR)
f010446e:	6a 00                	push   $0x0
f0104470:	6a 33                	push   $0x33
f0104472:	eb 00                	jmp    f0104474 <_alltraps>

f0104474 <_alltraps>:

/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
	pushl %ds	
f0104474:	1e                   	push   %ds
	pushl %es	
f0104475:	06                   	push   %es
	pushal
f0104476:	60                   	pusha  
	
	movw $GD_KD, %ax
f0104477:	66 b8 10 00          	mov    $0x10,%ax
	movw %ax, %ds
f010447b:	8e d8                	mov    %eax,%ds
	movw %ax, %es
f010447d:	8e c0                	mov    %eax,%es
	pushl %esp
f010447f:	54                   	push   %esp
	call trap
f0104480:	e8 0e fd ff ff       	call   f0104193 <trap>

f0104485 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f0104485:	55                   	push   %ebp
f0104486:	89 e5                	mov    %esp,%ebp
f0104488:	83 ec 08             	sub    $0x8,%esp
f010448b:	a1 48 72 23 f0       	mov    0xf0237248,%eax
f0104490:	8d 50 54             	lea    0x54(%eax),%edx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104493:	b9 00 00 00 00       	mov    $0x0,%ecx
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
f0104498:	8b 02                	mov    (%edx),%eax
f010449a:	83 e8 01             	sub    $0x1,%eax
		if ((envs[i].env_status == ENV_RUNNABLE ||
f010449d:	83 f8 02             	cmp    $0x2,%eax
f01044a0:	76 2d                	jbe    f01044cf <sched_halt+0x4a>
	for (i = 0; i < NENV; i++) {
f01044a2:	83 c1 01             	add    $0x1,%ecx
f01044a5:	83 c2 7c             	add    $0x7c,%edx
f01044a8:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f01044ae:	75 e8                	jne    f0104498 <sched_halt+0x13>
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
		cprintf("No runnable environments in the system!\n");
f01044b0:	83 ec 0c             	sub    $0xc,%esp
f01044b3:	68 b0 7a 10 f0       	push   $0xf0107ab0
f01044b8:	e8 3f f4 ff ff       	call   f01038fc <cprintf>
f01044bd:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f01044c0:	83 ec 0c             	sub    $0xc,%esp
f01044c3:	6a 00                	push   $0x0
f01044c5:	e8 81 c4 ff ff       	call   f010094b <monitor>
f01044ca:	83 c4 10             	add    $0x10,%esp
f01044cd:	eb f1                	jmp    f01044c0 <sched_halt+0x3b>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f01044cf:	e8 86 18 00 00       	call   f0105d5a <cpunum>
f01044d4:	6b c0 74             	imul   $0x74,%eax,%eax
f01044d7:	c7 80 28 80 23 f0 00 	movl   $0x0,-0xfdc7fd8(%eax)
f01044de:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f01044e1:	a1 8c 7e 23 f0       	mov    0xf0237e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f01044e6:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01044eb:	76 50                	jbe    f010453d <sched_halt+0xb8>
	return (physaddr_t)kva - KERNBASE;
f01044ed:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01044f2:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f01044f5:	e8 60 18 00 00       	call   f0105d5a <cpunum>
f01044fa:	6b d0 74             	imul   $0x74,%eax,%edx
f01044fd:	83 c2 04             	add    $0x4,%edx
	asm volatile("lock; xchgl %0, %1"
f0104500:	b8 02 00 00 00       	mov    $0x2,%eax
f0104505:	f0 87 82 20 80 23 f0 	lock xchg %eax,-0xfdc7fe0(%edx)
	spin_unlock(&kernel_lock);
f010450c:	83 ec 0c             	sub    $0xc,%esp
f010450f:	68 c0 33 12 f0       	push   $0xf01233c0
f0104514:	e8 4d 1b 00 00       	call   f0106066 <spin_unlock>
	asm volatile("pause");
f0104519:	f3 90                	pause  
		// Uncomment the following line after completing exercise 13
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f010451b:	e8 3a 18 00 00       	call   f0105d5a <cpunum>
f0104520:	6b c0 74             	imul   $0x74,%eax,%eax
	asm volatile (
f0104523:	8b 80 30 80 23 f0    	mov    -0xfdc7fd0(%eax),%eax
f0104529:	bd 00 00 00 00       	mov    $0x0,%ebp
f010452e:	89 c4                	mov    %eax,%esp
f0104530:	6a 00                	push   $0x0
f0104532:	6a 00                	push   $0x0
f0104534:	fb                   	sti    
f0104535:	f4                   	hlt    
f0104536:	eb fd                	jmp    f0104535 <sched_halt+0xb0>
}
f0104538:	83 c4 10             	add    $0x10,%esp
f010453b:	c9                   	leave  
f010453c:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010453d:	50                   	push   %eax
f010453e:	68 78 64 10 f0       	push   $0xf0106478
f0104543:	6a 50                	push   $0x50
f0104545:	68 d9 7a 10 f0       	push   $0xf0107ad9
f010454a:	e8 45 bb ff ff       	call   f0100094 <_panic>

f010454f <sched_yield>:
{
f010454f:	55                   	push   %ebp
f0104550:	89 e5                	mov    %esp,%ebp
f0104552:	56                   	push   %esi
f0104553:	53                   	push   %ebx
	idle = thiscpu->cpu_env;
f0104554:	e8 01 18 00 00       	call   f0105d5a <cpunum>
f0104559:	6b c0 74             	imul   $0x74,%eax,%eax
f010455c:	8b b0 28 80 23 f0    	mov    -0xfdc7fd8(%eax),%esi
    uint32_t start = (idle != NULL) ? ENVX( idle->env_id) : 0;
f0104562:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104567:	85 f6                	test   %esi,%esi
f0104569:	74 09                	je     f0104574 <sched_yield+0x25>
f010456b:	8b 4e 48             	mov    0x48(%esi),%ecx
f010456e:	81 e1 ff 03 00 00    	and    $0x3ff,%ecx
        if(envs[i].env_status == ENV_RUNNABLE)
f0104574:	8b 1d 48 72 23 f0    	mov    0xf0237248,%ebx
    uint32_t i = start;
f010457a:	89 c8                	mov    %ecx,%eax
        if(envs[i].env_status == ENV_RUNNABLE)
f010457c:	6b d0 7c             	imul   $0x7c,%eax,%edx
f010457f:	01 da                	add    %ebx,%edx
f0104581:	83 7a 54 02          	cmpl   $0x2,0x54(%edx)
f0104585:	74 22                	je     f01045a9 <sched_yield+0x5a>
    for (; i != start || first; i = (i+1) % NENV, first = false)
f0104587:	83 c0 01             	add    $0x1,%eax
f010458a:	25 ff 03 00 00       	and    $0x3ff,%eax
f010458f:	39 c1                	cmp    %eax,%ecx
f0104591:	75 e9                	jne    f010457c <sched_yield+0x2d>
    if (idle && idle->env_status == ENV_RUNNING)
f0104593:	85 f6                	test   %esi,%esi
f0104595:	74 06                	je     f010459d <sched_yield+0x4e>
f0104597:	83 7e 54 03          	cmpl   $0x3,0x54(%esi)
f010459b:	74 15                	je     f01045b2 <sched_yield+0x63>
	sched_halt();
f010459d:	e8 e3 fe ff ff       	call   f0104485 <sched_halt>
}
f01045a2:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01045a5:	5b                   	pop    %ebx
f01045a6:	5e                   	pop    %esi
f01045a7:	5d                   	pop    %ebp
f01045a8:	c3                   	ret    
            env_run(&envs[i]);
f01045a9:	83 ec 0c             	sub    $0xc,%esp
f01045ac:	52                   	push   %edx
f01045ad:	e8 22 f1 ff ff       	call   f01036d4 <env_run>
        env_run(idle);
f01045b2:	83 ec 0c             	sub    $0xc,%esp
f01045b5:	56                   	push   %esi
f01045b6:	e8 19 f1 ff ff       	call   f01036d4 <env_run>

f01045bb <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f01045bb:	55                   	push   %ebp
f01045bc:	89 e5                	mov    %esp,%ebp
f01045be:	57                   	push   %edi
f01045bf:	56                   	push   %esi
f01045c0:	53                   	push   %ebx
f01045c1:	83 ec 1c             	sub    $0x1c,%esp
f01045c4:	8b 45 08             	mov    0x8(%ebp),%eax
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
	int32_t ret = 0;
	switch (syscallno) {
f01045c7:	83 f8 0c             	cmp    $0xc,%eax
f01045ca:	0f 87 51 06 00 00    	ja     f0104c21 <syscall+0x666>
f01045d0:	ff 24 85 bc 7b 10 f0 	jmp    *-0xfef8444(,%eax,4)
	user_mem_assert(curenv, s, len, PTE_U);
f01045d7:	e8 7e 17 00 00       	call   f0105d5a <cpunum>
f01045dc:	6a 04                	push   $0x4
f01045de:	ff 75 10             	pushl  0x10(%ebp)
f01045e1:	ff 75 0c             	pushl  0xc(%ebp)
f01045e4:	6b c0 74             	imul   $0x74,%eax,%eax
f01045e7:	ff b0 28 80 23 f0    	pushl  -0xfdc7fd8(%eax)
f01045ed:	e8 88 e9 ff ff       	call   f0102f7a <user_mem_assert>
	cprintf("%.*s", len, s);
f01045f2:	83 c4 0c             	add    $0xc,%esp
f01045f5:	ff 75 0c             	pushl  0xc(%ebp)
f01045f8:	ff 75 10             	pushl  0x10(%ebp)
f01045fb:	68 e6 7a 10 f0       	push   $0xf0107ae6
f0104600:	e8 f7 f2 ff ff       	call   f01038fc <cprintf>
f0104605:	83 c4 10             	add    $0x10,%esp
	int32_t ret = 0;
f0104608:	bb 00 00 00 00       	mov    $0x0,%ebx
		 default:
			return -E_INVAL;

	}
	return ret;	
}
f010460d:	89 d8                	mov    %ebx,%eax
f010460f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104612:	5b                   	pop    %ebx
f0104613:	5e                   	pop    %esi
f0104614:	5f                   	pop    %edi
f0104615:	5d                   	pop    %ebp
f0104616:	c3                   	ret    
	return cons_getc();
f0104617:	e8 24 c0 ff ff       	call   f0100640 <cons_getc>
f010461c:	89 c3                	mov    %eax,%ebx
			break;
f010461e:	eb ed                	jmp    f010460d <syscall+0x52>
	if ((r = envid2env(envid, &e, 1)) < 0)
f0104620:	83 ec 04             	sub    $0x4,%esp
f0104623:	6a 01                	push   $0x1
f0104625:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104628:	50                   	push   %eax
f0104629:	ff 75 0c             	pushl  0xc(%ebp)
f010462c:	e8 1d ea ff ff       	call   f010304e <envid2env>
f0104631:	89 c3                	mov    %eax,%ebx
f0104633:	83 c4 10             	add    $0x10,%esp
f0104636:	85 c0                	test   %eax,%eax
f0104638:	78 d3                	js     f010460d <syscall+0x52>
	if (e == curenv)
f010463a:	e8 1b 17 00 00       	call   f0105d5a <cpunum>
f010463f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104642:	6b c0 74             	imul   $0x74,%eax,%eax
f0104645:	39 90 28 80 23 f0    	cmp    %edx,-0xfdc7fd8(%eax)
f010464b:	74 3a                	je     f0104687 <syscall+0xcc>
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f010464d:	8b 5a 48             	mov    0x48(%edx),%ebx
f0104650:	e8 05 17 00 00       	call   f0105d5a <cpunum>
f0104655:	83 ec 04             	sub    $0x4,%esp
f0104658:	53                   	push   %ebx
f0104659:	6b c0 74             	imul   $0x74,%eax,%eax
f010465c:	8b 80 28 80 23 f0    	mov    -0xfdc7fd8(%eax),%eax
f0104662:	ff 70 48             	pushl  0x48(%eax)
f0104665:	68 06 7b 10 f0       	push   $0xf0107b06
f010466a:	e8 8d f2 ff ff       	call   f01038fc <cprintf>
f010466f:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f0104672:	83 ec 0c             	sub    $0xc,%esp
f0104675:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104678:	e8 b8 ef ff ff       	call   f0103635 <env_destroy>
f010467d:	83 c4 10             	add    $0x10,%esp
	return 0;
f0104680:	bb 00 00 00 00       	mov    $0x0,%ebx
			break;
f0104685:	eb 86                	jmp    f010460d <syscall+0x52>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0104687:	e8 ce 16 00 00       	call   f0105d5a <cpunum>
f010468c:	83 ec 08             	sub    $0x8,%esp
f010468f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104692:	8b 80 28 80 23 f0    	mov    -0xfdc7fd8(%eax),%eax
f0104698:	ff 70 48             	pushl  0x48(%eax)
f010469b:	68 eb 7a 10 f0       	push   $0xf0107aeb
f01046a0:	e8 57 f2 ff ff       	call   f01038fc <cprintf>
f01046a5:	83 c4 10             	add    $0x10,%esp
f01046a8:	eb c8                	jmp    f0104672 <syscall+0xb7>
	return curenv->env_id;
f01046aa:	e8 ab 16 00 00       	call   f0105d5a <cpunum>
f01046af:	6b c0 74             	imul   $0x74,%eax,%eax
f01046b2:	8b 80 28 80 23 f0    	mov    -0xfdc7fd8(%eax),%eax
f01046b8:	8b 58 48             	mov    0x48(%eax),%ebx
			break;
f01046bb:	e9 4d ff ff ff       	jmp    f010460d <syscall+0x52>
	sched_yield();
f01046c0:	e8 8a fe ff ff       	call   f010454f <sched_yield>
	if ((r = env_alloc(&e, curenv->env_id)) < 0) {
f01046c5:	e8 90 16 00 00       	call   f0105d5a <cpunum>
f01046ca:	83 ec 08             	sub    $0x8,%esp
f01046cd:	6b c0 74             	imul   $0x74,%eax,%eax
f01046d0:	8b 80 28 80 23 f0    	mov    -0xfdc7fd8(%eax),%eax
f01046d6:	ff 70 48             	pushl  0x48(%eax)
f01046d9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01046dc:	50                   	push   %eax
f01046dd:	e8 7a ea ff ff       	call   f010315c <env_alloc>
f01046e2:	89 c3                	mov    %eax,%ebx
f01046e4:	83 c4 10             	add    $0x10,%esp
f01046e7:	85 c0                	test   %eax,%eax
f01046e9:	0f 88 1e ff ff ff    	js     f010460d <syscall+0x52>
		e->env_status = ENV_NOT_RUNNABLE;
f01046ef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01046f2:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
		e->env_tf = curenv->env_tf;
f01046f9:	e8 5c 16 00 00       	call   f0105d5a <cpunum>
f01046fe:	6b c0 74             	imul   $0x74,%eax,%eax
f0104701:	8b b0 28 80 23 f0    	mov    -0xfdc7fd8(%eax),%esi
f0104707:	b9 11 00 00 00       	mov    $0x11,%ecx
f010470c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010470f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		e->env_tf.tf_regs.reg_eax = 0;
f0104711:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104714:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
		return e->env_id;
f010471b:	8b 58 48             	mov    0x48(%eax),%ebx
			break;
f010471e:	e9 ea fe ff ff       	jmp    f010460d <syscall+0x52>
    if (envid2env(envid, &e, 1) < 0) 
f0104723:	83 ec 04             	sub    $0x4,%esp
f0104726:	6a 01                	push   $0x1
f0104728:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010472b:	50                   	push   %eax
f010472c:	ff 75 0c             	pushl  0xc(%ebp)
f010472f:	e8 1a e9 ff ff       	call   f010304e <envid2env>
f0104734:	83 c4 10             	add    $0x10,%esp
f0104737:	85 c0                	test   %eax,%eax
f0104739:	78 20                	js     f010475b <syscall+0x1a0>
    if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE) 
f010473b:	8b 45 10             	mov    0x10(%ebp),%eax
f010473e:	83 e8 02             	sub    $0x2,%eax
f0104741:	a9 fd ff ff ff       	test   $0xfffffffd,%eax
f0104746:	75 1d                	jne    f0104765 <syscall+0x1aa>
    e->env_status = status;
f0104748:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010474b:	8b 4d 10             	mov    0x10(%ebp),%ecx
f010474e:	89 48 54             	mov    %ecx,0x54(%eax)
    return 0;
f0104751:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104756:	e9 b2 fe ff ff       	jmp    f010460d <syscall+0x52>
		return -E_BAD_ENV;
f010475b:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f0104760:	e9 a8 fe ff ff       	jmp    f010460d <syscall+0x52>
		return -E_INVAL;
f0104765:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
   		     break;
f010476a:	e9 9e fe ff ff       	jmp    f010460d <syscall+0x52>
	int r = envid2env(envid, &e, true);
f010476f:	83 ec 04             	sub    $0x4,%esp
f0104772:	6a 01                	push   $0x1
f0104774:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104777:	50                   	push   %eax
f0104778:	ff 75 0c             	pushl  0xc(%ebp)
f010477b:	e8 ce e8 ff ff       	call   f010304e <envid2env>
f0104780:	89 c3                	mov    %eax,%ebx
	if (r != 0) {
f0104782:	83 c4 10             	add    $0x10,%esp
f0104785:	85 c0                	test   %eax,%eax
f0104787:	0f 85 80 fe ff ff    	jne    f010460d <syscall+0x52>
	assert(func != NULL);
f010478d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0104791:	74 1c                	je     f01047af <syscall+0x1f4>
	e->env_pgfault_upcall = func;
f0104793:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104796:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104799:	89 78 64             	mov    %edi,0x64(%eax)
	user_mem_assert(e, func, 4, 0);
f010479c:	6a 00                	push   $0x0
f010479e:	6a 04                	push   $0x4
f01047a0:	57                   	push   %edi
f01047a1:	50                   	push   %eax
f01047a2:	e8 d3 e7 ff ff       	call   f0102f7a <user_mem_assert>
f01047a7:	83 c4 10             	add    $0x10,%esp
			break;
f01047aa:	e9 5e fe ff ff       	jmp    f010460d <syscall+0x52>
	assert(func != NULL);
f01047af:	68 1e 7b 10 f0       	push   $0xf0107b1e
f01047b4:	68 be 69 10 f0       	push   $0xf01069be
f01047b9:	68 91 00 00 00       	push   $0x91
f01047be:	68 2b 7b 10 f0       	push   $0xf0107b2b
f01047c3:	e8 cc b8 ff ff       	call   f0100094 <_panic>
	   (perm & (~(PTE_U|PTE_AVAIL|PTE_P|PTE_W))) != 0 ||
f01047c8:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f01047cf:	0f 87 82 00 00 00    	ja     f0104857 <syscall+0x29c>
	   (uintptr_t)va >= UTOP || 
f01047d5:	8b 45 14             	mov    0x14(%ebp),%eax
f01047d8:	25 fd f1 ff ff       	and    $0xfffff1fd,%eax
f01047dd:	83 f0 05             	xor    $0x5,%eax
	   PGOFF(va) != 0)
f01047e0:	8b 55 10             	mov    0x10(%ebp),%edx
f01047e3:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
	   (uintptr_t)va >= UTOP || 
f01047e9:	09 d0                	or     %edx,%eax
f01047eb:	75 74                	jne    f0104861 <syscall+0x2a6>
	struct PageInfo *pginfo = page_alloc(ALLOC_ZERO);
f01047ed:	83 ec 0c             	sub    $0xc,%esp
f01047f0:	6a 01                	push   $0x1
f01047f2:	e8 9a c7 ff ff       	call   f0100f91 <page_alloc>
f01047f7:	89 c6                	mov    %eax,%esi
	if (!pginfo) return -E_NO_MEM;
f01047f9:	83 c4 10             	add    $0x10,%esp
f01047fc:	85 c0                	test   %eax,%eax
f01047fe:	74 6b                	je     f010486b <syscall+0x2b0>
	if((r = envid2env(envid, &e, 1)) < 0) return r;
f0104800:	83 ec 04             	sub    $0x4,%esp
f0104803:	6a 01                	push   $0x1
f0104805:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104808:	50                   	push   %eax
f0104809:	ff 75 0c             	pushl  0xc(%ebp)
f010480c:	e8 3d e8 ff ff       	call   f010304e <envid2env>
f0104811:	89 c3                	mov    %eax,%ebx
f0104813:	83 c4 10             	add    $0x10,%esp
f0104816:	85 c0                	test   %eax,%eax
f0104818:	0f 88 ef fd ff ff    	js     f010460d <syscall+0x52>
	r = page_insert(e->env_pgdir, pginfo, va, perm);
f010481e:	ff 75 14             	pushl  0x14(%ebp)
f0104821:	ff 75 10             	pushl  0x10(%ebp)
f0104824:	56                   	push   %esi
f0104825:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104828:	ff 70 60             	pushl  0x60(%eax)
f010482b:	e8 22 ca ff ff       	call   f0101252 <page_insert>
	if (r<0) {
f0104830:	83 c4 10             	add    $0x10,%esp
f0104833:	85 c0                	test   %eax,%eax
f0104835:	78 0a                	js     f0104841 <syscall+0x286>
	return 0;
f0104837:	bb 00 00 00 00       	mov    $0x0,%ebx
       	    break;
f010483c:	e9 cc fd ff ff       	jmp    f010460d <syscall+0x52>
		 page_free(pginfo);
f0104841:	83 ec 0c             	sub    $0xc,%esp
f0104844:	56                   	push   %esi
f0104845:	e8 b9 c7 ff ff       	call   f0101003 <page_free>
f010484a:	83 c4 10             	add    $0x10,%esp
		 return -E_NO_MEM;
f010484d:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
f0104852:	e9 b6 fd ff ff       	jmp    f010460d <syscall+0x52>
		 return -E_INVAL;
f0104857:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010485c:	e9 ac fd ff ff       	jmp    f010460d <syscall+0x52>
f0104861:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104866:	e9 a2 fd ff ff       	jmp    f010460d <syscall+0x52>
	if (!pginfo) return -E_NO_MEM;
f010486b:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
f0104870:	e9 98 fd ff ff       	jmp    f010460d <syscall+0x52>
	struct Env *src_env = NULL;
f0104875:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	int r = envid2env(srcenvid, &src_env, true);
f010487c:	83 ec 04             	sub    $0x4,%esp
f010487f:	6a 01                	push   $0x1
f0104881:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104884:	50                   	push   %eax
f0104885:	ff 75 0c             	pushl  0xc(%ebp)
f0104888:	e8 c1 e7 ff ff       	call   f010304e <envid2env>
f010488d:	89 c3                	mov    %eax,%ebx
	if( r != 0 ) { 
f010488f:	83 c4 10             	add    $0x10,%esp
f0104892:	85 c0                	test   %eax,%eax
f0104894:	0f 85 73 fd ff ff    	jne    f010460d <syscall+0x52>
	assert(src_env != NULL);
f010489a:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010489d:	85 c0                	test   %eax,%eax
f010489f:	0f 84 e5 00 00 00    	je     f010498a <syscall+0x3cf>
	assert(srcenvid == 0 || src_env->env_id == srcenvid);
f01048a5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01048a9:	74 0c                	je     f01048b7 <syscall+0x2fc>
f01048ab:	8b 40 48             	mov    0x48(%eax),%eax
f01048ae:	39 45 0c             	cmp    %eax,0xc(%ebp)
f01048b1:	0f 85 ec 00 00 00    	jne    f01049a3 <syscall+0x3e8>
	struct Env *dst_env = NULL;
f01048b7:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
	r = envid2env(dstenvid, &dst_env, true);
f01048be:	83 ec 04             	sub    $0x4,%esp
f01048c1:	6a 01                	push   $0x1
f01048c3:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01048c6:	50                   	push   %eax
f01048c7:	ff 75 14             	pushl  0x14(%ebp)
f01048ca:	e8 7f e7 ff ff       	call   f010304e <envid2env>
f01048cf:	89 c3                	mov    %eax,%ebx
	if( r != 0 ) { 
f01048d1:	83 c4 10             	add    $0x10,%esp
f01048d4:	85 c0                	test   %eax,%eax
f01048d6:	0f 85 31 fd ff ff    	jne    f010460d <syscall+0x52>
	assert(dst_env != NULL);
f01048dc:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01048df:	85 c0                	test   %eax,%eax
f01048e1:	0f 84 d5 00 00 00    	je     f01049bc <syscall+0x401>
	assert(dstenvid == 0 || dst_env->env_id == dstenvid);
f01048e7:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
f01048eb:	74 0c                	je     f01048f9 <syscall+0x33e>
f01048ed:	8b 40 48             	mov    0x48(%eax),%eax
f01048f0:	39 45 14             	cmp    %eax,0x14(%ebp)
f01048f3:	0f 85 dc 00 00 00    	jne    f01049d5 <syscall+0x41a>
	if((uint32_t)srcva >= UTOP || (uint32_t)dstva >= UTOP || \
f01048f9:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104900:	0f 87 e8 00 00 00    	ja     f01049ee <syscall+0x433>
f0104906:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f010490d:	0f 87 db 00 00 00    	ja     f01049ee <syscall+0x433>
		PGOFF(srcva) != 0 || PGOFF(dstva) != 0) {
f0104913:	8b 45 10             	mov    0x10(%ebp),%eax
f0104916:	0b 45 18             	or     0x18(%ebp),%eax
f0104919:	a9 ff 0f 00 00       	test   $0xfff,%eax
f010491e:	0f 85 d4 00 00 00    	jne    f01049f8 <syscall+0x43d>
	if(( perm & PTE_U) == 0 || (perm & PTE_P) == 0 || (perm & ~PTE_SYSCALL) != 0) {
f0104924:	8b 45 1c             	mov    0x1c(%ebp),%eax
f0104927:	25 fd f1 ff ff       	and    $0xfffff1fd,%eax
f010492c:	83 f8 05             	cmp    $0x5,%eax
f010492f:	0f 85 cd 00 00 00    	jne    f0104a02 <syscall+0x447>
	pte_t *src_ptep = NULL;
f0104935:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	struct PageInfo *pp = page_lookup(src_env->env_pgdir, srcva, &src_ptep);
f010493c:	83 ec 04             	sub    $0x4,%esp
f010493f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104942:	50                   	push   %eax
f0104943:	ff 75 10             	pushl  0x10(%ebp)
f0104946:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104949:	ff 70 60             	pushl  0x60(%eax)
f010494c:	e8 2a c8 ff ff       	call   f010117b <page_lookup>
	if(!pp || ((perm & PTE_W) && ((*src_ptep & PTE_W) != PTE_W))) {
f0104951:	83 c4 10             	add    $0x10,%esp
f0104954:	85 c0                	test   %eax,%eax
f0104956:	0f 84 b0 00 00 00    	je     f0104a0c <syscall+0x451>
f010495c:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f0104960:	74 0c                	je     f010496e <syscall+0x3b3>
f0104962:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104965:	f6 02 02             	testb  $0x2,(%edx)
f0104968:	0f 84 a8 00 00 00    	je     f0104a16 <syscall+0x45b>
	return page_insert(dst_env->env_pgdir, pp, dstva, perm);
f010496e:	ff 75 1c             	pushl  0x1c(%ebp)
f0104971:	ff 75 18             	pushl  0x18(%ebp)
f0104974:	50                   	push   %eax
f0104975:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104978:	ff 70 60             	pushl  0x60(%eax)
f010497b:	e8 d2 c8 ff ff       	call   f0101252 <page_insert>
f0104980:	89 c3                	mov    %eax,%ebx
f0104982:	83 c4 10             	add    $0x10,%esp
f0104985:	e9 83 fc ff ff       	jmp    f010460d <syscall+0x52>
	assert(src_env != NULL);
f010498a:	68 3a 7b 10 f0       	push   $0xf0107b3a
f010498f:	68 be 69 10 f0       	push   $0xf01069be
f0104994:	68 eb 00 00 00       	push   $0xeb
f0104999:	68 2b 7b 10 f0       	push   $0xf0107b2b
f010499e:	e8 f1 b6 ff ff       	call   f0100094 <_panic>
	assert(srcenvid == 0 || src_env->env_id == srcenvid);
f01049a3:	68 5c 7b 10 f0       	push   $0xf0107b5c
f01049a8:	68 be 69 10 f0       	push   $0xf01069be
f01049ad:	68 ec 00 00 00       	push   $0xec
f01049b2:	68 2b 7b 10 f0       	push   $0xf0107b2b
f01049b7:	e8 d8 b6 ff ff       	call   f0100094 <_panic>
	assert(dst_env != NULL);
f01049bc:	68 4a 7b 10 f0       	push   $0xf0107b4a
f01049c1:	68 be 69 10 f0       	push   $0xf01069be
f01049c6:	68 f2 00 00 00       	push   $0xf2
f01049cb:	68 2b 7b 10 f0       	push   $0xf0107b2b
f01049d0:	e8 bf b6 ff ff       	call   f0100094 <_panic>
	assert(dstenvid == 0 || dst_env->env_id == dstenvid);
f01049d5:	68 8c 7b 10 f0       	push   $0xf0107b8c
f01049da:	68 be 69 10 f0       	push   $0xf01069be
f01049df:	68 f3 00 00 00       	push   $0xf3
f01049e4:	68 2b 7b 10 f0       	push   $0xf0107b2b
f01049e9:	e8 a6 b6 ff ff       	call   f0100094 <_panic>
		return -E_INVAL;
f01049ee:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01049f3:	e9 15 fc ff ff       	jmp    f010460d <syscall+0x52>
f01049f8:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01049fd:	e9 0b fc ff ff       	jmp    f010460d <syscall+0x52>
		return -E_INVAL;
f0104a02:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104a07:	e9 01 fc ff ff       	jmp    f010460d <syscall+0x52>
		return -E_INVAL;
f0104a0c:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104a11:	e9 f7 fb ff ff       	jmp    f010460d <syscall+0x52>
f0104a16:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
            break;
f0104a1b:	e9 ed fb ff ff       	jmp    f010460d <syscall+0x52>
    if (envid2env(envid, &e, 1) < 0) 
f0104a20:	83 ec 04             	sub    $0x4,%esp
f0104a23:	6a 01                	push   $0x1
f0104a25:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104a28:	50                   	push   %eax
f0104a29:	ff 75 0c             	pushl  0xc(%ebp)
f0104a2c:	e8 1d e6 ff ff       	call   f010304e <envid2env>
f0104a31:	83 c4 10             	add    $0x10,%esp
f0104a34:	85 c0                	test   %eax,%eax
f0104a36:	78 30                	js     f0104a68 <syscall+0x4ad>
	if ((uintptr_t)va >= UTOP || PGOFF(va) != 0) 
f0104a38:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104a3f:	77 31                	ja     f0104a72 <syscall+0x4b7>
f0104a41:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104a48:	75 32                	jne    f0104a7c <syscall+0x4c1>
    page_remove(e->env_pgdir, va);
f0104a4a:	83 ec 08             	sub    $0x8,%esp
f0104a4d:	ff 75 10             	pushl  0x10(%ebp)
f0104a50:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104a53:	ff 70 60             	pushl  0x60(%eax)
f0104a56:	e8 b1 c7 ff ff       	call   f010120c <page_remove>
f0104a5b:	83 c4 10             	add    $0x10,%esp
    return 0;	
f0104a5e:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104a63:	e9 a5 fb ff ff       	jmp    f010460d <syscall+0x52>
		return -E_BAD_ENV;
f0104a68:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f0104a6d:	e9 9b fb ff ff       	jmp    f010460d <syscall+0x52>
		return -E_INVAL;
f0104a72:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104a77:	e9 91 fb ff ff       	jmp    f010460d <syscall+0x52>
f0104a7c:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
       	    break;
f0104a81:	e9 87 fb ff ff       	jmp    f010460d <syscall+0x52>
	struct Env* recv = NULL;
f0104a86:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
	if((error_code = envid2env(envid, &recv, 0)) < 0)
f0104a8d:	83 ec 04             	sub    $0x4,%esp
f0104a90:	6a 00                	push   $0x0
f0104a92:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104a95:	50                   	push   %eax
f0104a96:	ff 75 0c             	pushl  0xc(%ebp)
f0104a99:	e8 b0 e5 ff ff       	call   f010304e <envid2env>
f0104a9e:	89 c3                	mov    %eax,%ebx
f0104aa0:	83 c4 10             	add    $0x10,%esp
f0104aa3:	85 c0                	test   %eax,%eax
f0104aa5:	0f 88 62 fb ff ff    	js     f010460d <syscall+0x52>
	if(!recv->env_ipc_recving)
f0104aab:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104aae:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f0104ab2:	0f 84 03 01 00 00    	je     f0104bbb <syscall+0x600>
	recv->env_ipc_perm = 0;
f0104ab8:	c7 40 78 00 00 00 00 	movl   $0x0,0x78(%eax)
	recv->env_ipc_from = curenv->env_id;
f0104abf:	e8 96 12 00 00       	call   f0105d5a <cpunum>
f0104ac4:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104ac7:	6b c0 74             	imul   $0x74,%eax,%eax
f0104aca:	8b 80 28 80 23 f0    	mov    -0xfdc7fd8(%eax),%eax
f0104ad0:	8b 40 48             	mov    0x48(%eax),%eax
f0104ad3:	89 42 74             	mov    %eax,0x74(%edx)
	recv->env_ipc_value = value;
f0104ad6:	8b 45 10             	mov    0x10(%ebp),%eax
f0104ad9:	89 42 70             	mov    %eax,0x70(%edx)
	if((uintptr_t)srcva < UTOP && (uintptr_t)(recv->env_ipc_dstva) < UTOP)
f0104adc:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f0104ae3:	0f 87 9f 00 00 00    	ja     f0104b88 <syscall+0x5cd>
f0104ae9:	81 7a 6c ff ff bf ee 	cmpl   $0xeebfffff,0x6c(%edx)
f0104af0:	0f 87 92 00 00 00    	ja     f0104b88 <syscall+0x5cd>
			return -E_INVAL;
f0104af6:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
		if((uintptr_t)srcva != ROUNDDOWN((uintptr_t)srcva, PGSIZE))
f0104afb:	f7 45 14 ff 0f 00 00 	testl  $0xfff,0x14(%ebp)
f0104b02:	0f 85 05 fb ff ff    	jne    f010460d <syscall+0x52>
		if(((perm & PTE_U) == 0) || ((perm & PTE_P) == 0) )
f0104b08:	8b 45 18             	mov    0x18(%ebp),%eax
f0104b0b:	83 e0 05             	and    $0x5,%eax
f0104b0e:	83 f8 05             	cmp    $0x5,%eax
f0104b11:	0f 85 f6 fa ff ff    	jne    f010460d <syscall+0x52>
		if((perm & ~PTE_SYSCALL) != 0)
f0104b17:	f7 45 18 f8 f1 ff ff 	testl  $0xfffff1f8,0x18(%ebp)
f0104b1e:	0f 85 e9 fa ff ff    	jne    f010460d <syscall+0x52>
		pte_t* pte_addr = NULL;
f0104b24:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		page = page_lookup(curenv->env_pgdir, srcva, &pte_addr);
f0104b2b:	e8 2a 12 00 00       	call   f0105d5a <cpunum>
f0104b30:	83 ec 04             	sub    $0x4,%esp
f0104b33:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104b36:	52                   	push   %edx
f0104b37:	ff 75 14             	pushl  0x14(%ebp)
f0104b3a:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b3d:	8b 80 28 80 23 f0    	mov    -0xfdc7fd8(%eax),%eax
f0104b43:	ff 70 60             	pushl  0x60(%eax)
f0104b46:	e8 30 c6 ff ff       	call   f010117b <page_lookup>
		if(page == NULL)
f0104b4b:	83 c4 10             	add    $0x10,%esp
f0104b4e:	85 c0                	test   %eax,%eax
f0104b50:	74 55                	je     f0104ba7 <syscall+0x5ec>
		if((perm & PTE_W) && !((*pte_addr) & PTE_W))
f0104b52:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f0104b56:	74 08                	je     f0104b60 <syscall+0x5a5>
f0104b58:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104b5b:	f6 02 02             	testb  $0x2,(%edx)
f0104b5e:	74 51                	je     f0104bb1 <syscall+0x5f6>
		if((error_code = page_insert(recv->env_pgdir, page, recv->env_ipc_dstva, perm)) < 0)
f0104b60:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104b63:	ff 75 18             	pushl  0x18(%ebp)
f0104b66:	ff 72 6c             	pushl  0x6c(%edx)
f0104b69:	50                   	push   %eax
f0104b6a:	ff 72 60             	pushl  0x60(%edx)
f0104b6d:	e8 e0 c6 ff ff       	call   f0101252 <page_insert>
f0104b72:	89 c3                	mov    %eax,%ebx
f0104b74:	83 c4 10             	add    $0x10,%esp
f0104b77:	85 c0                	test   %eax,%eax
f0104b79:	0f 88 8e fa ff ff    	js     f010460d <syscall+0x52>
		recv->env_ipc_perm = perm;
f0104b7f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104b82:	8b 7d 18             	mov    0x18(%ebp),%edi
f0104b85:	89 78 78             	mov    %edi,0x78(%eax)
	recv->env_ipc_recving = 0;
f0104b88:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104b8b:	c6 40 68 00          	movb   $0x0,0x68(%eax)
	recv->env_tf.tf_regs.reg_eax = 0;
f0104b8f:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	recv->env_status = ENV_RUNNABLE;
f0104b96:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	return 0;
f0104b9d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104ba2:	e9 66 fa ff ff       	jmp    f010460d <syscall+0x52>
			return -E_INVAL;
f0104ba7:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104bac:	e9 5c fa ff ff       	jmp    f010460d <syscall+0x52>
			return -E_INVAL;
f0104bb1:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104bb6:	e9 52 fa ff ff       	jmp    f010460d <syscall+0x52>
		return -E_IPC_NOT_RECV;
f0104bbb:	bb f9 ff ff ff       	mov    $0xfffffff9,%ebx
			break;
f0104bc0:	e9 48 fa ff ff       	jmp    f010460d <syscall+0x52>
	if ((uintptr_t)dstva < UTOP ) {
f0104bc5:	81 7d 0c ff ff bf ee 	cmpl   $0xeebfffff,0xc(%ebp)
f0104bcc:	77 27                	ja     f0104bf5 <syscall+0x63a>
		 if (PGOFF(dstva) != 0)
f0104bce:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
f0104bd5:	74 0a                	je     f0104be1 <syscall+0x626>
			ret = sys_ipc_recv((void *) a1);
f0104bd7:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104bdc:	e9 2c fa ff ff       	jmp    f010460d <syscall+0x52>
		 curenv->env_ipc_dstva =dstva;
f0104be1:	e8 74 11 00 00       	call   f0105d5a <cpunum>
f0104be6:	6b c0 74             	imul   $0x74,%eax,%eax
f0104be9:	8b 80 28 80 23 f0    	mov    -0xfdc7fd8(%eax),%eax
f0104bef:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0104bf2:	89 78 6c             	mov    %edi,0x6c(%eax)
	curenv->env_ipc_recving = 1;
f0104bf5:	e8 60 11 00 00       	call   f0105d5a <cpunum>
f0104bfa:	6b c0 74             	imul   $0x74,%eax,%eax
f0104bfd:	8b 80 28 80 23 f0    	mov    -0xfdc7fd8(%eax),%eax
f0104c03:	c6 40 68 01          	movb   $0x1,0x68(%eax)
	curenv->env_status = ENV_NOT_RUNNABLE;
f0104c07:	e8 4e 11 00 00       	call   f0105d5a <cpunum>
f0104c0c:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c0f:	8b 80 28 80 23 f0    	mov    -0xfdc7fd8(%eax),%eax
f0104c15:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	sched_yield();
f0104c1c:	e8 2e f9 ff ff       	call   f010454f <sched_yield>
			return -E_INVAL;
f0104c21:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104c26:	e9 e2 f9 ff ff       	jmp    f010460d <syscall+0x52>

f0104c2b <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0104c2b:	55                   	push   %ebp
f0104c2c:	89 e5                	mov    %esp,%ebp
f0104c2e:	57                   	push   %edi
f0104c2f:	56                   	push   %esi
f0104c30:	53                   	push   %ebx
f0104c31:	83 ec 14             	sub    $0x14,%esp
f0104c34:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104c37:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104c3a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104c3d:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0104c40:	8b 1a                	mov    (%edx),%ebx
f0104c42:	8b 01                	mov    (%ecx),%eax
f0104c44:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104c47:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0104c4e:	eb 23                	jmp    f0104c73 <stab_binsearch+0x48>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0104c50:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0104c53:	eb 1e                	jmp    f0104c73 <stab_binsearch+0x48>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0104c55:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104c58:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104c5b:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0104c5f:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0104c62:	73 41                	jae    f0104ca5 <stab_binsearch+0x7a>
			*region_left = m;
f0104c64:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104c67:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0104c69:	8d 5f 01             	lea    0x1(%edi),%ebx
		any_matches = 1;
f0104c6c:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0104c73:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0104c76:	7f 5a                	jg     f0104cd2 <stab_binsearch+0xa7>
		int true_m = (l + r) / 2, m = true_m;
f0104c78:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104c7b:	01 d8                	add    %ebx,%eax
f0104c7d:	89 c7                	mov    %eax,%edi
f0104c7f:	c1 ef 1f             	shr    $0x1f,%edi
f0104c82:	01 c7                	add    %eax,%edi
f0104c84:	d1 ff                	sar    %edi
f0104c86:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0104c89:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104c8c:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0104c90:	89 f8                	mov    %edi,%eax
		while (m >= l && stabs[m].n_type != type)
f0104c92:	39 c3                	cmp    %eax,%ebx
f0104c94:	7f ba                	jg     f0104c50 <stab_binsearch+0x25>
f0104c96:	0f b6 0a             	movzbl (%edx),%ecx
f0104c99:	83 ea 0c             	sub    $0xc,%edx
f0104c9c:	39 f1                	cmp    %esi,%ecx
f0104c9e:	74 b5                	je     f0104c55 <stab_binsearch+0x2a>
			m--;
f0104ca0:	83 e8 01             	sub    $0x1,%eax
f0104ca3:	eb ed                	jmp    f0104c92 <stab_binsearch+0x67>
		} else if (stabs[m].n_value > addr) {
f0104ca5:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0104ca8:	76 14                	jbe    f0104cbe <stab_binsearch+0x93>
			*region_right = m - 1;
f0104caa:	83 e8 01             	sub    $0x1,%eax
f0104cad:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104cb0:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0104cb3:	89 07                	mov    %eax,(%edi)
		any_matches = 1;
f0104cb5:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104cbc:	eb b5                	jmp    f0104c73 <stab_binsearch+0x48>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0104cbe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104cc1:	89 07                	mov    %eax,(%edi)
			l = m;
			addr++;
f0104cc3:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0104cc7:	89 c3                	mov    %eax,%ebx
		any_matches = 1;
f0104cc9:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104cd0:	eb a1                	jmp    f0104c73 <stab_binsearch+0x48>
		}
	}

	if (!any_matches)
f0104cd2:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0104cd6:	75 15                	jne    f0104ced <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f0104cd8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104cdb:	8b 00                	mov    (%eax),%eax
f0104cdd:	83 e8 01             	sub    $0x1,%eax
f0104ce0:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104ce3:	89 06                	mov    %eax,(%esi)
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0104ce5:	83 c4 14             	add    $0x14,%esp
f0104ce8:	5b                   	pop    %ebx
f0104ce9:	5e                   	pop    %esi
f0104cea:	5f                   	pop    %edi
f0104ceb:	5d                   	pop    %ebp
f0104cec:	c3                   	ret    
		for (l = *region_right;
f0104ced:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104cf0:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0104cf2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104cf5:	8b 0f                	mov    (%edi),%ecx
f0104cf7:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104cfa:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0104cfd:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
		for (l = *region_right;
f0104d01:	eb 03                	jmp    f0104d06 <stab_binsearch+0xdb>
		     l--)
f0104d03:	83 e8 01             	sub    $0x1,%eax
		for (l = *region_right;
f0104d06:	39 c1                	cmp    %eax,%ecx
f0104d08:	7d 0a                	jge    f0104d14 <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f0104d0a:	0f b6 1a             	movzbl (%edx),%ebx
f0104d0d:	83 ea 0c             	sub    $0xc,%edx
f0104d10:	39 f3                	cmp    %esi,%ebx
f0104d12:	75 ef                	jne    f0104d03 <stab_binsearch+0xd8>
		*region_left = l;
f0104d14:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104d17:	89 06                	mov    %eax,(%esi)
}
f0104d19:	eb ca                	jmp    f0104ce5 <stab_binsearch+0xba>

f0104d1b <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0104d1b:	55                   	push   %ebp
f0104d1c:	89 e5                	mov    %esp,%ebp
f0104d1e:	57                   	push   %edi
f0104d1f:	56                   	push   %esi
f0104d20:	53                   	push   %ebx
f0104d21:	83 ec 4c             	sub    $0x4c,%esp
f0104d24:	8b 75 08             	mov    0x8(%ebp),%esi
f0104d27:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0104d2a:	c7 03 f0 7b 10 f0    	movl   $0xf0107bf0,(%ebx)
	info->eip_line = 0;
f0104d30:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0104d37:	c7 43 08 f0 7b 10 f0 	movl   $0xf0107bf0,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0104d3e:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0104d45:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0104d48:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0104d4f:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0104d55:	0f 87 1d 01 00 00    	ja     f0104e78 <debuginfo_eip+0x15d>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f0104d5b:	a1 00 00 20 00       	mov    0x200000,%eax
f0104d60:	89 45 b8             	mov    %eax,-0x48(%ebp)
		stab_end = usd->stab_end;
f0104d63:	a1 04 00 20 00       	mov    0x200004,%eax
		stabstr = usd->stabstr;
f0104d68:	8b 3d 08 00 20 00    	mov    0x200008,%edi
f0104d6e:	89 7d b4             	mov    %edi,-0x4c(%ebp)
		stabstr_end = usd->stabstr_end;
f0104d71:	8b 3d 0c 00 20 00    	mov    0x20000c,%edi
f0104d77:	89 7d bc             	mov    %edi,-0x44(%ebp)
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0104d7a:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0104d7d:	39 7d b4             	cmp    %edi,-0x4c(%ebp)
f0104d80:	0f 83 bb 01 00 00    	jae    f0104f41 <debuginfo_eip+0x226>
f0104d86:	80 7f ff 00          	cmpb   $0x0,-0x1(%edi)
f0104d8a:	0f 85 b8 01 00 00    	jne    f0104f48 <debuginfo_eip+0x22d>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0104d90:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0104d97:	8b 7d b8             	mov    -0x48(%ebp),%edi
f0104d9a:	29 f8                	sub    %edi,%eax
f0104d9c:	c1 f8 02             	sar    $0x2,%eax
f0104d9f:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0104da5:	83 e8 01             	sub    $0x1,%eax
f0104da8:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0104dab:	56                   	push   %esi
f0104dac:	6a 64                	push   $0x64
f0104dae:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104db1:	89 c1                	mov    %eax,%ecx
f0104db3:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104db6:	89 f8                	mov    %edi,%eax
f0104db8:	e8 6e fe ff ff       	call   f0104c2b <stab_binsearch>
	if (lfile == 0)
f0104dbd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104dc0:	83 c4 08             	add    $0x8,%esp
f0104dc3:	85 c0                	test   %eax,%eax
f0104dc5:	0f 84 84 01 00 00    	je     f0104f4f <debuginfo_eip+0x234>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0104dcb:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0104dce:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104dd1:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0104dd4:	56                   	push   %esi
f0104dd5:	6a 24                	push   $0x24
f0104dd7:	8d 45 d8             	lea    -0x28(%ebp),%eax
f0104dda:	89 c1                	mov    %eax,%ecx
f0104ddc:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0104ddf:	89 f8                	mov    %edi,%eax
f0104de1:	e8 45 fe ff ff       	call   f0104c2b <stab_binsearch>

	if (lfun <= rfun) {
f0104de6:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104de9:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0104dec:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
f0104def:	83 c4 08             	add    $0x8,%esp
f0104df2:	39 c8                	cmp    %ecx,%eax
f0104df4:	0f 8f 9d 00 00 00    	jg     f0104e97 <debuginfo_eip+0x17c>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0104dfa:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104dfd:	8d 0c 97             	lea    (%edi,%edx,4),%ecx
f0104e00:	8b 11                	mov    (%ecx),%edx
f0104e02:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0104e05:	2b 7d b4             	sub    -0x4c(%ebp),%edi
f0104e08:	39 fa                	cmp    %edi,%edx
f0104e0a:	73 06                	jae    f0104e12 <debuginfo_eip+0xf7>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0104e0c:	03 55 b4             	add    -0x4c(%ebp),%edx
f0104e0f:	89 53 08             	mov    %edx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0104e12:	8b 51 08             	mov    0x8(%ecx),%edx
f0104e15:	89 53 10             	mov    %edx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0104e18:	29 d6                	sub    %edx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0104e1a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0104e1d:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0104e20:	89 45 d0             	mov    %eax,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0104e23:	83 ec 08             	sub    $0x8,%esp
f0104e26:	6a 3a                	push   $0x3a
f0104e28:	ff 73 08             	pushl  0x8(%ebx)
f0104e2b:	e8 0e 09 00 00       	call   f010573e <strfind>
f0104e30:	2b 43 08             	sub    0x8(%ebx),%eax
f0104e33:	89 43 0c             	mov    %eax,0xc(%ebx)
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0104e36:	83 c4 08             	add    $0x8,%esp
f0104e39:	56                   	push   %esi
f0104e3a:	6a 44                	push   $0x44
f0104e3c:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0104e3f:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0104e42:	8b 75 b8             	mov    -0x48(%ebp),%esi
f0104e45:	89 f0                	mov    %esi,%eax
f0104e47:	e8 df fd ff ff       	call   f0104c2b <stab_binsearch>
	if (lline <= rline) {
f0104e4c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0104e4f:	83 c4 10             	add    $0x10,%esp
f0104e52:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f0104e55:	0f 8f fb 00 00 00    	jg     f0104f56 <debuginfo_eip+0x23b>
		 info->eip_line = stabs[lline].n_desc;
f0104e5b:	89 d0                	mov    %edx,%eax
f0104e5d:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0104e60:	c1 e2 02             	shl    $0x2,%edx
f0104e63:	0f b7 4c 16 06       	movzwl 0x6(%esi,%edx,1),%ecx
f0104e68:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104e6b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104e6e:	8d 54 16 04          	lea    0x4(%esi,%edx,1),%edx
f0104e72:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f0104e76:	eb 3d                	jmp    f0104eb5 <debuginfo_eip+0x19a>
		stabstr_end = __STABSTR_END__;
f0104e78:	c7 45 bc e1 84 11 f0 	movl   $0xf01184e1,-0x44(%ebp)
		stabstr = __STABSTR_BEGIN__;
f0104e7f:	c7 45 b4 a5 4c 11 f0 	movl   $0xf0114ca5,-0x4c(%ebp)
		stab_end = __STAB_END__;
f0104e86:	b8 a4 4c 11 f0       	mov    $0xf0114ca4,%eax
		stabs = __STAB_BEGIN__;
f0104e8b:	c7 45 b8 d4 80 10 f0 	movl   $0xf01080d4,-0x48(%ebp)
f0104e92:	e9 e3 fe ff ff       	jmp    f0104d7a <debuginfo_eip+0x5f>
		info->eip_fn_addr = addr;
f0104e97:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0104e9a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104e9d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0104ea0:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104ea3:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0104ea6:	e9 78 ff ff ff       	jmp    f0104e23 <debuginfo_eip+0x108>
f0104eab:	83 e8 01             	sub    $0x1,%eax
f0104eae:	83 ea 0c             	sub    $0xc,%edx
f0104eb1:	c6 45 c4 01          	movb   $0x1,-0x3c(%ebp)
f0104eb5:	89 45 c0             	mov    %eax,-0x40(%ebp)
	while (lline >= lfile
f0104eb8:	39 c7                	cmp    %eax,%edi
f0104eba:	7f 45                	jg     f0104f01 <debuginfo_eip+0x1e6>
	       && stabs[lline].n_type != N_SOL
f0104ebc:	0f b6 0a             	movzbl (%edx),%ecx
f0104ebf:	80 f9 84             	cmp    $0x84,%cl
f0104ec2:	74 19                	je     f0104edd <debuginfo_eip+0x1c2>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104ec4:	80 f9 64             	cmp    $0x64,%cl
f0104ec7:	75 e2                	jne    f0104eab <debuginfo_eip+0x190>
f0104ec9:	83 7a 04 00          	cmpl   $0x0,0x4(%edx)
f0104ecd:	74 dc                	je     f0104eab <debuginfo_eip+0x190>
f0104ecf:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0104ed3:	74 11                	je     f0104ee6 <debuginfo_eip+0x1cb>
f0104ed5:	8b 75 c0             	mov    -0x40(%ebp),%esi
f0104ed8:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0104edb:	eb 09                	jmp    f0104ee6 <debuginfo_eip+0x1cb>
f0104edd:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0104ee1:	74 03                	je     f0104ee6 <debuginfo_eip+0x1cb>
f0104ee3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0104ee6:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0104ee9:	8b 7d b8             	mov    -0x48(%ebp),%edi
f0104eec:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0104eef:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0104ef2:	8b 7d b4             	mov    -0x4c(%ebp),%edi
f0104ef5:	29 f8                	sub    %edi,%eax
f0104ef7:	39 c2                	cmp    %eax,%edx
f0104ef9:	73 06                	jae    f0104f01 <debuginfo_eip+0x1e6>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0104efb:	89 f8                	mov    %edi,%eax
f0104efd:	01 d0                	add    %edx,%eax
f0104eff:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104f01:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104f04:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104f07:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f0104f0c:	39 f2                	cmp    %esi,%edx
f0104f0e:	7d 52                	jge    f0104f62 <debuginfo_eip+0x247>
		for (lline = lfun + 1;
f0104f10:	83 c2 01             	add    $0x1,%edx
f0104f13:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0104f16:	89 d0                	mov    %edx,%eax
f0104f18:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0104f1b:	8b 7d b8             	mov    -0x48(%ebp),%edi
f0104f1e:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
f0104f22:	eb 04                	jmp    f0104f28 <debuginfo_eip+0x20d>
			info->eip_fn_narg++;
f0104f24:	83 43 14 01          	addl   $0x1,0x14(%ebx)
		for (lline = lfun + 1;
f0104f28:	39 c6                	cmp    %eax,%esi
f0104f2a:	7e 31                	jle    f0104f5d <debuginfo_eip+0x242>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0104f2c:	0f b6 0a             	movzbl (%edx),%ecx
f0104f2f:	83 c0 01             	add    $0x1,%eax
f0104f32:	83 c2 0c             	add    $0xc,%edx
f0104f35:	80 f9 a0             	cmp    $0xa0,%cl
f0104f38:	74 ea                	je     f0104f24 <debuginfo_eip+0x209>
	return 0;
f0104f3a:	b8 00 00 00 00       	mov    $0x0,%eax
f0104f3f:	eb 21                	jmp    f0104f62 <debuginfo_eip+0x247>
		return -1;
f0104f41:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104f46:	eb 1a                	jmp    f0104f62 <debuginfo_eip+0x247>
f0104f48:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104f4d:	eb 13                	jmp    f0104f62 <debuginfo_eip+0x247>
		return -1;
f0104f4f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104f54:	eb 0c                	jmp    f0104f62 <debuginfo_eip+0x247>
		 return -1;
f0104f56:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104f5b:	eb 05                	jmp    f0104f62 <debuginfo_eip+0x247>
	return 0;
f0104f5d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104f62:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104f65:	5b                   	pop    %ebx
f0104f66:	5e                   	pop    %esi
f0104f67:	5f                   	pop    %edi
f0104f68:	5d                   	pop    %ebp
f0104f69:	c3                   	ret    

f0104f6a <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0104f6a:	55                   	push   %ebp
f0104f6b:	89 e5                	mov    %esp,%ebp
f0104f6d:	57                   	push   %edi
f0104f6e:	56                   	push   %esi
f0104f6f:	53                   	push   %ebx
f0104f70:	83 ec 1c             	sub    $0x1c,%esp
f0104f73:	89 c7                	mov    %eax,%edi
f0104f75:	89 d6                	mov    %edx,%esi
f0104f77:	8b 45 08             	mov    0x8(%ebp),%eax
f0104f7a:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104f7d:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104f80:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0104f83:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104f86:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104f8b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104f8e:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0104f91:	3b 45 10             	cmp    0x10(%ebp),%eax
f0104f94:	89 d0                	mov    %edx,%eax
f0104f96:	1b 45 e4             	sbb    -0x1c(%ebp),%eax
f0104f99:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0104f9c:	73 15                	jae    f0104fb3 <printnum+0x49>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0104f9e:	83 eb 01             	sub    $0x1,%ebx
f0104fa1:	85 db                	test   %ebx,%ebx
f0104fa3:	7e 43                	jle    f0104fe8 <printnum+0x7e>
			putch(padc, putdat);
f0104fa5:	83 ec 08             	sub    $0x8,%esp
f0104fa8:	56                   	push   %esi
f0104fa9:	ff 75 18             	pushl  0x18(%ebp)
f0104fac:	ff d7                	call   *%edi
f0104fae:	83 c4 10             	add    $0x10,%esp
f0104fb1:	eb eb                	jmp    f0104f9e <printnum+0x34>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0104fb3:	83 ec 0c             	sub    $0xc,%esp
f0104fb6:	ff 75 18             	pushl  0x18(%ebp)
f0104fb9:	8b 45 14             	mov    0x14(%ebp),%eax
f0104fbc:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0104fbf:	53                   	push   %ebx
f0104fc0:	ff 75 10             	pushl  0x10(%ebp)
f0104fc3:	83 ec 08             	sub    $0x8,%esp
f0104fc6:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104fc9:	ff 75 e0             	pushl  -0x20(%ebp)
f0104fcc:	ff 75 dc             	pushl  -0x24(%ebp)
f0104fcf:	ff 75 d8             	pushl  -0x28(%ebp)
f0104fd2:	e8 79 11 00 00       	call   f0106150 <__udivdi3>
f0104fd7:	83 c4 18             	add    $0x18,%esp
f0104fda:	52                   	push   %edx
f0104fdb:	50                   	push   %eax
f0104fdc:	89 f2                	mov    %esi,%edx
f0104fde:	89 f8                	mov    %edi,%eax
f0104fe0:	e8 85 ff ff ff       	call   f0104f6a <printnum>
f0104fe5:	83 c4 20             	add    $0x20,%esp
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0104fe8:	83 ec 08             	sub    $0x8,%esp
f0104feb:	56                   	push   %esi
f0104fec:	83 ec 04             	sub    $0x4,%esp
f0104fef:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104ff2:	ff 75 e0             	pushl  -0x20(%ebp)
f0104ff5:	ff 75 dc             	pushl  -0x24(%ebp)
f0104ff8:	ff 75 d8             	pushl  -0x28(%ebp)
f0104ffb:	e8 60 12 00 00       	call   f0106260 <__umoddi3>
f0105000:	83 c4 14             	add    $0x14,%esp
f0105003:	0f be 80 fa 7b 10 f0 	movsbl -0xfef8406(%eax),%eax
f010500a:	50                   	push   %eax
f010500b:	ff d7                	call   *%edi
}
f010500d:	83 c4 10             	add    $0x10,%esp
f0105010:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105013:	5b                   	pop    %ebx
f0105014:	5e                   	pop    %esi
f0105015:	5f                   	pop    %edi
f0105016:	5d                   	pop    %ebp
f0105017:	c3                   	ret    

f0105018 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0105018:	55                   	push   %ebp
f0105019:	89 e5                	mov    %esp,%ebp
f010501b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f010501e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0105022:	8b 10                	mov    (%eax),%edx
f0105024:	3b 50 04             	cmp    0x4(%eax),%edx
f0105027:	73 0a                	jae    f0105033 <sprintputch+0x1b>
		*b->buf++ = ch;
f0105029:	8d 4a 01             	lea    0x1(%edx),%ecx
f010502c:	89 08                	mov    %ecx,(%eax)
f010502e:	8b 45 08             	mov    0x8(%ebp),%eax
f0105031:	88 02                	mov    %al,(%edx)
}
f0105033:	5d                   	pop    %ebp
f0105034:	c3                   	ret    

f0105035 <printfmt>:
{
f0105035:	55                   	push   %ebp
f0105036:	89 e5                	mov    %esp,%ebp
f0105038:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f010503b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f010503e:	50                   	push   %eax
f010503f:	ff 75 10             	pushl  0x10(%ebp)
f0105042:	ff 75 0c             	pushl  0xc(%ebp)
f0105045:	ff 75 08             	pushl  0x8(%ebp)
f0105048:	e8 05 00 00 00       	call   f0105052 <vprintfmt>
}
f010504d:	83 c4 10             	add    $0x10,%esp
f0105050:	c9                   	leave  
f0105051:	c3                   	ret    

f0105052 <vprintfmt>:
{
f0105052:	55                   	push   %ebp
f0105053:	89 e5                	mov    %esp,%ebp
f0105055:	57                   	push   %edi
f0105056:	56                   	push   %esi
f0105057:	53                   	push   %ebx
f0105058:	83 ec 3c             	sub    $0x3c,%esp
f010505b:	8b 75 08             	mov    0x8(%ebp),%esi
f010505e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105061:	8b 7d 10             	mov    0x10(%ebp),%edi
f0105064:	eb 0a                	jmp    f0105070 <vprintfmt+0x1e>
			putch(ch, putdat);
f0105066:	83 ec 08             	sub    $0x8,%esp
f0105069:	53                   	push   %ebx
f010506a:	50                   	push   %eax
f010506b:	ff d6                	call   *%esi
f010506d:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0105070:	83 c7 01             	add    $0x1,%edi
f0105073:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0105077:	83 f8 25             	cmp    $0x25,%eax
f010507a:	74 0c                	je     f0105088 <vprintfmt+0x36>
			if (ch == '\0')
f010507c:	85 c0                	test   %eax,%eax
f010507e:	75 e6                	jne    f0105066 <vprintfmt+0x14>
}
f0105080:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105083:	5b                   	pop    %ebx
f0105084:	5e                   	pop    %esi
f0105085:	5f                   	pop    %edi
f0105086:	5d                   	pop    %ebp
f0105087:	c3                   	ret    
		padc = ' ';
f0105088:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
f010508c:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;//精度
f0105093:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;//总宽度
f010509a:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f01050a1:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f01050a6:	8d 47 01             	lea    0x1(%edi),%eax
f01050a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01050ac:	0f b6 17             	movzbl (%edi),%edx
f01050af:	8d 42 dd             	lea    -0x23(%edx),%eax
f01050b2:	3c 55                	cmp    $0x55,%al
f01050b4:	0f 87 ba 03 00 00    	ja     f0105474 <vprintfmt+0x422>
f01050ba:	0f b6 c0             	movzbl %al,%eax
f01050bd:	ff 24 85 c0 7c 10 f0 	jmp    *-0xfef8340(,%eax,4)
f01050c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
f01050c7:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
f01050cb:	eb d9                	jmp    f01050a6 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
f01050cd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
f01050d0:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
f01050d4:	eb d0                	jmp    f01050a6 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
f01050d6:	0f b6 d2             	movzbl %dl,%edx
f01050d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {//依次读取数据宽度
f01050dc:	b8 00 00 00 00       	mov    $0x0,%eax
f01050e1:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
f01050e4:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01050e7:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f01050eb:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f01050ee:	8d 4a d0             	lea    -0x30(%edx),%ecx
f01050f1:	83 f9 09             	cmp    $0x9,%ecx
f01050f4:	77 55                	ja     f010514b <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {//依次读取数据宽度
f01050f6:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
f01050f9:	eb e9                	jmp    f01050e4 <vprintfmt+0x92>
			precision = va_arg(ap, int);
f01050fb:	8b 45 14             	mov    0x14(%ebp),%eax
f01050fe:	8b 00                	mov    (%eax),%eax
f0105100:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105103:	8b 45 14             	mov    0x14(%ebp),%eax
f0105106:	8d 40 04             	lea    0x4(%eax),%eax
f0105109:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f010510c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
f010510f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0105113:	79 91                	jns    f01050a6 <vprintfmt+0x54>
				width = precision, precision = -1;
f0105115:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0105118:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010511b:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
f0105122:	eb 82                	jmp    f01050a6 <vprintfmt+0x54>
f0105124:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105127:	85 c0                	test   %eax,%eax
f0105129:	ba 00 00 00 00       	mov    $0x0,%edx
f010512e:	0f 49 d0             	cmovns %eax,%edx
f0105131:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0105134:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105137:	e9 6a ff ff ff       	jmp    f01050a6 <vprintfmt+0x54>
f010513c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
f010513f:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
f0105146:	e9 5b ff ff ff       	jmp    f01050a6 <vprintfmt+0x54>
f010514b:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f010514e:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105151:	eb bc                	jmp    f010510f <vprintfmt+0xbd>
			lflag++;
f0105153:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f0105156:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f0105159:	e9 48 ff ff ff       	jmp    f01050a6 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
f010515e:	8b 45 14             	mov    0x14(%ebp),%eax
f0105161:	8d 78 04             	lea    0x4(%eax),%edi
f0105164:	83 ec 08             	sub    $0x8,%esp
f0105167:	53                   	push   %ebx
f0105168:	ff 30                	pushl  (%eax)
f010516a:	ff d6                	call   *%esi
			break;
f010516c:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f010516f:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
f0105172:	e9 9c 02 00 00       	jmp    f0105413 <vprintfmt+0x3c1>
			err = va_arg(ap, int);
f0105177:	8b 45 14             	mov    0x14(%ebp),%eax
f010517a:	8d 78 04             	lea    0x4(%eax),%edi
f010517d:	8b 00                	mov    (%eax),%eax
f010517f:	99                   	cltd   
f0105180:	31 d0                	xor    %edx,%eax
f0105182:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0105184:	83 f8 08             	cmp    $0x8,%eax
f0105187:	7f 23                	jg     f01051ac <vprintfmt+0x15a>
f0105189:	8b 14 85 20 7e 10 f0 	mov    -0xfef81e0(,%eax,4),%edx
f0105190:	85 d2                	test   %edx,%edx
f0105192:	74 18                	je     f01051ac <vprintfmt+0x15a>
				printfmt(putch, putdat, "%s", p);
f0105194:	52                   	push   %edx
f0105195:	68 d0 69 10 f0       	push   $0xf01069d0
f010519a:	53                   	push   %ebx
f010519b:	56                   	push   %esi
f010519c:	e8 94 fe ff ff       	call   f0105035 <printfmt>
f01051a1:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f01051a4:	89 7d 14             	mov    %edi,0x14(%ebp)
f01051a7:	e9 67 02 00 00       	jmp    f0105413 <vprintfmt+0x3c1>
				printfmt(putch, putdat, "error %d", err);
f01051ac:	50                   	push   %eax
f01051ad:	68 12 7c 10 f0       	push   $0xf0107c12
f01051b2:	53                   	push   %ebx
f01051b3:	56                   	push   %esi
f01051b4:	e8 7c fe ff ff       	call   f0105035 <printfmt>
f01051b9:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f01051bc:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f01051bf:	e9 4f 02 00 00       	jmp    f0105413 <vprintfmt+0x3c1>
			if ((p = va_arg(ap, char *)) == NULL)
f01051c4:	8b 45 14             	mov    0x14(%ebp),%eax
f01051c7:	83 c0 04             	add    $0x4,%eax
f01051ca:	89 45 c8             	mov    %eax,-0x38(%ebp)
f01051cd:	8b 45 14             	mov    0x14(%ebp),%eax
f01051d0:	8b 10                	mov    (%eax),%edx
				p = "(null)";
f01051d2:	85 d2                	test   %edx,%edx
f01051d4:	b8 0b 7c 10 f0       	mov    $0xf0107c0b,%eax
f01051d9:	0f 45 c2             	cmovne %edx,%eax
f01051dc:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
f01051df:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01051e3:	7e 06                	jle    f01051eb <vprintfmt+0x199>
f01051e5:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
f01051e9:	75 0d                	jne    f01051f8 <vprintfmt+0x1a6>
				for (width -= strnlen(p, precision); width > 0; width--)
f01051eb:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01051ee:	89 c7                	mov    %eax,%edi
f01051f0:	03 45 e0             	add    -0x20(%ebp),%eax
f01051f3:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01051f6:	eb 3f                	jmp    f0105237 <vprintfmt+0x1e5>
f01051f8:	83 ec 08             	sub    $0x8,%esp
f01051fb:	ff 75 d8             	pushl  -0x28(%ebp)
f01051fe:	50                   	push   %eax
f01051ff:	e8 ef 03 00 00       	call   f01055f3 <strnlen>
f0105204:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0105207:	29 c2                	sub    %eax,%edx
f0105209:	89 55 c4             	mov    %edx,-0x3c(%ebp)
f010520c:	83 c4 10             	add    $0x10,%esp
f010520f:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
f0105211:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
f0105215:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f0105218:	85 ff                	test   %edi,%edi
f010521a:	7e 58                	jle    f0105274 <vprintfmt+0x222>
					putch(padc, putdat);
f010521c:	83 ec 08             	sub    $0x8,%esp
f010521f:	53                   	push   %ebx
f0105220:	ff 75 e0             	pushl  -0x20(%ebp)
f0105223:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f0105225:	83 ef 01             	sub    $0x1,%edi
f0105228:	83 c4 10             	add    $0x10,%esp
f010522b:	eb eb                	jmp    f0105218 <vprintfmt+0x1c6>
					putch(ch, putdat);
f010522d:	83 ec 08             	sub    $0x8,%esp
f0105230:	53                   	push   %ebx
f0105231:	52                   	push   %edx
f0105232:	ff d6                	call   *%esi
f0105234:	83 c4 10             	add    $0x10,%esp
f0105237:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f010523a:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010523c:	83 c7 01             	add    $0x1,%edi
f010523f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0105243:	0f be d0             	movsbl %al,%edx
f0105246:	85 d2                	test   %edx,%edx
f0105248:	74 45                	je     f010528f <vprintfmt+0x23d>
f010524a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f010524e:	78 06                	js     f0105256 <vprintfmt+0x204>
f0105250:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
f0105254:	78 35                	js     f010528b <vprintfmt+0x239>
				if (altflag && (ch < ' ' || ch > '~'))
f0105256:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f010525a:	74 d1                	je     f010522d <vprintfmt+0x1db>
f010525c:	0f be c0             	movsbl %al,%eax
f010525f:	83 e8 20             	sub    $0x20,%eax
f0105262:	83 f8 5e             	cmp    $0x5e,%eax
f0105265:	76 c6                	jbe    f010522d <vprintfmt+0x1db>
					putch('?', putdat);
f0105267:	83 ec 08             	sub    $0x8,%esp
f010526a:	53                   	push   %ebx
f010526b:	6a 3f                	push   $0x3f
f010526d:	ff d6                	call   *%esi
f010526f:	83 c4 10             	add    $0x10,%esp
f0105272:	eb c3                	jmp    f0105237 <vprintfmt+0x1e5>
f0105274:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0105277:	85 d2                	test   %edx,%edx
f0105279:	b8 00 00 00 00       	mov    $0x0,%eax
f010527e:	0f 49 c2             	cmovns %edx,%eax
f0105281:	29 c2                	sub    %eax,%edx
f0105283:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0105286:	e9 60 ff ff ff       	jmp    f01051eb <vprintfmt+0x199>
f010528b:	89 cf                	mov    %ecx,%edi
f010528d:	eb 02                	jmp    f0105291 <vprintfmt+0x23f>
f010528f:	89 cf                	mov    %ecx,%edi
			for (; width > 0; width--)
f0105291:	85 ff                	test   %edi,%edi
f0105293:	7e 10                	jle    f01052a5 <vprintfmt+0x253>
				putch(' ', putdat);
f0105295:	83 ec 08             	sub    $0x8,%esp
f0105298:	53                   	push   %ebx
f0105299:	6a 20                	push   $0x20
f010529b:	ff d6                	call   *%esi
			for (; width > 0; width--)
f010529d:	83 ef 01             	sub    $0x1,%edi
f01052a0:	83 c4 10             	add    $0x10,%esp
f01052a3:	eb ec                	jmp    f0105291 <vprintfmt+0x23f>
			if ((p = va_arg(ap, char *)) == NULL)
f01052a5:	8b 45 c8             	mov    -0x38(%ebp),%eax
f01052a8:	89 45 14             	mov    %eax,0x14(%ebp)
f01052ab:	e9 63 01 00 00       	jmp    f0105413 <vprintfmt+0x3c1>
	if (lflag >= 2)
f01052b0:	83 f9 01             	cmp    $0x1,%ecx
f01052b3:	7f 1b                	jg     f01052d0 <vprintfmt+0x27e>
	else if (lflag)
f01052b5:	85 c9                	test   %ecx,%ecx
f01052b7:	74 63                	je     f010531c <vprintfmt+0x2ca>
		return va_arg(*ap, long);
f01052b9:	8b 45 14             	mov    0x14(%ebp),%eax
f01052bc:	8b 00                	mov    (%eax),%eax
f01052be:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01052c1:	99                   	cltd   
f01052c2:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01052c5:	8b 45 14             	mov    0x14(%ebp),%eax
f01052c8:	8d 40 04             	lea    0x4(%eax),%eax
f01052cb:	89 45 14             	mov    %eax,0x14(%ebp)
f01052ce:	eb 17                	jmp    f01052e7 <vprintfmt+0x295>
		return va_arg(*ap, long long);
f01052d0:	8b 45 14             	mov    0x14(%ebp),%eax
f01052d3:	8b 50 04             	mov    0x4(%eax),%edx
f01052d6:	8b 00                	mov    (%eax),%eax
f01052d8:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01052db:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01052de:	8b 45 14             	mov    0x14(%ebp),%eax
f01052e1:	8d 40 08             	lea    0x8(%eax),%eax
f01052e4:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f01052e7:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01052ea:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f01052ed:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
f01052f2:	85 c9                	test   %ecx,%ecx
f01052f4:	0f 89 ff 00 00 00    	jns    f01053f9 <vprintfmt+0x3a7>
				putch('-', putdat);
f01052fa:	83 ec 08             	sub    $0x8,%esp
f01052fd:	53                   	push   %ebx
f01052fe:	6a 2d                	push   $0x2d
f0105300:	ff d6                	call   *%esi
				num = -(long long) num;
f0105302:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0105305:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0105308:	f7 da                	neg    %edx
f010530a:	83 d1 00             	adc    $0x0,%ecx
f010530d:	f7 d9                	neg    %ecx
f010530f:	83 c4 10             	add    $0x10,%esp
			base = 10;
f0105312:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105317:	e9 dd 00 00 00       	jmp    f01053f9 <vprintfmt+0x3a7>
		return va_arg(*ap, int);
f010531c:	8b 45 14             	mov    0x14(%ebp),%eax
f010531f:	8b 00                	mov    (%eax),%eax
f0105321:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105324:	99                   	cltd   
f0105325:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0105328:	8b 45 14             	mov    0x14(%ebp),%eax
f010532b:	8d 40 04             	lea    0x4(%eax),%eax
f010532e:	89 45 14             	mov    %eax,0x14(%ebp)
f0105331:	eb b4                	jmp    f01052e7 <vprintfmt+0x295>
	if (lflag >= 2)
f0105333:	83 f9 01             	cmp    $0x1,%ecx
f0105336:	7f 1e                	jg     f0105356 <vprintfmt+0x304>
	else if (lflag)
f0105338:	85 c9                	test   %ecx,%ecx
f010533a:	74 32                	je     f010536e <vprintfmt+0x31c>
		return va_arg(*ap, unsigned long);
f010533c:	8b 45 14             	mov    0x14(%ebp),%eax
f010533f:	8b 10                	mov    (%eax),%edx
f0105341:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105346:	8d 40 04             	lea    0x4(%eax),%eax
f0105349:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f010534c:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105351:	e9 a3 00 00 00       	jmp    f01053f9 <vprintfmt+0x3a7>
		return va_arg(*ap, unsigned long long);
f0105356:	8b 45 14             	mov    0x14(%ebp),%eax
f0105359:	8b 10                	mov    (%eax),%edx
f010535b:	8b 48 04             	mov    0x4(%eax),%ecx
f010535e:	8d 40 08             	lea    0x8(%eax),%eax
f0105361:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0105364:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105369:	e9 8b 00 00 00       	jmp    f01053f9 <vprintfmt+0x3a7>
		return va_arg(*ap, unsigned int);
f010536e:	8b 45 14             	mov    0x14(%ebp),%eax
f0105371:	8b 10                	mov    (%eax),%edx
f0105373:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105378:	8d 40 04             	lea    0x4(%eax),%eax
f010537b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f010537e:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105383:	eb 74                	jmp    f01053f9 <vprintfmt+0x3a7>
	if (lflag >= 2)
f0105385:	83 f9 01             	cmp    $0x1,%ecx
f0105388:	7f 1b                	jg     f01053a5 <vprintfmt+0x353>
	else if (lflag)
f010538a:	85 c9                	test   %ecx,%ecx
f010538c:	74 2c                	je     f01053ba <vprintfmt+0x368>
		return va_arg(*ap, unsigned long);
f010538e:	8b 45 14             	mov    0x14(%ebp),%eax
f0105391:	8b 10                	mov    (%eax),%edx
f0105393:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105398:	8d 40 04             	lea    0x4(%eax),%eax
f010539b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f010539e:	b8 08 00 00 00       	mov    $0x8,%eax
f01053a3:	eb 54                	jmp    f01053f9 <vprintfmt+0x3a7>
		return va_arg(*ap, unsigned long long);
f01053a5:	8b 45 14             	mov    0x14(%ebp),%eax
f01053a8:	8b 10                	mov    (%eax),%edx
f01053aa:	8b 48 04             	mov    0x4(%eax),%ecx
f01053ad:	8d 40 08             	lea    0x8(%eax),%eax
f01053b0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f01053b3:	b8 08 00 00 00       	mov    $0x8,%eax
f01053b8:	eb 3f                	jmp    f01053f9 <vprintfmt+0x3a7>
		return va_arg(*ap, unsigned int);
f01053ba:	8b 45 14             	mov    0x14(%ebp),%eax
f01053bd:	8b 10                	mov    (%eax),%edx
f01053bf:	b9 00 00 00 00       	mov    $0x0,%ecx
f01053c4:	8d 40 04             	lea    0x4(%eax),%eax
f01053c7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f01053ca:	b8 08 00 00 00       	mov    $0x8,%eax
f01053cf:	eb 28                	jmp    f01053f9 <vprintfmt+0x3a7>
			putch('0', putdat);
f01053d1:	83 ec 08             	sub    $0x8,%esp
f01053d4:	53                   	push   %ebx
f01053d5:	6a 30                	push   $0x30
f01053d7:	ff d6                	call   *%esi
			putch('x', putdat);
f01053d9:	83 c4 08             	add    $0x8,%esp
f01053dc:	53                   	push   %ebx
f01053dd:	6a 78                	push   $0x78
f01053df:	ff d6                	call   *%esi
			num = (unsigned long long)
f01053e1:	8b 45 14             	mov    0x14(%ebp),%eax
f01053e4:	8b 10                	mov    (%eax),%edx
f01053e6:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f01053eb:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f01053ee:	8d 40 04             	lea    0x4(%eax),%eax
f01053f1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01053f4:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
f01053f9:	83 ec 0c             	sub    $0xc,%esp
f01053fc:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
f0105400:	57                   	push   %edi
f0105401:	ff 75 e0             	pushl  -0x20(%ebp)
f0105404:	50                   	push   %eax
f0105405:	51                   	push   %ecx
f0105406:	52                   	push   %edx
f0105407:	89 da                	mov    %ebx,%edx
f0105409:	89 f0                	mov    %esi,%eax
f010540b:	e8 5a fb ff ff       	call   f0104f6a <printnum>
			break;
f0105410:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
f0105413:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0105416:	e9 55 fc ff ff       	jmp    f0105070 <vprintfmt+0x1e>
	if (lflag >= 2)
f010541b:	83 f9 01             	cmp    $0x1,%ecx
f010541e:	7f 1b                	jg     f010543b <vprintfmt+0x3e9>
	else if (lflag)
f0105420:	85 c9                	test   %ecx,%ecx
f0105422:	74 2c                	je     f0105450 <vprintfmt+0x3fe>
		return va_arg(*ap, unsigned long);
f0105424:	8b 45 14             	mov    0x14(%ebp),%eax
f0105427:	8b 10                	mov    (%eax),%edx
f0105429:	b9 00 00 00 00       	mov    $0x0,%ecx
f010542e:	8d 40 04             	lea    0x4(%eax),%eax
f0105431:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0105434:	b8 10 00 00 00       	mov    $0x10,%eax
f0105439:	eb be                	jmp    f01053f9 <vprintfmt+0x3a7>
		return va_arg(*ap, unsigned long long);
f010543b:	8b 45 14             	mov    0x14(%ebp),%eax
f010543e:	8b 10                	mov    (%eax),%edx
f0105440:	8b 48 04             	mov    0x4(%eax),%ecx
f0105443:	8d 40 08             	lea    0x8(%eax),%eax
f0105446:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0105449:	b8 10 00 00 00       	mov    $0x10,%eax
f010544e:	eb a9                	jmp    f01053f9 <vprintfmt+0x3a7>
		return va_arg(*ap, unsigned int);
f0105450:	8b 45 14             	mov    0x14(%ebp),%eax
f0105453:	8b 10                	mov    (%eax),%edx
f0105455:	b9 00 00 00 00       	mov    $0x0,%ecx
f010545a:	8d 40 04             	lea    0x4(%eax),%eax
f010545d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0105460:	b8 10 00 00 00       	mov    $0x10,%eax
f0105465:	eb 92                	jmp    f01053f9 <vprintfmt+0x3a7>
			putch(ch, putdat);
f0105467:	83 ec 08             	sub    $0x8,%esp
f010546a:	53                   	push   %ebx
f010546b:	6a 25                	push   $0x25
f010546d:	ff d6                	call   *%esi
			break;
f010546f:	83 c4 10             	add    $0x10,%esp
f0105472:	eb 9f                	jmp    f0105413 <vprintfmt+0x3c1>
			putch('%', putdat);
f0105474:	83 ec 08             	sub    $0x8,%esp
f0105477:	53                   	push   %ebx
f0105478:	6a 25                	push   $0x25
f010547a:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f010547c:	83 c4 10             	add    $0x10,%esp
f010547f:	89 f8                	mov    %edi,%eax
f0105481:	eb 03                	jmp    f0105486 <vprintfmt+0x434>
f0105483:	83 e8 01             	sub    $0x1,%eax
f0105486:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f010548a:	75 f7                	jne    f0105483 <vprintfmt+0x431>
f010548c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010548f:	eb 82                	jmp    f0105413 <vprintfmt+0x3c1>

f0105491 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0105491:	55                   	push   %ebp
f0105492:	89 e5                	mov    %esp,%ebp
f0105494:	83 ec 18             	sub    $0x18,%esp
f0105497:	8b 45 08             	mov    0x8(%ebp),%eax
f010549a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f010549d:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01054a0:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01054a4:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01054a7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01054ae:	85 c0                	test   %eax,%eax
f01054b0:	74 26                	je     f01054d8 <vsnprintf+0x47>
f01054b2:	85 d2                	test   %edx,%edx
f01054b4:	7e 22                	jle    f01054d8 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01054b6:	ff 75 14             	pushl  0x14(%ebp)
f01054b9:	ff 75 10             	pushl  0x10(%ebp)
f01054bc:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01054bf:	50                   	push   %eax
f01054c0:	68 18 50 10 f0       	push   $0xf0105018
f01054c5:	e8 88 fb ff ff       	call   f0105052 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01054ca:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01054cd:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01054d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01054d3:	83 c4 10             	add    $0x10,%esp
}
f01054d6:	c9                   	leave  
f01054d7:	c3                   	ret    
		return -E_INVAL;
f01054d8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01054dd:	eb f7                	jmp    f01054d6 <vsnprintf+0x45>

f01054df <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01054df:	55                   	push   %ebp
f01054e0:	89 e5                	mov    %esp,%ebp
f01054e2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01054e5:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01054e8:	50                   	push   %eax
f01054e9:	ff 75 10             	pushl  0x10(%ebp)
f01054ec:	ff 75 0c             	pushl  0xc(%ebp)
f01054ef:	ff 75 08             	pushl  0x8(%ebp)
f01054f2:	e8 9a ff ff ff       	call   f0105491 <vsnprintf>
	va_end(ap);

	return rc;
}
f01054f7:	c9                   	leave  
f01054f8:	c3                   	ret    

f01054f9 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01054f9:	55                   	push   %ebp
f01054fa:	89 e5                	mov    %esp,%ebp
f01054fc:	57                   	push   %edi
f01054fd:	56                   	push   %esi
f01054fe:	53                   	push   %ebx
f01054ff:	83 ec 0c             	sub    $0xc,%esp
f0105502:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0105505:	85 c0                	test   %eax,%eax
f0105507:	74 11                	je     f010551a <readline+0x21>
		cprintf("%s", prompt);
f0105509:	83 ec 08             	sub    $0x8,%esp
f010550c:	50                   	push   %eax
f010550d:	68 d0 69 10 f0       	push   $0xf01069d0
f0105512:	e8 e5 e3 ff ff       	call   f01038fc <cprintf>
f0105517:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f010551a:	83 ec 0c             	sub    $0xc,%esp
f010551d:	6a 00                	push   $0x0
f010551f:	e8 ab b2 ff ff       	call   f01007cf <iscons>
f0105524:	89 c7                	mov    %eax,%edi
f0105526:	83 c4 10             	add    $0x10,%esp
	i = 0;
f0105529:	be 00 00 00 00       	mov    $0x0,%esi
f010552e:	eb 4b                	jmp    f010557b <readline+0x82>
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
f0105530:	83 ec 08             	sub    $0x8,%esp
f0105533:	50                   	push   %eax
f0105534:	68 44 7e 10 f0       	push   $0xf0107e44
f0105539:	e8 be e3 ff ff       	call   f01038fc <cprintf>
			return NULL;
f010553e:	83 c4 10             	add    $0x10,%esp
f0105541:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f0105546:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105549:	5b                   	pop    %ebx
f010554a:	5e                   	pop    %esi
f010554b:	5f                   	pop    %edi
f010554c:	5d                   	pop    %ebp
f010554d:	c3                   	ret    
			if (echoing)
f010554e:	85 ff                	test   %edi,%edi
f0105550:	75 05                	jne    f0105557 <readline+0x5e>
			i--;
f0105552:	83 ee 01             	sub    $0x1,%esi
f0105555:	eb 24                	jmp    f010557b <readline+0x82>
				cputchar('\b');
f0105557:	83 ec 0c             	sub    $0xc,%esp
f010555a:	6a 08                	push   $0x8
f010555c:	e8 4d b2 ff ff       	call   f01007ae <cputchar>
f0105561:	83 c4 10             	add    $0x10,%esp
f0105564:	eb ec                	jmp    f0105552 <readline+0x59>
				cputchar(c);
f0105566:	83 ec 0c             	sub    $0xc,%esp
f0105569:	53                   	push   %ebx
f010556a:	e8 3f b2 ff ff       	call   f01007ae <cputchar>
f010556f:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0105572:	88 9e 80 7a 23 f0    	mov    %bl,-0xfdc8580(%esi)
f0105578:	8d 76 01             	lea    0x1(%esi),%esi
		c = getchar();
f010557b:	e8 3e b2 ff ff       	call   f01007be <getchar>
f0105580:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0105582:	85 c0                	test   %eax,%eax
f0105584:	78 aa                	js     f0105530 <readline+0x37>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0105586:	83 f8 08             	cmp    $0x8,%eax
f0105589:	0f 94 c2             	sete   %dl
f010558c:	83 f8 7f             	cmp    $0x7f,%eax
f010558f:	0f 94 c0             	sete   %al
f0105592:	08 c2                	or     %al,%dl
f0105594:	74 04                	je     f010559a <readline+0xa1>
f0105596:	85 f6                	test   %esi,%esi
f0105598:	7f b4                	jg     f010554e <readline+0x55>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010559a:	83 fb 1f             	cmp    $0x1f,%ebx
f010559d:	7e 0e                	jle    f01055ad <readline+0xb4>
f010559f:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f01055a5:	7f 06                	jg     f01055ad <readline+0xb4>
			if (echoing)
f01055a7:	85 ff                	test   %edi,%edi
f01055a9:	74 c7                	je     f0105572 <readline+0x79>
f01055ab:	eb b9                	jmp    f0105566 <readline+0x6d>
		} else if (c == '\n' || c == '\r') {
f01055ad:	83 fb 0a             	cmp    $0xa,%ebx
f01055b0:	74 05                	je     f01055b7 <readline+0xbe>
f01055b2:	83 fb 0d             	cmp    $0xd,%ebx
f01055b5:	75 c4                	jne    f010557b <readline+0x82>
			if (echoing)
f01055b7:	85 ff                	test   %edi,%edi
f01055b9:	75 11                	jne    f01055cc <readline+0xd3>
			buf[i] = 0;
f01055bb:	c6 86 80 7a 23 f0 00 	movb   $0x0,-0xfdc8580(%esi)
			return buf;
f01055c2:	b8 80 7a 23 f0       	mov    $0xf0237a80,%eax
f01055c7:	e9 7a ff ff ff       	jmp    f0105546 <readline+0x4d>
				cputchar('\n');
f01055cc:	83 ec 0c             	sub    $0xc,%esp
f01055cf:	6a 0a                	push   $0xa
f01055d1:	e8 d8 b1 ff ff       	call   f01007ae <cputchar>
f01055d6:	83 c4 10             	add    $0x10,%esp
f01055d9:	eb e0                	jmp    f01055bb <readline+0xc2>

f01055db <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01055db:	55                   	push   %ebp
f01055dc:	89 e5                	mov    %esp,%ebp
f01055de:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01055e1:	b8 00 00 00 00       	mov    $0x0,%eax
f01055e6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01055ea:	74 05                	je     f01055f1 <strlen+0x16>
		n++;
f01055ec:	83 c0 01             	add    $0x1,%eax
f01055ef:	eb f5                	jmp    f01055e6 <strlen+0xb>
	return n;
}
f01055f1:	5d                   	pop    %ebp
f01055f2:	c3                   	ret    

f01055f3 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01055f3:	55                   	push   %ebp
f01055f4:	89 e5                	mov    %esp,%ebp
f01055f6:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01055f9:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01055fc:	ba 00 00 00 00       	mov    $0x0,%edx
f0105601:	39 c2                	cmp    %eax,%edx
f0105603:	74 0d                	je     f0105612 <strnlen+0x1f>
f0105605:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f0105609:	74 05                	je     f0105610 <strnlen+0x1d>
		n++;
f010560b:	83 c2 01             	add    $0x1,%edx
f010560e:	eb f1                	jmp    f0105601 <strnlen+0xe>
f0105610:	89 d0                	mov    %edx,%eax
	return n;
}
f0105612:	5d                   	pop    %ebp
f0105613:	c3                   	ret    

f0105614 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0105614:	55                   	push   %ebp
f0105615:	89 e5                	mov    %esp,%ebp
f0105617:	53                   	push   %ebx
f0105618:	8b 45 08             	mov    0x8(%ebp),%eax
f010561b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f010561e:	ba 00 00 00 00       	mov    $0x0,%edx
f0105623:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f0105627:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f010562a:	83 c2 01             	add    $0x1,%edx
f010562d:	84 c9                	test   %cl,%cl
f010562f:	75 f2                	jne    f0105623 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0105631:	5b                   	pop    %ebx
f0105632:	5d                   	pop    %ebp
f0105633:	c3                   	ret    

f0105634 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0105634:	55                   	push   %ebp
f0105635:	89 e5                	mov    %esp,%ebp
f0105637:	53                   	push   %ebx
f0105638:	83 ec 10             	sub    $0x10,%esp
f010563b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f010563e:	53                   	push   %ebx
f010563f:	e8 97 ff ff ff       	call   f01055db <strlen>
f0105644:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
f0105647:	ff 75 0c             	pushl  0xc(%ebp)
f010564a:	01 d8                	add    %ebx,%eax
f010564c:	50                   	push   %eax
f010564d:	e8 c2 ff ff ff       	call   f0105614 <strcpy>
	return dst;
}
f0105652:	89 d8                	mov    %ebx,%eax
f0105654:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0105657:	c9                   	leave  
f0105658:	c3                   	ret    

f0105659 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0105659:	55                   	push   %ebp
f010565a:	89 e5                	mov    %esp,%ebp
f010565c:	56                   	push   %esi
f010565d:	53                   	push   %ebx
f010565e:	8b 45 08             	mov    0x8(%ebp),%eax
f0105661:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105664:	89 c6                	mov    %eax,%esi
f0105666:	03 75 10             	add    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105669:	89 c2                	mov    %eax,%edx
f010566b:	39 f2                	cmp    %esi,%edx
f010566d:	74 11                	je     f0105680 <strncpy+0x27>
		*dst++ = *src;
f010566f:	83 c2 01             	add    $0x1,%edx
f0105672:	0f b6 19             	movzbl (%ecx),%ebx
f0105675:	88 5a ff             	mov    %bl,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0105678:	80 fb 01             	cmp    $0x1,%bl
f010567b:	83 d9 ff             	sbb    $0xffffffff,%ecx
f010567e:	eb eb                	jmp    f010566b <strncpy+0x12>
	}
	return ret;
}
f0105680:	5b                   	pop    %ebx
f0105681:	5e                   	pop    %esi
f0105682:	5d                   	pop    %ebp
f0105683:	c3                   	ret    

f0105684 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0105684:	55                   	push   %ebp
f0105685:	89 e5                	mov    %esp,%ebp
f0105687:	56                   	push   %esi
f0105688:	53                   	push   %ebx
f0105689:	8b 75 08             	mov    0x8(%ebp),%esi
f010568c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010568f:	8b 55 10             	mov    0x10(%ebp),%edx
f0105692:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105694:	85 d2                	test   %edx,%edx
f0105696:	74 21                	je     f01056b9 <strlcpy+0x35>
f0105698:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f010569c:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
f010569e:	39 c2                	cmp    %eax,%edx
f01056a0:	74 14                	je     f01056b6 <strlcpy+0x32>
f01056a2:	0f b6 19             	movzbl (%ecx),%ebx
f01056a5:	84 db                	test   %bl,%bl
f01056a7:	74 0b                	je     f01056b4 <strlcpy+0x30>
			*dst++ = *src++;
f01056a9:	83 c1 01             	add    $0x1,%ecx
f01056ac:	83 c2 01             	add    $0x1,%edx
f01056af:	88 5a ff             	mov    %bl,-0x1(%edx)
f01056b2:	eb ea                	jmp    f010569e <strlcpy+0x1a>
f01056b4:	89 d0                	mov    %edx,%eax
		*dst = '\0';
f01056b6:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f01056b9:	29 f0                	sub    %esi,%eax
}
f01056bb:	5b                   	pop    %ebx
f01056bc:	5e                   	pop    %esi
f01056bd:	5d                   	pop    %ebp
f01056be:	c3                   	ret    

f01056bf <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01056bf:	55                   	push   %ebp
f01056c0:	89 e5                	mov    %esp,%ebp
f01056c2:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01056c5:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01056c8:	0f b6 01             	movzbl (%ecx),%eax
f01056cb:	84 c0                	test   %al,%al
f01056cd:	74 0c                	je     f01056db <strcmp+0x1c>
f01056cf:	3a 02                	cmp    (%edx),%al
f01056d1:	75 08                	jne    f01056db <strcmp+0x1c>
		p++, q++;
f01056d3:	83 c1 01             	add    $0x1,%ecx
f01056d6:	83 c2 01             	add    $0x1,%edx
f01056d9:	eb ed                	jmp    f01056c8 <strcmp+0x9>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01056db:	0f b6 c0             	movzbl %al,%eax
f01056de:	0f b6 12             	movzbl (%edx),%edx
f01056e1:	29 d0                	sub    %edx,%eax
}
f01056e3:	5d                   	pop    %ebp
f01056e4:	c3                   	ret    

f01056e5 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01056e5:	55                   	push   %ebp
f01056e6:	89 e5                	mov    %esp,%ebp
f01056e8:	53                   	push   %ebx
f01056e9:	8b 45 08             	mov    0x8(%ebp),%eax
f01056ec:	8b 55 0c             	mov    0xc(%ebp),%edx
f01056ef:	89 c3                	mov    %eax,%ebx
f01056f1:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f01056f4:	eb 06                	jmp    f01056fc <strncmp+0x17>
		n--, p++, q++;
f01056f6:	83 c0 01             	add    $0x1,%eax
f01056f9:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f01056fc:	39 d8                	cmp    %ebx,%eax
f01056fe:	74 16                	je     f0105716 <strncmp+0x31>
f0105700:	0f b6 08             	movzbl (%eax),%ecx
f0105703:	84 c9                	test   %cl,%cl
f0105705:	74 04                	je     f010570b <strncmp+0x26>
f0105707:	3a 0a                	cmp    (%edx),%cl
f0105709:	74 eb                	je     f01056f6 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f010570b:	0f b6 00             	movzbl (%eax),%eax
f010570e:	0f b6 12             	movzbl (%edx),%edx
f0105711:	29 d0                	sub    %edx,%eax
}
f0105713:	5b                   	pop    %ebx
f0105714:	5d                   	pop    %ebp
f0105715:	c3                   	ret    
		return 0;
f0105716:	b8 00 00 00 00       	mov    $0x0,%eax
f010571b:	eb f6                	jmp    f0105713 <strncmp+0x2e>

f010571d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010571d:	55                   	push   %ebp
f010571e:	89 e5                	mov    %esp,%ebp
f0105720:	8b 45 08             	mov    0x8(%ebp),%eax
f0105723:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105727:	0f b6 10             	movzbl (%eax),%edx
f010572a:	84 d2                	test   %dl,%dl
f010572c:	74 09                	je     f0105737 <strchr+0x1a>
		if (*s == c)
f010572e:	38 ca                	cmp    %cl,%dl
f0105730:	74 0a                	je     f010573c <strchr+0x1f>
	for (; *s; s++)
f0105732:	83 c0 01             	add    $0x1,%eax
f0105735:	eb f0                	jmp    f0105727 <strchr+0xa>
			return (char *) s;
	return 0;
f0105737:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010573c:	5d                   	pop    %ebp
f010573d:	c3                   	ret    

f010573e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010573e:	55                   	push   %ebp
f010573f:	89 e5                	mov    %esp,%ebp
f0105741:	8b 45 08             	mov    0x8(%ebp),%eax
f0105744:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105748:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f010574b:	38 ca                	cmp    %cl,%dl
f010574d:	74 09                	je     f0105758 <strfind+0x1a>
f010574f:	84 d2                	test   %dl,%dl
f0105751:	74 05                	je     f0105758 <strfind+0x1a>
	for (; *s; s++)
f0105753:	83 c0 01             	add    $0x1,%eax
f0105756:	eb f0                	jmp    f0105748 <strfind+0xa>
			break;
	return (char *) s;
}
f0105758:	5d                   	pop    %ebp
f0105759:	c3                   	ret    

f010575a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f010575a:	55                   	push   %ebp
f010575b:	89 e5                	mov    %esp,%ebp
f010575d:	57                   	push   %edi
f010575e:	56                   	push   %esi
f010575f:	53                   	push   %ebx
f0105760:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105763:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0105766:	85 c9                	test   %ecx,%ecx
f0105768:	74 31                	je     f010579b <memset+0x41>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f010576a:	89 f8                	mov    %edi,%eax
f010576c:	09 c8                	or     %ecx,%eax
f010576e:	a8 03                	test   $0x3,%al
f0105770:	75 23                	jne    f0105795 <memset+0x3b>
		c &= 0xFF;
f0105772:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0105776:	89 d3                	mov    %edx,%ebx
f0105778:	c1 e3 08             	shl    $0x8,%ebx
f010577b:	89 d0                	mov    %edx,%eax
f010577d:	c1 e0 18             	shl    $0x18,%eax
f0105780:	89 d6                	mov    %edx,%esi
f0105782:	c1 e6 10             	shl    $0x10,%esi
f0105785:	09 f0                	or     %esi,%eax
f0105787:	09 c2                	or     %eax,%edx
f0105789:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f010578b:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f010578e:	89 d0                	mov    %edx,%eax
f0105790:	fc                   	cld    
f0105791:	f3 ab                	rep stos %eax,%es:(%edi)
f0105793:	eb 06                	jmp    f010579b <memset+0x41>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0105795:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105798:	fc                   	cld    
f0105799:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010579b:	89 f8                	mov    %edi,%eax
f010579d:	5b                   	pop    %ebx
f010579e:	5e                   	pop    %esi
f010579f:	5f                   	pop    %edi
f01057a0:	5d                   	pop    %ebp
f01057a1:	c3                   	ret    

f01057a2 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01057a2:	55                   	push   %ebp
f01057a3:	89 e5                	mov    %esp,%ebp
f01057a5:	57                   	push   %edi
f01057a6:	56                   	push   %esi
f01057a7:	8b 45 08             	mov    0x8(%ebp),%eax
f01057aa:	8b 75 0c             	mov    0xc(%ebp),%esi
f01057ad:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01057b0:	39 c6                	cmp    %eax,%esi
f01057b2:	73 32                	jae    f01057e6 <memmove+0x44>
f01057b4:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01057b7:	39 c2                	cmp    %eax,%edx
f01057b9:	76 2b                	jbe    f01057e6 <memmove+0x44>
		s += n;
		d += n;
f01057bb:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01057be:	89 fe                	mov    %edi,%esi
f01057c0:	09 ce                	or     %ecx,%esi
f01057c2:	09 d6                	or     %edx,%esi
f01057c4:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01057ca:	75 0e                	jne    f01057da <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f01057cc:	83 ef 04             	sub    $0x4,%edi
f01057cf:	8d 72 fc             	lea    -0x4(%edx),%esi
f01057d2:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f01057d5:	fd                   	std    
f01057d6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01057d8:	eb 09                	jmp    f01057e3 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f01057da:	83 ef 01             	sub    $0x1,%edi
f01057dd:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f01057e0:	fd                   	std    
f01057e1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01057e3:	fc                   	cld    
f01057e4:	eb 1a                	jmp    f0105800 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01057e6:	89 c2                	mov    %eax,%edx
f01057e8:	09 ca                	or     %ecx,%edx
f01057ea:	09 f2                	or     %esi,%edx
f01057ec:	f6 c2 03             	test   $0x3,%dl
f01057ef:	75 0a                	jne    f01057fb <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f01057f1:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f01057f4:	89 c7                	mov    %eax,%edi
f01057f6:	fc                   	cld    
f01057f7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01057f9:	eb 05                	jmp    f0105800 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
f01057fb:	89 c7                	mov    %eax,%edi
f01057fd:	fc                   	cld    
f01057fe:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0105800:	5e                   	pop    %esi
f0105801:	5f                   	pop    %edi
f0105802:	5d                   	pop    %ebp
f0105803:	c3                   	ret    

f0105804 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0105804:	55                   	push   %ebp
f0105805:	89 e5                	mov    %esp,%ebp
f0105807:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f010580a:	ff 75 10             	pushl  0x10(%ebp)
f010580d:	ff 75 0c             	pushl  0xc(%ebp)
f0105810:	ff 75 08             	pushl  0x8(%ebp)
f0105813:	e8 8a ff ff ff       	call   f01057a2 <memmove>
}
f0105818:	c9                   	leave  
f0105819:	c3                   	ret    

f010581a <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f010581a:	55                   	push   %ebp
f010581b:	89 e5                	mov    %esp,%ebp
f010581d:	56                   	push   %esi
f010581e:	53                   	push   %ebx
f010581f:	8b 45 08             	mov    0x8(%ebp),%eax
f0105822:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105825:	89 c6                	mov    %eax,%esi
f0105827:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010582a:	39 f0                	cmp    %esi,%eax
f010582c:	74 1c                	je     f010584a <memcmp+0x30>
		if (*s1 != *s2)
f010582e:	0f b6 08             	movzbl (%eax),%ecx
f0105831:	0f b6 1a             	movzbl (%edx),%ebx
f0105834:	38 d9                	cmp    %bl,%cl
f0105836:	75 08                	jne    f0105840 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f0105838:	83 c0 01             	add    $0x1,%eax
f010583b:	83 c2 01             	add    $0x1,%edx
f010583e:	eb ea                	jmp    f010582a <memcmp+0x10>
			return (int) *s1 - (int) *s2;
f0105840:	0f b6 c1             	movzbl %cl,%eax
f0105843:	0f b6 db             	movzbl %bl,%ebx
f0105846:	29 d8                	sub    %ebx,%eax
f0105848:	eb 05                	jmp    f010584f <memcmp+0x35>
	}

	return 0;
f010584a:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010584f:	5b                   	pop    %ebx
f0105850:	5e                   	pop    %esi
f0105851:	5d                   	pop    %ebp
f0105852:	c3                   	ret    

f0105853 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0105853:	55                   	push   %ebp
f0105854:	89 e5                	mov    %esp,%ebp
f0105856:	8b 45 08             	mov    0x8(%ebp),%eax
f0105859:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f010585c:	89 c2                	mov    %eax,%edx
f010585e:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0105861:	39 d0                	cmp    %edx,%eax
f0105863:	73 09                	jae    f010586e <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
f0105865:	38 08                	cmp    %cl,(%eax)
f0105867:	74 05                	je     f010586e <memfind+0x1b>
	for (; s < ends; s++)
f0105869:	83 c0 01             	add    $0x1,%eax
f010586c:	eb f3                	jmp    f0105861 <memfind+0xe>
			break;
	return (void *) s;
}
f010586e:	5d                   	pop    %ebp
f010586f:	c3                   	ret    

f0105870 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0105870:	55                   	push   %ebp
f0105871:	89 e5                	mov    %esp,%ebp
f0105873:	57                   	push   %edi
f0105874:	56                   	push   %esi
f0105875:	53                   	push   %ebx
f0105876:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105879:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010587c:	eb 03                	jmp    f0105881 <strtol+0x11>
		s++;
f010587e:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
f0105881:	0f b6 01             	movzbl (%ecx),%eax
f0105884:	3c 20                	cmp    $0x20,%al
f0105886:	74 f6                	je     f010587e <strtol+0xe>
f0105888:	3c 09                	cmp    $0x9,%al
f010588a:	74 f2                	je     f010587e <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f010588c:	3c 2b                	cmp    $0x2b,%al
f010588e:	74 2a                	je     f01058ba <strtol+0x4a>
	int neg = 0;
f0105890:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f0105895:	3c 2d                	cmp    $0x2d,%al
f0105897:	74 2b                	je     f01058c4 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105899:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f010589f:	75 0f                	jne    f01058b0 <strtol+0x40>
f01058a1:	80 39 30             	cmpb   $0x30,(%ecx)
f01058a4:	74 28                	je     f01058ce <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01058a6:	85 db                	test   %ebx,%ebx
f01058a8:	b8 0a 00 00 00       	mov    $0xa,%eax
f01058ad:	0f 44 d8             	cmove  %eax,%ebx
f01058b0:	b8 00 00 00 00       	mov    $0x0,%eax
f01058b5:	89 5d 10             	mov    %ebx,0x10(%ebp)
f01058b8:	eb 50                	jmp    f010590a <strtol+0x9a>
		s++;
f01058ba:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
f01058bd:	bf 00 00 00 00       	mov    $0x0,%edi
f01058c2:	eb d5                	jmp    f0105899 <strtol+0x29>
		s++, neg = 1;
f01058c4:	83 c1 01             	add    $0x1,%ecx
f01058c7:	bf 01 00 00 00       	mov    $0x1,%edi
f01058cc:	eb cb                	jmp    f0105899 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01058ce:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f01058d2:	74 0e                	je     f01058e2 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
f01058d4:	85 db                	test   %ebx,%ebx
f01058d6:	75 d8                	jne    f01058b0 <strtol+0x40>
		s++, base = 8;
f01058d8:	83 c1 01             	add    $0x1,%ecx
f01058db:	bb 08 00 00 00       	mov    $0x8,%ebx
f01058e0:	eb ce                	jmp    f01058b0 <strtol+0x40>
		s += 2, base = 16;
f01058e2:	83 c1 02             	add    $0x2,%ecx
f01058e5:	bb 10 00 00 00       	mov    $0x10,%ebx
f01058ea:	eb c4                	jmp    f01058b0 <strtol+0x40>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
f01058ec:	8d 72 9f             	lea    -0x61(%edx),%esi
f01058ef:	89 f3                	mov    %esi,%ebx
f01058f1:	80 fb 19             	cmp    $0x19,%bl
f01058f4:	77 29                	ja     f010591f <strtol+0xaf>
			dig = *s - 'a' + 10;
f01058f6:	0f be d2             	movsbl %dl,%edx
f01058f9:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f01058fc:	3b 55 10             	cmp    0x10(%ebp),%edx
f01058ff:	7d 30                	jge    f0105931 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
f0105901:	83 c1 01             	add    $0x1,%ecx
f0105904:	0f af 45 10          	imul   0x10(%ebp),%eax
f0105908:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f010590a:	0f b6 11             	movzbl (%ecx),%edx
f010590d:	8d 72 d0             	lea    -0x30(%edx),%esi
f0105910:	89 f3                	mov    %esi,%ebx
f0105912:	80 fb 09             	cmp    $0x9,%bl
f0105915:	77 d5                	ja     f01058ec <strtol+0x7c>
			dig = *s - '0';
f0105917:	0f be d2             	movsbl %dl,%edx
f010591a:	83 ea 30             	sub    $0x30,%edx
f010591d:	eb dd                	jmp    f01058fc <strtol+0x8c>
		else if (*s >= 'A' && *s <= 'Z')
f010591f:	8d 72 bf             	lea    -0x41(%edx),%esi
f0105922:	89 f3                	mov    %esi,%ebx
f0105924:	80 fb 19             	cmp    $0x19,%bl
f0105927:	77 08                	ja     f0105931 <strtol+0xc1>
			dig = *s - 'A' + 10;
f0105929:	0f be d2             	movsbl %dl,%edx
f010592c:	83 ea 37             	sub    $0x37,%edx
f010592f:	eb cb                	jmp    f01058fc <strtol+0x8c>
		// we don't properly detect overflow!
	}

	if (endptr)
f0105931:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0105935:	74 05                	je     f010593c <strtol+0xcc>
		*endptr = (char *) s;
f0105937:	8b 75 0c             	mov    0xc(%ebp),%esi
f010593a:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f010593c:	89 c2                	mov    %eax,%edx
f010593e:	f7 da                	neg    %edx
f0105940:	85 ff                	test   %edi,%edi
f0105942:	0f 45 c2             	cmovne %edx,%eax
}
f0105945:	5b                   	pop    %ebx
f0105946:	5e                   	pop    %esi
f0105947:	5f                   	pop    %edi
f0105948:	5d                   	pop    %ebp
f0105949:	c3                   	ret    
f010594a:	66 90                	xchg   %ax,%ax

f010594c <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f010594c:	fa                   	cli    

	xorw    %ax, %ax
f010594d:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f010594f:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105951:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105953:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0105955:	0f 01 16             	lgdtl  (%esi)
f0105958:	74 70                	je     f01059ca <mpsearch1+0x3>
	movl    %cr0, %eax
f010595a:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f010595d:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0105961:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0105964:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f010596a:	08 00                	or     %al,(%eax)

f010596c <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f010596c:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0105970:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105972:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105974:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0105976:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f010597a:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f010597c:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f010597e:	b8 00 10 12 00       	mov    $0x121000,%eax
	movl    %eax, %cr3
f0105983:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0105986:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0105989:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f010598e:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0105991:	8b 25 84 7e 23 f0    	mov    0xf0237e84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0105997:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f010599c:	b8 01 02 10 f0       	mov    $0xf0100201,%eax
	call    *%eax
f01059a1:	ff d0                	call   *%eax

f01059a3 <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f01059a3:	eb fe                	jmp    f01059a3 <spin>
f01059a5:	8d 76 00             	lea    0x0(%esi),%esi

f01059a8 <gdt>:
	...
f01059b0:	ff                   	(bad)  
f01059b1:	ff 00                	incl   (%eax)
f01059b3:	00 00                	add    %al,(%eax)
f01059b5:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f01059bc:	00                   	.byte 0x0
f01059bd:	92                   	xchg   %eax,%edx
f01059be:	cf                   	iret   
	...

f01059c0 <gdtdesc>:
f01059c0:	17                   	pop    %ss
f01059c1:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f01059c6 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f01059c6:	90                   	nop

f01059c7 <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f01059c7:	55                   	push   %ebp
f01059c8:	89 e5                	mov    %esp,%ebp
f01059ca:	57                   	push   %edi
f01059cb:	56                   	push   %esi
f01059cc:	53                   	push   %ebx
f01059cd:	83 ec 0c             	sub    $0xc,%esp
	if (PGNUM(pa) >= npages)
f01059d0:	8b 0d 88 7e 23 f0    	mov    0xf0237e88,%ecx
f01059d6:	89 c3                	mov    %eax,%ebx
f01059d8:	c1 eb 0c             	shr    $0xc,%ebx
f01059db:	39 cb                	cmp    %ecx,%ebx
f01059dd:	73 1a                	jae    f01059f9 <mpsearch1+0x32>
	return (void *)(pa + KERNBASE);
f01059df:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f01059e5:	8d 3c 02             	lea    (%edx,%eax,1),%edi
	if (PGNUM(pa) >= npages)
f01059e8:	89 f8                	mov    %edi,%eax
f01059ea:	c1 e8 0c             	shr    $0xc,%eax
f01059ed:	39 c8                	cmp    %ecx,%eax
f01059ef:	73 1a                	jae    f0105a0b <mpsearch1+0x44>
	return (void *)(pa + KERNBASE);
f01059f1:	81 ef 00 00 00 10    	sub    $0x10000000,%edi

	for (; mp < end; mp++)
f01059f7:	eb 27                	jmp    f0105a20 <mpsearch1+0x59>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01059f9:	50                   	push   %eax
f01059fa:	68 54 64 10 f0       	push   $0xf0106454
f01059ff:	6a 57                	push   $0x57
f0105a01:	68 e1 7f 10 f0       	push   $0xf0107fe1
f0105a06:	e8 89 a6 ff ff       	call   f0100094 <_panic>
f0105a0b:	57                   	push   %edi
f0105a0c:	68 54 64 10 f0       	push   $0xf0106454
f0105a11:	6a 57                	push   $0x57
f0105a13:	68 e1 7f 10 f0       	push   $0xf0107fe1
f0105a18:	e8 77 a6 ff ff       	call   f0100094 <_panic>
f0105a1d:	83 c3 10             	add    $0x10,%ebx
f0105a20:	39 fb                	cmp    %edi,%ebx
f0105a22:	73 30                	jae    f0105a54 <mpsearch1+0x8d>
f0105a24:	89 de                	mov    %ebx,%esi
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105a26:	83 ec 04             	sub    $0x4,%esp
f0105a29:	6a 04                	push   $0x4
f0105a2b:	68 f1 7f 10 f0       	push   $0xf0107ff1
f0105a30:	53                   	push   %ebx
f0105a31:	e8 e4 fd ff ff       	call   f010581a <memcmp>
f0105a36:	83 c4 10             	add    $0x10,%esp
f0105a39:	85 c0                	test   %eax,%eax
f0105a3b:	75 e0                	jne    f0105a1d <mpsearch1+0x56>
f0105a3d:	89 da                	mov    %ebx,%edx
	for (i = 0; i < len; i++)
f0105a3f:	83 c6 10             	add    $0x10,%esi
		sum += ((uint8_t *)addr)[i];
f0105a42:	0f b6 0a             	movzbl (%edx),%ecx
f0105a45:	01 c8                	add    %ecx,%eax
f0105a47:	83 c2 01             	add    $0x1,%edx
	for (i = 0; i < len; i++)
f0105a4a:	39 f2                	cmp    %esi,%edx
f0105a4c:	75 f4                	jne    f0105a42 <mpsearch1+0x7b>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105a4e:	84 c0                	test   %al,%al
f0105a50:	75 cb                	jne    f0105a1d <mpsearch1+0x56>
f0105a52:	eb 05                	jmp    f0105a59 <mpsearch1+0x92>
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f0105a54:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f0105a59:	89 d8                	mov    %ebx,%eax
f0105a5b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105a5e:	5b                   	pop    %ebx
f0105a5f:	5e                   	pop    %esi
f0105a60:	5f                   	pop    %edi
f0105a61:	5d                   	pop    %ebp
f0105a62:	c3                   	ret    

f0105a63 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f0105a63:	55                   	push   %ebp
f0105a64:	89 e5                	mov    %esp,%ebp
f0105a66:	57                   	push   %edi
f0105a67:	56                   	push   %esi
f0105a68:	53                   	push   %ebx
f0105a69:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0105a6c:	c7 05 c0 83 23 f0 20 	movl   $0xf0238020,0xf02383c0
f0105a73:	80 23 f0 
	if (PGNUM(pa) >= npages)
f0105a76:	83 3d 88 7e 23 f0 00 	cmpl   $0x0,0xf0237e88
f0105a7d:	0f 84 a3 00 00 00    	je     f0105b26 <mp_init+0xc3>
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0105a83:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0105a8a:	85 c0                	test   %eax,%eax
f0105a8c:	0f 84 aa 00 00 00    	je     f0105b3c <mp_init+0xd9>
		p <<= 4;	// Translate from segment to PA
f0105a92:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f0105a95:	ba 00 04 00 00       	mov    $0x400,%edx
f0105a9a:	e8 28 ff ff ff       	call   f01059c7 <mpsearch1>
f0105a9f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105aa2:	85 c0                	test   %eax,%eax
f0105aa4:	75 1a                	jne    f0105ac0 <mp_init+0x5d>
	return mpsearch1(0xF0000, 0x10000);
f0105aa6:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105aab:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0105ab0:	e8 12 ff ff ff       	call   f01059c7 <mpsearch1>
f0105ab5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if ((mp = mpsearch()) == 0)
f0105ab8:	85 c0                	test   %eax,%eax
f0105aba:	0f 84 31 02 00 00    	je     f0105cf1 <mp_init+0x28e>
	if (mp->physaddr == 0 || mp->type != 0) {
f0105ac0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105ac3:	8b 58 04             	mov    0x4(%eax),%ebx
f0105ac6:	85 db                	test   %ebx,%ebx
f0105ac8:	0f 84 97 00 00 00    	je     f0105b65 <mp_init+0x102>
f0105ace:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0105ad2:	0f 85 8d 00 00 00    	jne    f0105b65 <mp_init+0x102>
f0105ad8:	89 d8                	mov    %ebx,%eax
f0105ada:	c1 e8 0c             	shr    $0xc,%eax
f0105add:	3b 05 88 7e 23 f0    	cmp    0xf0237e88,%eax
f0105ae3:	0f 83 91 00 00 00    	jae    f0105b7a <mp_init+0x117>
	return (void *)(pa + KERNBASE);
f0105ae9:	81 eb 00 00 00 10    	sub    $0x10000000,%ebx
f0105aef:	89 de                	mov    %ebx,%esi
	if (memcmp(conf, "PCMP", 4) != 0) {
f0105af1:	83 ec 04             	sub    $0x4,%esp
f0105af4:	6a 04                	push   $0x4
f0105af6:	68 f6 7f 10 f0       	push   $0xf0107ff6
f0105afb:	53                   	push   %ebx
f0105afc:	e8 19 fd ff ff       	call   f010581a <memcmp>
f0105b01:	83 c4 10             	add    $0x10,%esp
f0105b04:	85 c0                	test   %eax,%eax
f0105b06:	0f 85 83 00 00 00    	jne    f0105b8f <mp_init+0x12c>
f0105b0c:	0f b7 7b 04          	movzwl 0x4(%ebx),%edi
f0105b10:	01 df                	add    %ebx,%edi
	sum = 0;
f0105b12:	89 c2                	mov    %eax,%edx
	for (i = 0; i < len; i++)
f0105b14:	39 fb                	cmp    %edi,%ebx
f0105b16:	0f 84 88 00 00 00    	je     f0105ba4 <mp_init+0x141>
		sum += ((uint8_t *)addr)[i];
f0105b1c:	0f b6 0b             	movzbl (%ebx),%ecx
f0105b1f:	01 ca                	add    %ecx,%edx
f0105b21:	83 c3 01             	add    $0x1,%ebx
f0105b24:	eb ee                	jmp    f0105b14 <mp_init+0xb1>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105b26:	68 00 04 00 00       	push   $0x400
f0105b2b:	68 54 64 10 f0       	push   $0xf0106454
f0105b30:	6a 6f                	push   $0x6f
f0105b32:	68 e1 7f 10 f0       	push   $0xf0107fe1
f0105b37:	e8 58 a5 ff ff       	call   f0100094 <_panic>
		p = *(uint16_t *) (bda + 0x13) * 1024;
f0105b3c:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0105b43:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f0105b46:	2d 00 04 00 00       	sub    $0x400,%eax
f0105b4b:	ba 00 04 00 00       	mov    $0x400,%edx
f0105b50:	e8 72 fe ff ff       	call   f01059c7 <mpsearch1>
f0105b55:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105b58:	85 c0                	test   %eax,%eax
f0105b5a:	0f 85 60 ff ff ff    	jne    f0105ac0 <mp_init+0x5d>
f0105b60:	e9 41 ff ff ff       	jmp    f0105aa6 <mp_init+0x43>
		cprintf("SMP: Default configurations not implemented\n");
f0105b65:	83 ec 0c             	sub    $0xc,%esp
f0105b68:	68 54 7e 10 f0       	push   $0xf0107e54
f0105b6d:	e8 8a dd ff ff       	call   f01038fc <cprintf>
f0105b72:	83 c4 10             	add    $0x10,%esp
f0105b75:	e9 77 01 00 00       	jmp    f0105cf1 <mp_init+0x28e>
f0105b7a:	53                   	push   %ebx
f0105b7b:	68 54 64 10 f0       	push   $0xf0106454
f0105b80:	68 90 00 00 00       	push   $0x90
f0105b85:	68 e1 7f 10 f0       	push   $0xf0107fe1
f0105b8a:	e8 05 a5 ff ff       	call   f0100094 <_panic>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0105b8f:	83 ec 0c             	sub    $0xc,%esp
f0105b92:	68 84 7e 10 f0       	push   $0xf0107e84
f0105b97:	e8 60 dd ff ff       	call   f01038fc <cprintf>
f0105b9c:	83 c4 10             	add    $0x10,%esp
f0105b9f:	e9 4d 01 00 00       	jmp    f0105cf1 <mp_init+0x28e>
	if (sum(conf, conf->length) != 0) {
f0105ba4:	84 d2                	test   %dl,%dl
f0105ba6:	75 16                	jne    f0105bbe <mp_init+0x15b>
	if (conf->version != 1 && conf->version != 4) {
f0105ba8:	0f b6 56 06          	movzbl 0x6(%esi),%edx
f0105bac:	80 fa 01             	cmp    $0x1,%dl
f0105baf:	74 05                	je     f0105bb6 <mp_init+0x153>
f0105bb1:	80 fa 04             	cmp    $0x4,%dl
f0105bb4:	75 1d                	jne    f0105bd3 <mp_init+0x170>
f0105bb6:	0f b7 4e 28          	movzwl 0x28(%esi),%ecx
f0105bba:	01 d9                	add    %ebx,%ecx
f0105bbc:	eb 36                	jmp    f0105bf4 <mp_init+0x191>
		cprintf("SMP: Bad MP configuration checksum\n");
f0105bbe:	83 ec 0c             	sub    $0xc,%esp
f0105bc1:	68 b8 7e 10 f0       	push   $0xf0107eb8
f0105bc6:	e8 31 dd ff ff       	call   f01038fc <cprintf>
f0105bcb:	83 c4 10             	add    $0x10,%esp
f0105bce:	e9 1e 01 00 00       	jmp    f0105cf1 <mp_init+0x28e>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0105bd3:	83 ec 08             	sub    $0x8,%esp
f0105bd6:	0f b6 d2             	movzbl %dl,%edx
f0105bd9:	52                   	push   %edx
f0105bda:	68 dc 7e 10 f0       	push   $0xf0107edc
f0105bdf:	e8 18 dd ff ff       	call   f01038fc <cprintf>
f0105be4:	83 c4 10             	add    $0x10,%esp
f0105be7:	e9 05 01 00 00       	jmp    f0105cf1 <mp_init+0x28e>
		sum += ((uint8_t *)addr)[i];
f0105bec:	0f b6 13             	movzbl (%ebx),%edx
f0105bef:	01 d0                	add    %edx,%eax
f0105bf1:	83 c3 01             	add    $0x1,%ebx
	for (i = 0; i < len; i++)
f0105bf4:	39 d9                	cmp    %ebx,%ecx
f0105bf6:	75 f4                	jne    f0105bec <mp_init+0x189>
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0105bf8:	02 46 2a             	add    0x2a(%esi),%al
f0105bfb:	75 1c                	jne    f0105c19 <mp_init+0x1b6>
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
f0105bfd:	c7 05 00 80 23 f0 01 	movl   $0x1,0xf0238000
f0105c04:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0105c07:	8b 46 24             	mov    0x24(%esi),%eax
f0105c0a:	a3 00 90 27 f0       	mov    %eax,0xf0279000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105c0f:	8d 7e 2c             	lea    0x2c(%esi),%edi
f0105c12:	bb 00 00 00 00       	mov    $0x0,%ebx
f0105c17:	eb 4d                	jmp    f0105c66 <mp_init+0x203>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0105c19:	83 ec 0c             	sub    $0xc,%esp
f0105c1c:	68 fc 7e 10 f0       	push   $0xf0107efc
f0105c21:	e8 d6 dc ff ff       	call   f01038fc <cprintf>
f0105c26:	83 c4 10             	add    $0x10,%esp
f0105c29:	e9 c3 00 00 00       	jmp    f0105cf1 <mp_init+0x28e>
		switch (*p) {
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0105c2e:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f0105c32:	74 11                	je     f0105c45 <mp_init+0x1e2>
				bootcpu = &cpus[ncpu];
f0105c34:	6b 05 c4 83 23 f0 74 	imul   $0x74,0xf02383c4,%eax
f0105c3b:	05 20 80 23 f0       	add    $0xf0238020,%eax
f0105c40:	a3 c0 83 23 f0       	mov    %eax,0xf02383c0
			if (ncpu < NCPU) {
f0105c45:	a1 c4 83 23 f0       	mov    0xf02383c4,%eax
f0105c4a:	83 f8 07             	cmp    $0x7,%eax
f0105c4d:	7f 2f                	jg     f0105c7e <mp_init+0x21b>
				cpus[ncpu].cpu_id = ncpu;
f0105c4f:	6b d0 74             	imul   $0x74,%eax,%edx
f0105c52:	88 82 20 80 23 f0    	mov    %al,-0xfdc7fe0(%edx)
				ncpu++;
f0105c58:	83 c0 01             	add    $0x1,%eax
f0105c5b:	a3 c4 83 23 f0       	mov    %eax,0xf02383c4
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0105c60:	83 c7 14             	add    $0x14,%edi
	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105c63:	83 c3 01             	add    $0x1,%ebx
f0105c66:	0f b7 46 22          	movzwl 0x22(%esi),%eax
f0105c6a:	39 d8                	cmp    %ebx,%eax
f0105c6c:	76 4b                	jbe    f0105cb9 <mp_init+0x256>
		switch (*p) {
f0105c6e:	0f b6 07             	movzbl (%edi),%eax
f0105c71:	84 c0                	test   %al,%al
f0105c73:	74 b9                	je     f0105c2e <mp_init+0x1cb>
f0105c75:	3c 04                	cmp    $0x4,%al
f0105c77:	77 1c                	ja     f0105c95 <mp_init+0x232>
			continue;
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0105c79:	83 c7 08             	add    $0x8,%edi
			continue;
f0105c7c:	eb e5                	jmp    f0105c63 <mp_init+0x200>
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0105c7e:	83 ec 08             	sub    $0x8,%esp
f0105c81:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f0105c85:	50                   	push   %eax
f0105c86:	68 2c 7f 10 f0       	push   $0xf0107f2c
f0105c8b:	e8 6c dc ff ff       	call   f01038fc <cprintf>
f0105c90:	83 c4 10             	add    $0x10,%esp
f0105c93:	eb cb                	jmp    f0105c60 <mp_init+0x1fd>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0105c95:	83 ec 08             	sub    $0x8,%esp
		switch (*p) {
f0105c98:	0f b6 c0             	movzbl %al,%eax
			cprintf("mpinit: unknown config type %x\n", *p);
f0105c9b:	50                   	push   %eax
f0105c9c:	68 54 7f 10 f0       	push   $0xf0107f54
f0105ca1:	e8 56 dc ff ff       	call   f01038fc <cprintf>
			ismp = 0;
f0105ca6:	c7 05 00 80 23 f0 00 	movl   $0x0,0xf0238000
f0105cad:	00 00 00 
			i = conf->entry;
f0105cb0:	0f b7 5e 22          	movzwl 0x22(%esi),%ebx
f0105cb4:	83 c4 10             	add    $0x10,%esp
f0105cb7:	eb aa                	jmp    f0105c63 <mp_init+0x200>
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0105cb9:	a1 c0 83 23 f0       	mov    0xf02383c0,%eax
f0105cbe:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0105cc5:	83 3d 00 80 23 f0 00 	cmpl   $0x0,0xf0238000
f0105ccc:	74 2b                	je     f0105cf9 <mp_init+0x296>
		ncpu = 1;
		lapicaddr = 0;
		cprintf("SMP: configuration not found, SMP disabled\n");
		return;
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0105cce:	83 ec 04             	sub    $0x4,%esp
f0105cd1:	ff 35 c4 83 23 f0    	pushl  0xf02383c4
f0105cd7:	0f b6 00             	movzbl (%eax),%eax
f0105cda:	50                   	push   %eax
f0105cdb:	68 fb 7f 10 f0       	push   $0xf0107ffb
f0105ce0:	e8 17 dc ff ff       	call   f01038fc <cprintf>

	if (mp->imcrp) {
f0105ce5:	83 c4 10             	add    $0x10,%esp
f0105ce8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105ceb:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0105cef:	75 2e                	jne    f0105d1f <mp_init+0x2bc>
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f0105cf1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105cf4:	5b                   	pop    %ebx
f0105cf5:	5e                   	pop    %esi
f0105cf6:	5f                   	pop    %edi
f0105cf7:	5d                   	pop    %ebp
f0105cf8:	c3                   	ret    
		ncpu = 1;
f0105cf9:	c7 05 c4 83 23 f0 01 	movl   $0x1,0xf02383c4
f0105d00:	00 00 00 
		lapicaddr = 0;
f0105d03:	c7 05 00 90 27 f0 00 	movl   $0x0,0xf0279000
f0105d0a:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0105d0d:	83 ec 0c             	sub    $0xc,%esp
f0105d10:	68 74 7f 10 f0       	push   $0xf0107f74
f0105d15:	e8 e2 db ff ff       	call   f01038fc <cprintf>
		return;
f0105d1a:	83 c4 10             	add    $0x10,%esp
f0105d1d:	eb d2                	jmp    f0105cf1 <mp_init+0x28e>
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0105d1f:	83 ec 0c             	sub    $0xc,%esp
f0105d22:	68 a0 7f 10 f0       	push   $0xf0107fa0
f0105d27:	e8 d0 db ff ff       	call   f01038fc <cprintf>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105d2c:	b8 70 00 00 00       	mov    $0x70,%eax
f0105d31:	ba 22 00 00 00       	mov    $0x22,%edx
f0105d36:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0105d37:	ba 23 00 00 00       	mov    $0x23,%edx
f0105d3c:	ec                   	in     (%dx),%al
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f0105d3d:	83 c8 01             	or     $0x1,%eax
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105d40:	ee                   	out    %al,(%dx)
f0105d41:	83 c4 10             	add    $0x10,%esp
f0105d44:	eb ab                	jmp    f0105cf1 <mp_init+0x28e>

f0105d46 <lapicw>:
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
	lapic[index] = value;
f0105d46:	8b 0d 04 90 27 f0    	mov    0xf0279004,%ecx
f0105d4c:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0105d4f:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0105d51:	a1 04 90 27 f0       	mov    0xf0279004,%eax
f0105d56:	8b 40 20             	mov    0x20(%eax),%eax
}
f0105d59:	c3                   	ret    

f0105d5a <cpunum>:
}

int
cpunum(void)
{
	if (lapic)
f0105d5a:	8b 15 04 90 27 f0    	mov    0xf0279004,%edx
		return lapic[ID] >> 24;
	return 0;
f0105d60:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lapic)
f0105d65:	85 d2                	test   %edx,%edx
f0105d67:	74 06                	je     f0105d6f <cpunum+0x15>
		return lapic[ID] >> 24;
f0105d69:	8b 42 20             	mov    0x20(%edx),%eax
f0105d6c:	c1 e8 18             	shr    $0x18,%eax
}
f0105d6f:	c3                   	ret    

f0105d70 <lapic_init>:
	if (!lapicaddr)
f0105d70:	a1 00 90 27 f0       	mov    0xf0279000,%eax
f0105d75:	85 c0                	test   %eax,%eax
f0105d77:	75 01                	jne    f0105d7a <lapic_init+0xa>
f0105d79:	c3                   	ret    
{
f0105d7a:	55                   	push   %ebp
f0105d7b:	89 e5                	mov    %esp,%ebp
f0105d7d:	83 ec 10             	sub    $0x10,%esp
	lapic = mmio_map_region(lapicaddr, 4096);
f0105d80:	68 00 10 00 00       	push   $0x1000
f0105d85:	50                   	push   %eax
f0105d86:	e8 2d b5 ff ff       	call   f01012b8 <mmio_map_region>
f0105d8b:	a3 04 90 27 f0       	mov    %eax,0xf0279004
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0105d90:	ba 27 01 00 00       	mov    $0x127,%edx
f0105d95:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0105d9a:	e8 a7 ff ff ff       	call   f0105d46 <lapicw>
	lapicw(TDCR, X1);
f0105d9f:	ba 0b 00 00 00       	mov    $0xb,%edx
f0105da4:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0105da9:	e8 98 ff ff ff       	call   f0105d46 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0105dae:	ba 20 00 02 00       	mov    $0x20020,%edx
f0105db3:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0105db8:	e8 89 ff ff ff       	call   f0105d46 <lapicw>
	lapicw(TICR, 10000000); 
f0105dbd:	ba 80 96 98 00       	mov    $0x989680,%edx
f0105dc2:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0105dc7:	e8 7a ff ff ff       	call   f0105d46 <lapicw>
	if (thiscpu != bootcpu)
f0105dcc:	e8 89 ff ff ff       	call   f0105d5a <cpunum>
f0105dd1:	6b c0 74             	imul   $0x74,%eax,%eax
f0105dd4:	05 20 80 23 f0       	add    $0xf0238020,%eax
f0105dd9:	83 c4 10             	add    $0x10,%esp
f0105ddc:	39 05 c0 83 23 f0    	cmp    %eax,0xf02383c0
f0105de2:	74 0f                	je     f0105df3 <lapic_init+0x83>
		lapicw(LINT0, MASKED);
f0105de4:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105de9:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0105dee:	e8 53 ff ff ff       	call   f0105d46 <lapicw>
	lapicw(LINT1, MASKED);
f0105df3:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105df8:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0105dfd:	e8 44 ff ff ff       	call   f0105d46 <lapicw>
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0105e02:	a1 04 90 27 f0       	mov    0xf0279004,%eax
f0105e07:	8b 40 30             	mov    0x30(%eax),%eax
f0105e0a:	c1 e8 10             	shr    $0x10,%eax
f0105e0d:	a8 fc                	test   $0xfc,%al
f0105e0f:	75 7c                	jne    f0105e8d <lapic_init+0x11d>
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0105e11:	ba 33 00 00 00       	mov    $0x33,%edx
f0105e16:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0105e1b:	e8 26 ff ff ff       	call   f0105d46 <lapicw>
	lapicw(ESR, 0);
f0105e20:	ba 00 00 00 00       	mov    $0x0,%edx
f0105e25:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105e2a:	e8 17 ff ff ff       	call   f0105d46 <lapicw>
	lapicw(ESR, 0);
f0105e2f:	ba 00 00 00 00       	mov    $0x0,%edx
f0105e34:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105e39:	e8 08 ff ff ff       	call   f0105d46 <lapicw>
	lapicw(EOI, 0);
f0105e3e:	ba 00 00 00 00       	mov    $0x0,%edx
f0105e43:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105e48:	e8 f9 fe ff ff       	call   f0105d46 <lapicw>
	lapicw(ICRHI, 0);
f0105e4d:	ba 00 00 00 00       	mov    $0x0,%edx
f0105e52:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105e57:	e8 ea fe ff ff       	call   f0105d46 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0105e5c:	ba 00 85 08 00       	mov    $0x88500,%edx
f0105e61:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105e66:	e8 db fe ff ff       	call   f0105d46 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0105e6b:	8b 15 04 90 27 f0    	mov    0xf0279004,%edx
f0105e71:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105e77:	f6 c4 10             	test   $0x10,%ah
f0105e7a:	75 f5                	jne    f0105e71 <lapic_init+0x101>
	lapicw(TPR, 0);
f0105e7c:	ba 00 00 00 00       	mov    $0x0,%edx
f0105e81:	b8 20 00 00 00       	mov    $0x20,%eax
f0105e86:	e8 bb fe ff ff       	call   f0105d46 <lapicw>
}
f0105e8b:	c9                   	leave  
f0105e8c:	c3                   	ret    
		lapicw(PCINT, MASKED);
f0105e8d:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105e92:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0105e97:	e8 aa fe ff ff       	call   f0105d46 <lapicw>
f0105e9c:	e9 70 ff ff ff       	jmp    f0105e11 <lapic_init+0xa1>

f0105ea1 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f0105ea1:	83 3d 04 90 27 f0 00 	cmpl   $0x0,0xf0279004
f0105ea8:	74 17                	je     f0105ec1 <lapic_eoi+0x20>
{
f0105eaa:	55                   	push   %ebp
f0105eab:	89 e5                	mov    %esp,%ebp
f0105ead:	83 ec 08             	sub    $0x8,%esp
		lapicw(EOI, 0);
f0105eb0:	ba 00 00 00 00       	mov    $0x0,%edx
f0105eb5:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105eba:	e8 87 fe ff ff       	call   f0105d46 <lapicw>
}
f0105ebf:	c9                   	leave  
f0105ec0:	c3                   	ret    
f0105ec1:	c3                   	ret    

f0105ec2 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0105ec2:	55                   	push   %ebp
f0105ec3:	89 e5                	mov    %esp,%ebp
f0105ec5:	56                   	push   %esi
f0105ec6:	53                   	push   %ebx
f0105ec7:	8b 75 08             	mov    0x8(%ebp),%esi
f0105eca:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105ecd:	b8 0f 00 00 00       	mov    $0xf,%eax
f0105ed2:	ba 70 00 00 00       	mov    $0x70,%edx
f0105ed7:	ee                   	out    %al,(%dx)
f0105ed8:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105edd:	ba 71 00 00 00       	mov    $0x71,%edx
f0105ee2:	ee                   	out    %al,(%dx)
	if (PGNUM(pa) >= npages)
f0105ee3:	83 3d 88 7e 23 f0 00 	cmpl   $0x0,0xf0237e88
f0105eea:	74 7e                	je     f0105f6a <lapic_startap+0xa8>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0105eec:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0105ef3:	00 00 
	wrv[1] = addr >> 4;
f0105ef5:	89 d8                	mov    %ebx,%eax
f0105ef7:	c1 e8 04             	shr    $0x4,%eax
f0105efa:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0105f00:	c1 e6 18             	shl    $0x18,%esi
f0105f03:	89 f2                	mov    %esi,%edx
f0105f05:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105f0a:	e8 37 fe ff ff       	call   f0105d46 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0105f0f:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0105f14:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105f19:	e8 28 fe ff ff       	call   f0105d46 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0105f1e:	ba 00 85 00 00       	mov    $0x8500,%edx
f0105f23:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105f28:	e8 19 fe ff ff       	call   f0105d46 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105f2d:	c1 eb 0c             	shr    $0xc,%ebx
f0105f30:	80 cf 06             	or     $0x6,%bh
		lapicw(ICRHI, apicid << 24);
f0105f33:	89 f2                	mov    %esi,%edx
f0105f35:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105f3a:	e8 07 fe ff ff       	call   f0105d46 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105f3f:	89 da                	mov    %ebx,%edx
f0105f41:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105f46:	e8 fb fd ff ff       	call   f0105d46 <lapicw>
		lapicw(ICRHI, apicid << 24);
f0105f4b:	89 f2                	mov    %esi,%edx
f0105f4d:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105f52:	e8 ef fd ff ff       	call   f0105d46 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105f57:	89 da                	mov    %ebx,%edx
f0105f59:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105f5e:	e8 e3 fd ff ff       	call   f0105d46 <lapicw>
		microdelay(200);
	}
}
f0105f63:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105f66:	5b                   	pop    %ebx
f0105f67:	5e                   	pop    %esi
f0105f68:	5d                   	pop    %ebp
f0105f69:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105f6a:	68 67 04 00 00       	push   $0x467
f0105f6f:	68 54 64 10 f0       	push   $0xf0106454
f0105f74:	68 98 00 00 00       	push   $0x98
f0105f79:	68 18 80 10 f0       	push   $0xf0108018
f0105f7e:	e8 11 a1 ff ff       	call   f0100094 <_panic>

f0105f83 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0105f83:	55                   	push   %ebp
f0105f84:	89 e5                	mov    %esp,%ebp
f0105f86:	83 ec 08             	sub    $0x8,%esp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0105f89:	8b 55 08             	mov    0x8(%ebp),%edx
f0105f8c:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0105f92:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105f97:	e8 aa fd ff ff       	call   f0105d46 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0105f9c:	8b 15 04 90 27 f0    	mov    0xf0279004,%edx
f0105fa2:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105fa8:	f6 c4 10             	test   $0x10,%ah
f0105fab:	75 f5                	jne    f0105fa2 <lapic_ipi+0x1f>
		;
}
f0105fad:	c9                   	leave  
f0105fae:	c3                   	ret    

f0105faf <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0105faf:	55                   	push   %ebp
f0105fb0:	89 e5                	mov    %esp,%ebp
f0105fb2:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0105fb5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0105fbb:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105fbe:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0105fc1:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0105fc8:	5d                   	pop    %ebp
f0105fc9:	c3                   	ret    

f0105fca <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0105fca:	55                   	push   %ebp
f0105fcb:	89 e5                	mov    %esp,%ebp
f0105fcd:	56                   	push   %esi
f0105fce:	53                   	push   %ebx
f0105fcf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	return lock->locked && lock->cpu == thiscpu;
f0105fd2:	83 3b 00             	cmpl   $0x0,(%ebx)
f0105fd5:	75 12                	jne    f0105fe9 <spin_lock+0x1f>
	asm volatile("lock; xchgl %0, %1"
f0105fd7:	ba 01 00 00 00       	mov    $0x1,%edx
f0105fdc:	89 d0                	mov    %edx,%eax
f0105fde:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0105fe1:	85 c0                	test   %eax,%eax
f0105fe3:	74 36                	je     f010601b <spin_lock+0x51>
		asm volatile ("pause");
f0105fe5:	f3 90                	pause  
f0105fe7:	eb f3                	jmp    f0105fdc <spin_lock+0x12>
	return lock->locked && lock->cpu == thiscpu;
f0105fe9:	8b 73 08             	mov    0x8(%ebx),%esi
f0105fec:	e8 69 fd ff ff       	call   f0105d5a <cpunum>
f0105ff1:	6b c0 74             	imul   $0x74,%eax,%eax
f0105ff4:	05 20 80 23 f0       	add    $0xf0238020,%eax
	if (holding(lk))
f0105ff9:	39 c6                	cmp    %eax,%esi
f0105ffb:	75 da                	jne    f0105fd7 <spin_lock+0xd>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0105ffd:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0106000:	e8 55 fd ff ff       	call   f0105d5a <cpunum>
f0106005:	83 ec 0c             	sub    $0xc,%esp
f0106008:	53                   	push   %ebx
f0106009:	50                   	push   %eax
f010600a:	68 28 80 10 f0       	push   $0xf0108028
f010600f:	6a 41                	push   $0x41
f0106011:	68 8c 80 10 f0       	push   $0xf010808c
f0106016:	e8 79 a0 ff ff       	call   f0100094 <_panic>

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f010601b:	e8 3a fd ff ff       	call   f0105d5a <cpunum>
f0106020:	6b c0 74             	imul   $0x74,%eax,%eax
f0106023:	05 20 80 23 f0       	add    $0xf0238020,%eax
f0106028:	89 43 08             	mov    %eax,0x8(%ebx)
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f010602b:	89 ea                	mov    %ebp,%edx
	for (i = 0; i < 10; i++){
f010602d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0106032:	83 f8 09             	cmp    $0x9,%eax
f0106035:	7f 16                	jg     f010604d <spin_lock+0x83>
f0106037:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f010603d:	76 0e                	jbe    f010604d <spin_lock+0x83>
		pcs[i] = ebp[1];          // saved %eip
f010603f:	8b 4a 04             	mov    0x4(%edx),%ecx
f0106042:	89 4c 83 0c          	mov    %ecx,0xc(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0106046:	8b 12                	mov    (%edx),%edx
	for (i = 0; i < 10; i++){
f0106048:	83 c0 01             	add    $0x1,%eax
f010604b:	eb e5                	jmp    f0106032 <spin_lock+0x68>
	for (; i < 10; i++)
f010604d:	83 f8 09             	cmp    $0x9,%eax
f0106050:	7f 0d                	jg     f010605f <spin_lock+0x95>
		pcs[i] = 0;
f0106052:	c7 44 83 0c 00 00 00 	movl   $0x0,0xc(%ebx,%eax,4)
f0106059:	00 
	for (; i < 10; i++)
f010605a:	83 c0 01             	add    $0x1,%eax
f010605d:	eb ee                	jmp    f010604d <spin_lock+0x83>
	get_caller_pcs(lk->pcs);
#endif
}
f010605f:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0106062:	5b                   	pop    %ebx
f0106063:	5e                   	pop    %esi
f0106064:	5d                   	pop    %ebp
f0106065:	c3                   	ret    

f0106066 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0106066:	55                   	push   %ebp
f0106067:	89 e5                	mov    %esp,%ebp
f0106069:	57                   	push   %edi
f010606a:	56                   	push   %esi
f010606b:	53                   	push   %ebx
f010606c:	83 ec 4c             	sub    $0x4c,%esp
f010606f:	8b 75 08             	mov    0x8(%ebp),%esi
	return lock->locked && lock->cpu == thiscpu;
f0106072:	83 3e 00             	cmpl   $0x0,(%esi)
f0106075:	75 35                	jne    f01060ac <spin_unlock+0x46>
//	cprintf("kern_lock_cpu:%p--------------------------------------------------\n", lk->cpu);
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f0106077:	83 ec 04             	sub    $0x4,%esp
f010607a:	6a 28                	push   $0x28
f010607c:	8d 46 0c             	lea    0xc(%esi),%eax
f010607f:	50                   	push   %eax
f0106080:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f0106083:	53                   	push   %ebx
f0106084:	e8 19 f7 ff ff       	call   f01057a2 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f0106089:	8b 46 08             	mov    0x8(%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f010608c:	0f b6 38             	movzbl (%eax),%edi
f010608f:	8b 76 04             	mov    0x4(%esi),%esi
f0106092:	e8 c3 fc ff ff       	call   f0105d5a <cpunum>
f0106097:	57                   	push   %edi
f0106098:	56                   	push   %esi
f0106099:	50                   	push   %eax
f010609a:	68 54 80 10 f0       	push   $0xf0108054
f010609f:	e8 58 d8 ff ff       	call   f01038fc <cprintf>
f01060a4:	83 c4 20             	add    $0x20,%esp
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f01060a7:	8d 7d a8             	lea    -0x58(%ebp),%edi
f01060aa:	eb 4e                	jmp    f01060fa <spin_unlock+0x94>
	return lock->locked && lock->cpu == thiscpu;
f01060ac:	8b 5e 08             	mov    0x8(%esi),%ebx
f01060af:	e8 a6 fc ff ff       	call   f0105d5a <cpunum>
f01060b4:	6b c0 74             	imul   $0x74,%eax,%eax
f01060b7:	05 20 80 23 f0       	add    $0xf0238020,%eax
	if (!holding(lk)) {
f01060bc:	39 c3                	cmp    %eax,%ebx
f01060be:	75 b7                	jne    f0106077 <spin_unlock+0x11>
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
	}

	lk->pcs[0] = 0;
f01060c0:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f01060c7:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
	asm volatile("lock; xchgl %0, %1"
f01060ce:	b8 00 00 00 00       	mov    $0x0,%eax
f01060d3:	f0 87 06             	lock xchg %eax,(%esi)
	// respect to any other instruction which references the same memory.
	// x86 CPUs will not reorder loads/stores across locked instructions
	// (vol 3, 8.2.2). Because xchg() is implemented using asm volatile,
	// gcc will not reorder C statements across the xchg.
	xchg(&lk->locked, 0);
}
f01060d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01060d9:	5b                   	pop    %ebx
f01060da:	5e                   	pop    %esi
f01060db:	5f                   	pop    %edi
f01060dc:	5d                   	pop    %ebp
f01060dd:	c3                   	ret    
				cprintf("  %08x\n", pcs[i]);
f01060de:	83 ec 08             	sub    $0x8,%esp
f01060e1:	ff 36                	pushl  (%esi)
f01060e3:	68 b3 80 10 f0       	push   $0xf01080b3
f01060e8:	e8 0f d8 ff ff       	call   f01038fc <cprintf>
f01060ed:	83 c4 10             	add    $0x10,%esp
f01060f0:	83 c3 04             	add    $0x4,%ebx
		for (i = 0; i < 10 && pcs[i]; i++) {
f01060f3:	8d 45 e8             	lea    -0x18(%ebp),%eax
f01060f6:	39 c3                	cmp    %eax,%ebx
f01060f8:	74 40                	je     f010613a <spin_unlock+0xd4>
f01060fa:	89 de                	mov    %ebx,%esi
f01060fc:	8b 03                	mov    (%ebx),%eax
f01060fe:	85 c0                	test   %eax,%eax
f0106100:	74 38                	je     f010613a <spin_unlock+0xd4>
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0106102:	83 ec 08             	sub    $0x8,%esp
f0106105:	57                   	push   %edi
f0106106:	50                   	push   %eax
f0106107:	e8 0f ec ff ff       	call   f0104d1b <debuginfo_eip>
f010610c:	83 c4 10             	add    $0x10,%esp
f010610f:	85 c0                	test   %eax,%eax
f0106111:	78 cb                	js     f01060de <spin_unlock+0x78>
					pcs[i] - info.eip_fn_addr);
f0106113:	8b 06                	mov    (%esi),%eax
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0106115:	83 ec 04             	sub    $0x4,%esp
f0106118:	89 c2                	mov    %eax,%edx
f010611a:	2b 55 b8             	sub    -0x48(%ebp),%edx
f010611d:	52                   	push   %edx
f010611e:	ff 75 b0             	pushl  -0x50(%ebp)
f0106121:	ff 75 b4             	pushl  -0x4c(%ebp)
f0106124:	ff 75 ac             	pushl  -0x54(%ebp)
f0106127:	ff 75 a8             	pushl  -0x58(%ebp)
f010612a:	50                   	push   %eax
f010612b:	68 9c 80 10 f0       	push   $0xf010809c
f0106130:	e8 c7 d7 ff ff       	call   f01038fc <cprintf>
f0106135:	83 c4 20             	add    $0x20,%esp
f0106138:	eb b6                	jmp    f01060f0 <spin_unlock+0x8a>
		panic("spin_unlock");
f010613a:	83 ec 04             	sub    $0x4,%esp
f010613d:	68 bb 80 10 f0       	push   $0xf01080bb
f0106142:	6a 68                	push   $0x68
f0106144:	68 8c 80 10 f0       	push   $0xf010808c
f0106149:	e8 46 9f ff ff       	call   f0100094 <_panic>
f010614e:	66 90                	xchg   %ax,%ax

f0106150 <__udivdi3>:
f0106150:	f3 0f 1e fb          	endbr32 
f0106154:	55                   	push   %ebp
f0106155:	57                   	push   %edi
f0106156:	56                   	push   %esi
f0106157:	53                   	push   %ebx
f0106158:	83 ec 1c             	sub    $0x1c,%esp
f010615b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010615f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f0106163:	8b 74 24 34          	mov    0x34(%esp),%esi
f0106167:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f010616b:	85 d2                	test   %edx,%edx
f010616d:	75 49                	jne    f01061b8 <__udivdi3+0x68>
f010616f:	39 f3                	cmp    %esi,%ebx
f0106171:	76 15                	jbe    f0106188 <__udivdi3+0x38>
f0106173:	31 ff                	xor    %edi,%edi
f0106175:	89 e8                	mov    %ebp,%eax
f0106177:	89 f2                	mov    %esi,%edx
f0106179:	f7 f3                	div    %ebx
f010617b:	89 fa                	mov    %edi,%edx
f010617d:	83 c4 1c             	add    $0x1c,%esp
f0106180:	5b                   	pop    %ebx
f0106181:	5e                   	pop    %esi
f0106182:	5f                   	pop    %edi
f0106183:	5d                   	pop    %ebp
f0106184:	c3                   	ret    
f0106185:	8d 76 00             	lea    0x0(%esi),%esi
f0106188:	89 d9                	mov    %ebx,%ecx
f010618a:	85 db                	test   %ebx,%ebx
f010618c:	75 0b                	jne    f0106199 <__udivdi3+0x49>
f010618e:	b8 01 00 00 00       	mov    $0x1,%eax
f0106193:	31 d2                	xor    %edx,%edx
f0106195:	f7 f3                	div    %ebx
f0106197:	89 c1                	mov    %eax,%ecx
f0106199:	31 d2                	xor    %edx,%edx
f010619b:	89 f0                	mov    %esi,%eax
f010619d:	f7 f1                	div    %ecx
f010619f:	89 c6                	mov    %eax,%esi
f01061a1:	89 e8                	mov    %ebp,%eax
f01061a3:	89 f7                	mov    %esi,%edi
f01061a5:	f7 f1                	div    %ecx
f01061a7:	89 fa                	mov    %edi,%edx
f01061a9:	83 c4 1c             	add    $0x1c,%esp
f01061ac:	5b                   	pop    %ebx
f01061ad:	5e                   	pop    %esi
f01061ae:	5f                   	pop    %edi
f01061af:	5d                   	pop    %ebp
f01061b0:	c3                   	ret    
f01061b1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01061b8:	39 f2                	cmp    %esi,%edx
f01061ba:	77 1c                	ja     f01061d8 <__udivdi3+0x88>
f01061bc:	0f bd fa             	bsr    %edx,%edi
f01061bf:	83 f7 1f             	xor    $0x1f,%edi
f01061c2:	75 2c                	jne    f01061f0 <__udivdi3+0xa0>
f01061c4:	39 f2                	cmp    %esi,%edx
f01061c6:	72 06                	jb     f01061ce <__udivdi3+0x7e>
f01061c8:	31 c0                	xor    %eax,%eax
f01061ca:	39 eb                	cmp    %ebp,%ebx
f01061cc:	77 ad                	ja     f010617b <__udivdi3+0x2b>
f01061ce:	b8 01 00 00 00       	mov    $0x1,%eax
f01061d3:	eb a6                	jmp    f010617b <__udivdi3+0x2b>
f01061d5:	8d 76 00             	lea    0x0(%esi),%esi
f01061d8:	31 ff                	xor    %edi,%edi
f01061da:	31 c0                	xor    %eax,%eax
f01061dc:	89 fa                	mov    %edi,%edx
f01061de:	83 c4 1c             	add    $0x1c,%esp
f01061e1:	5b                   	pop    %ebx
f01061e2:	5e                   	pop    %esi
f01061e3:	5f                   	pop    %edi
f01061e4:	5d                   	pop    %ebp
f01061e5:	c3                   	ret    
f01061e6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01061ed:	8d 76 00             	lea    0x0(%esi),%esi
f01061f0:	89 f9                	mov    %edi,%ecx
f01061f2:	b8 20 00 00 00       	mov    $0x20,%eax
f01061f7:	29 f8                	sub    %edi,%eax
f01061f9:	d3 e2                	shl    %cl,%edx
f01061fb:	89 54 24 08          	mov    %edx,0x8(%esp)
f01061ff:	89 c1                	mov    %eax,%ecx
f0106201:	89 da                	mov    %ebx,%edx
f0106203:	d3 ea                	shr    %cl,%edx
f0106205:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0106209:	09 d1                	or     %edx,%ecx
f010620b:	89 f2                	mov    %esi,%edx
f010620d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106211:	89 f9                	mov    %edi,%ecx
f0106213:	d3 e3                	shl    %cl,%ebx
f0106215:	89 c1                	mov    %eax,%ecx
f0106217:	d3 ea                	shr    %cl,%edx
f0106219:	89 f9                	mov    %edi,%ecx
f010621b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f010621f:	89 eb                	mov    %ebp,%ebx
f0106221:	d3 e6                	shl    %cl,%esi
f0106223:	89 c1                	mov    %eax,%ecx
f0106225:	d3 eb                	shr    %cl,%ebx
f0106227:	09 de                	or     %ebx,%esi
f0106229:	89 f0                	mov    %esi,%eax
f010622b:	f7 74 24 08          	divl   0x8(%esp)
f010622f:	89 d6                	mov    %edx,%esi
f0106231:	89 c3                	mov    %eax,%ebx
f0106233:	f7 64 24 0c          	mull   0xc(%esp)
f0106237:	39 d6                	cmp    %edx,%esi
f0106239:	72 15                	jb     f0106250 <__udivdi3+0x100>
f010623b:	89 f9                	mov    %edi,%ecx
f010623d:	d3 e5                	shl    %cl,%ebp
f010623f:	39 c5                	cmp    %eax,%ebp
f0106241:	73 04                	jae    f0106247 <__udivdi3+0xf7>
f0106243:	39 d6                	cmp    %edx,%esi
f0106245:	74 09                	je     f0106250 <__udivdi3+0x100>
f0106247:	89 d8                	mov    %ebx,%eax
f0106249:	31 ff                	xor    %edi,%edi
f010624b:	e9 2b ff ff ff       	jmp    f010617b <__udivdi3+0x2b>
f0106250:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0106253:	31 ff                	xor    %edi,%edi
f0106255:	e9 21 ff ff ff       	jmp    f010617b <__udivdi3+0x2b>
f010625a:	66 90                	xchg   %ax,%ax
f010625c:	66 90                	xchg   %ax,%ax
f010625e:	66 90                	xchg   %ax,%ax

f0106260 <__umoddi3>:
f0106260:	f3 0f 1e fb          	endbr32 
f0106264:	55                   	push   %ebp
f0106265:	57                   	push   %edi
f0106266:	56                   	push   %esi
f0106267:	53                   	push   %ebx
f0106268:	83 ec 1c             	sub    $0x1c,%esp
f010626b:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f010626f:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f0106273:	8b 74 24 30          	mov    0x30(%esp),%esi
f0106277:	8b 7c 24 38          	mov    0x38(%esp),%edi
f010627b:	89 da                	mov    %ebx,%edx
f010627d:	85 c0                	test   %eax,%eax
f010627f:	75 3f                	jne    f01062c0 <__umoddi3+0x60>
f0106281:	39 df                	cmp    %ebx,%edi
f0106283:	76 13                	jbe    f0106298 <__umoddi3+0x38>
f0106285:	89 f0                	mov    %esi,%eax
f0106287:	f7 f7                	div    %edi
f0106289:	89 d0                	mov    %edx,%eax
f010628b:	31 d2                	xor    %edx,%edx
f010628d:	83 c4 1c             	add    $0x1c,%esp
f0106290:	5b                   	pop    %ebx
f0106291:	5e                   	pop    %esi
f0106292:	5f                   	pop    %edi
f0106293:	5d                   	pop    %ebp
f0106294:	c3                   	ret    
f0106295:	8d 76 00             	lea    0x0(%esi),%esi
f0106298:	89 fd                	mov    %edi,%ebp
f010629a:	85 ff                	test   %edi,%edi
f010629c:	75 0b                	jne    f01062a9 <__umoddi3+0x49>
f010629e:	b8 01 00 00 00       	mov    $0x1,%eax
f01062a3:	31 d2                	xor    %edx,%edx
f01062a5:	f7 f7                	div    %edi
f01062a7:	89 c5                	mov    %eax,%ebp
f01062a9:	89 d8                	mov    %ebx,%eax
f01062ab:	31 d2                	xor    %edx,%edx
f01062ad:	f7 f5                	div    %ebp
f01062af:	89 f0                	mov    %esi,%eax
f01062b1:	f7 f5                	div    %ebp
f01062b3:	89 d0                	mov    %edx,%eax
f01062b5:	eb d4                	jmp    f010628b <__umoddi3+0x2b>
f01062b7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01062be:	66 90                	xchg   %ax,%ax
f01062c0:	89 f1                	mov    %esi,%ecx
f01062c2:	39 d8                	cmp    %ebx,%eax
f01062c4:	76 0a                	jbe    f01062d0 <__umoddi3+0x70>
f01062c6:	89 f0                	mov    %esi,%eax
f01062c8:	83 c4 1c             	add    $0x1c,%esp
f01062cb:	5b                   	pop    %ebx
f01062cc:	5e                   	pop    %esi
f01062cd:	5f                   	pop    %edi
f01062ce:	5d                   	pop    %ebp
f01062cf:	c3                   	ret    
f01062d0:	0f bd e8             	bsr    %eax,%ebp
f01062d3:	83 f5 1f             	xor    $0x1f,%ebp
f01062d6:	75 20                	jne    f01062f8 <__umoddi3+0x98>
f01062d8:	39 d8                	cmp    %ebx,%eax
f01062da:	0f 82 b0 00 00 00    	jb     f0106390 <__umoddi3+0x130>
f01062e0:	39 f7                	cmp    %esi,%edi
f01062e2:	0f 86 a8 00 00 00    	jbe    f0106390 <__umoddi3+0x130>
f01062e8:	89 c8                	mov    %ecx,%eax
f01062ea:	83 c4 1c             	add    $0x1c,%esp
f01062ed:	5b                   	pop    %ebx
f01062ee:	5e                   	pop    %esi
f01062ef:	5f                   	pop    %edi
f01062f0:	5d                   	pop    %ebp
f01062f1:	c3                   	ret    
f01062f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01062f8:	89 e9                	mov    %ebp,%ecx
f01062fa:	ba 20 00 00 00       	mov    $0x20,%edx
f01062ff:	29 ea                	sub    %ebp,%edx
f0106301:	d3 e0                	shl    %cl,%eax
f0106303:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106307:	89 d1                	mov    %edx,%ecx
f0106309:	89 f8                	mov    %edi,%eax
f010630b:	d3 e8                	shr    %cl,%eax
f010630d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0106311:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106315:	8b 54 24 04          	mov    0x4(%esp),%edx
f0106319:	09 c1                	or     %eax,%ecx
f010631b:	89 d8                	mov    %ebx,%eax
f010631d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106321:	89 e9                	mov    %ebp,%ecx
f0106323:	d3 e7                	shl    %cl,%edi
f0106325:	89 d1                	mov    %edx,%ecx
f0106327:	d3 e8                	shr    %cl,%eax
f0106329:	89 e9                	mov    %ebp,%ecx
f010632b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f010632f:	d3 e3                	shl    %cl,%ebx
f0106331:	89 c7                	mov    %eax,%edi
f0106333:	89 d1                	mov    %edx,%ecx
f0106335:	89 f0                	mov    %esi,%eax
f0106337:	d3 e8                	shr    %cl,%eax
f0106339:	89 e9                	mov    %ebp,%ecx
f010633b:	89 fa                	mov    %edi,%edx
f010633d:	d3 e6                	shl    %cl,%esi
f010633f:	09 d8                	or     %ebx,%eax
f0106341:	f7 74 24 08          	divl   0x8(%esp)
f0106345:	89 d1                	mov    %edx,%ecx
f0106347:	89 f3                	mov    %esi,%ebx
f0106349:	f7 64 24 0c          	mull   0xc(%esp)
f010634d:	89 c6                	mov    %eax,%esi
f010634f:	89 d7                	mov    %edx,%edi
f0106351:	39 d1                	cmp    %edx,%ecx
f0106353:	72 06                	jb     f010635b <__umoddi3+0xfb>
f0106355:	75 10                	jne    f0106367 <__umoddi3+0x107>
f0106357:	39 c3                	cmp    %eax,%ebx
f0106359:	73 0c                	jae    f0106367 <__umoddi3+0x107>
f010635b:	2b 44 24 0c          	sub    0xc(%esp),%eax
f010635f:	1b 54 24 08          	sbb    0x8(%esp),%edx
f0106363:	89 d7                	mov    %edx,%edi
f0106365:	89 c6                	mov    %eax,%esi
f0106367:	89 ca                	mov    %ecx,%edx
f0106369:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f010636e:	29 f3                	sub    %esi,%ebx
f0106370:	19 fa                	sbb    %edi,%edx
f0106372:	89 d0                	mov    %edx,%eax
f0106374:	d3 e0                	shl    %cl,%eax
f0106376:	89 e9                	mov    %ebp,%ecx
f0106378:	d3 eb                	shr    %cl,%ebx
f010637a:	d3 ea                	shr    %cl,%edx
f010637c:	09 d8                	or     %ebx,%eax
f010637e:	83 c4 1c             	add    $0x1c,%esp
f0106381:	5b                   	pop    %ebx
f0106382:	5e                   	pop    %esi
f0106383:	5f                   	pop    %edi
f0106384:	5d                   	pop    %ebp
f0106385:	c3                   	ret    
f0106386:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f010638d:	8d 76 00             	lea    0x0(%esi),%esi
f0106390:	89 da                	mov    %ebx,%edx
f0106392:	29 fe                	sub    %edi,%esi
f0106394:	19 c2                	sbb    %eax,%edx
f0106396:	89 f1                	mov    %esi,%ecx
f0106398:	89 c8                	mov    %ecx,%eax
f010639a:	e9 4b ff ff ff       	jmp    f01062ea <__umoddi3+0x8a>
