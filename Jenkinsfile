pipeline {
    agent any
    environment {
        PATH = "$PATH:/usr/local/bin/"
    }
    triggers {
        GenericTrigger (
            causeString: 'Triggered on push', genericVariables: [[defaultValue: '', key: 'branch', regexpFilter: '', value: '$.push.changes[0].old.name']], printContributedVariables: true, printPostContent: true, regexpFilterExpression: '^(master)*?$', regexpFilterText: '$branch', token: 'demo', tokenCredentialId: ''
        )
    }
    stages {
        stage('Git Clone') {
            steps {
                cleanWs()
                checkout scmGit(branches: [[name: '*/master']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/watri/demo.git']])
            }
        }
        stage('Change jar version') {
            steps {
                sh '''
                #!/bin/bash
                sed -i "s|dcid|${BUILD_NUMBER}|g" pom.xml
                sed -i "s|dcid|${BUILD_NUMBER}|g" Dockerfile
                whoami
                '''
            }
        }
        stage('Dockerfie Scan Hadolint') {
            steps {
                sh 'hadolint --config hadolint.yaml Dockerfile'
            }
        }
        stage('Build') {
            steps {
                sh 'docker build -t watri/demo:$(git rev-parse --short HEAD)${BUILD_NUMBER} -f Dockerfile .'
            }
        }
        stage('Image Scan Trivy') {
            steps {
                sh 'trivy image --config trivy.yaml watri/demo:$(git rev-parse --short HEAD)${BUILD_NUMBER}'
            }
        }
        stage('Push Image to Registry') {
            steps {
                withDockerRegistry([ credentialsId: 'docker-hub-cred', url: '' ]) {
                sh  'docker push watri/demo:$(git rev-parse --short HEAD)${BUILD_NUMBER}'
                }
            }
        }
        stage('Deploy to Cluster') {
            steps {
                sh '''
                #!/bin/bash
                echo "Deploying to Docker destop Cluster"
                sed -i "s|latest|$(git rev-parse --short HEAD)${BUILD_NUMBER}|g" deployment/deployment.yaml 
                kubectl config use-context docker-desktop && kubectl apply -f deployment/deployment.yaml 
                '''

                sh '''
                #!/bin/bash
                echo "Deployment Check Development"
                kubectl config use-context docker-desktop && kubectl rollout status deployment/app-demo-deployment -n default --timeout=300s
                '''
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: 'result.html', followSymlinks: false
        }
    }
}