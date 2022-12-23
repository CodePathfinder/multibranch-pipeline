FROM tomcat
LABEL "Project"="Vprofile"

RUN rm -rf /usr/local/tomcat/webapps/*
COPY target/vprofile-v2.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 
CMD ["catalina.sh", "run"]
