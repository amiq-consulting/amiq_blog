def call(Map config = [:]){
    pipeline{
        agent any
        
        environment{
                String commit = sh(returnStdout: true, script: 'git log -1 --oneline').trim()
                PROJ_HOME = "$WORKSPACE"
        }
        
        stages{
            stage ("Code Checkout"){
                
                options {retry(3)}

                steps{
                    script{
                        try{
                            codeCheckOut("${config.gitURL}")
                        }catch(Exception e){
                            echo e.toString()
                            sh 'exit 1'
                        }
                    }
                    stash(name: 'gitrepo')
                }
            }
            
            stage ('Code Compilation'){
                            
                steps{
                    lock (label: 'amun_agent', resource: null){
                        script{
                            try{
                                compile()
                            }catch(Exception e){
                                echo e.toString()
                            }
                        }
                    }
                }
            }
            
            stage ("Linting"){
                when {
                    expression {
                        hasNOLINT(commit) == false
                    }
                }
                
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
            
            stage ('Sanity test'){
                // agent{
                //     label 'amun'
                // }
                
                environment{
                    PROJ_HOME = "$WORKSPACE"
                }
                
                steps {
                    lock (label: 'amun_agent', resource: null){
                        unstash 'gitrepo'
                        script{
                            try{
                                runTest(seed: "${config.sanityTestSeed}", testName:"${config.sanityTestName}")
                            }catch(Exception e){
                                echo e.toString()
                                sh 'exit 1'
                            }
                        }
                    }
                }
            }
            
            
            stage ('Regression'){
                agent{
                    label 'amun'
                }

                environment{
                    PROJ_HOME = "$WORKSPACE"
                }
                
                when {
                    expression {
                        hasNOREG(commit) == false
                    }
                    
                }
                
                steps{
                    unstash 'gitrepo'
                    script{
                        try{
                            sh 'export PROJ_HOME=$WORKSPACE'
                            regression(vsif:"${config.vsif}")
                        }catch(Exception e){
                            echo e.toString()
                            sh 'exit 1'
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
        }
        
    }
}