# Multi-stage Docker build for Flutter web app
# Stage 1: Build the Flutter web app
FROM ghcr.io/cirruslabs/flutter:stable AS build

# Set working directory
WORKDIR /app

# Copy pubspec files and get dependencies
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# Copy the rest of the application
COPY . .

# Set API_BASE_URL in .env file for Flutter build
# This will use the API_BASE_URL build arg from Render.com or default
ARG API_BASE_URL=http://localhost:8080/api/reconnect
RUN echo "API_BASE_URL=${API_BASE_URL}" > .env

# Build the web app for production (disable WASM dry-run to avoid compilation issues)
RUN flutter build web --release --no-wasm-dry-run

# Stage 2: Serve the app with nginx
FROM nginx:alpine

# Install envsubst (part of gettext package) for environment variable substitution
RUN apk add --no-cache gettext

# Copy the built web app from the previous stage
COPY --from=build /app/build/web /usr/share/nginx/html

# Copy nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]