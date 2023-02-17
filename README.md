# End-to-End ML-OPS CICD Pipeline with Sagemaker, GithubActions & Terraform

## Objectives:

Orchestrate a full ML-Ops CI/CD Pipeline which is practical and beginner-friendly, while being able to clearly illustrate fundamental devops concepts

1. Ingest data from outside sources
2. Process the data into a suitable format ready to be consumed by ML engines
3. Setup relevant repository structure i.e. main / dev for the workflow
4. Implement core ML logic, which includes packaging our code as a docker container, uploading to ECR and having Sagemaker use that container to for running training jobs
5. Expose endpoints, for data scientists we will have the Sagemaker endpoints
6. Expose endpoints, for general users by implementing AWS Lambda + API Gateway Serverless architecture pattern
7. Propagate the results to all subscribers / services via AWS Lambda + SNS Topic pattern, these subscribers can be any services but to keep things simple we will send emails/notifications to users

## Tools:

Here we will summarize some of the tools used in this project:

-   **Planning**: This part is underrated but is essential to your success as an architect
	- [**Cloudcraft.co**](http://Cloudcraft.co)
	- Pen and Paper
-   **Development**: 
	- **VS Code** - VS Code has a lot of helpful extensions when working with AWS
	- **Make** - Makefiles help us run commands faster and save time
-   **Source Control Management**: 
	- **Github** - is the most easily accessible SCM, but you may also consider going for AWS CodeCommit if you plan to use AWS CodePipeline
-   **Data Ingestion**: 
	- **S3** 
	- **AWS DynamoDB**, RDS, Redshift, Kinesis - to keep things simple we will stick with S3 as the source of our data, but you may integrate other sources like Kinesis data streams or a DynamoDB table
-   **Infrastructure-as-Code**: 
	- **Terraform** - ease-of-use and its universality but you may also consider AWS SAM because it simplifies a lot of constructs we are using
-   **Packaging/Deployment:**  
	- **Docker + AWS ECR** - Docker is used in combination with **AWS ECR** (Elastic Container Registry) to build and host docker images
-   **CI/CD Orchestration**: 
	- **GithubActions** - Coming to the main part, we prefer to use GithubActions because of their simplicity to get things done fast while having a very gentle learning curve, I would also recommend CodePipeline if you are already using CodeBuild and CodeCommit
-   **AWS Services**
    -   **S3** - For data storage/ingestion
    -   **IAM** - for creating roles with relevant attached policies so we do not face any issues with permissions
    -   **ECR** - Docker image used by Sagemaker is stored on ECR
    -   **AWS Sagemaker** - for the core ML logic i.e. training the model, storing it and exposing an inference sagemaker endpoint
    -   **Lambda + API Gateway** - this creates the serverless architecture pattern which allows us to serve requests to users who wish to consume model output or wish to generate their own prediction results
    -   **AWS Lambda + SNS Topic** - This pushes the computed output to other services or in this case other subscriber users via email


![3d](assets/3d.png)
![2d](assets/2d.png)


# Issues:

1. add redshift/kinesis support
