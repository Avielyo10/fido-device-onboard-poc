# FIDO Device Onboard - POC

This POC uses https://github.com/fedora-iot/fido-device-onboard-rs.git divided into microservices in a rootless mode (client runs as root) so they can run as services on top of Openshift.

> **NOTE:** Running poc will remove all running containers on your machine, check `run` on `Makefile` to verify the network is available before running.

## Run POC

```bash
make poc
```

![provisioning with fdo](images/provisioning-with-fdo-hi-res.jpg)

## What happened?

This POC meaning to demonstrate the process of onboarding a new IoT device using zero-touch provisiong.
Let's break it into parts:

### Supply chain

First as we build the images we do a small simulation of a manufacturer that pass its product to a reseller which sell it eventually to the owner, this process can take place as many times as you wish.

```dockerfile
RUN fdo-owner-tool initialize-device --device-cert-ca-chain keys/device_ca_cert.pem --device-cert-ca-private-key keys/device_ca_key.der --manufacturer-cert keys/manufacturer_cert.pem testdevice1 testdevice1.ov testdevice1.dc --rendezvous-info rendezvous-info.yml
RUN fdo-owner-tool extend-ownership-voucher testdevice1.ov --current-owner-private-key keys/manufacturer_key.der --new-owner-cert keys/reseller_cert.pem
RUN fdo-owner-tool extend-ownership-voucher testdevice1.ov --current-owner-private-key keys/reseller_key.der --new-owner-cert keys/owner_cert.pem
```
