pipeline{
    agent any

    parameters{
        choice=(name:"TerraformAction",choices:['apply','destroy'],description:"Choose your terraform action")
    }

    environment{
          AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
          AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
    }
        stages{
            stage("git-checkout"){
                steps{
                       git url:"https://github.com/Gotoman12/DevOps-terraform.git",branch:"eks"
                }
            }
            stage("terrform-plan"){
                steps{
                    sh 'terraform init'
                    sh 'terrafrom plan -out tfplan'
                    sh 'terraform show -no-color tfplan > tfplan.txt'
                }
            }
            stage('Approval'){
            steps{
                script{
                    def plan = readFile 'tfplan.txt'
                    input message: "Do you want to proceed with Terraform ${params.TerraformAction}?"
                }
            }
        }
        stage("apply/destroy"){
            steps{
                sh '''
                if ["${TerraformAction}" = "apply" ];then
                  terraform apply tfplan
                else
                     terraform destroy -auto-approve    
                fi
                '''
            }
        }
    }
}