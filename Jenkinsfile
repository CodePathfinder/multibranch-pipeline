// Multi-branch pipeline (multibranch-pipeline-task2) with is triggered by manual scanning or automatically upon push
// of new commits to any branch in repository CodePathfinder/multibranch-pipeline [github webhook (push)].
// It can also track the newly created or deleted branches, check and deal with pull requests (PR), send check statuses
// to GitHub through GitHub API using github 'personal access token'

void setBuildStatus(String state, String message, String context) {
    withCredentials([string(credentialsId: 'github-commit-status-token', variable: 'TOKEN')]) {
        env.state="$state"
        env.message="$message"
        env.context="$context"
        sh '''
            set -x
            sha=$(git log -1 --pretty=%H)
            curl \\
            -X POST \\
            -H "Accept: application/vnd.github+json" \\
            -H "Authorization: Bearer $TOKEN" \\
            -H "X-GitHub-Api-Version: 2022-11-28" \\
            https://api.github.com/repos/$GIT_REPOSITORY/statuses/$sha \\
            -d \"{\\\"state\\\": \\\"${state}\\\", \\\"target_url\\\": \\\"$BUILD_URL\\\", \\\"description\\\": \\\"${message}\\\", \\\"context\\\": \\\"${context}\\\"}\"
        '''
    }
}

pipeline {
    agent {
        label 'master'
    }
    options {
        buildDiscarder(logRotator(numToKeepStr: '5', artifactNumToKeepStr: '5'))
        timestamps()
        skipDefaultCheckout()
    }
    environment {
        GIT_REPOSITORY = 'CodePathfinder/multibranch-pipeline'
    }
    stages {
        stage('CLEAN WORKSPACE') {
            steps {
                echo '=============== Deleting workspace =================='
                deleteDir()
            }
        }
        stage('Git Checkout'){
           steps{
                checkout scm
            }
        }
        stage('Test commit message') {
            when {
                not {
                    branch "main"
                }
            }
            steps {
                script {
                    echo '========== Test commit message for branches other then main ============'
                    sh '''
                    SHA=$(git log -1 --pretty=%H)
                    COMMIT_MESSAGE=$(git log -1 --pretty=%s)
                    count=$(echo $COMMIT_MESSAGE | sed -n \'/^[A-Z]\\{1,5\\}-[0-9]\\{1,5\\} /p\' | sed \'s/ //g\' | wc -c)
                    if [ "$count" -ge "10" -a "$count" -le "72" ]; then
                        echo "Message $COMMIT_MESSAGE for commit $SHA looks fine!"
                        exit 0
                    else
                        echo "Message $COMMIT_MESSAGE for commit $SHA does not comply with the required format"
                        exit 1
                    fi
                    '''
                }
            }
        }
        stage ("Lint dockerfile") {
            steps {
                echo '=========================  Lint dockerfile ========================='
                sh '''
                docker run --rm -i ghcr.io/hadolint/hadolint < Dockerfile | tee -a hadolint_lint.txt
                count=$(cat hadolint_lint.txt | grep -v style | wc -l)
                if [ "$count" -ge "1" ]; then
                    echo "Check hadolint_lint.txt and correct your Dockerfile"
                    exit 2
                fi
                '''
            }
            post {
                always {
                    archiveArtifacts 'hadolint_lint.txt'
                }
            }
        }
    }
    post {
        success {
            setBuildStatus('success', 'The build succeeded!', 'continuous-integration/jenkins');
        }
        failure {
            setBuildStatus('failure', 'The build failed!', 'continuous-integration/jenkins');
        }
    }
}
