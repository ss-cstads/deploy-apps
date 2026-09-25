# --- Injetadas pelo GitHub Actions ------------------------------------------
variable "namespace" {
  description = "Namespace do aluno (secret STUDENT_NAMESPACE). Define o servico <namespace>-backend."
  type        = string
}

variable "image" {
  description = "Imagem Docker da API (ex.: ghcr.io/<usuario>/<repo>/backend:<sha>)."
  type        = string
}

# --- Personalizaveis pelo aluno ----------------------------------------------
variable "job_name" {
  description = "Nome do job no Nomad (unico dentro do namespace)."
  type        = string
  default     = "api"
}

variable "port" {
  description = "Porta em que a API escuta dentro do container (EXPOSE do Dockerfile)."
  type        = number
  default     = 8080
}

variable "health_path" {
  description = "Rota HTTP que responde 2xx quando a API esta saudavel."
  type        = string
  default     = "/health"
}

variable "count" {
  description = "Numero de instancias."
  type        = number
  default     = 1
}

variable "cpu" {
  description = "CPU reservada, em MHz."
  type        = number
  default     = 300
}

variable "memory" {
  description = "Memoria reservada, em MB (Spring Boot: 512 ou mais)."
  type        = number
  default     = 512
}

variable "healthy_deadline" {
  description = "Tempo maximo para a nova versao ficar saudavel antes do rollback automatico."
  type        = string
  default     = "5m"
}

variable "env" {
  description = "Variaveis de ambiente nao secretas (ex.: { DB_HOST = \"127.0.0.1\" })."
  type        = map(string)
  default     = {}
}

variable "vault_secrets" {
  description = "Chaves do Vault (secret/students/<namespace>/app) injetadas como env em MAIUSCULAS."
  type        = list(string)
  default     = []
}

variable "secret_env" {
  description = "Env montada com segredos do Vault: { DATABASE_URL = \"mysql://app:{{db_password}}@127.0.0.1:3306/app\" }."
  type        = map(string)
  default     = {}
}

variable "mysql_upstream" {
  description = "Liga o acesso ao pack mysql (<namespace>-mysql) via service mesh."
  type        = bool
  default     = false
}

variable "mysql_local_port" {
  description = "Porta local (127.0.0.1) onde o MySQL fica acessivel quando mysql_upstream = true."
  type        = number
  default     = 3306
}
