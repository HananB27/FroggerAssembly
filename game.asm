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
	ldr r1, GameLogicFlag_Ptr
	str r0, [r1]	;store in memory that gamelogic didnt happen this frame

	mov sp,#0x03000000
	mov r4,#0x04000000
	mov r2,#0x403
	str r2,[r4]


	; Initialize RAM variables
    ldr r4, CurrentFrame_Ptr
    mov r5, #0
    strb r5, [r4]      ; Initialize CurrentFrame to 0

	bl LoadBackground



	mov r8,#52
	mov r9,#146
	and r8, r8, #0xFF
	and r9, r9, #0xFF
	mov r6,#0 ; direction: 0=North, 1=South, 2=West, 3=East

	bl ShowSprite

	;LANE 1 FIRST RENDER

	mov r4, #132			;CAR 1 vertical pos

	mov r0, #-16
	mov r5, #3
	mov r3,#-16
	bl ShowSpriteXor
	mov r0, #-16
	ldr r1, FirstObjectPosition
	mov r3,r0, asl #8
	str r3,[r1]
	mov r3, #-16+70
	mov r5, #3
	bl ShowSpriteXor

	;LANE 2 FIRST RENDER
	mov r4, #118			;CAR 1 vertical pos

	mov r0, #-16
	mov r3,#-16
	mov r5, #1
	bl ShowSpriteXor
	mov r0, #-16
	ldr r1, SecondObjectPosition
	mov r3,r0, asl #8
	str r3,[r1]
	mov r3, #30
	mov r5, #1
	bl ShowSpriteXor

    ;LANE 3 FIRST RENDER
    mov r4, #104			;CAR 3 vertical pos (new position between lanes 1 and 2)

    mov r0, #-16
    mov r5, #4              ; Use car sprite 4
    mov r3,#-16
    bl ShowSpriteXor
    mov r0, #-16
    ldr r1, ThirdObjectPosition
    mov r3,r0, asl #8
    str r3,[r1]
    mov r3, #-16+70
    mov r5, #4
    bl ShowSpriteXor


MoveOrGame:

	ldr r0, Vcount_Ptr
	ldr r1, [r0]
	cmp r1, #160
	blt SetFlagUp
	ldr r0, GameLogicFlag_Ptr
	ldr r1,[r0]
	cmp r1,#1
	beq GameLogic

	;check if not in blank, if not, check flag to render once in vblank
	;if blank, check flag should i render
	;once rendered, set flag not to render

SetFlagUp:
	ldr r0, GameLogicFlag_Ptr
	mov r1,#1
	str r1,[r0]

	b MoveOrGame2




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
    cmp.b r9,#15
    blt CheckDown
    sub.b r9,r9,#14
    mov r6, #0          ; North

    b AfterDirectionCheck

CheckDown:
    tst r0,#0b0000000010000000 ; Down
    bne CheckLeft
    cmp.b r9,#140
    bgt CheckLeft
    add.b r9,r9,#14
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
	mov r1, #0
	ldr r0, GameLogicFlag_Ptr
	str r1, [r0]		;Set GameLogicFlag_Ptr as down, do not tick again until out of vblank

	;LANE 1 FIRST RENDER
	mov r4, #132			;car 1 vertical pos

	ldr r0, FirstObjectPosition
	ldr r1,[r0]
	mov r3, r1, asr #8
	mov r5,#3


	bl ShowSpriteXor			;derender sprite1

	ldr r0, FirstObjectPosition
	ldr r1,[r0]
	mov r3, r1, asr #8			;get pixel
	add r3,r3,#70				;second car offset
	cmp r3,#150
	blt DontWrapValue
	sub r3,r3,#166
DontWrapValue:
	mov r5, #3
	bl ShowSpriteXor			;derender sprite2

	ldr r0, FirstObjectPosition
	ldr r1,[r0]
	add r1,r1, #60				;add subpixel
	mov r3, r1, asr #8			;get pixel

	cmp r3,#150					;wrap around
	blt KeepValue
	;mov r3,#-16
	sub r3,r3,#166
	mov r1, r3, lsl#8
