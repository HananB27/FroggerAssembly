ENTRY(_start)
SECTIONS {
    . = 0x08000000; /* GBA ROM start address */
    .text : {
        *(.text)
    }
}
