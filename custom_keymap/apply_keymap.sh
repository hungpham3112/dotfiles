#!/bin/bash

CUSTOM_KEYMAP="$HOME/.config/custom_keymap/custom_keymap.xkb"
XMODMAP_SETTING="$HOME/.config/.Xmodmap"

# Wait for the X server to be fully started
sleep 5

# Apply custom keymap
xkbcomp -w 0 "$CUSTOM_KEYMAP" "$DISPLAY"

# Apply xmodmap settings
xmodmap "$XMODMAP_SETTING"
