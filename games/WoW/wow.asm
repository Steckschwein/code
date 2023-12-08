.include "wow.inc"

.import intro_main

.export char_out=krn_chrout
.export fopen=krn_open
.export fread_byte=krn_fread_byte
.export fclose=krn_close

appstart
.code
main:
		jsr intro_main
		jmp (retvec)
