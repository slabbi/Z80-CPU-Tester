;==================================================================================================
; Z80 CPU Tester
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
;==================================================================================================

; some constants

CPU_Z80		EQU		0
CPU_Z180	EQU 	1
CPU_Z280	EQU		2
CPU_EZ80	EQU 	3
CPU_U880	EQU		4
CPU_NEC_CL	EQU		5

PORTA		EQU		11111110B			; A0 = L / Bit 0 = L
PORTB		EQU		11111101B			; A1 = L / Bit 1 = L

; some vars in ram

COUNTER		EQU		$8000

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

DELAY   MACRO
		LOCAL 	loop1, loop2
        LD      h, $ff
loop1:  LD      l, $ff
loop2:  DEC     l
        JP      nz, loop2
        DEC     h
        JP      nz, loop1
        ENDM

INCCNT	MACRO
		LD		hl, COUNTER
		INC 	(hl)
		SETLEDA (hl)
		DELAY
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
		SETLEDA	0				; port A off
		SETLEDB	0				; port B off
		DELAY

        LD      b,3				; three times alternating indicators
fnmi:   SETLEDA 240				; port A = 11110000
		SETLEDB 15				; port B = 00001111
		DELAY
		SETLEDA 15				; port B = 00001111
		SETLEDB 240				; port B = 11110000
		DELAY
        DJNZ    fnmi
	
start:							; program starts here
		IM		1				; interrupt mode 1
		LD		sp, $ffff		; set stack
		SETLEDA 0				; port A off
		SETLEDB 0				; port b off

;--------------------------------------------------------------------------------------------------
; CHECK eZ80
;--------------------------------------------------------------------------------------------------

startident:

		XOR		a
		LD		e,e				; this is .LIL command on eZ80
		LD		hl, 0   		; part of long load on eZ80 only
		INC		a				; part of long load on eZ80 only
		
		LD		d, CPU_EZ80		; d = CPU type, assuming it is EZ880
		JR		z, identified	; yes, it is a EZ880

;--------------------------------------------------------------------------------------------------
; CHECK Z180
;--------------------------------------------------------------------------------------------------

		XOR		a
		DEC		a
		DAA						; Z180 returns $f9, Z80 returns $99
		CP		$f9				; is Z180?
		LD		d, CPU_Z180
		JR		z, identified	; yes, it is a Z180

		LD		a, $40
		BYTE	$cb, $37		; from the Z280 data book
		JP		p, z280_detected	; yes, it is a Z280

;--------------------------------------------------------------------------------------------------
; CHECK U880
;--------------------------------------------------------------------------------------------------

        LD      hl,$ffff
        LD      bc,$180a
        SCF
        OUTI
		LD		d, CPU_U880
        JP      c, identified	; yes, it is a UB880

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
		LD		d, CPU_Z80
		JR		z, identified	; yes, it is a Z80
	
		LD		d, CPU_NEC_CL	; it is a clone
		JR		identified

z280_detected:
		LD		d, CPU_Z280		; Z280 identified

;--------------------------------------------------------------------------------------------------
; CHECK CMOS/NMOS
;--------------------------------------------------------------------------------------------------

identified:
		LD 		e, 0			; e = 0 for NMOS; e = 1 for CMOS

        LD      c, 0
;       out     (c),0
        BYTE    $ed, $71      	; CMOS = $FF; NMOS = $00
		NOP
		IN		a,(c)

		JP		z, isnmos		; $00, so it is NMOS
		SET     7, d			; set bit 7 to indicate CMOS
isnmos:

		LD		a, d 			; check identified CPU
		AND     $0f				; currently lower four bits
		CP      CPU_U880		; is it a UB880
		JP      nz, isnotU880	; no, it is not
		SET		6, d			; set bit 7 to indicate UB880
isnotU880:

;==================================================================================================
; STATUS: CU00tttt (C = CMOS, U = UB880, tttt = type)
; Z80= 0000, Z180= 0001, Z280= 0010, EZ80= 0011, U880= 0100, Clone= 0101
;==================================================================================================

		LD 		a, d			; output identification flag
		SETLEDB	a				
		DELAY
		DELAY

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

; 1: test memory access, 16 bit register load
		
test1:
		INCCNT
		LD		hl, $8001
		LD		de, $8002
		LD		bc,	$8003

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

		LD		hl, $8001		; now a simple pattern
		LD		de, $8002
		LD		bc,	$8003
		
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

; 2: test RL, RR, register to register load

test2:
		INCCNT
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

; 3: test ADD, SUB

test3:
		INCCNT
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

; 4: test PUSH, POP, 16 bit SBC

test4:
		INCCNT
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

; 5: test sub, add, inc, dec

test5:
		INCCNT
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

; 6: test some multiplation

test6:
		INCCNT
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

; 7: test some 64bit multiplation

test7:
		INCCNT
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

testsdone:
		JP		runninglight
		
		
;==================================================================================================
; some maths functions
;==================================================================================================
	
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
; display error
;==================================================================================================

error:
		LD		a, (COUNTER)
error1:
		SET		7, a
		SETLEDA a
		DELAY
		RES		7, a
		SETLEDA a
		DELAY
		JR		error1

;==================================================================================================
; main loop 3x light left
;==================================================================================================

runninglight:
		
		XOR     a 		 		; clear carry
        LD      a,1				; set bit 0
        LD      b,3				; three times running light

left:   SETLEDA a
        RL      a				; lotate left
		DELAY
        JR      nc, left		; all bits
        DJNZ    left

        SETLEDA 0            	; turn off all LEDs
		DELAY

        JP      runninglight	; continue endless

