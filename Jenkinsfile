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
        stage('CHECK COMMIT MESSAGE'){
            steps{
                sh '''
                msg=$(git log -1 --pretty=%s) 
                echo $msg
                '''
            }
    	}
        stage('For feature branches'){
            when { 
                branch 'feature-*'
            }
            steps {
                sh '''
                cat README.md
                '''                
            }
        }
        stage('For dev branch'){
            when { 
                branch 'dev'
            }
            steps {
                echo 'This only runs for the PR' 
            }
        }
    }
}
