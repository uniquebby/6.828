
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
f0100015:	b8 00 40 11 00       	mov    $0x114000,%eax
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
f0100034:	bc 00 20 11 f0       	mov    $0xf0112000,%esp

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
f010004a:	81 c3 1e 50 01 00    	add    $0x1501e,%ebx
f0100050:	8b 75 08             	mov    0x8(%ebp),%esi
	cprintf("entering test_backtrace %d\n", x);
f0100053:	83 ec 08             	sub    $0x8,%esp
f0100056:	56                   	push   %esi
f0100057:	8d 83 18 d0 fe ff    	lea    -0x12fe8(%ebx),%eax
f010005d:	50                   	push   %eax
f010005e:	e8 9a 0f 00 00       	call   f0100ffd <cprintf>
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
f010007d:	8d 83 34 d0 fe ff    	lea    -0x12fcc(%ebx),%eax
f0100083:	50                   	push   %eax
f0100084:	e8 74 0f 00 00       	call   f0100ffd <cprintf>
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
f01000b2:	81 c3 b6 4f 01 00    	add    $0x14fb6,%ebx
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f01000b8:	c7 c2 80 50 11 f0    	mov    $0xf0115080,%edx
f01000be:	c7 c0 c0 56 11 f0    	mov    $0xf01156c0,%eax
f01000c4:	29 d0                	sub    %edx,%eax
f01000c6:	50                   	push   %eax
f01000c7:	6a 00                	push   $0x0
f01000c9:	52                   	push   %edx
f01000ca:	e8 53 1b 00 00       	call   f0101c22 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000cf:	e8 15 05 00 00       	call   f01005e9 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000d4:	83 c4 08             	add    $0x8,%esp
f01000d7:	68 ac 1a 00 00       	push   $0x1aac
f01000dc:	8d 83 4f d0 fe ff    	lea    -0x12fb1(%ebx),%eax
f01000e2:	50                   	push   %eax
f01000e3:	e8 15 0f 00 00       	call   f0100ffd <cprintf>

	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f01000e8:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f01000ef:	e8 4c ff ff ff       	call   f0100040 <test_backtrace>
	// Lab 2 memory management initialization functions
	mem_init();
f01000f4:	e8 1c 0a 00 00       	call   f0100b15 <mem_init>
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
f0100119:	81 c3 4f 4f 01 00    	add    $0x14f4f,%ebx
f010011f:	8b 7d 10             	mov    0x10(%ebp),%edi
	va_list ap;

	if (panicstr)
f0100122:	c7 c0 c4 56 11 f0    	mov    $0xf01156c4,%eax
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
f010014c:	8d 83 6a d0 fe ff    	lea    -0x12f96(%ebx),%eax
f0100152:	50                   	push   %eax
f0100153:	e8 a5 0e 00 00       	call   f0100ffd <cprintf>
	vcprintf(fmt, ap);
f0100158:	83 c4 08             	add    $0x8,%esp
f010015b:	56                   	push   %esi
f010015c:	57                   	push   %edi
f010015d:	e8 64 0e 00 00       	call   f0100fc6 <vcprintf>
	cprintf("\n");
f0100162:	8d 83 a6 d0 fe ff    	lea    -0x12f5a(%ebx),%eax
f0100168:	89 04 24             	mov    %eax,(%esp)
f010016b:	e8 8d 0e 00 00       	call   f0100ffd <cprintf>
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
f010017f:	81 c3 e9 4e 01 00    	add    $0x14ee9,%ebx
	va_list ap;

	va_start(ap, fmt);
f0100185:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel warning at %s:%d: ", file, line);
f0100188:	83 ec 04             	sub    $0x4,%esp
f010018b:	ff 75 0c             	pushl  0xc(%ebp)
f010018e:	ff 75 08             	pushl  0x8(%ebp)
f0100191:	8d 83 82 d0 fe ff    	lea    -0x12f7e(%ebx),%eax
f0100197:	50                   	push   %eax
f0100198:	e8 60 0e 00 00       	call   f0100ffd <cprintf>
	vcprintf(fmt, ap);
f010019d:	83 c4 08             	add    $0x8,%esp
f01001a0:	56                   	push   %esi
f01001a1:	ff 75 10             	pushl  0x10(%ebp)
f01001a4:	e8 1d 0e 00 00       	call   f0100fc6 <vcprintf>
	cprintf("\n");
f01001a9:	8d 83 a6 d0 fe ff    	lea    -0x12f5a(%ebx),%eax
f01001af:	89 04 24             	mov    %eax,(%esp)
f01001b2:	e8 46 0e 00 00       	call   f0100ffd <cprintf>
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
f01001e9:	81 c3 7f 4e 01 00    	add    $0x14e7f,%ebx
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
f0100230:	81 c3 38 4e 01 00    	add    $0x14e38,%ebx
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
f0100278:	0f b6 84 13 d8 d1 fe 	movzbl -0x12e28(%ebx,%edx,1),%eax
f010027f:	ff 
f0100280:	0b 83 18 00 00 00    	or     0x18(%ebx),%eax
	shift ^= togglecode[data];
f0100286:	0f b6 8c 13 d8 d0 fe 	movzbl -0x12f28(%ebx,%edx,1),%ecx
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
f01002e7:	0f b6 84 13 d8 d1 fe 	movzbl -0x12e28(%ebx,%edx,1),%eax
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
f0100323:	8d 83 9c d0 fe ff    	lea    -0x12f64(%ebx),%eax
f0100329:	50                   	push   %eax
f010032a:	e8 ce 0c 00 00       	call   f0100ffd <cprintf>
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
f010035e:	81 c3 0a 4d 01 00    	add    $0x14d0a,%ebx
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
f010051e:	e8 47 17 00 00       	call   f0101c6a <memmove>
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
f0100556:	05 12 4b 01 00       	add    $0x14b12,%eax
	if (serial_exists)
