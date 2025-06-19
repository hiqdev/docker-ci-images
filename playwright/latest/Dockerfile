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
# 1. change browser cache directory from ~/.cache/ms-playwright
ENV PLAYWRIGHT_BROWSERS_PATH=/ms-playwright

# 2. Bake in browsers & deps.
#    Browsers will be downloaded in `/ms-playwright`.
#    Note: make sure to set 777 to the registry so that any user can access
#    registry.
RUN mkdir /ms-playwright && \
    chmod -R 777 /ms-playwright

# Install Playwright and its browsers
RUN npx playwright install --with-deps && \
    rm -rf /var/lib/apt/lists/* \
