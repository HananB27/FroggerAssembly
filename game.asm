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

DataSection_Address:
    .long DataSection

ProgramStart:
    ldr r12, DataSection_Address
    mov r0, #0
    ldr r1, [r12, #8]  ; GameLogicFlag_Ptr
    str r0, [r1]    ;store in memory that gamelogic didnt happen this frame

    mov sp,#0x03000000
    mov r4,#0x04000000
    mov r2,#0x403
    str r2,[r4]

    ; Initialize RAM variables
    ldr r4, [r12, #0]  ; CurrentFrame_Ptr
    mov r5, #0
    strb r5, [r4]      ; Initialize CurrentFrame to 0

    bl LoadBackground

    mov r8,#62
    mov r9,#146
    and r8, r8, #0xFF
    and r9, r9, #0xFF
    mov r6,#0 ; direction: 0=North, 1=South, 2=West, 3=East

    bl ShowSprite

    ;LANE 1 FIRST RENDER
    mov r4, #132            ;CAR 1 vertical pos

    mov r0, #-16
    mov r5, #3
    mov r3,#-16
    bl ShowSpriteXor
    mov r0, #-16
    ldr r1, [r12, #20]  ; FirstObjectPosition
    mov r3,r0, asl #8
    str r3,[r1]
    mov r3, #-16+70
    mov r5, #3
    bl ShowSpriteXor

    ;LANE 2 FIRST RENDER
    mov r4, #118            ;CAR 1 vertical pos

    mov r0, #-16
    mov r3,#-16
    mov r5, #1
    bl ShowSpriteXor
    mov r0, #-16
    ldr r1, [r12, #24]  ; SecondObjectPosition
    mov r3,r0, asl #8
    str r3,[r1]
    mov r3, #30
    mov r5, #1
    bl ShowSpriteXor

    ;LANE 3 FIRST RENDER
    mov r4, #104            ;CAR 3 vertical pos

    mov r0, #-16
    mov r5, #4              ; Use car sprite 4
    mov r3,#-16
    bl ShowSpriteXor
    mov r0, #-16
    ldr r1, [r12, #28]  ; ThirdObjectPosition
    mov r3,r0, asl #8
    str r3,[r1]
    mov r3, #-16+70
    mov r5, #4
    bl ShowSpriteXor

    mov r4, #62       ; Turtle vertical position (in water area)

    ; First turtle
    mov r3, #30         ; X position
    mov r5, #5          ; Use sprite type 5 for turtle
    bl ShowSpriteXor

    ; Second turtle
    mov r3, #46         ; X position
    mov r5, #5          ; Use sprite type 5 for turtle
    bl ShowSpriteXor

    ; Third turtle
    mov r3, #62       ; X position
    mov r5, #5          ; Use sprite type 5 for turtle
    bl ShowSpriteXor

MoveOrGame:
    ldr r12, DataSection_Address  ; Load DataSection address
    ldr r0, [r12, #12]  ; Vcount_Ptr
    ldr r1, [r0]
    cmp r1, #160
    blt SetFlagUp
    ldr r0, [r12, #8]   ; GameLogicFlag_Ptr
    ldr r1, [r0]
    cmp r1, #1
    beq GameLogic

    ;check if not in blank, if not, check flag to render once in vblank
    ;if blank, check flag should i render
    ;once rendered, set flag not to render

SetFlagUp:
    ldr r12, DataSection_Address  ; Load DataSection address
    ldr r0, [r12, #8]   ; GameLogicFlag_Ptr
    mov r1, #1
    str r1, [r0]

    b MoveOrGame2

MoveOrGame2:
    ldr r12, DataSection_Address  ; Load DataSection address
    ldr r1, [r12, #4]   ; Delay_Ptr
    ldr r0, [r1]
    cmp.b r0, #0        ; if 0, do move logic again, else decrement and go to MoveOrGame
    beq InfLoop
    sub r0, r0, #1      ; if not 0, decrement, store, go to MoveOrGame
    ldr r1, [r12, #4]   ; Delay_Ptr
    str r0, [r1]
    b MoveOrGame

InfLoop:
    mov r3, #0x4000130

WaitNoInput:
    ; Load previous input (pressed = 1 logic)
    ldr r12, DataSection_Address
    ldr r0, [r12, #16]  ; PreviousInput_Ptr
    ldrh r2, [r0]       ; r2 = previous pressed buttons

    ; Load current input
    ldrh r1, [r3]       ; raw input
    mvn r1, r1          ; invert → pressed = 1
    and r1, r1, #0xF0   ; keep only D-pad bits

    ; Store current for next time
    strh r1, [r0]       ; update PreviousInput

    ; If nothing is newly pressed, go back
    ; Check: r1 == 0 → no buttons pressed → go to MoveOrGame
    cmp r1, #0
    beq MoveOrGame

    ; Check if current input equals previous input → still holding → skip
    cmp r1, r2
    beq MoveOrGame

    ; Else → new directional press
    mov r0, r1          ; pass current input in r0 if needed
    b DirectionChecks

WaitForInput:
    ldrh r1, [r3]
    mov r0, r1
    and r0, r0, #0b0000000011110000
    cmp r0, #0b0000000011110000
    ;beq WaitForInput   ; Wait until a direction is pressed
    beq MoveOrGame      ; same ol same ol

DirectionChecks:
    bl RemoveSprite

    ldrh r1, [r3]
    mov r0, r1
    and r0, r0, #0b0000000011110000

    ; Check directions once per press
    tst r0, #0b0000000001000000 ; Up
    bne CheckDown
    cmp.b r9, #15
    blt CheckDown
    sub.b r9, r9, #14
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
    ldr r12, DataSection_Address
    ldr r4, [r12, #0]   ; CurrentFrame_Ptr
    mov r7, #1
    strb r7, [r4]
    bl ShowSprite       ; This will use current r6 value for direction

    ; Increase the delay for jump frame
    mov r0,#0x8FFF     ; Increased from 0x5FFF to 0x8FFF
Delay1:
    subs r0,r0,#1
    bne Delay1

JumpAnimation:
    ; Remove jump frame sprite
    bl RemoveSprite

    ; Reset to normal frame
    ldr r12, DataSection_Address
    ldr r4, [r12, #0]   ; CurrentFrame_Ptr
    mov r7, #0
    strb r7, [r4]
    bl ShowSprite       ; This will use current r6 value for direction

    ; Increase delay before next input
    mov r0,#0x2FFF     ; Increased from 0x1AFF to 0x2FFF
    ldr r12, DataSection_Address
    ldr r1, [r12, #4]   ; Delay_Ptr
    str r0, [r1]
    b MoveOrGame

GameLogic:
    mov r1, #0
    ldr r12, DataSection_Address
    ldr r0, [r12, #8]   ; GameLogicFlag_Ptr
    str r1, [r0]        ; Set GameLogicFlag_Ptr as down, do not tick again until out of vblank

    ;LANE 1 FIRST RENDER
    mov r4, #132        ; car 1 vertical pos

    ldr r0, [r12, #20]  ; FirstObjectPosition
    ldr r1, [r0]
    mov r3, r1, asr #8
    mov r5, #3

    bl ShowSpriteXor    ; derender sprite1

    ldr r0, [r12, #20]  ; FirstObjectPosition
    ldr r1, [r0]
    mov r3, r1, asr #8  ; get pixel
    add r3, r3, #70     ; second car offset
    cmp r3, #150
    blt DontWrapValue
    sub r3, r3, #166
DontWrapValue:
    mov r5, #3
    bl ShowSpriteXor    ; derender sprite2

    ldr r0, [r12, #20]  ; FirstObjectPosition
    ldr r1, [r0]
    add r1, r1, #60     ; add subpixel
    mov r3, r1, asr #8  ; get pixel

    cmp r3, #150        ; wrap around
    blt KeepValue
    sub r3, r3, #166
    mov r1, r3, lsl #8
KeepValue:
    str r1, [r0]
    mov r5, #3

    ; r3 contains pixel value of car, r9 contains vertical of frog
    add r1, r9, #16

    bl ShowSpriteXor    ; render sprite1
    ldr r0, [r12, #20]  ; FirstObjectPosition
    ldr r1, [r0]
    mov r3, r1, asr #8  ; get pixel
    add r3, r3, #70
    cmp r3, #150
    blt DontWrapValue11
    sub r3, r3, #166
DontWrapValue11:
    mov r5, #3
    bl ShowSpriteXor    ; render sprite 2

    cmp r9, #132        ; frog vertical position equal to only possible position in this lane
    bne SkipCollisionLane1
    ldr r0, [r12, #20]  ; FirstObjectPosition
    ldr r1, [r0]
    mov r3, r1, asr #8  ; get pixel
    mov r1, r3          ; r1 = obj1.x
    add r2, r1, #14     ; r2 = obj1.x + 14
    cmp r2, r8          ; if (obj1.x + 14 <= obj2.x)
    ble NoCollision1    ; no collision

    add r2, r8, #12     ; r2 = obj2.x + 12
    cmp r2, r3          ; if (obj2.x + 12 <= obj1.x)
    ble NoCollision1    ; no collision

    b Death             ; Collision occurred

NoCollision1:
    ldr r0, [r12, #20]  ; FirstObjectPosition
    ldr r1, [r0]
    mov r3, r1, asr #8  ; get pixel
    add r3, r3, #70
    cmp r3, #150
    blt DontWrapValue115
    sub r3, r3, #166
DontWrapValue115:
    mov r1, r3          ; r1 = obj1.x
    add r2, r1, #14     ; r2 = obj1.x + 14
    cmp r2, r8          ; if (obj1.x + 14 <= obj2.x)
    ble NoCollision2    ; no collision

    add r2, r8, #12     ; r2 = obj2.x + 12
    cmp r2, r3          ; if (obj2.x + 12 <= obj1.x)
    ble NoCollision2    ; no collision

    b Death             ; Collision occurred

NoCollision2:

;LANE 1 END
;--------------------------------------------------------
;LANE 2 FIRST RENDER
;car GOING LEFT

SkipCollisionLane1:
    mov r4, #118        ; car 1 vertical pos

    ldr r12, DataSection_Address
    ldr r0, [r12, #24]  ; SecondObjectPosition
    ldr r1, [r0]
    mov r3, r1, asr #8
    mov r5, #1
    bl ShowSpriteXor    ; derender sprite1

    ldr r0, [r12, #24]  ; SecondObjectPosition
    ldr r1, [r0]
    mov r3, r1, asr #8  ; get pixel
    add r3, r3, #-120   ; second car offset
    cmp r3, #-16        ; less than -16 for left
    bgt DontWrapValue2
    add r3, r3, #166    ; add
DontWrapValue2:
    mov r5, #1
    bl ShowSpriteXor    ; derender sprite2

    ldr r0, [r12, #24]  ; SecondObjectPosition
    ldr r1, [r0]
    add r1, r1, #-200   ; add subpixel, now -
    mov r3, r1, asr #8  ; get pixel

    cmp r3, #-16        ; wrap around, from left
    bgt KeepValue2
    add r3, r3, #166    ; add for left
    mov r1, r3, lsl #8
KeepValue2:
    str r1, [r0]
    mov r5, #1
    bl ShowSpriteXor    ; render sprite1

    ldr r0, [r12, #24]  ; SecondObjectPosition
    ldr r1, [r0]
    mov r3, r1, asr #8  ; get pixel
    add r3, r3, #-120   ; second car offset
    cmp r3, #-16        ; -16
    bgt DontWrapValue22
    add r3, r3, #166    ; add
DontWrapValue22:
    mov r5, #1
    bl ShowSpriteXor    ; render sprite 2

    ; COLLISION FOR LANE 2
    cmp r9, #118        ; frog vertical position equal to only possible position in this lane
    bne SkipCollisionLane12
    ldr r0, [r12, #24]  ; SecondObjectPosition
    ldr r1, [r0]
    mov r3, r1, asr #8  ; get pixel
    mov r1, r3          ; r1 = obj1.x
    add r2, r1, #14     ; r2 = obj1.x + 14
    cmp r2, r8          ; if (obj1.x + 14 <= obj2.x)
    ble NoCollision12   ; no collision

    add r2, r8, #12     ; r2 = obj2.x + 12
    cmp r2, r3          ; if (obj2.x + 12 <= obj1.x)
    ble NoCollision12   ; no collision

    b Death             ; Collision occurred
NoCollision12:
    ldr r12, DataSection_Address
    ldr r0, [r12, #24]  ; SecondObjectPosition
    ldr r1, [r0]
    mov r3, r1, asr #8  ; get pixel
    add r3, r3, #-120   ; second car offset
    cmp r3, #-16        ; -16
    bgt DontWrapValue1152
    add r3, r3, #166    ; add
DontWrapValue1152:
    mov r1, r3          ; r1 = obj1.x
    add r2, r1, #14     ; r2 = obj1.x + 14
    cmp r2, r8          ; if (obj1.x + 14 <= obj2.x)
    ble NoCollision22   ; no collision

    add r2, r8, #12     ; r2 = obj2.x + 12
    cmp r2, r3          ; if (obj2.x + 12 <= obj1.x)
    ble NoCollision22   ; no collision

    b Death             ; Collision occurred

SkipCollisionLane12:
NoCollision22:
    ;LANE 3 FIRST RENDER (Moving right like Lane 1)
    mov r4, #104        ; CAR 3 vertical pos

    ldr r12, DataSection_Address
    ldr r0, [r12, #28]  ; ThirdObjectPosition
    ldr r1, [r0]
    mov r3, r1, asr #8
    mov r5, #4          ; Use car sprite 4

    bl ShowSpriteXor    ; derender sprite1

    ldr r0, [r12, #28]  ; ThirdObjectPosition
    ldr r1, [r0]
    mov r3, r1, asr #8  ; get pixel
    add r3, r3, #70     ; second car offset
    cmp r3, #150
    blt DontWrapValue3
    sub r3, r3, #166
DontWrapValue3:
    mov r5, #4
    bl ShowSpriteXor    ; derender sprite2

    ldr r0, [r12, #28]  ; ThirdObjectPosition
    ldr r1, [r0]
    add r1, r1, #75     ; add subpixel (slightly faster than lane 1)
    mov r3, r1, asr #8  ; get pixel

    cmp r3, #150        ; wrap around
    blt KeepValue3
    sub r3, r3, #166
    mov r1, r3, lsl #8
KeepValue3:
    str r1, [r0]
    mov r5, #4

    bl ShowSpriteXor    ; render sprite1
    ldr r0, [r12, #28]  ; ThirdObjectPosition
    ldr r1, [r0]
    mov r3, r1, asr #8  ; get pixel
    add r3, r3, #70
    cmp r3, #150
    blt DontWrapValue31
    sub r3, r3, #166
DontWrapValue31:
    mov r5, #4
    bl ShowSpriteXor    ; render sprite 2

    cmp r9, #104        ; frog vertical position equal to only possible position in this lane
    bne SkipCollisionLane3
    ldr r0, [r12, #28]  ; ThirdObjectPosition
    ldr r1, [r0]
    mov r3, r1, asr #8  ; get pixel
    mov r1, r3          ; r1 = obj1.x
    add r2, r1, #14     ; r2 = obj1.x + 14
    cmp r2, r8          ; if (obj1.x + 14 <= obj2.x)
    ble NoCollision3    ; no collision

    add r2, r8, #12     ; r2 = obj2.x + 12
    cmp r2, r3          ; if (obj2.x + 12 <= obj1.x)
    ble NoCollision3    ; no collision

    b Death             ; Collision occurred

NoCollision3:
    ldr r0, [r12, #28]  ; ThirdObjectPosition
    ldr r1, [r0]
    mov r3, r1, asr #8  ; get pixel
    add r3, r3, #70
    cmp r3, #150
    blt DontWrapValue315
    sub r3, r3, #166
DontWrapValue315:
    mov r1, r3          ; r1 = obj1.x
    add r2, r1, #14     ; r2 = obj1.x + 14
    cmp r2, r8          ; if (obj1.x + 14 <= obj2.x)
    ble NoCollision32   ; no collision

    add r2, r8, #12     ; r2 = obj2.x + 12
    cmp r2, r3          ; if (obj2.x + 12 <= obj1.x)
    ble NoCollision32   ; no collision

    b Death             ; Collision occurred

SkipCollisionLane3:
NoCollision32:
    mov r4, #62       ; Turtle vertical position

    ; Clear first turtle
    ldr r12, DataSection_Address
    mov r3, #30         ; X position
    mov r5, #5          ; Use sprite type 5 for turtle
    bl ShowSpriteXor    ; XOR to clear

    ; Clear second turtle
    mov r3, #46        ; X position
    mov r5, #5          ; Use sprite type 5 for turtle
    bl ShowSpriteXor    ; XOR to clear

    ; Clear third turtle
    mov r3, #62        ; X position
    mov r5, #5          ; Use sprite type 5 for turtle
    bl ShowSpriteXor    ; XOR to clear

    ; Now redraw turtles (possibly with updated positions)
    mov r4, #62       ; Turtle vertical position

    ; Redraw first turtle
    ldr r12, DataSection_Address
    ldr r0, [r12, #68]  ; Turtle1_Ptr
    ldr r1, [r0]
    mov r3, #30         ; X position
    mov r5, #5          ; Use sprite type 5 for turtle
    bl ShowSpriteXor

    ; Redraw second turtle
    mov r3, #46        ; X position
    mov r5, #5          ; Use sprite type 5 for turtle
    bl ShowSpriteXor

SkipWaterCheck:
    cmp r9, #64
    bgt SkipVictoryCheck    ; If y > 64, skip water check
    cmp r9, #16
    blt SkipVictoryCheck    ; If y < 16, skip water check

    ; We're in water zone - check if on a turtle before triggering death
    cmp r9, #62             ; Check if at turtle row (y=62)
    bne WaterDeath          ; If not on turtle row, it's water death

    ; Check if frog is on any of the three turtles
    ; First turtle: x=30 to x=45
    cmp r8, #30
    blt CheckSecondTurtle   ; Less than turtle 1 start
    cmp r8, #45
    ble OnTurtle            ; On turtle 1

CheckSecondTurtle:
    ; Second turtle: x=46 to x=61
    cmp r8, #46
    blt CheckThirdTurtle    ; Less than turtle 2 start
    cmp r8, #61
    ble OnTurtle            ; On turtle 2

CheckThirdTurtle:
    ; Third turtle: x=62 to x=77
    cmp r8, #62
    blt WaterDeath          ; Less than turtle 3 start
    cmp r8, #77
    ble OnTurtle            ; On turtle 3
    b WaterDeath            ; Not on any turtle

OnTurtle:
    ; Frog is safely on a turtle, continue game
    b SkipVictoryCheck
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

    ; Remove player frog sprite
    bl RemoveSprite

    ; Calculate victory zone center position
    mov r9, #6         ; Victory row Y position

    ; Show victory frog sprite
    mov r10, #0x06000000
    mov r1, #2
    mul r2, r1, r8     ; X position
    add r10, r10, r2
    mov r1, #480       ; 240*2
    mul r2, r1, r9     ; Y position
    add r10, r10, r2

    ; Load victory frog sprite data using DataSection
    ldr r12, DataSection_Address
    ldr r1, [r12, #64]  ; VictoryFrog_Ptr (16 * 4 = 64, as it's the 17th entry)

    mov r4, #16        ; Height
VictoryFrog_NextLine:
    mov r5, #16        ; Width
    STMFD sp!, {r10}
VictoryFrog_NextPixel:
    ldrH r3, [r1], #2
    cmp r3, #0
    beq VictoryFrog_Skip
    strH r3, [r10]
VictoryFrog_Skip:
    add r10, r10, #2
    subs r5, r5, #1
    bne VictoryFrog_NextPixel
    LDMFD sp!, {r10}
    add r10, r10, #480
    subs r4, r4, #1
    bne VictoryFrog_NextLine

    ; Victory celebration delay
    mov r0, #0xF000
    mov r1, #3
VictoryDelayOuter:
    mov r2, r0
VictoryDelayInner:
    subs r2, r2, #1
    bne VictoryDelayInner
    subs r1, r1, #1
    bne VictoryDelayOuter

    ; Return player to starting position
    mov r8, #52         ; Starting X position
    mov r9, #146        ; Starting Y position
    and r8, r8, #0xFF
    and r9, r9, #0xFF
    mov r6, #0          ; Face north

    ; Show sprite at starting position
    bl ShowSprite

    LDMFD sp!, {r0-r7, pc}
TopRowButNotInZone:
    b Death
OutOfBoundDeath:
    bl RemoveSprite
    mov r8, #50
    mov r9, #50
    b Death

Death:
    STMFD sp!, {r0-r7, lr}    ; Save registers

    ; First remove the frog sprite
    bl RemoveSprite

    ; Store original death coordinates
    mov r11, r8        ; Save X coordinate
    mov r12, r9        ; Save Y coordinate

    ; Death Animation Frame 1
    ldr r4, Death1_Literal_Addr
    ldr r1, [r4]
    bl ShowDeathFrame
    bl DeathDelay
    bl RemoveDeathFrame    ; Clear frame 1

    ; Death Animation Frame 2
    ldr r4, Death2_Literal_Addr
    ldr r1, [r4]
    bl ShowDeathFrame
    bl DeathDelay
    bl RemoveDeathFrame    ; Clear frame 2

    ; Death Animation Frame 3
    ldr r4, Death3_Literal_Addr
    ldr r1, [r4]
    bl ShowDeathFrame
    bl DeathDelay
    bl RemoveDeathFrame    ; Clear frame 3

    mov r0, #0x7FFF        ; Shorter pause before skeleton
    mov r1, #1
DeathDelay_Short:
    subs r0, r0, #1
    bne DeathDelay_Short

    ; Death Animation Frame 4 (Death7 - skeleton)
    ldr r4, Death7_Literal_Addr
    ldr r1, [r4]
    bl ShowDeathFrame
    bl DeathDelay
    bl RemoveDeathFrame    ; Clear final frame

    LDMFD sp!, {r0-r7, lr}    ; Restore registers

    ; Instead of resetting position, restart the entire game
    b ProgramStart        ; Branch back to game start
WaterDeath:
    STMFD sp!, {r0-r7, lr}    ; Save registers

    ; First remove the frog sprite
    bl RemoveSprite

    ; Store original death coordinates
    mov r11, r8        ; Save X coordinate
    mov r12, r9        ; Save Y coordinate

    ; Water Death Animation Frame 1
    ldr r4, Death4_Literal_Addr
    ldr r1, [r4]
    bl ShowDeathFrame
    bl DeathDelay
    bl RemoveDeathFrame    ; Clear frame 1

    ; Water Death Animation Frame 2
    ldr r4, Death5_Literal_Addr
    ldr r1, [r4]
    bl ShowDeathFrame
    bl DeathDelay
    bl RemoveDeathFrame    ; Clear frame 2

    ; Water Death Animation Frame 3
    ldr r4, Death6_Literal_Addr
    ldr r1, [r4]
    bl ShowDeathFrame
    bl DeathDelay
    bl RemoveDeathFrame    ; Clear frame 3

    mov r0, #0x7FFF        ; Shorter pause before skeleton
    mov r1, #1
WaterDeathDelay_Short:
    subs r0, r0, #1
    bne WaterDeathDelay_Short

    ; Death Animation Frame 4 (Death7 - skeleton)
    ldr r4, Death7_Literal_Addr
    ldr r1, [r4]
    bl ShowDeathFrame
    bl DeathDelay
    bl RemoveDeathFrame    ; Clear final frame

    LDMFD sp!, {r0-r7, lr}    ; Restore registers

    ; Restart the game
    b ProgramStart
Death1_Literal_Addr: .long Death1_Literal
Death2_Literal_Addr: .long Death2_Literal
Death3_Literal_Addr: .long Death3_Literal
Death4_Literal_Addr: .long Death4_Literal
Death5_Literal_Addr: .long Death5_Literal
Death6_Literal_Addr: .long Death6_Literal
Death7_Literal_Addr: .long Death7_Literal

SkipLiterals:

; Helper routine to show death frame
ShowDeathFrame:
    STMFD sp!, {r0-r7, lr}
    mov r10, #0x06000000      ; VRAM base

    ; Calculate position based on saved death coordinates
    mov r2, r11               ; Get saved X coordinate
    mov r4, r12               ; Get saved Y coordinate

    ; Calculate VRAM address
    mov r3, #2
    mul r5, r2, r3            ; X offset
    add r10, r10, r5

    mov r3, #480             ; 240*2 bytes per line
    mul r5, r4, r3           ; Y offset
    add r10, r10, r5

    mov r6, #16              ; Height
ShowDeathFrame_NextLine:
    mov r5, #16              ; Width
    STMFD sp!, {r10}
ShowDeathFrame_NextPixel:
    ldrH r3, [r1], #2        ; Load death sprite pixel
    cmp r3, #0               ; Check if transparent
    beq ShowDeathFrame_Skip
    strH r3, [r10]           ; Draw pixel
ShowDeathFrame_Skip:
    add r10, r10, #2
    subs r5, r5, #1
    bne ShowDeathFrame_NextPixel
    LDMFD sp!, {r10}
    add r10, r10, #480       ; Next line
    subs r6, r6, #1
    bne ShowDeathFrame_NextLine

    LDMFD sp!, {r0-r7, pc}

; Helper routine to remove death frame
RemoveDeathFrame:
    STMFD sp!, {r0-r7, lr}
    mov r10, #0x06000000
    mov r1, #2
    mul r2, r1, r11         ; Use saved death X coordinate
    add r10, r10, r2
    mov r1, #240*2
    mul r2, r1, r12         ; Use saved death Y coordinate
    add r10, r10, r2

    ; Get background data pointer properly
    ldr r7, DataSection_Address  ; Use r7 instead of r12
    ldr r0, [r7, #60]  ; BackgroundData_Ptr
    mov r1, r12             ; Y coordinate
    mov r2, #240
    mul r3, r1, r2
    add r3, r3, r11         ; Add X coordinate
    mov r2, #2
    mul r3, r2, r3
    add r0, r0, r3

    mov r4, #16             ; Height
RemoveDeathFrame_NextLine:
    mov r5, #16             ; Width
    STMFD sp!, {r10, r0}
RemoveDeathFrame_NextByte:
    ldrH r3, [r0], #2      ; Load background pixel
    strH r3, [r10], #2     ; Restore background pixel
    subs r5, r5, #1
    bne RemoveDeathFrame_NextByte
    LDMFD sp!, {r10, r0}
    add r10, r10, #240*2   ; Next VRAM line
    add r0, r0, #240*2     ; Next background line
    subs r4, r4, #1
    bne RemoveDeathFrame_NextLine

    LDMFD sp!, {r0-r7, pc}

    LDMFD sp!, {r0-r7, pc}

; Delay between death animation frames
; Delay between death animation frames
DeathDelay:
    STMFD sp!, {r0-r1, lr}
    mov r0, #0xFFFF     ; Keep maximum value for smooth animation
    mov r1, #4          ; Reduced from 8 to 4 (half as slow as before)
DeathDelay_Outer:
    mov r2, r0
DeathDelay_Inner:
    subs r2, r2, #1
    bne DeathDelay_Inner
    subs r1, r1, #1
    bne DeathDelay_Outer
    LDMFD sp!, {r0-r1, pc}
MoveBack:
    mov r8, #20

LoadBackground:
    STMFD sp!, {r0-r7, lr}
    mov r0, #0x06000000
    ldr r12, DataSection_Address
    ldr r1, [r12, #60]  ; BackgroundData_Ptr
    mov r2, #240*160
BackgroundCopy:
    ldrh r3, [r1], #2
    strh r3, [r0], #2
    subs r2, r2, #1
    bne BackgroundCopy
    LDMFD sp!, {r0-r7, pc}

;FROG RENDER START ----------------------------

ShowSprite:
    mov r10, #0x06000000
    mov r1, #2
    mul r2, r1, r8
    add r10, r10, r2
    mov r1, #240*2
    mul r2, r1, r9
    add r10, r10, r2

    ; Load current animation frame
    ldr r12, DataSection_Address
    ldr r4, [r12, #0]   ; CurrentFrame_Ptr
    ldrb r5, [r4]       ; r5 now contains current frame (0 or 1)

    cmp r6, #0          ; Check if facing North
    bne CheckSouth
    cmp r5, #0          ; Check which frame
    bne NorthJump
    ldr r4, Sprite_Literals_Addr
    ldr r7, [r4, #0]    ; Load normal sprite
    ldr r1, [r7]
    b AfterLoadFrog

NorthJump:
    ldr r4, Sprite_Literals_Addr
    ldr r7, [r4, #4]
    ldr r1, [r7]        ; Two-step load for Frame 1
    b AfterLoadFrog

CheckSouth:
    cmp r6, #1          ; Check if facing South
    bne CheckWest
    cmp r5, #0          ; Check which frame
    bne SouthJump
    ldr r4, Sprite_Literals_Addr
    ldr r7, [r4, #8]
    ldr r1, [r7]
    b AfterLoadFrog

SouthJump:
    ldr r4, Sprite_Literals_Addr
    ldr r7, [r4, #12]
    ldr r1, [r7]        ; Two-step load for Frame 1
    b AfterLoadFrog

CheckWest:
    cmp r6, #2          ; Check if facing West
    bne CheckEast
    cmp r5, #0          ; Check which frame
    bne WestJump
    ldr r4, Sprite_Literals_Addr
    ldr r7, [r4, #16]
    ldr r1, [r7]
    b AfterLoadFrog

WestJump:
    ldr r4, Sprite_Literals_Addr
    ldr r7, [r4, #20]
    ldr r1, [r7]
    b AfterLoadFrog

CheckEast:
    cmp r5, #0
    bne EastJump
    ldr r4, Sprite_Literals_Addr
    ldr r7, [r4, #24]
    ldr r1, [r7]
    b AfterLoadFrog

EastJump:
    ldr r4, Sprite_Literals_Addr
    ldr r7, [r4, #28]
    ldr r1, [r7]

AfterLoadFrog:

    b SkipSpriteLiterals

Sprite_Literals_Addr: .long sprite_literals

SkipSpriteLiterals:
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
    ldr r0, [r12,#60]
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

    ; Save DataSection_Address before using r12 for other purposes
    mov   r7, r12             ; Save DataSection_Address in r7

    ; Load sprite address based on type in r5
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
    bne   NotFourth
    adr   r2, CarFourth_Literal
    b     AfterCarLoad

    NotFourth:
    cmp   r5, #5
    bne   NotTurtle
    ldr   r2, [r12,#68]  ; Use the literal directly instead of accessing through r12
    b     AfterCarLoad

    NotTurtle:
    ; Fallback/default for any other sprite type
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
;DEATH SPRIES ------------------
Death1_Data: .incbin "assets/death/death1.img.bin"
Death2_Data: .incbin "assets/death/death2.img.bin"
Death3_Data: .incbin "assets/death/death3.img.bin"
Death4_Data: .incbin "assets/death/death4.img.bin"
Death5_Data: .incbin "assets/death/death5.img.bin"
Death6_Data: .incbin "assets/death/death6.img.bin"
Death7_Data: .incbin "assets/death/death7.img.bin"

Turtle1_Data: .incbin "assets/river/turtles/turtle1.img.bin"
Turtle1_Literal: .long Turtle1_Data


; Add pointers to the death animation frames
Death1_Literal: .long Death1_Data
Death2_Literal: .long Death2_Data
Death3_Literal: .long Death3_Data
Death4_Literal: .long Death4_Data
Death5_Literal: .long Death5_Data
Death6_Literal: .long Death6_Data
Death7_Literal: .long Death7_Data
;END OF DEATH SPRITES ---------------

VictoryFrog_Data: .incbin "assets/map/finishFrog1.img.bin"
VictoryFrog_Literal: .long VictoryFrog_Data

.align 4
DataSection:
    CurrentFrame_Ptr:   .long 0x03000000 ;0
    Delay_Ptr:         .long 0x03005C00 ;4
    GameLogicFlag_Ptr: .long 0x03004A00 ;8
    Vcount_Ptr:        .long 0x04000006 ;12
    PreviousInput_Ptr: .long 0x03007F00 ;16
    FirstObjectPosition:  .long 0x03000F28  ;20
    SecondObjectPosition: .long 0x03000004  ;24
    ThirdObjectPosition:  .long 0x03000008  ;28
    FourthObjectPosition: .long 0x0300000C  ;32
    FifthObjectPosition:  .long 0x03000010  ;36
    SixthObjectPosition:  .long 0x03000014  ;40
    SeventhObjectPosition:.long 0x03000018  ;44
    EighthObjectPosition: .long 0x0300001C  ;48
    NinthObjectPosition:  .long 0x03000020  ;52
    TenthObjectPosition:  .long 0x03000024  ;56
    BackgroundData_Ptr:   .long BackgroundData  ;60
    VictoryFrog_Ptr:      .long VictoryFrog_Data    ;64
    Turtle1_Ptr: .long Turtle1_Literal ;68


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