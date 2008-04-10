	.ORG 600
start:
	LDA #$99
	ADC #$87
	CLC
	NOP
	BCC bcc1 ; taken
	ADC #$60 ; not done
	ADC #$93 ; not done
bcc1:
	SEC
	NOP
	BCC bcc2 ; not taken
	CLV
bcc2:
	BVC bvc1 ; taken
	LDA #$00 ; not done
bvc1: 
	ADC #$AD
	;ADC #$17
	;SED
	;ADC #$95
	;CLD
	;ADC #$9A
	NOP
	STA $30