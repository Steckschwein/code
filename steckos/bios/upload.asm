    .export upload

    .import uart_rx, uart_tx
    .import vdp_chrout, print_crlf, hexout, primm

    .include "bios.inc"
    .include "uart.inc"

.code
;----------------------------------------------------------------------------------------------
upload:
		jsr print_crlf
		print "Serial upload.."
		; load start address
		jsr uart_rx
		sta startaddr

		jsr uart_rx
		sta startaddr+1


		; lda startaddr+1
		jsr hexout
		lda startaddr
		jsr hexout

		lda #' '
		jsr vdp_chrout

		jsr upload_ok

		; load number of bytes to be uploaded
		jsr uart_rx
		sta length

		jsr uart_rx
		sta length+1

		; calculate end address
		clc
		lda length
		adc startaddr
		sta endaddr

		lda length+1
		adc startaddr+1
		sta endaddr+1

		; lda endaddr+1
		jsr hexout

		lda endaddr
		jsr hexout

		lda #' '
		jsr vdp_chrout


		lda startaddr
		sta addr
		lda startaddr+1
		sta addr+1

		jsr upload_ok

		ldy #$00
@l1:
		jsr uart_rx
		sta (addr),y

		iny
		cpy #$00
		bne @l2
		inc addr+1

@l2:
		; msb of current address equals msb of end address?
		lda addr+1
		cmp endaddr+1
		bne @l1 ; no? read next byte

		; yes? compare y to lsb of endaddr
		cpy endaddr
		bne @l1 ; no? read next byte

		; yes? write OK

		jsr upload_ok

		print "OK"
		rts

upload_ok:
		lda #'O'
		jsr uart_tx
		lda #'K'
		jmp uart_tx
		; rts