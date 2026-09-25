# --- Injetadas pelo GitHub Actions ------------------------------------------
variable "namespace" {
  description = "Namespace do aluno (secret STUDENT_NAMESPACE). Define o servico <namespace>-app e a URL publica."
  type        = string
}

variable "image" {
  description = "Imagem Docker da aplicacao (ex.: ghcr.io/<usuario>/<repo>:<sha>)."
  type        = string
}

# --- Personalizaveis pelo aluno ----------------------------------------------
variable "job_name" {
  description = "Nome do job no Nomad (unico dentro do namespace)."
  type        = string
  default     = "web"
}

variable "port" {
  description = "Porta em que a aplicacao escuta dentro do container (EXPOSE do Dockerfile)."
  type        = number
  default     = 8080
}

variable "health_path" {
  description = "Rota HTTP que responde 2xx quando a aplicacao esta saudavel."
  type        = string
  default     = "/"
}

variable "count" {
  description = "Numero de instancias."
  type        = number
  default     = 1
}

variable "cpu" {
  description = "CPU reservada, em MHz."
  type        = number
  default     = 200
}

variable "memory" {
  description = "Memoria reservada, em MB. O container e encerrado se passar disso."
  type        = number
  default     = 256
}

variable "healthy_deadline" {
  description = "Tempo maximo para a nova versao ficar saudavel antes do rollback automatico."
  type        = string
  default     = "3m"
}

variable "env" {
  description = "Variaveis de ambiente nao secretas (ex.: { NODE_ENV = \"production\" })."
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

variable "backend_upstream" {
  description = "Liga o acesso ao pack api (<namespace>-backend) via service mesh."
  type        = bool
  default     = false
}

variable "backend_local_port" {
  description = "Porta local (127.0.0.1) onde o backend fica acessivel quando backend_upstream = true."
  type        = number
  default     = 8080
}
