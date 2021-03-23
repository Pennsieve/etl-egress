#!/usr/bin/env python

import os
import unittest

# https://github.com/spulec/moto
#from moto import mock_sqs

from test.test_support import EnvironmentVarGuard
from egress.egress import Egress
from pprint import pprint

class ProcessEvent(unittest.TestCase):
    def setUp(self):
        ''' Set up test case '''

        self.etl = Egress()

        self.time         = '2017-10-23T17:56:03Z'
        self.job_id            = '4c7599ae-0a82-49aa-ba5a-4727fcce14a8'
        self.status            = 'READY'
        self.import_id         = 'b468a043-0a92-4496-802e-4a13b430068a' 
        self.organization_id   = '1000'
        self.package_id        = '10455'
        self.uploads_s3_key    = 'testing@pennsieve.com/b468a043-0a92-4496-802e-4a13b430068a/video1.avi'
        self.uploads_s3_bucket = 'pennsieve-ops'

        self.etl.EVENT = {
          'time': self.time,
          'detail': {
            'jobId': self.job_id,
            'status': self.status,
            'container': {
              'environment': [
                {
                  'name': 'IMPORT_ID',
                  'value': self.import_id
                },
                {
                  'name': 'ORGANIZATION_ID',
                  'value': self.organization_id
                },
                {
                  'name': 'PACKAGE_ID',
                  'value': self.package_id
                },
                {
                  'name': 'UPLOADS_S3_KEY',
                  'value': self.uploads_s3_key
                },
                {
                  'name': 'UPLOADS_S3_BUCKET',
                  'value': self.uploads_s3_bucket
                }
              ]
            }
          }
        }

    def test_create_egress_message(self):
        ''' Test the contract for the SQS consumer '''

        egress_message = {
          'UpdatePackageState': {
            'importId': self.import_id,
            'jobId': self.job_id,
            'organizationId': self.organization_id,
            'packageId': self.package_id,
            'state': self.status,
            'time': self.time,
            'uploadsS3Bucket': self.uploads_s3_bucket,
            'uploadsS3Key': self.uploads_s3_key
          }
        }

        self.etl._create_egress_message()

        check_lists = [
          ['importId',        self.import_id,         self.etl.EGRESS_MESSAGE['UpdatePackageState']['importId']],
          ['jobId',           self.job_id,            self.etl.EGRESS_MESSAGE['UpdatePackageState']['jobId']],
          ['organizationId',  self.organization_id,   self.etl.EGRESS_MESSAGE['UpdatePackageState']['organizationId']],
          ['packageId',       self.package_id,        self.etl.EGRESS_MESSAGE['UpdatePackageState']['packageId']],
          ['state',           self.status,            self.etl.EGRESS_MESSAGE['UpdatePackageState']['state']],
          ['time',            self.time,              self.etl.EGRESS_MESSAGE['UpdatePackageState']['time']],
          ['uploadsS3Bucket', self.uploads_s3_bucket, self.etl.EGRESS_MESSAGE['UpdatePackageState']['uploadsS3Bucket']],
          ['uploadsS3Key',    self.uploads_s3_key,    self.etl.EGRESS_MESSAGE['UpdatePackageState']['uploadsS3Key']]
        ]

        for check_list in check_lists:
            _expected_result = check_list[1]
            _actual_result   = check_list[2]
            _key             = check_list[0]

            self.assertEqual(_expected_result, 
                         _actual_result,
                         msg='Contract with sqs consumer broken: {} should be {} but received {}'.format(_key, _expected_result, _actual_result))
