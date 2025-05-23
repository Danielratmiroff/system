from types import FunctionType
from libqtile.widget import (
    GroupBox,
    WindowName,
    TextBox,
    NetGraph,
    CPU,
    Memory,
    MemoryGraph,
    KeyboardLayout,
    GenPollText,
    Net,
    ThermalSensor,
    ThermalZone,
    Volume,
    Clock,
    Systray,
    QuickExit,
    CurrentLayoutIcon
)
from libqtile import hook
from libqtile.utils import guess_terminal
from libqtile.lazy import lazy
from libqtile.config import Click, Drag, Group, Key, Match, Screen
from libqtile import bar, layout, qtile, widget
import subprocess
import os
import sys
import psutil
sys.path.append(
    '/home/daniel/.local/qtile-venv/lib/python3.12.3/site-packages')


# mod = "mod4" # OS key
mod = "mod1"  # Alt key
# mod = "space"
terminal = guess_terminal()
main_screen_groups = "12345"


@hook.subscribe.client_new
def move_starting_windows(window):
    if window.name == "cursor":
        window.togroup("3", switch_group=False)
    if window.name == "wezterm":
        window.togroup("2", switch_group=False)


@hook.subscribe.startup_once
def autostart():
    home = os.path.expanduser('~/.config/qtile/autostart.sh')
    subprocess.Popen([home])
    # move_starting_windows


colors = {
    "background": "#282a36",      # Base background color
    "foreground": "#f8f8f2",      # Base foreground/text color
    "accent": "#bd93f9",          # Accent color for highlights and focus
    "gray": "#6272a4",            # Gray color for inactive elements
    "cyan": "#8be9fd",            # Cyan color for prompts and informational text
    "red": "#ff5555",             # Red color for alerts and important indicators
    "yellow": "#f1fa8c",          # Yellow color for warnings and battery status
    "green": "#50fa7b",           # Green color for clocks and status indicators
    # Blue color (optional, can be used similarly to cyan)
    "blue": "#8be9fd",
    "inactive": "#5c5c5c",
    "active": "#8be9fd",
    "urgent": "#ff5555",
    "highlight": "#ff79c6",

}

keys = [

    # Standard navigation
    Key([mod], "h", lazy.layout.left()),
    Key([mod], "l", lazy.layout.right()),
    Key([mod], "j", lazy.layout.down()),
    Key([mod], "k", lazy.layout.up()),

    # Move screens
    Key([mod, "shift"], "h", lazy.layout.swap_left()),
    Key([mod, "shift"], "l", lazy.layout.swap_right()),
    Key([mod, "shift"], "j", lazy.layout.shuffle_down()),
    Key([mod, "shift"], "k", lazy.layout.shuffle_up()),

    # Resize
    Key([mod], "Up", lazy.layout.grow()),
    Key([mod], "Down", lazy.layout.shrink()),
    Key([mod], "n", lazy.layout.reset()),
    Key([mod, "shift"], "n", lazy.layout.normalize()),
    Key([mod], "o", lazy.layout.maximize()),
    Key([mod, "shift"], "s", lazy.layout.toggle_auto_maximize()),
    Key([mod, "shift"], "backspace", lazy.layout.flip()),

    # Softwares
    # Key([mod], "o", lazy.spawn('obsidian'), desc="Launch obsidian"),
    Key([mod], "t", lazy.spawn('wezterm'), desc="Launch terminal"),
    Key([mod], "s", lazy.spawn('slack'), desc="Launch terminal"),
    # Key([mod], "b", lazy.spawn('zen-browser'), desc="Launch browser"),
    Key([mod], "b", lazy.spawn('brave-browser --new-window'), desc="Launch browser"),
    Key([mod], "a", lazy.spawn('rofi -show drun'), desc="Launch rofi drun"),
    Key([mod], "TAB", lazy.spawn('rofi -show window'), desc="Launch rofi window"),
    Key([mod], "c", lazy.spawn('cursor'), desc="Launch cursor"),
    Key([mod], "Print", lazy.spawn(
        'Flameshot gui'), desc="Launch screenshot"),
    Key([mod, "control"], "l", lazy.spawn(
        'betterlockscreen -l --off 30'), desc="Lock screen"),

    # Toggle between different layouts as defined below
    # Key([mod], "Tab", lazy.next_layout(), desc="Toggle between layouts"),
    Key([mod], "q", lazy.window.kill(), desc="Kill focused window"),
    # Key([mod], "w", lazy.to_screen(0)),
    # Key([mod], "e", lazy.to_screen(1)),
    Key(
        [mod],
        "f",
        lazy.window.toggle_fullscreen(),
        desc="Toggle fullscreen on the focused window",
    ),
    # Key([mod], "t", lazy.window.toggle_floating(),
    # desc="Toggle floating on the focused window"),
    Key([mod, "control"], "r", lazy.reload_config(), desc="Reload the config"),
    Key([mod, "control"], "q", lazy.shutdown(), desc="Shutdown Qtile"),
    # Key([mod], "r", lazy.spawncmd(), desc="Spawn a command using a prompt widget"),
]

