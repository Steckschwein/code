      .include "bios.inc"
      .include "sdcard.inc"
      .include "fat32.inc"
      .include "nvram.inc"

      .import uart_init, upload
      .import init_via1
      .import hexout, primm, print_crlf
      .import vdp_init, _vdp_chrout, vdp_detect
      .import init_sdcard
      .import fat_mount, fat_read, fat_find_first, calc_lba_addr
      .import read_nvram

		.export vdp_chrout

.macro set_ctrlport
			pha
			lda ctrl_port
			lsr
			lda ctrl_port
			and #$fe
			rol
			sta ctrl_port
			pla
.endmacro

.code
do_reset:
			; disable interrupt
			sei
			; clear decimal flag
			cld

			; init stack pointer
			ldx #$ff
			txs

			lda ctrl_port
			ora #%11111000
			sta ctrl_port

  			; Check zeropage and Memory
check_zp:
		    ; Start at $ff
			ldy #$ff
			; Start with pattern $03 : $ff
@l2:		ldx #num_patterns
@l1:		lda pattern,x
			sta $00,y
			cmp $00,y
			bne zp_broken

			dex
			bne @l1

			dey
			bne @l2

check_stack:
			;check stack
			ldy #$ff
@l2:		ldx #num_patterns
@l1:		lda pattern,x
			sta $0100,y
			cmp $0100,y
			bne stack_broken

			dex
			bne @l1

			dey
			bne @l2

check_memory:
			lda #>start_check
			sta ptr1h
			ldy #<start_check
			stz ptr1l

@l2:		ldx #num_patterns  ; 2 cycles
@l1:		lda pattern,x      ; 4 cycles
	  		sta (ptr1l),y   ; 6 cycles
			cmp (ptr1l),y   ; 5 cycles
			bne @l3				  ; 2 cycles, 3 if taken

			dex  				  ; 2 cycles
			bne @l1			  ; 2 cycles, 3 if taken

			iny  				  ; 2 cycles
			bne @l2				  ; 2 cycles, 3 if taken

			; Stop at $e000 to prevent overwriting BIOS Code when ROMOFF
			ldx ptr1h		  ; 3 cycles
			inx				  ; 2 cycles
			stx ptr1h		  ; 3 cycles
			cpx #$e0			  ; 2 cycles

			bne @l2 			  ; 2 cycles, 3 if taken
@l3:  	sty ptr1l		  ; 3 cycles

	  					  ; 42 cycles

	  		; save end address
	  		; lda ptr1l
	  		; sta ram_end_l
	  		; lda ptr1h
	  		; sta ram_end_h

			lda #$e0
			cmp ptr1h
			bne mem_broken

			lda ptr1l
			bne mem_broken


			bra mem_ok

mem_broken:
			lda #$80
			bra stop

zp_broken:
			lda #$40
			bra stop

stack_broken:
			lda #$20
stop:
			sta ctrl_port
@loop:		bra @loop


mem_ok:
			set_ctrlport

			jsr vdp_init

			set_ctrlport

			jsr primm
			.byte "BIOS "
			.include "version.inc"
			.byte $0a,0

			print "Memcheck $"
			lda ptr1h
			jsr hexout
			lda ptr1l
			jsr hexout
			jsr print_crlf

			jsr vdp_detect

			set_ctrlport
			jsr init_via1

         lda #<nvram
         ldy #>nvram
			jsr read_nvram
         set_ctrlport

			jsr uart_init
         set_ctrlport

			jsr init_sdcard
         stz errno

         lda errno
			beq boot_from_card

			; display sd card error message
			cmp #$0f
			bne @l1
			print "Invalid SD card"
@l1:		cmp #$1f
			bne @l2
			print "SD card init failed"
@l2:		cmp #$ff
			bne @l3
			print "No SD card"
@l3:
do_upload:
         jsr upload
         jmp startup

boot_from_card:
         lda #(<nvram)+nvram::filename
         sta ptr1l
         lda #>nvram
         sta ptr1h

			print "Boot from SD card.. "
			jsr fat_mount

			lda errno
			beq @findfile
			jsr print_crlf
			print "FAT32 mount error: "
			jsr hexout
         bra do_upload

@findfile:
@l4:
			jsr fat_find_first
			bcs @loadfile

			jsr print_crlf

			ldy #$00
@loop:
         lda (ptr1),y
			jsr vdp_chrout
			iny
			cpy #$0b
			bne @loop
			print " not found."

			bra do_upload
@loadfile:
			ldy #DIR_FstClusHI + 1
			lda (dirptr),y
			sta root_dir_first_clus + 3
			ldy #DIR_FstClusHI
			lda (dirptr),y
			sta root_dir_first_clus + 2
			ldy #DIR_FstClusLO + 1
			lda (dirptr),y
			sta root_dir_first_clus + 1
			ldy #DIR_FstClusLO
			lda (dirptr),y
			sta root_dir_first_clus
			jsr calc_lba_addr

			.repeat 4, i
				ldy #DIR_FileSize + i
				lda (dirptr),y
				sta filesize + i
			.endrep

			SetVector steckos_start, startaddr
			SetVector steckos_start, sd_blkptr
			jsr fat_read

		; re-init stack pointer
startup:
			ldx #$ff
			txs

			; jump to new code
			jmp (startaddr)

bios_irq:
		rti
;    save
 ;   bit a_vreg
  ;  bpl @exit
;@exit:
 ;   restore

num_patterns = $02
pattern:
	.byte $aa,$55,$00
.segment "JUMPTABLE"
; TODO can be removed if the steckschwein emu is finished one day and no chrout hook is required anymore
; jump table - required for fixed adressing within steckschwein-emu to hook some calls
vdp_chrout:
			jmp _vdp_chrout

.SEGMENT "VECTORS"
;----------------------------------------------------------------------------------------------
; Interrupt vectors
;----------------------------------------------------------------------------------------------
; $FFFA/$FFFB NMI Vector
.word mem_ok
; $FFFC/$FFFD reset vector
;*= $fffc
.word do_reset
; $FFFE/$FFFF IRQ vector
;*= $fffe
.word bios_irq
