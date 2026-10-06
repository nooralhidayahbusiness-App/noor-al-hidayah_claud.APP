#!/bin/bash

echo "🕌 Starting Noor Al-Hidayah preview..."

# 1) أوقف أي عمليات قديمة
pkill -f flutter 2>/dev/null
pkill -f dart 2>/dev/null
sleep 2

# 2) شغّل التطبيق (نفس الأمر اللي يشتغل عندك — بدون clean)
flutter run -d web-server \
  --web-hostname 0.0.0.0 \
  --web-port 8095
