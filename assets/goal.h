
//{{BLOCK(goal)

//======================================================================
//
//	goal, 256x256@4, 
//	+ palette 256 entries, not compressed
//	+ 40 tiles (t|f|p reduced) not compressed
//	+ regular map (in SBBs), not compressed, 32x32 
//	Total size: 512 + 1280 + 2048 = 3840
//
//	Time-stamp: 2025-03-14, 13:58:25
//	Exported by Cearn's GBA Image Transmogrifier, v0.9.2
//	( http://www.coranac.com/projects/#grit )
//
//======================================================================

#ifndef GRIT_GOAL_H
#define GRIT_GOAL_H

#define goalTilesLen 1280
extern const unsigned int goalTiles[320];

#define goalMapLen 2048
extern const unsigned short goalMap[1024];

#define goalPalLen 512
extern const unsigned short goalPal[256];

#endif // GRIT_GOAL_H

//}}BLOCK(goal)
