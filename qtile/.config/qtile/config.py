# Copyright (c) 2010 Aldo Cortesi
# Copyright (c) 2010, 2014 dequis
# Copyright (c) 2012 Randall Ma
# Copyright (c) 2012-2014 Tycho Andersen
# Copyright (c) 2012 Craig Barnes
# Copyright (c) 2013 horsik
# Copyright (c) 2013 Tao Sauvage
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

import os
import subprocess
from libqtile import bar, extension, hook, layout, qtile, widget
from libqtile.config import Click, Drag, Group, Key, KeyChord, Match, Screen, ScratchPad, DropDown
from libqtile.lazy import lazy
import colors

mod = "mod4"              # Sets mod key to SUPER/WINDOWS
myTerm = "kitty"      # My terminal of choice
myBrowser = "brave"       # My browser of choice
myAltBrowser = "qutebrowser"      
myEmacs = "emacsclient -c -a 'emacs' " # The space at the end is IMPORTANT!
myMenu = "rofi -show drun -show-icons -theme ~/.config/rofi/dt-center.rasi"

# Allows you to input a name when adding treetab section.
@lazy.layout.function
def add_treetab_section(layout):
    prompt = qtile.widgets_map["prompt"]
    prompt.start_input("Section name: ", layout.cmd_add_section)

# A function for hide/show all the windows in a group
@lazy.function
def minimize_all(qtile):
    for win in qtile.current_group.windows:
        if hasattr(win, "toggle_minimize"):
            win.toggle_minimize()
           
# A function for toggling between MAX and MONADTALL layouts
@lazy.function
def maximize_by_switching_layout(qtile):
    current_layout_name = qtile.current_group.layout.name
    if current_layout_name == 'monadtall':
        qtile.current_group.layout = 'max'
    elif current_layout_name == 'max':
        qtile.current_group.layout = 'monadtall'

