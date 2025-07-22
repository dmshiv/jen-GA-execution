pipeline {
    agent any

    parameters {
        booleanParam(name: 'DESTROY_MODE', defaultValue: false, description: 'Enable to destroy infrastructure instead of applying')
    }

    environment {
        TF_IN_AUTOMATION = "1"
        TF_INPUT = "0"
    }

    stages {
        // ---------- APPLY FLOW ----------
        stage('Apply - Mumbai') {
            when { expression { !params.DESTROY_MODE } }
            stages {
                stage('Mumbai - Init') {
                    steps {
                        dir('holding-3-tf-folders/mumbai') {
                            script {
                                def initStatus = sh(script: 'terraform init -reconfigure', returnStatus: true)
                                if (initStatus != 0) {
                                    echo "⚠️ Init failed in Mumbai. Retrying with -upgrade..."
                                    sh 'terraform init -upgrade'
                                }
                            }
                        }
                    }
                }
                stage('Mumbai - Plan') {
                    steps {
                        dir('holding-3-tf-folders/mumbai') {
                            sh 'terraform plan -out=tfplan'
                        }
                    }
                }
                stage('Mumbai - Apply') {
                    steps {
                        dir('holding-3-tf-folders/mumbai') {
                            sh 'terraform apply -auto-approve tfplan'
                        }
                    }
                }
            }
        }

        stage('Apply - Ireland') {
            when { expression { !params.DESTROY_MODE } }
            stages {
                stage('Ireland - Init') {
                    steps {
                        dir('holding-3-tf-folders/ireland') {
                            script {
                                def initStatus = sh(script: 'terraform init -reconfigure', returnStatus: true)
                                if (initStatus != 0) {
                                    echo "⚠️ Init failed in Ireland. Retrying with -upgrade..."
                                    sh 'terraform init -upgrade'
                                }
                            }
                        }
                    }
                }
                stage('Ireland - Plan') {
                    steps {
                        dir('holding-3-tf-folders/ireland') {
                            sh 'terraform plan -out=tfplan'
                        }
                    }
                }
                stage('Ireland - Apply') {
                    steps {
                        dir('holding-3-tf-folders/ireland') {
                            sh 'terraform apply -auto-approve tfplan'
                        }
                    }
                }
            }
        }

        stage('Apply - Accelerator') {
            when { expression { !params.DESTROY_MODE } }
            stages {
                stage('Accelerator - Init') {
                    steps {
                        dir('holding-3-tf-folders/accelerator-file') {
                            script {
                                def initStatus = sh(script: 'terraform init -reconfigure', returnStatus: true)
                                if (initStatus != 0) {
                                    echo "⚠️ Init failed in Accelerator. Retrying with -upgrade..."
                                    sh 'terraform init -upgrade'
                                }
                            }
                        }
                    }
                }
                stage('Accelerator - Plan') {
                    steps {
                        dir('holding-3-tf-folders/accelerator-file') {
                            sh 'terraform plan -out=tfplan'
                        }
                    }
                }
                stage('Accelerator - Apply') {
                    steps {
                        dir('holding-3-tf-folders/accelerator-file') {
                            sh 'terraform apply -auto-approve tfplan'
                        }
                    }
                }
            }
        }

        // ---------- DESTROY FLOW ----------
        stage('Destroy - Accelerator') {
            when { expression { params.DESTROY_MODE } }
            steps {
                dir('holding-3-tf-folders/accelerator-file') {
                    script {
                        def initStatus = sh(script: 'terraform init -reconfigure', returnStatus: true)
                        if (initStatus != 0) {
                            echo "⚠️ Init failed in Accelerator. Retrying with -upgrade..."
                            sh 'terraform init -upgrade'
                        }
                        sh 'terraform destroy -auto-approve || echo "⚠️ Accelerator destroy failed"'
                    }
                }
            }
        }

        stage('Destroy - Ireland') {
            when { expression { params.DESTROY_MODE } }
            steps {
                dir('holding-3-tf-folders/ireland') {
                    script {
                        def initStatus = sh(script: 'terraform init -reconfigure', returnStatus: true)
                        if (initStatus != 0) {
                            echo "⚠️ Init failed in Ireland. Retrying with -upgrade..."
                            sh 'terraform init -upgrade'
                        }
                        sh 'terraform destroy -auto-approve || echo "⚠️ Ireland destroy failed"'
                    }
                }
            }
        }

        stage('Destroy - Mumbai') {
            when { expression { params.DESTROY_MODE } }
            steps {
                dir('holding-3-tf-folders/mumbai') {
                    script {
                        def initStatus = sh(script: 'terraform init -reconfigure', returnStatus: true)
                        if (initStatus != 0) {
                            echo "⚠️ Init failed in Mumbai. Retrying with -upgrade..."
                            sh 'terraform init -upgrade'
                        }
                        sh 'terraform destroy -auto-approve || echo "⚠️ Mumbai destroy failed"'
                    }
                }
            }
        }
    }
}
