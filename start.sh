#!/bin/bash

# حذف أقفال الشاشة القديمة
rm -f /tmp/.X1-lock /tmp/.X11-unix/X1

# 1. بدء Xvfb
Xvfb :1 -screen 0 1024x768x16 &
export DISPLAY=:1

# 2. انتظار Xvfb
for i in {1..15}; do
    if xdpyinfo -display :1 >/dev/null 2>&1; then
        echo "Xvfb is ready on display :1"
        break
    fi
    echo "Waiting for Xvfb... ($i)"
    sleep 1
done

# 3. تهيئة Wine (مرة واحدة)
echo "Initializing Wine..."
wineboot -u 2>&1 | tee /app/wineboot.log
sleep 3

# 4. تشغيل Fluxbox و x11vnc
fluxbox &
x11vnc -forever -shared -nopw -display :1 -rfbport 5900 -bg -o /app/x11vnc.log
sleep 2

# 5. التحقق من وجود ملف SpyNote.exe وعرض محتويات المجلد
echo "Contents of /app:"
ls -la /app

# 6. محاولة تشغيل SpyNote (إذا وجد)
if [ -f "/app/SpyNote.exe" ]; then
    echo "SpyNote.exe found, starting..."
    wine /app/SpyNote.exe 2>&1 | tee /app/wine.log &
else
    echo "WARNING: SpyNote.exe not found. Checking for other .exe files..."
    find /app -name "*.exe" -exec echo "Found: {}" \;
fi

# 7. بدء noVNC (دائمًا، بغض النظر عن نجاح SpyNote)
echo "Starting websockify on port 10000..."
websockify --web /usr/share/novnc/ 10000 localhost:5900 &

# 8. الحفاظ على الحاوية نشطة
echo "Container is running. Press Ctrl+C to stop."
sleep infinity
