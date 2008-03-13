	.ORG 600
	
start:
	LDA #$7C
	STA $20
	LDA #$02
	STA $21
	LDA #$00
	ORA #$03
	JMP jump1
	ORA #$FF ; not done
jump1:
	ORA #$30
	JSR subr
	ORA #$42
	JMP ($0020)
	ORA #$FF ; not done
subr:
	STA $30
	LDX $30
	LDA #$00
	RTS
final:
	STA $0D,X
	
