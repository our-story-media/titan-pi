# Indaba Titan Raspberry PI Install

[![Build Status](https://dev.azure.com/ourstorytitan/OurStoryBuilds/_apis/build/status/our-story-media.titan-pi?branchName=master)](https://dev.azure.com/ourstorytitan/OurStoryBuilds/_build/latest?definitionId=13&branchName=master)

Download the SD Card image at https://d2co3wsaqlrb1k.cloudfront.net/indaba-rpi.zip and then use [Balena Etcher](https://www.balena.io/etcher/) to copy it to an SD card.

# DevOps

Before deploying a new version of Indaba Titan, the indaba-titan.tar docker image needs updating to S3. Use the scripts in the ourstory-server repository to perform this update.

This repo is built in Azure Pipelines. It produces a single .zip file, first downloading the latest version of the indaba-titan.tar docker update image from S3. The name of the .zip file produced will contain the versions of both indaba-server and indaba-worker that the image contains. This file is then uploaded to S3, and copied to indaba-rpi.zip. This zip file can be flashed directly onto an SD card for use in a rapsberry pi.

<!-- To bootstrap installer, run

`curl -sSL https://raw.githubusercontent.com/our-story-media/ourstory-titan/master/install/gettitan | sh` -->
