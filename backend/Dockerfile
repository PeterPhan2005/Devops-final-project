# ─────────────────────────────────────────────────────────
# Stage 1: Build
# ─────────────────────────────────────────────────────────
FROM eclipse-temurin:21-jdk-alpine AS builder

WORKDIR /app

# Copy dependency files first (better Docker cache)
COPY pom.xml .

# Download and cache dependencies
RUN apk add --no-cache maven && \
    mvn dependency:go-offline -B

# Copy source code
COPY src ./src

# Build the application
RUN mvn package -DskipTests -B

# ─────────────────────────────────────────────────────────
# Stage 2: Runtime
# ─────────────────────────────────────────────────────────
FROM eclipse-temurin:21-jre-alpine

WORKDIR /app

# Install curl for healthcheck (Alpine doesn't include it by default)
RUN apk add --no-cache curl

# Create non-root user for security
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
RUN mkdir -p /app/uploads && chown -R appuser:appgroup /app

COPY --from=builder /app/target/*.jar app.jar

# Switch to non-root user
USER appuser

EXPOSE 8080

# JVM tuning: limit memory, enable exit on OOM for Kubernetes
ENTRYPOINT ["sh", "-c", "java -XX:+ExitOnOutOfMemoryError -Xms128m -Xmx512m -jar app.jar"]
