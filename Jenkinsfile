pipeline {
	agent any
	options {
        buildDiscarder(logRotator(numToKeepStr: '5', artifactNumToKeepStr: '5'))
        timestamps()
        skipDefaultCheckout()
    }
	tools {
        maven "MAVEN3"
        jdk "OracleJDK8"
    }	
    stages {
        stage('CLEAN WORKSPACE') {
            steps {
                echo 'Deleting workspace'
                deleteDir()
            }
        }
        stage('GIT CHECKOUT'){
            steps{
                checkout scm
            }
    	}
        stage('MVN BUILD'){
            steps {
                sh 'mvn -DskipTests install'
            }
            post {
                success {
                    archiveArtifacts artifacts: '**/*.war'
                }
            }
        }
        stage('UNIT TEST'){
            steps {
                sh 'mvn test'
            }
        }
 
        stage('BUILD IMAGE') {
            steps {
                script {
                    dockerImage = docker.build(APP_IMG_NAME + ":$BUILD_NUMBER", "./")
                }
            }
        }
    }
}