keys = [
    # The essentials
    Key([mod], "Return", lazy.spawn(myTerm), desc="Terminal"),
    Key([mod], "w", lazy.spawn(myBrowser), desc='Web browser'),
    Key([mod, "shift"], "w", lazy.spawn(myAltBrowser), desc='Web browser'),
    Key([mod], "b", lazy.hide_show_bar(position='all'), desc="Toggles the bar to show/hide"),
    Key([mod], "Tab", lazy.next_layout(), desc="Toggle between layouts"),
    Key([mod], "q", lazy.window.kill(), desc="Kill focused window"),
    Key([mod], "l", lazy.spawn("xscreensaver-command -lock"), desc="Lock Screen"),
    Key([mod, "shift"], "r", lazy.reload_config(), desc="Reload the config"),
    Key([mod, "shift"], "q", lazy.shutdown(), desc="Shutdown Qtile"),
    Key([mod, "shift"], "p", lazy.spawn("/home/karna/.config/rofi/powermenu/type-4/powermenu.sh &"), desc="Power menu"),
    Key([mod, "control"], "p", lazy.spawn("sh -c 'pidof gromit-mpx && gromit-mpx -q || gromit-mpx -k none -u none -a -o 1'"), desc="Gromit Mpx"),
    Key([mod, "control"], "F9", lazy.spawn("gromit-mpx -t"), desc="Run gromit-mpx with -t option"),
    Key([mod], "F9", lazy.spawn("gromit-mpx -v"), desc="Run gromit-mpx with -v option"),
    Key([mod, "shift"], "F9", lazy.spawn("gromit-mpx -c"), desc="Run gromit-mpx with -c option"),
    Key([mod, "shift"], "F8", lazy.spawn("gromit-mpx -y"), desc="Run gromit-mpx with -y option"),
    Key([mod], "F8", lazy.spawn("gromit-mpx -z"), desc="Run gromit-mpx with -z option"),
    Key([mod, "shift"], "n", lazy.spawn("thunar"), desc="Launch file manager"),
    Key([mod, "mod1"], "n", lazy.spawn("alacritty -e ranger"), desc="Launch ranger in kitty terminal"),
    Key([mod], "e", lazy.spawn(myEmacs), desc="Launch Emacs client"),
    Key([mod, "shift"], "e", lazy.spawn("/home/karna/.config/rofi/applets/bin/emoji.sh &"), desc="Launch emoji picker"),
    Key([mod, "mod1"], "p", lazy.spawn("/home/karna/.config/scripts/rofi-pass-xorg &"), desc="Launch rofi password manager"),
    Key(["mod1"], "Tab", lazy.spawn("/home/karna/.config/rofi/launchers/type-7/windows.sh &"), desc="Launch rofi window switcher"),
    Key([mod, "mod1"], "a", lazy.spawn("/home/karna/.config/scripts/script &"), desc="Run custom script"),

    Key([mod, "shift"], "s", lazy.spawn("flameshot gui"), desc="Flameshot"),


    # Key([mod], "r", lazy.spawncmd(), desc="Spawn a command using a prompt widget"),
    Key([mod], "d", lazy.spawn(myMenu), desc="Rofi Menu"),
    # Volume Control
    Key([], "XF86AudioRaiseVolume", lazy.spawn("wpctl set-volume @DEFAULT_AUDIO_SINK@ 3%+")),
    Key([], "XF86AudioLowerVolume", lazy.spawn("wpctl set-volume @DEFAULT_AUDIO_SINK@ 3%-")),
    Key([], "XF86AudioMute", lazy.spawn("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")),
    Key([], "XF86AudioMicMute", lazy.spawn("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle")),

    # Additional mic mute toggle with modifier
    Key(["mod4"], "XF86AudioMute", lazy.spawn("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle")),

    # Media Control
    Key([], "XF86AudioPlay", lazy.spawn("mpc toggle")),
    Key([], "XF86AudioPrev", lazy.spawn("mpc prev")),
    Key([], "XF86AudioNext", lazy.spawn("mpc next")),

    Key([mod, "mod1"], "1", lazy.spawn("mpc toggle")),
    Key([mod, "mod1"], "3", lazy.spawn("mpc next")),
    Key([mod, "mod1"], "2", lazy.spawn("mpc prev")),
    Key([mod, "mod1", "shift"], "1", lazy.spawn("mpc stop")),
    
    # Switch between windows
    # Some layouts like 'monadtall' only need to use j/k to move
    # through the stack, but other layouts like 'columns' will
    # require all four directions h/j/k/l to move around.
    Key([mod], "left", lazy.layout.left(), desc="Move focus to left"),
    Key([mod], "right", lazy.layout.right(), desc="Move focus to right"),
    Key([mod], "down", lazy.layout.down(), desc="Move focus down"),
    Key([mod], "up", lazy.layout.up(), desc="Move focus up"),
    Key([mod], "space", lazy.layout.next(), desc="Move window focus to other window"),

    # Move windows between left/right columns or move up/down in current stack.
    # Moving out of range in Columns layout will create new column.
    Key([mod, "shift"], "left",
        lazy.layout.shuffle_left(),
        lazy.layout.move_left().when(layout=["treetab"]),
        desc="Move window to the left/move tab left in treetab"),

    Key([mod, "shift"], "right",
        lazy.layout.shuffle_right(),
        lazy.layout.move_right().when(layout=["treetab"]),
        desc="Move window to the right/move tab right in treetab"),

    Key([mod, "shift"], "down",
        lazy.layout.shuffle_down(),
        lazy.layout.section_down().when(layout=["treetab"]),
        desc="Move window down/move down a section in treetab"
    ),
    Key([mod, "shift"], "up",
        lazy.layout.shuffle_up(),
        lazy.layout.section_up().when(layout=["treetab"]),
        desc="Move window downup/move up a section in treetab"
    ),

    # Toggle between split and unsplit sides of stack.
    # Split = all windows displayed
    # Unsplit = 1 window displayed, like Max layout, but still with
    # multiple stack panes
    Key([mod, "shift"], "space", lazy.layout.toggle_split(), desc="Toggle between split and unsplit sides of stack"),

    # Treetab prompt
    Key([mod, "shift"], "a", add_treetab_section, desc='Prompt to add new section in treetab'),

    # Grow/shrink windows left/right. 
    # This is mainly for the 'monadtall' and 'monadwide' layouts
    # although it does also work in the 'bsp' and 'columns' layouts.
    Key([mod], "equal",
        lazy.layout.grow_left().when(layout=["bsp", "columns"]),
        lazy.layout.grow().when(layout=["monadtall", "monadwide"]),
        desc="Grow window to the left"
    ),
    Key([mod], "minus",
        lazy.layout.grow_right().when(layout=["bsp", "columns"]),
        lazy.layout.shrink().when(layout=["monadtall", "monadwide"]),
        desc="Grow window to the left"
    ),

    # Grow windows up, down, left, right.  Only works in certain layouts.
    # Works in 'bsp' and 'columns' layout.
    Key([mod, "control"], "h", lazy.layout.grow_left(), desc="Grow window to the left"),
    Key([mod, "control"], "l", lazy.layout.grow_right(), desc="Grow window to the right"),
    Key([mod, "control"], "j", lazy.layout.grow_down(), desc="Grow window down"),
    Key([mod, "control"], "k", lazy.layout.grow_up(), desc="Grow window up"),
    Key([mod], "n", lazy.layout.normalize(), desc="Reset all window sizes"),
    Key([mod], "m", lazy.layout.maximize(), desc='Toggle between min and max sizes'),
    Key([mod], "t", lazy.window.toggle_floating(), desc='toggle floating'),
    Key([mod], "f", maximize_by_switching_layout(), lazy.window.toggle_fullscreen(), desc='toggle fullscreen'),
    Key([mod, "mod1"], "m", minimize_all(), desc="Toggle hide/show all windows on current group"),

    # Switch focus of monitors
    # Key([mod], "period", lazy.next_screen(), desc='Move focus to next monitor'),
    # Key([mod], "comma", lazy.prev_screen(), desc='Move focus to prev monitor'),
    
    # Emacs programs launched using the key chord SUPER+e followed by 'key'
    # KeyChord([mod],"e", [
    #     Key([], "e", lazy.spawn(myEmacs), desc='Emacs Dashboard'),
    #     Key([], "a", lazy.spawn(myEmacs + "--eval '(emms-play-directory-tree \"~/Music/\")'"), desc='Emacs EMMS'),
    #     Key([], "b", lazy.spawn(myEmacs + "--eval '(ibuffer)'"), desc='Emacs Ibuffer'),
    #     Key([], "d", lazy.spawn(myEmacs + "--eval '(dired nil)'"), desc='Emacs Dired'),
    #     Key([], "i", lazy.spawn(myEmacs + "--eval '(erc)'"), desc='Emacs ERC'),
    #     Key([], "s", lazy.spawn(myEmacs + "--eval '(eshell)'"), desc='Emacs Eshell'),
    #     Key([], "v", lazy.spawn(myEmacs + "--eval '(vterm)'"), desc='Emacs Vterm'),
    #     Key([], "w", lazy.spawn(myEmacs + "--eval '(eww \"distro.tube\")'"), desc='Emacs EWW'),
    #     Key([], "F4", lazy.spawn("killall emacs"),
    #                   lazy.spawn("/usr/bin/emacs --daemon"),
    #                   desc='Kill/restart the Emacs daemon')
    # ]),
]

