#!/bin/sh

# Environment variable injection script for Flutter web app
# This script runs at container startup to inject environment variables

echo "🚀 Injecting environment variables into Flutter web app..."

# Set default values if environment variables are not provided
API_BASE_URL=${API_BASE_URL:-"http://localhost:8080/api/reconnect"}
PORT=${PORT:-80}

echo "📡 API_BASE_URL: $API_BASE_URL"
echo "🔌 PORT: $PORT"

# Process nginx configuration to use correct port
sed "s/PORT_PLACEHOLDER/$PORT/g" /etc/nginx/nginx.conf > /tmp/nginx.conf.tmp
mv /tmp/nginx.conf.tmp /etc/nginx/nginx.conf

# Create the env-config.js file with environment variables
cat > /usr/share/nginx/html/env-config.js << EOF
// Runtime environment configuration
// This file is generated at container startup with environment variables
window.ENV = {
  API_BASE_URL: '$API_BASE_URL'
};
EOF

echo "✅ Environment variables injected successfully!"
echo "📄 Generated env-config.js:"
cat /usr/share/nginx/html/env-config.js