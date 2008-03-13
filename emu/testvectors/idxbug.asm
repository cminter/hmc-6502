	.ORG $600

start:
	LDA #112
	STA $30
	LDA #113
	STA $31
	LDA #114
	STA $32
	LDA #197
	STA $70
	LDA #124
	STA $71
	LDA #161
	STA $72
	LDA #155
	LDX #16
	AND ($20,X)
	ORA ($21,X)
	EOR ($22,X)