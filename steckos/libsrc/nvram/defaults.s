.export nvram_defaults
nvram_defaults:
	 .byte $42
	 .byte $00
	 .byte "LOADER  BIN"
	 .word $01
	 .byte %00000011