f010055b:	80 b8 4c 02 00 00 00 	cmpb   $0x0,0x24c(%eax)
f0100562:	75 01                	jne    f0100565 <serial_intr+0x14>
f0100564:	c3                   	ret    
{
f0100565:	55                   	push   %ebp
f0100566:	89 e5                	mov    %esp,%ebp
f0100568:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f010056b:	8d 80 5d b1 fe ff    	lea    -0x14ea3(%eax),%eax
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
f0100583:	05 e5 4a 01 00       	add    $0x14ae5,%eax
	cons_intr(kbd_proc_data);
f0100588:	8d 80 be b1 fe ff    	lea    -0x14e42(%eax),%eax
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
f01005a1:	81 c3 c7 4a 01 00    	add    $0x14ac7,%ebx
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
f01005f7:	81 c3 71 4a 01 00    	add    $0x14a71,%ebx
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
f01006fa:	8d 83 a8 d0 fe ff    	lea    -0x12f58(%ebx),%eax
f0100700:	50                   	push   %eax
f0100701:	e8 f7 08 00 00       	call   f0100ffd <cprintf>
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
f0100740:	81 c3 28 49 01 00    	add    $0x14928,%ebx
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100746:	83 ec 04             	sub    $0x4,%esp
f0100749:	8d 83 d8 d2 fe ff    	lea    -0x12d28(%ebx),%eax
f010074f:	50                   	push   %eax
f0100750:	8d 83 f6 d2 fe ff    	lea    -0x12d0a(%ebx),%eax
f0100756:	50                   	push   %eax
f0100757:	8d b3 fb d2 fe ff    	lea    -0x12d05(%ebx),%esi
f010075d:	56                   	push   %esi
f010075e:	e8 9a 08 00 00       	call   f0100ffd <cprintf>
f0100763:	83 c4 0c             	add    $0xc,%esp
f0100766:	8d 83 a8 d3 fe ff    	lea    -0x12c58(%ebx),%eax
f010076c:	50                   	push   %eax
f010076d:	8d 83 04 d3 fe ff    	lea    -0x12cfc(%ebx),%eax
f0100773:	50                   	push   %eax
f0100774:	56                   	push   %esi
f0100775:	e8 83 08 00 00       	call   f0100ffd <cprintf>
f010077a:	83 c4 0c             	add    $0xc,%esp
f010077d:	8d 83 0d d3 fe ff    	lea    -0x12cf3(%ebx),%eax
f0100783:	50                   	push   %eax
f0100784:	8d 83 24 d3 fe ff    	lea    -0x12cdc(%ebx),%eax
f010078a:	50                   	push   %eax
f010078b:	56                   	push   %esi
f010078c:	e8 6c 08 00 00       	call   f0100ffd <cprintf>
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
f01007ab:	81 c3 bd 48 01 00    	add    $0x148bd,%ebx
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007b1:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f01007b7:	50                   	push   %eax
f01007b8:	e8 40 08 00 00       	call   f0100ffd <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01007bd:	83 c4 08             	add    $0x8,%esp
f01007c0:	ff b3 f8 ff ff ff    	pushl  -0x8(%ebx)
f01007c6:	8d 83 d0 d3 fe ff    	lea    -0x12c30(%ebx),%eax
f01007cc:	50                   	push   %eax
f01007cd:	e8 2b 08 00 00       	call   f0100ffd <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01007d2:	83 c4 0c             	add    $0xc,%esp
f01007d5:	c7 c7 0c 00 10 f0    	mov    $0xf010000c,%edi
f01007db:	8d 87 00 00 00 10    	lea    0x10000000(%edi),%eax
f01007e1:	50                   	push   %eax
f01007e2:	57                   	push   %edi
f01007e3:	8d 83 f8 d3 fe ff    	lea    -0x12c08(%ebx),%eax
f01007e9:	50                   	push   %eax
f01007ea:	e8 0e 08 00 00       	call   f0100ffd <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01007ef:	83 c4 0c             	add    $0xc,%esp
f01007f2:	c7 c0 6f 20 10 f0    	mov    $0xf010206f,%eax
f01007f8:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01007fe:	52                   	push   %edx
f01007ff:	50                   	push   %eax
f0100800:	8d 83 1c d4 fe ff    	lea    -0x12be4(%ebx),%eax
f0100806:	50                   	push   %eax
f0100807:	e8 f1 07 00 00       	call   f0100ffd <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010080c:	83 c4 0c             	add    $0xc,%esp
f010080f:	c7 c0 80 50 11 f0    	mov    $0xf0115080,%eax
f0100815:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010081b:	52                   	push   %edx
f010081c:	50                   	push   %eax
f010081d:	8d 83 40 d4 fe ff    	lea    -0x12bc0(%ebx),%eax
f0100823:	50                   	push   %eax
f0100824:	e8 d4 07 00 00       	call   f0100ffd <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100829:	83 c4 0c             	add    $0xc,%esp
f010082c:	c7 c6 c0 56 11 f0    	mov    $0xf01156c0,%esi
f0100832:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f0100838:	50                   	push   %eax
f0100839:	56                   	push   %esi
f010083a:	8d 83 64 d4 fe ff    	lea    -0x12b9c(%ebx),%eax
f0100840:	50                   	push   %eax
f0100841:	e8 b7 07 00 00       	call   f0100ffd <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100846:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f0100849:	29 fe                	sub    %edi,%esi
f010084b:	81 c6 ff 03 00 00    	add    $0x3ff,%esi
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100851:	c1 fe 0a             	sar    $0xa,%esi
f0100854:	56                   	push   %esi
f0100855:	8d 83 88 d4 fe ff    	lea    -0x12b78(%ebx),%eax
f010085b:	50                   	push   %eax
f010085c:	e8 9c 07 00 00       	call   f0100ffd <cprintf>
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
f010087c:	81 c3 ec 47 01 00    	add    $0x147ec,%ebx

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
f0100884:	8d 83 47 d3 fe ff    	lea    -0x12cb9(%ebx),%eax
f010088a:	50                   	push   %eax
f010088b:	e8 6d 07 00 00       	call   f0100ffd <cprintf>
	while (ebp != 0) {
f0100890:	83 c4 10             	add    $0x10,%esp
		ptr_ebp = (uint32_t *)ebp;
		cprintf(" ebp %x  eip %x  args %08x %08x %08x %08x %08x\n", 
f0100893:	8d 83 b4 d4 fe ff    	lea    -0x12b4c(%ebx),%eax
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
f01008ba:	8d 83 59 d3 fe ff    	lea    -0x12ca7(%ebx),%eax
f01008c0:	50                   	push   %eax
f01008c1:	e8 37 07 00 00       	call   f0100ffd <cprintf>
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
f01008e7:	e8 11 07 00 00       	call   f0100ffd <cprintf>
		if (debuginfo_eip(ptr_ebp[1], &info) == 0) {
f01008ec:	83 c4 18             	add    $0x18,%esp
f01008ef:	ff 75 c0             	pushl  -0x40(%ebp)
f01008f2:	ff 76 04             	pushl  0x4(%esi)
f01008f5:	e8 07 08 00 00       	call   f0101101 <debuginfo_eip>
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
f010091e:	81 c3 4a 47 01 00    	add    $0x1474a,%ebx
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100924:	8d 83 e4 d4 fe ff    	lea    -0x12b1c(%ebx),%eax
f010092a:	50                   	push   %eax
f010092b:	e8 cd 06 00 00       	call   f0100ffd <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100930:	8d 83 08 d5 fe ff    	lea    -0x12af8(%ebx),%eax
f0100936:	89 04 24             	mov    %eax,(%esp)
f0100939:	e8 bf 06 00 00       	call   f0100ffd <cprintf>
f010093e:	83 c4 10             	add    $0x10,%esp
		while (*buf && strchr(WHITESPACE, *buf))
f0100941:	8d 83 6f d3 fe ff    	lea    -0x12c91(%ebx),%eax
f0100947:	89 45 a0             	mov    %eax,-0x60(%ebp)
f010094a:	e9 d1 00 00 00       	jmp    f0100a20 <monitor+0x110>
f010094f:	83 ec 08             	sub    $0x8,%esp
f0100952:	0f be c0             	movsbl %al,%eax
f0100955:	50                   	push   %eax
f0100956:	ff 75 a0             	pushl  -0x60(%ebp)
f0100959:	e8 87 12 00 00       	call   f0101be5 <strchr>
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
f01009a0:	e8 e2 11 00 00       	call   f0101b87 <strcmp>
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
f01009c1:	8d 83 91 d3 fe ff    	lea    -0x12c6f(%ebx),%eax
f01009c7:	50                   	push   %eax
f01009c8:	e8 30 06 00 00       	call   f0100ffd <cprintf>
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
f01009f7:	e8 e9 11 00 00       	call   f0101be5 <strchr>
f01009fc:	83 c4 10             	add    $0x10,%esp
f01009ff:	85 c0                	test   %eax,%eax
f0100a01:	0f 85 67 ff ff ff    	jne    f010096e <monitor+0x5e>
			buf++;
f0100a07:	83 c6 01             	add    $0x1,%esi
f0100a0a:	eb da                	jmp    f01009e6 <monitor+0xd6>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100a0c:	83 ec 08             	sub    $0x8,%esp
f0100a0f:	6a 10                	push   $0x10
f0100a11:	8d 83 74 d3 fe ff    	lea    -0x12c8c(%ebx),%eax
f0100a17:	50                   	push   %eax
f0100a18:	e8 e0 05 00 00       	call   f0100ffd <cprintf>
f0100a1d:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f0100a20:	8d bb 6b d3 fe ff    	lea    -0x12c95(%ebx),%edi
f0100a26:	83 ec 0c             	sub    $0xc,%esp
f0100a29:	57                   	push   %edi
f0100a2a:	e8 77 0f 00 00       	call   f01019a6 <readline>
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

f0100a72 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100a72:	55                   	push   %ebp
f0100a73:	89 e5                	mov    %esp,%ebp
f0100a75:	57                   	push   %edi
f0100a76:	56                   	push   %esi
f0100a77:	53                   	push   %ebx
f0100a78:	83 ec 18             	sub    $0x18,%esp
f0100a7b:	e8 41 f7 ff ff       	call   f01001c1 <__x86.get_pc_thunk.bx>
f0100a80:	81 c3 e8 45 01 00    	add    $0x145e8,%ebx
f0100a86:	89 c7                	mov    %eax,%edi
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100a88:	50                   	push   %eax
f0100a89:	e8 e8 04 00 00       	call   f0100f76 <mc146818_read>
f0100a8e:	89 c6                	mov    %eax,%esi
f0100a90:	83 c7 01             	add    $0x1,%edi
f0100a93:	89 3c 24             	mov    %edi,(%esp)
f0100a96:	e8 db 04 00 00       	call   f0100f76 <mc146818_read>
f0100a9b:	c1 e0 08             	shl    $0x8,%eax
f0100a9e:	09 f0                	or     %esi,%eax
}
f0100aa0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100aa3:	5b                   	pop    %ebx
f0100aa4:	5e                   	pop    %esi
f0100aa5:	5f                   	pop    %edi
f0100aa6:	5d                   	pop    %ebp
f0100aa7:	c3                   	ret    

f0100aa8 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100aa8:	55                   	push   %ebp
f0100aa9:	89 e5                	mov    %esp,%ebp
f0100aab:	57                   	push   %edi
f0100aac:	56                   	push   %esi
f0100aad:	53                   	push   %ebx
f0100aae:	83 ec 04             	sub    $0x4,%esp
f0100ab1:	e8 bc 04 00 00       	call   f0100f72 <__x86.get_pc_thunk.si>
f0100ab6:	81 c6 b2 45 01 00    	add    $0x145b2,%esi
f0100abc:	89 75 f0             	mov    %esi,-0x10(%ebp)
f0100abf:	8b 9e 54 02 00 00    	mov    0x254(%esi),%ebx
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0100ac5:	ba 00 00 00 00       	mov    $0x0,%edx
f0100aca:	b8 00 00 00 00       	mov    $0x0,%eax
f0100acf:	c7 c7 c8 56 11 f0    	mov    $0xf01156c8,%edi
		pages[i].pp_ref = 0;
f0100ad5:	c7 c6 d0 56 11 f0    	mov    $0xf01156d0,%esi
	for (i = 0; i < npages; i++) {
f0100adb:	39 07                	cmp    %eax,(%edi)
f0100add:	76 21                	jbe    f0100b00 <page_init+0x58>
f0100adf:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
		pages[i].pp_ref = 0;
f0100ae6:	89 d1                	mov    %edx,%ecx
f0100ae8:	03 0e                	add    (%esi),%ecx
f0100aea:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f0100af0:	89 19                	mov    %ebx,(%ecx)
	for (i = 0; i < npages; i++) {
f0100af2:	83 c0 01             	add    $0x1,%eax
		page_free_list = &pages[i];
f0100af5:	89 d3                	mov    %edx,%ebx
f0100af7:	03 1e                	add    (%esi),%ebx
f0100af9:	ba 01 00 00 00       	mov    $0x1,%edx
f0100afe:	eb db                	jmp    f0100adb <page_init+0x33>
f0100b00:	84 d2                	test   %dl,%dl
f0100b02:	74 09                	je     f0100b0d <page_init+0x65>
f0100b04:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100b07:	89 98 54 02 00 00    	mov    %ebx,0x254(%eax)
	}
}
f0100b0d:	83 c4 04             	add    $0x4,%esp
f0100b10:	5b                   	pop    %ebx
f0100b11:	5e                   	pop    %esi
f0100b12:	5f                   	pop    %edi
f0100b13:	5d                   	pop    %ebp
f0100b14:	c3                   	ret    

f0100b15 <mem_init>:
{
f0100b15:	55                   	push   %ebp
f0100b16:	89 e5                	mov    %esp,%ebp
f0100b18:	57                   	push   %edi
f0100b19:	56                   	push   %esi
f0100b1a:	53                   	push   %ebx
f0100b1b:	83 ec 2c             	sub    $0x2c,%esp
f0100b1e:	e8 9e f6 ff ff       	call   f01001c1 <__x86.get_pc_thunk.bx>
f0100b23:	81 c3 45 45 01 00    	add    $0x14545,%ebx
	basemem = nvram_read(NVRAM_BASELO);
f0100b29:	b8 15 00 00 00       	mov    $0x15,%eax
f0100b2e:	e8 3f ff ff ff       	call   f0100a72 <nvram_read>
f0100b33:	89 c6                	mov    %eax,%esi
	extmem = nvram_read(NVRAM_EXTLO);
f0100b35:	b8 17 00 00 00       	mov    $0x17,%eax
f0100b3a:	e8 33 ff ff ff       	call   f0100a72 <nvram_read>
f0100b3f:	89 c7                	mov    %eax,%edi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f0100b41:	b8 34 00 00 00       	mov    $0x34,%eax
f0100b46:	e8 27 ff ff ff       	call   f0100a72 <nvram_read>
	if (ext16mem)
f0100b4b:	c1 e0 06             	shl    $0x6,%eax
f0100b4e:	0f 84 e1 00 00 00    	je     f0100c35 <mem_init+0x120>
		totalmem = 16 * 1024 + ext16mem;
f0100b54:	05 00 40 00 00       	add    $0x4000,%eax
	npages = totalmem / (PGSIZE / 1024);
f0100b59:	89 c1                	mov    %eax,%ecx
f0100b5b:	c1 e9 02             	shr    $0x2,%ecx
f0100b5e:	c7 c2 c8 56 11 f0    	mov    $0xf01156c8,%edx
f0100b64:	89 0a                	mov    %ecx,(%edx)
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0100b66:	89 c2                	mov    %eax,%edx
f0100b68:	29 f2                	sub    %esi,%edx
f0100b6a:	52                   	push   %edx
f0100b6b:	56                   	push   %esi
f0100b6c:	50                   	push   %eax
f0100b6d:	8d 83 30 d5 fe ff    	lea    -0x12ad0(%ebx),%eax
f0100b73:	50                   	push   %eax
f0100b74:	e8 84 04 00 00       	call   f0100ffd <cprintf>
	if (!nextfree) {
f0100b79:	83 c4 10             	add    $0x10,%esp
f0100b7c:	83 bb 50 02 00 00 00 	cmpl   $0x0,0x250(%ebx)
f0100b83:	0f 84 c1 00 00 00    	je     f0100c4a <mem_init+0x135>
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0100b89:	c7 c6 cc 56 11 f0    	mov    $0xf01156cc,%esi
f0100b8f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	memset(kern_pgdir, 0, PGSIZE);
f0100b95:	83 ec 04             	sub    $0x4,%esp
f0100b98:	68 00 10 00 00       	push   $0x1000
f0100b9d:	6a 00                	push   $0x0
f0100b9f:	6a 00                	push   $0x0
f0100ba1:	e8 7c 10 00 00       	call   f0101c22 <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0100ba6:	8b 06                	mov    (%esi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100ba8:	83 c4 10             	add    $0x10,%esp
f0100bab:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100bb0:	0f 86 af 00 00 00    	jbe    f0100c65 <mem_init+0x150>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
	return (physaddr_t)kva - KERNBASE;
f0100bb6:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0100bbc:	83 ca 05             	or     $0x5,%edx
f0100bbf:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	page_init();
f0100bc5:	e8 de fe ff ff       	call   f0100aa8 <page_init>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100bca:	8b 83 54 02 00 00    	mov    0x254(%ebx),%eax
f0100bd0:	85 c0                	test   %eax,%eax
f0100bd2:	0f 84 a6 00 00 00    	je     f0100c7e <mem_init+0x169>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100bd8:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100bdb:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100bde:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100be1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100be4:	c7 c6 d0 56 11 f0    	mov    $0xf01156d0,%esi
f0100bea:	89 c2                	mov    %eax,%edx
f0100bec:	2b 16                	sub    (%esi),%edx
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100bee:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100bf4:	0f 95 c2             	setne  %dl
f0100bf7:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100bfa:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100bfe:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100c00:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c04:	8b 00                	mov    (%eax),%eax
f0100c06:	85 c0                	test   %eax,%eax
f0100c08:	75 e0                	jne    f0100bea <mem_init+0xd5>
		}
		*tp[1] = 0;
f0100c0a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100c0d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100c13:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100c16:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100c19:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100c1b:	8b 75 d8             	mov    -0x28(%ebp),%esi
f0100c1e:	89 b3 54 02 00 00    	mov    %esi,0x254(%ebx)
f0100c24:	c7 c7 d0 56 11 f0    	mov    $0xf01156d0,%edi
	if (PGNUM(pa) >= npages)
f0100c2a:	c7 c0 c8 56 11 f0    	mov    $0xf01156c8,%eax
f0100c30:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0100c33:	eb 7c                	jmp    f0100cb1 <mem_init+0x19c>
		totalmem = basemem;
f0100c35:	89 f0                	mov    %esi,%eax
	else if (extmem)
f0100c37:	85 ff                	test   %edi,%edi
f0100c39:	0f 84 1a ff ff ff    	je     f0100b59 <mem_init+0x44>
		totalmem = 1 * 1024 + extmem;
f0100c3f:	8d 87 00 04 00 00    	lea    0x400(%edi),%eax
f0100c45:	e9 0f ff ff ff       	jmp    f0100b59 <mem_init+0x44>
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100c4a:	c7 c0 c0 56 11 f0    	mov    $0xf01156c0,%eax
f0100c50:	05 ff 0f 00 00       	add    $0xfff,%eax
f0100c55:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100c5a:	89 83 50 02 00 00    	mov    %eax,0x250(%ebx)
f0100c60:	e9 24 ff ff ff       	jmp    f0100b89 <mem_init+0x74>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100c65:	50                   	push   %eax
f0100c66:	8d 83 6c d5 fe ff    	lea    -0x12a94(%ebx),%eax
f0100c6c:	50                   	push   %eax
f0100c6d:	68 8e 00 00 00       	push   $0x8e
f0100c72:	8d 83 54 d6 fe ff    	lea    -0x129ac(%ebx),%eax
f0100c78:	50                   	push   %eax
f0100c79:	e8 8d f4 ff ff       	call   f010010b <_panic>
		panic("'page_free_list' is a null pointer!");
f0100c7e:	83 ec 04             	sub    $0x4,%esp
f0100c81:	8d 83 90 d5 fe ff    	lea    -0x12a70(%ebx),%eax
f0100c87:	50                   	push   %eax
f0100c88:	68 c2 01 00 00       	push   $0x1c2
f0100c8d:	8d 83 54 d6 fe ff    	lea    -0x129ac(%ebx),%eax
f0100c93:	50                   	push   %eax
f0100c94:	e8 72 f4 ff ff       	call   f010010b <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c99:	50                   	push   %eax
f0100c9a:	8d 83 b4 d5 fe ff    	lea    -0x12a4c(%ebx),%eax
f0100ca0:	50                   	push   %eax
f0100ca1:	6a 52                	push   $0x52
f0100ca3:	8d 83 60 d6 fe ff    	lea    -0x129a0(%ebx),%eax
f0100ca9:	50                   	push   %eax
f0100caa:	e8 5c f4 ff ff       	call   f010010b <_panic>
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100caf:	8b 36                	mov    (%esi),%esi
f0100cb1:	85 f6                	test   %esi,%esi
f0100cb3:	74 3a                	je     f0100cef <mem_init+0x1da>
	return (pp - pages) << PGSHIFT;
f0100cb5:	89 f0                	mov    %esi,%eax
f0100cb7:	2b 07                	sub    (%edi),%eax
f0100cb9:	c1 f8 03             	sar    $0x3,%eax
f0100cbc:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100cbf:	89 c1                	mov    %eax,%ecx
f0100cc1:	c1 e9 16             	shr    $0x16,%ecx
f0100cc4:	75 e9                	jne    f0100caf <mem_init+0x19a>
	if (PGNUM(pa) >= npages)
f0100cc6:	89 c2                	mov    %eax,%edx
f0100cc8:	c1 ea 0c             	shr    $0xc,%edx
f0100ccb:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0100cce:	3b 11                	cmp    (%ecx),%edx
f0100cd0:	73 c7                	jae    f0100c99 <mem_init+0x184>
			memset(page2kva(pp), 0x97, 128);
f0100cd2:	83 ec 04             	sub    $0x4,%esp
f0100cd5:	68 80 00 00 00       	push   $0x80
f0100cda:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0100cdf:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100ce4:	50                   	push   %eax
f0100ce5:	e8 38 0f 00 00       	call   f0101c22 <memset>
f0100cea:	83 c4 10             	add    $0x10,%esp
f0100ced:	eb c0                	jmp    f0100caf <mem_init+0x19a>
	if (!nextfree) {
f0100cef:	83 bb 50 02 00 00 00 	cmpl   $0x0,0x250(%ebx)
f0100cf6:	74 30                	je     f0100d28 <mem_init+0x213>

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100cf8:	8b 93 54 02 00 00    	mov    0x254(%ebx),%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100cfe:	c7 c0 d0 56 11 f0    	mov    $0xf01156d0,%eax
f0100d04:	8b 08                	mov    (%eax),%ecx
		assert(pp < pages + npages);
f0100d06:	c7 c0 c8 56 11 f0    	mov    $0xf01156c8,%eax
f0100d0c:	8b 30                	mov    (%eax),%esi
f0100d0e:	8d 04 f1             	lea    (%ecx,%esi,8),%eax
f0100d11:	89 45 d0             	mov    %eax,-0x30(%ebp)
	int nfree_basemem = 0, nfree_extmem = 0;
f0100d14:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f0100d1b:	bf 00 00 00 00       	mov    $0x0,%edi
f0100d20:	89 75 cc             	mov    %esi,-0x34(%ebp)
f0100d23:	e9 01 01 00 00       	jmp    f0100e29 <mem_init+0x314>
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100d28:	c7 c0 c0 56 11 f0    	mov    $0xf01156c0,%eax
f0100d2e:	05 ff 0f 00 00       	add    $0xfff,%eax
f0100d33:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100d38:	89 83 50 02 00 00    	mov    %eax,0x250(%ebx)
f0100d3e:	eb b8                	jmp    f0100cf8 <mem_init+0x1e3>
		assert(pp >= pages);
f0100d40:	8d 83 6e d6 fe ff    	lea    -0x12992(%ebx),%eax
f0100d46:	50                   	push   %eax
f0100d47:	8d 83 7a d6 fe ff    	lea    -0x12986(%ebx),%eax
f0100d4d:	50                   	push   %eax
f0100d4e:	68 dc 01 00 00       	push   $0x1dc
f0100d53:	8d 83 54 d6 fe ff    	lea    -0x129ac(%ebx),%eax
f0100d59:	50                   	push   %eax
f0100d5a:	e8 ac f3 ff ff       	call   f010010b <_panic>
		assert(pp < pages + npages);
f0100d5f:	8d 83 8f d6 fe ff    	lea    -0x12971(%ebx),%eax
f0100d65:	50                   	push   %eax
f0100d66:	8d 83 7a d6 fe ff    	lea    -0x12986(%ebx),%eax
f0100d6c:	50                   	push   %eax
f0100d6d:	68 dd 01 00 00       	push   $0x1dd
f0100d72:	8d 83 54 d6 fe ff    	lea    -0x129ac(%ebx),%eax
f0100d78:	50                   	push   %eax
f0100d79:	e8 8d f3 ff ff       	call   f010010b <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100d7e:	8d 83 d8 d5 fe ff    	lea    -0x12a28(%ebx),%eax
f0100d84:	50                   	push   %eax
f0100d85:	8d 83 7a d6 fe ff    	lea    -0x12986(%ebx),%eax
f0100d8b:	50                   	push   %eax
f0100d8c:	68 de 01 00 00       	push   $0x1de
f0100d91:	8d 83 54 d6 fe ff    	lea    -0x129ac(%ebx),%eax
f0100d97:	50                   	push   %eax
f0100d98:	e8 6e f3 ff ff       	call   f010010b <_panic>

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100d9d:	8d 83 a3 d6 fe ff    	lea    -0x1295d(%ebx),%eax
f0100da3:	50                   	push   %eax
f0100da4:	8d 83 7a d6 fe ff    	lea    -0x12986(%ebx),%eax
f0100daa:	50                   	push   %eax
f0100dab:	68 e1 01 00 00       	push   $0x1e1
f0100db0:	8d 83 54 d6 fe ff    	lea    -0x129ac(%ebx),%eax
f0100db6:	50                   	push   %eax
f0100db7:	e8 4f f3 ff ff       	call   f010010b <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100dbc:	8d 83 b4 d6 fe ff    	lea    -0x1294c(%ebx),%eax
f0100dc2:	50                   	push   %eax
f0100dc3:	8d 83 7a d6 fe ff    	lea    -0x12986(%ebx),%eax
f0100dc9:	50                   	push   %eax
f0100dca:	68 e2 01 00 00       	push   $0x1e2
f0100dcf:	8d 83 54 d6 fe ff    	lea    -0x129ac(%ebx),%eax
f0100dd5:	50                   	push   %eax
f0100dd6:	e8 30 f3 ff ff       	call   f010010b <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100ddb:	8d 83 0c d6 fe ff    	lea    -0x129f4(%ebx),%eax
f0100de1:	50                   	push   %eax
f0100de2:	8d 83 7a d6 fe ff    	lea    -0x12986(%ebx),%eax
f0100de8:	50                   	push   %eax
f0100de9:	68 e3 01 00 00       	push   $0x1e3
f0100dee:	8d 83 54 d6 fe ff    	lea    -0x129ac(%ebx),%eax
f0100df4:	50                   	push   %eax
f0100df5:	e8 11 f3 ff ff       	call   f010010b <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100dfa:	8d 83 cd d6 fe ff    	lea    -0x12933(%ebx),%eax
f0100e00:	50                   	push   %eax
f0100e01:	8d 83 7a d6 fe ff    	lea    -0x12986(%ebx),%eax
f0100e07:	50                   	push   %eax
f0100e08:	68 e4 01 00 00       	push   $0x1e4
f0100e0d:	8d 83 54 d6 fe ff    	lea    -0x129ac(%ebx),%eax
f0100e13:	50                   	push   %eax
f0100e14:	e8 f2 f2 ff ff       	call   f010010b <_panic>
	if (PGNUM(pa) >= npages)
f0100e19:	89 c6                	mov    %eax,%esi
f0100e1b:	c1 ee 0c             	shr    $0xc,%esi
f0100e1e:	39 75 cc             	cmp    %esi,-0x34(%ebp)
f0100e21:	76 5c                	jbe    f0100e7f <mem_init+0x36a>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
		else
			++nfree_extmem;
f0100e23:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100e27:	8b 12                	mov    (%edx),%edx
f0100e29:	85 d2                	test   %edx,%edx
f0100e2b:	74 68                	je     f0100e95 <mem_init+0x380>
		assert(pp >= pages);
f0100e2d:	39 d1                	cmp    %edx,%ecx
f0100e2f:	0f 87 0b ff ff ff    	ja     f0100d40 <mem_init+0x22b>
		assert(pp < pages + npages);
f0100e35:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f0100e38:	0f 83 21 ff ff ff    	jae    f0100d5f <mem_init+0x24a>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100e3e:	89 d0                	mov    %edx,%eax
f0100e40:	29 c8                	sub    %ecx,%eax
f0100e42:	a8 07                	test   $0x7,%al
f0100e44:	0f 85 34 ff ff ff    	jne    f0100d7e <mem_init+0x269>
	return (pp - pages) << PGSHIFT;
f0100e4a:	c1 f8 03             	sar    $0x3,%eax
		assert(page2pa(pp) != 0);
f0100e4d:	c1 e0 0c             	shl    $0xc,%eax
f0100e50:	0f 84 47 ff ff ff    	je     f0100d9d <mem_init+0x288>
		assert(page2pa(pp) != IOPHYSMEM);
f0100e56:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100e5b:	0f 84 5b ff ff ff    	je     f0100dbc <mem_init+0x2a7>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100e61:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100e66:	0f 84 6f ff ff ff    	je     f0100ddb <mem_init+0x2c6>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100e6c:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100e71:	74 87                	je     f0100dfa <mem_init+0x2e5>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100e73:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100e78:	77 9f                	ja     f0100e19 <mem_init+0x304>
			++nfree_basemem;
f0100e7a:	83 c7 01             	add    $0x1,%edi
f0100e7d:	eb a8                	jmp    f0100e27 <mem_init+0x312>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100e7f:	50                   	push   %eax
f0100e80:	8d 83 b4 d5 fe ff    	lea    -0x12a4c(%ebx),%eax
f0100e86:	50                   	push   %eax
f0100e87:	6a 52                	push   $0x52
f0100e89:	8d 83 60 d6 fe ff    	lea    -0x129a0(%ebx),%eax
f0100e8f:	50                   	push   %eax
f0100e90:	e8 76 f2 ff ff       	call   f010010b <_panic>
	}

	assert(nfree_basemem > 0);
f0100e95:	85 ff                	test   %edi,%edi
f0100e97:	7e 44                	jle    f0100edd <mem_init+0x3c8>
	assert(nfree_extmem > 0);
f0100e99:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0100e9d:	7e 5d                	jle    f0100efc <mem_init+0x3e7>

	cprintf("check_page_free_list() succeeded!\n");
f0100e9f:	83 ec 0c             	sub    $0xc,%esp
f0100ea2:	8d 83 30 d6 fe ff    	lea    -0x129d0(%ebx),%eax
f0100ea8:	50                   	push   %eax
f0100ea9:	e8 4f 01 00 00       	call   f0100ffd <cprintf>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f0100eae:	83 c4 10             	add    $0x10,%esp
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0100eb1:	8b 83 54 02 00 00    	mov    0x254(%ebx),%eax
	if (!pages)
f0100eb7:	c7 c2 d0 56 11 f0    	mov    $0xf01156d0,%edx
f0100ebd:	83 3a 00             	cmpl   $0x0,(%edx)
f0100ec0:	75 5b                	jne    f0100f1d <mem_init+0x408>
		panic("'pages' is a null pointer!");
f0100ec2:	83 ec 04             	sub    $0x4,%esp
f0100ec5:	8d 83 0a d7 fe ff    	lea    -0x128f6(%ebx),%eax
f0100ecb:	50                   	push   %eax
f0100ecc:	68 01 02 00 00       	push   $0x201
f0100ed1:	8d 83 54 d6 fe ff    	lea    -0x129ac(%ebx),%eax
f0100ed7:	50                   	push   %eax
f0100ed8:	e8 2e f2 ff ff       	call   f010010b <_panic>
	assert(nfree_basemem > 0);
f0100edd:	8d 83 e7 d6 fe ff    	lea    -0x12919(%ebx),%eax
f0100ee3:	50                   	push   %eax
f0100ee4:	8d 83 7a d6 fe ff    	lea    -0x12986(%ebx),%eax
f0100eea:	50                   	push   %eax
f0100eeb:	68 ed 01 00 00       	push   $0x1ed
f0100ef0:	8d 83 54 d6 fe ff    	lea    -0x129ac(%ebx),%eax
f0100ef6:	50                   	push   %eax
f0100ef7:	e8 0f f2 ff ff       	call   f010010b <_panic>
	assert(nfree_extmem > 0);
f0100efc:	8d 83 f9 d6 fe ff    	lea    -0x12907(%ebx),%eax
f0100f02:	50                   	push   %eax
f0100f03:	8d 83 7a d6 fe ff    	lea    -0x12986(%ebx),%eax
f0100f09:	50                   	push   %eax
f0100f0a:	68 ee 01 00 00       	push   $0x1ee
f0100f0f:	8d 83 54 d6 fe ff    	lea    -0x129ac(%ebx),%eax
f0100f15:	50                   	push   %eax
f0100f16:	e8 f0 f1 ff ff       	call   f010010b <_panic>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0100f1b:	8b 00                	mov    (%eax),%eax
f0100f1d:	85 c0                	test   %eax,%eax
f0100f1f:	75 fa                	jne    f0100f1b <mem_init+0x406>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0100f21:	8d 83 25 d7 fe ff    	lea    -0x128db(%ebx),%eax
f0100f27:	50                   	push   %eax
f0100f28:	8d 83 7a d6 fe ff    	lea    -0x12986(%ebx),%eax
f0100f2e:	50                   	push   %eax
f0100f2f:	68 09 02 00 00       	push   $0x209
f0100f34:	8d 83 54 d6 fe ff    	lea    -0x129ac(%ebx),%eax
f0100f3a:	50                   	push   %eax
f0100f3b:	e8 cb f1 ff ff       	call   f010010b <_panic>

f0100f40 <page_alloc>:
}
f0100f40:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f45:	c3                   	ret    

f0100f46 <page_free>:
}
f0100f46:	c3                   	ret    

f0100f47 <page_decref>:
{
f0100f47:	55                   	push   %ebp
f0100f48:	89 e5                	mov    %esp,%ebp
f0100f4a:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f0100f4d:	66 83 68 04 01       	subw   $0x1,0x4(%eax)
}
f0100f52:	5d                   	pop    %ebp
f0100f53:	c3                   	ret    

f0100f54 <pgdir_walk>:
}
f0100f54:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f59:	c3                   	ret    

f0100f5a <page_insert>:
}
f0100f5a:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f5f:	c3                   	ret    

f0100f60 <page_lookup>:
}
f0100f60:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f65:	c3                   	ret    

