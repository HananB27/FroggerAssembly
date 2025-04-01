# Generates a mask file from a GBA 16bpp sprite
# Assumes any pixel with value 0 (black) is transparent
# Adjust the threshold value if your transparent color is different

with open("assets/frogs/frogNorth.img.bin", "rb") as f:
    sprite_data = f.read()

mask_data = bytearray(len(sprite_data))

for i in range(0, len(sprite_data), 2):
    # Read 16-bit value (little-endian)
    pixel = sprite_data[i] | (sprite_data[i+1] << 8)

    # If pixel is not transparent (not black in this example)
    # You may need to change this condition based on what color represents transparency
    if pixel != 0:
        mask_data[i] = 1    # Set to 1 for visible
        mask_data[i+1] = 0  # High byte is 0
    else:
        mask_data[i] = 0    # Set to 0 for transparent
        mask_data[i+1] = 0  # High byte is 0

with open("assets/frogs/frogNorth.mask.bin", "wb") as f:
    f.write(mask_data)