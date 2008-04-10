	.ORG 600
start:
	LDA #$27
	ADC #$01
	SEC
	PHP
	CLC
	PLP
	ADC #$00
	PHA
	LDA #$00
	PLA
	STA $30