ARCH     := arm-none-eabi
AS       := $(ARCH)-as
LD       := $(ARCH)-ld
OBJCOPY  := $(ARCH)-objcopy

TARGET   := game
SRC      := boot.s
OUT      := $(TARGET).gba
GBAFIX   := C:/devkitPro/tools/bin/gbafix.exe

all:
	$(AS) -o boot.o $(SRC)
	$(LD) -T linker.ld -o $(TARGET).elf boot.o
	$(OBJCOPY) -O binary $(TARGET).elf $(OUT)
	$(GBAFIX) $(OUT) -t"TEST"

clean:
	rm -f boot.o $(TARGET).elf $(OUT)
