	.ORG 600
start:
	LDA #$35
	
	TAX
	DEX
	DEX
	INX
	TXA
	
	TAY
	DEY
	DEY
	INY
	TYA
	
	TAX
	LDA #$20
	TXS
	LDX #$10
	TSX
	TXA
	
	STA $40