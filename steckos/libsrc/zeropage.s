
;
; zeropage usage

.include      "zeropage.inc"

; ------------------------------------------------------------------------
;.zeropage



.export retvec    = $fff8

.export lba_addr  = $0280   ; 4 bytes
.export blocks    = $0284   ; 1 byte - blocks to read with max sec/cl (volumeID+VolumeID::BPB_SecPerClus)
; $0285 free
; $0286 free
.export key       = $0287   ; 1 byte - keyboard char

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