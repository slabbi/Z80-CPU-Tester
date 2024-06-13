;==================================================================================================
; Z80 CPU Tester
;
; v1.1.7
;
; Requires hardware v1 with 32kb EPROM/EEPROM and 32kb SRAM
;
; Software:
; - CPU identification
; - tests a few commands (these tests are not really thorough and well thought out 
;   and should only be considered as proof of concept)
;
;  CPU_CLONE = NEC clones only
;
; After a successfull test it shows the result:
;
; Port B:
; STATUS: CU00tttt (C = CMOS, U = UB880, tttt = type)
; Z80= 0000, Z180= 0001, Z280= 0010, EZ80= 0011, U880= 0100, Clone= 0101
; An identified UB880 displays [0100 0100}.
;
; Port A:
; Counts the performed tests.
; When done either 
; - the number of the failed test is displayed with a blinking bit 7, or 
; - a running light shows a successfull result.
;
; Some math functions from https://learn.cemetech.net/index.php/Z80:Math_Routines
;
;==================================================================================================

; some constants

CPU_Z80				EQU		0
CPU_Z180			EQU 	1
CPU_Z280			EQU		2
CPU_EZ80			EQU 	3
CPU_U880NEW			EQU		4
CPU_U880OLD			EQU 	5
CPU_SHARPLH5080A	EQU		6
CPU_NMOSZ80			EQU		7
CPU_NECD780C		EQU		8
CPU_KR1858VM1		EQU		9
CPU_NMOSUNKNOWN		EQU		10
CPU_CMOSZ80			EQU		11
CPU_TOSHIBA			EQU		12
CPU_NECD70008AC		EQU		13
CPU_CMOSUNKNOWN		EQU		14
CPU_NEC_CL			EQU		15
CPU_ERROR			EQU		16



PORTA		EQU		11111110B	; A0 = L / Bit 0 = L
PORTB		EQU		11111101B	; A1 = L / Bit 1 = L

PIDIGITS	EQU		100			; number of digits to compute
DISKS		EQU 	6			; number of disks to move


; some vars in ram

Z80TYPE		EQU		$8000
ISCMOS		EQU		$8001
ISU880		EQU		$8002
COUNTER		EQU		$8003
LOCKED		EQU		$8004

XFYFCOUNT:	EQU		$8010	; 4 bytes
XFCOUNT:	EQU 	$8014	; 2 bytes
YFCOUNT:	EQU 	$8016	; 2 bytes
XYRESULT:	EQU		$8018	; 1 byte

; used in mul32

var_x 		EQU 	$9000
var_y 		EQU 	$9004
var_z 		EQU		$9008
var_z0 		EQU		$9008
var_z2 		EQU		$900c

; some macros

SETLEDA MACRO lednr 
        LD      c, PORTA
        LD      a, lednr
        OUT     (c),a
        ENDM

SETLEDB MACRO lednr 
        LD      c, PORTB
        LD      a, lednr
        OUT     (c),a
        ENDM

MEMCPY 	MACRO bytes
		LOCAL	loop
		LD      b, bytes
loop:	LD		a, (hl)
		LD		(de), a
		INC		hl
		INC		de
		DJNZ	loop
		ENDM

MEMCMP	MACRO bytes, label
		LOCAL	loop
		LD		b, bytes
loop:	LD		a, (de)
		CP		(hl)
		JP		nz, label
		INC		hl
		INC		de
		DJNZ	loop
		ENDM

;--------------------------------------------------------------------------------------------------
; NO FLASH = NMOS
;--------------------------------------------------------------------------------------------------
		ORG $0000				; RESET vector

reset:  DI						; disable interrupts
		JP		start			; jump to start
		
		ORG $0038				; INT vector

int:	RETI					; interrupt not used

		ORG $0066				; NMI vector

nmi:	DI						; disable interrupts
		PUSH	af
		LD		a, (LOCKED)
		CP		0
		JR		z, donmi
		POP		af
		RETN

donmi:	
		LD		a, $ff
		LD		(LOCKED), a
		PUSH	bc
		PUSH    de
		PUSH	hl
		CALL	nmifunction
		POP     hl
		POP		de
		POP		bc
		XOR		a
		LD		(LOCKED), a
		POP		af
		RETN

