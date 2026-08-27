#!/usr/bin/env bash
# mirza_vali Pro — one-line / local installer
# ------------------------------------------------------------
# NOT classic mirza_vali. Classic=/home/mirza_vali  Pro=/home/mirza_vali_pro
#
# Public repo (testing):
#   curl -fsSL https://raw.githubusercontent.com/silent4time/mirza_vali_pro/main/install.sh | sudo bash
#
# Local zip (or after repo is Private again):
#   sudo bash install.sh /root/mirza_vali_pro-latest.zip
# ------------------------------------------------------------
set -euo pipefail

REPO_OWNER="${REPO_OWNER:-silent4time}"
REPO_NAME="${REPO_NAME:-mirza_vali_pro}"
REPO_RAW="https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/main"
REPO_ZIP_RAW="${REPO_RAW}/mirza_vali_pro-latest.zip"
REPO_ZIP_GITHUB="https://github.com/${REPO_OWNER}/${REPO_NAME}/raw/main/mirza_vali_pro-latest.zip"
SRC_DIR="/opt/mirza_vali_pro-src"
WORK="/tmp/mirza_vali_pro_install_$$"
LOCAL_ZIP="${1:-}"

if [[ ${EUID:-$(id -u)} -ne 0 ]]; then
  echo "Please run as root (sudo)."
  exit 1
fi

export DEBIAN_FRONTEND=noninteractive
command -v curl >/dev/null 2>&1 || { apt-get update -y >/dev/null 2>&1; apt-get install -y curl >/dev/null 2>&1; }
command -v unzip >/dev/null 2>&1 || { apt-get update -y >/dev/null 2>&1; apt-get install -y unzip >/dev/null 2>&1; }

mkdir -p "$WORK"
ZIP_FILE="$WORK/mirza_vali_pro-latest.zip"

pick_local_zip() {
  local candidates=(
    "$LOCAL_ZIP"
    "/root/mirza_vali_pro-latest.zip"
    "/home/mirza_vali_pro-latest.zip"
    "/root/mirza_vali_pro_v4.0.2.zip"
    "/home/mirza_vali_pro_v4.0.2.zip"
    "/root/mirza_vali_pro_v4.0.1.zip"
    "/home/mirza_vali_pro_v4.0.1.zip"
    "/root/mirza_vali_pro_v4.0.0.zip"
    "/home/mirza_vali_pro_v4.0.0.zip"
  )
  local c
  for c in "${candidates[@]}"; do
    if [[ -n "$c" && -f "$c" && -s "$c" ]]; then
      echo "$c"
      return 0
    fi
  done
  return 1
}

echo "[*] mirza_vali Pro installer"
echo "    Target install path (default): /home/mirza_vali_pro"
echo "    Classic mirza_vali at /home/mirza_vali will NOT be touched."
echo ""

if [[ "${SKIP_LOCAL:-0}" != "1" ]] && LOCAL_FOUND="$(pick_local_zip)"; then
  echo "[*] Using local package: $LOCAL_FOUND"
  cp -f "$LOCAL_FOUND" "$ZIP_FILE"
else
  echo "[*] No local zip found — trying GitHub (${REPO_OWNER}/${REPO_NAME})..."
  echo "    Public repo download: mirza_vali_pro-latest.zip from GitHub main"
  OK=0
  if [[ -n "${GITHUB_TOKEN:-${GH_TOKEN:-}}" ]]; then
    TOK="${GITHUB_TOKEN:-$GH_TOKEN}"
    if curl -fsSL --connect-timeout 15 --max-time 180 \
      -H "Authorization: token ${TOK}" \
      -o "$ZIP_FILE" "$REPO_ZIP_GITHUB"; then
      OK=1
    fi
  fi
  if [[ "$OK" -ne 1 ]]; then
    if curl -fsSL --connect-timeout 15 --max-time 180 --retry 2 -o "$ZIP_FILE" "$REPO_ZIP_GITHUB"; then
      OK=1
    elif curl -fsSL --connect-timeout 15 --max-time 180 --retry 2 -o "$ZIP_FILE" "$REPO_ZIP_RAW"; then
      OK=1
    fi
  fi
  if [[ "$OK" -ne 1 ]]; then
    echo "[x] Could not download from GitHub."
    echo "    Checklist:"
    echo "      1) Repo silent4time/mirza_vali_pro is Public (or use GH_TOKEN)"
    echo "      2) File mirza_vali_pro-latest.zip exists on branch main (repo root)"
    echo "      3) Or upload zip to server: sudo bash install.sh /root/mirza_vali_pro-latest.zip"
    rm -rf "$WORK"
    exit 1
  fi
fi

if [[ ! -s "$ZIP_FILE" ]] || ! unzip -t "$ZIP_FILE" >/dev/null 2>&1; then
  echo "[x] Package is missing or not a valid zip."
  rm -rf "$WORK"
  exit 1
fi

echo "[*] Extracting..."
mkdir -p "$WORK/out"
unzip -qo "$ZIP_FILE" -d "$WORK/out"

if [[ ! -f "$WORK/out/manage.sh" ]] && [[ -f "$WORK/out/mirza_vali_pro-latest.zip" ]]; then
  echo "[*] Nested mirza_vali_pro-latest.zip detected — extracting inner package..."
  mkdir -p "$WORK/inner"
  unzip -qo "$WORK/out/mirza_vali_pro-latest.zip" -d "$WORK/inner"
  rm -rf "$WORK/out"
  mv "$WORK/inner" "$WORK/out"
fi

FOUND=""
if [[ -f "$WORK/out/manage.sh" && -d "$WORK/out/patch" ]]; then
  FOUND="$WORK/out"
else
  FOUND="$(find "$WORK/out" -type f -name manage.sh 2>/dev/null | head -1 || true)"
  if [[ -n "$FOUND" ]]; then
    FOUND="$(dirname "$FOUND")"
  fi
fi

if [[ -z "$FOUND" || ! -f "$FOUND/manage.sh" ]]; then
  echo "[x] manage.sh not found inside the package."
  rm -rf "$WORK"
  exit 1
fi
if [[ ! -d "$FOUND/patch" || ! -f "$FOUND/patch/botapi.php" ]]; then
  echo "[x] patch/ folder missing inside the package."
  rm -rf "$WORK"
  exit 1
fi

if grep -q 'PROJECT_NAME="mirza_vali"' "$FOUND/manage.sh" 2>/dev/null && ! grep -q 'PROJECT_NAME="mirza_vali_pro"' "$FOUND/manage.sh" 2>/dev/null; then
  echo "[x] This package looks like CLASSIC mirza_vali (not Pro)."
  rm -rf "$WORK"
  exit 1
fi

echo "[*] Installing Pro source to $SRC_DIR ..."
rm -rf "$SRC_DIR"
mkdir -p /opt "$SRC_DIR"
cp -a "$FOUND"/. "$SRC_DIR/"
chmod +x "$SRC_DIR/manage.sh" "$SRC_DIR/install.sh" 2>/dev/null || true
rm -rf "$WORK"

echo "[*] Source OK"
echo "    Classic (if any): /home/mirza_vali  — left alone"
echo "    Pro default path: /home/mirza_vali_pro"
echo "[*] Starting mirza_vali Pro management panel..."
echo "    Choose: 1) Install mirza_vali Pro"
cd "$SRC_DIR"
if [[ -e /dev/tty ]]; then
  exec bash ./manage.sh "$@" < /dev/tty
else
  exec bash ./manage.sh "$@"
fi
