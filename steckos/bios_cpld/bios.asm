.include "bios.inc"

.code

uart_cpb = $0200

do_reset:
			; disable interrupt
			sei
			; clear decimal flag
			cld

			; init stack pointer
			ldx #$ff
			txs

;		lda #fcr_FIFO_enable | fcr_reset_receiver_FIFO | fcr_reset_transmit_FIFO
;		sta uart1+uart_fcr
;		stz uart1+uart_ier	; polled mode (so far)
;		stz uart1+uart_mcr	; reset DTR, RTS

		lda #fcr_FIFO_enable | fcr_reset_receiver_FIFO | fcr_reset_transmit_FIFO
		sta uart_cpb+uart_fcr
		stz uart_cpb+uart_ier	; polled mode (so far)
		stz uart_cpb+uart_mcr	; reset DTR, RTS

@loop:
		; lda uart_cpb+5 ;lsr


		lda #lsr_THRE
@l0:
		bit uart_cpb+uart_lsr
		beq @l0
		lda #'A'
		sta uart_cpb+uart_rxtx

;@l1:
;		lda #lsr_THRE
;		bit uart1+uart_lsr
;		beq @l1
;
;		lda #'X'
;		sta uart1+uart_rxtx

		bra	@loop

bios_irq:
	rti

.segment "VECTORS"
;----------------------------------------------------------------------------------------------
; Interrupt vectors
;----------------------------------------------------------------------------------------------
; $FFFA/$FFFB NMI Vector
.word bios_irq
; $FFFC/$FFFD reset vector
;*= $fffc
.word do_reset
; $FFFE/$FFFF IRQ vector
;*= $fffe
.word bios_irq
