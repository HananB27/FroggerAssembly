
	.org  0x08000000     ; GBA ROM Address starts at 0x08000000

	b	ProgramStart	;000h    4     ROM Entry Point  (32bit ARM branch opcode, eg. "B rom_start") 
	
;004h    156   Nintendo Logo    (compressed bitmap, required!)
	.byte 0xC8,0x60,0x4F,0xE2,0x01,0x70,0x8F,0xE2,0x17,0xFF,0x2F,0xE1,0x12,0x4F,0x11,0x48     ; C
	.byte 0x12,0x4C,0x20,0x60,0x64,0x60,0x7C,0x62,0x30,0x1C,0x39,0x1C,0x10,0x4A,0x00,0xF0     ; D
    .byte 0x14,0xF8,0x30,0x6A,0x80,0x19,0xB1,0x6A,0xF2,0x6A,0x00,0xF0,0x0B,0xF8,0x30,0x6B     ; E
    .byte 0x80,0x19,0xB1,0x6B,0xF2,0x6B,0x00,0xF0,0x08,0xF8,0x70,0x6A,0x77,0x6B,0x07,0x4C     ; F
    .byte 0x60,0x60,0x38,0x47,0x07,0x4B,0xD2,0x18,0x9A,0x43,0x07,0x4B,0x92,0x08,0xD2,0x18     ; 10
    .byte 0x0C,0xDF,0xF7,0x46,0x04,0xF0,0x1F,0xE5,0x00,0xFE,0x7F,0x02,0xF0,0xFF,0x7F,0x02     ; 11
    .byte 0xF0,0x01,0x00,0x00,0xFF,0x01,0x00,0x00,0x00,0x00,0x00,0x04,0x00,0x00,0x00,0x00     ; 12
    .byte 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00     ; 13
    .byte 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00     ; 14
	.byte 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x1A,0x9E,0x7B,0xEB     ; 15
	
    ;		123456789012
    .ascii "LEARNASM.NET";0A0h    12    Game Title       (uppercase ascii, max 12 characters)	
    .ascii "0000"	;0ACh    4     Game Code        (uppercase ascii, 4 characters)
    .ascii "00"		;0B0h    2     Maker Code       (uppercase ascii, 2 characters)
	.byte 0x96		;0B2h    1     Fixed value      (must be 96h, required!)
	.byte 0			;0B3h    1     Main unit code   (00h for current GBA models)
	.byte 0			;0B4h    1     Device type      (usually 00h) (bit7=DACS/debug related)
	.space 7		;0B5h    7     Reserved Area    (should be zero filled)
	.byte 0			;0BCh    1     Software version (usually 00h)
	.byte 0			;0BDh    1     Complement check (header checksum, required!)
	.word 0			;0BEh    2     Reserved Area    (should be zero filled)
	.long 0			;0C0h    4     RAM Entry Point  (32bit ARM branch opcode, eg. "B ram_start")
	.byte 0			;0C4h    1     Boot mode        (init as 00h - BIOS overwrites this value!)
	.byte 0			;0C5h    1     Slave ID Number  (init as 00h - BIOS overwrites this value!)
	.space 26		;0C6h    26    Not used         (seems to be unused)
	.long 0			;0E0h    4     JOYBUS Entry Pt. (32bit ARM branch opcode, eg. "B joy_start")

ProgramStart:
	mov sp,#0x03000000			;Init Stack Pointer
	
	mov r4,#0x04000000  		;DISPCNT -LCD Control
	mov r2,#0x403    			;4= Layer 2 on / 3= ScreenMode 3
	str	r2,[r4]         	
	
;Sprite Pos
	mov r8,#10					;Xpos
	mov r9,#10					;Ypos
	
	bl ShowSprite				;Show the sprite starting position
	
InfLoop:
	mov r3,#0x4000130			;Read GBA joypad
	ldrh r0,[r3]		
	            ;------lrDULRSsBA
	and r0,r0,#0b0000000011110000
	cmp r0,#0b0000000011110000
	beq InfLoop
	
	bl ShowSprite				;Remove the old sprite
	         ;------lrDULRSsBA
	tst r0,#0b0000000001000000
	bne JoyNotUp
	cmp.b r9,#0
	beq JoyNotUp
	sub.b r9,r9,#1				;Move Up
JoyNotUp:	
			 ;------lrDULRSsBA
	tst r0,#0b0000000010000000
	bne JoyNotDown
	cmp.b r9,#160-8
	beq JoyNotDown
	add.b r9,r9,#1				;Move Down
JoyNotDown:	
	         ;------lrDULRSsBA
	tst r0,#0b0000000000100000
	bne JoyNotLeft
	cmp.b r8,#0
	beq JoyNotLeft
	sub.b r8,r8,#1				;Move Left
JoyNotLeft:	
			 ;------lrDULRSsBA
	tst r0,#0b0000000000010000
	bne JoyNotRight
	cmp.b r8,#240-8
	beq JoyNotRight
	add.b r8,r8,#1				;Move Right
JoyNotRight:	

	bl ShowSprite				;Show the new sprite position

	mov r0,#0x1FFF				;Delay Loop
Delay:	
	subs r0,r0,#1
	bne Delay
	b InfLoop					;Repeat.
	
;Xor Sprite, drawing twice will remove sprite from screen.
ShowSprite:
	mov r10,#0x06000000 		;VRAM base
	
	mov r1,#2					;2 bytes per pixel
	mul r2,r1,r8
	add r10,r10,r2				;Xpos *2
	
	mov r1,#240*2				;240 pixels per line, 2 bytes per pixel
	mul r2,r1,r9
	add r10,r10,r2				;Ypos * 240*2
	
	ldr r1,Frog_TileData_Ptr		;Sprite Address
	mov r6,#16					;Height
Sprite_NextLine:	
	mov r5,#16					;Width (in words / pixels)

	STMFD sp!,{r10}
Sprite_NextByte:
		ldrH r3,[r1],#2			;Must write 16/32bit per VRAM write 
		ldrH r2,[r10]
		eor r3,r3,r2			;Eor Word from screen
		strH r3,[r10],#2
		
		subs r5,r5,#1			;X Loop
		bne Sprite_NextByte
	LDMFD sp!,{r10}		
	add r10,r10,#240*2			;240 - 2 bytes per pixel
	subs r6,r6,#1
	bne Sprite_NextLine			;Y loop
	mov pc,lr

Frog_TileData_Ptr:
    .long Frog_TileData
	
Frog_TileData:
    .incbin "assets/frogs/frog1.img.bin"



	
	