void setBuildStatus(String sha_test) {
    
    
    withCredentials([string(credentialsId: 'github-commit-status-token', variable: 'TOKEN')]) {
        // echo "$message"
        sh '''
            set -x
            sha=$(git log -1 --pretty=%H)
            echo $sha
            curl \\
            -H "Accept: application/vnd.github+json" \\
            -H "Authorization: Bearer $TOKEN" \\
            -H "X-GitHub-Api-Version: 2022-11-28" \\
            https://api.github.com/repos/$GIT_REPOSITORY/commits/$sha/branches-where-head
        '''
    }
}

pipeline {
    agent any
    options {
        buildDiscarder(logRotator(numToKeepStr: '5', artifactNumToKeepStr: '5'))
        timestamps()
    }
    environment {
        GIT_REPOSITORY = 'CodePathfinder/multibranch-pipeline'
    }
    stages {
        stage('Git Checkout'){
            steps{
                git branch: 'main',
                credentialsId: 'githublogin',
                url: "git@github.com:${GIT_REPOSITORY}.git"
            }
        }
        stage('Test commit message') {
            steps {
                // setBuildStatus("Checking commit message", "checking", "pending");
                script {
                    try {
                        sh '''
                        SHA=$(git log -1 --pretty=%H)
                        COMMIT_MESSAGE=$(git log -1 --pretty=%s)
                        count=$(echo $COMMIT_MESSAGE | sed -n \'/^[A-Z]\\{1,5\\}-[0-9]\\{1,5\\} /p\' | sed \'s/ //g\' | wc -c)
                        if [ "$count" -ge "10" -a "$count" -le "72" ]; then
                            echo "Message $COMMIT_MESSAGE for commit $SHA looks fine!"
                            exit 0
                        else
                            echo "Message $COMMIT_MESSAGE for commit $SHA does not comply with the following format: <ticket><space><message>, where ticket shall consist of 1 to 5 CAPITAL_LETTERS, then \'-\', then 1 to 5 digits. The total message length shall be between 10 and 72 symbols excluding spaces."
                            exit 1
                        fi
                        '''
                        setBuildStatus("655475a9abd2489c35e2efdba80634d3ece42efa");
                    } catch (err) {
                        echo "ERROR"
                        // setBuildStatus("Commit message does not comply with the required format!", "checked", "failure");
                        throw err
                    }
                }
            }
        }
    }
}
