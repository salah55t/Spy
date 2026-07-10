#!/bin/bash

# بدء Xvfb
Xvfb :1 -screen 0 1024x768x16 &
export DISPLAY=:1

# انتظار Xvfb
for i in {1..10}; do
    xdpyinfo -display :1 >/dev/null 2>&1 && break
    echo "Waiting for Xvfb... ($i)"
    sleep 1
done

# بدء Fluxbox
fluxbox &

# بدء x11vnc مع انتظار التأكد من تشغيله
x11vnc -forever -shared -nopw -display :1 -rfbport 5900 -bg -o /app/x11vnc.log
sleep 3

# التحقق من أن x11vnc يستمع على 5900
if ! ss -lnt | grep -q :5900; then
    echo "ERROR: x11vnc not listening on port 5900" >&2
    cat /app/x11vnc.log
    exit 1
fi

# تثبيت .NET في الخلفية
winetricks -q dotnet40 2>&1 > /app/winetricks.log &

# تشغيل التطبيق في الخلفية
wine explorer /desktop=spynote,1024x768 /app/app.exe 2>&1 > /app/wine.log &

# تشغيل websockify (بالمسار الصحيح)
/usr/bin/websockify --web /usr/share/novnc/ 10000 localhost:5900
