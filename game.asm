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
	mov r0, #0
	str r0, GameLogicFlag_Ptr	;store in memory that gamelogic didnt happen this frame

	mov sp,#0x03000000
	mov r4,#0x04000000
	mov r2,#0x403
	str r2,[r4]

	; Initialize RAM variables
    ldr r4, CurrentFrame_Ptr
    mov r5, #0
    strb r5, [r4]      ; Initialize CurrentFrame to 0

	bl LoadBackground
    b ShowMenu

	mov r8,#52
	mov r9,#146
	and r8, r8, #0xFF
	and r9, r9, #0xFF
	mov r6,#0 ; direction: 0=North, 1=South, 2=West, 3=East

	bl ShowSprite

ShowMenu:
    ; Draw "FROGGER" letters
    bl DrawTitle
    
    ; Check for Start button (Enter)
CheckStart:
    ldrh r0, [r3]
    mvn r0, r0               ; Invert the input (like in your WaitNoInput)
    and r0, r0, #0x08            ; Check Start button (bit 3)
    cmp r0, #0x08
    bne CheckStart           ; If not pressed, keep checking

    b GameInit         ; Jump to your existing game code

DrawTitle:
    STMFD sp!, {r0-r7, lr}

    ; Draw F
    mov r8, #64        ; X position for F (adjusted for 7 letters)
    mov r9, #60        ; Y position for letters
    ldr r4, title_literals
    ldr r7, [r4, #0]
    ldr r1, [r7]
    bl DrawLetter

    ; Draw R
    mov r8, #80        ; X position for R
    ldr r4, title_literals
    ldr r7, [r4, #4]
    ldr r1, [r4]
    bl DrawLetter

    ; Draw O
    mov r8, #96        ; X position for O
    ldr r4, sprite_literals
    ldr r7, [r4, #12]
    ldr r1, [r7]
    bl DrawLetter

    ; Draw G
    mov r8, #112       ; X position for first G
    ldr r4, sprite_literals
    ldr r7, [r4, #16]
    ldr r1, [r7]
    bl DrawLetter

    ; Draw G (second)
    mov r8, #128       ; X position for second G
    ldr r4, sprite_literals
    ldr r7, [r4, #16]
    ldr r1, [r7]
    bl DrawLetter

    ; Draw E
    mov r8, #144       ; X position for E
    ldr r4, sprite_literals
    ldr r7, [r4, #20]
    ldr r1, [r7]
    bl DrawLetter

    ; Draw R (second)
    mov r8, #160       ; X position for final R
    ldr r4, sprite_literals
    ldr r7, [r4, #4]
    ldr r1, [r7]
    bl DrawLetter

    LDMFD sp!, {r0-r7, pc}

.align 4
title_literals:
    .long F_Literal
    .long R_Literal
    .long O_Literal
    .long G_Literal
    .long E_Literal

DrawLetter:
    STMFD sp!, {r0-r7, lr}
    
    mov r10,#0x06000000
    mov r1,#2
    mul r2,r1,r8
    add r10,r10,r2
    mov r1,#240*2
    mul r2,r1,r9
    add r10,r10,r2

    ; r1 already contains the letter sprite data
    mov r4,#16          ; Height
DrawLetter_NextLine:
    mov r5,#16          ; Width
    STMFD sp!,{r10}
DrawLetter_NextByte:
    ldrH r3,[r1],#2
    cmp r3,#0
    beq DrawLetter_SkipPixel
    strH r3,[r10]
DrawLetter_SkipPixel:
    add r10,r10,#2
    subs r5,r5,#1
    bne DrawLetter_NextByte
    LDMFD sp!,{r10}
    add r10,r10,#240*2
    subs r4,r4,#1
    bne DrawLetter_NextLine
    
    LDMFD sp!, {r0-r7, pc}

GameInit:
    mov r0, #0
    str r0, GameLogicFlag_Ptr    ; store in memory that gamelogic didnt happen this frame

    ; Initialize RAM variables
    ldr r4, CurrentFrame_Ptr
    mov r5, #0
    strb r5, [r4]      ; Initialize CurrentFrame to 0

    mov r8,#52
    mov r9,#146
    and r8, r8, #0xFF
    and r9, r9, #0xFF
    mov r6,#0          ; direction: 0=North, 1=South, 2=West, 3=East

    bl ShowSprite

    b MoveOrGame 

MoveOrGame:
	ldr r0, GameLogicFlag_Ptr ;get game logic flag, did the game logic already happen this frame
	ldr r0, [r0]
	cmp r0, #0				;if the GameLogic is 0, do the gamelogic, set flag at end to 1
	beq MoveOncePerFrame
	b MoveOrGame2
	
	

MoveOncePerFrame:
	mov r0, #1
	ldr r1, GameLogicFlag_Ptr
	str r0, [r1]		;put gamelogic flag up
	ldr r0, Vcount_Ptr ;get current vram line rendering
	ldr r0, [r0]
	cmp.b r0, #161		;check if in vblank currently rendering
	bgt GameLogic
	b MoveOrGame2			;else get to the Move part of MoveOrGame
	
MoveOrGame2:
	ldr r1, Delay_Ptr	;get move delay from memory
	ldr r0, [r1]
	cmp.b r0, #0		;if 0, do move logic again, else decrement and go to MoveOrGame
	beq InfLoop
	sub r0,r0,#1			;if not 0, decrement, store, go to MoveOrGame
	ldr r1, Delay_Ptr
	str r0, [r1]
	b MoveOrGame
	
	
InfLoop:
    mov r3, #0x4000130

	
WaitNoInput:
    ; Load previous input (pressed = 1 logic)
    ldr r0, PreviousInput_Ptr
    ldrh r2, [r0]            ; r2 = previous pressed buttons

    ; Load current input
    ldrh r1, [r3]            ; raw input
    mvn r1, r1               ; invert → pressed = 1
    and r1, r1, #0xF0        ; keep only D-pad bits

    ; Store current for next time
    strh r1, [r0]            ; update PreviousInput

    ; If nothing is newly pressed, go back
    ; Check: r1 == 0 → no buttons pressed → go to MoveOrGame
    cmp r1, #0
    beq MoveOrGame

    ; Check if current input equals previous input → still holding → skip
    cmp r1, r2
    beq MoveOrGame

    ; Else → new directional press
	
    mov r0, r1               ; pass current input in r0 if needed
    b DirectionChecks
	
   ; ldrh r0, [r3]
    ;and r0, r0, #0b0000000011110000
    ;cmp r0, #0b0000000011110000
    ;bne WaitNoInput     ; Wait until no buttons pressed
    ;bne MoveOrGame  ; Wait until no buttons pressed, else go to MoveOrGame to decide whether to do game logic or come back


WaitForInput:
    ldrh r1, [r3]
	mov r0, r1
    and r0, r0, #0b0000000011110000
    cmp r0, #0b0000000011110000
    ;beq WaitForInput    ; Wait until a direction is pressed
	beq MoveOrGame		;same ol same ol

DirectionChecks:
	
    bl RemoveSprite

	ldrh r1, [r3]
	mov r0, r1
    and r0, r0, #0b0000000011110000
	
    ; Check directions once per press
    tst r0,#0b0000000001000000 ; Up
    bne CheckDown
    cmp.b r9,#4
    blt CheckDown
    sub.b r9,r9,#12
    mov r6, #0          ; North

    b AfterDirectionCheck

CheckDown:
    tst r0,#0b0000000010000000 ; Down
    bne CheckLeft
    cmp.b r9,#140
    bgt CheckLeft
    add.b r9,r9,#12
    mov r6, #1          ; South
    b AfterDirectionCheck

CheckLeft:
    tst r0,#0b0000000000100000 ; Left
    bne CheckRight
    cmp.b r8,#6
    blt CheckRight
    sub.b r8,r8,#10
    mov r6, #2          ; West
    b AfterDirectionCheck

CheckRight:
    tst r0,#0b0000000000010000 ; Right
    bne AfterDirectionCheck
    cmp.b r8,#126
    bgt AfterDirectionCheck
    add.b r8,r8,#10
    mov r6, #3          ; East

AfterDirectionCheck:
    ; Remove old sprite first
    bl RemoveSprite

    ; Set jump frame for movement
    ldr r4, CurrentFrame_Ptr
    mov r7, #1
    strb r7, [r4]
    bl ShowSprite       ; This will use current r6 value for direction

    ; Small delay for jump frame
    mov r0,#0x5FFF
Delay1:
    subs r0,r0,#1
    bne Delay1

JumpAnimation:
    ; Remove jump frame sprite
    bl RemoveSprite

    ; Reset to normal frame
    ldr r4, CurrentFrame_Ptr
    mov r7, #0
    strb r7, [r4]
    bl ShowSprite       ; This will use current r6 value for direction

    ; Delay before next input
    mov r0,#0x1AFF
	ldr r1, Delay_Ptr
	str r0, [r1]
	b MoveOrGame

GameLogic:
	mov r0, #0
	ldr r1, MoveOncePerFrame	;store gamelogicflag as down
	str r0, [r1]
	cmp.b r8,#136
	bgt OutOfBoundDeath
	cmp.b r8,#0
	blt Death
	b MoveOrGame
	
	
OutOfBoundDeath:

Death:
	mov r8, #60
	mov r9, #60
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

	; Load current animation frame
    ldr r4, CurrentFrame_Ptr
    ldrb r5, [r4]       ; r5 now contains current frame (0 or 1)

    cmp r6, #0          ; Check if facing North
    bne CheckSouth
    cmp r5, #0          ; Check which frame
    bne NorthJump
    adr r4, sprite_literals
    ldr r7, [r4, #0]    ; Load normal sprite
    ldr r1, [r7]
    b AfterLoadFrog

NorthJump:
	adr r4, sprite_literals
	ldr r7, [r4, #4]
	ldr r1, [r7]        ; Two-step load for Frame 1
	b AfterLoadFrog

CheckSouth:
	cmp r6, #1          ; Check if facing South
	bne CheckWest
	cmp r5, #0          ; Check which frame
	bne SouthJump
	adr r4, sprite_literals
	ldr r7, [r4, #8]
	ldr r1, [r7]
	b AfterLoadFrog

SouthJump:
	adr r4, sprite_literals
	ldr r7, [r4, #12]
	ldr r1, [r7]        ; Two-step load for Frame 1
	b AfterLoadFrog

CheckWest:
	cmp r6, #2          ; Check if facing West
	bne CheckEast
	cmp r5, #0          ; Check which frame
   	bne WestJump
	adr r4, sprite_literals
	ldr r7, [r4, #16]
	ldr r1, [r7]
	b AfterLoadFrog

WestJump:
	adr r4, sprite_literals
	ldr r7, [r4, #20]
	ldr r1, [r7]
	b AfterLoadFrog

CheckEast:
	cmp r5, #0          
   	bne EastJump
	adr r4, sprite_literals
	ldr r7, [r4, #24]
	ldr r1, [r7]
	b AfterLoadFrog

EastJump:
	adr r4, sprite_literals
	ldr r7, [r4, #28]
	ldr r1, [r7]

AfterLoadFrog:

.align 4
sprite_literals:
    .long FrogNorth_Literal
    .long FrogNorthJump_Literal
    .long FrogSouth_Literal
    .long FrogSouthJump_Literal
    .long FrogWest_Literal
    .long FrogWestJump_Literal
    .long FrogEast_Literal
    .long FrogEastJump_Literal

	mov r4,#16          ; Changed from r6 to r4
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
    subs r4,r4,#1      ; Changed from r6 to r4
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
    mov r4, #16        ; Changed from r6 to r4 for the counter
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
    subs r4,r4,#1      ; Changed from r6 to r4
    bne RemoveSprite_NextLine
    LDMFD sp!, {r0-r7, pc}

BackgroundData_Ptr: .long BackgroundData

CurrentFrame_Ptr:   .long 0x03000000
;AnimDelay_Ptr:      .long 0x03000001
Delay_Ptr:			.long 0x03005C00
GameLogicFlag_Ptr:	.long 0x03000003
Vcount_Ptr:			.long 0x04000006
PreviousInput_Ptr: 	.long 0x03007F00

 
FrogNorth_Data: .incbin "assets/frogs/frogNorth.img.bin"
FrogSouth_Data: .incbin "assets/frogs/frogSouth.img.bin"
FrogEast_Data:  .incbin "assets/frogs/frogEast.img.bin"
FrogWest_Data:  .incbin "assets/frogs/frogWest.img.bin"

FrogNorthJump_Data:  .incbin "assets/frogs/frogNorthJump.img.bin"  ; Jump frame for north
FrogSouthJump_Data:  .incbin "assets/frogs/frogSouthJump.img.bin"  ; Jump frame for south
FrogEastJump_Data:   .incbin "assets/frogs/frogEastJump.img.bin"   ; Jump frame for east
FrogWestJump_Data:   .incbin "assets/frogs/frogWestJump.img.bin"   ; Jump frame for west

F_Data:  .incbin "assets/letters/title/F.img.bin"
R_Data:  .incbin "assets/letters/title/R.img.bin"
O_Data:  .incbin "assets/letters/title/O.img.bin"
G_Data:  .incbin "assets/letters/title/G.img.bin"
E_Data:  .incbin "assets/letters/title/E.img.bin"

FrogNorth_Literal: .long FrogNorth_Data
FrogSouth_Literal: .long FrogSouth_Data
FrogWest_Literal:  .long FrogWest_Data
FrogEast_Literal:  .long FrogEast_Data

FrogNorthJump_Literal: .long FrogNorthJump_Data
FrogSouthJump_Literal: .long FrogSouthJump_Data
FrogEastJump_Literal:  .long FrogEastJump_Data
FrogWestJump_Literal:  .long FrogWestJump_Data

F_Literal: .long F_Data
R_Literal: .long R_Data
O_Literal: .long O_Data
G_Literal: .long G_Data
E_Literal: .long E_Data

BackgroundData: .incbin "assets/smallmap.img.bin"