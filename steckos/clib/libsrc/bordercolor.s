;
; Ullrich von Bassewitz, 06.08.1998
;
; unsigned char __fastcall__ bordercolor (unsigned char color);
;


		  .export _bordercolor

		  .import vdp_bgcolor

_bordercolor=vdp_bgcolor