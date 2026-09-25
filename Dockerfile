FROM apache/spark:3.5.5-scala2.12-java17-python3-ubuntu

USER root

# System + Chrome dependencies for Selenium
RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
    xvfb \
    libxi6 \
    libnss3 \
    libasound2 \
    libgbm1 \
    python3-tk \
    python3-dev \
    curl \
    && wget -q \
       https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
    && apt-get install -y \
       ./google-chrome-stable_current_amd64.deb \
    && rm google-chrome-stable_current_amd64.deb \
    && rm -rf /var/lib/apt/lists/*

# Python dependencies
COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt \
    && sbase install chromedriver

WORKDIR /app

COPY . .

CMD ["bash"]