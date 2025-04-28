#!/usr/bin/env zsh

# ─── Color Definitions ───────────────────────────────────────────────────────
RED='\033[0;31m'     # red foreground&#8203;:contentReference[oaicite:0]{index=0}
YELLOW='\033[0;33m'  # yellow foreground&#8203;:contentReference[oaicite:1]{index=1}
BLUE='\033[0;34m'    # blue foreground&#8203;:contentReference[oaicite:2]{index=2}
GREEN='\033[0;32m'   # green foreground&#8203;:contentReference[oaicite:4]{index=4}
NC='\033[0m'         # reset / no color&#8203;:contentReference[oaicite:3]{index=3}

# ─── Logging Functions ─────────────────────────────────────────────────────
error_ () {
  # Prints [ERROR] in red, then resets color
  echo "${RED}[ERROR] $*${NC}"
}

warning_ () {
  # Prints [WARNING] in yellow, then resets color
  echo "${YELLOW}[WARNING] $*${NC}"
}

info_ () {
  # Prints [INFO] in blue, then resets color
  echo "${BLUE}[INFO] $*${NC}"
}

success_ () {
  # Prints [SUCCESS] in green, then resets color
  echo "${GREEN}[SUCCESS] $*${NC}"
}
