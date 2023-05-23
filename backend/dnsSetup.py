#!/usr/bin/env python3
# Description: This script is used to get the DNS records from OVH API
import json
import ovh

# Instanciate an OVH Client.
# You can generate new credentials with full access to your account on
# the token creation page
client = ovh.Client(
    endpoint='ovh-eu',               # Endpoint of API OVH Europe (List of available endpoints)
    application_key='cd5b04ffc8157cbf',    # Application Key
    application_secret='6e079cd046add6c3b1fa8a0ff656c2cb', # Application Secret
    consumer_key='d575fa8443a3f420a2dc27144f769646',       # Consumer Key
)

result = client.get('/domain'['None'])
print(client)

# Pretty print
print(result)
print(json.dumps(result, indent=4))
