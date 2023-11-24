# Terraform infrastructure setup
The following page will report some terraform code snippets which allows to setup kafka connect instance on k8s.

## Setup eventhub
Eventhub has been used as kafka cluster for kafka connect. Each eventhub namespace represent a different kafka cluster where azure apply a limit in terms of number of topics. The standard plan of azure eventhub can support up to 10 topics. A single instance of kakfa connect cluster will use 3 technical topics
with compaction policy in order to save and keep data related to jobs config, resume checkpoint and job status. 3 of 10 topics will be
used by kafka connect cluster, making available only 7 topics for application purpose.

## Kafka Connect setup
The setup of kakfa connect can be done using terraform's kubernetes deployment resource. This deployment example also include
**liveness** and **readiness** of kafka connect using the rest api exposed by kafka connect. The pod will be marked as **ready** when starts to return 200 from rest api.

```hcl
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
    kubernetes_config_map.kafka_connect_debezium_config,
    kubernetes_secret.kafka_connect_debezium_secret
  ]
}
```

## High availability
To achieve high availability we must use multiple instance of kakfa connect (aka distributed mode). This can be
achieved by setting same group.id across multiple instance. In k8s we can increase the number of pods and kafka will
balance jobs of same group.id.
K8s cluster runs over multiple virtual machine (nodes), so we need to be tolerant to node fault. This can be achieved by using
pod anti-affinity in order to schedule pod execution on different nodes. 
```yaml

```

In this way a fault of a single node will not affect kafka
connect cluster which has another pod instance running in another k8s node.