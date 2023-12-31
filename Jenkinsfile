pipeline {
    agent any
    environment {
        PATH = "$PATH:/usr/local/bin/"
    }
    stages {
        stage('Git Clone') {
            steps {
                checkout scmGit(branches: [[name: '*/master']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/watri/demo.git']])
            }
        }
        stage('Change jar version') {
            steps {
                sh '''
                #!/bin/bash
                sed -i '' "s|dcid|${BUILD_NUMBER}|g" pom.xml
                sed -i '' "s|dcid|${BUILD_NUMBER}|g" Dockerfile
                '''
            }
        }
        stage('Build') {
            steps {
                sh 'docker build -t watri/demo:$(git rev-parse --short HEAD)${BUILD_NUMBER} -f Dockerfile .'
            }
        }
        stage('Image Registry') {
            steps {
                sh 'docker push watri/demo:$(git rev-parse --short HEAD)${BUILD_NUMBER}'
            }
        }
        stage('Deploy to Cluster') {
            steps {
                sh '''
                #!/bin/bash
                echo "Deploying to Docker destop Cluster"
                sed -i '' "s|latest|$(git rev-parse --short HEAD)${BUILD_NUMBER}|g" deployment/deployment.yaml 
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
}