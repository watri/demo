# Stage 1: Build the application with Maven
FROM maven:3.8.4-openjdk-11 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn dependency:go-offline
RUN mvn clean package -DskipTests && \
    rm -rf /app/target/classes

# Stage 2: Create a lightweight image to run the application
FROM adoptopenjdk:11-jre-hotspot-bionic as final
WORKDIR /app
COPY --from=build /app/target/demo-dcid-SNAPSHOT.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]