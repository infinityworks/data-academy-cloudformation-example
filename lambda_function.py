import logging
import boto3
import pandas as pd

LOGGER = logging.getLogger()
LOGGER.setLevel(logging.INFO)

def handler(event, context):
    LOGGER.info(f'Event structure: {event}')

    # Use boto3 to download the event s3 object key to the /tmp directory.

    # Use pandas to read the csv.

    # Log the dataframe head.