FROM centos AS fdo-base

# build binaries
RUN yum update -y && yum install -y cargo git-core openssl-devel
RUN git clone https://github.com/fedora-iot/fido-device-onboard-rs.git
RUN cd fido-device-onboard-rs && cargo build --release

# create secrets
ADD create-secrets.sh ./
RUN sh create-secrets.sh

# simulation
ADD config/rendezvous-info.yml ./
ADD config/owner-addresses.yml ./
RUN cp /fido-device-onboard-rs/target/release/fdo-owner-tool /usr/local/bin/
RUN fdo-owner-tool initialize-device --device-cert-ca-chain keys/device_ca_cert.pem --device-cert-ca-private-key keys/device_ca_key.der --manufacturer-cert keys/manufacturer_cert.pem testdevice1 testdevice1.ov testdevice1.dc --rendezvous-info rendezvous-info.yml
RUN fdo-owner-tool extend-ownership-voucher testdevice1.ov --current-owner-private-key keys/manufacturer_key.der --new-owner-cert keys/reseller_cert.pem
RUN fdo-owner-tool extend-ownership-voucher testdevice1.ov --current-owner-private-key keys/reseller_key.der --new-owner-cert keys/owner_cert.pem


FROM registry.access.redhat.com/ubi8/ubi-minimal AS fdo-client-linuxapp
COPY --from=fdo-base /fido-device-onboard-rs/target/release/fdo-client-linuxapp /usr/local/bin/
COPY --from=fdo-base /testdevice1.dc ./

ENV DEVICE_CREDENTIAL=/testdevice1.dc
ENV RUST_LOG=trace
CMD ["fdo-client-linuxapp"]


FROM registry.access.redhat.com/ubi8/ubi-minimal AS fdo-rendezvous-server
RUN useradd -ms /bin/bash fido-user
WORKDIR /home/fido-user
COPY --from=fdo-base /fido-device-onboard-rs/target/release/fdo-rendezvous-server /usr/local/bin/
COPY --from=fdo-base /keys/device_ca_cert.pem keys/device_ca_cert.pem
COPY --from=fdo-base /keys/manufacturer_cert.pem keys/manufacturer_cert.pem
RUN chown fido-user keys/*

USER fido-user
ADD config/rendezvous-service.yml ./
RUN mkdir -p rendezvous_registered/
ENV RUST_LOG=trace
CMD ["fdo-rendezvous-server"]


FROM registry.access.redhat.com/ubi8/ubi-minimal AS fdo-owner-onboarding-service
RUN useradd -ms /bin/bash fido-user
WORKDIR /home/fido-user
COPY --from=fdo-base /fido-device-onboard-rs/target/release/fdo-owner-onboarding-service /usr/local/bin/
COPY --from=fdo-base /keys/device_ca_cert.pem keys/device_ca_cert.pem
COPY --from=fdo-base /keys/owner_key.der keys/owner_key.der
RUN chown fido-user keys/*

USER fido-user
ADD config/owner-onboarding-service.yml ./
RUN mkdir -p ownership_vouchers/
ENV RUST_LOG=trace
CMD ["fdo-owner-onboarding-service"]
