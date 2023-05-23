#!/usr/bin/env python3
# Description: This script is used to get the DNS records from OVH API
import ovh

# Instanciate an OVH Client.
client = ovh.Client(
    endpoint='ovh-eu',  # Endpoint of API OVH Europe (List of available endpoints)
    application_key='cd5b04ffc8157cbf',  # Application Key
    application_secret='6e079cd046add6c3b1fa8a0ff656c2cb',  # Application Secret
    consumer_key='d575fa8443a3f420a2dc27144f769646',  # Consumer Key
)

result = client.get("/domain/zone/mocanupaulc.com/record", fieldType='A')
client.put('/domain/zone/mocanupaulc.com/record/{}'.format(result[0]), target='35.241.221.72',ttl=60)
client.put('/domain/zone/mocanupaulc.com/record/{}'.format(result[1]), target='35.241.221.72',ttl=60,subDomain='www')
refresh=client.post('/domain/zone/mocanupaulc.com/refresh')

