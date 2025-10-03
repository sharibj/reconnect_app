# 🚀 Reconnect App - Docker Deployment Guide

This guide explains how to deploy the Reconnect Flutter web app using Docker with runtime environment variable configuration.

## 📋 Prerequisites

- Docker and Docker Compose installed
- A running backend API server (for authentication and data)

## 🏗️ Quick Start

### 1. Using Docker Compose (Recommended)

```bash
# Clone the repository
git clone <your-repo-url>
cd reconnect_app

# Update the API_BASE_URL in docker-compose.yml
# Edit docker-compose.yml and set API_BASE_URL to your backend URL

# Build and run
docker-compose up --build -d

# The app will be available at http://localhost:3000
```

### 2. Using Docker directly

```bash
# Build the image
docker build -t reconnect-app .

# Run the container with environment variables
docker run -d \
  --name reconnect-frontend \
  -p 3000:80 \
  -e API_BASE_URL=http://your-backend-server:8080/api/reconnect \
  reconnect-app

# The app will be available at http://localhost:3000
```

## ⚙️ Configuration

### Environment Variables

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `API_BASE_URL` | Base URL for the backend API | `http://localhost:8080/api/reconnect` | Yes |

### Example Configuration

```bash
# For local development
API_BASE_URL=http://localhost:8080/api/reconnect

# For production with different backend
API_BASE_URL=https://api.yourdomain.com/api/reconnect

# For containerized backend
API_BASE_URL=http://reconnect-backend:8080/api/reconnect
```

## 🏭 Production Deployment

### 1. Cloud Deployment (AWS, GCP, Azure)

```bash
# Build for production
docker build -t reconnect-app:latest .

# Tag for your registry
docker tag reconnect-app:latest your-registry.com/reconnect-app:latest

# Push to registry
docker push your-registry.com/reconnect-app:latest

# Deploy with your cloud provider's container service
```

### 2. Kubernetes Deployment

Create a `k8s-deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: reconnect-frontend
spec:
  replicas: 3
  selector:
    matchLabels:
      app: reconnect-frontend
  template:
    metadata:
      labels:
        app: reconnect-frontend
    spec:
      containers:
      - name: reconnect-frontend
        image: your-registry.com/reconnect-app:latest
        ports:
        - containerPort: 80
        env:
        - name: API_BASE_URL
          value: "https://api.yourdomain.com/api/reconnect"
---
apiVersion: v1
kind: Service
metadata:
  name: reconnect-frontend-service
spec:
  selector:
    app: reconnect-frontend
  ports:
  - port: 80
    targetPort: 80
  type: LoadBalancer
```

### 3. Docker Swarm Deployment

```yaml
# docker-stack.yml
version: '3.8'
services:
  reconnect-frontend:
    image: reconnect-app:latest
    ports:
      - "3000:80"
    environment:
      - API_BASE_URL=https://api.yourdomain.com/api/reconnect
    deploy:
      replicas: 3
      restart_policy:
        condition: on-failure
    networks:
      - reconnect-network
networks:
  reconnect-network:
    external: true
```

## 🏥 Health Checks

The container includes a health check endpoint at `/health`. You can monitor the application health:

```bash
# Check health
curl http://localhost:3000/health

# Expected response: "healthy"
```

## 🔧 Troubleshooting

### 1. App shows "Failed to load" errors

**Cause**: Backend API is not accessible or API_BASE_URL is incorrect.

**Solution**:
- Verify your backend is running and accessible
- Check the API_BASE_URL environment variable
- Ensure CORS is properly configured on your backend

### 2. Authentication not working

**Cause**: API endpoints are not accessible or returning errors.

**Solution**:
- Check browser developer tools for network errors
- Verify backend authentication endpoints are working
- Ensure JWT token handling is working correctly

### 3. Container fails to start

**Cause**: Build issues or missing dependencies.

**Solution**:
```bash
# Check container logs
docker logs reconnect-frontend

# Rebuild with no cache
docker build --no-cache -t reconnect-app .
```

### 4. Runtime environment variables not working

**Cause**: The injection script is not running or env-config.js is not loading.

**Solution**:
- Check that inject-env.sh has execute permissions
- Verify env-config.js is being generated in the container
- Check browser developer tools for JavaScript errors

## 📁 File Structure

```
reconnect_app/
├── Dockerfile              # Multi-stage Docker build
├── docker-compose.yml      # Docker Compose configuration
├── nginx.conf              # Nginx web server configuration
├── inject-env.sh           # Environment variable injection script
├── env-config.template.js  # Environment config template
└── web/
    └── index.html          # Updated to include env-config.js
```

## 🔐 Security Considerations

1. **HTTPS**: Always use HTTPS in production
2. **Environment Variables**: Never commit sensitive data to version control
3. **CORS**: Configure your backend CORS settings properly
4. **Nginx Security**: The nginx.conf includes basic security headers
5. **Container Security**: Keep your base images updated

## 📊 Monitoring & Logging

### View Logs
```bash
# Docker Compose
docker-compose logs -f reconnect-frontend

# Docker
docker logs -f reconnect-frontend
```

### Metrics
The nginx configuration includes access logs that can be used for monitoring and analytics.

## 🔄 Updates & Maintenance

### Update the Application
```bash
# Pull latest changes
git pull origin main

# Rebuild and restart
docker-compose up --build -d
```

### Backup Considerations
The application is stateless - all data is stored in the backend. No backup is needed for the frontend container itself.

## 📞 Support

For issues or questions:
1. Check the troubleshooting section above
2. Review container logs
3. Verify backend API connectivity
4. Check browser developer tools for client-side errors

## 🎯 Render.com Deployment (Recommended)

Render.com provides excellent Docker support with automatic deployments from Git. The app is optimized for Render.com deployment.

### Quick Deploy to Render.com

1. **Fork/Clone the repository** to your GitHub account

2. **Connect to Render.com**:
   - Go to [render.com](https://render.com) and sign up/login
   - Click "New" → "Web Service"
   - Connect your GitHub repository

3. **Use Render Blueprint** (Easiest):
   ```bash
   # The render.yaml file is already configured
   # Just update the API_BASE_URL in render.yaml to point to your backend
   ```

4. **Manual Setup** (Alternative):
   - **Name**: `reconnect-frontend`
   - **Runtime**: Docker
   - **Dockerfile Path**: `./Dockerfile.render`
   - **Build Command**: (leave empty, handled by Docker)
   - **Start Command**: (leave empty, handled by Docker)

5. **Environment Variables**:
   ```
   API_BASE_URL=https://your-backend.onrender.com/api/reconnect
   ```

6. **Deploy**: Click "Create Web Service" and wait for deployment!

### Render.com Features

✅ **Automatic Deployments**: Deploys on every git push
✅ **Free Tier Available**: Perfect for testing and small projects
✅ **Custom Domains**: Add your own domain easily
✅ **SSL Certificates**: Automatic HTTPS
✅ **Health Checks**: Built-in monitoring
✅ **Logs & Metrics**: Full observability

### Render.com Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `API_BASE_URL` | Backend API URL | `https://api.yourdomain.com/api/reconnect` |
| `PORT` | Port to listen on | `10000` (set automatically by Render) |

### Render.com URLs

After deployment, your app will be available at:
- **Render URL**: `https://your-service-name.onrender.com`
- **Custom Domain**: Configure in Render dashboard
- **Health Check**: `https://your-service-name.onrender.com/health`

---

**Happy Deploying! 🎉**