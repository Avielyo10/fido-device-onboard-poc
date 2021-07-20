FROM centos AS base

RUN yum update -y && yum install -y cargo git-core openssl-devel
RUN git clone https://github.com/fedora-iot/fido-device-onboard-rs.git
RUN cd fido-device-onboard-rs && cargo build --release
ADD create-secrets.sh ./
RUN sh create-secrets.sh

FROM centos AS fdo-client-linuxapp
RUN useradd -ms /bin/bash fido-user
COPY --from=base /fido-device-onboard-rs/target/release/fdo-client-linuxapp /usr/local/bin/fdo-client-linuxapp
COPY --from=base /fido-device-onboard-rs/target/release/fdo-owner-tool /usr/local/bin/fdo-owner-tool
WORKDIR /home/fido-user
COPY --from=base /keys/* keys/
ADD config/rendezvous-info.yml ./
ADD config/owner-addresses.yml ./
# simulation
RUN fdo-owner-tool initialize-device --device-cert-ca-chain keys/device_ca_cert.pem --device-cert-ca-private-key keys/device_ca_key.der --manufacturer-cert keys/manufacturer_cert.pem testdevice1 testdevice1.ov testdevice1.dc --rendezvous-info rendezvous-info.yml
RUN fdo-owner-tool extend-ownership-voucher testdevice1.ov --current-owner-private-key keys/manufacturer_key.der --new-owner-cert keys/reseller_cert.pem
RUN fdo-owner-tool extend-ownership-voucher testdevice1.ov --current-owner-private-key keys/reseller_key.der --new-owner-cert keys/owner_cert.pem


FROM centos AS fdo-rendezvous-server
RUN useradd -ms /bin/bash fido-user
COPY --from=base /fido-device-onboard-rs/target/release/fdo-rendezvous-server /usr/local/bin/fdo-rendezvous-server
WORKDIR /home/fido-user
COPY --from=base /keys/device_ca_cert.pem keys/device_ca_cert.pem
COPY --from=base /keys/manufacturer_cert.pem keys/manufacturer_cert.pem
ADD config/rendezvous-service.yml ./
RUN mkdir -p rendezvous_registered/
CMD ["fdo-rendezvous-server"]

FROM centos AS fdo-owner-onboarding-service
RUN useradd -ms /bin/bash fido-user
COPY --from=base /fido-device-onboard-rs/target/release/fdo-owner-onboarding-service /usr/local/bin/fdo-owner-onboarding-service
WORKDIR /home/fido-user
COPY --from=base /keys/device_ca_cert.pem keys/device_ca_cert.pem
COPY --from=base /keys/owner_key.der keys/owner_key.der
ADD config/owner-onboarding-service.yml ./
RUN mkdir -p ownership_vouchers/
CMD ["fdo-owner-onboarding-service"]
