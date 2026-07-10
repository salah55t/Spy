FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

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
    net-tools \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# انسخ الملف المضغوط وفك ضغطه
COPY SpyNote\ V6.zip /app/app.zip
RUN unzip app.zip && rm app.zip

# انسخ ملف start.sh
COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

EXPOSE 10000

CMD ["/app/start.sh"]