KeepValue:
	str r1,[r0]
	mov r5, #3

	;r3 contains pixel value of car, r9 contains vertical of frog, check if frog is in lane, and if he is, check the horizontal.
	;r0, r1 and r2 are free
	add r1, r9, #16

	bl ShowSpriteXor			;render sprite1
	ldr r0, FirstObjectPosition
	ldr r1,[r0]
	mov r3, r1, asr #8			;get pixel
	add r3,r3,#70
	cmp r3,#150
	blt DontWrapValue11
	sub r3,r3,#166
DontWrapValue11:
	mov r5, #3
	bl ShowSpriteXor			;render sprite 2

	cmp r9,#132			;frog vertical position equal to only possible position in this lane
	bne SkipCollisionLane1
	ldr r0, FirstObjectPosition
	ldr r1,[r0]
	mov r3, r1, asr #8			;get pixel
	mov     r1, r3          ; r1 = obj1.x
    add     r2, r1, #14     ; r2 = obj1.x + 14
    cmp     r2, r8          ; if (obj1.x + 14 <= obj2.x)
    ble     NoCollision1     ;    no collision

    add     r2, r8, #12     ; r2 = obj2.x + 12
    cmp     r2, r3          ; if (obj2.x + 12 <= obj1.x)
    ble     NoCollision1     ;    no collision

    b       Death           ; Collision occurred

NoCollision1:
	ldr r0, FirstObjectPosition
	ldr r1,[r0]
	mov r3, r1, asr #8			;get pixel
	add r3,r3,#70
	cmp r3,#150
	blt DontWrapValue115
	sub r3,r3,#166
DontWrapValue115:
	mov     r1, r3          ; r1 = obj1.x
    add     r2, r1, #14     ; r2 = obj1.x + 14
    cmp     r2, r8          ; if (obj1.x + 14 <= obj2.x)
    ble     NoCollision2     ;    no collision

    add     r2, r8, #12     ; r2 = obj2.x + 12
    cmp     r2, r3          ; if (obj2.x + 12 <= obj1.x)
    ble     NoCollision2     ;    no collision

    b       Death           ; Collision occurred


NoCollision2:


;LANE 1 END
;--------------------------------------------------------
;LANE 2 FIRST RENDER
;car GOING LEFT

SkipCollisionLane1:
	mov r4, #118			;car 1 vertical pos

	ldr r0, SecondObjectPosition
	ldr r1,[r0]
	mov r3, r1, asr #8
	mov r5, #1
	bl ShowSpriteXor			;derender sprite1

	ldr r0, SecondObjectPosition
	ldr r1,[r0]
	mov r3, r1, asr #8			;get pixel
	add r3,r3,#-120				;second car offset
	cmp r3,#-16				;less than -16 for left
	bgt DontWrapValue2
	add r3,r3,#166			;add
DontWrapValue2:
	mov r5, #1
	bl ShowSpriteXor			;derender sprite2

	ldr r0, SecondObjectPosition
	ldr r1,[r0]
	add r1,r1, #-200				;add subpixel, now -
	mov r3, r1, asr #8			;get pixel

	cmp r3,#-16				;wrap around, from left
	bgt KeepValue2
	;mov r3,#-16
	add r3,r3,#166			;add for left
	mov r1, r3, lsl#8
KeepValue2:
	str r1,[r0]
	mov r5, #1
	bl ShowSpriteXor			;render sprite1
	ldr r0, SecondObjectPosition
	ldr r1,[r0]
	mov r3, r1, asr #8			;get pixel
	add r3,r3,#-120				;second car offset
	cmp r3,#-16					;-16
	bgt DontWrapValue22
	add r3,r3,#166				;add
DontWrapValue22:
	mov r5, #1
	bl ShowSpriteXor			;render sprite 2
	;;COLLISION FOR LANE 2
	cmp r9,#118			;frog vertical position equal to only possible position in this lane
	bne SkipCollisionLane12
	ldr r0, SecondObjectPosition
	ldr r1,[r0]
	mov r3, r1, asr #8			;get pixel
	mov     r1, r3          ; r1 = obj1.x
    add     r2, r1, #14     ; r2 = obj1.x + 14
    cmp     r2, r8          ; if (obj1.x + 14 <= obj2.x)
    ble     NoCollision12    ;    no collision

    add     r2, r8, #12     ; r2 = obj2.x + 12
    cmp     r2, r3          ; if (obj2.x + 12 <= obj1.x)
    ble     NoCollision12     ;    no collision

    b       Death           ; Collision occurred

