/* See LICENSE file for copyright and license details. */

/* appearance */
static const unsigned int borderpx = 3; /* border pixel of windows */
static const unsigned int snap = 32;    /* snap pixel */
static const unsigned int systraypinning =
    0; /* 0: sloppy systray follows selected monitor, >0: pin systray to monitor
          X */
static const unsigned int systrayonleft =
    0; /* 0: systray in the right corner, >0: systray on left of status text */
static const unsigned int systrayspacing = 2; /* systray spacing */
static const int systraypinningfailfirst =
    1; /* 1: if pinning fails, display systray on the first monitor, False:
          display systray on the last monitor*/
static const int showsystray = 1;      /* 0 means no systray */
static const unsigned int gappih = 7; /* horiz inner gap between windows */
static const unsigned int gappiv = 7; /* vert inner gap between windows */
static const unsigned int gappoh =
    5; /* horiz outer gap between windows and screen edge */
static const unsigned int gappov =
    5; /* vert outer gap between windows and screen edge */
static int smartgaps =
    1; /* 1 means no outer gap when there is only one window */

static const int swallowfloating =
    0;                        /* 1 means swallow floating windows by default */
static const int showbar = 1; /* 0 means no bar */
static const int topbar = 1;  /* 0 means bottom bar */
// static const char *fonts[]          = { "JetBrains Mono:size=11",
// "JoyPixels:pixelsize=11:antialias=true:autohint=true"};

static const char *fonts[] = {
    "Iosevka Nerd Font:weight=bold:size=11.5:antialias=true:hinting=true",
    "Ubuntu:weight=bold:size=11:antialias=true:hinting=true",
    "Hack:size=11:antialias=true:autohint=true",
    "fontawesome:size=11:antialias=true:hinting=true",
    "JoyPixels:size=11:antialias=true:autohint=true"};
static const char dmenufont[] = "Iosevka Nerd Font:weight=bold:size=11";
static char normbgcolor[] = "#222222";
static char normbordercolor[] = "#444444";
static char normfgcolor[] = "#bbbbbb";
static char selfgcolor[] = "#eeeeee";
static char selbordercolor[] = "#005577";
static char selbgcolor[] = "#005577";
static char *colors[][3] = {
    /*               fg           bg           border   */
    [SchemeNorm] = {normfgcolor, normbgcolor, normbordercolor},
    [SchemeSel] = {selfgcolor, selbgcolor, selbordercolor},
};

typedef struct {
  const char *name;
  const void *cmd;
} Sp;
const char *spcmd1[] = {"st", "-n", "spterm", "-g", "120x34", NULL};
const char *spcmd2[] = {"st", "-n", "spmusic", "-g", "120x34", "-e", "/home/karna/.ncmpcpp/scripts/ncmpcpp-art", NULL};
// const char *spcmd3[] = {
//    "st", "-n",    "spcal", "-f", "Iosevka Nerd Font:weight=bold:size=14",
//    "-g", "50x20", "-e",    "bc", "-lq",
//    NULL};

const char *spcmd3[] = {"qalculate-gtk", NULL};

const char *spcmd4[] = {
    "st",     "-n",     "spgpt", "-f",   "Iosevka Nerd Font:weight=bold:size=12",
    // "-g",     "120x34", "-e",    "tgpt", "--model", "llama2", "-i",     NULL};
    "-g",     "120x34", "-e",    "ollama", "run", "mistral",     NULL};
const char *spcmd5[] = {
    "st", "-n",     "spnews", "-f",       "Iosevka Nerd Font:weight=bold:size=12",
    "-g", "120x34", "-e",     "newsboat", NULL};

static Sp scratchpads[] = {
    /* name          cmd  */
    {"spterm", spcmd1}, {"spmusic", spcmd2}, {"spcal", spcmd3},
    {"spgpt", spcmd4},  {"spnews", spcmd5},
};

/* tagging */
// static const char *tags[] = { "", "", "", "", "", "",
// "", "", "" };
static const char *tags[] = {"", "", "", "","", "","", "", ""};
// static const char *tags[] = { "1", "2", "3", "4", "5", "6", "7", "8", "9" };

