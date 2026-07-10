#!/bin/bash
rm -f /tmp/.X1-lock /tmp/.X11-unix/X1

Xvfb :1 -screen 0 1024x768x16 &
export DISPLAY=:1

for i in {1..10}; do
    xdpyinfo -display :1 >/dev/null 2>&1 && break
    sleep 1
done

fluxbox &
x11vnc -forever -shared -nopw -display :1 -rfbport 5900 -bg -o /app/x11vnc.log

# لا حاجة لـ winetricks الآن
# winetricks -q dotnet40 2>&1 | tee /app/winetricks.log

# تشغيل SpyNote مع سطح مكتب افتراضي
wine explorer /desktop=spynote,1024x768 /app/SpyNote.exe 2>&1 | tee /app/wine.log &

websockify --web /usr/share/novnc/ 10000 localhost:5900