start:							; program starts here
		IM		1				; interrupt mode 1
		LD		sp, $ffff		; set stack
		SETLEDA 0				; port A off
		SETLEDB 0				; port b off
		XOR		a
		LD 		hl, 0
		LD		(Z80TYPE), a
		LD		(ISCMOS), a
		LD		(ISU880), a
		LD		(COUNTER), a
		LD		(XFYFCOUNT), hl
		LD		(XFYFCOUNT+2), hl
		LD		(XFCOUNT), hl
		LD		(YFCOUNT), hl
		LD		(XYRESULT), a
		LD		(LOCKED), a
		
;--------------------------------------------------------------------------------------------------
; CHECK CMOS/NMOS / sets ISCMOS flag
;--------------------------------------------------------------------------------------------------

        LD      c, 0
;       out     (c),0
        defb    $ed, $71      	; CMOS = $FF; NMOS = $00
		NOP
		IN		a,(c)

		JP		z, isnmos		; $00, so it is NMOS
		LD		hl, ISCMOS
		LD		(hl), $ff
isnmos:
		SETLEDA 0
		
;--------------------------------------------------------------------------------------------------
; CHECK eZ80
;--------------------------------------------------------------------------------------------------

startident:

		XOR		a
		LD		e,e				; this is .LIL command on eZ80
		LD		hl, 0   		; part of long load on eZ80 only
		INC		a				; part of long load on eZ80 only
		
		LD		d, CPU_EZ80		; d = CPU type, assuming it is EZ880
		JP		z, iddone		; yes, it is a EZ880

;--------------------------------------------------------------------------------------------------
; CHECK Z180
;--------------------------------------------------------------------------------------------------

		XOR		a
		DEC		a
		DAA						; Z180 returns $f9, Z80 returns $99
		CP		$f9				; is Z180?
		LD		d, CPU_Z180
		JP		z, iddone		; yes, it is a Z180

		LD		a, $40
		defb 	$cb, $37		; from the Z280 data book
		JP		p, z280_detected	; yes, it is a Z280

;--------------------------------------------------------------------------------------------------
; CHECK U880 / sets U880 flag
;--------------------------------------------------------------------------------------------------

		LD		hl, ISU880
		LD		(hl), $ff

        LD      hl,$ffff
        LD      bc,$180a
        SCF
        OUTI
        JP      c, xyident	; yes, it is a UB880, skip other tests

		LD		hl, ISU880
		LD		(hl), 0

		JR		xyident

z280_detected:
		LD		d, CPU_Z280		; Z280 identified
		JP		iddone

;--------------------------------------------------------------------------------------------------
; XF/YF identification
; Tests from https://github.com/skiselev/z80-tests/
;--------------------------------------------------------------------------------------------------

xyident:
		CALL	testxy		

		LD		d, CPU_ERROR	; should never happen, helps to identify not catched CPUs
		
		LD		hl, XYRESULT
		LD		(hl), a

		LD		a, (ISU880)
		CP		0				; is U880?
		JR		z, checkz80		; it is a Z80
		
		LD		a, (XYRESULT)	; U880
		CP		$ff				; is XF/YF always set?
		LD		d, CPU_U880NEW
		JP		z, iddone
		LD		d, CPU_U880OLD
		JP		iddone

checkz80:
		LD		a, (ISCMOS)
		CP		0				; is CMOS?
		JR		nz, checkcmos	; yes, it is CMOS

; check for Sharp LH5080A

		LD		a, (XYRESULT)
		CP		$30
		JP		z, SHARPLH5080A
		CP 		$FF				; does it always set XF/YF?
		JP		z, NMOSZ80
		CP		$fd				; does it sometimes not set XF when FLAGS.3=1?
		JP		z, NECU780C
		CP		$f4
		JP		z, KR1858VM1

