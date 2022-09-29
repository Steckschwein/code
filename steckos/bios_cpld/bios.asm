.include "bios.inc"

.code

uart_cpb = $0250

do_reset:
		; disable interrupt
		sei

		; clear decimal flag
		cld

		; init stack pointer
		ldx #$ff
		txs

        lda #lcr_DLAB
        sta uart_cpb+uart_lcr

        lda #$01 ;115200
        sta uart_cpb+uart_dll
        stz uart_cpb+uart_dlh ; dlh always 0, we do not support baudrates < 600
        lda #$03 ;8N1
        sta uart_cpb+uart_lcr

		lda #fcr_FIFO_enable | fcr_reset_receiver_FIFO | fcr_reset_transmit_FIFO
		sta uart_cpb+uart_fcr
		stz uart_cpb+uart_ier	; polled mode (so far)
		stz uart_cpb+uart_mcr	; reset DTR, RTS

;		lda #fcr_FIFO_enable | fcr_reset_receiver_FIFO | fcr_reset_transmit_FIFO
;		sta uart1+uart_fcr
;		stz uart1+uart_ier	; polled mode (so far)
;		stz uart1+uart_mcr	; reset DTR, RTS

@loop:
        ldx #'0'
@lx:
		lda #lsr_THRE
@l0:
		bit uart_cpb+uart_lsr
		beq @l0
        stx uart_cpb+uart_rxtx
        inx
        cpx #'9'+1
        bne @lx
;		lda #lsr_THRE
;@l1:
;		bit uart1+uart_lsr
;		beq @l1
;		lda #'Y'
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
