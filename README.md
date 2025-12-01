# E-Commerce Microservices - DevOps Hackathon Solution

A fully containerized microservices e-commerce backend with Docker, security best practices, and comprehensive DevOps automation.

## 🏗️ Architecture

```
                    ┌─────────────────┐
                    │   Client/User   │
                    └────────┬────────┘
                             │
                             │ HTTP (port 5921)
                             │
                    ┌────────▼────────┐
                    │    Gateway      │
                    │  (port 5921)    │
                    │   [Exposed]     │
                    └────────┬────────┘
                             │
                    ┌────────┴────────┐
                    │                 │
         ┌──────────▼──────────┐      │
         │   Private Network   │      │
         │  (Docker Network)   │      │
         └──────────┬──────────┘      │
                    │                 │
         ┌──────────┴──────────┐      │
         │                     │      │
    ┌────▼────┐         ┌──────▼──────┐
    │ Backend │         │   MongoDB   │
    │(port    │◄────────┤  (port      │
    │ 3847)   │         │  27017)     │
    │[Not     │         │ [Not        │
    │Exposed] │         │ Exposed]    │
    └─────────┘         └─────────────┘
```

**Security Architecture:**
- ✅ Gateway is the ONLY service exposed externally (port 5921)
- ✅ Backend and MongoDB are isolated in a private Docker network
- ✅ No direct external access to Backend (port 3847) or MongoDB (port 27017)
- ✅ All requests must go through the Gateway

## 📁 Project Structure

```
.
├── backend/
│   ├── Dockerfile              # Production optimized build
│   ├── Dockerfile.dev          # Development with hot reload
│   ├── package.json
│   ├── tsconfig.json
│   └── src/
│       ├── index.ts
│       ├── config/
│       ├── models/
│       ├── routes/
│       └── types/
├── gateway/
│   ├── Dockerfile              # Production optimized build
│   ├── Dockerfile.dev          # Development with hot reload
│   ├── package.json
│   └── src/
│       └── gateway.js
├── docker/
│   ├── compose.development.yaml    # Dev environment config
│   └── compose.production.yaml     # Production config
├── Makefile                    # Complete CLI automation
├── .env.example               # Environment template
├── .gitignore                # Security: excludes .env
├── .dockerignore             # Optimized Docker builds
└── README.md
```

## 🚀 Quick Start

### Prerequisites

- Docker (v20.10+)
- Docker Compose (v2.0+)
- Make (optional, but recommended)

### Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/bongodev/cuet-cse-fest-devops-hackathon-preli.git
   cd cuet-cse-fest-devops-hackathon-preli
   ```

2. **Configure environment variables**
   ```bash
   cp .env.example .env
   ```
   
   Edit `.env` and set your MongoDB password:
   ```env
   MONGO_INITDB_ROOT_USERNAME=admin
   MONGO_INITDB_ROOT_PASSWORD=allideasfromai
   MONGO_URI=mongodb://admin:allideasfromai@mongo:27017
   MONGO_DATABASE=ecommerce
   BACKEND_PORT=3847
   GATEWAY_PORT=5921
   NODE_ENV=development
   ```

3. **Start development environment**
   ```bash
   make dev-up
   ```
   
   Or without Make:
   ```bash
   docker compose -f docker/compose.development.yaml --env-file .env up -d
   ```

4. **Check service health**
   ```bash
   make health
   ```

## 🎯 Available Commands

### Using Makefile (Recommended)

#### Development Commands
```bash
make dev-up           # Start development environment
make dev-down         # Stop development environment
make dev-build        # Build development containers
make dev-logs         # View development logs
make dev-restart      # Restart development services
make dev-shell        # Open shell in backend container
make dev-ps           # Show running containers
```

#### Production Commands
```bash
make prod-up          # Start production environment
make prod-down        # Stop production environment
make prod-build       # Build production containers
make prod-logs        # View production logs
make prod-restart     # Restart production services
```

#### Database Commands
```bash
make mongo-shell      # Open MongoDB shell
make db-backup        # Backup MongoDB database
make db-reset         # Reset database (WARNING: deletes all data)
```

#### Utility Commands
```bash
make health           # Check service health
make backend-shell    # Open backend container shell
make gateway-shell    # Open gateway container shell
make clean            # Remove containers and networks
make clean-all        # Remove everything (containers, networks, volumes, images)
make help             # Display all available commands
```

### Without Make

#### Development
```bash
docker compose -f docker/compose.development.yaml --env-file .env up -d
docker compose -f docker/compose.development.yaml --env-file .env down
docker compose -f docker/compose.development.yaml --env-file .env logs -f
```

#### Production
```bash
docker compose -f docker/compose.production.yaml --env-file .env up -d
docker compose -f docker/compose.production.yaml --env-file .env down
docker compose -f docker/compose.production.yaml --env-file .env logs -f
```

## 🧪 Testing the Implementation

### Health Checks

1. **Check Gateway health:**
   ```bash
   curl http://localhost:5921/health
   ```
   Expected: `{"ok":true}`

2. **Check Backend health via Gateway:**
   ```bash
   curl http://localhost:5921/api/health
   ```
   Expected: `{"ok":true}`

### Product Management

1. **Create a product:**
   ```bash
   curl -X POST http://localhost:5921/api/products \
     -H 'Content-Type: application/json' \
     -d '{"name":"Test Product","price":99.99}'
   ```

2. **Get all products:**
   ```bash
   curl http://localhost:5921/api/products
   ```

### Security Verification

**Verify Backend is NOT directly accessible (should fail):**
```bash
curl http://localhost:3847/api/products
```
Expected: Connection refused or timeout (Backend is not exposed externally)

## 🔒 Security Features

### 1. Network Isolation
- Backend and MongoDB run on an isolated Docker network
- Only Gateway is exposed to the public network
- Zero external access to internal services

### 2. Docker Image Security
- Multi-stage builds for minimal production images
- Non-root user execution in containers
- Read-only filesystem where possible
- Security options: `no-new-privileges`

### 3. Secret Management
- `.env` file excluded from git via `.gitignore`
- `.env.example` template without actual secrets
- Environment-based configuration

### 4. Production Hardening
- Resource limits (CPU & memory)
- Health checks for all services
- Automatic restart policies
- Tmpfs mounts for temporary data

## 🎨 Docker Optimizations

### Production Dockerfiles
- **Multi-stage builds**: Separate build and runtime stages
- **Layer caching**: Strategic COPY ordering for faster rebuilds
- **Minimal base images**: Alpine Linux (node:20-alpine)
- **Production dependencies only**: `npm ci --only=production`
- **Cache cleaning**: `npm cache clean --force`

### Development Dockerfiles
- Hot reload support (tsx watch / nodemon)
- Volume mounts for source code
- All dev dependencies included
- Faster iteration cycles

### Docker Compose
- **Health checks**: Ensures services start in correct order
- **Depends_on with conditions**: Smart startup sequencing
- **Named volumes**: Persistent data across restarts
- **Resource limits**: Prevents resource exhaustion

## 📊 Data Persistence

MongoDB data persists across container restarts using named Docker volumes:

**Development:**
- `ecommerce-mongo-data-dev`
- `ecommerce-mongo-config-dev`

**Production:**
- `ecommerce-mongo-data-prod`
- `ecommerce-mongo-config-prod`

To reset data: `make db-reset MODE=dev` or `make db-reset MODE=prod`

## 🔧 Development Workflow

1. **Start services:**
   ```bash
   make dev-up
   ```

2. **View logs:**
   ```bash
   make dev-logs
   ```

3. **Make code changes** - Changes auto-reload in containers

4. **Test your changes:**
   ```bash
   make health
   curl http://localhost:5921/api/products
   ```

5. **Debug in container:**
   ```bash
   make backend-shell
   # or
   make gateway-shell
   ```

6. **Stop services:**
   ```bash
   make dev-down
   ```

## 🚢 Production Deployment

1. **Build production images:**
   ```bash
   make prod-build
   ```

2. **Update .env for production:**
   ```env
   NODE_ENV=production
   MONGO_INITDB_ROOT_PASSWORD=<strong-password>
   ```

3. **Start production environment:**
   ```bash
   make prod-up
   ```

4. **Monitor services:**
   ```bash
   make prod-logs
   make health
   ```

## 📝 Environment Variables

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `MONGO_INITDB_ROOT_USERNAME` | MongoDB admin username | `admin` | ✅ |
| `MONGO_INITDB_ROOT_PASSWORD` | MongoDB admin password | - | ✅ |
| `MONGO_URI` | MongoDB connection string | - | ✅ |
| `MONGO_DATABASE` | Database name | `ecommerce` | ✅ |
| `BACKEND_PORT` | Backend service port | `3847` | ✅ (DO NOT CHANGE) |
| `GATEWAY_PORT` | Gateway service port | `5921` | ✅ (DO NOT CHANGE) |
| `NODE_ENV` | Environment mode | `development` | ✅ |

## 🐛 Troubleshooting

### Services won't start
```bash
# Check if ports are already in use
netstat -an | findstr "5921"
netstat -an | findstr "3847"

