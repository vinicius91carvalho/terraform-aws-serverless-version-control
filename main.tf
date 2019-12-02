/* 
  Configura o provedor do BitBucket
  As seguintes variáveis de ambiente devem estar presentes:
  - BITBUCKET_USERNAME
  - BITBUCKET_PASSWORD
*/
provider "bitbucket" {
}

/*
  Cria o repositório no BitBucket
*/
resource "bitbucket_repository" "app" {
  owner      = var.team_name
  name       = var.project_name
  scm        = "git"
  is_private = true
}


/*
  Envia a aplicação para o repositório remoto criado
*/
resource "null_resource" "push_to_repo" {

  triggers = {
    git_index_exists = fileexists("${var.app_relative_path}/.git/index")
  }

  provisioner "local-exec" {
    command = "cd ${var.app_relative_path} && git init"
  }

  provisioner "local-exec" {
    command = "cd ${var.app_relative_path} && git remote add origin ${bitbucket_repository.app.clone_ssh}"
  }

  provisioner "local-exec" {
    command = "cd ${var.app_relative_path} && git add . && git commit -am \"First commit\" && git push --set-upstream origin master"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "cd ${var.app_relative_path} && rm -rf .git/"
  }

  depends_on = [bitbucket_repository.app]
}

