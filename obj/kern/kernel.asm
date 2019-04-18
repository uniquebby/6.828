
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
f010004b:	68 20 55 10 f0       	push   $0xf0105520
f0100050:	e8 7d 37 00 00       	call   f01037d2 <cprintf>
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
f010006f:	68 3c 55 10 f0       	push   $0xf010553c
f0100074:	e8 59 37 00 00       	call   f01037d2 <cprintf>
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
f010008a:	e8 1d 08 00 00       	call   f01008ac <mon_backtrace>
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
f010009c:	83 3d 00 1f 23 f0 00 	cmpl   $0x0,0xf0231f00
f01000a3:	74 0f                	je     f01000b4 <_panic+0x20>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000a5:	83 ec 0c             	sub    $0xc,%esp
f01000a8:	6a 00                	push   $0x0
f01000aa:	e8 84 08 00 00       	call   f0100933 <monitor>
f01000af:	83 c4 10             	add    $0x10,%esp
f01000b2:	eb f1                	jmp    f01000a5 <_panic+0x11>
	panicstr = fmt;
f01000b4:	89 35 00 1f 23 f0    	mov    %esi,0xf0231f00
	asm volatile("cli; cld");
f01000ba:	fa                   	cli    
f01000bb:	fc                   	cld    
	va_start(ap, fmt);
f01000bc:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f01000bf:	e8 02 4e 00 00       	call   f0104ec6 <cpunum>
f01000c4:	ff 75 0c             	pushl  0xc(%ebp)
f01000c7:	ff 75 08             	pushl  0x8(%ebp)
f01000ca:	50                   	push   %eax
f01000cb:	68 b0 55 10 f0       	push   $0xf01055b0
f01000d0:	e8 fd 36 00 00       	call   f01037d2 <cprintf>
	vcprintf(fmt, ap);
f01000d5:	83 c4 08             	add    $0x8,%esp
f01000d8:	53                   	push   %ebx
f01000d9:	56                   	push   %esi
f01000da:	e8 cd 36 00 00       	call   f01037ac <vcprintf>
	cprintf("\n");
f01000df:	c7 04 24 a3 67 10 f0 	movl   $0xf01067a3,(%esp)
f01000e6:	e8 e7 36 00 00       	call   f01037d2 <cprintf>
f01000eb:	83 c4 10             	add    $0x10,%esp
f01000ee:	eb b5                	jmp    f01000a5 <_panic+0x11>

f01000f0 <i386_init>:
{
f01000f0:	55                   	push   %ebp
f01000f1:	89 e5                	mov    %esp,%ebp
f01000f3:	53                   	push   %ebx
f01000f4:	83 ec 04             	sub    $0x4,%esp
	cons_init();
f01000f7:	e8 6f 05 00 00       	call   f010066b <cons_init>
	cprintf("6828 decimal is %o octal!\n", 6828);
f01000fc:	83 ec 08             	sub    $0x8,%esp
f01000ff:	68 ac 1a 00 00       	push   $0x1aac
f0100104:	68 57 55 10 f0       	push   $0xf0105557
f0100109:	e8 c4 36 00 00       	call   f01037d2 <cprintf>
	test_backtrace(5);
f010010e:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f0100115:	e8 26 ff ff ff       	call   f0100040 <test_backtrace>
	mem_init();
f010011a:	e8 bc 11 00 00       	call   f01012db <mem_init>
	env_init();
f010011f:	e8 00 2f 00 00       	call   f0103024 <env_init>
	trap_init();
f0100124:	e8 1f 37 00 00       	call   f0103848 <trap_init>
	mp_init();
f0100129:	e8 a1 4a 00 00       	call   f0104bcf <mp_init>
	lapic_init();
f010012e:	e8 a9 4d 00 00       	call   f0104edc <lapic_init>
	pic_init();
f0100133:	e8 bb 35 00 00       	call   f01036f3 <pic_init>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100138:	83 c4 10             	add    $0x10,%esp
f010013b:	83 3d 08 1f 23 f0 07 	cmpl   $0x7,0xf0231f08
f0100142:	76 27                	jbe    f010016b <i386_init+0x7b>
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f0100144:	83 ec 04             	sub    $0x4,%esp
f0100147:	b8 32 4b 10 f0       	mov    $0xf0104b32,%eax
f010014c:	2d b8 4a 10 f0       	sub    $0xf0104ab8,%eax
f0100151:	50                   	push   %eax
f0100152:	68 b8 4a 10 f0       	push   $0xf0104ab8
f0100157:	68 00 70 00 f0       	push   $0xf0007000
f010015c:	e8 ae 47 00 00       	call   f010490f <memmove>
f0100161:	83 c4 10             	add    $0x10,%esp
	for (c = cpus; c < cpus + ncpu; c++) {
f0100164:	bb 20 20 23 f0       	mov    $0xf0232020,%ebx
f0100169:	eb 19                	jmp    f0100184 <i386_init+0x94>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010016b:	68 00 70 00 00       	push   $0x7000
f0100170:	68 d4 55 10 f0       	push   $0xf01055d4
f0100175:	6a 5a                	push   $0x5a
f0100177:	68 72 55 10 f0       	push   $0xf0105572
f010017c:	e8 13 ff ff ff       	call   f0100094 <_panic>
f0100181:	83 c3 74             	add    $0x74,%ebx
f0100184:	6b 05 c4 23 23 f0 74 	imul   $0x74,0xf02323c4,%eax
f010018b:	05 20 20 23 f0       	add    $0xf0232020,%eax
f0100190:	39 c3                	cmp    %eax,%ebx
f0100192:	73 4d                	jae    f01001e1 <i386_init+0xf1>
		if (c == cpus + cpunum())  // We've started already.
f0100194:	e8 2d 4d 00 00       	call   f0104ec6 <cpunum>
f0100199:	6b c0 74             	imul   $0x74,%eax,%eax
f010019c:	05 20 20 23 f0       	add    $0xf0232020,%eax
f01001a1:	39 c3                	cmp    %eax,%ebx
f01001a3:	74 dc                	je     f0100181 <i386_init+0x91>
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f01001a5:	89 d8                	mov    %ebx,%eax
f01001a7:	2d 20 20 23 f0       	sub    $0xf0232020,%eax
f01001ac:	c1 f8 02             	sar    $0x2,%eax
f01001af:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f01001b5:	c1 e0 0f             	shl    $0xf,%eax
f01001b8:	8d 80 00 b0 23 f0    	lea    -0xfdc5000(%eax),%eax
f01001be:	a3 04 1f 23 f0       	mov    %eax,0xf0231f04
		lapic_startap(c->cpu_id, PADDR(code));
f01001c3:	83 ec 08             	sub    $0x8,%esp
f01001c6:	68 00 70 00 00       	push   $0x7000
f01001cb:	0f b6 03             	movzbl (%ebx),%eax
f01001ce:	50                   	push   %eax
f01001cf:	e8 5a 4e 00 00       	call   f010502e <lapic_startap>
f01001d4:	83 c4 10             	add    $0x10,%esp
		while(c->cpu_status != CPU_STARTED)
f01001d7:	8b 43 04             	mov    0x4(%ebx),%eax
f01001da:	83 f8 01             	cmp    $0x1,%eax
f01001dd:	75 f8                	jne    f01001d7 <i386_init+0xe7>
f01001df:	eb a0                	jmp    f0100181 <i386_init+0x91>
	ENV_CREATE(user_primes, ENV_TYPE_USER);
f01001e1:	83 ec 08             	sub    $0x8,%esp
f01001e4:	6a 00                	push   $0x0
f01001e6:	68 c0 71 22 f0       	push   $0xf02271c0
f01001eb:	e8 05 30 00 00       	call   f01031f5 <env_create>
	sched_yield();
f01001f0:	e8 7c 3b 00 00       	call   f0103d71 <sched_yield>

f01001f5 <mp_main>:
{
f01001f5:	55                   	push   %ebp
f01001f6:	89 e5                	mov    %esp,%ebp
f01001f8:	83 ec 08             	sub    $0x8,%esp
	lcr3(PADDR(kern_pgdir));
f01001fb:	a1 0c 1f 23 f0       	mov    0xf0231f0c,%eax
	if ((uint32_t)kva < KERNBASE)
f0100200:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100205:	76 46                	jbe    f010024d <mp_main+0x58>
	return (physaddr_t)kva - KERNBASE;
f0100207:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f010020c:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f010020f:	e8 b2 4c 00 00       	call   f0104ec6 <cpunum>
f0100214:	83 ec 08             	sub    $0x8,%esp
f0100217:	50                   	push   %eax
f0100218:	68 7e 55 10 f0       	push   $0xf010557e
f010021d:	e8 b0 35 00 00       	call   f01037d2 <cprintf>
	lapic_init();
f0100222:	e8 b5 4c 00 00       	call   f0104edc <lapic_init>
	env_init_percpu();
f0100227:	e8 cc 2d 00 00       	call   f0102ff8 <env_init_percpu>
	trap_init_percpu();
f010022c:	e8 b5 35 00 00       	call   f01037e6 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100231:	e8 90 4c 00 00       	call   f0104ec6 <cpunum>
f0100236:	6b d0 74             	imul   $0x74,%eax,%edx
f0100239:	83 c2 04             	add    $0x4,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f010023c:	b8 01 00 00 00       	mov    $0x1,%eax
f0100241:	f0 87 82 20 20 23 f0 	lock xchg %eax,-0xfdcdfe0(%edx)
f0100248:	83 c4 10             	add    $0x10,%esp
f010024b:	eb fe                	jmp    f010024b <mp_main+0x56>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010024d:	50                   	push   %eax
f010024e:	68 f8 55 10 f0       	push   $0xf01055f8
f0100253:	6a 71                	push   $0x71
f0100255:	68 72 55 10 f0       	push   $0xf0105572
f010025a:	e8 35 fe ff ff       	call   f0100094 <_panic>

f010025f <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010025f:	55                   	push   %ebp
f0100260:	89 e5                	mov    %esp,%ebp
f0100262:	53                   	push   %ebx
f0100263:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100266:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100269:	ff 75 0c             	pushl  0xc(%ebp)
f010026c:	ff 75 08             	pushl  0x8(%ebp)
f010026f:	68 94 55 10 f0       	push   $0xf0105594
f0100274:	e8 59 35 00 00       	call   f01037d2 <cprintf>
	vcprintf(fmt, ap);
f0100279:	83 c4 08             	add    $0x8,%esp
f010027c:	53                   	push   %ebx
f010027d:	ff 75 10             	pushl  0x10(%ebp)
f0100280:	e8 27 35 00 00       	call   f01037ac <vcprintf>
	cprintf("\n");
f0100285:	c7 04 24 a3 67 10 f0 	movl   $0xf01067a3,(%esp)
f010028c:	e8 41 35 00 00       	call   f01037d2 <cprintf>
	va_end(ap);
}
f0100291:	83 c4 10             	add    $0x10,%esp
f0100294:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100297:	c9                   	leave  
f0100298:	c3                   	ret    

f0100299 <serial_proc_data>:
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100299:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010029e:	ec                   	in     (%dx),%al
static bool serial_exists;

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f010029f:	a8 01                	test   $0x1,%al
f01002a1:	74 0a                	je     f01002ad <serial_proc_data+0x14>
f01002a3:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01002a8:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01002a9:	0f b6 c0             	movzbl %al,%eax
f01002ac:	c3                   	ret    
		return -1;
f01002ad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f01002b2:	c3                   	ret    

f01002b3 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01002b3:	55                   	push   %ebp
f01002b4:	89 e5                	mov    %esp,%ebp
f01002b6:	53                   	push   %ebx
f01002b7:	83 ec 04             	sub    $0x4,%esp
f01002ba:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f01002bc:	ff d3                	call   *%ebx
f01002be:	83 f8 ff             	cmp    $0xffffffff,%eax
f01002c1:	74 29                	je     f01002ec <cons_intr+0x39>
		if (c == 0)
f01002c3:	85 c0                	test   %eax,%eax
f01002c5:	74 f5                	je     f01002bc <cons_intr+0x9>
			continue;
		cons.buf[cons.wpos++] = c;
f01002c7:	8b 0d 24 12 23 f0    	mov    0xf0231224,%ecx
f01002cd:	8d 51 01             	lea    0x1(%ecx),%edx
f01002d0:	88 81 20 10 23 f0    	mov    %al,-0xfdcefe0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f01002d6:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.wpos = 0;
f01002dc:	b8 00 00 00 00       	mov    $0x0,%eax
f01002e1:	0f 44 d0             	cmove  %eax,%edx
f01002e4:	89 15 24 12 23 f0    	mov    %edx,0xf0231224
f01002ea:	eb d0                	jmp    f01002bc <cons_intr+0x9>
	}
}
f01002ec:	83 c4 04             	add    $0x4,%esp
f01002ef:	5b                   	pop    %ebx
f01002f0:	5d                   	pop    %ebp
f01002f1:	c3                   	ret    

f01002f2 <kbd_proc_data>:
{
f01002f2:	55                   	push   %ebp
f01002f3:	89 e5                	mov    %esp,%ebp
f01002f5:	53                   	push   %ebx
f01002f6:	83 ec 04             	sub    $0x4,%esp
f01002f9:	ba 64 00 00 00       	mov    $0x64,%edx
f01002fe:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f01002ff:	a8 01                	test   $0x1,%al
f0100301:	0f 84 f2 00 00 00    	je     f01003f9 <kbd_proc_data+0x107>
	if (stat & KBS_TERR)
f0100307:	a8 20                	test   $0x20,%al
f0100309:	0f 85 f1 00 00 00    	jne    f0100400 <kbd_proc_data+0x10e>
f010030f:	ba 60 00 00 00       	mov    $0x60,%edx
f0100314:	ec                   	in     (%dx),%al
f0100315:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f0100317:	3c e0                	cmp    $0xe0,%al
f0100319:	74 61                	je     f010037c <kbd_proc_data+0x8a>
	} else if (data & 0x80) {
f010031b:	84 c0                	test   %al,%al
f010031d:	78 70                	js     f010038f <kbd_proc_data+0x9d>
	} else if (shift & E0ESC) {
f010031f:	8b 0d 00 10 23 f0    	mov    0xf0231000,%ecx
f0100325:	f6 c1 40             	test   $0x40,%cl
f0100328:	74 0e                	je     f0100338 <kbd_proc_data+0x46>
		data |= 0x80;
f010032a:	83 c8 80             	or     $0xffffff80,%eax
f010032d:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f010032f:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100332:	89 0d 00 10 23 f0    	mov    %ecx,0xf0231000
	shift |= shiftcode[data];
f0100338:	0f b6 d2             	movzbl %dl,%edx
f010033b:	0f b6 82 80 57 10 f0 	movzbl -0xfefa880(%edx),%eax
f0100342:	0b 05 00 10 23 f0    	or     0xf0231000,%eax
	shift ^= togglecode[data];
f0100348:	0f b6 8a 80 56 10 f0 	movzbl -0xfefa980(%edx),%ecx
f010034f:	31 c8                	xor    %ecx,%eax
f0100351:	a3 00 10 23 f0       	mov    %eax,0xf0231000
	c = charcode[shift & (CTL | SHIFT)][data];
f0100356:	89 c1                	mov    %eax,%ecx
f0100358:	83 e1 03             	and    $0x3,%ecx
f010035b:	8b 0c 8d 60 56 10 f0 	mov    -0xfefa9a0(,%ecx,4),%ecx
f0100362:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f0100366:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f0100369:	a8 08                	test   $0x8,%al
f010036b:	74 61                	je     f01003ce <kbd_proc_data+0xdc>
		if ('a' <= c && c <= 'z')
f010036d:	89 da                	mov    %ebx,%edx
f010036f:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f0100372:	83 f9 19             	cmp    $0x19,%ecx
f0100375:	77 4b                	ja     f01003c2 <kbd_proc_data+0xd0>
			c += 'A' - 'a';
f0100377:	83 eb 20             	sub    $0x20,%ebx
f010037a:	eb 0c                	jmp    f0100388 <kbd_proc_data+0x96>
		shift |= E0ESC;
f010037c:	83 0d 00 10 23 f0 40 	orl    $0x40,0xf0231000
		return 0;
f0100383:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f0100388:	89 d8                	mov    %ebx,%eax
f010038a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010038d:	c9                   	leave  
f010038e:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f010038f:	8b 0d 00 10 23 f0    	mov    0xf0231000,%ecx
f0100395:	89 cb                	mov    %ecx,%ebx
f0100397:	83 e3 40             	and    $0x40,%ebx
f010039a:	83 e0 7f             	and    $0x7f,%eax
f010039d:	85 db                	test   %ebx,%ebx
f010039f:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01003a2:	0f b6 d2             	movzbl %dl,%edx
f01003a5:	0f b6 82 80 57 10 f0 	movzbl -0xfefa880(%edx),%eax
f01003ac:	83 c8 40             	or     $0x40,%eax
f01003af:	0f b6 c0             	movzbl %al,%eax
f01003b2:	f7 d0                	not    %eax
f01003b4:	21 c8                	and    %ecx,%eax
f01003b6:	a3 00 10 23 f0       	mov    %eax,0xf0231000
		return 0;
f01003bb:	bb 00 00 00 00       	mov    $0x0,%ebx
f01003c0:	eb c6                	jmp    f0100388 <kbd_proc_data+0x96>
		else if ('A' <= c && c <= 'Z')
f01003c2:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01003c5:	8d 4b 20             	lea    0x20(%ebx),%ecx
f01003c8:	83 fa 1a             	cmp    $0x1a,%edx
f01003cb:	0f 42 d9             	cmovb  %ecx,%ebx
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01003ce:	f7 d0                	not    %eax
f01003d0:	a8 06                	test   $0x6,%al
f01003d2:	75 b4                	jne    f0100388 <kbd_proc_data+0x96>
f01003d4:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01003da:	75 ac                	jne    f0100388 <kbd_proc_data+0x96>
		cprintf("Rebooting!\n");
f01003dc:	83 ec 0c             	sub    $0xc,%esp
f01003df:	68 1c 56 10 f0       	push   $0xf010561c
f01003e4:	e8 e9 33 00 00       	call   f01037d2 <cprintf>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003e9:	b8 03 00 00 00       	mov    $0x3,%eax
f01003ee:	ba 92 00 00 00       	mov    $0x92,%edx
f01003f3:	ee                   	out    %al,(%dx)
f01003f4:	83 c4 10             	add    $0x10,%esp
f01003f7:	eb 8f                	jmp    f0100388 <kbd_proc_data+0x96>
		return -1;
f01003f9:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f01003fe:	eb 88                	jmp    f0100388 <kbd_proc_data+0x96>
		return -1;
f0100400:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f0100405:	eb 81                	jmp    f0100388 <kbd_proc_data+0x96>

f0100407 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100407:	55                   	push   %ebp
f0100408:	89 e5                	mov    %esp,%ebp
f010040a:	57                   	push   %edi
f010040b:	56                   	push   %esi
f010040c:	53                   	push   %ebx
f010040d:	83 ec 1c             	sub    $0x1c,%esp
f0100410:	89 c1                	mov    %eax,%ecx
	for (i = 0;
f0100412:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100417:	bf fd 03 00 00       	mov    $0x3fd,%edi
f010041c:	bb 84 00 00 00       	mov    $0x84,%ebx
f0100421:	89 fa                	mov    %edi,%edx
f0100423:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100424:	a8 20                	test   $0x20,%al
f0100426:	75 13                	jne    f010043b <cons_putc+0x34>
f0100428:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f010042e:	7f 0b                	jg     f010043b <cons_putc+0x34>
f0100430:	89 da                	mov    %ebx,%edx
f0100432:	ec                   	in     (%dx),%al
f0100433:	ec                   	in     (%dx),%al
f0100434:	ec                   	in     (%dx),%al
f0100435:	ec                   	in     (%dx),%al
	     i++)
f0100436:	83 c6 01             	add    $0x1,%esi
f0100439:	eb e6                	jmp    f0100421 <cons_putc+0x1a>
	outb(COM1 + COM_TX, c);
f010043b:	88 4d e7             	mov    %cl,-0x19(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010043e:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100443:	89 c8                	mov    %ecx,%eax
f0100445:	ee                   	out    %al,(%dx)
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100446:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010044b:	bf 79 03 00 00       	mov    $0x379,%edi
f0100450:	bb 84 00 00 00       	mov    $0x84,%ebx
f0100455:	89 fa                	mov    %edi,%edx
f0100457:	ec                   	in     (%dx),%al
f0100458:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f010045e:	7f 0f                	jg     f010046f <cons_putc+0x68>
f0100460:	84 c0                	test   %al,%al
f0100462:	78 0b                	js     f010046f <cons_putc+0x68>
f0100464:	89 da                	mov    %ebx,%edx
f0100466:	ec                   	in     (%dx),%al
f0100467:	ec                   	in     (%dx),%al
f0100468:	ec                   	in     (%dx),%al
f0100469:	ec                   	in     (%dx),%al
f010046a:	83 c6 01             	add    $0x1,%esi
f010046d:	eb e6                	jmp    f0100455 <cons_putc+0x4e>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010046f:	ba 78 03 00 00       	mov    $0x378,%edx
f0100474:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100478:	ee                   	out    %al,(%dx)
f0100479:	ba 7a 03 00 00       	mov    $0x37a,%edx
f010047e:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100483:	ee                   	out    %al,(%dx)
f0100484:	b8 08 00 00 00       	mov    $0x8,%eax
f0100489:	ee                   	out    %al,(%dx)
	if (!(c & ~0xFF))
f010048a:	89 ca                	mov    %ecx,%edx
f010048c:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f0100492:	89 c8                	mov    %ecx,%eax
f0100494:	80 cc 07             	or     $0x7,%ah
f0100497:	85 d2                	test   %edx,%edx
f0100499:	0f 44 c8             	cmove  %eax,%ecx
	switch (c & 0xff) {
f010049c:	0f b6 c1             	movzbl %cl,%eax
f010049f:	83 f8 09             	cmp    $0x9,%eax
f01004a2:	0f 84 b0 00 00 00    	je     f0100558 <cons_putc+0x151>
f01004a8:	7e 73                	jle    f010051d <cons_putc+0x116>
f01004aa:	83 f8 0a             	cmp    $0xa,%eax
f01004ad:	0f 84 98 00 00 00    	je     f010054b <cons_putc+0x144>
f01004b3:	83 f8 0d             	cmp    $0xd,%eax
f01004b6:	0f 85 d3 00 00 00    	jne    f010058f <cons_putc+0x188>
		crt_pos -= (crt_pos % CRT_COLS);
f01004bc:	0f b7 05 28 12 23 f0 	movzwl 0xf0231228,%eax
f01004c3:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01004c9:	c1 e8 16             	shr    $0x16,%eax
f01004cc:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01004cf:	c1 e0 04             	shl    $0x4,%eax
f01004d2:	66 a3 28 12 23 f0    	mov    %ax,0xf0231228
	if (crt_pos >= CRT_SIZE) {
f01004d8:	66 81 3d 28 12 23 f0 	cmpw   $0x7cf,0xf0231228
f01004df:	cf 07 
f01004e1:	0f 87 cb 00 00 00    	ja     f01005b2 <cons_putc+0x1ab>
	outb(addr_6845, 14);
f01004e7:	8b 0d 30 12 23 f0    	mov    0xf0231230,%ecx
f01004ed:	b8 0e 00 00 00       	mov    $0xe,%eax
f01004f2:	89 ca                	mov    %ecx,%edx
f01004f4:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01004f5:	0f b7 1d 28 12 23 f0 	movzwl 0xf0231228,%ebx
f01004fc:	8d 71 01             	lea    0x1(%ecx),%esi
f01004ff:	89 d8                	mov    %ebx,%eax
f0100501:	66 c1 e8 08          	shr    $0x8,%ax
f0100505:	89 f2                	mov    %esi,%edx
f0100507:	ee                   	out    %al,(%dx)
f0100508:	b8 0f 00 00 00       	mov    $0xf,%eax
f010050d:	89 ca                	mov    %ecx,%edx
f010050f:	ee                   	out    %al,(%dx)
f0100510:	89 d8                	mov    %ebx,%eax
f0100512:	89 f2                	mov    %esi,%edx
f0100514:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100515:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100518:	5b                   	pop    %ebx
f0100519:	5e                   	pop    %esi
f010051a:	5f                   	pop    %edi
f010051b:	5d                   	pop    %ebp
f010051c:	c3                   	ret    
	switch (c & 0xff) {
f010051d:	83 f8 08             	cmp    $0x8,%eax
f0100520:	75 6d                	jne    f010058f <cons_putc+0x188>
		if (crt_pos > 0) {
f0100522:	0f b7 05 28 12 23 f0 	movzwl 0xf0231228,%eax
f0100529:	66 85 c0             	test   %ax,%ax
f010052c:	74 b9                	je     f01004e7 <cons_putc+0xe0>
			crt_pos--;
f010052e:	83 e8 01             	sub    $0x1,%eax
f0100531:	66 a3 28 12 23 f0    	mov    %ax,0xf0231228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100537:	0f b7 c0             	movzwl %ax,%eax
f010053a:	b1 00                	mov    $0x0,%cl
f010053c:	83 c9 20             	or     $0x20,%ecx
f010053f:	8b 15 2c 12 23 f0    	mov    0xf023122c,%edx
f0100545:	66 89 0c 42          	mov    %cx,(%edx,%eax,2)
f0100549:	eb 8d                	jmp    f01004d8 <cons_putc+0xd1>
		crt_pos += CRT_COLS;
f010054b:	66 83 05 28 12 23 f0 	addw   $0x50,0xf0231228
f0100552:	50 
f0100553:	e9 64 ff ff ff       	jmp    f01004bc <cons_putc+0xb5>
		cons_putc(' ');
f0100558:	b8 20 00 00 00       	mov    $0x20,%eax
f010055d:	e8 a5 fe ff ff       	call   f0100407 <cons_putc>
		cons_putc(' ');
f0100562:	b8 20 00 00 00       	mov    $0x20,%eax
f0100567:	e8 9b fe ff ff       	call   f0100407 <cons_putc>
		cons_putc(' ');
f010056c:	b8 20 00 00 00       	mov    $0x20,%eax
f0100571:	e8 91 fe ff ff       	call   f0100407 <cons_putc>
		cons_putc(' ');
f0100576:	b8 20 00 00 00       	mov    $0x20,%eax
f010057b:	e8 87 fe ff ff       	call   f0100407 <cons_putc>
		cons_putc(' ');
f0100580:	b8 20 00 00 00       	mov    $0x20,%eax
f0100585:	e8 7d fe ff ff       	call   f0100407 <cons_putc>
f010058a:	e9 49 ff ff ff       	jmp    f01004d8 <cons_putc+0xd1>
		crt_buf[crt_pos++] = c;		/* write the character */
f010058f:	0f b7 05 28 12 23 f0 	movzwl 0xf0231228,%eax
f0100596:	8d 50 01             	lea    0x1(%eax),%edx
f0100599:	66 89 15 28 12 23 f0 	mov    %dx,0xf0231228
f01005a0:	0f b7 c0             	movzwl %ax,%eax
f01005a3:	8b 15 2c 12 23 f0    	mov    0xf023122c,%edx
f01005a9:	66 89 0c 42          	mov    %cx,(%edx,%eax,2)
f01005ad:	e9 26 ff ff ff       	jmp    f01004d8 <cons_putc+0xd1>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01005b2:	a1 2c 12 23 f0       	mov    0xf023122c,%eax
f01005b7:	83 ec 04             	sub    $0x4,%esp
f01005ba:	68 00 0f 00 00       	push   $0xf00
f01005bf:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01005c5:	52                   	push   %edx
f01005c6:	50                   	push   %eax
f01005c7:	e8 43 43 00 00       	call   f010490f <memmove>
			crt_buf[i] = 0x0700 | ' ';
f01005cc:	8b 15 2c 12 23 f0    	mov    0xf023122c,%edx
f01005d2:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f01005d8:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f01005de:	83 c4 10             	add    $0x10,%esp
f01005e1:	66 c7 00 20 07       	movw   $0x720,(%eax)
f01005e6:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01005e9:	39 d0                	cmp    %edx,%eax
f01005eb:	75 f4                	jne    f01005e1 <cons_putc+0x1da>
		crt_pos -= CRT_COLS;
f01005ed:	66 83 2d 28 12 23 f0 	subw   $0x50,0xf0231228
f01005f4:	50 
f01005f5:	e9 ed fe ff ff       	jmp    f01004e7 <cons_putc+0xe0>

f01005fa <serial_intr>:
	if (serial_exists)
f01005fa:	80 3d 34 12 23 f0 00 	cmpb   $0x0,0xf0231234
f0100601:	75 01                	jne    f0100604 <serial_intr+0xa>
f0100603:	c3                   	ret    
{
f0100604:	55                   	push   %ebp
f0100605:	89 e5                	mov    %esp,%ebp
f0100607:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f010060a:	b8 99 02 10 f0       	mov    $0xf0100299,%eax
f010060f:	e8 9f fc ff ff       	call   f01002b3 <cons_intr>
}
f0100614:	c9                   	leave  
f0100615:	c3                   	ret    

f0100616 <kbd_intr>:
{
f0100616:	55                   	push   %ebp
f0100617:	89 e5                	mov    %esp,%ebp
f0100619:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f010061c:	b8 f2 02 10 f0       	mov    $0xf01002f2,%eax
f0100621:	e8 8d fc ff ff       	call   f01002b3 <cons_intr>
}
f0100626:	c9                   	leave  
f0100627:	c3                   	ret    

f0100628 <cons_getc>:
{
f0100628:	55                   	push   %ebp
f0100629:	89 e5                	mov    %esp,%ebp
f010062b:	83 ec 08             	sub    $0x8,%esp
	serial_intr();
f010062e:	e8 c7 ff ff ff       	call   f01005fa <serial_intr>
	kbd_intr();
f0100633:	e8 de ff ff ff       	call   f0100616 <kbd_intr>
	if (cons.rpos != cons.wpos) {
f0100638:	8b 15 20 12 23 f0    	mov    0xf0231220,%edx
	return 0;
f010063e:	b8 00 00 00 00       	mov    $0x0,%eax
	if (cons.rpos != cons.wpos) {
f0100643:	3b 15 24 12 23 f0    	cmp    0xf0231224,%edx
f0100649:	74 1e                	je     f0100669 <cons_getc+0x41>
		c = cons.buf[cons.rpos++];
f010064b:	8d 4a 01             	lea    0x1(%edx),%ecx
f010064e:	0f b6 82 20 10 23 f0 	movzbl -0xfdcefe0(%edx),%eax
			cons.rpos = 0;
f0100655:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f010065b:	ba 00 00 00 00       	mov    $0x0,%edx
f0100660:	0f 44 ca             	cmove  %edx,%ecx
f0100663:	89 0d 20 12 23 f0    	mov    %ecx,0xf0231220
}
f0100669:	c9                   	leave  
f010066a:	c3                   	ret    

f010066b <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f010066b:	55                   	push   %ebp
f010066c:	89 e5                	mov    %esp,%ebp
f010066e:	57                   	push   %edi
f010066f:	56                   	push   %esi
f0100670:	53                   	push   %ebx
f0100671:	83 ec 0c             	sub    $0xc,%esp
	was = *cp;
f0100674:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010067b:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100682:	5a a5 
	if (*cp != 0xA55A) {
f0100684:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010068b:	66 3d 5a a5          	cmp    $0xa55a,%ax
f010068f:	0f 84 d4 00 00 00    	je     f0100769 <cons_init+0xfe>
		addr_6845 = MONO_BASE;
f0100695:	c7 05 30 12 23 f0 b4 	movl   $0x3b4,0xf0231230
f010069c:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010069f:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
	outb(addr_6845, 14);
f01006a4:	8b 3d 30 12 23 f0    	mov    0xf0231230,%edi
f01006aa:	b8 0e 00 00 00       	mov    $0xe,%eax
f01006af:	89 fa                	mov    %edi,%edx
f01006b1:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01006b2:	8d 4f 01             	lea    0x1(%edi),%ecx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006b5:	89 ca                	mov    %ecx,%edx
f01006b7:	ec                   	in     (%dx),%al
f01006b8:	0f b6 c0             	movzbl %al,%eax
f01006bb:	c1 e0 08             	shl    $0x8,%eax
f01006be:	89 c3                	mov    %eax,%ebx
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006c0:	b8 0f 00 00 00       	mov    $0xf,%eax
f01006c5:	89 fa                	mov    %edi,%edx
f01006c7:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006c8:	89 ca                	mov    %ecx,%edx
f01006ca:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f01006cb:	89 35 2c 12 23 f0    	mov    %esi,0xf023122c
	pos |= inb(addr_6845 + 1);
f01006d1:	0f b6 c0             	movzbl %al,%eax
f01006d4:	09 d8                	or     %ebx,%eax
	crt_pos = pos;
f01006d6:	66 a3 28 12 23 f0    	mov    %ax,0xf0231228
	kbd_intr();
f01006dc:	e8 35 ff ff ff       	call   f0100616 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_KBD));
f01006e1:	83 ec 0c             	sub    $0xc,%esp
f01006e4:	0f b7 05 a8 13 12 f0 	movzwl 0xf01213a8,%eax
f01006eb:	25 fd ff 00 00       	and    $0xfffd,%eax
f01006f0:	50                   	push   %eax
f01006f1:	e8 7f 2f 00 00       	call   f0103675 <irq_setmask_8259A>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006f6:	bb 00 00 00 00       	mov    $0x0,%ebx
f01006fb:	b9 fa 03 00 00       	mov    $0x3fa,%ecx
f0100700:	89 d8                	mov    %ebx,%eax
f0100702:	89 ca                	mov    %ecx,%edx
f0100704:	ee                   	out    %al,(%dx)
f0100705:	bf fb 03 00 00       	mov    $0x3fb,%edi
f010070a:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f010070f:	89 fa                	mov    %edi,%edx
f0100711:	ee                   	out    %al,(%dx)
f0100712:	b8 0c 00 00 00       	mov    $0xc,%eax
f0100717:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010071c:	ee                   	out    %al,(%dx)
f010071d:	be f9 03 00 00       	mov    $0x3f9,%esi
f0100722:	89 d8                	mov    %ebx,%eax
f0100724:	89 f2                	mov    %esi,%edx
f0100726:	ee                   	out    %al,(%dx)
f0100727:	b8 03 00 00 00       	mov    $0x3,%eax
f010072c:	89 fa                	mov    %edi,%edx
f010072e:	ee                   	out    %al,(%dx)
f010072f:	ba fc 03 00 00       	mov    $0x3fc,%edx
f0100734:	89 d8                	mov    %ebx,%eax
f0100736:	ee                   	out    %al,(%dx)
f0100737:	b8 01 00 00 00       	mov    $0x1,%eax
f010073c:	89 f2                	mov    %esi,%edx
f010073e:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010073f:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100744:	ec                   	in     (%dx),%al
f0100745:	89 c3                	mov    %eax,%ebx
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100747:	83 c4 10             	add    $0x10,%esp
f010074a:	3c ff                	cmp    $0xff,%al
f010074c:	0f 95 05 34 12 23 f0 	setne  0xf0231234
f0100753:	89 ca                	mov    %ecx,%edx
f0100755:	ec                   	in     (%dx),%al
f0100756:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010075b:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f010075c:	80 fb ff             	cmp    $0xff,%bl
f010075f:	74 23                	je     f0100784 <cons_init+0x119>
		cprintf("Serial port does not exist!\n");
}
f0100761:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100764:	5b                   	pop    %ebx
f0100765:	5e                   	pop    %esi
f0100766:	5f                   	pop    %edi
f0100767:	5d                   	pop    %ebp
f0100768:	c3                   	ret    
		*cp = was;
f0100769:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100770:	c7 05 30 12 23 f0 d4 	movl   $0x3d4,0xf0231230
f0100777:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f010077a:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
f010077f:	e9 20 ff ff ff       	jmp    f01006a4 <cons_init+0x39>
		cprintf("Serial port does not exist!\n");
f0100784:	83 ec 0c             	sub    $0xc,%esp
f0100787:	68 28 56 10 f0       	push   $0xf0105628
f010078c:	e8 41 30 00 00       	call   f01037d2 <cprintf>
f0100791:	83 c4 10             	add    $0x10,%esp
}
f0100794:	eb cb                	jmp    f0100761 <cons_init+0xf6>

f0100796 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100796:	55                   	push   %ebp
f0100797:	89 e5                	mov    %esp,%ebp
f0100799:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f010079c:	8b 45 08             	mov    0x8(%ebp),%eax
f010079f:	e8 63 fc ff ff       	call   f0100407 <cons_putc>
}
f01007a4:	c9                   	leave  
f01007a5:	c3                   	ret    

f01007a6 <getchar>:

int
getchar(void)
{
f01007a6:	55                   	push   %ebp
f01007a7:	89 e5                	mov    %esp,%ebp
f01007a9:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01007ac:	e8 77 fe ff ff       	call   f0100628 <cons_getc>
f01007b1:	85 c0                	test   %eax,%eax
f01007b3:	74 f7                	je     f01007ac <getchar+0x6>
		/* do nothing */;
	return c;
}
f01007b5:	c9                   	leave  
f01007b6:	c3                   	ret    

f01007b7 <iscons>:
int
iscons(int fdnum)
{
	// used by readline
	return 1;
}
f01007b7:	b8 01 00 00 00       	mov    $0x1,%eax
f01007bc:	c3                   	ret    

f01007bd <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01007bd:	55                   	push   %ebp
f01007be:	89 e5                	mov    %esp,%ebp
f01007c0:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01007c3:	68 80 58 10 f0       	push   $0xf0105880
f01007c8:	68 9e 58 10 f0       	push   $0xf010589e
f01007cd:	68 a3 58 10 f0       	push   $0xf01058a3
f01007d2:	e8 fb 2f 00 00       	call   f01037d2 <cprintf>
f01007d7:	83 c4 0c             	add    $0xc,%esp
f01007da:	68 50 59 10 f0       	push   $0xf0105950
f01007df:	68 ac 58 10 f0       	push   $0xf01058ac
f01007e4:	68 a3 58 10 f0       	push   $0xf01058a3
f01007e9:	e8 e4 2f 00 00       	call   f01037d2 <cprintf>
f01007ee:	83 c4 0c             	add    $0xc,%esp
f01007f1:	68 b5 58 10 f0       	push   $0xf01058b5
f01007f6:	68 cc 58 10 f0       	push   $0xf01058cc
f01007fb:	68 a3 58 10 f0       	push   $0xf01058a3
f0100800:	e8 cd 2f 00 00       	call   f01037d2 <cprintf>
	return 0;
}
f0100805:	b8 00 00 00 00       	mov    $0x0,%eax
f010080a:	c9                   	leave  
f010080b:	c3                   	ret    

f010080c <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f010080c:	55                   	push   %ebp
f010080d:	89 e5                	mov    %esp,%ebp
f010080f:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100812:	68 d6 58 10 f0       	push   $0xf01058d6
f0100817:	e8 b6 2f 00 00       	call   f01037d2 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f010081c:	83 c4 08             	add    $0x8,%esp
f010081f:	68 0c 00 10 00       	push   $0x10000c
f0100824:	68 78 59 10 f0       	push   $0xf0105978
f0100829:	e8 a4 2f 00 00       	call   f01037d2 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010082e:	83 c4 0c             	add    $0xc,%esp
f0100831:	68 0c 00 10 00       	push   $0x10000c
f0100836:	68 0c 00 10 f0       	push   $0xf010000c
f010083b:	68 a0 59 10 f0       	push   $0xf01059a0
f0100840:	e8 8d 2f 00 00       	call   f01037d2 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100845:	83 c4 0c             	add    $0xc,%esp
f0100848:	68 0f 55 10 00       	push   $0x10550f
f010084d:	68 0f 55 10 f0       	push   $0xf010550f
f0100852:	68 c4 59 10 f0       	push   $0xf01059c4
f0100857:	e8 76 2f 00 00       	call   f01037d2 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010085c:	83 c4 0c             	add    $0xc,%esp
f010085f:	68 00 10 23 00       	push   $0x231000
f0100864:	68 00 10 23 f0       	push   $0xf0231000
f0100869:	68 e8 59 10 f0       	push   $0xf01059e8
f010086e:	e8 5f 2f 00 00       	call   f01037d2 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100873:	83 c4 0c             	add    $0xc,%esp
f0100876:	68 08 30 27 00       	push   $0x273008
f010087b:	68 08 30 27 f0       	push   $0xf0273008
f0100880:	68 0c 5a 10 f0       	push   $0xf0105a0c
f0100885:	e8 48 2f 00 00       	call   f01037d2 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f010088a:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f010088d:	b8 08 30 27 f0       	mov    $0xf0273008,%eax
f0100892:	2d 0d fc 0f f0       	sub    $0xf00ffc0d,%eax
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100897:	c1 f8 0a             	sar    $0xa,%eax
f010089a:	50                   	push   %eax
f010089b:	68 30 5a 10 f0       	push   $0xf0105a30
f01008a0:	e8 2d 2f 00 00       	call   f01037d2 <cprintf>
	return 0;
}
f01008a5:	b8 00 00 00 00       	mov    $0x0,%eax
f01008aa:	c9                   	leave  
f01008ab:	c3                   	ret    

f01008ac <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01008ac:	55                   	push   %ebp
f01008ad:	89 e5                	mov    %esp,%ebp
f01008af:	57                   	push   %edi
f01008b0:	56                   	push   %esi
f01008b1:	53                   	push   %ebx
f01008b2:	83 ec 38             	sub    $0x38,%esp
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f01008b5:	89 eb                	mov    %ebp,%ebx
	// Your code here.
	uint32_t ebp, *ptr_ebp;
	ebp = read_ebp();
	cprintf("Stack backtrace:\n");
f01008b7:	68 ef 58 10 f0       	push   $0xf01058ef
f01008bc:	e8 11 2f 00 00       	call   f01037d2 <cprintf>
	while (ebp != 0) {
f01008c1:	83 c4 10             	add    $0x10,%esp
		ptr_ebp = (uint32_t *)ebp;
		cprintf(" ebp %x  eip %x  args %08x %08x %08x %08x %08x\n", 
        		ebp, ptr_ebp[1], ptr_ebp[2], ptr_ebp[3], ptr_ebp[4], ptr_ebp[5], ptr_ebp[6]);
		struct Eipdebuginfo info;
		if (debuginfo_eip(ptr_ebp[1], &info) == 0) {
f01008c4:	8d 7d d0             	lea    -0x30(%ebp),%edi
	while (ebp != 0) {
f01008c7:	eb 25                	jmp    f01008ee <mon_backtrace+0x42>
			uint32_t fn_offset = ptr_ebp[1] - info.eip_fn_addr; 
			cprintf(" \t%s:%d: %.*s+%d\n", info.eip_file, info.eip_line\
f01008c9:	83 ec 08             	sub    $0x8,%esp
			uint32_t fn_offset = ptr_ebp[1] - info.eip_fn_addr; 
f01008cc:	8b 43 04             	mov    0x4(%ebx),%eax
f01008cf:	2b 45 e0             	sub    -0x20(%ebp),%eax
			cprintf(" \t%s:%d: %.*s+%d\n", info.eip_file, info.eip_line\
f01008d2:	50                   	push   %eax
f01008d3:	ff 75 d8             	pushl  -0x28(%ebp)
f01008d6:	ff 75 dc             	pushl  -0x24(%ebp)
f01008d9:	ff 75 d4             	pushl  -0x2c(%ebp)
f01008dc:	ff 75 d0             	pushl  -0x30(%ebp)
f01008df:	68 01 59 10 f0       	push   $0xf0105901
f01008e4:	e8 e9 2e 00 00       	call   f01037d2 <cprintf>
f01008e9:	83 c4 20             	add    $0x20,%esp
							, info.eip_fn_namelen, info.eip_fn_name, fn_offset);
		}
		ebp = *ptr_ebp;
f01008ec:	8b 1e                	mov    (%esi),%ebx
	while (ebp != 0) {
f01008ee:	85 db                	test   %ebx,%ebx
f01008f0:	74 34                	je     f0100926 <mon_backtrace+0x7a>
		ptr_ebp = (uint32_t *)ebp;
f01008f2:	89 de                	mov    %ebx,%esi
		cprintf(" ebp %x  eip %x  args %08x %08x %08x %08x %08x\n", 
f01008f4:	ff 73 18             	pushl  0x18(%ebx)
f01008f7:	ff 73 14             	pushl  0x14(%ebx)
f01008fa:	ff 73 10             	pushl  0x10(%ebx)
f01008fd:	ff 73 0c             	pushl  0xc(%ebx)
f0100900:	ff 73 08             	pushl  0x8(%ebx)
f0100903:	ff 73 04             	pushl  0x4(%ebx)
f0100906:	53                   	push   %ebx
f0100907:	68 5c 5a 10 f0       	push   $0xf0105a5c
f010090c:	e8 c1 2e 00 00       	call   f01037d2 <cprintf>
		if (debuginfo_eip(ptr_ebp[1], &info) == 0) {
f0100911:	83 c4 18             	add    $0x18,%esp
f0100914:	57                   	push   %edi
f0100915:	ff 73 04             	pushl  0x4(%ebx)
f0100918:	e8 6b 35 00 00       	call   f0103e88 <debuginfo_eip>
f010091d:	83 c4 10             	add    $0x10,%esp
f0100920:	85 c0                	test   %eax,%eax
f0100922:	75 c8                	jne    f01008ec <mon_backtrace+0x40>
f0100924:	eb a3                	jmp    f01008c9 <mon_backtrace+0x1d>
	}
	return 0;
}
f0100926:	b8 00 00 00 00       	mov    $0x0,%eax
f010092b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010092e:	5b                   	pop    %ebx
f010092f:	5e                   	pop    %esi
f0100930:	5f                   	pop    %edi
f0100931:	5d                   	pop    %ebp
f0100932:	c3                   	ret    

f0100933 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100933:	55                   	push   %ebp
f0100934:	89 e5                	mov    %esp,%ebp
f0100936:	57                   	push   %edi
f0100937:	56                   	push   %esi
f0100938:	53                   	push   %ebx
f0100939:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f010093c:	68 8c 5a 10 f0       	push   $0xf0105a8c
f0100941:	e8 8c 2e 00 00       	call   f01037d2 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100946:	c7 04 24 b0 5a 10 f0 	movl   $0xf0105ab0,(%esp)
f010094d:	e8 80 2e 00 00       	call   f01037d2 <cprintf>

	if (tf != NULL)
f0100952:	83 c4 10             	add    $0x10,%esp
f0100955:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100959:	0f 84 d9 00 00 00    	je     f0100a38 <monitor+0x105>
		print_trapframe(tf);
f010095f:	83 ec 0c             	sub    $0xc,%esp
f0100962:	ff 75 08             	pushl  0x8(%ebp)
f0100965:	e8 79 2f 00 00       	call   f01038e3 <print_trapframe>
f010096a:	83 c4 10             	add    $0x10,%esp
f010096d:	e9 c6 00 00 00       	jmp    f0100a38 <monitor+0x105>
		while (*buf && strchr(WHITESPACE, *buf))
f0100972:	83 ec 08             	sub    $0x8,%esp
f0100975:	0f be c0             	movsbl %al,%eax
f0100978:	50                   	push   %eax
f0100979:	68 17 59 10 f0       	push   $0xf0105917
f010097e:	e8 07 3f 00 00       	call   f010488a <strchr>
f0100983:	83 c4 10             	add    $0x10,%esp
f0100986:	85 c0                	test   %eax,%eax
f0100988:	74 63                	je     f01009ed <monitor+0xba>
			*buf++ = 0;
f010098a:	c6 03 00             	movb   $0x0,(%ebx)
f010098d:	89 f7                	mov    %esi,%edi
f010098f:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100992:	89 fe                	mov    %edi,%esi
		while (*buf && strchr(WHITESPACE, *buf))
f0100994:	0f b6 03             	movzbl (%ebx),%eax
f0100997:	84 c0                	test   %al,%al
f0100999:	75 d7                	jne    f0100972 <monitor+0x3f>
	argv[argc] = 0;
f010099b:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f01009a2:	00 
	if (argc == 0)
f01009a3:	85 f6                	test   %esi,%esi
f01009a5:	0f 84 8d 00 00 00    	je     f0100a38 <monitor+0x105>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f01009ab:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (strcmp(argv[0], commands[i].name) == 0)
f01009b0:	83 ec 08             	sub    $0x8,%esp
f01009b3:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f01009b6:	ff 34 85 e0 5a 10 f0 	pushl  -0xfefa520(,%eax,4)
f01009bd:	ff 75 a8             	pushl  -0x58(%ebp)
f01009c0:	e8 67 3e 00 00       	call   f010482c <strcmp>
f01009c5:	83 c4 10             	add    $0x10,%esp
f01009c8:	85 c0                	test   %eax,%eax
f01009ca:	0f 84 8f 00 00 00    	je     f0100a5f <monitor+0x12c>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f01009d0:	83 c3 01             	add    $0x1,%ebx
f01009d3:	83 fb 03             	cmp    $0x3,%ebx
f01009d6:	75 d8                	jne    f01009b0 <monitor+0x7d>
	cprintf("Unknown command '%s'\n", argv[0]);
f01009d8:	83 ec 08             	sub    $0x8,%esp
f01009db:	ff 75 a8             	pushl  -0x58(%ebp)
f01009de:	68 39 59 10 f0       	push   $0xf0105939
f01009e3:	e8 ea 2d 00 00       	call   f01037d2 <cprintf>
f01009e8:	83 c4 10             	add    $0x10,%esp
f01009eb:	eb 4b                	jmp    f0100a38 <monitor+0x105>
		if (*buf == 0)
f01009ed:	80 3b 00             	cmpb   $0x0,(%ebx)
f01009f0:	74 a9                	je     f010099b <monitor+0x68>
		if (argc == MAXARGS-1) {
f01009f2:	83 fe 0f             	cmp    $0xf,%esi
f01009f5:	74 2f                	je     f0100a26 <monitor+0xf3>
		argv[argc++] = buf;
f01009f7:	8d 7e 01             	lea    0x1(%esi),%edi
f01009fa:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
		while (*buf && !strchr(WHITESPACE, *buf))
f01009fe:	0f b6 03             	movzbl (%ebx),%eax
f0100a01:	84 c0                	test   %al,%al
f0100a03:	74 8d                	je     f0100992 <monitor+0x5f>
f0100a05:	83 ec 08             	sub    $0x8,%esp
f0100a08:	0f be c0             	movsbl %al,%eax
f0100a0b:	50                   	push   %eax
f0100a0c:	68 17 59 10 f0       	push   $0xf0105917
f0100a11:	e8 74 3e 00 00       	call   f010488a <strchr>
f0100a16:	83 c4 10             	add    $0x10,%esp
f0100a19:	85 c0                	test   %eax,%eax
f0100a1b:	0f 85 71 ff ff ff    	jne    f0100992 <monitor+0x5f>
			buf++;
f0100a21:	83 c3 01             	add    $0x1,%ebx
f0100a24:	eb d8                	jmp    f01009fe <monitor+0xcb>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100a26:	83 ec 08             	sub    $0x8,%esp
f0100a29:	6a 10                	push   $0x10
f0100a2b:	68 1c 59 10 f0       	push   $0xf010591c
f0100a30:	e8 9d 2d 00 00       	call   f01037d2 <cprintf>
f0100a35:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f0100a38:	83 ec 0c             	sub    $0xc,%esp
f0100a3b:	68 13 59 10 f0       	push   $0xf0105913
f0100a40:	e8 21 3c 00 00       	call   f0104666 <readline>
f0100a45:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100a47:	83 c4 10             	add    $0x10,%esp
f0100a4a:	85 c0                	test   %eax,%eax
f0100a4c:	74 ea                	je     f0100a38 <monitor+0x105>
	argv[argc] = 0;
f0100a4e:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f0100a55:	be 00 00 00 00       	mov    $0x0,%esi
f0100a5a:	e9 35 ff ff ff       	jmp    f0100994 <monitor+0x61>
			return commands[i].func(argc, argv, tf);
f0100a5f:	83 ec 04             	sub    $0x4,%esp
f0100a62:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100a65:	ff 75 08             	pushl  0x8(%ebp)
f0100a68:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100a6b:	52                   	push   %edx
f0100a6c:	56                   	push   %esi
f0100a6d:	ff 14 85 e8 5a 10 f0 	call   *-0xfefa518(,%eax,4)
			if (runcmd(buf, tf) < 0)
f0100a74:	83 c4 10             	add    $0x10,%esp
f0100a77:	85 c0                	test   %eax,%eax
f0100a79:	79 bd                	jns    f0100a38 <monitor+0x105>
				break;
	}
}
f0100a7b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100a7e:	5b                   	pop    %ebx
f0100a7f:	5e                   	pop    %esi
f0100a80:	5f                   	pop    %edi
f0100a81:	5d                   	pop    %ebp
f0100a82:	c3                   	ret    

f0100a83 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100a83:	89 c2                	mov    %eax,%edx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100a85:	83 3d 38 12 23 f0 00 	cmpl   $0x0,0xf0231238
f0100a8c:	74 1a                	je     f0100aa8 <boot_alloc+0x25>
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	//cprintf("nextfree:%p\n", nextfree);
	result = nextfree;
f0100a8e:	a1 38 12 23 f0       	mov    0xf0231238,%eax
	nextfree += ROUNDUP(n, PGSIZE);
f0100a93:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
f0100a99:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100a9f:	01 c2                	add    %eax,%edx
f0100aa1:	89 15 38 12 23 f0    	mov    %edx,0xf0231238
	return result;
}
f0100aa7:	c3                   	ret    
		nextfree = ROUNDUP((char *) end, PGSIZE);		
f0100aa8:	b8 07 40 27 f0       	mov    $0xf0274007,%eax
f0100aad:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100ab2:	a3 38 12 23 f0       	mov    %eax,0xf0231238
f0100ab7:	eb d5                	jmp    f0100a8e <boot_alloc+0xb>

f0100ab9 <nvram_read>:
{
f0100ab9:	55                   	push   %ebp
f0100aba:	89 e5                	mov    %esp,%ebp
f0100abc:	56                   	push   %esi
f0100abd:	53                   	push   %ebx
f0100abe:	89 c6                	mov    %eax,%esi
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100ac0:	83 ec 0c             	sub    $0xc,%esp
f0100ac3:	50                   	push   %eax
f0100ac4:	e8 7e 2b 00 00       	call   f0103647 <mc146818_read>
f0100ac9:	89 c3                	mov    %eax,%ebx
f0100acb:	83 c6 01             	add    $0x1,%esi
f0100ace:	89 34 24             	mov    %esi,(%esp)
f0100ad1:	e8 71 2b 00 00       	call   f0103647 <mc146818_read>
f0100ad6:	c1 e0 08             	shl    $0x8,%eax
f0100ad9:	09 d8                	or     %ebx,%eax
}
f0100adb:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100ade:	5b                   	pop    %ebx
f0100adf:	5e                   	pop    %esi
f0100ae0:	5d                   	pop    %ebp
f0100ae1:	c3                   	ret    

f0100ae2 <check_va2pa>:

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;
	pgdir = &pgdir[PDX(va)];
f0100ae2:	89 d1                	mov    %edx,%ecx
f0100ae4:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100ae7:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100aea:	a8 01                	test   $0x1,%al
f0100aec:	74 52                	je     f0100b40 <check_va2pa+0x5e>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100aee:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0100af3:	89 c1                	mov    %eax,%ecx
f0100af5:	c1 e9 0c             	shr    $0xc,%ecx
f0100af8:	3b 0d 08 1f 23 f0    	cmp    0xf0231f08,%ecx
f0100afe:	73 25                	jae    f0100b25 <check_va2pa+0x43>
	if (!(p[PTX(va)] & PTE_P))
f0100b00:	c1 ea 0c             	shr    $0xc,%edx
f0100b03:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100b09:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100b10:	89 c2                	mov    %eax,%edx
f0100b12:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100b15:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b1a:	85 d2                	test   %edx,%edx
f0100b1c:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100b21:	0f 44 c2             	cmove  %edx,%eax
f0100b24:	c3                   	ret    
{
f0100b25:	55                   	push   %ebp
f0100b26:	89 e5                	mov    %esp,%ebp
f0100b28:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100b2b:	50                   	push   %eax
f0100b2c:	68 d4 55 10 f0       	push   $0xf01055d4
f0100b31:	68 a0 03 00 00       	push   $0x3a0
f0100b36:	68 9d 64 10 f0       	push   $0xf010649d
f0100b3b:	e8 54 f5 ff ff       	call   f0100094 <_panic>
		return ~0;
f0100b40:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f0100b45:	c3                   	ret    

f0100b46 <check_page_free_list>:
{
f0100b46:	55                   	push   %ebp
f0100b47:	89 e5                	mov    %esp,%ebp
f0100b49:	57                   	push   %edi
f0100b4a:	56                   	push   %esi
f0100b4b:	53                   	push   %ebx
f0100b4c:	83 ec 2c             	sub    $0x2c,%esp
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100b4f:	84 c0                	test   %al,%al
f0100b51:	0f 85 77 02 00 00    	jne    f0100dce <check_page_free_list+0x288>
	if (!page_free_list)
f0100b57:	83 3d 3c 12 23 f0 00 	cmpl   $0x0,0xf023123c
f0100b5e:	74 0a                	je     f0100b6a <check_page_free_list+0x24>
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100b60:	be 00 04 00 00       	mov    $0x400,%esi
f0100b65:	e9 d1 02 00 00       	jmp    f0100e3b <check_page_free_list+0x2f5>
		panic("'page_free_list' is a null pointer!");
f0100b6a:	83 ec 04             	sub    $0x4,%esp
f0100b6d:	68 04 5b 10 f0       	push   $0xf0105b04
f0100b72:	68 c6 02 00 00       	push   $0x2c6
f0100b77:	68 9d 64 10 f0       	push   $0xf010649d
f0100b7c:	e8 13 f5 ff ff       	call   f0100094 <_panic>
f0100b81:	50                   	push   %eax
f0100b82:	68 d4 55 10 f0       	push   $0xf01055d4
f0100b87:	6a 58                	push   $0x58
f0100b89:	68 b0 64 10 f0       	push   $0xf01064b0
f0100b8e:	e8 01 f5 ff ff       	call   f0100094 <_panic>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100b93:	8b 1b                	mov    (%ebx),%ebx
f0100b95:	85 db                	test   %ebx,%ebx
f0100b97:	74 41                	je     f0100bda <check_page_free_list+0x94>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100b99:	89 d8                	mov    %ebx,%eax
f0100b9b:	2b 05 10 1f 23 f0    	sub    0xf0231f10,%eax
f0100ba1:	c1 f8 03             	sar    $0x3,%eax
f0100ba4:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100ba7:	89 c2                	mov    %eax,%edx
f0100ba9:	c1 ea 16             	shr    $0x16,%edx
f0100bac:	39 f2                	cmp    %esi,%edx
f0100bae:	73 e3                	jae    f0100b93 <check_page_free_list+0x4d>
	if (PGNUM(pa) >= npages)
f0100bb0:	89 c2                	mov    %eax,%edx
f0100bb2:	c1 ea 0c             	shr    $0xc,%edx
f0100bb5:	3b 15 08 1f 23 f0    	cmp    0xf0231f08,%edx
f0100bbb:	73 c4                	jae    f0100b81 <check_page_free_list+0x3b>
			memset(page2kva(pp), 0x97, 128);
f0100bbd:	83 ec 04             	sub    $0x4,%esp
f0100bc0:	68 80 00 00 00       	push   $0x80
f0100bc5:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0100bca:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100bcf:	50                   	push   %eax
f0100bd0:	e8 f2 3c 00 00       	call   f01048c7 <memset>
f0100bd5:	83 c4 10             	add    $0x10,%esp
f0100bd8:	eb b9                	jmp    f0100b93 <check_page_free_list+0x4d>
	first_free_page = (char *) boot_alloc(0);
f0100bda:	b8 00 00 00 00       	mov    $0x0,%eax
f0100bdf:	e8 9f fe ff ff       	call   f0100a83 <boot_alloc>
f0100be4:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100be7:	8b 15 3c 12 23 f0    	mov    0xf023123c,%edx
		assert(pp >= pages);
f0100bed:	8b 0d 10 1f 23 f0    	mov    0xf0231f10,%ecx
		assert(pp < pages + npages);
f0100bf3:	a1 08 1f 23 f0       	mov    0xf0231f08,%eax
f0100bf8:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100bfb:	8d 34 c1             	lea    (%ecx,%eax,8),%esi
	int nfree_basemem = 0, nfree_extmem = 0;
f0100bfe:	bf 00 00 00 00       	mov    $0x0,%edi
f0100c03:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c06:	e9 f9 00 00 00       	jmp    f0100d04 <check_page_free_list+0x1be>
		assert(pp >= pages);
f0100c0b:	68 be 64 10 f0       	push   $0xf01064be
f0100c10:	68 ca 64 10 f0       	push   $0xf01064ca
f0100c15:	68 e3 02 00 00       	push   $0x2e3
f0100c1a:	68 9d 64 10 f0       	push   $0xf010649d
f0100c1f:	e8 70 f4 ff ff       	call   f0100094 <_panic>
		assert(pp < pages + npages);
f0100c24:	68 df 64 10 f0       	push   $0xf01064df
f0100c29:	68 ca 64 10 f0       	push   $0xf01064ca
f0100c2e:	68 e4 02 00 00       	push   $0x2e4
f0100c33:	68 9d 64 10 f0       	push   $0xf010649d
f0100c38:	e8 57 f4 ff ff       	call   f0100094 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100c3d:	68 28 5b 10 f0       	push   $0xf0105b28
f0100c42:	68 ca 64 10 f0       	push   $0xf01064ca
f0100c47:	68 e5 02 00 00       	push   $0x2e5
f0100c4c:	68 9d 64 10 f0       	push   $0xf010649d
f0100c51:	e8 3e f4 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != 0);
f0100c56:	68 f3 64 10 f0       	push   $0xf01064f3
f0100c5b:	68 ca 64 10 f0       	push   $0xf01064ca
f0100c60:	68 e8 02 00 00       	push   $0x2e8
f0100c65:	68 9d 64 10 f0       	push   $0xf010649d
f0100c6a:	e8 25 f4 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100c6f:	68 04 65 10 f0       	push   $0xf0106504
f0100c74:	68 ca 64 10 f0       	push   $0xf01064ca
f0100c79:	68 e9 02 00 00       	push   $0x2e9
f0100c7e:	68 9d 64 10 f0       	push   $0xf010649d
f0100c83:	e8 0c f4 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100c88:	68 5c 5b 10 f0       	push   $0xf0105b5c
f0100c8d:	68 ca 64 10 f0       	push   $0xf01064ca
f0100c92:	68 ea 02 00 00       	push   $0x2ea
f0100c97:	68 9d 64 10 f0       	push   $0xf010649d
f0100c9c:	e8 f3 f3 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100ca1:	68 1d 65 10 f0       	push   $0xf010651d
f0100ca6:	68 ca 64 10 f0       	push   $0xf01064ca
f0100cab:	68 eb 02 00 00       	push   $0x2eb
f0100cb0:	68 9d 64 10 f0       	push   $0xf010649d
f0100cb5:	e8 da f3 ff ff       	call   f0100094 <_panic>
	if (PGNUM(pa) >= npages)
f0100cba:	89 c3                	mov    %eax,%ebx
f0100cbc:	c1 eb 0c             	shr    $0xc,%ebx
f0100cbf:	39 5d d0             	cmp    %ebx,-0x30(%ebp)
f0100cc2:	76 0f                	jbe    f0100cd3 <check_page_free_list+0x18d>
	return (void *)(pa + KERNBASE);
f0100cc4:	2d 00 00 00 10       	sub    $0x10000000,%eax
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100cc9:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0100ccc:	77 17                	ja     f0100ce5 <check_page_free_list+0x19f>
			++nfree_extmem;
f0100cce:	83 c7 01             	add    $0x1,%edi
f0100cd1:	eb 2f                	jmp    f0100d02 <check_page_free_list+0x1bc>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100cd3:	50                   	push   %eax
f0100cd4:	68 d4 55 10 f0       	push   $0xf01055d4
f0100cd9:	6a 58                	push   $0x58
f0100cdb:	68 b0 64 10 f0       	push   $0xf01064b0
f0100ce0:	e8 af f3 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100ce5:	68 80 5b 10 f0       	push   $0xf0105b80
f0100cea:	68 ca 64 10 f0       	push   $0xf01064ca
f0100cef:	68 ec 02 00 00       	push   $0x2ec
f0100cf4:	68 9d 64 10 f0       	push   $0xf010649d
f0100cf9:	e8 96 f3 ff ff       	call   f0100094 <_panic>
			++nfree_basemem;
f0100cfe:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100d02:	8b 12                	mov    (%edx),%edx
f0100d04:	85 d2                	test   %edx,%edx
f0100d06:	74 74                	je     f0100d7c <check_page_free_list+0x236>
		assert(pp >= pages);
f0100d08:	39 d1                	cmp    %edx,%ecx
f0100d0a:	0f 87 fb fe ff ff    	ja     f0100c0b <check_page_free_list+0xc5>
		assert(pp < pages + npages);
f0100d10:	39 d6                	cmp    %edx,%esi
f0100d12:	0f 86 0c ff ff ff    	jbe    f0100c24 <check_page_free_list+0xde>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100d18:	89 d0                	mov    %edx,%eax
f0100d1a:	29 c8                	sub    %ecx,%eax
f0100d1c:	a8 07                	test   $0x7,%al
f0100d1e:	0f 85 19 ff ff ff    	jne    f0100c3d <check_page_free_list+0xf7>
	return (pp - pages) << PGSHIFT;
f0100d24:	c1 f8 03             	sar    $0x3,%eax
		assert(page2pa(pp) != 0);
f0100d27:	c1 e0 0c             	shl    $0xc,%eax
f0100d2a:	0f 84 26 ff ff ff    	je     f0100c56 <check_page_free_list+0x110>
		assert(page2pa(pp) != IOPHYSMEM);
f0100d30:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100d35:	0f 84 34 ff ff ff    	je     f0100c6f <check_page_free_list+0x129>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100d3b:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100d40:	0f 84 42 ff ff ff    	je     f0100c88 <check_page_free_list+0x142>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100d46:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100d4b:	0f 84 50 ff ff ff    	je     f0100ca1 <check_page_free_list+0x15b>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100d51:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100d56:	0f 87 5e ff ff ff    	ja     f0100cba <check_page_free_list+0x174>
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100d5c:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100d61:	75 9b                	jne    f0100cfe <check_page_free_list+0x1b8>
f0100d63:	68 37 65 10 f0       	push   $0xf0106537
f0100d68:	68 ca 64 10 f0       	push   $0xf01064ca
f0100d6d:	68 ee 02 00 00       	push   $0x2ee
f0100d72:	68 9d 64 10 f0       	push   $0xf010649d
f0100d77:	e8 18 f3 ff ff       	call   f0100094 <_panic>
f0100d7c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
	assert(nfree_basemem > 0);
f0100d7f:	85 db                	test   %ebx,%ebx
f0100d81:	7e 19                	jle    f0100d9c <check_page_free_list+0x256>
	assert(nfree_extmem > 0);
f0100d83:	85 ff                	test   %edi,%edi
f0100d85:	7e 2e                	jle    f0100db5 <check_page_free_list+0x26f>
	cprintf("check_page_free_list() succeeded!\n");
f0100d87:	83 ec 0c             	sub    $0xc,%esp
f0100d8a:	68 c8 5b 10 f0       	push   $0xf0105bc8
f0100d8f:	e8 3e 2a 00 00       	call   f01037d2 <cprintf>
}
f0100d94:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100d97:	5b                   	pop    %ebx
f0100d98:	5e                   	pop    %esi
f0100d99:	5f                   	pop    %edi
f0100d9a:	5d                   	pop    %ebp
f0100d9b:	c3                   	ret    
	assert(nfree_basemem > 0);
f0100d9c:	68 54 65 10 f0       	push   $0xf0106554
f0100da1:	68 ca 64 10 f0       	push   $0xf01064ca
f0100da6:	68 f6 02 00 00       	push   $0x2f6
f0100dab:	68 9d 64 10 f0       	push   $0xf010649d
f0100db0:	e8 df f2 ff ff       	call   f0100094 <_panic>
	assert(nfree_extmem > 0);
f0100db5:	68 66 65 10 f0       	push   $0xf0106566
f0100dba:	68 ca 64 10 f0       	push   $0xf01064ca
f0100dbf:	68 f7 02 00 00       	push   $0x2f7
f0100dc4:	68 9d 64 10 f0       	push   $0xf010649d
f0100dc9:	e8 c6 f2 ff ff       	call   f0100094 <_panic>
	if (!page_free_list)
f0100dce:	a1 3c 12 23 f0       	mov    0xf023123c,%eax
f0100dd3:	85 c0                	test   %eax,%eax
f0100dd5:	0f 84 8f fd ff ff    	je     f0100b6a <check_page_free_list+0x24>
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100ddb:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100dde:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100de1:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100de4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100de7:	89 c2                	mov    %eax,%edx
f0100de9:	2b 15 10 1f 23 f0    	sub    0xf0231f10,%edx
			pagetype = (PDX(page2pa(pp)) >= pdx_limit);
f0100def:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100df5:	0f 95 c2             	setne  %dl
f0100df8:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100dfb:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100dff:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100e01:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100e05:	8b 00                	mov    (%eax),%eax
f0100e07:	85 c0                	test   %eax,%eax
f0100e09:	75 dc                	jne    f0100de7 <check_page_free_list+0x2a1>
		cprintf("end%p\n",pp);
f0100e0b:	83 ec 08             	sub    $0x8,%esp
f0100e0e:	6a 00                	push   $0x0
f0100e10:	68 a9 64 10 f0       	push   $0xf01064a9
f0100e15:	e8 b8 29 00 00       	call   f01037d2 <cprintf>
		*tp[1] = 0;
f0100e1a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100e1d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100e23:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100e26:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100e29:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100e2b:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100e2e:	a3 3c 12 23 f0       	mov    %eax,0xf023123c
f0100e33:	83 c4 10             	add    $0x10,%esp
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100e36:	be 01 00 00 00       	mov    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100e3b:	8b 1d 3c 12 23 f0    	mov    0xf023123c,%ebx
f0100e41:	e9 4f fd ff ff       	jmp    f0100b95 <check_page_free_list+0x4f>

f0100e46 <page_init>:
{
f0100e46:	55                   	push   %ebp
f0100e47:	89 e5                	mov    %esp,%ebp
f0100e49:	56                   	push   %esi
f0100e4a:	53                   	push   %ebx
	pages[0].pp_ref = 1;
f0100e4b:	a1 10 1f 23 f0       	mov    0xf0231f10,%eax
f0100e50:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
    for (i = 1; i < npages_basemem; i++) {
f0100e56:	bb 01 00 00 00       	mov    $0x1,%ebx
f0100e5b:	eb 3c                	jmp    f0100e99 <page_init+0x53>
f0100e5d:	8d 34 dd 00 00 00 00 	lea    0x0(,%ebx,8),%esi
        pages[i].pp_ref = 0;
f0100e64:	89 f2                	mov    %esi,%edx
f0100e66:	03 15 10 1f 23 f0    	add    0xf0231f10,%edx
f0100e6c:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
        pages[i].pp_link = page_free_list;
f0100e72:	a1 3c 12 23 f0       	mov    0xf023123c,%eax
f0100e77:	89 02                	mov    %eax,(%edx)
		cprintf("page_init:%p\n", page_free_list);
f0100e79:	83 ec 08             	sub    $0x8,%esp
f0100e7c:	50                   	push   %eax
f0100e7d:	68 77 65 10 f0       	push   $0xf0106577
f0100e82:	e8 4b 29 00 00       	call   f01037d2 <cprintf>
        page_free_list = &pages[i];
f0100e87:	03 35 10 1f 23 f0    	add    0xf0231f10,%esi
f0100e8d:	89 35 3c 12 23 f0    	mov    %esi,0xf023123c
f0100e93:	83 c4 10             	add    $0x10,%esp
    for (i = 1; i < npages_basemem; i++) {
f0100e96:	83 c3 01             	add    $0x1,%ebx
f0100e99:	39 1d 40 12 23 f0    	cmp    %ebx,0xf0231240
f0100e9f:	76 12                	jbe    f0100eb3 <page_init+0x6d>
		if (i == MPENTRY_PADDR/PGSIZE) {
f0100ea1:	83 fb 07             	cmp    $0x7,%ebx
f0100ea4:	75 b7                	jne    f0100e5d <page_init+0x17>
			 pages[i].pp_ref = 1;
f0100ea6:	a1 10 1f 23 f0       	mov    0xf0231f10,%eax
f0100eab:	66 c7 40 3c 01 00    	movw   $0x1,0x3c(%eax)
			 continue;
f0100eb1:	eb e3                	jmp    f0100e96 <page_init+0x50>
	size_t first_free_address = PADDR(boot_alloc(0));
f0100eb3:	b8 00 00 00 00       	mov    $0x0,%eax
f0100eb8:	e8 c6 fb ff ff       	call   f0100a83 <boot_alloc>
	if ((uint32_t)kva < KERNBASE)
f0100ebd:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100ec2:	76 3b                	jbe    f0100eff <page_init+0xb9>
	return (physaddr_t)kva - KERNBASE;
f0100ec4:	8d 88 00 00 00 10    	lea    0x10000000(%eax),%ecx
        pages[i].pp_ref = 1;
f0100eca:	8b 15 10 1f 23 f0    	mov    0xf0231f10,%edx
f0100ed0:	8d 82 04 05 00 00    	lea    0x504(%edx),%eax
f0100ed6:	81 c2 04 08 00 00    	add    $0x804,%edx
f0100edc:	66 c7 00 01 00       	movw   $0x1,(%eax)
f0100ee1:	83 c0 08             	add    $0x8,%eax
    for (i = IOPHYSMEM/PGSIZE; i < EXTPHYSMEM/PGSIZE; i++) {
f0100ee4:	39 d0                	cmp    %edx,%eax
f0100ee6:	75 f4                	jne    f0100edc <page_init+0x96>
    for (i = first_free_address/PGSIZE; i < npages; i++) {
f0100ee8:	89 c8                	mov    %ecx,%eax
f0100eea:	c1 e8 0c             	shr    $0xc,%eax
f0100eed:	8b 1d 3c 12 23 f0    	mov    0xf023123c,%ebx
f0100ef3:	ba 00 00 00 00       	mov    $0x0,%edx
f0100ef8:	be 01 00 00 00       	mov    $0x1,%esi
f0100efd:	eb 39                	jmp    f0100f38 <page_init+0xf2>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100eff:	50                   	push   %eax
f0100f00:	68 f8 55 10 f0       	push   $0xf01055f8
f0100f05:	68 56 01 00 00       	push   $0x156
f0100f0a:	68 9d 64 10 f0       	push   $0xf010649d
f0100f0f:	e8 80 f1 ff ff       	call   f0100094 <_panic>
f0100f14:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
        pages[i].pp_ref = 0;
f0100f1b:	89 d1                	mov    %edx,%ecx
f0100f1d:	03 0d 10 1f 23 f0    	add    0xf0231f10,%ecx
f0100f23:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
        pages[i].pp_link = page_free_list;
f0100f29:	89 19                	mov    %ebx,(%ecx)
    for (i = first_free_address/PGSIZE; i < npages; i++) {
f0100f2b:	83 c0 01             	add    $0x1,%eax
        page_free_list = &pages[i];
f0100f2e:	89 d3                	mov    %edx,%ebx
f0100f30:	03 1d 10 1f 23 f0    	add    0xf0231f10,%ebx
f0100f36:	89 f2                	mov    %esi,%edx
    for (i = first_free_address/PGSIZE; i < npages; i++) {
f0100f38:	39 05 08 1f 23 f0    	cmp    %eax,0xf0231f08
f0100f3e:	77 d4                	ja     f0100f14 <page_init+0xce>
f0100f40:	84 d2                	test   %dl,%dl
f0100f42:	74 06                	je     f0100f4a <page_init+0x104>
f0100f44:	89 1d 3c 12 23 f0    	mov    %ebx,0xf023123c
}
f0100f4a:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100f4d:	5b                   	pop    %ebx
f0100f4e:	5e                   	pop    %esi
f0100f4f:	5d                   	pop    %ebp
f0100f50:	c3                   	ret    

f0100f51 <page_alloc>:
{
f0100f51:	55                   	push   %ebp
f0100f52:	89 e5                	mov    %esp,%ebp
f0100f54:	53                   	push   %ebx
f0100f55:	83 ec 04             	sub    $0x4,%esp
	if (!page_free_list) {
f0100f58:	8b 1d 3c 12 23 f0    	mov    0xf023123c,%ebx
f0100f5e:	85 db                	test   %ebx,%ebx
f0100f60:	74 13                	je     f0100f75 <page_alloc+0x24>
	page_free_list = page->pp_link;
f0100f62:	8b 03                	mov    (%ebx),%eax
f0100f64:	a3 3c 12 23 f0       	mov    %eax,0xf023123c
	page->pp_link = NULL;
f0100f69:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (alloc_flags & ALLOC_ZERO) {
f0100f6f:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100f73:	75 07                	jne    f0100f7c <page_alloc+0x2b>
}
f0100f75:	89 d8                	mov    %ebx,%eax
f0100f77:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100f7a:	c9                   	leave  
f0100f7b:	c3                   	ret    
	return (pp - pages) << PGSHIFT;
f0100f7c:	89 d8                	mov    %ebx,%eax
f0100f7e:	2b 05 10 1f 23 f0    	sub    0xf0231f10,%eax
f0100f84:	c1 f8 03             	sar    $0x3,%eax
f0100f87:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0100f8a:	89 c2                	mov    %eax,%edx
f0100f8c:	c1 ea 0c             	shr    $0xc,%edx
f0100f8f:	3b 15 08 1f 23 f0    	cmp    0xf0231f08,%edx
f0100f95:	73 1a                	jae    f0100fb1 <page_alloc+0x60>
		memset(page2kva(page), 0, PGSIZE); 
f0100f97:	83 ec 04             	sub    $0x4,%esp
f0100f9a:	68 00 10 00 00       	push   $0x1000
f0100f9f:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f0100fa1:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100fa6:	50                   	push   %eax
f0100fa7:	e8 1b 39 00 00       	call   f01048c7 <memset>
f0100fac:	83 c4 10             	add    $0x10,%esp
f0100faf:	eb c4                	jmp    f0100f75 <page_alloc+0x24>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100fb1:	50                   	push   %eax
f0100fb2:	68 d4 55 10 f0       	push   $0xf01055d4
f0100fb7:	6a 58                	push   $0x58
f0100fb9:	68 b0 64 10 f0       	push   $0xf01064b0
f0100fbe:	e8 d1 f0 ff ff       	call   f0100094 <_panic>

f0100fc3 <page_free>:
{
f0100fc3:	55                   	push   %ebp
f0100fc4:	89 e5                	mov    %esp,%ebp
f0100fc6:	83 ec 08             	sub    $0x8,%esp
f0100fc9:	8b 45 08             	mov    0x8(%ebp),%eax
	if (pp->pp_ref || pp->pp_link) {
f0100fcc:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100fd1:	75 14                	jne    f0100fe7 <page_free+0x24>
f0100fd3:	83 38 00             	cmpl   $0x0,(%eax)
f0100fd6:	75 0f                	jne    f0100fe7 <page_free+0x24>
	pp->pp_link = page_free_list;
f0100fd8:	8b 15 3c 12 23 f0    	mov    0xf023123c,%edx
f0100fde:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0100fe0:	a3 3c 12 23 f0       	mov    %eax,0xf023123c
}
f0100fe5:	c9                   	leave  
f0100fe6:	c3                   	ret    
		panic("page_free: double check failed when dealloc page. '\n");
f0100fe7:	83 ec 04             	sub    $0x4,%esp
f0100fea:	68 ec 5b 10 f0       	push   $0xf0105bec
f0100fef:	68 91 01 00 00       	push   $0x191
f0100ff4:	68 9d 64 10 f0       	push   $0xf010649d
f0100ff9:	e8 96 f0 ff ff       	call   f0100094 <_panic>

f0100ffe <page_decref>:
{
f0100ffe:	55                   	push   %ebp
f0100fff:	89 e5                	mov    %esp,%ebp
f0101001:	83 ec 08             	sub    $0x8,%esp
f0101004:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0101007:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f010100b:	83 e8 01             	sub    $0x1,%eax
f010100e:	66 89 42 04          	mov    %ax,0x4(%edx)
f0101012:	66 85 c0             	test   %ax,%ax
f0101015:	74 02                	je     f0101019 <page_decref+0x1b>
}
f0101017:	c9                   	leave  
f0101018:	c3                   	ret    
		page_free(pp);
f0101019:	83 ec 0c             	sub    $0xc,%esp
f010101c:	52                   	push   %edx
f010101d:	e8 a1 ff ff ff       	call   f0100fc3 <page_free>
f0101022:	83 c4 10             	add    $0x10,%esp
}
f0101025:	eb f0                	jmp    f0101017 <page_decref+0x19>

f0101027 <pgdir_walk>:
{
f0101027:	55                   	push   %ebp
f0101028:	89 e5                	mov    %esp,%ebp
f010102a:	56                   	push   %esi
f010102b:	53                   	push   %ebx
f010102c:	8b 45 0c             	mov    0xc(%ebp),%eax
	uint32_t ptx = PTX(va);		
f010102f:	89 c6                	mov    %eax,%esi
f0101031:	c1 ee 0c             	shr    $0xc,%esi
f0101034:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
	uint32_t pdx = PDX(va);		
f010103a:	c1 e8 16             	shr    $0x16,%eax
	if (pgdir[pdx] & PTE_P) {
f010103d:	8d 1c 85 00 00 00 00 	lea    0x0(,%eax,4),%ebx
f0101044:	03 5d 08             	add    0x8(%ebp),%ebx
f0101047:	8b 03                	mov    (%ebx),%eax
f0101049:	a8 01                	test   $0x1,%al
f010104b:	74 36                	je     f0101083 <pgdir_walk+0x5c>
		pgtab = KADDR(PTE_ADDR(pgdir[pdx]));
f010104d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0101052:	89 c2                	mov    %eax,%edx
f0101054:	c1 ea 0c             	shr    $0xc,%edx
f0101057:	39 15 08 1f 23 f0    	cmp    %edx,0xf0231f08
f010105d:	76 0f                	jbe    f010106e <pgdir_walk+0x47>
	return (void *)(pa + KERNBASE);
f010105f:	2d 00 00 00 10       	sub    $0x10000000,%eax
	return &pgtab[ptx];
f0101064:	8d 04 b0             	lea    (%eax,%esi,4),%eax
}
f0101067:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010106a:	5b                   	pop    %ebx
f010106b:	5e                   	pop    %esi
f010106c:	5d                   	pop    %ebp
f010106d:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010106e:	50                   	push   %eax
f010106f:	68 d4 55 10 f0       	push   $0xf01055d4
f0101074:	68 c1 01 00 00       	push   $0x1c1
f0101079:	68 9d 64 10 f0       	push   $0xf010649d
f010107e:	e8 11 f0 ff ff       	call   f0100094 <_panic>
		if (create) {
f0101083:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101087:	74 50                	je     f01010d9 <pgdir_walk+0xb2>
			struct PageInfo *new_pginfo = page_alloc(ALLOC_ZERO);	
f0101089:	83 ec 0c             	sub    $0xc,%esp
f010108c:	6a 01                	push   $0x1
f010108e:	e8 be fe ff ff       	call   f0100f51 <page_alloc>
			if (new_pginfo) {
f0101093:	83 c4 10             	add    $0x10,%esp
f0101096:	85 c0                	test   %eax,%eax
f0101098:	74 46                	je     f01010e0 <pgdir_walk+0xb9>
				new_pginfo->pp_ref += 1;
f010109a:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f010109f:	2b 05 10 1f 23 f0    	sub    0xf0231f10,%eax
f01010a5:	89 c2                	mov    %eax,%edx
f01010a7:	c1 fa 03             	sar    $0x3,%edx
f01010aa:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f01010ad:	89 d0                	mov    %edx,%eax
f01010af:	c1 e8 0c             	shr    $0xc,%eax
f01010b2:	3b 05 08 1f 23 f0    	cmp    0xf0231f08,%eax
f01010b8:	73 0d                	jae    f01010c7 <pgdir_walk+0xa0>
	return (void *)(pa + KERNBASE);
f01010ba:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
				pgdir[pdx] = page2pa(new_pginfo) | PTE_P | PTE_W | PTE_U;
f01010c0:	83 ca 07             	or     $0x7,%edx
f01010c3:	89 13                	mov    %edx,(%ebx)
f01010c5:	eb 9d                	jmp    f0101064 <pgdir_walk+0x3d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01010c7:	52                   	push   %edx
f01010c8:	68 d4 55 10 f0       	push   $0xf01055d4
f01010cd:	6a 58                	push   $0x58
f01010cf:	68 b0 64 10 f0       	push   $0xf01064b0
f01010d4:	e8 bb ef ff ff       	call   f0100094 <_panic>
			return NULL;
f01010d9:	b8 00 00 00 00       	mov    $0x0,%eax
f01010de:	eb 87                	jmp    f0101067 <pgdir_walk+0x40>
			return NULL; 
f01010e0:	b8 00 00 00 00       	mov    $0x0,%eax
f01010e5:	eb 80                	jmp    f0101067 <pgdir_walk+0x40>

f01010e7 <boot_map_region>:
{
f01010e7:	55                   	push   %ebp
f01010e8:	89 e5                	mov    %esp,%ebp
f01010ea:	57                   	push   %edi
f01010eb:	56                   	push   %esi
f01010ec:	53                   	push   %ebx
f01010ed:	83 ec 1c             	sub    $0x1c,%esp
f01010f0:	89 c7                	mov    %eax,%edi
f01010f2:	8b 45 08             	mov    0x8(%ebp),%eax
f01010f5:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f01010fb:	01 c1                	add    %eax,%ecx
f01010fd:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	for (size_t i = 0;i < pg_num; i++) {
f0101100:	89 c3                	mov    %eax,%ebx
		pte = pgdir_walk(pgdir, (void *)va, 1);		 
f0101102:	89 d6                	mov    %edx,%esi
f0101104:	29 c6                	sub    %eax,%esi
	for (size_t i = 0;i < pg_num; i++) {
f0101106:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0101109:	74 28                	je     f0101133 <boot_map_region+0x4c>
		pte = pgdir_walk(pgdir, (void *)va, 1);		 
f010110b:	83 ec 04             	sub    $0x4,%esp
f010110e:	6a 01                	push   $0x1
f0101110:	8d 04 1e             	lea    (%esi,%ebx,1),%eax
f0101113:	50                   	push   %eax
f0101114:	57                   	push   %edi
f0101115:	e8 0d ff ff ff       	call   f0101027 <pgdir_walk>
		if (!pte) {
f010111a:	83 c4 10             	add    $0x10,%esp
f010111d:	85 c0                	test   %eax,%eax
f010111f:	74 12                	je     f0101133 <boot_map_region+0x4c>
		*pte = pa | perm | PTE_P;
f0101121:	89 da                	mov    %ebx,%edx
f0101123:	0b 55 0c             	or     0xc(%ebp),%edx
f0101126:	83 ca 01             	or     $0x1,%edx
f0101129:	89 10                	mov    %edx,(%eax)
		pa += PGSIZE;
f010112b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0101131:	eb d3                	jmp    f0101106 <boot_map_region+0x1f>
}
f0101133:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101136:	5b                   	pop    %ebx
f0101137:	5e                   	pop    %esi
f0101138:	5f                   	pop    %edi
f0101139:	5d                   	pop    %ebp
f010113a:	c3                   	ret    

f010113b <page_lookup>:
{
f010113b:	55                   	push   %ebp
f010113c:	89 e5                	mov    %esp,%ebp
f010113e:	83 ec 0c             	sub    $0xc,%esp
	pte_t *pte = pgdir_walk(pgdir, va, 0);
f0101141:	6a 00                	push   $0x0
f0101143:	ff 75 0c             	pushl  0xc(%ebp)
f0101146:	ff 75 08             	pushl  0x8(%ebp)
f0101149:	e8 d9 fe ff ff       	call   f0101027 <pgdir_walk>
	if (!pte) {
f010114e:	83 c4 10             	add    $0x10,%esp
f0101151:	85 c0                	test   %eax,%eax
f0101153:	74 3b                	je     f0101190 <page_lookup+0x55>
		*pte_store = pte;
f0101155:	8b 55 10             	mov    0x10(%ebp),%edx
f0101158:	89 02                	mov    %eax,(%edx)
	 	if (*pte) {
f010115a:	8b 10                	mov    (%eax),%edx
	return NULL;
f010115c:	b8 00 00 00 00       	mov    $0x0,%eax
	 	if (*pte) {
f0101161:	85 d2                	test   %edx,%edx
f0101163:	75 02                	jne    f0101167 <page_lookup+0x2c>
}
f0101165:	c9                   	leave  
f0101166:	c3                   	ret    
f0101167:	c1 ea 0c             	shr    $0xc,%edx
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010116a:	39 15 08 1f 23 f0    	cmp    %edx,0xf0231f08
f0101170:	76 0a                	jbe    f010117c <page_lookup+0x41>
		panic("pa2page called with invalid pa");
	return &pages[PGNUM(pa)];
f0101172:	a1 10 1f 23 f0       	mov    0xf0231f10,%eax
f0101177:	8d 04 d0             	lea    (%eax,%edx,8),%eax
			return pa2page(PTE_ADDR(*pte)); 
f010117a:	eb e9                	jmp    f0101165 <page_lookup+0x2a>
		panic("pa2page called with invalid pa");
f010117c:	83 ec 04             	sub    $0x4,%esp
f010117f:	68 24 5c 10 f0       	push   $0xf0105c24
f0101184:	6a 51                	push   $0x51
f0101186:	68 b0 64 10 f0       	push   $0xf01064b0
f010118b:	e8 04 ef ff ff       	call   f0100094 <_panic>
		 return NULL;
f0101190:	b8 00 00 00 00       	mov    $0x0,%eax
f0101195:	eb ce                	jmp    f0101165 <page_lookup+0x2a>

f0101197 <tlb_invalidate>:
{
f0101197:	55                   	push   %ebp
f0101198:	89 e5                	mov    %esp,%ebp
f010119a:	83 ec 08             	sub    $0x8,%esp
	if (!curenv || curenv->env_pgdir == pgdir)
f010119d:	e8 24 3d 00 00       	call   f0104ec6 <cpunum>
f01011a2:	6b c0 74             	imul   $0x74,%eax,%eax
f01011a5:	83 b8 28 20 23 f0 00 	cmpl   $0x0,-0xfdcdfd8(%eax)
f01011ac:	74 16                	je     f01011c4 <tlb_invalidate+0x2d>
f01011ae:	e8 13 3d 00 00       	call   f0104ec6 <cpunum>
f01011b3:	6b c0 74             	imul   $0x74,%eax,%eax
f01011b6:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f01011bc:	8b 55 08             	mov    0x8(%ebp),%edx
f01011bf:	39 50 60             	cmp    %edx,0x60(%eax)
f01011c2:	75 06                	jne    f01011ca <tlb_invalidate+0x33>
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01011c4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01011c7:	0f 01 38             	invlpg (%eax)
}
f01011ca:	c9                   	leave  
f01011cb:	c3                   	ret    

f01011cc <page_remove>:
{
f01011cc:	55                   	push   %ebp
f01011cd:	89 e5                	mov    %esp,%ebp
f01011cf:	56                   	push   %esi
f01011d0:	53                   	push   %ebx
f01011d1:	83 ec 14             	sub    $0x14,%esp
f01011d4:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01011d7:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct PageInfo *pginfo = page_lookup(pgdir, va, pte_store);
f01011da:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01011dd:	50                   	push   %eax
f01011de:	56                   	push   %esi
f01011df:	53                   	push   %ebx
f01011e0:	e8 56 ff ff ff       	call   f010113b <page_lookup>
	if (pginfo) {
f01011e5:	83 c4 10             	add    $0x10,%esp
f01011e8:	85 c0                	test   %eax,%eax
f01011ea:	74 1f                	je     f010120b <page_remove+0x3f>
		page_decref(pginfo);
f01011ec:	83 ec 0c             	sub    $0xc,%esp
f01011ef:	50                   	push   %eax
f01011f0:	e8 09 fe ff ff       	call   f0100ffe <page_decref>
		*pte = 0;	 
f01011f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01011f8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		tlb_invalidate(pgdir, va);
f01011fe:	83 c4 08             	add    $0x8,%esp
f0101201:	56                   	push   %esi
f0101202:	53                   	push   %ebx
f0101203:	e8 8f ff ff ff       	call   f0101197 <tlb_invalidate>
f0101208:	83 c4 10             	add    $0x10,%esp
}
f010120b:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010120e:	5b                   	pop    %ebx
f010120f:	5e                   	pop    %esi
f0101210:	5d                   	pop    %ebp
f0101211:	c3                   	ret    

f0101212 <page_insert>:
{
f0101212:	55                   	push   %ebp
f0101213:	89 e5                	mov    %esp,%ebp
f0101215:	57                   	push   %edi
f0101216:	56                   	push   %esi
f0101217:	53                   	push   %ebx
f0101218:	83 ec 10             	sub    $0x10,%esp
f010121b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010121e:	8b 7d 10             	mov    0x10(%ebp),%edi
	pte_t *pte = pgdir_walk(pgdir, va, 1);	
f0101221:	6a 01                	push   $0x1
f0101223:	57                   	push   %edi
f0101224:	ff 75 08             	pushl  0x8(%ebp)
f0101227:	e8 fb fd ff ff       	call   f0101027 <pgdir_walk>
	if (!pte) {
f010122c:	83 c4 10             	add    $0x10,%esp
f010122f:	85 c0                	test   %eax,%eax
f0101231:	74 3e                	je     f0101271 <page_insert+0x5f>
f0101233:	89 c6                	mov    %eax,%esi
	pp->pp_ref++;
f0101235:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
	if (*pte & PTE_P) {
f010123a:	f6 00 01             	testb  $0x1,(%eax)
f010123d:	75 21                	jne    f0101260 <page_insert+0x4e>
	return (pp - pages) << PGSHIFT;
f010123f:	2b 1d 10 1f 23 f0    	sub    0xf0231f10,%ebx
f0101245:	c1 fb 03             	sar    $0x3,%ebx
f0101248:	c1 e3 0c             	shl    $0xc,%ebx
	*pte = page2pa(pp) | perm | PTE_P;
f010124b:	0b 5d 14             	or     0x14(%ebp),%ebx
f010124e:	83 cb 01             	or     $0x1,%ebx
f0101251:	89 1e                	mov    %ebx,(%esi)
	return 0;
f0101253:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101258:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010125b:	5b                   	pop    %ebx
f010125c:	5e                   	pop    %esi
f010125d:	5f                   	pop    %edi
f010125e:	5d                   	pop    %ebp
f010125f:	c3                   	ret    
		 page_remove(pgdir, va);
f0101260:	83 ec 08             	sub    $0x8,%esp
f0101263:	57                   	push   %edi
f0101264:	ff 75 08             	pushl  0x8(%ebp)
f0101267:	e8 60 ff ff ff       	call   f01011cc <page_remove>
f010126c:	83 c4 10             	add    $0x10,%esp
f010126f:	eb ce                	jmp    f010123f <page_insert+0x2d>
		 return -E_NO_MEM;
f0101271:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0101276:	eb e0                	jmp    f0101258 <page_insert+0x46>

f0101278 <mmio_map_region>:
{
f0101278:	55                   	push   %ebp
f0101279:	89 e5                	mov    %esp,%ebp
f010127b:	53                   	push   %ebx
f010127c:	83 ec 04             	sub    $0x4,%esp
    size_t rounded_size = ROUNDUP(size, PGSIZE);
f010127f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101282:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
f0101288:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    if (base + rounded_size > MMIOLIM) panic("memory overflow ");
f010128e:	8b 15 00 13 12 f0    	mov    0xf0121300,%edx
f0101294:	8d 04 1a             	lea    (%edx,%ebx,1),%eax
f0101297:	3d 00 00 c0 ef       	cmp    $0xefc00000,%eax
f010129c:	77 26                	ja     f01012c4 <mmio_map_region+0x4c>
    boot_map_region(kern_pgdir, base, rounded_size, pa, PTE_W|PTE_PCD|PTE_PWT);
f010129e:	83 ec 08             	sub    $0x8,%esp
f01012a1:	6a 1a                	push   $0x1a
f01012a3:	ff 75 08             	pushl  0x8(%ebp)
f01012a6:	89 d9                	mov    %ebx,%ecx
f01012a8:	a1 0c 1f 23 f0       	mov    0xf0231f0c,%eax
f01012ad:	e8 35 fe ff ff       	call   f01010e7 <boot_map_region>
    uintptr_t return_base = base;
f01012b2:	a1 00 13 12 f0       	mov    0xf0121300,%eax
    base += rounded_size;
f01012b7:	01 c3                	add    %eax,%ebx
f01012b9:	89 1d 00 13 12 f0    	mov    %ebx,0xf0121300
}
f01012bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01012c2:	c9                   	leave  
f01012c3:	c3                   	ret    
    if (base + rounded_size > MMIOLIM) panic("memory overflow ");
f01012c4:	83 ec 04             	sub    $0x4,%esp
f01012c7:	68 85 65 10 f0       	push   $0xf0106585
f01012cc:	68 7f 02 00 00       	push   $0x27f
f01012d1:	68 9d 64 10 f0       	push   $0xf010649d
f01012d6:	e8 b9 ed ff ff       	call   f0100094 <_panic>

f01012db <mem_init>:
{
f01012db:	55                   	push   %ebp
f01012dc:	89 e5                	mov    %esp,%ebp
f01012de:	57                   	push   %edi
f01012df:	56                   	push   %esi
f01012e0:	53                   	push   %ebx
f01012e1:	83 ec 3c             	sub    $0x3c,%esp
	basemem = nvram_read(NVRAM_BASELO);
f01012e4:	b8 15 00 00 00       	mov    $0x15,%eax
f01012e9:	e8 cb f7 ff ff       	call   f0100ab9 <nvram_read>
f01012ee:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f01012f0:	b8 17 00 00 00       	mov    $0x17,%eax
f01012f5:	e8 bf f7 ff ff       	call   f0100ab9 <nvram_read>
f01012fa:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f01012fc:	b8 34 00 00 00       	mov    $0x34,%eax
f0101301:	e8 b3 f7 ff ff       	call   f0100ab9 <nvram_read>
	if (ext16mem)
f0101306:	c1 e0 06             	shl    $0x6,%eax
f0101309:	0f 84 ea 00 00 00    	je     f01013f9 <mem_init+0x11e>
		totalmem = 16 * 1024 + ext16mem;
f010130f:	05 00 40 00 00       	add    $0x4000,%eax
	npages = totalmem / (PGSIZE / 1024);
f0101314:	89 c2                	mov    %eax,%edx
f0101316:	c1 ea 02             	shr    $0x2,%edx
f0101319:	89 15 08 1f 23 f0    	mov    %edx,0xf0231f08
	npages_basemem = basemem / (PGSIZE / 1024);
f010131f:	89 da                	mov    %ebx,%edx
f0101321:	c1 ea 02             	shr    $0x2,%edx
f0101324:	89 15 40 12 23 f0    	mov    %edx,0xf0231240
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010132a:	89 c2                	mov    %eax,%edx
f010132c:	29 da                	sub    %ebx,%edx
f010132e:	52                   	push   %edx
f010132f:	53                   	push   %ebx
f0101330:	50                   	push   %eax
f0101331:	68 44 5c 10 f0       	push   $0xf0105c44
f0101336:	e8 97 24 00 00       	call   f01037d2 <cprintf>
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f010133b:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101340:	e8 3e f7 ff ff       	call   f0100a83 <boot_alloc>
f0101345:	a3 0c 1f 23 f0       	mov    %eax,0xf0231f0c
	memset(kern_pgdir, 0, PGSIZE);
f010134a:	83 c4 0c             	add    $0xc,%esp
f010134d:	68 00 10 00 00       	push   $0x1000
f0101352:	6a 00                	push   $0x0
f0101354:	50                   	push   %eax
f0101355:	e8 6d 35 00 00       	call   f01048c7 <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f010135a:	a1 0c 1f 23 f0       	mov    0xf0231f0c,%eax
	if ((uint32_t)kva < KERNBASE)
f010135f:	83 c4 10             	add    $0x10,%esp
f0101362:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101367:	0f 86 9c 00 00 00    	jbe    f0101409 <mem_init+0x12e>
	return (physaddr_t)kva - KERNBASE;
f010136d:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101373:	83 ca 05             	or     $0x5,%edx
f0101376:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	pages = (struct PageInfo*) boot_alloc(npages * sizeof(struct PageInfo));
f010137c:	a1 08 1f 23 f0       	mov    0xf0231f08,%eax
f0101381:	c1 e0 03             	shl    $0x3,%eax
f0101384:	e8 fa f6 ff ff       	call   f0100a83 <boot_alloc>
f0101389:	a3 10 1f 23 f0       	mov    %eax,0xf0231f10
	memset(pages, 0, npages * sizeof(struct PageInfo));
f010138e:	83 ec 04             	sub    $0x4,%esp
f0101391:	8b 0d 08 1f 23 f0    	mov    0xf0231f08,%ecx
f0101397:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f010139e:	52                   	push   %edx
f010139f:	6a 00                	push   $0x0
f01013a1:	50                   	push   %eax
f01013a2:	e8 20 35 00 00       	call   f01048c7 <memset>
	envs = (struct Env*) boot_alloc(NENV * sizeof(struct Env));
f01013a7:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f01013ac:	e8 d2 f6 ff ff       	call   f0100a83 <boot_alloc>
f01013b1:	a3 44 12 23 f0       	mov    %eax,0xf0231244
	memset(envs, 0, NENV * sizeof(struct Env));
f01013b6:	83 c4 0c             	add    $0xc,%esp
f01013b9:	68 00 f0 01 00       	push   $0x1f000
f01013be:	6a 00                	push   $0x0
f01013c0:	50                   	push   %eax
f01013c1:	e8 01 35 00 00       	call   f01048c7 <memset>
	page_init();
f01013c6:	e8 7b fa ff ff       	call   f0100e46 <page_init>
	check_page_free_list(1);
f01013cb:	b8 01 00 00 00       	mov    $0x1,%eax
f01013d0:	e8 71 f7 ff ff       	call   f0100b46 <check_page_free_list>
	if (!pages)
f01013d5:	83 c4 10             	add    $0x10,%esp
f01013d8:	83 3d 10 1f 23 f0 00 	cmpl   $0x0,0xf0231f10
f01013df:	74 3d                	je     f010141e <mem_init+0x143>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01013e1:	a1 3c 12 23 f0       	mov    0xf023123c,%eax
f01013e6:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f01013ed:	85 c0                	test   %eax,%eax
f01013ef:	74 44                	je     f0101435 <mem_init+0x15a>
		++nfree;
f01013f1:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01013f5:	8b 00                	mov    (%eax),%eax
f01013f7:	eb f4                	jmp    f01013ed <mem_init+0x112>
		totalmem = 1 * 1024 + extmem;
f01013f9:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f01013ff:	85 f6                	test   %esi,%esi
f0101401:	0f 44 c3             	cmove  %ebx,%eax
f0101404:	e9 0b ff ff ff       	jmp    f0101314 <mem_init+0x39>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101409:	50                   	push   %eax
f010140a:	68 f8 55 10 f0       	push   $0xf01055f8
f010140f:	68 a3 00 00 00       	push   $0xa3
f0101414:	68 9d 64 10 f0       	push   $0xf010649d
f0101419:	e8 76 ec ff ff       	call   f0100094 <_panic>
		panic("'pages' is a null pointer!");
f010141e:	83 ec 04             	sub    $0x4,%esp
f0101421:	68 96 65 10 f0       	push   $0xf0106596
f0101426:	68 0a 03 00 00       	push   $0x30a
f010142b:	68 9d 64 10 f0       	push   $0xf010649d
f0101430:	e8 5f ec ff ff       	call   f0100094 <_panic>
	assert((pp0 = page_alloc(0)));
f0101435:	83 ec 0c             	sub    $0xc,%esp
f0101438:	6a 00                	push   $0x0
f010143a:	e8 12 fb ff ff       	call   f0100f51 <page_alloc>
f010143f:	89 c3                	mov    %eax,%ebx
f0101441:	83 c4 10             	add    $0x10,%esp
f0101444:	85 c0                	test   %eax,%eax
f0101446:	0f 84 00 02 00 00    	je     f010164c <mem_init+0x371>
	assert((pp1 = page_alloc(0)));
f010144c:	83 ec 0c             	sub    $0xc,%esp
f010144f:	6a 00                	push   $0x0
f0101451:	e8 fb fa ff ff       	call   f0100f51 <page_alloc>
f0101456:	89 c6                	mov    %eax,%esi
f0101458:	83 c4 10             	add    $0x10,%esp
f010145b:	85 c0                	test   %eax,%eax
f010145d:	0f 84 02 02 00 00    	je     f0101665 <mem_init+0x38a>
	assert((pp2 = page_alloc(0)));
f0101463:	83 ec 0c             	sub    $0xc,%esp
f0101466:	6a 00                	push   $0x0
f0101468:	e8 e4 fa ff ff       	call   f0100f51 <page_alloc>
f010146d:	89 c7                	mov    %eax,%edi
f010146f:	83 c4 10             	add    $0x10,%esp
f0101472:	85 c0                	test   %eax,%eax
f0101474:	0f 84 04 02 00 00    	je     f010167e <mem_init+0x3a3>
	assert(pp1 && pp1 != pp0);
f010147a:	39 f3                	cmp    %esi,%ebx
f010147c:	0f 84 15 02 00 00    	je     f0101697 <mem_init+0x3bc>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101482:	39 c6                	cmp    %eax,%esi
f0101484:	0f 84 26 02 00 00    	je     f01016b0 <mem_init+0x3d5>
f010148a:	39 c3                	cmp    %eax,%ebx
f010148c:	0f 84 1e 02 00 00    	je     f01016b0 <mem_init+0x3d5>
	return (pp - pages) << PGSHIFT;
f0101492:	8b 0d 10 1f 23 f0    	mov    0xf0231f10,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101498:	8b 15 08 1f 23 f0    	mov    0xf0231f08,%edx
f010149e:	c1 e2 0c             	shl    $0xc,%edx
f01014a1:	89 d8                	mov    %ebx,%eax
f01014a3:	29 c8                	sub    %ecx,%eax
f01014a5:	c1 f8 03             	sar    $0x3,%eax
f01014a8:	c1 e0 0c             	shl    $0xc,%eax
f01014ab:	39 d0                	cmp    %edx,%eax
f01014ad:	0f 83 16 02 00 00    	jae    f01016c9 <mem_init+0x3ee>
f01014b3:	89 f0                	mov    %esi,%eax
f01014b5:	29 c8                	sub    %ecx,%eax
f01014b7:	c1 f8 03             	sar    $0x3,%eax
f01014ba:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp1) < npages*PGSIZE);
f01014bd:	39 c2                	cmp    %eax,%edx
f01014bf:	0f 86 1d 02 00 00    	jbe    f01016e2 <mem_init+0x407>
f01014c5:	89 f8                	mov    %edi,%eax
f01014c7:	29 c8                	sub    %ecx,%eax
f01014c9:	c1 f8 03             	sar    $0x3,%eax
f01014cc:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp2) < npages*PGSIZE);
f01014cf:	39 c2                	cmp    %eax,%edx
f01014d1:	0f 86 24 02 00 00    	jbe    f01016fb <mem_init+0x420>
	fl = page_free_list;
f01014d7:	a1 3c 12 23 f0       	mov    0xf023123c,%eax
f01014dc:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01014df:	c7 05 3c 12 23 f0 00 	movl   $0x0,0xf023123c
f01014e6:	00 00 00 
	assert(!page_alloc(0));
f01014e9:	83 ec 0c             	sub    $0xc,%esp
f01014ec:	6a 00                	push   $0x0
f01014ee:	e8 5e fa ff ff       	call   f0100f51 <page_alloc>
f01014f3:	83 c4 10             	add    $0x10,%esp
f01014f6:	85 c0                	test   %eax,%eax
f01014f8:	0f 85 16 02 00 00    	jne    f0101714 <mem_init+0x439>
	page_free(pp0);
f01014fe:	83 ec 0c             	sub    $0xc,%esp
f0101501:	53                   	push   %ebx
f0101502:	e8 bc fa ff ff       	call   f0100fc3 <page_free>
	page_free(pp1);
f0101507:	89 34 24             	mov    %esi,(%esp)
f010150a:	e8 b4 fa ff ff       	call   f0100fc3 <page_free>
	page_free(pp2);
f010150f:	89 3c 24             	mov    %edi,(%esp)
f0101512:	e8 ac fa ff ff       	call   f0100fc3 <page_free>
	assert((pp0 = page_alloc(0)));
f0101517:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010151e:	e8 2e fa ff ff       	call   f0100f51 <page_alloc>
f0101523:	89 c3                	mov    %eax,%ebx
f0101525:	83 c4 10             	add    $0x10,%esp
f0101528:	85 c0                	test   %eax,%eax
f010152a:	0f 84 fd 01 00 00    	je     f010172d <mem_init+0x452>
	assert((pp1 = page_alloc(0)));
f0101530:	83 ec 0c             	sub    $0xc,%esp
f0101533:	6a 00                	push   $0x0
f0101535:	e8 17 fa ff ff       	call   f0100f51 <page_alloc>
f010153a:	89 c6                	mov    %eax,%esi
f010153c:	83 c4 10             	add    $0x10,%esp
f010153f:	85 c0                	test   %eax,%eax
f0101541:	0f 84 ff 01 00 00    	je     f0101746 <mem_init+0x46b>
	assert((pp2 = page_alloc(0)));
f0101547:	83 ec 0c             	sub    $0xc,%esp
f010154a:	6a 00                	push   $0x0
f010154c:	e8 00 fa ff ff       	call   f0100f51 <page_alloc>
f0101551:	89 c7                	mov    %eax,%edi
f0101553:	83 c4 10             	add    $0x10,%esp
f0101556:	85 c0                	test   %eax,%eax
f0101558:	0f 84 01 02 00 00    	je     f010175f <mem_init+0x484>
	assert(pp1 && pp1 != pp0);
f010155e:	39 f3                	cmp    %esi,%ebx
f0101560:	0f 84 12 02 00 00    	je     f0101778 <mem_init+0x49d>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101566:	39 c6                	cmp    %eax,%esi
f0101568:	0f 84 23 02 00 00    	je     f0101791 <mem_init+0x4b6>
f010156e:	39 c3                	cmp    %eax,%ebx
f0101570:	0f 84 1b 02 00 00    	je     f0101791 <mem_init+0x4b6>
	assert(!page_alloc(0));
f0101576:	83 ec 0c             	sub    $0xc,%esp
f0101579:	6a 00                	push   $0x0
f010157b:	e8 d1 f9 ff ff       	call   f0100f51 <page_alloc>
f0101580:	83 c4 10             	add    $0x10,%esp
f0101583:	85 c0                	test   %eax,%eax
f0101585:	0f 85 1f 02 00 00    	jne    f01017aa <mem_init+0x4cf>
f010158b:	89 d8                	mov    %ebx,%eax
f010158d:	2b 05 10 1f 23 f0    	sub    0xf0231f10,%eax
f0101593:	c1 f8 03             	sar    $0x3,%eax
f0101596:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0101599:	89 c2                	mov    %eax,%edx
f010159b:	c1 ea 0c             	shr    $0xc,%edx
f010159e:	3b 15 08 1f 23 f0    	cmp    0xf0231f08,%edx
f01015a4:	0f 83 19 02 00 00    	jae    f01017c3 <mem_init+0x4e8>
	memset(page2kva(pp0), 1, PGSIZE);
f01015aa:	83 ec 04             	sub    $0x4,%esp
f01015ad:	68 00 10 00 00       	push   $0x1000
f01015b2:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f01015b4:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01015b9:	50                   	push   %eax
f01015ba:	e8 08 33 00 00       	call   f01048c7 <memset>
	page_free(pp0);
f01015bf:	89 1c 24             	mov    %ebx,(%esp)
f01015c2:	e8 fc f9 ff ff       	call   f0100fc3 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01015c7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01015ce:	e8 7e f9 ff ff       	call   f0100f51 <page_alloc>
f01015d3:	83 c4 10             	add    $0x10,%esp
f01015d6:	85 c0                	test   %eax,%eax
f01015d8:	0f 84 f7 01 00 00    	je     f01017d5 <mem_init+0x4fa>
	assert(pp && pp0 == pp);
f01015de:	39 c3                	cmp    %eax,%ebx
f01015e0:	0f 85 08 02 00 00    	jne    f01017ee <mem_init+0x513>
	return (pp - pages) << PGSHIFT;
f01015e6:	2b 05 10 1f 23 f0    	sub    0xf0231f10,%eax
f01015ec:	c1 f8 03             	sar    $0x3,%eax
f01015ef:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f01015f2:	89 c2                	mov    %eax,%edx
f01015f4:	c1 ea 0c             	shr    $0xc,%edx
f01015f7:	3b 15 08 1f 23 f0    	cmp    0xf0231f08,%edx
f01015fd:	0f 83 04 02 00 00    	jae    f0101807 <mem_init+0x52c>
	return (void *)(pa + KERNBASE);
f0101603:	8d 90 00 00 00 f0    	lea    -0x10000000(%eax),%edx
f0101609:	2d 00 f0 ff 0f       	sub    $0xffff000,%eax
		assert(c[i] == 0);
f010160e:	80 3a 00             	cmpb   $0x0,(%edx)
f0101611:	0f 85 02 02 00 00    	jne    f0101819 <mem_init+0x53e>
f0101617:	83 c2 01             	add    $0x1,%edx
	for (i = 0; i < PGSIZE; i++)
f010161a:	39 c2                	cmp    %eax,%edx
f010161c:	75 f0                	jne    f010160e <mem_init+0x333>
	page_free_list = fl;
f010161e:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101621:	a3 3c 12 23 f0       	mov    %eax,0xf023123c
	page_free(pp0);
f0101626:	83 ec 0c             	sub    $0xc,%esp
f0101629:	53                   	push   %ebx
f010162a:	e8 94 f9 ff ff       	call   f0100fc3 <page_free>
	page_free(pp1);
f010162f:	89 34 24             	mov    %esi,(%esp)
f0101632:	e8 8c f9 ff ff       	call   f0100fc3 <page_free>
	page_free(pp2);
f0101637:	89 3c 24             	mov    %edi,(%esp)
f010163a:	e8 84 f9 ff ff       	call   f0100fc3 <page_free>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010163f:	a1 3c 12 23 f0       	mov    0xf023123c,%eax
f0101644:	83 c4 10             	add    $0x10,%esp
f0101647:	e9 ec 01 00 00       	jmp    f0101838 <mem_init+0x55d>
	assert((pp0 = page_alloc(0)));
f010164c:	68 b1 65 10 f0       	push   $0xf01065b1
f0101651:	68 ca 64 10 f0       	push   $0xf01064ca
f0101656:	68 12 03 00 00       	push   $0x312
f010165b:	68 9d 64 10 f0       	push   $0xf010649d
f0101660:	e8 2f ea ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f0101665:	68 c7 65 10 f0       	push   $0xf01065c7
f010166a:	68 ca 64 10 f0       	push   $0xf01064ca
f010166f:	68 13 03 00 00       	push   $0x313
f0101674:	68 9d 64 10 f0       	push   $0xf010649d
f0101679:	e8 16 ea ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f010167e:	68 dd 65 10 f0       	push   $0xf01065dd
f0101683:	68 ca 64 10 f0       	push   $0xf01064ca
f0101688:	68 14 03 00 00       	push   $0x314
f010168d:	68 9d 64 10 f0       	push   $0xf010649d
f0101692:	e8 fd e9 ff ff       	call   f0100094 <_panic>
	assert(pp1 && pp1 != pp0);
f0101697:	68 f3 65 10 f0       	push   $0xf01065f3
f010169c:	68 ca 64 10 f0       	push   $0xf01064ca
f01016a1:	68 17 03 00 00       	push   $0x317
f01016a6:	68 9d 64 10 f0       	push   $0xf010649d
f01016ab:	e8 e4 e9 ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01016b0:	68 80 5c 10 f0       	push   $0xf0105c80
f01016b5:	68 ca 64 10 f0       	push   $0xf01064ca
f01016ba:	68 18 03 00 00       	push   $0x318
f01016bf:	68 9d 64 10 f0       	push   $0xf010649d
f01016c4:	e8 cb e9 ff ff       	call   f0100094 <_panic>
	assert(page2pa(pp0) < npages*PGSIZE);
f01016c9:	68 05 66 10 f0       	push   $0xf0106605
f01016ce:	68 ca 64 10 f0       	push   $0xf01064ca
f01016d3:	68 19 03 00 00       	push   $0x319
f01016d8:	68 9d 64 10 f0       	push   $0xf010649d
f01016dd:	e8 b2 e9 ff ff       	call   f0100094 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f01016e2:	68 22 66 10 f0       	push   $0xf0106622
f01016e7:	68 ca 64 10 f0       	push   $0xf01064ca
f01016ec:	68 1a 03 00 00       	push   $0x31a
f01016f1:	68 9d 64 10 f0       	push   $0xf010649d
f01016f6:	e8 99 e9 ff ff       	call   f0100094 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f01016fb:	68 3f 66 10 f0       	push   $0xf010663f
f0101700:	68 ca 64 10 f0       	push   $0xf01064ca
f0101705:	68 1b 03 00 00       	push   $0x31b
f010170a:	68 9d 64 10 f0       	push   $0xf010649d
f010170f:	e8 80 e9 ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f0101714:	68 5c 66 10 f0       	push   $0xf010665c
f0101719:	68 ca 64 10 f0       	push   $0xf01064ca
f010171e:	68 22 03 00 00       	push   $0x322
f0101723:	68 9d 64 10 f0       	push   $0xf010649d
f0101728:	e8 67 e9 ff ff       	call   f0100094 <_panic>
	assert((pp0 = page_alloc(0)));
f010172d:	68 b1 65 10 f0       	push   $0xf01065b1
f0101732:	68 ca 64 10 f0       	push   $0xf01064ca
f0101737:	68 29 03 00 00       	push   $0x329
f010173c:	68 9d 64 10 f0       	push   $0xf010649d
f0101741:	e8 4e e9 ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f0101746:	68 c7 65 10 f0       	push   $0xf01065c7
f010174b:	68 ca 64 10 f0       	push   $0xf01064ca
f0101750:	68 2a 03 00 00       	push   $0x32a
f0101755:	68 9d 64 10 f0       	push   $0xf010649d
f010175a:	e8 35 e9 ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f010175f:	68 dd 65 10 f0       	push   $0xf01065dd
f0101764:	68 ca 64 10 f0       	push   $0xf01064ca
f0101769:	68 2b 03 00 00       	push   $0x32b
f010176e:	68 9d 64 10 f0       	push   $0xf010649d
f0101773:	e8 1c e9 ff ff       	call   f0100094 <_panic>
	assert(pp1 && pp1 != pp0);
f0101778:	68 f3 65 10 f0       	push   $0xf01065f3
f010177d:	68 ca 64 10 f0       	push   $0xf01064ca
f0101782:	68 2d 03 00 00       	push   $0x32d
f0101787:	68 9d 64 10 f0       	push   $0xf010649d
f010178c:	e8 03 e9 ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101791:	68 80 5c 10 f0       	push   $0xf0105c80
f0101796:	68 ca 64 10 f0       	push   $0xf01064ca
f010179b:	68 2e 03 00 00       	push   $0x32e
f01017a0:	68 9d 64 10 f0       	push   $0xf010649d
f01017a5:	e8 ea e8 ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f01017aa:	68 5c 66 10 f0       	push   $0xf010665c
f01017af:	68 ca 64 10 f0       	push   $0xf01064ca
f01017b4:	68 2f 03 00 00       	push   $0x32f
f01017b9:	68 9d 64 10 f0       	push   $0xf010649d
f01017be:	e8 d1 e8 ff ff       	call   f0100094 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01017c3:	50                   	push   %eax
f01017c4:	68 d4 55 10 f0       	push   $0xf01055d4
f01017c9:	6a 58                	push   $0x58
f01017cb:	68 b0 64 10 f0       	push   $0xf01064b0
f01017d0:	e8 bf e8 ff ff       	call   f0100094 <_panic>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01017d5:	68 6b 66 10 f0       	push   $0xf010666b
f01017da:	68 ca 64 10 f0       	push   $0xf01064ca
f01017df:	68 34 03 00 00       	push   $0x334
f01017e4:	68 9d 64 10 f0       	push   $0xf010649d
f01017e9:	e8 a6 e8 ff ff       	call   f0100094 <_panic>
	assert(pp && pp0 == pp);
f01017ee:	68 89 66 10 f0       	push   $0xf0106689
f01017f3:	68 ca 64 10 f0       	push   $0xf01064ca
f01017f8:	68 35 03 00 00       	push   $0x335
f01017fd:	68 9d 64 10 f0       	push   $0xf010649d
f0101802:	e8 8d e8 ff ff       	call   f0100094 <_panic>
f0101807:	50                   	push   %eax
f0101808:	68 d4 55 10 f0       	push   $0xf01055d4
f010180d:	6a 58                	push   $0x58
f010180f:	68 b0 64 10 f0       	push   $0xf01064b0
f0101814:	e8 7b e8 ff ff       	call   f0100094 <_panic>
		assert(c[i] == 0);
f0101819:	68 99 66 10 f0       	push   $0xf0106699
f010181e:	68 ca 64 10 f0       	push   $0xf01064ca
f0101823:	68 38 03 00 00       	push   $0x338
f0101828:	68 9d 64 10 f0       	push   $0xf010649d
f010182d:	e8 62 e8 ff ff       	call   f0100094 <_panic>
		--nfree;
f0101832:	83 6d d4 01          	subl   $0x1,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101836:	8b 00                	mov    (%eax),%eax
f0101838:	85 c0                	test   %eax,%eax
f010183a:	75 f6                	jne    f0101832 <mem_init+0x557>
	assert(nfree == 0);
f010183c:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0101840:	0f 85 14 09 00 00    	jne    f010215a <mem_init+0xe7f>
	cprintf("check_page_alloc() succeeded!\n");
f0101846:	83 ec 0c             	sub    $0xc,%esp
f0101849:	68 a0 5c 10 f0       	push   $0xf0105ca0
f010184e:	e8 7f 1f 00 00       	call   f01037d2 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101853:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010185a:	e8 f2 f6 ff ff       	call   f0100f51 <page_alloc>
f010185f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101862:	83 c4 10             	add    $0x10,%esp
f0101865:	85 c0                	test   %eax,%eax
f0101867:	0f 84 06 09 00 00    	je     f0102173 <mem_init+0xe98>
	assert((pp1 = page_alloc(0)));
f010186d:	83 ec 0c             	sub    $0xc,%esp
f0101870:	6a 00                	push   $0x0
f0101872:	e8 da f6 ff ff       	call   f0100f51 <page_alloc>
f0101877:	89 c7                	mov    %eax,%edi
f0101879:	83 c4 10             	add    $0x10,%esp
f010187c:	85 c0                	test   %eax,%eax
f010187e:	0f 84 08 09 00 00    	je     f010218c <mem_init+0xeb1>
	assert((pp2 = page_alloc(0)));
f0101884:	83 ec 0c             	sub    $0xc,%esp
f0101887:	6a 00                	push   $0x0
f0101889:	e8 c3 f6 ff ff       	call   f0100f51 <page_alloc>
f010188e:	89 c3                	mov    %eax,%ebx
f0101890:	83 c4 10             	add    $0x10,%esp
f0101893:	85 c0                	test   %eax,%eax
f0101895:	0f 84 0a 09 00 00    	je     f01021a5 <mem_init+0xeca>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010189b:	39 7d d4             	cmp    %edi,-0x2c(%ebp)
f010189e:	0f 84 1a 09 00 00    	je     f01021be <mem_init+0xee3>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01018a4:	39 c7                	cmp    %eax,%edi
f01018a6:	0f 84 2b 09 00 00    	je     f01021d7 <mem_init+0xefc>
f01018ac:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f01018af:	0f 84 22 09 00 00    	je     f01021d7 <mem_init+0xefc>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01018b5:	a1 3c 12 23 f0       	mov    0xf023123c,%eax
f01018ba:	89 45 cc             	mov    %eax,-0x34(%ebp)
	page_free_list = 0;
f01018bd:	c7 05 3c 12 23 f0 00 	movl   $0x0,0xf023123c
f01018c4:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01018c7:	83 ec 0c             	sub    $0xc,%esp
f01018ca:	6a 00                	push   $0x0
f01018cc:	e8 80 f6 ff ff       	call   f0100f51 <page_alloc>
f01018d1:	83 c4 10             	add    $0x10,%esp
f01018d4:	85 c0                	test   %eax,%eax
f01018d6:	0f 85 14 09 00 00    	jne    f01021f0 <mem_init+0xf15>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f01018dc:	83 ec 04             	sub    $0x4,%esp
f01018df:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01018e2:	50                   	push   %eax
f01018e3:	6a 00                	push   $0x0
f01018e5:	ff 35 0c 1f 23 f0    	pushl  0xf0231f0c
f01018eb:	e8 4b f8 ff ff       	call   f010113b <page_lookup>
f01018f0:	83 c4 10             	add    $0x10,%esp
f01018f3:	85 c0                	test   %eax,%eax
f01018f5:	0f 85 0e 09 00 00    	jne    f0102209 <mem_init+0xf2e>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01018fb:	6a 02                	push   $0x2
f01018fd:	6a 00                	push   $0x0
f01018ff:	57                   	push   %edi
f0101900:	ff 35 0c 1f 23 f0    	pushl  0xf0231f0c
f0101906:	e8 07 f9 ff ff       	call   f0101212 <page_insert>
f010190b:	83 c4 10             	add    $0x10,%esp
f010190e:	85 c0                	test   %eax,%eax
f0101910:	0f 89 0c 09 00 00    	jns    f0102222 <mem_init+0xf47>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101916:	83 ec 0c             	sub    $0xc,%esp
f0101919:	ff 75 d4             	pushl  -0x2c(%ebp)
f010191c:	e8 a2 f6 ff ff       	call   f0100fc3 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101921:	6a 02                	push   $0x2
f0101923:	6a 00                	push   $0x0
f0101925:	57                   	push   %edi
f0101926:	ff 35 0c 1f 23 f0    	pushl  0xf0231f0c
f010192c:	e8 e1 f8 ff ff       	call   f0101212 <page_insert>
f0101931:	83 c4 20             	add    $0x20,%esp
f0101934:	85 c0                	test   %eax,%eax
f0101936:	0f 85 ff 08 00 00    	jne    f010223b <mem_init+0xf60>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010193c:	8b 35 0c 1f 23 f0    	mov    0xf0231f0c,%esi
	return (pp - pages) << PGSHIFT;
f0101942:	8b 0d 10 1f 23 f0    	mov    0xf0231f10,%ecx
f0101948:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f010194b:	8b 16                	mov    (%esi),%edx
f010194d:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101953:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101956:	29 c8                	sub    %ecx,%eax
f0101958:	c1 f8 03             	sar    $0x3,%eax
f010195b:	c1 e0 0c             	shl    $0xc,%eax
f010195e:	39 c2                	cmp    %eax,%edx
f0101960:	0f 85 ee 08 00 00    	jne    f0102254 <mem_init+0xf79>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101966:	ba 00 00 00 00       	mov    $0x0,%edx
f010196b:	89 f0                	mov    %esi,%eax
f010196d:	e8 70 f1 ff ff       	call   f0100ae2 <check_va2pa>
f0101972:	89 fa                	mov    %edi,%edx
f0101974:	2b 55 d0             	sub    -0x30(%ebp),%edx
f0101977:	c1 fa 03             	sar    $0x3,%edx
f010197a:	c1 e2 0c             	shl    $0xc,%edx
f010197d:	39 d0                	cmp    %edx,%eax
f010197f:	0f 85 e8 08 00 00    	jne    f010226d <mem_init+0xf92>
	assert(pp1->pp_ref == 1);
f0101985:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f010198a:	0f 85 f6 08 00 00    	jne    f0102286 <mem_init+0xfab>
	assert(pp0->pp_ref == 1);
f0101990:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101993:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101998:	0f 85 01 09 00 00    	jne    f010229f <mem_init+0xfc4>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010199e:	6a 02                	push   $0x2
f01019a0:	68 00 10 00 00       	push   $0x1000
f01019a5:	53                   	push   %ebx
f01019a6:	56                   	push   %esi
f01019a7:	e8 66 f8 ff ff       	call   f0101212 <page_insert>
f01019ac:	83 c4 10             	add    $0x10,%esp
f01019af:	85 c0                	test   %eax,%eax
f01019b1:	0f 85 01 09 00 00    	jne    f01022b8 <mem_init+0xfdd>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01019b7:	ba 00 10 00 00       	mov    $0x1000,%edx
f01019bc:	a1 0c 1f 23 f0       	mov    0xf0231f0c,%eax
f01019c1:	e8 1c f1 ff ff       	call   f0100ae2 <check_va2pa>
f01019c6:	89 da                	mov    %ebx,%edx
f01019c8:	2b 15 10 1f 23 f0    	sub    0xf0231f10,%edx
f01019ce:	c1 fa 03             	sar    $0x3,%edx
f01019d1:	c1 e2 0c             	shl    $0xc,%edx
f01019d4:	39 d0                	cmp    %edx,%eax
f01019d6:	0f 85 f5 08 00 00    	jne    f01022d1 <mem_init+0xff6>
	assert(pp2->pp_ref == 1);
f01019dc:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01019e1:	0f 85 03 09 00 00    	jne    f01022ea <mem_init+0x100f>

	// should be no free memory
	assert(!page_alloc(0));
f01019e7:	83 ec 0c             	sub    $0xc,%esp
f01019ea:	6a 00                	push   $0x0
f01019ec:	e8 60 f5 ff ff       	call   f0100f51 <page_alloc>
f01019f1:	83 c4 10             	add    $0x10,%esp
f01019f4:	85 c0                	test   %eax,%eax
f01019f6:	0f 85 07 09 00 00    	jne    f0102303 <mem_init+0x1028>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01019fc:	6a 02                	push   $0x2
f01019fe:	68 00 10 00 00       	push   $0x1000
f0101a03:	53                   	push   %ebx
f0101a04:	ff 35 0c 1f 23 f0    	pushl  0xf0231f0c
f0101a0a:	e8 03 f8 ff ff       	call   f0101212 <page_insert>
f0101a0f:	83 c4 10             	add    $0x10,%esp
f0101a12:	85 c0                	test   %eax,%eax
f0101a14:	0f 85 02 09 00 00    	jne    f010231c <mem_init+0x1041>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101a1a:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101a1f:	a1 0c 1f 23 f0       	mov    0xf0231f0c,%eax
f0101a24:	e8 b9 f0 ff ff       	call   f0100ae2 <check_va2pa>
f0101a29:	89 da                	mov    %ebx,%edx
f0101a2b:	2b 15 10 1f 23 f0    	sub    0xf0231f10,%edx
f0101a31:	c1 fa 03             	sar    $0x3,%edx
f0101a34:	c1 e2 0c             	shl    $0xc,%edx
f0101a37:	39 d0                	cmp    %edx,%eax
f0101a39:	0f 85 f6 08 00 00    	jne    f0102335 <mem_init+0x105a>
	assert(pp2->pp_ref == 1);
f0101a3f:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101a44:	0f 85 04 09 00 00    	jne    f010234e <mem_init+0x1073>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101a4a:	83 ec 0c             	sub    $0xc,%esp
f0101a4d:	6a 00                	push   $0x0
f0101a4f:	e8 fd f4 ff ff       	call   f0100f51 <page_alloc>
f0101a54:	83 c4 10             	add    $0x10,%esp
f0101a57:	85 c0                	test   %eax,%eax
f0101a59:	0f 85 08 09 00 00    	jne    f0102367 <mem_init+0x108c>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101a5f:	8b 15 0c 1f 23 f0    	mov    0xf0231f0c,%edx
f0101a65:	8b 02                	mov    (%edx),%eax
f0101a67:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0101a6c:	89 c1                	mov    %eax,%ecx
f0101a6e:	c1 e9 0c             	shr    $0xc,%ecx
f0101a71:	3b 0d 08 1f 23 f0    	cmp    0xf0231f08,%ecx
f0101a77:	0f 83 03 09 00 00    	jae    f0102380 <mem_init+0x10a5>
	return (void *)(pa + KERNBASE);
f0101a7d:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101a82:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101a85:	83 ec 04             	sub    $0x4,%esp
f0101a88:	6a 00                	push   $0x0
f0101a8a:	68 00 10 00 00       	push   $0x1000
f0101a8f:	52                   	push   %edx
f0101a90:	e8 92 f5 ff ff       	call   f0101027 <pgdir_walk>
f0101a95:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101a98:	8d 51 04             	lea    0x4(%ecx),%edx
f0101a9b:	83 c4 10             	add    $0x10,%esp
f0101a9e:	39 d0                	cmp    %edx,%eax
f0101aa0:	0f 85 ef 08 00 00    	jne    f0102395 <mem_init+0x10ba>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101aa6:	6a 06                	push   $0x6
f0101aa8:	68 00 10 00 00       	push   $0x1000
f0101aad:	53                   	push   %ebx
f0101aae:	ff 35 0c 1f 23 f0    	pushl  0xf0231f0c
f0101ab4:	e8 59 f7 ff ff       	call   f0101212 <page_insert>
f0101ab9:	83 c4 10             	add    $0x10,%esp
f0101abc:	85 c0                	test   %eax,%eax
f0101abe:	0f 85 ea 08 00 00    	jne    f01023ae <mem_init+0x10d3>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101ac4:	8b 35 0c 1f 23 f0    	mov    0xf0231f0c,%esi
f0101aca:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101acf:	89 f0                	mov    %esi,%eax
f0101ad1:	e8 0c f0 ff ff       	call   f0100ae2 <check_va2pa>
	return (pp - pages) << PGSHIFT;
f0101ad6:	89 da                	mov    %ebx,%edx
f0101ad8:	2b 15 10 1f 23 f0    	sub    0xf0231f10,%edx
f0101ade:	c1 fa 03             	sar    $0x3,%edx
f0101ae1:	c1 e2 0c             	shl    $0xc,%edx
f0101ae4:	39 d0                	cmp    %edx,%eax
f0101ae6:	0f 85 db 08 00 00    	jne    f01023c7 <mem_init+0x10ec>
	assert(pp2->pp_ref == 1);
f0101aec:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101af1:	0f 85 e9 08 00 00    	jne    f01023e0 <mem_init+0x1105>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101af7:	83 ec 04             	sub    $0x4,%esp
f0101afa:	6a 00                	push   $0x0
f0101afc:	68 00 10 00 00       	push   $0x1000
f0101b01:	56                   	push   %esi
f0101b02:	e8 20 f5 ff ff       	call   f0101027 <pgdir_walk>
f0101b07:	83 c4 10             	add    $0x10,%esp
f0101b0a:	f6 00 04             	testb  $0x4,(%eax)
f0101b0d:	0f 84 e6 08 00 00    	je     f01023f9 <mem_init+0x111e>
	assert(kern_pgdir[0] & PTE_U);
f0101b13:	a1 0c 1f 23 f0       	mov    0xf0231f0c,%eax
f0101b18:	f6 00 04             	testb  $0x4,(%eax)
f0101b1b:	0f 84 f1 08 00 00    	je     f0102412 <mem_init+0x1137>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101b21:	6a 02                	push   $0x2
f0101b23:	68 00 10 00 00       	push   $0x1000
f0101b28:	53                   	push   %ebx
f0101b29:	50                   	push   %eax
f0101b2a:	e8 e3 f6 ff ff       	call   f0101212 <page_insert>
f0101b2f:	83 c4 10             	add    $0x10,%esp
f0101b32:	85 c0                	test   %eax,%eax
f0101b34:	0f 85 f1 08 00 00    	jne    f010242b <mem_init+0x1150>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101b3a:	83 ec 04             	sub    $0x4,%esp
f0101b3d:	6a 00                	push   $0x0
f0101b3f:	68 00 10 00 00       	push   $0x1000
f0101b44:	ff 35 0c 1f 23 f0    	pushl  0xf0231f0c
f0101b4a:	e8 d8 f4 ff ff       	call   f0101027 <pgdir_walk>
f0101b4f:	83 c4 10             	add    $0x10,%esp
f0101b52:	f6 00 02             	testb  $0x2,(%eax)
f0101b55:	0f 84 e9 08 00 00    	je     f0102444 <mem_init+0x1169>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101b5b:	83 ec 04             	sub    $0x4,%esp
f0101b5e:	6a 00                	push   $0x0
f0101b60:	68 00 10 00 00       	push   $0x1000
f0101b65:	ff 35 0c 1f 23 f0    	pushl  0xf0231f0c
f0101b6b:	e8 b7 f4 ff ff       	call   f0101027 <pgdir_walk>
f0101b70:	83 c4 10             	add    $0x10,%esp
f0101b73:	f6 00 04             	testb  $0x4,(%eax)
f0101b76:	0f 85 e1 08 00 00    	jne    f010245d <mem_init+0x1182>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101b7c:	6a 02                	push   $0x2
f0101b7e:	68 00 00 40 00       	push   $0x400000
f0101b83:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101b86:	ff 35 0c 1f 23 f0    	pushl  0xf0231f0c
f0101b8c:	e8 81 f6 ff ff       	call   f0101212 <page_insert>
f0101b91:	83 c4 10             	add    $0x10,%esp
f0101b94:	85 c0                	test   %eax,%eax
f0101b96:	0f 89 da 08 00 00    	jns    f0102476 <mem_init+0x119b>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101b9c:	6a 02                	push   $0x2
f0101b9e:	68 00 10 00 00       	push   $0x1000
f0101ba3:	57                   	push   %edi
f0101ba4:	ff 35 0c 1f 23 f0    	pushl  0xf0231f0c
f0101baa:	e8 63 f6 ff ff       	call   f0101212 <page_insert>
f0101baf:	83 c4 10             	add    $0x10,%esp
f0101bb2:	85 c0                	test   %eax,%eax
f0101bb4:	0f 85 d5 08 00 00    	jne    f010248f <mem_init+0x11b4>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101bba:	83 ec 04             	sub    $0x4,%esp
f0101bbd:	6a 00                	push   $0x0
f0101bbf:	68 00 10 00 00       	push   $0x1000
f0101bc4:	ff 35 0c 1f 23 f0    	pushl  0xf0231f0c
f0101bca:	e8 58 f4 ff ff       	call   f0101027 <pgdir_walk>
f0101bcf:	83 c4 10             	add    $0x10,%esp
f0101bd2:	f6 00 04             	testb  $0x4,(%eax)
f0101bd5:	0f 85 cd 08 00 00    	jne    f01024a8 <mem_init+0x11cd>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101bdb:	a1 0c 1f 23 f0       	mov    0xf0231f0c,%eax
f0101be0:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101be3:	ba 00 00 00 00       	mov    $0x0,%edx
f0101be8:	e8 f5 ee ff ff       	call   f0100ae2 <check_va2pa>
f0101bed:	89 fe                	mov    %edi,%esi
f0101bef:	2b 35 10 1f 23 f0    	sub    0xf0231f10,%esi
f0101bf5:	c1 fe 03             	sar    $0x3,%esi
f0101bf8:	c1 e6 0c             	shl    $0xc,%esi
f0101bfb:	39 f0                	cmp    %esi,%eax
f0101bfd:	0f 85 be 08 00 00    	jne    f01024c1 <mem_init+0x11e6>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101c03:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c08:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101c0b:	e8 d2 ee ff ff       	call   f0100ae2 <check_va2pa>
f0101c10:	39 c6                	cmp    %eax,%esi
f0101c12:	0f 85 c2 08 00 00    	jne    f01024da <mem_init+0x11ff>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101c18:	66 83 7f 04 02       	cmpw   $0x2,0x4(%edi)
f0101c1d:	0f 85 d0 08 00 00    	jne    f01024f3 <mem_init+0x1218>
	assert(pp2->pp_ref == 0);
f0101c23:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101c28:	0f 85 de 08 00 00    	jne    f010250c <mem_init+0x1231>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101c2e:	83 ec 0c             	sub    $0xc,%esp
f0101c31:	6a 00                	push   $0x0
f0101c33:	e8 19 f3 ff ff       	call   f0100f51 <page_alloc>
f0101c38:	83 c4 10             	add    $0x10,%esp
f0101c3b:	39 c3                	cmp    %eax,%ebx
f0101c3d:	0f 85 e2 08 00 00    	jne    f0102525 <mem_init+0x124a>
f0101c43:	85 c0                	test   %eax,%eax
f0101c45:	0f 84 da 08 00 00    	je     f0102525 <mem_init+0x124a>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101c4b:	83 ec 08             	sub    $0x8,%esp
f0101c4e:	6a 00                	push   $0x0
f0101c50:	ff 35 0c 1f 23 f0    	pushl  0xf0231f0c
f0101c56:	e8 71 f5 ff ff       	call   f01011cc <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101c5b:	8b 35 0c 1f 23 f0    	mov    0xf0231f0c,%esi
f0101c61:	ba 00 00 00 00       	mov    $0x0,%edx
f0101c66:	89 f0                	mov    %esi,%eax
f0101c68:	e8 75 ee ff ff       	call   f0100ae2 <check_va2pa>
f0101c6d:	83 c4 10             	add    $0x10,%esp
f0101c70:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101c73:	0f 85 c5 08 00 00    	jne    f010253e <mem_init+0x1263>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101c79:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c7e:	89 f0                	mov    %esi,%eax
f0101c80:	e8 5d ee ff ff       	call   f0100ae2 <check_va2pa>
f0101c85:	89 fa                	mov    %edi,%edx
f0101c87:	2b 15 10 1f 23 f0    	sub    0xf0231f10,%edx
f0101c8d:	c1 fa 03             	sar    $0x3,%edx
f0101c90:	c1 e2 0c             	shl    $0xc,%edx
f0101c93:	39 d0                	cmp    %edx,%eax
f0101c95:	0f 85 bc 08 00 00    	jne    f0102557 <mem_init+0x127c>
	assert(pp1->pp_ref == 1);
f0101c9b:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101ca0:	0f 85 ca 08 00 00    	jne    f0102570 <mem_init+0x1295>
	assert(pp2->pp_ref == 0);
f0101ca6:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101cab:	0f 85 d8 08 00 00    	jne    f0102589 <mem_init+0x12ae>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101cb1:	6a 00                	push   $0x0
f0101cb3:	68 00 10 00 00       	push   $0x1000
f0101cb8:	57                   	push   %edi
f0101cb9:	56                   	push   %esi
f0101cba:	e8 53 f5 ff ff       	call   f0101212 <page_insert>
f0101cbf:	83 c4 10             	add    $0x10,%esp
f0101cc2:	85 c0                	test   %eax,%eax
f0101cc4:	0f 85 d8 08 00 00    	jne    f01025a2 <mem_init+0x12c7>
	assert(pp1->pp_ref);
f0101cca:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101ccf:	0f 84 e6 08 00 00    	je     f01025bb <mem_init+0x12e0>
	assert(pp1->pp_link == NULL);
f0101cd5:	83 3f 00             	cmpl   $0x0,(%edi)
f0101cd8:	0f 85 f6 08 00 00    	jne    f01025d4 <mem_init+0x12f9>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101cde:	83 ec 08             	sub    $0x8,%esp
f0101ce1:	68 00 10 00 00       	push   $0x1000
f0101ce6:	ff 35 0c 1f 23 f0    	pushl  0xf0231f0c
f0101cec:	e8 db f4 ff ff       	call   f01011cc <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101cf1:	8b 35 0c 1f 23 f0    	mov    0xf0231f0c,%esi
f0101cf7:	ba 00 00 00 00       	mov    $0x0,%edx
f0101cfc:	89 f0                	mov    %esi,%eax
f0101cfe:	e8 df ed ff ff       	call   f0100ae2 <check_va2pa>
f0101d03:	83 c4 10             	add    $0x10,%esp
f0101d06:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101d09:	0f 85 de 08 00 00    	jne    f01025ed <mem_init+0x1312>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101d0f:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d14:	89 f0                	mov    %esi,%eax
f0101d16:	e8 c7 ed ff ff       	call   f0100ae2 <check_va2pa>
f0101d1b:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101d1e:	0f 85 e2 08 00 00    	jne    f0102606 <mem_init+0x132b>
	assert(pp1->pp_ref == 0);
f0101d24:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101d29:	0f 85 f0 08 00 00    	jne    f010261f <mem_init+0x1344>
	assert(pp2->pp_ref == 0);
f0101d2f:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101d34:	0f 85 fe 08 00 00    	jne    f0102638 <mem_init+0x135d>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101d3a:	83 ec 0c             	sub    $0xc,%esp
f0101d3d:	6a 00                	push   $0x0
f0101d3f:	e8 0d f2 ff ff       	call   f0100f51 <page_alloc>
f0101d44:	83 c4 10             	add    $0x10,%esp
f0101d47:	85 c0                	test   %eax,%eax
f0101d49:	0f 84 02 09 00 00    	je     f0102651 <mem_init+0x1376>
f0101d4f:	39 c7                	cmp    %eax,%edi
f0101d51:	0f 85 fa 08 00 00    	jne    f0102651 <mem_init+0x1376>

	// should be no free memory
	assert(!page_alloc(0));
f0101d57:	83 ec 0c             	sub    $0xc,%esp
f0101d5a:	6a 00                	push   $0x0
f0101d5c:	e8 f0 f1 ff ff       	call   f0100f51 <page_alloc>
f0101d61:	83 c4 10             	add    $0x10,%esp
f0101d64:	85 c0                	test   %eax,%eax
f0101d66:	0f 85 fe 08 00 00    	jne    f010266a <mem_init+0x138f>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101d6c:	8b 0d 0c 1f 23 f0    	mov    0xf0231f0c,%ecx
f0101d72:	8b 11                	mov    (%ecx),%edx
f0101d74:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101d7a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d7d:	2b 05 10 1f 23 f0    	sub    0xf0231f10,%eax
f0101d83:	c1 f8 03             	sar    $0x3,%eax
f0101d86:	c1 e0 0c             	shl    $0xc,%eax
f0101d89:	39 c2                	cmp    %eax,%edx
f0101d8b:	0f 85 f2 08 00 00    	jne    f0102683 <mem_init+0x13a8>
	kern_pgdir[0] = 0;
f0101d91:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0101d97:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d9a:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101d9f:	0f 85 f7 08 00 00    	jne    f010269c <mem_init+0x13c1>
	pp0->pp_ref = 0;
f0101da5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101da8:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0101dae:	83 ec 0c             	sub    $0xc,%esp
f0101db1:	50                   	push   %eax
f0101db2:	e8 0c f2 ff ff       	call   f0100fc3 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0101db7:	83 c4 0c             	add    $0xc,%esp
f0101dba:	6a 01                	push   $0x1
f0101dbc:	68 00 10 40 00       	push   $0x401000
f0101dc1:	ff 35 0c 1f 23 f0    	pushl  0xf0231f0c
f0101dc7:	e8 5b f2 ff ff       	call   f0101027 <pgdir_walk>
f0101dcc:	89 c1                	mov    %eax,%ecx
f0101dce:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0101dd1:	a1 0c 1f 23 f0       	mov    0xf0231f0c,%eax
f0101dd6:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101dd9:	8b 40 04             	mov    0x4(%eax),%eax
f0101ddc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0101de1:	8b 35 08 1f 23 f0    	mov    0xf0231f08,%esi
f0101de7:	89 c2                	mov    %eax,%edx
f0101de9:	c1 ea 0c             	shr    $0xc,%edx
f0101dec:	83 c4 10             	add    $0x10,%esp
f0101def:	39 f2                	cmp    %esi,%edx
f0101df1:	0f 83 be 08 00 00    	jae    f01026b5 <mem_init+0x13da>
	assert(ptep == ptep1 + PTX(va));
f0101df7:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f0101dfc:	39 c1                	cmp    %eax,%ecx
f0101dfe:	0f 85 c6 08 00 00    	jne    f01026ca <mem_init+0x13ef>
	kern_pgdir[PDX(va)] = 0;
f0101e04:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101e07:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f0101e0e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e11:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f0101e17:	2b 05 10 1f 23 f0    	sub    0xf0231f10,%eax
f0101e1d:	c1 f8 03             	sar    $0x3,%eax
f0101e20:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0101e23:	89 c2                	mov    %eax,%edx
f0101e25:	c1 ea 0c             	shr    $0xc,%edx
f0101e28:	39 d6                	cmp    %edx,%esi
f0101e2a:	0f 86 b3 08 00 00    	jbe    f01026e3 <mem_init+0x1408>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0101e30:	83 ec 04             	sub    $0x4,%esp
f0101e33:	68 00 10 00 00       	push   $0x1000
f0101e38:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f0101e3d:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101e42:	50                   	push   %eax
f0101e43:	e8 7f 2a 00 00       	call   f01048c7 <memset>
	page_free(pp0);
f0101e48:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0101e4b:	89 34 24             	mov    %esi,(%esp)
f0101e4e:	e8 70 f1 ff ff       	call   f0100fc3 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0101e53:	83 c4 0c             	add    $0xc,%esp
f0101e56:	6a 01                	push   $0x1
f0101e58:	6a 00                	push   $0x0
f0101e5a:	ff 35 0c 1f 23 f0    	pushl  0xf0231f0c
f0101e60:	e8 c2 f1 ff ff       	call   f0101027 <pgdir_walk>
	return (pp - pages) << PGSHIFT;
f0101e65:	89 f0                	mov    %esi,%eax
f0101e67:	2b 05 10 1f 23 f0    	sub    0xf0231f10,%eax
f0101e6d:	c1 f8 03             	sar    $0x3,%eax
f0101e70:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0101e73:	89 c2                	mov    %eax,%edx
f0101e75:	c1 ea 0c             	shr    $0xc,%edx
f0101e78:	83 c4 10             	add    $0x10,%esp
f0101e7b:	3b 15 08 1f 23 f0    	cmp    0xf0231f08,%edx
f0101e81:	0f 83 6e 08 00 00    	jae    f01026f5 <mem_init+0x141a>
	return (void *)(pa + KERNBASE);
f0101e87:	8d 90 00 00 00 f0    	lea    -0x10000000(%eax),%edx
	ptep = (pte_t *) page2kva(pp0);
f0101e8d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0101e90:	2d 00 f0 ff 0f       	sub    $0xffff000,%eax
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0101e95:	f6 02 01             	testb  $0x1,(%edx)
f0101e98:	0f 85 69 08 00 00    	jne    f0102707 <mem_init+0x142c>
f0101e9e:	83 c2 04             	add    $0x4,%edx
	for(i=0; i<NPTENTRIES; i++)
f0101ea1:	39 c2                	cmp    %eax,%edx
f0101ea3:	75 f0                	jne    f0101e95 <mem_init+0xbba>
	kern_pgdir[0] = 0;
f0101ea5:	a1 0c 1f 23 f0       	mov    0xf0231f0c,%eax
f0101eaa:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0101eb0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101eb3:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0101eb9:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0101ebc:	89 0d 3c 12 23 f0    	mov    %ecx,0xf023123c

	// free the pages we took
	page_free(pp0);
f0101ec2:	83 ec 0c             	sub    $0xc,%esp
f0101ec5:	50                   	push   %eax
f0101ec6:	e8 f8 f0 ff ff       	call   f0100fc3 <page_free>
	page_free(pp1);
f0101ecb:	89 3c 24             	mov    %edi,(%esp)
f0101ece:	e8 f0 f0 ff ff       	call   f0100fc3 <page_free>
	page_free(pp2);
f0101ed3:	89 1c 24             	mov    %ebx,(%esp)
f0101ed6:	e8 e8 f0 ff ff       	call   f0100fc3 <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f0101edb:	83 c4 08             	add    $0x8,%esp
f0101ede:	68 01 10 00 00       	push   $0x1001
f0101ee3:	6a 00                	push   $0x0
f0101ee5:	e8 8e f3 ff ff       	call   f0101278 <mmio_map_region>
f0101eea:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f0101eec:	83 c4 08             	add    $0x8,%esp
f0101eef:	68 00 10 00 00       	push   $0x1000
f0101ef4:	6a 00                	push   $0x0
f0101ef6:	e8 7d f3 ff ff       	call   f0101278 <mmio_map_region>
f0101efb:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8192 < MMIOLIM);
f0101efd:	8d 83 00 20 00 00    	lea    0x2000(%ebx),%eax
f0101f03:	83 c4 10             	add    $0x10,%esp
f0101f06:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0101f0c:	0f 86 0e 08 00 00    	jbe    f0102720 <mem_init+0x1445>
f0101f12:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0101f17:	0f 87 03 08 00 00    	ja     f0102720 <mem_init+0x1445>
	assert(mm2 >= MMIOBASE && mm2 + 8192 < MMIOLIM);
f0101f1d:	8d 96 00 20 00 00    	lea    0x2000(%esi),%edx
f0101f23:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f0101f29:	0f 87 0a 08 00 00    	ja     f0102739 <mem_init+0x145e>
f0101f2f:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0101f35:	0f 86 fe 07 00 00    	jbe    f0102739 <mem_init+0x145e>
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0101f3b:	89 da                	mov    %ebx,%edx
f0101f3d:	09 f2                	or     %esi,%edx
f0101f3f:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0101f45:	0f 85 07 08 00 00    	jne    f0102752 <mem_init+0x1477>
	// check that they don't overlap
	assert(mm1 + 8192 <= mm2);
f0101f4b:	39 c6                	cmp    %eax,%esi
f0101f4d:	0f 82 18 08 00 00    	jb     f010276b <mem_init+0x1490>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0101f53:	8b 3d 0c 1f 23 f0    	mov    0xf0231f0c,%edi
f0101f59:	89 da                	mov    %ebx,%edx
f0101f5b:	89 f8                	mov    %edi,%eax
f0101f5d:	e8 80 eb ff ff       	call   f0100ae2 <check_va2pa>
f0101f62:	85 c0                	test   %eax,%eax
f0101f64:	0f 85 1a 08 00 00    	jne    f0102784 <mem_init+0x14a9>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0101f6a:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f0101f70:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101f73:	89 c2                	mov    %eax,%edx
f0101f75:	89 f8                	mov    %edi,%eax
f0101f77:	e8 66 eb ff ff       	call   f0100ae2 <check_va2pa>
f0101f7c:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0101f81:	0f 85 16 08 00 00    	jne    f010279d <mem_init+0x14c2>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0101f87:	89 f2                	mov    %esi,%edx
f0101f89:	89 f8                	mov    %edi,%eax
f0101f8b:	e8 52 eb ff ff       	call   f0100ae2 <check_va2pa>
f0101f90:	85 c0                	test   %eax,%eax
f0101f92:	0f 85 1e 08 00 00    	jne    f01027b6 <mem_init+0x14db>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0101f98:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f0101f9e:	89 f8                	mov    %edi,%eax
f0101fa0:	e8 3d eb ff ff       	call   f0100ae2 <check_va2pa>
f0101fa5:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101fa8:	0f 85 21 08 00 00    	jne    f01027cf <mem_init+0x14f4>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f0101fae:	83 ec 04             	sub    $0x4,%esp
f0101fb1:	6a 00                	push   $0x0
f0101fb3:	53                   	push   %ebx
f0101fb4:	57                   	push   %edi
f0101fb5:	e8 6d f0 ff ff       	call   f0101027 <pgdir_walk>
f0101fba:	83 c4 10             	add    $0x10,%esp
f0101fbd:	f6 00 1a             	testb  $0x1a,(%eax)
f0101fc0:	0f 84 22 08 00 00    	je     f01027e8 <mem_init+0x150d>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0101fc6:	83 ec 04             	sub    $0x4,%esp
f0101fc9:	6a 00                	push   $0x0
f0101fcb:	53                   	push   %ebx
f0101fcc:	ff 35 0c 1f 23 f0    	pushl  0xf0231f0c
f0101fd2:	e8 50 f0 ff ff       	call   f0101027 <pgdir_walk>
f0101fd7:	83 c4 10             	add    $0x10,%esp
f0101fda:	f6 00 04             	testb  $0x4,(%eax)
f0101fdd:	0f 85 1e 08 00 00    	jne    f0102801 <mem_init+0x1526>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f0101fe3:	83 ec 04             	sub    $0x4,%esp
f0101fe6:	6a 00                	push   $0x0
f0101fe8:	53                   	push   %ebx
f0101fe9:	ff 35 0c 1f 23 f0    	pushl  0xf0231f0c
f0101fef:	e8 33 f0 ff ff       	call   f0101027 <pgdir_walk>
f0101ff4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f0101ffa:	83 c4 0c             	add    $0xc,%esp
f0101ffd:	6a 00                	push   $0x0
f0101fff:	ff 75 d4             	pushl  -0x2c(%ebp)
f0102002:	ff 35 0c 1f 23 f0    	pushl  0xf0231f0c
f0102008:	e8 1a f0 ff ff       	call   f0101027 <pgdir_walk>
f010200d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f0102013:	83 c4 0c             	add    $0xc,%esp
f0102016:	6a 00                	push   $0x0
f0102018:	56                   	push   %esi
f0102019:	ff 35 0c 1f 23 f0    	pushl  0xf0231f0c
f010201f:	e8 03 f0 ff ff       	call   f0101027 <pgdir_walk>
f0102024:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f010202a:	c7 04 24 8c 67 10 f0 	movl   $0xf010678c,(%esp)
f0102031:	e8 9c 17 00 00       	call   f01037d2 <cprintf>
	boot_map_region(kern_pgdir, (uintptr_t) UPAGES, npages*sizeof(struct PageInfo), PADDR(pages), PTE_U | PTE_P);
f0102036:	a1 10 1f 23 f0       	mov    0xf0231f10,%eax
	if ((uint32_t)kva < KERNBASE)
f010203b:	83 c4 10             	add    $0x10,%esp
f010203e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102043:	0f 86 d1 07 00 00    	jbe    f010281a <mem_init+0x153f>
f0102049:	8b 0d 08 1f 23 f0    	mov    0xf0231f08,%ecx
f010204f:	c1 e1 03             	shl    $0x3,%ecx
f0102052:	83 ec 08             	sub    $0x8,%esp
f0102055:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f0102057:	05 00 00 00 10       	add    $0x10000000,%eax
f010205c:	50                   	push   %eax
f010205d:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102062:	a1 0c 1f 23 f0       	mov    0xf0231f0c,%eax
f0102067:	e8 7b f0 ff ff       	call   f01010e7 <boot_map_region>
	boot_map_region(kern_pgdir, (uintptr_t) UENVS, ROUNDUP(NENV * sizeof(struct Env), PGSIZE), PADDR(envs), PTE_U | PTE_P);
f010206c:	a1 44 12 23 f0       	mov    0xf0231244,%eax
	if ((uint32_t)kva < KERNBASE)
f0102071:	83 c4 10             	add    $0x10,%esp
f0102074:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102079:	0f 86 b0 07 00 00    	jbe    f010282f <mem_init+0x1554>
f010207f:	83 ec 08             	sub    $0x8,%esp
f0102082:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f0102084:	05 00 00 00 10       	add    $0x10000000,%eax
f0102089:	50                   	push   %eax
f010208a:	b9 00 f0 01 00       	mov    $0x1f000,%ecx
f010208f:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102094:	a1 0c 1f 23 f0       	mov    0xf0231f0c,%eax
f0102099:	e8 49 f0 ff ff       	call   f01010e7 <boot_map_region>
	if ((uint32_t)kva < KERNBASE)
f010209e:	83 c4 10             	add    $0x10,%esp
f01020a1:	b8 00 70 11 f0       	mov    $0xf0117000,%eax
f01020a6:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01020ab:	0f 86 93 07 00 00    	jbe    f0102844 <mem_init+0x1569>
	boot_map_region(kern_pgdir, (uintptr_t) (KSTACKTOP-KSTKSIZE), KSTKSIZE, PADDR(bootstack), PTE_W | PTE_P);
f01020b1:	83 ec 08             	sub    $0x8,%esp
f01020b4:	6a 03                	push   $0x3
f01020b6:	68 00 70 11 00       	push   $0x117000
f01020bb:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01020c0:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f01020c5:	a1 0c 1f 23 f0       	mov    0xf0231f0c,%eax
f01020ca:	e8 18 f0 ff ff       	call   f01010e7 <boot_map_region>
	boot_map_region(kern_pgdir, (uintptr_t) KERNBASE, ROUNDUP(0xffffffff - KERNBASE, PGSIZE), 0, PTE_W | PTE_P);
f01020cf:	83 c4 08             	add    $0x8,%esp
f01020d2:	6a 03                	push   $0x3
f01020d4:	6a 00                	push   $0x0
f01020d6:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f01020db:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f01020e0:	a1 0c 1f 23 f0       	mov    0xf0231f0c,%eax
f01020e5:	e8 fd ef ff ff       	call   f01010e7 <boot_map_region>
	pgdir = kern_pgdir;
f01020ea:	8b 3d 0c 1f 23 f0    	mov    0xf0231f0c,%edi
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f01020f0:	a1 08 1f 23 f0       	mov    0xf0231f08,%eax
f01020f5:	89 45 c8             	mov    %eax,-0x38(%ebp)
f01020f8:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f01020ff:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102104:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102107:	8b 35 10 1f 23 f0    	mov    0xf0231f10,%esi
f010210d:	89 75 d0             	mov    %esi,-0x30(%ebp)
	return (physaddr_t)kva - KERNBASE;
f0102110:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f0102116:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102119:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < n; i += PGSIZE)
f010211c:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102121:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0102124:	0f 86 5d 07 00 00    	jbe    f0102887 <mem_init+0x15ac>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010212a:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f0102130:	89 f8                	mov    %edi,%eax
f0102132:	e8 ab e9 ff ff       	call   f0100ae2 <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f0102137:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f010213e:	0f 86 15 07 00 00    	jbe    f0102859 <mem_init+0x157e>
f0102144:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0102147:	8d 14 0b             	lea    (%ebx,%ecx,1),%edx
f010214a:	39 d0                	cmp    %edx,%eax
f010214c:	0f 85 1c 07 00 00    	jne    f010286e <mem_init+0x1593>
	for (i = 0; i < n; i += PGSIZE)
f0102152:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102158:	eb c7                	jmp    f0102121 <mem_init+0xe46>
	assert(nfree == 0);
f010215a:	68 a3 66 10 f0       	push   $0xf01066a3
f010215f:	68 ca 64 10 f0       	push   $0xf01064ca
f0102164:	68 45 03 00 00       	push   $0x345
f0102169:	68 9d 64 10 f0       	push   $0xf010649d
f010216e:	e8 21 df ff ff       	call   f0100094 <_panic>
	assert((pp0 = page_alloc(0)));
f0102173:	68 b1 65 10 f0       	push   $0xf01065b1
f0102178:	68 ca 64 10 f0       	push   $0xf01064ca
f010217d:	68 b5 03 00 00       	push   $0x3b5
f0102182:	68 9d 64 10 f0       	push   $0xf010649d
f0102187:	e8 08 df ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f010218c:	68 c7 65 10 f0       	push   $0xf01065c7
f0102191:	68 ca 64 10 f0       	push   $0xf01064ca
f0102196:	68 b6 03 00 00       	push   $0x3b6
f010219b:	68 9d 64 10 f0       	push   $0xf010649d
f01021a0:	e8 ef de ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f01021a5:	68 dd 65 10 f0       	push   $0xf01065dd
f01021aa:	68 ca 64 10 f0       	push   $0xf01064ca
f01021af:	68 b7 03 00 00       	push   $0x3b7
f01021b4:	68 9d 64 10 f0       	push   $0xf010649d
f01021b9:	e8 d6 de ff ff       	call   f0100094 <_panic>
	assert(pp1 && pp1 != pp0);
f01021be:	68 f3 65 10 f0       	push   $0xf01065f3
f01021c3:	68 ca 64 10 f0       	push   $0xf01064ca
f01021c8:	68 ba 03 00 00       	push   $0x3ba
f01021cd:	68 9d 64 10 f0       	push   $0xf010649d
f01021d2:	e8 bd de ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01021d7:	68 80 5c 10 f0       	push   $0xf0105c80
f01021dc:	68 ca 64 10 f0       	push   $0xf01064ca
f01021e1:	68 bb 03 00 00       	push   $0x3bb
f01021e6:	68 9d 64 10 f0       	push   $0xf010649d
f01021eb:	e8 a4 de ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f01021f0:	68 5c 66 10 f0       	push   $0xf010665c
f01021f5:	68 ca 64 10 f0       	push   $0xf01064ca
f01021fa:	68 c2 03 00 00       	push   $0x3c2
f01021ff:	68 9d 64 10 f0       	push   $0xf010649d
f0102204:	e8 8b de ff ff       	call   f0100094 <_panic>
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0102209:	68 c0 5c 10 f0       	push   $0xf0105cc0
f010220e:	68 ca 64 10 f0       	push   $0xf01064ca
f0102213:	68 c5 03 00 00       	push   $0x3c5
f0102218:	68 9d 64 10 f0       	push   $0xf010649d
f010221d:	e8 72 de ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0102222:	68 f8 5c 10 f0       	push   $0xf0105cf8
f0102227:	68 ca 64 10 f0       	push   $0xf01064ca
f010222c:	68 c8 03 00 00       	push   $0x3c8
f0102231:	68 9d 64 10 f0       	push   $0xf010649d
f0102236:	e8 59 de ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f010223b:	68 28 5d 10 f0       	push   $0xf0105d28
f0102240:	68 ca 64 10 f0       	push   $0xf01064ca
f0102245:	68 cc 03 00 00       	push   $0x3cc
f010224a:	68 9d 64 10 f0       	push   $0xf010649d
f010224f:	e8 40 de ff ff       	call   f0100094 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102254:	68 58 5d 10 f0       	push   $0xf0105d58
f0102259:	68 ca 64 10 f0       	push   $0xf01064ca
f010225e:	68 cd 03 00 00       	push   $0x3cd
f0102263:	68 9d 64 10 f0       	push   $0xf010649d
f0102268:	e8 27 de ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f010226d:	68 80 5d 10 f0       	push   $0xf0105d80
f0102272:	68 ca 64 10 f0       	push   $0xf01064ca
f0102277:	68 ce 03 00 00       	push   $0x3ce
f010227c:	68 9d 64 10 f0       	push   $0xf010649d
f0102281:	e8 0e de ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 1);
f0102286:	68 ae 66 10 f0       	push   $0xf01066ae
f010228b:	68 ca 64 10 f0       	push   $0xf01064ca
f0102290:	68 cf 03 00 00       	push   $0x3cf
f0102295:	68 9d 64 10 f0       	push   $0xf010649d
f010229a:	e8 f5 dd ff ff       	call   f0100094 <_panic>
	assert(pp0->pp_ref == 1);
f010229f:	68 bf 66 10 f0       	push   $0xf01066bf
f01022a4:	68 ca 64 10 f0       	push   $0xf01064ca
f01022a9:	68 d0 03 00 00       	push   $0x3d0
f01022ae:	68 9d 64 10 f0       	push   $0xf010649d
f01022b3:	e8 dc dd ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01022b8:	68 b0 5d 10 f0       	push   $0xf0105db0
f01022bd:	68 ca 64 10 f0       	push   $0xf01064ca
f01022c2:	68 d3 03 00 00       	push   $0x3d3
f01022c7:	68 9d 64 10 f0       	push   $0xf010649d
f01022cc:	e8 c3 dd ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01022d1:	68 ec 5d 10 f0       	push   $0xf0105dec
f01022d6:	68 ca 64 10 f0       	push   $0xf01064ca
f01022db:	68 d4 03 00 00       	push   $0x3d4
f01022e0:	68 9d 64 10 f0       	push   $0xf010649d
f01022e5:	e8 aa dd ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f01022ea:	68 d0 66 10 f0       	push   $0xf01066d0
f01022ef:	68 ca 64 10 f0       	push   $0xf01064ca
f01022f4:	68 d5 03 00 00       	push   $0x3d5
f01022f9:	68 9d 64 10 f0       	push   $0xf010649d
f01022fe:	e8 91 dd ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f0102303:	68 5c 66 10 f0       	push   $0xf010665c
f0102308:	68 ca 64 10 f0       	push   $0xf01064ca
f010230d:	68 d8 03 00 00       	push   $0x3d8
f0102312:	68 9d 64 10 f0       	push   $0xf010649d
f0102317:	e8 78 dd ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010231c:	68 b0 5d 10 f0       	push   $0xf0105db0
f0102321:	68 ca 64 10 f0       	push   $0xf01064ca
f0102326:	68 db 03 00 00       	push   $0x3db
f010232b:	68 9d 64 10 f0       	push   $0xf010649d
f0102330:	e8 5f dd ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102335:	68 ec 5d 10 f0       	push   $0xf0105dec
f010233a:	68 ca 64 10 f0       	push   $0xf01064ca
f010233f:	68 dc 03 00 00       	push   $0x3dc
f0102344:	68 9d 64 10 f0       	push   $0xf010649d
f0102349:	e8 46 dd ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f010234e:	68 d0 66 10 f0       	push   $0xf01066d0
f0102353:	68 ca 64 10 f0       	push   $0xf01064ca
f0102358:	68 dd 03 00 00       	push   $0x3dd
f010235d:	68 9d 64 10 f0       	push   $0xf010649d
f0102362:	e8 2d dd ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f0102367:	68 5c 66 10 f0       	push   $0xf010665c
f010236c:	68 ca 64 10 f0       	push   $0xf01064ca
f0102371:	68 e1 03 00 00       	push   $0x3e1
f0102376:	68 9d 64 10 f0       	push   $0xf010649d
f010237b:	e8 14 dd ff ff       	call   f0100094 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102380:	50                   	push   %eax
f0102381:	68 d4 55 10 f0       	push   $0xf01055d4
f0102386:	68 e4 03 00 00       	push   $0x3e4
f010238b:	68 9d 64 10 f0       	push   $0xf010649d
f0102390:	e8 ff dc ff ff       	call   f0100094 <_panic>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0102395:	68 1c 5e 10 f0       	push   $0xf0105e1c
f010239a:	68 ca 64 10 f0       	push   $0xf01064ca
f010239f:	68 e5 03 00 00       	push   $0x3e5
f01023a4:	68 9d 64 10 f0       	push   $0xf010649d
f01023a9:	e8 e6 dc ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f01023ae:	68 5c 5e 10 f0       	push   $0xf0105e5c
f01023b3:	68 ca 64 10 f0       	push   $0xf01064ca
f01023b8:	68 e8 03 00 00       	push   $0x3e8
f01023bd:	68 9d 64 10 f0       	push   $0xf010649d
f01023c2:	e8 cd dc ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01023c7:	68 ec 5d 10 f0       	push   $0xf0105dec
f01023cc:	68 ca 64 10 f0       	push   $0xf01064ca
f01023d1:	68 e9 03 00 00       	push   $0x3e9
f01023d6:	68 9d 64 10 f0       	push   $0xf010649d
f01023db:	e8 b4 dc ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f01023e0:	68 d0 66 10 f0       	push   $0xf01066d0
f01023e5:	68 ca 64 10 f0       	push   $0xf01064ca
f01023ea:	68 ea 03 00 00       	push   $0x3ea
f01023ef:	68 9d 64 10 f0       	push   $0xf010649d
f01023f4:	e8 9b dc ff ff       	call   f0100094 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f01023f9:	68 9c 5e 10 f0       	push   $0xf0105e9c
f01023fe:	68 ca 64 10 f0       	push   $0xf01064ca
f0102403:	68 eb 03 00 00       	push   $0x3eb
f0102408:	68 9d 64 10 f0       	push   $0xf010649d
f010240d:	e8 82 dc ff ff       	call   f0100094 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0102412:	68 e1 66 10 f0       	push   $0xf01066e1
f0102417:	68 ca 64 10 f0       	push   $0xf01064ca
f010241c:	68 ec 03 00 00       	push   $0x3ec
f0102421:	68 9d 64 10 f0       	push   $0xf010649d
f0102426:	e8 69 dc ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010242b:	68 b0 5d 10 f0       	push   $0xf0105db0
f0102430:	68 ca 64 10 f0       	push   $0xf01064ca
f0102435:	68 ef 03 00 00       	push   $0x3ef
f010243a:	68 9d 64 10 f0       	push   $0xf010649d
f010243f:	e8 50 dc ff ff       	call   f0100094 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0102444:	68 d0 5e 10 f0       	push   $0xf0105ed0
f0102449:	68 ca 64 10 f0       	push   $0xf01064ca
f010244e:	68 f0 03 00 00       	push   $0x3f0
f0102453:	68 9d 64 10 f0       	push   $0xf010649d
f0102458:	e8 37 dc ff ff       	call   f0100094 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f010245d:	68 04 5f 10 f0       	push   $0xf0105f04
f0102462:	68 ca 64 10 f0       	push   $0xf01064ca
f0102467:	68 f1 03 00 00       	push   $0x3f1
f010246c:	68 9d 64 10 f0       	push   $0xf010649d
f0102471:	e8 1e dc ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0102476:	68 3c 5f 10 f0       	push   $0xf0105f3c
f010247b:	68 ca 64 10 f0       	push   $0xf01064ca
f0102480:	68 f4 03 00 00       	push   $0x3f4
f0102485:	68 9d 64 10 f0       	push   $0xf010649d
f010248a:	e8 05 dc ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f010248f:	68 74 5f 10 f0       	push   $0xf0105f74
f0102494:	68 ca 64 10 f0       	push   $0xf01064ca
f0102499:	68 f7 03 00 00       	push   $0x3f7
f010249e:	68 9d 64 10 f0       	push   $0xf010649d
f01024a3:	e8 ec db ff ff       	call   f0100094 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01024a8:	68 04 5f 10 f0       	push   $0xf0105f04
f01024ad:	68 ca 64 10 f0       	push   $0xf01064ca
f01024b2:	68 f8 03 00 00       	push   $0x3f8
f01024b7:	68 9d 64 10 f0       	push   $0xf010649d
f01024bc:	e8 d3 db ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f01024c1:	68 b0 5f 10 f0       	push   $0xf0105fb0
f01024c6:	68 ca 64 10 f0       	push   $0xf01064ca
f01024cb:	68 fb 03 00 00       	push   $0x3fb
f01024d0:	68 9d 64 10 f0       	push   $0xf010649d
f01024d5:	e8 ba db ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01024da:	68 dc 5f 10 f0       	push   $0xf0105fdc
f01024df:	68 ca 64 10 f0       	push   $0xf01064ca
f01024e4:	68 fc 03 00 00       	push   $0x3fc
f01024e9:	68 9d 64 10 f0       	push   $0xf010649d
f01024ee:	e8 a1 db ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 2);
f01024f3:	68 f7 66 10 f0       	push   $0xf01066f7
f01024f8:	68 ca 64 10 f0       	push   $0xf01064ca
f01024fd:	68 fe 03 00 00       	push   $0x3fe
f0102502:	68 9d 64 10 f0       	push   $0xf010649d
f0102507:	e8 88 db ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f010250c:	68 08 67 10 f0       	push   $0xf0106708
f0102511:	68 ca 64 10 f0       	push   $0xf01064ca
f0102516:	68 ff 03 00 00       	push   $0x3ff
f010251b:	68 9d 64 10 f0       	push   $0xf010649d
f0102520:	e8 6f db ff ff       	call   f0100094 <_panic>
	assert((pp = page_alloc(0)) && pp == pp2);
f0102525:	68 0c 60 10 f0       	push   $0xf010600c
f010252a:	68 ca 64 10 f0       	push   $0xf01064ca
f010252f:	68 02 04 00 00       	push   $0x402
f0102534:	68 9d 64 10 f0       	push   $0xf010649d
f0102539:	e8 56 db ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010253e:	68 30 60 10 f0       	push   $0xf0106030
f0102543:	68 ca 64 10 f0       	push   $0xf01064ca
f0102548:	68 06 04 00 00       	push   $0x406
f010254d:	68 9d 64 10 f0       	push   $0xf010649d
f0102552:	e8 3d db ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102557:	68 dc 5f 10 f0       	push   $0xf0105fdc
f010255c:	68 ca 64 10 f0       	push   $0xf01064ca
f0102561:	68 07 04 00 00       	push   $0x407
f0102566:	68 9d 64 10 f0       	push   $0xf010649d
f010256b:	e8 24 db ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 1);
f0102570:	68 ae 66 10 f0       	push   $0xf01066ae
f0102575:	68 ca 64 10 f0       	push   $0xf01064ca
f010257a:	68 08 04 00 00       	push   $0x408
f010257f:	68 9d 64 10 f0       	push   $0xf010649d
f0102584:	e8 0b db ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f0102589:	68 08 67 10 f0       	push   $0xf0106708
f010258e:	68 ca 64 10 f0       	push   $0xf01064ca
f0102593:	68 09 04 00 00       	push   $0x409
f0102598:	68 9d 64 10 f0       	push   $0xf010649d
f010259d:	e8 f2 da ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f01025a2:	68 54 60 10 f0       	push   $0xf0106054
f01025a7:	68 ca 64 10 f0       	push   $0xf01064ca
f01025ac:	68 0c 04 00 00       	push   $0x40c
f01025b1:	68 9d 64 10 f0       	push   $0xf010649d
f01025b6:	e8 d9 da ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref);
f01025bb:	68 19 67 10 f0       	push   $0xf0106719
f01025c0:	68 ca 64 10 f0       	push   $0xf01064ca
f01025c5:	68 0d 04 00 00       	push   $0x40d
f01025ca:	68 9d 64 10 f0       	push   $0xf010649d
f01025cf:	e8 c0 da ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_link == NULL);
f01025d4:	68 25 67 10 f0       	push   $0xf0106725
f01025d9:	68 ca 64 10 f0       	push   $0xf01064ca
f01025de:	68 0e 04 00 00       	push   $0x40e
f01025e3:	68 9d 64 10 f0       	push   $0xf010649d
f01025e8:	e8 a7 da ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01025ed:	68 30 60 10 f0       	push   $0xf0106030
f01025f2:	68 ca 64 10 f0       	push   $0xf01064ca
f01025f7:	68 12 04 00 00       	push   $0x412
f01025fc:	68 9d 64 10 f0       	push   $0xf010649d
f0102601:	e8 8e da ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102606:	68 8c 60 10 f0       	push   $0xf010608c
f010260b:	68 ca 64 10 f0       	push   $0xf01064ca
f0102610:	68 13 04 00 00       	push   $0x413
f0102615:	68 9d 64 10 f0       	push   $0xf010649d
f010261a:	e8 75 da ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 0);
f010261f:	68 3a 67 10 f0       	push   $0xf010673a
f0102624:	68 ca 64 10 f0       	push   $0xf01064ca
f0102629:	68 14 04 00 00       	push   $0x414
f010262e:	68 9d 64 10 f0       	push   $0xf010649d
f0102633:	e8 5c da ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f0102638:	68 08 67 10 f0       	push   $0xf0106708
f010263d:	68 ca 64 10 f0       	push   $0xf01064ca
f0102642:	68 15 04 00 00       	push   $0x415
f0102647:	68 9d 64 10 f0       	push   $0xf010649d
f010264c:	e8 43 da ff ff       	call   f0100094 <_panic>
	assert((pp = page_alloc(0)) && pp == pp1);
f0102651:	68 b4 60 10 f0       	push   $0xf01060b4
f0102656:	68 ca 64 10 f0       	push   $0xf01064ca
f010265b:	68 18 04 00 00       	push   $0x418
f0102660:	68 9d 64 10 f0       	push   $0xf010649d
f0102665:	e8 2a da ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f010266a:	68 5c 66 10 f0       	push   $0xf010665c
f010266f:	68 ca 64 10 f0       	push   $0xf01064ca
f0102674:	68 1b 04 00 00       	push   $0x41b
f0102679:	68 9d 64 10 f0       	push   $0xf010649d
f010267e:	e8 11 da ff ff       	call   f0100094 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102683:	68 58 5d 10 f0       	push   $0xf0105d58
f0102688:	68 ca 64 10 f0       	push   $0xf01064ca
f010268d:	68 1e 04 00 00       	push   $0x41e
f0102692:	68 9d 64 10 f0       	push   $0xf010649d
f0102697:	e8 f8 d9 ff ff       	call   f0100094 <_panic>
	assert(pp0->pp_ref == 1);
f010269c:	68 bf 66 10 f0       	push   $0xf01066bf
f01026a1:	68 ca 64 10 f0       	push   $0xf01064ca
f01026a6:	68 20 04 00 00       	push   $0x420
f01026ab:	68 9d 64 10 f0       	push   $0xf010649d
f01026b0:	e8 df d9 ff ff       	call   f0100094 <_panic>
f01026b5:	50                   	push   %eax
f01026b6:	68 d4 55 10 f0       	push   $0xf01055d4
f01026bb:	68 27 04 00 00       	push   $0x427
f01026c0:	68 9d 64 10 f0       	push   $0xf010649d
f01026c5:	e8 ca d9 ff ff       	call   f0100094 <_panic>
	assert(ptep == ptep1 + PTX(va));
f01026ca:	68 4b 67 10 f0       	push   $0xf010674b
f01026cf:	68 ca 64 10 f0       	push   $0xf01064ca
f01026d4:	68 28 04 00 00       	push   $0x428
f01026d9:	68 9d 64 10 f0       	push   $0xf010649d
f01026de:	e8 b1 d9 ff ff       	call   f0100094 <_panic>
f01026e3:	50                   	push   %eax
f01026e4:	68 d4 55 10 f0       	push   $0xf01055d4
f01026e9:	6a 58                	push   $0x58
f01026eb:	68 b0 64 10 f0       	push   $0xf01064b0
f01026f0:	e8 9f d9 ff ff       	call   f0100094 <_panic>
f01026f5:	50                   	push   %eax
f01026f6:	68 d4 55 10 f0       	push   $0xf01055d4
f01026fb:	6a 58                	push   $0x58
f01026fd:	68 b0 64 10 f0       	push   $0xf01064b0
f0102702:	e8 8d d9 ff ff       	call   f0100094 <_panic>
		assert((ptep[i] & PTE_P) == 0);
f0102707:	68 63 67 10 f0       	push   $0xf0106763
f010270c:	68 ca 64 10 f0       	push   $0xf01064ca
f0102711:	68 32 04 00 00       	push   $0x432
f0102716:	68 9d 64 10 f0       	push   $0xf010649d
f010271b:	e8 74 d9 ff ff       	call   f0100094 <_panic>
	assert(mm1 >= MMIOBASE && mm1 + 8192 < MMIOLIM);
f0102720:	68 d8 60 10 f0       	push   $0xf01060d8
f0102725:	68 ca 64 10 f0       	push   $0xf01064ca
f010272a:	68 42 04 00 00       	push   $0x442
f010272f:	68 9d 64 10 f0       	push   $0xf010649d
f0102734:	e8 5b d9 ff ff       	call   f0100094 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8192 < MMIOLIM);
f0102739:	68 00 61 10 f0       	push   $0xf0106100
f010273e:	68 ca 64 10 f0       	push   $0xf01064ca
f0102743:	68 43 04 00 00       	push   $0x443
f0102748:	68 9d 64 10 f0       	push   $0xf010649d
f010274d:	e8 42 d9 ff ff       	call   f0100094 <_panic>
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0102752:	68 28 61 10 f0       	push   $0xf0106128
f0102757:	68 ca 64 10 f0       	push   $0xf01064ca
f010275c:	68 45 04 00 00       	push   $0x445
f0102761:	68 9d 64 10 f0       	push   $0xf010649d
f0102766:	e8 29 d9 ff ff       	call   f0100094 <_panic>
	assert(mm1 + 8192 <= mm2);
f010276b:	68 7a 67 10 f0       	push   $0xf010677a
f0102770:	68 ca 64 10 f0       	push   $0xf01064ca
f0102775:	68 47 04 00 00       	push   $0x447
f010277a:	68 9d 64 10 f0       	push   $0xf010649d
f010277f:	e8 10 d9 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0102784:	68 50 61 10 f0       	push   $0xf0106150
f0102789:	68 ca 64 10 f0       	push   $0xf01064ca
f010278e:	68 49 04 00 00       	push   $0x449
f0102793:	68 9d 64 10 f0       	push   $0xf010649d
f0102798:	e8 f7 d8 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f010279d:	68 74 61 10 f0       	push   $0xf0106174
f01027a2:	68 ca 64 10 f0       	push   $0xf01064ca
f01027a7:	68 4a 04 00 00       	push   $0x44a
f01027ac:	68 9d 64 10 f0       	push   $0xf010649d
f01027b1:	e8 de d8 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f01027b6:	68 a4 61 10 f0       	push   $0xf01061a4
f01027bb:	68 ca 64 10 f0       	push   $0xf01064ca
f01027c0:	68 4b 04 00 00       	push   $0x44b
f01027c5:	68 9d 64 10 f0       	push   $0xf010649d
f01027ca:	e8 c5 d8 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f01027cf:	68 c8 61 10 f0       	push   $0xf01061c8
f01027d4:	68 ca 64 10 f0       	push   $0xf01064ca
f01027d9:	68 4c 04 00 00       	push   $0x44c
f01027de:	68 9d 64 10 f0       	push   $0xf010649d
f01027e3:	e8 ac d8 ff ff       	call   f0100094 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f01027e8:	68 f4 61 10 f0       	push   $0xf01061f4
f01027ed:	68 ca 64 10 f0       	push   $0xf01064ca
f01027f2:	68 4e 04 00 00       	push   $0x44e
f01027f7:	68 9d 64 10 f0       	push   $0xf010649d
f01027fc:	e8 93 d8 ff ff       	call   f0100094 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102801:	68 38 62 10 f0       	push   $0xf0106238
f0102806:	68 ca 64 10 f0       	push   $0xf01064ca
f010280b:	68 4f 04 00 00       	push   $0x44f
f0102810:	68 9d 64 10 f0       	push   $0xf010649d
f0102815:	e8 7a d8 ff ff       	call   f0100094 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010281a:	50                   	push   %eax
f010281b:	68 f8 55 10 f0       	push   $0xf01055f8
f0102820:	68 d1 00 00 00       	push   $0xd1
f0102825:	68 9d 64 10 f0       	push   $0xf010649d
f010282a:	e8 65 d8 ff ff       	call   f0100094 <_panic>
f010282f:	50                   	push   %eax
f0102830:	68 f8 55 10 f0       	push   $0xf01055f8
f0102835:	68 da 00 00 00       	push   $0xda
f010283a:	68 9d 64 10 f0       	push   $0xf010649d
f010283f:	e8 50 d8 ff ff       	call   f0100094 <_panic>
f0102844:	50                   	push   %eax
f0102845:	68 f8 55 10 f0       	push   $0xf01055f8
f010284a:	68 e7 00 00 00       	push   $0xe7
f010284f:	68 9d 64 10 f0       	push   $0xf010649d
f0102854:	e8 3b d8 ff ff       	call   f0100094 <_panic>
f0102859:	56                   	push   %esi
f010285a:	68 f8 55 10 f0       	push   $0xf01055f8
f010285f:	68 5e 03 00 00       	push   $0x35e
f0102864:	68 9d 64 10 f0       	push   $0xf010649d
f0102869:	e8 26 d8 ff ff       	call   f0100094 <_panic>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010286e:	68 6c 62 10 f0       	push   $0xf010626c
f0102873:	68 ca 64 10 f0       	push   $0xf01064ca
f0102878:	68 5e 03 00 00       	push   $0x35e
f010287d:	68 9d 64 10 f0       	push   $0xf010649d
f0102882:	e8 0d d8 ff ff       	call   f0100094 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102887:	a1 44 12 23 f0       	mov    0xf0231244,%eax
f010288c:	89 45 d0             	mov    %eax,-0x30(%ebp)
	if ((uint32_t)kva < KERNBASE)
f010288f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102892:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f0102897:	8d b0 00 00 40 21    	lea    0x21400000(%eax),%esi
f010289d:	89 da                	mov    %ebx,%edx
f010289f:	89 f8                	mov    %edi,%eax
f01028a1:	e8 3c e2 ff ff       	call   f0100ae2 <check_va2pa>
f01028a6:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f01028ad:	76 3d                	jbe    f01028ec <mem_init+0x1611>
f01028af:	8d 14 1e             	lea    (%esi,%ebx,1),%edx
f01028b2:	39 d0                	cmp    %edx,%eax
f01028b4:	75 4d                	jne    f0102903 <mem_init+0x1628>
f01028b6:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE) {
f01028bc:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f01028c2:	75 d9                	jne    f010289d <mem_init+0x15c2>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01028c4:	8b 75 c8             	mov    -0x38(%ebp),%esi
f01028c7:	c1 e6 0c             	shl    $0xc,%esi
f01028ca:	bb 00 00 00 00       	mov    $0x0,%ebx
f01028cf:	39 f3                	cmp    %esi,%ebx
f01028d1:	73 62                	jae    f0102935 <mem_init+0x165a>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f01028d3:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f01028d9:	89 f8                	mov    %edi,%eax
f01028db:	e8 02 e2 ff ff       	call   f0100ae2 <check_va2pa>
f01028e0:	39 c3                	cmp    %eax,%ebx
f01028e2:	75 38                	jne    f010291c <mem_init+0x1641>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01028e4:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01028ea:	eb e3                	jmp    f01028cf <mem_init+0x15f4>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01028ec:	ff 75 d0             	pushl  -0x30(%ebp)
f01028ef:	68 f8 55 10 f0       	push   $0xf01055f8
f01028f4:	68 65 03 00 00       	push   $0x365
f01028f9:	68 9d 64 10 f0       	push   $0xf010649d
f01028fe:	e8 91 d7 ff ff       	call   f0100094 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102903:	68 a0 62 10 f0       	push   $0xf01062a0
f0102908:	68 ca 64 10 f0       	push   $0xf01064ca
f010290d:	68 65 03 00 00       	push   $0x365
f0102912:	68 9d 64 10 f0       	push   $0xf010649d
f0102917:	e8 78 d7 ff ff       	call   f0100094 <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f010291c:	68 d4 62 10 f0       	push   $0xf01062d4
f0102921:	68 ca 64 10 f0       	push   $0xf01064ca
f0102926:	68 6c 03 00 00       	push   $0x36c
f010292b:	68 9d 64 10 f0       	push   $0xf010649d
f0102930:	e8 5f d7 ff ff       	call   f0100094 <_panic>
f0102935:	c7 45 d0 00 30 23 f0 	movl   $0xf0233000,-0x30(%ebp)
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f010293c:	b8 00 30 23 f0       	mov    $0xf0233000,%eax
f0102941:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f0102946:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0102949:	89 c7                	mov    %eax,%edi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f010294b:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f010294e:	89 f3                	mov    %esi,%ebx
f0102950:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102953:	05 00 80 00 20       	add    $0x20008000,%eax
f0102958:	89 45 cc             	mov    %eax,-0x34(%ebp)
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f010295b:	8d 86 00 80 00 00    	lea    0x8000(%esi),%eax
f0102961:	89 45 c8             	mov    %eax,-0x38(%ebp)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102964:	89 da                	mov    %ebx,%edx
f0102966:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102969:	e8 74 e1 ff ff       	call   f0100ae2 <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f010296e:	81 ff ff ff ff ef    	cmp    $0xefffffff,%edi
f0102974:	0f 86 a7 00 00 00    	jbe    f0102a21 <mem_init+0x1746>
f010297a:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f010297d:	8d 14 19             	lea    (%ecx,%ebx,1),%edx
f0102980:	39 d0                	cmp    %edx,%eax
f0102982:	0f 85 b0 00 00 00    	jne    f0102a38 <mem_init+0x175d>
f0102988:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f010298e:	3b 5d c8             	cmp    -0x38(%ebp),%ebx
f0102991:	75 d1                	jne    f0102964 <mem_init+0x1689>
f0102993:	8d 9e 00 80 ff ff    	lea    -0x8000(%esi),%ebx
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102999:	89 da                	mov    %ebx,%edx
f010299b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010299e:	e8 3f e1 ff ff       	call   f0100ae2 <check_va2pa>
f01029a3:	83 f8 ff             	cmp    $0xffffffff,%eax
f01029a6:	0f 85 a5 00 00 00    	jne    f0102a51 <mem_init+0x1776>
f01029ac:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f01029b2:	39 f3                	cmp    %esi,%ebx
f01029b4:	75 e3                	jne    f0102999 <mem_init+0x16be>
f01029b6:	81 ee 00 00 01 00    	sub    $0x10000,%esi
f01029bc:	81 45 d0 00 80 01 00 	addl   $0x18000,-0x30(%ebp)
f01029c3:	81 c7 00 80 00 00    	add    $0x8000,%edi
	for (n = 0; n < NCPU; n++) {
f01029c9:	81 ff 00 30 27 f0    	cmp    $0xf0273000,%edi
f01029cf:	0f 85 76 ff ff ff    	jne    f010294b <mem_init+0x1670>
f01029d5:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01029d8:	bb 00 80 ff ef       	mov    $0xefff8000,%ebx
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f01029dd:	b8 00 70 11 f0       	mov    $0xf0117000,%eax
f01029e2:	8d b0 00 80 00 20    	lea    0x20008000(%eax),%esi
f01029e8:	89 da                	mov    %ebx,%edx
f01029ea:	89 f8                	mov    %edi,%eax
f01029ec:	e8 f1 e0 ff ff       	call   f0100ae2 <check_va2pa>
f01029f1:	8d 14 1e             	lea    (%esi,%ebx,1),%edx
f01029f4:	39 d0                	cmp    %edx,%eax
f01029f6:	75 72                	jne    f0102a6a <mem_init+0x178f>
f01029f8:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f01029fe:	81 fb 00 00 00 f0    	cmp    $0xf0000000,%ebx
f0102a04:	75 e2                	jne    f01029e8 <mem_init+0x170d>
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102a06:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f0102a0b:	89 f8                	mov    %edi,%eax
f0102a0d:	e8 d0 e0 ff ff       	call   f0100ae2 <check_va2pa>
f0102a12:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102a15:	75 6c                	jne    f0102a83 <mem_init+0x17a8>
	for (i = 0; i < NPDENTRIES; i++) {
f0102a17:	b8 00 00 00 00       	mov    $0x0,%eax
f0102a1c:	e9 b1 00 00 00       	jmp    f0102ad2 <mem_init+0x17f7>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102a21:	ff 75 c4             	pushl  -0x3c(%ebp)
f0102a24:	68 f8 55 10 f0       	push   $0xf01055f8
f0102a29:	68 75 03 00 00       	push   $0x375
f0102a2e:	68 9d 64 10 f0       	push   $0xf010649d
f0102a33:	e8 5c d6 ff ff       	call   f0100094 <_panic>
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102a38:	68 fc 62 10 f0       	push   $0xf01062fc
f0102a3d:	68 ca 64 10 f0       	push   $0xf01064ca
f0102a42:	68 75 03 00 00       	push   $0x375
f0102a47:	68 9d 64 10 f0       	push   $0xf010649d
f0102a4c:	e8 43 d6 ff ff       	call   f0100094 <_panic>
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102a51:	68 44 63 10 f0       	push   $0xf0106344
f0102a56:	68 ca 64 10 f0       	push   $0xf01064ca
f0102a5b:	68 77 03 00 00       	push   $0x377
f0102a60:	68 9d 64 10 f0       	push   $0xf010649d
f0102a65:	e8 2a d6 ff ff       	call   f0100094 <_panic>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102a6a:	68 68 63 10 f0       	push   $0xf0106368
f0102a6f:	68 ca 64 10 f0       	push   $0xf01064ca
f0102a74:	68 7a 03 00 00       	push   $0x37a
f0102a79:	68 9d 64 10 f0       	push   $0xf010649d
f0102a7e:	e8 11 d6 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102a83:	68 b0 63 10 f0       	push   $0xf01063b0
f0102a88:	68 ca 64 10 f0       	push   $0xf01064ca
f0102a8d:	68 7b 03 00 00       	push   $0x37b
f0102a92:	68 9d 64 10 f0       	push   $0xf010649d
f0102a97:	e8 f8 d5 ff ff       	call   f0100094 <_panic>
			assert(pgdir[i] & PTE_P);
f0102a9c:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f0102aa0:	75 48                	jne    f0102aea <mem_init+0x180f>
f0102aa2:	68 a5 67 10 f0       	push   $0xf01067a5
f0102aa7:	68 ca 64 10 f0       	push   $0xf01064ca
f0102aac:	68 86 03 00 00       	push   $0x386
f0102ab1:	68 9d 64 10 f0       	push   $0xf010649d
f0102ab6:	e8 d9 d5 ff ff       	call   f0100094 <_panic>
				assert(pgdir[i] & PTE_P);
f0102abb:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0102abe:	f6 c2 01             	test   $0x1,%dl
f0102ac1:	74 2c                	je     f0102aef <mem_init+0x1814>
				assert(pgdir[i] & PTE_W);
f0102ac3:	f6 c2 02             	test   $0x2,%dl
f0102ac6:	74 40                	je     f0102b08 <mem_init+0x182d>
	for (i = 0; i < NPDENTRIES; i++) {
f0102ac8:	83 c0 01             	add    $0x1,%eax
f0102acb:	3d 00 04 00 00       	cmp    $0x400,%eax
f0102ad0:	74 68                	je     f0102b3a <mem_init+0x185f>
		switch (i) {
f0102ad2:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0102ad8:	83 fa 04             	cmp    $0x4,%edx
f0102adb:	76 bf                	jbe    f0102a9c <mem_init+0x17c1>
			if (i >= PDX(KERNBASE)) {
f0102add:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102ae2:	77 d7                	ja     f0102abb <mem_init+0x17e0>
				assert(pgdir[i] == 0);
f0102ae4:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f0102ae8:	75 37                	jne    f0102b21 <mem_init+0x1846>
	for (i = 0; i < NPDENTRIES; i++) {
f0102aea:	83 c0 01             	add    $0x1,%eax
f0102aed:	eb e3                	jmp    f0102ad2 <mem_init+0x17f7>
				assert(pgdir[i] & PTE_P);
f0102aef:	68 a5 67 10 f0       	push   $0xf01067a5
f0102af4:	68 ca 64 10 f0       	push   $0xf01064ca
f0102af9:	68 8a 03 00 00       	push   $0x38a
f0102afe:	68 9d 64 10 f0       	push   $0xf010649d
f0102b03:	e8 8c d5 ff ff       	call   f0100094 <_panic>
				assert(pgdir[i] & PTE_W);
f0102b08:	68 b6 67 10 f0       	push   $0xf01067b6
f0102b0d:	68 ca 64 10 f0       	push   $0xf01064ca
f0102b12:	68 8b 03 00 00       	push   $0x38b
f0102b17:	68 9d 64 10 f0       	push   $0xf010649d
f0102b1c:	e8 73 d5 ff ff       	call   f0100094 <_panic>
				assert(pgdir[i] == 0);
f0102b21:	68 c7 67 10 f0       	push   $0xf01067c7
f0102b26:	68 ca 64 10 f0       	push   $0xf01064ca
f0102b2b:	68 8d 03 00 00       	push   $0x38d
f0102b30:	68 9d 64 10 f0       	push   $0xf010649d
f0102b35:	e8 5a d5 ff ff       	call   f0100094 <_panic>
	cprintf("check_kern_pgdir() succeeded!\n");
f0102b3a:	83 ec 0c             	sub    $0xc,%esp
f0102b3d:	68 e0 63 10 f0       	push   $0xf01063e0
f0102b42:	e8 8b 0c 00 00       	call   f01037d2 <cprintf>
	lcr3(PADDR(kern_pgdir));
f0102b47:	a1 0c 1f 23 f0       	mov    0xf0231f0c,%eax
	if ((uint32_t)kva < KERNBASE)
f0102b4c:	83 c4 10             	add    $0x10,%esp
f0102b4f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102b54:	0f 86 fb 01 00 00    	jbe    f0102d55 <mem_init+0x1a7a>
	return (physaddr_t)kva - KERNBASE;
f0102b5a:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102b5f:	0f 22 d8             	mov    %eax,%cr3
	check_page_free_list(0);
f0102b62:	b8 00 00 00 00       	mov    $0x0,%eax
f0102b67:	e8 da df ff ff       	call   f0100b46 <check_page_free_list>
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0102b6c:	0f 20 c0             	mov    %cr0,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f0102b6f:	83 e0 f3             	and    $0xfffffff3,%eax
f0102b72:	0d 23 00 05 80       	or     $0x80050023,%eax
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0102b77:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102b7a:	83 ec 0c             	sub    $0xc,%esp
f0102b7d:	6a 00                	push   $0x0
f0102b7f:	e8 cd e3 ff ff       	call   f0100f51 <page_alloc>
f0102b84:	89 c6                	mov    %eax,%esi
f0102b86:	83 c4 10             	add    $0x10,%esp
f0102b89:	85 c0                	test   %eax,%eax
f0102b8b:	0f 84 d9 01 00 00    	je     f0102d6a <mem_init+0x1a8f>
	assert((pp1 = page_alloc(0)));
f0102b91:	83 ec 0c             	sub    $0xc,%esp
f0102b94:	6a 00                	push   $0x0
f0102b96:	e8 b6 e3 ff ff       	call   f0100f51 <page_alloc>
f0102b9b:	89 c7                	mov    %eax,%edi
f0102b9d:	83 c4 10             	add    $0x10,%esp
f0102ba0:	85 c0                	test   %eax,%eax
f0102ba2:	0f 84 db 01 00 00    	je     f0102d83 <mem_init+0x1aa8>
	assert((pp2 = page_alloc(0)));
f0102ba8:	83 ec 0c             	sub    $0xc,%esp
f0102bab:	6a 00                	push   $0x0
f0102bad:	e8 9f e3 ff ff       	call   f0100f51 <page_alloc>
f0102bb2:	89 c3                	mov    %eax,%ebx
f0102bb4:	83 c4 10             	add    $0x10,%esp
f0102bb7:	85 c0                	test   %eax,%eax
f0102bb9:	0f 84 dd 01 00 00    	je     f0102d9c <mem_init+0x1ac1>
	page_free(pp0);
f0102bbf:	83 ec 0c             	sub    $0xc,%esp
f0102bc2:	56                   	push   %esi
f0102bc3:	e8 fb e3 ff ff       	call   f0100fc3 <page_free>
	return (pp - pages) << PGSHIFT;
f0102bc8:	89 f8                	mov    %edi,%eax
f0102bca:	2b 05 10 1f 23 f0    	sub    0xf0231f10,%eax
f0102bd0:	c1 f8 03             	sar    $0x3,%eax
f0102bd3:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102bd6:	89 c2                	mov    %eax,%edx
f0102bd8:	c1 ea 0c             	shr    $0xc,%edx
f0102bdb:	83 c4 10             	add    $0x10,%esp
f0102bde:	3b 15 08 1f 23 f0    	cmp    0xf0231f08,%edx
f0102be4:	0f 83 cb 01 00 00    	jae    f0102db5 <mem_init+0x1ada>
	memset(page2kva(pp1), 1, PGSIZE);
f0102bea:	83 ec 04             	sub    $0x4,%esp
f0102bed:	68 00 10 00 00       	push   $0x1000
f0102bf2:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0102bf4:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102bf9:	50                   	push   %eax
f0102bfa:	e8 c8 1c 00 00       	call   f01048c7 <memset>
	return (pp - pages) << PGSHIFT;
f0102bff:	89 d8                	mov    %ebx,%eax
f0102c01:	2b 05 10 1f 23 f0    	sub    0xf0231f10,%eax
f0102c07:	c1 f8 03             	sar    $0x3,%eax
f0102c0a:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102c0d:	89 c2                	mov    %eax,%edx
f0102c0f:	c1 ea 0c             	shr    $0xc,%edx
f0102c12:	83 c4 10             	add    $0x10,%esp
f0102c15:	3b 15 08 1f 23 f0    	cmp    0xf0231f08,%edx
f0102c1b:	0f 83 a6 01 00 00    	jae    f0102dc7 <mem_init+0x1aec>
	memset(page2kva(pp2), 2, PGSIZE);
f0102c21:	83 ec 04             	sub    $0x4,%esp
f0102c24:	68 00 10 00 00       	push   $0x1000
f0102c29:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f0102c2b:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102c30:	50                   	push   %eax
f0102c31:	e8 91 1c 00 00       	call   f01048c7 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102c36:	6a 02                	push   $0x2
f0102c38:	68 00 10 00 00       	push   $0x1000
f0102c3d:	57                   	push   %edi
f0102c3e:	ff 35 0c 1f 23 f0    	pushl  0xf0231f0c
f0102c44:	e8 c9 e5 ff ff       	call   f0101212 <page_insert>
	assert(pp1->pp_ref == 1);
f0102c49:	83 c4 20             	add    $0x20,%esp
f0102c4c:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102c51:	0f 85 82 01 00 00    	jne    f0102dd9 <mem_init+0x1afe>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102c57:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102c5e:	01 01 01 
f0102c61:	0f 85 8b 01 00 00    	jne    f0102df2 <mem_init+0x1b17>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102c67:	6a 02                	push   $0x2
f0102c69:	68 00 10 00 00       	push   $0x1000
f0102c6e:	53                   	push   %ebx
f0102c6f:	ff 35 0c 1f 23 f0    	pushl  0xf0231f0c
f0102c75:	e8 98 e5 ff ff       	call   f0101212 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102c7a:	83 c4 10             	add    $0x10,%esp
f0102c7d:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102c84:	02 02 02 
f0102c87:	0f 85 7e 01 00 00    	jne    f0102e0b <mem_init+0x1b30>
	assert(pp2->pp_ref == 1);
f0102c8d:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102c92:	0f 85 8c 01 00 00    	jne    f0102e24 <mem_init+0x1b49>
	assert(pp1->pp_ref == 0);
f0102c98:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102c9d:	0f 85 9a 01 00 00    	jne    f0102e3d <mem_init+0x1b62>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102ca3:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102caa:	03 03 03 
	return (pp - pages) << PGSHIFT;
f0102cad:	89 d8                	mov    %ebx,%eax
f0102caf:	2b 05 10 1f 23 f0    	sub    0xf0231f10,%eax
f0102cb5:	c1 f8 03             	sar    $0x3,%eax
f0102cb8:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102cbb:	89 c2                	mov    %eax,%edx
f0102cbd:	c1 ea 0c             	shr    $0xc,%edx
f0102cc0:	3b 15 08 1f 23 f0    	cmp    0xf0231f08,%edx
f0102cc6:	0f 83 8a 01 00 00    	jae    f0102e56 <mem_init+0x1b7b>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102ccc:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102cd3:	03 03 03 
f0102cd6:	0f 85 8c 01 00 00    	jne    f0102e68 <mem_init+0x1b8d>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102cdc:	83 ec 08             	sub    $0x8,%esp
f0102cdf:	68 00 10 00 00       	push   $0x1000
f0102ce4:	ff 35 0c 1f 23 f0    	pushl  0xf0231f0c
f0102cea:	e8 dd e4 ff ff       	call   f01011cc <page_remove>
	assert(pp2->pp_ref == 0);
f0102cef:	83 c4 10             	add    $0x10,%esp
f0102cf2:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102cf7:	0f 85 84 01 00 00    	jne    f0102e81 <mem_init+0x1ba6>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102cfd:	8b 0d 0c 1f 23 f0    	mov    0xf0231f0c,%ecx
f0102d03:	8b 11                	mov    (%ecx),%edx
f0102d05:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	return (pp - pages) << PGSHIFT;
f0102d0b:	89 f0                	mov    %esi,%eax
f0102d0d:	2b 05 10 1f 23 f0    	sub    0xf0231f10,%eax
f0102d13:	c1 f8 03             	sar    $0x3,%eax
f0102d16:	c1 e0 0c             	shl    $0xc,%eax
f0102d19:	39 c2                	cmp    %eax,%edx
f0102d1b:	0f 85 79 01 00 00    	jne    f0102e9a <mem_init+0x1bbf>
	kern_pgdir[0] = 0;
f0102d21:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102d27:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102d2c:	0f 85 81 01 00 00    	jne    f0102eb3 <mem_init+0x1bd8>
	pp0->pp_ref = 0;
f0102d32:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f0102d38:	83 ec 0c             	sub    $0xc,%esp
f0102d3b:	56                   	push   %esi
f0102d3c:	e8 82 e2 ff ff       	call   f0100fc3 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102d41:	c7 04 24 74 64 10 f0 	movl   $0xf0106474,(%esp)
f0102d48:	e8 85 0a 00 00       	call   f01037d2 <cprintf>
}
f0102d4d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102d50:	5b                   	pop    %ebx
f0102d51:	5e                   	pop    %esi
f0102d52:	5f                   	pop    %edi
f0102d53:	5d                   	pop    %ebp
f0102d54:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102d55:	50                   	push   %eax
f0102d56:	68 f8 55 10 f0       	push   $0xf01055f8
f0102d5b:	68 03 01 00 00       	push   $0x103
f0102d60:	68 9d 64 10 f0       	push   $0xf010649d
f0102d65:	e8 2a d3 ff ff       	call   f0100094 <_panic>
	assert((pp0 = page_alloc(0)));
f0102d6a:	68 b1 65 10 f0       	push   $0xf01065b1
f0102d6f:	68 ca 64 10 f0       	push   $0xf01064ca
f0102d74:	68 64 04 00 00       	push   $0x464
f0102d79:	68 9d 64 10 f0       	push   $0xf010649d
f0102d7e:	e8 11 d3 ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f0102d83:	68 c7 65 10 f0       	push   $0xf01065c7
f0102d88:	68 ca 64 10 f0       	push   $0xf01064ca
f0102d8d:	68 65 04 00 00       	push   $0x465
f0102d92:	68 9d 64 10 f0       	push   $0xf010649d
f0102d97:	e8 f8 d2 ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f0102d9c:	68 dd 65 10 f0       	push   $0xf01065dd
f0102da1:	68 ca 64 10 f0       	push   $0xf01064ca
f0102da6:	68 66 04 00 00       	push   $0x466
f0102dab:	68 9d 64 10 f0       	push   $0xf010649d
f0102db0:	e8 df d2 ff ff       	call   f0100094 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102db5:	50                   	push   %eax
f0102db6:	68 d4 55 10 f0       	push   $0xf01055d4
f0102dbb:	6a 58                	push   $0x58
f0102dbd:	68 b0 64 10 f0       	push   $0xf01064b0
f0102dc2:	e8 cd d2 ff ff       	call   f0100094 <_panic>
f0102dc7:	50                   	push   %eax
f0102dc8:	68 d4 55 10 f0       	push   $0xf01055d4
f0102dcd:	6a 58                	push   $0x58
f0102dcf:	68 b0 64 10 f0       	push   $0xf01064b0
f0102dd4:	e8 bb d2 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 1);
f0102dd9:	68 ae 66 10 f0       	push   $0xf01066ae
f0102dde:	68 ca 64 10 f0       	push   $0xf01064ca
f0102de3:	68 6b 04 00 00       	push   $0x46b
f0102de8:	68 9d 64 10 f0       	push   $0xf010649d
f0102ded:	e8 a2 d2 ff ff       	call   f0100094 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102df2:	68 00 64 10 f0       	push   $0xf0106400
f0102df7:	68 ca 64 10 f0       	push   $0xf01064ca
f0102dfc:	68 6c 04 00 00       	push   $0x46c
f0102e01:	68 9d 64 10 f0       	push   $0xf010649d
f0102e06:	e8 89 d2 ff ff       	call   f0100094 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102e0b:	68 24 64 10 f0       	push   $0xf0106424
f0102e10:	68 ca 64 10 f0       	push   $0xf01064ca
f0102e15:	68 6e 04 00 00       	push   $0x46e
f0102e1a:	68 9d 64 10 f0       	push   $0xf010649d
f0102e1f:	e8 70 d2 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f0102e24:	68 d0 66 10 f0       	push   $0xf01066d0
f0102e29:	68 ca 64 10 f0       	push   $0xf01064ca
f0102e2e:	68 6f 04 00 00       	push   $0x46f
f0102e33:	68 9d 64 10 f0       	push   $0xf010649d
f0102e38:	e8 57 d2 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 0);
f0102e3d:	68 3a 67 10 f0       	push   $0xf010673a
f0102e42:	68 ca 64 10 f0       	push   $0xf01064ca
f0102e47:	68 70 04 00 00       	push   $0x470
f0102e4c:	68 9d 64 10 f0       	push   $0xf010649d
f0102e51:	e8 3e d2 ff ff       	call   f0100094 <_panic>
f0102e56:	50                   	push   %eax
f0102e57:	68 d4 55 10 f0       	push   $0xf01055d4
f0102e5c:	6a 58                	push   $0x58
f0102e5e:	68 b0 64 10 f0       	push   $0xf01064b0
f0102e63:	e8 2c d2 ff ff       	call   f0100094 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102e68:	68 48 64 10 f0       	push   $0xf0106448
f0102e6d:	68 ca 64 10 f0       	push   $0xf01064ca
f0102e72:	68 72 04 00 00       	push   $0x472
f0102e77:	68 9d 64 10 f0       	push   $0xf010649d
f0102e7c:	e8 13 d2 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f0102e81:	68 08 67 10 f0       	push   $0xf0106708
f0102e86:	68 ca 64 10 f0       	push   $0xf01064ca
f0102e8b:	68 74 04 00 00       	push   $0x474
f0102e90:	68 9d 64 10 f0       	push   $0xf010649d
f0102e95:	e8 fa d1 ff ff       	call   f0100094 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102e9a:	68 58 5d 10 f0       	push   $0xf0105d58
f0102e9f:	68 ca 64 10 f0       	push   $0xf01064ca
f0102ea4:	68 77 04 00 00       	push   $0x477
f0102ea9:	68 9d 64 10 f0       	push   $0xf010649d
f0102eae:	e8 e1 d1 ff ff       	call   f0100094 <_panic>
	assert(pp0->pp_ref == 1);
f0102eb3:	68 bf 66 10 f0       	push   $0xf01066bf
f0102eb8:	68 ca 64 10 f0       	push   $0xf01064ca
f0102ebd:	68 79 04 00 00       	push   $0x479
f0102ec2:	68 9d 64 10 f0       	push   $0xf010649d
f0102ec7:	e8 c8 d1 ff ff       	call   f0100094 <_panic>

f0102ecc <user_mem_check>:
}
f0102ecc:	b8 00 00 00 00       	mov    $0x0,%eax
f0102ed1:	c3                   	ret    

f0102ed2 <user_mem_assert>:
}
f0102ed2:	c3                   	ret    

f0102ed3 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0102ed3:	55                   	push   %ebp
f0102ed4:	89 e5                	mov    %esp,%ebp
f0102ed6:	57                   	push   %edi
f0102ed7:	56                   	push   %esi
f0102ed8:	53                   	push   %ebx
f0102ed9:	83 ec 0c             	sub    $0xc,%esp
f0102edc:	89 c7                	mov    %eax,%edi
	// LAB 3: Your code here.
	void* i;
	for (i = ROUNDDOWN(va, PGSIZE); i < ROUNDUP(va + len, PGSIZE); i+=PGSIZE){
f0102ede:	89 d3                	mov    %edx,%ebx
f0102ee0:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0102ee6:	8d b4 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%esi
f0102eed:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
f0102ef3:	39 f3                	cmp    %esi,%ebx
f0102ef5:	73 5c                	jae    f0102f53 <region_alloc+0x80>
		struct PageInfo *pginfo = page_alloc(0);
f0102ef7:	83 ec 0c             	sub    $0xc,%esp
f0102efa:	6a 00                	push   $0x0
f0102efc:	e8 50 e0 ff ff       	call   f0100f51 <page_alloc>
		if (!pginfo) {
f0102f01:	83 c4 10             	add    $0x10,%esp
f0102f04:	85 c0                	test   %eax,%eax
f0102f06:	74 20                	je     f0102f28 <region_alloc+0x55>
			 panic("region_alloc:%e", -E_NO_MEM);
		}
		pginfo->pp_ref++;
f0102f08:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
		int r = page_insert(e->env_pgdir, pginfo, i, PTE_W | PTE_U | PTE_P);
f0102f0d:	6a 07                	push   $0x7
f0102f0f:	53                   	push   %ebx
f0102f10:	50                   	push   %eax
f0102f11:	ff 77 60             	pushl  0x60(%edi)
f0102f14:	e8 f9 e2 ff ff       	call   f0101212 <page_insert>
		if (r < 0) {
f0102f19:	83 c4 10             	add    $0x10,%esp
f0102f1c:	85 c0                	test   %eax,%eax
f0102f1e:	78 1e                	js     f0102f3e <region_alloc+0x6b>
	for (i = ROUNDDOWN(va, PGSIZE); i < ROUNDUP(va + len, PGSIZE); i+=PGSIZE){
f0102f20:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102f26:	eb cb                	jmp    f0102ef3 <region_alloc+0x20>
			 panic("region_alloc:%e", -E_NO_MEM);
f0102f28:	6a fc                	push   $0xfffffffc
f0102f2a:	68 d5 67 10 f0       	push   $0xf01067d5
f0102f2f:	68 22 01 00 00       	push   $0x122
f0102f34:	68 e5 67 10 f0       	push   $0xf01067e5
f0102f39:	e8 56 d1 ff ff       	call   f0100094 <_panic>
			 panic("region_alloc:%e", r);
f0102f3e:	50                   	push   %eax
f0102f3f:	68 d5 67 10 f0       	push   $0xf01067d5
f0102f44:	68 27 01 00 00       	push   $0x127
f0102f49:	68 e5 67 10 f0       	push   $0xf01067e5
f0102f4e:	e8 41 d1 ff ff       	call   f0100094 <_panic>
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
}
f0102f53:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102f56:	5b                   	pop    %ebx
f0102f57:	5e                   	pop    %esi
f0102f58:	5f                   	pop    %edi
f0102f59:	5d                   	pop    %ebp
f0102f5a:	c3                   	ret    

f0102f5b <envid2env>:
{
f0102f5b:	55                   	push   %ebp
f0102f5c:	89 e5                	mov    %esp,%ebp
f0102f5e:	56                   	push   %esi
f0102f5f:	53                   	push   %ebx
f0102f60:	8b 45 08             	mov    0x8(%ebp),%eax
f0102f63:	8b 55 10             	mov    0x10(%ebp),%edx
	if (envid == 0) {
f0102f66:	85 c0                	test   %eax,%eax
f0102f68:	74 2e                	je     f0102f98 <envid2env+0x3d>
	e = &envs[ENVX(envid)];
f0102f6a:	89 c3                	mov    %eax,%ebx
f0102f6c:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0102f72:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f0102f75:	03 1d 44 12 23 f0    	add    0xf0231244,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0102f7b:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0102f7f:	74 31                	je     f0102fb2 <envid2env+0x57>
f0102f81:	39 43 48             	cmp    %eax,0x48(%ebx)
f0102f84:	75 2c                	jne    f0102fb2 <envid2env+0x57>
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0102f86:	84 d2                	test   %dl,%dl
f0102f88:	75 38                	jne    f0102fc2 <envid2env+0x67>
	*env_store = e;
f0102f8a:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102f8d:	89 18                	mov    %ebx,(%eax)
	return 0;
f0102f8f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102f94:	5b                   	pop    %ebx
f0102f95:	5e                   	pop    %esi
f0102f96:	5d                   	pop    %ebp
f0102f97:	c3                   	ret    
		*env_store = curenv;
f0102f98:	e8 29 1f 00 00       	call   f0104ec6 <cpunum>
f0102f9d:	6b c0 74             	imul   $0x74,%eax,%eax
f0102fa0:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0102fa6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102fa9:	89 01                	mov    %eax,(%ecx)
		return 0;
f0102fab:	b8 00 00 00 00       	mov    $0x0,%eax
f0102fb0:	eb e2                	jmp    f0102f94 <envid2env+0x39>
		*env_store = 0;
f0102fb2:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102fb5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102fbb:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102fc0:	eb d2                	jmp    f0102f94 <envid2env+0x39>
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0102fc2:	e8 ff 1e 00 00       	call   f0104ec6 <cpunum>
f0102fc7:	6b c0 74             	imul   $0x74,%eax,%eax
f0102fca:	39 98 28 20 23 f0    	cmp    %ebx,-0xfdcdfd8(%eax)
f0102fd0:	74 b8                	je     f0102f8a <envid2env+0x2f>
f0102fd2:	8b 73 4c             	mov    0x4c(%ebx),%esi
f0102fd5:	e8 ec 1e 00 00       	call   f0104ec6 <cpunum>
f0102fda:	6b c0 74             	imul   $0x74,%eax,%eax
f0102fdd:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0102fe3:	3b 70 48             	cmp    0x48(%eax),%esi
f0102fe6:	74 a2                	je     f0102f8a <envid2env+0x2f>
		*env_store = 0;
f0102fe8:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102feb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102ff1:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102ff6:	eb 9c                	jmp    f0102f94 <envid2env+0x39>

f0102ff8 <env_init_percpu>:
	asm volatile("lgdt (%0)" : : "r" (p));
f0102ff8:	b8 20 13 12 f0       	mov    $0xf0121320,%eax
f0102ffd:	0f 01 10             	lgdtl  (%eax)
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f0103000:	b8 23 00 00 00       	mov    $0x23,%eax
f0103005:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f0103007:	8e e0                	mov    %eax,%fs
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f0103009:	b8 10 00 00 00       	mov    $0x10,%eax
f010300e:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f0103010:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f0103012:	8e d0                	mov    %eax,%ss
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f0103014:	ea 1b 30 10 f0 08 00 	ljmp   $0x8,$0xf010301b
	asm volatile("lldt %0" : : "r" (sel));
f010301b:	b8 00 00 00 00       	mov    $0x0,%eax
f0103020:	0f 00 d0             	lldt   %ax
}
f0103023:	c3                   	ret    

f0103024 <env_init>:
{
f0103024:	55                   	push   %ebp
f0103025:	89 e5                	mov    %esp,%ebp
f0103027:	56                   	push   %esi
f0103028:	53                   	push   %ebx
		envs[i].env_id = 0;
f0103029:	8b 35 44 12 23 f0    	mov    0xf0231244,%esi
f010302f:	8b 15 48 12 23 f0    	mov    0xf0231248,%edx
f0103035:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f010303b:	89 f3                	mov    %esi,%ebx
f010303d:	eb 02                	jmp    f0103041 <env_init+0x1d>
f010303f:	89 c8                	mov    %ecx,%eax
f0103041:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_link = env_free_list;
f0103048:	89 50 44             	mov    %edx,0x44(%eax)
f010304b:	8d 48 84             	lea    -0x7c(%eax),%ecx
		env_free_list = &envs[i];
f010304e:	89 c2                	mov    %eax,%edx
	for (int i = NENV-1;i >= 0;i--) {
f0103050:	39 d8                	cmp    %ebx,%eax
f0103052:	75 eb                	jne    f010303f <env_init+0x1b>
f0103054:	89 35 48 12 23 f0    	mov    %esi,0xf0231248
	env_init_percpu();
f010305a:	e8 99 ff ff ff       	call   f0102ff8 <env_init_percpu>
}
f010305f:	5b                   	pop    %ebx
f0103060:	5e                   	pop    %esi
f0103061:	5d                   	pop    %ebp
f0103062:	c3                   	ret    

f0103063 <env_alloc>:
{
f0103063:	55                   	push   %ebp
f0103064:	89 e5                	mov    %esp,%ebp
f0103066:	56                   	push   %esi
f0103067:	53                   	push   %ebx
	if (!(e = env_free_list))
f0103068:	8b 1d 48 12 23 f0    	mov    0xf0231248,%ebx
f010306e:	85 db                	test   %ebx,%ebx
f0103070:	0f 84 71 01 00 00    	je     f01031e7 <env_alloc+0x184>
	if (!(p = page_alloc(ALLOC_ZERO)))
f0103076:	83 ec 0c             	sub    $0xc,%esp
f0103079:	6a 01                	push   $0x1
f010307b:	e8 d1 de ff ff       	call   f0100f51 <page_alloc>
f0103080:	89 c6                	mov    %eax,%esi
f0103082:	83 c4 10             	add    $0x10,%esp
f0103085:	85 c0                	test   %eax,%eax
f0103087:	0f 84 61 01 00 00    	je     f01031ee <env_alloc+0x18b>
	return (pp - pages) << PGSHIFT;
f010308d:	2b 05 10 1f 23 f0    	sub    0xf0231f10,%eax
f0103093:	c1 f8 03             	sar    $0x3,%eax
f0103096:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0103099:	89 c2                	mov    %eax,%edx
f010309b:	c1 ea 0c             	shr    $0xc,%edx
f010309e:	3b 15 08 1f 23 f0    	cmp    0xf0231f08,%edx
f01030a4:	0f 83 16 01 00 00    	jae    f01031c0 <env_alloc+0x15d>
	return (void *)(pa + KERNBASE);
f01030aa:	2d 00 00 00 10       	sub    $0x10000000,%eax
	e->env_pgdir = page2kva(p);	
f01030af:	89 43 60             	mov    %eax,0x60(%ebx)
	memcpy(e->env_pgdir, kern_pgdir, PGSIZE);
f01030b2:	83 ec 04             	sub    $0x4,%esp
f01030b5:	68 00 10 00 00       	push   $0x1000
f01030ba:	ff 35 0c 1f 23 f0    	pushl  0xf0231f0c
f01030c0:	50                   	push   %eax
f01030c1:	e8 ab 18 00 00       	call   f0104971 <memcpy>
	p->pp_ref++;
f01030c6:	66 83 46 04 01       	addw   $0x1,0x4(%esi)
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f01030cb:	8b 43 60             	mov    0x60(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f01030ce:	83 c4 10             	add    $0x10,%esp
f01030d1:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01030d6:	0f 86 f6 00 00 00    	jbe    f01031d2 <env_alloc+0x16f>
	return (physaddr_t)kva - KERNBASE;
f01030dc:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01030e2:	83 ca 05             	or     $0x5,%edx
f01030e5:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f01030eb:	8b 43 48             	mov    0x48(%ebx),%eax
f01030ee:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f01030f3:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f01030f8:	ba 00 10 00 00       	mov    $0x1000,%edx
f01030fd:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f0103100:	89 da                	mov    %ebx,%edx
f0103102:	2b 15 44 12 23 f0    	sub    0xf0231244,%edx
f0103108:	c1 fa 02             	sar    $0x2,%edx
f010310b:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f0103111:	09 d0                	or     %edx,%eax
f0103113:	89 43 48             	mov    %eax,0x48(%ebx)
	e->env_parent_id = parent_id;
f0103116:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103119:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f010311c:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0103123:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f010312a:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0103131:	83 ec 04             	sub    $0x4,%esp
f0103134:	6a 44                	push   $0x44
f0103136:	6a 00                	push   $0x0
f0103138:	53                   	push   %ebx
f0103139:	e8 89 17 00 00       	call   f01048c7 <memset>
	e->env_tf.tf_ds = GD_UD | 3;
f010313e:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0103144:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f010314a:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0103150:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0103157:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	e->env_pgfault_upcall = 0;
f010315d:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)
	e->env_ipc_recving = 0;
f0103164:	c6 43 68 00          	movb   $0x0,0x68(%ebx)
	env_free_list = e->env_link;
f0103168:	8b 43 44             	mov    0x44(%ebx),%eax
f010316b:	a3 48 12 23 f0       	mov    %eax,0xf0231248
	*newenv_store = e;
f0103170:	8b 45 08             	mov    0x8(%ebp),%eax
f0103173:	89 18                	mov    %ebx,(%eax)
	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103175:	8b 5b 48             	mov    0x48(%ebx),%ebx
f0103178:	e8 49 1d 00 00       	call   f0104ec6 <cpunum>
f010317d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103180:	83 c4 10             	add    $0x10,%esp
f0103183:	ba 00 00 00 00       	mov    $0x0,%edx
f0103188:	83 b8 28 20 23 f0 00 	cmpl   $0x0,-0xfdcdfd8(%eax)
f010318f:	74 11                	je     f01031a2 <env_alloc+0x13f>
f0103191:	e8 30 1d 00 00       	call   f0104ec6 <cpunum>
f0103196:	6b c0 74             	imul   $0x74,%eax,%eax
f0103199:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f010319f:	8b 50 48             	mov    0x48(%eax),%edx
f01031a2:	83 ec 04             	sub    $0x4,%esp
f01031a5:	53                   	push   %ebx
f01031a6:	52                   	push   %edx
f01031a7:	68 f0 67 10 f0       	push   $0xf01067f0
f01031ac:	e8 21 06 00 00       	call   f01037d2 <cprintf>
	return 0;
f01031b1:	83 c4 10             	add    $0x10,%esp
f01031b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01031b9:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01031bc:	5b                   	pop    %ebx
f01031bd:	5e                   	pop    %esi
f01031be:	5d                   	pop    %ebp
f01031bf:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01031c0:	50                   	push   %eax
f01031c1:	68 d4 55 10 f0       	push   $0xf01055d4
f01031c6:	6a 58                	push   $0x58
f01031c8:	68 b0 64 10 f0       	push   $0xf01064b0
f01031cd:	e8 c2 ce ff ff       	call   f0100094 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01031d2:	50                   	push   %eax
f01031d3:	68 f8 55 10 f0       	push   $0xf01055f8
f01031d8:	68 c6 00 00 00       	push   $0xc6
f01031dd:	68 e5 67 10 f0       	push   $0xf01067e5
f01031e2:	e8 ad ce ff ff       	call   f0100094 <_panic>
		return -E_NO_FREE_ENV;
f01031e7:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f01031ec:	eb cb                	jmp    f01031b9 <env_alloc+0x156>
		return -E_NO_MEM;
f01031ee:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01031f3:	eb c4                	jmp    f01031b9 <env_alloc+0x156>

f01031f5 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f01031f5:	55                   	push   %ebp
f01031f6:	89 e5                	mov    %esp,%ebp
f01031f8:	57                   	push   %edi
f01031f9:	56                   	push   %esi
f01031fa:	53                   	push   %ebx
f01031fb:	83 ec 34             	sub    $0x34,%esp
f01031fe:	8b 75 08             	mov    0x8(%ebp),%esi
	// LAB 3: Your code here.
	struct 	Env *e;	
	int r = env_alloc(&e, (envid_t)0);
f0103201:	6a 00                	push   $0x0
f0103203:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103206:	50                   	push   %eax
f0103207:	e8 57 fe ff ff       	call   f0103063 <env_alloc>
	if (r < 0) {
f010320c:	83 c4 10             	add    $0x10,%esp
f010320f:	85 c0                	test   %eax,%eax
f0103211:	78 36                	js     f0103249 <env_create+0x54>
		 panic("env_create: %e", r);
	}
	e->env_type = type;
f0103213:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103216:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103219:	89 47 50             	mov    %eax,0x50(%edi)
	if (elf->e_magic != ELF_MAGIC) {
f010321c:	81 3e 7f 45 4c 46    	cmpl   $0x464c457f,(%esi)
f0103222:	75 3a                	jne    f010325e <env_create+0x69>
	ph = (struct Proghdr *) (binary + elf->e_phoff);
f0103224:	89 f3                	mov    %esi,%ebx
f0103226:	03 5e 1c             	add    0x1c(%esi),%ebx
	eph = ph + elf->e_phnum;
f0103229:	0f b7 46 2c          	movzwl 0x2c(%esi),%eax
f010322d:	c1 e0 05             	shl    $0x5,%eax
f0103230:	01 d8                	add    %ebx,%eax
f0103232:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	lcr3(PADDR(e->env_pgdir));
f0103235:	8b 47 60             	mov    0x60(%edi),%eax
	if ((uint32_t)kva < KERNBASE)
f0103238:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010323d:	76 36                	jbe    f0103275 <env_create+0x80>
	return (physaddr_t)kva - KERNBASE;
f010323f:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0103244:	0f 22 d8             	mov    %eax,%cr3
f0103247:	eb 5b                	jmp    f01032a4 <env_create+0xaf>
		 panic("env_create: %e", r);
f0103249:	50                   	push   %eax
f010324a:	68 05 68 10 f0       	push   $0xf0106805
f010324f:	68 94 01 00 00       	push   $0x194
f0103254:	68 e5 67 10 f0       	push   $0xf01067e5
f0103259:	e8 36 ce ff ff       	call   f0100094 <_panic>
		 panic("load_icode: not an Elf file");
f010325e:	83 ec 04             	sub    $0x4,%esp
f0103261:	68 14 68 10 f0       	push   $0xf0106814
f0103266:	68 6c 01 00 00       	push   $0x16c
f010326b:	68 e5 67 10 f0       	push   $0xf01067e5
f0103270:	e8 1f ce ff ff       	call   f0100094 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103275:	50                   	push   %eax
f0103276:	68 f8 55 10 f0       	push   $0xf01055f8
f010327b:	68 71 01 00 00       	push   $0x171
f0103280:	68 e5 67 10 f0       	push   $0xf01067e5
f0103285:	e8 0a ce ff ff       	call   f0100094 <_panic>
					 panic("load_icode: file size is greater than memory size");
f010328a:	83 ec 04             	sub    $0x4,%esp
f010328d:	68 54 68 10 f0       	push   $0xf0106854
f0103292:	68 75 01 00 00       	push   $0x175
f0103297:	68 e5 67 10 f0       	push   $0xf01067e5
f010329c:	e8 f3 cd ff ff       	call   f0100094 <_panic>
	for (; ph<eph; ph++) {
f01032a1:	83 c3 20             	add    $0x20,%ebx
f01032a4:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f01032a7:	76 47                	jbe    f01032f0 <env_create+0xfb>
		if (ph->p_type == ELF_PROG_LOAD) {
f01032a9:	83 3b 01             	cmpl   $0x1,(%ebx)
f01032ac:	75 f3                	jne    f01032a1 <env_create+0xac>
			 if (ph->p_filesz > ph->p_memsz) {
f01032ae:	8b 4b 14             	mov    0x14(%ebx),%ecx
f01032b1:	39 4b 10             	cmp    %ecx,0x10(%ebx)
f01032b4:	77 d4                	ja     f010328a <env_create+0x95>
			 region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f01032b6:	8b 53 08             	mov    0x8(%ebx),%edx
f01032b9:	89 f8                	mov    %edi,%eax
f01032bb:	e8 13 fc ff ff       	call   f0102ed3 <region_alloc>
			 memcpy((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
f01032c0:	83 ec 04             	sub    $0x4,%esp
f01032c3:	ff 73 10             	pushl  0x10(%ebx)
f01032c6:	89 f0                	mov    %esi,%eax
f01032c8:	03 43 04             	add    0x4(%ebx),%eax
f01032cb:	50                   	push   %eax
f01032cc:	ff 73 08             	pushl  0x8(%ebx)
f01032cf:	e8 9d 16 00 00       	call   f0104971 <memcpy>
			 memset((void *)ph->p_va + ph->p_filesz, 0, ph->p_memsz - ph->p_filesz);
f01032d4:	8b 43 10             	mov    0x10(%ebx),%eax
f01032d7:	83 c4 0c             	add    $0xc,%esp
f01032da:	8b 53 14             	mov    0x14(%ebx),%edx
f01032dd:	29 c2                	sub    %eax,%edx
f01032df:	52                   	push   %edx
f01032e0:	6a 00                	push   $0x0
f01032e2:	03 43 08             	add    0x8(%ebx),%eax
f01032e5:	50                   	push   %eax
f01032e6:	e8 dc 15 00 00       	call   f01048c7 <memset>
f01032eb:	83 c4 10             	add    $0x10,%esp
f01032ee:	eb b1                	jmp    f01032a1 <env_create+0xac>
	e->env_tf.tf_eip = elf->e_entry;
f01032f0:	8b 46 18             	mov    0x18(%esi),%eax
f01032f3:	89 47 30             	mov    %eax,0x30(%edi)
	region_alloc(e, (void *)USTACKTOP - PGSIZE, PGSIZE);
f01032f6:	b9 00 10 00 00       	mov    $0x1000,%ecx
f01032fb:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0103300:	89 f8                	mov    %edi,%eax
f0103302:	e8 cc fb ff ff       	call   f0102ed3 <region_alloc>
	lcr3(PADDR(kern_pgdir));
f0103307:	a1 0c 1f 23 f0       	mov    0xf0231f0c,%eax
	if ((uint32_t)kva < KERNBASE)
f010330c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103311:	76 10                	jbe    f0103323 <env_create+0x12e>
	return (physaddr_t)kva - KERNBASE;
f0103313:	05 00 00 00 10       	add    $0x10000000,%eax
f0103318:	0f 22 d8             	mov    %eax,%cr3
	load_icode(e, binary);
}
f010331b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010331e:	5b                   	pop    %ebx
f010331f:	5e                   	pop    %esi
f0103320:	5f                   	pop    %edi
f0103321:	5d                   	pop    %ebp
f0103322:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103323:	50                   	push   %eax
f0103324:	68 f8 55 10 f0       	push   $0xf01055f8
f0103329:	68 83 01 00 00       	push   $0x183
f010332e:	68 e5 67 10 f0       	push   $0xf01067e5
f0103333:	e8 5c cd ff ff       	call   f0100094 <_panic>

f0103338 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0103338:	55                   	push   %ebp
f0103339:	89 e5                	mov    %esp,%ebp
f010333b:	57                   	push   %edi
f010333c:	56                   	push   %esi
f010333d:	53                   	push   %ebx
f010333e:	83 ec 1c             	sub    $0x1c,%esp
f0103341:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103344:	e8 7d 1b 00 00       	call   f0104ec6 <cpunum>
f0103349:	6b c0 74             	imul   $0x74,%eax,%eax
f010334c:	39 b8 28 20 23 f0    	cmp    %edi,-0xfdcdfd8(%eax)
f0103352:	74 48                	je     f010339c <env_free+0x64>
		lcr3(PADDR(kern_pgdir));

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103354:	8b 5f 48             	mov    0x48(%edi),%ebx
f0103357:	e8 6a 1b 00 00       	call   f0104ec6 <cpunum>
f010335c:	6b c0 74             	imul   $0x74,%eax,%eax
f010335f:	ba 00 00 00 00       	mov    $0x0,%edx
f0103364:	83 b8 28 20 23 f0 00 	cmpl   $0x0,-0xfdcdfd8(%eax)
f010336b:	74 11                	je     f010337e <env_free+0x46>
f010336d:	e8 54 1b 00 00       	call   f0104ec6 <cpunum>
f0103372:	6b c0 74             	imul   $0x74,%eax,%eax
f0103375:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f010337b:	8b 50 48             	mov    0x48(%eax),%edx
f010337e:	83 ec 04             	sub    $0x4,%esp
f0103381:	53                   	push   %ebx
f0103382:	52                   	push   %edx
f0103383:	68 30 68 10 f0       	push   $0xf0106830
f0103388:	e8 45 04 00 00       	call   f01037d2 <cprintf>
f010338d:	83 c4 10             	add    $0x10,%esp
f0103390:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103397:	e9 a9 00 00 00       	jmp    f0103445 <env_free+0x10d>
		lcr3(PADDR(kern_pgdir));
f010339c:	a1 0c 1f 23 f0       	mov    0xf0231f0c,%eax
	if ((uint32_t)kva < KERNBASE)
f01033a1:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01033a6:	76 0a                	jbe    f01033b2 <env_free+0x7a>
	return (physaddr_t)kva - KERNBASE;
f01033a8:	05 00 00 00 10       	add    $0x10000000,%eax
f01033ad:	0f 22 d8             	mov    %eax,%cr3
f01033b0:	eb a2                	jmp    f0103354 <env_free+0x1c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01033b2:	50                   	push   %eax
f01033b3:	68 f8 55 10 f0       	push   $0xf01055f8
f01033b8:	68 a8 01 00 00       	push   $0x1a8
f01033bd:	68 e5 67 10 f0       	push   $0xf01067e5
f01033c2:	e8 cd cc ff ff       	call   f0100094 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01033c7:	56                   	push   %esi
f01033c8:	68 d4 55 10 f0       	push   $0xf01055d4
f01033cd:	68 b7 01 00 00       	push   $0x1b7
f01033d2:	68 e5 67 10 f0       	push   $0xf01067e5
f01033d7:	e8 b8 cc ff ff       	call   f0100094 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01033dc:	83 ec 08             	sub    $0x8,%esp
f01033df:	89 d8                	mov    %ebx,%eax
f01033e1:	c1 e0 0c             	shl    $0xc,%eax
f01033e4:	0b 45 e4             	or     -0x1c(%ebp),%eax
f01033e7:	50                   	push   %eax
f01033e8:	ff 77 60             	pushl  0x60(%edi)
f01033eb:	e8 dc dd ff ff       	call   f01011cc <page_remove>
f01033f0:	83 c4 10             	add    $0x10,%esp
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01033f3:	83 c3 01             	add    $0x1,%ebx
f01033f6:	83 c6 04             	add    $0x4,%esi
f01033f9:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f01033ff:	74 07                	je     f0103408 <env_free+0xd0>
			if (pt[pteno] & PTE_P)
f0103401:	f6 06 01             	testb  $0x1,(%esi)
f0103404:	74 ed                	je     f01033f3 <env_free+0xbb>
f0103406:	eb d4                	jmp    f01033dc <env_free+0xa4>
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103408:	8b 47 60             	mov    0x60(%edi),%eax
f010340b:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010340e:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
	if (PGNUM(pa) >= npages)
f0103415:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103418:	3b 05 08 1f 23 f0    	cmp    0xf0231f08,%eax
f010341e:	73 69                	jae    f0103489 <env_free+0x151>
		page_decref(pa2page(pa));
f0103420:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f0103423:	a1 10 1f 23 f0       	mov    0xf0231f10,%eax
f0103428:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010342b:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f010342e:	50                   	push   %eax
f010342f:	e8 ca db ff ff       	call   f0100ffe <page_decref>
f0103434:	83 c4 10             	add    $0x10,%esp
f0103437:	83 45 e0 04          	addl   $0x4,-0x20(%ebp)
f010343b:	8b 45 e0             	mov    -0x20(%ebp),%eax
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f010343e:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f0103443:	74 58                	je     f010349d <env_free+0x165>
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103445:	8b 47 60             	mov    0x60(%edi),%eax
f0103448:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010344b:	8b 34 10             	mov    (%eax,%edx,1),%esi
f010344e:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0103454:	74 e1                	je     f0103437 <env_free+0xff>
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103456:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	if (PGNUM(pa) >= npages)
f010345c:	89 f0                	mov    %esi,%eax
f010345e:	c1 e8 0c             	shr    $0xc,%eax
f0103461:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0103464:	39 05 08 1f 23 f0    	cmp    %eax,0xf0231f08
f010346a:	0f 86 57 ff ff ff    	jbe    f01033c7 <env_free+0x8f>
	return (void *)(pa + KERNBASE);
f0103470:	81 ee 00 00 00 10    	sub    $0x10000000,%esi
f0103476:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103479:	c1 e0 14             	shl    $0x14,%eax
f010347c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f010347f:	bb 00 00 00 00       	mov    $0x0,%ebx
f0103484:	e9 78 ff ff ff       	jmp    f0103401 <env_free+0xc9>
		panic("pa2page called with invalid pa");
f0103489:	83 ec 04             	sub    $0x4,%esp
f010348c:	68 24 5c 10 f0       	push   $0xf0105c24
f0103491:	6a 51                	push   $0x51
f0103493:	68 b0 64 10 f0       	push   $0xf01064b0
f0103498:	e8 f7 cb ff ff       	call   f0100094 <_panic>
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f010349d:	8b 47 60             	mov    0x60(%edi),%eax
	if ((uint32_t)kva < KERNBASE)
f01034a0:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01034a5:	76 49                	jbe    f01034f0 <env_free+0x1b8>
	e->env_pgdir = 0;
f01034a7:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
	return (physaddr_t)kva - KERNBASE;
f01034ae:	05 00 00 00 10       	add    $0x10000000,%eax
	if (PGNUM(pa) >= npages)
f01034b3:	c1 e8 0c             	shr    $0xc,%eax
f01034b6:	3b 05 08 1f 23 f0    	cmp    0xf0231f08,%eax
f01034bc:	73 47                	jae    f0103505 <env_free+0x1cd>
	page_decref(pa2page(pa));
f01034be:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f01034c1:	8b 15 10 1f 23 f0    	mov    0xf0231f10,%edx
f01034c7:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f01034ca:	50                   	push   %eax
f01034cb:	e8 2e db ff ff       	call   f0100ffe <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f01034d0:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f01034d7:	a1 48 12 23 f0       	mov    0xf0231248,%eax
f01034dc:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f01034df:	89 3d 48 12 23 f0    	mov    %edi,0xf0231248
}
f01034e5:	83 c4 10             	add    $0x10,%esp
f01034e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01034eb:	5b                   	pop    %ebx
f01034ec:	5e                   	pop    %esi
f01034ed:	5f                   	pop    %edi
f01034ee:	5d                   	pop    %ebp
f01034ef:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01034f0:	50                   	push   %eax
f01034f1:	68 f8 55 10 f0       	push   $0xf01055f8
f01034f6:	68 c5 01 00 00       	push   $0x1c5
f01034fb:	68 e5 67 10 f0       	push   $0xf01067e5
f0103500:	e8 8f cb ff ff       	call   f0100094 <_panic>
		panic("pa2page called with invalid pa");
f0103505:	83 ec 04             	sub    $0x4,%esp
f0103508:	68 24 5c 10 f0       	push   $0xf0105c24
f010350d:	6a 51                	push   $0x51
f010350f:	68 b0 64 10 f0       	push   $0xf01064b0
f0103514:	e8 7b cb ff ff       	call   f0100094 <_panic>

f0103519 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0103519:	55                   	push   %ebp
f010351a:	89 e5                	mov    %esp,%ebp
f010351c:	53                   	push   %ebx
f010351d:	83 ec 04             	sub    $0x4,%esp
f0103520:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103523:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0103527:	74 21                	je     f010354a <env_destroy+0x31>
		e->env_status = ENV_DYING;
		return;
	}

	env_free(e);
f0103529:	83 ec 0c             	sub    $0xc,%esp
f010352c:	53                   	push   %ebx
f010352d:	e8 06 fe ff ff       	call   f0103338 <env_free>

	if (curenv == e) {
f0103532:	e8 8f 19 00 00       	call   f0104ec6 <cpunum>
f0103537:	6b c0 74             	imul   $0x74,%eax,%eax
f010353a:	83 c4 10             	add    $0x10,%esp
f010353d:	39 98 28 20 23 f0    	cmp    %ebx,-0xfdcdfd8(%eax)
f0103543:	74 1e                	je     f0103563 <env_destroy+0x4a>
		curenv = NULL;
		sched_yield();
	}
}
f0103545:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103548:	c9                   	leave  
f0103549:	c3                   	ret    
	if (e->env_status == ENV_RUNNING && curenv != e) {
f010354a:	e8 77 19 00 00       	call   f0104ec6 <cpunum>
f010354f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103552:	39 98 28 20 23 f0    	cmp    %ebx,-0xfdcdfd8(%eax)
f0103558:	74 cf                	je     f0103529 <env_destroy+0x10>
		e->env_status = ENV_DYING;
f010355a:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0103561:	eb e2                	jmp    f0103545 <env_destroy+0x2c>
		curenv = NULL;
f0103563:	e8 5e 19 00 00       	call   f0104ec6 <cpunum>
f0103568:	6b c0 74             	imul   $0x74,%eax,%eax
f010356b:	c7 80 28 20 23 f0 00 	movl   $0x0,-0xfdcdfd8(%eax)
f0103572:	00 00 00 
		sched_yield();
f0103575:	e8 f7 07 00 00       	call   f0103d71 <sched_yield>

f010357a <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f010357a:	55                   	push   %ebp
f010357b:	89 e5                	mov    %esp,%ebp
f010357d:	53                   	push   %ebx
f010357e:	83 ec 04             	sub    $0x4,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0103581:	e8 40 19 00 00       	call   f0104ec6 <cpunum>
f0103586:	6b c0 74             	imul   $0x74,%eax,%eax
f0103589:	8b 98 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%ebx
f010358f:	e8 32 19 00 00       	call   f0104ec6 <cpunum>
f0103594:	89 43 5c             	mov    %eax,0x5c(%ebx)

	asm volatile(
f0103597:	8b 65 08             	mov    0x8(%ebp),%esp
f010359a:	61                   	popa   
f010359b:	07                   	pop    %es
f010359c:	1f                   	pop    %ds
f010359d:	83 c4 08             	add    $0x8,%esp
f01035a0:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f01035a1:	83 ec 04             	sub    $0x4,%esp
f01035a4:	68 46 68 10 f0       	push   $0xf0106846
f01035a9:	68 fc 01 00 00       	push   $0x1fc
f01035ae:	68 e5 67 10 f0       	push   $0xf01067e5
f01035b3:	e8 dc ca ff ff       	call   f0100094 <_panic>

f01035b8 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f01035b8:	55                   	push   %ebp
f01035b9:	89 e5                	mov    %esp,%ebp
f01035bb:	53                   	push   %ebx
f01035bc:	83 ec 04             	sub    $0x4,%esp
f01035bf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	if (curenv && curenv->env_status == ENV_RUNNING) {
f01035c2:	e8 ff 18 00 00       	call   f0104ec6 <cpunum>
f01035c7:	6b c0 74             	imul   $0x74,%eax,%eax
f01035ca:	83 b8 28 20 23 f0 00 	cmpl   $0x0,-0xfdcdfd8(%eax)
f01035d1:	74 14                	je     f01035e7 <env_run+0x2f>
f01035d3:	e8 ee 18 00 00       	call   f0104ec6 <cpunum>
f01035d8:	6b c0 74             	imul   $0x74,%eax,%eax
f01035db:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f01035e1:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01035e5:	74 34                	je     f010361b <env_run+0x63>
		 curenv->env_status = ENV_RUNNABLE;
	}
		 curenv = e;
f01035e7:	e8 da 18 00 00       	call   f0104ec6 <cpunum>
f01035ec:	6b c0 74             	imul   $0x74,%eax,%eax
f01035ef:	89 98 28 20 23 f0    	mov    %ebx,-0xfdcdfd8(%eax)
		 e->env_status = ENV_RUNNING;
f01035f5:	c7 43 54 03 00 00 00 	movl   $0x3,0x54(%ebx)
		 e->env_runs++ ;
f01035fc:	83 43 58 01          	addl   $0x1,0x58(%ebx)
		 lcr3(PADDR(e->env_pgdir));
f0103600:	8b 43 60             	mov    0x60(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f0103603:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103608:	76 28                	jbe    f0103632 <env_run+0x7a>
	return (physaddr_t)kva - KERNBASE;
f010360a:	05 00 00 00 10       	add    $0x10000000,%eax
f010360f:	0f 22 d8             	mov    %eax,%cr3

		 env_pop_tf(&e->env_tf);
f0103612:	83 ec 0c             	sub    $0xc,%esp
f0103615:	53                   	push   %ebx
f0103616:	e8 5f ff ff ff       	call   f010357a <env_pop_tf>
		 curenv->env_status = ENV_RUNNABLE;
f010361b:	e8 a6 18 00 00       	call   f0104ec6 <cpunum>
f0103620:	6b c0 74             	imul   $0x74,%eax,%eax
f0103623:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0103629:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
f0103630:	eb b5                	jmp    f01035e7 <env_run+0x2f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103632:	50                   	push   %eax
f0103633:	68 f8 55 10 f0       	push   $0xf01055f8
f0103638:	68 20 02 00 00       	push   $0x220
f010363d:	68 e5 67 10 f0       	push   $0xf01067e5
f0103642:	e8 4d ca ff ff       	call   f0100094 <_panic>

f0103647 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103647:	55                   	push   %ebp
f0103648:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010364a:	8b 45 08             	mov    0x8(%ebp),%eax
f010364d:	ba 70 00 00 00       	mov    $0x70,%edx
f0103652:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103653:	ba 71 00 00 00       	mov    $0x71,%edx
f0103658:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103659:	0f b6 c0             	movzbl %al,%eax
}
f010365c:	5d                   	pop    %ebp
f010365d:	c3                   	ret    

f010365e <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f010365e:	55                   	push   %ebp
f010365f:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103661:	8b 45 08             	mov    0x8(%ebp),%eax
f0103664:	ba 70 00 00 00       	mov    $0x70,%edx
f0103669:	ee                   	out    %al,(%dx)
f010366a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010366d:	ba 71 00 00 00       	mov    $0x71,%edx
f0103672:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103673:	5d                   	pop    %ebp
f0103674:	c3                   	ret    

f0103675 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0103675:	55                   	push   %ebp
f0103676:	89 e5                	mov    %esp,%ebp
f0103678:	56                   	push   %esi
f0103679:	53                   	push   %ebx
f010367a:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f010367d:	66 a3 a8 13 12 f0    	mov    %ax,0xf01213a8
	if (!didinit)
f0103683:	80 3d 4c 12 23 f0 00 	cmpb   $0x0,0xf023124c
f010368a:	75 07                	jne    f0103693 <irq_setmask_8259A+0x1e>
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
}
f010368c:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010368f:	5b                   	pop    %ebx
f0103690:	5e                   	pop    %esi
f0103691:	5d                   	pop    %ebp
f0103692:	c3                   	ret    
f0103693:	89 c6                	mov    %eax,%esi
f0103695:	ba 21 00 00 00       	mov    $0x21,%edx
f010369a:	ee                   	out    %al,(%dx)
	outb(IO_PIC2+1, (char)(mask >> 8));
f010369b:	66 c1 e8 08          	shr    $0x8,%ax
f010369f:	ba a1 00 00 00       	mov    $0xa1,%edx
f01036a4:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f01036a5:	83 ec 0c             	sub    $0xc,%esp
f01036a8:	68 86 68 10 f0       	push   $0xf0106886
f01036ad:	e8 20 01 00 00       	call   f01037d2 <cprintf>
f01036b2:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f01036b5:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f01036ba:	0f b7 f6             	movzwl %si,%esi
f01036bd:	f7 d6                	not    %esi
f01036bf:	eb 19                	jmp    f01036da <irq_setmask_8259A+0x65>
			cprintf(" %d", i);
f01036c1:	83 ec 08             	sub    $0x8,%esp
f01036c4:	53                   	push   %ebx
f01036c5:	68 f4 6c 10 f0       	push   $0xf0106cf4
f01036ca:	e8 03 01 00 00       	call   f01037d2 <cprintf>
f01036cf:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f01036d2:	83 c3 01             	add    $0x1,%ebx
f01036d5:	83 fb 10             	cmp    $0x10,%ebx
f01036d8:	74 07                	je     f01036e1 <irq_setmask_8259A+0x6c>
		if (~mask & (1<<i))
f01036da:	0f a3 de             	bt     %ebx,%esi
f01036dd:	73 f3                	jae    f01036d2 <irq_setmask_8259A+0x5d>
f01036df:	eb e0                	jmp    f01036c1 <irq_setmask_8259A+0x4c>
	cprintf("\n");
f01036e1:	83 ec 0c             	sub    $0xc,%esp
f01036e4:	68 a3 67 10 f0       	push   $0xf01067a3
f01036e9:	e8 e4 00 00 00       	call   f01037d2 <cprintf>
f01036ee:	83 c4 10             	add    $0x10,%esp
f01036f1:	eb 99                	jmp    f010368c <irq_setmask_8259A+0x17>

f01036f3 <pic_init>:
{
f01036f3:	55                   	push   %ebp
f01036f4:	89 e5                	mov    %esp,%ebp
f01036f6:	57                   	push   %edi
f01036f7:	56                   	push   %esi
f01036f8:	53                   	push   %ebx
f01036f9:	83 ec 0c             	sub    $0xc,%esp
	didinit = 1;
f01036fc:	c6 05 4c 12 23 f0 01 	movb   $0x1,0xf023124c
f0103703:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103708:	bb 21 00 00 00       	mov    $0x21,%ebx
f010370d:	89 da                	mov    %ebx,%edx
f010370f:	ee                   	out    %al,(%dx)
f0103710:	b9 a1 00 00 00       	mov    $0xa1,%ecx
f0103715:	89 ca                	mov    %ecx,%edx
f0103717:	ee                   	out    %al,(%dx)
f0103718:	bf 11 00 00 00       	mov    $0x11,%edi
f010371d:	be 20 00 00 00       	mov    $0x20,%esi
f0103722:	89 f8                	mov    %edi,%eax
f0103724:	89 f2                	mov    %esi,%edx
f0103726:	ee                   	out    %al,(%dx)
f0103727:	b8 20 00 00 00       	mov    $0x20,%eax
f010372c:	89 da                	mov    %ebx,%edx
f010372e:	ee                   	out    %al,(%dx)
f010372f:	b8 04 00 00 00       	mov    $0x4,%eax
f0103734:	ee                   	out    %al,(%dx)
f0103735:	b8 03 00 00 00       	mov    $0x3,%eax
f010373a:	ee                   	out    %al,(%dx)
f010373b:	bb a0 00 00 00       	mov    $0xa0,%ebx
f0103740:	89 f8                	mov    %edi,%eax
f0103742:	89 da                	mov    %ebx,%edx
f0103744:	ee                   	out    %al,(%dx)
f0103745:	b8 28 00 00 00       	mov    $0x28,%eax
f010374a:	89 ca                	mov    %ecx,%edx
f010374c:	ee                   	out    %al,(%dx)
f010374d:	b8 02 00 00 00       	mov    $0x2,%eax
f0103752:	ee                   	out    %al,(%dx)
f0103753:	b8 01 00 00 00       	mov    $0x1,%eax
f0103758:	ee                   	out    %al,(%dx)
f0103759:	bf 68 00 00 00       	mov    $0x68,%edi
f010375e:	89 f8                	mov    %edi,%eax
f0103760:	89 f2                	mov    %esi,%edx
f0103762:	ee                   	out    %al,(%dx)
f0103763:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0103768:	89 c8                	mov    %ecx,%eax
f010376a:	ee                   	out    %al,(%dx)
f010376b:	89 f8                	mov    %edi,%eax
f010376d:	89 da                	mov    %ebx,%edx
f010376f:	ee                   	out    %al,(%dx)
f0103770:	89 c8                	mov    %ecx,%eax
f0103772:	ee                   	out    %al,(%dx)
	if (irq_mask_8259A != 0xFFFF)
f0103773:	0f b7 05 a8 13 12 f0 	movzwl 0xf01213a8,%eax
f010377a:	66 83 f8 ff          	cmp    $0xffff,%ax
f010377e:	75 08                	jne    f0103788 <pic_init+0x95>
}
f0103780:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103783:	5b                   	pop    %ebx
f0103784:	5e                   	pop    %esi
f0103785:	5f                   	pop    %edi
f0103786:	5d                   	pop    %ebp
f0103787:	c3                   	ret    
		irq_setmask_8259A(irq_mask_8259A);
f0103788:	83 ec 0c             	sub    $0xc,%esp
f010378b:	0f b7 c0             	movzwl %ax,%eax
f010378e:	50                   	push   %eax
f010378f:	e8 e1 fe ff ff       	call   f0103675 <irq_setmask_8259A>
f0103794:	83 c4 10             	add    $0x10,%esp
}
f0103797:	eb e7                	jmp    f0103780 <pic_init+0x8d>

f0103799 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103799:	55                   	push   %ebp
f010379a:	89 e5                	mov    %esp,%ebp
f010379c:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f010379f:	ff 75 08             	pushl  0x8(%ebp)
f01037a2:	e8 ef cf ff ff       	call   f0100796 <cputchar>
	*cnt++;
}
f01037a7:	83 c4 10             	add    $0x10,%esp
f01037aa:	c9                   	leave  
f01037ab:	c3                   	ret    

f01037ac <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01037ac:	55                   	push   %ebp
f01037ad:	89 e5                	mov    %esp,%ebp
f01037af:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f01037b2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01037b9:	ff 75 0c             	pushl  0xc(%ebp)
f01037bc:	ff 75 08             	pushl  0x8(%ebp)
f01037bf:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01037c2:	50                   	push   %eax
f01037c3:	68 99 37 10 f0       	push   $0xf0103799
f01037c8:	e8 f2 09 00 00       	call   f01041bf <vprintfmt>
	return cnt;
}
f01037cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01037d0:	c9                   	leave  
f01037d1:	c3                   	ret    

f01037d2 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01037d2:	55                   	push   %ebp
f01037d3:	89 e5                	mov    %esp,%ebp
f01037d5:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01037d8:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f01037db:	50                   	push   %eax
f01037dc:	ff 75 08             	pushl  0x8(%ebp)
f01037df:	e8 c8 ff ff ff       	call   f01037ac <vcprintf>
	va_end(ap);

	return cnt;
}
f01037e4:	c9                   	leave  
f01037e5:	c3                   	ret    

f01037e6 <trap_init_percpu>:
	//
	// LAB 4: Your code here:

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f01037e6:	b8 80 1a 23 f0       	mov    $0xf0231a80,%eax
f01037eb:	c7 05 84 1a 23 f0 00 	movl   $0xf0000000,0xf0231a84
f01037f2:	00 00 f0 
	ts.ts_ss0 = GD_KD;
f01037f5:	66 c7 05 88 1a 23 f0 	movw   $0x10,0xf0231a88
f01037fc:	10 00 
	ts.ts_iomb = sizeof(struct Taskstate);
f01037fe:	66 c7 05 e6 1a 23 f0 	movw   $0x68,0xf0231ae6
f0103805:	68 00 

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f0103807:	66 c7 05 68 13 12 f0 	movw   $0x67,0xf0121368
f010380e:	67 00 
f0103810:	66 a3 6a 13 12 f0    	mov    %ax,0xf012136a
f0103816:	89 c2                	mov    %eax,%edx
f0103818:	c1 ea 10             	shr    $0x10,%edx
f010381b:	88 15 6c 13 12 f0    	mov    %dl,0xf012136c
f0103821:	c6 05 6e 13 12 f0 40 	movb   $0x40,0xf012136e
f0103828:	c1 e8 18             	shr    $0x18,%eax
f010382b:	a2 6f 13 12 f0       	mov    %al,0xf012136f
					sizeof(struct Taskstate) - 1, 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
f0103830:	c6 05 6d 13 12 f0 89 	movb   $0x89,0xf012136d
	asm volatile("ltr %0" : : "r" (sel));
f0103837:	b8 28 00 00 00       	mov    $0x28,%eax
f010383c:	0f 00 d8             	ltr    %ax
	asm volatile("lidt (%0)" : : "r" (p));
f010383f:	b8 ac 13 12 f0       	mov    $0xf01213ac,%eax
f0103844:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f0103847:	c3                   	ret    

f0103848 <trap_init>:
{
f0103848:	55                   	push   %ebp
f0103849:	89 e5                	mov    %esp,%ebp
f010384b:	83 ec 08             	sub    $0x8,%esp
	trap_init_percpu();
f010384e:	e8 93 ff ff ff       	call   f01037e6 <trap_init_percpu>
}
f0103853:	c9                   	leave  
f0103854:	c3                   	ret    

f0103855 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103855:	55                   	push   %ebp
f0103856:	89 e5                	mov    %esp,%ebp
f0103858:	53                   	push   %ebx
f0103859:	83 ec 0c             	sub    $0xc,%esp
f010385c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f010385f:	ff 33                	pushl  (%ebx)
f0103861:	68 9a 68 10 f0       	push   $0xf010689a
f0103866:	e8 67 ff ff ff       	call   f01037d2 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f010386b:	83 c4 08             	add    $0x8,%esp
f010386e:	ff 73 04             	pushl  0x4(%ebx)
f0103871:	68 a9 68 10 f0       	push   $0xf01068a9
f0103876:	e8 57 ff ff ff       	call   f01037d2 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f010387b:	83 c4 08             	add    $0x8,%esp
f010387e:	ff 73 08             	pushl  0x8(%ebx)
f0103881:	68 b8 68 10 f0       	push   $0xf01068b8
f0103886:	e8 47 ff ff ff       	call   f01037d2 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f010388b:	83 c4 08             	add    $0x8,%esp
f010388e:	ff 73 0c             	pushl  0xc(%ebx)
f0103891:	68 c7 68 10 f0       	push   $0xf01068c7
f0103896:	e8 37 ff ff ff       	call   f01037d2 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f010389b:	83 c4 08             	add    $0x8,%esp
f010389e:	ff 73 10             	pushl  0x10(%ebx)
f01038a1:	68 d6 68 10 f0       	push   $0xf01068d6
f01038a6:	e8 27 ff ff ff       	call   f01037d2 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f01038ab:	83 c4 08             	add    $0x8,%esp
f01038ae:	ff 73 14             	pushl  0x14(%ebx)
f01038b1:	68 e5 68 10 f0       	push   $0xf01068e5
f01038b6:	e8 17 ff ff ff       	call   f01037d2 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f01038bb:	83 c4 08             	add    $0x8,%esp
f01038be:	ff 73 18             	pushl  0x18(%ebx)
f01038c1:	68 f4 68 10 f0       	push   $0xf01068f4
f01038c6:	e8 07 ff ff ff       	call   f01037d2 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f01038cb:	83 c4 08             	add    $0x8,%esp
f01038ce:	ff 73 1c             	pushl  0x1c(%ebx)
f01038d1:	68 03 69 10 f0       	push   $0xf0106903
f01038d6:	e8 f7 fe ff ff       	call   f01037d2 <cprintf>
}
f01038db:	83 c4 10             	add    $0x10,%esp
f01038de:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01038e1:	c9                   	leave  
f01038e2:	c3                   	ret    

f01038e3 <print_trapframe>:
{
f01038e3:	55                   	push   %ebp
f01038e4:	89 e5                	mov    %esp,%ebp
f01038e6:	56                   	push   %esi
f01038e7:	53                   	push   %ebx
f01038e8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f01038eb:	e8 d6 15 00 00       	call   f0104ec6 <cpunum>
f01038f0:	83 ec 04             	sub    $0x4,%esp
f01038f3:	50                   	push   %eax
f01038f4:	53                   	push   %ebx
f01038f5:	68 67 69 10 f0       	push   $0xf0106967
f01038fa:	e8 d3 fe ff ff       	call   f01037d2 <cprintf>
	print_regs(&tf->tf_regs);
f01038ff:	89 1c 24             	mov    %ebx,(%esp)
f0103902:	e8 4e ff ff ff       	call   f0103855 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103907:	83 c4 08             	add    $0x8,%esp
f010390a:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f010390e:	50                   	push   %eax
f010390f:	68 85 69 10 f0       	push   $0xf0106985
f0103914:	e8 b9 fe ff ff       	call   f01037d2 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103919:	83 c4 08             	add    $0x8,%esp
f010391c:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103920:	50                   	push   %eax
f0103921:	68 98 69 10 f0       	push   $0xf0106998
f0103926:	e8 a7 fe ff ff       	call   f01037d2 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f010392b:	8b 43 28             	mov    0x28(%ebx),%eax
	if (trapno < ARRAY_SIZE(excnames))
f010392e:	83 c4 10             	add    $0x10,%esp
f0103931:	83 f8 13             	cmp    $0x13,%eax
f0103934:	0f 86 e1 00 00 00    	jbe    f0103a1b <print_trapframe+0x138>
		return "System call";
f010393a:	ba 12 69 10 f0       	mov    $0xf0106912,%edx
	if (trapno == T_SYSCALL)
f010393f:	83 f8 30             	cmp    $0x30,%eax
f0103942:	74 13                	je     f0103957 <print_trapframe+0x74>
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0103944:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
f0103947:	83 fa 0f             	cmp    $0xf,%edx
f010394a:	ba 1e 69 10 f0       	mov    $0xf010691e,%edx
f010394f:	b9 2d 69 10 f0       	mov    $0xf010692d,%ecx
f0103954:	0f 46 d1             	cmovbe %ecx,%edx
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103957:	83 ec 04             	sub    $0x4,%esp
f010395a:	52                   	push   %edx
f010395b:	50                   	push   %eax
f010395c:	68 ab 69 10 f0       	push   $0xf01069ab
f0103961:	e8 6c fe ff ff       	call   f01037d2 <cprintf>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103966:	83 c4 10             	add    $0x10,%esp
f0103969:	39 1d 60 1a 23 f0    	cmp    %ebx,0xf0231a60
f010396f:	0f 84 b2 00 00 00    	je     f0103a27 <print_trapframe+0x144>
	cprintf("  err  0x%08x", tf->tf_err);
f0103975:	83 ec 08             	sub    $0x8,%esp
f0103978:	ff 73 2c             	pushl  0x2c(%ebx)
f010397b:	68 cc 69 10 f0       	push   $0xf01069cc
f0103980:	e8 4d fe ff ff       	call   f01037d2 <cprintf>
	if (tf->tf_trapno == T_PGFLT)
f0103985:	83 c4 10             	add    $0x10,%esp
f0103988:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f010398c:	0f 85 b8 00 00 00    	jne    f0103a4a <print_trapframe+0x167>
			tf->tf_err & 1 ? "protection" : "not-present");
f0103992:	8b 43 2c             	mov    0x2c(%ebx),%eax
		cprintf(" [%s, %s, %s]\n",
f0103995:	89 c2                	mov    %eax,%edx
f0103997:	83 e2 01             	and    $0x1,%edx
f010399a:	b9 40 69 10 f0       	mov    $0xf0106940,%ecx
f010399f:	ba 4b 69 10 f0       	mov    $0xf010694b,%edx
f01039a4:	0f 44 ca             	cmove  %edx,%ecx
f01039a7:	89 c2                	mov    %eax,%edx
f01039a9:	83 e2 02             	and    $0x2,%edx
f01039ac:	be 57 69 10 f0       	mov    $0xf0106957,%esi
f01039b1:	ba 5d 69 10 f0       	mov    $0xf010695d,%edx
f01039b6:	0f 45 d6             	cmovne %esi,%edx
f01039b9:	83 e0 04             	and    $0x4,%eax
f01039bc:	b8 62 69 10 f0       	mov    $0xf0106962,%eax
f01039c1:	be 97 6a 10 f0       	mov    $0xf0106a97,%esi
f01039c6:	0f 44 c6             	cmove  %esi,%eax
f01039c9:	51                   	push   %ecx
f01039ca:	52                   	push   %edx
f01039cb:	50                   	push   %eax
f01039cc:	68 da 69 10 f0       	push   $0xf01069da
f01039d1:	e8 fc fd ff ff       	call   f01037d2 <cprintf>
f01039d6:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f01039d9:	83 ec 08             	sub    $0x8,%esp
f01039dc:	ff 73 30             	pushl  0x30(%ebx)
f01039df:	68 e9 69 10 f0       	push   $0xf01069e9
f01039e4:	e8 e9 fd ff ff       	call   f01037d2 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f01039e9:	83 c4 08             	add    $0x8,%esp
f01039ec:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f01039f0:	50                   	push   %eax
f01039f1:	68 f8 69 10 f0       	push   $0xf01069f8
f01039f6:	e8 d7 fd ff ff       	call   f01037d2 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f01039fb:	83 c4 08             	add    $0x8,%esp
f01039fe:	ff 73 38             	pushl  0x38(%ebx)
f0103a01:	68 0b 6a 10 f0       	push   $0xf0106a0b
f0103a06:	e8 c7 fd ff ff       	call   f01037d2 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0103a0b:	83 c4 10             	add    $0x10,%esp
f0103a0e:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103a12:	75 4b                	jne    f0103a5f <print_trapframe+0x17c>
}
f0103a14:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103a17:	5b                   	pop    %ebx
f0103a18:	5e                   	pop    %esi
f0103a19:	5d                   	pop    %ebp
f0103a1a:	c3                   	ret    
		return excnames[trapno];
f0103a1b:	8b 14 85 20 6c 10 f0 	mov    -0xfef93e0(,%eax,4),%edx
f0103a22:	e9 30 ff ff ff       	jmp    f0103957 <print_trapframe+0x74>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103a27:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103a2b:	0f 85 44 ff ff ff    	jne    f0103975 <print_trapframe+0x92>
	asm volatile("movl %%cr2,%0" : "=r" (val));
f0103a31:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0103a34:	83 ec 08             	sub    $0x8,%esp
f0103a37:	50                   	push   %eax
f0103a38:	68 bd 69 10 f0       	push   $0xf01069bd
f0103a3d:	e8 90 fd ff ff       	call   f01037d2 <cprintf>
f0103a42:	83 c4 10             	add    $0x10,%esp
f0103a45:	e9 2b ff ff ff       	jmp    f0103975 <print_trapframe+0x92>
		cprintf("\n");
f0103a4a:	83 ec 0c             	sub    $0xc,%esp
f0103a4d:	68 a3 67 10 f0       	push   $0xf01067a3
f0103a52:	e8 7b fd ff ff       	call   f01037d2 <cprintf>
f0103a57:	83 c4 10             	add    $0x10,%esp
f0103a5a:	e9 7a ff ff ff       	jmp    f01039d9 <print_trapframe+0xf6>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0103a5f:	83 ec 08             	sub    $0x8,%esp
f0103a62:	ff 73 3c             	pushl  0x3c(%ebx)
f0103a65:	68 1a 6a 10 f0       	push   $0xf0106a1a
f0103a6a:	e8 63 fd ff ff       	call   f01037d2 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0103a6f:	83 c4 08             	add    $0x8,%esp
f0103a72:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0103a76:	50                   	push   %eax
f0103a77:	68 29 6a 10 f0       	push   $0xf0106a29
f0103a7c:	e8 51 fd ff ff       	call   f01037d2 <cprintf>
f0103a81:	83 c4 10             	add    $0x10,%esp
}
f0103a84:	eb 8e                	jmp    f0103a14 <print_trapframe+0x131>

f0103a86 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0103a86:	55                   	push   %ebp
f0103a87:	89 e5                	mov    %esp,%ebp
f0103a89:	57                   	push   %edi
f0103a8a:	56                   	push   %esi
f0103a8b:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0103a8e:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f0103a8f:	83 3d 00 1f 23 f0 00 	cmpl   $0x0,0xf0231f00
f0103a96:	74 01                	je     f0103a99 <trap+0x13>
		asm volatile("hlt");
f0103a98:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f0103a99:	e8 28 14 00 00       	call   f0104ec6 <cpunum>
f0103a9e:	6b d0 74             	imul   $0x74,%eax,%edx
f0103aa1:	83 c2 04             	add    $0x4,%edx
	asm volatile("lock; xchgl %0, %1"
f0103aa4:	b8 01 00 00 00       	mov    $0x1,%eax
f0103aa9:	f0 87 82 20 20 23 f0 	lock xchg %eax,-0xfdcdfe0(%edx)
f0103ab0:	83 f8 02             	cmp    $0x2,%eax
f0103ab3:	0f 84 8a 00 00 00    	je     f0103b43 <trap+0xbd>
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f0103ab9:	9c                   	pushf  
f0103aba:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0103abb:	f6 c4 02             	test   $0x2,%ah
f0103abe:	0f 85 94 00 00 00    	jne    f0103b58 <trap+0xd2>

	if ((tf->tf_cs & 3) == 3) {
f0103ac4:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0103ac8:	83 e0 03             	and    $0x3,%eax
f0103acb:	66 83 f8 03          	cmp    $0x3,%ax
f0103acf:	0f 84 9c 00 00 00    	je     f0103b71 <trap+0xeb>
		tf = &curenv->env_tf;
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0103ad5:	89 35 60 1a 23 f0    	mov    %esi,0xf0231a60
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f0103adb:	83 7e 28 27          	cmpl   $0x27,0x28(%esi)
f0103adf:	0f 84 21 01 00 00    	je     f0103c06 <trap+0x180>
	print_trapframe(tf);
f0103ae5:	83 ec 0c             	sub    $0xc,%esp
f0103ae8:	56                   	push   %esi
f0103ae9:	e8 f5 fd ff ff       	call   f01038e3 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0103aee:	83 c4 10             	add    $0x10,%esp
f0103af1:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0103af6:	0f 84 27 01 00 00    	je     f0103c23 <trap+0x19d>
		env_destroy(curenv);
f0103afc:	e8 c5 13 00 00       	call   f0104ec6 <cpunum>
f0103b01:	83 ec 0c             	sub    $0xc,%esp
f0103b04:	6b c0 74             	imul   $0x74,%eax,%eax
f0103b07:	ff b0 28 20 23 f0    	pushl  -0xfdcdfd8(%eax)
f0103b0d:	e8 07 fa ff ff       	call   f0103519 <env_destroy>
f0103b12:	83 c4 10             	add    $0x10,%esp
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f0103b15:	e8 ac 13 00 00       	call   f0104ec6 <cpunum>
f0103b1a:	6b c0 74             	imul   $0x74,%eax,%eax
f0103b1d:	83 b8 28 20 23 f0 00 	cmpl   $0x0,-0xfdcdfd8(%eax)
f0103b24:	74 18                	je     f0103b3e <trap+0xb8>
f0103b26:	e8 9b 13 00 00       	call   f0104ec6 <cpunum>
f0103b2b:	6b c0 74             	imul   $0x74,%eax,%eax
f0103b2e:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0103b34:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103b38:	0f 84 fc 00 00 00    	je     f0103c3a <trap+0x1b4>
		env_run(curenv);
	else
		sched_yield();
f0103b3e:	e8 2e 02 00 00       	call   f0103d71 <sched_yield>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0103b43:	83 ec 0c             	sub    $0xc,%esp
f0103b46:	68 c0 13 12 f0       	push   $0xf01213c0
f0103b4b:	e8 e6 15 00 00       	call   f0105136 <spin_lock>
f0103b50:	83 c4 10             	add    $0x10,%esp
f0103b53:	e9 61 ff ff ff       	jmp    f0103ab9 <trap+0x33>
	assert(!(read_eflags() & FL_IF));
f0103b58:	68 3c 6a 10 f0       	push   $0xf0106a3c
f0103b5d:	68 ca 64 10 f0       	push   $0xf01064ca
f0103b62:	68 de 00 00 00       	push   $0xde
f0103b67:	68 55 6a 10 f0       	push   $0xf0106a55
f0103b6c:	e8 23 c5 ff ff       	call   f0100094 <_panic>
		assert(curenv);
f0103b71:	e8 50 13 00 00       	call   f0104ec6 <cpunum>
f0103b76:	6b c0 74             	imul   $0x74,%eax,%eax
f0103b79:	83 b8 28 20 23 f0 00 	cmpl   $0x0,-0xfdcdfd8(%eax)
f0103b80:	74 3e                	je     f0103bc0 <trap+0x13a>
		if (curenv->env_status == ENV_DYING) {
f0103b82:	e8 3f 13 00 00       	call   f0104ec6 <cpunum>
f0103b87:	6b c0 74             	imul   $0x74,%eax,%eax
f0103b8a:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0103b90:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0103b94:	74 43                	je     f0103bd9 <trap+0x153>
		curenv->env_tf = *tf;
f0103b96:	e8 2b 13 00 00       	call   f0104ec6 <cpunum>
f0103b9b:	6b c0 74             	imul   $0x74,%eax,%eax
f0103b9e:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0103ba4:	b9 11 00 00 00       	mov    $0x11,%ecx
f0103ba9:	89 c7                	mov    %eax,%edi
f0103bab:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		tf = &curenv->env_tf;
f0103bad:	e8 14 13 00 00       	call   f0104ec6 <cpunum>
f0103bb2:	6b c0 74             	imul   $0x74,%eax,%eax
f0103bb5:	8b b0 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%esi
f0103bbb:	e9 15 ff ff ff       	jmp    f0103ad5 <trap+0x4f>
		assert(curenv);
f0103bc0:	68 61 6a 10 f0       	push   $0xf0106a61
f0103bc5:	68 ca 64 10 f0       	push   $0xf01064ca
f0103bca:	68 e5 00 00 00       	push   $0xe5
f0103bcf:	68 55 6a 10 f0       	push   $0xf0106a55
f0103bd4:	e8 bb c4 ff ff       	call   f0100094 <_panic>
			env_free(curenv);
f0103bd9:	e8 e8 12 00 00       	call   f0104ec6 <cpunum>
f0103bde:	83 ec 0c             	sub    $0xc,%esp
f0103be1:	6b c0 74             	imul   $0x74,%eax,%eax
f0103be4:	ff b0 28 20 23 f0    	pushl  -0xfdcdfd8(%eax)
f0103bea:	e8 49 f7 ff ff       	call   f0103338 <env_free>
			curenv = NULL;
f0103bef:	e8 d2 12 00 00       	call   f0104ec6 <cpunum>
f0103bf4:	6b c0 74             	imul   $0x74,%eax,%eax
f0103bf7:	c7 80 28 20 23 f0 00 	movl   $0x0,-0xfdcdfd8(%eax)
f0103bfe:	00 00 00 
			sched_yield();
f0103c01:	e8 6b 01 00 00       	call   f0103d71 <sched_yield>
		cprintf("Spurious interrupt on irq 7\n");
f0103c06:	83 ec 0c             	sub    $0xc,%esp
f0103c09:	68 68 6a 10 f0       	push   $0xf0106a68
f0103c0e:	e8 bf fb ff ff       	call   f01037d2 <cprintf>
		print_trapframe(tf);
f0103c13:	89 34 24             	mov    %esi,(%esp)
f0103c16:	e8 c8 fc ff ff       	call   f01038e3 <print_trapframe>
f0103c1b:	83 c4 10             	add    $0x10,%esp
f0103c1e:	e9 f2 fe ff ff       	jmp    f0103b15 <trap+0x8f>
		panic("unhandled trap in kernel");
f0103c23:	83 ec 04             	sub    $0x4,%esp
f0103c26:	68 85 6a 10 f0       	push   $0xf0106a85
f0103c2b:	68 c4 00 00 00       	push   $0xc4
f0103c30:	68 55 6a 10 f0       	push   $0xf0106a55
f0103c35:	e8 5a c4 ff ff       	call   f0100094 <_panic>
		env_run(curenv);
f0103c3a:	e8 87 12 00 00       	call   f0104ec6 <cpunum>
f0103c3f:	83 ec 0c             	sub    $0xc,%esp
f0103c42:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c45:	ff b0 28 20 23 f0    	pushl  -0xfdcdfd8(%eax)
f0103c4b:	e8 68 f9 ff ff       	call   f01035b8 <env_run>

f0103c50 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0103c50:	55                   	push   %ebp
f0103c51:	89 e5                	mov    %esp,%ebp
f0103c53:	57                   	push   %edi
f0103c54:	56                   	push   %esi
f0103c55:	53                   	push   %ebx
f0103c56:	83 ec 0c             	sub    $0xc,%esp
f0103c59:	8b 5d 08             	mov    0x8(%ebp),%ebx
	asm volatile("movl %%cr2,%0" : "=r" (val));
f0103c5c:	0f 20 d6             	mov    %cr2,%esi
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103c5f:	8b 7b 30             	mov    0x30(%ebx),%edi
		curenv->env_id, fault_va, tf->tf_eip);
f0103c62:	e8 5f 12 00 00       	call   f0104ec6 <cpunum>
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103c67:	57                   	push   %edi
f0103c68:	56                   	push   %esi
		curenv->env_id, fault_va, tf->tf_eip);
f0103c69:	6b c0 74             	imul   $0x74,%eax,%eax
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103c6c:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0103c72:	ff 70 48             	pushl  0x48(%eax)
f0103c75:	68 e4 6b 10 f0       	push   $0xf0106be4
f0103c7a:	e8 53 fb ff ff       	call   f01037d2 <cprintf>
	print_trapframe(tf);
f0103c7f:	89 1c 24             	mov    %ebx,(%esp)
f0103c82:	e8 5c fc ff ff       	call   f01038e3 <print_trapframe>
	env_destroy(curenv);
f0103c87:	e8 3a 12 00 00       	call   f0104ec6 <cpunum>
f0103c8c:	83 c4 04             	add    $0x4,%esp
f0103c8f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c92:	ff b0 28 20 23 f0    	pushl  -0xfdcdfd8(%eax)
f0103c98:	e8 7c f8 ff ff       	call   f0103519 <env_destroy>
}
f0103c9d:	83 c4 10             	add    $0x10,%esp
f0103ca0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103ca3:	5b                   	pop    %ebx
f0103ca4:	5e                   	pop    %esi
f0103ca5:	5f                   	pop    %edi
f0103ca6:	5d                   	pop    %ebp
f0103ca7:	c3                   	ret    

f0103ca8 <sched_halt>:
f0103ca8:	55                   	push   %ebp
f0103ca9:	89 e5                	mov    %esp,%ebp
f0103cab:	83 ec 08             	sub    $0x8,%esp
f0103cae:	a1 44 12 23 f0       	mov    0xf0231244,%eax
f0103cb3:	8d 50 54             	lea    0x54(%eax),%edx
f0103cb6:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103cbb:	8b 02                	mov    (%edx),%eax
f0103cbd:	83 e8 01             	sub    $0x1,%eax
f0103cc0:	83 f8 02             	cmp    $0x2,%eax
f0103cc3:	76 2d                	jbe    f0103cf2 <sched_halt+0x4a>
f0103cc5:	83 c1 01             	add    $0x1,%ecx
f0103cc8:	83 c2 7c             	add    $0x7c,%edx
f0103ccb:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f0103cd1:	75 e8                	jne    f0103cbb <sched_halt+0x13>
f0103cd3:	83 ec 0c             	sub    $0xc,%esp
f0103cd6:	68 70 6c 10 f0       	push   $0xf0106c70
f0103cdb:	e8 f2 fa ff ff       	call   f01037d2 <cprintf>
f0103ce0:	83 c4 10             	add    $0x10,%esp
f0103ce3:	83 ec 0c             	sub    $0xc,%esp
f0103ce6:	6a 00                	push   $0x0
f0103ce8:	e8 46 cc ff ff       	call   f0100933 <monitor>
f0103ced:	83 c4 10             	add    $0x10,%esp
f0103cf0:	eb f1                	jmp    f0103ce3 <sched_halt+0x3b>
f0103cf2:	e8 cf 11 00 00       	call   f0104ec6 <cpunum>
f0103cf7:	6b c0 74             	imul   $0x74,%eax,%eax
f0103cfa:	c7 80 28 20 23 f0 00 	movl   $0x0,-0xfdcdfd8(%eax)
f0103d01:	00 00 00 
f0103d04:	a1 0c 1f 23 f0       	mov    0xf0231f0c,%eax
f0103d09:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103d0e:	76 4f                	jbe    f0103d5f <sched_halt+0xb7>
f0103d10:	05 00 00 00 10       	add    $0x10000000,%eax
f0103d15:	0f 22 d8             	mov    %eax,%cr3
f0103d18:	e8 a9 11 00 00       	call   f0104ec6 <cpunum>
f0103d1d:	6b d0 74             	imul   $0x74,%eax,%edx
f0103d20:	83 c2 04             	add    $0x4,%edx
f0103d23:	b8 02 00 00 00       	mov    $0x2,%eax
f0103d28:	f0 87 82 20 20 23 f0 	lock xchg %eax,-0xfdcdfe0(%edx)
f0103d2f:	83 ec 0c             	sub    $0xc,%esp
f0103d32:	68 c0 13 12 f0       	push   $0xf01213c0
f0103d37:	e8 96 14 00 00       	call   f01051d2 <spin_unlock>
f0103d3c:	f3 90                	pause  
f0103d3e:	e8 83 11 00 00       	call   f0104ec6 <cpunum>
f0103d43:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d46:	8b 80 30 20 23 f0    	mov    -0xfdcdfd0(%eax),%eax
f0103d4c:	bd 00 00 00 00       	mov    $0x0,%ebp
f0103d51:	89 c4                	mov    %eax,%esp
f0103d53:	6a 00                	push   $0x0
f0103d55:	6a 00                	push   $0x0
f0103d57:	f4                   	hlt    
f0103d58:	eb fd                	jmp    f0103d57 <sched_halt+0xaf>
f0103d5a:	83 c4 10             	add    $0x10,%esp
f0103d5d:	c9                   	leave  
f0103d5e:	c3                   	ret    
f0103d5f:	50                   	push   %eax
f0103d60:	68 f8 55 10 f0       	push   $0xf01055f8
f0103d65:	6a 3d                	push   $0x3d
f0103d67:	68 99 6c 10 f0       	push   $0xf0106c99
f0103d6c:	e8 23 c3 ff ff       	call   f0100094 <_panic>

f0103d71 <sched_yield>:
f0103d71:	55                   	push   %ebp
f0103d72:	89 e5                	mov    %esp,%ebp
f0103d74:	83 ec 08             	sub    $0x8,%esp
f0103d77:	e8 2c ff ff ff       	call   f0103ca8 <sched_halt>
f0103d7c:	c9                   	leave  
f0103d7d:	c3                   	ret    

f0103d7e <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0103d7e:	55                   	push   %ebp
f0103d7f:	89 e5                	mov    %esp,%ebp
f0103d81:	83 ec 0c             	sub    $0xc,%esp
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.

	panic("syscall not implemented");
f0103d84:	68 a6 6c 10 f0       	push   $0xf0106ca6
f0103d89:	68 12 01 00 00       	push   $0x112
f0103d8e:	68 be 6c 10 f0       	push   $0xf0106cbe
f0103d93:	e8 fc c2 ff ff       	call   f0100094 <_panic>

f0103d98 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0103d98:	55                   	push   %ebp
f0103d99:	89 e5                	mov    %esp,%ebp
f0103d9b:	57                   	push   %edi
f0103d9c:	56                   	push   %esi
f0103d9d:	53                   	push   %ebx
f0103d9e:	83 ec 14             	sub    $0x14,%esp
f0103da1:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103da4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0103da7:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0103daa:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0103dad:	8b 1a                	mov    (%edx),%ebx
f0103daf:	8b 01                	mov    (%ecx),%eax
f0103db1:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103db4:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0103dbb:	eb 23                	jmp    f0103de0 <stab_binsearch+0x48>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0103dbd:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0103dc0:	eb 1e                	jmp    f0103de0 <stab_binsearch+0x48>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0103dc2:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103dc5:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0103dc8:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0103dcc:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0103dcf:	73 41                	jae    f0103e12 <stab_binsearch+0x7a>
			*region_left = m;
f0103dd1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0103dd4:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0103dd6:	8d 5f 01             	lea    0x1(%edi),%ebx
		any_matches = 1;
f0103dd9:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0103de0:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0103de3:	7f 5a                	jg     f0103e3f <stab_binsearch+0xa7>
		int true_m = (l + r) / 2, m = true_m;
f0103de5:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103de8:	01 d8                	add    %ebx,%eax
f0103dea:	89 c7                	mov    %eax,%edi
f0103dec:	c1 ef 1f             	shr    $0x1f,%edi
f0103def:	01 c7                	add    %eax,%edi
f0103df1:	d1 ff                	sar    %edi
f0103df3:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0103df6:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0103df9:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0103dfd:	89 f8                	mov    %edi,%eax
		while (m >= l && stabs[m].n_type != type)
f0103dff:	39 c3                	cmp    %eax,%ebx
f0103e01:	7f ba                	jg     f0103dbd <stab_binsearch+0x25>
f0103e03:	0f b6 0a             	movzbl (%edx),%ecx
f0103e06:	83 ea 0c             	sub    $0xc,%edx
f0103e09:	39 f1                	cmp    %esi,%ecx
f0103e0b:	74 b5                	je     f0103dc2 <stab_binsearch+0x2a>
			m--;
f0103e0d:	83 e8 01             	sub    $0x1,%eax
f0103e10:	eb ed                	jmp    f0103dff <stab_binsearch+0x67>
		} else if (stabs[m].n_value > addr) {
f0103e12:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0103e15:	76 14                	jbe    f0103e2b <stab_binsearch+0x93>
			*region_right = m - 1;
f0103e17:	83 e8 01             	sub    $0x1,%eax
f0103e1a:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103e1d:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0103e20:	89 07                	mov    %eax,(%edi)
		any_matches = 1;
f0103e22:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0103e29:	eb b5                	jmp    f0103de0 <stab_binsearch+0x48>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0103e2b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103e2e:	89 07                	mov    %eax,(%edi)
			l = m;
			addr++;
f0103e30:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0103e34:	89 c3                	mov    %eax,%ebx
		any_matches = 1;
f0103e36:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0103e3d:	eb a1                	jmp    f0103de0 <stab_binsearch+0x48>
		}
	}

	if (!any_matches)
f0103e3f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0103e43:	75 15                	jne    f0103e5a <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f0103e45:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103e48:	8b 00                	mov    (%eax),%eax
f0103e4a:	83 e8 01             	sub    $0x1,%eax
f0103e4d:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0103e50:	89 06                	mov    %eax,(%esi)
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0103e52:	83 c4 14             	add    $0x14,%esp
f0103e55:	5b                   	pop    %ebx
f0103e56:	5e                   	pop    %esi
f0103e57:	5f                   	pop    %edi
f0103e58:	5d                   	pop    %ebp
f0103e59:	c3                   	ret    
		for (l = *region_right;
f0103e5a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103e5d:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0103e5f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103e62:	8b 0f                	mov    (%edi),%ecx
f0103e64:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103e67:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0103e6a:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
		for (l = *region_right;
f0103e6e:	eb 03                	jmp    f0103e73 <stab_binsearch+0xdb>
		     l--)
f0103e70:	83 e8 01             	sub    $0x1,%eax
		for (l = *region_right;
f0103e73:	39 c1                	cmp    %eax,%ecx
f0103e75:	7d 0a                	jge    f0103e81 <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f0103e77:	0f b6 1a             	movzbl (%edx),%ebx
f0103e7a:	83 ea 0c             	sub    $0xc,%edx
f0103e7d:	39 f3                	cmp    %esi,%ebx
f0103e7f:	75 ef                	jne    f0103e70 <stab_binsearch+0xd8>
		*region_left = l;
f0103e81:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0103e84:	89 06                	mov    %eax,(%esi)
}
f0103e86:	eb ca                	jmp    f0103e52 <stab_binsearch+0xba>

f0103e88 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0103e88:	55                   	push   %ebp
f0103e89:	89 e5                	mov    %esp,%ebp
f0103e8b:	57                   	push   %edi
f0103e8c:	56                   	push   %esi
f0103e8d:	53                   	push   %ebx
f0103e8e:	83 ec 4c             	sub    $0x4c,%esp
f0103e91:	8b 75 08             	mov    0x8(%ebp),%esi
f0103e94:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0103e97:	c7 03 cd 6c 10 f0    	movl   $0xf0106ccd,(%ebx)
	info->eip_line = 0;
f0103e9d:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0103ea4:	c7 43 08 cd 6c 10 f0 	movl   $0xf0106ccd,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0103eab:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0103eb2:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0103eb5:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0103ebc:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0103ec2:	0f 87 1d 01 00 00    	ja     f0103fe5 <debuginfo_eip+0x15d>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f0103ec8:	a1 00 00 20 00       	mov    0x200000,%eax
f0103ecd:	89 45 b8             	mov    %eax,-0x48(%ebp)
		stab_end = usd->stab_end;
f0103ed0:	a1 04 00 20 00       	mov    0x200004,%eax
		stabstr = usd->stabstr;
f0103ed5:	8b 3d 08 00 20 00    	mov    0x200008,%edi
f0103edb:	89 7d b4             	mov    %edi,-0x4c(%ebp)
		stabstr_end = usd->stabstr_end;
f0103ede:	8b 3d 0c 00 20 00    	mov    0x20000c,%edi
f0103ee4:	89 7d bc             	mov    %edi,-0x44(%ebp)
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0103ee7:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0103eea:	39 7d b4             	cmp    %edi,-0x4c(%ebp)
f0103eed:	0f 83 bb 01 00 00    	jae    f01040ae <debuginfo_eip+0x226>
f0103ef3:	80 7f ff 00          	cmpb   $0x0,-0x1(%edi)
f0103ef7:	0f 85 b8 01 00 00    	jne    f01040b5 <debuginfo_eip+0x22d>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0103efd:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0103f04:	8b 7d b8             	mov    -0x48(%ebp),%edi
f0103f07:	29 f8                	sub    %edi,%eax
f0103f09:	c1 f8 02             	sar    $0x2,%eax
f0103f0c:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0103f12:	83 e8 01             	sub    $0x1,%eax
f0103f15:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0103f18:	56                   	push   %esi
f0103f19:	6a 64                	push   $0x64
f0103f1b:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0103f1e:	89 c1                	mov    %eax,%ecx
f0103f20:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0103f23:	89 f8                	mov    %edi,%eax
f0103f25:	e8 6e fe ff ff       	call   f0103d98 <stab_binsearch>
	if (lfile == 0)
f0103f2a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103f2d:	83 c4 08             	add    $0x8,%esp
f0103f30:	85 c0                	test   %eax,%eax
f0103f32:	0f 84 84 01 00 00    	je     f01040bc <debuginfo_eip+0x234>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0103f38:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0103f3b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103f3e:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0103f41:	56                   	push   %esi
f0103f42:	6a 24                	push   $0x24
f0103f44:	8d 45 d8             	lea    -0x28(%ebp),%eax
f0103f47:	89 c1                	mov    %eax,%ecx
f0103f49:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0103f4c:	89 f8                	mov    %edi,%eax
f0103f4e:	e8 45 fe ff ff       	call   f0103d98 <stab_binsearch>

	if (lfun <= rfun) {
f0103f53:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103f56:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0103f59:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
f0103f5c:	83 c4 08             	add    $0x8,%esp
f0103f5f:	39 c8                	cmp    %ecx,%eax
f0103f61:	0f 8f 9d 00 00 00    	jg     f0104004 <debuginfo_eip+0x17c>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0103f67:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103f6a:	8d 0c 97             	lea    (%edi,%edx,4),%ecx
f0103f6d:	8b 11                	mov    (%ecx),%edx
f0103f6f:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0103f72:	2b 7d b4             	sub    -0x4c(%ebp),%edi
f0103f75:	39 fa                	cmp    %edi,%edx
f0103f77:	73 06                	jae    f0103f7f <debuginfo_eip+0xf7>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0103f79:	03 55 b4             	add    -0x4c(%ebp),%edx
f0103f7c:	89 53 08             	mov    %edx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0103f7f:	8b 51 08             	mov    0x8(%ecx),%edx
f0103f82:	89 53 10             	mov    %edx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0103f85:	29 d6                	sub    %edx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0103f87:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0103f8a:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0103f8d:	89 45 d0             	mov    %eax,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0103f90:	83 ec 08             	sub    $0x8,%esp
f0103f93:	6a 3a                	push   $0x3a
f0103f95:	ff 73 08             	pushl  0x8(%ebx)
f0103f98:	e8 0e 09 00 00       	call   f01048ab <strfind>
f0103f9d:	2b 43 08             	sub    0x8(%ebx),%eax
f0103fa0:	89 43 0c             	mov    %eax,0xc(%ebx)
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0103fa3:	83 c4 08             	add    $0x8,%esp
f0103fa6:	56                   	push   %esi
f0103fa7:	6a 44                	push   $0x44
f0103fa9:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0103fac:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0103faf:	8b 75 b8             	mov    -0x48(%ebp),%esi
f0103fb2:	89 f0                	mov    %esi,%eax
f0103fb4:	e8 df fd ff ff       	call   f0103d98 <stab_binsearch>
	if (lline <= rline) {
f0103fb9:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103fbc:	83 c4 10             	add    $0x10,%esp
f0103fbf:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f0103fc2:	0f 8f fb 00 00 00    	jg     f01040c3 <debuginfo_eip+0x23b>
		 info->eip_line = stabs[lline].n_desc;
f0103fc8:	89 d0                	mov    %edx,%eax
f0103fca:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0103fcd:	c1 e2 02             	shl    $0x2,%edx
f0103fd0:	0f b7 4c 16 06       	movzwl 0x6(%esi,%edx,1),%ecx
f0103fd5:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0103fd8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103fdb:	8d 54 16 04          	lea    0x4(%esi,%edx,1),%edx
f0103fdf:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f0103fe3:	eb 3d                	jmp    f0104022 <debuginfo_eip+0x19a>
		stabstr_end = __STABSTR_END__;
f0103fe5:	c7 45 bc c4 60 11 f0 	movl   $0xf01160c4,-0x44(%ebp)
		stabstr = __STABSTR_BEGIN__;
f0103fec:	c7 45 b4 d5 29 11 f0 	movl   $0xf01129d5,-0x4c(%ebp)
		stab_end = __STAB_END__;
f0103ff3:	b8 d4 29 11 f0       	mov    $0xf01129d4,%eax
		stabs = __STAB_BEGIN__;
f0103ff8:	c7 45 b8 b4 71 10 f0 	movl   $0xf01071b4,-0x48(%ebp)
f0103fff:	e9 e3 fe ff ff       	jmp    f0103ee7 <debuginfo_eip+0x5f>
		info->eip_fn_addr = addr;
f0104004:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0104007:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010400a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f010400d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104010:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0104013:	e9 78 ff ff ff       	jmp    f0103f90 <debuginfo_eip+0x108>
f0104018:	83 e8 01             	sub    $0x1,%eax
f010401b:	83 ea 0c             	sub    $0xc,%edx
f010401e:	c6 45 c4 01          	movb   $0x1,-0x3c(%ebp)
f0104022:	89 45 c0             	mov    %eax,-0x40(%ebp)
	while (lline >= lfile
f0104025:	39 c7                	cmp    %eax,%edi
f0104027:	7f 45                	jg     f010406e <debuginfo_eip+0x1e6>
	       && stabs[lline].n_type != N_SOL
f0104029:	0f b6 0a             	movzbl (%edx),%ecx
f010402c:	80 f9 84             	cmp    $0x84,%cl
f010402f:	74 19                	je     f010404a <debuginfo_eip+0x1c2>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104031:	80 f9 64             	cmp    $0x64,%cl
f0104034:	75 e2                	jne    f0104018 <debuginfo_eip+0x190>
f0104036:	83 7a 04 00          	cmpl   $0x0,0x4(%edx)
f010403a:	74 dc                	je     f0104018 <debuginfo_eip+0x190>
f010403c:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0104040:	74 11                	je     f0104053 <debuginfo_eip+0x1cb>
f0104042:	8b 75 c0             	mov    -0x40(%ebp),%esi
f0104045:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0104048:	eb 09                	jmp    f0104053 <debuginfo_eip+0x1cb>
f010404a:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f010404e:	74 03                	je     f0104053 <debuginfo_eip+0x1cb>
f0104050:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0104053:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0104056:	8b 7d b8             	mov    -0x48(%ebp),%edi
f0104059:	8b 14 87             	mov    (%edi,%eax,4),%edx
f010405c:	8b 45 bc             	mov    -0x44(%ebp),%eax
f010405f:	8b 7d b4             	mov    -0x4c(%ebp),%edi
f0104062:	29 f8                	sub    %edi,%eax
f0104064:	39 c2                	cmp    %eax,%edx
f0104066:	73 06                	jae    f010406e <debuginfo_eip+0x1e6>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0104068:	89 f8                	mov    %edi,%eax
f010406a:	01 d0                	add    %edx,%eax
f010406c:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f010406e:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104071:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104074:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f0104079:	39 f2                	cmp    %esi,%edx
f010407b:	7d 52                	jge    f01040cf <debuginfo_eip+0x247>
		for (lline = lfun + 1;
f010407d:	83 c2 01             	add    $0x1,%edx
f0104080:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0104083:	89 d0                	mov    %edx,%eax
f0104085:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0104088:	8b 7d b8             	mov    -0x48(%ebp),%edi
f010408b:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
f010408f:	eb 04                	jmp    f0104095 <debuginfo_eip+0x20d>
			info->eip_fn_narg++;
f0104091:	83 43 14 01          	addl   $0x1,0x14(%ebx)
		for (lline = lfun + 1;
f0104095:	39 c6                	cmp    %eax,%esi
f0104097:	7e 31                	jle    f01040ca <debuginfo_eip+0x242>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0104099:	0f b6 0a             	movzbl (%edx),%ecx
f010409c:	83 c0 01             	add    $0x1,%eax
f010409f:	83 c2 0c             	add    $0xc,%edx
f01040a2:	80 f9 a0             	cmp    $0xa0,%cl
f01040a5:	74 ea                	je     f0104091 <debuginfo_eip+0x209>
	return 0;
f01040a7:	b8 00 00 00 00       	mov    $0x0,%eax
f01040ac:	eb 21                	jmp    f01040cf <debuginfo_eip+0x247>
		return -1;
f01040ae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01040b3:	eb 1a                	jmp    f01040cf <debuginfo_eip+0x247>
f01040b5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01040ba:	eb 13                	jmp    f01040cf <debuginfo_eip+0x247>
		return -1;
f01040bc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01040c1:	eb 0c                	jmp    f01040cf <debuginfo_eip+0x247>
		 return -1;
f01040c3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01040c8:	eb 05                	jmp    f01040cf <debuginfo_eip+0x247>
	return 0;
f01040ca:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01040cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01040d2:	5b                   	pop    %ebx
f01040d3:	5e                   	pop    %esi
f01040d4:	5f                   	pop    %edi
f01040d5:	5d                   	pop    %ebp
f01040d6:	c3                   	ret    

f01040d7 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f01040d7:	55                   	push   %ebp
f01040d8:	89 e5                	mov    %esp,%ebp
f01040da:	57                   	push   %edi
f01040db:	56                   	push   %esi
f01040dc:	53                   	push   %ebx
f01040dd:	83 ec 1c             	sub    $0x1c,%esp
f01040e0:	89 c7                	mov    %eax,%edi
f01040e2:	89 d6                	mov    %edx,%esi
f01040e4:	8b 45 08             	mov    0x8(%ebp),%eax
f01040e7:	8b 55 0c             	mov    0xc(%ebp),%edx
f01040ea:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01040ed:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f01040f0:	8b 4d 10             	mov    0x10(%ebp),%ecx
f01040f3:	bb 00 00 00 00       	mov    $0x0,%ebx
f01040f8:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01040fb:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f01040fe:	3b 45 10             	cmp    0x10(%ebp),%eax
f0104101:	89 d0                	mov    %edx,%eax
f0104103:	1b 45 e4             	sbb    -0x1c(%ebp),%eax
f0104106:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0104109:	73 15                	jae    f0104120 <printnum+0x49>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f010410b:	83 eb 01             	sub    $0x1,%ebx
f010410e:	85 db                	test   %ebx,%ebx
f0104110:	7e 43                	jle    f0104155 <printnum+0x7e>
			putch(padc, putdat);
f0104112:	83 ec 08             	sub    $0x8,%esp
f0104115:	56                   	push   %esi
f0104116:	ff 75 18             	pushl  0x18(%ebp)
f0104119:	ff d7                	call   *%edi
f010411b:	83 c4 10             	add    $0x10,%esp
f010411e:	eb eb                	jmp    f010410b <printnum+0x34>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0104120:	83 ec 0c             	sub    $0xc,%esp
f0104123:	ff 75 18             	pushl  0x18(%ebp)
f0104126:	8b 45 14             	mov    0x14(%ebp),%eax
f0104129:	8d 58 ff             	lea    -0x1(%eax),%ebx
f010412c:	53                   	push   %ebx
f010412d:	ff 75 10             	pushl  0x10(%ebp)
f0104130:	83 ec 08             	sub    $0x8,%esp
f0104133:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104136:	ff 75 e0             	pushl  -0x20(%ebp)
f0104139:	ff 75 dc             	pushl  -0x24(%ebp)
f010413c:	ff 75 d8             	pushl  -0x28(%ebp)
f010413f:	e8 7c 11 00 00       	call   f01052c0 <__udivdi3>
f0104144:	83 c4 18             	add    $0x18,%esp
f0104147:	52                   	push   %edx
f0104148:	50                   	push   %eax
f0104149:	89 f2                	mov    %esi,%edx
f010414b:	89 f8                	mov    %edi,%eax
f010414d:	e8 85 ff ff ff       	call   f01040d7 <printnum>
f0104152:	83 c4 20             	add    $0x20,%esp
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0104155:	83 ec 08             	sub    $0x8,%esp
f0104158:	56                   	push   %esi
f0104159:	83 ec 04             	sub    $0x4,%esp
f010415c:	ff 75 e4             	pushl  -0x1c(%ebp)
f010415f:	ff 75 e0             	pushl  -0x20(%ebp)
f0104162:	ff 75 dc             	pushl  -0x24(%ebp)
f0104165:	ff 75 d8             	pushl  -0x28(%ebp)
f0104168:	e8 63 12 00 00       	call   f01053d0 <__umoddi3>
f010416d:	83 c4 14             	add    $0x14,%esp
f0104170:	0f be 80 d7 6c 10 f0 	movsbl -0xfef9329(%eax),%eax
f0104177:	50                   	push   %eax
f0104178:	ff d7                	call   *%edi
}
f010417a:	83 c4 10             	add    $0x10,%esp
f010417d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104180:	5b                   	pop    %ebx
f0104181:	5e                   	pop    %esi
f0104182:	5f                   	pop    %edi
f0104183:	5d                   	pop    %ebp
f0104184:	c3                   	ret    

f0104185 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0104185:	55                   	push   %ebp
f0104186:	89 e5                	mov    %esp,%ebp
f0104188:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f010418b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f010418f:	8b 10                	mov    (%eax),%edx
f0104191:	3b 50 04             	cmp    0x4(%eax),%edx
f0104194:	73 0a                	jae    f01041a0 <sprintputch+0x1b>
		*b->buf++ = ch;
f0104196:	8d 4a 01             	lea    0x1(%edx),%ecx
f0104199:	89 08                	mov    %ecx,(%eax)
f010419b:	8b 45 08             	mov    0x8(%ebp),%eax
f010419e:	88 02                	mov    %al,(%edx)
}
f01041a0:	5d                   	pop    %ebp
f01041a1:	c3                   	ret    

f01041a2 <printfmt>:
{
f01041a2:	55                   	push   %ebp
f01041a3:	89 e5                	mov    %esp,%ebp
f01041a5:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f01041a8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f01041ab:	50                   	push   %eax
f01041ac:	ff 75 10             	pushl  0x10(%ebp)
f01041af:	ff 75 0c             	pushl  0xc(%ebp)
f01041b2:	ff 75 08             	pushl  0x8(%ebp)
f01041b5:	e8 05 00 00 00       	call   f01041bf <vprintfmt>
}
f01041ba:	83 c4 10             	add    $0x10,%esp
f01041bd:	c9                   	leave  
f01041be:	c3                   	ret    

f01041bf <vprintfmt>:
{
f01041bf:	55                   	push   %ebp
f01041c0:	89 e5                	mov    %esp,%ebp
f01041c2:	57                   	push   %edi
f01041c3:	56                   	push   %esi
f01041c4:	53                   	push   %ebx
f01041c5:	83 ec 3c             	sub    $0x3c,%esp
f01041c8:	8b 75 08             	mov    0x8(%ebp),%esi
f01041cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01041ce:	8b 7d 10             	mov    0x10(%ebp),%edi
f01041d1:	eb 0a                	jmp    f01041dd <vprintfmt+0x1e>
			putch(ch, putdat);
f01041d3:	83 ec 08             	sub    $0x8,%esp
f01041d6:	53                   	push   %ebx
f01041d7:	50                   	push   %eax
f01041d8:	ff d6                	call   *%esi
f01041da:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01041dd:	83 c7 01             	add    $0x1,%edi
f01041e0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f01041e4:	83 f8 25             	cmp    $0x25,%eax
f01041e7:	74 0c                	je     f01041f5 <vprintfmt+0x36>
			if (ch == '\0')
f01041e9:	85 c0                	test   %eax,%eax
f01041eb:	75 e6                	jne    f01041d3 <vprintfmt+0x14>
}
f01041ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01041f0:	5b                   	pop    %ebx
f01041f1:	5e                   	pop    %esi
f01041f2:	5f                   	pop    %edi
f01041f3:	5d                   	pop    %ebp
f01041f4:	c3                   	ret    
		padc = ' ';
f01041f5:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
f01041f9:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;//精度
f0104200:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;//总宽度
f0104207:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f010420e:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f0104213:	8d 47 01             	lea    0x1(%edi),%eax
f0104216:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104219:	0f b6 17             	movzbl (%edi),%edx
f010421c:	8d 42 dd             	lea    -0x23(%edx),%eax
f010421f:	3c 55                	cmp    $0x55,%al
f0104221:	0f 87 ba 03 00 00    	ja     f01045e1 <vprintfmt+0x422>
f0104227:	0f b6 c0             	movzbl %al,%eax
f010422a:	ff 24 85 a0 6d 10 f0 	jmp    *-0xfef9260(,%eax,4)
f0104231:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
f0104234:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
f0104238:	eb d9                	jmp    f0104213 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
f010423a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
f010423d:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
f0104241:	eb d0                	jmp    f0104213 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
f0104243:	0f b6 d2             	movzbl %dl,%edx
f0104246:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {//依次读取数据宽度
f0104249:	b8 00 00 00 00       	mov    $0x0,%eax
f010424e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
f0104251:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0104254:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f0104258:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f010425b:	8d 4a d0             	lea    -0x30(%edx),%ecx
f010425e:	83 f9 09             	cmp    $0x9,%ecx
f0104261:	77 55                	ja     f01042b8 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {//依次读取数据宽度
f0104263:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
f0104266:	eb e9                	jmp    f0104251 <vprintfmt+0x92>
			precision = va_arg(ap, int);
f0104268:	8b 45 14             	mov    0x14(%ebp),%eax
f010426b:	8b 00                	mov    (%eax),%eax
f010426d:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104270:	8b 45 14             	mov    0x14(%ebp),%eax
f0104273:	8d 40 04             	lea    0x4(%eax),%eax
f0104276:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0104279:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
f010427c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0104280:	79 91                	jns    f0104213 <vprintfmt+0x54>
				width = precision, precision = -1;
f0104282:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0104285:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104288:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
f010428f:	eb 82                	jmp    f0104213 <vprintfmt+0x54>
f0104291:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104294:	85 c0                	test   %eax,%eax
f0104296:	ba 00 00 00 00       	mov    $0x0,%edx
f010429b:	0f 49 d0             	cmovns %eax,%edx
f010429e:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01042a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01042a4:	e9 6a ff ff ff       	jmp    f0104213 <vprintfmt+0x54>
f01042a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
f01042ac:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
f01042b3:	e9 5b ff ff ff       	jmp    f0104213 <vprintfmt+0x54>
f01042b8:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01042bb:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01042be:	eb bc                	jmp    f010427c <vprintfmt+0xbd>
			lflag++;
f01042c0:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f01042c3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f01042c6:	e9 48 ff ff ff       	jmp    f0104213 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
f01042cb:	8b 45 14             	mov    0x14(%ebp),%eax
f01042ce:	8d 78 04             	lea    0x4(%eax),%edi
f01042d1:	83 ec 08             	sub    $0x8,%esp
f01042d4:	53                   	push   %ebx
f01042d5:	ff 30                	pushl  (%eax)
f01042d7:	ff d6                	call   *%esi
			break;
f01042d9:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f01042dc:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
f01042df:	e9 9c 02 00 00       	jmp    f0104580 <vprintfmt+0x3c1>
			err = va_arg(ap, int);
f01042e4:	8b 45 14             	mov    0x14(%ebp),%eax
f01042e7:	8d 78 04             	lea    0x4(%eax),%edi
f01042ea:	8b 00                	mov    (%eax),%eax
f01042ec:	99                   	cltd   
f01042ed:	31 d0                	xor    %edx,%eax
f01042ef:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01042f1:	83 f8 08             	cmp    $0x8,%eax
f01042f4:	7f 23                	jg     f0104319 <vprintfmt+0x15a>
f01042f6:	8b 14 85 00 6f 10 f0 	mov    -0xfef9100(,%eax,4),%edx
f01042fd:	85 d2                	test   %edx,%edx
f01042ff:	74 18                	je     f0104319 <vprintfmt+0x15a>
				printfmt(putch, putdat, "%s", p);
f0104301:	52                   	push   %edx
f0104302:	68 dc 64 10 f0       	push   $0xf01064dc
f0104307:	53                   	push   %ebx
f0104308:	56                   	push   %esi
f0104309:	e8 94 fe ff ff       	call   f01041a2 <printfmt>
f010430e:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0104311:	89 7d 14             	mov    %edi,0x14(%ebp)
f0104314:	e9 67 02 00 00       	jmp    f0104580 <vprintfmt+0x3c1>
				printfmt(putch, putdat, "error %d", err);
f0104319:	50                   	push   %eax
f010431a:	68 ef 6c 10 f0       	push   $0xf0106cef
f010431f:	53                   	push   %ebx
f0104320:	56                   	push   %esi
f0104321:	e8 7c fe ff ff       	call   f01041a2 <printfmt>
f0104326:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0104329:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f010432c:	e9 4f 02 00 00       	jmp    f0104580 <vprintfmt+0x3c1>
			if ((p = va_arg(ap, char *)) == NULL)
f0104331:	8b 45 14             	mov    0x14(%ebp),%eax
f0104334:	83 c0 04             	add    $0x4,%eax
f0104337:	89 45 c8             	mov    %eax,-0x38(%ebp)
f010433a:	8b 45 14             	mov    0x14(%ebp),%eax
f010433d:	8b 10                	mov    (%eax),%edx
				p = "(null)";
f010433f:	85 d2                	test   %edx,%edx
f0104341:	b8 e8 6c 10 f0       	mov    $0xf0106ce8,%eax
f0104346:	0f 45 c2             	cmovne %edx,%eax
f0104349:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
f010434c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0104350:	7e 06                	jle    f0104358 <vprintfmt+0x199>
f0104352:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
f0104356:	75 0d                	jne    f0104365 <vprintfmt+0x1a6>
				for (width -= strnlen(p, precision); width > 0; width--)
f0104358:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010435b:	89 c7                	mov    %eax,%edi
f010435d:	03 45 e0             	add    -0x20(%ebp),%eax
f0104360:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104363:	eb 3f                	jmp    f01043a4 <vprintfmt+0x1e5>
f0104365:	83 ec 08             	sub    $0x8,%esp
f0104368:	ff 75 d8             	pushl  -0x28(%ebp)
f010436b:	50                   	push   %eax
f010436c:	e8 ef 03 00 00       	call   f0104760 <strnlen>
f0104371:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104374:	29 c2                	sub    %eax,%edx
f0104376:	89 55 c4             	mov    %edx,-0x3c(%ebp)
f0104379:	83 c4 10             	add    $0x10,%esp
f010437c:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
f010437e:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
f0104382:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f0104385:	85 ff                	test   %edi,%edi
f0104387:	7e 58                	jle    f01043e1 <vprintfmt+0x222>
					putch(padc, putdat);
f0104389:	83 ec 08             	sub    $0x8,%esp
f010438c:	53                   	push   %ebx
f010438d:	ff 75 e0             	pushl  -0x20(%ebp)
f0104390:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f0104392:	83 ef 01             	sub    $0x1,%edi
f0104395:	83 c4 10             	add    $0x10,%esp
f0104398:	eb eb                	jmp    f0104385 <vprintfmt+0x1c6>
					putch(ch, putdat);
f010439a:	83 ec 08             	sub    $0x8,%esp
f010439d:	53                   	push   %ebx
f010439e:	52                   	push   %edx
f010439f:	ff d6                	call   *%esi
f01043a1:	83 c4 10             	add    $0x10,%esp
f01043a4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01043a7:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01043a9:	83 c7 01             	add    $0x1,%edi
f01043ac:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f01043b0:	0f be d0             	movsbl %al,%edx
f01043b3:	85 d2                	test   %edx,%edx
f01043b5:	74 45                	je     f01043fc <vprintfmt+0x23d>
f01043b7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f01043bb:	78 06                	js     f01043c3 <vprintfmt+0x204>
f01043bd:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
f01043c1:	78 35                	js     f01043f8 <vprintfmt+0x239>
				if (altflag && (ch < ' ' || ch > '~'))
f01043c3:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f01043c7:	74 d1                	je     f010439a <vprintfmt+0x1db>
f01043c9:	0f be c0             	movsbl %al,%eax
f01043cc:	83 e8 20             	sub    $0x20,%eax
f01043cf:	83 f8 5e             	cmp    $0x5e,%eax
f01043d2:	76 c6                	jbe    f010439a <vprintfmt+0x1db>
					putch('?', putdat);
f01043d4:	83 ec 08             	sub    $0x8,%esp
f01043d7:	53                   	push   %ebx
f01043d8:	6a 3f                	push   $0x3f
f01043da:	ff d6                	call   *%esi
f01043dc:	83 c4 10             	add    $0x10,%esp
f01043df:	eb c3                	jmp    f01043a4 <vprintfmt+0x1e5>
f01043e1:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f01043e4:	85 d2                	test   %edx,%edx
f01043e6:	b8 00 00 00 00       	mov    $0x0,%eax
f01043eb:	0f 49 c2             	cmovns %edx,%eax
f01043ee:	29 c2                	sub    %eax,%edx
f01043f0:	89 55 e0             	mov    %edx,-0x20(%ebp)
f01043f3:	e9 60 ff ff ff       	jmp    f0104358 <vprintfmt+0x199>
f01043f8:	89 cf                	mov    %ecx,%edi
f01043fa:	eb 02                	jmp    f01043fe <vprintfmt+0x23f>
f01043fc:	89 cf                	mov    %ecx,%edi
			for (; width > 0; width--)
f01043fe:	85 ff                	test   %edi,%edi
f0104400:	7e 10                	jle    f0104412 <vprintfmt+0x253>
				putch(' ', putdat);
f0104402:	83 ec 08             	sub    $0x8,%esp
f0104405:	53                   	push   %ebx
f0104406:	6a 20                	push   $0x20
f0104408:	ff d6                	call   *%esi
			for (; width > 0; width--)
f010440a:	83 ef 01             	sub    $0x1,%edi
f010440d:	83 c4 10             	add    $0x10,%esp
f0104410:	eb ec                	jmp    f01043fe <vprintfmt+0x23f>
			if ((p = va_arg(ap, char *)) == NULL)
f0104412:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0104415:	89 45 14             	mov    %eax,0x14(%ebp)
f0104418:	e9 63 01 00 00       	jmp    f0104580 <vprintfmt+0x3c1>
	if (lflag >= 2)
f010441d:	83 f9 01             	cmp    $0x1,%ecx
f0104420:	7f 1b                	jg     f010443d <vprintfmt+0x27e>
	else if (lflag)
f0104422:	85 c9                	test   %ecx,%ecx
f0104424:	74 63                	je     f0104489 <vprintfmt+0x2ca>
		return va_arg(*ap, long);
f0104426:	8b 45 14             	mov    0x14(%ebp),%eax
f0104429:	8b 00                	mov    (%eax),%eax
f010442b:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010442e:	99                   	cltd   
f010442f:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0104432:	8b 45 14             	mov    0x14(%ebp),%eax
f0104435:	8d 40 04             	lea    0x4(%eax),%eax
f0104438:	89 45 14             	mov    %eax,0x14(%ebp)
f010443b:	eb 17                	jmp    f0104454 <vprintfmt+0x295>
		return va_arg(*ap, long long);
f010443d:	8b 45 14             	mov    0x14(%ebp),%eax
f0104440:	8b 50 04             	mov    0x4(%eax),%edx
f0104443:	8b 00                	mov    (%eax),%eax
f0104445:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104448:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010444b:	8b 45 14             	mov    0x14(%ebp),%eax
f010444e:	8d 40 08             	lea    0x8(%eax),%eax
f0104451:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f0104454:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104457:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f010445a:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
f010445f:	85 c9                	test   %ecx,%ecx
f0104461:	0f 89 ff 00 00 00    	jns    f0104566 <vprintfmt+0x3a7>
				putch('-', putdat);
f0104467:	83 ec 08             	sub    $0x8,%esp
f010446a:	53                   	push   %ebx
f010446b:	6a 2d                	push   $0x2d
f010446d:	ff d6                	call   *%esi
				num = -(long long) num;
f010446f:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104472:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0104475:	f7 da                	neg    %edx
f0104477:	83 d1 00             	adc    $0x0,%ecx
f010447a:	f7 d9                	neg    %ecx
f010447c:	83 c4 10             	add    $0x10,%esp
			base = 10;
f010447f:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104484:	e9 dd 00 00 00       	jmp    f0104566 <vprintfmt+0x3a7>
		return va_arg(*ap, int);
f0104489:	8b 45 14             	mov    0x14(%ebp),%eax
f010448c:	8b 00                	mov    (%eax),%eax
f010448e:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104491:	99                   	cltd   
f0104492:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0104495:	8b 45 14             	mov    0x14(%ebp),%eax
f0104498:	8d 40 04             	lea    0x4(%eax),%eax
f010449b:	89 45 14             	mov    %eax,0x14(%ebp)
f010449e:	eb b4                	jmp    f0104454 <vprintfmt+0x295>
	if (lflag >= 2)
f01044a0:	83 f9 01             	cmp    $0x1,%ecx
f01044a3:	7f 1e                	jg     f01044c3 <vprintfmt+0x304>
	else if (lflag)
f01044a5:	85 c9                	test   %ecx,%ecx
f01044a7:	74 32                	je     f01044db <vprintfmt+0x31c>
		return va_arg(*ap, unsigned long);
f01044a9:	8b 45 14             	mov    0x14(%ebp),%eax
f01044ac:	8b 10                	mov    (%eax),%edx
f01044ae:	b9 00 00 00 00       	mov    $0x0,%ecx
f01044b3:	8d 40 04             	lea    0x4(%eax),%eax
f01044b6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01044b9:	b8 0a 00 00 00       	mov    $0xa,%eax
f01044be:	e9 a3 00 00 00       	jmp    f0104566 <vprintfmt+0x3a7>
		return va_arg(*ap, unsigned long long);
f01044c3:	8b 45 14             	mov    0x14(%ebp),%eax
f01044c6:	8b 10                	mov    (%eax),%edx
f01044c8:	8b 48 04             	mov    0x4(%eax),%ecx
f01044cb:	8d 40 08             	lea    0x8(%eax),%eax
f01044ce:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01044d1:	b8 0a 00 00 00       	mov    $0xa,%eax
f01044d6:	e9 8b 00 00 00       	jmp    f0104566 <vprintfmt+0x3a7>
		return va_arg(*ap, unsigned int);
f01044db:	8b 45 14             	mov    0x14(%ebp),%eax
f01044de:	8b 10                	mov    (%eax),%edx
f01044e0:	b9 00 00 00 00       	mov    $0x0,%ecx
f01044e5:	8d 40 04             	lea    0x4(%eax),%eax
f01044e8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01044eb:	b8 0a 00 00 00       	mov    $0xa,%eax
f01044f0:	eb 74                	jmp    f0104566 <vprintfmt+0x3a7>
	if (lflag >= 2)
f01044f2:	83 f9 01             	cmp    $0x1,%ecx
f01044f5:	7f 1b                	jg     f0104512 <vprintfmt+0x353>
	else if (lflag)
f01044f7:	85 c9                	test   %ecx,%ecx
f01044f9:	74 2c                	je     f0104527 <vprintfmt+0x368>
		return va_arg(*ap, unsigned long);
f01044fb:	8b 45 14             	mov    0x14(%ebp),%eax
f01044fe:	8b 10                	mov    (%eax),%edx
f0104500:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104505:	8d 40 04             	lea    0x4(%eax),%eax
f0104508:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f010450b:	b8 08 00 00 00       	mov    $0x8,%eax
f0104510:	eb 54                	jmp    f0104566 <vprintfmt+0x3a7>
		return va_arg(*ap, unsigned long long);
f0104512:	8b 45 14             	mov    0x14(%ebp),%eax
f0104515:	8b 10                	mov    (%eax),%edx
f0104517:	8b 48 04             	mov    0x4(%eax),%ecx
f010451a:	8d 40 08             	lea    0x8(%eax),%eax
f010451d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0104520:	b8 08 00 00 00       	mov    $0x8,%eax
f0104525:	eb 3f                	jmp    f0104566 <vprintfmt+0x3a7>
		return va_arg(*ap, unsigned int);
f0104527:	8b 45 14             	mov    0x14(%ebp),%eax
f010452a:	8b 10                	mov    (%eax),%edx
f010452c:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104531:	8d 40 04             	lea    0x4(%eax),%eax
f0104534:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0104537:	b8 08 00 00 00       	mov    $0x8,%eax
f010453c:	eb 28                	jmp    f0104566 <vprintfmt+0x3a7>
			putch('0', putdat);
f010453e:	83 ec 08             	sub    $0x8,%esp
f0104541:	53                   	push   %ebx
f0104542:	6a 30                	push   $0x30
f0104544:	ff d6                	call   *%esi
			putch('x', putdat);
f0104546:	83 c4 08             	add    $0x8,%esp
f0104549:	53                   	push   %ebx
f010454a:	6a 78                	push   $0x78
f010454c:	ff d6                	call   *%esi
			num = (unsigned long long)
f010454e:	8b 45 14             	mov    0x14(%ebp),%eax
f0104551:	8b 10                	mov    (%eax),%edx
f0104553:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f0104558:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f010455b:	8d 40 04             	lea    0x4(%eax),%eax
f010455e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0104561:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
f0104566:	83 ec 0c             	sub    $0xc,%esp
f0104569:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
f010456d:	57                   	push   %edi
f010456e:	ff 75 e0             	pushl  -0x20(%ebp)
f0104571:	50                   	push   %eax
f0104572:	51                   	push   %ecx
f0104573:	52                   	push   %edx
f0104574:	89 da                	mov    %ebx,%edx
f0104576:	89 f0                	mov    %esi,%eax
f0104578:	e8 5a fb ff ff       	call   f01040d7 <printnum>
			break;
f010457d:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
f0104580:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0104583:	e9 55 fc ff ff       	jmp    f01041dd <vprintfmt+0x1e>
	if (lflag >= 2)
f0104588:	83 f9 01             	cmp    $0x1,%ecx
f010458b:	7f 1b                	jg     f01045a8 <vprintfmt+0x3e9>
	else if (lflag)
f010458d:	85 c9                	test   %ecx,%ecx
f010458f:	74 2c                	je     f01045bd <vprintfmt+0x3fe>
		return va_arg(*ap, unsigned long);
f0104591:	8b 45 14             	mov    0x14(%ebp),%eax
f0104594:	8b 10                	mov    (%eax),%edx
f0104596:	b9 00 00 00 00       	mov    $0x0,%ecx
f010459b:	8d 40 04             	lea    0x4(%eax),%eax
f010459e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01045a1:	b8 10 00 00 00       	mov    $0x10,%eax
f01045a6:	eb be                	jmp    f0104566 <vprintfmt+0x3a7>
		return va_arg(*ap, unsigned long long);
f01045a8:	8b 45 14             	mov    0x14(%ebp),%eax
f01045ab:	8b 10                	mov    (%eax),%edx
f01045ad:	8b 48 04             	mov    0x4(%eax),%ecx
f01045b0:	8d 40 08             	lea    0x8(%eax),%eax
f01045b3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01045b6:	b8 10 00 00 00       	mov    $0x10,%eax
f01045bb:	eb a9                	jmp    f0104566 <vprintfmt+0x3a7>
		return va_arg(*ap, unsigned int);
f01045bd:	8b 45 14             	mov    0x14(%ebp),%eax
f01045c0:	8b 10                	mov    (%eax),%edx
f01045c2:	b9 00 00 00 00       	mov    $0x0,%ecx
f01045c7:	8d 40 04             	lea    0x4(%eax),%eax
f01045ca:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01045cd:	b8 10 00 00 00       	mov    $0x10,%eax
f01045d2:	eb 92                	jmp    f0104566 <vprintfmt+0x3a7>
			putch(ch, putdat);
f01045d4:	83 ec 08             	sub    $0x8,%esp
f01045d7:	53                   	push   %ebx
f01045d8:	6a 25                	push   $0x25
f01045da:	ff d6                	call   *%esi
			break;
f01045dc:	83 c4 10             	add    $0x10,%esp
f01045df:	eb 9f                	jmp    f0104580 <vprintfmt+0x3c1>
			putch('%', putdat);
f01045e1:	83 ec 08             	sub    $0x8,%esp
f01045e4:	53                   	push   %ebx
f01045e5:	6a 25                	push   $0x25
f01045e7:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f01045e9:	83 c4 10             	add    $0x10,%esp
f01045ec:	89 f8                	mov    %edi,%eax
f01045ee:	eb 03                	jmp    f01045f3 <vprintfmt+0x434>
f01045f0:	83 e8 01             	sub    $0x1,%eax
f01045f3:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f01045f7:	75 f7                	jne    f01045f0 <vprintfmt+0x431>
f01045f9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01045fc:	eb 82                	jmp    f0104580 <vprintfmt+0x3c1>

f01045fe <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01045fe:	55                   	push   %ebp
f01045ff:	89 e5                	mov    %esp,%ebp
f0104601:	83 ec 18             	sub    $0x18,%esp
f0104604:	8b 45 08             	mov    0x8(%ebp),%eax
f0104607:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f010460a:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010460d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0104611:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0104614:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010461b:	85 c0                	test   %eax,%eax
f010461d:	74 26                	je     f0104645 <vsnprintf+0x47>
f010461f:	85 d2                	test   %edx,%edx
f0104621:	7e 22                	jle    f0104645 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0104623:	ff 75 14             	pushl  0x14(%ebp)
f0104626:	ff 75 10             	pushl  0x10(%ebp)
f0104629:	8d 45 ec             	lea    -0x14(%ebp),%eax
f010462c:	50                   	push   %eax
f010462d:	68 85 41 10 f0       	push   $0xf0104185
f0104632:	e8 88 fb ff ff       	call   f01041bf <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0104637:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010463a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010463d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104640:	83 c4 10             	add    $0x10,%esp
}
f0104643:	c9                   	leave  
f0104644:	c3                   	ret    
		return -E_INVAL;
f0104645:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010464a:	eb f7                	jmp    f0104643 <vsnprintf+0x45>

f010464c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f010464c:	55                   	push   %ebp
f010464d:	89 e5                	mov    %esp,%ebp
f010464f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0104652:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0104655:	50                   	push   %eax
f0104656:	ff 75 10             	pushl  0x10(%ebp)
f0104659:	ff 75 0c             	pushl  0xc(%ebp)
f010465c:	ff 75 08             	pushl  0x8(%ebp)
f010465f:	e8 9a ff ff ff       	call   f01045fe <vsnprintf>
	va_end(ap);

	return rc;
}
f0104664:	c9                   	leave  
f0104665:	c3                   	ret    

f0104666 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0104666:	55                   	push   %ebp
f0104667:	89 e5                	mov    %esp,%ebp
f0104669:	57                   	push   %edi
f010466a:	56                   	push   %esi
f010466b:	53                   	push   %ebx
f010466c:	83 ec 0c             	sub    $0xc,%esp
f010466f:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0104672:	85 c0                	test   %eax,%eax
f0104674:	74 11                	je     f0104687 <readline+0x21>
		cprintf("%s", prompt);
f0104676:	83 ec 08             	sub    $0x8,%esp
f0104679:	50                   	push   %eax
f010467a:	68 dc 64 10 f0       	push   $0xf01064dc
f010467f:	e8 4e f1 ff ff       	call   f01037d2 <cprintf>
f0104684:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0104687:	83 ec 0c             	sub    $0xc,%esp
f010468a:	6a 00                	push   $0x0
f010468c:	e8 26 c1 ff ff       	call   f01007b7 <iscons>
f0104691:	89 c7                	mov    %eax,%edi
f0104693:	83 c4 10             	add    $0x10,%esp
	i = 0;
f0104696:	be 00 00 00 00       	mov    $0x0,%esi
f010469b:	eb 4b                	jmp    f01046e8 <readline+0x82>
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
f010469d:	83 ec 08             	sub    $0x8,%esp
f01046a0:	50                   	push   %eax
f01046a1:	68 24 6f 10 f0       	push   $0xf0106f24
f01046a6:	e8 27 f1 ff ff       	call   f01037d2 <cprintf>
			return NULL;
f01046ab:	83 c4 10             	add    $0x10,%esp
f01046ae:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f01046b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01046b6:	5b                   	pop    %ebx
f01046b7:	5e                   	pop    %esi
f01046b8:	5f                   	pop    %edi
f01046b9:	5d                   	pop    %ebp
f01046ba:	c3                   	ret    
			if (echoing)
f01046bb:	85 ff                	test   %edi,%edi
f01046bd:	75 05                	jne    f01046c4 <readline+0x5e>
			i--;
f01046bf:	83 ee 01             	sub    $0x1,%esi
f01046c2:	eb 24                	jmp    f01046e8 <readline+0x82>
				cputchar('\b');
f01046c4:	83 ec 0c             	sub    $0xc,%esp
f01046c7:	6a 08                	push   $0x8
f01046c9:	e8 c8 c0 ff ff       	call   f0100796 <cputchar>
f01046ce:	83 c4 10             	add    $0x10,%esp
f01046d1:	eb ec                	jmp    f01046bf <readline+0x59>
				cputchar(c);
f01046d3:	83 ec 0c             	sub    $0xc,%esp
f01046d6:	53                   	push   %ebx
f01046d7:	e8 ba c0 ff ff       	call   f0100796 <cputchar>
f01046dc:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f01046df:	88 9e 00 1b 23 f0    	mov    %bl,-0xfdce500(%esi)
f01046e5:	8d 76 01             	lea    0x1(%esi),%esi
		c = getchar();
f01046e8:	e8 b9 c0 ff ff       	call   f01007a6 <getchar>
f01046ed:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01046ef:	85 c0                	test   %eax,%eax
f01046f1:	78 aa                	js     f010469d <readline+0x37>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01046f3:	83 f8 08             	cmp    $0x8,%eax
f01046f6:	0f 94 c2             	sete   %dl
f01046f9:	83 f8 7f             	cmp    $0x7f,%eax
f01046fc:	0f 94 c0             	sete   %al
f01046ff:	08 c2                	or     %al,%dl
f0104701:	74 04                	je     f0104707 <readline+0xa1>
f0104703:	85 f6                	test   %esi,%esi
f0104705:	7f b4                	jg     f01046bb <readline+0x55>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0104707:	83 fb 1f             	cmp    $0x1f,%ebx
f010470a:	7e 0e                	jle    f010471a <readline+0xb4>
f010470c:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0104712:	7f 06                	jg     f010471a <readline+0xb4>
			if (echoing)
f0104714:	85 ff                	test   %edi,%edi
f0104716:	74 c7                	je     f01046df <readline+0x79>
f0104718:	eb b9                	jmp    f01046d3 <readline+0x6d>
		} else if (c == '\n' || c == '\r') {
f010471a:	83 fb 0a             	cmp    $0xa,%ebx
f010471d:	74 05                	je     f0104724 <readline+0xbe>
f010471f:	83 fb 0d             	cmp    $0xd,%ebx
f0104722:	75 c4                	jne    f01046e8 <readline+0x82>
			if (echoing)
f0104724:	85 ff                	test   %edi,%edi
f0104726:	75 11                	jne    f0104739 <readline+0xd3>
			buf[i] = 0;
f0104728:	c6 86 00 1b 23 f0 00 	movb   $0x0,-0xfdce500(%esi)
			return buf;
f010472f:	b8 00 1b 23 f0       	mov    $0xf0231b00,%eax
f0104734:	e9 7a ff ff ff       	jmp    f01046b3 <readline+0x4d>
				cputchar('\n');
f0104739:	83 ec 0c             	sub    $0xc,%esp
f010473c:	6a 0a                	push   $0xa
f010473e:	e8 53 c0 ff ff       	call   f0100796 <cputchar>
f0104743:	83 c4 10             	add    $0x10,%esp
f0104746:	eb e0                	jmp    f0104728 <readline+0xc2>

f0104748 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0104748:	55                   	push   %ebp
f0104749:	89 e5                	mov    %esp,%ebp
f010474b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f010474e:	b8 00 00 00 00       	mov    $0x0,%eax
f0104753:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0104757:	74 05                	je     f010475e <strlen+0x16>
		n++;
f0104759:	83 c0 01             	add    $0x1,%eax
f010475c:	eb f5                	jmp    f0104753 <strlen+0xb>
	return n;
}
f010475e:	5d                   	pop    %ebp
f010475f:	c3                   	ret    

f0104760 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0104760:	55                   	push   %ebp
f0104761:	89 e5                	mov    %esp,%ebp
f0104763:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104766:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0104769:	ba 00 00 00 00       	mov    $0x0,%edx
f010476e:	39 c2                	cmp    %eax,%edx
f0104770:	74 0d                	je     f010477f <strnlen+0x1f>
f0104772:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f0104776:	74 05                	je     f010477d <strnlen+0x1d>
		n++;
f0104778:	83 c2 01             	add    $0x1,%edx
f010477b:	eb f1                	jmp    f010476e <strnlen+0xe>
f010477d:	89 d0                	mov    %edx,%eax
	return n;
}
f010477f:	5d                   	pop    %ebp
f0104780:	c3                   	ret    

f0104781 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0104781:	55                   	push   %ebp
f0104782:	89 e5                	mov    %esp,%ebp
f0104784:	53                   	push   %ebx
f0104785:	8b 45 08             	mov    0x8(%ebp),%eax
f0104788:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f010478b:	ba 00 00 00 00       	mov    $0x0,%edx
f0104790:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f0104794:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0104797:	83 c2 01             	add    $0x1,%edx
f010479a:	84 c9                	test   %cl,%cl
f010479c:	75 f2                	jne    f0104790 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f010479e:	5b                   	pop    %ebx
f010479f:	5d                   	pop    %ebp
f01047a0:	c3                   	ret    

f01047a1 <strcat>:

char *
strcat(char *dst, const char *src)
{
f01047a1:	55                   	push   %ebp
f01047a2:	89 e5                	mov    %esp,%ebp
f01047a4:	53                   	push   %ebx
f01047a5:	83 ec 10             	sub    $0x10,%esp
f01047a8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01047ab:	53                   	push   %ebx
f01047ac:	e8 97 ff ff ff       	call   f0104748 <strlen>
f01047b1:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
f01047b4:	ff 75 0c             	pushl  0xc(%ebp)
f01047b7:	01 d8                	add    %ebx,%eax
f01047b9:	50                   	push   %eax
f01047ba:	e8 c2 ff ff ff       	call   f0104781 <strcpy>
	return dst;
}
f01047bf:	89 d8                	mov    %ebx,%eax
f01047c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01047c4:	c9                   	leave  
f01047c5:	c3                   	ret    

f01047c6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01047c6:	55                   	push   %ebp
f01047c7:	89 e5                	mov    %esp,%ebp
f01047c9:	56                   	push   %esi
f01047ca:	53                   	push   %ebx
f01047cb:	8b 45 08             	mov    0x8(%ebp),%eax
f01047ce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01047d1:	89 c6                	mov    %eax,%esi
f01047d3:	03 75 10             	add    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01047d6:	89 c2                	mov    %eax,%edx
f01047d8:	39 f2                	cmp    %esi,%edx
f01047da:	74 11                	je     f01047ed <strncpy+0x27>
		*dst++ = *src;
f01047dc:	83 c2 01             	add    $0x1,%edx
f01047df:	0f b6 19             	movzbl (%ecx),%ebx
f01047e2:	88 5a ff             	mov    %bl,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01047e5:	80 fb 01             	cmp    $0x1,%bl
f01047e8:	83 d9 ff             	sbb    $0xffffffff,%ecx
f01047eb:	eb eb                	jmp    f01047d8 <strncpy+0x12>
	}
	return ret;
}
f01047ed:	5b                   	pop    %ebx
f01047ee:	5e                   	pop    %esi
f01047ef:	5d                   	pop    %ebp
f01047f0:	c3                   	ret    

f01047f1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01047f1:	55                   	push   %ebp
f01047f2:	89 e5                	mov    %esp,%ebp
f01047f4:	56                   	push   %esi
f01047f5:	53                   	push   %ebx
f01047f6:	8b 75 08             	mov    0x8(%ebp),%esi
f01047f9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01047fc:	8b 55 10             	mov    0x10(%ebp),%edx
f01047ff:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0104801:	85 d2                	test   %edx,%edx
f0104803:	74 21                	je     f0104826 <strlcpy+0x35>
f0104805:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0104809:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
f010480b:	39 c2                	cmp    %eax,%edx
f010480d:	74 14                	je     f0104823 <strlcpy+0x32>
f010480f:	0f b6 19             	movzbl (%ecx),%ebx
f0104812:	84 db                	test   %bl,%bl
f0104814:	74 0b                	je     f0104821 <strlcpy+0x30>
			*dst++ = *src++;
f0104816:	83 c1 01             	add    $0x1,%ecx
f0104819:	83 c2 01             	add    $0x1,%edx
f010481c:	88 5a ff             	mov    %bl,-0x1(%edx)
f010481f:	eb ea                	jmp    f010480b <strlcpy+0x1a>
f0104821:	89 d0                	mov    %edx,%eax
		*dst = '\0';
f0104823:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0104826:	29 f0                	sub    %esi,%eax
}
f0104828:	5b                   	pop    %ebx
f0104829:	5e                   	pop    %esi
f010482a:	5d                   	pop    %ebp
f010482b:	c3                   	ret    

f010482c <strcmp>:

int
strcmp(const char *p, const char *q)
{
f010482c:	55                   	push   %ebp
f010482d:	89 e5                	mov    %esp,%ebp
f010482f:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104832:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0104835:	0f b6 01             	movzbl (%ecx),%eax
f0104838:	84 c0                	test   %al,%al
f010483a:	74 0c                	je     f0104848 <strcmp+0x1c>
f010483c:	3a 02                	cmp    (%edx),%al
f010483e:	75 08                	jne    f0104848 <strcmp+0x1c>
		p++, q++;
f0104840:	83 c1 01             	add    $0x1,%ecx
f0104843:	83 c2 01             	add    $0x1,%edx
f0104846:	eb ed                	jmp    f0104835 <strcmp+0x9>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0104848:	0f b6 c0             	movzbl %al,%eax
f010484b:	0f b6 12             	movzbl (%edx),%edx
f010484e:	29 d0                	sub    %edx,%eax
}
f0104850:	5d                   	pop    %ebp
f0104851:	c3                   	ret    

f0104852 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0104852:	55                   	push   %ebp
f0104853:	89 e5                	mov    %esp,%ebp
f0104855:	53                   	push   %ebx
f0104856:	8b 45 08             	mov    0x8(%ebp),%eax
f0104859:	8b 55 0c             	mov    0xc(%ebp),%edx
f010485c:	89 c3                	mov    %eax,%ebx
f010485e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0104861:	eb 06                	jmp    f0104869 <strncmp+0x17>
		n--, p++, q++;
f0104863:	83 c0 01             	add    $0x1,%eax
f0104866:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f0104869:	39 d8                	cmp    %ebx,%eax
f010486b:	74 16                	je     f0104883 <strncmp+0x31>
f010486d:	0f b6 08             	movzbl (%eax),%ecx
f0104870:	84 c9                	test   %cl,%cl
f0104872:	74 04                	je     f0104878 <strncmp+0x26>
f0104874:	3a 0a                	cmp    (%edx),%cl
f0104876:	74 eb                	je     f0104863 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0104878:	0f b6 00             	movzbl (%eax),%eax
f010487b:	0f b6 12             	movzbl (%edx),%edx
f010487e:	29 d0                	sub    %edx,%eax
}
f0104880:	5b                   	pop    %ebx
f0104881:	5d                   	pop    %ebp
f0104882:	c3                   	ret    
		return 0;
f0104883:	b8 00 00 00 00       	mov    $0x0,%eax
f0104888:	eb f6                	jmp    f0104880 <strncmp+0x2e>

f010488a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010488a:	55                   	push   %ebp
f010488b:	89 e5                	mov    %esp,%ebp
f010488d:	8b 45 08             	mov    0x8(%ebp),%eax
f0104890:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0104894:	0f b6 10             	movzbl (%eax),%edx
f0104897:	84 d2                	test   %dl,%dl
f0104899:	74 09                	je     f01048a4 <strchr+0x1a>
		if (*s == c)
f010489b:	38 ca                	cmp    %cl,%dl
f010489d:	74 0a                	je     f01048a9 <strchr+0x1f>
	for (; *s; s++)
f010489f:	83 c0 01             	add    $0x1,%eax
f01048a2:	eb f0                	jmp    f0104894 <strchr+0xa>
			return (char *) s;
	return 0;
f01048a4:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01048a9:	5d                   	pop    %ebp
f01048aa:	c3                   	ret    

f01048ab <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01048ab:	55                   	push   %ebp
f01048ac:	89 e5                	mov    %esp,%ebp
f01048ae:	8b 45 08             	mov    0x8(%ebp),%eax
f01048b1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01048b5:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f01048b8:	38 ca                	cmp    %cl,%dl
f01048ba:	74 09                	je     f01048c5 <strfind+0x1a>
f01048bc:	84 d2                	test   %dl,%dl
f01048be:	74 05                	je     f01048c5 <strfind+0x1a>
	for (; *s; s++)
f01048c0:	83 c0 01             	add    $0x1,%eax
f01048c3:	eb f0                	jmp    f01048b5 <strfind+0xa>
			break;
	return (char *) s;
}
f01048c5:	5d                   	pop    %ebp
f01048c6:	c3                   	ret    

f01048c7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01048c7:	55                   	push   %ebp
f01048c8:	89 e5                	mov    %esp,%ebp
f01048ca:	57                   	push   %edi
f01048cb:	56                   	push   %esi
f01048cc:	53                   	push   %ebx
f01048cd:	8b 7d 08             	mov    0x8(%ebp),%edi
f01048d0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01048d3:	85 c9                	test   %ecx,%ecx
f01048d5:	74 31                	je     f0104908 <memset+0x41>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01048d7:	89 f8                	mov    %edi,%eax
f01048d9:	09 c8                	or     %ecx,%eax
f01048db:	a8 03                	test   $0x3,%al
f01048dd:	75 23                	jne    f0104902 <memset+0x3b>
		c &= 0xFF;
f01048df:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01048e3:	89 d3                	mov    %edx,%ebx
f01048e5:	c1 e3 08             	shl    $0x8,%ebx
f01048e8:	89 d0                	mov    %edx,%eax
f01048ea:	c1 e0 18             	shl    $0x18,%eax
f01048ed:	89 d6                	mov    %edx,%esi
f01048ef:	c1 e6 10             	shl    $0x10,%esi
f01048f2:	09 f0                	or     %esi,%eax
f01048f4:	09 c2                	or     %eax,%edx
f01048f6:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f01048f8:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f01048fb:	89 d0                	mov    %edx,%eax
f01048fd:	fc                   	cld    
f01048fe:	f3 ab                	rep stos %eax,%es:(%edi)
f0104900:	eb 06                	jmp    f0104908 <memset+0x41>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0104902:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104905:	fc                   	cld    
f0104906:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0104908:	89 f8                	mov    %edi,%eax
f010490a:	5b                   	pop    %ebx
f010490b:	5e                   	pop    %esi
f010490c:	5f                   	pop    %edi
f010490d:	5d                   	pop    %ebp
f010490e:	c3                   	ret    

f010490f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f010490f:	55                   	push   %ebp
f0104910:	89 e5                	mov    %esp,%ebp
f0104912:	57                   	push   %edi
f0104913:	56                   	push   %esi
f0104914:	8b 45 08             	mov    0x8(%ebp),%eax
f0104917:	8b 75 0c             	mov    0xc(%ebp),%esi
f010491a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f010491d:	39 c6                	cmp    %eax,%esi
f010491f:	73 32                	jae    f0104953 <memmove+0x44>
f0104921:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0104924:	39 c2                	cmp    %eax,%edx
f0104926:	76 2b                	jbe    f0104953 <memmove+0x44>
		s += n;
		d += n;
f0104928:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010492b:	89 fe                	mov    %edi,%esi
f010492d:	09 ce                	or     %ecx,%esi
f010492f:	09 d6                	or     %edx,%esi
f0104931:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0104937:	75 0e                	jne    f0104947 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0104939:	83 ef 04             	sub    $0x4,%edi
f010493c:	8d 72 fc             	lea    -0x4(%edx),%esi
f010493f:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f0104942:	fd                   	std    
f0104943:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104945:	eb 09                	jmp    f0104950 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0104947:	83 ef 01             	sub    $0x1,%edi
f010494a:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f010494d:	fd                   	std    
f010494e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0104950:	fc                   	cld    
f0104951:	eb 1a                	jmp    f010496d <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104953:	89 c2                	mov    %eax,%edx
f0104955:	09 ca                	or     %ecx,%edx
f0104957:	09 f2                	or     %esi,%edx
f0104959:	f6 c2 03             	test   $0x3,%dl
f010495c:	75 0a                	jne    f0104968 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f010495e:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f0104961:	89 c7                	mov    %eax,%edi
f0104963:	fc                   	cld    
f0104964:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104966:	eb 05                	jmp    f010496d <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
f0104968:	89 c7                	mov    %eax,%edi
f010496a:	fc                   	cld    
f010496b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f010496d:	5e                   	pop    %esi
f010496e:	5f                   	pop    %edi
f010496f:	5d                   	pop    %ebp
f0104970:	c3                   	ret    

f0104971 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0104971:	55                   	push   %ebp
f0104972:	89 e5                	mov    %esp,%ebp
f0104974:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0104977:	ff 75 10             	pushl  0x10(%ebp)
f010497a:	ff 75 0c             	pushl  0xc(%ebp)
f010497d:	ff 75 08             	pushl  0x8(%ebp)
f0104980:	e8 8a ff ff ff       	call   f010490f <memmove>
}
f0104985:	c9                   	leave  
f0104986:	c3                   	ret    

f0104987 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0104987:	55                   	push   %ebp
f0104988:	89 e5                	mov    %esp,%ebp
f010498a:	56                   	push   %esi
f010498b:	53                   	push   %ebx
f010498c:	8b 45 08             	mov    0x8(%ebp),%eax
f010498f:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104992:	89 c6                	mov    %eax,%esi
f0104994:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0104997:	39 f0                	cmp    %esi,%eax
f0104999:	74 1c                	je     f01049b7 <memcmp+0x30>
		if (*s1 != *s2)
f010499b:	0f b6 08             	movzbl (%eax),%ecx
f010499e:	0f b6 1a             	movzbl (%edx),%ebx
f01049a1:	38 d9                	cmp    %bl,%cl
f01049a3:	75 08                	jne    f01049ad <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f01049a5:	83 c0 01             	add    $0x1,%eax
f01049a8:	83 c2 01             	add    $0x1,%edx
f01049ab:	eb ea                	jmp    f0104997 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
f01049ad:	0f b6 c1             	movzbl %cl,%eax
f01049b0:	0f b6 db             	movzbl %bl,%ebx
f01049b3:	29 d8                	sub    %ebx,%eax
f01049b5:	eb 05                	jmp    f01049bc <memcmp+0x35>
	}

	return 0;
f01049b7:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01049bc:	5b                   	pop    %ebx
f01049bd:	5e                   	pop    %esi
f01049be:	5d                   	pop    %ebp
f01049bf:	c3                   	ret    

f01049c0 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01049c0:	55                   	push   %ebp
f01049c1:	89 e5                	mov    %esp,%ebp
f01049c3:	8b 45 08             	mov    0x8(%ebp),%eax
f01049c6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f01049c9:	89 c2                	mov    %eax,%edx
f01049cb:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f01049ce:	39 d0                	cmp    %edx,%eax
f01049d0:	73 09                	jae    f01049db <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
f01049d2:	38 08                	cmp    %cl,(%eax)
f01049d4:	74 05                	je     f01049db <memfind+0x1b>
	for (; s < ends; s++)
f01049d6:	83 c0 01             	add    $0x1,%eax
f01049d9:	eb f3                	jmp    f01049ce <memfind+0xe>
			break;
	return (void *) s;
}
f01049db:	5d                   	pop    %ebp
f01049dc:	c3                   	ret    

f01049dd <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01049dd:	55                   	push   %ebp
f01049de:	89 e5                	mov    %esp,%ebp
f01049e0:	57                   	push   %edi
f01049e1:	56                   	push   %esi
f01049e2:	53                   	push   %ebx
f01049e3:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01049e6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01049e9:	eb 03                	jmp    f01049ee <strtol+0x11>
		s++;
f01049eb:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
f01049ee:	0f b6 01             	movzbl (%ecx),%eax
f01049f1:	3c 20                	cmp    $0x20,%al
f01049f3:	74 f6                	je     f01049eb <strtol+0xe>
f01049f5:	3c 09                	cmp    $0x9,%al
f01049f7:	74 f2                	je     f01049eb <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f01049f9:	3c 2b                	cmp    $0x2b,%al
f01049fb:	74 2a                	je     f0104a27 <strtol+0x4a>
	int neg = 0;
f01049fd:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f0104a02:	3c 2d                	cmp    $0x2d,%al
f0104a04:	74 2b                	je     f0104a31 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0104a06:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0104a0c:	75 0f                	jne    f0104a1d <strtol+0x40>
f0104a0e:	80 39 30             	cmpb   $0x30,(%ecx)
f0104a11:	74 28                	je     f0104a3b <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0104a13:	85 db                	test   %ebx,%ebx
f0104a15:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104a1a:	0f 44 d8             	cmove  %eax,%ebx
f0104a1d:	b8 00 00 00 00       	mov    $0x0,%eax
f0104a22:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0104a25:	eb 50                	jmp    f0104a77 <strtol+0x9a>
		s++;
f0104a27:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
f0104a2a:	bf 00 00 00 00       	mov    $0x0,%edi
f0104a2f:	eb d5                	jmp    f0104a06 <strtol+0x29>
		s++, neg = 1;
f0104a31:	83 c1 01             	add    $0x1,%ecx
f0104a34:	bf 01 00 00 00       	mov    $0x1,%edi
f0104a39:	eb cb                	jmp    f0104a06 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0104a3b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0104a3f:	74 0e                	je     f0104a4f <strtol+0x72>
	else if (base == 0 && s[0] == '0')
f0104a41:	85 db                	test   %ebx,%ebx
f0104a43:	75 d8                	jne    f0104a1d <strtol+0x40>
		s++, base = 8;
f0104a45:	83 c1 01             	add    $0x1,%ecx
f0104a48:	bb 08 00 00 00       	mov    $0x8,%ebx
f0104a4d:	eb ce                	jmp    f0104a1d <strtol+0x40>
		s += 2, base = 16;
f0104a4f:	83 c1 02             	add    $0x2,%ecx
f0104a52:	bb 10 00 00 00       	mov    $0x10,%ebx
f0104a57:	eb c4                	jmp    f0104a1d <strtol+0x40>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
f0104a59:	8d 72 9f             	lea    -0x61(%edx),%esi
f0104a5c:	89 f3                	mov    %esi,%ebx
f0104a5e:	80 fb 19             	cmp    $0x19,%bl
f0104a61:	77 29                	ja     f0104a8c <strtol+0xaf>
			dig = *s - 'a' + 10;
f0104a63:	0f be d2             	movsbl %dl,%edx
f0104a66:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0104a69:	3b 55 10             	cmp    0x10(%ebp),%edx
f0104a6c:	7d 30                	jge    f0104a9e <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
f0104a6e:	83 c1 01             	add    $0x1,%ecx
f0104a71:	0f af 45 10          	imul   0x10(%ebp),%eax
f0104a75:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f0104a77:	0f b6 11             	movzbl (%ecx),%edx
f0104a7a:	8d 72 d0             	lea    -0x30(%edx),%esi
f0104a7d:	89 f3                	mov    %esi,%ebx
f0104a7f:	80 fb 09             	cmp    $0x9,%bl
f0104a82:	77 d5                	ja     f0104a59 <strtol+0x7c>
			dig = *s - '0';
f0104a84:	0f be d2             	movsbl %dl,%edx
f0104a87:	83 ea 30             	sub    $0x30,%edx
f0104a8a:	eb dd                	jmp    f0104a69 <strtol+0x8c>
		else if (*s >= 'A' && *s <= 'Z')
f0104a8c:	8d 72 bf             	lea    -0x41(%edx),%esi
f0104a8f:	89 f3                	mov    %esi,%ebx
f0104a91:	80 fb 19             	cmp    $0x19,%bl
f0104a94:	77 08                	ja     f0104a9e <strtol+0xc1>
			dig = *s - 'A' + 10;
f0104a96:	0f be d2             	movsbl %dl,%edx
f0104a99:	83 ea 37             	sub    $0x37,%edx
f0104a9c:	eb cb                	jmp    f0104a69 <strtol+0x8c>
		// we don't properly detect overflow!
	}

	if (endptr)
f0104a9e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0104aa2:	74 05                	je     f0104aa9 <strtol+0xcc>
		*endptr = (char *) s;
f0104aa4:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104aa7:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f0104aa9:	89 c2                	mov    %eax,%edx
f0104aab:	f7 da                	neg    %edx
f0104aad:	85 ff                	test   %edi,%edi
f0104aaf:	0f 45 c2             	cmovne %edx,%eax
}
f0104ab2:	5b                   	pop    %ebx
f0104ab3:	5e                   	pop    %esi
f0104ab4:	5f                   	pop    %edi
f0104ab5:	5d                   	pop    %ebp
f0104ab6:	c3                   	ret    
f0104ab7:	90                   	nop

f0104ab8 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0104ab8:	fa                   	cli    

	xorw    %ax, %ax
f0104ab9:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f0104abb:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0104abd:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0104abf:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0104ac1:	0f 01 16             	lgdtl  (%esi)
f0104ac4:	74 70                	je     f0104b36 <mpsearch1+0x3>
	movl    %cr0, %eax
f0104ac6:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0104ac9:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0104acd:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0104ad0:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0104ad6:	08 00                	or     %al,(%eax)

f0104ad8 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0104ad8:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0104adc:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0104ade:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0104ae0:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0104ae2:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0104ae6:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0104ae8:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0104aea:	b8 00 f0 11 00       	mov    $0x11f000,%eax
	movl    %eax, %cr3
f0104aef:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0104af2:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0104af5:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0104afa:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0104afd:	8b 25 04 1f 23 f0    	mov    0xf0231f04,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0104b03:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0104b08:	b8 f5 01 10 f0       	mov    $0xf01001f5,%eax
	call    *%eax
f0104b0d:	ff d0                	call   *%eax

f0104b0f <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0104b0f:	eb fe                	jmp    f0104b0f <spin>
f0104b11:	8d 76 00             	lea    0x0(%esi),%esi

f0104b14 <gdt>:
	...
f0104b1c:	ff                   	(bad)  
f0104b1d:	ff 00                	incl   (%eax)
f0104b1f:	00 00                	add    %al,(%eax)
f0104b21:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0104b28:	00                   	.byte 0x0
f0104b29:	92                   	xchg   %eax,%edx
f0104b2a:	cf                   	iret   
	...

f0104b2c <gdtdesc>:
f0104b2c:	17                   	pop    %ss
f0104b2d:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0104b32 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0104b32:	90                   	nop

f0104b33 <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0104b33:	55                   	push   %ebp
f0104b34:	89 e5                	mov    %esp,%ebp
f0104b36:	57                   	push   %edi
f0104b37:	56                   	push   %esi
f0104b38:	53                   	push   %ebx
f0104b39:	83 ec 0c             	sub    $0xc,%esp
	if (PGNUM(pa) >= npages)
f0104b3c:	8b 0d 08 1f 23 f0    	mov    0xf0231f08,%ecx
f0104b42:	89 c3                	mov    %eax,%ebx
f0104b44:	c1 eb 0c             	shr    $0xc,%ebx
f0104b47:	39 cb                	cmp    %ecx,%ebx
f0104b49:	73 1a                	jae    f0104b65 <mpsearch1+0x32>
	return (void *)(pa + KERNBASE);
f0104b4b:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0104b51:	8d 3c 02             	lea    (%edx,%eax,1),%edi
	if (PGNUM(pa) >= npages)
f0104b54:	89 f8                	mov    %edi,%eax
f0104b56:	c1 e8 0c             	shr    $0xc,%eax
f0104b59:	39 c8                	cmp    %ecx,%eax
f0104b5b:	73 1a                	jae    f0104b77 <mpsearch1+0x44>
	return (void *)(pa + KERNBASE);
f0104b5d:	81 ef 00 00 00 10    	sub    $0x10000000,%edi

	for (; mp < end; mp++)
f0104b63:	eb 27                	jmp    f0104b8c <mpsearch1+0x59>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0104b65:	50                   	push   %eax
f0104b66:	68 d4 55 10 f0       	push   $0xf01055d4
f0104b6b:	6a 57                	push   $0x57
f0104b6d:	68 c1 70 10 f0       	push   $0xf01070c1
f0104b72:	e8 1d b5 ff ff       	call   f0100094 <_panic>
f0104b77:	57                   	push   %edi
f0104b78:	68 d4 55 10 f0       	push   $0xf01055d4
f0104b7d:	6a 57                	push   $0x57
f0104b7f:	68 c1 70 10 f0       	push   $0xf01070c1
f0104b84:	e8 0b b5 ff ff       	call   f0100094 <_panic>
f0104b89:	83 c3 10             	add    $0x10,%ebx
f0104b8c:	39 fb                	cmp    %edi,%ebx
f0104b8e:	73 30                	jae    f0104bc0 <mpsearch1+0x8d>
f0104b90:	89 de                	mov    %ebx,%esi
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0104b92:	83 ec 04             	sub    $0x4,%esp
f0104b95:	6a 04                	push   $0x4
f0104b97:	68 d1 70 10 f0       	push   $0xf01070d1
f0104b9c:	53                   	push   %ebx
f0104b9d:	e8 e5 fd ff ff       	call   f0104987 <memcmp>
f0104ba2:	83 c4 10             	add    $0x10,%esp
f0104ba5:	85 c0                	test   %eax,%eax
f0104ba7:	75 e0                	jne    f0104b89 <mpsearch1+0x56>
f0104ba9:	89 da                	mov    %ebx,%edx
	for (i = 0; i < len; i++)
f0104bab:	83 c6 10             	add    $0x10,%esi
		sum += ((uint8_t *)addr)[i];
f0104bae:	0f b6 0a             	movzbl (%edx),%ecx
f0104bb1:	01 c8                	add    %ecx,%eax
f0104bb3:	83 c2 01             	add    $0x1,%edx
	for (i = 0; i < len; i++)
f0104bb6:	39 f2                	cmp    %esi,%edx
f0104bb8:	75 f4                	jne    f0104bae <mpsearch1+0x7b>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0104bba:	84 c0                	test   %al,%al
f0104bbc:	75 cb                	jne    f0104b89 <mpsearch1+0x56>
f0104bbe:	eb 05                	jmp    f0104bc5 <mpsearch1+0x92>
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f0104bc0:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f0104bc5:	89 d8                	mov    %ebx,%eax
f0104bc7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104bca:	5b                   	pop    %ebx
f0104bcb:	5e                   	pop    %esi
f0104bcc:	5f                   	pop    %edi
f0104bcd:	5d                   	pop    %ebp
f0104bce:	c3                   	ret    

f0104bcf <mp_init>:
	return conf;
}

void
mp_init(void)
{
f0104bcf:	55                   	push   %ebp
f0104bd0:	89 e5                	mov    %esp,%ebp
f0104bd2:	57                   	push   %edi
f0104bd3:	56                   	push   %esi
f0104bd4:	53                   	push   %ebx
f0104bd5:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0104bd8:	c7 05 c0 23 23 f0 20 	movl   $0xf0232020,0xf02323c0
f0104bdf:	20 23 f0 
	if (PGNUM(pa) >= npages)
f0104be2:	83 3d 08 1f 23 f0 00 	cmpl   $0x0,0xf0231f08
f0104be9:	0f 84 a3 00 00 00    	je     f0104c92 <mp_init+0xc3>
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0104bef:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0104bf6:	85 c0                	test   %eax,%eax
f0104bf8:	0f 84 aa 00 00 00    	je     f0104ca8 <mp_init+0xd9>
		p <<= 4;	// Translate from segment to PA
f0104bfe:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f0104c01:	ba 00 04 00 00       	mov    $0x400,%edx
f0104c06:	e8 28 ff ff ff       	call   f0104b33 <mpsearch1>
f0104c0b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104c0e:	85 c0                	test   %eax,%eax
f0104c10:	75 1a                	jne    f0104c2c <mp_init+0x5d>
	return mpsearch1(0xF0000, 0x10000);
f0104c12:	ba 00 00 01 00       	mov    $0x10000,%edx
f0104c17:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0104c1c:	e8 12 ff ff ff       	call   f0104b33 <mpsearch1>
f0104c21:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if ((mp = mpsearch()) == 0)
f0104c24:	85 c0                	test   %eax,%eax
f0104c26:	0f 84 31 02 00 00    	je     f0104e5d <mp_init+0x28e>
	if (mp->physaddr == 0 || mp->type != 0) {
f0104c2c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104c2f:	8b 58 04             	mov    0x4(%eax),%ebx
f0104c32:	85 db                	test   %ebx,%ebx
f0104c34:	0f 84 97 00 00 00    	je     f0104cd1 <mp_init+0x102>
f0104c3a:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0104c3e:	0f 85 8d 00 00 00    	jne    f0104cd1 <mp_init+0x102>
f0104c44:	89 d8                	mov    %ebx,%eax
f0104c46:	c1 e8 0c             	shr    $0xc,%eax
f0104c49:	3b 05 08 1f 23 f0    	cmp    0xf0231f08,%eax
f0104c4f:	0f 83 91 00 00 00    	jae    f0104ce6 <mp_init+0x117>
	return (void *)(pa + KERNBASE);
f0104c55:	81 eb 00 00 00 10    	sub    $0x10000000,%ebx
f0104c5b:	89 de                	mov    %ebx,%esi
	if (memcmp(conf, "PCMP", 4) != 0) {
f0104c5d:	83 ec 04             	sub    $0x4,%esp
f0104c60:	6a 04                	push   $0x4
f0104c62:	68 d6 70 10 f0       	push   $0xf01070d6
f0104c67:	53                   	push   %ebx
f0104c68:	e8 1a fd ff ff       	call   f0104987 <memcmp>
f0104c6d:	83 c4 10             	add    $0x10,%esp
f0104c70:	85 c0                	test   %eax,%eax
f0104c72:	0f 85 83 00 00 00    	jne    f0104cfb <mp_init+0x12c>
f0104c78:	0f b7 7b 04          	movzwl 0x4(%ebx),%edi
f0104c7c:	01 df                	add    %ebx,%edi
	sum = 0;
f0104c7e:	89 c2                	mov    %eax,%edx
	for (i = 0; i < len; i++)
f0104c80:	39 fb                	cmp    %edi,%ebx
f0104c82:	0f 84 88 00 00 00    	je     f0104d10 <mp_init+0x141>
		sum += ((uint8_t *)addr)[i];
f0104c88:	0f b6 0b             	movzbl (%ebx),%ecx
f0104c8b:	01 ca                	add    %ecx,%edx
f0104c8d:	83 c3 01             	add    $0x1,%ebx
f0104c90:	eb ee                	jmp    f0104c80 <mp_init+0xb1>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0104c92:	68 00 04 00 00       	push   $0x400
f0104c97:	68 d4 55 10 f0       	push   $0xf01055d4
f0104c9c:	6a 6f                	push   $0x6f
f0104c9e:	68 c1 70 10 f0       	push   $0xf01070c1
f0104ca3:	e8 ec b3 ff ff       	call   f0100094 <_panic>
		p = *(uint16_t *) (bda + 0x13) * 1024;
f0104ca8:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0104caf:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f0104cb2:	2d 00 04 00 00       	sub    $0x400,%eax
f0104cb7:	ba 00 04 00 00       	mov    $0x400,%edx
f0104cbc:	e8 72 fe ff ff       	call   f0104b33 <mpsearch1>
f0104cc1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104cc4:	85 c0                	test   %eax,%eax
f0104cc6:	0f 85 60 ff ff ff    	jne    f0104c2c <mp_init+0x5d>
f0104ccc:	e9 41 ff ff ff       	jmp    f0104c12 <mp_init+0x43>
		cprintf("SMP: Default configurations not implemented\n");
f0104cd1:	83 ec 0c             	sub    $0xc,%esp
f0104cd4:	68 34 6f 10 f0       	push   $0xf0106f34
f0104cd9:	e8 f4 ea ff ff       	call   f01037d2 <cprintf>
f0104cde:	83 c4 10             	add    $0x10,%esp
f0104ce1:	e9 77 01 00 00       	jmp    f0104e5d <mp_init+0x28e>
f0104ce6:	53                   	push   %ebx
f0104ce7:	68 d4 55 10 f0       	push   $0xf01055d4
f0104cec:	68 90 00 00 00       	push   $0x90
f0104cf1:	68 c1 70 10 f0       	push   $0xf01070c1
f0104cf6:	e8 99 b3 ff ff       	call   f0100094 <_panic>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0104cfb:	83 ec 0c             	sub    $0xc,%esp
f0104cfe:	68 64 6f 10 f0       	push   $0xf0106f64
f0104d03:	e8 ca ea ff ff       	call   f01037d2 <cprintf>
f0104d08:	83 c4 10             	add    $0x10,%esp
f0104d0b:	e9 4d 01 00 00       	jmp    f0104e5d <mp_init+0x28e>
	if (sum(conf, conf->length) != 0) {
f0104d10:	84 d2                	test   %dl,%dl
f0104d12:	75 16                	jne    f0104d2a <mp_init+0x15b>
	if (conf->version != 1 && conf->version != 4) {
f0104d14:	0f b6 56 06          	movzbl 0x6(%esi),%edx
f0104d18:	80 fa 01             	cmp    $0x1,%dl
f0104d1b:	74 05                	je     f0104d22 <mp_init+0x153>
f0104d1d:	80 fa 04             	cmp    $0x4,%dl
f0104d20:	75 1d                	jne    f0104d3f <mp_init+0x170>
f0104d22:	0f b7 4e 28          	movzwl 0x28(%esi),%ecx
f0104d26:	01 d9                	add    %ebx,%ecx
f0104d28:	eb 36                	jmp    f0104d60 <mp_init+0x191>
		cprintf("SMP: Bad MP configuration checksum\n");
f0104d2a:	83 ec 0c             	sub    $0xc,%esp
f0104d2d:	68 98 6f 10 f0       	push   $0xf0106f98
f0104d32:	e8 9b ea ff ff       	call   f01037d2 <cprintf>
f0104d37:	83 c4 10             	add    $0x10,%esp
f0104d3a:	e9 1e 01 00 00       	jmp    f0104e5d <mp_init+0x28e>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0104d3f:	83 ec 08             	sub    $0x8,%esp
f0104d42:	0f b6 d2             	movzbl %dl,%edx
f0104d45:	52                   	push   %edx
f0104d46:	68 bc 6f 10 f0       	push   $0xf0106fbc
f0104d4b:	e8 82 ea ff ff       	call   f01037d2 <cprintf>
f0104d50:	83 c4 10             	add    $0x10,%esp
f0104d53:	e9 05 01 00 00       	jmp    f0104e5d <mp_init+0x28e>
		sum += ((uint8_t *)addr)[i];
f0104d58:	0f b6 13             	movzbl (%ebx),%edx
f0104d5b:	01 d0                	add    %edx,%eax
f0104d5d:	83 c3 01             	add    $0x1,%ebx
	for (i = 0; i < len; i++)
f0104d60:	39 d9                	cmp    %ebx,%ecx
f0104d62:	75 f4                	jne    f0104d58 <mp_init+0x189>
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0104d64:	02 46 2a             	add    0x2a(%esi),%al
f0104d67:	75 1c                	jne    f0104d85 <mp_init+0x1b6>
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
f0104d69:	c7 05 00 20 23 f0 01 	movl   $0x1,0xf0232000
f0104d70:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0104d73:	8b 46 24             	mov    0x24(%esi),%eax
f0104d76:	a3 00 30 27 f0       	mov    %eax,0xf0273000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0104d7b:	8d 7e 2c             	lea    0x2c(%esi),%edi
f0104d7e:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104d83:	eb 4d                	jmp    f0104dd2 <mp_init+0x203>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0104d85:	83 ec 0c             	sub    $0xc,%esp
f0104d88:	68 dc 6f 10 f0       	push   $0xf0106fdc
f0104d8d:	e8 40 ea ff ff       	call   f01037d2 <cprintf>
f0104d92:	83 c4 10             	add    $0x10,%esp
f0104d95:	e9 c3 00 00 00       	jmp    f0104e5d <mp_init+0x28e>
		switch (*p) {
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0104d9a:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f0104d9e:	74 11                	je     f0104db1 <mp_init+0x1e2>
				bootcpu = &cpus[ncpu];
f0104da0:	6b 05 c4 23 23 f0 74 	imul   $0x74,0xf02323c4,%eax
f0104da7:	05 20 20 23 f0       	add    $0xf0232020,%eax
f0104dac:	a3 c0 23 23 f0       	mov    %eax,0xf02323c0
			if (ncpu < NCPU) {
f0104db1:	a1 c4 23 23 f0       	mov    0xf02323c4,%eax
f0104db6:	83 f8 07             	cmp    $0x7,%eax
f0104db9:	7f 2f                	jg     f0104dea <mp_init+0x21b>
				cpus[ncpu].cpu_id = ncpu;
f0104dbb:	6b d0 74             	imul   $0x74,%eax,%edx
f0104dbe:	88 82 20 20 23 f0    	mov    %al,-0xfdcdfe0(%edx)
				ncpu++;
f0104dc4:	83 c0 01             	add    $0x1,%eax
f0104dc7:	a3 c4 23 23 f0       	mov    %eax,0xf02323c4
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0104dcc:	83 c7 14             	add    $0x14,%edi
	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0104dcf:	83 c3 01             	add    $0x1,%ebx
f0104dd2:	0f b7 46 22          	movzwl 0x22(%esi),%eax
f0104dd6:	39 d8                	cmp    %ebx,%eax
f0104dd8:	76 4b                	jbe    f0104e25 <mp_init+0x256>
		switch (*p) {
f0104dda:	0f b6 07             	movzbl (%edi),%eax
f0104ddd:	84 c0                	test   %al,%al
f0104ddf:	74 b9                	je     f0104d9a <mp_init+0x1cb>
f0104de1:	3c 04                	cmp    $0x4,%al
f0104de3:	77 1c                	ja     f0104e01 <mp_init+0x232>
			continue;
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0104de5:	83 c7 08             	add    $0x8,%edi
			continue;
f0104de8:	eb e5                	jmp    f0104dcf <mp_init+0x200>
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0104dea:	83 ec 08             	sub    $0x8,%esp
f0104ded:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f0104df1:	50                   	push   %eax
f0104df2:	68 0c 70 10 f0       	push   $0xf010700c
f0104df7:	e8 d6 e9 ff ff       	call   f01037d2 <cprintf>
f0104dfc:	83 c4 10             	add    $0x10,%esp
f0104dff:	eb cb                	jmp    f0104dcc <mp_init+0x1fd>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0104e01:	83 ec 08             	sub    $0x8,%esp
		switch (*p) {
f0104e04:	0f b6 c0             	movzbl %al,%eax
			cprintf("mpinit: unknown config type %x\n", *p);
f0104e07:	50                   	push   %eax
f0104e08:	68 34 70 10 f0       	push   $0xf0107034
f0104e0d:	e8 c0 e9 ff ff       	call   f01037d2 <cprintf>
			ismp = 0;
f0104e12:	c7 05 00 20 23 f0 00 	movl   $0x0,0xf0232000
f0104e19:	00 00 00 
			i = conf->entry;
f0104e1c:	0f b7 5e 22          	movzwl 0x22(%esi),%ebx
f0104e20:	83 c4 10             	add    $0x10,%esp
f0104e23:	eb aa                	jmp    f0104dcf <mp_init+0x200>
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0104e25:	a1 c0 23 23 f0       	mov    0xf02323c0,%eax
f0104e2a:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0104e31:	83 3d 00 20 23 f0 00 	cmpl   $0x0,0xf0232000
f0104e38:	74 2b                	je     f0104e65 <mp_init+0x296>
		ncpu = 1;
		lapicaddr = 0;
		cprintf("SMP: configuration not found, SMP disabled\n");
		return;
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0104e3a:	83 ec 04             	sub    $0x4,%esp
f0104e3d:	ff 35 c4 23 23 f0    	pushl  0xf02323c4
f0104e43:	0f b6 00             	movzbl (%eax),%eax
f0104e46:	50                   	push   %eax
f0104e47:	68 db 70 10 f0       	push   $0xf01070db
f0104e4c:	e8 81 e9 ff ff       	call   f01037d2 <cprintf>

	if (mp->imcrp) {
f0104e51:	83 c4 10             	add    $0x10,%esp
f0104e54:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104e57:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0104e5b:	75 2e                	jne    f0104e8b <mp_init+0x2bc>
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f0104e5d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104e60:	5b                   	pop    %ebx
f0104e61:	5e                   	pop    %esi
f0104e62:	5f                   	pop    %edi
f0104e63:	5d                   	pop    %ebp
f0104e64:	c3                   	ret    
		ncpu = 1;
f0104e65:	c7 05 c4 23 23 f0 01 	movl   $0x1,0xf02323c4
f0104e6c:	00 00 00 
		lapicaddr = 0;
f0104e6f:	c7 05 00 30 27 f0 00 	movl   $0x0,0xf0273000
f0104e76:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0104e79:	83 ec 0c             	sub    $0xc,%esp
f0104e7c:	68 54 70 10 f0       	push   $0xf0107054
f0104e81:	e8 4c e9 ff ff       	call   f01037d2 <cprintf>
		return;
f0104e86:	83 c4 10             	add    $0x10,%esp
f0104e89:	eb d2                	jmp    f0104e5d <mp_init+0x28e>
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0104e8b:	83 ec 0c             	sub    $0xc,%esp
f0104e8e:	68 80 70 10 f0       	push   $0xf0107080
f0104e93:	e8 3a e9 ff ff       	call   f01037d2 <cprintf>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0104e98:	b8 70 00 00 00       	mov    $0x70,%eax
f0104e9d:	ba 22 00 00 00       	mov    $0x22,%edx
f0104ea2:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0104ea3:	ba 23 00 00 00       	mov    $0x23,%edx
f0104ea8:	ec                   	in     (%dx),%al
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f0104ea9:	83 c8 01             	or     $0x1,%eax
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0104eac:	ee                   	out    %al,(%dx)
f0104ead:	83 c4 10             	add    $0x10,%esp
f0104eb0:	eb ab                	jmp    f0104e5d <mp_init+0x28e>

f0104eb2 <lapicw>:
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
	lapic[index] = value;
f0104eb2:	8b 0d 04 30 27 f0    	mov    0xf0273004,%ecx
f0104eb8:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0104ebb:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0104ebd:	a1 04 30 27 f0       	mov    0xf0273004,%eax
f0104ec2:	8b 40 20             	mov    0x20(%eax),%eax
}
f0104ec5:	c3                   	ret    

f0104ec6 <cpunum>:
}

int
cpunum(void)
{
	if (lapic)
f0104ec6:	8b 15 04 30 27 f0    	mov    0xf0273004,%edx
		return lapic[ID] >> 24;
	return 0;
f0104ecc:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lapic)
f0104ed1:	85 d2                	test   %edx,%edx
f0104ed3:	74 06                	je     f0104edb <cpunum+0x15>
		return lapic[ID] >> 24;
f0104ed5:	8b 42 20             	mov    0x20(%edx),%eax
f0104ed8:	c1 e8 18             	shr    $0x18,%eax
}
f0104edb:	c3                   	ret    

f0104edc <lapic_init>:
	if (!lapicaddr)
f0104edc:	a1 00 30 27 f0       	mov    0xf0273000,%eax
f0104ee1:	85 c0                	test   %eax,%eax
f0104ee3:	75 01                	jne    f0104ee6 <lapic_init+0xa>
f0104ee5:	c3                   	ret    
{
f0104ee6:	55                   	push   %ebp
f0104ee7:	89 e5                	mov    %esp,%ebp
f0104ee9:	83 ec 10             	sub    $0x10,%esp
	lapic = mmio_map_region(lapicaddr, 4096);
f0104eec:	68 00 10 00 00       	push   $0x1000
f0104ef1:	50                   	push   %eax
f0104ef2:	e8 81 c3 ff ff       	call   f0101278 <mmio_map_region>
f0104ef7:	a3 04 30 27 f0       	mov    %eax,0xf0273004
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0104efc:	ba 27 01 00 00       	mov    $0x127,%edx
f0104f01:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0104f06:	e8 a7 ff ff ff       	call   f0104eb2 <lapicw>
	lapicw(TDCR, X1);
f0104f0b:	ba 0b 00 00 00       	mov    $0xb,%edx
f0104f10:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0104f15:	e8 98 ff ff ff       	call   f0104eb2 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0104f1a:	ba 20 00 02 00       	mov    $0x20020,%edx
f0104f1f:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0104f24:	e8 89 ff ff ff       	call   f0104eb2 <lapicw>
	lapicw(TICR, 10000000); 
f0104f29:	ba 80 96 98 00       	mov    $0x989680,%edx
f0104f2e:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0104f33:	e8 7a ff ff ff       	call   f0104eb2 <lapicw>
	if (thiscpu != bootcpu)
f0104f38:	e8 89 ff ff ff       	call   f0104ec6 <cpunum>
f0104f3d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104f40:	05 20 20 23 f0       	add    $0xf0232020,%eax
f0104f45:	83 c4 10             	add    $0x10,%esp
f0104f48:	39 05 c0 23 23 f0    	cmp    %eax,0xf02323c0
f0104f4e:	74 0f                	je     f0104f5f <lapic_init+0x83>
		lapicw(LINT0, MASKED);
f0104f50:	ba 00 00 01 00       	mov    $0x10000,%edx
f0104f55:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0104f5a:	e8 53 ff ff ff       	call   f0104eb2 <lapicw>
	lapicw(LINT1, MASKED);
f0104f5f:	ba 00 00 01 00       	mov    $0x10000,%edx
f0104f64:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0104f69:	e8 44 ff ff ff       	call   f0104eb2 <lapicw>
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0104f6e:	a1 04 30 27 f0       	mov    0xf0273004,%eax
f0104f73:	8b 40 30             	mov    0x30(%eax),%eax
f0104f76:	c1 e8 10             	shr    $0x10,%eax
f0104f79:	a8 fc                	test   $0xfc,%al
f0104f7b:	75 7c                	jne    f0104ff9 <lapic_init+0x11d>
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0104f7d:	ba 33 00 00 00       	mov    $0x33,%edx
f0104f82:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0104f87:	e8 26 ff ff ff       	call   f0104eb2 <lapicw>
	lapicw(ESR, 0);
f0104f8c:	ba 00 00 00 00       	mov    $0x0,%edx
f0104f91:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0104f96:	e8 17 ff ff ff       	call   f0104eb2 <lapicw>
	lapicw(ESR, 0);
f0104f9b:	ba 00 00 00 00       	mov    $0x0,%edx
f0104fa0:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0104fa5:	e8 08 ff ff ff       	call   f0104eb2 <lapicw>
	lapicw(EOI, 0);
f0104faa:	ba 00 00 00 00       	mov    $0x0,%edx
f0104faf:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0104fb4:	e8 f9 fe ff ff       	call   f0104eb2 <lapicw>
	lapicw(ICRHI, 0);
f0104fb9:	ba 00 00 00 00       	mov    $0x0,%edx
f0104fbe:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0104fc3:	e8 ea fe ff ff       	call   f0104eb2 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0104fc8:	ba 00 85 08 00       	mov    $0x88500,%edx
f0104fcd:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0104fd2:	e8 db fe ff ff       	call   f0104eb2 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0104fd7:	8b 15 04 30 27 f0    	mov    0xf0273004,%edx
f0104fdd:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0104fe3:	f6 c4 10             	test   $0x10,%ah
f0104fe6:	75 f5                	jne    f0104fdd <lapic_init+0x101>
	lapicw(TPR, 0);
f0104fe8:	ba 00 00 00 00       	mov    $0x0,%edx
f0104fed:	b8 20 00 00 00       	mov    $0x20,%eax
f0104ff2:	e8 bb fe ff ff       	call   f0104eb2 <lapicw>
}
f0104ff7:	c9                   	leave  
f0104ff8:	c3                   	ret    
		lapicw(PCINT, MASKED);
f0104ff9:	ba 00 00 01 00       	mov    $0x10000,%edx
f0104ffe:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0105003:	e8 aa fe ff ff       	call   f0104eb2 <lapicw>
f0105008:	e9 70 ff ff ff       	jmp    f0104f7d <lapic_init+0xa1>

f010500d <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f010500d:	83 3d 04 30 27 f0 00 	cmpl   $0x0,0xf0273004
f0105014:	74 17                	je     f010502d <lapic_eoi+0x20>
{
f0105016:	55                   	push   %ebp
f0105017:	89 e5                	mov    %esp,%ebp
f0105019:	83 ec 08             	sub    $0x8,%esp
		lapicw(EOI, 0);
f010501c:	ba 00 00 00 00       	mov    $0x0,%edx
f0105021:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105026:	e8 87 fe ff ff       	call   f0104eb2 <lapicw>
}
f010502b:	c9                   	leave  
f010502c:	c3                   	ret    
f010502d:	c3                   	ret    

f010502e <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f010502e:	55                   	push   %ebp
f010502f:	89 e5                	mov    %esp,%ebp
f0105031:	56                   	push   %esi
f0105032:	53                   	push   %ebx
f0105033:	8b 75 08             	mov    0x8(%ebp),%esi
f0105036:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105039:	b8 0f 00 00 00       	mov    $0xf,%eax
f010503e:	ba 70 00 00 00       	mov    $0x70,%edx
f0105043:	ee                   	out    %al,(%dx)
f0105044:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105049:	ba 71 00 00 00       	mov    $0x71,%edx
f010504e:	ee                   	out    %al,(%dx)
	if (PGNUM(pa) >= npages)
f010504f:	83 3d 08 1f 23 f0 00 	cmpl   $0x0,0xf0231f08
f0105056:	74 7e                	je     f01050d6 <lapic_startap+0xa8>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0105058:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f010505f:	00 00 
	wrv[1] = addr >> 4;
f0105061:	89 d8                	mov    %ebx,%eax
f0105063:	c1 e8 04             	shr    $0x4,%eax
f0105066:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f010506c:	c1 e6 18             	shl    $0x18,%esi
f010506f:	89 f2                	mov    %esi,%edx
f0105071:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105076:	e8 37 fe ff ff       	call   f0104eb2 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f010507b:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0105080:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105085:	e8 28 fe ff ff       	call   f0104eb2 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f010508a:	ba 00 85 00 00       	mov    $0x8500,%edx
f010508f:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105094:	e8 19 fe ff ff       	call   f0104eb2 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105099:	c1 eb 0c             	shr    $0xc,%ebx
f010509c:	80 cf 06             	or     $0x6,%bh
		lapicw(ICRHI, apicid << 24);
f010509f:	89 f2                	mov    %esi,%edx
f01050a1:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01050a6:	e8 07 fe ff ff       	call   f0104eb2 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01050ab:	89 da                	mov    %ebx,%edx
f01050ad:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01050b2:	e8 fb fd ff ff       	call   f0104eb2 <lapicw>
		lapicw(ICRHI, apicid << 24);
f01050b7:	89 f2                	mov    %esi,%edx
f01050b9:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01050be:	e8 ef fd ff ff       	call   f0104eb2 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01050c3:	89 da                	mov    %ebx,%edx
f01050c5:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01050ca:	e8 e3 fd ff ff       	call   f0104eb2 <lapicw>
		microdelay(200);
	}
}
f01050cf:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01050d2:	5b                   	pop    %ebx
f01050d3:	5e                   	pop    %esi
f01050d4:	5d                   	pop    %ebp
f01050d5:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01050d6:	68 67 04 00 00       	push   $0x467
f01050db:	68 d4 55 10 f0       	push   $0xf01055d4
f01050e0:	68 98 00 00 00       	push   $0x98
f01050e5:	68 f8 70 10 f0       	push   $0xf01070f8
f01050ea:	e8 a5 af ff ff       	call   f0100094 <_panic>

f01050ef <lapic_ipi>:

void
lapic_ipi(int vector)
{
f01050ef:	55                   	push   %ebp
f01050f0:	89 e5                	mov    %esp,%ebp
f01050f2:	83 ec 08             	sub    $0x8,%esp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f01050f5:	8b 55 08             	mov    0x8(%ebp),%edx
f01050f8:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f01050fe:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105103:	e8 aa fd ff ff       	call   f0104eb2 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0105108:	8b 15 04 30 27 f0    	mov    0xf0273004,%edx
f010510e:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105114:	f6 c4 10             	test   $0x10,%ah
f0105117:	75 f5                	jne    f010510e <lapic_ipi+0x1f>
		;
}
f0105119:	c9                   	leave  
f010511a:	c3                   	ret    

f010511b <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f010511b:	55                   	push   %ebp
f010511c:	89 e5                	mov    %esp,%ebp
f010511e:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0105121:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0105127:	8b 55 0c             	mov    0xc(%ebp),%edx
f010512a:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f010512d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0105134:	5d                   	pop    %ebp
f0105135:	c3                   	ret    

f0105136 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0105136:	55                   	push   %ebp
f0105137:	89 e5                	mov    %esp,%ebp
f0105139:	56                   	push   %esi
f010513a:	53                   	push   %ebx
f010513b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	return lock->locked && lock->cpu == thiscpu;
f010513e:	83 3b 00             	cmpl   $0x0,(%ebx)
f0105141:	75 12                	jne    f0105155 <spin_lock+0x1f>
	asm volatile("lock; xchgl %0, %1"
f0105143:	ba 01 00 00 00       	mov    $0x1,%edx
f0105148:	89 d0                	mov    %edx,%eax
f010514a:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f010514d:	85 c0                	test   %eax,%eax
f010514f:	74 36                	je     f0105187 <spin_lock+0x51>
		asm volatile ("pause");
f0105151:	f3 90                	pause  
f0105153:	eb f3                	jmp    f0105148 <spin_lock+0x12>
	return lock->locked && lock->cpu == thiscpu;
f0105155:	8b 73 08             	mov    0x8(%ebx),%esi
f0105158:	e8 69 fd ff ff       	call   f0104ec6 <cpunum>
f010515d:	6b c0 74             	imul   $0x74,%eax,%eax
f0105160:	05 20 20 23 f0       	add    $0xf0232020,%eax
	if (holding(lk))
f0105165:	39 c6                	cmp    %eax,%esi
f0105167:	75 da                	jne    f0105143 <spin_lock+0xd>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0105169:	8b 5b 04             	mov    0x4(%ebx),%ebx
f010516c:	e8 55 fd ff ff       	call   f0104ec6 <cpunum>
f0105171:	83 ec 0c             	sub    $0xc,%esp
f0105174:	53                   	push   %ebx
f0105175:	50                   	push   %eax
f0105176:	68 08 71 10 f0       	push   $0xf0107108
f010517b:	6a 41                	push   $0x41
f010517d:	68 6c 71 10 f0       	push   $0xf010716c
f0105182:	e8 0d af ff ff       	call   f0100094 <_panic>

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0105187:	e8 3a fd ff ff       	call   f0104ec6 <cpunum>
f010518c:	6b c0 74             	imul   $0x74,%eax,%eax
f010518f:	05 20 20 23 f0       	add    $0xf0232020,%eax
f0105194:	89 43 08             	mov    %eax,0x8(%ebx)
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0105197:	89 ea                	mov    %ebp,%edx
	for (i = 0; i < 10; i++){
f0105199:	b8 00 00 00 00       	mov    $0x0,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f010519e:	83 f8 09             	cmp    $0x9,%eax
f01051a1:	7f 16                	jg     f01051b9 <spin_lock+0x83>
f01051a3:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f01051a9:	76 0e                	jbe    f01051b9 <spin_lock+0x83>
		pcs[i] = ebp[1];          // saved %eip
f01051ab:	8b 4a 04             	mov    0x4(%edx),%ecx
f01051ae:	89 4c 83 0c          	mov    %ecx,0xc(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f01051b2:	8b 12                	mov    (%edx),%edx
	for (i = 0; i < 10; i++){
f01051b4:	83 c0 01             	add    $0x1,%eax
f01051b7:	eb e5                	jmp    f010519e <spin_lock+0x68>
	for (; i < 10; i++)
f01051b9:	83 f8 09             	cmp    $0x9,%eax
f01051bc:	7f 0d                	jg     f01051cb <spin_lock+0x95>
		pcs[i] = 0;
f01051be:	c7 44 83 0c 00 00 00 	movl   $0x0,0xc(%ebx,%eax,4)
f01051c5:	00 
	for (; i < 10; i++)
f01051c6:	83 c0 01             	add    $0x1,%eax
f01051c9:	eb ee                	jmp    f01051b9 <spin_lock+0x83>
	get_caller_pcs(lk->pcs);
#endif
}
f01051cb:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01051ce:	5b                   	pop    %ebx
f01051cf:	5e                   	pop    %esi
f01051d0:	5d                   	pop    %ebp
f01051d1:	c3                   	ret    

f01051d2 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f01051d2:	55                   	push   %ebp
f01051d3:	89 e5                	mov    %esp,%ebp
f01051d5:	57                   	push   %edi
f01051d6:	56                   	push   %esi
f01051d7:	53                   	push   %ebx
f01051d8:	83 ec 4c             	sub    $0x4c,%esp
f01051db:	8b 75 08             	mov    0x8(%ebp),%esi
	return lock->locked && lock->cpu == thiscpu;
f01051de:	83 3e 00             	cmpl   $0x0,(%esi)
f01051e1:	75 35                	jne    f0105218 <spin_unlock+0x46>
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f01051e3:	83 ec 04             	sub    $0x4,%esp
f01051e6:	6a 28                	push   $0x28
f01051e8:	8d 46 0c             	lea    0xc(%esi),%eax
f01051eb:	50                   	push   %eax
f01051ec:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f01051ef:	53                   	push   %ebx
f01051f0:	e8 1a f7 ff ff       	call   f010490f <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f01051f5:	8b 46 08             	mov    0x8(%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f01051f8:	0f b6 38             	movzbl (%eax),%edi
f01051fb:	8b 76 04             	mov    0x4(%esi),%esi
f01051fe:	e8 c3 fc ff ff       	call   f0104ec6 <cpunum>
f0105203:	57                   	push   %edi
f0105204:	56                   	push   %esi
f0105205:	50                   	push   %eax
f0105206:	68 34 71 10 f0       	push   $0xf0107134
f010520b:	e8 c2 e5 ff ff       	call   f01037d2 <cprintf>
f0105210:	83 c4 20             	add    $0x20,%esp
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0105213:	8d 7d a8             	lea    -0x58(%ebp),%edi
f0105216:	eb 4e                	jmp    f0105266 <spin_unlock+0x94>
	return lock->locked && lock->cpu == thiscpu;
f0105218:	8b 5e 08             	mov    0x8(%esi),%ebx
f010521b:	e8 a6 fc ff ff       	call   f0104ec6 <cpunum>
f0105220:	6b c0 74             	imul   $0x74,%eax,%eax
f0105223:	05 20 20 23 f0       	add    $0xf0232020,%eax
	if (!holding(lk)) {
f0105228:	39 c3                	cmp    %eax,%ebx
f010522a:	75 b7                	jne    f01051e3 <spin_unlock+0x11>
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
	}

	lk->pcs[0] = 0;
f010522c:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f0105233:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
	asm volatile("lock; xchgl %0, %1"
f010523a:	b8 00 00 00 00       	mov    $0x0,%eax
f010523f:	f0 87 06             	lock xchg %eax,(%esi)
	// respect to any other instruction which references the same memory.
	// x86 CPUs will not reorder loads/stores across locked instructions
	// (vol 3, 8.2.2). Because xchg() is implemented using asm volatile,
	// gcc will not reorder C statements across the xchg.
	xchg(&lk->locked, 0);
}
f0105242:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105245:	5b                   	pop    %ebx
f0105246:	5e                   	pop    %esi
f0105247:	5f                   	pop    %edi
f0105248:	5d                   	pop    %ebp
f0105249:	c3                   	ret    
				cprintf("  %08x\n", pcs[i]);
f010524a:	83 ec 08             	sub    $0x8,%esp
f010524d:	ff 36                	pushl  (%esi)
f010524f:	68 93 71 10 f0       	push   $0xf0107193
f0105254:	e8 79 e5 ff ff       	call   f01037d2 <cprintf>
f0105259:	83 c4 10             	add    $0x10,%esp
f010525c:	83 c3 04             	add    $0x4,%ebx
		for (i = 0; i < 10 && pcs[i]; i++) {
f010525f:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0105262:	39 c3                	cmp    %eax,%ebx
f0105264:	74 40                	je     f01052a6 <spin_unlock+0xd4>
f0105266:	89 de                	mov    %ebx,%esi
f0105268:	8b 03                	mov    (%ebx),%eax
f010526a:	85 c0                	test   %eax,%eax
f010526c:	74 38                	je     f01052a6 <spin_unlock+0xd4>
			if (debuginfo_eip(pcs[i], &info) >= 0)
f010526e:	83 ec 08             	sub    $0x8,%esp
f0105271:	57                   	push   %edi
f0105272:	50                   	push   %eax
f0105273:	e8 10 ec ff ff       	call   f0103e88 <debuginfo_eip>
f0105278:	83 c4 10             	add    $0x10,%esp
f010527b:	85 c0                	test   %eax,%eax
f010527d:	78 cb                	js     f010524a <spin_unlock+0x78>
					pcs[i] - info.eip_fn_addr);
f010527f:	8b 06                	mov    (%esi),%eax
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0105281:	83 ec 04             	sub    $0x4,%esp
f0105284:	89 c2                	mov    %eax,%edx
f0105286:	2b 55 b8             	sub    -0x48(%ebp),%edx
f0105289:	52                   	push   %edx
f010528a:	ff 75 b0             	pushl  -0x50(%ebp)
f010528d:	ff 75 b4             	pushl  -0x4c(%ebp)
f0105290:	ff 75 ac             	pushl  -0x54(%ebp)
f0105293:	ff 75 a8             	pushl  -0x58(%ebp)
f0105296:	50                   	push   %eax
f0105297:	68 7c 71 10 f0       	push   $0xf010717c
f010529c:	e8 31 e5 ff ff       	call   f01037d2 <cprintf>
f01052a1:	83 c4 20             	add    $0x20,%esp
f01052a4:	eb b6                	jmp    f010525c <spin_unlock+0x8a>
		panic("spin_unlock");
f01052a6:	83 ec 04             	sub    $0x4,%esp
f01052a9:	68 9b 71 10 f0       	push   $0xf010719b
f01052ae:	6a 67                	push   $0x67
f01052b0:	68 6c 71 10 f0       	push   $0xf010716c
f01052b5:	e8 da ad ff ff       	call   f0100094 <_panic>
f01052ba:	66 90                	xchg   %ax,%ax
f01052bc:	66 90                	xchg   %ax,%ax
f01052be:	66 90                	xchg   %ax,%ax

f01052c0 <__udivdi3>:
f01052c0:	f3 0f 1e fb          	endbr32 
f01052c4:	55                   	push   %ebp
f01052c5:	57                   	push   %edi
f01052c6:	56                   	push   %esi
f01052c7:	53                   	push   %ebx
f01052c8:	83 ec 1c             	sub    $0x1c,%esp
f01052cb:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f01052cf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f01052d3:	8b 74 24 34          	mov    0x34(%esp),%esi
f01052d7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f01052db:	85 d2                	test   %edx,%edx
f01052dd:	75 49                	jne    f0105328 <__udivdi3+0x68>
f01052df:	39 f3                	cmp    %esi,%ebx
f01052e1:	76 15                	jbe    f01052f8 <__udivdi3+0x38>
f01052e3:	31 ff                	xor    %edi,%edi
f01052e5:	89 e8                	mov    %ebp,%eax
f01052e7:	89 f2                	mov    %esi,%edx
f01052e9:	f7 f3                	div    %ebx
f01052eb:	89 fa                	mov    %edi,%edx
f01052ed:	83 c4 1c             	add    $0x1c,%esp
f01052f0:	5b                   	pop    %ebx
f01052f1:	5e                   	pop    %esi
f01052f2:	5f                   	pop    %edi
f01052f3:	5d                   	pop    %ebp
f01052f4:	c3                   	ret    
f01052f5:	8d 76 00             	lea    0x0(%esi),%esi
f01052f8:	89 d9                	mov    %ebx,%ecx
f01052fa:	85 db                	test   %ebx,%ebx
f01052fc:	75 0b                	jne    f0105309 <__udivdi3+0x49>
f01052fe:	b8 01 00 00 00       	mov    $0x1,%eax
f0105303:	31 d2                	xor    %edx,%edx
f0105305:	f7 f3                	div    %ebx
f0105307:	89 c1                	mov    %eax,%ecx
f0105309:	31 d2                	xor    %edx,%edx
f010530b:	89 f0                	mov    %esi,%eax
f010530d:	f7 f1                	div    %ecx
f010530f:	89 c6                	mov    %eax,%esi
f0105311:	89 e8                	mov    %ebp,%eax
f0105313:	89 f7                	mov    %esi,%edi
f0105315:	f7 f1                	div    %ecx
f0105317:	89 fa                	mov    %edi,%edx
f0105319:	83 c4 1c             	add    $0x1c,%esp
f010531c:	5b                   	pop    %ebx
f010531d:	5e                   	pop    %esi
f010531e:	5f                   	pop    %edi
f010531f:	5d                   	pop    %ebp
f0105320:	c3                   	ret    
f0105321:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105328:	39 f2                	cmp    %esi,%edx
f010532a:	77 1c                	ja     f0105348 <__udivdi3+0x88>
f010532c:	0f bd fa             	bsr    %edx,%edi
f010532f:	83 f7 1f             	xor    $0x1f,%edi
f0105332:	75 2c                	jne    f0105360 <__udivdi3+0xa0>
f0105334:	39 f2                	cmp    %esi,%edx
f0105336:	72 06                	jb     f010533e <__udivdi3+0x7e>
f0105338:	31 c0                	xor    %eax,%eax
f010533a:	39 eb                	cmp    %ebp,%ebx
f010533c:	77 ad                	ja     f01052eb <__udivdi3+0x2b>
f010533e:	b8 01 00 00 00       	mov    $0x1,%eax
f0105343:	eb a6                	jmp    f01052eb <__udivdi3+0x2b>
f0105345:	8d 76 00             	lea    0x0(%esi),%esi
f0105348:	31 ff                	xor    %edi,%edi
f010534a:	31 c0                	xor    %eax,%eax
f010534c:	89 fa                	mov    %edi,%edx
f010534e:	83 c4 1c             	add    $0x1c,%esp
f0105351:	5b                   	pop    %ebx
f0105352:	5e                   	pop    %esi
f0105353:	5f                   	pop    %edi
f0105354:	5d                   	pop    %ebp
f0105355:	c3                   	ret    
f0105356:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f010535d:	8d 76 00             	lea    0x0(%esi),%esi
f0105360:	89 f9                	mov    %edi,%ecx
f0105362:	b8 20 00 00 00       	mov    $0x20,%eax
f0105367:	29 f8                	sub    %edi,%eax
f0105369:	d3 e2                	shl    %cl,%edx
f010536b:	89 54 24 08          	mov    %edx,0x8(%esp)
f010536f:	89 c1                	mov    %eax,%ecx
f0105371:	89 da                	mov    %ebx,%edx
f0105373:	d3 ea                	shr    %cl,%edx
f0105375:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0105379:	09 d1                	or     %edx,%ecx
f010537b:	89 f2                	mov    %esi,%edx
f010537d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0105381:	89 f9                	mov    %edi,%ecx
f0105383:	d3 e3                	shl    %cl,%ebx
f0105385:	89 c1                	mov    %eax,%ecx
f0105387:	d3 ea                	shr    %cl,%edx
f0105389:	89 f9                	mov    %edi,%ecx
f010538b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f010538f:	89 eb                	mov    %ebp,%ebx
f0105391:	d3 e6                	shl    %cl,%esi
f0105393:	89 c1                	mov    %eax,%ecx
f0105395:	d3 eb                	shr    %cl,%ebx
f0105397:	09 de                	or     %ebx,%esi
f0105399:	89 f0                	mov    %esi,%eax
f010539b:	f7 74 24 08          	divl   0x8(%esp)
f010539f:	89 d6                	mov    %edx,%esi
f01053a1:	89 c3                	mov    %eax,%ebx
f01053a3:	f7 64 24 0c          	mull   0xc(%esp)
f01053a7:	39 d6                	cmp    %edx,%esi
f01053a9:	72 15                	jb     f01053c0 <__udivdi3+0x100>
f01053ab:	89 f9                	mov    %edi,%ecx
f01053ad:	d3 e5                	shl    %cl,%ebp
f01053af:	39 c5                	cmp    %eax,%ebp
f01053b1:	73 04                	jae    f01053b7 <__udivdi3+0xf7>
f01053b3:	39 d6                	cmp    %edx,%esi
f01053b5:	74 09                	je     f01053c0 <__udivdi3+0x100>
f01053b7:	89 d8                	mov    %ebx,%eax
f01053b9:	31 ff                	xor    %edi,%edi
f01053bb:	e9 2b ff ff ff       	jmp    f01052eb <__udivdi3+0x2b>
f01053c0:	8d 43 ff             	lea    -0x1(%ebx),%eax
f01053c3:	31 ff                	xor    %edi,%edi
f01053c5:	e9 21 ff ff ff       	jmp    f01052eb <__udivdi3+0x2b>
f01053ca:	66 90                	xchg   %ax,%ax
f01053cc:	66 90                	xchg   %ax,%ax
f01053ce:	66 90                	xchg   %ax,%ax

f01053d0 <__umoddi3>:
f01053d0:	f3 0f 1e fb          	endbr32 
f01053d4:	55                   	push   %ebp
f01053d5:	57                   	push   %edi
f01053d6:	56                   	push   %esi
f01053d7:	53                   	push   %ebx
f01053d8:	83 ec 1c             	sub    $0x1c,%esp
f01053db:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f01053df:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f01053e3:	8b 74 24 30          	mov    0x30(%esp),%esi
f01053e7:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01053eb:	89 da                	mov    %ebx,%edx
f01053ed:	85 c0                	test   %eax,%eax
f01053ef:	75 3f                	jne    f0105430 <__umoddi3+0x60>
f01053f1:	39 df                	cmp    %ebx,%edi
f01053f3:	76 13                	jbe    f0105408 <__umoddi3+0x38>
f01053f5:	89 f0                	mov    %esi,%eax
f01053f7:	f7 f7                	div    %edi
f01053f9:	89 d0                	mov    %edx,%eax
f01053fb:	31 d2                	xor    %edx,%edx
f01053fd:	83 c4 1c             	add    $0x1c,%esp
f0105400:	5b                   	pop    %ebx
f0105401:	5e                   	pop    %esi
f0105402:	5f                   	pop    %edi
f0105403:	5d                   	pop    %ebp
f0105404:	c3                   	ret    
f0105405:	8d 76 00             	lea    0x0(%esi),%esi
f0105408:	89 fd                	mov    %edi,%ebp
f010540a:	85 ff                	test   %edi,%edi
f010540c:	75 0b                	jne    f0105419 <__umoddi3+0x49>
f010540e:	b8 01 00 00 00       	mov    $0x1,%eax
f0105413:	31 d2                	xor    %edx,%edx
f0105415:	f7 f7                	div    %edi
f0105417:	89 c5                	mov    %eax,%ebp
f0105419:	89 d8                	mov    %ebx,%eax
f010541b:	31 d2                	xor    %edx,%edx
f010541d:	f7 f5                	div    %ebp
f010541f:	89 f0                	mov    %esi,%eax
f0105421:	f7 f5                	div    %ebp
f0105423:	89 d0                	mov    %edx,%eax
f0105425:	eb d4                	jmp    f01053fb <__umoddi3+0x2b>
f0105427:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f010542e:	66 90                	xchg   %ax,%ax
f0105430:	89 f1                	mov    %esi,%ecx
f0105432:	39 d8                	cmp    %ebx,%eax
f0105434:	76 0a                	jbe    f0105440 <__umoddi3+0x70>
f0105436:	89 f0                	mov    %esi,%eax
f0105438:	83 c4 1c             	add    $0x1c,%esp
f010543b:	5b                   	pop    %ebx
f010543c:	5e                   	pop    %esi
f010543d:	5f                   	pop    %edi
f010543e:	5d                   	pop    %ebp
f010543f:	c3                   	ret    
f0105440:	0f bd e8             	bsr    %eax,%ebp
f0105443:	83 f5 1f             	xor    $0x1f,%ebp
f0105446:	75 20                	jne    f0105468 <__umoddi3+0x98>
f0105448:	39 d8                	cmp    %ebx,%eax
f010544a:	0f 82 b0 00 00 00    	jb     f0105500 <__umoddi3+0x130>
f0105450:	39 f7                	cmp    %esi,%edi
f0105452:	0f 86 a8 00 00 00    	jbe    f0105500 <__umoddi3+0x130>
f0105458:	89 c8                	mov    %ecx,%eax
f010545a:	83 c4 1c             	add    $0x1c,%esp
f010545d:	5b                   	pop    %ebx
f010545e:	5e                   	pop    %esi
f010545f:	5f                   	pop    %edi
f0105460:	5d                   	pop    %ebp
f0105461:	c3                   	ret    
f0105462:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0105468:	89 e9                	mov    %ebp,%ecx
f010546a:	ba 20 00 00 00       	mov    $0x20,%edx
f010546f:	29 ea                	sub    %ebp,%edx
f0105471:	d3 e0                	shl    %cl,%eax
f0105473:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105477:	89 d1                	mov    %edx,%ecx
f0105479:	89 f8                	mov    %edi,%eax
f010547b:	d3 e8                	shr    %cl,%eax
f010547d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0105481:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105485:	8b 54 24 04          	mov    0x4(%esp),%edx
f0105489:	09 c1                	or     %eax,%ecx
f010548b:	89 d8                	mov    %ebx,%eax
f010548d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0105491:	89 e9                	mov    %ebp,%ecx
f0105493:	d3 e7                	shl    %cl,%edi
f0105495:	89 d1                	mov    %edx,%ecx
f0105497:	d3 e8                	shr    %cl,%eax
f0105499:	89 e9                	mov    %ebp,%ecx
f010549b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f010549f:	d3 e3                	shl    %cl,%ebx
f01054a1:	89 c7                	mov    %eax,%edi
f01054a3:	89 d1                	mov    %edx,%ecx
f01054a5:	89 f0                	mov    %esi,%eax
f01054a7:	d3 e8                	shr    %cl,%eax
f01054a9:	89 e9                	mov    %ebp,%ecx
f01054ab:	89 fa                	mov    %edi,%edx
f01054ad:	d3 e6                	shl    %cl,%esi
f01054af:	09 d8                	or     %ebx,%eax
f01054b1:	f7 74 24 08          	divl   0x8(%esp)
f01054b5:	89 d1                	mov    %edx,%ecx
f01054b7:	89 f3                	mov    %esi,%ebx
f01054b9:	f7 64 24 0c          	mull   0xc(%esp)
f01054bd:	89 c6                	mov    %eax,%esi
f01054bf:	89 d7                	mov    %edx,%edi
f01054c1:	39 d1                	cmp    %edx,%ecx
f01054c3:	72 06                	jb     f01054cb <__umoddi3+0xfb>
f01054c5:	75 10                	jne    f01054d7 <__umoddi3+0x107>
f01054c7:	39 c3                	cmp    %eax,%ebx
f01054c9:	73 0c                	jae    f01054d7 <__umoddi3+0x107>
f01054cb:	2b 44 24 0c          	sub    0xc(%esp),%eax
f01054cf:	1b 54 24 08          	sbb    0x8(%esp),%edx
f01054d3:	89 d7                	mov    %edx,%edi
f01054d5:	89 c6                	mov    %eax,%esi
f01054d7:	89 ca                	mov    %ecx,%edx
f01054d9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01054de:	29 f3                	sub    %esi,%ebx
f01054e0:	19 fa                	sbb    %edi,%edx
f01054e2:	89 d0                	mov    %edx,%eax
f01054e4:	d3 e0                	shl    %cl,%eax
f01054e6:	89 e9                	mov    %ebp,%ecx
f01054e8:	d3 eb                	shr    %cl,%ebx
f01054ea:	d3 ea                	shr    %cl,%edx
f01054ec:	09 d8                	or     %ebx,%eax
f01054ee:	83 c4 1c             	add    $0x1c,%esp
f01054f1:	5b                   	pop    %ebx
f01054f2:	5e                   	pop    %esi
f01054f3:	5f                   	pop    %edi
f01054f4:	5d                   	pop    %ebp
f01054f5:	c3                   	ret    
f01054f6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01054fd:	8d 76 00             	lea    0x0(%esi),%esi
f0105500:	89 da                	mov    %ebx,%edx
f0105502:	29 fe                	sub    %edi,%esi
f0105504:	19 c2                	sbb    %eax,%edx
f0105506:	89 f1                	mov    %esi,%ecx
f0105508:	89 c8                	mov    %ecx,%eax
f010550a:	e9 4b ff ff ff       	jmp    f010545a <__umoddi3+0x8a>
