	.ORG 600
start:
	SEI
	SED
	PHP
	PLA
	STA $20
	CLI
	CLD
	PHP
	PLA
	ADC $20
	STA $21