;==================================================================================================
; Towers of Hanoi
;==================================================================================================

TOHMOVES equ		$9000	

start_hanoi:

	LD		a, DISKS
	LD		b, 'A'		; A is source
	LD		c, 'B'		; B is target
	LD		d, 'C'		; C is intermediate
	LD		hl, TOHMOVES

hanoi:
	OR		a			; stop recursion, if 0
	RET		z

	DEC		a
	PUSH	af
	PUSH	bc
	PUSH	de
	LD		e, c
	LD		c, d
	LD		d, e
	CALL	hanoi		; recursion
	POP		de
	POP		bc
	POP		af

	LD		(hl), b
	INC 	hl
	LD		(hl), c
	INC     hl

	LD		e, b
	LD		b, d
	LD		d, e
	JR		hanoi

hanoir:	DB "ACABCBACBABCACAB"
		DB "CBCABACBACABCBAC"
		DB "BABCACBACBCABABC"
		DB "ACABCBACBABCACAB"
		DB "CBCABACBACABCBCA"
		DB "BABCACBACBCABACB"
		DB "ACABCBACBCBCACAB"
		DB "CBCABACBACABCB", 0

