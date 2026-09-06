FROM eclipse-temurin:26-jre

RUN apt-get update \
    && apt-get install -y wget \
    && rm -rf /var/lib/apt/lists/*

ENV CATALINA_HOME=/usr/local/tomcat
ENV PATH=$CATALINA_HOME/bin:$PATH

RUN mkdir -p "$CATALINA_HOME"

WORKDIR "$CATALINA_HOME"

RUN wget https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.88/bin/apache-tomcat-9.0.88.tar.gz \
    -O tomcat.tar.gz \
    && tar -xzf tomcat.tar.gz --strip-components=1 \
    && rm tomcat.tar.gz

RUN rm -rf "$CATALINA_HOME/webapps/*"

COPY ORDEXA.war "$CATALINA_HOME/webapps/ROOT.war"

EXPOSE 8080

CMD ["catalina.sh", "run"]
