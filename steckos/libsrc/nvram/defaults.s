.include "nvram.inc"

.export nvram_defaults
nvram_defaults:
	 .byte nvram_signature
	 .byte "LOADER  BIN"
	 .word $01
	 .byte $2e
