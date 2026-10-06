#!/bin/bash

# ============================================================
# Noor Al-Hidayah — Preview (Release + Static Serve)
# ============================================================

echo "🧹 Cleaning old processes..."
pkill -f "http.server" 2>/dev/null
pkill -f flutter 2>/dev/null
pkill -f dart 2>/dev/null
sleep 2

echo "🔨 Building web (release)..."
echo "   ⏱️  First build: 1-3 minutes | After: ~30 sec"
flutter build web --release

echo ""
echo "🚀 Serving on port 8095 (static files)..."
echo "   ✅ Fast navigation — no lag"
echo ""
cd build/web
python3 -m http.server 8095 --bind 0.0.0.0
