# Stage 1: Build the application with Maven
FROM eclipse-temurin:17-jdk-jammy as builder
WORKDIR /opt/app
COPY .mvn/ .mvn
COPY mvnw pom.xml ./
RUN ./mvnw dependency:go-offline
COPY ./src ./src
RUN ./mvnw clean install

# Stage 2: final image for run the application
FROM eclipse-temurin:17-jre-jammy as final
RUN addgroup demogroup; adduser  --ingroup demogroup --disabled-password kerapuh
USER kerapuh
WORKDIR /opt/app
EXPOSE 8080
COPY --from=builder /opt/app/target/demo-dcid-SNAPSHOT.jar /opt/app/app.jar
ENTRYPOINT ["java", "-jar", "app.jar"]