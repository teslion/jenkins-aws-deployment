#!/bin/bash

#If you have a job defined, change this env variable to the desired job name. And uncomment lines below.
export JOB_NAME=jenkins_job


export JENKINS_CREDENTIALS=administrator:topsecretpassword
export JENKINS_HOST=http://127.0.0.1:8080/
sudo wget localhost:8080/jnlpJars/jenkins-cli.jar -O /jenkins-cli.jar
sudo java -jar /jenkins-cli.jar -s $JENKINS_HOST -auth $JENKINS_CREDENTIALS install-plugin credentials
sudo java -jar /jenkins-cli.jar -s $JENKINS_HOST -auth $JENKINS_CREDENTIALS install-plugin credentials-binding
sudo java -jar /jenkins-cli.jar -s $JENKINS_HOST -auth $JENKINS_CREDENTIALS install-plugin timestamper
sudo java -jar /jenkins-cli.jar -s $JENKINS_HOST -auth $JENKINS_CREDENTIALS install-plugin workflow-aggregator
sudo java -jar /jenkins-cli.jar -s $JENKINS_HOST -auth $JENKINS_CREDENTIALS install-plugin github-branch-source
sudo java -jar /jenkins-cli.jar -s $JENKINS_HOST -auth $JENKINS_CREDENTIALS install-plugin pipeline-github-lib
sudo java -jar /jenkins-cli.jar -s $JENKINS_HOST -auth $JENKINS_CREDENTIALS install-plugin pipeline-stage-view
sudo java -jar /jenkins-cli.jar -s $JENKINS_HOST -auth $JENKINS_CREDENTIALS install-plugin git
sudo java -jar /jenkins-cli.jar -s $JENKINS_HOST -auth $JENKINS_CREDENTIALS install-plugin github
sudo java -jar /jenkins-cli.jar -s $JENKINS_HOST -auth $JENKINS_CREDENTIALS install-plugin matrix-auth
sudo java -jar /jenkins-cli.jar -s $JENKINS_HOST -auth $JENKINS_CREDENTIALS install-plugin pam-auth
sudo java -jar /jenkins-cli.jar -s $JENKINS_HOST -auth $JENKINS_CREDENTIALS install-plugin ssh-agent
sudo java -jar /jenkins-cli.jar -s $JENKINS_HOST -auth $JENKINS_CREDENTIALS install-plugin ssh-slaves
sudo java -jar /jenkins-cli.jar -s $JENKINS_HOST -auth $JENKINS_CREDENTIALS install-plugin packer
sudo java -jar /jenkins-cli.jar -s $JENKINS_HOST -auth $JENKINS_CREDENTIALS install-plugin cloudbees-credentials
sudo java -jar /jenkins-cli.jar -s $JENKINS_HOST -auth $JENKINS_CREDENTIALS install-plugin generic-webhook-trigger
sudo java -jar /jenkins-cli.jar -s $JENKINS_HOST -auth $JENKINS_CREDENTIALS install-plugin favorite-view
sudo java -jar /jenkins-cli.jar -s $JENKINS_HOST -auth $JENKINS_CREDENTIALS install-plugin github-oauth
sudo java -jar /jenkins-cli.jar -s $JENKINS_HOST -auth $JENKINS_CREDENTIALS install-plugin ghprb
sudo java -jar /jenkins-cli.jar -s $JENKINS_HOST -auth $JENKINS_CREDENTIALS install-plugin google-play-android-publisher
sudo java -jar /jenkins-cli.jar -s $JENKINS_HOST -auth $JENKINS_CREDENTIALS install-plugin gradle
sudo java -jar /jenkins-cli.jar -s $JENKINS_HOST -auth $JENKINS_CREDENTIALS install-plugin jobConfigHistory
sudo java -jar /jenkins-cli.jar -s $JENKINS_HOST -auth $JENKINS_CREDENTIALS install-plugin kubernetes-credentials
sudo java -jar /jenkins-cli.jar -s $JENKINS_HOST -auth $JENKINS_CREDENTIALS install-plugin msbuild
sudo java -jar /jenkins-cli.jar -s $JENKINS_HOST -auth $JENKINS_CREDENTIALS install-plugin pipeline-maven
sudo java -jar /jenkins-cli.jar -s $JENKINS_HOST -auth $JENKINS_CREDENTIALS install-plugin workflow-aggregator
sudo java -jar /jenkins-cli.jar -s $JENKINS_HOST -auth $JENKINS_CREDENTIALS install-plugin pipeline-aws
sudo java -jar /jenkins-cli.jar -s $JENKINS_HOST -auth $JENKINS_CREDENTIALS install-plugin testng-plugin
sudo java -jar /jenkins-cli.jar -s $JENKINS_HOST -auth $JENKINS_CREDENTIALS install-plugin variant
sudo java -jar /jenkins-cli.jar -s $JENKINS_HOST -auth $JENKINS_CREDENTIALS install-plugin ws-cleanup
sudo java -jar /jenkins-cli.jar -s $JENKINS_HOST -auth $JENKINS_CREDENTIALS install-plugin xunit
sudo java -jar /jenkins-cli.jar -s $JENKINS_HOST -auth $JENKINS_CREDENTIALS install-plugin docker-workflow
sudo java -jar /jenkins-cli.jar -s $JENKINS_HOST -auth $JENKINS_CREDENTIALS install-plugin git-parameter
sudo java -jar /jenkins-cli.jar -s $JENKINS_HOST -auth $JENKINS_CREDENTIALS install-plugin docker-build-publish

sudo java -jar /jenkins-cli.jar -s $JENKINS_HOST -auth $JENKINS_CREDENTIALS restart
sleep 30

#If you have added the Jenkins job, copied it over to "job.xml", feel free to uncomment the line below
#  sudo cat /tmp/packer_job.xml | sudo java -jar /jenkins-cli.jar -s $JENKINS_HOST -auth $JENKINS_CREDENTIALS create-job $JOB_NAME

#If you want to immediatly start the job, uncomment the line below
#  sudo java -jar /jenkins-cli.jar -s $JENKINS_HOST -auth $JENKINS_CREDENTIALS build $JOB_NAME

#cleanup
sudo rm /var/lib/jenkins/init.groovy.d/init.groovy
sudo rmdir /var/lib/jenkins/init.groovy.d
rm /tmp/job.xml
rm /tmp/jenkins_config.sh
rm /tmp/instance_config.sh
unset JENKINS_CREDENTIALS
unset JENKINS_HOST
