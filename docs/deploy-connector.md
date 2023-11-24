# Deploy connector

Kafka connect expose a lot of REST API allowing to manage the connector lifecycle. You can create a connector
by making a POST or PUT http request.



!!! example
    Create a new connector or update an existing one with name `cosmos-connector`.
    
    ` PUT http://localhost:8083/connectors/cosmos-connector/config` with the following payload
    ``` json
    --8<-- "docs/examples/kafka-connect/mongo-connector-example.json"
    ```