#!/usr/bin/env python
'''Output ETL process update'''

# SEND ERROR for FAILURE
# SEND READY for SUCCESS

from pprint import pprint

import json
import logging
import os
import sys
import time
import boto3

from settings import Logging

logger = Logging().logger

def lambda_handler(event=None, context=None):
    '''Start AWS Lambda Function'''

    try:
        if 'aws.batch' == event['source']:
            _batch_event(event)
        if 'aws.ecs' == event['source']:
            _ecs_event(event)
    except KeyError:
        print(json.dumps(event))
        #if 'aws.sns' == event['source']:
        #    _sns_event(event)

def _batch_event(event):
    event = event['detail']
    event.pop('attempts', None)
    event['job_definition'] = event.pop('jobDefinition')
    event['job_id'] = event.pop('jobId')
    event['job_name'] = event.pop('jobName')
    event['job_queue'] = event.pop('jobQueue')

    batch_event = { 
        'batch': event,
        'timestamp': get_time(),
    }

    command = [command.split() for command in batch_event['batch']['container']['command'] if 's3' in command]
    location = [location for location in command[0] if 's3://' in location]
    import_id = location[0].split('/')[4]
    batch_event['pennsieve'] = {'import_id': import_id}

    print(json.dumps(batch_event))

def _ecs_event(event):
    event = event['detail']

    ecs_event = { 
        'fargate': event,
        'timestamp': get_time(),
    }

    if any(d['name']== 'IMPORT_ID' for d in ecs_event['fargate']['overrides']['containerOverrides'][0]['environment']):
        import_id = ecs_event['fargate']['overrides']['containerOverrides'][0]['environment'][0]['value']
        ecs_event['pennsieve'] = {'import_id': import_id}

    print(json.dumps(ecs_event))

def _sns_event(event):
    event = event['Records'][0]['Sns']['Message']

    sns_event = { 
        'pennsieve': event,
        'timestamp': get_time(),
    }

    if any(d['name']== 'IMPORT_ID' for d in ecs_event['fargate']['overrides']['containerOverrides'][0]['environment']):
        import_id = ecs_event['fargate']['overrides']['containerOverrides'][0]['environment'][0]['value']
        ecs_event['pennsieve'] = {'import_id': import_id}

    print(json.dumps(ecs_event))

def get_time():
    ts = int(round(time.time() * 1000))
    return ts

if __name__ == '__main__':
    with open('example.json', 'r') as content_file:
        event = content_file.read()
    lambda_handler(json.loads(event))

