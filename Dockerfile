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

# Build the web app for production
RUN flutter build web --release

# Stage 2: Serve the app with nginx
FROM nginx:alpine

# Install envsubst (part of gettext package) for environment variable substitution
RUN apk add --no-cache gettext

# Copy the built web app from the previous stage
COPY --from=build /app/build/web /usr/share/nginx/html

# Copy nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Create environment variable injection script
COPY inject-env.sh /docker-entrypoint.d/
RUN chmod +x /docker-entrypoint.d/inject-env.sh

# Create template for environment variables
COPY env-config.template.js /usr/share/nginx/html/

# Expose port (Render.com will set PORT environment variable)
EXPOSE $PORT

# The default nginx entrypoint will run our injection script automatically
CMD ["nginx", "-g", "daemon off;"]