NoCollision12:
	ldr r0, SecondObjectPosition
	ldr r1,[r0]
	mov r3, r1, asr #8			;get pixel
	add r3,r3,#-120				;second car offset
	cmp r3,#-16					;-16
	bgt DontWrapValue1152
	add r3,r3,#166				;add
DontWrapValue1152:
	mov     r1, r3          ; r1 = obj1.x
    add     r2, r1, #14     ; r2 = obj1.x + 14
    cmp     r2, r8          ; if (obj1.x + 14 <= obj2.x)
    ble     NoCollision22     ;    no collision

    add     r2, r8, #12     ; r2 = obj2.x + 12
    cmp     r2, r3          ; if (obj2.x + 12 <= obj1.x)
    ble     NoCollision22     ;    no collision

    b       Death           ; Collision occurred

SkipCollisionLane12:
NoCollision22:
	;LANE 3 FIRST RENDER (Moving right like Lane 1)
    mov r4, #104			;CAR 3 vertical pos

    ldr r0, ThirdObjectPosition
    ldr r1,[r0]
    mov r3, r1, asr #8
    mov r5, #4              ; Use car sprite 4


    bl ShowSpriteXor			;derender sprite1

    ldr r0, ThirdObjectPosition
    ldr r1,[r0]
    mov r3, r1, asr #8			;get pixel
    add r3,r3,#70				;second car offset
    cmp r3,#150
    blt DontWrapValue3
    sub r3,r3,#166
    DontWrapValue3:
    mov r5, #4
    bl ShowSpriteXor			;derender sprite2

    ldr r0, ThirdObjectPosition
    ldr r1,[r0]
    add r1,r1, #75				;add subpixel (slightly faster than lane 1)
    mov r3, r1, asr #8			;get pixel

    cmp r3,#150					;wrap around
    blt KeepValue3
    sub r3,r3,#166
    mov r1, r3, lsl#8
    KeepValue3:
    str r1,[r0]
    mov r5, #4

    bl ShowSpriteXor			;render sprite1
    ldr r0, ThirdObjectPosition
    ldr r1,[r0]
    mov r3, r1, asr #8			;get pixel
    add r3,r3,#70
    cmp r3,#150
    blt DontWrapValue31
    sub r3,r3,#166
    DontWrapValue31:
    mov r5, #4
    bl ShowSpriteXor			;render sprite 2

    cmp r9,#104			;frog vertical position equal to only possible position in this lane
    bne SkipCollisionLane3
    ldr r0, ThirdObjectPosition
    ldr r1,[r0]
    mov r3, r1, asr #8			;get pixel
    mov     r1, r3          ; r1 = obj1.x
    add     r2, r1, #14     ; r2 = obj1.x + 14
    cmp     r2, r8          ; if (obj1.x + 14 <= obj2.x)
    ble     NoCollision3     ;    no collision

    add     r2, r8, #12     ; r2 = obj2.x + 12
    cmp     r2, r3          ; if (obj2.x + 12 <= obj1.x)
    ble     NoCollision3     ;    no collision

    b       Death           ; Collision occurred

    NoCollision3:
    ldr r0, ThirdObjectPosition
    ldr r1,[r0]
    mov r3, r1, asr #8			;get pixel
    add r3,r3,#70
    cmp r3,#150
    blt DontWrapValue315
    sub r3,r3,#166
    DontWrapValue315:
    mov     r1, r3          ; r1 = obj1.x
    add     r2, r1, #14     ; r2 = obj1.x + 14
    cmp     r2, r8          ; if (obj1.x + 14 <= obj2.x)
    ble     NoCollision32    ;    no collision

    add     r2, r8, #12     ; r2 = obj2.x + 12
    cmp     r2, r3          ; if (obj2.x + 12 <= obj1.x)
    ble     NoCollision32    ;    no collision

    b       Death           ; Collision occurred

    SkipCollisionLane3:
NoCollision32:

    ;cmp r8, #
    ;Lane1Collision
    cmp r9, #6
    bne SkipVictoryCheck

