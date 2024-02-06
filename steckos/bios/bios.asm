.include "bios.inc"

.autoimport

; expose high level read_/write_block api
.export read_block=             blklayer_read_block
; configure low level or device read_/write_block api
.export dev_read_block=         sd_read_block

.export char_out=vdp_charout
.export debug_chrout=vdp_charout
;.export char_out=uart_tx
;.import uart_tx
.export crc16_lo=BUFFER_0
.export crc16_hi=BUFFER_1
.export crc16_init=crc16_table_init
.export xmodem_rcvbuffer=BUFFER_2
.export xmodem_startaddress=startaddr

.zeropage
      ptr1:       .res 2
      ptr2:       .res 2
      init_step:  .res 1
      startaddr:  .res 2

;.exportzp ptr1,  ptr2

.code

; bios does not support fat write, so we export a dummy function for write which is not used anyway since we call with O_RDONLY
.export dev_write_block=_noop
.export write_block=_noop
.export write_block_buffered=_noop
.export write_flush=_noop
_noop:
      clc
      rts

memcheck:
      ldx #0    ; start bank 0
      bit ctrl_port+3 ; bank 4 RAM?
      bpl @starthigh
      lda #>$4300 ; start bank 0, but skip zp
      bra @check_page0
@starthigh:
      ldx #4
@check_page:
      lda #>$4000
@check_page0:
      sta ptr1+1
      stz ptr1+0
      stx ctrl_port+1

@checkloop:
      ldy #num_patterns-1
@patternloop:
      lda pattern,y
      sta (ptr1)
      lda (ptr1)
      cmp pattern,y
      bne mem_broken
      dey
      bpl @patternloop

      inc16 ptr1

      lda ptr1+1
      cmp #$80
      bne @checkloop

      jsr display_progress

      ;txa
      ;jsr hexout
      inx
      cmp #31
      bne @check_page

      stz crs_x
      println "Memcheck 512k OK  "
      rts

display_progress:
      stz crs_x
      jsr primm
      .byte "Memcheck bank #",0
      txa
      jmp hexout_s

mem_broken:
      jsr primm
      .byte "Memory error! Bank ",0
      txa
      jsr hexout_s
      jsr primm
      .byte " at ",0

      lda ptr1+1
      jsr hexout_s
      lda ptr1
      jsr hexout
      println ""
@stop:
      jmp @stop

_delay_10ms:
:     sys_delay_ms 10
      dey
      bne :-
      rts

_keyboard_cmd_status:
      print_dot
      ldy #100
:     dey
      bmi :+
      phy
      ldy #5
      jsr _delay_10ms
      lda #KBD_HOST_CMD_CMD_STATUS
      jsr spi_rw_byte
      ply
      cmp #KBD_HOST_CMD_STATUS_EOT
      bne :-
:    rts

;  requires nvram init beforehand
keyboard_init:
      jsr primm
      .byte "Keyboard init.", 0

      ldy #50
      jsr _delay_10ms

      stz init_step

      lda #spi_device_keyboard
      jsr spi_select_device
      bne @fail

      inc init_step
      lda #KBD_CMD_RESET
      jsr spi_rw_byte
      jsr _keyboard_cmd_status
      bne @fail

      inc init_step
      lda #KBD_CMD_TYPEMATIC
      jsr spi_rw_byte
      lda nvram+nvram::keyboard_tm ; typematic settings
      jsr spi_rw_byte
      jsr _keyboard_cmd_status
      bne @fail

      jsr print_ok
      clc
      jmp spi_deselect
@fail:
      pha
      jsr primm
      .byte "FAIL (",0
      lda init_step
      jsr hexout_s
      lda #'/'
      jsr char_out
      pla
      jsr hexout_s
      jsr primm
      .byte ")", CODE_LF, 0
      sec
      jmp spi_deselect

do_reset:
      ; disable interrupt
      sei
      ; clear decimal flag
      cld

      ; init stack pointer
      ldx #$ff
      txs

      lda #$00
      sta slot0
      ina
      sta slot1

      ; Check zeropage and Memory
check_zp:
      ; Start at $ff
      ldy #0
      ; Start with pattern $03 : $ff
