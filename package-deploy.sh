set -eu

#### CONFIGURATION SECTION ####
stack_name=$1
deployment_bucket=$2
#### CONFIGURATION SECTION ####

profile_name=$3

# Delete deploy dir if exists for a clean start
if [ -d ".deployment" ]; then rm -rf .deployment; fi

# Install dependencies from requirements-deploy.txt with container at python 3.9
docker run -v "/$(pwd)":/var/task "public.ecr.aws/sam/build-python3.9" \
        //bin/sh -c "pip install -r requirements-deploy.txt -t ./.deployment; exit"

# Copy src code into .deployment dir
cp -r ./src/cafe ./.deployment

# Package template and upload local resources to S3
# A unique S3 filename is automatically generated each time
aws cloudformation package --template-file cloudformation.yml \
    --s3-bucket ${deployment_bucket} \
    --output-template-file cloudformation-packaged.yml \
    --profile ${profile_name}

# Deploy template
aws cloudformation deploy --stack-name ${stack_name}-etl-app \
    --template-file cloudformation-packaged.yml --region eu-west-1 \
    --capabilities CAPABILITY_IAM --parameter-overrides NamePrefix=${stack_name} \
    --profile ${profile_name}

# Remove .deployment dir and packaged CloudFormation template
rm -rf .deployment
rm cloudformation-packaged.yml