# Clean and restart
make clean
make dev-up
```

### Cannot connect to services
```bash
# Check container status
make dev-ps

# Check logs
make dev-logs

# Check network
docker network ls
docker network inspect ecommerce-network-dev
```

### Database connection issues
```bash
# Check MongoDB logs
make dev-logs SERVICE=mongo

# Reset database
make db-reset
```

### Permission issues
```bash
# Clean volumes and restart
make clean-volumes
make dev-up
```

## 📚 Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Best Practices](https://docs.docker.com/compose/production/)
- [Node.js Docker Best Practices](https://github.com/nodejs/docker-node/blob/main/docs/BestPractices.md)
- [MongoDB Docker Setup](https://hub.docker.com/_/mongo)

## 📄 License

This project is part of the CUET CSE Fest DevOps Hackathon.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

---

**Made with ❤️ for CUET CSE Fest DevOps Hackathon**


## Project Structure

**DO NOT CHANGE THE PROJECT STRUCTURE.** The following structure must be maintained:

```
.
├── backend/
│   ├── Dockerfile
│   ├── Dockerfile.dev
│   └── src/
├── gateway/
│   ├── Dockerfile
│   ├── Dockerfile.dev
│   └── src/
├── docker/
│   ├── compose.development.yaml
│   └── compose.production.yaml
├── Makefile
└── README.md
```

## Environment Variables

Create a `.env` file in the root directory with the following variables (do not commit actual values):

```env
MONGO_INITDB_ROOT_USERNAME=
MONGO_INITDB_ROOT_PASSWORD=
MONGO_URI=
MONGO_DATABASE=
BACKEND_PORT=3847 # DO NOT CHANGE
GATEWAY_PORT=5921 # DO NOT CHANGE 
NODE_ENV=
```

## Expectations (Open ended, DO YOUR BEST!!!)

- Separate Dev and Prod configs
- Data Persistence
- Follow security basics (limit network exposure, sanitize input) 
- Docker Image Optimization
- Makefile CLI Commands for smooth dev and prod deploy experience (TRY TO COMPLETE THE COMMANDS COMMENTED IN THE Makefile)

**ADD WHAT EVER BEST PRACTICES YOU KNOW**

## Testing

Use the following curl commands to test your implementation.

### Health Checks

Check gateway health:
```bash
curl http://localhost:5921/health
```

Check backend health via gateway:
```bash
curl http://localhost:5921/api/health
```

### Product Management

Create a product:
```bash
curl -X POST http://localhost:5921/api/products \
  -H 'Content-Type: application/json' \
  -d '{"name":"Test Product","price":99.99}'
```

Get all products:
```bash
curl http://localhost:5921/api/products
```

### Security Test

Verify backend is not directly accessible (should fail or be blocked):
```bash
curl http://localhost:3847/api/products
```

## Submission Process

1. **Fork the Repository**
   - Fork this repository to your GitHub account
   - The repository must remain **private** during the contest

2. **Make Repository Public**
   - In the **last 5 minutes** of the contest, make your repository **public**
   - Repositories that remain private after the contest ends will not be evaluated

3. **Submit Repository URL**
   - Submit your repository URL at [arena.bongodev.com](https://arena.bongodev.com)
   - Ensure the URL is correct and accessible

4. **Code Evaluation**
   - All submissions will be both **automated and manually evaluated**
   - Plagiarism and code copying will result in disqualification

## Rules

- ⚠️ **NO COPYING**: All code must be your original work. Copying code from other participants or external sources will result in immediate disqualification.

- ⚠️ **NO POST-CONTEST COMMITS**: Pushing any commits to the git repository after the contest ends will result in **disqualification**. All work must be completed and committed before the contest deadline.

- ✅ **Repository Visibility**: Keep your repository private during the contest, then make it public in the last 5 minutes.

- ✅ **Submission Deadline**: Ensure your repository is public and submitted before the contest ends.

Good luck!

