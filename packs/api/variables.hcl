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
  default     = "api"
}

variable "port" {
  description = "Porta em que o app escuta no container."
  type        = number
  default     = 8080
}

variable "health_path" {
  description = "Rota HTTP que responde 2xx quando o app esta saudavel."
  type        = string
  default     = "/health"
}

variable "count" {
  description = "Numero de instancias."
  type        = number
  default     = 1
}

variable "cpu" {
  description = "CPU reservada (MHz)."
  type        = number
  default     = 300
}

variable "memory" {
  description = "Memoria reservada (MB)."
  type        = number
  default     = 512
}

variable "healthy_deadline" {
  description = "Prazo para a versao nova ficar saudavel antes do rollback."
  type        = string
  default     = "5m"
}

variable "mysql_upstream" {
  description = "Acesso ao MySQL (pack mysql) em 127.0.0.1:3306, com DB_* e DATABASE_URL."
  type        = bool
  default     = false
}
