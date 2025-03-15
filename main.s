.section .text
.global _start
.align 2

@ Memory addresses
.equ REG_DISPCNT,   0x4000000  @ Display control register
.equ BG0CNT,        0x4000008  @ Background 0 Control register
.equ BG0HOFS,       0x4000010  @ BG0 horizontal offset
.equ BG0VOFS,       0x4000012  @ BG0 vertical offset
.equ BG0_CHAR_BASE, 0x6000000  @ Tile Character Base (VRAM for tileset)
.equ BG0_MAP_BASE,  0x6004000  @ Tile Map Base (VRAM for map)
.equ BG_PALETTE,    0x5000000  @ Background palette memory

@ Entry point
_start:
    ldr r0, =REG_DISPCNT
    ldr r1, =0x100            @ Mode 0 | Enable BG0
    str r1, [r0]

    ldr r0, =BG0CNT
    ldr r1, =0x0000           @ Character Base Block 0, Map Base Block 31
    str r1, [r0]

@ Load Palette into Palette RAM
    ldr r0, =BG_PALETTE       @ Load address for palette
    ldr r1, =goal_palette
    mov r2, #256              @ Number of colors to load
palette_load_loop:
    ldrh r3, [r1], #2
    strh r3, [r0], #2
    subs r2, r2, #1
    bne palette_load_loop

@ Load tile graphics into character memory
    ldr r0, =BG0_CHAR_BASE
    ldr r1, =goal_tiles
    mov r2, #(512*8)          @ Number of bytes in tiles (adjust if needed)
tile_load_loop:
    ldmia r1!, {r3-r6}
    stmia r0!, {r3-r6}
    subs r2, r2, #16          @ Process 4 words at a time
    bne tile_load_loop

@ Load tilemap into map memory
    ldr r0, =BG0_MAP_BASE
    ldr r1, =goal_map
    mov r2, #(32*32)          @ Tilemap size (32x32)
map_load_loop:
    ldrh r3, [r1], #2
    strh r3, [r0], #2
    subs r2, r2, #1
    bne map_load_loop

@ Infinite loop to keep program running
loop:
    b loop

@ Background Data
    .section .rodata
goal_tiles:
    .incbin "assets/goal.img.bin"   @ Include tile graphics
goal_map:
    .incbin "assets/goal.map.bin"   @ Include tilemap data
goal_palette:
    .incbin "assets/goal.pal.bin"   @ Include palette data

    .end
