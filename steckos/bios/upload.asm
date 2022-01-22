    .export upload

    .import uart_rx, uart_tx
    .import vdp_chrout, print_crlf, hexout, primm

    .importzp startaddr, endaddr

    .include "bios.inc"
    .include "uart.inc"
.zeropage
   ptr_upload_addr:    .res 2
   length:             .res 1

.code
;----------------------------------------------------------------------------------------------
upload:
		print "Serial upload.."
		; load start address
		jsr uart_rx
        sta startaddr
		sta ptr_upload_addr
        jsr uart_rx
        sta startaddr+1
		sta ptr_upload_addr+1

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

		jsr hexout
		lda endaddr
		jsr hexout

		lda #' '
		jsr vdp_chrout


		jsr upload_ok

@l1:
		jsr uart_rx
		sta (ptr_upload_addr)

		inc16 ptr_upload_addr

		cmp16 ptr_upload_addr, endaddr, @l1

		; yes? write OK
		jsr upload_ok

		print "OK"
		rts

upload_ok:
		lda #'O'
		jsr uart_tx
		lda #'K'
		jmp uart_tx
