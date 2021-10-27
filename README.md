# Indaba Titan Raspberry PI Install

[![CircleCI](https://circleci.com/gh/our-story-media/titan-pi/tree/master.svg?style=svg)](https://circleci.com/gh/our-story-media/titan-pi/tree/master)

Download the SD Card image at https://download.indaba.dev/indaba-rpi.zip and then use [Balena Etcher](https://www.balena.io/etcher/) to copy it to an SD card.

# DevOps

Before deploying a new version of Indaba Titan, the indaba-titan.tar docker image needs updating to S3. Use the scripts in the ourstory-server repository to perform this update.

This repo is built in CircleCI. It produces a single .zip file, first downloading the latest version of the indaba-titan.tar docker update image from S3. The name of the .zip file produced will contain the versions of both indaba-server and indaba-worker that the image contains. This file is then uploaded to S3, and copied to indaba-rpi.zip. This zip file can be flashed directly onto an SD card for use in a rapsberry pi.

<!-- To bootstrap installer, run

`curl -sSL https://raw.githubusercontent.com/our-story-media/ourstory-titan/master/install/gettitan | sh` -->

## On-Boot

On first startup of the PI, the `gettitan` bash script runs.

It does a number of basic things like expending the filesystem, then:

1. Checks if the indaba-titan:latest image exists in the local dock install.

2. If not, it attempts to load this file from the local .tar file that came with the install in /indaba

3. Once complete, it runs the docker stack.

4. It then runs the `indaba-supervisor` app in the background.

From then on, when the device boots, it runs the docker stack straight away and starts the app.

## indaba-supervisor

Once the PI is running after the first time, the `indaba-supervisor` application maintains a watch on inserted USB drives.

Once a drive is inserted, it does the following:

### Backup Logs

1. Copies runtime logs to drive (i.e. the output of the getttian script and indaba-supervisor)

2. Dumps the docker log to the drive.

### Update Application

If the drive contains a file called `indaba-update.tar` in the root, it stops the current stack, loads the new tar file as an image into docker and removes the installed flag and reboots. This then triggers the gettitan script to re-load the stack fresh with the new version (whilst maintaining the data).

### Emergency Asset Copy

If the drive contains a file called `EMERGENCYBACKUP`, then the assets directory (i.e. videos, content) will be directly copied to the drive. This method is only to be used when the Indaba application cannot be started, and the UI for normal backups be used.
