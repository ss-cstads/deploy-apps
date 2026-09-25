job [[ template "job_name" . ]] {
  namespace   = [[ var "namespace" . | quote ]]
  datacenters = ["dc1"]
  type        = "service"

[[ template "update" . ]]

  group "web" {
    count = [[ var "count" . ]]

    network {
      mode = "bridge"
      port "http" {
        to = [[ var "port" . ]]
      }
    }

    # Nome fixo <namespace>-app: e o servico publicado em
    # https://<namespace>.projetos.sapucaia.ifsul.edu.br
    service {
      name = "[[ var "namespace" . ]]-app"
      port = "http"
      tags = ["student", [[ var "namespace" . | quote ]], "web"]

      connect {
        sidecar_service {
          proxy {
            local_service_port = [[ var "port" . ]]
            config {
              protocol = "http"
            }
[[- if var "backend_upstream" . ]]

            # <namespace>-backend (pack api) em 127.0.0.1:[[ var "backend_local_port" . ]]
            upstreams {
              destination_name = "[[ var "namespace" . ]]-backend"
              local_bind_port  = [[ var "backend_local_port" . ]]
            }
[[- end ]]
          }
        }
      }

      check {
        name     = "HTTP health"
        type     = "http"
        path     = [[ var "health_path" . | quote ]]
        interval = "10s"
        timeout  = "3s"
      }
    }

[[ template "restart_reschedule" . ]]

    task "web" {
      driver = "docker"

      config {
        image = [[ var "image" . | quote ]]
        ports = ["http"]
      }

      resources {
        cpu    = [[ var "cpu" . ]]
        memory = [[ var "memory" . ]]
      }
[[ template "env" . ]]
[[ template "vault_secrets" . ]]
    }
  }
}
