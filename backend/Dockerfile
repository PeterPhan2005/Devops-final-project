# ─────────────────────────────────────────────────────────
# Stage 1: Build
# ─────────────────────────────────────────────────────────
FROM maven:3.9-eclipse-temurin-21 AS builder

WORKDIR /app

# Copy dependency files first (better Docker cache)
COPY pom.xml .

# Download and cache dependencies
RUN mvn dependency:go-offline -B

# Copy source code
COPY src ./src

# Build the application
RUN mvn package -DskipTests -B

# ─────────────────────────────────────────────────────────
# Stage 2: Runtime
# ─────────────────────────────────────────────────────────
FROM eclipse-temurin:21-jre-alpine

WORKDIR /app

# Install curl for healthcheck
RUN apk add --no-cache curl

# Create app user and uploads directory
RUN addgroup -S appgroup && adduser -S appuser -G appgroup && \
    mkdir -p /app/uploads && chown -R appuser:appgroup /app

COPY --from=builder /app/target/*.jar app.jar

# Run as root so bind mount file sharing works with macOS host
# For prod deployment, change to: USER appuser
USER root
RUN chmod 777 /app/uploads

EXPOSE 8080

# JVM tuning: limit memory, enable exit on OOM for Kubernetes
ENTRYPOINT ["sh", "-c", "java -XX:+ExitOnOutOfMemoryError -Xms128m -Xmx512m -jar app.jar"]