f0100f66 <page_remove>:
}
f0100f66:	c3                   	ret    

f0100f67 <tlb_invalidate>:
{
f0100f67:	55                   	push   %ebp
f0100f68:	89 e5                	mov    %esp,%ebp
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0100f6a:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100f6d:	0f 01 38             	invlpg (%eax)
}
f0100f70:	5d                   	pop    %ebp
f0100f71:	c3                   	ret    

f0100f72 <__x86.get_pc_thunk.si>:
f0100f72:	8b 34 24             	mov    (%esp),%esi
f0100f75:	c3                   	ret    

f0100f76 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0100f76:	55                   	push   %ebp
f0100f77:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100f79:	8b 45 08             	mov    0x8(%ebp),%eax
f0100f7c:	ba 70 00 00 00       	mov    $0x70,%edx
f0100f81:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100f82:	ba 71 00 00 00       	mov    $0x71,%edx
f0100f87:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0100f88:	0f b6 c0             	movzbl %al,%eax
}
f0100f8b:	5d                   	pop    %ebp
f0100f8c:	c3                   	ret    

f0100f8d <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0100f8d:	55                   	push   %ebp
f0100f8e:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100f90:	8b 45 08             	mov    0x8(%ebp),%eax
f0100f93:	ba 70 00 00 00       	mov    $0x70,%edx
f0100f98:	ee                   	out    %al,(%dx)
f0100f99:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100f9c:	ba 71 00 00 00       	mov    $0x71,%edx
f0100fa1:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0100fa2:	5d                   	pop    %ebp
f0100fa3:	c3                   	ret    

f0100fa4 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0100fa4:	55                   	push   %ebp
f0100fa5:	89 e5                	mov    %esp,%ebp
f0100fa7:	53                   	push   %ebx
f0100fa8:	83 ec 10             	sub    $0x10,%esp
f0100fab:	e8 11 f2 ff ff       	call   f01001c1 <__x86.get_pc_thunk.bx>
f0100fb0:	81 c3 b8 40 01 00    	add    $0x140b8,%ebx
	cputchar(ch);
f0100fb6:	ff 75 08             	pushl  0x8(%ebp)
f0100fb9:	e8 4d f7 ff ff       	call   f010070b <cputchar>
	*cnt++;
}
f0100fbe:	83 c4 10             	add    $0x10,%esp
f0100fc1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100fc4:	c9                   	leave  
f0100fc5:	c3                   	ret    

f0100fc6 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0100fc6:	55                   	push   %ebp
f0100fc7:	89 e5                	mov    %esp,%ebp
f0100fc9:	53                   	push   %ebx
f0100fca:	83 ec 14             	sub    $0x14,%esp
f0100fcd:	e8 ef f1 ff ff       	call   f01001c1 <__x86.get_pc_thunk.bx>
f0100fd2:	81 c3 96 40 01 00    	add    $0x14096,%ebx
	int cnt = 0;
f0100fd8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0100fdf:	ff 75 0c             	pushl  0xc(%ebp)
f0100fe2:	ff 75 08             	pushl  0x8(%ebp)
f0100fe5:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100fe8:	50                   	push   %eax
f0100fe9:	8d 83 3c bf fe ff    	lea    -0x140c4(%ebx),%eax
f0100fef:	50                   	push   %eax
f0100ff0:	e8 96 04 00 00       	call   f010148b <vprintfmt>
	return cnt;
}
f0100ff5:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100ff8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100ffb:	c9                   	leave  
f0100ffc:	c3                   	ret    

f0100ffd <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0100ffd:	55                   	push   %ebp
f0100ffe:	89 e5                	mov    %esp,%ebp
f0101000:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0101003:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0101006:	50                   	push   %eax
f0101007:	ff 75 08             	pushl  0x8(%ebp)
f010100a:	e8 b7 ff ff ff       	call   f0100fc6 <vcprintf>
	va_end(ap);

	return cnt;
}
f010100f:	c9                   	leave  
f0101010:	c3                   	ret    

f0101011 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0101011:	55                   	push   %ebp
f0101012:	89 e5                	mov    %esp,%ebp
f0101014:	57                   	push   %edi
f0101015:	56                   	push   %esi
f0101016:	53                   	push   %ebx
f0101017:	83 ec 14             	sub    $0x14,%esp
f010101a:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010101d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0101020:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0101023:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0101026:	8b 1a                	mov    (%edx),%ebx
f0101028:	8b 01                	mov    (%ecx),%eax
f010102a:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010102d:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0101034:	eb 23                	jmp    f0101059 <stab_binsearch+0x48>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0101036:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0101039:	eb 1e                	jmp    f0101059 <stab_binsearch+0x48>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f010103b:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010103e:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0101041:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0101045:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0101048:	73 41                	jae    f010108b <stab_binsearch+0x7a>
			*region_left = m;
f010104a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f010104d:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f010104f:	8d 5f 01             	lea    0x1(%edi),%ebx
		any_matches = 1;
f0101052:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0101059:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f010105c:	7f 5a                	jg     f01010b8 <stab_binsearch+0xa7>
		int true_m = (l + r) / 2, m = true_m;
f010105e:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0101061:	01 d8                	add    %ebx,%eax
f0101063:	89 c7                	mov    %eax,%edi
f0101065:	c1 ef 1f             	shr    $0x1f,%edi
f0101068:	01 c7                	add    %eax,%edi
f010106a:	d1 ff                	sar    %edi
f010106c:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f010106f:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0101072:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0101076:	89 f8                	mov    %edi,%eax
		while (m >= l && stabs[m].n_type != type)
f0101078:	39 c3                	cmp    %eax,%ebx
f010107a:	7f ba                	jg     f0101036 <stab_binsearch+0x25>
f010107c:	0f b6 0a             	movzbl (%edx),%ecx
f010107f:	83 ea 0c             	sub    $0xc,%edx
f0101082:	39 f1                	cmp    %esi,%ecx
f0101084:	74 b5                	je     f010103b <stab_binsearch+0x2a>
			m--;
f0101086:	83 e8 01             	sub    $0x1,%eax
f0101089:	eb ed                	jmp    f0101078 <stab_binsearch+0x67>
		} else if (stabs[m].n_value > addr) {
f010108b:	3b 55 0c             	cmp    0xc(%ebp),%edx
f010108e:	76 14                	jbe    f01010a4 <stab_binsearch+0x93>
			*region_right = m - 1;
f0101090:	83 e8 01             	sub    $0x1,%eax
f0101093:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0101096:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0101099:	89 07                	mov    %eax,(%edi)
		any_matches = 1;
f010109b:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01010a2:	eb b5                	jmp    f0101059 <stab_binsearch+0x48>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f01010a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01010a7:	89 07                	mov    %eax,(%edi)
			l = m;
			addr++;
f01010a9:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f01010ad:	89 c3                	mov    %eax,%ebx
		any_matches = 1;
f01010af:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01010b6:	eb a1                	jmp    f0101059 <stab_binsearch+0x48>
		}
	}

	if (!any_matches)
