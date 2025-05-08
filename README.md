#  Frogger for Game Boy Advance (GBA)

This is a fully functional and frame-accurate port of the classic **Frogger** arcade game, written entirely in **ARM7TDMI assembly** for the **Game Boy Advance**. It features sprite rendering, background logic, object collisions, animations, and VBlank-safe logic.

##  Features

- Fully playable Frogger clone with original mechanics.
- Written in 100% ARM7TDMI assembly.
- VBlank-based frame updates to ensure flicker-free rendering.
- 4 car lanes and 3 log lanes with full wraparound and collision logic.
- Turtle platforms and victory zones implemented.
- Frog animation with jump frames and directional rendering.
- Custom death animations and sprite XOR logic for flickerless clearing.
- Optimized background saving and restoring (frog movement doesn't affect background).
- Asset streaming from `.img.bin` GBA-ready formats.

##  Architecture

- Game logic runs only **once per VBlank** to maintain consistent timing.
- All rendering is done directly to VRAM (`0x06000000`) using 16-bit mode.
- Assets are `.incbin`-ed from binary image files for cars, logs, frogs, turtles, deaths, and background.
- All object positions use **subpixel** logic for smooth movement.
- Inputs are edge detected — actions only trigger on **new key presses**.
- Collision detection is done per lane using bounding-box logic.

##  Requirements

- [devkitARM](https://devkitpro.org/)
- Assembler supporting ARM7TDMI (e.g. `arm-none-eabi-as`, vasm)
- GBA emulator (e.g. mGBA, NO$GBA) or real hardware + flash cart

##  How to Build

1. Install `devkitARM` and ensure `arm-none-eabi-as` and `arm-none-eabi-ld` are in your PATH.
2. Assemble and link the project:
   ```bash
   arm-none-eabi-as -mthumb-interwork -o game.o game.asm
   arm-none-eabi-ld -Ttext=0x08000000 -o game.elf game.o
   arm-none-eabi-objcopy -O binary game.elf rom.gba
   ```
3. Run `rom.gba` in an emulator or on real hardware.

## 📝 Notes

- The code contains detailed comments and labeled sections for every game element: frog, cars, turtles, logs, death, background.
- Supports multiple animation frames for player movement.
- Uses custom routines to XOR sprites and restore background efficiently.
- Additional features like **multiple lives**, **time bar**, and **score tracking** could be added as future improvements.
