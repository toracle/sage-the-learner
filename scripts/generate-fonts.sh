#!/usr/bin/env bash
set -euo pipefail

CACHE_DIR=".fonts-cache"
FONTS_DIR="fonts"

mkdir -p "$CACHE_DIR" "$FONTS_DIR"

download_if_missing() {
    local url="$1"
    local dest="$2"
    if [ ! -f "$dest" ]; then
        echo "Downloading $(basename "$dest")..."
        curl -fL --progress-bar -o "$dest" "$url"
    else
        echo "Cached: $(basename "$dest")"
    fi
}

instantiate_if_missing() {
    local input="$1"
    local output="$2"
    local wght="$3"
    if [ ! -f "$output" ]; then
        echo "Instantiating $(basename "$output") (wght=$wght)..."
        python3 -m fontTools.varLib.instancer -o "$output" "$input" "wght=$wght"
    else
        echo "Exists: $(basename "$output")"
    fi
}

# NotoSerifKR
SERIF_VAR="$CACHE_DIR/NotoSerifKR[wght].ttf"
download_if_missing \
    "https://github.com/google/fonts/raw/main/ofl/notoserifkr/NotoSerifKR%5Bwght%5D.ttf" \
    "$SERIF_VAR"
instantiate_if_missing "$SERIF_VAR" "$FONTS_DIR/NotoSerifKR-Regular.ttf" 400
instantiate_if_missing "$SERIF_VAR" "$FONTS_DIR/NotoSerifKR-Bold.ttf"    700

# NotoSansKR
SANS_VAR="$CACHE_DIR/NotoSansKR[wght].ttf"
download_if_missing \
    "https://github.com/google/fonts/raw/main/ofl/notosanskr/NotoSansKR%5Bwght%5D.ttf" \
    "$SANS_VAR"
instantiate_if_missing "$SANS_VAR" "$FONTS_DIR/NotoSansKR-Regular.ttf" 400
instantiate_if_missing "$SANS_VAR" "$FONTS_DIR/NotoSansKR-Bold.ttf"    700

# NotoMono
MONO_OUT="$FONTS_DIR/NotoMono-Regular.ttf"
MONO_SYSTEM="/usr/share/fonts/truetype/noto/NotoMono-Regular.ttf"
if [ ! -f "$MONO_OUT" ]; then
    if [ -f "$MONO_SYSTEM" ]; then
        echo "Copying NotoMono-Regular.ttf from system..."
        cp "$MONO_SYSTEM" "$MONO_OUT"
    else
        echo "Downloading NotoMono-Regular.ttf..."
        download_if_missing \
            "https://github.com/google/fonts/raw/main/apache/notomono/NotoMono-Regular.ttf" \
            "$MONO_OUT"
    fi
else
    echo "Exists: NotoMono-Regular.ttf"
fi

echo "Done. Fonts are in $FONTS_DIR/"
