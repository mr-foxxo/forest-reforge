# Supply a reviewed Debian i386 image digest and a locally obtained 32-bit JDK8.
ARG VIEWER_BASE_IMAGE
FROM --platform=linux/386 ${VIEWER_BASE_IMAGE}
ARG VIEWER_BASE_IMAGE
ARG JDK_SHA256
USER 0
RUN echo "$VIEWER_BASE_IMAGE" | grep -Eq '^.+@sha256:[a-f0-9]{64}$'
RUN apt-get update && apt-get install -y --no-install-recommends \
    xvfb x11vnc fluxbox unzip file ca-certificates fonts-dejavu \
    libxtst6 libxi6 libxrender1 libxext6 libxrandr2 libasound2 \
    libfreetype6 libfontconfig1 && rm -rf /var/lib/apt/lists/*
COPY private/jdk8-i386.tar.gz /tmp/jdk.tar.gz
RUN test -n "$JDK_SHA256" && echo "$JDK_SHA256  /tmp/jdk.tar.gz" | sha256sum -c - \
    && mkdir -p /opt/java && tar -xzf /tmp/jdk.tar.gz -C /opt/java --strip-components=1 \
    && rm /tmp/jdk.tar.gz && test "$(/opt/java/bin/java -XshowSettings:properties -version 2>&1 | sed -n 's/.*sun.arch.data.model = //p')" = 32
COPY JnlpLauncher.java /opt/viewer/JnlpLauncher.java
RUN /opt/java/bin/javac -d /opt/viewer /opt/viewer/JnlpLauncher.java \
    && mkdir -p /state && chown 1000:1000 /state
COPY start-viewer.sh /usr/local/bin/start-viewer
RUN chmod 755 /usr/local/bin/start-viewer
ENV JAVA_HOME=/opt/java PATH=/opt/java/bin:$PATH HOME=/state DISPLAY=:99
USER 1000:1000
ENTRYPOINT ["/usr/local/bin/start-viewer"]

