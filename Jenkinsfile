def workspace;

node
{
  stage('printing terraform file')
{
    sh 'git init .'
    sh 'pwd'
    sh 'git pull https://github.com/pradip10/jenkins-terraform.git'
    sh 'cat aws.tf'
}

stage('build')
{

    sh 'terraform init && terraform apply -auto-approve'
}
