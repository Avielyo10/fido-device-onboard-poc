# FIDO Device Onboard - POC

This POC uses https://github.com/fedora-iot/fido-device-onboard-rs.git divided into microservices in a rootless mode (client runs as root) so they can run as services on top of Openshift.

> **NOTE:** Running poc will remove all running containers on your machine, check `run` on `Makefile` to verify the network is available before running.

## Run POC

```bash
make poc
```

![provisioning with fdo](images/provisioning-with-fdo-hi-res.jpg)
