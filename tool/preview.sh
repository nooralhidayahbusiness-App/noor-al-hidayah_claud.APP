#!/bin/bash
# Builds the web app and serves it on port 8095 (open it from the Ports tab).
pkill -f "http.server 8095" 2>/dev/null
flutter build web --release --pwa-strategy=none --dart-define=SHOW_SKIP=true && python3 -m http.server 8095 --directory build/web
