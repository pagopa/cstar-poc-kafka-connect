# Setup OpenTelemetry collector
TBD diagram

In order to collect traces from kafka-connect and send it to azure appinsight we must setup an opentelemetry collector.
The community offers an easy to use helm chart to configure a collector. The example shows a terraform code to deploy the helm chart
and a configuration (`values.yml`) of collector.

=== "Terraform helm chart"
    ``` terraform
    resource "helm_release" "opentelemetry_collecotr" {
    chart      = "opentelemetry-collector"
    name       = "opentelemetry-collector"
    repository = "https://open-telemetry.github.io/opentelemetry-helm-charts"
    version    = "0.73.1"

    namespace = "..."

    values = [
        templatefile("values.yml", {
                azure_monitor_connection_string : "<instrumentation_key>"
            })
        ]
    }
    ```
=== "Collector configuration"
    ``` yaml
    --8<-- "docs/examples/opentelemetry/values.yml"
    ```   
    

This configuration allows the collector to receive data related to metrics, traces and logs from an OTLP endpoint. The endpoint
is exposed through grpc on 4317 port. To enable export to azure we use the `contrib` implementation of azure exporter which requires appinsight's instrumentation key.

In `service.pipelines` you can define the flow of your data starting from receiver, processor and exporter. For example
this snippet instrunct the collector to receive traces from otlp endpoint and exports it to debug (console print) and to azuremonitor.
```yaml 
traces:
    receivers: [otlp]
    exporters: [debug, azuremonitor]
```

## Prometheus receiver
In order to collect JMX exposed metrics through prometheus we must setup collecto to capture prometheus metrics from pods.

TBD