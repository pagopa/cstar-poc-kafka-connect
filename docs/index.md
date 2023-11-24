# Kafka Connect POC
The poc is intended to deploy k8s cluster an instance of kafka connect.
Actually, the main target of kafka connect is a cosmos mongodb api instance using the official mongo kafka connect at 1.5.1 version.

![Architecture](images/connect.png)

## Project folders
* `kafka-connect-image` - Contains a Dockerfile to build a kafka-connect base image with official mongo db connector. It use Gradle to download dependecies from maven, also add opentelemetry java agent to jar in order to use it to instrument the connector.
