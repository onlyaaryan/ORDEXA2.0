# Stage 1: Build the WAR file inside Docker using Maven
FROM maven:3.9-eclipse-temurin-17 AS builder
WORKDIR /app
COPY . .
RUN mvn clean package -DskipTests

# Stage 2: Run Tomcat and deploy the generated WAR
FROM eclipse-temurin:26-jdk

RUN apt-get update && apt-get install -y wget tar && rm -rf /var/lib/apt/lists/*

RUN wget https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.88/bin/apache-tomcat-9.0.88.tar.gz -O /tmp/tomcat.tar.gz \
    && mkdir -p /usr/local/tomcat \
    && tar -xzf /tmp/tomcat.tar.gz -C /usr/local/tomcat --strip-components=1 \
    && rm /tmp/tomcat.tar.gz

ENV CATALINA_HOME /usr/local/tomcat
ENV PATH $CATALINA_HOME/bin:$PATH

RUN rm -rf /usr/local/tomcat/webapps/*

COPY --from=builder /app/target/*.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080
CMD ["catalina.sh", "run"]