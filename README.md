
# Introduction
To support multiple VMs, please find out the full details: https://medium.com/@cyanzhoufeng/gcp-put-your-staging-env-into-sleep-mode-during-non-working-hours-bc557673028d
This code is used to achieve the functions described in this Medium article

## The code is to enhance the existing function Scheduling Compute Instances with Cloud Scheduler

Below is the original README of the sample code, it also includes the instruction

======================Quote started===================

<img src="https://avatars2.githubusercontent.com/u/2810941?v=3&s=96" alt="Google Cloud Platform logo" title="Google Cloud Platform" align="right" height="96" width="96"/>

# Google Cloud Functions - Scheduling GCE Instances sample

## Deploy and run the sample

See the [Scheduling Instances with Cloud Scheduler tutorial][tutorial].

[tutorial]: https://cloud.google.com/scheduler/docs/scheduling-instances-with-cloud-scheduler

## Run the tests

1. Read and follow the [prerequisites](../../#how-to-run-the-tests).

1. Install dependencies:

        npm install

1. Run the tests:

        npm test

## Additional resources

* [GCE NodeJS Client Library documentation][compute_nodejs_docs]
* [Background Cloud Functions documentation][background_functions_docs]

[compute_nodejs_docs]: https://cloud.google.com/compute/docs/tutorials/nodejs-guide
[background_functions_docs]: https://cloud.google.com/functions/docs/writing/background

======================Quote ended===================

## Usage
Checkout the code
```
git clone git@github.com:CyanZero/gcp-vms-sleep.git
```
No need to install as the code will be uploaded to GCP Cloud Function, so run the below Gloud API  (Need to install GCloud util first)
```
gcloud functions deploy startInstancePubSubMul \
    --trigger-topic start-instance-event \
    --runtime nodejs6 \
    --region asia-northeast1
gcloud functions deploy stopInstancePubSubMul \
    --trigger-topic start-instance-event \
    --runtime nodejs6 \
    --region asia-northeast1
```
### Verify the new created Cloud function
```
# The zone value depends on your actual settings
data=$(echo '{ "zone": "YOUR_ZONE", "instances": ["instance-a", "instance-b"] }' | base64)
# Notice the limited support for the cloud function, and the region used here is asia-northeast1
gcloud functions call stopInstancePubSub \
 - region asia-northeast1 \
 - project YOUR_PROJECT_NAME \
 - data '{"data":$data}'
# Check if the instances are in terminated statusgcloud compute instances describe instance-a \
    --zone YOUR_ZONE \
    | grep status
status: TERMINATED
```
### Addition Shell scripts if you want to automate remove/add VMs process
```
bash mul_sleep_scheduler.sh dev "YOUR_ZONE" "instance-a instance-b"
```
