# Defining the Git repo to instantiate on the SageMaker notebook instance
resource "aws_sagemaker_code_repository" "git_repo" {
  code_repository_name = "aws-sm-notebook-instance-repo"

  git_config {
    repository_url = "https://github.com/AndreasLuckert/aws-sm-notebook-instance.git"
  }
}