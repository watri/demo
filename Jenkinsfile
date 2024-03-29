pipeline {
    agent any
    environment {
        PATH = "$PATH:/usr/local/bin/"
        IMAGETAG = ""
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
                git branch: 'master', credentialsId: 'github-login', url: 'https://github.com/watri/demo.git'
                // checkout scmGit(branches: [[name: '*/master']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/watri/demo.git']])
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
                script{
                    IMAGETAG = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim() + BUILD_NUMBER
                    echo "Image Tag: ${IMAGETAG}"
                }
                sh "docker build -t watri/demo:${IMAGETAG} -f Dockerfile ."
            }
        }
        stage('Image Scan Trivy') {
            steps {
                sh "echo trivy scan"
                // sh "trivy image --config trivy.yaml watri/demo:${IMAGETAG}"
            }
        }
        stage('Push Image to Registry') {
            steps {
                withDockerRegistry([ credentialsId: 'docker-hub-cred', url: '' ]) {
                sh  "docker push watri/demo:${IMAGETAG}"
                }
            }
        }
        stage('Update Values File for ArgoCD') {
            environment {
                GIT_REPO_NAME = "demo-chart"
                GIT_USER_NAME = "watri"
            }
            steps {
                dir('demo-chart') {
                    git branch: 'master', credentialsId: 'github-login', url: 'https://github.com/watri/demo-chart.git'
                    
                    withCredentials([string(credentialsId: 'github-key', variable: 'GITHUB_TOKEN')]) {
                        script {
                            sh """
                                git config user.email "chieewhatt@gmail.com" 
                                git config user.name "watri"
                                currenttag=\$(yq .image.tag charts/demo/values-prod.yaml)
                                yq -i '.image.tag = "${IMAGETAG}"' charts/demo/values-prod.yaml
                                git add charts/demo/values-prod.yaml
                                git commit -m "Update image to version ${IMAGETAG}"
                                git push https://${GITHUB_TOKEN}@github.com/${GIT_USER_NAME}/${GIT_REPO_NAME} HEAD:master
                            
                            """  
                        }
                    }
                }
            }
        }
        // stage('Deploy to Cluster') {
        //     steps {
        //         sh '''
        //         #!/bin/bash
        //         echo "Deploying to Docker destop Cluster"
        //         helm upgrade --install --wait --timeout=300s demo-service demo/demo --set=image.tag=$(git rev-parse --short HEAD)${BUILD_NUMBER} --namespace=prod --kube-context=docker-desktop -f deployment/values-prod.yaml
        //         '''
        //         // sed -i "s|latest|$(git rev-parse --short HEAD)${BUILD_NUMBER}|g" deployment/deployment.yaml 
        //         // kubectl config use-context docker-desktop && kubectl apply -f deployment/deployment.yaml 

        //         sh '''
        //         #!/bin/bash
        //         echo "Deployment Check Development"
        //         kubectl config use-context docker-desktop && kubectl rollout status deployment/demo-service -n prod --timeout=300s
        //         '''
        //     }
        // }
    }

    // post {
    //     always {
    //         archiveArtifacts artifacts: 'result.html', followSymlinks: false
    //     }
    // }
}