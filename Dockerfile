# Build stage
FROM gradle:8.11-jdk21 AS build
WORKDIR /app

# Copy Gradle wrapper and configuration files
COPY gradle gradle
COPY gradlew .
COPY gradle.properties .
COPY settings.gradle.kts .

# Copy the app module build configuration
COPY app/build.gradle.kts app/

# Download dependencies (this layer will be cached)
RUN gradle :app:dependencies --no-daemon || true

# Copy source code
COPY app/src app/src

# Build the application (skip tests for faster builds)
RUN gradle :app:build -x test --no-daemon

# Runtime stage
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app

# Copy the built JAR from build stage
COPY --from=build /app/app/build/libs/*.jar app.jar

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
