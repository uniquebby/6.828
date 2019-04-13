
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
f0100015:	b8 00 30 11 00       	mov    $0x113000,%eax
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
f0100034:	bc 00 10 11 f0       	mov    $0xf0111000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 68 00 00 00       	call   f01000a6 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <test_backtrace>:
#include <kern/console.h>

// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	56                   	push   %esi
f0100044:	53                   	push   %ebx
f0100045:	e8 72 01 00 00       	call   f01001bc <__x86.get_pc_thunk.bx>
f010004a:	81 c3 1e 40 01 00    	add    $0x1401e,%ebx
f0100050:	8b 75 08             	mov    0x8(%ebp),%esi
	cprintf("entering test_backtrace %d\n", x);
f0100053:	83 ec 08             	sub    $0x8,%esp
f0100056:	56                   	push   %esi
f0100057:	8d 83 d8 da fe ff    	lea    -0x12528(%ebx),%eax
f010005d:	50                   	push   %eax
f010005e:	e8 63 0a 00 00       	call   f0100ac6 <cprintf>
	if (x > 0)
f0100063:	83 c4 10             	add    $0x10,%esp
f0100066:	85 f6                	test   %esi,%esi
f0100068:	7e 29                	jle    f0100093 <test_backtrace+0x53>
		test_backtrace(x-1);
f010006a:	83 ec 0c             	sub    $0xc,%esp
f010006d:	8d 46 ff             	lea    -0x1(%esi),%eax
f0100070:	50                   	push   %eax
f0100071:	e8 ca ff ff ff       	call   f0100040 <test_backtrace>
f0100076:	83 c4 10             	add    $0x10,%esp
	else
		mon_backtrace(0, 0, 0);
	cprintf("leaving test_backtrace %d\n", x);
f0100079:	83 ec 08             	sub    $0x8,%esp
f010007c:	56                   	push   %esi
f010007d:	8d 83 f4 da fe ff    	lea    -0x1250c(%ebx),%eax
f0100083:	50                   	push   %eax
f0100084:	e8 3d 0a 00 00       	call   f0100ac6 <cprintf>
}
f0100089:	83 c4 10             	add    $0x10,%esp
f010008c:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010008f:	5b                   	pop    %ebx
f0100090:	5e                   	pop    %esi
f0100091:	5d                   	pop    %ebp
f0100092:	c3                   	ret    
		mon_backtrace(0, 0, 0);
f0100093:	83 ec 04             	sub    $0x4,%esp
f0100096:	6a 00                	push   $0x0
f0100098:	6a 00                	push   $0x0
f010009a:	6a 00                	push   $0x0
f010009c:	e8 c8 07 00 00       	call   f0100869 <mon_backtrace>
f01000a1:	83 c4 10             	add    $0x10,%esp
f01000a4:	eb d3                	jmp    f0100079 <test_backtrace+0x39>

f01000a6 <i386_init>:

void
i386_init(void)
{
f01000a6:	55                   	push   %ebp
f01000a7:	89 e5                	mov    %esp,%ebp
f01000a9:	53                   	push   %ebx
f01000aa:	83 ec 08             	sub    $0x8,%esp
f01000ad:	e8 0a 01 00 00       	call   f01001bc <__x86.get_pc_thunk.bx>
f01000b2:	81 c3 b6 3f 01 00    	add    $0x13fb6,%ebx
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f01000b8:	c7 c2 80 40 11 f0    	mov    $0xf0114080,%edx
f01000be:	c7 c0 c0 46 11 f0    	mov    $0xf01146c0,%eax
f01000c4:	29 d0                	sub    %edx,%eax
f01000c6:	50                   	push   %eax
f01000c7:	6a 00                	push   $0x0
f01000c9:	52                   	push   %edx
f01000ca:	e8 1c 16 00 00       	call   f01016eb <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000cf:	e8 10 05 00 00       	call   f01005e4 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000d4:	83 c4 08             	add    $0x8,%esp
f01000d7:	68 ac 1a 00 00       	push   $0x1aac
f01000dc:	8d 83 0f db fe ff    	lea    -0x124f1(%ebx),%eax
f01000e2:	50                   	push   %eax
f01000e3:	e8 de 09 00 00       	call   f0100ac6 <cprintf>

	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f01000e8:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f01000ef:	e8 4c ff ff ff       	call   f0100040 <test_backtrace>
f01000f4:	83 c4 10             	add    $0x10,%esp

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f01000f7:	83 ec 0c             	sub    $0xc,%esp
f01000fa:	6a 00                	push   $0x0
f01000fc:	e8 0a 08 00 00       	call   f010090b <monitor>
f0100101:	83 c4 10             	add    $0x10,%esp
f0100104:	eb f1                	jmp    f01000f7 <i386_init+0x51>

f0100106 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100106:	55                   	push   %ebp
f0100107:	89 e5                	mov    %esp,%ebp
f0100109:	57                   	push   %edi
f010010a:	56                   	push   %esi
f010010b:	53                   	push   %ebx
f010010c:	83 ec 0c             	sub    $0xc,%esp
f010010f:	e8 a8 00 00 00       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100114:	81 c3 54 3f 01 00    	add    $0x13f54,%ebx
f010011a:	8b 7d 10             	mov    0x10(%ebp),%edi
	va_list ap;

	if (panicstr)
f010011d:	c7 c0 c4 46 11 f0    	mov    $0xf01146c4,%eax
f0100123:	83 38 00             	cmpl   $0x0,(%eax)
f0100126:	74 0f                	je     f0100137 <_panic+0x31>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100128:	83 ec 0c             	sub    $0xc,%esp
f010012b:	6a 00                	push   $0x0
f010012d:	e8 d9 07 00 00       	call   f010090b <monitor>
f0100132:	83 c4 10             	add    $0x10,%esp
f0100135:	eb f1                	jmp    f0100128 <_panic+0x22>
	panicstr = fmt;
f0100137:	89 38                	mov    %edi,(%eax)
	asm volatile("cli; cld");
f0100139:	fa                   	cli    
f010013a:	fc                   	cld    
	va_start(ap, fmt);
f010013b:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel panic at %s:%d: ", file, line);
f010013e:	83 ec 04             	sub    $0x4,%esp
f0100141:	ff 75 0c             	pushl  0xc(%ebp)
f0100144:	ff 75 08             	pushl  0x8(%ebp)
f0100147:	8d 83 2a db fe ff    	lea    -0x124d6(%ebx),%eax
f010014d:	50                   	push   %eax
f010014e:	e8 73 09 00 00       	call   f0100ac6 <cprintf>
	vcprintf(fmt, ap);
f0100153:	83 c4 08             	add    $0x8,%esp
f0100156:	56                   	push   %esi
f0100157:	57                   	push   %edi
f0100158:	e8 32 09 00 00       	call   f0100a8f <vcprintf>
	cprintf("\n");
f010015d:	8d 83 66 db fe ff    	lea    -0x1249a(%ebx),%eax
f0100163:	89 04 24             	mov    %eax,(%esp)
f0100166:	e8 5b 09 00 00       	call   f0100ac6 <cprintf>
f010016b:	83 c4 10             	add    $0x10,%esp
f010016e:	eb b8                	jmp    f0100128 <_panic+0x22>

f0100170 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100170:	55                   	push   %ebp
f0100171:	89 e5                	mov    %esp,%ebp
f0100173:	56                   	push   %esi
f0100174:	53                   	push   %ebx
f0100175:	e8 42 00 00 00       	call   f01001bc <__x86.get_pc_thunk.bx>
f010017a:	81 c3 ee 3e 01 00    	add    $0x13eee,%ebx
	va_list ap;

	va_start(ap, fmt);
f0100180:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel warning at %s:%d: ", file, line);
f0100183:	83 ec 04             	sub    $0x4,%esp
f0100186:	ff 75 0c             	pushl  0xc(%ebp)
f0100189:	ff 75 08             	pushl  0x8(%ebp)
f010018c:	8d 83 42 db fe ff    	lea    -0x124be(%ebx),%eax
f0100192:	50                   	push   %eax
f0100193:	e8 2e 09 00 00       	call   f0100ac6 <cprintf>
	vcprintf(fmt, ap);
f0100198:	83 c4 08             	add    $0x8,%esp
f010019b:	56                   	push   %esi
f010019c:	ff 75 10             	pushl  0x10(%ebp)
f010019f:	e8 eb 08 00 00       	call   f0100a8f <vcprintf>
	cprintf("\n");
f01001a4:	8d 83 66 db fe ff    	lea    -0x1249a(%ebx),%eax
f01001aa:	89 04 24             	mov    %eax,(%esp)
f01001ad:	e8 14 09 00 00       	call   f0100ac6 <cprintf>
	va_end(ap);
}
f01001b2:	83 c4 10             	add    $0x10,%esp
f01001b5:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01001b8:	5b                   	pop    %ebx
f01001b9:	5e                   	pop    %esi
f01001ba:	5d                   	pop    %ebp
f01001bb:	c3                   	ret    

f01001bc <__x86.get_pc_thunk.bx>:
f01001bc:	8b 1c 24             	mov    (%esp),%ebx
f01001bf:	c3                   	ret    

f01001c0 <serial_proc_data>:

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01001c0:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01001c5:	ec                   	in     (%dx),%al
static bool serial_exists;

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01001c6:	a8 01                	test   $0x1,%al
f01001c8:	74 0a                	je     f01001d4 <serial_proc_data+0x14>
f01001ca:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01001cf:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01001d0:	0f b6 c0             	movzbl %al,%eax
f01001d3:	c3                   	ret    
		return -1;
f01001d4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f01001d9:	c3                   	ret    

f01001da <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01001da:	55                   	push   %ebp
f01001db:	89 e5                	mov    %esp,%ebp
f01001dd:	56                   	push   %esi
f01001de:	53                   	push   %ebx
f01001df:	e8 d8 ff ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f01001e4:	81 c3 84 3e 01 00    	add    $0x13e84,%ebx
f01001ea:	89 c6                	mov    %eax,%esi
	int c;

	while ((c = (*proc)()) != -1) {
f01001ec:	ff d6                	call   *%esi
f01001ee:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001f1:	74 2a                	je     f010021d <cons_intr+0x43>
		if (c == 0)
f01001f3:	85 c0                	test   %eax,%eax
f01001f5:	74 f5                	je     f01001ec <cons_intr+0x12>
			continue;
		cons.buf[cons.wpos++] = c;
f01001f7:	8b 8b 3c 02 00 00    	mov    0x23c(%ebx),%ecx
f01001fd:	8d 51 01             	lea    0x1(%ecx),%edx
f0100200:	88 84 0b 38 00 00 00 	mov    %al,0x38(%ebx,%ecx,1)
		if (cons.wpos == CONSBUFSIZE)
f0100207:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.wpos = 0;
f010020d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100212:	0f 44 d0             	cmove  %eax,%edx
f0100215:	89 93 3c 02 00 00    	mov    %edx,0x23c(%ebx)
f010021b:	eb cf                	jmp    f01001ec <cons_intr+0x12>
	}
}
f010021d:	5b                   	pop    %ebx
f010021e:	5e                   	pop    %esi
f010021f:	5d                   	pop    %ebp
f0100220:	c3                   	ret    

