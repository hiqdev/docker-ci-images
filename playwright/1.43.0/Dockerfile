FROM node:18-bullseye

# Tells apt and dpkg to skip interactive prompts.
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies required by Playwright
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libnss3 \
    libxss1 \
    libasound2 \
    libx11-xcb1 \
    libgtk-3-0 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# === BAKE BROWSERS INTO IMAGE ===
# 1. Change browser cache directory from ~/.cache/ms-playwright
ENV PLAYWRIGHT_BROWSERS_PATH=/ms-playwright

# 2. Create directory and make it world-accessible
RUN mkdir -p /ms-playwright && chmod -R 777 /ms-playwright

# Install Playwright 1.43.0 and its browsers
RUN npm install -g playwright@1.43.0 && \
    npx playwright install --with-deps && \
    rm -rf /var/lib/apt/lists/*

# Set default working directory
WORKDIR /app

# Verify installation
RUN playwright --version