groups = [
    ScratchPad("scratchpad", [
        DropDown("term", "kitty", opacity=0.8),
        DropDown("ncmpcpp", "alacritty -e ncmpcpp",
                 x=0.22, y=0.17, width=0.55, height=0.65, opacity=0.9,
                 on_focus_lost_hide=True),
    DropDown(
        "chess",
        "/opt/brave-bin/brave --user-data-dir=/home/karna/.config/brave-chess --profile-directory=Default --app-id=kinpkbniadkppecjaginbegiljofpcfc --disable-session-crashed-bubble --disable-infobars",
        x=0.17, y=0.09, width=0.65, height=0.75, opacity=0.9,
        warp_pointer=False,
        on_focus_lost_hide=True
    ),
    ]),

    Group("1", label="", layout="monadtall"),
    Group("2", label="", layout="monadtall"),
    Group("3", label="", layout="monadtall"),
    Group("4", label="", layout="monadtall"),
    Group("5", label="", layout="monadtall"),
    Group("6", label="", layout="monadtall"),
    Group("7", label="𝦝", layout="monadtall"),
    Group("8", label="", layout="monadtall"),
    Group("9", label="", layout="monadtall"),
    Group("0", label="⛨", layout="monadtall"),
]
 
keys.extend([
    # Keybindings for switching to groups
    Key(["mod4"], "1", lazy.group["1"].toscreen(), desc="Switch to group 1"),
    Key(["mod4"], "2", lazy.group["2"].toscreen(), desc="Switch to group 2"),
    Key(["mod4"], "3", lazy.group["3"].toscreen(), desc="Switch to group 3"),
    Key(["mod4"], "4", lazy.group["4"].toscreen(), desc="Switch to group 4"),
    Key(["mod4"], "5", lazy.group["5"].toscreen(), desc="Switch to group 5"),
    Key(["mod4"], "6", lazy.group["6"].toscreen(), desc="Switch to group 6"),
    Key(["mod4"], "7", lazy.group["7"].toscreen(), desc="Switch to group 7"),
    Key(["mod4"], "8", lazy.group["8"].toscreen(), desc="Switch to group 8"),
    Key(["mod4"], "9", lazy.group["9"].toscreen(), desc="Switch to group 9"),
    Key(["mod4"], "0", lazy.group["0"].toscreen(), desc="Switch to group 0"),

    # Keybindings for moving windows to groups
    Key(["mod4", "shift"], "1", lazy.window.togroup("1", switch_group=False), desc="Move window to group 1"),
    Key(["mod4", "shift"], "2", lazy.window.togroup("2", switch_group=False), desc="Move window to group 2"),
    Key(["mod4", "shift"], "3", lazy.window.togroup("3", switch_group=False), desc="Move window to group 3"),
    Key(["mod4", "shift"], "4", lazy.window.togroup("4", switch_group=False), desc="Move window to group 4"),
    Key(["mod4", "shift"], "5", lazy.window.togroup("5", switch_group=False), desc="Move window to group 5"),
    Key(["mod4", "shift"], "6", lazy.window.togroup("6", switch_group=False), desc="Move window to group 6"),
    Key(["mod4", "shift"], "7", lazy.window.togroup("7", switch_group=False), desc="Move window to group 7"),
    Key(["mod4", "shift"], "8", lazy.window.togroup("8", switch_group=False), desc="Move window to group 8"),
    Key(["mod4", "shift"], "9", lazy.window.togroup("9", switch_group=False), desc="Move window to group 9"),
    Key(["mod4", "shift"], "0", lazy.window.togroup("0", switch_group=False), desc="Move window to group 0"),

    # ScratchPad Keybindings
    Key([], "F12", lazy.group["scratchpad"].dropdown_toggle("term"), desc="Toggle ScratchPad terminal"),
    Key(["mod4", "shift"], "m", lazy.group["scratchpad"].dropdown_toggle("ncmpcpp"), desc="Toggle Ncmpcpp"),
    Key([], "F11", lazy.group["scratchpad"].dropdown_toggle("chess"), desc="Toggle Chess"),
])

