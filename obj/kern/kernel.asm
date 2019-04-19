
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
f010004b:	68 60 55 10 f0       	push   $0xf0105560
f0100050:	e8 58 37 00 00       	call   f01037ad <cprintf>
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
f010006f:	68 7c 55 10 f0       	push   $0xf010557c
f0100074:	e8 34 37 00 00       	call   f01037ad <cprintf>
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
f010009c:	83 3d 80 1e 23 f0 00 	cmpl   $0x0,0xf0231e80
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
f01000b4:	89 35 80 1e 23 f0    	mov    %esi,0xf0231e80
	asm volatile("cli; cld");
f01000ba:	fa                   	cli    
f01000bb:	fc                   	cld    
	va_start(ap, fmt);
f01000bc:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f01000bf:	e8 46 4e 00 00       	call   f0104f0a <cpunum>
f01000c4:	ff 75 0c             	pushl  0xc(%ebp)
f01000c7:	ff 75 08             	pushl  0x8(%ebp)
f01000ca:	50                   	push   %eax
f01000cb:	68 f0 55 10 f0       	push   $0xf01055f0
f01000d0:	e8 d8 36 00 00       	call   f01037ad <cprintf>
	vcprintf(fmt, ap);
f01000d5:	83 c4 08             	add    $0x8,%esp
f01000d8:	53                   	push   %ebx
f01000d9:	56                   	push   %esi
f01000da:	e8 a8 36 00 00       	call   f0103787 <vcprintf>
	cprintf("\n");
f01000df:	c7 04 24 6b 67 10 f0 	movl   $0xf010676b,(%esp)
f01000e6:	e8 c2 36 00 00       	call   f01037ad <cprintf>
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
f0100104:	68 97 55 10 f0       	push   $0xf0105597
f0100109:	e8 9f 36 00 00       	call   f01037ad <cprintf>
	test_backtrace(5);
f010010e:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f0100115:	e8 26 ff ff ff       	call   f0100040 <test_backtrace>
	mem_init();
f010011a:	e8 bc 11 00 00       	call   f01012db <mem_init>
	env_init();
f010011f:	e8 db 2e 00 00       	call   f0102fff <env_init>
	trap_init();
f0100124:	e8 62 37 00 00       	call   f010388b <trap_init>
	mp_init();
f0100129:	e8 e5 4a 00 00       	call   f0104c13 <mp_init>
	lapic_init();
f010012e:	e8 ed 4d 00 00       	call   f0104f20 <lapic_init>
	pic_init();
f0100133:	e8 96 35 00 00       	call   f01036ce <pic_init>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100138:	83 c4 10             	add    $0x10,%esp
f010013b:	83 3d 88 1e 23 f0 07 	cmpl   $0x7,0xf0231e88
f0100142:	76 27                	jbe    f010016b <i386_init+0x7b>
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f0100144:	83 ec 04             	sub    $0x4,%esp
f0100147:	b8 76 4b 10 f0       	mov    $0xf0104b76,%eax
f010014c:	2d fc 4a 10 f0       	sub    $0xf0104afc,%eax
f0100151:	50                   	push   %eax
f0100152:	68 fc 4a 10 f0       	push   $0xf0104afc
f0100157:	68 00 70 00 f0       	push   $0xf0007000
f010015c:	e8 f1 47 00 00       	call   f0104952 <memmove>
f0100161:	83 c4 10             	add    $0x10,%esp
	for (c = cpus; c < cpus + ncpu; c++) {
f0100164:	bb 20 20 23 f0       	mov    $0xf0232020,%ebx
f0100169:	eb 19                	jmp    f0100184 <i386_init+0x94>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010016b:	68 00 70 00 00       	push   $0x7000
f0100170:	68 14 56 10 f0       	push   $0xf0105614
f0100175:	6a 5a                	push   $0x5a
f0100177:	68 b2 55 10 f0       	push   $0xf01055b2
f010017c:	e8 13 ff ff ff       	call   f0100094 <_panic>
f0100181:	83 c3 74             	add    $0x74,%ebx
f0100184:	6b 05 c4 23 23 f0 74 	imul   $0x74,0xf02323c4,%eax
f010018b:	05 20 20 23 f0       	add    $0xf0232020,%eax
f0100190:	39 c3                	cmp    %eax,%ebx
f0100192:	73 4d                	jae    f01001e1 <i386_init+0xf1>
		if (c == cpus + cpunum())  // We've started already.
f0100194:	e8 71 4d 00 00       	call   f0104f0a <cpunum>
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
f01001be:	a3 84 1e 23 f0       	mov    %eax,0xf0231e84
		lapic_startap(c->cpu_id, PADDR(code));
f01001c3:	83 ec 08             	sub    $0x8,%esp
f01001c6:	68 00 70 00 00       	push   $0x7000
f01001cb:	0f b6 03             	movzbl (%ebx),%eax
f01001ce:	50                   	push   %eax
f01001cf:	e8 9e 4e 00 00       	call   f0105072 <lapic_startap>
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
f01001eb:	e8 e0 2f 00 00       	call   f01031d0 <env_create>
	sched_yield();
f01001f0:	e8 bf 3b 00 00       	call   f0103db4 <sched_yield>

f01001f5 <mp_main>:
{
f01001f5:	55                   	push   %ebp
f01001f6:	89 e5                	mov    %esp,%ebp
f01001f8:	83 ec 08             	sub    $0x8,%esp
	lcr3(PADDR(kern_pgdir));
f01001fb:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
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
f010020f:	e8 f6 4c 00 00       	call   f0104f0a <cpunum>
f0100214:	83 ec 08             	sub    $0x8,%esp
f0100217:	50                   	push   %eax
f0100218:	68 be 55 10 f0       	push   $0xf01055be
f010021d:	e8 8b 35 00 00       	call   f01037ad <cprintf>
	lapic_init();
f0100222:	e8 f9 4c 00 00       	call   f0104f20 <lapic_init>
	env_init_percpu();
f0100227:	e8 a7 2d 00 00       	call   f0102fd3 <env_init_percpu>
	trap_init_percpu();
f010022c:	e8 90 35 00 00       	call   f01037c1 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100231:	e8 d4 4c 00 00       	call   f0104f0a <cpunum>
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
f010024e:	68 38 56 10 f0       	push   $0xf0105638
f0100253:	6a 71                	push   $0x71
f0100255:	68 b2 55 10 f0       	push   $0xf01055b2
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
f010026f:	68 d4 55 10 f0       	push   $0xf01055d4
f0100274:	e8 34 35 00 00       	call   f01037ad <cprintf>
	vcprintf(fmt, ap);
f0100279:	83 c4 08             	add    $0x8,%esp
f010027c:	53                   	push   %ebx
f010027d:	ff 75 10             	pushl  0x10(%ebp)
f0100280:	e8 02 35 00 00       	call   f0103787 <vcprintf>
	cprintf("\n");
f0100285:	c7 04 24 6b 67 10 f0 	movl   $0xf010676b,(%esp)
f010028c:	e8 1c 35 00 00       	call   f01037ad <cprintf>
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
f010033b:	0f b6 82 c0 57 10 f0 	movzbl -0xfefa840(%edx),%eax
f0100342:	0b 05 00 10 23 f0    	or     0xf0231000,%eax
	shift ^= togglecode[data];
f0100348:	0f b6 8a c0 56 10 f0 	movzbl -0xfefa940(%edx),%ecx
f010034f:	31 c8                	xor    %ecx,%eax
f0100351:	a3 00 10 23 f0       	mov    %eax,0xf0231000
	c = charcode[shift & (CTL | SHIFT)][data];
f0100356:	89 c1                	mov    %eax,%ecx
f0100358:	83 e1 03             	and    $0x3,%ecx
f010035b:	8b 0c 8d a0 56 10 f0 	mov    -0xfefa960(,%ecx,4),%ecx
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
f01003a5:	0f b6 82 c0 57 10 f0 	movzbl -0xfefa840(%edx),%eax
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
f01003df:	68 5c 56 10 f0       	push   $0xf010565c
f01003e4:	e8 c4 33 00 00       	call   f01037ad <cprintf>
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
f01005c7:	e8 86 43 00 00       	call   f0104952 <memmove>
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
f01006f1:	e8 5a 2f 00 00       	call   f0103650 <irq_setmask_8259A>
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
f0100787:	68 68 56 10 f0       	push   $0xf0105668
f010078c:	e8 1c 30 00 00       	call   f01037ad <cprintf>
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
f01007c3:	68 c0 58 10 f0       	push   $0xf01058c0
f01007c8:	68 de 58 10 f0       	push   $0xf01058de
f01007cd:	68 e3 58 10 f0       	push   $0xf01058e3
f01007d2:	e8 d6 2f 00 00       	call   f01037ad <cprintf>
f01007d7:	83 c4 0c             	add    $0xc,%esp
f01007da:	68 90 59 10 f0       	push   $0xf0105990
f01007df:	68 ec 58 10 f0       	push   $0xf01058ec
f01007e4:	68 e3 58 10 f0       	push   $0xf01058e3
f01007e9:	e8 bf 2f 00 00       	call   f01037ad <cprintf>
f01007ee:	83 c4 0c             	add    $0xc,%esp
f01007f1:	68 f5 58 10 f0       	push   $0xf01058f5
f01007f6:	68 0c 59 10 f0       	push   $0xf010590c
f01007fb:	68 e3 58 10 f0       	push   $0xf01058e3
f0100800:	e8 a8 2f 00 00       	call   f01037ad <cprintf>
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
f0100812:	68 16 59 10 f0       	push   $0xf0105916
f0100817:	e8 91 2f 00 00       	call   f01037ad <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f010081c:	83 c4 08             	add    $0x8,%esp
f010081f:	68 0c 00 10 00       	push   $0x10000c
f0100824:	68 b8 59 10 f0       	push   $0xf01059b8
f0100829:	e8 7f 2f 00 00       	call   f01037ad <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010082e:	83 c4 0c             	add    $0xc,%esp
f0100831:	68 0c 00 10 00       	push   $0x10000c
f0100836:	68 0c 00 10 f0       	push   $0xf010000c
f010083b:	68 e0 59 10 f0       	push   $0xf01059e0
f0100840:	e8 68 2f 00 00       	call   f01037ad <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100845:	83 c4 0c             	add    $0xc,%esp
f0100848:	68 4f 55 10 00       	push   $0x10554f
f010084d:	68 4f 55 10 f0       	push   $0xf010554f
f0100852:	68 04 5a 10 f0       	push   $0xf0105a04
f0100857:	e8 51 2f 00 00       	call   f01037ad <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010085c:	83 c4 0c             	add    $0xc,%esp
f010085f:	68 00 10 23 00       	push   $0x231000
f0100864:	68 00 10 23 f0       	push   $0xf0231000
f0100869:	68 28 5a 10 f0       	push   $0xf0105a28
f010086e:	e8 3a 2f 00 00       	call   f01037ad <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100873:	83 c4 0c             	add    $0xc,%esp
f0100876:	68 08 30 27 00       	push   $0x273008
f010087b:	68 08 30 27 f0       	push   $0xf0273008
f0100880:	68 4c 5a 10 f0       	push   $0xf0105a4c
f0100885:	e8 23 2f 00 00       	call   f01037ad <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f010088a:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f010088d:	b8 08 30 27 f0       	mov    $0xf0273008,%eax
f0100892:	2d 0d fc 0f f0       	sub    $0xf00ffc0d,%eax
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100897:	c1 f8 0a             	sar    $0xa,%eax
f010089a:	50                   	push   %eax
f010089b:	68 70 5a 10 f0       	push   $0xf0105a70
f01008a0:	e8 08 2f 00 00       	call   f01037ad <cprintf>
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
f01008b7:	68 2f 59 10 f0       	push   $0xf010592f
f01008bc:	e8 ec 2e 00 00       	call   f01037ad <cprintf>
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
f01008df:	68 41 59 10 f0       	push   $0xf0105941
f01008e4:	e8 c4 2e 00 00       	call   f01037ad <cprintf>
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
f0100907:	68 9c 5a 10 f0       	push   $0xf0105a9c
f010090c:	e8 9c 2e 00 00       	call   f01037ad <cprintf>
		if (debuginfo_eip(ptr_ebp[1], &info) == 0) {
f0100911:	83 c4 18             	add    $0x18,%esp
f0100914:	57                   	push   %edi
f0100915:	ff 73 04             	pushl  0x4(%ebx)
f0100918:	e8 ae 35 00 00       	call   f0103ecb <debuginfo_eip>
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
f010093c:	68 cc 5a 10 f0       	push   $0xf0105acc
f0100941:	e8 67 2e 00 00       	call   f01037ad <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100946:	c7 04 24 f0 5a 10 f0 	movl   $0xf0105af0,(%esp)
f010094d:	e8 5b 2e 00 00       	call   f01037ad <cprintf>

	if (tf != NULL)
f0100952:	83 c4 10             	add    $0x10,%esp
f0100955:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100959:	0f 84 d9 00 00 00    	je     f0100a38 <monitor+0x105>
		print_trapframe(tf);
f010095f:	83 ec 0c             	sub    $0xc,%esp
f0100962:	ff 75 08             	pushl  0x8(%ebp)
f0100965:	e8 bc 2f 00 00       	call   f0103926 <print_trapframe>
f010096a:	83 c4 10             	add    $0x10,%esp
f010096d:	e9 c6 00 00 00       	jmp    f0100a38 <monitor+0x105>
		while (*buf && strchr(WHITESPACE, *buf))
f0100972:	83 ec 08             	sub    $0x8,%esp
f0100975:	0f be c0             	movsbl %al,%eax
f0100978:	50                   	push   %eax
f0100979:	68 57 59 10 f0       	push   $0xf0105957
f010097e:	e8 4a 3f 00 00       	call   f01048cd <strchr>
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
f01009b6:	ff 34 85 20 5b 10 f0 	pushl  -0xfefa4e0(,%eax,4)
f01009bd:	ff 75 a8             	pushl  -0x58(%ebp)
f01009c0:	e8 aa 3e 00 00       	call   f010486f <strcmp>
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
f01009de:	68 79 59 10 f0       	push   $0xf0105979
f01009e3:	e8 c5 2d 00 00       	call   f01037ad <cprintf>
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
f0100a0c:	68 57 59 10 f0       	push   $0xf0105957
f0100a11:	e8 b7 3e 00 00       	call   f01048cd <strchr>
f0100a16:	83 c4 10             	add    $0x10,%esp
f0100a19:	85 c0                	test   %eax,%eax
f0100a1b:	0f 85 71 ff ff ff    	jne    f0100992 <monitor+0x5f>
			buf++;
f0100a21:	83 c3 01             	add    $0x1,%ebx
f0100a24:	eb d8                	jmp    f01009fe <monitor+0xcb>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100a26:	83 ec 08             	sub    $0x8,%esp
f0100a29:	6a 10                	push   $0x10
f0100a2b:	68 5c 59 10 f0       	push   $0xf010595c
f0100a30:	e8 78 2d 00 00       	call   f01037ad <cprintf>
f0100a35:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f0100a38:	83 ec 0c             	sub    $0xc,%esp
f0100a3b:	68 53 59 10 f0       	push   $0xf0105953
f0100a40:	e8 64 3c 00 00       	call   f01046a9 <readline>
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
f0100a6d:	ff 14 85 28 5b 10 f0 	call   *-0xfefa4d8(,%eax,4)
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
f0100ac4:	e8 59 2b 00 00       	call   f0103622 <mc146818_read>
f0100ac9:	89 c3                	mov    %eax,%ebx
f0100acb:	83 c6 01             	add    $0x1,%esi
f0100ace:	89 34 24             	mov    %esi,(%esp)
f0100ad1:	e8 4c 2b 00 00       	call   f0103622 <mc146818_read>
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
f0100af8:	3b 0d 88 1e 23 f0    	cmp    0xf0231e88,%ecx
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
f0100b2c:	68 14 56 10 f0       	push   $0xf0105614
f0100b31:	68 a1 03 00 00       	push   $0x3a1
f0100b36:	68 65 64 10 f0       	push   $0xf0106465
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
f0100b6d:	68 44 5b 10 f0       	push   $0xf0105b44
f0100b72:	68 cb 02 00 00       	push   $0x2cb
f0100b77:	68 65 64 10 f0       	push   $0xf0106465
f0100b7c:	e8 13 f5 ff ff       	call   f0100094 <_panic>
f0100b81:	50                   	push   %eax
f0100b82:	68 14 56 10 f0       	push   $0xf0105614
f0100b87:	6a 58                	push   $0x58
f0100b89:	68 78 64 10 f0       	push   $0xf0106478
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
f0100b9b:	2b 05 90 1e 23 f0    	sub    0xf0231e90,%eax
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
f0100bb5:	3b 15 88 1e 23 f0    	cmp    0xf0231e88,%edx
f0100bbb:	73 c4                	jae    f0100b81 <check_page_free_list+0x3b>
			memset(page2kva(pp), 0x97, 128);
f0100bbd:	83 ec 04             	sub    $0x4,%esp
f0100bc0:	68 80 00 00 00       	push   $0x80
f0100bc5:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0100bca:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100bcf:	50                   	push   %eax
f0100bd0:	e8 35 3d 00 00       	call   f010490a <memset>
f0100bd5:	83 c4 10             	add    $0x10,%esp
f0100bd8:	eb b9                	jmp    f0100b93 <check_page_free_list+0x4d>
	first_free_page = (char *) boot_alloc(0);
f0100bda:	b8 00 00 00 00       	mov    $0x0,%eax
f0100bdf:	e8 9f fe ff ff       	call   f0100a83 <boot_alloc>
f0100be4:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100be7:	8b 15 3c 12 23 f0    	mov    0xf023123c,%edx
		assert(pp >= pages);
f0100bed:	8b 0d 90 1e 23 f0    	mov    0xf0231e90,%ecx
		assert(pp < pages + npages);
f0100bf3:	a1 88 1e 23 f0       	mov    0xf0231e88,%eax
f0100bf8:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100bfb:	8d 34 c1             	lea    (%ecx,%eax,8),%esi
	int nfree_basemem = 0, nfree_extmem = 0;
f0100bfe:	bf 00 00 00 00       	mov    $0x0,%edi
f0100c03:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c06:	e9 f9 00 00 00       	jmp    f0100d04 <check_page_free_list+0x1be>
		assert(pp >= pages);
f0100c0b:	68 86 64 10 f0       	push   $0xf0106486
f0100c10:	68 92 64 10 f0       	push   $0xf0106492
f0100c15:	68 e8 02 00 00       	push   $0x2e8
f0100c1a:	68 65 64 10 f0       	push   $0xf0106465
f0100c1f:	e8 70 f4 ff ff       	call   f0100094 <_panic>
		assert(pp < pages + npages);
f0100c24:	68 a7 64 10 f0       	push   $0xf01064a7
f0100c29:	68 92 64 10 f0       	push   $0xf0106492
f0100c2e:	68 e9 02 00 00       	push   $0x2e9
f0100c33:	68 65 64 10 f0       	push   $0xf0106465
f0100c38:	e8 57 f4 ff ff       	call   f0100094 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100c3d:	68 68 5b 10 f0       	push   $0xf0105b68
f0100c42:	68 92 64 10 f0       	push   $0xf0106492
f0100c47:	68 ea 02 00 00       	push   $0x2ea
f0100c4c:	68 65 64 10 f0       	push   $0xf0106465
f0100c51:	e8 3e f4 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != 0);
f0100c56:	68 bb 64 10 f0       	push   $0xf01064bb
f0100c5b:	68 92 64 10 f0       	push   $0xf0106492
f0100c60:	68 ed 02 00 00       	push   $0x2ed
f0100c65:	68 65 64 10 f0       	push   $0xf0106465
f0100c6a:	e8 25 f4 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100c6f:	68 cc 64 10 f0       	push   $0xf01064cc
f0100c74:	68 92 64 10 f0       	push   $0xf0106492
f0100c79:	68 ee 02 00 00       	push   $0x2ee
f0100c7e:	68 65 64 10 f0       	push   $0xf0106465
f0100c83:	e8 0c f4 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100c88:	68 9c 5b 10 f0       	push   $0xf0105b9c
f0100c8d:	68 92 64 10 f0       	push   $0xf0106492
f0100c92:	68 ef 02 00 00       	push   $0x2ef
f0100c97:	68 65 64 10 f0       	push   $0xf0106465
f0100c9c:	e8 f3 f3 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100ca1:	68 e5 64 10 f0       	push   $0xf01064e5
f0100ca6:	68 92 64 10 f0       	push   $0xf0106492
f0100cab:	68 f0 02 00 00       	push   $0x2f0
f0100cb0:	68 65 64 10 f0       	push   $0xf0106465
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
f0100cd4:	68 14 56 10 f0       	push   $0xf0105614
f0100cd9:	6a 58                	push   $0x58
f0100cdb:	68 78 64 10 f0       	push   $0xf0106478
f0100ce0:	e8 af f3 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100ce5:	68 c0 5b 10 f0       	push   $0xf0105bc0
f0100cea:	68 92 64 10 f0       	push   $0xf0106492
f0100cef:	68 f1 02 00 00       	push   $0x2f1
f0100cf4:	68 65 64 10 f0       	push   $0xf0106465
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
f0100d63:	68 ff 64 10 f0       	push   $0xf01064ff
f0100d68:	68 92 64 10 f0       	push   $0xf0106492
f0100d6d:	68 f3 02 00 00       	push   $0x2f3
f0100d72:	68 65 64 10 f0       	push   $0xf0106465
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
f0100d8a:	68 08 5c 10 f0       	push   $0xf0105c08
f0100d8f:	e8 19 2a 00 00       	call   f01037ad <cprintf>
}
f0100d94:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100d97:	5b                   	pop    %ebx
f0100d98:	5e                   	pop    %esi
f0100d99:	5f                   	pop    %edi
f0100d9a:	5d                   	pop    %ebp
f0100d9b:	c3                   	ret    
	assert(nfree_basemem > 0);
f0100d9c:	68 1c 65 10 f0       	push   $0xf010651c
f0100da1:	68 92 64 10 f0       	push   $0xf0106492
f0100da6:	68 fb 02 00 00       	push   $0x2fb
f0100dab:	68 65 64 10 f0       	push   $0xf0106465
f0100db0:	e8 df f2 ff ff       	call   f0100094 <_panic>
	assert(nfree_extmem > 0);
f0100db5:	68 2e 65 10 f0       	push   $0xf010652e
f0100dba:	68 92 64 10 f0       	push   $0xf0106492
f0100dbf:	68 fc 02 00 00       	push   $0x2fc
f0100dc4:	68 65 64 10 f0       	push   $0xf0106465
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
f0100de9:	2b 15 90 1e 23 f0    	sub    0xf0231e90,%edx
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
f0100e10:	68 71 64 10 f0       	push   $0xf0106471
f0100e15:	e8 93 29 00 00       	call   f01037ad <cprintf>
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
f0100e4b:	a1 90 1e 23 f0       	mov    0xf0231e90,%eax
f0100e50:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
    for (i = 1; i < npages_basemem; i++) {
f0100e56:	bb 01 00 00 00       	mov    $0x1,%ebx
f0100e5b:	eb 3c                	jmp    f0100e99 <page_init+0x53>
f0100e5d:	8d 34 dd 00 00 00 00 	lea    0x0(,%ebx,8),%esi
        pages[i].pp_ref = 0;
f0100e64:	89 f2                	mov    %esi,%edx
f0100e66:	03 15 90 1e 23 f0    	add    0xf0231e90,%edx
f0100e6c:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
        pages[i].pp_link = page_free_list;
f0100e72:	a1 3c 12 23 f0       	mov    0xf023123c,%eax
f0100e77:	89 02                	mov    %eax,(%edx)
		cprintf("page_init:%p\n", page_free_list);
f0100e79:	83 ec 08             	sub    $0x8,%esp
f0100e7c:	50                   	push   %eax
f0100e7d:	68 3f 65 10 f0       	push   $0xf010653f
f0100e82:	e8 26 29 00 00       	call   f01037ad <cprintf>
        page_free_list = &pages[i];
f0100e87:	03 35 90 1e 23 f0    	add    0xf0231e90,%esi
f0100e8d:	89 35 3c 12 23 f0    	mov    %esi,0xf023123c
f0100e93:	83 c4 10             	add    $0x10,%esp
    for (i = 1; i < npages_basemem; i++) {
f0100e96:	83 c3 01             	add    $0x1,%ebx
f0100e99:	39 1d 40 12 23 f0    	cmp    %ebx,0xf0231240
f0100e9f:	76 12                	jbe    f0100eb3 <page_init+0x6d>
		if (i == mp_page) {
f0100ea1:	83 fb 07             	cmp    $0x7,%ebx
f0100ea4:	75 b7                	jne    f0100e5d <page_init+0x17>
			 pages[i].pp_ref = 1;
f0100ea6:	a1 90 1e 23 f0       	mov    0xf0231e90,%eax
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
f0100eca:	8b 15 90 1e 23 f0    	mov    0xf0231e90,%edx
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
f0100f00:	68 38 56 10 f0       	push   $0xf0105638
f0100f05:	68 5b 01 00 00       	push   $0x15b
f0100f0a:	68 65 64 10 f0       	push   $0xf0106465
f0100f0f:	e8 80 f1 ff ff       	call   f0100094 <_panic>
f0100f14:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
        pages[i].pp_ref = 0;
f0100f1b:	89 d1                	mov    %edx,%ecx
f0100f1d:	03 0d 90 1e 23 f0    	add    0xf0231e90,%ecx
f0100f23:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
        pages[i].pp_link = page_free_list;
f0100f29:	89 19                	mov    %ebx,(%ecx)
    for (i = first_free_address/PGSIZE; i < npages; i++) {
f0100f2b:	83 c0 01             	add    $0x1,%eax
        page_free_list = &pages[i];
f0100f2e:	89 d3                	mov    %edx,%ebx
f0100f30:	03 1d 90 1e 23 f0    	add    0xf0231e90,%ebx
f0100f36:	89 f2                	mov    %esi,%edx
    for (i = first_free_address/PGSIZE; i < npages; i++) {
f0100f38:	39 05 88 1e 23 f0    	cmp    %eax,0xf0231e88
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
f0100f7e:	2b 05 90 1e 23 f0    	sub    0xf0231e90,%eax
f0100f84:	c1 f8 03             	sar    $0x3,%eax
f0100f87:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0100f8a:	89 c2                	mov    %eax,%edx
f0100f8c:	c1 ea 0c             	shr    $0xc,%edx
f0100f8f:	3b 15 88 1e 23 f0    	cmp    0xf0231e88,%edx
f0100f95:	73 1a                	jae    f0100fb1 <page_alloc+0x60>
		memset(page2kva(page), 0, PGSIZE); 
f0100f97:	83 ec 04             	sub    $0x4,%esp
f0100f9a:	68 00 10 00 00       	push   $0x1000
f0100f9f:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f0100fa1:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100fa6:	50                   	push   %eax
f0100fa7:	e8 5e 39 00 00       	call   f010490a <memset>
f0100fac:	83 c4 10             	add    $0x10,%esp
f0100faf:	eb c4                	jmp    f0100f75 <page_alloc+0x24>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100fb1:	50                   	push   %eax
f0100fb2:	68 14 56 10 f0       	push   $0xf0105614
f0100fb7:	6a 58                	push   $0x58
f0100fb9:	68 78 64 10 f0       	push   $0xf0106478
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
f0100fea:	68 2c 5c 10 f0       	push   $0xf0105c2c
f0100fef:	68 96 01 00 00       	push   $0x196
f0100ff4:	68 65 64 10 f0       	push   $0xf0106465
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
f0101057:	39 15 88 1e 23 f0    	cmp    %edx,0xf0231e88
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
f010106f:	68 14 56 10 f0       	push   $0xf0105614
f0101074:	68 c6 01 00 00       	push   $0x1c6
f0101079:	68 65 64 10 f0       	push   $0xf0106465
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
f010109f:	2b 05 90 1e 23 f0    	sub    0xf0231e90,%eax
f01010a5:	89 c2                	mov    %eax,%edx
f01010a7:	c1 fa 03             	sar    $0x3,%edx
f01010aa:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f01010ad:	89 d0                	mov    %edx,%eax
f01010af:	c1 e8 0c             	shr    $0xc,%eax
f01010b2:	3b 05 88 1e 23 f0    	cmp    0xf0231e88,%eax
f01010b8:	73 0d                	jae    f01010c7 <pgdir_walk+0xa0>
	return (void *)(pa + KERNBASE);
f01010ba:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
				pgdir[pdx] = page2pa(new_pginfo) | PTE_P | PTE_W | PTE_U;
f01010c0:	83 ca 07             	or     $0x7,%edx
f01010c3:	89 13                	mov    %edx,(%ebx)
f01010c5:	eb 9d                	jmp    f0101064 <pgdir_walk+0x3d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01010c7:	52                   	push   %edx
f01010c8:	68 14 56 10 f0       	push   $0xf0105614
f01010cd:	6a 58                	push   $0x58
f01010cf:	68 78 64 10 f0       	push   $0xf0106478
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
f010116a:	39 15 88 1e 23 f0    	cmp    %edx,0xf0231e88
f0101170:	76 0a                	jbe    f010117c <page_lookup+0x41>
		panic("pa2page called with invalid pa");
	return &pages[PGNUM(pa)];
f0101172:	a1 90 1e 23 f0       	mov    0xf0231e90,%eax
f0101177:	8d 04 d0             	lea    (%eax,%edx,8),%eax
			return pa2page(PTE_ADDR(*pte)); 
f010117a:	eb e9                	jmp    f0101165 <page_lookup+0x2a>
		panic("pa2page called with invalid pa");
f010117c:	83 ec 04             	sub    $0x4,%esp
f010117f:	68 64 5c 10 f0       	push   $0xf0105c64
f0101184:	6a 51                	push   $0x51
f0101186:	68 78 64 10 f0       	push   $0xf0106478
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
f010119d:	e8 68 3d 00 00       	call   f0104f0a <cpunum>
f01011a2:	6b c0 74             	imul   $0x74,%eax,%eax
f01011a5:	83 b8 28 20 23 f0 00 	cmpl   $0x0,-0xfdcdfd8(%eax)
f01011ac:	74 16                	je     f01011c4 <tlb_invalidate+0x2d>
f01011ae:	e8 57 3d 00 00       	call   f0104f0a <cpunum>
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
f010123f:	2b 1d 90 1e 23 f0    	sub    0xf0231e90,%ebx
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
f01012a8:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
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
f01012c7:	68 4d 65 10 f0       	push   $0xf010654d
f01012cc:	68 84 02 00 00       	push   $0x284
f01012d1:	68 65 64 10 f0       	push   $0xf0106465
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
f0101319:	89 15 88 1e 23 f0    	mov    %edx,0xf0231e88
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
f0101331:	68 84 5c 10 f0       	push   $0xf0105c84
f0101336:	e8 72 24 00 00       	call   f01037ad <cprintf>
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f010133b:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101340:	e8 3e f7 ff ff       	call   f0100a83 <boot_alloc>
f0101345:	a3 8c 1e 23 f0       	mov    %eax,0xf0231e8c
	memset(kern_pgdir, 0, PGSIZE);
f010134a:	83 c4 0c             	add    $0xc,%esp
f010134d:	68 00 10 00 00       	push   $0x1000
f0101352:	6a 00                	push   $0x0
f0101354:	50                   	push   %eax
f0101355:	e8 b0 35 00 00       	call   f010490a <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f010135a:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f010135f:	83 c4 10             	add    $0x10,%esp
f0101362:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101367:	0f 86 9c 00 00 00    	jbe    f0101409 <mem_init+0x12e>
	return (physaddr_t)kva - KERNBASE;
f010136d:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101373:	83 ca 05             	or     $0x5,%edx
f0101376:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	pages = (struct PageInfo*) boot_alloc(npages * sizeof(struct PageInfo));
f010137c:	a1 88 1e 23 f0       	mov    0xf0231e88,%eax
f0101381:	c1 e0 03             	shl    $0x3,%eax
f0101384:	e8 fa f6 ff ff       	call   f0100a83 <boot_alloc>
f0101389:	a3 90 1e 23 f0       	mov    %eax,0xf0231e90
	memset(pages, 0, npages * sizeof(struct PageInfo));
f010138e:	83 ec 04             	sub    $0x4,%esp
f0101391:	8b 0d 88 1e 23 f0    	mov    0xf0231e88,%ecx
f0101397:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f010139e:	52                   	push   %edx
f010139f:	6a 00                	push   $0x0
f01013a1:	50                   	push   %eax
f01013a2:	e8 63 35 00 00       	call   f010490a <memset>
	envs = (struct Env*) boot_alloc(NENV * sizeof(struct Env));
f01013a7:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f01013ac:	e8 d2 f6 ff ff       	call   f0100a83 <boot_alloc>
f01013b1:	a3 44 12 23 f0       	mov    %eax,0xf0231244
	memset(envs, 0, NENV * sizeof(struct Env));
f01013b6:	83 c4 0c             	add    $0xc,%esp
f01013b9:	68 00 f0 01 00       	push   $0x1f000
f01013be:	6a 00                	push   $0x0
f01013c0:	50                   	push   %eax
f01013c1:	e8 44 35 00 00       	call   f010490a <memset>
	page_init();
f01013c6:	e8 7b fa ff ff       	call   f0100e46 <page_init>
	check_page_free_list(1);
f01013cb:	b8 01 00 00 00       	mov    $0x1,%eax
f01013d0:	e8 71 f7 ff ff       	call   f0100b46 <check_page_free_list>
	if (!pages)
f01013d5:	83 c4 10             	add    $0x10,%esp
f01013d8:	83 3d 90 1e 23 f0 00 	cmpl   $0x0,0xf0231e90
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
f010140a:	68 38 56 10 f0       	push   $0xf0105638
f010140f:	68 a3 00 00 00       	push   $0xa3
f0101414:	68 65 64 10 f0       	push   $0xf0106465
f0101419:	e8 76 ec ff ff       	call   f0100094 <_panic>
		panic("'pages' is a null pointer!");
f010141e:	83 ec 04             	sub    $0x4,%esp
f0101421:	68 5e 65 10 f0       	push   $0xf010655e
f0101426:	68 0f 03 00 00       	push   $0x30f
f010142b:	68 65 64 10 f0       	push   $0xf0106465
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
f0101492:	8b 0d 90 1e 23 f0    	mov    0xf0231e90,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101498:	8b 15 88 1e 23 f0    	mov    0xf0231e88,%edx
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
f0101566:	39 c3                	cmp    %eax,%ebx
f0101568:	0f 84 23 02 00 00    	je     f0101791 <mem_init+0x4b6>
f010156e:	39 c6                	cmp    %eax,%esi
f0101570:	0f 84 1b 02 00 00    	je     f0101791 <mem_init+0x4b6>
	assert(!page_alloc(0));
f0101576:	83 ec 0c             	sub    $0xc,%esp
f0101579:	6a 00                	push   $0x0
f010157b:	e8 d1 f9 ff ff       	call   f0100f51 <page_alloc>
f0101580:	83 c4 10             	add    $0x10,%esp
f0101583:	85 c0                	test   %eax,%eax
f0101585:	0f 85 1f 02 00 00    	jne    f01017aa <mem_init+0x4cf>
f010158b:	89 d8                	mov    %ebx,%eax
f010158d:	2b 05 90 1e 23 f0    	sub    0xf0231e90,%eax
f0101593:	c1 f8 03             	sar    $0x3,%eax
f0101596:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0101599:	89 c2                	mov    %eax,%edx
f010159b:	c1 ea 0c             	shr    $0xc,%edx
f010159e:	3b 15 88 1e 23 f0    	cmp    0xf0231e88,%edx
f01015a4:	0f 83 19 02 00 00    	jae    f01017c3 <mem_init+0x4e8>
	memset(page2kva(pp0), 1, PGSIZE);
f01015aa:	83 ec 04             	sub    $0x4,%esp
f01015ad:	68 00 10 00 00       	push   $0x1000
f01015b2:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f01015b4:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01015b9:	50                   	push   %eax
f01015ba:	e8 4b 33 00 00       	call   f010490a <memset>
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
f01015e6:	2b 05 90 1e 23 f0    	sub    0xf0231e90,%eax
f01015ec:	c1 f8 03             	sar    $0x3,%eax
f01015ef:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f01015f2:	89 c2                	mov    %eax,%edx
f01015f4:	c1 ea 0c             	shr    $0xc,%edx
f01015f7:	3b 15 88 1e 23 f0    	cmp    0xf0231e88,%edx
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
f010164c:	68 79 65 10 f0       	push   $0xf0106579
f0101651:	68 92 64 10 f0       	push   $0xf0106492
f0101656:	68 17 03 00 00       	push   $0x317
f010165b:	68 65 64 10 f0       	push   $0xf0106465
f0101660:	e8 2f ea ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f0101665:	68 8f 65 10 f0       	push   $0xf010658f
f010166a:	68 92 64 10 f0       	push   $0xf0106492
f010166f:	68 18 03 00 00       	push   $0x318
f0101674:	68 65 64 10 f0       	push   $0xf0106465
f0101679:	e8 16 ea ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f010167e:	68 a5 65 10 f0       	push   $0xf01065a5
f0101683:	68 92 64 10 f0       	push   $0xf0106492
f0101688:	68 19 03 00 00       	push   $0x319
f010168d:	68 65 64 10 f0       	push   $0xf0106465
f0101692:	e8 fd e9 ff ff       	call   f0100094 <_panic>
	assert(pp1 && pp1 != pp0);
f0101697:	68 bb 65 10 f0       	push   $0xf01065bb
f010169c:	68 92 64 10 f0       	push   $0xf0106492
f01016a1:	68 1c 03 00 00       	push   $0x31c
f01016a6:	68 65 64 10 f0       	push   $0xf0106465
f01016ab:	e8 e4 e9 ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01016b0:	68 c0 5c 10 f0       	push   $0xf0105cc0
f01016b5:	68 92 64 10 f0       	push   $0xf0106492
f01016ba:	68 1d 03 00 00       	push   $0x31d
f01016bf:	68 65 64 10 f0       	push   $0xf0106465
f01016c4:	e8 cb e9 ff ff       	call   f0100094 <_panic>
	assert(page2pa(pp0) < npages*PGSIZE);
f01016c9:	68 cd 65 10 f0       	push   $0xf01065cd
f01016ce:	68 92 64 10 f0       	push   $0xf0106492
f01016d3:	68 1e 03 00 00       	push   $0x31e
f01016d8:	68 65 64 10 f0       	push   $0xf0106465
f01016dd:	e8 b2 e9 ff ff       	call   f0100094 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f01016e2:	68 ea 65 10 f0       	push   $0xf01065ea
f01016e7:	68 92 64 10 f0       	push   $0xf0106492
f01016ec:	68 1f 03 00 00       	push   $0x31f
f01016f1:	68 65 64 10 f0       	push   $0xf0106465
f01016f6:	e8 99 e9 ff ff       	call   f0100094 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f01016fb:	68 07 66 10 f0       	push   $0xf0106607
f0101700:	68 92 64 10 f0       	push   $0xf0106492
f0101705:	68 20 03 00 00       	push   $0x320
f010170a:	68 65 64 10 f0       	push   $0xf0106465
f010170f:	e8 80 e9 ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f0101714:	68 24 66 10 f0       	push   $0xf0106624
f0101719:	68 92 64 10 f0       	push   $0xf0106492
f010171e:	68 27 03 00 00       	push   $0x327
f0101723:	68 65 64 10 f0       	push   $0xf0106465
f0101728:	e8 67 e9 ff ff       	call   f0100094 <_panic>
	assert((pp0 = page_alloc(0)));
f010172d:	68 79 65 10 f0       	push   $0xf0106579
f0101732:	68 92 64 10 f0       	push   $0xf0106492
f0101737:	68 2e 03 00 00       	push   $0x32e
f010173c:	68 65 64 10 f0       	push   $0xf0106465
f0101741:	e8 4e e9 ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f0101746:	68 8f 65 10 f0       	push   $0xf010658f
f010174b:	68 92 64 10 f0       	push   $0xf0106492
f0101750:	68 2f 03 00 00       	push   $0x32f
f0101755:	68 65 64 10 f0       	push   $0xf0106465
f010175a:	e8 35 e9 ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f010175f:	68 a5 65 10 f0       	push   $0xf01065a5
f0101764:	68 92 64 10 f0       	push   $0xf0106492
f0101769:	68 30 03 00 00       	push   $0x330
f010176e:	68 65 64 10 f0       	push   $0xf0106465
f0101773:	e8 1c e9 ff ff       	call   f0100094 <_panic>
	assert(pp1 && pp1 != pp0);
f0101778:	68 bb 65 10 f0       	push   $0xf01065bb
f010177d:	68 92 64 10 f0       	push   $0xf0106492
f0101782:	68 32 03 00 00       	push   $0x332
f0101787:	68 65 64 10 f0       	push   $0xf0106465
f010178c:	e8 03 e9 ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101791:	68 c0 5c 10 f0       	push   $0xf0105cc0
f0101796:	68 92 64 10 f0       	push   $0xf0106492
f010179b:	68 33 03 00 00       	push   $0x333
f01017a0:	68 65 64 10 f0       	push   $0xf0106465
f01017a5:	e8 ea e8 ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f01017aa:	68 24 66 10 f0       	push   $0xf0106624
f01017af:	68 92 64 10 f0       	push   $0xf0106492
f01017b4:	68 34 03 00 00       	push   $0x334
f01017b9:	68 65 64 10 f0       	push   $0xf0106465
f01017be:	e8 d1 e8 ff ff       	call   f0100094 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01017c3:	50                   	push   %eax
f01017c4:	68 14 56 10 f0       	push   $0xf0105614
f01017c9:	6a 58                	push   $0x58
f01017cb:	68 78 64 10 f0       	push   $0xf0106478
f01017d0:	e8 bf e8 ff ff       	call   f0100094 <_panic>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01017d5:	68 33 66 10 f0       	push   $0xf0106633
f01017da:	68 92 64 10 f0       	push   $0xf0106492
f01017df:	68 39 03 00 00       	push   $0x339
f01017e4:	68 65 64 10 f0       	push   $0xf0106465
f01017e9:	e8 a6 e8 ff ff       	call   f0100094 <_panic>
	assert(pp && pp0 == pp);
f01017ee:	68 51 66 10 f0       	push   $0xf0106651
f01017f3:	68 92 64 10 f0       	push   $0xf0106492
f01017f8:	68 3a 03 00 00       	push   $0x33a
f01017fd:	68 65 64 10 f0       	push   $0xf0106465
f0101802:	e8 8d e8 ff ff       	call   f0100094 <_panic>
f0101807:	50                   	push   %eax
f0101808:	68 14 56 10 f0       	push   $0xf0105614
f010180d:	6a 58                	push   $0x58
f010180f:	68 78 64 10 f0       	push   $0xf0106478
f0101814:	e8 7b e8 ff ff       	call   f0100094 <_panic>
		assert(c[i] == 0);
f0101819:	68 61 66 10 f0       	push   $0xf0106661
f010181e:	68 92 64 10 f0       	push   $0xf0106492
f0101823:	68 3d 03 00 00       	push   $0x33d
f0101828:	68 65 64 10 f0       	push   $0xf0106465
f010182d:	e8 62 e8 ff ff       	call   f0100094 <_panic>
		--nfree;
f0101832:	83 6d d4 01          	subl   $0x1,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101836:	8b 00                	mov    (%eax),%eax
f0101838:	85 c0                	test   %eax,%eax
f010183a:	75 f6                	jne    f0101832 <mem_init+0x557>
	assert(nfree == 0);
f010183c:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0101840:	0f 85 65 09 00 00    	jne    f01021ab <mem_init+0xed0>
	cprintf("check_page_alloc() succeeded!\n");
f0101846:	83 ec 0c             	sub    $0xc,%esp
f0101849:	68 e0 5c 10 f0       	push   $0xf0105ce0
f010184e:	e8 5a 1f 00 00       	call   f01037ad <cprintf>
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
f0101867:	0f 84 57 09 00 00    	je     f01021c4 <mem_init+0xee9>
	assert((pp1 = page_alloc(0)));
f010186d:	83 ec 0c             	sub    $0xc,%esp
f0101870:	6a 00                	push   $0x0
f0101872:	e8 da f6 ff ff       	call   f0100f51 <page_alloc>
f0101877:	89 c7                	mov    %eax,%edi
f0101879:	83 c4 10             	add    $0x10,%esp
f010187c:	85 c0                	test   %eax,%eax
f010187e:	0f 84 59 09 00 00    	je     f01021dd <mem_init+0xf02>
	assert((pp2 = page_alloc(0)));
f0101884:	83 ec 0c             	sub    $0xc,%esp
f0101887:	6a 00                	push   $0x0
f0101889:	e8 c3 f6 ff ff       	call   f0100f51 <page_alloc>
f010188e:	89 c3                	mov    %eax,%ebx
f0101890:	83 c4 10             	add    $0x10,%esp
f0101893:	85 c0                	test   %eax,%eax
f0101895:	0f 84 5b 09 00 00    	je     f01021f6 <mem_init+0xf1b>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010189b:	39 7d d4             	cmp    %edi,-0x2c(%ebp)
f010189e:	0f 84 6b 09 00 00    	je     f010220f <mem_init+0xf34>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01018a4:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f01018a7:	0f 84 7b 09 00 00    	je     f0102228 <mem_init+0xf4d>
f01018ad:	39 c7                	cmp    %eax,%edi
f01018af:	0f 84 73 09 00 00    	je     f0102228 <mem_init+0xf4d>

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
f01018d6:	0f 85 65 09 00 00    	jne    f0102241 <mem_init+0xf66>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f01018dc:	83 ec 04             	sub    $0x4,%esp
f01018df:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01018e2:	50                   	push   %eax
f01018e3:	6a 00                	push   $0x0
f01018e5:	ff 35 8c 1e 23 f0    	pushl  0xf0231e8c
f01018eb:	e8 4b f8 ff ff       	call   f010113b <page_lookup>
f01018f0:	83 c4 10             	add    $0x10,%esp
f01018f3:	85 c0                	test   %eax,%eax
f01018f5:	0f 85 5f 09 00 00    	jne    f010225a <mem_init+0xf7f>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01018fb:	6a 02                	push   $0x2
f01018fd:	6a 00                	push   $0x0
f01018ff:	57                   	push   %edi
f0101900:	ff 35 8c 1e 23 f0    	pushl  0xf0231e8c
f0101906:	e8 07 f9 ff ff       	call   f0101212 <page_insert>
f010190b:	83 c4 10             	add    $0x10,%esp
f010190e:	85 c0                	test   %eax,%eax
f0101910:	0f 89 5d 09 00 00    	jns    f0102273 <mem_init+0xf98>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101916:	83 ec 0c             	sub    $0xc,%esp
f0101919:	ff 75 d4             	pushl  -0x2c(%ebp)
f010191c:	e8 a2 f6 ff ff       	call   f0100fc3 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101921:	6a 02                	push   $0x2
f0101923:	6a 00                	push   $0x0
f0101925:	57                   	push   %edi
f0101926:	ff 35 8c 1e 23 f0    	pushl  0xf0231e8c
f010192c:	e8 e1 f8 ff ff       	call   f0101212 <page_insert>
f0101931:	83 c4 20             	add    $0x20,%esp
f0101934:	85 c0                	test   %eax,%eax
f0101936:	0f 85 50 09 00 00    	jne    f010228c <mem_init+0xfb1>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010193c:	8b 35 8c 1e 23 f0    	mov    0xf0231e8c,%esi
	return (pp - pages) << PGSHIFT;
f0101942:	8b 0d 90 1e 23 f0    	mov    0xf0231e90,%ecx
f0101948:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f010194b:	8b 16                	mov    (%esi),%edx
f010194d:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101953:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101956:	29 c8                	sub    %ecx,%eax
f0101958:	c1 f8 03             	sar    $0x3,%eax
f010195b:	c1 e0 0c             	shl    $0xc,%eax
f010195e:	39 c2                	cmp    %eax,%edx
f0101960:	0f 85 3f 09 00 00    	jne    f01022a5 <mem_init+0xfca>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101966:	ba 00 00 00 00       	mov    $0x0,%edx
f010196b:	89 f0                	mov    %esi,%eax
f010196d:	e8 70 f1 ff ff       	call   f0100ae2 <check_va2pa>
f0101972:	89 fa                	mov    %edi,%edx
f0101974:	2b 55 d0             	sub    -0x30(%ebp),%edx
f0101977:	c1 fa 03             	sar    $0x3,%edx
f010197a:	c1 e2 0c             	shl    $0xc,%edx
f010197d:	39 d0                	cmp    %edx,%eax
f010197f:	0f 85 39 09 00 00    	jne    f01022be <mem_init+0xfe3>
	assert(pp1->pp_ref == 1);
f0101985:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f010198a:	0f 85 47 09 00 00    	jne    f01022d7 <mem_init+0xffc>
	assert(pp0->pp_ref == 1);
f0101990:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101993:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101998:	0f 85 52 09 00 00    	jne    f01022f0 <mem_init+0x1015>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010199e:	6a 02                	push   $0x2
f01019a0:	68 00 10 00 00       	push   $0x1000
f01019a5:	53                   	push   %ebx
f01019a6:	56                   	push   %esi
f01019a7:	e8 66 f8 ff ff       	call   f0101212 <page_insert>
f01019ac:	83 c4 10             	add    $0x10,%esp
f01019af:	85 c0                	test   %eax,%eax
f01019b1:	0f 85 52 09 00 00    	jne    f0102309 <mem_init+0x102e>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01019b7:	ba 00 10 00 00       	mov    $0x1000,%edx
f01019bc:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f01019c1:	e8 1c f1 ff ff       	call   f0100ae2 <check_va2pa>
f01019c6:	89 da                	mov    %ebx,%edx
f01019c8:	2b 15 90 1e 23 f0    	sub    0xf0231e90,%edx
f01019ce:	c1 fa 03             	sar    $0x3,%edx
f01019d1:	c1 e2 0c             	shl    $0xc,%edx
f01019d4:	39 d0                	cmp    %edx,%eax
f01019d6:	0f 85 46 09 00 00    	jne    f0102322 <mem_init+0x1047>
	assert(pp2->pp_ref == 1);
f01019dc:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01019e1:	0f 85 54 09 00 00    	jne    f010233b <mem_init+0x1060>

	// should be no free memory
	assert(!page_alloc(0));
f01019e7:	83 ec 0c             	sub    $0xc,%esp
f01019ea:	6a 00                	push   $0x0
f01019ec:	e8 60 f5 ff ff       	call   f0100f51 <page_alloc>
f01019f1:	83 c4 10             	add    $0x10,%esp
f01019f4:	85 c0                	test   %eax,%eax
f01019f6:	0f 85 58 09 00 00    	jne    f0102354 <mem_init+0x1079>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01019fc:	6a 02                	push   $0x2
f01019fe:	68 00 10 00 00       	push   $0x1000
f0101a03:	53                   	push   %ebx
f0101a04:	ff 35 8c 1e 23 f0    	pushl  0xf0231e8c
f0101a0a:	e8 03 f8 ff ff       	call   f0101212 <page_insert>
f0101a0f:	83 c4 10             	add    $0x10,%esp
f0101a12:	85 c0                	test   %eax,%eax
f0101a14:	0f 85 53 09 00 00    	jne    f010236d <mem_init+0x1092>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101a1a:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101a1f:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f0101a24:	e8 b9 f0 ff ff       	call   f0100ae2 <check_va2pa>
f0101a29:	89 da                	mov    %ebx,%edx
f0101a2b:	2b 15 90 1e 23 f0    	sub    0xf0231e90,%edx
f0101a31:	c1 fa 03             	sar    $0x3,%edx
f0101a34:	c1 e2 0c             	shl    $0xc,%edx
f0101a37:	39 d0                	cmp    %edx,%eax
f0101a39:	0f 85 47 09 00 00    	jne    f0102386 <mem_init+0x10ab>
	assert(pp2->pp_ref == 1);
f0101a3f:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101a44:	0f 85 55 09 00 00    	jne    f010239f <mem_init+0x10c4>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101a4a:	83 ec 0c             	sub    $0xc,%esp
f0101a4d:	6a 00                	push   $0x0
f0101a4f:	e8 fd f4 ff ff       	call   f0100f51 <page_alloc>
f0101a54:	83 c4 10             	add    $0x10,%esp
f0101a57:	85 c0                	test   %eax,%eax
f0101a59:	0f 85 59 09 00 00    	jne    f01023b8 <mem_init+0x10dd>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101a5f:	8b 15 8c 1e 23 f0    	mov    0xf0231e8c,%edx
f0101a65:	8b 02                	mov    (%edx),%eax
f0101a67:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0101a6c:	89 c1                	mov    %eax,%ecx
f0101a6e:	c1 e9 0c             	shr    $0xc,%ecx
f0101a71:	3b 0d 88 1e 23 f0    	cmp    0xf0231e88,%ecx
f0101a77:	0f 83 54 09 00 00    	jae    f01023d1 <mem_init+0x10f6>
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
f0101aa0:	0f 85 40 09 00 00    	jne    f01023e6 <mem_init+0x110b>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101aa6:	6a 06                	push   $0x6
f0101aa8:	68 00 10 00 00       	push   $0x1000
f0101aad:	53                   	push   %ebx
f0101aae:	ff 35 8c 1e 23 f0    	pushl  0xf0231e8c
f0101ab4:	e8 59 f7 ff ff       	call   f0101212 <page_insert>
f0101ab9:	83 c4 10             	add    $0x10,%esp
f0101abc:	85 c0                	test   %eax,%eax
f0101abe:	0f 85 3b 09 00 00    	jne    f01023ff <mem_init+0x1124>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101ac4:	8b 35 8c 1e 23 f0    	mov    0xf0231e8c,%esi
f0101aca:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101acf:	89 f0                	mov    %esi,%eax
f0101ad1:	e8 0c f0 ff ff       	call   f0100ae2 <check_va2pa>
	return (pp - pages) << PGSHIFT;
f0101ad6:	89 da                	mov    %ebx,%edx
f0101ad8:	2b 15 90 1e 23 f0    	sub    0xf0231e90,%edx
f0101ade:	c1 fa 03             	sar    $0x3,%edx
f0101ae1:	c1 e2 0c             	shl    $0xc,%edx
f0101ae4:	39 d0                	cmp    %edx,%eax
f0101ae6:	0f 85 2c 09 00 00    	jne    f0102418 <mem_init+0x113d>
	assert(pp2->pp_ref == 1);
f0101aec:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101af1:	0f 85 3a 09 00 00    	jne    f0102431 <mem_init+0x1156>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101af7:	83 ec 04             	sub    $0x4,%esp
f0101afa:	6a 00                	push   $0x0
f0101afc:	68 00 10 00 00       	push   $0x1000
f0101b01:	56                   	push   %esi
f0101b02:	e8 20 f5 ff ff       	call   f0101027 <pgdir_walk>
f0101b07:	83 c4 10             	add    $0x10,%esp
f0101b0a:	f6 00 04             	testb  $0x4,(%eax)
f0101b0d:	0f 84 37 09 00 00    	je     f010244a <mem_init+0x116f>
	assert(kern_pgdir[0] & PTE_U);
f0101b13:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f0101b18:	f6 00 04             	testb  $0x4,(%eax)
f0101b1b:	0f 84 42 09 00 00    	je     f0102463 <mem_init+0x1188>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101b21:	6a 02                	push   $0x2
f0101b23:	68 00 10 00 00       	push   $0x1000
f0101b28:	53                   	push   %ebx
f0101b29:	50                   	push   %eax
f0101b2a:	e8 e3 f6 ff ff       	call   f0101212 <page_insert>
f0101b2f:	83 c4 10             	add    $0x10,%esp
f0101b32:	85 c0                	test   %eax,%eax
f0101b34:	0f 85 42 09 00 00    	jne    f010247c <mem_init+0x11a1>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101b3a:	83 ec 04             	sub    $0x4,%esp
f0101b3d:	6a 00                	push   $0x0
f0101b3f:	68 00 10 00 00       	push   $0x1000
f0101b44:	ff 35 8c 1e 23 f0    	pushl  0xf0231e8c
f0101b4a:	e8 d8 f4 ff ff       	call   f0101027 <pgdir_walk>
f0101b4f:	83 c4 10             	add    $0x10,%esp
f0101b52:	f6 00 02             	testb  $0x2,(%eax)
f0101b55:	0f 84 3a 09 00 00    	je     f0102495 <mem_init+0x11ba>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101b5b:	83 ec 04             	sub    $0x4,%esp
f0101b5e:	6a 00                	push   $0x0
f0101b60:	68 00 10 00 00       	push   $0x1000
f0101b65:	ff 35 8c 1e 23 f0    	pushl  0xf0231e8c
f0101b6b:	e8 b7 f4 ff ff       	call   f0101027 <pgdir_walk>
f0101b70:	83 c4 10             	add    $0x10,%esp
f0101b73:	f6 00 04             	testb  $0x4,(%eax)
f0101b76:	0f 85 32 09 00 00    	jne    f01024ae <mem_init+0x11d3>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101b7c:	6a 02                	push   $0x2
f0101b7e:	68 00 00 40 00       	push   $0x400000
f0101b83:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101b86:	ff 35 8c 1e 23 f0    	pushl  0xf0231e8c
f0101b8c:	e8 81 f6 ff ff       	call   f0101212 <page_insert>
f0101b91:	83 c4 10             	add    $0x10,%esp
f0101b94:	85 c0                	test   %eax,%eax
f0101b96:	0f 89 2b 09 00 00    	jns    f01024c7 <mem_init+0x11ec>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101b9c:	6a 02                	push   $0x2
f0101b9e:	68 00 10 00 00       	push   $0x1000
f0101ba3:	57                   	push   %edi
f0101ba4:	ff 35 8c 1e 23 f0    	pushl  0xf0231e8c
f0101baa:	e8 63 f6 ff ff       	call   f0101212 <page_insert>
f0101baf:	83 c4 10             	add    $0x10,%esp
f0101bb2:	85 c0                	test   %eax,%eax
f0101bb4:	0f 85 26 09 00 00    	jne    f01024e0 <mem_init+0x1205>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101bba:	83 ec 04             	sub    $0x4,%esp
f0101bbd:	6a 00                	push   $0x0
f0101bbf:	68 00 10 00 00       	push   $0x1000
f0101bc4:	ff 35 8c 1e 23 f0    	pushl  0xf0231e8c
f0101bca:	e8 58 f4 ff ff       	call   f0101027 <pgdir_walk>
f0101bcf:	83 c4 10             	add    $0x10,%esp
f0101bd2:	f6 00 04             	testb  $0x4,(%eax)
f0101bd5:	0f 85 1e 09 00 00    	jne    f01024f9 <mem_init+0x121e>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101bdb:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f0101be0:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101be3:	ba 00 00 00 00       	mov    $0x0,%edx
f0101be8:	e8 f5 ee ff ff       	call   f0100ae2 <check_va2pa>
f0101bed:	89 fe                	mov    %edi,%esi
f0101bef:	2b 35 90 1e 23 f0    	sub    0xf0231e90,%esi
f0101bf5:	c1 fe 03             	sar    $0x3,%esi
f0101bf8:	c1 e6 0c             	shl    $0xc,%esi
f0101bfb:	39 f0                	cmp    %esi,%eax
f0101bfd:	0f 85 0f 09 00 00    	jne    f0102512 <mem_init+0x1237>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101c03:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c08:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101c0b:	e8 d2 ee ff ff       	call   f0100ae2 <check_va2pa>
f0101c10:	39 c6                	cmp    %eax,%esi
f0101c12:	0f 85 13 09 00 00    	jne    f010252b <mem_init+0x1250>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101c18:	66 83 7f 04 02       	cmpw   $0x2,0x4(%edi)
f0101c1d:	0f 85 21 09 00 00    	jne    f0102544 <mem_init+0x1269>
	assert(pp2->pp_ref == 0);
f0101c23:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101c28:	0f 85 2f 09 00 00    	jne    f010255d <mem_init+0x1282>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101c2e:	83 ec 0c             	sub    $0xc,%esp
f0101c31:	6a 00                	push   $0x0
f0101c33:	e8 19 f3 ff ff       	call   f0100f51 <page_alloc>
f0101c38:	83 c4 10             	add    $0x10,%esp
f0101c3b:	85 c0                	test   %eax,%eax
f0101c3d:	0f 84 33 09 00 00    	je     f0102576 <mem_init+0x129b>
f0101c43:	39 c3                	cmp    %eax,%ebx
f0101c45:	0f 85 2b 09 00 00    	jne    f0102576 <mem_init+0x129b>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101c4b:	83 ec 08             	sub    $0x8,%esp
f0101c4e:	6a 00                	push   $0x0
f0101c50:	ff 35 8c 1e 23 f0    	pushl  0xf0231e8c
f0101c56:	e8 71 f5 ff ff       	call   f01011cc <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101c5b:	8b 35 8c 1e 23 f0    	mov    0xf0231e8c,%esi
f0101c61:	ba 00 00 00 00       	mov    $0x0,%edx
f0101c66:	89 f0                	mov    %esi,%eax
f0101c68:	e8 75 ee ff ff       	call   f0100ae2 <check_va2pa>
f0101c6d:	83 c4 10             	add    $0x10,%esp
f0101c70:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101c73:	0f 85 16 09 00 00    	jne    f010258f <mem_init+0x12b4>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101c79:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c7e:	89 f0                	mov    %esi,%eax
f0101c80:	e8 5d ee ff ff       	call   f0100ae2 <check_va2pa>
f0101c85:	89 fa                	mov    %edi,%edx
f0101c87:	2b 15 90 1e 23 f0    	sub    0xf0231e90,%edx
f0101c8d:	c1 fa 03             	sar    $0x3,%edx
f0101c90:	c1 e2 0c             	shl    $0xc,%edx
f0101c93:	39 d0                	cmp    %edx,%eax
f0101c95:	0f 85 0d 09 00 00    	jne    f01025a8 <mem_init+0x12cd>
	assert(pp1->pp_ref == 1);
f0101c9b:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101ca0:	0f 85 1b 09 00 00    	jne    f01025c1 <mem_init+0x12e6>
	assert(pp2->pp_ref == 0);
f0101ca6:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101cab:	0f 85 29 09 00 00    	jne    f01025da <mem_init+0x12ff>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101cb1:	6a 00                	push   $0x0
f0101cb3:	68 00 10 00 00       	push   $0x1000
f0101cb8:	57                   	push   %edi
f0101cb9:	56                   	push   %esi
f0101cba:	e8 53 f5 ff ff       	call   f0101212 <page_insert>
f0101cbf:	83 c4 10             	add    $0x10,%esp
f0101cc2:	85 c0                	test   %eax,%eax
f0101cc4:	0f 85 29 09 00 00    	jne    f01025f3 <mem_init+0x1318>
	assert(pp1->pp_ref);
f0101cca:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101ccf:	0f 84 37 09 00 00    	je     f010260c <mem_init+0x1331>
	assert(pp1->pp_link == NULL);
f0101cd5:	83 3f 00             	cmpl   $0x0,(%edi)
f0101cd8:	0f 85 47 09 00 00    	jne    f0102625 <mem_init+0x134a>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101cde:	83 ec 08             	sub    $0x8,%esp
f0101ce1:	68 00 10 00 00       	push   $0x1000
f0101ce6:	ff 35 8c 1e 23 f0    	pushl  0xf0231e8c
f0101cec:	e8 db f4 ff ff       	call   f01011cc <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101cf1:	8b 35 8c 1e 23 f0    	mov    0xf0231e8c,%esi
f0101cf7:	ba 00 00 00 00       	mov    $0x0,%edx
f0101cfc:	89 f0                	mov    %esi,%eax
f0101cfe:	e8 df ed ff ff       	call   f0100ae2 <check_va2pa>
f0101d03:	83 c4 10             	add    $0x10,%esp
f0101d06:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101d09:	0f 85 2f 09 00 00    	jne    f010263e <mem_init+0x1363>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101d0f:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d14:	89 f0                	mov    %esi,%eax
f0101d16:	e8 c7 ed ff ff       	call   f0100ae2 <check_va2pa>
f0101d1b:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101d1e:	0f 85 33 09 00 00    	jne    f0102657 <mem_init+0x137c>
	assert(pp1->pp_ref == 0);
f0101d24:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101d29:	0f 85 41 09 00 00    	jne    f0102670 <mem_init+0x1395>
	assert(pp2->pp_ref == 0);
f0101d2f:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101d34:	0f 85 4f 09 00 00    	jne    f0102689 <mem_init+0x13ae>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101d3a:	83 ec 0c             	sub    $0xc,%esp
f0101d3d:	6a 00                	push   $0x0
f0101d3f:	e8 0d f2 ff ff       	call   f0100f51 <page_alloc>
f0101d44:	83 c4 10             	add    $0x10,%esp
f0101d47:	39 c7                	cmp    %eax,%edi
f0101d49:	0f 85 53 09 00 00    	jne    f01026a2 <mem_init+0x13c7>
f0101d4f:	85 c0                	test   %eax,%eax
f0101d51:	0f 84 4b 09 00 00    	je     f01026a2 <mem_init+0x13c7>

	// should be no free memory
	assert(!page_alloc(0));
f0101d57:	83 ec 0c             	sub    $0xc,%esp
f0101d5a:	6a 00                	push   $0x0
f0101d5c:	e8 f0 f1 ff ff       	call   f0100f51 <page_alloc>
f0101d61:	83 c4 10             	add    $0x10,%esp
f0101d64:	85 c0                	test   %eax,%eax
f0101d66:	0f 85 4f 09 00 00    	jne    f01026bb <mem_init+0x13e0>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101d6c:	8b 0d 8c 1e 23 f0    	mov    0xf0231e8c,%ecx
f0101d72:	8b 11                	mov    (%ecx),%edx
f0101d74:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101d7a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d7d:	2b 05 90 1e 23 f0    	sub    0xf0231e90,%eax
f0101d83:	c1 f8 03             	sar    $0x3,%eax
f0101d86:	c1 e0 0c             	shl    $0xc,%eax
f0101d89:	39 c2                	cmp    %eax,%edx
f0101d8b:	0f 85 43 09 00 00    	jne    f01026d4 <mem_init+0x13f9>
	kern_pgdir[0] = 0;
f0101d91:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0101d97:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d9a:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101d9f:	0f 85 48 09 00 00    	jne    f01026ed <mem_init+0x1412>
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
f0101dc1:	ff 35 8c 1e 23 f0    	pushl  0xf0231e8c
f0101dc7:	e8 5b f2 ff ff       	call   f0101027 <pgdir_walk>
f0101dcc:	89 c1                	mov    %eax,%ecx
f0101dce:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0101dd1:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f0101dd6:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101dd9:	8b 40 04             	mov    0x4(%eax),%eax
f0101ddc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0101de1:	8b 35 88 1e 23 f0    	mov    0xf0231e88,%esi
f0101de7:	89 c2                	mov    %eax,%edx
f0101de9:	c1 ea 0c             	shr    $0xc,%edx
f0101dec:	83 c4 10             	add    $0x10,%esp
f0101def:	39 f2                	cmp    %esi,%edx
f0101df1:	0f 83 0f 09 00 00    	jae    f0102706 <mem_init+0x142b>
	assert(ptep == ptep1 + PTX(va));
f0101df7:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f0101dfc:	39 c1                	cmp    %eax,%ecx
f0101dfe:	0f 85 17 09 00 00    	jne    f010271b <mem_init+0x1440>
	kern_pgdir[PDX(va)] = 0;
f0101e04:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101e07:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f0101e0e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e11:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f0101e17:	2b 05 90 1e 23 f0    	sub    0xf0231e90,%eax
f0101e1d:	c1 f8 03             	sar    $0x3,%eax
f0101e20:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0101e23:	89 c2                	mov    %eax,%edx
f0101e25:	c1 ea 0c             	shr    $0xc,%edx
f0101e28:	39 d6                	cmp    %edx,%esi
f0101e2a:	0f 86 04 09 00 00    	jbe    f0102734 <mem_init+0x1459>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0101e30:	83 ec 04             	sub    $0x4,%esp
f0101e33:	68 00 10 00 00       	push   $0x1000
f0101e38:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f0101e3d:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101e42:	50                   	push   %eax
f0101e43:	e8 c2 2a 00 00       	call   f010490a <memset>
	page_free(pp0);
f0101e48:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0101e4b:	89 34 24             	mov    %esi,(%esp)
f0101e4e:	e8 70 f1 ff ff       	call   f0100fc3 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0101e53:	83 c4 0c             	add    $0xc,%esp
f0101e56:	6a 01                	push   $0x1
f0101e58:	6a 00                	push   $0x0
f0101e5a:	ff 35 8c 1e 23 f0    	pushl  0xf0231e8c
f0101e60:	e8 c2 f1 ff ff       	call   f0101027 <pgdir_walk>
	return (pp - pages) << PGSHIFT;
f0101e65:	89 f0                	mov    %esi,%eax
f0101e67:	2b 05 90 1e 23 f0    	sub    0xf0231e90,%eax
f0101e6d:	c1 f8 03             	sar    $0x3,%eax
f0101e70:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0101e73:	89 c2                	mov    %eax,%edx
f0101e75:	c1 ea 0c             	shr    $0xc,%edx
f0101e78:	83 c4 10             	add    $0x10,%esp
f0101e7b:	3b 15 88 1e 23 f0    	cmp    0xf0231e88,%edx
f0101e81:	0f 83 bf 08 00 00    	jae    f0102746 <mem_init+0x146b>
	return (void *)(pa + KERNBASE);
f0101e87:	8d 90 00 00 00 f0    	lea    -0x10000000(%eax),%edx
	ptep = (pte_t *) page2kva(pp0);
f0101e8d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0101e90:	2d 00 f0 ff 0f       	sub    $0xffff000,%eax
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0101e95:	f6 02 01             	testb  $0x1,(%edx)
f0101e98:	0f 85 ba 08 00 00    	jne    f0102758 <mem_init+0x147d>
f0101e9e:	83 c2 04             	add    $0x4,%edx
	for(i=0; i<NPTENTRIES; i++)
f0101ea1:	39 c2                	cmp    %eax,%edx
f0101ea3:	75 f0                	jne    f0101e95 <mem_init+0xbba>
	kern_pgdir[0] = 0;
f0101ea5:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
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
f0101f0c:	0f 86 5f 08 00 00    	jbe    f0102771 <mem_init+0x1496>
f0101f12:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0101f17:	0f 87 54 08 00 00    	ja     f0102771 <mem_init+0x1496>
	assert(mm2 >= MMIOBASE && mm2 + 8192 < MMIOLIM);
f0101f1d:	8d 96 00 20 00 00    	lea    0x2000(%esi),%edx
f0101f23:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f0101f29:	0f 87 5b 08 00 00    	ja     f010278a <mem_init+0x14af>
f0101f2f:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0101f35:	0f 86 4f 08 00 00    	jbe    f010278a <mem_init+0x14af>
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0101f3b:	89 da                	mov    %ebx,%edx
f0101f3d:	09 f2                	or     %esi,%edx
f0101f3f:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0101f45:	0f 85 58 08 00 00    	jne    f01027a3 <mem_init+0x14c8>
	// check that they don't overlap
	assert(mm1 + 8192 <= mm2);
f0101f4b:	39 c6                	cmp    %eax,%esi
f0101f4d:	0f 82 69 08 00 00    	jb     f01027bc <mem_init+0x14e1>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0101f53:	8b 3d 8c 1e 23 f0    	mov    0xf0231e8c,%edi
f0101f59:	89 da                	mov    %ebx,%edx
f0101f5b:	89 f8                	mov    %edi,%eax
f0101f5d:	e8 80 eb ff ff       	call   f0100ae2 <check_va2pa>
f0101f62:	85 c0                	test   %eax,%eax
f0101f64:	0f 85 6b 08 00 00    	jne    f01027d5 <mem_init+0x14fa>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0101f6a:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f0101f70:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101f73:	89 c2                	mov    %eax,%edx
f0101f75:	89 f8                	mov    %edi,%eax
f0101f77:	e8 66 eb ff ff       	call   f0100ae2 <check_va2pa>
f0101f7c:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0101f81:	0f 85 67 08 00 00    	jne    f01027ee <mem_init+0x1513>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0101f87:	89 f2                	mov    %esi,%edx
f0101f89:	89 f8                	mov    %edi,%eax
f0101f8b:	e8 52 eb ff ff       	call   f0100ae2 <check_va2pa>
f0101f90:	85 c0                	test   %eax,%eax
f0101f92:	0f 85 6f 08 00 00    	jne    f0102807 <mem_init+0x152c>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0101f98:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f0101f9e:	89 f8                	mov    %edi,%eax
f0101fa0:	e8 3d eb ff ff       	call   f0100ae2 <check_va2pa>
f0101fa5:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101fa8:	0f 85 72 08 00 00    	jne    f0102820 <mem_init+0x1545>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f0101fae:	83 ec 04             	sub    $0x4,%esp
f0101fb1:	6a 00                	push   $0x0
f0101fb3:	53                   	push   %ebx
f0101fb4:	57                   	push   %edi
f0101fb5:	e8 6d f0 ff ff       	call   f0101027 <pgdir_walk>
f0101fba:	83 c4 10             	add    $0x10,%esp
f0101fbd:	f6 00 1a             	testb  $0x1a,(%eax)
f0101fc0:	0f 84 73 08 00 00    	je     f0102839 <mem_init+0x155e>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0101fc6:	83 ec 04             	sub    $0x4,%esp
f0101fc9:	6a 00                	push   $0x0
f0101fcb:	53                   	push   %ebx
f0101fcc:	ff 35 8c 1e 23 f0    	pushl  0xf0231e8c
f0101fd2:	e8 50 f0 ff ff       	call   f0101027 <pgdir_walk>
f0101fd7:	83 c4 10             	add    $0x10,%esp
f0101fda:	f6 00 04             	testb  $0x4,(%eax)
f0101fdd:	0f 85 6f 08 00 00    	jne    f0102852 <mem_init+0x1577>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f0101fe3:	83 ec 04             	sub    $0x4,%esp
f0101fe6:	6a 00                	push   $0x0
f0101fe8:	53                   	push   %ebx
f0101fe9:	ff 35 8c 1e 23 f0    	pushl  0xf0231e8c
f0101fef:	e8 33 f0 ff ff       	call   f0101027 <pgdir_walk>
f0101ff4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f0101ffa:	83 c4 0c             	add    $0xc,%esp
f0101ffd:	6a 00                	push   $0x0
f0101fff:	ff 75 d4             	pushl  -0x2c(%ebp)
f0102002:	ff 35 8c 1e 23 f0    	pushl  0xf0231e8c
f0102008:	e8 1a f0 ff ff       	call   f0101027 <pgdir_walk>
f010200d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f0102013:	83 c4 0c             	add    $0xc,%esp
f0102016:	6a 00                	push   $0x0
f0102018:	56                   	push   %esi
f0102019:	ff 35 8c 1e 23 f0    	pushl  0xf0231e8c
f010201f:	e8 03 f0 ff ff       	call   f0101027 <pgdir_walk>
f0102024:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f010202a:	c7 04 24 54 67 10 f0 	movl   $0xf0106754,(%esp)
f0102031:	e8 77 17 00 00       	call   f01037ad <cprintf>
	boot_map_region(kern_pgdir, (uintptr_t) UPAGES, npages*sizeof(struct PageInfo), PADDR(pages), PTE_U | PTE_P);
f0102036:	a1 90 1e 23 f0       	mov    0xf0231e90,%eax
	if ((uint32_t)kva < KERNBASE)
f010203b:	83 c4 10             	add    $0x10,%esp
f010203e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102043:	0f 86 22 08 00 00    	jbe    f010286b <mem_init+0x1590>
f0102049:	8b 0d 88 1e 23 f0    	mov    0xf0231e88,%ecx
f010204f:	c1 e1 03             	shl    $0x3,%ecx
f0102052:	83 ec 08             	sub    $0x8,%esp
f0102055:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f0102057:	05 00 00 00 10       	add    $0x10000000,%eax
f010205c:	50                   	push   %eax
f010205d:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102062:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f0102067:	e8 7b f0 ff ff       	call   f01010e7 <boot_map_region>
	boot_map_region(kern_pgdir, (uintptr_t) UENVS, ROUNDUP(NENV * sizeof(struct Env), PGSIZE), PADDR(envs), PTE_U | PTE_P);
f010206c:	a1 44 12 23 f0       	mov    0xf0231244,%eax
	if ((uint32_t)kva < KERNBASE)
f0102071:	83 c4 10             	add    $0x10,%esp
f0102074:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102079:	0f 86 01 08 00 00    	jbe    f0102880 <mem_init+0x15a5>
f010207f:	83 ec 08             	sub    $0x8,%esp
f0102082:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f0102084:	05 00 00 00 10       	add    $0x10000000,%eax
f0102089:	50                   	push   %eax
f010208a:	b9 00 f0 01 00       	mov    $0x1f000,%ecx
f010208f:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102094:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f0102099:	e8 49 f0 ff ff       	call   f01010e7 <boot_map_region>
	if ((uint32_t)kva < KERNBASE)
f010209e:	83 c4 10             	add    $0x10,%esp
f01020a1:	b8 00 70 11 f0       	mov    $0xf0117000,%eax
f01020a6:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01020ab:	0f 86 e4 07 00 00    	jbe    f0102895 <mem_init+0x15ba>
	boot_map_region(kern_pgdir, (uintptr_t) (KSTACKTOP-KSTKSIZE), KSTKSIZE, PADDR(bootstack), PTE_W | PTE_P);
f01020b1:	83 ec 08             	sub    $0x8,%esp
f01020b4:	6a 03                	push   $0x3
f01020b6:	68 00 70 11 00       	push   $0x117000
f01020bb:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01020c0:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f01020c5:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f01020ca:	e8 18 f0 ff ff       	call   f01010e7 <boot_map_region>
	boot_map_region(kern_pgdir, (uintptr_t) KERNBASE, ROUNDUP(0xffffffff - KERNBASE, PGSIZE), 0, PTE_W | PTE_P);
f01020cf:	83 c4 08             	add    $0x8,%esp
f01020d2:	6a 03                	push   $0x3
f01020d4:	6a 00                	push   $0x0
f01020d6:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f01020db:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f01020e0:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f01020e5:	e8 fd ef ff ff       	call   f01010e7 <boot_map_region>
f01020ea:	c7 45 d0 00 30 23 f0 	movl   $0xf0233000,-0x30(%ebp)
f01020f1:	83 c4 10             	add    $0x10,%esp
f01020f4:	bb 00 30 23 f0       	mov    $0xf0233000,%ebx
    uintptr_t start_addr = KSTACKTOP - KSTKSIZE;    
f01020f9:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f01020fe:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102104:	0f 86 a0 07 00 00    	jbe    f01028aa <mem_init+0x15cf>
        boot_map_region(kern_pgdir, (uintptr_t) start_addr, KSTKSIZE, PADDR(percpu_kstacks[i]), PTE_W | PTE_P);
f010210a:	83 ec 08             	sub    $0x8,%esp
f010210d:	6a 03                	push   $0x3
f010210f:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f0102115:	50                   	push   %eax
f0102116:	b9 00 80 00 00       	mov    $0x8000,%ecx
f010211b:	89 f2                	mov    %esi,%edx
f010211d:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f0102122:	e8 c0 ef ff ff       	call   f01010e7 <boot_map_region>
        start_addr -= KSTKSIZE + KSTKGAP;
f0102127:	81 ee 00 00 01 00    	sub    $0x10000,%esi
f010212d:	81 c3 00 80 00 00    	add    $0x8000,%ebx
    for (size_t i = 0; i < NCPU; i++) {
f0102133:	83 c4 10             	add    $0x10,%esp
f0102136:	81 fe 00 80 f7 ef    	cmp    $0xeff78000,%esi
f010213c:	75 c0                	jne    f01020fe <mem_init+0xe23>
	pgdir = kern_pgdir;
f010213e:	8b 3d 8c 1e 23 f0    	mov    0xf0231e8c,%edi
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102144:	a1 88 1e 23 f0       	mov    0xf0231e88,%eax
f0102149:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f010214c:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0102153:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102158:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010215b:	8b 35 90 1e 23 f0    	mov    0xf0231e90,%esi
f0102161:	89 75 cc             	mov    %esi,-0x34(%ebp)
	return (physaddr_t)kva - KERNBASE;
f0102164:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f010216a:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (i = 0; i < n; i += PGSIZE)
f010216d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102172:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0102175:	0f 86 72 07 00 00    	jbe    f01028ed <mem_init+0x1612>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010217b:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f0102181:	89 f8                	mov    %edi,%eax
f0102183:	e8 5a e9 ff ff       	call   f0100ae2 <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f0102188:	81 7d cc ff ff ff ef 	cmpl   $0xefffffff,-0x34(%ebp)
f010218f:	0f 86 2a 07 00 00    	jbe    f01028bf <mem_init+0x15e4>
f0102195:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0102198:	8d 14 0b             	lea    (%ebx,%ecx,1),%edx
f010219b:	39 d0                	cmp    %edx,%eax
f010219d:	0f 85 31 07 00 00    	jne    f01028d4 <mem_init+0x15f9>
	for (i = 0; i < n; i += PGSIZE)
f01021a3:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01021a9:	eb c7                	jmp    f0102172 <mem_init+0xe97>
	assert(nfree == 0);
f01021ab:	68 6b 66 10 f0       	push   $0xf010666b
f01021b0:	68 92 64 10 f0       	push   $0xf0106492
f01021b5:	68 4a 03 00 00       	push   $0x34a
f01021ba:	68 65 64 10 f0       	push   $0xf0106465
f01021bf:	e8 d0 de ff ff       	call   f0100094 <_panic>
	assert((pp0 = page_alloc(0)));
f01021c4:	68 79 65 10 f0       	push   $0xf0106579
f01021c9:	68 92 64 10 f0       	push   $0xf0106492
f01021ce:	68 b6 03 00 00       	push   $0x3b6
f01021d3:	68 65 64 10 f0       	push   $0xf0106465
f01021d8:	e8 b7 de ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f01021dd:	68 8f 65 10 f0       	push   $0xf010658f
f01021e2:	68 92 64 10 f0       	push   $0xf0106492
f01021e7:	68 b7 03 00 00       	push   $0x3b7
f01021ec:	68 65 64 10 f0       	push   $0xf0106465
f01021f1:	e8 9e de ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f01021f6:	68 a5 65 10 f0       	push   $0xf01065a5
f01021fb:	68 92 64 10 f0       	push   $0xf0106492
f0102200:	68 b8 03 00 00       	push   $0x3b8
f0102205:	68 65 64 10 f0       	push   $0xf0106465
f010220a:	e8 85 de ff ff       	call   f0100094 <_panic>
	assert(pp1 && pp1 != pp0);
f010220f:	68 bb 65 10 f0       	push   $0xf01065bb
f0102214:	68 92 64 10 f0       	push   $0xf0106492
f0102219:	68 bb 03 00 00       	push   $0x3bb
f010221e:	68 65 64 10 f0       	push   $0xf0106465
f0102223:	e8 6c de ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0102228:	68 c0 5c 10 f0       	push   $0xf0105cc0
f010222d:	68 92 64 10 f0       	push   $0xf0106492
f0102232:	68 bc 03 00 00       	push   $0x3bc
f0102237:	68 65 64 10 f0       	push   $0xf0106465
f010223c:	e8 53 de ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f0102241:	68 24 66 10 f0       	push   $0xf0106624
f0102246:	68 92 64 10 f0       	push   $0xf0106492
f010224b:	68 c3 03 00 00       	push   $0x3c3
f0102250:	68 65 64 10 f0       	push   $0xf0106465
f0102255:	e8 3a de ff ff       	call   f0100094 <_panic>
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f010225a:	68 00 5d 10 f0       	push   $0xf0105d00
f010225f:	68 92 64 10 f0       	push   $0xf0106492
f0102264:	68 c6 03 00 00       	push   $0x3c6
f0102269:	68 65 64 10 f0       	push   $0xf0106465
f010226e:	e8 21 de ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0102273:	68 38 5d 10 f0       	push   $0xf0105d38
f0102278:	68 92 64 10 f0       	push   $0xf0106492
f010227d:	68 c9 03 00 00       	push   $0x3c9
f0102282:	68 65 64 10 f0       	push   $0xf0106465
f0102287:	e8 08 de ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f010228c:	68 68 5d 10 f0       	push   $0xf0105d68
f0102291:	68 92 64 10 f0       	push   $0xf0106492
f0102296:	68 cd 03 00 00       	push   $0x3cd
f010229b:	68 65 64 10 f0       	push   $0xf0106465
f01022a0:	e8 ef dd ff ff       	call   f0100094 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01022a5:	68 98 5d 10 f0       	push   $0xf0105d98
f01022aa:	68 92 64 10 f0       	push   $0xf0106492
f01022af:	68 ce 03 00 00       	push   $0x3ce
f01022b4:	68 65 64 10 f0       	push   $0xf0106465
f01022b9:	e8 d6 dd ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f01022be:	68 c0 5d 10 f0       	push   $0xf0105dc0
f01022c3:	68 92 64 10 f0       	push   $0xf0106492
f01022c8:	68 cf 03 00 00       	push   $0x3cf
f01022cd:	68 65 64 10 f0       	push   $0xf0106465
f01022d2:	e8 bd dd ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 1);
f01022d7:	68 76 66 10 f0       	push   $0xf0106676
f01022dc:	68 92 64 10 f0       	push   $0xf0106492
f01022e1:	68 d0 03 00 00       	push   $0x3d0
f01022e6:	68 65 64 10 f0       	push   $0xf0106465
f01022eb:	e8 a4 dd ff ff       	call   f0100094 <_panic>
	assert(pp0->pp_ref == 1);
f01022f0:	68 87 66 10 f0       	push   $0xf0106687
f01022f5:	68 92 64 10 f0       	push   $0xf0106492
f01022fa:	68 d1 03 00 00       	push   $0x3d1
f01022ff:	68 65 64 10 f0       	push   $0xf0106465
f0102304:	e8 8b dd ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102309:	68 f0 5d 10 f0       	push   $0xf0105df0
f010230e:	68 92 64 10 f0       	push   $0xf0106492
f0102313:	68 d4 03 00 00       	push   $0x3d4
f0102318:	68 65 64 10 f0       	push   $0xf0106465
f010231d:	e8 72 dd ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102322:	68 2c 5e 10 f0       	push   $0xf0105e2c
f0102327:	68 92 64 10 f0       	push   $0xf0106492
f010232c:	68 d5 03 00 00       	push   $0x3d5
f0102331:	68 65 64 10 f0       	push   $0xf0106465
f0102336:	e8 59 dd ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f010233b:	68 98 66 10 f0       	push   $0xf0106698
f0102340:	68 92 64 10 f0       	push   $0xf0106492
f0102345:	68 d6 03 00 00       	push   $0x3d6
f010234a:	68 65 64 10 f0       	push   $0xf0106465
f010234f:	e8 40 dd ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f0102354:	68 24 66 10 f0       	push   $0xf0106624
f0102359:	68 92 64 10 f0       	push   $0xf0106492
f010235e:	68 d9 03 00 00       	push   $0x3d9
f0102363:	68 65 64 10 f0       	push   $0xf0106465
f0102368:	e8 27 dd ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010236d:	68 f0 5d 10 f0       	push   $0xf0105df0
f0102372:	68 92 64 10 f0       	push   $0xf0106492
f0102377:	68 dc 03 00 00       	push   $0x3dc
f010237c:	68 65 64 10 f0       	push   $0xf0106465
f0102381:	e8 0e dd ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102386:	68 2c 5e 10 f0       	push   $0xf0105e2c
f010238b:	68 92 64 10 f0       	push   $0xf0106492
f0102390:	68 dd 03 00 00       	push   $0x3dd
f0102395:	68 65 64 10 f0       	push   $0xf0106465
f010239a:	e8 f5 dc ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f010239f:	68 98 66 10 f0       	push   $0xf0106698
f01023a4:	68 92 64 10 f0       	push   $0xf0106492
f01023a9:	68 de 03 00 00       	push   $0x3de
f01023ae:	68 65 64 10 f0       	push   $0xf0106465
f01023b3:	e8 dc dc ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f01023b8:	68 24 66 10 f0       	push   $0xf0106624
f01023bd:	68 92 64 10 f0       	push   $0xf0106492
f01023c2:	68 e2 03 00 00       	push   $0x3e2
f01023c7:	68 65 64 10 f0       	push   $0xf0106465
f01023cc:	e8 c3 dc ff ff       	call   f0100094 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01023d1:	50                   	push   %eax
f01023d2:	68 14 56 10 f0       	push   $0xf0105614
f01023d7:	68 e5 03 00 00       	push   $0x3e5
f01023dc:	68 65 64 10 f0       	push   $0xf0106465
f01023e1:	e8 ae dc ff ff       	call   f0100094 <_panic>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f01023e6:	68 5c 5e 10 f0       	push   $0xf0105e5c
f01023eb:	68 92 64 10 f0       	push   $0xf0106492
f01023f0:	68 e6 03 00 00       	push   $0x3e6
f01023f5:	68 65 64 10 f0       	push   $0xf0106465
f01023fa:	e8 95 dc ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f01023ff:	68 9c 5e 10 f0       	push   $0xf0105e9c
f0102404:	68 92 64 10 f0       	push   $0xf0106492
f0102409:	68 e9 03 00 00       	push   $0x3e9
f010240e:	68 65 64 10 f0       	push   $0xf0106465
f0102413:	e8 7c dc ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102418:	68 2c 5e 10 f0       	push   $0xf0105e2c
f010241d:	68 92 64 10 f0       	push   $0xf0106492
f0102422:	68 ea 03 00 00       	push   $0x3ea
f0102427:	68 65 64 10 f0       	push   $0xf0106465
f010242c:	e8 63 dc ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f0102431:	68 98 66 10 f0       	push   $0xf0106698
f0102436:	68 92 64 10 f0       	push   $0xf0106492
f010243b:	68 eb 03 00 00       	push   $0x3eb
f0102440:	68 65 64 10 f0       	push   $0xf0106465
f0102445:	e8 4a dc ff ff       	call   f0100094 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f010244a:	68 dc 5e 10 f0       	push   $0xf0105edc
f010244f:	68 92 64 10 f0       	push   $0xf0106492
f0102454:	68 ec 03 00 00       	push   $0x3ec
f0102459:	68 65 64 10 f0       	push   $0xf0106465
f010245e:	e8 31 dc ff ff       	call   f0100094 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0102463:	68 a9 66 10 f0       	push   $0xf01066a9
f0102468:	68 92 64 10 f0       	push   $0xf0106492
f010246d:	68 ed 03 00 00       	push   $0x3ed
f0102472:	68 65 64 10 f0       	push   $0xf0106465
f0102477:	e8 18 dc ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010247c:	68 f0 5d 10 f0       	push   $0xf0105df0
f0102481:	68 92 64 10 f0       	push   $0xf0106492
f0102486:	68 f0 03 00 00       	push   $0x3f0
f010248b:	68 65 64 10 f0       	push   $0xf0106465
f0102490:	e8 ff db ff ff       	call   f0100094 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0102495:	68 10 5f 10 f0       	push   $0xf0105f10
f010249a:	68 92 64 10 f0       	push   $0xf0106492
f010249f:	68 f1 03 00 00       	push   $0x3f1
f01024a4:	68 65 64 10 f0       	push   $0xf0106465
f01024a9:	e8 e6 db ff ff       	call   f0100094 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01024ae:	68 44 5f 10 f0       	push   $0xf0105f44
f01024b3:	68 92 64 10 f0       	push   $0xf0106492
f01024b8:	68 f2 03 00 00       	push   $0x3f2
f01024bd:	68 65 64 10 f0       	push   $0xf0106465
f01024c2:	e8 cd db ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f01024c7:	68 7c 5f 10 f0       	push   $0xf0105f7c
f01024cc:	68 92 64 10 f0       	push   $0xf0106492
f01024d1:	68 f5 03 00 00       	push   $0x3f5
f01024d6:	68 65 64 10 f0       	push   $0xf0106465
f01024db:	e8 b4 db ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f01024e0:	68 b4 5f 10 f0       	push   $0xf0105fb4
f01024e5:	68 92 64 10 f0       	push   $0xf0106492
f01024ea:	68 f8 03 00 00       	push   $0x3f8
f01024ef:	68 65 64 10 f0       	push   $0xf0106465
f01024f4:	e8 9b db ff ff       	call   f0100094 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01024f9:	68 44 5f 10 f0       	push   $0xf0105f44
f01024fe:	68 92 64 10 f0       	push   $0xf0106492
f0102503:	68 f9 03 00 00       	push   $0x3f9
f0102508:	68 65 64 10 f0       	push   $0xf0106465
f010250d:	e8 82 db ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102512:	68 f0 5f 10 f0       	push   $0xf0105ff0
f0102517:	68 92 64 10 f0       	push   $0xf0106492
f010251c:	68 fc 03 00 00       	push   $0x3fc
f0102521:	68 65 64 10 f0       	push   $0xf0106465
f0102526:	e8 69 db ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010252b:	68 1c 60 10 f0       	push   $0xf010601c
f0102530:	68 92 64 10 f0       	push   $0xf0106492
f0102535:	68 fd 03 00 00       	push   $0x3fd
f010253a:	68 65 64 10 f0       	push   $0xf0106465
f010253f:	e8 50 db ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 2);
f0102544:	68 bf 66 10 f0       	push   $0xf01066bf
f0102549:	68 92 64 10 f0       	push   $0xf0106492
f010254e:	68 ff 03 00 00       	push   $0x3ff
f0102553:	68 65 64 10 f0       	push   $0xf0106465
f0102558:	e8 37 db ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f010255d:	68 d0 66 10 f0       	push   $0xf01066d0
f0102562:	68 92 64 10 f0       	push   $0xf0106492
f0102567:	68 00 04 00 00       	push   $0x400
f010256c:	68 65 64 10 f0       	push   $0xf0106465
f0102571:	e8 1e db ff ff       	call   f0100094 <_panic>
	assert((pp = page_alloc(0)) && pp == pp2);
f0102576:	68 4c 60 10 f0       	push   $0xf010604c
f010257b:	68 92 64 10 f0       	push   $0xf0106492
f0102580:	68 03 04 00 00       	push   $0x403
f0102585:	68 65 64 10 f0       	push   $0xf0106465
f010258a:	e8 05 db ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010258f:	68 70 60 10 f0       	push   $0xf0106070
f0102594:	68 92 64 10 f0       	push   $0xf0106492
f0102599:	68 07 04 00 00       	push   $0x407
f010259e:	68 65 64 10 f0       	push   $0xf0106465
f01025a3:	e8 ec da ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01025a8:	68 1c 60 10 f0       	push   $0xf010601c
f01025ad:	68 92 64 10 f0       	push   $0xf0106492
f01025b2:	68 08 04 00 00       	push   $0x408
f01025b7:	68 65 64 10 f0       	push   $0xf0106465
f01025bc:	e8 d3 da ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 1);
f01025c1:	68 76 66 10 f0       	push   $0xf0106676
f01025c6:	68 92 64 10 f0       	push   $0xf0106492
f01025cb:	68 09 04 00 00       	push   $0x409
f01025d0:	68 65 64 10 f0       	push   $0xf0106465
f01025d5:	e8 ba da ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f01025da:	68 d0 66 10 f0       	push   $0xf01066d0
f01025df:	68 92 64 10 f0       	push   $0xf0106492
f01025e4:	68 0a 04 00 00       	push   $0x40a
f01025e9:	68 65 64 10 f0       	push   $0xf0106465
f01025ee:	e8 a1 da ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f01025f3:	68 94 60 10 f0       	push   $0xf0106094
f01025f8:	68 92 64 10 f0       	push   $0xf0106492
f01025fd:	68 0d 04 00 00       	push   $0x40d
f0102602:	68 65 64 10 f0       	push   $0xf0106465
f0102607:	e8 88 da ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref);
f010260c:	68 e1 66 10 f0       	push   $0xf01066e1
f0102611:	68 92 64 10 f0       	push   $0xf0106492
f0102616:	68 0e 04 00 00       	push   $0x40e
f010261b:	68 65 64 10 f0       	push   $0xf0106465
f0102620:	e8 6f da ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_link == NULL);
f0102625:	68 ed 66 10 f0       	push   $0xf01066ed
f010262a:	68 92 64 10 f0       	push   $0xf0106492
f010262f:	68 0f 04 00 00       	push   $0x40f
f0102634:	68 65 64 10 f0       	push   $0xf0106465
f0102639:	e8 56 da ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010263e:	68 70 60 10 f0       	push   $0xf0106070
f0102643:	68 92 64 10 f0       	push   $0xf0106492
f0102648:	68 13 04 00 00       	push   $0x413
f010264d:	68 65 64 10 f0       	push   $0xf0106465
f0102652:	e8 3d da ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102657:	68 cc 60 10 f0       	push   $0xf01060cc
f010265c:	68 92 64 10 f0       	push   $0xf0106492
f0102661:	68 14 04 00 00       	push   $0x414
f0102666:	68 65 64 10 f0       	push   $0xf0106465
f010266b:	e8 24 da ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 0);
f0102670:	68 02 67 10 f0       	push   $0xf0106702
f0102675:	68 92 64 10 f0       	push   $0xf0106492
f010267a:	68 15 04 00 00       	push   $0x415
f010267f:	68 65 64 10 f0       	push   $0xf0106465
f0102684:	e8 0b da ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f0102689:	68 d0 66 10 f0       	push   $0xf01066d0
f010268e:	68 92 64 10 f0       	push   $0xf0106492
f0102693:	68 16 04 00 00       	push   $0x416
f0102698:	68 65 64 10 f0       	push   $0xf0106465
f010269d:	e8 f2 d9 ff ff       	call   f0100094 <_panic>
	assert((pp = page_alloc(0)) && pp == pp1);
f01026a2:	68 f4 60 10 f0       	push   $0xf01060f4
f01026a7:	68 92 64 10 f0       	push   $0xf0106492
f01026ac:	68 19 04 00 00       	push   $0x419
f01026b1:	68 65 64 10 f0       	push   $0xf0106465
f01026b6:	e8 d9 d9 ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f01026bb:	68 24 66 10 f0       	push   $0xf0106624
f01026c0:	68 92 64 10 f0       	push   $0xf0106492
f01026c5:	68 1c 04 00 00       	push   $0x41c
f01026ca:	68 65 64 10 f0       	push   $0xf0106465
f01026cf:	e8 c0 d9 ff ff       	call   f0100094 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01026d4:	68 98 5d 10 f0       	push   $0xf0105d98
f01026d9:	68 92 64 10 f0       	push   $0xf0106492
f01026de:	68 1f 04 00 00       	push   $0x41f
f01026e3:	68 65 64 10 f0       	push   $0xf0106465
f01026e8:	e8 a7 d9 ff ff       	call   f0100094 <_panic>
	assert(pp0->pp_ref == 1);
f01026ed:	68 87 66 10 f0       	push   $0xf0106687
f01026f2:	68 92 64 10 f0       	push   $0xf0106492
f01026f7:	68 21 04 00 00       	push   $0x421
f01026fc:	68 65 64 10 f0       	push   $0xf0106465
f0102701:	e8 8e d9 ff ff       	call   f0100094 <_panic>
f0102706:	50                   	push   %eax
f0102707:	68 14 56 10 f0       	push   $0xf0105614
f010270c:	68 28 04 00 00       	push   $0x428
f0102711:	68 65 64 10 f0       	push   $0xf0106465
f0102716:	e8 79 d9 ff ff       	call   f0100094 <_panic>
	assert(ptep == ptep1 + PTX(va));
f010271b:	68 13 67 10 f0       	push   $0xf0106713
f0102720:	68 92 64 10 f0       	push   $0xf0106492
f0102725:	68 29 04 00 00       	push   $0x429
f010272a:	68 65 64 10 f0       	push   $0xf0106465
f010272f:	e8 60 d9 ff ff       	call   f0100094 <_panic>
f0102734:	50                   	push   %eax
f0102735:	68 14 56 10 f0       	push   $0xf0105614
f010273a:	6a 58                	push   $0x58
f010273c:	68 78 64 10 f0       	push   $0xf0106478
f0102741:	e8 4e d9 ff ff       	call   f0100094 <_panic>
f0102746:	50                   	push   %eax
f0102747:	68 14 56 10 f0       	push   $0xf0105614
f010274c:	6a 58                	push   $0x58
f010274e:	68 78 64 10 f0       	push   $0xf0106478
f0102753:	e8 3c d9 ff ff       	call   f0100094 <_panic>
		assert((ptep[i] & PTE_P) == 0);
f0102758:	68 2b 67 10 f0       	push   $0xf010672b
f010275d:	68 92 64 10 f0       	push   $0xf0106492
f0102762:	68 33 04 00 00       	push   $0x433
f0102767:	68 65 64 10 f0       	push   $0xf0106465
f010276c:	e8 23 d9 ff ff       	call   f0100094 <_panic>
	assert(mm1 >= MMIOBASE && mm1 + 8192 < MMIOLIM);
f0102771:	68 18 61 10 f0       	push   $0xf0106118
f0102776:	68 92 64 10 f0       	push   $0xf0106492
f010277b:	68 43 04 00 00       	push   $0x443
f0102780:	68 65 64 10 f0       	push   $0xf0106465
f0102785:	e8 0a d9 ff ff       	call   f0100094 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8192 < MMIOLIM);
f010278a:	68 40 61 10 f0       	push   $0xf0106140
f010278f:	68 92 64 10 f0       	push   $0xf0106492
f0102794:	68 44 04 00 00       	push   $0x444
f0102799:	68 65 64 10 f0       	push   $0xf0106465
f010279e:	e8 f1 d8 ff ff       	call   f0100094 <_panic>
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f01027a3:	68 68 61 10 f0       	push   $0xf0106168
f01027a8:	68 92 64 10 f0       	push   $0xf0106492
f01027ad:	68 46 04 00 00       	push   $0x446
f01027b2:	68 65 64 10 f0       	push   $0xf0106465
f01027b7:	e8 d8 d8 ff ff       	call   f0100094 <_panic>
	assert(mm1 + 8192 <= mm2);
f01027bc:	68 42 67 10 f0       	push   $0xf0106742
f01027c1:	68 92 64 10 f0       	push   $0xf0106492
f01027c6:	68 48 04 00 00       	push   $0x448
f01027cb:	68 65 64 10 f0       	push   $0xf0106465
f01027d0:	e8 bf d8 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f01027d5:	68 90 61 10 f0       	push   $0xf0106190
f01027da:	68 92 64 10 f0       	push   $0xf0106492
f01027df:	68 4a 04 00 00       	push   $0x44a
f01027e4:	68 65 64 10 f0       	push   $0xf0106465
f01027e9:	e8 a6 d8 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f01027ee:	68 b4 61 10 f0       	push   $0xf01061b4
f01027f3:	68 92 64 10 f0       	push   $0xf0106492
f01027f8:	68 4b 04 00 00       	push   $0x44b
f01027fd:	68 65 64 10 f0       	push   $0xf0106465
f0102802:	e8 8d d8 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0102807:	68 e4 61 10 f0       	push   $0xf01061e4
f010280c:	68 92 64 10 f0       	push   $0xf0106492
f0102811:	68 4c 04 00 00       	push   $0x44c
f0102816:	68 65 64 10 f0       	push   $0xf0106465
f010281b:	e8 74 d8 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0102820:	68 08 62 10 f0       	push   $0xf0106208
f0102825:	68 92 64 10 f0       	push   $0xf0106492
f010282a:	68 4d 04 00 00       	push   $0x44d
f010282f:	68 65 64 10 f0       	push   $0xf0106465
f0102834:	e8 5b d8 ff ff       	call   f0100094 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f0102839:	68 34 62 10 f0       	push   $0xf0106234
f010283e:	68 92 64 10 f0       	push   $0xf0106492
f0102843:	68 4f 04 00 00       	push   $0x44f
f0102848:	68 65 64 10 f0       	push   $0xf0106465
f010284d:	e8 42 d8 ff ff       	call   f0100094 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102852:	68 78 62 10 f0       	push   $0xf0106278
f0102857:	68 92 64 10 f0       	push   $0xf0106492
f010285c:	68 50 04 00 00       	push   $0x450
f0102861:	68 65 64 10 f0       	push   $0xf0106465
f0102866:	e8 29 d8 ff ff       	call   f0100094 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010286b:	50                   	push   %eax
f010286c:	68 38 56 10 f0       	push   $0xf0105638
f0102871:	68 d1 00 00 00       	push   $0xd1
f0102876:	68 65 64 10 f0       	push   $0xf0106465
f010287b:	e8 14 d8 ff ff       	call   f0100094 <_panic>
f0102880:	50                   	push   %eax
f0102881:	68 38 56 10 f0       	push   $0xf0105638
f0102886:	68 da 00 00 00       	push   $0xda
f010288b:	68 65 64 10 f0       	push   $0xf0106465
f0102890:	e8 ff d7 ff ff       	call   f0100094 <_panic>
f0102895:	50                   	push   %eax
f0102896:	68 38 56 10 f0       	push   $0xf0105638
f010289b:	68 e7 00 00 00       	push   $0xe7
f01028a0:	68 65 64 10 f0       	push   $0xf0106465
f01028a5:	e8 ea d7 ff ff       	call   f0100094 <_panic>
f01028aa:	53                   	push   %ebx
f01028ab:	68 38 56 10 f0       	push   $0xf0105638
f01028b0:	68 2a 01 00 00       	push   $0x12a
f01028b5:	68 65 64 10 f0       	push   $0xf0106465
f01028ba:	e8 d5 d7 ff ff       	call   f0100094 <_panic>
f01028bf:	56                   	push   %esi
f01028c0:	68 38 56 10 f0       	push   $0xf0105638
f01028c5:	68 63 03 00 00       	push   $0x363
f01028ca:	68 65 64 10 f0       	push   $0xf0106465
f01028cf:	e8 c0 d7 ff ff       	call   f0100094 <_panic>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01028d4:	68 ac 62 10 f0       	push   $0xf01062ac
f01028d9:	68 92 64 10 f0       	push   $0xf0106492
f01028de:	68 63 03 00 00       	push   $0x363
f01028e3:	68 65 64 10 f0       	push   $0xf0106465
f01028e8:	e8 a7 d7 ff ff       	call   f0100094 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f01028ed:	a1 44 12 23 f0       	mov    0xf0231244,%eax
f01028f2:	89 45 cc             	mov    %eax,-0x34(%ebp)
	if ((uint32_t)kva < KERNBASE)
f01028f5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01028f8:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f01028fd:	8d b0 00 00 40 21    	lea    0x21400000(%eax),%esi
f0102903:	89 da                	mov    %ebx,%edx
f0102905:	89 f8                	mov    %edi,%eax
f0102907:	e8 d6 e1 ff ff       	call   f0100ae2 <check_va2pa>
f010290c:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f0102913:	76 3d                	jbe    f0102952 <mem_init+0x1677>
f0102915:	8d 14 1e             	lea    (%esi,%ebx,1),%edx
f0102918:	39 d0                	cmp    %edx,%eax
f010291a:	75 4d                	jne    f0102969 <mem_init+0x168e>
f010291c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE) {
f0102922:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f0102928:	75 d9                	jne    f0102903 <mem_init+0x1628>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f010292a:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f010292d:	c1 e6 0c             	shl    $0xc,%esi
f0102930:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102935:	39 f3                	cmp    %esi,%ebx
f0102937:	73 62                	jae    f010299b <mem_init+0x16c0>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102939:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f010293f:	89 f8                	mov    %edi,%eax
f0102941:	e8 9c e1 ff ff       	call   f0100ae2 <check_va2pa>
f0102946:	39 c3                	cmp    %eax,%ebx
f0102948:	75 38                	jne    f0102982 <mem_init+0x16a7>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f010294a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102950:	eb e3                	jmp    f0102935 <mem_init+0x165a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102952:	ff 75 cc             	pushl  -0x34(%ebp)
f0102955:	68 38 56 10 f0       	push   $0xf0105638
f010295a:	68 6a 03 00 00       	push   $0x36a
f010295f:	68 65 64 10 f0       	push   $0xf0106465
f0102964:	e8 2b d7 ff ff       	call   f0100094 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102969:	68 e0 62 10 f0       	push   $0xf01062e0
f010296e:	68 92 64 10 f0       	push   $0xf0106492
f0102973:	68 6a 03 00 00       	push   $0x36a
f0102978:	68 65 64 10 f0       	push   $0xf0106465
f010297d:	e8 12 d7 ff ff       	call   f0100094 <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102982:	68 14 63 10 f0       	push   $0xf0106314
f0102987:	68 92 64 10 f0       	push   $0xf0106492
f010298c:	68 71 03 00 00       	push   $0x371
f0102991:	68 65 64 10 f0       	push   $0xf0106465
f0102996:	e8 f9 d6 ff ff       	call   f0100094 <_panic>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f010299b:	b8 00 30 23 f0       	mov    $0xf0233000,%eax
f01029a0:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f01029a5:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f01029a8:	89 c7                	mov    %eax,%edi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f01029aa:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f01029ad:	89 f3                	mov    %esi,%ebx
f01029af:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01029b2:	05 00 80 00 20       	add    $0x20008000,%eax
f01029b7:	89 45 cc             	mov    %eax,-0x34(%ebp)
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f01029ba:	8d 86 00 80 00 00    	lea    0x8000(%esi),%eax
f01029c0:	89 45 c8             	mov    %eax,-0x38(%ebp)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f01029c3:	89 da                	mov    %ebx,%edx
f01029c5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01029c8:	e8 15 e1 ff ff       	call   f0100ae2 <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f01029cd:	81 ff ff ff ff ef    	cmp    $0xefffffff,%edi
f01029d3:	76 59                	jbe    f0102a2e <mem_init+0x1753>
f01029d5:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f01029d8:	8d 14 19             	lea    (%ecx,%ebx,1),%edx
f01029db:	39 d0                	cmp    %edx,%eax
f01029dd:	75 66                	jne    f0102a45 <mem_init+0x176a>
f01029df:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f01029e5:	3b 5d c8             	cmp    -0x38(%ebp),%ebx
f01029e8:	75 d9                	jne    f01029c3 <mem_init+0x16e8>
f01029ea:	8d 9e 00 80 ff ff    	lea    -0x8000(%esi),%ebx
			assert(check_va2pa(pgdir, base + i) == ~0);
f01029f0:	89 da                	mov    %ebx,%edx
f01029f2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01029f5:	e8 e8 e0 ff ff       	call   f0100ae2 <check_va2pa>
f01029fa:	83 f8 ff             	cmp    $0xffffffff,%eax
f01029fd:	75 5f                	jne    f0102a5e <mem_init+0x1783>
f01029ff:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0102a05:	39 f3                	cmp    %esi,%ebx
f0102a07:	75 e7                	jne    f01029f0 <mem_init+0x1715>
f0102a09:	81 ee 00 00 01 00    	sub    $0x10000,%esi
f0102a0f:	81 45 d0 00 80 01 00 	addl   $0x18000,-0x30(%ebp)
f0102a16:	81 c7 00 80 00 00    	add    $0x8000,%edi
	for (n = 0; n < NCPU; n++) {
f0102a1c:	81 ff 00 30 27 f0    	cmp    $0xf0273000,%edi
f0102a22:	75 86                	jne    f01029aa <mem_init+0x16cf>
f0102a24:	8b 7d d4             	mov    -0x2c(%ebp),%edi
	for (i = 0; i < NPDENTRIES; i++) {
f0102a27:	b8 00 00 00 00       	mov    $0x0,%eax
f0102a2c:	eb 7f                	jmp    f0102aad <mem_init+0x17d2>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102a2e:	ff 75 c4             	pushl  -0x3c(%ebp)
f0102a31:	68 38 56 10 f0       	push   $0xf0105638
f0102a36:	68 7a 03 00 00       	push   $0x37a
f0102a3b:	68 65 64 10 f0       	push   $0xf0106465
f0102a40:	e8 4f d6 ff ff       	call   f0100094 <_panic>
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102a45:	68 3c 63 10 f0       	push   $0xf010633c
f0102a4a:	68 92 64 10 f0       	push   $0xf0106492
f0102a4f:	68 7a 03 00 00       	push   $0x37a
f0102a54:	68 65 64 10 f0       	push   $0xf0106465
f0102a59:	e8 36 d6 ff ff       	call   f0100094 <_panic>
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102a5e:	68 84 63 10 f0       	push   $0xf0106384
f0102a63:	68 92 64 10 f0       	push   $0xf0106492
f0102a68:	68 7c 03 00 00       	push   $0x37c
f0102a6d:	68 65 64 10 f0       	push   $0xf0106465
f0102a72:	e8 1d d6 ff ff       	call   f0100094 <_panic>
			assert(pgdir[i] & PTE_P);
f0102a77:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f0102a7b:	75 48                	jne    f0102ac5 <mem_init+0x17ea>
f0102a7d:	68 6d 67 10 f0       	push   $0xf010676d
f0102a82:	68 92 64 10 f0       	push   $0xf0106492
f0102a87:	68 87 03 00 00       	push   $0x387
f0102a8c:	68 65 64 10 f0       	push   $0xf0106465
f0102a91:	e8 fe d5 ff ff       	call   f0100094 <_panic>
				assert(pgdir[i] & PTE_P);
f0102a96:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0102a99:	f6 c2 01             	test   $0x1,%dl
f0102a9c:	74 2c                	je     f0102aca <mem_init+0x17ef>
				assert(pgdir[i] & PTE_W);
f0102a9e:	f6 c2 02             	test   $0x2,%dl
f0102aa1:	74 40                	je     f0102ae3 <mem_init+0x1808>
	for (i = 0; i < NPDENTRIES; i++) {
f0102aa3:	83 c0 01             	add    $0x1,%eax
f0102aa6:	3d 00 04 00 00       	cmp    $0x400,%eax
f0102aab:	74 68                	je     f0102b15 <mem_init+0x183a>
		switch (i) {
f0102aad:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0102ab3:	83 fa 04             	cmp    $0x4,%edx
f0102ab6:	76 bf                	jbe    f0102a77 <mem_init+0x179c>
			if (i >= PDX(KERNBASE)) {
f0102ab8:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102abd:	77 d7                	ja     f0102a96 <mem_init+0x17bb>
				assert(pgdir[i] == 0);
f0102abf:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f0102ac3:	75 37                	jne    f0102afc <mem_init+0x1821>
	for (i = 0; i < NPDENTRIES; i++) {
f0102ac5:	83 c0 01             	add    $0x1,%eax
f0102ac8:	eb e3                	jmp    f0102aad <mem_init+0x17d2>
				assert(pgdir[i] & PTE_P);
f0102aca:	68 6d 67 10 f0       	push   $0xf010676d
f0102acf:	68 92 64 10 f0       	push   $0xf0106492
f0102ad4:	68 8b 03 00 00       	push   $0x38b
f0102ad9:	68 65 64 10 f0       	push   $0xf0106465
f0102ade:	e8 b1 d5 ff ff       	call   f0100094 <_panic>
				assert(pgdir[i] & PTE_W);
f0102ae3:	68 7e 67 10 f0       	push   $0xf010677e
f0102ae8:	68 92 64 10 f0       	push   $0xf0106492
f0102aed:	68 8c 03 00 00       	push   $0x38c
f0102af2:	68 65 64 10 f0       	push   $0xf0106465
f0102af7:	e8 98 d5 ff ff       	call   f0100094 <_panic>
				assert(pgdir[i] == 0);
f0102afc:	68 8f 67 10 f0       	push   $0xf010678f
f0102b01:	68 92 64 10 f0       	push   $0xf0106492
f0102b06:	68 8e 03 00 00       	push   $0x38e
f0102b0b:	68 65 64 10 f0       	push   $0xf0106465
f0102b10:	e8 7f d5 ff ff       	call   f0100094 <_panic>
	cprintf("check_kern_pgdir() succeeded!\n");
f0102b15:	83 ec 0c             	sub    $0xc,%esp
f0102b18:	68 a8 63 10 f0       	push   $0xf01063a8
f0102b1d:	e8 8b 0c 00 00       	call   f01037ad <cprintf>
	lcr3(PADDR(kern_pgdir));
f0102b22:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f0102b27:	83 c4 10             	add    $0x10,%esp
f0102b2a:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102b2f:	0f 86 fb 01 00 00    	jbe    f0102d30 <mem_init+0x1a55>
	return (physaddr_t)kva - KERNBASE;
f0102b35:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102b3a:	0f 22 d8             	mov    %eax,%cr3
	check_page_free_list(0);
f0102b3d:	b8 00 00 00 00       	mov    $0x0,%eax
f0102b42:	e8 ff df ff ff       	call   f0100b46 <check_page_free_list>
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0102b47:	0f 20 c0             	mov    %cr0,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f0102b4a:	83 e0 f3             	and    $0xfffffff3,%eax
f0102b4d:	0d 23 00 05 80       	or     $0x80050023,%eax
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0102b52:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102b55:	83 ec 0c             	sub    $0xc,%esp
f0102b58:	6a 00                	push   $0x0
f0102b5a:	e8 f2 e3 ff ff       	call   f0100f51 <page_alloc>
f0102b5f:	89 c6                	mov    %eax,%esi
f0102b61:	83 c4 10             	add    $0x10,%esp
f0102b64:	85 c0                	test   %eax,%eax
f0102b66:	0f 84 d9 01 00 00    	je     f0102d45 <mem_init+0x1a6a>
	assert((pp1 = page_alloc(0)));
f0102b6c:	83 ec 0c             	sub    $0xc,%esp
f0102b6f:	6a 00                	push   $0x0
f0102b71:	e8 db e3 ff ff       	call   f0100f51 <page_alloc>
f0102b76:	89 c7                	mov    %eax,%edi
f0102b78:	83 c4 10             	add    $0x10,%esp
f0102b7b:	85 c0                	test   %eax,%eax
f0102b7d:	0f 84 db 01 00 00    	je     f0102d5e <mem_init+0x1a83>
	assert((pp2 = page_alloc(0)));
f0102b83:	83 ec 0c             	sub    $0xc,%esp
f0102b86:	6a 00                	push   $0x0
f0102b88:	e8 c4 e3 ff ff       	call   f0100f51 <page_alloc>
f0102b8d:	89 c3                	mov    %eax,%ebx
f0102b8f:	83 c4 10             	add    $0x10,%esp
f0102b92:	85 c0                	test   %eax,%eax
f0102b94:	0f 84 dd 01 00 00    	je     f0102d77 <mem_init+0x1a9c>
	page_free(pp0);
f0102b9a:	83 ec 0c             	sub    $0xc,%esp
f0102b9d:	56                   	push   %esi
f0102b9e:	e8 20 e4 ff ff       	call   f0100fc3 <page_free>
	return (pp - pages) << PGSHIFT;
f0102ba3:	89 f8                	mov    %edi,%eax
f0102ba5:	2b 05 90 1e 23 f0    	sub    0xf0231e90,%eax
f0102bab:	c1 f8 03             	sar    $0x3,%eax
f0102bae:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102bb1:	89 c2                	mov    %eax,%edx
f0102bb3:	c1 ea 0c             	shr    $0xc,%edx
f0102bb6:	83 c4 10             	add    $0x10,%esp
f0102bb9:	3b 15 88 1e 23 f0    	cmp    0xf0231e88,%edx
f0102bbf:	0f 83 cb 01 00 00    	jae    f0102d90 <mem_init+0x1ab5>
	memset(page2kva(pp1), 1, PGSIZE);
f0102bc5:	83 ec 04             	sub    $0x4,%esp
f0102bc8:	68 00 10 00 00       	push   $0x1000
f0102bcd:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0102bcf:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102bd4:	50                   	push   %eax
f0102bd5:	e8 30 1d 00 00       	call   f010490a <memset>
	return (pp - pages) << PGSHIFT;
f0102bda:	89 d8                	mov    %ebx,%eax
f0102bdc:	2b 05 90 1e 23 f0    	sub    0xf0231e90,%eax
f0102be2:	c1 f8 03             	sar    $0x3,%eax
f0102be5:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102be8:	89 c2                	mov    %eax,%edx
f0102bea:	c1 ea 0c             	shr    $0xc,%edx
f0102bed:	83 c4 10             	add    $0x10,%esp
f0102bf0:	3b 15 88 1e 23 f0    	cmp    0xf0231e88,%edx
f0102bf6:	0f 83 a6 01 00 00    	jae    f0102da2 <mem_init+0x1ac7>
	memset(page2kva(pp2), 2, PGSIZE);
f0102bfc:	83 ec 04             	sub    $0x4,%esp
f0102bff:	68 00 10 00 00       	push   $0x1000
f0102c04:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f0102c06:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102c0b:	50                   	push   %eax
f0102c0c:	e8 f9 1c 00 00       	call   f010490a <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102c11:	6a 02                	push   $0x2
f0102c13:	68 00 10 00 00       	push   $0x1000
f0102c18:	57                   	push   %edi
f0102c19:	ff 35 8c 1e 23 f0    	pushl  0xf0231e8c
f0102c1f:	e8 ee e5 ff ff       	call   f0101212 <page_insert>
	assert(pp1->pp_ref == 1);
f0102c24:	83 c4 20             	add    $0x20,%esp
f0102c27:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102c2c:	0f 85 82 01 00 00    	jne    f0102db4 <mem_init+0x1ad9>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102c32:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102c39:	01 01 01 
f0102c3c:	0f 85 8b 01 00 00    	jne    f0102dcd <mem_init+0x1af2>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102c42:	6a 02                	push   $0x2
f0102c44:	68 00 10 00 00       	push   $0x1000
f0102c49:	53                   	push   %ebx
f0102c4a:	ff 35 8c 1e 23 f0    	pushl  0xf0231e8c
f0102c50:	e8 bd e5 ff ff       	call   f0101212 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102c55:	83 c4 10             	add    $0x10,%esp
f0102c58:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102c5f:	02 02 02 
f0102c62:	0f 85 7e 01 00 00    	jne    f0102de6 <mem_init+0x1b0b>
	assert(pp2->pp_ref == 1);
f0102c68:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102c6d:	0f 85 8c 01 00 00    	jne    f0102dff <mem_init+0x1b24>
	assert(pp1->pp_ref == 0);
f0102c73:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102c78:	0f 85 9a 01 00 00    	jne    f0102e18 <mem_init+0x1b3d>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102c7e:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102c85:	03 03 03 
	return (pp - pages) << PGSHIFT;
f0102c88:	89 d8                	mov    %ebx,%eax
f0102c8a:	2b 05 90 1e 23 f0    	sub    0xf0231e90,%eax
f0102c90:	c1 f8 03             	sar    $0x3,%eax
f0102c93:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102c96:	89 c2                	mov    %eax,%edx
f0102c98:	c1 ea 0c             	shr    $0xc,%edx
f0102c9b:	3b 15 88 1e 23 f0    	cmp    0xf0231e88,%edx
f0102ca1:	0f 83 8a 01 00 00    	jae    f0102e31 <mem_init+0x1b56>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102ca7:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102cae:	03 03 03 
f0102cb1:	0f 85 8c 01 00 00    	jne    f0102e43 <mem_init+0x1b68>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102cb7:	83 ec 08             	sub    $0x8,%esp
f0102cba:	68 00 10 00 00       	push   $0x1000
f0102cbf:	ff 35 8c 1e 23 f0    	pushl  0xf0231e8c
f0102cc5:	e8 02 e5 ff ff       	call   f01011cc <page_remove>
	assert(pp2->pp_ref == 0);
f0102cca:	83 c4 10             	add    $0x10,%esp
f0102ccd:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102cd2:	0f 85 84 01 00 00    	jne    f0102e5c <mem_init+0x1b81>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102cd8:	8b 0d 8c 1e 23 f0    	mov    0xf0231e8c,%ecx
f0102cde:	8b 11                	mov    (%ecx),%edx
f0102ce0:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	return (pp - pages) << PGSHIFT;
f0102ce6:	89 f0                	mov    %esi,%eax
f0102ce8:	2b 05 90 1e 23 f0    	sub    0xf0231e90,%eax
f0102cee:	c1 f8 03             	sar    $0x3,%eax
f0102cf1:	c1 e0 0c             	shl    $0xc,%eax
f0102cf4:	39 c2                	cmp    %eax,%edx
f0102cf6:	0f 85 79 01 00 00    	jne    f0102e75 <mem_init+0x1b9a>
	kern_pgdir[0] = 0;
f0102cfc:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102d02:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102d07:	0f 85 81 01 00 00    	jne    f0102e8e <mem_init+0x1bb3>
	pp0->pp_ref = 0;
f0102d0d:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f0102d13:	83 ec 0c             	sub    $0xc,%esp
f0102d16:	56                   	push   %esi
f0102d17:	e8 a7 e2 ff ff       	call   f0100fc3 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102d1c:	c7 04 24 3c 64 10 f0 	movl   $0xf010643c,(%esp)
f0102d23:	e8 85 0a 00 00       	call   f01037ad <cprintf>
}
f0102d28:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102d2b:	5b                   	pop    %ebx
f0102d2c:	5e                   	pop    %esi
f0102d2d:	5f                   	pop    %edi
f0102d2e:	5d                   	pop    %ebp
f0102d2f:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102d30:	50                   	push   %eax
f0102d31:	68 38 56 10 f0       	push   $0xf0105638
f0102d36:	68 03 01 00 00       	push   $0x103
f0102d3b:	68 65 64 10 f0       	push   $0xf0106465
f0102d40:	e8 4f d3 ff ff       	call   f0100094 <_panic>
	assert((pp0 = page_alloc(0)));
f0102d45:	68 79 65 10 f0       	push   $0xf0106579
f0102d4a:	68 92 64 10 f0       	push   $0xf0106492
f0102d4f:	68 65 04 00 00       	push   $0x465
f0102d54:	68 65 64 10 f0       	push   $0xf0106465
f0102d59:	e8 36 d3 ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f0102d5e:	68 8f 65 10 f0       	push   $0xf010658f
f0102d63:	68 92 64 10 f0       	push   $0xf0106492
f0102d68:	68 66 04 00 00       	push   $0x466
f0102d6d:	68 65 64 10 f0       	push   $0xf0106465
f0102d72:	e8 1d d3 ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f0102d77:	68 a5 65 10 f0       	push   $0xf01065a5
f0102d7c:	68 92 64 10 f0       	push   $0xf0106492
f0102d81:	68 67 04 00 00       	push   $0x467
f0102d86:	68 65 64 10 f0       	push   $0xf0106465
f0102d8b:	e8 04 d3 ff ff       	call   f0100094 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102d90:	50                   	push   %eax
f0102d91:	68 14 56 10 f0       	push   $0xf0105614
f0102d96:	6a 58                	push   $0x58
f0102d98:	68 78 64 10 f0       	push   $0xf0106478
f0102d9d:	e8 f2 d2 ff ff       	call   f0100094 <_panic>
f0102da2:	50                   	push   %eax
f0102da3:	68 14 56 10 f0       	push   $0xf0105614
f0102da8:	6a 58                	push   $0x58
f0102daa:	68 78 64 10 f0       	push   $0xf0106478
f0102daf:	e8 e0 d2 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 1);
f0102db4:	68 76 66 10 f0       	push   $0xf0106676
f0102db9:	68 92 64 10 f0       	push   $0xf0106492
f0102dbe:	68 6c 04 00 00       	push   $0x46c
f0102dc3:	68 65 64 10 f0       	push   $0xf0106465
f0102dc8:	e8 c7 d2 ff ff       	call   f0100094 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102dcd:	68 c8 63 10 f0       	push   $0xf01063c8
f0102dd2:	68 92 64 10 f0       	push   $0xf0106492
f0102dd7:	68 6d 04 00 00       	push   $0x46d
f0102ddc:	68 65 64 10 f0       	push   $0xf0106465
f0102de1:	e8 ae d2 ff ff       	call   f0100094 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102de6:	68 ec 63 10 f0       	push   $0xf01063ec
f0102deb:	68 92 64 10 f0       	push   $0xf0106492
f0102df0:	68 6f 04 00 00       	push   $0x46f
f0102df5:	68 65 64 10 f0       	push   $0xf0106465
f0102dfa:	e8 95 d2 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f0102dff:	68 98 66 10 f0       	push   $0xf0106698
f0102e04:	68 92 64 10 f0       	push   $0xf0106492
f0102e09:	68 70 04 00 00       	push   $0x470
f0102e0e:	68 65 64 10 f0       	push   $0xf0106465
f0102e13:	e8 7c d2 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 0);
f0102e18:	68 02 67 10 f0       	push   $0xf0106702
f0102e1d:	68 92 64 10 f0       	push   $0xf0106492
f0102e22:	68 71 04 00 00       	push   $0x471
f0102e27:	68 65 64 10 f0       	push   $0xf0106465
f0102e2c:	e8 63 d2 ff ff       	call   f0100094 <_panic>
f0102e31:	50                   	push   %eax
f0102e32:	68 14 56 10 f0       	push   $0xf0105614
f0102e37:	6a 58                	push   $0x58
f0102e39:	68 78 64 10 f0       	push   $0xf0106478
f0102e3e:	e8 51 d2 ff ff       	call   f0100094 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102e43:	68 10 64 10 f0       	push   $0xf0106410
f0102e48:	68 92 64 10 f0       	push   $0xf0106492
f0102e4d:	68 73 04 00 00       	push   $0x473
f0102e52:	68 65 64 10 f0       	push   $0xf0106465
f0102e57:	e8 38 d2 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f0102e5c:	68 d0 66 10 f0       	push   $0xf01066d0
f0102e61:	68 92 64 10 f0       	push   $0xf0106492
f0102e66:	68 75 04 00 00       	push   $0x475
f0102e6b:	68 65 64 10 f0       	push   $0xf0106465
f0102e70:	e8 1f d2 ff ff       	call   f0100094 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102e75:	68 98 5d 10 f0       	push   $0xf0105d98
f0102e7a:	68 92 64 10 f0       	push   $0xf0106492
f0102e7f:	68 78 04 00 00       	push   $0x478
f0102e84:	68 65 64 10 f0       	push   $0xf0106465
f0102e89:	e8 06 d2 ff ff       	call   f0100094 <_panic>
	assert(pp0->pp_ref == 1);
f0102e8e:	68 87 66 10 f0       	push   $0xf0106687
f0102e93:	68 92 64 10 f0       	push   $0xf0106492
f0102e98:	68 7a 04 00 00       	push   $0x47a
f0102e9d:	68 65 64 10 f0       	push   $0xf0106465
f0102ea2:	e8 ed d1 ff ff       	call   f0100094 <_panic>

f0102ea7 <user_mem_check>:
}
f0102ea7:	b8 00 00 00 00       	mov    $0x0,%eax
f0102eac:	c3                   	ret    

f0102ead <user_mem_assert>:
}
f0102ead:	c3                   	ret    

f0102eae <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0102eae:	55                   	push   %ebp
f0102eaf:	89 e5                	mov    %esp,%ebp
f0102eb1:	57                   	push   %edi
f0102eb2:	56                   	push   %esi
f0102eb3:	53                   	push   %ebx
f0102eb4:	83 ec 0c             	sub    $0xc,%esp
f0102eb7:	89 c7                	mov    %eax,%edi
	// LAB 3: Your code here.
	void* i;
	for (i = ROUNDDOWN(va, PGSIZE); i < ROUNDUP(va + len, PGSIZE); i+=PGSIZE){
f0102eb9:	89 d3                	mov    %edx,%ebx
f0102ebb:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0102ec1:	8d b4 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%esi
f0102ec8:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
f0102ece:	39 f3                	cmp    %esi,%ebx
f0102ed0:	73 5c                	jae    f0102f2e <region_alloc+0x80>
		struct PageInfo *pginfo = page_alloc(0);
f0102ed2:	83 ec 0c             	sub    $0xc,%esp
f0102ed5:	6a 00                	push   $0x0
f0102ed7:	e8 75 e0 ff ff       	call   f0100f51 <page_alloc>
		if (!pginfo) {
f0102edc:	83 c4 10             	add    $0x10,%esp
f0102edf:	85 c0                	test   %eax,%eax
f0102ee1:	74 20                	je     f0102f03 <region_alloc+0x55>
			 panic("region_alloc:%e", -E_NO_MEM);
		}
		pginfo->pp_ref++;
f0102ee3:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
		int r = page_insert(e->env_pgdir, pginfo, i, PTE_W | PTE_U | PTE_P);
f0102ee8:	6a 07                	push   $0x7
f0102eea:	53                   	push   %ebx
f0102eeb:	50                   	push   %eax
f0102eec:	ff 77 60             	pushl  0x60(%edi)
f0102eef:	e8 1e e3 ff ff       	call   f0101212 <page_insert>
		if (r < 0) {
f0102ef4:	83 c4 10             	add    $0x10,%esp
f0102ef7:	85 c0                	test   %eax,%eax
f0102ef9:	78 1e                	js     f0102f19 <region_alloc+0x6b>
	for (i = ROUNDDOWN(va, PGSIZE); i < ROUNDUP(va + len, PGSIZE); i+=PGSIZE){
f0102efb:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102f01:	eb cb                	jmp    f0102ece <region_alloc+0x20>
			 panic("region_alloc:%e", -E_NO_MEM);
f0102f03:	6a fc                	push   $0xfffffffc
f0102f05:	68 9d 67 10 f0       	push   $0xf010679d
f0102f0a:	68 22 01 00 00       	push   $0x122
f0102f0f:	68 ad 67 10 f0       	push   $0xf01067ad
f0102f14:	e8 7b d1 ff ff       	call   f0100094 <_panic>
			 panic("region_alloc:%e", r);
f0102f19:	50                   	push   %eax
f0102f1a:	68 9d 67 10 f0       	push   $0xf010679d
f0102f1f:	68 27 01 00 00       	push   $0x127
f0102f24:	68 ad 67 10 f0       	push   $0xf01067ad
f0102f29:	e8 66 d1 ff ff       	call   f0100094 <_panic>
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
}
f0102f2e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102f31:	5b                   	pop    %ebx
f0102f32:	5e                   	pop    %esi
f0102f33:	5f                   	pop    %edi
f0102f34:	5d                   	pop    %ebp
f0102f35:	c3                   	ret    

f0102f36 <envid2env>:
{
f0102f36:	55                   	push   %ebp
f0102f37:	89 e5                	mov    %esp,%ebp
f0102f39:	56                   	push   %esi
f0102f3a:	53                   	push   %ebx
f0102f3b:	8b 45 08             	mov    0x8(%ebp),%eax
f0102f3e:	8b 55 10             	mov    0x10(%ebp),%edx
	if (envid == 0) {
f0102f41:	85 c0                	test   %eax,%eax
f0102f43:	74 2e                	je     f0102f73 <envid2env+0x3d>
	e = &envs[ENVX(envid)];
f0102f45:	89 c3                	mov    %eax,%ebx
f0102f47:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0102f4d:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f0102f50:	03 1d 44 12 23 f0    	add    0xf0231244,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0102f56:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0102f5a:	74 31                	je     f0102f8d <envid2env+0x57>
f0102f5c:	39 43 48             	cmp    %eax,0x48(%ebx)
f0102f5f:	75 2c                	jne    f0102f8d <envid2env+0x57>
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0102f61:	84 d2                	test   %dl,%dl
f0102f63:	75 38                	jne    f0102f9d <envid2env+0x67>
	*env_store = e;
f0102f65:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102f68:	89 18                	mov    %ebx,(%eax)
	return 0;
f0102f6a:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102f6f:	5b                   	pop    %ebx
f0102f70:	5e                   	pop    %esi
f0102f71:	5d                   	pop    %ebp
f0102f72:	c3                   	ret    
		*env_store = curenv;
f0102f73:	e8 92 1f 00 00       	call   f0104f0a <cpunum>
f0102f78:	6b c0 74             	imul   $0x74,%eax,%eax
f0102f7b:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0102f81:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102f84:	89 01                	mov    %eax,(%ecx)
		return 0;
f0102f86:	b8 00 00 00 00       	mov    $0x0,%eax
f0102f8b:	eb e2                	jmp    f0102f6f <envid2env+0x39>
		*env_store = 0;
f0102f8d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102f90:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102f96:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102f9b:	eb d2                	jmp    f0102f6f <envid2env+0x39>
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0102f9d:	e8 68 1f 00 00       	call   f0104f0a <cpunum>
f0102fa2:	6b c0 74             	imul   $0x74,%eax,%eax
f0102fa5:	39 98 28 20 23 f0    	cmp    %ebx,-0xfdcdfd8(%eax)
f0102fab:	74 b8                	je     f0102f65 <envid2env+0x2f>
f0102fad:	8b 73 4c             	mov    0x4c(%ebx),%esi
f0102fb0:	e8 55 1f 00 00       	call   f0104f0a <cpunum>
f0102fb5:	6b c0 74             	imul   $0x74,%eax,%eax
f0102fb8:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0102fbe:	3b 70 48             	cmp    0x48(%eax),%esi
f0102fc1:	74 a2                	je     f0102f65 <envid2env+0x2f>
		*env_store = 0;
f0102fc3:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102fc6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102fcc:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102fd1:	eb 9c                	jmp    f0102f6f <envid2env+0x39>

f0102fd3 <env_init_percpu>:
	asm volatile("lgdt (%0)" : : "r" (p));
f0102fd3:	b8 20 13 12 f0       	mov    $0xf0121320,%eax
f0102fd8:	0f 01 10             	lgdtl  (%eax)
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f0102fdb:	b8 23 00 00 00       	mov    $0x23,%eax
f0102fe0:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f0102fe2:	8e e0                	mov    %eax,%fs
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f0102fe4:	b8 10 00 00 00       	mov    $0x10,%eax
f0102fe9:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f0102feb:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f0102fed:	8e d0                	mov    %eax,%ss
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f0102fef:	ea f6 2f 10 f0 08 00 	ljmp   $0x8,$0xf0102ff6
	asm volatile("lldt %0" : : "r" (sel));
f0102ff6:	b8 00 00 00 00       	mov    $0x0,%eax
f0102ffb:	0f 00 d0             	lldt   %ax
}
f0102ffe:	c3                   	ret    

f0102fff <env_init>:
{
f0102fff:	55                   	push   %ebp
f0103000:	89 e5                	mov    %esp,%ebp
f0103002:	56                   	push   %esi
f0103003:	53                   	push   %ebx
		envs[i].env_id = 0;
f0103004:	8b 35 44 12 23 f0    	mov    0xf0231244,%esi
f010300a:	8b 15 48 12 23 f0    	mov    0xf0231248,%edx
f0103010:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f0103016:	89 f3                	mov    %esi,%ebx
f0103018:	eb 02                	jmp    f010301c <env_init+0x1d>
f010301a:	89 c8                	mov    %ecx,%eax
f010301c:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_link = env_free_list;
f0103023:	89 50 44             	mov    %edx,0x44(%eax)
f0103026:	8d 48 84             	lea    -0x7c(%eax),%ecx
		env_free_list = &envs[i];
f0103029:	89 c2                	mov    %eax,%edx
	for (int i = NENV-1;i >= 0;i--) {
f010302b:	39 d8                	cmp    %ebx,%eax
f010302d:	75 eb                	jne    f010301a <env_init+0x1b>
f010302f:	89 35 48 12 23 f0    	mov    %esi,0xf0231248
	env_init_percpu();
f0103035:	e8 99 ff ff ff       	call   f0102fd3 <env_init_percpu>
}
f010303a:	5b                   	pop    %ebx
f010303b:	5e                   	pop    %esi
f010303c:	5d                   	pop    %ebp
f010303d:	c3                   	ret    

f010303e <env_alloc>:
{
f010303e:	55                   	push   %ebp
f010303f:	89 e5                	mov    %esp,%ebp
f0103041:	56                   	push   %esi
f0103042:	53                   	push   %ebx
	if (!(e = env_free_list))
f0103043:	8b 1d 48 12 23 f0    	mov    0xf0231248,%ebx
f0103049:	85 db                	test   %ebx,%ebx
f010304b:	0f 84 71 01 00 00    	je     f01031c2 <env_alloc+0x184>
	if (!(p = page_alloc(ALLOC_ZERO)))
f0103051:	83 ec 0c             	sub    $0xc,%esp
f0103054:	6a 01                	push   $0x1
f0103056:	e8 f6 de ff ff       	call   f0100f51 <page_alloc>
f010305b:	89 c6                	mov    %eax,%esi
f010305d:	83 c4 10             	add    $0x10,%esp
f0103060:	85 c0                	test   %eax,%eax
f0103062:	0f 84 61 01 00 00    	je     f01031c9 <env_alloc+0x18b>
	return (pp - pages) << PGSHIFT;
f0103068:	2b 05 90 1e 23 f0    	sub    0xf0231e90,%eax
f010306e:	c1 f8 03             	sar    $0x3,%eax
f0103071:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0103074:	89 c2                	mov    %eax,%edx
f0103076:	c1 ea 0c             	shr    $0xc,%edx
f0103079:	3b 15 88 1e 23 f0    	cmp    0xf0231e88,%edx
f010307f:	0f 83 16 01 00 00    	jae    f010319b <env_alloc+0x15d>
	return (void *)(pa + KERNBASE);
f0103085:	2d 00 00 00 10       	sub    $0x10000000,%eax
	e->env_pgdir = page2kva(p);	
f010308a:	89 43 60             	mov    %eax,0x60(%ebx)
	memcpy(e->env_pgdir, kern_pgdir, PGSIZE);
f010308d:	83 ec 04             	sub    $0x4,%esp
f0103090:	68 00 10 00 00       	push   $0x1000
f0103095:	ff 35 8c 1e 23 f0    	pushl  0xf0231e8c
f010309b:	50                   	push   %eax
f010309c:	e8 13 19 00 00       	call   f01049b4 <memcpy>
	p->pp_ref++;
f01030a1:	66 83 46 04 01       	addw   $0x1,0x4(%esi)
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f01030a6:	8b 43 60             	mov    0x60(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f01030a9:	83 c4 10             	add    $0x10,%esp
f01030ac:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01030b1:	0f 86 f6 00 00 00    	jbe    f01031ad <env_alloc+0x16f>
	return (physaddr_t)kva - KERNBASE;
f01030b7:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01030bd:	83 ca 05             	or     $0x5,%edx
f01030c0:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f01030c6:	8b 43 48             	mov    0x48(%ebx),%eax
f01030c9:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f01030ce:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f01030d3:	ba 00 10 00 00       	mov    $0x1000,%edx
f01030d8:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f01030db:	89 da                	mov    %ebx,%edx
f01030dd:	2b 15 44 12 23 f0    	sub    0xf0231244,%edx
f01030e3:	c1 fa 02             	sar    $0x2,%edx
f01030e6:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f01030ec:	09 d0                	or     %edx,%eax
f01030ee:	89 43 48             	mov    %eax,0x48(%ebx)
	e->env_parent_id = parent_id;
f01030f1:	8b 45 0c             	mov    0xc(%ebp),%eax
f01030f4:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f01030f7:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f01030fe:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0103105:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f010310c:	83 ec 04             	sub    $0x4,%esp
f010310f:	6a 44                	push   $0x44
f0103111:	6a 00                	push   $0x0
f0103113:	53                   	push   %ebx
f0103114:	e8 f1 17 00 00       	call   f010490a <memset>
	e->env_tf.tf_ds = GD_UD | 3;
f0103119:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f010311f:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0103125:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f010312b:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0103132:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	e->env_pgfault_upcall = 0;
f0103138:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)
	e->env_ipc_recving = 0;
f010313f:	c6 43 68 00          	movb   $0x0,0x68(%ebx)
	env_free_list = e->env_link;
f0103143:	8b 43 44             	mov    0x44(%ebx),%eax
f0103146:	a3 48 12 23 f0       	mov    %eax,0xf0231248
	*newenv_store = e;
f010314b:	8b 45 08             	mov    0x8(%ebp),%eax
f010314e:	89 18                	mov    %ebx,(%eax)
	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103150:	8b 5b 48             	mov    0x48(%ebx),%ebx
f0103153:	e8 b2 1d 00 00       	call   f0104f0a <cpunum>
f0103158:	6b c0 74             	imul   $0x74,%eax,%eax
f010315b:	83 c4 10             	add    $0x10,%esp
f010315e:	ba 00 00 00 00       	mov    $0x0,%edx
f0103163:	83 b8 28 20 23 f0 00 	cmpl   $0x0,-0xfdcdfd8(%eax)
f010316a:	74 11                	je     f010317d <env_alloc+0x13f>
f010316c:	e8 99 1d 00 00       	call   f0104f0a <cpunum>
f0103171:	6b c0 74             	imul   $0x74,%eax,%eax
f0103174:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f010317a:	8b 50 48             	mov    0x48(%eax),%edx
f010317d:	83 ec 04             	sub    $0x4,%esp
f0103180:	53                   	push   %ebx
f0103181:	52                   	push   %edx
f0103182:	68 b8 67 10 f0       	push   $0xf01067b8
f0103187:	e8 21 06 00 00       	call   f01037ad <cprintf>
	return 0;
f010318c:	83 c4 10             	add    $0x10,%esp
f010318f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103194:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103197:	5b                   	pop    %ebx
f0103198:	5e                   	pop    %esi
f0103199:	5d                   	pop    %ebp
f010319a:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010319b:	50                   	push   %eax
f010319c:	68 14 56 10 f0       	push   $0xf0105614
f01031a1:	6a 58                	push   $0x58
f01031a3:	68 78 64 10 f0       	push   $0xf0106478
f01031a8:	e8 e7 ce ff ff       	call   f0100094 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01031ad:	50                   	push   %eax
f01031ae:	68 38 56 10 f0       	push   $0xf0105638
f01031b3:	68 c6 00 00 00       	push   $0xc6
f01031b8:	68 ad 67 10 f0       	push   $0xf01067ad
f01031bd:	e8 d2 ce ff ff       	call   f0100094 <_panic>
		return -E_NO_FREE_ENV;
f01031c2:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f01031c7:	eb cb                	jmp    f0103194 <env_alloc+0x156>
		return -E_NO_MEM;
f01031c9:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01031ce:	eb c4                	jmp    f0103194 <env_alloc+0x156>

f01031d0 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f01031d0:	55                   	push   %ebp
f01031d1:	89 e5                	mov    %esp,%ebp
f01031d3:	57                   	push   %edi
f01031d4:	56                   	push   %esi
f01031d5:	53                   	push   %ebx
f01031d6:	83 ec 34             	sub    $0x34,%esp
f01031d9:	8b 75 08             	mov    0x8(%ebp),%esi
	// LAB 3: Your code here.
	struct 	Env *e;	
	int r = env_alloc(&e, (envid_t)0);
f01031dc:	6a 00                	push   $0x0
f01031de:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01031e1:	50                   	push   %eax
f01031e2:	e8 57 fe ff ff       	call   f010303e <env_alloc>
	if (r < 0) {
f01031e7:	83 c4 10             	add    $0x10,%esp
f01031ea:	85 c0                	test   %eax,%eax
f01031ec:	78 36                	js     f0103224 <env_create+0x54>
		 panic("env_create: %e", r);
	}
	e->env_type = type;
f01031ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01031f1:	8b 45 0c             	mov    0xc(%ebp),%eax
f01031f4:	89 47 50             	mov    %eax,0x50(%edi)
	if (elf->e_magic != ELF_MAGIC) {
f01031f7:	81 3e 7f 45 4c 46    	cmpl   $0x464c457f,(%esi)
f01031fd:	75 3a                	jne    f0103239 <env_create+0x69>
	ph = (struct Proghdr *) (binary + elf->e_phoff);
f01031ff:	89 f3                	mov    %esi,%ebx
f0103201:	03 5e 1c             	add    0x1c(%esi),%ebx
	eph = ph + elf->e_phnum;
f0103204:	0f b7 46 2c          	movzwl 0x2c(%esi),%eax
f0103208:	c1 e0 05             	shl    $0x5,%eax
f010320b:	01 d8                	add    %ebx,%eax
f010320d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	lcr3(PADDR(e->env_pgdir));
f0103210:	8b 47 60             	mov    0x60(%edi),%eax
	if ((uint32_t)kva < KERNBASE)
f0103213:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103218:	76 36                	jbe    f0103250 <env_create+0x80>
	return (physaddr_t)kva - KERNBASE;
f010321a:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f010321f:	0f 22 d8             	mov    %eax,%cr3
f0103222:	eb 5b                	jmp    f010327f <env_create+0xaf>
		 panic("env_create: %e", r);
f0103224:	50                   	push   %eax
f0103225:	68 cd 67 10 f0       	push   $0xf01067cd
f010322a:	68 94 01 00 00       	push   $0x194
f010322f:	68 ad 67 10 f0       	push   $0xf01067ad
f0103234:	e8 5b ce ff ff       	call   f0100094 <_panic>
		 panic("load_icode: not an Elf file");
f0103239:	83 ec 04             	sub    $0x4,%esp
f010323c:	68 dc 67 10 f0       	push   $0xf01067dc
f0103241:	68 6c 01 00 00       	push   $0x16c
f0103246:	68 ad 67 10 f0       	push   $0xf01067ad
f010324b:	e8 44 ce ff ff       	call   f0100094 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103250:	50                   	push   %eax
f0103251:	68 38 56 10 f0       	push   $0xf0105638
f0103256:	68 71 01 00 00       	push   $0x171
f010325b:	68 ad 67 10 f0       	push   $0xf01067ad
f0103260:	e8 2f ce ff ff       	call   f0100094 <_panic>
					 panic("load_icode: file size is greater than memory size");
f0103265:	83 ec 04             	sub    $0x4,%esp
f0103268:	68 1c 68 10 f0       	push   $0xf010681c
f010326d:	68 75 01 00 00       	push   $0x175
f0103272:	68 ad 67 10 f0       	push   $0xf01067ad
f0103277:	e8 18 ce ff ff       	call   f0100094 <_panic>
	for (; ph<eph; ph++) {
f010327c:	83 c3 20             	add    $0x20,%ebx
f010327f:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0103282:	76 47                	jbe    f01032cb <env_create+0xfb>
		if (ph->p_type == ELF_PROG_LOAD) {
f0103284:	83 3b 01             	cmpl   $0x1,(%ebx)
f0103287:	75 f3                	jne    f010327c <env_create+0xac>
			 if (ph->p_filesz > ph->p_memsz) {
f0103289:	8b 4b 14             	mov    0x14(%ebx),%ecx
f010328c:	39 4b 10             	cmp    %ecx,0x10(%ebx)
f010328f:	77 d4                	ja     f0103265 <env_create+0x95>
			 region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f0103291:	8b 53 08             	mov    0x8(%ebx),%edx
f0103294:	89 f8                	mov    %edi,%eax
f0103296:	e8 13 fc ff ff       	call   f0102eae <region_alloc>
			 memcpy((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
f010329b:	83 ec 04             	sub    $0x4,%esp
f010329e:	ff 73 10             	pushl  0x10(%ebx)
f01032a1:	89 f0                	mov    %esi,%eax
f01032a3:	03 43 04             	add    0x4(%ebx),%eax
f01032a6:	50                   	push   %eax
f01032a7:	ff 73 08             	pushl  0x8(%ebx)
f01032aa:	e8 05 17 00 00       	call   f01049b4 <memcpy>
			 memset((void *)ph->p_va + ph->p_filesz, 0, ph->p_memsz - ph->p_filesz);
f01032af:	8b 43 10             	mov    0x10(%ebx),%eax
f01032b2:	83 c4 0c             	add    $0xc,%esp
f01032b5:	8b 53 14             	mov    0x14(%ebx),%edx
f01032b8:	29 c2                	sub    %eax,%edx
f01032ba:	52                   	push   %edx
f01032bb:	6a 00                	push   $0x0
f01032bd:	03 43 08             	add    0x8(%ebx),%eax
f01032c0:	50                   	push   %eax
f01032c1:	e8 44 16 00 00       	call   f010490a <memset>
f01032c6:	83 c4 10             	add    $0x10,%esp
f01032c9:	eb b1                	jmp    f010327c <env_create+0xac>
	e->env_tf.tf_eip = elf->e_entry;
f01032cb:	8b 46 18             	mov    0x18(%esi),%eax
f01032ce:	89 47 30             	mov    %eax,0x30(%edi)
	region_alloc(e, (void *)USTACKTOP - PGSIZE, PGSIZE);
f01032d1:	b9 00 10 00 00       	mov    $0x1000,%ecx
f01032d6:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f01032db:	89 f8                	mov    %edi,%eax
f01032dd:	e8 cc fb ff ff       	call   f0102eae <region_alloc>
	lcr3(PADDR(kern_pgdir));
f01032e2:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f01032e7:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01032ec:	76 10                	jbe    f01032fe <env_create+0x12e>
	return (physaddr_t)kva - KERNBASE;
f01032ee:	05 00 00 00 10       	add    $0x10000000,%eax
f01032f3:	0f 22 d8             	mov    %eax,%cr3
	load_icode(e, binary);
}
f01032f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01032f9:	5b                   	pop    %ebx
f01032fa:	5e                   	pop    %esi
f01032fb:	5f                   	pop    %edi
f01032fc:	5d                   	pop    %ebp
f01032fd:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01032fe:	50                   	push   %eax
f01032ff:	68 38 56 10 f0       	push   $0xf0105638
f0103304:	68 83 01 00 00       	push   $0x183
f0103309:	68 ad 67 10 f0       	push   $0xf01067ad
f010330e:	e8 81 cd ff ff       	call   f0100094 <_panic>

f0103313 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0103313:	55                   	push   %ebp
f0103314:	89 e5                	mov    %esp,%ebp
f0103316:	57                   	push   %edi
f0103317:	56                   	push   %esi
f0103318:	53                   	push   %ebx
f0103319:	83 ec 1c             	sub    $0x1c,%esp
f010331c:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f010331f:	e8 e6 1b 00 00       	call   f0104f0a <cpunum>
f0103324:	6b c0 74             	imul   $0x74,%eax,%eax
f0103327:	39 b8 28 20 23 f0    	cmp    %edi,-0xfdcdfd8(%eax)
f010332d:	74 48                	je     f0103377 <env_free+0x64>
		lcr3(PADDR(kern_pgdir));

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f010332f:	8b 5f 48             	mov    0x48(%edi),%ebx
f0103332:	e8 d3 1b 00 00       	call   f0104f0a <cpunum>
f0103337:	6b c0 74             	imul   $0x74,%eax,%eax
f010333a:	ba 00 00 00 00       	mov    $0x0,%edx
f010333f:	83 b8 28 20 23 f0 00 	cmpl   $0x0,-0xfdcdfd8(%eax)
f0103346:	74 11                	je     f0103359 <env_free+0x46>
f0103348:	e8 bd 1b 00 00       	call   f0104f0a <cpunum>
f010334d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103350:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0103356:	8b 50 48             	mov    0x48(%eax),%edx
f0103359:	83 ec 04             	sub    $0x4,%esp
f010335c:	53                   	push   %ebx
f010335d:	52                   	push   %edx
f010335e:	68 f8 67 10 f0       	push   $0xf01067f8
f0103363:	e8 45 04 00 00       	call   f01037ad <cprintf>
f0103368:	83 c4 10             	add    $0x10,%esp
f010336b:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103372:	e9 a9 00 00 00       	jmp    f0103420 <env_free+0x10d>
		lcr3(PADDR(kern_pgdir));
f0103377:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f010337c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103381:	76 0a                	jbe    f010338d <env_free+0x7a>
	return (physaddr_t)kva - KERNBASE;
f0103383:	05 00 00 00 10       	add    $0x10000000,%eax
f0103388:	0f 22 d8             	mov    %eax,%cr3
f010338b:	eb a2                	jmp    f010332f <env_free+0x1c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010338d:	50                   	push   %eax
f010338e:	68 38 56 10 f0       	push   $0xf0105638
f0103393:	68 a8 01 00 00       	push   $0x1a8
f0103398:	68 ad 67 10 f0       	push   $0xf01067ad
f010339d:	e8 f2 cc ff ff       	call   f0100094 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01033a2:	56                   	push   %esi
f01033a3:	68 14 56 10 f0       	push   $0xf0105614
f01033a8:	68 b7 01 00 00       	push   $0x1b7
f01033ad:	68 ad 67 10 f0       	push   $0xf01067ad
f01033b2:	e8 dd cc ff ff       	call   f0100094 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01033b7:	83 ec 08             	sub    $0x8,%esp
f01033ba:	89 d8                	mov    %ebx,%eax
f01033bc:	c1 e0 0c             	shl    $0xc,%eax
f01033bf:	0b 45 e4             	or     -0x1c(%ebp),%eax
f01033c2:	50                   	push   %eax
f01033c3:	ff 77 60             	pushl  0x60(%edi)
f01033c6:	e8 01 de ff ff       	call   f01011cc <page_remove>
f01033cb:	83 c4 10             	add    $0x10,%esp
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01033ce:	83 c3 01             	add    $0x1,%ebx
f01033d1:	83 c6 04             	add    $0x4,%esi
f01033d4:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f01033da:	74 07                	je     f01033e3 <env_free+0xd0>
			if (pt[pteno] & PTE_P)
f01033dc:	f6 06 01             	testb  $0x1,(%esi)
f01033df:	74 ed                	je     f01033ce <env_free+0xbb>
f01033e1:	eb d4                	jmp    f01033b7 <env_free+0xa4>
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f01033e3:	8b 47 60             	mov    0x60(%edi),%eax
f01033e6:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01033e9:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
	if (PGNUM(pa) >= npages)
f01033f0:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01033f3:	3b 05 88 1e 23 f0    	cmp    0xf0231e88,%eax
f01033f9:	73 69                	jae    f0103464 <env_free+0x151>
		page_decref(pa2page(pa));
f01033fb:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f01033fe:	a1 90 1e 23 f0       	mov    0xf0231e90,%eax
f0103403:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103406:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f0103409:	50                   	push   %eax
f010340a:	e8 ef db ff ff       	call   f0100ffe <page_decref>
f010340f:	83 c4 10             	add    $0x10,%esp
f0103412:	83 45 e0 04          	addl   $0x4,-0x20(%ebp)
f0103416:	8b 45 e0             	mov    -0x20(%ebp),%eax
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103419:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f010341e:	74 58                	je     f0103478 <env_free+0x165>
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103420:	8b 47 60             	mov    0x60(%edi),%eax
f0103423:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103426:	8b 34 10             	mov    (%eax,%edx,1),%esi
f0103429:	f7 c6 01 00 00 00    	test   $0x1,%esi
f010342f:	74 e1                	je     f0103412 <env_free+0xff>
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103431:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	if (PGNUM(pa) >= npages)
f0103437:	89 f0                	mov    %esi,%eax
f0103439:	c1 e8 0c             	shr    $0xc,%eax
f010343c:	89 45 dc             	mov    %eax,-0x24(%ebp)
f010343f:	39 05 88 1e 23 f0    	cmp    %eax,0xf0231e88
f0103445:	0f 86 57 ff ff ff    	jbe    f01033a2 <env_free+0x8f>
	return (void *)(pa + KERNBASE);
f010344b:	81 ee 00 00 00 10    	sub    $0x10000000,%esi
f0103451:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103454:	c1 e0 14             	shl    $0x14,%eax
f0103457:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f010345a:	bb 00 00 00 00       	mov    $0x0,%ebx
f010345f:	e9 78 ff ff ff       	jmp    f01033dc <env_free+0xc9>
		panic("pa2page called with invalid pa");
f0103464:	83 ec 04             	sub    $0x4,%esp
f0103467:	68 64 5c 10 f0       	push   $0xf0105c64
f010346c:	6a 51                	push   $0x51
f010346e:	68 78 64 10 f0       	push   $0xf0106478
f0103473:	e8 1c cc ff ff       	call   f0100094 <_panic>
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103478:	8b 47 60             	mov    0x60(%edi),%eax
	if ((uint32_t)kva < KERNBASE)
f010347b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103480:	76 49                	jbe    f01034cb <env_free+0x1b8>
	e->env_pgdir = 0;
f0103482:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
	return (physaddr_t)kva - KERNBASE;
f0103489:	05 00 00 00 10       	add    $0x10000000,%eax
	if (PGNUM(pa) >= npages)
f010348e:	c1 e8 0c             	shr    $0xc,%eax
f0103491:	3b 05 88 1e 23 f0    	cmp    0xf0231e88,%eax
f0103497:	73 47                	jae    f01034e0 <env_free+0x1cd>
	page_decref(pa2page(pa));
f0103499:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f010349c:	8b 15 90 1e 23 f0    	mov    0xf0231e90,%edx
f01034a2:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f01034a5:	50                   	push   %eax
f01034a6:	e8 53 db ff ff       	call   f0100ffe <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f01034ab:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f01034b2:	a1 48 12 23 f0       	mov    0xf0231248,%eax
f01034b7:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f01034ba:	89 3d 48 12 23 f0    	mov    %edi,0xf0231248
}
f01034c0:	83 c4 10             	add    $0x10,%esp
f01034c3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01034c6:	5b                   	pop    %ebx
f01034c7:	5e                   	pop    %esi
f01034c8:	5f                   	pop    %edi
f01034c9:	5d                   	pop    %ebp
f01034ca:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01034cb:	50                   	push   %eax
f01034cc:	68 38 56 10 f0       	push   $0xf0105638
f01034d1:	68 c5 01 00 00       	push   $0x1c5
f01034d6:	68 ad 67 10 f0       	push   $0xf01067ad
f01034db:	e8 b4 cb ff ff       	call   f0100094 <_panic>
		panic("pa2page called with invalid pa");
f01034e0:	83 ec 04             	sub    $0x4,%esp
f01034e3:	68 64 5c 10 f0       	push   $0xf0105c64
f01034e8:	6a 51                	push   $0x51
f01034ea:	68 78 64 10 f0       	push   $0xf0106478
f01034ef:	e8 a0 cb ff ff       	call   f0100094 <_panic>

f01034f4 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f01034f4:	55                   	push   %ebp
f01034f5:	89 e5                	mov    %esp,%ebp
f01034f7:	53                   	push   %ebx
f01034f8:	83 ec 04             	sub    $0x4,%esp
f01034fb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f01034fe:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0103502:	74 21                	je     f0103525 <env_destroy+0x31>
		e->env_status = ENV_DYING;
		return;
	}

	env_free(e);
f0103504:	83 ec 0c             	sub    $0xc,%esp
f0103507:	53                   	push   %ebx
f0103508:	e8 06 fe ff ff       	call   f0103313 <env_free>

	if (curenv == e) {
f010350d:	e8 f8 19 00 00       	call   f0104f0a <cpunum>
f0103512:	6b c0 74             	imul   $0x74,%eax,%eax
f0103515:	83 c4 10             	add    $0x10,%esp
f0103518:	39 98 28 20 23 f0    	cmp    %ebx,-0xfdcdfd8(%eax)
f010351e:	74 1e                	je     f010353e <env_destroy+0x4a>
		curenv = NULL;
		sched_yield();
	}
}
f0103520:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103523:	c9                   	leave  
f0103524:	c3                   	ret    
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103525:	e8 e0 19 00 00       	call   f0104f0a <cpunum>
f010352a:	6b c0 74             	imul   $0x74,%eax,%eax
f010352d:	39 98 28 20 23 f0    	cmp    %ebx,-0xfdcdfd8(%eax)
f0103533:	74 cf                	je     f0103504 <env_destroy+0x10>
		e->env_status = ENV_DYING;
f0103535:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f010353c:	eb e2                	jmp    f0103520 <env_destroy+0x2c>
		curenv = NULL;
f010353e:	e8 c7 19 00 00       	call   f0104f0a <cpunum>
f0103543:	6b c0 74             	imul   $0x74,%eax,%eax
f0103546:	c7 80 28 20 23 f0 00 	movl   $0x0,-0xfdcdfd8(%eax)
f010354d:	00 00 00 
		sched_yield();
f0103550:	e8 5f 08 00 00       	call   f0103db4 <sched_yield>

f0103555 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103555:	55                   	push   %ebp
f0103556:	89 e5                	mov    %esp,%ebp
f0103558:	53                   	push   %ebx
f0103559:	83 ec 04             	sub    $0x4,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f010355c:	e8 a9 19 00 00       	call   f0104f0a <cpunum>
f0103561:	6b c0 74             	imul   $0x74,%eax,%eax
f0103564:	8b 98 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%ebx
f010356a:	e8 9b 19 00 00       	call   f0104f0a <cpunum>
f010356f:	89 43 5c             	mov    %eax,0x5c(%ebx)

	asm volatile(
f0103572:	8b 65 08             	mov    0x8(%ebp),%esp
f0103575:	61                   	popa   
f0103576:	07                   	pop    %es
f0103577:	1f                   	pop    %ds
f0103578:	83 c4 08             	add    $0x8,%esp
f010357b:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f010357c:	83 ec 04             	sub    $0x4,%esp
f010357f:	68 0e 68 10 f0       	push   $0xf010680e
f0103584:	68 fc 01 00 00       	push   $0x1fc
f0103589:	68 ad 67 10 f0       	push   $0xf01067ad
f010358e:	e8 01 cb ff ff       	call   f0100094 <_panic>

f0103593 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103593:	55                   	push   %ebp
f0103594:	89 e5                	mov    %esp,%ebp
f0103596:	53                   	push   %ebx
f0103597:	83 ec 04             	sub    $0x4,%esp
f010359a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	if (curenv && curenv->env_status == ENV_RUNNING) {
f010359d:	e8 68 19 00 00       	call   f0104f0a <cpunum>
f01035a2:	6b c0 74             	imul   $0x74,%eax,%eax
f01035a5:	83 b8 28 20 23 f0 00 	cmpl   $0x0,-0xfdcdfd8(%eax)
f01035ac:	74 14                	je     f01035c2 <env_run+0x2f>
f01035ae:	e8 57 19 00 00       	call   f0104f0a <cpunum>
f01035b3:	6b c0 74             	imul   $0x74,%eax,%eax
f01035b6:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f01035bc:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01035c0:	74 34                	je     f01035f6 <env_run+0x63>
		 curenv->env_status = ENV_RUNNABLE;
	}
		 curenv = e;
f01035c2:	e8 43 19 00 00       	call   f0104f0a <cpunum>
f01035c7:	6b c0 74             	imul   $0x74,%eax,%eax
f01035ca:	89 98 28 20 23 f0    	mov    %ebx,-0xfdcdfd8(%eax)
		 e->env_status = ENV_RUNNING;
f01035d0:	c7 43 54 03 00 00 00 	movl   $0x3,0x54(%ebx)
		 e->env_runs++ ;
f01035d7:	83 43 58 01          	addl   $0x1,0x58(%ebx)
		 lcr3(PADDR(e->env_pgdir));
f01035db:	8b 43 60             	mov    0x60(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f01035de:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01035e3:	76 28                	jbe    f010360d <env_run+0x7a>
	return (physaddr_t)kva - KERNBASE;
f01035e5:	05 00 00 00 10       	add    $0x10000000,%eax
f01035ea:	0f 22 d8             	mov    %eax,%cr3

		 env_pop_tf(&e->env_tf);
f01035ed:	83 ec 0c             	sub    $0xc,%esp
f01035f0:	53                   	push   %ebx
f01035f1:	e8 5f ff ff ff       	call   f0103555 <env_pop_tf>
		 curenv->env_status = ENV_RUNNABLE;
f01035f6:	e8 0f 19 00 00       	call   f0104f0a <cpunum>
f01035fb:	6b c0 74             	imul   $0x74,%eax,%eax
f01035fe:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0103604:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
f010360b:	eb b5                	jmp    f01035c2 <env_run+0x2f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010360d:	50                   	push   %eax
f010360e:	68 38 56 10 f0       	push   $0xf0105638
f0103613:	68 20 02 00 00       	push   $0x220
f0103618:	68 ad 67 10 f0       	push   $0xf01067ad
f010361d:	e8 72 ca ff ff       	call   f0100094 <_panic>

f0103622 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103622:	55                   	push   %ebp
f0103623:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103625:	8b 45 08             	mov    0x8(%ebp),%eax
f0103628:	ba 70 00 00 00       	mov    $0x70,%edx
f010362d:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010362e:	ba 71 00 00 00       	mov    $0x71,%edx
f0103633:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103634:	0f b6 c0             	movzbl %al,%eax
}
f0103637:	5d                   	pop    %ebp
f0103638:	c3                   	ret    

f0103639 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103639:	55                   	push   %ebp
f010363a:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010363c:	8b 45 08             	mov    0x8(%ebp),%eax
f010363f:	ba 70 00 00 00       	mov    $0x70,%edx
f0103644:	ee                   	out    %al,(%dx)
f0103645:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103648:	ba 71 00 00 00       	mov    $0x71,%edx
f010364d:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f010364e:	5d                   	pop    %ebp
f010364f:	c3                   	ret    

f0103650 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0103650:	55                   	push   %ebp
f0103651:	89 e5                	mov    %esp,%ebp
f0103653:	56                   	push   %esi
f0103654:	53                   	push   %ebx
f0103655:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f0103658:	66 a3 a8 13 12 f0    	mov    %ax,0xf01213a8
	if (!didinit)
f010365e:	80 3d 4c 12 23 f0 00 	cmpb   $0x0,0xf023124c
f0103665:	75 07                	jne    f010366e <irq_setmask_8259A+0x1e>
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
}
f0103667:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010366a:	5b                   	pop    %ebx
f010366b:	5e                   	pop    %esi
f010366c:	5d                   	pop    %ebp
f010366d:	c3                   	ret    
f010366e:	89 c6                	mov    %eax,%esi
f0103670:	ba 21 00 00 00       	mov    $0x21,%edx
f0103675:	ee                   	out    %al,(%dx)
	outb(IO_PIC2+1, (char)(mask >> 8));
f0103676:	66 c1 e8 08          	shr    $0x8,%ax
f010367a:	ba a1 00 00 00       	mov    $0xa1,%edx
f010367f:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f0103680:	83 ec 0c             	sub    $0xc,%esp
f0103683:	68 4e 68 10 f0       	push   $0xf010684e
f0103688:	e8 20 01 00 00       	call   f01037ad <cprintf>
f010368d:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f0103690:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0103695:	0f b7 f6             	movzwl %si,%esi
f0103698:	f7 d6                	not    %esi
f010369a:	eb 19                	jmp    f01036b5 <irq_setmask_8259A+0x65>
			cprintf(" %d", i);
f010369c:	83 ec 08             	sub    $0x8,%esp
f010369f:	53                   	push   %ebx
f01036a0:	68 b4 6c 10 f0       	push   $0xf0106cb4
f01036a5:	e8 03 01 00 00       	call   f01037ad <cprintf>
f01036aa:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f01036ad:	83 c3 01             	add    $0x1,%ebx
f01036b0:	83 fb 10             	cmp    $0x10,%ebx
f01036b3:	74 07                	je     f01036bc <irq_setmask_8259A+0x6c>
		if (~mask & (1<<i))
f01036b5:	0f a3 de             	bt     %ebx,%esi
f01036b8:	73 f3                	jae    f01036ad <irq_setmask_8259A+0x5d>
f01036ba:	eb e0                	jmp    f010369c <irq_setmask_8259A+0x4c>
	cprintf("\n");
f01036bc:	83 ec 0c             	sub    $0xc,%esp
f01036bf:	68 6b 67 10 f0       	push   $0xf010676b
f01036c4:	e8 e4 00 00 00       	call   f01037ad <cprintf>
f01036c9:	83 c4 10             	add    $0x10,%esp
f01036cc:	eb 99                	jmp    f0103667 <irq_setmask_8259A+0x17>

f01036ce <pic_init>:
{
f01036ce:	55                   	push   %ebp
f01036cf:	89 e5                	mov    %esp,%ebp
f01036d1:	57                   	push   %edi
f01036d2:	56                   	push   %esi
f01036d3:	53                   	push   %ebx
f01036d4:	83 ec 0c             	sub    $0xc,%esp
	didinit = 1;
f01036d7:	c6 05 4c 12 23 f0 01 	movb   $0x1,0xf023124c
f01036de:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01036e3:	bb 21 00 00 00       	mov    $0x21,%ebx
f01036e8:	89 da                	mov    %ebx,%edx
f01036ea:	ee                   	out    %al,(%dx)
f01036eb:	b9 a1 00 00 00       	mov    $0xa1,%ecx
f01036f0:	89 ca                	mov    %ecx,%edx
f01036f2:	ee                   	out    %al,(%dx)
f01036f3:	bf 11 00 00 00       	mov    $0x11,%edi
f01036f8:	be 20 00 00 00       	mov    $0x20,%esi
f01036fd:	89 f8                	mov    %edi,%eax
f01036ff:	89 f2                	mov    %esi,%edx
f0103701:	ee                   	out    %al,(%dx)
f0103702:	b8 20 00 00 00       	mov    $0x20,%eax
f0103707:	89 da                	mov    %ebx,%edx
f0103709:	ee                   	out    %al,(%dx)
f010370a:	b8 04 00 00 00       	mov    $0x4,%eax
f010370f:	ee                   	out    %al,(%dx)
f0103710:	b8 03 00 00 00       	mov    $0x3,%eax
f0103715:	ee                   	out    %al,(%dx)
f0103716:	bb a0 00 00 00       	mov    $0xa0,%ebx
f010371b:	89 f8                	mov    %edi,%eax
f010371d:	89 da                	mov    %ebx,%edx
f010371f:	ee                   	out    %al,(%dx)
f0103720:	b8 28 00 00 00       	mov    $0x28,%eax
f0103725:	89 ca                	mov    %ecx,%edx
f0103727:	ee                   	out    %al,(%dx)
f0103728:	b8 02 00 00 00       	mov    $0x2,%eax
f010372d:	ee                   	out    %al,(%dx)
f010372e:	b8 01 00 00 00       	mov    $0x1,%eax
f0103733:	ee                   	out    %al,(%dx)
f0103734:	bf 68 00 00 00       	mov    $0x68,%edi
f0103739:	89 f8                	mov    %edi,%eax
f010373b:	89 f2                	mov    %esi,%edx
f010373d:	ee                   	out    %al,(%dx)
f010373e:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0103743:	89 c8                	mov    %ecx,%eax
f0103745:	ee                   	out    %al,(%dx)
f0103746:	89 f8                	mov    %edi,%eax
f0103748:	89 da                	mov    %ebx,%edx
f010374a:	ee                   	out    %al,(%dx)
f010374b:	89 c8                	mov    %ecx,%eax
f010374d:	ee                   	out    %al,(%dx)
	if (irq_mask_8259A != 0xFFFF)
f010374e:	0f b7 05 a8 13 12 f0 	movzwl 0xf01213a8,%eax
f0103755:	66 83 f8 ff          	cmp    $0xffff,%ax
f0103759:	75 08                	jne    f0103763 <pic_init+0x95>
}
f010375b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010375e:	5b                   	pop    %ebx
f010375f:	5e                   	pop    %esi
f0103760:	5f                   	pop    %edi
f0103761:	5d                   	pop    %ebp
f0103762:	c3                   	ret    
		irq_setmask_8259A(irq_mask_8259A);
f0103763:	83 ec 0c             	sub    $0xc,%esp
f0103766:	0f b7 c0             	movzwl %ax,%eax
f0103769:	50                   	push   %eax
f010376a:	e8 e1 fe ff ff       	call   f0103650 <irq_setmask_8259A>
f010376f:	83 c4 10             	add    $0x10,%esp
}
f0103772:	eb e7                	jmp    f010375b <pic_init+0x8d>

f0103774 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103774:	55                   	push   %ebp
f0103775:	89 e5                	mov    %esp,%ebp
f0103777:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f010377a:	ff 75 08             	pushl  0x8(%ebp)
f010377d:	e8 14 d0 ff ff       	call   f0100796 <cputchar>
	*cnt++;
}
f0103782:	83 c4 10             	add    $0x10,%esp
f0103785:	c9                   	leave  
f0103786:	c3                   	ret    

f0103787 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103787:	55                   	push   %ebp
f0103788:	89 e5                	mov    %esp,%ebp
f010378a:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f010378d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103794:	ff 75 0c             	pushl  0xc(%ebp)
f0103797:	ff 75 08             	pushl  0x8(%ebp)
f010379a:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010379d:	50                   	push   %eax
f010379e:	68 74 37 10 f0       	push   $0xf0103774
f01037a3:	e8 5a 0a 00 00       	call   f0104202 <vprintfmt>
	return cnt;
}
f01037a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01037ab:	c9                   	leave  
f01037ac:	c3                   	ret    

f01037ad <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01037ad:	55                   	push   %ebp
f01037ae:	89 e5                	mov    %esp,%ebp
f01037b0:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01037b3:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f01037b6:	50                   	push   %eax
f01037b7:	ff 75 08             	pushl  0x8(%ebp)
f01037ba:	e8 c8 ff ff ff       	call   f0103787 <vcprintf>
	va_end(ap);

	return cnt;
}
f01037bf:	c9                   	leave  
f01037c0:	c3                   	ret    

f01037c1 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f01037c1:	55                   	push   %ebp
f01037c2:	89 e5                	mov    %esp,%ebp
f01037c4:	56                   	push   %esi
f01037c5:	53                   	push   %ebx
	// get a triple fault.  If you set up an individual CPU's TSS
	// wrong, you may not get a fault until you try to return from
	// user space on that CPU.
	//
	// LAB 4: Your code here:
	struct Taskstate *this_ts = &thiscpu->cpu_ts;
f01037c6:	e8 3f 17 00 00       	call   f0104f0a <cpunum>
f01037cb:	6b f0 74             	imul   $0x74,%eax,%esi
f01037ce:	8d 9e 2c 20 23 f0    	lea    -0xfdcdfd4(%esi),%ebx
	this_ts->ts_esp0 = KSTACKTOP - thiscpu->cpu_id*(KSTKSIZE + KSTKGAP);
f01037d4:	e8 31 17 00 00       	call   f0104f0a <cpunum>
f01037d9:	6b c0 74             	imul   $0x74,%eax,%eax
f01037dc:	0f b6 88 20 20 23 f0 	movzbl -0xfdcdfe0(%eax),%ecx
f01037e3:	c1 e1 10             	shl    $0x10,%ecx
f01037e6:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
f01037eb:	29 c8                	sub    %ecx,%eax
f01037ed:	89 86 30 20 23 f0    	mov    %eax,-0xfdcdfd0(%esi)
	this_ts->ts_ss0 = GD_KD;
f01037f3:	66 c7 86 34 20 23 f0 	movw   $0x10,-0xfdcdfcc(%esi)
f01037fa:	10 00 
	this_ts->ts_iomb = sizeof(struct Taskstate);
f01037fc:	66 c7 86 92 20 23 f0 	movw   $0x68,-0xfdcdf6e(%esi)
f0103803:	68 00 
//	ts.ts_esp0 = KSTACKTOP;
//	ts.ts_ss0 = GD_KD;
//	ts.ts_iomb = sizeof(struct Taskstate);

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3) + thiscpu->cpu_id] = SEG16(STS_T32A, (uint32_t) (this_ts),
f0103805:	e8 00 17 00 00       	call   f0104f0a <cpunum>
f010380a:	6b c0 74             	imul   $0x74,%eax,%eax
f010380d:	0f b6 80 20 20 23 f0 	movzbl -0xfdcdfe0(%eax),%eax
f0103814:	83 c0 05             	add    $0x5,%eax
f0103817:	66 c7 04 c5 40 13 12 	movw   $0x67,-0xfedecc0(,%eax,8)
f010381e:	f0 67 00 
f0103821:	66 89 1c c5 42 13 12 	mov    %bx,-0xfedecbe(,%eax,8)
f0103828:	f0 
f0103829:	89 da                	mov    %ebx,%edx
f010382b:	c1 ea 10             	shr    $0x10,%edx
f010382e:	88 14 c5 44 13 12 f0 	mov    %dl,-0xfedecbc(,%eax,8)
f0103835:	c6 04 c5 45 13 12 f0 	movb   $0x99,-0xfedecbb(,%eax,8)
f010383c:	99 
f010383d:	c6 04 c5 46 13 12 f0 	movb   $0x40,-0xfedecba(,%eax,8)
f0103844:	40 
f0103845:	c1 eb 18             	shr    $0x18,%ebx
f0103848:	88 1c c5 47 13 12 f0 	mov    %bl,-0xfedecb9(,%eax,8)
					sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3) + thiscpu->cpu_id].sd_s = 0;
f010384f:	e8 b6 16 00 00       	call   f0104f0a <cpunum>
f0103854:	6b c0 74             	imul   $0x74,%eax,%eax
f0103857:	0f b6 80 20 20 23 f0 	movzbl -0xfdcdfe0(%eax),%eax
f010385e:	80 24 c5 6d 13 12 f0 	andb   $0xef,-0xfedec93(,%eax,8)
f0103865:	ef 

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0 + (thiscpu->cpu_id << 3));
f0103866:	e8 9f 16 00 00       	call   f0104f0a <cpunum>
f010386b:	6b c0 74             	imul   $0x74,%eax,%eax
f010386e:	0f b6 80 20 20 23 f0 	movzbl -0xfdcdfe0(%eax),%eax
f0103875:	8d 04 c5 28 00 00 00 	lea    0x28(,%eax,8),%eax
	asm volatile("ltr %0" : : "r" (sel));
f010387c:	0f 00 d8             	ltr    %ax
	asm volatile("lidt (%0)" : : "r" (p));
f010387f:	b8 ac 13 12 f0       	mov    $0xf01213ac,%eax
f0103884:	0f 01 18             	lidtl  (%eax)

	// Load the IDT
	lidt(&idt_pd);
}
f0103887:	5b                   	pop    %ebx
f0103888:	5e                   	pop    %esi
f0103889:	5d                   	pop    %ebp
f010388a:	c3                   	ret    

f010388b <trap_init>:
{
f010388b:	55                   	push   %ebp
f010388c:	89 e5                	mov    %esp,%ebp
f010388e:	83 ec 08             	sub    $0x8,%esp
	trap_init_percpu();
f0103891:	e8 2b ff ff ff       	call   f01037c1 <trap_init_percpu>
}
f0103896:	c9                   	leave  
f0103897:	c3                   	ret    

f0103898 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103898:	55                   	push   %ebp
f0103899:	89 e5                	mov    %esp,%ebp
f010389b:	53                   	push   %ebx
f010389c:	83 ec 0c             	sub    $0xc,%esp
f010389f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f01038a2:	ff 33                	pushl  (%ebx)
f01038a4:	68 62 68 10 f0       	push   $0xf0106862
f01038a9:	e8 ff fe ff ff       	call   f01037ad <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f01038ae:	83 c4 08             	add    $0x8,%esp
f01038b1:	ff 73 04             	pushl  0x4(%ebx)
f01038b4:	68 71 68 10 f0       	push   $0xf0106871
f01038b9:	e8 ef fe ff ff       	call   f01037ad <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f01038be:	83 c4 08             	add    $0x8,%esp
f01038c1:	ff 73 08             	pushl  0x8(%ebx)
f01038c4:	68 80 68 10 f0       	push   $0xf0106880
f01038c9:	e8 df fe ff ff       	call   f01037ad <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f01038ce:	83 c4 08             	add    $0x8,%esp
f01038d1:	ff 73 0c             	pushl  0xc(%ebx)
f01038d4:	68 8f 68 10 f0       	push   $0xf010688f
f01038d9:	e8 cf fe ff ff       	call   f01037ad <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f01038de:	83 c4 08             	add    $0x8,%esp
f01038e1:	ff 73 10             	pushl  0x10(%ebx)
f01038e4:	68 9e 68 10 f0       	push   $0xf010689e
f01038e9:	e8 bf fe ff ff       	call   f01037ad <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f01038ee:	83 c4 08             	add    $0x8,%esp
f01038f1:	ff 73 14             	pushl  0x14(%ebx)
f01038f4:	68 ad 68 10 f0       	push   $0xf01068ad
f01038f9:	e8 af fe ff ff       	call   f01037ad <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f01038fe:	83 c4 08             	add    $0x8,%esp
f0103901:	ff 73 18             	pushl  0x18(%ebx)
f0103904:	68 bc 68 10 f0       	push   $0xf01068bc
f0103909:	e8 9f fe ff ff       	call   f01037ad <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f010390e:	83 c4 08             	add    $0x8,%esp
f0103911:	ff 73 1c             	pushl  0x1c(%ebx)
f0103914:	68 cb 68 10 f0       	push   $0xf01068cb
f0103919:	e8 8f fe ff ff       	call   f01037ad <cprintf>
}
f010391e:	83 c4 10             	add    $0x10,%esp
f0103921:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103924:	c9                   	leave  
f0103925:	c3                   	ret    

f0103926 <print_trapframe>:
{
f0103926:	55                   	push   %ebp
f0103927:	89 e5                	mov    %esp,%ebp
f0103929:	56                   	push   %esi
f010392a:	53                   	push   %ebx
f010392b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f010392e:	e8 d7 15 00 00       	call   f0104f0a <cpunum>
f0103933:	83 ec 04             	sub    $0x4,%esp
f0103936:	50                   	push   %eax
f0103937:	53                   	push   %ebx
f0103938:	68 2f 69 10 f0       	push   $0xf010692f
f010393d:	e8 6b fe ff ff       	call   f01037ad <cprintf>
	print_regs(&tf->tf_regs);
f0103942:	89 1c 24             	mov    %ebx,(%esp)
f0103945:	e8 4e ff ff ff       	call   f0103898 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f010394a:	83 c4 08             	add    $0x8,%esp
f010394d:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103951:	50                   	push   %eax
f0103952:	68 4d 69 10 f0       	push   $0xf010694d
f0103957:	e8 51 fe ff ff       	call   f01037ad <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f010395c:	83 c4 08             	add    $0x8,%esp
f010395f:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103963:	50                   	push   %eax
f0103964:	68 60 69 10 f0       	push   $0xf0106960
f0103969:	e8 3f fe ff ff       	call   f01037ad <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f010396e:	8b 43 28             	mov    0x28(%ebx),%eax
	if (trapno < ARRAY_SIZE(excnames))
f0103971:	83 c4 10             	add    $0x10,%esp
f0103974:	83 f8 13             	cmp    $0x13,%eax
f0103977:	0f 86 e1 00 00 00    	jbe    f0103a5e <print_trapframe+0x138>
		return "System call";
f010397d:	ba da 68 10 f0       	mov    $0xf01068da,%edx
	if (trapno == T_SYSCALL)
f0103982:	83 f8 30             	cmp    $0x30,%eax
f0103985:	74 13                	je     f010399a <print_trapframe+0x74>
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0103987:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
f010398a:	83 fa 0f             	cmp    $0xf,%edx
f010398d:	ba e6 68 10 f0       	mov    $0xf01068e6,%edx
f0103992:	b9 f5 68 10 f0       	mov    $0xf01068f5,%ecx
f0103997:	0f 46 d1             	cmovbe %ecx,%edx
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f010399a:	83 ec 04             	sub    $0x4,%esp
f010399d:	52                   	push   %edx
f010399e:	50                   	push   %eax
f010399f:	68 73 69 10 f0       	push   $0xf0106973
f01039a4:	e8 04 fe ff ff       	call   f01037ad <cprintf>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f01039a9:	83 c4 10             	add    $0x10,%esp
f01039ac:	39 1d 60 1a 23 f0    	cmp    %ebx,0xf0231a60
f01039b2:	0f 84 b2 00 00 00    	je     f0103a6a <print_trapframe+0x144>
	cprintf("  err  0x%08x", tf->tf_err);
f01039b8:	83 ec 08             	sub    $0x8,%esp
f01039bb:	ff 73 2c             	pushl  0x2c(%ebx)
f01039be:	68 94 69 10 f0       	push   $0xf0106994
f01039c3:	e8 e5 fd ff ff       	call   f01037ad <cprintf>
	if (tf->tf_trapno == T_PGFLT)
f01039c8:	83 c4 10             	add    $0x10,%esp
f01039cb:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f01039cf:	0f 85 b8 00 00 00    	jne    f0103a8d <print_trapframe+0x167>
			tf->tf_err & 1 ? "protection" : "not-present");
f01039d5:	8b 43 2c             	mov    0x2c(%ebx),%eax
		cprintf(" [%s, %s, %s]\n",
f01039d8:	89 c2                	mov    %eax,%edx
f01039da:	83 e2 01             	and    $0x1,%edx
f01039dd:	b9 08 69 10 f0       	mov    $0xf0106908,%ecx
f01039e2:	ba 13 69 10 f0       	mov    $0xf0106913,%edx
f01039e7:	0f 44 ca             	cmove  %edx,%ecx
f01039ea:	89 c2                	mov    %eax,%edx
f01039ec:	83 e2 02             	and    $0x2,%edx
f01039ef:	be 1f 69 10 f0       	mov    $0xf010691f,%esi
f01039f4:	ba 25 69 10 f0       	mov    $0xf0106925,%edx
f01039f9:	0f 45 d6             	cmovne %esi,%edx
f01039fc:	83 e0 04             	and    $0x4,%eax
f01039ff:	b8 2a 69 10 f0       	mov    $0xf010692a,%eax
f0103a04:	be 5f 6a 10 f0       	mov    $0xf0106a5f,%esi
f0103a09:	0f 44 c6             	cmove  %esi,%eax
f0103a0c:	51                   	push   %ecx
f0103a0d:	52                   	push   %edx
f0103a0e:	50                   	push   %eax
f0103a0f:	68 a2 69 10 f0       	push   $0xf01069a2
f0103a14:	e8 94 fd ff ff       	call   f01037ad <cprintf>
f0103a19:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103a1c:	83 ec 08             	sub    $0x8,%esp
f0103a1f:	ff 73 30             	pushl  0x30(%ebx)
f0103a22:	68 b1 69 10 f0       	push   $0xf01069b1
f0103a27:	e8 81 fd ff ff       	call   f01037ad <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103a2c:	83 c4 08             	add    $0x8,%esp
f0103a2f:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103a33:	50                   	push   %eax
f0103a34:	68 c0 69 10 f0       	push   $0xf01069c0
f0103a39:	e8 6f fd ff ff       	call   f01037ad <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103a3e:	83 c4 08             	add    $0x8,%esp
f0103a41:	ff 73 38             	pushl  0x38(%ebx)
f0103a44:	68 d3 69 10 f0       	push   $0xf01069d3
f0103a49:	e8 5f fd ff ff       	call   f01037ad <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0103a4e:	83 c4 10             	add    $0x10,%esp
f0103a51:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103a55:	75 4b                	jne    f0103aa2 <print_trapframe+0x17c>
}
f0103a57:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103a5a:	5b                   	pop    %ebx
f0103a5b:	5e                   	pop    %esi
f0103a5c:	5d                   	pop    %ebp
f0103a5d:	c3                   	ret    
		return excnames[trapno];
f0103a5e:	8b 14 85 e0 6b 10 f0 	mov    -0xfef9420(,%eax,4),%edx
f0103a65:	e9 30 ff ff ff       	jmp    f010399a <print_trapframe+0x74>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103a6a:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103a6e:	0f 85 44 ff ff ff    	jne    f01039b8 <print_trapframe+0x92>
	asm volatile("movl %%cr2,%0" : "=r" (val));
f0103a74:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0103a77:	83 ec 08             	sub    $0x8,%esp
f0103a7a:	50                   	push   %eax
f0103a7b:	68 85 69 10 f0       	push   $0xf0106985
f0103a80:	e8 28 fd ff ff       	call   f01037ad <cprintf>
f0103a85:	83 c4 10             	add    $0x10,%esp
f0103a88:	e9 2b ff ff ff       	jmp    f01039b8 <print_trapframe+0x92>
		cprintf("\n");
f0103a8d:	83 ec 0c             	sub    $0xc,%esp
f0103a90:	68 6b 67 10 f0       	push   $0xf010676b
f0103a95:	e8 13 fd ff ff       	call   f01037ad <cprintf>
f0103a9a:	83 c4 10             	add    $0x10,%esp
f0103a9d:	e9 7a ff ff ff       	jmp    f0103a1c <print_trapframe+0xf6>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0103aa2:	83 ec 08             	sub    $0x8,%esp
f0103aa5:	ff 73 3c             	pushl  0x3c(%ebx)
f0103aa8:	68 e2 69 10 f0       	push   $0xf01069e2
f0103aad:	e8 fb fc ff ff       	call   f01037ad <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0103ab2:	83 c4 08             	add    $0x8,%esp
f0103ab5:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0103ab9:	50                   	push   %eax
f0103aba:	68 f1 69 10 f0       	push   $0xf01069f1
f0103abf:	e8 e9 fc ff ff       	call   f01037ad <cprintf>
f0103ac4:	83 c4 10             	add    $0x10,%esp
}
f0103ac7:	eb 8e                	jmp    f0103a57 <print_trapframe+0x131>

f0103ac9 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0103ac9:	55                   	push   %ebp
f0103aca:	89 e5                	mov    %esp,%ebp
f0103acc:	57                   	push   %edi
f0103acd:	56                   	push   %esi
f0103ace:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0103ad1:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f0103ad2:	83 3d 80 1e 23 f0 00 	cmpl   $0x0,0xf0231e80
f0103ad9:	74 01                	je     f0103adc <trap+0x13>
		asm volatile("hlt");
f0103adb:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f0103adc:	e8 29 14 00 00       	call   f0104f0a <cpunum>
f0103ae1:	6b d0 74             	imul   $0x74,%eax,%edx
f0103ae4:	83 c2 04             	add    $0x4,%edx
	asm volatile("lock; xchgl %0, %1"
f0103ae7:	b8 01 00 00 00       	mov    $0x1,%eax
f0103aec:	f0 87 82 20 20 23 f0 	lock xchg %eax,-0xfdcdfe0(%edx)
f0103af3:	83 f8 02             	cmp    $0x2,%eax
f0103af6:	0f 84 8a 00 00 00    	je     f0103b86 <trap+0xbd>
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f0103afc:	9c                   	pushf  
f0103afd:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0103afe:	f6 c4 02             	test   $0x2,%ah
f0103b01:	0f 85 94 00 00 00    	jne    f0103b9b <trap+0xd2>

	if ((tf->tf_cs & 3) == 3) {
f0103b07:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0103b0b:	83 e0 03             	and    $0x3,%eax
f0103b0e:	66 83 f8 03          	cmp    $0x3,%ax
f0103b12:	0f 84 9c 00 00 00    	je     f0103bb4 <trap+0xeb>
		tf = &curenv->env_tf;
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0103b18:	89 35 60 1a 23 f0    	mov    %esi,0xf0231a60
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f0103b1e:	83 7e 28 27          	cmpl   $0x27,0x28(%esi)
f0103b22:	0f 84 21 01 00 00    	je     f0103c49 <trap+0x180>
	print_trapframe(tf);
f0103b28:	83 ec 0c             	sub    $0xc,%esp
f0103b2b:	56                   	push   %esi
f0103b2c:	e8 f5 fd ff ff       	call   f0103926 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0103b31:	83 c4 10             	add    $0x10,%esp
f0103b34:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0103b39:	0f 84 27 01 00 00    	je     f0103c66 <trap+0x19d>
		env_destroy(curenv);
f0103b3f:	e8 c6 13 00 00       	call   f0104f0a <cpunum>
f0103b44:	83 ec 0c             	sub    $0xc,%esp
f0103b47:	6b c0 74             	imul   $0x74,%eax,%eax
f0103b4a:	ff b0 28 20 23 f0    	pushl  -0xfdcdfd8(%eax)
f0103b50:	e8 9f f9 ff ff       	call   f01034f4 <env_destroy>
f0103b55:	83 c4 10             	add    $0x10,%esp
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f0103b58:	e8 ad 13 00 00       	call   f0104f0a <cpunum>
f0103b5d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103b60:	83 b8 28 20 23 f0 00 	cmpl   $0x0,-0xfdcdfd8(%eax)
f0103b67:	74 18                	je     f0103b81 <trap+0xb8>
f0103b69:	e8 9c 13 00 00       	call   f0104f0a <cpunum>
f0103b6e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103b71:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0103b77:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103b7b:	0f 84 fc 00 00 00    	je     f0103c7d <trap+0x1b4>
		env_run(curenv);
	else
		sched_yield();
f0103b81:	e8 2e 02 00 00       	call   f0103db4 <sched_yield>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0103b86:	83 ec 0c             	sub    $0xc,%esp
f0103b89:	68 c0 13 12 f0       	push   $0xf01213c0
f0103b8e:	e8 e7 15 00 00       	call   f010517a <spin_lock>
f0103b93:	83 c4 10             	add    $0x10,%esp
f0103b96:	e9 61 ff ff ff       	jmp    f0103afc <trap+0x33>
	assert(!(read_eflags() & FL_IF));
f0103b9b:	68 04 6a 10 f0       	push   $0xf0106a04
f0103ba0:	68 92 64 10 f0       	push   $0xf0106492
f0103ba5:	68 e7 00 00 00       	push   $0xe7
f0103baa:	68 1d 6a 10 f0       	push   $0xf0106a1d
f0103baf:	e8 e0 c4 ff ff       	call   f0100094 <_panic>
		assert(curenv);
f0103bb4:	e8 51 13 00 00       	call   f0104f0a <cpunum>
f0103bb9:	6b c0 74             	imul   $0x74,%eax,%eax
f0103bbc:	83 b8 28 20 23 f0 00 	cmpl   $0x0,-0xfdcdfd8(%eax)
f0103bc3:	74 3e                	je     f0103c03 <trap+0x13a>
		if (curenv->env_status == ENV_DYING) {
f0103bc5:	e8 40 13 00 00       	call   f0104f0a <cpunum>
f0103bca:	6b c0 74             	imul   $0x74,%eax,%eax
f0103bcd:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0103bd3:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0103bd7:	74 43                	je     f0103c1c <trap+0x153>
		curenv->env_tf = *tf;
f0103bd9:	e8 2c 13 00 00       	call   f0104f0a <cpunum>
f0103bde:	6b c0 74             	imul   $0x74,%eax,%eax
f0103be1:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0103be7:	b9 11 00 00 00       	mov    $0x11,%ecx
f0103bec:	89 c7                	mov    %eax,%edi
f0103bee:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		tf = &curenv->env_tf;
f0103bf0:	e8 15 13 00 00       	call   f0104f0a <cpunum>
f0103bf5:	6b c0 74             	imul   $0x74,%eax,%eax
f0103bf8:	8b b0 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%esi
f0103bfe:	e9 15 ff ff ff       	jmp    f0103b18 <trap+0x4f>
		assert(curenv);
f0103c03:	68 29 6a 10 f0       	push   $0xf0106a29
f0103c08:	68 92 64 10 f0       	push   $0xf0106492
f0103c0d:	68 ee 00 00 00       	push   $0xee
f0103c12:	68 1d 6a 10 f0       	push   $0xf0106a1d
f0103c17:	e8 78 c4 ff ff       	call   f0100094 <_panic>
			env_free(curenv);
f0103c1c:	e8 e9 12 00 00       	call   f0104f0a <cpunum>
f0103c21:	83 ec 0c             	sub    $0xc,%esp
f0103c24:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c27:	ff b0 28 20 23 f0    	pushl  -0xfdcdfd8(%eax)
f0103c2d:	e8 e1 f6 ff ff       	call   f0103313 <env_free>
			curenv = NULL;
f0103c32:	e8 d3 12 00 00       	call   f0104f0a <cpunum>
f0103c37:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c3a:	c7 80 28 20 23 f0 00 	movl   $0x0,-0xfdcdfd8(%eax)
f0103c41:	00 00 00 
			sched_yield();
f0103c44:	e8 6b 01 00 00       	call   f0103db4 <sched_yield>
		cprintf("Spurious interrupt on irq 7\n");
f0103c49:	83 ec 0c             	sub    $0xc,%esp
f0103c4c:	68 30 6a 10 f0       	push   $0xf0106a30
f0103c51:	e8 57 fb ff ff       	call   f01037ad <cprintf>
		print_trapframe(tf);
f0103c56:	89 34 24             	mov    %esi,(%esp)
f0103c59:	e8 c8 fc ff ff       	call   f0103926 <print_trapframe>
f0103c5e:	83 c4 10             	add    $0x10,%esp
f0103c61:	e9 f2 fe ff ff       	jmp    f0103b58 <trap+0x8f>
		panic("unhandled trap in kernel");
f0103c66:	83 ec 04             	sub    $0x4,%esp
f0103c69:	68 4d 6a 10 f0       	push   $0xf0106a4d
f0103c6e:	68 cd 00 00 00       	push   $0xcd
f0103c73:	68 1d 6a 10 f0       	push   $0xf0106a1d
f0103c78:	e8 17 c4 ff ff       	call   f0100094 <_panic>
		env_run(curenv);
f0103c7d:	e8 88 12 00 00       	call   f0104f0a <cpunum>
f0103c82:	83 ec 0c             	sub    $0xc,%esp
f0103c85:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c88:	ff b0 28 20 23 f0    	pushl  -0xfdcdfd8(%eax)
f0103c8e:	e8 00 f9 ff ff       	call   f0103593 <env_run>

f0103c93 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0103c93:	55                   	push   %ebp
f0103c94:	89 e5                	mov    %esp,%ebp
f0103c96:	57                   	push   %edi
f0103c97:	56                   	push   %esi
f0103c98:	53                   	push   %ebx
f0103c99:	83 ec 0c             	sub    $0xc,%esp
f0103c9c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	asm volatile("movl %%cr2,%0" : "=r" (val));
f0103c9f:	0f 20 d6             	mov    %cr2,%esi
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103ca2:	8b 7b 30             	mov    0x30(%ebx),%edi
		curenv->env_id, fault_va, tf->tf_eip);
f0103ca5:	e8 60 12 00 00       	call   f0104f0a <cpunum>
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103caa:	57                   	push   %edi
f0103cab:	56                   	push   %esi
		curenv->env_id, fault_va, tf->tf_eip);
f0103cac:	6b c0 74             	imul   $0x74,%eax,%eax
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103caf:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0103cb5:	ff 70 48             	pushl  0x48(%eax)
f0103cb8:	68 ac 6b 10 f0       	push   $0xf0106bac
f0103cbd:	e8 eb fa ff ff       	call   f01037ad <cprintf>
	print_trapframe(tf);
f0103cc2:	89 1c 24             	mov    %ebx,(%esp)
f0103cc5:	e8 5c fc ff ff       	call   f0103926 <print_trapframe>
	env_destroy(curenv);
f0103cca:	e8 3b 12 00 00       	call   f0104f0a <cpunum>
f0103ccf:	83 c4 04             	add    $0x4,%esp
f0103cd2:	6b c0 74             	imul   $0x74,%eax,%eax
f0103cd5:	ff b0 28 20 23 f0    	pushl  -0xfdcdfd8(%eax)
f0103cdb:	e8 14 f8 ff ff       	call   f01034f4 <env_destroy>
}
f0103ce0:	83 c4 10             	add    $0x10,%esp
f0103ce3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103ce6:	5b                   	pop    %ebx
f0103ce7:	5e                   	pop    %esi
f0103ce8:	5f                   	pop    %edi
f0103ce9:	5d                   	pop    %ebp
f0103cea:	c3                   	ret    

f0103ceb <sched_halt>:
f0103ceb:	55                   	push   %ebp
f0103cec:	89 e5                	mov    %esp,%ebp
f0103cee:	83 ec 08             	sub    $0x8,%esp
f0103cf1:	a1 44 12 23 f0       	mov    0xf0231244,%eax
f0103cf6:	8d 50 54             	lea    0x54(%eax),%edx
f0103cf9:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103cfe:	8b 02                	mov    (%edx),%eax
f0103d00:	83 e8 01             	sub    $0x1,%eax
f0103d03:	83 f8 02             	cmp    $0x2,%eax
f0103d06:	76 2d                	jbe    f0103d35 <sched_halt+0x4a>
f0103d08:	83 c1 01             	add    $0x1,%ecx
f0103d0b:	83 c2 7c             	add    $0x7c,%edx
f0103d0e:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f0103d14:	75 e8                	jne    f0103cfe <sched_halt+0x13>
f0103d16:	83 ec 0c             	sub    $0xc,%esp
f0103d19:	68 30 6c 10 f0       	push   $0xf0106c30
f0103d1e:	e8 8a fa ff ff       	call   f01037ad <cprintf>
f0103d23:	83 c4 10             	add    $0x10,%esp
f0103d26:	83 ec 0c             	sub    $0xc,%esp
f0103d29:	6a 00                	push   $0x0
f0103d2b:	e8 03 cc ff ff       	call   f0100933 <monitor>
f0103d30:	83 c4 10             	add    $0x10,%esp
f0103d33:	eb f1                	jmp    f0103d26 <sched_halt+0x3b>
f0103d35:	e8 d0 11 00 00       	call   f0104f0a <cpunum>
f0103d3a:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d3d:	c7 80 28 20 23 f0 00 	movl   $0x0,-0xfdcdfd8(%eax)
f0103d44:	00 00 00 
f0103d47:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f0103d4c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103d51:	76 4f                	jbe    f0103da2 <sched_halt+0xb7>
f0103d53:	05 00 00 00 10       	add    $0x10000000,%eax
f0103d58:	0f 22 d8             	mov    %eax,%cr3
f0103d5b:	e8 aa 11 00 00       	call   f0104f0a <cpunum>
f0103d60:	6b d0 74             	imul   $0x74,%eax,%edx
f0103d63:	83 c2 04             	add    $0x4,%edx
f0103d66:	b8 02 00 00 00       	mov    $0x2,%eax
f0103d6b:	f0 87 82 20 20 23 f0 	lock xchg %eax,-0xfdcdfe0(%edx)
f0103d72:	83 ec 0c             	sub    $0xc,%esp
f0103d75:	68 c0 13 12 f0       	push   $0xf01213c0
f0103d7a:	e8 97 14 00 00       	call   f0105216 <spin_unlock>
f0103d7f:	f3 90                	pause  
f0103d81:	e8 84 11 00 00       	call   f0104f0a <cpunum>
f0103d86:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d89:	8b 80 30 20 23 f0    	mov    -0xfdcdfd0(%eax),%eax
f0103d8f:	bd 00 00 00 00       	mov    $0x0,%ebp
f0103d94:	89 c4                	mov    %eax,%esp
f0103d96:	6a 00                	push   $0x0
f0103d98:	6a 00                	push   $0x0
f0103d9a:	f4                   	hlt    
f0103d9b:	eb fd                	jmp    f0103d9a <sched_halt+0xaf>
f0103d9d:	83 c4 10             	add    $0x10,%esp
f0103da0:	c9                   	leave  
f0103da1:	c3                   	ret    
f0103da2:	50                   	push   %eax
f0103da3:	68 38 56 10 f0       	push   $0xf0105638
f0103da8:	6a 3d                	push   $0x3d
f0103daa:	68 59 6c 10 f0       	push   $0xf0106c59
f0103daf:	e8 e0 c2 ff ff       	call   f0100094 <_panic>

f0103db4 <sched_yield>:
f0103db4:	55                   	push   %ebp
f0103db5:	89 e5                	mov    %esp,%ebp
f0103db7:	83 ec 08             	sub    $0x8,%esp
f0103dba:	e8 2c ff ff ff       	call   f0103ceb <sched_halt>
f0103dbf:	c9                   	leave  
f0103dc0:	c3                   	ret    

f0103dc1 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0103dc1:	55                   	push   %ebp
f0103dc2:	89 e5                	mov    %esp,%ebp
f0103dc4:	83 ec 0c             	sub    $0xc,%esp
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.

	panic("syscall not implemented");
f0103dc7:	68 66 6c 10 f0       	push   $0xf0106c66
f0103dcc:	68 12 01 00 00       	push   $0x112
f0103dd1:	68 7e 6c 10 f0       	push   $0xf0106c7e
f0103dd6:	e8 b9 c2 ff ff       	call   f0100094 <_panic>

f0103ddb <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0103ddb:	55                   	push   %ebp
f0103ddc:	89 e5                	mov    %esp,%ebp
f0103dde:	57                   	push   %edi
f0103ddf:	56                   	push   %esi
f0103de0:	53                   	push   %ebx
f0103de1:	83 ec 14             	sub    $0x14,%esp
f0103de4:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103de7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0103dea:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0103ded:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0103df0:	8b 1a                	mov    (%edx),%ebx
f0103df2:	8b 01                	mov    (%ecx),%eax
f0103df4:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103df7:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0103dfe:	eb 23                	jmp    f0103e23 <stab_binsearch+0x48>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0103e00:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0103e03:	eb 1e                	jmp    f0103e23 <stab_binsearch+0x48>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0103e05:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103e08:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0103e0b:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0103e0f:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0103e12:	73 41                	jae    f0103e55 <stab_binsearch+0x7a>
			*region_left = m;
f0103e14:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0103e17:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0103e19:	8d 5f 01             	lea    0x1(%edi),%ebx
		any_matches = 1;
f0103e1c:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0103e23:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0103e26:	7f 5a                	jg     f0103e82 <stab_binsearch+0xa7>
		int true_m = (l + r) / 2, m = true_m;
f0103e28:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103e2b:	01 d8                	add    %ebx,%eax
f0103e2d:	89 c7                	mov    %eax,%edi
f0103e2f:	c1 ef 1f             	shr    $0x1f,%edi
f0103e32:	01 c7                	add    %eax,%edi
f0103e34:	d1 ff                	sar    %edi
f0103e36:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0103e39:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0103e3c:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0103e40:	89 f8                	mov    %edi,%eax
		while (m >= l && stabs[m].n_type != type)
f0103e42:	39 c3                	cmp    %eax,%ebx
f0103e44:	7f ba                	jg     f0103e00 <stab_binsearch+0x25>
f0103e46:	0f b6 0a             	movzbl (%edx),%ecx
f0103e49:	83 ea 0c             	sub    $0xc,%edx
f0103e4c:	39 f1                	cmp    %esi,%ecx
f0103e4e:	74 b5                	je     f0103e05 <stab_binsearch+0x2a>
			m--;
f0103e50:	83 e8 01             	sub    $0x1,%eax
f0103e53:	eb ed                	jmp    f0103e42 <stab_binsearch+0x67>
		} else if (stabs[m].n_value > addr) {
f0103e55:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0103e58:	76 14                	jbe    f0103e6e <stab_binsearch+0x93>
			*region_right = m - 1;
f0103e5a:	83 e8 01             	sub    $0x1,%eax
f0103e5d:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103e60:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0103e63:	89 07                	mov    %eax,(%edi)
		any_matches = 1;
f0103e65:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0103e6c:	eb b5                	jmp    f0103e23 <stab_binsearch+0x48>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0103e6e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103e71:	89 07                	mov    %eax,(%edi)
			l = m;
			addr++;
f0103e73:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0103e77:	89 c3                	mov    %eax,%ebx
		any_matches = 1;
f0103e79:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0103e80:	eb a1                	jmp    f0103e23 <stab_binsearch+0x48>
		}
	}

	if (!any_matches)
f0103e82:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0103e86:	75 15                	jne    f0103e9d <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f0103e88:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103e8b:	8b 00                	mov    (%eax),%eax
f0103e8d:	83 e8 01             	sub    $0x1,%eax
f0103e90:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0103e93:	89 06                	mov    %eax,(%esi)
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0103e95:	83 c4 14             	add    $0x14,%esp
f0103e98:	5b                   	pop    %ebx
f0103e99:	5e                   	pop    %esi
f0103e9a:	5f                   	pop    %edi
f0103e9b:	5d                   	pop    %ebp
f0103e9c:	c3                   	ret    
		for (l = *region_right;
f0103e9d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103ea0:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0103ea2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103ea5:	8b 0f                	mov    (%edi),%ecx
f0103ea7:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103eaa:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0103ead:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
		for (l = *region_right;
f0103eb1:	eb 03                	jmp    f0103eb6 <stab_binsearch+0xdb>
		     l--)
f0103eb3:	83 e8 01             	sub    $0x1,%eax
		for (l = *region_right;
f0103eb6:	39 c1                	cmp    %eax,%ecx
f0103eb8:	7d 0a                	jge    f0103ec4 <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f0103eba:	0f b6 1a             	movzbl (%edx),%ebx
f0103ebd:	83 ea 0c             	sub    $0xc,%edx
f0103ec0:	39 f3                	cmp    %esi,%ebx
f0103ec2:	75 ef                	jne    f0103eb3 <stab_binsearch+0xd8>
		*region_left = l;
f0103ec4:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0103ec7:	89 06                	mov    %eax,(%esi)
}
f0103ec9:	eb ca                	jmp    f0103e95 <stab_binsearch+0xba>

f0103ecb <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0103ecb:	55                   	push   %ebp
f0103ecc:	89 e5                	mov    %esp,%ebp
f0103ece:	57                   	push   %edi
f0103ecf:	56                   	push   %esi
f0103ed0:	53                   	push   %ebx
f0103ed1:	83 ec 4c             	sub    $0x4c,%esp
f0103ed4:	8b 75 08             	mov    0x8(%ebp),%esi
f0103ed7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0103eda:	c7 03 8d 6c 10 f0    	movl   $0xf0106c8d,(%ebx)
	info->eip_line = 0;
f0103ee0:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0103ee7:	c7 43 08 8d 6c 10 f0 	movl   $0xf0106c8d,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0103eee:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0103ef5:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0103ef8:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0103eff:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0103f05:	0f 87 1d 01 00 00    	ja     f0104028 <debuginfo_eip+0x15d>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f0103f0b:	a1 00 00 20 00       	mov    0x200000,%eax
f0103f10:	89 45 b8             	mov    %eax,-0x48(%ebp)
		stab_end = usd->stab_end;
f0103f13:	a1 04 00 20 00       	mov    0x200004,%eax
		stabstr = usd->stabstr;
f0103f18:	8b 3d 08 00 20 00    	mov    0x200008,%edi
f0103f1e:	89 7d b4             	mov    %edi,-0x4c(%ebp)
		stabstr_end = usd->stabstr_end;
f0103f21:	8b 3d 0c 00 20 00    	mov    0x20000c,%edi
f0103f27:	89 7d bc             	mov    %edi,-0x44(%ebp)
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0103f2a:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0103f2d:	39 7d b4             	cmp    %edi,-0x4c(%ebp)
f0103f30:	0f 83 bb 01 00 00    	jae    f01040f1 <debuginfo_eip+0x226>
f0103f36:	80 7f ff 00          	cmpb   $0x0,-0x1(%edi)
f0103f3a:	0f 85 b8 01 00 00    	jne    f01040f8 <debuginfo_eip+0x22d>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0103f40:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0103f47:	8b 7d b8             	mov    -0x48(%ebp),%edi
f0103f4a:	29 f8                	sub    %edi,%eax
f0103f4c:	c1 f8 02             	sar    $0x2,%eax
f0103f4f:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0103f55:	83 e8 01             	sub    $0x1,%eax
f0103f58:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0103f5b:	56                   	push   %esi
f0103f5c:	6a 64                	push   $0x64
f0103f5e:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0103f61:	89 c1                	mov    %eax,%ecx
f0103f63:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0103f66:	89 f8                	mov    %edi,%eax
f0103f68:	e8 6e fe ff ff       	call   f0103ddb <stab_binsearch>
	if (lfile == 0)
f0103f6d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103f70:	83 c4 08             	add    $0x8,%esp
f0103f73:	85 c0                	test   %eax,%eax
f0103f75:	0f 84 84 01 00 00    	je     f01040ff <debuginfo_eip+0x234>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0103f7b:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0103f7e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103f81:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0103f84:	56                   	push   %esi
f0103f85:	6a 24                	push   $0x24
f0103f87:	8d 45 d8             	lea    -0x28(%ebp),%eax
f0103f8a:	89 c1                	mov    %eax,%ecx
f0103f8c:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0103f8f:	89 f8                	mov    %edi,%eax
f0103f91:	e8 45 fe ff ff       	call   f0103ddb <stab_binsearch>

	if (lfun <= rfun) {
f0103f96:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103f99:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0103f9c:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
f0103f9f:	83 c4 08             	add    $0x8,%esp
f0103fa2:	39 c8                	cmp    %ecx,%eax
f0103fa4:	0f 8f 9d 00 00 00    	jg     f0104047 <debuginfo_eip+0x17c>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0103faa:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103fad:	8d 0c 97             	lea    (%edi,%edx,4),%ecx
f0103fb0:	8b 11                	mov    (%ecx),%edx
f0103fb2:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0103fb5:	2b 7d b4             	sub    -0x4c(%ebp),%edi
f0103fb8:	39 fa                	cmp    %edi,%edx
f0103fba:	73 06                	jae    f0103fc2 <debuginfo_eip+0xf7>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0103fbc:	03 55 b4             	add    -0x4c(%ebp),%edx
f0103fbf:	89 53 08             	mov    %edx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0103fc2:	8b 51 08             	mov    0x8(%ecx),%edx
f0103fc5:	89 53 10             	mov    %edx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0103fc8:	29 d6                	sub    %edx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0103fca:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0103fcd:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0103fd0:	89 45 d0             	mov    %eax,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0103fd3:	83 ec 08             	sub    $0x8,%esp
f0103fd6:	6a 3a                	push   $0x3a
f0103fd8:	ff 73 08             	pushl  0x8(%ebx)
f0103fdb:	e8 0e 09 00 00       	call   f01048ee <strfind>
f0103fe0:	2b 43 08             	sub    0x8(%ebx),%eax
f0103fe3:	89 43 0c             	mov    %eax,0xc(%ebx)
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0103fe6:	83 c4 08             	add    $0x8,%esp
f0103fe9:	56                   	push   %esi
f0103fea:	6a 44                	push   $0x44
f0103fec:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0103fef:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0103ff2:	8b 75 b8             	mov    -0x48(%ebp),%esi
f0103ff5:	89 f0                	mov    %esi,%eax
f0103ff7:	e8 df fd ff ff       	call   f0103ddb <stab_binsearch>
	if (lline <= rline) {
f0103ffc:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103fff:	83 c4 10             	add    $0x10,%esp
f0104002:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f0104005:	0f 8f fb 00 00 00    	jg     f0104106 <debuginfo_eip+0x23b>
		 info->eip_line = stabs[lline].n_desc;
f010400b:	89 d0                	mov    %edx,%eax
f010400d:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0104010:	c1 e2 02             	shl    $0x2,%edx
f0104013:	0f b7 4c 16 06       	movzwl 0x6(%esi,%edx,1),%ecx
f0104018:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f010401b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010401e:	8d 54 16 04          	lea    0x4(%esi,%edx,1),%edx
f0104022:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f0104026:	eb 3d                	jmp    f0104065 <debuginfo_eip+0x19a>
		stabstr_end = __STABSTR_END__;
f0104028:	c7 45 bc b8 61 11 f0 	movl   $0xf01161b8,-0x44(%ebp)
		stabstr = __STABSTR_BEGIN__;
f010402f:	c7 45 b4 a9 2a 11 f0 	movl   $0xf0112aa9,-0x4c(%ebp)
		stab_end = __STAB_END__;
f0104036:	b8 a8 2a 11 f0       	mov    $0xf0112aa8,%eax
		stabs = __STAB_BEGIN__;
f010403b:	c7 45 b8 74 71 10 f0 	movl   $0xf0107174,-0x48(%ebp)
f0104042:	e9 e3 fe ff ff       	jmp    f0103f2a <debuginfo_eip+0x5f>
		info->eip_fn_addr = addr;
f0104047:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f010404a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010404d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0104050:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104053:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0104056:	e9 78 ff ff ff       	jmp    f0103fd3 <debuginfo_eip+0x108>
f010405b:	83 e8 01             	sub    $0x1,%eax
f010405e:	83 ea 0c             	sub    $0xc,%edx
f0104061:	c6 45 c4 01          	movb   $0x1,-0x3c(%ebp)
f0104065:	89 45 c0             	mov    %eax,-0x40(%ebp)
	while (lline >= lfile
f0104068:	39 c7                	cmp    %eax,%edi
f010406a:	7f 45                	jg     f01040b1 <debuginfo_eip+0x1e6>
	       && stabs[lline].n_type != N_SOL
f010406c:	0f b6 0a             	movzbl (%edx),%ecx
f010406f:	80 f9 84             	cmp    $0x84,%cl
f0104072:	74 19                	je     f010408d <debuginfo_eip+0x1c2>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104074:	80 f9 64             	cmp    $0x64,%cl
f0104077:	75 e2                	jne    f010405b <debuginfo_eip+0x190>
f0104079:	83 7a 04 00          	cmpl   $0x0,0x4(%edx)
f010407d:	74 dc                	je     f010405b <debuginfo_eip+0x190>
f010407f:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0104083:	74 11                	je     f0104096 <debuginfo_eip+0x1cb>
f0104085:	8b 75 c0             	mov    -0x40(%ebp),%esi
f0104088:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f010408b:	eb 09                	jmp    f0104096 <debuginfo_eip+0x1cb>
f010408d:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0104091:	74 03                	je     f0104096 <debuginfo_eip+0x1cb>
f0104093:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0104096:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0104099:	8b 7d b8             	mov    -0x48(%ebp),%edi
f010409c:	8b 14 87             	mov    (%edi,%eax,4),%edx
f010409f:	8b 45 bc             	mov    -0x44(%ebp),%eax
f01040a2:	8b 7d b4             	mov    -0x4c(%ebp),%edi
f01040a5:	29 f8                	sub    %edi,%eax
f01040a7:	39 c2                	cmp    %eax,%edx
f01040a9:	73 06                	jae    f01040b1 <debuginfo_eip+0x1e6>
		info->eip_file = stabstr + stabs[lline].n_strx;
f01040ab:	89 f8                	mov    %edi,%eax
f01040ad:	01 d0                	add    %edx,%eax
f01040af:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01040b1:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01040b4:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01040b7:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f01040bc:	39 f2                	cmp    %esi,%edx
f01040be:	7d 52                	jge    f0104112 <debuginfo_eip+0x247>
		for (lline = lfun + 1;
f01040c0:	83 c2 01             	add    $0x1,%edx
f01040c3:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f01040c6:	89 d0                	mov    %edx,%eax
f01040c8:	8d 14 52             	lea    (%edx,%edx,2),%edx
f01040cb:	8b 7d b8             	mov    -0x48(%ebp),%edi
f01040ce:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
f01040d2:	eb 04                	jmp    f01040d8 <debuginfo_eip+0x20d>
			info->eip_fn_narg++;
f01040d4:	83 43 14 01          	addl   $0x1,0x14(%ebx)
		for (lline = lfun + 1;
f01040d8:	39 c6                	cmp    %eax,%esi
f01040da:	7e 31                	jle    f010410d <debuginfo_eip+0x242>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01040dc:	0f b6 0a             	movzbl (%edx),%ecx
f01040df:	83 c0 01             	add    $0x1,%eax
f01040e2:	83 c2 0c             	add    $0xc,%edx
f01040e5:	80 f9 a0             	cmp    $0xa0,%cl
f01040e8:	74 ea                	je     f01040d4 <debuginfo_eip+0x209>
	return 0;
f01040ea:	b8 00 00 00 00       	mov    $0x0,%eax
f01040ef:	eb 21                	jmp    f0104112 <debuginfo_eip+0x247>
		return -1;
f01040f1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01040f6:	eb 1a                	jmp    f0104112 <debuginfo_eip+0x247>
f01040f8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01040fd:	eb 13                	jmp    f0104112 <debuginfo_eip+0x247>
		return -1;
f01040ff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104104:	eb 0c                	jmp    f0104112 <debuginfo_eip+0x247>
		 return -1;
f0104106:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010410b:	eb 05                	jmp    f0104112 <debuginfo_eip+0x247>
	return 0;
f010410d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104112:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104115:	5b                   	pop    %ebx
f0104116:	5e                   	pop    %esi
f0104117:	5f                   	pop    %edi
f0104118:	5d                   	pop    %ebp
f0104119:	c3                   	ret    

f010411a <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f010411a:	55                   	push   %ebp
f010411b:	89 e5                	mov    %esp,%ebp
f010411d:	57                   	push   %edi
f010411e:	56                   	push   %esi
f010411f:	53                   	push   %ebx
f0104120:	83 ec 1c             	sub    $0x1c,%esp
f0104123:	89 c7                	mov    %eax,%edi
f0104125:	89 d6                	mov    %edx,%esi
f0104127:	8b 45 08             	mov    0x8(%ebp),%eax
f010412a:	8b 55 0c             	mov    0xc(%ebp),%edx
f010412d:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104130:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0104133:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104136:	bb 00 00 00 00       	mov    $0x0,%ebx
f010413b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f010413e:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0104141:	3b 45 10             	cmp    0x10(%ebp),%eax
f0104144:	89 d0                	mov    %edx,%eax
f0104146:	1b 45 e4             	sbb    -0x1c(%ebp),%eax
f0104149:	8b 5d 14             	mov    0x14(%ebp),%ebx
f010414c:	73 15                	jae    f0104163 <printnum+0x49>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f010414e:	83 eb 01             	sub    $0x1,%ebx
f0104151:	85 db                	test   %ebx,%ebx
f0104153:	7e 43                	jle    f0104198 <printnum+0x7e>
			putch(padc, putdat);
f0104155:	83 ec 08             	sub    $0x8,%esp
f0104158:	56                   	push   %esi
f0104159:	ff 75 18             	pushl  0x18(%ebp)
f010415c:	ff d7                	call   *%edi
f010415e:	83 c4 10             	add    $0x10,%esp
f0104161:	eb eb                	jmp    f010414e <printnum+0x34>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0104163:	83 ec 0c             	sub    $0xc,%esp
f0104166:	ff 75 18             	pushl  0x18(%ebp)
f0104169:	8b 45 14             	mov    0x14(%ebp),%eax
f010416c:	8d 58 ff             	lea    -0x1(%eax),%ebx
f010416f:	53                   	push   %ebx
f0104170:	ff 75 10             	pushl  0x10(%ebp)
f0104173:	83 ec 08             	sub    $0x8,%esp
f0104176:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104179:	ff 75 e0             	pushl  -0x20(%ebp)
f010417c:	ff 75 dc             	pushl  -0x24(%ebp)
f010417f:	ff 75 d8             	pushl  -0x28(%ebp)
f0104182:	e8 79 11 00 00       	call   f0105300 <__udivdi3>
f0104187:	83 c4 18             	add    $0x18,%esp
f010418a:	52                   	push   %edx
f010418b:	50                   	push   %eax
f010418c:	89 f2                	mov    %esi,%edx
f010418e:	89 f8                	mov    %edi,%eax
f0104190:	e8 85 ff ff ff       	call   f010411a <printnum>
f0104195:	83 c4 20             	add    $0x20,%esp
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0104198:	83 ec 08             	sub    $0x8,%esp
f010419b:	56                   	push   %esi
f010419c:	83 ec 04             	sub    $0x4,%esp
f010419f:	ff 75 e4             	pushl  -0x1c(%ebp)
f01041a2:	ff 75 e0             	pushl  -0x20(%ebp)
f01041a5:	ff 75 dc             	pushl  -0x24(%ebp)
f01041a8:	ff 75 d8             	pushl  -0x28(%ebp)
f01041ab:	e8 60 12 00 00       	call   f0105410 <__umoddi3>
f01041b0:	83 c4 14             	add    $0x14,%esp
f01041b3:	0f be 80 97 6c 10 f0 	movsbl -0xfef9369(%eax),%eax
f01041ba:	50                   	push   %eax
f01041bb:	ff d7                	call   *%edi
}
f01041bd:	83 c4 10             	add    $0x10,%esp
f01041c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01041c3:	5b                   	pop    %ebx
f01041c4:	5e                   	pop    %esi
f01041c5:	5f                   	pop    %edi
f01041c6:	5d                   	pop    %ebp
f01041c7:	c3                   	ret    

f01041c8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f01041c8:	55                   	push   %ebp
f01041c9:	89 e5                	mov    %esp,%ebp
f01041cb:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f01041ce:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f01041d2:	8b 10                	mov    (%eax),%edx
f01041d4:	3b 50 04             	cmp    0x4(%eax),%edx
f01041d7:	73 0a                	jae    f01041e3 <sprintputch+0x1b>
		*b->buf++ = ch;
f01041d9:	8d 4a 01             	lea    0x1(%edx),%ecx
f01041dc:	89 08                	mov    %ecx,(%eax)
f01041de:	8b 45 08             	mov    0x8(%ebp),%eax
f01041e1:	88 02                	mov    %al,(%edx)
}
f01041e3:	5d                   	pop    %ebp
f01041e4:	c3                   	ret    

f01041e5 <printfmt>:
{
f01041e5:	55                   	push   %ebp
f01041e6:	89 e5                	mov    %esp,%ebp
f01041e8:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f01041eb:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f01041ee:	50                   	push   %eax
f01041ef:	ff 75 10             	pushl  0x10(%ebp)
f01041f2:	ff 75 0c             	pushl  0xc(%ebp)
f01041f5:	ff 75 08             	pushl  0x8(%ebp)
f01041f8:	e8 05 00 00 00       	call   f0104202 <vprintfmt>
}
f01041fd:	83 c4 10             	add    $0x10,%esp
f0104200:	c9                   	leave  
f0104201:	c3                   	ret    

f0104202 <vprintfmt>:
{
f0104202:	55                   	push   %ebp
f0104203:	89 e5                	mov    %esp,%ebp
f0104205:	57                   	push   %edi
f0104206:	56                   	push   %esi
f0104207:	53                   	push   %ebx
f0104208:	83 ec 3c             	sub    $0x3c,%esp
f010420b:	8b 75 08             	mov    0x8(%ebp),%esi
f010420e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104211:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104214:	eb 0a                	jmp    f0104220 <vprintfmt+0x1e>
			putch(ch, putdat);
f0104216:	83 ec 08             	sub    $0x8,%esp
f0104219:	53                   	push   %ebx
f010421a:	50                   	push   %eax
f010421b:	ff d6                	call   *%esi
f010421d:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0104220:	83 c7 01             	add    $0x1,%edi
f0104223:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0104227:	83 f8 25             	cmp    $0x25,%eax
f010422a:	74 0c                	je     f0104238 <vprintfmt+0x36>
			if (ch == '\0')
f010422c:	85 c0                	test   %eax,%eax
f010422e:	75 e6                	jne    f0104216 <vprintfmt+0x14>
}
f0104230:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104233:	5b                   	pop    %ebx
f0104234:	5e                   	pop    %esi
f0104235:	5f                   	pop    %edi
f0104236:	5d                   	pop    %ebp
f0104237:	c3                   	ret    
		padc = ' ';
f0104238:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
f010423c:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;//精度
f0104243:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;//总宽度
f010424a:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f0104251:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f0104256:	8d 47 01             	lea    0x1(%edi),%eax
f0104259:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010425c:	0f b6 17             	movzbl (%edi),%edx
f010425f:	8d 42 dd             	lea    -0x23(%edx),%eax
f0104262:	3c 55                	cmp    $0x55,%al
f0104264:	0f 87 ba 03 00 00    	ja     f0104624 <vprintfmt+0x422>
f010426a:	0f b6 c0             	movzbl %al,%eax
f010426d:	ff 24 85 60 6d 10 f0 	jmp    *-0xfef92a0(,%eax,4)
f0104274:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
f0104277:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
f010427b:	eb d9                	jmp    f0104256 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
f010427d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
f0104280:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
f0104284:	eb d0                	jmp    f0104256 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
f0104286:	0f b6 d2             	movzbl %dl,%edx
f0104289:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {//依次读取数据宽度
f010428c:	b8 00 00 00 00       	mov    $0x0,%eax
f0104291:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
f0104294:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0104297:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f010429b:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f010429e:	8d 4a d0             	lea    -0x30(%edx),%ecx
f01042a1:	83 f9 09             	cmp    $0x9,%ecx
f01042a4:	77 55                	ja     f01042fb <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {//依次读取数据宽度
f01042a6:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
f01042a9:	eb e9                	jmp    f0104294 <vprintfmt+0x92>
			precision = va_arg(ap, int);
f01042ab:	8b 45 14             	mov    0x14(%ebp),%eax
f01042ae:	8b 00                	mov    (%eax),%eax
f01042b0:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01042b3:	8b 45 14             	mov    0x14(%ebp),%eax
f01042b6:	8d 40 04             	lea    0x4(%eax),%eax
f01042b9:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01042bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
f01042bf:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01042c3:	79 91                	jns    f0104256 <vprintfmt+0x54>
				width = precision, precision = -1;
f01042c5:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01042c8:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01042cb:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
f01042d2:	eb 82                	jmp    f0104256 <vprintfmt+0x54>
f01042d4:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01042d7:	85 c0                	test   %eax,%eax
f01042d9:	ba 00 00 00 00       	mov    $0x0,%edx
f01042de:	0f 49 d0             	cmovns %eax,%edx
f01042e1:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01042e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01042e7:	e9 6a ff ff ff       	jmp    f0104256 <vprintfmt+0x54>
f01042ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
f01042ef:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
f01042f6:	e9 5b ff ff ff       	jmp    f0104256 <vprintfmt+0x54>
f01042fb:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01042fe:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104301:	eb bc                	jmp    f01042bf <vprintfmt+0xbd>
			lflag++;
f0104303:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f0104306:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f0104309:	e9 48 ff ff ff       	jmp    f0104256 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
f010430e:	8b 45 14             	mov    0x14(%ebp),%eax
f0104311:	8d 78 04             	lea    0x4(%eax),%edi
f0104314:	83 ec 08             	sub    $0x8,%esp
f0104317:	53                   	push   %ebx
f0104318:	ff 30                	pushl  (%eax)
f010431a:	ff d6                	call   *%esi
			break;
f010431c:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f010431f:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
f0104322:	e9 9c 02 00 00       	jmp    f01045c3 <vprintfmt+0x3c1>
			err = va_arg(ap, int);
f0104327:	8b 45 14             	mov    0x14(%ebp),%eax
f010432a:	8d 78 04             	lea    0x4(%eax),%edi
f010432d:	8b 00                	mov    (%eax),%eax
f010432f:	99                   	cltd   
f0104330:	31 d0                	xor    %edx,%eax
f0104332:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0104334:	83 f8 08             	cmp    $0x8,%eax
f0104337:	7f 23                	jg     f010435c <vprintfmt+0x15a>
f0104339:	8b 14 85 c0 6e 10 f0 	mov    -0xfef9140(,%eax,4),%edx
f0104340:	85 d2                	test   %edx,%edx
f0104342:	74 18                	je     f010435c <vprintfmt+0x15a>
				printfmt(putch, putdat, "%s", p);
f0104344:	52                   	push   %edx
f0104345:	68 a4 64 10 f0       	push   $0xf01064a4
f010434a:	53                   	push   %ebx
f010434b:	56                   	push   %esi
f010434c:	e8 94 fe ff ff       	call   f01041e5 <printfmt>
f0104351:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0104354:	89 7d 14             	mov    %edi,0x14(%ebp)
f0104357:	e9 67 02 00 00       	jmp    f01045c3 <vprintfmt+0x3c1>
				printfmt(putch, putdat, "error %d", err);
f010435c:	50                   	push   %eax
f010435d:	68 af 6c 10 f0       	push   $0xf0106caf
f0104362:	53                   	push   %ebx
f0104363:	56                   	push   %esi
f0104364:	e8 7c fe ff ff       	call   f01041e5 <printfmt>
f0104369:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f010436c:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f010436f:	e9 4f 02 00 00       	jmp    f01045c3 <vprintfmt+0x3c1>
			if ((p = va_arg(ap, char *)) == NULL)
f0104374:	8b 45 14             	mov    0x14(%ebp),%eax
f0104377:	83 c0 04             	add    $0x4,%eax
f010437a:	89 45 c8             	mov    %eax,-0x38(%ebp)
f010437d:	8b 45 14             	mov    0x14(%ebp),%eax
f0104380:	8b 10                	mov    (%eax),%edx
				p = "(null)";
f0104382:	85 d2                	test   %edx,%edx
f0104384:	b8 a8 6c 10 f0       	mov    $0xf0106ca8,%eax
f0104389:	0f 45 c2             	cmovne %edx,%eax
f010438c:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
f010438f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0104393:	7e 06                	jle    f010439b <vprintfmt+0x199>
f0104395:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
f0104399:	75 0d                	jne    f01043a8 <vprintfmt+0x1a6>
				for (width -= strnlen(p, precision); width > 0; width--)
f010439b:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010439e:	89 c7                	mov    %eax,%edi
f01043a0:	03 45 e0             	add    -0x20(%ebp),%eax
f01043a3:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01043a6:	eb 3f                	jmp    f01043e7 <vprintfmt+0x1e5>
f01043a8:	83 ec 08             	sub    $0x8,%esp
f01043ab:	ff 75 d8             	pushl  -0x28(%ebp)
f01043ae:	50                   	push   %eax
f01043af:	e8 ef 03 00 00       	call   f01047a3 <strnlen>
f01043b4:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01043b7:	29 c2                	sub    %eax,%edx
f01043b9:	89 55 c4             	mov    %edx,-0x3c(%ebp)
f01043bc:	83 c4 10             	add    $0x10,%esp
f01043bf:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
f01043c1:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
f01043c5:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f01043c8:	85 ff                	test   %edi,%edi
f01043ca:	7e 58                	jle    f0104424 <vprintfmt+0x222>
					putch(padc, putdat);
f01043cc:	83 ec 08             	sub    $0x8,%esp
f01043cf:	53                   	push   %ebx
f01043d0:	ff 75 e0             	pushl  -0x20(%ebp)
f01043d3:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f01043d5:	83 ef 01             	sub    $0x1,%edi
f01043d8:	83 c4 10             	add    $0x10,%esp
f01043db:	eb eb                	jmp    f01043c8 <vprintfmt+0x1c6>
					putch(ch, putdat);
f01043dd:	83 ec 08             	sub    $0x8,%esp
f01043e0:	53                   	push   %ebx
f01043e1:	52                   	push   %edx
f01043e2:	ff d6                	call   *%esi
f01043e4:	83 c4 10             	add    $0x10,%esp
f01043e7:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01043ea:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01043ec:	83 c7 01             	add    $0x1,%edi
f01043ef:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f01043f3:	0f be d0             	movsbl %al,%edx
f01043f6:	85 d2                	test   %edx,%edx
f01043f8:	74 45                	je     f010443f <vprintfmt+0x23d>
f01043fa:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f01043fe:	78 06                	js     f0104406 <vprintfmt+0x204>
f0104400:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
f0104404:	78 35                	js     f010443b <vprintfmt+0x239>
				if (altflag && (ch < ' ' || ch > '~'))
f0104406:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f010440a:	74 d1                	je     f01043dd <vprintfmt+0x1db>
f010440c:	0f be c0             	movsbl %al,%eax
f010440f:	83 e8 20             	sub    $0x20,%eax
f0104412:	83 f8 5e             	cmp    $0x5e,%eax
f0104415:	76 c6                	jbe    f01043dd <vprintfmt+0x1db>
					putch('?', putdat);
f0104417:	83 ec 08             	sub    $0x8,%esp
f010441a:	53                   	push   %ebx
f010441b:	6a 3f                	push   $0x3f
f010441d:	ff d6                	call   *%esi
f010441f:	83 c4 10             	add    $0x10,%esp
f0104422:	eb c3                	jmp    f01043e7 <vprintfmt+0x1e5>
f0104424:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0104427:	85 d2                	test   %edx,%edx
f0104429:	b8 00 00 00 00       	mov    $0x0,%eax
f010442e:	0f 49 c2             	cmovns %edx,%eax
f0104431:	29 c2                	sub    %eax,%edx
f0104433:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0104436:	e9 60 ff ff ff       	jmp    f010439b <vprintfmt+0x199>
f010443b:	89 cf                	mov    %ecx,%edi
f010443d:	eb 02                	jmp    f0104441 <vprintfmt+0x23f>
f010443f:	89 cf                	mov    %ecx,%edi
			for (; width > 0; width--)
f0104441:	85 ff                	test   %edi,%edi
f0104443:	7e 10                	jle    f0104455 <vprintfmt+0x253>
				putch(' ', putdat);
f0104445:	83 ec 08             	sub    $0x8,%esp
f0104448:	53                   	push   %ebx
f0104449:	6a 20                	push   $0x20
f010444b:	ff d6                	call   *%esi
			for (; width > 0; width--)
f010444d:	83 ef 01             	sub    $0x1,%edi
f0104450:	83 c4 10             	add    $0x10,%esp
f0104453:	eb ec                	jmp    f0104441 <vprintfmt+0x23f>
			if ((p = va_arg(ap, char *)) == NULL)
f0104455:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0104458:	89 45 14             	mov    %eax,0x14(%ebp)
f010445b:	e9 63 01 00 00       	jmp    f01045c3 <vprintfmt+0x3c1>
	if (lflag >= 2)
f0104460:	83 f9 01             	cmp    $0x1,%ecx
f0104463:	7f 1b                	jg     f0104480 <vprintfmt+0x27e>
	else if (lflag)
f0104465:	85 c9                	test   %ecx,%ecx
f0104467:	74 63                	je     f01044cc <vprintfmt+0x2ca>
		return va_arg(*ap, long);
f0104469:	8b 45 14             	mov    0x14(%ebp),%eax
f010446c:	8b 00                	mov    (%eax),%eax
f010446e:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104471:	99                   	cltd   
f0104472:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0104475:	8b 45 14             	mov    0x14(%ebp),%eax
f0104478:	8d 40 04             	lea    0x4(%eax),%eax
f010447b:	89 45 14             	mov    %eax,0x14(%ebp)
f010447e:	eb 17                	jmp    f0104497 <vprintfmt+0x295>
		return va_arg(*ap, long long);
f0104480:	8b 45 14             	mov    0x14(%ebp),%eax
f0104483:	8b 50 04             	mov    0x4(%eax),%edx
f0104486:	8b 00                	mov    (%eax),%eax
f0104488:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010448b:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010448e:	8b 45 14             	mov    0x14(%ebp),%eax
f0104491:	8d 40 08             	lea    0x8(%eax),%eax
f0104494:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f0104497:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010449a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f010449d:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
f01044a2:	85 c9                	test   %ecx,%ecx
f01044a4:	0f 89 ff 00 00 00    	jns    f01045a9 <vprintfmt+0x3a7>
				putch('-', putdat);
f01044aa:	83 ec 08             	sub    $0x8,%esp
f01044ad:	53                   	push   %ebx
f01044ae:	6a 2d                	push   $0x2d
f01044b0:	ff d6                	call   *%esi
				num = -(long long) num;
f01044b2:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01044b5:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f01044b8:	f7 da                	neg    %edx
f01044ba:	83 d1 00             	adc    $0x0,%ecx
f01044bd:	f7 d9                	neg    %ecx
f01044bf:	83 c4 10             	add    $0x10,%esp
			base = 10;
f01044c2:	b8 0a 00 00 00       	mov    $0xa,%eax
f01044c7:	e9 dd 00 00 00       	jmp    f01045a9 <vprintfmt+0x3a7>
		return va_arg(*ap, int);
f01044cc:	8b 45 14             	mov    0x14(%ebp),%eax
f01044cf:	8b 00                	mov    (%eax),%eax
f01044d1:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01044d4:	99                   	cltd   
f01044d5:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01044d8:	8b 45 14             	mov    0x14(%ebp),%eax
f01044db:	8d 40 04             	lea    0x4(%eax),%eax
f01044de:	89 45 14             	mov    %eax,0x14(%ebp)
f01044e1:	eb b4                	jmp    f0104497 <vprintfmt+0x295>
	if (lflag >= 2)
f01044e3:	83 f9 01             	cmp    $0x1,%ecx
f01044e6:	7f 1e                	jg     f0104506 <vprintfmt+0x304>
	else if (lflag)
f01044e8:	85 c9                	test   %ecx,%ecx
f01044ea:	74 32                	je     f010451e <vprintfmt+0x31c>
		return va_arg(*ap, unsigned long);
f01044ec:	8b 45 14             	mov    0x14(%ebp),%eax
f01044ef:	8b 10                	mov    (%eax),%edx
f01044f1:	b9 00 00 00 00       	mov    $0x0,%ecx
f01044f6:	8d 40 04             	lea    0x4(%eax),%eax
f01044f9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01044fc:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104501:	e9 a3 00 00 00       	jmp    f01045a9 <vprintfmt+0x3a7>
		return va_arg(*ap, unsigned long long);
f0104506:	8b 45 14             	mov    0x14(%ebp),%eax
f0104509:	8b 10                	mov    (%eax),%edx
f010450b:	8b 48 04             	mov    0x4(%eax),%ecx
f010450e:	8d 40 08             	lea    0x8(%eax),%eax
f0104511:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0104514:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104519:	e9 8b 00 00 00       	jmp    f01045a9 <vprintfmt+0x3a7>
		return va_arg(*ap, unsigned int);
f010451e:	8b 45 14             	mov    0x14(%ebp),%eax
f0104521:	8b 10                	mov    (%eax),%edx
f0104523:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104528:	8d 40 04             	lea    0x4(%eax),%eax
f010452b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f010452e:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104533:	eb 74                	jmp    f01045a9 <vprintfmt+0x3a7>
	if (lflag >= 2)
f0104535:	83 f9 01             	cmp    $0x1,%ecx
f0104538:	7f 1b                	jg     f0104555 <vprintfmt+0x353>
	else if (lflag)
f010453a:	85 c9                	test   %ecx,%ecx
f010453c:	74 2c                	je     f010456a <vprintfmt+0x368>
		return va_arg(*ap, unsigned long);
f010453e:	8b 45 14             	mov    0x14(%ebp),%eax
f0104541:	8b 10                	mov    (%eax),%edx
f0104543:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104548:	8d 40 04             	lea    0x4(%eax),%eax
f010454b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f010454e:	b8 08 00 00 00       	mov    $0x8,%eax
f0104553:	eb 54                	jmp    f01045a9 <vprintfmt+0x3a7>
		return va_arg(*ap, unsigned long long);
f0104555:	8b 45 14             	mov    0x14(%ebp),%eax
f0104558:	8b 10                	mov    (%eax),%edx
f010455a:	8b 48 04             	mov    0x4(%eax),%ecx
f010455d:	8d 40 08             	lea    0x8(%eax),%eax
f0104560:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0104563:	b8 08 00 00 00       	mov    $0x8,%eax
f0104568:	eb 3f                	jmp    f01045a9 <vprintfmt+0x3a7>
		return va_arg(*ap, unsigned int);
f010456a:	8b 45 14             	mov    0x14(%ebp),%eax
f010456d:	8b 10                	mov    (%eax),%edx
f010456f:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104574:	8d 40 04             	lea    0x4(%eax),%eax
f0104577:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f010457a:	b8 08 00 00 00       	mov    $0x8,%eax
f010457f:	eb 28                	jmp    f01045a9 <vprintfmt+0x3a7>
			putch('0', putdat);
f0104581:	83 ec 08             	sub    $0x8,%esp
f0104584:	53                   	push   %ebx
f0104585:	6a 30                	push   $0x30
f0104587:	ff d6                	call   *%esi
			putch('x', putdat);
f0104589:	83 c4 08             	add    $0x8,%esp
f010458c:	53                   	push   %ebx
f010458d:	6a 78                	push   $0x78
f010458f:	ff d6                	call   *%esi
			num = (unsigned long long)
f0104591:	8b 45 14             	mov    0x14(%ebp),%eax
f0104594:	8b 10                	mov    (%eax),%edx
f0104596:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f010459b:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f010459e:	8d 40 04             	lea    0x4(%eax),%eax
f01045a1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01045a4:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
f01045a9:	83 ec 0c             	sub    $0xc,%esp
f01045ac:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
f01045b0:	57                   	push   %edi
f01045b1:	ff 75 e0             	pushl  -0x20(%ebp)
f01045b4:	50                   	push   %eax
f01045b5:	51                   	push   %ecx
f01045b6:	52                   	push   %edx
f01045b7:	89 da                	mov    %ebx,%edx
f01045b9:	89 f0                	mov    %esi,%eax
f01045bb:	e8 5a fb ff ff       	call   f010411a <printnum>
			break;
f01045c0:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
f01045c3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01045c6:	e9 55 fc ff ff       	jmp    f0104220 <vprintfmt+0x1e>
	if (lflag >= 2)
f01045cb:	83 f9 01             	cmp    $0x1,%ecx
f01045ce:	7f 1b                	jg     f01045eb <vprintfmt+0x3e9>
	else if (lflag)
f01045d0:	85 c9                	test   %ecx,%ecx
f01045d2:	74 2c                	je     f0104600 <vprintfmt+0x3fe>
		return va_arg(*ap, unsigned long);
f01045d4:	8b 45 14             	mov    0x14(%ebp),%eax
f01045d7:	8b 10                	mov    (%eax),%edx
f01045d9:	b9 00 00 00 00       	mov    $0x0,%ecx
f01045de:	8d 40 04             	lea    0x4(%eax),%eax
f01045e1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01045e4:	b8 10 00 00 00       	mov    $0x10,%eax
f01045e9:	eb be                	jmp    f01045a9 <vprintfmt+0x3a7>
		return va_arg(*ap, unsigned long long);
f01045eb:	8b 45 14             	mov    0x14(%ebp),%eax
f01045ee:	8b 10                	mov    (%eax),%edx
f01045f0:	8b 48 04             	mov    0x4(%eax),%ecx
f01045f3:	8d 40 08             	lea    0x8(%eax),%eax
f01045f6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01045f9:	b8 10 00 00 00       	mov    $0x10,%eax
f01045fe:	eb a9                	jmp    f01045a9 <vprintfmt+0x3a7>
		return va_arg(*ap, unsigned int);
f0104600:	8b 45 14             	mov    0x14(%ebp),%eax
f0104603:	8b 10                	mov    (%eax),%edx
f0104605:	b9 00 00 00 00       	mov    $0x0,%ecx
f010460a:	8d 40 04             	lea    0x4(%eax),%eax
f010460d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0104610:	b8 10 00 00 00       	mov    $0x10,%eax
f0104615:	eb 92                	jmp    f01045a9 <vprintfmt+0x3a7>
			putch(ch, putdat);
f0104617:	83 ec 08             	sub    $0x8,%esp
f010461a:	53                   	push   %ebx
f010461b:	6a 25                	push   $0x25
f010461d:	ff d6                	call   *%esi
			break;
f010461f:	83 c4 10             	add    $0x10,%esp
f0104622:	eb 9f                	jmp    f01045c3 <vprintfmt+0x3c1>
			putch('%', putdat);
f0104624:	83 ec 08             	sub    $0x8,%esp
f0104627:	53                   	push   %ebx
f0104628:	6a 25                	push   $0x25
f010462a:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f010462c:	83 c4 10             	add    $0x10,%esp
f010462f:	89 f8                	mov    %edi,%eax
f0104631:	eb 03                	jmp    f0104636 <vprintfmt+0x434>
f0104633:	83 e8 01             	sub    $0x1,%eax
f0104636:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f010463a:	75 f7                	jne    f0104633 <vprintfmt+0x431>
f010463c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010463f:	eb 82                	jmp    f01045c3 <vprintfmt+0x3c1>

f0104641 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0104641:	55                   	push   %ebp
f0104642:	89 e5                	mov    %esp,%ebp
f0104644:	83 ec 18             	sub    $0x18,%esp
f0104647:	8b 45 08             	mov    0x8(%ebp),%eax
f010464a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f010464d:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104650:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0104654:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0104657:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010465e:	85 c0                	test   %eax,%eax
f0104660:	74 26                	je     f0104688 <vsnprintf+0x47>
f0104662:	85 d2                	test   %edx,%edx
f0104664:	7e 22                	jle    f0104688 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0104666:	ff 75 14             	pushl  0x14(%ebp)
f0104669:	ff 75 10             	pushl  0x10(%ebp)
f010466c:	8d 45 ec             	lea    -0x14(%ebp),%eax
f010466f:	50                   	push   %eax
f0104670:	68 c8 41 10 f0       	push   $0xf01041c8
f0104675:	e8 88 fb ff ff       	call   f0104202 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f010467a:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010467d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0104680:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104683:	83 c4 10             	add    $0x10,%esp
}
f0104686:	c9                   	leave  
f0104687:	c3                   	ret    
		return -E_INVAL;
f0104688:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010468d:	eb f7                	jmp    f0104686 <vsnprintf+0x45>

f010468f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f010468f:	55                   	push   %ebp
f0104690:	89 e5                	mov    %esp,%ebp
f0104692:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0104695:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0104698:	50                   	push   %eax
f0104699:	ff 75 10             	pushl  0x10(%ebp)
f010469c:	ff 75 0c             	pushl  0xc(%ebp)
f010469f:	ff 75 08             	pushl  0x8(%ebp)
f01046a2:	e8 9a ff ff ff       	call   f0104641 <vsnprintf>
	va_end(ap);

	return rc;
}
f01046a7:	c9                   	leave  
f01046a8:	c3                   	ret    

f01046a9 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01046a9:	55                   	push   %ebp
f01046aa:	89 e5                	mov    %esp,%ebp
f01046ac:	57                   	push   %edi
f01046ad:	56                   	push   %esi
f01046ae:	53                   	push   %ebx
f01046af:	83 ec 0c             	sub    $0xc,%esp
f01046b2:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01046b5:	85 c0                	test   %eax,%eax
f01046b7:	74 11                	je     f01046ca <readline+0x21>
		cprintf("%s", prompt);
f01046b9:	83 ec 08             	sub    $0x8,%esp
f01046bc:	50                   	push   %eax
f01046bd:	68 a4 64 10 f0       	push   $0xf01064a4
f01046c2:	e8 e6 f0 ff ff       	call   f01037ad <cprintf>
f01046c7:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f01046ca:	83 ec 0c             	sub    $0xc,%esp
f01046cd:	6a 00                	push   $0x0
f01046cf:	e8 e3 c0 ff ff       	call   f01007b7 <iscons>
f01046d4:	89 c7                	mov    %eax,%edi
f01046d6:	83 c4 10             	add    $0x10,%esp
	i = 0;
f01046d9:	be 00 00 00 00       	mov    $0x0,%esi
f01046de:	eb 4b                	jmp    f010472b <readline+0x82>
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
f01046e0:	83 ec 08             	sub    $0x8,%esp
f01046e3:	50                   	push   %eax
f01046e4:	68 e4 6e 10 f0       	push   $0xf0106ee4
f01046e9:	e8 bf f0 ff ff       	call   f01037ad <cprintf>
			return NULL;
f01046ee:	83 c4 10             	add    $0x10,%esp
f01046f1:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f01046f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01046f9:	5b                   	pop    %ebx
f01046fa:	5e                   	pop    %esi
f01046fb:	5f                   	pop    %edi
f01046fc:	5d                   	pop    %ebp
f01046fd:	c3                   	ret    
			if (echoing)
f01046fe:	85 ff                	test   %edi,%edi
f0104700:	75 05                	jne    f0104707 <readline+0x5e>
			i--;
f0104702:	83 ee 01             	sub    $0x1,%esi
f0104705:	eb 24                	jmp    f010472b <readline+0x82>
				cputchar('\b');
f0104707:	83 ec 0c             	sub    $0xc,%esp
f010470a:	6a 08                	push   $0x8
f010470c:	e8 85 c0 ff ff       	call   f0100796 <cputchar>
f0104711:	83 c4 10             	add    $0x10,%esp
f0104714:	eb ec                	jmp    f0104702 <readline+0x59>
				cputchar(c);
f0104716:	83 ec 0c             	sub    $0xc,%esp
f0104719:	53                   	push   %ebx
f010471a:	e8 77 c0 ff ff       	call   f0100796 <cputchar>
f010471f:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0104722:	88 9e 80 1a 23 f0    	mov    %bl,-0xfdce580(%esi)
f0104728:	8d 76 01             	lea    0x1(%esi),%esi
		c = getchar();
f010472b:	e8 76 c0 ff ff       	call   f01007a6 <getchar>
f0104730:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0104732:	85 c0                	test   %eax,%eax
f0104734:	78 aa                	js     f01046e0 <readline+0x37>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0104736:	83 f8 08             	cmp    $0x8,%eax
f0104739:	0f 94 c2             	sete   %dl
f010473c:	83 f8 7f             	cmp    $0x7f,%eax
f010473f:	0f 94 c0             	sete   %al
f0104742:	08 c2                	or     %al,%dl
f0104744:	74 04                	je     f010474a <readline+0xa1>
f0104746:	85 f6                	test   %esi,%esi
f0104748:	7f b4                	jg     f01046fe <readline+0x55>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010474a:	83 fb 1f             	cmp    $0x1f,%ebx
f010474d:	7e 0e                	jle    f010475d <readline+0xb4>
f010474f:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0104755:	7f 06                	jg     f010475d <readline+0xb4>
			if (echoing)
f0104757:	85 ff                	test   %edi,%edi
f0104759:	74 c7                	je     f0104722 <readline+0x79>
f010475b:	eb b9                	jmp    f0104716 <readline+0x6d>
		} else if (c == '\n' || c == '\r') {
f010475d:	83 fb 0a             	cmp    $0xa,%ebx
f0104760:	74 05                	je     f0104767 <readline+0xbe>
f0104762:	83 fb 0d             	cmp    $0xd,%ebx
f0104765:	75 c4                	jne    f010472b <readline+0x82>
			if (echoing)
f0104767:	85 ff                	test   %edi,%edi
f0104769:	75 11                	jne    f010477c <readline+0xd3>
			buf[i] = 0;
f010476b:	c6 86 80 1a 23 f0 00 	movb   $0x0,-0xfdce580(%esi)
			return buf;
f0104772:	b8 80 1a 23 f0       	mov    $0xf0231a80,%eax
f0104777:	e9 7a ff ff ff       	jmp    f01046f6 <readline+0x4d>
				cputchar('\n');
f010477c:	83 ec 0c             	sub    $0xc,%esp
f010477f:	6a 0a                	push   $0xa
f0104781:	e8 10 c0 ff ff       	call   f0100796 <cputchar>
f0104786:	83 c4 10             	add    $0x10,%esp
f0104789:	eb e0                	jmp    f010476b <readline+0xc2>

f010478b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f010478b:	55                   	push   %ebp
f010478c:	89 e5                	mov    %esp,%ebp
f010478e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0104791:	b8 00 00 00 00       	mov    $0x0,%eax
f0104796:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f010479a:	74 05                	je     f01047a1 <strlen+0x16>
		n++;
f010479c:	83 c0 01             	add    $0x1,%eax
f010479f:	eb f5                	jmp    f0104796 <strlen+0xb>
	return n;
}
f01047a1:	5d                   	pop    %ebp
f01047a2:	c3                   	ret    

f01047a3 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01047a3:	55                   	push   %ebp
f01047a4:	89 e5                	mov    %esp,%ebp
f01047a6:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01047a9:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01047ac:	ba 00 00 00 00       	mov    $0x0,%edx
f01047b1:	39 c2                	cmp    %eax,%edx
f01047b3:	74 0d                	je     f01047c2 <strnlen+0x1f>
f01047b5:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f01047b9:	74 05                	je     f01047c0 <strnlen+0x1d>
		n++;
f01047bb:	83 c2 01             	add    $0x1,%edx
f01047be:	eb f1                	jmp    f01047b1 <strnlen+0xe>
f01047c0:	89 d0                	mov    %edx,%eax
	return n;
}
f01047c2:	5d                   	pop    %ebp
f01047c3:	c3                   	ret    

f01047c4 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01047c4:	55                   	push   %ebp
f01047c5:	89 e5                	mov    %esp,%ebp
f01047c7:	53                   	push   %ebx
f01047c8:	8b 45 08             	mov    0x8(%ebp),%eax
f01047cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01047ce:	ba 00 00 00 00       	mov    $0x0,%edx
f01047d3:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f01047d7:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f01047da:	83 c2 01             	add    $0x1,%edx
f01047dd:	84 c9                	test   %cl,%cl
f01047df:	75 f2                	jne    f01047d3 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f01047e1:	5b                   	pop    %ebx
f01047e2:	5d                   	pop    %ebp
f01047e3:	c3                   	ret    

f01047e4 <strcat>:

char *
strcat(char *dst, const char *src)
{
f01047e4:	55                   	push   %ebp
f01047e5:	89 e5                	mov    %esp,%ebp
f01047e7:	53                   	push   %ebx
f01047e8:	83 ec 10             	sub    $0x10,%esp
f01047eb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01047ee:	53                   	push   %ebx
f01047ef:	e8 97 ff ff ff       	call   f010478b <strlen>
f01047f4:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
f01047f7:	ff 75 0c             	pushl  0xc(%ebp)
f01047fa:	01 d8                	add    %ebx,%eax
f01047fc:	50                   	push   %eax
f01047fd:	e8 c2 ff ff ff       	call   f01047c4 <strcpy>
	return dst;
}
f0104802:	89 d8                	mov    %ebx,%eax
f0104804:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104807:	c9                   	leave  
f0104808:	c3                   	ret    

f0104809 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0104809:	55                   	push   %ebp
f010480a:	89 e5                	mov    %esp,%ebp
f010480c:	56                   	push   %esi
f010480d:	53                   	push   %ebx
f010480e:	8b 45 08             	mov    0x8(%ebp),%eax
f0104811:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104814:	89 c6                	mov    %eax,%esi
f0104816:	03 75 10             	add    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0104819:	89 c2                	mov    %eax,%edx
f010481b:	39 f2                	cmp    %esi,%edx
f010481d:	74 11                	je     f0104830 <strncpy+0x27>
		*dst++ = *src;
f010481f:	83 c2 01             	add    $0x1,%edx
f0104822:	0f b6 19             	movzbl (%ecx),%ebx
f0104825:	88 5a ff             	mov    %bl,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0104828:	80 fb 01             	cmp    $0x1,%bl
f010482b:	83 d9 ff             	sbb    $0xffffffff,%ecx
f010482e:	eb eb                	jmp    f010481b <strncpy+0x12>
	}
	return ret;
}
f0104830:	5b                   	pop    %ebx
f0104831:	5e                   	pop    %esi
f0104832:	5d                   	pop    %ebp
f0104833:	c3                   	ret    

f0104834 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0104834:	55                   	push   %ebp
f0104835:	89 e5                	mov    %esp,%ebp
f0104837:	56                   	push   %esi
f0104838:	53                   	push   %ebx
f0104839:	8b 75 08             	mov    0x8(%ebp),%esi
f010483c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010483f:	8b 55 10             	mov    0x10(%ebp),%edx
f0104842:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0104844:	85 d2                	test   %edx,%edx
f0104846:	74 21                	je     f0104869 <strlcpy+0x35>
f0104848:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f010484c:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
f010484e:	39 c2                	cmp    %eax,%edx
f0104850:	74 14                	je     f0104866 <strlcpy+0x32>
f0104852:	0f b6 19             	movzbl (%ecx),%ebx
f0104855:	84 db                	test   %bl,%bl
f0104857:	74 0b                	je     f0104864 <strlcpy+0x30>
			*dst++ = *src++;
f0104859:	83 c1 01             	add    $0x1,%ecx
f010485c:	83 c2 01             	add    $0x1,%edx
f010485f:	88 5a ff             	mov    %bl,-0x1(%edx)
f0104862:	eb ea                	jmp    f010484e <strlcpy+0x1a>
f0104864:	89 d0                	mov    %edx,%eax
		*dst = '\0';
f0104866:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0104869:	29 f0                	sub    %esi,%eax
}
f010486b:	5b                   	pop    %ebx
f010486c:	5e                   	pop    %esi
f010486d:	5d                   	pop    %ebp
f010486e:	c3                   	ret    

f010486f <strcmp>:

int
strcmp(const char *p, const char *q)
{
f010486f:	55                   	push   %ebp
f0104870:	89 e5                	mov    %esp,%ebp
f0104872:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104875:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0104878:	0f b6 01             	movzbl (%ecx),%eax
f010487b:	84 c0                	test   %al,%al
f010487d:	74 0c                	je     f010488b <strcmp+0x1c>
f010487f:	3a 02                	cmp    (%edx),%al
f0104881:	75 08                	jne    f010488b <strcmp+0x1c>
		p++, q++;
f0104883:	83 c1 01             	add    $0x1,%ecx
f0104886:	83 c2 01             	add    $0x1,%edx
f0104889:	eb ed                	jmp    f0104878 <strcmp+0x9>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f010488b:	0f b6 c0             	movzbl %al,%eax
f010488e:	0f b6 12             	movzbl (%edx),%edx
f0104891:	29 d0                	sub    %edx,%eax
}
f0104893:	5d                   	pop    %ebp
f0104894:	c3                   	ret    

f0104895 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0104895:	55                   	push   %ebp
f0104896:	89 e5                	mov    %esp,%ebp
f0104898:	53                   	push   %ebx
f0104899:	8b 45 08             	mov    0x8(%ebp),%eax
f010489c:	8b 55 0c             	mov    0xc(%ebp),%edx
f010489f:	89 c3                	mov    %eax,%ebx
f01048a1:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f01048a4:	eb 06                	jmp    f01048ac <strncmp+0x17>
		n--, p++, q++;
f01048a6:	83 c0 01             	add    $0x1,%eax
f01048a9:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f01048ac:	39 d8                	cmp    %ebx,%eax
f01048ae:	74 16                	je     f01048c6 <strncmp+0x31>
f01048b0:	0f b6 08             	movzbl (%eax),%ecx
f01048b3:	84 c9                	test   %cl,%cl
f01048b5:	74 04                	je     f01048bb <strncmp+0x26>
f01048b7:	3a 0a                	cmp    (%edx),%cl
f01048b9:	74 eb                	je     f01048a6 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01048bb:	0f b6 00             	movzbl (%eax),%eax
f01048be:	0f b6 12             	movzbl (%edx),%edx
f01048c1:	29 d0                	sub    %edx,%eax
}
f01048c3:	5b                   	pop    %ebx
f01048c4:	5d                   	pop    %ebp
f01048c5:	c3                   	ret    
		return 0;
f01048c6:	b8 00 00 00 00       	mov    $0x0,%eax
f01048cb:	eb f6                	jmp    f01048c3 <strncmp+0x2e>

f01048cd <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01048cd:	55                   	push   %ebp
f01048ce:	89 e5                	mov    %esp,%ebp
f01048d0:	8b 45 08             	mov    0x8(%ebp),%eax
f01048d3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01048d7:	0f b6 10             	movzbl (%eax),%edx
f01048da:	84 d2                	test   %dl,%dl
f01048dc:	74 09                	je     f01048e7 <strchr+0x1a>
		if (*s == c)
f01048de:	38 ca                	cmp    %cl,%dl
f01048e0:	74 0a                	je     f01048ec <strchr+0x1f>
	for (; *s; s++)
f01048e2:	83 c0 01             	add    $0x1,%eax
f01048e5:	eb f0                	jmp    f01048d7 <strchr+0xa>
			return (char *) s;
	return 0;
f01048e7:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01048ec:	5d                   	pop    %ebp
f01048ed:	c3                   	ret    

f01048ee <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01048ee:	55                   	push   %ebp
f01048ef:	89 e5                	mov    %esp,%ebp
f01048f1:	8b 45 08             	mov    0x8(%ebp),%eax
f01048f4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01048f8:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f01048fb:	38 ca                	cmp    %cl,%dl
f01048fd:	74 09                	je     f0104908 <strfind+0x1a>
f01048ff:	84 d2                	test   %dl,%dl
f0104901:	74 05                	je     f0104908 <strfind+0x1a>
	for (; *s; s++)
f0104903:	83 c0 01             	add    $0x1,%eax
f0104906:	eb f0                	jmp    f01048f8 <strfind+0xa>
			break;
	return (char *) s;
}
f0104908:	5d                   	pop    %ebp
f0104909:	c3                   	ret    

f010490a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f010490a:	55                   	push   %ebp
f010490b:	89 e5                	mov    %esp,%ebp
f010490d:	57                   	push   %edi
f010490e:	56                   	push   %esi
f010490f:	53                   	push   %ebx
f0104910:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104913:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0104916:	85 c9                	test   %ecx,%ecx
f0104918:	74 31                	je     f010494b <memset+0x41>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f010491a:	89 f8                	mov    %edi,%eax
f010491c:	09 c8                	or     %ecx,%eax
f010491e:	a8 03                	test   $0x3,%al
f0104920:	75 23                	jne    f0104945 <memset+0x3b>
		c &= 0xFF;
f0104922:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0104926:	89 d3                	mov    %edx,%ebx
f0104928:	c1 e3 08             	shl    $0x8,%ebx
f010492b:	89 d0                	mov    %edx,%eax
f010492d:	c1 e0 18             	shl    $0x18,%eax
f0104930:	89 d6                	mov    %edx,%esi
f0104932:	c1 e6 10             	shl    $0x10,%esi
f0104935:	09 f0                	or     %esi,%eax
f0104937:	09 c2                	or     %eax,%edx
f0104939:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f010493b:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f010493e:	89 d0                	mov    %edx,%eax
f0104940:	fc                   	cld    
f0104941:	f3 ab                	rep stos %eax,%es:(%edi)
f0104943:	eb 06                	jmp    f010494b <memset+0x41>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0104945:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104948:	fc                   	cld    
f0104949:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010494b:	89 f8                	mov    %edi,%eax
f010494d:	5b                   	pop    %ebx
f010494e:	5e                   	pop    %esi
f010494f:	5f                   	pop    %edi
f0104950:	5d                   	pop    %ebp
f0104951:	c3                   	ret    

f0104952 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0104952:	55                   	push   %ebp
f0104953:	89 e5                	mov    %esp,%ebp
f0104955:	57                   	push   %edi
f0104956:	56                   	push   %esi
f0104957:	8b 45 08             	mov    0x8(%ebp),%eax
f010495a:	8b 75 0c             	mov    0xc(%ebp),%esi
f010495d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0104960:	39 c6                	cmp    %eax,%esi
f0104962:	73 32                	jae    f0104996 <memmove+0x44>
f0104964:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0104967:	39 c2                	cmp    %eax,%edx
f0104969:	76 2b                	jbe    f0104996 <memmove+0x44>
		s += n;
		d += n;
f010496b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010496e:	89 fe                	mov    %edi,%esi
f0104970:	09 ce                	or     %ecx,%esi
f0104972:	09 d6                	or     %edx,%esi
f0104974:	f7 c6 03 00 00 00    	test   $0x3,%esi
f010497a:	75 0e                	jne    f010498a <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f010497c:	83 ef 04             	sub    $0x4,%edi
f010497f:	8d 72 fc             	lea    -0x4(%edx),%esi
f0104982:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f0104985:	fd                   	std    
f0104986:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104988:	eb 09                	jmp    f0104993 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f010498a:	83 ef 01             	sub    $0x1,%edi
f010498d:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f0104990:	fd                   	std    
f0104991:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0104993:	fc                   	cld    
f0104994:	eb 1a                	jmp    f01049b0 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104996:	89 c2                	mov    %eax,%edx
f0104998:	09 ca                	or     %ecx,%edx
f010499a:	09 f2                	or     %esi,%edx
f010499c:	f6 c2 03             	test   $0x3,%dl
f010499f:	75 0a                	jne    f01049ab <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f01049a1:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f01049a4:	89 c7                	mov    %eax,%edi
f01049a6:	fc                   	cld    
f01049a7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01049a9:	eb 05                	jmp    f01049b0 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
f01049ab:	89 c7                	mov    %eax,%edi
f01049ad:	fc                   	cld    
f01049ae:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01049b0:	5e                   	pop    %esi
f01049b1:	5f                   	pop    %edi
f01049b2:	5d                   	pop    %ebp
f01049b3:	c3                   	ret    

f01049b4 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01049b4:	55                   	push   %ebp
f01049b5:	89 e5                	mov    %esp,%ebp
f01049b7:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f01049ba:	ff 75 10             	pushl  0x10(%ebp)
f01049bd:	ff 75 0c             	pushl  0xc(%ebp)
f01049c0:	ff 75 08             	pushl  0x8(%ebp)
f01049c3:	e8 8a ff ff ff       	call   f0104952 <memmove>
}
f01049c8:	c9                   	leave  
f01049c9:	c3                   	ret    

f01049ca <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01049ca:	55                   	push   %ebp
f01049cb:	89 e5                	mov    %esp,%ebp
f01049cd:	56                   	push   %esi
f01049ce:	53                   	push   %ebx
f01049cf:	8b 45 08             	mov    0x8(%ebp),%eax
f01049d2:	8b 55 0c             	mov    0xc(%ebp),%edx
f01049d5:	89 c6                	mov    %eax,%esi
f01049d7:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01049da:	39 f0                	cmp    %esi,%eax
f01049dc:	74 1c                	je     f01049fa <memcmp+0x30>
		if (*s1 != *s2)
f01049de:	0f b6 08             	movzbl (%eax),%ecx
f01049e1:	0f b6 1a             	movzbl (%edx),%ebx
f01049e4:	38 d9                	cmp    %bl,%cl
f01049e6:	75 08                	jne    f01049f0 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f01049e8:	83 c0 01             	add    $0x1,%eax
f01049eb:	83 c2 01             	add    $0x1,%edx
f01049ee:	eb ea                	jmp    f01049da <memcmp+0x10>
			return (int) *s1 - (int) *s2;
f01049f0:	0f b6 c1             	movzbl %cl,%eax
f01049f3:	0f b6 db             	movzbl %bl,%ebx
f01049f6:	29 d8                	sub    %ebx,%eax
f01049f8:	eb 05                	jmp    f01049ff <memcmp+0x35>
	}

	return 0;
f01049fa:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01049ff:	5b                   	pop    %ebx
f0104a00:	5e                   	pop    %esi
f0104a01:	5d                   	pop    %ebp
f0104a02:	c3                   	ret    

f0104a03 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0104a03:	55                   	push   %ebp
f0104a04:	89 e5                	mov    %esp,%ebp
f0104a06:	8b 45 08             	mov    0x8(%ebp),%eax
f0104a09:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0104a0c:	89 c2                	mov    %eax,%edx
f0104a0e:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0104a11:	39 d0                	cmp    %edx,%eax
f0104a13:	73 09                	jae    f0104a1e <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
f0104a15:	38 08                	cmp    %cl,(%eax)
f0104a17:	74 05                	je     f0104a1e <memfind+0x1b>
	for (; s < ends; s++)
f0104a19:	83 c0 01             	add    $0x1,%eax
f0104a1c:	eb f3                	jmp    f0104a11 <memfind+0xe>
			break;
	return (void *) s;
}
f0104a1e:	5d                   	pop    %ebp
f0104a1f:	c3                   	ret    

f0104a20 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0104a20:	55                   	push   %ebp
f0104a21:	89 e5                	mov    %esp,%ebp
f0104a23:	57                   	push   %edi
f0104a24:	56                   	push   %esi
f0104a25:	53                   	push   %ebx
f0104a26:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104a29:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0104a2c:	eb 03                	jmp    f0104a31 <strtol+0x11>
		s++;
f0104a2e:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
f0104a31:	0f b6 01             	movzbl (%ecx),%eax
f0104a34:	3c 20                	cmp    $0x20,%al
f0104a36:	74 f6                	je     f0104a2e <strtol+0xe>
f0104a38:	3c 09                	cmp    $0x9,%al
f0104a3a:	74 f2                	je     f0104a2e <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f0104a3c:	3c 2b                	cmp    $0x2b,%al
f0104a3e:	74 2a                	je     f0104a6a <strtol+0x4a>
	int neg = 0;
f0104a40:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f0104a45:	3c 2d                	cmp    $0x2d,%al
f0104a47:	74 2b                	je     f0104a74 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0104a49:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0104a4f:	75 0f                	jne    f0104a60 <strtol+0x40>
f0104a51:	80 39 30             	cmpb   $0x30,(%ecx)
f0104a54:	74 28                	je     f0104a7e <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0104a56:	85 db                	test   %ebx,%ebx
f0104a58:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104a5d:	0f 44 d8             	cmove  %eax,%ebx
f0104a60:	b8 00 00 00 00       	mov    $0x0,%eax
f0104a65:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0104a68:	eb 50                	jmp    f0104aba <strtol+0x9a>
		s++;
f0104a6a:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
f0104a6d:	bf 00 00 00 00       	mov    $0x0,%edi
f0104a72:	eb d5                	jmp    f0104a49 <strtol+0x29>
		s++, neg = 1;
f0104a74:	83 c1 01             	add    $0x1,%ecx
f0104a77:	bf 01 00 00 00       	mov    $0x1,%edi
f0104a7c:	eb cb                	jmp    f0104a49 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0104a7e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0104a82:	74 0e                	je     f0104a92 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
f0104a84:	85 db                	test   %ebx,%ebx
f0104a86:	75 d8                	jne    f0104a60 <strtol+0x40>
		s++, base = 8;
f0104a88:	83 c1 01             	add    $0x1,%ecx
f0104a8b:	bb 08 00 00 00       	mov    $0x8,%ebx
f0104a90:	eb ce                	jmp    f0104a60 <strtol+0x40>
		s += 2, base = 16;
f0104a92:	83 c1 02             	add    $0x2,%ecx
f0104a95:	bb 10 00 00 00       	mov    $0x10,%ebx
f0104a9a:	eb c4                	jmp    f0104a60 <strtol+0x40>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
f0104a9c:	8d 72 9f             	lea    -0x61(%edx),%esi
f0104a9f:	89 f3                	mov    %esi,%ebx
f0104aa1:	80 fb 19             	cmp    $0x19,%bl
f0104aa4:	77 29                	ja     f0104acf <strtol+0xaf>
			dig = *s - 'a' + 10;
f0104aa6:	0f be d2             	movsbl %dl,%edx
f0104aa9:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0104aac:	3b 55 10             	cmp    0x10(%ebp),%edx
f0104aaf:	7d 30                	jge    f0104ae1 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
f0104ab1:	83 c1 01             	add    $0x1,%ecx
f0104ab4:	0f af 45 10          	imul   0x10(%ebp),%eax
f0104ab8:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f0104aba:	0f b6 11             	movzbl (%ecx),%edx
f0104abd:	8d 72 d0             	lea    -0x30(%edx),%esi
f0104ac0:	89 f3                	mov    %esi,%ebx
f0104ac2:	80 fb 09             	cmp    $0x9,%bl
f0104ac5:	77 d5                	ja     f0104a9c <strtol+0x7c>
			dig = *s - '0';
f0104ac7:	0f be d2             	movsbl %dl,%edx
f0104aca:	83 ea 30             	sub    $0x30,%edx
f0104acd:	eb dd                	jmp    f0104aac <strtol+0x8c>
		else if (*s >= 'A' && *s <= 'Z')
f0104acf:	8d 72 bf             	lea    -0x41(%edx),%esi
f0104ad2:	89 f3                	mov    %esi,%ebx
f0104ad4:	80 fb 19             	cmp    $0x19,%bl
f0104ad7:	77 08                	ja     f0104ae1 <strtol+0xc1>
			dig = *s - 'A' + 10;
f0104ad9:	0f be d2             	movsbl %dl,%edx
f0104adc:	83 ea 37             	sub    $0x37,%edx
f0104adf:	eb cb                	jmp    f0104aac <strtol+0x8c>
		// we don't properly detect overflow!
	}

	if (endptr)
f0104ae1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0104ae5:	74 05                	je     f0104aec <strtol+0xcc>
		*endptr = (char *) s;
f0104ae7:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104aea:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f0104aec:	89 c2                	mov    %eax,%edx
f0104aee:	f7 da                	neg    %edx
f0104af0:	85 ff                	test   %edi,%edi
f0104af2:	0f 45 c2             	cmovne %edx,%eax
}
f0104af5:	5b                   	pop    %ebx
f0104af6:	5e                   	pop    %esi
f0104af7:	5f                   	pop    %edi
f0104af8:	5d                   	pop    %ebp
f0104af9:	c3                   	ret    
f0104afa:	66 90                	xchg   %ax,%ax

f0104afc <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0104afc:	fa                   	cli    

	xorw    %ax, %ax
f0104afd:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f0104aff:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0104b01:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0104b03:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0104b05:	0f 01 16             	lgdtl  (%esi)
f0104b08:	74 70                	je     f0104b7a <mpsearch1+0x3>
	movl    %cr0, %eax
f0104b0a:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0104b0d:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0104b11:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0104b14:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0104b1a:	08 00                	or     %al,(%eax)

f0104b1c <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0104b1c:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0104b20:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0104b22:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0104b24:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0104b26:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0104b2a:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0104b2c:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0104b2e:	b8 00 f0 11 00       	mov    $0x11f000,%eax
	movl    %eax, %cr3
f0104b33:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0104b36:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0104b39:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0104b3e:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0104b41:	8b 25 84 1e 23 f0    	mov    0xf0231e84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0104b47:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0104b4c:	b8 f5 01 10 f0       	mov    $0xf01001f5,%eax
	call    *%eax
f0104b51:	ff d0                	call   *%eax

f0104b53 <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0104b53:	eb fe                	jmp    f0104b53 <spin>
f0104b55:	8d 76 00             	lea    0x0(%esi),%esi

f0104b58 <gdt>:
	...
f0104b60:	ff                   	(bad)  
f0104b61:	ff 00                	incl   (%eax)
f0104b63:	00 00                	add    %al,(%eax)
f0104b65:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0104b6c:	00                   	.byte 0x0
f0104b6d:	92                   	xchg   %eax,%edx
f0104b6e:	cf                   	iret   
	...

f0104b70 <gdtdesc>:
f0104b70:	17                   	pop    %ss
f0104b71:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0104b76 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0104b76:	90                   	nop

f0104b77 <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0104b77:	55                   	push   %ebp
f0104b78:	89 e5                	mov    %esp,%ebp
f0104b7a:	57                   	push   %edi
f0104b7b:	56                   	push   %esi
f0104b7c:	53                   	push   %ebx
f0104b7d:	83 ec 0c             	sub    $0xc,%esp
	if (PGNUM(pa) >= npages)
f0104b80:	8b 0d 88 1e 23 f0    	mov    0xf0231e88,%ecx
f0104b86:	89 c3                	mov    %eax,%ebx
f0104b88:	c1 eb 0c             	shr    $0xc,%ebx
f0104b8b:	39 cb                	cmp    %ecx,%ebx
f0104b8d:	73 1a                	jae    f0104ba9 <mpsearch1+0x32>
	return (void *)(pa + KERNBASE);
f0104b8f:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0104b95:	8d 3c 02             	lea    (%edx,%eax,1),%edi
	if (PGNUM(pa) >= npages)
f0104b98:	89 f8                	mov    %edi,%eax
f0104b9a:	c1 e8 0c             	shr    $0xc,%eax
f0104b9d:	39 c8                	cmp    %ecx,%eax
f0104b9f:	73 1a                	jae    f0104bbb <mpsearch1+0x44>
	return (void *)(pa + KERNBASE);
f0104ba1:	81 ef 00 00 00 10    	sub    $0x10000000,%edi

	for (; mp < end; mp++)
f0104ba7:	eb 27                	jmp    f0104bd0 <mpsearch1+0x59>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0104ba9:	50                   	push   %eax
f0104baa:	68 14 56 10 f0       	push   $0xf0105614
f0104baf:	6a 57                	push   $0x57
f0104bb1:	68 81 70 10 f0       	push   $0xf0107081
f0104bb6:	e8 d9 b4 ff ff       	call   f0100094 <_panic>
f0104bbb:	57                   	push   %edi
f0104bbc:	68 14 56 10 f0       	push   $0xf0105614
f0104bc1:	6a 57                	push   $0x57
f0104bc3:	68 81 70 10 f0       	push   $0xf0107081
f0104bc8:	e8 c7 b4 ff ff       	call   f0100094 <_panic>
f0104bcd:	83 c3 10             	add    $0x10,%ebx
f0104bd0:	39 fb                	cmp    %edi,%ebx
f0104bd2:	73 30                	jae    f0104c04 <mpsearch1+0x8d>
f0104bd4:	89 de                	mov    %ebx,%esi
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0104bd6:	83 ec 04             	sub    $0x4,%esp
f0104bd9:	6a 04                	push   $0x4
f0104bdb:	68 91 70 10 f0       	push   $0xf0107091
f0104be0:	53                   	push   %ebx
f0104be1:	e8 e4 fd ff ff       	call   f01049ca <memcmp>
f0104be6:	83 c4 10             	add    $0x10,%esp
f0104be9:	85 c0                	test   %eax,%eax
f0104beb:	75 e0                	jne    f0104bcd <mpsearch1+0x56>
f0104bed:	89 da                	mov    %ebx,%edx
	for (i = 0; i < len; i++)
f0104bef:	83 c6 10             	add    $0x10,%esi
		sum += ((uint8_t *)addr)[i];
f0104bf2:	0f b6 0a             	movzbl (%edx),%ecx
f0104bf5:	01 c8                	add    %ecx,%eax
f0104bf7:	83 c2 01             	add    $0x1,%edx
	for (i = 0; i < len; i++)
f0104bfa:	39 f2                	cmp    %esi,%edx
f0104bfc:	75 f4                	jne    f0104bf2 <mpsearch1+0x7b>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0104bfe:	84 c0                	test   %al,%al
f0104c00:	75 cb                	jne    f0104bcd <mpsearch1+0x56>
f0104c02:	eb 05                	jmp    f0104c09 <mpsearch1+0x92>
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f0104c04:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f0104c09:	89 d8                	mov    %ebx,%eax
f0104c0b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104c0e:	5b                   	pop    %ebx
f0104c0f:	5e                   	pop    %esi
f0104c10:	5f                   	pop    %edi
f0104c11:	5d                   	pop    %ebp
f0104c12:	c3                   	ret    

f0104c13 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f0104c13:	55                   	push   %ebp
f0104c14:	89 e5                	mov    %esp,%ebp
f0104c16:	57                   	push   %edi
f0104c17:	56                   	push   %esi
f0104c18:	53                   	push   %ebx
f0104c19:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0104c1c:	c7 05 c0 23 23 f0 20 	movl   $0xf0232020,0xf02323c0
f0104c23:	20 23 f0 
	if (PGNUM(pa) >= npages)
f0104c26:	83 3d 88 1e 23 f0 00 	cmpl   $0x0,0xf0231e88
f0104c2d:	0f 84 a3 00 00 00    	je     f0104cd6 <mp_init+0xc3>
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0104c33:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0104c3a:	85 c0                	test   %eax,%eax
f0104c3c:	0f 84 aa 00 00 00    	je     f0104cec <mp_init+0xd9>
		p <<= 4;	// Translate from segment to PA
f0104c42:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f0104c45:	ba 00 04 00 00       	mov    $0x400,%edx
f0104c4a:	e8 28 ff ff ff       	call   f0104b77 <mpsearch1>
f0104c4f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104c52:	85 c0                	test   %eax,%eax
f0104c54:	75 1a                	jne    f0104c70 <mp_init+0x5d>
	return mpsearch1(0xF0000, 0x10000);
f0104c56:	ba 00 00 01 00       	mov    $0x10000,%edx
f0104c5b:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0104c60:	e8 12 ff ff ff       	call   f0104b77 <mpsearch1>
f0104c65:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if ((mp = mpsearch()) == 0)
f0104c68:	85 c0                	test   %eax,%eax
f0104c6a:	0f 84 31 02 00 00    	je     f0104ea1 <mp_init+0x28e>
	if (mp->physaddr == 0 || mp->type != 0) {
f0104c70:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104c73:	8b 58 04             	mov    0x4(%eax),%ebx
f0104c76:	85 db                	test   %ebx,%ebx
f0104c78:	0f 84 97 00 00 00    	je     f0104d15 <mp_init+0x102>
f0104c7e:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0104c82:	0f 85 8d 00 00 00    	jne    f0104d15 <mp_init+0x102>
f0104c88:	89 d8                	mov    %ebx,%eax
f0104c8a:	c1 e8 0c             	shr    $0xc,%eax
f0104c8d:	3b 05 88 1e 23 f0    	cmp    0xf0231e88,%eax
f0104c93:	0f 83 91 00 00 00    	jae    f0104d2a <mp_init+0x117>
	return (void *)(pa + KERNBASE);
f0104c99:	81 eb 00 00 00 10    	sub    $0x10000000,%ebx
f0104c9f:	89 de                	mov    %ebx,%esi
	if (memcmp(conf, "PCMP", 4) != 0) {
f0104ca1:	83 ec 04             	sub    $0x4,%esp
f0104ca4:	6a 04                	push   $0x4
f0104ca6:	68 96 70 10 f0       	push   $0xf0107096
f0104cab:	53                   	push   %ebx
f0104cac:	e8 19 fd ff ff       	call   f01049ca <memcmp>
f0104cb1:	83 c4 10             	add    $0x10,%esp
f0104cb4:	85 c0                	test   %eax,%eax
f0104cb6:	0f 85 83 00 00 00    	jne    f0104d3f <mp_init+0x12c>
f0104cbc:	0f b7 7b 04          	movzwl 0x4(%ebx),%edi
f0104cc0:	01 df                	add    %ebx,%edi
	sum = 0;
f0104cc2:	89 c2                	mov    %eax,%edx
	for (i = 0; i < len; i++)
f0104cc4:	39 fb                	cmp    %edi,%ebx
f0104cc6:	0f 84 88 00 00 00    	je     f0104d54 <mp_init+0x141>
		sum += ((uint8_t *)addr)[i];
f0104ccc:	0f b6 0b             	movzbl (%ebx),%ecx
f0104ccf:	01 ca                	add    %ecx,%edx
f0104cd1:	83 c3 01             	add    $0x1,%ebx
f0104cd4:	eb ee                	jmp    f0104cc4 <mp_init+0xb1>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0104cd6:	68 00 04 00 00       	push   $0x400
f0104cdb:	68 14 56 10 f0       	push   $0xf0105614
f0104ce0:	6a 6f                	push   $0x6f
f0104ce2:	68 81 70 10 f0       	push   $0xf0107081
f0104ce7:	e8 a8 b3 ff ff       	call   f0100094 <_panic>
		p = *(uint16_t *) (bda + 0x13) * 1024;
f0104cec:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0104cf3:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f0104cf6:	2d 00 04 00 00       	sub    $0x400,%eax
f0104cfb:	ba 00 04 00 00       	mov    $0x400,%edx
f0104d00:	e8 72 fe ff ff       	call   f0104b77 <mpsearch1>
f0104d05:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104d08:	85 c0                	test   %eax,%eax
f0104d0a:	0f 85 60 ff ff ff    	jne    f0104c70 <mp_init+0x5d>
f0104d10:	e9 41 ff ff ff       	jmp    f0104c56 <mp_init+0x43>
		cprintf("SMP: Default configurations not implemented\n");
f0104d15:	83 ec 0c             	sub    $0xc,%esp
f0104d18:	68 f4 6e 10 f0       	push   $0xf0106ef4
f0104d1d:	e8 8b ea ff ff       	call   f01037ad <cprintf>
f0104d22:	83 c4 10             	add    $0x10,%esp
f0104d25:	e9 77 01 00 00       	jmp    f0104ea1 <mp_init+0x28e>
f0104d2a:	53                   	push   %ebx
f0104d2b:	68 14 56 10 f0       	push   $0xf0105614
f0104d30:	68 90 00 00 00       	push   $0x90
f0104d35:	68 81 70 10 f0       	push   $0xf0107081
f0104d3a:	e8 55 b3 ff ff       	call   f0100094 <_panic>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0104d3f:	83 ec 0c             	sub    $0xc,%esp
f0104d42:	68 24 6f 10 f0       	push   $0xf0106f24
f0104d47:	e8 61 ea ff ff       	call   f01037ad <cprintf>
f0104d4c:	83 c4 10             	add    $0x10,%esp
f0104d4f:	e9 4d 01 00 00       	jmp    f0104ea1 <mp_init+0x28e>
	if (sum(conf, conf->length) != 0) {
f0104d54:	84 d2                	test   %dl,%dl
f0104d56:	75 16                	jne    f0104d6e <mp_init+0x15b>
	if (conf->version != 1 && conf->version != 4) {
f0104d58:	0f b6 56 06          	movzbl 0x6(%esi),%edx
f0104d5c:	80 fa 01             	cmp    $0x1,%dl
f0104d5f:	74 05                	je     f0104d66 <mp_init+0x153>
f0104d61:	80 fa 04             	cmp    $0x4,%dl
f0104d64:	75 1d                	jne    f0104d83 <mp_init+0x170>
f0104d66:	0f b7 4e 28          	movzwl 0x28(%esi),%ecx
f0104d6a:	01 d9                	add    %ebx,%ecx
f0104d6c:	eb 36                	jmp    f0104da4 <mp_init+0x191>
		cprintf("SMP: Bad MP configuration checksum\n");
f0104d6e:	83 ec 0c             	sub    $0xc,%esp
f0104d71:	68 58 6f 10 f0       	push   $0xf0106f58
f0104d76:	e8 32 ea ff ff       	call   f01037ad <cprintf>
f0104d7b:	83 c4 10             	add    $0x10,%esp
f0104d7e:	e9 1e 01 00 00       	jmp    f0104ea1 <mp_init+0x28e>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0104d83:	83 ec 08             	sub    $0x8,%esp
f0104d86:	0f b6 d2             	movzbl %dl,%edx
f0104d89:	52                   	push   %edx
f0104d8a:	68 7c 6f 10 f0       	push   $0xf0106f7c
f0104d8f:	e8 19 ea ff ff       	call   f01037ad <cprintf>
f0104d94:	83 c4 10             	add    $0x10,%esp
f0104d97:	e9 05 01 00 00       	jmp    f0104ea1 <mp_init+0x28e>
		sum += ((uint8_t *)addr)[i];
f0104d9c:	0f b6 13             	movzbl (%ebx),%edx
f0104d9f:	01 d0                	add    %edx,%eax
f0104da1:	83 c3 01             	add    $0x1,%ebx
	for (i = 0; i < len; i++)
f0104da4:	39 d9                	cmp    %ebx,%ecx
f0104da6:	75 f4                	jne    f0104d9c <mp_init+0x189>
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0104da8:	02 46 2a             	add    0x2a(%esi),%al
f0104dab:	75 1c                	jne    f0104dc9 <mp_init+0x1b6>
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
f0104dad:	c7 05 00 20 23 f0 01 	movl   $0x1,0xf0232000
f0104db4:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0104db7:	8b 46 24             	mov    0x24(%esi),%eax
f0104dba:	a3 00 30 27 f0       	mov    %eax,0xf0273000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0104dbf:	8d 7e 2c             	lea    0x2c(%esi),%edi
f0104dc2:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104dc7:	eb 4d                	jmp    f0104e16 <mp_init+0x203>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0104dc9:	83 ec 0c             	sub    $0xc,%esp
f0104dcc:	68 9c 6f 10 f0       	push   $0xf0106f9c
f0104dd1:	e8 d7 e9 ff ff       	call   f01037ad <cprintf>
f0104dd6:	83 c4 10             	add    $0x10,%esp
f0104dd9:	e9 c3 00 00 00       	jmp    f0104ea1 <mp_init+0x28e>
		switch (*p) {
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0104dde:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f0104de2:	74 11                	je     f0104df5 <mp_init+0x1e2>
				bootcpu = &cpus[ncpu];
f0104de4:	6b 05 c4 23 23 f0 74 	imul   $0x74,0xf02323c4,%eax
f0104deb:	05 20 20 23 f0       	add    $0xf0232020,%eax
f0104df0:	a3 c0 23 23 f0       	mov    %eax,0xf02323c0
			if (ncpu < NCPU) {
f0104df5:	a1 c4 23 23 f0       	mov    0xf02323c4,%eax
f0104dfa:	83 f8 07             	cmp    $0x7,%eax
f0104dfd:	7f 2f                	jg     f0104e2e <mp_init+0x21b>
				cpus[ncpu].cpu_id = ncpu;
f0104dff:	6b d0 74             	imul   $0x74,%eax,%edx
f0104e02:	88 82 20 20 23 f0    	mov    %al,-0xfdcdfe0(%edx)
				ncpu++;
f0104e08:	83 c0 01             	add    $0x1,%eax
f0104e0b:	a3 c4 23 23 f0       	mov    %eax,0xf02323c4
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0104e10:	83 c7 14             	add    $0x14,%edi
	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0104e13:	83 c3 01             	add    $0x1,%ebx
f0104e16:	0f b7 46 22          	movzwl 0x22(%esi),%eax
f0104e1a:	39 d8                	cmp    %ebx,%eax
f0104e1c:	76 4b                	jbe    f0104e69 <mp_init+0x256>
		switch (*p) {
f0104e1e:	0f b6 07             	movzbl (%edi),%eax
f0104e21:	84 c0                	test   %al,%al
f0104e23:	74 b9                	je     f0104dde <mp_init+0x1cb>
f0104e25:	3c 04                	cmp    $0x4,%al
f0104e27:	77 1c                	ja     f0104e45 <mp_init+0x232>
			continue;
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0104e29:	83 c7 08             	add    $0x8,%edi
			continue;
f0104e2c:	eb e5                	jmp    f0104e13 <mp_init+0x200>
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0104e2e:	83 ec 08             	sub    $0x8,%esp
f0104e31:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f0104e35:	50                   	push   %eax
f0104e36:	68 cc 6f 10 f0       	push   $0xf0106fcc
f0104e3b:	e8 6d e9 ff ff       	call   f01037ad <cprintf>
f0104e40:	83 c4 10             	add    $0x10,%esp
f0104e43:	eb cb                	jmp    f0104e10 <mp_init+0x1fd>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0104e45:	83 ec 08             	sub    $0x8,%esp
		switch (*p) {
f0104e48:	0f b6 c0             	movzbl %al,%eax
			cprintf("mpinit: unknown config type %x\n", *p);
f0104e4b:	50                   	push   %eax
f0104e4c:	68 f4 6f 10 f0       	push   $0xf0106ff4
f0104e51:	e8 57 e9 ff ff       	call   f01037ad <cprintf>
			ismp = 0;
f0104e56:	c7 05 00 20 23 f0 00 	movl   $0x0,0xf0232000
f0104e5d:	00 00 00 
			i = conf->entry;
f0104e60:	0f b7 5e 22          	movzwl 0x22(%esi),%ebx
f0104e64:	83 c4 10             	add    $0x10,%esp
f0104e67:	eb aa                	jmp    f0104e13 <mp_init+0x200>
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0104e69:	a1 c0 23 23 f0       	mov    0xf02323c0,%eax
f0104e6e:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0104e75:	83 3d 00 20 23 f0 00 	cmpl   $0x0,0xf0232000
f0104e7c:	74 2b                	je     f0104ea9 <mp_init+0x296>
		ncpu = 1;
		lapicaddr = 0;
		cprintf("SMP: configuration not found, SMP disabled\n");
		return;
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0104e7e:	83 ec 04             	sub    $0x4,%esp
f0104e81:	ff 35 c4 23 23 f0    	pushl  0xf02323c4
f0104e87:	0f b6 00             	movzbl (%eax),%eax
f0104e8a:	50                   	push   %eax
f0104e8b:	68 9b 70 10 f0       	push   $0xf010709b
f0104e90:	e8 18 e9 ff ff       	call   f01037ad <cprintf>

	if (mp->imcrp) {
f0104e95:	83 c4 10             	add    $0x10,%esp
f0104e98:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104e9b:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0104e9f:	75 2e                	jne    f0104ecf <mp_init+0x2bc>
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f0104ea1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104ea4:	5b                   	pop    %ebx
f0104ea5:	5e                   	pop    %esi
f0104ea6:	5f                   	pop    %edi
f0104ea7:	5d                   	pop    %ebp
f0104ea8:	c3                   	ret    
		ncpu = 1;
f0104ea9:	c7 05 c4 23 23 f0 01 	movl   $0x1,0xf02323c4
f0104eb0:	00 00 00 
		lapicaddr = 0;
f0104eb3:	c7 05 00 30 27 f0 00 	movl   $0x0,0xf0273000
f0104eba:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0104ebd:	83 ec 0c             	sub    $0xc,%esp
f0104ec0:	68 14 70 10 f0       	push   $0xf0107014
f0104ec5:	e8 e3 e8 ff ff       	call   f01037ad <cprintf>
		return;
f0104eca:	83 c4 10             	add    $0x10,%esp
f0104ecd:	eb d2                	jmp    f0104ea1 <mp_init+0x28e>
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0104ecf:	83 ec 0c             	sub    $0xc,%esp
f0104ed2:	68 40 70 10 f0       	push   $0xf0107040
f0104ed7:	e8 d1 e8 ff ff       	call   f01037ad <cprintf>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0104edc:	b8 70 00 00 00       	mov    $0x70,%eax
f0104ee1:	ba 22 00 00 00       	mov    $0x22,%edx
f0104ee6:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0104ee7:	ba 23 00 00 00       	mov    $0x23,%edx
f0104eec:	ec                   	in     (%dx),%al
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f0104eed:	83 c8 01             	or     $0x1,%eax
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0104ef0:	ee                   	out    %al,(%dx)
f0104ef1:	83 c4 10             	add    $0x10,%esp
f0104ef4:	eb ab                	jmp    f0104ea1 <mp_init+0x28e>

f0104ef6 <lapicw>:
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
	lapic[index] = value;
f0104ef6:	8b 0d 04 30 27 f0    	mov    0xf0273004,%ecx
f0104efc:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0104eff:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0104f01:	a1 04 30 27 f0       	mov    0xf0273004,%eax
f0104f06:	8b 40 20             	mov    0x20(%eax),%eax
}
f0104f09:	c3                   	ret    

f0104f0a <cpunum>:
}

int
cpunum(void)
{
	if (lapic)
f0104f0a:	8b 15 04 30 27 f0    	mov    0xf0273004,%edx
		return lapic[ID] >> 24;
	return 0;
f0104f10:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lapic)
f0104f15:	85 d2                	test   %edx,%edx
f0104f17:	74 06                	je     f0104f1f <cpunum+0x15>
		return lapic[ID] >> 24;
f0104f19:	8b 42 20             	mov    0x20(%edx),%eax
f0104f1c:	c1 e8 18             	shr    $0x18,%eax
}
f0104f1f:	c3                   	ret    

f0104f20 <lapic_init>:
	if (!lapicaddr)
f0104f20:	a1 00 30 27 f0       	mov    0xf0273000,%eax
f0104f25:	85 c0                	test   %eax,%eax
f0104f27:	75 01                	jne    f0104f2a <lapic_init+0xa>
f0104f29:	c3                   	ret    
{
f0104f2a:	55                   	push   %ebp
f0104f2b:	89 e5                	mov    %esp,%ebp
f0104f2d:	83 ec 10             	sub    $0x10,%esp
	lapic = mmio_map_region(lapicaddr, 4096);
f0104f30:	68 00 10 00 00       	push   $0x1000
f0104f35:	50                   	push   %eax
f0104f36:	e8 3d c3 ff ff       	call   f0101278 <mmio_map_region>
f0104f3b:	a3 04 30 27 f0       	mov    %eax,0xf0273004
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0104f40:	ba 27 01 00 00       	mov    $0x127,%edx
f0104f45:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0104f4a:	e8 a7 ff ff ff       	call   f0104ef6 <lapicw>
	lapicw(TDCR, X1);
f0104f4f:	ba 0b 00 00 00       	mov    $0xb,%edx
f0104f54:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0104f59:	e8 98 ff ff ff       	call   f0104ef6 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0104f5e:	ba 20 00 02 00       	mov    $0x20020,%edx
f0104f63:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0104f68:	e8 89 ff ff ff       	call   f0104ef6 <lapicw>
	lapicw(TICR, 10000000); 
f0104f6d:	ba 80 96 98 00       	mov    $0x989680,%edx
f0104f72:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0104f77:	e8 7a ff ff ff       	call   f0104ef6 <lapicw>
	if (thiscpu != bootcpu)
f0104f7c:	e8 89 ff ff ff       	call   f0104f0a <cpunum>
f0104f81:	6b c0 74             	imul   $0x74,%eax,%eax
f0104f84:	05 20 20 23 f0       	add    $0xf0232020,%eax
f0104f89:	83 c4 10             	add    $0x10,%esp
f0104f8c:	39 05 c0 23 23 f0    	cmp    %eax,0xf02323c0
f0104f92:	74 0f                	je     f0104fa3 <lapic_init+0x83>
		lapicw(LINT0, MASKED);
f0104f94:	ba 00 00 01 00       	mov    $0x10000,%edx
f0104f99:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0104f9e:	e8 53 ff ff ff       	call   f0104ef6 <lapicw>
	lapicw(LINT1, MASKED);
f0104fa3:	ba 00 00 01 00       	mov    $0x10000,%edx
f0104fa8:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0104fad:	e8 44 ff ff ff       	call   f0104ef6 <lapicw>
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0104fb2:	a1 04 30 27 f0       	mov    0xf0273004,%eax
f0104fb7:	8b 40 30             	mov    0x30(%eax),%eax
f0104fba:	c1 e8 10             	shr    $0x10,%eax
f0104fbd:	a8 fc                	test   $0xfc,%al
f0104fbf:	75 7c                	jne    f010503d <lapic_init+0x11d>
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0104fc1:	ba 33 00 00 00       	mov    $0x33,%edx
f0104fc6:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0104fcb:	e8 26 ff ff ff       	call   f0104ef6 <lapicw>
	lapicw(ESR, 0);
f0104fd0:	ba 00 00 00 00       	mov    $0x0,%edx
f0104fd5:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0104fda:	e8 17 ff ff ff       	call   f0104ef6 <lapicw>
	lapicw(ESR, 0);
f0104fdf:	ba 00 00 00 00       	mov    $0x0,%edx
f0104fe4:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0104fe9:	e8 08 ff ff ff       	call   f0104ef6 <lapicw>
	lapicw(EOI, 0);
f0104fee:	ba 00 00 00 00       	mov    $0x0,%edx
f0104ff3:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0104ff8:	e8 f9 fe ff ff       	call   f0104ef6 <lapicw>
	lapicw(ICRHI, 0);
f0104ffd:	ba 00 00 00 00       	mov    $0x0,%edx
f0105002:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105007:	e8 ea fe ff ff       	call   f0104ef6 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f010500c:	ba 00 85 08 00       	mov    $0x88500,%edx
f0105011:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105016:	e8 db fe ff ff       	call   f0104ef6 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f010501b:	8b 15 04 30 27 f0    	mov    0xf0273004,%edx
f0105021:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105027:	f6 c4 10             	test   $0x10,%ah
f010502a:	75 f5                	jne    f0105021 <lapic_init+0x101>
	lapicw(TPR, 0);
f010502c:	ba 00 00 00 00       	mov    $0x0,%edx
f0105031:	b8 20 00 00 00       	mov    $0x20,%eax
f0105036:	e8 bb fe ff ff       	call   f0104ef6 <lapicw>
}
f010503b:	c9                   	leave  
f010503c:	c3                   	ret    
		lapicw(PCINT, MASKED);
f010503d:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105042:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0105047:	e8 aa fe ff ff       	call   f0104ef6 <lapicw>
f010504c:	e9 70 ff ff ff       	jmp    f0104fc1 <lapic_init+0xa1>

f0105051 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f0105051:	83 3d 04 30 27 f0 00 	cmpl   $0x0,0xf0273004
f0105058:	74 17                	je     f0105071 <lapic_eoi+0x20>
{
f010505a:	55                   	push   %ebp
f010505b:	89 e5                	mov    %esp,%ebp
f010505d:	83 ec 08             	sub    $0x8,%esp
		lapicw(EOI, 0);
f0105060:	ba 00 00 00 00       	mov    $0x0,%edx
f0105065:	b8 2c 00 00 00       	mov    $0x2c,%eax
f010506a:	e8 87 fe ff ff       	call   f0104ef6 <lapicw>
}
f010506f:	c9                   	leave  
f0105070:	c3                   	ret    
f0105071:	c3                   	ret    

f0105072 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0105072:	55                   	push   %ebp
f0105073:	89 e5                	mov    %esp,%ebp
f0105075:	56                   	push   %esi
f0105076:	53                   	push   %ebx
f0105077:	8b 75 08             	mov    0x8(%ebp),%esi
f010507a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010507d:	b8 0f 00 00 00       	mov    $0xf,%eax
f0105082:	ba 70 00 00 00       	mov    $0x70,%edx
f0105087:	ee                   	out    %al,(%dx)
f0105088:	b8 0a 00 00 00       	mov    $0xa,%eax
f010508d:	ba 71 00 00 00       	mov    $0x71,%edx
f0105092:	ee                   	out    %al,(%dx)
	if (PGNUM(pa) >= npages)
f0105093:	83 3d 88 1e 23 f0 00 	cmpl   $0x0,0xf0231e88
f010509a:	74 7e                	je     f010511a <lapic_startap+0xa8>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f010509c:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f01050a3:	00 00 
	wrv[1] = addr >> 4;
f01050a5:	89 d8                	mov    %ebx,%eax
f01050a7:	c1 e8 04             	shr    $0x4,%eax
f01050aa:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f01050b0:	c1 e6 18             	shl    $0x18,%esi
f01050b3:	89 f2                	mov    %esi,%edx
f01050b5:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01050ba:	e8 37 fe ff ff       	call   f0104ef6 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f01050bf:	ba 00 c5 00 00       	mov    $0xc500,%edx
f01050c4:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01050c9:	e8 28 fe ff ff       	call   f0104ef6 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f01050ce:	ba 00 85 00 00       	mov    $0x8500,%edx
f01050d3:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01050d8:	e8 19 fe ff ff       	call   f0104ef6 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01050dd:	c1 eb 0c             	shr    $0xc,%ebx
f01050e0:	80 cf 06             	or     $0x6,%bh
		lapicw(ICRHI, apicid << 24);
f01050e3:	89 f2                	mov    %esi,%edx
f01050e5:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01050ea:	e8 07 fe ff ff       	call   f0104ef6 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01050ef:	89 da                	mov    %ebx,%edx
f01050f1:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01050f6:	e8 fb fd ff ff       	call   f0104ef6 <lapicw>
		lapicw(ICRHI, apicid << 24);
f01050fb:	89 f2                	mov    %esi,%edx
f01050fd:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105102:	e8 ef fd ff ff       	call   f0104ef6 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105107:	89 da                	mov    %ebx,%edx
f0105109:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010510e:	e8 e3 fd ff ff       	call   f0104ef6 <lapicw>
		microdelay(200);
	}
}
f0105113:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105116:	5b                   	pop    %ebx
f0105117:	5e                   	pop    %esi
f0105118:	5d                   	pop    %ebp
f0105119:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010511a:	68 67 04 00 00       	push   $0x467
f010511f:	68 14 56 10 f0       	push   $0xf0105614
f0105124:	68 98 00 00 00       	push   $0x98
f0105129:	68 b8 70 10 f0       	push   $0xf01070b8
f010512e:	e8 61 af ff ff       	call   f0100094 <_panic>

f0105133 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0105133:	55                   	push   %ebp
f0105134:	89 e5                	mov    %esp,%ebp
f0105136:	83 ec 08             	sub    $0x8,%esp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0105139:	8b 55 08             	mov    0x8(%ebp),%edx
f010513c:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0105142:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105147:	e8 aa fd ff ff       	call   f0104ef6 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f010514c:	8b 15 04 30 27 f0    	mov    0xf0273004,%edx
f0105152:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105158:	f6 c4 10             	test   $0x10,%ah
f010515b:	75 f5                	jne    f0105152 <lapic_ipi+0x1f>
		;
}
f010515d:	c9                   	leave  
f010515e:	c3                   	ret    

f010515f <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f010515f:	55                   	push   %ebp
f0105160:	89 e5                	mov    %esp,%ebp
f0105162:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0105165:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f010516b:	8b 55 0c             	mov    0xc(%ebp),%edx
f010516e:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0105171:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0105178:	5d                   	pop    %ebp
f0105179:	c3                   	ret    

f010517a <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f010517a:	55                   	push   %ebp
f010517b:	89 e5                	mov    %esp,%ebp
f010517d:	56                   	push   %esi
f010517e:	53                   	push   %ebx
f010517f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	return lock->locked && lock->cpu == thiscpu;
f0105182:	83 3b 00             	cmpl   $0x0,(%ebx)
f0105185:	75 12                	jne    f0105199 <spin_lock+0x1f>
	asm volatile("lock; xchgl %0, %1"
f0105187:	ba 01 00 00 00       	mov    $0x1,%edx
f010518c:	89 d0                	mov    %edx,%eax
f010518e:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0105191:	85 c0                	test   %eax,%eax
f0105193:	74 36                	je     f01051cb <spin_lock+0x51>
		asm volatile ("pause");
f0105195:	f3 90                	pause  
f0105197:	eb f3                	jmp    f010518c <spin_lock+0x12>
	return lock->locked && lock->cpu == thiscpu;
f0105199:	8b 73 08             	mov    0x8(%ebx),%esi
f010519c:	e8 69 fd ff ff       	call   f0104f0a <cpunum>
f01051a1:	6b c0 74             	imul   $0x74,%eax,%eax
f01051a4:	05 20 20 23 f0       	add    $0xf0232020,%eax
	if (holding(lk))
f01051a9:	39 c6                	cmp    %eax,%esi
f01051ab:	75 da                	jne    f0105187 <spin_lock+0xd>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f01051ad:	8b 5b 04             	mov    0x4(%ebx),%ebx
f01051b0:	e8 55 fd ff ff       	call   f0104f0a <cpunum>
f01051b5:	83 ec 0c             	sub    $0xc,%esp
f01051b8:	53                   	push   %ebx
f01051b9:	50                   	push   %eax
f01051ba:	68 c8 70 10 f0       	push   $0xf01070c8
f01051bf:	6a 41                	push   $0x41
f01051c1:	68 2c 71 10 f0       	push   $0xf010712c
f01051c6:	e8 c9 ae ff ff       	call   f0100094 <_panic>

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f01051cb:	e8 3a fd ff ff       	call   f0104f0a <cpunum>
f01051d0:	6b c0 74             	imul   $0x74,%eax,%eax
f01051d3:	05 20 20 23 f0       	add    $0xf0232020,%eax
f01051d8:	89 43 08             	mov    %eax,0x8(%ebx)
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f01051db:	89 ea                	mov    %ebp,%edx
	for (i = 0; i < 10; i++){
f01051dd:	b8 00 00 00 00       	mov    $0x0,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f01051e2:	83 f8 09             	cmp    $0x9,%eax
f01051e5:	7f 16                	jg     f01051fd <spin_lock+0x83>
f01051e7:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f01051ed:	76 0e                	jbe    f01051fd <spin_lock+0x83>
		pcs[i] = ebp[1];          // saved %eip
f01051ef:	8b 4a 04             	mov    0x4(%edx),%ecx
f01051f2:	89 4c 83 0c          	mov    %ecx,0xc(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f01051f6:	8b 12                	mov    (%edx),%edx
	for (i = 0; i < 10; i++){
f01051f8:	83 c0 01             	add    $0x1,%eax
f01051fb:	eb e5                	jmp    f01051e2 <spin_lock+0x68>
	for (; i < 10; i++)
f01051fd:	83 f8 09             	cmp    $0x9,%eax
f0105200:	7f 0d                	jg     f010520f <spin_lock+0x95>
		pcs[i] = 0;
f0105202:	c7 44 83 0c 00 00 00 	movl   $0x0,0xc(%ebx,%eax,4)
f0105209:	00 
	for (; i < 10; i++)
f010520a:	83 c0 01             	add    $0x1,%eax
f010520d:	eb ee                	jmp    f01051fd <spin_lock+0x83>
	get_caller_pcs(lk->pcs);
#endif
}
f010520f:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105212:	5b                   	pop    %ebx
f0105213:	5e                   	pop    %esi
f0105214:	5d                   	pop    %ebp
f0105215:	c3                   	ret    

f0105216 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0105216:	55                   	push   %ebp
f0105217:	89 e5                	mov    %esp,%ebp
f0105219:	57                   	push   %edi
f010521a:	56                   	push   %esi
f010521b:	53                   	push   %ebx
f010521c:	83 ec 4c             	sub    $0x4c,%esp
f010521f:	8b 75 08             	mov    0x8(%ebp),%esi
	return lock->locked && lock->cpu == thiscpu;
f0105222:	83 3e 00             	cmpl   $0x0,(%esi)
f0105225:	75 35                	jne    f010525c <spin_unlock+0x46>
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f0105227:	83 ec 04             	sub    $0x4,%esp
f010522a:	6a 28                	push   $0x28
f010522c:	8d 46 0c             	lea    0xc(%esi),%eax
f010522f:	50                   	push   %eax
f0105230:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f0105233:	53                   	push   %ebx
f0105234:	e8 19 f7 ff ff       	call   f0104952 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f0105239:	8b 46 08             	mov    0x8(%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f010523c:	0f b6 38             	movzbl (%eax),%edi
f010523f:	8b 76 04             	mov    0x4(%esi),%esi
f0105242:	e8 c3 fc ff ff       	call   f0104f0a <cpunum>
f0105247:	57                   	push   %edi
f0105248:	56                   	push   %esi
f0105249:	50                   	push   %eax
f010524a:	68 f4 70 10 f0       	push   $0xf01070f4
f010524f:	e8 59 e5 ff ff       	call   f01037ad <cprintf>
f0105254:	83 c4 20             	add    $0x20,%esp
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0105257:	8d 7d a8             	lea    -0x58(%ebp),%edi
f010525a:	eb 4e                	jmp    f01052aa <spin_unlock+0x94>
	return lock->locked && lock->cpu == thiscpu;
f010525c:	8b 5e 08             	mov    0x8(%esi),%ebx
f010525f:	e8 a6 fc ff ff       	call   f0104f0a <cpunum>
f0105264:	6b c0 74             	imul   $0x74,%eax,%eax
f0105267:	05 20 20 23 f0       	add    $0xf0232020,%eax
	if (!holding(lk)) {
f010526c:	39 c3                	cmp    %eax,%ebx
f010526e:	75 b7                	jne    f0105227 <spin_unlock+0x11>
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
	}

	lk->pcs[0] = 0;
f0105270:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f0105277:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
	asm volatile("lock; xchgl %0, %1"
f010527e:	b8 00 00 00 00       	mov    $0x0,%eax
f0105283:	f0 87 06             	lock xchg %eax,(%esi)
	// respect to any other instruction which references the same memory.
	// x86 CPUs will not reorder loads/stores across locked instructions
	// (vol 3, 8.2.2). Because xchg() is implemented using asm volatile,
	// gcc will not reorder C statements across the xchg.
	xchg(&lk->locked, 0);
}
f0105286:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105289:	5b                   	pop    %ebx
f010528a:	5e                   	pop    %esi
f010528b:	5f                   	pop    %edi
f010528c:	5d                   	pop    %ebp
f010528d:	c3                   	ret    
				cprintf("  %08x\n", pcs[i]);
f010528e:	83 ec 08             	sub    $0x8,%esp
f0105291:	ff 36                	pushl  (%esi)
f0105293:	68 53 71 10 f0       	push   $0xf0107153
f0105298:	e8 10 e5 ff ff       	call   f01037ad <cprintf>
f010529d:	83 c4 10             	add    $0x10,%esp
f01052a0:	83 c3 04             	add    $0x4,%ebx
		for (i = 0; i < 10 && pcs[i]; i++) {
f01052a3:	8d 45 e8             	lea    -0x18(%ebp),%eax
f01052a6:	39 c3                	cmp    %eax,%ebx
f01052a8:	74 40                	je     f01052ea <spin_unlock+0xd4>
f01052aa:	89 de                	mov    %ebx,%esi
f01052ac:	8b 03                	mov    (%ebx),%eax
f01052ae:	85 c0                	test   %eax,%eax
f01052b0:	74 38                	je     f01052ea <spin_unlock+0xd4>
			if (debuginfo_eip(pcs[i], &info) >= 0)
f01052b2:	83 ec 08             	sub    $0x8,%esp
f01052b5:	57                   	push   %edi
f01052b6:	50                   	push   %eax
f01052b7:	e8 0f ec ff ff       	call   f0103ecb <debuginfo_eip>
f01052bc:	83 c4 10             	add    $0x10,%esp
f01052bf:	85 c0                	test   %eax,%eax
f01052c1:	78 cb                	js     f010528e <spin_unlock+0x78>
					pcs[i] - info.eip_fn_addr);
f01052c3:	8b 06                	mov    (%esi),%eax
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f01052c5:	83 ec 04             	sub    $0x4,%esp
f01052c8:	89 c2                	mov    %eax,%edx
f01052ca:	2b 55 b8             	sub    -0x48(%ebp),%edx
f01052cd:	52                   	push   %edx
f01052ce:	ff 75 b0             	pushl  -0x50(%ebp)
f01052d1:	ff 75 b4             	pushl  -0x4c(%ebp)
f01052d4:	ff 75 ac             	pushl  -0x54(%ebp)
f01052d7:	ff 75 a8             	pushl  -0x58(%ebp)
f01052da:	50                   	push   %eax
f01052db:	68 3c 71 10 f0       	push   $0xf010713c
f01052e0:	e8 c8 e4 ff ff       	call   f01037ad <cprintf>
f01052e5:	83 c4 20             	add    $0x20,%esp
f01052e8:	eb b6                	jmp    f01052a0 <spin_unlock+0x8a>
		panic("spin_unlock");
f01052ea:	83 ec 04             	sub    $0x4,%esp
f01052ed:	68 5b 71 10 f0       	push   $0xf010715b
f01052f2:	6a 67                	push   $0x67
f01052f4:	68 2c 71 10 f0       	push   $0xf010712c
f01052f9:	e8 96 ad ff ff       	call   f0100094 <_panic>
f01052fe:	66 90                	xchg   %ax,%ax

f0105300 <__udivdi3>:
f0105300:	f3 0f 1e fb          	endbr32 
f0105304:	55                   	push   %ebp
f0105305:	57                   	push   %edi
f0105306:	56                   	push   %esi
f0105307:	53                   	push   %ebx
f0105308:	83 ec 1c             	sub    $0x1c,%esp
f010530b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010530f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f0105313:	8b 74 24 34          	mov    0x34(%esp),%esi
f0105317:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f010531b:	85 d2                	test   %edx,%edx
f010531d:	75 49                	jne    f0105368 <__udivdi3+0x68>
f010531f:	39 f3                	cmp    %esi,%ebx
f0105321:	76 15                	jbe    f0105338 <__udivdi3+0x38>
f0105323:	31 ff                	xor    %edi,%edi
f0105325:	89 e8                	mov    %ebp,%eax
f0105327:	89 f2                	mov    %esi,%edx
f0105329:	f7 f3                	div    %ebx
f010532b:	89 fa                	mov    %edi,%edx
f010532d:	83 c4 1c             	add    $0x1c,%esp
f0105330:	5b                   	pop    %ebx
f0105331:	5e                   	pop    %esi
f0105332:	5f                   	pop    %edi
f0105333:	5d                   	pop    %ebp
f0105334:	c3                   	ret    
f0105335:	8d 76 00             	lea    0x0(%esi),%esi
f0105338:	89 d9                	mov    %ebx,%ecx
f010533a:	85 db                	test   %ebx,%ebx
f010533c:	75 0b                	jne    f0105349 <__udivdi3+0x49>
f010533e:	b8 01 00 00 00       	mov    $0x1,%eax
f0105343:	31 d2                	xor    %edx,%edx
f0105345:	f7 f3                	div    %ebx
f0105347:	89 c1                	mov    %eax,%ecx
f0105349:	31 d2                	xor    %edx,%edx
f010534b:	89 f0                	mov    %esi,%eax
f010534d:	f7 f1                	div    %ecx
f010534f:	89 c6                	mov    %eax,%esi
f0105351:	89 e8                	mov    %ebp,%eax
f0105353:	89 f7                	mov    %esi,%edi
f0105355:	f7 f1                	div    %ecx
f0105357:	89 fa                	mov    %edi,%edx
f0105359:	83 c4 1c             	add    $0x1c,%esp
f010535c:	5b                   	pop    %ebx
f010535d:	5e                   	pop    %esi
f010535e:	5f                   	pop    %edi
f010535f:	5d                   	pop    %ebp
f0105360:	c3                   	ret    
f0105361:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105368:	39 f2                	cmp    %esi,%edx
f010536a:	77 1c                	ja     f0105388 <__udivdi3+0x88>
f010536c:	0f bd fa             	bsr    %edx,%edi
f010536f:	83 f7 1f             	xor    $0x1f,%edi
f0105372:	75 2c                	jne    f01053a0 <__udivdi3+0xa0>
f0105374:	39 f2                	cmp    %esi,%edx
f0105376:	72 06                	jb     f010537e <__udivdi3+0x7e>
f0105378:	31 c0                	xor    %eax,%eax
f010537a:	39 eb                	cmp    %ebp,%ebx
f010537c:	77 ad                	ja     f010532b <__udivdi3+0x2b>
f010537e:	b8 01 00 00 00       	mov    $0x1,%eax
f0105383:	eb a6                	jmp    f010532b <__udivdi3+0x2b>
f0105385:	8d 76 00             	lea    0x0(%esi),%esi
f0105388:	31 ff                	xor    %edi,%edi
f010538a:	31 c0                	xor    %eax,%eax
f010538c:	89 fa                	mov    %edi,%edx
f010538e:	83 c4 1c             	add    $0x1c,%esp
f0105391:	5b                   	pop    %ebx
f0105392:	5e                   	pop    %esi
f0105393:	5f                   	pop    %edi
f0105394:	5d                   	pop    %ebp
f0105395:	c3                   	ret    
f0105396:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f010539d:	8d 76 00             	lea    0x0(%esi),%esi
f01053a0:	89 f9                	mov    %edi,%ecx
f01053a2:	b8 20 00 00 00       	mov    $0x20,%eax
f01053a7:	29 f8                	sub    %edi,%eax
f01053a9:	d3 e2                	shl    %cl,%edx
f01053ab:	89 54 24 08          	mov    %edx,0x8(%esp)
f01053af:	89 c1                	mov    %eax,%ecx
f01053b1:	89 da                	mov    %ebx,%edx
f01053b3:	d3 ea                	shr    %cl,%edx
f01053b5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f01053b9:	09 d1                	or     %edx,%ecx
f01053bb:	89 f2                	mov    %esi,%edx
f01053bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01053c1:	89 f9                	mov    %edi,%ecx
f01053c3:	d3 e3                	shl    %cl,%ebx
f01053c5:	89 c1                	mov    %eax,%ecx
f01053c7:	d3 ea                	shr    %cl,%edx
f01053c9:	89 f9                	mov    %edi,%ecx
f01053cb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01053cf:	89 eb                	mov    %ebp,%ebx
f01053d1:	d3 e6                	shl    %cl,%esi
f01053d3:	89 c1                	mov    %eax,%ecx
f01053d5:	d3 eb                	shr    %cl,%ebx
f01053d7:	09 de                	or     %ebx,%esi
f01053d9:	89 f0                	mov    %esi,%eax
f01053db:	f7 74 24 08          	divl   0x8(%esp)
f01053df:	89 d6                	mov    %edx,%esi
f01053e1:	89 c3                	mov    %eax,%ebx
f01053e3:	f7 64 24 0c          	mull   0xc(%esp)
f01053e7:	39 d6                	cmp    %edx,%esi
f01053e9:	72 15                	jb     f0105400 <__udivdi3+0x100>
f01053eb:	89 f9                	mov    %edi,%ecx
f01053ed:	d3 e5                	shl    %cl,%ebp
f01053ef:	39 c5                	cmp    %eax,%ebp
f01053f1:	73 04                	jae    f01053f7 <__udivdi3+0xf7>
f01053f3:	39 d6                	cmp    %edx,%esi
f01053f5:	74 09                	je     f0105400 <__udivdi3+0x100>
f01053f7:	89 d8                	mov    %ebx,%eax
f01053f9:	31 ff                	xor    %edi,%edi
f01053fb:	e9 2b ff ff ff       	jmp    f010532b <__udivdi3+0x2b>
f0105400:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0105403:	31 ff                	xor    %edi,%edi
f0105405:	e9 21 ff ff ff       	jmp    f010532b <__udivdi3+0x2b>
f010540a:	66 90                	xchg   %ax,%ax
f010540c:	66 90                	xchg   %ax,%ax
f010540e:	66 90                	xchg   %ax,%ax

f0105410 <__umoddi3>:
f0105410:	f3 0f 1e fb          	endbr32 
f0105414:	55                   	push   %ebp
f0105415:	57                   	push   %edi
f0105416:	56                   	push   %esi
f0105417:	53                   	push   %ebx
f0105418:	83 ec 1c             	sub    $0x1c,%esp
f010541b:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f010541f:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f0105423:	8b 74 24 30          	mov    0x30(%esp),%esi
f0105427:	8b 7c 24 38          	mov    0x38(%esp),%edi
f010542b:	89 da                	mov    %ebx,%edx
f010542d:	85 c0                	test   %eax,%eax
f010542f:	75 3f                	jne    f0105470 <__umoddi3+0x60>
f0105431:	39 df                	cmp    %ebx,%edi
f0105433:	76 13                	jbe    f0105448 <__umoddi3+0x38>
f0105435:	89 f0                	mov    %esi,%eax
f0105437:	f7 f7                	div    %edi
f0105439:	89 d0                	mov    %edx,%eax
f010543b:	31 d2                	xor    %edx,%edx
f010543d:	83 c4 1c             	add    $0x1c,%esp
f0105440:	5b                   	pop    %ebx
f0105441:	5e                   	pop    %esi
f0105442:	5f                   	pop    %edi
f0105443:	5d                   	pop    %ebp
f0105444:	c3                   	ret    
f0105445:	8d 76 00             	lea    0x0(%esi),%esi
f0105448:	89 fd                	mov    %edi,%ebp
f010544a:	85 ff                	test   %edi,%edi
f010544c:	75 0b                	jne    f0105459 <__umoddi3+0x49>
f010544e:	b8 01 00 00 00       	mov    $0x1,%eax
f0105453:	31 d2                	xor    %edx,%edx
f0105455:	f7 f7                	div    %edi
f0105457:	89 c5                	mov    %eax,%ebp
f0105459:	89 d8                	mov    %ebx,%eax
f010545b:	31 d2                	xor    %edx,%edx
f010545d:	f7 f5                	div    %ebp
f010545f:	89 f0                	mov    %esi,%eax
f0105461:	f7 f5                	div    %ebp
f0105463:	89 d0                	mov    %edx,%eax
f0105465:	eb d4                	jmp    f010543b <__umoddi3+0x2b>
f0105467:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f010546e:	66 90                	xchg   %ax,%ax
f0105470:	89 f1                	mov    %esi,%ecx
f0105472:	39 d8                	cmp    %ebx,%eax
f0105474:	76 0a                	jbe    f0105480 <__umoddi3+0x70>
f0105476:	89 f0                	mov    %esi,%eax
f0105478:	83 c4 1c             	add    $0x1c,%esp
f010547b:	5b                   	pop    %ebx
f010547c:	5e                   	pop    %esi
f010547d:	5f                   	pop    %edi
f010547e:	5d                   	pop    %ebp
f010547f:	c3                   	ret    
f0105480:	0f bd e8             	bsr    %eax,%ebp
f0105483:	83 f5 1f             	xor    $0x1f,%ebp
f0105486:	75 20                	jne    f01054a8 <__umoddi3+0x98>
f0105488:	39 d8                	cmp    %ebx,%eax
f010548a:	0f 82 b0 00 00 00    	jb     f0105540 <__umoddi3+0x130>
f0105490:	39 f7                	cmp    %esi,%edi
f0105492:	0f 86 a8 00 00 00    	jbe    f0105540 <__umoddi3+0x130>
f0105498:	89 c8                	mov    %ecx,%eax
f010549a:	83 c4 1c             	add    $0x1c,%esp
f010549d:	5b                   	pop    %ebx
f010549e:	5e                   	pop    %esi
f010549f:	5f                   	pop    %edi
f01054a0:	5d                   	pop    %ebp
f01054a1:	c3                   	ret    
f01054a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01054a8:	89 e9                	mov    %ebp,%ecx
f01054aa:	ba 20 00 00 00       	mov    $0x20,%edx
f01054af:	29 ea                	sub    %ebp,%edx
f01054b1:	d3 e0                	shl    %cl,%eax
f01054b3:	89 44 24 08          	mov    %eax,0x8(%esp)
f01054b7:	89 d1                	mov    %edx,%ecx
f01054b9:	89 f8                	mov    %edi,%eax
f01054bb:	d3 e8                	shr    %cl,%eax
f01054bd:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f01054c1:	89 54 24 04          	mov    %edx,0x4(%esp)
f01054c5:	8b 54 24 04          	mov    0x4(%esp),%edx
f01054c9:	09 c1                	or     %eax,%ecx
f01054cb:	89 d8                	mov    %ebx,%eax
f01054cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01054d1:	89 e9                	mov    %ebp,%ecx
f01054d3:	d3 e7                	shl    %cl,%edi
f01054d5:	89 d1                	mov    %edx,%ecx
f01054d7:	d3 e8                	shr    %cl,%eax
f01054d9:	89 e9                	mov    %ebp,%ecx
f01054db:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01054df:	d3 e3                	shl    %cl,%ebx
f01054e1:	89 c7                	mov    %eax,%edi
f01054e3:	89 d1                	mov    %edx,%ecx
f01054e5:	89 f0                	mov    %esi,%eax
f01054e7:	d3 e8                	shr    %cl,%eax
f01054e9:	89 e9                	mov    %ebp,%ecx
f01054eb:	89 fa                	mov    %edi,%edx
f01054ed:	d3 e6                	shl    %cl,%esi
f01054ef:	09 d8                	or     %ebx,%eax
f01054f1:	f7 74 24 08          	divl   0x8(%esp)
f01054f5:	89 d1                	mov    %edx,%ecx
f01054f7:	89 f3                	mov    %esi,%ebx
f01054f9:	f7 64 24 0c          	mull   0xc(%esp)
f01054fd:	89 c6                	mov    %eax,%esi
f01054ff:	89 d7                	mov    %edx,%edi
f0105501:	39 d1                	cmp    %edx,%ecx
f0105503:	72 06                	jb     f010550b <__umoddi3+0xfb>
f0105505:	75 10                	jne    f0105517 <__umoddi3+0x107>
f0105507:	39 c3                	cmp    %eax,%ebx
f0105509:	73 0c                	jae    f0105517 <__umoddi3+0x107>
f010550b:	2b 44 24 0c          	sub    0xc(%esp),%eax
f010550f:	1b 54 24 08          	sbb    0x8(%esp),%edx
f0105513:	89 d7                	mov    %edx,%edi
f0105515:	89 c6                	mov    %eax,%esi
f0105517:	89 ca                	mov    %ecx,%edx
f0105519:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f010551e:	29 f3                	sub    %esi,%ebx
f0105520:	19 fa                	sbb    %edi,%edx
f0105522:	89 d0                	mov    %edx,%eax
f0105524:	d3 e0                	shl    %cl,%eax
f0105526:	89 e9                	mov    %ebp,%ecx
f0105528:	d3 eb                	shr    %cl,%ebx
f010552a:	d3 ea                	shr    %cl,%edx
f010552c:	09 d8                	or     %ebx,%eax
f010552e:	83 c4 1c             	add    $0x1c,%esp
f0105531:	5b                   	pop    %ebx
f0105532:	5e                   	pop    %esi
f0105533:	5f                   	pop    %edi
f0105534:	5d                   	pop    %ebp
f0105535:	c3                   	ret    
f0105536:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f010553d:	8d 76 00             	lea    0x0(%esi),%esi
f0105540:	89 da                	mov    %ebx,%edx
f0105542:	29 fe                	sub    %edi,%esi
f0105544:	19 c2                	sbb    %eax,%edx
f0105546:	89 f1                	mov    %esi,%ecx
f0105548:	89 c8                	mov    %ecx,%eax
f010554a:	e9 4b ff ff ff       	jmp    f010549a <__umoddi3+0x8a>
