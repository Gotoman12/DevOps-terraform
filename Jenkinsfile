pipeline{
    agent any

    parameters{
        choice=(name:"TerraformAction",choices:['apply','destroy'],description:"Choose your terraform action")
    }

    environment{
          AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
    }
}