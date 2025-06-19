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

# Install only necessary npm packages
COPY package.json package-lock.json* ./
RUN npm ci

# Install Playwright with browser dependencies
RUN npx playwright install --with-deps

# Set working directory and entry point
WORKDIR /app

CMD ["npx", "playwright", "--version"]