
		.include "uart.inc"

		.export uart_tx
.code
;----------------------------------------------------------------------------------------------
; send byte in A
;----------------------------------------------------------------------------------------------
uart_tx:
					 pha

					 lda #lsr_THRE

@l:
					 bit uart1+uart_lsr
					 beq @l

					 pla

					 sta uart1+uart_rxtx

					 rts

