
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
f0100015:	b8 00 e0 18 00       	mov    $0x18e000,%eax
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
f0100034:	bc 00 b0 11 f0       	mov    $0xf011b000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 68 00 00 00       	call   f01000a6 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <test_backtrace>:
#include <kern/env.h>
#include <kern/trap.h>
// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	56                   	push   %esi
f0100044:	53                   	push   %ebx
f0100045:	e8 8f 01 00 00       	call   f01001d9 <__x86.get_pc_thunk.bx>
f010004a:	81 c3 aa f0 08 00    	add    $0x8f0aa,%ebx
f0100050:	8b 75 08             	mov    0x8(%ebp),%esi
	cprintf("entering test_backtrace %d\n", x);
f0100053:	83 ec 08             	sub    $0x8,%esp
f0100056:	56                   	push   %esi
f0100057:	8d 83 4c 60 f7 ff    	lea    -0x89fb4(%ebx),%eax
f010005d:	50                   	push   %eax
f010005e:	e8 d4 37 00 00       	call   f0103837 <cprintf>
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
f010007d:	8d 83 68 60 f7 ff    	lea    -0x89f98(%ebx),%eax
f0100083:	50                   	push   %eax
f0100084:	e8 ae 37 00 00       	call   f0103837 <cprintf>
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
f010009c:	e8 e5 07 00 00       	call   f0100886 <mon_backtrace>
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
f01000ad:	e8 27 01 00 00       	call   f01001d9 <__x86.get_pc_thunk.bx>
f01000b2:	81 c3 42 f0 08 00    	add    $0x8f042,%ebx
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f01000b8:	c7 c0 00 00 19 f0    	mov    $0xf0190000,%eax
f01000be:	c7 c2 00 f1 18 f0    	mov    $0xf018f100,%edx
f01000c4:	29 d0                	sub    %edx,%eax
f01000c6:	50                   	push   %eax
f01000c7:	6a 00                	push   $0x0
f01000c9:	52                   	push   %edx
f01000ca:	e8 24 4c 00 00       	call   f0104cf3 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000cf:	e8 2d 05 00 00       	call   f0100601 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000d4:	83 c4 08             	add    $0x8,%esp
f01000d7:	68 ac 1a 00 00       	push   $0x1aac
f01000dc:	8d 83 83 60 f7 ff    	lea    -0x89f7d(%ebx),%eax
f01000e2:	50                   	push   %eax
f01000e3:	e8 4f 37 00 00       	call   f0103837 <cprintf>

	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f01000e8:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f01000ef:	e8 4c ff ff ff       	call   f0100040 <test_backtrace>
	// Lab 2 memory management initialization functions
	mem_init();
f01000f4:	e8 99 12 00 00       	call   f0101392 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f01000f9:	e8 63 30 00 00       	call   f0103161 <env_init>
	trap_init();
f01000fe:	e8 e7 37 00 00       	call   f01038ea <trap_init>

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f0100103:	83 c4 08             	add    $0x8,%esp
f0100106:	6a 00                	push   $0x0
f0100108:	ff b3 f8 ff ff ff    	pushl  -0x8(%ebx)
f010010e:	e8 37 32 00 00       	call   f010334a <env_create>
	// Touch all you want.
	ENV_CREATE(user_hello, ENV_TYPE_USER);
#endif // TEST*

	// We only have one user environment for now, so just run it.
	env_run(&envs[0]);
f0100113:	83 c4 04             	add    $0x4,%esp
f0100116:	c7 c0 48 f3 18 f0    	mov    $0xf018f348,%eax
f010011c:	ff 30                	pushl  (%eax)
f010011e:	e8 18 36 00 00       	call   f010373b <env_run>

f0100123 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100123:	55                   	push   %ebp
f0100124:	89 e5                	mov    %esp,%ebp
f0100126:	57                   	push   %edi
f0100127:	56                   	push   %esi
f0100128:	53                   	push   %ebx
f0100129:	83 ec 0c             	sub    $0xc,%esp
f010012c:	e8 a8 00 00 00       	call   f01001d9 <__x86.get_pc_thunk.bx>
f0100131:	81 c3 c3 ef 08 00    	add    $0x8efc3,%ebx
f0100137:	8b 7d 10             	mov    0x10(%ebp),%edi
	va_list ap;

	if (panicstr)
f010013a:	c7 c0 00 00 19 f0    	mov    $0xf0190000,%eax
f0100140:	83 38 00             	cmpl   $0x0,(%eax)
f0100143:	74 0f                	je     f0100154 <_panic+0x31>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100145:	83 ec 0c             	sub    $0xc,%esp
f0100148:	6a 00                	push   $0x0
f010014a:	e8 d9 07 00 00       	call   f0100928 <monitor>
f010014f:	83 c4 10             	add    $0x10,%esp
f0100152:	eb f1                	jmp    f0100145 <_panic+0x22>
	panicstr = fmt;
f0100154:	89 38                	mov    %edi,(%eax)
	asm volatile("cli; cld");
f0100156:	fa                   	cli    
f0100157:	fc                   	cld    
	va_start(ap, fmt);
f0100158:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel panic at %s:%d: ", file, line);
f010015b:	83 ec 04             	sub    $0x4,%esp
f010015e:	ff 75 0c             	pushl  0xc(%ebp)
f0100161:	ff 75 08             	pushl  0x8(%ebp)
f0100164:	8d 83 9e 60 f7 ff    	lea    -0x89f62(%ebx),%eax
f010016a:	50                   	push   %eax
f010016b:	e8 c7 36 00 00       	call   f0103837 <cprintf>
	vcprintf(fmt, ap);
f0100170:	83 c4 08             	add    $0x8,%esp
f0100173:	56                   	push   %esi
f0100174:	57                   	push   %edi
f0100175:	e8 86 36 00 00       	call   f0103800 <vcprintf>
	cprintf("\n");
f010017a:	8d 83 f6 6f f7 ff    	lea    -0x8900a(%ebx),%eax
f0100180:	89 04 24             	mov    %eax,(%esp)
f0100183:	e8 af 36 00 00       	call   f0103837 <cprintf>
f0100188:	83 c4 10             	add    $0x10,%esp
f010018b:	eb b8                	jmp    f0100145 <_panic+0x22>

f010018d <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010018d:	55                   	push   %ebp
f010018e:	89 e5                	mov    %esp,%ebp
f0100190:	56                   	push   %esi
f0100191:	53                   	push   %ebx
f0100192:	e8 42 00 00 00       	call   f01001d9 <__x86.get_pc_thunk.bx>
f0100197:	81 c3 5d ef 08 00    	add    $0x8ef5d,%ebx
	va_list ap;

	va_start(ap, fmt);
f010019d:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel warning at %s:%d: ", file, line);
f01001a0:	83 ec 04             	sub    $0x4,%esp
f01001a3:	ff 75 0c             	pushl  0xc(%ebp)
f01001a6:	ff 75 08             	pushl  0x8(%ebp)
f01001a9:	8d 83 b6 60 f7 ff    	lea    -0x89f4a(%ebx),%eax
f01001af:	50                   	push   %eax
f01001b0:	e8 82 36 00 00       	call   f0103837 <cprintf>
	vcprintf(fmt, ap);
f01001b5:	83 c4 08             	add    $0x8,%esp
f01001b8:	56                   	push   %esi
f01001b9:	ff 75 10             	pushl  0x10(%ebp)
f01001bc:	e8 3f 36 00 00       	call   f0103800 <vcprintf>
	cprintf("\n");
f01001c1:	8d 83 f6 6f f7 ff    	lea    -0x8900a(%ebx),%eax
f01001c7:	89 04 24             	mov    %eax,(%esp)
f01001ca:	e8 68 36 00 00       	call   f0103837 <cprintf>
	va_end(ap);
}
f01001cf:	83 c4 10             	add    $0x10,%esp
f01001d2:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01001d5:	5b                   	pop    %ebx
f01001d6:	5e                   	pop    %esi
f01001d7:	5d                   	pop    %ebp
f01001d8:	c3                   	ret    

f01001d9 <__x86.get_pc_thunk.bx>:
f01001d9:	8b 1c 24             	mov    (%esp),%ebx
f01001dc:	c3                   	ret    

f01001dd <serial_proc_data>:

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01001dd:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01001e2:	ec                   	in     (%dx),%al
static bool serial_exists;

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01001e3:	a8 01                	test   $0x1,%al
f01001e5:	74 0a                	je     f01001f1 <serial_proc_data+0x14>
f01001e7:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01001ec:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01001ed:	0f b6 c0             	movzbl %al,%eax
f01001f0:	c3                   	ret    
		return -1;
f01001f1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f01001f6:	c3                   	ret    

f01001f7 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01001f7:	55                   	push   %ebp
f01001f8:	89 e5                	mov    %esp,%ebp
f01001fa:	56                   	push   %esi
f01001fb:	53                   	push   %ebx
f01001fc:	e8 d8 ff ff ff       	call   f01001d9 <__x86.get_pc_thunk.bx>
f0100201:	81 c3 f3 ee 08 00    	add    $0x8eef3,%ebx
f0100207:	89 c6                	mov    %eax,%esi
	int c;

	while ((c = (*proc)()) != -1) {
f0100209:	ff d6                	call   *%esi
f010020b:	83 f8 ff             	cmp    $0xffffffff,%eax
f010020e:	74 2a                	je     f010023a <cons_intr+0x43>
		if (c == 0)
f0100210:	85 c0                	test   %eax,%eax
f0100212:	74 f5                	je     f0100209 <cons_intr+0x12>
			continue;
		cons.buf[cons.wpos++] = c;
f0100214:	8b 8b 30 02 00 00    	mov    0x230(%ebx),%ecx
f010021a:	8d 51 01             	lea    0x1(%ecx),%edx
f010021d:	88 84 0b 2c 00 00 00 	mov    %al,0x2c(%ebx,%ecx,1)
		if (cons.wpos == CONSBUFSIZE)
f0100224:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.wpos = 0;
f010022a:	b8 00 00 00 00       	mov    $0x0,%eax
f010022f:	0f 44 d0             	cmove  %eax,%edx
f0100232:	89 93 30 02 00 00    	mov    %edx,0x230(%ebx)
f0100238:	eb cf                	jmp    f0100209 <cons_intr+0x12>
	}
}
f010023a:	5b                   	pop    %ebx
f010023b:	5e                   	pop    %esi
f010023c:	5d                   	pop    %ebp
f010023d:	c3                   	ret    

f010023e <kbd_proc_data>:
{
f010023e:	55                   	push   %ebp
f010023f:	89 e5                	mov    %esp,%ebp
f0100241:	56                   	push   %esi
f0100242:	53                   	push   %ebx
f0100243:	e8 91 ff ff ff       	call   f01001d9 <__x86.get_pc_thunk.bx>
f0100248:	81 c3 ac ee 08 00    	add    $0x8eeac,%ebx
f010024e:	ba 64 00 00 00       	mov    $0x64,%edx
f0100253:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f0100254:	a8 01                	test   $0x1,%al
f0100256:	0f 84 fb 00 00 00    	je     f0100357 <kbd_proc_data+0x119>
	if (stat & KBS_TERR)
f010025c:	a8 20                	test   $0x20,%al
f010025e:	0f 85 fa 00 00 00    	jne    f010035e <kbd_proc_data+0x120>
f0100264:	ba 60 00 00 00       	mov    $0x60,%edx
f0100269:	ec                   	in     (%dx),%al
f010026a:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f010026c:	3c e0                	cmp    $0xe0,%al
f010026e:	74 64                	je     f01002d4 <kbd_proc_data+0x96>
	} else if (data & 0x80) {
f0100270:	84 c0                	test   %al,%al
f0100272:	78 75                	js     f01002e9 <kbd_proc_data+0xab>
	} else if (shift & E0ESC) {
f0100274:	8b 8b 0c 00 00 00    	mov    0xc(%ebx),%ecx
f010027a:	f6 c1 40             	test   $0x40,%cl
f010027d:	74 0e                	je     f010028d <kbd_proc_data+0x4f>
		data |= 0x80;
f010027f:	83 c8 80             	or     $0xffffff80,%eax
f0100282:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100284:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100287:	89 8b 0c 00 00 00    	mov    %ecx,0xc(%ebx)
	shift |= shiftcode[data];
f010028d:	0f b6 d2             	movzbl %dl,%edx
f0100290:	0f b6 84 13 0c 62 f7 	movzbl -0x89df4(%ebx,%edx,1),%eax
f0100297:	ff 
f0100298:	0b 83 0c 00 00 00    	or     0xc(%ebx),%eax
	shift ^= togglecode[data];
f010029e:	0f b6 8c 13 0c 61 f7 	movzbl -0x89ef4(%ebx,%edx,1),%ecx
f01002a5:	ff 
f01002a6:	31 c8                	xor    %ecx,%eax
f01002a8:	89 83 0c 00 00 00    	mov    %eax,0xc(%ebx)
	c = charcode[shift & (CTL | SHIFT)][data];
f01002ae:	89 c1                	mov    %eax,%ecx
f01002b0:	83 e1 03             	and    $0x3,%ecx
f01002b3:	8b 8c 8b 2c ff ff ff 	mov    -0xd4(%ebx,%ecx,4),%ecx
f01002ba:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f01002be:	0f b6 f2             	movzbl %dl,%esi
	if (shift & CAPSLOCK) {
f01002c1:	a8 08                	test   $0x8,%al
f01002c3:	74 65                	je     f010032a <kbd_proc_data+0xec>
		if ('a' <= c && c <= 'z')
f01002c5:	89 f2                	mov    %esi,%edx
f01002c7:	8d 4e 9f             	lea    -0x61(%esi),%ecx
f01002ca:	83 f9 19             	cmp    $0x19,%ecx
f01002cd:	77 4f                	ja     f010031e <kbd_proc_data+0xe0>
			c += 'A' - 'a';
f01002cf:	83 ee 20             	sub    $0x20,%esi
f01002d2:	eb 0c                	jmp    f01002e0 <kbd_proc_data+0xa2>
		shift |= E0ESC;
f01002d4:	83 8b 0c 00 00 00 40 	orl    $0x40,0xc(%ebx)
		return 0;
f01002db:	be 00 00 00 00       	mov    $0x0,%esi
}
f01002e0:	89 f0                	mov    %esi,%eax
f01002e2:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01002e5:	5b                   	pop    %ebx
f01002e6:	5e                   	pop    %esi
f01002e7:	5d                   	pop    %ebp
f01002e8:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f01002e9:	8b 8b 0c 00 00 00    	mov    0xc(%ebx),%ecx
f01002ef:	89 ce                	mov    %ecx,%esi
f01002f1:	83 e6 40             	and    $0x40,%esi
f01002f4:	83 e0 7f             	and    $0x7f,%eax
f01002f7:	85 f6                	test   %esi,%esi
f01002f9:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01002fc:	0f b6 d2             	movzbl %dl,%edx
f01002ff:	0f b6 84 13 0c 62 f7 	movzbl -0x89df4(%ebx,%edx,1),%eax
f0100306:	ff 
f0100307:	83 c8 40             	or     $0x40,%eax
f010030a:	0f b6 c0             	movzbl %al,%eax
f010030d:	f7 d0                	not    %eax
f010030f:	21 c8                	and    %ecx,%eax
f0100311:	89 83 0c 00 00 00    	mov    %eax,0xc(%ebx)
		return 0;
f0100317:	be 00 00 00 00       	mov    $0x0,%esi
f010031c:	eb c2                	jmp    f01002e0 <kbd_proc_data+0xa2>
		else if ('A' <= c && c <= 'Z')
f010031e:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f0100321:	8d 4e 20             	lea    0x20(%esi),%ecx
f0100324:	83 fa 1a             	cmp    $0x1a,%edx
f0100327:	0f 42 f1             	cmovb  %ecx,%esi
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f010032a:	f7 d0                	not    %eax
f010032c:	a8 06                	test   $0x6,%al
f010032e:	75 b0                	jne    f01002e0 <kbd_proc_data+0xa2>
f0100330:	81 fe e9 00 00 00    	cmp    $0xe9,%esi
f0100336:	75 a8                	jne    f01002e0 <kbd_proc_data+0xa2>
		cprintf("Rebooting!\n");
f0100338:	83 ec 0c             	sub    $0xc,%esp
f010033b:	8d 83 d0 60 f7 ff    	lea    -0x89f30(%ebx),%eax
f0100341:	50                   	push   %eax
f0100342:	e8 f0 34 00 00       	call   f0103837 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100347:	b8 03 00 00 00       	mov    $0x3,%eax
f010034c:	ba 92 00 00 00       	mov    $0x92,%edx
f0100351:	ee                   	out    %al,(%dx)
f0100352:	83 c4 10             	add    $0x10,%esp
f0100355:	eb 89                	jmp    f01002e0 <kbd_proc_data+0xa2>
		return -1;
f0100357:	be ff ff ff ff       	mov    $0xffffffff,%esi
f010035c:	eb 82                	jmp    f01002e0 <kbd_proc_data+0xa2>
		return -1;
f010035e:	be ff ff ff ff       	mov    $0xffffffff,%esi
f0100363:	e9 78 ff ff ff       	jmp    f01002e0 <kbd_proc_data+0xa2>

f0100368 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100368:	55                   	push   %ebp
f0100369:	89 e5                	mov    %esp,%ebp
f010036b:	57                   	push   %edi
f010036c:	56                   	push   %esi
f010036d:	53                   	push   %ebx
f010036e:	83 ec 1c             	sub    $0x1c,%esp
f0100371:	e8 63 fe ff ff       	call   f01001d9 <__x86.get_pc_thunk.bx>
f0100376:	81 c3 7e ed 08 00    	add    $0x8ed7e,%ebx
f010037c:	89 c7                	mov    %eax,%edi
	for (i = 0;
f010037e:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100383:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100388:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010038d:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f010038e:	a8 20                	test   $0x20,%al
f0100390:	75 13                	jne    f01003a5 <cons_putc+0x3d>
f0100392:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f0100398:	7f 0b                	jg     f01003a5 <cons_putc+0x3d>
f010039a:	89 ca                	mov    %ecx,%edx
f010039c:	ec                   	in     (%dx),%al
f010039d:	ec                   	in     (%dx),%al
f010039e:	ec                   	in     (%dx),%al
f010039f:	ec                   	in     (%dx),%al
	     i++)
f01003a0:	83 c6 01             	add    $0x1,%esi
f01003a3:	eb e3                	jmp    f0100388 <cons_putc+0x20>
	outb(COM1 + COM_TX, c);
f01003a5:	89 f8                	mov    %edi,%eax
f01003a7:	88 45 e7             	mov    %al,-0x19(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003aa:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01003af:	ee                   	out    %al,(%dx)
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01003b0:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003b5:	b9 84 00 00 00       	mov    $0x84,%ecx
f01003ba:	ba 79 03 00 00       	mov    $0x379,%edx
f01003bf:	ec                   	in     (%dx),%al
f01003c0:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f01003c6:	7f 0f                	jg     f01003d7 <cons_putc+0x6f>
f01003c8:	84 c0                	test   %al,%al
f01003ca:	78 0b                	js     f01003d7 <cons_putc+0x6f>
f01003cc:	89 ca                	mov    %ecx,%edx
f01003ce:	ec                   	in     (%dx),%al
f01003cf:	ec                   	in     (%dx),%al
f01003d0:	ec                   	in     (%dx),%al
f01003d1:	ec                   	in     (%dx),%al
f01003d2:	83 c6 01             	add    $0x1,%esi
f01003d5:	eb e3                	jmp    f01003ba <cons_putc+0x52>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003d7:	ba 78 03 00 00       	mov    $0x378,%edx
f01003dc:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f01003e0:	ee                   	out    %al,(%dx)
f01003e1:	ba 7a 03 00 00       	mov    $0x37a,%edx
f01003e6:	b8 0d 00 00 00       	mov    $0xd,%eax
f01003eb:	ee                   	out    %al,(%dx)
f01003ec:	b8 08 00 00 00       	mov    $0x8,%eax
f01003f1:	ee                   	out    %al,(%dx)
	if (!(c & ~0xFF))
f01003f2:	89 fa                	mov    %edi,%edx
f01003f4:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f01003fa:	89 f8                	mov    %edi,%eax
f01003fc:	80 cc 07             	or     $0x7,%ah
f01003ff:	85 d2                	test   %edx,%edx
f0100401:	0f 44 f8             	cmove  %eax,%edi
	switch (c & 0xff) {
f0100404:	89 f8                	mov    %edi,%eax
f0100406:	0f b6 c0             	movzbl %al,%eax
f0100409:	83 f8 09             	cmp    $0x9,%eax
f010040c:	0f 84 b4 00 00 00    	je     f01004c6 <cons_putc+0x15e>
f0100412:	7e 74                	jle    f0100488 <cons_putc+0x120>
f0100414:	83 f8 0a             	cmp    $0xa,%eax
f0100417:	0f 84 9c 00 00 00    	je     f01004b9 <cons_putc+0x151>
f010041d:	83 f8 0d             	cmp    $0xd,%eax
f0100420:	0f 85 d7 00 00 00    	jne    f01004fd <cons_putc+0x195>
		crt_pos -= (crt_pos % CRT_COLS);
f0100426:	0f b7 83 34 02 00 00 	movzwl 0x234(%ebx),%eax
f010042d:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100433:	c1 e8 16             	shr    $0x16,%eax
f0100436:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100439:	c1 e0 04             	shl    $0x4,%eax
f010043c:	66 89 83 34 02 00 00 	mov    %ax,0x234(%ebx)
	if (crt_pos >= CRT_SIZE) {
f0100443:	66 81 bb 34 02 00 00 	cmpw   $0x7cf,0x234(%ebx)
f010044a:	cf 07 
f010044c:	0f 87 ce 00 00 00    	ja     f0100520 <cons_putc+0x1b8>
	outb(addr_6845, 14);
f0100452:	8b 8b 3c 02 00 00    	mov    0x23c(%ebx),%ecx
f0100458:	b8 0e 00 00 00       	mov    $0xe,%eax
f010045d:	89 ca                	mov    %ecx,%edx
f010045f:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100460:	0f b7 9b 34 02 00 00 	movzwl 0x234(%ebx),%ebx
f0100467:	8d 71 01             	lea    0x1(%ecx),%esi
f010046a:	89 d8                	mov    %ebx,%eax
f010046c:	66 c1 e8 08          	shr    $0x8,%ax
f0100470:	89 f2                	mov    %esi,%edx
f0100472:	ee                   	out    %al,(%dx)
f0100473:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100478:	89 ca                	mov    %ecx,%edx
f010047a:	ee                   	out    %al,(%dx)
f010047b:	89 d8                	mov    %ebx,%eax
f010047d:	89 f2                	mov    %esi,%edx
f010047f:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100480:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100483:	5b                   	pop    %ebx
f0100484:	5e                   	pop    %esi
f0100485:	5f                   	pop    %edi
f0100486:	5d                   	pop    %ebp
f0100487:	c3                   	ret    
	switch (c & 0xff) {
f0100488:	83 f8 08             	cmp    $0x8,%eax
f010048b:	75 70                	jne    f01004fd <cons_putc+0x195>
		if (crt_pos > 0) {
f010048d:	0f b7 83 34 02 00 00 	movzwl 0x234(%ebx),%eax
f0100494:	66 85 c0             	test   %ax,%ax
f0100497:	74 b9                	je     f0100452 <cons_putc+0xea>
			crt_pos--;
f0100499:	83 e8 01             	sub    $0x1,%eax
f010049c:	66 89 83 34 02 00 00 	mov    %ax,0x234(%ebx)
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004a3:	0f b7 c0             	movzwl %ax,%eax
f01004a6:	89 fa                	mov    %edi,%edx
f01004a8:	b2 00                	mov    $0x0,%dl
f01004aa:	83 ca 20             	or     $0x20,%edx
f01004ad:	8b 8b 38 02 00 00    	mov    0x238(%ebx),%ecx
f01004b3:	66 89 14 41          	mov    %dx,(%ecx,%eax,2)
f01004b7:	eb 8a                	jmp    f0100443 <cons_putc+0xdb>
		crt_pos += CRT_COLS;
f01004b9:	66 83 83 34 02 00 00 	addw   $0x50,0x234(%ebx)
f01004c0:	50 
f01004c1:	e9 60 ff ff ff       	jmp    f0100426 <cons_putc+0xbe>
		cons_putc(' ');
f01004c6:	b8 20 00 00 00       	mov    $0x20,%eax
f01004cb:	e8 98 fe ff ff       	call   f0100368 <cons_putc>
		cons_putc(' ');
f01004d0:	b8 20 00 00 00       	mov    $0x20,%eax
f01004d5:	e8 8e fe ff ff       	call   f0100368 <cons_putc>
		cons_putc(' ');
f01004da:	b8 20 00 00 00       	mov    $0x20,%eax
f01004df:	e8 84 fe ff ff       	call   f0100368 <cons_putc>
		cons_putc(' ');
f01004e4:	b8 20 00 00 00       	mov    $0x20,%eax
f01004e9:	e8 7a fe ff ff       	call   f0100368 <cons_putc>
		cons_putc(' ');
f01004ee:	b8 20 00 00 00       	mov    $0x20,%eax
f01004f3:	e8 70 fe ff ff       	call   f0100368 <cons_putc>
f01004f8:	e9 46 ff ff ff       	jmp    f0100443 <cons_putc+0xdb>
		crt_buf[crt_pos++] = c;		/* write the character */
f01004fd:	0f b7 83 34 02 00 00 	movzwl 0x234(%ebx),%eax
f0100504:	8d 50 01             	lea    0x1(%eax),%edx
f0100507:	66 89 93 34 02 00 00 	mov    %dx,0x234(%ebx)
f010050e:	0f b7 c0             	movzwl %ax,%eax
f0100511:	8b 93 38 02 00 00    	mov    0x238(%ebx),%edx
f0100517:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f010051b:	e9 23 ff ff ff       	jmp    f0100443 <cons_putc+0xdb>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100520:	8b 83 38 02 00 00    	mov    0x238(%ebx),%eax
f0100526:	83 ec 04             	sub    $0x4,%esp
f0100529:	68 00 0f 00 00       	push   $0xf00
f010052e:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100534:	52                   	push   %edx
f0100535:	50                   	push   %eax
f0100536:	e8 00 48 00 00       	call   f0104d3b <memmove>
			crt_buf[i] = 0x0700 | ' ';
f010053b:	8b 93 38 02 00 00    	mov    0x238(%ebx),%edx
f0100541:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100547:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f010054d:	83 c4 10             	add    $0x10,%esp
f0100550:	66 c7 00 20 07       	movw   $0x720,(%eax)
f0100555:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100558:	39 d0                	cmp    %edx,%eax
f010055a:	75 f4                	jne    f0100550 <cons_putc+0x1e8>
		crt_pos -= CRT_COLS;
f010055c:	66 83 ab 34 02 00 00 	subw   $0x50,0x234(%ebx)
f0100563:	50 
f0100564:	e9 e9 fe ff ff       	jmp    f0100452 <cons_putc+0xea>

f0100569 <serial_intr>:
{
f0100569:	e8 dc 01 00 00       	call   f010074a <__x86.get_pc_thunk.ax>
f010056e:	05 86 eb 08 00       	add    $0x8eb86,%eax
	if (serial_exists)
f0100573:	80 b8 40 02 00 00 00 	cmpb   $0x0,0x240(%eax)
f010057a:	75 01                	jne    f010057d <serial_intr+0x14>
f010057c:	c3                   	ret    
{
f010057d:	55                   	push   %ebp
f010057e:	89 e5                	mov    %esp,%ebp
f0100580:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f0100583:	8d 80 e9 10 f7 ff    	lea    -0x8ef17(%eax),%eax
f0100589:	e8 69 fc ff ff       	call   f01001f7 <cons_intr>
}
f010058e:	c9                   	leave  
f010058f:	c3                   	ret    

f0100590 <kbd_intr>:
{
f0100590:	55                   	push   %ebp
f0100591:	89 e5                	mov    %esp,%ebp
f0100593:	83 ec 08             	sub    $0x8,%esp
f0100596:	e8 af 01 00 00       	call   f010074a <__x86.get_pc_thunk.ax>
f010059b:	05 59 eb 08 00       	add    $0x8eb59,%eax
	cons_intr(kbd_proc_data);
f01005a0:	8d 80 4a 11 f7 ff    	lea    -0x8eeb6(%eax),%eax
f01005a6:	e8 4c fc ff ff       	call   f01001f7 <cons_intr>
}
f01005ab:	c9                   	leave  
f01005ac:	c3                   	ret    

f01005ad <cons_getc>:
{
f01005ad:	55                   	push   %ebp
f01005ae:	89 e5                	mov    %esp,%ebp
f01005b0:	53                   	push   %ebx
f01005b1:	83 ec 04             	sub    $0x4,%esp
f01005b4:	e8 20 fc ff ff       	call   f01001d9 <__x86.get_pc_thunk.bx>
f01005b9:	81 c3 3b eb 08 00    	add    $0x8eb3b,%ebx
	serial_intr();
f01005bf:	e8 a5 ff ff ff       	call   f0100569 <serial_intr>
	kbd_intr();
f01005c4:	e8 c7 ff ff ff       	call   f0100590 <kbd_intr>
	if (cons.rpos != cons.wpos) {
f01005c9:	8b 8b 2c 02 00 00    	mov    0x22c(%ebx),%ecx
	return 0;
f01005cf:	b8 00 00 00 00       	mov    $0x0,%eax
	if (cons.rpos != cons.wpos) {
f01005d4:	3b 8b 30 02 00 00    	cmp    0x230(%ebx),%ecx
f01005da:	74 1f                	je     f01005fb <cons_getc+0x4e>
		c = cons.buf[cons.rpos++];
f01005dc:	8d 51 01             	lea    0x1(%ecx),%edx
f01005df:	0f b6 84 0b 2c 00 00 	movzbl 0x2c(%ebx,%ecx,1),%eax
f01005e6:	00 
		if (cons.rpos == CONSBUFSIZE)
f01005e7:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.rpos = 0;
f01005ed:	b9 00 00 00 00       	mov    $0x0,%ecx
f01005f2:	0f 44 d1             	cmove  %ecx,%edx
f01005f5:	89 93 2c 02 00 00    	mov    %edx,0x22c(%ebx)
}
f01005fb:	83 c4 04             	add    $0x4,%esp
f01005fe:	5b                   	pop    %ebx
f01005ff:	5d                   	pop    %ebp
f0100600:	c3                   	ret    

f0100601 <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f0100601:	55                   	push   %ebp
f0100602:	89 e5                	mov    %esp,%ebp
f0100604:	57                   	push   %edi
f0100605:	56                   	push   %esi
f0100606:	53                   	push   %ebx
f0100607:	83 ec 1c             	sub    $0x1c,%esp
f010060a:	e8 ca fb ff ff       	call   f01001d9 <__x86.get_pc_thunk.bx>
f010060f:	81 c3 e5 ea 08 00    	add    $0x8eae5,%ebx
	was = *cp;
f0100615:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010061c:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100623:	5a a5 
	if (*cp != 0xA55A) {
f0100625:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010062c:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100630:	0f 84 bc 00 00 00    	je     f01006f2 <cons_init+0xf1>
		addr_6845 = MONO_BASE;
f0100636:	c7 83 3c 02 00 00 b4 	movl   $0x3b4,0x23c(%ebx)
f010063d:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100640:	c7 45 e4 00 00 0b f0 	movl   $0xf00b0000,-0x1c(%ebp)
	outb(addr_6845, 14);
f0100647:	8b bb 3c 02 00 00    	mov    0x23c(%ebx),%edi
f010064d:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100652:	89 fa                	mov    %edi,%edx
f0100654:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100655:	8d 4f 01             	lea    0x1(%edi),%ecx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100658:	89 ca                	mov    %ecx,%edx
f010065a:	ec                   	in     (%dx),%al
f010065b:	0f b6 f0             	movzbl %al,%esi
f010065e:	c1 e6 08             	shl    $0x8,%esi
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100661:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100666:	89 fa                	mov    %edi,%edx
f0100668:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100669:	89 ca                	mov    %ecx,%edx
f010066b:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f010066c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010066f:	89 bb 38 02 00 00    	mov    %edi,0x238(%ebx)
	pos |= inb(addr_6845 + 1);
f0100675:	0f b6 c0             	movzbl %al,%eax
f0100678:	09 c6                	or     %eax,%esi
	crt_pos = pos;
f010067a:	66 89 b3 34 02 00 00 	mov    %si,0x234(%ebx)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100681:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100686:	89 c8                	mov    %ecx,%eax
f0100688:	ba fa 03 00 00       	mov    $0x3fa,%edx
f010068d:	ee                   	out    %al,(%dx)
f010068e:	bf fb 03 00 00       	mov    $0x3fb,%edi
f0100693:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100698:	89 fa                	mov    %edi,%edx
f010069a:	ee                   	out    %al,(%dx)
f010069b:	b8 0c 00 00 00       	mov    $0xc,%eax
f01006a0:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01006a5:	ee                   	out    %al,(%dx)
f01006a6:	be f9 03 00 00       	mov    $0x3f9,%esi
f01006ab:	89 c8                	mov    %ecx,%eax
f01006ad:	89 f2                	mov    %esi,%edx
f01006af:	ee                   	out    %al,(%dx)
f01006b0:	b8 03 00 00 00       	mov    $0x3,%eax
f01006b5:	89 fa                	mov    %edi,%edx
f01006b7:	ee                   	out    %al,(%dx)
f01006b8:	ba fc 03 00 00       	mov    $0x3fc,%edx
f01006bd:	89 c8                	mov    %ecx,%eax
f01006bf:	ee                   	out    %al,(%dx)
f01006c0:	b8 01 00 00 00       	mov    $0x1,%eax
f01006c5:	89 f2                	mov    %esi,%edx
f01006c7:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006c8:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01006cd:	ec                   	in     (%dx),%al
f01006ce:	89 c1                	mov    %eax,%ecx
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01006d0:	3c ff                	cmp    $0xff,%al
f01006d2:	0f 95 83 40 02 00 00 	setne  0x240(%ebx)
f01006d9:	ba fa 03 00 00       	mov    $0x3fa,%edx
f01006de:	ec                   	in     (%dx),%al
f01006df:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01006e4:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01006e5:	80 f9 ff             	cmp    $0xff,%cl
f01006e8:	74 25                	je     f010070f <cons_init+0x10e>
		cprintf("Serial port does not exist!\n");
}
f01006ea:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01006ed:	5b                   	pop    %ebx
f01006ee:	5e                   	pop    %esi
f01006ef:	5f                   	pop    %edi
f01006f0:	5d                   	pop    %ebp
f01006f1:	c3                   	ret    
		*cp = was;
f01006f2:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01006f9:	c7 83 3c 02 00 00 d4 	movl   $0x3d4,0x23c(%ebx)
f0100700:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100703:	c7 45 e4 00 80 0b f0 	movl   $0xf00b8000,-0x1c(%ebp)
f010070a:	e9 38 ff ff ff       	jmp    f0100647 <cons_init+0x46>
		cprintf("Serial port does not exist!\n");
f010070f:	83 ec 0c             	sub    $0xc,%esp
f0100712:	8d 83 dc 60 f7 ff    	lea    -0x89f24(%ebx),%eax
f0100718:	50                   	push   %eax
f0100719:	e8 19 31 00 00       	call   f0103837 <cprintf>
f010071e:	83 c4 10             	add    $0x10,%esp
}
f0100721:	eb c7                	jmp    f01006ea <cons_init+0xe9>

f0100723 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100723:	55                   	push   %ebp
f0100724:	89 e5                	mov    %esp,%ebp
f0100726:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100729:	8b 45 08             	mov    0x8(%ebp),%eax
f010072c:	e8 37 fc ff ff       	call   f0100368 <cons_putc>
}
f0100731:	c9                   	leave  
f0100732:	c3                   	ret    

f0100733 <getchar>:

int
getchar(void)
{
f0100733:	55                   	push   %ebp
f0100734:	89 e5                	mov    %esp,%ebp
f0100736:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100739:	e8 6f fe ff ff       	call   f01005ad <cons_getc>
f010073e:	85 c0                	test   %eax,%eax
f0100740:	74 f7                	je     f0100739 <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100742:	c9                   	leave  
f0100743:	c3                   	ret    

f0100744 <iscons>:
int
iscons(int fdnum)
{
	// used by readline
	return 1;
}
f0100744:	b8 01 00 00 00       	mov    $0x1,%eax
f0100749:	c3                   	ret    

f010074a <__x86.get_pc_thunk.ax>:
f010074a:	8b 04 24             	mov    (%esp),%eax
f010074d:	c3                   	ret    

f010074e <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f010074e:	55                   	push   %ebp
f010074f:	89 e5                	mov    %esp,%ebp
f0100751:	56                   	push   %esi
f0100752:	53                   	push   %ebx
f0100753:	e8 81 fa ff ff       	call   f01001d9 <__x86.get_pc_thunk.bx>
f0100758:	81 c3 9c e9 08 00    	add    $0x8e99c,%ebx
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f010075e:	83 ec 04             	sub    $0x4,%esp
f0100761:	8d 83 0c 63 f7 ff    	lea    -0x89cf4(%ebx),%eax
f0100767:	50                   	push   %eax
f0100768:	8d 83 2a 63 f7 ff    	lea    -0x89cd6(%ebx),%eax
f010076e:	50                   	push   %eax
f010076f:	8d b3 2f 63 f7 ff    	lea    -0x89cd1(%ebx),%esi
f0100775:	56                   	push   %esi
f0100776:	e8 bc 30 00 00       	call   f0103837 <cprintf>
f010077b:	83 c4 0c             	add    $0xc,%esp
f010077e:	8d 83 dc 63 f7 ff    	lea    -0x89c24(%ebx),%eax
f0100784:	50                   	push   %eax
f0100785:	8d 83 38 63 f7 ff    	lea    -0x89cc8(%ebx),%eax
f010078b:	50                   	push   %eax
f010078c:	56                   	push   %esi
f010078d:	e8 a5 30 00 00       	call   f0103837 <cprintf>
f0100792:	83 c4 0c             	add    $0xc,%esp
f0100795:	8d 83 41 63 f7 ff    	lea    -0x89cbf(%ebx),%eax
f010079b:	50                   	push   %eax
f010079c:	8d 83 58 63 f7 ff    	lea    -0x89ca8(%ebx),%eax
f01007a2:	50                   	push   %eax
f01007a3:	56                   	push   %esi
f01007a4:	e8 8e 30 00 00       	call   f0103837 <cprintf>
	return 0;
}
f01007a9:	b8 00 00 00 00       	mov    $0x0,%eax
f01007ae:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01007b1:	5b                   	pop    %ebx
f01007b2:	5e                   	pop    %esi
f01007b3:	5d                   	pop    %ebp
f01007b4:	c3                   	ret    

f01007b5 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007b5:	55                   	push   %ebp
f01007b6:	89 e5                	mov    %esp,%ebp
f01007b8:	57                   	push   %edi
f01007b9:	56                   	push   %esi
f01007ba:	53                   	push   %ebx
f01007bb:	83 ec 18             	sub    $0x18,%esp
f01007be:	e8 16 fa ff ff       	call   f01001d9 <__x86.get_pc_thunk.bx>
f01007c3:	81 c3 31 e9 08 00    	add    $0x8e931,%ebx
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007c9:	8d 83 62 63 f7 ff    	lea    -0x89c9e(%ebx),%eax
f01007cf:	50                   	push   %eax
f01007d0:	e8 62 30 00 00       	call   f0103837 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01007d5:	83 c4 08             	add    $0x8,%esp
f01007d8:	ff b3 fc ff ff ff    	pushl  -0x4(%ebx)
f01007de:	8d 83 04 64 f7 ff    	lea    -0x89bfc(%ebx),%eax
f01007e4:	50                   	push   %eax
f01007e5:	e8 4d 30 00 00       	call   f0103837 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01007ea:	83 c4 0c             	add    $0xc,%esp
f01007ed:	c7 c7 0c 00 10 f0    	mov    $0xf010000c,%edi
f01007f3:	8d 87 00 00 00 10    	lea    0x10000000(%edi),%eax
f01007f9:	50                   	push   %eax
f01007fa:	57                   	push   %edi
f01007fb:	8d 83 2c 64 f7 ff    	lea    -0x89bd4(%ebx),%eax
f0100801:	50                   	push   %eax
f0100802:	e8 30 30 00 00       	call   f0103837 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100807:	83 c4 0c             	add    $0xc,%esp
f010080a:	c7 c0 3f 51 10 f0    	mov    $0xf010513f,%eax
f0100810:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0100816:	52                   	push   %edx
f0100817:	50                   	push   %eax
f0100818:	8d 83 50 64 f7 ff    	lea    -0x89bb0(%ebx),%eax
f010081e:	50                   	push   %eax
f010081f:	e8 13 30 00 00       	call   f0103837 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100824:	83 c4 0c             	add    $0xc,%esp
f0100827:	c7 c0 00 f1 18 f0    	mov    $0xf018f100,%eax
f010082d:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0100833:	52                   	push   %edx
f0100834:	50                   	push   %eax
f0100835:	8d 83 74 64 f7 ff    	lea    -0x89b8c(%ebx),%eax
f010083b:	50                   	push   %eax
f010083c:	e8 f6 2f 00 00       	call   f0103837 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100841:	83 c4 0c             	add    $0xc,%esp
f0100844:	c7 c6 00 00 19 f0    	mov    $0xf0190000,%esi
f010084a:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f0100850:	50                   	push   %eax
f0100851:	56                   	push   %esi
f0100852:	8d 83 98 64 f7 ff    	lea    -0x89b68(%ebx),%eax
f0100858:	50                   	push   %eax
f0100859:	e8 d9 2f 00 00       	call   f0103837 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f010085e:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f0100861:	29 fe                	sub    %edi,%esi
f0100863:	81 c6 ff 03 00 00    	add    $0x3ff,%esi
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100869:	c1 fe 0a             	sar    $0xa,%esi
f010086c:	56                   	push   %esi
f010086d:	8d 83 bc 64 f7 ff    	lea    -0x89b44(%ebx),%eax
f0100873:	50                   	push   %eax
f0100874:	e8 be 2f 00 00       	call   f0103837 <cprintf>
	return 0;
}
f0100879:	b8 00 00 00 00       	mov    $0x0,%eax
f010087e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100881:	5b                   	pop    %ebx
f0100882:	5e                   	pop    %esi
f0100883:	5f                   	pop    %edi
f0100884:	5d                   	pop    %ebp
f0100885:	c3                   	ret    

f0100886 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100886:	55                   	push   %ebp
f0100887:	89 e5                	mov    %esp,%ebp
f0100889:	57                   	push   %edi
f010088a:	56                   	push   %esi
f010088b:	53                   	push   %ebx
f010088c:	83 ec 48             	sub    $0x48,%esp
f010088f:	e8 45 f9 ff ff       	call   f01001d9 <__x86.get_pc_thunk.bx>
f0100894:	81 c3 60 e8 08 00    	add    $0x8e860,%ebx

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f010089a:	89 ee                	mov    %ebp,%esi
	// Your code here.
	uint32_t ebp, *ptr_ebp;
	ebp = read_ebp();
	cprintf("Stack backtrace:\n");
f010089c:	8d 83 7b 63 f7 ff    	lea    -0x89c85(%ebx),%eax
f01008a2:	50                   	push   %eax
f01008a3:	e8 8f 2f 00 00       	call   f0103837 <cprintf>
	while (ebp != 0) {
f01008a8:	83 c4 10             	add    $0x10,%esp
		ptr_ebp = (uint32_t *)ebp;
		cprintf(" ebp %x  eip %x  args %08x %08x %08x %08x %08x\n", 
f01008ab:	8d 83 e8 64 f7 ff    	lea    -0x89b18(%ebx),%eax
f01008b1:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        		ebp, ptr_ebp[1], ptr_ebp[2], ptr_ebp[3], ptr_ebp[4], ptr_ebp[5], ptr_ebp[6]);
		struct Eipdebuginfo info;
		if (debuginfo_eip(ptr_ebp[1], &info) == 0) {
f01008b4:	8d 45 d0             	lea    -0x30(%ebp),%eax
f01008b7:	89 45 c0             	mov    %eax,-0x40(%ebp)
	while (ebp != 0) {
f01008ba:	eb 27                	jmp    f01008e3 <mon_backtrace+0x5d>
			uint32_t fn_offset = ptr_ebp[1] - info.eip_fn_addr; 
			cprintf(" \t%s:%d: %.*s+%d\n", info.eip_file, info.eip_line\
f01008bc:	83 ec 08             	sub    $0x8,%esp
			uint32_t fn_offset = ptr_ebp[1] - info.eip_fn_addr; 
f01008bf:	8b 46 04             	mov    0x4(%esi),%eax
f01008c2:	2b 45 e0             	sub    -0x20(%ebp),%eax
			cprintf(" \t%s:%d: %.*s+%d\n", info.eip_file, info.eip_line\
f01008c5:	50                   	push   %eax
f01008c6:	ff 75 d8             	pushl  -0x28(%ebp)
f01008c9:	ff 75 dc             	pushl  -0x24(%ebp)
f01008cc:	ff 75 d4             	pushl  -0x2c(%ebp)
f01008cf:	ff 75 d0             	pushl  -0x30(%ebp)
f01008d2:	8d 83 8d 63 f7 ff    	lea    -0x89c73(%ebx),%eax
f01008d8:	50                   	push   %eax
f01008d9:	e8 59 2f 00 00       	call   f0103837 <cprintf>
f01008de:	83 c4 20             	add    $0x20,%esp
							, info.eip_fn_namelen, info.eip_fn_name, fn_offset);
		}
		ebp = *ptr_ebp;
f01008e1:	8b 37                	mov    (%edi),%esi
	while (ebp != 0) {
f01008e3:	85 f6                	test   %esi,%esi
f01008e5:	74 34                	je     f010091b <mon_backtrace+0x95>
		ptr_ebp = (uint32_t *)ebp;
f01008e7:	89 f7                	mov    %esi,%edi
		cprintf(" ebp %x  eip %x  args %08x %08x %08x %08x %08x\n", 
f01008e9:	ff 76 18             	pushl  0x18(%esi)
f01008ec:	ff 76 14             	pushl  0x14(%esi)
f01008ef:	ff 76 10             	pushl  0x10(%esi)
f01008f2:	ff 76 0c             	pushl  0xc(%esi)
f01008f5:	ff 76 08             	pushl  0x8(%esi)
f01008f8:	ff 76 04             	pushl  0x4(%esi)
f01008fb:	56                   	push   %esi
f01008fc:	ff 75 c4             	pushl  -0x3c(%ebp)
f01008ff:	e8 33 2f 00 00       	call   f0103837 <cprintf>
		if (debuginfo_eip(ptr_ebp[1], &info) == 0) {
f0100904:	83 c4 18             	add    $0x18,%esp
f0100907:	ff 75 c0             	pushl  -0x40(%ebp)
f010090a:	ff 76 04             	pushl  0x4(%esi)
f010090d:	e8 eb 38 00 00       	call   f01041fd <debuginfo_eip>
f0100912:	83 c4 10             	add    $0x10,%esp
f0100915:	85 c0                	test   %eax,%eax
f0100917:	75 c8                	jne    f01008e1 <mon_backtrace+0x5b>
f0100919:	eb a1                	jmp    f01008bc <mon_backtrace+0x36>
	}
	return 0;
}
f010091b:	b8 00 00 00 00       	mov    $0x0,%eax
f0100920:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100923:	5b                   	pop    %ebx
f0100924:	5e                   	pop    %esi
f0100925:	5f                   	pop    %edi
f0100926:	5d                   	pop    %ebp
f0100927:	c3                   	ret    

f0100928 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100928:	55                   	push   %ebp
f0100929:	89 e5                	mov    %esp,%ebp
f010092b:	57                   	push   %edi
f010092c:	56                   	push   %esi
f010092d:	53                   	push   %ebx
f010092e:	83 ec 68             	sub    $0x68,%esp
f0100931:	e8 a3 f8 ff ff       	call   f01001d9 <__x86.get_pc_thunk.bx>
f0100936:	81 c3 be e7 08 00    	add    $0x8e7be,%ebx
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f010093c:	8d 83 18 65 f7 ff    	lea    -0x89ae8(%ebx),%eax
f0100942:	50                   	push   %eax
f0100943:	e8 ef 2e 00 00       	call   f0103837 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100948:	8d 83 3c 65 f7 ff    	lea    -0x89ac4(%ebx),%eax
f010094e:	89 04 24             	mov    %eax,(%esp)
f0100951:	e8 e1 2e 00 00       	call   f0103837 <cprintf>

	if (tf != NULL)
f0100956:	83 c4 10             	add    $0x10,%esp
f0100959:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f010095d:	74 0e                	je     f010096d <monitor+0x45>
		print_trapframe(tf);
f010095f:	83 ec 0c             	sub    $0xc,%esp
f0100962:	ff 75 08             	pushl  0x8(%ebp)
f0100965:	e8 d8 33 00 00       	call   f0103d42 <print_trapframe>
f010096a:	83 c4 10             	add    $0x10,%esp
		while (*buf && strchr(WHITESPACE, *buf))
f010096d:	8d 83 a3 63 f7 ff    	lea    -0x89c5d(%ebx),%eax
f0100973:	89 45 a0             	mov    %eax,-0x60(%ebp)
f0100976:	e9 d1 00 00 00       	jmp    f0100a4c <monitor+0x124>
f010097b:	83 ec 08             	sub    $0x8,%esp
f010097e:	0f be c0             	movsbl %al,%eax
f0100981:	50                   	push   %eax
f0100982:	ff 75 a0             	pushl  -0x60(%ebp)
f0100985:	e8 2c 43 00 00       	call   f0104cb6 <strchr>
f010098a:	83 c4 10             	add    $0x10,%esp
f010098d:	85 c0                	test   %eax,%eax
f010098f:	74 6d                	je     f01009fe <monitor+0xd6>
			*buf++ = 0;
f0100991:	c6 06 00             	movb   $0x0,(%esi)
f0100994:	89 7d a4             	mov    %edi,-0x5c(%ebp)
f0100997:	8d 76 01             	lea    0x1(%esi),%esi
f010099a:	8b 7d a4             	mov    -0x5c(%ebp),%edi
		while (*buf && strchr(WHITESPACE, *buf))
f010099d:	0f b6 06             	movzbl (%esi),%eax
f01009a0:	84 c0                	test   %al,%al
f01009a2:	75 d7                	jne    f010097b <monitor+0x53>
	argv[argc] = 0;
f01009a4:	c7 44 bd a8 00 00 00 	movl   $0x0,-0x58(%ebp,%edi,4)
f01009ab:	00 
	if (argc == 0)
f01009ac:	85 ff                	test   %edi,%edi
f01009ae:	0f 84 98 00 00 00    	je     f0100a4c <monitor+0x124>
f01009b4:	8d b3 4c ff ff ff    	lea    -0xb4(%ebx),%esi
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f01009ba:	b8 00 00 00 00       	mov    $0x0,%eax
f01009bf:	89 7d a4             	mov    %edi,-0x5c(%ebp)
f01009c2:	89 c7                	mov    %eax,%edi
		if (strcmp(argv[0], commands[i].name) == 0)
f01009c4:	83 ec 08             	sub    $0x8,%esp
f01009c7:	ff 36                	pushl  (%esi)
f01009c9:	ff 75 a8             	pushl  -0x58(%ebp)
f01009cc:	e8 87 42 00 00       	call   f0104c58 <strcmp>
f01009d1:	83 c4 10             	add    $0x10,%esp
f01009d4:	85 c0                	test   %eax,%eax
f01009d6:	0f 84 99 00 00 00    	je     f0100a75 <monitor+0x14d>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f01009dc:	83 c7 01             	add    $0x1,%edi
f01009df:	83 c6 0c             	add    $0xc,%esi
f01009e2:	83 ff 03             	cmp    $0x3,%edi
f01009e5:	75 dd                	jne    f01009c4 <monitor+0x9c>
	cprintf("Unknown command '%s'\n", argv[0]);
f01009e7:	83 ec 08             	sub    $0x8,%esp
f01009ea:	ff 75 a8             	pushl  -0x58(%ebp)
f01009ed:	8d 83 c5 63 f7 ff    	lea    -0x89c3b(%ebx),%eax
f01009f3:	50                   	push   %eax
f01009f4:	e8 3e 2e 00 00       	call   f0103837 <cprintf>
f01009f9:	83 c4 10             	add    $0x10,%esp
f01009fc:	eb 4e                	jmp    f0100a4c <monitor+0x124>
		if (*buf == 0)
f01009fe:	80 3e 00             	cmpb   $0x0,(%esi)
f0100a01:	74 a1                	je     f01009a4 <monitor+0x7c>
		if (argc == MAXARGS-1) {
f0100a03:	83 ff 0f             	cmp    $0xf,%edi
f0100a06:	74 30                	je     f0100a38 <monitor+0x110>
		argv[argc++] = buf;
f0100a08:	8d 47 01             	lea    0x1(%edi),%eax
f0100a0b:	89 45 a4             	mov    %eax,-0x5c(%ebp)
f0100a0e:	89 74 bd a8          	mov    %esi,-0x58(%ebp,%edi,4)
		while (*buf && !strchr(WHITESPACE, *buf))
f0100a12:	0f b6 06             	movzbl (%esi),%eax
f0100a15:	84 c0                	test   %al,%al
f0100a17:	74 81                	je     f010099a <monitor+0x72>
f0100a19:	83 ec 08             	sub    $0x8,%esp
f0100a1c:	0f be c0             	movsbl %al,%eax
f0100a1f:	50                   	push   %eax
f0100a20:	ff 75 a0             	pushl  -0x60(%ebp)
f0100a23:	e8 8e 42 00 00       	call   f0104cb6 <strchr>
f0100a28:	83 c4 10             	add    $0x10,%esp
f0100a2b:	85 c0                	test   %eax,%eax
f0100a2d:	0f 85 67 ff ff ff    	jne    f010099a <monitor+0x72>
			buf++;
f0100a33:	83 c6 01             	add    $0x1,%esi
f0100a36:	eb da                	jmp    f0100a12 <monitor+0xea>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100a38:	83 ec 08             	sub    $0x8,%esp
f0100a3b:	6a 10                	push   $0x10
f0100a3d:	8d 83 a8 63 f7 ff    	lea    -0x89c58(%ebx),%eax
f0100a43:	50                   	push   %eax
f0100a44:	e8 ee 2d 00 00       	call   f0103837 <cprintf>
f0100a49:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f0100a4c:	8d bb 9f 63 f7 ff    	lea    -0x89c61(%ebx),%edi
f0100a52:	83 ec 0c             	sub    $0xc,%esp
f0100a55:	57                   	push   %edi
f0100a56:	e8 1c 40 00 00       	call   f0104a77 <readline>
		if (buf != NULL)
f0100a5b:	83 c4 10             	add    $0x10,%esp
f0100a5e:	85 c0                	test   %eax,%eax
f0100a60:	74 f0                	je     f0100a52 <monitor+0x12a>
f0100a62:	89 c6                	mov    %eax,%esi
	argv[argc] = 0;
f0100a64:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f0100a6b:	bf 00 00 00 00       	mov    $0x0,%edi
f0100a70:	e9 28 ff ff ff       	jmp    f010099d <monitor+0x75>
f0100a75:	89 f8                	mov    %edi,%eax
f0100a77:	8b 7d a4             	mov    -0x5c(%ebp),%edi
			return commands[i].func(argc, argv, tf);
f0100a7a:	83 ec 04             	sub    $0x4,%esp
f0100a7d:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100a80:	ff 75 08             	pushl  0x8(%ebp)
f0100a83:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100a86:	52                   	push   %edx
f0100a87:	57                   	push   %edi
f0100a88:	ff 94 83 54 ff ff ff 	call   *-0xac(%ebx,%eax,4)
			if (runcmd(buf, tf) < 0)
f0100a8f:	83 c4 10             	add    $0x10,%esp
f0100a92:	85 c0                	test   %eax,%eax
f0100a94:	79 b6                	jns    f0100a4c <monitor+0x124>
				break;
	}
}
f0100a96:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100a99:	5b                   	pop    %ebx
f0100a9a:	5e                   	pop    %esi
f0100a9b:	5f                   	pop    %edi
f0100a9c:	5d                   	pop    %ebp
f0100a9d:	c3                   	ret    

f0100a9e <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100a9e:	e8 51 25 00 00       	call   f0102ff4 <__x86.get_pc_thunk.cx>
f0100aa3:	81 c1 51 e6 08 00    	add    $0x8e651,%ecx
f0100aa9:	89 c2                	mov    %eax,%edx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100aab:	83 b9 44 02 00 00 00 	cmpl   $0x0,0x244(%ecx)
f0100ab2:	74 1b                	je     f0100acf <boot_alloc+0x31>
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	//cprintf("nextfree:%p\n", nextfree);
	result = nextfree;
f0100ab4:	8b 81 44 02 00 00    	mov    0x244(%ecx),%eax
	nextfree += ROUNDUP(n, PGSIZE);
f0100aba:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
f0100ac0:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100ac6:	01 c2                	add    %eax,%edx
f0100ac8:	89 91 44 02 00 00    	mov    %edx,0x244(%ecx)
	return result;
}
f0100ace:	c3                   	ret    
		nextfree = ROUNDUP((char *) end + 16, PGSIZE);		
f0100acf:	c7 c0 00 00 19 f0    	mov    $0xf0190000,%eax
f0100ad5:	05 0f 10 00 00       	add    $0x100f,%eax
f0100ada:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100adf:	89 81 44 02 00 00    	mov    %eax,0x244(%ecx)
f0100ae5:	eb cd                	jmp    f0100ab4 <boot_alloc+0x16>

f0100ae7 <nvram_read>:
{
f0100ae7:	55                   	push   %ebp
f0100ae8:	89 e5                	mov    %esp,%ebp
f0100aea:	57                   	push   %edi
f0100aeb:	56                   	push   %esi
f0100aec:	53                   	push   %ebx
f0100aed:	83 ec 18             	sub    $0x18,%esp
f0100af0:	e8 e4 f6 ff ff       	call   f01001d9 <__x86.get_pc_thunk.bx>
f0100af5:	81 c3 ff e5 08 00    	add    $0x8e5ff,%ebx
f0100afb:	89 c7                	mov    %eax,%edi
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100afd:	50                   	push   %eax
f0100afe:	e8 ad 2c 00 00       	call   f01037b0 <mc146818_read>
f0100b03:	89 c6                	mov    %eax,%esi
f0100b05:	83 c7 01             	add    $0x1,%edi
f0100b08:	89 3c 24             	mov    %edi,(%esp)
f0100b0b:	e8 a0 2c 00 00       	call   f01037b0 <mc146818_read>
f0100b10:	c1 e0 08             	shl    $0x8,%eax
f0100b13:	09 f0                	or     %esi,%eax
}
f0100b15:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100b18:	5b                   	pop    %ebx
f0100b19:	5e                   	pop    %esi
f0100b1a:	5f                   	pop    %edi
f0100b1b:	5d                   	pop    %ebp
f0100b1c:	c3                   	ret    

f0100b1d <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100b1d:	55                   	push   %ebp
f0100b1e:	89 e5                	mov    %esp,%ebp
f0100b20:	56                   	push   %esi
f0100b21:	53                   	push   %ebx
f0100b22:	e8 cd 24 00 00       	call   f0102ff4 <__x86.get_pc_thunk.cx>
f0100b27:	81 c1 cd e5 08 00    	add    $0x8e5cd,%ecx
	pte_t *p;
	pgdir = &pgdir[PDX(va)];
f0100b2d:	89 d3                	mov    %edx,%ebx
f0100b2f:	c1 eb 16             	shr    $0x16,%ebx
	if (!(*pgdir & PTE_P))
f0100b32:	8b 04 98             	mov    (%eax,%ebx,4),%eax
f0100b35:	a8 01                	test   $0x1,%al
f0100b37:	74 5a                	je     f0100b93 <check_va2pa+0x76>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100b39:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100b3e:	89 c6                	mov    %eax,%esi
f0100b40:	c1 ee 0c             	shr    $0xc,%esi
f0100b43:	c7 c3 04 00 19 f0    	mov    $0xf0190004,%ebx
f0100b49:	3b 33                	cmp    (%ebx),%esi
f0100b4b:	73 2b                	jae    f0100b78 <check_va2pa+0x5b>
	if (!(p[PTX(va)] & PTE_P))
f0100b4d:	c1 ea 0c             	shr    $0xc,%edx
f0100b50:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100b56:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100b5d:	89 c2                	mov    %eax,%edx
f0100b5f:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100b62:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b67:	85 d2                	test   %edx,%edx
f0100b69:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100b6e:	0f 44 c2             	cmove  %edx,%eax
}
f0100b71:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100b74:	5b                   	pop    %ebx
f0100b75:	5e                   	pop    %esi
f0100b76:	5d                   	pop    %ebp
f0100b77:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100b78:	50                   	push   %eax
f0100b79:	8d 81 64 65 f7 ff    	lea    -0x89a9c(%ecx),%eax
f0100b7f:	50                   	push   %eax
f0100b80:	68 3c 03 00 00       	push   $0x33c
f0100b85:	8d 81 45 6d f7 ff    	lea    -0x892bb(%ecx),%eax
f0100b8b:	50                   	push   %eax
f0100b8c:	89 cb                	mov    %ecx,%ebx
f0100b8e:	e8 90 f5 ff ff       	call   f0100123 <_panic>
		return ~0;
f0100b93:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100b98:	eb d7                	jmp    f0100b71 <check_va2pa+0x54>

f0100b9a <check_page_free_list>:
{
f0100b9a:	55                   	push   %ebp
f0100b9b:	89 e5                	mov    %esp,%ebp
f0100b9d:	57                   	push   %edi
f0100b9e:	56                   	push   %esi
f0100b9f:	53                   	push   %ebx
f0100ba0:	83 ec 2c             	sub    $0x2c,%esp
f0100ba3:	e8 50 24 00 00       	call   f0102ff8 <__x86.get_pc_thunk.si>
f0100ba8:	81 c6 4c e5 08 00    	add    $0x8e54c,%esi
f0100bae:	89 75 c8             	mov    %esi,-0x38(%ebp)
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100bb1:	84 c0                	test   %al,%al
f0100bb3:	0f 85 ec 02 00 00    	jne    f0100ea5 <check_page_free_list+0x30b>
	if (!page_free_list)
f0100bb9:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0100bbc:	83 b8 48 02 00 00 00 	cmpl   $0x0,0x248(%eax)
f0100bc3:	74 21                	je     f0100be6 <check_page_free_list+0x4c>
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100bc5:	c7 45 d4 00 04 00 00 	movl   $0x400,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100bcc:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0100bcf:	8b b0 48 02 00 00    	mov    0x248(%eax),%esi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100bd5:	c7 c7 0c 00 19 f0    	mov    $0xf019000c,%edi
	if (PGNUM(pa) >= npages)
f0100bdb:	c7 c0 04 00 19 f0    	mov    $0xf0190004,%eax
f0100be1:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100be4:	eb 39                	jmp    f0100c1f <check_page_free_list+0x85>
		panic("'page_free_list' is a null pointer!");
f0100be6:	83 ec 04             	sub    $0x4,%esp
f0100be9:	8b 5d c8             	mov    -0x38(%ebp),%ebx
f0100bec:	8d 83 88 65 f7 ff    	lea    -0x89a78(%ebx),%eax
f0100bf2:	50                   	push   %eax
f0100bf3:	68 71 02 00 00       	push   $0x271
f0100bf8:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f0100bfe:	50                   	push   %eax
f0100bff:	e8 1f f5 ff ff       	call   f0100123 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c04:	50                   	push   %eax
f0100c05:	8b 5d c8             	mov    -0x38(%ebp),%ebx
f0100c08:	8d 83 64 65 f7 ff    	lea    -0x89a9c(%ebx),%eax
f0100c0e:	50                   	push   %eax
f0100c0f:	6a 56                	push   $0x56
f0100c11:	8d 83 51 6d f7 ff    	lea    -0x892af(%ebx),%eax
f0100c17:	50                   	push   %eax
f0100c18:	e8 06 f5 ff ff       	call   f0100123 <_panic>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100c1d:	8b 36                	mov    (%esi),%esi
f0100c1f:	85 f6                	test   %esi,%esi
f0100c21:	74 40                	je     f0100c63 <check_page_free_list+0xc9>
	return (pp - pages) << PGSHIFT;
f0100c23:	89 f0                	mov    %esi,%eax
f0100c25:	2b 07                	sub    (%edi),%eax
f0100c27:	c1 f8 03             	sar    $0x3,%eax
f0100c2a:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100c2d:	89 c2                	mov    %eax,%edx
f0100c2f:	c1 ea 16             	shr    $0x16,%edx
f0100c32:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100c35:	73 e6                	jae    f0100c1d <check_page_free_list+0x83>
	if (PGNUM(pa) >= npages)
f0100c37:	89 c2                	mov    %eax,%edx
f0100c39:	c1 ea 0c             	shr    $0xc,%edx
f0100c3c:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0100c3f:	3b 11                	cmp    (%ecx),%edx
f0100c41:	73 c1                	jae    f0100c04 <check_page_free_list+0x6a>
			memset(page2kva(pp), 0x97, 128);
f0100c43:	83 ec 04             	sub    $0x4,%esp
f0100c46:	68 80 00 00 00       	push   $0x80
f0100c4b:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0100c50:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c55:	50                   	push   %eax
f0100c56:	8b 5d c8             	mov    -0x38(%ebp),%ebx
f0100c59:	e8 95 40 00 00       	call   f0104cf3 <memset>
f0100c5e:	83 c4 10             	add    $0x10,%esp
f0100c61:	eb ba                	jmp    f0100c1d <check_page_free_list+0x83>
	first_free_page = (char *) boot_alloc(0);
f0100c63:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c68:	e8 31 fe ff ff       	call   f0100a9e <boot_alloc>
f0100c6d:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c70:	8b 7d c8             	mov    -0x38(%ebp),%edi
f0100c73:	8b 97 48 02 00 00    	mov    0x248(%edi),%edx
		assert(pp >= pages);
f0100c79:	c7 c0 0c 00 19 f0    	mov    $0xf019000c,%eax
f0100c7f:	8b 08                	mov    (%eax),%ecx
		assert(pp < pages + npages);
f0100c81:	c7 c0 04 00 19 f0    	mov    $0xf0190004,%eax
f0100c87:	8b 00                	mov    (%eax),%eax
f0100c89:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100c8c:	8d 3c c1             	lea    (%ecx,%eax,8),%edi
	int nfree_basemem = 0, nfree_extmem = 0;
f0100c8f:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100c94:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c97:	e9 08 01 00 00       	jmp    f0100da4 <check_page_free_list+0x20a>
		assert(pp >= pages);
f0100c9c:	8b 5d c8             	mov    -0x38(%ebp),%ebx
f0100c9f:	8d 83 5f 6d f7 ff    	lea    -0x892a1(%ebx),%eax
f0100ca5:	50                   	push   %eax
f0100ca6:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f0100cac:	50                   	push   %eax
f0100cad:	68 8b 02 00 00       	push   $0x28b
f0100cb2:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f0100cb8:	50                   	push   %eax
f0100cb9:	e8 65 f4 ff ff       	call   f0100123 <_panic>
		assert(pp < pages + npages);
f0100cbe:	8b 5d c8             	mov    -0x38(%ebp),%ebx
f0100cc1:	8d 83 80 6d f7 ff    	lea    -0x89280(%ebx),%eax
f0100cc7:	50                   	push   %eax
f0100cc8:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f0100cce:	50                   	push   %eax
f0100ccf:	68 8c 02 00 00       	push   $0x28c
f0100cd4:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f0100cda:	50                   	push   %eax
f0100cdb:	e8 43 f4 ff ff       	call   f0100123 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100ce0:	8b 5d c8             	mov    -0x38(%ebp),%ebx
f0100ce3:	8d 83 ac 65 f7 ff    	lea    -0x89a54(%ebx),%eax
f0100ce9:	50                   	push   %eax
f0100cea:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f0100cf0:	50                   	push   %eax
f0100cf1:	68 8d 02 00 00       	push   $0x28d
f0100cf6:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f0100cfc:	50                   	push   %eax
f0100cfd:	e8 21 f4 ff ff       	call   f0100123 <_panic>
		assert(page2pa(pp) != 0);
f0100d02:	8b 5d c8             	mov    -0x38(%ebp),%ebx
f0100d05:	8d 83 94 6d f7 ff    	lea    -0x8926c(%ebx),%eax
f0100d0b:	50                   	push   %eax
f0100d0c:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f0100d12:	50                   	push   %eax
f0100d13:	68 90 02 00 00       	push   $0x290
f0100d18:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f0100d1e:	50                   	push   %eax
f0100d1f:	e8 ff f3 ff ff       	call   f0100123 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100d24:	8b 5d c8             	mov    -0x38(%ebp),%ebx
f0100d27:	8d 83 a5 6d f7 ff    	lea    -0x8925b(%ebx),%eax
f0100d2d:	50                   	push   %eax
f0100d2e:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f0100d34:	50                   	push   %eax
f0100d35:	68 91 02 00 00       	push   $0x291
f0100d3a:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f0100d40:	50                   	push   %eax
f0100d41:	e8 dd f3 ff ff       	call   f0100123 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100d46:	8b 5d c8             	mov    -0x38(%ebp),%ebx
f0100d49:	8d 83 e0 65 f7 ff    	lea    -0x89a20(%ebx),%eax
f0100d4f:	50                   	push   %eax
f0100d50:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f0100d56:	50                   	push   %eax
f0100d57:	68 92 02 00 00       	push   $0x292
f0100d5c:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f0100d62:	50                   	push   %eax
f0100d63:	e8 bb f3 ff ff       	call   f0100123 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100d68:	8b 5d c8             	mov    -0x38(%ebp),%ebx
f0100d6b:	8d 83 be 6d f7 ff    	lea    -0x89242(%ebx),%eax
f0100d71:	50                   	push   %eax
f0100d72:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f0100d78:	50                   	push   %eax
f0100d79:	68 93 02 00 00       	push   $0x293
f0100d7e:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f0100d84:	50                   	push   %eax
f0100d85:	e8 99 f3 ff ff       	call   f0100123 <_panic>
	if (PGNUM(pa) >= npages)
f0100d8a:	89 c3                	mov    %eax,%ebx
f0100d8c:	c1 eb 0c             	shr    $0xc,%ebx
f0100d8f:	39 5d d0             	cmp    %ebx,-0x30(%ebp)
f0100d92:	76 6d                	jbe    f0100e01 <check_page_free_list+0x267>
	return (void *)(pa + KERNBASE);
f0100d94:	2d 00 00 00 10       	sub    $0x10000000,%eax
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100d99:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0100d9c:	77 7c                	ja     f0100e1a <check_page_free_list+0x280>
			++nfree_extmem;
f0100d9e:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100da2:	8b 12                	mov    (%edx),%edx
f0100da4:	85 d2                	test   %edx,%edx
f0100da6:	0f 84 90 00 00 00    	je     f0100e3c <check_page_free_list+0x2a2>
		assert(pp >= pages);
f0100dac:	39 d1                	cmp    %edx,%ecx
f0100dae:	0f 87 e8 fe ff ff    	ja     f0100c9c <check_page_free_list+0x102>
		assert(pp < pages + npages);
f0100db4:	39 d7                	cmp    %edx,%edi
f0100db6:	0f 86 02 ff ff ff    	jbe    f0100cbe <check_page_free_list+0x124>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100dbc:	89 d0                	mov    %edx,%eax
f0100dbe:	29 c8                	sub    %ecx,%eax
f0100dc0:	a8 07                	test   $0x7,%al
f0100dc2:	0f 85 18 ff ff ff    	jne    f0100ce0 <check_page_free_list+0x146>
	return (pp - pages) << PGSHIFT;
f0100dc8:	c1 f8 03             	sar    $0x3,%eax
		assert(page2pa(pp) != 0);
f0100dcb:	c1 e0 0c             	shl    $0xc,%eax
f0100dce:	0f 84 2e ff ff ff    	je     f0100d02 <check_page_free_list+0x168>
		assert(page2pa(pp) != IOPHYSMEM);
f0100dd4:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100dd9:	0f 84 45 ff ff ff    	je     f0100d24 <check_page_free_list+0x18a>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100ddf:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100de4:	0f 84 5c ff ff ff    	je     f0100d46 <check_page_free_list+0x1ac>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100dea:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100def:	0f 84 73 ff ff ff    	je     f0100d68 <check_page_free_list+0x1ce>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100df5:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100dfa:	77 8e                	ja     f0100d8a <check_page_free_list+0x1f0>
			++nfree_basemem;
f0100dfc:	83 c6 01             	add    $0x1,%esi
f0100dff:	eb a1                	jmp    f0100da2 <check_page_free_list+0x208>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100e01:	50                   	push   %eax
f0100e02:	8b 5d c8             	mov    -0x38(%ebp),%ebx
f0100e05:	8d 83 64 65 f7 ff    	lea    -0x89a9c(%ebx),%eax
f0100e0b:	50                   	push   %eax
f0100e0c:	6a 56                	push   $0x56
f0100e0e:	8d 83 51 6d f7 ff    	lea    -0x892af(%ebx),%eax
f0100e14:	50                   	push   %eax
f0100e15:	e8 09 f3 ff ff       	call   f0100123 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100e1a:	8b 5d c8             	mov    -0x38(%ebp),%ebx
f0100e1d:	8d 83 04 66 f7 ff    	lea    -0x899fc(%ebx),%eax
f0100e23:	50                   	push   %eax
f0100e24:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f0100e2a:	50                   	push   %eax
f0100e2b:	68 94 02 00 00       	push   $0x294
f0100e30:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f0100e36:	50                   	push   %eax
f0100e37:	e8 e7 f2 ff ff       	call   f0100123 <_panic>
f0100e3c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
	assert(nfree_basemem > 0);
f0100e3f:	85 f6                	test   %esi,%esi
f0100e41:	7e 1e                	jle    f0100e61 <check_page_free_list+0x2c7>
	assert(nfree_extmem > 0);
f0100e43:	85 db                	test   %ebx,%ebx
f0100e45:	7e 3c                	jle    f0100e83 <check_page_free_list+0x2e9>
	cprintf("check_page_free_list() succeeded!\n");
f0100e47:	83 ec 0c             	sub    $0xc,%esp
f0100e4a:	8b 5d c8             	mov    -0x38(%ebp),%ebx
f0100e4d:	8d 83 4c 66 f7 ff    	lea    -0x899b4(%ebx),%eax
f0100e53:	50                   	push   %eax
f0100e54:	e8 de 29 00 00       	call   f0103837 <cprintf>
}
f0100e59:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e5c:	5b                   	pop    %ebx
f0100e5d:	5e                   	pop    %esi
f0100e5e:	5f                   	pop    %edi
f0100e5f:	5d                   	pop    %ebp
f0100e60:	c3                   	ret    
	assert(nfree_basemem > 0);
f0100e61:	8b 5d c8             	mov    -0x38(%ebp),%ebx
f0100e64:	8d 83 d8 6d f7 ff    	lea    -0x89228(%ebx),%eax
f0100e6a:	50                   	push   %eax
f0100e6b:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f0100e71:	50                   	push   %eax
f0100e72:	68 9c 02 00 00       	push   $0x29c
f0100e77:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f0100e7d:	50                   	push   %eax
f0100e7e:	e8 a0 f2 ff ff       	call   f0100123 <_panic>
	assert(nfree_extmem > 0);
f0100e83:	8b 5d c8             	mov    -0x38(%ebp),%ebx
f0100e86:	8d 83 ea 6d f7 ff    	lea    -0x89216(%ebx),%eax
f0100e8c:	50                   	push   %eax
f0100e8d:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f0100e93:	50                   	push   %eax
f0100e94:	68 9d 02 00 00       	push   $0x29d
f0100e99:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f0100e9f:	50                   	push   %eax
f0100ea0:	e8 7e f2 ff ff       	call   f0100123 <_panic>
	if (!page_free_list)
f0100ea5:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0100ea8:	8b 80 48 02 00 00    	mov    0x248(%eax),%eax
f0100eae:	85 c0                	test   %eax,%eax
f0100eb0:	0f 84 30 fd ff ff    	je     f0100be6 <check_page_free_list+0x4c>
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100eb6:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100eb9:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100ebc:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100ebf:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	return (pp - pages) << PGSHIFT;
f0100ec2:	8b 75 c8             	mov    -0x38(%ebp),%esi
f0100ec5:	c7 c3 0c 00 19 f0    	mov    $0xf019000c,%ebx
f0100ecb:	89 c2                	mov    %eax,%edx
f0100ecd:	2b 13                	sub    (%ebx),%edx
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100ecf:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100ed5:	0f 95 c2             	setne  %dl
f0100ed8:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100edb:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100edf:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100ee1:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100ee5:	8b 00                	mov    (%eax),%eax
f0100ee7:	85 c0                	test   %eax,%eax
f0100ee9:	75 e0                	jne    f0100ecb <check_page_free_list+0x331>
		*tp[1] = 0;
f0100eeb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100eee:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100ef4:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100ef7:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100efa:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100efc:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100eff:	8b 75 c8             	mov    -0x38(%ebp),%esi
f0100f02:	89 86 48 02 00 00    	mov    %eax,0x248(%esi)
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100f08:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
f0100f0f:	e9 b8 fc ff ff       	jmp    f0100bcc <check_page_free_list+0x32>

f0100f14 <page_init>:
{
f0100f14:	55                   	push   %ebp
f0100f15:	89 e5                	mov    %esp,%ebp
f0100f17:	57                   	push   %edi
f0100f18:	56                   	push   %esi
f0100f19:	53                   	push   %ebx
f0100f1a:	83 ec 1c             	sub    $0x1c,%esp
f0100f1d:	e8 da 20 00 00       	call   f0102ffc <__x86.get_pc_thunk.di>
f0100f22:	81 c7 d2 e1 08 00    	add    $0x8e1d2,%edi
f0100f28:	89 fe                	mov    %edi,%esi
f0100f2a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
	pages[0].pp_ref = 1;
f0100f2d:	c7 c0 0c 00 19 f0    	mov    $0xf019000c,%eax
f0100f33:	8b 00                	mov    (%eax),%eax
f0100f35:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
    for (i = 1; i < npages_basemem; i++) {
f0100f3b:	8b bf 4c 02 00 00    	mov    0x24c(%edi),%edi
f0100f41:	8b 9e 48 02 00 00    	mov    0x248(%esi),%ebx
f0100f47:	ba 00 00 00 00       	mov    $0x0,%edx
f0100f4c:	b8 01 00 00 00       	mov    $0x1,%eax
        pages[i].pp_ref = 0;
f0100f51:	c7 c6 0c 00 19 f0    	mov    $0xf019000c,%esi
    for (i = 1; i < npages_basemem; i++) {
f0100f57:	eb 1f                	jmp    f0100f78 <page_init+0x64>
f0100f59:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
        pages[i].pp_ref = 0;
f0100f60:	89 d1                	mov    %edx,%ecx
f0100f62:	03 0e                	add    (%esi),%ecx
f0100f64:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
        pages[i].pp_link = page_free_list;
f0100f6a:	89 19                	mov    %ebx,(%ecx)
    for (i = 1; i < npages_basemem; i++) {
f0100f6c:	83 c0 01             	add    $0x1,%eax
        page_free_list = &pages[i];
f0100f6f:	89 d3                	mov    %edx,%ebx
f0100f71:	03 1e                	add    (%esi),%ebx
f0100f73:	ba 01 00 00 00       	mov    $0x1,%edx
    for (i = 1; i < npages_basemem; i++) {
f0100f78:	39 c7                	cmp    %eax,%edi
f0100f7a:	77 dd                	ja     f0100f59 <page_init+0x45>
f0100f7c:	84 d2                	test   %dl,%dl
f0100f7e:	74 09                	je     f0100f89 <page_init+0x75>
f0100f80:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100f83:	89 98 48 02 00 00    	mov    %ebx,0x248(%eax)
	size_t first_free_address = PADDR(boot_alloc(0));
f0100f89:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f8e:	e8 0b fb ff ff       	call   f0100a9e <boot_alloc>
	if ((uint32_t)kva < KERNBASE)
f0100f93:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100f98:	76 47                	jbe    f0100fe1 <page_init+0xcd>
	return (physaddr_t)kva - KERNBASE;
f0100f9a:	05 00 00 00 10       	add    $0x10000000,%eax
        pages[i].pp_ref = 1;
f0100f9f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100fa2:	c7 c2 0c 00 19 f0    	mov    $0xf019000c,%edx
f0100fa8:	8b 0a                	mov    (%edx),%ecx
f0100faa:	8d 91 04 05 00 00    	lea    0x504(%ecx),%edx
f0100fb0:	81 c1 04 08 00 00    	add    $0x804,%ecx
f0100fb6:	66 c7 02 01 00       	movw   $0x1,(%edx)
f0100fbb:	83 c2 08             	add    $0x8,%edx
    for (i = IOPHYSMEM/PGSIZE; i < EXTPHYSMEM/PGSIZE; i++) {
f0100fbe:	39 ca                	cmp    %ecx,%edx
f0100fc0:	75 f4                	jne    f0100fb6 <page_init+0xa2>
    for (i = first_free_address/PGSIZE; i < npages; i++) {
f0100fc2:	c1 e8 0c             	shr    $0xc,%eax
f0100fc5:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100fc8:	8b 9e 48 02 00 00    	mov    0x248(%esi),%ebx
f0100fce:	ba 00 00 00 00       	mov    $0x0,%edx
f0100fd3:	c7 c7 04 00 19 f0    	mov    $0xf0190004,%edi
        pages[i].pp_ref = 0;
f0100fd9:	c7 c6 0c 00 19 f0    	mov    $0xf019000c,%esi
    for (i = first_free_address/PGSIZE; i < npages; i++) {
f0100fdf:	eb 3b                	jmp    f010101c <page_init+0x108>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100fe1:	50                   	push   %eax
f0100fe2:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100fe5:	8d 83 70 66 f7 ff    	lea    -0x89990(%ebx),%eax
f0100feb:	50                   	push   %eax
f0100fec:	68 2c 01 00 00       	push   $0x12c
f0100ff1:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f0100ff7:	50                   	push   %eax
f0100ff8:	e8 26 f1 ff ff       	call   f0100123 <_panic>
f0100ffd:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
        pages[i].pp_ref = 0;
f0101004:	89 d1                	mov    %edx,%ecx
f0101006:	03 0e                	add    (%esi),%ecx
f0101008:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
        pages[i].pp_link = page_free_list;
f010100e:	89 19                	mov    %ebx,(%ecx)
    for (i = first_free_address/PGSIZE; i < npages; i++) {
f0101010:	83 c0 01             	add    $0x1,%eax
        page_free_list = &pages[i];
f0101013:	89 d3                	mov    %edx,%ebx
f0101015:	03 1e                	add    (%esi),%ebx
f0101017:	ba 01 00 00 00       	mov    $0x1,%edx
    for (i = first_free_address/PGSIZE; i < npages; i++) {
f010101c:	39 07                	cmp    %eax,(%edi)
f010101e:	77 dd                	ja     f0100ffd <page_init+0xe9>
f0101020:	84 d2                	test   %dl,%dl
f0101022:	74 09                	je     f010102d <page_init+0x119>
f0101024:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101027:	89 98 48 02 00 00    	mov    %ebx,0x248(%eax)
}
f010102d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101030:	5b                   	pop    %ebx
f0101031:	5e                   	pop    %esi
f0101032:	5f                   	pop    %edi
f0101033:	5d                   	pop    %ebp
f0101034:	c3                   	ret    

f0101035 <page_alloc>:
{
f0101035:	55                   	push   %ebp
f0101036:	89 e5                	mov    %esp,%ebp
f0101038:	56                   	push   %esi
f0101039:	53                   	push   %ebx
f010103a:	e8 9a f1 ff ff       	call   f01001d9 <__x86.get_pc_thunk.bx>
f010103f:	81 c3 b5 e0 08 00    	add    $0x8e0b5,%ebx
	if (!page_free_list) {
f0101045:	8b b3 48 02 00 00    	mov    0x248(%ebx),%esi
f010104b:	85 f6                	test   %esi,%esi
f010104d:	74 14                	je     f0101063 <page_alloc+0x2e>
	page_free_list = page->pp_link;
f010104f:	8b 06                	mov    (%esi),%eax
f0101051:	89 83 48 02 00 00    	mov    %eax,0x248(%ebx)
	page->pp_link = NULL;
f0101057:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (alloc_flags & ALLOC_ZERO) {
f010105d:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0101061:	75 09                	jne    f010106c <page_alloc+0x37>
}
f0101063:	89 f0                	mov    %esi,%eax
f0101065:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101068:	5b                   	pop    %ebx
f0101069:	5e                   	pop    %esi
f010106a:	5d                   	pop    %ebp
f010106b:	c3                   	ret    
	return (pp - pages) << PGSHIFT;
f010106c:	c7 c0 0c 00 19 f0    	mov    $0xf019000c,%eax
f0101072:	89 f2                	mov    %esi,%edx
f0101074:	2b 10                	sub    (%eax),%edx
f0101076:	89 d0                	mov    %edx,%eax
f0101078:	c1 f8 03             	sar    $0x3,%eax
f010107b:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f010107e:	89 c1                	mov    %eax,%ecx
f0101080:	c1 e9 0c             	shr    $0xc,%ecx
f0101083:	c7 c2 04 00 19 f0    	mov    $0xf0190004,%edx
f0101089:	3b 0a                	cmp    (%edx),%ecx
f010108b:	73 1a                	jae    f01010a7 <page_alloc+0x72>
		memset(page2kva(page), 0, PGSIZE); 
f010108d:	83 ec 04             	sub    $0x4,%esp
f0101090:	68 00 10 00 00       	push   $0x1000
f0101095:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f0101097:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010109c:	50                   	push   %eax
f010109d:	e8 51 3c 00 00       	call   f0104cf3 <memset>
f01010a2:	83 c4 10             	add    $0x10,%esp
f01010a5:	eb bc                	jmp    f0101063 <page_alloc+0x2e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01010a7:	50                   	push   %eax
f01010a8:	8d 83 64 65 f7 ff    	lea    -0x89a9c(%ebx),%eax
f01010ae:	50                   	push   %eax
f01010af:	6a 56                	push   $0x56
f01010b1:	8d 83 51 6d f7 ff    	lea    -0x892af(%ebx),%eax
f01010b7:	50                   	push   %eax
f01010b8:	e8 66 f0 ff ff       	call   f0100123 <_panic>

f01010bd <page_free>:
{
f01010bd:	55                   	push   %ebp
f01010be:	89 e5                	mov    %esp,%ebp
f01010c0:	53                   	push   %ebx
f01010c1:	83 ec 04             	sub    $0x4,%esp
f01010c4:	e8 10 f1 ff ff       	call   f01001d9 <__x86.get_pc_thunk.bx>
f01010c9:	81 c3 2b e0 08 00    	add    $0x8e02b,%ebx
f01010cf:	8b 45 08             	mov    0x8(%ebp),%eax
	if (pp->pp_ref || pp->pp_link) {
f01010d2:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f01010d7:	75 18                	jne    f01010f1 <page_free+0x34>
f01010d9:	83 38 00             	cmpl   $0x0,(%eax)
f01010dc:	75 13                	jne    f01010f1 <page_free+0x34>
	pp->pp_link = page_free_list;
f01010de:	8b 8b 48 02 00 00    	mov    0x248(%ebx),%ecx
f01010e4:	89 08                	mov    %ecx,(%eax)
	page_free_list = pp;
f01010e6:	89 83 48 02 00 00    	mov    %eax,0x248(%ebx)
}
f01010ec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01010ef:	c9                   	leave  
f01010f0:	c3                   	ret    
		panic("page_free: double check failed when dealloc page. '\n");
f01010f1:	83 ec 04             	sub    $0x4,%esp
f01010f4:	8d 83 94 66 f7 ff    	lea    -0x8996c(%ebx),%eax
f01010fa:	50                   	push   %eax
f01010fb:	68 67 01 00 00       	push   $0x167
f0101100:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f0101106:	50                   	push   %eax
f0101107:	e8 17 f0 ff ff       	call   f0100123 <_panic>

f010110c <page_decref>:
{
f010110c:	55                   	push   %ebp
f010110d:	89 e5                	mov    %esp,%ebp
f010110f:	83 ec 08             	sub    $0x8,%esp
f0101112:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0101115:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0101119:	83 e8 01             	sub    $0x1,%eax
f010111c:	66 89 42 04          	mov    %ax,0x4(%edx)
f0101120:	66 85 c0             	test   %ax,%ax
f0101123:	74 02                	je     f0101127 <page_decref+0x1b>
}
f0101125:	c9                   	leave  
f0101126:	c3                   	ret    
		page_free(pp);
f0101127:	83 ec 0c             	sub    $0xc,%esp
f010112a:	52                   	push   %edx
f010112b:	e8 8d ff ff ff       	call   f01010bd <page_free>
f0101130:	83 c4 10             	add    $0x10,%esp
}
f0101133:	eb f0                	jmp    f0101125 <page_decref+0x19>

f0101135 <pgdir_walk>:
{
f0101135:	55                   	push   %ebp
f0101136:	89 e5                	mov    %esp,%ebp
f0101138:	57                   	push   %edi
f0101139:	56                   	push   %esi
f010113a:	53                   	push   %ebx
f010113b:	83 ec 0c             	sub    $0xc,%esp
f010113e:	e8 96 f0 ff ff       	call   f01001d9 <__x86.get_pc_thunk.bx>
f0101143:	81 c3 b1 df 08 00    	add    $0x8dfb1,%ebx
f0101149:	8b 45 0c             	mov    0xc(%ebp),%eax
	uint32_t ptx = PTX(va);		
f010114c:	89 c6                	mov    %eax,%esi
f010114e:	c1 ee 0c             	shr    $0xc,%esi
f0101151:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
	uint32_t pdx = PDX(va);		
f0101157:	c1 e8 16             	shr    $0x16,%eax
	if (pgdir[pdx] & PTE_P) {
f010115a:	8d 3c 85 00 00 00 00 	lea    0x0(,%eax,4),%edi
f0101161:	03 7d 08             	add    0x8(%ebp),%edi
f0101164:	8b 07                	mov    (%edi),%eax
f0101166:	a8 01                	test   $0x1,%al
f0101168:	74 3d                	je     f01011a7 <pgdir_walk+0x72>
		pgtab = KADDR(PTE_ADDR(pgdir[pdx]));
f010116a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f010116f:	89 c2                	mov    %eax,%edx
f0101171:	c1 ea 0c             	shr    $0xc,%edx
f0101174:	c7 c1 04 00 19 f0    	mov    $0xf0190004,%ecx
f010117a:	39 11                	cmp    %edx,(%ecx)
f010117c:	76 10                	jbe    f010118e <pgdir_walk+0x59>
	return (void *)(pa + KERNBASE);
f010117e:	2d 00 00 00 10       	sub    $0x10000000,%eax
	return &pgtab[ptx];
f0101183:	8d 04 b0             	lea    (%eax,%esi,4),%eax
}
f0101186:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101189:	5b                   	pop    %ebx
f010118a:	5e                   	pop    %esi
f010118b:	5f                   	pop    %edi
f010118c:	5d                   	pop    %ebp
f010118d:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010118e:	50                   	push   %eax
f010118f:	8d 83 64 65 f7 ff    	lea    -0x89a9c(%ebx),%eax
f0101195:	50                   	push   %eax
f0101196:	68 97 01 00 00       	push   $0x197
f010119b:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f01011a1:	50                   	push   %eax
f01011a2:	e8 7c ef ff ff       	call   f0100123 <_panic>
		if (create) {
f01011a7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01011ab:	74 58                	je     f0101205 <pgdir_walk+0xd0>
			struct PageInfo *new_pginfo = page_alloc(ALLOC_ZERO);	
f01011ad:	83 ec 0c             	sub    $0xc,%esp
f01011b0:	6a 01                	push   $0x1
f01011b2:	e8 7e fe ff ff       	call   f0101035 <page_alloc>
			if (new_pginfo) {
f01011b7:	83 c4 10             	add    $0x10,%esp
f01011ba:	85 c0                	test   %eax,%eax
f01011bc:	74 51                	je     f010120f <pgdir_walk+0xda>
				new_pginfo->pp_ref += 1;
f01011be:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f01011c3:	c7 c2 0c 00 19 f0    	mov    $0xf019000c,%edx
f01011c9:	2b 02                	sub    (%edx),%eax
f01011cb:	89 c2                	mov    %eax,%edx
f01011cd:	c1 fa 03             	sar    $0x3,%edx
f01011d0:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f01011d3:	89 d1                	mov    %edx,%ecx
f01011d5:	c1 e9 0c             	shr    $0xc,%ecx
f01011d8:	c7 c0 04 00 19 f0    	mov    $0xf0190004,%eax
f01011de:	3b 08                	cmp    (%eax),%ecx
f01011e0:	73 0d                	jae    f01011ef <pgdir_walk+0xba>
	return (void *)(pa + KERNBASE);
f01011e2:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
				pgdir[pdx] = page2pa(new_pginfo) | PTE_P | PTE_W | PTE_U;
f01011e8:	83 ca 07             	or     $0x7,%edx
f01011eb:	89 17                	mov    %edx,(%edi)
f01011ed:	eb 94                	jmp    f0101183 <pgdir_walk+0x4e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01011ef:	52                   	push   %edx
f01011f0:	8d 83 64 65 f7 ff    	lea    -0x89a9c(%ebx),%eax
f01011f6:	50                   	push   %eax
f01011f7:	6a 56                	push   $0x56
f01011f9:	8d 83 51 6d f7 ff    	lea    -0x892af(%ebx),%eax
f01011ff:	50                   	push   %eax
f0101200:	e8 1e ef ff ff       	call   f0100123 <_panic>
			return NULL;
f0101205:	b8 00 00 00 00       	mov    $0x0,%eax
f010120a:	e9 77 ff ff ff       	jmp    f0101186 <pgdir_walk+0x51>
			return NULL; 
f010120f:	b8 00 00 00 00       	mov    $0x0,%eax
f0101214:	e9 6d ff ff ff       	jmp    f0101186 <pgdir_walk+0x51>

f0101219 <boot_map_region>:
{
f0101219:	55                   	push   %ebp
f010121a:	89 e5                	mov    %esp,%ebp
f010121c:	57                   	push   %edi
f010121d:	56                   	push   %esi
f010121e:	53                   	push   %ebx
f010121f:	83 ec 1c             	sub    $0x1c,%esp
f0101222:	89 c7                	mov    %eax,%edi
f0101224:	8b 45 08             	mov    0x8(%ebp),%eax
f0101227:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f010122d:	01 c1                	add    %eax,%ecx
f010122f:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	for (size_t i = 0;i < pg_num; i++) {
f0101232:	89 c3                	mov    %eax,%ebx
		pte = pgdir_walk(pgdir, (void *)va, 1);		 
f0101234:	89 d6                	mov    %edx,%esi
f0101236:	29 c6                	sub    %eax,%esi
	for (size_t i = 0;i < pg_num; i++) {
f0101238:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f010123b:	74 28                	je     f0101265 <boot_map_region+0x4c>
		pte = pgdir_walk(pgdir, (void *)va, 1);		 
f010123d:	83 ec 04             	sub    $0x4,%esp
f0101240:	6a 01                	push   $0x1
f0101242:	8d 04 1e             	lea    (%esi,%ebx,1),%eax
f0101245:	50                   	push   %eax
f0101246:	57                   	push   %edi
f0101247:	e8 e9 fe ff ff       	call   f0101135 <pgdir_walk>
		if (!pte) {
f010124c:	83 c4 10             	add    $0x10,%esp
f010124f:	85 c0                	test   %eax,%eax
f0101251:	74 12                	je     f0101265 <boot_map_region+0x4c>
		*pte = pa | perm | PTE_P;
f0101253:	89 da                	mov    %ebx,%edx
f0101255:	0b 55 0c             	or     0xc(%ebp),%edx
f0101258:	83 ca 01             	or     $0x1,%edx
f010125b:	89 10                	mov    %edx,(%eax)
		pa += PGSIZE;
f010125d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0101263:	eb d3                	jmp    f0101238 <boot_map_region+0x1f>
}
f0101265:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101268:	5b                   	pop    %ebx
f0101269:	5e                   	pop    %esi
f010126a:	5f                   	pop    %edi
f010126b:	5d                   	pop    %ebp
f010126c:	c3                   	ret    

f010126d <page_lookup>:
{
f010126d:	55                   	push   %ebp
f010126e:	89 e5                	mov    %esp,%ebp
f0101270:	53                   	push   %ebx
f0101271:	83 ec 08             	sub    $0x8,%esp
f0101274:	e8 60 ef ff ff       	call   f01001d9 <__x86.get_pc_thunk.bx>
f0101279:	81 c3 7b de 08 00    	add    $0x8de7b,%ebx
	pte_t *pte = pgdir_walk(pgdir, va, 0);
f010127f:	6a 00                	push   $0x0
f0101281:	ff 75 0c             	pushl  0xc(%ebp)
f0101284:	ff 75 08             	pushl  0x8(%ebp)
f0101287:	e8 a9 fe ff ff       	call   f0101135 <pgdir_walk>
	if (!pte) {
f010128c:	83 c4 10             	add    $0x10,%esp
f010128f:	85 c0                	test   %eax,%eax
f0101291:	74 47                	je     f01012da <page_lookup+0x6d>
		*pte_store = pte;
f0101293:	8b 55 10             	mov    0x10(%ebp),%edx
f0101296:	89 02                	mov    %eax,(%edx)
	 	if (*pte) {
f0101298:	8b 10                	mov    (%eax),%edx
	return NULL;
f010129a:	b8 00 00 00 00       	mov    $0x0,%eax
	 	if (*pte) {
f010129f:	85 d2                	test   %edx,%edx
f01012a1:	75 05                	jne    f01012a8 <page_lookup+0x3b>
}
f01012a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01012a6:	c9                   	leave  
f01012a7:	c3                   	ret    
f01012a8:	c1 ea 0c             	shr    $0xc,%edx
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01012ab:	c7 c0 04 00 19 f0    	mov    $0xf0190004,%eax
f01012b1:	39 10                	cmp    %edx,(%eax)
f01012b3:	76 0d                	jbe    f01012c2 <page_lookup+0x55>
		panic("pa2page called with invalid pa");
	return &pages[PGNUM(pa)];
f01012b5:	c7 c0 0c 00 19 f0    	mov    $0xf019000c,%eax
f01012bb:	8b 00                	mov    (%eax),%eax
f01012bd:	8d 04 d0             	lea    (%eax,%edx,8),%eax
			return pa2page(PTE_ADDR(*pte)); 
f01012c0:	eb e1                	jmp    f01012a3 <page_lookup+0x36>
		panic("pa2page called with invalid pa");
f01012c2:	83 ec 04             	sub    $0x4,%esp
f01012c5:	8d 83 cc 66 f7 ff    	lea    -0x89934(%ebx),%eax
f01012cb:	50                   	push   %eax
f01012cc:	6a 4f                	push   $0x4f
f01012ce:	8d 83 51 6d f7 ff    	lea    -0x892af(%ebx),%eax
f01012d4:	50                   	push   %eax
f01012d5:	e8 49 ee ff ff       	call   f0100123 <_panic>
		 return NULL;
f01012da:	b8 00 00 00 00       	mov    $0x0,%eax
f01012df:	eb c2                	jmp    f01012a3 <page_lookup+0x36>

f01012e1 <page_remove>:
{
f01012e1:	55                   	push   %ebp
f01012e2:	89 e5                	mov    %esp,%ebp
f01012e4:	53                   	push   %ebx
f01012e5:	83 ec 18             	sub    $0x18,%esp
f01012e8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct PageInfo *pginfo = page_lookup(pgdir, va, pte_store);
f01012eb:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01012ee:	50                   	push   %eax
f01012ef:	53                   	push   %ebx
f01012f0:	ff 75 08             	pushl  0x8(%ebp)
f01012f3:	e8 75 ff ff ff       	call   f010126d <page_lookup>
	if (pginfo) {
f01012f8:	83 c4 10             	add    $0x10,%esp
f01012fb:	85 c0                	test   %eax,%eax
f01012fd:	74 18                	je     f0101317 <page_remove+0x36>
		page_decref(pginfo);
f01012ff:	83 ec 0c             	sub    $0xc,%esp
f0101302:	50                   	push   %eax
f0101303:	e8 04 fe ff ff       	call   f010110c <page_decref>
		*pte = 0;	 
f0101308:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010130b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101311:	0f 01 3b             	invlpg (%ebx)
f0101314:	83 c4 10             	add    $0x10,%esp
}
f0101317:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010131a:	c9                   	leave  
f010131b:	c3                   	ret    

f010131c <page_insert>:
{
f010131c:	55                   	push   %ebp
f010131d:	89 e5                	mov    %esp,%ebp
f010131f:	57                   	push   %edi
f0101320:	56                   	push   %esi
f0101321:	53                   	push   %ebx
f0101322:	83 ec 10             	sub    $0x10,%esp
f0101325:	e8 d2 1c 00 00       	call   f0102ffc <__x86.get_pc_thunk.di>
f010132a:	81 c7 ca dd 08 00    	add    $0x8ddca,%edi
f0101330:	8b 75 0c             	mov    0xc(%ebp),%esi
	pte_t *pte = pgdir_walk(pgdir, va, 1);	
f0101333:	6a 01                	push   $0x1
f0101335:	ff 75 10             	pushl  0x10(%ebp)
f0101338:	ff 75 08             	pushl  0x8(%ebp)
f010133b:	e8 f5 fd ff ff       	call   f0101135 <pgdir_walk>
	if (!pte) {
f0101340:	83 c4 10             	add    $0x10,%esp
f0101343:	85 c0                	test   %eax,%eax
f0101345:	74 44                	je     f010138b <page_insert+0x6f>
f0101347:	89 c3                	mov    %eax,%ebx
	pp->pp_ref++;
f0101349:	66 83 46 04 01       	addw   $0x1,0x4(%esi)
	if (*pte & PTE_P) {
f010134e:	f6 00 01             	testb  $0x1,(%eax)
f0101351:	75 25                	jne    f0101378 <page_insert+0x5c>
	return (pp - pages) << PGSHIFT;
f0101353:	c7 c0 0c 00 19 f0    	mov    $0xf019000c,%eax
f0101359:	2b 30                	sub    (%eax),%esi
f010135b:	89 f0                	mov    %esi,%eax
f010135d:	c1 f8 03             	sar    $0x3,%eax
f0101360:	c1 e0 0c             	shl    $0xc,%eax
	*pte = page2pa(pp) | perm | PTE_P;
f0101363:	0b 45 14             	or     0x14(%ebp),%eax
f0101366:	83 c8 01             	or     $0x1,%eax
f0101369:	89 03                	mov    %eax,(%ebx)
	return 0;
f010136b:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101370:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101373:	5b                   	pop    %ebx
f0101374:	5e                   	pop    %esi
f0101375:	5f                   	pop    %edi
f0101376:	5d                   	pop    %ebp
f0101377:	c3                   	ret    
		 page_remove(pgdir, va);
f0101378:	83 ec 08             	sub    $0x8,%esp
f010137b:	ff 75 10             	pushl  0x10(%ebp)
f010137e:	ff 75 08             	pushl  0x8(%ebp)
f0101381:	e8 5b ff ff ff       	call   f01012e1 <page_remove>
f0101386:	83 c4 10             	add    $0x10,%esp
f0101389:	eb c8                	jmp    f0101353 <page_insert+0x37>
		 return -E_NO_MEM;
f010138b:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0101390:	eb de                	jmp    f0101370 <page_insert+0x54>

f0101392 <mem_init>:
{
f0101392:	55                   	push   %ebp
f0101393:	89 e5                	mov    %esp,%ebp
f0101395:	57                   	push   %edi
f0101396:	56                   	push   %esi
f0101397:	53                   	push   %ebx
f0101398:	83 ec 3c             	sub    $0x3c,%esp
f010139b:	e8 39 ee ff ff       	call   f01001d9 <__x86.get_pc_thunk.bx>
f01013a0:	81 c3 54 dd 08 00    	add    $0x8dd54,%ebx
	basemem = nvram_read(NVRAM_BASELO);
f01013a6:	b8 15 00 00 00       	mov    $0x15,%eax
f01013ab:	e8 37 f7 ff ff       	call   f0100ae7 <nvram_read>
f01013b0:	89 c6                	mov    %eax,%esi
	extmem = nvram_read(NVRAM_EXTLO);
f01013b2:	b8 17 00 00 00       	mov    $0x17,%eax
f01013b7:	e8 2b f7 ff ff       	call   f0100ae7 <nvram_read>
f01013bc:	89 c7                	mov    %eax,%edi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f01013be:	b8 34 00 00 00       	mov    $0x34,%eax
f01013c3:	e8 1f f7 ff ff       	call   f0100ae7 <nvram_read>
	if (ext16mem)
f01013c8:	c1 e0 06             	shl    $0x6,%eax
f01013cb:	0f 84 ec 00 00 00    	je     f01014bd <mem_init+0x12b>
		totalmem = 16 * 1024 + ext16mem;
f01013d1:	05 00 40 00 00       	add    $0x4000,%eax
	npages = totalmem / (PGSIZE / 1024);
f01013d6:	89 c1                	mov    %eax,%ecx
f01013d8:	c1 e9 02             	shr    $0x2,%ecx
f01013db:	c7 c2 04 00 19 f0    	mov    $0xf0190004,%edx
f01013e1:	89 0a                	mov    %ecx,(%edx)
	npages_basemem = basemem / (PGSIZE / 1024);
f01013e3:	89 f2                	mov    %esi,%edx
f01013e5:	c1 ea 02             	shr    $0x2,%edx
f01013e8:	89 93 4c 02 00 00    	mov    %edx,0x24c(%ebx)
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01013ee:	89 c2                	mov    %eax,%edx
f01013f0:	29 f2                	sub    %esi,%edx
f01013f2:	52                   	push   %edx
f01013f3:	56                   	push   %esi
f01013f4:	50                   	push   %eax
f01013f5:	8d 83 ec 66 f7 ff    	lea    -0x89914(%ebx),%eax
f01013fb:	50                   	push   %eax
f01013fc:	e8 36 24 00 00       	call   f0103837 <cprintf>
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0101401:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101406:	e8 93 f6 ff ff       	call   f0100a9e <boot_alloc>
f010140b:	c7 c6 08 00 19 f0    	mov    $0xf0190008,%esi
f0101411:	89 06                	mov    %eax,(%esi)
	memset(kern_pgdir, 0, PGSIZE);
f0101413:	83 c4 0c             	add    $0xc,%esp
f0101416:	68 00 10 00 00       	push   $0x1000
f010141b:	6a 00                	push   $0x0
f010141d:	50                   	push   %eax
f010141e:	e8 d0 38 00 00       	call   f0104cf3 <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101423:	8b 06                	mov    (%esi),%eax
	if ((uint32_t)kva < KERNBASE)
f0101425:	83 c4 10             	add    $0x10,%esp
f0101428:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010142d:	0f 86 9a 00 00 00    	jbe    f01014cd <mem_init+0x13b>
	return (physaddr_t)kva - KERNBASE;
f0101433:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101439:	83 ca 05             	or     $0x5,%edx
f010143c:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	pages = (struct PageInfo*) boot_alloc(npages * sizeof(struct PageInfo));
f0101442:	c7 c7 04 00 19 f0    	mov    $0xf0190004,%edi
f0101448:	8b 07                	mov    (%edi),%eax
f010144a:	c1 e0 03             	shl    $0x3,%eax
f010144d:	e8 4c f6 ff ff       	call   f0100a9e <boot_alloc>
f0101452:	c7 c6 0c 00 19 f0    	mov    $0xf019000c,%esi
f0101458:	89 06                	mov    %eax,(%esi)
	memset(pages, 0, npages * sizeof(struct PageInfo));
f010145a:	83 ec 04             	sub    $0x4,%esp
f010145d:	8b 17                	mov    (%edi),%edx
f010145f:	c1 e2 03             	shl    $0x3,%edx
f0101462:	52                   	push   %edx
f0101463:	6a 00                	push   $0x0
f0101465:	50                   	push   %eax
f0101466:	e8 88 38 00 00       	call   f0104cf3 <memset>
	envs = (struct Env*) boot_alloc(NENV * sizeof(struct Env));
f010146b:	b8 00 80 01 00       	mov    $0x18000,%eax
f0101470:	e8 29 f6 ff ff       	call   f0100a9e <boot_alloc>
f0101475:	c7 c2 48 f3 18 f0    	mov    $0xf018f348,%edx
f010147b:	89 02                	mov    %eax,(%edx)
	memset(envs, 0, NENV * sizeof(struct Env));
f010147d:	83 c4 0c             	add    $0xc,%esp
f0101480:	68 00 80 01 00       	push   $0x18000
f0101485:	6a 00                	push   $0x0
f0101487:	50                   	push   %eax
f0101488:	e8 66 38 00 00       	call   f0104cf3 <memset>
	page_init();
f010148d:	e8 82 fa ff ff       	call   f0100f14 <page_init>
	check_page_free_list(1);
f0101492:	b8 01 00 00 00       	mov    $0x1,%eax
f0101497:	e8 fe f6 ff ff       	call   f0100b9a <check_page_free_list>
	if (!pages)
f010149c:	83 c4 10             	add    $0x10,%esp
f010149f:	83 3e 00             	cmpl   $0x0,(%esi)
f01014a2:	74 42                	je     f01014e6 <mem_init+0x154>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01014a4:	8b 83 48 02 00 00    	mov    0x248(%ebx),%eax
f01014aa:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
f01014b1:	85 c0                	test   %eax,%eax
f01014b3:	74 4c                	je     f0101501 <mem_init+0x16f>
		++nfree;
f01014b5:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01014b9:	8b 00                	mov    (%eax),%eax
f01014bb:	eb f4                	jmp    f01014b1 <mem_init+0x11f>
		totalmem = 1 * 1024 + extmem;
f01014bd:	8d 87 00 04 00 00    	lea    0x400(%edi),%eax
f01014c3:	85 ff                	test   %edi,%edi
f01014c5:	0f 44 c6             	cmove  %esi,%eax
f01014c8:	e9 09 ff ff ff       	jmp    f01013d6 <mem_init+0x44>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01014cd:	50                   	push   %eax
f01014ce:	8d 83 70 66 f7 ff    	lea    -0x89990(%ebx),%eax
f01014d4:	50                   	push   %eax
f01014d5:	68 a1 00 00 00       	push   $0xa1
f01014da:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f01014e0:	50                   	push   %eax
f01014e1:	e8 3d ec ff ff       	call   f0100123 <_panic>
		panic("'pages' is a null pointer!");
f01014e6:	83 ec 04             	sub    $0x4,%esp
f01014e9:	8d 83 fb 6d f7 ff    	lea    -0x89205(%ebx),%eax
f01014ef:	50                   	push   %eax
f01014f0:	68 b0 02 00 00       	push   $0x2b0
f01014f5:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f01014fb:	50                   	push   %eax
f01014fc:	e8 22 ec ff ff       	call   f0100123 <_panic>
	assert((pp0 = page_alloc(0)));
f0101501:	83 ec 0c             	sub    $0xc,%esp
f0101504:	6a 00                	push   $0x0
f0101506:	e8 2a fb ff ff       	call   f0101035 <page_alloc>
f010150b:	89 c6                	mov    %eax,%esi
f010150d:	83 c4 10             	add    $0x10,%esp
f0101510:	85 c0                	test   %eax,%eax
f0101512:	0f 84 20 02 00 00    	je     f0101738 <mem_init+0x3a6>
	assert((pp1 = page_alloc(0)));
f0101518:	83 ec 0c             	sub    $0xc,%esp
f010151b:	6a 00                	push   $0x0
f010151d:	e8 13 fb ff ff       	call   f0101035 <page_alloc>
f0101522:	89 c7                	mov    %eax,%edi
f0101524:	83 c4 10             	add    $0x10,%esp
f0101527:	85 c0                	test   %eax,%eax
f0101529:	0f 84 28 02 00 00    	je     f0101757 <mem_init+0x3c5>
	assert((pp2 = page_alloc(0)));
f010152f:	83 ec 0c             	sub    $0xc,%esp
f0101532:	6a 00                	push   $0x0
f0101534:	e8 fc fa ff ff       	call   f0101035 <page_alloc>
f0101539:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010153c:	83 c4 10             	add    $0x10,%esp
f010153f:	85 c0                	test   %eax,%eax
f0101541:	0f 84 2f 02 00 00    	je     f0101776 <mem_init+0x3e4>
	assert(pp1 && pp1 != pp0);
f0101547:	39 fe                	cmp    %edi,%esi
f0101549:	0f 84 46 02 00 00    	je     f0101795 <mem_init+0x403>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010154f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101552:	39 c7                	cmp    %eax,%edi
f0101554:	0f 84 5a 02 00 00    	je     f01017b4 <mem_init+0x422>
f010155a:	39 c6                	cmp    %eax,%esi
f010155c:	0f 84 52 02 00 00    	je     f01017b4 <mem_init+0x422>
	return (pp - pages) << PGSHIFT;
f0101562:	c7 c0 0c 00 19 f0    	mov    $0xf019000c,%eax
f0101568:	8b 08                	mov    (%eax),%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f010156a:	c7 c0 04 00 19 f0    	mov    $0xf0190004,%eax
f0101570:	8b 10                	mov    (%eax),%edx
f0101572:	c1 e2 0c             	shl    $0xc,%edx
f0101575:	89 f0                	mov    %esi,%eax
f0101577:	29 c8                	sub    %ecx,%eax
f0101579:	c1 f8 03             	sar    $0x3,%eax
f010157c:	c1 e0 0c             	shl    $0xc,%eax
f010157f:	39 d0                	cmp    %edx,%eax
f0101581:	0f 83 4c 02 00 00    	jae    f01017d3 <mem_init+0x441>
f0101587:	89 f8                	mov    %edi,%eax
f0101589:	29 c8                	sub    %ecx,%eax
f010158b:	c1 f8 03             	sar    $0x3,%eax
f010158e:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp1) < npages*PGSIZE);
f0101591:	39 c2                	cmp    %eax,%edx
f0101593:	0f 86 59 02 00 00    	jbe    f01017f2 <mem_init+0x460>
f0101599:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010159c:	29 c8                	sub    %ecx,%eax
f010159e:	c1 f8 03             	sar    $0x3,%eax
f01015a1:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp2) < npages*PGSIZE);
f01015a4:	39 c2                	cmp    %eax,%edx
f01015a6:	0f 86 65 02 00 00    	jbe    f0101811 <mem_init+0x47f>
	fl = page_free_list;
f01015ac:	8b 83 48 02 00 00    	mov    0x248(%ebx),%eax
f01015b2:	89 45 cc             	mov    %eax,-0x34(%ebp)
	page_free_list = 0;
f01015b5:	c7 83 48 02 00 00 00 	movl   $0x0,0x248(%ebx)
f01015bc:	00 00 00 
	assert(!page_alloc(0));
f01015bf:	83 ec 0c             	sub    $0xc,%esp
f01015c2:	6a 00                	push   $0x0
f01015c4:	e8 6c fa ff ff       	call   f0101035 <page_alloc>
f01015c9:	83 c4 10             	add    $0x10,%esp
f01015cc:	85 c0                	test   %eax,%eax
f01015ce:	0f 85 5c 02 00 00    	jne    f0101830 <mem_init+0x49e>
	page_free(pp0);
f01015d4:	83 ec 0c             	sub    $0xc,%esp
f01015d7:	56                   	push   %esi
f01015d8:	e8 e0 fa ff ff       	call   f01010bd <page_free>
	page_free(pp1);
f01015dd:	89 3c 24             	mov    %edi,(%esp)
f01015e0:	e8 d8 fa ff ff       	call   f01010bd <page_free>
	page_free(pp2);
f01015e5:	83 c4 04             	add    $0x4,%esp
f01015e8:	ff 75 d4             	pushl  -0x2c(%ebp)
f01015eb:	e8 cd fa ff ff       	call   f01010bd <page_free>
	assert((pp0 = page_alloc(0)));
f01015f0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01015f7:	e8 39 fa ff ff       	call   f0101035 <page_alloc>
f01015fc:	89 c6                	mov    %eax,%esi
f01015fe:	83 c4 10             	add    $0x10,%esp
f0101601:	85 c0                	test   %eax,%eax
f0101603:	0f 84 46 02 00 00    	je     f010184f <mem_init+0x4bd>
	assert((pp1 = page_alloc(0)));
f0101609:	83 ec 0c             	sub    $0xc,%esp
f010160c:	6a 00                	push   $0x0
f010160e:	e8 22 fa ff ff       	call   f0101035 <page_alloc>
f0101613:	89 c7                	mov    %eax,%edi
f0101615:	83 c4 10             	add    $0x10,%esp
f0101618:	85 c0                	test   %eax,%eax
f010161a:	0f 84 4e 02 00 00    	je     f010186e <mem_init+0x4dc>
	assert((pp2 = page_alloc(0)));
f0101620:	83 ec 0c             	sub    $0xc,%esp
f0101623:	6a 00                	push   $0x0
f0101625:	e8 0b fa ff ff       	call   f0101035 <page_alloc>
f010162a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010162d:	83 c4 10             	add    $0x10,%esp
f0101630:	85 c0                	test   %eax,%eax
f0101632:	0f 84 55 02 00 00    	je     f010188d <mem_init+0x4fb>
	assert(pp1 && pp1 != pp0);
f0101638:	39 fe                	cmp    %edi,%esi
f010163a:	0f 84 6c 02 00 00    	je     f01018ac <mem_init+0x51a>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101640:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101643:	39 c7                	cmp    %eax,%edi
f0101645:	0f 84 80 02 00 00    	je     f01018cb <mem_init+0x539>
f010164b:	39 c6                	cmp    %eax,%esi
f010164d:	0f 84 78 02 00 00    	je     f01018cb <mem_init+0x539>
	assert(!page_alloc(0));
f0101653:	83 ec 0c             	sub    $0xc,%esp
f0101656:	6a 00                	push   $0x0
f0101658:	e8 d8 f9 ff ff       	call   f0101035 <page_alloc>
f010165d:	83 c4 10             	add    $0x10,%esp
f0101660:	85 c0                	test   %eax,%eax
f0101662:	0f 85 82 02 00 00    	jne    f01018ea <mem_init+0x558>
f0101668:	c7 c0 0c 00 19 f0    	mov    $0xf019000c,%eax
f010166e:	89 f1                	mov    %esi,%ecx
f0101670:	2b 08                	sub    (%eax),%ecx
f0101672:	89 c8                	mov    %ecx,%eax
f0101674:	c1 f8 03             	sar    $0x3,%eax
f0101677:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f010167a:	89 c1                	mov    %eax,%ecx
f010167c:	c1 e9 0c             	shr    $0xc,%ecx
f010167f:	c7 c2 04 00 19 f0    	mov    $0xf0190004,%edx
f0101685:	3b 0a                	cmp    (%edx),%ecx
f0101687:	0f 83 7c 02 00 00    	jae    f0101909 <mem_init+0x577>
	memset(page2kva(pp0), 1, PGSIZE);
f010168d:	83 ec 04             	sub    $0x4,%esp
f0101690:	68 00 10 00 00       	push   $0x1000
f0101695:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0101697:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010169c:	50                   	push   %eax
f010169d:	e8 51 36 00 00       	call   f0104cf3 <memset>
	page_free(pp0);
f01016a2:	89 34 24             	mov    %esi,(%esp)
f01016a5:	e8 13 fa ff ff       	call   f01010bd <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01016aa:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01016b1:	e8 7f f9 ff ff       	call   f0101035 <page_alloc>
f01016b6:	83 c4 10             	add    $0x10,%esp
f01016b9:	85 c0                	test   %eax,%eax
f01016bb:	0f 84 5e 02 00 00    	je     f010191f <mem_init+0x58d>
	assert(pp && pp0 == pp);
f01016c1:	39 c6                	cmp    %eax,%esi
f01016c3:	0f 85 75 02 00 00    	jne    f010193e <mem_init+0x5ac>
	return (pp - pages) << PGSHIFT;
f01016c9:	c7 c2 0c 00 19 f0    	mov    $0xf019000c,%edx
f01016cf:	2b 02                	sub    (%edx),%eax
f01016d1:	c1 f8 03             	sar    $0x3,%eax
f01016d4:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f01016d7:	89 c1                	mov    %eax,%ecx
f01016d9:	c1 e9 0c             	shr    $0xc,%ecx
f01016dc:	c7 c2 04 00 19 f0    	mov    $0xf0190004,%edx
f01016e2:	3b 0a                	cmp    (%edx),%ecx
f01016e4:	0f 83 73 02 00 00    	jae    f010195d <mem_init+0x5cb>
	return (void *)(pa + KERNBASE);
f01016ea:	8d 90 00 00 00 f0    	lea    -0x10000000(%eax),%edx
f01016f0:	2d 00 f0 ff 0f       	sub    $0xffff000,%eax
		assert(c[i] == 0);
f01016f5:	80 3a 00             	cmpb   $0x0,(%edx)
f01016f8:	0f 85 75 02 00 00    	jne    f0101973 <mem_init+0x5e1>
f01016fe:	83 c2 01             	add    $0x1,%edx
	for (i = 0; i < PGSIZE; i++)
f0101701:	39 c2                	cmp    %eax,%edx
f0101703:	75 f0                	jne    f01016f5 <mem_init+0x363>
	page_free_list = fl;
f0101705:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101708:	89 83 48 02 00 00    	mov    %eax,0x248(%ebx)
	page_free(pp0);
f010170e:	83 ec 0c             	sub    $0xc,%esp
f0101711:	56                   	push   %esi
f0101712:	e8 a6 f9 ff ff       	call   f01010bd <page_free>
	page_free(pp1);
f0101717:	89 3c 24             	mov    %edi,(%esp)
f010171a:	e8 9e f9 ff ff       	call   f01010bd <page_free>
	page_free(pp2);
f010171f:	83 c4 04             	add    $0x4,%esp
f0101722:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101725:	e8 93 f9 ff ff       	call   f01010bd <page_free>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010172a:	8b 83 48 02 00 00    	mov    0x248(%ebx),%eax
f0101730:	83 c4 10             	add    $0x10,%esp
f0101733:	e9 60 02 00 00       	jmp    f0101998 <mem_init+0x606>
	assert((pp0 = page_alloc(0)));
f0101738:	8d 83 16 6e f7 ff    	lea    -0x891ea(%ebx),%eax
f010173e:	50                   	push   %eax
f010173f:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f0101745:	50                   	push   %eax
f0101746:	68 b8 02 00 00       	push   $0x2b8
f010174b:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f0101751:	50                   	push   %eax
f0101752:	e8 cc e9 ff ff       	call   f0100123 <_panic>
	assert((pp1 = page_alloc(0)));
f0101757:	8d 83 2c 6e f7 ff    	lea    -0x891d4(%ebx),%eax
f010175d:	50                   	push   %eax
f010175e:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f0101764:	50                   	push   %eax
f0101765:	68 b9 02 00 00       	push   $0x2b9
f010176a:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f0101770:	50                   	push   %eax
f0101771:	e8 ad e9 ff ff       	call   f0100123 <_panic>
	assert((pp2 = page_alloc(0)));
f0101776:	8d 83 42 6e f7 ff    	lea    -0x891be(%ebx),%eax
f010177c:	50                   	push   %eax
f010177d:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f0101783:	50                   	push   %eax
f0101784:	68 ba 02 00 00       	push   $0x2ba
f0101789:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f010178f:	50                   	push   %eax
f0101790:	e8 8e e9 ff ff       	call   f0100123 <_panic>
	assert(pp1 && pp1 != pp0);
f0101795:	8d 83 58 6e f7 ff    	lea    -0x891a8(%ebx),%eax
f010179b:	50                   	push   %eax
f010179c:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f01017a2:	50                   	push   %eax
f01017a3:	68 bd 02 00 00       	push   $0x2bd
f01017a8:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f01017ae:	50                   	push   %eax
f01017af:	e8 6f e9 ff ff       	call   f0100123 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01017b4:	8d 83 28 67 f7 ff    	lea    -0x898d8(%ebx),%eax
f01017ba:	50                   	push   %eax
f01017bb:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f01017c1:	50                   	push   %eax
f01017c2:	68 be 02 00 00       	push   $0x2be
f01017c7:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f01017cd:	50                   	push   %eax
f01017ce:	e8 50 e9 ff ff       	call   f0100123 <_panic>
	assert(page2pa(pp0) < npages*PGSIZE);
f01017d3:	8d 83 6a 6e f7 ff    	lea    -0x89196(%ebx),%eax
f01017d9:	50                   	push   %eax
f01017da:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f01017e0:	50                   	push   %eax
f01017e1:	68 bf 02 00 00       	push   $0x2bf
f01017e6:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f01017ec:	50                   	push   %eax
f01017ed:	e8 31 e9 ff ff       	call   f0100123 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f01017f2:	8d 83 87 6e f7 ff    	lea    -0x89179(%ebx),%eax
f01017f8:	50                   	push   %eax
f01017f9:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f01017ff:	50                   	push   %eax
f0101800:	68 c0 02 00 00       	push   $0x2c0
f0101805:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f010180b:	50                   	push   %eax
f010180c:	e8 12 e9 ff ff       	call   f0100123 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f0101811:	8d 83 a4 6e f7 ff    	lea    -0x8915c(%ebx),%eax
f0101817:	50                   	push   %eax
f0101818:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f010181e:	50                   	push   %eax
f010181f:	68 c1 02 00 00       	push   $0x2c1
f0101824:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f010182a:	50                   	push   %eax
f010182b:	e8 f3 e8 ff ff       	call   f0100123 <_panic>
	assert(!page_alloc(0));
f0101830:	8d 83 c1 6e f7 ff    	lea    -0x8913f(%ebx),%eax
f0101836:	50                   	push   %eax
f0101837:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f010183d:	50                   	push   %eax
f010183e:	68 c8 02 00 00       	push   $0x2c8
f0101843:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f0101849:	50                   	push   %eax
f010184a:	e8 d4 e8 ff ff       	call   f0100123 <_panic>
	assert((pp0 = page_alloc(0)));
f010184f:	8d 83 16 6e f7 ff    	lea    -0x891ea(%ebx),%eax
f0101855:	50                   	push   %eax
f0101856:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f010185c:	50                   	push   %eax
f010185d:	68 cf 02 00 00       	push   $0x2cf
f0101862:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f0101868:	50                   	push   %eax
f0101869:	e8 b5 e8 ff ff       	call   f0100123 <_panic>
	assert((pp1 = page_alloc(0)));
f010186e:	8d 83 2c 6e f7 ff    	lea    -0x891d4(%ebx),%eax
f0101874:	50                   	push   %eax
f0101875:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f010187b:	50                   	push   %eax
f010187c:	68 d0 02 00 00       	push   $0x2d0
f0101881:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f0101887:	50                   	push   %eax
f0101888:	e8 96 e8 ff ff       	call   f0100123 <_panic>
	assert((pp2 = page_alloc(0)));
f010188d:	8d 83 42 6e f7 ff    	lea    -0x891be(%ebx),%eax
f0101893:	50                   	push   %eax
f0101894:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f010189a:	50                   	push   %eax
f010189b:	68 d1 02 00 00       	push   $0x2d1
f01018a0:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f01018a6:	50                   	push   %eax
f01018a7:	e8 77 e8 ff ff       	call   f0100123 <_panic>
	assert(pp1 && pp1 != pp0);
f01018ac:	8d 83 58 6e f7 ff    	lea    -0x891a8(%ebx),%eax
f01018b2:	50                   	push   %eax
f01018b3:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f01018b9:	50                   	push   %eax
f01018ba:	68 d3 02 00 00       	push   $0x2d3
f01018bf:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f01018c5:	50                   	push   %eax
f01018c6:	e8 58 e8 ff ff       	call   f0100123 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01018cb:	8d 83 28 67 f7 ff    	lea    -0x898d8(%ebx),%eax
f01018d1:	50                   	push   %eax
f01018d2:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f01018d8:	50                   	push   %eax
f01018d9:	68 d4 02 00 00       	push   $0x2d4
f01018de:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f01018e4:	50                   	push   %eax
f01018e5:	e8 39 e8 ff ff       	call   f0100123 <_panic>
	assert(!page_alloc(0));
f01018ea:	8d 83 c1 6e f7 ff    	lea    -0x8913f(%ebx),%eax
f01018f0:	50                   	push   %eax
f01018f1:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f01018f7:	50                   	push   %eax
f01018f8:	68 d5 02 00 00       	push   $0x2d5
f01018fd:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f0101903:	50                   	push   %eax
f0101904:	e8 1a e8 ff ff       	call   f0100123 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101909:	50                   	push   %eax
f010190a:	8d 83 64 65 f7 ff    	lea    -0x89a9c(%ebx),%eax
f0101910:	50                   	push   %eax
f0101911:	6a 56                	push   $0x56
f0101913:	8d 83 51 6d f7 ff    	lea    -0x892af(%ebx),%eax
f0101919:	50                   	push   %eax
f010191a:	e8 04 e8 ff ff       	call   f0100123 <_panic>
	assert((pp = page_alloc(ALLOC_ZERO)));
f010191f:	8d 83 d0 6e f7 ff    	lea    -0x89130(%ebx),%eax
f0101925:	50                   	push   %eax
f0101926:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f010192c:	50                   	push   %eax
f010192d:	68 da 02 00 00       	push   $0x2da
f0101932:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f0101938:	50                   	push   %eax
f0101939:	e8 e5 e7 ff ff       	call   f0100123 <_panic>
	assert(pp && pp0 == pp);
f010193e:	8d 83 ee 6e f7 ff    	lea    -0x89112(%ebx),%eax
f0101944:	50                   	push   %eax
f0101945:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f010194b:	50                   	push   %eax
f010194c:	68 db 02 00 00       	push   $0x2db
f0101951:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f0101957:	50                   	push   %eax
f0101958:	e8 c6 e7 ff ff       	call   f0100123 <_panic>
f010195d:	50                   	push   %eax
f010195e:	8d 83 64 65 f7 ff    	lea    -0x89a9c(%ebx),%eax
f0101964:	50                   	push   %eax
f0101965:	6a 56                	push   $0x56
f0101967:	8d 83 51 6d f7 ff    	lea    -0x892af(%ebx),%eax
f010196d:	50                   	push   %eax
f010196e:	e8 b0 e7 ff ff       	call   f0100123 <_panic>
		assert(c[i] == 0);
f0101973:	8d 83 fe 6e f7 ff    	lea    -0x89102(%ebx),%eax
f0101979:	50                   	push   %eax
f010197a:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f0101980:	50                   	push   %eax
f0101981:	68 de 02 00 00       	push   $0x2de
f0101986:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f010198c:	50                   	push   %eax
f010198d:	e8 91 e7 ff ff       	call   f0100123 <_panic>
		--nfree;
f0101992:	83 6d d0 01          	subl   $0x1,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101996:	8b 00                	mov    (%eax),%eax
f0101998:	85 c0                	test   %eax,%eax
f010199a:	75 f6                	jne    f0101992 <mem_init+0x600>
	assert(nfree == 0);
f010199c:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f01019a0:	0f 85 53 08 00 00    	jne    f01021f9 <mem_init+0xe67>
	cprintf("check_page_alloc() succeeded!\n");
f01019a6:	83 ec 0c             	sub    $0xc,%esp
f01019a9:	8d 83 48 67 f7 ff    	lea    -0x898b8(%ebx),%eax
f01019af:	50                   	push   %eax
f01019b0:	e8 82 1e 00 00       	call   f0103837 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01019b5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01019bc:	e8 74 f6 ff ff       	call   f0101035 <page_alloc>
f01019c1:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01019c4:	83 c4 10             	add    $0x10,%esp
f01019c7:	85 c0                	test   %eax,%eax
f01019c9:	0f 84 49 08 00 00    	je     f0102218 <mem_init+0xe86>
	assert((pp1 = page_alloc(0)));
f01019cf:	83 ec 0c             	sub    $0xc,%esp
f01019d2:	6a 00                	push   $0x0
f01019d4:	e8 5c f6 ff ff       	call   f0101035 <page_alloc>
f01019d9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01019dc:	83 c4 10             	add    $0x10,%esp
f01019df:	85 c0                	test   %eax,%eax
f01019e1:	0f 84 50 08 00 00    	je     f0102237 <mem_init+0xea5>
	assert((pp2 = page_alloc(0)));
f01019e7:	83 ec 0c             	sub    $0xc,%esp
f01019ea:	6a 00                	push   $0x0
f01019ec:	e8 44 f6 ff ff       	call   f0101035 <page_alloc>
f01019f1:	89 c7                	mov    %eax,%edi
f01019f3:	83 c4 10             	add    $0x10,%esp
f01019f6:	85 c0                	test   %eax,%eax
f01019f8:	0f 84 58 08 00 00    	je     f0102256 <mem_init+0xec4>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01019fe:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101a01:	39 4d d0             	cmp    %ecx,-0x30(%ebp)
f0101a04:	0f 84 6b 08 00 00    	je     f0102275 <mem_init+0xee3>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101a0a:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101a0d:	0f 84 81 08 00 00    	je     f0102294 <mem_init+0xf02>
f0101a13:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0101a16:	0f 84 78 08 00 00    	je     f0102294 <mem_init+0xf02>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101a1c:	8b 83 48 02 00 00    	mov    0x248(%ebx),%eax
f0101a22:	89 45 c8             	mov    %eax,-0x38(%ebp)
	page_free_list = 0;
f0101a25:	c7 83 48 02 00 00 00 	movl   $0x0,0x248(%ebx)
f0101a2c:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101a2f:	83 ec 0c             	sub    $0xc,%esp
f0101a32:	6a 00                	push   $0x0
f0101a34:	e8 fc f5 ff ff       	call   f0101035 <page_alloc>
f0101a39:	83 c4 10             	add    $0x10,%esp
f0101a3c:	85 c0                	test   %eax,%eax
f0101a3e:	0f 85 6f 08 00 00    	jne    f01022b3 <mem_init+0xf21>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101a44:	83 ec 04             	sub    $0x4,%esp
f0101a47:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101a4a:	50                   	push   %eax
f0101a4b:	6a 00                	push   $0x0
f0101a4d:	c7 c0 08 00 19 f0    	mov    $0xf0190008,%eax
f0101a53:	ff 30                	pushl  (%eax)
f0101a55:	e8 13 f8 ff ff       	call   f010126d <page_lookup>
f0101a5a:	83 c4 10             	add    $0x10,%esp
f0101a5d:	85 c0                	test   %eax,%eax
f0101a5f:	0f 85 6d 08 00 00    	jne    f01022d2 <mem_init+0xf40>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101a65:	6a 02                	push   $0x2
f0101a67:	6a 00                	push   $0x0
f0101a69:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101a6c:	c7 c0 08 00 19 f0    	mov    $0xf0190008,%eax
f0101a72:	ff 30                	pushl  (%eax)
f0101a74:	e8 a3 f8 ff ff       	call   f010131c <page_insert>
f0101a79:	83 c4 10             	add    $0x10,%esp
f0101a7c:	85 c0                	test   %eax,%eax
f0101a7e:	0f 89 6d 08 00 00    	jns    f01022f1 <mem_init+0xf5f>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101a84:	83 ec 0c             	sub    $0xc,%esp
f0101a87:	ff 75 d0             	pushl  -0x30(%ebp)
f0101a8a:	e8 2e f6 ff ff       	call   f01010bd <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101a8f:	6a 02                	push   $0x2
f0101a91:	6a 00                	push   $0x0
f0101a93:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101a96:	c7 c0 08 00 19 f0    	mov    $0xf0190008,%eax
f0101a9c:	ff 30                	pushl  (%eax)
f0101a9e:	e8 79 f8 ff ff       	call   f010131c <page_insert>
f0101aa3:	83 c4 20             	add    $0x20,%esp
f0101aa6:	85 c0                	test   %eax,%eax
f0101aa8:	0f 85 62 08 00 00    	jne    f0102310 <mem_init+0xf7e>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101aae:	c7 c0 08 00 19 f0    	mov    $0xf0190008,%eax
f0101ab4:	8b 30                	mov    (%eax),%esi
	return (pp - pages) << PGSHIFT;
f0101ab6:	c7 c0 0c 00 19 f0    	mov    $0xf019000c,%eax
f0101abc:	8b 08                	mov    (%eax),%ecx
f0101abe:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0101ac1:	8b 16                	mov    (%esi),%edx
f0101ac3:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101ac9:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101acc:	29 c8                	sub    %ecx,%eax
f0101ace:	c1 f8 03             	sar    $0x3,%eax
f0101ad1:	c1 e0 0c             	shl    $0xc,%eax
f0101ad4:	39 c2                	cmp    %eax,%edx
f0101ad6:	0f 85 53 08 00 00    	jne    f010232f <mem_init+0xf9d>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101adc:	ba 00 00 00 00       	mov    $0x0,%edx
f0101ae1:	89 f0                	mov    %esi,%eax
f0101ae3:	e8 35 f0 ff ff       	call   f0100b1d <check_va2pa>
f0101ae8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101aeb:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0101aee:	c1 fa 03             	sar    $0x3,%edx
f0101af1:	c1 e2 0c             	shl    $0xc,%edx
f0101af4:	39 d0                	cmp    %edx,%eax
f0101af6:	0f 85 52 08 00 00    	jne    f010234e <mem_init+0xfbc>
	assert(pp1->pp_ref == 1);
f0101afc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101aff:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101b04:	0f 85 63 08 00 00    	jne    f010236d <mem_init+0xfdb>
	assert(pp0->pp_ref == 1);
f0101b0a:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101b0d:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101b12:	0f 85 74 08 00 00    	jne    f010238c <mem_init+0xffa>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101b18:	6a 02                	push   $0x2
f0101b1a:	68 00 10 00 00       	push   $0x1000
f0101b1f:	57                   	push   %edi
f0101b20:	56                   	push   %esi
f0101b21:	e8 f6 f7 ff ff       	call   f010131c <page_insert>
f0101b26:	83 c4 10             	add    $0x10,%esp
f0101b29:	85 c0                	test   %eax,%eax
f0101b2b:	0f 85 7a 08 00 00    	jne    f01023ab <mem_init+0x1019>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101b31:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101b36:	c7 c0 08 00 19 f0    	mov    $0xf0190008,%eax
f0101b3c:	8b 00                	mov    (%eax),%eax
f0101b3e:	e8 da ef ff ff       	call   f0100b1d <check_va2pa>
f0101b43:	c7 c2 0c 00 19 f0    	mov    $0xf019000c,%edx
f0101b49:	89 f9                	mov    %edi,%ecx
f0101b4b:	2b 0a                	sub    (%edx),%ecx
f0101b4d:	89 ca                	mov    %ecx,%edx
f0101b4f:	c1 fa 03             	sar    $0x3,%edx
f0101b52:	c1 e2 0c             	shl    $0xc,%edx
f0101b55:	39 d0                	cmp    %edx,%eax
f0101b57:	0f 85 6d 08 00 00    	jne    f01023ca <mem_init+0x1038>
	assert(pp2->pp_ref == 1);
f0101b5d:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101b62:	0f 85 81 08 00 00    	jne    f01023e9 <mem_init+0x1057>

	// should be no free memory
	assert(!page_alloc(0));
f0101b68:	83 ec 0c             	sub    $0xc,%esp
f0101b6b:	6a 00                	push   $0x0
f0101b6d:	e8 c3 f4 ff ff       	call   f0101035 <page_alloc>
f0101b72:	83 c4 10             	add    $0x10,%esp
f0101b75:	85 c0                	test   %eax,%eax
f0101b77:	0f 85 8b 08 00 00    	jne    f0102408 <mem_init+0x1076>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101b7d:	6a 02                	push   $0x2
f0101b7f:	68 00 10 00 00       	push   $0x1000
f0101b84:	57                   	push   %edi
f0101b85:	c7 c0 08 00 19 f0    	mov    $0xf0190008,%eax
f0101b8b:	ff 30                	pushl  (%eax)
f0101b8d:	e8 8a f7 ff ff       	call   f010131c <page_insert>
f0101b92:	83 c4 10             	add    $0x10,%esp
f0101b95:	85 c0                	test   %eax,%eax
f0101b97:	0f 85 8a 08 00 00    	jne    f0102427 <mem_init+0x1095>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101b9d:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ba2:	c7 c0 08 00 19 f0    	mov    $0xf0190008,%eax
f0101ba8:	8b 00                	mov    (%eax),%eax
f0101baa:	e8 6e ef ff ff       	call   f0100b1d <check_va2pa>
f0101baf:	c7 c2 0c 00 19 f0    	mov    $0xf019000c,%edx
f0101bb5:	89 f9                	mov    %edi,%ecx
f0101bb7:	2b 0a                	sub    (%edx),%ecx
f0101bb9:	89 ca                	mov    %ecx,%edx
f0101bbb:	c1 fa 03             	sar    $0x3,%edx
f0101bbe:	c1 e2 0c             	shl    $0xc,%edx
f0101bc1:	39 d0                	cmp    %edx,%eax
f0101bc3:	0f 85 7d 08 00 00    	jne    f0102446 <mem_init+0x10b4>
	assert(pp2->pp_ref == 1);
f0101bc9:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101bce:	0f 85 91 08 00 00    	jne    f0102465 <mem_init+0x10d3>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101bd4:	83 ec 0c             	sub    $0xc,%esp
f0101bd7:	6a 00                	push   $0x0
f0101bd9:	e8 57 f4 ff ff       	call   f0101035 <page_alloc>
f0101bde:	83 c4 10             	add    $0x10,%esp
f0101be1:	85 c0                	test   %eax,%eax
f0101be3:	0f 85 9b 08 00 00    	jne    f0102484 <mem_init+0x10f2>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101be9:	c7 c0 08 00 19 f0    	mov    $0xf0190008,%eax
f0101bef:	8b 10                	mov    (%eax),%edx
f0101bf1:	8b 02                	mov    (%edx),%eax
f0101bf3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0101bf8:	89 c6                	mov    %eax,%esi
f0101bfa:	c1 ee 0c             	shr    $0xc,%esi
f0101bfd:	c7 c1 04 00 19 f0    	mov    $0xf0190004,%ecx
f0101c03:	3b 31                	cmp    (%ecx),%esi
f0101c05:	0f 83 98 08 00 00    	jae    f01024a3 <mem_init+0x1111>
	return (void *)(pa + KERNBASE);
f0101c0b:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101c10:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101c13:	83 ec 04             	sub    $0x4,%esp
f0101c16:	6a 00                	push   $0x0
f0101c18:	68 00 10 00 00       	push   $0x1000
f0101c1d:	52                   	push   %edx
f0101c1e:	e8 12 f5 ff ff       	call   f0101135 <pgdir_walk>
f0101c23:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101c26:	8d 51 04             	lea    0x4(%ecx),%edx
f0101c29:	83 c4 10             	add    $0x10,%esp
f0101c2c:	39 d0                	cmp    %edx,%eax
f0101c2e:	0f 85 88 08 00 00    	jne    f01024bc <mem_init+0x112a>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101c34:	6a 06                	push   $0x6
f0101c36:	68 00 10 00 00       	push   $0x1000
f0101c3b:	57                   	push   %edi
f0101c3c:	c7 c0 08 00 19 f0    	mov    $0xf0190008,%eax
f0101c42:	ff 30                	pushl  (%eax)
f0101c44:	e8 d3 f6 ff ff       	call   f010131c <page_insert>
f0101c49:	83 c4 10             	add    $0x10,%esp
f0101c4c:	85 c0                	test   %eax,%eax
f0101c4e:	0f 85 87 08 00 00    	jne    f01024db <mem_init+0x1149>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101c54:	c7 c0 08 00 19 f0    	mov    $0xf0190008,%eax
f0101c5a:	8b 30                	mov    (%eax),%esi
f0101c5c:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c61:	89 f0                	mov    %esi,%eax
f0101c63:	e8 b5 ee ff ff       	call   f0100b1d <check_va2pa>
	return (pp - pages) << PGSHIFT;
f0101c68:	c7 c2 0c 00 19 f0    	mov    $0xf019000c,%edx
f0101c6e:	89 f9                	mov    %edi,%ecx
f0101c70:	2b 0a                	sub    (%edx),%ecx
f0101c72:	89 ca                	mov    %ecx,%edx
f0101c74:	c1 fa 03             	sar    $0x3,%edx
f0101c77:	c1 e2 0c             	shl    $0xc,%edx
f0101c7a:	39 d0                	cmp    %edx,%eax
f0101c7c:	0f 85 78 08 00 00    	jne    f01024fa <mem_init+0x1168>
	assert(pp2->pp_ref == 1);
f0101c82:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101c87:	0f 85 8c 08 00 00    	jne    f0102519 <mem_init+0x1187>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101c8d:	83 ec 04             	sub    $0x4,%esp
f0101c90:	6a 00                	push   $0x0
f0101c92:	68 00 10 00 00       	push   $0x1000
f0101c97:	56                   	push   %esi
f0101c98:	e8 98 f4 ff ff       	call   f0101135 <pgdir_walk>
f0101c9d:	83 c4 10             	add    $0x10,%esp
f0101ca0:	f6 00 04             	testb  $0x4,(%eax)
f0101ca3:	0f 84 8f 08 00 00    	je     f0102538 <mem_init+0x11a6>
	assert(kern_pgdir[0] & PTE_U);
f0101ca9:	c7 c0 08 00 19 f0    	mov    $0xf0190008,%eax
f0101caf:	8b 00                	mov    (%eax),%eax
f0101cb1:	f6 00 04             	testb  $0x4,(%eax)
f0101cb4:	0f 84 9d 08 00 00    	je     f0102557 <mem_init+0x11c5>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101cba:	6a 02                	push   $0x2
f0101cbc:	68 00 10 00 00       	push   $0x1000
f0101cc1:	57                   	push   %edi
f0101cc2:	50                   	push   %eax
f0101cc3:	e8 54 f6 ff ff       	call   f010131c <page_insert>
f0101cc8:	83 c4 10             	add    $0x10,%esp
f0101ccb:	85 c0                	test   %eax,%eax
f0101ccd:	0f 85 a3 08 00 00    	jne    f0102576 <mem_init+0x11e4>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101cd3:	83 ec 04             	sub    $0x4,%esp
f0101cd6:	6a 00                	push   $0x0
f0101cd8:	68 00 10 00 00       	push   $0x1000
f0101cdd:	c7 c0 08 00 19 f0    	mov    $0xf0190008,%eax
f0101ce3:	ff 30                	pushl  (%eax)
f0101ce5:	e8 4b f4 ff ff       	call   f0101135 <pgdir_walk>
f0101cea:	83 c4 10             	add    $0x10,%esp
f0101ced:	f6 00 02             	testb  $0x2,(%eax)
f0101cf0:	0f 84 9f 08 00 00    	je     f0102595 <mem_init+0x1203>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101cf6:	83 ec 04             	sub    $0x4,%esp
f0101cf9:	6a 00                	push   $0x0
f0101cfb:	68 00 10 00 00       	push   $0x1000
f0101d00:	c7 c0 08 00 19 f0    	mov    $0xf0190008,%eax
f0101d06:	ff 30                	pushl  (%eax)
f0101d08:	e8 28 f4 ff ff       	call   f0101135 <pgdir_walk>
f0101d0d:	83 c4 10             	add    $0x10,%esp
f0101d10:	f6 00 04             	testb  $0x4,(%eax)
f0101d13:	0f 85 9b 08 00 00    	jne    f01025b4 <mem_init+0x1222>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101d19:	6a 02                	push   $0x2
f0101d1b:	68 00 00 40 00       	push   $0x400000
f0101d20:	ff 75 d0             	pushl  -0x30(%ebp)
f0101d23:	c7 c0 08 00 19 f0    	mov    $0xf0190008,%eax
f0101d29:	ff 30                	pushl  (%eax)
f0101d2b:	e8 ec f5 ff ff       	call   f010131c <page_insert>
f0101d30:	83 c4 10             	add    $0x10,%esp
f0101d33:	85 c0                	test   %eax,%eax
f0101d35:	0f 89 98 08 00 00    	jns    f01025d3 <mem_init+0x1241>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101d3b:	6a 02                	push   $0x2
f0101d3d:	68 00 10 00 00       	push   $0x1000
f0101d42:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101d45:	c7 c0 08 00 19 f0    	mov    $0xf0190008,%eax
f0101d4b:	ff 30                	pushl  (%eax)
f0101d4d:	e8 ca f5 ff ff       	call   f010131c <page_insert>
f0101d52:	83 c4 10             	add    $0x10,%esp
f0101d55:	85 c0                	test   %eax,%eax
f0101d57:	0f 85 95 08 00 00    	jne    f01025f2 <mem_init+0x1260>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101d5d:	83 ec 04             	sub    $0x4,%esp
f0101d60:	6a 00                	push   $0x0
f0101d62:	68 00 10 00 00       	push   $0x1000
f0101d67:	c7 c0 08 00 19 f0    	mov    $0xf0190008,%eax
f0101d6d:	ff 30                	pushl  (%eax)
f0101d6f:	e8 c1 f3 ff ff       	call   f0101135 <pgdir_walk>
f0101d74:	83 c4 10             	add    $0x10,%esp
f0101d77:	f6 00 04             	testb  $0x4,(%eax)
f0101d7a:	0f 85 91 08 00 00    	jne    f0102611 <mem_init+0x127f>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101d80:	c7 c0 08 00 19 f0    	mov    $0xf0190008,%eax
f0101d86:	8b 00                	mov    (%eax),%eax
f0101d88:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101d8b:	ba 00 00 00 00       	mov    $0x0,%edx
f0101d90:	e8 88 ed ff ff       	call   f0100b1d <check_va2pa>
f0101d95:	c7 c2 0c 00 19 f0    	mov    $0xf019000c,%edx
f0101d9b:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0101d9e:	2b 32                	sub    (%edx),%esi
f0101da0:	c1 fe 03             	sar    $0x3,%esi
f0101da3:	c1 e6 0c             	shl    $0xc,%esi
f0101da6:	39 f0                	cmp    %esi,%eax
f0101da8:	0f 85 82 08 00 00    	jne    f0102630 <mem_init+0x129e>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101dae:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101db3:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101db6:	e8 62 ed ff ff       	call   f0100b1d <check_va2pa>
f0101dbb:	39 c6                	cmp    %eax,%esi
f0101dbd:	0f 85 8c 08 00 00    	jne    f010264f <mem_init+0x12bd>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101dc3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101dc6:	66 83 78 04 02       	cmpw   $0x2,0x4(%eax)
f0101dcb:	0f 85 9d 08 00 00    	jne    f010266e <mem_init+0x12dc>
	assert(pp2->pp_ref == 0);
f0101dd1:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101dd6:	0f 85 b1 08 00 00    	jne    f010268d <mem_init+0x12fb>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101ddc:	83 ec 0c             	sub    $0xc,%esp
f0101ddf:	6a 00                	push   $0x0
f0101de1:	e8 4f f2 ff ff       	call   f0101035 <page_alloc>
f0101de6:	83 c4 10             	add    $0x10,%esp
f0101de9:	39 c7                	cmp    %eax,%edi
f0101deb:	0f 85 bb 08 00 00    	jne    f01026ac <mem_init+0x131a>
f0101df1:	85 c0                	test   %eax,%eax
f0101df3:	0f 84 b3 08 00 00    	je     f01026ac <mem_init+0x131a>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101df9:	83 ec 08             	sub    $0x8,%esp
f0101dfc:	6a 00                	push   $0x0
f0101dfe:	c7 c6 08 00 19 f0    	mov    $0xf0190008,%esi
f0101e04:	ff 36                	pushl  (%esi)
f0101e06:	e8 d6 f4 ff ff       	call   f01012e1 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101e0b:	8b 36                	mov    (%esi),%esi
f0101e0d:	ba 00 00 00 00       	mov    $0x0,%edx
f0101e12:	89 f0                	mov    %esi,%eax
f0101e14:	e8 04 ed ff ff       	call   f0100b1d <check_va2pa>
f0101e19:	83 c4 10             	add    $0x10,%esp
f0101e1c:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101e1f:	0f 85 a6 08 00 00    	jne    f01026cb <mem_init+0x1339>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101e25:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e2a:	89 f0                	mov    %esi,%eax
f0101e2c:	e8 ec ec ff ff       	call   f0100b1d <check_va2pa>
f0101e31:	c7 c2 0c 00 19 f0    	mov    $0xf019000c,%edx
f0101e37:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101e3a:	2b 0a                	sub    (%edx),%ecx
f0101e3c:	89 ca                	mov    %ecx,%edx
f0101e3e:	c1 fa 03             	sar    $0x3,%edx
f0101e41:	c1 e2 0c             	shl    $0xc,%edx
f0101e44:	39 d0                	cmp    %edx,%eax
f0101e46:	0f 85 9e 08 00 00    	jne    f01026ea <mem_init+0x1358>
	assert(pp1->pp_ref == 1);
f0101e4c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e4f:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101e54:	0f 85 af 08 00 00    	jne    f0102709 <mem_init+0x1377>
	assert(pp2->pp_ref == 0);
f0101e5a:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101e5f:	0f 85 c3 08 00 00    	jne    f0102728 <mem_init+0x1396>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101e65:	6a 00                	push   $0x0
f0101e67:	68 00 10 00 00       	push   $0x1000
f0101e6c:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101e6f:	56                   	push   %esi
f0101e70:	e8 a7 f4 ff ff       	call   f010131c <page_insert>
f0101e75:	83 c4 10             	add    $0x10,%esp
f0101e78:	85 c0                	test   %eax,%eax
f0101e7a:	0f 85 c7 08 00 00    	jne    f0102747 <mem_init+0x13b5>
	assert(pp1->pp_ref);
f0101e80:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e83:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101e88:	0f 84 d8 08 00 00    	je     f0102766 <mem_init+0x13d4>
	assert(pp1->pp_link == NULL);
f0101e8e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e91:	83 38 00             	cmpl   $0x0,(%eax)
f0101e94:	0f 85 eb 08 00 00    	jne    f0102785 <mem_init+0x13f3>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101e9a:	83 ec 08             	sub    $0x8,%esp
f0101e9d:	68 00 10 00 00       	push   $0x1000
f0101ea2:	c7 c6 08 00 19 f0    	mov    $0xf0190008,%esi
f0101ea8:	ff 36                	pushl  (%esi)
f0101eaa:	e8 32 f4 ff ff       	call   f01012e1 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101eaf:	8b 36                	mov    (%esi),%esi
f0101eb1:	ba 00 00 00 00       	mov    $0x0,%edx
f0101eb6:	89 f0                	mov    %esi,%eax
f0101eb8:	e8 60 ec ff ff       	call   f0100b1d <check_va2pa>
f0101ebd:	83 c4 10             	add    $0x10,%esp
f0101ec0:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101ec3:	0f 85 db 08 00 00    	jne    f01027a4 <mem_init+0x1412>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101ec9:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ece:	89 f0                	mov    %esi,%eax
f0101ed0:	e8 48 ec ff ff       	call   f0100b1d <check_va2pa>
f0101ed5:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101ed8:	0f 85 e5 08 00 00    	jne    f01027c3 <mem_init+0x1431>
	assert(pp1->pp_ref == 0);
f0101ede:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ee1:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101ee6:	0f 85 f6 08 00 00    	jne    f01027e2 <mem_init+0x1450>
	assert(pp2->pp_ref == 0);
f0101eec:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101ef1:	0f 85 0a 09 00 00    	jne    f0102801 <mem_init+0x146f>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101ef7:	83 ec 0c             	sub    $0xc,%esp
f0101efa:	6a 00                	push   $0x0
f0101efc:	e8 34 f1 ff ff       	call   f0101035 <page_alloc>
f0101f01:	83 c4 10             	add    $0x10,%esp
f0101f04:	85 c0                	test   %eax,%eax
f0101f06:	0f 84 14 09 00 00    	je     f0102820 <mem_init+0x148e>
f0101f0c:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101f0f:	0f 85 0b 09 00 00    	jne    f0102820 <mem_init+0x148e>

	// should be no free memory
	assert(!page_alloc(0));
f0101f15:	83 ec 0c             	sub    $0xc,%esp
f0101f18:	6a 00                	push   $0x0
f0101f1a:	e8 16 f1 ff ff       	call   f0101035 <page_alloc>
f0101f1f:	83 c4 10             	add    $0x10,%esp
f0101f22:	85 c0                	test   %eax,%eax
f0101f24:	0f 85 15 09 00 00    	jne    f010283f <mem_init+0x14ad>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101f2a:	c7 c0 08 00 19 f0    	mov    $0xf0190008,%eax
f0101f30:	8b 08                	mov    (%eax),%ecx
f0101f32:	8b 11                	mov    (%ecx),%edx
f0101f34:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101f3a:	c7 c0 0c 00 19 f0    	mov    $0xf019000c,%eax
f0101f40:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0101f43:	2b 30                	sub    (%eax),%esi
f0101f45:	89 f0                	mov    %esi,%eax
f0101f47:	c1 f8 03             	sar    $0x3,%eax
f0101f4a:	c1 e0 0c             	shl    $0xc,%eax
f0101f4d:	39 c2                	cmp    %eax,%edx
f0101f4f:	0f 85 09 09 00 00    	jne    f010285e <mem_init+0x14cc>
	kern_pgdir[0] = 0;
f0101f55:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0101f5b:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101f5e:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101f63:	0f 85 14 09 00 00    	jne    f010287d <mem_init+0x14eb>
	pp0->pp_ref = 0;
f0101f69:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101f6c:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0101f72:	83 ec 0c             	sub    $0xc,%esp
f0101f75:	50                   	push   %eax
f0101f76:	e8 42 f1 ff ff       	call   f01010bd <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0101f7b:	83 c4 0c             	add    $0xc,%esp
f0101f7e:	6a 01                	push   $0x1
f0101f80:	68 00 10 40 00       	push   $0x401000
f0101f85:	c7 c6 08 00 19 f0    	mov    $0xf0190008,%esi
f0101f8b:	ff 36                	pushl  (%esi)
f0101f8d:	e8 a3 f1 ff ff       	call   f0101135 <pgdir_walk>
f0101f92:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101f95:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0101f98:	8b 36                	mov    (%esi),%esi
f0101f9a:	8b 56 04             	mov    0x4(%esi),%edx
f0101f9d:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f0101fa3:	c7 c1 04 00 19 f0    	mov    $0xf0190004,%ecx
f0101fa9:	8b 09                	mov    (%ecx),%ecx
f0101fab:	89 d0                	mov    %edx,%eax
f0101fad:	c1 e8 0c             	shr    $0xc,%eax
f0101fb0:	83 c4 10             	add    $0x10,%esp
f0101fb3:	39 c8                	cmp    %ecx,%eax
f0101fb5:	0f 83 e1 08 00 00    	jae    f010289c <mem_init+0x150a>
	assert(ptep == ptep1 + PTX(va));
f0101fbb:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f0101fc1:	39 55 cc             	cmp    %edx,-0x34(%ebp)
f0101fc4:	0f 85 eb 08 00 00    	jne    f01028b5 <mem_init+0x1523>
	kern_pgdir[PDX(va)] = 0;
f0101fca:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	pp0->pp_ref = 0;
f0101fd1:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0101fd4:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)
	return (pp - pages) << PGSHIFT;
f0101fda:	c7 c0 0c 00 19 f0    	mov    $0xf019000c,%eax
f0101fe0:	2b 30                	sub    (%eax),%esi
f0101fe2:	89 f0                	mov    %esi,%eax
f0101fe4:	c1 f8 03             	sar    $0x3,%eax
f0101fe7:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0101fea:	89 c2                	mov    %eax,%edx
f0101fec:	c1 ea 0c             	shr    $0xc,%edx
f0101fef:	39 d1                	cmp    %edx,%ecx
f0101ff1:	0f 86 dd 08 00 00    	jbe    f01028d4 <mem_init+0x1542>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0101ff7:	83 ec 04             	sub    $0x4,%esp
f0101ffa:	68 00 10 00 00       	push   $0x1000
f0101fff:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f0102004:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102009:	50                   	push   %eax
f010200a:	e8 e4 2c 00 00       	call   f0104cf3 <memset>
	page_free(pp0);
f010200f:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0102012:	89 34 24             	mov    %esi,(%esp)
f0102015:	e8 a3 f0 ff ff       	call   f01010bd <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f010201a:	83 c4 0c             	add    $0xc,%esp
f010201d:	6a 01                	push   $0x1
f010201f:	6a 00                	push   $0x0
f0102021:	c7 c0 08 00 19 f0    	mov    $0xf0190008,%eax
f0102027:	ff 30                	pushl  (%eax)
f0102029:	e8 07 f1 ff ff       	call   f0101135 <pgdir_walk>
	return (pp - pages) << PGSHIFT;
f010202e:	c7 c0 0c 00 19 f0    	mov    $0xf019000c,%eax
f0102034:	2b 30                	sub    (%eax),%esi
f0102036:	89 f0                	mov    %esi,%eax
f0102038:	c1 f8 03             	sar    $0x3,%eax
f010203b:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f010203e:	89 c1                	mov    %eax,%ecx
f0102040:	c1 e9 0c             	shr    $0xc,%ecx
f0102043:	83 c4 10             	add    $0x10,%esp
f0102046:	c7 c2 04 00 19 f0    	mov    $0xf0190004,%edx
f010204c:	3b 0a                	cmp    (%edx),%ecx
f010204e:	0f 83 96 08 00 00    	jae    f01028ea <mem_init+0x1558>
	return (void *)(pa + KERNBASE);
f0102054:	8d 90 00 00 00 f0    	lea    -0x10000000(%eax),%edx
	ptep = (pte_t *) page2kva(pp0);
f010205a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f010205d:	2d 00 f0 ff 0f       	sub    $0xffff000,%eax
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102062:	f6 02 01             	testb  $0x1,(%edx)
f0102065:	0f 85 95 08 00 00    	jne    f0102900 <mem_init+0x156e>
f010206b:	83 c2 04             	add    $0x4,%edx
	for(i=0; i<NPTENTRIES; i++)
f010206e:	39 c2                	cmp    %eax,%edx
f0102070:	75 f0                	jne    f0102062 <mem_init+0xcd0>
	kern_pgdir[0] = 0;
f0102072:	c7 c0 08 00 19 f0    	mov    $0xf0190008,%eax
f0102078:	8b 00                	mov    (%eax),%eax
f010207a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102080:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102083:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0102089:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f010208c:	89 8b 48 02 00 00    	mov    %ecx,0x248(%ebx)

	// free the pages we took
	page_free(pp0);
f0102092:	83 ec 0c             	sub    $0xc,%esp
f0102095:	50                   	push   %eax
f0102096:	e8 22 f0 ff ff       	call   f01010bd <page_free>
	page_free(pp1);
f010209b:	83 c4 04             	add    $0x4,%esp
f010209e:	ff 75 d4             	pushl  -0x2c(%ebp)
f01020a1:	e8 17 f0 ff ff       	call   f01010bd <page_free>
	page_free(pp2);
f01020a6:	89 3c 24             	mov    %edi,(%esp)
f01020a9:	e8 0f f0 ff ff       	call   f01010bd <page_free>

	cprintf("check_page() succeeded!\n");
f01020ae:	8d 83 df 6f f7 ff    	lea    -0x89021(%ebx),%eax
f01020b4:	89 04 24             	mov    %eax,(%esp)
f01020b7:	e8 7b 17 00 00       	call   f0103837 <cprintf>
	boot_map_region(kern_pgdir, (uintptr_t) UPAGES, npages*sizeof(struct PageInfo), PADDR(pages), PTE_U | PTE_P);
f01020bc:	c7 c0 0c 00 19 f0    	mov    $0xf019000c,%eax
f01020c2:	8b 00                	mov    (%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f01020c4:	83 c4 10             	add    $0x10,%esp
f01020c7:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01020cc:	0f 86 4d 08 00 00    	jbe    f010291f <mem_init+0x158d>
f01020d2:	c7 c2 04 00 19 f0    	mov    $0xf0190004,%edx
f01020d8:	8b 0a                	mov    (%edx),%ecx
f01020da:	c1 e1 03             	shl    $0x3,%ecx
f01020dd:	83 ec 08             	sub    $0x8,%esp
f01020e0:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f01020e2:	05 00 00 00 10       	add    $0x10000000,%eax
f01020e7:	50                   	push   %eax
f01020e8:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f01020ed:	c7 c0 08 00 19 f0    	mov    $0xf0190008,%eax
f01020f3:	8b 00                	mov    (%eax),%eax
f01020f5:	e8 1f f1 ff ff       	call   f0101219 <boot_map_region>
	boot_map_region(kern_pgdir, (uintptr_t) UENVS, ROUNDUP(NENV * sizeof(struct Env), PGSIZE), PADDR(envs), PTE_U | PTE_P);
f01020fa:	c7 c0 48 f3 18 f0    	mov    $0xf018f348,%eax
f0102100:	8b 00                	mov    (%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0102102:	83 c4 10             	add    $0x10,%esp
f0102105:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010210a:	0f 86 28 08 00 00    	jbe    f0102938 <mem_init+0x15a6>
f0102110:	83 ec 08             	sub    $0x8,%esp
f0102113:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f0102115:	05 00 00 00 10       	add    $0x10000000,%eax
f010211a:	50                   	push   %eax
f010211b:	b9 00 80 01 00       	mov    $0x18000,%ecx
f0102120:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102125:	c7 c0 08 00 19 f0    	mov    $0xf0190008,%eax
f010212b:	8b 00                	mov    (%eax),%eax
f010212d:	e8 e7 f0 ff ff       	call   f0101219 <boot_map_region>
	if ((uint32_t)kva < KERNBASE)
f0102132:	c7 c0 00 30 11 f0    	mov    $0xf0113000,%eax
f0102138:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010213b:	83 c4 10             	add    $0x10,%esp
f010213e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102143:	0f 86 08 08 00 00    	jbe    f0102951 <mem_init+0x15bf>
	boot_map_region(kern_pgdir, (uintptr_t) (KSTACKTOP-KSTKSIZE), KSTKSIZE, PADDR(bootstack), PTE_W | PTE_P);
f0102149:	c7 c6 08 00 19 f0    	mov    $0xf0190008,%esi
f010214f:	83 ec 08             	sub    $0x8,%esp
f0102152:	6a 03                	push   $0x3
	return (physaddr_t)kva - KERNBASE;
f0102154:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102157:	05 00 00 00 10       	add    $0x10000000,%eax
f010215c:	50                   	push   %eax
f010215d:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102162:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102167:	8b 06                	mov    (%esi),%eax
f0102169:	e8 ab f0 ff ff       	call   f0101219 <boot_map_region>
	boot_map_region(kern_pgdir, (uintptr_t) KERNBASE, ROUNDUP(0xffffffff - KERNBASE, PGSIZE), 0, PTE_W | PTE_P);
f010216e:	83 c4 08             	add    $0x8,%esp
f0102171:	6a 03                	push   $0x3
f0102173:	6a 00                	push   $0x0
f0102175:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f010217a:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f010217f:	8b 06                	mov    (%esi),%eax
f0102181:	e8 93 f0 ff ff       	call   f0101219 <boot_map_region>
	pgdir = kern_pgdir;
f0102186:	8b 3e                	mov    (%esi),%edi
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102188:	c7 c0 04 00 19 f0    	mov    $0xf0190004,%eax
f010218e:	8b 00                	mov    (%eax),%eax
f0102190:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0102193:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f010219a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010219f:	89 45 d0             	mov    %eax,-0x30(%ebp)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01021a2:	c7 c0 0c 00 19 f0    	mov    $0xf019000c,%eax
f01021a8:	8b 00                	mov    (%eax),%eax
f01021aa:	89 45 c0             	mov    %eax,-0x40(%ebp)
	if ((uint32_t)kva < KERNBASE)
f01021ad:	89 45 cc             	mov    %eax,-0x34(%ebp)
	return (physaddr_t)kva - KERNBASE;
f01021b0:	05 00 00 00 10       	add    $0x10000000,%eax
f01021b5:	89 45 c8             	mov    %eax,-0x38(%ebp)
f01021b8:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < n; i += PGSIZE)
f01021bb:	be 00 00 00 00       	mov    $0x0,%esi
f01021c0:	39 75 d0             	cmp    %esi,-0x30(%ebp)
f01021c3:	0f 86 db 07 00 00    	jbe    f01029a4 <mem_init+0x1612>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01021c9:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
f01021cf:	89 f8                	mov    %edi,%eax
f01021d1:	e8 47 e9 ff ff       	call   f0100b1d <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f01021d6:	81 7d cc ff ff ff ef 	cmpl   $0xefffffff,-0x34(%ebp)
f01021dd:	0f 86 87 07 00 00    	jbe    f010296a <mem_init+0x15d8>
f01021e3:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f01021e6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01021e9:	39 d0                	cmp    %edx,%eax
f01021eb:	0f 85 94 07 00 00    	jne    f0102985 <mem_init+0x15f3>
	for (i = 0; i < n; i += PGSIZE)
f01021f1:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01021f7:	eb c7                	jmp    f01021c0 <mem_init+0xe2e>
	assert(nfree == 0);
f01021f9:	8d 83 08 6f f7 ff    	lea    -0x890f8(%ebx),%eax
f01021ff:	50                   	push   %eax
f0102200:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f0102206:	50                   	push   %eax
f0102207:	68 eb 02 00 00       	push   $0x2eb
f010220c:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f0102212:	50                   	push   %eax
f0102213:	e8 0b df ff ff       	call   f0100123 <_panic>
	assert((pp0 = page_alloc(0)));
f0102218:	8d 83 16 6e f7 ff    	lea    -0x891ea(%ebx),%eax
f010221e:	50                   	push   %eax
f010221f:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f0102225:	50                   	push   %eax
f0102226:	68 50 03 00 00       	push   $0x350
f010222b:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f0102231:	50                   	push   %eax
f0102232:	e8 ec de ff ff       	call   f0100123 <_panic>
	assert((pp1 = page_alloc(0)));
f0102237:	8d 83 2c 6e f7 ff    	lea    -0x891d4(%ebx),%eax
f010223d:	50                   	push   %eax
f010223e:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f0102244:	50                   	push   %eax
f0102245:	68 51 03 00 00       	push   $0x351
f010224a:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f0102250:	50                   	push   %eax
f0102251:	e8 cd de ff ff       	call   f0100123 <_panic>
	assert((pp2 = page_alloc(0)));
f0102256:	8d 83 42 6e f7 ff    	lea    -0x891be(%ebx),%eax
f010225c:	50                   	push   %eax
f010225d:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f0102263:	50                   	push   %eax
f0102264:	68 52 03 00 00       	push   $0x352
f0102269:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f010226f:	50                   	push   %eax
f0102270:	e8 ae de ff ff       	call   f0100123 <_panic>
	assert(pp1 && pp1 != pp0);
f0102275:	8d 83 58 6e f7 ff    	lea    -0x891a8(%ebx),%eax
f010227b:	50                   	push   %eax
f010227c:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f0102282:	50                   	push   %eax
f0102283:	68 55 03 00 00       	push   $0x355
f0102288:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f010228e:	50                   	push   %eax
f010228f:	e8 8f de ff ff       	call   f0100123 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0102294:	8d 83 28 67 f7 ff    	lea    -0x898d8(%ebx),%eax
f010229a:	50                   	push   %eax
f010229b:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f01022a1:	50                   	push   %eax
f01022a2:	68 56 03 00 00       	push   $0x356
f01022a7:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f01022ad:	50                   	push   %eax
f01022ae:	e8 70 de ff ff       	call   f0100123 <_panic>
	assert(!page_alloc(0));
f01022b3:	8d 83 c1 6e f7 ff    	lea    -0x8913f(%ebx),%eax
f01022b9:	50                   	push   %eax
f01022ba:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f01022c0:	50                   	push   %eax
f01022c1:	68 5d 03 00 00       	push   $0x35d
f01022c6:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f01022cc:	50                   	push   %eax
f01022cd:	e8 51 de ff ff       	call   f0100123 <_panic>
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f01022d2:	8d 83 68 67 f7 ff    	lea    -0x89898(%ebx),%eax
f01022d8:	50                   	push   %eax
f01022d9:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f01022df:	50                   	push   %eax
f01022e0:	68 60 03 00 00       	push   $0x360
f01022e5:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f01022eb:	50                   	push   %eax
f01022ec:	e8 32 de ff ff       	call   f0100123 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01022f1:	8d 83 a0 67 f7 ff    	lea    -0x89860(%ebx),%eax
f01022f7:	50                   	push   %eax
f01022f8:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f01022fe:	50                   	push   %eax
f01022ff:	68 63 03 00 00       	push   $0x363
f0102304:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f010230a:	50                   	push   %eax
f010230b:	e8 13 de ff ff       	call   f0100123 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0102310:	8d 83 d0 67 f7 ff    	lea    -0x89830(%ebx),%eax
f0102316:	50                   	push   %eax
f0102317:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f010231d:	50                   	push   %eax
f010231e:	68 67 03 00 00       	push   $0x367
f0102323:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f0102329:	50                   	push   %eax
f010232a:	e8 f4 dd ff ff       	call   f0100123 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010232f:	8d 83 00 68 f7 ff    	lea    -0x89800(%ebx),%eax
f0102335:	50                   	push   %eax
f0102336:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f010233c:	50                   	push   %eax
f010233d:	68 68 03 00 00       	push   $0x368
f0102342:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f0102348:	50                   	push   %eax
f0102349:	e8 d5 dd ff ff       	call   f0100123 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f010234e:	8d 83 28 68 f7 ff    	lea    -0x897d8(%ebx),%eax
f0102354:	50                   	push   %eax
f0102355:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f010235b:	50                   	push   %eax
f010235c:	68 69 03 00 00       	push   $0x369
f0102361:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f0102367:	50                   	push   %eax
f0102368:	e8 b6 dd ff ff       	call   f0100123 <_panic>
	assert(pp1->pp_ref == 1);
f010236d:	8d 83 13 6f f7 ff    	lea    -0x890ed(%ebx),%eax
f0102373:	50                   	push   %eax
f0102374:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f010237a:	50                   	push   %eax
f010237b:	68 6a 03 00 00       	push   $0x36a
f0102380:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f0102386:	50                   	push   %eax
f0102387:	e8 97 dd ff ff       	call   f0100123 <_panic>
	assert(pp0->pp_ref == 1);
f010238c:	8d 83 24 6f f7 ff    	lea    -0x890dc(%ebx),%eax
f0102392:	50                   	push   %eax
f0102393:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f0102399:	50                   	push   %eax
f010239a:	68 6b 03 00 00       	push   $0x36b
f010239f:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f01023a5:	50                   	push   %eax
f01023a6:	e8 78 dd ff ff       	call   f0100123 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01023ab:	8d 83 58 68 f7 ff    	lea    -0x897a8(%ebx),%eax
f01023b1:	50                   	push   %eax
f01023b2:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f01023b8:	50                   	push   %eax
f01023b9:	68 6e 03 00 00       	push   $0x36e
f01023be:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f01023c4:	50                   	push   %eax
f01023c5:	e8 59 dd ff ff       	call   f0100123 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01023ca:	8d 83 94 68 f7 ff    	lea    -0x8976c(%ebx),%eax
f01023d0:	50                   	push   %eax
f01023d1:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f01023d7:	50                   	push   %eax
f01023d8:	68 6f 03 00 00       	push   $0x36f
f01023dd:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f01023e3:	50                   	push   %eax
f01023e4:	e8 3a dd ff ff       	call   f0100123 <_panic>
	assert(pp2->pp_ref == 1);
f01023e9:	8d 83 35 6f f7 ff    	lea    -0x890cb(%ebx),%eax
f01023ef:	50                   	push   %eax
f01023f0:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f01023f6:	50                   	push   %eax
f01023f7:	68 70 03 00 00       	push   $0x370
f01023fc:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f0102402:	50                   	push   %eax
f0102403:	e8 1b dd ff ff       	call   f0100123 <_panic>
	assert(!page_alloc(0));
f0102408:	8d 83 c1 6e f7 ff    	lea    -0x8913f(%ebx),%eax
f010240e:	50                   	push   %eax
f010240f:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f0102415:	50                   	push   %eax
f0102416:	68 73 03 00 00       	push   $0x373
f010241b:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f0102421:	50                   	push   %eax
f0102422:	e8 fc dc ff ff       	call   f0100123 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102427:	8d 83 58 68 f7 ff    	lea    -0x897a8(%ebx),%eax
f010242d:	50                   	push   %eax
f010242e:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f0102434:	50                   	push   %eax
f0102435:	68 76 03 00 00       	push   $0x376
f010243a:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f0102440:	50                   	push   %eax
f0102441:	e8 dd dc ff ff       	call   f0100123 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102446:	8d 83 94 68 f7 ff    	lea    -0x8976c(%ebx),%eax
f010244c:	50                   	push   %eax
f010244d:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f0102453:	50                   	push   %eax
f0102454:	68 77 03 00 00       	push   $0x377
f0102459:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f010245f:	50                   	push   %eax
f0102460:	e8 be dc ff ff       	call   f0100123 <_panic>
	assert(pp2->pp_ref == 1);
f0102465:	8d 83 35 6f f7 ff    	lea    -0x890cb(%ebx),%eax
f010246b:	50                   	push   %eax
f010246c:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f0102472:	50                   	push   %eax
f0102473:	68 78 03 00 00       	push   $0x378
f0102478:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f010247e:	50                   	push   %eax
f010247f:	e8 9f dc ff ff       	call   f0100123 <_panic>
	assert(!page_alloc(0));
f0102484:	8d 83 c1 6e f7 ff    	lea    -0x8913f(%ebx),%eax
f010248a:	50                   	push   %eax
f010248b:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f0102491:	50                   	push   %eax
f0102492:	68 7c 03 00 00       	push   $0x37c
f0102497:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f010249d:	50                   	push   %eax
f010249e:	e8 80 dc ff ff       	call   f0100123 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01024a3:	50                   	push   %eax
f01024a4:	8d 83 64 65 f7 ff    	lea    -0x89a9c(%ebx),%eax
f01024aa:	50                   	push   %eax
f01024ab:	68 7f 03 00 00       	push   $0x37f
f01024b0:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f01024b6:	50                   	push   %eax
f01024b7:	e8 67 dc ff ff       	call   f0100123 <_panic>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f01024bc:	8d 83 c4 68 f7 ff    	lea    -0x8973c(%ebx),%eax
f01024c2:	50                   	push   %eax
f01024c3:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f01024c9:	50                   	push   %eax
f01024ca:	68 80 03 00 00       	push   $0x380
f01024cf:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f01024d5:	50                   	push   %eax
f01024d6:	e8 48 dc ff ff       	call   f0100123 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f01024db:	8d 83 04 69 f7 ff    	lea    -0x896fc(%ebx),%eax
f01024e1:	50                   	push   %eax
f01024e2:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f01024e8:	50                   	push   %eax
f01024e9:	68 83 03 00 00       	push   $0x383
f01024ee:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f01024f4:	50                   	push   %eax
f01024f5:	e8 29 dc ff ff       	call   f0100123 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01024fa:	8d 83 94 68 f7 ff    	lea    -0x8976c(%ebx),%eax
f0102500:	50                   	push   %eax
f0102501:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f0102507:	50                   	push   %eax
f0102508:	68 84 03 00 00       	push   $0x384
f010250d:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f0102513:	50                   	push   %eax
f0102514:	e8 0a dc ff ff       	call   f0100123 <_panic>
	assert(pp2->pp_ref == 1);
f0102519:	8d 83 35 6f f7 ff    	lea    -0x890cb(%ebx),%eax
f010251f:	50                   	push   %eax
f0102520:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f0102526:	50                   	push   %eax
f0102527:	68 85 03 00 00       	push   $0x385
f010252c:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f0102532:	50                   	push   %eax
f0102533:	e8 eb db ff ff       	call   f0100123 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0102538:	8d 83 44 69 f7 ff    	lea    -0x896bc(%ebx),%eax
f010253e:	50                   	push   %eax
f010253f:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f0102545:	50                   	push   %eax
f0102546:	68 86 03 00 00       	push   $0x386
f010254b:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f0102551:	50                   	push   %eax
f0102552:	e8 cc db ff ff       	call   f0100123 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0102557:	8d 83 46 6f f7 ff    	lea    -0x890ba(%ebx),%eax
f010255d:	50                   	push   %eax
f010255e:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f0102564:	50                   	push   %eax
f0102565:	68 87 03 00 00       	push   $0x387
f010256a:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f0102570:	50                   	push   %eax
f0102571:	e8 ad db ff ff       	call   f0100123 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102576:	8d 83 58 68 f7 ff    	lea    -0x897a8(%ebx),%eax
f010257c:	50                   	push   %eax
f010257d:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f0102583:	50                   	push   %eax
f0102584:	68 8a 03 00 00       	push   $0x38a
f0102589:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f010258f:	50                   	push   %eax
f0102590:	e8 8e db ff ff       	call   f0100123 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0102595:	8d 83 78 69 f7 ff    	lea    -0x89688(%ebx),%eax
f010259b:	50                   	push   %eax
f010259c:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f01025a2:	50                   	push   %eax
f01025a3:	68 8b 03 00 00       	push   $0x38b
f01025a8:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f01025ae:	50                   	push   %eax
f01025af:	e8 6f db ff ff       	call   f0100123 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01025b4:	8d 83 ac 69 f7 ff    	lea    -0x89654(%ebx),%eax
f01025ba:	50                   	push   %eax
f01025bb:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f01025c1:	50                   	push   %eax
f01025c2:	68 8c 03 00 00       	push   $0x38c
f01025c7:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f01025cd:	50                   	push   %eax
f01025ce:	e8 50 db ff ff       	call   f0100123 <_panic>
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f01025d3:	8d 83 e4 69 f7 ff    	lea    -0x8961c(%ebx),%eax
f01025d9:	50                   	push   %eax
f01025da:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f01025e0:	50                   	push   %eax
f01025e1:	68 8f 03 00 00       	push   $0x38f
f01025e6:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f01025ec:	50                   	push   %eax
f01025ed:	e8 31 db ff ff       	call   f0100123 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f01025f2:	8d 83 1c 6a f7 ff    	lea    -0x895e4(%ebx),%eax
f01025f8:	50                   	push   %eax
f01025f9:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f01025ff:	50                   	push   %eax
f0102600:	68 92 03 00 00       	push   $0x392
f0102605:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f010260b:	50                   	push   %eax
f010260c:	e8 12 db ff ff       	call   f0100123 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102611:	8d 83 ac 69 f7 ff    	lea    -0x89654(%ebx),%eax
f0102617:	50                   	push   %eax
f0102618:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f010261e:	50                   	push   %eax
f010261f:	68 93 03 00 00       	push   $0x393
f0102624:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f010262a:	50                   	push   %eax
f010262b:	e8 f3 da ff ff       	call   f0100123 <_panic>
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102630:	8d 83 58 6a f7 ff    	lea    -0x895a8(%ebx),%eax
f0102636:	50                   	push   %eax
f0102637:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f010263d:	50                   	push   %eax
f010263e:	68 96 03 00 00       	push   $0x396
f0102643:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f0102649:	50                   	push   %eax
f010264a:	e8 d4 da ff ff       	call   f0100123 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010264f:	8d 83 84 6a f7 ff    	lea    -0x8957c(%ebx),%eax
f0102655:	50                   	push   %eax
f0102656:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f010265c:	50                   	push   %eax
f010265d:	68 97 03 00 00       	push   $0x397
f0102662:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f0102668:	50                   	push   %eax
f0102669:	e8 b5 da ff ff       	call   f0100123 <_panic>
	assert(pp1->pp_ref == 2);
f010266e:	8d 83 5c 6f f7 ff    	lea    -0x890a4(%ebx),%eax
f0102674:	50                   	push   %eax
f0102675:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f010267b:	50                   	push   %eax
f010267c:	68 99 03 00 00       	push   $0x399
f0102681:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f0102687:	50                   	push   %eax
f0102688:	e8 96 da ff ff       	call   f0100123 <_panic>
	assert(pp2->pp_ref == 0);
f010268d:	8d 83 6d 6f f7 ff    	lea    -0x89093(%ebx),%eax
f0102693:	50                   	push   %eax
f0102694:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f010269a:	50                   	push   %eax
f010269b:	68 9a 03 00 00       	push   $0x39a
f01026a0:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f01026a6:	50                   	push   %eax
f01026a7:	e8 77 da ff ff       	call   f0100123 <_panic>
	assert((pp = page_alloc(0)) && pp == pp2);
f01026ac:	8d 83 b4 6a f7 ff    	lea    -0x8954c(%ebx),%eax
f01026b2:	50                   	push   %eax
f01026b3:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f01026b9:	50                   	push   %eax
f01026ba:	68 9d 03 00 00       	push   $0x39d
f01026bf:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f01026c5:	50                   	push   %eax
f01026c6:	e8 58 da ff ff       	call   f0100123 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01026cb:	8d 83 d8 6a f7 ff    	lea    -0x89528(%ebx),%eax
f01026d1:	50                   	push   %eax
f01026d2:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f01026d8:	50                   	push   %eax
f01026d9:	68 a1 03 00 00       	push   $0x3a1
f01026de:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f01026e4:	50                   	push   %eax
f01026e5:	e8 39 da ff ff       	call   f0100123 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01026ea:	8d 83 84 6a f7 ff    	lea    -0x8957c(%ebx),%eax
f01026f0:	50                   	push   %eax
f01026f1:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f01026f7:	50                   	push   %eax
f01026f8:	68 a2 03 00 00       	push   $0x3a2
f01026fd:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f0102703:	50                   	push   %eax
f0102704:	e8 1a da ff ff       	call   f0100123 <_panic>
	assert(pp1->pp_ref == 1);
f0102709:	8d 83 13 6f f7 ff    	lea    -0x890ed(%ebx),%eax
f010270f:	50                   	push   %eax
f0102710:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f0102716:	50                   	push   %eax
f0102717:	68 a3 03 00 00       	push   $0x3a3
f010271c:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f0102722:	50                   	push   %eax
f0102723:	e8 fb d9 ff ff       	call   f0100123 <_panic>
	assert(pp2->pp_ref == 0);
f0102728:	8d 83 6d 6f f7 ff    	lea    -0x89093(%ebx),%eax
f010272e:	50                   	push   %eax
f010272f:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f0102735:	50                   	push   %eax
f0102736:	68 a4 03 00 00       	push   $0x3a4
f010273b:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f0102741:	50                   	push   %eax
f0102742:	e8 dc d9 ff ff       	call   f0100123 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0102747:	8d 83 fc 6a f7 ff    	lea    -0x89504(%ebx),%eax
f010274d:	50                   	push   %eax
f010274e:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f0102754:	50                   	push   %eax
f0102755:	68 a7 03 00 00       	push   $0x3a7
f010275a:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f0102760:	50                   	push   %eax
f0102761:	e8 bd d9 ff ff       	call   f0100123 <_panic>
	assert(pp1->pp_ref);
f0102766:	8d 83 7e 6f f7 ff    	lea    -0x89082(%ebx),%eax
f010276c:	50                   	push   %eax
f010276d:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f0102773:	50                   	push   %eax
f0102774:	68 a8 03 00 00       	push   $0x3a8
f0102779:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f010277f:	50                   	push   %eax
f0102780:	e8 9e d9 ff ff       	call   f0100123 <_panic>
	assert(pp1->pp_link == NULL);
f0102785:	8d 83 8a 6f f7 ff    	lea    -0x89076(%ebx),%eax
f010278b:	50                   	push   %eax
f010278c:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f0102792:	50                   	push   %eax
f0102793:	68 a9 03 00 00       	push   $0x3a9
f0102798:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f010279e:	50                   	push   %eax
f010279f:	e8 7f d9 ff ff       	call   f0100123 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01027a4:	8d 83 d8 6a f7 ff    	lea    -0x89528(%ebx),%eax
f01027aa:	50                   	push   %eax
f01027ab:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f01027b1:	50                   	push   %eax
f01027b2:	68 ad 03 00 00       	push   $0x3ad
f01027b7:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f01027bd:	50                   	push   %eax
f01027be:	e8 60 d9 ff ff       	call   f0100123 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f01027c3:	8d 83 34 6b f7 ff    	lea    -0x894cc(%ebx),%eax
f01027c9:	50                   	push   %eax
f01027ca:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f01027d0:	50                   	push   %eax
f01027d1:	68 ae 03 00 00       	push   $0x3ae
f01027d6:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f01027dc:	50                   	push   %eax
f01027dd:	e8 41 d9 ff ff       	call   f0100123 <_panic>
	assert(pp1->pp_ref == 0);
f01027e2:	8d 83 9f 6f f7 ff    	lea    -0x89061(%ebx),%eax
f01027e8:	50                   	push   %eax
f01027e9:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f01027ef:	50                   	push   %eax
f01027f0:	68 af 03 00 00       	push   $0x3af
f01027f5:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f01027fb:	50                   	push   %eax
f01027fc:	e8 22 d9 ff ff       	call   f0100123 <_panic>
	assert(pp2->pp_ref == 0);
f0102801:	8d 83 6d 6f f7 ff    	lea    -0x89093(%ebx),%eax
f0102807:	50                   	push   %eax
f0102808:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f010280e:	50                   	push   %eax
f010280f:	68 b0 03 00 00       	push   $0x3b0
f0102814:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f010281a:	50                   	push   %eax
f010281b:	e8 03 d9 ff ff       	call   f0100123 <_panic>
	assert((pp = page_alloc(0)) && pp == pp1);
f0102820:	8d 83 5c 6b f7 ff    	lea    -0x894a4(%ebx),%eax
f0102826:	50                   	push   %eax
f0102827:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f010282d:	50                   	push   %eax
f010282e:	68 b3 03 00 00       	push   $0x3b3
f0102833:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f0102839:	50                   	push   %eax
f010283a:	e8 e4 d8 ff ff       	call   f0100123 <_panic>
	assert(!page_alloc(0));
f010283f:	8d 83 c1 6e f7 ff    	lea    -0x8913f(%ebx),%eax
f0102845:	50                   	push   %eax
f0102846:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f010284c:	50                   	push   %eax
f010284d:	68 b6 03 00 00       	push   $0x3b6
f0102852:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f0102858:	50                   	push   %eax
f0102859:	e8 c5 d8 ff ff       	call   f0100123 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010285e:	8d 83 00 68 f7 ff    	lea    -0x89800(%ebx),%eax
f0102864:	50                   	push   %eax
f0102865:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f010286b:	50                   	push   %eax
f010286c:	68 b9 03 00 00       	push   $0x3b9
f0102871:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f0102877:	50                   	push   %eax
f0102878:	e8 a6 d8 ff ff       	call   f0100123 <_panic>
	assert(pp0->pp_ref == 1);
f010287d:	8d 83 24 6f f7 ff    	lea    -0x890dc(%ebx),%eax
f0102883:	50                   	push   %eax
f0102884:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f010288a:	50                   	push   %eax
f010288b:	68 bb 03 00 00       	push   $0x3bb
f0102890:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f0102896:	50                   	push   %eax
f0102897:	e8 87 d8 ff ff       	call   f0100123 <_panic>
f010289c:	52                   	push   %edx
f010289d:	8d 83 64 65 f7 ff    	lea    -0x89a9c(%ebx),%eax
f01028a3:	50                   	push   %eax
f01028a4:	68 c2 03 00 00       	push   $0x3c2
f01028a9:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f01028af:	50                   	push   %eax
f01028b0:	e8 6e d8 ff ff       	call   f0100123 <_panic>
	assert(ptep == ptep1 + PTX(va));
f01028b5:	8d 83 b0 6f f7 ff    	lea    -0x89050(%ebx),%eax
f01028bb:	50                   	push   %eax
f01028bc:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f01028c2:	50                   	push   %eax
f01028c3:	68 c3 03 00 00       	push   $0x3c3
f01028c8:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f01028ce:	50                   	push   %eax
f01028cf:	e8 4f d8 ff ff       	call   f0100123 <_panic>
f01028d4:	50                   	push   %eax
f01028d5:	8d 83 64 65 f7 ff    	lea    -0x89a9c(%ebx),%eax
f01028db:	50                   	push   %eax
f01028dc:	6a 56                	push   $0x56
f01028de:	8d 83 51 6d f7 ff    	lea    -0x892af(%ebx),%eax
f01028e4:	50                   	push   %eax
f01028e5:	e8 39 d8 ff ff       	call   f0100123 <_panic>
f01028ea:	50                   	push   %eax
f01028eb:	8d 83 64 65 f7 ff    	lea    -0x89a9c(%ebx),%eax
f01028f1:	50                   	push   %eax
f01028f2:	6a 56                	push   $0x56
f01028f4:	8d 83 51 6d f7 ff    	lea    -0x892af(%ebx),%eax
f01028fa:	50                   	push   %eax
f01028fb:	e8 23 d8 ff ff       	call   f0100123 <_panic>
		assert((ptep[i] & PTE_P) == 0);
f0102900:	8d 83 c8 6f f7 ff    	lea    -0x89038(%ebx),%eax
f0102906:	50                   	push   %eax
f0102907:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f010290d:	50                   	push   %eax
f010290e:	68 cd 03 00 00       	push   $0x3cd
f0102913:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f0102919:	50                   	push   %eax
f010291a:	e8 04 d8 ff ff       	call   f0100123 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010291f:	50                   	push   %eax
f0102920:	8d 83 70 66 f7 ff    	lea    -0x89990(%ebx),%eax
f0102926:	50                   	push   %eax
f0102927:	68 cf 00 00 00       	push   $0xcf
f010292c:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f0102932:	50                   	push   %eax
f0102933:	e8 eb d7 ff ff       	call   f0100123 <_panic>
f0102938:	50                   	push   %eax
f0102939:	8d 83 70 66 f7 ff    	lea    -0x89990(%ebx),%eax
f010293f:	50                   	push   %eax
f0102940:	68 d8 00 00 00       	push   $0xd8
f0102945:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f010294b:	50                   	push   %eax
f010294c:	e8 d2 d7 ff ff       	call   f0100123 <_panic>
f0102951:	50                   	push   %eax
f0102952:	8d 83 70 66 f7 ff    	lea    -0x89990(%ebx),%eax
f0102958:	50                   	push   %eax
f0102959:	68 e5 00 00 00       	push   $0xe5
f010295e:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f0102964:	50                   	push   %eax
f0102965:	e8 b9 d7 ff ff       	call   f0100123 <_panic>
f010296a:	ff 75 c0             	pushl  -0x40(%ebp)
f010296d:	8d 83 70 66 f7 ff    	lea    -0x89990(%ebx),%eax
f0102973:	50                   	push   %eax
f0102974:	68 04 03 00 00       	push   $0x304
f0102979:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f010297f:	50                   	push   %eax
f0102980:	e8 9e d7 ff ff       	call   f0100123 <_panic>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102985:	8d 83 80 6b f7 ff    	lea    -0x89480(%ebx),%eax
f010298b:	50                   	push   %eax
f010298c:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f0102992:	50                   	push   %eax
f0102993:	68 04 03 00 00       	push   $0x304
f0102998:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f010299e:	50                   	push   %eax
f010299f:	e8 7f d7 ff ff       	call   f0100123 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f01029a4:	c7 c0 48 f3 18 f0    	mov    $0xf018f348,%eax
f01029aa:	8b 00                	mov    (%eax),%eax
f01029ac:	89 45 c8             	mov    %eax,-0x38(%ebp)
	if ((uint32_t)kva < KERNBASE)
f01029af:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01029b2:	be 00 00 c0 ee       	mov    $0xeec00000,%esi
f01029b7:	05 00 00 40 21       	add    $0x21400000,%eax
f01029bc:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01029bf:	89 f2                	mov    %esi,%edx
f01029c1:	89 f8                	mov    %edi,%eax
f01029c3:	e8 55 e1 ff ff       	call   f0100b1d <check_va2pa>
f01029c8:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f01029cf:	76 28                	jbe    f01029f9 <mem_init+0x1667>
f01029d1:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f01029d4:	8d 14 31             	lea    (%ecx,%esi,1),%edx
f01029d7:	39 d0                	cmp    %edx,%eax
f01029d9:	75 39                	jne    f0102a14 <mem_init+0x1682>
f01029db:	81 c6 00 10 00 00    	add    $0x1000,%esi
	for (i = 0; i < n; i += PGSIZE) {
f01029e1:	81 fe 00 80 c1 ee    	cmp    $0xeec18000,%esi
f01029e7:	75 d6                	jne    f01029bf <mem_init+0x162d>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01029e9:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f01029ec:	c1 e0 0c             	shl    $0xc,%eax
f01029ef:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01029f2:	be 00 00 00 00       	mov    $0x0,%esi
f01029f7:	eb 40                	jmp    f0102a39 <mem_init+0x16a7>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01029f9:	ff 75 c8             	pushl  -0x38(%ebp)
f01029fc:	8d 83 70 66 f7 ff    	lea    -0x89990(%ebx),%eax
f0102a02:	50                   	push   %eax
f0102a03:	68 0b 03 00 00       	push   $0x30b
f0102a08:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f0102a0e:	50                   	push   %eax
f0102a0f:	e8 0f d7 ff ff       	call   f0100123 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102a14:	8d 83 b4 6b f7 ff    	lea    -0x8944c(%ebx),%eax
f0102a1a:	50                   	push   %eax
f0102a1b:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f0102a21:	50                   	push   %eax
f0102a22:	68 0b 03 00 00       	push   $0x30b
f0102a27:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f0102a2d:	50                   	push   %eax
f0102a2e:	e8 f0 d6 ff ff       	call   f0100123 <_panic>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102a33:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102a39:	3b 75 d0             	cmp    -0x30(%ebp),%esi
f0102a3c:	73 30                	jae    f0102a6e <mem_init+0x16dc>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102a3e:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
f0102a44:	89 f8                	mov    %edi,%eax
f0102a46:	e8 d2 e0 ff ff       	call   f0100b1d <check_va2pa>
f0102a4b:	39 c6                	cmp    %eax,%esi
f0102a4d:	74 e4                	je     f0102a33 <mem_init+0x16a1>
f0102a4f:	8d 83 e8 6b f7 ff    	lea    -0x89418(%ebx),%eax
f0102a55:	50                   	push   %eax
f0102a56:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f0102a5c:	50                   	push   %eax
f0102a5d:	68 12 03 00 00       	push   $0x312
f0102a62:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f0102a68:	50                   	push   %eax
f0102a69:	e8 b5 d6 ff ff       	call   f0100123 <_panic>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102a6e:	be 00 80 ff ef       	mov    $0xefff8000,%esi
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102a73:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102a76:	05 00 80 00 20       	add    $0x20008000,%eax
f0102a7b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102a7e:	89 f2                	mov    %esi,%edx
f0102a80:	89 f8                	mov    %edi,%eax
f0102a82:	e8 96 e0 ff ff       	call   f0100b1d <check_va2pa>
f0102a87:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102a8a:	8d 14 31             	lea    (%ecx,%esi,1),%edx
f0102a8d:	39 d0                	cmp    %edx,%eax
f0102a8f:	0f 85 85 00 00 00    	jne    f0102b1a <mem_init+0x1788>
f0102a95:	81 c6 00 10 00 00    	add    $0x1000,%esi
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102a9b:	81 fe 00 00 00 f0    	cmp    $0xf0000000,%esi
f0102aa1:	75 db                	jne    f0102a7e <mem_init+0x16ec>
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102aa3:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f0102aa8:	89 f8                	mov    %edi,%eax
f0102aaa:	e8 6e e0 ff ff       	call   f0100b1d <check_va2pa>
f0102aaf:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102ab2:	0f 85 81 00 00 00    	jne    f0102b39 <mem_init+0x17a7>
	for (i = 0; i < NPDENTRIES; i++) {
f0102ab8:	b8 00 00 00 00       	mov    $0x0,%eax
			if (i >= PDX(KERNBASE)) {
f0102abd:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102ac2:	0f 87 90 00 00 00    	ja     f0102b58 <mem_init+0x17c6>
				assert(pgdir[i] == 0);
f0102ac8:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f0102acc:	0f 85 d5 00 00 00    	jne    f0102ba7 <mem_init+0x1815>
	for (i = 0; i < NPDENTRIES; i++) {
f0102ad2:	83 c0 01             	add    $0x1,%eax
f0102ad5:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f0102ada:	0f 87 e6 00 00 00    	ja     f0102bc6 <mem_init+0x1834>
		switch (i) {
f0102ae0:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f0102ae5:	72 d6                	jb     f0102abd <mem_init+0x172b>
f0102ae7:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f0102aec:	76 07                	jbe    f0102af5 <mem_init+0x1763>
f0102aee:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102af3:	75 c8                	jne    f0102abd <mem_init+0x172b>
			assert(pgdir[i] & PTE_P);
f0102af5:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f0102af9:	75 d7                	jne    f0102ad2 <mem_init+0x1740>
f0102afb:	8d 83 f8 6f f7 ff    	lea    -0x89008(%ebx),%eax
f0102b01:	50                   	push   %eax
f0102b02:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f0102b08:	50                   	push   %eax
f0102b09:	68 22 03 00 00       	push   $0x322
f0102b0e:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f0102b14:	50                   	push   %eax
f0102b15:	e8 09 d6 ff ff       	call   f0100123 <_panic>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102b1a:	8d 83 10 6c f7 ff    	lea    -0x893f0(%ebx),%eax
f0102b20:	50                   	push   %eax
f0102b21:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f0102b27:	50                   	push   %eax
f0102b28:	68 17 03 00 00       	push   $0x317
f0102b2d:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f0102b33:	50                   	push   %eax
f0102b34:	e8 ea d5 ff ff       	call   f0100123 <_panic>
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102b39:	8d 83 58 6c f7 ff    	lea    -0x893a8(%ebx),%eax
f0102b3f:	50                   	push   %eax
f0102b40:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f0102b46:	50                   	push   %eax
f0102b47:	68 18 03 00 00       	push   $0x318
f0102b4c:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f0102b52:	50                   	push   %eax
f0102b53:	e8 cb d5 ff ff       	call   f0100123 <_panic>
				assert(pgdir[i] & PTE_P);
f0102b58:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0102b5b:	f6 c2 01             	test   $0x1,%dl
f0102b5e:	74 28                	je     f0102b88 <mem_init+0x17f6>
				assert(pgdir[i] & PTE_W);
f0102b60:	f6 c2 02             	test   $0x2,%dl
f0102b63:	0f 85 69 ff ff ff    	jne    f0102ad2 <mem_init+0x1740>
f0102b69:	8d 83 09 70 f7 ff    	lea    -0x88ff7(%ebx),%eax
f0102b6f:	50                   	push   %eax
f0102b70:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f0102b76:	50                   	push   %eax
f0102b77:	68 27 03 00 00       	push   $0x327
f0102b7c:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f0102b82:	50                   	push   %eax
f0102b83:	e8 9b d5 ff ff       	call   f0100123 <_panic>
				assert(pgdir[i] & PTE_P);
f0102b88:	8d 83 f8 6f f7 ff    	lea    -0x89008(%ebx),%eax
f0102b8e:	50                   	push   %eax
f0102b8f:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f0102b95:	50                   	push   %eax
f0102b96:	68 26 03 00 00       	push   $0x326
f0102b9b:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f0102ba1:	50                   	push   %eax
f0102ba2:	e8 7c d5 ff ff       	call   f0100123 <_panic>
				assert(pgdir[i] == 0);
f0102ba7:	8d 83 1a 70 f7 ff    	lea    -0x88fe6(%ebx),%eax
f0102bad:	50                   	push   %eax
f0102bae:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f0102bb4:	50                   	push   %eax
f0102bb5:	68 29 03 00 00       	push   $0x329
f0102bba:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f0102bc0:	50                   	push   %eax
f0102bc1:	e8 5d d5 ff ff       	call   f0100123 <_panic>
	cprintf("check_kern_pgdir() succeeded!\n");
f0102bc6:	83 ec 0c             	sub    $0xc,%esp
f0102bc9:	8d 83 88 6c f7 ff    	lea    -0x89378(%ebx),%eax
f0102bcf:	50                   	push   %eax
f0102bd0:	e8 62 0c 00 00       	call   f0103837 <cprintf>
	lcr3(PADDR(kern_pgdir));
f0102bd5:	c7 c0 08 00 19 f0    	mov    $0xf0190008,%eax
f0102bdb:	8b 00                	mov    (%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0102bdd:	83 c4 10             	add    $0x10,%esp
f0102be0:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102be5:	0f 86 28 02 00 00    	jbe    f0102e13 <mem_init+0x1a81>
	return (physaddr_t)kva - KERNBASE;
f0102beb:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102bf0:	0f 22 d8             	mov    %eax,%cr3
	check_page_free_list(0);
f0102bf3:	b8 00 00 00 00       	mov    $0x0,%eax
f0102bf8:	e8 9d df ff ff       	call   f0100b9a <check_page_free_list>
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0102bfd:	0f 20 c0             	mov    %cr0,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f0102c00:	83 e0 f3             	and    $0xfffffff3,%eax
f0102c03:	0d 23 00 05 80       	or     $0x80050023,%eax
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0102c08:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102c0b:	83 ec 0c             	sub    $0xc,%esp
f0102c0e:	6a 00                	push   $0x0
f0102c10:	e8 20 e4 ff ff       	call   f0101035 <page_alloc>
f0102c15:	89 c7                	mov    %eax,%edi
f0102c17:	83 c4 10             	add    $0x10,%esp
f0102c1a:	85 c0                	test   %eax,%eax
f0102c1c:	0f 84 0a 02 00 00    	je     f0102e2c <mem_init+0x1a9a>
	assert((pp1 = page_alloc(0)));
f0102c22:	83 ec 0c             	sub    $0xc,%esp
f0102c25:	6a 00                	push   $0x0
f0102c27:	e8 09 e4 ff ff       	call   f0101035 <page_alloc>
f0102c2c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102c2f:	83 c4 10             	add    $0x10,%esp
f0102c32:	85 c0                	test   %eax,%eax
f0102c34:	0f 84 11 02 00 00    	je     f0102e4b <mem_init+0x1ab9>
	assert((pp2 = page_alloc(0)));
f0102c3a:	83 ec 0c             	sub    $0xc,%esp
f0102c3d:	6a 00                	push   $0x0
f0102c3f:	e8 f1 e3 ff ff       	call   f0101035 <page_alloc>
f0102c44:	89 c6                	mov    %eax,%esi
f0102c46:	83 c4 10             	add    $0x10,%esp
f0102c49:	85 c0                	test   %eax,%eax
f0102c4b:	0f 84 19 02 00 00    	je     f0102e6a <mem_init+0x1ad8>
	page_free(pp0);
f0102c51:	83 ec 0c             	sub    $0xc,%esp
f0102c54:	57                   	push   %edi
f0102c55:	e8 63 e4 ff ff       	call   f01010bd <page_free>
	return (pp - pages) << PGSHIFT;
f0102c5a:	c7 c0 0c 00 19 f0    	mov    $0xf019000c,%eax
f0102c60:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102c63:	2b 08                	sub    (%eax),%ecx
f0102c65:	89 c8                	mov    %ecx,%eax
f0102c67:	c1 f8 03             	sar    $0x3,%eax
f0102c6a:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102c6d:	89 c1                	mov    %eax,%ecx
f0102c6f:	c1 e9 0c             	shr    $0xc,%ecx
f0102c72:	83 c4 10             	add    $0x10,%esp
f0102c75:	c7 c2 04 00 19 f0    	mov    $0xf0190004,%edx
f0102c7b:	3b 0a                	cmp    (%edx),%ecx
f0102c7d:	0f 83 06 02 00 00    	jae    f0102e89 <mem_init+0x1af7>
	memset(page2kva(pp1), 1, PGSIZE);
f0102c83:	83 ec 04             	sub    $0x4,%esp
f0102c86:	68 00 10 00 00       	push   $0x1000
f0102c8b:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0102c8d:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102c92:	50                   	push   %eax
f0102c93:	e8 5b 20 00 00       	call   f0104cf3 <memset>
	return (pp - pages) << PGSHIFT;
f0102c98:	c7 c0 0c 00 19 f0    	mov    $0xf019000c,%eax
f0102c9e:	89 f1                	mov    %esi,%ecx
f0102ca0:	2b 08                	sub    (%eax),%ecx
f0102ca2:	89 c8                	mov    %ecx,%eax
f0102ca4:	c1 f8 03             	sar    $0x3,%eax
f0102ca7:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102caa:	89 c1                	mov    %eax,%ecx
f0102cac:	c1 e9 0c             	shr    $0xc,%ecx
f0102caf:	83 c4 10             	add    $0x10,%esp
f0102cb2:	c7 c2 04 00 19 f0    	mov    $0xf0190004,%edx
f0102cb8:	3b 0a                	cmp    (%edx),%ecx
f0102cba:	0f 83 df 01 00 00    	jae    f0102e9f <mem_init+0x1b0d>
	memset(page2kva(pp2), 2, PGSIZE);
f0102cc0:	83 ec 04             	sub    $0x4,%esp
f0102cc3:	68 00 10 00 00       	push   $0x1000
f0102cc8:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f0102cca:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102ccf:	50                   	push   %eax
f0102cd0:	e8 1e 20 00 00       	call   f0104cf3 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102cd5:	6a 02                	push   $0x2
f0102cd7:	68 00 10 00 00       	push   $0x1000
f0102cdc:	ff 75 d4             	pushl  -0x2c(%ebp)
f0102cdf:	c7 c0 08 00 19 f0    	mov    $0xf0190008,%eax
f0102ce5:	ff 30                	pushl  (%eax)
f0102ce7:	e8 30 e6 ff ff       	call   f010131c <page_insert>
	assert(pp1->pp_ref == 1);
f0102cec:	83 c4 20             	add    $0x20,%esp
f0102cef:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102cf2:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0102cf7:	0f 85 b8 01 00 00    	jne    f0102eb5 <mem_init+0x1b23>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102cfd:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102d04:	01 01 01 
f0102d07:	0f 85 c7 01 00 00    	jne    f0102ed4 <mem_init+0x1b42>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102d0d:	6a 02                	push   $0x2
f0102d0f:	68 00 10 00 00       	push   $0x1000
f0102d14:	56                   	push   %esi
f0102d15:	c7 c0 08 00 19 f0    	mov    $0xf0190008,%eax
f0102d1b:	ff 30                	pushl  (%eax)
f0102d1d:	e8 fa e5 ff ff       	call   f010131c <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102d22:	83 c4 10             	add    $0x10,%esp
f0102d25:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102d2c:	02 02 02 
f0102d2f:	0f 85 be 01 00 00    	jne    f0102ef3 <mem_init+0x1b61>
	assert(pp2->pp_ref == 1);
f0102d35:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102d3a:	0f 85 d2 01 00 00    	jne    f0102f12 <mem_init+0x1b80>
	assert(pp1->pp_ref == 0);
f0102d40:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102d43:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0102d48:	0f 85 e3 01 00 00    	jne    f0102f31 <mem_init+0x1b9f>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102d4e:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102d55:	03 03 03 
	return (pp - pages) << PGSHIFT;
f0102d58:	c7 c0 0c 00 19 f0    	mov    $0xf019000c,%eax
f0102d5e:	89 f1                	mov    %esi,%ecx
f0102d60:	2b 08                	sub    (%eax),%ecx
f0102d62:	89 c8                	mov    %ecx,%eax
f0102d64:	c1 f8 03             	sar    $0x3,%eax
f0102d67:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102d6a:	89 c1                	mov    %eax,%ecx
f0102d6c:	c1 e9 0c             	shr    $0xc,%ecx
f0102d6f:	c7 c2 04 00 19 f0    	mov    $0xf0190004,%edx
f0102d75:	3b 0a                	cmp    (%edx),%ecx
f0102d77:	0f 83 d3 01 00 00    	jae    f0102f50 <mem_init+0x1bbe>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102d7d:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102d84:	03 03 03 
f0102d87:	0f 85 d9 01 00 00    	jne    f0102f66 <mem_init+0x1bd4>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102d8d:	83 ec 08             	sub    $0x8,%esp
f0102d90:	68 00 10 00 00       	push   $0x1000
f0102d95:	c7 c0 08 00 19 f0    	mov    $0xf0190008,%eax
f0102d9b:	ff 30                	pushl  (%eax)
f0102d9d:	e8 3f e5 ff ff       	call   f01012e1 <page_remove>
	assert(pp2->pp_ref == 0);
f0102da2:	83 c4 10             	add    $0x10,%esp
f0102da5:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102daa:	0f 85 d5 01 00 00    	jne    f0102f85 <mem_init+0x1bf3>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102db0:	c7 c0 08 00 19 f0    	mov    $0xf0190008,%eax
f0102db6:	8b 08                	mov    (%eax),%ecx
f0102db8:	8b 11                	mov    (%ecx),%edx
f0102dba:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	return (pp - pages) << PGSHIFT;
f0102dc0:	c7 c0 0c 00 19 f0    	mov    $0xf019000c,%eax
f0102dc6:	89 fe                	mov    %edi,%esi
f0102dc8:	2b 30                	sub    (%eax),%esi
f0102dca:	89 f0                	mov    %esi,%eax
f0102dcc:	c1 f8 03             	sar    $0x3,%eax
f0102dcf:	c1 e0 0c             	shl    $0xc,%eax
f0102dd2:	39 c2                	cmp    %eax,%edx
f0102dd4:	0f 85 ca 01 00 00    	jne    f0102fa4 <mem_init+0x1c12>
	kern_pgdir[0] = 0;
f0102dda:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102de0:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102de5:	0f 85 d8 01 00 00    	jne    f0102fc3 <mem_init+0x1c31>
	pp0->pp_ref = 0;
f0102deb:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// free the pages we took
	page_free(pp0);
f0102df1:	83 ec 0c             	sub    $0xc,%esp
f0102df4:	57                   	push   %edi
f0102df5:	e8 c3 e2 ff ff       	call   f01010bd <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102dfa:	8d 83 1c 6d f7 ff    	lea    -0x892e4(%ebx),%eax
f0102e00:	89 04 24             	mov    %eax,(%esp)
f0102e03:	e8 2f 0a 00 00       	call   f0103837 <cprintf>
}
f0102e08:	83 c4 10             	add    $0x10,%esp
f0102e0b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102e0e:	5b                   	pop    %ebx
f0102e0f:	5e                   	pop    %esi
f0102e10:	5f                   	pop    %edi
f0102e11:	5d                   	pop    %ebp
f0102e12:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102e13:	50                   	push   %eax
f0102e14:	8d 83 70 66 f7 ff    	lea    -0x89990(%ebx),%eax
f0102e1a:	50                   	push   %eax
f0102e1b:	68 fe 00 00 00       	push   $0xfe
f0102e20:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f0102e26:	50                   	push   %eax
f0102e27:	e8 f7 d2 ff ff       	call   f0100123 <_panic>
	assert((pp0 = page_alloc(0)));
f0102e2c:	8d 83 16 6e f7 ff    	lea    -0x891ea(%ebx),%eax
f0102e32:	50                   	push   %eax
f0102e33:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f0102e39:	50                   	push   %eax
f0102e3a:	68 e8 03 00 00       	push   $0x3e8
f0102e3f:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f0102e45:	50                   	push   %eax
f0102e46:	e8 d8 d2 ff ff       	call   f0100123 <_panic>
	assert((pp1 = page_alloc(0)));
f0102e4b:	8d 83 2c 6e f7 ff    	lea    -0x891d4(%ebx),%eax
f0102e51:	50                   	push   %eax
f0102e52:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f0102e58:	50                   	push   %eax
f0102e59:	68 e9 03 00 00       	push   $0x3e9
f0102e5e:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f0102e64:	50                   	push   %eax
f0102e65:	e8 b9 d2 ff ff       	call   f0100123 <_panic>
	assert((pp2 = page_alloc(0)));
f0102e6a:	8d 83 42 6e f7 ff    	lea    -0x891be(%ebx),%eax
f0102e70:	50                   	push   %eax
f0102e71:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f0102e77:	50                   	push   %eax
f0102e78:	68 ea 03 00 00       	push   $0x3ea
f0102e7d:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f0102e83:	50                   	push   %eax
f0102e84:	e8 9a d2 ff ff       	call   f0100123 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102e89:	50                   	push   %eax
f0102e8a:	8d 83 64 65 f7 ff    	lea    -0x89a9c(%ebx),%eax
f0102e90:	50                   	push   %eax
f0102e91:	6a 56                	push   $0x56
f0102e93:	8d 83 51 6d f7 ff    	lea    -0x892af(%ebx),%eax
f0102e99:	50                   	push   %eax
f0102e9a:	e8 84 d2 ff ff       	call   f0100123 <_panic>
f0102e9f:	50                   	push   %eax
f0102ea0:	8d 83 64 65 f7 ff    	lea    -0x89a9c(%ebx),%eax
f0102ea6:	50                   	push   %eax
f0102ea7:	6a 56                	push   $0x56
f0102ea9:	8d 83 51 6d f7 ff    	lea    -0x892af(%ebx),%eax
f0102eaf:	50                   	push   %eax
f0102eb0:	e8 6e d2 ff ff       	call   f0100123 <_panic>
	assert(pp1->pp_ref == 1);
f0102eb5:	8d 83 13 6f f7 ff    	lea    -0x890ed(%ebx),%eax
f0102ebb:	50                   	push   %eax
f0102ebc:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f0102ec2:	50                   	push   %eax
f0102ec3:	68 ef 03 00 00       	push   $0x3ef
f0102ec8:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f0102ece:	50                   	push   %eax
f0102ecf:	e8 4f d2 ff ff       	call   f0100123 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102ed4:	8d 83 a8 6c f7 ff    	lea    -0x89358(%ebx),%eax
f0102eda:	50                   	push   %eax
f0102edb:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f0102ee1:	50                   	push   %eax
f0102ee2:	68 f0 03 00 00       	push   $0x3f0
f0102ee7:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f0102eed:	50                   	push   %eax
f0102eee:	e8 30 d2 ff ff       	call   f0100123 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102ef3:	8d 83 cc 6c f7 ff    	lea    -0x89334(%ebx),%eax
f0102ef9:	50                   	push   %eax
f0102efa:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f0102f00:	50                   	push   %eax
f0102f01:	68 f2 03 00 00       	push   $0x3f2
f0102f06:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f0102f0c:	50                   	push   %eax
f0102f0d:	e8 11 d2 ff ff       	call   f0100123 <_panic>
	assert(pp2->pp_ref == 1);
f0102f12:	8d 83 35 6f f7 ff    	lea    -0x890cb(%ebx),%eax
f0102f18:	50                   	push   %eax
f0102f19:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f0102f1f:	50                   	push   %eax
f0102f20:	68 f3 03 00 00       	push   $0x3f3
f0102f25:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f0102f2b:	50                   	push   %eax
f0102f2c:	e8 f2 d1 ff ff       	call   f0100123 <_panic>
	assert(pp1->pp_ref == 0);
f0102f31:	8d 83 9f 6f f7 ff    	lea    -0x89061(%ebx),%eax
f0102f37:	50                   	push   %eax
f0102f38:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f0102f3e:	50                   	push   %eax
f0102f3f:	68 f4 03 00 00       	push   $0x3f4
f0102f44:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f0102f4a:	50                   	push   %eax
f0102f4b:	e8 d3 d1 ff ff       	call   f0100123 <_panic>
f0102f50:	50                   	push   %eax
f0102f51:	8d 83 64 65 f7 ff    	lea    -0x89a9c(%ebx),%eax
f0102f57:	50                   	push   %eax
f0102f58:	6a 56                	push   $0x56
f0102f5a:	8d 83 51 6d f7 ff    	lea    -0x892af(%ebx),%eax
f0102f60:	50                   	push   %eax
f0102f61:	e8 bd d1 ff ff       	call   f0100123 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102f66:	8d 83 f0 6c f7 ff    	lea    -0x89310(%ebx),%eax
f0102f6c:	50                   	push   %eax
f0102f6d:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f0102f73:	50                   	push   %eax
f0102f74:	68 f6 03 00 00       	push   $0x3f6
f0102f79:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f0102f7f:	50                   	push   %eax
f0102f80:	e8 9e d1 ff ff       	call   f0100123 <_panic>
	assert(pp2->pp_ref == 0);
f0102f85:	8d 83 6d 6f f7 ff    	lea    -0x89093(%ebx),%eax
f0102f8b:	50                   	push   %eax
f0102f8c:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f0102f92:	50                   	push   %eax
f0102f93:	68 f8 03 00 00       	push   $0x3f8
f0102f98:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f0102f9e:	50                   	push   %eax
f0102f9f:	e8 7f d1 ff ff       	call   f0100123 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102fa4:	8d 83 00 68 f7 ff    	lea    -0x89800(%ebx),%eax
f0102faa:	50                   	push   %eax
f0102fab:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f0102fb1:	50                   	push   %eax
f0102fb2:	68 fb 03 00 00       	push   $0x3fb
f0102fb7:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f0102fbd:	50                   	push   %eax
f0102fbe:	e8 60 d1 ff ff       	call   f0100123 <_panic>
	assert(pp0->pp_ref == 1);
f0102fc3:	8d 83 24 6f f7 ff    	lea    -0x890dc(%ebx),%eax
f0102fc9:	50                   	push   %eax
f0102fca:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f0102fd0:	50                   	push   %eax
f0102fd1:	68 fd 03 00 00       	push   $0x3fd
f0102fd6:	8d 83 45 6d f7 ff    	lea    -0x892bb(%ebx),%eax
f0102fdc:	50                   	push   %eax
f0102fdd:	e8 41 d1 ff ff       	call   f0100123 <_panic>

f0102fe2 <tlb_invalidate>:
{
f0102fe2:	55                   	push   %ebp
f0102fe3:	89 e5                	mov    %esp,%ebp
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0102fe5:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102fe8:	0f 01 38             	invlpg (%eax)
}
f0102feb:	5d                   	pop    %ebp
f0102fec:	c3                   	ret    

f0102fed <user_mem_check>:
}
f0102fed:	b8 00 00 00 00       	mov    $0x0,%eax
f0102ff2:	c3                   	ret    

f0102ff3 <user_mem_assert>:
}
f0102ff3:	c3                   	ret    

f0102ff4 <__x86.get_pc_thunk.cx>:
f0102ff4:	8b 0c 24             	mov    (%esp),%ecx
f0102ff7:	c3                   	ret    

f0102ff8 <__x86.get_pc_thunk.si>:
f0102ff8:	8b 34 24             	mov    (%esp),%esi
f0102ffb:	c3                   	ret    

f0102ffc <__x86.get_pc_thunk.di>:
f0102ffc:	8b 3c 24             	mov    (%esp),%edi
f0102fff:	c3                   	ret    

f0103000 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0103000:	55                   	push   %ebp
f0103001:	89 e5                	mov    %esp,%ebp
f0103003:	57                   	push   %edi
f0103004:	56                   	push   %esi
f0103005:	53                   	push   %ebx
f0103006:	83 ec 1c             	sub    $0x1c,%esp
f0103009:	e8 cb d1 ff ff       	call   f01001d9 <__x86.get_pc_thunk.bx>
f010300e:	81 c3 e6 c0 08 00    	add    $0x8c0e6,%ebx
f0103014:	89 c7                	mov    %eax,%edi
	// LAB 3: Your code here.
	void* i;
	for (i = ROUNDDOWN(va, PGSIZE); i < ROUNDUP(va + len, PGSIZE); i+=PGSIZE){
f0103016:	89 d6                	mov    %edx,%esi
f0103018:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
f010301e:	8d 84 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%eax
f0103025:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010302a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010302d:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f0103030:	73 64                	jae    f0103096 <region_alloc+0x96>
		struct PageInfo *pginfo = page_alloc(0);
f0103032:	83 ec 0c             	sub    $0xc,%esp
f0103035:	6a 00                	push   $0x0
f0103037:	e8 f9 df ff ff       	call   f0101035 <page_alloc>
		if (!pginfo) {
f010303c:	83 c4 10             	add    $0x10,%esp
f010303f:	85 c0                	test   %eax,%eax
f0103041:	74 20                	je     f0103063 <region_alloc+0x63>
			 panic("region_alloc:%e", -E_NO_MEM);
		}
		pginfo->pp_ref++;
f0103043:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
		int r = page_insert(e->env_pgdir, pginfo, i, PTE_W | PTE_U | PTE_P);
f0103048:	6a 07                	push   $0x7
f010304a:	56                   	push   %esi
f010304b:	50                   	push   %eax
f010304c:	ff 77 5c             	pushl  0x5c(%edi)
f010304f:	e8 c8 e2 ff ff       	call   f010131c <page_insert>
		if (r < 0) {
f0103054:	83 c4 10             	add    $0x10,%esp
f0103057:	85 c0                	test   %eax,%eax
f0103059:	78 22                	js     f010307d <region_alloc+0x7d>
	for (i = ROUNDDOWN(va, PGSIZE); i < ROUNDUP(va + len, PGSIZE); i+=PGSIZE){
f010305b:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0103061:	eb ca                	jmp    f010302d <region_alloc+0x2d>
			 panic("region_alloc:%e", -E_NO_MEM);
f0103063:	6a fc                	push   $0xfffffffc
f0103065:	8d 83 28 70 f7 ff    	lea    -0x88fd8(%ebx),%eax
f010306b:	50                   	push   %eax
f010306c:	68 16 01 00 00       	push   $0x116
f0103071:	8d 83 38 70 f7 ff    	lea    -0x88fc8(%ebx),%eax
f0103077:	50                   	push   %eax
f0103078:	e8 a6 d0 ff ff       	call   f0100123 <_panic>
			 panic("region_alloc:%e", r);
f010307d:	50                   	push   %eax
f010307e:	8d 83 28 70 f7 ff    	lea    -0x88fd8(%ebx),%eax
f0103084:	50                   	push   %eax
f0103085:	68 1b 01 00 00       	push   $0x11b
f010308a:	8d 83 38 70 f7 ff    	lea    -0x88fc8(%ebx),%eax
f0103090:	50                   	push   %eax
f0103091:	e8 8d d0 ff ff       	call   f0100123 <_panic>
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
}
f0103096:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103099:	5b                   	pop    %ebx
f010309a:	5e                   	pop    %esi
f010309b:	5f                   	pop    %edi
f010309c:	5d                   	pop    %ebp
f010309d:	c3                   	ret    

f010309e <envid2env>:
{
f010309e:	55                   	push   %ebp
f010309f:	89 e5                	mov    %esp,%ebp
f01030a1:	53                   	push   %ebx
f01030a2:	e8 4d ff ff ff       	call   f0102ff4 <__x86.get_pc_thunk.cx>
f01030a7:	81 c1 4d c0 08 00    	add    $0x8c04d,%ecx
f01030ad:	8b 55 08             	mov    0x8(%ebp),%edx
f01030b0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if (envid == 0) {
f01030b3:	85 d2                	test   %edx,%edx
f01030b5:	74 41                	je     f01030f8 <envid2env+0x5a>
	e = &envs[ENVX(envid)];
f01030b7:	89 d0                	mov    %edx,%eax
f01030b9:	25 ff 03 00 00       	and    $0x3ff,%eax
f01030be:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01030c1:	c1 e0 05             	shl    $0x5,%eax
f01030c4:	03 81 54 02 00 00    	add    0x254(%ecx),%eax
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f01030ca:	83 78 54 00          	cmpl   $0x0,0x54(%eax)
f01030ce:	74 3a                	je     f010310a <envid2env+0x6c>
f01030d0:	39 50 48             	cmp    %edx,0x48(%eax)
f01030d3:	75 35                	jne    f010310a <envid2env+0x6c>
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f01030d5:	84 db                	test   %bl,%bl
f01030d7:	74 12                	je     f01030eb <envid2env+0x4d>
f01030d9:	8b 91 50 02 00 00    	mov    0x250(%ecx),%edx
f01030df:	39 c2                	cmp    %eax,%edx
f01030e1:	74 08                	je     f01030eb <envid2env+0x4d>
f01030e3:	8b 5a 48             	mov    0x48(%edx),%ebx
f01030e6:	39 58 4c             	cmp    %ebx,0x4c(%eax)
f01030e9:	75 2f                	jne    f010311a <envid2env+0x7c>
	*env_store = e;
f01030eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01030ee:	89 03                	mov    %eax,(%ebx)
	return 0;
f01030f0:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01030f5:	5b                   	pop    %ebx
f01030f6:	5d                   	pop    %ebp
f01030f7:	c3                   	ret    
		*env_store = curenv;
f01030f8:	8b 81 50 02 00 00    	mov    0x250(%ecx),%eax
f01030fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103101:	89 01                	mov    %eax,(%ecx)
		return 0;
f0103103:	b8 00 00 00 00       	mov    $0x0,%eax
f0103108:	eb eb                	jmp    f01030f5 <envid2env+0x57>
		*env_store = 0;
f010310a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010310d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0103113:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103118:	eb db                	jmp    f01030f5 <envid2env+0x57>
		*env_store = 0;
f010311a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010311d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0103123:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103128:	eb cb                	jmp    f01030f5 <envid2env+0x57>

f010312a <env_init_percpu>:
{
f010312a:	e8 1b d6 ff ff       	call   f010074a <__x86.get_pc_thunk.ax>
f010312f:	05 c5 bf 08 00       	add    $0x8bfc5,%eax
	asm volatile("lgdt (%0)" : : "r" (p));
f0103134:	8d 80 0c ff ff ff    	lea    -0xf4(%eax),%eax
f010313a:	0f 01 10             	lgdtl  (%eax)
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f010313d:	b8 23 00 00 00       	mov    $0x23,%eax
f0103142:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f0103144:	8e e0                	mov    %eax,%fs
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f0103146:	b8 10 00 00 00       	mov    $0x10,%eax
f010314b:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f010314d:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f010314f:	8e d0                	mov    %eax,%ss
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f0103151:	ea 58 31 10 f0 08 00 	ljmp   $0x8,$0xf0103158
	asm volatile("lldt %0" : : "r" (sel));
f0103158:	b8 00 00 00 00       	mov    $0x0,%eax
f010315d:	0f 00 d0             	lldt   %ax
}
f0103160:	c3                   	ret    

f0103161 <env_init>:
{
f0103161:	55                   	push   %ebp
f0103162:	89 e5                	mov    %esp,%ebp
f0103164:	57                   	push   %edi
f0103165:	56                   	push   %esi
f0103166:	53                   	push   %ebx
f0103167:	83 ec 0c             	sub    $0xc,%esp
f010316a:	e8 89 fe ff ff       	call   f0102ff8 <__x86.get_pc_thunk.si>
f010316f:	81 c6 85 bf 08 00    	add    $0x8bf85,%esi
		envs[i].env_id = 0;
f0103175:	8b be 54 02 00 00    	mov    0x254(%esi),%edi
f010317b:	8b 96 58 02 00 00    	mov    0x258(%esi),%edx
f0103181:	8d 87 a0 7f 01 00    	lea    0x17fa0(%edi),%eax
f0103187:	89 fb                	mov    %edi,%ebx
f0103189:	eb 02                	jmp    f010318d <env_init+0x2c>
f010318b:	89 c8                	mov    %ecx,%eax
f010318d:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_link = env_free_list;
f0103194:	89 50 44             	mov    %edx,0x44(%eax)
f0103197:	8d 48 a0             	lea    -0x60(%eax),%ecx
		env_free_list = &envs[i];
f010319a:	89 c2                	mov    %eax,%edx
	for (int i = NENV-1;i >= 0;i--) {
f010319c:	39 d8                	cmp    %ebx,%eax
f010319e:	75 eb                	jne    f010318b <env_init+0x2a>
f01031a0:	89 be 58 02 00 00    	mov    %edi,0x258(%esi)
	env_init_percpu();
f01031a6:	e8 7f ff ff ff       	call   f010312a <env_init_percpu>
}
f01031ab:	83 c4 0c             	add    $0xc,%esp
f01031ae:	5b                   	pop    %ebx
f01031af:	5e                   	pop    %esi
f01031b0:	5f                   	pop    %edi
f01031b1:	5d                   	pop    %ebp
f01031b2:	c3                   	ret    

f01031b3 <env_alloc>:
{
f01031b3:	55                   	push   %ebp
f01031b4:	89 e5                	mov    %esp,%ebp
f01031b6:	57                   	push   %edi
f01031b7:	56                   	push   %esi
f01031b8:	53                   	push   %ebx
f01031b9:	83 ec 0c             	sub    $0xc,%esp
f01031bc:	e8 18 d0 ff ff       	call   f01001d9 <__x86.get_pc_thunk.bx>
f01031c1:	81 c3 33 bf 08 00    	add    $0x8bf33,%ebx
	if (!(e = env_free_list))
f01031c7:	8b b3 58 02 00 00    	mov    0x258(%ebx),%esi
f01031cd:	85 f6                	test   %esi,%esi
f01031cf:	0f 84 67 01 00 00    	je     f010333c <env_alloc+0x189>
	if (!(p = page_alloc(ALLOC_ZERO)))
f01031d5:	83 ec 0c             	sub    $0xc,%esp
f01031d8:	6a 01                	push   $0x1
f01031da:	e8 56 de ff ff       	call   f0101035 <page_alloc>
f01031df:	89 c7                	mov    %eax,%edi
f01031e1:	83 c4 10             	add    $0x10,%esp
f01031e4:	85 c0                	test   %eax,%eax
f01031e6:	0f 84 57 01 00 00    	je     f0103343 <env_alloc+0x190>
	return (pp - pages) << PGSHIFT;
f01031ec:	c7 c0 0c 00 19 f0    	mov    $0xf019000c,%eax
f01031f2:	89 f9                	mov    %edi,%ecx
f01031f4:	2b 08                	sub    (%eax),%ecx
f01031f6:	89 c8                	mov    %ecx,%eax
f01031f8:	c1 f8 03             	sar    $0x3,%eax
f01031fb:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f01031fe:	89 c1                	mov    %eax,%ecx
f0103200:	c1 e9 0c             	shr    $0xc,%ecx
f0103203:	c7 c2 04 00 19 f0    	mov    $0xf0190004,%edx
f0103209:	3b 0a                	cmp    (%edx),%ecx
f010320b:	0f 83 fc 00 00 00    	jae    f010330d <env_alloc+0x15a>
	return (void *)(pa + KERNBASE);
f0103211:	2d 00 00 00 10       	sub    $0x10000000,%eax
	e->env_pgdir = page2kva(p);	
f0103216:	89 46 5c             	mov    %eax,0x5c(%esi)
	memcpy(e->env_pgdir, kern_pgdir, PGSIZE);
f0103219:	83 ec 04             	sub    $0x4,%esp
f010321c:	68 00 10 00 00       	push   $0x1000
f0103221:	c7 c2 08 00 19 f0    	mov    $0xf0190008,%edx
f0103227:	ff 32                	pushl  (%edx)
f0103229:	50                   	push   %eax
f010322a:	e8 6e 1b 00 00       	call   f0104d9d <memcpy>
	p->pp_ref++;
f010322f:	66 83 47 04 01       	addw   $0x1,0x4(%edi)
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0103234:	8b 46 5c             	mov    0x5c(%esi),%eax
	if ((uint32_t)kva < KERNBASE)
f0103237:	83 c4 10             	add    $0x10,%esp
f010323a:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010323f:	0f 86 de 00 00 00    	jbe    f0103323 <env_alloc+0x170>
	return (physaddr_t)kva - KERNBASE;
f0103245:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010324b:	83 ca 05             	or     $0x5,%edx
f010324e:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0103254:	8b 46 48             	mov    0x48(%esi),%eax
f0103257:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f010325c:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f0103261:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103266:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f0103269:	89 f2                	mov    %esi,%edx
f010326b:	2b 93 54 02 00 00    	sub    0x254(%ebx),%edx
f0103271:	c1 fa 05             	sar    $0x5,%edx
f0103274:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f010327a:	09 d0                	or     %edx,%eax
f010327c:	89 46 48             	mov    %eax,0x48(%esi)
	e->env_parent_id = parent_id;
f010327f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103282:	89 46 4c             	mov    %eax,0x4c(%esi)
	e->env_type = ENV_TYPE_USER;
f0103285:	c7 46 50 00 00 00 00 	movl   $0x0,0x50(%esi)
	e->env_status = ENV_RUNNABLE;
f010328c:	c7 46 54 02 00 00 00 	movl   $0x2,0x54(%esi)
	e->env_runs = 0;
f0103293:	c7 46 58 00 00 00 00 	movl   $0x0,0x58(%esi)
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f010329a:	83 ec 04             	sub    $0x4,%esp
f010329d:	6a 44                	push   $0x44
f010329f:	6a 00                	push   $0x0
f01032a1:	56                   	push   %esi
f01032a2:	e8 4c 1a 00 00       	call   f0104cf3 <memset>
	e->env_tf.tf_ds = GD_UD | 3;
f01032a7:	66 c7 46 24 23 00    	movw   $0x23,0x24(%esi)
	e->env_tf.tf_es = GD_UD | 3;
f01032ad:	66 c7 46 20 23 00    	movw   $0x23,0x20(%esi)
	e->env_tf.tf_ss = GD_UD | 3;
f01032b3:	66 c7 46 40 23 00    	movw   $0x23,0x40(%esi)
	e->env_tf.tf_esp = USTACKTOP;
f01032b9:	c7 46 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%esi)
	e->env_tf.tf_cs = GD_UT | 3;
f01032c0:	66 c7 46 34 1b 00    	movw   $0x1b,0x34(%esi)
	env_free_list = e->env_link;
f01032c6:	8b 46 44             	mov    0x44(%esi),%eax
f01032c9:	89 83 58 02 00 00    	mov    %eax,0x258(%ebx)
	*newenv_store = e;
f01032cf:	8b 45 08             	mov    0x8(%ebp),%eax
f01032d2:	89 30                	mov    %esi,(%eax)
	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01032d4:	8b 4e 48             	mov    0x48(%esi),%ecx
f01032d7:	8b 83 50 02 00 00    	mov    0x250(%ebx),%eax
f01032dd:	83 c4 10             	add    $0x10,%esp
f01032e0:	ba 00 00 00 00       	mov    $0x0,%edx
f01032e5:	85 c0                	test   %eax,%eax
f01032e7:	74 03                	je     f01032ec <env_alloc+0x139>
f01032e9:	8b 50 48             	mov    0x48(%eax),%edx
f01032ec:	83 ec 04             	sub    $0x4,%esp
f01032ef:	51                   	push   %ecx
f01032f0:	52                   	push   %edx
f01032f1:	8d 83 43 70 f7 ff    	lea    -0x88fbd(%ebx),%eax
f01032f7:	50                   	push   %eax
f01032f8:	e8 3a 05 00 00       	call   f0103837 <cprintf>
	return 0;
f01032fd:	83 c4 10             	add    $0x10,%esp
f0103300:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103305:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103308:	5b                   	pop    %ebx
f0103309:	5e                   	pop    %esi
f010330a:	5f                   	pop    %edi
f010330b:	5d                   	pop    %ebp
f010330c:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010330d:	50                   	push   %eax
f010330e:	8d 83 64 65 f7 ff    	lea    -0x89a9c(%ebx),%eax
f0103314:	50                   	push   %eax
f0103315:	6a 56                	push   $0x56
f0103317:	8d 83 51 6d f7 ff    	lea    -0x892af(%ebx),%eax
f010331d:	50                   	push   %eax
f010331e:	e8 00 ce ff ff       	call   f0100123 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103323:	50                   	push   %eax
f0103324:	8d 83 70 66 f7 ff    	lea    -0x89990(%ebx),%eax
f010332a:	50                   	push   %eax
f010332b:	68 c3 00 00 00       	push   $0xc3
f0103330:	8d 83 38 70 f7 ff    	lea    -0x88fc8(%ebx),%eax
f0103336:	50                   	push   %eax
f0103337:	e8 e7 cd ff ff       	call   f0100123 <_panic>
		return -E_NO_FREE_ENV;
f010333c:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0103341:	eb c2                	jmp    f0103305 <env_alloc+0x152>
		return -E_NO_MEM;
f0103343:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0103348:	eb bb                	jmp    f0103305 <env_alloc+0x152>

f010334a <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f010334a:	55                   	push   %ebp
f010334b:	89 e5                	mov    %esp,%ebp
f010334d:	57                   	push   %edi
f010334e:	56                   	push   %esi
f010334f:	53                   	push   %ebx
f0103350:	83 ec 34             	sub    $0x34,%esp
f0103353:	e8 81 ce ff ff       	call   f01001d9 <__x86.get_pc_thunk.bx>
f0103358:	81 c3 9c bd 08 00    	add    $0x8bd9c,%ebx
f010335e:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 3: Your code here.
	struct 	Env *e;	
	int r = env_alloc(&e, (envid_t)0);
f0103361:	6a 00                	push   $0x0
f0103363:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103366:	50                   	push   %eax
f0103367:	e8 47 fe ff ff       	call   f01031b3 <env_alloc>
	if (r < 0) {
f010336c:	83 c4 10             	add    $0x10,%esp
f010336f:	85 c0                	test   %eax,%eax
f0103371:	78 3e                	js     f01033b1 <env_create+0x67>
		 panic("env_create: %e", r);
	}
	e->env_type = type;
f0103373:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103376:	89 c1                	mov    %eax,%ecx
f0103378:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010337b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010337e:	89 41 50             	mov    %eax,0x50(%ecx)
	if (elf->e_magic != ELF_MAGIC) {
f0103381:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f0103387:	75 41                	jne    f01033ca <env_create+0x80>
	ph = (struct Proghdr *) (binary + elf->e_phoff);
f0103389:	89 fe                	mov    %edi,%esi
f010338b:	03 77 1c             	add    0x1c(%edi),%esi
	eph = ph + elf->e_phnum;
f010338e:	0f b7 47 2c          	movzwl 0x2c(%edi),%eax
f0103392:	c1 e0 05             	shl    $0x5,%eax
f0103395:	01 f0                	add    %esi,%eax
f0103397:	89 45 d0             	mov    %eax,-0x30(%ebp)
	lcr3(PADDR(e->env_pgdir));
f010339a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010339d:	8b 40 5c             	mov    0x5c(%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f01033a0:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01033a5:	76 3e                	jbe    f01033e5 <env_create+0x9b>
	return (physaddr_t)kva - KERNBASE;
f01033a7:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01033ac:	0f 22 d8             	mov    %eax,%cr3
f01033af:	eb 6b                	jmp    f010341c <env_create+0xd2>
		 panic("env_create: %e", r);
f01033b1:	50                   	push   %eax
f01033b2:	8d 83 58 70 f7 ff    	lea    -0x88fa8(%ebx),%eax
f01033b8:	50                   	push   %eax
f01033b9:	68 88 01 00 00       	push   $0x188
f01033be:	8d 83 38 70 f7 ff    	lea    -0x88fc8(%ebx),%eax
f01033c4:	50                   	push   %eax
f01033c5:	e8 59 cd ff ff       	call   f0100123 <_panic>
		 panic("load_icode: not an Elf file");
f01033ca:	83 ec 04             	sub    $0x4,%esp
f01033cd:	8d 83 67 70 f7 ff    	lea    -0x88f99(%ebx),%eax
f01033d3:	50                   	push   %eax
f01033d4:	68 60 01 00 00       	push   $0x160
f01033d9:	8d 83 38 70 f7 ff    	lea    -0x88fc8(%ebx),%eax
f01033df:	50                   	push   %eax
f01033e0:	e8 3e cd ff ff       	call   f0100123 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01033e5:	50                   	push   %eax
f01033e6:	8d 83 70 66 f7 ff    	lea    -0x89990(%ebx),%eax
f01033ec:	50                   	push   %eax
f01033ed:	68 65 01 00 00       	push   $0x165
f01033f2:	8d 83 38 70 f7 ff    	lea    -0x88fc8(%ebx),%eax
f01033f8:	50                   	push   %eax
f01033f9:	e8 25 cd ff ff       	call   f0100123 <_panic>
					 panic("load_icode: file size is greater than memory size");
f01033fe:	83 ec 04             	sub    $0x4,%esp
f0103401:	8d 83 a8 70 f7 ff    	lea    -0x88f58(%ebx),%eax
f0103407:	50                   	push   %eax
f0103408:	68 69 01 00 00       	push   $0x169
f010340d:	8d 83 38 70 f7 ff    	lea    -0x88fc8(%ebx),%eax
f0103413:	50                   	push   %eax
f0103414:	e8 0a cd ff ff       	call   f0100123 <_panic>
	for (; ph<eph; ph++) {
f0103419:	83 c6 20             	add    $0x20,%esi
f010341c:	39 75 d0             	cmp    %esi,-0x30(%ebp)
f010341f:	76 48                	jbe    f0103469 <env_create+0x11f>
		if (ph->p_type == ELF_PROG_LOAD) {
f0103421:	83 3e 01             	cmpl   $0x1,(%esi)
f0103424:	75 f3                	jne    f0103419 <env_create+0xcf>
			 if (ph->p_filesz > ph->p_memsz) {
f0103426:	8b 4e 14             	mov    0x14(%esi),%ecx
f0103429:	39 4e 10             	cmp    %ecx,0x10(%esi)
f010342c:	77 d0                	ja     f01033fe <env_create+0xb4>
			 region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f010342e:	8b 56 08             	mov    0x8(%esi),%edx
f0103431:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103434:	e8 c7 fb ff ff       	call   f0103000 <region_alloc>
			 memcpy((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
f0103439:	83 ec 04             	sub    $0x4,%esp
f010343c:	ff 76 10             	pushl  0x10(%esi)
f010343f:	89 f8                	mov    %edi,%eax
f0103441:	03 46 04             	add    0x4(%esi),%eax
f0103444:	50                   	push   %eax
f0103445:	ff 76 08             	pushl  0x8(%esi)
f0103448:	e8 50 19 00 00       	call   f0104d9d <memcpy>
			 memset((void *)ph->p_va + ph->p_filesz, 0, ph->p_memsz - ph->p_filesz);
f010344d:	8b 46 10             	mov    0x10(%esi),%eax
f0103450:	83 c4 0c             	add    $0xc,%esp
f0103453:	8b 56 14             	mov    0x14(%esi),%edx
f0103456:	29 c2                	sub    %eax,%edx
f0103458:	52                   	push   %edx
f0103459:	6a 00                	push   $0x0
f010345b:	03 46 08             	add    0x8(%esi),%eax
f010345e:	50                   	push   %eax
f010345f:	e8 8f 18 00 00       	call   f0104cf3 <memset>
f0103464:	83 c4 10             	add    $0x10,%esp
f0103467:	eb b0                	jmp    f0103419 <env_create+0xcf>
	e->env_tf.tf_eip = elf->e_entry;
f0103469:	8b 47 18             	mov    0x18(%edi),%eax
f010346c:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010346f:	89 47 30             	mov    %eax,0x30(%edi)
	region_alloc(e, (void *)USTACKTOP - PGSIZE, PGSIZE);
f0103472:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0103477:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f010347c:	89 f8                	mov    %edi,%eax
f010347e:	e8 7d fb ff ff       	call   f0103000 <region_alloc>
	lcr3(PADDR(kern_pgdir));
f0103483:	c7 c0 08 00 19 f0    	mov    $0xf0190008,%eax
f0103489:	8b 00                	mov    (%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f010348b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103490:	76 10                	jbe    f01034a2 <env_create+0x158>
	return (physaddr_t)kva - KERNBASE;
f0103492:	05 00 00 00 10       	add    $0x10000000,%eax
f0103497:	0f 22 d8             	mov    %eax,%cr3
	load_icode(e, binary);
}
f010349a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010349d:	5b                   	pop    %ebx
f010349e:	5e                   	pop    %esi
f010349f:	5f                   	pop    %edi
f01034a0:	5d                   	pop    %ebp
f01034a1:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01034a2:	50                   	push   %eax
f01034a3:	8d 83 70 66 f7 ff    	lea    -0x89990(%ebx),%eax
f01034a9:	50                   	push   %eax
f01034aa:	68 77 01 00 00       	push   $0x177
f01034af:	8d 83 38 70 f7 ff    	lea    -0x88fc8(%ebx),%eax
f01034b5:	50                   	push   %eax
f01034b6:	e8 68 cc ff ff       	call   f0100123 <_panic>

f01034bb <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f01034bb:	55                   	push   %ebp
f01034bc:	89 e5                	mov    %esp,%ebp
f01034be:	57                   	push   %edi
f01034bf:	56                   	push   %esi
f01034c0:	53                   	push   %ebx
f01034c1:	83 ec 2c             	sub    $0x2c,%esp
f01034c4:	e8 10 cd ff ff       	call   f01001d9 <__x86.get_pc_thunk.bx>
f01034c9:	81 c3 2b bc 08 00    	add    $0x8bc2b,%ebx
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f01034cf:	8b 93 50 02 00 00    	mov    0x250(%ebx),%edx
f01034d5:	3b 55 08             	cmp    0x8(%ebp),%edx
f01034d8:	74 3e                	je     f0103518 <env_free+0x5d>
		lcr3(PADDR(kern_pgdir));

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01034da:	8b 45 08             	mov    0x8(%ebp),%eax
f01034dd:	8b 48 48             	mov    0x48(%eax),%ecx
f01034e0:	b8 00 00 00 00       	mov    $0x0,%eax
f01034e5:	85 d2                	test   %edx,%edx
f01034e7:	74 03                	je     f01034ec <env_free+0x31>
f01034e9:	8b 42 48             	mov    0x48(%edx),%eax
f01034ec:	83 ec 04             	sub    $0x4,%esp
f01034ef:	51                   	push   %ecx
f01034f0:	50                   	push   %eax
f01034f1:	8d 83 83 70 f7 ff    	lea    -0x88f7d(%ebx),%eax
f01034f7:	50                   	push   %eax
f01034f8:	e8 3a 03 00 00       	call   f0103837 <cprintf>
f01034fd:	83 c4 10             	add    $0x10,%esp
f0103500:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
	if (PGNUM(pa) >= npages)
f0103507:	c7 c0 04 00 19 f0    	mov    $0xf0190004,%eax
f010350d:	89 45 d8             	mov    %eax,-0x28(%ebp)
	if (PGNUM(pa) >= npages)
f0103510:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0103513:	e9 c2 00 00 00       	jmp    f01035da <env_free+0x11f>
		lcr3(PADDR(kern_pgdir));
f0103518:	c7 c0 08 00 19 f0    	mov    $0xf0190008,%eax
f010351e:	8b 00                	mov    (%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0103520:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103525:	76 10                	jbe    f0103537 <env_free+0x7c>
	return (physaddr_t)kva - KERNBASE;
f0103527:	05 00 00 00 10       	add    $0x10000000,%eax
f010352c:	0f 22 d8             	mov    %eax,%cr3
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f010352f:	8b 45 08             	mov    0x8(%ebp),%eax
f0103532:	8b 48 48             	mov    0x48(%eax),%ecx
f0103535:	eb b2                	jmp    f01034e9 <env_free+0x2e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103537:	50                   	push   %eax
f0103538:	8d 83 70 66 f7 ff    	lea    -0x89990(%ebx),%eax
f010353e:	50                   	push   %eax
f010353f:	68 9c 01 00 00       	push   $0x19c
f0103544:	8d 83 38 70 f7 ff    	lea    -0x88fc8(%ebx),%eax
f010354a:	50                   	push   %eax
f010354b:	e8 d3 cb ff ff       	call   f0100123 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103550:	57                   	push   %edi
f0103551:	8d 83 64 65 f7 ff    	lea    -0x89a9c(%ebx),%eax
f0103557:	50                   	push   %eax
f0103558:	68 ab 01 00 00       	push   $0x1ab
f010355d:	8d 83 38 70 f7 ff    	lea    -0x88fc8(%ebx),%eax
f0103563:	50                   	push   %eax
f0103564:	e8 ba cb ff ff       	call   f0100123 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103569:	83 ec 08             	sub    $0x8,%esp
f010356c:	89 f0                	mov    %esi,%eax
f010356e:	c1 e0 0c             	shl    $0xc,%eax
f0103571:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103574:	50                   	push   %eax
f0103575:	8b 45 08             	mov    0x8(%ebp),%eax
f0103578:	ff 70 5c             	pushl  0x5c(%eax)
f010357b:	e8 61 dd ff ff       	call   f01012e1 <page_remove>
f0103580:	83 c4 10             	add    $0x10,%esp
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103583:	83 c6 01             	add    $0x1,%esi
f0103586:	83 c7 04             	add    $0x4,%edi
f0103589:	81 fe 00 04 00 00    	cmp    $0x400,%esi
f010358f:	74 07                	je     f0103598 <env_free+0xdd>
			if (pt[pteno] & PTE_P)
f0103591:	f6 07 01             	testb  $0x1,(%edi)
f0103594:	74 ed                	je     f0103583 <env_free+0xc8>
f0103596:	eb d1                	jmp    f0103569 <env_free+0xae>
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103598:	8b 45 08             	mov    0x8(%ebp),%eax
f010359b:	8b 40 5c             	mov    0x5c(%eax),%eax
f010359e:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01035a1:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
	if (PGNUM(pa) >= npages)
f01035a8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01035ab:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01035ae:	3b 10                	cmp    (%eax),%edx
f01035b0:	73 6e                	jae    f0103620 <env_free+0x165>
		page_decref(pa2page(pa));
f01035b2:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f01035b5:	c7 c0 0c 00 19 f0    	mov    $0xf019000c,%eax
f01035bb:	8b 00                	mov    (%eax),%eax
f01035bd:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01035c0:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f01035c3:	50                   	push   %eax
f01035c4:	e8 43 db ff ff       	call   f010110c <page_decref>
f01035c9:	83 c4 10             	add    $0x10,%esp
f01035cc:	83 45 e0 04          	addl   $0x4,-0x20(%ebp)
f01035d0:	8b 45 e0             	mov    -0x20(%ebp),%eax
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f01035d3:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f01035d8:	74 5e                	je     f0103638 <env_free+0x17d>
		if (!(e->env_pgdir[pdeno] & PTE_P))
f01035da:	8b 45 08             	mov    0x8(%ebp),%eax
f01035dd:	8b 40 5c             	mov    0x5c(%eax),%eax
f01035e0:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01035e3:	8b 3c 10             	mov    (%eax,%edx,1),%edi
f01035e6:	f7 c7 01 00 00 00    	test   $0x1,%edi
f01035ec:	74 de                	je     f01035cc <env_free+0x111>
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f01035ee:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	if (PGNUM(pa) >= npages)
f01035f4:	89 f8                	mov    %edi,%eax
f01035f6:	c1 e8 0c             	shr    $0xc,%eax
f01035f9:	89 45 dc             	mov    %eax,-0x24(%ebp)
f01035fc:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01035ff:	39 02                	cmp    %eax,(%edx)
f0103601:	0f 86 49 ff ff ff    	jbe    f0103550 <env_free+0x95>
	return (void *)(pa + KERNBASE);
f0103607:	81 ef 00 00 00 10    	sub    $0x10000000,%edi
f010360d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103610:	c1 e0 14             	shl    $0x14,%eax
f0103613:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103616:	be 00 00 00 00       	mov    $0x0,%esi
f010361b:	e9 71 ff ff ff       	jmp    f0103591 <env_free+0xd6>
		panic("pa2page called with invalid pa");
f0103620:	83 ec 04             	sub    $0x4,%esp
f0103623:	8d 83 cc 66 f7 ff    	lea    -0x89934(%ebx),%eax
f0103629:	50                   	push   %eax
f010362a:	6a 4f                	push   $0x4f
f010362c:	8d 83 51 6d f7 ff    	lea    -0x892af(%ebx),%eax
f0103632:	50                   	push   %eax
f0103633:	e8 eb ca ff ff       	call   f0100123 <_panic>
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103638:	8b 45 08             	mov    0x8(%ebp),%eax
f010363b:	8b 40 5c             	mov    0x5c(%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f010363e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103643:	76 57                	jbe    f010369c <env_free+0x1e1>
	e->env_pgdir = 0;
f0103645:	8b 55 08             	mov    0x8(%ebp),%edx
f0103648:	c7 42 5c 00 00 00 00 	movl   $0x0,0x5c(%edx)
	return (physaddr_t)kva - KERNBASE;
f010364f:	05 00 00 00 10       	add    $0x10000000,%eax
	if (PGNUM(pa) >= npages)
f0103654:	c1 e8 0c             	shr    $0xc,%eax
f0103657:	c7 c2 04 00 19 f0    	mov    $0xf0190004,%edx
f010365d:	3b 02                	cmp    (%edx),%eax
f010365f:	73 54                	jae    f01036b5 <env_free+0x1fa>
	page_decref(pa2page(pa));
f0103661:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f0103664:	c7 c2 0c 00 19 f0    	mov    $0xf019000c,%edx
f010366a:	8b 12                	mov    (%edx),%edx
f010366c:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f010366f:	50                   	push   %eax
f0103670:	e8 97 da ff ff       	call   f010110c <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103675:	8b 45 08             	mov    0x8(%ebp),%eax
f0103678:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
	e->env_link = env_free_list;
f010367f:	8b 83 58 02 00 00    	mov    0x258(%ebx),%eax
f0103685:	8b 55 08             	mov    0x8(%ebp),%edx
f0103688:	89 42 44             	mov    %eax,0x44(%edx)
	env_free_list = e;
f010368b:	89 93 58 02 00 00    	mov    %edx,0x258(%ebx)
}
f0103691:	83 c4 10             	add    $0x10,%esp
f0103694:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103697:	5b                   	pop    %ebx
f0103698:	5e                   	pop    %esi
f0103699:	5f                   	pop    %edi
f010369a:	5d                   	pop    %ebp
f010369b:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010369c:	50                   	push   %eax
f010369d:	8d 83 70 66 f7 ff    	lea    -0x89990(%ebx),%eax
f01036a3:	50                   	push   %eax
f01036a4:	68 b9 01 00 00       	push   $0x1b9
f01036a9:	8d 83 38 70 f7 ff    	lea    -0x88fc8(%ebx),%eax
f01036af:	50                   	push   %eax
f01036b0:	e8 6e ca ff ff       	call   f0100123 <_panic>
		panic("pa2page called with invalid pa");
f01036b5:	83 ec 04             	sub    $0x4,%esp
f01036b8:	8d 83 cc 66 f7 ff    	lea    -0x89934(%ebx),%eax
f01036be:	50                   	push   %eax
f01036bf:	6a 4f                	push   $0x4f
f01036c1:	8d 83 51 6d f7 ff    	lea    -0x892af(%ebx),%eax
f01036c7:	50                   	push   %eax
f01036c8:	e8 56 ca ff ff       	call   f0100123 <_panic>

f01036cd <env_destroy>:
//
// Frees environment e.
//
void
env_destroy(struct Env *e)
{
f01036cd:	55                   	push   %ebp
f01036ce:	89 e5                	mov    %esp,%ebp
f01036d0:	53                   	push   %ebx
f01036d1:	83 ec 10             	sub    $0x10,%esp
f01036d4:	e8 00 cb ff ff       	call   f01001d9 <__x86.get_pc_thunk.bx>
f01036d9:	81 c3 1b ba 08 00    	add    $0x8ba1b,%ebx
	env_free(e);
f01036df:	ff 75 08             	pushl  0x8(%ebp)
f01036e2:	e8 d4 fd ff ff       	call   f01034bb <env_free>

	cprintf("Destroyed the only environment - nothing more to do!\n");
f01036e7:	8d 83 dc 70 f7 ff    	lea    -0x88f24(%ebx),%eax
f01036ed:	89 04 24             	mov    %eax,(%esp)
f01036f0:	e8 42 01 00 00       	call   f0103837 <cprintf>
f01036f5:	83 c4 10             	add    $0x10,%esp
	while (1)
		monitor(NULL);
f01036f8:	83 ec 0c             	sub    $0xc,%esp
f01036fb:	6a 00                	push   $0x0
f01036fd:	e8 26 d2 ff ff       	call   f0100928 <monitor>
f0103702:	83 c4 10             	add    $0x10,%esp
f0103705:	eb f1                	jmp    f01036f8 <env_destroy+0x2b>

f0103707 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103707:	55                   	push   %ebp
f0103708:	89 e5                	mov    %esp,%ebp
f010370a:	53                   	push   %ebx
f010370b:	83 ec 08             	sub    $0x8,%esp
f010370e:	e8 c6 ca ff ff       	call   f01001d9 <__x86.get_pc_thunk.bx>
f0103713:	81 c3 e1 b9 08 00    	add    $0x8b9e1,%ebx
	asm volatile(
f0103719:	8b 65 08             	mov    0x8(%ebp),%esp
f010371c:	61                   	popa   
f010371d:	07                   	pop    %es
f010371e:	1f                   	pop    %ds
f010371f:	83 c4 08             	add    $0x8,%esp
f0103722:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103723:	8d 83 99 70 f7 ff    	lea    -0x88f67(%ebx),%eax
f0103729:	50                   	push   %eax
f010372a:	68 e2 01 00 00       	push   $0x1e2
f010372f:	8d 83 38 70 f7 ff    	lea    -0x88fc8(%ebx),%eax
f0103735:	50                   	push   %eax
f0103736:	e8 e8 c9 ff ff       	call   f0100123 <_panic>

f010373b <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f010373b:	55                   	push   %ebp
f010373c:	89 e5                	mov    %esp,%ebp
f010373e:	53                   	push   %ebx
f010373f:	83 ec 04             	sub    $0x4,%esp
f0103742:	e8 92 ca ff ff       	call   f01001d9 <__x86.get_pc_thunk.bx>
f0103747:	81 c3 ad b9 08 00    	add    $0x8b9ad,%ebx
f010374d:	8b 45 08             	mov    0x8(%ebp),%eax
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	if (curenv && curenv->env_status == ENV_RUNNING) {
f0103750:	8b 93 50 02 00 00    	mov    0x250(%ebx),%edx
f0103756:	85 d2                	test   %edx,%edx
f0103758:	74 06                	je     f0103760 <env_run+0x25>
f010375a:	83 7a 54 03          	cmpl   $0x3,0x54(%edx)
f010375e:	74 2e                	je     f010378e <env_run+0x53>
		 curenv->env_status = ENV_RUNNABLE;
	}
		 curenv = e;
f0103760:	89 83 50 02 00 00    	mov    %eax,0x250(%ebx)
		 e->env_status = ENV_RUNNING;
f0103766:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
		 e->env_runs++ ;
f010376d:	83 40 58 01          	addl   $0x1,0x58(%eax)
		 lcr3(PADDR(e->env_pgdir));
f0103771:	8b 50 5c             	mov    0x5c(%eax),%edx
	if ((uint32_t)kva < KERNBASE)
f0103774:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f010377a:	76 1b                	jbe    f0103797 <env_run+0x5c>
	return (physaddr_t)kva - KERNBASE;
f010377c:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0103782:	0f 22 da             	mov    %edx,%cr3

		 env_pop_tf(&e->env_tf);
f0103785:	83 ec 0c             	sub    $0xc,%esp
f0103788:	50                   	push   %eax
f0103789:	e8 79 ff ff ff       	call   f0103707 <env_pop_tf>
		 curenv->env_status = ENV_RUNNABLE;
f010378e:	c7 42 54 02 00 00 00 	movl   $0x2,0x54(%edx)
f0103795:	eb c9                	jmp    f0103760 <env_run+0x25>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103797:	52                   	push   %edx
f0103798:	8d 83 70 66 f7 ff    	lea    -0x89990(%ebx),%eax
f010379e:	50                   	push   %eax
f010379f:	68 06 02 00 00       	push   $0x206
f01037a4:	8d 83 38 70 f7 ff    	lea    -0x88fc8(%ebx),%eax
f01037aa:	50                   	push   %eax
f01037ab:	e8 73 c9 ff ff       	call   f0100123 <_panic>

f01037b0 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f01037b0:	55                   	push   %ebp
f01037b1:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01037b3:	8b 45 08             	mov    0x8(%ebp),%eax
f01037b6:	ba 70 00 00 00       	mov    $0x70,%edx
f01037bb:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01037bc:	ba 71 00 00 00       	mov    $0x71,%edx
f01037c1:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f01037c2:	0f b6 c0             	movzbl %al,%eax
}
f01037c5:	5d                   	pop    %ebp
f01037c6:	c3                   	ret    

f01037c7 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f01037c7:	55                   	push   %ebp
f01037c8:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01037ca:	8b 45 08             	mov    0x8(%ebp),%eax
f01037cd:	ba 70 00 00 00       	mov    $0x70,%edx
f01037d2:	ee                   	out    %al,(%dx)
f01037d3:	8b 45 0c             	mov    0xc(%ebp),%eax
f01037d6:	ba 71 00 00 00       	mov    $0x71,%edx
f01037db:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f01037dc:	5d                   	pop    %ebp
f01037dd:	c3                   	ret    

f01037de <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01037de:	55                   	push   %ebp
f01037df:	89 e5                	mov    %esp,%ebp
f01037e1:	53                   	push   %ebx
f01037e2:	83 ec 10             	sub    $0x10,%esp
f01037e5:	e8 ef c9 ff ff       	call   f01001d9 <__x86.get_pc_thunk.bx>
f01037ea:	81 c3 0a b9 08 00    	add    $0x8b90a,%ebx
	cputchar(ch);
f01037f0:	ff 75 08             	pushl  0x8(%ebp)
f01037f3:	e8 2b cf ff ff       	call   f0100723 <cputchar>
	*cnt++;
}
f01037f8:	83 c4 10             	add    $0x10,%esp
f01037fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01037fe:	c9                   	leave  
f01037ff:	c3                   	ret    

f0103800 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103800:	55                   	push   %ebp
f0103801:	89 e5                	mov    %esp,%ebp
f0103803:	53                   	push   %ebx
f0103804:	83 ec 14             	sub    $0x14,%esp
f0103807:	e8 cd c9 ff ff       	call   f01001d9 <__x86.get_pc_thunk.bx>
f010380c:	81 c3 e8 b8 08 00    	add    $0x8b8e8,%ebx
	int cnt = 0;
f0103812:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103819:	ff 75 0c             	pushl  0xc(%ebp)
f010381c:	ff 75 08             	pushl  0x8(%ebp)
f010381f:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103822:	50                   	push   %eax
f0103823:	8d 83 ea 46 f7 ff    	lea    -0x8b916(%ebx),%eax
f0103829:	50                   	push   %eax
f010382a:	e8 31 0d 00 00       	call   f0104560 <vprintfmt>
	return cnt;
}
f010382f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103832:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103835:	c9                   	leave  
f0103836:	c3                   	ret    

f0103837 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103837:	55                   	push   %ebp
f0103838:	89 e5                	mov    %esp,%ebp
f010383a:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f010383d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103840:	50                   	push   %eax
f0103841:	ff 75 08             	pushl  0x8(%ebp)
f0103844:	e8 b7 ff ff ff       	call   f0103800 <vcprintf>
	va_end(ap);

	return cnt;
}
f0103849:	c9                   	leave  
f010384a:	c3                   	ret    

f010384b <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f010384b:	55                   	push   %ebp
f010384c:	89 e5                	mov    %esp,%ebp
f010384e:	57                   	push   %edi
f010384f:	56                   	push   %esi
f0103850:	53                   	push   %ebx
f0103851:	83 ec 04             	sub    $0x4,%esp
f0103854:	e8 80 c9 ff ff       	call   f01001d9 <__x86.get_pc_thunk.bx>
f0103859:	81 c3 9b b8 08 00    	add    $0x8b89b,%ebx
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f010385f:	c7 83 90 0a 00 00 00 	movl   $0xf0000000,0xa90(%ebx)
f0103866:	00 00 f0 
	ts.ts_ss0 = GD_KD;
f0103869:	66 c7 83 94 0a 00 00 	movw   $0x10,0xa94(%ebx)
f0103870:	10 00 
	ts.ts_iomb = sizeof(struct Taskstate);
f0103872:	66 c7 83 f2 0a 00 00 	movw   $0x68,0xaf2(%ebx)
f0103879:	68 00 

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f010387b:	c7 c0 00 c3 11 f0    	mov    $0xf011c300,%eax
f0103881:	66 c7 40 28 67 00    	movw   $0x67,0x28(%eax)
f0103887:	8d b3 8c 0a 00 00    	lea    0xa8c(%ebx),%esi
f010388d:	66 89 70 2a          	mov    %si,0x2a(%eax)
f0103891:	89 f2                	mov    %esi,%edx
f0103893:	c1 ea 10             	shr    $0x10,%edx
f0103896:	88 50 2c             	mov    %dl,0x2c(%eax)
f0103899:	0f b6 50 2d          	movzbl 0x2d(%eax),%edx
f010389d:	83 e2 f0             	and    $0xfffffff0,%edx
f01038a0:	83 ca 09             	or     $0x9,%edx
f01038a3:	83 e2 9f             	and    $0xffffff9f,%edx
f01038a6:	83 ca 80             	or     $0xffffff80,%edx
f01038a9:	88 55 f3             	mov    %dl,-0xd(%ebp)
f01038ac:	88 50 2d             	mov    %dl,0x2d(%eax)
f01038af:	0f b6 48 2e          	movzbl 0x2e(%eax),%ecx
f01038b3:	83 e1 c0             	and    $0xffffffc0,%ecx
f01038b6:	83 c9 40             	or     $0x40,%ecx
f01038b9:	83 e1 7f             	and    $0x7f,%ecx
f01038bc:	88 48 2e             	mov    %cl,0x2e(%eax)
f01038bf:	c1 ee 18             	shr    $0x18,%esi
f01038c2:	89 f1                	mov    %esi,%ecx
f01038c4:	88 48 2f             	mov    %cl,0x2f(%eax)
					sizeof(struct Taskstate) - 1, 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
f01038c7:	0f b6 55 f3          	movzbl -0xd(%ebp),%edx
f01038cb:	83 e2 ef             	and    $0xffffffef,%edx
f01038ce:	88 50 2d             	mov    %dl,0x2d(%eax)
	asm volatile("ltr %0" : : "r" (sel));
f01038d1:	b8 28 00 00 00       	mov    $0x28,%eax
f01038d6:	0f 00 d8             	ltr    %ax
	asm volatile("lidt (%0)" : : "r" (p));
f01038d9:	8d 83 14 ff ff ff    	lea    -0xec(%ebx),%eax
f01038df:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f01038e2:	83 c4 04             	add    $0x4,%esp
f01038e5:	5b                   	pop    %ebx
f01038e6:	5e                   	pop    %esi
f01038e7:	5f                   	pop    %edi
f01038e8:	5d                   	pop    %ebp
f01038e9:	c3                   	ret    

f01038ea <trap_init>:
{
f01038ea:	55                   	push   %ebp
f01038eb:	89 e5                	mov    %esp,%ebp
f01038ed:	e8 58 ce ff ff       	call   f010074a <__x86.get_pc_thunk.ax>
f01038f2:	05 02 b8 08 00       	add    $0x8b802,%eax
    SETGATE(idt[T_DIVIDE], 1, GD_KT, traphandler0, 0);
f01038f7:	c7 c2 68 40 10 f0    	mov    $0xf0104068,%edx
f01038fd:	66 89 90 6c 02 00 00 	mov    %dx,0x26c(%eax)
f0103904:	66 c7 80 6e 02 00 00 	movw   $0x8,0x26e(%eax)
f010390b:	08 00 
f010390d:	c6 80 70 02 00 00 00 	movb   $0x0,0x270(%eax)
f0103914:	c6 80 71 02 00 00 8f 	movb   $0x8f,0x271(%eax)
f010391b:	c1 ea 10             	shr    $0x10,%edx
f010391e:	66 89 90 72 02 00 00 	mov    %dx,0x272(%eax)
    SETGATE(idt[T_DEBUG], 1, GD_KT, traphandler1, 0);
f0103925:	c7 c2 6e 40 10 f0    	mov    $0xf010406e,%edx
f010392b:	66 89 90 74 02 00 00 	mov    %dx,0x274(%eax)
f0103932:	66 c7 80 76 02 00 00 	movw   $0x8,0x276(%eax)
f0103939:	08 00 
f010393b:	c6 80 78 02 00 00 00 	movb   $0x0,0x278(%eax)
f0103942:	c6 80 79 02 00 00 8f 	movb   $0x8f,0x279(%eax)
f0103949:	c1 ea 10             	shr    $0x10,%edx
f010394c:	66 89 90 7a 02 00 00 	mov    %dx,0x27a(%eax)
    SETGATE(idt[T_NMI], 1, GD_KT, traphandler2, 0);
f0103953:	c7 c2 74 40 10 f0    	mov    $0xf0104074,%edx
f0103959:	66 89 90 7c 02 00 00 	mov    %dx,0x27c(%eax)
f0103960:	66 c7 80 7e 02 00 00 	movw   $0x8,0x27e(%eax)
f0103967:	08 00 
f0103969:	c6 80 80 02 00 00 00 	movb   $0x0,0x280(%eax)
f0103970:	c6 80 81 02 00 00 8f 	movb   $0x8f,0x281(%eax)
f0103977:	c1 ea 10             	shr    $0x10,%edx
f010397a:	66 89 90 82 02 00 00 	mov    %dx,0x282(%eax)
    SETGATE(idt[T_BRKPT], 1, GD_KT, traphandler3, 0);
f0103981:	c7 c2 7a 40 10 f0    	mov    $0xf010407a,%edx
f0103987:	66 89 90 84 02 00 00 	mov    %dx,0x284(%eax)
f010398e:	66 c7 80 86 02 00 00 	movw   $0x8,0x286(%eax)
f0103995:	08 00 
f0103997:	c6 80 88 02 00 00 00 	movb   $0x0,0x288(%eax)
f010399e:	c6 80 89 02 00 00 8f 	movb   $0x8f,0x289(%eax)
f01039a5:	c1 ea 10             	shr    $0x10,%edx
f01039a8:	66 89 90 8a 02 00 00 	mov    %dx,0x28a(%eax)
    SETGATE(idt[T_OFLOW], 1, GD_KT, traphandler4, 0);
f01039af:	c7 c2 80 40 10 f0    	mov    $0xf0104080,%edx
f01039b5:	66 89 90 8c 02 00 00 	mov    %dx,0x28c(%eax)
f01039bc:	66 c7 80 8e 02 00 00 	movw   $0x8,0x28e(%eax)
f01039c3:	08 00 
f01039c5:	c6 80 90 02 00 00 00 	movb   $0x0,0x290(%eax)
f01039cc:	c6 80 91 02 00 00 8f 	movb   $0x8f,0x291(%eax)
f01039d3:	c1 ea 10             	shr    $0x10,%edx
f01039d6:	66 89 90 92 02 00 00 	mov    %dx,0x292(%eax)
    SETGATE(idt[T_BOUND], 1, GD_KT, traphandler5, 0);
f01039dd:	c7 c2 86 40 10 f0    	mov    $0xf0104086,%edx
f01039e3:	66 89 90 94 02 00 00 	mov    %dx,0x294(%eax)
f01039ea:	66 c7 80 96 02 00 00 	movw   $0x8,0x296(%eax)
f01039f1:	08 00 
f01039f3:	c6 80 98 02 00 00 00 	movb   $0x0,0x298(%eax)
f01039fa:	c6 80 99 02 00 00 8f 	movb   $0x8f,0x299(%eax)
f0103a01:	c1 ea 10             	shr    $0x10,%edx
f0103a04:	66 89 90 9a 02 00 00 	mov    %dx,0x29a(%eax)
    SETGATE(idt[T_ILLOP], 1, GD_KT, traphandler6, 0);
f0103a0b:	c7 c2 8c 40 10 f0    	mov    $0xf010408c,%edx
f0103a11:	66 89 90 9c 02 00 00 	mov    %dx,0x29c(%eax)
f0103a18:	66 c7 80 9e 02 00 00 	movw   $0x8,0x29e(%eax)
f0103a1f:	08 00 
f0103a21:	c6 80 a0 02 00 00 00 	movb   $0x0,0x2a0(%eax)
f0103a28:	c6 80 a1 02 00 00 8f 	movb   $0x8f,0x2a1(%eax)
f0103a2f:	c1 ea 10             	shr    $0x10,%edx
f0103a32:	66 89 90 a2 02 00 00 	mov    %dx,0x2a2(%eax)
    SETGATE(idt[T_DEVICE], 1, GD_KT, traphandler7, 0);
f0103a39:	c7 c2 92 40 10 f0    	mov    $0xf0104092,%edx
f0103a3f:	66 89 90 a4 02 00 00 	mov    %dx,0x2a4(%eax)
f0103a46:	66 c7 80 a6 02 00 00 	movw   $0x8,0x2a6(%eax)
f0103a4d:	08 00 
f0103a4f:	c6 80 a8 02 00 00 00 	movb   $0x0,0x2a8(%eax)
f0103a56:	c6 80 a9 02 00 00 8f 	movb   $0x8f,0x2a9(%eax)
f0103a5d:	c1 ea 10             	shr    $0x10,%edx
f0103a60:	66 89 90 aa 02 00 00 	mov    %dx,0x2aa(%eax)
    SETGATE(idt[T_DBLFLT], 1, GD_KT, traphandler8, 0);
f0103a67:	c7 c2 98 40 10 f0    	mov    $0xf0104098,%edx
f0103a6d:	66 89 90 ac 02 00 00 	mov    %dx,0x2ac(%eax)
f0103a74:	66 c7 80 ae 02 00 00 	movw   $0x8,0x2ae(%eax)
f0103a7b:	08 00 
f0103a7d:	c6 80 b0 02 00 00 00 	movb   $0x0,0x2b0(%eax)
f0103a84:	c6 80 b1 02 00 00 8f 	movb   $0x8f,0x2b1(%eax)
f0103a8b:	c1 ea 10             	shr    $0x10,%edx
f0103a8e:	66 89 90 b2 02 00 00 	mov    %dx,0x2b2(%eax)
    SETGATE(idt[T_TSS], 1, GD_KT, traphandler10, 0);
f0103a95:	c7 c2 9c 40 10 f0    	mov    $0xf010409c,%edx
f0103a9b:	66 89 90 bc 02 00 00 	mov    %dx,0x2bc(%eax)
f0103aa2:	66 c7 80 be 02 00 00 	movw   $0x8,0x2be(%eax)
f0103aa9:	08 00 
f0103aab:	c6 80 c0 02 00 00 00 	movb   $0x0,0x2c0(%eax)
f0103ab2:	c6 80 c1 02 00 00 8f 	movb   $0x8f,0x2c1(%eax)
f0103ab9:	c1 ea 10             	shr    $0x10,%edx
f0103abc:	66 89 90 c2 02 00 00 	mov    %dx,0x2c2(%eax)
    SETGATE(idt[T_SEGNP], 1, GD_KT, traphandler11, 0);
f0103ac3:	c7 c2 a0 40 10 f0    	mov    $0xf01040a0,%edx
f0103ac9:	66 89 90 c4 02 00 00 	mov    %dx,0x2c4(%eax)
f0103ad0:	66 c7 80 c6 02 00 00 	movw   $0x8,0x2c6(%eax)
f0103ad7:	08 00 
f0103ad9:	c6 80 c8 02 00 00 00 	movb   $0x0,0x2c8(%eax)
f0103ae0:	c6 80 c9 02 00 00 8f 	movb   $0x8f,0x2c9(%eax)
f0103ae7:	c1 ea 10             	shr    $0x10,%edx
f0103aea:	66 89 90 ca 02 00 00 	mov    %dx,0x2ca(%eax)
    SETGATE(idt[T_STACK], 1, GD_KT, traphandler12, 0);
f0103af1:	c7 c2 a4 40 10 f0    	mov    $0xf01040a4,%edx
f0103af7:	66 89 90 cc 02 00 00 	mov    %dx,0x2cc(%eax)
f0103afe:	66 c7 80 ce 02 00 00 	movw   $0x8,0x2ce(%eax)
f0103b05:	08 00 
f0103b07:	c6 80 d0 02 00 00 00 	movb   $0x0,0x2d0(%eax)
f0103b0e:	c6 80 d1 02 00 00 8f 	movb   $0x8f,0x2d1(%eax)
f0103b15:	c1 ea 10             	shr    $0x10,%edx
f0103b18:	66 89 90 d2 02 00 00 	mov    %dx,0x2d2(%eax)
    SETGATE(idt[T_GPFLT], 1, GD_KT, traphandler13, 0);
f0103b1f:	c7 c2 a8 40 10 f0    	mov    $0xf01040a8,%edx
f0103b25:	66 89 90 d4 02 00 00 	mov    %dx,0x2d4(%eax)
f0103b2c:	66 c7 80 d6 02 00 00 	movw   $0x8,0x2d6(%eax)
f0103b33:	08 00 
f0103b35:	c6 80 d8 02 00 00 00 	movb   $0x0,0x2d8(%eax)
f0103b3c:	c6 80 d9 02 00 00 8f 	movb   $0x8f,0x2d9(%eax)
f0103b43:	c1 ea 10             	shr    $0x10,%edx
f0103b46:	66 89 90 da 02 00 00 	mov    %dx,0x2da(%eax)
    SETGATE(idt[T_PGFLT], 1, GD_KT, traphandler14, 0);
f0103b4d:	c7 c2 ac 40 10 f0    	mov    $0xf01040ac,%edx
f0103b53:	66 89 90 dc 02 00 00 	mov    %dx,0x2dc(%eax)
f0103b5a:	66 c7 80 de 02 00 00 	movw   $0x8,0x2de(%eax)
f0103b61:	08 00 
f0103b63:	c6 80 e0 02 00 00 00 	movb   $0x0,0x2e0(%eax)
f0103b6a:	c6 80 e1 02 00 00 8f 	movb   $0x8f,0x2e1(%eax)
f0103b71:	c1 ea 10             	shr    $0x10,%edx
f0103b74:	66 89 90 e2 02 00 00 	mov    %dx,0x2e2(%eax)
    SETGATE(idt[T_FPERR], 1, GD_KT, traphandler16, 0);
f0103b7b:	c7 c2 b0 40 10 f0    	mov    $0xf01040b0,%edx
f0103b81:	66 89 90 ec 02 00 00 	mov    %dx,0x2ec(%eax)
f0103b88:	66 c7 80 ee 02 00 00 	movw   $0x8,0x2ee(%eax)
f0103b8f:	08 00 
f0103b91:	c6 80 f0 02 00 00 00 	movb   $0x0,0x2f0(%eax)
f0103b98:	c6 80 f1 02 00 00 8f 	movb   $0x8f,0x2f1(%eax)
f0103b9f:	c1 ea 10             	shr    $0x10,%edx
f0103ba2:	66 89 90 f2 02 00 00 	mov    %dx,0x2f2(%eax)
    SETGATE(idt[T_ALIGN], 1, GD_KT, traphandler17, 0);
f0103ba9:	c7 c2 b6 40 10 f0    	mov    $0xf01040b6,%edx
f0103baf:	66 89 90 f4 02 00 00 	mov    %dx,0x2f4(%eax)
f0103bb6:	66 c7 80 f6 02 00 00 	movw   $0x8,0x2f6(%eax)
f0103bbd:	08 00 
f0103bbf:	c6 80 f8 02 00 00 00 	movb   $0x0,0x2f8(%eax)
f0103bc6:	c6 80 f9 02 00 00 8f 	movb   $0x8f,0x2f9(%eax)
f0103bcd:	c1 ea 10             	shr    $0x10,%edx
f0103bd0:	66 89 90 fa 02 00 00 	mov    %dx,0x2fa(%eax)
    SETGATE(idt[T_MCHK], 1, GD_KT, traphandler18, 0);
f0103bd7:	c7 c2 ba 40 10 f0    	mov    $0xf01040ba,%edx
f0103bdd:	66 89 90 fc 02 00 00 	mov    %dx,0x2fc(%eax)
f0103be4:	66 c7 80 fe 02 00 00 	movw   $0x8,0x2fe(%eax)
f0103beb:	08 00 
f0103bed:	c6 80 00 03 00 00 00 	movb   $0x0,0x300(%eax)
f0103bf4:	c6 80 01 03 00 00 8f 	movb   $0x8f,0x301(%eax)
f0103bfb:	c1 ea 10             	shr    $0x10,%edx
f0103bfe:	66 89 90 02 03 00 00 	mov    %dx,0x302(%eax)
    SETGATE(idt[T_SIMDERR], 1, GD_KT, traphandler19, 0);
f0103c05:	c7 c2 c0 40 10 f0    	mov    $0xf01040c0,%edx
f0103c0b:	66 89 90 04 03 00 00 	mov    %dx,0x304(%eax)
f0103c12:	66 c7 80 06 03 00 00 	movw   $0x8,0x306(%eax)
f0103c19:	08 00 
f0103c1b:	c6 80 08 03 00 00 00 	movb   $0x0,0x308(%eax)
f0103c22:	c6 80 09 03 00 00 8f 	movb   $0x8f,0x309(%eax)
f0103c29:	c1 ea 10             	shr    $0x10,%edx
f0103c2c:	66 89 90 0a 03 00 00 	mov    %dx,0x30a(%eax)
    SETGATE(idt[T_SYSCALL], 0, GD_KT, traphandler48, 0);
f0103c33:	c7 c2 c6 40 10 f0    	mov    $0xf01040c6,%edx
f0103c39:	66 89 90 ec 03 00 00 	mov    %dx,0x3ec(%eax)
f0103c40:	66 c7 80 ee 03 00 00 	movw   $0x8,0x3ee(%eax)
f0103c47:	08 00 
f0103c49:	c6 80 f0 03 00 00 00 	movb   $0x0,0x3f0(%eax)
f0103c50:	c6 80 f1 03 00 00 8e 	movb   $0x8e,0x3f1(%eax)
f0103c57:	c1 ea 10             	shr    $0x10,%edx
f0103c5a:	66 89 90 f2 03 00 00 	mov    %dx,0x3f2(%eax)
    SETGATE(idt[T_DEFAULT], 0, GD_KT, traphandler500, 0);
f0103c61:	c7 c2 cc 40 10 f0    	mov    $0xf01040cc,%edx
f0103c67:	66 89 90 0c 12 00 00 	mov    %dx,0x120c(%eax)
f0103c6e:	66 c7 80 0e 12 00 00 	movw   $0x8,0x120e(%eax)
f0103c75:	08 00 
f0103c77:	c6 80 10 12 00 00 00 	movb   $0x0,0x1210(%eax)
f0103c7e:	c6 80 11 12 00 00 8e 	movb   $0x8e,0x1211(%eax)
f0103c85:	c1 ea 10             	shr    $0x10,%edx
f0103c88:	66 89 90 12 12 00 00 	mov    %dx,0x1212(%eax)
	trap_init_percpu();
f0103c8f:	e8 b7 fb ff ff       	call   f010384b <trap_init_percpu>
}
f0103c94:	5d                   	pop    %ebp
f0103c95:	c3                   	ret    

f0103c96 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103c96:	55                   	push   %ebp
f0103c97:	89 e5                	mov    %esp,%ebp
f0103c99:	56                   	push   %esi
f0103c9a:	53                   	push   %ebx
f0103c9b:	e8 39 c5 ff ff       	call   f01001d9 <__x86.get_pc_thunk.bx>
f0103ca0:	81 c3 54 b4 08 00    	add    $0x8b454,%ebx
f0103ca6:	8b 75 08             	mov    0x8(%ebp),%esi
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103ca9:	83 ec 08             	sub    $0x8,%esp
f0103cac:	ff 36                	pushl  (%esi)
f0103cae:	8d 83 12 71 f7 ff    	lea    -0x88eee(%ebx),%eax
f0103cb4:	50                   	push   %eax
f0103cb5:	e8 7d fb ff ff       	call   f0103837 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103cba:	83 c4 08             	add    $0x8,%esp
f0103cbd:	ff 76 04             	pushl  0x4(%esi)
f0103cc0:	8d 83 21 71 f7 ff    	lea    -0x88edf(%ebx),%eax
f0103cc6:	50                   	push   %eax
f0103cc7:	e8 6b fb ff ff       	call   f0103837 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103ccc:	83 c4 08             	add    $0x8,%esp
f0103ccf:	ff 76 08             	pushl  0x8(%esi)
f0103cd2:	8d 83 30 71 f7 ff    	lea    -0x88ed0(%ebx),%eax
f0103cd8:	50                   	push   %eax
f0103cd9:	e8 59 fb ff ff       	call   f0103837 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103cde:	83 c4 08             	add    $0x8,%esp
f0103ce1:	ff 76 0c             	pushl  0xc(%esi)
f0103ce4:	8d 83 3f 71 f7 ff    	lea    -0x88ec1(%ebx),%eax
f0103cea:	50                   	push   %eax
f0103ceb:	e8 47 fb ff ff       	call   f0103837 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103cf0:	83 c4 08             	add    $0x8,%esp
f0103cf3:	ff 76 10             	pushl  0x10(%esi)
f0103cf6:	8d 83 4e 71 f7 ff    	lea    -0x88eb2(%ebx),%eax
f0103cfc:	50                   	push   %eax
f0103cfd:	e8 35 fb ff ff       	call   f0103837 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103d02:	83 c4 08             	add    $0x8,%esp
f0103d05:	ff 76 14             	pushl  0x14(%esi)
f0103d08:	8d 83 5d 71 f7 ff    	lea    -0x88ea3(%ebx),%eax
f0103d0e:	50                   	push   %eax
f0103d0f:	e8 23 fb ff ff       	call   f0103837 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103d14:	83 c4 08             	add    $0x8,%esp
f0103d17:	ff 76 18             	pushl  0x18(%esi)
f0103d1a:	8d 83 6c 71 f7 ff    	lea    -0x88e94(%ebx),%eax
f0103d20:	50                   	push   %eax
f0103d21:	e8 11 fb ff ff       	call   f0103837 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103d26:	83 c4 08             	add    $0x8,%esp
f0103d29:	ff 76 1c             	pushl  0x1c(%esi)
f0103d2c:	8d 83 7b 71 f7 ff    	lea    -0x88e85(%ebx),%eax
f0103d32:	50                   	push   %eax
f0103d33:	e8 ff fa ff ff       	call   f0103837 <cprintf>
}
f0103d38:	83 c4 10             	add    $0x10,%esp
f0103d3b:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103d3e:	5b                   	pop    %ebx
f0103d3f:	5e                   	pop    %esi
f0103d40:	5d                   	pop    %ebp
f0103d41:	c3                   	ret    

f0103d42 <print_trapframe>:
{
f0103d42:	55                   	push   %ebp
f0103d43:	89 e5                	mov    %esp,%ebp
f0103d45:	57                   	push   %edi
f0103d46:	56                   	push   %esi
f0103d47:	53                   	push   %ebx
f0103d48:	83 ec 14             	sub    $0x14,%esp
f0103d4b:	e8 89 c4 ff ff       	call   f01001d9 <__x86.get_pc_thunk.bx>
f0103d50:	81 c3 a4 b3 08 00    	add    $0x8b3a4,%ebx
f0103d56:	8b 75 08             	mov    0x8(%ebp),%esi
	cprintf("TRAP frame at %p\n", tf);
f0103d59:	56                   	push   %esi
f0103d5a:	8d 83 b1 72 f7 ff    	lea    -0x88d4f(%ebx),%eax
f0103d60:	50                   	push   %eax
f0103d61:	e8 d1 fa ff ff       	call   f0103837 <cprintf>
	print_regs(&tf->tf_regs);
f0103d66:	89 34 24             	mov    %esi,(%esp)
f0103d69:	e8 28 ff ff ff       	call   f0103c96 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103d6e:	83 c4 08             	add    $0x8,%esp
f0103d71:	0f b7 46 20          	movzwl 0x20(%esi),%eax
f0103d75:	50                   	push   %eax
f0103d76:	8d 83 cc 71 f7 ff    	lea    -0x88e34(%ebx),%eax
f0103d7c:	50                   	push   %eax
f0103d7d:	e8 b5 fa ff ff       	call   f0103837 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103d82:	83 c4 08             	add    $0x8,%esp
f0103d85:	0f b7 46 24          	movzwl 0x24(%esi),%eax
f0103d89:	50                   	push   %eax
f0103d8a:	8d 83 df 71 f7 ff    	lea    -0x88e21(%ebx),%eax
f0103d90:	50                   	push   %eax
f0103d91:	e8 a1 fa ff ff       	call   f0103837 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103d96:	8b 56 28             	mov    0x28(%esi),%edx
	if (trapno < ARRAY_SIZE(excnames))
f0103d99:	83 c4 10             	add    $0x10,%esp
f0103d9c:	83 fa 13             	cmp    $0x13,%edx
f0103d9f:	0f 86 e9 00 00 00    	jbe    f0103e8e <print_trapframe+0x14c>
		return "System call";
f0103da5:	83 fa 30             	cmp    $0x30,%edx
f0103da8:	8d 83 8a 71 f7 ff    	lea    -0x88e76(%ebx),%eax
f0103dae:	8d 8b 99 71 f7 ff    	lea    -0x88e67(%ebx),%ecx
f0103db4:	0f 44 c1             	cmove  %ecx,%eax
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103db7:	83 ec 04             	sub    $0x4,%esp
f0103dba:	50                   	push   %eax
f0103dbb:	52                   	push   %edx
f0103dbc:	8d 83 f2 71 f7 ff    	lea    -0x88e0e(%ebx),%eax
f0103dc2:	50                   	push   %eax
f0103dc3:	e8 6f fa ff ff       	call   f0103837 <cprintf>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103dc8:	83 c4 10             	add    $0x10,%esp
f0103dcb:	39 b3 6c 0a 00 00    	cmp    %esi,0xa6c(%ebx)
f0103dd1:	0f 84 c3 00 00 00    	je     f0103e9a <print_trapframe+0x158>
	cprintf("  err  0x%08x", tf->tf_err);
f0103dd7:	83 ec 08             	sub    $0x8,%esp
f0103dda:	ff 76 2c             	pushl  0x2c(%esi)
f0103ddd:	8d 83 13 72 f7 ff    	lea    -0x88ded(%ebx),%eax
f0103de3:	50                   	push   %eax
f0103de4:	e8 4e fa ff ff       	call   f0103837 <cprintf>
	if (tf->tf_trapno == T_PGFLT)
f0103de9:	83 c4 10             	add    $0x10,%esp
f0103dec:	83 7e 28 0e          	cmpl   $0xe,0x28(%esi)
f0103df0:	0f 85 c9 00 00 00    	jne    f0103ebf <print_trapframe+0x17d>
			tf->tf_err & 1 ? "protection" : "not-present");
f0103df6:	8b 46 2c             	mov    0x2c(%esi),%eax
		cprintf(" [%s, %s, %s]\n",
f0103df9:	89 c2                	mov    %eax,%edx
f0103dfb:	83 e2 01             	and    $0x1,%edx
f0103dfe:	8d 8b a5 71 f7 ff    	lea    -0x88e5b(%ebx),%ecx
f0103e04:	8d 93 b0 71 f7 ff    	lea    -0x88e50(%ebx),%edx
f0103e0a:	0f 44 ca             	cmove  %edx,%ecx
f0103e0d:	89 c2                	mov    %eax,%edx
f0103e0f:	83 e2 02             	and    $0x2,%edx
f0103e12:	8d 93 bc 71 f7 ff    	lea    -0x88e44(%ebx),%edx
f0103e18:	8d bb c2 71 f7 ff    	lea    -0x88e3e(%ebx),%edi
f0103e1e:	0f 44 d7             	cmove  %edi,%edx
f0103e21:	83 e0 04             	and    $0x4,%eax
f0103e24:	8d 83 c7 71 f7 ff    	lea    -0x88e39(%ebx),%eax
f0103e2a:	8d bb dc 72 f7 ff    	lea    -0x88d24(%ebx),%edi
f0103e30:	0f 44 c7             	cmove  %edi,%eax
f0103e33:	51                   	push   %ecx
f0103e34:	52                   	push   %edx
f0103e35:	50                   	push   %eax
f0103e36:	8d 83 21 72 f7 ff    	lea    -0x88ddf(%ebx),%eax
f0103e3c:	50                   	push   %eax
f0103e3d:	e8 f5 f9 ff ff       	call   f0103837 <cprintf>
f0103e42:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103e45:	83 ec 08             	sub    $0x8,%esp
f0103e48:	ff 76 30             	pushl  0x30(%esi)
f0103e4b:	8d 83 30 72 f7 ff    	lea    -0x88dd0(%ebx),%eax
f0103e51:	50                   	push   %eax
f0103e52:	e8 e0 f9 ff ff       	call   f0103837 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103e57:	83 c4 08             	add    $0x8,%esp
f0103e5a:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0103e5e:	50                   	push   %eax
f0103e5f:	8d 83 3f 72 f7 ff    	lea    -0x88dc1(%ebx),%eax
f0103e65:	50                   	push   %eax
f0103e66:	e8 cc f9 ff ff       	call   f0103837 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103e6b:	83 c4 08             	add    $0x8,%esp
f0103e6e:	ff 76 38             	pushl  0x38(%esi)
f0103e71:	8d 83 52 72 f7 ff    	lea    -0x88dae(%ebx),%eax
f0103e77:	50                   	push   %eax
f0103e78:	e8 ba f9 ff ff       	call   f0103837 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0103e7d:	83 c4 10             	add    $0x10,%esp
f0103e80:	f6 46 34 03          	testb  $0x3,0x34(%esi)
f0103e84:	75 50                	jne    f0103ed6 <print_trapframe+0x194>
}
f0103e86:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103e89:	5b                   	pop    %ebx
f0103e8a:	5e                   	pop    %esi
f0103e8b:	5f                   	pop    %edi
f0103e8c:	5d                   	pop    %ebp
f0103e8d:	c3                   	ret    
		return excnames[trapno];
f0103e8e:	8b 84 93 8c ff ff ff 	mov    -0x74(%ebx,%edx,4),%eax
f0103e95:	e9 1d ff ff ff       	jmp    f0103db7 <print_trapframe+0x75>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103e9a:	83 7e 28 0e          	cmpl   $0xe,0x28(%esi)
f0103e9e:	0f 85 33 ff ff ff    	jne    f0103dd7 <print_trapframe+0x95>
	asm volatile("movl %%cr2,%0" : "=r" (val));
f0103ea4:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0103ea7:	83 ec 08             	sub    $0x8,%esp
f0103eaa:	50                   	push   %eax
f0103eab:	8d 83 04 72 f7 ff    	lea    -0x88dfc(%ebx),%eax
f0103eb1:	50                   	push   %eax
f0103eb2:	e8 80 f9 ff ff       	call   f0103837 <cprintf>
f0103eb7:	83 c4 10             	add    $0x10,%esp
f0103eba:	e9 18 ff ff ff       	jmp    f0103dd7 <print_trapframe+0x95>
		cprintf("\n");
f0103ebf:	83 ec 0c             	sub    $0xc,%esp
f0103ec2:	8d 83 f6 6f f7 ff    	lea    -0x8900a(%ebx),%eax
f0103ec8:	50                   	push   %eax
f0103ec9:	e8 69 f9 ff ff       	call   f0103837 <cprintf>
f0103ece:	83 c4 10             	add    $0x10,%esp
f0103ed1:	e9 6f ff ff ff       	jmp    f0103e45 <print_trapframe+0x103>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0103ed6:	83 ec 08             	sub    $0x8,%esp
f0103ed9:	ff 76 3c             	pushl  0x3c(%esi)
f0103edc:	8d 83 61 72 f7 ff    	lea    -0x88d9f(%ebx),%eax
f0103ee2:	50                   	push   %eax
f0103ee3:	e8 4f f9 ff ff       	call   f0103837 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0103ee8:	83 c4 08             	add    $0x8,%esp
f0103eeb:	0f b7 46 40          	movzwl 0x40(%esi),%eax
f0103eef:	50                   	push   %eax
f0103ef0:	8d 83 70 72 f7 ff    	lea    -0x88d90(%ebx),%eax
f0103ef6:	50                   	push   %eax
f0103ef7:	e8 3b f9 ff ff       	call   f0103837 <cprintf>
f0103efc:	83 c4 10             	add    $0x10,%esp
}
f0103eff:	eb 85                	jmp    f0103e86 <print_trapframe+0x144>

f0103f01 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0103f01:	55                   	push   %ebp
f0103f02:	89 e5                	mov    %esp,%ebp
f0103f04:	57                   	push   %edi
f0103f05:	56                   	push   %esi
f0103f06:	53                   	push   %ebx
f0103f07:	83 ec 0c             	sub    $0xc,%esp
f0103f0a:	e8 ca c2 ff ff       	call   f01001d9 <__x86.get_pc_thunk.bx>
f0103f0f:	81 c3 e5 b1 08 00    	add    $0x8b1e5,%ebx
f0103f15:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0103f18:	fc                   	cld    
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f0103f19:	9c                   	pushf  
f0103f1a:	58                   	pop    %eax

	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0103f1b:	f6 c4 02             	test   $0x2,%ah
f0103f1e:	74 1f                	je     f0103f3f <trap+0x3e>
f0103f20:	8d 83 83 72 f7 ff    	lea    -0x88d7d(%ebx),%eax
f0103f26:	50                   	push   %eax
f0103f27:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f0103f2d:	50                   	push   %eax
f0103f2e:	68 d9 00 00 00       	push   $0xd9
f0103f33:	8d 83 9c 72 f7 ff    	lea    -0x88d64(%ebx),%eax
f0103f39:	50                   	push   %eax
f0103f3a:	e8 e4 c1 ff ff       	call   f0100123 <_panic>

	cprintf("Incoming TRAP frame at %p\n", tf);
f0103f3f:	83 ec 08             	sub    $0x8,%esp
f0103f42:	56                   	push   %esi
f0103f43:	8d 83 a8 72 f7 ff    	lea    -0x88d58(%ebx),%eax
f0103f49:	50                   	push   %eax
f0103f4a:	e8 e8 f8 ff ff       	call   f0103837 <cprintf>

	if ((tf->tf_cs & 3) == 3) {
f0103f4f:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0103f53:	83 e0 03             	and    $0x3,%eax
f0103f56:	83 c4 10             	add    $0x10,%esp
f0103f59:	66 83 f8 03          	cmp    $0x3,%ax
f0103f5d:	75 1d                	jne    f0103f7c <trap+0x7b>
		// Trapped from user mode.
		assert(curenv);
f0103f5f:	c7 c0 44 f3 18 f0    	mov    $0xf018f344,%eax
f0103f65:	8b 00                	mov    (%eax),%eax
f0103f67:	85 c0                	test   %eax,%eax
f0103f69:	74 68                	je     f0103fd3 <trap+0xd2>

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f0103f6b:	b9 11 00 00 00       	mov    $0x11,%ecx
f0103f70:	89 c7                	mov    %eax,%edi
f0103f72:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0103f74:	c7 c0 44 f3 18 f0    	mov    $0xf018f344,%eax
f0103f7a:	8b 30                	mov    (%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0103f7c:	89 b3 6c 0a 00 00    	mov    %esi,0xa6c(%ebx)
	print_trapframe(tf);
f0103f82:	83 ec 0c             	sub    $0xc,%esp
f0103f85:	56                   	push   %esi
f0103f86:	e8 b7 fd ff ff       	call   f0103d42 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0103f8b:	83 c4 10             	add    $0x10,%esp
f0103f8e:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0103f93:	74 5d                	je     f0103ff2 <trap+0xf1>
		env_destroy(curenv);
f0103f95:	83 ec 0c             	sub    $0xc,%esp
f0103f98:	c7 c6 44 f3 18 f0    	mov    $0xf018f344,%esi
f0103f9e:	ff 36                	pushl  (%esi)
f0103fa0:	e8 28 f7 ff ff       	call   f01036cd <env_destroy>

	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);

	// Return to the current environment, which should be running.
	assert(curenv && curenv->env_status == ENV_RUNNING);
f0103fa5:	8b 06                	mov    (%esi),%eax
f0103fa7:	83 c4 10             	add    $0x10,%esp
f0103faa:	85 c0                	test   %eax,%eax
f0103fac:	74 06                	je     f0103fb4 <trap+0xb3>
f0103fae:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103fb2:	74 59                	je     f010400d <trap+0x10c>
f0103fb4:	8d 83 28 74 f7 ff    	lea    -0x88bd8(%ebx),%eax
f0103fba:	50                   	push   %eax
f0103fbb:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f0103fc1:	50                   	push   %eax
f0103fc2:	68 f1 00 00 00       	push   $0xf1
f0103fc7:	8d 83 9c 72 f7 ff    	lea    -0x88d64(%ebx),%eax
f0103fcd:	50                   	push   %eax
f0103fce:	e8 50 c1 ff ff       	call   f0100123 <_panic>
		assert(curenv);
f0103fd3:	8d 83 c3 72 f7 ff    	lea    -0x88d3d(%ebx),%eax
f0103fd9:	50                   	push   %eax
f0103fda:	8d 83 6b 6d f7 ff    	lea    -0x89295(%ebx),%eax
f0103fe0:	50                   	push   %eax
f0103fe1:	68 df 00 00 00       	push   $0xdf
f0103fe6:	8d 83 9c 72 f7 ff    	lea    -0x88d64(%ebx),%eax
f0103fec:	50                   	push   %eax
f0103fed:	e8 31 c1 ff ff       	call   f0100123 <_panic>
		panic("unhandled trap in kernel");
f0103ff2:	83 ec 04             	sub    $0x4,%esp
f0103ff5:	8d 83 ca 72 f7 ff    	lea    -0x88d36(%ebx),%eax
f0103ffb:	50                   	push   %eax
f0103ffc:	68 c8 00 00 00       	push   $0xc8
f0104001:	8d 83 9c 72 f7 ff    	lea    -0x88d64(%ebx),%eax
f0104007:	50                   	push   %eax
f0104008:	e8 16 c1 ff ff       	call   f0100123 <_panic>
	env_run(curenv);
f010400d:	83 ec 0c             	sub    $0xc,%esp
f0104010:	50                   	push   %eax
f0104011:	e8 25 f7 ff ff       	call   f010373b <env_run>

f0104016 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0104016:	55                   	push   %ebp
f0104017:	89 e5                	mov    %esp,%ebp
f0104019:	57                   	push   %edi
f010401a:	56                   	push   %esi
f010401b:	53                   	push   %ebx
f010401c:	83 ec 0c             	sub    $0xc,%esp
f010401f:	e8 b5 c1 ff ff       	call   f01001d9 <__x86.get_pc_thunk.bx>
f0104024:	81 c3 d0 b0 08 00    	add    $0x8b0d0,%ebx
f010402a:	8b 7d 08             	mov    0x8(%ebp),%edi
	asm volatile("movl %%cr2,%0" : "=r" (val));
f010402d:	0f 20 d0             	mov    %cr2,%eax

	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104030:	ff 77 30             	pushl  0x30(%edi)
f0104033:	50                   	push   %eax
f0104034:	c7 c6 44 f3 18 f0    	mov    $0xf018f344,%esi
f010403a:	8b 06                	mov    (%esi),%eax
f010403c:	ff 70 48             	pushl  0x48(%eax)
f010403f:	8d 83 54 74 f7 ff    	lea    -0x88bac(%ebx),%eax
f0104045:	50                   	push   %eax
f0104046:	e8 ec f7 ff ff       	call   f0103837 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f010404b:	89 3c 24             	mov    %edi,(%esp)
f010404e:	e8 ef fc ff ff       	call   f0103d42 <print_trapframe>
	env_destroy(curenv);
f0104053:	83 c4 04             	add    $0x4,%esp
f0104056:	ff 36                	pushl  (%esi)
f0104058:	e8 70 f6 ff ff       	call   f01036cd <env_destroy>
}
f010405d:	83 c4 10             	add    $0x10,%esp
f0104060:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104063:	5b                   	pop    %ebx
f0104064:	5e                   	pop    %esi
f0104065:	5f                   	pop    %edi
f0104066:	5d                   	pop    %ebp
f0104067:	c3                   	ret    

f0104068 <traphandler0>:

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */

TRAPHANDLER_NOEC(traphandler0, T_DIVIDE)
f0104068:	6a 00                	push   $0x0
f010406a:	6a 00                	push   $0x0
f010406c:	eb 67                	jmp    f01040d5 <_alltraps>

f010406e <traphandler1>:
TRAPHANDLER_NOEC(traphandler1, T_DEBUG)
f010406e:	6a 00                	push   $0x0
f0104070:	6a 01                	push   $0x1
f0104072:	eb 61                	jmp    f01040d5 <_alltraps>

f0104074 <traphandler2>:
TRAPHANDLER_NOEC(traphandler2, T_NMI)
f0104074:	6a 00                	push   $0x0
f0104076:	6a 02                	push   $0x2
f0104078:	eb 5b                	jmp    f01040d5 <_alltraps>

f010407a <traphandler3>:
TRAPHANDLER_NOEC(traphandler3, T_BRKPT)
f010407a:	6a 00                	push   $0x0
f010407c:	6a 03                	push   $0x3
f010407e:	eb 55                	jmp    f01040d5 <_alltraps>

f0104080 <traphandler4>:
TRAPHANDLER_NOEC(traphandler4, T_OFLOW)
f0104080:	6a 00                	push   $0x0
f0104082:	6a 04                	push   $0x4
f0104084:	eb 4f                	jmp    f01040d5 <_alltraps>

f0104086 <traphandler5>:
TRAPHANDLER_NOEC(traphandler5, T_BOUND)
f0104086:	6a 00                	push   $0x0
f0104088:	6a 05                	push   $0x5
f010408a:	eb 49                	jmp    f01040d5 <_alltraps>

f010408c <traphandler6>:
TRAPHANDLER_NOEC(traphandler6, T_ILLOP)
f010408c:	6a 00                	push   $0x0
f010408e:	6a 06                	push   $0x6
f0104090:	eb 43                	jmp    f01040d5 <_alltraps>

f0104092 <traphandler7>:
TRAPHANDLER_NOEC(traphandler7, T_DEVICE)
f0104092:	6a 00                	push   $0x0
f0104094:	6a 07                	push   $0x7
f0104096:	eb 3d                	jmp    f01040d5 <_alltraps>

f0104098 <traphandler8>:
TRAPHANDLER(traphandler8, T_DBLFLT)
f0104098:	6a 08                	push   $0x8
f010409a:	eb 39                	jmp    f01040d5 <_alltraps>

f010409c <traphandler10>:
// 9 deprecated since 386
TRAPHANDLER(traphandler10, T_TSS)
f010409c:	6a 0a                	push   $0xa
f010409e:	eb 35                	jmp    f01040d5 <_alltraps>

f01040a0 <traphandler11>:
TRAPHANDLER(traphandler11, T_SEGNP)
f01040a0:	6a 0b                	push   $0xb
f01040a2:	eb 31                	jmp    f01040d5 <_alltraps>

f01040a4 <traphandler12>:
TRAPHANDLER(traphandler12, T_STACK)
f01040a4:	6a 0c                	push   $0xc
f01040a6:	eb 2d                	jmp    f01040d5 <_alltraps>

f01040a8 <traphandler13>:
TRAPHANDLER(traphandler13, T_GPFLT)
f01040a8:	6a 0d                	push   $0xd
f01040aa:	eb 29                	jmp    f01040d5 <_alltraps>

f01040ac <traphandler14>:
TRAPHANDLER(traphandler14, T_PGFLT)
f01040ac:	6a 0e                	push   $0xe
f01040ae:	eb 25                	jmp    f01040d5 <_alltraps>

f01040b0 <traphandler16>:
// 15 reserved by intel
TRAPHANDLER_NOEC(traphandler16, T_FPERR)
f01040b0:	6a 00                	push   $0x0
f01040b2:	6a 10                	push   $0x10
f01040b4:	eb 1f                	jmp    f01040d5 <_alltraps>

f01040b6 <traphandler17>:
TRAPHANDLER(traphandler17, T_ALIGN)
f01040b6:	6a 11                	push   $0x11
f01040b8:	eb 1b                	jmp    f01040d5 <_alltraps>

f01040ba <traphandler18>:
TRAPHANDLER_NOEC(traphandler18, T_MCHK)
f01040ba:	6a 00                	push   $0x0
f01040bc:	6a 12                	push   $0x12
f01040be:	eb 15                	jmp    f01040d5 <_alltraps>

f01040c0 <traphandler19>:
TRAPHANDLER_NOEC(traphandler19, T_SIMDERR)
f01040c0:	6a 00                	push   $0x0
f01040c2:	6a 13                	push   $0x13
f01040c4:	eb 0f                	jmp    f01040d5 <_alltraps>

f01040c6 <traphandler48>:

// system call (interrupt)
TRAPHANDLER_NOEC(traphandler48, T_SYSCALL)
f01040c6:	6a 00                	push   $0x0
f01040c8:	6a 30                	push   $0x30
f01040ca:	eb 09                	jmp    f01040d5 <_alltraps>

f01040cc <traphandler500>:
TRAPHANDLER_NOEC(traphandler500, T_DEFAULT)	
f01040cc:	6a 00                	push   $0x0
f01040ce:	68 f4 01 00 00       	push   $0x1f4
f01040d3:	eb 00                	jmp    f01040d5 <_alltraps>

f01040d5 <_alltraps>:

/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
	pushl %ds	
f01040d5:	1e                   	push   %ds
	pushl %es	
f01040d6:	06                   	push   %es
	pushal
f01040d7:	60                   	pusha  
	
	movw $GD_KD, %ax
f01040d8:	66 b8 10 00          	mov    $0x10,%ax
	movw %ax, %ds
f01040dc:	8e d8                	mov    %eax,%ds
	movw %ax, %es
f01040de:	8e c0                	mov    %eax,%es
	pushl %esp
f01040e0:	54                   	push   %esp
	call trap
f01040e1:	e8 1b fe ff ff       	call   f0103f01 <trap>

f01040e6 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f01040e6:	55                   	push   %ebp
f01040e7:	89 e5                	mov    %esp,%ebp
f01040e9:	53                   	push   %ebx
f01040ea:	83 ec 08             	sub    $0x8,%esp
f01040ed:	e8 e7 c0 ff ff       	call   f01001d9 <__x86.get_pc_thunk.bx>
f01040f2:	81 c3 02 b0 08 00    	add    $0x8b002,%ebx
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.

	panic("syscall not implemented");
f01040f8:	8d 83 78 74 f7 ff    	lea    -0x88b88(%ebx),%eax
f01040fe:	50                   	push   %eax
f01040ff:	6a 49                	push   $0x49
f0104101:	8d 83 90 74 f7 ff    	lea    -0x88b70(%ebx),%eax
f0104107:	50                   	push   %eax
f0104108:	e8 16 c0 ff ff       	call   f0100123 <_panic>

f010410d <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f010410d:	55                   	push   %ebp
f010410e:	89 e5                	mov    %esp,%ebp
f0104110:	57                   	push   %edi
f0104111:	56                   	push   %esi
f0104112:	53                   	push   %ebx
f0104113:	83 ec 14             	sub    $0x14,%esp
f0104116:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104119:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f010411c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f010411f:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0104122:	8b 1a                	mov    (%edx),%ebx
f0104124:	8b 01                	mov    (%ecx),%eax
f0104126:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104129:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0104130:	eb 23                	jmp    f0104155 <stab_binsearch+0x48>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0104132:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0104135:	eb 1e                	jmp    f0104155 <stab_binsearch+0x48>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0104137:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010413a:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010413d:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0104141:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0104144:	73 41                	jae    f0104187 <stab_binsearch+0x7a>
			*region_left = m;
f0104146:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104149:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f010414b:	8d 5f 01             	lea    0x1(%edi),%ebx
		any_matches = 1;
f010414e:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0104155:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0104158:	7f 5a                	jg     f01041b4 <stab_binsearch+0xa7>
		int true_m = (l + r) / 2, m = true_m;
f010415a:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010415d:	01 d8                	add    %ebx,%eax
f010415f:	89 c7                	mov    %eax,%edi
f0104161:	c1 ef 1f             	shr    $0x1f,%edi
f0104164:	01 c7                	add    %eax,%edi
f0104166:	d1 ff                	sar    %edi
f0104168:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f010416b:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010416e:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0104172:	89 f8                	mov    %edi,%eax
		while (m >= l && stabs[m].n_type != type)
f0104174:	39 c3                	cmp    %eax,%ebx
f0104176:	7f ba                	jg     f0104132 <stab_binsearch+0x25>
f0104178:	0f b6 0a             	movzbl (%edx),%ecx
f010417b:	83 ea 0c             	sub    $0xc,%edx
f010417e:	39 f1                	cmp    %esi,%ecx
f0104180:	74 b5                	je     f0104137 <stab_binsearch+0x2a>
			m--;
f0104182:	83 e8 01             	sub    $0x1,%eax
f0104185:	eb ed                	jmp    f0104174 <stab_binsearch+0x67>
		} else if (stabs[m].n_value > addr) {
f0104187:	3b 55 0c             	cmp    0xc(%ebp),%edx
f010418a:	76 14                	jbe    f01041a0 <stab_binsearch+0x93>
			*region_right = m - 1;
f010418c:	83 e8 01             	sub    $0x1,%eax
f010418f:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104192:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0104195:	89 07                	mov    %eax,(%edi)
		any_matches = 1;
f0104197:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f010419e:	eb b5                	jmp    f0104155 <stab_binsearch+0x48>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f01041a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01041a3:	89 07                	mov    %eax,(%edi)
			l = m;
			addr++;
f01041a5:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f01041a9:	89 c3                	mov    %eax,%ebx
		any_matches = 1;
f01041ab:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01041b2:	eb a1                	jmp    f0104155 <stab_binsearch+0x48>
		}
	}

	if (!any_matches)
f01041b4:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f01041b8:	75 15                	jne    f01041cf <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f01041ba:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01041bd:	8b 00                	mov    (%eax),%eax
f01041bf:	83 e8 01             	sub    $0x1,%eax
f01041c2:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01041c5:	89 06                	mov    %eax,(%esi)
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f01041c7:	83 c4 14             	add    $0x14,%esp
f01041ca:	5b                   	pop    %ebx
f01041cb:	5e                   	pop    %esi
f01041cc:	5f                   	pop    %edi
f01041cd:	5d                   	pop    %ebp
f01041ce:	c3                   	ret    
		for (l = *region_right;
f01041cf:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01041d2:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f01041d4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01041d7:	8b 0f                	mov    (%edi),%ecx
f01041d9:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01041dc:	8b 7d ec             	mov    -0x14(%ebp),%edi
f01041df:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
		for (l = *region_right;
f01041e3:	eb 03                	jmp    f01041e8 <stab_binsearch+0xdb>
		     l--)
f01041e5:	83 e8 01             	sub    $0x1,%eax
		for (l = *region_right;
f01041e8:	39 c1                	cmp    %eax,%ecx
f01041ea:	7d 0a                	jge    f01041f6 <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f01041ec:	0f b6 1a             	movzbl (%edx),%ebx
f01041ef:	83 ea 0c             	sub    $0xc,%edx
f01041f2:	39 f3                	cmp    %esi,%ebx
f01041f4:	75 ef                	jne    f01041e5 <stab_binsearch+0xd8>
		*region_left = l;
f01041f6:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01041f9:	89 06                	mov    %eax,(%esi)
}
f01041fb:	eb ca                	jmp    f01041c7 <stab_binsearch+0xba>

f01041fd <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01041fd:	55                   	push   %ebp
f01041fe:	89 e5                	mov    %esp,%ebp
f0104200:	57                   	push   %edi
f0104201:	56                   	push   %esi
f0104202:	53                   	push   %ebx
f0104203:	83 ec 4c             	sub    $0x4c,%esp
f0104206:	e8 ce bf ff ff       	call   f01001d9 <__x86.get_pc_thunk.bx>
f010420b:	81 c3 e9 ae 08 00    	add    $0x8aee9,%ebx
f0104211:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0104214:	8d 83 9f 74 f7 ff    	lea    -0x88b61(%ebx),%eax
f010421a:	89 06                	mov    %eax,(%esi)
	info->eip_line = 0;
f010421c:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f0104223:	89 46 08             	mov    %eax,0x8(%esi)
	info->eip_fn_namelen = 9;
f0104226:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f010422d:	8b 45 08             	mov    0x8(%ebp),%eax
f0104230:	89 46 10             	mov    %eax,0x10(%esi)
	info->eip_fn_narg = 0;
f0104233:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f010423a:	3d ff ff 7f ef       	cmp    $0xef7fffff,%eax
f010423f:	0f 87 20 01 00 00    	ja     f0104365 <debuginfo_eip+0x168>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f0104245:	a1 00 00 20 00       	mov    0x200000,%eax
f010424a:	89 45 b8             	mov    %eax,-0x48(%ebp)
		stab_end = usd->stab_end;
f010424d:	a1 04 00 20 00       	mov    0x200004,%eax
		stabstr = usd->stabstr;
f0104252:	8b 3d 08 00 20 00    	mov    0x200008,%edi
f0104258:	89 7d b4             	mov    %edi,-0x4c(%ebp)
		stabstr_end = usd->stabstr_end;
f010425b:	8b 3d 0c 00 20 00    	mov    0x20000c,%edi
f0104261:	89 7d bc             	mov    %edi,-0x44(%ebp)
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0104264:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0104267:	39 7d b4             	cmp    %edi,-0x4c(%ebp)
f010426a:	0f 83 c8 01 00 00    	jae    f0104438 <debuginfo_eip+0x23b>
f0104270:	80 7f ff 00          	cmpb   $0x0,-0x1(%edi)
f0104274:	0f 85 c5 01 00 00    	jne    f010443f <debuginfo_eip+0x242>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f010427a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0104281:	8b 7d b8             	mov    -0x48(%ebp),%edi
f0104284:	29 f8                	sub    %edi,%eax
f0104286:	c1 f8 02             	sar    $0x2,%eax
f0104289:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f010428f:	83 e8 01             	sub    $0x1,%eax
f0104292:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0104295:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0104298:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f010429b:	ff 75 08             	pushl  0x8(%ebp)
f010429e:	6a 64                	push   $0x64
f01042a0:	89 f8                	mov    %edi,%eax
f01042a2:	e8 66 fe ff ff       	call   f010410d <stab_binsearch>
	if (lfile == 0)
f01042a7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01042aa:	83 c4 08             	add    $0x8,%esp
f01042ad:	85 c0                	test   %eax,%eax
f01042af:	0f 84 91 01 00 00    	je     f0104446 <debuginfo_eip+0x249>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f01042b5:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f01042b8:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01042bb:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f01042be:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f01042c1:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01042c4:	ff 75 08             	pushl  0x8(%ebp)
f01042c7:	6a 24                	push   $0x24
f01042c9:	89 f8                	mov    %edi,%eax
f01042cb:	e8 3d fe ff ff       	call   f010410d <stab_binsearch>

	if (lfun <= rfun) {
f01042d0:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01042d3:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01042d6:	83 c4 08             	add    $0x8,%esp
f01042d9:	39 d0                	cmp    %edx,%eax
f01042db:	0f 8f aa 00 00 00    	jg     f010438b <debuginfo_eip+0x18e>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f01042e1:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f01042e4:	8d 0c 8f             	lea    (%edi,%ecx,4),%ecx
f01042e7:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
f01042ea:	8b 09                	mov    (%ecx),%ecx
f01042ec:	8b 7d bc             	mov    -0x44(%ebp),%edi
f01042ef:	2b 7d b4             	sub    -0x4c(%ebp),%edi
f01042f2:	39 f9                	cmp    %edi,%ecx
f01042f4:	73 06                	jae    f01042fc <debuginfo_eip+0xff>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f01042f6:	03 4d b4             	add    -0x4c(%ebp),%ecx
f01042f9:	89 4e 08             	mov    %ecx,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f01042fc:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f01042ff:	8b 4f 08             	mov    0x8(%edi),%ecx
f0104302:	89 4e 10             	mov    %ecx,0x10(%esi)
		addr -= info->eip_fn_addr;
f0104305:	29 4d 08             	sub    %ecx,0x8(%ebp)
		// Search within the function definition for the line number.
		lline = lfun;
f0104308:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f010430b:	89 55 d0             	mov    %edx,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f010430e:	83 ec 08             	sub    $0x8,%esp
f0104311:	6a 3a                	push   $0x3a
f0104313:	ff 76 08             	pushl  0x8(%esi)
f0104316:	e8 bc 09 00 00       	call   f0104cd7 <strfind>
f010431b:	2b 46 08             	sub    0x8(%esi),%eax
f010431e:	89 46 0c             	mov    %eax,0xc(%esi)
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0104321:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0104324:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0104327:	83 c4 08             	add    $0x8,%esp
f010432a:	ff 75 08             	pushl  0x8(%ebp)
f010432d:	6a 44                	push   $0x44
f010432f:	8b 5d b8             	mov    -0x48(%ebp),%ebx
f0104332:	89 d8                	mov    %ebx,%eax
f0104334:	e8 d4 fd ff ff       	call   f010410d <stab_binsearch>
	if (lline <= rline) {
f0104339:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f010433c:	83 c4 10             	add    $0x10,%esp
f010433f:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f0104342:	0f 8f 05 01 00 00    	jg     f010444d <debuginfo_eip+0x250>
		 info->eip_line = stabs[lline].n_desc;
f0104348:	89 d0                	mov    %edx,%eax
f010434a:	8d 14 52             	lea    (%edx,%edx,2),%edx
f010434d:	c1 e2 02             	shl    $0x2,%edx
f0104350:	0f b7 4c 13 06       	movzwl 0x6(%ebx,%edx,1),%ecx
f0104355:	89 4e 04             	mov    %ecx,0x4(%esi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104358:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010435b:	8d 54 13 04          	lea    0x4(%ebx,%edx,1),%edx
f010435f:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f0104363:	eb 47                	jmp    f01043ac <debuginfo_eip+0x1af>
		stabstr_end = __STABSTR_END__;
f0104365:	c7 c0 27 27 11 f0    	mov    $0xf0112727,%eax
f010436b:	89 45 bc             	mov    %eax,-0x44(%ebp)
		stabstr = __STABSTR_BEGIN__;
f010436e:	c7 c0 35 fc 10 f0    	mov    $0xf010fc35,%eax
f0104374:	89 45 b4             	mov    %eax,-0x4c(%ebp)
		stab_end = __STAB_END__;
f0104377:	c7 c0 34 fc 10 f0    	mov    $0xf010fc34,%eax
		stabs = __STAB_BEGIN__;
f010437d:	c7 c7 90 67 10 f0    	mov    $0xf0106790,%edi
f0104383:	89 7d b8             	mov    %edi,-0x48(%ebp)
f0104386:	e9 d9 fe ff ff       	jmp    f0104264 <debuginfo_eip+0x67>
		info->eip_fn_addr = addr;
f010438b:	8b 45 08             	mov    0x8(%ebp),%eax
f010438e:	89 46 10             	mov    %eax,0x10(%esi)
		lline = lfile;
f0104391:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104394:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0104397:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010439a:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010439d:	e9 6c ff ff ff       	jmp    f010430e <debuginfo_eip+0x111>
f01043a2:	83 e8 01             	sub    $0x1,%eax
f01043a5:	83 ea 0c             	sub    $0xc,%edx
f01043a8:	c6 45 c4 01          	movb   $0x1,-0x3c(%ebp)
f01043ac:	89 45 c0             	mov    %eax,-0x40(%ebp)
	while (lline >= lfile
f01043af:	39 c7                	cmp    %eax,%edi
f01043b1:	7f 45                	jg     f01043f8 <debuginfo_eip+0x1fb>
	       && stabs[lline].n_type != N_SOL
f01043b3:	0f b6 0a             	movzbl (%edx),%ecx
f01043b6:	80 f9 84             	cmp    $0x84,%cl
f01043b9:	74 19                	je     f01043d4 <debuginfo_eip+0x1d7>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01043bb:	80 f9 64             	cmp    $0x64,%cl
f01043be:	75 e2                	jne    f01043a2 <debuginfo_eip+0x1a5>
f01043c0:	83 7a 04 00          	cmpl   $0x0,0x4(%edx)
f01043c4:	74 dc                	je     f01043a2 <debuginfo_eip+0x1a5>
f01043c6:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f01043ca:	74 11                	je     f01043dd <debuginfo_eip+0x1e0>
f01043cc:	8b 7d c0             	mov    -0x40(%ebp),%edi
f01043cf:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f01043d2:	eb 09                	jmp    f01043dd <debuginfo_eip+0x1e0>
f01043d4:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f01043d8:	74 03                	je     f01043dd <debuginfo_eip+0x1e0>
f01043da:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f01043dd:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01043e0:	8b 7d b8             	mov    -0x48(%ebp),%edi
f01043e3:	8b 14 87             	mov    (%edi,%eax,4),%edx
f01043e6:	8b 45 bc             	mov    -0x44(%ebp),%eax
f01043e9:	8b 7d b4             	mov    -0x4c(%ebp),%edi
f01043ec:	29 f8                	sub    %edi,%eax
f01043ee:	39 c2                	cmp    %eax,%edx
f01043f0:	73 06                	jae    f01043f8 <debuginfo_eip+0x1fb>
		info->eip_file = stabstr + stabs[lline].n_strx;
f01043f2:	89 f8                	mov    %edi,%eax
f01043f4:	01 d0                	add    %edx,%eax
f01043f6:	89 06                	mov    %eax,(%esi)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01043f8:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01043fb:	8b 5d d8             	mov    -0x28(%ebp),%ebx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01043fe:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f0104403:	39 da                	cmp    %ebx,%edx
f0104405:	7d 52                	jge    f0104459 <debuginfo_eip+0x25c>
		for (lline = lfun + 1;
f0104407:	83 c2 01             	add    $0x1,%edx
f010440a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f010440d:	89 d0                	mov    %edx,%eax
f010440f:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0104412:	8b 7d b8             	mov    -0x48(%ebp),%edi
f0104415:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
f0104419:	eb 04                	jmp    f010441f <debuginfo_eip+0x222>
			info->eip_fn_narg++;
f010441b:	83 46 14 01          	addl   $0x1,0x14(%esi)
		for (lline = lfun + 1;
f010441f:	39 c3                	cmp    %eax,%ebx
f0104421:	7e 31                	jle    f0104454 <debuginfo_eip+0x257>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0104423:	0f b6 0a             	movzbl (%edx),%ecx
f0104426:	83 c0 01             	add    $0x1,%eax
f0104429:	83 c2 0c             	add    $0xc,%edx
f010442c:	80 f9 a0             	cmp    $0xa0,%cl
f010442f:	74 ea                	je     f010441b <debuginfo_eip+0x21e>
	return 0;
f0104431:	b8 00 00 00 00       	mov    $0x0,%eax
f0104436:	eb 21                	jmp    f0104459 <debuginfo_eip+0x25c>
		return -1;
f0104438:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010443d:	eb 1a                	jmp    f0104459 <debuginfo_eip+0x25c>
f010443f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104444:	eb 13                	jmp    f0104459 <debuginfo_eip+0x25c>
		return -1;
f0104446:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010444b:	eb 0c                	jmp    f0104459 <debuginfo_eip+0x25c>
		 return -1;
f010444d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104452:	eb 05                	jmp    f0104459 <debuginfo_eip+0x25c>
	return 0;
f0104454:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104459:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010445c:	5b                   	pop    %ebx
f010445d:	5e                   	pop    %esi
f010445e:	5f                   	pop    %edi
f010445f:	5d                   	pop    %ebp
f0104460:	c3                   	ret    

f0104461 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0104461:	55                   	push   %ebp
f0104462:	89 e5                	mov    %esp,%ebp
f0104464:	57                   	push   %edi
f0104465:	56                   	push   %esi
f0104466:	53                   	push   %ebx
f0104467:	83 ec 2c             	sub    $0x2c,%esp
f010446a:	e8 85 eb ff ff       	call   f0102ff4 <__x86.get_pc_thunk.cx>
f010446f:	81 c1 85 ac 08 00    	add    $0x8ac85,%ecx
f0104475:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0104478:	89 c7                	mov    %eax,%edi
f010447a:	89 d6                	mov    %edx,%esi
f010447c:	8b 45 08             	mov    0x8(%ebp),%eax
f010447f:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104482:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0104485:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0104488:	8b 4d 10             	mov    0x10(%ebp),%ecx
f010448b:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104490:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104493:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0104496:	3b 45 10             	cmp    0x10(%ebp),%eax
f0104499:	89 d0                	mov    %edx,%eax
f010449b:	1b 45 e4             	sbb    -0x1c(%ebp),%eax
f010449e:	8b 5d 14             	mov    0x14(%ebp),%ebx
f01044a1:	73 15                	jae    f01044b8 <printnum+0x57>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f01044a3:	83 eb 01             	sub    $0x1,%ebx
f01044a6:	85 db                	test   %ebx,%ebx
f01044a8:	7e 46                	jle    f01044f0 <printnum+0x8f>
			putch(padc, putdat);
f01044aa:	83 ec 08             	sub    $0x8,%esp
f01044ad:	56                   	push   %esi
f01044ae:	ff 75 18             	pushl  0x18(%ebp)
f01044b1:	ff d7                	call   *%edi
f01044b3:	83 c4 10             	add    $0x10,%esp
f01044b6:	eb eb                	jmp    f01044a3 <printnum+0x42>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f01044b8:	83 ec 0c             	sub    $0xc,%esp
f01044bb:	ff 75 18             	pushl  0x18(%ebp)
f01044be:	8b 45 14             	mov    0x14(%ebp),%eax
f01044c1:	8d 58 ff             	lea    -0x1(%eax),%ebx
f01044c4:	53                   	push   %ebx
f01044c5:	ff 75 10             	pushl  0x10(%ebp)
f01044c8:	83 ec 08             	sub    $0x8,%esp
f01044cb:	ff 75 e4             	pushl  -0x1c(%ebp)
f01044ce:	ff 75 e0             	pushl  -0x20(%ebp)
f01044d1:	ff 75 d4             	pushl  -0x2c(%ebp)
f01044d4:	ff 75 d0             	pushl  -0x30(%ebp)
f01044d7:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f01044da:	e8 11 0a 00 00       	call   f0104ef0 <__udivdi3>
f01044df:	83 c4 18             	add    $0x18,%esp
f01044e2:	52                   	push   %edx
f01044e3:	50                   	push   %eax
f01044e4:	89 f2                	mov    %esi,%edx
f01044e6:	89 f8                	mov    %edi,%eax
f01044e8:	e8 74 ff ff ff       	call   f0104461 <printnum>
f01044ed:	83 c4 20             	add    $0x20,%esp
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f01044f0:	83 ec 08             	sub    $0x8,%esp
f01044f3:	56                   	push   %esi
f01044f4:	83 ec 04             	sub    $0x4,%esp
f01044f7:	ff 75 e4             	pushl  -0x1c(%ebp)
f01044fa:	ff 75 e0             	pushl  -0x20(%ebp)
f01044fd:	ff 75 d4             	pushl  -0x2c(%ebp)
f0104500:	ff 75 d0             	pushl  -0x30(%ebp)
f0104503:	8b 75 dc             	mov    -0x24(%ebp),%esi
f0104506:	89 f3                	mov    %esi,%ebx
f0104508:	e8 f3 0a 00 00       	call   f0105000 <__umoddi3>
f010450d:	83 c4 14             	add    $0x14,%esp
f0104510:	0f be 84 06 a9 74 f7 	movsbl -0x88b57(%esi,%eax,1),%eax
f0104517:	ff 
f0104518:	50                   	push   %eax
f0104519:	ff d7                	call   *%edi
}
f010451b:	83 c4 10             	add    $0x10,%esp
f010451e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104521:	5b                   	pop    %ebx
f0104522:	5e                   	pop    %esi
f0104523:	5f                   	pop    %edi
f0104524:	5d                   	pop    %ebp
f0104525:	c3                   	ret    

f0104526 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0104526:	55                   	push   %ebp
f0104527:	89 e5                	mov    %esp,%ebp
f0104529:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f010452c:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0104530:	8b 10                	mov    (%eax),%edx
f0104532:	3b 50 04             	cmp    0x4(%eax),%edx
f0104535:	73 0a                	jae    f0104541 <sprintputch+0x1b>
		*b->buf++ = ch;
f0104537:	8d 4a 01             	lea    0x1(%edx),%ecx
f010453a:	89 08                	mov    %ecx,(%eax)
f010453c:	8b 45 08             	mov    0x8(%ebp),%eax
f010453f:	88 02                	mov    %al,(%edx)
}
f0104541:	5d                   	pop    %ebp
f0104542:	c3                   	ret    

f0104543 <printfmt>:
{
f0104543:	55                   	push   %ebp
f0104544:	89 e5                	mov    %esp,%ebp
f0104546:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f0104549:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f010454c:	50                   	push   %eax
f010454d:	ff 75 10             	pushl  0x10(%ebp)
f0104550:	ff 75 0c             	pushl  0xc(%ebp)
f0104553:	ff 75 08             	pushl  0x8(%ebp)
f0104556:	e8 05 00 00 00       	call   f0104560 <vprintfmt>
}
f010455b:	83 c4 10             	add    $0x10,%esp
f010455e:	c9                   	leave  
f010455f:	c3                   	ret    

f0104560 <vprintfmt>:
{
f0104560:	55                   	push   %ebp
f0104561:	89 e5                	mov    %esp,%ebp
f0104563:	57                   	push   %edi
f0104564:	56                   	push   %esi
f0104565:	53                   	push   %ebx
f0104566:	83 ec 3c             	sub    $0x3c,%esp
f0104569:	e8 dc c1 ff ff       	call   f010074a <__x86.get_pc_thunk.ax>
f010456e:	05 86 ab 08 00       	add    $0x8ab86,%eax
f0104573:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104576:	8b 75 08             	mov    0x8(%ebp),%esi
f0104579:	8b 7d 0c             	mov    0xc(%ebp),%edi
f010457c:	8b 5d 10             	mov    0x10(%ebp),%ebx
f010457f:	eb 0a                	jmp    f010458b <vprintfmt+0x2b>
			putch(ch, putdat);
f0104581:	83 ec 08             	sub    $0x8,%esp
f0104584:	57                   	push   %edi
f0104585:	50                   	push   %eax
f0104586:	ff d6                	call   *%esi
f0104588:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
f010458b:	83 c3 01             	add    $0x1,%ebx
f010458e:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
f0104592:	83 f8 25             	cmp    $0x25,%eax
f0104595:	74 0c                	je     f01045a3 <vprintfmt+0x43>
			if (ch == '\0')
f0104597:	85 c0                	test   %eax,%eax
f0104599:	75 e6                	jne    f0104581 <vprintfmt+0x21>
}
f010459b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010459e:	5b                   	pop    %ebx
f010459f:	5e                   	pop    %esi
f01045a0:	5f                   	pop    %edi
f01045a1:	5d                   	pop    %ebp
f01045a2:	c3                   	ret    
		padc = ' ';
f01045a3:	c6 45 cf 20          	movb   $0x20,-0x31(%ebp)
		altflag = 0;
f01045a7:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
		precision = -1;//精度
f01045ae:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;//总宽度
f01045b5:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		lflag = 0;
f01045bc:	b9 00 00 00 00       	mov    $0x0,%ecx
f01045c1:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f01045c4:	89 75 08             	mov    %esi,0x8(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01045c7:	8d 43 01             	lea    0x1(%ebx),%eax
f01045ca:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01045cd:	0f b6 13             	movzbl (%ebx),%edx
f01045d0:	8d 42 dd             	lea    -0x23(%edx),%eax
f01045d3:	3c 55                	cmp    $0x55,%al
f01045d5:	0f 87 00 04 00 00    	ja     f01049db <.L21>
f01045db:	0f b6 c0             	movzbl %al,%eax
f01045de:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01045e1:	89 ce                	mov    %ecx,%esi
f01045e3:	03 b4 81 34 75 f7 ff 	add    -0x88acc(%ecx,%eax,4),%esi
f01045ea:	ff e6                	jmp    *%esi

f01045ec <.L68>:
f01045ec:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
f01045ef:	c6 45 cf 2d          	movb   $0x2d,-0x31(%ebp)
f01045f3:	eb d2                	jmp    f01045c7 <vprintfmt+0x67>

f01045f5 <.L33>:
		switch (ch = *(unsigned char *) fmt++) {
f01045f5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '0';
f01045f8:	c6 45 cf 30          	movb   $0x30,-0x31(%ebp)
f01045fc:	eb c9                	jmp    f01045c7 <vprintfmt+0x67>

f01045fe <.L32>:
		switch (ch = *(unsigned char *) fmt++) {
f01045fe:	0f b6 d2             	movzbl %dl,%edx
f0104601:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {//依次读取数据宽度
f0104604:	b8 00 00 00 00       	mov    $0x0,%eax
f0104609:	8b 75 08             	mov    0x8(%ebp),%esi
				precision = precision * 10 + ch - '0';
f010460c:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010460f:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f0104613:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
f0104616:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0104619:	83 f9 09             	cmp    $0x9,%ecx
f010461c:	77 58                	ja     f0104676 <.L37+0xf>
			for (precision = 0; ; ++fmt) {//依次读取数据宽度
f010461e:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
f0104621:	eb e9                	jmp    f010460c <.L32+0xe>

f0104623 <.L35>:
			precision = va_arg(ap, int);
f0104623:	8b 45 14             	mov    0x14(%ebp),%eax
f0104626:	8b 00                	mov    (%eax),%eax
f0104628:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010462b:	8b 45 14             	mov    0x14(%ebp),%eax
f010462e:	8d 40 04             	lea    0x4(%eax),%eax
f0104631:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0104634:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
f0104637:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f010463b:	79 8a                	jns    f01045c7 <vprintfmt+0x67>
				width = precision, precision = -1;
f010463d:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0104640:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0104643:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
f010464a:	e9 78 ff ff ff       	jmp    f01045c7 <vprintfmt+0x67>

f010464f <.L34>:
f010464f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0104652:	85 c0                	test   %eax,%eax
f0104654:	ba 00 00 00 00       	mov    $0x0,%edx
f0104659:	0f 49 d0             	cmovns %eax,%edx
f010465c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f010465f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104662:	e9 60 ff ff ff       	jmp    f01045c7 <vprintfmt+0x67>

f0104667 <.L37>:
f0104667:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
f010466a:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
f0104671:	e9 51 ff ff ff       	jmp    f01045c7 <vprintfmt+0x67>
f0104676:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104679:	89 75 08             	mov    %esi,0x8(%ebp)
f010467c:	eb b9                	jmp    f0104637 <.L35+0x14>

f010467e <.L28>:
			lflag++;
f010467e:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0104682:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
f0104685:	e9 3d ff ff ff       	jmp    f01045c7 <vprintfmt+0x67>

f010468a <.L31>:
f010468a:	8b 75 08             	mov    0x8(%ebp),%esi
			putch(va_arg(ap, int), putdat);
f010468d:	8b 45 14             	mov    0x14(%ebp),%eax
f0104690:	8d 58 04             	lea    0x4(%eax),%ebx
f0104693:	83 ec 08             	sub    $0x8,%esp
f0104696:	57                   	push   %edi
f0104697:	ff 30                	pushl  (%eax)
f0104699:	ff d6                	call   *%esi
			break;
f010469b:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f010469e:	89 5d 14             	mov    %ebx,0x14(%ebp)
			break;
f01046a1:	e9 cb 02 00 00       	jmp    f0104971 <.L26+0x45>

f01046a6 <.L29>:
f01046a6:	8b 75 08             	mov    0x8(%ebp),%esi
			err = va_arg(ap, int);
f01046a9:	8b 45 14             	mov    0x14(%ebp),%eax
f01046ac:	8d 58 04             	lea    0x4(%eax),%ebx
f01046af:	8b 00                	mov    (%eax),%eax
f01046b1:	99                   	cltd   
f01046b2:	31 d0                	xor    %edx,%eax
f01046b4:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01046b6:	83 f8 06             	cmp    $0x6,%eax
f01046b9:	7f 2b                	jg     f01046e6 <.L29+0x40>
f01046bb:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01046be:	8b 94 82 dc ff ff ff 	mov    -0x24(%edx,%eax,4),%edx
f01046c5:	85 d2                	test   %edx,%edx
f01046c7:	74 1d                	je     f01046e6 <.L29+0x40>
				printfmt(putch, putdat, "%s", p);
f01046c9:	52                   	push   %edx
f01046ca:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01046cd:	8d 80 7d 6d f7 ff    	lea    -0x89283(%eax),%eax
f01046d3:	50                   	push   %eax
f01046d4:	57                   	push   %edi
f01046d5:	56                   	push   %esi
f01046d6:	e8 68 fe ff ff       	call   f0104543 <printfmt>
f01046db:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f01046de:	89 5d 14             	mov    %ebx,0x14(%ebp)
f01046e1:	e9 8b 02 00 00       	jmp    f0104971 <.L26+0x45>
				printfmt(putch, putdat, "error %d", err);
f01046e6:	50                   	push   %eax
f01046e7:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01046ea:	8d 80 c1 74 f7 ff    	lea    -0x88b3f(%eax),%eax
f01046f0:	50                   	push   %eax
f01046f1:	57                   	push   %edi
f01046f2:	56                   	push   %esi
f01046f3:	e8 4b fe ff ff       	call   f0104543 <printfmt>
f01046f8:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f01046fb:	89 5d 14             	mov    %ebx,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f01046fe:	e9 6e 02 00 00       	jmp    f0104971 <.L26+0x45>

f0104703 <.L25>:
f0104703:	8b 75 08             	mov    0x8(%ebp),%esi
			if ((p = va_arg(ap, char *)) == NULL)
f0104706:	8b 45 14             	mov    0x14(%ebp),%eax
f0104709:	83 c0 04             	add    $0x4,%eax
f010470c:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f010470f:	8b 45 14             	mov    0x14(%ebp),%eax
f0104712:	8b 10                	mov    (%eax),%edx
				p = "(null)";
f0104714:	85 d2                	test   %edx,%edx
f0104716:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104719:	8d 80 ba 74 f7 ff    	lea    -0x88b46(%eax),%eax
f010471f:	0f 45 c2             	cmovne %edx,%eax
f0104722:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
f0104725:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0104729:	7e 06                	jle    f0104731 <.L25+0x2e>
f010472b:	80 7d cf 2d          	cmpb   $0x2d,-0x31(%ebp)
f010472f:	75 0d                	jne    f010473e <.L25+0x3b>
				for (width -= strnlen(p, precision); width > 0; width--)
f0104731:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0104734:	89 c3                	mov    %eax,%ebx
f0104736:	03 45 d4             	add    -0x2c(%ebp),%eax
f0104739:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010473c:	eb 42                	jmp    f0104780 <.L25+0x7d>
f010473e:	83 ec 08             	sub    $0x8,%esp
f0104741:	ff 75 d8             	pushl  -0x28(%ebp)
f0104744:	50                   	push   %eax
f0104745:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0104748:	e8 3f 04 00 00       	call   f0104b8c <strnlen>
f010474d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0104750:	29 c2                	sub    %eax,%edx
f0104752:	89 55 c0             	mov    %edx,-0x40(%ebp)
f0104755:	83 c4 10             	add    $0x10,%esp
f0104758:	89 d3                	mov    %edx,%ebx
					putch(padc, putdat);
f010475a:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
f010475e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f0104761:	85 db                	test   %ebx,%ebx
f0104763:	7e 58                	jle    f01047bd <.L25+0xba>
					putch(padc, putdat);
f0104765:	83 ec 08             	sub    $0x8,%esp
f0104768:	57                   	push   %edi
f0104769:	ff 75 d4             	pushl  -0x2c(%ebp)
f010476c:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f010476e:	83 eb 01             	sub    $0x1,%ebx
f0104771:	83 c4 10             	add    $0x10,%esp
f0104774:	eb eb                	jmp    f0104761 <.L25+0x5e>
					putch(ch, putdat);
f0104776:	83 ec 08             	sub    $0x8,%esp
f0104779:	57                   	push   %edi
f010477a:	52                   	push   %edx
f010477b:	ff d6                	call   *%esi
f010477d:	83 c4 10             	add    $0x10,%esp
f0104780:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0104783:	29 d9                	sub    %ebx,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0104785:	83 c3 01             	add    $0x1,%ebx
f0104788:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
f010478c:	0f be d0             	movsbl %al,%edx
f010478f:	85 d2                	test   %edx,%edx
f0104791:	74 45                	je     f01047d8 <.L25+0xd5>
f0104793:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0104797:	78 06                	js     f010479f <.L25+0x9c>
f0104799:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
f010479d:	78 35                	js     f01047d4 <.L25+0xd1>
				if (altflag && (ch < ' ' || ch > '~'))
f010479f:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f01047a3:	74 d1                	je     f0104776 <.L25+0x73>
f01047a5:	0f be c0             	movsbl %al,%eax
f01047a8:	83 e8 20             	sub    $0x20,%eax
f01047ab:	83 f8 5e             	cmp    $0x5e,%eax
f01047ae:	76 c6                	jbe    f0104776 <.L25+0x73>
					putch('?', putdat);
f01047b0:	83 ec 08             	sub    $0x8,%esp
f01047b3:	57                   	push   %edi
f01047b4:	6a 3f                	push   $0x3f
f01047b6:	ff d6                	call   *%esi
f01047b8:	83 c4 10             	add    $0x10,%esp
f01047bb:	eb c3                	jmp    f0104780 <.L25+0x7d>
f01047bd:	8b 55 c0             	mov    -0x40(%ebp),%edx
f01047c0:	85 d2                	test   %edx,%edx
f01047c2:	b8 00 00 00 00       	mov    $0x0,%eax
f01047c7:	0f 49 c2             	cmovns %edx,%eax
f01047ca:	29 c2                	sub    %eax,%edx
f01047cc:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f01047cf:	e9 5d ff ff ff       	jmp    f0104731 <.L25+0x2e>
f01047d4:	89 cb                	mov    %ecx,%ebx
f01047d6:	eb 02                	jmp    f01047da <.L25+0xd7>
f01047d8:	89 cb                	mov    %ecx,%ebx
			for (; width > 0; width--)
f01047da:	85 db                	test   %ebx,%ebx
f01047dc:	7e 10                	jle    f01047ee <.L25+0xeb>
				putch(' ', putdat);
f01047de:	83 ec 08             	sub    $0x8,%esp
f01047e1:	57                   	push   %edi
f01047e2:	6a 20                	push   $0x20
f01047e4:	ff d6                	call   *%esi
			for (; width > 0; width--)
f01047e6:	83 eb 01             	sub    $0x1,%ebx
f01047e9:	83 c4 10             	add    $0x10,%esp
f01047ec:	eb ec                	jmp    f01047da <.L25+0xd7>
			if ((p = va_arg(ap, char *)) == NULL)
f01047ee:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f01047f1:	89 45 14             	mov    %eax,0x14(%ebp)
f01047f4:	e9 78 01 00 00       	jmp    f0104971 <.L26+0x45>

f01047f9 <.L30>:
f01047f9:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f01047fc:	8b 75 08             	mov    0x8(%ebp),%esi
	if (lflag >= 2)
f01047ff:	83 f9 01             	cmp    $0x1,%ecx
f0104802:	7f 1b                	jg     f010481f <.L30+0x26>
	else if (lflag)
f0104804:	85 c9                	test   %ecx,%ecx
f0104806:	74 63                	je     f010486b <.L30+0x72>
		return va_arg(*ap, long);
f0104808:	8b 45 14             	mov    0x14(%ebp),%eax
f010480b:	8b 00                	mov    (%eax),%eax
f010480d:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104810:	99                   	cltd   
f0104811:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0104814:	8b 45 14             	mov    0x14(%ebp),%eax
f0104817:	8d 40 04             	lea    0x4(%eax),%eax
f010481a:	89 45 14             	mov    %eax,0x14(%ebp)
f010481d:	eb 17                	jmp    f0104836 <.L30+0x3d>
		return va_arg(*ap, long long);
f010481f:	8b 45 14             	mov    0x14(%ebp),%eax
f0104822:	8b 50 04             	mov    0x4(%eax),%edx
f0104825:	8b 00                	mov    (%eax),%eax
f0104827:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010482a:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010482d:	8b 45 14             	mov    0x14(%ebp),%eax
f0104830:	8d 40 08             	lea    0x8(%eax),%eax
f0104833:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f0104836:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104839:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f010483c:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
f0104841:	85 c9                	test   %ecx,%ecx
f0104843:	0f 89 0e 01 00 00    	jns    f0104957 <.L26+0x2b>
				putch('-', putdat);
f0104849:	83 ec 08             	sub    $0x8,%esp
f010484c:	57                   	push   %edi
f010484d:	6a 2d                	push   $0x2d
f010484f:	ff d6                	call   *%esi
				num = -(long long) num;
f0104851:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104854:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0104857:	f7 da                	neg    %edx
f0104859:	83 d1 00             	adc    $0x0,%ecx
f010485c:	f7 d9                	neg    %ecx
f010485e:	83 c4 10             	add    $0x10,%esp
			base = 10;
f0104861:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104866:	e9 ec 00 00 00       	jmp    f0104957 <.L26+0x2b>
		return va_arg(*ap, int);
f010486b:	8b 45 14             	mov    0x14(%ebp),%eax
f010486e:	8b 00                	mov    (%eax),%eax
f0104870:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104873:	99                   	cltd   
f0104874:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0104877:	8b 45 14             	mov    0x14(%ebp),%eax
f010487a:	8d 40 04             	lea    0x4(%eax),%eax
f010487d:	89 45 14             	mov    %eax,0x14(%ebp)
f0104880:	eb b4                	jmp    f0104836 <.L30+0x3d>

f0104882 <.L24>:
f0104882:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0104885:	8b 75 08             	mov    0x8(%ebp),%esi
	if (lflag >= 2)
f0104888:	83 f9 01             	cmp    $0x1,%ecx
f010488b:	7f 1e                	jg     f01048ab <.L24+0x29>
	else if (lflag)
f010488d:	85 c9                	test   %ecx,%ecx
f010488f:	74 32                	je     f01048c3 <.L24+0x41>
		return va_arg(*ap, unsigned long);
f0104891:	8b 45 14             	mov    0x14(%ebp),%eax
f0104894:	8b 10                	mov    (%eax),%edx
f0104896:	b9 00 00 00 00       	mov    $0x0,%ecx
f010489b:	8d 40 04             	lea    0x4(%eax),%eax
f010489e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01048a1:	b8 0a 00 00 00       	mov    $0xa,%eax
f01048a6:	e9 ac 00 00 00       	jmp    f0104957 <.L26+0x2b>
		return va_arg(*ap, unsigned long long);
f01048ab:	8b 45 14             	mov    0x14(%ebp),%eax
f01048ae:	8b 10                	mov    (%eax),%edx
f01048b0:	8b 48 04             	mov    0x4(%eax),%ecx
f01048b3:	8d 40 08             	lea    0x8(%eax),%eax
f01048b6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01048b9:	b8 0a 00 00 00       	mov    $0xa,%eax
f01048be:	e9 94 00 00 00       	jmp    f0104957 <.L26+0x2b>
		return va_arg(*ap, unsigned int);
f01048c3:	8b 45 14             	mov    0x14(%ebp),%eax
f01048c6:	8b 10                	mov    (%eax),%edx
f01048c8:	b9 00 00 00 00       	mov    $0x0,%ecx
f01048cd:	8d 40 04             	lea    0x4(%eax),%eax
f01048d0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01048d3:	b8 0a 00 00 00       	mov    $0xa,%eax
f01048d8:	eb 7d                	jmp    f0104957 <.L26+0x2b>

f01048da <.L27>:
f01048da:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f01048dd:	8b 75 08             	mov    0x8(%ebp),%esi
	if (lflag >= 2)
f01048e0:	83 f9 01             	cmp    $0x1,%ecx
f01048e3:	7f 1b                	jg     f0104900 <.L27+0x26>
	else if (lflag)
f01048e5:	85 c9                	test   %ecx,%ecx
f01048e7:	74 2c                	je     f0104915 <.L27+0x3b>
		return va_arg(*ap, unsigned long);
f01048e9:	8b 45 14             	mov    0x14(%ebp),%eax
f01048ec:	8b 10                	mov    (%eax),%edx
f01048ee:	b9 00 00 00 00       	mov    $0x0,%ecx
f01048f3:	8d 40 04             	lea    0x4(%eax),%eax
f01048f6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f01048f9:	b8 08 00 00 00       	mov    $0x8,%eax
f01048fe:	eb 57                	jmp    f0104957 <.L26+0x2b>
		return va_arg(*ap, unsigned long long);
f0104900:	8b 45 14             	mov    0x14(%ebp),%eax
f0104903:	8b 10                	mov    (%eax),%edx
f0104905:	8b 48 04             	mov    0x4(%eax),%ecx
f0104908:	8d 40 08             	lea    0x8(%eax),%eax
f010490b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f010490e:	b8 08 00 00 00       	mov    $0x8,%eax
f0104913:	eb 42                	jmp    f0104957 <.L26+0x2b>
		return va_arg(*ap, unsigned int);
f0104915:	8b 45 14             	mov    0x14(%ebp),%eax
f0104918:	8b 10                	mov    (%eax),%edx
f010491a:	b9 00 00 00 00       	mov    $0x0,%ecx
f010491f:	8d 40 04             	lea    0x4(%eax),%eax
f0104922:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0104925:	b8 08 00 00 00       	mov    $0x8,%eax
f010492a:	eb 2b                	jmp    f0104957 <.L26+0x2b>

f010492c <.L26>:
f010492c:	8b 75 08             	mov    0x8(%ebp),%esi
			putch('0', putdat);
f010492f:	83 ec 08             	sub    $0x8,%esp
f0104932:	57                   	push   %edi
f0104933:	6a 30                	push   $0x30
f0104935:	ff d6                	call   *%esi
			putch('x', putdat);
f0104937:	83 c4 08             	add    $0x8,%esp
f010493a:	57                   	push   %edi
f010493b:	6a 78                	push   $0x78
f010493d:	ff d6                	call   *%esi
			num = (unsigned long long)
f010493f:	8b 45 14             	mov    0x14(%ebp),%eax
f0104942:	8b 10                	mov    (%eax),%edx
f0104944:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f0104949:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f010494c:	8d 40 04             	lea    0x4(%eax),%eax
f010494f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0104952:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
f0104957:	83 ec 0c             	sub    $0xc,%esp
f010495a:	0f be 5d cf          	movsbl -0x31(%ebp),%ebx
f010495e:	53                   	push   %ebx
f010495f:	ff 75 d4             	pushl  -0x2c(%ebp)
f0104962:	50                   	push   %eax
f0104963:	51                   	push   %ecx
f0104964:	52                   	push   %edx
f0104965:	89 fa                	mov    %edi,%edx
f0104967:	89 f0                	mov    %esi,%eax
f0104969:	e8 f3 fa ff ff       	call   f0104461 <printnum>
			break;
f010496e:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
f0104971:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0104974:	e9 12 fc ff ff       	jmp    f010458b <vprintfmt+0x2b>

f0104979 <.L22>:
f0104979:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f010497c:	8b 75 08             	mov    0x8(%ebp),%esi
	if (lflag >= 2)
f010497f:	83 f9 01             	cmp    $0x1,%ecx
f0104982:	7f 1b                	jg     f010499f <.L22+0x26>
	else if (lflag)
f0104984:	85 c9                	test   %ecx,%ecx
f0104986:	74 2c                	je     f01049b4 <.L22+0x3b>
		return va_arg(*ap, unsigned long);
f0104988:	8b 45 14             	mov    0x14(%ebp),%eax
f010498b:	8b 10                	mov    (%eax),%edx
f010498d:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104992:	8d 40 04             	lea    0x4(%eax),%eax
f0104995:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0104998:	b8 10 00 00 00       	mov    $0x10,%eax
f010499d:	eb b8                	jmp    f0104957 <.L26+0x2b>
		return va_arg(*ap, unsigned long long);
f010499f:	8b 45 14             	mov    0x14(%ebp),%eax
f01049a2:	8b 10                	mov    (%eax),%edx
f01049a4:	8b 48 04             	mov    0x4(%eax),%ecx
f01049a7:	8d 40 08             	lea    0x8(%eax),%eax
f01049aa:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01049ad:	b8 10 00 00 00       	mov    $0x10,%eax
f01049b2:	eb a3                	jmp    f0104957 <.L26+0x2b>
		return va_arg(*ap, unsigned int);
f01049b4:	8b 45 14             	mov    0x14(%ebp),%eax
f01049b7:	8b 10                	mov    (%eax),%edx
f01049b9:	b9 00 00 00 00       	mov    $0x0,%ecx
f01049be:	8d 40 04             	lea    0x4(%eax),%eax
f01049c1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01049c4:	b8 10 00 00 00       	mov    $0x10,%eax
f01049c9:	eb 8c                	jmp    f0104957 <.L26+0x2b>

f01049cb <.L36>:
f01049cb:	8b 75 08             	mov    0x8(%ebp),%esi
			putch(ch, putdat);
f01049ce:	83 ec 08             	sub    $0x8,%esp
f01049d1:	57                   	push   %edi
f01049d2:	6a 25                	push   $0x25
f01049d4:	ff d6                	call   *%esi
			break;
f01049d6:	83 c4 10             	add    $0x10,%esp
f01049d9:	eb 96                	jmp    f0104971 <.L26+0x45>

f01049db <.L21>:
f01049db:	8b 75 08             	mov    0x8(%ebp),%esi
			putch('%', putdat);
f01049de:	83 ec 08             	sub    $0x8,%esp
f01049e1:	57                   	push   %edi
f01049e2:	6a 25                	push   $0x25
f01049e4:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f01049e6:	83 c4 10             	add    $0x10,%esp
f01049e9:	89 d8                	mov    %ebx,%eax
f01049eb:	eb 03                	jmp    f01049f0 <.L21+0x15>
f01049ed:	83 e8 01             	sub    $0x1,%eax
f01049f0:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f01049f4:	75 f7                	jne    f01049ed <.L21+0x12>
f01049f6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01049f9:	e9 73 ff ff ff       	jmp    f0104971 <.L26+0x45>

f01049fe <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01049fe:	55                   	push   %ebp
f01049ff:	89 e5                	mov    %esp,%ebp
f0104a01:	53                   	push   %ebx
f0104a02:	83 ec 14             	sub    $0x14,%esp
f0104a05:	e8 cf b7 ff ff       	call   f01001d9 <__x86.get_pc_thunk.bx>
f0104a0a:	81 c3 ea a6 08 00    	add    $0x8a6ea,%ebx
f0104a10:	8b 45 08             	mov    0x8(%ebp),%eax
f0104a13:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0104a16:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104a19:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0104a1d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0104a20:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0104a27:	85 c0                	test   %eax,%eax
f0104a29:	74 2b                	je     f0104a56 <vsnprintf+0x58>
f0104a2b:	85 d2                	test   %edx,%edx
f0104a2d:	7e 27                	jle    f0104a56 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0104a2f:	ff 75 14             	pushl  0x14(%ebp)
f0104a32:	ff 75 10             	pushl  0x10(%ebp)
f0104a35:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0104a38:	50                   	push   %eax
f0104a39:	8d 83 32 54 f7 ff    	lea    -0x8abce(%ebx),%eax
f0104a3f:	50                   	push   %eax
f0104a40:	e8 1b fb ff ff       	call   f0104560 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0104a45:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104a48:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0104a4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104a4e:	83 c4 10             	add    $0x10,%esp
}
f0104a51:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104a54:	c9                   	leave  
f0104a55:	c3                   	ret    
		return -E_INVAL;
f0104a56:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104a5b:	eb f4                	jmp    f0104a51 <vsnprintf+0x53>

f0104a5d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0104a5d:	55                   	push   %ebp
f0104a5e:	89 e5                	mov    %esp,%ebp
f0104a60:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0104a63:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0104a66:	50                   	push   %eax
f0104a67:	ff 75 10             	pushl  0x10(%ebp)
f0104a6a:	ff 75 0c             	pushl  0xc(%ebp)
f0104a6d:	ff 75 08             	pushl  0x8(%ebp)
f0104a70:	e8 89 ff ff ff       	call   f01049fe <vsnprintf>
	va_end(ap);

	return rc;
}
f0104a75:	c9                   	leave  
f0104a76:	c3                   	ret    

f0104a77 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0104a77:	55                   	push   %ebp
f0104a78:	89 e5                	mov    %esp,%ebp
f0104a7a:	57                   	push   %edi
f0104a7b:	56                   	push   %esi
f0104a7c:	53                   	push   %ebx
f0104a7d:	83 ec 1c             	sub    $0x1c,%esp
f0104a80:	e8 54 b7 ff ff       	call   f01001d9 <__x86.get_pc_thunk.bx>
f0104a85:	81 c3 6f a6 08 00    	add    $0x8a66f,%ebx
f0104a8b:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0104a8e:	85 c0                	test   %eax,%eax
f0104a90:	74 13                	je     f0104aa5 <readline+0x2e>
		cprintf("%s", prompt);
f0104a92:	83 ec 08             	sub    $0x8,%esp
f0104a95:	50                   	push   %eax
f0104a96:	8d 83 7d 6d f7 ff    	lea    -0x89283(%ebx),%eax
f0104a9c:	50                   	push   %eax
f0104a9d:	e8 95 ed ff ff       	call   f0103837 <cprintf>
f0104aa2:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0104aa5:	83 ec 0c             	sub    $0xc,%esp
f0104aa8:	6a 00                	push   $0x0
f0104aaa:	e8 95 bc ff ff       	call   f0100744 <iscons>
f0104aaf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104ab2:	83 c4 10             	add    $0x10,%esp
	i = 0;
f0104ab5:	bf 00 00 00 00       	mov    $0x0,%edi
f0104aba:	eb 52                	jmp    f0104b0e <readline+0x97>
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
f0104abc:	83 ec 08             	sub    $0x8,%esp
f0104abf:	50                   	push   %eax
f0104ac0:	8d 83 8c 76 f7 ff    	lea    -0x88974(%ebx),%eax
f0104ac6:	50                   	push   %eax
f0104ac7:	e8 6b ed ff ff       	call   f0103837 <cprintf>
			return NULL;
f0104acc:	83 c4 10             	add    $0x10,%esp
f0104acf:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f0104ad4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104ad7:	5b                   	pop    %ebx
f0104ad8:	5e                   	pop    %esi
f0104ad9:	5f                   	pop    %edi
f0104ada:	5d                   	pop    %ebp
f0104adb:	c3                   	ret    
			if (echoing)
f0104adc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0104ae0:	75 05                	jne    f0104ae7 <readline+0x70>
			i--;
f0104ae2:	83 ef 01             	sub    $0x1,%edi
f0104ae5:	eb 27                	jmp    f0104b0e <readline+0x97>
				cputchar('\b');
f0104ae7:	83 ec 0c             	sub    $0xc,%esp
f0104aea:	6a 08                	push   $0x8
f0104aec:	e8 32 bc ff ff       	call   f0100723 <cputchar>
f0104af1:	83 c4 10             	add    $0x10,%esp
f0104af4:	eb ec                	jmp    f0104ae2 <readline+0x6b>
				cputchar(c);
f0104af6:	83 ec 0c             	sub    $0xc,%esp
f0104af9:	56                   	push   %esi
f0104afa:	e8 24 bc ff ff       	call   f0100723 <cputchar>
f0104aff:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0104b02:	89 f0                	mov    %esi,%eax
f0104b04:	88 84 3b 0c 0b 00 00 	mov    %al,0xb0c(%ebx,%edi,1)
f0104b0b:	8d 7f 01             	lea    0x1(%edi),%edi
		c = getchar();
f0104b0e:	e8 20 bc ff ff       	call   f0100733 <getchar>
f0104b13:	89 c6                	mov    %eax,%esi
		if (c < 0) {
f0104b15:	85 c0                	test   %eax,%eax
f0104b17:	78 a3                	js     f0104abc <readline+0x45>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0104b19:	83 f8 08             	cmp    $0x8,%eax
f0104b1c:	0f 94 c2             	sete   %dl
f0104b1f:	83 f8 7f             	cmp    $0x7f,%eax
f0104b22:	0f 94 c0             	sete   %al
f0104b25:	08 c2                	or     %al,%dl
f0104b27:	74 04                	je     f0104b2d <readline+0xb6>
f0104b29:	85 ff                	test   %edi,%edi
f0104b2b:	7f af                	jg     f0104adc <readline+0x65>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0104b2d:	83 fe 1f             	cmp    $0x1f,%esi
f0104b30:	7e 10                	jle    f0104b42 <readline+0xcb>
f0104b32:	81 ff fe 03 00 00    	cmp    $0x3fe,%edi
f0104b38:	7f 08                	jg     f0104b42 <readline+0xcb>
			if (echoing)
f0104b3a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0104b3e:	74 c2                	je     f0104b02 <readline+0x8b>
f0104b40:	eb b4                	jmp    f0104af6 <readline+0x7f>
		} else if (c == '\n' || c == '\r') {
f0104b42:	83 fe 0a             	cmp    $0xa,%esi
f0104b45:	74 05                	je     f0104b4c <readline+0xd5>
f0104b47:	83 fe 0d             	cmp    $0xd,%esi
f0104b4a:	75 c2                	jne    f0104b0e <readline+0x97>
			if (echoing)
f0104b4c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0104b50:	75 13                	jne    f0104b65 <readline+0xee>
			buf[i] = 0;
f0104b52:	c6 84 3b 0c 0b 00 00 	movb   $0x0,0xb0c(%ebx,%edi,1)
f0104b59:	00 
			return buf;
f0104b5a:	8d 83 0c 0b 00 00    	lea    0xb0c(%ebx),%eax
f0104b60:	e9 6f ff ff ff       	jmp    f0104ad4 <readline+0x5d>
				cputchar('\n');
f0104b65:	83 ec 0c             	sub    $0xc,%esp
f0104b68:	6a 0a                	push   $0xa
f0104b6a:	e8 b4 bb ff ff       	call   f0100723 <cputchar>
f0104b6f:	83 c4 10             	add    $0x10,%esp
f0104b72:	eb de                	jmp    f0104b52 <readline+0xdb>

f0104b74 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0104b74:	55                   	push   %ebp
f0104b75:	89 e5                	mov    %esp,%ebp
f0104b77:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0104b7a:	b8 00 00 00 00       	mov    $0x0,%eax
f0104b7f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0104b83:	74 05                	je     f0104b8a <strlen+0x16>
		n++;
f0104b85:	83 c0 01             	add    $0x1,%eax
f0104b88:	eb f5                	jmp    f0104b7f <strlen+0xb>
	return n;
}
f0104b8a:	5d                   	pop    %ebp
f0104b8b:	c3                   	ret    

f0104b8c <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0104b8c:	55                   	push   %ebp
f0104b8d:	89 e5                	mov    %esp,%ebp
f0104b8f:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104b92:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0104b95:	ba 00 00 00 00       	mov    $0x0,%edx
f0104b9a:	39 c2                	cmp    %eax,%edx
f0104b9c:	74 0d                	je     f0104bab <strnlen+0x1f>
f0104b9e:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f0104ba2:	74 05                	je     f0104ba9 <strnlen+0x1d>
		n++;
f0104ba4:	83 c2 01             	add    $0x1,%edx
f0104ba7:	eb f1                	jmp    f0104b9a <strnlen+0xe>
f0104ba9:	89 d0                	mov    %edx,%eax
	return n;
}
f0104bab:	5d                   	pop    %ebp
f0104bac:	c3                   	ret    

f0104bad <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0104bad:	55                   	push   %ebp
f0104bae:	89 e5                	mov    %esp,%ebp
f0104bb0:	53                   	push   %ebx
f0104bb1:	8b 45 08             	mov    0x8(%ebp),%eax
f0104bb4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0104bb7:	ba 00 00 00 00       	mov    $0x0,%edx
f0104bbc:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f0104bc0:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0104bc3:	83 c2 01             	add    $0x1,%edx
f0104bc6:	84 c9                	test   %cl,%cl
f0104bc8:	75 f2                	jne    f0104bbc <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0104bca:	5b                   	pop    %ebx
f0104bcb:	5d                   	pop    %ebp
f0104bcc:	c3                   	ret    

f0104bcd <strcat>:

char *
strcat(char *dst, const char *src)
{
f0104bcd:	55                   	push   %ebp
f0104bce:	89 e5                	mov    %esp,%ebp
f0104bd0:	53                   	push   %ebx
f0104bd1:	83 ec 10             	sub    $0x10,%esp
f0104bd4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0104bd7:	53                   	push   %ebx
f0104bd8:	e8 97 ff ff ff       	call   f0104b74 <strlen>
f0104bdd:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
f0104be0:	ff 75 0c             	pushl  0xc(%ebp)
f0104be3:	01 d8                	add    %ebx,%eax
f0104be5:	50                   	push   %eax
f0104be6:	e8 c2 ff ff ff       	call   f0104bad <strcpy>
	return dst;
}
f0104beb:	89 d8                	mov    %ebx,%eax
f0104bed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104bf0:	c9                   	leave  
f0104bf1:	c3                   	ret    

f0104bf2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0104bf2:	55                   	push   %ebp
f0104bf3:	89 e5                	mov    %esp,%ebp
f0104bf5:	56                   	push   %esi
f0104bf6:	53                   	push   %ebx
f0104bf7:	8b 45 08             	mov    0x8(%ebp),%eax
f0104bfa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104bfd:	89 c6                	mov    %eax,%esi
f0104bff:	03 75 10             	add    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0104c02:	89 c2                	mov    %eax,%edx
f0104c04:	39 f2                	cmp    %esi,%edx
f0104c06:	74 11                	je     f0104c19 <strncpy+0x27>
		*dst++ = *src;
f0104c08:	83 c2 01             	add    $0x1,%edx
f0104c0b:	0f b6 19             	movzbl (%ecx),%ebx
f0104c0e:	88 5a ff             	mov    %bl,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0104c11:	80 fb 01             	cmp    $0x1,%bl
f0104c14:	83 d9 ff             	sbb    $0xffffffff,%ecx
f0104c17:	eb eb                	jmp    f0104c04 <strncpy+0x12>
	}
	return ret;
}
f0104c19:	5b                   	pop    %ebx
f0104c1a:	5e                   	pop    %esi
f0104c1b:	5d                   	pop    %ebp
f0104c1c:	c3                   	ret    

f0104c1d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0104c1d:	55                   	push   %ebp
f0104c1e:	89 e5                	mov    %esp,%ebp
f0104c20:	56                   	push   %esi
f0104c21:	53                   	push   %ebx
f0104c22:	8b 75 08             	mov    0x8(%ebp),%esi
f0104c25:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104c28:	8b 55 10             	mov    0x10(%ebp),%edx
f0104c2b:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0104c2d:	85 d2                	test   %edx,%edx
f0104c2f:	74 21                	je     f0104c52 <strlcpy+0x35>
f0104c31:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0104c35:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
f0104c37:	39 c2                	cmp    %eax,%edx
f0104c39:	74 14                	je     f0104c4f <strlcpy+0x32>
f0104c3b:	0f b6 19             	movzbl (%ecx),%ebx
f0104c3e:	84 db                	test   %bl,%bl
f0104c40:	74 0b                	je     f0104c4d <strlcpy+0x30>
			*dst++ = *src++;
f0104c42:	83 c1 01             	add    $0x1,%ecx
f0104c45:	83 c2 01             	add    $0x1,%edx
f0104c48:	88 5a ff             	mov    %bl,-0x1(%edx)
f0104c4b:	eb ea                	jmp    f0104c37 <strlcpy+0x1a>
f0104c4d:	89 d0                	mov    %edx,%eax
		*dst = '\0';
f0104c4f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0104c52:	29 f0                	sub    %esi,%eax
}
f0104c54:	5b                   	pop    %ebx
f0104c55:	5e                   	pop    %esi
f0104c56:	5d                   	pop    %ebp
f0104c57:	c3                   	ret    

f0104c58 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0104c58:	55                   	push   %ebp
f0104c59:	89 e5                	mov    %esp,%ebp
f0104c5b:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104c5e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0104c61:	0f b6 01             	movzbl (%ecx),%eax
f0104c64:	84 c0                	test   %al,%al
f0104c66:	74 0c                	je     f0104c74 <strcmp+0x1c>
f0104c68:	3a 02                	cmp    (%edx),%al
f0104c6a:	75 08                	jne    f0104c74 <strcmp+0x1c>
		p++, q++;
f0104c6c:	83 c1 01             	add    $0x1,%ecx
f0104c6f:	83 c2 01             	add    $0x1,%edx
f0104c72:	eb ed                	jmp    f0104c61 <strcmp+0x9>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0104c74:	0f b6 c0             	movzbl %al,%eax
f0104c77:	0f b6 12             	movzbl (%edx),%edx
f0104c7a:	29 d0                	sub    %edx,%eax
}
f0104c7c:	5d                   	pop    %ebp
f0104c7d:	c3                   	ret    

f0104c7e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0104c7e:	55                   	push   %ebp
f0104c7f:	89 e5                	mov    %esp,%ebp
f0104c81:	53                   	push   %ebx
f0104c82:	8b 45 08             	mov    0x8(%ebp),%eax
f0104c85:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104c88:	89 c3                	mov    %eax,%ebx
f0104c8a:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0104c8d:	eb 06                	jmp    f0104c95 <strncmp+0x17>
		n--, p++, q++;
f0104c8f:	83 c0 01             	add    $0x1,%eax
f0104c92:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f0104c95:	39 d8                	cmp    %ebx,%eax
f0104c97:	74 16                	je     f0104caf <strncmp+0x31>
f0104c99:	0f b6 08             	movzbl (%eax),%ecx
f0104c9c:	84 c9                	test   %cl,%cl
f0104c9e:	74 04                	je     f0104ca4 <strncmp+0x26>
f0104ca0:	3a 0a                	cmp    (%edx),%cl
f0104ca2:	74 eb                	je     f0104c8f <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0104ca4:	0f b6 00             	movzbl (%eax),%eax
f0104ca7:	0f b6 12             	movzbl (%edx),%edx
f0104caa:	29 d0                	sub    %edx,%eax
}
f0104cac:	5b                   	pop    %ebx
f0104cad:	5d                   	pop    %ebp
f0104cae:	c3                   	ret    
		return 0;
f0104caf:	b8 00 00 00 00       	mov    $0x0,%eax
f0104cb4:	eb f6                	jmp    f0104cac <strncmp+0x2e>

f0104cb6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0104cb6:	55                   	push   %ebp
f0104cb7:	89 e5                	mov    %esp,%ebp
f0104cb9:	8b 45 08             	mov    0x8(%ebp),%eax
f0104cbc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0104cc0:	0f b6 10             	movzbl (%eax),%edx
f0104cc3:	84 d2                	test   %dl,%dl
f0104cc5:	74 09                	je     f0104cd0 <strchr+0x1a>
		if (*s == c)
f0104cc7:	38 ca                	cmp    %cl,%dl
f0104cc9:	74 0a                	je     f0104cd5 <strchr+0x1f>
	for (; *s; s++)
f0104ccb:	83 c0 01             	add    $0x1,%eax
f0104cce:	eb f0                	jmp    f0104cc0 <strchr+0xa>
			return (char *) s;
	return 0;
f0104cd0:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104cd5:	5d                   	pop    %ebp
f0104cd6:	c3                   	ret    

f0104cd7 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0104cd7:	55                   	push   %ebp
f0104cd8:	89 e5                	mov    %esp,%ebp
f0104cda:	8b 45 08             	mov    0x8(%ebp),%eax
f0104cdd:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0104ce1:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0104ce4:	38 ca                	cmp    %cl,%dl
f0104ce6:	74 09                	je     f0104cf1 <strfind+0x1a>
f0104ce8:	84 d2                	test   %dl,%dl
f0104cea:	74 05                	je     f0104cf1 <strfind+0x1a>
	for (; *s; s++)
f0104cec:	83 c0 01             	add    $0x1,%eax
f0104cef:	eb f0                	jmp    f0104ce1 <strfind+0xa>
			break;
	return (char *) s;
}
f0104cf1:	5d                   	pop    %ebp
f0104cf2:	c3                   	ret    

f0104cf3 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0104cf3:	55                   	push   %ebp
f0104cf4:	89 e5                	mov    %esp,%ebp
f0104cf6:	57                   	push   %edi
f0104cf7:	56                   	push   %esi
f0104cf8:	53                   	push   %ebx
f0104cf9:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104cfc:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0104cff:	85 c9                	test   %ecx,%ecx
f0104d01:	74 31                	je     f0104d34 <memset+0x41>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0104d03:	89 f8                	mov    %edi,%eax
f0104d05:	09 c8                	or     %ecx,%eax
f0104d07:	a8 03                	test   $0x3,%al
f0104d09:	75 23                	jne    f0104d2e <memset+0x3b>
		c &= 0xFF;
f0104d0b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0104d0f:	89 d3                	mov    %edx,%ebx
f0104d11:	c1 e3 08             	shl    $0x8,%ebx
f0104d14:	89 d0                	mov    %edx,%eax
f0104d16:	c1 e0 18             	shl    $0x18,%eax
f0104d19:	89 d6                	mov    %edx,%esi
f0104d1b:	c1 e6 10             	shl    $0x10,%esi
f0104d1e:	09 f0                	or     %esi,%eax
f0104d20:	09 c2                	or     %eax,%edx
f0104d22:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0104d24:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f0104d27:	89 d0                	mov    %edx,%eax
f0104d29:	fc                   	cld    
f0104d2a:	f3 ab                	rep stos %eax,%es:(%edi)
f0104d2c:	eb 06                	jmp    f0104d34 <memset+0x41>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0104d2e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104d31:	fc                   	cld    
f0104d32:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0104d34:	89 f8                	mov    %edi,%eax
f0104d36:	5b                   	pop    %ebx
f0104d37:	5e                   	pop    %esi
f0104d38:	5f                   	pop    %edi
f0104d39:	5d                   	pop    %ebp
f0104d3a:	c3                   	ret    

f0104d3b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0104d3b:	55                   	push   %ebp
f0104d3c:	89 e5                	mov    %esp,%ebp
f0104d3e:	57                   	push   %edi
f0104d3f:	56                   	push   %esi
f0104d40:	8b 45 08             	mov    0x8(%ebp),%eax
f0104d43:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104d46:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0104d49:	39 c6                	cmp    %eax,%esi
f0104d4b:	73 32                	jae    f0104d7f <memmove+0x44>
f0104d4d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0104d50:	39 c2                	cmp    %eax,%edx
f0104d52:	76 2b                	jbe    f0104d7f <memmove+0x44>
		s += n;
		d += n;
f0104d54:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104d57:	89 fe                	mov    %edi,%esi
f0104d59:	09 ce                	or     %ecx,%esi
f0104d5b:	09 d6                	or     %edx,%esi
f0104d5d:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0104d63:	75 0e                	jne    f0104d73 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0104d65:	83 ef 04             	sub    $0x4,%edi
f0104d68:	8d 72 fc             	lea    -0x4(%edx),%esi
f0104d6b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f0104d6e:	fd                   	std    
f0104d6f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104d71:	eb 09                	jmp    f0104d7c <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0104d73:	83 ef 01             	sub    $0x1,%edi
f0104d76:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f0104d79:	fd                   	std    
f0104d7a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0104d7c:	fc                   	cld    
f0104d7d:	eb 1a                	jmp    f0104d99 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104d7f:	89 c2                	mov    %eax,%edx
f0104d81:	09 ca                	or     %ecx,%edx
f0104d83:	09 f2                	or     %esi,%edx
f0104d85:	f6 c2 03             	test   $0x3,%dl
f0104d88:	75 0a                	jne    f0104d94 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0104d8a:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f0104d8d:	89 c7                	mov    %eax,%edi
f0104d8f:	fc                   	cld    
f0104d90:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104d92:	eb 05                	jmp    f0104d99 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
f0104d94:	89 c7                	mov    %eax,%edi
f0104d96:	fc                   	cld    
f0104d97:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0104d99:	5e                   	pop    %esi
f0104d9a:	5f                   	pop    %edi
f0104d9b:	5d                   	pop    %ebp
f0104d9c:	c3                   	ret    

f0104d9d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0104d9d:	55                   	push   %ebp
f0104d9e:	89 e5                	mov    %esp,%ebp
f0104da0:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0104da3:	ff 75 10             	pushl  0x10(%ebp)
f0104da6:	ff 75 0c             	pushl  0xc(%ebp)
f0104da9:	ff 75 08             	pushl  0x8(%ebp)
f0104dac:	e8 8a ff ff ff       	call   f0104d3b <memmove>
}
f0104db1:	c9                   	leave  
f0104db2:	c3                   	ret    

f0104db3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0104db3:	55                   	push   %ebp
f0104db4:	89 e5                	mov    %esp,%ebp
f0104db6:	56                   	push   %esi
f0104db7:	53                   	push   %ebx
f0104db8:	8b 45 08             	mov    0x8(%ebp),%eax
f0104dbb:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104dbe:	89 c6                	mov    %eax,%esi
f0104dc0:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0104dc3:	39 f0                	cmp    %esi,%eax
f0104dc5:	74 1c                	je     f0104de3 <memcmp+0x30>
		if (*s1 != *s2)
f0104dc7:	0f b6 08             	movzbl (%eax),%ecx
f0104dca:	0f b6 1a             	movzbl (%edx),%ebx
f0104dcd:	38 d9                	cmp    %bl,%cl
f0104dcf:	75 08                	jne    f0104dd9 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f0104dd1:	83 c0 01             	add    $0x1,%eax
f0104dd4:	83 c2 01             	add    $0x1,%edx
f0104dd7:	eb ea                	jmp    f0104dc3 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
f0104dd9:	0f b6 c1             	movzbl %cl,%eax
f0104ddc:	0f b6 db             	movzbl %bl,%ebx
f0104ddf:	29 d8                	sub    %ebx,%eax
f0104de1:	eb 05                	jmp    f0104de8 <memcmp+0x35>
	}

	return 0;
f0104de3:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104de8:	5b                   	pop    %ebx
f0104de9:	5e                   	pop    %esi
f0104dea:	5d                   	pop    %ebp
f0104deb:	c3                   	ret    

f0104dec <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0104dec:	55                   	push   %ebp
f0104ded:	89 e5                	mov    %esp,%ebp
f0104def:	8b 45 08             	mov    0x8(%ebp),%eax
f0104df2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0104df5:	89 c2                	mov    %eax,%edx
f0104df7:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0104dfa:	39 d0                	cmp    %edx,%eax
f0104dfc:	73 09                	jae    f0104e07 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
f0104dfe:	38 08                	cmp    %cl,(%eax)
f0104e00:	74 05                	je     f0104e07 <memfind+0x1b>
	for (; s < ends; s++)
f0104e02:	83 c0 01             	add    $0x1,%eax
f0104e05:	eb f3                	jmp    f0104dfa <memfind+0xe>
			break;
	return (void *) s;
}
f0104e07:	5d                   	pop    %ebp
f0104e08:	c3                   	ret    

f0104e09 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0104e09:	55                   	push   %ebp
f0104e0a:	89 e5                	mov    %esp,%ebp
f0104e0c:	57                   	push   %edi
f0104e0d:	56                   	push   %esi
f0104e0e:	53                   	push   %ebx
f0104e0f:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104e12:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0104e15:	eb 03                	jmp    f0104e1a <strtol+0x11>
		s++;
f0104e17:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
f0104e1a:	0f b6 01             	movzbl (%ecx),%eax
f0104e1d:	3c 20                	cmp    $0x20,%al
f0104e1f:	74 f6                	je     f0104e17 <strtol+0xe>
f0104e21:	3c 09                	cmp    $0x9,%al
f0104e23:	74 f2                	je     f0104e17 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f0104e25:	3c 2b                	cmp    $0x2b,%al
f0104e27:	74 2a                	je     f0104e53 <strtol+0x4a>
	int neg = 0;
f0104e29:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f0104e2e:	3c 2d                	cmp    $0x2d,%al
f0104e30:	74 2b                	je     f0104e5d <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0104e32:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0104e38:	75 0f                	jne    f0104e49 <strtol+0x40>
f0104e3a:	80 39 30             	cmpb   $0x30,(%ecx)
f0104e3d:	74 28                	je     f0104e67 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0104e3f:	85 db                	test   %ebx,%ebx
f0104e41:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104e46:	0f 44 d8             	cmove  %eax,%ebx
f0104e49:	b8 00 00 00 00       	mov    $0x0,%eax
f0104e4e:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0104e51:	eb 50                	jmp    f0104ea3 <strtol+0x9a>
		s++;
f0104e53:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
f0104e56:	bf 00 00 00 00       	mov    $0x0,%edi
f0104e5b:	eb d5                	jmp    f0104e32 <strtol+0x29>
		s++, neg = 1;
f0104e5d:	83 c1 01             	add    $0x1,%ecx
f0104e60:	bf 01 00 00 00       	mov    $0x1,%edi
f0104e65:	eb cb                	jmp    f0104e32 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0104e67:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0104e6b:	74 0e                	je     f0104e7b <strtol+0x72>
	else if (base == 0 && s[0] == '0')
f0104e6d:	85 db                	test   %ebx,%ebx
f0104e6f:	75 d8                	jne    f0104e49 <strtol+0x40>
		s++, base = 8;
f0104e71:	83 c1 01             	add    $0x1,%ecx
f0104e74:	bb 08 00 00 00       	mov    $0x8,%ebx
f0104e79:	eb ce                	jmp    f0104e49 <strtol+0x40>
		s += 2, base = 16;
f0104e7b:	83 c1 02             	add    $0x2,%ecx
f0104e7e:	bb 10 00 00 00       	mov    $0x10,%ebx
f0104e83:	eb c4                	jmp    f0104e49 <strtol+0x40>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
f0104e85:	8d 72 9f             	lea    -0x61(%edx),%esi
f0104e88:	89 f3                	mov    %esi,%ebx
f0104e8a:	80 fb 19             	cmp    $0x19,%bl
f0104e8d:	77 29                	ja     f0104eb8 <strtol+0xaf>
			dig = *s - 'a' + 10;
f0104e8f:	0f be d2             	movsbl %dl,%edx
f0104e92:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0104e95:	3b 55 10             	cmp    0x10(%ebp),%edx
f0104e98:	7d 30                	jge    f0104eca <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
f0104e9a:	83 c1 01             	add    $0x1,%ecx
f0104e9d:	0f af 45 10          	imul   0x10(%ebp),%eax
f0104ea1:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f0104ea3:	0f b6 11             	movzbl (%ecx),%edx
f0104ea6:	8d 72 d0             	lea    -0x30(%edx),%esi
f0104ea9:	89 f3                	mov    %esi,%ebx
f0104eab:	80 fb 09             	cmp    $0x9,%bl
f0104eae:	77 d5                	ja     f0104e85 <strtol+0x7c>
			dig = *s - '0';
f0104eb0:	0f be d2             	movsbl %dl,%edx
f0104eb3:	83 ea 30             	sub    $0x30,%edx
f0104eb6:	eb dd                	jmp    f0104e95 <strtol+0x8c>
		else if (*s >= 'A' && *s <= 'Z')
f0104eb8:	8d 72 bf             	lea    -0x41(%edx),%esi
f0104ebb:	89 f3                	mov    %esi,%ebx
f0104ebd:	80 fb 19             	cmp    $0x19,%bl
f0104ec0:	77 08                	ja     f0104eca <strtol+0xc1>
			dig = *s - 'A' + 10;
f0104ec2:	0f be d2             	movsbl %dl,%edx
f0104ec5:	83 ea 37             	sub    $0x37,%edx
f0104ec8:	eb cb                	jmp    f0104e95 <strtol+0x8c>
		// we don't properly detect overflow!
	}

	if (endptr)
f0104eca:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0104ece:	74 05                	je     f0104ed5 <strtol+0xcc>
		*endptr = (char *) s;
f0104ed0:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104ed3:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f0104ed5:	89 c2                	mov    %eax,%edx
f0104ed7:	f7 da                	neg    %edx
f0104ed9:	85 ff                	test   %edi,%edi
f0104edb:	0f 45 c2             	cmovne %edx,%eax
}
f0104ede:	5b                   	pop    %ebx
f0104edf:	5e                   	pop    %esi
f0104ee0:	5f                   	pop    %edi
f0104ee1:	5d                   	pop    %ebp
f0104ee2:	c3                   	ret    
f0104ee3:	66 90                	xchg   %ax,%ax
f0104ee5:	66 90                	xchg   %ax,%ax
f0104ee7:	66 90                	xchg   %ax,%ax
f0104ee9:	66 90                	xchg   %ax,%ax
f0104eeb:	66 90                	xchg   %ax,%ax
f0104eed:	66 90                	xchg   %ax,%ax
f0104eef:	90                   	nop

f0104ef0 <__udivdi3>:
f0104ef0:	f3 0f 1e fb          	endbr32 
f0104ef4:	55                   	push   %ebp
f0104ef5:	57                   	push   %edi
f0104ef6:	56                   	push   %esi
f0104ef7:	53                   	push   %ebx
f0104ef8:	83 ec 1c             	sub    $0x1c,%esp
f0104efb:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f0104eff:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f0104f03:	8b 74 24 34          	mov    0x34(%esp),%esi
f0104f07:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f0104f0b:	85 d2                	test   %edx,%edx
f0104f0d:	75 49                	jne    f0104f58 <__udivdi3+0x68>
f0104f0f:	39 f3                	cmp    %esi,%ebx
f0104f11:	76 15                	jbe    f0104f28 <__udivdi3+0x38>
f0104f13:	31 ff                	xor    %edi,%edi
f0104f15:	89 e8                	mov    %ebp,%eax
f0104f17:	89 f2                	mov    %esi,%edx
f0104f19:	f7 f3                	div    %ebx
f0104f1b:	89 fa                	mov    %edi,%edx
f0104f1d:	83 c4 1c             	add    $0x1c,%esp
f0104f20:	5b                   	pop    %ebx
f0104f21:	5e                   	pop    %esi
f0104f22:	5f                   	pop    %edi
f0104f23:	5d                   	pop    %ebp
f0104f24:	c3                   	ret    
f0104f25:	8d 76 00             	lea    0x0(%esi),%esi
f0104f28:	89 d9                	mov    %ebx,%ecx
f0104f2a:	85 db                	test   %ebx,%ebx
f0104f2c:	75 0b                	jne    f0104f39 <__udivdi3+0x49>
f0104f2e:	b8 01 00 00 00       	mov    $0x1,%eax
f0104f33:	31 d2                	xor    %edx,%edx
f0104f35:	f7 f3                	div    %ebx
f0104f37:	89 c1                	mov    %eax,%ecx
f0104f39:	31 d2                	xor    %edx,%edx
f0104f3b:	89 f0                	mov    %esi,%eax
f0104f3d:	f7 f1                	div    %ecx
f0104f3f:	89 c6                	mov    %eax,%esi
f0104f41:	89 e8                	mov    %ebp,%eax
f0104f43:	89 f7                	mov    %esi,%edi
f0104f45:	f7 f1                	div    %ecx
f0104f47:	89 fa                	mov    %edi,%edx
f0104f49:	83 c4 1c             	add    $0x1c,%esp
f0104f4c:	5b                   	pop    %ebx
f0104f4d:	5e                   	pop    %esi
f0104f4e:	5f                   	pop    %edi
f0104f4f:	5d                   	pop    %ebp
f0104f50:	c3                   	ret    
f0104f51:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0104f58:	39 f2                	cmp    %esi,%edx
f0104f5a:	77 1c                	ja     f0104f78 <__udivdi3+0x88>
f0104f5c:	0f bd fa             	bsr    %edx,%edi
f0104f5f:	83 f7 1f             	xor    $0x1f,%edi
f0104f62:	75 2c                	jne    f0104f90 <__udivdi3+0xa0>
f0104f64:	39 f2                	cmp    %esi,%edx
f0104f66:	72 06                	jb     f0104f6e <__udivdi3+0x7e>
f0104f68:	31 c0                	xor    %eax,%eax
f0104f6a:	39 eb                	cmp    %ebp,%ebx
f0104f6c:	77 ad                	ja     f0104f1b <__udivdi3+0x2b>
f0104f6e:	b8 01 00 00 00       	mov    $0x1,%eax
f0104f73:	eb a6                	jmp    f0104f1b <__udivdi3+0x2b>
f0104f75:	8d 76 00             	lea    0x0(%esi),%esi
f0104f78:	31 ff                	xor    %edi,%edi
f0104f7a:	31 c0                	xor    %eax,%eax
f0104f7c:	89 fa                	mov    %edi,%edx
f0104f7e:	83 c4 1c             	add    $0x1c,%esp
f0104f81:	5b                   	pop    %ebx
f0104f82:	5e                   	pop    %esi
f0104f83:	5f                   	pop    %edi
f0104f84:	5d                   	pop    %ebp
f0104f85:	c3                   	ret    
f0104f86:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0104f8d:	8d 76 00             	lea    0x0(%esi),%esi
f0104f90:	89 f9                	mov    %edi,%ecx
f0104f92:	b8 20 00 00 00       	mov    $0x20,%eax
f0104f97:	29 f8                	sub    %edi,%eax
f0104f99:	d3 e2                	shl    %cl,%edx
f0104f9b:	89 54 24 08          	mov    %edx,0x8(%esp)
f0104f9f:	89 c1                	mov    %eax,%ecx
f0104fa1:	89 da                	mov    %ebx,%edx
f0104fa3:	d3 ea                	shr    %cl,%edx
f0104fa5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0104fa9:	09 d1                	or     %edx,%ecx
f0104fab:	89 f2                	mov    %esi,%edx
f0104fad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0104fb1:	89 f9                	mov    %edi,%ecx
f0104fb3:	d3 e3                	shl    %cl,%ebx
f0104fb5:	89 c1                	mov    %eax,%ecx
f0104fb7:	d3 ea                	shr    %cl,%edx
f0104fb9:	89 f9                	mov    %edi,%ecx
f0104fbb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0104fbf:	89 eb                	mov    %ebp,%ebx
f0104fc1:	d3 e6                	shl    %cl,%esi
f0104fc3:	89 c1                	mov    %eax,%ecx
f0104fc5:	d3 eb                	shr    %cl,%ebx
f0104fc7:	09 de                	or     %ebx,%esi
f0104fc9:	89 f0                	mov    %esi,%eax
f0104fcb:	f7 74 24 08          	divl   0x8(%esp)
f0104fcf:	89 d6                	mov    %edx,%esi
f0104fd1:	89 c3                	mov    %eax,%ebx
f0104fd3:	f7 64 24 0c          	mull   0xc(%esp)
f0104fd7:	39 d6                	cmp    %edx,%esi
f0104fd9:	72 15                	jb     f0104ff0 <__udivdi3+0x100>
f0104fdb:	89 f9                	mov    %edi,%ecx
f0104fdd:	d3 e5                	shl    %cl,%ebp
f0104fdf:	39 c5                	cmp    %eax,%ebp
f0104fe1:	73 04                	jae    f0104fe7 <__udivdi3+0xf7>
f0104fe3:	39 d6                	cmp    %edx,%esi
f0104fe5:	74 09                	je     f0104ff0 <__udivdi3+0x100>
f0104fe7:	89 d8                	mov    %ebx,%eax
f0104fe9:	31 ff                	xor    %edi,%edi
f0104feb:	e9 2b ff ff ff       	jmp    f0104f1b <__udivdi3+0x2b>
f0104ff0:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0104ff3:	31 ff                	xor    %edi,%edi
f0104ff5:	e9 21 ff ff ff       	jmp    f0104f1b <__udivdi3+0x2b>
f0104ffa:	66 90                	xchg   %ax,%ax
f0104ffc:	66 90                	xchg   %ax,%ax
f0104ffe:	66 90                	xchg   %ax,%ax

f0105000 <__umoddi3>:
f0105000:	f3 0f 1e fb          	endbr32 
f0105004:	55                   	push   %ebp
f0105005:	57                   	push   %edi
f0105006:	56                   	push   %esi
f0105007:	53                   	push   %ebx
f0105008:	83 ec 1c             	sub    $0x1c,%esp
f010500b:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f010500f:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f0105013:	8b 74 24 30          	mov    0x30(%esp),%esi
f0105017:	8b 7c 24 38          	mov    0x38(%esp),%edi
f010501b:	89 da                	mov    %ebx,%edx
f010501d:	85 c0                	test   %eax,%eax
f010501f:	75 3f                	jne    f0105060 <__umoddi3+0x60>
f0105021:	39 df                	cmp    %ebx,%edi
f0105023:	76 13                	jbe    f0105038 <__umoddi3+0x38>
f0105025:	89 f0                	mov    %esi,%eax
f0105027:	f7 f7                	div    %edi
f0105029:	89 d0                	mov    %edx,%eax
f010502b:	31 d2                	xor    %edx,%edx
f010502d:	83 c4 1c             	add    $0x1c,%esp
f0105030:	5b                   	pop    %ebx
f0105031:	5e                   	pop    %esi
f0105032:	5f                   	pop    %edi
f0105033:	5d                   	pop    %ebp
f0105034:	c3                   	ret    
f0105035:	8d 76 00             	lea    0x0(%esi),%esi
f0105038:	89 fd                	mov    %edi,%ebp
f010503a:	85 ff                	test   %edi,%edi
f010503c:	75 0b                	jne    f0105049 <__umoddi3+0x49>
f010503e:	b8 01 00 00 00       	mov    $0x1,%eax
f0105043:	31 d2                	xor    %edx,%edx
f0105045:	f7 f7                	div    %edi
f0105047:	89 c5                	mov    %eax,%ebp
f0105049:	89 d8                	mov    %ebx,%eax
f010504b:	31 d2                	xor    %edx,%edx
f010504d:	f7 f5                	div    %ebp
f010504f:	89 f0                	mov    %esi,%eax
f0105051:	f7 f5                	div    %ebp
f0105053:	89 d0                	mov    %edx,%eax
f0105055:	eb d4                	jmp    f010502b <__umoddi3+0x2b>
f0105057:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f010505e:	66 90                	xchg   %ax,%ax
f0105060:	89 f1                	mov    %esi,%ecx
f0105062:	39 d8                	cmp    %ebx,%eax
f0105064:	76 0a                	jbe    f0105070 <__umoddi3+0x70>
f0105066:	89 f0                	mov    %esi,%eax
f0105068:	83 c4 1c             	add    $0x1c,%esp
f010506b:	5b                   	pop    %ebx
f010506c:	5e                   	pop    %esi
f010506d:	5f                   	pop    %edi
f010506e:	5d                   	pop    %ebp
f010506f:	c3                   	ret    
f0105070:	0f bd e8             	bsr    %eax,%ebp
f0105073:	83 f5 1f             	xor    $0x1f,%ebp
f0105076:	75 20                	jne    f0105098 <__umoddi3+0x98>
f0105078:	39 d8                	cmp    %ebx,%eax
f010507a:	0f 82 b0 00 00 00    	jb     f0105130 <__umoddi3+0x130>
f0105080:	39 f7                	cmp    %esi,%edi
f0105082:	0f 86 a8 00 00 00    	jbe    f0105130 <__umoddi3+0x130>
f0105088:	89 c8                	mov    %ecx,%eax
f010508a:	83 c4 1c             	add    $0x1c,%esp
f010508d:	5b                   	pop    %ebx
f010508e:	5e                   	pop    %esi
f010508f:	5f                   	pop    %edi
f0105090:	5d                   	pop    %ebp
f0105091:	c3                   	ret    
f0105092:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0105098:	89 e9                	mov    %ebp,%ecx
f010509a:	ba 20 00 00 00       	mov    $0x20,%edx
f010509f:	29 ea                	sub    %ebp,%edx
f01050a1:	d3 e0                	shl    %cl,%eax
f01050a3:	89 44 24 08          	mov    %eax,0x8(%esp)
f01050a7:	89 d1                	mov    %edx,%ecx
f01050a9:	89 f8                	mov    %edi,%eax
f01050ab:	d3 e8                	shr    %cl,%eax
f01050ad:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f01050b1:	89 54 24 04          	mov    %edx,0x4(%esp)
f01050b5:	8b 54 24 04          	mov    0x4(%esp),%edx
f01050b9:	09 c1                	or     %eax,%ecx
f01050bb:	89 d8                	mov    %ebx,%eax
f01050bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01050c1:	89 e9                	mov    %ebp,%ecx
f01050c3:	d3 e7                	shl    %cl,%edi
f01050c5:	89 d1                	mov    %edx,%ecx
f01050c7:	d3 e8                	shr    %cl,%eax
f01050c9:	89 e9                	mov    %ebp,%ecx
f01050cb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01050cf:	d3 e3                	shl    %cl,%ebx
f01050d1:	89 c7                	mov    %eax,%edi
f01050d3:	89 d1                	mov    %edx,%ecx
f01050d5:	89 f0                	mov    %esi,%eax
f01050d7:	d3 e8                	shr    %cl,%eax
f01050d9:	89 e9                	mov    %ebp,%ecx
f01050db:	89 fa                	mov    %edi,%edx
f01050dd:	d3 e6                	shl    %cl,%esi
f01050df:	09 d8                	or     %ebx,%eax
f01050e1:	f7 74 24 08          	divl   0x8(%esp)
f01050e5:	89 d1                	mov    %edx,%ecx
f01050e7:	89 f3                	mov    %esi,%ebx
f01050e9:	f7 64 24 0c          	mull   0xc(%esp)
f01050ed:	89 c6                	mov    %eax,%esi
f01050ef:	89 d7                	mov    %edx,%edi
f01050f1:	39 d1                	cmp    %edx,%ecx
f01050f3:	72 06                	jb     f01050fb <__umoddi3+0xfb>
f01050f5:	75 10                	jne    f0105107 <__umoddi3+0x107>
f01050f7:	39 c3                	cmp    %eax,%ebx
f01050f9:	73 0c                	jae    f0105107 <__umoddi3+0x107>
f01050fb:	2b 44 24 0c          	sub    0xc(%esp),%eax
f01050ff:	1b 54 24 08          	sbb    0x8(%esp),%edx
f0105103:	89 d7                	mov    %edx,%edi
f0105105:	89 c6                	mov    %eax,%esi
f0105107:	89 ca                	mov    %ecx,%edx
f0105109:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f010510e:	29 f3                	sub    %esi,%ebx
f0105110:	19 fa                	sbb    %edi,%edx
f0105112:	89 d0                	mov    %edx,%eax
f0105114:	d3 e0                	shl    %cl,%eax
f0105116:	89 e9                	mov    %ebp,%ecx
f0105118:	d3 eb                	shr    %cl,%ebx
f010511a:	d3 ea                	shr    %cl,%edx
f010511c:	09 d8                	or     %ebx,%eax
f010511e:	83 c4 1c             	add    $0x1c,%esp
f0105121:	5b                   	pop    %ebx
f0105122:	5e                   	pop    %esi
f0105123:	5f                   	pop    %edi
f0105124:	5d                   	pop    %ebp
f0105125:	c3                   	ret    
f0105126:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f010512d:	8d 76 00             	lea    0x0(%esi),%esi
f0105130:	89 da                	mov    %ebx,%edx
f0105132:	29 fe                	sub    %edi,%esi
f0105134:	19 c2                	sbb    %eax,%edx
f0105136:	89 f1                	mov    %esi,%ecx
f0105138:	89 c8                	mov    %ecx,%eax
f010513a:	e9 4b ff ff ff       	jmp    f010508a <__umoddi3+0x8a>
