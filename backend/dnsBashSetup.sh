#!/bin/bash

# Set the API endpoint and credentials
ENDPOINT="ovh-eu"
APPLICATION_KEY="cd5b04ffc8157cbf"
APPLICATION_SECRET="6e079cd046add6c3b1fa8a0ff656c2cb"
CONSUMER_KEY="d575fa8443a3f420a2dc27144f769646"

# Make the API request using curl
response=$(curl -X GET -H "X-Ovh-Application: $APPLICATION_KEY" -H "X-Ovh-Timestamp: $(date +%s%3N)" -H "X-Ovh-Signature: $APPLICATION_SECRET+$CONSUMER_KEY+GET+/domain/zone/mocanupaulc.com/record" -H "X-Ovh-Consumer: $CONSUMER_KEY" "https://api.$ENDPOINT/1.0/domain/zone/mocanupaulc.com/record?fieldType=A")

# Parse the JSON response using jq
result=$(echo "$response" | jq .)

# Pretty print the result
echo "$result"
