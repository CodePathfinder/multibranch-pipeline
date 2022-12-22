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
        stage('Test commit message') {
            steps {
                sh ''' msg=$(git log -1 --pretty=%s)
                    count=$(echo $msg | sed -n \'/^[A-Z]\\{1,5\\}-[0-9]\\{1,5\\} /p\' | sed \'s/ //g\' | wc -c)
                    if [ "$count" -ge "10" -a "$count" -le "72" ]; then
                        echo "Commit message looks fine!"
                        exit 0
                    else
                        echo "Commit message does not comply with the following format: <ticket><space><message>, where ticket shall consist of 1 to 5 CAPITAL_LETTERS, then \'-\', then 1 to 5 digits. The total message length shall be between 10 and 72 symbols excluding spaces."
                        exit 1
                    fi'''
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
