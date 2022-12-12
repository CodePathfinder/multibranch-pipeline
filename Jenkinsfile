pipeline {
	agent any
	tools {
        maven "MAVEN3"
        jdk "OracleJDK8"
    }	
	environment {
        SONARSERVER = 'sonarserver'
        SONARSCANNER = 'sonarscanner'
        REGISTRY_CREDENTIAL = 'dockerhub-creds'
        APP_IMG_REPOSITORY = 'gamdckr/vproappimg'
        IMAGE_REGISTRY = 'https://hub.docker.com/'
    }
    stages {
        stage('Git Checkout'){
            steps{
                git branch: 'ci-build-dockerhub',
                credentialsId: 'githublogin',
                url: 'git@github.com:CodePathfinder/vproject.git'
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
                    dockerImage = docker.build(APP_IMG_REPOSITORY + ":$BUILD_NUMBER", "./Dockerfile")
                }
            }
        }
        stage('PUSH IMAGE') {
            steps{
                script {
                    docker.withRegistry(IMAGE_REGISTRY, REGISTRY_CREDENTIAL) {
                        dockerImage.push("$BUILD_NUMBER")
                        dockerImage.push('latest')
                    }
                }
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
