
		.include "uart.inc"

		.export uart_tx
.code
;@module: uart
;----------------------------------------------------------------------------------------------
; send byte in A
;----------------------------------------------------------------------------------------------
;@name: "uart_tx"
;@in: A, "byte to send"
;@desc: "send byte"
uart_tx:
					 pha

					 lda #lsr_THRE

@l:
					 bit uart1+uart_lsr
					 beq @l

					 pla

					 sta uart1+uart_rxtx

					 rts

