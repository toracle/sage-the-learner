#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# 빌드 스크립트: 현자 세이지의 비법
# Usage:
#   ./build.sh          → HTML + PDF (if fonts present)
#   ./build.sh html     → HTML only
#   ./build.sh pdf      → PDF only
# ─────────────────────────────────────────────────────────────────────────────
set -e

TARGET="${1:-all}"
DIST="dist"
# PDF_FONTSDIR can be overridden.
# Default: system nanum path (apt install fonts-nanum fonts-nanum-coding)
# Fallback: local ./fonts/ directory
SYSTEM_NANUM="/usr/share/fonts/truetype/nanum"
if [ -n "$PDF_FONTSDIR" ]; then
  FONTS_DIR="$PDF_FONTSDIR"
elif [ -d "$SYSTEM_NANUM" ]; then
  FONTS_DIR="$SYSTEM_NANUM"
else
  FONTS_DIR="fonts"
fi

mkdir -p "$DIST"

# ── bundle exec wrapper ───────────────────────────────────────────────────────
BUNDLE="bundle exec"
if ! command -v bundle >/dev/null 2>&1; then
  echo "❌  bundler not found. Install: gem install bundler"
  exit 1
fi
# Ensure gems are installed
bundle check >/dev/null 2>&1 || bundle install

# ── Font check ───────────────────────────────────────────────────────────────
REQUIRED_FONTS=(
  "NanumMyeongjo.ttf"
  "NanumMyeongjoBold.ttf"
  "NanumGothic.ttf"
  "NanumGothicBold.ttf"
  "NanumBarunGothic.ttf"
  "NanumGothicCoding.ttf"
  "NanumGothicCodingBold.ttf"
)

FONTS_OK=true
for f in "${REQUIRED_FONTS[@]}"; do
  if [ ! -f "$FONTS_DIR/$f" ]; then
    echo "⚠️   Missing font: $FONTS_DIR/$f"
    FONTS_OK=false
  fi
done

if [ "$FONTS_OK" = false ]; then
  echo ""
  echo "    Nanum 폰트 다운로드: https://hangeul.naver.com/font"
  echo "    다운로드 후 fonts/ 디렉토리에 복사하거나,"
  echo "    시스템 설치 후 PDF_FONTSDIR=/usr/share/fonts/truetype/nanum 로 지정하세요."
  echo ""
fi

# ── HTML build ───────────────────────────────────────────────────────────────
build_html() {
  echo "📄  HTML 빌드 중..."
  $BUNDLE asciidoctor \
    -d book \
    -o "$DIST/book.html" \
    book.adoc
  echo "✅  HTML → $DIST/book.html"
}

# ── PDF build ────────────────────────────────────────────────────────────────
build_pdf() {
  if [ "$FONTS_OK" = false ]; then
    echo "⏭️   PDF 빌드 건너뜀 (폰트 누락)"
    return
  fi
  echo "📕  PDF 빌드 중..."
  $BUNDLE asciidoctor-pdf \
    -d book \
    -a pdf-theme=themes/korean-theme.yml \
    -a pdf-fontsdir="$FONTS_DIR" \
    -o "$DIST/book.pdf" \
    book.adoc
  echo "✅  PDF  → $DIST/book.pdf"
}

# ── Run ──────────────────────────────────────────────────────────────────────
case "$TARGET" in
  html)       build_html ;;
  pdf)        build_pdf ;;
  all|*)      build_html; build_pdf ;;
esac
