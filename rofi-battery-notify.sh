#!/bin/bash

# Font Configuration
FONT_NAME="0xProto Nerd Font" # Font family
FONT_SIZE="12"                # Font size

# Size Configuration
NOTIF_WIDTH="23"            # Width in em units
NOTIF_HEIGHT="2.5"          # Height in em units
BORDER_WIDTH="2"            # Border width in px
BORDER_RADIUS="40"          # Border radius in px
NOTIF_POSITION="north east" # Position on screen
Y_OFFSET="10"               # Offset from top/bottom

# Color Configuration
BG_COLOR="#232136"  # Background
CUR_COLOR="#1f1d2e" # Current line/selection
FG_COLOR="#e0def4"  # Foreground
CMT_COLOR="#6e6a86" # Comments
CYA_COLOR="#9ccfd8" # Cyan
GRN_COLOR="#cba6f7" # Green
ORA_COLOR="#ebbcba" # Orange/Warning color
PUR_COLOR="#c4a7e7" # Purple
RED_COLOR="#eb6f92" # Red/Critical color
YEL_COLOR="#f6c177" # Yellow

# Battery Configuration
BATTERY_PATH="/sys/class/power_supply/BAT0"
LOW_BATTERY_THRESHOLD=20
CRITICAL_BATTERY_THRESHOLD=5
BATTERY_ICON="󰁻"

show_notification() {
  local urgency=$1
  local message=$2
  local color_theme="
    * { 
      background: ${BG_COLOR};
      foreground: ${FG_COLOR};
      selected-normal-background: ${CUR_COLOR};
      selected-normal-foreground: ${FG_COLOR};
    }
    window {
      width: ${NOTIF_WIDTH}em;
      height: ${NOTIF_HEIGHT}em;
      border: 0;
      padding: 0;
      margin: 0;
      location: ${NOTIF_POSITION};
      anchor: ${NOTIF_POSITION};
      y-offset: ${Y_OFFSET};
      background-color: @background;
      border-radius: ${BORDER_RADIUS}px;
      border: ${BORDER_WIDTH}px;
      border-color: ${ORA_COLOR};
    }
    mainbox {
      children: [message];
      padding: 0;
      margin: 0;
      border: 0;
      background-color: @background;
    }
    message {
      padding: 0;
      margin: 0;
      border: 0;
      background-color: @background;
    }
    textbox {
      horizontal-align: 0.5;
      vertical-align: 0.5;
      font: \"${FONT_NAME} ${FONT_SIZE}\";
      background-color: @background;
    }"

  if [ "$urgency" = "critical" ]; then
    echo " ${BATTERY_ICON}: Battery ${BATTERY_LEVEL}%" | rofi \
      -e " ${BATTERY_ICON}: Battery ${BATTERY_LEVEL}%" \
      -theme-str "${color_theme}" \
      -theme-str "window { border-color: ${RED_COLOR}; }" \
      -theme-str "textbox { text-color: ${RED_COLOR}; }" \
      -timeout 10
  else
    echo " ${BATTERY_ICON}: Battery ${BATTERY_LEVEL}%" | rofi \
      -e " ${BATTERY_ICON}: Battery ${BATTERY_LEVEL}%" \
      -theme-str "${color_theme}" \
      -theme-str "textbox { text-color: ${ORA_COLOR}; }" \
      -timeout 10
  fi
}

while true; do
  # Get battery percentage
  BATTERY_LEVEL=$(cat "$BATTERY_PATH/capacity")
  # Get charging status
  CHARGING_STATUS=$(cat "$BATTERY_PATH/status")

  # Check if battery is low and not charging
  if [ "$BATTERY_LEVEL" -le "$LOW_BATTERY_THRESHOLD" ] && [ "$CHARGING_STATUS" != "Charging" ]; then
    if [ "$BATTERY_LEVEL" -le "$CRITICAL_BATTERY_THRESHOLD" ]; then
      show_notification "critical" "Battery level: ${BATTERY_LEVEL}%"
      sleep 300
    else
      show_notification "warning" "Battery level: ${BATTERY_LEVEL}%"
      sleep 1200
    fi
  fi

  # Sleep for 60 seconds before checking again
  sleep 60
done