SkipVictoryCheck:
	; Check if frog has reached the top row where victory zones are
	cmp r9, #6
	bne SkipVictoryLogic  ; Not at top, continue normal game

	; We're at the top row (y=6), check if in a valid victory zone
	; Victory zones: 12px wide, starting at x=0 (shifted 5px left), with 20px gaps
	; Zone 1: 0-11  (was 5-16)
	; Zone 2: 32-43 (was 37-48)
	; Zone 3: 64-75 (was 69-80)
	; Zone 4: 96-107 (was 101-112)
	; Zone 5: 128-139 (was 133-144)

	; Check if in zone 1
	cmp r8, #0
	blt TopRowButNotInZone  ; Less than start of zone 1
	cmp r8, #11
	ble HandleVictory       ; In zone 1

	; Check if in zone 2
	cmp r8, #32
	blt TopRowButNotInZone  ; Between zones
	cmp r8, #43
	ble HandleVictory       ; In zone 2

	; Check if in zone 3
	cmp r8, #64
	blt TopRowButNotInZone  ; Between zones
	cmp r8, #75
	ble HandleVictory       ; In zone 3

	; Check if in zone 4
	cmp r8, #96
	blt TopRowButNotInZone  ; Between zones
	cmp r8, #107
	ble HandleVictory       ; In zone 4

	; Check if in zone 5
	cmp r8, #128
	blt TopRowButNotInZone  ; Between zones
	cmp r8, #139
	ble HandleVictory       ; In zone 5

	; If we're here, we're at top row but not in a victory zone


SkipVictoryLogic:
	; Continue with normal game logic
	b InfLoop

; Handle the victory sequence
HandleVictory:
    STMFD sp!, {r0-r7, lr}

    ; First show the frog in the victory position
    bl ShowSprite

    ; Victory celebration delay - Fixed for large immediate value
    mov r0, #0xF000     ; Use a smaller value that fits in immediate
    mov r1, #3          ; Multiply by using a loop
VictoryDelayOuter:
    mov r2, r0
VictoryDelayInner:
    subs r2, r2, #1
    bne VictoryDelayInner
    subs r1, r1, #1
    bne VictoryDelayOuter

    ; Remove sprite from victory position
    bl RemoveSprite

    ; Teleport player back to starting position
    mov r8, #52
    mov r9, #146
    and r8, r8, #0xFF
    and r9, r9, #0xFF
    mov r6, #0    ; Face north

    ; Show sprite at starting position
    bl ShowSprite

    LDMFD sp!, {r0-r7, pc}

TopRowButNotInZone:
	; Player is at the top but not in a victory zone - death!
	b Death
OutOfBoundDeath:
	bl RemoveSprite
	mov r8, #50
	mov r9, #50
	b Death

Death:
	bl RemoveSprite
	mov r8, #170
	mov r9, #70
	b Death

MoveBack:
	mov r8,#20

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

;FROG RENDER START ----------------------------

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

;FROG RENDER END ----------------------------

;CAR RENDER 16x16 START ---------------------

;Xor Sprite, drawing twice will remove sprite from screen.
ShowSpriteXor:
    mov   r10, #0x06000000      ; VRAM base

    ; Calculate destination address in VRAM from x (r3) and y (r4)
    mov   r1, #2              ; 2 bytes per pixel
    mul   r2, r1, r3          ; r2 = x coordinate * 2
    add   r10, r10, r2        ; add X offset
    mov   r11, r3             ; save starting x coordinate in r11

    mov   r1, #480            ; 240 pixels per line * 2 bytes = 480 bytes/line
    mul   r2, r1, r4          ; r2 = y coordinate * 480
    add   r10, r10, r2        ; add Y offset

    ; Load car sprite address from CarThird_Literal
	cmp   r5, #1
    bne   NotSecond
    adr   r2, CarFirst_Literal
    b     AfterCarLoad
    NotSecond:
    cmp   r5, #3
    bne   NotThird
    adr   r2, CarThird_Literal
    b     AfterCarLoad
    NotThird:
    cmp   r5, #4
    bne   NotFirst
    adr   r2, CarFourth_Literal
    b     AfterCarLoad
    NotFirst:
    ; Fallback/default
    ldr   r2, CarFirst_Literal

    AfterCarLoad:
    ldr   r1, [r2]

    mov   r6, #16             ; Height = 16 lines

