# Makefile for building GBA Assembly program

# Assembler command
ASM = vasmarm_std

# Input assembly file
SOURCE = game.asm

# Output directory
BUILD_DIR = BldGBA

# Output files
OUTPUT = $(BUILD_DIR)/game.gba
LISTING = $(BUILD_DIR)/Listing.txt

# Build command and flags
ASMFLAGS = -chklabels -nocase -L$(LISTING) -Fbin

# Default target
all: $(OUTPUT)

# Build output directory if it doesn't exist
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Compile the source assembly file
$(OUTPUT): $(SOURCE) | $(BUILD_DIR)
	$(ASM) $(SOURCE) $(ASMFLAGS) -o $(OUTPUT)

# Clean generated files
clean:
	rm -f $(OUTPUT) $(LISTING)

.PHONY: all clean