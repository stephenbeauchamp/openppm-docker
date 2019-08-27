# An OpenPPM Container
## openppm-docker
A simple docker file to make a container running OpenPPM. Not recommended for production, but ideal for trials and testing.

##How to run
Once you have docker installed issue this command
$ sudo docker run --name openppm -d -p 8080:8080 stephenbeauchamp/openppm:latest

Wait for the container to start up then access the site from your browser on port 8080

## GCP Cloud Run
If you use GCP you can deploy this container with Cloud Run.

[![Run on Google Cloud](https://storage.googleapis.com/cloudrun/button.svg)](https://console.cloud.google.com/cloudshell/editor?shellonly=true&cloudshell_image=gcr.io/cloudrun/button&cloudshell_git_repo=https://github.com/stephenbeauchamp/openppm-docker.git)
