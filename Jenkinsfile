#!groovy

node('executor') {
  ws("etl-egress") {
    checkout scm

    def authorName  = sh(returnStdout: true, script: 'git --no-pager show --format="%an" --no-patch')
    def isMain    = env.BRANCH_NAME == "main"
    def serviceName = env.JOB_NAME.tokenize("/")[1]

    def commitHash    = sh(returnStdout: true, script: 'git rev-parse HEAD | cut -c-7').trim()
    def version       = "${env.BUILD_NUMBER}-${commitHash}"

    try {
      stage("Test") {
        //sh 'make test'
      }

      if(isMain) {

        stage("Build & Publish") { sh "export VERSION=${version}; make build" }

        stage("Deploy") {
          build job: "service-deploy/pennsieve-non-prod/us-east-1/dev-vpc-use1/dev/${serviceName}",
          parameters: [
            string(name: 'VERSION_NUMBER', value: version),
            string(name: 'TERRAFORM_ACTION', value: 'apply')
          ]
        }
      }
    } catch (e) {
      slackSend(color: '#b20000', message: "FAILED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL}) by ${authorName}")
      throw e
    }

    slackSend(color: '#006600', message: "SUCCESSFUL: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL}) by ${authorName}")
  }
}
