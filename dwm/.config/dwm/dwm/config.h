/* See LICENSE file for copyright and license details. */

#define SESSION_FILE "/tmp/dwm-session"

/* appearance */
static const unsigned int borderpx  = 1;        /* border pixel of windows */
static const unsigned int snap      = 32;       /* snap pixel */
static const int swallowfloating    = 0;        /* 1 means swallow floating windows by default */
static const unsigned int gappih    = 5;       /* horiz inner gap between windows */
static const unsigned int gappiv    = 7;       /* vert inner gap between windows */
static const unsigned int gappoh    = 7;       /* horiz outer gap between windows and screen edge */
static const unsigned int gappov    = 5;       /* vert outer gap between windows and screen edge */
static       int smartgaps          = 1;        /* 1 means no outer gap when there is only one window */
static const unsigned int systraypinning = 0;   /* 0: sloppy systray follows selected monitor, >0: pin systray to monitor X */
static const unsigned int systrayonleft = 0;    /* 0: systray in the right corner, >0: systray on left of status text */
static const unsigned int systrayspacing = 2;   /* systray spacing */
static const int systraypinningfailfirst = 1;   /* 1: if pinning fails, display systray on the first monitor, False: display systray on the last monitor*/
static const int showsystray        = 1;        /* 0 means no systray */
static const int showbar            = 1;        /* 0 means no bar */
static const int topbar             = 1;        /* 0 means bottom bar */
static const char *fonts[]          = { "Iosevka Term Nerd Font:weight=bold:size=11:antialias=true:hinting=true", "NotoColorEmoji:pixelsize=11:antialias=true:autohint=true", };
static const char dmenufont[]       = "Iosevka Term Nerd Font:size=12:weight=bold";
static char normbgcolor[]           = "#222222";
static char normbordercolor[]       = "#444444";
static char normfgcolor[]           = "#bbbbbb";
static char selfgcolor[]            = "#eeeeee";
static char selbordercolor[]        = "#005577";
static char selbgcolor[]            = "#005577";
static char *colors[][3] = {
       /*               fg           bg           border   */
       [SchemeNorm] = { normfgcolor, normbgcolor, normbordercolor },
       [SchemeSel]  = { selfgcolor,  selbgcolor,  selbordercolor  },
};

typedef struct {
	const char *name;
	const void *cmd;
} Sp;

const char *spcmd1[] = {"st", "-n", "spterm", "-g", "120x34", NULL};
const char *spcmd2[] = {"kitty", "--class", "spmusic", "-e", "rmpc", NULL};
// const char *spcmd2[] = {"st", "-n", "spmusic", "-g", "120x34", "-e", "rmpc", NULL};
const char *spcmd3[] = {"qalculate-gtk", NULL};
const char *spcmd4[] = {"st", "-n",     "spnews", "-f",       "Iosevka Term Nerd Font:weight=bold:size=12", "-g", "120x34", "-e",     "newsboat", NULL};
const char *spcmd5[] = {"st", "-n", "spchess", "-g", "135x35", "-e", "/home/karna/apps/Chess-linux-x64/Chess", NULL};

static Sp scratchpads[] = {
    /* name          cmd  */
    {"spterm"   ,    spcmd1}, 
    {"spmusic"  ,    spcmd2}, 
    {"spcal"    ,    spcmd3},
    {"spgpt"    ,    spcmd4},  
    {"spnews"   ,    spcmd5},
};

/* tagging */
static const char *tags[]         = { "", "", "", "","", "","", "", "" };
static const char *tagsalt[]      = { "1", "2", "3", "4", "5", "6", "7", "8", "9" };
static const int momentaryalttags = 0; /* 1 means alttags will show only when key is held down*/

