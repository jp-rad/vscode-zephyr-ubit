#!/bin/bash

set -e  # Exit immediately if any command fails

MODE="$1"                 # Operation mode: build, flash, debugserver
BOARD_ARG="$2"            # Target board: bbc_microbit | bbc_microbit_v2 | auto
WORK_DIR="${3:-$(pwd)}"   # optional project dir

USB_IDS=("0d28:0204")     # USB vendor:product ID for micro:bit detection
TARGET_V1="nrf51"         # nrf51822 - micro:bit v1
TARGET_V2="nrf52"         # nrf52833 - micro:bit v2

# Validate mode
if [[ "$MODE" != "build" && "$MODE" != "flash" && "$MODE" != "debugserver" ]]; then
  echo "❌ Invalid mode: $MODE"
  echo "Usage: $0 [build|flash|debugserver] [bbc_microbit|bbc_microbit_v2|auto] [optional project dir]"
  exit 1
fi

# Validate board
if [[ "$BOARD_ARG" != "bbc_microbit" && "$BOARD_ARG" != "bbc_microbit_v2" && "$BOARD_ARG" != "auto" ]]; then
  echo "❌ Invalid BOARD value: $BOARD_ARG"
  echo "Usage: $0 [build|flash|debugserver] [bbc_microbit|bbc_microbit_v2|auto] [optional project dir]"
  exit 1
fi

# Validate and change to working directory
cd $WORK_DIR || { echo "❌ Failed to change directory to $WORK_DIR"; exit 1; }

# Step 1: Detect micro:bit USB device and set permission
if [[ "$BOARD_ARG" == "auto" || "$MODE" == "debugserver" ]]; then
  while IFS= read -r line; do
    for id in "${USB_IDS[@]}"; do
      if [[ "$line" == *"$id"* ]]; then
        BUS=$(echo "$line" | awk '{print $2}')
        DEV=$(echo "$line" | awk '{gsub(":", "", $4); print $4}')
        DEV_PATH="/dev/bus/usb/$BUS/$DEV"

        echo "🔌 micro:bit detected at $DEV_PATH"

        if [[ -e "$DEV_PATH" ]]; then
          if sudo chmod 666 "$DEV_PATH"; then
            echo "✅ Permissions set for $DEV_PATH"
          else
            echo "❌ Failed to set permissions" >&2
          fi
        else
          echo "⚠️ Device path does not exist: $DEV_PATH" >&2
        fi
        break
      fi
    done
  done < <(lsusb)
fi

# Step 2: Determine board name from argument or via pyocd auto-detection
if [[ "$BOARD_ARG" != "auto" ]]; then
  BOARD="$BOARD_ARG"
  echo "📦 Using board specified by argument: $BOARD"
else
  result=$(pyocd list)

  if echo "$result" | grep -q "$TARGET_V1"; then
    BOARD="bbc_microbit"
    echo "🎯 Detected board: micro:bit v1"
  elif echo "$result" | grep -q "$TARGET_V2"; then
    BOARD="bbc_microbit_v2"
    echo "🎯 Detected board: micro:bit v2"
  else
    echo "❌ No supported board detected"
    exit 1
  fi
fi

# Step 3: Build firmware for the detected or specified board
if [[ "$MODE" == "build" ]]; then
  echo "🔨 Building firmware for $BOARD ..."
  west build -p auto -b "$BOARD"
fi

# Step 4: Optionally flash firmware
if [[ "$MODE" == "flash" ]]; then
  echo "⚡ Flashing firmware to $BOARD ..."
  west flash
fi

# Step 5: Optionally start debug server
if [[ "$MODE" == "debugserver" ]]; then
  echo "🚀 Launching debugserver for $BOARD ..."
  west debugserver
fi