# colors = colors.DoomOne
colors = colors.WalColors

layout_theme = {"border_width": 3,
                "margin": 8,
                "border_focus": colors[8],
                "border_normal": colors[0]
                }

layouts = [
    layout.MonadTall(**layout_theme),
    layout.MonadWide(**layout_theme),
    layout.Tile(**layout_theme),
    layout.Max(**layout_theme),
    #layout.Bsp(**layout_theme),
    #layout.Floating(**layout_theme)
    #layout.RatioTile(**layout_theme),
    #layout.VerticalTile(**layout_theme),
    #layout.Matrix(**layout_theme),
    #layout.Stack(**layout_theme, num_stacks=2),
    #layout.Columns(**layout_theme),
    #layout.TreeTab(
    #     font = "JetBrains Mono Nerd Font Bold",
    #     fontsize = 11,
    #     border_width = 0,
    #     bg_color = colors[0],
    #     active_bg = colors[8],
    #     active_fg = colors[2],
    #     inactive_bg = colors[1],
    #     inactive_fg = colors[0],
    #     padding_left = 8,
    #     padding_x = 8,
    #     padding_y = 6,
    #     sections = ["ONE", "TWO", "THREE"],
    #     section_fontsize = 10,
    #     section_fg = colors[7],
    #     section_top = 15,
    #     section_bottom = 15,
    #     level_shift = 8,
    #     vspace = 3,
    #     panel_width = 240
    #     ),
    #layout.Zoomy(**layout_theme),
]

