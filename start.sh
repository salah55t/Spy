#!/bin/bash

# حذف أقفال الشاشة القديمة
rm -f /tmp/.X1-lock /tmp/.X11-unix/X1

# 1. بدء Xvfb مباشرة وتصدير DISPLAY
Xvfb :1 -screen 0 1024x768x16 &
export DISPLAY=:1

# 2. انتظار Xvfb (مع فحص فعلي)
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
sleep 2

# 4. بدء Fluxbox و x11vnc
fluxbox &
x11vnc -forever -shared -nopw -display :1 -rfbport 5900 -bg -o /app/x11vnc.log
sleep 2

# 5. تشغيل SpyNote مع سطح مكتب افتراضي
echo "Starting SpyNote.exe with virtual desktop..."
wine explorer /desktop=spynote,1024x768 /app/SpyNote.exe 2>&1 | tee /app/wine.log &

# 6. بدء noVNC
echo "Starting websockify on port 10000..."
websockify --web /usr/share/novnc/ 10000 localhost:5900
