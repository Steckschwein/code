			.import crc7
			.import popax

			.export _crc7


; extern unsigned char __fastcall__ crc7 (unsigned char *data, unsigned char length);

.proc _crc7

			pha			; length to stack
			jsr popax	; reorg arguments .A/.Y data pointer .X length
			phx
			ply
			plx			; .X length from stack
			jmp crc7
.endproc
