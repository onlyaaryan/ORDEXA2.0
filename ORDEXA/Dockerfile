FROM eclipse-temurin:26-jre

# Install wget to download Tomcat
RUN apt-get update && apt-get install -y wget && rm -rf /var/lib/apt/lists/*

# Setup Tomcat environment
ENV CATALINA_HOME /usr/local/tomcat
ENV PATH $CATALINA_HOME/bin:$PATH
RUN mkdir -p "$CATALINA_HOME"
WORKDIR $CATALINA_HOME

# Download and extract Apache Tomcat 9
RUN wget https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.88/bin/apache-tomcat-9.0.88.tar.gz -O tomcat.tar.gz \
    && tar -xvf tomcat.tar.gz --strip-components=1 \
    && rm tomcat.tar.gz

# Remove default apps
RUN rm -rf webapps/*

# Copy your pre-built WAR file as ROOT.war
COPY ORDEXA.war webapps/ROOT.war

EXPOSE 8080
CMD ["catalina.sh", "run"]
