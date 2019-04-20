/* See COPYRIGHT for copyright information. */

#include <inc/mmu.h>
#include <inc/memlayout.h>
#include <inc/trap.h>

#include <kern/picirq.h>


###################################################################
# exceptions/interrupts
###################################################################

/* TRAPHANDLER defines a globally-visible function for handling a trap.
 * It pushes a trap number onto the stack, then jumps to _alltraps.
 * Use TRAPHANDLER for traps where the CPU automatically pushes an error code.
 *
 * You shouldn't call a TRAPHANDLER function from C, but you may
 * need to _declare_ one in C (for instance, to get a function pointer
 * during IDT setup).  You can declare the function with
 *   void NAME();
 * where NAME is the argument passed to TRAPHANDLER.
 */
#define TRAPHANDLER(name, num)						\
	.globl name;		/* define global symbol for 'name' */	\
	.type name, @function;	/* symbol type is function */		\
	.align 2;		/* align function definition */		\
	name:			/* function starts here */		\
	pushl $(num);							\
	jmp _alltraps

/* Use TRAPHANDLER_NOEC for traps where the CPU doesn't push an error code.
 * It pushes a 0 in place of the error code, so the trap frame has the same
 * format in either case.
 */
#define TRAPHANDLER_NOEC(name, num)					\
	.globl name;							\
	.type name, @function;						\
	.align 2;							\
	name:								\
	pushl $0;							\
	pushl $(num);							\
	jmp _alltraps

.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
TRAPHANDLER_NOEC(traphandler0, T_DIVIDE)
TRAPHANDLER_NOEC(traphandler1, T_DEBUG)
TRAPHANDLER_NOEC(traphandler2, T_NMI)
TRAPHANDLER_NOEC(traphandler3, T_BRKPT)
TRAPHANDLER_NOEC(traphandler4, T_OFLOW)
TRAPHANDLER_NOEC(traphandler5, T_BOUND)
TRAPHANDLER_NOEC(traphandler6, T_ILLOP)
TRAPHANDLER_NOEC(traphandler7, T_DEVICE)
TRAPHANDLER(traphandler8, T_DBLFLT)
// 9 deprecated since 386
TRAPHANDLER(traphandler10, T_TSS)
TRAPHANDLER(traphandler11, T_SEGNP)
TRAPHANDLER(traphandler12, T_STACK)
TRAPHANDLER(traphandler13, T_GPFLT)
TRAPHANDLER(traphandler14, T_PGFLT)
// 15 reserved by intel
TRAPHANDLER_NOEC(traphandler16, T_FPERR)
TRAPHANDLER(traphandler17, T_ALIGN)
TRAPHANDLER_NOEC(traphandler18, T_MCHK)
TRAPHANDLER_NOEC(traphandler19, T_SIMDERR)

// system call (interrupt)
TRAPHANDLER_NOEC(traphandler48, T_SYSCALL)
TRAPHANDLER_NOEC(traphandler500, T_DEFAULT)	

/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
	pushl %ds	
	pushl %es	
	pushal
	
	movw $GD_KD, %ax
	movw %ax, %ds
	movw %ax, %es
	pushl %esp
	call trap


/*
 * Lab 3: Your code here for _alltraps
 */

