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

The template contains a two sections:
* **Parameters**: Parameters allow us to receive user inputs when we create out stacks.
* **Resources**: Resources describe the resources we want to deploy. We can reference parameters in the resources section using the `!REF` intrinsic function.

Upload your deployment template to S3 using the following command:
```
aws s3 cp templates/template1-s3-bucket.yaml s3://<bucket-name>/templates/template1-s3-bucket.yaml
```
Once the template has been uploaded to S3 you can create the CloudFormation stack.
```
aws cloudformation create-stack --stack-name <cf-stack-name> --template-url https://<bucket-name>.s3.eu-west-1.amazonaws.com/templates/template1-s3-bucket.yaml --parameters BucketName=<bucket-name> --region eu-west-1
```

**Exercise 1**: Extend this template by adding another parameter and S3 bucket. You will have to update the CloudFormation template, upload the revision to S3 and run the `aws cloudformation update-stack` command.

### Template2: Lambda Function



### Template3: Lambda Function 2












