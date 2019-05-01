// implement fork from user space

#include <inc/string.h>
#include <inc/lib.h>

// PTE_COW marks copy-on-write page table entries.
// It is one of the bits explicitly allocated to user processes (PTE_AVAIL).
#define PTE_COW		0x800

//
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
	void *addr = (void *) utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	int r;

	// Check that the faulting access was (1) a write, and (2) to a
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(err & FEC_WR) || !(uvpt[PGNUM(addr)] & PTE_COW))
		panic("pgfault: invalid user trap frame");


	// Allocate a new page, map it at a temporary location (PFTEMP),
	// copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	envid_t envid = sys_getenvid();
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P|PTE_W|PTE_U);
	if (r < 0) 
		panic("pgfault: page allocation failed %e", r);

	addr = ROUNDDOWN(addr, PGSIZE);
	memmove(PFTEMP, addr, PGSIZE);
    if ((r = sys_page_unmap(envid, addr)) < 0)
        panic("pgfault: page unmap failed (%e)", r);
    if ((r = sys_page_map(envid, PFTEMP, envid, addr, PTE_P | PTE_W |PTE_U)) < 0)
        panic("pgfault: page map failed (%e)", r);
    if ((r = sys_page_unmap(envid, PFTEMP)) < 0)
        panic("pgfault: page unmap failed (%e)", r);

//	panic("pgfault not implemented");
}

//
// Map our virtual page pn (address pn*PGSIZE) into the target envid
// at the same virtual address.  If the page is writable or copy-on-write,
// the new mapping must be created copy-on-write, and then our mapping must be
// marked copy-on-write as well.  (Exercise: Why do we need to mark ours
// copy-on-write again if it was already copy-on-write at the beginning of
// this function?)
//
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
	int r;

	// LAB 4: Your code here.
//	envid_t p_eid = sys_getenvid();
//	pte_t pte = uvpt[pn];
//	int perm = PTE_U|PTE_P;
//	void *va = (void *)(pn * PGSIZE);

//	if (pte & PTE_W || pte & PTE_COW)
//		perm |= PTE_COW;
	
//	perm &= PTE_SYSCALL;
//	if ((r = sys_page_map(p_eid, va, envid, va, perm)) < 0)
//		return r;
	
//	if (perm & PTE_COW) {
//		if ((r = sys_page_map(p_eid, va, p_eid, va, perm)) < 0)
//			return r; 
//	}

	envid_t this_env_id = sys_getenvid();
    void * va = (void *)(pn * PGSIZE);

    int perm = uvpt[pn] & 0xFFF;
    if ( (perm & PTE_W) || (perm & PTE_COW) ) {
        // marked as COW and read-only
        perm |= PTE_COW;
        perm &= ~PTE_W;
    }
    // IMPORTANT: adjust permission to the syscall
    perm &= PTE_SYSCALL;
    // cprintf("fromenvid = %x, toenvid = %x, dup page %d, addr = %08p, perm = %03x\n",this_env_id, envid, pn, va, perm);
    if((r = sys_page_map(this_env_id, va, envid, va, perm)) < 0)
        panic("duppage: %e",r);
    if((r = sys_page_map(this_env_id, va, this_env_id, va, perm)) < 0)
        panic("duppage: %e",r);
//	panic("duppage not implemented");
	return 0;
}

//
// User-level fork with copy-on-write.
// Set up our page fault handler appropriately.
// Create a child.
// Copy our address space and page fault handler setup to the child.
// Then mark the child as runnable and return.
//
// Returns: child's envid to the parent, 0 to the child, < 0 on error.
// It is also OK to panic on error.
//
// Hint:
//   Use uvpd, uvpt, and duppage.
//   Remember to fix "thisenv" in the child process.
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
	envid_t e_id = sys_exofork();
	if (e_id < 0) panic("fork: %e", e_id);
	if (e_id == 0) {
		 thisenv = &envs[ENVX(sys_getenvid())];
		 return 0;
	}
	
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {
		if (((uvpd[PDX(addr)]) & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)) {
			 duppage(e_id, PGNUM(addr));
		}
	} 

	int r = sys_page_alloc(e_id, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P);
	if (r < 0) 
		panic("fork: %e", r);
	
	extern void _pgfault_upcall();
	r = sys_env_set_pgfault_upcall(e_id, _pgfault_upcall);
	if (r < 0) 
		panic("fork: set upcall for child failed, %e", r);

	r = sys_env_set_status(e_id, ENV_RUNNABLE);
	if (r < 0) 
		panic("fork: env_set_status failed: %e", r);
		 
	return e_id;
		 
	
//	panic("fork not implemented");
}

// Challenge!
int
sfork(void)
{
	panic("sfork not implemented");
	return -E_INVAL;
}