static const Rule rules[] = {
    /* xprop(1):
     *	WM_CLASS(STRING) = instance, class
     *	WM_NAME(STRING) = title
     */
    /* class                instance  title           tags mask  isfloating
       isterminal  noswallow  monitor */
    {"TelegramDesktop", NULL, NULL, 0, 1, 0, 0, -1},
    // {"GitHub Desktop", NULL, NULL, 0, 1 << 3, 0, 0, -1},
    {"Pavucontrol", NULL, NULL, 0, 1, 0, 0, -1},
    {"Blueman-manager", NULL, NULL, 0, 1, 0, 0, -1},
    {"baobab", NULL, NULL, 0, 1, 0, 0, -1},
    {"qBittorrent", NULL, NULL, 1 << 5, 0, 0, 0, -1},
    {"pinentry-qt", NULL, NULL, 0, 1, 0, 0, -1},
    {"Qalculate-gtk", NULL, NULL, 0, 1, 0, 0, -1},
    {"Gnome-disks",   NULL, NULL, 0, 1, 0, 0, -1},
    {"Nm-connection-editor", NULL, NULL, 0, 1, 0, 0, -1},
    {"flameshot", NULL, NULL, 0, 1, 0, 0, -1},
    {"obs", NULL, NULL, 1<<7, 1, 0, 0, -1},
    // {"floorp", NULL, NULL, 1 << 2, 0, 0, -1, -1},
    {"Brave-browser", NULL, NULL, 1 << 1, 0, 0, -1, -1},
    {"Vivaldi-stable", NULL, NULL, 1 << 1, 0, 0, -1, -1},
    // {"Ferdium", NULL, NULL, 1 << 3, 0, 0, -1, -1},
    {"discord", NULL, NULL, 1 << 5, 0, 0, -1, -1},
    {"St", NULL, NULL, 0, 0, 1, 0, -1},
    {"kitty", NULL, NULL, 0, 0, 1, 0, -1},
    {NULL, NULL, "Event Tester", 0, 0, 0, 1, -1}, /* xev */
    { NULL, "spterm",  NULL, SPTAG(0), 1, 1, 0, -1 },
    { NULL, "spmusic", NULL, SPTAG(1), 1, 1, 0, -1 },
    // { NULL, "spcal",   NULL, SPTAG(2), 1, 0, 0, -1 }, // Not a terminal!
    { "Qalculate-gtk", NULL, NULL, SPTAG(2), 1, 0, 0, -1 },
    { NULL, "spgpt",   NULL, SPTAG(3), 1, 1, 0, -1 },
    { NULL, "spnews",  NULL, SPTAG(4), 1, 1, 0, -1 },
};

/* layout(s) */
static const float mfact = 0.55; /* factor of master area size [0.05..0.95] */
static const int nmaster = 1;    /* number of clients in master area */
static const int resizehints =
    1; /* 1 means respect size hints in tiled resizals */

#define FORCE_VSPLIT                                                           \
  1 /* nrowgrid layout: force two clients to always split vertically */
#include "vanitygaps.c"
#include <X11/XF86keysym.h>

static const Layout layouts[] = {
    /* symbol     arrange function */
    {"[]=", tile}, /* first entry is default */
    {"[M]", monocle},
    {"[@]", spiral},
    {"[\\]", dwindle},
    {"H[]", deck},
    {"TTT", bstack},
    {"===", bstackhoriz},
    {"HHH", grid},
    {"###", nrowgrid},
    {"---", horizgrid},
    {":::", gaplessgrid},
    {"|M|", centeredmaster},
    {">M>", centeredfloatingmaster},
    {"><>", NULL}, /* no layout function means floating behavior */
    {NULL, NULL},
};

/* key definitions */
#define MODKEY Mod4Mask
#define TAGKEYS(KEY, TAG)                                                      \
  {MODKEY, KEY, view, {.ui = 1 << TAG}},                                       \
      {MODKEY | ControlMask, KEY, toggleview, {.ui = 1 << TAG}},               \
      {MODKEY | ShiftMask, KEY, tag, {.ui = 1 << TAG}},                        \
      {MODKEY | ControlMask | ShiftMask, KEY, toggletag, {.ui = 1 << TAG}},