;--------------------------------------------------------------------------------------------------
; CHECK Z80 vs CLONE / [ S | Z | YF | H || XF | P/V | N | C ]
;--------------------------------------------------------------------------------------------------

		LD		bc, $00ff
		PUSH	bc
		POP		af				; F is now 0xFF, A is 0 -> now play with XF and YF
		SCF						; will give 0 for NEC clones, 28 for Zilog
		NOP						; (Turbo R will also show 28)
		PUSH	af
		pop		bc				; get AF register
		LD		a,c
		AND		$28				; check $28
		CP		$28

		LD		d, CPU_NEC_CL
		JR		nz, iddone

		LD		D, CPU_NMOSUNKNOWN
		JP		iddone

SHARPLH5080A:
		LD		d, CPU_SHARPLH5080A
		JP		iddone
NMOSZ80:
		LD		d, CPU_NMOSZ80
		JP		iddone
NECU780C:
		LD		d, CPU_NECD780C
		JP		iddone
KR1858VM1:
		LD		d, CPU_KR1858VM1
		JP		iddone


checkcmos:
		LD		a, (XYRESULT)
		CP		$ff				; does it always set XF/YF?
		JR		z, CMOSZ80
		CP		$3f				; does it never set YF when A.5=1?
		JR		z, TOSHIBA

		CP		$20				; YF is often set when A.5=1?
		JR		nc, CMOSUNKNOWN	; XYRESULT > 1Fh, not a NEC...
		AND		$0f				; F.5=1 & A.5=0 and F.3=1 & A.3=0 results
		CP		$03				; F.5=1 & A.5=0 never result in YF set?
		JR		c, CMOSUNKNOWN
		AND		$03				; F.3=1 & A.3=0 results
		JR		nz, NEC

CMOSUNKNOWN:	
		LD 		d, CPU_CMOSUNKNOWN
		JP		iddone
CMOSZ80:
		LD 		d, CPU_CMOSZ80
		JP		iddone
TOSHIBA:
		LD		d, CPU_TOSHIBA
		JP		iddone
NEC:
		LD		d, CPU_NECD70008AC
		JP		iddone

		NOP

iddone:
		LD		hl, Z80TYPE
		LD		(hl), d
		
		CALL 	prettyprint		; the functions will take a while, so output the result on port B


;==================================================================================================
; CPU Function Tests
;
; It was planned to use the "Frank Cringle's Z80 instruction set exerciser".
; It seems not to work properly here, so I execure some Z80 code. It does not test
; all functions completely but it should catch some bad CPUs.
; There are 32kb rom and 32kb ram available, so please feel free to add/contribute some 
; reasonable code.
;==================================================================================================

		LD		hl, COUNTER
		LD 		(hl), 0

;----------------------------------------------------------------------
; 1: test memory access, 16 bit register load
;----------------------------------------------------------------------
		
test1:
		CALL 	inccnt
		LD		hl, $8101
		LD		de, $8102
		LD		bc,	$8103

		XOR		a				; clear 3 bytes
		LD		(hl), a
		LD		(de), a
		LD		(bc), a
		CP		(hl)			; first byte = 0?
		JP		nz, error
		INC		hl
		CP		(hl)			; second byte = 0?
		JP		nz, error
		INC		hl
		CP		(hl)			; third byte = 0?
		JP		nz, error

		LD		hl, $8101		; now a simple pattern
		LD		de, $8102
		LD		bc,	$8103
		
		LD		a, 10101010B
		LD		(hl), a         ; first byte = pattern?
		LD		(de), a         
		LD		(bc), a         
		CP		(hl)            ; second byte = pattern?
		JP		nz, error       
		INC		hl              
		CP		(hl)            ; third byte = pattern?
		JP		nz, error
		INC		hl
		CP		(hl)
		JP		nz, error

;----------------------------------------------------------------------
; 2: test RL, RR, register to register load
;----------------------------------------------------------------------

test2:
		CALL 	inccnt
		XOR		a
		LD		a, 1			; 1
		RL		a				
		LD		b, a			; 2
		RL		b	
		LD		c, b			; 4
		RL		c	
		LD		h, c			; 8
		RL		h	
		LD		l, h			; 16
		RL		l	
		LD		d, l			; 32
		RL		d	
		LD		e, d			; 64
		RL		e
		LD		a, e			; 128
		RL		a				; rotate into carry
		JP		nc, error
		
		RR		a
		LD		b, a            ; 128
		RR		b
		LD		c, b            ; 64
		RR		c
		LD		h, c            ; 32
		RR		h
		LD		l, h            ; 16
		RR		l
		LD		d, l            ; 8
		RR		d
		LD		e, d            ; 4
		RR		e
		LD		a, e            ; 2
		RR		a
		CP		1				; shoult be 1
		JP		nz, error		; no

