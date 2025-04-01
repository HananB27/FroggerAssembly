    .org  0x08000000     ; GBA ROM Address starts at 0x08000000

	b	ProgramStart	;000h    4     ROM Entry Point

; Nintendo Logo (required)
	.byte 0xC8,0x60,0x4F,0xE2,0x01,0x70,0x8F,0xE2,0x17,0xFF,0x2F,0xE1,0x12,0x4F,0x11,0x48
	.byte 0x12,0x4C,0x20,0x60,0x64,0x60,0x7C,0x62,0x30,0x1C,0x39,0x1C,0x10,0x4A,0x00,0xF0
	.byte 0x14,0xF8,0x30,0x6A,0x80,0x19,0xB1,0x6A,0xF2,0x6A,0x00,0xF0,0x0B,0xF8,0x30,0x6B
	.byte 0x80,0x19,0xB1,0x6B,0xF2,0x6B,0x00,0xF0,0x08,0xF8,0x70,0x6A,0x77,0x6B,0x07,0x4C
	.byte 0x60,0x60,0x38,0x47,0x07,0x4B,0xD2,0x18,0x9A,0x43,0x07,0x4B,0x92,0x08,0xD2,0x18
	.byte 0x0C,0xDF,0xF7,0x46,0x04,0xF0,0x1F,0xE5,0x00,0xFE,0x7F,0x02,0xF0,0xFF,0x7F,0x02
	.byte 0xF0,0x01,0x00,0x00,0xFF,0x01,0x00,0x00,0x00,0x00,0x00,0x04,0x00,0x00,0x00,0x00
	.byte 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
	.byte 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
	.byte 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x1A,0x9E,0x7B,0xEB

    .ascii "LEARNASM.NET"
    .ascii "0000"
    .ascii "00"
	.byte 0x96
	.byte 0
	.byte 0
	.space 7
	.byte 0
	.byte 0
	.word 0
	.long 0
	.byte 0
	.byte 0
	.space 26
	.long 0

ProgramStart:
	mov sp,#0x03000000
	mov r4,#0x04000000
	mov r2,#0x403
	str r2,[r4]

	bl LoadBackground

	mov r8,#10
	mov r9,#10
	mov r6,#0 ; direction: 0=North, 1=South, 2=West, 3=East

	bl ShowSprite

InfLoop:
	mov r3,#0x4000130
	ldrh r0,[r3]
	and r0,r0,#0b0000000011110000
	cmp r0,#0b0000000011110000
	beq InfLoop

	bl RemoveSprite

	tst r0,#0b0000000001000000 ; Up
	bne JoyNotUp
	cmp.b r9,#0
	beq JoyNotUp
	sub.b r9,r9,#4
	mov r6, #0
JoyNotUp:
	tst r0,#0b0000000010000000 ; Down
	bne JoyNotDown
	cmp.b r9,#160-8
	beq JoyNotDown
	add.b r9,r9,#4
	mov r6, #1
JoyNotDown:
	tst r0,#0b0000000000100000 ; Left
	bne JoyNotLeft
	cmp.b r8,#0
	beq JoyNotLeft
	sub.b r8,r8,#4
	mov r6, #2
JoyNotLeft:
	tst r0,#0b0000000000010000 ; Right
	bne JoyNotRight
	cmp.b r8,#240-8
	beq JoyNotRight
	add.b r8,r8,#4
	mov r6, #3
JoyNotRight:

	bl ShowSprite

	mov r0,#0x1FFF
Delay:
	subs r0,r0,#1
	bne Delay
	b InfLoop

LoadBackground:
	STMFD sp!, {r0-r7, lr}
	mov r0, #0x06000000
	ldr r1, BackgroundData_Ptr
	mov r2, #240*160
BackgroundCopy:
	ldrh r3, [r1], #2
	strh r3, [r0], #2
	subs r2, r2, #1
	bne BackgroundCopy
	LDMFD sp!, {r0-r7, pc}

ShowSprite:
	mov r10,#0x06000000
	mov r1,#2
	mul r2,r1,r8
	add r10,r10,r2
	mov r1,#240*2
	mul r2,r1,r9
	add r10,r10,r2

	cmp r6, #0
	beq LoadNorth
	cmp r6, #1
	beq LoadSouth
	cmp r6, #2
	beq LoadWest
	cmp r6, #3
	beq LoadEast
	b AfterLoadFrog

LoadNorth:
	ldr r1, FrogNorth_Literal
	b AfterLoadFrog
LoadSouth:
	ldr r1, FrogSouth_Literal
	b AfterLoadFrog
LoadWest:
	ldr r1, FrogWest_Literal
	b AfterLoadFrog
LoadEast:
	ldr r1, FrogEast_Literal

AfterLoadFrog:
	mov r6,#16
Sprite_NextLine:
	mov r5,#16
	STMFD sp!,{r10}
Sprite_NextByte:
	ldrH r3,[r1],#2
	cmp r3,#0
	beq Sprite_SkipPixel
	strH r3,[r10]
Sprite_SkipPixel:
	add r10,r10,#2
	subs r5,r5,#1
	bne Sprite_NextByte
	LDMFD sp!,{r10}
	add r10,r10,#240*2
	subs r6,r6,#1
	bne Sprite_NextLine
	mov pc,lr

RemoveSprite:
	STMFD sp!, {r0-r7, lr}
	mov r10,#0x06000000
	mov r1,#2
	mul r2,r1,r8
	add r10,r10,r2
	mov r1,#240*2
	mul r2,r1,r9
	add r10,r10,r2
	ldr r0, BackgroundData_Ptr
	mov r1, r9
	mov r2, #240
	mul r3, r1, r2
	add r3, r3, r8
	mov r2, #2
	mul r3, r2, r3
	add r0, r0, r3
	mov r6, #16
RemoveSprite_NextLine:
	mov r5, #16
	STMFD sp!,{r10, r0}
RemoveSprite_NextByte:
	ldrH r3,[r0],#2
	strH r3,[r10],#2
	subs r5,r5,#1
	bne RemoveSprite_NextByte
	LDMFD sp!,{r10, r0}
	add r10,r10,#240*2
	add r0, r0, #240*2
	subs r6,r6,#1
	bne RemoveSprite_NextLine
	LDMFD sp!, {r0-r7, pc}

BackgroundData_Ptr: .long BackgroundData

FrogNorth_Data: .incbin "assets/frogs/frogNorth.img.bin"
FrogSouth_Data: .incbin "assets/frogs/frogSouth.img.bin"
FrogEast_Data:  .incbin "assets/frogs/frogEast.img.bin"
FrogWest_Data:  .incbin "assets/frogs/frogWest.img.bin"

FrogNorth_Literal: .long FrogNorth_Data
FrogSouth_Literal: .long FrogSouth_Data
FrogWest_Literal:  .long FrogWest_Data
FrogEast_Literal:  .long FrogEast_Data

BackgroundData: .incbin "assets/background.img.bin"
