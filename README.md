# Task 1

## A. Apache Log 4xx 5xx error Counter

### Introduction

`count_errors.sh` is a bash script to be used with scheduling tools such as cron to periodically trigger the script.  The script splits (rotate) the log file into multiple dated files.  This allows for easy management and easy usage of the files during debugging.
<br/><br/>


### Executing the Code

Running the code:

        count_errors.sh <log file>

Example:

        count_errors.sh apache_log
        
<br/><br/>


### Configuration

`count_errors.sh` requires setup of default configuration as shown below.

        threshold=${THRESHOLD:-200}
        subject="<Alert> Some Message" 
        from=${FROM:-"someuser@domain.com"}
        to=${TO:-"someuser@domain.com"}

`threshold` sets the tolerance threshold that dictates the minumum number of errors that would tigger sending of the alert email message.

`subject` sets the subject of the alert email message to be sent when minimum number of errors are met or exeeded.

`from` sets the email sender value for alert emails to be sent.

`to` sets the email recepient value for alert emails to be sent.
<br/><br/>


### Runtime Environment

Default configurations can be overridden by environment values.

`THRESHOLD` environment variable overrides `threshold` default value.

`FROM` environment variable overrides `from` default value.

`TO` environment variable overrides `to` default value.
<br/><br/>


### Assumptions

`cron` calls the application properly with parameter pointing to the path of the log file to be checked.

The spacing or formatting of erroneous line follows the format presented in the sample output file.  The code assumes consistency with the current formatting and spacing.

The script assumes that mail credentials are setup on the machine to run the code and it is properly secured on the local machine while mail server is configured with ACL.
<br/><br/>


## B. Housekeeping

Some commented parts of the script could be used to easily and practically handle growing log storage.  Split dated files or rotated files can be immediately compressed for efficient local storage.

Compressed rotated files can also be moved to external storage such as S3 or NFS to further address growing local storage.  Movement to external archiving storage could be done immediately after assessment or depending on the age of the rotated log file.  S3 can be enabled with lifecycle to further allow automatic deletion of logs older than 7 years.
<br/><br/><br/>


---
<br/>


# Task 2

## Introduction

The [repository](https://github.com/sngsweekeat/one2onetool) was forked into [my own repo](https://github.com/galvezlj/one2onetool).  CICD was added to allow automation of build and deployment process to address the assignment requirements.
<br/><br/>


## How To Use

The project listens to changes on the `staging` and `release` branches.  Both of the branches triggers the common workflow or pipeline.  To observe the pipeline at work, one only needs to either commit a change to `staging` branch or merge changes into `release` branch.  (Ideally, commits should only be towards `devel` branch and only merges should be done for `staging` and `release` branches.)

After detecting activities in the `staging` and `release`, the pipeline automatically builds and stores artifacts.  The pipeline also automatically deploys to the target environment.  Functionality of the deployment can be observed by extracting the details of test `ALB` assigned to the deployment.  This ALB can be used to browse the service offered by the application

Use the alb `external link` details at the end of `Trigger deploy` step

        deployment.apps/one2onetool-deployment unchanged
        service/one2onetool-service unchanged
        external link:
        a34c4b41734324659ab4861dd29569f2-848373920.ap-southeast-1.elb.amazonaws.com

staging external link: <br/>
a70137b05db5e4639842cddc6e8f1580-1966365122.ap-southeast-1.elb.amazonaws.com

release external link: <br/>
a34c4b41734324659ab4861dd29569f2-848373920.ap-southeast-1.elb.amazonaws.com
<br/><br/>


## Details

### The CICD

Github Actions was chosen for the CI automation for the purpose of this exercise.  Any CICD tools can be utilised to achieve the same goal.  Github actions offers completely free automation service without the need to spin costing resources.

For different circumstances, applications and environments, running other automations such as Jenkins could be more appropriate.

The automation uses single [workflow](https://github.com/galvezlj/one2onetool/blob/master/.github/workflows/node.js.yml) to complete the the whole process of building and deploying to target environments.
<br/><br/>


### The Pipeline

The pipeline streamlines test stages to ensure quality of the `release`.  The pipeline listens to changes on `staging` and `release` branches.  Changes to these branches will trigger targetted build based on the branch that had been modified and automated deployment to respective environments.

In cases of failures during the processing of the pipeline, the process will automatically send out alert emails.
<br/><br/>


### Gitflow `release` Process

The gitflow requires that changes must be done and tested on the develop branch bfore the changes are merged into `staging`.  After testing the `staging` branch on `UAT` environment, changes are then merged to the `release` branch for deployment to `PROD` environment.
<br/><br/>


### Security

All the credentials utilised by the pipeline are imported and secured as repository's secrets.  As best practice dictates, the secrets imported must have least required privileges to lessen impact radius in cases of leaks.

Logical separation was put in place using `namespace` to demonstrate some level of logical segregation for security.  This would, to some level, offer isolation of the production environment.
<br/><br/>


### High Availablity and Scalability

The project demonstrates high availability by utilising the EC2 ASG and K8S HPA.  Multiple replicas were deployed to demonstrate redundancy.  ASG and HPA allows for multiple levels of automatic horizontal scaling.
<br/><br/>


### Configurability

Helm templating was adopted to allow easy templating for resuability to target varying environments and applications.

The template currently demonstrates build time configuration configurability to target either `UAT` and `PROD` environments.  It also demonstrates reusability and configurability using application specific configurations for a reusable helm template.

Helm tempate could be spun as separate repo and could be utilised as common tempate for other services or microservices.
<br/><br/>


### Cost

For the sake of this project, higher importance is given to cost having very limited budget and resource.

Github Actions was chosen because it is free.

Single EKS cluster was utilised instead of separate cluster for `PROD` and `UAT` to lower the cost.  Ideally, `PROD` must have wider logical or physical deparation from any non-`PROD` environment.

Only 2 replicas were created to minimally demonstrate redundancy to keep the cost of the demo low.
<br/><br/>


### Platform

The EKS cluster and the limited amount of AWS resources were created for the sole purpose of the project.

AWS was chosen as the most commonly utilised cloud provider my most companies.  Any cloud provider cold be used.

EKS was chosen over ECS as EKS, being kubernetes, is more commonly used platform.

The whole test platform was brought up completely using terraform.  This Infra-As-Code demonstrates disposable and repeatable on-demand environment.
<br/><br/>


### TODO

Number of replicas must be defined based on the criticality of the system and its users.  From which, required availability, responsiveness can be defined to suggest the required redundancy, tolerance, recoverability.  These information can help define the required number of replicas and sensitivity of the autoscaling.

`PROD` and non-`PROD` should have wider separation.  The production environment should have its own cluster for isolation.  This is to lessen the impact of non-`PROD` activities and problems to the production workload.

CD should rely on immutable deployments.  Common images should be used to traverse environment promotion rather than having separate images for `staging` and `release` branch.  It is required in best practice to ensure that the deployment being promoted to higher enviroment to be tested first in lower environments.  This can be perfectly achieved by making sure that all environments should use same pool of immutable image artifacts.  CD should center on the immiutable deployments such as container images in the container repositories.

CI should center on development that creates single immutable and configurable output to target all the higher environments.

CI and CD should be decoupled as latter part of the CD requires higher criticality credentials that require higher security.  This separation adheres closely to roles and responsiblity segregation.

Approval process must be included and streamlined in the pipeline to ensure proper compliance to change policy.

Better versioning scheme could be used both on the github repo and docker hub.  Using human readable versions could better be interpreted and handled over commit hashes.