;----------------------------------------------------------------------
; 3: test ADD, SUB
;----------------------------------------------------------------------

test3:
		CALL 	inccnt
		XOR		a
		ADD     01010101B
		CP		01010101B
		JP		NZ, error
		ADD		10101010B
		CP		$ff
		JP		NZ, error
		SUB		$0f
		CP		$f0
		JP		NZ, error
		SUB		$f0
		CP		$00
		JP		NZ, error

;----------------------------------------------------------------------
; 4: test PUSH, POP, 16 bit SBC
;----------------------------------------------------------------------

test4:
		CALL 	inccnt
		LD		hl, $1234
		LD		bc, 0
		PUSH	hl
		POP		bc
		XOR		a
		SBC		hl, bc
		JP		nz, error

		LD		hl, $4321
		LD		de, 0
		PUSH	hl
		POP		de
		XOR		a
		SBC		hl, de
		JP		nz, error

		LD		hl, $4321
		XOR		a
		SBC		hl, hl
		JP		nz, error

;----------------------------------------------------------------------
; 5: test sub, add, inc, dec
;----------------------------------------------------------------------

test5:
		CALL 	inccnt
		LD		hl, $0102
		LD		de, $0408
		LD		bc, $1020
		LD		a, 0
		ADD		a, h
		CP		$01
		JP		nz, error
		ADD		a, l
		CP		$03
		JP		nz, error
		ADD 	a, d
		CP		$07
		JP		nz, error
		ADD		a, e
		CP		$0f
		JP		nz, error
		ADD     a, b
		CP		$1f
		JP		nz, error
		ADD     a, c
		CP		$3f
		JP		nz, error
		
		SUB		a, h
		SUB		a, l
		SUB 	a, d
		SUB		a, e
		SUB     a, b
		SUB     a, c
		CP		$00
		JP		nz, error

		DEC		h
		DEC		l
		DEC		d
		DEC		e
		DEC		b
		DEC		c

		LD		a, $00
		CP		h
		JP		nz, error
		LD		a, $01
		CP		l
		JP		nz, error
		LD		a, $03
		CP		d
		JP		nz, error
		LD		a, $07
		CP		e
		JP		nz, error
		LD		a, $0f
		CP		b
		JP		nz, error
		LD		a, $1f
		CP		c
		JP		nz, error

		INC		h
		INC		l
		INC		d
		INC		e
		INC		b
		INC		c

		ADD 	hl, de
		ADD 	hl, bc

		LD		a, $15
		CP		h
		JP		nz, error
		LD		a, $2a
		CP		l
		JP		nz, error

;----------------------------------------------------------------------
; 6: test some 16 bit multiplication
;----------------------------------------------------------------------

test6:
		CALL 	inccnt
		JP		test6_1
		
x1:		defw	$1234
y1:		defw	$5678
z1:		defd	$06260060

x2:		defw	$FEDC
y2:		defw	$BA98
z2:		defd	$B9C32AA0
		
test6_1:

		LD		bc, (x1)
		LD		de, (y1)
		CALL	mul16
		LD		(var_z), hl
		LD		(var_z+2), de
		LD		hl, z1
		LD		de, var_z
		MEMCMP	4, error

		LD		bc, (x2)
		LD		de, (y2)
		CALL	mul16
		LD		(var_z), hl
		LD		(var_z+2), de
		LD		hl, z2
		LD		de, var_z
		MEMCMP	4, error

;----------------------------------------------------------------------
; 7: test some 64 bit multiplication
;----------------------------------------------------------------------

test7:
		CALL 	inccnt
		JP		test7_1
		
xx1:	defd	$12345678
yy1:	defd	$fedcba98
zz1:	defd	$35068740
		defd	$121FA00A
		
