/* See LICENSE file for copyright and license details. */

/* Helper macros for spawning commands */
#define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }
#define CMD(...)   { .v = (const char*[]){ __VA_ARGS__, NULL } }

/* appearance */
static const unsigned int borderpx       = 1;   /* border pixel of windows */
static const unsigned int snap           = 32;  /* snap pixel */
static const int swallowfloating         = 0;   /* 1 means swallow floating windows by default */
static const unsigned int gappih         = 7;  /* horiz inner gap between windows */
static const unsigned int gappiv         = 7;  /* vert inner gap between windows */
static const unsigned int gappoh         = 5;  /* horiz outer gap between windows and screen edge */
static const unsigned int gappov         = 5;  /* vert outer gap between windows and screen edge */
static const int smartgaps_fact          = 0;   /* gap factor when there is only one client; 0 = no gaps, 3 = 3x outer gaps */
static const char autostartblocksh[]     = "autostart_blocking.sh";
static const char autostartsh[]          = "autostart.sh";
static const char dwmdir[]               = "dwm";
static const char localshare[]           = ".local/share";
static const int showbar                 = 1;   /* 0 means no bar */
static const int topbar                  = 1;   /* 0 means bottom bar */
static int floatposgrid_x                = 5;  /* float grid columns */
static int floatposgrid_y                = 5;  /* float grid rows */
/* Status is to be shown on: -1 (all monitors), 0 (a specific monitor by index), 'A' (active monitor) */
static const int statusmon               = 'A';
static const unsigned int systrayspacing = 2;   /* systray spacing */
static const int showsystray             = 1;   /* 0 means no systray */

/* Indicators: see patch/bar_indicators.h for options */
static int tagindicatortype              = INDICATOR_TOP_LEFT_SQUARE;
static int tiledindicatortype            = INDICATOR_NONE;
static int floatindicatortype            = INDICATOR_TOP_LEFT_SQUARE;
static const char *fonts[] = {
    "Iosevka Nerd Font:weight=bold:size=11:antialias=true:hinting=true",
    "NotoColorEmoji:pixelsize=11:antialias=true:autohint=true"
    "Font Awesome 6 Free Solid:size=11",
    "JoyPixels:size=11:antialias=true:autohint=true"};
static const char dmenufont[]       = "Iosevka Nerd Font:size=12:weight=bold";

static char c000000[]                    = "#000000"; // placeholder value

static char normfgcolor[]                = "#bbbbbb";
static char normbgcolor[]                = "#222222";
static char normbordercolor[]            = "#444444";
static char normfloatcolor[]             = "#db8fd9";

static char selfgcolor[]                 = "#eeeeee";
static char selbgcolor[]                 = "#005577";
static char selbordercolor[]             = "#005577";
static char selfloatcolor[]              = "#005577";

static char titlenormfgcolor[]           = "#bbbbbb";
static char titlenormbgcolor[]           = "#222222";
static char titlenormbordercolor[]       = "#444444";
static char titlenormfloatcolor[]        = "#db8fd9";

static char titleselfgcolor[]            = "#eeeeee";
static char titleselbgcolor[]            = "#005577";
static char titleselbordercolor[]        = "#005577";
static char titleselfloatcolor[]         = "#005577";

static char tagsnormfgcolor[]            = "#bbbbbb";
static char tagsnormbgcolor[]            = "#222222";
static char tagsnormbordercolor[]        = "#444444";
static char tagsnormfloatcolor[]         = "#db8fd9";

static char tagsselfgcolor[]             = "#eeeeee";
static char tagsselbgcolor[]             = "#005577";
static char tagsselbordercolor[]         = "#005577";
static char tagsselfloatcolor[]          = "#005577";

static char hidnormfgcolor[]             = "#005577";
static char hidselfgcolor[]              = "#227799";
static char hidnormbgcolor[]             = "#222222";
static char hidselbgcolor[]              = "#222222";

static char urgfgcolor[]                 = "#bbbbbb";
static char urgbgcolor[]                 = "#222222";
static char urgbordercolor[]             = "#ff0000";
static char urgfloatcolor[]              = "#db8fd9";