@l2:  ldx #num_patterns-1
@l1:  lda pattern,x
      sta $00,y
      cmp $00,y
      bne zp_broken
      dex
      bpl @l1
      iny
      bne @l2
check_stack:
      ;check stack
@l2:  ldx #num_patterns-1
@l1:  lda pattern,x
      sta $0100,y
      cmp $0100,y
      bne stack_broken
      dex
      bpl @l1
      iny
      bne @l2

      bra zp_stack_ok

zp_broken:
stack_broken:

zp_stack_ok:

      jsr blklayer_init

      jsr init_via1

      lda #<nvram
      ldy #>nvram
      jsr read_nvram

      jsr uart_init ; uses nvram settings, so we have to init after nvram read (with fallback)

      jsr vdp_init

      jsr primm
      .byte "steckOS BIOS   "
      .include "version.inc"
      .byte CODE_LF,0

      jsr vdp_detect

      ;jsr memcheck

      jsr keyboard_init
@sdcard:
      jsr sdcard_detect
      beq @sdcard_init
      println "SD card not found!"
      jmp do_upload
@sdcard_init:
      jsr sdcard_init
      beq boot_from_card
      pha
      print "SD card init failed! "
      pla
      jsr hexout_s
      println ""
      jmp do_upload

boot_from_card:
      print "Boot from SD card... "
      jsr fat_mount
      bcc @findfile
      pha
      print "mount error ("
      pla
      jsr hexout_s
      println ")"
      bra do_upload
@findfile:
      ldy #0
@loop:
      lda nvram+nvram::filename,y
      beq :+
      jsr vdp_chrout
      iny
      bne @loop
:     lda #(<nvram)+nvram::filename
      ldx #>nvram
      ldy #O_RDONLY
      jsr fat_fopen          ; A/X - pointer to filename
      bcc @loadfile
@loop_end:
      println " not found."
      bra do_upload
@loadfile:
      print " found."
      jsr fat_fread_byte  ; start address low
      bcs load_error
      sta startaddr+0
      print_dot

      jsr fat_fread_byte ; start address high
      bcs load_error
      sta startaddr+1
      print_dot
      lda startaddr
      ldy startaddr+1
@l:   jsr fat_fread_vollgas
@l_is_eof:
      pha
      jsr fat_close    ; close after read to free fd, regardless of error
      pla
      cmp #EOK
      beq load_ok
load_error:
      jsr hexout_s
      println " read error"
do_upload:
      jsr xmodem_upload
      bcs load_error
load_ok:
      jsr print_ok
startup:
      ; re-init stack pointer
      ldx #$ff
      txs
      ; jump to new code
      jmp (startaddr)

print_ok:
      jsr primm
      .byte " OK", CODE_LF, 0
      rts

do_nmi:
      save
      lda #Light_Blue<<4|Light_Blue
      jsr vdp_bgcolor
      lda #Gray<<4|Black
      jsr vdp_bgcolor
      restore
      rti

bios_irq:
      save

@check_vdp:
      pla  ; get P state
      pha ; push back
      and #%00010000 ; brk command?
      beq @lvdp
      lda #Magenta<<4|Magenta
      jsr vdp_bgcolor
@lvdp:
      bit a_vreg ; vdp irq ?
      bpl @check_via
      lda #Cyan<<4|Cyan
      jsr vdp_bgcolor
@check_via:
      bit via1ifr    ; Interrupt from VIA?
      bpl @check_opl
      ; via irq handling code - can only be keyboard at the moment
      lda #Light_Yellow<<4|Light_Yellow
      jsr vdp_bgcolor
@check_opl:
      bit opl_stat
      bpl @lok
      lda #Light_Green<<4|Light_Green
      jsr vdp_bgcolor
@lok:
      lda #Gray<<4|Black
      jsr vdp_bgcolor
      restore
      rti

num_patterns = $04
pattern:
      .byte $ff,$aa,$55,$00

.segment "VECTORS"
vdp_chrout:
      jmp vdp_charout
;----------------------------------------------------------------------------------------------
; Interrupt vectors
;----------------------------------------------------------------------------------------------
; $FFFA/$FFFB NMI Vector
.word do_nmi
; $FFFC/$FFFD reset vector
;*= $fffc
.word do_reset
; $FFFE/$FFFF IRQ vector
;*= $fffe
.word bios_irq
