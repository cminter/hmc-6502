	.ORG $600

start:
	LDA #$E7	; 2 cycles
	STA $20		; 3 cycles
	LDA #$18	; 2 cycles
	STA $10		; 3 cycles
	EOR #$FF	; 2 cycles
	CMP $20		; 3 cycles
	BNE final 	; 2 cycles (not taken)
	SBC $10		; 3 cycles
	CMP $20		; 3 cycles
	BNE final	; 3 cycles (taken)
	EOR #$AA	; shouldn't happen
final:
	STA $42		; 3 cycles, should be $42=0xCF
			; total 29 cycles