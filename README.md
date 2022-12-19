# CustomerFeedback

Perform
* Receiving customer feedback and putting it into Elastic search
* Expose Admin interface to watch customer feedbacks
* Expose User interface for managing exact company feedbacks and interface

# Project setup

Prepare application itself

```bash
asdf install
mix setup
```

Run related services. Run in the separated terminal

```
docker-compose up
```

Run server itself

```
mix phx.server
```

Now you can visit the server http://localhost:4000/



## External services

### RabbitMQ    
Located at https://localhost:15672/   
Credentials: guest:guest

### Elasticsearch

Located at https://localhost:9200/

### Create index for elasticsearch

To create necessary index please built in Elasticsearch mix task

```
mix elasticsearch.build feedback_documents --cluster CustomerFeedback.ElasticsearchCluster
```

### Load Testing

For testng purposes and filling database with random data, there was created the script,
that full database with fake data.
As performance testing framework - used k6.

To run testing, you can run:

```
k6 run --vus 10 --rps 200 --duration 10s ./load_testing/test_feedbacks.js
```

