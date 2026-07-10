#!/bin/bash

# حذف أي ملفات قفل قديمة للشاشة 1
rm -f /tmp/.X1-lock /tmp/.X11-unix/X1

# بدء Xvfb على الشاشة 1 بعد التنظيف
Xvfb :1 -screen 0 1024x768x16 &
export DISPLAY=:1

# انتظار حتى يصبح Xvfb جاهزاً
for i in {1..10}; do
    xdpyinfo -display :1 >/dev/null 2>&1 && break
    echo "Waiting for Xvfb... ($i)"
    sleep 1
done

# إذا لم يعمل Xvfb على :1، جرب :99
if ! xdpyinfo -display :1 >/dev/null 2>&1; then
    echo "Display :1 failed, trying :99"
    rm -f /tmp/.X99-lock /tmp/.X11-unix/X99
    Xvfb :99 -screen 0 1024x768x16 &
    export DISPLAY=:99
    sleep 3
fi

# تشغيل باقي الخدمات
fluxbox &
x11vnc -forever -shared -nopw -display "$DISPLAY" -rfbport 5900 -bg -o /app/x11vnc.log
sleep 2

winetricks -q dotnet40 2>&1 | tee /app/winetricks.log
wine explorer /desktop=spynote,1024x768 /app/SpyNote.exe 2>&1 | tee /app/wine.log &

websockify --web /usr/share/novnc/ 10000 localhost:5900