test7_1:

		LD		hl, xx1
		LD		de, var_x
		MEMCPY	4

		LD		hl, yy1
		LD		de, var_y
		MEMCPY	4

		CALL	mul32			; result $121FA00A_35068740

		LD		hl, zz1
		LD		de, var_z
		MEMCMP	8, error

;----------------------------------------------------------------------
; 8: test some square toots (BIT, RL, ADD, SUB)
;----------------------------------------------------------------------

test8:
		CALL 	inccnt

		LD		hl, $0400		; sqrt(1024) = 32 (E), 0 (BC)
		CALL	sqrt
		LD		a, 32
		CP		e
		JP		nz, error
		XOR		a
		LD		hl, 0
		SBC		hl, bc
		JP		nz, error
		
		LD		hl, $FFD0		; sqrt(65488) = 255 (E), 463 (BC)
		CALL	sqrt
		LD		a, 255
		CP		e
		JP		nz, error
		XOR		a
		LD		hl, 463
		SBC		hl, bc
		JP		nz, error


;----------------------------------------------------------------------
; 9: play Towers of Hanoi
;----------------------------------------------------------------------

test9:
		CALL 	inccnt
		call 	start_hanoi
		LD		hl, hanoir
		LD		de, TOHMOVES
		MEMCMP	(1<<DISKS)-1, error


;----------------------------------------------------------------------
; 10: calculate Pi
;----------------------------------------------------------------------

test10:
		CALL 	inccnt			; $320
		CALL 	calc_pi
		
		LD		hl, pi
		LD		de, READABLE
		MEMCMP	PIDIGITS, error



;----------------------------------------------------------------------
; ALL TESTS FINISHED
;----------------------------------------------------------------------

testsdone:
		CALL 	prettyprint		; in case some test has destroyed the output on port B
		JP		runninglight


;==================================================================================================
; STATUS: CU00tttt (C = CMOS, U = UB880, tttt = type)
; Z80= 0000, Z180= 0001, Z280= 0010, EZ80= 0011, U880= 0100, Clone= 0101
;==================================================================================================

prettyprint:
		LD		a, (Z80TYPE)	; load type
		LD		d, a

		LD		a, (ISCMOS)		; is CMOS?
		CP		0
		jr 		z, ppisnmos		; jump if NMOS 
		SET     7, d			; set bit 7 to indicate CMOS
ppisnmos:

		LD		a, (ISU880)		; is U880?
		CP		0
		JR      z, ppisnotU880	; jump if not
		SET		6, d			; set bit 7 to indicate UB880
ppisnotU880:

		LD 		a, d			; output identification flag
		SETLEDB	a				
		CALL	delay
		CALL	delay
		RET

;==================================================================================================
; TESTXY - Tests how SCF (STC) instruction affects FLAGS.5 (YF) and FLAGS.3 (XF)
; Input:
;	None
; Output:
;	A[7:6] - YF result of F = 0, A = C | 0x20 & 0xF7
;	A[5:4] - XF result of F = 0, A = C | 0x08 & 0xDF
;	A[3:2] - YF result of F = C | 0x20 & 0xF7, A = 0
;	A[1:0] - XF result of F = C | 0x08 & 0xDF, A = 0
;	Where the result bits set as follows:
;	00 - YF/XF always set as 0
;	11 - YF/XF always set as 1
;	01 - YF/XF most of the time set as 0
;	10 - YF/XF most of the time set as 1
;==================================================================================================

testxy:
		LD		c, $ff			; loop counter
	
testxy1:
		LD		hl, XFYFCOUNT	; results stored here

; check F = 0, A = C | 0x20 & 0xF7
		LD		e, $00			; FLAGS = 0
		LD		a, c
		OR		$20				; A.5 = 1
		AND     $f7				; A.3 = 0
		LD		d, a			; A = C | 0x20 & 0xF7
		PUSH	de				; PUSH DE TO THE STACK
		POP		af				; POP A AND FLAGS FROM THE STACK (DE)
		SCF						; STC, SET CF FLAG, DEPENDING ON THE CPU TYPE THIS
								; ALSO MIGHT CHANGE YF AND XF FLAGS
		CALL	storeycount

