.include "nvram.inc"

.export nvram_defaults
nvram_defaults:
	 .byte nvram_signature
	 .byte "LOADER  BIN"
	 .byte $01	;115200
	 .byte $03	;8N1
	 .byte $37	;crc7