/* helper for spawning shell commands in the pre dwm-5.0 fashion */
#define SHCMD(cmd)                                                             \
  {                                                                            \
    .v = (const char *[]) { "/bin/sh", "-c", cmd, NULL }                       \
  }

#define STATUSBAR "dwmblocks"

/* commands */
static char dmenumon[2] =
    "0"; /* component of dmenucmd, manipulated in spawn() */
// static char dmenuprompt[256] = "Search:";
// static const char *dmenucmd[] = {"dmenu_run", "-m", dmenumon, "-fn", dmenufont, "-l", "10", "-p",dmenuprompt,NULL};
static const char *dmenucmd[] = {"rofi", "-show", "drun", "-show-icons", "-theme", "/home/karna/.config/rofi/dt-center.rasi", NULL};
static const char *termcmd[] = {"kitty", NULL};
static const char *emacs[] = {"emacs", NULL};
static const char *browser[] = {"vivaldi", NULL};
static const char *browser1[] = {"qutebrowser", NULL};
static const char *files[] = {"st", "-e", "yazi", NULL};
// static const char *music[] = {"st", "-e", "~/.ncmpcpp/scripts/ncmpcpp-art", NULL};
static const char *files1[] = {"thunar", NULL};
static const char *editor1[] = {"st", "-e", "nvim", NULL};