f01010b8:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f01010bc:	75 15                	jne    f01010d3 <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f01010be:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01010c1:	8b 00                	mov    (%eax),%eax
f01010c3:	83 e8 01             	sub    $0x1,%eax
f01010c6:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01010c9:	89 06                	mov    %eax,(%esi)
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f01010cb:	83 c4 14             	add    $0x14,%esp
f01010ce:	5b                   	pop    %ebx
f01010cf:	5e                   	pop    %esi
f01010d0:	5f                   	pop    %edi
f01010d1:	5d                   	pop    %ebp
f01010d2:	c3                   	ret    
		for (l = *region_right;
f01010d3:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01010d6:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f01010d8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01010db:	8b 0f                	mov    (%edi),%ecx
f01010dd:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01010e0:	8b 7d ec             	mov    -0x14(%ebp),%edi
f01010e3:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
		for (l = *region_right;
f01010e7:	eb 03                	jmp    f01010ec <stab_binsearch+0xdb>
		     l--)
f01010e9:	83 e8 01             	sub    $0x1,%eax
		for (l = *region_right;
f01010ec:	39 c1                	cmp    %eax,%ecx
f01010ee:	7d 0a                	jge    f01010fa <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f01010f0:	0f b6 1a             	movzbl (%edx),%ebx
f01010f3:	83 ea 0c             	sub    $0xc,%edx
f01010f6:	39 f3                	cmp    %esi,%ebx
f01010f8:	75 ef                	jne    f01010e9 <stab_binsearch+0xd8>
		*region_left = l;
f01010fa:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01010fd:	89 06                	mov    %eax,(%esi)
}
f01010ff:	eb ca                	jmp    f01010cb <stab_binsearch+0xba>

f0101101 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0101101:	55                   	push   %ebp
f0101102:	89 e5                	mov    %esp,%ebp
f0101104:	57                   	push   %edi
f0101105:	56                   	push   %esi
f0101106:	53                   	push   %ebx
f0101107:	83 ec 3c             	sub    $0x3c,%esp
f010110a:	e8 b2 f0 ff ff       	call   f01001c1 <__x86.get_pc_thunk.bx>
f010110f:	81 c3 59 3f 01 00    	add    $0x13f59,%ebx
f0101115:	89 5d bc             	mov    %ebx,-0x44(%ebp)
f0101118:	8b 7d 08             	mov    0x8(%ebp),%edi
f010111b:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f010111e:	8d 83 3b d7 fe ff    	lea    -0x128c5(%ebx),%eax
f0101124:	89 06                	mov    %eax,(%esi)
	info->eip_line = 0;
f0101126:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f010112d:	89 46 08             	mov    %eax,0x8(%esi)
	info->eip_fn_namelen = 9;
f0101130:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f0101137:	89 7e 10             	mov    %edi,0x10(%esi)
	info->eip_fn_narg = 0;
f010113a:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0101141:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0101147:	0f 86 42 01 00 00    	jbe    f010128f <debuginfo_eip+0x18e>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f010114d:	c7 c0 9d 7c 10 f0    	mov    $0xf0107c9d,%eax
f0101153:	39 83 fc ff ff ff    	cmp    %eax,-0x4(%ebx)
f0101159:	0f 86 04 02 00 00    	jbe    f0101363 <debuginfo_eip+0x262>
f010115f:	8b 5d bc             	mov    -0x44(%ebp),%ebx
f0101162:	c7 c0 c0 99 10 f0    	mov    $0xf01099c0,%eax
f0101168:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f010116c:	0f 85 f8 01 00 00    	jne    f010136a <debuginfo_eip+0x269>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0101172:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0101179:	c7 c0 bc 29 10 f0    	mov    $0xf01029bc,%eax
f010117f:	c7 c2 9c 7c 10 f0    	mov    $0xf0107c9c,%edx
f0101185:	29 c2                	sub    %eax,%edx
f0101187:	c1 fa 02             	sar    $0x2,%edx
f010118a:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0101190:	83 ea 01             	sub    $0x1,%edx
f0101193:	89 55 e0             	mov    %edx,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0101196:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0101199:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f010119c:	83 ec 08             	sub    $0x8,%esp
f010119f:	57                   	push   %edi
f01011a0:	6a 64                	push   $0x64
f01011a2:	e8 6a fe ff ff       	call   f0101011 <stab_binsearch>
	if (lfile == 0)
f01011a7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01011aa:	83 c4 10             	add    $0x10,%esp
f01011ad:	85 c0                	test   %eax,%eax
f01011af:	0f 84 bc 01 00 00    	je     f0101371 <debuginfo_eip+0x270>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f01011b5:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f01011b8:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01011bb:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f01011be:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f01011c1:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01011c4:	83 ec 08             	sub    $0x8,%esp
f01011c7:	57                   	push   %edi
f01011c8:	6a 24                	push   $0x24
f01011ca:	c7 c0 bc 29 10 f0    	mov    $0xf01029bc,%eax
f01011d0:	e8 3c fe ff ff       	call   f0101011 <stab_binsearch>

	if (lfun <= rfun) {
f01011d5:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01011d8:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f01011db:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
f01011de:	83 c4 10             	add    $0x10,%esp
f01011e1:	39 c8                	cmp    %ecx,%eax
f01011e3:	0f 8f c1 00 00 00    	jg     f01012aa <debuginfo_eip+0x1a9>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f01011e9:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01011ec:	c7 c1 bc 29 10 f0    	mov    $0xf01029bc,%ecx
f01011f2:	8d 0c 91             	lea    (%ecx,%edx,4),%ecx
f01011f5:	8b 11                	mov    (%ecx),%edx
f01011f7:	89 55 c0             	mov    %edx,-0x40(%ebp)
f01011fa:	c7 c2 c0 99 10 f0    	mov    $0xf01099c0,%edx
f0101200:	89 5d bc             	mov    %ebx,-0x44(%ebp)
f0101203:	81 ea 9d 7c 10 f0    	sub    $0xf0107c9d,%edx
f0101209:	8b 5d c0             	mov    -0x40(%ebp),%ebx
f010120c:	39 d3                	cmp    %edx,%ebx
f010120e:	73 0c                	jae    f010121c <debuginfo_eip+0x11b>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0101210:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0101213:	81 c3 9d 7c 10 f0    	add    $0xf0107c9d,%ebx
f0101219:	89 5e 08             	mov    %ebx,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f010121c:	8b 51 08             	mov    0x8(%ecx),%edx
f010121f:	89 56 10             	mov    %edx,0x10(%esi)
		addr -= info->eip_fn_addr;
f0101222:	29 d7                	sub    %edx,%edi
		// Search within the function definition for the line number.
		lline = lfun;
f0101224:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0101227:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f010122a:	89 45 d0             	mov    %eax,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f010122d:	83 ec 08             	sub    $0x8,%esp
f0101230:	6a 3a                	push   $0x3a
f0101232:	ff 76 08             	pushl  0x8(%esi)
f0101235:	8b 5d bc             	mov    -0x44(%ebp),%ebx
f0101238:	e8 c9 09 00 00       	call   f0101c06 <strfind>
f010123d:	2b 46 08             	sub    0x8(%esi),%eax
f0101240:	89 46 0c             	mov    %eax,0xc(%esi)
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0101243:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0101246:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0101249:	83 c4 08             	add    $0x8,%esp
f010124c:	57                   	push   %edi
f010124d:	6a 44                	push   $0x44
f010124f:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0101252:	c7 c0 bc 29 10 f0    	mov    $0xf01029bc,%eax
f0101258:	e8 b4 fd ff ff       	call   f0101011 <stab_binsearch>
	if (lline <= rline) {
f010125d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101260:	83 c4 10             	add    $0x10,%esp
f0101263:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f0101266:	0f 8f 0c 01 00 00    	jg     f0101378 <debuginfo_eip+0x277>
		 info->eip_line = stabs[lline].n_desc;
f010126c:	89 d0                	mov    %edx,%eax
f010126e:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0101271:	c1 e2 02             	shl    $0x2,%edx
f0101274:	c7 c1 bc 29 10 f0    	mov    $0xf01029bc,%ecx
f010127a:	0f b7 5c 0a 06       	movzwl 0x6(%edx,%ecx,1),%ebx
f010127f:	89 5e 04             	mov    %ebx,0x4(%esi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0101282:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0101285:	8d 54 0a 04          	lea    0x4(%edx,%ecx,1),%edx
f0101289:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f010128d:	eb 39                	jmp    f01012c8 <debuginfo_eip+0x1c7>
  	        panic("User address");
f010128f:	83 ec 04             	sub    $0x4,%esp
f0101292:	8b 5d bc             	mov    -0x44(%ebp),%ebx
f0101295:	8d 83 45 d7 fe ff    	lea    -0x128bb(%ebx),%eax
f010129b:	50                   	push   %eax
f010129c:	6a 7f                	push   $0x7f
f010129e:	8d 83 52 d7 fe ff    	lea    -0x128ae(%ebx),%eax
f01012a4:	50                   	push   %eax
f01012a5:	e8 61 ee ff ff       	call   f010010b <_panic>
		info->eip_fn_addr = addr;
f01012aa:	89 7e 10             	mov    %edi,0x10(%esi)
		lline = lfile;
f01012ad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01012b0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f01012b3:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01012b6:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01012b9:	e9 6f ff ff ff       	jmp    f010122d <debuginfo_eip+0x12c>
f01012be:	83 e8 01             	sub    $0x1,%eax
f01012c1:	83 ea 0c             	sub    $0xc,%edx
f01012c4:	c6 45 c4 01          	movb   $0x1,-0x3c(%ebp)
f01012c8:	89 45 c0             	mov    %eax,-0x40(%ebp)
	while (lline >= lfile
f01012cb:	39 c7                	cmp    %eax,%edi
f01012cd:	7f 51                	jg     f0101320 <debuginfo_eip+0x21f>
	       && stabs[lline].n_type != N_SOL
f01012cf:	0f b6 0a             	movzbl (%edx),%ecx
f01012d2:	80 f9 84             	cmp    $0x84,%cl
f01012d5:	74 19                	je     f01012f0 <debuginfo_eip+0x1ef>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01012d7:	80 f9 64             	cmp    $0x64,%cl
f01012da:	75 e2                	jne    f01012be <debuginfo_eip+0x1bd>
f01012dc:	83 7a 04 00          	cmpl   $0x0,0x4(%edx)
f01012e0:	74 dc                	je     f01012be <debuginfo_eip+0x1bd>
f01012e2:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f01012e6:	74 11                	je     f01012f9 <debuginfo_eip+0x1f8>
f01012e8:	8b 7d c0             	mov    -0x40(%ebp),%edi
f01012eb:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f01012ee:	eb 09                	jmp    f01012f9 <debuginfo_eip+0x1f8>
f01012f0:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f01012f4:	74 03                	je     f01012f9 <debuginfo_eip+0x1f8>
f01012f6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f01012f9:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01012fc:	8b 7d bc             	mov    -0x44(%ebp),%edi
f01012ff:	c7 c0 bc 29 10 f0    	mov    $0xf01029bc,%eax
f0101305:	8b 14 90             	mov    (%eax,%edx,4),%edx
f0101308:	c7 c0 c0 99 10 f0    	mov    $0xf01099c0,%eax
f010130e:	81 e8 9d 7c 10 f0    	sub    $0xf0107c9d,%eax
f0101314:	39 c2                	cmp    %eax,%edx
f0101316:	73 08                	jae    f0101320 <debuginfo_eip+0x21f>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0101318:	81 c2 9d 7c 10 f0    	add    $0xf0107c9d,%edx
f010131e:	89 16                	mov    %edx,(%esi)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0101320:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0101323:	8b 5d d8             	mov    -0x28(%ebp),%ebx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0101326:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f010132b:	39 da                	cmp    %ebx,%edx
f010132d:	7d 55                	jge    f0101384 <debuginfo_eip+0x283>
		for (lline = lfun + 1;
f010132f:	83 c2 01             	add    $0x1,%edx
f0101332:	89 d0                	mov    %edx,%eax
f0101334:	8d 0c 52             	lea    (%edx,%edx,2),%ecx
f0101337:	8b 7d bc             	mov    -0x44(%ebp),%edi
f010133a:	c7 c2 bc 29 10 f0    	mov    $0xf01029bc,%edx
f0101340:	8d 54 8a 04          	lea    0x4(%edx,%ecx,4),%edx
f0101344:	eb 04                	jmp    f010134a <debuginfo_eip+0x249>
			info->eip_fn_narg++;
f0101346:	83 46 14 01          	addl   $0x1,0x14(%esi)
		for (lline = lfun + 1;
f010134a:	39 c3                	cmp    %eax,%ebx
f010134c:	7e 31                	jle    f010137f <debuginfo_eip+0x27e>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f010134e:	0f b6 0a             	movzbl (%edx),%ecx
f0101351:	83 c0 01             	add    $0x1,%eax
f0101354:	83 c2 0c             	add    $0xc,%edx
f0101357:	80 f9 a0             	cmp    $0xa0,%cl
f010135a:	74 ea                	je     f0101346 <debuginfo_eip+0x245>
	return 0;
f010135c:	b8 00 00 00 00       	mov    $0x0,%eax
f0101361:	eb 21                	jmp    f0101384 <debuginfo_eip+0x283>
		return -1;
f0101363:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0101368:	eb 1a                	jmp    f0101384 <debuginfo_eip+0x283>
f010136a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010136f:	eb 13                	jmp    f0101384 <debuginfo_eip+0x283>
		return -1;
f0101371:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0101376:	eb 0c                	jmp    f0101384 <debuginfo_eip+0x283>
		 return -1;
f0101378:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010137d:	eb 05                	jmp    f0101384 <debuginfo_eip+0x283>
	return 0;
f010137f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101384:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101387:	5b                   	pop    %ebx
f0101388:	5e                   	pop    %esi
f0101389:	5f                   	pop    %edi
f010138a:	5d                   	pop    %ebp
f010138b:	c3                   	ret    

f010138c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f010138c:	55                   	push   %ebp
f010138d:	89 e5                	mov    %esp,%ebp
f010138f:	57                   	push   %edi
f0101390:	56                   	push   %esi
f0101391:	53                   	push   %ebx
f0101392:	83 ec 2c             	sub    $0x2c,%esp
f0101395:	e8 08 06 00 00       	call   f01019a2 <__x86.get_pc_thunk.cx>
f010139a:	81 c1 ce 3c 01 00    	add    $0x13cce,%ecx
f01013a0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f01013a3:	89 c7                	mov    %eax,%edi
f01013a5:	89 d6                	mov    %edx,%esi
f01013a7:	8b 45 08             	mov    0x8(%ebp),%eax
f01013aa:	8b 55 0c             	mov    0xc(%ebp),%edx
f01013ad:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01013b0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f01013b3:	8b 4d 10             	mov    0x10(%ebp),%ecx
f01013b6:	bb 00 00 00 00       	mov    $0x0,%ebx
f01013bb:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01013be:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f01013c1:	3b 45 10             	cmp    0x10(%ebp),%eax
f01013c4:	89 d0                	mov    %edx,%eax
f01013c6:	1b 45 e4             	sbb    -0x1c(%ebp),%eax
f01013c9:	8b 5d 14             	mov    0x14(%ebp),%ebx
f01013cc:	73 15                	jae    f01013e3 <printnum+0x57>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f01013ce:	83 eb 01             	sub    $0x1,%ebx
f01013d1:	85 db                	test   %ebx,%ebx
f01013d3:	7e 46                	jle    f010141b <printnum+0x8f>
			putch(padc, putdat);
f01013d5:	83 ec 08             	sub    $0x8,%esp
f01013d8:	56                   	push   %esi
f01013d9:	ff 75 18             	pushl  0x18(%ebp)
f01013dc:	ff d7                	call   *%edi
f01013de:	83 c4 10             	add    $0x10,%esp
f01013e1:	eb eb                	jmp    f01013ce <printnum+0x42>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f01013e3:	83 ec 0c             	sub    $0xc,%esp
f01013e6:	ff 75 18             	pushl  0x18(%ebp)
f01013e9:	8b 45 14             	mov    0x14(%ebp),%eax
f01013ec:	8d 58 ff             	lea    -0x1(%eax),%ebx
f01013ef:	53                   	push   %ebx
f01013f0:	ff 75 10             	pushl  0x10(%ebp)
f01013f3:	83 ec 08             	sub    $0x8,%esp
f01013f6:	ff 75 e4             	pushl  -0x1c(%ebp)
f01013f9:	ff 75 e0             	pushl  -0x20(%ebp)
f01013fc:	ff 75 d4             	pushl  -0x2c(%ebp)
f01013ff:	ff 75 d0             	pushl  -0x30(%ebp)
f0101402:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0101405:	e8 16 0a 00 00       	call   f0101e20 <__udivdi3>
f010140a:	83 c4 18             	add    $0x18,%esp
f010140d:	52                   	push   %edx
f010140e:	50                   	push   %eax
f010140f:	89 f2                	mov    %esi,%edx
f0101411:	89 f8                	mov    %edi,%eax
f0101413:	e8 74 ff ff ff       	call   f010138c <printnum>
f0101418:	83 c4 20             	add    $0x20,%esp
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f010141b:	83 ec 08             	sub    $0x8,%esp
f010141e:	56                   	push   %esi
f010141f:	83 ec 04             	sub    $0x4,%esp
f0101422:	ff 75 e4             	pushl  -0x1c(%ebp)
f0101425:	ff 75 e0             	pushl  -0x20(%ebp)
f0101428:	ff 75 d4             	pushl  -0x2c(%ebp)
f010142b:	ff 75 d0             	pushl  -0x30(%ebp)
f010142e:	8b 75 dc             	mov    -0x24(%ebp),%esi
f0101431:	89 f3                	mov    %esi,%ebx
f0101433:	e8 f8 0a 00 00       	call   f0101f30 <__umoddi3>
f0101438:	83 c4 14             	add    $0x14,%esp
f010143b:	0f be 84 06 60 d7 fe 	movsbl -0x128a0(%esi,%eax,1),%eax
f0101442:	ff 
f0101443:	50                   	push   %eax
f0101444:	ff d7                	call   *%edi
}
f0101446:	83 c4 10             	add    $0x10,%esp
f0101449:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010144c:	5b                   	pop    %ebx
f010144d:	5e                   	pop    %esi
f010144e:	5f                   	pop    %edi
f010144f:	5d                   	pop    %ebp
f0101450:	c3                   	ret    

f0101451 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0101451:	55                   	push   %ebp
f0101452:	89 e5                	mov    %esp,%ebp
f0101454:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0101457:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f010145b:	8b 10                	mov    (%eax),%edx
f010145d:	3b 50 04             	cmp    0x4(%eax),%edx
f0101460:	73 0a                	jae    f010146c <sprintputch+0x1b>
		*b->buf++ = ch;
f0101462:	8d 4a 01             	lea    0x1(%edx),%ecx
f0101465:	89 08                	mov    %ecx,(%eax)
f0101467:	8b 45 08             	mov    0x8(%ebp),%eax
f010146a:	88 02                	mov    %al,(%edx)
}
f010146c:	5d                   	pop    %ebp
f010146d:	c3                   	ret    

f010146e <printfmt>:
{
f010146e:	55                   	push   %ebp
f010146f:	89 e5                	mov    %esp,%ebp
f0101471:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f0101474:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0101477:	50                   	push   %eax
f0101478:	ff 75 10             	pushl  0x10(%ebp)
f010147b:	ff 75 0c             	pushl  0xc(%ebp)
f010147e:	ff 75 08             	pushl  0x8(%ebp)
f0101481:	e8 05 00 00 00       	call   f010148b <vprintfmt>
}
f0101486:	83 c4 10             	add    $0x10,%esp
f0101489:	c9                   	leave  
f010148a:	c3                   	ret    

f010148b <vprintfmt>:
{
f010148b:	55                   	push   %ebp
f010148c:	89 e5                	mov    %esp,%ebp
f010148e:	57                   	push   %edi
f010148f:	56                   	push   %esi
f0101490:	53                   	push   %ebx
f0101491:	83 ec 3c             	sub    $0x3c,%esp
f0101494:	e8 99 f2 ff ff       	call   f0100732 <__x86.get_pc_thunk.ax>
f0101499:	05 cf 3b 01 00       	add    $0x13bcf,%eax
f010149e:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01014a1:	8b 75 08             	mov    0x8(%ebp),%esi
f01014a4:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01014a7:	8b 5d 10             	mov    0x10(%ebp),%ebx
f01014aa:	eb 0a                	jmp    f01014b6 <vprintfmt+0x2b>
			putch(ch, putdat);
f01014ac:	83 ec 08             	sub    $0x8,%esp
f01014af:	57                   	push   %edi
f01014b0:	50                   	push   %eax
f01014b1:	ff d6                	call   *%esi
f01014b3:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01014b6:	83 c3 01             	add    $0x1,%ebx
f01014b9:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
f01014bd:	83 f8 25             	cmp    $0x25,%eax
f01014c0:	74 0c                	je     f01014ce <vprintfmt+0x43>
			if (ch == '\0')
f01014c2:	85 c0                	test   %eax,%eax
f01014c4:	75 e6                	jne    f01014ac <vprintfmt+0x21>
}
f01014c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01014c9:	5b                   	pop    %ebx
f01014ca:	5e                   	pop    %esi
f01014cb:	5f                   	pop    %edi
f01014cc:	5d                   	pop    %ebp
f01014cd:	c3                   	ret    
		padc = ' ';
f01014ce:	c6 45 cf 20          	movb   $0x20,-0x31(%ebp)
		altflag = 0;
f01014d2:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
		precision = -1;//精度
f01014d9:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;//总宽度
f01014e0:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		lflag = 0;
f01014e7:	b9 00 00 00 00       	mov    $0x0,%ecx
f01014ec:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f01014ef:	89 75 08             	mov    %esi,0x8(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01014f2:	8d 43 01             	lea    0x1(%ebx),%eax
f01014f5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01014f8:	0f b6 13             	movzbl (%ebx),%edx
f01014fb:	8d 42 dd             	lea    -0x23(%edx),%eax
f01014fe:	3c 55                	cmp    $0x55,%al
f0101500:	0f 87 00 04 00 00    	ja     f0101906 <.L21>
f0101506:	0f b6 c0             	movzbl %al,%eax
f0101509:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f010150c:	89 ce                	mov    %ecx,%esi
f010150e:	03 b4 81 ec d7 fe ff 	add    -0x12814(%ecx,%eax,4),%esi
f0101515:	ff e6                	jmp    *%esi

f0101517 <.L68>:
f0101517:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
f010151a:	c6 45 cf 2d          	movb   $0x2d,-0x31(%ebp)
f010151e:	eb d2                	jmp    f01014f2 <vprintfmt+0x67>

f0101520 <.L33>:
		switch (ch = *(unsigned char *) fmt++) {
f0101520:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '0';
f0101523:	c6 45 cf 30          	movb   $0x30,-0x31(%ebp)
f0101527:	eb c9                	jmp    f01014f2 <vprintfmt+0x67>

f0101529 <.L32>:
		switch (ch = *(unsigned char *) fmt++) {
f0101529:	0f b6 d2             	movzbl %dl,%edx
f010152c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {//依次读取数据宽度
f010152f:	b8 00 00 00 00       	mov    $0x0,%eax
f0101534:	8b 75 08             	mov    0x8(%ebp),%esi
				precision = precision * 10 + ch - '0';
f0101537:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010153a:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f010153e:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
f0101541:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0101544:	83 f9 09             	cmp    $0x9,%ecx
f0101547:	77 58                	ja     f01015a1 <.L37+0xf>
			for (precision = 0; ; ++fmt) {//依次读取数据宽度
f0101549:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
f010154c:	eb e9                	jmp    f0101537 <.L32+0xe>

f010154e <.L35>:
			precision = va_arg(ap, int);
f010154e:	8b 45 14             	mov    0x14(%ebp),%eax
f0101551:	8b 00                	mov    (%eax),%eax
f0101553:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101556:	8b 45 14             	mov    0x14(%ebp),%eax
f0101559:	8d 40 04             	lea    0x4(%eax),%eax
f010155c:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f010155f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
f0101562:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0101566:	79 8a                	jns    f01014f2 <vprintfmt+0x67>
				width = precision, precision = -1;
f0101568:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010156b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010156e:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
f0101575:	e9 78 ff ff ff       	jmp    f01014f2 <vprintfmt+0x67>

f010157a <.L34>:
f010157a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010157d:	85 c0                	test   %eax,%eax
f010157f:	ba 00 00 00 00       	mov    $0x0,%edx
f0101584:	0f 49 d0             	cmovns %eax,%edx
f0101587:	89 55 d4             	mov    %edx,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f010158a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f010158d:	e9 60 ff ff ff       	jmp    f01014f2 <vprintfmt+0x67>

f0101592 <.L37>:
f0101592:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
f0101595:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
f010159c:	e9 51 ff ff ff       	jmp    f01014f2 <vprintfmt+0x67>
f01015a1:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01015a4:	89 75 08             	mov    %esi,0x8(%ebp)
f01015a7:	eb b9                	jmp    f0101562 <.L35+0x14>

f01015a9 <.L28>:
			lflag++;
f01015a9:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01015ad:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
f01015b0:	e9 3d ff ff ff       	jmp    f01014f2 <vprintfmt+0x67>

f01015b5 <.L31>:
f01015b5:	8b 75 08             	mov    0x8(%ebp),%esi
			putch(va_arg(ap, int), putdat);
f01015b8:	8b 45 14             	mov    0x14(%ebp),%eax
f01015bb:	8d 58 04             	lea    0x4(%eax),%ebx
f01015be:	83 ec 08             	sub    $0x8,%esp
f01015c1:	57                   	push   %edi
f01015c2:	ff 30                	pushl  (%eax)
f01015c4:	ff d6                	call   *%esi
			break;
f01015c6:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f01015c9:	89 5d 14             	mov    %ebx,0x14(%ebp)
			break;
f01015cc:	e9 cb 02 00 00       	jmp    f010189c <.L26+0x45>

f01015d1 <.L29>:
f01015d1:	8b 75 08             	mov    0x8(%ebp),%esi
			err = va_arg(ap, int);
f01015d4:	8b 45 14             	mov    0x14(%ebp),%eax
f01015d7:	8d 58 04             	lea    0x4(%eax),%ebx
f01015da:	8b 00                	mov    (%eax),%eax
f01015dc:	99                   	cltd   
f01015dd:	31 d0                	xor    %edx,%eax
f01015df:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01015e1:	83 f8 06             	cmp    $0x6,%eax
f01015e4:	7f 2b                	jg     f0101611 <.L29+0x40>
f01015e6:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01015e9:	8b 94 82 dc ff ff ff 	mov    -0x24(%edx,%eax,4),%edx
f01015f0:	85 d2                	test   %edx,%edx
f01015f2:	74 1d                	je     f0101611 <.L29+0x40>
				printfmt(putch, putdat, "%s", p);
f01015f4:	52                   	push   %edx
f01015f5:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01015f8:	8d 80 8c d6 fe ff    	lea    -0x12974(%eax),%eax
f01015fe:	50                   	push   %eax
f01015ff:	57                   	push   %edi
f0101600:	56                   	push   %esi
f0101601:	e8 68 fe ff ff       	call   f010146e <printfmt>
f0101606:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0101609:	89 5d 14             	mov    %ebx,0x14(%ebp)
f010160c:	e9 8b 02 00 00       	jmp    f010189c <.L26+0x45>
				printfmt(putch, putdat, "error %d", err);
f0101611:	50                   	push   %eax
f0101612:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101615:	8d 80 78 d7 fe ff    	lea    -0x12888(%eax),%eax
f010161b:	50                   	push   %eax
f010161c:	57                   	push   %edi
f010161d:	56                   	push   %esi
f010161e:	e8 4b fe ff ff       	call   f010146e <printfmt>
f0101623:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0101626:	89 5d 14             	mov    %ebx,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f0101629:	e9 6e 02 00 00       	jmp    f010189c <.L26+0x45>

f010162e <.L25>:
f010162e:	8b 75 08             	mov    0x8(%ebp),%esi
			if ((p = va_arg(ap, char *)) == NULL)
f0101631:	8b 45 14             	mov    0x14(%ebp),%eax
f0101634:	83 c0 04             	add    $0x4,%eax
f0101637:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f010163a:	8b 45 14             	mov    0x14(%ebp),%eax
f010163d:	8b 10                	mov    (%eax),%edx
				p = "(null)";
f010163f:	85 d2                	test   %edx,%edx
f0101641:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101644:	8d 80 71 d7 fe ff    	lea    -0x1288f(%eax),%eax
f010164a:	0f 45 c2             	cmovne %edx,%eax
f010164d:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
f0101650:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0101654:	7e 06                	jle    f010165c <.L25+0x2e>
f0101656:	80 7d cf 2d          	cmpb   $0x2d,-0x31(%ebp)
f010165a:	75 0d                	jne    f0101669 <.L25+0x3b>
				for (width -= strnlen(p, precision); width > 0; width--)
f010165c:	8b 45 c8             	mov    -0x38(%ebp),%eax
f010165f:	89 c3                	mov    %eax,%ebx
f0101661:	03 45 d4             	add    -0x2c(%ebp),%eax
f0101664:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101667:	eb 42                	jmp    f01016ab <.L25+0x7d>
f0101669:	83 ec 08             	sub    $0x8,%esp
f010166c:	ff 75 d8             	pushl  -0x28(%ebp)
f010166f:	50                   	push   %eax
f0101670:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0101673:	e8 43 04 00 00       	call   f0101abb <strnlen>
f0101678:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f010167b:	29 c2                	sub    %eax,%edx
f010167d:	89 55 c0             	mov    %edx,-0x40(%ebp)
f0101680:	83 c4 10             	add    $0x10,%esp
f0101683:	89 d3                	mov    %edx,%ebx
					putch(padc, putdat);
f0101685:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
f0101689:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f010168c:	85 db                	test   %ebx,%ebx
f010168e:	7e 58                	jle    f01016e8 <.L25+0xba>
					putch(padc, putdat);
f0101690:	83 ec 08             	sub    $0x8,%esp
f0101693:	57                   	push   %edi
f0101694:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101697:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f0101699:	83 eb 01             	sub    $0x1,%ebx
f010169c:	83 c4 10             	add    $0x10,%esp
f010169f:	eb eb                	jmp    f010168c <.L25+0x5e>
					putch(ch, putdat);
f01016a1:	83 ec 08             	sub    $0x8,%esp
f01016a4:	57                   	push   %edi
f01016a5:	52                   	push   %edx
f01016a6:	ff d6                	call   *%esi
f01016a8:	83 c4 10             	add    $0x10,%esp
f01016ab:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01016ae:	29 d9                	sub    %ebx,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01016b0:	83 c3 01             	add    $0x1,%ebx
f01016b3:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
f01016b7:	0f be d0             	movsbl %al,%edx
f01016ba:	85 d2                	test   %edx,%edx
f01016bc:	74 45                	je     f0101703 <.L25+0xd5>
f01016be:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f01016c2:	78 06                	js     f01016ca <.L25+0x9c>
f01016c4:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
f01016c8:	78 35                	js     f01016ff <.L25+0xd1>
				if (altflag && (ch < ' ' || ch > '~'))
f01016ca:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f01016ce:	74 d1                	je     f01016a1 <.L25+0x73>
f01016d0:	0f be c0             	movsbl %al,%eax
f01016d3:	83 e8 20             	sub    $0x20,%eax
f01016d6:	83 f8 5e             	cmp    $0x5e,%eax
f01016d9:	76 c6                	jbe    f01016a1 <.L25+0x73>
					putch('?', putdat);
f01016db:	83 ec 08             	sub    $0x8,%esp
f01016de:	57                   	push   %edi
f01016df:	6a 3f                	push   $0x3f
f01016e1:	ff d6                	call   *%esi
f01016e3:	83 c4 10             	add    $0x10,%esp
f01016e6:	eb c3                	jmp    f01016ab <.L25+0x7d>
f01016e8:	8b 55 c0             	mov    -0x40(%ebp),%edx
f01016eb:	85 d2                	test   %edx,%edx
f01016ed:	b8 00 00 00 00       	mov    $0x0,%eax
f01016f2:	0f 49 c2             	cmovns %edx,%eax
f01016f5:	29 c2                	sub    %eax,%edx
f01016f7:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f01016fa:	e9 5d ff ff ff       	jmp    f010165c <.L25+0x2e>
f01016ff:	89 cb                	mov    %ecx,%ebx
f0101701:	eb 02                	jmp    f0101705 <.L25+0xd7>
f0101703:	89 cb                	mov    %ecx,%ebx
			for (; width > 0; width--)
f0101705:	85 db                	test   %ebx,%ebx
f0101707:	7e 10                	jle    f0101719 <.L25+0xeb>
				putch(' ', putdat);
f0101709:	83 ec 08             	sub    $0x8,%esp
f010170c:	57                   	push   %edi
f010170d:	6a 20                	push   $0x20
f010170f:	ff d6                	call   *%esi
			for (; width > 0; width--)
f0101711:	83 eb 01             	sub    $0x1,%ebx
f0101714:	83 c4 10             	add    $0x10,%esp
f0101717:	eb ec                	jmp    f0101705 <.L25+0xd7>
			if ((p = va_arg(ap, char *)) == NULL)
f0101719:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f010171c:	89 45 14             	mov    %eax,0x14(%ebp)
f010171f:	e9 78 01 00 00       	jmp    f010189c <.L26+0x45>

f0101724 <.L30>:
f0101724:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0101727:	8b 75 08             	mov    0x8(%ebp),%esi
	if (lflag >= 2)
f010172a:	83 f9 01             	cmp    $0x1,%ecx
f010172d:	7f 1b                	jg     f010174a <.L30+0x26>
	else if (lflag)
f010172f:	85 c9                	test   %ecx,%ecx
f0101731:	74 63                	je     f0101796 <.L30+0x72>
		return va_arg(*ap, long);
f0101733:	8b 45 14             	mov    0x14(%ebp),%eax
f0101736:	8b 00                	mov    (%eax),%eax
f0101738:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010173b:	99                   	cltd   
f010173c:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010173f:	8b 45 14             	mov    0x14(%ebp),%eax
f0101742:	8d 40 04             	lea    0x4(%eax),%eax
f0101745:	89 45 14             	mov    %eax,0x14(%ebp)
f0101748:	eb 17                	jmp    f0101761 <.L30+0x3d>
		return va_arg(*ap, long long);
f010174a:	8b 45 14             	mov    0x14(%ebp),%eax
f010174d:	8b 50 04             	mov    0x4(%eax),%edx
f0101750:	8b 00                	mov    (%eax),%eax
f0101752:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101755:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0101758:	8b 45 14             	mov    0x14(%ebp),%eax
f010175b:	8d 40 08             	lea    0x8(%eax),%eax
f010175e:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f0101761:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0101764:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f0101767:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
f010176c:	85 c9                	test   %ecx,%ecx
f010176e:	0f 89 0e 01 00 00    	jns    f0101882 <.L26+0x2b>
				putch('-', putdat);
f0101774:	83 ec 08             	sub    $0x8,%esp
f0101777:	57                   	push   %edi
f0101778:	6a 2d                	push   $0x2d
f010177a:	ff d6                	call   *%esi
				num = -(long long) num;
f010177c:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010177f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0101782:	f7 da                	neg    %edx
f0101784:	83 d1 00             	adc    $0x0,%ecx
f0101787:	f7 d9                	neg    %ecx
f0101789:	83 c4 10             	add    $0x10,%esp
			base = 10;
f010178c:	b8 0a 00 00 00       	mov    $0xa,%eax
f0101791:	e9 ec 00 00 00       	jmp    f0101882 <.L26+0x2b>
		return va_arg(*ap, int);
f0101796:	8b 45 14             	mov    0x14(%ebp),%eax
f0101799:	8b 00                	mov    (%eax),%eax
f010179b:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010179e:	99                   	cltd   
f010179f:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01017a2:	8b 45 14             	mov    0x14(%ebp),%eax
f01017a5:	8d 40 04             	lea    0x4(%eax),%eax
f01017a8:	89 45 14             	mov    %eax,0x14(%ebp)
f01017ab:	eb b4                	jmp    f0101761 <.L30+0x3d>

f01017ad <.L24>:
f01017ad:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f01017b0:	8b 75 08             	mov    0x8(%ebp),%esi
	if (lflag >= 2)
f01017b3:	83 f9 01             	cmp    $0x1,%ecx
f01017b6:	7f 1e                	jg     f01017d6 <.L24+0x29>
	else if (lflag)
f01017b8:	85 c9                	test   %ecx,%ecx
f01017ba:	74 32                	je     f01017ee <.L24+0x41>
		return va_arg(*ap, unsigned long);
f01017bc:	8b 45 14             	mov    0x14(%ebp),%eax
f01017bf:	8b 10                	mov    (%eax),%edx
f01017c1:	b9 00 00 00 00       	mov    $0x0,%ecx
f01017c6:	8d 40 04             	lea    0x4(%eax),%eax
f01017c9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01017cc:	b8 0a 00 00 00       	mov    $0xa,%eax
f01017d1:	e9 ac 00 00 00       	jmp    f0101882 <.L26+0x2b>
		return va_arg(*ap, unsigned long long);
f01017d6:	8b 45 14             	mov    0x14(%ebp),%eax
f01017d9:	8b 10                	mov    (%eax),%edx
f01017db:	8b 48 04             	mov    0x4(%eax),%ecx
f01017de:	8d 40 08             	lea    0x8(%eax),%eax
f01017e1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01017e4:	b8 0a 00 00 00       	mov    $0xa,%eax
f01017e9:	e9 94 00 00 00       	jmp    f0101882 <.L26+0x2b>
		return va_arg(*ap, unsigned int);
f01017ee:	8b 45 14             	mov    0x14(%ebp),%eax
f01017f1:	8b 10                	mov    (%eax),%edx
f01017f3:	b9 00 00 00 00       	mov    $0x0,%ecx
f01017f8:	8d 40 04             	lea    0x4(%eax),%eax
f01017fb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01017fe:	b8 0a 00 00 00       	mov    $0xa,%eax
f0101803:	eb 7d                	jmp    f0101882 <.L26+0x2b>

f0101805 <.L27>:
f0101805:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0101808:	8b 75 08             	mov    0x8(%ebp),%esi
	if (lflag >= 2)
f010180b:	83 f9 01             	cmp    $0x1,%ecx
f010180e:	7f 1b                	jg     f010182b <.L27+0x26>
	else if (lflag)
f0101810:	85 c9                	test   %ecx,%ecx
f0101812:	74 2c                	je     f0101840 <.L27+0x3b>
		return va_arg(*ap, unsigned long);
f0101814:	8b 45 14             	mov    0x14(%ebp),%eax
f0101817:	8b 10                	mov    (%eax),%edx
f0101819:	b9 00 00 00 00       	mov    $0x0,%ecx
f010181e:	8d 40 04             	lea    0x4(%eax),%eax
f0101821:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0101824:	b8 08 00 00 00       	mov    $0x8,%eax
f0101829:	eb 57                	jmp    f0101882 <.L26+0x2b>
		return va_arg(*ap, unsigned long long);
f010182b:	8b 45 14             	mov    0x14(%ebp),%eax
f010182e:	8b 10                	mov    (%eax),%edx
f0101830:	8b 48 04             	mov    0x4(%eax),%ecx
f0101833:	8d 40 08             	lea    0x8(%eax),%eax
f0101836:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0101839:	b8 08 00 00 00       	mov    $0x8,%eax
f010183e:	eb 42                	jmp    f0101882 <.L26+0x2b>
		return va_arg(*ap, unsigned int);
f0101840:	8b 45 14             	mov    0x14(%ebp),%eax
f0101843:	8b 10                	mov    (%eax),%edx
f0101845:	b9 00 00 00 00       	mov    $0x0,%ecx
f010184a:	8d 40 04             	lea    0x4(%eax),%eax
f010184d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0101850:	b8 08 00 00 00       	mov    $0x8,%eax
f0101855:	eb 2b                	jmp    f0101882 <.L26+0x2b>

f0101857 <.L26>:
f0101857:	8b 75 08             	mov    0x8(%ebp),%esi
			putch('0', putdat);
f010185a:	83 ec 08             	sub    $0x8,%esp
f010185d:	57                   	push   %edi
f010185e:	6a 30                	push   $0x30
f0101860:	ff d6                	call   *%esi
			putch('x', putdat);
f0101862:	83 c4 08             	add    $0x8,%esp
f0101865:	57                   	push   %edi
f0101866:	6a 78                	push   $0x78
f0101868:	ff d6                	call   *%esi
			num = (unsigned long long)
f010186a:	8b 45 14             	mov    0x14(%ebp),%eax
f010186d:	8b 10                	mov    (%eax),%edx
f010186f:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f0101874:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f0101877:	8d 40 04             	lea    0x4(%eax),%eax
f010187a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010187d:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
f0101882:	83 ec 0c             	sub    $0xc,%esp
f0101885:	0f be 5d cf          	movsbl -0x31(%ebp),%ebx
f0101889:	53                   	push   %ebx
f010188a:	ff 75 d4             	pushl  -0x2c(%ebp)
f010188d:	50                   	push   %eax
f010188e:	51                   	push   %ecx
f010188f:	52                   	push   %edx
f0101890:	89 fa                	mov    %edi,%edx
f0101892:	89 f0                	mov    %esi,%eax
f0101894:	e8 f3 fa ff ff       	call   f010138c <printnum>
			break;
f0101899:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
f010189c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
f010189f:	e9 12 fc ff ff       	jmp    f01014b6 <vprintfmt+0x2b>

f01018a4 <.L22>:
f01018a4:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f01018a7:	8b 75 08             	mov    0x8(%ebp),%esi
	if (lflag >= 2)
f01018aa:	83 f9 01             	cmp    $0x1,%ecx
f01018ad:	7f 1b                	jg     f01018ca <.L22+0x26>
	else if (lflag)
f01018af:	85 c9                	test   %ecx,%ecx
f01018b1:	74 2c                	je     f01018df <.L22+0x3b>
		return va_arg(*ap, unsigned long);
f01018b3:	8b 45 14             	mov    0x14(%ebp),%eax
f01018b6:	8b 10                	mov    (%eax),%edx
f01018b8:	b9 00 00 00 00       	mov    $0x0,%ecx
f01018bd:	8d 40 04             	lea    0x4(%eax),%eax
f01018c0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01018c3:	b8 10 00 00 00       	mov    $0x10,%eax
f01018c8:	eb b8                	jmp    f0101882 <.L26+0x2b>
		return va_arg(*ap, unsigned long long);
f01018ca:	8b 45 14             	mov    0x14(%ebp),%eax
f01018cd:	8b 10                	mov    (%eax),%edx
f01018cf:	8b 48 04             	mov    0x4(%eax),%ecx
f01018d2:	8d 40 08             	lea    0x8(%eax),%eax
f01018d5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01018d8:	b8 10 00 00 00       	mov    $0x10,%eax
f01018dd:	eb a3                	jmp    f0101882 <.L26+0x2b>
		return va_arg(*ap, unsigned int);
f01018df:	8b 45 14             	mov    0x14(%ebp),%eax
f01018e2:	8b 10                	mov    (%eax),%edx
f01018e4:	b9 00 00 00 00       	mov    $0x0,%ecx
f01018e9:	8d 40 04             	lea    0x4(%eax),%eax
f01018ec:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01018ef:	b8 10 00 00 00       	mov    $0x10,%eax
f01018f4:	eb 8c                	jmp    f0101882 <.L26+0x2b>

f01018f6 <.L36>:
f01018f6:	8b 75 08             	mov    0x8(%ebp),%esi
			putch(ch, putdat);
f01018f9:	83 ec 08             	sub    $0x8,%esp
f01018fc:	57                   	push   %edi
f01018fd:	6a 25                	push   $0x25
f01018ff:	ff d6                	call   *%esi
			break;
f0101901:	83 c4 10             	add    $0x10,%esp
f0101904:	eb 96                	jmp    f010189c <.L26+0x45>

f0101906 <.L21>:
f0101906:	8b 75 08             	mov    0x8(%ebp),%esi
			putch('%', putdat);
f0101909:	83 ec 08             	sub    $0x8,%esp
f010190c:	57                   	push   %edi
f010190d:	6a 25                	push   $0x25
f010190f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0101911:	83 c4 10             	add    $0x10,%esp
f0101914:	89 d8                	mov    %ebx,%eax
f0101916:	eb 03                	jmp    f010191b <.L21+0x15>
f0101918:	83 e8 01             	sub    $0x1,%eax
f010191b:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f010191f:	75 f7                	jne    f0101918 <.L21+0x12>
f0101921:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101924:	e9 73 ff ff ff       	jmp    f010189c <.L26+0x45>

f0101929 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0101929:	55                   	push   %ebp
f010192a:	89 e5                	mov    %esp,%ebp
f010192c:	53                   	push   %ebx
f010192d:	83 ec 14             	sub    $0x14,%esp
f0101930:	e8 8c e8 ff ff       	call   f01001c1 <__x86.get_pc_thunk.bx>
f0101935:	81 c3 33 37 01 00    	add    $0x13733,%ebx
f010193b:	8b 45 08             	mov    0x8(%ebp),%eax
f010193e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0101941:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0101944:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0101948:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f010194b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0101952:	85 c0                	test   %eax,%eax
f0101954:	74 2b                	je     f0101981 <vsnprintf+0x58>
f0101956:	85 d2                	test   %edx,%edx
f0101958:	7e 27                	jle    f0101981 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f010195a:	ff 75 14             	pushl  0x14(%ebp)
f010195d:	ff 75 10             	pushl  0x10(%ebp)
f0101960:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0101963:	50                   	push   %eax
f0101964:	8d 83 e9 c3 fe ff    	lea    -0x13c17(%ebx),%eax
f010196a:	50                   	push   %eax
f010196b:	e8 1b fb ff ff       	call   f010148b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0101970:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101973:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0101976:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101979:	83 c4 10             	add    $0x10,%esp
}
f010197c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010197f:	c9                   	leave  
f0101980:	c3                   	ret    
		return -E_INVAL;
f0101981:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0101986:	eb f4                	jmp    f010197c <vsnprintf+0x53>

f0101988 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0101988:	55                   	push   %ebp
f0101989:	89 e5                	mov    %esp,%ebp
f010198b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f010198e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0101991:	50                   	push   %eax
f0101992:	ff 75 10             	pushl  0x10(%ebp)
f0101995:	ff 75 0c             	pushl  0xc(%ebp)
f0101998:	ff 75 08             	pushl  0x8(%ebp)
f010199b:	e8 89 ff ff ff       	call   f0101929 <vsnprintf>
	va_end(ap);

	return rc;
}
f01019a0:	c9                   	leave  
f01019a1:	c3                   	ret    

f01019a2 <__x86.get_pc_thunk.cx>:
f01019a2:	8b 0c 24             	mov    (%esp),%ecx
f01019a5:	c3                   	ret    

f01019a6 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01019a6:	55                   	push   %ebp
f01019a7:	89 e5                	mov    %esp,%ebp
f01019a9:	57                   	push   %edi
f01019aa:	56                   	push   %esi
f01019ab:	53                   	push   %ebx
f01019ac:	83 ec 1c             	sub    $0x1c,%esp
f01019af:	e8 0d e8 ff ff       	call   f01001c1 <__x86.get_pc_thunk.bx>
f01019b4:	81 c3 b4 36 01 00    	add    $0x136b4,%ebx
f01019ba:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01019bd:	85 c0                	test   %eax,%eax
f01019bf:	74 13                	je     f01019d4 <readline+0x2e>
		cprintf("%s", prompt);
f01019c1:	83 ec 08             	sub    $0x8,%esp
f01019c4:	50                   	push   %eax
f01019c5:	8d 83 8c d6 fe ff    	lea    -0x12974(%ebx),%eax
f01019cb:	50                   	push   %eax
f01019cc:	e8 2c f6 ff ff       	call   f0100ffd <cprintf>
f01019d1:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f01019d4:	83 ec 0c             	sub    $0xc,%esp
f01019d7:	6a 00                	push   $0x0
f01019d9:	e8 4e ed ff ff       	call   f010072c <iscons>
f01019de:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01019e1:	83 c4 10             	add    $0x10,%esp
	i = 0;
f01019e4:	bf 00 00 00 00       	mov    $0x0,%edi
f01019e9:	eb 52                	jmp    f0101a3d <readline+0x97>
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
f01019eb:	83 ec 08             	sub    $0x8,%esp
f01019ee:	50                   	push   %eax
f01019ef:	8d 83 44 d9 fe ff    	lea    -0x126bc(%ebx),%eax
f01019f5:	50                   	push   %eax
f01019f6:	e8 02 f6 ff ff       	call   f0100ffd <cprintf>
			return NULL;
f01019fb:	83 c4 10             	add    $0x10,%esp
f01019fe:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f0101a03:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101a06:	5b                   	pop    %ebx
f0101a07:	5e                   	pop    %esi
f0101a08:	5f                   	pop    %edi
f0101a09:	5d                   	pop    %ebp
f0101a0a:	c3                   	ret    
			if (echoing)
f0101a0b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0101a0f:	75 05                	jne    f0101a16 <readline+0x70>
			i--;
f0101a11:	83 ef 01             	sub    $0x1,%edi
f0101a14:	eb 27                	jmp    f0101a3d <readline+0x97>
				cputchar('\b');
f0101a16:	83 ec 0c             	sub    $0xc,%esp
f0101a19:	6a 08                	push   $0x8
f0101a1b:	e8 eb ec ff ff       	call   f010070b <cputchar>
f0101a20:	83 c4 10             	add    $0x10,%esp
f0101a23:	eb ec                	jmp    f0101a11 <readline+0x6b>
				cputchar(c);
f0101a25:	83 ec 0c             	sub    $0xc,%esp
f0101a28:	56                   	push   %esi
f0101a29:	e8 dd ec ff ff       	call   f010070b <cputchar>
f0101a2e:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0101a31:	89 f0                	mov    %esi,%eax
f0101a33:	88 84 3b 58 02 00 00 	mov    %al,0x258(%ebx,%edi,1)
f0101a3a:	8d 7f 01             	lea    0x1(%edi),%edi
		c = getchar();
f0101a3d:	e8 d9 ec ff ff       	call   f010071b <getchar>
f0101a42:	89 c6                	mov    %eax,%esi
		if (c < 0) {
f0101a44:	85 c0                	test   %eax,%eax
f0101a46:	78 a3                	js     f01019eb <readline+0x45>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0101a48:	83 f8 08             	cmp    $0x8,%eax
f0101a4b:	0f 94 c2             	sete   %dl
f0101a4e:	83 f8 7f             	cmp    $0x7f,%eax
f0101a51:	0f 94 c0             	sete   %al
f0101a54:	08 c2                	or     %al,%dl
f0101a56:	74 04                	je     f0101a5c <readline+0xb6>
f0101a58:	85 ff                	test   %edi,%edi
f0101a5a:	7f af                	jg     f0101a0b <readline+0x65>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0101a5c:	83 fe 1f             	cmp    $0x1f,%esi
f0101a5f:	7e 10                	jle    f0101a71 <readline+0xcb>
f0101a61:	81 ff fe 03 00 00    	cmp    $0x3fe,%edi
f0101a67:	7f 08                	jg     f0101a71 <readline+0xcb>
			if (echoing)
f0101a69:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0101a6d:	74 c2                	je     f0101a31 <readline+0x8b>
f0101a6f:	eb b4                	jmp    f0101a25 <readline+0x7f>
		} else if (c == '\n' || c == '\r') {
f0101a71:	83 fe 0a             	cmp    $0xa,%esi
f0101a74:	74 05                	je     f0101a7b <readline+0xd5>
f0101a76:	83 fe 0d             	cmp    $0xd,%esi
f0101a79:	75 c2                	jne    f0101a3d <readline+0x97>
			if (echoing)
f0101a7b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0101a7f:	75 13                	jne    f0101a94 <readline+0xee>
			buf[i] = 0;
f0101a81:	c6 84 3b 58 02 00 00 	movb   $0x0,0x258(%ebx,%edi,1)
f0101a88:	00 
			return buf;
f0101a89:	8d 83 58 02 00 00    	lea    0x258(%ebx),%eax
f0101a8f:	e9 6f ff ff ff       	jmp    f0101a03 <readline+0x5d>
				cputchar('\n');
f0101a94:	83 ec 0c             	sub    $0xc,%esp
f0101a97:	6a 0a                	push   $0xa
f0101a99:	e8 6d ec ff ff       	call   f010070b <cputchar>
f0101a9e:	83 c4 10             	add    $0x10,%esp
f0101aa1:	eb de                	jmp    f0101a81 <readline+0xdb>

f0101aa3 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0101aa3:	55                   	push   %ebp
f0101aa4:	89 e5                	mov    %esp,%ebp
f0101aa6:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0101aa9:	b8 00 00 00 00       	mov    $0x0,%eax
f0101aae:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0101ab2:	74 05                	je     f0101ab9 <strlen+0x16>
		n++;
f0101ab4:	83 c0 01             	add    $0x1,%eax
f0101ab7:	eb f5                	jmp    f0101aae <strlen+0xb>
	return n;
}
f0101ab9:	5d                   	pop    %ebp
f0101aba:	c3                   	ret    

f0101abb <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0101abb:	55                   	push   %ebp
f0101abc:	89 e5                	mov    %esp,%ebp
f0101abe:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101ac1:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101ac4:	ba 00 00 00 00       	mov    $0x0,%edx
f0101ac9:	39 c2                	cmp    %eax,%edx
f0101acb:	74 0d                	je     f0101ada <strnlen+0x1f>
f0101acd:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f0101ad1:	74 05                	je     f0101ad8 <strnlen+0x1d>
		n++;
f0101ad3:	83 c2 01             	add    $0x1,%edx
f0101ad6:	eb f1                	jmp    f0101ac9 <strnlen+0xe>
f0101ad8:	89 d0                	mov    %edx,%eax
	return n;
}
f0101ada:	5d                   	pop    %ebp
f0101adb:	c3                   	ret    

f0101adc <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0101adc:	55                   	push   %ebp
f0101add:	89 e5                	mov    %esp,%ebp
f0101adf:	53                   	push   %ebx
f0101ae0:	8b 45 08             	mov    0x8(%ebp),%eax
f0101ae3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0101ae6:	ba 00 00 00 00       	mov    $0x0,%edx
f0101aeb:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f0101aef:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0101af2:	83 c2 01             	add    $0x1,%edx
f0101af5:	84 c9                	test   %cl,%cl
f0101af7:	75 f2                	jne    f0101aeb <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0101af9:	5b                   	pop    %ebx
f0101afa:	5d                   	pop    %ebp
f0101afb:	c3                   	ret    

f0101afc <strcat>:

char *
strcat(char *dst, const char *src)
{
f0101afc:	55                   	push   %ebp
f0101afd:	89 e5                	mov    %esp,%ebp
f0101aff:	53                   	push   %ebx
f0101b00:	83 ec 10             	sub    $0x10,%esp
f0101b03:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0101b06:	53                   	push   %ebx
f0101b07:	e8 97 ff ff ff       	call   f0101aa3 <strlen>
f0101b0c:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
f0101b0f:	ff 75 0c             	pushl  0xc(%ebp)
f0101b12:	01 d8                	add    %ebx,%eax
f0101b14:	50                   	push   %eax
f0101b15:	e8 c2 ff ff ff       	call   f0101adc <strcpy>
	return dst;
}
f0101b1a:	89 d8                	mov    %ebx,%eax
f0101b1c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101b1f:	c9                   	leave  
f0101b20:	c3                   	ret    

f0101b21 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0101b21:	55                   	push   %ebp
f0101b22:	89 e5                	mov    %esp,%ebp
f0101b24:	56                   	push   %esi
f0101b25:	53                   	push   %ebx
f0101b26:	8b 45 08             	mov    0x8(%ebp),%eax
f0101b29:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101b2c:	89 c6                	mov    %eax,%esi
f0101b2e:	03 75 10             	add    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101b31:	89 c2                	mov    %eax,%edx
f0101b33:	39 f2                	cmp    %esi,%edx
f0101b35:	74 11                	je     f0101b48 <strncpy+0x27>
		*dst++ = *src;
f0101b37:	83 c2 01             	add    $0x1,%edx
f0101b3a:	0f b6 19             	movzbl (%ecx),%ebx
f0101b3d:	88 5a ff             	mov    %bl,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0101b40:	80 fb 01             	cmp    $0x1,%bl
f0101b43:	83 d9 ff             	sbb    $0xffffffff,%ecx
f0101b46:	eb eb                	jmp    f0101b33 <strncpy+0x12>
	}
	return ret;
}
f0101b48:	5b                   	pop    %ebx
f0101b49:	5e                   	pop    %esi
f0101b4a:	5d                   	pop    %ebp
f0101b4b:	c3                   	ret    

f0101b4c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0101b4c:	55                   	push   %ebp
f0101b4d:	89 e5                	mov    %esp,%ebp
f0101b4f:	56                   	push   %esi
f0101b50:	53                   	push   %ebx
f0101b51:	8b 75 08             	mov    0x8(%ebp),%esi
f0101b54:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101b57:	8b 55 10             	mov    0x10(%ebp),%edx
f0101b5a:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0101b5c:	85 d2                	test   %edx,%edx
f0101b5e:	74 21                	je     f0101b81 <strlcpy+0x35>
f0101b60:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0101b64:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
f0101b66:	39 c2                	cmp    %eax,%edx
f0101b68:	74 14                	je     f0101b7e <strlcpy+0x32>
f0101b6a:	0f b6 19             	movzbl (%ecx),%ebx
f0101b6d:	84 db                	test   %bl,%bl
f0101b6f:	74 0b                	je     f0101b7c <strlcpy+0x30>
			*dst++ = *src++;
f0101b71:	83 c1 01             	add    $0x1,%ecx
f0101b74:	83 c2 01             	add    $0x1,%edx
f0101b77:	88 5a ff             	mov    %bl,-0x1(%edx)
f0101b7a:	eb ea                	jmp    f0101b66 <strlcpy+0x1a>
f0101b7c:	89 d0                	mov    %edx,%eax
		*dst = '\0';
f0101b7e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0101b81:	29 f0                	sub    %esi,%eax
}
f0101b83:	5b                   	pop    %ebx
f0101b84:	5e                   	pop    %esi
f0101b85:	5d                   	pop    %ebp
f0101b86:	c3                   	ret    

f0101b87 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0101b87:	55                   	push   %ebp
f0101b88:	89 e5                	mov    %esp,%ebp
f0101b8a:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101b8d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0101b90:	0f b6 01             	movzbl (%ecx),%eax
f0101b93:	84 c0                	test   %al,%al
f0101b95:	74 0c                	je     f0101ba3 <strcmp+0x1c>
f0101b97:	3a 02                	cmp    (%edx),%al
f0101b99:	75 08                	jne    f0101ba3 <strcmp+0x1c>
		p++, q++;
f0101b9b:	83 c1 01             	add    $0x1,%ecx
f0101b9e:	83 c2 01             	add    $0x1,%edx
f0101ba1:	eb ed                	jmp    f0101b90 <strcmp+0x9>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0101ba3:	0f b6 c0             	movzbl %al,%eax
f0101ba6:	0f b6 12             	movzbl (%edx),%edx
f0101ba9:	29 d0                	sub    %edx,%eax
}
f0101bab:	5d                   	pop    %ebp
f0101bac:	c3                   	ret    

f0101bad <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0101bad:	55                   	push   %ebp
f0101bae:	89 e5                	mov    %esp,%ebp
f0101bb0:	53                   	push   %ebx
f0101bb1:	8b 45 08             	mov    0x8(%ebp),%eax
f0101bb4:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101bb7:	89 c3                	mov    %eax,%ebx
f0101bb9:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0101bbc:	eb 06                	jmp    f0101bc4 <strncmp+0x17>
		n--, p++, q++;
f0101bbe:	83 c0 01             	add    $0x1,%eax
f0101bc1:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f0101bc4:	39 d8                	cmp    %ebx,%eax
f0101bc6:	74 16                	je     f0101bde <strncmp+0x31>
f0101bc8:	0f b6 08             	movzbl (%eax),%ecx
f0101bcb:	84 c9                	test   %cl,%cl
f0101bcd:	74 04                	je     f0101bd3 <strncmp+0x26>
f0101bcf:	3a 0a                	cmp    (%edx),%cl
f0101bd1:	74 eb                	je     f0101bbe <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0101bd3:	0f b6 00             	movzbl (%eax),%eax
f0101bd6:	0f b6 12             	movzbl (%edx),%edx
f0101bd9:	29 d0                	sub    %edx,%eax
}
f0101bdb:	5b                   	pop    %ebx
f0101bdc:	5d                   	pop    %ebp
f0101bdd:	c3                   	ret    
		return 0;
f0101bde:	b8 00 00 00 00       	mov    $0x0,%eax
f0101be3:	eb f6                	jmp    f0101bdb <strncmp+0x2e>

f0101be5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0101be5:	55                   	push   %ebp
f0101be6:	89 e5                	mov    %esp,%ebp
f0101be8:	8b 45 08             	mov    0x8(%ebp),%eax
f0101beb:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101bef:	0f b6 10             	movzbl (%eax),%edx
f0101bf2:	84 d2                	test   %dl,%dl
f0101bf4:	74 09                	je     f0101bff <strchr+0x1a>
		if (*s == c)
f0101bf6:	38 ca                	cmp    %cl,%dl
f0101bf8:	74 0a                	je     f0101c04 <strchr+0x1f>
	for (; *s; s++)
f0101bfa:	83 c0 01             	add    $0x1,%eax
f0101bfd:	eb f0                	jmp    f0101bef <strchr+0xa>
			return (char *) s;
	return 0;
f0101bff:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101c04:	5d                   	pop    %ebp
f0101c05:	c3                   	ret    

f0101c06 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0101c06:	55                   	push   %ebp
f0101c07:	89 e5                	mov    %esp,%ebp
f0101c09:	8b 45 08             	mov    0x8(%ebp),%eax
f0101c0c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101c10:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0101c13:	38 ca                	cmp    %cl,%dl
f0101c15:	74 09                	je     f0101c20 <strfind+0x1a>
f0101c17:	84 d2                	test   %dl,%dl
f0101c19:	74 05                	je     f0101c20 <strfind+0x1a>
	for (; *s; s++)
f0101c1b:	83 c0 01             	add    $0x1,%eax
f0101c1e:	eb f0                	jmp    f0101c10 <strfind+0xa>
			break;
	return (char *) s;
}
f0101c20:	5d                   	pop    %ebp
f0101c21:	c3                   	ret    

f0101c22 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0101c22:	55                   	push   %ebp
f0101c23:	89 e5                	mov    %esp,%ebp
f0101c25:	57                   	push   %edi
f0101c26:	56                   	push   %esi
f0101c27:	53                   	push   %ebx
f0101c28:	8b 7d 08             	mov    0x8(%ebp),%edi
f0101c2b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0101c2e:	85 c9                	test   %ecx,%ecx
f0101c30:	74 31                	je     f0101c63 <memset+0x41>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0101c32:	89 f8                	mov    %edi,%eax
f0101c34:	09 c8                	or     %ecx,%eax
f0101c36:	a8 03                	test   $0x3,%al
f0101c38:	75 23                	jne    f0101c5d <memset+0x3b>
		c &= 0xFF;
f0101c3a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0101c3e:	89 d3                	mov    %edx,%ebx
f0101c40:	c1 e3 08             	shl    $0x8,%ebx
f0101c43:	89 d0                	mov    %edx,%eax
f0101c45:	c1 e0 18             	shl    $0x18,%eax
f0101c48:	89 d6                	mov    %edx,%esi
f0101c4a:	c1 e6 10             	shl    $0x10,%esi
f0101c4d:	09 f0                	or     %esi,%eax
f0101c4f:	09 c2                	or     %eax,%edx
f0101c51:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0101c53:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f0101c56:	89 d0                	mov    %edx,%eax
f0101c58:	fc                   	cld    
f0101c59:	f3 ab                	rep stos %eax,%es:(%edi)
f0101c5b:	eb 06                	jmp    f0101c63 <memset+0x41>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0101c5d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101c60:	fc                   	cld    
f0101c61:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0101c63:	89 f8                	mov    %edi,%eax
f0101c65:	5b                   	pop    %ebx
f0101c66:	5e                   	pop    %esi
f0101c67:	5f                   	pop    %edi
f0101c68:	5d                   	pop    %ebp
f0101c69:	c3                   	ret    

f0101c6a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0101c6a:	55                   	push   %ebp
f0101c6b:	89 e5                	mov    %esp,%ebp
f0101c6d:	57                   	push   %edi
f0101c6e:	56                   	push   %esi
f0101c6f:	8b 45 08             	mov    0x8(%ebp),%eax
f0101c72:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101c75:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0101c78:	39 c6                	cmp    %eax,%esi
f0101c7a:	73 32                	jae    f0101cae <memmove+0x44>
f0101c7c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0101c7f:	39 c2                	cmp    %eax,%edx
f0101c81:	76 2b                	jbe    f0101cae <memmove+0x44>
		s += n;
		d += n;
f0101c83:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101c86:	89 fe                	mov    %edi,%esi
f0101c88:	09 ce                	or     %ecx,%esi
f0101c8a:	09 d6                	or     %edx,%esi
f0101c8c:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0101c92:	75 0e                	jne    f0101ca2 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0101c94:	83 ef 04             	sub    $0x4,%edi
f0101c97:	8d 72 fc             	lea    -0x4(%edx),%esi
f0101c9a:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f0101c9d:	fd                   	std    
f0101c9e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0101ca0:	eb 09                	jmp    f0101cab <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0101ca2:	83 ef 01             	sub    $0x1,%edi
f0101ca5:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f0101ca8:	fd                   	std    
f0101ca9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0101cab:	fc                   	cld    
f0101cac:	eb 1a                	jmp    f0101cc8 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101cae:	89 c2                	mov    %eax,%edx
f0101cb0:	09 ca                	or     %ecx,%edx
f0101cb2:	09 f2                	or     %esi,%edx
f0101cb4:	f6 c2 03             	test   $0x3,%dl
f0101cb7:	75 0a                	jne    f0101cc3 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0101cb9:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f0101cbc:	89 c7                	mov    %eax,%edi
f0101cbe:	fc                   	cld    
f0101cbf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0101cc1:	eb 05                	jmp    f0101cc8 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
f0101cc3:	89 c7                	mov    %eax,%edi
f0101cc5:	fc                   	cld    
f0101cc6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0101cc8:	5e                   	pop    %esi
f0101cc9:	5f                   	pop    %edi
f0101cca:	5d                   	pop    %ebp
f0101ccb:	c3                   	ret    

f0101ccc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0101ccc:	55                   	push   %ebp
f0101ccd:	89 e5                	mov    %esp,%ebp
f0101ccf:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0101cd2:	ff 75 10             	pushl  0x10(%ebp)
f0101cd5:	ff 75 0c             	pushl  0xc(%ebp)
f0101cd8:	ff 75 08             	pushl  0x8(%ebp)
f0101cdb:	e8 8a ff ff ff       	call   f0101c6a <memmove>
}
f0101ce0:	c9                   	leave  
f0101ce1:	c3                   	ret    

