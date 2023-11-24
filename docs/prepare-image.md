# Prepare docker image



## Kafka connect image
`kafka-connect-image` - Contains a Dockerfile to build a kafka-connect base image with official mongo db connector. It use Gradle to download dependecies from maven, also add opentelemetry java agent to jar in order to use it to instrument the connector.

```bash
cd kafka-connect-image
docker build -t cstarcommon.azure.io/kafka-connectors .
```
The docker build is multistage:

1. the first stage downloads connector jars using gradle. Also downloads opentelemetry-javaagent to use it later to instrument connector
2. the final stage use `debezium/connect-base` which is a base image of kafka connect and copy the connector from previous stage

## Strimzi image
TBD