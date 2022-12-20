import requests
import boto3

from botocore.handlers import disable_signing
s3 = boto3.resource('s3')
s3.meta.client.meta.events.register('choose-signer.s3.*', disable_signing)

allFiles = s3.Bucket("coderbytechallengesandbox").objects.all()
for file in allFiles:
  if "__cb__" in file.key:
    file_content = file.get()['Body'].read()
    print(file_content.decode('utf-8'))
