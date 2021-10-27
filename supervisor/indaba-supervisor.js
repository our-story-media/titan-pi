require("console-stamp")(console);
const drivelist = require("drivelist");
const _ = require("lodash");
const util = require("util");
const exec = util.promisify(require("child_process").exec);
const fs = require("fs-extra");
const path = require("path");
const express = require("express");
const webpage = fs.readFileSync(path.join(__dirname, "index.html")).toString();
let servers = [];
const version = require(path.join(__dirname, "package.json"));

let numdrives = -1;
let alreadyprocessing = false;
let currentPercentage = "0";

function runExec(cmd) {
  const exec = require("child_process").exec;
  return new Promise((resolve, reject) => {
    exec(cmd, (error, stdout, stderr) => {
      if (error) {
        console.warn(error);
      }
      resolve(stdout ? stdout : stderr);
    });
  });
}

function runExecResult(cmd) {
  const exec = require("child_process").exec;
  return new Promise((resolve, reject) => {
    exec(cmd, (error, stdout, stderr) => {
      // if (error) {
      //   console.warn(error);
      // }
      resolve(error ? false : true);
    });
  });
}

function runExecProgress(cmd) {
  const exec = require("child_process").exec;
  return new Promise((resolve, reject) => {
    let proc = exec(cmd, (error, stdout, stderr) => {
      if (error) {
        console.warn(error);
      }
      resolve(stdout ? stdout : stderr);
    });
    proc.stderr.on("data", (chunk) => {
      try {
        currentPercentage = chunk.split("\n")[0];
      } catch {
        currentPercentage = chunk;
      }
    });
  });
}

function startServer() {
  console.log("Starting mini server on :80 and :8845");

  try {
    app = express();

    app.get("*", function (req, res) {
      res.send(webpage.replace("{{percentage}}", currentPercentage));
    });

    servers.push(app.listen(80));
    servers.push(app.listen(8845));
  } catch (e) {
    console.error(e);
  }
}

function stopServer() {
  console.log("Stopping mini server on :80 and :8845");
  try {
    servers.forEach((element) => {
      element.close();
    });
    servers = [];
  } catch (e) {
    console.error(e);
  }
}

async function update(pathin) {
  console.log("Backup Logs...");

  let logdir = `logs-${Math.floor(Date.now() / 1000)}`;
  let backupdir = `backup-${Math.floor(Date.now() / 1000)}`;

  console.log(`Creating ${logdir}`);

  try {
    await fs.ensureDir(`${path.join(pathin, "indaba-logs", logdir)}`);
  } catch (e) {
    console.error(e);
  }

  console.log("Copying local logs...");
  try {
    await runExec(
      `cp /indaba/*.log "${path.join(pathin, "indaba-logs", logdir)}"`
    );
  } catch (e) {
    console.error(e);
  }

  console.log("Exporting docker logs...");
  try {
    await runExec(
      `docker logs indaba > "${path.join(
        pathin,
        "indaba-logs",
        `${logdir}/docker.log`
      )}"`
    );
  } catch (e) {
    console.error("Failed to copy docker logs");
    console.error(e);
  }

  console.log("Checking for Emergency Asset Backup");

  let assettrigger = path.join(pathin, "EMERGENCYBACKUP");

  if (fs.existsSync(assettrigger)) {
    console.log("Starting emergency asset backup");
    try {
      await fs.ensureDir(`${path.join(pathin, "indaba-em-backup", backupdir)}`);
    } catch (e) {
      console.error(e);
    }

    console.log("Stopping Current Container");
    try {
      await runExec("docker stop indaba");
    } catch (e) {
      console.error(e);
    }

    //run temp web server:
    startServer();

    console.log("Copying upload directory...");
    try {
      await runExec(
        `cp -R ./upload  "${path.join(pathin, "indaba-em-backup", backupdir)}"`
      );
    } catch (e) {
      console.error(e);
    }

    console.log("Renaming trigger file");

    try {
      await runExec(`mv ${assettrigger} ${assettrigger}.done`);
    } catch (e) {
      console.error(e);
    }

    stopServer();
    console.log("Rebooting...");
    runExec("reboot");
  }

  console.log("Checking for Update...");

  let filename = path.join(pathin, "indaba-update.tar");

  if (fs.existsSync(filename)) {
    console.log("Stopping Current Container");

    try {
      await runExec("docker stop indaba");
    } catch (e) {
      console.error(e);
    }

    //run temp web server:
    startServer();

    console.log("Loading New Image");

    await runExecProgress(`pv -n "${filename}" | docker load`); //output is on stderr

    currentPercentage = "rebooting...";

    console.log("Removing Old Image");

    try {
      await runExec("docker rm indaba");
    } catch (e) {
      console.error(e);
    }

    console.log("Renaming source file");

    try {
      fs.renameSync(`${filename}`, `${filename}.done`);
    } catch (e) {
      console.error(e);
    }

    console.log("Removing Install Marker");

    try {
      await runExec("rm /indaba/.titaninstalled");
    } catch (e) {
      console.error(e);
    }

    stopServer();

    console.log("Run Install Script to Complete Update (now rebooting)");

    runExec("reboot");
    // await runExec("./gettitan");
  } else {
    console.error("No indaba-update.tar file!");
  }
}

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function start() {
  try {
    let drives = await drivelist.list();

    if (numdrives == -1) numdrives = _.size(drives);

    if (_.size(drives) > numdrives && !alreadyprocessing) {
      alreadyprocessing = true;
      console.log("New Drive Detected");

      // await sleep(5000);

      // drives = await drivelist.list();

      let usb = _.find(drives, { isUSB: true });

      // console.log(usb);

      numdrives = _.size(drives);

      if (usb.mountpoints.length > 0) {
        //run update
        console.log("Running update from", usb.mountpoints[0].path);
        await update(usb.mountpoints[0].path);
      } else {
        console.log("No Mountpoint", usb);
      }

      alreadyprocessing = false;
    } else {
      numdrives = _.size(drives);
    }

    setTimeout(start, 5000);
  } catch (e) {
    console.error("UPDATE FAILED!");
    console.error(e);
    setTimeout(start, 5000);
  }
}

// checks if this is the first time that its been installed (first boot)
async function initialInstall() {
  try {
    //wait for the gettitan script to fire up and start the container
    // await sleep(5000);

    let imageExists = false;

    imageExists = await runExecResult(
      "docker image inspect bootlegger/titan-compact"
    );

    console.log(`Initial Image Exists: ${imageExists}`);

    if (imageExists === false) {
      //run temp web server:
      startServer();

      console.log("Loading New Image");

      await runExecProgress(`pv -n "/indaba/indaba-update.tar" | docker load`); //output is on stderr

      currentPercentage = "rebooting...";

      stopServer();

      console.log("Run Install Script to Complete Update (now rebooting)");

      runExec("reboot");
    }
  } catch (e) {
    console.error("Initial Load Failed!");
    console.error(e);
  }
}

console.log(`Started (${version.version})...`);
initialInstall();
start();
