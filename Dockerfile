# Stage 1: Build the application with Maven
FROM eclipse-temurin:17-jdk-alpine AS builder
WORKDIR /opt/app

# Create non-root user only once
RUN adduser -D appuser
USER appuser

# Copy build files and dependencies
COPY .mvn/ .mvn
COPY mvnw pom.xml ./
RUN ./mvnw dependency:go-offline
COPY ./src ./src
RUN ./mvnw clean install

# Stage 2: Final image for running the application
FROM eclipse-temurin:17-jre-alpine AS final

# Reuse non-root user from builder stage
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /etc/group /etc/group
USER appuser

WORKDIR /opt/app
EXPOSE 8080
COPY --from=builder --chown=appuser /opt/app/target/demo-dcid-SNAPSHOT.jar /opt/app/app.jar
ENTRYPOINT ["java", "-jar", "app.jar"]