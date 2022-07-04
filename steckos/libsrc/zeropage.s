
;
; zeropage usage

.include		  "zeropage.inc"

; ------------------------------------------------------------------------
.zeropage

; shell related - TODO FIXME away from kernel stuff, conflicts with basic. but after basic start, we dont care about shell zp. maybe if we want to return to shell one day !!!
.exportzp cmdptr    = $d6
.exportzp paramptr  = $d8

; TEXTUI
.exportzp crs_ptr   = $e0

; pointer and temps - internally used by library
.exportzp s_ptr1	= $e2	; 2 bytes
.exportzp s_ptr2	= $e4	; 2 bytes
.exportzp s_ptr3	= $e6	; 2 bytes

.exportzp s_tmp1	= $e8
.exportzp s_tmp2	= s_tmp1+1	; single byte
.exportzp s_tmp3	= s_tmp1+2	; single byte

; have to use fixed zp locations to avoid ehbasic clashes
.exportzp vdp_ptr   =$ec
.exportzp vdp_tmp   =$ee

; FAT32
.exportzp filenameptr   = $f0	; 2 byte
.exportzp dirptr        = $f2	; 2 byte

; SDCARD/storage block pointer
.exportzp read_blkptr  	= $f4
.exportzp write_blkptr 	= $f6
.exportzp sd_tmp		= $f8

; spi shift register location
.exportzp spi_sr        = $f9
.exportzp __volatile_ptr = $fa
.exportzp __volatile_tmp = $fc

; flags/signals (like ctrl-c, etc)
.exportzp flags         = $fd


;.exportzp ansi_state			 = $f9
;.exportzp ansi_index			 = $fa
;.exportzp ansi_param1			= $fb
;.exportzp ansi_param2			= $fc

.export retvec    = $fff8

; custom isr, aligned with v-blank, called by kernel on each frame
.export user_isr	= $028a
