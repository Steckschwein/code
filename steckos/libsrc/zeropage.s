;
; zeropage usage

.include        "zeropage.inc"

; ------------------------------------------------------------------------
.zeropage
ptr1:           .res 2
ptr2:           .res 2
ptr3:           .res 2
ptr4:           .res 2
ptr5:           .res 2
ptr6:           .res 2
tmp1:           .res 1
tmp2:           .res 1
tmp3:           .res 1
tmp4:           .res 1

; have to use fixed zp locations to avoid ehbasic clashes
.exportzp vdp_ptr :=$ec
.exportzp vdp_tmp :=$ed