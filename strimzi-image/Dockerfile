FROM gradle:8.4.0-jdk8-jammy@sha256:c10f5e897983c6b87008b2d604e6baf824d3d99d852543bc5cb3b6b1c45e5bcb as deps

WORKDIR /deps

COPY build.gradle build.gradle
RUN gradle getMongoKafkaConnectDeps

RUN curl -L "https://github.com/open-telemetry/opentelemetry-java-instrumentation/releases/download/v1.32.0/opentelemetry-javaagent.jar" \
    --output "opentelemetry-javaagent.jar" 

FROM quay.io/strimzi/kafka:0.38.0-kafka-3.6.0
USER root:root

COPY --from=deps /deps/mongo-kafka-connect/ /opt/kafka/plugins/
COPY --from=deps /deps/opentelemetry-javaagent.jar .

USER 1001