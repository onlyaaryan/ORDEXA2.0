# Stage 1: Use Tomcat server and deploy pre-built WAR
FROM tomcat:9.0-jre17

# Remove default root apps if needed
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy the pre-built WAR file into Tomcat webapps directory as ROOT.war
COPY ORDEXA.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080
CMD ["catalina.sh", "run"]
