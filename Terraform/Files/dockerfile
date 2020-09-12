FROM jenkins/jenkins:latest

# Install the Jenkins Plugins

COPY ./jenkins-plugins /usr/share/jenkins/plugins
RUN while read i ; \ 
		do /usr/local/bin/install-plugins.sh $i ; \
	done < /usr/share/jenkins/plugins

ENV JENKINS_USER admin
ENV JENKINS_PASS admin

# Skip Jenkins setup wizard
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false

# Run  groovy files from init.groovy.d dir to create a default admin user
COPY default-user.groovy /usr/share/jenkins/ref/init.groovy.d/

# volume for Jenkins settings
VOLUME /var/jenkins_home
© 2020 GitHub, Inc.