; check F = 0, A = C | 0x08 & 0xDF
		LD		e, $00			; FLAGS = 0
		LD		a, c
		OR 		$08				; A.3 = 1
		AND  	$df				; A.5 = 0
		LD		d, a			; A = C | 0x08 & 0xDF
		PUSH	de				; PUSH DE TO THE STACK
		POP		af				; POP A AND FLAGS FROM THE STACK (DE)
		SCF						; STC, SET CF FLAG, DEPENDING ON THE CPU TYPE THIS
								; ALSO MIGHT CHANGE YF AND XF FLAGS
		CALL	storexcount

; check F = C | 0x20 & 0xF7, A = 0
		LD 		a, c
		OR 		$20				; FLAGS.5 = 1
		AND     $f7				; FLAGS.3 = 0
		LD 		e, a			; FLAGS = C | 0x20 & 0xF7
		LD		d, $00			; A = 0
		PUSH	de				; PUSH DE TO THE STACK
		POP		af				; POP A AND FLAGS FROM THE STACK (DE)
		SCF						; STC, SET CF FLAG, DEPENDING ON THE CPU TYPE THIS
								; ALSO MIGHT CHANGE YF AND XF FLAGS
		CALL	storeycount

; check F = C | 0x08 & 0xDF, A = 0
		LD 		a, c
		OR 		$08				; FLAGS.3 = 1
		AND		$df				; FLAGS.5 = 0
		LD 		e, a			; FLAGS = C | 0x08 & 0xDF
		LD      d, $00			; A = 0
		PUSH	de				; PUSH DE TO THE STACK
		POP		af				; POP A AND FLAGS FROM THE STACK (DE)
		SCF						; STC, SET CF FLAG, DEPENDING ON THE CPU TYPE THIS
								; ALSO MIGHT CHANGE YF AND XF FLAGS
		CALL	storexcount

		DEC		c
		JR		nz, testxy1
	
		LD		c, 4			; iteration count - number of bytes
		LD		hl, XFYFCOUNT	; counters

testxy2:
		RLA						; RAL
		RLA						; RAL
		AND		$fc				; zero two least significant bits
		LD 		b, a			; store A to B
		LD 		a, (hl)
		CP		$7f
		JR		nc,	testxy3		; jump if the count is 0x80 or more
		CP		0
		JR		z, testxy5		; the count is 0 leave bits at 0
		LD		a, 1			; the count is between 1 and 0x7F, set result bits to 01
		JP		testxy5
testxy3:
		CP		$ff
		LD		a, 2			; the count is between 0x80 and 0xFE, set result bits to 10
		JR		nz, testxy4
		LD		a, 3			; the count is 0xFF, set result bits to 11
		JP		testxy5
testxy4:
		LD		a, 1			; the count is 0x7F or less, set result bits to 01
testxy5:
		OR		b
		INC		hl
		DEC		c
		JR		nz, testxy2
		RET

;-------------------------------------------------------------------------
; STOREXCOUNT - Isolates and stores XF to the byte counter at (HL)
; Input:
;	FLAGS	- flags
;	HL	- pointer to the counters
; Output:
;	HL	- incremented by 1 (points to the next counter)
; Trashes A and DE
;-------------------------------------------------------------------------
storexcount:
		PUSH	af				; transfer flags
		POP		de				; to E register
		LD		a, e
		AND     $08				; isolate XF
		JR		z, storexdone
		INC		(hl)			; increment the XF counter (HL)
storexdone:
		INC		hl				; point to the next entry
		RET

;-------------------------------------------------------------------------
; STOREYCOUNT - Isolates and stores YF to the byte counter at (HL)
; Input:
;	FLAGS	- flags
;	HL	- pointer to the counters
; Output:
;	HL	- incremented by 1 (points to the next counter)
; Trashes A and DE
;-------------------------------------------------------------------------
storeycount:
		PUSH	af				; transfer flags
		POP		de				; to E register
		LD		a, e
		AND     $20				; isolate YF
		JR		z, storeydone
		INC		(hl)			; increment the YF counter (HL)
storeydone:
		INC		hl				; point to the next entry
		RET

;==================================================================================================
; some maths functions
;==================================================================================================

