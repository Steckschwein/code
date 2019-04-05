;
; Ullrich von Bassewitz, 06.08.1998
;
; unsigned char __fastcall__ textcolor (unsigned char color);
; unsigned char __fastcall__ bgcolor (unsigned char color);
;


        .export         _textcolor, _bgcolor

        .import vdp_bgcolor

_textcolor:
        asl
        asl
        asl
        asl
_bgcolor:
        jmp vdp_bgcolor
