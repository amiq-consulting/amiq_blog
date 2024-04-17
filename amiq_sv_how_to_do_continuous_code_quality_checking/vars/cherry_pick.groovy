def call() {
    sh 'git fetch origin ${GERRIT_REFSPEC} && git cherry-pick FETCH_HEAD'
}
