#!/bin/bash

# قتل أي عمليات قديمة
pkill -f flutter 2>/dev/null
pkill -f dart 2>/dev/null

# تنظيف
flutter clean 2>/dev/null
flutter pub get 2>/dev/null

# تشغيل
flutter run -d web-server \
  --web-hostname 0.0.0.0 \
  --web-port 8095 \
  --no-wasm-dry-run
