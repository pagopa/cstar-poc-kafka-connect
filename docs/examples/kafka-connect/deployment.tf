resource "kubernetes_deployment" "kafka_connect" {
  count = 1
  metadata {
    name = "kafka-connect"
    namespace = "..."
  }
  spec {
    replicas = "1"
    selector {
      match_labels = { app = "kafka-connect" }
    }
    template {
      metadata {
        labels = { app = "kafka-connect" }
      }
      spec {
        container {
          name = "kafka-connect"
          image_pull_policy = "Always"
          image = "cstardcommonacr.azurecr.io/kafka-connectors"

          port {
            container_port = 8083
          }

          env_from {
            config_map_ref {
              name = "kafka-connect-config"
            }
          }

          env_from {
            secret_ref {
              name = "kafka-connect-secret"
            }
          }

          resources {
            limits = {
              cpu = "400m"
              memory = "512Mi"
            }
          }

          liveness_probe {
            http_get {
              path = "/connectors"
              port = "8083"
            }

            initial_delay_seconds = 60
            period_seconds = 5
            timeout_seconds = 5
            success_threshold = 1
            failure_threshold = 10
          }

          readiness_probe {
            http_get {
              path = "/connectors"
              port = "8083"
            }
            initial_delay_seconds = 40
            period_seconds = 10
            timeout_seconds = 5
            success_threshold = 1
            failure_threshold = 3
          }
        }
      }
    }
  }
  depends_on = [
    kubernetes_config_map.kafka_connect_config,
    kubernetes_secret.kafka_connect_secret
  ]
}