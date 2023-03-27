pipeline {
    agent any
    
    stages {
        stage('Cloning git') {
            steps {
                echo 'Cloning'
                git branch: 'main',
                credentialsId: 'DarwinPM26',
                url: 'https://github.com/DarwinPM26/Nodepipeline.git'
                sh "ls -lat"
            }
        }
        stage('Install dependencies') {
            steps {
                echo 'Installing'
                sh 'npm install --global yarn'
                sh 'yarn install'
            }
        }
        stage('Build') {
            steps {
                echo 'Building'
                sh 'npm run build'
            }
        }
        stage('Unit Test') {
            steps {
                echo 'Testing'
                sh 'npm test'
            }
        }
         stage('Sonar Scan') {
            steps {
                script {
                scannerHome = tool 'SonarScanner'
                }
                withSonarQubeEnv('sonarqube') {
                sh "${scannerHome}/bin/sonar-scanner \
                -Dsonar.projectKey=Jenkins \
                -Dsonar.sources=Infra/shared/workspace/libs/shared/dls/src \
                -Dsonar.javascript.lcov.reportPaths=Infra/shared/workspace/dist/coverage/libs/shared/dls/lcov.info"
                }
            }
        }
        stage('Deploy') {
            steps{
                echo 'Deployingy'
                //s3Upload consoleLogLevel: 'INFO', dontSetBuildResultOnFailure: false, dontWaitForConcurrentBuildCompletion: false, entries: [[bucket: 'lanzbucket', excludedFile: '', flatten: false, gzipFiles: false, keepForever: false, managedArtifacts: false, noUploadOnFailure: true, selectedRegion: 'ap-southeast-1', showDirectlyInBrowser: false, sourceFile: 'build/', storageClass: 'STANDARD', uploadFromSlave: false, useServerSideEncryption: false]], pluginFailureResultConstraint: 'FAILURE', profileName: 'jenkins-s3', userMetadata: [
            }
        }
    }
}
