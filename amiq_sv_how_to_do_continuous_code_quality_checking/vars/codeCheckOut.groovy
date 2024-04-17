def call(String gitURL){

    sh "echo BRANCH: ${GERRIT_BRANCH}"
    sh "echo REFSPEC: ${GERRIT_REFSPEC}"
    //checkout scmGit(branches: [[name: "${GERRIT_REFSPEC}"]], extensions: [cleanBeforeCheckout()], userRemoteConfigs: [[credentialsId: '4a5de5a8-30dc-404f-b894-1e25f862db89', refspec: '${GERRIT_REFSPEC}', url: "${gitURL}"]])
    checkout scmGit(branches: [[name: "${GERRIT_BRANCH}"]], userRemoteConfigs: [[credentialsId: '4a5de5a8-30dc-404f-b894-1e25f862db89', refspec: "${GERRIT_REFSPEC}", url: "${gitURL}"]])
}
