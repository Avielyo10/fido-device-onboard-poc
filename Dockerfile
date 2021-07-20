FROM centos AS base

RUN yum update -y && yum install -y cargo git-core openssl-devel
RUN git clone https://github.com/fedora-iot/fido-device-onboard-rs.git
RUN cd fido-device-onboard-rs && cargo build --release 

FROM centos AS fdo-client-linuxapp
RUN useradd -ms /bin/bash fido-user
COPY --from=base /fido-device-onboard-rs/target/release/fdo-client-linuxapp /usr/local/bin/fdo-client-linuxapp
WORKDIR /home/fido-user

FROM centos AS fdo-rendezvous-server
RUN useradd -ms /bin/bash fido-user
COPY --from=base /fido-device-onboard-rs/target/release/fdo-rendezvous-server /usr/local/bin/fdo-rendezvous-server
WORKDIR /home/fido-user

FROM centos AS fdo-owner-onboarding-service
RUN useradd -ms /bin/bash fido-user
COPY --from=base /fido-device-onboard-rs/target/release/fdo-owner-onboarding-service /usr/local/bin/fdo-owner-onboarding-service
WORKDIR /home/fido-user
