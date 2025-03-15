
    .section .text
    .global read_keys
    .align 2

@ Memory addresses
.equ REG_KEYINPUT, 0x4000130  @ Key input register (GBA)

@ Key Masks (Buttons are active low)
.equ KEY_A,      0x0001
.equ KEY_B,      0x0002
.equ KEY_SELECT, 0x0004
.equ KEY_START,  0x0008
.equ KEY_RIGHT,  0x0010
.equ KEY_LEFT,   0x0020
.equ KEY_UP,     0x0040
.equ KEY_DOWN,   0x0080
.equ KEY_R,      0x0100
.equ KEY_L,      0x0200

@ Function: read_keys
@ Reads key input and stores it in r0 (bitmask of pressed keys)
read_keys:
    ldr r0, =REG_KEYINPUT  @ Load address of key input register
    ldrh r1, [r0]          @ Read 16-bit value (active low)
    mvn r0, r1            @ Invert bits so 1 means pressed
    bx lr                 @ Return
