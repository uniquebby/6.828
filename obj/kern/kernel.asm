
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
f010004b:	68 40 55 10 f0       	push   $0xf0105540
f0100050:	e8 b0 37 00 00       	call   f0103805 <cprintf>
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
f010006f:	68 5c 55 10 f0       	push   $0xf010555c
f0100074:	e8 8c 37 00 00       	call   f0103805 <cprintf>
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
f01000bf:	e8 36 4e 00 00       	call   f0104efa <cpunum>
f01000c4:	ff 75 0c             	pushl  0xc(%ebp)
f01000c7:	ff 75 08             	pushl  0x8(%ebp)
f01000ca:	50                   	push   %eax
f01000cb:	68 d0 55 10 f0       	push   $0xf01055d0
f01000d0:	e8 30 37 00 00       	call   f0103805 <cprintf>
	vcprintf(fmt, ap);
f01000d5:	83 c4 08             	add    $0x8,%esp
f01000d8:	53                   	push   %ebx
f01000d9:	56                   	push   %esi
f01000da:	e8 00 37 00 00       	call   f01037df <vcprintf>
	cprintf("\n");
f01000df:	c7 04 24 ef 67 10 f0 	movl   $0xf01067ef,(%esp)
f01000e6:	e8 1a 37 00 00       	call   f0103805 <cprintf>
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
f0100104:	68 77 55 10 f0       	push   $0xf0105577
f0100109:	e8 f7 36 00 00       	call   f0103805 <cprintf>
	test_backtrace(5);
f010010e:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f0100115:	e8 26 ff ff ff       	call   f0100040 <test_backtrace>
	mem_init();
f010011a:	e8 ef 11 00 00       	call   f010130e <mem_init>
	env_init();
f010011f:	e8 33 2f 00 00       	call   f0103057 <env_init>
	trap_init();
f0100124:	e8 52 37 00 00       	call   f010387b <trap_init>
	mp_init();
f0100129:	e8 d5 4a 00 00       	call   f0104c03 <mp_init>
	lapic_init();
f010012e:	e8 dd 4d 00 00       	call   f0104f10 <lapic_init>
	pic_init();
f0100133:	e8 ee 35 00 00       	call   f0103726 <pic_init>
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
f0100147:	b8 66 4b 10 f0       	mov    $0xf0104b66,%eax
f010014c:	2d ec 4a 10 f0       	sub    $0xf0104aec,%eax
f0100151:	50                   	push   %eax
f0100152:	68 ec 4a 10 f0       	push   $0xf0104aec
f0100157:	68 00 70 00 f0       	push   $0xf0007000
f010015c:	e8 e1 47 00 00       	call   f0104942 <memmove>
f0100161:	83 c4 10             	add    $0x10,%esp
	for (c = cpus; c < cpus + ncpu; c++) {
f0100164:	bb 20 20 23 f0       	mov    $0xf0232020,%ebx
f0100169:	eb 19                	jmp    f0100184 <i386_init+0x94>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010016b:	68 00 70 00 00       	push   $0x7000
f0100170:	68 f4 55 10 f0       	push   $0xf01055f4
f0100175:	6a 5a                	push   $0x5a
f0100177:	68 92 55 10 f0       	push   $0xf0105592
f010017c:	e8 13 ff ff ff       	call   f0100094 <_panic>
f0100181:	83 c3 74             	add    $0x74,%ebx
f0100184:	6b 05 c4 23 23 f0 74 	imul   $0x74,0xf02323c4,%eax
f010018b:	05 20 20 23 f0       	add    $0xf0232020,%eax
f0100190:	39 c3                	cmp    %eax,%ebx
f0100192:	73 4d                	jae    f01001e1 <i386_init+0xf1>
		if (c == cpus + cpunum())  // We've started already.
f0100194:	e8 61 4d 00 00       	call   f0104efa <cpunum>
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
f01001cf:	e8 8e 4e 00 00       	call   f0105062 <lapic_startap>
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
f01001eb:	e8 38 30 00 00       	call   f0103228 <env_create>
	sched_yield();
f01001f0:	e8 af 3b 00 00       	call   f0103da4 <sched_yield>

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
f010020f:	e8 e6 4c 00 00       	call   f0104efa <cpunum>
f0100214:	83 ec 08             	sub    $0x8,%esp
f0100217:	50                   	push   %eax
f0100218:	68 9e 55 10 f0       	push   $0xf010559e
f010021d:	e8 e3 35 00 00       	call   f0103805 <cprintf>
	lapic_init();
f0100222:	e8 e9 4c 00 00       	call   f0104f10 <lapic_init>
	env_init_percpu();
f0100227:	e8 ff 2d 00 00       	call   f010302b <env_init_percpu>
	trap_init_percpu();
f010022c:	e8 e8 35 00 00       	call   f0103819 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100231:	e8 c4 4c 00 00       	call   f0104efa <cpunum>
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
f010024e:	68 18 56 10 f0       	push   $0xf0105618
f0100253:	6a 71                	push   $0x71
f0100255:	68 92 55 10 f0       	push   $0xf0105592
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
f010026f:	68 b4 55 10 f0       	push   $0xf01055b4
f0100274:	e8 8c 35 00 00       	call   f0103805 <cprintf>
	vcprintf(fmt, ap);
f0100279:	83 c4 08             	add    $0x8,%esp
f010027c:	53                   	push   %ebx
f010027d:	ff 75 10             	pushl  0x10(%ebp)
f0100280:	e8 5a 35 00 00       	call   f01037df <vcprintf>
	cprintf("\n");
f0100285:	c7 04 24 ef 67 10 f0 	movl   $0xf01067ef,(%esp)
f010028c:	e8 74 35 00 00       	call   f0103805 <cprintf>
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
f010033b:	0f b6 82 a0 57 10 f0 	movzbl -0xfefa860(%edx),%eax
f0100342:	0b 05 00 10 23 f0    	or     0xf0231000,%eax
	shift ^= togglecode[data];
f0100348:	0f b6 8a a0 56 10 f0 	movzbl -0xfefa960(%edx),%ecx
f010034f:	31 c8                	xor    %ecx,%eax
f0100351:	a3 00 10 23 f0       	mov    %eax,0xf0231000
	c = charcode[shift & (CTL | SHIFT)][data];
f0100356:	89 c1                	mov    %eax,%ecx
f0100358:	83 e1 03             	and    $0x3,%ecx
f010035b:	8b 0c 8d 80 56 10 f0 	mov    -0xfefa980(,%ecx,4),%ecx
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
f01003a5:	0f b6 82 a0 57 10 f0 	movzbl -0xfefa860(%edx),%eax
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
f01003df:	68 3c 56 10 f0       	push   $0xf010563c
f01003e4:	e8 1c 34 00 00       	call   f0103805 <cprintf>
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
f01005c7:	e8 76 43 00 00       	call   f0104942 <memmove>
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
f01006f1:	e8 b2 2f 00 00       	call   f01036a8 <irq_setmask_8259A>
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
f0100787:	68 48 56 10 f0       	push   $0xf0105648
f010078c:	e8 74 30 00 00       	call   f0103805 <cprintf>
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
f01007c3:	68 a0 58 10 f0       	push   $0xf01058a0
f01007c8:	68 be 58 10 f0       	push   $0xf01058be
f01007cd:	68 c3 58 10 f0       	push   $0xf01058c3
f01007d2:	e8 2e 30 00 00       	call   f0103805 <cprintf>
f01007d7:	83 c4 0c             	add    $0xc,%esp
f01007da:	68 70 59 10 f0       	push   $0xf0105970
f01007df:	68 cc 58 10 f0       	push   $0xf01058cc
f01007e4:	68 c3 58 10 f0       	push   $0xf01058c3
f01007e9:	e8 17 30 00 00       	call   f0103805 <cprintf>
f01007ee:	83 c4 0c             	add    $0xc,%esp
f01007f1:	68 d5 58 10 f0       	push   $0xf01058d5
f01007f6:	68 ec 58 10 f0       	push   $0xf01058ec
f01007fb:	68 c3 58 10 f0       	push   $0xf01058c3
f0100800:	e8 00 30 00 00       	call   f0103805 <cprintf>
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
f0100812:	68 f6 58 10 f0       	push   $0xf01058f6
f0100817:	e8 e9 2f 00 00       	call   f0103805 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f010081c:	83 c4 08             	add    $0x8,%esp
f010081f:	68 0c 00 10 00       	push   $0x10000c
f0100824:	68 98 59 10 f0       	push   $0xf0105998
f0100829:	e8 d7 2f 00 00       	call   f0103805 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010082e:	83 c4 0c             	add    $0xc,%esp
f0100831:	68 0c 00 10 00       	push   $0x10000c
f0100836:	68 0c 00 10 f0       	push   $0xf010000c
f010083b:	68 c0 59 10 f0       	push   $0xf01059c0
f0100840:	e8 c0 2f 00 00       	call   f0103805 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100845:	83 c4 0c             	add    $0xc,%esp
f0100848:	68 3f 55 10 00       	push   $0x10553f
f010084d:	68 3f 55 10 f0       	push   $0xf010553f
f0100852:	68 e4 59 10 f0       	push   $0xf01059e4
f0100857:	e8 a9 2f 00 00       	call   f0103805 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010085c:	83 c4 0c             	add    $0xc,%esp
f010085f:	68 00 10 23 00       	push   $0x231000
f0100864:	68 00 10 23 f0       	push   $0xf0231000
f0100869:	68 08 5a 10 f0       	push   $0xf0105a08
f010086e:	e8 92 2f 00 00       	call   f0103805 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100873:	83 c4 0c             	add    $0xc,%esp
f0100876:	68 08 30 27 00       	push   $0x273008
f010087b:	68 08 30 27 f0       	push   $0xf0273008
f0100880:	68 2c 5a 10 f0       	push   $0xf0105a2c
f0100885:	e8 7b 2f 00 00       	call   f0103805 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f010088a:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f010088d:	b8 08 30 27 f0       	mov    $0xf0273008,%eax
f0100892:	2d 0d fc 0f f0       	sub    $0xf00ffc0d,%eax
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100897:	c1 f8 0a             	sar    $0xa,%eax
f010089a:	50                   	push   %eax
f010089b:	68 50 5a 10 f0       	push   $0xf0105a50
f01008a0:	e8 60 2f 00 00       	call   f0103805 <cprintf>
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
f01008b7:	68 0f 59 10 f0       	push   $0xf010590f
f01008bc:	e8 44 2f 00 00       	call   f0103805 <cprintf>
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
f01008df:	68 21 59 10 f0       	push   $0xf0105921
f01008e4:	e8 1c 2f 00 00       	call   f0103805 <cprintf>
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
f0100907:	68 7c 5a 10 f0       	push   $0xf0105a7c
f010090c:	e8 f4 2e 00 00       	call   f0103805 <cprintf>
		if (debuginfo_eip(ptr_ebp[1], &info) == 0) {
f0100911:	83 c4 18             	add    $0x18,%esp
f0100914:	57                   	push   %edi
f0100915:	ff 73 04             	pushl  0x4(%ebx)
f0100918:	e8 9e 35 00 00       	call   f0103ebb <debuginfo_eip>
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
f010093c:	68 ac 5a 10 f0       	push   $0xf0105aac
f0100941:	e8 bf 2e 00 00       	call   f0103805 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100946:	c7 04 24 d0 5a 10 f0 	movl   $0xf0105ad0,(%esp)
f010094d:	e8 b3 2e 00 00       	call   f0103805 <cprintf>

	if (tf != NULL)
f0100952:	83 c4 10             	add    $0x10,%esp
f0100955:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100959:	0f 84 d9 00 00 00    	je     f0100a38 <monitor+0x105>
		print_trapframe(tf);
f010095f:	83 ec 0c             	sub    $0xc,%esp
f0100962:	ff 75 08             	pushl  0x8(%ebp)
f0100965:	e8 ac 2f 00 00       	call   f0103916 <print_trapframe>
f010096a:	83 c4 10             	add    $0x10,%esp
f010096d:	e9 c6 00 00 00       	jmp    f0100a38 <monitor+0x105>
		while (*buf && strchr(WHITESPACE, *buf))
f0100972:	83 ec 08             	sub    $0x8,%esp
f0100975:	0f be c0             	movsbl %al,%eax
f0100978:	50                   	push   %eax
f0100979:	68 37 59 10 f0       	push   $0xf0105937
f010097e:	e8 3a 3f 00 00       	call   f01048bd <strchr>
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
f01009b6:	ff 34 85 00 5b 10 f0 	pushl  -0xfefa500(,%eax,4)
f01009bd:	ff 75 a8             	pushl  -0x58(%ebp)
f01009c0:	e8 9a 3e 00 00       	call   f010485f <strcmp>
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
f01009de:	68 59 59 10 f0       	push   $0xf0105959
f01009e3:	e8 1d 2e 00 00       	call   f0103805 <cprintf>
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
f0100a0c:	68 37 59 10 f0       	push   $0xf0105937
f0100a11:	e8 a7 3e 00 00       	call   f01048bd <strchr>
f0100a16:	83 c4 10             	add    $0x10,%esp
f0100a19:	85 c0                	test   %eax,%eax
f0100a1b:	0f 85 71 ff ff ff    	jne    f0100992 <monitor+0x5f>
			buf++;
f0100a21:	83 c3 01             	add    $0x1,%ebx
f0100a24:	eb d8                	jmp    f01009fe <monitor+0xcb>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100a26:	83 ec 08             	sub    $0x8,%esp
f0100a29:	6a 10                	push   $0x10
f0100a2b:	68 3c 59 10 f0       	push   $0xf010593c
f0100a30:	e8 d0 2d 00 00       	call   f0103805 <cprintf>
f0100a35:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f0100a38:	83 ec 0c             	sub    $0xc,%esp
f0100a3b:	68 33 59 10 f0       	push   $0xf0105933
f0100a40:	e8 54 3c 00 00       	call   f0104699 <readline>
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
f0100a6d:	ff 14 85 08 5b 10 f0 	call   *-0xfefa4f8(,%eax,4)
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
f0100ac4:	e8 b1 2b 00 00       	call   f010367a <mc146818_read>
f0100ac9:	89 c3                	mov    %eax,%ebx
f0100acb:	83 c6 01             	add    $0x1,%esi
f0100ace:	89 34 24             	mov    %esi,(%esp)
f0100ad1:	e8 a4 2b 00 00       	call   f010367a <mc146818_read>
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
f0100b2c:	68 f4 55 10 f0       	push   $0xf01055f4
f0100b31:	68 a2 03 00 00       	push   $0x3a2
f0100b36:	68 bd 64 10 f0       	push   $0xf01064bd
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
f0100b51:	0f 85 e1 02 00 00    	jne    f0100e38 <check_page_free_list+0x2f2>
	if (!page_free_list)
f0100b57:	83 3d 3c 12 23 f0 00 	cmpl   $0x0,0xf023123c
f0100b5e:	74 19                	je     f0100b79 <check_page_free_list+0x33>
	cprintf("%d\n",only_low_memory);
f0100b60:	83 ec 08             	sub    $0x8,%esp
f0100b63:	6a 00                	push   $0x0
f0100b65:	68 cd 69 10 f0       	push   $0xf01069cd
f0100b6a:	e8 96 2c 00 00       	call   f0103805 <cprintf>
f0100b6f:	83 c4 10             	add    $0x10,%esp
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100b72:	be 00 04 00 00       	mov    $0x400,%esi
f0100b77:	eb 6a                	jmp    f0100be3 <check_page_free_list+0x9d>
		panic("'page_free_list' is a null pointer!");
f0100b79:	83 ec 04             	sub    $0x4,%esp
f0100b7c:	68 24 5b 10 f0       	push   $0xf0105b24
f0100b81:	68 c5 02 00 00       	push   $0x2c5
f0100b86:	68 bd 64 10 f0       	push   $0xf01064bd
f0100b8b:	e8 04 f5 ff ff       	call   f0100094 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100b90:	89 c2                	mov    %eax,%edx
f0100b92:	2b 15 10 1f 23 f0    	sub    0xf0231f10,%edx
			pagetype = (PDX(page2pa(pp)) >= pdx_limit);
f0100b98:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100b9e:	0f 95 c2             	setne  %dl
f0100ba1:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100ba4:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100ba8:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100baa:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100bae:	8b 00                	mov    (%eax),%eax
f0100bb0:	85 c0                	test   %eax,%eax
f0100bb2:	75 dc                	jne    f0100b90 <check_page_free_list+0x4a>
			cprintf("end%d",pagetype);
f0100bb4:	83 ec 08             	sub    $0x8,%esp
f0100bb7:	52                   	push   %edx
f0100bb8:	68 c9 64 10 f0       	push   $0xf01064c9
f0100bbd:	e8 43 2c 00 00       	call   f0103805 <cprintf>
		*tp[1] = 0;
f0100bc2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100bc5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100bcb:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100bce:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100bd1:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100bd3:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100bd6:	a3 3c 12 23 f0       	mov    %eax,0xf023123c
f0100bdb:	83 c4 10             	add    $0x10,%esp
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100bde:	be 01 00 00 00       	mov    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100be3:	8b 1d 3c 12 23 f0    	mov    0xf023123c,%ebx
f0100be9:	eb 14                	jmp    f0100bff <check_page_free_list+0xb9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100beb:	50                   	push   %eax
f0100bec:	68 f4 55 10 f0       	push   $0xf01055f4
f0100bf1:	6a 58                	push   $0x58
f0100bf3:	68 cf 64 10 f0       	push   $0xf01064cf
f0100bf8:	e8 97 f4 ff ff       	call   f0100094 <_panic>
f0100bfd:	8b 1b                	mov    (%ebx),%ebx
f0100bff:	85 db                	test   %ebx,%ebx
f0100c01:	74 41                	je     f0100c44 <check_page_free_list+0xfe>
	return (pp - pages) << PGSHIFT;
f0100c03:	89 d8                	mov    %ebx,%eax
f0100c05:	2b 05 10 1f 23 f0    	sub    0xf0231f10,%eax
f0100c0b:	c1 f8 03             	sar    $0x3,%eax
f0100c0e:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100c11:	89 c2                	mov    %eax,%edx
f0100c13:	c1 ea 16             	shr    $0x16,%edx
f0100c16:	39 f2                	cmp    %esi,%edx
f0100c18:	73 e3                	jae    f0100bfd <check_page_free_list+0xb7>
	if (PGNUM(pa) >= npages)
f0100c1a:	89 c2                	mov    %eax,%edx
f0100c1c:	c1 ea 0c             	shr    $0xc,%edx
f0100c1f:	3b 15 08 1f 23 f0    	cmp    0xf0231f08,%edx
f0100c25:	73 c4                	jae    f0100beb <check_page_free_list+0xa5>
			memset(page2kva(pp), 0x97, 128);
f0100c27:	83 ec 04             	sub    $0x4,%esp
f0100c2a:	68 80 00 00 00       	push   $0x80
f0100c2f:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0100c34:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c39:	50                   	push   %eax
f0100c3a:	e8 bb 3c 00 00       	call   f01048fa <memset>
f0100c3f:	83 c4 10             	add    $0x10,%esp
f0100c42:	eb b9                	jmp    f0100bfd <check_page_free_list+0xb7>
	first_free_page = (char *) boot_alloc(0);
f0100c44:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c49:	e8 35 fe ff ff       	call   f0100a83 <boot_alloc>
f0100c4e:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c51:	8b 15 3c 12 23 f0    	mov    0xf023123c,%edx
		assert(pp >= pages);
f0100c57:	8b 0d 10 1f 23 f0    	mov    0xf0231f10,%ecx
		assert(pp < pages + npages);
f0100c5d:	a1 08 1f 23 f0       	mov    0xf0231f08,%eax
f0100c62:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100c65:	8d 34 c1             	lea    (%ecx,%eax,8),%esi
	int nfree_basemem = 0, nfree_extmem = 0;
f0100c68:	bf 00 00 00 00       	mov    $0x0,%edi
f0100c6d:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c70:	e9 f9 00 00 00       	jmp    f0100d6e <check_page_free_list+0x228>
		assert(pp >= pages);
f0100c75:	68 dd 64 10 f0       	push   $0xf01064dd
f0100c7a:	68 e9 64 10 f0       	push   $0xf01064e9
f0100c7f:	68 e5 02 00 00       	push   $0x2e5
f0100c84:	68 bd 64 10 f0       	push   $0xf01064bd
f0100c89:	e8 06 f4 ff ff       	call   f0100094 <_panic>
		assert(pp < pages + npages);
f0100c8e:	68 fe 64 10 f0       	push   $0xf01064fe
f0100c93:	68 e9 64 10 f0       	push   $0xf01064e9
f0100c98:	68 e6 02 00 00       	push   $0x2e6
f0100c9d:	68 bd 64 10 f0       	push   $0xf01064bd
f0100ca2:	e8 ed f3 ff ff       	call   f0100094 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100ca7:	68 48 5b 10 f0       	push   $0xf0105b48
f0100cac:	68 e9 64 10 f0       	push   $0xf01064e9
f0100cb1:	68 e7 02 00 00       	push   $0x2e7
f0100cb6:	68 bd 64 10 f0       	push   $0xf01064bd
f0100cbb:	e8 d4 f3 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != 0);
f0100cc0:	68 12 65 10 f0       	push   $0xf0106512
f0100cc5:	68 e9 64 10 f0       	push   $0xf01064e9
f0100cca:	68 ea 02 00 00       	push   $0x2ea
f0100ccf:	68 bd 64 10 f0       	push   $0xf01064bd
f0100cd4:	e8 bb f3 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100cd9:	68 23 65 10 f0       	push   $0xf0106523
f0100cde:	68 e9 64 10 f0       	push   $0xf01064e9
f0100ce3:	68 eb 02 00 00       	push   $0x2eb
f0100ce8:	68 bd 64 10 f0       	push   $0xf01064bd
f0100ced:	e8 a2 f3 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100cf2:	68 7c 5b 10 f0       	push   $0xf0105b7c
f0100cf7:	68 e9 64 10 f0       	push   $0xf01064e9
f0100cfc:	68 ec 02 00 00       	push   $0x2ec
f0100d01:	68 bd 64 10 f0       	push   $0xf01064bd
f0100d06:	e8 89 f3 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100d0b:	68 3c 65 10 f0       	push   $0xf010653c
f0100d10:	68 e9 64 10 f0       	push   $0xf01064e9
f0100d15:	68 ed 02 00 00       	push   $0x2ed
f0100d1a:	68 bd 64 10 f0       	push   $0xf01064bd
f0100d1f:	e8 70 f3 ff ff       	call   f0100094 <_panic>
	if (PGNUM(pa) >= npages)
f0100d24:	89 c3                	mov    %eax,%ebx
f0100d26:	c1 eb 0c             	shr    $0xc,%ebx
f0100d29:	39 5d d0             	cmp    %ebx,-0x30(%ebp)
f0100d2c:	76 0f                	jbe    f0100d3d <check_page_free_list+0x1f7>
	return (void *)(pa + KERNBASE);
f0100d2e:	2d 00 00 00 10       	sub    $0x10000000,%eax
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100d33:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0100d36:	77 17                	ja     f0100d4f <check_page_free_list+0x209>
			++nfree_extmem;
f0100d38:	83 c7 01             	add    $0x1,%edi
f0100d3b:	eb 2f                	jmp    f0100d6c <check_page_free_list+0x226>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100d3d:	50                   	push   %eax
f0100d3e:	68 f4 55 10 f0       	push   $0xf01055f4
f0100d43:	6a 58                	push   $0x58
f0100d45:	68 cf 64 10 f0       	push   $0xf01064cf
f0100d4a:	e8 45 f3 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100d4f:	68 a0 5b 10 f0       	push   $0xf0105ba0
f0100d54:	68 e9 64 10 f0       	push   $0xf01064e9
f0100d59:	68 ee 02 00 00       	push   $0x2ee
f0100d5e:	68 bd 64 10 f0       	push   $0xf01064bd
f0100d63:	e8 2c f3 ff ff       	call   f0100094 <_panic>
			++nfree_basemem;
f0100d68:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100d6c:	8b 12                	mov    (%edx),%edx
f0100d6e:	85 d2                	test   %edx,%edx
f0100d70:	74 74                	je     f0100de6 <check_page_free_list+0x2a0>
		assert(pp >= pages);
f0100d72:	39 d1                	cmp    %edx,%ecx
f0100d74:	0f 87 fb fe ff ff    	ja     f0100c75 <check_page_free_list+0x12f>
		assert(pp < pages + npages);
f0100d7a:	39 d6                	cmp    %edx,%esi
f0100d7c:	0f 86 0c ff ff ff    	jbe    f0100c8e <check_page_free_list+0x148>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100d82:	89 d0                	mov    %edx,%eax
f0100d84:	29 c8                	sub    %ecx,%eax
f0100d86:	a8 07                	test   $0x7,%al
f0100d88:	0f 85 19 ff ff ff    	jne    f0100ca7 <check_page_free_list+0x161>
	return (pp - pages) << PGSHIFT;
f0100d8e:	c1 f8 03             	sar    $0x3,%eax
		assert(page2pa(pp) != 0);
f0100d91:	c1 e0 0c             	shl    $0xc,%eax
f0100d94:	0f 84 26 ff ff ff    	je     f0100cc0 <check_page_free_list+0x17a>
		assert(page2pa(pp) != IOPHYSMEM);
f0100d9a:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100d9f:	0f 84 34 ff ff ff    	je     f0100cd9 <check_page_free_list+0x193>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100da5:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100daa:	0f 84 42 ff ff ff    	je     f0100cf2 <check_page_free_list+0x1ac>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100db0:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100db5:	0f 84 50 ff ff ff    	je     f0100d0b <check_page_free_list+0x1c5>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100dbb:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100dc0:	0f 87 5e ff ff ff    	ja     f0100d24 <check_page_free_list+0x1de>
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100dc6:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100dcb:	75 9b                	jne    f0100d68 <check_page_free_list+0x222>
f0100dcd:	68 56 65 10 f0       	push   $0xf0106556
f0100dd2:	68 e9 64 10 f0       	push   $0xf01064e9
f0100dd7:	68 f0 02 00 00       	push   $0x2f0
f0100ddc:	68 bd 64 10 f0       	push   $0xf01064bd
f0100de1:	e8 ae f2 ff ff       	call   f0100094 <_panic>
f0100de6:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
	assert(nfree_basemem > 0);
f0100de9:	85 db                	test   %ebx,%ebx
f0100deb:	7e 19                	jle    f0100e06 <check_page_free_list+0x2c0>
	assert(nfree_extmem > 0);
f0100ded:	85 ff                	test   %edi,%edi
f0100def:	7e 2e                	jle    f0100e1f <check_page_free_list+0x2d9>
	cprintf("check_page_free_list() succeeded!\n");
f0100df1:	83 ec 0c             	sub    $0xc,%esp
f0100df4:	68 e8 5b 10 f0       	push   $0xf0105be8
f0100df9:	e8 07 2a 00 00       	call   f0103805 <cprintf>
}
f0100dfe:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e01:	5b                   	pop    %ebx
f0100e02:	5e                   	pop    %esi
f0100e03:	5f                   	pop    %edi
f0100e04:	5d                   	pop    %ebp
f0100e05:	c3                   	ret    
	assert(nfree_basemem > 0);
f0100e06:	68 73 65 10 f0       	push   $0xf0106573
f0100e0b:	68 e9 64 10 f0       	push   $0xf01064e9
f0100e10:	68 f8 02 00 00       	push   $0x2f8
f0100e15:	68 bd 64 10 f0       	push   $0xf01064bd
f0100e1a:	e8 75 f2 ff ff       	call   f0100094 <_panic>
	assert(nfree_extmem > 0);
f0100e1f:	68 85 65 10 f0       	push   $0xf0106585
f0100e24:	68 e9 64 10 f0       	push   $0xf01064e9
f0100e29:	68 f9 02 00 00       	push   $0x2f9
f0100e2e:	68 bd 64 10 f0       	push   $0xf01064bd
f0100e33:	e8 5c f2 ff ff       	call   f0100094 <_panic>
	if (!page_free_list)
f0100e38:	83 3d 3c 12 23 f0 00 	cmpl   $0x0,0xf023123c
f0100e3f:	0f 84 34 fd ff ff    	je     f0100b79 <check_page_free_list+0x33>
	cprintf("%d\n",only_low_memory);
f0100e45:	83 ec 08             	sub    $0x8,%esp
f0100e48:	6a 01                	push   $0x1
f0100e4a:	68 cd 69 10 f0       	push   $0xf01069cd
f0100e4f:	e8 b1 29 00 00       	call   f0103805 <cprintf>
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100e54:	8d 45 d8             	lea    -0x28(%ebp),%eax
f0100e57:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100e5a:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0100e5d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100e60:	a1 3c 12 23 f0       	mov    0xf023123c,%eax
f0100e65:	83 c4 10             	add    $0x10,%esp
		int pagetype = 0;
f0100e68:	ba 00 00 00 00       	mov    $0x0,%edx
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100e6d:	e9 3e fd ff ff       	jmp    f0100bb0 <check_page_free_list+0x6a>

f0100e72 <page_init>:
{
f0100e72:	55                   	push   %ebp
f0100e73:	89 e5                	mov    %esp,%ebp
f0100e75:	56                   	push   %esi
f0100e76:	53                   	push   %ebx
	pages[0].pp_ref = 1;
f0100e77:	a1 10 1f 23 f0       	mov    0xf0231f10,%eax
f0100e7c:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
	cprintf("page_init &page_free_list:%p\n", &page_free_list);
f0100e82:	83 ec 08             	sub    $0x8,%esp
f0100e85:	68 3c 12 23 f0       	push   $0xf023123c
f0100e8a:	68 96 65 10 f0       	push   $0xf0106596
f0100e8f:	e8 71 29 00 00       	call   f0103805 <cprintf>
	cprintf("page_init page_free_list:%p\n", page_free_list);
f0100e94:	83 c4 08             	add    $0x8,%esp
f0100e97:	ff 35 3c 12 23 f0    	pushl  0xf023123c
f0100e9d:	68 b4 65 10 f0       	push   $0xf01065b4
f0100ea2:	e8 5e 29 00 00       	call   f0103805 <cprintf>
    for (i = 1; i < npages_basemem; i++) {
f0100ea7:	8b 1d 40 12 23 f0    	mov    0xf0231240,%ebx
f0100ead:	83 c4 10             	add    $0x10,%esp
f0100eb0:	b8 01 00 00 00       	mov    $0x1,%eax
f0100eb5:	eb 0f                	jmp    f0100ec6 <page_init+0x54>
			 pages[i].pp_ref = 1;
f0100eb7:	8b 15 10 1f 23 f0    	mov    0xf0231f10,%edx
f0100ebd:	66 c7 42 04 01 00    	movw   $0x1,0x4(%edx)
    for (i = 1; i < npages_basemem; i++) {
f0100ec3:	83 c0 01             	add    $0x1,%eax
f0100ec6:	39 c3                	cmp    %eax,%ebx
f0100ec8:	76 2f                	jbe    f0100ef9 <page_init+0x87>
		if (i == ROUNDDOWN(MPENTRY_PADDR/PGSIZE, PGSIZE)) {
f0100eca:	85 c0                	test   %eax,%eax
f0100ecc:	74 e9                	je     f0100eb7 <page_init+0x45>
f0100ece:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
        pages[i].pp_ref = 0;
f0100ed5:	89 d1                	mov    %edx,%ecx
f0100ed7:	03 0d 10 1f 23 f0    	add    0xf0231f10,%ecx
f0100edd:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
        pages[i].pp_link = page_free_list;
f0100ee3:	8b 35 3c 12 23 f0    	mov    0xf023123c,%esi
f0100ee9:	89 31                	mov    %esi,(%ecx)
        page_free_list = &pages[i];
f0100eeb:	03 15 10 1f 23 f0    	add    0xf0231f10,%edx
f0100ef1:	89 15 3c 12 23 f0    	mov    %edx,0xf023123c
f0100ef7:	eb ca                	jmp    f0100ec3 <page_init+0x51>
	size_t first_free_address = PADDR(boot_alloc(0));
f0100ef9:	b8 00 00 00 00       	mov    $0x0,%eax
f0100efe:	e8 80 fb ff ff       	call   f0100a83 <boot_alloc>
	if ((uint32_t)kva < KERNBASE)
f0100f03:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100f08:	76 2b                	jbe    f0100f35 <page_init+0xc3>
	return (physaddr_t)kva - KERNBASE;
f0100f0a:	8d 88 00 00 00 10    	lea    0x10000000(%eax),%ecx
        pages[i].pp_ref = 1;
f0100f10:	8b 15 10 1f 23 f0    	mov    0xf0231f10,%edx
f0100f16:	8d 82 04 05 00 00    	lea    0x504(%edx),%eax
f0100f1c:	81 c2 04 08 00 00    	add    $0x804,%edx
f0100f22:	66 c7 00 01 00       	movw   $0x1,(%eax)
f0100f27:	83 c0 08             	add    $0x8,%eax
    for (i = IOPHYSMEM/PGSIZE; i < EXTPHYSMEM/PGSIZE; i++) {
f0100f2a:	39 d0                	cmp    %edx,%eax
f0100f2c:	75 f4                	jne    f0100f22 <page_init+0xb0>
    for (i = first_free_address/PGSIZE; i < npages; i++) {
f0100f2e:	c1 e9 0c             	shr    $0xc,%ecx
f0100f31:	89 ca                	mov    %ecx,%edx
f0100f33:	eb 40                	jmp    f0100f75 <page_init+0x103>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100f35:	50                   	push   %eax
f0100f36:	68 18 56 10 f0       	push   $0xf0105618
f0100f3b:	68 55 01 00 00       	push   $0x155
f0100f40:	68 bd 64 10 f0       	push   $0xf01064bd
f0100f45:	e8 4a f1 ff ff       	call   f0100094 <_panic>
f0100f4a:	8d 04 d5 00 00 00 00 	lea    0x0(,%edx,8),%eax
        pages[i].pp_ref = 0;
f0100f51:	89 c1                	mov    %eax,%ecx
f0100f53:	03 0d 10 1f 23 f0    	add    0xf0231f10,%ecx
f0100f59:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
        pages[i].pp_link = page_free_list;
f0100f5f:	8b 1d 3c 12 23 f0    	mov    0xf023123c,%ebx
f0100f65:	89 19                	mov    %ebx,(%ecx)
        page_free_list = &pages[i];
f0100f67:	03 05 10 1f 23 f0    	add    0xf0231f10,%eax
f0100f6d:	a3 3c 12 23 f0       	mov    %eax,0xf023123c
    for (i = first_free_address/PGSIZE; i < npages; i++) {
f0100f72:	83 c2 01             	add    $0x1,%edx
f0100f75:	39 15 08 1f 23 f0    	cmp    %edx,0xf0231f08
f0100f7b:	77 cd                	ja     f0100f4a <page_init+0xd8>
}
f0100f7d:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100f80:	5b                   	pop    %ebx
f0100f81:	5e                   	pop    %esi
f0100f82:	5d                   	pop    %ebp
f0100f83:	c3                   	ret    

f0100f84 <page_alloc>:
{
f0100f84:	55                   	push   %ebp
f0100f85:	89 e5                	mov    %esp,%ebp
f0100f87:	53                   	push   %ebx
f0100f88:	83 ec 04             	sub    $0x4,%esp
	if (!page_free_list) {
f0100f8b:	8b 1d 3c 12 23 f0    	mov    0xf023123c,%ebx
f0100f91:	85 db                	test   %ebx,%ebx
f0100f93:	74 13                	je     f0100fa8 <page_alloc+0x24>
	page_free_list = page->pp_link;
f0100f95:	8b 03                	mov    (%ebx),%eax
f0100f97:	a3 3c 12 23 f0       	mov    %eax,0xf023123c
	page->pp_link = NULL;
f0100f9c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (alloc_flags & ALLOC_ZERO) {
f0100fa2:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100fa6:	75 07                	jne    f0100faf <page_alloc+0x2b>
}
f0100fa8:	89 d8                	mov    %ebx,%eax
f0100faa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100fad:	c9                   	leave  
f0100fae:	c3                   	ret    
	return (pp - pages) << PGSHIFT;
f0100faf:	89 d8                	mov    %ebx,%eax
f0100fb1:	2b 05 10 1f 23 f0    	sub    0xf0231f10,%eax
f0100fb7:	c1 f8 03             	sar    $0x3,%eax
f0100fba:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0100fbd:	89 c2                	mov    %eax,%edx
f0100fbf:	c1 ea 0c             	shr    $0xc,%edx
f0100fc2:	3b 15 08 1f 23 f0    	cmp    0xf0231f08,%edx
f0100fc8:	73 1a                	jae    f0100fe4 <page_alloc+0x60>
		memset(page2kva(page), 0, PGSIZE); 
f0100fca:	83 ec 04             	sub    $0x4,%esp
f0100fcd:	68 00 10 00 00       	push   $0x1000
f0100fd2:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f0100fd4:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100fd9:	50                   	push   %eax
f0100fda:	e8 1b 39 00 00       	call   f01048fa <memset>
f0100fdf:	83 c4 10             	add    $0x10,%esp
f0100fe2:	eb c4                	jmp    f0100fa8 <page_alloc+0x24>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100fe4:	50                   	push   %eax
f0100fe5:	68 f4 55 10 f0       	push   $0xf01055f4
f0100fea:	6a 58                	push   $0x58
f0100fec:	68 cf 64 10 f0       	push   $0xf01064cf
f0100ff1:	e8 9e f0 ff ff       	call   f0100094 <_panic>

f0100ff6 <page_free>:
{
f0100ff6:	55                   	push   %ebp
f0100ff7:	89 e5                	mov    %esp,%ebp
f0100ff9:	83 ec 08             	sub    $0x8,%esp
f0100ffc:	8b 45 08             	mov    0x8(%ebp),%eax
	if (pp->pp_ref || pp->pp_link) {
f0100fff:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101004:	75 14                	jne    f010101a <page_free+0x24>
f0101006:	83 38 00             	cmpl   $0x0,(%eax)
f0101009:	75 0f                	jne    f010101a <page_free+0x24>
	pp->pp_link = page_free_list;
f010100b:	8b 15 3c 12 23 f0    	mov    0xf023123c,%edx
f0101011:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0101013:	a3 3c 12 23 f0       	mov    %eax,0xf023123c
}
f0101018:	c9                   	leave  
f0101019:	c3                   	ret    
		panic("page_free: double check failed when dealloc page. '\n");
f010101a:	83 ec 04             	sub    $0x4,%esp
f010101d:	68 0c 5c 10 f0       	push   $0xf0105c0c
f0101022:	68 90 01 00 00       	push   $0x190
f0101027:	68 bd 64 10 f0       	push   $0xf01064bd
f010102c:	e8 63 f0 ff ff       	call   f0100094 <_panic>

f0101031 <page_decref>:
{
f0101031:	55                   	push   %ebp
f0101032:	89 e5                	mov    %esp,%ebp
f0101034:	83 ec 08             	sub    $0x8,%esp
f0101037:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f010103a:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f010103e:	83 e8 01             	sub    $0x1,%eax
f0101041:	66 89 42 04          	mov    %ax,0x4(%edx)
f0101045:	66 85 c0             	test   %ax,%ax
f0101048:	74 02                	je     f010104c <page_decref+0x1b>
}
f010104a:	c9                   	leave  
f010104b:	c3                   	ret    
		page_free(pp);
f010104c:	83 ec 0c             	sub    $0xc,%esp
f010104f:	52                   	push   %edx
f0101050:	e8 a1 ff ff ff       	call   f0100ff6 <page_free>
f0101055:	83 c4 10             	add    $0x10,%esp
}
f0101058:	eb f0                	jmp    f010104a <page_decref+0x19>

f010105a <pgdir_walk>:
{
f010105a:	55                   	push   %ebp
f010105b:	89 e5                	mov    %esp,%ebp
f010105d:	56                   	push   %esi
f010105e:	53                   	push   %ebx
f010105f:	8b 45 0c             	mov    0xc(%ebp),%eax
	uint32_t ptx = PTX(va);		
f0101062:	89 c6                	mov    %eax,%esi
f0101064:	c1 ee 0c             	shr    $0xc,%esi
f0101067:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
	uint32_t pdx = PDX(va);		
f010106d:	c1 e8 16             	shr    $0x16,%eax
	if (pgdir[pdx] & PTE_P) {
f0101070:	8d 1c 85 00 00 00 00 	lea    0x0(,%eax,4),%ebx
f0101077:	03 5d 08             	add    0x8(%ebp),%ebx
f010107a:	8b 03                	mov    (%ebx),%eax
f010107c:	a8 01                	test   $0x1,%al
f010107e:	74 36                	je     f01010b6 <pgdir_walk+0x5c>
		pgtab = KADDR(PTE_ADDR(pgdir[pdx]));
f0101080:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0101085:	89 c2                	mov    %eax,%edx
f0101087:	c1 ea 0c             	shr    $0xc,%edx
f010108a:	39 15 08 1f 23 f0    	cmp    %edx,0xf0231f08
f0101090:	76 0f                	jbe    f01010a1 <pgdir_walk+0x47>
	return (void *)(pa + KERNBASE);
f0101092:	2d 00 00 00 10       	sub    $0x10000000,%eax
	return &pgtab[ptx];
f0101097:	8d 04 b0             	lea    (%eax,%esi,4),%eax
}
f010109a:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010109d:	5b                   	pop    %ebx
f010109e:	5e                   	pop    %esi
f010109f:	5d                   	pop    %ebp
f01010a0:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01010a1:	50                   	push   %eax
f01010a2:	68 f4 55 10 f0       	push   $0xf01055f4
f01010a7:	68 c0 01 00 00       	push   $0x1c0
f01010ac:	68 bd 64 10 f0       	push   $0xf01064bd
f01010b1:	e8 de ef ff ff       	call   f0100094 <_panic>
		if (create) {
f01010b6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01010ba:	74 50                	je     f010110c <pgdir_walk+0xb2>
			struct PageInfo *new_pginfo = page_alloc(ALLOC_ZERO);	
f01010bc:	83 ec 0c             	sub    $0xc,%esp
f01010bf:	6a 01                	push   $0x1
f01010c1:	e8 be fe ff ff       	call   f0100f84 <page_alloc>
			if (new_pginfo) {
f01010c6:	83 c4 10             	add    $0x10,%esp
f01010c9:	85 c0                	test   %eax,%eax
f01010cb:	74 46                	je     f0101113 <pgdir_walk+0xb9>
				new_pginfo->pp_ref += 1;
f01010cd:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f01010d2:	2b 05 10 1f 23 f0    	sub    0xf0231f10,%eax
f01010d8:	89 c2                	mov    %eax,%edx
f01010da:	c1 fa 03             	sar    $0x3,%edx
f01010dd:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f01010e0:	89 d0                	mov    %edx,%eax
f01010e2:	c1 e8 0c             	shr    $0xc,%eax
f01010e5:	3b 05 08 1f 23 f0    	cmp    0xf0231f08,%eax
f01010eb:	73 0d                	jae    f01010fa <pgdir_walk+0xa0>
	return (void *)(pa + KERNBASE);
f01010ed:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
				pgdir[pdx] = page2pa(new_pginfo) | PTE_P | PTE_W | PTE_U;
f01010f3:	83 ca 07             	or     $0x7,%edx
f01010f6:	89 13                	mov    %edx,(%ebx)
f01010f8:	eb 9d                	jmp    f0101097 <pgdir_walk+0x3d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01010fa:	52                   	push   %edx
f01010fb:	68 f4 55 10 f0       	push   $0xf01055f4
f0101100:	6a 58                	push   $0x58
f0101102:	68 cf 64 10 f0       	push   $0xf01064cf
f0101107:	e8 88 ef ff ff       	call   f0100094 <_panic>
			return NULL;
f010110c:	b8 00 00 00 00       	mov    $0x0,%eax
f0101111:	eb 87                	jmp    f010109a <pgdir_walk+0x40>
			return NULL; 
f0101113:	b8 00 00 00 00       	mov    $0x0,%eax
f0101118:	eb 80                	jmp    f010109a <pgdir_walk+0x40>

f010111a <boot_map_region>:
{
f010111a:	55                   	push   %ebp
f010111b:	89 e5                	mov    %esp,%ebp
f010111d:	57                   	push   %edi
f010111e:	56                   	push   %esi
f010111f:	53                   	push   %ebx
f0101120:	83 ec 1c             	sub    $0x1c,%esp
f0101123:	89 c7                	mov    %eax,%edi
f0101125:	8b 45 08             	mov    0x8(%ebp),%eax
f0101128:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f010112e:	01 c1                	add    %eax,%ecx
f0101130:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	for (size_t i = 0;i < pg_num; i++) {
f0101133:	89 c3                	mov    %eax,%ebx
		pte = pgdir_walk(pgdir, (void *)va, 1);		 
f0101135:	89 d6                	mov    %edx,%esi
f0101137:	29 c6                	sub    %eax,%esi
	for (size_t i = 0;i < pg_num; i++) {
f0101139:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f010113c:	74 28                	je     f0101166 <boot_map_region+0x4c>
		pte = pgdir_walk(pgdir, (void *)va, 1);		 
f010113e:	83 ec 04             	sub    $0x4,%esp
f0101141:	6a 01                	push   $0x1
f0101143:	8d 04 1e             	lea    (%esi,%ebx,1),%eax
f0101146:	50                   	push   %eax
f0101147:	57                   	push   %edi
f0101148:	e8 0d ff ff ff       	call   f010105a <pgdir_walk>
		if (!pte) {
f010114d:	83 c4 10             	add    $0x10,%esp
f0101150:	85 c0                	test   %eax,%eax
f0101152:	74 12                	je     f0101166 <boot_map_region+0x4c>
		*pte = pa | perm | PTE_P;
f0101154:	89 da                	mov    %ebx,%edx
f0101156:	0b 55 0c             	or     0xc(%ebp),%edx
f0101159:	83 ca 01             	or     $0x1,%edx
f010115c:	89 10                	mov    %edx,(%eax)
		pa += PGSIZE;
f010115e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0101164:	eb d3                	jmp    f0101139 <boot_map_region+0x1f>
}
f0101166:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101169:	5b                   	pop    %ebx
f010116a:	5e                   	pop    %esi
f010116b:	5f                   	pop    %edi
f010116c:	5d                   	pop    %ebp
f010116d:	c3                   	ret    

f010116e <page_lookup>:
{
f010116e:	55                   	push   %ebp
f010116f:	89 e5                	mov    %esp,%ebp
f0101171:	83 ec 0c             	sub    $0xc,%esp
	pte_t *pte = pgdir_walk(pgdir, va, 0);
f0101174:	6a 00                	push   $0x0
f0101176:	ff 75 0c             	pushl  0xc(%ebp)
f0101179:	ff 75 08             	pushl  0x8(%ebp)
f010117c:	e8 d9 fe ff ff       	call   f010105a <pgdir_walk>
	if (!pte) {
f0101181:	83 c4 10             	add    $0x10,%esp
f0101184:	85 c0                	test   %eax,%eax
f0101186:	74 3b                	je     f01011c3 <page_lookup+0x55>
		*pte_store = pte;
f0101188:	8b 55 10             	mov    0x10(%ebp),%edx
f010118b:	89 02                	mov    %eax,(%edx)
	 	if (*pte) {
f010118d:	8b 10                	mov    (%eax),%edx
	return NULL;
f010118f:	b8 00 00 00 00       	mov    $0x0,%eax
	 	if (*pte) {
f0101194:	85 d2                	test   %edx,%edx
f0101196:	75 02                	jne    f010119a <page_lookup+0x2c>
}
f0101198:	c9                   	leave  
f0101199:	c3                   	ret    
f010119a:	c1 ea 0c             	shr    $0xc,%edx
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010119d:	39 15 08 1f 23 f0    	cmp    %edx,0xf0231f08
f01011a3:	76 0a                	jbe    f01011af <page_lookup+0x41>
		panic("pa2page called with invalid pa");
	return &pages[PGNUM(pa)];
f01011a5:	a1 10 1f 23 f0       	mov    0xf0231f10,%eax
f01011aa:	8d 04 d0             	lea    (%eax,%edx,8),%eax
			return pa2page(PTE_ADDR(*pte)); 
f01011ad:	eb e9                	jmp    f0101198 <page_lookup+0x2a>
		panic("pa2page called with invalid pa");
f01011af:	83 ec 04             	sub    $0x4,%esp
f01011b2:	68 44 5c 10 f0       	push   $0xf0105c44
f01011b7:	6a 51                	push   $0x51
f01011b9:	68 cf 64 10 f0       	push   $0xf01064cf
f01011be:	e8 d1 ee ff ff       	call   f0100094 <_panic>
		 return NULL;
f01011c3:	b8 00 00 00 00       	mov    $0x0,%eax
f01011c8:	eb ce                	jmp    f0101198 <page_lookup+0x2a>

f01011ca <tlb_invalidate>:
{
f01011ca:	55                   	push   %ebp
f01011cb:	89 e5                	mov    %esp,%ebp
f01011cd:	83 ec 08             	sub    $0x8,%esp
	if (!curenv || curenv->env_pgdir == pgdir)
f01011d0:	e8 25 3d 00 00       	call   f0104efa <cpunum>
f01011d5:	6b c0 74             	imul   $0x74,%eax,%eax
f01011d8:	83 b8 28 20 23 f0 00 	cmpl   $0x0,-0xfdcdfd8(%eax)
f01011df:	74 16                	je     f01011f7 <tlb_invalidate+0x2d>
f01011e1:	e8 14 3d 00 00       	call   f0104efa <cpunum>
f01011e6:	6b c0 74             	imul   $0x74,%eax,%eax
f01011e9:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f01011ef:	8b 55 08             	mov    0x8(%ebp),%edx
f01011f2:	39 50 60             	cmp    %edx,0x60(%eax)
f01011f5:	75 06                	jne    f01011fd <tlb_invalidate+0x33>
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01011f7:	8b 45 0c             	mov    0xc(%ebp),%eax
f01011fa:	0f 01 38             	invlpg (%eax)
}
f01011fd:	c9                   	leave  
f01011fe:	c3                   	ret    

f01011ff <page_remove>:
{
f01011ff:	55                   	push   %ebp
f0101200:	89 e5                	mov    %esp,%ebp
f0101202:	56                   	push   %esi
f0101203:	53                   	push   %ebx
f0101204:	83 ec 14             	sub    $0x14,%esp
f0101207:	8b 5d 08             	mov    0x8(%ebp),%ebx
f010120a:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct PageInfo *pginfo = page_lookup(pgdir, va, pte_store);
f010120d:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101210:	50                   	push   %eax
f0101211:	56                   	push   %esi
f0101212:	53                   	push   %ebx
f0101213:	e8 56 ff ff ff       	call   f010116e <page_lookup>
	if (pginfo) {
f0101218:	83 c4 10             	add    $0x10,%esp
f010121b:	85 c0                	test   %eax,%eax
f010121d:	74 1f                	je     f010123e <page_remove+0x3f>
		page_decref(pginfo);
f010121f:	83 ec 0c             	sub    $0xc,%esp
f0101222:	50                   	push   %eax
f0101223:	e8 09 fe ff ff       	call   f0101031 <page_decref>
		*pte = 0;	 
f0101228:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010122b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		tlb_invalidate(pgdir, va);
f0101231:	83 c4 08             	add    $0x8,%esp
f0101234:	56                   	push   %esi
f0101235:	53                   	push   %ebx
f0101236:	e8 8f ff ff ff       	call   f01011ca <tlb_invalidate>
f010123b:	83 c4 10             	add    $0x10,%esp
}
f010123e:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101241:	5b                   	pop    %ebx
f0101242:	5e                   	pop    %esi
f0101243:	5d                   	pop    %ebp
f0101244:	c3                   	ret    

f0101245 <page_insert>:
{
f0101245:	55                   	push   %ebp
f0101246:	89 e5                	mov    %esp,%ebp
f0101248:	57                   	push   %edi
f0101249:	56                   	push   %esi
f010124a:	53                   	push   %ebx
f010124b:	83 ec 10             	sub    $0x10,%esp
f010124e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101251:	8b 7d 10             	mov    0x10(%ebp),%edi
	pte_t *pte = pgdir_walk(pgdir, va, 1);	
f0101254:	6a 01                	push   $0x1
f0101256:	57                   	push   %edi
f0101257:	ff 75 08             	pushl  0x8(%ebp)
f010125a:	e8 fb fd ff ff       	call   f010105a <pgdir_walk>
	if (!pte) {
f010125f:	83 c4 10             	add    $0x10,%esp
f0101262:	85 c0                	test   %eax,%eax
f0101264:	74 3e                	je     f01012a4 <page_insert+0x5f>
f0101266:	89 c6                	mov    %eax,%esi
	pp->pp_ref++;
f0101268:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
	if (*pte & PTE_P) {
f010126d:	f6 00 01             	testb  $0x1,(%eax)
f0101270:	75 21                	jne    f0101293 <page_insert+0x4e>
	return (pp - pages) << PGSHIFT;
f0101272:	2b 1d 10 1f 23 f0    	sub    0xf0231f10,%ebx
f0101278:	c1 fb 03             	sar    $0x3,%ebx
f010127b:	c1 e3 0c             	shl    $0xc,%ebx
	*pte = page2pa(pp) | perm | PTE_P;
f010127e:	0b 5d 14             	or     0x14(%ebp),%ebx
f0101281:	83 cb 01             	or     $0x1,%ebx
f0101284:	89 1e                	mov    %ebx,(%esi)
	return 0;
f0101286:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010128b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010128e:	5b                   	pop    %ebx
f010128f:	5e                   	pop    %esi
f0101290:	5f                   	pop    %edi
f0101291:	5d                   	pop    %ebp
f0101292:	c3                   	ret    
		 page_remove(pgdir, va);
f0101293:	83 ec 08             	sub    $0x8,%esp
f0101296:	57                   	push   %edi
f0101297:	ff 75 08             	pushl  0x8(%ebp)
f010129a:	e8 60 ff ff ff       	call   f01011ff <page_remove>
f010129f:	83 c4 10             	add    $0x10,%esp
f01012a2:	eb ce                	jmp    f0101272 <page_insert+0x2d>
		 return -E_NO_MEM;
f01012a4:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01012a9:	eb e0                	jmp    f010128b <page_insert+0x46>

f01012ab <mmio_map_region>:
{
f01012ab:	55                   	push   %ebp
f01012ac:	89 e5                	mov    %esp,%ebp
f01012ae:	53                   	push   %ebx
f01012af:	83 ec 04             	sub    $0x4,%esp
    size_t rounded_size = ROUNDUP(size, PGSIZE);
f01012b2:	8b 45 0c             	mov    0xc(%ebp),%eax
f01012b5:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
f01012bb:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    if (base + rounded_size > MMIOLIM) panic("memory overflow ");
f01012c1:	8b 15 00 13 12 f0    	mov    0xf0121300,%edx
f01012c7:	8d 04 1a             	lea    (%edx,%ebx,1),%eax
f01012ca:	3d 00 00 c0 ef       	cmp    $0xefc00000,%eax
f01012cf:	77 26                	ja     f01012f7 <mmio_map_region+0x4c>
    boot_map_region(kern_pgdir, base, rounded_size, pa, PTE_W|PTE_PCD|PTE_PWT);
f01012d1:	83 ec 08             	sub    $0x8,%esp
f01012d4:	6a 1a                	push   $0x1a
f01012d6:	ff 75 08             	pushl  0x8(%ebp)
f01012d9:	89 d9                	mov    %ebx,%ecx
f01012db:	a1 0c 1f 23 f0       	mov    0xf0231f0c,%eax
f01012e0:	e8 35 fe ff ff       	call   f010111a <boot_map_region>
    uintptr_t return_base = base;
f01012e5:	a1 00 13 12 f0       	mov    0xf0121300,%eax
    base += rounded_size;
f01012ea:	01 c3                	add    %eax,%ebx
f01012ec:	89 1d 00 13 12 f0    	mov    %ebx,0xf0121300
}
f01012f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01012f5:	c9                   	leave  
f01012f6:	c3                   	ret    
    if (base + rounded_size > MMIOLIM) panic("memory overflow ");
f01012f7:	83 ec 04             	sub    $0x4,%esp
f01012fa:	68 d1 65 10 f0       	push   $0xf01065d1
f01012ff:	68 7e 02 00 00       	push   $0x27e
f0101304:	68 bd 64 10 f0       	push   $0xf01064bd
f0101309:	e8 86 ed ff ff       	call   f0100094 <_panic>

f010130e <mem_init>:
{
f010130e:	55                   	push   %ebp
f010130f:	89 e5                	mov    %esp,%ebp
f0101311:	57                   	push   %edi
f0101312:	56                   	push   %esi
f0101313:	53                   	push   %ebx
f0101314:	83 ec 3c             	sub    $0x3c,%esp
	basemem = nvram_read(NVRAM_BASELO);
f0101317:	b8 15 00 00 00       	mov    $0x15,%eax
f010131c:	e8 98 f7 ff ff       	call   f0100ab9 <nvram_read>
f0101321:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f0101323:	b8 17 00 00 00       	mov    $0x17,%eax
f0101328:	e8 8c f7 ff ff       	call   f0100ab9 <nvram_read>
f010132d:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f010132f:	b8 34 00 00 00       	mov    $0x34,%eax
f0101334:	e8 80 f7 ff ff       	call   f0100ab9 <nvram_read>
	if (ext16mem)
f0101339:	c1 e0 06             	shl    $0x6,%eax
f010133c:	0f 84 ea 00 00 00    	je     f010142c <mem_init+0x11e>
		totalmem = 16 * 1024 + ext16mem;
f0101342:	05 00 40 00 00       	add    $0x4000,%eax
	npages = totalmem / (PGSIZE / 1024);
f0101347:	89 c2                	mov    %eax,%edx
f0101349:	c1 ea 02             	shr    $0x2,%edx
f010134c:	89 15 08 1f 23 f0    	mov    %edx,0xf0231f08
	npages_basemem = basemem / (PGSIZE / 1024);
f0101352:	89 da                	mov    %ebx,%edx
f0101354:	c1 ea 02             	shr    $0x2,%edx
f0101357:	89 15 40 12 23 f0    	mov    %edx,0xf0231240
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010135d:	89 c2                	mov    %eax,%edx
f010135f:	29 da                	sub    %ebx,%edx
f0101361:	52                   	push   %edx
f0101362:	53                   	push   %ebx
f0101363:	50                   	push   %eax
f0101364:	68 64 5c 10 f0       	push   $0xf0105c64
f0101369:	e8 97 24 00 00       	call   f0103805 <cprintf>
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f010136e:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101373:	e8 0b f7 ff ff       	call   f0100a83 <boot_alloc>
f0101378:	a3 0c 1f 23 f0       	mov    %eax,0xf0231f0c
	memset(kern_pgdir, 0, PGSIZE);
f010137d:	83 c4 0c             	add    $0xc,%esp
f0101380:	68 00 10 00 00       	push   $0x1000
f0101385:	6a 00                	push   $0x0
f0101387:	50                   	push   %eax
f0101388:	e8 6d 35 00 00       	call   f01048fa <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f010138d:	a1 0c 1f 23 f0       	mov    0xf0231f0c,%eax
	if ((uint32_t)kva < KERNBASE)
f0101392:	83 c4 10             	add    $0x10,%esp
f0101395:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010139a:	0f 86 9c 00 00 00    	jbe    f010143c <mem_init+0x12e>
	return (physaddr_t)kva - KERNBASE;
f01013a0:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01013a6:	83 ca 05             	or     $0x5,%edx
f01013a9:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	pages = (struct PageInfo*) boot_alloc(npages * sizeof(struct PageInfo));
f01013af:	a1 08 1f 23 f0       	mov    0xf0231f08,%eax
f01013b4:	c1 e0 03             	shl    $0x3,%eax
f01013b7:	e8 c7 f6 ff ff       	call   f0100a83 <boot_alloc>
f01013bc:	a3 10 1f 23 f0       	mov    %eax,0xf0231f10
	memset(pages, 0, npages * sizeof(struct PageInfo));
f01013c1:	83 ec 04             	sub    $0x4,%esp
f01013c4:	8b 0d 08 1f 23 f0    	mov    0xf0231f08,%ecx
f01013ca:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f01013d1:	52                   	push   %edx
f01013d2:	6a 00                	push   $0x0
f01013d4:	50                   	push   %eax
f01013d5:	e8 20 35 00 00       	call   f01048fa <memset>
	envs = (struct Env*) boot_alloc(NENV * sizeof(struct Env));
f01013da:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f01013df:	e8 9f f6 ff ff       	call   f0100a83 <boot_alloc>
f01013e4:	a3 44 12 23 f0       	mov    %eax,0xf0231244
	memset(envs, 0, NENV * sizeof(struct Env));
f01013e9:	83 c4 0c             	add    $0xc,%esp
f01013ec:	68 00 f0 01 00       	push   $0x1f000
f01013f1:	6a 00                	push   $0x0
f01013f3:	50                   	push   %eax
f01013f4:	e8 01 35 00 00       	call   f01048fa <memset>
	page_init();
f01013f9:	e8 74 fa ff ff       	call   f0100e72 <page_init>
	check_page_free_list(1);
f01013fe:	b8 01 00 00 00       	mov    $0x1,%eax
f0101403:	e8 3e f7 ff ff       	call   f0100b46 <check_page_free_list>
	if (!pages)
f0101408:	83 c4 10             	add    $0x10,%esp
f010140b:	83 3d 10 1f 23 f0 00 	cmpl   $0x0,0xf0231f10
f0101412:	74 3d                	je     f0101451 <mem_init+0x143>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101414:	a1 3c 12 23 f0       	mov    0xf023123c,%eax
f0101419:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f0101420:	85 c0                	test   %eax,%eax
f0101422:	74 44                	je     f0101468 <mem_init+0x15a>
		++nfree;
f0101424:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101428:	8b 00                	mov    (%eax),%eax
f010142a:	eb f4                	jmp    f0101420 <mem_init+0x112>
		totalmem = 1 * 1024 + extmem;
f010142c:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f0101432:	85 f6                	test   %esi,%esi
f0101434:	0f 44 c3             	cmove  %ebx,%eax
f0101437:	e9 0b ff ff ff       	jmp    f0101347 <mem_init+0x39>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010143c:	50                   	push   %eax
f010143d:	68 18 56 10 f0       	push   $0xf0105618
f0101442:	68 a3 00 00 00       	push   $0xa3
f0101447:	68 bd 64 10 f0       	push   $0xf01064bd
f010144c:	e8 43 ec ff ff       	call   f0100094 <_panic>
		panic("'pages' is a null pointer!");
f0101451:	83 ec 04             	sub    $0x4,%esp
f0101454:	68 e2 65 10 f0       	push   $0xf01065e2
f0101459:	68 0c 03 00 00       	push   $0x30c
f010145e:	68 bd 64 10 f0       	push   $0xf01064bd
f0101463:	e8 2c ec ff ff       	call   f0100094 <_panic>
	assert((pp0 = page_alloc(0)));
f0101468:	83 ec 0c             	sub    $0xc,%esp
f010146b:	6a 00                	push   $0x0
f010146d:	e8 12 fb ff ff       	call   f0100f84 <page_alloc>
f0101472:	89 c3                	mov    %eax,%ebx
f0101474:	83 c4 10             	add    $0x10,%esp
f0101477:	85 c0                	test   %eax,%eax
f0101479:	0f 84 00 02 00 00    	je     f010167f <mem_init+0x371>
	assert((pp1 = page_alloc(0)));
f010147f:	83 ec 0c             	sub    $0xc,%esp
f0101482:	6a 00                	push   $0x0
f0101484:	e8 fb fa ff ff       	call   f0100f84 <page_alloc>
f0101489:	89 c6                	mov    %eax,%esi
f010148b:	83 c4 10             	add    $0x10,%esp
f010148e:	85 c0                	test   %eax,%eax
f0101490:	0f 84 02 02 00 00    	je     f0101698 <mem_init+0x38a>
	assert((pp2 = page_alloc(0)));
f0101496:	83 ec 0c             	sub    $0xc,%esp
f0101499:	6a 00                	push   $0x0
f010149b:	e8 e4 fa ff ff       	call   f0100f84 <page_alloc>
f01014a0:	89 c7                	mov    %eax,%edi
f01014a2:	83 c4 10             	add    $0x10,%esp
f01014a5:	85 c0                	test   %eax,%eax
f01014a7:	0f 84 04 02 00 00    	je     f01016b1 <mem_init+0x3a3>
	assert(pp1 && pp1 != pp0);
f01014ad:	39 f3                	cmp    %esi,%ebx
f01014af:	0f 84 15 02 00 00    	je     f01016ca <mem_init+0x3bc>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01014b5:	39 c6                	cmp    %eax,%esi
f01014b7:	0f 84 26 02 00 00    	je     f01016e3 <mem_init+0x3d5>
f01014bd:	39 c3                	cmp    %eax,%ebx
f01014bf:	0f 84 1e 02 00 00    	je     f01016e3 <mem_init+0x3d5>
	return (pp - pages) << PGSHIFT;
f01014c5:	8b 0d 10 1f 23 f0    	mov    0xf0231f10,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f01014cb:	8b 15 08 1f 23 f0    	mov    0xf0231f08,%edx
f01014d1:	c1 e2 0c             	shl    $0xc,%edx
f01014d4:	89 d8                	mov    %ebx,%eax
f01014d6:	29 c8                	sub    %ecx,%eax
f01014d8:	c1 f8 03             	sar    $0x3,%eax
f01014db:	c1 e0 0c             	shl    $0xc,%eax
f01014de:	39 d0                	cmp    %edx,%eax
f01014e0:	0f 83 16 02 00 00    	jae    f01016fc <mem_init+0x3ee>
f01014e6:	89 f0                	mov    %esi,%eax
f01014e8:	29 c8                	sub    %ecx,%eax
f01014ea:	c1 f8 03             	sar    $0x3,%eax
f01014ed:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp1) < npages*PGSIZE);
f01014f0:	39 c2                	cmp    %eax,%edx
f01014f2:	0f 86 1d 02 00 00    	jbe    f0101715 <mem_init+0x407>
f01014f8:	89 f8                	mov    %edi,%eax
f01014fa:	29 c8                	sub    %ecx,%eax
f01014fc:	c1 f8 03             	sar    $0x3,%eax
f01014ff:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp2) < npages*PGSIZE);
f0101502:	39 c2                	cmp    %eax,%edx
f0101504:	0f 86 24 02 00 00    	jbe    f010172e <mem_init+0x420>
	fl = page_free_list;
f010150a:	a1 3c 12 23 f0       	mov    0xf023123c,%eax
f010150f:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101512:	c7 05 3c 12 23 f0 00 	movl   $0x0,0xf023123c
f0101519:	00 00 00 
	assert(!page_alloc(0));
f010151c:	83 ec 0c             	sub    $0xc,%esp
f010151f:	6a 00                	push   $0x0
f0101521:	e8 5e fa ff ff       	call   f0100f84 <page_alloc>
f0101526:	83 c4 10             	add    $0x10,%esp
f0101529:	85 c0                	test   %eax,%eax
f010152b:	0f 85 16 02 00 00    	jne    f0101747 <mem_init+0x439>
	page_free(pp0);
f0101531:	83 ec 0c             	sub    $0xc,%esp
f0101534:	53                   	push   %ebx
f0101535:	e8 bc fa ff ff       	call   f0100ff6 <page_free>
	page_free(pp1);
f010153a:	89 34 24             	mov    %esi,(%esp)
f010153d:	e8 b4 fa ff ff       	call   f0100ff6 <page_free>
	page_free(pp2);
f0101542:	89 3c 24             	mov    %edi,(%esp)
f0101545:	e8 ac fa ff ff       	call   f0100ff6 <page_free>
	assert((pp0 = page_alloc(0)));
f010154a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101551:	e8 2e fa ff ff       	call   f0100f84 <page_alloc>
f0101556:	89 c3                	mov    %eax,%ebx
f0101558:	83 c4 10             	add    $0x10,%esp
f010155b:	85 c0                	test   %eax,%eax
f010155d:	0f 84 fd 01 00 00    	je     f0101760 <mem_init+0x452>
	assert((pp1 = page_alloc(0)));
f0101563:	83 ec 0c             	sub    $0xc,%esp
f0101566:	6a 00                	push   $0x0
f0101568:	e8 17 fa ff ff       	call   f0100f84 <page_alloc>
f010156d:	89 c6                	mov    %eax,%esi
f010156f:	83 c4 10             	add    $0x10,%esp
f0101572:	85 c0                	test   %eax,%eax
f0101574:	0f 84 ff 01 00 00    	je     f0101779 <mem_init+0x46b>
	assert((pp2 = page_alloc(0)));
f010157a:	83 ec 0c             	sub    $0xc,%esp
f010157d:	6a 00                	push   $0x0
f010157f:	e8 00 fa ff ff       	call   f0100f84 <page_alloc>
f0101584:	89 c7                	mov    %eax,%edi
f0101586:	83 c4 10             	add    $0x10,%esp
f0101589:	85 c0                	test   %eax,%eax
f010158b:	0f 84 01 02 00 00    	je     f0101792 <mem_init+0x484>
	assert(pp1 && pp1 != pp0);
f0101591:	39 f3                	cmp    %esi,%ebx
f0101593:	0f 84 12 02 00 00    	je     f01017ab <mem_init+0x49d>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101599:	39 c6                	cmp    %eax,%esi
f010159b:	0f 84 23 02 00 00    	je     f01017c4 <mem_init+0x4b6>
f01015a1:	39 c3                	cmp    %eax,%ebx
f01015a3:	0f 84 1b 02 00 00    	je     f01017c4 <mem_init+0x4b6>
	assert(!page_alloc(0));
f01015a9:	83 ec 0c             	sub    $0xc,%esp
f01015ac:	6a 00                	push   $0x0
f01015ae:	e8 d1 f9 ff ff       	call   f0100f84 <page_alloc>
f01015b3:	83 c4 10             	add    $0x10,%esp
f01015b6:	85 c0                	test   %eax,%eax
f01015b8:	0f 85 1f 02 00 00    	jne    f01017dd <mem_init+0x4cf>
f01015be:	89 d8                	mov    %ebx,%eax
f01015c0:	2b 05 10 1f 23 f0    	sub    0xf0231f10,%eax
f01015c6:	c1 f8 03             	sar    $0x3,%eax
f01015c9:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f01015cc:	89 c2                	mov    %eax,%edx
f01015ce:	c1 ea 0c             	shr    $0xc,%edx
f01015d1:	3b 15 08 1f 23 f0    	cmp    0xf0231f08,%edx
f01015d7:	0f 83 19 02 00 00    	jae    f01017f6 <mem_init+0x4e8>
	memset(page2kva(pp0), 1, PGSIZE);
f01015dd:	83 ec 04             	sub    $0x4,%esp
f01015e0:	68 00 10 00 00       	push   $0x1000
f01015e5:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f01015e7:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01015ec:	50                   	push   %eax
f01015ed:	e8 08 33 00 00       	call   f01048fa <memset>
	page_free(pp0);
f01015f2:	89 1c 24             	mov    %ebx,(%esp)
f01015f5:	e8 fc f9 ff ff       	call   f0100ff6 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01015fa:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101601:	e8 7e f9 ff ff       	call   f0100f84 <page_alloc>
f0101606:	83 c4 10             	add    $0x10,%esp
f0101609:	85 c0                	test   %eax,%eax
f010160b:	0f 84 f7 01 00 00    	je     f0101808 <mem_init+0x4fa>
	assert(pp && pp0 == pp);
f0101611:	39 c3                	cmp    %eax,%ebx
f0101613:	0f 85 08 02 00 00    	jne    f0101821 <mem_init+0x513>
	return (pp - pages) << PGSHIFT;
f0101619:	2b 05 10 1f 23 f0    	sub    0xf0231f10,%eax
f010161f:	c1 f8 03             	sar    $0x3,%eax
f0101622:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0101625:	89 c2                	mov    %eax,%edx
f0101627:	c1 ea 0c             	shr    $0xc,%edx
f010162a:	3b 15 08 1f 23 f0    	cmp    0xf0231f08,%edx
f0101630:	0f 83 04 02 00 00    	jae    f010183a <mem_init+0x52c>
	return (void *)(pa + KERNBASE);
f0101636:	8d 90 00 00 00 f0    	lea    -0x10000000(%eax),%edx
f010163c:	2d 00 f0 ff 0f       	sub    $0xffff000,%eax
		assert(c[i] == 0);
f0101641:	80 3a 00             	cmpb   $0x0,(%edx)
f0101644:	0f 85 02 02 00 00    	jne    f010184c <mem_init+0x53e>
f010164a:	83 c2 01             	add    $0x1,%edx
	for (i = 0; i < PGSIZE; i++)
f010164d:	39 c2                	cmp    %eax,%edx
f010164f:	75 f0                	jne    f0101641 <mem_init+0x333>
	page_free_list = fl;
f0101651:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101654:	a3 3c 12 23 f0       	mov    %eax,0xf023123c
	page_free(pp0);
f0101659:	83 ec 0c             	sub    $0xc,%esp
f010165c:	53                   	push   %ebx
f010165d:	e8 94 f9 ff ff       	call   f0100ff6 <page_free>
	page_free(pp1);
f0101662:	89 34 24             	mov    %esi,(%esp)
f0101665:	e8 8c f9 ff ff       	call   f0100ff6 <page_free>
	page_free(pp2);
f010166a:	89 3c 24             	mov    %edi,(%esp)
f010166d:	e8 84 f9 ff ff       	call   f0100ff6 <page_free>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101672:	a1 3c 12 23 f0       	mov    0xf023123c,%eax
f0101677:	83 c4 10             	add    $0x10,%esp
f010167a:	e9 ec 01 00 00       	jmp    f010186b <mem_init+0x55d>
	assert((pp0 = page_alloc(0)));
f010167f:	68 fd 65 10 f0       	push   $0xf01065fd
f0101684:	68 e9 64 10 f0       	push   $0xf01064e9
f0101689:	68 14 03 00 00       	push   $0x314
f010168e:	68 bd 64 10 f0       	push   $0xf01064bd
f0101693:	e8 fc e9 ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f0101698:	68 13 66 10 f0       	push   $0xf0106613
f010169d:	68 e9 64 10 f0       	push   $0xf01064e9
f01016a2:	68 15 03 00 00       	push   $0x315
f01016a7:	68 bd 64 10 f0       	push   $0xf01064bd
f01016ac:	e8 e3 e9 ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f01016b1:	68 29 66 10 f0       	push   $0xf0106629
f01016b6:	68 e9 64 10 f0       	push   $0xf01064e9
f01016bb:	68 16 03 00 00       	push   $0x316
f01016c0:	68 bd 64 10 f0       	push   $0xf01064bd
f01016c5:	e8 ca e9 ff ff       	call   f0100094 <_panic>
	assert(pp1 && pp1 != pp0);
f01016ca:	68 3f 66 10 f0       	push   $0xf010663f
f01016cf:	68 e9 64 10 f0       	push   $0xf01064e9
f01016d4:	68 19 03 00 00       	push   $0x319
f01016d9:	68 bd 64 10 f0       	push   $0xf01064bd
f01016de:	e8 b1 e9 ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01016e3:	68 a0 5c 10 f0       	push   $0xf0105ca0
f01016e8:	68 e9 64 10 f0       	push   $0xf01064e9
f01016ed:	68 1a 03 00 00       	push   $0x31a
f01016f2:	68 bd 64 10 f0       	push   $0xf01064bd
f01016f7:	e8 98 e9 ff ff       	call   f0100094 <_panic>
	assert(page2pa(pp0) < npages*PGSIZE);
f01016fc:	68 51 66 10 f0       	push   $0xf0106651
f0101701:	68 e9 64 10 f0       	push   $0xf01064e9
f0101706:	68 1b 03 00 00       	push   $0x31b
f010170b:	68 bd 64 10 f0       	push   $0xf01064bd
f0101710:	e8 7f e9 ff ff       	call   f0100094 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0101715:	68 6e 66 10 f0       	push   $0xf010666e
f010171a:	68 e9 64 10 f0       	push   $0xf01064e9
f010171f:	68 1c 03 00 00       	push   $0x31c
f0101724:	68 bd 64 10 f0       	push   $0xf01064bd
f0101729:	e8 66 e9 ff ff       	call   f0100094 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f010172e:	68 8b 66 10 f0       	push   $0xf010668b
f0101733:	68 e9 64 10 f0       	push   $0xf01064e9
f0101738:	68 1d 03 00 00       	push   $0x31d
f010173d:	68 bd 64 10 f0       	push   $0xf01064bd
f0101742:	e8 4d e9 ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f0101747:	68 a8 66 10 f0       	push   $0xf01066a8
f010174c:	68 e9 64 10 f0       	push   $0xf01064e9
f0101751:	68 24 03 00 00       	push   $0x324
f0101756:	68 bd 64 10 f0       	push   $0xf01064bd
f010175b:	e8 34 e9 ff ff       	call   f0100094 <_panic>
	assert((pp0 = page_alloc(0)));
f0101760:	68 fd 65 10 f0       	push   $0xf01065fd
f0101765:	68 e9 64 10 f0       	push   $0xf01064e9
f010176a:	68 2b 03 00 00       	push   $0x32b
f010176f:	68 bd 64 10 f0       	push   $0xf01064bd
f0101774:	e8 1b e9 ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f0101779:	68 13 66 10 f0       	push   $0xf0106613
f010177e:	68 e9 64 10 f0       	push   $0xf01064e9
f0101783:	68 2c 03 00 00       	push   $0x32c
f0101788:	68 bd 64 10 f0       	push   $0xf01064bd
f010178d:	e8 02 e9 ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f0101792:	68 29 66 10 f0       	push   $0xf0106629
f0101797:	68 e9 64 10 f0       	push   $0xf01064e9
f010179c:	68 2d 03 00 00       	push   $0x32d
f01017a1:	68 bd 64 10 f0       	push   $0xf01064bd
f01017a6:	e8 e9 e8 ff ff       	call   f0100094 <_panic>
	assert(pp1 && pp1 != pp0);
f01017ab:	68 3f 66 10 f0       	push   $0xf010663f
f01017b0:	68 e9 64 10 f0       	push   $0xf01064e9
f01017b5:	68 2f 03 00 00       	push   $0x32f
f01017ba:	68 bd 64 10 f0       	push   $0xf01064bd
f01017bf:	e8 d0 e8 ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01017c4:	68 a0 5c 10 f0       	push   $0xf0105ca0
f01017c9:	68 e9 64 10 f0       	push   $0xf01064e9
f01017ce:	68 30 03 00 00       	push   $0x330
f01017d3:	68 bd 64 10 f0       	push   $0xf01064bd
f01017d8:	e8 b7 e8 ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f01017dd:	68 a8 66 10 f0       	push   $0xf01066a8
f01017e2:	68 e9 64 10 f0       	push   $0xf01064e9
f01017e7:	68 31 03 00 00       	push   $0x331
f01017ec:	68 bd 64 10 f0       	push   $0xf01064bd
f01017f1:	e8 9e e8 ff ff       	call   f0100094 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01017f6:	50                   	push   %eax
f01017f7:	68 f4 55 10 f0       	push   $0xf01055f4
f01017fc:	6a 58                	push   $0x58
f01017fe:	68 cf 64 10 f0       	push   $0xf01064cf
f0101803:	e8 8c e8 ff ff       	call   f0100094 <_panic>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101808:	68 b7 66 10 f0       	push   $0xf01066b7
f010180d:	68 e9 64 10 f0       	push   $0xf01064e9
f0101812:	68 36 03 00 00       	push   $0x336
f0101817:	68 bd 64 10 f0       	push   $0xf01064bd
f010181c:	e8 73 e8 ff ff       	call   f0100094 <_panic>
	assert(pp && pp0 == pp);
f0101821:	68 d5 66 10 f0       	push   $0xf01066d5
f0101826:	68 e9 64 10 f0       	push   $0xf01064e9
f010182b:	68 37 03 00 00       	push   $0x337
f0101830:	68 bd 64 10 f0       	push   $0xf01064bd
f0101835:	e8 5a e8 ff ff       	call   f0100094 <_panic>
f010183a:	50                   	push   %eax
f010183b:	68 f4 55 10 f0       	push   $0xf01055f4
f0101840:	6a 58                	push   $0x58
f0101842:	68 cf 64 10 f0       	push   $0xf01064cf
f0101847:	e8 48 e8 ff ff       	call   f0100094 <_panic>
		assert(c[i] == 0);
f010184c:	68 e5 66 10 f0       	push   $0xf01066e5
f0101851:	68 e9 64 10 f0       	push   $0xf01064e9
f0101856:	68 3a 03 00 00       	push   $0x33a
f010185b:	68 bd 64 10 f0       	push   $0xf01064bd
f0101860:	e8 2f e8 ff ff       	call   f0100094 <_panic>
		--nfree;
f0101865:	83 6d d4 01          	subl   $0x1,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101869:	8b 00                	mov    (%eax),%eax
f010186b:	85 c0                	test   %eax,%eax
f010186d:	75 f6                	jne    f0101865 <mem_init+0x557>
	assert(nfree == 0);
f010186f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0101873:	0f 85 14 09 00 00    	jne    f010218d <mem_init+0xe7f>
	cprintf("check_page_alloc() succeeded!\n");
f0101879:	83 ec 0c             	sub    $0xc,%esp
f010187c:	68 c0 5c 10 f0       	push   $0xf0105cc0
f0101881:	e8 7f 1f 00 00       	call   f0103805 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101886:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010188d:	e8 f2 f6 ff ff       	call   f0100f84 <page_alloc>
f0101892:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101895:	83 c4 10             	add    $0x10,%esp
f0101898:	85 c0                	test   %eax,%eax
f010189a:	0f 84 06 09 00 00    	je     f01021a6 <mem_init+0xe98>
	assert((pp1 = page_alloc(0)));
f01018a0:	83 ec 0c             	sub    $0xc,%esp
f01018a3:	6a 00                	push   $0x0
f01018a5:	e8 da f6 ff ff       	call   f0100f84 <page_alloc>
f01018aa:	89 c7                	mov    %eax,%edi
f01018ac:	83 c4 10             	add    $0x10,%esp
f01018af:	85 c0                	test   %eax,%eax
f01018b1:	0f 84 08 09 00 00    	je     f01021bf <mem_init+0xeb1>
	assert((pp2 = page_alloc(0)));
f01018b7:	83 ec 0c             	sub    $0xc,%esp
f01018ba:	6a 00                	push   $0x0
f01018bc:	e8 c3 f6 ff ff       	call   f0100f84 <page_alloc>
f01018c1:	89 c3                	mov    %eax,%ebx
f01018c3:	83 c4 10             	add    $0x10,%esp
f01018c6:	85 c0                	test   %eax,%eax
f01018c8:	0f 84 0a 09 00 00    	je     f01021d8 <mem_init+0xeca>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01018ce:	39 7d d4             	cmp    %edi,-0x2c(%ebp)
f01018d1:	0f 84 1a 09 00 00    	je     f01021f1 <mem_init+0xee3>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01018d7:	39 c7                	cmp    %eax,%edi
f01018d9:	0f 84 2b 09 00 00    	je     f010220a <mem_init+0xefc>
f01018df:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f01018e2:	0f 84 22 09 00 00    	je     f010220a <mem_init+0xefc>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01018e8:	a1 3c 12 23 f0       	mov    0xf023123c,%eax
f01018ed:	89 45 cc             	mov    %eax,-0x34(%ebp)
	page_free_list = 0;
f01018f0:	c7 05 3c 12 23 f0 00 	movl   $0x0,0xf023123c
f01018f7:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01018fa:	83 ec 0c             	sub    $0xc,%esp
f01018fd:	6a 00                	push   $0x0
f01018ff:	e8 80 f6 ff ff       	call   f0100f84 <page_alloc>
f0101904:	83 c4 10             	add    $0x10,%esp
f0101907:	85 c0                	test   %eax,%eax
f0101909:	0f 85 14 09 00 00    	jne    f0102223 <mem_init+0xf15>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f010190f:	83 ec 04             	sub    $0x4,%esp
f0101912:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101915:	50                   	push   %eax
f0101916:	6a 00                	push   $0x0
f0101918:	ff 35 0c 1f 23 f0    	pushl  0xf0231f0c
f010191e:	e8 4b f8 ff ff       	call   f010116e <page_lookup>
f0101923:	83 c4 10             	add    $0x10,%esp
f0101926:	85 c0                	test   %eax,%eax
f0101928:	0f 85 0e 09 00 00    	jne    f010223c <mem_init+0xf2e>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f010192e:	6a 02                	push   $0x2
f0101930:	6a 00                	push   $0x0
f0101932:	57                   	push   %edi
f0101933:	ff 35 0c 1f 23 f0    	pushl  0xf0231f0c
f0101939:	e8 07 f9 ff ff       	call   f0101245 <page_insert>
f010193e:	83 c4 10             	add    $0x10,%esp
f0101941:	85 c0                	test   %eax,%eax
f0101943:	0f 89 0c 09 00 00    	jns    f0102255 <mem_init+0xf47>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101949:	83 ec 0c             	sub    $0xc,%esp
f010194c:	ff 75 d4             	pushl  -0x2c(%ebp)
f010194f:	e8 a2 f6 ff ff       	call   f0100ff6 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101954:	6a 02                	push   $0x2
f0101956:	6a 00                	push   $0x0
f0101958:	57                   	push   %edi
f0101959:	ff 35 0c 1f 23 f0    	pushl  0xf0231f0c
f010195f:	e8 e1 f8 ff ff       	call   f0101245 <page_insert>
f0101964:	83 c4 20             	add    $0x20,%esp
f0101967:	85 c0                	test   %eax,%eax
f0101969:	0f 85 ff 08 00 00    	jne    f010226e <mem_init+0xf60>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010196f:	8b 35 0c 1f 23 f0    	mov    0xf0231f0c,%esi
	return (pp - pages) << PGSHIFT;
f0101975:	8b 0d 10 1f 23 f0    	mov    0xf0231f10,%ecx
f010197b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f010197e:	8b 16                	mov    (%esi),%edx
f0101980:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101986:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101989:	29 c8                	sub    %ecx,%eax
f010198b:	c1 f8 03             	sar    $0x3,%eax
f010198e:	c1 e0 0c             	shl    $0xc,%eax
f0101991:	39 c2                	cmp    %eax,%edx
f0101993:	0f 85 ee 08 00 00    	jne    f0102287 <mem_init+0xf79>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101999:	ba 00 00 00 00       	mov    $0x0,%edx
f010199e:	89 f0                	mov    %esi,%eax
f01019a0:	e8 3d f1 ff ff       	call   f0100ae2 <check_va2pa>
f01019a5:	89 fa                	mov    %edi,%edx
f01019a7:	2b 55 d0             	sub    -0x30(%ebp),%edx
f01019aa:	c1 fa 03             	sar    $0x3,%edx
f01019ad:	c1 e2 0c             	shl    $0xc,%edx
f01019b0:	39 d0                	cmp    %edx,%eax
f01019b2:	0f 85 e8 08 00 00    	jne    f01022a0 <mem_init+0xf92>
	assert(pp1->pp_ref == 1);
f01019b8:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01019bd:	0f 85 f6 08 00 00    	jne    f01022b9 <mem_init+0xfab>
	assert(pp0->pp_ref == 1);
f01019c3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01019c6:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f01019cb:	0f 85 01 09 00 00    	jne    f01022d2 <mem_init+0xfc4>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01019d1:	6a 02                	push   $0x2
f01019d3:	68 00 10 00 00       	push   $0x1000
f01019d8:	53                   	push   %ebx
f01019d9:	56                   	push   %esi
f01019da:	e8 66 f8 ff ff       	call   f0101245 <page_insert>
f01019df:	83 c4 10             	add    $0x10,%esp
f01019e2:	85 c0                	test   %eax,%eax
f01019e4:	0f 85 01 09 00 00    	jne    f01022eb <mem_init+0xfdd>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01019ea:	ba 00 10 00 00       	mov    $0x1000,%edx
f01019ef:	a1 0c 1f 23 f0       	mov    0xf0231f0c,%eax
f01019f4:	e8 e9 f0 ff ff       	call   f0100ae2 <check_va2pa>
f01019f9:	89 da                	mov    %ebx,%edx
f01019fb:	2b 15 10 1f 23 f0    	sub    0xf0231f10,%edx
f0101a01:	c1 fa 03             	sar    $0x3,%edx
f0101a04:	c1 e2 0c             	shl    $0xc,%edx
f0101a07:	39 d0                	cmp    %edx,%eax
f0101a09:	0f 85 f5 08 00 00    	jne    f0102304 <mem_init+0xff6>
	assert(pp2->pp_ref == 1);
f0101a0f:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101a14:	0f 85 03 09 00 00    	jne    f010231d <mem_init+0x100f>

	// should be no free memory
	assert(!page_alloc(0));
f0101a1a:	83 ec 0c             	sub    $0xc,%esp
f0101a1d:	6a 00                	push   $0x0
f0101a1f:	e8 60 f5 ff ff       	call   f0100f84 <page_alloc>
f0101a24:	83 c4 10             	add    $0x10,%esp
f0101a27:	85 c0                	test   %eax,%eax
f0101a29:	0f 85 07 09 00 00    	jne    f0102336 <mem_init+0x1028>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101a2f:	6a 02                	push   $0x2
f0101a31:	68 00 10 00 00       	push   $0x1000
f0101a36:	53                   	push   %ebx
f0101a37:	ff 35 0c 1f 23 f0    	pushl  0xf0231f0c
f0101a3d:	e8 03 f8 ff ff       	call   f0101245 <page_insert>
f0101a42:	83 c4 10             	add    $0x10,%esp
f0101a45:	85 c0                	test   %eax,%eax
f0101a47:	0f 85 02 09 00 00    	jne    f010234f <mem_init+0x1041>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101a4d:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101a52:	a1 0c 1f 23 f0       	mov    0xf0231f0c,%eax
f0101a57:	e8 86 f0 ff ff       	call   f0100ae2 <check_va2pa>
f0101a5c:	89 da                	mov    %ebx,%edx
f0101a5e:	2b 15 10 1f 23 f0    	sub    0xf0231f10,%edx
f0101a64:	c1 fa 03             	sar    $0x3,%edx
f0101a67:	c1 e2 0c             	shl    $0xc,%edx
f0101a6a:	39 d0                	cmp    %edx,%eax
f0101a6c:	0f 85 f6 08 00 00    	jne    f0102368 <mem_init+0x105a>
	assert(pp2->pp_ref == 1);
f0101a72:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101a77:	0f 85 04 09 00 00    	jne    f0102381 <mem_init+0x1073>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101a7d:	83 ec 0c             	sub    $0xc,%esp
f0101a80:	6a 00                	push   $0x0
f0101a82:	e8 fd f4 ff ff       	call   f0100f84 <page_alloc>
f0101a87:	83 c4 10             	add    $0x10,%esp
f0101a8a:	85 c0                	test   %eax,%eax
f0101a8c:	0f 85 08 09 00 00    	jne    f010239a <mem_init+0x108c>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101a92:	8b 15 0c 1f 23 f0    	mov    0xf0231f0c,%edx
f0101a98:	8b 02                	mov    (%edx),%eax
f0101a9a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0101a9f:	89 c1                	mov    %eax,%ecx
f0101aa1:	c1 e9 0c             	shr    $0xc,%ecx
f0101aa4:	3b 0d 08 1f 23 f0    	cmp    0xf0231f08,%ecx
f0101aaa:	0f 83 03 09 00 00    	jae    f01023b3 <mem_init+0x10a5>
	return (void *)(pa + KERNBASE);
f0101ab0:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101ab5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101ab8:	83 ec 04             	sub    $0x4,%esp
f0101abb:	6a 00                	push   $0x0
f0101abd:	68 00 10 00 00       	push   $0x1000
f0101ac2:	52                   	push   %edx
f0101ac3:	e8 92 f5 ff ff       	call   f010105a <pgdir_walk>
f0101ac8:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101acb:	8d 51 04             	lea    0x4(%ecx),%edx
f0101ace:	83 c4 10             	add    $0x10,%esp
f0101ad1:	39 d0                	cmp    %edx,%eax
f0101ad3:	0f 85 ef 08 00 00    	jne    f01023c8 <mem_init+0x10ba>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101ad9:	6a 06                	push   $0x6
f0101adb:	68 00 10 00 00       	push   $0x1000
f0101ae0:	53                   	push   %ebx
f0101ae1:	ff 35 0c 1f 23 f0    	pushl  0xf0231f0c
f0101ae7:	e8 59 f7 ff ff       	call   f0101245 <page_insert>
f0101aec:	83 c4 10             	add    $0x10,%esp
f0101aef:	85 c0                	test   %eax,%eax
f0101af1:	0f 85 ea 08 00 00    	jne    f01023e1 <mem_init+0x10d3>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101af7:	8b 35 0c 1f 23 f0    	mov    0xf0231f0c,%esi
f0101afd:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101b02:	89 f0                	mov    %esi,%eax
f0101b04:	e8 d9 ef ff ff       	call   f0100ae2 <check_va2pa>
	return (pp - pages) << PGSHIFT;
f0101b09:	89 da                	mov    %ebx,%edx
f0101b0b:	2b 15 10 1f 23 f0    	sub    0xf0231f10,%edx
f0101b11:	c1 fa 03             	sar    $0x3,%edx
f0101b14:	c1 e2 0c             	shl    $0xc,%edx
f0101b17:	39 d0                	cmp    %edx,%eax
f0101b19:	0f 85 db 08 00 00    	jne    f01023fa <mem_init+0x10ec>
	assert(pp2->pp_ref == 1);
f0101b1f:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101b24:	0f 85 e9 08 00 00    	jne    f0102413 <mem_init+0x1105>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101b2a:	83 ec 04             	sub    $0x4,%esp
f0101b2d:	6a 00                	push   $0x0
f0101b2f:	68 00 10 00 00       	push   $0x1000
f0101b34:	56                   	push   %esi
f0101b35:	e8 20 f5 ff ff       	call   f010105a <pgdir_walk>
f0101b3a:	83 c4 10             	add    $0x10,%esp
f0101b3d:	f6 00 04             	testb  $0x4,(%eax)
f0101b40:	0f 84 e6 08 00 00    	je     f010242c <mem_init+0x111e>
	assert(kern_pgdir[0] & PTE_U);
f0101b46:	a1 0c 1f 23 f0       	mov    0xf0231f0c,%eax
f0101b4b:	f6 00 04             	testb  $0x4,(%eax)
f0101b4e:	0f 84 f1 08 00 00    	je     f0102445 <mem_init+0x1137>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101b54:	6a 02                	push   $0x2
f0101b56:	68 00 10 00 00       	push   $0x1000
f0101b5b:	53                   	push   %ebx
f0101b5c:	50                   	push   %eax
f0101b5d:	e8 e3 f6 ff ff       	call   f0101245 <page_insert>
f0101b62:	83 c4 10             	add    $0x10,%esp
f0101b65:	85 c0                	test   %eax,%eax
f0101b67:	0f 85 f1 08 00 00    	jne    f010245e <mem_init+0x1150>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101b6d:	83 ec 04             	sub    $0x4,%esp
f0101b70:	6a 00                	push   $0x0
f0101b72:	68 00 10 00 00       	push   $0x1000
f0101b77:	ff 35 0c 1f 23 f0    	pushl  0xf0231f0c
f0101b7d:	e8 d8 f4 ff ff       	call   f010105a <pgdir_walk>
f0101b82:	83 c4 10             	add    $0x10,%esp
f0101b85:	f6 00 02             	testb  $0x2,(%eax)
f0101b88:	0f 84 e9 08 00 00    	je     f0102477 <mem_init+0x1169>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101b8e:	83 ec 04             	sub    $0x4,%esp
f0101b91:	6a 00                	push   $0x0
f0101b93:	68 00 10 00 00       	push   $0x1000
f0101b98:	ff 35 0c 1f 23 f0    	pushl  0xf0231f0c
f0101b9e:	e8 b7 f4 ff ff       	call   f010105a <pgdir_walk>
f0101ba3:	83 c4 10             	add    $0x10,%esp
f0101ba6:	f6 00 04             	testb  $0x4,(%eax)
f0101ba9:	0f 85 e1 08 00 00    	jne    f0102490 <mem_init+0x1182>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101baf:	6a 02                	push   $0x2
f0101bb1:	68 00 00 40 00       	push   $0x400000
f0101bb6:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101bb9:	ff 35 0c 1f 23 f0    	pushl  0xf0231f0c
f0101bbf:	e8 81 f6 ff ff       	call   f0101245 <page_insert>
f0101bc4:	83 c4 10             	add    $0x10,%esp
f0101bc7:	85 c0                	test   %eax,%eax
f0101bc9:	0f 89 da 08 00 00    	jns    f01024a9 <mem_init+0x119b>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101bcf:	6a 02                	push   $0x2
f0101bd1:	68 00 10 00 00       	push   $0x1000
f0101bd6:	57                   	push   %edi
f0101bd7:	ff 35 0c 1f 23 f0    	pushl  0xf0231f0c
f0101bdd:	e8 63 f6 ff ff       	call   f0101245 <page_insert>
f0101be2:	83 c4 10             	add    $0x10,%esp
f0101be5:	85 c0                	test   %eax,%eax
f0101be7:	0f 85 d5 08 00 00    	jne    f01024c2 <mem_init+0x11b4>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101bed:	83 ec 04             	sub    $0x4,%esp
f0101bf0:	6a 00                	push   $0x0
f0101bf2:	68 00 10 00 00       	push   $0x1000
f0101bf7:	ff 35 0c 1f 23 f0    	pushl  0xf0231f0c
f0101bfd:	e8 58 f4 ff ff       	call   f010105a <pgdir_walk>
f0101c02:	83 c4 10             	add    $0x10,%esp
f0101c05:	f6 00 04             	testb  $0x4,(%eax)
f0101c08:	0f 85 cd 08 00 00    	jne    f01024db <mem_init+0x11cd>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101c0e:	a1 0c 1f 23 f0       	mov    0xf0231f0c,%eax
f0101c13:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101c16:	ba 00 00 00 00       	mov    $0x0,%edx
f0101c1b:	e8 c2 ee ff ff       	call   f0100ae2 <check_va2pa>
f0101c20:	89 fe                	mov    %edi,%esi
f0101c22:	2b 35 10 1f 23 f0    	sub    0xf0231f10,%esi
f0101c28:	c1 fe 03             	sar    $0x3,%esi
f0101c2b:	c1 e6 0c             	shl    $0xc,%esi
f0101c2e:	39 f0                	cmp    %esi,%eax
f0101c30:	0f 85 be 08 00 00    	jne    f01024f4 <mem_init+0x11e6>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101c36:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c3b:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101c3e:	e8 9f ee ff ff       	call   f0100ae2 <check_va2pa>
f0101c43:	39 c6                	cmp    %eax,%esi
f0101c45:	0f 85 c2 08 00 00    	jne    f010250d <mem_init+0x11ff>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101c4b:	66 83 7f 04 02       	cmpw   $0x2,0x4(%edi)
f0101c50:	0f 85 d0 08 00 00    	jne    f0102526 <mem_init+0x1218>
	assert(pp2->pp_ref == 0);
f0101c56:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101c5b:	0f 85 de 08 00 00    	jne    f010253f <mem_init+0x1231>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101c61:	83 ec 0c             	sub    $0xc,%esp
f0101c64:	6a 00                	push   $0x0
f0101c66:	e8 19 f3 ff ff       	call   f0100f84 <page_alloc>
f0101c6b:	83 c4 10             	add    $0x10,%esp
f0101c6e:	39 c3                	cmp    %eax,%ebx
f0101c70:	0f 85 e2 08 00 00    	jne    f0102558 <mem_init+0x124a>
f0101c76:	85 c0                	test   %eax,%eax
f0101c78:	0f 84 da 08 00 00    	je     f0102558 <mem_init+0x124a>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101c7e:	83 ec 08             	sub    $0x8,%esp
f0101c81:	6a 00                	push   $0x0
f0101c83:	ff 35 0c 1f 23 f0    	pushl  0xf0231f0c
f0101c89:	e8 71 f5 ff ff       	call   f01011ff <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101c8e:	8b 35 0c 1f 23 f0    	mov    0xf0231f0c,%esi
f0101c94:	ba 00 00 00 00       	mov    $0x0,%edx
f0101c99:	89 f0                	mov    %esi,%eax
f0101c9b:	e8 42 ee ff ff       	call   f0100ae2 <check_va2pa>
f0101ca0:	83 c4 10             	add    $0x10,%esp
f0101ca3:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101ca6:	0f 85 c5 08 00 00    	jne    f0102571 <mem_init+0x1263>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101cac:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101cb1:	89 f0                	mov    %esi,%eax
f0101cb3:	e8 2a ee ff ff       	call   f0100ae2 <check_va2pa>
f0101cb8:	89 fa                	mov    %edi,%edx
f0101cba:	2b 15 10 1f 23 f0    	sub    0xf0231f10,%edx
f0101cc0:	c1 fa 03             	sar    $0x3,%edx
f0101cc3:	c1 e2 0c             	shl    $0xc,%edx
f0101cc6:	39 d0                	cmp    %edx,%eax
f0101cc8:	0f 85 bc 08 00 00    	jne    f010258a <mem_init+0x127c>
	assert(pp1->pp_ref == 1);
f0101cce:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101cd3:	0f 85 ca 08 00 00    	jne    f01025a3 <mem_init+0x1295>
	assert(pp2->pp_ref == 0);
f0101cd9:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101cde:	0f 85 d8 08 00 00    	jne    f01025bc <mem_init+0x12ae>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101ce4:	6a 00                	push   $0x0
f0101ce6:	68 00 10 00 00       	push   $0x1000
f0101ceb:	57                   	push   %edi
f0101cec:	56                   	push   %esi
f0101ced:	e8 53 f5 ff ff       	call   f0101245 <page_insert>
f0101cf2:	83 c4 10             	add    $0x10,%esp
f0101cf5:	85 c0                	test   %eax,%eax
f0101cf7:	0f 85 d8 08 00 00    	jne    f01025d5 <mem_init+0x12c7>
	assert(pp1->pp_ref);
f0101cfd:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101d02:	0f 84 e6 08 00 00    	je     f01025ee <mem_init+0x12e0>
	assert(pp1->pp_link == NULL);
f0101d08:	83 3f 00             	cmpl   $0x0,(%edi)
f0101d0b:	0f 85 f6 08 00 00    	jne    f0102607 <mem_init+0x12f9>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101d11:	83 ec 08             	sub    $0x8,%esp
f0101d14:	68 00 10 00 00       	push   $0x1000
f0101d19:	ff 35 0c 1f 23 f0    	pushl  0xf0231f0c
f0101d1f:	e8 db f4 ff ff       	call   f01011ff <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101d24:	8b 35 0c 1f 23 f0    	mov    0xf0231f0c,%esi
f0101d2a:	ba 00 00 00 00       	mov    $0x0,%edx
f0101d2f:	89 f0                	mov    %esi,%eax
f0101d31:	e8 ac ed ff ff       	call   f0100ae2 <check_va2pa>
f0101d36:	83 c4 10             	add    $0x10,%esp
f0101d39:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101d3c:	0f 85 de 08 00 00    	jne    f0102620 <mem_init+0x1312>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101d42:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d47:	89 f0                	mov    %esi,%eax
f0101d49:	e8 94 ed ff ff       	call   f0100ae2 <check_va2pa>
f0101d4e:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101d51:	0f 85 e2 08 00 00    	jne    f0102639 <mem_init+0x132b>
	assert(pp1->pp_ref == 0);
f0101d57:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101d5c:	0f 85 f0 08 00 00    	jne    f0102652 <mem_init+0x1344>
	assert(pp2->pp_ref == 0);
f0101d62:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101d67:	0f 85 fe 08 00 00    	jne    f010266b <mem_init+0x135d>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101d6d:	83 ec 0c             	sub    $0xc,%esp
f0101d70:	6a 00                	push   $0x0
f0101d72:	e8 0d f2 ff ff       	call   f0100f84 <page_alloc>
f0101d77:	83 c4 10             	add    $0x10,%esp
f0101d7a:	85 c0                	test   %eax,%eax
f0101d7c:	0f 84 02 09 00 00    	je     f0102684 <mem_init+0x1376>
f0101d82:	39 c7                	cmp    %eax,%edi
f0101d84:	0f 85 fa 08 00 00    	jne    f0102684 <mem_init+0x1376>

	// should be no free memory
	assert(!page_alloc(0));
f0101d8a:	83 ec 0c             	sub    $0xc,%esp
f0101d8d:	6a 00                	push   $0x0
f0101d8f:	e8 f0 f1 ff ff       	call   f0100f84 <page_alloc>
f0101d94:	83 c4 10             	add    $0x10,%esp
f0101d97:	85 c0                	test   %eax,%eax
f0101d99:	0f 85 fe 08 00 00    	jne    f010269d <mem_init+0x138f>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101d9f:	8b 0d 0c 1f 23 f0    	mov    0xf0231f0c,%ecx
f0101da5:	8b 11                	mov    (%ecx),%edx
f0101da7:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101dad:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101db0:	2b 05 10 1f 23 f0    	sub    0xf0231f10,%eax
f0101db6:	c1 f8 03             	sar    $0x3,%eax
f0101db9:	c1 e0 0c             	shl    $0xc,%eax
f0101dbc:	39 c2                	cmp    %eax,%edx
f0101dbe:	0f 85 f2 08 00 00    	jne    f01026b6 <mem_init+0x13a8>
	kern_pgdir[0] = 0;
f0101dc4:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0101dca:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101dcd:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101dd2:	0f 85 f7 08 00 00    	jne    f01026cf <mem_init+0x13c1>
	pp0->pp_ref = 0;
f0101dd8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ddb:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0101de1:	83 ec 0c             	sub    $0xc,%esp
f0101de4:	50                   	push   %eax
f0101de5:	e8 0c f2 ff ff       	call   f0100ff6 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0101dea:	83 c4 0c             	add    $0xc,%esp
f0101ded:	6a 01                	push   $0x1
f0101def:	68 00 10 40 00       	push   $0x401000
f0101df4:	ff 35 0c 1f 23 f0    	pushl  0xf0231f0c
f0101dfa:	e8 5b f2 ff ff       	call   f010105a <pgdir_walk>
f0101dff:	89 c1                	mov    %eax,%ecx
f0101e01:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0101e04:	a1 0c 1f 23 f0       	mov    0xf0231f0c,%eax
f0101e09:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101e0c:	8b 40 04             	mov    0x4(%eax),%eax
f0101e0f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0101e14:	8b 35 08 1f 23 f0    	mov    0xf0231f08,%esi
f0101e1a:	89 c2                	mov    %eax,%edx
f0101e1c:	c1 ea 0c             	shr    $0xc,%edx
f0101e1f:	83 c4 10             	add    $0x10,%esp
f0101e22:	39 f2                	cmp    %esi,%edx
f0101e24:	0f 83 be 08 00 00    	jae    f01026e8 <mem_init+0x13da>
	assert(ptep == ptep1 + PTX(va));
f0101e2a:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f0101e2f:	39 c1                	cmp    %eax,%ecx
f0101e31:	0f 85 c6 08 00 00    	jne    f01026fd <mem_init+0x13ef>
	kern_pgdir[PDX(va)] = 0;
f0101e37:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101e3a:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f0101e41:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e44:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f0101e4a:	2b 05 10 1f 23 f0    	sub    0xf0231f10,%eax
f0101e50:	c1 f8 03             	sar    $0x3,%eax
f0101e53:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0101e56:	89 c2                	mov    %eax,%edx
f0101e58:	c1 ea 0c             	shr    $0xc,%edx
f0101e5b:	39 d6                	cmp    %edx,%esi
f0101e5d:	0f 86 b3 08 00 00    	jbe    f0102716 <mem_init+0x1408>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0101e63:	83 ec 04             	sub    $0x4,%esp
f0101e66:	68 00 10 00 00       	push   $0x1000
f0101e6b:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f0101e70:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101e75:	50                   	push   %eax
f0101e76:	e8 7f 2a 00 00       	call   f01048fa <memset>
	page_free(pp0);
f0101e7b:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0101e7e:	89 34 24             	mov    %esi,(%esp)
f0101e81:	e8 70 f1 ff ff       	call   f0100ff6 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0101e86:	83 c4 0c             	add    $0xc,%esp
f0101e89:	6a 01                	push   $0x1
f0101e8b:	6a 00                	push   $0x0
f0101e8d:	ff 35 0c 1f 23 f0    	pushl  0xf0231f0c
f0101e93:	e8 c2 f1 ff ff       	call   f010105a <pgdir_walk>
	return (pp - pages) << PGSHIFT;
f0101e98:	89 f0                	mov    %esi,%eax
f0101e9a:	2b 05 10 1f 23 f0    	sub    0xf0231f10,%eax
f0101ea0:	c1 f8 03             	sar    $0x3,%eax
f0101ea3:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0101ea6:	89 c2                	mov    %eax,%edx
f0101ea8:	c1 ea 0c             	shr    $0xc,%edx
f0101eab:	83 c4 10             	add    $0x10,%esp
f0101eae:	3b 15 08 1f 23 f0    	cmp    0xf0231f08,%edx
f0101eb4:	0f 83 6e 08 00 00    	jae    f0102728 <mem_init+0x141a>
	return (void *)(pa + KERNBASE);
f0101eba:	8d 90 00 00 00 f0    	lea    -0x10000000(%eax),%edx
	ptep = (pte_t *) page2kva(pp0);
f0101ec0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0101ec3:	2d 00 f0 ff 0f       	sub    $0xffff000,%eax
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0101ec8:	f6 02 01             	testb  $0x1,(%edx)
f0101ecb:	0f 85 69 08 00 00    	jne    f010273a <mem_init+0x142c>
f0101ed1:	83 c2 04             	add    $0x4,%edx
	for(i=0; i<NPTENTRIES; i++)
f0101ed4:	39 c2                	cmp    %eax,%edx
f0101ed6:	75 f0                	jne    f0101ec8 <mem_init+0xbba>
	kern_pgdir[0] = 0;
f0101ed8:	a1 0c 1f 23 f0       	mov    0xf0231f0c,%eax
f0101edd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0101ee3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ee6:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0101eec:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0101eef:	89 0d 3c 12 23 f0    	mov    %ecx,0xf023123c

	// free the pages we took
	page_free(pp0);
f0101ef5:	83 ec 0c             	sub    $0xc,%esp
f0101ef8:	50                   	push   %eax
f0101ef9:	e8 f8 f0 ff ff       	call   f0100ff6 <page_free>
	page_free(pp1);
f0101efe:	89 3c 24             	mov    %edi,(%esp)
f0101f01:	e8 f0 f0 ff ff       	call   f0100ff6 <page_free>
	page_free(pp2);
f0101f06:	89 1c 24             	mov    %ebx,(%esp)
f0101f09:	e8 e8 f0 ff ff       	call   f0100ff6 <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f0101f0e:	83 c4 08             	add    $0x8,%esp
f0101f11:	68 01 10 00 00       	push   $0x1001
f0101f16:	6a 00                	push   $0x0
f0101f18:	e8 8e f3 ff ff       	call   f01012ab <mmio_map_region>
f0101f1d:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f0101f1f:	83 c4 08             	add    $0x8,%esp
f0101f22:	68 00 10 00 00       	push   $0x1000
f0101f27:	6a 00                	push   $0x0
f0101f29:	e8 7d f3 ff ff       	call   f01012ab <mmio_map_region>
f0101f2e:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8192 < MMIOLIM);
f0101f30:	8d 83 00 20 00 00    	lea    0x2000(%ebx),%eax
f0101f36:	83 c4 10             	add    $0x10,%esp
f0101f39:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0101f3f:	0f 86 0e 08 00 00    	jbe    f0102753 <mem_init+0x1445>
f0101f45:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0101f4a:	0f 87 03 08 00 00    	ja     f0102753 <mem_init+0x1445>
	assert(mm2 >= MMIOBASE && mm2 + 8192 < MMIOLIM);
f0101f50:	8d 96 00 20 00 00    	lea    0x2000(%esi),%edx
f0101f56:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f0101f5c:	0f 87 0a 08 00 00    	ja     f010276c <mem_init+0x145e>
f0101f62:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0101f68:	0f 86 fe 07 00 00    	jbe    f010276c <mem_init+0x145e>
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0101f6e:	89 da                	mov    %ebx,%edx
f0101f70:	09 f2                	or     %esi,%edx
f0101f72:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0101f78:	0f 85 07 08 00 00    	jne    f0102785 <mem_init+0x1477>
	// check that they don't overlap
	assert(mm1 + 8192 <= mm2);
f0101f7e:	39 c6                	cmp    %eax,%esi
f0101f80:	0f 82 18 08 00 00    	jb     f010279e <mem_init+0x1490>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0101f86:	8b 3d 0c 1f 23 f0    	mov    0xf0231f0c,%edi
f0101f8c:	89 da                	mov    %ebx,%edx
f0101f8e:	89 f8                	mov    %edi,%eax
f0101f90:	e8 4d eb ff ff       	call   f0100ae2 <check_va2pa>
f0101f95:	85 c0                	test   %eax,%eax
f0101f97:	0f 85 1a 08 00 00    	jne    f01027b7 <mem_init+0x14a9>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0101f9d:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f0101fa3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101fa6:	89 c2                	mov    %eax,%edx
f0101fa8:	89 f8                	mov    %edi,%eax
f0101faa:	e8 33 eb ff ff       	call   f0100ae2 <check_va2pa>
f0101faf:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0101fb4:	0f 85 16 08 00 00    	jne    f01027d0 <mem_init+0x14c2>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0101fba:	89 f2                	mov    %esi,%edx
f0101fbc:	89 f8                	mov    %edi,%eax
f0101fbe:	e8 1f eb ff ff       	call   f0100ae2 <check_va2pa>
f0101fc3:	85 c0                	test   %eax,%eax
f0101fc5:	0f 85 1e 08 00 00    	jne    f01027e9 <mem_init+0x14db>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0101fcb:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f0101fd1:	89 f8                	mov    %edi,%eax
f0101fd3:	e8 0a eb ff ff       	call   f0100ae2 <check_va2pa>
f0101fd8:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101fdb:	0f 85 21 08 00 00    	jne    f0102802 <mem_init+0x14f4>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f0101fe1:	83 ec 04             	sub    $0x4,%esp
f0101fe4:	6a 00                	push   $0x0
f0101fe6:	53                   	push   %ebx
f0101fe7:	57                   	push   %edi
f0101fe8:	e8 6d f0 ff ff       	call   f010105a <pgdir_walk>
f0101fed:	83 c4 10             	add    $0x10,%esp
f0101ff0:	f6 00 1a             	testb  $0x1a,(%eax)
f0101ff3:	0f 84 22 08 00 00    	je     f010281b <mem_init+0x150d>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0101ff9:	83 ec 04             	sub    $0x4,%esp
f0101ffc:	6a 00                	push   $0x0
f0101ffe:	53                   	push   %ebx
f0101fff:	ff 35 0c 1f 23 f0    	pushl  0xf0231f0c
f0102005:	e8 50 f0 ff ff       	call   f010105a <pgdir_walk>
f010200a:	83 c4 10             	add    $0x10,%esp
f010200d:	f6 00 04             	testb  $0x4,(%eax)
f0102010:	0f 85 1e 08 00 00    	jne    f0102834 <mem_init+0x1526>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f0102016:	83 ec 04             	sub    $0x4,%esp
f0102019:	6a 00                	push   $0x0
f010201b:	53                   	push   %ebx
f010201c:	ff 35 0c 1f 23 f0    	pushl  0xf0231f0c
f0102022:	e8 33 f0 ff ff       	call   f010105a <pgdir_walk>
f0102027:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f010202d:	83 c4 0c             	add    $0xc,%esp
f0102030:	6a 00                	push   $0x0
f0102032:	ff 75 d4             	pushl  -0x2c(%ebp)
f0102035:	ff 35 0c 1f 23 f0    	pushl  0xf0231f0c
f010203b:	e8 1a f0 ff ff       	call   f010105a <pgdir_walk>
f0102040:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f0102046:	83 c4 0c             	add    $0xc,%esp
f0102049:	6a 00                	push   $0x0
f010204b:	56                   	push   %esi
f010204c:	ff 35 0c 1f 23 f0    	pushl  0xf0231f0c
f0102052:	e8 03 f0 ff ff       	call   f010105a <pgdir_walk>
f0102057:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f010205d:	c7 04 24 d8 67 10 f0 	movl   $0xf01067d8,(%esp)
f0102064:	e8 9c 17 00 00       	call   f0103805 <cprintf>
	boot_map_region(kern_pgdir, (uintptr_t) UPAGES, npages*sizeof(struct PageInfo), PADDR(pages), PTE_U | PTE_P);
f0102069:	a1 10 1f 23 f0       	mov    0xf0231f10,%eax
	if ((uint32_t)kva < KERNBASE)
f010206e:	83 c4 10             	add    $0x10,%esp
f0102071:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102076:	0f 86 d1 07 00 00    	jbe    f010284d <mem_init+0x153f>
f010207c:	8b 0d 08 1f 23 f0    	mov    0xf0231f08,%ecx
f0102082:	c1 e1 03             	shl    $0x3,%ecx
f0102085:	83 ec 08             	sub    $0x8,%esp
f0102088:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f010208a:	05 00 00 00 10       	add    $0x10000000,%eax
f010208f:	50                   	push   %eax
f0102090:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102095:	a1 0c 1f 23 f0       	mov    0xf0231f0c,%eax
f010209a:	e8 7b f0 ff ff       	call   f010111a <boot_map_region>
	boot_map_region(kern_pgdir, (uintptr_t) UENVS, ROUNDUP(NENV * sizeof(struct Env), PGSIZE), PADDR(envs), PTE_U | PTE_P);
f010209f:	a1 44 12 23 f0       	mov    0xf0231244,%eax
	if ((uint32_t)kva < KERNBASE)
f01020a4:	83 c4 10             	add    $0x10,%esp
f01020a7:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01020ac:	0f 86 b0 07 00 00    	jbe    f0102862 <mem_init+0x1554>
f01020b2:	83 ec 08             	sub    $0x8,%esp
f01020b5:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f01020b7:	05 00 00 00 10       	add    $0x10000000,%eax
f01020bc:	50                   	push   %eax
f01020bd:	b9 00 f0 01 00       	mov    $0x1f000,%ecx
f01020c2:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f01020c7:	a1 0c 1f 23 f0       	mov    0xf0231f0c,%eax
f01020cc:	e8 49 f0 ff ff       	call   f010111a <boot_map_region>
	if ((uint32_t)kva < KERNBASE)
f01020d1:	83 c4 10             	add    $0x10,%esp
f01020d4:	b8 00 70 11 f0       	mov    $0xf0117000,%eax
f01020d9:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01020de:	0f 86 93 07 00 00    	jbe    f0102877 <mem_init+0x1569>
	boot_map_region(kern_pgdir, (uintptr_t) (KSTACKTOP-KSTKSIZE), KSTKSIZE, PADDR(bootstack), PTE_W | PTE_P);
f01020e4:	83 ec 08             	sub    $0x8,%esp
f01020e7:	6a 03                	push   $0x3
f01020e9:	68 00 70 11 00       	push   $0x117000
f01020ee:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01020f3:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f01020f8:	a1 0c 1f 23 f0       	mov    0xf0231f0c,%eax
f01020fd:	e8 18 f0 ff ff       	call   f010111a <boot_map_region>
	boot_map_region(kern_pgdir, (uintptr_t) KERNBASE, ROUNDUP(0xffffffff - KERNBASE, PGSIZE), 0, PTE_W | PTE_P);
f0102102:	83 c4 08             	add    $0x8,%esp
f0102105:	6a 03                	push   $0x3
f0102107:	6a 00                	push   $0x0
f0102109:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f010210e:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102113:	a1 0c 1f 23 f0       	mov    0xf0231f0c,%eax
f0102118:	e8 fd ef ff ff       	call   f010111a <boot_map_region>
	pgdir = kern_pgdir;
f010211d:	8b 3d 0c 1f 23 f0    	mov    0xf0231f0c,%edi
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102123:	a1 08 1f 23 f0       	mov    0xf0231f08,%eax
f0102128:	89 45 c8             	mov    %eax,-0x38(%ebp)
f010212b:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0102132:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102137:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010213a:	8b 35 10 1f 23 f0    	mov    0xf0231f10,%esi
f0102140:	89 75 d0             	mov    %esi,-0x30(%ebp)
	return (physaddr_t)kva - KERNBASE;
f0102143:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f0102149:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010214c:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < n; i += PGSIZE)
f010214f:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102154:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0102157:	0f 86 5d 07 00 00    	jbe    f01028ba <mem_init+0x15ac>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010215d:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f0102163:	89 f8                	mov    %edi,%eax
f0102165:	e8 78 e9 ff ff       	call   f0100ae2 <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f010216a:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f0102171:	0f 86 15 07 00 00    	jbe    f010288c <mem_init+0x157e>
f0102177:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f010217a:	8d 14 0b             	lea    (%ebx,%ecx,1),%edx
f010217d:	39 d0                	cmp    %edx,%eax
f010217f:	0f 85 1c 07 00 00    	jne    f01028a1 <mem_init+0x1593>
	for (i = 0; i < n; i += PGSIZE)
f0102185:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010218b:	eb c7                	jmp    f0102154 <mem_init+0xe46>
	assert(nfree == 0);
f010218d:	68 ef 66 10 f0       	push   $0xf01066ef
f0102192:	68 e9 64 10 f0       	push   $0xf01064e9
f0102197:	68 47 03 00 00       	push   $0x347
f010219c:	68 bd 64 10 f0       	push   $0xf01064bd
f01021a1:	e8 ee de ff ff       	call   f0100094 <_panic>
	assert((pp0 = page_alloc(0)));
f01021a6:	68 fd 65 10 f0       	push   $0xf01065fd
f01021ab:	68 e9 64 10 f0       	push   $0xf01064e9
f01021b0:	68 b7 03 00 00       	push   $0x3b7
f01021b5:	68 bd 64 10 f0       	push   $0xf01064bd
f01021ba:	e8 d5 de ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f01021bf:	68 13 66 10 f0       	push   $0xf0106613
f01021c4:	68 e9 64 10 f0       	push   $0xf01064e9
f01021c9:	68 b8 03 00 00       	push   $0x3b8
f01021ce:	68 bd 64 10 f0       	push   $0xf01064bd
f01021d3:	e8 bc de ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f01021d8:	68 29 66 10 f0       	push   $0xf0106629
f01021dd:	68 e9 64 10 f0       	push   $0xf01064e9
f01021e2:	68 b9 03 00 00       	push   $0x3b9
f01021e7:	68 bd 64 10 f0       	push   $0xf01064bd
f01021ec:	e8 a3 de ff ff       	call   f0100094 <_panic>
	assert(pp1 && pp1 != pp0);
f01021f1:	68 3f 66 10 f0       	push   $0xf010663f
f01021f6:	68 e9 64 10 f0       	push   $0xf01064e9
f01021fb:	68 bc 03 00 00       	push   $0x3bc
f0102200:	68 bd 64 10 f0       	push   $0xf01064bd
f0102205:	e8 8a de ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010220a:	68 a0 5c 10 f0       	push   $0xf0105ca0
f010220f:	68 e9 64 10 f0       	push   $0xf01064e9
f0102214:	68 bd 03 00 00       	push   $0x3bd
f0102219:	68 bd 64 10 f0       	push   $0xf01064bd
f010221e:	e8 71 de ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f0102223:	68 a8 66 10 f0       	push   $0xf01066a8
f0102228:	68 e9 64 10 f0       	push   $0xf01064e9
f010222d:	68 c4 03 00 00       	push   $0x3c4
f0102232:	68 bd 64 10 f0       	push   $0xf01064bd
f0102237:	e8 58 de ff ff       	call   f0100094 <_panic>
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f010223c:	68 e0 5c 10 f0       	push   $0xf0105ce0
f0102241:	68 e9 64 10 f0       	push   $0xf01064e9
f0102246:	68 c7 03 00 00       	push   $0x3c7
f010224b:	68 bd 64 10 f0       	push   $0xf01064bd
f0102250:	e8 3f de ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0102255:	68 18 5d 10 f0       	push   $0xf0105d18
f010225a:	68 e9 64 10 f0       	push   $0xf01064e9
f010225f:	68 ca 03 00 00       	push   $0x3ca
f0102264:	68 bd 64 10 f0       	push   $0xf01064bd
f0102269:	e8 26 de ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f010226e:	68 48 5d 10 f0       	push   $0xf0105d48
f0102273:	68 e9 64 10 f0       	push   $0xf01064e9
f0102278:	68 ce 03 00 00       	push   $0x3ce
f010227d:	68 bd 64 10 f0       	push   $0xf01064bd
f0102282:	e8 0d de ff ff       	call   f0100094 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102287:	68 78 5d 10 f0       	push   $0xf0105d78
f010228c:	68 e9 64 10 f0       	push   $0xf01064e9
f0102291:	68 cf 03 00 00       	push   $0x3cf
f0102296:	68 bd 64 10 f0       	push   $0xf01064bd
f010229b:	e8 f4 dd ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f01022a0:	68 a0 5d 10 f0       	push   $0xf0105da0
f01022a5:	68 e9 64 10 f0       	push   $0xf01064e9
f01022aa:	68 d0 03 00 00       	push   $0x3d0
f01022af:	68 bd 64 10 f0       	push   $0xf01064bd
f01022b4:	e8 db dd ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 1);
f01022b9:	68 fa 66 10 f0       	push   $0xf01066fa
f01022be:	68 e9 64 10 f0       	push   $0xf01064e9
f01022c3:	68 d1 03 00 00       	push   $0x3d1
f01022c8:	68 bd 64 10 f0       	push   $0xf01064bd
f01022cd:	e8 c2 dd ff ff       	call   f0100094 <_panic>
	assert(pp0->pp_ref == 1);
f01022d2:	68 0b 67 10 f0       	push   $0xf010670b
f01022d7:	68 e9 64 10 f0       	push   $0xf01064e9
f01022dc:	68 d2 03 00 00       	push   $0x3d2
f01022e1:	68 bd 64 10 f0       	push   $0xf01064bd
f01022e6:	e8 a9 dd ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01022eb:	68 d0 5d 10 f0       	push   $0xf0105dd0
f01022f0:	68 e9 64 10 f0       	push   $0xf01064e9
f01022f5:	68 d5 03 00 00       	push   $0x3d5
f01022fa:	68 bd 64 10 f0       	push   $0xf01064bd
f01022ff:	e8 90 dd ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102304:	68 0c 5e 10 f0       	push   $0xf0105e0c
f0102309:	68 e9 64 10 f0       	push   $0xf01064e9
f010230e:	68 d6 03 00 00       	push   $0x3d6
f0102313:	68 bd 64 10 f0       	push   $0xf01064bd
f0102318:	e8 77 dd ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f010231d:	68 1c 67 10 f0       	push   $0xf010671c
f0102322:	68 e9 64 10 f0       	push   $0xf01064e9
f0102327:	68 d7 03 00 00       	push   $0x3d7
f010232c:	68 bd 64 10 f0       	push   $0xf01064bd
f0102331:	e8 5e dd ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f0102336:	68 a8 66 10 f0       	push   $0xf01066a8
f010233b:	68 e9 64 10 f0       	push   $0xf01064e9
f0102340:	68 da 03 00 00       	push   $0x3da
f0102345:	68 bd 64 10 f0       	push   $0xf01064bd
f010234a:	e8 45 dd ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010234f:	68 d0 5d 10 f0       	push   $0xf0105dd0
f0102354:	68 e9 64 10 f0       	push   $0xf01064e9
f0102359:	68 dd 03 00 00       	push   $0x3dd
f010235e:	68 bd 64 10 f0       	push   $0xf01064bd
f0102363:	e8 2c dd ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102368:	68 0c 5e 10 f0       	push   $0xf0105e0c
f010236d:	68 e9 64 10 f0       	push   $0xf01064e9
f0102372:	68 de 03 00 00       	push   $0x3de
f0102377:	68 bd 64 10 f0       	push   $0xf01064bd
f010237c:	e8 13 dd ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f0102381:	68 1c 67 10 f0       	push   $0xf010671c
f0102386:	68 e9 64 10 f0       	push   $0xf01064e9
f010238b:	68 df 03 00 00       	push   $0x3df
f0102390:	68 bd 64 10 f0       	push   $0xf01064bd
f0102395:	e8 fa dc ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f010239a:	68 a8 66 10 f0       	push   $0xf01066a8
f010239f:	68 e9 64 10 f0       	push   $0xf01064e9
f01023a4:	68 e3 03 00 00       	push   $0x3e3
f01023a9:	68 bd 64 10 f0       	push   $0xf01064bd
f01023ae:	e8 e1 dc ff ff       	call   f0100094 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01023b3:	50                   	push   %eax
f01023b4:	68 f4 55 10 f0       	push   $0xf01055f4
f01023b9:	68 e6 03 00 00       	push   $0x3e6
f01023be:	68 bd 64 10 f0       	push   $0xf01064bd
f01023c3:	e8 cc dc ff ff       	call   f0100094 <_panic>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f01023c8:	68 3c 5e 10 f0       	push   $0xf0105e3c
f01023cd:	68 e9 64 10 f0       	push   $0xf01064e9
f01023d2:	68 e7 03 00 00       	push   $0x3e7
f01023d7:	68 bd 64 10 f0       	push   $0xf01064bd
f01023dc:	e8 b3 dc ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f01023e1:	68 7c 5e 10 f0       	push   $0xf0105e7c
f01023e6:	68 e9 64 10 f0       	push   $0xf01064e9
f01023eb:	68 ea 03 00 00       	push   $0x3ea
f01023f0:	68 bd 64 10 f0       	push   $0xf01064bd
f01023f5:	e8 9a dc ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01023fa:	68 0c 5e 10 f0       	push   $0xf0105e0c
f01023ff:	68 e9 64 10 f0       	push   $0xf01064e9
f0102404:	68 eb 03 00 00       	push   $0x3eb
f0102409:	68 bd 64 10 f0       	push   $0xf01064bd
f010240e:	e8 81 dc ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f0102413:	68 1c 67 10 f0       	push   $0xf010671c
f0102418:	68 e9 64 10 f0       	push   $0xf01064e9
f010241d:	68 ec 03 00 00       	push   $0x3ec
f0102422:	68 bd 64 10 f0       	push   $0xf01064bd
f0102427:	e8 68 dc ff ff       	call   f0100094 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f010242c:	68 bc 5e 10 f0       	push   $0xf0105ebc
f0102431:	68 e9 64 10 f0       	push   $0xf01064e9
f0102436:	68 ed 03 00 00       	push   $0x3ed
f010243b:	68 bd 64 10 f0       	push   $0xf01064bd
f0102440:	e8 4f dc ff ff       	call   f0100094 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0102445:	68 2d 67 10 f0       	push   $0xf010672d
f010244a:	68 e9 64 10 f0       	push   $0xf01064e9
f010244f:	68 ee 03 00 00       	push   $0x3ee
f0102454:	68 bd 64 10 f0       	push   $0xf01064bd
f0102459:	e8 36 dc ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010245e:	68 d0 5d 10 f0       	push   $0xf0105dd0
f0102463:	68 e9 64 10 f0       	push   $0xf01064e9
f0102468:	68 f1 03 00 00       	push   $0x3f1
f010246d:	68 bd 64 10 f0       	push   $0xf01064bd
f0102472:	e8 1d dc ff ff       	call   f0100094 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0102477:	68 f0 5e 10 f0       	push   $0xf0105ef0
f010247c:	68 e9 64 10 f0       	push   $0xf01064e9
f0102481:	68 f2 03 00 00       	push   $0x3f2
f0102486:	68 bd 64 10 f0       	push   $0xf01064bd
f010248b:	e8 04 dc ff ff       	call   f0100094 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102490:	68 24 5f 10 f0       	push   $0xf0105f24
f0102495:	68 e9 64 10 f0       	push   $0xf01064e9
f010249a:	68 f3 03 00 00       	push   $0x3f3
f010249f:	68 bd 64 10 f0       	push   $0xf01064bd
f01024a4:	e8 eb db ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f01024a9:	68 5c 5f 10 f0       	push   $0xf0105f5c
f01024ae:	68 e9 64 10 f0       	push   $0xf01064e9
f01024b3:	68 f6 03 00 00       	push   $0x3f6
f01024b8:	68 bd 64 10 f0       	push   $0xf01064bd
f01024bd:	e8 d2 db ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f01024c2:	68 94 5f 10 f0       	push   $0xf0105f94
f01024c7:	68 e9 64 10 f0       	push   $0xf01064e9
f01024cc:	68 f9 03 00 00       	push   $0x3f9
f01024d1:	68 bd 64 10 f0       	push   $0xf01064bd
f01024d6:	e8 b9 db ff ff       	call   f0100094 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01024db:	68 24 5f 10 f0       	push   $0xf0105f24
f01024e0:	68 e9 64 10 f0       	push   $0xf01064e9
f01024e5:	68 fa 03 00 00       	push   $0x3fa
f01024ea:	68 bd 64 10 f0       	push   $0xf01064bd
f01024ef:	e8 a0 db ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f01024f4:	68 d0 5f 10 f0       	push   $0xf0105fd0
f01024f9:	68 e9 64 10 f0       	push   $0xf01064e9
f01024fe:	68 fd 03 00 00       	push   $0x3fd
f0102503:	68 bd 64 10 f0       	push   $0xf01064bd
f0102508:	e8 87 db ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010250d:	68 fc 5f 10 f0       	push   $0xf0105ffc
f0102512:	68 e9 64 10 f0       	push   $0xf01064e9
f0102517:	68 fe 03 00 00       	push   $0x3fe
f010251c:	68 bd 64 10 f0       	push   $0xf01064bd
f0102521:	e8 6e db ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 2);
f0102526:	68 43 67 10 f0       	push   $0xf0106743
f010252b:	68 e9 64 10 f0       	push   $0xf01064e9
f0102530:	68 00 04 00 00       	push   $0x400
f0102535:	68 bd 64 10 f0       	push   $0xf01064bd
f010253a:	e8 55 db ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f010253f:	68 54 67 10 f0       	push   $0xf0106754
f0102544:	68 e9 64 10 f0       	push   $0xf01064e9
f0102549:	68 01 04 00 00       	push   $0x401
f010254e:	68 bd 64 10 f0       	push   $0xf01064bd
f0102553:	e8 3c db ff ff       	call   f0100094 <_panic>
	assert((pp = page_alloc(0)) && pp == pp2);
f0102558:	68 2c 60 10 f0       	push   $0xf010602c
f010255d:	68 e9 64 10 f0       	push   $0xf01064e9
f0102562:	68 04 04 00 00       	push   $0x404
f0102567:	68 bd 64 10 f0       	push   $0xf01064bd
f010256c:	e8 23 db ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102571:	68 50 60 10 f0       	push   $0xf0106050
f0102576:	68 e9 64 10 f0       	push   $0xf01064e9
f010257b:	68 08 04 00 00       	push   $0x408
f0102580:	68 bd 64 10 f0       	push   $0xf01064bd
f0102585:	e8 0a db ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010258a:	68 fc 5f 10 f0       	push   $0xf0105ffc
f010258f:	68 e9 64 10 f0       	push   $0xf01064e9
f0102594:	68 09 04 00 00       	push   $0x409
f0102599:	68 bd 64 10 f0       	push   $0xf01064bd
f010259e:	e8 f1 da ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 1);
f01025a3:	68 fa 66 10 f0       	push   $0xf01066fa
f01025a8:	68 e9 64 10 f0       	push   $0xf01064e9
f01025ad:	68 0a 04 00 00       	push   $0x40a
f01025b2:	68 bd 64 10 f0       	push   $0xf01064bd
f01025b7:	e8 d8 da ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f01025bc:	68 54 67 10 f0       	push   $0xf0106754
f01025c1:	68 e9 64 10 f0       	push   $0xf01064e9
f01025c6:	68 0b 04 00 00       	push   $0x40b
f01025cb:	68 bd 64 10 f0       	push   $0xf01064bd
f01025d0:	e8 bf da ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f01025d5:	68 74 60 10 f0       	push   $0xf0106074
f01025da:	68 e9 64 10 f0       	push   $0xf01064e9
f01025df:	68 0e 04 00 00       	push   $0x40e
f01025e4:	68 bd 64 10 f0       	push   $0xf01064bd
f01025e9:	e8 a6 da ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref);
f01025ee:	68 65 67 10 f0       	push   $0xf0106765
f01025f3:	68 e9 64 10 f0       	push   $0xf01064e9
f01025f8:	68 0f 04 00 00       	push   $0x40f
f01025fd:	68 bd 64 10 f0       	push   $0xf01064bd
f0102602:	e8 8d da ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_link == NULL);
f0102607:	68 71 67 10 f0       	push   $0xf0106771
f010260c:	68 e9 64 10 f0       	push   $0xf01064e9
f0102611:	68 10 04 00 00       	push   $0x410
f0102616:	68 bd 64 10 f0       	push   $0xf01064bd
f010261b:	e8 74 da ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102620:	68 50 60 10 f0       	push   $0xf0106050
f0102625:	68 e9 64 10 f0       	push   $0xf01064e9
f010262a:	68 14 04 00 00       	push   $0x414
f010262f:	68 bd 64 10 f0       	push   $0xf01064bd
f0102634:	e8 5b da ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102639:	68 ac 60 10 f0       	push   $0xf01060ac
f010263e:	68 e9 64 10 f0       	push   $0xf01064e9
f0102643:	68 15 04 00 00       	push   $0x415
f0102648:	68 bd 64 10 f0       	push   $0xf01064bd
f010264d:	e8 42 da ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 0);
f0102652:	68 86 67 10 f0       	push   $0xf0106786
f0102657:	68 e9 64 10 f0       	push   $0xf01064e9
f010265c:	68 16 04 00 00       	push   $0x416
f0102661:	68 bd 64 10 f0       	push   $0xf01064bd
f0102666:	e8 29 da ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f010266b:	68 54 67 10 f0       	push   $0xf0106754
f0102670:	68 e9 64 10 f0       	push   $0xf01064e9
f0102675:	68 17 04 00 00       	push   $0x417
f010267a:	68 bd 64 10 f0       	push   $0xf01064bd
f010267f:	e8 10 da ff ff       	call   f0100094 <_panic>
	assert((pp = page_alloc(0)) && pp == pp1);
f0102684:	68 d4 60 10 f0       	push   $0xf01060d4
f0102689:	68 e9 64 10 f0       	push   $0xf01064e9
f010268e:	68 1a 04 00 00       	push   $0x41a
f0102693:	68 bd 64 10 f0       	push   $0xf01064bd
f0102698:	e8 f7 d9 ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f010269d:	68 a8 66 10 f0       	push   $0xf01066a8
f01026a2:	68 e9 64 10 f0       	push   $0xf01064e9
f01026a7:	68 1d 04 00 00       	push   $0x41d
f01026ac:	68 bd 64 10 f0       	push   $0xf01064bd
f01026b1:	e8 de d9 ff ff       	call   f0100094 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01026b6:	68 78 5d 10 f0       	push   $0xf0105d78
f01026bb:	68 e9 64 10 f0       	push   $0xf01064e9
f01026c0:	68 20 04 00 00       	push   $0x420
f01026c5:	68 bd 64 10 f0       	push   $0xf01064bd
f01026ca:	e8 c5 d9 ff ff       	call   f0100094 <_panic>
	assert(pp0->pp_ref == 1);
f01026cf:	68 0b 67 10 f0       	push   $0xf010670b
f01026d4:	68 e9 64 10 f0       	push   $0xf01064e9
f01026d9:	68 22 04 00 00       	push   $0x422
f01026de:	68 bd 64 10 f0       	push   $0xf01064bd
f01026e3:	e8 ac d9 ff ff       	call   f0100094 <_panic>
f01026e8:	50                   	push   %eax
f01026e9:	68 f4 55 10 f0       	push   $0xf01055f4
f01026ee:	68 29 04 00 00       	push   $0x429
f01026f3:	68 bd 64 10 f0       	push   $0xf01064bd
f01026f8:	e8 97 d9 ff ff       	call   f0100094 <_panic>
	assert(ptep == ptep1 + PTX(va));
f01026fd:	68 97 67 10 f0       	push   $0xf0106797
f0102702:	68 e9 64 10 f0       	push   $0xf01064e9
f0102707:	68 2a 04 00 00       	push   $0x42a
f010270c:	68 bd 64 10 f0       	push   $0xf01064bd
f0102711:	e8 7e d9 ff ff       	call   f0100094 <_panic>
f0102716:	50                   	push   %eax
f0102717:	68 f4 55 10 f0       	push   $0xf01055f4
f010271c:	6a 58                	push   $0x58
f010271e:	68 cf 64 10 f0       	push   $0xf01064cf
f0102723:	e8 6c d9 ff ff       	call   f0100094 <_panic>
f0102728:	50                   	push   %eax
f0102729:	68 f4 55 10 f0       	push   $0xf01055f4
f010272e:	6a 58                	push   $0x58
f0102730:	68 cf 64 10 f0       	push   $0xf01064cf
f0102735:	e8 5a d9 ff ff       	call   f0100094 <_panic>
		assert((ptep[i] & PTE_P) == 0);
f010273a:	68 af 67 10 f0       	push   $0xf01067af
f010273f:	68 e9 64 10 f0       	push   $0xf01064e9
f0102744:	68 34 04 00 00       	push   $0x434
f0102749:	68 bd 64 10 f0       	push   $0xf01064bd
f010274e:	e8 41 d9 ff ff       	call   f0100094 <_panic>
	assert(mm1 >= MMIOBASE && mm1 + 8192 < MMIOLIM);
f0102753:	68 f8 60 10 f0       	push   $0xf01060f8
f0102758:	68 e9 64 10 f0       	push   $0xf01064e9
f010275d:	68 44 04 00 00       	push   $0x444
f0102762:	68 bd 64 10 f0       	push   $0xf01064bd
f0102767:	e8 28 d9 ff ff       	call   f0100094 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8192 < MMIOLIM);
f010276c:	68 20 61 10 f0       	push   $0xf0106120
f0102771:	68 e9 64 10 f0       	push   $0xf01064e9
f0102776:	68 45 04 00 00       	push   $0x445
f010277b:	68 bd 64 10 f0       	push   $0xf01064bd
f0102780:	e8 0f d9 ff ff       	call   f0100094 <_panic>
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0102785:	68 48 61 10 f0       	push   $0xf0106148
f010278a:	68 e9 64 10 f0       	push   $0xf01064e9
f010278f:	68 47 04 00 00       	push   $0x447
f0102794:	68 bd 64 10 f0       	push   $0xf01064bd
f0102799:	e8 f6 d8 ff ff       	call   f0100094 <_panic>
	assert(mm1 + 8192 <= mm2);
f010279e:	68 c6 67 10 f0       	push   $0xf01067c6
f01027a3:	68 e9 64 10 f0       	push   $0xf01064e9
f01027a8:	68 49 04 00 00       	push   $0x449
f01027ad:	68 bd 64 10 f0       	push   $0xf01064bd
f01027b2:	e8 dd d8 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f01027b7:	68 70 61 10 f0       	push   $0xf0106170
f01027bc:	68 e9 64 10 f0       	push   $0xf01064e9
f01027c1:	68 4b 04 00 00       	push   $0x44b
f01027c6:	68 bd 64 10 f0       	push   $0xf01064bd
f01027cb:	e8 c4 d8 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f01027d0:	68 94 61 10 f0       	push   $0xf0106194
f01027d5:	68 e9 64 10 f0       	push   $0xf01064e9
f01027da:	68 4c 04 00 00       	push   $0x44c
f01027df:	68 bd 64 10 f0       	push   $0xf01064bd
f01027e4:	e8 ab d8 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f01027e9:	68 c4 61 10 f0       	push   $0xf01061c4
f01027ee:	68 e9 64 10 f0       	push   $0xf01064e9
f01027f3:	68 4d 04 00 00       	push   $0x44d
f01027f8:	68 bd 64 10 f0       	push   $0xf01064bd
f01027fd:	e8 92 d8 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0102802:	68 e8 61 10 f0       	push   $0xf01061e8
f0102807:	68 e9 64 10 f0       	push   $0xf01064e9
f010280c:	68 4e 04 00 00       	push   $0x44e
f0102811:	68 bd 64 10 f0       	push   $0xf01064bd
f0102816:	e8 79 d8 ff ff       	call   f0100094 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f010281b:	68 14 62 10 f0       	push   $0xf0106214
f0102820:	68 e9 64 10 f0       	push   $0xf01064e9
f0102825:	68 50 04 00 00       	push   $0x450
f010282a:	68 bd 64 10 f0       	push   $0xf01064bd
f010282f:	e8 60 d8 ff ff       	call   f0100094 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102834:	68 58 62 10 f0       	push   $0xf0106258
f0102839:	68 e9 64 10 f0       	push   $0xf01064e9
f010283e:	68 51 04 00 00       	push   $0x451
f0102843:	68 bd 64 10 f0       	push   $0xf01064bd
f0102848:	e8 47 d8 ff ff       	call   f0100094 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010284d:	50                   	push   %eax
f010284e:	68 18 56 10 f0       	push   $0xf0105618
f0102853:	68 d1 00 00 00       	push   $0xd1
f0102858:	68 bd 64 10 f0       	push   $0xf01064bd
f010285d:	e8 32 d8 ff ff       	call   f0100094 <_panic>
f0102862:	50                   	push   %eax
f0102863:	68 18 56 10 f0       	push   $0xf0105618
f0102868:	68 da 00 00 00       	push   $0xda
f010286d:	68 bd 64 10 f0       	push   $0xf01064bd
f0102872:	e8 1d d8 ff ff       	call   f0100094 <_panic>
f0102877:	50                   	push   %eax
f0102878:	68 18 56 10 f0       	push   $0xf0105618
f010287d:	68 e7 00 00 00       	push   $0xe7
f0102882:	68 bd 64 10 f0       	push   $0xf01064bd
f0102887:	e8 08 d8 ff ff       	call   f0100094 <_panic>
f010288c:	56                   	push   %esi
f010288d:	68 18 56 10 f0       	push   $0xf0105618
f0102892:	68 60 03 00 00       	push   $0x360
f0102897:	68 bd 64 10 f0       	push   $0xf01064bd
f010289c:	e8 f3 d7 ff ff       	call   f0100094 <_panic>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01028a1:	68 8c 62 10 f0       	push   $0xf010628c
f01028a6:	68 e9 64 10 f0       	push   $0xf01064e9
f01028ab:	68 60 03 00 00       	push   $0x360
f01028b0:	68 bd 64 10 f0       	push   $0xf01064bd
f01028b5:	e8 da d7 ff ff       	call   f0100094 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f01028ba:	a1 44 12 23 f0       	mov    0xf0231244,%eax
f01028bf:	89 45 d0             	mov    %eax,-0x30(%ebp)
	if ((uint32_t)kva < KERNBASE)
f01028c2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01028c5:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f01028ca:	8d b0 00 00 40 21    	lea    0x21400000(%eax),%esi
f01028d0:	89 da                	mov    %ebx,%edx
f01028d2:	89 f8                	mov    %edi,%eax
f01028d4:	e8 09 e2 ff ff       	call   f0100ae2 <check_va2pa>
f01028d9:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f01028e0:	76 3d                	jbe    f010291f <mem_init+0x1611>
f01028e2:	8d 14 1e             	lea    (%esi,%ebx,1),%edx
f01028e5:	39 d0                	cmp    %edx,%eax
f01028e7:	75 4d                	jne    f0102936 <mem_init+0x1628>
f01028e9:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE) {
f01028ef:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f01028f5:	75 d9                	jne    f01028d0 <mem_init+0x15c2>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01028f7:	8b 75 c8             	mov    -0x38(%ebp),%esi
f01028fa:	c1 e6 0c             	shl    $0xc,%esi
f01028fd:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102902:	39 f3                	cmp    %esi,%ebx
f0102904:	73 62                	jae    f0102968 <mem_init+0x165a>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102906:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f010290c:	89 f8                	mov    %edi,%eax
f010290e:	e8 cf e1 ff ff       	call   f0100ae2 <check_va2pa>
f0102913:	39 c3                	cmp    %eax,%ebx
f0102915:	75 38                	jne    f010294f <mem_init+0x1641>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102917:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010291d:	eb e3                	jmp    f0102902 <mem_init+0x15f4>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010291f:	ff 75 d0             	pushl  -0x30(%ebp)
f0102922:	68 18 56 10 f0       	push   $0xf0105618
f0102927:	68 67 03 00 00       	push   $0x367
f010292c:	68 bd 64 10 f0       	push   $0xf01064bd
f0102931:	e8 5e d7 ff ff       	call   f0100094 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102936:	68 c0 62 10 f0       	push   $0xf01062c0
f010293b:	68 e9 64 10 f0       	push   $0xf01064e9
f0102940:	68 67 03 00 00       	push   $0x367
f0102945:	68 bd 64 10 f0       	push   $0xf01064bd
f010294a:	e8 45 d7 ff ff       	call   f0100094 <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f010294f:	68 f4 62 10 f0       	push   $0xf01062f4
f0102954:	68 e9 64 10 f0       	push   $0xf01064e9
f0102959:	68 6e 03 00 00       	push   $0x36e
f010295e:	68 bd 64 10 f0       	push   $0xf01064bd
f0102963:	e8 2c d7 ff ff       	call   f0100094 <_panic>
f0102968:	c7 45 d0 00 30 23 f0 	movl   $0xf0233000,-0x30(%ebp)
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f010296f:	b8 00 30 23 f0       	mov    $0xf0233000,%eax
f0102974:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f0102979:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f010297c:	89 c7                	mov    %eax,%edi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f010297e:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f0102981:	89 f3                	mov    %esi,%ebx
f0102983:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102986:	05 00 80 00 20       	add    $0x20008000,%eax
f010298b:	89 45 cc             	mov    %eax,-0x34(%ebp)
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f010298e:	8d 86 00 80 00 00    	lea    0x8000(%esi),%eax
f0102994:	89 45 c8             	mov    %eax,-0x38(%ebp)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102997:	89 da                	mov    %ebx,%edx
f0102999:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010299c:	e8 41 e1 ff ff       	call   f0100ae2 <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f01029a1:	81 ff ff ff ff ef    	cmp    $0xefffffff,%edi
f01029a7:	0f 86 a7 00 00 00    	jbe    f0102a54 <mem_init+0x1746>
f01029ad:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f01029b0:	8d 14 19             	lea    (%ecx,%ebx,1),%edx
f01029b3:	39 d0                	cmp    %edx,%eax
f01029b5:	0f 85 b0 00 00 00    	jne    f0102a6b <mem_init+0x175d>
f01029bb:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f01029c1:	3b 5d c8             	cmp    -0x38(%ebp),%ebx
f01029c4:	75 d1                	jne    f0102997 <mem_init+0x1689>
f01029c6:	8d 9e 00 80 ff ff    	lea    -0x8000(%esi),%ebx
			assert(check_va2pa(pgdir, base + i) == ~0);
f01029cc:	89 da                	mov    %ebx,%edx
f01029ce:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01029d1:	e8 0c e1 ff ff       	call   f0100ae2 <check_va2pa>
f01029d6:	83 f8 ff             	cmp    $0xffffffff,%eax
f01029d9:	0f 85 a5 00 00 00    	jne    f0102a84 <mem_init+0x1776>
f01029df:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f01029e5:	39 f3                	cmp    %esi,%ebx
f01029e7:	75 e3                	jne    f01029cc <mem_init+0x16be>
f01029e9:	81 ee 00 00 01 00    	sub    $0x10000,%esi
f01029ef:	81 45 d0 00 80 01 00 	addl   $0x18000,-0x30(%ebp)
f01029f6:	81 c7 00 80 00 00    	add    $0x8000,%edi
	for (n = 0; n < NCPU; n++) {
f01029fc:	81 ff 00 30 27 f0    	cmp    $0xf0273000,%edi
f0102a02:	0f 85 76 ff ff ff    	jne    f010297e <mem_init+0x1670>
f0102a08:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102a0b:	bb 00 80 ff ef       	mov    $0xefff8000,%ebx
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102a10:	b8 00 70 11 f0       	mov    $0xf0117000,%eax
f0102a15:	8d b0 00 80 00 20    	lea    0x20008000(%eax),%esi
f0102a1b:	89 da                	mov    %ebx,%edx
f0102a1d:	89 f8                	mov    %edi,%eax
f0102a1f:	e8 be e0 ff ff       	call   f0100ae2 <check_va2pa>
f0102a24:	8d 14 1e             	lea    (%esi,%ebx,1),%edx
f0102a27:	39 d0                	cmp    %edx,%eax
f0102a29:	75 72                	jne    f0102a9d <mem_init+0x178f>
f0102a2b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102a31:	81 fb 00 00 00 f0    	cmp    $0xf0000000,%ebx
f0102a37:	75 e2                	jne    f0102a1b <mem_init+0x170d>
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102a39:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f0102a3e:	89 f8                	mov    %edi,%eax
f0102a40:	e8 9d e0 ff ff       	call   f0100ae2 <check_va2pa>
f0102a45:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102a48:	75 6c                	jne    f0102ab6 <mem_init+0x17a8>
	for (i = 0; i < NPDENTRIES; i++) {
f0102a4a:	b8 00 00 00 00       	mov    $0x0,%eax
f0102a4f:	e9 b1 00 00 00       	jmp    f0102b05 <mem_init+0x17f7>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102a54:	ff 75 c4             	pushl  -0x3c(%ebp)
f0102a57:	68 18 56 10 f0       	push   $0xf0105618
f0102a5c:	68 77 03 00 00       	push   $0x377
f0102a61:	68 bd 64 10 f0       	push   $0xf01064bd
f0102a66:	e8 29 d6 ff ff       	call   f0100094 <_panic>
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102a6b:	68 1c 63 10 f0       	push   $0xf010631c
f0102a70:	68 e9 64 10 f0       	push   $0xf01064e9
f0102a75:	68 77 03 00 00       	push   $0x377
f0102a7a:	68 bd 64 10 f0       	push   $0xf01064bd
f0102a7f:	e8 10 d6 ff ff       	call   f0100094 <_panic>
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102a84:	68 64 63 10 f0       	push   $0xf0106364
f0102a89:	68 e9 64 10 f0       	push   $0xf01064e9
f0102a8e:	68 79 03 00 00       	push   $0x379
f0102a93:	68 bd 64 10 f0       	push   $0xf01064bd
f0102a98:	e8 f7 d5 ff ff       	call   f0100094 <_panic>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102a9d:	68 88 63 10 f0       	push   $0xf0106388
f0102aa2:	68 e9 64 10 f0       	push   $0xf01064e9
f0102aa7:	68 7c 03 00 00       	push   $0x37c
f0102aac:	68 bd 64 10 f0       	push   $0xf01064bd
f0102ab1:	e8 de d5 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102ab6:	68 d0 63 10 f0       	push   $0xf01063d0
f0102abb:	68 e9 64 10 f0       	push   $0xf01064e9
f0102ac0:	68 7d 03 00 00       	push   $0x37d
f0102ac5:	68 bd 64 10 f0       	push   $0xf01064bd
f0102aca:	e8 c5 d5 ff ff       	call   f0100094 <_panic>
			assert(pgdir[i] & PTE_P);
f0102acf:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f0102ad3:	75 48                	jne    f0102b1d <mem_init+0x180f>
f0102ad5:	68 f1 67 10 f0       	push   $0xf01067f1
f0102ada:	68 e9 64 10 f0       	push   $0xf01064e9
f0102adf:	68 88 03 00 00       	push   $0x388
f0102ae4:	68 bd 64 10 f0       	push   $0xf01064bd
f0102ae9:	e8 a6 d5 ff ff       	call   f0100094 <_panic>
				assert(pgdir[i] & PTE_P);
f0102aee:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0102af1:	f6 c2 01             	test   $0x1,%dl
f0102af4:	74 2c                	je     f0102b22 <mem_init+0x1814>
				assert(pgdir[i] & PTE_W);
f0102af6:	f6 c2 02             	test   $0x2,%dl
f0102af9:	74 40                	je     f0102b3b <mem_init+0x182d>
	for (i = 0; i < NPDENTRIES; i++) {
f0102afb:	83 c0 01             	add    $0x1,%eax
f0102afe:	3d 00 04 00 00       	cmp    $0x400,%eax
f0102b03:	74 68                	je     f0102b6d <mem_init+0x185f>
		switch (i) {
f0102b05:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0102b0b:	83 fa 04             	cmp    $0x4,%edx
f0102b0e:	76 bf                	jbe    f0102acf <mem_init+0x17c1>
			if (i >= PDX(KERNBASE)) {
f0102b10:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102b15:	77 d7                	ja     f0102aee <mem_init+0x17e0>
				assert(pgdir[i] == 0);
f0102b17:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f0102b1b:	75 37                	jne    f0102b54 <mem_init+0x1846>
	for (i = 0; i < NPDENTRIES; i++) {
f0102b1d:	83 c0 01             	add    $0x1,%eax
f0102b20:	eb e3                	jmp    f0102b05 <mem_init+0x17f7>
				assert(pgdir[i] & PTE_P);
f0102b22:	68 f1 67 10 f0       	push   $0xf01067f1
f0102b27:	68 e9 64 10 f0       	push   $0xf01064e9
f0102b2c:	68 8c 03 00 00       	push   $0x38c
f0102b31:	68 bd 64 10 f0       	push   $0xf01064bd
f0102b36:	e8 59 d5 ff ff       	call   f0100094 <_panic>
				assert(pgdir[i] & PTE_W);
f0102b3b:	68 02 68 10 f0       	push   $0xf0106802
f0102b40:	68 e9 64 10 f0       	push   $0xf01064e9
f0102b45:	68 8d 03 00 00       	push   $0x38d
f0102b4a:	68 bd 64 10 f0       	push   $0xf01064bd
f0102b4f:	e8 40 d5 ff ff       	call   f0100094 <_panic>
				assert(pgdir[i] == 0);
f0102b54:	68 13 68 10 f0       	push   $0xf0106813
f0102b59:	68 e9 64 10 f0       	push   $0xf01064e9
f0102b5e:	68 8f 03 00 00       	push   $0x38f
f0102b63:	68 bd 64 10 f0       	push   $0xf01064bd
f0102b68:	e8 27 d5 ff ff       	call   f0100094 <_panic>
	cprintf("check_kern_pgdir() succeeded!\n");
f0102b6d:	83 ec 0c             	sub    $0xc,%esp
f0102b70:	68 00 64 10 f0       	push   $0xf0106400
f0102b75:	e8 8b 0c 00 00       	call   f0103805 <cprintf>
	lcr3(PADDR(kern_pgdir));
f0102b7a:	a1 0c 1f 23 f0       	mov    0xf0231f0c,%eax
	if ((uint32_t)kva < KERNBASE)
f0102b7f:	83 c4 10             	add    $0x10,%esp
f0102b82:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102b87:	0f 86 fb 01 00 00    	jbe    f0102d88 <mem_init+0x1a7a>
	return (physaddr_t)kva - KERNBASE;
f0102b8d:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102b92:	0f 22 d8             	mov    %eax,%cr3
	check_page_free_list(0);
f0102b95:	b8 00 00 00 00       	mov    $0x0,%eax
f0102b9a:	e8 a7 df ff ff       	call   f0100b46 <check_page_free_list>
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0102b9f:	0f 20 c0             	mov    %cr0,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f0102ba2:	83 e0 f3             	and    $0xfffffff3,%eax
f0102ba5:	0d 23 00 05 80       	or     $0x80050023,%eax
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0102baa:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102bad:	83 ec 0c             	sub    $0xc,%esp
f0102bb0:	6a 00                	push   $0x0
f0102bb2:	e8 cd e3 ff ff       	call   f0100f84 <page_alloc>
f0102bb7:	89 c6                	mov    %eax,%esi
f0102bb9:	83 c4 10             	add    $0x10,%esp
f0102bbc:	85 c0                	test   %eax,%eax
f0102bbe:	0f 84 d9 01 00 00    	je     f0102d9d <mem_init+0x1a8f>
	assert((pp1 = page_alloc(0)));
f0102bc4:	83 ec 0c             	sub    $0xc,%esp
f0102bc7:	6a 00                	push   $0x0
f0102bc9:	e8 b6 e3 ff ff       	call   f0100f84 <page_alloc>
f0102bce:	89 c7                	mov    %eax,%edi
f0102bd0:	83 c4 10             	add    $0x10,%esp
f0102bd3:	85 c0                	test   %eax,%eax
f0102bd5:	0f 84 db 01 00 00    	je     f0102db6 <mem_init+0x1aa8>
	assert((pp2 = page_alloc(0)));
f0102bdb:	83 ec 0c             	sub    $0xc,%esp
f0102bde:	6a 00                	push   $0x0
f0102be0:	e8 9f e3 ff ff       	call   f0100f84 <page_alloc>
f0102be5:	89 c3                	mov    %eax,%ebx
f0102be7:	83 c4 10             	add    $0x10,%esp
f0102bea:	85 c0                	test   %eax,%eax
f0102bec:	0f 84 dd 01 00 00    	je     f0102dcf <mem_init+0x1ac1>
	page_free(pp0);
f0102bf2:	83 ec 0c             	sub    $0xc,%esp
f0102bf5:	56                   	push   %esi
f0102bf6:	e8 fb e3 ff ff       	call   f0100ff6 <page_free>
	return (pp - pages) << PGSHIFT;
f0102bfb:	89 f8                	mov    %edi,%eax
f0102bfd:	2b 05 10 1f 23 f0    	sub    0xf0231f10,%eax
f0102c03:	c1 f8 03             	sar    $0x3,%eax
f0102c06:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102c09:	89 c2                	mov    %eax,%edx
f0102c0b:	c1 ea 0c             	shr    $0xc,%edx
f0102c0e:	83 c4 10             	add    $0x10,%esp
f0102c11:	3b 15 08 1f 23 f0    	cmp    0xf0231f08,%edx
f0102c17:	0f 83 cb 01 00 00    	jae    f0102de8 <mem_init+0x1ada>
	memset(page2kva(pp1), 1, PGSIZE);
f0102c1d:	83 ec 04             	sub    $0x4,%esp
f0102c20:	68 00 10 00 00       	push   $0x1000
f0102c25:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0102c27:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102c2c:	50                   	push   %eax
f0102c2d:	e8 c8 1c 00 00       	call   f01048fa <memset>
	return (pp - pages) << PGSHIFT;
f0102c32:	89 d8                	mov    %ebx,%eax
f0102c34:	2b 05 10 1f 23 f0    	sub    0xf0231f10,%eax
f0102c3a:	c1 f8 03             	sar    $0x3,%eax
f0102c3d:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102c40:	89 c2                	mov    %eax,%edx
f0102c42:	c1 ea 0c             	shr    $0xc,%edx
f0102c45:	83 c4 10             	add    $0x10,%esp
f0102c48:	3b 15 08 1f 23 f0    	cmp    0xf0231f08,%edx
f0102c4e:	0f 83 a6 01 00 00    	jae    f0102dfa <mem_init+0x1aec>
	memset(page2kva(pp2), 2, PGSIZE);
f0102c54:	83 ec 04             	sub    $0x4,%esp
f0102c57:	68 00 10 00 00       	push   $0x1000
f0102c5c:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f0102c5e:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102c63:	50                   	push   %eax
f0102c64:	e8 91 1c 00 00       	call   f01048fa <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102c69:	6a 02                	push   $0x2
f0102c6b:	68 00 10 00 00       	push   $0x1000
f0102c70:	57                   	push   %edi
f0102c71:	ff 35 0c 1f 23 f0    	pushl  0xf0231f0c
f0102c77:	e8 c9 e5 ff ff       	call   f0101245 <page_insert>
	assert(pp1->pp_ref == 1);
f0102c7c:	83 c4 20             	add    $0x20,%esp
f0102c7f:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102c84:	0f 85 82 01 00 00    	jne    f0102e0c <mem_init+0x1afe>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102c8a:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102c91:	01 01 01 
f0102c94:	0f 85 8b 01 00 00    	jne    f0102e25 <mem_init+0x1b17>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102c9a:	6a 02                	push   $0x2
f0102c9c:	68 00 10 00 00       	push   $0x1000
f0102ca1:	53                   	push   %ebx
f0102ca2:	ff 35 0c 1f 23 f0    	pushl  0xf0231f0c
f0102ca8:	e8 98 e5 ff ff       	call   f0101245 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102cad:	83 c4 10             	add    $0x10,%esp
f0102cb0:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102cb7:	02 02 02 
f0102cba:	0f 85 7e 01 00 00    	jne    f0102e3e <mem_init+0x1b30>
	assert(pp2->pp_ref == 1);
f0102cc0:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102cc5:	0f 85 8c 01 00 00    	jne    f0102e57 <mem_init+0x1b49>
	assert(pp1->pp_ref == 0);
f0102ccb:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102cd0:	0f 85 9a 01 00 00    	jne    f0102e70 <mem_init+0x1b62>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102cd6:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102cdd:	03 03 03 
	return (pp - pages) << PGSHIFT;
f0102ce0:	89 d8                	mov    %ebx,%eax
f0102ce2:	2b 05 10 1f 23 f0    	sub    0xf0231f10,%eax
f0102ce8:	c1 f8 03             	sar    $0x3,%eax
f0102ceb:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102cee:	89 c2                	mov    %eax,%edx
f0102cf0:	c1 ea 0c             	shr    $0xc,%edx
f0102cf3:	3b 15 08 1f 23 f0    	cmp    0xf0231f08,%edx
f0102cf9:	0f 83 8a 01 00 00    	jae    f0102e89 <mem_init+0x1b7b>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102cff:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102d06:	03 03 03 
f0102d09:	0f 85 8c 01 00 00    	jne    f0102e9b <mem_init+0x1b8d>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102d0f:	83 ec 08             	sub    $0x8,%esp
f0102d12:	68 00 10 00 00       	push   $0x1000
f0102d17:	ff 35 0c 1f 23 f0    	pushl  0xf0231f0c
f0102d1d:	e8 dd e4 ff ff       	call   f01011ff <page_remove>
	assert(pp2->pp_ref == 0);
f0102d22:	83 c4 10             	add    $0x10,%esp
f0102d25:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102d2a:	0f 85 84 01 00 00    	jne    f0102eb4 <mem_init+0x1ba6>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102d30:	8b 0d 0c 1f 23 f0    	mov    0xf0231f0c,%ecx
f0102d36:	8b 11                	mov    (%ecx),%edx
f0102d38:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	return (pp - pages) << PGSHIFT;
f0102d3e:	89 f0                	mov    %esi,%eax
f0102d40:	2b 05 10 1f 23 f0    	sub    0xf0231f10,%eax
f0102d46:	c1 f8 03             	sar    $0x3,%eax
f0102d49:	c1 e0 0c             	shl    $0xc,%eax
f0102d4c:	39 c2                	cmp    %eax,%edx
f0102d4e:	0f 85 79 01 00 00    	jne    f0102ecd <mem_init+0x1bbf>
	kern_pgdir[0] = 0;
f0102d54:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102d5a:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102d5f:	0f 85 81 01 00 00    	jne    f0102ee6 <mem_init+0x1bd8>
	pp0->pp_ref = 0;
f0102d65:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f0102d6b:	83 ec 0c             	sub    $0xc,%esp
f0102d6e:	56                   	push   %esi
f0102d6f:	e8 82 e2 ff ff       	call   f0100ff6 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102d74:	c7 04 24 94 64 10 f0 	movl   $0xf0106494,(%esp)
f0102d7b:	e8 85 0a 00 00       	call   f0103805 <cprintf>
}
f0102d80:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102d83:	5b                   	pop    %ebx
f0102d84:	5e                   	pop    %esi
f0102d85:	5f                   	pop    %edi
f0102d86:	5d                   	pop    %ebp
f0102d87:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102d88:	50                   	push   %eax
f0102d89:	68 18 56 10 f0       	push   $0xf0105618
f0102d8e:	68 03 01 00 00       	push   $0x103
f0102d93:	68 bd 64 10 f0       	push   $0xf01064bd
f0102d98:	e8 f7 d2 ff ff       	call   f0100094 <_panic>
	assert((pp0 = page_alloc(0)));
f0102d9d:	68 fd 65 10 f0       	push   $0xf01065fd
f0102da2:	68 e9 64 10 f0       	push   $0xf01064e9
f0102da7:	68 66 04 00 00       	push   $0x466
f0102dac:	68 bd 64 10 f0       	push   $0xf01064bd
f0102db1:	e8 de d2 ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f0102db6:	68 13 66 10 f0       	push   $0xf0106613
f0102dbb:	68 e9 64 10 f0       	push   $0xf01064e9
f0102dc0:	68 67 04 00 00       	push   $0x467
f0102dc5:	68 bd 64 10 f0       	push   $0xf01064bd
f0102dca:	e8 c5 d2 ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f0102dcf:	68 29 66 10 f0       	push   $0xf0106629
f0102dd4:	68 e9 64 10 f0       	push   $0xf01064e9
f0102dd9:	68 68 04 00 00       	push   $0x468
f0102dde:	68 bd 64 10 f0       	push   $0xf01064bd
f0102de3:	e8 ac d2 ff ff       	call   f0100094 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102de8:	50                   	push   %eax
f0102de9:	68 f4 55 10 f0       	push   $0xf01055f4
f0102dee:	6a 58                	push   $0x58
f0102df0:	68 cf 64 10 f0       	push   $0xf01064cf
f0102df5:	e8 9a d2 ff ff       	call   f0100094 <_panic>
f0102dfa:	50                   	push   %eax
f0102dfb:	68 f4 55 10 f0       	push   $0xf01055f4
f0102e00:	6a 58                	push   $0x58
f0102e02:	68 cf 64 10 f0       	push   $0xf01064cf
f0102e07:	e8 88 d2 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 1);
f0102e0c:	68 fa 66 10 f0       	push   $0xf01066fa
f0102e11:	68 e9 64 10 f0       	push   $0xf01064e9
f0102e16:	68 6d 04 00 00       	push   $0x46d
f0102e1b:	68 bd 64 10 f0       	push   $0xf01064bd
f0102e20:	e8 6f d2 ff ff       	call   f0100094 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102e25:	68 20 64 10 f0       	push   $0xf0106420
f0102e2a:	68 e9 64 10 f0       	push   $0xf01064e9
f0102e2f:	68 6e 04 00 00       	push   $0x46e
f0102e34:	68 bd 64 10 f0       	push   $0xf01064bd
f0102e39:	e8 56 d2 ff ff       	call   f0100094 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102e3e:	68 44 64 10 f0       	push   $0xf0106444
f0102e43:	68 e9 64 10 f0       	push   $0xf01064e9
f0102e48:	68 70 04 00 00       	push   $0x470
f0102e4d:	68 bd 64 10 f0       	push   $0xf01064bd
f0102e52:	e8 3d d2 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f0102e57:	68 1c 67 10 f0       	push   $0xf010671c
f0102e5c:	68 e9 64 10 f0       	push   $0xf01064e9
f0102e61:	68 71 04 00 00       	push   $0x471
f0102e66:	68 bd 64 10 f0       	push   $0xf01064bd
f0102e6b:	e8 24 d2 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 0);
f0102e70:	68 86 67 10 f0       	push   $0xf0106786
f0102e75:	68 e9 64 10 f0       	push   $0xf01064e9
f0102e7a:	68 72 04 00 00       	push   $0x472
f0102e7f:	68 bd 64 10 f0       	push   $0xf01064bd
f0102e84:	e8 0b d2 ff ff       	call   f0100094 <_panic>
f0102e89:	50                   	push   %eax
f0102e8a:	68 f4 55 10 f0       	push   $0xf01055f4
f0102e8f:	6a 58                	push   $0x58
f0102e91:	68 cf 64 10 f0       	push   $0xf01064cf
f0102e96:	e8 f9 d1 ff ff       	call   f0100094 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102e9b:	68 68 64 10 f0       	push   $0xf0106468
f0102ea0:	68 e9 64 10 f0       	push   $0xf01064e9
f0102ea5:	68 74 04 00 00       	push   $0x474
f0102eaa:	68 bd 64 10 f0       	push   $0xf01064bd
f0102eaf:	e8 e0 d1 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f0102eb4:	68 54 67 10 f0       	push   $0xf0106754
f0102eb9:	68 e9 64 10 f0       	push   $0xf01064e9
f0102ebe:	68 76 04 00 00       	push   $0x476
f0102ec3:	68 bd 64 10 f0       	push   $0xf01064bd
f0102ec8:	e8 c7 d1 ff ff       	call   f0100094 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102ecd:	68 78 5d 10 f0       	push   $0xf0105d78
f0102ed2:	68 e9 64 10 f0       	push   $0xf01064e9
f0102ed7:	68 79 04 00 00       	push   $0x479
f0102edc:	68 bd 64 10 f0       	push   $0xf01064bd
f0102ee1:	e8 ae d1 ff ff       	call   f0100094 <_panic>
	assert(pp0->pp_ref == 1);
f0102ee6:	68 0b 67 10 f0       	push   $0xf010670b
f0102eeb:	68 e9 64 10 f0       	push   $0xf01064e9
f0102ef0:	68 7b 04 00 00       	push   $0x47b
f0102ef5:	68 bd 64 10 f0       	push   $0xf01064bd
f0102efa:	e8 95 d1 ff ff       	call   f0100094 <_panic>

f0102eff <user_mem_check>:
}
f0102eff:	b8 00 00 00 00       	mov    $0x0,%eax
f0102f04:	c3                   	ret    

f0102f05 <user_mem_assert>:
}
f0102f05:	c3                   	ret    

f0102f06 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0102f06:	55                   	push   %ebp
f0102f07:	89 e5                	mov    %esp,%ebp
f0102f09:	57                   	push   %edi
f0102f0a:	56                   	push   %esi
f0102f0b:	53                   	push   %ebx
f0102f0c:	83 ec 0c             	sub    $0xc,%esp
f0102f0f:	89 c7                	mov    %eax,%edi
	// LAB 3: Your code here.
	void* i;
	for (i = ROUNDDOWN(va, PGSIZE); i < ROUNDUP(va + len, PGSIZE); i+=PGSIZE){
f0102f11:	89 d3                	mov    %edx,%ebx
f0102f13:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0102f19:	8d b4 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%esi
f0102f20:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
f0102f26:	39 f3                	cmp    %esi,%ebx
f0102f28:	73 5c                	jae    f0102f86 <region_alloc+0x80>
		struct PageInfo *pginfo = page_alloc(0);
f0102f2a:	83 ec 0c             	sub    $0xc,%esp
f0102f2d:	6a 00                	push   $0x0
f0102f2f:	e8 50 e0 ff ff       	call   f0100f84 <page_alloc>
		if (!pginfo) {
f0102f34:	83 c4 10             	add    $0x10,%esp
f0102f37:	85 c0                	test   %eax,%eax
f0102f39:	74 20                	je     f0102f5b <region_alloc+0x55>
			 panic("region_alloc:%e", -E_NO_MEM);
		}
		pginfo->pp_ref++;
f0102f3b:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
		int r = page_insert(e->env_pgdir, pginfo, i, PTE_W | PTE_U | PTE_P);
f0102f40:	6a 07                	push   $0x7
f0102f42:	53                   	push   %ebx
f0102f43:	50                   	push   %eax
f0102f44:	ff 77 60             	pushl  0x60(%edi)
f0102f47:	e8 f9 e2 ff ff       	call   f0101245 <page_insert>
		if (r < 0) {
f0102f4c:	83 c4 10             	add    $0x10,%esp
f0102f4f:	85 c0                	test   %eax,%eax
f0102f51:	78 1e                	js     f0102f71 <region_alloc+0x6b>
	for (i = ROUNDDOWN(va, PGSIZE); i < ROUNDUP(va + len, PGSIZE); i+=PGSIZE){
f0102f53:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102f59:	eb cb                	jmp    f0102f26 <region_alloc+0x20>
			 panic("region_alloc:%e", -E_NO_MEM);
f0102f5b:	6a fc                	push   $0xfffffffc
f0102f5d:	68 21 68 10 f0       	push   $0xf0106821
f0102f62:	68 22 01 00 00       	push   $0x122
f0102f67:	68 31 68 10 f0       	push   $0xf0106831
f0102f6c:	e8 23 d1 ff ff       	call   f0100094 <_panic>
			 panic("region_alloc:%e", r);
f0102f71:	50                   	push   %eax
f0102f72:	68 21 68 10 f0       	push   $0xf0106821
f0102f77:	68 27 01 00 00       	push   $0x127
f0102f7c:	68 31 68 10 f0       	push   $0xf0106831
f0102f81:	e8 0e d1 ff ff       	call   f0100094 <_panic>
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
}
f0102f86:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102f89:	5b                   	pop    %ebx
f0102f8a:	5e                   	pop    %esi
f0102f8b:	5f                   	pop    %edi
f0102f8c:	5d                   	pop    %ebp
f0102f8d:	c3                   	ret    

f0102f8e <envid2env>:
{
f0102f8e:	55                   	push   %ebp
f0102f8f:	89 e5                	mov    %esp,%ebp
f0102f91:	56                   	push   %esi
f0102f92:	53                   	push   %ebx
f0102f93:	8b 45 08             	mov    0x8(%ebp),%eax
f0102f96:	8b 55 10             	mov    0x10(%ebp),%edx
	if (envid == 0) {
f0102f99:	85 c0                	test   %eax,%eax
f0102f9b:	74 2e                	je     f0102fcb <envid2env+0x3d>
	e = &envs[ENVX(envid)];
f0102f9d:	89 c3                	mov    %eax,%ebx
f0102f9f:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0102fa5:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f0102fa8:	03 1d 44 12 23 f0    	add    0xf0231244,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0102fae:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0102fb2:	74 31                	je     f0102fe5 <envid2env+0x57>
f0102fb4:	39 43 48             	cmp    %eax,0x48(%ebx)
f0102fb7:	75 2c                	jne    f0102fe5 <envid2env+0x57>
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0102fb9:	84 d2                	test   %dl,%dl
f0102fbb:	75 38                	jne    f0102ff5 <envid2env+0x67>
	*env_store = e;
f0102fbd:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102fc0:	89 18                	mov    %ebx,(%eax)
	return 0;
f0102fc2:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102fc7:	5b                   	pop    %ebx
f0102fc8:	5e                   	pop    %esi
f0102fc9:	5d                   	pop    %ebp
f0102fca:	c3                   	ret    
		*env_store = curenv;
f0102fcb:	e8 2a 1f 00 00       	call   f0104efa <cpunum>
f0102fd0:	6b c0 74             	imul   $0x74,%eax,%eax
f0102fd3:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0102fd9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102fdc:	89 01                	mov    %eax,(%ecx)
		return 0;
f0102fde:	b8 00 00 00 00       	mov    $0x0,%eax
f0102fe3:	eb e2                	jmp    f0102fc7 <envid2env+0x39>
		*env_store = 0;
f0102fe5:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102fe8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102fee:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102ff3:	eb d2                	jmp    f0102fc7 <envid2env+0x39>
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0102ff5:	e8 00 1f 00 00       	call   f0104efa <cpunum>
f0102ffa:	6b c0 74             	imul   $0x74,%eax,%eax
f0102ffd:	39 98 28 20 23 f0    	cmp    %ebx,-0xfdcdfd8(%eax)
f0103003:	74 b8                	je     f0102fbd <envid2env+0x2f>
f0103005:	8b 73 4c             	mov    0x4c(%ebx),%esi
f0103008:	e8 ed 1e 00 00       	call   f0104efa <cpunum>
f010300d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103010:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0103016:	3b 70 48             	cmp    0x48(%eax),%esi
f0103019:	74 a2                	je     f0102fbd <envid2env+0x2f>
		*env_store = 0;
f010301b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010301e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0103024:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103029:	eb 9c                	jmp    f0102fc7 <envid2env+0x39>

f010302b <env_init_percpu>:
	asm volatile("lgdt (%0)" : : "r" (p));
f010302b:	b8 20 13 12 f0       	mov    $0xf0121320,%eax
f0103030:	0f 01 10             	lgdtl  (%eax)
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f0103033:	b8 23 00 00 00       	mov    $0x23,%eax
f0103038:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f010303a:	8e e0                	mov    %eax,%fs
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f010303c:	b8 10 00 00 00       	mov    $0x10,%eax
f0103041:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f0103043:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f0103045:	8e d0                	mov    %eax,%ss
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f0103047:	ea 4e 30 10 f0 08 00 	ljmp   $0x8,$0xf010304e
	asm volatile("lldt %0" : : "r" (sel));
f010304e:	b8 00 00 00 00       	mov    $0x0,%eax
f0103053:	0f 00 d0             	lldt   %ax
}
f0103056:	c3                   	ret    

f0103057 <env_init>:
{
f0103057:	55                   	push   %ebp
f0103058:	89 e5                	mov    %esp,%ebp
f010305a:	56                   	push   %esi
f010305b:	53                   	push   %ebx
		envs[i].env_id = 0;
f010305c:	8b 35 44 12 23 f0    	mov    0xf0231244,%esi
f0103062:	8b 15 48 12 23 f0    	mov    0xf0231248,%edx
f0103068:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f010306e:	89 f3                	mov    %esi,%ebx
f0103070:	eb 02                	jmp    f0103074 <env_init+0x1d>
f0103072:	89 c8                	mov    %ecx,%eax
f0103074:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_link = env_free_list;
f010307b:	89 50 44             	mov    %edx,0x44(%eax)
f010307e:	8d 48 84             	lea    -0x7c(%eax),%ecx
		env_free_list = &envs[i];
f0103081:	89 c2                	mov    %eax,%edx
	for (int i = NENV-1;i >= 0;i--) {
f0103083:	39 d8                	cmp    %ebx,%eax
f0103085:	75 eb                	jne    f0103072 <env_init+0x1b>
f0103087:	89 35 48 12 23 f0    	mov    %esi,0xf0231248
	env_init_percpu();
f010308d:	e8 99 ff ff ff       	call   f010302b <env_init_percpu>
}
f0103092:	5b                   	pop    %ebx
f0103093:	5e                   	pop    %esi
f0103094:	5d                   	pop    %ebp
f0103095:	c3                   	ret    

f0103096 <env_alloc>:
{
f0103096:	55                   	push   %ebp
f0103097:	89 e5                	mov    %esp,%ebp
f0103099:	56                   	push   %esi
f010309a:	53                   	push   %ebx
	if (!(e = env_free_list))
f010309b:	8b 1d 48 12 23 f0    	mov    0xf0231248,%ebx
f01030a1:	85 db                	test   %ebx,%ebx
f01030a3:	0f 84 71 01 00 00    	je     f010321a <env_alloc+0x184>
	if (!(p = page_alloc(ALLOC_ZERO)))
f01030a9:	83 ec 0c             	sub    $0xc,%esp
f01030ac:	6a 01                	push   $0x1
f01030ae:	e8 d1 de ff ff       	call   f0100f84 <page_alloc>
f01030b3:	89 c6                	mov    %eax,%esi
f01030b5:	83 c4 10             	add    $0x10,%esp
f01030b8:	85 c0                	test   %eax,%eax
f01030ba:	0f 84 61 01 00 00    	je     f0103221 <env_alloc+0x18b>
	return (pp - pages) << PGSHIFT;
f01030c0:	2b 05 10 1f 23 f0    	sub    0xf0231f10,%eax
f01030c6:	c1 f8 03             	sar    $0x3,%eax
f01030c9:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f01030cc:	89 c2                	mov    %eax,%edx
f01030ce:	c1 ea 0c             	shr    $0xc,%edx
f01030d1:	3b 15 08 1f 23 f0    	cmp    0xf0231f08,%edx
f01030d7:	0f 83 16 01 00 00    	jae    f01031f3 <env_alloc+0x15d>
	return (void *)(pa + KERNBASE);
f01030dd:	2d 00 00 00 10       	sub    $0x10000000,%eax
	e->env_pgdir = page2kva(p);	
f01030e2:	89 43 60             	mov    %eax,0x60(%ebx)
	memcpy(e->env_pgdir, kern_pgdir, PGSIZE);
f01030e5:	83 ec 04             	sub    $0x4,%esp
f01030e8:	68 00 10 00 00       	push   $0x1000
f01030ed:	ff 35 0c 1f 23 f0    	pushl  0xf0231f0c
f01030f3:	50                   	push   %eax
f01030f4:	e8 ab 18 00 00       	call   f01049a4 <memcpy>
	p->pp_ref++;
f01030f9:	66 83 46 04 01       	addw   $0x1,0x4(%esi)
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f01030fe:	8b 43 60             	mov    0x60(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f0103101:	83 c4 10             	add    $0x10,%esp
f0103104:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103109:	0f 86 f6 00 00 00    	jbe    f0103205 <env_alloc+0x16f>
	return (physaddr_t)kva - KERNBASE;
f010310f:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0103115:	83 ca 05             	or     $0x5,%edx
f0103118:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f010311e:	8b 43 48             	mov    0x48(%ebx),%eax
f0103121:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0103126:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f010312b:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103130:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f0103133:	89 da                	mov    %ebx,%edx
f0103135:	2b 15 44 12 23 f0    	sub    0xf0231244,%edx
f010313b:	c1 fa 02             	sar    $0x2,%edx
f010313e:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f0103144:	09 d0                	or     %edx,%eax
f0103146:	89 43 48             	mov    %eax,0x48(%ebx)
	e->env_parent_id = parent_id;
f0103149:	8b 45 0c             	mov    0xc(%ebp),%eax
f010314c:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f010314f:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0103156:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f010315d:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0103164:	83 ec 04             	sub    $0x4,%esp
f0103167:	6a 44                	push   $0x44
f0103169:	6a 00                	push   $0x0
f010316b:	53                   	push   %ebx
f010316c:	e8 89 17 00 00       	call   f01048fa <memset>
	e->env_tf.tf_ds = GD_UD | 3;
f0103171:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0103177:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f010317d:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0103183:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f010318a:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	e->env_pgfault_upcall = 0;
f0103190:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)
	e->env_ipc_recving = 0;
f0103197:	c6 43 68 00          	movb   $0x0,0x68(%ebx)
	env_free_list = e->env_link;
f010319b:	8b 43 44             	mov    0x44(%ebx),%eax
f010319e:	a3 48 12 23 f0       	mov    %eax,0xf0231248
	*newenv_store = e;
f01031a3:	8b 45 08             	mov    0x8(%ebp),%eax
f01031a6:	89 18                	mov    %ebx,(%eax)
	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01031a8:	8b 5b 48             	mov    0x48(%ebx),%ebx
f01031ab:	e8 4a 1d 00 00       	call   f0104efa <cpunum>
f01031b0:	6b c0 74             	imul   $0x74,%eax,%eax
f01031b3:	83 c4 10             	add    $0x10,%esp
f01031b6:	ba 00 00 00 00       	mov    $0x0,%edx
f01031bb:	83 b8 28 20 23 f0 00 	cmpl   $0x0,-0xfdcdfd8(%eax)
f01031c2:	74 11                	je     f01031d5 <env_alloc+0x13f>
f01031c4:	e8 31 1d 00 00       	call   f0104efa <cpunum>
f01031c9:	6b c0 74             	imul   $0x74,%eax,%eax
f01031cc:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f01031d2:	8b 50 48             	mov    0x48(%eax),%edx
f01031d5:	83 ec 04             	sub    $0x4,%esp
f01031d8:	53                   	push   %ebx
f01031d9:	52                   	push   %edx
f01031da:	68 3c 68 10 f0       	push   $0xf010683c
f01031df:	e8 21 06 00 00       	call   f0103805 <cprintf>
	return 0;
f01031e4:	83 c4 10             	add    $0x10,%esp
f01031e7:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01031ec:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01031ef:	5b                   	pop    %ebx
f01031f0:	5e                   	pop    %esi
f01031f1:	5d                   	pop    %ebp
f01031f2:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01031f3:	50                   	push   %eax
f01031f4:	68 f4 55 10 f0       	push   $0xf01055f4
f01031f9:	6a 58                	push   $0x58
f01031fb:	68 cf 64 10 f0       	push   $0xf01064cf
f0103200:	e8 8f ce ff ff       	call   f0100094 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103205:	50                   	push   %eax
f0103206:	68 18 56 10 f0       	push   $0xf0105618
f010320b:	68 c6 00 00 00       	push   $0xc6
f0103210:	68 31 68 10 f0       	push   $0xf0106831
f0103215:	e8 7a ce ff ff       	call   f0100094 <_panic>
		return -E_NO_FREE_ENV;
f010321a:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f010321f:	eb cb                	jmp    f01031ec <env_alloc+0x156>
		return -E_NO_MEM;
f0103221:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0103226:	eb c4                	jmp    f01031ec <env_alloc+0x156>

f0103228 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f0103228:	55                   	push   %ebp
f0103229:	89 e5                	mov    %esp,%ebp
f010322b:	57                   	push   %edi
f010322c:	56                   	push   %esi
f010322d:	53                   	push   %ebx
f010322e:	83 ec 34             	sub    $0x34,%esp
f0103231:	8b 75 08             	mov    0x8(%ebp),%esi
	// LAB 3: Your code here.
	struct 	Env *e;	
	int r = env_alloc(&e, (envid_t)0);
f0103234:	6a 00                	push   $0x0
f0103236:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103239:	50                   	push   %eax
f010323a:	e8 57 fe ff ff       	call   f0103096 <env_alloc>
	if (r < 0) {
f010323f:	83 c4 10             	add    $0x10,%esp
f0103242:	85 c0                	test   %eax,%eax
f0103244:	78 36                	js     f010327c <env_create+0x54>
		 panic("env_create: %e", r);
	}
	e->env_type = type;
f0103246:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103249:	8b 45 0c             	mov    0xc(%ebp),%eax
f010324c:	89 47 50             	mov    %eax,0x50(%edi)
	if (elf->e_magic != ELF_MAGIC) {
f010324f:	81 3e 7f 45 4c 46    	cmpl   $0x464c457f,(%esi)
f0103255:	75 3a                	jne    f0103291 <env_create+0x69>
	ph = (struct Proghdr *) (binary + elf->e_phoff);
f0103257:	89 f3                	mov    %esi,%ebx
f0103259:	03 5e 1c             	add    0x1c(%esi),%ebx
	eph = ph + elf->e_phnum;
f010325c:	0f b7 46 2c          	movzwl 0x2c(%esi),%eax
f0103260:	c1 e0 05             	shl    $0x5,%eax
f0103263:	01 d8                	add    %ebx,%eax
f0103265:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	lcr3(PADDR(e->env_pgdir));
f0103268:	8b 47 60             	mov    0x60(%edi),%eax
	if ((uint32_t)kva < KERNBASE)
f010326b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103270:	76 36                	jbe    f01032a8 <env_create+0x80>
	return (physaddr_t)kva - KERNBASE;
f0103272:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0103277:	0f 22 d8             	mov    %eax,%cr3
f010327a:	eb 5b                	jmp    f01032d7 <env_create+0xaf>
		 panic("env_create: %e", r);
f010327c:	50                   	push   %eax
f010327d:	68 51 68 10 f0       	push   $0xf0106851
f0103282:	68 94 01 00 00       	push   $0x194
f0103287:	68 31 68 10 f0       	push   $0xf0106831
f010328c:	e8 03 ce ff ff       	call   f0100094 <_panic>
		 panic("load_icode: not an Elf file");
f0103291:	83 ec 04             	sub    $0x4,%esp
f0103294:	68 60 68 10 f0       	push   $0xf0106860
f0103299:	68 6c 01 00 00       	push   $0x16c
f010329e:	68 31 68 10 f0       	push   $0xf0106831
f01032a3:	e8 ec cd ff ff       	call   f0100094 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01032a8:	50                   	push   %eax
f01032a9:	68 18 56 10 f0       	push   $0xf0105618
f01032ae:	68 71 01 00 00       	push   $0x171
f01032b3:	68 31 68 10 f0       	push   $0xf0106831
f01032b8:	e8 d7 cd ff ff       	call   f0100094 <_panic>
					 panic("load_icode: file size is greater than memory size");
f01032bd:	83 ec 04             	sub    $0x4,%esp
f01032c0:	68 a0 68 10 f0       	push   $0xf01068a0
f01032c5:	68 75 01 00 00       	push   $0x175
f01032ca:	68 31 68 10 f0       	push   $0xf0106831
f01032cf:	e8 c0 cd ff ff       	call   f0100094 <_panic>
	for (; ph<eph; ph++) {
f01032d4:	83 c3 20             	add    $0x20,%ebx
f01032d7:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f01032da:	76 47                	jbe    f0103323 <env_create+0xfb>
		if (ph->p_type == ELF_PROG_LOAD) {
f01032dc:	83 3b 01             	cmpl   $0x1,(%ebx)
f01032df:	75 f3                	jne    f01032d4 <env_create+0xac>
			 if (ph->p_filesz > ph->p_memsz) {
f01032e1:	8b 4b 14             	mov    0x14(%ebx),%ecx
f01032e4:	39 4b 10             	cmp    %ecx,0x10(%ebx)
f01032e7:	77 d4                	ja     f01032bd <env_create+0x95>
			 region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f01032e9:	8b 53 08             	mov    0x8(%ebx),%edx
f01032ec:	89 f8                	mov    %edi,%eax
f01032ee:	e8 13 fc ff ff       	call   f0102f06 <region_alloc>
			 memcpy((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
f01032f3:	83 ec 04             	sub    $0x4,%esp
f01032f6:	ff 73 10             	pushl  0x10(%ebx)
f01032f9:	89 f0                	mov    %esi,%eax
f01032fb:	03 43 04             	add    0x4(%ebx),%eax
f01032fe:	50                   	push   %eax
f01032ff:	ff 73 08             	pushl  0x8(%ebx)
f0103302:	e8 9d 16 00 00       	call   f01049a4 <memcpy>
			 memset((void *)ph->p_va + ph->p_filesz, 0, ph->p_memsz - ph->p_filesz);
f0103307:	8b 43 10             	mov    0x10(%ebx),%eax
f010330a:	83 c4 0c             	add    $0xc,%esp
f010330d:	8b 53 14             	mov    0x14(%ebx),%edx
f0103310:	29 c2                	sub    %eax,%edx
f0103312:	52                   	push   %edx
f0103313:	6a 00                	push   $0x0
f0103315:	03 43 08             	add    0x8(%ebx),%eax
f0103318:	50                   	push   %eax
f0103319:	e8 dc 15 00 00       	call   f01048fa <memset>
f010331e:	83 c4 10             	add    $0x10,%esp
f0103321:	eb b1                	jmp    f01032d4 <env_create+0xac>
	e->env_tf.tf_eip = elf->e_entry;
f0103323:	8b 46 18             	mov    0x18(%esi),%eax
f0103326:	89 47 30             	mov    %eax,0x30(%edi)
	region_alloc(e, (void *)USTACKTOP - PGSIZE, PGSIZE);
f0103329:	b9 00 10 00 00       	mov    $0x1000,%ecx
f010332e:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0103333:	89 f8                	mov    %edi,%eax
f0103335:	e8 cc fb ff ff       	call   f0102f06 <region_alloc>
	lcr3(PADDR(kern_pgdir));
f010333a:	a1 0c 1f 23 f0       	mov    0xf0231f0c,%eax
	if ((uint32_t)kva < KERNBASE)
f010333f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103344:	76 10                	jbe    f0103356 <env_create+0x12e>
	return (physaddr_t)kva - KERNBASE;
f0103346:	05 00 00 00 10       	add    $0x10000000,%eax
f010334b:	0f 22 d8             	mov    %eax,%cr3
	load_icode(e, binary);
}
f010334e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103351:	5b                   	pop    %ebx
f0103352:	5e                   	pop    %esi
f0103353:	5f                   	pop    %edi
f0103354:	5d                   	pop    %ebp
f0103355:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103356:	50                   	push   %eax
f0103357:	68 18 56 10 f0       	push   $0xf0105618
f010335c:	68 83 01 00 00       	push   $0x183
f0103361:	68 31 68 10 f0       	push   $0xf0106831
f0103366:	e8 29 cd ff ff       	call   f0100094 <_panic>

f010336b <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f010336b:	55                   	push   %ebp
f010336c:	89 e5                	mov    %esp,%ebp
f010336e:	57                   	push   %edi
f010336f:	56                   	push   %esi
f0103370:	53                   	push   %ebx
f0103371:	83 ec 1c             	sub    $0x1c,%esp
f0103374:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103377:	e8 7e 1b 00 00       	call   f0104efa <cpunum>
f010337c:	6b c0 74             	imul   $0x74,%eax,%eax
f010337f:	39 b8 28 20 23 f0    	cmp    %edi,-0xfdcdfd8(%eax)
f0103385:	74 48                	je     f01033cf <env_free+0x64>
		lcr3(PADDR(kern_pgdir));

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103387:	8b 5f 48             	mov    0x48(%edi),%ebx
f010338a:	e8 6b 1b 00 00       	call   f0104efa <cpunum>
f010338f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103392:	ba 00 00 00 00       	mov    $0x0,%edx
f0103397:	83 b8 28 20 23 f0 00 	cmpl   $0x0,-0xfdcdfd8(%eax)
f010339e:	74 11                	je     f01033b1 <env_free+0x46>
f01033a0:	e8 55 1b 00 00       	call   f0104efa <cpunum>
f01033a5:	6b c0 74             	imul   $0x74,%eax,%eax
f01033a8:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f01033ae:	8b 50 48             	mov    0x48(%eax),%edx
f01033b1:	83 ec 04             	sub    $0x4,%esp
f01033b4:	53                   	push   %ebx
f01033b5:	52                   	push   %edx
f01033b6:	68 7c 68 10 f0       	push   $0xf010687c
f01033bb:	e8 45 04 00 00       	call   f0103805 <cprintf>
f01033c0:	83 c4 10             	add    $0x10,%esp
f01033c3:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f01033ca:	e9 a9 00 00 00       	jmp    f0103478 <env_free+0x10d>
		lcr3(PADDR(kern_pgdir));
f01033cf:	a1 0c 1f 23 f0       	mov    0xf0231f0c,%eax
	if ((uint32_t)kva < KERNBASE)
f01033d4:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01033d9:	76 0a                	jbe    f01033e5 <env_free+0x7a>
	return (physaddr_t)kva - KERNBASE;
f01033db:	05 00 00 00 10       	add    $0x10000000,%eax
f01033e0:	0f 22 d8             	mov    %eax,%cr3
f01033e3:	eb a2                	jmp    f0103387 <env_free+0x1c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01033e5:	50                   	push   %eax
f01033e6:	68 18 56 10 f0       	push   $0xf0105618
f01033eb:	68 a8 01 00 00       	push   $0x1a8
f01033f0:	68 31 68 10 f0       	push   $0xf0106831
f01033f5:	e8 9a cc ff ff       	call   f0100094 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01033fa:	56                   	push   %esi
f01033fb:	68 f4 55 10 f0       	push   $0xf01055f4
f0103400:	68 b7 01 00 00       	push   $0x1b7
f0103405:	68 31 68 10 f0       	push   $0xf0106831
f010340a:	e8 85 cc ff ff       	call   f0100094 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f010340f:	83 ec 08             	sub    $0x8,%esp
f0103412:	89 d8                	mov    %ebx,%eax
f0103414:	c1 e0 0c             	shl    $0xc,%eax
f0103417:	0b 45 e4             	or     -0x1c(%ebp),%eax
f010341a:	50                   	push   %eax
f010341b:	ff 77 60             	pushl  0x60(%edi)
f010341e:	e8 dc dd ff ff       	call   f01011ff <page_remove>
f0103423:	83 c4 10             	add    $0x10,%esp
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103426:	83 c3 01             	add    $0x1,%ebx
f0103429:	83 c6 04             	add    $0x4,%esi
f010342c:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0103432:	74 07                	je     f010343b <env_free+0xd0>
			if (pt[pteno] & PTE_P)
f0103434:	f6 06 01             	testb  $0x1,(%esi)
f0103437:	74 ed                	je     f0103426 <env_free+0xbb>
f0103439:	eb d4                	jmp    f010340f <env_free+0xa4>
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f010343b:	8b 47 60             	mov    0x60(%edi),%eax
f010343e:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103441:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
	if (PGNUM(pa) >= npages)
f0103448:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010344b:	3b 05 08 1f 23 f0    	cmp    0xf0231f08,%eax
f0103451:	73 69                	jae    f01034bc <env_free+0x151>
		page_decref(pa2page(pa));
f0103453:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f0103456:	a1 10 1f 23 f0       	mov    0xf0231f10,%eax
f010345b:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010345e:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f0103461:	50                   	push   %eax
f0103462:	e8 ca db ff ff       	call   f0101031 <page_decref>
f0103467:	83 c4 10             	add    $0x10,%esp
f010346a:	83 45 e0 04          	addl   $0x4,-0x20(%ebp)
f010346e:	8b 45 e0             	mov    -0x20(%ebp),%eax
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103471:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f0103476:	74 58                	je     f01034d0 <env_free+0x165>
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103478:	8b 47 60             	mov    0x60(%edi),%eax
f010347b:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010347e:	8b 34 10             	mov    (%eax,%edx,1),%esi
f0103481:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0103487:	74 e1                	je     f010346a <env_free+0xff>
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103489:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	if (PGNUM(pa) >= npages)
f010348f:	89 f0                	mov    %esi,%eax
f0103491:	c1 e8 0c             	shr    $0xc,%eax
f0103494:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0103497:	39 05 08 1f 23 f0    	cmp    %eax,0xf0231f08
f010349d:	0f 86 57 ff ff ff    	jbe    f01033fa <env_free+0x8f>
	return (void *)(pa + KERNBASE);
f01034a3:	81 ee 00 00 00 10    	sub    $0x10000000,%esi
f01034a9:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01034ac:	c1 e0 14             	shl    $0x14,%eax
f01034af:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01034b2:	bb 00 00 00 00       	mov    $0x0,%ebx
f01034b7:	e9 78 ff ff ff       	jmp    f0103434 <env_free+0xc9>
		panic("pa2page called with invalid pa");
f01034bc:	83 ec 04             	sub    $0x4,%esp
f01034bf:	68 44 5c 10 f0       	push   $0xf0105c44
f01034c4:	6a 51                	push   $0x51
f01034c6:	68 cf 64 10 f0       	push   $0xf01064cf
f01034cb:	e8 c4 cb ff ff       	call   f0100094 <_panic>
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f01034d0:	8b 47 60             	mov    0x60(%edi),%eax
	if ((uint32_t)kva < KERNBASE)
f01034d3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01034d8:	76 49                	jbe    f0103523 <env_free+0x1b8>
	e->env_pgdir = 0;
f01034da:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
	return (physaddr_t)kva - KERNBASE;
f01034e1:	05 00 00 00 10       	add    $0x10000000,%eax
	if (PGNUM(pa) >= npages)
f01034e6:	c1 e8 0c             	shr    $0xc,%eax
f01034e9:	3b 05 08 1f 23 f0    	cmp    0xf0231f08,%eax
f01034ef:	73 47                	jae    f0103538 <env_free+0x1cd>
	page_decref(pa2page(pa));
f01034f1:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f01034f4:	8b 15 10 1f 23 f0    	mov    0xf0231f10,%edx
f01034fa:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f01034fd:	50                   	push   %eax
f01034fe:	e8 2e db ff ff       	call   f0101031 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103503:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f010350a:	a1 48 12 23 f0       	mov    0xf0231248,%eax
f010350f:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0103512:	89 3d 48 12 23 f0    	mov    %edi,0xf0231248
}
f0103518:	83 c4 10             	add    $0x10,%esp
f010351b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010351e:	5b                   	pop    %ebx
f010351f:	5e                   	pop    %esi
f0103520:	5f                   	pop    %edi
f0103521:	5d                   	pop    %ebp
f0103522:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103523:	50                   	push   %eax
f0103524:	68 18 56 10 f0       	push   $0xf0105618
f0103529:	68 c5 01 00 00       	push   $0x1c5
f010352e:	68 31 68 10 f0       	push   $0xf0106831
f0103533:	e8 5c cb ff ff       	call   f0100094 <_panic>
		panic("pa2page called with invalid pa");
f0103538:	83 ec 04             	sub    $0x4,%esp
f010353b:	68 44 5c 10 f0       	push   $0xf0105c44
f0103540:	6a 51                	push   $0x51
f0103542:	68 cf 64 10 f0       	push   $0xf01064cf
f0103547:	e8 48 cb ff ff       	call   f0100094 <_panic>

f010354c <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f010354c:	55                   	push   %ebp
f010354d:	89 e5                	mov    %esp,%ebp
f010354f:	53                   	push   %ebx
f0103550:	83 ec 04             	sub    $0x4,%esp
f0103553:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103556:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f010355a:	74 21                	je     f010357d <env_destroy+0x31>
		e->env_status = ENV_DYING;
		return;
	}

	env_free(e);
f010355c:	83 ec 0c             	sub    $0xc,%esp
f010355f:	53                   	push   %ebx
f0103560:	e8 06 fe ff ff       	call   f010336b <env_free>

	if (curenv == e) {
f0103565:	e8 90 19 00 00       	call   f0104efa <cpunum>
f010356a:	6b c0 74             	imul   $0x74,%eax,%eax
f010356d:	83 c4 10             	add    $0x10,%esp
f0103570:	39 98 28 20 23 f0    	cmp    %ebx,-0xfdcdfd8(%eax)
f0103576:	74 1e                	je     f0103596 <env_destroy+0x4a>
		curenv = NULL;
		sched_yield();
	}
}
f0103578:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010357b:	c9                   	leave  
f010357c:	c3                   	ret    
	if (e->env_status == ENV_RUNNING && curenv != e) {
f010357d:	e8 78 19 00 00       	call   f0104efa <cpunum>
f0103582:	6b c0 74             	imul   $0x74,%eax,%eax
f0103585:	39 98 28 20 23 f0    	cmp    %ebx,-0xfdcdfd8(%eax)
f010358b:	74 cf                	je     f010355c <env_destroy+0x10>
		e->env_status = ENV_DYING;
f010358d:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0103594:	eb e2                	jmp    f0103578 <env_destroy+0x2c>
		curenv = NULL;
f0103596:	e8 5f 19 00 00       	call   f0104efa <cpunum>
f010359b:	6b c0 74             	imul   $0x74,%eax,%eax
f010359e:	c7 80 28 20 23 f0 00 	movl   $0x0,-0xfdcdfd8(%eax)
f01035a5:	00 00 00 
		sched_yield();
f01035a8:	e8 f7 07 00 00       	call   f0103da4 <sched_yield>

f01035ad <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f01035ad:	55                   	push   %ebp
f01035ae:	89 e5                	mov    %esp,%ebp
f01035b0:	53                   	push   %ebx
f01035b1:	83 ec 04             	sub    $0x4,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f01035b4:	e8 41 19 00 00       	call   f0104efa <cpunum>
f01035b9:	6b c0 74             	imul   $0x74,%eax,%eax
f01035bc:	8b 98 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%ebx
f01035c2:	e8 33 19 00 00       	call   f0104efa <cpunum>
f01035c7:	89 43 5c             	mov    %eax,0x5c(%ebx)

	asm volatile(
f01035ca:	8b 65 08             	mov    0x8(%ebp),%esp
f01035cd:	61                   	popa   
f01035ce:	07                   	pop    %es
f01035cf:	1f                   	pop    %ds
f01035d0:	83 c4 08             	add    $0x8,%esp
f01035d3:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f01035d4:	83 ec 04             	sub    $0x4,%esp
f01035d7:	68 92 68 10 f0       	push   $0xf0106892
f01035dc:	68 fc 01 00 00       	push   $0x1fc
f01035e1:	68 31 68 10 f0       	push   $0xf0106831
f01035e6:	e8 a9 ca ff ff       	call   f0100094 <_panic>

f01035eb <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f01035eb:	55                   	push   %ebp
f01035ec:	89 e5                	mov    %esp,%ebp
f01035ee:	53                   	push   %ebx
f01035ef:	83 ec 04             	sub    $0x4,%esp
f01035f2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	if (curenv && curenv->env_status == ENV_RUNNING) {
f01035f5:	e8 00 19 00 00       	call   f0104efa <cpunum>
f01035fa:	6b c0 74             	imul   $0x74,%eax,%eax
f01035fd:	83 b8 28 20 23 f0 00 	cmpl   $0x0,-0xfdcdfd8(%eax)
f0103604:	74 14                	je     f010361a <env_run+0x2f>
f0103606:	e8 ef 18 00 00       	call   f0104efa <cpunum>
f010360b:	6b c0 74             	imul   $0x74,%eax,%eax
f010360e:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0103614:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103618:	74 34                	je     f010364e <env_run+0x63>
		 curenv->env_status = ENV_RUNNABLE;
	}
		 curenv = e;
f010361a:	e8 db 18 00 00       	call   f0104efa <cpunum>
f010361f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103622:	89 98 28 20 23 f0    	mov    %ebx,-0xfdcdfd8(%eax)
		 e->env_status = ENV_RUNNING;
f0103628:	c7 43 54 03 00 00 00 	movl   $0x3,0x54(%ebx)
		 e->env_runs++ ;
f010362f:	83 43 58 01          	addl   $0x1,0x58(%ebx)
		 lcr3(PADDR(e->env_pgdir));
f0103633:	8b 43 60             	mov    0x60(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f0103636:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010363b:	76 28                	jbe    f0103665 <env_run+0x7a>
	return (physaddr_t)kva - KERNBASE;
f010363d:	05 00 00 00 10       	add    $0x10000000,%eax
f0103642:	0f 22 d8             	mov    %eax,%cr3

		 env_pop_tf(&e->env_tf);
f0103645:	83 ec 0c             	sub    $0xc,%esp
f0103648:	53                   	push   %ebx
f0103649:	e8 5f ff ff ff       	call   f01035ad <env_pop_tf>
		 curenv->env_status = ENV_RUNNABLE;
f010364e:	e8 a7 18 00 00       	call   f0104efa <cpunum>
f0103653:	6b c0 74             	imul   $0x74,%eax,%eax
f0103656:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f010365c:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
f0103663:	eb b5                	jmp    f010361a <env_run+0x2f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103665:	50                   	push   %eax
f0103666:	68 18 56 10 f0       	push   $0xf0105618
f010366b:	68 20 02 00 00       	push   $0x220
f0103670:	68 31 68 10 f0       	push   $0xf0106831
f0103675:	e8 1a ca ff ff       	call   f0100094 <_panic>

f010367a <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f010367a:	55                   	push   %ebp
f010367b:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010367d:	8b 45 08             	mov    0x8(%ebp),%eax
f0103680:	ba 70 00 00 00       	mov    $0x70,%edx
f0103685:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103686:	ba 71 00 00 00       	mov    $0x71,%edx
f010368b:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f010368c:	0f b6 c0             	movzbl %al,%eax
}
f010368f:	5d                   	pop    %ebp
f0103690:	c3                   	ret    

f0103691 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103691:	55                   	push   %ebp
f0103692:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103694:	8b 45 08             	mov    0x8(%ebp),%eax
f0103697:	ba 70 00 00 00       	mov    $0x70,%edx
f010369c:	ee                   	out    %al,(%dx)
f010369d:	8b 45 0c             	mov    0xc(%ebp),%eax
f01036a0:	ba 71 00 00 00       	mov    $0x71,%edx
f01036a5:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f01036a6:	5d                   	pop    %ebp
f01036a7:	c3                   	ret    

f01036a8 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f01036a8:	55                   	push   %ebp
f01036a9:	89 e5                	mov    %esp,%ebp
f01036ab:	56                   	push   %esi
f01036ac:	53                   	push   %ebx
f01036ad:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f01036b0:	66 a3 a8 13 12 f0    	mov    %ax,0xf01213a8
	if (!didinit)
f01036b6:	80 3d 4c 12 23 f0 00 	cmpb   $0x0,0xf023124c
f01036bd:	75 07                	jne    f01036c6 <irq_setmask_8259A+0x1e>
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
}
f01036bf:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01036c2:	5b                   	pop    %ebx
f01036c3:	5e                   	pop    %esi
f01036c4:	5d                   	pop    %ebp
f01036c5:	c3                   	ret    
f01036c6:	89 c6                	mov    %eax,%esi
f01036c8:	ba 21 00 00 00       	mov    $0x21,%edx
f01036cd:	ee                   	out    %al,(%dx)
	outb(IO_PIC2+1, (char)(mask >> 8));
f01036ce:	66 c1 e8 08          	shr    $0x8,%ax
f01036d2:	ba a1 00 00 00       	mov    $0xa1,%edx
f01036d7:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f01036d8:	83 ec 0c             	sub    $0xc,%esp
f01036db:	68 d2 68 10 f0       	push   $0xf01068d2
f01036e0:	e8 20 01 00 00       	call   f0103805 <cprintf>
f01036e5:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f01036e8:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f01036ed:	0f b7 f6             	movzwl %si,%esi
f01036f0:	f7 d6                	not    %esi
f01036f2:	eb 19                	jmp    f010370d <irq_setmask_8259A+0x65>
			cprintf(" %d", i);
f01036f4:	83 ec 08             	sub    $0x8,%esp
f01036f7:	53                   	push   %ebx
f01036f8:	68 34 6d 10 f0       	push   $0xf0106d34
f01036fd:	e8 03 01 00 00       	call   f0103805 <cprintf>
f0103702:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f0103705:	83 c3 01             	add    $0x1,%ebx
f0103708:	83 fb 10             	cmp    $0x10,%ebx
f010370b:	74 07                	je     f0103714 <irq_setmask_8259A+0x6c>
		if (~mask & (1<<i))
f010370d:	0f a3 de             	bt     %ebx,%esi
f0103710:	73 f3                	jae    f0103705 <irq_setmask_8259A+0x5d>
f0103712:	eb e0                	jmp    f01036f4 <irq_setmask_8259A+0x4c>
	cprintf("\n");
f0103714:	83 ec 0c             	sub    $0xc,%esp
f0103717:	68 ef 67 10 f0       	push   $0xf01067ef
f010371c:	e8 e4 00 00 00       	call   f0103805 <cprintf>
f0103721:	83 c4 10             	add    $0x10,%esp
f0103724:	eb 99                	jmp    f01036bf <irq_setmask_8259A+0x17>

f0103726 <pic_init>:
{
f0103726:	55                   	push   %ebp
f0103727:	89 e5                	mov    %esp,%ebp
f0103729:	57                   	push   %edi
f010372a:	56                   	push   %esi
f010372b:	53                   	push   %ebx
f010372c:	83 ec 0c             	sub    $0xc,%esp
	didinit = 1;
f010372f:	c6 05 4c 12 23 f0 01 	movb   $0x1,0xf023124c
f0103736:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010373b:	bb 21 00 00 00       	mov    $0x21,%ebx
f0103740:	89 da                	mov    %ebx,%edx
f0103742:	ee                   	out    %al,(%dx)
f0103743:	b9 a1 00 00 00       	mov    $0xa1,%ecx
f0103748:	89 ca                	mov    %ecx,%edx
f010374a:	ee                   	out    %al,(%dx)
f010374b:	bf 11 00 00 00       	mov    $0x11,%edi
f0103750:	be 20 00 00 00       	mov    $0x20,%esi
f0103755:	89 f8                	mov    %edi,%eax
f0103757:	89 f2                	mov    %esi,%edx
f0103759:	ee                   	out    %al,(%dx)
f010375a:	b8 20 00 00 00       	mov    $0x20,%eax
f010375f:	89 da                	mov    %ebx,%edx
f0103761:	ee                   	out    %al,(%dx)
f0103762:	b8 04 00 00 00       	mov    $0x4,%eax
f0103767:	ee                   	out    %al,(%dx)
f0103768:	b8 03 00 00 00       	mov    $0x3,%eax
f010376d:	ee                   	out    %al,(%dx)
f010376e:	bb a0 00 00 00       	mov    $0xa0,%ebx
f0103773:	89 f8                	mov    %edi,%eax
f0103775:	89 da                	mov    %ebx,%edx
f0103777:	ee                   	out    %al,(%dx)
f0103778:	b8 28 00 00 00       	mov    $0x28,%eax
f010377d:	89 ca                	mov    %ecx,%edx
f010377f:	ee                   	out    %al,(%dx)
f0103780:	b8 02 00 00 00       	mov    $0x2,%eax
f0103785:	ee                   	out    %al,(%dx)
f0103786:	b8 01 00 00 00       	mov    $0x1,%eax
f010378b:	ee                   	out    %al,(%dx)
f010378c:	bf 68 00 00 00       	mov    $0x68,%edi
f0103791:	89 f8                	mov    %edi,%eax
f0103793:	89 f2                	mov    %esi,%edx
f0103795:	ee                   	out    %al,(%dx)
f0103796:	b9 0a 00 00 00       	mov    $0xa,%ecx
f010379b:	89 c8                	mov    %ecx,%eax
f010379d:	ee                   	out    %al,(%dx)
f010379e:	89 f8                	mov    %edi,%eax
f01037a0:	89 da                	mov    %ebx,%edx
f01037a2:	ee                   	out    %al,(%dx)
f01037a3:	89 c8                	mov    %ecx,%eax
f01037a5:	ee                   	out    %al,(%dx)
	if (irq_mask_8259A != 0xFFFF)
f01037a6:	0f b7 05 a8 13 12 f0 	movzwl 0xf01213a8,%eax
f01037ad:	66 83 f8 ff          	cmp    $0xffff,%ax
f01037b1:	75 08                	jne    f01037bb <pic_init+0x95>
}
f01037b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01037b6:	5b                   	pop    %ebx
f01037b7:	5e                   	pop    %esi
f01037b8:	5f                   	pop    %edi
f01037b9:	5d                   	pop    %ebp
f01037ba:	c3                   	ret    
		irq_setmask_8259A(irq_mask_8259A);
f01037bb:	83 ec 0c             	sub    $0xc,%esp
f01037be:	0f b7 c0             	movzwl %ax,%eax
f01037c1:	50                   	push   %eax
f01037c2:	e8 e1 fe ff ff       	call   f01036a8 <irq_setmask_8259A>
f01037c7:	83 c4 10             	add    $0x10,%esp
}
f01037ca:	eb e7                	jmp    f01037b3 <pic_init+0x8d>

f01037cc <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01037cc:	55                   	push   %ebp
f01037cd:	89 e5                	mov    %esp,%ebp
f01037cf:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f01037d2:	ff 75 08             	pushl  0x8(%ebp)
f01037d5:	e8 bc cf ff ff       	call   f0100796 <cputchar>
	*cnt++;
}
f01037da:	83 c4 10             	add    $0x10,%esp
f01037dd:	c9                   	leave  
f01037de:	c3                   	ret    

f01037df <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01037df:	55                   	push   %ebp
f01037e0:	89 e5                	mov    %esp,%ebp
f01037e2:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f01037e5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01037ec:	ff 75 0c             	pushl  0xc(%ebp)
f01037ef:	ff 75 08             	pushl  0x8(%ebp)
f01037f2:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01037f5:	50                   	push   %eax
f01037f6:	68 cc 37 10 f0       	push   $0xf01037cc
f01037fb:	e8 f2 09 00 00       	call   f01041f2 <vprintfmt>
	return cnt;
}
f0103800:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103803:	c9                   	leave  
f0103804:	c3                   	ret    

f0103805 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103805:	55                   	push   %ebp
f0103806:	89 e5                	mov    %esp,%ebp
f0103808:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f010380b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f010380e:	50                   	push   %eax
f010380f:	ff 75 08             	pushl  0x8(%ebp)
f0103812:	e8 c8 ff ff ff       	call   f01037df <vcprintf>
	va_end(ap);

	return cnt;
}
f0103817:	c9                   	leave  
f0103818:	c3                   	ret    

f0103819 <trap_init_percpu>:
	//
	// LAB 4: Your code here:

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f0103819:	b8 80 1a 23 f0       	mov    $0xf0231a80,%eax
f010381e:	c7 05 84 1a 23 f0 00 	movl   $0xf0000000,0xf0231a84
f0103825:	00 00 f0 
	ts.ts_ss0 = GD_KD;
f0103828:	66 c7 05 88 1a 23 f0 	movw   $0x10,0xf0231a88
f010382f:	10 00 
	ts.ts_iomb = sizeof(struct Taskstate);
f0103831:	66 c7 05 e6 1a 23 f0 	movw   $0x68,0xf0231ae6
f0103838:	68 00 

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f010383a:	66 c7 05 68 13 12 f0 	movw   $0x67,0xf0121368
f0103841:	67 00 
f0103843:	66 a3 6a 13 12 f0    	mov    %ax,0xf012136a
f0103849:	89 c2                	mov    %eax,%edx
f010384b:	c1 ea 10             	shr    $0x10,%edx
f010384e:	88 15 6c 13 12 f0    	mov    %dl,0xf012136c
f0103854:	c6 05 6e 13 12 f0 40 	movb   $0x40,0xf012136e
f010385b:	c1 e8 18             	shr    $0x18,%eax
f010385e:	a2 6f 13 12 f0       	mov    %al,0xf012136f
					sizeof(struct Taskstate) - 1, 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
f0103863:	c6 05 6d 13 12 f0 89 	movb   $0x89,0xf012136d
	asm volatile("ltr %0" : : "r" (sel));
f010386a:	b8 28 00 00 00       	mov    $0x28,%eax
f010386f:	0f 00 d8             	ltr    %ax
	asm volatile("lidt (%0)" : : "r" (p));
f0103872:	b8 ac 13 12 f0       	mov    $0xf01213ac,%eax
f0103877:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f010387a:	c3                   	ret    

f010387b <trap_init>:
{
f010387b:	55                   	push   %ebp
f010387c:	89 e5                	mov    %esp,%ebp
f010387e:	83 ec 08             	sub    $0x8,%esp
	trap_init_percpu();
f0103881:	e8 93 ff ff ff       	call   f0103819 <trap_init_percpu>
}
f0103886:	c9                   	leave  
f0103887:	c3                   	ret    

f0103888 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103888:	55                   	push   %ebp
f0103889:	89 e5                	mov    %esp,%ebp
f010388b:	53                   	push   %ebx
f010388c:	83 ec 0c             	sub    $0xc,%esp
f010388f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103892:	ff 33                	pushl  (%ebx)
f0103894:	68 e6 68 10 f0       	push   $0xf01068e6
f0103899:	e8 67 ff ff ff       	call   f0103805 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f010389e:	83 c4 08             	add    $0x8,%esp
f01038a1:	ff 73 04             	pushl  0x4(%ebx)
f01038a4:	68 f5 68 10 f0       	push   $0xf01068f5
f01038a9:	e8 57 ff ff ff       	call   f0103805 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f01038ae:	83 c4 08             	add    $0x8,%esp
f01038b1:	ff 73 08             	pushl  0x8(%ebx)
f01038b4:	68 04 69 10 f0       	push   $0xf0106904
f01038b9:	e8 47 ff ff ff       	call   f0103805 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f01038be:	83 c4 08             	add    $0x8,%esp
f01038c1:	ff 73 0c             	pushl  0xc(%ebx)
f01038c4:	68 13 69 10 f0       	push   $0xf0106913
f01038c9:	e8 37 ff ff ff       	call   f0103805 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f01038ce:	83 c4 08             	add    $0x8,%esp
f01038d1:	ff 73 10             	pushl  0x10(%ebx)
f01038d4:	68 22 69 10 f0       	push   $0xf0106922
f01038d9:	e8 27 ff ff ff       	call   f0103805 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f01038de:	83 c4 08             	add    $0x8,%esp
f01038e1:	ff 73 14             	pushl  0x14(%ebx)
f01038e4:	68 31 69 10 f0       	push   $0xf0106931
f01038e9:	e8 17 ff ff ff       	call   f0103805 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f01038ee:	83 c4 08             	add    $0x8,%esp
f01038f1:	ff 73 18             	pushl  0x18(%ebx)
f01038f4:	68 40 69 10 f0       	push   $0xf0106940
f01038f9:	e8 07 ff ff ff       	call   f0103805 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f01038fe:	83 c4 08             	add    $0x8,%esp
f0103901:	ff 73 1c             	pushl  0x1c(%ebx)
f0103904:	68 4f 69 10 f0       	push   $0xf010694f
f0103909:	e8 f7 fe ff ff       	call   f0103805 <cprintf>
}
f010390e:	83 c4 10             	add    $0x10,%esp
f0103911:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103914:	c9                   	leave  
f0103915:	c3                   	ret    

f0103916 <print_trapframe>:
{
f0103916:	55                   	push   %ebp
f0103917:	89 e5                	mov    %esp,%ebp
f0103919:	56                   	push   %esi
f010391a:	53                   	push   %ebx
f010391b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f010391e:	e8 d7 15 00 00       	call   f0104efa <cpunum>
f0103923:	83 ec 04             	sub    $0x4,%esp
f0103926:	50                   	push   %eax
f0103927:	53                   	push   %ebx
f0103928:	68 b3 69 10 f0       	push   $0xf01069b3
f010392d:	e8 d3 fe ff ff       	call   f0103805 <cprintf>
	print_regs(&tf->tf_regs);
f0103932:	89 1c 24             	mov    %ebx,(%esp)
f0103935:	e8 4e ff ff ff       	call   f0103888 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f010393a:	83 c4 08             	add    $0x8,%esp
f010393d:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103941:	50                   	push   %eax
f0103942:	68 d1 69 10 f0       	push   $0xf01069d1
f0103947:	e8 b9 fe ff ff       	call   f0103805 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f010394c:	83 c4 08             	add    $0x8,%esp
f010394f:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103953:	50                   	push   %eax
f0103954:	68 e4 69 10 f0       	push   $0xf01069e4
f0103959:	e8 a7 fe ff ff       	call   f0103805 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f010395e:	8b 43 28             	mov    0x28(%ebx),%eax
	if (trapno < ARRAY_SIZE(excnames))
f0103961:	83 c4 10             	add    $0x10,%esp
f0103964:	83 f8 13             	cmp    $0x13,%eax
f0103967:	0f 86 e1 00 00 00    	jbe    f0103a4e <print_trapframe+0x138>
		return "System call";
f010396d:	ba 5e 69 10 f0       	mov    $0xf010695e,%edx
	if (trapno == T_SYSCALL)
f0103972:	83 f8 30             	cmp    $0x30,%eax
f0103975:	74 13                	je     f010398a <print_trapframe+0x74>
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0103977:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
f010397a:	83 fa 0f             	cmp    $0xf,%edx
f010397d:	ba 6a 69 10 f0       	mov    $0xf010696a,%edx
f0103982:	b9 79 69 10 f0       	mov    $0xf0106979,%ecx
f0103987:	0f 46 d1             	cmovbe %ecx,%edx
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f010398a:	83 ec 04             	sub    $0x4,%esp
f010398d:	52                   	push   %edx
f010398e:	50                   	push   %eax
f010398f:	68 f7 69 10 f0       	push   $0xf01069f7
f0103994:	e8 6c fe ff ff       	call   f0103805 <cprintf>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103999:	83 c4 10             	add    $0x10,%esp
f010399c:	39 1d 60 1a 23 f0    	cmp    %ebx,0xf0231a60
f01039a2:	0f 84 b2 00 00 00    	je     f0103a5a <print_trapframe+0x144>
	cprintf("  err  0x%08x", tf->tf_err);
f01039a8:	83 ec 08             	sub    $0x8,%esp
f01039ab:	ff 73 2c             	pushl  0x2c(%ebx)
f01039ae:	68 18 6a 10 f0       	push   $0xf0106a18
f01039b3:	e8 4d fe ff ff       	call   f0103805 <cprintf>
	if (tf->tf_trapno == T_PGFLT)
f01039b8:	83 c4 10             	add    $0x10,%esp
f01039bb:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f01039bf:	0f 85 b8 00 00 00    	jne    f0103a7d <print_trapframe+0x167>
			tf->tf_err & 1 ? "protection" : "not-present");
f01039c5:	8b 43 2c             	mov    0x2c(%ebx),%eax
		cprintf(" [%s, %s, %s]\n",
f01039c8:	89 c2                	mov    %eax,%edx
f01039ca:	83 e2 01             	and    $0x1,%edx
f01039cd:	b9 8c 69 10 f0       	mov    $0xf010698c,%ecx
f01039d2:	ba 97 69 10 f0       	mov    $0xf0106997,%edx
f01039d7:	0f 44 ca             	cmove  %edx,%ecx
f01039da:	89 c2                	mov    %eax,%edx
f01039dc:	83 e2 02             	and    $0x2,%edx
f01039df:	be a3 69 10 f0       	mov    $0xf01069a3,%esi
f01039e4:	ba a9 69 10 f0       	mov    $0xf01069a9,%edx
f01039e9:	0f 45 d6             	cmovne %esi,%edx
f01039ec:	83 e0 04             	and    $0x4,%eax
f01039ef:	b8 ae 69 10 f0       	mov    $0xf01069ae,%eax
f01039f4:	be e3 6a 10 f0       	mov    $0xf0106ae3,%esi
f01039f9:	0f 44 c6             	cmove  %esi,%eax
f01039fc:	51                   	push   %ecx
f01039fd:	52                   	push   %edx
f01039fe:	50                   	push   %eax
f01039ff:	68 26 6a 10 f0       	push   $0xf0106a26
f0103a04:	e8 fc fd ff ff       	call   f0103805 <cprintf>
f0103a09:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103a0c:	83 ec 08             	sub    $0x8,%esp
f0103a0f:	ff 73 30             	pushl  0x30(%ebx)
f0103a12:	68 35 6a 10 f0       	push   $0xf0106a35
f0103a17:	e8 e9 fd ff ff       	call   f0103805 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103a1c:	83 c4 08             	add    $0x8,%esp
f0103a1f:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103a23:	50                   	push   %eax
f0103a24:	68 44 6a 10 f0       	push   $0xf0106a44
f0103a29:	e8 d7 fd ff ff       	call   f0103805 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103a2e:	83 c4 08             	add    $0x8,%esp
f0103a31:	ff 73 38             	pushl  0x38(%ebx)
f0103a34:	68 57 6a 10 f0       	push   $0xf0106a57
f0103a39:	e8 c7 fd ff ff       	call   f0103805 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0103a3e:	83 c4 10             	add    $0x10,%esp
f0103a41:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103a45:	75 4b                	jne    f0103a92 <print_trapframe+0x17c>
}
f0103a47:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103a4a:	5b                   	pop    %ebx
f0103a4b:	5e                   	pop    %esi
f0103a4c:	5d                   	pop    %ebp
f0103a4d:	c3                   	ret    
		return excnames[trapno];
f0103a4e:	8b 14 85 60 6c 10 f0 	mov    -0xfef93a0(,%eax,4),%edx
f0103a55:	e9 30 ff ff ff       	jmp    f010398a <print_trapframe+0x74>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103a5a:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103a5e:	0f 85 44 ff ff ff    	jne    f01039a8 <print_trapframe+0x92>
	asm volatile("movl %%cr2,%0" : "=r" (val));
f0103a64:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0103a67:	83 ec 08             	sub    $0x8,%esp
f0103a6a:	50                   	push   %eax
f0103a6b:	68 09 6a 10 f0       	push   $0xf0106a09
f0103a70:	e8 90 fd ff ff       	call   f0103805 <cprintf>
f0103a75:	83 c4 10             	add    $0x10,%esp
f0103a78:	e9 2b ff ff ff       	jmp    f01039a8 <print_trapframe+0x92>
		cprintf("\n");
f0103a7d:	83 ec 0c             	sub    $0xc,%esp
f0103a80:	68 ef 67 10 f0       	push   $0xf01067ef
f0103a85:	e8 7b fd ff ff       	call   f0103805 <cprintf>
f0103a8a:	83 c4 10             	add    $0x10,%esp
f0103a8d:	e9 7a ff ff ff       	jmp    f0103a0c <print_trapframe+0xf6>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0103a92:	83 ec 08             	sub    $0x8,%esp
f0103a95:	ff 73 3c             	pushl  0x3c(%ebx)
f0103a98:	68 66 6a 10 f0       	push   $0xf0106a66
f0103a9d:	e8 63 fd ff ff       	call   f0103805 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0103aa2:	83 c4 08             	add    $0x8,%esp
f0103aa5:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0103aa9:	50                   	push   %eax
f0103aaa:	68 75 6a 10 f0       	push   $0xf0106a75
f0103aaf:	e8 51 fd ff ff       	call   f0103805 <cprintf>
f0103ab4:	83 c4 10             	add    $0x10,%esp
}
f0103ab7:	eb 8e                	jmp    f0103a47 <print_trapframe+0x131>

f0103ab9 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0103ab9:	55                   	push   %ebp
f0103aba:	89 e5                	mov    %esp,%ebp
f0103abc:	57                   	push   %edi
f0103abd:	56                   	push   %esi
f0103abe:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0103ac1:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f0103ac2:	83 3d 00 1f 23 f0 00 	cmpl   $0x0,0xf0231f00
f0103ac9:	74 01                	je     f0103acc <trap+0x13>
		asm volatile("hlt");
f0103acb:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f0103acc:	e8 29 14 00 00       	call   f0104efa <cpunum>
f0103ad1:	6b d0 74             	imul   $0x74,%eax,%edx
f0103ad4:	83 c2 04             	add    $0x4,%edx
	asm volatile("lock; xchgl %0, %1"
f0103ad7:	b8 01 00 00 00       	mov    $0x1,%eax
f0103adc:	f0 87 82 20 20 23 f0 	lock xchg %eax,-0xfdcdfe0(%edx)
f0103ae3:	83 f8 02             	cmp    $0x2,%eax
f0103ae6:	0f 84 8a 00 00 00    	je     f0103b76 <trap+0xbd>
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f0103aec:	9c                   	pushf  
f0103aed:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0103aee:	f6 c4 02             	test   $0x2,%ah
f0103af1:	0f 85 94 00 00 00    	jne    f0103b8b <trap+0xd2>

	if ((tf->tf_cs & 3) == 3) {
f0103af7:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0103afb:	83 e0 03             	and    $0x3,%eax
f0103afe:	66 83 f8 03          	cmp    $0x3,%ax
f0103b02:	0f 84 9c 00 00 00    	je     f0103ba4 <trap+0xeb>
		tf = &curenv->env_tf;
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0103b08:	89 35 60 1a 23 f0    	mov    %esi,0xf0231a60
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f0103b0e:	83 7e 28 27          	cmpl   $0x27,0x28(%esi)
f0103b12:	0f 84 21 01 00 00    	je     f0103c39 <trap+0x180>
	print_trapframe(tf);
f0103b18:	83 ec 0c             	sub    $0xc,%esp
f0103b1b:	56                   	push   %esi
f0103b1c:	e8 f5 fd ff ff       	call   f0103916 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0103b21:	83 c4 10             	add    $0x10,%esp
f0103b24:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0103b29:	0f 84 27 01 00 00    	je     f0103c56 <trap+0x19d>
		env_destroy(curenv);
f0103b2f:	e8 c6 13 00 00       	call   f0104efa <cpunum>
f0103b34:	83 ec 0c             	sub    $0xc,%esp
f0103b37:	6b c0 74             	imul   $0x74,%eax,%eax
f0103b3a:	ff b0 28 20 23 f0    	pushl  -0xfdcdfd8(%eax)
f0103b40:	e8 07 fa ff ff       	call   f010354c <env_destroy>
f0103b45:	83 c4 10             	add    $0x10,%esp
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f0103b48:	e8 ad 13 00 00       	call   f0104efa <cpunum>
f0103b4d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103b50:	83 b8 28 20 23 f0 00 	cmpl   $0x0,-0xfdcdfd8(%eax)
f0103b57:	74 18                	je     f0103b71 <trap+0xb8>
f0103b59:	e8 9c 13 00 00       	call   f0104efa <cpunum>
f0103b5e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103b61:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0103b67:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103b6b:	0f 84 fc 00 00 00    	je     f0103c6d <trap+0x1b4>
		env_run(curenv);
	else
		sched_yield();
f0103b71:	e8 2e 02 00 00       	call   f0103da4 <sched_yield>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0103b76:	83 ec 0c             	sub    $0xc,%esp
f0103b79:	68 c0 13 12 f0       	push   $0xf01213c0
f0103b7e:	e8 e7 15 00 00       	call   f010516a <spin_lock>
f0103b83:	83 c4 10             	add    $0x10,%esp
f0103b86:	e9 61 ff ff ff       	jmp    f0103aec <trap+0x33>
	assert(!(read_eflags() & FL_IF));
f0103b8b:	68 88 6a 10 f0       	push   $0xf0106a88
f0103b90:	68 e9 64 10 f0       	push   $0xf01064e9
f0103b95:	68 de 00 00 00       	push   $0xde
f0103b9a:	68 a1 6a 10 f0       	push   $0xf0106aa1
f0103b9f:	e8 f0 c4 ff ff       	call   f0100094 <_panic>
		assert(curenv);
f0103ba4:	e8 51 13 00 00       	call   f0104efa <cpunum>
f0103ba9:	6b c0 74             	imul   $0x74,%eax,%eax
f0103bac:	83 b8 28 20 23 f0 00 	cmpl   $0x0,-0xfdcdfd8(%eax)
f0103bb3:	74 3e                	je     f0103bf3 <trap+0x13a>
		if (curenv->env_status == ENV_DYING) {
f0103bb5:	e8 40 13 00 00       	call   f0104efa <cpunum>
f0103bba:	6b c0 74             	imul   $0x74,%eax,%eax
f0103bbd:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0103bc3:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0103bc7:	74 43                	je     f0103c0c <trap+0x153>
		curenv->env_tf = *tf;
f0103bc9:	e8 2c 13 00 00       	call   f0104efa <cpunum>
f0103bce:	6b c0 74             	imul   $0x74,%eax,%eax
f0103bd1:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0103bd7:	b9 11 00 00 00       	mov    $0x11,%ecx
f0103bdc:	89 c7                	mov    %eax,%edi
f0103bde:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		tf = &curenv->env_tf;
f0103be0:	e8 15 13 00 00       	call   f0104efa <cpunum>
f0103be5:	6b c0 74             	imul   $0x74,%eax,%eax
f0103be8:	8b b0 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%esi
f0103bee:	e9 15 ff ff ff       	jmp    f0103b08 <trap+0x4f>
		assert(curenv);
f0103bf3:	68 ad 6a 10 f0       	push   $0xf0106aad
f0103bf8:	68 e9 64 10 f0       	push   $0xf01064e9
f0103bfd:	68 e5 00 00 00       	push   $0xe5
f0103c02:	68 a1 6a 10 f0       	push   $0xf0106aa1
f0103c07:	e8 88 c4 ff ff       	call   f0100094 <_panic>
			env_free(curenv);
f0103c0c:	e8 e9 12 00 00       	call   f0104efa <cpunum>
f0103c11:	83 ec 0c             	sub    $0xc,%esp
f0103c14:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c17:	ff b0 28 20 23 f0    	pushl  -0xfdcdfd8(%eax)
f0103c1d:	e8 49 f7 ff ff       	call   f010336b <env_free>
			curenv = NULL;
f0103c22:	e8 d3 12 00 00       	call   f0104efa <cpunum>
f0103c27:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c2a:	c7 80 28 20 23 f0 00 	movl   $0x0,-0xfdcdfd8(%eax)
f0103c31:	00 00 00 
			sched_yield();
f0103c34:	e8 6b 01 00 00       	call   f0103da4 <sched_yield>
		cprintf("Spurious interrupt on irq 7\n");
f0103c39:	83 ec 0c             	sub    $0xc,%esp
f0103c3c:	68 b4 6a 10 f0       	push   $0xf0106ab4
f0103c41:	e8 bf fb ff ff       	call   f0103805 <cprintf>
		print_trapframe(tf);
f0103c46:	89 34 24             	mov    %esi,(%esp)
f0103c49:	e8 c8 fc ff ff       	call   f0103916 <print_trapframe>
f0103c4e:	83 c4 10             	add    $0x10,%esp
f0103c51:	e9 f2 fe ff ff       	jmp    f0103b48 <trap+0x8f>
		panic("unhandled trap in kernel");
f0103c56:	83 ec 04             	sub    $0x4,%esp
f0103c59:	68 d1 6a 10 f0       	push   $0xf0106ad1
f0103c5e:	68 c4 00 00 00       	push   $0xc4
f0103c63:	68 a1 6a 10 f0       	push   $0xf0106aa1
f0103c68:	e8 27 c4 ff ff       	call   f0100094 <_panic>
		env_run(curenv);
f0103c6d:	e8 88 12 00 00       	call   f0104efa <cpunum>
f0103c72:	83 ec 0c             	sub    $0xc,%esp
f0103c75:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c78:	ff b0 28 20 23 f0    	pushl  -0xfdcdfd8(%eax)
f0103c7e:	e8 68 f9 ff ff       	call   f01035eb <env_run>

f0103c83 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0103c83:	55                   	push   %ebp
f0103c84:	89 e5                	mov    %esp,%ebp
f0103c86:	57                   	push   %edi
f0103c87:	56                   	push   %esi
f0103c88:	53                   	push   %ebx
f0103c89:	83 ec 0c             	sub    $0xc,%esp
f0103c8c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	asm volatile("movl %%cr2,%0" : "=r" (val));
f0103c8f:	0f 20 d6             	mov    %cr2,%esi
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103c92:	8b 7b 30             	mov    0x30(%ebx),%edi
		curenv->env_id, fault_va, tf->tf_eip);
f0103c95:	e8 60 12 00 00       	call   f0104efa <cpunum>
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103c9a:	57                   	push   %edi
f0103c9b:	56                   	push   %esi
		curenv->env_id, fault_va, tf->tf_eip);
f0103c9c:	6b c0 74             	imul   $0x74,%eax,%eax
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103c9f:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0103ca5:	ff 70 48             	pushl  0x48(%eax)
f0103ca8:	68 30 6c 10 f0       	push   $0xf0106c30
f0103cad:	e8 53 fb ff ff       	call   f0103805 <cprintf>
	print_trapframe(tf);
f0103cb2:	89 1c 24             	mov    %ebx,(%esp)
f0103cb5:	e8 5c fc ff ff       	call   f0103916 <print_trapframe>
	env_destroy(curenv);
f0103cba:	e8 3b 12 00 00       	call   f0104efa <cpunum>
f0103cbf:	83 c4 04             	add    $0x4,%esp
f0103cc2:	6b c0 74             	imul   $0x74,%eax,%eax
f0103cc5:	ff b0 28 20 23 f0    	pushl  -0xfdcdfd8(%eax)
f0103ccb:	e8 7c f8 ff ff       	call   f010354c <env_destroy>
}
f0103cd0:	83 c4 10             	add    $0x10,%esp
f0103cd3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103cd6:	5b                   	pop    %ebx
f0103cd7:	5e                   	pop    %esi
f0103cd8:	5f                   	pop    %edi
f0103cd9:	5d                   	pop    %ebp
f0103cda:	c3                   	ret    

f0103cdb <sched_halt>:
f0103cdb:	55                   	push   %ebp
f0103cdc:	89 e5                	mov    %esp,%ebp
f0103cde:	83 ec 08             	sub    $0x8,%esp
f0103ce1:	a1 44 12 23 f0       	mov    0xf0231244,%eax
f0103ce6:	8d 50 54             	lea    0x54(%eax),%edx
f0103ce9:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103cee:	8b 02                	mov    (%edx),%eax
f0103cf0:	83 e8 01             	sub    $0x1,%eax
f0103cf3:	83 f8 02             	cmp    $0x2,%eax
f0103cf6:	76 2d                	jbe    f0103d25 <sched_halt+0x4a>
f0103cf8:	83 c1 01             	add    $0x1,%ecx
f0103cfb:	83 c2 7c             	add    $0x7c,%edx
f0103cfe:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f0103d04:	75 e8                	jne    f0103cee <sched_halt+0x13>
f0103d06:	83 ec 0c             	sub    $0xc,%esp
f0103d09:	68 b0 6c 10 f0       	push   $0xf0106cb0
f0103d0e:	e8 f2 fa ff ff       	call   f0103805 <cprintf>
f0103d13:	83 c4 10             	add    $0x10,%esp
f0103d16:	83 ec 0c             	sub    $0xc,%esp
f0103d19:	6a 00                	push   $0x0
f0103d1b:	e8 13 cc ff ff       	call   f0100933 <monitor>
f0103d20:	83 c4 10             	add    $0x10,%esp
f0103d23:	eb f1                	jmp    f0103d16 <sched_halt+0x3b>
f0103d25:	e8 d0 11 00 00       	call   f0104efa <cpunum>
f0103d2a:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d2d:	c7 80 28 20 23 f0 00 	movl   $0x0,-0xfdcdfd8(%eax)
f0103d34:	00 00 00 
f0103d37:	a1 0c 1f 23 f0       	mov    0xf0231f0c,%eax
f0103d3c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103d41:	76 4f                	jbe    f0103d92 <sched_halt+0xb7>
f0103d43:	05 00 00 00 10       	add    $0x10000000,%eax
f0103d48:	0f 22 d8             	mov    %eax,%cr3
f0103d4b:	e8 aa 11 00 00       	call   f0104efa <cpunum>
f0103d50:	6b d0 74             	imul   $0x74,%eax,%edx
f0103d53:	83 c2 04             	add    $0x4,%edx
f0103d56:	b8 02 00 00 00       	mov    $0x2,%eax
f0103d5b:	f0 87 82 20 20 23 f0 	lock xchg %eax,-0xfdcdfe0(%edx)
f0103d62:	83 ec 0c             	sub    $0xc,%esp
f0103d65:	68 c0 13 12 f0       	push   $0xf01213c0
f0103d6a:	e8 97 14 00 00       	call   f0105206 <spin_unlock>
f0103d6f:	f3 90                	pause  
f0103d71:	e8 84 11 00 00       	call   f0104efa <cpunum>
f0103d76:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d79:	8b 80 30 20 23 f0    	mov    -0xfdcdfd0(%eax),%eax
f0103d7f:	bd 00 00 00 00       	mov    $0x0,%ebp
f0103d84:	89 c4                	mov    %eax,%esp
f0103d86:	6a 00                	push   $0x0
f0103d88:	6a 00                	push   $0x0
f0103d8a:	f4                   	hlt    
f0103d8b:	eb fd                	jmp    f0103d8a <sched_halt+0xaf>
f0103d8d:	83 c4 10             	add    $0x10,%esp
f0103d90:	c9                   	leave  
f0103d91:	c3                   	ret    
f0103d92:	50                   	push   %eax
f0103d93:	68 18 56 10 f0       	push   $0xf0105618
f0103d98:	6a 3d                	push   $0x3d
f0103d9a:	68 d9 6c 10 f0       	push   $0xf0106cd9
f0103d9f:	e8 f0 c2 ff ff       	call   f0100094 <_panic>

f0103da4 <sched_yield>:
f0103da4:	55                   	push   %ebp
f0103da5:	89 e5                	mov    %esp,%ebp
f0103da7:	83 ec 08             	sub    $0x8,%esp
f0103daa:	e8 2c ff ff ff       	call   f0103cdb <sched_halt>
f0103daf:	c9                   	leave  
f0103db0:	c3                   	ret    

f0103db1 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0103db1:	55                   	push   %ebp
f0103db2:	89 e5                	mov    %esp,%ebp
f0103db4:	83 ec 0c             	sub    $0xc,%esp
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.

	panic("syscall not implemented");
f0103db7:	68 e6 6c 10 f0       	push   $0xf0106ce6
f0103dbc:	68 12 01 00 00       	push   $0x112
f0103dc1:	68 fe 6c 10 f0       	push   $0xf0106cfe
f0103dc6:	e8 c9 c2 ff ff       	call   f0100094 <_panic>

f0103dcb <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0103dcb:	55                   	push   %ebp
f0103dcc:	89 e5                	mov    %esp,%ebp
f0103dce:	57                   	push   %edi
f0103dcf:	56                   	push   %esi
f0103dd0:	53                   	push   %ebx
f0103dd1:	83 ec 14             	sub    $0x14,%esp
f0103dd4:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103dd7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0103dda:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0103ddd:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0103de0:	8b 1a                	mov    (%edx),%ebx
f0103de2:	8b 01                	mov    (%ecx),%eax
f0103de4:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103de7:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0103dee:	eb 23                	jmp    f0103e13 <stab_binsearch+0x48>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0103df0:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0103df3:	eb 1e                	jmp    f0103e13 <stab_binsearch+0x48>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0103df5:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103df8:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0103dfb:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0103dff:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0103e02:	73 41                	jae    f0103e45 <stab_binsearch+0x7a>
			*region_left = m;
f0103e04:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0103e07:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0103e09:	8d 5f 01             	lea    0x1(%edi),%ebx
		any_matches = 1;
f0103e0c:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0103e13:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0103e16:	7f 5a                	jg     f0103e72 <stab_binsearch+0xa7>
		int true_m = (l + r) / 2, m = true_m;
f0103e18:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103e1b:	01 d8                	add    %ebx,%eax
f0103e1d:	89 c7                	mov    %eax,%edi
f0103e1f:	c1 ef 1f             	shr    $0x1f,%edi
f0103e22:	01 c7                	add    %eax,%edi
f0103e24:	d1 ff                	sar    %edi
f0103e26:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0103e29:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0103e2c:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0103e30:	89 f8                	mov    %edi,%eax
		while (m >= l && stabs[m].n_type != type)
f0103e32:	39 c3                	cmp    %eax,%ebx
f0103e34:	7f ba                	jg     f0103df0 <stab_binsearch+0x25>
f0103e36:	0f b6 0a             	movzbl (%edx),%ecx
f0103e39:	83 ea 0c             	sub    $0xc,%edx
f0103e3c:	39 f1                	cmp    %esi,%ecx
f0103e3e:	74 b5                	je     f0103df5 <stab_binsearch+0x2a>
			m--;
f0103e40:	83 e8 01             	sub    $0x1,%eax
f0103e43:	eb ed                	jmp    f0103e32 <stab_binsearch+0x67>
		} else if (stabs[m].n_value > addr) {
f0103e45:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0103e48:	76 14                	jbe    f0103e5e <stab_binsearch+0x93>
			*region_right = m - 1;
f0103e4a:	83 e8 01             	sub    $0x1,%eax
f0103e4d:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103e50:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0103e53:	89 07                	mov    %eax,(%edi)
		any_matches = 1;
f0103e55:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0103e5c:	eb b5                	jmp    f0103e13 <stab_binsearch+0x48>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0103e5e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103e61:	89 07                	mov    %eax,(%edi)
			l = m;
			addr++;
f0103e63:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0103e67:	89 c3                	mov    %eax,%ebx
		any_matches = 1;
f0103e69:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0103e70:	eb a1                	jmp    f0103e13 <stab_binsearch+0x48>
		}
	}

	if (!any_matches)
f0103e72:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0103e76:	75 15                	jne    f0103e8d <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f0103e78:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103e7b:	8b 00                	mov    (%eax),%eax
f0103e7d:	83 e8 01             	sub    $0x1,%eax
f0103e80:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0103e83:	89 06                	mov    %eax,(%esi)
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0103e85:	83 c4 14             	add    $0x14,%esp
f0103e88:	5b                   	pop    %ebx
f0103e89:	5e                   	pop    %esi
f0103e8a:	5f                   	pop    %edi
f0103e8b:	5d                   	pop    %ebp
f0103e8c:	c3                   	ret    
		for (l = *region_right;
f0103e8d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103e90:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0103e92:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103e95:	8b 0f                	mov    (%edi),%ecx
f0103e97:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103e9a:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0103e9d:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
		for (l = *region_right;
f0103ea1:	eb 03                	jmp    f0103ea6 <stab_binsearch+0xdb>
		     l--)
f0103ea3:	83 e8 01             	sub    $0x1,%eax
		for (l = *region_right;
f0103ea6:	39 c1                	cmp    %eax,%ecx
f0103ea8:	7d 0a                	jge    f0103eb4 <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f0103eaa:	0f b6 1a             	movzbl (%edx),%ebx
f0103ead:	83 ea 0c             	sub    $0xc,%edx
f0103eb0:	39 f3                	cmp    %esi,%ebx
f0103eb2:	75 ef                	jne    f0103ea3 <stab_binsearch+0xd8>
		*region_left = l;
f0103eb4:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0103eb7:	89 06                	mov    %eax,(%esi)
}
f0103eb9:	eb ca                	jmp    f0103e85 <stab_binsearch+0xba>

f0103ebb <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0103ebb:	55                   	push   %ebp
f0103ebc:	89 e5                	mov    %esp,%ebp
f0103ebe:	57                   	push   %edi
f0103ebf:	56                   	push   %esi
f0103ec0:	53                   	push   %ebx
f0103ec1:	83 ec 4c             	sub    $0x4c,%esp
f0103ec4:	8b 75 08             	mov    0x8(%ebp),%esi
f0103ec7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0103eca:	c7 03 0d 6d 10 f0    	movl   $0xf0106d0d,(%ebx)
	info->eip_line = 0;
f0103ed0:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0103ed7:	c7 43 08 0d 6d 10 f0 	movl   $0xf0106d0d,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0103ede:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0103ee5:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0103ee8:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0103eef:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0103ef5:	0f 87 1d 01 00 00    	ja     f0104018 <debuginfo_eip+0x15d>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f0103efb:	a1 00 00 20 00       	mov    0x200000,%eax
f0103f00:	89 45 b8             	mov    %eax,-0x48(%ebp)
		stab_end = usd->stab_end;
f0103f03:	a1 04 00 20 00       	mov    0x200004,%eax
		stabstr = usd->stabstr;
f0103f08:	8b 3d 08 00 20 00    	mov    0x200008,%edi
f0103f0e:	89 7d b4             	mov    %edi,-0x4c(%ebp)
		stabstr_end = usd->stabstr_end;
f0103f11:	8b 3d 0c 00 20 00    	mov    0x20000c,%edi
f0103f17:	89 7d bc             	mov    %edi,-0x44(%ebp)
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0103f1a:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0103f1d:	39 7d b4             	cmp    %edi,-0x4c(%ebp)
f0103f20:	0f 83 bb 01 00 00    	jae    f01040e1 <debuginfo_eip+0x226>
f0103f26:	80 7f ff 00          	cmpb   $0x0,-0x1(%edi)
f0103f2a:	0f 85 b8 01 00 00    	jne    f01040e8 <debuginfo_eip+0x22d>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0103f30:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0103f37:	8b 7d b8             	mov    -0x48(%ebp),%edi
f0103f3a:	29 f8                	sub    %edi,%eax
f0103f3c:	c1 f8 02             	sar    $0x2,%eax
f0103f3f:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0103f45:	83 e8 01             	sub    $0x1,%eax
f0103f48:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0103f4b:	56                   	push   %esi
f0103f4c:	6a 64                	push   $0x64
f0103f4e:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0103f51:	89 c1                	mov    %eax,%ecx
f0103f53:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0103f56:	89 f8                	mov    %edi,%eax
f0103f58:	e8 6e fe ff ff       	call   f0103dcb <stab_binsearch>
	if (lfile == 0)
f0103f5d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103f60:	83 c4 08             	add    $0x8,%esp
f0103f63:	85 c0                	test   %eax,%eax
f0103f65:	0f 84 84 01 00 00    	je     f01040ef <debuginfo_eip+0x234>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0103f6b:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0103f6e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103f71:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0103f74:	56                   	push   %esi
f0103f75:	6a 24                	push   $0x24
f0103f77:	8d 45 d8             	lea    -0x28(%ebp),%eax
f0103f7a:	89 c1                	mov    %eax,%ecx
f0103f7c:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0103f7f:	89 f8                	mov    %edi,%eax
f0103f81:	e8 45 fe ff ff       	call   f0103dcb <stab_binsearch>

	if (lfun <= rfun) {
f0103f86:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103f89:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0103f8c:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
f0103f8f:	83 c4 08             	add    $0x8,%esp
f0103f92:	39 c8                	cmp    %ecx,%eax
f0103f94:	0f 8f 9d 00 00 00    	jg     f0104037 <debuginfo_eip+0x17c>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0103f9a:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103f9d:	8d 0c 97             	lea    (%edi,%edx,4),%ecx
f0103fa0:	8b 11                	mov    (%ecx),%edx
f0103fa2:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0103fa5:	2b 7d b4             	sub    -0x4c(%ebp),%edi
f0103fa8:	39 fa                	cmp    %edi,%edx
f0103faa:	73 06                	jae    f0103fb2 <debuginfo_eip+0xf7>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0103fac:	03 55 b4             	add    -0x4c(%ebp),%edx
f0103faf:	89 53 08             	mov    %edx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0103fb2:	8b 51 08             	mov    0x8(%ecx),%edx
f0103fb5:	89 53 10             	mov    %edx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0103fb8:	29 d6                	sub    %edx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0103fba:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0103fbd:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0103fc0:	89 45 d0             	mov    %eax,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0103fc3:	83 ec 08             	sub    $0x8,%esp
f0103fc6:	6a 3a                	push   $0x3a
f0103fc8:	ff 73 08             	pushl  0x8(%ebx)
f0103fcb:	e8 0e 09 00 00       	call   f01048de <strfind>
f0103fd0:	2b 43 08             	sub    0x8(%ebx),%eax
f0103fd3:	89 43 0c             	mov    %eax,0xc(%ebx)
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0103fd6:	83 c4 08             	add    $0x8,%esp
f0103fd9:	56                   	push   %esi
f0103fda:	6a 44                	push   $0x44
f0103fdc:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0103fdf:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0103fe2:	8b 75 b8             	mov    -0x48(%ebp),%esi
f0103fe5:	89 f0                	mov    %esi,%eax
f0103fe7:	e8 df fd ff ff       	call   f0103dcb <stab_binsearch>
	if (lline <= rline) {
f0103fec:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103fef:	83 c4 10             	add    $0x10,%esp
f0103ff2:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f0103ff5:	0f 8f fb 00 00 00    	jg     f01040f6 <debuginfo_eip+0x23b>
		 info->eip_line = stabs[lline].n_desc;
f0103ffb:	89 d0                	mov    %edx,%eax
f0103ffd:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0104000:	c1 e2 02             	shl    $0x2,%edx
f0104003:	0f b7 4c 16 06       	movzwl 0x6(%esi,%edx,1),%ecx
f0104008:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f010400b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010400e:	8d 54 16 04          	lea    0x4(%esi,%edx,1),%edx
f0104012:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f0104016:	eb 3d                	jmp    f0104055 <debuginfo_eip+0x19a>
		stabstr_end = __STABSTR_END__;
f0104018:	c7 45 bc de 61 11 f0 	movl   $0xf01161de,-0x44(%ebp)
		stabstr = __STABSTR_BEGIN__;
f010401f:	c7 45 b4 d5 2a 11 f0 	movl   $0xf0112ad5,-0x4c(%ebp)
		stab_end = __STAB_END__;
f0104026:	b8 d4 2a 11 f0       	mov    $0xf0112ad4,%eax
		stabs = __STAB_BEGIN__;
f010402b:	c7 45 b8 f4 71 10 f0 	movl   $0xf01071f4,-0x48(%ebp)
f0104032:	e9 e3 fe ff ff       	jmp    f0103f1a <debuginfo_eip+0x5f>
		info->eip_fn_addr = addr;
f0104037:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f010403a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010403d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0104040:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104043:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0104046:	e9 78 ff ff ff       	jmp    f0103fc3 <debuginfo_eip+0x108>
f010404b:	83 e8 01             	sub    $0x1,%eax
f010404e:	83 ea 0c             	sub    $0xc,%edx
f0104051:	c6 45 c4 01          	movb   $0x1,-0x3c(%ebp)
f0104055:	89 45 c0             	mov    %eax,-0x40(%ebp)
	while (lline >= lfile
f0104058:	39 c7                	cmp    %eax,%edi
f010405a:	7f 45                	jg     f01040a1 <debuginfo_eip+0x1e6>
	       && stabs[lline].n_type != N_SOL
f010405c:	0f b6 0a             	movzbl (%edx),%ecx
f010405f:	80 f9 84             	cmp    $0x84,%cl
f0104062:	74 19                	je     f010407d <debuginfo_eip+0x1c2>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104064:	80 f9 64             	cmp    $0x64,%cl
f0104067:	75 e2                	jne    f010404b <debuginfo_eip+0x190>
f0104069:	83 7a 04 00          	cmpl   $0x0,0x4(%edx)
f010406d:	74 dc                	je     f010404b <debuginfo_eip+0x190>
f010406f:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0104073:	74 11                	je     f0104086 <debuginfo_eip+0x1cb>
f0104075:	8b 75 c0             	mov    -0x40(%ebp),%esi
f0104078:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f010407b:	eb 09                	jmp    f0104086 <debuginfo_eip+0x1cb>
f010407d:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0104081:	74 03                	je     f0104086 <debuginfo_eip+0x1cb>
f0104083:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0104086:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0104089:	8b 7d b8             	mov    -0x48(%ebp),%edi
f010408c:	8b 14 87             	mov    (%edi,%eax,4),%edx
f010408f:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0104092:	8b 7d b4             	mov    -0x4c(%ebp),%edi
f0104095:	29 f8                	sub    %edi,%eax
f0104097:	39 c2                	cmp    %eax,%edx
f0104099:	73 06                	jae    f01040a1 <debuginfo_eip+0x1e6>
		info->eip_file = stabstr + stabs[lline].n_strx;
f010409b:	89 f8                	mov    %edi,%eax
f010409d:	01 d0                	add    %edx,%eax
f010409f:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01040a1:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01040a4:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01040a7:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f01040ac:	39 f2                	cmp    %esi,%edx
f01040ae:	7d 52                	jge    f0104102 <debuginfo_eip+0x247>
		for (lline = lfun + 1;
f01040b0:	83 c2 01             	add    $0x1,%edx
f01040b3:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f01040b6:	89 d0                	mov    %edx,%eax
f01040b8:	8d 14 52             	lea    (%edx,%edx,2),%edx
f01040bb:	8b 7d b8             	mov    -0x48(%ebp),%edi
f01040be:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
f01040c2:	eb 04                	jmp    f01040c8 <debuginfo_eip+0x20d>
			info->eip_fn_narg++;
f01040c4:	83 43 14 01          	addl   $0x1,0x14(%ebx)
		for (lline = lfun + 1;
f01040c8:	39 c6                	cmp    %eax,%esi
f01040ca:	7e 31                	jle    f01040fd <debuginfo_eip+0x242>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01040cc:	0f b6 0a             	movzbl (%edx),%ecx
f01040cf:	83 c0 01             	add    $0x1,%eax
f01040d2:	83 c2 0c             	add    $0xc,%edx
f01040d5:	80 f9 a0             	cmp    $0xa0,%cl
f01040d8:	74 ea                	je     f01040c4 <debuginfo_eip+0x209>
	return 0;
f01040da:	b8 00 00 00 00       	mov    $0x0,%eax
f01040df:	eb 21                	jmp    f0104102 <debuginfo_eip+0x247>
		return -1;
f01040e1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01040e6:	eb 1a                	jmp    f0104102 <debuginfo_eip+0x247>
f01040e8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01040ed:	eb 13                	jmp    f0104102 <debuginfo_eip+0x247>
		return -1;
f01040ef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01040f4:	eb 0c                	jmp    f0104102 <debuginfo_eip+0x247>
		 return -1;
f01040f6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01040fb:	eb 05                	jmp    f0104102 <debuginfo_eip+0x247>
	return 0;
f01040fd:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104102:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104105:	5b                   	pop    %ebx
f0104106:	5e                   	pop    %esi
f0104107:	5f                   	pop    %edi
f0104108:	5d                   	pop    %ebp
f0104109:	c3                   	ret    

f010410a <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f010410a:	55                   	push   %ebp
f010410b:	89 e5                	mov    %esp,%ebp
f010410d:	57                   	push   %edi
f010410e:	56                   	push   %esi
f010410f:	53                   	push   %ebx
f0104110:	83 ec 1c             	sub    $0x1c,%esp
f0104113:	89 c7                	mov    %eax,%edi
f0104115:	89 d6                	mov    %edx,%esi
f0104117:	8b 45 08             	mov    0x8(%ebp),%eax
f010411a:	8b 55 0c             	mov    0xc(%ebp),%edx
f010411d:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104120:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0104123:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104126:	bb 00 00 00 00       	mov    $0x0,%ebx
f010412b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f010412e:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0104131:	3b 45 10             	cmp    0x10(%ebp),%eax
f0104134:	89 d0                	mov    %edx,%eax
f0104136:	1b 45 e4             	sbb    -0x1c(%ebp),%eax
f0104139:	8b 5d 14             	mov    0x14(%ebp),%ebx
f010413c:	73 15                	jae    f0104153 <printnum+0x49>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f010413e:	83 eb 01             	sub    $0x1,%ebx
f0104141:	85 db                	test   %ebx,%ebx
f0104143:	7e 43                	jle    f0104188 <printnum+0x7e>
			putch(padc, putdat);
f0104145:	83 ec 08             	sub    $0x8,%esp
f0104148:	56                   	push   %esi
f0104149:	ff 75 18             	pushl  0x18(%ebp)
f010414c:	ff d7                	call   *%edi
f010414e:	83 c4 10             	add    $0x10,%esp
f0104151:	eb eb                	jmp    f010413e <printnum+0x34>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0104153:	83 ec 0c             	sub    $0xc,%esp
f0104156:	ff 75 18             	pushl  0x18(%ebp)
f0104159:	8b 45 14             	mov    0x14(%ebp),%eax
f010415c:	8d 58 ff             	lea    -0x1(%eax),%ebx
f010415f:	53                   	push   %ebx
f0104160:	ff 75 10             	pushl  0x10(%ebp)
f0104163:	83 ec 08             	sub    $0x8,%esp
f0104166:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104169:	ff 75 e0             	pushl  -0x20(%ebp)
f010416c:	ff 75 dc             	pushl  -0x24(%ebp)
f010416f:	ff 75 d8             	pushl  -0x28(%ebp)
f0104172:	e8 79 11 00 00       	call   f01052f0 <__udivdi3>
f0104177:	83 c4 18             	add    $0x18,%esp
f010417a:	52                   	push   %edx
f010417b:	50                   	push   %eax
f010417c:	89 f2                	mov    %esi,%edx
f010417e:	89 f8                	mov    %edi,%eax
f0104180:	e8 85 ff ff ff       	call   f010410a <printnum>
f0104185:	83 c4 20             	add    $0x20,%esp
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0104188:	83 ec 08             	sub    $0x8,%esp
f010418b:	56                   	push   %esi
f010418c:	83 ec 04             	sub    $0x4,%esp
f010418f:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104192:	ff 75 e0             	pushl  -0x20(%ebp)
f0104195:	ff 75 dc             	pushl  -0x24(%ebp)
f0104198:	ff 75 d8             	pushl  -0x28(%ebp)
f010419b:	e8 60 12 00 00       	call   f0105400 <__umoddi3>
f01041a0:	83 c4 14             	add    $0x14,%esp
f01041a3:	0f be 80 17 6d 10 f0 	movsbl -0xfef92e9(%eax),%eax
f01041aa:	50                   	push   %eax
f01041ab:	ff d7                	call   *%edi
}
f01041ad:	83 c4 10             	add    $0x10,%esp
f01041b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01041b3:	5b                   	pop    %ebx
f01041b4:	5e                   	pop    %esi
f01041b5:	5f                   	pop    %edi
f01041b6:	5d                   	pop    %ebp
f01041b7:	c3                   	ret    

f01041b8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f01041b8:	55                   	push   %ebp
f01041b9:	89 e5                	mov    %esp,%ebp
f01041bb:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f01041be:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f01041c2:	8b 10                	mov    (%eax),%edx
f01041c4:	3b 50 04             	cmp    0x4(%eax),%edx
f01041c7:	73 0a                	jae    f01041d3 <sprintputch+0x1b>
		*b->buf++ = ch;
f01041c9:	8d 4a 01             	lea    0x1(%edx),%ecx
f01041cc:	89 08                	mov    %ecx,(%eax)
f01041ce:	8b 45 08             	mov    0x8(%ebp),%eax
f01041d1:	88 02                	mov    %al,(%edx)
}
f01041d3:	5d                   	pop    %ebp
f01041d4:	c3                   	ret    

f01041d5 <printfmt>:
{
f01041d5:	55                   	push   %ebp
f01041d6:	89 e5                	mov    %esp,%ebp
f01041d8:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f01041db:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f01041de:	50                   	push   %eax
f01041df:	ff 75 10             	pushl  0x10(%ebp)
f01041e2:	ff 75 0c             	pushl  0xc(%ebp)
f01041e5:	ff 75 08             	pushl  0x8(%ebp)
f01041e8:	e8 05 00 00 00       	call   f01041f2 <vprintfmt>
}
f01041ed:	83 c4 10             	add    $0x10,%esp
f01041f0:	c9                   	leave  
f01041f1:	c3                   	ret    

f01041f2 <vprintfmt>:
{
f01041f2:	55                   	push   %ebp
f01041f3:	89 e5                	mov    %esp,%ebp
f01041f5:	57                   	push   %edi
f01041f6:	56                   	push   %esi
f01041f7:	53                   	push   %ebx
f01041f8:	83 ec 3c             	sub    $0x3c,%esp
f01041fb:	8b 75 08             	mov    0x8(%ebp),%esi
f01041fe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104201:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104204:	eb 0a                	jmp    f0104210 <vprintfmt+0x1e>
			putch(ch, putdat);
f0104206:	83 ec 08             	sub    $0x8,%esp
f0104209:	53                   	push   %ebx
f010420a:	50                   	push   %eax
f010420b:	ff d6                	call   *%esi
f010420d:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0104210:	83 c7 01             	add    $0x1,%edi
f0104213:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0104217:	83 f8 25             	cmp    $0x25,%eax
f010421a:	74 0c                	je     f0104228 <vprintfmt+0x36>
			if (ch == '\0')
f010421c:	85 c0                	test   %eax,%eax
f010421e:	75 e6                	jne    f0104206 <vprintfmt+0x14>
}
f0104220:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104223:	5b                   	pop    %ebx
f0104224:	5e                   	pop    %esi
f0104225:	5f                   	pop    %edi
f0104226:	5d                   	pop    %ebp
f0104227:	c3                   	ret    
		padc = ' ';
f0104228:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
f010422c:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;//精度
f0104233:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;//总宽度
f010423a:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f0104241:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f0104246:	8d 47 01             	lea    0x1(%edi),%eax
f0104249:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010424c:	0f b6 17             	movzbl (%edi),%edx
f010424f:	8d 42 dd             	lea    -0x23(%edx),%eax
f0104252:	3c 55                	cmp    $0x55,%al
f0104254:	0f 87 ba 03 00 00    	ja     f0104614 <vprintfmt+0x422>
f010425a:	0f b6 c0             	movzbl %al,%eax
f010425d:	ff 24 85 e0 6d 10 f0 	jmp    *-0xfef9220(,%eax,4)
f0104264:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
f0104267:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
f010426b:	eb d9                	jmp    f0104246 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
f010426d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
f0104270:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
f0104274:	eb d0                	jmp    f0104246 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
f0104276:	0f b6 d2             	movzbl %dl,%edx
f0104279:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {//依次读取数据宽度
f010427c:	b8 00 00 00 00       	mov    $0x0,%eax
f0104281:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
f0104284:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0104287:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f010428b:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f010428e:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0104291:	83 f9 09             	cmp    $0x9,%ecx
f0104294:	77 55                	ja     f01042eb <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {//依次读取数据宽度
f0104296:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
f0104299:	eb e9                	jmp    f0104284 <vprintfmt+0x92>
			precision = va_arg(ap, int);
f010429b:	8b 45 14             	mov    0x14(%ebp),%eax
f010429e:	8b 00                	mov    (%eax),%eax
f01042a0:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01042a3:	8b 45 14             	mov    0x14(%ebp),%eax
f01042a6:	8d 40 04             	lea    0x4(%eax),%eax
f01042a9:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01042ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
f01042af:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01042b3:	79 91                	jns    f0104246 <vprintfmt+0x54>
				width = precision, precision = -1;
f01042b5:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01042b8:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01042bb:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
f01042c2:	eb 82                	jmp    f0104246 <vprintfmt+0x54>
f01042c4:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01042c7:	85 c0                	test   %eax,%eax
f01042c9:	ba 00 00 00 00       	mov    $0x0,%edx
f01042ce:	0f 49 d0             	cmovns %eax,%edx
f01042d1:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01042d4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01042d7:	e9 6a ff ff ff       	jmp    f0104246 <vprintfmt+0x54>
f01042dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
f01042df:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
f01042e6:	e9 5b ff ff ff       	jmp    f0104246 <vprintfmt+0x54>
f01042eb:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01042ee:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01042f1:	eb bc                	jmp    f01042af <vprintfmt+0xbd>
			lflag++;
f01042f3:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f01042f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f01042f9:	e9 48 ff ff ff       	jmp    f0104246 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
f01042fe:	8b 45 14             	mov    0x14(%ebp),%eax
f0104301:	8d 78 04             	lea    0x4(%eax),%edi
f0104304:	83 ec 08             	sub    $0x8,%esp
f0104307:	53                   	push   %ebx
f0104308:	ff 30                	pushl  (%eax)
f010430a:	ff d6                	call   *%esi
			break;
f010430c:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f010430f:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
f0104312:	e9 9c 02 00 00       	jmp    f01045b3 <vprintfmt+0x3c1>
			err = va_arg(ap, int);
f0104317:	8b 45 14             	mov    0x14(%ebp),%eax
f010431a:	8d 78 04             	lea    0x4(%eax),%edi
f010431d:	8b 00                	mov    (%eax),%eax
f010431f:	99                   	cltd   
f0104320:	31 d0                	xor    %edx,%eax
f0104322:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0104324:	83 f8 08             	cmp    $0x8,%eax
f0104327:	7f 23                	jg     f010434c <vprintfmt+0x15a>
f0104329:	8b 14 85 40 6f 10 f0 	mov    -0xfef90c0(,%eax,4),%edx
f0104330:	85 d2                	test   %edx,%edx
f0104332:	74 18                	je     f010434c <vprintfmt+0x15a>
				printfmt(putch, putdat, "%s", p);
f0104334:	52                   	push   %edx
f0104335:	68 fb 64 10 f0       	push   $0xf01064fb
f010433a:	53                   	push   %ebx
f010433b:	56                   	push   %esi
f010433c:	e8 94 fe ff ff       	call   f01041d5 <printfmt>
f0104341:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0104344:	89 7d 14             	mov    %edi,0x14(%ebp)
f0104347:	e9 67 02 00 00       	jmp    f01045b3 <vprintfmt+0x3c1>
				printfmt(putch, putdat, "error %d", err);
f010434c:	50                   	push   %eax
f010434d:	68 2f 6d 10 f0       	push   $0xf0106d2f
f0104352:	53                   	push   %ebx
f0104353:	56                   	push   %esi
f0104354:	e8 7c fe ff ff       	call   f01041d5 <printfmt>
f0104359:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f010435c:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f010435f:	e9 4f 02 00 00       	jmp    f01045b3 <vprintfmt+0x3c1>
			if ((p = va_arg(ap, char *)) == NULL)
f0104364:	8b 45 14             	mov    0x14(%ebp),%eax
f0104367:	83 c0 04             	add    $0x4,%eax
f010436a:	89 45 c8             	mov    %eax,-0x38(%ebp)
f010436d:	8b 45 14             	mov    0x14(%ebp),%eax
f0104370:	8b 10                	mov    (%eax),%edx
				p = "(null)";
f0104372:	85 d2                	test   %edx,%edx
f0104374:	b8 28 6d 10 f0       	mov    $0xf0106d28,%eax
f0104379:	0f 45 c2             	cmovne %edx,%eax
f010437c:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
f010437f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0104383:	7e 06                	jle    f010438b <vprintfmt+0x199>
f0104385:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
f0104389:	75 0d                	jne    f0104398 <vprintfmt+0x1a6>
				for (width -= strnlen(p, precision); width > 0; width--)
f010438b:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010438e:	89 c7                	mov    %eax,%edi
f0104390:	03 45 e0             	add    -0x20(%ebp),%eax
f0104393:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104396:	eb 3f                	jmp    f01043d7 <vprintfmt+0x1e5>
f0104398:	83 ec 08             	sub    $0x8,%esp
f010439b:	ff 75 d8             	pushl  -0x28(%ebp)
f010439e:	50                   	push   %eax
f010439f:	e8 ef 03 00 00       	call   f0104793 <strnlen>
f01043a4:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01043a7:	29 c2                	sub    %eax,%edx
f01043a9:	89 55 c4             	mov    %edx,-0x3c(%ebp)
f01043ac:	83 c4 10             	add    $0x10,%esp
f01043af:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
f01043b1:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
f01043b5:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f01043b8:	85 ff                	test   %edi,%edi
f01043ba:	7e 58                	jle    f0104414 <vprintfmt+0x222>
					putch(padc, putdat);
f01043bc:	83 ec 08             	sub    $0x8,%esp
f01043bf:	53                   	push   %ebx
f01043c0:	ff 75 e0             	pushl  -0x20(%ebp)
f01043c3:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f01043c5:	83 ef 01             	sub    $0x1,%edi
f01043c8:	83 c4 10             	add    $0x10,%esp
f01043cb:	eb eb                	jmp    f01043b8 <vprintfmt+0x1c6>
					putch(ch, putdat);
f01043cd:	83 ec 08             	sub    $0x8,%esp
f01043d0:	53                   	push   %ebx
f01043d1:	52                   	push   %edx
f01043d2:	ff d6                	call   *%esi
f01043d4:	83 c4 10             	add    $0x10,%esp
f01043d7:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01043da:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01043dc:	83 c7 01             	add    $0x1,%edi
f01043df:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f01043e3:	0f be d0             	movsbl %al,%edx
f01043e6:	85 d2                	test   %edx,%edx
f01043e8:	74 45                	je     f010442f <vprintfmt+0x23d>
f01043ea:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f01043ee:	78 06                	js     f01043f6 <vprintfmt+0x204>
f01043f0:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
f01043f4:	78 35                	js     f010442b <vprintfmt+0x239>
				if (altflag && (ch < ' ' || ch > '~'))
f01043f6:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f01043fa:	74 d1                	je     f01043cd <vprintfmt+0x1db>
f01043fc:	0f be c0             	movsbl %al,%eax
f01043ff:	83 e8 20             	sub    $0x20,%eax
f0104402:	83 f8 5e             	cmp    $0x5e,%eax
f0104405:	76 c6                	jbe    f01043cd <vprintfmt+0x1db>
					putch('?', putdat);
f0104407:	83 ec 08             	sub    $0x8,%esp
f010440a:	53                   	push   %ebx
f010440b:	6a 3f                	push   $0x3f
f010440d:	ff d6                	call   *%esi
f010440f:	83 c4 10             	add    $0x10,%esp
f0104412:	eb c3                	jmp    f01043d7 <vprintfmt+0x1e5>
f0104414:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0104417:	85 d2                	test   %edx,%edx
f0104419:	b8 00 00 00 00       	mov    $0x0,%eax
f010441e:	0f 49 c2             	cmovns %edx,%eax
f0104421:	29 c2                	sub    %eax,%edx
f0104423:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0104426:	e9 60 ff ff ff       	jmp    f010438b <vprintfmt+0x199>
f010442b:	89 cf                	mov    %ecx,%edi
f010442d:	eb 02                	jmp    f0104431 <vprintfmt+0x23f>
f010442f:	89 cf                	mov    %ecx,%edi
			for (; width > 0; width--)
f0104431:	85 ff                	test   %edi,%edi
f0104433:	7e 10                	jle    f0104445 <vprintfmt+0x253>
				putch(' ', putdat);
f0104435:	83 ec 08             	sub    $0x8,%esp
f0104438:	53                   	push   %ebx
f0104439:	6a 20                	push   $0x20
f010443b:	ff d6                	call   *%esi
			for (; width > 0; width--)
f010443d:	83 ef 01             	sub    $0x1,%edi
f0104440:	83 c4 10             	add    $0x10,%esp
f0104443:	eb ec                	jmp    f0104431 <vprintfmt+0x23f>
			if ((p = va_arg(ap, char *)) == NULL)
f0104445:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0104448:	89 45 14             	mov    %eax,0x14(%ebp)
f010444b:	e9 63 01 00 00       	jmp    f01045b3 <vprintfmt+0x3c1>
	if (lflag >= 2)
f0104450:	83 f9 01             	cmp    $0x1,%ecx
f0104453:	7f 1b                	jg     f0104470 <vprintfmt+0x27e>
	else if (lflag)
f0104455:	85 c9                	test   %ecx,%ecx
f0104457:	74 63                	je     f01044bc <vprintfmt+0x2ca>
		return va_arg(*ap, long);
f0104459:	8b 45 14             	mov    0x14(%ebp),%eax
f010445c:	8b 00                	mov    (%eax),%eax
f010445e:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104461:	99                   	cltd   
f0104462:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0104465:	8b 45 14             	mov    0x14(%ebp),%eax
f0104468:	8d 40 04             	lea    0x4(%eax),%eax
f010446b:	89 45 14             	mov    %eax,0x14(%ebp)
f010446e:	eb 17                	jmp    f0104487 <vprintfmt+0x295>
		return va_arg(*ap, long long);
f0104470:	8b 45 14             	mov    0x14(%ebp),%eax
f0104473:	8b 50 04             	mov    0x4(%eax),%edx
f0104476:	8b 00                	mov    (%eax),%eax
f0104478:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010447b:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010447e:	8b 45 14             	mov    0x14(%ebp),%eax
f0104481:	8d 40 08             	lea    0x8(%eax),%eax
f0104484:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f0104487:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010448a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f010448d:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
f0104492:	85 c9                	test   %ecx,%ecx
f0104494:	0f 89 ff 00 00 00    	jns    f0104599 <vprintfmt+0x3a7>
				putch('-', putdat);
f010449a:	83 ec 08             	sub    $0x8,%esp
f010449d:	53                   	push   %ebx
f010449e:	6a 2d                	push   $0x2d
f01044a0:	ff d6                	call   *%esi
				num = -(long long) num;
f01044a2:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01044a5:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f01044a8:	f7 da                	neg    %edx
f01044aa:	83 d1 00             	adc    $0x0,%ecx
f01044ad:	f7 d9                	neg    %ecx
f01044af:	83 c4 10             	add    $0x10,%esp
			base = 10;
f01044b2:	b8 0a 00 00 00       	mov    $0xa,%eax
f01044b7:	e9 dd 00 00 00       	jmp    f0104599 <vprintfmt+0x3a7>
		return va_arg(*ap, int);
f01044bc:	8b 45 14             	mov    0x14(%ebp),%eax
f01044bf:	8b 00                	mov    (%eax),%eax
f01044c1:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01044c4:	99                   	cltd   
f01044c5:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01044c8:	8b 45 14             	mov    0x14(%ebp),%eax
f01044cb:	8d 40 04             	lea    0x4(%eax),%eax
f01044ce:	89 45 14             	mov    %eax,0x14(%ebp)
f01044d1:	eb b4                	jmp    f0104487 <vprintfmt+0x295>
	if (lflag >= 2)
f01044d3:	83 f9 01             	cmp    $0x1,%ecx
f01044d6:	7f 1e                	jg     f01044f6 <vprintfmt+0x304>
	else if (lflag)
f01044d8:	85 c9                	test   %ecx,%ecx
f01044da:	74 32                	je     f010450e <vprintfmt+0x31c>
		return va_arg(*ap, unsigned long);
f01044dc:	8b 45 14             	mov    0x14(%ebp),%eax
f01044df:	8b 10                	mov    (%eax),%edx
f01044e1:	b9 00 00 00 00       	mov    $0x0,%ecx
f01044e6:	8d 40 04             	lea    0x4(%eax),%eax
f01044e9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01044ec:	b8 0a 00 00 00       	mov    $0xa,%eax
f01044f1:	e9 a3 00 00 00       	jmp    f0104599 <vprintfmt+0x3a7>
		return va_arg(*ap, unsigned long long);
f01044f6:	8b 45 14             	mov    0x14(%ebp),%eax
f01044f9:	8b 10                	mov    (%eax),%edx
f01044fb:	8b 48 04             	mov    0x4(%eax),%ecx
f01044fe:	8d 40 08             	lea    0x8(%eax),%eax
f0104501:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0104504:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104509:	e9 8b 00 00 00       	jmp    f0104599 <vprintfmt+0x3a7>
		return va_arg(*ap, unsigned int);
f010450e:	8b 45 14             	mov    0x14(%ebp),%eax
f0104511:	8b 10                	mov    (%eax),%edx
f0104513:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104518:	8d 40 04             	lea    0x4(%eax),%eax
f010451b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f010451e:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104523:	eb 74                	jmp    f0104599 <vprintfmt+0x3a7>
	if (lflag >= 2)
f0104525:	83 f9 01             	cmp    $0x1,%ecx
f0104528:	7f 1b                	jg     f0104545 <vprintfmt+0x353>
	else if (lflag)
f010452a:	85 c9                	test   %ecx,%ecx
f010452c:	74 2c                	je     f010455a <vprintfmt+0x368>
		return va_arg(*ap, unsigned long);
f010452e:	8b 45 14             	mov    0x14(%ebp),%eax
f0104531:	8b 10                	mov    (%eax),%edx
f0104533:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104538:	8d 40 04             	lea    0x4(%eax),%eax
f010453b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f010453e:	b8 08 00 00 00       	mov    $0x8,%eax
f0104543:	eb 54                	jmp    f0104599 <vprintfmt+0x3a7>
		return va_arg(*ap, unsigned long long);
f0104545:	8b 45 14             	mov    0x14(%ebp),%eax
f0104548:	8b 10                	mov    (%eax),%edx
f010454a:	8b 48 04             	mov    0x4(%eax),%ecx
f010454d:	8d 40 08             	lea    0x8(%eax),%eax
f0104550:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0104553:	b8 08 00 00 00       	mov    $0x8,%eax
f0104558:	eb 3f                	jmp    f0104599 <vprintfmt+0x3a7>
		return va_arg(*ap, unsigned int);
f010455a:	8b 45 14             	mov    0x14(%ebp),%eax
f010455d:	8b 10                	mov    (%eax),%edx
f010455f:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104564:	8d 40 04             	lea    0x4(%eax),%eax
f0104567:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f010456a:	b8 08 00 00 00       	mov    $0x8,%eax
f010456f:	eb 28                	jmp    f0104599 <vprintfmt+0x3a7>
			putch('0', putdat);
f0104571:	83 ec 08             	sub    $0x8,%esp
f0104574:	53                   	push   %ebx
f0104575:	6a 30                	push   $0x30
f0104577:	ff d6                	call   *%esi
			putch('x', putdat);
f0104579:	83 c4 08             	add    $0x8,%esp
f010457c:	53                   	push   %ebx
f010457d:	6a 78                	push   $0x78
f010457f:	ff d6                	call   *%esi
			num = (unsigned long long)
f0104581:	8b 45 14             	mov    0x14(%ebp),%eax
f0104584:	8b 10                	mov    (%eax),%edx
f0104586:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f010458b:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f010458e:	8d 40 04             	lea    0x4(%eax),%eax
f0104591:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0104594:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
f0104599:	83 ec 0c             	sub    $0xc,%esp
f010459c:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
f01045a0:	57                   	push   %edi
f01045a1:	ff 75 e0             	pushl  -0x20(%ebp)
f01045a4:	50                   	push   %eax
f01045a5:	51                   	push   %ecx
f01045a6:	52                   	push   %edx
f01045a7:	89 da                	mov    %ebx,%edx
f01045a9:	89 f0                	mov    %esi,%eax
f01045ab:	e8 5a fb ff ff       	call   f010410a <printnum>
			break;
f01045b0:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
f01045b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01045b6:	e9 55 fc ff ff       	jmp    f0104210 <vprintfmt+0x1e>
	if (lflag >= 2)
f01045bb:	83 f9 01             	cmp    $0x1,%ecx
f01045be:	7f 1b                	jg     f01045db <vprintfmt+0x3e9>
	else if (lflag)
f01045c0:	85 c9                	test   %ecx,%ecx
f01045c2:	74 2c                	je     f01045f0 <vprintfmt+0x3fe>
		return va_arg(*ap, unsigned long);
f01045c4:	8b 45 14             	mov    0x14(%ebp),%eax
f01045c7:	8b 10                	mov    (%eax),%edx
f01045c9:	b9 00 00 00 00       	mov    $0x0,%ecx
f01045ce:	8d 40 04             	lea    0x4(%eax),%eax
f01045d1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01045d4:	b8 10 00 00 00       	mov    $0x10,%eax
f01045d9:	eb be                	jmp    f0104599 <vprintfmt+0x3a7>
		return va_arg(*ap, unsigned long long);
f01045db:	8b 45 14             	mov    0x14(%ebp),%eax
f01045de:	8b 10                	mov    (%eax),%edx
f01045e0:	8b 48 04             	mov    0x4(%eax),%ecx
f01045e3:	8d 40 08             	lea    0x8(%eax),%eax
f01045e6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01045e9:	b8 10 00 00 00       	mov    $0x10,%eax
f01045ee:	eb a9                	jmp    f0104599 <vprintfmt+0x3a7>
		return va_arg(*ap, unsigned int);
f01045f0:	8b 45 14             	mov    0x14(%ebp),%eax
f01045f3:	8b 10                	mov    (%eax),%edx
f01045f5:	b9 00 00 00 00       	mov    $0x0,%ecx
f01045fa:	8d 40 04             	lea    0x4(%eax),%eax
f01045fd:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0104600:	b8 10 00 00 00       	mov    $0x10,%eax
f0104605:	eb 92                	jmp    f0104599 <vprintfmt+0x3a7>
			putch(ch, putdat);
f0104607:	83 ec 08             	sub    $0x8,%esp
f010460a:	53                   	push   %ebx
f010460b:	6a 25                	push   $0x25
f010460d:	ff d6                	call   *%esi
			break;
f010460f:	83 c4 10             	add    $0x10,%esp
f0104612:	eb 9f                	jmp    f01045b3 <vprintfmt+0x3c1>
			putch('%', putdat);
f0104614:	83 ec 08             	sub    $0x8,%esp
f0104617:	53                   	push   %ebx
f0104618:	6a 25                	push   $0x25
f010461a:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f010461c:	83 c4 10             	add    $0x10,%esp
f010461f:	89 f8                	mov    %edi,%eax
f0104621:	eb 03                	jmp    f0104626 <vprintfmt+0x434>
f0104623:	83 e8 01             	sub    $0x1,%eax
f0104626:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f010462a:	75 f7                	jne    f0104623 <vprintfmt+0x431>
f010462c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010462f:	eb 82                	jmp    f01045b3 <vprintfmt+0x3c1>

f0104631 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0104631:	55                   	push   %ebp
f0104632:	89 e5                	mov    %esp,%ebp
f0104634:	83 ec 18             	sub    $0x18,%esp
f0104637:	8b 45 08             	mov    0x8(%ebp),%eax
f010463a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f010463d:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104640:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0104644:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0104647:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010464e:	85 c0                	test   %eax,%eax
f0104650:	74 26                	je     f0104678 <vsnprintf+0x47>
f0104652:	85 d2                	test   %edx,%edx
f0104654:	7e 22                	jle    f0104678 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0104656:	ff 75 14             	pushl  0x14(%ebp)
f0104659:	ff 75 10             	pushl  0x10(%ebp)
f010465c:	8d 45 ec             	lea    -0x14(%ebp),%eax
f010465f:	50                   	push   %eax
f0104660:	68 b8 41 10 f0       	push   $0xf01041b8
f0104665:	e8 88 fb ff ff       	call   f01041f2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f010466a:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010466d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0104670:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104673:	83 c4 10             	add    $0x10,%esp
}
f0104676:	c9                   	leave  
f0104677:	c3                   	ret    
		return -E_INVAL;
f0104678:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010467d:	eb f7                	jmp    f0104676 <vsnprintf+0x45>

f010467f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f010467f:	55                   	push   %ebp
f0104680:	89 e5                	mov    %esp,%ebp
f0104682:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0104685:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0104688:	50                   	push   %eax
f0104689:	ff 75 10             	pushl  0x10(%ebp)
f010468c:	ff 75 0c             	pushl  0xc(%ebp)
f010468f:	ff 75 08             	pushl  0x8(%ebp)
f0104692:	e8 9a ff ff ff       	call   f0104631 <vsnprintf>
	va_end(ap);

	return rc;
}
f0104697:	c9                   	leave  
f0104698:	c3                   	ret    

f0104699 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0104699:	55                   	push   %ebp
f010469a:	89 e5                	mov    %esp,%ebp
f010469c:	57                   	push   %edi
f010469d:	56                   	push   %esi
f010469e:	53                   	push   %ebx
f010469f:	83 ec 0c             	sub    $0xc,%esp
f01046a2:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01046a5:	85 c0                	test   %eax,%eax
f01046a7:	74 11                	je     f01046ba <readline+0x21>
		cprintf("%s", prompt);
f01046a9:	83 ec 08             	sub    $0x8,%esp
f01046ac:	50                   	push   %eax
f01046ad:	68 fb 64 10 f0       	push   $0xf01064fb
f01046b2:	e8 4e f1 ff ff       	call   f0103805 <cprintf>
f01046b7:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f01046ba:	83 ec 0c             	sub    $0xc,%esp
f01046bd:	6a 00                	push   $0x0
f01046bf:	e8 f3 c0 ff ff       	call   f01007b7 <iscons>
f01046c4:	89 c7                	mov    %eax,%edi
f01046c6:	83 c4 10             	add    $0x10,%esp
	i = 0;
f01046c9:	be 00 00 00 00       	mov    $0x0,%esi
f01046ce:	eb 4b                	jmp    f010471b <readline+0x82>
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
f01046d0:	83 ec 08             	sub    $0x8,%esp
f01046d3:	50                   	push   %eax
f01046d4:	68 64 6f 10 f0       	push   $0xf0106f64
f01046d9:	e8 27 f1 ff ff       	call   f0103805 <cprintf>
			return NULL;
f01046de:	83 c4 10             	add    $0x10,%esp
f01046e1:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f01046e6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01046e9:	5b                   	pop    %ebx
f01046ea:	5e                   	pop    %esi
f01046eb:	5f                   	pop    %edi
f01046ec:	5d                   	pop    %ebp
f01046ed:	c3                   	ret    
			if (echoing)
f01046ee:	85 ff                	test   %edi,%edi
f01046f0:	75 05                	jne    f01046f7 <readline+0x5e>
			i--;
f01046f2:	83 ee 01             	sub    $0x1,%esi
f01046f5:	eb 24                	jmp    f010471b <readline+0x82>
				cputchar('\b');
f01046f7:	83 ec 0c             	sub    $0xc,%esp
f01046fa:	6a 08                	push   $0x8
f01046fc:	e8 95 c0 ff ff       	call   f0100796 <cputchar>
f0104701:	83 c4 10             	add    $0x10,%esp
f0104704:	eb ec                	jmp    f01046f2 <readline+0x59>
				cputchar(c);
f0104706:	83 ec 0c             	sub    $0xc,%esp
f0104709:	53                   	push   %ebx
f010470a:	e8 87 c0 ff ff       	call   f0100796 <cputchar>
f010470f:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0104712:	88 9e 00 1b 23 f0    	mov    %bl,-0xfdce500(%esi)
f0104718:	8d 76 01             	lea    0x1(%esi),%esi
		c = getchar();
f010471b:	e8 86 c0 ff ff       	call   f01007a6 <getchar>
f0104720:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0104722:	85 c0                	test   %eax,%eax
f0104724:	78 aa                	js     f01046d0 <readline+0x37>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0104726:	83 f8 08             	cmp    $0x8,%eax
f0104729:	0f 94 c2             	sete   %dl
f010472c:	83 f8 7f             	cmp    $0x7f,%eax
f010472f:	0f 94 c0             	sete   %al
f0104732:	08 c2                	or     %al,%dl
f0104734:	74 04                	je     f010473a <readline+0xa1>
f0104736:	85 f6                	test   %esi,%esi
f0104738:	7f b4                	jg     f01046ee <readline+0x55>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010473a:	83 fb 1f             	cmp    $0x1f,%ebx
f010473d:	7e 0e                	jle    f010474d <readline+0xb4>
f010473f:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0104745:	7f 06                	jg     f010474d <readline+0xb4>
			if (echoing)
f0104747:	85 ff                	test   %edi,%edi
f0104749:	74 c7                	je     f0104712 <readline+0x79>
f010474b:	eb b9                	jmp    f0104706 <readline+0x6d>
		} else if (c == '\n' || c == '\r') {
f010474d:	83 fb 0a             	cmp    $0xa,%ebx
f0104750:	74 05                	je     f0104757 <readline+0xbe>
f0104752:	83 fb 0d             	cmp    $0xd,%ebx
f0104755:	75 c4                	jne    f010471b <readline+0x82>
			if (echoing)
f0104757:	85 ff                	test   %edi,%edi
f0104759:	75 11                	jne    f010476c <readline+0xd3>
			buf[i] = 0;
f010475b:	c6 86 00 1b 23 f0 00 	movb   $0x0,-0xfdce500(%esi)
			return buf;
f0104762:	b8 00 1b 23 f0       	mov    $0xf0231b00,%eax
f0104767:	e9 7a ff ff ff       	jmp    f01046e6 <readline+0x4d>
				cputchar('\n');
f010476c:	83 ec 0c             	sub    $0xc,%esp
f010476f:	6a 0a                	push   $0xa
f0104771:	e8 20 c0 ff ff       	call   f0100796 <cputchar>
f0104776:	83 c4 10             	add    $0x10,%esp
f0104779:	eb e0                	jmp    f010475b <readline+0xc2>

f010477b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f010477b:	55                   	push   %ebp
f010477c:	89 e5                	mov    %esp,%ebp
f010477e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0104781:	b8 00 00 00 00       	mov    $0x0,%eax
f0104786:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f010478a:	74 05                	je     f0104791 <strlen+0x16>
		n++;
f010478c:	83 c0 01             	add    $0x1,%eax
f010478f:	eb f5                	jmp    f0104786 <strlen+0xb>
	return n;
}
f0104791:	5d                   	pop    %ebp
f0104792:	c3                   	ret    

f0104793 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0104793:	55                   	push   %ebp
f0104794:	89 e5                	mov    %esp,%ebp
f0104796:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104799:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010479c:	ba 00 00 00 00       	mov    $0x0,%edx
f01047a1:	39 c2                	cmp    %eax,%edx
f01047a3:	74 0d                	je     f01047b2 <strnlen+0x1f>
f01047a5:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f01047a9:	74 05                	je     f01047b0 <strnlen+0x1d>
		n++;
f01047ab:	83 c2 01             	add    $0x1,%edx
f01047ae:	eb f1                	jmp    f01047a1 <strnlen+0xe>
f01047b0:	89 d0                	mov    %edx,%eax
	return n;
}
f01047b2:	5d                   	pop    %ebp
f01047b3:	c3                   	ret    

f01047b4 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01047b4:	55                   	push   %ebp
f01047b5:	89 e5                	mov    %esp,%ebp
f01047b7:	53                   	push   %ebx
f01047b8:	8b 45 08             	mov    0x8(%ebp),%eax
f01047bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01047be:	ba 00 00 00 00       	mov    $0x0,%edx
f01047c3:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f01047c7:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f01047ca:	83 c2 01             	add    $0x1,%edx
f01047cd:	84 c9                	test   %cl,%cl
f01047cf:	75 f2                	jne    f01047c3 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f01047d1:	5b                   	pop    %ebx
f01047d2:	5d                   	pop    %ebp
f01047d3:	c3                   	ret    

f01047d4 <strcat>:

char *
strcat(char *dst, const char *src)
{
f01047d4:	55                   	push   %ebp
f01047d5:	89 e5                	mov    %esp,%ebp
f01047d7:	53                   	push   %ebx
f01047d8:	83 ec 10             	sub    $0x10,%esp
f01047db:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01047de:	53                   	push   %ebx
f01047df:	e8 97 ff ff ff       	call   f010477b <strlen>
f01047e4:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
f01047e7:	ff 75 0c             	pushl  0xc(%ebp)
f01047ea:	01 d8                	add    %ebx,%eax
f01047ec:	50                   	push   %eax
f01047ed:	e8 c2 ff ff ff       	call   f01047b4 <strcpy>
	return dst;
}
f01047f2:	89 d8                	mov    %ebx,%eax
f01047f4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01047f7:	c9                   	leave  
f01047f8:	c3                   	ret    

f01047f9 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01047f9:	55                   	push   %ebp
f01047fa:	89 e5                	mov    %esp,%ebp
f01047fc:	56                   	push   %esi
f01047fd:	53                   	push   %ebx
f01047fe:	8b 45 08             	mov    0x8(%ebp),%eax
f0104801:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104804:	89 c6                	mov    %eax,%esi
f0104806:	03 75 10             	add    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0104809:	89 c2                	mov    %eax,%edx
f010480b:	39 f2                	cmp    %esi,%edx
f010480d:	74 11                	je     f0104820 <strncpy+0x27>
		*dst++ = *src;
f010480f:	83 c2 01             	add    $0x1,%edx
f0104812:	0f b6 19             	movzbl (%ecx),%ebx
f0104815:	88 5a ff             	mov    %bl,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0104818:	80 fb 01             	cmp    $0x1,%bl
f010481b:	83 d9 ff             	sbb    $0xffffffff,%ecx
f010481e:	eb eb                	jmp    f010480b <strncpy+0x12>
	}
	return ret;
}
f0104820:	5b                   	pop    %ebx
f0104821:	5e                   	pop    %esi
f0104822:	5d                   	pop    %ebp
f0104823:	c3                   	ret    

f0104824 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0104824:	55                   	push   %ebp
f0104825:	89 e5                	mov    %esp,%ebp
f0104827:	56                   	push   %esi
f0104828:	53                   	push   %ebx
f0104829:	8b 75 08             	mov    0x8(%ebp),%esi
f010482c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010482f:	8b 55 10             	mov    0x10(%ebp),%edx
f0104832:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0104834:	85 d2                	test   %edx,%edx
f0104836:	74 21                	je     f0104859 <strlcpy+0x35>
f0104838:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f010483c:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
f010483e:	39 c2                	cmp    %eax,%edx
f0104840:	74 14                	je     f0104856 <strlcpy+0x32>
f0104842:	0f b6 19             	movzbl (%ecx),%ebx
f0104845:	84 db                	test   %bl,%bl
f0104847:	74 0b                	je     f0104854 <strlcpy+0x30>
			*dst++ = *src++;
f0104849:	83 c1 01             	add    $0x1,%ecx
f010484c:	83 c2 01             	add    $0x1,%edx
f010484f:	88 5a ff             	mov    %bl,-0x1(%edx)
f0104852:	eb ea                	jmp    f010483e <strlcpy+0x1a>
f0104854:	89 d0                	mov    %edx,%eax
		*dst = '\0';
f0104856:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0104859:	29 f0                	sub    %esi,%eax
}
f010485b:	5b                   	pop    %ebx
f010485c:	5e                   	pop    %esi
f010485d:	5d                   	pop    %ebp
f010485e:	c3                   	ret    

f010485f <strcmp>:

int
strcmp(const char *p, const char *q)
{
f010485f:	55                   	push   %ebp
f0104860:	89 e5                	mov    %esp,%ebp
f0104862:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104865:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0104868:	0f b6 01             	movzbl (%ecx),%eax
f010486b:	84 c0                	test   %al,%al
f010486d:	74 0c                	je     f010487b <strcmp+0x1c>
f010486f:	3a 02                	cmp    (%edx),%al
f0104871:	75 08                	jne    f010487b <strcmp+0x1c>
		p++, q++;
f0104873:	83 c1 01             	add    $0x1,%ecx
f0104876:	83 c2 01             	add    $0x1,%edx
f0104879:	eb ed                	jmp    f0104868 <strcmp+0x9>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f010487b:	0f b6 c0             	movzbl %al,%eax
f010487e:	0f b6 12             	movzbl (%edx),%edx
f0104881:	29 d0                	sub    %edx,%eax
}
f0104883:	5d                   	pop    %ebp
f0104884:	c3                   	ret    

f0104885 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0104885:	55                   	push   %ebp
f0104886:	89 e5                	mov    %esp,%ebp
f0104888:	53                   	push   %ebx
f0104889:	8b 45 08             	mov    0x8(%ebp),%eax
f010488c:	8b 55 0c             	mov    0xc(%ebp),%edx
f010488f:	89 c3                	mov    %eax,%ebx
f0104891:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0104894:	eb 06                	jmp    f010489c <strncmp+0x17>
		n--, p++, q++;
f0104896:	83 c0 01             	add    $0x1,%eax
f0104899:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f010489c:	39 d8                	cmp    %ebx,%eax
f010489e:	74 16                	je     f01048b6 <strncmp+0x31>
f01048a0:	0f b6 08             	movzbl (%eax),%ecx
f01048a3:	84 c9                	test   %cl,%cl
f01048a5:	74 04                	je     f01048ab <strncmp+0x26>
f01048a7:	3a 0a                	cmp    (%edx),%cl
f01048a9:	74 eb                	je     f0104896 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01048ab:	0f b6 00             	movzbl (%eax),%eax
f01048ae:	0f b6 12             	movzbl (%edx),%edx
f01048b1:	29 d0                	sub    %edx,%eax
}
f01048b3:	5b                   	pop    %ebx
f01048b4:	5d                   	pop    %ebp
f01048b5:	c3                   	ret    
		return 0;
f01048b6:	b8 00 00 00 00       	mov    $0x0,%eax
f01048bb:	eb f6                	jmp    f01048b3 <strncmp+0x2e>

f01048bd <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01048bd:	55                   	push   %ebp
f01048be:	89 e5                	mov    %esp,%ebp
f01048c0:	8b 45 08             	mov    0x8(%ebp),%eax
f01048c3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01048c7:	0f b6 10             	movzbl (%eax),%edx
f01048ca:	84 d2                	test   %dl,%dl
f01048cc:	74 09                	je     f01048d7 <strchr+0x1a>
		if (*s == c)
f01048ce:	38 ca                	cmp    %cl,%dl
f01048d0:	74 0a                	je     f01048dc <strchr+0x1f>
	for (; *s; s++)
f01048d2:	83 c0 01             	add    $0x1,%eax
f01048d5:	eb f0                	jmp    f01048c7 <strchr+0xa>
			return (char *) s;
	return 0;
f01048d7:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01048dc:	5d                   	pop    %ebp
f01048dd:	c3                   	ret    

f01048de <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01048de:	55                   	push   %ebp
f01048df:	89 e5                	mov    %esp,%ebp
f01048e1:	8b 45 08             	mov    0x8(%ebp),%eax
f01048e4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01048e8:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f01048eb:	38 ca                	cmp    %cl,%dl
f01048ed:	74 09                	je     f01048f8 <strfind+0x1a>
f01048ef:	84 d2                	test   %dl,%dl
f01048f1:	74 05                	je     f01048f8 <strfind+0x1a>
	for (; *s; s++)
f01048f3:	83 c0 01             	add    $0x1,%eax
f01048f6:	eb f0                	jmp    f01048e8 <strfind+0xa>
			break;
	return (char *) s;
}
f01048f8:	5d                   	pop    %ebp
f01048f9:	c3                   	ret    

f01048fa <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01048fa:	55                   	push   %ebp
f01048fb:	89 e5                	mov    %esp,%ebp
f01048fd:	57                   	push   %edi
f01048fe:	56                   	push   %esi
f01048ff:	53                   	push   %ebx
f0104900:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104903:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0104906:	85 c9                	test   %ecx,%ecx
f0104908:	74 31                	je     f010493b <memset+0x41>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f010490a:	89 f8                	mov    %edi,%eax
f010490c:	09 c8                	or     %ecx,%eax
f010490e:	a8 03                	test   $0x3,%al
f0104910:	75 23                	jne    f0104935 <memset+0x3b>
		c &= 0xFF;
f0104912:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0104916:	89 d3                	mov    %edx,%ebx
f0104918:	c1 e3 08             	shl    $0x8,%ebx
f010491b:	89 d0                	mov    %edx,%eax
f010491d:	c1 e0 18             	shl    $0x18,%eax
f0104920:	89 d6                	mov    %edx,%esi
f0104922:	c1 e6 10             	shl    $0x10,%esi
f0104925:	09 f0                	or     %esi,%eax
f0104927:	09 c2                	or     %eax,%edx
f0104929:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f010492b:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f010492e:	89 d0                	mov    %edx,%eax
f0104930:	fc                   	cld    
f0104931:	f3 ab                	rep stos %eax,%es:(%edi)
f0104933:	eb 06                	jmp    f010493b <memset+0x41>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0104935:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104938:	fc                   	cld    
f0104939:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010493b:	89 f8                	mov    %edi,%eax
f010493d:	5b                   	pop    %ebx
f010493e:	5e                   	pop    %esi
f010493f:	5f                   	pop    %edi
f0104940:	5d                   	pop    %ebp
f0104941:	c3                   	ret    

f0104942 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0104942:	55                   	push   %ebp
f0104943:	89 e5                	mov    %esp,%ebp
f0104945:	57                   	push   %edi
f0104946:	56                   	push   %esi
f0104947:	8b 45 08             	mov    0x8(%ebp),%eax
f010494a:	8b 75 0c             	mov    0xc(%ebp),%esi
f010494d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0104950:	39 c6                	cmp    %eax,%esi
f0104952:	73 32                	jae    f0104986 <memmove+0x44>
f0104954:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0104957:	39 c2                	cmp    %eax,%edx
f0104959:	76 2b                	jbe    f0104986 <memmove+0x44>
		s += n;
		d += n;
f010495b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010495e:	89 fe                	mov    %edi,%esi
f0104960:	09 ce                	or     %ecx,%esi
f0104962:	09 d6                	or     %edx,%esi
f0104964:	f7 c6 03 00 00 00    	test   $0x3,%esi
f010496a:	75 0e                	jne    f010497a <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f010496c:	83 ef 04             	sub    $0x4,%edi
f010496f:	8d 72 fc             	lea    -0x4(%edx),%esi
f0104972:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f0104975:	fd                   	std    
f0104976:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104978:	eb 09                	jmp    f0104983 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f010497a:	83 ef 01             	sub    $0x1,%edi
f010497d:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f0104980:	fd                   	std    
f0104981:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0104983:	fc                   	cld    
f0104984:	eb 1a                	jmp    f01049a0 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104986:	89 c2                	mov    %eax,%edx
f0104988:	09 ca                	or     %ecx,%edx
f010498a:	09 f2                	or     %esi,%edx
f010498c:	f6 c2 03             	test   $0x3,%dl
f010498f:	75 0a                	jne    f010499b <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0104991:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f0104994:	89 c7                	mov    %eax,%edi
f0104996:	fc                   	cld    
f0104997:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104999:	eb 05                	jmp    f01049a0 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
f010499b:	89 c7                	mov    %eax,%edi
f010499d:	fc                   	cld    
f010499e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01049a0:	5e                   	pop    %esi
f01049a1:	5f                   	pop    %edi
f01049a2:	5d                   	pop    %ebp
f01049a3:	c3                   	ret    

f01049a4 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01049a4:	55                   	push   %ebp
f01049a5:	89 e5                	mov    %esp,%ebp
f01049a7:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f01049aa:	ff 75 10             	pushl  0x10(%ebp)
f01049ad:	ff 75 0c             	pushl  0xc(%ebp)
f01049b0:	ff 75 08             	pushl  0x8(%ebp)
f01049b3:	e8 8a ff ff ff       	call   f0104942 <memmove>
}
f01049b8:	c9                   	leave  
f01049b9:	c3                   	ret    

f01049ba <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01049ba:	55                   	push   %ebp
f01049bb:	89 e5                	mov    %esp,%ebp
f01049bd:	56                   	push   %esi
f01049be:	53                   	push   %ebx
f01049bf:	8b 45 08             	mov    0x8(%ebp),%eax
f01049c2:	8b 55 0c             	mov    0xc(%ebp),%edx
f01049c5:	89 c6                	mov    %eax,%esi
f01049c7:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01049ca:	39 f0                	cmp    %esi,%eax
f01049cc:	74 1c                	je     f01049ea <memcmp+0x30>
		if (*s1 != *s2)
f01049ce:	0f b6 08             	movzbl (%eax),%ecx
f01049d1:	0f b6 1a             	movzbl (%edx),%ebx
f01049d4:	38 d9                	cmp    %bl,%cl
f01049d6:	75 08                	jne    f01049e0 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f01049d8:	83 c0 01             	add    $0x1,%eax
f01049db:	83 c2 01             	add    $0x1,%edx
f01049de:	eb ea                	jmp    f01049ca <memcmp+0x10>
			return (int) *s1 - (int) *s2;
f01049e0:	0f b6 c1             	movzbl %cl,%eax
f01049e3:	0f b6 db             	movzbl %bl,%ebx
f01049e6:	29 d8                	sub    %ebx,%eax
f01049e8:	eb 05                	jmp    f01049ef <memcmp+0x35>
	}

	return 0;
f01049ea:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01049ef:	5b                   	pop    %ebx
f01049f0:	5e                   	pop    %esi
f01049f1:	5d                   	pop    %ebp
f01049f2:	c3                   	ret    

f01049f3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01049f3:	55                   	push   %ebp
f01049f4:	89 e5                	mov    %esp,%ebp
f01049f6:	8b 45 08             	mov    0x8(%ebp),%eax
f01049f9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f01049fc:	89 c2                	mov    %eax,%edx
f01049fe:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0104a01:	39 d0                	cmp    %edx,%eax
f0104a03:	73 09                	jae    f0104a0e <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
f0104a05:	38 08                	cmp    %cl,(%eax)
f0104a07:	74 05                	je     f0104a0e <memfind+0x1b>
	for (; s < ends; s++)
f0104a09:	83 c0 01             	add    $0x1,%eax
f0104a0c:	eb f3                	jmp    f0104a01 <memfind+0xe>
			break;
	return (void *) s;
}
f0104a0e:	5d                   	pop    %ebp
f0104a0f:	c3                   	ret    

f0104a10 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0104a10:	55                   	push   %ebp
f0104a11:	89 e5                	mov    %esp,%ebp
f0104a13:	57                   	push   %edi
f0104a14:	56                   	push   %esi
f0104a15:	53                   	push   %ebx
f0104a16:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104a19:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0104a1c:	eb 03                	jmp    f0104a21 <strtol+0x11>
		s++;
f0104a1e:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
f0104a21:	0f b6 01             	movzbl (%ecx),%eax
f0104a24:	3c 20                	cmp    $0x20,%al
f0104a26:	74 f6                	je     f0104a1e <strtol+0xe>
f0104a28:	3c 09                	cmp    $0x9,%al
f0104a2a:	74 f2                	je     f0104a1e <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f0104a2c:	3c 2b                	cmp    $0x2b,%al
f0104a2e:	74 2a                	je     f0104a5a <strtol+0x4a>
	int neg = 0;
f0104a30:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f0104a35:	3c 2d                	cmp    $0x2d,%al
f0104a37:	74 2b                	je     f0104a64 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0104a39:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0104a3f:	75 0f                	jne    f0104a50 <strtol+0x40>
f0104a41:	80 39 30             	cmpb   $0x30,(%ecx)
f0104a44:	74 28                	je     f0104a6e <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0104a46:	85 db                	test   %ebx,%ebx
f0104a48:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104a4d:	0f 44 d8             	cmove  %eax,%ebx
f0104a50:	b8 00 00 00 00       	mov    $0x0,%eax
f0104a55:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0104a58:	eb 50                	jmp    f0104aaa <strtol+0x9a>
		s++;
f0104a5a:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
f0104a5d:	bf 00 00 00 00       	mov    $0x0,%edi
f0104a62:	eb d5                	jmp    f0104a39 <strtol+0x29>
		s++, neg = 1;
f0104a64:	83 c1 01             	add    $0x1,%ecx
f0104a67:	bf 01 00 00 00       	mov    $0x1,%edi
f0104a6c:	eb cb                	jmp    f0104a39 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0104a6e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0104a72:	74 0e                	je     f0104a82 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
f0104a74:	85 db                	test   %ebx,%ebx
f0104a76:	75 d8                	jne    f0104a50 <strtol+0x40>
		s++, base = 8;
f0104a78:	83 c1 01             	add    $0x1,%ecx
f0104a7b:	bb 08 00 00 00       	mov    $0x8,%ebx
f0104a80:	eb ce                	jmp    f0104a50 <strtol+0x40>
		s += 2, base = 16;
f0104a82:	83 c1 02             	add    $0x2,%ecx
f0104a85:	bb 10 00 00 00       	mov    $0x10,%ebx
f0104a8a:	eb c4                	jmp    f0104a50 <strtol+0x40>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
f0104a8c:	8d 72 9f             	lea    -0x61(%edx),%esi
f0104a8f:	89 f3                	mov    %esi,%ebx
f0104a91:	80 fb 19             	cmp    $0x19,%bl
f0104a94:	77 29                	ja     f0104abf <strtol+0xaf>
			dig = *s - 'a' + 10;
f0104a96:	0f be d2             	movsbl %dl,%edx
f0104a99:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0104a9c:	3b 55 10             	cmp    0x10(%ebp),%edx
f0104a9f:	7d 30                	jge    f0104ad1 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
f0104aa1:	83 c1 01             	add    $0x1,%ecx
f0104aa4:	0f af 45 10          	imul   0x10(%ebp),%eax
f0104aa8:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f0104aaa:	0f b6 11             	movzbl (%ecx),%edx
f0104aad:	8d 72 d0             	lea    -0x30(%edx),%esi
f0104ab0:	89 f3                	mov    %esi,%ebx
f0104ab2:	80 fb 09             	cmp    $0x9,%bl
f0104ab5:	77 d5                	ja     f0104a8c <strtol+0x7c>
			dig = *s - '0';
f0104ab7:	0f be d2             	movsbl %dl,%edx
f0104aba:	83 ea 30             	sub    $0x30,%edx
f0104abd:	eb dd                	jmp    f0104a9c <strtol+0x8c>
		else if (*s >= 'A' && *s <= 'Z')
f0104abf:	8d 72 bf             	lea    -0x41(%edx),%esi
f0104ac2:	89 f3                	mov    %esi,%ebx
f0104ac4:	80 fb 19             	cmp    $0x19,%bl
f0104ac7:	77 08                	ja     f0104ad1 <strtol+0xc1>
			dig = *s - 'A' + 10;
f0104ac9:	0f be d2             	movsbl %dl,%edx
f0104acc:	83 ea 37             	sub    $0x37,%edx
f0104acf:	eb cb                	jmp    f0104a9c <strtol+0x8c>
		// we don't properly detect overflow!
	}

	if (endptr)
f0104ad1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0104ad5:	74 05                	je     f0104adc <strtol+0xcc>
		*endptr = (char *) s;
f0104ad7:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104ada:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f0104adc:	89 c2                	mov    %eax,%edx
f0104ade:	f7 da                	neg    %edx
f0104ae0:	85 ff                	test   %edi,%edi
f0104ae2:	0f 45 c2             	cmovne %edx,%eax
}
f0104ae5:	5b                   	pop    %ebx
f0104ae6:	5e                   	pop    %esi
f0104ae7:	5f                   	pop    %edi
f0104ae8:	5d                   	pop    %ebp
f0104ae9:	c3                   	ret    
f0104aea:	66 90                	xchg   %ax,%ax

f0104aec <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0104aec:	fa                   	cli    

	xorw    %ax, %ax
f0104aed:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f0104aef:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0104af1:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0104af3:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0104af5:	0f 01 16             	lgdtl  (%esi)
f0104af8:	74 70                	je     f0104b6a <mpsearch1+0x3>
	movl    %cr0, %eax
f0104afa:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0104afd:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0104b01:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0104b04:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0104b0a:	08 00                	or     %al,(%eax)

f0104b0c <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0104b0c:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0104b10:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0104b12:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0104b14:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0104b16:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0104b1a:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0104b1c:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0104b1e:	b8 00 f0 11 00       	mov    $0x11f000,%eax
	movl    %eax, %cr3
f0104b23:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0104b26:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0104b29:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0104b2e:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0104b31:	8b 25 04 1f 23 f0    	mov    0xf0231f04,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0104b37:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0104b3c:	b8 f5 01 10 f0       	mov    $0xf01001f5,%eax
	call    *%eax
f0104b41:	ff d0                	call   *%eax

f0104b43 <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0104b43:	eb fe                	jmp    f0104b43 <spin>
f0104b45:	8d 76 00             	lea    0x0(%esi),%esi

f0104b48 <gdt>:
	...
f0104b50:	ff                   	(bad)  
f0104b51:	ff 00                	incl   (%eax)
f0104b53:	00 00                	add    %al,(%eax)
f0104b55:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0104b5c:	00                   	.byte 0x0
f0104b5d:	92                   	xchg   %eax,%edx
f0104b5e:	cf                   	iret   
	...

f0104b60 <gdtdesc>:
f0104b60:	17                   	pop    %ss
f0104b61:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0104b66 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0104b66:	90                   	nop

f0104b67 <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0104b67:	55                   	push   %ebp
f0104b68:	89 e5                	mov    %esp,%ebp
f0104b6a:	57                   	push   %edi
f0104b6b:	56                   	push   %esi
f0104b6c:	53                   	push   %ebx
f0104b6d:	83 ec 0c             	sub    $0xc,%esp
	if (PGNUM(pa) >= npages)
f0104b70:	8b 0d 08 1f 23 f0    	mov    0xf0231f08,%ecx
f0104b76:	89 c3                	mov    %eax,%ebx
f0104b78:	c1 eb 0c             	shr    $0xc,%ebx
f0104b7b:	39 cb                	cmp    %ecx,%ebx
f0104b7d:	73 1a                	jae    f0104b99 <mpsearch1+0x32>
	return (void *)(pa + KERNBASE);
f0104b7f:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0104b85:	8d 3c 02             	lea    (%edx,%eax,1),%edi
	if (PGNUM(pa) >= npages)
f0104b88:	89 f8                	mov    %edi,%eax
f0104b8a:	c1 e8 0c             	shr    $0xc,%eax
f0104b8d:	39 c8                	cmp    %ecx,%eax
f0104b8f:	73 1a                	jae    f0104bab <mpsearch1+0x44>
	return (void *)(pa + KERNBASE);
f0104b91:	81 ef 00 00 00 10    	sub    $0x10000000,%edi

	for (; mp < end; mp++)
f0104b97:	eb 27                	jmp    f0104bc0 <mpsearch1+0x59>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0104b99:	50                   	push   %eax
f0104b9a:	68 f4 55 10 f0       	push   $0xf01055f4
f0104b9f:	6a 57                	push   $0x57
f0104ba1:	68 01 71 10 f0       	push   $0xf0107101
f0104ba6:	e8 e9 b4 ff ff       	call   f0100094 <_panic>
f0104bab:	57                   	push   %edi
f0104bac:	68 f4 55 10 f0       	push   $0xf01055f4
f0104bb1:	6a 57                	push   $0x57
f0104bb3:	68 01 71 10 f0       	push   $0xf0107101
f0104bb8:	e8 d7 b4 ff ff       	call   f0100094 <_panic>
f0104bbd:	83 c3 10             	add    $0x10,%ebx
f0104bc0:	39 fb                	cmp    %edi,%ebx
f0104bc2:	73 30                	jae    f0104bf4 <mpsearch1+0x8d>
f0104bc4:	89 de                	mov    %ebx,%esi
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0104bc6:	83 ec 04             	sub    $0x4,%esp
f0104bc9:	6a 04                	push   $0x4
f0104bcb:	68 11 71 10 f0       	push   $0xf0107111
f0104bd0:	53                   	push   %ebx
f0104bd1:	e8 e4 fd ff ff       	call   f01049ba <memcmp>
f0104bd6:	83 c4 10             	add    $0x10,%esp
f0104bd9:	85 c0                	test   %eax,%eax
f0104bdb:	75 e0                	jne    f0104bbd <mpsearch1+0x56>
f0104bdd:	89 da                	mov    %ebx,%edx
	for (i = 0; i < len; i++)
f0104bdf:	83 c6 10             	add    $0x10,%esi
		sum += ((uint8_t *)addr)[i];
f0104be2:	0f b6 0a             	movzbl (%edx),%ecx
f0104be5:	01 c8                	add    %ecx,%eax
f0104be7:	83 c2 01             	add    $0x1,%edx
	for (i = 0; i < len; i++)
f0104bea:	39 f2                	cmp    %esi,%edx
f0104bec:	75 f4                	jne    f0104be2 <mpsearch1+0x7b>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0104bee:	84 c0                	test   %al,%al
f0104bf0:	75 cb                	jne    f0104bbd <mpsearch1+0x56>
f0104bf2:	eb 05                	jmp    f0104bf9 <mpsearch1+0x92>
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f0104bf4:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f0104bf9:	89 d8                	mov    %ebx,%eax
f0104bfb:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104bfe:	5b                   	pop    %ebx
f0104bff:	5e                   	pop    %esi
f0104c00:	5f                   	pop    %edi
f0104c01:	5d                   	pop    %ebp
f0104c02:	c3                   	ret    

f0104c03 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f0104c03:	55                   	push   %ebp
f0104c04:	89 e5                	mov    %esp,%ebp
f0104c06:	57                   	push   %edi
f0104c07:	56                   	push   %esi
f0104c08:	53                   	push   %ebx
f0104c09:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0104c0c:	c7 05 c0 23 23 f0 20 	movl   $0xf0232020,0xf02323c0
f0104c13:	20 23 f0 
	if (PGNUM(pa) >= npages)
f0104c16:	83 3d 08 1f 23 f0 00 	cmpl   $0x0,0xf0231f08
f0104c1d:	0f 84 a3 00 00 00    	je     f0104cc6 <mp_init+0xc3>
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0104c23:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0104c2a:	85 c0                	test   %eax,%eax
f0104c2c:	0f 84 aa 00 00 00    	je     f0104cdc <mp_init+0xd9>
		p <<= 4;	// Translate from segment to PA
f0104c32:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f0104c35:	ba 00 04 00 00       	mov    $0x400,%edx
f0104c3a:	e8 28 ff ff ff       	call   f0104b67 <mpsearch1>
f0104c3f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104c42:	85 c0                	test   %eax,%eax
f0104c44:	75 1a                	jne    f0104c60 <mp_init+0x5d>
	return mpsearch1(0xF0000, 0x10000);
f0104c46:	ba 00 00 01 00       	mov    $0x10000,%edx
f0104c4b:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0104c50:	e8 12 ff ff ff       	call   f0104b67 <mpsearch1>
f0104c55:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if ((mp = mpsearch()) == 0)
f0104c58:	85 c0                	test   %eax,%eax
f0104c5a:	0f 84 31 02 00 00    	je     f0104e91 <mp_init+0x28e>
	if (mp->physaddr == 0 || mp->type != 0) {
f0104c60:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104c63:	8b 58 04             	mov    0x4(%eax),%ebx
f0104c66:	85 db                	test   %ebx,%ebx
f0104c68:	0f 84 97 00 00 00    	je     f0104d05 <mp_init+0x102>
f0104c6e:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0104c72:	0f 85 8d 00 00 00    	jne    f0104d05 <mp_init+0x102>
f0104c78:	89 d8                	mov    %ebx,%eax
f0104c7a:	c1 e8 0c             	shr    $0xc,%eax
f0104c7d:	3b 05 08 1f 23 f0    	cmp    0xf0231f08,%eax
f0104c83:	0f 83 91 00 00 00    	jae    f0104d1a <mp_init+0x117>
	return (void *)(pa + KERNBASE);
f0104c89:	81 eb 00 00 00 10    	sub    $0x10000000,%ebx
f0104c8f:	89 de                	mov    %ebx,%esi
	if (memcmp(conf, "PCMP", 4) != 0) {
f0104c91:	83 ec 04             	sub    $0x4,%esp
f0104c94:	6a 04                	push   $0x4
f0104c96:	68 16 71 10 f0       	push   $0xf0107116
f0104c9b:	53                   	push   %ebx
f0104c9c:	e8 19 fd ff ff       	call   f01049ba <memcmp>
f0104ca1:	83 c4 10             	add    $0x10,%esp
f0104ca4:	85 c0                	test   %eax,%eax
f0104ca6:	0f 85 83 00 00 00    	jne    f0104d2f <mp_init+0x12c>
f0104cac:	0f b7 7b 04          	movzwl 0x4(%ebx),%edi
f0104cb0:	01 df                	add    %ebx,%edi
	sum = 0;
f0104cb2:	89 c2                	mov    %eax,%edx
	for (i = 0; i < len; i++)
f0104cb4:	39 fb                	cmp    %edi,%ebx
f0104cb6:	0f 84 88 00 00 00    	je     f0104d44 <mp_init+0x141>
		sum += ((uint8_t *)addr)[i];
f0104cbc:	0f b6 0b             	movzbl (%ebx),%ecx
f0104cbf:	01 ca                	add    %ecx,%edx
f0104cc1:	83 c3 01             	add    $0x1,%ebx
f0104cc4:	eb ee                	jmp    f0104cb4 <mp_init+0xb1>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0104cc6:	68 00 04 00 00       	push   $0x400
f0104ccb:	68 f4 55 10 f0       	push   $0xf01055f4
f0104cd0:	6a 6f                	push   $0x6f
f0104cd2:	68 01 71 10 f0       	push   $0xf0107101
f0104cd7:	e8 b8 b3 ff ff       	call   f0100094 <_panic>
		p = *(uint16_t *) (bda + 0x13) * 1024;
f0104cdc:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0104ce3:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f0104ce6:	2d 00 04 00 00       	sub    $0x400,%eax
f0104ceb:	ba 00 04 00 00       	mov    $0x400,%edx
f0104cf0:	e8 72 fe ff ff       	call   f0104b67 <mpsearch1>
f0104cf5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104cf8:	85 c0                	test   %eax,%eax
f0104cfa:	0f 85 60 ff ff ff    	jne    f0104c60 <mp_init+0x5d>
f0104d00:	e9 41 ff ff ff       	jmp    f0104c46 <mp_init+0x43>
		cprintf("SMP: Default configurations not implemented\n");
f0104d05:	83 ec 0c             	sub    $0xc,%esp
f0104d08:	68 74 6f 10 f0       	push   $0xf0106f74
f0104d0d:	e8 f3 ea ff ff       	call   f0103805 <cprintf>
f0104d12:	83 c4 10             	add    $0x10,%esp
f0104d15:	e9 77 01 00 00       	jmp    f0104e91 <mp_init+0x28e>
f0104d1a:	53                   	push   %ebx
f0104d1b:	68 f4 55 10 f0       	push   $0xf01055f4
f0104d20:	68 90 00 00 00       	push   $0x90
f0104d25:	68 01 71 10 f0       	push   $0xf0107101
f0104d2a:	e8 65 b3 ff ff       	call   f0100094 <_panic>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0104d2f:	83 ec 0c             	sub    $0xc,%esp
f0104d32:	68 a4 6f 10 f0       	push   $0xf0106fa4
f0104d37:	e8 c9 ea ff ff       	call   f0103805 <cprintf>
f0104d3c:	83 c4 10             	add    $0x10,%esp
f0104d3f:	e9 4d 01 00 00       	jmp    f0104e91 <mp_init+0x28e>
	if (sum(conf, conf->length) != 0) {
f0104d44:	84 d2                	test   %dl,%dl
f0104d46:	75 16                	jne    f0104d5e <mp_init+0x15b>
	if (conf->version != 1 && conf->version != 4) {
f0104d48:	0f b6 56 06          	movzbl 0x6(%esi),%edx
f0104d4c:	80 fa 01             	cmp    $0x1,%dl
f0104d4f:	74 05                	je     f0104d56 <mp_init+0x153>
f0104d51:	80 fa 04             	cmp    $0x4,%dl
f0104d54:	75 1d                	jne    f0104d73 <mp_init+0x170>
f0104d56:	0f b7 4e 28          	movzwl 0x28(%esi),%ecx
f0104d5a:	01 d9                	add    %ebx,%ecx
f0104d5c:	eb 36                	jmp    f0104d94 <mp_init+0x191>
		cprintf("SMP: Bad MP configuration checksum\n");
f0104d5e:	83 ec 0c             	sub    $0xc,%esp
f0104d61:	68 d8 6f 10 f0       	push   $0xf0106fd8
f0104d66:	e8 9a ea ff ff       	call   f0103805 <cprintf>
f0104d6b:	83 c4 10             	add    $0x10,%esp
f0104d6e:	e9 1e 01 00 00       	jmp    f0104e91 <mp_init+0x28e>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0104d73:	83 ec 08             	sub    $0x8,%esp
f0104d76:	0f b6 d2             	movzbl %dl,%edx
f0104d79:	52                   	push   %edx
f0104d7a:	68 fc 6f 10 f0       	push   $0xf0106ffc
f0104d7f:	e8 81 ea ff ff       	call   f0103805 <cprintf>
f0104d84:	83 c4 10             	add    $0x10,%esp
f0104d87:	e9 05 01 00 00       	jmp    f0104e91 <mp_init+0x28e>
		sum += ((uint8_t *)addr)[i];
f0104d8c:	0f b6 13             	movzbl (%ebx),%edx
f0104d8f:	01 d0                	add    %edx,%eax
f0104d91:	83 c3 01             	add    $0x1,%ebx
	for (i = 0; i < len; i++)
f0104d94:	39 d9                	cmp    %ebx,%ecx
f0104d96:	75 f4                	jne    f0104d8c <mp_init+0x189>
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0104d98:	02 46 2a             	add    0x2a(%esi),%al
f0104d9b:	75 1c                	jne    f0104db9 <mp_init+0x1b6>
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
f0104d9d:	c7 05 00 20 23 f0 01 	movl   $0x1,0xf0232000
f0104da4:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0104da7:	8b 46 24             	mov    0x24(%esi),%eax
f0104daa:	a3 00 30 27 f0       	mov    %eax,0xf0273000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0104daf:	8d 7e 2c             	lea    0x2c(%esi),%edi
f0104db2:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104db7:	eb 4d                	jmp    f0104e06 <mp_init+0x203>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0104db9:	83 ec 0c             	sub    $0xc,%esp
f0104dbc:	68 1c 70 10 f0       	push   $0xf010701c
f0104dc1:	e8 3f ea ff ff       	call   f0103805 <cprintf>
f0104dc6:	83 c4 10             	add    $0x10,%esp
f0104dc9:	e9 c3 00 00 00       	jmp    f0104e91 <mp_init+0x28e>
		switch (*p) {
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0104dce:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f0104dd2:	74 11                	je     f0104de5 <mp_init+0x1e2>
				bootcpu = &cpus[ncpu];
f0104dd4:	6b 05 c4 23 23 f0 74 	imul   $0x74,0xf02323c4,%eax
f0104ddb:	05 20 20 23 f0       	add    $0xf0232020,%eax
f0104de0:	a3 c0 23 23 f0       	mov    %eax,0xf02323c0
			if (ncpu < NCPU) {
f0104de5:	a1 c4 23 23 f0       	mov    0xf02323c4,%eax
f0104dea:	83 f8 07             	cmp    $0x7,%eax
f0104ded:	7f 2f                	jg     f0104e1e <mp_init+0x21b>
				cpus[ncpu].cpu_id = ncpu;
f0104def:	6b d0 74             	imul   $0x74,%eax,%edx
f0104df2:	88 82 20 20 23 f0    	mov    %al,-0xfdcdfe0(%edx)
				ncpu++;
f0104df8:	83 c0 01             	add    $0x1,%eax
f0104dfb:	a3 c4 23 23 f0       	mov    %eax,0xf02323c4
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0104e00:	83 c7 14             	add    $0x14,%edi
	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0104e03:	83 c3 01             	add    $0x1,%ebx
f0104e06:	0f b7 46 22          	movzwl 0x22(%esi),%eax
f0104e0a:	39 d8                	cmp    %ebx,%eax
f0104e0c:	76 4b                	jbe    f0104e59 <mp_init+0x256>
		switch (*p) {
f0104e0e:	0f b6 07             	movzbl (%edi),%eax
f0104e11:	84 c0                	test   %al,%al
f0104e13:	74 b9                	je     f0104dce <mp_init+0x1cb>
f0104e15:	3c 04                	cmp    $0x4,%al
f0104e17:	77 1c                	ja     f0104e35 <mp_init+0x232>
			continue;
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0104e19:	83 c7 08             	add    $0x8,%edi
			continue;
f0104e1c:	eb e5                	jmp    f0104e03 <mp_init+0x200>
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0104e1e:	83 ec 08             	sub    $0x8,%esp
f0104e21:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f0104e25:	50                   	push   %eax
f0104e26:	68 4c 70 10 f0       	push   $0xf010704c
f0104e2b:	e8 d5 e9 ff ff       	call   f0103805 <cprintf>
f0104e30:	83 c4 10             	add    $0x10,%esp
f0104e33:	eb cb                	jmp    f0104e00 <mp_init+0x1fd>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0104e35:	83 ec 08             	sub    $0x8,%esp
		switch (*p) {
f0104e38:	0f b6 c0             	movzbl %al,%eax
			cprintf("mpinit: unknown config type %x\n", *p);
f0104e3b:	50                   	push   %eax
f0104e3c:	68 74 70 10 f0       	push   $0xf0107074
f0104e41:	e8 bf e9 ff ff       	call   f0103805 <cprintf>
			ismp = 0;
f0104e46:	c7 05 00 20 23 f0 00 	movl   $0x0,0xf0232000
f0104e4d:	00 00 00 
			i = conf->entry;
f0104e50:	0f b7 5e 22          	movzwl 0x22(%esi),%ebx
f0104e54:	83 c4 10             	add    $0x10,%esp
f0104e57:	eb aa                	jmp    f0104e03 <mp_init+0x200>
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0104e59:	a1 c0 23 23 f0       	mov    0xf02323c0,%eax
f0104e5e:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0104e65:	83 3d 00 20 23 f0 00 	cmpl   $0x0,0xf0232000
f0104e6c:	74 2b                	je     f0104e99 <mp_init+0x296>
		ncpu = 1;
		lapicaddr = 0;
		cprintf("SMP: configuration not found, SMP disabled\n");
		return;
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0104e6e:	83 ec 04             	sub    $0x4,%esp
f0104e71:	ff 35 c4 23 23 f0    	pushl  0xf02323c4
f0104e77:	0f b6 00             	movzbl (%eax),%eax
f0104e7a:	50                   	push   %eax
f0104e7b:	68 1b 71 10 f0       	push   $0xf010711b
f0104e80:	e8 80 e9 ff ff       	call   f0103805 <cprintf>

	if (mp->imcrp) {
f0104e85:	83 c4 10             	add    $0x10,%esp
f0104e88:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104e8b:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0104e8f:	75 2e                	jne    f0104ebf <mp_init+0x2bc>
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f0104e91:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104e94:	5b                   	pop    %ebx
f0104e95:	5e                   	pop    %esi
f0104e96:	5f                   	pop    %edi
f0104e97:	5d                   	pop    %ebp
f0104e98:	c3                   	ret    
		ncpu = 1;
f0104e99:	c7 05 c4 23 23 f0 01 	movl   $0x1,0xf02323c4
f0104ea0:	00 00 00 
		lapicaddr = 0;
f0104ea3:	c7 05 00 30 27 f0 00 	movl   $0x0,0xf0273000
f0104eaa:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0104ead:	83 ec 0c             	sub    $0xc,%esp
f0104eb0:	68 94 70 10 f0       	push   $0xf0107094
f0104eb5:	e8 4b e9 ff ff       	call   f0103805 <cprintf>
		return;
f0104eba:	83 c4 10             	add    $0x10,%esp
f0104ebd:	eb d2                	jmp    f0104e91 <mp_init+0x28e>
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0104ebf:	83 ec 0c             	sub    $0xc,%esp
f0104ec2:	68 c0 70 10 f0       	push   $0xf01070c0
f0104ec7:	e8 39 e9 ff ff       	call   f0103805 <cprintf>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0104ecc:	b8 70 00 00 00       	mov    $0x70,%eax
f0104ed1:	ba 22 00 00 00       	mov    $0x22,%edx
f0104ed6:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0104ed7:	ba 23 00 00 00       	mov    $0x23,%edx
f0104edc:	ec                   	in     (%dx),%al
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f0104edd:	83 c8 01             	or     $0x1,%eax
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0104ee0:	ee                   	out    %al,(%dx)
f0104ee1:	83 c4 10             	add    $0x10,%esp
f0104ee4:	eb ab                	jmp    f0104e91 <mp_init+0x28e>

f0104ee6 <lapicw>:
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
	lapic[index] = value;
f0104ee6:	8b 0d 04 30 27 f0    	mov    0xf0273004,%ecx
f0104eec:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0104eef:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0104ef1:	a1 04 30 27 f0       	mov    0xf0273004,%eax
f0104ef6:	8b 40 20             	mov    0x20(%eax),%eax
}
f0104ef9:	c3                   	ret    

f0104efa <cpunum>:
}

int
cpunum(void)
{
	if (lapic)
f0104efa:	8b 15 04 30 27 f0    	mov    0xf0273004,%edx
		return lapic[ID] >> 24;
	return 0;
f0104f00:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lapic)
f0104f05:	85 d2                	test   %edx,%edx
f0104f07:	74 06                	je     f0104f0f <cpunum+0x15>
		return lapic[ID] >> 24;
f0104f09:	8b 42 20             	mov    0x20(%edx),%eax
f0104f0c:	c1 e8 18             	shr    $0x18,%eax
}
f0104f0f:	c3                   	ret    

f0104f10 <lapic_init>:
	if (!lapicaddr)
f0104f10:	a1 00 30 27 f0       	mov    0xf0273000,%eax
f0104f15:	85 c0                	test   %eax,%eax
f0104f17:	75 01                	jne    f0104f1a <lapic_init+0xa>
f0104f19:	c3                   	ret    
{
f0104f1a:	55                   	push   %ebp
f0104f1b:	89 e5                	mov    %esp,%ebp
f0104f1d:	83 ec 10             	sub    $0x10,%esp
	lapic = mmio_map_region(lapicaddr, 4096);
f0104f20:	68 00 10 00 00       	push   $0x1000
f0104f25:	50                   	push   %eax
f0104f26:	e8 80 c3 ff ff       	call   f01012ab <mmio_map_region>
f0104f2b:	a3 04 30 27 f0       	mov    %eax,0xf0273004
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0104f30:	ba 27 01 00 00       	mov    $0x127,%edx
f0104f35:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0104f3a:	e8 a7 ff ff ff       	call   f0104ee6 <lapicw>
	lapicw(TDCR, X1);
f0104f3f:	ba 0b 00 00 00       	mov    $0xb,%edx
f0104f44:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0104f49:	e8 98 ff ff ff       	call   f0104ee6 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0104f4e:	ba 20 00 02 00       	mov    $0x20020,%edx
f0104f53:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0104f58:	e8 89 ff ff ff       	call   f0104ee6 <lapicw>
	lapicw(TICR, 10000000); 
f0104f5d:	ba 80 96 98 00       	mov    $0x989680,%edx
f0104f62:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0104f67:	e8 7a ff ff ff       	call   f0104ee6 <lapicw>
	if (thiscpu != bootcpu)
f0104f6c:	e8 89 ff ff ff       	call   f0104efa <cpunum>
f0104f71:	6b c0 74             	imul   $0x74,%eax,%eax
f0104f74:	05 20 20 23 f0       	add    $0xf0232020,%eax
f0104f79:	83 c4 10             	add    $0x10,%esp
f0104f7c:	39 05 c0 23 23 f0    	cmp    %eax,0xf02323c0
f0104f82:	74 0f                	je     f0104f93 <lapic_init+0x83>
		lapicw(LINT0, MASKED);
f0104f84:	ba 00 00 01 00       	mov    $0x10000,%edx
f0104f89:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0104f8e:	e8 53 ff ff ff       	call   f0104ee6 <lapicw>
	lapicw(LINT1, MASKED);
f0104f93:	ba 00 00 01 00       	mov    $0x10000,%edx
f0104f98:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0104f9d:	e8 44 ff ff ff       	call   f0104ee6 <lapicw>
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0104fa2:	a1 04 30 27 f0       	mov    0xf0273004,%eax
f0104fa7:	8b 40 30             	mov    0x30(%eax),%eax
f0104faa:	c1 e8 10             	shr    $0x10,%eax
f0104fad:	a8 fc                	test   $0xfc,%al
f0104faf:	75 7c                	jne    f010502d <lapic_init+0x11d>
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0104fb1:	ba 33 00 00 00       	mov    $0x33,%edx
f0104fb6:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0104fbb:	e8 26 ff ff ff       	call   f0104ee6 <lapicw>
	lapicw(ESR, 0);
f0104fc0:	ba 00 00 00 00       	mov    $0x0,%edx
f0104fc5:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0104fca:	e8 17 ff ff ff       	call   f0104ee6 <lapicw>
	lapicw(ESR, 0);
f0104fcf:	ba 00 00 00 00       	mov    $0x0,%edx
f0104fd4:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0104fd9:	e8 08 ff ff ff       	call   f0104ee6 <lapicw>
	lapicw(EOI, 0);
f0104fde:	ba 00 00 00 00       	mov    $0x0,%edx
f0104fe3:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0104fe8:	e8 f9 fe ff ff       	call   f0104ee6 <lapicw>
	lapicw(ICRHI, 0);
f0104fed:	ba 00 00 00 00       	mov    $0x0,%edx
f0104ff2:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0104ff7:	e8 ea fe ff ff       	call   f0104ee6 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0104ffc:	ba 00 85 08 00       	mov    $0x88500,%edx
f0105001:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105006:	e8 db fe ff ff       	call   f0104ee6 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f010500b:	8b 15 04 30 27 f0    	mov    0xf0273004,%edx
f0105011:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105017:	f6 c4 10             	test   $0x10,%ah
f010501a:	75 f5                	jne    f0105011 <lapic_init+0x101>
	lapicw(TPR, 0);
f010501c:	ba 00 00 00 00       	mov    $0x0,%edx
f0105021:	b8 20 00 00 00       	mov    $0x20,%eax
f0105026:	e8 bb fe ff ff       	call   f0104ee6 <lapicw>
}
f010502b:	c9                   	leave  
f010502c:	c3                   	ret    
		lapicw(PCINT, MASKED);
f010502d:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105032:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0105037:	e8 aa fe ff ff       	call   f0104ee6 <lapicw>
f010503c:	e9 70 ff ff ff       	jmp    f0104fb1 <lapic_init+0xa1>

f0105041 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f0105041:	83 3d 04 30 27 f0 00 	cmpl   $0x0,0xf0273004
f0105048:	74 17                	je     f0105061 <lapic_eoi+0x20>
{
f010504a:	55                   	push   %ebp
f010504b:	89 e5                	mov    %esp,%ebp
f010504d:	83 ec 08             	sub    $0x8,%esp
		lapicw(EOI, 0);
f0105050:	ba 00 00 00 00       	mov    $0x0,%edx
f0105055:	b8 2c 00 00 00       	mov    $0x2c,%eax
f010505a:	e8 87 fe ff ff       	call   f0104ee6 <lapicw>
}
f010505f:	c9                   	leave  
f0105060:	c3                   	ret    
f0105061:	c3                   	ret    

f0105062 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0105062:	55                   	push   %ebp
f0105063:	89 e5                	mov    %esp,%ebp
f0105065:	56                   	push   %esi
f0105066:	53                   	push   %ebx
f0105067:	8b 75 08             	mov    0x8(%ebp),%esi
f010506a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010506d:	b8 0f 00 00 00       	mov    $0xf,%eax
f0105072:	ba 70 00 00 00       	mov    $0x70,%edx
f0105077:	ee                   	out    %al,(%dx)
f0105078:	b8 0a 00 00 00       	mov    $0xa,%eax
f010507d:	ba 71 00 00 00       	mov    $0x71,%edx
f0105082:	ee                   	out    %al,(%dx)
	if (PGNUM(pa) >= npages)
f0105083:	83 3d 08 1f 23 f0 00 	cmpl   $0x0,0xf0231f08
f010508a:	74 7e                	je     f010510a <lapic_startap+0xa8>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f010508c:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0105093:	00 00 
	wrv[1] = addr >> 4;
f0105095:	89 d8                	mov    %ebx,%eax
f0105097:	c1 e8 04             	shr    $0x4,%eax
f010509a:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f01050a0:	c1 e6 18             	shl    $0x18,%esi
f01050a3:	89 f2                	mov    %esi,%edx
f01050a5:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01050aa:	e8 37 fe ff ff       	call   f0104ee6 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f01050af:	ba 00 c5 00 00       	mov    $0xc500,%edx
f01050b4:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01050b9:	e8 28 fe ff ff       	call   f0104ee6 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f01050be:	ba 00 85 00 00       	mov    $0x8500,%edx
f01050c3:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01050c8:	e8 19 fe ff ff       	call   f0104ee6 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01050cd:	c1 eb 0c             	shr    $0xc,%ebx
f01050d0:	80 cf 06             	or     $0x6,%bh
		lapicw(ICRHI, apicid << 24);
f01050d3:	89 f2                	mov    %esi,%edx
f01050d5:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01050da:	e8 07 fe ff ff       	call   f0104ee6 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01050df:	89 da                	mov    %ebx,%edx
f01050e1:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01050e6:	e8 fb fd ff ff       	call   f0104ee6 <lapicw>
		lapicw(ICRHI, apicid << 24);
f01050eb:	89 f2                	mov    %esi,%edx
f01050ed:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01050f2:	e8 ef fd ff ff       	call   f0104ee6 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01050f7:	89 da                	mov    %ebx,%edx
f01050f9:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01050fe:	e8 e3 fd ff ff       	call   f0104ee6 <lapicw>
		microdelay(200);
	}
}
f0105103:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105106:	5b                   	pop    %ebx
f0105107:	5e                   	pop    %esi
f0105108:	5d                   	pop    %ebp
f0105109:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010510a:	68 67 04 00 00       	push   $0x467
f010510f:	68 f4 55 10 f0       	push   $0xf01055f4
f0105114:	68 98 00 00 00       	push   $0x98
f0105119:	68 38 71 10 f0       	push   $0xf0107138
f010511e:	e8 71 af ff ff       	call   f0100094 <_panic>

f0105123 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0105123:	55                   	push   %ebp
f0105124:	89 e5                	mov    %esp,%ebp
f0105126:	83 ec 08             	sub    $0x8,%esp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0105129:	8b 55 08             	mov    0x8(%ebp),%edx
f010512c:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0105132:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105137:	e8 aa fd ff ff       	call   f0104ee6 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f010513c:	8b 15 04 30 27 f0    	mov    0xf0273004,%edx
f0105142:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105148:	f6 c4 10             	test   $0x10,%ah
f010514b:	75 f5                	jne    f0105142 <lapic_ipi+0x1f>
		;
}
f010514d:	c9                   	leave  
f010514e:	c3                   	ret    

f010514f <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f010514f:	55                   	push   %ebp
f0105150:	89 e5                	mov    %esp,%ebp
f0105152:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0105155:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f010515b:	8b 55 0c             	mov    0xc(%ebp),%edx
f010515e:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0105161:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0105168:	5d                   	pop    %ebp
f0105169:	c3                   	ret    

f010516a <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f010516a:	55                   	push   %ebp
f010516b:	89 e5                	mov    %esp,%ebp
f010516d:	56                   	push   %esi
f010516e:	53                   	push   %ebx
f010516f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	return lock->locked && lock->cpu == thiscpu;
f0105172:	83 3b 00             	cmpl   $0x0,(%ebx)
f0105175:	75 12                	jne    f0105189 <spin_lock+0x1f>
	asm volatile("lock; xchgl %0, %1"
f0105177:	ba 01 00 00 00       	mov    $0x1,%edx
f010517c:	89 d0                	mov    %edx,%eax
f010517e:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0105181:	85 c0                	test   %eax,%eax
f0105183:	74 36                	je     f01051bb <spin_lock+0x51>
		asm volatile ("pause");
f0105185:	f3 90                	pause  
f0105187:	eb f3                	jmp    f010517c <spin_lock+0x12>
	return lock->locked && lock->cpu == thiscpu;
f0105189:	8b 73 08             	mov    0x8(%ebx),%esi
f010518c:	e8 69 fd ff ff       	call   f0104efa <cpunum>
f0105191:	6b c0 74             	imul   $0x74,%eax,%eax
f0105194:	05 20 20 23 f0       	add    $0xf0232020,%eax
	if (holding(lk))
f0105199:	39 c6                	cmp    %eax,%esi
f010519b:	75 da                	jne    f0105177 <spin_lock+0xd>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f010519d:	8b 5b 04             	mov    0x4(%ebx),%ebx
f01051a0:	e8 55 fd ff ff       	call   f0104efa <cpunum>
f01051a5:	83 ec 0c             	sub    $0xc,%esp
f01051a8:	53                   	push   %ebx
f01051a9:	50                   	push   %eax
f01051aa:	68 48 71 10 f0       	push   $0xf0107148
f01051af:	6a 41                	push   $0x41
f01051b1:	68 ac 71 10 f0       	push   $0xf01071ac
f01051b6:	e8 d9 ae ff ff       	call   f0100094 <_panic>

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f01051bb:	e8 3a fd ff ff       	call   f0104efa <cpunum>
f01051c0:	6b c0 74             	imul   $0x74,%eax,%eax
f01051c3:	05 20 20 23 f0       	add    $0xf0232020,%eax
f01051c8:	89 43 08             	mov    %eax,0x8(%ebx)
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f01051cb:	89 ea                	mov    %ebp,%edx
	for (i = 0; i < 10; i++){
f01051cd:	b8 00 00 00 00       	mov    $0x0,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f01051d2:	83 f8 09             	cmp    $0x9,%eax
f01051d5:	7f 16                	jg     f01051ed <spin_lock+0x83>
f01051d7:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f01051dd:	76 0e                	jbe    f01051ed <spin_lock+0x83>
		pcs[i] = ebp[1];          // saved %eip
f01051df:	8b 4a 04             	mov    0x4(%edx),%ecx
f01051e2:	89 4c 83 0c          	mov    %ecx,0xc(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f01051e6:	8b 12                	mov    (%edx),%edx
	for (i = 0; i < 10; i++){
f01051e8:	83 c0 01             	add    $0x1,%eax
f01051eb:	eb e5                	jmp    f01051d2 <spin_lock+0x68>
	for (; i < 10; i++)
f01051ed:	83 f8 09             	cmp    $0x9,%eax
f01051f0:	7f 0d                	jg     f01051ff <spin_lock+0x95>
		pcs[i] = 0;
f01051f2:	c7 44 83 0c 00 00 00 	movl   $0x0,0xc(%ebx,%eax,4)
f01051f9:	00 
	for (; i < 10; i++)
f01051fa:	83 c0 01             	add    $0x1,%eax
f01051fd:	eb ee                	jmp    f01051ed <spin_lock+0x83>
	get_caller_pcs(lk->pcs);
#endif
}
f01051ff:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105202:	5b                   	pop    %ebx
f0105203:	5e                   	pop    %esi
f0105204:	5d                   	pop    %ebp
f0105205:	c3                   	ret    

f0105206 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0105206:	55                   	push   %ebp
f0105207:	89 e5                	mov    %esp,%ebp
f0105209:	57                   	push   %edi
f010520a:	56                   	push   %esi
f010520b:	53                   	push   %ebx
f010520c:	83 ec 4c             	sub    $0x4c,%esp
f010520f:	8b 75 08             	mov    0x8(%ebp),%esi
	return lock->locked && lock->cpu == thiscpu;
f0105212:	83 3e 00             	cmpl   $0x0,(%esi)
f0105215:	75 35                	jne    f010524c <spin_unlock+0x46>
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f0105217:	83 ec 04             	sub    $0x4,%esp
f010521a:	6a 28                	push   $0x28
f010521c:	8d 46 0c             	lea    0xc(%esi),%eax
f010521f:	50                   	push   %eax
f0105220:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f0105223:	53                   	push   %ebx
f0105224:	e8 19 f7 ff ff       	call   f0104942 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f0105229:	8b 46 08             	mov    0x8(%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f010522c:	0f b6 38             	movzbl (%eax),%edi
f010522f:	8b 76 04             	mov    0x4(%esi),%esi
f0105232:	e8 c3 fc ff ff       	call   f0104efa <cpunum>
f0105237:	57                   	push   %edi
f0105238:	56                   	push   %esi
f0105239:	50                   	push   %eax
f010523a:	68 74 71 10 f0       	push   $0xf0107174
f010523f:	e8 c1 e5 ff ff       	call   f0103805 <cprintf>
f0105244:	83 c4 20             	add    $0x20,%esp
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0105247:	8d 7d a8             	lea    -0x58(%ebp),%edi
f010524a:	eb 4e                	jmp    f010529a <spin_unlock+0x94>
	return lock->locked && lock->cpu == thiscpu;
f010524c:	8b 5e 08             	mov    0x8(%esi),%ebx
f010524f:	e8 a6 fc ff ff       	call   f0104efa <cpunum>
f0105254:	6b c0 74             	imul   $0x74,%eax,%eax
f0105257:	05 20 20 23 f0       	add    $0xf0232020,%eax
	if (!holding(lk)) {
f010525c:	39 c3                	cmp    %eax,%ebx
f010525e:	75 b7                	jne    f0105217 <spin_unlock+0x11>
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
	}

	lk->pcs[0] = 0;
f0105260:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f0105267:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
	asm volatile("lock; xchgl %0, %1"
f010526e:	b8 00 00 00 00       	mov    $0x0,%eax
f0105273:	f0 87 06             	lock xchg %eax,(%esi)
	// respect to any other instruction which references the same memory.
	// x86 CPUs will not reorder loads/stores across locked instructions
	// (vol 3, 8.2.2). Because xchg() is implemented using asm volatile,
	// gcc will not reorder C statements across the xchg.
	xchg(&lk->locked, 0);
}
f0105276:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105279:	5b                   	pop    %ebx
f010527a:	5e                   	pop    %esi
f010527b:	5f                   	pop    %edi
f010527c:	5d                   	pop    %ebp
f010527d:	c3                   	ret    
				cprintf("  %08x\n", pcs[i]);
f010527e:	83 ec 08             	sub    $0x8,%esp
f0105281:	ff 36                	pushl  (%esi)
f0105283:	68 d3 71 10 f0       	push   $0xf01071d3
f0105288:	e8 78 e5 ff ff       	call   f0103805 <cprintf>
f010528d:	83 c4 10             	add    $0x10,%esp
f0105290:	83 c3 04             	add    $0x4,%ebx
		for (i = 0; i < 10 && pcs[i]; i++) {
f0105293:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0105296:	39 c3                	cmp    %eax,%ebx
f0105298:	74 40                	je     f01052da <spin_unlock+0xd4>
f010529a:	89 de                	mov    %ebx,%esi
f010529c:	8b 03                	mov    (%ebx),%eax
f010529e:	85 c0                	test   %eax,%eax
f01052a0:	74 38                	je     f01052da <spin_unlock+0xd4>
			if (debuginfo_eip(pcs[i], &info) >= 0)
f01052a2:	83 ec 08             	sub    $0x8,%esp
f01052a5:	57                   	push   %edi
f01052a6:	50                   	push   %eax
f01052a7:	e8 0f ec ff ff       	call   f0103ebb <debuginfo_eip>
f01052ac:	83 c4 10             	add    $0x10,%esp
f01052af:	85 c0                	test   %eax,%eax
f01052b1:	78 cb                	js     f010527e <spin_unlock+0x78>
					pcs[i] - info.eip_fn_addr);
f01052b3:	8b 06                	mov    (%esi),%eax
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f01052b5:	83 ec 04             	sub    $0x4,%esp
f01052b8:	89 c2                	mov    %eax,%edx
f01052ba:	2b 55 b8             	sub    -0x48(%ebp),%edx
f01052bd:	52                   	push   %edx
f01052be:	ff 75 b0             	pushl  -0x50(%ebp)
f01052c1:	ff 75 b4             	pushl  -0x4c(%ebp)
f01052c4:	ff 75 ac             	pushl  -0x54(%ebp)
f01052c7:	ff 75 a8             	pushl  -0x58(%ebp)
f01052ca:	50                   	push   %eax
f01052cb:	68 bc 71 10 f0       	push   $0xf01071bc
f01052d0:	e8 30 e5 ff ff       	call   f0103805 <cprintf>
f01052d5:	83 c4 20             	add    $0x20,%esp
f01052d8:	eb b6                	jmp    f0105290 <spin_unlock+0x8a>
		panic("spin_unlock");
f01052da:	83 ec 04             	sub    $0x4,%esp
f01052dd:	68 db 71 10 f0       	push   $0xf01071db
f01052e2:	6a 67                	push   $0x67
f01052e4:	68 ac 71 10 f0       	push   $0xf01071ac
f01052e9:	e8 a6 ad ff ff       	call   f0100094 <_panic>
f01052ee:	66 90                	xchg   %ax,%ax

f01052f0 <__udivdi3>:
f01052f0:	f3 0f 1e fb          	endbr32 
f01052f4:	55                   	push   %ebp
f01052f5:	57                   	push   %edi
f01052f6:	56                   	push   %esi
f01052f7:	53                   	push   %ebx
f01052f8:	83 ec 1c             	sub    $0x1c,%esp
f01052fb:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f01052ff:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f0105303:	8b 74 24 34          	mov    0x34(%esp),%esi
f0105307:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f010530b:	85 d2                	test   %edx,%edx
f010530d:	75 49                	jne    f0105358 <__udivdi3+0x68>
f010530f:	39 f3                	cmp    %esi,%ebx
f0105311:	76 15                	jbe    f0105328 <__udivdi3+0x38>
f0105313:	31 ff                	xor    %edi,%edi
f0105315:	89 e8                	mov    %ebp,%eax
f0105317:	89 f2                	mov    %esi,%edx
f0105319:	f7 f3                	div    %ebx
f010531b:	89 fa                	mov    %edi,%edx
f010531d:	83 c4 1c             	add    $0x1c,%esp
f0105320:	5b                   	pop    %ebx
f0105321:	5e                   	pop    %esi
f0105322:	5f                   	pop    %edi
f0105323:	5d                   	pop    %ebp
f0105324:	c3                   	ret    
f0105325:	8d 76 00             	lea    0x0(%esi),%esi
f0105328:	89 d9                	mov    %ebx,%ecx
f010532a:	85 db                	test   %ebx,%ebx
f010532c:	75 0b                	jne    f0105339 <__udivdi3+0x49>
f010532e:	b8 01 00 00 00       	mov    $0x1,%eax
f0105333:	31 d2                	xor    %edx,%edx
f0105335:	f7 f3                	div    %ebx
f0105337:	89 c1                	mov    %eax,%ecx
f0105339:	31 d2                	xor    %edx,%edx
f010533b:	89 f0                	mov    %esi,%eax
f010533d:	f7 f1                	div    %ecx
f010533f:	89 c6                	mov    %eax,%esi
f0105341:	89 e8                	mov    %ebp,%eax
f0105343:	89 f7                	mov    %esi,%edi
f0105345:	f7 f1                	div    %ecx
f0105347:	89 fa                	mov    %edi,%edx
f0105349:	83 c4 1c             	add    $0x1c,%esp
f010534c:	5b                   	pop    %ebx
f010534d:	5e                   	pop    %esi
f010534e:	5f                   	pop    %edi
f010534f:	5d                   	pop    %ebp
f0105350:	c3                   	ret    
f0105351:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105358:	39 f2                	cmp    %esi,%edx
f010535a:	77 1c                	ja     f0105378 <__udivdi3+0x88>
f010535c:	0f bd fa             	bsr    %edx,%edi
f010535f:	83 f7 1f             	xor    $0x1f,%edi
f0105362:	75 2c                	jne    f0105390 <__udivdi3+0xa0>
f0105364:	39 f2                	cmp    %esi,%edx
f0105366:	72 06                	jb     f010536e <__udivdi3+0x7e>
f0105368:	31 c0                	xor    %eax,%eax
f010536a:	39 eb                	cmp    %ebp,%ebx
f010536c:	77 ad                	ja     f010531b <__udivdi3+0x2b>
f010536e:	b8 01 00 00 00       	mov    $0x1,%eax
f0105373:	eb a6                	jmp    f010531b <__udivdi3+0x2b>
f0105375:	8d 76 00             	lea    0x0(%esi),%esi
f0105378:	31 ff                	xor    %edi,%edi
f010537a:	31 c0                	xor    %eax,%eax
f010537c:	89 fa                	mov    %edi,%edx
f010537e:	83 c4 1c             	add    $0x1c,%esp
f0105381:	5b                   	pop    %ebx
f0105382:	5e                   	pop    %esi
f0105383:	5f                   	pop    %edi
f0105384:	5d                   	pop    %ebp
f0105385:	c3                   	ret    
f0105386:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f010538d:	8d 76 00             	lea    0x0(%esi),%esi
f0105390:	89 f9                	mov    %edi,%ecx
f0105392:	b8 20 00 00 00       	mov    $0x20,%eax
f0105397:	29 f8                	sub    %edi,%eax
f0105399:	d3 e2                	shl    %cl,%edx
f010539b:	89 54 24 08          	mov    %edx,0x8(%esp)
f010539f:	89 c1                	mov    %eax,%ecx
f01053a1:	89 da                	mov    %ebx,%edx
f01053a3:	d3 ea                	shr    %cl,%edx
f01053a5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f01053a9:	09 d1                	or     %edx,%ecx
f01053ab:	89 f2                	mov    %esi,%edx
f01053ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01053b1:	89 f9                	mov    %edi,%ecx
f01053b3:	d3 e3                	shl    %cl,%ebx
f01053b5:	89 c1                	mov    %eax,%ecx
f01053b7:	d3 ea                	shr    %cl,%edx
f01053b9:	89 f9                	mov    %edi,%ecx
f01053bb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01053bf:	89 eb                	mov    %ebp,%ebx
f01053c1:	d3 e6                	shl    %cl,%esi
f01053c3:	89 c1                	mov    %eax,%ecx
f01053c5:	d3 eb                	shr    %cl,%ebx
f01053c7:	09 de                	or     %ebx,%esi
f01053c9:	89 f0                	mov    %esi,%eax
f01053cb:	f7 74 24 08          	divl   0x8(%esp)
f01053cf:	89 d6                	mov    %edx,%esi
f01053d1:	89 c3                	mov    %eax,%ebx
f01053d3:	f7 64 24 0c          	mull   0xc(%esp)
f01053d7:	39 d6                	cmp    %edx,%esi
f01053d9:	72 15                	jb     f01053f0 <__udivdi3+0x100>
f01053db:	89 f9                	mov    %edi,%ecx
f01053dd:	d3 e5                	shl    %cl,%ebp
f01053df:	39 c5                	cmp    %eax,%ebp
f01053e1:	73 04                	jae    f01053e7 <__udivdi3+0xf7>
f01053e3:	39 d6                	cmp    %edx,%esi
f01053e5:	74 09                	je     f01053f0 <__udivdi3+0x100>
f01053e7:	89 d8                	mov    %ebx,%eax
f01053e9:	31 ff                	xor    %edi,%edi
f01053eb:	e9 2b ff ff ff       	jmp    f010531b <__udivdi3+0x2b>
f01053f0:	8d 43 ff             	lea    -0x1(%ebx),%eax
f01053f3:	31 ff                	xor    %edi,%edi
f01053f5:	e9 21 ff ff ff       	jmp    f010531b <__udivdi3+0x2b>
f01053fa:	66 90                	xchg   %ax,%ax
f01053fc:	66 90                	xchg   %ax,%ax
f01053fe:	66 90                	xchg   %ax,%ax

f0105400 <__umoddi3>:
f0105400:	f3 0f 1e fb          	endbr32 
f0105404:	55                   	push   %ebp
f0105405:	57                   	push   %edi
f0105406:	56                   	push   %esi
f0105407:	53                   	push   %ebx
f0105408:	83 ec 1c             	sub    $0x1c,%esp
f010540b:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f010540f:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f0105413:	8b 74 24 30          	mov    0x30(%esp),%esi
f0105417:	8b 7c 24 38          	mov    0x38(%esp),%edi
f010541b:	89 da                	mov    %ebx,%edx
f010541d:	85 c0                	test   %eax,%eax
f010541f:	75 3f                	jne    f0105460 <__umoddi3+0x60>
f0105421:	39 df                	cmp    %ebx,%edi
f0105423:	76 13                	jbe    f0105438 <__umoddi3+0x38>
f0105425:	89 f0                	mov    %esi,%eax
f0105427:	f7 f7                	div    %edi
f0105429:	89 d0                	mov    %edx,%eax
f010542b:	31 d2                	xor    %edx,%edx
f010542d:	83 c4 1c             	add    $0x1c,%esp
f0105430:	5b                   	pop    %ebx
f0105431:	5e                   	pop    %esi
f0105432:	5f                   	pop    %edi
f0105433:	5d                   	pop    %ebp
f0105434:	c3                   	ret    
f0105435:	8d 76 00             	lea    0x0(%esi),%esi
f0105438:	89 fd                	mov    %edi,%ebp
f010543a:	85 ff                	test   %edi,%edi
f010543c:	75 0b                	jne    f0105449 <__umoddi3+0x49>
f010543e:	b8 01 00 00 00       	mov    $0x1,%eax
f0105443:	31 d2                	xor    %edx,%edx
f0105445:	f7 f7                	div    %edi
f0105447:	89 c5                	mov    %eax,%ebp
f0105449:	89 d8                	mov    %ebx,%eax
f010544b:	31 d2                	xor    %edx,%edx
f010544d:	f7 f5                	div    %ebp
f010544f:	89 f0                	mov    %esi,%eax
f0105451:	f7 f5                	div    %ebp
f0105453:	89 d0                	mov    %edx,%eax
f0105455:	eb d4                	jmp    f010542b <__umoddi3+0x2b>
f0105457:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f010545e:	66 90                	xchg   %ax,%ax
f0105460:	89 f1                	mov    %esi,%ecx
f0105462:	39 d8                	cmp    %ebx,%eax
f0105464:	76 0a                	jbe    f0105470 <__umoddi3+0x70>
f0105466:	89 f0                	mov    %esi,%eax
f0105468:	83 c4 1c             	add    $0x1c,%esp
f010546b:	5b                   	pop    %ebx
f010546c:	5e                   	pop    %esi
f010546d:	5f                   	pop    %edi
f010546e:	5d                   	pop    %ebp
f010546f:	c3                   	ret    
f0105470:	0f bd e8             	bsr    %eax,%ebp
f0105473:	83 f5 1f             	xor    $0x1f,%ebp
f0105476:	75 20                	jne    f0105498 <__umoddi3+0x98>
f0105478:	39 d8                	cmp    %ebx,%eax
f010547a:	0f 82 b0 00 00 00    	jb     f0105530 <__umoddi3+0x130>
f0105480:	39 f7                	cmp    %esi,%edi
f0105482:	0f 86 a8 00 00 00    	jbe    f0105530 <__umoddi3+0x130>
f0105488:	89 c8                	mov    %ecx,%eax
f010548a:	83 c4 1c             	add    $0x1c,%esp
f010548d:	5b                   	pop    %ebx
f010548e:	5e                   	pop    %esi
f010548f:	5f                   	pop    %edi
f0105490:	5d                   	pop    %ebp
f0105491:	c3                   	ret    
f0105492:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0105498:	89 e9                	mov    %ebp,%ecx
f010549a:	ba 20 00 00 00       	mov    $0x20,%edx
f010549f:	29 ea                	sub    %ebp,%edx
f01054a1:	d3 e0                	shl    %cl,%eax
f01054a3:	89 44 24 08          	mov    %eax,0x8(%esp)
f01054a7:	89 d1                	mov    %edx,%ecx
f01054a9:	89 f8                	mov    %edi,%eax
f01054ab:	d3 e8                	shr    %cl,%eax
f01054ad:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f01054b1:	89 54 24 04          	mov    %edx,0x4(%esp)
f01054b5:	8b 54 24 04          	mov    0x4(%esp),%edx
f01054b9:	09 c1                	or     %eax,%ecx
f01054bb:	89 d8                	mov    %ebx,%eax
f01054bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01054c1:	89 e9                	mov    %ebp,%ecx
f01054c3:	d3 e7                	shl    %cl,%edi
f01054c5:	89 d1                	mov    %edx,%ecx
f01054c7:	d3 e8                	shr    %cl,%eax
f01054c9:	89 e9                	mov    %ebp,%ecx
f01054cb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01054cf:	d3 e3                	shl    %cl,%ebx
f01054d1:	89 c7                	mov    %eax,%edi
f01054d3:	89 d1                	mov    %edx,%ecx
f01054d5:	89 f0                	mov    %esi,%eax
f01054d7:	d3 e8                	shr    %cl,%eax
f01054d9:	89 e9                	mov    %ebp,%ecx
f01054db:	89 fa                	mov    %edi,%edx
f01054dd:	d3 e6                	shl    %cl,%esi
f01054df:	09 d8                	or     %ebx,%eax
f01054e1:	f7 74 24 08          	divl   0x8(%esp)
f01054e5:	89 d1                	mov    %edx,%ecx
f01054e7:	89 f3                	mov    %esi,%ebx
f01054e9:	f7 64 24 0c          	mull   0xc(%esp)
f01054ed:	89 c6                	mov    %eax,%esi
f01054ef:	89 d7                	mov    %edx,%edi
f01054f1:	39 d1                	cmp    %edx,%ecx
f01054f3:	72 06                	jb     f01054fb <__umoddi3+0xfb>
f01054f5:	75 10                	jne    f0105507 <__umoddi3+0x107>
f01054f7:	39 c3                	cmp    %eax,%ebx
f01054f9:	73 0c                	jae    f0105507 <__umoddi3+0x107>
f01054fb:	2b 44 24 0c          	sub    0xc(%esp),%eax
f01054ff:	1b 54 24 08          	sbb    0x8(%esp),%edx
f0105503:	89 d7                	mov    %edx,%edi
f0105505:	89 c6                	mov    %eax,%esi
f0105507:	89 ca                	mov    %ecx,%edx
f0105509:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f010550e:	29 f3                	sub    %esi,%ebx
f0105510:	19 fa                	sbb    %edi,%edx
f0105512:	89 d0                	mov    %edx,%eax
f0105514:	d3 e0                	shl    %cl,%eax
f0105516:	89 e9                	mov    %ebp,%ecx
f0105518:	d3 eb                	shr    %cl,%ebx
f010551a:	d3 ea                	shr    %cl,%edx
f010551c:	09 d8                	or     %ebx,%eax
f010551e:	83 c4 1c             	add    $0x1c,%esp
f0105521:	5b                   	pop    %ebx
f0105522:	5e                   	pop    %esi
f0105523:	5f                   	pop    %edi
f0105524:	5d                   	pop    %ebp
f0105525:	c3                   	ret    
f0105526:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f010552d:	8d 76 00             	lea    0x0(%esi),%esi
f0105530:	89 da                	mov    %ebx,%edx
f0105532:	29 fe                	sub    %edi,%esi
f0105534:	19 c2                	sbb    %eax,%edx
f0105536:	89 f1                	mov    %esi,%ecx
f0105538:	89 c8                	mov    %ecx,%eax
f010553a:	e9 4b ff ff ff       	jmp    f010548a <__umoddi3+0x8a>
