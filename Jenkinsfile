#!/usr/bin/groovy

// load pipeline functions
// Requires pipeline-github-lib plugin to load library from github

node {
  def app



  def pwd = pwd()
  def user_id = ''
  wrap([$class: 'BuildUser']) {
      echo "userId=${BUILD_USER_ID},fullName=${BUILD_USER},email=${BUILD_USER_EMAIL}"
      user_id = "${BUILD_USER_ID}"
  }

  sh "env"

  stage('Clone repository') {
      /* Let's make sure we have the repository cloned to our workspace */
      checkout scm
  }

  stage('Build image') {
    sh "make iso" 
  }

  stage('Move ISO to /tmp of the Jenkins CONTAINER') {
    sh "mv EDCOP-dev.iso /tmp/" 
  }
}
