def raw_to_words(filepath, output_words_per_line=8):
    with open(filepath, "rb") as f:
        data = f.read()

    assert len(data) % 2 == 0, "RAW file must have even number of bytes (16-bit pixels)"

    words = []
    for i in range(0, len(data), 2):
        val = int.from_bytes(data[i:i+2], "little")
        words.append(val)

    # Format as .word lines
    for i in range(0, len(words), output_words_per_line):
        chunk = words[i:i+output_words_per_line]
        line = "\t.word " + ",".join(f"0x{w:04X}" for w in chunk)
        print(line)

# Run the converter
raw_to_words("frogs/frog1.RAW")
