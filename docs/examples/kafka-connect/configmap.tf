resource "kubernetes_config_map" "kafka_connect_config" {
  count = 1
  metadata {
    name = "kafka-connect-config"
    namespace = "strimzi"
  }

  data = {
    GROUP_ID = "<cluster_id>" // e.g. rtd-cluster
    BOOTSTRAP_SERVERS = "<eventhub_name>.servicebus.windows.net:9093"
    CONFIG_STORAGE_TOPIC = "<name>-configs" // suggested to use same name
    OFFSET_STORAGE_TOPIC = "<name>-offsets"
    STATUS_STORAGE_TOPIC = "<name>-status"
    CONNECT_KEY_CONVERTER="org.apache.kafka.connect.json.JsonConverter"
    CONNECT_VALUE_CONVERTER="org.apache.kafka.connect.json.JsonConverter"
    # worker config
    CONNECT_SECURITY_PROTOCOL="SASL_SSL"
    CONNECT_SASL_MECHANISM="PLAIN"

    # producer config
    CONNECT_PRODUCER_SECURITY_PROTOCOL="SASL_SSL"
    CONNECT_PRODUCER_SASL_MECHANISM="PLAIN"

    # eventhub configs
    CONNECT_METADATA_MAX_AGE_MS: "180000"
    CONNECT_CONNECTIONS_MAX_IDLE_MS: "180000"
    CONNECT_MAX_REQUEST_SIZE: "1000000"
  }
}