f0101ce2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0101ce2:	55                   	push   %ebp
f0101ce3:	89 e5                	mov    %esp,%ebp
f0101ce5:	56                   	push   %esi
f0101ce6:	53                   	push   %ebx
f0101ce7:	8b 45 08             	mov    0x8(%ebp),%eax
f0101cea:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101ced:	89 c6                	mov    %eax,%esi
f0101cef:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0101cf2:	39 f0                	cmp    %esi,%eax
f0101cf4:	74 1c                	je     f0101d12 <memcmp+0x30>
		if (*s1 != *s2)
f0101cf6:	0f b6 08             	movzbl (%eax),%ecx
f0101cf9:	0f b6 1a             	movzbl (%edx),%ebx
f0101cfc:	38 d9                	cmp    %bl,%cl
f0101cfe:	75 08                	jne    f0101d08 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f0101d00:	83 c0 01             	add    $0x1,%eax
f0101d03:	83 c2 01             	add    $0x1,%edx
f0101d06:	eb ea                	jmp    f0101cf2 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
f0101d08:	0f b6 c1             	movzbl %cl,%eax
f0101d0b:	0f b6 db             	movzbl %bl,%ebx
f0101d0e:	29 d8                	sub    %ebx,%eax
f0101d10:	eb 05                	jmp    f0101d17 <memcmp+0x35>
	}

	return 0;
