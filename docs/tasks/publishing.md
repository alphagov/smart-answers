### Publishing

Changes to smart answer landing (or start) pages need to be sent to the Publishing API for them to appear on GOV.UK.

You will need the flow `name` and `content_id`, both of which can be found in the relevant Flow file, e.g. `ReportALostOrStolenPassportFlow`.

The [rake task `publishing_api:sync[FLOW_NAME]`](../../lib/tasks/publishing_api.rake) exists for this purpose, and needs to be run once you have deployed your changes. It can be run via Kubernetes as follows:

```bash
# For each ENVIRONMENT [integration, staging, production]...

# Ensure you are using the correct ENVIRONMENT
kubectl config use-context govuk-ENVIRONMENT
kubectl config current-context

# Get a temporary AWS token
export AWS_REGION=eu-west-1
eval $(gds aws govuk-ENVIRONMENT-developer -e --art 8h)

# Check the current value for your change in publishing-api
kubectl -n apps exec -it deploy/publishing-api -- rails c
Document.find_by(content_id: CONTENT_ID).editions.last

# Run the rake task
kubectl -n apps exec deploy/smartanswers -- rake 'publishing_api:sync[FLOW_NAME]'

# Make sure your changes have been updated correctly
kubectl -n apps exec -it deploy/publishing-api -- rails c
Document.find_by(content_id: CONTENT_ID).editions.last
```

If you have made multiple changes to a number of flows, there is also the [rake task `publishing_api:sync_all`](../../lib/tasks/publishing_api.rake) which sync's all flows with the Publishing API. It can be run as above substituting `publishing_api:sync[FLOW_NAME]` with `publishing_api:sync_all`.
