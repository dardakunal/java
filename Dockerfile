FROM tomcat:alpine
MAINTAINER your_name
# COPY path-to-your-application-war path-to-webapps-in-docker-tomcat
ADD **/*.war /usr/local/tomcat/webapps/
