def call(Map config = [:]){
    if (config.testName == "")
        sh 'echo "No name given to test" '

    if (config.seed == "")
        sh 'echo "No seed given to test" '

    sh "source /apps/source.apps ; /proj/vmngr/dvci/run.sh ${config.testName} ${config.seed}"
}