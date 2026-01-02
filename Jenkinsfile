pipeline {
    agent any

    parameters {
        choice(
            name: 'terraformAction',
            choices: ['apply', 'destroy'],
            description: 'Choose your terraform action'
        )
    }

    environment {
        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
    }

    stages {

        stage("Git Checkout") {
            steps {
                git url: "https://github.com/Gotoman12/DevOps-terraform.git", branch: "eks"
            }
        }

        stage("Terraform Init & Plan") {
            steps {
                sh '''
                  terraform init
                  terraform plan -out=tfplan
                  terraform show -no-color tfplan > tfplan.txt
                '''
            }
        }

        stage("Approval") {
            steps {
                script {
                    input message: "Do you want to proceed with Terraform ${params.terraformAction}?"
                }
            }
        }

        stage("Apply / Destroy") {
            steps {
                sh '''
                  if [ "${terraformAction}" = "apply" ]; then
                    terraform apply -auto-approve tfplan
                  else
                    terraform destroy -auto-approve
                  fi
                '''
            }
        }
    }
}
