# Indaba Titan Raspberry PI Install

[![Build Status](https://dev.azure.com/ourstorytitan/OurStoryBuilds/_apis/build/status/our-story-media.titan-pi?branchName=master)](https://dev.azure.com/ourstorytitan/OurStoryBuilds/_build/latest?definitionId=13&branchName=master)

Download the SD Card image at https://d2co3wsaqlrb1k.cloudfront.net/indaba-rpi.zip and then use [Balena Etcher](https://www.balena.io/etcher/) to copy it to an SD card.

# DevOps

This repo is built in Azure Pipelines. It produces a single .img file, first downloading the latest version of the indaba-titan.tar docker update image. The name of the .img file produced will contain the versions of both indaba-server and indaba-worker that the image contains.

<!-- To bootstrap installer, run

`curl -sSL https://raw.githubusercontent.com/our-story-media/ourstory-titan/master/install/gettitan | sh` -->