"""
bedrock-asset-processor

Triggered by object creation events in the Bedrock assets bucket.
Logs the name of each uploaded file to CloudWatch Logs.
"""

import logging
import urllib.parse

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def handler(event, context):
    records = event.get("Records", [])

    if not records:
        logger.warning("Event contained no S3 records")
        return {"statusCode": 200, "processed": 0}

    for record in records:
        bucket = record["s3"]["bucket"]["name"]

        # S3 event keys are URL encoded, so "my file.png" arrives as
        # "my+file.png". Decoding gives the name the user actually used.
        key = urllib.parse.unquote_plus(record["s3"]["object"]["key"])

        logger.info("Image received: %s", key)
        logger.info("Source bucket: %s", bucket)

    return {"statusCode": 200, "processed": len(records)}
