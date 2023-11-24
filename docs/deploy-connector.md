# Deploy connector

Kafka connect expose a lot of REST API allowing to manage the connector lifecycle. You can create a connector
by making a POST or PUT http request.



!!! example
    Create a new connector or update an existing one with name `cosmos-connector`.
    
    ` PUT http://localhost:8083/connectors/cosmos-connector/config` with the following payload
    ``` json
    --8<-- "docs/examples/kafka-connect/mongo-connector-example.json"
    ```

In the example, the most importat configuration are:
- `connection.uri: ${env:COSMOS_CONNECTION_STRING}` - this will resolve the connection string with the environment variable value
- `pipeline` -  is the pipeline used by mongo to make `watch` method call. The pipeline must be equals as the one repoted by microsoft documention
- `output.schema.key` - allows to define the partition key used by kafka producer
- heartbeat - allows to prevent an [invalid token](https://www.mongodb.com/docs/kafka-connector/current/troubleshooting/recover-from-invalid-resume-token/#prevention). This require an additional topic to keep heartbeats