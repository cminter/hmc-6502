	.ORG 600
start:
	LDA #$28
	SEC
	SED
	PHP
	CLD
	CLC
	PLP
	ADC #$00
	ADC #$93
	PHA
	LDA #$00
	PLA
	STA $30
	