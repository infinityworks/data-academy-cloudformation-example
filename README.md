# data-academy-cloudformation-example

A repository to demonstrate a simple CloudFormation repo for the data academy. The AWS Documentation on CloudFormation is very extensive and can be found [here](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/Welcome.html).
## Quick Start:

Clone this repo to your local machine using the following command:

```
git clone git@github.com:infinityworks/data-academy-cloudformation-example.git
```
## Pre-requisites

### AWS CLI:
Double check you have a working installation of the AWS CLI:
```
❯ aws --version
aws-cli/2.4.10 Python/3.9.9 Darwin/20.6.0 source/x86_64 prompt/off
```
### AWS Authorisation:
If you have already setup an SSO profile skip to step 10
1. On a terminal run: `aws configure sso`
2. Enter your SSO (Single Sign-On) URL.
3. Enter the SSO Region: `eu-west-1`
4. A web page will open asking you to sign into the AWS CLI, click the *Sign in to AWS CLI* button.
5. Looking back at your terminal, select a valid role.
6. When the terminal asks for a CLI default client region, hit enter.
7. When the terminal asks for a CLI default output, hit enter.
8. When the terminal asks for a CLI profile name, enter a name: e.g. learner-profile
9. You can log out of your SSO by running the following command: `aws sso logout`
10. You can then login again by running: `aws sso login --profile <profile-name>`
11. Check you can access AWS using the following command: `aws s3 ls --profile <profile-name>`. The command should list all the S3 buckets in the AWS account you have permissions to view. Validate this output using the AWS console.
12. Finally set the following environmental variable: `AWS_PROFILE=<profile-name>`. This will save you adding the profile flag to every CLI command.

## Deploying your first CloudFormation Stacks:

It is possible to configure and deploy CloudFormation stacks in the AWS console however we want to configure them using CloudFormation templates within our repos. A CloudFormation template is a declaration of AWS resources that make up a stack. The template is stored as either a JSON or YAML file, since they are just text files they can be edited using any text editor and managed in your source control system with the rest of your code.

Before we can deploy our templates we must first upload them to S3. If you haven't already done so, create an S3 bucket for your templates. You can do this in the AWS console or using the following CLI command:
```
aws s3 mb s3://<bucket-name> --region eu-west-1
```

### Template1: S3 Bucket

The first and simplest CloudFormation template you will deploy can be found [here](templates/template1-s3-bucket.yaml).

The template contains one section:
* **Resources**: Resources describe the resources we want to deploy. You will need to update the bucket name in the template.

Upload your deployment template to S3 using the following command:
```
aws s3 cp templates/template1-s3-bucket.yaml s3://<bucket-name>/templates/template1-s3-bucket.yaml
```
Once the template has been uploaded to S3 you can create the CloudFormation stack.
```
aws cloudformation create-stack --stack-name <cf-stack-name> --template-url https://<bucket-name>.s3.eu-west-1.amazonaws.com/templates/template1-s3-bucket.yaml --region eu-west-1
```

**Exercise 1**: Extend this template by adding another S3 bucket. You will have to update the CloudFormation template, upload the revision to S3 and run the `aws cloudformation update-stack` command.

### Template2: Lambda Function

The second CloudFormation template you will deploy can be found [here](templates/template2-lambda.yaml).

The template only contains a resources section. There are two resources being deployed:
* **Lambda Function Role**: The functions execution role, this dictates what the function can and cannot do within the AWS account.
* **Lambda Function**: The lambda function itself.

Upload the deployment template to S3, using the same commands as above, and create a new CloudFormation stack. Once the CloudFormation stack has been deployed, manually invoke the lambda in the console (or using the CLI). N.B. When deployinbg roles using CloudFormation you must also include the following flag: ` --capabilities CAPABILITY_IAM`.

**Exercise 2**: Extend the function code to list all objects in a specified S3 bucket. You will need to use Boto3 to do this. The required function can be found [here](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/s3.html#S3.Client.list_objects). Since the function is now interacting with S3, you will also need to update the function role. Add a new policy to the lambda execution role, similar to the LambdaLogsPolicy which adds the permissions to list s3 objects. This [guide](https://aws.amazon.com/premiumsupport/knowledge-center/lambda-execution-role-s3-bucket/) will help.

### Template3: Lambda Function with S3 Trigger

The third CloudFormation template builds upon the second but includes an S3 event trigger which invokes the function.

The following resources are being deployed, you will need to update the S3 bucket name:
* **Lambda Function Role**
* **Lambda Function**
* **S3 Bucket**: A regular S3 bucket which contains a notification configuration.
* **Lambda Permission**: The permission resource grants an AWS service or another account permission to use a function. In this instance the S3 bucket is granted permissions to invoke the lambda.

N/B The S3 Bucket has a notification configuration which is commented out. Due to a bug in CloudFormation you must first deploy the stack without S3 bucket notification, uncomment the notification configuration and update the stack.

Upload the deployment template to S3, using the same commands as above, and create a new CloudFormation stack. Once the CloudFormation stack has been deployed, manually invoke the lambda by uploading a file into the S3 bucket. Deconstruct the event and identify the s3 bucket and s3 key.

**Exercise 3**: Extend the function code to download the S3 object in the event to the `/tmp` directory of the lambda. You will need to use boto3 to do this. The required function can be found [here](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/s3.html#S3.Client.download_file). Since the function is now interacting with S3, you will also need to update the permissions to get S3 objects. Assert that the file has been downloaded and log the results.



### Template4: Lambda Deployment Packages

You will often want to use external Python packages in your lambda functions (Pandas, Requests, etc.). To use additional packages in your lambda functions you must build a deployment package and upload it to S3.

To build a deployment package using a docker container follow these steps, the advantage of using a docker container over a virtual environment is a consistent environment.
```
docker run -v "$PWD":/var/task "lambci/lambda:build-python3.8" /bin/sh -c "pip install -r requirements.txt -t package/; exit"
cd package
zip -r ../deployment_package.zip .   
zip -g deployment_package.zip lambda_function.py
```

Template 4 builds on template 3 but uses a deployment package on S3 to deploy the lambda. Rather than hard coding the S3 bucket names, you will be using parameters. Parameters allow user inputs while the stack is being created.

```
aws cloudformation create-stack --stack-name <cf-stack-name> --template-url https://<bucket-name>.s3.eu-west-1.amazonaws.com/templates/template4-lambda-s3.yaml --region eu-west-1 --parameters ParameterKey=DeploymentBucket,ParameterValue=<BUCKET> ParameterKey=DeploymentPackageKey,ParameterValue=<KEY> ParameterKey=BucketName,ParameterValue=<BUCKET> --capabilities CAPABILITY_IAM
```

**Exercise 4**: Update the *lambda_function.py* file to use pandas to read a csv file from the `/tmp` directory. Log the dataframe head. Once you've updated the lambda function, create a deployment package as per the above steps. Upload the deployment package to the same S3 bucket where you are deploying your templates. Finally create a new stack for template 4 with the relevent parameters.



