f0100221 <kbd_proc_data>:
{
f0100221:	55                   	push   %ebp
f0100222:	89 e5                	mov    %esp,%ebp
f0100224:	56                   	push   %esi
f0100225:	53                   	push   %ebx
f0100226:	e8 91 ff ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f010022b:	81 c3 3d 3e 01 00    	add    $0x13e3d,%ebx
f0100231:	ba 64 00 00 00       	mov    $0x64,%edx
f0100236:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f0100237:	a8 01                	test   $0x1,%al
f0100239:	0f 84 fb 00 00 00    	je     f010033a <kbd_proc_data+0x119>
	if (stat & KBS_TERR)
f010023f:	a8 20                	test   $0x20,%al
f0100241:	0f 85 fa 00 00 00    	jne    f0100341 <kbd_proc_data+0x120>
f0100247:	ba 60 00 00 00       	mov    $0x60,%edx
f010024c:	ec                   	in     (%dx),%al
f010024d:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f010024f:	3c e0                	cmp    $0xe0,%al
f0100251:	74 64                	je     f01002b7 <kbd_proc_data+0x96>
	} else if (data & 0x80) {
f0100253:	84 c0                	test   %al,%al
f0100255:	78 75                	js     f01002cc <kbd_proc_data+0xab>
	} else if (shift & E0ESC) {
f0100257:	8b 8b 18 00 00 00    	mov    0x18(%ebx),%ecx
f010025d:	f6 c1 40             	test   $0x40,%cl
f0100260:	74 0e                	je     f0100270 <kbd_proc_data+0x4f>
		data |= 0x80;
f0100262:	83 c8 80             	or     $0xffffff80,%eax
f0100265:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100267:	83 e1 bf             	and    $0xffffffbf,%ecx
f010026a:	89 8b 18 00 00 00    	mov    %ecx,0x18(%ebx)
	shift |= shiftcode[data];
f0100270:	0f b6 d2             	movzbl %dl,%edx
f0100273:	0f b6 84 13 98 dc fe 	movzbl -0x12368(%ebx,%edx,1),%eax
f010027a:	ff 
f010027b:	0b 83 18 00 00 00    	or     0x18(%ebx),%eax
	shift ^= togglecode[data];
f0100281:	0f b6 8c 13 98 db fe 	movzbl -0x12468(%ebx,%edx,1),%ecx
f0100288:	ff 
f0100289:	31 c8                	xor    %ecx,%eax
f010028b:	89 83 18 00 00 00    	mov    %eax,0x18(%ebx)
	c = charcode[shift & (CTL | SHIFT)][data];
f0100291:	89 c1                	mov    %eax,%ecx
f0100293:	83 e1 03             	and    $0x3,%ecx
f0100296:	8b 8c 8b 98 ff ff ff 	mov    -0x68(%ebx,%ecx,4),%ecx
f010029d:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f01002a1:	0f b6 f2             	movzbl %dl,%esi
	if (shift & CAPSLOCK) {
f01002a4:	a8 08                	test   $0x8,%al
f01002a6:	74 65                	je     f010030d <kbd_proc_data+0xec>
		if ('a' <= c && c <= 'z')
f01002a8:	89 f2                	mov    %esi,%edx
f01002aa:	8d 4e 9f             	lea    -0x61(%esi),%ecx
f01002ad:	83 f9 19             	cmp    $0x19,%ecx
f01002b0:	77 4f                	ja     f0100301 <kbd_proc_data+0xe0>
			c += 'A' - 'a';
f01002b2:	83 ee 20             	sub    $0x20,%esi
f01002b5:	eb 0c                	jmp    f01002c3 <kbd_proc_data+0xa2>
		shift |= E0ESC;
f01002b7:	83 8b 18 00 00 00 40 	orl    $0x40,0x18(%ebx)
		return 0;
f01002be:	be 00 00 00 00       	mov    $0x0,%esi
}
f01002c3:	89 f0                	mov    %esi,%eax
f01002c5:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01002c8:	5b                   	pop    %ebx
f01002c9:	5e                   	pop    %esi
f01002ca:	5d                   	pop    %ebp
f01002cb:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f01002cc:	8b 8b 18 00 00 00    	mov    0x18(%ebx),%ecx
f01002d2:	89 ce                	mov    %ecx,%esi
f01002d4:	83 e6 40             	and    $0x40,%esi
f01002d7:	83 e0 7f             	and    $0x7f,%eax
f01002da:	85 f6                	test   %esi,%esi
f01002dc:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01002df:	0f b6 d2             	movzbl %dl,%edx
f01002e2:	0f b6 84 13 98 dc fe 	movzbl -0x12368(%ebx,%edx,1),%eax
f01002e9:	ff 
f01002ea:	83 c8 40             	or     $0x40,%eax
f01002ed:	0f b6 c0             	movzbl %al,%eax
f01002f0:	f7 d0                	not    %eax
f01002f2:	21 c8                	and    %ecx,%eax
f01002f4:	89 83 18 00 00 00    	mov    %eax,0x18(%ebx)
		return 0;
f01002fa:	be 00 00 00 00       	mov    $0x0,%esi
f01002ff:	eb c2                	jmp    f01002c3 <kbd_proc_data+0xa2>
		else if ('A' <= c && c <= 'Z')
f0100301:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f0100304:	8d 4e 20             	lea    0x20(%esi),%ecx
f0100307:	83 fa 1a             	cmp    $0x1a,%edx
f010030a:	0f 42 f1             	cmovb  %ecx,%esi
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f010030d:	f7 d0                	not    %eax
f010030f:	a8 06                	test   $0x6,%al
f0100311:	75 b0                	jne    f01002c3 <kbd_proc_data+0xa2>
f0100313:	81 fe e9 00 00 00    	cmp    $0xe9,%esi
f0100319:	75 a8                	jne    f01002c3 <kbd_proc_data+0xa2>
		cprintf("Rebooting!\n");
f010031b:	83 ec 0c             	sub    $0xc,%esp
f010031e:	8d 83 5c db fe ff    	lea    -0x124a4(%ebx),%eax
f0100324:	50                   	push   %eax
f0100325:	e8 9c 07 00 00       	call   f0100ac6 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010032a:	b8 03 00 00 00       	mov    $0x3,%eax
f010032f:	ba 92 00 00 00       	mov    $0x92,%edx
f0100334:	ee                   	out    %al,(%dx)
f0100335:	83 c4 10             	add    $0x10,%esp
f0100338:	eb 89                	jmp    f01002c3 <kbd_proc_data+0xa2>
		return -1;
f010033a:	be ff ff ff ff       	mov    $0xffffffff,%esi
f010033f:	eb 82                	jmp    f01002c3 <kbd_proc_data+0xa2>
		return -1;
f0100341:	be ff ff ff ff       	mov    $0xffffffff,%esi
f0100346:	e9 78 ff ff ff       	jmp    f01002c3 <kbd_proc_data+0xa2>

f010034b <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f010034b:	55                   	push   %ebp
f010034c:	89 e5                	mov    %esp,%ebp
f010034e:	57                   	push   %edi
f010034f:	56                   	push   %esi
f0100350:	53                   	push   %ebx
f0100351:	83 ec 1c             	sub    $0x1c,%esp
f0100354:	e8 63 fe ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100359:	81 c3 0f 3d 01 00    	add    $0x13d0f,%ebx
f010035f:	89 c7                	mov    %eax,%edi
	for (i = 0;
f0100361:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100366:	b9 84 00 00 00       	mov    $0x84,%ecx
f010036b:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100370:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100371:	a8 20                	test   $0x20,%al
f0100373:	75 13                	jne    f0100388 <cons_putc+0x3d>
f0100375:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f010037b:	7f 0b                	jg     f0100388 <cons_putc+0x3d>
f010037d:	89 ca                	mov    %ecx,%edx
f010037f:	ec                   	in     (%dx),%al
f0100380:	ec                   	in     (%dx),%al
f0100381:	ec                   	in     (%dx),%al
f0100382:	ec                   	in     (%dx),%al
	     i++)
f0100383:	83 c6 01             	add    $0x1,%esi
f0100386:	eb e3                	jmp    f010036b <cons_putc+0x20>
	outb(COM1 + COM_TX, c);
f0100388:	89 f8                	mov    %edi,%eax
f010038a:	88 45 e7             	mov    %al,-0x19(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010038d:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100392:	ee                   	out    %al,(%dx)
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100393:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100398:	b9 84 00 00 00       	mov    $0x84,%ecx
f010039d:	ba 79 03 00 00       	mov    $0x379,%edx
f01003a2:	ec                   	in     (%dx),%al
f01003a3:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f01003a9:	7f 0f                	jg     f01003ba <cons_putc+0x6f>
f01003ab:	84 c0                	test   %al,%al
f01003ad:	78 0b                	js     f01003ba <cons_putc+0x6f>
f01003af:	89 ca                	mov    %ecx,%edx
f01003b1:	ec                   	in     (%dx),%al
f01003b2:	ec                   	in     (%dx),%al
f01003b3:	ec                   	in     (%dx),%al
f01003b4:	ec                   	in     (%dx),%al
f01003b5:	83 c6 01             	add    $0x1,%esi
f01003b8:	eb e3                	jmp    f010039d <cons_putc+0x52>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003ba:	ba 78 03 00 00       	mov    $0x378,%edx
f01003bf:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f01003c3:	ee                   	out    %al,(%dx)
f01003c4:	ba 7a 03 00 00       	mov    $0x37a,%edx
f01003c9:	b8 0d 00 00 00       	mov    $0xd,%eax
f01003ce:	ee                   	out    %al,(%dx)
f01003cf:	b8 08 00 00 00       	mov    $0x8,%eax
f01003d4:	ee                   	out    %al,(%dx)
	if (!(c & ~0xFF))
f01003d5:	89 fa                	mov    %edi,%edx
f01003d7:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f01003dd:	89 f8                	mov    %edi,%eax
f01003df:	80 cc 07             	or     $0x7,%ah
f01003e2:	85 d2                	test   %edx,%edx
f01003e4:	0f 44 f8             	cmove  %eax,%edi
	switch (c & 0xff) {
f01003e7:	89 f8                	mov    %edi,%eax
f01003e9:	0f b6 c0             	movzbl %al,%eax
f01003ec:	83 f8 09             	cmp    $0x9,%eax
f01003ef:	0f 84 b4 00 00 00    	je     f01004a9 <cons_putc+0x15e>
f01003f5:	7e 74                	jle    f010046b <cons_putc+0x120>
f01003f7:	83 f8 0a             	cmp    $0xa,%eax
f01003fa:	0f 84 9c 00 00 00    	je     f010049c <cons_putc+0x151>
f0100400:	83 f8 0d             	cmp    $0xd,%eax
f0100403:	0f 85 d7 00 00 00    	jne    f01004e0 <cons_putc+0x195>
		crt_pos -= (crt_pos % CRT_COLS);
f0100409:	0f b7 83 40 02 00 00 	movzwl 0x240(%ebx),%eax
f0100410:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100416:	c1 e8 16             	shr    $0x16,%eax
f0100419:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010041c:	c1 e0 04             	shl    $0x4,%eax
f010041f:	66 89 83 40 02 00 00 	mov    %ax,0x240(%ebx)
	if (crt_pos >= CRT_SIZE) {
f0100426:	66 81 bb 40 02 00 00 	cmpw   $0x7cf,0x240(%ebx)
f010042d:	cf 07 
f010042f:	0f 87 ce 00 00 00    	ja     f0100503 <cons_putc+0x1b8>
	outb(addr_6845, 14);
f0100435:	8b 8b 48 02 00 00    	mov    0x248(%ebx),%ecx
f010043b:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100440:	89 ca                	mov    %ecx,%edx
f0100442:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100443:	0f b7 9b 40 02 00 00 	movzwl 0x240(%ebx),%ebx
f010044a:	8d 71 01             	lea    0x1(%ecx),%esi
f010044d:	89 d8                	mov    %ebx,%eax
f010044f:	66 c1 e8 08          	shr    $0x8,%ax
f0100453:	89 f2                	mov    %esi,%edx
f0100455:	ee                   	out    %al,(%dx)
f0100456:	b8 0f 00 00 00       	mov    $0xf,%eax
f010045b:	89 ca                	mov    %ecx,%edx
f010045d:	ee                   	out    %al,(%dx)
f010045e:	89 d8                	mov    %ebx,%eax
f0100460:	89 f2                	mov    %esi,%edx
f0100462:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100463:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100466:	5b                   	pop    %ebx
f0100467:	5e                   	pop    %esi
f0100468:	5f                   	pop    %edi
f0100469:	5d                   	pop    %ebp
f010046a:	c3                   	ret    
	switch (c & 0xff) {
f010046b:	83 f8 08             	cmp    $0x8,%eax
f010046e:	75 70                	jne    f01004e0 <cons_putc+0x195>
		if (crt_pos > 0) {
f0100470:	0f b7 83 40 02 00 00 	movzwl 0x240(%ebx),%eax
f0100477:	66 85 c0             	test   %ax,%ax
f010047a:	74 b9                	je     f0100435 <cons_putc+0xea>
			crt_pos--;
f010047c:	83 e8 01             	sub    $0x1,%eax
f010047f:	66 89 83 40 02 00 00 	mov    %ax,0x240(%ebx)
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100486:	0f b7 c0             	movzwl %ax,%eax
f0100489:	89 fa                	mov    %edi,%edx
f010048b:	b2 00                	mov    $0x0,%dl
f010048d:	83 ca 20             	or     $0x20,%edx
f0100490:	8b 8b 44 02 00 00    	mov    0x244(%ebx),%ecx
f0100496:	66 89 14 41          	mov    %dx,(%ecx,%eax,2)
f010049a:	eb 8a                	jmp    f0100426 <cons_putc+0xdb>
		crt_pos += CRT_COLS;
f010049c:	66 83 83 40 02 00 00 	addw   $0x50,0x240(%ebx)
f01004a3:	50 
f01004a4:	e9 60 ff ff ff       	jmp    f0100409 <cons_putc+0xbe>
		cons_putc(' ');
f01004a9:	b8 20 00 00 00       	mov    $0x20,%eax
f01004ae:	e8 98 fe ff ff       	call   f010034b <cons_putc>
		cons_putc(' ');
f01004b3:	b8 20 00 00 00       	mov    $0x20,%eax
f01004b8:	e8 8e fe ff ff       	call   f010034b <cons_putc>
		cons_putc(' ');
f01004bd:	b8 20 00 00 00       	mov    $0x20,%eax
f01004c2:	e8 84 fe ff ff       	call   f010034b <cons_putc>
		cons_putc(' ');
f01004c7:	b8 20 00 00 00       	mov    $0x20,%eax
f01004cc:	e8 7a fe ff ff       	call   f010034b <cons_putc>
		cons_putc(' ');
f01004d1:	b8 20 00 00 00       	mov    $0x20,%eax
f01004d6:	e8 70 fe ff ff       	call   f010034b <cons_putc>
f01004db:	e9 46 ff ff ff       	jmp    f0100426 <cons_putc+0xdb>
		crt_buf[crt_pos++] = c;		/* write the character */
f01004e0:	0f b7 83 40 02 00 00 	movzwl 0x240(%ebx),%eax
f01004e7:	8d 50 01             	lea    0x1(%eax),%edx
f01004ea:	66 89 93 40 02 00 00 	mov    %dx,0x240(%ebx)
f01004f1:	0f b7 c0             	movzwl %ax,%eax
f01004f4:	8b 93 44 02 00 00    	mov    0x244(%ebx),%edx
f01004fa:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01004fe:	e9 23 ff ff ff       	jmp    f0100426 <cons_putc+0xdb>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100503:	8b 83 44 02 00 00    	mov    0x244(%ebx),%eax
f0100509:	83 ec 04             	sub    $0x4,%esp
f010050c:	68 00 0f 00 00       	push   $0xf00
f0100511:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100517:	52                   	push   %edx
f0100518:	50                   	push   %eax
f0100519:	e8 15 12 00 00       	call   f0101733 <memmove>
			crt_buf[i] = 0x0700 | ' ';
f010051e:	8b 93 44 02 00 00    	mov    0x244(%ebx),%edx
f0100524:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f010052a:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100530:	83 c4 10             	add    $0x10,%esp
f0100533:	66 c7 00 20 07       	movw   $0x720,(%eax)
f0100538:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010053b:	39 d0                	cmp    %edx,%eax
f010053d:	75 f4                	jne    f0100533 <cons_putc+0x1e8>
		crt_pos -= CRT_COLS;
f010053f:	66 83 ab 40 02 00 00 	subw   $0x50,0x240(%ebx)
f0100546:	50 
f0100547:	e9 e9 fe ff ff       	jmp    f0100435 <cons_putc+0xea>

f010054c <serial_intr>:
{
f010054c:	e8 dc 01 00 00       	call   f010072d <__x86.get_pc_thunk.ax>
f0100551:	05 17 3b 01 00       	add    $0x13b17,%eax
	if (serial_exists)
f0100556:	80 b8 4c 02 00 00 00 	cmpb   $0x0,0x24c(%eax)
f010055d:	75 01                	jne    f0100560 <serial_intr+0x14>
f010055f:	c3                   	ret    
{
f0100560:	55                   	push   %ebp
f0100561:	89 e5                	mov    %esp,%ebp
f0100563:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f0100566:	8d 80 58 c1 fe ff    	lea    -0x13ea8(%eax),%eax
f010056c:	e8 69 fc ff ff       	call   f01001da <cons_intr>
}
f0100571:	c9                   	leave  
f0100572:	c3                   	ret    

f0100573 <kbd_intr>:
{
f0100573:	55                   	push   %ebp
f0100574:	89 e5                	mov    %esp,%ebp
f0100576:	83 ec 08             	sub    $0x8,%esp
f0100579:	e8 af 01 00 00       	call   f010072d <__x86.get_pc_thunk.ax>
f010057e:	05 ea 3a 01 00       	add    $0x13aea,%eax
	cons_intr(kbd_proc_data);
f0100583:	8d 80 b9 c1 fe ff    	lea    -0x13e47(%eax),%eax
f0100589:	e8 4c fc ff ff       	call   f01001da <cons_intr>
}
f010058e:	c9                   	leave  
f010058f:	c3                   	ret    

f0100590 <cons_getc>:
{
f0100590:	55                   	push   %ebp
f0100591:	89 e5                	mov    %esp,%ebp
f0100593:	53                   	push   %ebx
f0100594:	83 ec 04             	sub    $0x4,%esp
f0100597:	e8 20 fc ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f010059c:	81 c3 cc 3a 01 00    	add    $0x13acc,%ebx
	serial_intr();
f01005a2:	e8 a5 ff ff ff       	call   f010054c <serial_intr>
	kbd_intr();
f01005a7:	e8 c7 ff ff ff       	call   f0100573 <kbd_intr>
	if (cons.rpos != cons.wpos) {
f01005ac:	8b 8b 38 02 00 00    	mov    0x238(%ebx),%ecx
	return 0;
f01005b2:	b8 00 00 00 00       	mov    $0x0,%eax
	if (cons.rpos != cons.wpos) {
f01005b7:	3b 8b 3c 02 00 00    	cmp    0x23c(%ebx),%ecx
f01005bd:	74 1f                	je     f01005de <cons_getc+0x4e>
		c = cons.buf[cons.rpos++];
f01005bf:	8d 51 01             	lea    0x1(%ecx),%edx
f01005c2:	0f b6 84 0b 38 00 00 	movzbl 0x38(%ebx,%ecx,1),%eax
f01005c9:	00 
		if (cons.rpos == CONSBUFSIZE)
f01005ca:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.rpos = 0;
f01005d0:	b9 00 00 00 00       	mov    $0x0,%ecx
f01005d5:	0f 44 d1             	cmove  %ecx,%edx
f01005d8:	89 93 38 02 00 00    	mov    %edx,0x238(%ebx)
}
f01005de:	83 c4 04             	add    $0x4,%esp
f01005e1:	5b                   	pop    %ebx
f01005e2:	5d                   	pop    %ebp
f01005e3:	c3                   	ret    

f01005e4 <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f01005e4:	55                   	push   %ebp
f01005e5:	89 e5                	mov    %esp,%ebp
f01005e7:	57                   	push   %edi
f01005e8:	56                   	push   %esi
f01005e9:	53                   	push   %ebx
f01005ea:	83 ec 1c             	sub    $0x1c,%esp
f01005ed:	e8 ca fb ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f01005f2:	81 c3 76 3a 01 00    	add    $0x13a76,%ebx
	was = *cp;
f01005f8:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f01005ff:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100606:	5a a5 
	if (*cp != 0xA55A) {
f0100608:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010060f:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100613:	0f 84 bc 00 00 00    	je     f01006d5 <cons_init+0xf1>
		addr_6845 = MONO_BASE;
f0100619:	c7 83 48 02 00 00 b4 	movl   $0x3b4,0x248(%ebx)
f0100620:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100623:	c7 45 e4 00 00 0b f0 	movl   $0xf00b0000,-0x1c(%ebp)
	outb(addr_6845, 14);
f010062a:	8b bb 48 02 00 00    	mov    0x248(%ebx),%edi
f0100630:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100635:	89 fa                	mov    %edi,%edx
f0100637:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100638:	8d 4f 01             	lea    0x1(%edi),%ecx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010063b:	89 ca                	mov    %ecx,%edx
f010063d:	ec                   	in     (%dx),%al
f010063e:	0f b6 f0             	movzbl %al,%esi
f0100641:	c1 e6 08             	shl    $0x8,%esi
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100644:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100649:	89 fa                	mov    %edi,%edx
f010064b:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010064c:	89 ca                	mov    %ecx,%edx
f010064e:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f010064f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100652:	89 bb 44 02 00 00    	mov    %edi,0x244(%ebx)
	pos |= inb(addr_6845 + 1);
f0100658:	0f b6 c0             	movzbl %al,%eax
f010065b:	09 c6                	or     %eax,%esi
	crt_pos = pos;
f010065d:	66 89 b3 40 02 00 00 	mov    %si,0x240(%ebx)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100664:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100669:	89 c8                	mov    %ecx,%eax
f010066b:	ba fa 03 00 00       	mov    $0x3fa,%edx
f0100670:	ee                   	out    %al,(%dx)
f0100671:	bf fb 03 00 00       	mov    $0x3fb,%edi
f0100676:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f010067b:	89 fa                	mov    %edi,%edx
f010067d:	ee                   	out    %al,(%dx)
f010067e:	b8 0c 00 00 00       	mov    $0xc,%eax
f0100683:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100688:	ee                   	out    %al,(%dx)
f0100689:	be f9 03 00 00       	mov    $0x3f9,%esi
f010068e:	89 c8                	mov    %ecx,%eax
f0100690:	89 f2                	mov    %esi,%edx
f0100692:	ee                   	out    %al,(%dx)
f0100693:	b8 03 00 00 00       	mov    $0x3,%eax
f0100698:	89 fa                	mov    %edi,%edx
f010069a:	ee                   	out    %al,(%dx)
f010069b:	ba fc 03 00 00       	mov    $0x3fc,%edx
f01006a0:	89 c8                	mov    %ecx,%eax
f01006a2:	ee                   	out    %al,(%dx)
f01006a3:	b8 01 00 00 00       	mov    $0x1,%eax
f01006a8:	89 f2                	mov    %esi,%edx
f01006aa:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006ab:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01006b0:	ec                   	in     (%dx),%al
f01006b1:	89 c1                	mov    %eax,%ecx
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01006b3:	3c ff                	cmp    $0xff,%al
f01006b5:	0f 95 83 4c 02 00 00 	setne  0x24c(%ebx)
f01006bc:	ba fa 03 00 00       	mov    $0x3fa,%edx
f01006c1:	ec                   	in     (%dx),%al
f01006c2:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01006c7:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01006c8:	80 f9 ff             	cmp    $0xff,%cl
f01006cb:	74 25                	je     f01006f2 <cons_init+0x10e>
		cprintf("Serial port does not exist!\n");
}
f01006cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01006d0:	5b                   	pop    %ebx
f01006d1:	5e                   	pop    %esi
f01006d2:	5f                   	pop    %edi
f01006d3:	5d                   	pop    %ebp
f01006d4:	c3                   	ret    
		*cp = was;
f01006d5:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01006dc:	c7 83 48 02 00 00 d4 	movl   $0x3d4,0x248(%ebx)
f01006e3:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01006e6:	c7 45 e4 00 80 0b f0 	movl   $0xf00b8000,-0x1c(%ebp)
f01006ed:	e9 38 ff ff ff       	jmp    f010062a <cons_init+0x46>
		cprintf("Serial port does not exist!\n");
f01006f2:	83 ec 0c             	sub    $0xc,%esp
f01006f5:	8d 83 68 db fe ff    	lea    -0x12498(%ebx),%eax
f01006fb:	50                   	push   %eax
f01006fc:	e8 c5 03 00 00       	call   f0100ac6 <cprintf>
f0100701:	83 c4 10             	add    $0x10,%esp
}
f0100704:	eb c7                	jmp    f01006cd <cons_init+0xe9>

f0100706 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100706:	55                   	push   %ebp
f0100707:	89 e5                	mov    %esp,%ebp
f0100709:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f010070c:	8b 45 08             	mov    0x8(%ebp),%eax
f010070f:	e8 37 fc ff ff       	call   f010034b <cons_putc>
}
f0100714:	c9                   	leave  
f0100715:	c3                   	ret    

f0100716 <getchar>:

int
getchar(void)
{
f0100716:	55                   	push   %ebp
f0100717:	89 e5                	mov    %esp,%ebp
f0100719:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f010071c:	e8 6f fe ff ff       	call   f0100590 <cons_getc>
f0100721:	85 c0                	test   %eax,%eax
f0100723:	74 f7                	je     f010071c <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100725:	c9                   	leave  
f0100726:	c3                   	ret    

f0100727 <iscons>:
int
iscons(int fdnum)
{
	// used by readline
	return 1;
}
f0100727:	b8 01 00 00 00       	mov    $0x1,%eax
f010072c:	c3                   	ret    

f010072d <__x86.get_pc_thunk.ax>:
f010072d:	8b 04 24             	mov    (%esp),%eax
f0100730:	c3                   	ret    

f0100731 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100731:	55                   	push   %ebp
f0100732:	89 e5                	mov    %esp,%ebp
f0100734:	56                   	push   %esi
f0100735:	53                   	push   %ebx
f0100736:	e8 81 fa ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f010073b:	81 c3 2d 39 01 00    	add    $0x1392d,%ebx
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100741:	83 ec 04             	sub    $0x4,%esp
f0100744:	8d 83 98 dd fe ff    	lea    -0x12268(%ebx),%eax
f010074a:	50                   	push   %eax
f010074b:	8d 83 b6 dd fe ff    	lea    -0x1224a(%ebx),%eax
f0100751:	50                   	push   %eax
f0100752:	8d b3 bb dd fe ff    	lea    -0x12245(%ebx),%esi
f0100758:	56                   	push   %esi
f0100759:	e8 68 03 00 00       	call   f0100ac6 <cprintf>
f010075e:	83 c4 0c             	add    $0xc,%esp
f0100761:	8d 83 68 de fe ff    	lea    -0x12198(%ebx),%eax
f0100767:	50                   	push   %eax
f0100768:	8d 83 c4 dd fe ff    	lea    -0x1223c(%ebx),%eax
f010076e:	50                   	push   %eax
f010076f:	56                   	push   %esi
f0100770:	e8 51 03 00 00       	call   f0100ac6 <cprintf>
f0100775:	83 c4 0c             	add    $0xc,%esp
f0100778:	8d 83 cd dd fe ff    	lea    -0x12233(%ebx),%eax
f010077e:	50                   	push   %eax
f010077f:	8d 83 e4 dd fe ff    	lea    -0x1221c(%ebx),%eax
f0100785:	50                   	push   %eax
f0100786:	56                   	push   %esi
f0100787:	e8 3a 03 00 00       	call   f0100ac6 <cprintf>
	return 0;
}
f010078c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100791:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100794:	5b                   	pop    %ebx
f0100795:	5e                   	pop    %esi
f0100796:	5d                   	pop    %ebp
f0100797:	c3                   	ret    

f0100798 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100798:	55                   	push   %ebp
f0100799:	89 e5                	mov    %esp,%ebp
f010079b:	57                   	push   %edi
f010079c:	56                   	push   %esi
f010079d:	53                   	push   %ebx
f010079e:	83 ec 18             	sub    $0x18,%esp
f01007a1:	e8 16 fa ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f01007a6:	81 c3 c2 38 01 00    	add    $0x138c2,%ebx
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007ac:	8d 83 ee dd fe ff    	lea    -0x12212(%ebx),%eax
f01007b2:	50                   	push   %eax
f01007b3:	e8 0e 03 00 00       	call   f0100ac6 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01007b8:	83 c4 08             	add    $0x8,%esp
f01007bb:	ff b3 f8 ff ff ff    	pushl  -0x8(%ebx)
f01007c1:	8d 83 90 de fe ff    	lea    -0x12170(%ebx),%eax
f01007c7:	50                   	push   %eax
f01007c8:	e8 f9 02 00 00       	call   f0100ac6 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01007cd:	83 c4 0c             	add    $0xc,%esp
f01007d0:	c7 c7 0c 00 10 f0    	mov    $0xf010000c,%edi
f01007d6:	8d 87 00 00 00 10    	lea    0x10000000(%edi),%eax
f01007dc:	50                   	push   %eax
f01007dd:	57                   	push   %edi
f01007de:	8d 83 b8 de fe ff    	lea    -0x12148(%ebx),%eax
f01007e4:	50                   	push   %eax
f01007e5:	e8 dc 02 00 00       	call   f0100ac6 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01007ea:	83 c4 0c             	add    $0xc,%esp
f01007ed:	c7 c0 2f 1b 10 f0    	mov    $0xf0101b2f,%eax
f01007f3:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01007f9:	52                   	push   %edx
f01007fa:	50                   	push   %eax
f01007fb:	8d 83 dc de fe ff    	lea    -0x12124(%ebx),%eax
f0100801:	50                   	push   %eax
f0100802:	e8 bf 02 00 00       	call   f0100ac6 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100807:	83 c4 0c             	add    $0xc,%esp
f010080a:	c7 c0 80 40 11 f0    	mov    $0xf0114080,%eax
f0100810:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0100816:	52                   	push   %edx
f0100817:	50                   	push   %eax
f0100818:	8d 83 00 df fe ff    	lea    -0x12100(%ebx),%eax
f010081e:	50                   	push   %eax
f010081f:	e8 a2 02 00 00       	call   f0100ac6 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100824:	83 c4 0c             	add    $0xc,%esp
f0100827:	c7 c6 c0 46 11 f0    	mov    $0xf01146c0,%esi
f010082d:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f0100833:	50                   	push   %eax
f0100834:	56                   	push   %esi
f0100835:	8d 83 24 df fe ff    	lea    -0x120dc(%ebx),%eax
f010083b:	50                   	push   %eax
f010083c:	e8 85 02 00 00       	call   f0100ac6 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100841:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f0100844:	29 fe                	sub    %edi,%esi
f0100846:	81 c6 ff 03 00 00    	add    $0x3ff,%esi
	cprintf("Kernel executable memory footprint: %dKB\n",
f010084c:	c1 fe 0a             	sar    $0xa,%esi
f010084f:	56                   	push   %esi
f0100850:	8d 83 48 df fe ff    	lea    -0x120b8(%ebx),%eax
f0100856:	50                   	push   %eax
f0100857:	e8 6a 02 00 00       	call   f0100ac6 <cprintf>
	return 0;
}
f010085c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100861:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100864:	5b                   	pop    %ebx
f0100865:	5e                   	pop    %esi
f0100866:	5f                   	pop    %edi
f0100867:	5d                   	pop    %ebp
f0100868:	c3                   	ret    

f0100869 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100869:	55                   	push   %ebp
f010086a:	89 e5                	mov    %esp,%ebp
f010086c:	57                   	push   %edi
f010086d:	56                   	push   %esi
f010086e:	53                   	push   %ebx
f010086f:	83 ec 48             	sub    $0x48,%esp
f0100872:	e8 45 f9 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100877:	81 c3 f1 37 01 00    	add    $0x137f1,%ebx

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f010087d:	89 ee                	mov    %ebp,%esi
	// Your code here.
	uint32_t ebp, *ptr_ebp;
	ebp = read_ebp();
	cprintf("Stack backtrace:\n");
f010087f:	8d 83 07 de fe ff    	lea    -0x121f9(%ebx),%eax
f0100885:	50                   	push   %eax
f0100886:	e8 3b 02 00 00       	call   f0100ac6 <cprintf>
	while (ebp != 0) {
f010088b:	83 c4 10             	add    $0x10,%esp
		ptr_ebp = (uint32_t *)ebp;
		cprintf(" ebp %x  eip %x  args %08x %08x %08x %08x %08x\n", 
f010088e:	8d 83 74 df fe ff    	lea    -0x1208c(%ebx),%eax
f0100894:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        		ebp, ptr_ebp[1], ptr_ebp[2], ptr_ebp[3], ptr_ebp[4], ptr_ebp[5], ptr_ebp[6]);
		struct Eipdebuginfo info;
		if (debuginfo_eip(ptr_ebp[1], &info) == 0) {
f0100897:	8d 45 d0             	lea    -0x30(%ebp),%eax
f010089a:	89 45 c0             	mov    %eax,-0x40(%ebp)
	while (ebp != 0) {
f010089d:	eb 27                	jmp    f01008c6 <mon_backtrace+0x5d>
			uint32_t fn_offset = ptr_ebp[1] - info.eip_fn_addr; 
			cprintf(" \t%s:%d: %.*s+%d\n", info.eip_file, info.eip_line\
f010089f:	83 ec 08             	sub    $0x8,%esp
			uint32_t fn_offset = ptr_ebp[1] - info.eip_fn_addr; 
f01008a2:	8b 46 04             	mov    0x4(%esi),%eax
f01008a5:	2b 45 e0             	sub    -0x20(%ebp),%eax
			cprintf(" \t%s:%d: %.*s+%d\n", info.eip_file, info.eip_line\
f01008a8:	50                   	push   %eax
f01008a9:	ff 75 d8             	pushl  -0x28(%ebp)
f01008ac:	ff 75 dc             	pushl  -0x24(%ebp)
f01008af:	ff 75 d4             	pushl  -0x2c(%ebp)
f01008b2:	ff 75 d0             	pushl  -0x30(%ebp)
f01008b5:	8d 83 19 de fe ff    	lea    -0x121e7(%ebx),%eax
f01008bb:	50                   	push   %eax
f01008bc:	e8 05 02 00 00       	call   f0100ac6 <cprintf>
f01008c1:	83 c4 20             	add    $0x20,%esp
							, info.eip_fn_namelen, info.eip_fn_name, fn_offset);
		}
		ebp = *ptr_ebp;
f01008c4:	8b 37                	mov    (%edi),%esi
	while (ebp != 0) {
f01008c6:	85 f6                	test   %esi,%esi
f01008c8:	74 34                	je     f01008fe <mon_backtrace+0x95>
		ptr_ebp = (uint32_t *)ebp;
f01008ca:	89 f7                	mov    %esi,%edi
		cprintf(" ebp %x  eip %x  args %08x %08x %08x %08x %08x\n", 
f01008cc:	ff 76 18             	pushl  0x18(%esi)
f01008cf:	ff 76 14             	pushl  0x14(%esi)
f01008d2:	ff 76 10             	pushl  0x10(%esi)
f01008d5:	ff 76 0c             	pushl  0xc(%esi)
f01008d8:	ff 76 08             	pushl  0x8(%esi)
f01008db:	ff 76 04             	pushl  0x4(%esi)
f01008de:	56                   	push   %esi
f01008df:	ff 75 c4             	pushl  -0x3c(%ebp)
f01008e2:	e8 df 01 00 00       	call   f0100ac6 <cprintf>
		if (debuginfo_eip(ptr_ebp[1], &info) == 0) {
f01008e7:	83 c4 18             	add    $0x18,%esp
f01008ea:	ff 75 c0             	pushl  -0x40(%ebp)
f01008ed:	ff 76 04             	pushl  0x4(%esi)
f01008f0:	e8 d5 02 00 00       	call   f0100bca <debuginfo_eip>
f01008f5:	83 c4 10             	add    $0x10,%esp
f01008f8:	85 c0                	test   %eax,%eax
f01008fa:	75 c8                	jne    f01008c4 <mon_backtrace+0x5b>
f01008fc:	eb a1                	jmp    f010089f <mon_backtrace+0x36>
	}
	return 0;
}
f01008fe:	b8 00 00 00 00       	mov    $0x0,%eax
f0100903:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100906:	5b                   	pop    %ebx
f0100907:	5e                   	pop    %esi
f0100908:	5f                   	pop    %edi
f0100909:	5d                   	pop    %ebp
f010090a:	c3                   	ret    

f010090b <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f010090b:	55                   	push   %ebp
f010090c:	89 e5                	mov    %esp,%ebp
f010090e:	57                   	push   %edi
f010090f:	56                   	push   %esi
f0100910:	53                   	push   %ebx
f0100911:	83 ec 68             	sub    $0x68,%esp
f0100914:	e8 a3 f8 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100919:	81 c3 4f 37 01 00    	add    $0x1374f,%ebx
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f010091f:	8d 83 a4 df fe ff    	lea    -0x1205c(%ebx),%eax
f0100925:	50                   	push   %eax
f0100926:	e8 9b 01 00 00       	call   f0100ac6 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f010092b:	8d 83 c8 df fe ff    	lea    -0x12038(%ebx),%eax
f0100931:	89 04 24             	mov    %eax,(%esp)
f0100934:	e8 8d 01 00 00       	call   f0100ac6 <cprintf>
f0100939:	83 c4 10             	add    $0x10,%esp
		while (*buf && strchr(WHITESPACE, *buf))
f010093c:	8d 83 2f de fe ff    	lea    -0x121d1(%ebx),%eax
f0100942:	89 45 a0             	mov    %eax,-0x60(%ebp)
f0100945:	e9 d1 00 00 00       	jmp    f0100a1b <monitor+0x110>
f010094a:	83 ec 08             	sub    $0x8,%esp
f010094d:	0f be c0             	movsbl %al,%eax
f0100950:	50                   	push   %eax
f0100951:	ff 75 a0             	pushl  -0x60(%ebp)
f0100954:	e8 55 0d 00 00       	call   f01016ae <strchr>
f0100959:	83 c4 10             	add    $0x10,%esp
f010095c:	85 c0                	test   %eax,%eax
f010095e:	74 6d                	je     f01009cd <monitor+0xc2>
			*buf++ = 0;
f0100960:	c6 06 00             	movb   $0x0,(%esi)
f0100963:	89 7d a4             	mov    %edi,-0x5c(%ebp)
f0100966:	8d 76 01             	lea    0x1(%esi),%esi
f0100969:	8b 7d a4             	mov    -0x5c(%ebp),%edi
		while (*buf && strchr(WHITESPACE, *buf))
f010096c:	0f b6 06             	movzbl (%esi),%eax
f010096f:	84 c0                	test   %al,%al
f0100971:	75 d7                	jne    f010094a <monitor+0x3f>
	argv[argc] = 0;
f0100973:	c7 44 bd a8 00 00 00 	movl   $0x0,-0x58(%ebp,%edi,4)
f010097a:	00 
	if (argc == 0)
f010097b:	85 ff                	test   %edi,%edi
f010097d:	0f 84 98 00 00 00    	je     f0100a1b <monitor+0x110>
f0100983:	8d b3 b8 ff ff ff    	lea    -0x48(%ebx),%esi
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100989:	b8 00 00 00 00       	mov    $0x0,%eax
f010098e:	89 7d a4             	mov    %edi,-0x5c(%ebp)
f0100991:	89 c7                	mov    %eax,%edi
		if (strcmp(argv[0], commands[i].name) == 0)
f0100993:	83 ec 08             	sub    $0x8,%esp
f0100996:	ff 36                	pushl  (%esi)
f0100998:	ff 75 a8             	pushl  -0x58(%ebp)
f010099b:	e8 b0 0c 00 00       	call   f0101650 <strcmp>
f01009a0:	83 c4 10             	add    $0x10,%esp
f01009a3:	85 c0                	test   %eax,%eax
f01009a5:	0f 84 99 00 00 00    	je     f0100a44 <monitor+0x139>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f01009ab:	83 c7 01             	add    $0x1,%edi
f01009ae:	83 c6 0c             	add    $0xc,%esi
f01009b1:	83 ff 03             	cmp    $0x3,%edi
f01009b4:	75 dd                	jne    f0100993 <monitor+0x88>
	cprintf("Unknown command '%s'\n", argv[0]);
f01009b6:	83 ec 08             	sub    $0x8,%esp
f01009b9:	ff 75 a8             	pushl  -0x58(%ebp)
f01009bc:	8d 83 51 de fe ff    	lea    -0x121af(%ebx),%eax
f01009c2:	50                   	push   %eax
f01009c3:	e8 fe 00 00 00       	call   f0100ac6 <cprintf>
f01009c8:	83 c4 10             	add    $0x10,%esp
f01009cb:	eb 4e                	jmp    f0100a1b <monitor+0x110>
		if (*buf == 0)
f01009cd:	80 3e 00             	cmpb   $0x0,(%esi)
f01009d0:	74 a1                	je     f0100973 <monitor+0x68>
		if (argc == MAXARGS-1) {
f01009d2:	83 ff 0f             	cmp    $0xf,%edi
f01009d5:	74 30                	je     f0100a07 <monitor+0xfc>
		argv[argc++] = buf;
f01009d7:	8d 47 01             	lea    0x1(%edi),%eax
f01009da:	89 45 a4             	mov    %eax,-0x5c(%ebp)
f01009dd:	89 74 bd a8          	mov    %esi,-0x58(%ebp,%edi,4)
		while (*buf && !strchr(WHITESPACE, *buf))
f01009e1:	0f b6 06             	movzbl (%esi),%eax
f01009e4:	84 c0                	test   %al,%al
f01009e6:	74 81                	je     f0100969 <monitor+0x5e>
f01009e8:	83 ec 08             	sub    $0x8,%esp
f01009eb:	0f be c0             	movsbl %al,%eax
f01009ee:	50                   	push   %eax
f01009ef:	ff 75 a0             	pushl  -0x60(%ebp)
f01009f2:	e8 b7 0c 00 00       	call   f01016ae <strchr>
f01009f7:	83 c4 10             	add    $0x10,%esp
f01009fa:	85 c0                	test   %eax,%eax
f01009fc:	0f 85 67 ff ff ff    	jne    f0100969 <monitor+0x5e>
			buf++;
f0100a02:	83 c6 01             	add    $0x1,%esi
f0100a05:	eb da                	jmp    f01009e1 <monitor+0xd6>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100a07:	83 ec 08             	sub    $0x8,%esp
f0100a0a:	6a 10                	push   $0x10
f0100a0c:	8d 83 34 de fe ff    	lea    -0x121cc(%ebx),%eax
f0100a12:	50                   	push   %eax
f0100a13:	e8 ae 00 00 00       	call   f0100ac6 <cprintf>
f0100a18:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f0100a1b:	8d bb 2b de fe ff    	lea    -0x121d5(%ebx),%edi
f0100a21:	83 ec 0c             	sub    $0xc,%esp
f0100a24:	57                   	push   %edi
f0100a25:	e8 45 0a 00 00       	call   f010146f <readline>
		if (buf != NULL)
f0100a2a:	83 c4 10             	add    $0x10,%esp
f0100a2d:	85 c0                	test   %eax,%eax
f0100a2f:	74 f0                	je     f0100a21 <monitor+0x116>
f0100a31:	89 c6                	mov    %eax,%esi
	argv[argc] = 0;
f0100a33:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f0100a3a:	bf 00 00 00 00       	mov    $0x0,%edi
f0100a3f:	e9 28 ff ff ff       	jmp    f010096c <monitor+0x61>
f0100a44:	89 f8                	mov    %edi,%eax
f0100a46:	8b 7d a4             	mov    -0x5c(%ebp),%edi
			return commands[i].func(argc, argv, tf);
f0100a49:	83 ec 04             	sub    $0x4,%esp
f0100a4c:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100a4f:	ff 75 08             	pushl  0x8(%ebp)
f0100a52:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100a55:	52                   	push   %edx
f0100a56:	57                   	push   %edi
f0100a57:	ff 94 83 c0 ff ff ff 	call   *-0x40(%ebx,%eax,4)
			if (runcmd(buf, tf) < 0)
f0100a5e:	83 c4 10             	add    $0x10,%esp
f0100a61:	85 c0                	test   %eax,%eax
f0100a63:	79 b6                	jns    f0100a1b <monitor+0x110>
				break;
	}
}
f0100a65:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100a68:	5b                   	pop    %ebx
f0100a69:	5e                   	pop    %esi
f0100a6a:	5f                   	pop    %edi
f0100a6b:	5d                   	pop    %ebp
f0100a6c:	c3                   	ret    

f0100a6d <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0100a6d:	55                   	push   %ebp
f0100a6e:	89 e5                	mov    %esp,%ebp
f0100a70:	53                   	push   %ebx
f0100a71:	83 ec 10             	sub    $0x10,%esp
f0100a74:	e8 43 f7 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100a79:	81 c3 ef 35 01 00    	add    $0x135ef,%ebx
	cputchar(ch);
f0100a7f:	ff 75 08             	pushl  0x8(%ebp)
f0100a82:	e8 7f fc ff ff       	call   f0100706 <cputchar>
	*cnt++;
}
f0100a87:	83 c4 10             	add    $0x10,%esp
f0100a8a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100a8d:	c9                   	leave  
f0100a8e:	c3                   	ret    

f0100a8f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0100a8f:	55                   	push   %ebp
f0100a90:	89 e5                	mov    %esp,%ebp
f0100a92:	53                   	push   %ebx
f0100a93:	83 ec 14             	sub    $0x14,%esp
f0100a96:	e8 21 f7 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100a9b:	81 c3 cd 35 01 00    	add    $0x135cd,%ebx
	int cnt = 0;
f0100aa1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0100aa8:	ff 75 0c             	pushl  0xc(%ebp)
f0100aab:	ff 75 08             	pushl  0x8(%ebp)
f0100aae:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100ab1:	50                   	push   %eax
f0100ab2:	8d 83 05 ca fe ff    	lea    -0x135fb(%ebx),%eax
f0100ab8:	50                   	push   %eax
f0100ab9:	e8 96 04 00 00       	call   f0100f54 <vprintfmt>
	return cnt;
}
f0100abe:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100ac1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100ac4:	c9                   	leave  
f0100ac5:	c3                   	ret    

f0100ac6 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0100ac6:	55                   	push   %ebp
f0100ac7:	89 e5                	mov    %esp,%ebp
f0100ac9:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0100acc:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0100acf:	50                   	push   %eax
f0100ad0:	ff 75 08             	pushl  0x8(%ebp)
f0100ad3:	e8 b7 ff ff ff       	call   f0100a8f <vcprintf>
	va_end(ap);

	return cnt;
}
f0100ad8:	c9                   	leave  
f0100ad9:	c3                   	ret    

f0100ada <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0100ada:	55                   	push   %ebp
f0100adb:	89 e5                	mov    %esp,%ebp
f0100add:	57                   	push   %edi
f0100ade:	56                   	push   %esi
f0100adf:	53                   	push   %ebx
f0100ae0:	83 ec 14             	sub    $0x14,%esp
f0100ae3:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0100ae6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100ae9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100aec:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0100aef:	8b 1a                	mov    (%edx),%ebx
f0100af1:	8b 01                	mov    (%ecx),%eax
f0100af3:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100af6:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0100afd:	eb 23                	jmp    f0100b22 <stab_binsearch+0x48>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0100aff:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0100b02:	eb 1e                	jmp    f0100b22 <stab_binsearch+0x48>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0100b04:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100b07:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100b0a:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0100b0e:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100b11:	73 41                	jae    f0100b54 <stab_binsearch+0x7a>
			*region_left = m;
f0100b13:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100b16:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0100b18:	8d 5f 01             	lea    0x1(%edi),%ebx
		any_matches = 1;
f0100b1b:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0100b22:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0100b25:	7f 5a                	jg     f0100b81 <stab_binsearch+0xa7>
		int true_m = (l + r) / 2, m = true_m;
f0100b27:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100b2a:	01 d8                	add    %ebx,%eax
f0100b2c:	89 c7                	mov    %eax,%edi
f0100b2e:	c1 ef 1f             	shr    $0x1f,%edi
f0100b31:	01 c7                	add    %eax,%edi
f0100b33:	d1 ff                	sar    %edi
f0100b35:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0100b38:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100b3b:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0100b3f:	89 f8                	mov    %edi,%eax
		while (m >= l && stabs[m].n_type != type)
f0100b41:	39 c3                	cmp    %eax,%ebx
f0100b43:	7f ba                	jg     f0100aff <stab_binsearch+0x25>
f0100b45:	0f b6 0a             	movzbl (%edx),%ecx
f0100b48:	83 ea 0c             	sub    $0xc,%edx
f0100b4b:	39 f1                	cmp    %esi,%ecx
f0100b4d:	74 b5                	je     f0100b04 <stab_binsearch+0x2a>
			m--;
f0100b4f:	83 e8 01             	sub    $0x1,%eax
f0100b52:	eb ed                	jmp    f0100b41 <stab_binsearch+0x67>
		} else if (stabs[m].n_value > addr) {
f0100b54:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100b57:	76 14                	jbe    f0100b6d <stab_binsearch+0x93>
			*region_right = m - 1;
f0100b59:	83 e8 01             	sub    $0x1,%eax
f0100b5c:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100b5f:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0100b62:	89 07                	mov    %eax,(%edi)
		any_matches = 1;
f0100b64:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100b6b:	eb b5                	jmp    f0100b22 <stab_binsearch+0x48>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100b6d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100b70:	89 07                	mov    %eax,(%edi)
			l = m;
			addr++;
f0100b72:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0100b76:	89 c3                	mov    %eax,%ebx
		any_matches = 1;
f0100b78:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100b7f:	eb a1                	jmp    f0100b22 <stab_binsearch+0x48>
		}
	}

	if (!any_matches)
f0100b81:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0100b85:	75 15                	jne    f0100b9c <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f0100b87:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100b8a:	8b 00                	mov    (%eax),%eax
f0100b8c:	83 e8 01             	sub    $0x1,%eax
f0100b8f:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0100b92:	89 06                	mov    %eax,(%esi)
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0100b94:	83 c4 14             	add    $0x14,%esp
f0100b97:	5b                   	pop    %ebx
f0100b98:	5e                   	pop    %esi
f0100b99:	5f                   	pop    %edi
f0100b9a:	5d                   	pop    %ebp
f0100b9b:	c3                   	ret    
		for (l = *region_right;
f0100b9c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100b9f:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0100ba1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100ba4:	8b 0f                	mov    (%edi),%ecx
f0100ba6:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100ba9:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0100bac:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
		for (l = *region_right;
f0100bb0:	eb 03                	jmp    f0100bb5 <stab_binsearch+0xdb>
		     l--)
f0100bb2:	83 e8 01             	sub    $0x1,%eax
		for (l = *region_right;
f0100bb5:	39 c1                	cmp    %eax,%ecx
f0100bb7:	7d 0a                	jge    f0100bc3 <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f0100bb9:	0f b6 1a             	movzbl (%edx),%ebx
f0100bbc:	83 ea 0c             	sub    $0xc,%edx
f0100bbf:	39 f3                	cmp    %esi,%ebx
f0100bc1:	75 ef                	jne    f0100bb2 <stab_binsearch+0xd8>
		*region_left = l;
f0100bc3:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100bc6:	89 06                	mov    %eax,(%esi)
}
f0100bc8:	eb ca                	jmp    f0100b94 <stab_binsearch+0xba>

f0100bca <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100bca:	55                   	push   %ebp
f0100bcb:	89 e5                	mov    %esp,%ebp
f0100bcd:	57                   	push   %edi
f0100bce:	56                   	push   %esi
f0100bcf:	53                   	push   %ebx
f0100bd0:	83 ec 3c             	sub    $0x3c,%esp
f0100bd3:	e8 e4 f5 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100bd8:	81 c3 90 34 01 00    	add    $0x13490,%ebx
f0100bde:	89 5d bc             	mov    %ebx,-0x44(%ebp)
f0100be1:	8b 7d 08             	mov    0x8(%ebp),%edi
f0100be4:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100be7:	8d 83 f0 df fe ff    	lea    -0x12010(%ebx),%eax
f0100bed:	89 06                	mov    %eax,(%esi)
	info->eip_line = 0;
f0100bef:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f0100bf6:	89 46 08             	mov    %eax,0x8(%esi)
	info->eip_fn_namelen = 9;
f0100bf9:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f0100c00:	89 7e 10             	mov    %edi,0x10(%esi)
	info->eip_fn_narg = 0;
f0100c03:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100c0a:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0100c10:	0f 86 42 01 00 00    	jbe    f0100d58 <debuginfo_eip+0x18e>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100c16:	c7 c0 a9 66 10 f0    	mov    $0xf01066a9,%eax
f0100c1c:	39 83 fc ff ff ff    	cmp    %eax,-0x4(%ebx)
f0100c22:	0f 86 04 02 00 00    	jbe    f0100e2c <debuginfo_eip+0x262>
f0100c28:	8b 5d bc             	mov    -0x44(%ebp),%ebx
f0100c2b:	c7 c0 5e 80 10 f0    	mov    $0xf010805e,%eax
f0100c31:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f0100c35:	0f 85 f8 01 00 00    	jne    f0100e33 <debuginfo_eip+0x269>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100c3b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100c42:	c7 c0 74 22 10 f0    	mov    $0xf0102274,%eax
f0100c48:	c7 c2 a8 66 10 f0    	mov    $0xf01066a8,%edx
f0100c4e:	29 c2                	sub    %eax,%edx
f0100c50:	c1 fa 02             	sar    $0x2,%edx
f0100c53:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0100c59:	83 ea 01             	sub    $0x1,%edx
f0100c5c:	89 55 e0             	mov    %edx,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100c5f:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100c62:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100c65:	83 ec 08             	sub    $0x8,%esp
f0100c68:	57                   	push   %edi
f0100c69:	6a 64                	push   $0x64
f0100c6b:	e8 6a fe ff ff       	call   f0100ada <stab_binsearch>
	if (lfile == 0)
f0100c70:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100c73:	83 c4 10             	add    $0x10,%esp
f0100c76:	85 c0                	test   %eax,%eax
f0100c78:	0f 84 bc 01 00 00    	je     f0100e3a <debuginfo_eip+0x270>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100c7e:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0100c81:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100c84:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100c87:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100c8a:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100c8d:	83 ec 08             	sub    $0x8,%esp
f0100c90:	57                   	push   %edi
f0100c91:	6a 24                	push   $0x24
f0100c93:	c7 c0 74 22 10 f0    	mov    $0xf0102274,%eax
f0100c99:	e8 3c fe ff ff       	call   f0100ada <stab_binsearch>

	if (lfun <= rfun) {
f0100c9e:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100ca1:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0100ca4:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
f0100ca7:	83 c4 10             	add    $0x10,%esp
f0100caa:	39 c8                	cmp    %ecx,%eax
f0100cac:	0f 8f c1 00 00 00    	jg     f0100d73 <debuginfo_eip+0x1a9>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100cb2:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100cb5:	c7 c1 74 22 10 f0    	mov    $0xf0102274,%ecx
f0100cbb:	8d 0c 91             	lea    (%ecx,%edx,4),%ecx
f0100cbe:	8b 11                	mov    (%ecx),%edx
f0100cc0:	89 55 c0             	mov    %edx,-0x40(%ebp)
f0100cc3:	c7 c2 5e 80 10 f0    	mov    $0xf010805e,%edx
f0100cc9:	89 5d bc             	mov    %ebx,-0x44(%ebp)
f0100ccc:	81 ea a9 66 10 f0    	sub    $0xf01066a9,%edx
f0100cd2:	8b 5d c0             	mov    -0x40(%ebp),%ebx
f0100cd5:	39 d3                	cmp    %edx,%ebx
f0100cd7:	73 0c                	jae    f0100ce5 <debuginfo_eip+0x11b>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100cd9:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0100cdc:	81 c3 a9 66 10 f0    	add    $0xf01066a9,%ebx
f0100ce2:	89 5e 08             	mov    %ebx,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100ce5:	8b 51 08             	mov    0x8(%ecx),%edx
f0100ce8:	89 56 10             	mov    %edx,0x10(%esi)
		addr -= info->eip_fn_addr;
f0100ceb:	29 d7                	sub    %edx,%edi
		// Search within the function definition for the line number.
		lline = lfun;
f0100ced:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0100cf0:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0100cf3:	89 45 d0             	mov    %eax,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100cf6:	83 ec 08             	sub    $0x8,%esp
f0100cf9:	6a 3a                	push   $0x3a
f0100cfb:	ff 76 08             	pushl  0x8(%esi)
f0100cfe:	8b 5d bc             	mov    -0x44(%ebp),%ebx
f0100d01:	e8 c9 09 00 00       	call   f01016cf <strfind>
f0100d06:	2b 46 08             	sub    0x8(%esi),%eax
f0100d09:	89 46 0c             	mov    %eax,0xc(%esi)
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0100d0c:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0100d0f:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0100d12:	83 c4 08             	add    $0x8,%esp
f0100d15:	57                   	push   %edi
f0100d16:	6a 44                	push   $0x44
f0100d18:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0100d1b:	c7 c0 74 22 10 f0    	mov    $0xf0102274,%eax
f0100d21:	e8 b4 fd ff ff       	call   f0100ada <stab_binsearch>
	if (lline <= rline) {
f0100d26:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0100d29:	83 c4 10             	add    $0x10,%esp
f0100d2c:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f0100d2f:	0f 8f 0c 01 00 00    	jg     f0100e41 <debuginfo_eip+0x277>
		 info->eip_line = stabs[lline].n_desc;
f0100d35:	89 d0                	mov    %edx,%eax
f0100d37:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0100d3a:	c1 e2 02             	shl    $0x2,%edx
f0100d3d:	c7 c1 74 22 10 f0    	mov    $0xf0102274,%ecx
f0100d43:	0f b7 5c 0a 06       	movzwl 0x6(%edx,%ecx,1),%ebx
f0100d48:	89 5e 04             	mov    %ebx,0x4(%esi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100d4b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100d4e:	8d 54 0a 04          	lea    0x4(%edx,%ecx,1),%edx
f0100d52:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f0100d56:	eb 39                	jmp    f0100d91 <debuginfo_eip+0x1c7>
  	        panic("User address");
f0100d58:	83 ec 04             	sub    $0x4,%esp
f0100d5b:	8b 5d bc             	mov    -0x44(%ebp),%ebx
f0100d5e:	8d 83 fa df fe ff    	lea    -0x12006(%ebx),%eax
f0100d64:	50                   	push   %eax
f0100d65:	6a 7f                	push   $0x7f
f0100d67:	8d 83 07 e0 fe ff    	lea    -0x11ff9(%ebx),%eax
f0100d6d:	50                   	push   %eax
f0100d6e:	e8 93 f3 ff ff       	call   f0100106 <_panic>
		info->eip_fn_addr = addr;
f0100d73:	89 7e 10             	mov    %edi,0x10(%esi)
		lline = lfile;
f0100d76:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100d79:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0100d7c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100d7f:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100d82:	e9 6f ff ff ff       	jmp    f0100cf6 <debuginfo_eip+0x12c>
f0100d87:	83 e8 01             	sub    $0x1,%eax
f0100d8a:	83 ea 0c             	sub    $0xc,%edx
f0100d8d:	c6 45 c4 01          	movb   $0x1,-0x3c(%ebp)
f0100d91:	89 45 c0             	mov    %eax,-0x40(%ebp)
	while (lline >= lfile
f0100d94:	39 c7                	cmp    %eax,%edi
f0100d96:	7f 51                	jg     f0100de9 <debuginfo_eip+0x21f>
	       && stabs[lline].n_type != N_SOL
f0100d98:	0f b6 0a             	movzbl (%edx),%ecx
f0100d9b:	80 f9 84             	cmp    $0x84,%cl
f0100d9e:	74 19                	je     f0100db9 <debuginfo_eip+0x1ef>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100da0:	80 f9 64             	cmp    $0x64,%cl
f0100da3:	75 e2                	jne    f0100d87 <debuginfo_eip+0x1bd>
f0100da5:	83 7a 04 00          	cmpl   $0x0,0x4(%edx)
f0100da9:	74 dc                	je     f0100d87 <debuginfo_eip+0x1bd>
f0100dab:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0100daf:	74 11                	je     f0100dc2 <debuginfo_eip+0x1f8>
f0100db1:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0100db4:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0100db7:	eb 09                	jmp    f0100dc2 <debuginfo_eip+0x1f8>
f0100db9:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0100dbd:	74 03                	je     f0100dc2 <debuginfo_eip+0x1f8>
f0100dbf:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100dc2:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100dc5:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0100dc8:	c7 c0 74 22 10 f0    	mov    $0xf0102274,%eax
f0100dce:	8b 14 90             	mov    (%eax,%edx,4),%edx
f0100dd1:	c7 c0 5e 80 10 f0    	mov    $0xf010805e,%eax
f0100dd7:	81 e8 a9 66 10 f0    	sub    $0xf01066a9,%eax
f0100ddd:	39 c2                	cmp    %eax,%edx
f0100ddf:	73 08                	jae    f0100de9 <debuginfo_eip+0x21f>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100de1:	81 c2 a9 66 10 f0    	add    $0xf01066a9,%edx
f0100de7:	89 16                	mov    %edx,(%esi)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100de9:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100dec:	8b 5d d8             	mov    -0x28(%ebp),%ebx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100def:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f0100df4:	39 da                	cmp    %ebx,%edx
f0100df6:	7d 55                	jge    f0100e4d <debuginfo_eip+0x283>
		for (lline = lfun + 1;
f0100df8:	83 c2 01             	add    $0x1,%edx
f0100dfb:	89 d0                	mov    %edx,%eax
f0100dfd:	8d 0c 52             	lea    (%edx,%edx,2),%ecx
f0100e00:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0100e03:	c7 c2 74 22 10 f0    	mov    $0xf0102274,%edx
f0100e09:	8d 54 8a 04          	lea    0x4(%edx,%ecx,4),%edx
f0100e0d:	eb 04                	jmp    f0100e13 <debuginfo_eip+0x249>
			info->eip_fn_narg++;
f0100e0f:	83 46 14 01          	addl   $0x1,0x14(%esi)
		for (lline = lfun + 1;
f0100e13:	39 c3                	cmp    %eax,%ebx
f0100e15:	7e 31                	jle    f0100e48 <debuginfo_eip+0x27e>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100e17:	0f b6 0a             	movzbl (%edx),%ecx
f0100e1a:	83 c0 01             	add    $0x1,%eax
f0100e1d:	83 c2 0c             	add    $0xc,%edx
f0100e20:	80 f9 a0             	cmp    $0xa0,%cl
f0100e23:	74 ea                	je     f0100e0f <debuginfo_eip+0x245>
	return 0;
f0100e25:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e2a:	eb 21                	jmp    f0100e4d <debuginfo_eip+0x283>
		return -1;
f0100e2c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100e31:	eb 1a                	jmp    f0100e4d <debuginfo_eip+0x283>
f0100e33:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100e38:	eb 13                	jmp    f0100e4d <debuginfo_eip+0x283>
		return -1;
f0100e3a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100e3f:	eb 0c                	jmp    f0100e4d <debuginfo_eip+0x283>
		 return -1;
f0100e41:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100e46:	eb 05                	jmp    f0100e4d <debuginfo_eip+0x283>
	return 0;
f0100e48:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100e4d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e50:	5b                   	pop    %ebx
f0100e51:	5e                   	pop    %esi
f0100e52:	5f                   	pop    %edi
f0100e53:	5d                   	pop    %ebp
f0100e54:	c3                   	ret    

f0100e55 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100e55:	55                   	push   %ebp
f0100e56:	89 e5                	mov    %esp,%ebp
f0100e58:	57                   	push   %edi
f0100e59:	56                   	push   %esi
f0100e5a:	53                   	push   %ebx
f0100e5b:	83 ec 2c             	sub    $0x2c,%esp
f0100e5e:	e8 08 06 00 00       	call   f010146b <__x86.get_pc_thunk.cx>
f0100e63:	81 c1 05 32 01 00    	add    $0x13205,%ecx
f0100e69:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0100e6c:	89 c7                	mov    %eax,%edi
f0100e6e:	89 d6                	mov    %edx,%esi
f0100e70:	8b 45 08             	mov    0x8(%ebp),%eax
f0100e73:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100e76:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100e79:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100e7c:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0100e7f:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100e84:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100e87:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0100e8a:	3b 45 10             	cmp    0x10(%ebp),%eax
f0100e8d:	89 d0                	mov    %edx,%eax
f0100e8f:	1b 45 e4             	sbb    -0x1c(%ebp),%eax
f0100e92:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0100e95:	73 15                	jae    f0100eac <printnum+0x57>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0100e97:	83 eb 01             	sub    $0x1,%ebx
f0100e9a:	85 db                	test   %ebx,%ebx
f0100e9c:	7e 46                	jle    f0100ee4 <printnum+0x8f>
			putch(padc, putdat);
f0100e9e:	83 ec 08             	sub    $0x8,%esp
f0100ea1:	56                   	push   %esi
f0100ea2:	ff 75 18             	pushl  0x18(%ebp)
f0100ea5:	ff d7                	call   *%edi
f0100ea7:	83 c4 10             	add    $0x10,%esp
f0100eaa:	eb eb                	jmp    f0100e97 <printnum+0x42>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100eac:	83 ec 0c             	sub    $0xc,%esp
f0100eaf:	ff 75 18             	pushl  0x18(%ebp)
f0100eb2:	8b 45 14             	mov    0x14(%ebp),%eax
f0100eb5:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0100eb8:	53                   	push   %ebx
f0100eb9:	ff 75 10             	pushl  0x10(%ebp)
f0100ebc:	83 ec 08             	sub    $0x8,%esp
f0100ebf:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100ec2:	ff 75 e0             	pushl  -0x20(%ebp)
f0100ec5:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100ec8:	ff 75 d0             	pushl  -0x30(%ebp)
f0100ecb:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0100ece:	e8 0d 0a 00 00       	call   f01018e0 <__udivdi3>
f0100ed3:	83 c4 18             	add    $0x18,%esp
f0100ed6:	52                   	push   %edx
f0100ed7:	50                   	push   %eax
f0100ed8:	89 f2                	mov    %esi,%edx
f0100eda:	89 f8                	mov    %edi,%eax
f0100edc:	e8 74 ff ff ff       	call   f0100e55 <printnum>
f0100ee1:	83 c4 20             	add    $0x20,%esp
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100ee4:	83 ec 08             	sub    $0x8,%esp
f0100ee7:	56                   	push   %esi
f0100ee8:	83 ec 04             	sub    $0x4,%esp
f0100eeb:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100eee:	ff 75 e0             	pushl  -0x20(%ebp)
f0100ef1:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100ef4:	ff 75 d0             	pushl  -0x30(%ebp)
f0100ef7:	8b 75 dc             	mov    -0x24(%ebp),%esi
f0100efa:	89 f3                	mov    %esi,%ebx
f0100efc:	e8 ef 0a 00 00       	call   f01019f0 <__umoddi3>
f0100f01:	83 c4 14             	add    $0x14,%esp
f0100f04:	0f be 84 06 15 e0 fe 	movsbl -0x11feb(%esi,%eax,1),%eax
f0100f0b:	ff 
f0100f0c:	50                   	push   %eax
f0100f0d:	ff d7                	call   *%edi
}
f0100f0f:	83 c4 10             	add    $0x10,%esp
f0100f12:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100f15:	5b                   	pop    %ebx
f0100f16:	5e                   	pop    %esi
f0100f17:	5f                   	pop    %edi
f0100f18:	5d                   	pop    %ebp
f0100f19:	c3                   	ret    

f0100f1a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100f1a:	55                   	push   %ebp
f0100f1b:	89 e5                	mov    %esp,%ebp
f0100f1d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100f20:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0100f24:	8b 10                	mov    (%eax),%edx
f0100f26:	3b 50 04             	cmp    0x4(%eax),%edx
f0100f29:	73 0a                	jae    f0100f35 <sprintputch+0x1b>
		*b->buf++ = ch;
f0100f2b:	8d 4a 01             	lea    0x1(%edx),%ecx
f0100f2e:	89 08                	mov    %ecx,(%eax)
f0100f30:	8b 45 08             	mov    0x8(%ebp),%eax
f0100f33:	88 02                	mov    %al,(%edx)
}
f0100f35:	5d                   	pop    %ebp
f0100f36:	c3                   	ret    

f0100f37 <printfmt>:
{
f0100f37:	55                   	push   %ebp
f0100f38:	89 e5                	mov    %esp,%ebp
f0100f3a:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f0100f3d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0100f40:	50                   	push   %eax
f0100f41:	ff 75 10             	pushl  0x10(%ebp)
f0100f44:	ff 75 0c             	pushl  0xc(%ebp)
f0100f47:	ff 75 08             	pushl  0x8(%ebp)
f0100f4a:	e8 05 00 00 00       	call   f0100f54 <vprintfmt>
}
f0100f4f:	83 c4 10             	add    $0x10,%esp
f0100f52:	c9                   	leave  
f0100f53:	c3                   	ret    

f0100f54 <vprintfmt>:
{
f0100f54:	55                   	push   %ebp
f0100f55:	89 e5                	mov    %esp,%ebp
f0100f57:	57                   	push   %edi
f0100f58:	56                   	push   %esi
f0100f59:	53                   	push   %ebx
f0100f5a:	83 ec 3c             	sub    $0x3c,%esp
f0100f5d:	e8 cb f7 ff ff       	call   f010072d <__x86.get_pc_thunk.ax>
f0100f62:	05 06 31 01 00       	add    $0x13106,%eax
f0100f67:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100f6a:	8b 75 08             	mov    0x8(%ebp),%esi
f0100f6d:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0100f70:	8b 5d 10             	mov    0x10(%ebp),%ebx
f0100f73:	eb 0a                	jmp    f0100f7f <vprintfmt+0x2b>
			putch(ch, putdat);
f0100f75:	83 ec 08             	sub    $0x8,%esp
f0100f78:	57                   	push   %edi
f0100f79:	50                   	push   %eax
f0100f7a:	ff d6                	call   *%esi
f0100f7c:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0100f7f:	83 c3 01             	add    $0x1,%ebx
f0100f82:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
f0100f86:	83 f8 25             	cmp    $0x25,%eax
f0100f89:	74 0c                	je     f0100f97 <vprintfmt+0x43>
			if (ch == '\0')
f0100f8b:	85 c0                	test   %eax,%eax
f0100f8d:	75 e6                	jne    f0100f75 <vprintfmt+0x21>
}
f0100f8f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100f92:	5b                   	pop    %ebx
f0100f93:	5e                   	pop    %esi
f0100f94:	5f                   	pop    %edi
f0100f95:	5d                   	pop    %ebp
f0100f96:	c3                   	ret    
		padc = ' ';
f0100f97:	c6 45 cf 20          	movb   $0x20,-0x31(%ebp)
		altflag = 0;
f0100f9b:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
		precision = -1;//精度
f0100fa2:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;//总宽度
f0100fa9:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		lflag = 0;
f0100fb0:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100fb5:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0100fb8:	89 75 08             	mov    %esi,0x8(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0100fbb:	8d 43 01             	lea    0x1(%ebx),%eax
f0100fbe:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100fc1:	0f b6 13             	movzbl (%ebx),%edx
f0100fc4:	8d 42 dd             	lea    -0x23(%edx),%eax
f0100fc7:	3c 55                	cmp    $0x55,%al
f0100fc9:	0f 87 00 04 00 00    	ja     f01013cf <.L21>
f0100fcf:	0f b6 c0             	movzbl %al,%eax
f0100fd2:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0100fd5:	89 ce                	mov    %ecx,%esi
f0100fd7:	03 b4 81 a4 e0 fe ff 	add    -0x11f5c(%ecx,%eax,4),%esi
f0100fde:	ff e6                	jmp    *%esi

f0100fe0 <.L68>:
f0100fe0:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
f0100fe3:	c6 45 cf 2d          	movb   $0x2d,-0x31(%ebp)
f0100fe7:	eb d2                	jmp    f0100fbb <vprintfmt+0x67>

f0100fe9 <.L33>:
		switch (ch = *(unsigned char *) fmt++) {
f0100fe9:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '0';
f0100fec:	c6 45 cf 30          	movb   $0x30,-0x31(%ebp)
f0100ff0:	eb c9                	jmp    f0100fbb <vprintfmt+0x67>

f0100ff2 <.L32>:
		switch (ch = *(unsigned char *) fmt++) {
f0100ff2:	0f b6 d2             	movzbl %dl,%edx
f0100ff5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {//依次读取数据宽度
f0100ff8:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ffd:	8b 75 08             	mov    0x8(%ebp),%esi
				precision = precision * 10 + ch - '0';
f0101000:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0101003:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f0101007:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
f010100a:	8d 4a d0             	lea    -0x30(%edx),%ecx
f010100d:	83 f9 09             	cmp    $0x9,%ecx
f0101010:	77 58                	ja     f010106a <.L37+0xf>
			for (precision = 0; ; ++fmt) {//依次读取数据宽度
f0101012:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
f0101015:	eb e9                	jmp    f0101000 <.L32+0xe>

f0101017 <.L35>:
			precision = va_arg(ap, int);
f0101017:	8b 45 14             	mov    0x14(%ebp),%eax
f010101a:	8b 00                	mov    (%eax),%eax
f010101c:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010101f:	8b 45 14             	mov    0x14(%ebp),%eax
f0101022:	8d 40 04             	lea    0x4(%eax),%eax
f0101025:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0101028:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
f010102b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f010102f:	79 8a                	jns    f0100fbb <vprintfmt+0x67>
				width = precision, precision = -1;
f0101031:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0101034:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101037:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
f010103e:	e9 78 ff ff ff       	jmp    f0100fbb <vprintfmt+0x67>

f0101043 <.L34>:
f0101043:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101046:	85 c0                	test   %eax,%eax
f0101048:	ba 00 00 00 00       	mov    $0x0,%edx
f010104d:	0f 49 d0             	cmovns %eax,%edx
f0101050:	89 55 d4             	mov    %edx,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0101053:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0101056:	e9 60 ff ff ff       	jmp    f0100fbb <vprintfmt+0x67>

f010105b <.L37>:
f010105b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
f010105e:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
f0101065:	e9 51 ff ff ff       	jmp    f0100fbb <vprintfmt+0x67>
f010106a:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010106d:	89 75 08             	mov    %esi,0x8(%ebp)
f0101070:	eb b9                	jmp    f010102b <.L35+0x14>

f0101072 <.L28>:
			lflag++;
f0101072:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0101076:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
f0101079:	e9 3d ff ff ff       	jmp    f0100fbb <vprintfmt+0x67>

f010107e <.L31>:
f010107e:	8b 75 08             	mov    0x8(%ebp),%esi
			putch(va_arg(ap, int), putdat);
f0101081:	8b 45 14             	mov    0x14(%ebp),%eax
f0101084:	8d 58 04             	lea    0x4(%eax),%ebx
f0101087:	83 ec 08             	sub    $0x8,%esp
f010108a:	57                   	push   %edi
f010108b:	ff 30                	pushl  (%eax)
f010108d:	ff d6                	call   *%esi
			break;
f010108f:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f0101092:	89 5d 14             	mov    %ebx,0x14(%ebp)
			break;
f0101095:	e9 cb 02 00 00       	jmp    f0101365 <.L26+0x45>

f010109a <.L29>:
f010109a:	8b 75 08             	mov    0x8(%ebp),%esi
			err = va_arg(ap, int);
f010109d:	8b 45 14             	mov    0x14(%ebp),%eax
f01010a0:	8d 58 04             	lea    0x4(%eax),%ebx
f01010a3:	8b 00                	mov    (%eax),%eax
f01010a5:	99                   	cltd   
f01010a6:	31 d0                	xor    %edx,%eax
f01010a8:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01010aa:	83 f8 06             	cmp    $0x6,%eax
f01010ad:	7f 2b                	jg     f01010da <.L29+0x40>
f01010af:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01010b2:	8b 94 82 dc ff ff ff 	mov    -0x24(%edx,%eax,4),%edx
f01010b9:	85 d2                	test   %edx,%edx
f01010bb:	74 1d                	je     f01010da <.L29+0x40>
				printfmt(putch, putdat, "%s", p);
f01010bd:	52                   	push   %edx
f01010be:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01010c1:	8d 80 36 e0 fe ff    	lea    -0x11fca(%eax),%eax
f01010c7:	50                   	push   %eax
f01010c8:	57                   	push   %edi
f01010c9:	56                   	push   %esi
f01010ca:	e8 68 fe ff ff       	call   f0100f37 <printfmt>
f01010cf:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f01010d2:	89 5d 14             	mov    %ebx,0x14(%ebp)
f01010d5:	e9 8b 02 00 00       	jmp    f0101365 <.L26+0x45>
				printfmt(putch, putdat, "error %d", err);
f01010da:	50                   	push   %eax
f01010db:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01010de:	8d 80 2d e0 fe ff    	lea    -0x11fd3(%eax),%eax
f01010e4:	50                   	push   %eax
f01010e5:	57                   	push   %edi
f01010e6:	56                   	push   %esi
f01010e7:	e8 4b fe ff ff       	call   f0100f37 <printfmt>
f01010ec:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f01010ef:	89 5d 14             	mov    %ebx,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f01010f2:	e9 6e 02 00 00       	jmp    f0101365 <.L26+0x45>

f01010f7 <.L25>:
f01010f7:	8b 75 08             	mov    0x8(%ebp),%esi
			if ((p = va_arg(ap, char *)) == NULL)
f01010fa:	8b 45 14             	mov    0x14(%ebp),%eax
f01010fd:	83 c0 04             	add    $0x4,%eax
f0101100:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0101103:	8b 45 14             	mov    0x14(%ebp),%eax
f0101106:	8b 10                	mov    (%eax),%edx
				p = "(null)";
f0101108:	85 d2                	test   %edx,%edx
f010110a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010110d:	8d 80 26 e0 fe ff    	lea    -0x11fda(%eax),%eax
f0101113:	0f 45 c2             	cmovne %edx,%eax
f0101116:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
f0101119:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f010111d:	7e 06                	jle    f0101125 <.L25+0x2e>
f010111f:	80 7d cf 2d          	cmpb   $0x2d,-0x31(%ebp)
f0101123:	75 0d                	jne    f0101132 <.L25+0x3b>
				for (width -= strnlen(p, precision); width > 0; width--)
f0101125:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0101128:	89 c3                	mov    %eax,%ebx
f010112a:	03 45 d4             	add    -0x2c(%ebp),%eax
f010112d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101130:	eb 42                	jmp    f0101174 <.L25+0x7d>
f0101132:	83 ec 08             	sub    $0x8,%esp
f0101135:	ff 75 d8             	pushl  -0x28(%ebp)
f0101138:	50                   	push   %eax
f0101139:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f010113c:	e8 43 04 00 00       	call   f0101584 <strnlen>
f0101141:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101144:	29 c2                	sub    %eax,%edx
f0101146:	89 55 c0             	mov    %edx,-0x40(%ebp)
f0101149:	83 c4 10             	add    $0x10,%esp
f010114c:	89 d3                	mov    %edx,%ebx
					putch(padc, putdat);
f010114e:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
f0101152:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f0101155:	85 db                	test   %ebx,%ebx
f0101157:	7e 58                	jle    f01011b1 <.L25+0xba>
					putch(padc, putdat);
f0101159:	83 ec 08             	sub    $0x8,%esp
f010115c:	57                   	push   %edi
f010115d:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101160:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f0101162:	83 eb 01             	sub    $0x1,%ebx
f0101165:	83 c4 10             	add    $0x10,%esp
f0101168:	eb eb                	jmp    f0101155 <.L25+0x5e>
					putch(ch, putdat);
f010116a:	83 ec 08             	sub    $0x8,%esp
f010116d:	57                   	push   %edi
f010116e:	52                   	push   %edx
f010116f:	ff d6                	call   *%esi
f0101171:	83 c4 10             	add    $0x10,%esp
f0101174:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101177:	29 d9                	sub    %ebx,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0101179:	83 c3 01             	add    $0x1,%ebx
f010117c:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
f0101180:	0f be d0             	movsbl %al,%edx
f0101183:	85 d2                	test   %edx,%edx
f0101185:	74 45                	je     f01011cc <.L25+0xd5>
f0101187:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f010118b:	78 06                	js     f0101193 <.L25+0x9c>
f010118d:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
f0101191:	78 35                	js     f01011c8 <.L25+0xd1>
				if (altflag && (ch < ' ' || ch > '~'))
f0101193:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f0101197:	74 d1                	je     f010116a <.L25+0x73>
f0101199:	0f be c0             	movsbl %al,%eax
f010119c:	83 e8 20             	sub    $0x20,%eax
f010119f:	83 f8 5e             	cmp    $0x5e,%eax
f01011a2:	76 c6                	jbe    f010116a <.L25+0x73>
					putch('?', putdat);
f01011a4:	83 ec 08             	sub    $0x8,%esp
f01011a7:	57                   	push   %edi
f01011a8:	6a 3f                	push   $0x3f
f01011aa:	ff d6                	call   *%esi
f01011ac:	83 c4 10             	add    $0x10,%esp
f01011af:	eb c3                	jmp    f0101174 <.L25+0x7d>
f01011b1:	8b 55 c0             	mov    -0x40(%ebp),%edx
f01011b4:	85 d2                	test   %edx,%edx
f01011b6:	b8 00 00 00 00       	mov    $0x0,%eax
f01011bb:	0f 49 c2             	cmovns %edx,%eax
f01011be:	29 c2                	sub    %eax,%edx
f01011c0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f01011c3:	e9 5d ff ff ff       	jmp    f0101125 <.L25+0x2e>
f01011c8:	89 cb                	mov    %ecx,%ebx
f01011ca:	eb 02                	jmp    f01011ce <.L25+0xd7>
f01011cc:	89 cb                	mov    %ecx,%ebx
			for (; width > 0; width--)
f01011ce:	85 db                	test   %ebx,%ebx
f01011d0:	7e 10                	jle    f01011e2 <.L25+0xeb>
				putch(' ', putdat);
f01011d2:	83 ec 08             	sub    $0x8,%esp
f01011d5:	57                   	push   %edi
f01011d6:	6a 20                	push   $0x20
f01011d8:	ff d6                	call   *%esi
			for (; width > 0; width--)
f01011da:	83 eb 01             	sub    $0x1,%ebx
f01011dd:	83 c4 10             	add    $0x10,%esp
f01011e0:	eb ec                	jmp    f01011ce <.L25+0xd7>
			if ((p = va_arg(ap, char *)) == NULL)
f01011e2:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f01011e5:	89 45 14             	mov    %eax,0x14(%ebp)
f01011e8:	e9 78 01 00 00       	jmp    f0101365 <.L26+0x45>

f01011ed <.L30>:
f01011ed:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f01011f0:	8b 75 08             	mov    0x8(%ebp),%esi
	if (lflag >= 2)
f01011f3:	83 f9 01             	cmp    $0x1,%ecx
f01011f6:	7f 1b                	jg     f0101213 <.L30+0x26>
	else if (lflag)
f01011f8:	85 c9                	test   %ecx,%ecx
f01011fa:	74 63                	je     f010125f <.L30+0x72>
		return va_arg(*ap, long);
f01011fc:	8b 45 14             	mov    0x14(%ebp),%eax
f01011ff:	8b 00                	mov    (%eax),%eax
f0101201:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101204:	99                   	cltd   
f0101205:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0101208:	8b 45 14             	mov    0x14(%ebp),%eax
f010120b:	8d 40 04             	lea    0x4(%eax),%eax
f010120e:	89 45 14             	mov    %eax,0x14(%ebp)
f0101211:	eb 17                	jmp    f010122a <.L30+0x3d>
		return va_arg(*ap, long long);
f0101213:	8b 45 14             	mov    0x14(%ebp),%eax
f0101216:	8b 50 04             	mov    0x4(%eax),%edx
f0101219:	8b 00                	mov    (%eax),%eax
f010121b:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010121e:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0101221:	8b 45 14             	mov    0x14(%ebp),%eax
f0101224:	8d 40 08             	lea    0x8(%eax),%eax
f0101227:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f010122a:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010122d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f0101230:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
f0101235:	85 c9                	test   %ecx,%ecx
f0101237:	0f 89 0e 01 00 00    	jns    f010134b <.L26+0x2b>
				putch('-', putdat);
f010123d:	83 ec 08             	sub    $0x8,%esp
f0101240:	57                   	push   %edi
f0101241:	6a 2d                	push   $0x2d
f0101243:	ff d6                	call   *%esi
				num = -(long long) num;
f0101245:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0101248:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f010124b:	f7 da                	neg    %edx
f010124d:	83 d1 00             	adc    $0x0,%ecx
f0101250:	f7 d9                	neg    %ecx
f0101252:	83 c4 10             	add    $0x10,%esp
			base = 10;
f0101255:	b8 0a 00 00 00       	mov    $0xa,%eax
f010125a:	e9 ec 00 00 00       	jmp    f010134b <.L26+0x2b>
		return va_arg(*ap, int);
f010125f:	8b 45 14             	mov    0x14(%ebp),%eax
f0101262:	8b 00                	mov    (%eax),%eax
f0101264:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101267:	99                   	cltd   
f0101268:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010126b:	8b 45 14             	mov    0x14(%ebp),%eax
f010126e:	8d 40 04             	lea    0x4(%eax),%eax
f0101271:	89 45 14             	mov    %eax,0x14(%ebp)
f0101274:	eb b4                	jmp    f010122a <.L30+0x3d>

f0101276 <.L24>:
f0101276:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0101279:	8b 75 08             	mov    0x8(%ebp),%esi
	if (lflag >= 2)
f010127c:	83 f9 01             	cmp    $0x1,%ecx
f010127f:	7f 1e                	jg     f010129f <.L24+0x29>
	else if (lflag)
f0101281:	85 c9                	test   %ecx,%ecx
f0101283:	74 32                	je     f01012b7 <.L24+0x41>
		return va_arg(*ap, unsigned long);
f0101285:	8b 45 14             	mov    0x14(%ebp),%eax
f0101288:	8b 10                	mov    (%eax),%edx
f010128a:	b9 00 00 00 00       	mov    $0x0,%ecx
f010128f:	8d 40 04             	lea    0x4(%eax),%eax
f0101292:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0101295:	b8 0a 00 00 00       	mov    $0xa,%eax
f010129a:	e9 ac 00 00 00       	jmp    f010134b <.L26+0x2b>
		return va_arg(*ap, unsigned long long);
f010129f:	8b 45 14             	mov    0x14(%ebp),%eax
f01012a2:	8b 10                	mov    (%eax),%edx
f01012a4:	8b 48 04             	mov    0x4(%eax),%ecx
f01012a7:	8d 40 08             	lea    0x8(%eax),%eax
f01012aa:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01012ad:	b8 0a 00 00 00       	mov    $0xa,%eax
f01012b2:	e9 94 00 00 00       	jmp    f010134b <.L26+0x2b>
		return va_arg(*ap, unsigned int);
f01012b7:	8b 45 14             	mov    0x14(%ebp),%eax
f01012ba:	8b 10                	mov    (%eax),%edx
f01012bc:	b9 00 00 00 00       	mov    $0x0,%ecx
f01012c1:	8d 40 04             	lea    0x4(%eax),%eax
f01012c4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01012c7:	b8 0a 00 00 00       	mov    $0xa,%eax
f01012cc:	eb 7d                	jmp    f010134b <.L26+0x2b>

f01012ce <.L27>:
f01012ce:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f01012d1:	8b 75 08             	mov    0x8(%ebp),%esi
	if (lflag >= 2)
f01012d4:	83 f9 01             	cmp    $0x1,%ecx
f01012d7:	7f 1b                	jg     f01012f4 <.L27+0x26>
	else if (lflag)
f01012d9:	85 c9                	test   %ecx,%ecx
f01012db:	74 2c                	je     f0101309 <.L27+0x3b>
		return va_arg(*ap, unsigned long);
f01012dd:	8b 45 14             	mov    0x14(%ebp),%eax
f01012e0:	8b 10                	mov    (%eax),%edx
f01012e2:	b9 00 00 00 00       	mov    $0x0,%ecx
f01012e7:	8d 40 04             	lea    0x4(%eax),%eax
f01012ea:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f01012ed:	b8 08 00 00 00       	mov    $0x8,%eax
f01012f2:	eb 57                	jmp    f010134b <.L26+0x2b>
		return va_arg(*ap, unsigned long long);
f01012f4:	8b 45 14             	mov    0x14(%ebp),%eax
f01012f7:	8b 10                	mov    (%eax),%edx
f01012f9:	8b 48 04             	mov    0x4(%eax),%ecx
f01012fc:	8d 40 08             	lea    0x8(%eax),%eax
f01012ff:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0101302:	b8 08 00 00 00       	mov    $0x8,%eax
f0101307:	eb 42                	jmp    f010134b <.L26+0x2b>
		return va_arg(*ap, unsigned int);
f0101309:	8b 45 14             	mov    0x14(%ebp),%eax
f010130c:	8b 10                	mov    (%eax),%edx
f010130e:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101313:	8d 40 04             	lea    0x4(%eax),%eax
f0101316:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0101319:	b8 08 00 00 00       	mov    $0x8,%eax
f010131e:	eb 2b                	jmp    f010134b <.L26+0x2b>

f0101320 <.L26>:
f0101320:	8b 75 08             	mov    0x8(%ebp),%esi
			putch('0', putdat);
f0101323:	83 ec 08             	sub    $0x8,%esp
f0101326:	57                   	push   %edi
f0101327:	6a 30                	push   $0x30
f0101329:	ff d6                	call   *%esi
			putch('x', putdat);
f010132b:	83 c4 08             	add    $0x8,%esp
f010132e:	57                   	push   %edi
f010132f:	6a 78                	push   $0x78
f0101331:	ff d6                	call   *%esi
			num = (unsigned long long)
f0101333:	8b 45 14             	mov    0x14(%ebp),%eax
f0101336:	8b 10                	mov    (%eax),%edx
f0101338:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f010133d:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f0101340:	8d 40 04             	lea    0x4(%eax),%eax
f0101343:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0101346:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
f010134b:	83 ec 0c             	sub    $0xc,%esp
f010134e:	0f be 5d cf          	movsbl -0x31(%ebp),%ebx
f0101352:	53                   	push   %ebx
f0101353:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101356:	50                   	push   %eax
f0101357:	51                   	push   %ecx
f0101358:	52                   	push   %edx
f0101359:	89 fa                	mov    %edi,%edx
f010135b:	89 f0                	mov    %esi,%eax
f010135d:	e8 f3 fa ff ff       	call   f0100e55 <printnum>
			break;
f0101362:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
f0101365:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0101368:	e9 12 fc ff ff       	jmp    f0100f7f <vprintfmt+0x2b>

f010136d <.L22>:
f010136d:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0101370:	8b 75 08             	mov    0x8(%ebp),%esi
	if (lflag >= 2)
f0101373:	83 f9 01             	cmp    $0x1,%ecx
f0101376:	7f 1b                	jg     f0101393 <.L22+0x26>
	else if (lflag)
f0101378:	85 c9                	test   %ecx,%ecx
f010137a:	74 2c                	je     f01013a8 <.L22+0x3b>
		return va_arg(*ap, unsigned long);
f010137c:	8b 45 14             	mov    0x14(%ebp),%eax
f010137f:	8b 10                	mov    (%eax),%edx
f0101381:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101386:	8d 40 04             	lea    0x4(%eax),%eax
f0101389:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010138c:	b8 10 00 00 00       	mov    $0x10,%eax
f0101391:	eb b8                	jmp    f010134b <.L26+0x2b>
		return va_arg(*ap, unsigned long long);
f0101393:	8b 45 14             	mov    0x14(%ebp),%eax
f0101396:	8b 10                	mov    (%eax),%edx
f0101398:	8b 48 04             	mov    0x4(%eax),%ecx
f010139b:	8d 40 08             	lea    0x8(%eax),%eax
f010139e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01013a1:	b8 10 00 00 00       	mov    $0x10,%eax
f01013a6:	eb a3                	jmp    f010134b <.L26+0x2b>
		return va_arg(*ap, unsigned int);
f01013a8:	8b 45 14             	mov    0x14(%ebp),%eax
f01013ab:	8b 10                	mov    (%eax),%edx
f01013ad:	b9 00 00 00 00       	mov    $0x0,%ecx
f01013b2:	8d 40 04             	lea    0x4(%eax),%eax
f01013b5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01013b8:	b8 10 00 00 00       	mov    $0x10,%eax
f01013bd:	eb 8c                	jmp    f010134b <.L26+0x2b>

f01013bf <.L36>:
f01013bf:	8b 75 08             	mov    0x8(%ebp),%esi
			putch(ch, putdat);
f01013c2:	83 ec 08             	sub    $0x8,%esp
f01013c5:	57                   	push   %edi
f01013c6:	6a 25                	push   $0x25
f01013c8:	ff d6                	call   *%esi
			break;
f01013ca:	83 c4 10             	add    $0x10,%esp
f01013cd:	eb 96                	jmp    f0101365 <.L26+0x45>

f01013cf <.L21>:
f01013cf:	8b 75 08             	mov    0x8(%ebp),%esi
			putch('%', putdat);
f01013d2:	83 ec 08             	sub    $0x8,%esp
f01013d5:	57                   	push   %edi
f01013d6:	6a 25                	push   $0x25
f01013d8:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f01013da:	83 c4 10             	add    $0x10,%esp
f01013dd:	89 d8                	mov    %ebx,%eax
f01013df:	eb 03                	jmp    f01013e4 <.L21+0x15>
f01013e1:	83 e8 01             	sub    $0x1,%eax
f01013e4:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f01013e8:	75 f7                	jne    f01013e1 <.L21+0x12>
f01013ea:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01013ed:	e9 73 ff ff ff       	jmp    f0101365 <.L26+0x45>

f01013f2 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01013f2:	55                   	push   %ebp
f01013f3:	89 e5                	mov    %esp,%ebp
f01013f5:	53                   	push   %ebx
f01013f6:	83 ec 14             	sub    $0x14,%esp
f01013f9:	e8 be ed ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f01013fe:	81 c3 6a 2c 01 00    	add    $0x12c6a,%ebx
f0101404:	8b 45 08             	mov    0x8(%ebp),%eax
f0101407:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f010140a:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010140d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0101411:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0101414:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010141b:	85 c0                	test   %eax,%eax
f010141d:	74 2b                	je     f010144a <vsnprintf+0x58>
f010141f:	85 d2                	test   %edx,%edx
f0101421:	7e 27                	jle    f010144a <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0101423:	ff 75 14             	pushl  0x14(%ebp)
f0101426:	ff 75 10             	pushl  0x10(%ebp)
f0101429:	8d 45 ec             	lea    -0x14(%ebp),%eax
f010142c:	50                   	push   %eax
f010142d:	8d 83 b2 ce fe ff    	lea    -0x1314e(%ebx),%eax
f0101433:	50                   	push   %eax
f0101434:	e8 1b fb ff ff       	call   f0100f54 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0101439:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010143c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010143f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101442:	83 c4 10             	add    $0x10,%esp
}
f0101445:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101448:	c9                   	leave  
f0101449:	c3                   	ret    
		return -E_INVAL;
f010144a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010144f:	eb f4                	jmp    f0101445 <vsnprintf+0x53>

f0101451 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0101451:	55                   	push   %ebp
f0101452:	89 e5                	mov    %esp,%ebp
f0101454:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0101457:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f010145a:	50                   	push   %eax
f010145b:	ff 75 10             	pushl  0x10(%ebp)
f010145e:	ff 75 0c             	pushl  0xc(%ebp)
f0101461:	ff 75 08             	pushl  0x8(%ebp)
f0101464:	e8 89 ff ff ff       	call   f01013f2 <vsnprintf>
	va_end(ap);

	return rc;
}
f0101469:	c9                   	leave  
f010146a:	c3                   	ret    

f010146b <__x86.get_pc_thunk.cx>:
f010146b:	8b 0c 24             	mov    (%esp),%ecx
f010146e:	c3                   	ret    

f010146f <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f010146f:	55                   	push   %ebp
f0101470:	89 e5                	mov    %esp,%ebp
f0101472:	57                   	push   %edi
f0101473:	56                   	push   %esi
f0101474:	53                   	push   %ebx
f0101475:	83 ec 1c             	sub    $0x1c,%esp
f0101478:	e8 3f ed ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f010147d:	81 c3 eb 2b 01 00    	add    $0x12beb,%ebx
f0101483:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0101486:	85 c0                	test   %eax,%eax
f0101488:	74 13                	je     f010149d <readline+0x2e>
		cprintf("%s", prompt);
f010148a:	83 ec 08             	sub    $0x8,%esp
f010148d:	50                   	push   %eax
f010148e:	8d 83 36 e0 fe ff    	lea    -0x11fca(%ebx),%eax
f0101494:	50                   	push   %eax
f0101495:	e8 2c f6 ff ff       	call   f0100ac6 <cprintf>
f010149a:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f010149d:	83 ec 0c             	sub    $0xc,%esp
f01014a0:	6a 00                	push   $0x0
f01014a2:	e8 80 f2 ff ff       	call   f0100727 <iscons>
f01014a7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01014aa:	83 c4 10             	add    $0x10,%esp
	i = 0;
f01014ad:	bf 00 00 00 00       	mov    $0x0,%edi
f01014b2:	eb 52                	jmp    f0101506 <readline+0x97>
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
f01014b4:	83 ec 08             	sub    $0x8,%esp
f01014b7:	50                   	push   %eax
f01014b8:	8d 83 fc e1 fe ff    	lea    -0x11e04(%ebx),%eax
f01014be:	50                   	push   %eax
f01014bf:	e8 02 f6 ff ff       	call   f0100ac6 <cprintf>
			return NULL;
f01014c4:	83 c4 10             	add    $0x10,%esp
f01014c7:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f01014cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01014cf:	5b                   	pop    %ebx
f01014d0:	5e                   	pop    %esi
f01014d1:	5f                   	pop    %edi
f01014d2:	5d                   	pop    %ebp
f01014d3:	c3                   	ret    
			if (echoing)
f01014d4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01014d8:	75 05                	jne    f01014df <readline+0x70>
			i--;
f01014da:	83 ef 01             	sub    $0x1,%edi
f01014dd:	eb 27                	jmp    f0101506 <readline+0x97>
				cputchar('\b');
f01014df:	83 ec 0c             	sub    $0xc,%esp
f01014e2:	6a 08                	push   $0x8
f01014e4:	e8 1d f2 ff ff       	call   f0100706 <cputchar>
f01014e9:	83 c4 10             	add    $0x10,%esp
f01014ec:	eb ec                	jmp    f01014da <readline+0x6b>
				cputchar(c);
f01014ee:	83 ec 0c             	sub    $0xc,%esp
f01014f1:	56                   	push   %esi
f01014f2:	e8 0f f2 ff ff       	call   f0100706 <cputchar>
f01014f7:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f01014fa:	89 f0                	mov    %esi,%eax
f01014fc:	88 84 3b 58 02 00 00 	mov    %al,0x258(%ebx,%edi,1)
f0101503:	8d 7f 01             	lea    0x1(%edi),%edi
		c = getchar();
f0101506:	e8 0b f2 ff ff       	call   f0100716 <getchar>
f010150b:	89 c6                	mov    %eax,%esi
		if (c < 0) {
f010150d:	85 c0                	test   %eax,%eax
f010150f:	78 a3                	js     f01014b4 <readline+0x45>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0101511:	83 f8 08             	cmp    $0x8,%eax
f0101514:	0f 94 c2             	sete   %dl
f0101517:	83 f8 7f             	cmp    $0x7f,%eax
f010151a:	0f 94 c0             	sete   %al
f010151d:	08 c2                	or     %al,%dl
f010151f:	74 04                	je     f0101525 <readline+0xb6>
f0101521:	85 ff                	test   %edi,%edi
f0101523:	7f af                	jg     f01014d4 <readline+0x65>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0101525:	83 fe 1f             	cmp    $0x1f,%esi
f0101528:	7e 10                	jle    f010153a <readline+0xcb>
f010152a:	81 ff fe 03 00 00    	cmp    $0x3fe,%edi
f0101530:	7f 08                	jg     f010153a <readline+0xcb>
			if (echoing)
f0101532:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0101536:	74 c2                	je     f01014fa <readline+0x8b>
f0101538:	eb b4                	jmp    f01014ee <readline+0x7f>
		} else if (c == '\n' || c == '\r') {
f010153a:	83 fe 0a             	cmp    $0xa,%esi
f010153d:	74 05                	je     f0101544 <readline+0xd5>
f010153f:	83 fe 0d             	cmp    $0xd,%esi
f0101542:	75 c2                	jne    f0101506 <readline+0x97>
			if (echoing)
f0101544:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0101548:	75 13                	jne    f010155d <readline+0xee>
			buf[i] = 0;
f010154a:	c6 84 3b 58 02 00 00 	movb   $0x0,0x258(%ebx,%edi,1)
f0101551:	00 
			return buf;
f0101552:	8d 83 58 02 00 00    	lea    0x258(%ebx),%eax
f0101558:	e9 6f ff ff ff       	jmp    f01014cc <readline+0x5d>
				cputchar('\n');
f010155d:	83 ec 0c             	sub    $0xc,%esp
f0101560:	6a 0a                	push   $0xa
f0101562:	e8 9f f1 ff ff       	call   f0100706 <cputchar>
f0101567:	83 c4 10             	add    $0x10,%esp
f010156a:	eb de                	jmp    f010154a <readline+0xdb>

f010156c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f010156c:	55                   	push   %ebp
f010156d:	89 e5                	mov    %esp,%ebp
f010156f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0101572:	b8 00 00 00 00       	mov    $0x0,%eax
f0101577:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f010157b:	74 05                	je     f0101582 <strlen+0x16>
		n++;
f010157d:	83 c0 01             	add    $0x1,%eax
f0101580:	eb f5                	jmp    f0101577 <strlen+0xb>
	return n;
}
f0101582:	5d                   	pop    %ebp
f0101583:	c3                   	ret    

f0101584 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0101584:	55                   	push   %ebp
f0101585:	89 e5                	mov    %esp,%ebp
f0101587:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010158a:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010158d:	ba 00 00 00 00       	mov    $0x0,%edx
f0101592:	39 c2                	cmp    %eax,%edx
f0101594:	74 0d                	je     f01015a3 <strnlen+0x1f>
f0101596:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f010159a:	74 05                	je     f01015a1 <strnlen+0x1d>
		n++;
f010159c:	83 c2 01             	add    $0x1,%edx
f010159f:	eb f1                	jmp    f0101592 <strnlen+0xe>
f01015a1:	89 d0                	mov    %edx,%eax
	return n;
}
f01015a3:	5d                   	pop    %ebp
f01015a4:	c3                   	ret    

f01015a5 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01015a5:	55                   	push   %ebp
f01015a6:	89 e5                	mov    %esp,%ebp
f01015a8:	53                   	push   %ebx
f01015a9:	8b 45 08             	mov    0x8(%ebp),%eax
f01015ac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01015af:	ba 00 00 00 00       	mov    $0x0,%edx
f01015b4:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f01015b8:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f01015bb:	83 c2 01             	add    $0x1,%edx
f01015be:	84 c9                	test   %cl,%cl
f01015c0:	75 f2                	jne    f01015b4 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f01015c2:	5b                   	pop    %ebx
f01015c3:	5d                   	pop    %ebp
f01015c4:	c3                   	ret    

f01015c5 <strcat>:

char *
strcat(char *dst, const char *src)
{
f01015c5:	55                   	push   %ebp
f01015c6:	89 e5                	mov    %esp,%ebp
f01015c8:	53                   	push   %ebx
f01015c9:	83 ec 10             	sub    $0x10,%esp
f01015cc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01015cf:	53                   	push   %ebx
f01015d0:	e8 97 ff ff ff       	call   f010156c <strlen>
f01015d5:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
f01015d8:	ff 75 0c             	pushl  0xc(%ebp)
f01015db:	01 d8                	add    %ebx,%eax
f01015dd:	50                   	push   %eax
f01015de:	e8 c2 ff ff ff       	call   f01015a5 <strcpy>
	return dst;
}
f01015e3:	89 d8                	mov    %ebx,%eax
f01015e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01015e8:	c9                   	leave  
f01015e9:	c3                   	ret    

f01015ea <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01015ea:	55                   	push   %ebp
f01015eb:	89 e5                	mov    %esp,%ebp
f01015ed:	56                   	push   %esi
f01015ee:	53                   	push   %ebx
f01015ef:	8b 45 08             	mov    0x8(%ebp),%eax
f01015f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01015f5:	89 c6                	mov    %eax,%esi
f01015f7:	03 75 10             	add    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01015fa:	89 c2                	mov    %eax,%edx
f01015fc:	39 f2                	cmp    %esi,%edx
f01015fe:	74 11                	je     f0101611 <strncpy+0x27>
		*dst++ = *src;
f0101600:	83 c2 01             	add    $0x1,%edx
f0101603:	0f b6 19             	movzbl (%ecx),%ebx
f0101606:	88 5a ff             	mov    %bl,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0101609:	80 fb 01             	cmp    $0x1,%bl
f010160c:	83 d9 ff             	sbb    $0xffffffff,%ecx
f010160f:	eb eb                	jmp    f01015fc <strncpy+0x12>
	}
	return ret;
}
f0101611:	5b                   	pop    %ebx
f0101612:	5e                   	pop    %esi
f0101613:	5d                   	pop    %ebp
f0101614:	c3                   	ret    

f0101615 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0101615:	55                   	push   %ebp
f0101616:	89 e5                	mov    %esp,%ebp
f0101618:	56                   	push   %esi
f0101619:	53                   	push   %ebx
f010161a:	8b 75 08             	mov    0x8(%ebp),%esi
f010161d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101620:	8b 55 10             	mov    0x10(%ebp),%edx
f0101623:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0101625:	85 d2                	test   %edx,%edx
f0101627:	74 21                	je     f010164a <strlcpy+0x35>
f0101629:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f010162d:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
f010162f:	39 c2                	cmp    %eax,%edx
f0101631:	74 14                	je     f0101647 <strlcpy+0x32>
f0101633:	0f b6 19             	movzbl (%ecx),%ebx
f0101636:	84 db                	test   %bl,%bl
f0101638:	74 0b                	je     f0101645 <strlcpy+0x30>
			*dst++ = *src++;
f010163a:	83 c1 01             	add    $0x1,%ecx
f010163d:	83 c2 01             	add    $0x1,%edx
f0101640:	88 5a ff             	mov    %bl,-0x1(%edx)
f0101643:	eb ea                	jmp    f010162f <strlcpy+0x1a>
f0101645:	89 d0                	mov    %edx,%eax
		*dst = '\0';
f0101647:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f010164a:	29 f0                	sub    %esi,%eax
}
f010164c:	5b                   	pop    %ebx
f010164d:	5e                   	pop    %esi
f010164e:	5d                   	pop    %ebp
f010164f:	c3                   	ret    

f0101650 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0101650:	55                   	push   %ebp
f0101651:	89 e5                	mov    %esp,%ebp
f0101653:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101656:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0101659:	0f b6 01             	movzbl (%ecx),%eax
f010165c:	84 c0                	test   %al,%al
f010165e:	74 0c                	je     f010166c <strcmp+0x1c>
f0101660:	3a 02                	cmp    (%edx),%al
f0101662:	75 08                	jne    f010166c <strcmp+0x1c>
		p++, q++;
f0101664:	83 c1 01             	add    $0x1,%ecx
f0101667:	83 c2 01             	add    $0x1,%edx
f010166a:	eb ed                	jmp    f0101659 <strcmp+0x9>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f010166c:	0f b6 c0             	movzbl %al,%eax
f010166f:	0f b6 12             	movzbl (%edx),%edx
f0101672:	29 d0                	sub    %edx,%eax
}
f0101674:	5d                   	pop    %ebp
f0101675:	c3                   	ret    

f0101676 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0101676:	55                   	push   %ebp
f0101677:	89 e5                	mov    %esp,%ebp
f0101679:	53                   	push   %ebx
f010167a:	8b 45 08             	mov    0x8(%ebp),%eax
f010167d:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101680:	89 c3                	mov    %eax,%ebx
f0101682:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0101685:	eb 06                	jmp    f010168d <strncmp+0x17>
		n--, p++, q++;
f0101687:	83 c0 01             	add    $0x1,%eax
f010168a:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f010168d:	39 d8                	cmp    %ebx,%eax
f010168f:	74 16                	je     f01016a7 <strncmp+0x31>
f0101691:	0f b6 08             	movzbl (%eax),%ecx
f0101694:	84 c9                	test   %cl,%cl
f0101696:	74 04                	je     f010169c <strncmp+0x26>
f0101698:	3a 0a                	cmp    (%edx),%cl
f010169a:	74 eb                	je     f0101687 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f010169c:	0f b6 00             	movzbl (%eax),%eax
f010169f:	0f b6 12             	movzbl (%edx),%edx
f01016a2:	29 d0                	sub    %edx,%eax
}
f01016a4:	5b                   	pop    %ebx
f01016a5:	5d                   	pop    %ebp
f01016a6:	c3                   	ret    
		return 0;
f01016a7:	b8 00 00 00 00       	mov    $0x0,%eax
f01016ac:	eb f6                	jmp    f01016a4 <strncmp+0x2e>

f01016ae <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01016ae:	55                   	push   %ebp
f01016af:	89 e5                	mov    %esp,%ebp
f01016b1:	8b 45 08             	mov    0x8(%ebp),%eax
f01016b4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01016b8:	0f b6 10             	movzbl (%eax),%edx
f01016bb:	84 d2                	test   %dl,%dl
f01016bd:	74 09                	je     f01016c8 <strchr+0x1a>
		if (*s == c)
f01016bf:	38 ca                	cmp    %cl,%dl
f01016c1:	74 0a                	je     f01016cd <strchr+0x1f>
	for (; *s; s++)
f01016c3:	83 c0 01             	add    $0x1,%eax
f01016c6:	eb f0                	jmp    f01016b8 <strchr+0xa>
			return (char *) s;
	return 0;
f01016c8:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01016cd:	5d                   	pop    %ebp
f01016ce:	c3                   	ret    

f01016cf <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01016cf:	55                   	push   %ebp
f01016d0:	89 e5                	mov    %esp,%ebp
f01016d2:	8b 45 08             	mov    0x8(%ebp),%eax
f01016d5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01016d9:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f01016dc:	38 ca                	cmp    %cl,%dl
f01016de:	74 09                	je     f01016e9 <strfind+0x1a>
f01016e0:	84 d2                	test   %dl,%dl
f01016e2:	74 05                	je     f01016e9 <strfind+0x1a>
	for (; *s; s++)
f01016e4:	83 c0 01             	add    $0x1,%eax
f01016e7:	eb f0                	jmp    f01016d9 <strfind+0xa>
			break;
	return (char *) s;
}
f01016e9:	5d                   	pop    %ebp
f01016ea:	c3                   	ret    

f01016eb <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01016eb:	55                   	push   %ebp
f01016ec:	89 e5                	mov    %esp,%ebp
f01016ee:	57                   	push   %edi
f01016ef:	56                   	push   %esi
f01016f0:	53                   	push   %ebx
f01016f1:	8b 7d 08             	mov    0x8(%ebp),%edi
f01016f4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01016f7:	85 c9                	test   %ecx,%ecx
f01016f9:	74 31                	je     f010172c <memset+0x41>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01016fb:	89 f8                	mov    %edi,%eax
f01016fd:	09 c8                	or     %ecx,%eax
f01016ff:	a8 03                	test   $0x3,%al
f0101701:	75 23                	jne    f0101726 <memset+0x3b>
		c &= 0xFF;
f0101703:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0101707:	89 d3                	mov    %edx,%ebx
f0101709:	c1 e3 08             	shl    $0x8,%ebx
f010170c:	89 d0                	mov    %edx,%eax
f010170e:	c1 e0 18             	shl    $0x18,%eax
f0101711:	89 d6                	mov    %edx,%esi
f0101713:	c1 e6 10             	shl    $0x10,%esi
f0101716:	09 f0                	or     %esi,%eax
f0101718:	09 c2                	or     %eax,%edx
f010171a:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f010171c:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f010171f:	89 d0                	mov    %edx,%eax
f0101721:	fc                   	cld    
f0101722:	f3 ab                	rep stos %eax,%es:(%edi)
f0101724:	eb 06                	jmp    f010172c <memset+0x41>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0101726:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101729:	fc                   	cld    
f010172a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010172c:	89 f8                	mov    %edi,%eax
f010172e:	5b                   	pop    %ebx
f010172f:	5e                   	pop    %esi
f0101730:	5f                   	pop    %edi
f0101731:	5d                   	pop    %ebp
f0101732:	c3                   	ret    

f0101733 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0101733:	55                   	push   %ebp
f0101734:	89 e5                	mov    %esp,%ebp
f0101736:	57                   	push   %edi
f0101737:	56                   	push   %esi
f0101738:	8b 45 08             	mov    0x8(%ebp),%eax
f010173b:	8b 75 0c             	mov    0xc(%ebp),%esi
f010173e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0101741:	39 c6                	cmp    %eax,%esi
f0101743:	73 32                	jae    f0101777 <memmove+0x44>
f0101745:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0101748:	39 c2                	cmp    %eax,%edx
f010174a:	76 2b                	jbe    f0101777 <memmove+0x44>
		s += n;
		d += n;
f010174c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010174f:	89 fe                	mov    %edi,%esi
f0101751:	09 ce                	or     %ecx,%esi
f0101753:	09 d6                	or     %edx,%esi
f0101755:	f7 c6 03 00 00 00    	test   $0x3,%esi
f010175b:	75 0e                	jne    f010176b <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f010175d:	83 ef 04             	sub    $0x4,%edi
f0101760:	8d 72 fc             	lea    -0x4(%edx),%esi
f0101763:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f0101766:	fd                   	std    
f0101767:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0101769:	eb 09                	jmp    f0101774 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f010176b:	83 ef 01             	sub    $0x1,%edi
f010176e:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f0101771:	fd                   	std    
f0101772:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0101774:	fc                   	cld    
f0101775:	eb 1a                	jmp    f0101791 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101777:	89 c2                	mov    %eax,%edx
f0101779:	09 ca                	or     %ecx,%edx
f010177b:	09 f2                	or     %esi,%edx
f010177d:	f6 c2 03             	test   $0x3,%dl
f0101780:	75 0a                	jne    f010178c <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0101782:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f0101785:	89 c7                	mov    %eax,%edi
f0101787:	fc                   	cld    
f0101788:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010178a:	eb 05                	jmp    f0101791 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
f010178c:	89 c7                	mov    %eax,%edi
f010178e:	fc                   	cld    
f010178f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0101791:	5e                   	pop    %esi
f0101792:	5f                   	pop    %edi
f0101793:	5d                   	pop    %ebp
f0101794:	c3                   	ret    

f0101795 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0101795:	55                   	push   %ebp
f0101796:	89 e5                	mov    %esp,%ebp
f0101798:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f010179b:	ff 75 10             	pushl  0x10(%ebp)
f010179e:	ff 75 0c             	pushl  0xc(%ebp)
f01017a1:	ff 75 08             	pushl  0x8(%ebp)
f01017a4:	e8 8a ff ff ff       	call   f0101733 <memmove>
}
f01017a9:	c9                   	leave  
f01017aa:	c3                   	ret    

f01017ab <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01017ab:	55                   	push   %ebp
f01017ac:	89 e5                	mov    %esp,%ebp
f01017ae:	56                   	push   %esi
f01017af:	53                   	push   %ebx
f01017b0:	8b 45 08             	mov    0x8(%ebp),%eax
f01017b3:	8b 55 0c             	mov    0xc(%ebp),%edx
f01017b6:	89 c6                	mov    %eax,%esi
f01017b8:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01017bb:	39 f0                	cmp    %esi,%eax
f01017bd:	74 1c                	je     f01017db <memcmp+0x30>
		if (*s1 != *s2)
f01017bf:	0f b6 08             	movzbl (%eax),%ecx
f01017c2:	0f b6 1a             	movzbl (%edx),%ebx
f01017c5:	38 d9                	cmp    %bl,%cl
f01017c7:	75 08                	jne    f01017d1 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f01017c9:	83 c0 01             	add    $0x1,%eax
f01017cc:	83 c2 01             	add    $0x1,%edx
f01017cf:	eb ea                	jmp    f01017bb <memcmp+0x10>
			return (int) *s1 - (int) *s2;
f01017d1:	0f b6 c1             	movzbl %cl,%eax
f01017d4:	0f b6 db             	movzbl %bl,%ebx
f01017d7:	29 d8                	sub    %ebx,%eax
f01017d9:	eb 05                	jmp    f01017e0 <memcmp+0x35>
	}

	return 0;
f01017db:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01017e0:	5b                   	pop    %ebx
f01017e1:	5e                   	pop    %esi
f01017e2:	5d                   	pop    %ebp
f01017e3:	c3                   	ret    

f01017e4 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01017e4:	55                   	push   %ebp
f01017e5:	89 e5                	mov    %esp,%ebp
f01017e7:	8b 45 08             	mov    0x8(%ebp),%eax
f01017ea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f01017ed:	89 c2                	mov    %eax,%edx
f01017ef:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f01017f2:	39 d0                	cmp    %edx,%eax
f01017f4:	73 09                	jae    f01017ff <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
f01017f6:	38 08                	cmp    %cl,(%eax)
f01017f8:	74 05                	je     f01017ff <memfind+0x1b>
	for (; s < ends; s++)
f01017fa:	83 c0 01             	add    $0x1,%eax
f01017fd:	eb f3                	jmp    f01017f2 <memfind+0xe>
			break;
	return (void *) s;
}
f01017ff:	5d                   	pop    %ebp
f0101800:	c3                   	ret    

f0101801 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0101801:	55                   	push   %ebp
f0101802:	89 e5                	mov    %esp,%ebp
f0101804:	57                   	push   %edi
f0101805:	56                   	push   %esi
f0101806:	53                   	push   %ebx
f0101807:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010180a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010180d:	eb 03                	jmp    f0101812 <strtol+0x11>
		s++;
f010180f:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
f0101812:	0f b6 01             	movzbl (%ecx),%eax
f0101815:	3c 20                	cmp    $0x20,%al
f0101817:	74 f6                	je     f010180f <strtol+0xe>
f0101819:	3c 09                	cmp    $0x9,%al
f010181b:	74 f2                	je     f010180f <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f010181d:	3c 2b                	cmp    $0x2b,%al
f010181f:	74 2a                	je     f010184b <strtol+0x4a>
	int neg = 0;
f0101821:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f0101826:	3c 2d                	cmp    $0x2d,%al
f0101828:	74 2b                	je     f0101855 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010182a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0101830:	75 0f                	jne    f0101841 <strtol+0x40>
f0101832:	80 39 30             	cmpb   $0x30,(%ecx)
f0101835:	74 28                	je     f010185f <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0101837:	85 db                	test   %ebx,%ebx
f0101839:	b8 0a 00 00 00       	mov    $0xa,%eax
f010183e:	0f 44 d8             	cmove  %eax,%ebx
f0101841:	b8 00 00 00 00       	mov    $0x0,%eax
f0101846:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0101849:	eb 50                	jmp    f010189b <strtol+0x9a>
		s++;
f010184b:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
f010184e:	bf 00 00 00 00       	mov    $0x0,%edi
f0101853:	eb d5                	jmp    f010182a <strtol+0x29>
		s++, neg = 1;
f0101855:	83 c1 01             	add    $0x1,%ecx
f0101858:	bf 01 00 00 00       	mov    $0x1,%edi
f010185d:	eb cb                	jmp    f010182a <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010185f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0101863:	74 0e                	je     f0101873 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
f0101865:	85 db                	test   %ebx,%ebx
f0101867:	75 d8                	jne    f0101841 <strtol+0x40>
		s++, base = 8;
f0101869:	83 c1 01             	add    $0x1,%ecx
f010186c:	bb 08 00 00 00       	mov    $0x8,%ebx
f0101871:	eb ce                	jmp    f0101841 <strtol+0x40>
		s += 2, base = 16;
f0101873:	83 c1 02             	add    $0x2,%ecx
f0101876:	bb 10 00 00 00       	mov    $0x10,%ebx
f010187b:	eb c4                	jmp    f0101841 <strtol+0x40>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
f010187d:	8d 72 9f             	lea    -0x61(%edx),%esi
f0101880:	89 f3                	mov    %esi,%ebx
f0101882:	80 fb 19             	cmp    $0x19,%bl
f0101885:	77 29                	ja     f01018b0 <strtol+0xaf>
			dig = *s - 'a' + 10;
f0101887:	0f be d2             	movsbl %dl,%edx
f010188a:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f010188d:	3b 55 10             	cmp    0x10(%ebp),%edx
f0101890:	7d 30                	jge    f01018c2 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
f0101892:	83 c1 01             	add    $0x1,%ecx
f0101895:	0f af 45 10          	imul   0x10(%ebp),%eax
f0101899:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f010189b:	0f b6 11             	movzbl (%ecx),%edx
f010189e:	8d 72 d0             	lea    -0x30(%edx),%esi
f01018a1:	89 f3                	mov    %esi,%ebx
f01018a3:	80 fb 09             	cmp    $0x9,%bl
f01018a6:	77 d5                	ja     f010187d <strtol+0x7c>
			dig = *s - '0';
f01018a8:	0f be d2             	movsbl %dl,%edx
f01018ab:	83 ea 30             	sub    $0x30,%edx
f01018ae:	eb dd                	jmp    f010188d <strtol+0x8c>
		else if (*s >= 'A' && *s <= 'Z')
f01018b0:	8d 72 bf             	lea    -0x41(%edx),%esi
f01018b3:	89 f3                	mov    %esi,%ebx
f01018b5:	80 fb 19             	cmp    $0x19,%bl
f01018b8:	77 08                	ja     f01018c2 <strtol+0xc1>
			dig = *s - 'A' + 10;
f01018ba:	0f be d2             	movsbl %dl,%edx
f01018bd:	83 ea 37             	sub    $0x37,%edx
f01018c0:	eb cb                	jmp    f010188d <strtol+0x8c>
		// we don't properly detect overflow!
	}

	if (endptr)
f01018c2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01018c6:	74 05                	je     f01018cd <strtol+0xcc>
		*endptr = (char *) s;
f01018c8:	8b 75 0c             	mov    0xc(%ebp),%esi
f01018cb:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f01018cd:	89 c2                	mov    %eax,%edx
f01018cf:	f7 da                	neg    %edx
f01018d1:	85 ff                	test   %edi,%edi
f01018d3:	0f 45 c2             	cmovne %edx,%eax
}
f01018d6:	5b                   	pop    %ebx
f01018d7:	5e                   	pop    %esi
f01018d8:	5f                   	pop    %edi
f01018d9:	5d                   	pop    %ebp
f01018da:	c3                   	ret    
f01018db:	66 90                	xchg   %ax,%ax
f01018dd:	66 90                	xchg   %ax,%ax
f01018df:	90                   	nop

f01018e0 <__udivdi3>:
f01018e0:	f3 0f 1e fb          	endbr32 
f01018e4:	55                   	push   %ebp
f01018e5:	57                   	push   %edi
f01018e6:	56                   	push   %esi
f01018e7:	53                   	push   %ebx
f01018e8:	83 ec 1c             	sub    $0x1c,%esp
f01018eb:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f01018ef:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f01018f3:	8b 74 24 34          	mov    0x34(%esp),%esi
f01018f7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f01018fb:	85 d2                	test   %edx,%edx
f01018fd:	75 49                	jne    f0101948 <__udivdi3+0x68>
f01018ff:	39 f3                	cmp    %esi,%ebx
f0101901:	76 15                	jbe    f0101918 <__udivdi3+0x38>
f0101903:	31 ff                	xor    %edi,%edi
f0101905:	89 e8                	mov    %ebp,%eax
f0101907:	89 f2                	mov    %esi,%edx
f0101909:	f7 f3                	div    %ebx
f010190b:	89 fa                	mov    %edi,%edx
f010190d:	83 c4 1c             	add    $0x1c,%esp
f0101910:	5b                   	pop    %ebx
f0101911:	5e                   	pop    %esi
f0101912:	5f                   	pop    %edi
f0101913:	5d                   	pop    %ebp
f0101914:	c3                   	ret    
f0101915:	8d 76 00             	lea    0x0(%esi),%esi
f0101918:	89 d9                	mov    %ebx,%ecx
f010191a:	85 db                	test   %ebx,%ebx
f010191c:	75 0b                	jne    f0101929 <__udivdi3+0x49>
f010191e:	b8 01 00 00 00       	mov    $0x1,%eax
f0101923:	31 d2                	xor    %edx,%edx
f0101925:	f7 f3                	div    %ebx
f0101927:	89 c1                	mov    %eax,%ecx
f0101929:	31 d2                	xor    %edx,%edx
f010192b:	89 f0                	mov    %esi,%eax
f010192d:	f7 f1                	div    %ecx
f010192f:	89 c6                	mov    %eax,%esi
f0101931:	89 e8                	mov    %ebp,%eax
f0101933:	89 f7                	mov    %esi,%edi
f0101935:	f7 f1                	div    %ecx
f0101937:	89 fa                	mov    %edi,%edx
f0101939:	83 c4 1c             	add    $0x1c,%esp
f010193c:	5b                   	pop    %ebx
f010193d:	5e                   	pop    %esi
f010193e:	5f                   	pop    %edi
f010193f:	5d                   	pop    %ebp
f0101940:	c3                   	ret    
f0101941:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101948:	39 f2                	cmp    %esi,%edx
f010194a:	77 1c                	ja     f0101968 <__udivdi3+0x88>
f010194c:	0f bd fa             	bsr    %edx,%edi
f010194f:	83 f7 1f             	xor    $0x1f,%edi
f0101952:	75 2c                	jne    f0101980 <__udivdi3+0xa0>
f0101954:	39 f2                	cmp    %esi,%edx
f0101956:	72 06                	jb     f010195e <__udivdi3+0x7e>
f0101958:	31 c0                	xor    %eax,%eax
f010195a:	39 eb                	cmp    %ebp,%ebx
f010195c:	77 ad                	ja     f010190b <__udivdi3+0x2b>
f010195e:	b8 01 00 00 00       	mov    $0x1,%eax
f0101963:	eb a6                	jmp    f010190b <__udivdi3+0x2b>
f0101965:	8d 76 00             	lea    0x0(%esi),%esi
f0101968:	31 ff                	xor    %edi,%edi
f010196a:	31 c0                	xor    %eax,%eax
f010196c:	89 fa                	mov    %edi,%edx
f010196e:	83 c4 1c             	add    $0x1c,%esp
f0101971:	5b                   	pop    %ebx
f0101972:	5e                   	pop    %esi
f0101973:	5f                   	pop    %edi
f0101974:	5d                   	pop    %ebp
f0101975:	c3                   	ret    
f0101976:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f010197d:	8d 76 00             	lea    0x0(%esi),%esi
f0101980:	89 f9                	mov    %edi,%ecx
f0101982:	b8 20 00 00 00       	mov    $0x20,%eax
f0101987:	29 f8                	sub    %edi,%eax
f0101989:	d3 e2                	shl    %cl,%edx
f010198b:	89 54 24 08          	mov    %edx,0x8(%esp)
f010198f:	89 c1                	mov    %eax,%ecx
f0101991:	89 da                	mov    %ebx,%edx
f0101993:	d3 ea                	shr    %cl,%edx
f0101995:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0101999:	09 d1                	or     %edx,%ecx
f010199b:	89 f2                	mov    %esi,%edx
f010199d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01019a1:	89 f9                	mov    %edi,%ecx
f01019a3:	d3 e3                	shl    %cl,%ebx
f01019a5:	89 c1                	mov    %eax,%ecx
f01019a7:	d3 ea                	shr    %cl,%edx
f01019a9:	89 f9                	mov    %edi,%ecx
f01019ab:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01019af:	89 eb                	mov    %ebp,%ebx
f01019b1:	d3 e6                	shl    %cl,%esi
f01019b3:	89 c1                	mov    %eax,%ecx
f01019b5:	d3 eb                	shr    %cl,%ebx
f01019b7:	09 de                	or     %ebx,%esi
f01019b9:	89 f0                	mov    %esi,%eax
f01019bb:	f7 74 24 08          	divl   0x8(%esp)
f01019bf:	89 d6                	mov    %edx,%esi
f01019c1:	89 c3                	mov    %eax,%ebx
f01019c3:	f7 64 24 0c          	mull   0xc(%esp)
f01019c7:	39 d6                	cmp    %edx,%esi
f01019c9:	72 15                	jb     f01019e0 <__udivdi3+0x100>
f01019cb:	89 f9                	mov    %edi,%ecx
f01019cd:	d3 e5                	shl    %cl,%ebp
f01019cf:	39 c5                	cmp    %eax,%ebp
f01019d1:	73 04                	jae    f01019d7 <__udivdi3+0xf7>
f01019d3:	39 d6                	cmp    %edx,%esi
f01019d5:	74 09                	je     f01019e0 <__udivdi3+0x100>
f01019d7:	89 d8                	mov    %ebx,%eax
f01019d9:	31 ff                	xor    %edi,%edi
f01019db:	e9 2b ff ff ff       	jmp    f010190b <__udivdi3+0x2b>
f01019e0:	8d 43 ff             	lea    -0x1(%ebx),%eax
f01019e3:	31 ff                	xor    %edi,%edi
f01019e5:	e9 21 ff ff ff       	jmp    f010190b <__udivdi3+0x2b>
f01019ea:	66 90                	xchg   %ax,%ax
f01019ec:	66 90                	xchg   %ax,%ax
f01019ee:	66 90                	xchg   %ax,%ax

f01019f0 <__umoddi3>:
f01019f0:	f3 0f 1e fb          	endbr32 
f01019f4:	55                   	push   %ebp
f01019f5:	57                   	push   %edi
f01019f6:	56                   	push   %esi
f01019f7:	53                   	push   %ebx
f01019f8:	83 ec 1c             	sub    $0x1c,%esp
f01019fb:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f01019ff:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f0101a03:	8b 74 24 30          	mov    0x30(%esp),%esi
f0101a07:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0101a0b:	89 da                	mov    %ebx,%edx
f0101a0d:	85 c0                	test   %eax,%eax
f0101a0f:	75 3f                	jne    f0101a50 <__umoddi3+0x60>
f0101a11:	39 df                	cmp    %ebx,%edi
f0101a13:	76 13                	jbe    f0101a28 <__umoddi3+0x38>
f0101a15:	89 f0                	mov    %esi,%eax
f0101a17:	f7 f7                	div    %edi
f0101a19:	89 d0                	mov    %edx,%eax
f0101a1b:	31 d2                	xor    %edx,%edx
f0101a1d:	83 c4 1c             	add    $0x1c,%esp
f0101a20:	5b                   	pop    %ebx
f0101a21:	5e                   	pop    %esi
f0101a22:	5f                   	pop    %edi
f0101a23:	5d                   	pop    %ebp
f0101a24:	c3                   	ret    
f0101a25:	8d 76 00             	lea    0x0(%esi),%esi
f0101a28:	89 fd                	mov    %edi,%ebp
f0101a2a:	85 ff                	test   %edi,%edi
f0101a2c:	75 0b                	jne    f0101a39 <__umoddi3+0x49>
f0101a2e:	b8 01 00 00 00       	mov    $0x1,%eax
f0101a33:	31 d2                	xor    %edx,%edx
f0101a35:	f7 f7                	div    %edi
f0101a37:	89 c5                	mov    %eax,%ebp
f0101a39:	89 d8                	mov    %ebx,%eax
f0101a3b:	31 d2                	xor    %edx,%edx
f0101a3d:	f7 f5                	div    %ebp
f0101a3f:	89 f0                	mov    %esi,%eax
f0101a41:	f7 f5                	div    %ebp
f0101a43:	89 d0                	mov    %edx,%eax
f0101a45:	eb d4                	jmp    f0101a1b <__umoddi3+0x2b>
f0101a47:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101a4e:	66 90                	xchg   %ax,%ax
f0101a50:	89 f1                	mov    %esi,%ecx
f0101a52:	39 d8                	cmp    %ebx,%eax
f0101a54:	76 0a                	jbe    f0101a60 <__umoddi3+0x70>
f0101a56:	89 f0                	mov    %esi,%eax
f0101a58:	83 c4 1c             	add    $0x1c,%esp
f0101a5b:	5b                   	pop    %ebx
f0101a5c:	5e                   	pop    %esi
f0101a5d:	5f                   	pop    %edi
f0101a5e:	5d                   	pop    %ebp
f0101a5f:	c3                   	ret    
f0101a60:	0f bd e8             	bsr    %eax,%ebp
f0101a63:	83 f5 1f             	xor    $0x1f,%ebp
f0101a66:	75 20                	jne    f0101a88 <__umoddi3+0x98>
f0101a68:	39 d8                	cmp    %ebx,%eax
f0101a6a:	0f 82 b0 00 00 00    	jb     f0101b20 <__umoddi3+0x130>
f0101a70:	39 f7                	cmp    %esi,%edi
f0101a72:	0f 86 a8 00 00 00    	jbe    f0101b20 <__umoddi3+0x130>
f0101a78:	89 c8                	mov    %ecx,%eax
f0101a7a:	83 c4 1c             	add    $0x1c,%esp
f0101a7d:	5b                   	pop    %ebx
f0101a7e:	5e                   	pop    %esi
f0101a7f:	5f                   	pop    %edi
f0101a80:	5d                   	pop    %ebp
f0101a81:	c3                   	ret    
f0101a82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101a88:	89 e9                	mov    %ebp,%ecx
f0101a8a:	ba 20 00 00 00       	mov    $0x20,%edx
f0101a8f:	29 ea                	sub    %ebp,%edx
f0101a91:	d3 e0                	shl    %cl,%eax
f0101a93:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101a97:	89 d1                	mov    %edx,%ecx
f0101a99:	89 f8                	mov    %edi,%eax
f0101a9b:	d3 e8                	shr    %cl,%eax
f0101a9d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0101aa1:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101aa5:	8b 54 24 04          	mov    0x4(%esp),%edx
f0101aa9:	09 c1                	or     %eax,%ecx
f0101aab:	89 d8                	mov    %ebx,%eax
f0101aad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101ab1:	89 e9                	mov    %ebp,%ecx
f0101ab3:	d3 e7                	shl    %cl,%edi
f0101ab5:	89 d1                	mov    %edx,%ecx
f0101ab7:	d3 e8                	shr    %cl,%eax
f0101ab9:	89 e9                	mov    %ebp,%ecx
f0101abb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0101abf:	d3 e3                	shl    %cl,%ebx
f0101ac1:	89 c7                	mov    %eax,%edi
f0101ac3:	89 d1                	mov    %edx,%ecx
f0101ac5:	89 f0                	mov    %esi,%eax
f0101ac7:	d3 e8                	shr    %cl,%eax
f0101ac9:	89 e9                	mov    %ebp,%ecx
f0101acb:	89 fa                	mov    %edi,%edx
f0101acd:	d3 e6                	shl    %cl,%esi
f0101acf:	09 d8                	or     %ebx,%eax
f0101ad1:	f7 74 24 08          	divl   0x8(%esp)
f0101ad5:	89 d1                	mov    %edx,%ecx
f0101ad7:	89 f3                	mov    %esi,%ebx
f0101ad9:	f7 64 24 0c          	mull   0xc(%esp)
f0101add:	89 c6                	mov    %eax,%esi
f0101adf:	89 d7                	mov    %edx,%edi
f0101ae1:	39 d1                	cmp    %edx,%ecx
f0101ae3:	72 06                	jb     f0101aeb <__umoddi3+0xfb>
f0101ae5:	75 10                	jne    f0101af7 <__umoddi3+0x107>
f0101ae7:	39 c3                	cmp    %eax,%ebx
f0101ae9:	73 0c                	jae    f0101af7 <__umoddi3+0x107>
f0101aeb:	2b 44 24 0c          	sub    0xc(%esp),%eax
f0101aef:	1b 54 24 08          	sbb    0x8(%esp),%edx
f0101af3:	89 d7                	mov    %edx,%edi
f0101af5:	89 c6                	mov    %eax,%esi
f0101af7:	89 ca                	mov    %ecx,%edx
f0101af9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0101afe:	29 f3                	sub    %esi,%ebx
f0101b00:	19 fa                	sbb    %edi,%edx
f0101b02:	89 d0                	mov    %edx,%eax
f0101b04:	d3 e0                	shl    %cl,%eax
f0101b06:	89 e9                	mov    %ebp,%ecx
f0101b08:	d3 eb                	shr    %cl,%ebx
f0101b0a:	d3 ea                	shr    %cl,%edx
f0101b0c:	09 d8                	or     %ebx,%eax
f0101b0e:	83 c4 1c             	add    $0x1c,%esp
f0101b11:	5b                   	pop    %ebx
f0101b12:	5e                   	pop    %esi
f0101b13:	5f                   	pop    %edi
f0101b14:	5d                   	pop    %ebp
f0101b15:	c3                   	ret    
f0101b16:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101b1d:	8d 76 00             	lea    0x0(%esi),%esi
f0101b20:	89 da                	mov    %ebx,%edx
f0101b22:	29 fe                	sub    %edi,%esi
f0101b24:	19 c2                	sbb    %eax,%edx
f0101b26:	89 f1                	mov    %esi,%ecx
f0101b28:	89 c8                	mov    %ecx,%eax
f0101b2a:	e9 4b ff ff ff       	jmp    f0101a7a <__umoddi3+0x8a>
