
//{{BLOCK(background)

//======================================================================
//
//	background, 1024x1024@4, 
//	+ palette 256 entries, not compressed
//	+ 2176 tiles (t|f|p reduced) not compressed
//	+ regular map (in SBBs), not compressed, 128x128 
//	Total size: 512 + 69632 + 32768 = 102912
//
//	Time-stamp: 2025-03-14, 13:56:07
//	Exported by Cearn's GBA Image Transmogrifier, v0.9.2
//	( http://www.coranac.com/projects/#grit )
//
//======================================================================

#ifndef GRIT_BACKGROUND_H
#define GRIT_BACKGROUND_H

#define backgroundTilesLen 69632
extern const unsigned int backgroundTiles[17408];

#define backgroundMapLen 32768
extern const unsigned short backgroundMap[16384];

#define backgroundPalLen 512
extern const unsigned short backgroundPal[256];

#endif // GRIT_BACKGROUND_H

//}}BLOCK(background)
