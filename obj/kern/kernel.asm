
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
f0100015:	b8 00 90 11 00       	mov    $0x119000,%eax
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
f0100034:	bc 00 70 11 f0       	mov    $0xf0117000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 68 00 00 00       	call   f01000a6 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <test_backtrace>:
#include <kern/pmap.h>
#include <kern/kclock.h>
// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	56                   	push   %esi
f0100044:	53                   	push   %ebx
f0100045:	e8 77 01 00 00       	call   f01001c1 <__x86.get_pc_thunk.bx>
f010004a:	81 c3 1e a0 01 00    	add    $0x1a01e,%ebx
f0100050:	8b 75 08             	mov    0x8(%ebp),%esi
	cprintf("entering test_backtrace %d\n", x);
f0100053:	83 ec 08             	sub    $0x8,%esp
f0100056:	56                   	push   %esi
f0100057:	8d 83 58 9f fe ff    	lea    -0x160a8(%ebx),%eax
f010005d:	50                   	push   %eax
f010005e:	e8 fb 2e 00 00       	call   f0102f5e <cprintf>
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
f010007d:	8d 83 74 9f fe ff    	lea    -0x1608c(%ebx),%eax
f0100083:	50                   	push   %eax
f0100084:	e8 d5 2e 00 00       	call   f0102f5e <cprintf>
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
f010009c:	e8 cd 07 00 00       	call   f010086e <mon_backtrace>
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
f01000ad:	e8 0f 01 00 00       	call   f01001c1 <__x86.get_pc_thunk.bx>
f01000b2:	81 c3 b6 9f 01 00    	add    $0x19fb6,%ebx
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f01000b8:	c7 c2 80 a0 11 f0    	mov    $0xf011a080,%edx
f01000be:	c7 c0 e0 a6 11 f0    	mov    $0xf011a6e0,%eax
f01000c4:	29 d0                	sub    %edx,%eax
f01000c6:	50                   	push   %eax
f01000c7:	6a 00                	push   $0x0
f01000c9:	52                   	push   %edx
f01000ca:	e8 b0 3a 00 00       	call   f0103b7f <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000cf:	e8 15 05 00 00       	call   f01005e9 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000d4:	83 c4 08             	add    $0x8,%esp
f01000d7:	68 ac 1a 00 00       	push   $0x1aac
f01000dc:	8d 83 8f 9f fe ff    	lea    -0x16071(%ebx),%eax
f01000e2:	50                   	push   %eax
f01000e3:	e8 76 2e 00 00       	call   f0102f5e <cprintf>

	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f01000e8:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f01000ef:	e8 4c ff ff ff       	call   f0100040 <test_backtrace>
	// Lab 2 memory management initialization functions
	mem_init();
f01000f4:	e8 6d 12 00 00       	call   f0101366 <mem_init>
f01000f9:	83 c4 10             	add    $0x10,%esp

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f01000fc:	83 ec 0c             	sub    $0xc,%esp
f01000ff:	6a 00                	push   $0x0
f0100101:	e8 0a 08 00 00       	call   f0100910 <monitor>
f0100106:	83 c4 10             	add    $0x10,%esp
f0100109:	eb f1                	jmp    f01000fc <i386_init+0x56>

f010010b <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f010010b:	55                   	push   %ebp
f010010c:	89 e5                	mov    %esp,%ebp
f010010e:	57                   	push   %edi
f010010f:	56                   	push   %esi
f0100110:	53                   	push   %ebx
f0100111:	83 ec 0c             	sub    $0xc,%esp
f0100114:	e8 a8 00 00 00       	call   f01001c1 <__x86.get_pc_thunk.bx>
f0100119:	81 c3 4f 9f 01 00    	add    $0x19f4f,%ebx
f010011f:	8b 7d 10             	mov    0x10(%ebp),%edi
	va_list ap;

	if (panicstr)
f0100122:	c7 c0 e4 a6 11 f0    	mov    $0xf011a6e4,%eax
f0100128:	83 38 00             	cmpl   $0x0,(%eax)
f010012b:	74 0f                	je     f010013c <_panic+0x31>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010012d:	83 ec 0c             	sub    $0xc,%esp
f0100130:	6a 00                	push   $0x0
f0100132:	e8 d9 07 00 00       	call   f0100910 <monitor>
f0100137:	83 c4 10             	add    $0x10,%esp
f010013a:	eb f1                	jmp    f010012d <_panic+0x22>
	panicstr = fmt;
f010013c:	89 38                	mov    %edi,(%eax)
	asm volatile("cli; cld");
f010013e:	fa                   	cli    
f010013f:	fc                   	cld    
	va_start(ap, fmt);
f0100140:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel panic at %s:%d: ", file, line);
f0100143:	83 ec 04             	sub    $0x4,%esp
f0100146:	ff 75 0c             	pushl  0xc(%ebp)
f0100149:	ff 75 08             	pushl  0x8(%ebp)
f010014c:	8d 83 aa 9f fe ff    	lea    -0x16056(%ebx),%eax
f0100152:	50                   	push   %eax
f0100153:	e8 06 2e 00 00       	call   f0102f5e <cprintf>
	vcprintf(fmt, ap);
f0100158:	83 c4 08             	add    $0x8,%esp
f010015b:	56                   	push   %esi
f010015c:	57                   	push   %edi
f010015d:	e8 c5 2d 00 00       	call   f0102f27 <vcprintf>
	cprintf("\n");
f0100162:	8d 83 d1 ae fe ff    	lea    -0x1512f(%ebx),%eax
f0100168:	89 04 24             	mov    %eax,(%esp)
f010016b:	e8 ee 2d 00 00       	call   f0102f5e <cprintf>
f0100170:	83 c4 10             	add    $0x10,%esp
f0100173:	eb b8                	jmp    f010012d <_panic+0x22>

f0100175 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100175:	55                   	push   %ebp
f0100176:	89 e5                	mov    %esp,%ebp
f0100178:	56                   	push   %esi
f0100179:	53                   	push   %ebx
f010017a:	e8 42 00 00 00       	call   f01001c1 <__x86.get_pc_thunk.bx>
f010017f:	81 c3 e9 9e 01 00    	add    $0x19ee9,%ebx
	va_list ap;

	va_start(ap, fmt);
f0100185:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel warning at %s:%d: ", file, line);
f0100188:	83 ec 04             	sub    $0x4,%esp
f010018b:	ff 75 0c             	pushl  0xc(%ebp)
f010018e:	ff 75 08             	pushl  0x8(%ebp)
f0100191:	8d 83 c2 9f fe ff    	lea    -0x1603e(%ebx),%eax
f0100197:	50                   	push   %eax
f0100198:	e8 c1 2d 00 00       	call   f0102f5e <cprintf>
	vcprintf(fmt, ap);
f010019d:	83 c4 08             	add    $0x8,%esp
f01001a0:	56                   	push   %esi
f01001a1:	ff 75 10             	pushl  0x10(%ebp)
f01001a4:	e8 7e 2d 00 00       	call   f0102f27 <vcprintf>
	cprintf("\n");
f01001a9:	8d 83 d1 ae fe ff    	lea    -0x1512f(%ebx),%eax
f01001af:	89 04 24             	mov    %eax,(%esp)
f01001b2:	e8 a7 2d 00 00       	call   f0102f5e <cprintf>
	va_end(ap);
}
f01001b7:	83 c4 10             	add    $0x10,%esp
f01001ba:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01001bd:	5b                   	pop    %ebx
f01001be:	5e                   	pop    %esi
f01001bf:	5d                   	pop    %ebp
f01001c0:	c3                   	ret    

f01001c1 <__x86.get_pc_thunk.bx>:
f01001c1:	8b 1c 24             	mov    (%esp),%ebx
f01001c4:	c3                   	ret    

f01001c5 <serial_proc_data>:

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01001c5:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01001ca:	ec                   	in     (%dx),%al
static bool serial_exists;

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01001cb:	a8 01                	test   $0x1,%al
f01001cd:	74 0a                	je     f01001d9 <serial_proc_data+0x14>
f01001cf:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01001d4:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01001d5:	0f b6 c0             	movzbl %al,%eax
f01001d8:	c3                   	ret    
		return -1;
f01001d9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f01001de:	c3                   	ret    

f01001df <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01001df:	55                   	push   %ebp
f01001e0:	89 e5                	mov    %esp,%ebp
f01001e2:	56                   	push   %esi
f01001e3:	53                   	push   %ebx
f01001e4:	e8 d8 ff ff ff       	call   f01001c1 <__x86.get_pc_thunk.bx>
f01001e9:	81 c3 7f 9e 01 00    	add    $0x19e7f,%ebx
f01001ef:	89 c6                	mov    %eax,%esi
	int c;

	while ((c = (*proc)()) != -1) {
f01001f1:	ff d6                	call   *%esi
f01001f3:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001f6:	74 2a                	je     f0100222 <cons_intr+0x43>
		if (c == 0)
f01001f8:	85 c0                	test   %eax,%eax
f01001fa:	74 f5                	je     f01001f1 <cons_intr+0x12>
			continue;
		cons.buf[cons.wpos++] = c;
f01001fc:	8b 8b 3c 02 00 00    	mov    0x23c(%ebx),%ecx
f0100202:	8d 51 01             	lea    0x1(%ecx),%edx
f0100205:	88 84 0b 38 00 00 00 	mov    %al,0x38(%ebx,%ecx,1)
		if (cons.wpos == CONSBUFSIZE)
f010020c:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.wpos = 0;
f0100212:	b8 00 00 00 00       	mov    $0x0,%eax
f0100217:	0f 44 d0             	cmove  %eax,%edx
f010021a:	89 93 3c 02 00 00    	mov    %edx,0x23c(%ebx)
f0100220:	eb cf                	jmp    f01001f1 <cons_intr+0x12>
	}
}
f0100222:	5b                   	pop    %ebx
f0100223:	5e                   	pop    %esi
f0100224:	5d                   	pop    %ebp
f0100225:	c3                   	ret    

