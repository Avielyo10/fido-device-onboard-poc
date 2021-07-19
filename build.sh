#!/bin/bash

for fdo in fdo-rendezvous-server fdo-owner-onboarding-service fdo-client-linuxapp; do
	podman build -t quay.io/ayosef/$fdo --target $fdo .
done