f0101d12:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101d17:	5b                   	pop    %ebx
f0101d18:	5e                   	pop    %esi
f0101d19:	5d                   	pop    %ebp
f0101d1a:	c3                   	ret    

f0101d1b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0101d1b:	55                   	push   %ebp
f0101d1c:	89 e5                	mov    %esp,%ebp
f0101d1e:	8b 45 08             	mov    0x8(%ebp),%eax
f0101d21:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0101d24:	89 c2                	mov    %eax,%edx
f0101d26:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0101d29:	39 d0                	cmp    %edx,%eax
f0101d2b:	73 09                	jae    f0101d36 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
f0101d2d:	38 08                	cmp    %cl,(%eax)
f0101d2f:	74 05                	je     f0101d36 <memfind+0x1b>
	for (; s < ends; s++)
f0101d31:	83 c0 01             	add    $0x1,%eax
f0101d34:	eb f3                	jmp    f0101d29 <memfind+0xe>
			break;
	return (void *) s;
}
f0101d36:	5d                   	pop    %ebp
f0101d37:	c3                   	ret    

f0101d38 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0101d38:	55                   	push   %ebp
f0101d39:	89 e5                	mov    %esp,%ebp
f0101d3b:	57                   	push   %edi
f0101d3c:	56                   	push   %esi
f0101d3d:	53                   	push   %ebx
f0101d3e:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101d41:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101d44:	eb 03                	jmp    f0101d49 <strtol+0x11>
		s++;
