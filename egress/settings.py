#!/usr/bin/env python

import os
import logging
import logging.config
import time

class UTCFormatter(logging.Formatter):
    converter = time.gmtime

class Logging(object):
    def __init__(self, import_id=None):
        log_level = os.environ.get('LOG_LEVEL', 'INFO')

        LOGGING = {
            'version': 1,
            'disable_existing_loggers': False,
            'formatters': {
                'utc': {
                    '()': UTCFormatter,
                    'format': '[%(asctime)s.%(msecs)03dZ] [%(levelname)s] [%(module)s] [{}] - %(message)s'.format(import_id),
                    'datefmt': '%Y-%m-%dT%H:%M:%OS'
                }
            },
            'handlers': {
                'pennsieve': {
                    'class': 'logging.StreamHandler',
                    'formatter': 'utc',
                }
            },
            'root': {
                'handlers': ['pennsieve'],
                'level': log_level,
           }
        }

        logging.config.dictConfig(LOGGING)
        self.logger = logging.getLogger()
