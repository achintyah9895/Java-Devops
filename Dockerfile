FROM tomcat:9.0.122-jre25-temurin-noble

RUN rm -rf /usr/local/tomcat/webapps/*

COPY target/01-maven-web-app*.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080

CMD ["catalina.sh", "run"]
