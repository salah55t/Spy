FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# تثبيت الحزم الأساسية + unzip لفك الضغط
RUN dpkg --add-architecture i386 && \
    apt-get update && apt-get install -y \
    xvfb \
    x11vnc \
    novnc \
    websockify \
    fluxbox \
    wine32 \
    wine64 \
    winetricks \
    curl \
    gnupg \
    unzip \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# انسخ الملف المضغوط
COPY "SpyNote.zip" /app/app.zip

# فك الضغط
RUN unzip /app/app.zip -d /app && \
    rm /app/app.zip

# ابحث عن أي ملف .exe داخل المجلد وانسخه إلى app.exe (لتسهيل التشغيل)
RUN find /app -name "*.exe" -exec cp {} /app/app.exe \;

EXPOSE 10000

# سكربت الإقلاع
RUN echo '#!/bin/bash\n\
Xvfb :1 -screen 0 1024x768x16 &\n\
export DISPLAY=:1\n\
sleep 3\n\
fluxbox &\n\
sleep 1\n\
x11vnc -forever -shared -nopw -display :1 -rfbport 5900 -bg -o /app/x11vnc.log\n\
sleep 2\n\
winetricks -q dotnet40 2>&1 | tee /app/winetricks.log\n\
wine explorer /desktop=spynote,1024x768 /app/app.exe 2>&1 | tee /app/wine.log &\n\
websockify --web /usr/share/novnc/ 10000 localhost:5900\n\
' > /app/start.sh && chmod +x /app/start.sh

CMD ["/app/start.sh"]
