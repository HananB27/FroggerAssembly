SECTIONS
{
    . = 0x08000000;  /* GBA ROM starts at 0x08000000 */
    .text : { *(.text) }
}
