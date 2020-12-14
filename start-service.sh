#!/bin/bash -xe
source /home/ec2-user/.bash_profile
cd /home/ec2-user/app/release
# Query the EC2 metadata service for this instance's region
TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"` \
REGION=`curl -H "X-aws-ec2-metadata-token: $TOKEN" -v http://169.254.169.254/latest/dynamic/instance-identity/document | jq .region -r`

# Query the EC2 metadata service for this instance's instance-id
export INSTANCE_ID=`curl -H "X-aws-ec2-metadata-token: $TOKEN" -v http://169.254.169.254/latest/dynamic/instance-identity/document | jq .instanceId -r`
# Query EC2 describeTags method and pull our the CFN Logical ID for this instance
export STACK_NAME=`aws --region $REGION ec2 describe-tags \
--filters "Name=resource-id,Values=${INSTANCE_ID}" \
          "Name=key,Values=aws:cloudformation:stack-name" \
  | jq -r ".Tags[0].Value"`
npm run start
