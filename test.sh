#!/bin/bash

function info {
    message="[INFO] ${1}"
    echo -e "\033[32;1m${message}\033[0m"
}

function warn {
    message="[WARN] ${1}"
    echo -e "\033[33;1m${message}\033[0m"
}

function check_registered_devices {
    info "Check if there are registered devices"
    export GUUID=$(podman exec -ti rendezvous-server ls /home/fido-user/rendezvous_registered/)
    if [[ -z ${GUUID} ]]; then
        warn "Nothing has been registered"
    else
        info "Found ${GUUID}"
    fi
}

make
check_registered_devices

info "Report to rendezvous"
podman run -dt --network myCNI --ip 10.88.2.4 --name reporter quay.io/ayosef/fdo-base /bin/bash
podman exec -ti reporter fdo-owner-tool report-to-rendezvous --ownership-voucher testdevice1.ov --owner-private-key keys/owner_key.der --owner-addresses-path owner-addresses.yml  --wait-time 600

info "Copying testdevice1.ov"
podman cp reporter:/testdevice1.ov .

info "Removing reporter"
podman rm -f reporter

check_registered_devices

info "Copy testdevice1.ov to owner-onboarding-service"
# remove all special characters from ${GUUID}
ov=$(echo "${GUUID}" | tr -dc '[:print:]')
podman cp testdevice1.ov owner-onboarding-service:/home/fido-user/ownership_vouchers/${ov}

info "Running client"
podman run -dt --network myCNI --ip 10.88.2.5 --name fido-client quay.io/ayosef/fdo-client-linuxapp /bin/bash
podman exec -ti -e RUST_LOG=trace fido-client fdo-client-linuxapp

ssh_key=$(podman exec -ti fido-client cat /root/.ssh/authorized_keys | grep testkey)
if [[ -z ${ssh_key} ]]; then
    warn "Couldn't find testkey in fido-client"
else
    info "testkey found in fido-client"
fi

make clean