f0100226 <kbd_proc_data>:
{
f0100226:	55                   	push   %ebp
f0100227:	89 e5                	mov    %esp,%ebp
f0100229:	56                   	push   %esi
f010022a:	53                   	push   %ebx
f010022b:	e8 91 ff ff ff       	call   f01001c1 <__x86.get_pc_thunk.bx>
f0100230:	81 c3 38 9e 01 00    	add    $0x19e38,%ebx
f0100236:	ba 64 00 00 00       	mov    $0x64,%edx
f010023b:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f010023c:	a8 01                	test   $0x1,%al
f010023e:	0f 84 fb 00 00 00    	je     f010033f <kbd_proc_data+0x119>
	if (stat & KBS_TERR)
f0100244:	a8 20                	test   $0x20,%al
f0100246:	0f 85 fa 00 00 00    	jne    f0100346 <kbd_proc_data+0x120>
f010024c:	ba 60 00 00 00       	mov    $0x60,%edx
f0100251:	ec                   	in     (%dx),%al
f0100252:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f0100254:	3c e0                	cmp    $0xe0,%al
f0100256:	74 64                	je     f01002bc <kbd_proc_data+0x96>
	} else if (data & 0x80) {
f0100258:	84 c0                	test   %al,%al
f010025a:	78 75                	js     f01002d1 <kbd_proc_data+0xab>
	} else if (shift & E0ESC) {
f010025c:	8b 8b 18 00 00 00    	mov    0x18(%ebx),%ecx
f0100262:	f6 c1 40             	test   $0x40,%cl
f0100265:	74 0e                	je     f0100275 <kbd_proc_data+0x4f>
		data |= 0x80;
f0100267:	83 c8 80             	or     $0xffffff80,%eax
f010026a:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f010026c:	83 e1 bf             	and    $0xffffffbf,%ecx
f010026f:	89 8b 18 00 00 00    	mov    %ecx,0x18(%ebx)
	shift |= shiftcode[data];
f0100275:	0f b6 d2             	movzbl %dl,%edx
f0100278:	0f b6 84 13 18 a1 fe 	movzbl -0x15ee8(%ebx,%edx,1),%eax
f010027f:	ff 
f0100280:	0b 83 18 00 00 00    	or     0x18(%ebx),%eax
	shift ^= togglecode[data];
f0100286:	0f b6 8c 13 18 a0 fe 	movzbl -0x15fe8(%ebx,%edx,1),%ecx
f010028d:	ff 
f010028e:	31 c8                	xor    %ecx,%eax
f0100290:	89 83 18 00 00 00    	mov    %eax,0x18(%ebx)
	c = charcode[shift & (CTL | SHIFT)][data];
f0100296:	89 c1                	mov    %eax,%ecx
f0100298:	83 e1 03             	and    $0x3,%ecx
f010029b:	8b 8c 8b 98 ff ff ff 	mov    -0x68(%ebx,%ecx,4),%ecx
f01002a2:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f01002a6:	0f b6 f2             	movzbl %dl,%esi
	if (shift & CAPSLOCK) {
f01002a9:	a8 08                	test   $0x8,%al
f01002ab:	74 65                	je     f0100312 <kbd_proc_data+0xec>
		if ('a' <= c && c <= 'z')
f01002ad:	89 f2                	mov    %esi,%edx
f01002af:	8d 4e 9f             	lea    -0x61(%esi),%ecx
f01002b2:	83 f9 19             	cmp    $0x19,%ecx
f01002b5:	77 4f                	ja     f0100306 <kbd_proc_data+0xe0>
			c += 'A' - 'a';
f01002b7:	83 ee 20             	sub    $0x20,%esi
f01002ba:	eb 0c                	jmp    f01002c8 <kbd_proc_data+0xa2>
		shift |= E0ESC;
f01002bc:	83 8b 18 00 00 00 40 	orl    $0x40,0x18(%ebx)
		return 0;
f01002c3:	be 00 00 00 00       	mov    $0x0,%esi
}
f01002c8:	89 f0                	mov    %esi,%eax
f01002ca:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01002cd:	5b                   	pop    %ebx
f01002ce:	5e                   	pop    %esi
f01002cf:	5d                   	pop    %ebp
f01002d0:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f01002d1:	8b 8b 18 00 00 00    	mov    0x18(%ebx),%ecx
f01002d7:	89 ce                	mov    %ecx,%esi
f01002d9:	83 e6 40             	and    $0x40,%esi
f01002dc:	83 e0 7f             	and    $0x7f,%eax
f01002df:	85 f6                	test   %esi,%esi
f01002e1:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01002e4:	0f b6 d2             	movzbl %dl,%edx
f01002e7:	0f b6 84 13 18 a1 fe 	movzbl -0x15ee8(%ebx,%edx,1),%eax
f01002ee:	ff 
f01002ef:	83 c8 40             	or     $0x40,%eax
f01002f2:	0f b6 c0             	movzbl %al,%eax
f01002f5:	f7 d0                	not    %eax
f01002f7:	21 c8                	and    %ecx,%eax
f01002f9:	89 83 18 00 00 00    	mov    %eax,0x18(%ebx)
		return 0;
f01002ff:	be 00 00 00 00       	mov    $0x0,%esi
f0100304:	eb c2                	jmp    f01002c8 <kbd_proc_data+0xa2>
		else if ('A' <= c && c <= 'Z')
f0100306:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f0100309:	8d 4e 20             	lea    0x20(%esi),%ecx
f010030c:	83 fa 1a             	cmp    $0x1a,%edx
f010030f:	0f 42 f1             	cmovb  %ecx,%esi
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100312:	f7 d0                	not    %eax
f0100314:	a8 06                	test   $0x6,%al
f0100316:	75 b0                	jne    f01002c8 <kbd_proc_data+0xa2>
f0100318:	81 fe e9 00 00 00    	cmp    $0xe9,%esi
f010031e:	75 a8                	jne    f01002c8 <kbd_proc_data+0xa2>
		cprintf("Rebooting!\n");
f0100320:	83 ec 0c             	sub    $0xc,%esp
f0100323:	8d 83 dc 9f fe ff    	lea    -0x16024(%ebx),%eax
f0100329:	50                   	push   %eax
f010032a:	e8 2f 2c 00 00       	call   f0102f5e <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010032f:	b8 03 00 00 00       	mov    $0x3,%eax
f0100334:	ba 92 00 00 00       	mov    $0x92,%edx
f0100339:	ee                   	out    %al,(%dx)
f010033a:	83 c4 10             	add    $0x10,%esp
f010033d:	eb 89                	jmp    f01002c8 <kbd_proc_data+0xa2>
		return -1;
f010033f:	be ff ff ff ff       	mov    $0xffffffff,%esi
f0100344:	eb 82                	jmp    f01002c8 <kbd_proc_data+0xa2>
		return -1;
f0100346:	be ff ff ff ff       	mov    $0xffffffff,%esi
f010034b:	e9 78 ff ff ff       	jmp    f01002c8 <kbd_proc_data+0xa2>

f0100350 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100350:	55                   	push   %ebp
f0100351:	89 e5                	mov    %esp,%ebp
f0100353:	57                   	push   %edi
f0100354:	56                   	push   %esi
f0100355:	53                   	push   %ebx
f0100356:	83 ec 1c             	sub    $0x1c,%esp
f0100359:	e8 63 fe ff ff       	call   f01001c1 <__x86.get_pc_thunk.bx>
f010035e:	81 c3 0a 9d 01 00    	add    $0x19d0a,%ebx
f0100364:	89 c7                	mov    %eax,%edi
	for (i = 0;
f0100366:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010036b:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100370:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100375:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100376:	a8 20                	test   $0x20,%al
f0100378:	75 13                	jne    f010038d <cons_putc+0x3d>
f010037a:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f0100380:	7f 0b                	jg     f010038d <cons_putc+0x3d>
f0100382:	89 ca                	mov    %ecx,%edx
f0100384:	ec                   	in     (%dx),%al
f0100385:	ec                   	in     (%dx),%al
f0100386:	ec                   	in     (%dx),%al
f0100387:	ec                   	in     (%dx),%al
	     i++)
f0100388:	83 c6 01             	add    $0x1,%esi
f010038b:	eb e3                	jmp    f0100370 <cons_putc+0x20>
	outb(COM1 + COM_TX, c);
f010038d:	89 f8                	mov    %edi,%eax
f010038f:	88 45 e7             	mov    %al,-0x19(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100392:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100397:	ee                   	out    %al,(%dx)
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100398:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010039d:	b9 84 00 00 00       	mov    $0x84,%ecx
f01003a2:	ba 79 03 00 00       	mov    $0x379,%edx
f01003a7:	ec                   	in     (%dx),%al
f01003a8:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f01003ae:	7f 0f                	jg     f01003bf <cons_putc+0x6f>
f01003b0:	84 c0                	test   %al,%al
f01003b2:	78 0b                	js     f01003bf <cons_putc+0x6f>
f01003b4:	89 ca                	mov    %ecx,%edx
f01003b6:	ec                   	in     (%dx),%al
f01003b7:	ec                   	in     (%dx),%al
f01003b8:	ec                   	in     (%dx),%al
f01003b9:	ec                   	in     (%dx),%al
f01003ba:	83 c6 01             	add    $0x1,%esi
f01003bd:	eb e3                	jmp    f01003a2 <cons_putc+0x52>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003bf:	ba 78 03 00 00       	mov    $0x378,%edx
f01003c4:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f01003c8:	ee                   	out    %al,(%dx)
f01003c9:	ba 7a 03 00 00       	mov    $0x37a,%edx
f01003ce:	b8 0d 00 00 00       	mov    $0xd,%eax
f01003d3:	ee                   	out    %al,(%dx)
f01003d4:	b8 08 00 00 00       	mov    $0x8,%eax
f01003d9:	ee                   	out    %al,(%dx)
	if (!(c & ~0xFF))
f01003da:	89 fa                	mov    %edi,%edx
f01003dc:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f01003e2:	89 f8                	mov    %edi,%eax
f01003e4:	80 cc 07             	or     $0x7,%ah
f01003e7:	85 d2                	test   %edx,%edx
f01003e9:	0f 44 f8             	cmove  %eax,%edi
	switch (c & 0xff) {
f01003ec:	89 f8                	mov    %edi,%eax
f01003ee:	0f b6 c0             	movzbl %al,%eax
f01003f1:	83 f8 09             	cmp    $0x9,%eax
f01003f4:	0f 84 b4 00 00 00    	je     f01004ae <cons_putc+0x15e>
f01003fa:	7e 74                	jle    f0100470 <cons_putc+0x120>
f01003fc:	83 f8 0a             	cmp    $0xa,%eax
f01003ff:	0f 84 9c 00 00 00    	je     f01004a1 <cons_putc+0x151>
f0100405:	83 f8 0d             	cmp    $0xd,%eax
f0100408:	0f 85 d7 00 00 00    	jne    f01004e5 <cons_putc+0x195>
		crt_pos -= (crt_pos % CRT_COLS);
f010040e:	0f b7 83 40 02 00 00 	movzwl 0x240(%ebx),%eax
f0100415:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f010041b:	c1 e8 16             	shr    $0x16,%eax
f010041e:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100421:	c1 e0 04             	shl    $0x4,%eax
f0100424:	66 89 83 40 02 00 00 	mov    %ax,0x240(%ebx)
	if (crt_pos >= CRT_SIZE) {
f010042b:	66 81 bb 40 02 00 00 	cmpw   $0x7cf,0x240(%ebx)
f0100432:	cf 07 
f0100434:	0f 87 ce 00 00 00    	ja     f0100508 <cons_putc+0x1b8>
	outb(addr_6845, 14);
f010043a:	8b 8b 48 02 00 00    	mov    0x248(%ebx),%ecx
f0100440:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100445:	89 ca                	mov    %ecx,%edx
f0100447:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100448:	0f b7 9b 40 02 00 00 	movzwl 0x240(%ebx),%ebx
f010044f:	8d 71 01             	lea    0x1(%ecx),%esi
f0100452:	89 d8                	mov    %ebx,%eax
f0100454:	66 c1 e8 08          	shr    $0x8,%ax
f0100458:	89 f2                	mov    %esi,%edx
f010045a:	ee                   	out    %al,(%dx)
f010045b:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100460:	89 ca                	mov    %ecx,%edx
f0100462:	ee                   	out    %al,(%dx)
f0100463:	89 d8                	mov    %ebx,%eax
f0100465:	89 f2                	mov    %esi,%edx
f0100467:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100468:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010046b:	5b                   	pop    %ebx
f010046c:	5e                   	pop    %esi
f010046d:	5f                   	pop    %edi
f010046e:	5d                   	pop    %ebp
f010046f:	c3                   	ret    
	switch (c & 0xff) {
f0100470:	83 f8 08             	cmp    $0x8,%eax
f0100473:	75 70                	jne    f01004e5 <cons_putc+0x195>
		if (crt_pos > 0) {
f0100475:	0f b7 83 40 02 00 00 	movzwl 0x240(%ebx),%eax
f010047c:	66 85 c0             	test   %ax,%ax
f010047f:	74 b9                	je     f010043a <cons_putc+0xea>
			crt_pos--;
f0100481:	83 e8 01             	sub    $0x1,%eax
f0100484:	66 89 83 40 02 00 00 	mov    %ax,0x240(%ebx)
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010048b:	0f b7 c0             	movzwl %ax,%eax
f010048e:	89 fa                	mov    %edi,%edx
f0100490:	b2 00                	mov    $0x0,%dl
f0100492:	83 ca 20             	or     $0x20,%edx
f0100495:	8b 8b 44 02 00 00    	mov    0x244(%ebx),%ecx
f010049b:	66 89 14 41          	mov    %dx,(%ecx,%eax,2)
f010049f:	eb 8a                	jmp    f010042b <cons_putc+0xdb>
		crt_pos += CRT_COLS;
f01004a1:	66 83 83 40 02 00 00 	addw   $0x50,0x240(%ebx)
f01004a8:	50 
f01004a9:	e9 60 ff ff ff       	jmp    f010040e <cons_putc+0xbe>
		cons_putc(' ');
f01004ae:	b8 20 00 00 00       	mov    $0x20,%eax
f01004b3:	e8 98 fe ff ff       	call   f0100350 <cons_putc>
		cons_putc(' ');
f01004b8:	b8 20 00 00 00       	mov    $0x20,%eax
f01004bd:	e8 8e fe ff ff       	call   f0100350 <cons_putc>
		cons_putc(' ');
f01004c2:	b8 20 00 00 00       	mov    $0x20,%eax
f01004c7:	e8 84 fe ff ff       	call   f0100350 <cons_putc>
		cons_putc(' ');
f01004cc:	b8 20 00 00 00       	mov    $0x20,%eax
f01004d1:	e8 7a fe ff ff       	call   f0100350 <cons_putc>
		cons_putc(' ');
f01004d6:	b8 20 00 00 00       	mov    $0x20,%eax
f01004db:	e8 70 fe ff ff       	call   f0100350 <cons_putc>
f01004e0:	e9 46 ff ff ff       	jmp    f010042b <cons_putc+0xdb>
		crt_buf[crt_pos++] = c;		/* write the character */
f01004e5:	0f b7 83 40 02 00 00 	movzwl 0x240(%ebx),%eax
f01004ec:	8d 50 01             	lea    0x1(%eax),%edx
f01004ef:	66 89 93 40 02 00 00 	mov    %dx,0x240(%ebx)
f01004f6:	0f b7 c0             	movzwl %ax,%eax
f01004f9:	8b 93 44 02 00 00    	mov    0x244(%ebx),%edx
f01004ff:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100503:	e9 23 ff ff ff       	jmp    f010042b <cons_putc+0xdb>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100508:	8b 83 44 02 00 00    	mov    0x244(%ebx),%eax
f010050e:	83 ec 04             	sub    $0x4,%esp
f0100511:	68 00 0f 00 00       	push   $0xf00
f0100516:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010051c:	52                   	push   %edx
f010051d:	50                   	push   %eax
f010051e:	e8 a4 36 00 00       	call   f0103bc7 <memmove>
			crt_buf[i] = 0x0700 | ' ';
f0100523:	8b 93 44 02 00 00    	mov    0x244(%ebx),%edx
f0100529:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f010052f:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100535:	83 c4 10             	add    $0x10,%esp
f0100538:	66 c7 00 20 07       	movw   $0x720,(%eax)
f010053d:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100540:	39 d0                	cmp    %edx,%eax
f0100542:	75 f4                	jne    f0100538 <cons_putc+0x1e8>
		crt_pos -= CRT_COLS;
f0100544:	66 83 ab 40 02 00 00 	subw   $0x50,0x240(%ebx)
f010054b:	50 
f010054c:	e9 e9 fe ff ff       	jmp    f010043a <cons_putc+0xea>

f0100551 <serial_intr>:
{
f0100551:	e8 dc 01 00 00       	call   f0100732 <__x86.get_pc_thunk.ax>
f0100556:	05 12 9b 01 00       	add    $0x19b12,%eax
	if (serial_exists)
f010055b:	80 b8 4c 02 00 00 00 	cmpb   $0x0,0x24c(%eax)
f0100562:	75 01                	jne    f0100565 <serial_intr+0x14>
f0100564:	c3                   	ret    
{
f0100565:	55                   	push   %ebp
f0100566:	89 e5                	mov    %esp,%ebp
f0100568:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f010056b:	8d 80 5d 61 fe ff    	lea    -0x19ea3(%eax),%eax
f0100571:	e8 69 fc ff ff       	call   f01001df <cons_intr>
}
f0100576:	c9                   	leave  
f0100577:	c3                   	ret    

f0100578 <kbd_intr>:
{
f0100578:	55                   	push   %ebp
f0100579:	89 e5                	mov    %esp,%ebp
f010057b:	83 ec 08             	sub    $0x8,%esp
f010057e:	e8 af 01 00 00       	call   f0100732 <__x86.get_pc_thunk.ax>
f0100583:	05 e5 9a 01 00       	add    $0x19ae5,%eax
	cons_intr(kbd_proc_data);
f0100588:	8d 80 be 61 fe ff    	lea    -0x19e42(%eax),%eax
f010058e:	e8 4c fc ff ff       	call   f01001df <cons_intr>
}
f0100593:	c9                   	leave  
f0100594:	c3                   	ret    

f0100595 <cons_getc>:
{
f0100595:	55                   	push   %ebp
f0100596:	89 e5                	mov    %esp,%ebp
f0100598:	53                   	push   %ebx
f0100599:	83 ec 04             	sub    $0x4,%esp
f010059c:	e8 20 fc ff ff       	call   f01001c1 <__x86.get_pc_thunk.bx>
f01005a1:	81 c3 c7 9a 01 00    	add    $0x19ac7,%ebx
	serial_intr();
f01005a7:	e8 a5 ff ff ff       	call   f0100551 <serial_intr>
	kbd_intr();
f01005ac:	e8 c7 ff ff ff       	call   f0100578 <kbd_intr>
	if (cons.rpos != cons.wpos) {
f01005b1:	8b 8b 38 02 00 00    	mov    0x238(%ebx),%ecx
	return 0;
f01005b7:	b8 00 00 00 00       	mov    $0x0,%eax
	if (cons.rpos != cons.wpos) {
f01005bc:	3b 8b 3c 02 00 00    	cmp    0x23c(%ebx),%ecx
f01005c2:	74 1f                	je     f01005e3 <cons_getc+0x4e>
		c = cons.buf[cons.rpos++];
f01005c4:	8d 51 01             	lea    0x1(%ecx),%edx
f01005c7:	0f b6 84 0b 38 00 00 	movzbl 0x38(%ebx,%ecx,1),%eax
f01005ce:	00 
		if (cons.rpos == CONSBUFSIZE)
f01005cf:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.rpos = 0;
f01005d5:	b9 00 00 00 00       	mov    $0x0,%ecx
f01005da:	0f 44 d1             	cmove  %ecx,%edx
f01005dd:	89 93 38 02 00 00    	mov    %edx,0x238(%ebx)
}
f01005e3:	83 c4 04             	add    $0x4,%esp
f01005e6:	5b                   	pop    %ebx
f01005e7:	5d                   	pop    %ebp
f01005e8:	c3                   	ret    

f01005e9 <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f01005e9:	55                   	push   %ebp
f01005ea:	89 e5                	mov    %esp,%ebp
f01005ec:	57                   	push   %edi
f01005ed:	56                   	push   %esi
f01005ee:	53                   	push   %ebx
f01005ef:	83 ec 1c             	sub    $0x1c,%esp
f01005f2:	e8 ca fb ff ff       	call   f01001c1 <__x86.get_pc_thunk.bx>
f01005f7:	81 c3 71 9a 01 00    	add    $0x19a71,%ebx
	was = *cp;
f01005fd:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100604:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f010060b:	5a a5 
	if (*cp != 0xA55A) {
f010060d:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100614:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100618:	0f 84 bc 00 00 00    	je     f01006da <cons_init+0xf1>
		addr_6845 = MONO_BASE;
f010061e:	c7 83 48 02 00 00 b4 	movl   $0x3b4,0x248(%ebx)
f0100625:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100628:	c7 45 e4 00 00 0b f0 	movl   $0xf00b0000,-0x1c(%ebp)
	outb(addr_6845, 14);
f010062f:	8b bb 48 02 00 00    	mov    0x248(%ebx),%edi
f0100635:	b8 0e 00 00 00       	mov    $0xe,%eax
f010063a:	89 fa                	mov    %edi,%edx
f010063c:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010063d:	8d 4f 01             	lea    0x1(%edi),%ecx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100640:	89 ca                	mov    %ecx,%edx
f0100642:	ec                   	in     (%dx),%al
f0100643:	0f b6 f0             	movzbl %al,%esi
f0100646:	c1 e6 08             	shl    $0x8,%esi
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100649:	b8 0f 00 00 00       	mov    $0xf,%eax
f010064e:	89 fa                	mov    %edi,%edx
f0100650:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100651:	89 ca                	mov    %ecx,%edx
f0100653:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f0100654:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100657:	89 bb 44 02 00 00    	mov    %edi,0x244(%ebx)
	pos |= inb(addr_6845 + 1);
f010065d:	0f b6 c0             	movzbl %al,%eax
f0100660:	09 c6                	or     %eax,%esi
	crt_pos = pos;
f0100662:	66 89 b3 40 02 00 00 	mov    %si,0x240(%ebx)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100669:	b9 00 00 00 00       	mov    $0x0,%ecx
f010066e:	89 c8                	mov    %ecx,%eax
f0100670:	ba fa 03 00 00       	mov    $0x3fa,%edx
f0100675:	ee                   	out    %al,(%dx)
f0100676:	bf fb 03 00 00       	mov    $0x3fb,%edi
f010067b:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100680:	89 fa                	mov    %edi,%edx
f0100682:	ee                   	out    %al,(%dx)
f0100683:	b8 0c 00 00 00       	mov    $0xc,%eax
f0100688:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010068d:	ee                   	out    %al,(%dx)
f010068e:	be f9 03 00 00       	mov    $0x3f9,%esi
f0100693:	89 c8                	mov    %ecx,%eax
f0100695:	89 f2                	mov    %esi,%edx
f0100697:	ee                   	out    %al,(%dx)
f0100698:	b8 03 00 00 00       	mov    $0x3,%eax
f010069d:	89 fa                	mov    %edi,%edx
f010069f:	ee                   	out    %al,(%dx)
f01006a0:	ba fc 03 00 00       	mov    $0x3fc,%edx
f01006a5:	89 c8                	mov    %ecx,%eax
f01006a7:	ee                   	out    %al,(%dx)
f01006a8:	b8 01 00 00 00       	mov    $0x1,%eax
f01006ad:	89 f2                	mov    %esi,%edx
f01006af:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006b0:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01006b5:	ec                   	in     (%dx),%al
f01006b6:	89 c1                	mov    %eax,%ecx
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01006b8:	3c ff                	cmp    $0xff,%al
f01006ba:	0f 95 83 4c 02 00 00 	setne  0x24c(%ebx)
f01006c1:	ba fa 03 00 00       	mov    $0x3fa,%edx
f01006c6:	ec                   	in     (%dx),%al
f01006c7:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01006cc:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01006cd:	80 f9 ff             	cmp    $0xff,%cl
f01006d0:	74 25                	je     f01006f7 <cons_init+0x10e>
		cprintf("Serial port does not exist!\n");
}
f01006d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01006d5:	5b                   	pop    %ebx
f01006d6:	5e                   	pop    %esi
f01006d7:	5f                   	pop    %edi
f01006d8:	5d                   	pop    %ebp
f01006d9:	c3                   	ret    
		*cp = was;
f01006da:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01006e1:	c7 83 48 02 00 00 d4 	movl   $0x3d4,0x248(%ebx)
f01006e8:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01006eb:	c7 45 e4 00 80 0b f0 	movl   $0xf00b8000,-0x1c(%ebp)
f01006f2:	e9 38 ff ff ff       	jmp    f010062f <cons_init+0x46>
		cprintf("Serial port does not exist!\n");
f01006f7:	83 ec 0c             	sub    $0xc,%esp
f01006fa:	8d 83 e8 9f fe ff    	lea    -0x16018(%ebx),%eax
f0100700:	50                   	push   %eax
f0100701:	e8 58 28 00 00       	call   f0102f5e <cprintf>
f0100706:	83 c4 10             	add    $0x10,%esp
}
f0100709:	eb c7                	jmp    f01006d2 <cons_init+0xe9>

f010070b <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010070b:	55                   	push   %ebp
f010070c:	89 e5                	mov    %esp,%ebp
f010070e:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100711:	8b 45 08             	mov    0x8(%ebp),%eax
f0100714:	e8 37 fc ff ff       	call   f0100350 <cons_putc>
}
f0100719:	c9                   	leave  
f010071a:	c3                   	ret    

f010071b <getchar>:

int
getchar(void)
{
f010071b:	55                   	push   %ebp
f010071c:	89 e5                	mov    %esp,%ebp
f010071e:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100721:	e8 6f fe ff ff       	call   f0100595 <cons_getc>
f0100726:	85 c0                	test   %eax,%eax
f0100728:	74 f7                	je     f0100721 <getchar+0x6>
		/* do nothing */;
	return c;
}
f010072a:	c9                   	leave  
f010072b:	c3                   	ret    

f010072c <iscons>:
int
iscons(int fdnum)
{
	// used by readline
	return 1;
}
f010072c:	b8 01 00 00 00       	mov    $0x1,%eax
f0100731:	c3                   	ret    

f0100732 <__x86.get_pc_thunk.ax>:
f0100732:	8b 04 24             	mov    (%esp),%eax
f0100735:	c3                   	ret    

f0100736 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100736:	55                   	push   %ebp
f0100737:	89 e5                	mov    %esp,%ebp
f0100739:	56                   	push   %esi
f010073a:	53                   	push   %ebx
f010073b:	e8 81 fa ff ff       	call   f01001c1 <__x86.get_pc_thunk.bx>
f0100740:	81 c3 28 99 01 00    	add    $0x19928,%ebx
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100746:	83 ec 04             	sub    $0x4,%esp
f0100749:	8d 83 18 a2 fe ff    	lea    -0x15de8(%ebx),%eax
f010074f:	50                   	push   %eax
f0100750:	8d 83 36 a2 fe ff    	lea    -0x15dca(%ebx),%eax
f0100756:	50                   	push   %eax
f0100757:	8d b3 3b a2 fe ff    	lea    -0x15dc5(%ebx),%esi
f010075d:	56                   	push   %esi
f010075e:	e8 fb 27 00 00       	call   f0102f5e <cprintf>
f0100763:	83 c4 0c             	add    $0xc,%esp
f0100766:	8d 83 e8 a2 fe ff    	lea    -0x15d18(%ebx),%eax
f010076c:	50                   	push   %eax
f010076d:	8d 83 44 a2 fe ff    	lea    -0x15dbc(%ebx),%eax
f0100773:	50                   	push   %eax
f0100774:	56                   	push   %esi
f0100775:	e8 e4 27 00 00       	call   f0102f5e <cprintf>
f010077a:	83 c4 0c             	add    $0xc,%esp
f010077d:	8d 83 4d a2 fe ff    	lea    -0x15db3(%ebx),%eax
f0100783:	50                   	push   %eax
f0100784:	8d 83 64 a2 fe ff    	lea    -0x15d9c(%ebx),%eax
f010078a:	50                   	push   %eax
f010078b:	56                   	push   %esi
f010078c:	e8 cd 27 00 00       	call   f0102f5e <cprintf>
	return 0;
}
f0100791:	b8 00 00 00 00       	mov    $0x0,%eax
f0100796:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100799:	5b                   	pop    %ebx
f010079a:	5e                   	pop    %esi
f010079b:	5d                   	pop    %ebp
f010079c:	c3                   	ret    

f010079d <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f010079d:	55                   	push   %ebp
f010079e:	89 e5                	mov    %esp,%ebp
f01007a0:	57                   	push   %edi
f01007a1:	56                   	push   %esi
f01007a2:	53                   	push   %ebx
f01007a3:	83 ec 18             	sub    $0x18,%esp
f01007a6:	e8 16 fa ff ff       	call   f01001c1 <__x86.get_pc_thunk.bx>
f01007ab:	81 c3 bd 98 01 00    	add    $0x198bd,%ebx
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007b1:	8d 83 6e a2 fe ff    	lea    -0x15d92(%ebx),%eax
f01007b7:	50                   	push   %eax
f01007b8:	e8 a1 27 00 00       	call   f0102f5e <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01007bd:	83 c4 08             	add    $0x8,%esp
f01007c0:	ff b3 f8 ff ff ff    	pushl  -0x8(%ebx)
f01007c6:	8d 83 10 a3 fe ff    	lea    -0x15cf0(%ebx),%eax
f01007cc:	50                   	push   %eax
f01007cd:	e8 8c 27 00 00       	call   f0102f5e <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01007d2:	83 c4 0c             	add    $0xc,%esp
f01007d5:	c7 c7 0c 00 10 f0    	mov    $0xf010000c,%edi
f01007db:	8d 87 00 00 00 10    	lea    0x10000000(%edi),%eax
f01007e1:	50                   	push   %eax
f01007e2:	57                   	push   %edi
f01007e3:	8d 83 38 a3 fe ff    	lea    -0x15cc8(%ebx),%eax
f01007e9:	50                   	push   %eax
f01007ea:	e8 6f 27 00 00       	call   f0102f5e <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01007ef:	83 c4 0c             	add    $0xc,%esp
f01007f2:	c7 c0 bf 3f 10 f0    	mov    $0xf0103fbf,%eax
f01007f8:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01007fe:	52                   	push   %edx
f01007ff:	50                   	push   %eax
f0100800:	8d 83 5c a3 fe ff    	lea    -0x15ca4(%ebx),%eax
f0100806:	50                   	push   %eax
f0100807:	e8 52 27 00 00       	call   f0102f5e <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010080c:	83 c4 0c             	add    $0xc,%esp
f010080f:	c7 c0 80 a0 11 f0    	mov    $0xf011a080,%eax
f0100815:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010081b:	52                   	push   %edx
f010081c:	50                   	push   %eax
f010081d:	8d 83 80 a3 fe ff    	lea    -0x15c80(%ebx),%eax
f0100823:	50                   	push   %eax
f0100824:	e8 35 27 00 00       	call   f0102f5e <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100829:	83 c4 0c             	add    $0xc,%esp
f010082c:	c7 c6 e0 a6 11 f0    	mov    $0xf011a6e0,%esi
f0100832:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f0100838:	50                   	push   %eax
f0100839:	56                   	push   %esi
f010083a:	8d 83 a4 a3 fe ff    	lea    -0x15c5c(%ebx),%eax
f0100840:	50                   	push   %eax
f0100841:	e8 18 27 00 00       	call   f0102f5e <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100846:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f0100849:	29 fe                	sub    %edi,%esi
f010084b:	81 c6 ff 03 00 00    	add    $0x3ff,%esi
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100851:	c1 fe 0a             	sar    $0xa,%esi
f0100854:	56                   	push   %esi
f0100855:	8d 83 c8 a3 fe ff    	lea    -0x15c38(%ebx),%eax
f010085b:	50                   	push   %eax
f010085c:	e8 fd 26 00 00       	call   f0102f5e <cprintf>
	return 0;
}
f0100861:	b8 00 00 00 00       	mov    $0x0,%eax
f0100866:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100869:	5b                   	pop    %ebx
f010086a:	5e                   	pop    %esi
f010086b:	5f                   	pop    %edi
f010086c:	5d                   	pop    %ebp
f010086d:	c3                   	ret    

f010086e <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f010086e:	55                   	push   %ebp
f010086f:	89 e5                	mov    %esp,%ebp
f0100871:	57                   	push   %edi
f0100872:	56                   	push   %esi
f0100873:	53                   	push   %ebx
f0100874:	83 ec 48             	sub    $0x48,%esp
f0100877:	e8 45 f9 ff ff       	call   f01001c1 <__x86.get_pc_thunk.bx>
f010087c:	81 c3 ec 97 01 00    	add    $0x197ec,%ebx

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0100882:	89 ee                	mov    %ebp,%esi
	// Your code here.
	uint32_t ebp, *ptr_ebp;
	ebp = read_ebp();
	cprintf("Stack backtrace:\n");
f0100884:	8d 83 87 a2 fe ff    	lea    -0x15d79(%ebx),%eax
f010088a:	50                   	push   %eax
f010088b:	e8 ce 26 00 00       	call   f0102f5e <cprintf>
	while (ebp != 0) {
f0100890:	83 c4 10             	add    $0x10,%esp
		ptr_ebp = (uint32_t *)ebp;
		cprintf(" ebp %x  eip %x  args %08x %08x %08x %08x %08x\n", 
f0100893:	8d 83 f4 a3 fe ff    	lea    -0x15c0c(%ebx),%eax
f0100899:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        		ebp, ptr_ebp[1], ptr_ebp[2], ptr_ebp[3], ptr_ebp[4], ptr_ebp[5], ptr_ebp[6]);
		struct Eipdebuginfo info;
		if (debuginfo_eip(ptr_ebp[1], &info) == 0) {
f010089c:	8d 45 d0             	lea    -0x30(%ebp),%eax
f010089f:	89 45 c0             	mov    %eax,-0x40(%ebp)
	while (ebp != 0) {
f01008a2:	eb 27                	jmp    f01008cb <mon_backtrace+0x5d>
			uint32_t fn_offset = ptr_ebp[1] - info.eip_fn_addr; 
			cprintf(" \t%s:%d: %.*s+%d\n", info.eip_file, info.eip_line\
f01008a4:	83 ec 08             	sub    $0x8,%esp
			uint32_t fn_offset = ptr_ebp[1] - info.eip_fn_addr; 
f01008a7:	8b 46 04             	mov    0x4(%esi),%eax
f01008aa:	2b 45 e0             	sub    -0x20(%ebp),%eax
			cprintf(" \t%s:%d: %.*s+%d\n", info.eip_file, info.eip_line\
f01008ad:	50                   	push   %eax
f01008ae:	ff 75 d8             	pushl  -0x28(%ebp)
f01008b1:	ff 75 dc             	pushl  -0x24(%ebp)
f01008b4:	ff 75 d4             	pushl  -0x2c(%ebp)
f01008b7:	ff 75 d0             	pushl  -0x30(%ebp)
f01008ba:	8d 83 99 a2 fe ff    	lea    -0x15d67(%ebx),%eax
f01008c0:	50                   	push   %eax
f01008c1:	e8 98 26 00 00       	call   f0102f5e <cprintf>
f01008c6:	83 c4 20             	add    $0x20,%esp
							, info.eip_fn_namelen, info.eip_fn_name, fn_offset);
		}
		ebp = *ptr_ebp;
f01008c9:	8b 37                	mov    (%edi),%esi
	while (ebp != 0) {
f01008cb:	85 f6                	test   %esi,%esi
f01008cd:	74 34                	je     f0100903 <mon_backtrace+0x95>
		ptr_ebp = (uint32_t *)ebp;
f01008cf:	89 f7                	mov    %esi,%edi
		cprintf(" ebp %x  eip %x  args %08x %08x %08x %08x %08x\n", 
f01008d1:	ff 76 18             	pushl  0x18(%esi)
f01008d4:	ff 76 14             	pushl  0x14(%esi)
f01008d7:	ff 76 10             	pushl  0x10(%esi)
f01008da:	ff 76 0c             	pushl  0xc(%esi)
f01008dd:	ff 76 08             	pushl  0x8(%esi)
f01008e0:	ff 76 04             	pushl  0x4(%esi)
f01008e3:	56                   	push   %esi
f01008e4:	ff 75 c4             	pushl  -0x3c(%ebp)
f01008e7:	e8 72 26 00 00       	call   f0102f5e <cprintf>
		if (debuginfo_eip(ptr_ebp[1], &info) == 0) {
f01008ec:	83 c4 18             	add    $0x18,%esp
f01008ef:	ff 75 c0             	pushl  -0x40(%ebp)
f01008f2:	ff 76 04             	pushl  0x4(%esi)
f01008f5:	e8 68 27 00 00       	call   f0103062 <debuginfo_eip>
f01008fa:	83 c4 10             	add    $0x10,%esp
f01008fd:	85 c0                	test   %eax,%eax
f01008ff:	75 c8                	jne    f01008c9 <mon_backtrace+0x5b>
f0100901:	eb a1                	jmp    f01008a4 <mon_backtrace+0x36>
	}
	return 0;
}
f0100903:	b8 00 00 00 00       	mov    $0x0,%eax
f0100908:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010090b:	5b                   	pop    %ebx
f010090c:	5e                   	pop    %esi
f010090d:	5f                   	pop    %edi
f010090e:	5d                   	pop    %ebp
f010090f:	c3                   	ret    

f0100910 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100910:	55                   	push   %ebp
f0100911:	89 e5                	mov    %esp,%ebp
f0100913:	57                   	push   %edi
f0100914:	56                   	push   %esi
f0100915:	53                   	push   %ebx
f0100916:	83 ec 68             	sub    $0x68,%esp
f0100919:	e8 a3 f8 ff ff       	call   f01001c1 <__x86.get_pc_thunk.bx>
f010091e:	81 c3 4a 97 01 00    	add    $0x1974a,%ebx
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100924:	8d 83 24 a4 fe ff    	lea    -0x15bdc(%ebx),%eax
f010092a:	50                   	push   %eax
f010092b:	e8 2e 26 00 00       	call   f0102f5e <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100930:	8d 83 48 a4 fe ff    	lea    -0x15bb8(%ebx),%eax
f0100936:	89 04 24             	mov    %eax,(%esp)
f0100939:	e8 20 26 00 00       	call   f0102f5e <cprintf>
f010093e:	83 c4 10             	add    $0x10,%esp
		while (*buf && strchr(WHITESPACE, *buf))
f0100941:	8d 83 af a2 fe ff    	lea    -0x15d51(%ebx),%eax
f0100947:	89 45 a0             	mov    %eax,-0x60(%ebp)
f010094a:	e9 d1 00 00 00       	jmp    f0100a20 <monitor+0x110>
f010094f:	83 ec 08             	sub    $0x8,%esp
f0100952:	0f be c0             	movsbl %al,%eax
f0100955:	50                   	push   %eax
f0100956:	ff 75 a0             	pushl  -0x60(%ebp)
f0100959:	e8 e4 31 00 00       	call   f0103b42 <strchr>
f010095e:	83 c4 10             	add    $0x10,%esp
f0100961:	85 c0                	test   %eax,%eax
f0100963:	74 6d                	je     f01009d2 <monitor+0xc2>
			*buf++ = 0;
f0100965:	c6 06 00             	movb   $0x0,(%esi)
f0100968:	89 7d a4             	mov    %edi,-0x5c(%ebp)
f010096b:	8d 76 01             	lea    0x1(%esi),%esi
f010096e:	8b 7d a4             	mov    -0x5c(%ebp),%edi
		while (*buf && strchr(WHITESPACE, *buf))
f0100971:	0f b6 06             	movzbl (%esi),%eax
f0100974:	84 c0                	test   %al,%al
f0100976:	75 d7                	jne    f010094f <monitor+0x3f>
	argv[argc] = 0;
f0100978:	c7 44 bd a8 00 00 00 	movl   $0x0,-0x58(%ebp,%edi,4)
f010097f:	00 
	if (argc == 0)
f0100980:	85 ff                	test   %edi,%edi
f0100982:	0f 84 98 00 00 00    	je     f0100a20 <monitor+0x110>
f0100988:	8d b3 b8 ff ff ff    	lea    -0x48(%ebx),%esi
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f010098e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100993:	89 7d a4             	mov    %edi,-0x5c(%ebp)
f0100996:	89 c7                	mov    %eax,%edi
		if (strcmp(argv[0], commands[i].name) == 0)
f0100998:	83 ec 08             	sub    $0x8,%esp
f010099b:	ff 36                	pushl  (%esi)
f010099d:	ff 75 a8             	pushl  -0x58(%ebp)
f01009a0:	e8 3f 31 00 00       	call   f0103ae4 <strcmp>
f01009a5:	83 c4 10             	add    $0x10,%esp
f01009a8:	85 c0                	test   %eax,%eax
f01009aa:	0f 84 99 00 00 00    	je     f0100a49 <monitor+0x139>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f01009b0:	83 c7 01             	add    $0x1,%edi
f01009b3:	83 c6 0c             	add    $0xc,%esi
f01009b6:	83 ff 03             	cmp    $0x3,%edi
f01009b9:	75 dd                	jne    f0100998 <monitor+0x88>
	cprintf("Unknown command '%s'\n", argv[0]);
f01009bb:	83 ec 08             	sub    $0x8,%esp
f01009be:	ff 75 a8             	pushl  -0x58(%ebp)
f01009c1:	8d 83 d1 a2 fe ff    	lea    -0x15d2f(%ebx),%eax
f01009c7:	50                   	push   %eax
f01009c8:	e8 91 25 00 00       	call   f0102f5e <cprintf>
f01009cd:	83 c4 10             	add    $0x10,%esp
f01009d0:	eb 4e                	jmp    f0100a20 <monitor+0x110>
		if (*buf == 0)
f01009d2:	80 3e 00             	cmpb   $0x0,(%esi)
f01009d5:	74 a1                	je     f0100978 <monitor+0x68>
		if (argc == MAXARGS-1) {
f01009d7:	83 ff 0f             	cmp    $0xf,%edi
f01009da:	74 30                	je     f0100a0c <monitor+0xfc>
		argv[argc++] = buf;
f01009dc:	8d 47 01             	lea    0x1(%edi),%eax
f01009df:	89 45 a4             	mov    %eax,-0x5c(%ebp)
f01009e2:	89 74 bd a8          	mov    %esi,-0x58(%ebp,%edi,4)
		while (*buf && !strchr(WHITESPACE, *buf))
f01009e6:	0f b6 06             	movzbl (%esi),%eax
f01009e9:	84 c0                	test   %al,%al
f01009eb:	74 81                	je     f010096e <monitor+0x5e>
f01009ed:	83 ec 08             	sub    $0x8,%esp
f01009f0:	0f be c0             	movsbl %al,%eax
f01009f3:	50                   	push   %eax
f01009f4:	ff 75 a0             	pushl  -0x60(%ebp)
f01009f7:	e8 46 31 00 00       	call   f0103b42 <strchr>
f01009fc:	83 c4 10             	add    $0x10,%esp
f01009ff:	85 c0                	test   %eax,%eax
f0100a01:	0f 85 67 ff ff ff    	jne    f010096e <monitor+0x5e>
			buf++;
f0100a07:	83 c6 01             	add    $0x1,%esi
f0100a0a:	eb da                	jmp    f01009e6 <monitor+0xd6>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100a0c:	83 ec 08             	sub    $0x8,%esp
f0100a0f:	6a 10                	push   $0x10
f0100a11:	8d 83 b4 a2 fe ff    	lea    -0x15d4c(%ebx),%eax
f0100a17:	50                   	push   %eax
f0100a18:	e8 41 25 00 00       	call   f0102f5e <cprintf>
f0100a1d:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f0100a20:	8d bb ab a2 fe ff    	lea    -0x15d55(%ebx),%edi
f0100a26:	83 ec 0c             	sub    $0xc,%esp
f0100a29:	57                   	push   %edi
f0100a2a:	e8 d4 2e 00 00       	call   f0103903 <readline>
		if (buf != NULL)
f0100a2f:	83 c4 10             	add    $0x10,%esp
f0100a32:	85 c0                	test   %eax,%eax
f0100a34:	74 f0                	je     f0100a26 <monitor+0x116>
f0100a36:	89 c6                	mov    %eax,%esi
	argv[argc] = 0;
f0100a38:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f0100a3f:	bf 00 00 00 00       	mov    $0x0,%edi
f0100a44:	e9 28 ff ff ff       	jmp    f0100971 <monitor+0x61>
f0100a49:	89 f8                	mov    %edi,%eax
f0100a4b:	8b 7d a4             	mov    -0x5c(%ebp),%edi
			return commands[i].func(argc, argv, tf);
f0100a4e:	83 ec 04             	sub    $0x4,%esp
f0100a51:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100a54:	ff 75 08             	pushl  0x8(%ebp)
f0100a57:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100a5a:	52                   	push   %edx
f0100a5b:	57                   	push   %edi
f0100a5c:	ff 94 83 c0 ff ff ff 	call   *-0x40(%ebx,%eax,4)
			if (runcmd(buf, tf) < 0)
f0100a63:	83 c4 10             	add    $0x10,%esp
f0100a66:	85 c0                	test   %eax,%eax
f0100a68:	79 b6                	jns    f0100a20 <monitor+0x110>
				break;
	}
}
f0100a6a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100a6d:	5b                   	pop    %ebx
f0100a6e:	5e                   	pop    %esi
f0100a6f:	5f                   	pop    %edi
f0100a70:	5d                   	pop    %ebp
f0100a71:	c3                   	ret    

f0100a72 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100a72:	e8 54 24 00 00       	call   f0102ecb <__x86.get_pc_thunk.cx>
f0100a77:	81 c1 f1 95 01 00    	add    $0x195f1,%ecx
f0100a7d:	89 c2                	mov    %eax,%edx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100a7f:	83 b9 50 02 00 00 00 	cmpl   $0x0,0x250(%ecx)
f0100a86:	74 1b                	je     f0100aa3 <boot_alloc+0x31>
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	result = nextfree;
f0100a88:	8b 81 50 02 00 00    	mov    0x250(%ecx),%eax
	nextfree += ROUNDUP(n, PGSIZE);
f0100a8e:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
f0100a94:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100a9a:	01 c2                	add    %eax,%edx
f0100a9c:	89 91 50 02 00 00    	mov    %edx,0x250(%ecx)
	return result;
}
f0100aa2:	c3                   	ret    
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100aa3:	c7 c0 e0 a6 11 f0    	mov    $0xf011a6e0,%eax
f0100aa9:	05 ff 0f 00 00       	add    $0xfff,%eax
f0100aae:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100ab3:	89 81 50 02 00 00    	mov    %eax,0x250(%ecx)
f0100ab9:	eb cd                	jmp    f0100a88 <boot_alloc+0x16>

f0100abb <nvram_read>:
{
f0100abb:	55                   	push   %ebp
f0100abc:	89 e5                	mov    %esp,%ebp
f0100abe:	57                   	push   %edi
f0100abf:	56                   	push   %esi
f0100ac0:	53                   	push   %ebx
f0100ac1:	83 ec 18             	sub    $0x18,%esp
f0100ac4:	e8 f8 f6 ff ff       	call   f01001c1 <__x86.get_pc_thunk.bx>
f0100ac9:	81 c3 9f 95 01 00    	add    $0x1959f,%ebx
f0100acf:	89 c7                	mov    %eax,%edi
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100ad1:	50                   	push   %eax
f0100ad2:	e8 00 24 00 00       	call   f0102ed7 <mc146818_read>
f0100ad7:	89 c6                	mov    %eax,%esi
f0100ad9:	83 c7 01             	add    $0x1,%edi
f0100adc:	89 3c 24             	mov    %edi,(%esp)
f0100adf:	e8 f3 23 00 00       	call   f0102ed7 <mc146818_read>
f0100ae4:	c1 e0 08             	shl    $0x8,%eax
f0100ae7:	09 f0                	or     %esi,%eax
}
f0100ae9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100aec:	5b                   	pop    %ebx
f0100aed:	5e                   	pop    %esi
f0100aee:	5f                   	pop    %edi
f0100aef:	5d                   	pop    %ebp
f0100af0:	c3                   	ret    

f0100af1 <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100af1:	55                   	push   %ebp
f0100af2:	89 e5                	mov    %esp,%ebp
f0100af4:	56                   	push   %esi
f0100af5:	53                   	push   %ebx
f0100af6:	e8 d0 23 00 00       	call   f0102ecb <__x86.get_pc_thunk.cx>
f0100afb:	81 c1 6d 95 01 00    	add    $0x1956d,%ecx
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100b01:	89 d3                	mov    %edx,%ebx
f0100b03:	c1 eb 16             	shr    $0x16,%ebx
	if (!(*pgdir & PTE_P))
f0100b06:	8b 04 98             	mov    (%eax,%ebx,4),%eax
f0100b09:	a8 01                	test   $0x1,%al
f0100b0b:	74 5a                	je     f0100b67 <check_va2pa+0x76>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100b0d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100b12:	89 c6                	mov    %eax,%esi
f0100b14:	c1 ee 0c             	shr    $0xc,%esi
f0100b17:	c7 c3 e8 a6 11 f0    	mov    $0xf011a6e8,%ebx
f0100b1d:	3b 33                	cmp    (%ebx),%esi
f0100b1f:	73 2b                	jae    f0100b4c <check_va2pa+0x5b>
	if (!(p[PTX(va)] & PTE_P))
f0100b21:	c1 ea 0c             	shr    $0xc,%edx
f0100b24:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100b2a:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100b31:	89 c2                	mov    %eax,%edx
f0100b33:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100b36:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b3b:	85 d2                	test   %edx,%edx
f0100b3d:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100b42:	0f 44 c2             	cmove  %edx,%eax
}
f0100b45:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100b48:	5b                   	pop    %ebx
f0100b49:	5e                   	pop    %esi
f0100b4a:	5d                   	pop    %ebp
f0100b4b:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100b4c:	50                   	push   %eax
f0100b4d:	8d 81 70 a4 fe ff    	lea    -0x15b90(%ecx),%eax
f0100b53:	50                   	push   %eax
f0100b54:	68 da 02 00 00       	push   $0x2da
f0100b59:	8d 81 20 ac fe ff    	lea    -0x153e0(%ecx),%eax
f0100b5f:	50                   	push   %eax
f0100b60:	89 cb                	mov    %ecx,%ebx
f0100b62:	e8 a4 f5 ff ff       	call   f010010b <_panic>
		return ~0;
f0100b67:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100b6c:	eb d7                	jmp    f0100b45 <check_va2pa+0x54>

f0100b6e <check_page_free_list>:
{
f0100b6e:	55                   	push   %ebp
f0100b6f:	89 e5                	mov    %esp,%ebp
f0100b71:	57                   	push   %edi
f0100b72:	56                   	push   %esi
f0100b73:	53                   	push   %ebx
f0100b74:	83 ec 2c             	sub    $0x2c,%esp
f0100b77:	e8 53 23 00 00       	call   f0102ecf <__x86.get_pc_thunk.si>
f0100b7c:	81 c6 ec 94 01 00    	add    $0x194ec,%esi
f0100b82:	89 75 c8             	mov    %esi,-0x38(%ebp)
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100b85:	84 c0                	test   %al,%al
f0100b87:	0f 85 ec 02 00 00    	jne    f0100e79 <check_page_free_list+0x30b>
	if (!page_free_list)
f0100b8d:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0100b90:	83 b8 54 02 00 00 00 	cmpl   $0x0,0x254(%eax)
f0100b97:	74 21                	je     f0100bba <check_page_free_list+0x4c>
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100b99:	c7 45 d4 00 04 00 00 	movl   $0x400,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100ba0:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0100ba3:	8b b0 54 02 00 00    	mov    0x254(%eax),%esi
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100ba9:	c7 c7 f0 a6 11 f0    	mov    $0xf011a6f0,%edi
	if (PGNUM(pa) >= npages)
f0100baf:	c7 c0 e8 a6 11 f0    	mov    $0xf011a6e8,%eax
f0100bb5:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100bb8:	eb 39                	jmp    f0100bf3 <check_page_free_list+0x85>
		panic("'page_free_list' is a null pointer!");
f0100bba:	83 ec 04             	sub    $0x4,%esp
f0100bbd:	8b 5d c8             	mov    -0x38(%ebp),%ebx
f0100bc0:	8d 83 94 a4 fe ff    	lea    -0x15b6c(%ebx),%eax
f0100bc6:	50                   	push   %eax
f0100bc7:	68 1b 02 00 00       	push   $0x21b
f0100bcc:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f0100bd2:	50                   	push   %eax
f0100bd3:	e8 33 f5 ff ff       	call   f010010b <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100bd8:	50                   	push   %eax
f0100bd9:	8b 5d c8             	mov    -0x38(%ebp),%ebx
f0100bdc:	8d 83 70 a4 fe ff    	lea    -0x15b90(%ebx),%eax
f0100be2:	50                   	push   %eax
f0100be3:	6a 52                	push   $0x52
f0100be5:	8d 83 2c ac fe ff    	lea    -0x153d4(%ebx),%eax
f0100beb:	50                   	push   %eax
f0100bec:	e8 1a f5 ff ff       	call   f010010b <_panic>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100bf1:	8b 36                	mov    (%esi),%esi
f0100bf3:	85 f6                	test   %esi,%esi
f0100bf5:	74 40                	je     f0100c37 <check_page_free_list+0xc9>
	return (pp - pages) << PGSHIFT;
f0100bf7:	89 f0                	mov    %esi,%eax
f0100bf9:	2b 07                	sub    (%edi),%eax
f0100bfb:	c1 f8 03             	sar    $0x3,%eax
f0100bfe:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100c01:	89 c2                	mov    %eax,%edx
f0100c03:	c1 ea 16             	shr    $0x16,%edx
f0100c06:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100c09:	73 e6                	jae    f0100bf1 <check_page_free_list+0x83>
	if (PGNUM(pa) >= npages)
f0100c0b:	89 c2                	mov    %eax,%edx
f0100c0d:	c1 ea 0c             	shr    $0xc,%edx
f0100c10:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0100c13:	3b 11                	cmp    (%ecx),%edx
f0100c15:	73 c1                	jae    f0100bd8 <check_page_free_list+0x6a>
			memset(page2kva(pp), 0x97, 128);
f0100c17:	83 ec 04             	sub    $0x4,%esp
f0100c1a:	68 80 00 00 00       	push   $0x80
f0100c1f:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0100c24:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c29:	50                   	push   %eax
f0100c2a:	8b 5d c8             	mov    -0x38(%ebp),%ebx
f0100c2d:	e8 4d 2f 00 00       	call   f0103b7f <memset>
f0100c32:	83 c4 10             	add    $0x10,%esp
f0100c35:	eb ba                	jmp    f0100bf1 <check_page_free_list+0x83>
	first_free_page = (char *) boot_alloc(0);
f0100c37:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c3c:	e8 31 fe ff ff       	call   f0100a72 <boot_alloc>
f0100c41:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c44:	8b 7d c8             	mov    -0x38(%ebp),%edi
f0100c47:	8b 97 54 02 00 00    	mov    0x254(%edi),%edx
		assert(pp >= pages);
f0100c4d:	c7 c0 f0 a6 11 f0    	mov    $0xf011a6f0,%eax
f0100c53:	8b 08                	mov    (%eax),%ecx
		assert(pp < pages + npages);
f0100c55:	c7 c0 e8 a6 11 f0    	mov    $0xf011a6e8,%eax
f0100c5b:	8b 00                	mov    (%eax),%eax
f0100c5d:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100c60:	8d 3c c1             	lea    (%ecx,%eax,8),%edi
	int nfree_basemem = 0, nfree_extmem = 0;
f0100c63:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100c68:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c6b:	e9 08 01 00 00       	jmp    f0100d78 <check_page_free_list+0x20a>
		assert(pp >= pages);
f0100c70:	8b 5d c8             	mov    -0x38(%ebp),%ebx
f0100c73:	8d 83 3a ac fe ff    	lea    -0x153c6(%ebx),%eax
f0100c79:	50                   	push   %eax
f0100c7a:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f0100c80:	50                   	push   %eax
f0100c81:	68 35 02 00 00       	push   $0x235
f0100c86:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f0100c8c:	50                   	push   %eax
f0100c8d:	e8 79 f4 ff ff       	call   f010010b <_panic>
		assert(pp < pages + npages);
f0100c92:	8b 5d c8             	mov    -0x38(%ebp),%ebx
f0100c95:	8d 83 5b ac fe ff    	lea    -0x153a5(%ebx),%eax
f0100c9b:	50                   	push   %eax
f0100c9c:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f0100ca2:	50                   	push   %eax
f0100ca3:	68 36 02 00 00       	push   $0x236
f0100ca8:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f0100cae:	50                   	push   %eax
f0100caf:	e8 57 f4 ff ff       	call   f010010b <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100cb4:	8b 5d c8             	mov    -0x38(%ebp),%ebx
f0100cb7:	8d 83 b8 a4 fe ff    	lea    -0x15b48(%ebx),%eax
f0100cbd:	50                   	push   %eax
f0100cbe:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f0100cc4:	50                   	push   %eax
f0100cc5:	68 37 02 00 00       	push   $0x237
f0100cca:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f0100cd0:	50                   	push   %eax
f0100cd1:	e8 35 f4 ff ff       	call   f010010b <_panic>
		assert(page2pa(pp) != 0);
f0100cd6:	8b 5d c8             	mov    -0x38(%ebp),%ebx
f0100cd9:	8d 83 6f ac fe ff    	lea    -0x15391(%ebx),%eax
f0100cdf:	50                   	push   %eax
f0100ce0:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f0100ce6:	50                   	push   %eax
f0100ce7:	68 3a 02 00 00       	push   $0x23a
f0100cec:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f0100cf2:	50                   	push   %eax
f0100cf3:	e8 13 f4 ff ff       	call   f010010b <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100cf8:	8b 5d c8             	mov    -0x38(%ebp),%ebx
f0100cfb:	8d 83 80 ac fe ff    	lea    -0x15380(%ebx),%eax
f0100d01:	50                   	push   %eax
f0100d02:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f0100d08:	50                   	push   %eax
f0100d09:	68 3b 02 00 00       	push   $0x23b
f0100d0e:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f0100d14:	50                   	push   %eax
f0100d15:	e8 f1 f3 ff ff       	call   f010010b <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100d1a:	8b 5d c8             	mov    -0x38(%ebp),%ebx
f0100d1d:	8d 83 ec a4 fe ff    	lea    -0x15b14(%ebx),%eax
f0100d23:	50                   	push   %eax
f0100d24:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f0100d2a:	50                   	push   %eax
f0100d2b:	68 3c 02 00 00       	push   $0x23c
f0100d30:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f0100d36:	50                   	push   %eax
f0100d37:	e8 cf f3 ff ff       	call   f010010b <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100d3c:	8b 5d c8             	mov    -0x38(%ebp),%ebx
f0100d3f:	8d 83 99 ac fe ff    	lea    -0x15367(%ebx),%eax
f0100d45:	50                   	push   %eax
f0100d46:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f0100d4c:	50                   	push   %eax
f0100d4d:	68 3d 02 00 00       	push   $0x23d
f0100d52:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f0100d58:	50                   	push   %eax
f0100d59:	e8 ad f3 ff ff       	call   f010010b <_panic>
	if (PGNUM(pa) >= npages)
f0100d5e:	89 c3                	mov    %eax,%ebx
f0100d60:	c1 eb 0c             	shr    $0xc,%ebx
f0100d63:	39 5d d0             	cmp    %ebx,-0x30(%ebp)
f0100d66:	76 6d                	jbe    f0100dd5 <check_page_free_list+0x267>
	return (void *)(pa + KERNBASE);
f0100d68:	2d 00 00 00 10       	sub    $0x10000000,%eax
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100d6d:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0100d70:	77 7c                	ja     f0100dee <check_page_free_list+0x280>
			++nfree_extmem;
f0100d72:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100d76:	8b 12                	mov    (%edx),%edx
f0100d78:	85 d2                	test   %edx,%edx
f0100d7a:	0f 84 90 00 00 00    	je     f0100e10 <check_page_free_list+0x2a2>
		assert(pp >= pages);
f0100d80:	39 d1                	cmp    %edx,%ecx
f0100d82:	0f 87 e8 fe ff ff    	ja     f0100c70 <check_page_free_list+0x102>
		assert(pp < pages + npages);
f0100d88:	39 d7                	cmp    %edx,%edi
f0100d8a:	0f 86 02 ff ff ff    	jbe    f0100c92 <check_page_free_list+0x124>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100d90:	89 d0                	mov    %edx,%eax
f0100d92:	29 c8                	sub    %ecx,%eax
f0100d94:	a8 07                	test   $0x7,%al
f0100d96:	0f 85 18 ff ff ff    	jne    f0100cb4 <check_page_free_list+0x146>
	return (pp - pages) << PGSHIFT;
f0100d9c:	c1 f8 03             	sar    $0x3,%eax
		assert(page2pa(pp) != 0);
f0100d9f:	c1 e0 0c             	shl    $0xc,%eax
f0100da2:	0f 84 2e ff ff ff    	je     f0100cd6 <check_page_free_list+0x168>
		assert(page2pa(pp) != IOPHYSMEM);
f0100da8:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100dad:	0f 84 45 ff ff ff    	je     f0100cf8 <check_page_free_list+0x18a>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100db3:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100db8:	0f 84 5c ff ff ff    	je     f0100d1a <check_page_free_list+0x1ac>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100dbe:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100dc3:	0f 84 73 ff ff ff    	je     f0100d3c <check_page_free_list+0x1ce>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100dc9:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100dce:	77 8e                	ja     f0100d5e <check_page_free_list+0x1f0>
			++nfree_basemem;
f0100dd0:	83 c6 01             	add    $0x1,%esi
f0100dd3:	eb a1                	jmp    f0100d76 <check_page_free_list+0x208>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100dd5:	50                   	push   %eax
f0100dd6:	8b 5d c8             	mov    -0x38(%ebp),%ebx
f0100dd9:	8d 83 70 a4 fe ff    	lea    -0x15b90(%ebx),%eax
f0100ddf:	50                   	push   %eax
f0100de0:	6a 52                	push   $0x52
f0100de2:	8d 83 2c ac fe ff    	lea    -0x153d4(%ebx),%eax
f0100de8:	50                   	push   %eax
f0100de9:	e8 1d f3 ff ff       	call   f010010b <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100dee:	8b 5d c8             	mov    -0x38(%ebp),%ebx
f0100df1:	8d 83 10 a5 fe ff    	lea    -0x15af0(%ebx),%eax
f0100df7:	50                   	push   %eax
f0100df8:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f0100dfe:	50                   	push   %eax
f0100dff:	68 3e 02 00 00       	push   $0x23e
f0100e04:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f0100e0a:	50                   	push   %eax
f0100e0b:	e8 fb f2 ff ff       	call   f010010b <_panic>
f0100e10:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
	assert(nfree_basemem > 0);
f0100e13:	85 f6                	test   %esi,%esi
f0100e15:	7e 1e                	jle    f0100e35 <check_page_free_list+0x2c7>
	assert(nfree_extmem > 0);
f0100e17:	85 db                	test   %ebx,%ebx
f0100e19:	7e 3c                	jle    f0100e57 <check_page_free_list+0x2e9>
	cprintf("check_page_free_list() succeeded!\n");
f0100e1b:	83 ec 0c             	sub    $0xc,%esp
f0100e1e:	8b 5d c8             	mov    -0x38(%ebp),%ebx
f0100e21:	8d 83 58 a5 fe ff    	lea    -0x15aa8(%ebx),%eax
f0100e27:	50                   	push   %eax
f0100e28:	e8 31 21 00 00       	call   f0102f5e <cprintf>
}
f0100e2d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e30:	5b                   	pop    %ebx
f0100e31:	5e                   	pop    %esi
f0100e32:	5f                   	pop    %edi
f0100e33:	5d                   	pop    %ebp
f0100e34:	c3                   	ret    
	assert(nfree_basemem > 0);
f0100e35:	8b 5d c8             	mov    -0x38(%ebp),%ebx
f0100e38:	8d 83 b3 ac fe ff    	lea    -0x1534d(%ebx),%eax
f0100e3e:	50                   	push   %eax
f0100e3f:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f0100e45:	50                   	push   %eax
f0100e46:	68 46 02 00 00       	push   $0x246
f0100e4b:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f0100e51:	50                   	push   %eax
f0100e52:	e8 b4 f2 ff ff       	call   f010010b <_panic>
	assert(nfree_extmem > 0);
f0100e57:	8b 5d c8             	mov    -0x38(%ebp),%ebx
f0100e5a:	8d 83 c5 ac fe ff    	lea    -0x1533b(%ebx),%eax
f0100e60:	50                   	push   %eax
f0100e61:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f0100e67:	50                   	push   %eax
f0100e68:	68 47 02 00 00       	push   $0x247
f0100e6d:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f0100e73:	50                   	push   %eax
f0100e74:	e8 92 f2 ff ff       	call   f010010b <_panic>
	if (!page_free_list)
f0100e79:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0100e7c:	8b 80 54 02 00 00    	mov    0x254(%eax),%eax
f0100e82:	85 c0                	test   %eax,%eax
f0100e84:	0f 84 30 fd ff ff    	je     f0100bba <check_page_free_list+0x4c>
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100e8a:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100e8d:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100e90:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100e93:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	return (pp - pages) << PGSHIFT;
f0100e96:	8b 75 c8             	mov    -0x38(%ebp),%esi
f0100e99:	c7 c3 f0 a6 11 f0    	mov    $0xf011a6f0,%ebx
f0100e9f:	89 c2                	mov    %eax,%edx
f0100ea1:	2b 13                	sub    (%ebx),%edx
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100ea3:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100ea9:	0f 95 c2             	setne  %dl
f0100eac:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100eaf:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100eb3:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100eb5:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100eb9:	8b 00                	mov    (%eax),%eax
f0100ebb:	85 c0                	test   %eax,%eax
f0100ebd:	75 e0                	jne    f0100e9f <check_page_free_list+0x331>
		*tp[1] = 0;
f0100ebf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100ec2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100ec8:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100ecb:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100ece:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100ed0:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100ed3:	8b 75 c8             	mov    -0x38(%ebp),%esi
f0100ed6:	89 86 54 02 00 00    	mov    %eax,0x254(%esi)
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100edc:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
f0100ee3:	e9 b8 fc ff ff       	jmp    f0100ba0 <check_page_free_list+0x32>

f0100ee8 <page_init>:
{
f0100ee8:	55                   	push   %ebp
f0100ee9:	89 e5                	mov    %esp,%ebp
f0100eeb:	57                   	push   %edi
f0100eec:	56                   	push   %esi
f0100eed:	53                   	push   %ebx
f0100eee:	83 ec 1c             	sub    $0x1c,%esp
f0100ef1:	e8 dd 1f 00 00       	call   f0102ed3 <__x86.get_pc_thunk.di>
f0100ef6:	81 c7 72 91 01 00    	add    $0x19172,%edi
f0100efc:	89 fe                	mov    %edi,%esi
f0100efe:	89 7d e4             	mov    %edi,-0x1c(%ebp)
	pages[0].pp_ref = 1;
f0100f01:	c7 c0 f0 a6 11 f0    	mov    $0xf011a6f0,%eax
f0100f07:	8b 00                	mov    (%eax),%eax
f0100f09:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
    for (i = 1; i < npages_basemem; i++) {
f0100f0f:	8b bf 58 02 00 00    	mov    0x258(%edi),%edi
f0100f15:	8b 9e 54 02 00 00    	mov    0x254(%esi),%ebx
f0100f1b:	ba 00 00 00 00       	mov    $0x0,%edx
f0100f20:	b8 01 00 00 00       	mov    $0x1,%eax
        pages[i].pp_ref = 0;
f0100f25:	c7 c6 f0 a6 11 f0    	mov    $0xf011a6f0,%esi
    for (i = 1; i < npages_basemem; i++) {
f0100f2b:	eb 1f                	jmp    f0100f4c <page_init+0x64>
f0100f2d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
        pages[i].pp_ref = 0;
f0100f34:	89 d1                	mov    %edx,%ecx
f0100f36:	03 0e                	add    (%esi),%ecx
f0100f38:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
        pages[i].pp_link = page_free_list;
f0100f3e:	89 19                	mov    %ebx,(%ecx)
    for (i = 1; i < npages_basemem; i++) {
f0100f40:	83 c0 01             	add    $0x1,%eax
        page_free_list = &pages[i];
f0100f43:	89 d3                	mov    %edx,%ebx
f0100f45:	03 1e                	add    (%esi),%ebx
f0100f47:	ba 01 00 00 00       	mov    $0x1,%edx
    for (i = 1; i < npages_basemem; i++) {
f0100f4c:	39 c7                	cmp    %eax,%edi
f0100f4e:	77 dd                	ja     f0100f2d <page_init+0x45>
f0100f50:	84 d2                	test   %dl,%dl
f0100f52:	74 09                	je     f0100f5d <page_init+0x75>
f0100f54:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100f57:	89 98 54 02 00 00    	mov    %ebx,0x254(%eax)
	size_t first_free_address = PADDR(boot_alloc(0));
f0100f5d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f62:	e8 0b fb ff ff       	call   f0100a72 <boot_alloc>
	if ((uint32_t)kva < KERNBASE)
f0100f67:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100f6c:	76 47                	jbe    f0100fb5 <page_init+0xcd>
	return (physaddr_t)kva - KERNBASE;
f0100f6e:	05 00 00 00 10       	add    $0x10000000,%eax
        pages[i].pp_ref = 1;
f0100f73:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100f76:	c7 c2 f0 a6 11 f0    	mov    $0xf011a6f0,%edx
f0100f7c:	8b 0a                	mov    (%edx),%ecx
f0100f7e:	8d 91 04 05 00 00    	lea    0x504(%ecx),%edx
f0100f84:	81 c1 04 08 00 00    	add    $0x804,%ecx
f0100f8a:	66 c7 02 01 00       	movw   $0x1,(%edx)
f0100f8f:	83 c2 08             	add    $0x8,%edx
    for (i = IOPHYSMEM/PGSIZE; i < EXTPHYSMEM/PGSIZE; i++) {
f0100f92:	39 ca                	cmp    %ecx,%edx
f0100f94:	75 f4                	jne    f0100f8a <page_init+0xa2>
    for (i = first_free_address/PGSIZE; i < npages; i++) {
f0100f96:	c1 e8 0c             	shr    $0xc,%eax
f0100f99:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100f9c:	8b 9e 54 02 00 00    	mov    0x254(%esi),%ebx
f0100fa2:	ba 00 00 00 00       	mov    $0x0,%edx
f0100fa7:	c7 c7 e8 a6 11 f0    	mov    $0xf011a6e8,%edi
        pages[i].pp_ref = 0;
f0100fad:	c7 c6 f0 a6 11 f0    	mov    $0xf011a6f0,%esi
    for (i = first_free_address/PGSIZE; i < npages; i++) {
f0100fb3:	eb 3b                	jmp    f0100ff0 <page_init+0x108>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100fb5:	50                   	push   %eax
f0100fb6:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100fb9:	8d 83 7c a5 fe ff    	lea    -0x15a84(%ebx),%eax
f0100fbf:	50                   	push   %eax
f0100fc0:	68 03 01 00 00       	push   $0x103
f0100fc5:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f0100fcb:	50                   	push   %eax
f0100fcc:	e8 3a f1 ff ff       	call   f010010b <_panic>
f0100fd1:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
        pages[i].pp_ref = 0;
f0100fd8:	89 d1                	mov    %edx,%ecx
f0100fda:	03 0e                	add    (%esi),%ecx
f0100fdc:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
        pages[i].pp_link = page_free_list;
f0100fe2:	89 19                	mov    %ebx,(%ecx)
    for (i = first_free_address/PGSIZE; i < npages; i++) {
f0100fe4:	83 c0 01             	add    $0x1,%eax
        page_free_list = &pages[i];
f0100fe7:	89 d3                	mov    %edx,%ebx
f0100fe9:	03 1e                	add    (%esi),%ebx
f0100feb:	ba 01 00 00 00       	mov    $0x1,%edx
    for (i = first_free_address/PGSIZE; i < npages; i++) {
f0100ff0:	39 07                	cmp    %eax,(%edi)
f0100ff2:	77 dd                	ja     f0100fd1 <page_init+0xe9>
f0100ff4:	84 d2                	test   %dl,%dl
f0100ff6:	74 09                	je     f0101001 <page_init+0x119>
f0100ff8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100ffb:	89 98 54 02 00 00    	mov    %ebx,0x254(%eax)
}
f0101001:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101004:	5b                   	pop    %ebx
f0101005:	5e                   	pop    %esi
f0101006:	5f                   	pop    %edi
f0101007:	5d                   	pop    %ebp
f0101008:	c3                   	ret    

f0101009 <page_alloc>:
{
f0101009:	55                   	push   %ebp
f010100a:	89 e5                	mov    %esp,%ebp
f010100c:	56                   	push   %esi
f010100d:	53                   	push   %ebx
f010100e:	e8 ae f1 ff ff       	call   f01001c1 <__x86.get_pc_thunk.bx>
f0101013:	81 c3 55 90 01 00    	add    $0x19055,%ebx
	if (!page_free_list) {
f0101019:	8b b3 54 02 00 00    	mov    0x254(%ebx),%esi
f010101f:	85 f6                	test   %esi,%esi
f0101021:	74 14                	je     f0101037 <page_alloc+0x2e>
	page_free_list = page->pp_link;
f0101023:	8b 06                	mov    (%esi),%eax
f0101025:	89 83 54 02 00 00    	mov    %eax,0x254(%ebx)
	page->pp_link = NULL;
f010102b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (alloc_flags & ALLOC_ZERO) {
f0101031:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0101035:	75 09                	jne    f0101040 <page_alloc+0x37>
}
f0101037:	89 f0                	mov    %esi,%eax
f0101039:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010103c:	5b                   	pop    %ebx
f010103d:	5e                   	pop    %esi
f010103e:	5d                   	pop    %ebp
f010103f:	c3                   	ret    
	return (pp - pages) << PGSHIFT;
f0101040:	c7 c0 f0 a6 11 f0    	mov    $0xf011a6f0,%eax
f0101046:	89 f2                	mov    %esi,%edx
f0101048:	2b 10                	sub    (%eax),%edx
f010104a:	89 d0                	mov    %edx,%eax
f010104c:	c1 f8 03             	sar    $0x3,%eax
f010104f:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0101052:	89 c1                	mov    %eax,%ecx
f0101054:	c1 e9 0c             	shr    $0xc,%ecx
f0101057:	c7 c2 e8 a6 11 f0    	mov    $0xf011a6e8,%edx
f010105d:	3b 0a                	cmp    (%edx),%ecx
f010105f:	73 1a                	jae    f010107b <page_alloc+0x72>
		memset(page2kva(page), 0, PGSIZE); 
f0101061:	83 ec 04             	sub    $0x4,%esp
f0101064:	68 00 10 00 00       	push   $0x1000
f0101069:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f010106b:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101070:	50                   	push   %eax
f0101071:	e8 09 2b 00 00       	call   f0103b7f <memset>
f0101076:	83 c4 10             	add    $0x10,%esp
f0101079:	eb bc                	jmp    f0101037 <page_alloc+0x2e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010107b:	50                   	push   %eax
f010107c:	8d 83 70 a4 fe ff    	lea    -0x15b90(%ebx),%eax
f0101082:	50                   	push   %eax
f0101083:	6a 52                	push   $0x52
f0101085:	8d 83 2c ac fe ff    	lea    -0x153d4(%ebx),%eax
f010108b:	50                   	push   %eax
f010108c:	e8 7a f0 ff ff       	call   f010010b <_panic>

f0101091 <page_free>:
{
f0101091:	55                   	push   %ebp
f0101092:	89 e5                	mov    %esp,%ebp
f0101094:	53                   	push   %ebx
f0101095:	83 ec 04             	sub    $0x4,%esp
f0101098:	e8 24 f1 ff ff       	call   f01001c1 <__x86.get_pc_thunk.bx>
f010109d:	81 c3 cb 8f 01 00    	add    $0x18fcb,%ebx
f01010a3:	8b 45 08             	mov    0x8(%ebp),%eax
	if (pp->pp_ref || pp->pp_link) {
f01010a6:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f01010ab:	75 18                	jne    f01010c5 <page_free+0x34>
f01010ad:	83 38 00             	cmpl   $0x0,(%eax)
f01010b0:	75 13                	jne    f01010c5 <page_free+0x34>
	pp->pp_link = page_free_list;
f01010b2:	8b 8b 54 02 00 00    	mov    0x254(%ebx),%ecx
f01010b8:	89 08                	mov    %ecx,(%eax)
	page_free_list = pp;
f01010ba:	89 83 54 02 00 00    	mov    %eax,0x254(%ebx)
}
f01010c0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01010c3:	c9                   	leave  
f01010c4:	c3                   	ret    
		panic("page_free: double check failed when dealloc page. '\n");
f01010c5:	83 ec 04             	sub    $0x4,%esp
f01010c8:	8d 83 a0 a5 fe ff    	lea    -0x15a60(%ebx),%eax
f01010ce:	50                   	push   %eax
f01010cf:	68 3e 01 00 00       	push   $0x13e
f01010d4:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f01010da:	50                   	push   %eax
f01010db:	e8 2b f0 ff ff       	call   f010010b <_panic>

f01010e0 <page_decref>:
{
f01010e0:	55                   	push   %ebp
f01010e1:	89 e5                	mov    %esp,%ebp
f01010e3:	83 ec 08             	sub    $0x8,%esp
f01010e6:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f01010e9:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f01010ed:	83 e8 01             	sub    $0x1,%eax
f01010f0:	66 89 42 04          	mov    %ax,0x4(%edx)
f01010f4:	66 85 c0             	test   %ax,%ax
f01010f7:	74 02                	je     f01010fb <page_decref+0x1b>
}
f01010f9:	c9                   	leave  
f01010fa:	c3                   	ret    
		page_free(pp);
f01010fb:	83 ec 0c             	sub    $0xc,%esp
f01010fe:	52                   	push   %edx
f01010ff:	e8 8d ff ff ff       	call   f0101091 <page_free>
f0101104:	83 c4 10             	add    $0x10,%esp
}
f0101107:	eb f0                	jmp    f01010f9 <page_decref+0x19>

f0101109 <pgdir_walk>:
{
f0101109:	55                   	push   %ebp
f010110a:	89 e5                	mov    %esp,%ebp
f010110c:	57                   	push   %edi
f010110d:	56                   	push   %esi
f010110e:	53                   	push   %ebx
f010110f:	83 ec 0c             	sub    $0xc,%esp
f0101112:	e8 aa f0 ff ff       	call   f01001c1 <__x86.get_pc_thunk.bx>
f0101117:	81 c3 51 8f 01 00    	add    $0x18f51,%ebx
f010111d:	8b 45 0c             	mov    0xc(%ebp),%eax
	uint32_t ptx = PTX(va);		
f0101120:	89 c6                	mov    %eax,%esi
f0101122:	c1 ee 0c             	shr    $0xc,%esi
f0101125:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
	uint32_t pdx = PDX(va);		
f010112b:	c1 e8 16             	shr    $0x16,%eax
	if (pgdir[pdx] & PTE_P) {
f010112e:	8d 3c 85 00 00 00 00 	lea    0x0(,%eax,4),%edi
f0101135:	03 7d 08             	add    0x8(%ebp),%edi
f0101138:	8b 07                	mov    (%edi),%eax
f010113a:	a8 01                	test   $0x1,%al
f010113c:	74 3d                	je     f010117b <pgdir_walk+0x72>
		pgtab = KADDR(PTE_ADDR(pgdir[pdx]));
f010113e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0101143:	89 c2                	mov    %eax,%edx
f0101145:	c1 ea 0c             	shr    $0xc,%edx
f0101148:	c7 c1 e8 a6 11 f0    	mov    $0xf011a6e8,%ecx
f010114e:	39 11                	cmp    %edx,(%ecx)
f0101150:	76 10                	jbe    f0101162 <pgdir_walk+0x59>
	return (void *)(pa + KERNBASE);
f0101152:	2d 00 00 00 10       	sub    $0x10000000,%eax
	return &pgtab[ptx];
f0101157:	8d 04 b0             	lea    (%eax,%esi,4),%eax
}
f010115a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010115d:	5b                   	pop    %ebx
f010115e:	5e                   	pop    %esi
f010115f:	5f                   	pop    %edi
f0101160:	5d                   	pop    %ebp
f0101161:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101162:	50                   	push   %eax
f0101163:	8d 83 70 a4 fe ff    	lea    -0x15b90(%ebx),%eax
f0101169:	50                   	push   %eax
f010116a:	68 6e 01 00 00       	push   $0x16e
f010116f:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f0101175:	50                   	push   %eax
f0101176:	e8 90 ef ff ff       	call   f010010b <_panic>
		if (create) {
f010117b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f010117f:	74 58                	je     f01011d9 <pgdir_walk+0xd0>
			struct PageInfo *new_pginfo = page_alloc(ALLOC_ZERO);	
f0101181:	83 ec 0c             	sub    $0xc,%esp
f0101184:	6a 01                	push   $0x1
f0101186:	e8 7e fe ff ff       	call   f0101009 <page_alloc>
			if (new_pginfo) {
f010118b:	83 c4 10             	add    $0x10,%esp
f010118e:	85 c0                	test   %eax,%eax
f0101190:	74 51                	je     f01011e3 <pgdir_walk+0xda>
				new_pginfo->pp_ref += 1;
f0101192:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f0101197:	c7 c2 f0 a6 11 f0    	mov    $0xf011a6f0,%edx
f010119d:	2b 02                	sub    (%edx),%eax
f010119f:	89 c2                	mov    %eax,%edx
f01011a1:	c1 fa 03             	sar    $0x3,%edx
f01011a4:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f01011a7:	89 d1                	mov    %edx,%ecx
f01011a9:	c1 e9 0c             	shr    $0xc,%ecx
f01011ac:	c7 c0 e8 a6 11 f0    	mov    $0xf011a6e8,%eax
f01011b2:	3b 08                	cmp    (%eax),%ecx
f01011b4:	73 0d                	jae    f01011c3 <pgdir_walk+0xba>
	return (void *)(pa + KERNBASE);
f01011b6:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
				pgdir[pdx] = page2pa(new_pginfo) | PTE_P | PTE_W | PTE_U;
f01011bc:	83 ca 07             	or     $0x7,%edx
f01011bf:	89 17                	mov    %edx,(%edi)
f01011c1:	eb 94                	jmp    f0101157 <pgdir_walk+0x4e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01011c3:	52                   	push   %edx
f01011c4:	8d 83 70 a4 fe ff    	lea    -0x15b90(%ebx),%eax
f01011ca:	50                   	push   %eax
f01011cb:	6a 52                	push   $0x52
f01011cd:	8d 83 2c ac fe ff    	lea    -0x153d4(%ebx),%eax
f01011d3:	50                   	push   %eax
f01011d4:	e8 32 ef ff ff       	call   f010010b <_panic>
			return NULL;
f01011d9:	b8 00 00 00 00       	mov    $0x0,%eax
f01011de:	e9 77 ff ff ff       	jmp    f010115a <pgdir_walk+0x51>
			return NULL; 
f01011e3:	b8 00 00 00 00       	mov    $0x0,%eax
f01011e8:	e9 6d ff ff ff       	jmp    f010115a <pgdir_walk+0x51>

f01011ed <boot_map_region>:
{
f01011ed:	55                   	push   %ebp
f01011ee:	89 e5                	mov    %esp,%ebp
f01011f0:	57                   	push   %edi
f01011f1:	56                   	push   %esi
f01011f2:	53                   	push   %ebx
f01011f3:	83 ec 1c             	sub    $0x1c,%esp
f01011f6:	89 c7                	mov    %eax,%edi
f01011f8:	8b 45 08             	mov    0x8(%ebp),%eax
f01011fb:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0101201:	01 c1                	add    %eax,%ecx
f0101203:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	for (size_t i = 0;i < pg_num; i++) {
f0101206:	89 c3                	mov    %eax,%ebx
		pte = pgdir_walk(pgdir, (void *)va, 1);		 
f0101208:	89 d6                	mov    %edx,%esi
f010120a:	29 c6                	sub    %eax,%esi
	for (size_t i = 0;i < pg_num; i++) {
f010120c:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f010120f:	74 28                	je     f0101239 <boot_map_region+0x4c>
		pte = pgdir_walk(pgdir, (void *)va, 1);		 
f0101211:	83 ec 04             	sub    $0x4,%esp
f0101214:	6a 01                	push   $0x1
f0101216:	8d 04 1e             	lea    (%esi,%ebx,1),%eax
f0101219:	50                   	push   %eax
f010121a:	57                   	push   %edi
f010121b:	e8 e9 fe ff ff       	call   f0101109 <pgdir_walk>
		if (!pte) {
f0101220:	83 c4 10             	add    $0x10,%esp
f0101223:	85 c0                	test   %eax,%eax
f0101225:	74 12                	je     f0101239 <boot_map_region+0x4c>
		*pte = pa | perm | PTE_P;
f0101227:	89 da                	mov    %ebx,%edx
f0101229:	0b 55 0c             	or     0xc(%ebp),%edx
f010122c:	83 ca 01             	or     $0x1,%edx
f010122f:	89 10                	mov    %edx,(%eax)
		pa += PGSIZE;
f0101231:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0101237:	eb d3                	jmp    f010120c <boot_map_region+0x1f>
}
f0101239:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010123c:	5b                   	pop    %ebx
f010123d:	5e                   	pop    %esi
f010123e:	5f                   	pop    %edi
f010123f:	5d                   	pop    %ebp
f0101240:	c3                   	ret    

f0101241 <page_lookup>:
{
f0101241:	55                   	push   %ebp
f0101242:	89 e5                	mov    %esp,%ebp
f0101244:	53                   	push   %ebx
f0101245:	83 ec 08             	sub    $0x8,%esp
f0101248:	e8 74 ef ff ff       	call   f01001c1 <__x86.get_pc_thunk.bx>
f010124d:	81 c3 1b 8e 01 00    	add    $0x18e1b,%ebx
	pte_t *pte = pgdir_walk(pgdir, va, 0);
f0101253:	6a 00                	push   $0x0
f0101255:	ff 75 0c             	pushl  0xc(%ebp)
f0101258:	ff 75 08             	pushl  0x8(%ebp)
f010125b:	e8 a9 fe ff ff       	call   f0101109 <pgdir_walk>
	if (!pte) {
f0101260:	83 c4 10             	add    $0x10,%esp
f0101263:	85 c0                	test   %eax,%eax
f0101265:	74 47                	je     f01012ae <page_lookup+0x6d>
		*pte_store = pte;
f0101267:	8b 55 10             	mov    0x10(%ebp),%edx
f010126a:	89 02                	mov    %eax,(%edx)
	 	if (*pte) {
f010126c:	8b 10                	mov    (%eax),%edx
	return NULL;
f010126e:	b8 00 00 00 00       	mov    $0x0,%eax
	 	if (*pte) {
f0101273:	85 d2                	test   %edx,%edx
f0101275:	75 05                	jne    f010127c <page_lookup+0x3b>
}
f0101277:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010127a:	c9                   	leave  
f010127b:	c3                   	ret    
f010127c:	c1 ea 0c             	shr    $0xc,%edx
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010127f:	c7 c0 e8 a6 11 f0    	mov    $0xf011a6e8,%eax
f0101285:	39 10                	cmp    %edx,(%eax)
f0101287:	76 0d                	jbe    f0101296 <page_lookup+0x55>
		panic("pa2page called with invalid pa");
	return &pages[PGNUM(pa)];
f0101289:	c7 c0 f0 a6 11 f0    	mov    $0xf011a6f0,%eax
f010128f:	8b 00                	mov    (%eax),%eax
f0101291:	8d 04 d0             	lea    (%eax,%edx,8),%eax
			return pa2page(PTE_ADDR(*pte)); 
f0101294:	eb e1                	jmp    f0101277 <page_lookup+0x36>
		panic("pa2page called with invalid pa");
f0101296:	83 ec 04             	sub    $0x4,%esp
f0101299:	8d 83 d8 a5 fe ff    	lea    -0x15a28(%ebx),%eax
f010129f:	50                   	push   %eax
f01012a0:	6a 4b                	push   $0x4b
f01012a2:	8d 83 2c ac fe ff    	lea    -0x153d4(%ebx),%eax
f01012a8:	50                   	push   %eax
f01012a9:	e8 5d ee ff ff       	call   f010010b <_panic>
		 return NULL;
f01012ae:	b8 00 00 00 00       	mov    $0x0,%eax
f01012b3:	eb c2                	jmp    f0101277 <page_lookup+0x36>

f01012b5 <page_remove>:
{
f01012b5:	55                   	push   %ebp
f01012b6:	89 e5                	mov    %esp,%ebp
f01012b8:	53                   	push   %ebx
f01012b9:	83 ec 18             	sub    $0x18,%esp
f01012bc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct PageInfo *pginfo = page_lookup(pgdir, va, pte_store);
f01012bf:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01012c2:	50                   	push   %eax
f01012c3:	53                   	push   %ebx
f01012c4:	ff 75 08             	pushl  0x8(%ebp)
f01012c7:	e8 75 ff ff ff       	call   f0101241 <page_lookup>
	if (pginfo) {
f01012cc:	83 c4 10             	add    $0x10,%esp
f01012cf:	85 c0                	test   %eax,%eax
f01012d1:	74 18                	je     f01012eb <page_remove+0x36>
		page_decref(pginfo);
f01012d3:	83 ec 0c             	sub    $0xc,%esp
f01012d6:	50                   	push   %eax
f01012d7:	e8 04 fe ff ff       	call   f01010e0 <page_decref>
		*pte = 0;	 
f01012dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01012df:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01012e5:	0f 01 3b             	invlpg (%ebx)
f01012e8:	83 c4 10             	add    $0x10,%esp
}
f01012eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01012ee:	c9                   	leave  
f01012ef:	c3                   	ret    

f01012f0 <page_insert>:
{
f01012f0:	55                   	push   %ebp
f01012f1:	89 e5                	mov    %esp,%ebp
f01012f3:	57                   	push   %edi
f01012f4:	56                   	push   %esi
f01012f5:	53                   	push   %ebx
f01012f6:	83 ec 10             	sub    $0x10,%esp
f01012f9:	e8 d5 1b 00 00       	call   f0102ed3 <__x86.get_pc_thunk.di>
f01012fe:	81 c7 6a 8d 01 00    	add    $0x18d6a,%edi
f0101304:	8b 75 0c             	mov    0xc(%ebp),%esi
	pte_t *pte = pgdir_walk(pgdir, va, 1);	
f0101307:	6a 01                	push   $0x1
f0101309:	ff 75 10             	pushl  0x10(%ebp)
f010130c:	ff 75 08             	pushl  0x8(%ebp)
f010130f:	e8 f5 fd ff ff       	call   f0101109 <pgdir_walk>
	if (!pte) {
f0101314:	83 c4 10             	add    $0x10,%esp
f0101317:	85 c0                	test   %eax,%eax
f0101319:	74 44                	je     f010135f <page_insert+0x6f>
f010131b:	89 c3                	mov    %eax,%ebx
	pp->pp_ref++;
f010131d:	66 83 46 04 01       	addw   $0x1,0x4(%esi)
	if (*pte & PTE_P) {
f0101322:	f6 00 01             	testb  $0x1,(%eax)
f0101325:	75 25                	jne    f010134c <page_insert+0x5c>
	return (pp - pages) << PGSHIFT;
f0101327:	c7 c0 f0 a6 11 f0    	mov    $0xf011a6f0,%eax
f010132d:	2b 30                	sub    (%eax),%esi
f010132f:	89 f0                	mov    %esi,%eax
f0101331:	c1 f8 03             	sar    $0x3,%eax
f0101334:	c1 e0 0c             	shl    $0xc,%eax
	*pte = page2pa(pp) | perm | PTE_P;
f0101337:	0b 45 14             	or     0x14(%ebp),%eax
f010133a:	83 c8 01             	or     $0x1,%eax
f010133d:	89 03                	mov    %eax,(%ebx)
	return 0;
f010133f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101344:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101347:	5b                   	pop    %ebx
f0101348:	5e                   	pop    %esi
f0101349:	5f                   	pop    %edi
f010134a:	5d                   	pop    %ebp
f010134b:	c3                   	ret    
		 page_remove(pgdir, va);
f010134c:	83 ec 08             	sub    $0x8,%esp
f010134f:	ff 75 10             	pushl  0x10(%ebp)
f0101352:	ff 75 08             	pushl  0x8(%ebp)
f0101355:	e8 5b ff ff ff       	call   f01012b5 <page_remove>
f010135a:	83 c4 10             	add    $0x10,%esp
f010135d:	eb c8                	jmp    f0101327 <page_insert+0x37>
		 return -E_NO_MEM;
f010135f:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0101364:	eb de                	jmp    f0101344 <page_insert+0x54>

f0101366 <mem_init>:
{
f0101366:	55                   	push   %ebp
f0101367:	89 e5                	mov    %esp,%ebp
f0101369:	57                   	push   %edi
f010136a:	56                   	push   %esi
f010136b:	53                   	push   %ebx
f010136c:	83 ec 3c             	sub    $0x3c,%esp
f010136f:	e8 4d ee ff ff       	call   f01001c1 <__x86.get_pc_thunk.bx>
f0101374:	81 c3 f4 8c 01 00    	add    $0x18cf4,%ebx
	basemem = nvram_read(NVRAM_BASELO);
f010137a:	b8 15 00 00 00       	mov    $0x15,%eax
f010137f:	e8 37 f7 ff ff       	call   f0100abb <nvram_read>
f0101384:	89 c6                	mov    %eax,%esi
	extmem = nvram_read(NVRAM_EXTLO);
f0101386:	b8 17 00 00 00       	mov    $0x17,%eax
f010138b:	e8 2b f7 ff ff       	call   f0100abb <nvram_read>
f0101390:	89 c7                	mov    %eax,%edi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f0101392:	b8 34 00 00 00       	mov    $0x34,%eax
f0101397:	e8 1f f7 ff ff       	call   f0100abb <nvram_read>
	if (ext16mem)
f010139c:	c1 e0 06             	shl    $0x6,%eax
f010139f:	0f 84 c6 00 00 00    	je     f010146b <mem_init+0x105>
		totalmem = 16 * 1024 + ext16mem;
f01013a5:	05 00 40 00 00       	add    $0x4000,%eax
	npages = totalmem / (PGSIZE / 1024);
f01013aa:	89 c1                	mov    %eax,%ecx
f01013ac:	c1 e9 02             	shr    $0x2,%ecx
f01013af:	c7 c2 e8 a6 11 f0    	mov    $0xf011a6e8,%edx
f01013b5:	89 0a                	mov    %ecx,(%edx)
	npages_basemem = basemem / (PGSIZE / 1024);
f01013b7:	89 f2                	mov    %esi,%edx
f01013b9:	c1 ea 02             	shr    $0x2,%edx
f01013bc:	89 93 58 02 00 00    	mov    %edx,0x258(%ebx)
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01013c2:	89 c2                	mov    %eax,%edx
f01013c4:	29 f2                	sub    %esi,%edx
f01013c6:	52                   	push   %edx
f01013c7:	56                   	push   %esi
f01013c8:	50                   	push   %eax
f01013c9:	8d 83 f8 a5 fe ff    	lea    -0x15a08(%ebx),%eax
f01013cf:	50                   	push   %eax
f01013d0:	e8 89 1b 00 00       	call   f0102f5e <cprintf>
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01013d5:	b8 00 10 00 00       	mov    $0x1000,%eax
f01013da:	e8 93 f6 ff ff       	call   f0100a72 <boot_alloc>
f01013df:	c7 c6 ec a6 11 f0    	mov    $0xf011a6ec,%esi
f01013e5:	89 06                	mov    %eax,(%esi)
	memset(kern_pgdir, 0, PGSIZE);
f01013e7:	83 c4 0c             	add    $0xc,%esp
f01013ea:	68 00 10 00 00       	push   $0x1000
f01013ef:	6a 00                	push   $0x0
f01013f1:	50                   	push   %eax
f01013f2:	e8 88 27 00 00       	call   f0103b7f <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01013f7:	8b 06                	mov    (%esi),%eax
	if ((uint32_t)kva < KERNBASE)
f01013f9:	83 c4 10             	add    $0x10,%esp
f01013fc:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101401:	76 78                	jbe    f010147b <mem_init+0x115>
	return (physaddr_t)kva - KERNBASE;
f0101403:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101409:	83 ca 05             	or     $0x5,%edx
f010140c:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	pages = (struct PageInfo*) boot_alloc(npages * sizeof(struct PageInfo));
f0101412:	c7 c7 e8 a6 11 f0    	mov    $0xf011a6e8,%edi
f0101418:	8b 07                	mov    (%edi),%eax
f010141a:	c1 e0 03             	shl    $0x3,%eax
f010141d:	e8 50 f6 ff ff       	call   f0100a72 <boot_alloc>
f0101422:	c7 c6 f0 a6 11 f0    	mov    $0xf011a6f0,%esi
f0101428:	89 06                	mov    %eax,(%esi)
	memset(pages, 0, npages * sizeof(struct PageInfo));
f010142a:	83 ec 04             	sub    $0x4,%esp
f010142d:	8b 17                	mov    (%edi),%edx
f010142f:	c1 e2 03             	shl    $0x3,%edx
f0101432:	52                   	push   %edx
f0101433:	6a 00                	push   $0x0
f0101435:	50                   	push   %eax
f0101436:	e8 44 27 00 00       	call   f0103b7f <memset>
	page_init();
f010143b:	e8 a8 fa ff ff       	call   f0100ee8 <page_init>
	check_page_free_list(1);
f0101440:	b8 01 00 00 00       	mov    $0x1,%eax
f0101445:	e8 24 f7 ff ff       	call   f0100b6e <check_page_free_list>
	if (!pages)
f010144a:	83 c4 10             	add    $0x10,%esp
f010144d:	83 3e 00             	cmpl   $0x0,(%esi)
f0101450:	74 42                	je     f0101494 <mem_init+0x12e>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101452:	8b 83 54 02 00 00    	mov    0x254(%ebx),%eax
f0101458:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
f010145f:	85 c0                	test   %eax,%eax
f0101461:	74 4c                	je     f01014af <mem_init+0x149>
		++nfree;
f0101463:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101467:	8b 00                	mov    (%eax),%eax
f0101469:	eb f4                	jmp    f010145f <mem_init+0xf9>
		totalmem = 1 * 1024 + extmem;
f010146b:	8d 87 00 04 00 00    	lea    0x400(%edi),%eax
f0101471:	85 ff                	test   %edi,%edi
f0101473:	0f 44 c6             	cmove  %esi,%eax
f0101476:	e9 2f ff ff ff       	jmp    f01013aa <mem_init+0x44>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010147b:	50                   	push   %eax
f010147c:	8d 83 7c a5 fe ff    	lea    -0x15a84(%ebx),%eax
f0101482:	50                   	push   %eax
f0101483:	68 8f 00 00 00       	push   $0x8f
f0101488:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f010148e:	50                   	push   %eax
f010148f:	e8 77 ec ff ff       	call   f010010b <_panic>
		panic("'pages' is a null pointer!");
f0101494:	83 ec 04             	sub    $0x4,%esp
f0101497:	8d 83 d6 ac fe ff    	lea    -0x1532a(%ebx),%eax
f010149d:	50                   	push   %eax
f010149e:	68 5a 02 00 00       	push   $0x25a
f01014a3:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f01014a9:	50                   	push   %eax
f01014aa:	e8 5c ec ff ff       	call   f010010b <_panic>
	assert((pp0 = page_alloc(0)));
f01014af:	83 ec 0c             	sub    $0xc,%esp
f01014b2:	6a 00                	push   $0x0
f01014b4:	e8 50 fb ff ff       	call   f0101009 <page_alloc>
f01014b9:	89 c6                	mov    %eax,%esi
f01014bb:	83 c4 10             	add    $0x10,%esp
f01014be:	85 c0                	test   %eax,%eax
f01014c0:	0f 84 20 02 00 00    	je     f01016e6 <mem_init+0x380>
	assert((pp1 = page_alloc(0)));
f01014c6:	83 ec 0c             	sub    $0xc,%esp
f01014c9:	6a 00                	push   $0x0
f01014cb:	e8 39 fb ff ff       	call   f0101009 <page_alloc>
f01014d0:	89 c7                	mov    %eax,%edi
f01014d2:	83 c4 10             	add    $0x10,%esp
f01014d5:	85 c0                	test   %eax,%eax
f01014d7:	0f 84 28 02 00 00    	je     f0101705 <mem_init+0x39f>
	assert((pp2 = page_alloc(0)));
f01014dd:	83 ec 0c             	sub    $0xc,%esp
f01014e0:	6a 00                	push   $0x0
f01014e2:	e8 22 fb ff ff       	call   f0101009 <page_alloc>
f01014e7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01014ea:	83 c4 10             	add    $0x10,%esp
f01014ed:	85 c0                	test   %eax,%eax
f01014ef:	0f 84 2f 02 00 00    	je     f0101724 <mem_init+0x3be>
	assert(pp1 && pp1 != pp0);
f01014f5:	39 fe                	cmp    %edi,%esi
f01014f7:	0f 84 46 02 00 00    	je     f0101743 <mem_init+0x3dd>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01014fd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101500:	39 c7                	cmp    %eax,%edi
f0101502:	0f 84 5a 02 00 00    	je     f0101762 <mem_init+0x3fc>
f0101508:	39 c6                	cmp    %eax,%esi
f010150a:	0f 84 52 02 00 00    	je     f0101762 <mem_init+0x3fc>
	return (pp - pages) << PGSHIFT;
f0101510:	c7 c0 f0 a6 11 f0    	mov    $0xf011a6f0,%eax
f0101516:	8b 08                	mov    (%eax),%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101518:	c7 c0 e8 a6 11 f0    	mov    $0xf011a6e8,%eax
f010151e:	8b 10                	mov    (%eax),%edx
f0101520:	c1 e2 0c             	shl    $0xc,%edx
f0101523:	89 f0                	mov    %esi,%eax
f0101525:	29 c8                	sub    %ecx,%eax
f0101527:	c1 f8 03             	sar    $0x3,%eax
f010152a:	c1 e0 0c             	shl    $0xc,%eax
f010152d:	39 d0                	cmp    %edx,%eax
f010152f:	0f 83 4c 02 00 00    	jae    f0101781 <mem_init+0x41b>
f0101535:	89 f8                	mov    %edi,%eax
f0101537:	29 c8                	sub    %ecx,%eax
f0101539:	c1 f8 03             	sar    $0x3,%eax
f010153c:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp1) < npages*PGSIZE);
f010153f:	39 c2                	cmp    %eax,%edx
f0101541:	0f 86 59 02 00 00    	jbe    f01017a0 <mem_init+0x43a>
f0101547:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010154a:	29 c8                	sub    %ecx,%eax
f010154c:	c1 f8 03             	sar    $0x3,%eax
f010154f:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp2) < npages*PGSIZE);
f0101552:	39 c2                	cmp    %eax,%edx
f0101554:	0f 86 65 02 00 00    	jbe    f01017bf <mem_init+0x459>
	fl = page_free_list;
f010155a:	8b 83 54 02 00 00    	mov    0x254(%ebx),%eax
f0101560:	89 45 cc             	mov    %eax,-0x34(%ebp)
	page_free_list = 0;
f0101563:	c7 83 54 02 00 00 00 	movl   $0x0,0x254(%ebx)
f010156a:	00 00 00 
	assert(!page_alloc(0));
f010156d:	83 ec 0c             	sub    $0xc,%esp
f0101570:	6a 00                	push   $0x0
f0101572:	e8 92 fa ff ff       	call   f0101009 <page_alloc>
f0101577:	83 c4 10             	add    $0x10,%esp
f010157a:	85 c0                	test   %eax,%eax
f010157c:	0f 85 5c 02 00 00    	jne    f01017de <mem_init+0x478>
	page_free(pp0);
f0101582:	83 ec 0c             	sub    $0xc,%esp
f0101585:	56                   	push   %esi
f0101586:	e8 06 fb ff ff       	call   f0101091 <page_free>
	page_free(pp1);
f010158b:	89 3c 24             	mov    %edi,(%esp)
f010158e:	e8 fe fa ff ff       	call   f0101091 <page_free>
	page_free(pp2);
f0101593:	83 c4 04             	add    $0x4,%esp
f0101596:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101599:	e8 f3 fa ff ff       	call   f0101091 <page_free>
	assert((pp0 = page_alloc(0)));
f010159e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01015a5:	e8 5f fa ff ff       	call   f0101009 <page_alloc>
f01015aa:	89 c6                	mov    %eax,%esi
f01015ac:	83 c4 10             	add    $0x10,%esp
f01015af:	85 c0                	test   %eax,%eax
f01015b1:	0f 84 46 02 00 00    	je     f01017fd <mem_init+0x497>
	assert((pp1 = page_alloc(0)));
f01015b7:	83 ec 0c             	sub    $0xc,%esp
f01015ba:	6a 00                	push   $0x0
f01015bc:	e8 48 fa ff ff       	call   f0101009 <page_alloc>
f01015c1:	89 c7                	mov    %eax,%edi
f01015c3:	83 c4 10             	add    $0x10,%esp
f01015c6:	85 c0                	test   %eax,%eax
f01015c8:	0f 84 4e 02 00 00    	je     f010181c <mem_init+0x4b6>
	assert((pp2 = page_alloc(0)));
f01015ce:	83 ec 0c             	sub    $0xc,%esp
f01015d1:	6a 00                	push   $0x0
f01015d3:	e8 31 fa ff ff       	call   f0101009 <page_alloc>
f01015d8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01015db:	83 c4 10             	add    $0x10,%esp
f01015de:	85 c0                	test   %eax,%eax
f01015e0:	0f 84 55 02 00 00    	je     f010183b <mem_init+0x4d5>
	assert(pp1 && pp1 != pp0);
f01015e6:	39 fe                	cmp    %edi,%esi
f01015e8:	0f 84 6c 02 00 00    	je     f010185a <mem_init+0x4f4>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01015ee:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01015f1:	39 c7                	cmp    %eax,%edi
f01015f3:	0f 84 80 02 00 00    	je     f0101879 <mem_init+0x513>
f01015f9:	39 c6                	cmp    %eax,%esi
f01015fb:	0f 84 78 02 00 00    	je     f0101879 <mem_init+0x513>
	assert(!page_alloc(0));
f0101601:	83 ec 0c             	sub    $0xc,%esp
f0101604:	6a 00                	push   $0x0
f0101606:	e8 fe f9 ff ff       	call   f0101009 <page_alloc>
f010160b:	83 c4 10             	add    $0x10,%esp
f010160e:	85 c0                	test   %eax,%eax
f0101610:	0f 85 82 02 00 00    	jne    f0101898 <mem_init+0x532>
f0101616:	c7 c0 f0 a6 11 f0    	mov    $0xf011a6f0,%eax
f010161c:	89 f1                	mov    %esi,%ecx
f010161e:	2b 08                	sub    (%eax),%ecx
f0101620:	89 c8                	mov    %ecx,%eax
f0101622:	c1 f8 03             	sar    $0x3,%eax
f0101625:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0101628:	89 c1                	mov    %eax,%ecx
f010162a:	c1 e9 0c             	shr    $0xc,%ecx
f010162d:	c7 c2 e8 a6 11 f0    	mov    $0xf011a6e8,%edx
f0101633:	3b 0a                	cmp    (%edx),%ecx
f0101635:	0f 83 7c 02 00 00    	jae    f01018b7 <mem_init+0x551>
	memset(page2kva(pp0), 1, PGSIZE);
f010163b:	83 ec 04             	sub    $0x4,%esp
f010163e:	68 00 10 00 00       	push   $0x1000
f0101643:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0101645:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010164a:	50                   	push   %eax
f010164b:	e8 2f 25 00 00       	call   f0103b7f <memset>
	page_free(pp0);
f0101650:	89 34 24             	mov    %esi,(%esp)
f0101653:	e8 39 fa ff ff       	call   f0101091 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101658:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010165f:	e8 a5 f9 ff ff       	call   f0101009 <page_alloc>
f0101664:	83 c4 10             	add    $0x10,%esp
f0101667:	85 c0                	test   %eax,%eax
f0101669:	0f 84 5e 02 00 00    	je     f01018cd <mem_init+0x567>
	assert(pp && pp0 == pp);
f010166f:	39 c6                	cmp    %eax,%esi
f0101671:	0f 85 75 02 00 00    	jne    f01018ec <mem_init+0x586>
	return (pp - pages) << PGSHIFT;
f0101677:	c7 c2 f0 a6 11 f0    	mov    $0xf011a6f0,%edx
f010167d:	2b 02                	sub    (%edx),%eax
f010167f:	c1 f8 03             	sar    $0x3,%eax
f0101682:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0101685:	89 c1                	mov    %eax,%ecx
f0101687:	c1 e9 0c             	shr    $0xc,%ecx
f010168a:	c7 c2 e8 a6 11 f0    	mov    $0xf011a6e8,%edx
f0101690:	3b 0a                	cmp    (%edx),%ecx
f0101692:	0f 83 73 02 00 00    	jae    f010190b <mem_init+0x5a5>
	return (void *)(pa + KERNBASE);
f0101698:	8d 90 00 00 00 f0    	lea    -0x10000000(%eax),%edx
f010169e:	2d 00 f0 ff 0f       	sub    $0xffff000,%eax
		assert(c[i] == 0);
f01016a3:	80 3a 00             	cmpb   $0x0,(%edx)
f01016a6:	0f 85 75 02 00 00    	jne    f0101921 <mem_init+0x5bb>
f01016ac:	83 c2 01             	add    $0x1,%edx
	for (i = 0; i < PGSIZE; i++)
f01016af:	39 c2                	cmp    %eax,%edx
f01016b1:	75 f0                	jne    f01016a3 <mem_init+0x33d>
	page_free_list = fl;
f01016b3:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01016b6:	89 83 54 02 00 00    	mov    %eax,0x254(%ebx)
	page_free(pp0);
f01016bc:	83 ec 0c             	sub    $0xc,%esp
f01016bf:	56                   	push   %esi
f01016c0:	e8 cc f9 ff ff       	call   f0101091 <page_free>
	page_free(pp1);
f01016c5:	89 3c 24             	mov    %edi,(%esp)
f01016c8:	e8 c4 f9 ff ff       	call   f0101091 <page_free>
	page_free(pp2);
f01016cd:	83 c4 04             	add    $0x4,%esp
f01016d0:	ff 75 d4             	pushl  -0x2c(%ebp)
f01016d3:	e8 b9 f9 ff ff       	call   f0101091 <page_free>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01016d8:	8b 83 54 02 00 00    	mov    0x254(%ebx),%eax
f01016de:	83 c4 10             	add    $0x10,%esp
f01016e1:	e9 60 02 00 00       	jmp    f0101946 <mem_init+0x5e0>
	assert((pp0 = page_alloc(0)));
f01016e6:	8d 83 f1 ac fe ff    	lea    -0x1530f(%ebx),%eax
f01016ec:	50                   	push   %eax
f01016ed:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f01016f3:	50                   	push   %eax
f01016f4:	68 62 02 00 00       	push   $0x262
f01016f9:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f01016ff:	50                   	push   %eax
f0101700:	e8 06 ea ff ff       	call   f010010b <_panic>
	assert((pp1 = page_alloc(0)));
f0101705:	8d 83 07 ad fe ff    	lea    -0x152f9(%ebx),%eax
f010170b:	50                   	push   %eax
f010170c:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f0101712:	50                   	push   %eax
f0101713:	68 63 02 00 00       	push   $0x263
f0101718:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f010171e:	50                   	push   %eax
f010171f:	e8 e7 e9 ff ff       	call   f010010b <_panic>
	assert((pp2 = page_alloc(0)));
f0101724:	8d 83 1d ad fe ff    	lea    -0x152e3(%ebx),%eax
f010172a:	50                   	push   %eax
f010172b:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f0101731:	50                   	push   %eax
f0101732:	68 64 02 00 00       	push   $0x264
f0101737:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f010173d:	50                   	push   %eax
f010173e:	e8 c8 e9 ff ff       	call   f010010b <_panic>
	assert(pp1 && pp1 != pp0);
f0101743:	8d 83 33 ad fe ff    	lea    -0x152cd(%ebx),%eax
f0101749:	50                   	push   %eax
f010174a:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f0101750:	50                   	push   %eax
f0101751:	68 67 02 00 00       	push   $0x267
f0101756:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f010175c:	50                   	push   %eax
f010175d:	e8 a9 e9 ff ff       	call   f010010b <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101762:	8d 83 34 a6 fe ff    	lea    -0x159cc(%ebx),%eax
f0101768:	50                   	push   %eax
f0101769:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f010176f:	50                   	push   %eax
f0101770:	68 68 02 00 00       	push   $0x268
f0101775:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f010177b:	50                   	push   %eax
f010177c:	e8 8a e9 ff ff       	call   f010010b <_panic>
	assert(page2pa(pp0) < npages*PGSIZE);
f0101781:	8d 83 45 ad fe ff    	lea    -0x152bb(%ebx),%eax
f0101787:	50                   	push   %eax
f0101788:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f010178e:	50                   	push   %eax
f010178f:	68 69 02 00 00       	push   $0x269
f0101794:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f010179a:	50                   	push   %eax
f010179b:	e8 6b e9 ff ff       	call   f010010b <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f01017a0:	8d 83 62 ad fe ff    	lea    -0x1529e(%ebx),%eax
f01017a6:	50                   	push   %eax
f01017a7:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f01017ad:	50                   	push   %eax
f01017ae:	68 6a 02 00 00       	push   $0x26a
f01017b3:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f01017b9:	50                   	push   %eax
f01017ba:	e8 4c e9 ff ff       	call   f010010b <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f01017bf:	8d 83 7f ad fe ff    	lea    -0x15281(%ebx),%eax
f01017c5:	50                   	push   %eax
f01017c6:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f01017cc:	50                   	push   %eax
f01017cd:	68 6b 02 00 00       	push   $0x26b
f01017d2:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f01017d8:	50                   	push   %eax
f01017d9:	e8 2d e9 ff ff       	call   f010010b <_panic>
	assert(!page_alloc(0));
f01017de:	8d 83 9c ad fe ff    	lea    -0x15264(%ebx),%eax
f01017e4:	50                   	push   %eax
f01017e5:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f01017eb:	50                   	push   %eax
f01017ec:	68 72 02 00 00       	push   $0x272
f01017f1:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f01017f7:	50                   	push   %eax
f01017f8:	e8 0e e9 ff ff       	call   f010010b <_panic>
	assert((pp0 = page_alloc(0)));
f01017fd:	8d 83 f1 ac fe ff    	lea    -0x1530f(%ebx),%eax
f0101803:	50                   	push   %eax
f0101804:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f010180a:	50                   	push   %eax
f010180b:	68 79 02 00 00       	push   $0x279
f0101810:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f0101816:	50                   	push   %eax
f0101817:	e8 ef e8 ff ff       	call   f010010b <_panic>
	assert((pp1 = page_alloc(0)));
f010181c:	8d 83 07 ad fe ff    	lea    -0x152f9(%ebx),%eax
f0101822:	50                   	push   %eax
f0101823:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f0101829:	50                   	push   %eax
f010182a:	68 7a 02 00 00       	push   $0x27a
f010182f:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f0101835:	50                   	push   %eax
f0101836:	e8 d0 e8 ff ff       	call   f010010b <_panic>
	assert((pp2 = page_alloc(0)));
f010183b:	8d 83 1d ad fe ff    	lea    -0x152e3(%ebx),%eax
f0101841:	50                   	push   %eax
f0101842:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f0101848:	50                   	push   %eax
f0101849:	68 7b 02 00 00       	push   $0x27b
f010184e:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f0101854:	50                   	push   %eax
f0101855:	e8 b1 e8 ff ff       	call   f010010b <_panic>
	assert(pp1 && pp1 != pp0);
f010185a:	8d 83 33 ad fe ff    	lea    -0x152cd(%ebx),%eax
f0101860:	50                   	push   %eax
f0101861:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f0101867:	50                   	push   %eax
f0101868:	68 7d 02 00 00       	push   $0x27d
f010186d:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f0101873:	50                   	push   %eax
f0101874:	e8 92 e8 ff ff       	call   f010010b <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101879:	8d 83 34 a6 fe ff    	lea    -0x159cc(%ebx),%eax
f010187f:	50                   	push   %eax
f0101880:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f0101886:	50                   	push   %eax
f0101887:	68 7e 02 00 00       	push   $0x27e
f010188c:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f0101892:	50                   	push   %eax
f0101893:	e8 73 e8 ff ff       	call   f010010b <_panic>
	assert(!page_alloc(0));
f0101898:	8d 83 9c ad fe ff    	lea    -0x15264(%ebx),%eax
f010189e:	50                   	push   %eax
f010189f:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f01018a5:	50                   	push   %eax
f01018a6:	68 7f 02 00 00       	push   $0x27f
f01018ab:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f01018b1:	50                   	push   %eax
f01018b2:	e8 54 e8 ff ff       	call   f010010b <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01018b7:	50                   	push   %eax
f01018b8:	8d 83 70 a4 fe ff    	lea    -0x15b90(%ebx),%eax
f01018be:	50                   	push   %eax
f01018bf:	6a 52                	push   $0x52
f01018c1:	8d 83 2c ac fe ff    	lea    -0x153d4(%ebx),%eax
f01018c7:	50                   	push   %eax
f01018c8:	e8 3e e8 ff ff       	call   f010010b <_panic>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01018cd:	8d 83 ab ad fe ff    	lea    -0x15255(%ebx),%eax
f01018d3:	50                   	push   %eax
f01018d4:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f01018da:	50                   	push   %eax
f01018db:	68 84 02 00 00       	push   $0x284
f01018e0:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f01018e6:	50                   	push   %eax
f01018e7:	e8 1f e8 ff ff       	call   f010010b <_panic>
	assert(pp && pp0 == pp);
f01018ec:	8d 83 c9 ad fe ff    	lea    -0x15237(%ebx),%eax
f01018f2:	50                   	push   %eax
f01018f3:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f01018f9:	50                   	push   %eax
f01018fa:	68 85 02 00 00       	push   $0x285
f01018ff:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f0101905:	50                   	push   %eax
f0101906:	e8 00 e8 ff ff       	call   f010010b <_panic>
f010190b:	50                   	push   %eax
f010190c:	8d 83 70 a4 fe ff    	lea    -0x15b90(%ebx),%eax
f0101912:	50                   	push   %eax
f0101913:	6a 52                	push   $0x52
f0101915:	8d 83 2c ac fe ff    	lea    -0x153d4(%ebx),%eax
f010191b:	50                   	push   %eax
f010191c:	e8 ea e7 ff ff       	call   f010010b <_panic>
		assert(c[i] == 0);
f0101921:	8d 83 d9 ad fe ff    	lea    -0x15227(%ebx),%eax
f0101927:	50                   	push   %eax
f0101928:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f010192e:	50                   	push   %eax
f010192f:	68 88 02 00 00       	push   $0x288
f0101934:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f010193a:	50                   	push   %eax
f010193b:	e8 cb e7 ff ff       	call   f010010b <_panic>
		--nfree;
f0101940:	83 6d d0 01          	subl   $0x1,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101944:	8b 00                	mov    (%eax),%eax
f0101946:	85 c0                	test   %eax,%eax
f0101948:	75 f6                	jne    f0101940 <mem_init+0x5da>
	assert(nfree == 0);
f010194a:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f010194e:	0f 85 1b 08 00 00    	jne    f010216f <mem_init+0xe09>
	cprintf("check_page_alloc() succeeded!\n");
f0101954:	83 ec 0c             	sub    $0xc,%esp
f0101957:	8d 83 54 a6 fe ff    	lea    -0x159ac(%ebx),%eax
f010195d:	50                   	push   %eax
f010195e:	e8 fb 15 00 00       	call   f0102f5e <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101963:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010196a:	e8 9a f6 ff ff       	call   f0101009 <page_alloc>
f010196f:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101972:	83 c4 10             	add    $0x10,%esp
f0101975:	85 c0                	test   %eax,%eax
f0101977:	0f 84 11 08 00 00    	je     f010218e <mem_init+0xe28>
	assert((pp1 = page_alloc(0)));
f010197d:	83 ec 0c             	sub    $0xc,%esp
f0101980:	6a 00                	push   $0x0
f0101982:	e8 82 f6 ff ff       	call   f0101009 <page_alloc>
f0101987:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010198a:	83 c4 10             	add    $0x10,%esp
f010198d:	85 c0                	test   %eax,%eax
f010198f:	0f 84 18 08 00 00    	je     f01021ad <mem_init+0xe47>
	assert((pp2 = page_alloc(0)));
f0101995:	83 ec 0c             	sub    $0xc,%esp
f0101998:	6a 00                	push   $0x0
f010199a:	e8 6a f6 ff ff       	call   f0101009 <page_alloc>
f010199f:	89 c7                	mov    %eax,%edi
f01019a1:	83 c4 10             	add    $0x10,%esp
f01019a4:	85 c0                	test   %eax,%eax
f01019a6:	0f 84 20 08 00 00    	je     f01021cc <mem_init+0xe66>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01019ac:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01019af:	39 4d d0             	cmp    %ecx,-0x30(%ebp)
f01019b2:	0f 84 33 08 00 00    	je     f01021eb <mem_init+0xe85>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01019b8:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f01019bb:	0f 84 49 08 00 00    	je     f010220a <mem_init+0xea4>
f01019c1:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f01019c4:	0f 84 40 08 00 00    	je     f010220a <mem_init+0xea4>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01019ca:	8b 83 54 02 00 00    	mov    0x254(%ebx),%eax
f01019d0:	89 45 c8             	mov    %eax,-0x38(%ebp)
	page_free_list = 0;
f01019d3:	c7 83 54 02 00 00 00 	movl   $0x0,0x254(%ebx)
f01019da:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01019dd:	83 ec 0c             	sub    $0xc,%esp
f01019e0:	6a 00                	push   $0x0
f01019e2:	e8 22 f6 ff ff       	call   f0101009 <page_alloc>
f01019e7:	83 c4 10             	add    $0x10,%esp
f01019ea:	85 c0                	test   %eax,%eax
f01019ec:	0f 85 37 08 00 00    	jne    f0102229 <mem_init+0xec3>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f01019f2:	83 ec 04             	sub    $0x4,%esp
f01019f5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01019f8:	50                   	push   %eax
f01019f9:	6a 00                	push   $0x0
f01019fb:	c7 c0 ec a6 11 f0    	mov    $0xf011a6ec,%eax
f0101a01:	ff 30                	pushl  (%eax)
f0101a03:	e8 39 f8 ff ff       	call   f0101241 <page_lookup>
f0101a08:	83 c4 10             	add    $0x10,%esp
f0101a0b:	85 c0                	test   %eax,%eax
f0101a0d:	0f 85 35 08 00 00    	jne    f0102248 <mem_init+0xee2>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101a13:	6a 02                	push   $0x2
f0101a15:	6a 00                	push   $0x0
f0101a17:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101a1a:	c7 c0 ec a6 11 f0    	mov    $0xf011a6ec,%eax
f0101a20:	ff 30                	pushl  (%eax)
f0101a22:	e8 c9 f8 ff ff       	call   f01012f0 <page_insert>
f0101a27:	83 c4 10             	add    $0x10,%esp
f0101a2a:	85 c0                	test   %eax,%eax
f0101a2c:	0f 89 35 08 00 00    	jns    f0102267 <mem_init+0xf01>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101a32:	83 ec 0c             	sub    $0xc,%esp
f0101a35:	ff 75 d0             	pushl  -0x30(%ebp)
f0101a38:	e8 54 f6 ff ff       	call   f0101091 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101a3d:	6a 02                	push   $0x2
f0101a3f:	6a 00                	push   $0x0
f0101a41:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101a44:	c7 c0 ec a6 11 f0    	mov    $0xf011a6ec,%eax
f0101a4a:	ff 30                	pushl  (%eax)
f0101a4c:	e8 9f f8 ff ff       	call   f01012f0 <page_insert>
f0101a51:	83 c4 20             	add    $0x20,%esp
f0101a54:	85 c0                	test   %eax,%eax
f0101a56:	0f 85 2a 08 00 00    	jne    f0102286 <mem_init+0xf20>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101a5c:	c7 c0 ec a6 11 f0    	mov    $0xf011a6ec,%eax
f0101a62:	8b 30                	mov    (%eax),%esi
	return (pp - pages) << PGSHIFT;
f0101a64:	c7 c0 f0 a6 11 f0    	mov    $0xf011a6f0,%eax
f0101a6a:	8b 08                	mov    (%eax),%ecx
f0101a6c:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0101a6f:	8b 16                	mov    (%esi),%edx
f0101a71:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101a77:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101a7a:	29 c8                	sub    %ecx,%eax
f0101a7c:	c1 f8 03             	sar    $0x3,%eax
f0101a7f:	c1 e0 0c             	shl    $0xc,%eax
f0101a82:	39 c2                	cmp    %eax,%edx
f0101a84:	0f 85 1b 08 00 00    	jne    f01022a5 <mem_init+0xf3f>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101a8a:	ba 00 00 00 00       	mov    $0x0,%edx
f0101a8f:	89 f0                	mov    %esi,%eax
f0101a91:	e8 5b f0 ff ff       	call   f0100af1 <check_va2pa>
f0101a96:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101a99:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0101a9c:	c1 fa 03             	sar    $0x3,%edx
f0101a9f:	c1 e2 0c             	shl    $0xc,%edx
f0101aa2:	39 d0                	cmp    %edx,%eax
f0101aa4:	0f 85 1a 08 00 00    	jne    f01022c4 <mem_init+0xf5e>
	assert(pp1->pp_ref == 1);
f0101aaa:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101aad:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101ab2:	0f 85 2b 08 00 00    	jne    f01022e3 <mem_init+0xf7d>
	assert(pp0->pp_ref == 1);
f0101ab8:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101abb:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101ac0:	0f 85 3c 08 00 00    	jne    f0102302 <mem_init+0xf9c>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101ac6:	6a 02                	push   $0x2
f0101ac8:	68 00 10 00 00       	push   $0x1000
f0101acd:	57                   	push   %edi
f0101ace:	56                   	push   %esi
f0101acf:	e8 1c f8 ff ff       	call   f01012f0 <page_insert>
f0101ad4:	83 c4 10             	add    $0x10,%esp
f0101ad7:	85 c0                	test   %eax,%eax
f0101ad9:	0f 85 42 08 00 00    	jne    f0102321 <mem_init+0xfbb>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101adf:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ae4:	c7 c0 ec a6 11 f0    	mov    $0xf011a6ec,%eax
f0101aea:	8b 00                	mov    (%eax),%eax
f0101aec:	e8 00 f0 ff ff       	call   f0100af1 <check_va2pa>
f0101af1:	c7 c2 f0 a6 11 f0    	mov    $0xf011a6f0,%edx
f0101af7:	89 f9                	mov    %edi,%ecx
f0101af9:	2b 0a                	sub    (%edx),%ecx
f0101afb:	89 ca                	mov    %ecx,%edx
f0101afd:	c1 fa 03             	sar    $0x3,%edx
f0101b00:	c1 e2 0c             	shl    $0xc,%edx
f0101b03:	39 d0                	cmp    %edx,%eax
f0101b05:	0f 85 35 08 00 00    	jne    f0102340 <mem_init+0xfda>
	assert(pp2->pp_ref == 1);
f0101b0b:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101b10:	0f 85 49 08 00 00    	jne    f010235f <mem_init+0xff9>

	// should be no free memory
	assert(!page_alloc(0));
f0101b16:	83 ec 0c             	sub    $0xc,%esp
f0101b19:	6a 00                	push   $0x0
f0101b1b:	e8 e9 f4 ff ff       	call   f0101009 <page_alloc>
f0101b20:	83 c4 10             	add    $0x10,%esp
f0101b23:	85 c0                	test   %eax,%eax
f0101b25:	0f 85 53 08 00 00    	jne    f010237e <mem_init+0x1018>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101b2b:	6a 02                	push   $0x2
f0101b2d:	68 00 10 00 00       	push   $0x1000
f0101b32:	57                   	push   %edi
f0101b33:	c7 c0 ec a6 11 f0    	mov    $0xf011a6ec,%eax
f0101b39:	ff 30                	pushl  (%eax)
f0101b3b:	e8 b0 f7 ff ff       	call   f01012f0 <page_insert>
f0101b40:	83 c4 10             	add    $0x10,%esp
f0101b43:	85 c0                	test   %eax,%eax
f0101b45:	0f 85 52 08 00 00    	jne    f010239d <mem_init+0x1037>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101b4b:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101b50:	c7 c0 ec a6 11 f0    	mov    $0xf011a6ec,%eax
f0101b56:	8b 00                	mov    (%eax),%eax
f0101b58:	e8 94 ef ff ff       	call   f0100af1 <check_va2pa>
f0101b5d:	c7 c2 f0 a6 11 f0    	mov    $0xf011a6f0,%edx
f0101b63:	89 f9                	mov    %edi,%ecx
f0101b65:	2b 0a                	sub    (%edx),%ecx
f0101b67:	89 ca                	mov    %ecx,%edx
f0101b69:	c1 fa 03             	sar    $0x3,%edx
f0101b6c:	c1 e2 0c             	shl    $0xc,%edx
f0101b6f:	39 d0                	cmp    %edx,%eax
f0101b71:	0f 85 45 08 00 00    	jne    f01023bc <mem_init+0x1056>
	assert(pp2->pp_ref == 1);
f0101b77:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101b7c:	0f 85 59 08 00 00    	jne    f01023db <mem_init+0x1075>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101b82:	83 ec 0c             	sub    $0xc,%esp
f0101b85:	6a 00                	push   $0x0
f0101b87:	e8 7d f4 ff ff       	call   f0101009 <page_alloc>
f0101b8c:	83 c4 10             	add    $0x10,%esp
f0101b8f:	85 c0                	test   %eax,%eax
f0101b91:	0f 85 63 08 00 00    	jne    f01023fa <mem_init+0x1094>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101b97:	c7 c0 ec a6 11 f0    	mov    $0xf011a6ec,%eax
f0101b9d:	8b 10                	mov    (%eax),%edx
f0101b9f:	8b 02                	mov    (%edx),%eax
f0101ba1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0101ba6:	89 c6                	mov    %eax,%esi
f0101ba8:	c1 ee 0c             	shr    $0xc,%esi
f0101bab:	c7 c1 e8 a6 11 f0    	mov    $0xf011a6e8,%ecx
f0101bb1:	3b 31                	cmp    (%ecx),%esi
f0101bb3:	0f 83 60 08 00 00    	jae    f0102419 <mem_init+0x10b3>
	return (void *)(pa + KERNBASE);
f0101bb9:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101bbe:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101bc1:	83 ec 04             	sub    $0x4,%esp
f0101bc4:	6a 00                	push   $0x0
f0101bc6:	68 00 10 00 00       	push   $0x1000
f0101bcb:	52                   	push   %edx
f0101bcc:	e8 38 f5 ff ff       	call   f0101109 <pgdir_walk>
f0101bd1:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101bd4:	8d 51 04             	lea    0x4(%ecx),%edx
f0101bd7:	83 c4 10             	add    $0x10,%esp
f0101bda:	39 d0                	cmp    %edx,%eax
f0101bdc:	0f 85 50 08 00 00    	jne    f0102432 <mem_init+0x10cc>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101be2:	6a 06                	push   $0x6
f0101be4:	68 00 10 00 00       	push   $0x1000
f0101be9:	57                   	push   %edi
f0101bea:	c7 c0 ec a6 11 f0    	mov    $0xf011a6ec,%eax
f0101bf0:	ff 30                	pushl  (%eax)
f0101bf2:	e8 f9 f6 ff ff       	call   f01012f0 <page_insert>
f0101bf7:	83 c4 10             	add    $0x10,%esp
f0101bfa:	85 c0                	test   %eax,%eax
f0101bfc:	0f 85 4f 08 00 00    	jne    f0102451 <mem_init+0x10eb>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101c02:	c7 c0 ec a6 11 f0    	mov    $0xf011a6ec,%eax
f0101c08:	8b 30                	mov    (%eax),%esi
f0101c0a:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c0f:	89 f0                	mov    %esi,%eax
f0101c11:	e8 db ee ff ff       	call   f0100af1 <check_va2pa>
	return (pp - pages) << PGSHIFT;
f0101c16:	c7 c2 f0 a6 11 f0    	mov    $0xf011a6f0,%edx
f0101c1c:	89 f9                	mov    %edi,%ecx
f0101c1e:	2b 0a                	sub    (%edx),%ecx
f0101c20:	89 ca                	mov    %ecx,%edx
f0101c22:	c1 fa 03             	sar    $0x3,%edx
f0101c25:	c1 e2 0c             	shl    $0xc,%edx
f0101c28:	39 d0                	cmp    %edx,%eax
f0101c2a:	0f 85 40 08 00 00    	jne    f0102470 <mem_init+0x110a>
	assert(pp2->pp_ref == 1);
f0101c30:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101c35:	0f 85 54 08 00 00    	jne    f010248f <mem_init+0x1129>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101c3b:	83 ec 04             	sub    $0x4,%esp
f0101c3e:	6a 00                	push   $0x0
f0101c40:	68 00 10 00 00       	push   $0x1000
f0101c45:	56                   	push   %esi
f0101c46:	e8 be f4 ff ff       	call   f0101109 <pgdir_walk>
f0101c4b:	83 c4 10             	add    $0x10,%esp
f0101c4e:	f6 00 04             	testb  $0x4,(%eax)
f0101c51:	0f 84 57 08 00 00    	je     f01024ae <mem_init+0x1148>
	assert(kern_pgdir[0] & PTE_U);
f0101c57:	c7 c0 ec a6 11 f0    	mov    $0xf011a6ec,%eax
f0101c5d:	8b 00                	mov    (%eax),%eax
f0101c5f:	f6 00 04             	testb  $0x4,(%eax)
f0101c62:	0f 84 65 08 00 00    	je     f01024cd <mem_init+0x1167>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101c68:	6a 02                	push   $0x2
f0101c6a:	68 00 10 00 00       	push   $0x1000
f0101c6f:	57                   	push   %edi
f0101c70:	50                   	push   %eax
f0101c71:	e8 7a f6 ff ff       	call   f01012f0 <page_insert>
f0101c76:	83 c4 10             	add    $0x10,%esp
f0101c79:	85 c0                	test   %eax,%eax
f0101c7b:	0f 85 6b 08 00 00    	jne    f01024ec <mem_init+0x1186>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101c81:	83 ec 04             	sub    $0x4,%esp
f0101c84:	6a 00                	push   $0x0
f0101c86:	68 00 10 00 00       	push   $0x1000
f0101c8b:	c7 c0 ec a6 11 f0    	mov    $0xf011a6ec,%eax
f0101c91:	ff 30                	pushl  (%eax)
f0101c93:	e8 71 f4 ff ff       	call   f0101109 <pgdir_walk>
f0101c98:	83 c4 10             	add    $0x10,%esp
f0101c9b:	f6 00 02             	testb  $0x2,(%eax)
f0101c9e:	0f 84 67 08 00 00    	je     f010250b <mem_init+0x11a5>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101ca4:	83 ec 04             	sub    $0x4,%esp
f0101ca7:	6a 00                	push   $0x0
f0101ca9:	68 00 10 00 00       	push   $0x1000
f0101cae:	c7 c0 ec a6 11 f0    	mov    $0xf011a6ec,%eax
f0101cb4:	ff 30                	pushl  (%eax)
f0101cb6:	e8 4e f4 ff ff       	call   f0101109 <pgdir_walk>
f0101cbb:	83 c4 10             	add    $0x10,%esp
f0101cbe:	f6 00 04             	testb  $0x4,(%eax)
f0101cc1:	0f 85 63 08 00 00    	jne    f010252a <mem_init+0x11c4>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101cc7:	6a 02                	push   $0x2
f0101cc9:	68 00 00 40 00       	push   $0x400000
f0101cce:	ff 75 d0             	pushl  -0x30(%ebp)
f0101cd1:	c7 c0 ec a6 11 f0    	mov    $0xf011a6ec,%eax
f0101cd7:	ff 30                	pushl  (%eax)
f0101cd9:	e8 12 f6 ff ff       	call   f01012f0 <page_insert>
f0101cde:	83 c4 10             	add    $0x10,%esp
f0101ce1:	85 c0                	test   %eax,%eax
f0101ce3:	0f 89 60 08 00 00    	jns    f0102549 <mem_init+0x11e3>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101ce9:	6a 02                	push   $0x2
f0101ceb:	68 00 10 00 00       	push   $0x1000
f0101cf0:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101cf3:	c7 c0 ec a6 11 f0    	mov    $0xf011a6ec,%eax
f0101cf9:	ff 30                	pushl  (%eax)
f0101cfb:	e8 f0 f5 ff ff       	call   f01012f0 <page_insert>
f0101d00:	83 c4 10             	add    $0x10,%esp
f0101d03:	85 c0                	test   %eax,%eax
f0101d05:	0f 85 5d 08 00 00    	jne    f0102568 <mem_init+0x1202>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101d0b:	83 ec 04             	sub    $0x4,%esp
f0101d0e:	6a 00                	push   $0x0
f0101d10:	68 00 10 00 00       	push   $0x1000
f0101d15:	c7 c0 ec a6 11 f0    	mov    $0xf011a6ec,%eax
f0101d1b:	ff 30                	pushl  (%eax)
f0101d1d:	e8 e7 f3 ff ff       	call   f0101109 <pgdir_walk>
f0101d22:	83 c4 10             	add    $0x10,%esp
f0101d25:	f6 00 04             	testb  $0x4,(%eax)
f0101d28:	0f 85 59 08 00 00    	jne    f0102587 <mem_init+0x1221>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101d2e:	c7 c0 ec a6 11 f0    	mov    $0xf011a6ec,%eax
f0101d34:	8b 00                	mov    (%eax),%eax
f0101d36:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101d39:	ba 00 00 00 00       	mov    $0x0,%edx
f0101d3e:	e8 ae ed ff ff       	call   f0100af1 <check_va2pa>
f0101d43:	c7 c2 f0 a6 11 f0    	mov    $0xf011a6f0,%edx
f0101d49:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0101d4c:	2b 32                	sub    (%edx),%esi
f0101d4e:	c1 fe 03             	sar    $0x3,%esi
f0101d51:	c1 e6 0c             	shl    $0xc,%esi
f0101d54:	39 f0                	cmp    %esi,%eax
f0101d56:	0f 85 4a 08 00 00    	jne    f01025a6 <mem_init+0x1240>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101d5c:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d61:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101d64:	e8 88 ed ff ff       	call   f0100af1 <check_va2pa>
f0101d69:	39 c6                	cmp    %eax,%esi
f0101d6b:	0f 85 54 08 00 00    	jne    f01025c5 <mem_init+0x125f>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101d71:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d74:	66 83 78 04 02       	cmpw   $0x2,0x4(%eax)
f0101d79:	0f 85 65 08 00 00    	jne    f01025e4 <mem_init+0x127e>
	assert(pp2->pp_ref == 0);
f0101d7f:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101d84:	0f 85 79 08 00 00    	jne    f0102603 <mem_init+0x129d>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101d8a:	83 ec 0c             	sub    $0xc,%esp
f0101d8d:	6a 00                	push   $0x0
f0101d8f:	e8 75 f2 ff ff       	call   f0101009 <page_alloc>
f0101d94:	83 c4 10             	add    $0x10,%esp
f0101d97:	39 c7                	cmp    %eax,%edi
f0101d99:	0f 85 83 08 00 00    	jne    f0102622 <mem_init+0x12bc>
f0101d9f:	85 c0                	test   %eax,%eax
f0101da1:	0f 84 7b 08 00 00    	je     f0102622 <mem_init+0x12bc>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101da7:	83 ec 08             	sub    $0x8,%esp
f0101daa:	6a 00                	push   $0x0
f0101dac:	c7 c6 ec a6 11 f0    	mov    $0xf011a6ec,%esi
f0101db2:	ff 36                	pushl  (%esi)
f0101db4:	e8 fc f4 ff ff       	call   f01012b5 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101db9:	8b 36                	mov    (%esi),%esi
f0101dbb:	ba 00 00 00 00       	mov    $0x0,%edx
f0101dc0:	89 f0                	mov    %esi,%eax
f0101dc2:	e8 2a ed ff ff       	call   f0100af1 <check_va2pa>
f0101dc7:	83 c4 10             	add    $0x10,%esp
f0101dca:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101dcd:	0f 85 6e 08 00 00    	jne    f0102641 <mem_init+0x12db>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101dd3:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101dd8:	89 f0                	mov    %esi,%eax
f0101dda:	e8 12 ed ff ff       	call   f0100af1 <check_va2pa>
f0101ddf:	c7 c2 f0 a6 11 f0    	mov    $0xf011a6f0,%edx
f0101de5:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101de8:	2b 0a                	sub    (%edx),%ecx
f0101dea:	89 ca                	mov    %ecx,%edx
f0101dec:	c1 fa 03             	sar    $0x3,%edx
f0101def:	c1 e2 0c             	shl    $0xc,%edx
f0101df2:	39 d0                	cmp    %edx,%eax
f0101df4:	0f 85 66 08 00 00    	jne    f0102660 <mem_init+0x12fa>
	assert(pp1->pp_ref == 1);
f0101dfa:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101dfd:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101e02:	0f 85 77 08 00 00    	jne    f010267f <mem_init+0x1319>
	assert(pp2->pp_ref == 0);
f0101e08:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101e0d:	0f 85 8b 08 00 00    	jne    f010269e <mem_init+0x1338>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101e13:	6a 00                	push   $0x0
f0101e15:	68 00 10 00 00       	push   $0x1000
f0101e1a:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101e1d:	56                   	push   %esi
f0101e1e:	e8 cd f4 ff ff       	call   f01012f0 <page_insert>
f0101e23:	83 c4 10             	add    $0x10,%esp
f0101e26:	85 c0                	test   %eax,%eax
f0101e28:	0f 85 8f 08 00 00    	jne    f01026bd <mem_init+0x1357>
	assert(pp1->pp_ref);
f0101e2e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e31:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101e36:	0f 84 a0 08 00 00    	je     f01026dc <mem_init+0x1376>
	assert(pp1->pp_link == NULL);
f0101e3c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e3f:	83 38 00             	cmpl   $0x0,(%eax)
f0101e42:	0f 85 b3 08 00 00    	jne    f01026fb <mem_init+0x1395>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101e48:	83 ec 08             	sub    $0x8,%esp
f0101e4b:	68 00 10 00 00       	push   $0x1000
f0101e50:	c7 c6 ec a6 11 f0    	mov    $0xf011a6ec,%esi
f0101e56:	ff 36                	pushl  (%esi)
f0101e58:	e8 58 f4 ff ff       	call   f01012b5 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101e5d:	8b 36                	mov    (%esi),%esi
f0101e5f:	ba 00 00 00 00       	mov    $0x0,%edx
f0101e64:	89 f0                	mov    %esi,%eax
f0101e66:	e8 86 ec ff ff       	call   f0100af1 <check_va2pa>
f0101e6b:	83 c4 10             	add    $0x10,%esp
f0101e6e:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101e71:	0f 85 a3 08 00 00    	jne    f010271a <mem_init+0x13b4>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101e77:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e7c:	89 f0                	mov    %esi,%eax
f0101e7e:	e8 6e ec ff ff       	call   f0100af1 <check_va2pa>
f0101e83:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101e86:	0f 85 ad 08 00 00    	jne    f0102739 <mem_init+0x13d3>
	assert(pp1->pp_ref == 0);
f0101e8c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e8f:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101e94:	0f 85 be 08 00 00    	jne    f0102758 <mem_init+0x13f2>
	assert(pp2->pp_ref == 0);
f0101e9a:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101e9f:	0f 85 d2 08 00 00    	jne    f0102777 <mem_init+0x1411>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101ea5:	83 ec 0c             	sub    $0xc,%esp
f0101ea8:	6a 00                	push   $0x0
f0101eaa:	e8 5a f1 ff ff       	call   f0101009 <page_alloc>
f0101eaf:	83 c4 10             	add    $0x10,%esp
f0101eb2:	85 c0                	test   %eax,%eax
f0101eb4:	0f 84 dc 08 00 00    	je     f0102796 <mem_init+0x1430>
f0101eba:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101ebd:	0f 85 d3 08 00 00    	jne    f0102796 <mem_init+0x1430>

	// should be no free memory
	assert(!page_alloc(0));
f0101ec3:	83 ec 0c             	sub    $0xc,%esp
f0101ec6:	6a 00                	push   $0x0
f0101ec8:	e8 3c f1 ff ff       	call   f0101009 <page_alloc>
f0101ecd:	83 c4 10             	add    $0x10,%esp
f0101ed0:	85 c0                	test   %eax,%eax
f0101ed2:	0f 85 dd 08 00 00    	jne    f01027b5 <mem_init+0x144f>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101ed8:	c7 c0 ec a6 11 f0    	mov    $0xf011a6ec,%eax
f0101ede:	8b 08                	mov    (%eax),%ecx
f0101ee0:	8b 11                	mov    (%ecx),%edx
f0101ee2:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101ee8:	c7 c0 f0 a6 11 f0    	mov    $0xf011a6f0,%eax
f0101eee:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0101ef1:	2b 30                	sub    (%eax),%esi
f0101ef3:	89 f0                	mov    %esi,%eax
f0101ef5:	c1 f8 03             	sar    $0x3,%eax
f0101ef8:	c1 e0 0c             	shl    $0xc,%eax
f0101efb:	39 c2                	cmp    %eax,%edx
f0101efd:	0f 85 d1 08 00 00    	jne    f01027d4 <mem_init+0x146e>
	kern_pgdir[0] = 0;
f0101f03:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0101f09:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101f0c:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101f11:	0f 85 dc 08 00 00    	jne    f01027f3 <mem_init+0x148d>
	pp0->pp_ref = 0;
f0101f17:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101f1a:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0101f20:	83 ec 0c             	sub    $0xc,%esp
f0101f23:	50                   	push   %eax
f0101f24:	e8 68 f1 ff ff       	call   f0101091 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0101f29:	83 c4 0c             	add    $0xc,%esp
f0101f2c:	6a 01                	push   $0x1
f0101f2e:	68 00 10 40 00       	push   $0x401000
f0101f33:	c7 c6 ec a6 11 f0    	mov    $0xf011a6ec,%esi
f0101f39:	ff 36                	pushl  (%esi)
f0101f3b:	e8 c9 f1 ff ff       	call   f0101109 <pgdir_walk>
f0101f40:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101f43:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0101f46:	8b 36                	mov    (%esi),%esi
f0101f48:	8b 56 04             	mov    0x4(%esi),%edx
f0101f4b:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f0101f51:	c7 c1 e8 a6 11 f0    	mov    $0xf011a6e8,%ecx
f0101f57:	8b 09                	mov    (%ecx),%ecx
f0101f59:	89 d0                	mov    %edx,%eax
f0101f5b:	c1 e8 0c             	shr    $0xc,%eax
f0101f5e:	83 c4 10             	add    $0x10,%esp
f0101f61:	39 c8                	cmp    %ecx,%eax
f0101f63:	0f 83 a9 08 00 00    	jae    f0102812 <mem_init+0x14ac>
	assert(ptep == ptep1 + PTX(va));
f0101f69:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f0101f6f:	39 55 cc             	cmp    %edx,-0x34(%ebp)
f0101f72:	0f 85 b3 08 00 00    	jne    f010282b <mem_init+0x14c5>
	kern_pgdir[PDX(va)] = 0;
f0101f78:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	pp0->pp_ref = 0;
f0101f7f:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0101f82:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)
	return (pp - pages) << PGSHIFT;
f0101f88:	c7 c0 f0 a6 11 f0    	mov    $0xf011a6f0,%eax
f0101f8e:	2b 30                	sub    (%eax),%esi
f0101f90:	89 f0                	mov    %esi,%eax
f0101f92:	c1 f8 03             	sar    $0x3,%eax
f0101f95:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0101f98:	89 c2                	mov    %eax,%edx
f0101f9a:	c1 ea 0c             	shr    $0xc,%edx
f0101f9d:	39 d1                	cmp    %edx,%ecx
f0101f9f:	0f 86 a5 08 00 00    	jbe    f010284a <mem_init+0x14e4>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0101fa5:	83 ec 04             	sub    $0x4,%esp
f0101fa8:	68 00 10 00 00       	push   $0x1000
f0101fad:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f0101fb2:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101fb7:	50                   	push   %eax
f0101fb8:	e8 c2 1b 00 00       	call   f0103b7f <memset>
	page_free(pp0);
f0101fbd:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0101fc0:	89 34 24             	mov    %esi,(%esp)
f0101fc3:	e8 c9 f0 ff ff       	call   f0101091 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0101fc8:	83 c4 0c             	add    $0xc,%esp
f0101fcb:	6a 01                	push   $0x1
f0101fcd:	6a 00                	push   $0x0
f0101fcf:	c7 c0 ec a6 11 f0    	mov    $0xf011a6ec,%eax
f0101fd5:	ff 30                	pushl  (%eax)
f0101fd7:	e8 2d f1 ff ff       	call   f0101109 <pgdir_walk>
	return (pp - pages) << PGSHIFT;
f0101fdc:	c7 c0 f0 a6 11 f0    	mov    $0xf011a6f0,%eax
f0101fe2:	2b 30                	sub    (%eax),%esi
f0101fe4:	89 f0                	mov    %esi,%eax
f0101fe6:	c1 f8 03             	sar    $0x3,%eax
f0101fe9:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0101fec:	89 c1                	mov    %eax,%ecx
f0101fee:	c1 e9 0c             	shr    $0xc,%ecx
f0101ff1:	83 c4 10             	add    $0x10,%esp
f0101ff4:	c7 c2 e8 a6 11 f0    	mov    $0xf011a6e8,%edx
f0101ffa:	3b 0a                	cmp    (%edx),%ecx
f0101ffc:	0f 83 5e 08 00 00    	jae    f0102860 <mem_init+0x14fa>
	return (void *)(pa + KERNBASE);
f0102002:	8d 90 00 00 00 f0    	lea    -0x10000000(%eax),%edx
	ptep = (pte_t *) page2kva(pp0);
f0102008:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f010200b:	2d 00 f0 ff 0f       	sub    $0xffff000,%eax
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102010:	f6 02 01             	testb  $0x1,(%edx)
f0102013:	0f 85 5d 08 00 00    	jne    f0102876 <mem_init+0x1510>
f0102019:	83 c2 04             	add    $0x4,%edx
	for(i=0; i<NPTENTRIES; i++)
f010201c:	39 c2                	cmp    %eax,%edx
f010201e:	75 f0                	jne    f0102010 <mem_init+0xcaa>
	kern_pgdir[0] = 0;
f0102020:	c7 c0 ec a6 11 f0    	mov    $0xf011a6ec,%eax
f0102026:	8b 00                	mov    (%eax),%eax
f0102028:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f010202e:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102031:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0102037:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f010203a:	89 8b 54 02 00 00    	mov    %ecx,0x254(%ebx)

	// free the pages we took
	page_free(pp0);
f0102040:	83 ec 0c             	sub    $0xc,%esp
f0102043:	50                   	push   %eax
f0102044:	e8 48 f0 ff ff       	call   f0101091 <page_free>
	page_free(pp1);
f0102049:	83 c4 04             	add    $0x4,%esp
f010204c:	ff 75 d4             	pushl  -0x2c(%ebp)
f010204f:	e8 3d f0 ff ff       	call   f0101091 <page_free>
	page_free(pp2);
f0102054:	89 3c 24             	mov    %edi,(%esp)
f0102057:	e8 35 f0 ff ff       	call   f0101091 <page_free>

	cprintf("check_page() succeeded!\n");
f010205c:	8d 83 ba ae fe ff    	lea    -0x15146(%ebx),%eax
f0102062:	89 04 24             	mov    %eax,(%esp)
f0102065:	e8 f4 0e 00 00       	call   f0102f5e <cprintf>
	boot_map_region(kern_pgdir, (uintptr_t) UPAGES, npages*sizeof(struct PageInfo), PADDR(pages), PTE_U | PTE_P);
f010206a:	c7 c0 f0 a6 11 f0    	mov    $0xf011a6f0,%eax
f0102070:	8b 00                	mov    (%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0102072:	83 c4 10             	add    $0x10,%esp
f0102075:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010207a:	0f 86 15 08 00 00    	jbe    f0102895 <mem_init+0x152f>
f0102080:	c7 c2 e8 a6 11 f0    	mov    $0xf011a6e8,%edx
f0102086:	8b 0a                	mov    (%edx),%ecx
f0102088:	c1 e1 03             	shl    $0x3,%ecx
f010208b:	83 ec 08             	sub    $0x8,%esp
f010208e:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f0102090:	05 00 00 00 10       	add    $0x10000000,%eax
f0102095:	50                   	push   %eax
f0102096:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f010209b:	c7 c0 ec a6 11 f0    	mov    $0xf011a6ec,%eax
f01020a1:	8b 00                	mov    (%eax),%eax
f01020a3:	e8 45 f1 ff ff       	call   f01011ed <boot_map_region>
	if ((uint32_t)kva < KERNBASE)
f01020a8:	c7 c0 00 f0 10 f0    	mov    $0xf010f000,%eax
f01020ae:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01020b1:	83 c4 10             	add    $0x10,%esp
f01020b4:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01020b9:	0f 86 ef 07 00 00    	jbe    f01028ae <mem_init+0x1548>
	boot_map_region(kern_pgdir, (uintptr_t) (KSTACKTOP-KSTKSIZE), KSTKSIZE, PADDR(bootstack), PTE_W | PTE_P);
f01020bf:	c7 c6 ec a6 11 f0    	mov    $0xf011a6ec,%esi
f01020c5:	83 ec 08             	sub    $0x8,%esp
f01020c8:	6a 03                	push   $0x3
	return (physaddr_t)kva - KERNBASE;
f01020ca:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01020cd:	05 00 00 00 10       	add    $0x10000000,%eax
f01020d2:	50                   	push   %eax
f01020d3:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01020d8:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f01020dd:	8b 06                	mov    (%esi),%eax
f01020df:	e8 09 f1 ff ff       	call   f01011ed <boot_map_region>
	boot_map_region(kern_pgdir, (uintptr_t) KERNBASE, ROUNDUP(0xffffffff - KERNBASE, PGSIZE), 0, PTE_W | PTE_P);
f01020e4:	83 c4 08             	add    $0x8,%esp
f01020e7:	6a 03                	push   $0x3
f01020e9:	6a 00                	push   $0x0
f01020eb:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f01020f0:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f01020f5:	8b 06                	mov    (%esi),%eax
f01020f7:	e8 f1 f0 ff ff       	call   f01011ed <boot_map_region>
	pgdir = kern_pgdir;
f01020fc:	8b 3e                	mov    (%esi),%edi
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f01020fe:	c7 c0 e8 a6 11 f0    	mov    $0xf011a6e8,%eax
f0102104:	8b 00                	mov    (%eax),%eax
f0102106:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0102109:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0102110:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102115:	89 45 d0             	mov    %eax,-0x30(%ebp)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102118:	c7 c0 f0 a6 11 f0    	mov    $0xf011a6f0,%eax
f010211e:	8b 00                	mov    (%eax),%eax
f0102120:	89 45 c0             	mov    %eax,-0x40(%ebp)
	if ((uint32_t)kva < KERNBASE)
f0102123:	89 45 cc             	mov    %eax,-0x34(%ebp)
	return (physaddr_t)kva - KERNBASE;
f0102126:	05 00 00 00 10       	add    $0x10000000,%eax
f010212b:	89 45 c8             	mov    %eax,-0x38(%ebp)
f010212e:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < n; i += PGSIZE)
f0102131:	be 00 00 00 00       	mov    $0x0,%esi
f0102136:	39 75 d0             	cmp    %esi,-0x30(%ebp)
f0102139:	0f 86 c2 07 00 00    	jbe    f0102901 <mem_init+0x159b>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010213f:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
f0102145:	89 f8                	mov    %edi,%eax
f0102147:	e8 a5 e9 ff ff       	call   f0100af1 <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f010214c:	81 7d cc ff ff ff ef 	cmpl   $0xefffffff,-0x34(%ebp)
f0102153:	0f 86 6e 07 00 00    	jbe    f01028c7 <mem_init+0x1561>
f0102159:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f010215c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f010215f:	39 d0                	cmp    %edx,%eax
f0102161:	0f 85 7b 07 00 00    	jne    f01028e2 <mem_init+0x157c>
	for (i = 0; i < n; i += PGSIZE)
f0102167:	81 c6 00 10 00 00    	add    $0x1000,%esi
f010216d:	eb c7                	jmp    f0102136 <mem_init+0xdd0>
	assert(nfree == 0);
f010216f:	8d 83 e3 ad fe ff    	lea    -0x1521d(%ebx),%eax
f0102175:	50                   	push   %eax
f0102176:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f010217c:	50                   	push   %eax
f010217d:	68 95 02 00 00       	push   $0x295
f0102182:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f0102188:	50                   	push   %eax
f0102189:	e8 7d df ff ff       	call   f010010b <_panic>
	assert((pp0 = page_alloc(0)));
f010218e:	8d 83 f1 ac fe ff    	lea    -0x1530f(%ebx),%eax
f0102194:	50                   	push   %eax
f0102195:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f010219b:	50                   	push   %eax
f010219c:	68 ee 02 00 00       	push   $0x2ee
f01021a1:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f01021a7:	50                   	push   %eax
f01021a8:	e8 5e df ff ff       	call   f010010b <_panic>
	assert((pp1 = page_alloc(0)));
f01021ad:	8d 83 07 ad fe ff    	lea    -0x152f9(%ebx),%eax
f01021b3:	50                   	push   %eax
f01021b4:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f01021ba:	50                   	push   %eax
f01021bb:	68 ef 02 00 00       	push   $0x2ef
f01021c0:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f01021c6:	50                   	push   %eax
f01021c7:	e8 3f df ff ff       	call   f010010b <_panic>
	assert((pp2 = page_alloc(0)));
f01021cc:	8d 83 1d ad fe ff    	lea    -0x152e3(%ebx),%eax
f01021d2:	50                   	push   %eax
f01021d3:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f01021d9:	50                   	push   %eax
f01021da:	68 f0 02 00 00       	push   $0x2f0
f01021df:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f01021e5:	50                   	push   %eax
f01021e6:	e8 20 df ff ff       	call   f010010b <_panic>
	assert(pp1 && pp1 != pp0);
f01021eb:	8d 83 33 ad fe ff    	lea    -0x152cd(%ebx),%eax
f01021f1:	50                   	push   %eax
f01021f2:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f01021f8:	50                   	push   %eax
f01021f9:	68 f3 02 00 00       	push   $0x2f3
f01021fe:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f0102204:	50                   	push   %eax
f0102205:	e8 01 df ff ff       	call   f010010b <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010220a:	8d 83 34 a6 fe ff    	lea    -0x159cc(%ebx),%eax
f0102210:	50                   	push   %eax
f0102211:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f0102217:	50                   	push   %eax
f0102218:	68 f4 02 00 00       	push   $0x2f4
f010221d:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f0102223:	50                   	push   %eax
f0102224:	e8 e2 de ff ff       	call   f010010b <_panic>
	assert(!page_alloc(0));
f0102229:	8d 83 9c ad fe ff    	lea    -0x15264(%ebx),%eax
f010222f:	50                   	push   %eax
f0102230:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f0102236:	50                   	push   %eax
f0102237:	68 fb 02 00 00       	push   $0x2fb
f010223c:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f0102242:	50                   	push   %eax
f0102243:	e8 c3 de ff ff       	call   f010010b <_panic>
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0102248:	8d 83 74 a6 fe ff    	lea    -0x1598c(%ebx),%eax
f010224e:	50                   	push   %eax
f010224f:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f0102255:	50                   	push   %eax
f0102256:	68 fe 02 00 00       	push   $0x2fe
f010225b:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f0102261:	50                   	push   %eax
f0102262:	e8 a4 de ff ff       	call   f010010b <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0102267:	8d 83 ac a6 fe ff    	lea    -0x15954(%ebx),%eax
f010226d:	50                   	push   %eax
f010226e:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f0102274:	50                   	push   %eax
f0102275:	68 01 03 00 00       	push   $0x301
f010227a:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f0102280:	50                   	push   %eax
f0102281:	e8 85 de ff ff       	call   f010010b <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0102286:	8d 83 dc a6 fe ff    	lea    -0x15924(%ebx),%eax
f010228c:	50                   	push   %eax
f010228d:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f0102293:	50                   	push   %eax
f0102294:	68 05 03 00 00       	push   $0x305
f0102299:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f010229f:	50                   	push   %eax
f01022a0:	e8 66 de ff ff       	call   f010010b <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01022a5:	8d 83 0c a7 fe ff    	lea    -0x158f4(%ebx),%eax
f01022ab:	50                   	push   %eax
f01022ac:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f01022b2:	50                   	push   %eax
f01022b3:	68 06 03 00 00       	push   $0x306
f01022b8:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f01022be:	50                   	push   %eax
f01022bf:	e8 47 de ff ff       	call   f010010b <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f01022c4:	8d 83 34 a7 fe ff    	lea    -0x158cc(%ebx),%eax
f01022ca:	50                   	push   %eax
f01022cb:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f01022d1:	50                   	push   %eax
f01022d2:	68 07 03 00 00       	push   $0x307
f01022d7:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f01022dd:	50                   	push   %eax
f01022de:	e8 28 de ff ff       	call   f010010b <_panic>
	assert(pp1->pp_ref == 1);
f01022e3:	8d 83 ee ad fe ff    	lea    -0x15212(%ebx),%eax
f01022e9:	50                   	push   %eax
f01022ea:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f01022f0:	50                   	push   %eax
f01022f1:	68 08 03 00 00       	push   $0x308
f01022f6:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f01022fc:	50                   	push   %eax
f01022fd:	e8 09 de ff ff       	call   f010010b <_panic>
	assert(pp0->pp_ref == 1);
f0102302:	8d 83 ff ad fe ff    	lea    -0x15201(%ebx),%eax
f0102308:	50                   	push   %eax
f0102309:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f010230f:	50                   	push   %eax
f0102310:	68 09 03 00 00       	push   $0x309
f0102315:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f010231b:	50                   	push   %eax
f010231c:	e8 ea dd ff ff       	call   f010010b <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102321:	8d 83 64 a7 fe ff    	lea    -0x1589c(%ebx),%eax
f0102327:	50                   	push   %eax
f0102328:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f010232e:	50                   	push   %eax
f010232f:	68 0c 03 00 00       	push   $0x30c
f0102334:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f010233a:	50                   	push   %eax
f010233b:	e8 cb dd ff ff       	call   f010010b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102340:	8d 83 a0 a7 fe ff    	lea    -0x15860(%ebx),%eax
f0102346:	50                   	push   %eax
f0102347:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f010234d:	50                   	push   %eax
f010234e:	68 0d 03 00 00       	push   $0x30d
f0102353:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f0102359:	50                   	push   %eax
f010235a:	e8 ac dd ff ff       	call   f010010b <_panic>
	assert(pp2->pp_ref == 1);
f010235f:	8d 83 10 ae fe ff    	lea    -0x151f0(%ebx),%eax
f0102365:	50                   	push   %eax
f0102366:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f010236c:	50                   	push   %eax
f010236d:	68 0e 03 00 00       	push   $0x30e
f0102372:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f0102378:	50                   	push   %eax
f0102379:	e8 8d dd ff ff       	call   f010010b <_panic>
	assert(!page_alloc(0));
f010237e:	8d 83 9c ad fe ff    	lea    -0x15264(%ebx),%eax
f0102384:	50                   	push   %eax
f0102385:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f010238b:	50                   	push   %eax
f010238c:	68 11 03 00 00       	push   $0x311
f0102391:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f0102397:	50                   	push   %eax
f0102398:	e8 6e dd ff ff       	call   f010010b <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010239d:	8d 83 64 a7 fe ff    	lea    -0x1589c(%ebx),%eax
f01023a3:	50                   	push   %eax
f01023a4:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f01023aa:	50                   	push   %eax
f01023ab:	68 14 03 00 00       	push   $0x314
f01023b0:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f01023b6:	50                   	push   %eax
f01023b7:	e8 4f dd ff ff       	call   f010010b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01023bc:	8d 83 a0 a7 fe ff    	lea    -0x15860(%ebx),%eax
f01023c2:	50                   	push   %eax
f01023c3:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f01023c9:	50                   	push   %eax
f01023ca:	68 15 03 00 00       	push   $0x315
f01023cf:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f01023d5:	50                   	push   %eax
f01023d6:	e8 30 dd ff ff       	call   f010010b <_panic>
	assert(pp2->pp_ref == 1);
f01023db:	8d 83 10 ae fe ff    	lea    -0x151f0(%ebx),%eax
f01023e1:	50                   	push   %eax
f01023e2:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f01023e8:	50                   	push   %eax
f01023e9:	68 16 03 00 00       	push   $0x316
f01023ee:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f01023f4:	50                   	push   %eax
f01023f5:	e8 11 dd ff ff       	call   f010010b <_panic>
	assert(!page_alloc(0));
f01023fa:	8d 83 9c ad fe ff    	lea    -0x15264(%ebx),%eax
f0102400:	50                   	push   %eax
f0102401:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f0102407:	50                   	push   %eax
f0102408:	68 1a 03 00 00       	push   $0x31a
f010240d:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f0102413:	50                   	push   %eax
f0102414:	e8 f2 dc ff ff       	call   f010010b <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102419:	50                   	push   %eax
f010241a:	8d 83 70 a4 fe ff    	lea    -0x15b90(%ebx),%eax
f0102420:	50                   	push   %eax
f0102421:	68 1d 03 00 00       	push   $0x31d
f0102426:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f010242c:	50                   	push   %eax
f010242d:	e8 d9 dc ff ff       	call   f010010b <_panic>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0102432:	8d 83 d0 a7 fe ff    	lea    -0x15830(%ebx),%eax
f0102438:	50                   	push   %eax
f0102439:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f010243f:	50                   	push   %eax
f0102440:	68 1e 03 00 00       	push   $0x31e
f0102445:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f010244b:	50                   	push   %eax
f010244c:	e8 ba dc ff ff       	call   f010010b <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0102451:	8d 83 10 a8 fe ff    	lea    -0x157f0(%ebx),%eax
f0102457:	50                   	push   %eax
f0102458:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f010245e:	50                   	push   %eax
f010245f:	68 21 03 00 00       	push   $0x321
f0102464:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f010246a:	50                   	push   %eax
f010246b:	e8 9b dc ff ff       	call   f010010b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102470:	8d 83 a0 a7 fe ff    	lea    -0x15860(%ebx),%eax
f0102476:	50                   	push   %eax
f0102477:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f010247d:	50                   	push   %eax
f010247e:	68 22 03 00 00       	push   $0x322
f0102483:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f0102489:	50                   	push   %eax
f010248a:	e8 7c dc ff ff       	call   f010010b <_panic>
	assert(pp2->pp_ref == 1);
f010248f:	8d 83 10 ae fe ff    	lea    -0x151f0(%ebx),%eax
f0102495:	50                   	push   %eax
f0102496:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f010249c:	50                   	push   %eax
f010249d:	68 23 03 00 00       	push   $0x323
f01024a2:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f01024a8:	50                   	push   %eax
f01024a9:	e8 5d dc ff ff       	call   f010010b <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f01024ae:	8d 83 50 a8 fe ff    	lea    -0x157b0(%ebx),%eax
f01024b4:	50                   	push   %eax
f01024b5:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f01024bb:	50                   	push   %eax
f01024bc:	68 24 03 00 00       	push   $0x324
f01024c1:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f01024c7:	50                   	push   %eax
f01024c8:	e8 3e dc ff ff       	call   f010010b <_panic>
	assert(kern_pgdir[0] & PTE_U);
f01024cd:	8d 83 21 ae fe ff    	lea    -0x151df(%ebx),%eax
f01024d3:	50                   	push   %eax
f01024d4:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f01024da:	50                   	push   %eax
f01024db:	68 25 03 00 00       	push   $0x325
f01024e0:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f01024e6:	50                   	push   %eax
f01024e7:	e8 1f dc ff ff       	call   f010010b <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01024ec:	8d 83 64 a7 fe ff    	lea    -0x1589c(%ebx),%eax
f01024f2:	50                   	push   %eax
f01024f3:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f01024f9:	50                   	push   %eax
f01024fa:	68 28 03 00 00       	push   $0x328
f01024ff:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f0102505:	50                   	push   %eax
f0102506:	e8 00 dc ff ff       	call   f010010b <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f010250b:	8d 83 84 a8 fe ff    	lea    -0x1577c(%ebx),%eax
f0102511:	50                   	push   %eax
f0102512:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f0102518:	50                   	push   %eax
f0102519:	68 29 03 00 00       	push   $0x329
f010251e:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f0102524:	50                   	push   %eax
f0102525:	e8 e1 db ff ff       	call   f010010b <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f010252a:	8d 83 b8 a8 fe ff    	lea    -0x15748(%ebx),%eax
f0102530:	50                   	push   %eax
f0102531:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f0102537:	50                   	push   %eax
f0102538:	68 2a 03 00 00       	push   $0x32a
f010253d:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f0102543:	50                   	push   %eax
f0102544:	e8 c2 db ff ff       	call   f010010b <_panic>
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0102549:	8d 83 f0 a8 fe ff    	lea    -0x15710(%ebx),%eax
f010254f:	50                   	push   %eax
f0102550:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f0102556:	50                   	push   %eax
f0102557:	68 2d 03 00 00       	push   $0x32d
f010255c:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f0102562:	50                   	push   %eax
f0102563:	e8 a3 db ff ff       	call   f010010b <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0102568:	8d 83 28 a9 fe ff    	lea    -0x156d8(%ebx),%eax
f010256e:	50                   	push   %eax
f010256f:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f0102575:	50                   	push   %eax
f0102576:	68 30 03 00 00       	push   $0x330
f010257b:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f0102581:	50                   	push   %eax
f0102582:	e8 84 db ff ff       	call   f010010b <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102587:	8d 83 b8 a8 fe ff    	lea    -0x15748(%ebx),%eax
f010258d:	50                   	push   %eax
f010258e:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f0102594:	50                   	push   %eax
f0102595:	68 31 03 00 00       	push   $0x331
f010259a:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f01025a0:	50                   	push   %eax
f01025a1:	e8 65 db ff ff       	call   f010010b <_panic>
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f01025a6:	8d 83 64 a9 fe ff    	lea    -0x1569c(%ebx),%eax
f01025ac:	50                   	push   %eax
f01025ad:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f01025b3:	50                   	push   %eax
f01025b4:	68 34 03 00 00       	push   $0x334
f01025b9:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f01025bf:	50                   	push   %eax
f01025c0:	e8 46 db ff ff       	call   f010010b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01025c5:	8d 83 90 a9 fe ff    	lea    -0x15670(%ebx),%eax
f01025cb:	50                   	push   %eax
f01025cc:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f01025d2:	50                   	push   %eax
f01025d3:	68 35 03 00 00       	push   $0x335
f01025d8:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f01025de:	50                   	push   %eax
f01025df:	e8 27 db ff ff       	call   f010010b <_panic>
	assert(pp1->pp_ref == 2);
f01025e4:	8d 83 37 ae fe ff    	lea    -0x151c9(%ebx),%eax
f01025ea:	50                   	push   %eax
f01025eb:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f01025f1:	50                   	push   %eax
f01025f2:	68 37 03 00 00       	push   $0x337
f01025f7:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f01025fd:	50                   	push   %eax
f01025fe:	e8 08 db ff ff       	call   f010010b <_panic>
	assert(pp2->pp_ref == 0);
f0102603:	8d 83 48 ae fe ff    	lea    -0x151b8(%ebx),%eax
f0102609:	50                   	push   %eax
f010260a:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f0102610:	50                   	push   %eax
f0102611:	68 38 03 00 00       	push   $0x338
f0102616:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f010261c:	50                   	push   %eax
f010261d:	e8 e9 da ff ff       	call   f010010b <_panic>
	assert((pp = page_alloc(0)) && pp == pp2);
f0102622:	8d 83 c0 a9 fe ff    	lea    -0x15640(%ebx),%eax
f0102628:	50                   	push   %eax
f0102629:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f010262f:	50                   	push   %eax
f0102630:	68 3b 03 00 00       	push   $0x33b
f0102635:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f010263b:	50                   	push   %eax
f010263c:	e8 ca da ff ff       	call   f010010b <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102641:	8d 83 e4 a9 fe ff    	lea    -0x1561c(%ebx),%eax
f0102647:	50                   	push   %eax
f0102648:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f010264e:	50                   	push   %eax
f010264f:	68 3f 03 00 00       	push   $0x33f
f0102654:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f010265a:	50                   	push   %eax
f010265b:	e8 ab da ff ff       	call   f010010b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102660:	8d 83 90 a9 fe ff    	lea    -0x15670(%ebx),%eax
f0102666:	50                   	push   %eax
f0102667:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f010266d:	50                   	push   %eax
f010266e:	68 40 03 00 00       	push   $0x340
f0102673:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f0102679:	50                   	push   %eax
f010267a:	e8 8c da ff ff       	call   f010010b <_panic>
	assert(pp1->pp_ref == 1);
f010267f:	8d 83 ee ad fe ff    	lea    -0x15212(%ebx),%eax
f0102685:	50                   	push   %eax
f0102686:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f010268c:	50                   	push   %eax
f010268d:	68 41 03 00 00       	push   $0x341
f0102692:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f0102698:	50                   	push   %eax
f0102699:	e8 6d da ff ff       	call   f010010b <_panic>
	assert(pp2->pp_ref == 0);
f010269e:	8d 83 48 ae fe ff    	lea    -0x151b8(%ebx),%eax
f01026a4:	50                   	push   %eax
f01026a5:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f01026ab:	50                   	push   %eax
f01026ac:	68 42 03 00 00       	push   $0x342
f01026b1:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f01026b7:	50                   	push   %eax
f01026b8:	e8 4e da ff ff       	call   f010010b <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f01026bd:	8d 83 08 aa fe ff    	lea    -0x155f8(%ebx),%eax
f01026c3:	50                   	push   %eax
f01026c4:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f01026ca:	50                   	push   %eax
f01026cb:	68 45 03 00 00       	push   $0x345
f01026d0:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f01026d6:	50                   	push   %eax
f01026d7:	e8 2f da ff ff       	call   f010010b <_panic>
	assert(pp1->pp_ref);
f01026dc:	8d 83 59 ae fe ff    	lea    -0x151a7(%ebx),%eax
f01026e2:	50                   	push   %eax
f01026e3:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f01026e9:	50                   	push   %eax
f01026ea:	68 46 03 00 00       	push   $0x346
f01026ef:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f01026f5:	50                   	push   %eax
f01026f6:	e8 10 da ff ff       	call   f010010b <_panic>
	assert(pp1->pp_link == NULL);
f01026fb:	8d 83 65 ae fe ff    	lea    -0x1519b(%ebx),%eax
f0102701:	50                   	push   %eax
f0102702:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f0102708:	50                   	push   %eax
f0102709:	68 47 03 00 00       	push   $0x347
f010270e:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f0102714:	50                   	push   %eax
f0102715:	e8 f1 d9 ff ff       	call   f010010b <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010271a:	8d 83 e4 a9 fe ff    	lea    -0x1561c(%ebx),%eax
f0102720:	50                   	push   %eax
f0102721:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f0102727:	50                   	push   %eax
f0102728:	68 4b 03 00 00       	push   $0x34b
f010272d:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f0102733:	50                   	push   %eax
f0102734:	e8 d2 d9 ff ff       	call   f010010b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102739:	8d 83 40 aa fe ff    	lea    -0x155c0(%ebx),%eax
f010273f:	50                   	push   %eax
f0102740:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f0102746:	50                   	push   %eax
f0102747:	68 4c 03 00 00       	push   $0x34c
f010274c:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f0102752:	50                   	push   %eax
f0102753:	e8 b3 d9 ff ff       	call   f010010b <_panic>
	assert(pp1->pp_ref == 0);
f0102758:	8d 83 7a ae fe ff    	lea    -0x15186(%ebx),%eax
f010275e:	50                   	push   %eax
f010275f:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f0102765:	50                   	push   %eax
f0102766:	68 4d 03 00 00       	push   $0x34d
f010276b:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f0102771:	50                   	push   %eax
f0102772:	e8 94 d9 ff ff       	call   f010010b <_panic>
	assert(pp2->pp_ref == 0);
f0102777:	8d 83 48 ae fe ff    	lea    -0x151b8(%ebx),%eax
f010277d:	50                   	push   %eax
f010277e:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f0102784:	50                   	push   %eax
f0102785:	68 4e 03 00 00       	push   $0x34e
f010278a:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f0102790:	50                   	push   %eax
f0102791:	e8 75 d9 ff ff       	call   f010010b <_panic>
	assert((pp = page_alloc(0)) && pp == pp1);
f0102796:	8d 83 68 aa fe ff    	lea    -0x15598(%ebx),%eax
f010279c:	50                   	push   %eax
f010279d:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f01027a3:	50                   	push   %eax
f01027a4:	68 51 03 00 00       	push   $0x351
f01027a9:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f01027af:	50                   	push   %eax
f01027b0:	e8 56 d9 ff ff       	call   f010010b <_panic>
	assert(!page_alloc(0));
f01027b5:	8d 83 9c ad fe ff    	lea    -0x15264(%ebx),%eax
f01027bb:	50                   	push   %eax
f01027bc:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f01027c2:	50                   	push   %eax
f01027c3:	68 54 03 00 00       	push   $0x354
f01027c8:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f01027ce:	50                   	push   %eax
f01027cf:	e8 37 d9 ff ff       	call   f010010b <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01027d4:	8d 83 0c a7 fe ff    	lea    -0x158f4(%ebx),%eax
f01027da:	50                   	push   %eax
f01027db:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f01027e1:	50                   	push   %eax
f01027e2:	68 57 03 00 00       	push   $0x357
f01027e7:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f01027ed:	50                   	push   %eax
f01027ee:	e8 18 d9 ff ff       	call   f010010b <_panic>
	assert(pp0->pp_ref == 1);
f01027f3:	8d 83 ff ad fe ff    	lea    -0x15201(%ebx),%eax
f01027f9:	50                   	push   %eax
f01027fa:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f0102800:	50                   	push   %eax
f0102801:	68 59 03 00 00       	push   $0x359
f0102806:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f010280c:	50                   	push   %eax
f010280d:	e8 f9 d8 ff ff       	call   f010010b <_panic>
f0102812:	52                   	push   %edx
f0102813:	8d 83 70 a4 fe ff    	lea    -0x15b90(%ebx),%eax
f0102819:	50                   	push   %eax
f010281a:	68 60 03 00 00       	push   $0x360
f010281f:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f0102825:	50                   	push   %eax
f0102826:	e8 e0 d8 ff ff       	call   f010010b <_panic>
	assert(ptep == ptep1 + PTX(va));
f010282b:	8d 83 8b ae fe ff    	lea    -0x15175(%ebx),%eax
f0102831:	50                   	push   %eax
f0102832:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f0102838:	50                   	push   %eax
f0102839:	68 61 03 00 00       	push   $0x361
f010283e:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f0102844:	50                   	push   %eax
f0102845:	e8 c1 d8 ff ff       	call   f010010b <_panic>
f010284a:	50                   	push   %eax
f010284b:	8d 83 70 a4 fe ff    	lea    -0x15b90(%ebx),%eax
f0102851:	50                   	push   %eax
f0102852:	6a 52                	push   $0x52
f0102854:	8d 83 2c ac fe ff    	lea    -0x153d4(%ebx),%eax
f010285a:	50                   	push   %eax
f010285b:	e8 ab d8 ff ff       	call   f010010b <_panic>
f0102860:	50                   	push   %eax
f0102861:	8d 83 70 a4 fe ff    	lea    -0x15b90(%ebx),%eax
f0102867:	50                   	push   %eax
f0102868:	6a 52                	push   $0x52
f010286a:	8d 83 2c ac fe ff    	lea    -0x153d4(%ebx),%eax
f0102870:	50                   	push   %eax
f0102871:	e8 95 d8 ff ff       	call   f010010b <_panic>
		assert((ptep[i] & PTE_P) == 0);
f0102876:	8d 83 a3 ae fe ff    	lea    -0x1515d(%ebx),%eax
f010287c:	50                   	push   %eax
f010287d:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f0102883:	50                   	push   %eax
f0102884:	68 6b 03 00 00       	push   $0x36b
f0102889:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f010288f:	50                   	push   %eax
f0102890:	e8 76 d8 ff ff       	call   f010010b <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102895:	50                   	push   %eax
f0102896:	8d 83 7c a5 fe ff    	lea    -0x15a84(%ebx),%eax
f010289c:	50                   	push   %eax
f010289d:	68 b2 00 00 00       	push   $0xb2
f01028a2:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f01028a8:	50                   	push   %eax
f01028a9:	e8 5d d8 ff ff       	call   f010010b <_panic>
f01028ae:	50                   	push   %eax
f01028af:	8d 83 7c a5 fe ff    	lea    -0x15a84(%ebx),%eax
f01028b5:	50                   	push   %eax
f01028b6:	68 bf 00 00 00       	push   $0xbf
f01028bb:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f01028c1:	50                   	push   %eax
f01028c2:	e8 44 d8 ff ff       	call   f010010b <_panic>
f01028c7:	ff 75 c0             	pushl  -0x40(%ebp)
f01028ca:	8d 83 7c a5 fe ff    	lea    -0x15a84(%ebx),%eax
f01028d0:	50                   	push   %eax
f01028d1:	68 ad 02 00 00       	push   $0x2ad
f01028d6:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f01028dc:	50                   	push   %eax
f01028dd:	e8 29 d8 ff ff       	call   f010010b <_panic>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01028e2:	8d 83 8c aa fe ff    	lea    -0x15574(%ebx),%eax
f01028e8:	50                   	push   %eax
f01028e9:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f01028ef:	50                   	push   %eax
f01028f0:	68 ad 02 00 00       	push   $0x2ad
f01028f5:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f01028fb:	50                   	push   %eax
f01028fc:	e8 0a d8 ff ff       	call   f010010b <_panic>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102901:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0102904:	c1 e0 0c             	shl    $0xc,%eax
f0102907:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010290a:	be 00 00 00 00       	mov    $0x0,%esi
f010290f:	eb 06                	jmp    f0102917 <mem_init+0x15b1>
f0102911:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102917:	3b 75 d0             	cmp    -0x30(%ebp),%esi
f010291a:	73 30                	jae    f010294c <mem_init+0x15e6>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f010291c:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
f0102922:	89 f8                	mov    %edi,%eax
f0102924:	e8 c8 e1 ff ff       	call   f0100af1 <check_va2pa>
f0102929:	39 c6                	cmp    %eax,%esi
f010292b:	74 e4                	je     f0102911 <mem_init+0x15ab>
f010292d:	8d 83 c0 aa fe ff    	lea    -0x15540(%ebx),%eax
f0102933:	50                   	push   %eax
f0102934:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f010293a:	50                   	push   %eax
f010293b:	68 b2 02 00 00       	push   $0x2b2
f0102940:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f0102946:	50                   	push   %eax
f0102947:	e8 bf d7 ff ff       	call   f010010b <_panic>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f010294c:	be 00 80 ff ef       	mov    $0xefff8000,%esi
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102951:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102954:	05 00 80 00 20       	add    $0x20008000,%eax
f0102959:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010295c:	89 f2                	mov    %esi,%edx
f010295e:	89 f8                	mov    %edi,%eax
f0102960:	e8 8c e1 ff ff       	call   f0100af1 <check_va2pa>
f0102965:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102968:	8d 14 31             	lea    (%ecx,%esi,1),%edx
f010296b:	39 c2                	cmp    %eax,%edx
f010296d:	0f 85 85 00 00 00    	jne    f01029f8 <mem_init+0x1692>
f0102973:	81 c6 00 10 00 00    	add    $0x1000,%esi
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102979:	81 fe 00 00 00 f0    	cmp    $0xf0000000,%esi
f010297f:	75 db                	jne    f010295c <mem_init+0x15f6>
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102981:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f0102986:	89 f8                	mov    %edi,%eax
f0102988:	e8 64 e1 ff ff       	call   f0100af1 <check_va2pa>
f010298d:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102990:	0f 85 81 00 00 00    	jne    f0102a17 <mem_init+0x16b1>
	for (i = 0; i < NPDENTRIES; i++) {
f0102996:	b8 00 00 00 00       	mov    $0x0,%eax
			if (i >= PDX(KERNBASE)) {
f010299b:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f01029a0:	0f 87 90 00 00 00    	ja     f0102a36 <mem_init+0x16d0>
				assert(pgdir[i] == 0);
f01029a6:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f01029aa:	0f 85 d5 00 00 00    	jne    f0102a85 <mem_init+0x171f>
	for (i = 0; i < NPDENTRIES; i++) {
f01029b0:	83 c0 01             	add    $0x1,%eax
f01029b3:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f01029b8:	0f 87 e6 00 00 00    	ja     f0102aa4 <mem_init+0x173e>
		switch (i) {
f01029be:	3d bc 03 00 00       	cmp    $0x3bc,%eax
f01029c3:	72 d6                	jb     f010299b <mem_init+0x1635>
f01029c5:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f01029ca:	76 07                	jbe    f01029d3 <mem_init+0x166d>
f01029cc:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f01029d1:	75 c8                	jne    f010299b <mem_init+0x1635>
			assert(pgdir[i] & PTE_P);
f01029d3:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f01029d7:	75 d7                	jne    f01029b0 <mem_init+0x164a>
f01029d9:	8d 83 d3 ae fe ff    	lea    -0x1512d(%ebx),%eax
f01029df:	50                   	push   %eax
f01029e0:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f01029e6:	50                   	push   %eax
f01029e7:	68 bf 02 00 00       	push   $0x2bf
f01029ec:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f01029f2:	50                   	push   %eax
f01029f3:	e8 13 d7 ff ff       	call   f010010b <_panic>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f01029f8:	8d 83 e8 aa fe ff    	lea    -0x15518(%ebx),%eax
f01029fe:	50                   	push   %eax
f01029ff:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f0102a05:	50                   	push   %eax
f0102a06:	68 b6 02 00 00       	push   $0x2b6
f0102a0b:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f0102a11:	50                   	push   %eax
f0102a12:	e8 f4 d6 ff ff       	call   f010010b <_panic>
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102a17:	8d 83 30 ab fe ff    	lea    -0x154d0(%ebx),%eax
f0102a1d:	50                   	push   %eax
f0102a1e:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f0102a24:	50                   	push   %eax
f0102a25:	68 b7 02 00 00       	push   $0x2b7
f0102a2a:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f0102a30:	50                   	push   %eax
f0102a31:	e8 d5 d6 ff ff       	call   f010010b <_panic>
				assert(pgdir[i] & PTE_P);
f0102a36:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0102a39:	f6 c2 01             	test   $0x1,%dl
f0102a3c:	74 28                	je     f0102a66 <mem_init+0x1700>
				assert(pgdir[i] & PTE_W);
f0102a3e:	f6 c2 02             	test   $0x2,%dl
f0102a41:	0f 85 69 ff ff ff    	jne    f01029b0 <mem_init+0x164a>
f0102a47:	8d 83 e4 ae fe ff    	lea    -0x1511c(%ebx),%eax
f0102a4d:	50                   	push   %eax
f0102a4e:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f0102a54:	50                   	push   %eax
f0102a55:	68 c4 02 00 00       	push   $0x2c4
f0102a5a:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f0102a60:	50                   	push   %eax
f0102a61:	e8 a5 d6 ff ff       	call   f010010b <_panic>
				assert(pgdir[i] & PTE_P);
f0102a66:	8d 83 d3 ae fe ff    	lea    -0x1512d(%ebx),%eax
f0102a6c:	50                   	push   %eax
f0102a6d:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f0102a73:	50                   	push   %eax
f0102a74:	68 c3 02 00 00       	push   $0x2c3
f0102a79:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f0102a7f:	50                   	push   %eax
f0102a80:	e8 86 d6 ff ff       	call   f010010b <_panic>
				assert(pgdir[i] == 0);
f0102a85:	8d 83 f5 ae fe ff    	lea    -0x1510b(%ebx),%eax
f0102a8b:	50                   	push   %eax
f0102a8c:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f0102a92:	50                   	push   %eax
f0102a93:	68 c6 02 00 00       	push   $0x2c6
f0102a98:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f0102a9e:	50                   	push   %eax
f0102a9f:	e8 67 d6 ff ff       	call   f010010b <_panic>
	cprintf("check_kern_pgdir() succeeded!\n");
f0102aa4:	83 ec 0c             	sub    $0xc,%esp
f0102aa7:	8d 83 60 ab fe ff    	lea    -0x154a0(%ebx),%eax
f0102aad:	50                   	push   %eax
f0102aae:	e8 ab 04 00 00       	call   f0102f5e <cprintf>
	lcr3(PADDR(kern_pgdir));
f0102ab3:	c7 c0 ec a6 11 f0    	mov    $0xf011a6ec,%eax
f0102ab9:	8b 00                	mov    (%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0102abb:	83 c4 10             	add    $0x10,%esp
f0102abe:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102ac3:	0f 86 28 02 00 00    	jbe    f0102cf1 <mem_init+0x198b>
	return (physaddr_t)kva - KERNBASE;
f0102ac9:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102ace:	0f 22 d8             	mov    %eax,%cr3
	check_page_free_list(0);
f0102ad1:	b8 00 00 00 00       	mov    $0x0,%eax
f0102ad6:	e8 93 e0 ff ff       	call   f0100b6e <check_page_free_list>
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0102adb:	0f 20 c0             	mov    %cr0,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f0102ade:	83 e0 f3             	and    $0xfffffff3,%eax
f0102ae1:	0d 23 00 05 80       	or     $0x80050023,%eax
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0102ae6:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102ae9:	83 ec 0c             	sub    $0xc,%esp
f0102aec:	6a 00                	push   $0x0
f0102aee:	e8 16 e5 ff ff       	call   f0101009 <page_alloc>
f0102af3:	89 c7                	mov    %eax,%edi
f0102af5:	83 c4 10             	add    $0x10,%esp
f0102af8:	85 c0                	test   %eax,%eax
f0102afa:	0f 84 0a 02 00 00    	je     f0102d0a <mem_init+0x19a4>
	assert((pp1 = page_alloc(0)));
f0102b00:	83 ec 0c             	sub    $0xc,%esp
f0102b03:	6a 00                	push   $0x0
f0102b05:	e8 ff e4 ff ff       	call   f0101009 <page_alloc>
f0102b0a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102b0d:	83 c4 10             	add    $0x10,%esp
f0102b10:	85 c0                	test   %eax,%eax
f0102b12:	0f 84 11 02 00 00    	je     f0102d29 <mem_init+0x19c3>
	assert((pp2 = page_alloc(0)));
f0102b18:	83 ec 0c             	sub    $0xc,%esp
f0102b1b:	6a 00                	push   $0x0
f0102b1d:	e8 e7 e4 ff ff       	call   f0101009 <page_alloc>
f0102b22:	89 c6                	mov    %eax,%esi
f0102b24:	83 c4 10             	add    $0x10,%esp
f0102b27:	85 c0                	test   %eax,%eax
f0102b29:	0f 84 19 02 00 00    	je     f0102d48 <mem_init+0x19e2>
	page_free(pp0);
f0102b2f:	83 ec 0c             	sub    $0xc,%esp
f0102b32:	57                   	push   %edi
f0102b33:	e8 59 e5 ff ff       	call   f0101091 <page_free>
	return (pp - pages) << PGSHIFT;
f0102b38:	c7 c0 f0 a6 11 f0    	mov    $0xf011a6f0,%eax
f0102b3e:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102b41:	2b 08                	sub    (%eax),%ecx
f0102b43:	89 c8                	mov    %ecx,%eax
f0102b45:	c1 f8 03             	sar    $0x3,%eax
f0102b48:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102b4b:	89 c1                	mov    %eax,%ecx
f0102b4d:	c1 e9 0c             	shr    $0xc,%ecx
f0102b50:	83 c4 10             	add    $0x10,%esp
f0102b53:	c7 c2 e8 a6 11 f0    	mov    $0xf011a6e8,%edx
f0102b59:	3b 0a                	cmp    (%edx),%ecx
f0102b5b:	0f 83 06 02 00 00    	jae    f0102d67 <mem_init+0x1a01>
	memset(page2kva(pp1), 1, PGSIZE);
f0102b61:	83 ec 04             	sub    $0x4,%esp
f0102b64:	68 00 10 00 00       	push   $0x1000
f0102b69:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0102b6b:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102b70:	50                   	push   %eax
f0102b71:	e8 09 10 00 00       	call   f0103b7f <memset>
	return (pp - pages) << PGSHIFT;
f0102b76:	c7 c0 f0 a6 11 f0    	mov    $0xf011a6f0,%eax
f0102b7c:	89 f1                	mov    %esi,%ecx
f0102b7e:	2b 08                	sub    (%eax),%ecx
f0102b80:	89 c8                	mov    %ecx,%eax
f0102b82:	c1 f8 03             	sar    $0x3,%eax
f0102b85:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102b88:	89 c1                	mov    %eax,%ecx
f0102b8a:	c1 e9 0c             	shr    $0xc,%ecx
f0102b8d:	83 c4 10             	add    $0x10,%esp
f0102b90:	c7 c2 e8 a6 11 f0    	mov    $0xf011a6e8,%edx
f0102b96:	3b 0a                	cmp    (%edx),%ecx
f0102b98:	0f 83 df 01 00 00    	jae    f0102d7d <mem_init+0x1a17>
	memset(page2kva(pp2), 2, PGSIZE);
f0102b9e:	83 ec 04             	sub    $0x4,%esp
f0102ba1:	68 00 10 00 00       	push   $0x1000
f0102ba6:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f0102ba8:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102bad:	50                   	push   %eax
f0102bae:	e8 cc 0f 00 00       	call   f0103b7f <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102bb3:	6a 02                	push   $0x2
f0102bb5:	68 00 10 00 00       	push   $0x1000
f0102bba:	ff 75 d4             	pushl  -0x2c(%ebp)
f0102bbd:	c7 c0 ec a6 11 f0    	mov    $0xf011a6ec,%eax
f0102bc3:	ff 30                	pushl  (%eax)
f0102bc5:	e8 26 e7 ff ff       	call   f01012f0 <page_insert>
	assert(pp1->pp_ref == 1);
f0102bca:	83 c4 20             	add    $0x20,%esp
f0102bcd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102bd0:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0102bd5:	0f 85 b8 01 00 00    	jne    f0102d93 <mem_init+0x1a2d>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102bdb:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102be2:	01 01 01 
f0102be5:	0f 85 c7 01 00 00    	jne    f0102db2 <mem_init+0x1a4c>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102beb:	6a 02                	push   $0x2
f0102bed:	68 00 10 00 00       	push   $0x1000
f0102bf2:	56                   	push   %esi
f0102bf3:	c7 c0 ec a6 11 f0    	mov    $0xf011a6ec,%eax
f0102bf9:	ff 30                	pushl  (%eax)
f0102bfb:	e8 f0 e6 ff ff       	call   f01012f0 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102c00:	83 c4 10             	add    $0x10,%esp
f0102c03:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102c0a:	02 02 02 
f0102c0d:	0f 85 be 01 00 00    	jne    f0102dd1 <mem_init+0x1a6b>
	assert(pp2->pp_ref == 1);
f0102c13:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102c18:	0f 85 d2 01 00 00    	jne    f0102df0 <mem_init+0x1a8a>
	assert(pp1->pp_ref == 0);
f0102c1e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102c21:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0102c26:	0f 85 e3 01 00 00    	jne    f0102e0f <mem_init+0x1aa9>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102c2c:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102c33:	03 03 03 
	return (pp - pages) << PGSHIFT;
f0102c36:	c7 c0 f0 a6 11 f0    	mov    $0xf011a6f0,%eax
f0102c3c:	89 f1                	mov    %esi,%ecx
f0102c3e:	2b 08                	sub    (%eax),%ecx
f0102c40:	89 c8                	mov    %ecx,%eax
f0102c42:	c1 f8 03             	sar    $0x3,%eax
f0102c45:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102c48:	89 c1                	mov    %eax,%ecx
f0102c4a:	c1 e9 0c             	shr    $0xc,%ecx
f0102c4d:	c7 c2 e8 a6 11 f0    	mov    $0xf011a6e8,%edx
f0102c53:	3b 0a                	cmp    (%edx),%ecx
f0102c55:	0f 83 d3 01 00 00    	jae    f0102e2e <mem_init+0x1ac8>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102c5b:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102c62:	03 03 03 
f0102c65:	0f 85 d9 01 00 00    	jne    f0102e44 <mem_init+0x1ade>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102c6b:	83 ec 08             	sub    $0x8,%esp
f0102c6e:	68 00 10 00 00       	push   $0x1000
f0102c73:	c7 c0 ec a6 11 f0    	mov    $0xf011a6ec,%eax
f0102c79:	ff 30                	pushl  (%eax)
f0102c7b:	e8 35 e6 ff ff       	call   f01012b5 <page_remove>
	assert(pp2->pp_ref == 0);
f0102c80:	83 c4 10             	add    $0x10,%esp
f0102c83:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102c88:	0f 85 d5 01 00 00    	jne    f0102e63 <mem_init+0x1afd>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102c8e:	c7 c0 ec a6 11 f0    	mov    $0xf011a6ec,%eax
f0102c94:	8b 08                	mov    (%eax),%ecx
f0102c96:	8b 11                	mov    (%ecx),%edx
f0102c98:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	return (pp - pages) << PGSHIFT;
f0102c9e:	c7 c0 f0 a6 11 f0    	mov    $0xf011a6f0,%eax
f0102ca4:	89 fe                	mov    %edi,%esi
f0102ca6:	2b 30                	sub    (%eax),%esi
f0102ca8:	89 f0                	mov    %esi,%eax
f0102caa:	c1 f8 03             	sar    $0x3,%eax
f0102cad:	c1 e0 0c             	shl    $0xc,%eax
f0102cb0:	39 c2                	cmp    %eax,%edx
f0102cb2:	0f 85 ca 01 00 00    	jne    f0102e82 <mem_init+0x1b1c>
	kern_pgdir[0] = 0;
f0102cb8:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102cbe:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102cc3:	0f 85 d8 01 00 00    	jne    f0102ea1 <mem_init+0x1b3b>
	pp0->pp_ref = 0;
f0102cc9:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// free the pages we took
	page_free(pp0);
f0102ccf:	83 ec 0c             	sub    $0xc,%esp
f0102cd2:	57                   	push   %edi
f0102cd3:	e8 b9 e3 ff ff       	call   f0101091 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102cd8:	8d 83 f4 ab fe ff    	lea    -0x1540c(%ebx),%eax
f0102cde:	89 04 24             	mov    %eax,(%esp)
f0102ce1:	e8 78 02 00 00       	call   f0102f5e <cprintf>
}
f0102ce6:	83 c4 10             	add    $0x10,%esp
f0102ce9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102cec:	5b                   	pop    %ebx
f0102ced:	5e                   	pop    %esi
f0102cee:	5f                   	pop    %edi
f0102cef:	5d                   	pop    %ebp
f0102cf0:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102cf1:	50                   	push   %eax
f0102cf2:	8d 83 7c a5 fe ff    	lea    -0x15a84(%ebx),%eax
f0102cf8:	50                   	push   %eax
f0102cf9:	68 d5 00 00 00       	push   $0xd5
f0102cfe:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f0102d04:	50                   	push   %eax
f0102d05:	e8 01 d4 ff ff       	call   f010010b <_panic>
	assert((pp0 = page_alloc(0)));
f0102d0a:	8d 83 f1 ac fe ff    	lea    -0x1530f(%ebx),%eax
f0102d10:	50                   	push   %eax
f0102d11:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f0102d17:	50                   	push   %eax
f0102d18:	68 86 03 00 00       	push   $0x386
f0102d1d:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f0102d23:	50                   	push   %eax
f0102d24:	e8 e2 d3 ff ff       	call   f010010b <_panic>
	assert((pp1 = page_alloc(0)));
f0102d29:	8d 83 07 ad fe ff    	lea    -0x152f9(%ebx),%eax
f0102d2f:	50                   	push   %eax
f0102d30:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f0102d36:	50                   	push   %eax
f0102d37:	68 87 03 00 00       	push   $0x387
f0102d3c:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f0102d42:	50                   	push   %eax
f0102d43:	e8 c3 d3 ff ff       	call   f010010b <_panic>
	assert((pp2 = page_alloc(0)));
f0102d48:	8d 83 1d ad fe ff    	lea    -0x152e3(%ebx),%eax
f0102d4e:	50                   	push   %eax
f0102d4f:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f0102d55:	50                   	push   %eax
f0102d56:	68 88 03 00 00       	push   $0x388
f0102d5b:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f0102d61:	50                   	push   %eax
f0102d62:	e8 a4 d3 ff ff       	call   f010010b <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102d67:	50                   	push   %eax
f0102d68:	8d 83 70 a4 fe ff    	lea    -0x15b90(%ebx),%eax
f0102d6e:	50                   	push   %eax
f0102d6f:	6a 52                	push   $0x52
f0102d71:	8d 83 2c ac fe ff    	lea    -0x153d4(%ebx),%eax
f0102d77:	50                   	push   %eax
f0102d78:	e8 8e d3 ff ff       	call   f010010b <_panic>
f0102d7d:	50                   	push   %eax
f0102d7e:	8d 83 70 a4 fe ff    	lea    -0x15b90(%ebx),%eax
f0102d84:	50                   	push   %eax
f0102d85:	6a 52                	push   $0x52
f0102d87:	8d 83 2c ac fe ff    	lea    -0x153d4(%ebx),%eax
f0102d8d:	50                   	push   %eax
f0102d8e:	e8 78 d3 ff ff       	call   f010010b <_panic>
	assert(pp1->pp_ref == 1);
f0102d93:	8d 83 ee ad fe ff    	lea    -0x15212(%ebx),%eax
f0102d99:	50                   	push   %eax
f0102d9a:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f0102da0:	50                   	push   %eax
f0102da1:	68 8d 03 00 00       	push   $0x38d
f0102da6:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f0102dac:	50                   	push   %eax
f0102dad:	e8 59 d3 ff ff       	call   f010010b <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102db2:	8d 83 80 ab fe ff    	lea    -0x15480(%ebx),%eax
f0102db8:	50                   	push   %eax
f0102db9:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f0102dbf:	50                   	push   %eax
f0102dc0:	68 8e 03 00 00       	push   $0x38e
f0102dc5:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f0102dcb:	50                   	push   %eax
f0102dcc:	e8 3a d3 ff ff       	call   f010010b <_panic>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102dd1:	8d 83 a4 ab fe ff    	lea    -0x1545c(%ebx),%eax
f0102dd7:	50                   	push   %eax
f0102dd8:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f0102dde:	50                   	push   %eax
f0102ddf:	68 90 03 00 00       	push   $0x390
f0102de4:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f0102dea:	50                   	push   %eax
f0102deb:	e8 1b d3 ff ff       	call   f010010b <_panic>
	assert(pp2->pp_ref == 1);
f0102df0:	8d 83 10 ae fe ff    	lea    -0x151f0(%ebx),%eax
f0102df6:	50                   	push   %eax
f0102df7:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f0102dfd:	50                   	push   %eax
f0102dfe:	68 91 03 00 00       	push   $0x391
f0102e03:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f0102e09:	50                   	push   %eax
f0102e0a:	e8 fc d2 ff ff       	call   f010010b <_panic>
	assert(pp1->pp_ref == 0);
f0102e0f:	8d 83 7a ae fe ff    	lea    -0x15186(%ebx),%eax
f0102e15:	50                   	push   %eax
f0102e16:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f0102e1c:	50                   	push   %eax
f0102e1d:	68 92 03 00 00       	push   $0x392
f0102e22:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f0102e28:	50                   	push   %eax
f0102e29:	e8 dd d2 ff ff       	call   f010010b <_panic>
f0102e2e:	50                   	push   %eax
f0102e2f:	8d 83 70 a4 fe ff    	lea    -0x15b90(%ebx),%eax
f0102e35:	50                   	push   %eax
f0102e36:	6a 52                	push   $0x52
f0102e38:	8d 83 2c ac fe ff    	lea    -0x153d4(%ebx),%eax
f0102e3e:	50                   	push   %eax
f0102e3f:	e8 c7 d2 ff ff       	call   f010010b <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102e44:	8d 83 c8 ab fe ff    	lea    -0x15438(%ebx),%eax
f0102e4a:	50                   	push   %eax
f0102e4b:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f0102e51:	50                   	push   %eax
f0102e52:	68 94 03 00 00       	push   $0x394
f0102e57:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f0102e5d:	50                   	push   %eax
f0102e5e:	e8 a8 d2 ff ff       	call   f010010b <_panic>
	assert(pp2->pp_ref == 0);
f0102e63:	8d 83 48 ae fe ff    	lea    -0x151b8(%ebx),%eax
f0102e69:	50                   	push   %eax
f0102e6a:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f0102e70:	50                   	push   %eax
f0102e71:	68 96 03 00 00       	push   $0x396
f0102e76:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f0102e7c:	50                   	push   %eax
f0102e7d:	e8 89 d2 ff ff       	call   f010010b <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102e82:	8d 83 0c a7 fe ff    	lea    -0x158f4(%ebx),%eax
f0102e88:	50                   	push   %eax
f0102e89:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f0102e8f:	50                   	push   %eax
f0102e90:	68 99 03 00 00       	push   $0x399
f0102e95:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f0102e9b:	50                   	push   %eax
f0102e9c:	e8 6a d2 ff ff       	call   f010010b <_panic>
	assert(pp0->pp_ref == 1);
f0102ea1:	8d 83 ff ad fe ff    	lea    -0x15201(%ebx),%eax
f0102ea7:	50                   	push   %eax
f0102ea8:	8d 83 46 ac fe ff    	lea    -0x153ba(%ebx),%eax
f0102eae:	50                   	push   %eax
f0102eaf:	68 9b 03 00 00       	push   $0x39b
f0102eb4:	8d 83 20 ac fe ff    	lea    -0x153e0(%ebx),%eax
f0102eba:	50                   	push   %eax
f0102ebb:	e8 4b d2 ff ff       	call   f010010b <_panic>

f0102ec0 <tlb_invalidate>:
{
f0102ec0:	55                   	push   %ebp
f0102ec1:	89 e5                	mov    %esp,%ebp
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0102ec3:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102ec6:	0f 01 38             	invlpg (%eax)
}
f0102ec9:	5d                   	pop    %ebp
f0102eca:	c3                   	ret    

f0102ecb <__x86.get_pc_thunk.cx>:
f0102ecb:	8b 0c 24             	mov    (%esp),%ecx
f0102ece:	c3                   	ret    

f0102ecf <__x86.get_pc_thunk.si>:
f0102ecf:	8b 34 24             	mov    (%esp),%esi
f0102ed2:	c3                   	ret    

f0102ed3 <__x86.get_pc_thunk.di>:
f0102ed3:	8b 3c 24             	mov    (%esp),%edi
f0102ed6:	c3                   	ret    

f0102ed7 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0102ed7:	55                   	push   %ebp
f0102ed8:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102eda:	8b 45 08             	mov    0x8(%ebp),%eax
f0102edd:	ba 70 00 00 00       	mov    $0x70,%edx
f0102ee2:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0102ee3:	ba 71 00 00 00       	mov    $0x71,%edx
f0102ee8:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0102ee9:	0f b6 c0             	movzbl %al,%eax
}
f0102eec:	5d                   	pop    %ebp
f0102eed:	c3                   	ret    

f0102eee <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0102eee:	55                   	push   %ebp
f0102eef:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102ef1:	8b 45 08             	mov    0x8(%ebp),%eax
f0102ef4:	ba 70 00 00 00       	mov    $0x70,%edx
f0102ef9:	ee                   	out    %al,(%dx)
f0102efa:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102efd:	ba 71 00 00 00       	mov    $0x71,%edx
f0102f02:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0102f03:	5d                   	pop    %ebp
f0102f04:	c3                   	ret    

f0102f05 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0102f05:	55                   	push   %ebp
f0102f06:	89 e5                	mov    %esp,%ebp
f0102f08:	53                   	push   %ebx
f0102f09:	83 ec 10             	sub    $0x10,%esp
f0102f0c:	e8 b0 d2 ff ff       	call   f01001c1 <__x86.get_pc_thunk.bx>
f0102f11:	81 c3 57 71 01 00    	add    $0x17157,%ebx
	cputchar(ch);
f0102f17:	ff 75 08             	pushl  0x8(%ebp)
f0102f1a:	e8 ec d7 ff ff       	call   f010070b <cputchar>
	*cnt++;
}
f0102f1f:	83 c4 10             	add    $0x10,%esp
f0102f22:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102f25:	c9                   	leave  
f0102f26:	c3                   	ret    

f0102f27 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0102f27:	55                   	push   %ebp
f0102f28:	89 e5                	mov    %esp,%ebp
f0102f2a:	53                   	push   %ebx
f0102f2b:	83 ec 14             	sub    $0x14,%esp
f0102f2e:	e8 8e d2 ff ff       	call   f01001c1 <__x86.get_pc_thunk.bx>
f0102f33:	81 c3 35 71 01 00    	add    $0x17135,%ebx
	int cnt = 0;
f0102f39:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0102f40:	ff 75 0c             	pushl  0xc(%ebp)
f0102f43:	ff 75 08             	pushl  0x8(%ebp)
f0102f46:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0102f49:	50                   	push   %eax
f0102f4a:	8d 83 9d 8e fe ff    	lea    -0x17163(%ebx),%eax
f0102f50:	50                   	push   %eax
f0102f51:	e8 96 04 00 00       	call   f01033ec <vprintfmt>
	return cnt;
}
f0102f56:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102f59:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102f5c:	c9                   	leave  
f0102f5d:	c3                   	ret    

f0102f5e <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0102f5e:	55                   	push   %ebp
f0102f5f:	89 e5                	mov    %esp,%ebp
f0102f61:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0102f64:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0102f67:	50                   	push   %eax
f0102f68:	ff 75 08             	pushl  0x8(%ebp)
f0102f6b:	e8 b7 ff ff ff       	call   f0102f27 <vcprintf>
	va_end(ap);

	return cnt;
}
f0102f70:	c9                   	leave  
f0102f71:	c3                   	ret    

f0102f72 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0102f72:	55                   	push   %ebp
f0102f73:	89 e5                	mov    %esp,%ebp
f0102f75:	57                   	push   %edi
f0102f76:	56                   	push   %esi
f0102f77:	53                   	push   %ebx
f0102f78:	83 ec 14             	sub    $0x14,%esp
f0102f7b:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0102f7e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0102f81:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0102f84:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0102f87:	8b 1a                	mov    (%edx),%ebx
f0102f89:	8b 01                	mov    (%ecx),%eax
f0102f8b:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0102f8e:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0102f95:	eb 23                	jmp    f0102fba <stab_binsearch+0x48>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0102f97:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0102f9a:	eb 1e                	jmp    f0102fba <stab_binsearch+0x48>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0102f9c:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0102f9f:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0102fa2:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0102fa6:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0102fa9:	73 41                	jae    f0102fec <stab_binsearch+0x7a>
			*region_left = m;
f0102fab:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0102fae:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0102fb0:	8d 5f 01             	lea    0x1(%edi),%ebx
		any_matches = 1;
f0102fb3:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0102fba:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0102fbd:	7f 5a                	jg     f0103019 <stab_binsearch+0xa7>
		int true_m = (l + r) / 2, m = true_m;
f0102fbf:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0102fc2:	01 d8                	add    %ebx,%eax
f0102fc4:	89 c7                	mov    %eax,%edi
f0102fc6:	c1 ef 1f             	shr    $0x1f,%edi
f0102fc9:	01 c7                	add    %eax,%edi
f0102fcb:	d1 ff                	sar    %edi
f0102fcd:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0102fd0:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0102fd3:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0102fd7:	89 f8                	mov    %edi,%eax
		while (m >= l && stabs[m].n_type != type)
f0102fd9:	39 c3                	cmp    %eax,%ebx
f0102fdb:	7f ba                	jg     f0102f97 <stab_binsearch+0x25>
f0102fdd:	0f b6 0a             	movzbl (%edx),%ecx
f0102fe0:	83 ea 0c             	sub    $0xc,%edx
f0102fe3:	39 f1                	cmp    %esi,%ecx
f0102fe5:	74 b5                	je     f0102f9c <stab_binsearch+0x2a>
			m--;
f0102fe7:	83 e8 01             	sub    $0x1,%eax
f0102fea:	eb ed                	jmp    f0102fd9 <stab_binsearch+0x67>
		} else if (stabs[m].n_value > addr) {
f0102fec:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0102fef:	76 14                	jbe    f0103005 <stab_binsearch+0x93>
			*region_right = m - 1;
f0102ff1:	83 e8 01             	sub    $0x1,%eax
f0102ff4:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0102ff7:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0102ffa:	89 07                	mov    %eax,(%edi)
		any_matches = 1;
f0102ffc:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0103003:	eb b5                	jmp    f0102fba <stab_binsearch+0x48>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0103005:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103008:	89 07                	mov    %eax,(%edi)
			l = m;
			addr++;
f010300a:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f010300e:	89 c3                	mov    %eax,%ebx
		any_matches = 1;
f0103010:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0103017:	eb a1                	jmp    f0102fba <stab_binsearch+0x48>
		}
	}

	if (!any_matches)
f0103019:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f010301d:	75 15                	jne    f0103034 <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f010301f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103022:	8b 00                	mov    (%eax),%eax
f0103024:	83 e8 01             	sub    $0x1,%eax
f0103027:	8b 75 e0             	mov    -0x20(%ebp),%esi
f010302a:	89 06                	mov    %eax,(%esi)
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f010302c:	83 c4 14             	add    $0x14,%esp
f010302f:	5b                   	pop    %ebx
f0103030:	5e                   	pop    %esi
f0103031:	5f                   	pop    %edi
f0103032:	5d                   	pop    %ebp
f0103033:	c3                   	ret    
		for (l = *region_right;
f0103034:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103037:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0103039:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010303c:	8b 0f                	mov    (%edi),%ecx
f010303e:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103041:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0103044:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
		for (l = *region_right;
f0103048:	eb 03                	jmp    f010304d <stab_binsearch+0xdb>
		     l--)
f010304a:	83 e8 01             	sub    $0x1,%eax
		for (l = *region_right;
f010304d:	39 c1                	cmp    %eax,%ecx
f010304f:	7d 0a                	jge    f010305b <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f0103051:	0f b6 1a             	movzbl (%edx),%ebx
f0103054:	83 ea 0c             	sub    $0xc,%edx
f0103057:	39 f3                	cmp    %esi,%ebx
f0103059:	75 ef                	jne    f010304a <stab_binsearch+0xd8>
		*region_left = l;
f010305b:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f010305e:	89 06                	mov    %eax,(%esi)
}
f0103060:	eb ca                	jmp    f010302c <stab_binsearch+0xba>

f0103062 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0103062:	55                   	push   %ebp
f0103063:	89 e5                	mov    %esp,%ebp
f0103065:	57                   	push   %edi
f0103066:	56                   	push   %esi
f0103067:	53                   	push   %ebx
f0103068:	83 ec 3c             	sub    $0x3c,%esp
f010306b:	e8 51 d1 ff ff       	call   f01001c1 <__x86.get_pc_thunk.bx>
f0103070:	81 c3 f8 6f 01 00    	add    $0x16ff8,%ebx
f0103076:	89 5d bc             	mov    %ebx,-0x44(%ebp)
f0103079:	8b 7d 08             	mov    0x8(%ebp),%edi
f010307c:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f010307f:	8d 83 03 af fe ff    	lea    -0x150fd(%ebx),%eax
f0103085:	89 06                	mov    %eax,(%esi)
	info->eip_line = 0;
f0103087:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f010308e:	89 46 08             	mov    %eax,0x8(%esi)
	info->eip_fn_namelen = 9;
f0103091:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f0103098:	89 7e 10             	mov    %edi,0x10(%esi)
	info->eip_fn_narg = 0;
f010309b:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f01030a2:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f01030a8:	0f 86 42 01 00 00    	jbe    f01031f0 <debuginfo_eip+0x18e>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01030ae:	c7 c0 05 c5 10 f0    	mov    $0xf010c505,%eax
f01030b4:	39 83 fc ff ff ff    	cmp    %eax,-0x4(%ebx)
f01030ba:	0f 86 04 02 00 00    	jbe    f01032c4 <debuginfo_eip+0x262>
f01030c0:	8b 5d bc             	mov    -0x44(%ebp),%ebx
f01030c3:	c7 c0 a1 e3 10 f0    	mov    $0xf010e3a1,%eax
f01030c9:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f01030cd:	0f 85 f8 01 00 00    	jne    f01032cb <debuginfo_eip+0x269>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f01030d3:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f01030da:	c7 c0 84 51 10 f0    	mov    $0xf0105184,%eax
f01030e0:	c7 c2 04 c5 10 f0    	mov    $0xf010c504,%edx
f01030e6:	29 c2                	sub    %eax,%edx
f01030e8:	c1 fa 02             	sar    $0x2,%edx
f01030eb:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f01030f1:	83 ea 01             	sub    $0x1,%edx
f01030f4:	89 55 e0             	mov    %edx,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f01030f7:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f01030fa:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f01030fd:	83 ec 08             	sub    $0x8,%esp
f0103100:	57                   	push   %edi
f0103101:	6a 64                	push   $0x64
f0103103:	e8 6a fe ff ff       	call   f0102f72 <stab_binsearch>
	if (lfile == 0)
f0103108:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010310b:	83 c4 10             	add    $0x10,%esp
f010310e:	85 c0                	test   %eax,%eax
f0103110:	0f 84 bc 01 00 00    	je     f01032d2 <debuginfo_eip+0x270>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0103116:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0103119:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010311c:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f010311f:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0103122:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0103125:	83 ec 08             	sub    $0x8,%esp
f0103128:	57                   	push   %edi
f0103129:	6a 24                	push   $0x24
f010312b:	c7 c0 84 51 10 f0    	mov    $0xf0105184,%eax
f0103131:	e8 3c fe ff ff       	call   f0102f72 <stab_binsearch>

	if (lfun <= rfun) {
f0103136:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103139:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f010313c:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
f010313f:	83 c4 10             	add    $0x10,%esp
f0103142:	39 c8                	cmp    %ecx,%eax
f0103144:	0f 8f c1 00 00 00    	jg     f010320b <debuginfo_eip+0x1a9>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f010314a:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010314d:	c7 c1 84 51 10 f0    	mov    $0xf0105184,%ecx
f0103153:	8d 0c 91             	lea    (%ecx,%edx,4),%ecx
f0103156:	8b 11                	mov    (%ecx),%edx
f0103158:	89 55 c0             	mov    %edx,-0x40(%ebp)
f010315b:	c7 c2 a1 e3 10 f0    	mov    $0xf010e3a1,%edx
f0103161:	89 5d bc             	mov    %ebx,-0x44(%ebp)
f0103164:	81 ea 05 c5 10 f0    	sub    $0xf010c505,%edx
f010316a:	8b 5d c0             	mov    -0x40(%ebp),%ebx
f010316d:	39 d3                	cmp    %edx,%ebx
f010316f:	73 0c                	jae    f010317d <debuginfo_eip+0x11b>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0103171:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0103174:	81 c3 05 c5 10 f0    	add    $0xf010c505,%ebx
f010317a:	89 5e 08             	mov    %ebx,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f010317d:	8b 51 08             	mov    0x8(%ecx),%edx
f0103180:	89 56 10             	mov    %edx,0x10(%esi)
		addr -= info->eip_fn_addr;
f0103183:	29 d7                	sub    %edx,%edi
		// Search within the function definition for the line number.
		lline = lfun;
f0103185:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0103188:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f010318b:	89 45 d0             	mov    %eax,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f010318e:	83 ec 08             	sub    $0x8,%esp
f0103191:	6a 3a                	push   $0x3a
f0103193:	ff 76 08             	pushl  0x8(%esi)
f0103196:	8b 5d bc             	mov    -0x44(%ebp),%ebx
f0103199:	e8 c5 09 00 00       	call   f0103b63 <strfind>
f010319e:	2b 46 08             	sub    0x8(%esi),%eax
f01031a1:	89 46 0c             	mov    %eax,0xc(%esi)
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f01031a4:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f01031a7:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f01031aa:	83 c4 08             	add    $0x8,%esp
f01031ad:	57                   	push   %edi
f01031ae:	6a 44                	push   $0x44
f01031b0:	8b 7d bc             	mov    -0x44(%ebp),%edi
f01031b3:	c7 c0 84 51 10 f0    	mov    $0xf0105184,%eax
f01031b9:	e8 b4 fd ff ff       	call   f0102f72 <stab_binsearch>
	if (lline <= rline) {
f01031be:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01031c1:	83 c4 10             	add    $0x10,%esp
f01031c4:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f01031c7:	0f 8f 0c 01 00 00    	jg     f01032d9 <debuginfo_eip+0x277>
		 info->eip_line = stabs[lline].n_desc;
f01031cd:	89 d0                	mov    %edx,%eax
f01031cf:	8d 14 52             	lea    (%edx,%edx,2),%edx
f01031d2:	c1 e2 02             	shl    $0x2,%edx
f01031d5:	c7 c1 84 51 10 f0    	mov    $0xf0105184,%ecx
f01031db:	0f b7 5c 0a 06       	movzwl 0x6(%edx,%ecx,1),%ebx
f01031e0:	89 5e 04             	mov    %ebx,0x4(%esi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01031e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01031e6:	8d 54 0a 04          	lea    0x4(%edx,%ecx,1),%edx
f01031ea:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f01031ee:	eb 39                	jmp    f0103229 <debuginfo_eip+0x1c7>
  	        panic("User address");
f01031f0:	83 ec 04             	sub    $0x4,%esp
f01031f3:	8b 5d bc             	mov    -0x44(%ebp),%ebx
f01031f6:	8d 83 0d af fe ff    	lea    -0x150f3(%ebx),%eax
f01031fc:	50                   	push   %eax
f01031fd:	6a 7f                	push   $0x7f
f01031ff:	8d 83 1a af fe ff    	lea    -0x150e6(%ebx),%eax
f0103205:	50                   	push   %eax
f0103206:	e8 00 cf ff ff       	call   f010010b <_panic>
		info->eip_fn_addr = addr;
f010320b:	89 7e 10             	mov    %edi,0x10(%esi)
		lline = lfile;
f010320e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103211:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0103214:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103217:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010321a:	e9 6f ff ff ff       	jmp    f010318e <debuginfo_eip+0x12c>
f010321f:	83 e8 01             	sub    $0x1,%eax
f0103222:	83 ea 0c             	sub    $0xc,%edx
f0103225:	c6 45 c4 01          	movb   $0x1,-0x3c(%ebp)
f0103229:	89 45 c0             	mov    %eax,-0x40(%ebp)
	while (lline >= lfile
f010322c:	39 c7                	cmp    %eax,%edi
f010322e:	7f 51                	jg     f0103281 <debuginfo_eip+0x21f>
	       && stabs[lline].n_type != N_SOL
f0103230:	0f b6 0a             	movzbl (%edx),%ecx
f0103233:	80 f9 84             	cmp    $0x84,%cl
f0103236:	74 19                	je     f0103251 <debuginfo_eip+0x1ef>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0103238:	80 f9 64             	cmp    $0x64,%cl
f010323b:	75 e2                	jne    f010321f <debuginfo_eip+0x1bd>
f010323d:	83 7a 04 00          	cmpl   $0x0,0x4(%edx)
f0103241:	74 dc                	je     f010321f <debuginfo_eip+0x1bd>
f0103243:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0103247:	74 11                	je     f010325a <debuginfo_eip+0x1f8>
f0103249:	8b 7d c0             	mov    -0x40(%ebp),%edi
f010324c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f010324f:	eb 09                	jmp    f010325a <debuginfo_eip+0x1f8>
f0103251:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0103255:	74 03                	je     f010325a <debuginfo_eip+0x1f8>
f0103257:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f010325a:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010325d:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0103260:	c7 c0 84 51 10 f0    	mov    $0xf0105184,%eax
f0103266:	8b 14 90             	mov    (%eax,%edx,4),%edx
f0103269:	c7 c0 a1 e3 10 f0    	mov    $0xf010e3a1,%eax
f010326f:	81 e8 05 c5 10 f0    	sub    $0xf010c505,%eax
f0103275:	39 c2                	cmp    %eax,%edx
f0103277:	73 08                	jae    f0103281 <debuginfo_eip+0x21f>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0103279:	81 c2 05 c5 10 f0    	add    $0xf010c505,%edx
f010327f:	89 16                	mov    %edx,(%esi)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0103281:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103284:	8b 5d d8             	mov    -0x28(%ebp),%ebx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103287:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f010328c:	39 da                	cmp    %ebx,%edx
f010328e:	7d 55                	jge    f01032e5 <debuginfo_eip+0x283>
		for (lline = lfun + 1;
f0103290:	83 c2 01             	add    $0x1,%edx
f0103293:	89 d0                	mov    %edx,%eax
f0103295:	8d 0c 52             	lea    (%edx,%edx,2),%ecx
f0103298:	8b 7d bc             	mov    -0x44(%ebp),%edi
f010329b:	c7 c2 84 51 10 f0    	mov    $0xf0105184,%edx
f01032a1:	8d 54 8a 04          	lea    0x4(%edx,%ecx,4),%edx
f01032a5:	eb 04                	jmp    f01032ab <debuginfo_eip+0x249>
			info->eip_fn_narg++;
f01032a7:	83 46 14 01          	addl   $0x1,0x14(%esi)
		for (lline = lfun + 1;
f01032ab:	39 c3                	cmp    %eax,%ebx
f01032ad:	7e 31                	jle    f01032e0 <debuginfo_eip+0x27e>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01032af:	0f b6 0a             	movzbl (%edx),%ecx
f01032b2:	83 c0 01             	add    $0x1,%eax
f01032b5:	83 c2 0c             	add    $0xc,%edx
f01032b8:	80 f9 a0             	cmp    $0xa0,%cl
f01032bb:	74 ea                	je     f01032a7 <debuginfo_eip+0x245>
	return 0;
f01032bd:	b8 00 00 00 00       	mov    $0x0,%eax
f01032c2:	eb 21                	jmp    f01032e5 <debuginfo_eip+0x283>
		return -1;
f01032c4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01032c9:	eb 1a                	jmp    f01032e5 <debuginfo_eip+0x283>
f01032cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01032d0:	eb 13                	jmp    f01032e5 <debuginfo_eip+0x283>
		return -1;
f01032d2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01032d7:	eb 0c                	jmp    f01032e5 <debuginfo_eip+0x283>
		 return -1;
f01032d9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01032de:	eb 05                	jmp    f01032e5 <debuginfo_eip+0x283>
	return 0;
f01032e0:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01032e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01032e8:	5b                   	pop    %ebx
f01032e9:	5e                   	pop    %esi
f01032ea:	5f                   	pop    %edi
f01032eb:	5d                   	pop    %ebp
f01032ec:	c3                   	ret    

f01032ed <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f01032ed:	55                   	push   %ebp
f01032ee:	89 e5                	mov    %esp,%ebp
f01032f0:	57                   	push   %edi
f01032f1:	56                   	push   %esi
f01032f2:	53                   	push   %ebx
f01032f3:	83 ec 2c             	sub    $0x2c,%esp
f01032f6:	e8 d0 fb ff ff       	call   f0102ecb <__x86.get_pc_thunk.cx>
f01032fb:	81 c1 6d 6d 01 00    	add    $0x16d6d,%ecx
f0103301:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0103304:	89 c7                	mov    %eax,%edi
f0103306:	89 d6                	mov    %edx,%esi
f0103308:	8b 45 08             	mov    0x8(%ebp),%eax
f010330b:	8b 55 0c             	mov    0xc(%ebp),%edx
f010330e:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0103311:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0103314:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0103317:	bb 00 00 00 00       	mov    $0x0,%ebx
f010331c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f010331f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0103322:	3b 45 10             	cmp    0x10(%ebp),%eax
f0103325:	89 d0                	mov    %edx,%eax
f0103327:	1b 45 e4             	sbb    -0x1c(%ebp),%eax
f010332a:	8b 5d 14             	mov    0x14(%ebp),%ebx
f010332d:	73 15                	jae    f0103344 <printnum+0x57>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f010332f:	83 eb 01             	sub    $0x1,%ebx
f0103332:	85 db                	test   %ebx,%ebx
f0103334:	7e 46                	jle    f010337c <printnum+0x8f>
			putch(padc, putdat);
f0103336:	83 ec 08             	sub    $0x8,%esp
f0103339:	56                   	push   %esi
f010333a:	ff 75 18             	pushl  0x18(%ebp)
f010333d:	ff d7                	call   *%edi
f010333f:	83 c4 10             	add    $0x10,%esp
f0103342:	eb eb                	jmp    f010332f <printnum+0x42>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0103344:	83 ec 0c             	sub    $0xc,%esp
f0103347:	ff 75 18             	pushl  0x18(%ebp)
f010334a:	8b 45 14             	mov    0x14(%ebp),%eax
f010334d:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0103350:	53                   	push   %ebx
f0103351:	ff 75 10             	pushl  0x10(%ebp)
f0103354:	83 ec 08             	sub    $0x8,%esp
f0103357:	ff 75 e4             	pushl  -0x1c(%ebp)
f010335a:	ff 75 e0             	pushl  -0x20(%ebp)
f010335d:	ff 75 d4             	pushl  -0x2c(%ebp)
f0103360:	ff 75 d0             	pushl  -0x30(%ebp)
f0103363:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0103366:	e8 05 0a 00 00       	call   f0103d70 <__udivdi3>
f010336b:	83 c4 18             	add    $0x18,%esp
f010336e:	52                   	push   %edx
f010336f:	50                   	push   %eax
f0103370:	89 f2                	mov    %esi,%edx
f0103372:	89 f8                	mov    %edi,%eax
f0103374:	e8 74 ff ff ff       	call   f01032ed <printnum>
f0103379:	83 c4 20             	add    $0x20,%esp
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f010337c:	83 ec 08             	sub    $0x8,%esp
f010337f:	56                   	push   %esi
f0103380:	83 ec 04             	sub    $0x4,%esp
f0103383:	ff 75 e4             	pushl  -0x1c(%ebp)
f0103386:	ff 75 e0             	pushl  -0x20(%ebp)
f0103389:	ff 75 d4             	pushl  -0x2c(%ebp)
f010338c:	ff 75 d0             	pushl  -0x30(%ebp)
f010338f:	8b 75 dc             	mov    -0x24(%ebp),%esi
f0103392:	89 f3                	mov    %esi,%ebx
f0103394:	e8 e7 0a 00 00       	call   f0103e80 <__umoddi3>
f0103399:	83 c4 14             	add    $0x14,%esp
f010339c:	0f be 84 06 28 af fe 	movsbl -0x150d8(%esi,%eax,1),%eax
f01033a3:	ff 
f01033a4:	50                   	push   %eax
f01033a5:	ff d7                	call   *%edi
}
f01033a7:	83 c4 10             	add    $0x10,%esp
f01033aa:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01033ad:	5b                   	pop    %ebx
f01033ae:	5e                   	pop    %esi
f01033af:	5f                   	pop    %edi
f01033b0:	5d                   	pop    %ebp
f01033b1:	c3                   	ret    

f01033b2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f01033b2:	55                   	push   %ebp
f01033b3:	89 e5                	mov    %esp,%ebp
f01033b5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f01033b8:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f01033bc:	8b 10                	mov    (%eax),%edx
f01033be:	3b 50 04             	cmp    0x4(%eax),%edx
f01033c1:	73 0a                	jae    f01033cd <sprintputch+0x1b>
		*b->buf++ = ch;
f01033c3:	8d 4a 01             	lea    0x1(%edx),%ecx
f01033c6:	89 08                	mov    %ecx,(%eax)
f01033c8:	8b 45 08             	mov    0x8(%ebp),%eax
f01033cb:	88 02                	mov    %al,(%edx)
}
f01033cd:	5d                   	pop    %ebp
f01033ce:	c3                   	ret    

f01033cf <printfmt>:
{
f01033cf:	55                   	push   %ebp
f01033d0:	89 e5                	mov    %esp,%ebp
f01033d2:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f01033d5:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f01033d8:	50                   	push   %eax
f01033d9:	ff 75 10             	pushl  0x10(%ebp)
f01033dc:	ff 75 0c             	pushl  0xc(%ebp)
f01033df:	ff 75 08             	pushl  0x8(%ebp)
f01033e2:	e8 05 00 00 00       	call   f01033ec <vprintfmt>
}
f01033e7:	83 c4 10             	add    $0x10,%esp
f01033ea:	c9                   	leave  
f01033eb:	c3                   	ret    

f01033ec <vprintfmt>:
{
f01033ec:	55                   	push   %ebp
f01033ed:	89 e5                	mov    %esp,%ebp
f01033ef:	57                   	push   %edi
f01033f0:	56                   	push   %esi
f01033f1:	53                   	push   %ebx
f01033f2:	83 ec 3c             	sub    $0x3c,%esp
f01033f5:	e8 38 d3 ff ff       	call   f0100732 <__x86.get_pc_thunk.ax>
f01033fa:	05 6e 6c 01 00       	add    $0x16c6e,%eax
f01033ff:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103402:	8b 75 08             	mov    0x8(%ebp),%esi
f0103405:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0103408:	8b 5d 10             	mov    0x10(%ebp),%ebx
f010340b:	eb 0a                	jmp    f0103417 <vprintfmt+0x2b>
			putch(ch, putdat);
f010340d:	83 ec 08             	sub    $0x8,%esp
f0103410:	57                   	push   %edi
f0103411:	50                   	push   %eax
f0103412:	ff d6                	call   *%esi
f0103414:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0103417:	83 c3 01             	add    $0x1,%ebx
f010341a:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
f010341e:	83 f8 25             	cmp    $0x25,%eax
f0103421:	74 0c                	je     f010342f <vprintfmt+0x43>
			if (ch == '\0')
f0103423:	85 c0                	test   %eax,%eax
f0103425:	75 e6                	jne    f010340d <vprintfmt+0x21>
}
f0103427:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010342a:	5b                   	pop    %ebx
f010342b:	5e                   	pop    %esi
f010342c:	5f                   	pop    %edi
f010342d:	5d                   	pop    %ebp
f010342e:	c3                   	ret    
		padc = ' ';
f010342f:	c6 45 cf 20          	movb   $0x20,-0x31(%ebp)
		altflag = 0;
f0103433:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
		precision = -1;//精度
f010343a:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;//总宽度
f0103441:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		lflag = 0;
f0103448:	b9 00 00 00 00       	mov    $0x0,%ecx
f010344d:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0103450:	89 75 08             	mov    %esi,0x8(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0103453:	8d 43 01             	lea    0x1(%ebx),%eax
f0103456:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103459:	0f b6 13             	movzbl (%ebx),%edx
f010345c:	8d 42 dd             	lea    -0x23(%edx),%eax
f010345f:	3c 55                	cmp    $0x55,%al
f0103461:	0f 87 00 04 00 00    	ja     f0103867 <.L21>
f0103467:	0f b6 c0             	movzbl %al,%eax
f010346a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f010346d:	89 ce                	mov    %ecx,%esi
f010346f:	03 b4 81 b4 af fe ff 	add    -0x1504c(%ecx,%eax,4),%esi
f0103476:	ff e6                	jmp    *%esi

f0103478 <.L68>:
f0103478:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
f010347b:	c6 45 cf 2d          	movb   $0x2d,-0x31(%ebp)
f010347f:	eb d2                	jmp    f0103453 <vprintfmt+0x67>

f0103481 <.L33>:
		switch (ch = *(unsigned char *) fmt++) {
f0103481:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '0';
f0103484:	c6 45 cf 30          	movb   $0x30,-0x31(%ebp)
f0103488:	eb c9                	jmp    f0103453 <vprintfmt+0x67>

f010348a <.L32>:
		switch (ch = *(unsigned char *) fmt++) {
f010348a:	0f b6 d2             	movzbl %dl,%edx
f010348d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {//依次读取数据宽度
f0103490:	b8 00 00 00 00       	mov    $0x0,%eax
f0103495:	8b 75 08             	mov    0x8(%ebp),%esi
				precision = precision * 10 + ch - '0';
f0103498:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010349b:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f010349f:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
f01034a2:	8d 4a d0             	lea    -0x30(%edx),%ecx
f01034a5:	83 f9 09             	cmp    $0x9,%ecx
f01034a8:	77 58                	ja     f0103502 <.L37+0xf>
			for (precision = 0; ; ++fmt) {//依次读取数据宽度
f01034aa:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
f01034ad:	eb e9                	jmp    f0103498 <.L32+0xe>

f01034af <.L35>:
			precision = va_arg(ap, int);
f01034af:	8b 45 14             	mov    0x14(%ebp),%eax
f01034b2:	8b 00                	mov    (%eax),%eax
f01034b4:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01034b7:	8b 45 14             	mov    0x14(%ebp),%eax
f01034ba:	8d 40 04             	lea    0x4(%eax),%eax
f01034bd:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01034c0:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
f01034c3:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f01034c7:	79 8a                	jns    f0103453 <vprintfmt+0x67>
				width = precision, precision = -1;
f01034c9:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01034cc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01034cf:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
f01034d6:	e9 78 ff ff ff       	jmp    f0103453 <vprintfmt+0x67>

f01034db <.L34>:
f01034db:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01034de:	85 c0                	test   %eax,%eax
f01034e0:	ba 00 00 00 00       	mov    $0x0,%edx
f01034e5:	0f 49 d0             	cmovns %eax,%edx
f01034e8:	89 55 d4             	mov    %edx,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01034eb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01034ee:	e9 60 ff ff ff       	jmp    f0103453 <vprintfmt+0x67>

f01034f3 <.L37>:
f01034f3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
f01034f6:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
f01034fd:	e9 51 ff ff ff       	jmp    f0103453 <vprintfmt+0x67>
f0103502:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103505:	89 75 08             	mov    %esi,0x8(%ebp)
f0103508:	eb b9                	jmp    f01034c3 <.L35+0x14>

f010350a <.L28>:
			lflag++;
f010350a:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f010350e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
f0103511:	e9 3d ff ff ff       	jmp    f0103453 <vprintfmt+0x67>

f0103516 <.L31>:
f0103516:	8b 75 08             	mov    0x8(%ebp),%esi
			putch(va_arg(ap, int), putdat);
f0103519:	8b 45 14             	mov    0x14(%ebp),%eax
f010351c:	8d 58 04             	lea    0x4(%eax),%ebx
f010351f:	83 ec 08             	sub    $0x8,%esp
f0103522:	57                   	push   %edi
f0103523:	ff 30                	pushl  (%eax)
f0103525:	ff d6                	call   *%esi
			break;
f0103527:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f010352a:	89 5d 14             	mov    %ebx,0x14(%ebp)
			break;
f010352d:	e9 cb 02 00 00       	jmp    f01037fd <.L26+0x45>

f0103532 <.L29>:
f0103532:	8b 75 08             	mov    0x8(%ebp),%esi
			err = va_arg(ap, int);
f0103535:	8b 45 14             	mov    0x14(%ebp),%eax
f0103538:	8d 58 04             	lea    0x4(%eax),%ebx
f010353b:	8b 00                	mov    (%eax),%eax
f010353d:	99                   	cltd   
f010353e:	31 d0                	xor    %edx,%eax
f0103540:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0103542:	83 f8 06             	cmp    $0x6,%eax
f0103545:	7f 2b                	jg     f0103572 <.L29+0x40>
f0103547:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010354a:	8b 94 82 dc ff ff ff 	mov    -0x24(%edx,%eax,4),%edx
f0103551:	85 d2                	test   %edx,%edx
f0103553:	74 1d                	je     f0103572 <.L29+0x40>
				printfmt(putch, putdat, "%s", p);
f0103555:	52                   	push   %edx
f0103556:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103559:	8d 80 58 ac fe ff    	lea    -0x153a8(%eax),%eax
f010355f:	50                   	push   %eax
f0103560:	57                   	push   %edi
f0103561:	56                   	push   %esi
f0103562:	e8 68 fe ff ff       	call   f01033cf <printfmt>
f0103567:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f010356a:	89 5d 14             	mov    %ebx,0x14(%ebp)
f010356d:	e9 8b 02 00 00       	jmp    f01037fd <.L26+0x45>
				printfmt(putch, putdat, "error %d", err);
f0103572:	50                   	push   %eax
f0103573:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103576:	8d 80 40 af fe ff    	lea    -0x150c0(%eax),%eax
f010357c:	50                   	push   %eax
f010357d:	57                   	push   %edi
f010357e:	56                   	push   %esi
f010357f:	e8 4b fe ff ff       	call   f01033cf <printfmt>
f0103584:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0103587:	89 5d 14             	mov    %ebx,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f010358a:	e9 6e 02 00 00       	jmp    f01037fd <.L26+0x45>

f010358f <.L25>:
f010358f:	8b 75 08             	mov    0x8(%ebp),%esi
			if ((p = va_arg(ap, char *)) == NULL)
f0103592:	8b 45 14             	mov    0x14(%ebp),%eax
f0103595:	83 c0 04             	add    $0x4,%eax
f0103598:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f010359b:	8b 45 14             	mov    0x14(%ebp),%eax
f010359e:	8b 10                	mov    (%eax),%edx
				p = "(null)";
f01035a0:	85 d2                	test   %edx,%edx
f01035a2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01035a5:	8d 80 39 af fe ff    	lea    -0x150c7(%eax),%eax
f01035ab:	0f 45 c2             	cmovne %edx,%eax
f01035ae:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
f01035b1:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f01035b5:	7e 06                	jle    f01035bd <.L25+0x2e>
f01035b7:	80 7d cf 2d          	cmpb   $0x2d,-0x31(%ebp)
f01035bb:	75 0d                	jne    f01035ca <.L25+0x3b>
				for (width -= strnlen(p, precision); width > 0; width--)
f01035bd:	8b 45 c8             	mov    -0x38(%ebp),%eax
f01035c0:	89 c3                	mov    %eax,%ebx
f01035c2:	03 45 d4             	add    -0x2c(%ebp),%eax
f01035c5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01035c8:	eb 42                	jmp    f010360c <.L25+0x7d>
f01035ca:	83 ec 08             	sub    $0x8,%esp
f01035cd:	ff 75 d8             	pushl  -0x28(%ebp)
f01035d0:	50                   	push   %eax
f01035d1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01035d4:	e8 3f 04 00 00       	call   f0103a18 <strnlen>
f01035d9:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01035dc:	29 c2                	sub    %eax,%edx
f01035de:	89 55 c0             	mov    %edx,-0x40(%ebp)
f01035e1:	83 c4 10             	add    $0x10,%esp
f01035e4:	89 d3                	mov    %edx,%ebx
					putch(padc, putdat);
f01035e6:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
f01035ea:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f01035ed:	85 db                	test   %ebx,%ebx
f01035ef:	7e 58                	jle    f0103649 <.L25+0xba>
					putch(padc, putdat);
f01035f1:	83 ec 08             	sub    $0x8,%esp
f01035f4:	57                   	push   %edi
f01035f5:	ff 75 d4             	pushl  -0x2c(%ebp)
f01035f8:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f01035fa:	83 eb 01             	sub    $0x1,%ebx
f01035fd:	83 c4 10             	add    $0x10,%esp
f0103600:	eb eb                	jmp    f01035ed <.L25+0x5e>
					putch(ch, putdat);
f0103602:	83 ec 08             	sub    $0x8,%esp
f0103605:	57                   	push   %edi
f0103606:	52                   	push   %edx
f0103607:	ff d6                	call   *%esi
f0103609:	83 c4 10             	add    $0x10,%esp
f010360c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f010360f:	29 d9                	sub    %ebx,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0103611:	83 c3 01             	add    $0x1,%ebx
f0103614:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
f0103618:	0f be d0             	movsbl %al,%edx
f010361b:	85 d2                	test   %edx,%edx
f010361d:	74 45                	je     f0103664 <.L25+0xd5>
f010361f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0103623:	78 06                	js     f010362b <.L25+0x9c>
f0103625:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
f0103629:	78 35                	js     f0103660 <.L25+0xd1>
				if (altflag && (ch < ' ' || ch > '~'))
f010362b:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f010362f:	74 d1                	je     f0103602 <.L25+0x73>
f0103631:	0f be c0             	movsbl %al,%eax
f0103634:	83 e8 20             	sub    $0x20,%eax
f0103637:	83 f8 5e             	cmp    $0x5e,%eax
f010363a:	76 c6                	jbe    f0103602 <.L25+0x73>
					putch('?', putdat);
f010363c:	83 ec 08             	sub    $0x8,%esp
f010363f:	57                   	push   %edi
f0103640:	6a 3f                	push   $0x3f
f0103642:	ff d6                	call   *%esi
f0103644:	83 c4 10             	add    $0x10,%esp
f0103647:	eb c3                	jmp    f010360c <.L25+0x7d>
f0103649:	8b 55 c0             	mov    -0x40(%ebp),%edx
f010364c:	85 d2                	test   %edx,%edx
f010364e:	b8 00 00 00 00       	mov    $0x0,%eax
f0103653:	0f 49 c2             	cmovns %edx,%eax
f0103656:	29 c2                	sub    %eax,%edx
f0103658:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f010365b:	e9 5d ff ff ff       	jmp    f01035bd <.L25+0x2e>
f0103660:	89 cb                	mov    %ecx,%ebx
f0103662:	eb 02                	jmp    f0103666 <.L25+0xd7>
f0103664:	89 cb                	mov    %ecx,%ebx
			for (; width > 0; width--)
f0103666:	85 db                	test   %ebx,%ebx
f0103668:	7e 10                	jle    f010367a <.L25+0xeb>
				putch(' ', putdat);
f010366a:	83 ec 08             	sub    $0x8,%esp
f010366d:	57                   	push   %edi
f010366e:	6a 20                	push   $0x20
f0103670:	ff d6                	call   *%esi
			for (; width > 0; width--)
f0103672:	83 eb 01             	sub    $0x1,%ebx
f0103675:	83 c4 10             	add    $0x10,%esp
f0103678:	eb ec                	jmp    f0103666 <.L25+0xd7>
			if ((p = va_arg(ap, char *)) == NULL)
f010367a:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f010367d:	89 45 14             	mov    %eax,0x14(%ebp)
f0103680:	e9 78 01 00 00       	jmp    f01037fd <.L26+0x45>

f0103685 <.L30>:
f0103685:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0103688:	8b 75 08             	mov    0x8(%ebp),%esi
	if (lflag >= 2)
f010368b:	83 f9 01             	cmp    $0x1,%ecx
f010368e:	7f 1b                	jg     f01036ab <.L30+0x26>
	else if (lflag)
f0103690:	85 c9                	test   %ecx,%ecx
f0103692:	74 63                	je     f01036f7 <.L30+0x72>
		return va_arg(*ap, long);
f0103694:	8b 45 14             	mov    0x14(%ebp),%eax
f0103697:	8b 00                	mov    (%eax),%eax
f0103699:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010369c:	99                   	cltd   
f010369d:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01036a0:	8b 45 14             	mov    0x14(%ebp),%eax
f01036a3:	8d 40 04             	lea    0x4(%eax),%eax
f01036a6:	89 45 14             	mov    %eax,0x14(%ebp)
f01036a9:	eb 17                	jmp    f01036c2 <.L30+0x3d>
		return va_arg(*ap, long long);
f01036ab:	8b 45 14             	mov    0x14(%ebp),%eax
f01036ae:	8b 50 04             	mov    0x4(%eax),%edx
f01036b1:	8b 00                	mov    (%eax),%eax
f01036b3:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01036b6:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01036b9:	8b 45 14             	mov    0x14(%ebp),%eax
f01036bc:	8d 40 08             	lea    0x8(%eax),%eax
f01036bf:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f01036c2:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01036c5:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f01036c8:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
f01036cd:	85 c9                	test   %ecx,%ecx
f01036cf:	0f 89 0e 01 00 00    	jns    f01037e3 <.L26+0x2b>
				putch('-', putdat);
f01036d5:	83 ec 08             	sub    $0x8,%esp
f01036d8:	57                   	push   %edi
f01036d9:	6a 2d                	push   $0x2d
f01036db:	ff d6                	call   *%esi
				num = -(long long) num;
f01036dd:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01036e0:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f01036e3:	f7 da                	neg    %edx
f01036e5:	83 d1 00             	adc    $0x0,%ecx
f01036e8:	f7 d9                	neg    %ecx
f01036ea:	83 c4 10             	add    $0x10,%esp
			base = 10;
f01036ed:	b8 0a 00 00 00       	mov    $0xa,%eax
f01036f2:	e9 ec 00 00 00       	jmp    f01037e3 <.L26+0x2b>
		return va_arg(*ap, int);
f01036f7:	8b 45 14             	mov    0x14(%ebp),%eax
f01036fa:	8b 00                	mov    (%eax),%eax
f01036fc:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01036ff:	99                   	cltd   
f0103700:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0103703:	8b 45 14             	mov    0x14(%ebp),%eax
f0103706:	8d 40 04             	lea    0x4(%eax),%eax
f0103709:	89 45 14             	mov    %eax,0x14(%ebp)
f010370c:	eb b4                	jmp    f01036c2 <.L30+0x3d>

f010370e <.L24>:
f010370e:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0103711:	8b 75 08             	mov    0x8(%ebp),%esi
	if (lflag >= 2)
f0103714:	83 f9 01             	cmp    $0x1,%ecx
f0103717:	7f 1e                	jg     f0103737 <.L24+0x29>
	else if (lflag)
f0103719:	85 c9                	test   %ecx,%ecx
f010371b:	74 32                	je     f010374f <.L24+0x41>
		return va_arg(*ap, unsigned long);
f010371d:	8b 45 14             	mov    0x14(%ebp),%eax
f0103720:	8b 10                	mov    (%eax),%edx
f0103722:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103727:	8d 40 04             	lea    0x4(%eax),%eax
f010372a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f010372d:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103732:	e9 ac 00 00 00       	jmp    f01037e3 <.L26+0x2b>
		return va_arg(*ap, unsigned long long);
f0103737:	8b 45 14             	mov    0x14(%ebp),%eax
f010373a:	8b 10                	mov    (%eax),%edx
f010373c:	8b 48 04             	mov    0x4(%eax),%ecx
f010373f:	8d 40 08             	lea    0x8(%eax),%eax
f0103742:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0103745:	b8 0a 00 00 00       	mov    $0xa,%eax
f010374a:	e9 94 00 00 00       	jmp    f01037e3 <.L26+0x2b>
		return va_arg(*ap, unsigned int);
f010374f:	8b 45 14             	mov    0x14(%ebp),%eax
f0103752:	8b 10                	mov    (%eax),%edx
f0103754:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103759:	8d 40 04             	lea    0x4(%eax),%eax
f010375c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f010375f:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103764:	eb 7d                	jmp    f01037e3 <.L26+0x2b>

f0103766 <.L27>:
f0103766:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0103769:	8b 75 08             	mov    0x8(%ebp),%esi
	if (lflag >= 2)
f010376c:	83 f9 01             	cmp    $0x1,%ecx
f010376f:	7f 1b                	jg     f010378c <.L27+0x26>
	else if (lflag)
f0103771:	85 c9                	test   %ecx,%ecx
f0103773:	74 2c                	je     f01037a1 <.L27+0x3b>
		return va_arg(*ap, unsigned long);
f0103775:	8b 45 14             	mov    0x14(%ebp),%eax
f0103778:	8b 10                	mov    (%eax),%edx
f010377a:	b9 00 00 00 00       	mov    $0x0,%ecx
f010377f:	8d 40 04             	lea    0x4(%eax),%eax
f0103782:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0103785:	b8 08 00 00 00       	mov    $0x8,%eax
f010378a:	eb 57                	jmp    f01037e3 <.L26+0x2b>
		return va_arg(*ap, unsigned long long);
f010378c:	8b 45 14             	mov    0x14(%ebp),%eax
f010378f:	8b 10                	mov    (%eax),%edx
f0103791:	8b 48 04             	mov    0x4(%eax),%ecx
f0103794:	8d 40 08             	lea    0x8(%eax),%eax
f0103797:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f010379a:	b8 08 00 00 00       	mov    $0x8,%eax
f010379f:	eb 42                	jmp    f01037e3 <.L26+0x2b>
		return va_arg(*ap, unsigned int);
f01037a1:	8b 45 14             	mov    0x14(%ebp),%eax
f01037a4:	8b 10                	mov    (%eax),%edx
f01037a6:	b9 00 00 00 00       	mov    $0x0,%ecx
f01037ab:	8d 40 04             	lea    0x4(%eax),%eax
f01037ae:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f01037b1:	b8 08 00 00 00       	mov    $0x8,%eax
f01037b6:	eb 2b                	jmp    f01037e3 <.L26+0x2b>

f01037b8 <.L26>:
f01037b8:	8b 75 08             	mov    0x8(%ebp),%esi
			putch('0', putdat);
f01037bb:	83 ec 08             	sub    $0x8,%esp
f01037be:	57                   	push   %edi
f01037bf:	6a 30                	push   $0x30
f01037c1:	ff d6                	call   *%esi
			putch('x', putdat);
f01037c3:	83 c4 08             	add    $0x8,%esp
f01037c6:	57                   	push   %edi
f01037c7:	6a 78                	push   $0x78
f01037c9:	ff d6                	call   *%esi
			num = (unsigned long long)
f01037cb:	8b 45 14             	mov    0x14(%ebp),%eax
f01037ce:	8b 10                	mov    (%eax),%edx
f01037d0:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f01037d5:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f01037d8:	8d 40 04             	lea    0x4(%eax),%eax
f01037db:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01037de:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
f01037e3:	83 ec 0c             	sub    $0xc,%esp
f01037e6:	0f be 5d cf          	movsbl -0x31(%ebp),%ebx
f01037ea:	53                   	push   %ebx
f01037eb:	ff 75 d4             	pushl  -0x2c(%ebp)
f01037ee:	50                   	push   %eax
f01037ef:	51                   	push   %ecx
f01037f0:	52                   	push   %edx
f01037f1:	89 fa                	mov    %edi,%edx
f01037f3:	89 f0                	mov    %esi,%eax
f01037f5:	e8 f3 fa ff ff       	call   f01032ed <printnum>
			break;
f01037fa:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
f01037fd:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0103800:	e9 12 fc ff ff       	jmp    f0103417 <vprintfmt+0x2b>

f0103805 <.L22>:
f0103805:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0103808:	8b 75 08             	mov    0x8(%ebp),%esi
	if (lflag >= 2)
f010380b:	83 f9 01             	cmp    $0x1,%ecx
f010380e:	7f 1b                	jg     f010382b <.L22+0x26>
	else if (lflag)
f0103810:	85 c9                	test   %ecx,%ecx
f0103812:	74 2c                	je     f0103840 <.L22+0x3b>
		return va_arg(*ap, unsigned long);
f0103814:	8b 45 14             	mov    0x14(%ebp),%eax
f0103817:	8b 10                	mov    (%eax),%edx
f0103819:	b9 00 00 00 00       	mov    $0x0,%ecx
f010381e:	8d 40 04             	lea    0x4(%eax),%eax
f0103821:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0103824:	b8 10 00 00 00       	mov    $0x10,%eax
f0103829:	eb b8                	jmp    f01037e3 <.L26+0x2b>
		return va_arg(*ap, unsigned long long);
f010382b:	8b 45 14             	mov    0x14(%ebp),%eax
f010382e:	8b 10                	mov    (%eax),%edx
f0103830:	8b 48 04             	mov    0x4(%eax),%ecx
f0103833:	8d 40 08             	lea    0x8(%eax),%eax
f0103836:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0103839:	b8 10 00 00 00       	mov    $0x10,%eax
f010383e:	eb a3                	jmp    f01037e3 <.L26+0x2b>
		return va_arg(*ap, unsigned int);
f0103840:	8b 45 14             	mov    0x14(%ebp),%eax
f0103843:	8b 10                	mov    (%eax),%edx
f0103845:	b9 00 00 00 00       	mov    $0x0,%ecx
f010384a:	8d 40 04             	lea    0x4(%eax),%eax
f010384d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0103850:	b8 10 00 00 00       	mov    $0x10,%eax
f0103855:	eb 8c                	jmp    f01037e3 <.L26+0x2b>

f0103857 <.L36>:
f0103857:	8b 75 08             	mov    0x8(%ebp),%esi
			putch(ch, putdat);
f010385a:	83 ec 08             	sub    $0x8,%esp
f010385d:	57                   	push   %edi
f010385e:	6a 25                	push   $0x25
f0103860:	ff d6                	call   *%esi
			break;
f0103862:	83 c4 10             	add    $0x10,%esp
f0103865:	eb 96                	jmp    f01037fd <.L26+0x45>

f0103867 <.L21>:
f0103867:	8b 75 08             	mov    0x8(%ebp),%esi
			putch('%', putdat);
f010386a:	83 ec 08             	sub    $0x8,%esp
f010386d:	57                   	push   %edi
f010386e:	6a 25                	push   $0x25
f0103870:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0103872:	83 c4 10             	add    $0x10,%esp
f0103875:	89 d8                	mov    %ebx,%eax
f0103877:	eb 03                	jmp    f010387c <.L21+0x15>
f0103879:	83 e8 01             	sub    $0x1,%eax
f010387c:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f0103880:	75 f7                	jne    f0103879 <.L21+0x12>
f0103882:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103885:	e9 73 ff ff ff       	jmp    f01037fd <.L26+0x45>

f010388a <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010388a:	55                   	push   %ebp
f010388b:	89 e5                	mov    %esp,%ebp
f010388d:	53                   	push   %ebx
f010388e:	83 ec 14             	sub    $0x14,%esp
f0103891:	e8 2b c9 ff ff       	call   f01001c1 <__x86.get_pc_thunk.bx>
f0103896:	81 c3 d2 67 01 00    	add    $0x167d2,%ebx
f010389c:	8b 45 08             	mov    0x8(%ebp),%eax
f010389f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01038a2:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01038a5:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01038a9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01038ac:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01038b3:	85 c0                	test   %eax,%eax
f01038b5:	74 2b                	je     f01038e2 <vsnprintf+0x58>
f01038b7:	85 d2                	test   %edx,%edx
f01038b9:	7e 27                	jle    f01038e2 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01038bb:	ff 75 14             	pushl  0x14(%ebp)
f01038be:	ff 75 10             	pushl  0x10(%ebp)
f01038c1:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01038c4:	50                   	push   %eax
f01038c5:	8d 83 4a 93 fe ff    	lea    -0x16cb6(%ebx),%eax
f01038cb:	50                   	push   %eax
f01038cc:	e8 1b fb ff ff       	call   f01033ec <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01038d1:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01038d4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01038d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01038da:	83 c4 10             	add    $0x10,%esp
}
f01038dd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01038e0:	c9                   	leave  
f01038e1:	c3                   	ret    
		return -E_INVAL;
f01038e2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01038e7:	eb f4                	jmp    f01038dd <vsnprintf+0x53>

f01038e9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01038e9:	55                   	push   %ebp
f01038ea:	89 e5                	mov    %esp,%ebp
f01038ec:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01038ef:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01038f2:	50                   	push   %eax
f01038f3:	ff 75 10             	pushl  0x10(%ebp)
f01038f6:	ff 75 0c             	pushl  0xc(%ebp)
f01038f9:	ff 75 08             	pushl  0x8(%ebp)
f01038fc:	e8 89 ff ff ff       	call   f010388a <vsnprintf>
	va_end(ap);

	return rc;
}
f0103901:	c9                   	leave  
f0103902:	c3                   	ret    

f0103903 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0103903:	55                   	push   %ebp
f0103904:	89 e5                	mov    %esp,%ebp
f0103906:	57                   	push   %edi
f0103907:	56                   	push   %esi
f0103908:	53                   	push   %ebx
f0103909:	83 ec 1c             	sub    $0x1c,%esp
f010390c:	e8 b0 c8 ff ff       	call   f01001c1 <__x86.get_pc_thunk.bx>
f0103911:	81 c3 57 67 01 00    	add    $0x16757,%ebx
f0103917:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f010391a:	85 c0                	test   %eax,%eax
f010391c:	74 13                	je     f0103931 <readline+0x2e>
		cprintf("%s", prompt);
f010391e:	83 ec 08             	sub    $0x8,%esp
f0103921:	50                   	push   %eax
f0103922:	8d 83 58 ac fe ff    	lea    -0x153a8(%ebx),%eax
f0103928:	50                   	push   %eax
f0103929:	e8 30 f6 ff ff       	call   f0102f5e <cprintf>
f010392e:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0103931:	83 ec 0c             	sub    $0xc,%esp
f0103934:	6a 00                	push   $0x0
f0103936:	e8 f1 cd ff ff       	call   f010072c <iscons>
f010393b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010393e:	83 c4 10             	add    $0x10,%esp
	i = 0;
f0103941:	bf 00 00 00 00       	mov    $0x0,%edi
f0103946:	eb 52                	jmp    f010399a <readline+0x97>
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
f0103948:	83 ec 08             	sub    $0x8,%esp
f010394b:	50                   	push   %eax
f010394c:	8d 83 0c b1 fe ff    	lea    -0x14ef4(%ebx),%eax
f0103952:	50                   	push   %eax
f0103953:	e8 06 f6 ff ff       	call   f0102f5e <cprintf>
			return NULL;
f0103958:	83 c4 10             	add    $0x10,%esp
f010395b:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f0103960:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103963:	5b                   	pop    %ebx
f0103964:	5e                   	pop    %esi
f0103965:	5f                   	pop    %edi
f0103966:	5d                   	pop    %ebp
f0103967:	c3                   	ret    
			if (echoing)
f0103968:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010396c:	75 05                	jne    f0103973 <readline+0x70>
			i--;
f010396e:	83 ef 01             	sub    $0x1,%edi
f0103971:	eb 27                	jmp    f010399a <readline+0x97>
				cputchar('\b');
f0103973:	83 ec 0c             	sub    $0xc,%esp
f0103976:	6a 08                	push   $0x8
f0103978:	e8 8e cd ff ff       	call   f010070b <cputchar>
f010397d:	83 c4 10             	add    $0x10,%esp
f0103980:	eb ec                	jmp    f010396e <readline+0x6b>
				cputchar(c);
f0103982:	83 ec 0c             	sub    $0xc,%esp
f0103985:	56                   	push   %esi
f0103986:	e8 80 cd ff ff       	call   f010070b <cputchar>
f010398b:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f010398e:	89 f0                	mov    %esi,%eax
f0103990:	88 84 3b 78 02 00 00 	mov    %al,0x278(%ebx,%edi,1)
f0103997:	8d 7f 01             	lea    0x1(%edi),%edi
		c = getchar();
f010399a:	e8 7c cd ff ff       	call   f010071b <getchar>
f010399f:	89 c6                	mov    %eax,%esi
		if (c < 0) {
f01039a1:	85 c0                	test   %eax,%eax
f01039a3:	78 a3                	js     f0103948 <readline+0x45>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01039a5:	83 f8 08             	cmp    $0x8,%eax
f01039a8:	0f 94 c2             	sete   %dl
f01039ab:	83 f8 7f             	cmp    $0x7f,%eax
f01039ae:	0f 94 c0             	sete   %al
f01039b1:	08 c2                	or     %al,%dl
f01039b3:	74 04                	je     f01039b9 <readline+0xb6>
f01039b5:	85 ff                	test   %edi,%edi
f01039b7:	7f af                	jg     f0103968 <readline+0x65>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01039b9:	83 fe 1f             	cmp    $0x1f,%esi
f01039bc:	7e 10                	jle    f01039ce <readline+0xcb>
f01039be:	81 ff fe 03 00 00    	cmp    $0x3fe,%edi
f01039c4:	7f 08                	jg     f01039ce <readline+0xcb>
			if (echoing)
f01039c6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01039ca:	74 c2                	je     f010398e <readline+0x8b>
f01039cc:	eb b4                	jmp    f0103982 <readline+0x7f>
		} else if (c == '\n' || c == '\r') {
f01039ce:	83 fe 0a             	cmp    $0xa,%esi
f01039d1:	74 05                	je     f01039d8 <readline+0xd5>
f01039d3:	83 fe 0d             	cmp    $0xd,%esi
f01039d6:	75 c2                	jne    f010399a <readline+0x97>
			if (echoing)
f01039d8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01039dc:	75 13                	jne    f01039f1 <readline+0xee>
			buf[i] = 0;
f01039de:	c6 84 3b 78 02 00 00 	movb   $0x0,0x278(%ebx,%edi,1)
f01039e5:	00 
			return buf;
f01039e6:	8d 83 78 02 00 00    	lea    0x278(%ebx),%eax
f01039ec:	e9 6f ff ff ff       	jmp    f0103960 <readline+0x5d>
				cputchar('\n');
f01039f1:	83 ec 0c             	sub    $0xc,%esp
f01039f4:	6a 0a                	push   $0xa
f01039f6:	e8 10 cd ff ff       	call   f010070b <cputchar>
f01039fb:	83 c4 10             	add    $0x10,%esp
f01039fe:	eb de                	jmp    f01039de <readline+0xdb>

f0103a00 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0103a00:	55                   	push   %ebp
f0103a01:	89 e5                	mov    %esp,%ebp
f0103a03:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0103a06:	b8 00 00 00 00       	mov    $0x0,%eax
f0103a0b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0103a0f:	74 05                	je     f0103a16 <strlen+0x16>
		n++;
f0103a11:	83 c0 01             	add    $0x1,%eax
f0103a14:	eb f5                	jmp    f0103a0b <strlen+0xb>
	return n;
}
f0103a16:	5d                   	pop    %ebp
f0103a17:	c3                   	ret    

f0103a18 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0103a18:	55                   	push   %ebp
f0103a19:	89 e5                	mov    %esp,%ebp
f0103a1b:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103a1e:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0103a21:	ba 00 00 00 00       	mov    $0x0,%edx
f0103a26:	39 c2                	cmp    %eax,%edx
f0103a28:	74 0d                	je     f0103a37 <strnlen+0x1f>
f0103a2a:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f0103a2e:	74 05                	je     f0103a35 <strnlen+0x1d>
		n++;
f0103a30:	83 c2 01             	add    $0x1,%edx
f0103a33:	eb f1                	jmp    f0103a26 <strnlen+0xe>
f0103a35:	89 d0                	mov    %edx,%eax
	return n;
}
f0103a37:	5d                   	pop    %ebp
f0103a38:	c3                   	ret    

f0103a39 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0103a39:	55                   	push   %ebp
f0103a3a:	89 e5                	mov    %esp,%ebp
f0103a3c:	53                   	push   %ebx
f0103a3d:	8b 45 08             	mov    0x8(%ebp),%eax
f0103a40:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0103a43:	ba 00 00 00 00       	mov    $0x0,%edx
f0103a48:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f0103a4c:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0103a4f:	83 c2 01             	add    $0x1,%edx
f0103a52:	84 c9                	test   %cl,%cl
f0103a54:	75 f2                	jne    f0103a48 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0103a56:	5b                   	pop    %ebx
f0103a57:	5d                   	pop    %ebp
f0103a58:	c3                   	ret    

f0103a59 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0103a59:	55                   	push   %ebp
f0103a5a:	89 e5                	mov    %esp,%ebp
f0103a5c:	53                   	push   %ebx
f0103a5d:	83 ec 10             	sub    $0x10,%esp
f0103a60:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0103a63:	53                   	push   %ebx
f0103a64:	e8 97 ff ff ff       	call   f0103a00 <strlen>
f0103a69:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
f0103a6c:	ff 75 0c             	pushl  0xc(%ebp)
f0103a6f:	01 d8                	add    %ebx,%eax
f0103a71:	50                   	push   %eax
f0103a72:	e8 c2 ff ff ff       	call   f0103a39 <strcpy>
	return dst;
}
f0103a77:	89 d8                	mov    %ebx,%eax
f0103a79:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103a7c:	c9                   	leave  
f0103a7d:	c3                   	ret    

f0103a7e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0103a7e:	55                   	push   %ebp
f0103a7f:	89 e5                	mov    %esp,%ebp
f0103a81:	56                   	push   %esi
f0103a82:	53                   	push   %ebx
f0103a83:	8b 45 08             	mov    0x8(%ebp),%eax
f0103a86:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103a89:	89 c6                	mov    %eax,%esi
f0103a8b:	03 75 10             	add    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0103a8e:	89 c2                	mov    %eax,%edx
f0103a90:	39 f2                	cmp    %esi,%edx
f0103a92:	74 11                	je     f0103aa5 <strncpy+0x27>
		*dst++ = *src;
f0103a94:	83 c2 01             	add    $0x1,%edx
f0103a97:	0f b6 19             	movzbl (%ecx),%ebx
f0103a9a:	88 5a ff             	mov    %bl,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0103a9d:	80 fb 01             	cmp    $0x1,%bl
f0103aa0:	83 d9 ff             	sbb    $0xffffffff,%ecx
f0103aa3:	eb eb                	jmp    f0103a90 <strncpy+0x12>
	}
	return ret;
}
f0103aa5:	5b                   	pop    %ebx
f0103aa6:	5e                   	pop    %esi
f0103aa7:	5d                   	pop    %ebp
f0103aa8:	c3                   	ret    

f0103aa9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0103aa9:	55                   	push   %ebp
f0103aaa:	89 e5                	mov    %esp,%ebp
f0103aac:	56                   	push   %esi
f0103aad:	53                   	push   %ebx
f0103aae:	8b 75 08             	mov    0x8(%ebp),%esi
f0103ab1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103ab4:	8b 55 10             	mov    0x10(%ebp),%edx
f0103ab7:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0103ab9:	85 d2                	test   %edx,%edx
f0103abb:	74 21                	je     f0103ade <strlcpy+0x35>
f0103abd:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0103ac1:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
f0103ac3:	39 c2                	cmp    %eax,%edx
f0103ac5:	74 14                	je     f0103adb <strlcpy+0x32>
f0103ac7:	0f b6 19             	movzbl (%ecx),%ebx
f0103aca:	84 db                	test   %bl,%bl
f0103acc:	74 0b                	je     f0103ad9 <strlcpy+0x30>
			*dst++ = *src++;
f0103ace:	83 c1 01             	add    $0x1,%ecx
f0103ad1:	83 c2 01             	add    $0x1,%edx
f0103ad4:	88 5a ff             	mov    %bl,-0x1(%edx)
f0103ad7:	eb ea                	jmp    f0103ac3 <strlcpy+0x1a>
f0103ad9:	89 d0                	mov    %edx,%eax
		*dst = '\0';
f0103adb:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0103ade:	29 f0                	sub    %esi,%eax
}
f0103ae0:	5b                   	pop    %ebx
f0103ae1:	5e                   	pop    %esi
f0103ae2:	5d                   	pop    %ebp
f0103ae3:	c3                   	ret    

f0103ae4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0103ae4:	55                   	push   %ebp
f0103ae5:	89 e5                	mov    %esp,%ebp
f0103ae7:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103aea:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0103aed:	0f b6 01             	movzbl (%ecx),%eax
f0103af0:	84 c0                	test   %al,%al
f0103af2:	74 0c                	je     f0103b00 <strcmp+0x1c>
f0103af4:	3a 02                	cmp    (%edx),%al
f0103af6:	75 08                	jne    f0103b00 <strcmp+0x1c>
		p++, q++;
f0103af8:	83 c1 01             	add    $0x1,%ecx
f0103afb:	83 c2 01             	add    $0x1,%edx
f0103afe:	eb ed                	jmp    f0103aed <strcmp+0x9>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0103b00:	0f b6 c0             	movzbl %al,%eax
f0103b03:	0f b6 12             	movzbl (%edx),%edx
f0103b06:	29 d0                	sub    %edx,%eax
}
f0103b08:	5d                   	pop    %ebp
f0103b09:	c3                   	ret    

f0103b0a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0103b0a:	55                   	push   %ebp
f0103b0b:	89 e5                	mov    %esp,%ebp
f0103b0d:	53                   	push   %ebx
f0103b0e:	8b 45 08             	mov    0x8(%ebp),%eax
f0103b11:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103b14:	89 c3                	mov    %eax,%ebx
f0103b16:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0103b19:	eb 06                	jmp    f0103b21 <strncmp+0x17>
		n--, p++, q++;
f0103b1b:	83 c0 01             	add    $0x1,%eax
f0103b1e:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f0103b21:	39 d8                	cmp    %ebx,%eax
f0103b23:	74 16                	je     f0103b3b <strncmp+0x31>
f0103b25:	0f b6 08             	movzbl (%eax),%ecx
f0103b28:	84 c9                	test   %cl,%cl
f0103b2a:	74 04                	je     f0103b30 <strncmp+0x26>
f0103b2c:	3a 0a                	cmp    (%edx),%cl
f0103b2e:	74 eb                	je     f0103b1b <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0103b30:	0f b6 00             	movzbl (%eax),%eax
f0103b33:	0f b6 12             	movzbl (%edx),%edx
f0103b36:	29 d0                	sub    %edx,%eax
}
f0103b38:	5b                   	pop    %ebx
f0103b39:	5d                   	pop    %ebp
f0103b3a:	c3                   	ret    
		return 0;
f0103b3b:	b8 00 00 00 00       	mov    $0x0,%eax
f0103b40:	eb f6                	jmp    f0103b38 <strncmp+0x2e>

f0103b42 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0103b42:	55                   	push   %ebp
f0103b43:	89 e5                	mov    %esp,%ebp
f0103b45:	8b 45 08             	mov    0x8(%ebp),%eax
f0103b48:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0103b4c:	0f b6 10             	movzbl (%eax),%edx
f0103b4f:	84 d2                	test   %dl,%dl
f0103b51:	74 09                	je     f0103b5c <strchr+0x1a>
		if (*s == c)
f0103b53:	38 ca                	cmp    %cl,%dl
f0103b55:	74 0a                	je     f0103b61 <strchr+0x1f>
	for (; *s; s++)
f0103b57:	83 c0 01             	add    $0x1,%eax
f0103b5a:	eb f0                	jmp    f0103b4c <strchr+0xa>
			return (char *) s;
	return 0;
f0103b5c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103b61:	5d                   	pop    %ebp
f0103b62:	c3                   	ret    

f0103b63 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0103b63:	55                   	push   %ebp
f0103b64:	89 e5                	mov    %esp,%ebp
f0103b66:	8b 45 08             	mov    0x8(%ebp),%eax
f0103b69:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0103b6d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0103b70:	38 ca                	cmp    %cl,%dl
f0103b72:	74 09                	je     f0103b7d <strfind+0x1a>
f0103b74:	84 d2                	test   %dl,%dl
f0103b76:	74 05                	je     f0103b7d <strfind+0x1a>
	for (; *s; s++)
f0103b78:	83 c0 01             	add    $0x1,%eax
f0103b7b:	eb f0                	jmp    f0103b6d <strfind+0xa>
			break;
	return (char *) s;
}
f0103b7d:	5d                   	pop    %ebp
f0103b7e:	c3                   	ret    

f0103b7f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0103b7f:	55                   	push   %ebp
f0103b80:	89 e5                	mov    %esp,%ebp
f0103b82:	57                   	push   %edi
f0103b83:	56                   	push   %esi
f0103b84:	53                   	push   %ebx
f0103b85:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103b88:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0103b8b:	85 c9                	test   %ecx,%ecx
f0103b8d:	74 31                	je     f0103bc0 <memset+0x41>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0103b8f:	89 f8                	mov    %edi,%eax
f0103b91:	09 c8                	or     %ecx,%eax
f0103b93:	a8 03                	test   $0x3,%al
f0103b95:	75 23                	jne    f0103bba <memset+0x3b>
		c &= 0xFF;
f0103b97:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0103b9b:	89 d3                	mov    %edx,%ebx
f0103b9d:	c1 e3 08             	shl    $0x8,%ebx
f0103ba0:	89 d0                	mov    %edx,%eax
f0103ba2:	c1 e0 18             	shl    $0x18,%eax
f0103ba5:	89 d6                	mov    %edx,%esi
f0103ba7:	c1 e6 10             	shl    $0x10,%esi
f0103baa:	09 f0                	or     %esi,%eax
f0103bac:	09 c2                	or     %eax,%edx
f0103bae:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0103bb0:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f0103bb3:	89 d0                	mov    %edx,%eax
f0103bb5:	fc                   	cld    
f0103bb6:	f3 ab                	rep stos %eax,%es:(%edi)
f0103bb8:	eb 06                	jmp    f0103bc0 <memset+0x41>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0103bba:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103bbd:	fc                   	cld    
f0103bbe:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0103bc0:	89 f8                	mov    %edi,%eax
f0103bc2:	5b                   	pop    %ebx
f0103bc3:	5e                   	pop    %esi
f0103bc4:	5f                   	pop    %edi
f0103bc5:	5d                   	pop    %ebp
f0103bc6:	c3                   	ret    

f0103bc7 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0103bc7:	55                   	push   %ebp
f0103bc8:	89 e5                	mov    %esp,%ebp
f0103bca:	57                   	push   %edi
f0103bcb:	56                   	push   %esi
f0103bcc:	8b 45 08             	mov    0x8(%ebp),%eax
f0103bcf:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103bd2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0103bd5:	39 c6                	cmp    %eax,%esi
f0103bd7:	73 32                	jae    f0103c0b <memmove+0x44>
f0103bd9:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0103bdc:	39 c2                	cmp    %eax,%edx
f0103bde:	76 2b                	jbe    f0103c0b <memmove+0x44>
		s += n;
		d += n;
f0103be0:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103be3:	89 fe                	mov    %edi,%esi
f0103be5:	09 ce                	or     %ecx,%esi
f0103be7:	09 d6                	or     %edx,%esi
f0103be9:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0103bef:	75 0e                	jne    f0103bff <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0103bf1:	83 ef 04             	sub    $0x4,%edi
f0103bf4:	8d 72 fc             	lea    -0x4(%edx),%esi
f0103bf7:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f0103bfa:	fd                   	std    
f0103bfb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0103bfd:	eb 09                	jmp    f0103c08 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0103bff:	83 ef 01             	sub    $0x1,%edi
f0103c02:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f0103c05:	fd                   	std    
f0103c06:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0103c08:	fc                   	cld    
f0103c09:	eb 1a                	jmp    f0103c25 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103c0b:	89 c2                	mov    %eax,%edx
f0103c0d:	09 ca                	or     %ecx,%edx
f0103c0f:	09 f2                	or     %esi,%edx
f0103c11:	f6 c2 03             	test   $0x3,%dl
f0103c14:	75 0a                	jne    f0103c20 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0103c16:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f0103c19:	89 c7                	mov    %eax,%edi
f0103c1b:	fc                   	cld    
f0103c1c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0103c1e:	eb 05                	jmp    f0103c25 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
f0103c20:	89 c7                	mov    %eax,%edi
f0103c22:	fc                   	cld    
f0103c23:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0103c25:	5e                   	pop    %esi
f0103c26:	5f                   	pop    %edi
f0103c27:	5d                   	pop    %ebp
f0103c28:	c3                   	ret    

f0103c29 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0103c29:	55                   	push   %ebp
f0103c2a:	89 e5                	mov    %esp,%ebp
f0103c2c:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0103c2f:	ff 75 10             	pushl  0x10(%ebp)
f0103c32:	ff 75 0c             	pushl  0xc(%ebp)
f0103c35:	ff 75 08             	pushl  0x8(%ebp)
f0103c38:	e8 8a ff ff ff       	call   f0103bc7 <memmove>
}
f0103c3d:	c9                   	leave  
f0103c3e:	c3                   	ret    

f0103c3f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0103c3f:	55                   	push   %ebp
f0103c40:	89 e5                	mov    %esp,%ebp
f0103c42:	56                   	push   %esi
f0103c43:	53                   	push   %ebx
f0103c44:	8b 45 08             	mov    0x8(%ebp),%eax
f0103c47:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103c4a:	89 c6                	mov    %eax,%esi
f0103c4c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0103c4f:	39 f0                	cmp    %esi,%eax
f0103c51:	74 1c                	je     f0103c6f <memcmp+0x30>
		if (*s1 != *s2)
f0103c53:	0f b6 08             	movzbl (%eax),%ecx
f0103c56:	0f b6 1a             	movzbl (%edx),%ebx
f0103c59:	38 d9                	cmp    %bl,%cl
f0103c5b:	75 08                	jne    f0103c65 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f0103c5d:	83 c0 01             	add    $0x1,%eax
f0103c60:	83 c2 01             	add    $0x1,%edx
f0103c63:	eb ea                	jmp    f0103c4f <memcmp+0x10>
			return (int) *s1 - (int) *s2;
f0103c65:	0f b6 c1             	movzbl %cl,%eax
f0103c68:	0f b6 db             	movzbl %bl,%ebx
f0103c6b:	29 d8                	sub    %ebx,%eax
f0103c6d:	eb 05                	jmp    f0103c74 <memcmp+0x35>
	}

	return 0;
f0103c6f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103c74:	5b                   	pop    %ebx
f0103c75:	5e                   	pop    %esi
f0103c76:	5d                   	pop    %ebp
f0103c77:	c3                   	ret    

f0103c78 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0103c78:	55                   	push   %ebp
f0103c79:	89 e5                	mov    %esp,%ebp
f0103c7b:	8b 45 08             	mov    0x8(%ebp),%eax
f0103c7e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0103c81:	89 c2                	mov    %eax,%edx
f0103c83:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0103c86:	39 d0                	cmp    %edx,%eax
f0103c88:	73 09                	jae    f0103c93 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
f0103c8a:	38 08                	cmp    %cl,(%eax)
f0103c8c:	74 05                	je     f0103c93 <memfind+0x1b>
	for (; s < ends; s++)
f0103c8e:	83 c0 01             	add    $0x1,%eax
f0103c91:	eb f3                	jmp    f0103c86 <memfind+0xe>
			break;
	return (void *) s;
}
f0103c93:	5d                   	pop    %ebp
f0103c94:	c3                   	ret    

f0103c95 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0103c95:	55                   	push   %ebp
f0103c96:	89 e5                	mov    %esp,%ebp
f0103c98:	57                   	push   %edi
f0103c99:	56                   	push   %esi
f0103c9a:	53                   	push   %ebx
f0103c9b:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103c9e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0103ca1:	eb 03                	jmp    f0103ca6 <strtol+0x11>
		s++;
f0103ca3:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
f0103ca6:	0f b6 01             	movzbl (%ecx),%eax
f0103ca9:	3c 20                	cmp    $0x20,%al
f0103cab:	74 f6                	je     f0103ca3 <strtol+0xe>
f0103cad:	3c 09                	cmp    $0x9,%al
f0103caf:	74 f2                	je     f0103ca3 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f0103cb1:	3c 2b                	cmp    $0x2b,%al
f0103cb3:	74 2a                	je     f0103cdf <strtol+0x4a>
	int neg = 0;
f0103cb5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f0103cba:	3c 2d                	cmp    $0x2d,%al
f0103cbc:	74 2b                	je     f0103ce9 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0103cbe:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0103cc4:	75 0f                	jne    f0103cd5 <strtol+0x40>
f0103cc6:	80 39 30             	cmpb   $0x30,(%ecx)
f0103cc9:	74 28                	je     f0103cf3 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0103ccb:	85 db                	test   %ebx,%ebx
f0103ccd:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103cd2:	0f 44 d8             	cmove  %eax,%ebx
f0103cd5:	b8 00 00 00 00       	mov    $0x0,%eax
f0103cda:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0103cdd:	eb 50                	jmp    f0103d2f <strtol+0x9a>
		s++;
f0103cdf:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
f0103ce2:	bf 00 00 00 00       	mov    $0x0,%edi
f0103ce7:	eb d5                	jmp    f0103cbe <strtol+0x29>
		s++, neg = 1;
f0103ce9:	83 c1 01             	add    $0x1,%ecx
f0103cec:	bf 01 00 00 00       	mov    $0x1,%edi
f0103cf1:	eb cb                	jmp    f0103cbe <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0103cf3:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0103cf7:	74 0e                	je     f0103d07 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
f0103cf9:	85 db                	test   %ebx,%ebx
f0103cfb:	75 d8                	jne    f0103cd5 <strtol+0x40>
		s++, base = 8;
f0103cfd:	83 c1 01             	add    $0x1,%ecx
f0103d00:	bb 08 00 00 00       	mov    $0x8,%ebx
f0103d05:	eb ce                	jmp    f0103cd5 <strtol+0x40>
		s += 2, base = 16;
f0103d07:	83 c1 02             	add    $0x2,%ecx
f0103d0a:	bb 10 00 00 00       	mov    $0x10,%ebx
f0103d0f:	eb c4                	jmp    f0103cd5 <strtol+0x40>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
f0103d11:	8d 72 9f             	lea    -0x61(%edx),%esi
f0103d14:	89 f3                	mov    %esi,%ebx
f0103d16:	80 fb 19             	cmp    $0x19,%bl
f0103d19:	77 29                	ja     f0103d44 <strtol+0xaf>
			dig = *s - 'a' + 10;
f0103d1b:	0f be d2             	movsbl %dl,%edx
f0103d1e:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0103d21:	3b 55 10             	cmp    0x10(%ebp),%edx
f0103d24:	7d 30                	jge    f0103d56 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
f0103d26:	83 c1 01             	add    $0x1,%ecx
f0103d29:	0f af 45 10          	imul   0x10(%ebp),%eax
f0103d2d:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f0103d2f:	0f b6 11             	movzbl (%ecx),%edx
f0103d32:	8d 72 d0             	lea    -0x30(%edx),%esi
f0103d35:	89 f3                	mov    %esi,%ebx
f0103d37:	80 fb 09             	cmp    $0x9,%bl
f0103d3a:	77 d5                	ja     f0103d11 <strtol+0x7c>
			dig = *s - '0';
f0103d3c:	0f be d2             	movsbl %dl,%edx
f0103d3f:	83 ea 30             	sub    $0x30,%edx
f0103d42:	eb dd                	jmp    f0103d21 <strtol+0x8c>
		else if (*s >= 'A' && *s <= 'Z')
f0103d44:	8d 72 bf             	lea    -0x41(%edx),%esi
f0103d47:	89 f3                	mov    %esi,%ebx
f0103d49:	80 fb 19             	cmp    $0x19,%bl
f0103d4c:	77 08                	ja     f0103d56 <strtol+0xc1>
			dig = *s - 'A' + 10;
f0103d4e:	0f be d2             	movsbl %dl,%edx
f0103d51:	83 ea 37             	sub    $0x37,%edx
f0103d54:	eb cb                	jmp    f0103d21 <strtol+0x8c>
		// we don't properly detect overflow!
	}

	if (endptr)
f0103d56:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0103d5a:	74 05                	je     f0103d61 <strtol+0xcc>
		*endptr = (char *) s;
f0103d5c:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103d5f:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f0103d61:	89 c2                	mov    %eax,%edx
f0103d63:	f7 da                	neg    %edx
f0103d65:	85 ff                	test   %edi,%edi
f0103d67:	0f 45 c2             	cmovne %edx,%eax
}
f0103d6a:	5b                   	pop    %ebx
f0103d6b:	5e                   	pop    %esi
f0103d6c:	5f                   	pop    %edi
f0103d6d:	5d                   	pop    %ebp
f0103d6e:	c3                   	ret    
f0103d6f:	90                   	nop

f0103d70 <__udivdi3>:
f0103d70:	f3 0f 1e fb          	endbr32 
f0103d74:	55                   	push   %ebp
f0103d75:	57                   	push   %edi
f0103d76:	56                   	push   %esi
f0103d77:	53                   	push   %ebx
f0103d78:	83 ec 1c             	sub    $0x1c,%esp
f0103d7b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f0103d7f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f0103d83:	8b 74 24 34          	mov    0x34(%esp),%esi
f0103d87:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f0103d8b:	85 d2                	test   %edx,%edx
f0103d8d:	75 49                	jne    f0103dd8 <__udivdi3+0x68>
f0103d8f:	39 f3                	cmp    %esi,%ebx
f0103d91:	76 15                	jbe    f0103da8 <__udivdi3+0x38>
f0103d93:	31 ff                	xor    %edi,%edi
f0103d95:	89 e8                	mov    %ebp,%eax
f0103d97:	89 f2                	mov    %esi,%edx
f0103d99:	f7 f3                	div    %ebx
f0103d9b:	89 fa                	mov    %edi,%edx
f0103d9d:	83 c4 1c             	add    $0x1c,%esp
f0103da0:	5b                   	pop    %ebx
f0103da1:	5e                   	pop    %esi
f0103da2:	5f                   	pop    %edi
f0103da3:	5d                   	pop    %ebp
f0103da4:	c3                   	ret    
f0103da5:	8d 76 00             	lea    0x0(%esi),%esi
f0103da8:	89 d9                	mov    %ebx,%ecx
f0103daa:	85 db                	test   %ebx,%ebx
f0103dac:	75 0b                	jne    f0103db9 <__udivdi3+0x49>
f0103dae:	b8 01 00 00 00       	mov    $0x1,%eax
f0103db3:	31 d2                	xor    %edx,%edx
f0103db5:	f7 f3                	div    %ebx
f0103db7:	89 c1                	mov    %eax,%ecx
f0103db9:	31 d2                	xor    %edx,%edx
f0103dbb:	89 f0                	mov    %esi,%eax
f0103dbd:	f7 f1                	div    %ecx
f0103dbf:	89 c6                	mov    %eax,%esi
f0103dc1:	89 e8                	mov    %ebp,%eax
f0103dc3:	89 f7                	mov    %esi,%edi
f0103dc5:	f7 f1                	div    %ecx
f0103dc7:	89 fa                	mov    %edi,%edx
f0103dc9:	83 c4 1c             	add    $0x1c,%esp
f0103dcc:	5b                   	pop    %ebx
f0103dcd:	5e                   	pop    %esi
f0103dce:	5f                   	pop    %edi
f0103dcf:	5d                   	pop    %ebp
f0103dd0:	c3                   	ret    
f0103dd1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0103dd8:	39 f2                	cmp    %esi,%edx
f0103dda:	77 1c                	ja     f0103df8 <__udivdi3+0x88>
f0103ddc:	0f bd fa             	bsr    %edx,%edi
f0103ddf:	83 f7 1f             	xor    $0x1f,%edi
f0103de2:	75 2c                	jne    f0103e10 <__udivdi3+0xa0>
f0103de4:	39 f2                	cmp    %esi,%edx
f0103de6:	72 06                	jb     f0103dee <__udivdi3+0x7e>
f0103de8:	31 c0                	xor    %eax,%eax
f0103dea:	39 eb                	cmp    %ebp,%ebx
f0103dec:	77 ad                	ja     f0103d9b <__udivdi3+0x2b>
f0103dee:	b8 01 00 00 00       	mov    $0x1,%eax
f0103df3:	eb a6                	jmp    f0103d9b <__udivdi3+0x2b>
f0103df5:	8d 76 00             	lea    0x0(%esi),%esi
f0103df8:	31 ff                	xor    %edi,%edi
f0103dfa:	31 c0                	xor    %eax,%eax
f0103dfc:	89 fa                	mov    %edi,%edx
f0103dfe:	83 c4 1c             	add    $0x1c,%esp
f0103e01:	5b                   	pop    %ebx
f0103e02:	5e                   	pop    %esi
f0103e03:	5f                   	pop    %edi
f0103e04:	5d                   	pop    %ebp
f0103e05:	c3                   	ret    
f0103e06:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0103e0d:	8d 76 00             	lea    0x0(%esi),%esi
f0103e10:	89 f9                	mov    %edi,%ecx
f0103e12:	b8 20 00 00 00       	mov    $0x20,%eax
f0103e17:	29 f8                	sub    %edi,%eax
f0103e19:	d3 e2                	shl    %cl,%edx
f0103e1b:	89 54 24 08          	mov    %edx,0x8(%esp)
f0103e1f:	89 c1                	mov    %eax,%ecx
f0103e21:	89 da                	mov    %ebx,%edx
f0103e23:	d3 ea                	shr    %cl,%edx
f0103e25:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0103e29:	09 d1                	or     %edx,%ecx
f0103e2b:	89 f2                	mov    %esi,%edx
f0103e2d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0103e31:	89 f9                	mov    %edi,%ecx
f0103e33:	d3 e3                	shl    %cl,%ebx
f0103e35:	89 c1                	mov    %eax,%ecx
f0103e37:	d3 ea                	shr    %cl,%edx
f0103e39:	89 f9                	mov    %edi,%ecx
f0103e3b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0103e3f:	89 eb                	mov    %ebp,%ebx
f0103e41:	d3 e6                	shl    %cl,%esi
f0103e43:	89 c1                	mov    %eax,%ecx
f0103e45:	d3 eb                	shr    %cl,%ebx
f0103e47:	09 de                	or     %ebx,%esi
f0103e49:	89 f0                	mov    %esi,%eax
f0103e4b:	f7 74 24 08          	divl   0x8(%esp)
f0103e4f:	89 d6                	mov    %edx,%esi
f0103e51:	89 c3                	mov    %eax,%ebx
f0103e53:	f7 64 24 0c          	mull   0xc(%esp)
f0103e57:	39 d6                	cmp    %edx,%esi
f0103e59:	72 15                	jb     f0103e70 <__udivdi3+0x100>
f0103e5b:	89 f9                	mov    %edi,%ecx
f0103e5d:	d3 e5                	shl    %cl,%ebp
f0103e5f:	39 c5                	cmp    %eax,%ebp
f0103e61:	73 04                	jae    f0103e67 <__udivdi3+0xf7>
f0103e63:	39 d6                	cmp    %edx,%esi
f0103e65:	74 09                	je     f0103e70 <__udivdi3+0x100>
f0103e67:	89 d8                	mov    %ebx,%eax
f0103e69:	31 ff                	xor    %edi,%edi
f0103e6b:	e9 2b ff ff ff       	jmp    f0103d9b <__udivdi3+0x2b>
f0103e70:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0103e73:	31 ff                	xor    %edi,%edi
f0103e75:	e9 21 ff ff ff       	jmp    f0103d9b <__udivdi3+0x2b>
f0103e7a:	66 90                	xchg   %ax,%ax
f0103e7c:	66 90                	xchg   %ax,%ax
f0103e7e:	66 90                	xchg   %ax,%ax

f0103e80 <__umoddi3>:
f0103e80:	f3 0f 1e fb          	endbr32 
f0103e84:	55                   	push   %ebp
f0103e85:	57                   	push   %edi
f0103e86:	56                   	push   %esi
f0103e87:	53                   	push   %ebx
f0103e88:	83 ec 1c             	sub    $0x1c,%esp
f0103e8b:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f0103e8f:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f0103e93:	8b 74 24 30          	mov    0x30(%esp),%esi
f0103e97:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0103e9b:	89 da                	mov    %ebx,%edx
f0103e9d:	85 c0                	test   %eax,%eax
f0103e9f:	75 3f                	jne    f0103ee0 <__umoddi3+0x60>
f0103ea1:	39 df                	cmp    %ebx,%edi
f0103ea3:	76 13                	jbe    f0103eb8 <__umoddi3+0x38>
f0103ea5:	89 f0                	mov    %esi,%eax
f0103ea7:	f7 f7                	div    %edi
f0103ea9:	89 d0                	mov    %edx,%eax
f0103eab:	31 d2                	xor    %edx,%edx
f0103ead:	83 c4 1c             	add    $0x1c,%esp
f0103eb0:	5b                   	pop    %ebx
f0103eb1:	5e                   	pop    %esi
f0103eb2:	5f                   	pop    %edi
f0103eb3:	5d                   	pop    %ebp
f0103eb4:	c3                   	ret    
f0103eb5:	8d 76 00             	lea    0x0(%esi),%esi
f0103eb8:	89 fd                	mov    %edi,%ebp
f0103eba:	85 ff                	test   %edi,%edi
f0103ebc:	75 0b                	jne    f0103ec9 <__umoddi3+0x49>
f0103ebe:	b8 01 00 00 00       	mov    $0x1,%eax
f0103ec3:	31 d2                	xor    %edx,%edx
f0103ec5:	f7 f7                	div    %edi
f0103ec7:	89 c5                	mov    %eax,%ebp
f0103ec9:	89 d8                	mov    %ebx,%eax
f0103ecb:	31 d2                	xor    %edx,%edx
f0103ecd:	f7 f5                	div    %ebp
f0103ecf:	89 f0                	mov    %esi,%eax
f0103ed1:	f7 f5                	div    %ebp
f0103ed3:	89 d0                	mov    %edx,%eax
f0103ed5:	eb d4                	jmp    f0103eab <__umoddi3+0x2b>
f0103ed7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0103ede:	66 90                	xchg   %ax,%ax
f0103ee0:	89 f1                	mov    %esi,%ecx
f0103ee2:	39 d8                	cmp    %ebx,%eax
f0103ee4:	76 0a                	jbe    f0103ef0 <__umoddi3+0x70>
f0103ee6:	89 f0                	mov    %esi,%eax
f0103ee8:	83 c4 1c             	add    $0x1c,%esp
f0103eeb:	5b                   	pop    %ebx
f0103eec:	5e                   	pop    %esi
f0103eed:	5f                   	pop    %edi
f0103eee:	5d                   	pop    %ebp
f0103eef:	c3                   	ret    
f0103ef0:	0f bd e8             	bsr    %eax,%ebp
f0103ef3:	83 f5 1f             	xor    $0x1f,%ebp
f0103ef6:	75 20                	jne    f0103f18 <__umoddi3+0x98>
f0103ef8:	39 d8                	cmp    %ebx,%eax
f0103efa:	0f 82 b0 00 00 00    	jb     f0103fb0 <__umoddi3+0x130>
f0103f00:	39 f7                	cmp    %esi,%edi
f0103f02:	0f 86 a8 00 00 00    	jbe    f0103fb0 <__umoddi3+0x130>
f0103f08:	89 c8                	mov    %ecx,%eax
f0103f0a:	83 c4 1c             	add    $0x1c,%esp
f0103f0d:	5b                   	pop    %ebx
f0103f0e:	5e                   	pop    %esi
f0103f0f:	5f                   	pop    %edi
f0103f10:	5d                   	pop    %ebp
f0103f11:	c3                   	ret    
f0103f12:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0103f18:	89 e9                	mov    %ebp,%ecx
f0103f1a:	ba 20 00 00 00       	mov    $0x20,%edx
f0103f1f:	29 ea                	sub    %ebp,%edx
f0103f21:	d3 e0                	shl    %cl,%eax
f0103f23:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103f27:	89 d1                	mov    %edx,%ecx
f0103f29:	89 f8                	mov    %edi,%eax
f0103f2b:	d3 e8                	shr    %cl,%eax
f0103f2d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0103f31:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103f35:	8b 54 24 04          	mov    0x4(%esp),%edx
f0103f39:	09 c1                	or     %eax,%ecx
f0103f3b:	89 d8                	mov    %ebx,%eax
f0103f3d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0103f41:	89 e9                	mov    %ebp,%ecx
f0103f43:	d3 e7                	shl    %cl,%edi
f0103f45:	89 d1                	mov    %edx,%ecx
f0103f47:	d3 e8                	shr    %cl,%eax
f0103f49:	89 e9                	mov    %ebp,%ecx
f0103f4b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0103f4f:	d3 e3                	shl    %cl,%ebx
f0103f51:	89 c7                	mov    %eax,%edi
f0103f53:	89 d1                	mov    %edx,%ecx
f0103f55:	89 f0                	mov    %esi,%eax
f0103f57:	d3 e8                	shr    %cl,%eax
f0103f59:	89 e9                	mov    %ebp,%ecx
f0103f5b:	89 fa                	mov    %edi,%edx
f0103f5d:	d3 e6                	shl    %cl,%esi
f0103f5f:	09 d8                	or     %ebx,%eax
f0103f61:	f7 74 24 08          	divl   0x8(%esp)
f0103f65:	89 d1                	mov    %edx,%ecx
f0103f67:	89 f3                	mov    %esi,%ebx
f0103f69:	f7 64 24 0c          	mull   0xc(%esp)
f0103f6d:	89 c6                	mov    %eax,%esi
f0103f6f:	89 d7                	mov    %edx,%edi
f0103f71:	39 d1                	cmp    %edx,%ecx
f0103f73:	72 06                	jb     f0103f7b <__umoddi3+0xfb>
f0103f75:	75 10                	jne    f0103f87 <__umoddi3+0x107>
f0103f77:	39 c3                	cmp    %eax,%ebx
f0103f79:	73 0c                	jae    f0103f87 <__umoddi3+0x107>
f0103f7b:	2b 44 24 0c          	sub    0xc(%esp),%eax
f0103f7f:	1b 54 24 08          	sbb    0x8(%esp),%edx
f0103f83:	89 d7                	mov    %edx,%edi
f0103f85:	89 c6                	mov    %eax,%esi
f0103f87:	89 ca                	mov    %ecx,%edx
f0103f89:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0103f8e:	29 f3                	sub    %esi,%ebx
f0103f90:	19 fa                	sbb    %edi,%edx
f0103f92:	89 d0                	mov    %edx,%eax
f0103f94:	d3 e0                	shl    %cl,%eax
f0103f96:	89 e9                	mov    %ebp,%ecx
f0103f98:	d3 eb                	shr    %cl,%ebx
f0103f9a:	d3 ea                	shr    %cl,%edx
f0103f9c:	09 d8                	or     %ebx,%eax
f0103f9e:	83 c4 1c             	add    $0x1c,%esp
f0103fa1:	5b                   	pop    %ebx
f0103fa2:	5e                   	pop    %esi
f0103fa3:	5f                   	pop    %edi
f0103fa4:	5d                   	pop    %ebp
f0103fa5:	c3                   	ret    
f0103fa6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0103fad:	8d 76 00             	lea    0x0(%esi),%esi
f0103fb0:	89 da                	mov    %ebx,%edx
f0103fb2:	29 fe                	sub    %edi,%esi
f0103fb4:	19 c2                	sbb    %eax,%edx
f0103fb6:	89 f1                	mov    %esi,%ecx
f0103fb8:	89 c8                	mov    %ecx,%eax
f0103fba:	e9 4b ff ff ff       	jmp    f0103f0a <__umoddi3+0x8a>
