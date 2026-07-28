#!/bin/bash

echo "🔄 Starting Flutter project setup..."

# تأكد إن Flutter في الـ PATH
export PATH="$PATH:$HOME/flutter/bin"

# تحقق من البيئة
flutter --version || { echo "❌ Flutter not found in PATH"; exit 1; }
flutter doctor

# جلب الـ dependencies
flutter pub get

# تحديث الإصدارات لو فيه تعارضات
flutter pub upgrade --major-versions

# توليد الملفات (Isar, Freezed, Riverpod)
flutter pub run build_runner build --delete-conflicting-outputs

# تشغيل التطبيق مباشرة على الويب
echo "🚀 Launching app on web server..."
flutter run -d web-server --web-port=8080 --web-hostname=0.0.0.0
