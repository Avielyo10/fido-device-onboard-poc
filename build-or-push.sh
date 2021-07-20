#!/bin/bash

FDOS="fdo-rendezvous-server fdo-owner-onboarding-service fdo-client-linuxapp"

if [[ "$1" == "build" ]]; then
	for fdo in ${FDOS}; do
		echo "[INFO] Building ${fdo}"
		podman build -t quay.io/ayosef/$fdo --target $fdo .
	done
elif [[ "$1" == "push" ]]; then
	podman login quay.io -u ayosef
	for fdo in ${FDOS}; do
		echo "[INFO] Pushing ${fdo}"
		podman push quay.io/ayosef/$fdo
	done
else
	echo "Usage: ./build-or-push.sh [build|push]" && exit 1
fi
