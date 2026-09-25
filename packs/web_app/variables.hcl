variable "namespace" {
  description = "Namespace do aluno."
  type        = string
}

variable "image" {
  description = "Imagem Docker."
  type        = string
}

variable "job_name" {
  description = "Nome do job no namespace."
  type        = string
  default     = "web"
}

variable "port" {
  description = "Porta em que o app escuta no container."
  type        = number
  default     = 8080
}

variable "health_path" {
  description = "Rota HTTP que responde 2xx quando o app esta saudavel."
  type        = string
  default     = "/"
}

variable "count" {
  description = "Numero de instancias."
  type        = number
  default     = 1
}

variable "cpu" {
  description = "CPU reservada (MHz)."
  type        = number
  default     = 200
}

variable "memory" {
  description = "Memoria reservada (MB)."
  type        = number
  default     = 256
}

variable "healthy_deadline" {
  description = "Prazo para a versao nova ficar saudavel antes do rollback."
  type        = string
  default     = "3m"
}

variable "mysql_upstream" {
  description = "Acesso ao MySQL (pack mysql) em 127.0.0.1:3306, com DB_* e DATABASE_URL."
  type        = bool
  default     = false
}

variable "backend_upstream" {
  description = "Acesso a API (pack api) em 127.0.0.1:8080."
  type        = bool
  default     = false
}
