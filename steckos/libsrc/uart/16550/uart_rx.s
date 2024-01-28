
		.include "uart.inc"
		
		.export uart_rx
.code
;----------------------------------------------------------------------------------------------
; receive byte, store in A
;----------------------------------------------------------------------------------------------
;@name: "uart_rx"
;@out: A, "received byte"
;@desc: "receive byte"
uart_rx:
					 lda #lsr_DR
@l:
					 bit uart1+uart_lsr
					 beq @l
					 lda uart1+uart_rxtx
					 rts