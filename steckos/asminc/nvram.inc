nvram_start		  = $20
nvram_write		  = $80
nvram_signature  = $42

.struct nvram
	 version			.byte
	 filename		.byte 13
	 uart_baudrate	.byte
	 uart_lsr		.byte
	 keyboard_tm	.byte ; ps/2 keyboard type matic (delay/rate) value
	 mainframe_mode .byte
	 crc7				.byte
.endstruct

nvram_size  = .sizeof(nvram)
