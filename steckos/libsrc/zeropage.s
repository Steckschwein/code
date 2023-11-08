
;
; zeropage usage

.include      "zeropage.inc"

; ------------------------------------------------------------------------
.zeropage

; shell related - TODO FIXME away from kernel stuff, conflicts with basic. but after basic start, we dont care about shell zp. maybe if we want to return to shell one day !!!
.exportzp cmdptr    = $e0
.exportzp paramptr  = $e2

; pointer and temps - internally used by library
.exportzp s_ptr1  = $e4  ; 2 bytes
.exportzp s_ptr2  = $e6  ; 2 bytes
.exportzp s_ptr3  = $e8  ; 2 bytes

.exportzp s_tmp1  = $ea
.exportzp s_tmp2  = s_tmp1+1  ; single byte
.exportzp s_tmp3  = s_tmp1+2  ; single byte

; have to use fixed zp locations to avoid ehbasic clashes
.exportzp vdp_ptr   =$ed
.exportzp vdp_tmp   =$ef

; FAT32
.exportzp filenameptr   = $f0  ; 2 byte
.exportzp dirptr        = $f2  ; 2 byte

; SDCARD/storage block pointer
.exportzp read_blkptr    = $f4
.exportzp write_blkptr   = $f6

; spi shift register location
.exportzp spi_sr            = $f9
.exportzp __volatile_ptr    = $fa
.exportzp __volatile_tmp    = $fc

; flags/signals (like ctrl-c, etc)
.exportzp flags             = $fd

;.exportzp ansi_state       = $f9
;.exportzp ansi_index       = $fa
;.exportzp ansi_param1      = $fb
;.exportzp ansi_param2      = $fc

.export retvec    = $fff8

.export lba_addr  = $0280    ; 4 bytes
.export blocks    = $0284    ; 3 bytes blocks to read, 3 bytes sufficient to address 4GB -> 4294967296 >> 9 = 8388608 ($800000) max blocks/file
.export key       = $0287   ; 1 byte keyboard char

; video mode register
.export video_mode   = $0288
                ; TODO not implemented/used yet - bit 0-4 - video mode bits - m1-m5 refer to msx spec. - e.g.
                ;   TEXT1 - 00001
                ;   TEXT2 - 01001
                ;   MC    - 00010
                ;   G1    - 00000
                ;   G2    - 00100
                ;   G3    - 01000
                ; bit 6 - text mode with 0 - 40 / 1 - 80 columns
                ; bit 7 - 0 - NTSC / 1 - PAL


; custom isr, aligned with v-blank, called by kernel on each frame
.export user_isr  = $0289
; TEXTUI
.export crs_x      = $028b
.export crs_y      = $028c