#include "movestack.c"
static Key keys[] = {
    /* modifier                     key        function        argument */
    {MODKEY, XK_l, setmfact, {.f = +0.05}},
    {MODKEY, XK_k, focusstack, {.i = -1}},
    {MODKEY, XK_j, focusstack, {.i = +1}},
    {MODKEY, XK_Left,  focusstack, {.i = -1} },
    {MODKEY, XK_Right, focusstack, {.i = +1} },
    {MODKEY | ShiftMask, XK_Left,  setmfact, {.f = +0.05} },
    {MODKEY | ShiftMask, XK_Right, setmfact, {.f = +0.05} },
    {MODKEY, XK_h, setmfact, {.f = -0.05}},
    {MODKEY | ShiftMask, XK_j, movestack, {.i = +1}},
    {MODKEY | ShiftMask, XK_k, movestack, {.i = -1}},
    {MODKEY | ShiftMask, XK_Left, movestack, {.i = +1}},
    {MODKEY | ShiftMask, XK_Right, movestack, {.i = -1}},
    {MODKEY | ShiftMask, XK_h, setcfact, {.f = +0.25}},
    {MODKEY | ShiftMask, XK_l, setcfact, {.f = -0.25}},
    {MODKEY | ShiftMask, XK_o, setcfact, {.f = 0.00}},
    {MODKEY, XK_g, togglebar, {0}},
    {MODKEY | ShiftMask, XK_f, zoom, {0}},
    {MODKEY | Mod1Mask, XK_u, incrgaps, {.i = +1}},
    {MODKEY | Mod1Mask | ShiftMask, XK_u, incrgaps, {.i = -1}},
    {MODKEY | Mod1Mask, XK_i, incrigaps, {.i = +1}},
    {MODKEY | Mod1Mask | ShiftMask, XK_i, incrigaps, {.i = -1}},
    {MODKEY | Mod1Mask, XK_o, incrogaps, {.i = +1}},
    {MODKEY | Mod1Mask | ShiftMask, XK_o, incrogaps, {.i = -1}},
    {MODKEY | Mod1Mask, XK_6, incrihgaps, {.i = +1}},
    {MODKEY | Mod1Mask | ShiftMask, XK_6, incrihgaps, {.i = -1}},
    {MODKEY | Mod1Mask, XK_7, incrivgaps, {.i = +1}},
    {MODKEY | Mod1Mask | ShiftMask, XK_7, incrivgaps, {.i = -1}},
    {MODKEY | Mod1Mask, XK_8, incrohgaps, {.i = +1}},
    {MODKEY | Mod1Mask | ShiftMask, XK_8, incrohgaps, {.i = -1}},
    {MODKEY | Mod1Mask, XK_9, incrovgaps, {.i = +1}},
    {MODKEY | Mod1Mask | ShiftMask, XK_9, incrovgaps, {.i = -1}},
    {MODKEY | Mod1Mask, XK_0, togglegaps, {0}},
    {MODKEY | Mod1Mask | ShiftMask, XK_0, defaultgaps, {0}},
    {MODKEY | ShiftMask, XK_d, incnmaster, {.i = -1}},
    {MODKEY, XK_s, incnmaster, {.i = +1}},
    {MODKEY, XK_q, killclient, {0}},
    {MODKEY | Mod1Mask, XK_w, setlayout, {.v = &layouts[0]}},
    {MODKEY, XK_e, setlayout, {.v = &layouts[1]}},
    {MODKEY, XK_r, setlayout, {.v = &layouts[2]}},
    {MODKEY | ShiftMask, XK_r, togglefloating, {0}},
    {MODKEY, XK_f, togglefullscr, {0}},
    {MODKEY, XK_t, setlayout, {0}},
    {MODKEY, XK_d, spawn, {.v = dmenucmd}},
    {MODKEY, XK_Return, spawn, {.v = termcmd}},
    {MODKEY, XK_e, spawn, {.v = emacs}},
    {MODKEY, XK_Tab, view, {0}},
    {MODKEY, XK_0, view, {.ui = ~0}},
    {MODKEY | ShiftMask, XK_0, tag, {.ui = ~0}},
    {MODKEY, XK_comma, focusmon, {.i = -1}},
    {MODKEY, XK_period, focusmon, {.i = +1}},
    {MODKEY | ShiftMask, XK_comma, tagmon, {.i = -1}},
    {MODKEY | ShiftMask, XK_period, tagmon, {.i = +1}},
    {MODKEY, XK_F5, xrdb, {.v = NULL}},
    TAGKEYS(XK_1, 0) TAGKEYS(XK_2, 1) TAGKEYS(XK_3, 2) TAGKEYS(XK_4, 3)
        TAGKEYS(XK_5, 4) TAGKEYS(XK_6, 5) TAGKEYS(XK_7, 6) TAGKEYS(XK_8, 7)
            TAGKEYS(XK_9, 8){MODKEY | ControlMask | ShiftMask, XK_r, quit, {1}},
    {MODKEY | ControlMask | ShiftMask, XK_q, quit, {0}},
    {0, XK_F12, togglescratch, {.ui = 0}},
    {MODKEY | ShiftMask, XK_m, togglescratch, {.ui = 1}},
    {MODKEY, XK_c, togglescratch, {.ui = 2}},
    // {MODKEY | ShiftMask, XK_g, togglescratch, {.ui = 3}},
    {MODKEY | Mod1Mask,  XK_n, togglescratch, {.ui = 4}},
    // {MODKEY, XK_F9, spawn, SHCMD("~/.dwm/volume mute")},
    // {MODKEY, XK_F10, spawn, SHCMD("~/.dwm/volume down")},
    // {MODKEY, XK_F11, spawn, SHCMD("~/.dwm/volume up")},
    {0, XF86XK_AudioMute, spawn, SHCMD("~/.dwm/volume mute")},
    {0, XF86XK_AudioLowerVolume, spawn, SHCMD("~/.dwm/volume down")},
    {0, XF86XK_AudioRaiseVolume, spawn, SHCMD("~/.dwm/volume up")},
    // {MODKEY | ShiftMask, XK_F9, spawn, SHCMD("~/.dwm/volume micmute")},
    {MODKEY , XK_F9, spawn, SHCMD("~/.dwm/volume micmute")},
    {MODKEY | ShiftMask, XK_F11, spawn, SHCMD("brightnessctl s 5%+")},
    {MODKEY | ShiftMask, XK_F10, spawn, SHCMD("brightnessctl s 5%-")},
    // {MODKEY, XK_v, spawn, SHCMD("clipmenu -i -fn JetBrainsMonoNL:10")},
    // {MODKEY, XK_n, spawn, SHCMD("~/.dwm/dmenu_file")},
    {MODKEY | ShiftMask, XK_p, spawn, SHCMD("~/.dwm/scripts/power")},
    {MODKEY | Mod1Mask, XK_p, spawn, SHCMD("~/.config/scripts/rofi-pass-xorg")},
    {MODKEY | ShiftMask, XK_a, spawn, SHCMD("~/.dwm/scripts/script")},
    {MODKEY | ShiftMask, XK_s, spawn, SHCMD("flameshot gui")},
    // {MODKEY | Mod1Mask, XK_l, spawn, SHCMD("betterlockscreen -l -q")},
    {MODKEY | Mod1Mask, XK_l, spawn, SHCMD("xscreensaver-command -lock &")},
    // {MODKEY | ControlMask | ShiftMask, XK_i, spawn,
     // SHCMD("networkmanager_dmenu")},
    {MODKEY, XK_w, spawn, {.v = browser}},
    // {MODKEY | ShiftMask, XK_m, spawn, {.v = music}},
    {MODKEY | ShiftMask, XK_w, spawn, {.v = browser1}},
    {MODKEY , XK_n, spawn, {.v = files}},
    {MODKEY | ShiftMask, XK_n, spawn, {.v = files1}},
    {MODKEY, XK_v, spawn, SHCMD("subl")},
    {MODKEY, XK_a, spawn, {.v = editor1}},
    // {MODKEY, XK_F8, spawn, {.v = (const char *[]){"mpc", "next", NULL}}},
    // {MODKEY, XK_F7, spawn, {.v = (const char *[]){"mpc", "toggle", NULL}}},
    // {MODKEY, XK_F6, spawn, {.v = (const char *[]){"mpc", "prev", NULL}}},
    //{MODKEY | ShiftMask,
     // spawn,
     // {.v = (const char *[]){"mpc", "stop", NULL}}},

    // Music controls with Mod + Alt
    { MODKEY|Mod1Mask,             XK_1,      spawn, SHCMD("mpc toggle") },
    { MODKEY|Mod1Mask,             XK_2,      spawn, SHCMD("mpc prev") },
    { MODKEY|Mod1Mask,             XK_3,      spawn, SHCMD("mpc next") },

    // Music stop with Mod + Shift + Alt
    { MODKEY|Mod1Mask|ShiftMask,   XK_1,      spawn, SHCMD("mpc stop") },

    { 0, XF86XK_AudioPrev,		spawn,		{.v = (const char*[]){ "mpc", "prev", NULL } } },
	  { 0, XF86XK_AudioNext,		spawn,		{.v = (const char*[]){ "mpc",  "next", NULL } } },
	  { 0, XF86XK_AudioPlay,		spawn,		{.v = (const char*[]){ "mpc", "toggle", NULL } } },
    {MODKEY,
     XK_F7,
     spawn,
     {.v = (const char *[]){"mpc", "stop", NULL}}},
};

/* button definitions */
/* click can be ClkTagBar, ClkLtSymbol, ClkStatusText, ClkWinTitle,
 * ClkClientWin, or ClkRootWin */
static Button buttons[] = {
    /* click                event mask      button          function argument */
    {ClkTagBar, MODKEY, Button1, tag, {0}},
    {ClkTagBar, MODKEY, Button3, toggletag, {0}},
    {ClkWinTitle, 0, Button2, zoom, {0}},
    {ClkStatusText, 0, Button2, spawn, {.v = termcmd}},
    {ClkClientWin, MODKEY, Button1, movemouse, {0}},
    {ClkClientWin, MODKEY, Button2, togglefloating, {0}},
    {ClkClientWin, MODKEY, Button1, resizemouse, {0}},
    {ClkTagBar, 0, Button1, view, {0}},
    {ClkTagBar, 0, Button3, toggleview, {0}},
    {ClkTagBar, MODKEY, Button1, tag, {0}},
    {ClkTagBar, MODKEY, Button3, toggletag, {0}},
};
