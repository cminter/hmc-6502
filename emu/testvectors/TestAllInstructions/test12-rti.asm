	.ORG 600
start:
	CLC
	LDA #$42
	BCC runstuff
	STA $33
	BCS end
runstuff:
	LDA #$02
	PHA
	LDA #$59
	PHA
	SEC
	PHP
	CLC
	RTI
end:
	