f0101d46:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
f0101d49:	0f b6 01             	movzbl (%ecx),%eax
f0101d4c:	3c 20                	cmp    $0x20,%al
f0101d4e:	74 f6                	je     f0101d46 <strtol+0xe>
f0101d50:	3c 09                	cmp    $0x9,%al
f0101d52:	74 f2                	je     f0101d46 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f0101d54:	3c 2b                	cmp    $0x2b,%al
f0101d56:	74 2a                	je     f0101d82 <strtol+0x4a>
	int neg = 0;
f0101d58:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f0101d5d:	3c 2d                	cmp    $0x2d,%al
f0101d5f:	74 2b                	je     f0101d8c <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0101d61:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0101d67:	75 0f                	jne    f0101d78 <strtol+0x40>
f0101d69:	80 39 30             	cmpb   $0x30,(%ecx)
f0101d6c:	74 28                	je     f0101d96 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0101d6e:	85 db                	test   %ebx,%ebx
f0101d70:	b8 0a 00 00 00       	mov    $0xa,%eax
f0101d75:	0f 44 d8             	cmove  %eax,%ebx
f0101d78:	b8 00 00 00 00       	mov    $0x0,%eax
f0101d7d:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0101d80:	eb 50                	jmp    f0101dd2 <strtol+0x9a>
		s++;
f0101d82:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
f0101d85:	bf 00 00 00 00       	mov    $0x0,%edi
f0101d8a:	eb d5                	jmp    f0101d61 <strtol+0x29>
		s++, neg = 1;
f0101d8c:	83 c1 01             	add    $0x1,%ecx
f0101d8f:	bf 01 00 00 00       	mov    $0x1,%edi
f0101d94:	eb cb                	jmp    f0101d61 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0101d96:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0101d9a:	74 0e                	je     f0101daa <strtol+0x72>
	else if (base == 0 && s[0] == '0')
f0101d9c:	85 db                	test   %ebx,%ebx
f0101d9e:	75 d8                	jne    f0101d78 <strtol+0x40>
		s++, base = 8;
f0101da0:	83 c1 01             	add    $0x1,%ecx
f0101da3:	bb 08 00 00 00       	mov    $0x8,%ebx
f0101da8:	eb ce                	jmp    f0101d78 <strtol+0x40>
		s += 2, base = 16;
f0101daa:	83 c1 02             	add    $0x2,%ecx
f0101dad:	bb 10 00 00 00       	mov    $0x10,%ebx
f0101db2:	eb c4                	jmp    f0101d78 <strtol+0x40>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
f0101db4:	8d 72 9f             	lea    -0x61(%edx),%esi
f0101db7:	89 f3                	mov    %esi,%ebx
f0101db9:	80 fb 19             	cmp    $0x19,%bl
f0101dbc:	77 29                	ja     f0101de7 <strtol+0xaf>
			dig = *s - 'a' + 10;
