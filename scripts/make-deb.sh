#!/usr/bin/env bash
#
# Package the built Linux release bundle into an installable .deb.
#
# Prerequisites:
#   flutter build linux --release    (produces build/linux/x64/release/bundle/)
#   dpkg-deb + fakeroot installed
#
# Usage:
#   scripts/make-deb.sh [version]      # version defaults to 0.0.5
#
# Output: build/deb/loops-flutter_<version>_amd64.deb
set -euo pipefail

VERSION="${1:-0.0.5}"
PKG="loops-flutter"            # Debian package name (lowercase, no underscores)
ARCH="amd64"
MAINTAINER="Ram-Victus <ramnikhileshcr44@gmail.com>"
BIN="loops_flutter"           # the Flutter executable name

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUNDLE="$ROOT/build/linux/x64/release/bundle"
OUT="$ROOT/build/deb"
STAGE="$OUT/${PKG}_${VERSION}_${ARCH}"

[ -x "$BUNDLE/$BIN" ] || { echo "ERROR: release bundle not found — run 'flutter build linux --release' first." >&2; exit 1; }

echo "==> Staging $PKG $VERSION"
rm -rf "$STAGE"
mkdir -p "$STAGE/DEBIAN" \
         "$STAGE/opt/$PKG" \
         "$STAGE/usr/bin" \
         "$STAGE/usr/share/applications" \
         "$STAGE/usr/share/icons/hicolor/512x512/apps"

# App payload under /opt, launched via a /usr/bin symlink.
cp -r "$BUNDLE/." "$STAGE/opt/$PKG/"
ln -sf "/opt/$PKG/$BIN" "$STAGE/usr/bin/$PKG"

# Icon + desktop entry.
cp "$ROOT/web/icons/Icon-512.png" "$STAGE/usr/share/icons/hicolor/512x512/apps/$PKG.png"
cat > "$STAGE/usr/share/applications/$PKG.desktop" <<DESKTOP
[Desktop Entry]
Type=Application
Name=Loops
Comment=A Flutter client for Loops short-form video
Exec=$PKG
Icon=$PKG
Categories=Video;Network;AudioVideo;
Terminal=false
DESKTOP

# Compute runtime dependencies.
#
# Curated base list (verified by installing on Ubuntu 24.04): the GTK shell,
# GLib, audio (ALSA/PulseAudio), OpenGL helpers, libmpv for desktop video, and
# the C/C++ runtimes. We then union in anything `ldd` additionally resolves to a
# system package, so newly-added native plugins are picked up automatically.
echo "==> Resolving dependencies"
BASE="libasound2t64 libc6 libepoxy0 libgcc-s1 libglib2.0-0t64 libgtk-3-0t64 libmpv2 libpulse0 libstdc++6"
LIBS=$(ldd "$STAGE/opt/$PKG/$BIN" "$STAGE/opt/$PKG/lib/"*.so 2>/dev/null \
        | awk '/=>/ {print $3}' | grep -E '^/' | sort -u)
DETECTED=$(for l in $LIBS; do dpkg -S "$l" 2>/dev/null; done | cut -d: -f1 | tr ',' '\n')
DEPS=$(printf '%s\n%s\n' "$(echo "$BASE" | tr ' ' '\n')" "$DETECTED" \
        | sort -u | grep -v "^$" | paste -sd, - | sed 's/,/, /g')

INSTALLED_KB=$(du -sk "$STAGE/opt" "$STAGE/usr" | awk '{s+=$1} END {print s}')

cat > "$STAGE/DEBIAN/control" <<CONTROL
Package: $PKG
Version: $VERSION
Section: video
Priority: optional
Architecture: $ARCH
Maintainer: $MAINTAINER
Installed-Size: $INSTALLED_KB
Depends: $DEPS
Description: Loops — short-form video client
 A modern, cross-platform Flutter client for the Loops video platform,
 featuring an immersive feed, Loops Studio creator dashboard, and a
 Material 3 interface with light/dark theming.
CONTROL

# Refresh the icon + desktop caches after install/removal.
cat > "$STAGE/DEBIAN/postinst" <<'POSTINST'
#!/bin/sh
set -e
if command -v gtk-update-icon-cache >/dev/null 2>&1; then
  gtk-update-icon-cache -q /usr/share/icons/hicolor || true
fi
if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database -q || true
fi
exit 0
POSTINST
cp "$STAGE/DEBIAN/postinst" "$STAGE/DEBIAN/postrm"
chmod 0755 "$STAGE/DEBIAN/postinst" "$STAGE/DEBIAN/postrm"

echo "==> Building .deb (Depends: $DEPS)"
fakeroot dpkg-deb --build "$STAGE" "$OUT/${PKG}_${VERSION}_${ARCH}.deb" >/dev/null
echo "==> Done: $OUT/${PKG}_${VERSION}_${ARCH}.deb"
