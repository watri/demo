# Stage 1: Build the application with Maven
FROM eclipse-temurin:17-jdk-alpine AS builder
WORKDIR /opt/app

# Copy build files and dependencies
COPY .mvn/ .mvn
COPY mvnw pom.xml ./
RUN chmod +x ./mvnw
# Make Maven wrapper executable and download dependencies
RUN ./mvnw dependency:go-offline

# Copy source code and build the application
COPY ./src ./src
RUN ./mvnw clean install

# Stage 2: Final image for running the application
FROM eclipse-temurin:17-jre-alpine AS final
WORKDIR /opt/app

# Copy built JAR file from builder stage, ensuring ownership by appuser
COPY --from=builder /opt/app/target/demo-dcid-SNAPSHOT.jar /opt/app/app.jar
EXPOSE 80
ENTRYPOINT ["java", "-jar","-Dserver.port=80", "app.jar"]