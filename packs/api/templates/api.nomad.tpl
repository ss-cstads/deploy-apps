job [[ template "job_name" . ]] {
  namespace   = [[ var "namespace" . | quote ]]
  datacenters = ["dc1"]
  type        = "service"

[[ template "update" . ]]

  group "api" {
    count = [[ var "count" . ]]

    network {
      mode = "bridge"
      port "http" {
        to = [[ var "port" . ]]
      }
    }

    # Nome fixo <namespace>-backend: so o <namespace>-app (pack web_app) pode
    # chamar este servico. Nao e exposto na internet.
    service {
      name = "[[ var "namespace" . ]]-backend"
      port = "http"
      tags = ["student", [[ var "namespace" . | quote ]], "api"]

      connect {
        sidecar_service {
          proxy {
            local_service_port = [[ var "port" . ]]
            config {
              protocol = "http"
            }
[[- template "mysql_upstream" . ]]
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

    task "api" {
      driver = "docker"

      config {
        image = [[ var "image" . | quote ]]
        ports = ["http"]
      }

      resources {
        cpu    = [[ var "cpu" . ]]
        memory = [[ var "memory" . ]]
      }

[[ template "app_env" . ]]
    }
  }
}