static char *colors[][ColCount] = {
	/*                       fg                bg                border                float */
	[SchemeNorm]         = { normfgcolor,      normbgcolor,      normbordercolor,      normfloatcolor },
	[SchemeSel]          = { selfgcolor,       selbgcolor,       selbordercolor,       selfloatcolor },
	[SchemeTitleNorm]    = { titlenormfgcolor, titlenormbgcolor, titlenormbordercolor, titlenormfloatcolor },
	[SchemeTitleSel]     = { titleselfgcolor,  titleselbgcolor,  titleselbordercolor,  titleselfloatcolor },
	[SchemeTagsNorm]     = { tagsnormfgcolor,  tagsnormbgcolor,  tagsnormbordercolor,  tagsnormfloatcolor },
	[SchemeTagsSel]      = { tagsselfgcolor,   tagsselbgcolor,   tagsselbordercolor,   tagsselfloatcolor },
	[SchemeHidNorm]      = { hidnormfgcolor,   hidnormbgcolor,   c000000,              c000000 },
	[SchemeHidSel]       = { hidselfgcolor,    hidselbgcolor,    c000000,              c000000 },
	[SchemeUrg]          = { urgfgcolor,       urgbgcolor,       urgbordercolor,       urgfloatcolor },
};

const char *spcmd1[] = {"st", "-n", "spterm", "-g", "120x34", NULL};
const char *spcmd2[] = {"st", "-n", "spmusic", "-g", "120x34", "-e", "/home/karna/.ncmpcpp/scripts/ncmpcpp-art", NULL};
const char *spcmd3[] = {"qalculate-gtk", NULL};
const char *spcmd4[] = {
    "st", "-n",     "spnews", "-f",       "Iosevka Nerd Font:weight=bold:size=12",
    "-g", "120x34", "-e",     "newsboat", NULL};
const char *spcmd5[] = {"st", "-n", "spchess", "-g", "135x35", "-e", "/home/karna/apps/chess-linux-x64/chess", NULL};

static Sp scratchpads[] = {
    /* name          cmd  */
    {"spterm", spcmd1}, {"spmusic", spcmd2}, {"spcal", spcmd3},
    {"spgpt", spcmd4},  {"spnews", spcmd5},
};


/* Tags
 * In a traditional dwm the number of tags in use can be changed simply by changing the number
 * of strings in the tags array. This build does things a bit different which has some added
 * benefits. If you need to change the number of tags here then change the NUMTAGS macro in dwm.c.
 *
 * Examples:
 *
 *  1) static char *tagicons[][NUMTAGS*2] = {
 *         [DEFAULT_TAGS] = { "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F", "G", "H", "I" },
 *     }
 *
 *  2) static char *tagicons[][1] = {
 *         [DEFAULT_TAGS] = { "•" },
 *     }
 *
 * The first example would result in the tags on the first monitor to be 1 through 9, while the
 * tags for the second monitor would be named A through I. A third monitor would start again at
 * 1 through 9 while the tags on a fourth monitor would also be named A through I. Note the tags
 * count of NUMTAGS*2 in the array initialiser which defines how many tag text / icon exists in
 * the array. This can be changed to *3 to add separate icons for a third monitor.
 *
 * For the second example each tag would be represented as a bullet point. Both cases work the
 * same from a technical standpoint - the icon index is derived from the tag index and the monitor
 * index. If the icon index is is greater than the number of tag icons then it will wrap around
 * until it an icon matches. Similarly if there are two tag icons then it would alternate between
 * them. This works seamlessly with alternative tags and alttagsdecoration patches.
 */
static char *tagicons[][NUMTAGS] =
{
	[DEFAULT_TAGS]        = {"", "", "", "","", "","", "", ""},
	// [DEFAULT_TAGS]        = { "1", "2", "3", "4", "5", "6", "7", "8", "9" },
	[ALTERNATIVE_TAGS]    = { "A", "B", "C", "D", "E", "F", "G", "H", "I" },
	[ALT_TAGS_DECORATION] = { "<1>", "<2>", "<3>", "<4>", "<5>", "<6>", "<7>", "<8>", "<9>" },
};