widget_defaults = dict(
    font="JetBrains Mono Nerd Font Bold",
    fontsize=12,
    padding=0,
    background=colors[0]
)

extension_defaults = widget_defaults.copy()

def init_widgets_list():
    widgets_list = [
        widget.Spacer(length=12),
        widget.Image(
            filename="~/.config/qtile/icons/infinity-icon.png",
            scale="False",
            mouse_callbacks={'Button2': lambda: qtile.cmd_spawn(myTerm)},
        ),
        widget.Prompt(
            font="JetBrains Mono Nerd Font Bold",
            fontsize=14,
            foreground=colors[1]
        ),
        widget.GroupBox(
            fontsize=12,
            margin_y=5,
            margin_x=8,
            padding_y=0,
            padding_x=1,
            borderwidth=3,
            active=colors[8],
            inactive=colors[9],
            rounded=False,
            # highlight_color=colors[2],
            highlight_method="line",
            this_current_screen_border=colors[7],
            this_screen_border=colors[4],
            other_current_screen_border=colors[7],
            other_screen_border=colors[4],
        ),
        widget.TextBox(
            text='|',
            font="JetBrains Mono Nerd Font Bold",
            foreground=colors[9],
            padding=2,
            fontsize=14
        ),
        # widget.CurrentLayout(
        #     foreground=colors[1],
        #     padding=5
        # ),
        widget.CurrentLayoutIcon(
            custom_icon_paths=[os.path.expanduser("~/.config/qtile/icons")],
            foreground=colors[1],
            padding=5,
            scale=0.50,
        ),
        widget.WindowCount(
            foreground=colors[1],
        ),
        widget.TextBox(
            text='|',
            font="JetBrains Mono Nerd Font Bold",
            foreground=colors[9],
            padding=2,
            fontsize=14
        ),
        widget.WindowName(
            foreground=colors[6],
            padding=4,
            max_chars=40
        ),
    
        widget.Mpd2(
            status_format='{play_status} [{repeat}{random}{single}] {title} - {artist}',
            idle_format='{play_status} {idle_message}',
            idle_message='Nil',
            idletimeout=2,
            undefined_value='N/A',
            padding=4,
            foreground='5E60CE',
          no_connection="🛑",
            play_states={'pause': '⏸', 'play': '▶', 'stop': '■'},
            prepare_status={'repeat': 'r', 'random': 'z', 'single': '1', 'consume': 'c', 'updating_db': 'U'},
            mouse_buttons={1: 'toggle', 3: 'stop', 4: 'previous', 5: 'next'},
            host='localhost',
            port=6600,
            fontsize=12,
            max_chars=40,
            update_interval=1
        ),

        widget.GenPollText(
            update_interval=600,
            func=lambda: subprocess.check_output("printf $(uname -r)", shell=True, text=True),
            foreground=colors[3],
            padding=6,
            fmt='❤ {}',
            mouse_callbacks={
                'Button2': lambda: qtile.cmd_spawn("kitty -e sudo pacman -Syyu")  # Right-click to open pavucontrol
            },
        ),
        widget.CPU(
            format='󰘚 {load_percent}%',
            foreground=colors[4],
            padding=6,
        ),
        widget.Memory(
            foreground=colors[8],
            padding=6,
            mouse_callbacks={'Button2': lambda: qtile.cmd_spawn(myTerm + ' -e btop')},
            # format='{MemUsed: .0f}{mm}/{MemTotal:.0f}{mm}({SwapUsed:.0f}{ms})',
            format='{MemUsed: .0f}{mm}',
            measure_mem='M',
            measure_swap='M',
            fmt='󰍛{}',
        ),
        # widget.DF(
        #     update_interval=60,
        #     foreground=colors[5],
        #     padding=6,
        #     mouse_callbacks={'Button1': lambda: qtile.cmd_spawn(myTerm + ' -e df')},
        #     partition='/',
        #     format='{uf}{m} free',
        #     fmt='🖴  Disk: {}',
        #     visible_on_warn=False,
        # ),

        widget.PulseVolume(
            foreground=colors[7],
            padding=6,
            emoji=False,
            emoji_list=['󰖁 ', '󰕿 ', '󰖀 ', '󰕾 '],
            fmt='🕫 {}',
            step=3,  # Scroll step for volume
            mouse_callbacks={
                'Button3': lambda: qtile.cmd_spawn("pavucontrol"),
                'Button2': lambda: qtile.cmd_spawn("blueman-manager")
            },
        ),
        # Brightness Widget with Scroll Support
        widget.Backlight(
            foreground=colors[3],
            backlight_name="intel_backlight",  # Change this if your device uses a different backlight name
            padding=6,
            fmt='☀ {}',
            step=5,  # Scroll step for brightness
        ),
        # widget.KeyboardLayout(
        #     foreground=colors[4],
        #     padding=6,
        #     fmt='⌨  Kbd: {}',
        # ),

        widget.Battery(
            format='{char} {percent:2.0%} ({hour:d}:{min:02d})',
            full_short_text=' 100%',
            padding=6,
            foreground=colors[4],
            full_char='',
            charge_char='',
            discharge_char='',
            empty_char='',
            notify_below=15,
            low_percentage=0.2,
            low_foreground='FF0000',
            show_short_text=True,
            update_interval=2,
            mouse_callbacks={
                'Button2': lambda: qtile.cmd_spawn("xfce4-power-manager-settings")
            }
        ),

        # widget.Bluetooth(
        #     default_text=' {connected_devices}',
        #     foreground=colors[7],
        #     adapter_format='Adapter: {name} [{symbol_powered}]',
        #     device_format='{name} {symbol_connected}',
        #     symbol_connected='',
        #     symbol_paired='',
        #     symbol_powered=('', ''),
        #     device_battery_format=' ({battery}%)',
        #     default_show_battery=True,
        #     hide_unnamed_devices=True,
        #     update_interval=2,
        #     scroll=True,
        #     default_timeout=2,
        #     mouse_callbacks={
        #         'Button2': lambda: qtile.cmd_spawn("blueman-manager")
        #     }
        # ),
        widget.Clock(
            foreground=colors[8],
            padding=6,
            format="⏱ %a, %b %d - %H:%M",
        ),
        # widget.TextBox(
        #     text="⏻",
        #     foreground=colors[7],
        #     font="Font Awesome 6 Free Solid",
        #     fontsize=16,
        #     padding=6,
        #     mouse_callbacks={'Button1': lambda: qtile.cmd_spawn("/home/karna/.config/rofi/powermenu/type-4/powermenu.sh &")},
        # ),
        widget.Systray(padding=3, icon_size=15),
        widget.Spacer(length=8),
    ]
    return widgets_list