layout_theme = dict(
    margin="15",
    border_width=3
)

layouts = [
    layout.Max(),
    layout.MonadTall(
        border_focus=colors["accent"],
        #        ratio=layout_theme["ratio"],
        #    margin=layout_theme["margin"],
        border_width=layout_theme["border_width"]
    ),
    layout.MonadThreeCol(
        border_focus=colors["accent"],
        #        ratio=layout_theme["ratio"],
        #    margin=layout_theme["margin"],
        border_width=layout_theme["border_width"]
    ),
]

# Main screen = 1
# Secondary screen = 0
groups = [
    Group("1",
          #   label="󰭹",  # Chat Icon
          #   label="󰅱",  # Code Icon
          label="",  # Linux
          matches=[
          #Match(wm_class="wezterm"),
          ],
          layout="monadtall",
          screen_affinity=1,
          ),
    Group("2",
          #   label="", # Terminal
          #   label="",  # Linux
          label="󰅱",  # Code Icon
          #   matches=[Match(wm_class="org.wezfurlong.wezterm")],
          layout="monadtall",
          screen_affinity=1
          ),
    Group("3",
          label="󰅱",  # Code Icon
          #   matches=[Match(wm_class="cursor")],
          screen_affinity=1,
          layout="monadtall",
          ),
    Group("4",
          #   label="󰀲",  # Android Icon
          label="󰅱",  # Code Icon
          matches=[
              Match(wm_class="android_studio")
          ],
          layout="monadtall",
          screen_affinity=1,
          ),
    Group("5",
          #   label="󰅱",  # Code Icon
          label="󰭹",  # Chat Icon
          matches=[
              Match(wm_class="obsidian"),
              Match(wm_class="slack"),
          ],
          screen_affinity=1,
          layout="monadthreecol",
          ),
    Group("6",
          label="",  # Chrome Icon
          matches=[Match(wm_class="brave-browser")],
          layout="monadtall",
          screen_affinity=0
          ),
    Group("7",
          label="",  # Firefox Icon
          screen_affinity=0,
          layout="max",
          ),
]


def goToGroup(qtile, name: str):
    # 1-4 on screen 1 (main screen)
    # 5-9 on screen 0 (secondary screen)
    if name in main_screen_groups:
        qtile.focus_screen(1)
        qtile.groups_map[name].toscreen()
    else:
        qtile.focus_screen(0)
        qtile.groups_map[name].toscreen()


def goToGroupAndMoveWindow(qtile, name: str):
    # 1-4 on screen 1 (main screen)
    # 5-9 on screen 0 (secondary screen)
    if name in main_screen_groups:
        qtile.current_window.togroup(name, switch_group=False)
        qtile.focus_screen(1)
        qtile.groups_map[name].toscreen()
    else:
        qtile.current_window.togroup(name, switch_group=False)
        qtile.focus_screen(0)
        qtile.groups_map[name].toscreen()


for i in groups:
    keys.extend([
        # Switch to group
        Key([mod], i.name, lazy.function(goToGroup, i.name),
            desc=f"Switch to group {i.name}"),
        # Move focused window to group
        Key([mod, "shift"], i.name, lazy.function(goToGroupAndMoveWindow, i.name),
            desc=f"Move window to group {i.name}"),
    ])

widget_defaults = dict(
    font="FiraCode Nerd Font",
    fontsize=12,
    padding=10,
    background=colors["background"],
    foreground=colors["foreground"],
)

extension_defaults = widget_defaults.copy()

# Function to check VPN status


def vpn_status():
    for proc in psutil.process_iter(['name']):
        if proc.info['name'] == 'openvpn':
            return colors["highlight"]
    return colors["inactive"]


