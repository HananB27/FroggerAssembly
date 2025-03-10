.section .text
.arm
.global _start

_start:
    b main

    .space 156             @ Padding for correct header alignment
    .word 0x51AEFF24       @ Nintendo logo data (part of GBA ROM header)
    .word 0x00000000
    .word 0x00000000
    .ascii "TEST"          @ Game title (4 chars)

main:
    ldr r0, =0x04000000    @ Display control register
    mov r1, #0x403         @ Mode 3, BG2 on
    str r1, [r0]

    ldr r0, =0x06000000    @ VRAM base address
    ldr r1, =((120 * 240 + 80) * 2) @ Pixel offset
    add r0, r0, r1

    mov r2, #0x001F        @ Red color
    strh r2, [r0]

loop:
    b loop
