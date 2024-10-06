; Title: BrainFuck 6502 Interpreter for the Apple ][ //e
; File: BF6502A2.VER3B.S
;
; CPU: 6502
; Platform: Apple ][ //e
; By: Michael Pohoreski
; Date: Dec, 2008
; Last updated: Jul, 2015
; Description: 187 Byte Interpreter of BrainFuck
; Version 3b
;    - No new functionality
;    - Cleaned up source code for readability
;    - Switched to Merlin directives
; License: BSD "Sharing is Caring!"
; https://github.com/Michaelangel007/brainfuck6502
;
; Discussion:
; https://groups.google.com/d/msg/comp.emulators.apple2/Om3JKqDZoEA/cwa5U1Hr3TAJ
;
; Definition:
; http://en.wikipedia.org/wiki/Brainfuck
;
; >  ++pData;
; <  --pData;
; +  ++(*pData);
; -  --(*pData);
; .  putchar(*pData);
; ,  *pData=getchar();
; [  while (*pData) { // if( *pData == 0 ), pCode = find_same_depth ( ']' );
; ]  }                // if( *pData != 0 ), pCode = find_same_depth ( '[' );
;
; Reference Tests:
; http://esoteric.sange.fi/brainfuck/bf-source/prog/tests.b
;
; Examples:
; http://esoteric.sange.fi/brainfuck/bf-source/prog/
; http://esolangs.org/wiki/Brainfuck#Implementations
; http://www.muppetlabs.com/~breadbox/bf/standards.html
; http://software.xfx.net/utilities/vbbfck/index.php
; http://nesdev.parodius.com/6502.txt

; ===================================================================
; Source
; This was hand-assembled so don't blame me if this doesn't assemble.
; Well, technically you can, but I'm to lazy to fix it.
; Send me a patch and I'll try to update it.
; Merlin has a 64 char limit of OPERAND+COMMENT
; So you'll probably run into that issue
; One day you'll be able to assemble this directly inside AppleWin

; Adapted for SteckOS and 65C02ized by Thomas Woinke 2024
; Original comments preserved for historic purposes


.include "steckos.inc"
.include "fat32.inc"
.include "fcntl.inc"
.include "errno.inc"

.export char_out=krn_chrout
.import hexout,primm

data_buf = $4000
code_buf = $8000
appstart $1000

.zeropage
data_ptr:       .res 2
code_ptr:       .res 2
input_ptr:      .res 2

CUR_DEPTH:      .res 1 ; // current nested depth
NUM_BRACKET:    .res 1 ; // depth to find[]


.code
        lda #<data_buf
        sta data_ptr
        sta input_ptr

        lda #>data_buf
        sta data_ptr+1
        sta input_ptr+1

        lda #<code_buf
        sta code_ptr
        
        lda #>code_buf
        sta code_ptr+1
        
        
        ; wipe data area $4000 - $7fff
@loop:
        lda #0
        ldy #$ff
:
        dey
        sta (input_ptr),y 
        bne :-
   
        lda input_ptr+1
        inc a 
        sta input_ptr+1

        cmp #$80
        bne @loop




        lda #<code_buf
        sta input_ptr
        lda #>code_buf
        sta input_ptr+1


        lda (paramptr)
        beq @input

        lda paramptr
        ldx paramptr+1
        ldy #O_RDONLY
        jsr krn_fopen
        bcs @ferror

:
        jsr krn_fread_byte 
        bcs @close
        sta (input_ptr)
        inc16 input_ptr
        bra :-

@close:
        jsr krn_close
        bra @input_done
@ferror:
        jsr primm
        .byte "file open error",$0a,$0d,0
        jmp (retvec)

@input:
        keyin
        cmp #13
        beq @input_done
        jsr char_out
        sta (input_ptr)
        inc16 input_ptr
        bra @input
@input_done:
        lda #0
        sta (input_ptr)

        crlf

; Used to read start address of $0806 = first Applesoft token
; If you use Applesoft as a helper text entry such as
;    0 "...brainfuck code..."
; You must manually move the BF code to $6000 via:
;     CALL -151
;     6000<806.900M
;     300G

        ; ORG $300
;       STA CLRTEXT     ; 8D 50 C0 ; Optional: C051 or C050

        ; JSR HGR         ; 20 D8 F3 ; Clear top 8K of data
        ; JSR HGR2        ; 20 E2 F3 ; Clear bot 8K of data

        ; LDY #$00        ; A0 00    ;
        ; STY code_ptr        ; 84 3C    ;
        ; STY data_ptr        ; 84 40    ;
        STZ CUR_DEPTH   ; 84 EE    ;

; Code needs to end with a zero byte 
; DEFAULT:  $60/$20 for   big code ($6000..$BFFF = 24K) / medium data ($2000..$5FFF = 16K)
; Optional: $08/$10 for small code ($0800..$0FFF =  2K) / large  data ($1000..$BFFF = 44K)
; Note: You will also need to zero memory if you use large data
        ; LDA #$60        ; A9 60    ; Start CODE buffer
        ; STA code_ptr+1      ; 85 3D    ;
        ; LDA #$20        ; A9 20    ; Start data_ptr buffer
        ; STA data_ptr+1      ; 85 41    ;
        ; ldy #$ff
        ; LDA #0

fetch:
        lda (code_ptr)
        beq exit
        
        jsr interpret

        inc16 code_ptr

        bra fetch
exit:
        jmp (retvec)


interpret:
        ldy #7
@find_opcode:
        cmp OPCODE,y
        beq exec 
        dey 
        bpl @find_opcode
        rts
exec:   
        tya
        asl
        tax

        lda (data_ptr)
        jmp (OPFUNCPTR,x)

BF_NEXT:
        inc16 data_ptr
        rts
BF_PREV:
        dec16 data_ptr
EXIT_2:
        RTS             ; 60       ;

BF_INC:
        ; lda (data_ptr)
        inc A
        sta (data_ptr)
        rts
BF_DEC:
        ; lda (data_ptr)
        dec A
        sta (data_ptr)
        rts
BF_IN:
        keyin 
        sta (data_ptr)
        rts
BF_OUT:
        ; lda (data_ptr)
        jsr char_out
        rts

BF_IF:                  ;          ; if( *pData == 0 ) pc = ']'
        INC CUR_DEPTH   ; E6 EE    ; *** depth++

        LDA (data_ptr)  ; B1 40    ; optimization: common code
        BNE EXIT_2      ; D0 E3    ; optimization: BEQ .1, therefore BNE RTS
        LDA CUR_DEPTH   ; A5 EE    ; match_depth = depth
        STA NUM_BRACKET ; 85 EF    ;
@L2:                                 ; Sub-Total Bytes #101
        ; JSR NXTA1+8     ; 20 C2 FC ; optimization: INC A1L, BNE +2, INC A1H, RTS
        inc16 code_ptr
        
        LDA (code_ptr)  ; B1 3C    ;
        CMP #'['        ; C9 5B    ; ***
        BNE @L4         ; D0 04    ;
        INC NUM_BRACKET ; E6 EF    ; *** inc stack
        BNE @L2         ; D0 F3    ;
@L4:
        CMP #']'         ; C9 5D    ; ***
        BNE @L2         ; D0 EF    ;
        LDA CUR_DEPTH   ; A5 EE    ;
        CMP NUM_BRACKET ; C5 EF    ;
        BEQ EXIT_2      ; F0 C8    ;
        DEC NUM_BRACKET ; C6 EF    ; *** dec stack
        CLC             ; 18       ;
        BCC @L2         ; 90 E4    ;
        
BF_FI:                  ;          ; if( *pData != 0 ) pc = '['
        DEC CUR_DEPTH   ; C6 EE    ; depth--
        LDA (data_ptr)  ; B1 40    ;
        BEQ EXIT_2      ; F0 BD    ; optimization: BNE .1, therefore BEQ RTS
        LDA CUR_DEPTH   ; A5 EE    ; match_depth = depth
        STA NUM_BRACKET ; 85 EF    ;
@L2:
        dec16 code_ptr

        LDA (code_ptr)  ; B1 3C    ;
        CMP #']'        ; C9 5D    ;
        BNE @L4         ; D0 04    ;
        DEC NUM_BRACKET ; C6 EF    ; dec stack
        BNE @L2         ; D0 EE    ;
@L4:
        CMP #'['        ; C9 5B    ;
        BNE @L2         ; D0 EA    ;
        LDA CUR_DEPTH   ; A5 EE    ;
        CMP NUM_BRACKET ; C5 EF    ;
        BEQ EXIT_2      ; F0 9D    ;
        INC NUM_BRACKET ; E6 EF    ; dec stack
        CLC             ; 18       ;
        BCC @L2         ; 90 DF    ;
        

OPCODE:
        .byte ",.[<]>-+"  ;          ; sorted: 2B 2C 2D 2E 3C 3E 5B 5D
OPFUNCPTR:               ;          ; by usage: least commonly called to most
        .word BF_IN    ; 4D       ; ,
        .word BF_OUT   ; 54       ; .
        .word BF_IF    ; 59       ; [
        .word BF_PREV  ; 3A       ; <
        .word BF_FI    ; 7F       ; ]
        .word BF_NEXT  ; 37       ; >
        .word BF_DEC   ; 46       ; -
        .word BF_INC   ; 43       ; +
.data 
; code_buf:
        ; Hello World!
        ; .asciiz "++++++++++[>+++++++>++++++++++>+++>+<<<<-]>++.>+.+++++++..+++.>++.<<+++++++++++++++.>.+++.------.--------.>+.>." 