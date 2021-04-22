pipeline {
  agent { dockerfile true }
  stages {
    stage('Compile') {
      steps {
        sh 'gradle wrapper'
        sh './gradlew compileDebugSources'
      }
    }

    stage('Ktlin format') {
          steps {
            sh './gradlew ktlintCheck'
          }
        }

    stage('Unit test') {
      steps {
        sh './gradlew testDebugUnitTest testDebugUnitTest'
      }
    }

 stage('Static analysis') {
      steps {
        sh './gradlew lintDebug'
      }
    }


    stage('Build APK') {

      steps {
         withCredentials(bindings: [file(credentialsId: 'appid', variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) {
          sh 'echo $GOOGLE_APPLICATION_CREDENTIALS'
          sh './gradlew assembleDebug appDistributionUploadDebug'
        }
        
        archiveArtifacts '**/*.apk'
      }
    }


    stage('Deploy') {
      when {
        branch 'qwe'
      }
      environment {
        SIGNING_KEYSTORE = credentials('my-app-signing-keystore')
        SIGNING_KEY_PASSWORD = credentials('my-app-signing-password')
      }
      post {
        success {
          mail(to: 'beta-testers@example.com', subject: 'New build available!', body: 'Check it out!')
        }

      }
      steps {
        sh './gradlew assembleRelease'
        archiveArtifacts '**/*.apk'
        androidApkUpload(googleCredentialsId: 'Google Play', apkFilesPattern: '**/*-release.apk', trackName: 'beta')
      }
    }

  }
  post {
    failure {
      mail(to: 'android-devs@example.com', subject: 'Oops!', body: "Build ${env.BUILD_NUMBER} failed; ${env.BUILD_URL}")
    }

  }
  options {
    skipStagesAfterUnstable()
  }
}