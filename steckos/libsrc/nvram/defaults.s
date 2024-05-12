.include "nvram.inc"
.include "vdp.inc"

.export nvram_defaults
nvram_defaults:
	.byte nvram_signature
	.byte "LOADER.PRG",0,0,0	; 13 byte - 8.3 file name + \0
	.byte $01	;115200
	.byte $03	;8N1
	.byte $20	;30Hz / 500ms
	.byte White<<4|Black
	.byte $7a	;crc7
