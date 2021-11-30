    processor 6502

    seg code
    org $F000           ; define the code origin at $F000

Start:
    sei                 ; disable interrupts
    cld                 ; disable BCD (binary coded decimal) math mode
    ldx #$FF            ; load the X register with the literal value 0xFF (255)
    txs                 ; transfer the X register contents to the stack pointer

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Clear the Page Zero region ($00 to $FF)
; Meaning the entire RAM and also the entire TIA registers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lda #0              ; load the A register with the literal value 0
    ldx #$FF            ; load the X register with the literal value 0xFF
    sta $FF             ; zero 0xFF
MemLoop:
    dex                 ; decrease the X register value, like X--
    sta $0,X            ; store the value of the A register inside the memory address $0 + X register value; no flags updated
    bne MemLoop         ; loop until the "dex" command makes X register 0 (Z flag is set)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Fill the ROM size to exactly 4KB
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    org $FFFC
    .word Start         ; reset vector at 0xFFFC (where the program starts)
    .word Start         ; interrupt vector at 0xFFFE (unused in the VCS)