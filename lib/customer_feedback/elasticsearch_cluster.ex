defmodule CustomerFeedback.ElasticsearchCluster do
  use Elasticsearch.Cluster, otp_app: :customer_feedback
end
