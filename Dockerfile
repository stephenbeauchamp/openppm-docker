
# // TO BUILD A LOCAL DOCKER IMAGE
# //   $ sudo docker build -t stephenbeauchamp/openppm .
# // RUN FROM LOCAL IMAGE
# //   $ sudo docker run --name openppm -d -p 8080:8080 stephenbeauchamp/openppm:latest

# // GIT HUB REPO: https://github.com/stephenbeauchamp/openppm-docker
# // DOCKER HUB REP: https://hub.docker.com/r/stephenbeauchamp/openppm

# // FURTHER ENHANCMENTS COULD BE
# //   - general enhacements
# //     - security, set random passwords for mysql root and openppm users
# //     - review tomcat startup warnings and ensure a clean start
# //     - enhance the container to use a volume for easy backup, restore, config from host
# //     - look into OpenPPM plugins
# //     - place in public docker repo
# //     - implement root redirection to /openppm/ [DONE!]
# //     - provide a mock data script, to set up demo users and projects
# //
# //   - get ready for production
# //     - work out upgrade path and examples
# //
# //   - maintenace
# //     - new versions of Centos (or other Linux flavors)
# //     - latest jdk
# //     - latest tomcat
# //     - latest OpenPPM

FROM centos:7.6.1810

SHELL ["/bin/bash","-c"]

RUN  yum update -y && \
     yum install mariadb-server java-1.7.0-openjdk-headless tomcat unzip -y && \
     mkdir /var/lib/tomcat/webapps/ROOT/ && \
     echo "<html><head> <meta http-equiv=\"refresh\" content=\"0;url=/openppm/\"/></head><body>You are being redirected to OpenPPM</body></html>" > /var/lib/tomcat/webapps/ROOT/index.jsp && \
     chown -R tomcat.tomcat /var/lib/tomcat/webapps/ROOT/ && \
     curl https://jaist.dl.sourceforge.net/project/openppm/Talaia%20OpenPPM%20Cell%204.6.1.zip --output /tmp/openppm-4.6.1.zip && \
     unzip -d /tmp/openppm-4.6.1/ /tmp/openppm-4.6.1.zip && \
     echo -e "[mysqld]\nbind-address=0.0.0.0\nconsole=1\ngeneral_log=1\ngeneral_log_file=/dev/stdout\nlog_error=/dev/stderr\ncollation-server=utf8_unicode_ci\ncharacter-set-server=utf8" > /etc/my.cnf.d/server.cnf && \
     chown -R mysql:mysql /var/lib/mysql && \
     su -l -s /bin/bash -c "mysql_install_db --user mysql" mysql && \
     ( mysqld_safe --user mysql & ) && \
     sleep 5 && \
     mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;" mysql && \
     mysql -e "DELETE FROM mysql.user WHERE User='';" mysql && \
     mysql -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');" mysql && \
     mysql -e "DROP DATABASE IF EXISTS test;" mysql && \
     mysql -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';" mysql && \
     mysql -e "FLUSH PRIVILEGES;" mysql && \
     mysql -e "CREATE DATABASE openppm;" mysql && \
     mysql -e "GRANT ALL PRIVILEGES ON openppm.* TO 'openppm'@'localhost' IDENTIFIED BY 'openppm';" mysql && \
     mysql < /tmp/openppm-4.6.1/CreateDB.sql && \
     cp /tmp/openppm-4.6.1/mariadb-java-client-1.1.8.jar /usr/share/tomcat/lib/ && \
     cp /tmp/openppm-4.6.1/jaas.config /usr/share/tomcat/conf/ && \
     cp /tmp/openppm-4.6.1/openppm.war /usr/share/tomcat/webapps/ && \
     cp /tmp/openppm-4.6.1/openppm.xml /etc/tomcat/Catalina/localhost/ && \
     sed -i "s/auth=\"Container\"/auth=\"Container\"\ factory=\"org.apache.commons.dbcp.BasicDataSourceFactory\"/" /etc/tomcat/Catalina/localhost/openppm.xml && \
     ( mysqld_safe --user mysql & ) && \
     sleep 10 && \
     ( su -l -s /bin/bash -c "JAVA_OPTS=\"-Djava.security.auth.login.config=/usr/share/tomcat/conf/jaas.config -Dfile.encoding=UTF8 -Duser.timezone=Australia/Sydney -Xmx2048m -XX:MaxPermSize=512m\" /usr/libexec/tomcat/server start" tomcat & ) && \
     sleep 60

EXPOSE 8080 3306

CMD  ( mysqld_safe --user mysql & ) && \
     sleep 10 && \
     su -l -s /bin/bash -c "JAVA_OPTS=\"-Djava.security.auth.login.config=/usr/share/tomcat/conf/jaas.config -Dfile.encoding=UTF8 -Duser.timezone=Australia/Sydney -Xmx2048m -XX:MaxPermSize=512m\" /usr/libexec/tomcat/server start" tomcat
