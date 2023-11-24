resource "kubernetes_secret" "kafka_connect_secret" {
  metadata {
    name = "kafka-connect-secret"
    namespace = "strimzi"
  }
  data = {
    CONNECT_SASL_JAAS_CONFIG: "org.apache.kafka.common.security.plain.PlainLoginModule required username=\"$ConnectionString\" password=\"<ConnectionString>\";"
    CONNECT_PRODUCER_SASL_JAAS_CONFIG: "org.apache.kafka.common.security.plain.PlainLoginModule required username=\"$ConnectionString\" password=\"<ConnectionString>\";"
  }
}