; This returns the square root of HL (rounded down).
; Inputs:
;	HL
; Outputs:
;   BC is the remainder
;   D is not changed
;   E is the square root
;   H is 0
; Destroys:
;   A
;   L is a value of either {0,1,4,5}
;     every bit except 0 and 2 are always zero
   
sqrt:
		LD 		bc, 0800h
        LD 		e,c       
        XOR 	a        
sqrtloop:
        ADD		hl, hl    
        RL 		c         
        ADC 	hl, hl    
        RL 		c         
        JR 		nc, sqrt1
        SET 	0, l      
sqrt1:  LD		a, e       
        ADD 	a, a      
        LD 		e, a       
        ADD 	a, a      
        bit		0, l      
        JR 		nz, sqrt2
        SUB		c        
        JR 		nc, sqrt3
sqrt2:  LD		a, c   
        SUB		e    
        INC		e    
        SUB		e    
        LD		c, a   
sqrt3:  DJNZ 	sqrtloop
        BIT		0, l      
        RET 	z        
        INC		b        
        RET          

; Inputs:
;   DE and BC are factors
; Outputs:
;   A is 0
;   BC is not changed
;   DE:HL is the product
mul16:  LD 		hl, 0
        LD 		a, 16
ml1:
        ADD		hl, hl
        RL 		e
		RL      d
        JR		nc, ml2
        ADD     hl, bc
        JR      nc, ml2
        INC		de
ml2:	DEC		a
        JR 		nz, ml1
        ret

mul32:
; uses karatsuba multiplication
; var_x * var_y
; z0 holds the 64-bit result
		LD 		de, (var_x)
		LD		bc, (var_y)
		PUSH	bc
		CALL 	mul16
		LD		(var_z0), hl
		LD		bc, (var_y+2)
        LD		(var_z0+2), de
		LD 		de, (var_x+2)
        PUSH	bc
        CALL 	mul16
		LD 		(var_z2), hl
		LD		(var_z2+2), de
		XOR		a
		LD		hl, (var_x)
		LD		de, (var_x+2)
		ADD		hl, de
		RRA
		POP		de
		EX		(sp), hl
		ADD		hl, de
		POP		bc
		EX		de, hl
		PUSH	de
		PUSH	bc
		PUSH	af
        CALL 	mul16
		EX		de, hl
		POP		af
		POP		bc
		JR		nc, m64_1	; $+3
		ADD 	hl, bc
m64_1:	POP		bc
		RLA
		JR		nc, m64_2	; $+4 - this is wrong $+5
		ADD		hl, bc
		ADC		a, 0
m64_2:	EX 		de, hl
		LD		bc, (var_z0)
		SBC 	hl, bc
		EX 		de, hl
		LD		bc, (var_z0+2)
		SBC		hl, bc
		SBC		a, 0
		EX		de, hl
		LD		bc, (var_z2)
		SBC		hl, bc
		EX 		de, hl
		LD		bc, (var_z2+2)
		SBC		hl, bc
		SBC		a, 0
		LD		b, h
		LD		c, l
		LD		hl,(var_z0+2)
		ADD		hl, de
		LD		(var_z0+2), hl
		LD		hl, (var_z2)
		ADC		hl, bc
		LD		(var_z2), hl
		RET		nc
		LD		hl, (var_z2+2)
		INC		hl
		LD		(var_z2+2), hl
		RET

;==================================================================================================
; some helpers
;==================================================================================================

delay:  PUSH	HL
        LD      h, $ff
loop1:  LD      l, $ff
loop2:  DEC     l
        JP      nz, loop2
        DEC     h
        JP      nz, loop1
        POP		HL
		RET

inccnt:	PUSH	HL
		LD		hl, COUNTER
		INC 	(hl)
		SETLEDA (hl)
		call	delay
        POP     HL
		RET

;==================================================================================================
; display error, debug blinking
;==================================================================================================

error:
		LD		a, (COUNTER)
error1:
		SET		7, a
		SETLEDA a
		CALL	delay
		RES		7, a
		SETLEDA a
		CALL	delay
		JR		error1

