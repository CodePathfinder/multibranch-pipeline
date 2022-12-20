pipeline {
	agent {
        label 'master'
    }
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
                echo 'Create artifact .war'
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
                echo 'Unittests are run'
            }
        }
        stage('FOR FEATURE BRANCH ONLY'){
            when { 
                branch 'feature-*'
            }
            steps {
                sh '''
                cat README.md
                '''                
            }
        }
        stage('FOR THE PR'){
            when { 
                branch 'PR-*'
            }
            steps {
                echo 'This only runs for the PR' 
            }
        }
        stage('BUILD IMAGE') {
            steps {
                dockerImage = docker.build('vproimg' + ":$BUILD_NUMBER", "./")
                echo 'Create dockerimage'
            }
        }
    }
}
