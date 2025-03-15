OBJFILES = main.o

all: main.gba

%.o: %.s
	arm-none-eabi-as -mcpu=arm7tdmi -g -o $@ $<

main.elf: $(OBJFILES)
	arm-none-eabi-ld -T linker.ld -o $@ $^

main.gba: main.elf
	arm-none-eabi-objcopy -O binary $< $@

clean:
	rm -f *.o *.elf *.gba assets/*.bin