def init_widgets_screen1():
    widgets_screen1 = init_widgets_list()
    return widgets_screen1 

# All other monitors' bars will display everything but widgets 22 (systray) and 23 (spacer).
# def init_widgets_screen2():
#     widgets_screen2 = init_widgets_list()
#     del widgets_screen2[15:16]
#     return widgets_screen2

# For adding transparency to your bar, add (background="#00000000") to the "Screen" line(s)
# For ex: Screen(top=bar.Bar(widgets=init_widgets_screen2(), background="#00000000", size=24)),

def init_screens():
    return [Screen(top=bar.Bar(widgets=init_widgets_screen1(), margin=[8, 12, 0, 12], size=28)),
            # Screen(top=bar.Bar(widgets=init_widgets_screen2(), margin=[8, 12, 0, 12], size=28)),
            # Screen(top=bar.Bar(widgets=init_widgets_screen2(), margin=[8, 12, 0, 12], size=28))
            ]

if __name__ in ["config", "__main__"]:
    screens = init_screens()
    widgets_list = init_widgets_list()
    widgets_screen1 = init_widgets_screen1()
    # widgets_screen2 = init_widgets_screen2()

def window_to_prev_group(qtile):
    if qtile.currentWindow is not None:
        i = qtile.groups.index(qtile.currentGroup)
        qtile.currentWindow.togroup(qtile.groups[i - 1].name)