static const Rule rules[] = {
	/* class                   instance        title           tags mask     isfloating  isterminal  noswallow  monitor  floatx  floaty  floatw  floath  floatborderpx */
	{ "Gimp",                  NULL,           NULL,           1 << 4,       0,          0,          0,         -1,      -1,     -1,     -1,     -1,     -1 },
	{ "Firefox",              NULL,           NULL,           1 << 7,       0,          0,          0,         -1,      -1,     -1,     -1,     -1,     -1 },

	{ "TelegramDesktop",      NULL,           NULL,           0,            1,          0,          0,         -1,      -1,     -1,     -1,     -1,     -1 },
	{ "Pavucontrol",          NULL,           NULL,           0,            1,          0,          0,         -1,      -1,     -1,     -1,     -1,     -1 },
	{ "Blueman-manager",      NULL,           NULL,           0,            1,          0,          0,         -1,      -1,     -1,     600,    600,    -1 },
	{ "baobab",               NULL,           NULL,           0,            1,          0,          0,         -1,      -1,     -1,     -1,     -1,     -1 },
	{ "qBittorrent",          NULL,           NULL,           1 << 5,       0,          0,          0,         -1,      -1,     -1,     -1,     -1,     -1 },
	{ "pinentry-qt",          NULL,           NULL,           0,            1,          0,          0,         -1,      -1,     -1,     -1,     -1,     -1 },
	{ "Qalculate-gtk",        NULL,           NULL,           0,            1,          0,          0,         -1,      -1,     -1,     -1,     -1,     -1 },
	{ "chess-nativefier-b30d50", NULL,        NULL,           0,            1,          0,          0,         -1,      -1,     -1,     -1,     -1,     -1 },
	{ "Gnome-disks",          NULL,           NULL,           0,            1,          0,          0,         -1,      -1,     -1,     -1,     -1,     -1 },
//	{ "Nm-connection-editor", NULL,           NULL,           0,            1,          0,          0,         -1,      -1,     -1,     -1,     -1,     -1 },
	{ "flameshot",            NULL,           NULL,           0,            1,          0,          0,         -1,      -1,     -1,     -1,     -1,     -1 },
	{ "obs",                  NULL,           NULL,           1 << 7,       1,          0,          0,         -1,      -1,     -1,     -1,     -1,     -1 },
	{ "Brave-browser",        NULL,           NULL,           1 << 1,       0,          0,          0,         -1,      -1,     -1,     -1,     -1,     -1 },
	{ "qutebrowser",          NULL,           NULL,           0,            1,          0,          0,         -1,      -1,     -1,     1100,   900,     -1 },
	{ "Vivaldi-stable",       NULL,           NULL,           1 << 1,       0,          0,          0,         -1,      -1,     -1,     -1,     -1,     -1 },
	{ "discord",              NULL,           NULL,           1 << 5,       0,          0,          0,         -1,      -1,     -1,     -1,     -1,     -1 },

	{ "St",                   NULL,           NULL,           0,            0,          1,          0,         -1,      -1,     -1,     -1,     -1,     -1 },
	{ "kitty",                NULL,           NULL,           0,            0,          1,          0,         -1,      -1,     -1,     -1,     -1,     -1 },
	{ "kitty-yazi",           NULL,           NULL,           0,            1,          1,          0,         -1,      -1,     -1,     1000,   800,    -1 },
	{ NULL,                   NULL,           "Event Tester", 0,            0,          0,          1,         -1,      -1,     -1,     -1,     -1,     -1 },

	{ NULL,                   "spterm",       NULL,           SPTAG(0),     1,          1,          0,         -1,      -1,     -1,     -1,     -1,     -1 },
	{ NULL,                   "spmusic",      NULL,           SPTAG(1),     1,          1,          0,         -1,      -1,     -1,     1000,   800,     -1 },
	{ "Qalculate-gtk",        NULL,           NULL,           SPTAG(2),     1,          0,          0,         -1,      -1,     -1,     -1,     -1,     -1 },
	{ NULL,                   "spnews",       NULL,           SPTAG(3),     1,          1,          0,         -1,      -1,     -1,     -1,     -1,     -1 },
	{ NULL,                   "spchess",      NULL,           SPTAG(4),     1,          1,          0,         -1,      -1,     -1,     -1,     -1,     -1 },
};

/* layout(s) */
static const float mfact     = 0.50; /* factor of master area size [0.05..0.95] */
static const int nmaster     = 1;    /* number of clients in master area */
static const int resizehints = 1;    /* 1 means respect size hints in tiled resizals */
static const int lockfullscreen = 1; /* 1 will force focus on the fullscreen window */

