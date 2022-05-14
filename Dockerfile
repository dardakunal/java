FROM tomcat:9.0.8-jre8-alpine
MAINTAINER your_name
# COPY path-to-your-application-war path-to-webapps-in-docker-tomcat
ADD **/*.war /usr/local/tomcat/webapps/