def window_to_next_group(qtile):
    if qtile.currentWindow is not None:
        i = qtile.groups.index(qtile.currentGroup)
        qtile.currentWindow.togroup(qtile.groups[i + 1].name)

def window_to_previous_screen(qtile):
    i = qtile.screens.index(qtile.current_screen)
    if i != 0:
        group = qtile.screens[i - 1].group.name
        qtile.current_window.togroup(group)

def window_to_next_screen(qtile):
    i = qtile.screens.index(qtile.current_screen)
    if i + 1 != len(qtile.screens):
        group = qtile.screens[i + 1].group.name
        qtile.current_window.togroup(group)

def switch_screens(qtile):
    i = qtile.screens.index(qtile.current_screen)
    group = qtile.screens[i - 1].group
    qtile.current_screen.set_group(group)

mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(), start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]

dgroups_key_binder = None
dgroups_app_rules = []  # type: list
follow_mouse_focus = True
bring_front_click = False
cursor_warp = False
floating_layout = layout.Floating(
    border_focus=colors[8],
    border_width=2,
    float_rules=[
        # Run the utility of `xprop` to see the wm class and name of an X client.
        *layout.Floating.default_float_rules,
        Match(wm_class="confirmreset"),   # gitk
        Match(wm_class="dialog"),         # dialog boxes
        Match(wm_class="download"),       # downloads
        Match(wm_class="error"),          # error msgs
        Match(wm_class="file_progress"),  # file progress boxes
        Match(wm_class='kdenlive'),       # kdenlive
        Match(wm_class="makebranch"),     # gitk
        Match(wm_class="maketag"),        # gitk
        Match(wm_class="notification"),   # notifications
        Match(wm_class='pinentry-gtk-2'), # GPG key password entry
        Match(wm_class="ssh-askpass"),    # ssh-askpass
        Match(wm_class="toolbar"),        # toolbars
        Match(wm_class="Yad"),            # yad boxes
        Match(title="branchdialog"),      # gitk
        Match(title='Confirmation'),      # tastyworks exit box
        Match(title='Qalculate!'),        # qalculate-gtk
        Match(title="pinentry"),          # GPG key password entry
        Match(title="tastycharts"),       # tastytrade pop-out charts
        Match(title="tastytrade"),        # tastytrade pop-out side gutter
        Match(title="tastytrade - Portfolio Report"), # tastytrade pop-out allocation
        Match(wm_class="tasty.javafx.launcher.LauncherFxApp"), # tastytrade settings
    ]
)
auto_fullscreen = True
focus_on_window_activation = "smart"
reconfigure_screens = True

# If things like steam games want to auto-minimize themselves when losing
# focus, should we respect this or not?
auto_minimize = True

# When using the Wayland backend, this can be used to configure input devices.
wl_input_rules = None

@hook.subscribe.startup_once
def start_once():
    home = os.path.expanduser('~')
    subprocess.call([home + '/.config/qtile/autostart.sh'])

# XXX: Gasp! We're lying here. In fact, nobody really uses or cares about this
# string besides java UI toolkits; you can see several discussions on the
# mailing lists, GitHub issues, and other WM documentation that suggest setting
# this string if your java app doesn't work correctly. We may as well just lie
# and say that we're a working one by default.
#
# We choose LG3D to maximize irony: it is a 3D non-reparenting WM written in
# java that happens to be on java's whitelist.
wmname = "LG3D"
