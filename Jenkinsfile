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
	environment {
        SONARSERVER = 'sonarserver'
        SONARSCANNER = 'sonarscanner'
        REGISTRY_CREDENTIAL = 'dockerhub-creds'
        APP_IMG_NAME = 'gamdckr/vproappimg'
        REGISTRY_URL = "https://index.docker.io/v1/"
    }
    stages {
        stage('CLEAN WORKSPACE') {
            steps {
                echo 'Deleting workspace'
                deleteDir()
            }
        }
        stage('Git Checkout'){
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
        stage ('CHECKSTYLE ANALYSIS'){
            steps {
                sh 'mvn checkstyle:checkstyle'
            }
        }
        stage('SONAR ANALYSIS') {
          
            environment {
                scannerHome = tool "${SONARSCANNER}"
            }

            steps {
                withSonarQubeEnv("${SONARSERVER}") {
                    sh '''${scannerHome}/bin/sonar-scanner -Dsonar.projectKey=vprofile \
                    -Dsonar.projectName=vprofile \
                    -Dsonar.projectVersion=1.0 \
                    -Dsonar.sources=src/ \
                    -Dsonar.java.binaries=target/test-classes/com/visualpathit/account/controllerTest/ \
                    -Dsonar.junit.reportsPath=target/surefire-reports/ \
                    -Dsonar.jacoco.reportsPath=target/jacoco.exec \
                    -Dsonar.java.checkstyle.reportPaths=target/checkstyle-result.xml'''
                }
            }
        }
        stage('QUALITY GATE') { 
            steps {
                timeout(time: 30, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }
        stage('BUILD IMAGE') {
            steps {
                script {
                    dockerImage = docker.build(APP_IMG_NAME + ":$BUILD_NUMBER", "./")
                }
            }
        }
        stage('PUSH IMAGE') {
            steps{
                script {
                    withDockerRegistry(credentialsId: "$REGISTRY_CREDENTIAL", url: "$REGISTRY_URL") {
                        dockerImage.push("$BUILD_NUMBER")
                        dockerImage.push('latest')
                    }
                }
            }
        }
        stage('DELETE IMAGE LOCALLY') {
            steps{
                sh "docker rmi $APP_IMG_NAME:$BUILD_NUMBER"
            }
        }
    }
    post {
        success {
            emailext body: "Job ${env.JOB_NAME} build ${env.BUILD_NUMBER}\nSee detailed info at: ${env.BUILD_URL} or in the attached logfile", 
                subject: 'Job Completion Notification',
                to: 'gamolchanov@gmail.com',
                attachLog: true
        }
    }
}