/* There are two options when it comes to per-client rules:
 *  - a typical struct table or
 *  - using the RULE macro
 *
 * A traditional struct table looks like this:
 *    // class      instance  title  wintype  tags mask  isfloating  monitor
 *    { "Gimp",     NULL,     NULL,  NULL,    1 << 4,    0,          -1 },
 *    { "Firefox",  NULL,     NULL,  NULL,    1 << 7,    0,          -1 },
 *
 * The RULE macro has the default values set for each field allowing you to only
 * specify the values that are relevant for your rule, e.g.
 *
 *    RULE(.class = "Gimp", .tags = 1 << 4)
 *    RULE(.class = "Firefox", .tags = 1 << 7)
 *
 * Refer to the Rule struct definition for the list of available fields depending on
 * the patches you enable.
 */
static const Rule rules[] = {
	/* xprop(1):
	 *	WM_CLASS(STRING) = instance, class
	 *	WM_NAME(STRING) = title
	 *	WM_WINDOW_ROLE(STRING) = role
	 *	_NET_WM_WINDOW_TYPE(ATOM) = wintype
	 */
	RULE(.wintype = WTYPE "DIALOG", .isfloating = 1)
	RULE(.wintype = WTYPE "UTILITY", .isfloating = 1)
	RULE(.wintype = WTYPE "TOOLBAR", .isfloating = 1)
	RULE(.wintype = WTYPE "SPLASH", .isfloating = 1)

	RULE(.class = "Gimp", .tags = 1 << 4)
	RULE(.class = "Firefox", .tags = 1 << 7)

	RULE(.class = "TelegramDesktop", .isfloating = 1)
	RULE(.class = "Pavucontrol", .isfloating = 1)
	RULE(.class = "Blueman-manager", .isfloating = 1, .floatpos = "0x 0y 800W 800H")
	RULE(.class = "baobab", .isfloating = 1)
	RULE(.class = "qBittorrent", .tags = 1 << 5)
	RULE(.class = "pinentry-qt", .isfloating = 1)
	RULE(.class = "Qalculate-gtk", .isfloating = 1)
	RULE(.class = "chess-nativefier-703820", .isfloating = 1)
	RULE(.class = "Gnome-disks", .isfloating = 1)
	RULE(.class = "Nm-connection-editor", .isfloating = 1)
	RULE(.class = "flameshot", .isfloating = 1)
	RULE(.class = "obs", .tags = 1 << 7, .isfloating = 1)
	RULE(.class = "Brave-browser", .tags = 1 << 1)
	RULE(.class = "Vivaldi-stable", .tags = 1 << 1)
	RULE(.class = "discord", .tags = 1 << 5)

	RULE(.class = "St", .isterminal = 1)
	RULE(.class = "kitty", .isterminal = 1)
	RULE(.title = "Event Tester", .noswallow = 1)

	RULE(.instance = "spterm", .tags = SPTAG(0), .isfloating = 1, .isterminal = 1)
	RULE(.instance = "spmusic", .tags = SPTAG(1), .isfloating = 1, .isterminal = 1)
	RULE(.class    = "Qalculate-gtk", .tags = SPTAG(2), .isfloating = 1)
	RULE(.instance = "spnews", .tags = SPTAG(3), .isfloating = 1, .isterminal = 1)
	RULE(.instance = "spchess", .tags = SPTAG(4), .isfloating = 1, .isterminal = 1)
};


/* Bar rules allow you to configure what is shown where on the bar, as well as
 * introducing your own bar modules.
 *
 *    monitor:
 *      -1  show on all monitors
 *       0  show on monitor 0
 *      'A' show on active monitor (i.e. focused / selected) (or just -1 for active?)
 *    bar - bar index, 0 is default, 1 is extrabar
 *    alignment - how the module is aligned compared to other modules
 *    widthfunc, drawfunc, clickfunc - providing bar module width, draw and click functions
 *    name - does nothing, intended for visual clue and for logging / debugging
 */
static const BarRule barrules[] = {
	/* monitor   bar    alignment         widthfunc                 drawfunc                clickfunc                hoverfunc                name */
	{ -1,        0,     BAR_ALIGN_LEFT,   width_tags,               draw_tags,              click_tags,              hover_tags,              "tags" },
	{  0,        0,     BAR_ALIGN_RIGHT,  width_systray,            draw_systray,           click_systray,           NULL,                    "systray" },
	{ -1,        0,     BAR_ALIGN_LEFT,   width_ltsymbol,           draw_ltsymbol,          click_ltsymbol,          NULL,                    "layout" },
	{ statusmon, 0,     BAR_ALIGN_RIGHT,  width_status,             draw_status,            click_statuscmd,         NULL,                    "status" },
	{ -1,        0,     BAR_ALIGN_NONE,   width_wintitle,           draw_wintitle,          click_wintitle,          NULL,                    "wintitle" },
};

