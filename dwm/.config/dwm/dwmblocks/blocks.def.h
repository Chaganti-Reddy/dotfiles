//Modify this file to change what commands output to your statusbar, and recompile using the make command.
static const Block blocks[] = {
	/*Icon*/	/*Command*/		/*Update Interval*/	/*Update Signal*/
  {"",	"~/.config/dwm/dwmblocks/scripts/nettraf",	1,	16},
  {"",	"~/.config/dwm/dwmblocks/scripts/memory",	10,	14},
  {"",	"~/.config/dwm/dwmblocks/scripts/cpu",		10,	18},
  {"",	"~/.config/dwm/dwmblocks/scripts/volume",	0,	10},
  {"",	"~/.config/dwm/dwmblocks/scripts/battery",	5,	3},

	// {"", "date '+%b %d (%a) %I:%M%p'",					5,		0},
  {"",	"~/.config/dwm/dwmblocks/scripts/clock",	60,	1},
};

//sets delimiter between status commands. NULL character ('\0') means no delimiter.
static char delim[] = " | ";
static unsigned int delimLen = 5;
