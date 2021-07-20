
all: clean build run

build:
	./build-or-push.sh build

clean:
	podman rm -fa
	rm -f testdevice1.ov

run:
	podman network create myCNI || true
	podman run -dt --network myCNI --ip 10.88.2.2 --name owner-onboarding-service quay.io/ayosef/fdo-owner-onboarding-service
	podman run -dt --network myCNI --ip 10.88.2.3 --name rendezvous-server quay.io/ayosef/fdo-rendezvous-server
	podman logs owner-onboarding-service
	podman logs rendezvous-server

push: build
	./build-or-push.sh push

poc: all
	./poc.sh
	make clean
