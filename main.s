	.equ MODE3, 0x0003
	.equ BG2_ENABLE, 0x0400
	.equ REG_DISPCNT, 0x4000000
	.equ VRAM, 0x6000000
	.equ SCREEN_WIDTH, 240
	.equ SCREEN_HEIGHT, 160

	.syntax unified
	.cpu arm7tdmi
	.text
	.global main

	.section .rodata
    .align 4
    .global frog1_img_bin
    .type frog1_img_bin, %object
    .size frog1_img_bin, 512
    frog1_img_bin:
    .incbin "assets/frogs/frog1.img.bin"

    .global background_img_bin
    .type background_img_bin, %object
    .size background_img_bin, SCREEN_WIDTH * SCREEN_HEIGHT * 2
    background_img_bin:
    .incbin "assets/map/map.img.bin"

main:
	@ Set mode 3 and enable BG2
	ldr r0, =REG_DISPCNT
	ldr r1, =MODE3 | BG2_ENABLE
	strh r1, [r0]

	@ Load background image
	ldr r4, =background_img_bin  @ Pointer to background image data
	ldr r5, =VRAM                @ Video memory location
	ldr r6, =SCREEN_WIDTH * SCREEN_HEIGHT  @ Total pixels

load_background:
	ldrh r7, [r4], #2    @ Load pixel from background image
	strh r7, [r5], #2    @ Store to VRAM
	subs r6, r6, #1       @ Decrement counter
	bne load_background  @ Continue until done

	@ Load frog image
	ldr r4, =frog1_img_bin  @ Pointer to image data
	ldr r5, =VRAM           @ Video memory location
	ldr r6, =16             @ Frog width
	ldr r7, =16             @ Frog height

	@ Set position (X=100, Y=70)
	mov r8, #100
	mov r9, #70

	@ Compute VRAM offset: (y * SCREEN_WIDTH + x) * 2
	mov r10, #SCREEN_WIDTH
	mul r10, r9, r10       @ r10 = y * SCREEN_WIDTH
	add r5, r5, r10, lsl #1  @ VRAM address += y offset
	add r5, r5, r8, lsl #1   @ VRAM address += x offset

draw_frog:
	push {r6, r7, r11}    @ Save width, height

draw_row:
	ldrh r11, [r4], #2    @ Load pixel from image
	strh r11, [r5], #2    @ Store to VRAM
	subs r6, r6, #1       @ Decrement width counter
	bne draw_row

	@ Move to next row
	ldr r6, =16
	add r5, r5, #(SCREEN_WIDTH - 16) * 2  @ Move to next row in VRAM
	subs r7, r7, #1       @ Decrement height counter
	bne draw_frog

	pop {r6, r7, r11}     @ Restore registers
	b .                   @ Infinite loop
