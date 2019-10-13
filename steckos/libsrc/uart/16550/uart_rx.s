
		.include "uart.inc"
		
		.export uart_rx
.code
;----------------------------------------------------------------------------------------------
; receive byte, store in A
;----------------------------------------------------------------------------------------------
uart_rx:
					 lda #lsr_DR
@l:
					 bit uart1+uart_lsr
					 beq @l
					 lda uart1+uart_rxtx
					 rts