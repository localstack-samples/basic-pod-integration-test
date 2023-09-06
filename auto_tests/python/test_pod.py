import boto3
import requests
import simplejson as json

from utils import get_logger

logger = get_logger.logger()


class TestBasicPodUsage:

    def test_pod(self):
        """
        The LocalStack Cloud Pod was loaded before the tests are run. It contains a bucket called "testpod"
        and an object in that bucket called "hello-world.txt" with the text "hello world" in it.

        This test
        - asserts that the bucket exists
        - asserts that the object hello-world.txt is in the bucket
        - asserts that the text "hello world" is in the hello-world.txt object
        :return:
        """
        # Name of the S3 bucket and object to download
        bucket_name = 'testpod'
        object_name = 'hello-world.txt'

        session = boto3.session.Session(profile_name='localstack')
        s3 = session.resource(
            service_name='s3',
        )
        # Print out bucket names
        result = next((bucket for bucket in s3.buckets.all() if bucket.name == bucket_name), None)
        assert result is not None
        assert result.name == bucket_name

        s3_client = session.client(service_name="s3")
        # Download the object into memory
        response = s3_client.get_object(Bucket=bucket_name, Key=object_name)
        content = response['Body'].read().decode('utf-8')
        assert "hello world" in content