/* layout(s) */
static const float mfact     = 0.5; /* factor of master area size [0.05..0.95] */
static const int nmaster     = 1;    /* number of clients in master area */
static const int resizehints = 0;    /* 1 means respect size hints in tiled resizals */
static const int lockfullscreen = 1; /* 1 will force focus on the fullscreen window */

static const Layout layouts[] = {
	/* symbol     arrange function */
	{ "[\\]",     dwindle }, /* first entry is default */
	{ "HHH",      grid },
	{ "[]=",      tile },
	{ "[M]",      monocle },
	{ "><>",      NULL },    /* no layout function means floating behavior */
};

/* key definitions */
#define MODKEY Mod4Mask
#define TAGKEYS(KEY,TAG) \
	{ MODKEY,                       KEY,      view,           {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask,           KEY,      toggleview,     {.ui = 1 << TAG} }, \
	{ MODKEY|ShiftMask,             KEY,      tag,            {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask|ShiftMask, KEY,      toggletag,      {.ui = 1 << TAG} },

/* commands */
static char dmenumon[2] = "0"; /* component of dmenucmd, manipulated in spawn() */
static char dmenuprompt[256] = "Search:";
static const char *dmenucmd[] = {
	"dmenu_run",
	"-m", dmenumon,
	"-fn", dmenufont,
  "-l", "10", "-p", dmenuprompt, 
	NULL
};
static const char *termcmd[]      = { "st", NULL };
static const char *volume_up[]    = { "sh", "-c", "wpctl set-volume @DEFAULT_AUDIO_SINK@ 3%+ && kill -44 $(pidof dwmblocks)", NULL };
static const char *volume_down[]  = { "sh", "-c", "wpctl set-volume @DEFAULT_AUDIO_SINK@ 3%- && kill -44 $(pidof dwmblocks)", NULL };
static const char *volume_mute[]  = { "sh", "-c", "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle && kill -44 $(pidof dwmblocks)", NULL };
static const char *mic_mute[]     = { "sh", "-c", "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle && kill -44 $(pidof dwmblocks)", NULL };
static const char *mic_up[]       = { "sh", "-c", "wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 5%+ && pkill -RTMIN+10 dwmblocks", NULL };
static const char *mic_down[]     = { "sh", "-c", "wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 5%- && pkill -RTMIN+10 dwmblocks", NULL }; // Both Kill and Pkill signals works same for 10
static const char *bright_up[]    = { "brightnessctl", "s", "5%+", NULL };
static const char *bright_down[]  = { "brightnessctl", "s", "5%-", NULL };
static const char *emacs[]        = {"emacs", NULL};
static const char *browser[]      = {"vivaldi", NULL};
static const char *browser1[]     = {"qutebrowser", NULL};
static const char *files[]        = {"st", "-e", "yazi", NULL};
static const char *files1[]       = {"thunar", NULL};
static const char *editor1[]      = {"kitty", "-e", "nvim", NULL};

/* This defines the name of the executable that handles the bar (used for signalling purposes) */
#define STATUSBAR "dwmblocks"
#include <X11/XF86keysym.h>

static const Key keys[] = {
	/* modifier                     key            function                argument */
	{ MODKEY,                       XK_d,          spawn,                  {.v = dmenucmd } },
	{ MODKEY,                       XK_Return,     spawn,                  {.v = termcmd } },
	{ MODKEY,                       XK_b,          togglebar,              {0} },
	{ MODKEY,                       XK_j,          focusstack,             {.i = +1 } },
	{ MODKEY,                       XK_k,          focusstack,             {.i = -1 } },
  { MODKEY,                       XK_Left,       focusstack,             {.i = -1} },
  { MODKEY,                       XK_Right,      focusstack,             {.i = +1} },
	{ MODKEY|Mod1Mask,              XK_j,          rotatestack,            {.i = +1 } },
	{ MODKEY|Mod1Mask,              XK_k,          rotatestack,            {.i = -1 } },
	{ MODKEY,                       XK_i,          incnmaster,             {.i = +1 } },
	{ MODKEY,                       XK_p,          incnmaster,             {.i = -1 } },
	{ MODKEY,                       XK_h,          setmfact,               {.f = -0.05} },
	{ MODKEY,                       XK_l,          setmfact,               {.f = +0.05} },
	{ MODKEY|ShiftMask,             XK_h,          setcfact,               {.f = +0.25} },
	{ MODKEY|ShiftMask,             XK_l,          setcfact,               {.f = -0.25} },
	{ MODKEY|ShiftMask,             XK_o,          setcfact,               {0} },
	{ MODKEY|ShiftMask,             XK_j,          movestack,              {.i = +1 } },
	{ MODKEY|ShiftMask,             XK_k,          movestack,              {.i = -1 } },
  { MODKEY|ShiftMask,             XK_Left,       movestack,              {.i = +1} },
  { MODKEY|ShiftMask,             XK_Right,      movestack,              {.i = -1} },
	{ MODKEY|ShiftMask,             XK_Return,     zoom,                   {0} },
	{ MODKEY|Mod1Mask,              XK_u,          incrgaps,               {.i = +1 } },
	{ MODKEY|Mod1Mask|ShiftMask,    XK_u,          incrgaps,               {.i = -1 } },
	{ MODKEY|Mod1Mask,              XK_i,          incrigaps,              {.i = +1 } },
	{ MODKEY|Mod1Mask|ShiftMask,    XK_i,          incrigaps,              {.i = -1 } },
	{ MODKEY|Mod1Mask,              XK_o,          incrogaps,              {.i = +1 } },
	{ MODKEY|Mod1Mask|ShiftMask,    XK_o,          incrogaps,              {.i = -1 } },
	{ MODKEY|Mod1Mask,              XK_6,          incrihgaps,             {.i = +1 } },
	{ MODKEY|Mod1Mask|ShiftMask,    XK_6,          incrihgaps,             {.i = -1 } },
	{ MODKEY|Mod1Mask,              XK_7,          incrivgaps,             {.i = +1 } },
	{ MODKEY|Mod1Mask|ShiftMask,    XK_7,          incrivgaps,             {.i = -1 } },
	{ MODKEY|Mod1Mask,              XK_8,          incrohgaps,             {.i = +1 } },
	{ MODKEY|Mod1Mask|ShiftMask,    XK_8,          incrohgaps,             {.i = -1 } },
	{ MODKEY|Mod1Mask,              XK_9,          incrovgaps,             {.i = +1 } },
	{ MODKEY|Mod1Mask|ShiftMask,    XK_9,          incrovgaps,             {.i = -1 } },
	{ MODKEY|Mod1Mask,              XK_0,          togglegaps,             {0} },
	{ MODKEY|Mod1Mask|ShiftMask,    XK_0,          defaultgaps,            {0} },
	{ MODKEY,                       XK_backslash,  view,                   {0} },
	{ MODKEY,                       XK_q,          killclient,             {0} },
	{ MODKEY|ShiftMask,             XK_q,          quit,                   {0} },
	{ MODKEY|ShiftMask,             XK_r,          quit,                   {1} },
	{ MODKEY,                       XK_F5,         xrdb,                   {.v = NULL } },
	{ MODKEY,                       XK_t,          setlayout,              {.v = &layouts[0]} },
	{ MODKEY,                       XK_f,          setlayout,              {.v = &layouts[1]} },
	{ MODKEY,                       XK_m,          setlayout,              {.v = &layouts[2]} },
	{ MODKEY,                       XK_space,      setlayout,              {0} },
	{ MODKEY|ShiftMask,             XK_f,          togglefloating,         {0} },
	{ MODKEY,                       XK_grave,      togglescratch,          {.ui = 0 } },
	{ MODKEY|ControlMask,           XK_grave,      setscratch,             {.ui = 0 } },
	{ MODKEY|ShiftMask,             XK_grave,      removescratch,          {.ui = 0 } },
	{ MODKEY,                       XK_y,          togglefullscreen,       {0} },
	{ MODKEY|ShiftMask,             XK_s,          togglesticky,           {0} },
	{ MODKEY,                       XK_0,          view,                   {.ui = ~SPTAGMASK } },
	{ MODKEY|ShiftMask,             XK_0,          tag,                    {.ui = ~SPTAGMASK } },
	{ MODKEY,                       XK_comma,      focusmon,               {.i = -1 } },
	{ MODKEY,                       XK_period,     focusmon,               {.i = +1 } },
	{ MODKEY|ShiftMask,             XK_comma,      tagmon,                 {.i = -1 } },
	{ MODKEY|ShiftMask,             XK_period,     tagmon,                 {.i = +1 } },
  /* Note that due to key limitations the below example kybindings are defined with a Mod3Mask,
	 * which is not always readily available. Refer to the patch wiki for more details. */
	/* Client position is limited to monitor window area */
	{ Mod3Mask,                     XK_u,            floatpos,               {.v = "-26x -26y" } }, // ↖
	{ Mod3Mask,                     XK_i,            floatpos,               {.v = "  0x -26y" } }, // ↑
	{ Mod3Mask,                     XK_o,            floatpos,               {.v = " 26x -26y" } }, // ↗
	{ Mod3Mask,                     XK_j,            floatpos,               {.v = "-26x   0y" } }, // ←
	{ Mod3Mask,                     XK_l,            floatpos,               {.v = " 26x   0y" } }, // →
	{ Mod3Mask,                     XK_m,            floatpos,               {.v = "-26x  26y" } }, // ↙
	{ Mod3Mask,                     XK_comma,        floatpos,               {.v = "  0x  26y" } }, // ↓
	{ Mod3Mask,                     XK_period,       floatpos,               {.v = " 26x  26y" } }, // ↘
	/* Absolute positioning (allows moving windows between monitors) */
	{ Mod3Mask|ControlMask,         XK_u,            floatpos,               {.v = "-26a -26a" } }, // ↖
	{ Mod3Mask|ControlMask,         XK_i,            floatpos,               {.v = "  0a -26a" } }, // ↑
	{ Mod3Mask|ControlMask,         XK_o,            floatpos,               {.v = " 26a -26a" } }, // ↗
	{ Mod3Mask|ControlMask,         XK_j,            floatpos,               {.v = "-26a   0a" } }, // ←
	{ Mod3Mask|ControlMask,         XK_l,            floatpos,               {.v = " 26a   0a" } }, // →
	{ Mod3Mask|ControlMask,         XK_m,            floatpos,               {.v = "-26a  26a" } }, // ↙
	{ Mod3Mask|ControlMask,         XK_comma,        floatpos,               {.v = "  0a  26a" } }, // ↓
	{ Mod3Mask|ControlMask,         XK_period,       floatpos,               {.v = " 26a  26a" } }, // ↘
	/* Resize client, client center position is fixed which means that client expands in all directions */
	{ Mod3Mask|ShiftMask,           XK_u,            floatpos,               {.v = "-26w -26h" } }, // ↖
	{ Mod3Mask|ShiftMask,           XK_i,            floatpos,               {.v = "  0w -26h" } }, // ↑
	{ Mod3Mask|ShiftMask,           XK_o,            floatpos,               {.v = " 26w -26h" } }, // ↗
	{ Mod3Mask|ShiftMask,           XK_j,            floatpos,               {.v = "-26w   0h" } }, // ←
	{ Mod3Mask|ShiftMask,           XK_k,            floatpos,               {.v = "800W 800H" } }, // ·
	{ Mod3Mask|ShiftMask,           XK_l,            floatpos,               {.v = " 26w   0h" } }, // →
	{ Mod3Mask|ShiftMask,           XK_m,            floatpos,               {.v = "-26w  26h" } }, // ↙
	{ Mod3Mask|ShiftMask,           XK_comma,        floatpos,               {.v = "  0w  26h" } }, // ↓
	{ Mod3Mask|ShiftMask,           XK_period,       floatpos,               {.v = " 26w  26h" } }, // ↘
	/* Client is positioned in a floating grid, movement is relative to client's current position */
	{ Mod3Mask|Mod1Mask,            XK_u,            floatpos,               {.v = "-1p -1p" } }, // ↖
	{ Mod3Mask|Mod1Mask,            XK_i,            floatpos,               {.v = " 0p -1p" } }, // ↑
	{ Mod3Mask|Mod1Mask,            XK_o,            floatpos,               {.v = " 1p -1p" } }, // ↗
	{ Mod3Mask|Mod1Mask,            XK_j,            floatpos,               {.v = "-1p  0p" } }, // ←
	{ Mod3Mask|Mod1Mask,            XK_k,            floatpos,               {.v = " 0p  0p" } }, // ·
	{ Mod3Mask|Mod1Mask,            XK_l,            floatpos,               {.v = " 1p  0p" } }, // →
	{ Mod3Mask|Mod1Mask,            XK_m,            floatpos,               {.v = "-1p  1p" } }, // ↙
	{ Mod3Mask|Mod1Mask,            XK_comma,        floatpos,               {.v = " 0p  1p" } }, // ↓
	{ Mod3Mask|Mod1Mask,            XK_period,       floatpos,               {.v = " 1p  1p" } }, // ↘
	{ MODKEY|ControlMask,           XK_comma,      cyclelayout,            {.i = -1 } },
	{ MODKEY|ControlMask,           XK_period,     cyclelayout,            {.i = +1 } },
	TAGKEYS(                        XK_1,                                  0)
	TAGKEYS(                        XK_2,                                  1)
	TAGKEYS(                        XK_3,                                  2)
	TAGKEYS(                        XK_4,                                  3)
	TAGKEYS(                        XK_5,                                  4)
	TAGKEYS(                        XK_6,                                  5)
	TAGKEYS(                        XK_7,                                  6)
	TAGKEYS(                        XK_8,                                  7)
	TAGKEYS(                        XK_9,                                  8)

  // Scratchpads
  { 0,                            XK_F12,       togglescratch,          {.ui = 0} },
  { MODKEY|ShiftMask,             XK_m,         togglescratch,          {.ui = 1} },
  { MODKEY,                       XK_c,         togglescratch,          {.ui = 2} },
  { MODKEY|Mod1Mask,              XK_n,         togglescratch,          {.ui = 3} },
  { 0,                            XK_F11,       togglescratch,          {.ui = 4} },

  // Volume Keys 
  { 0,                            XF86XK_AudioLowerVolume,        spawn,          {.v = volume_down } },
  { 0,                            XF86XK_AudioRaiseVolume,        spawn,          {.v = volume_up } },
  { 0,                            XF86XK_AudioMute,               spawn,          {.v = volume_mute } },
  { MODKEY,                       XK_F9,                          spawn,          {.v = mic_mute } },
  { MODKEY,                       XK_F11,                         spawn,          {.v = mic_up } },
  { MODKEY,                       XK_F10,                         spawn,          {.v = mic_down } },

	//{ MODKEY,			XK_bracketleft, spawn,                 {.v = (const char*[]){ "mpc", "seek", "-10", NULL } } },
	//{ MODKEY|ShiftMask,		XK_bracketleft, spawn,                 {.v = (const char*[]){ "mpc", "seek", "-60", NULL } } },
	//{ MODKEY,			XK_bracketright, spawn,                {.v = (const char*[]){ "mpc", "seek", "+10", NULL } } },
	//{ MODKEY|ShiftMask,		XK_bracketright, spawn,                {.v = (const char*[]){ "mpc", "seek", "+60", NULL } } },

  // Brightness Keys
  { 0,                            XF86XK_MonBrightnessUp,        spawn,          {.v = bright_up } },
  { 0,                            XF86XK_MonBrightnessDown,      spawn,          {.v = bright_down } },

  
   //  {MODKEY | ShiftMask, XK_p, spawn, SHCMD("~/.dwm/scripts/power")},
   //  {MODKEY | ShiftMask, XK_e, spawn, SHCMD("~/.config/rofi/applets/bin/emoji.sh")},
   //  {Mod1Mask , XK_Tab, spawn, SHCMD("~/.config/rofi/launchers/type-7/windows.sh")},
   //  {MODKEY | Mod1Mask, XK_p, spawn, SHCMD("~/.config/scripts/rofi-pass-xorg")},
   //  {MODKEY | ShiftMask, XK_a, spawn, SHCMD("~/.dwm/scripts/script")},
   //  {MODKEY | ShiftMask, XK_s, spawn, SHCMD("flameshot gui")},
   //  // {MODKEY | Mod1Mask, XK_l, spawn, SHCMD("betterlockscreen -l -q")},
   //  {MODKEY | Mod1Mask, XK_l, spawn, SHCMD("xscreensaver-command -lock &")},
   //  // {MODKEY | ControlMask | ShiftMask, XK_i, spawn,
   //   // SHCMD("networkmanager_dmenu")},
   //  {MODKEY, XK_w, spawn, {.v = browser}},
   //  // {MODKEY | ShiftMask, XK_m, spawn, {.v = music}},
   //  {MODKEY | ShiftMask, XK_w, spawn, {.v = browser1}},
   //  {MODKEY , XK_n, spawn, {.v = files}},
   //  {MODKEY | ShiftMask, XK_n, spawn, {.v = files1}},
   //  {MODKEY, XK_v, spawn, SHCMD("subl")},
   //  {MODKEY, XK_a, spawn, {.v = editor1}},
   //  // {MODKEY, XK_F8, spawn, {.v = (const char *[]){"mpc", "next", NULL}}},
   //  // {MODKEY, XK_F7, spawn, {.v = (const char *[]){"mpc", "toggle", NULL}}},
   //  // {MODKEY, XK_F6, spawn, {.v = (const char *[]){"mpc", "prev", NULL}}},
   //  //{MODKEY | ShiftMask,
   //   // spawn,
   //   // {.v = (const char *[]){"mpc", "stop", NULL}}},
			//
   //  // Music controls with Mod + Alt
   //  { MODKEY|Mod1Mask,             XK_1,      spawn, SHCMD("mpc toggle") },
   //  { MODKEY|Mod1Mask,             XK_2,      spawn, SHCMD("mpc prev") },
   //  { MODKEY|Mod1Mask,             XK_3,      spawn, SHCMD("mpc next") },
			//
   //  // Music stop with Mod + Shift + Alt
   //  { MODKEY|Mod1Mask|ShiftMask,   XK_1,      spawn, SHCMD("mpc stop") },
			//
   //  { 0, XF86XK_AudioPrev,		spawn,		{.v = (const char*[]){ "mpc", "prev", NULL } } },
	  // { 0, XF86XK_AudioNext,		spawn,		{.v = (const char*[]){ "mpc",  "next", NULL } } },
	  // { 0, XF86XK_AudioPlay,		spawn,		{.v = (const char*[]){ "mpc", "toggle", NULL } } },
   //  {MODKEY,
   //   XK_F7,
   //   spawn,
   //   {.v = (const char *[]){"mpc", "stop", NULL}}},

};

/* button definitions */
/* click can be ClkTagBar, ClkLtSymbol, ClkStatusText, ClkWinTitle, ClkClientWin, or ClkRootWin */
static const Button buttons[] = {
	/* click                event mask           button          function        argument */
	{ ClkLtSymbol,          0,                   Button1,        setlayout,      {0} },
	{ ClkLtSymbol,          0,                   Button3,        setlayout,      {.v = &layouts[2]} },
	{ ClkWinTitle,          0,                   Button2,        zoom,           {0} },
	{ ClkStatusText,        0,                   Button1,        sigstatusbar,   {.i = 1 } },
	{ ClkStatusText,        0,                   Button2,        sigstatusbar,   {.i = 2 } },
	{ ClkStatusText,        0,                   Button3,        sigstatusbar,   {.i = 3 } },
  { ClkStatusText,        0,                   Button4,        sigstatusbar,   {.i = 4 } },
  { ClkStatusText,        0,                   Button5,        sigstatusbar,   {.i = 5 } },
  { ClkStatusText,        ControlMask,         Button4,        sigstatusbar,   {.i = 6 } },
  { ClkStatusText,        ControlMask,         Button5,        sigstatusbar,   {.i = 7 } },
  { ClkStatusText,        ControlMask,         Button1,        sigstatusbar,   {.i = 8 } },
  { ClkStatusText,        ShiftMask,           Button1,        sigstatusbar,   {.i = 9 } },
	{ ClkClientWin,         MODKEY,              Button1,        movemouse,      {0} },
	{ ClkClientWin,         MODKEY,              Button2,        togglefloating, {0} },
	{ ClkClientWin,         MODKEY,              Button3,        resizemouse,    {0} },
	{ ClkClientWin,         MODKEY|ShiftMask,    Button1,        dragmfact,      {0} },
	{ ClkTagBar,            0,                   Button1,        view,           {0} },
	{ ClkTagBar,            0,                   Button3,        toggleview,     {0} },
	{ ClkTagBar,            MODKEY,              Button1,        tag,            {0} },
	{ ClkTagBar,            MODKEY,              Button3,        toggletag,      {0} },
};