debug:
		SETLEDA 0
		SETLEDB 0
		CALL	delay
		SETLEDA 15
		SETLEDB 15
		CALL	delay
		SETLEDA 240
		SETLEDB 240
		CALL	delay
		SETLEDA 0
		SETLEDB 0
		CALL 	delay
		RET
		
;==================================================================================================
; main loop 3x light left
;==================================================================================================

runninglight:
		
		XOR     a 		 		; clear carry
        LD      a,1				; set bit 0
        LD      b,3				; three times running light

left:   SETLEDA a
        RL      a				; lotate left
		CALL	delay
        JR      nc, left		; all bits
        DJNZ    left

        SETLEDA 0            	; turn off all LEDs
		CALL	delay

        JP      runninglight	; continue endless

;==================================================================================================
; NMI function
;==================================================================================================

nmifunction:
		SETLEDA	0				; port A off
		SETLEDB	0				; port B off
		CALL	delay
		CALL	testflags

        LD      b,3				; three times alternating indicators
fnmi:   SETLEDA 240				; port A = 11110000
		SETLEDB 15				; port B = 00001111
		CALL	delay
		SETLEDA 15				; port B = 00001111
		SETLEDB 240				; port B = 11110000
		CALL	delay
		CALL	delay
        DJNZ    fnmi

		SETLEDA	0				; port A off
		SETLEDB	0				; port B off
		CALL	delay

		LD		hl, XYRESULT	; load XY result
		SETLEDA	(hl)
		CALL	delay
		CALL	delay

		SETLEDA	0				; port A off
		SETLEDB	0				; port B off
		CALL	delay

		LD		hl, XFCOUNT		; load XF counter
		SETLEDA	(hl)
		INC     hl
		SETLEDB	(hl)
		CALL	delay
		CALL	delay
		
		SETLEDA	0				; port A off
		SETLEDB	0				; port B off
		CALL	delay

		LD		hl, YFCOUNT		; load YF counter
		SETLEDA	(hl)
		INC     hl
		SETLEDB	(hl)
		CALL	delay
		CALL	delay
		
		SETLEDA	0				; port A off
		SETLEDB	0				; port B off
		CALL	delay

		RET

;--------------------------------------------------------------------------------------------------
; tests how scf affects YF and XF flags
; tests from https://github.com/skiselev/z80-tests/
;--------------------------------------------------------------------------------------------------

testflags:
		LD		HL, 0
		LD		(XFCOUNT), hl
		LD		(YFCOUNT), hl
		LD		d, 0
tfloop1:
		LD		e, 0
tfloop2:
		PUSH	de
		PUSH	de				; PUSH DE TO THE STACK
		POP		af				; POP A AND FLAGS FROM THE STACK (DE)
		CCF						; CMC; SET CF FLAG, DEPENDING ON THE CPU TYPE THIS
								; ALSO MIGHT CHANGE YF AND XF FLAGS
		PUSH	af				; STORE A AND F
		POP		de				; NEW FLAGS IN E
		LD		a, e			; FLAGS TO ACCUMULATOR
		POP		de

		LD		hl, XFCOUNT		; POINT TO XF COUNTER
		RRCA					; RRC; BIT 3 TO CF
		RRCA
		RRCA
		RRCA
		JR		nc, tfloop4
		INC     (hl)
		JR		nz, tfloop4		; NO OVERFLOW
		INC		hl				; MOVE TO THE HIGH BIT
		INC		(hl)			; INCREMENT HIGHER BIT

tfloop4:
		LD		hl, YFCOUNT		; POINT TO YF COUNTER
		RRCA					; BIT 5 TO CF
		RRCA
		JR 		nc, tfloop5
		INC 	(hl)			; INCREMENT COUNTER IF FLAG IS SET
		JR 		nz, tfloop5		; NO OVERFLOW
		INC		hl				; MOVE TO THE HIGH BIT
		INC     (hl)			; INCREMENT HIGHER BIT

tfloop5:
		INC		e
		JR		nz, tfloop2
		INC     d				; INCREMENT D
		JR      nz, tfloop1
		RET

;==================================================================================================
; Includes
;==================================================================================================

include picalc.asm
include towersofhanoi.asm
