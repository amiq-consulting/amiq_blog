def call (Map config = [:]){
    pipeline{
        agent any

        environment{
                PROJ_HOME = "$WORKSPACE"
        }

        stages {

            stage ("Workspace preparation"){

                options {retry(3)}

                steps{
                    script{
                        try{
                            if ( currentBuild.number == 1){
                              echo "Cloning repository"
                              sh "git clone ${config.gitURL} ."
                            }
                            else{
                                echo "Build number: ${env.BUILD_NUMBER}"
                                cherry_pick()
                                echo "Cherry-picking ${GERRIT_REFSPEC}"
                            }
                        }catch(Exception e){
                            echo e.toString()
                            sh 'exit 1'
                        }
                    }
                }
            }

            stage ("AMIQ Internship Pipeline"){
                parallel{

                    stage ('Code Compilation'){
                        steps{
                            script{
                                try{
                                    compile()
                                }catch(Exception e){
                                    echo e.toString()
                                }
                            }
                        }
                    }
                    stage("Linting"){
                        steps{
                            script{

                                try{
                                    linting()
                                }catch(Exception e){
                                    sh 'cat $WORKSPACE/CustomReport.txt; exit 1'
                                    echo e.toString()
                                }
                            }
                        }
                    }
                }
            }

        }

        post{
            always{
                sendMail(mailTo:"${config.mailTo}")
            }
            success{
                gerritReview labels: [Verified: 1]
            }
            failure {
                gerritReview labels: [Verified: -1]
            }
            cleanup {
                sh 'git reset --hard HEAD^'
                sh 'git pull --rebase'
                sh 'git log -3 --oneline'
            }
        }
    }
}
