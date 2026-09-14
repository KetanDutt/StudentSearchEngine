# FindinG - Production Dockerfile
FROM maven:3.9-eclipse-temurin-11 AS build
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline -B
COPY src ./src
COPY WEB-INF ./WEB-INF
COPY *.html *.jsp css js images ./
# Build war
RUN mvn clean package -DskipTests

FROM tomcat:9-jdk11
LABEL maintainer="Ketan Dutt <ketan6196@gmail.com>"
LABEL version="2.0.0"
LABEL description="FindinG - Student Search Engine Production Ready"

# Remove default apps
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy war
COPY --from=build /app/target/finding.war /usr/local/tomcat/webapps/ROOT.war

# Add health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD curl -f http://localhost:8080/ || exit 1

# Security: run as non-root
RUN groupadd -r tomcat && useradd -r -g tomcat tomcat
RUN chown -R tomcat:tomcat /usr/local/tomcat
USER tomcat

EXPOSE 8080
CMD ["catalina.sh", "run"]
