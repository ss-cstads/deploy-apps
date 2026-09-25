variable "namespace" {
  description = "Namespace do aluno (servico e volume <namespace>-mysql)."
  type        = string
}

variable "job_name" {
  description = "Nome do job no namespace."
  type        = string
  default     = "mysql"
}

variable "image" {
  description = "Imagem do MySQL (8.4 = LTS)."
  type        = string
  default     = "mysql:8.4"
}

variable "cpu" {
  description = "CPU reservada (MHz)."
  type        = number
  default     = 500
}

variable "memory" {
  description = "Memoria reservada (MB)."
  type        = number
  default     = 512
}