f0101dbe:	0f be d2             	movsbl %dl,%edx
f0101dc1:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0101dc4:	3b 55 10             	cmp    0x10(%ebp),%edx
f0101dc7:	7d 30                	jge    f0101df9 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
f0101dc9:	83 c1 01             	add    $0x1,%ecx
f0101dcc:	0f af 45 10          	imul   0x10(%ebp),%eax
f0101dd0:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f0101dd2:	0f b6 11             	movzbl (%ecx),%edx
f0101dd5:	8d 72 d0             	lea    -0x30(%edx),%esi
f0101dd8:	89 f3                	mov    %esi,%ebx
f0101dda:	80 fb 09             	cmp    $0x9,%bl
f0101ddd:	77 d5                	ja     f0101db4 <strtol+0x7c>
			dig = *s - '0';
f0101ddf:	0f be d2             	movsbl %dl,%edx
f0101de2:	83 ea 30             	sub    $0x30,%edx
f0101de5:	eb dd                	jmp    f0101dc4 <strtol+0x8c>
		else if (*s >= 'A' && *s <= 'Z')
f0101de7:	8d 72 bf             	lea    -0x41(%edx),%esi
f0101dea:	89 f3                	mov    %esi,%ebx
f0101dec:	80 fb 19             	cmp    $0x19,%bl
f0101def:	77 08                	ja     f0101df9 <strtol+0xc1>
			dig = *s - 'A' + 10;
f0101df1:	0f be d2             	movsbl %dl,%edx
f0101df4:	83 ea 37             	sub    $0x37,%edx
f0101df7:	eb cb                	jmp    f0101dc4 <strtol+0x8c>
		// we don't properly detect overflow!
	}

	if (endptr)
f0101df9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0101dfd:	74 05                	je     f0101e04 <strtol+0xcc>
		*endptr = (char *) s;
f0101dff:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101e02:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f0101e04:	89 c2                	mov    %eax,%edx
f0101e06:	f7 da                	neg    %edx
f0101e08:	85 ff                	test   %edi,%edi
f0101e0a:	0f 45 c2             	cmovne %edx,%eax
}
f0101e0d:	5b                   	pop    %ebx
f0101e0e:	5e                   	pop    %esi
f0101e0f:	5f                   	pop    %edi
f0101e10:	5d                   	pop    %ebp
f0101e11:	c3                   	ret    
f0101e12:	66 90                	xchg   %ax,%ax
f0101e14:	66 90                	xchg   %ax,%ax
f0101e16:	66 90                	xchg   %ax,%ax
f0101e18:	66 90                	xchg   %ax,%ax
f0101e1a:	66 90                	xchg   %ax,%ax
f0101e1c:	66 90                	xchg   %ax,%ax
f0101e1e:	66 90                	xchg   %ax,%ax

f0101e20 <__udivdi3>:
f0101e20:	f3 0f 1e fb          	endbr32 
f0101e24:	55                   	push   %ebp
f0101e25:	57                   	push   %edi
f0101e26:	56                   	push   %esi
f0101e27:	53                   	push   %ebx
f0101e28:	83 ec 1c             	sub    $0x1c,%esp
f0101e2b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f0101e2f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f0101e33:	8b 74 24 34          	mov    0x34(%esp),%esi
f0101e37:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f0101e3b:	85 d2                	test   %edx,%edx
f0101e3d:	75 49                	jne    f0101e88 <__udivdi3+0x68>
f0101e3f:	39 f3                	cmp    %esi,%ebx
f0101e41:	76 15                	jbe    f0101e58 <__udivdi3+0x38>
f0101e43:	31 ff                	xor    %edi,%edi
f0101e45:	89 e8                	mov    %ebp,%eax
f0101e47:	89 f2                	mov    %esi,%edx
f0101e49:	f7 f3                	div    %ebx
f0101e4b:	89 fa                	mov    %edi,%edx
f0101e4d:	83 c4 1c             	add    $0x1c,%esp
f0101e50:	5b                   	pop    %ebx
f0101e51:	5e                   	pop    %esi
f0101e52:	5f                   	pop    %edi
f0101e53:	5d                   	pop    %ebp
f0101e54:	c3                   	ret    
f0101e55:	8d 76 00             	lea    0x0(%esi),%esi
f0101e58:	89 d9                	mov    %ebx,%ecx
f0101e5a:	85 db                	test   %ebx,%ebx
f0101e5c:	75 0b                	jne    f0101e69 <__udivdi3+0x49>
f0101e5e:	b8 01 00 00 00       	mov    $0x1,%eax
f0101e63:	31 d2                	xor    %edx,%edx
f0101e65:	f7 f3                	div    %ebx
f0101e67:	89 c1                	mov    %eax,%ecx
f0101e69:	31 d2                	xor    %edx,%edx
f0101e6b:	89 f0                	mov    %esi,%eax
f0101e6d:	f7 f1                	div    %ecx
f0101e6f:	89 c6                	mov    %eax,%esi
f0101e71:	89 e8                	mov    %ebp,%eax
f0101e73:	89 f7                	mov    %esi,%edi
f0101e75:	f7 f1                	div    %ecx
f0101e77:	89 fa                	mov    %edi,%edx
f0101e79:	83 c4 1c             	add    $0x1c,%esp
f0101e7c:	5b                   	pop    %ebx
f0101e7d:	5e                   	pop    %esi
f0101e7e:	5f                   	pop    %edi
f0101e7f:	5d                   	pop    %ebp
f0101e80:	c3                   	ret    
f0101e81:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101e88:	39 f2                	cmp    %esi,%edx
f0101e8a:	77 1c                	ja     f0101ea8 <__udivdi3+0x88>
f0101e8c:	0f bd fa             	bsr    %edx,%edi
f0101e8f:	83 f7 1f             	xor    $0x1f,%edi
f0101e92:	75 2c                	jne    f0101ec0 <__udivdi3+0xa0>
f0101e94:	39 f2                	cmp    %esi,%edx
f0101e96:	72 06                	jb     f0101e9e <__udivdi3+0x7e>
f0101e98:	31 c0                	xor    %eax,%eax
f0101e9a:	39 eb                	cmp    %ebp,%ebx
f0101e9c:	77 ad                	ja     f0101e4b <__udivdi3+0x2b>
f0101e9e:	b8 01 00 00 00       	mov    $0x1,%eax
f0101ea3:	eb a6                	jmp    f0101e4b <__udivdi3+0x2b>
f0101ea5:	8d 76 00             	lea    0x0(%esi),%esi
f0101ea8:	31 ff                	xor    %edi,%edi
f0101eaa:	31 c0                	xor    %eax,%eax
f0101eac:	89 fa                	mov    %edi,%edx
f0101eae:	83 c4 1c             	add    $0x1c,%esp
f0101eb1:	5b                   	pop    %ebx
f0101eb2:	5e                   	pop    %esi
f0101eb3:	5f                   	pop    %edi
f0101eb4:	5d                   	pop    %ebp
f0101eb5:	c3                   	ret    
f0101eb6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101ebd:	8d 76 00             	lea    0x0(%esi),%esi
f0101ec0:	89 f9                	mov    %edi,%ecx
f0101ec2:	b8 20 00 00 00       	mov    $0x20,%eax
f0101ec7:	29 f8                	sub    %edi,%eax
f0101ec9:	d3 e2                	shl    %cl,%edx
f0101ecb:	89 54 24 08          	mov    %edx,0x8(%esp)
f0101ecf:	89 c1                	mov    %eax,%ecx
f0101ed1:	89 da                	mov    %ebx,%edx
f0101ed3:	d3 ea                	shr    %cl,%edx
f0101ed5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0101ed9:	09 d1                	or     %edx,%ecx
f0101edb:	89 f2                	mov    %esi,%edx
f0101edd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101ee1:	89 f9                	mov    %edi,%ecx
f0101ee3:	d3 e3                	shl    %cl,%ebx
f0101ee5:	89 c1                	mov    %eax,%ecx
f0101ee7:	d3 ea                	shr    %cl,%edx
f0101ee9:	89 f9                	mov    %edi,%ecx
f0101eeb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0101eef:	89 eb                	mov    %ebp,%ebx
f0101ef1:	d3 e6                	shl    %cl,%esi
f0101ef3:	89 c1                	mov    %eax,%ecx
f0101ef5:	d3 eb                	shr    %cl,%ebx
f0101ef7:	09 de                	or     %ebx,%esi
f0101ef9:	89 f0                	mov    %esi,%eax
f0101efb:	f7 74 24 08          	divl   0x8(%esp)
f0101eff:	89 d6                	mov    %edx,%esi
f0101f01:	89 c3                	mov    %eax,%ebx
f0101f03:	f7 64 24 0c          	mull   0xc(%esp)
f0101f07:	39 d6                	cmp    %edx,%esi
f0101f09:	72 15                	jb     f0101f20 <__udivdi3+0x100>
f0101f0b:	89 f9                	mov    %edi,%ecx
f0101f0d:	d3 e5                	shl    %cl,%ebp
f0101f0f:	39 c5                	cmp    %eax,%ebp
f0101f11:	73 04                	jae    f0101f17 <__udivdi3+0xf7>
f0101f13:	39 d6                	cmp    %edx,%esi
f0101f15:	74 09                	je     f0101f20 <__udivdi3+0x100>
f0101f17:	89 d8                	mov    %ebx,%eax
f0101f19:	31 ff                	xor    %edi,%edi
f0101f1b:	e9 2b ff ff ff       	jmp    f0101e4b <__udivdi3+0x2b>
f0101f20:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0101f23:	31 ff                	xor    %edi,%edi
f0101f25:	e9 21 ff ff ff       	jmp    f0101e4b <__udivdi3+0x2b>
f0101f2a:	66 90                	xchg   %ax,%ax
f0101f2c:	66 90                	xchg   %ax,%ax
f0101f2e:	66 90                	xchg   %ax,%ax

f0101f30 <__umoddi3>:
f0101f30:	f3 0f 1e fb          	endbr32 
f0101f34:	55                   	push   %ebp
f0101f35:	57                   	push   %edi
f0101f36:	56                   	push   %esi
f0101f37:	53                   	push   %ebx
f0101f38:	83 ec 1c             	sub    $0x1c,%esp
f0101f3b:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f0101f3f:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f0101f43:	8b 74 24 30          	mov    0x30(%esp),%esi
f0101f47:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0101f4b:	89 da                	mov    %ebx,%edx
f0101f4d:	85 c0                	test   %eax,%eax
f0101f4f:	75 3f                	jne    f0101f90 <__umoddi3+0x60>
f0101f51:	39 df                	cmp    %ebx,%edi
f0101f53:	76 13                	jbe    f0101f68 <__umoddi3+0x38>
f0101f55:	89 f0                	mov    %esi,%eax
f0101f57:	f7 f7                	div    %edi
f0101f59:	89 d0                	mov    %edx,%eax
f0101f5b:	31 d2                	xor    %edx,%edx
f0101f5d:	83 c4 1c             	add    $0x1c,%esp
f0101f60:	5b                   	pop    %ebx
f0101f61:	5e                   	pop    %esi
f0101f62:	5f                   	pop    %edi
f0101f63:	5d                   	pop    %ebp
f0101f64:	c3                   	ret    
f0101f65:	8d 76 00             	lea    0x0(%esi),%esi
f0101f68:	89 fd                	mov    %edi,%ebp
f0101f6a:	85 ff                	test   %edi,%edi
f0101f6c:	75 0b                	jne    f0101f79 <__umoddi3+0x49>
f0101f6e:	b8 01 00 00 00       	mov    $0x1,%eax
f0101f73:	31 d2                	xor    %edx,%edx
f0101f75:	f7 f7                	div    %edi
f0101f77:	89 c5                	mov    %eax,%ebp
f0101f79:	89 d8                	mov    %ebx,%eax
f0101f7b:	31 d2                	xor    %edx,%edx
f0101f7d:	f7 f5                	div    %ebp
f0101f7f:	89 f0                	mov    %esi,%eax
f0101f81:	f7 f5                	div    %ebp
f0101f83:	89 d0                	mov    %edx,%eax
f0101f85:	eb d4                	jmp    f0101f5b <__umoddi3+0x2b>
f0101f87:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101f8e:	66 90                	xchg   %ax,%ax
f0101f90:	89 f1                	mov    %esi,%ecx
f0101f92:	39 d8                	cmp    %ebx,%eax
f0101f94:	76 0a                	jbe    f0101fa0 <__umoddi3+0x70>
f0101f96:	89 f0                	mov    %esi,%eax
f0101f98:	83 c4 1c             	add    $0x1c,%esp
f0101f9b:	5b                   	pop    %ebx
f0101f9c:	5e                   	pop    %esi
f0101f9d:	5f                   	pop    %edi
f0101f9e:	5d                   	pop    %ebp
f0101f9f:	c3                   	ret    
f0101fa0:	0f bd e8             	bsr    %eax,%ebp
f0101fa3:	83 f5 1f             	xor    $0x1f,%ebp
f0101fa6:	75 20                	jne    f0101fc8 <__umoddi3+0x98>
f0101fa8:	39 d8                	cmp    %ebx,%eax
f0101faa:	0f 82 b0 00 00 00    	jb     f0102060 <__umoddi3+0x130>
f0101fb0:	39 f7                	cmp    %esi,%edi
f0101fb2:	0f 86 a8 00 00 00    	jbe    f0102060 <__umoddi3+0x130>
f0101fb8:	89 c8                	mov    %ecx,%eax
f0101fba:	83 c4 1c             	add    $0x1c,%esp
f0101fbd:	5b                   	pop    %ebx
f0101fbe:	5e                   	pop    %esi
f0101fbf:	5f                   	pop    %edi
f0101fc0:	5d                   	pop    %ebp
f0101fc1:	c3                   	ret    
f0101fc2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101fc8:	89 e9                	mov    %ebp,%ecx
f0101fca:	ba 20 00 00 00       	mov    $0x20,%edx
f0101fcf:	29 ea                	sub    %ebp,%edx
f0101fd1:	d3 e0                	shl    %cl,%eax
f0101fd3:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101fd7:	89 d1                	mov    %edx,%ecx
f0101fd9:	89 f8                	mov    %edi,%eax
f0101fdb:	d3 e8                	shr    %cl,%eax
f0101fdd:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0101fe1:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101fe5:	8b 54 24 04          	mov    0x4(%esp),%edx
f0101fe9:	09 c1                	or     %eax,%ecx
f0101feb:	89 d8                	mov    %ebx,%eax
f0101fed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101ff1:	89 e9                	mov    %ebp,%ecx
f0101ff3:	d3 e7                	shl    %cl,%edi
f0101ff5:	89 d1                	mov    %edx,%ecx
f0101ff7:	d3 e8                	shr    %cl,%eax
f0101ff9:	89 e9                	mov    %ebp,%ecx
f0101ffb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0101fff:	d3 e3                	shl    %cl,%ebx
f0102001:	89 c7                	mov    %eax,%edi
f0102003:	89 d1                	mov    %edx,%ecx
f0102005:	89 f0                	mov    %esi,%eax
f0102007:	d3 e8                	shr    %cl,%eax
f0102009:	89 e9                	mov    %ebp,%ecx
f010200b:	89 fa                	mov    %edi,%edx
f010200d:	d3 e6                	shl    %cl,%esi
f010200f:	09 d8                	or     %ebx,%eax
f0102011:	f7 74 24 08          	divl   0x8(%esp)
f0102015:	89 d1                	mov    %edx,%ecx
f0102017:	89 f3                	mov    %esi,%ebx
f0102019:	f7 64 24 0c          	mull   0xc(%esp)
f010201d:	89 c6                	mov    %eax,%esi
f010201f:	89 d7                	mov    %edx,%edi
f0102021:	39 d1                	cmp    %edx,%ecx
f0102023:	72 06                	jb     f010202b <__umoddi3+0xfb>
f0102025:	75 10                	jne    f0102037 <__umoddi3+0x107>
f0102027:	39 c3                	cmp    %eax,%ebx
f0102029:	73 0c                	jae    f0102037 <__umoddi3+0x107>
f010202b:	2b 44 24 0c          	sub    0xc(%esp),%eax
f010202f:	1b 54 24 08          	sbb    0x8(%esp),%edx
f0102033:	89 d7                	mov    %edx,%edi
f0102035:	89 c6                	mov    %eax,%esi
f0102037:	89 ca                	mov    %ecx,%edx
f0102039:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f010203e:	29 f3                	sub    %esi,%ebx
f0102040:	19 fa                	sbb    %edi,%edx
f0102042:	89 d0                	mov    %edx,%eax
f0102044:	d3 e0                	shl    %cl,%eax
f0102046:	89 e9                	mov    %ebp,%ecx
f0102048:	d3 eb                	shr    %cl,%ebx
f010204a:	d3 ea                	shr    %cl,%edx
f010204c:	09 d8                	or     %ebx,%eax
f010204e:	83 c4 1c             	add    $0x1c,%esp
f0102051:	5b                   	pop    %ebx
f0102052:	5e                   	pop    %esi
f0102053:	5f                   	pop    %edi
f0102054:	5d                   	pop    %ebp
f0102055:	c3                   	ret    
f0102056:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f010205d:	8d 76 00             	lea    0x0(%esi),%esi
f0102060:	89 da                	mov    %ebx,%edx
f0102062:	29 fe                	sub    %edi,%esi
f0102064:	19 c2                	sbb    %eax,%edx
f0102066:	89 f1                	mov    %esi,%ecx
f0102068:	89 c8                	mov    %ecx,%eax
f010206a:	e9 4b ff ff ff       	jmp    f0101fba <__umoddi3+0x8a>