#define FORCE_VSPLIT 1  /* nrowgrid layout: force two clients to always split vertically */
#include "vanitygaps.c"

static const Layout layouts[] = {
	/* symbol     arrange function */
	{ "[\\]",     dwindle },
	{ "[]=",      tile },   
	{ "[M]",      monocle },
	{ "[@]",      spiral },
	{ "H[]",      deck },
	{ "TTT",      bstack },
	{ "===",      bstackhoriz },
	{ "HHH",      grid },
	{ "###",      nrowgrid },
	{ "---",      horizgrid },
	{ ":::",      gaplessgrid },
	{ "|M|",      centeredmaster },
	{ ">M>",      centeredfloatingmaster },
	{ "><>",      NULL },    /* no layout function means floating behavior */
	{ NULL,       NULL },
};

/* key definitions */
#define MODKEY Mod4Mask
#define TAGKEYS(CHAIN,KEY,TAG) \
	{ MODKEY,                       CHAIN,    KEY,      view,           {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask,           CHAIN,    KEY,      toggleview,     {.ui = 1 << TAG} }, \
	{ MODKEY|ShiftMask,             CHAIN,    KEY,      tag,            {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask|ShiftMask, CHAIN,    KEY,      toggletag,      {.ui = 1 << TAG} },

/* helper for spawning shell commands in the pre dwm-5.0 fashion */
#define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }

/* commands */
static char dmenumon[2] = "0"; /* component of dmenucmd, manipulated in spawn() */
static char dmenuprompt[] = "Search: ";
static char rofimodes[]="window,drun,combi";
static const char *dmenucmd[] = { "dmenu_run", "-m", dmenumon, "-fn", dmenufont, "-l", "10", "-p", dmenuprompt, NULL };
static const char *roficmd[] = { "rofi", "-modes", rofimodes, "-show", "combi", "--window-title", "'run'", NULL };
static const char *termcmd[]  = { "st", NULL };
static const char *browser[]  = { "brave", NULL };
static const char *browserAlt[]  = { "qutebrowser", NULL };
static const char *filemanager[] = { "thunar", NULL };
static const char *filemanagerAlt[] = { "kitty", "--class", "kitty-yazi", "-e", "yazi", NULL };
static const char *emacs[] = { "emacsclient", "-c", "-a", "emacs", NULL };

#include "movestack.c"
#include <X11/XF86keysym.h>
static const Key keys[] = {
	/* modifier                   chain    key        function        argument */
	{ MODKEY,                        -1,   XK_d,      spawn,          {.v = dmenucmd } },
	{ MODKEY,                        -1,   XK_Return, spawn,          {.v = termcmd } },
	{ MODKEY|ShiftMask,              -1,   XK_d,      spawn,          {.v = roficmd } },
	{ MODKEY,                        -1,   XK_b,      togglebar,      {0} },
	{ MODKEY,                        -1,   XK_j,      focusstack,     {.i = +1 } },
	{ MODKEY,                        -1,   XK_k,      focusstack,     {.i = -1 } },
	{ MODKEY,                        -1,   XK_i,      incnmaster,     {.i = +1 } },
	{ MODKEY,                        -1,   XK_p,      incnmaster,     {.i = -1 } },
	{ MODKEY,                        -1,   XK_h,      setmfact,       {.f = -0.05} },
	{ MODKEY,                        -1,   XK_l,      setmfact,       {.f = +0.05} },
	{ MODKEY|ShiftMask,              -1,   XK_h,      setcfact,       {.f = +0.25} },
	{ MODKEY|ShiftMask,              -1,   XK_l,      setcfact,       {.f = -0.25} },
	{ MODKEY|ShiftMask,              -1,   XK_o,      setcfact,       {.f =  0.00} },
	{ MODKEY|ShiftMask,              -1,   XK_j,      movestack,      {.i = +1 } },
	{ MODKEY|ShiftMask,              -1,   XK_k,      movestack,      {.i = -1 } },
	{ MODKEY|ShiftMask,              -1,   XK_Return, zoom,           {0} },
	{ MODKEY|Mod1Mask,               -1,   XK_u,      incrgaps,       {.i = +1 } },
	{ MODKEY|Mod1Mask|ShiftMask,     -1,   XK_u,      incrgaps,       {.i = -1 } },
	{ MODKEY|Mod1Mask,               -1,   XK_i,      incrigaps,      {.i = +1 } },
	{ MODKEY|Mod1Mask|ShiftMask,     -1,   XK_i,      incrigaps,      {.i = -1 } },
	{ MODKEY|Mod1Mask,               -1,   XK_o,      incrogaps,      {.i = +1 } },
	{ MODKEY|Mod1Mask|ShiftMask,     -1,   XK_o,      incrogaps,      {.i = -1 } },
	{ MODKEY|Mod1Mask,               -1,   XK_6,      incrihgaps,     {.i = +1 } },
	{ MODKEY|Mod1Mask|ShiftMask,     -1,   XK_6,      incrihgaps,     {.i = -1 } },
	{ MODKEY|Mod1Mask,               -1,   XK_7,      incrivgaps,     {.i = +1 } },
	{ MODKEY|Mod1Mask|ShiftMask,     -1,   XK_7,      incrivgaps,     {.i = -1 } },
	{ MODKEY|Mod1Mask,               -1,   XK_8,      incrohgaps,     {.i = +1 } },
	{ MODKEY|Mod1Mask|ShiftMask,     -1,   XK_8,      incrohgaps,     {.i = -1 } },
	{ MODKEY|Mod1Mask,               -1,   XK_9,      incrovgaps,     {.i = +1 } },
	{ MODKEY|Mod1Mask|ShiftMask,     -1,   XK_9,      incrovgaps,     {.i = -1 } },
	{ MODKEY|Mod1Mask,               -1,   XK_0,      togglegaps,     {0} },
	{ MODKEY|Mod1Mask|ShiftMask,     -1,   XK_0,      defaultgaps,    {0} },
	{ MODKEY,                        -1,   XK_Tab,    view,           {0} },
	{ MODKEY,                        -1,   XK_q,      killclient,     {0} },
	{ MODKEY,                        -1,   XK_t,      setlayout,      {.v = &layouts[0]} },
	{ MODKEY,                        -1,   XK_f,      setlayout,      {.v = &layouts[1]} },
	{ MODKEY,                        -1,   XK_m,      setlayout,      {.v = &layouts[2]} },
	{ MODKEY|ControlMask,		         -1,   XK_comma,  cyclelayout,    {.i = -1 } },
	{ MODKEY|ControlMask,            -1,   XK_period, cyclelayout,    {.i = +1 } },
	{ MODKEY,                        -1,   XK_space,  setlayout,      {0} },
	{ MODKEY|ShiftMask,              -1,   XK_space,  togglefloating, {0} },
	{ MODKEY,                        -1,   XK_f,      togglefullscr,  {0} },
	{ MODKEY,                        -1,   XK_0,      view,           {.ui = ~0 } },
	{ MODKEY|ShiftMask,              -1,   XK_0,      tag,            {.ui = ~0 } },
	{ MODKEY,                        -1,   XK_comma,  focusmon,       {.i = -1 } },
	{ MODKEY,                        -1,   XK_period, focusmon,       {.i = +1 } },
	{ MODKEY|ShiftMask,              -1,   XK_comma,  tagmon,         {.i = -1 } },
	{ MODKEY|ShiftMask,              -1,   XK_period, tagmon,         {.i = +1 } },
	{ MODKEY,                        -1,   XK_F5,     xrdb,           {.v = NULL } },
	{ MODKEY|ControlMask|ShiftMask,  -1,   XK_n,      togglealttag,   {0} },
	TAGKEYS(                         -1,   XK_1,                      0)
	TAGKEYS(                         -1,   XK_2,                      1)
	TAGKEYS(                         -1,   XK_3,                      2)
	TAGKEYS(                         -1,   XK_4,                      3)
	TAGKEYS(                         -1,   XK_5,                      4)
	TAGKEYS(                         -1,   XK_6,                      5)
	TAGKEYS(                         -1,   XK_7,                      6)
	TAGKEYS(                         -1,   XK_8,                      7)
	TAGKEYS(                         -1,   XK_9,                      8)
	{ MODKEY|ControlMask|ShiftMask,  -1,   XK_q,      quit,           {0} },
	{ MODKEY|ShiftMask,              -1,   XK_r,      quit,           {1} }, 
	{ MODKEY,                        -1,   XK_s,      togglesticky,   {0} },

  // Scratchpads
  { 0,                             -1,   XK_F12,    togglescratch,  {.ui = 0} },
  { MODKEY|ShiftMask,              -1,   XK_m,      togglescratch,  {.ui = 1} },
  { MODKEY,                        -1,   XK_c,      togglescratch,  {.ui = 2} },
  { 0,                             -1,   XF86XK_Calculator, togglescratch,  {.ui = 2} },
  { MODKEY|Mod1Mask,               -1,   XK_n,      togglescratch,  {.ui = 3} },
  { 0,                             -1,   XK_F11,    togglescratch,  {.ui = 4} },

  // Main Keybinds
  { MODKEY|ShiftMask,              -1,   XK_n,      spawn,          {.v = filemanager } },
  { MODKEY,                        -1,   XK_n,      spawn,          {.v = filemanagerAlt } },
  { MODKEY,                        -1,   XK_e,      spawn,          {.v = emacs } },
  { MODKEY,                        -1,   XK_w,      spawn,          {.v = browser } },
  { MODKEY|ShiftMask,              -1,   XK_w,      spawn,          {.v = browserAlt } },
  { MODKEY|ShiftMask,              -1,   XK_s,      spawn,          SHCMD("flameshot gui") },
  { MODKEY|Mod1Mask ,              -1,   XK_l,      spawn,          SHCMD("betterlockscreen -l") },

  // Volume Keys 
	{ 0,                             -1,   XF86XK_AudioRaiseVolume,  spawn,  SHCMD("pamixer --allow-boost -i 3 && ~/.dwm/scripts/notify-progress audio") },
	{ 0,                             -1,   XF86XK_AudioLowerVolume,  spawn,  SHCMD("pamixer --allow-boost -d 3 && ~/.dwm/scripts/notify-progress audio") },
	{ 0,                             -1,   XF86XK_AudioMute,         spawn,  SHCMD("pamixer -t && ~/.dwm/scripts/notify-progress muted") },
  { MODKEY|Mod1Mask,               -1,   XK_F9,                    spawn,  SHCMD("pactl set-source-mute @DEFAULT_AUDIO_SOURCE@ toggle") },

  // Brighntess Keys
  { 0,                             -1,   XF86XK_MonBrightnessUp,   spawn,  SHCMD("brightnessctl s 5%+ && ~/.dwm/scripts/notify-progress brightness") },
  { 0,                             -1,   XF86XK_MonBrightnessDown, spawn,  SHCMD("brightnessctl s 5%- && ~/.dwm/scripts/notify-progress brightness") },

  // Music Keys 
  { 0,                             -1,   XF86XK_AudioPlay,         spawn,  SHCMD("mpc toggle && ~/.dwm/scripts/mpd_notify") },
  { 0,                             -1,   XF86XK_AudioNext,         spawn,  SHCMD("mpc next && ~/.dwm/scripts/mpd_notify") },
  { 0,                             -1,   XF86XK_AudioPrev,         spawn,  SHCMD("mpc prev && ~/.dwm/scripts/mpd_notify") },
  { MODKEY|Mod1Mask,               XK_m, XK_t,                     spawn,  SHCMD("mpc toggle && ~/.dwm/scripts/mpd_notify") },
  { MODKEY|Mod1Mask,               XK_m, XK_n,                     spawn,  SHCMD("mpc next && ~/.dwm/scripts/mpd_notify") },
  { MODKEY|Mod1Mask,               XK_m, XK_p,                     spawn,  SHCMD("mpc prev && ~/.dwm/scripts/mpd_notify") },
  { MODKEY|Mod1Mask,               XK_m, XK_s,                     spawn,  SHCMD("mpc stop && ~/.dwm/scripts/mpd_notify") },
  { MODKEY,                        -1,   XK_bracketleft,           spawn,  SHCMD("mpc seek -10") },
  { MODKEY,                        -1,   XK_bracketright,          spawn,  SHCMD("mpc seek +10") },
  
  // Rofi Scripts 
  { MODKEY|Mod1Mask,               -1,   XK_f,                  spawn,  SHCMD("rofi -show find -modi find:~/.config/scripts/rofifinder &") },
  { MODKEY|ControlMask,             -1, XK_f,                   spawn,  SHCMD("~/.config/scripts/rofifm &") },
  { MODKEY|Mod1Mask,               -1,   XK_p,                  spawn,  SHCMD("~/.config/scripts/rofi-pass-xorg &") },
  { MODKEY|ShiftMask,              -1,   XK_a,                  spawn,  SHCMD("~/.config/scripts/script &") },
  { MODKEY,                        -1,   XK_v,                  spawn,  SHCMD("rofi -modi 'clipboard:greenclip print' -show clipboard -run-command '{cmd}'") },
  { MODKEY,                        XK_o, XK_t,                  spawn,  SHCMD("~/.config/scripts/rofi_todo &") },
  { MODKEY,                        XK_o, XK_p,                  spawn,  SHCMD("~/.config/scripts/rofi_pdf &") },
  { MODKEY,                        XK_o, XK_m,                  spawn,  SHCMD("~/.config/scripts/rofi_beats &") },
  { MODKEY,                        XK_o, XK_l,                  spawn,  SHCMD("~/.config/scripts/rofi_learn &") },
  { MODKEY|ShiftMask,               -1,  XK_o,                  spawn,  SHCMD("~/.dwm/scripts/ocr-script &> /tmp/ocr-file.log #&& notify-send 'OCR script' 'select text to be copied'") },
  { MODKEY|ShiftMask,               -1,  XK_e,                  spawn,  SHCMD("~/.config/rofi/applets/bin/emoji.sh &") },
  { MODKEY,                         -1,  XK_F7,                 spawn,  SHCMD("~/.dwm/scripts/drecord &") },
  { MODKEY|ShiftMask,               -1,  XK_p,                  spawn,  SHCMD("~/.config/rofi/powermenu/type-4/powermenu.sh &") },

  // Gromit Keys 
  { MODKEY|ControlMask,             -1, XK_p,                   spawn,  SHCMD("bash -c 'pidof gromit-mpx && gromit-mpx -q || gromit-mpx -k none -u none -a -o 1'") },
  { MODKEY|ControlMask,             -1, XK_F9,                  spawn,  SHCMD("gromit-mpx -t") },
  { MODKEY,                         -1, XK_F9,                  spawn,  SHCMD("gromit-mpx -v") },
  { MODKEY|ShiftMask,               -1, XK_F9,                  spawn,  SHCMD("gromit-mpx -c") },
  { MODKEY|ShiftMask,               -1, XK_F8,                  spawn,  SHCMD("gromit-mpx -y") },
  { MODKEY,                         -1, XK_F8,                  spawn,  SHCMD("gromit-mpx -z") },

  // Example keychain binds
	{ MODKEY,                       XK_a,       XK_d,      spawn,          {.v = dmenucmd } },
	{ MODKEY,                       XK_a,       XK_t,      spawn,          {.v = termcmd } },
};

/* button definitions */
/* click can be ClkTagBar, ClkLtSymbol, ClkStatusText, ClkWinTitle, ClkClientWin, or ClkRootWin */
static const Button buttons[] = {
	/* click                event mask      button          function        argument */
	{ ClkLtSymbol,          0,              Button1,        setlayout,      {0} },
	{ ClkLtSymbol,          0,              Button3,        setlayout,      {.v = &layouts[2]} },
	{ ClkWinTitle,          0,              Button2,        zoom,           {0} },
	{ ClkStatusText,        0,              Button2,        spawn,          {.v = termcmd } },
	{ ClkClientWin,         MODKEY,         Button1,        movemouse,      {0} },
	{ ClkClientWin,         MODKEY,         Button2,        togglefloating, {0} },
	{ ClkClientWin,         MODKEY,         Button1,        resizemouse,    {0} },
	{ ClkTagBar,            0,              Button1,        view,           {0} },
	{ ClkTagBar,            0,              Button3,        toggleview,     {0} },
	{ ClkTagBar,            MODKEY,         Button1,        tag,            {0} },
	{ ClkTagBar,            MODKEY,         Button3,        toggletag,      {0} },
};

