
# Builder stage
FROM openjdk:17-jdk-alpine AS builder
WORKDIR application
ARG JAR_FILE=target/*.jar
COPY ${JAR_FILE} application.jar
RUN java -Djarmode=layertools -jar application.jar extract

# Final stage
FROM openjdk:17-jdk-alpine
WORKDIR application

# Set JAVA_TOOL_OPTIONS environment variable for debugging
ENV JAVA_TOOL_OPTIONS="-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5005"

COPY --from=builder application/dependencies/ ./
COPY --from=builder application/spring-boot-loader/ ./
COPY --from=builder application/snapshot-dependencies/ ./
COPY --from=builder application/application/ ./
ENTRYPOINT ["java", "org.springframework.boot.loader.launch.JarLauncher"]
EXPOSE 8080 5005


## Builder stage
#FROM maven:3.8.1-openjdk-17-slim as builder
##COPY . .
##RUN mvn clean package -DskipTests
#WORKDIR application
#ARG JAR_FILE=target/*.jar
#COPY ${JAR_FILE} application.jar
#RUN java -Djarmode=layertools -jar application.jar extract
#
## Final stage
#FROM openjdk:17-jdk-slim
##COPY --from=builder /target/ChildVaccinationDiary-0.0.1-SNAPSHOT.jar app.jar
##EXPOSE 8080
##ENTRYPOINT ["java","-jar","app.jar"]
##WORKDIR application
##ENV JAVA_TOOL_OPTIONS="-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005"
##COPY --from=builder application/dependencies/ ./
##COPY --from=builder application/spring-boot-loader/ ./
##COPY --from=builder application/snapshot-dependencies/ ./
##COPY --from=builder application/application/ ./
##ENTRYPOINT ["java", "org.springframework.boot.loader.launch.JarLauncher"]
##EXPOSE 8080