screens = [
    Screen(),
    Screen(
        top=bar.Bar(
            [
                # Arbeitsflächen (Gruppen)
                GroupBox(
                    fontsize=14,
                    active=colors["active"],
                    inactive=colors["inactive"],
                    highlight_method='line',
                    padding_y=5,
                    padding_x=widget_defaults["padding"],
                    margin_x=5,
                    this_current_screen_border=colors["highlight"],
                    # hide_unused=True,
                ),

                widget.Spacer(length=bar.STRETCH),
                # Uhrzeit und Datum
                Clock(
                    font=widget_defaults["font"],
                    format='%b %d  %I:%M %p',
                    fontsize=14,
                    # foreground=colors["highlight"]
                ),
                # Systray für System-Icons
                Systray(
                    font=widget_defaults["font"],
                    padding=5,
                ),
                # Fenstername
                # WindowName(
                #     font=widget_defaults["font"],
                #     format='- {name}',
                #     fontsize=14,
                #     foreground=colors["foreground"]
                # ),
                widget.Spacer(length=bar.STRETCH),

                TextBox(
                    font=widget_defaults["font"],
                    text="",  # Temperature-Icon
                    padding=0,
                    foreground=colors["highlight"],
                ),
                ThermalZone(
                    font=widget_defaults["font"],
                    high=45,
                    crit=60
                ),

                # CPU-Auslastung
                TextBox(
                    font=widget_defaults["font"],
                    text="️",  # Symbol für CPU
                    fontsize=14,
                    padding=10,
                    foreground=colors["highlight"]
                ),
                CPU(format="{load_percent}%", padding=5),

                # Speicher
                TextBox(
                    font=widget_defaults["font"],
                    text="",  # Symbol für Speicher
                    padding=widget_defaults["padding"],
                    fontsize=14,
                    foreground=colors["highlight"]
                ),
                Memory(
                    font=widget_defaults["font"],
                    measure_mem="G",
                    format='{MemUsed:.0f}G / {MemTotal:.0f}G ({MemPercent:.0f}%)',
                    padding=5),

                # Netzwerkinformationen für Wi-Fi
                TextBox(
                    font=widget_defaults["font"],
                    text="",  # Wi-Fi icon
                    padding=10,
                    foreground=colors["highlight"]
                ),
                NetGraph(
                    interface="wlp0s20f3",
                    font=widget_defaults["font"],
                    type="linefill",
                    margin_y=5,
                    # format='{down} ↓↑ {up}',
                    padding=widget_defaults["padding"],
                    foreground=colors["foreground"]),

                # Ethernet
                TextBox(
                    font=widget_defaults["font"],
                    # text="󱘖", # Kabel icon
                    text="󰣶",  # Net icon
                    fontsize=14,
                    padding=widget_defaults["padding"],
                    foreground=colors["highlight"]
                ),
                NetGraph(
                    font=widget_defaults["font"],
                    interface="eno1",
                    margin_y=5,
                    #  format='{down} ↓↑ {up}',
                    padding=widget_defaults["padding"],
                    # foreground=colors["highlight"],
                    # graph_color=colors["highlight"]
                ),

                # Lautstärkeanzeige
                TextBox(
                    font=widget_defaults["font"],
                    text="",  # Lautstärke-Icon
                    padding=10,
                    foreground=colors["highlight"],
                ),
                Volume(
                    font=widget_defaults["font"],
                    fmt='Vol: {}',
                    padding=5
                ),

                KeyboardLayout(
                    font=widget_defaults["font"],
                    display_map={'us': '🇬🇧', 'de': '🇩🇪'},
                ),

                GenPollText(
                    func=lambda: f'<span foreground="{vpn_status()}">󰖂</span>',
                    update_interval=5,
                    font=widget_defaults["font"],
                    fontsize=14,
                ),

                QuickExit(
                    font=widget_defaults["font"],
                    foreground=colors["highlight"],
                )
            ],
            30,  # Höhe der Bar
            # background=colors["background"],
            opacity=0.9,  # Transparenz der Bar
            wallpaper="/home/daniel/Downloads/wall.jpg",
            wallpaper_mode='stretch',
        ),
    ),
]


# Drag floating layouts.
mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(),
         start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating(),
         start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]

dgroups_key_binder = None
dgroups_app_rules = []  # type: list

Rollow_mouse_focus = True
bring_front_click = False
floats_kept_above = True
cursor_warp = False
follow_mouse_focus = True

auto_fullscreen = True
focus_on_window_activation = "smart"
reconfigure_screens = False

# If things like steam games want to auto-minimize themselves when losing
# focus, should we respect this or not?
auto_minimize = True
