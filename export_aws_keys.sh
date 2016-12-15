#!/bin/bash
PROFILE="$1"
AWSBIN=$(which aws)
if [[ -z $PROFILE ]] ; then
 echo "No Profile provided. Clearing ENV variables"
 echo -e "please specify the AWS profile\n${0} <profile_name>"
 export AWS_ACCESS_KEY_ID=""
 export AWS_SECRET_ACCESS_KEY=""
 exit 1
fi
echo "Exporting credentials to ENV for profile $PROFILE"
AWS_ACCESS_KEY_ID=$($AWSBIN configure get aws_access_key_id --profile $PROFILE)
AWS_SECRET_ACCESS_KEY=$($AWSBIN configure get aws_secret_access_key --profile $PROFILE)
export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