Sprite_NextLineXor:
    mov   r5, #16             ; Width = 16 pixels per row
    mov   r7, #0              ; Reset column counter for this row
    STMFD sp!, {r10}          ; Save current row's VRAM pointer

Sprite_NextByteXor:
    add   r2, r11, r7         ; Compute absolute x: starting x (r11) + current column (r7)
    cmp   r2, #0              ; Check if absolute x is negative
    blt   SkipPixelXor        ; If negative, skip drawing this pixel
    cmp   r2, #148            ; Check if absolute x is above 148
    bgt   SkipPixelXor        ; If so, skip drawing this pixel
    ldrH  r3, [r1], #2        ; load one halfword (pixel) from car sprite data; advance pointer
    ldrH  r2, [r10]           ; load current VRAM pixel value at destination
    eor   r3, r3, r2          ; XOR the sprite pixel with the background pixel
    strH  r3, [r10], #2       ; store result back to VRAM; advance destination pointer
    b     ContinuePixelXor

SkipPixelXor:
    ldrH  r3, [r1], #2        ; load (discard) the sprite pixel, advancing pointer
    add   r10, r10, #2        ; advance VRAM pointer without drawing

ContinuePixelXor:
    add   r7, r7, #1          ; increment column counter
    subs  r5, r5, #1          ; decrement pixel count for this row
    bne   Sprite_NextByteXor  ; process next pixel in row

    LDMFD sp!, {r10}          ; restore VRAM pointer to start of row
    add   r10, r10, #480      ; advance to next scanline
    subs  r6, r6, #1          ; decrement remaining line count
    bne   Sprite_NextLineXor  ; loop for remaining rows

    bx    lr

CarThird_Literal: .long CarThird_Data      ; cars
CarThird_Data:    .incbin "assets/cars/car_small3.img.bin"

CarFourth_Literal: .long CarFourth_Data
CarFourth_Data:    .incbin "assets/cars/car_small4.img.bin"

CarFirst_Literal: .long CarFirst_Data      ; cars
CarFirst_Data:    .incbin "assets/cars/car_small1.img.bin"

;CAR RENDER 16x16 END ---------------------

BackgroundData_Ptr: .long BackgroundData

CurrentFrame_Ptr:   .long 0x03000000
Delay_Ptr:			.long 0x03005C00
GameLogicFlag_Ptr:	.long 0x03004A00
Vcount_Ptr:			.long 0x04000006
PreviousInput_Ptr: 	.long 0x03007F00

FirstObjectPosition:  .long  0x03000F28
SecondObjectPosition:  .long 0x03000004
ThirdObjectPosition:  .long 0x03000008
FourthObjectPosition:  .long 0x0300000C
FifthObjectPosition:   .long 0x03000010
SixthObjectPosition:   .long 0x03000014
SeventhObjectPosition: .long 0x03000018
EighthObjectPosition:  .long 0x0300001C
NinthObjectPosition:   .long 0x03000020
TenthObjectPosition:   .long 0x03000024

FrogNorth_Data: .incbin "assets/frogs/frogNorth.img.bin"
FrogSouth_Data: .incbin "assets/frogs/frogSouth.img.bin"
FrogEast_Data:  .incbin "assets/frogs/frogEast.img.bin"
FrogWest_Data:  .incbin "assets/frogs/frogWest.img.bin"

FrogNorthJump_Data:  .incbin "assets/frogs/frogNorthJump.img.bin"  ; Jump frame for north
FrogSouthJump_Data:  .incbin "assets/frogs/frogSouthJump.img.bin"  ; Jump frame for south
FrogEastJump_Data:   .incbin "assets/frogs/frogEastJump.img.bin"   ; Jump frame for east
FrogWestJump_Data:   .incbin "assets/frogs/frogWestJump.img.bin"   ; Jump frame for west


FrogNorth_Literal: .long FrogNorth_Data
FrogSouth_Literal: .long FrogSouth_Data
FrogWest_Literal:  .long FrogWest_Data
FrogEast_Literal:  .long FrogEast_Data

FrogNorthJump_Literal: .long FrogNorthJump_Data
FrogSouthJump_Literal: .long FrogSouthJump_Data
FrogEastJump_Literal:  .long FrogEastJump_Data
FrogWestJump_Literal:  .long FrogWestJump_Data

BackgroundData: .incbin "assets/smallmap.img.bin"