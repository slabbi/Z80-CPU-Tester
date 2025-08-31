;==================================================================================================
; some maths functions
;==================================================================================================
; License:
; If you share a routine that you didn't write, credit the author as best as you can 
; (unless the author doesn't want to be credited).
;==================================================================================================

;--------------------------------------------------------------------------------------------------
; Source: https://github.com/Zeda/Z80-Optimized-Routines/blob/master/math/squareroot/sqrtHL_fastest.z80
;
; returns A as the sqrt, HL as the remainder, D = 0
;--------------------------------------------------------------------------------------------------

sqrtHL:
		LD 		de, 05040h
		LD		a, h
		SUB		e        
		JR 		nc, sq7    
		ADD 	a, e      
		LD 		d, 16      
sq7:           
		CP 		d         
		JR 		c, sq6     
		SUB 	d        
		SET 	5, d      
sq6:           
		RES 	4, d      
		SRL		d        
		SET     2, d      
		CP      d         
		JR      c, sq5     
		SUB d        
		SET     3, d      
sq5:           
		SRL     d        
		INC 	a       
		SUB d        
		jr      nc, sq4    
		DEC     d        
		ADD     a, d      
		DEC     d        
sq4:           
		SRL     d        
		LD 		h, a       
		LD 		a, e       
		SBC     hl, de    
		JR      nc, sq3    
		ADD     hl, de    
sq3:           
		CCF          
		RRA          
		SRL     d        
		RRA          
		LD      e, a       
		SBC     hl, de    
		JR      c, sq2     
		OR      20h       
		db      254     	; CP *
sq2:           
		ADD     hl, de    	; will be skiped using the "CP"
		XOR     18h      
		SRL     d        
		RRA          
		LD 		e, a       
		SBC     hl, de    
		JR      c, sq1     
		OR      8         
		db      254
sq1:           
		ADD     hl, de    
		XOR     6        
		SRL    d        
		RRA          
		LD 		e, a       
		SBC     hl, de    
		JR      nc, sq0
		ADD 	hl, de    
		SRL     d        
		RRA          
		RET          
sq0:             
		INC 	a        
		SRL     d        
		RRA          
		RET

;--------------------------------------------------------------------------------------------------
; Source: https://learn.cemetech.net/index.php/Z80:Math_Routines#DE_Times_BC.2C_32-bit_result
;
; Inputs:
;   DE and BC are factors
; Outputs:
;   A is 0
;   BC is not changed
;   DE:HL is the product
;--------------------------------------------------------------------------------------------------

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

;--------------------------------------------------------------------------------------------------
; Source: https://learn.cemetech.net/index.php/Z80:Math_Routines#mul32.2C_64-bit_output
;
; uses karatsuba multiplication
; var_x * var_y
; z0 holds the 64-bit result
;--------------------------------------------------------------------------------------------------

mul32:
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
