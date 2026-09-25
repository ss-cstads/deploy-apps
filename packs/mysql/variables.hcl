# --- Injetada pelo GitHub Actions -------------------------------------------
variable "namespace" {
  description = "Namespace do aluno (secret STUDENT_NAMESPACE). Define o servico e o volume <namespace>-mysql."
  type        = string
}

# --- Personalizaveis pelo aluno ----------------------------------------------
variable "job_name" {
  description = "Nome do job no Nomad (unico dentro do namespace)."
  type        = string
  default     = "mysql"
}

variable "image" {
  description = "Imagem do MySQL. 8.4 = versao LTS atual."
  type        = string
  default     = "mysql:8.4"
}

variable "database" {
  description = "Banco criado no primeiro start (volume vazio)."
  type        = string
  default     = "app"
}

variable "user" {
  description = "Usuario da aplicacao criado no primeiro start; a senha e db_password no Vault."
  type        = string
  default     = "app"
}

variable "cpu" {
  description = "CPU reservada, em MHz."
  type        = number
  default     = 500
}

variable "memory" {
  description = "Memoria reservada, em MB."
  type        = number
  default     = 512
}
