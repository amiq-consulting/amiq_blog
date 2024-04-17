def call(Map config = [:]){

    if ("${currentBuild.currentResult}" == "SUCCES"){
        mail to: "${config.mailTo}",
        subject: "Jenkins Job '${JOB_NAME}', build (${BUILD_NUMBER}) ",
        body: "Job \'${JOB_NAME}\' has just finished build ${BUILD_NUMBER}.\n\nCongratulations!! It\'s status is ${currentBuild.currentResult}\n\nPlease go to '${BUILD_URL}' and check the steps.\n\nThank you,\nMr. Jenkins ",
        from: 'jenkins@sulki'
    }

    else{
        mail to: "${config.mailTo}",
        subject: "Jenkins Job '${JOB_NAME}', build (${BUILD_NUMBER}) ",
        body: "Job \'${JOB_NAME}\' has just finished build ${BUILD_NUMBER}.\n\nToo bad!! It\'s status is ${currentBuild.currentResult}\n\nPlease go to '${BUILD_URL}' and check the steps.\n\nThank you,\nMr. Jenkins ",
        from: 'jenkins@sulki'
    }
}