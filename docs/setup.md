# Setup
The following page will report some terraform code snippets which allows to setup kafka connect instance on k8s.

## Setup eventhub
Eventhub has been used as kafka cluster for kafka connect. Each eventhub namespace represent a different kafka cluster where azure apply a limit in terms of number of topics. The standard plan of azure eventhub can support up to 10 topics. A single instance of kakfa connect cluster will use 3 technical topics
with compaction policy in order to save and keep data related to jobs config, resume checkpoint and job status. 3 of 10 topics will be
used by kafka connect cluster, making available only 7 topics for application purpose.

!!! info
    Kafka connect automatically create topics on azure eventhub, so you need to provide a connection string with manage permission at   namespace level (not topic level).


``` terraform
resource "azurerm_eventhub_namespace_authorization_rule" "kakfa_connect_evh_access_key" {
  name                = "kafka-connect-access-key"
  namespace_name      = "..."
  resource_group_name = "..."
  manage              = true
  listen              = true
  send                = true
}
```



## Kafka Connect setup
The setup of kakfa connect can be done using terraform's kubernetes deployment resource. This deployment example also include
**liveness** and **readiness** of kafka connect using the rest api exposed by kafka connect. The pod will be marked as **ready** when starts to return 200 from rest api.

=== "Deployment"
    ``` terraform
    --8<-- "docs/examples/kafka-connect/deployment.tf"
    ```
=== "Configmap"
    ``` terraform
    --8<-- "docs/examples/kafka-connect/configmap.tf"
    ```
=== "Secrets"
    ``` terraform
    --8<-- "docs/examples/kafka-connect/secrets.tf"
    ```

### Observability
!!! warning
    Before follow this section, you must [setup opentelemetry](opentelemetry.md) collector which is necessary to collect data from kafka connect.


``` terraform
ENABLE_OTEL = "true"
OTEL_SERVICE_NAME= "kafka-connect"
OTEL_TRACES_EXPORTER="otlp"
OTEL_METRICS_EXPORTER="otlp"
OTEL_PROPAGATORS="tracecontext"
OTEL_EXPORTER_OTLP_ENDPOINT="http://opentelemetry-collector.strimzi.svc.cluster.local:4317"
OTEL_TRACES_SAMPLER="always_on"
JAVA_TOOL_OPTIONS="-javaagent:./opentelemetry-javaagent.jar"
OTEL_INSTRUMENTATION_COMMON_DEFAULT_ENABLED="false"
OTEL_INSTRUMENTATION_MONGO_ENABLED="true"
OTEL_INSTRUMENTATION_KAFKA_ENABLED="true"
```

### High availability
To achieve high availability we must use multiple instance of kakfa connect (aka distributed mode). This can be
achieved by setting same group.id across multiple instance. In k8s we can increase the number of pods and kafka will
balance jobs of same group.id.
K8s cluster runs over multiple virtual machine (nodes), so we need to be tolerant to node fault. This can be achieved by using
pod anti-affinity in order to schedule pod execution on different nodes. 

This snippets allows to schedule pod execution on nodes which doens't already contains the same pod. For example, if you have 3 k8s nodes and 3 replica of kafka-connect pod, you will get each node runs a single pod.
``` terraform title="Affinity"
spec {
    affinity {
        pod_anti_affinity {
            required_during_scheduling_ignored_during_execution {
                topology_key = "kubernetes.io/hostname"
            }
        }
    }
    ...
}
```

In this way a fault of a single node will not affect kafka
connect cluster which has another pod instance running in another k8s node.

## Strimzi setup
TBD