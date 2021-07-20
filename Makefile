
all: clean build run

build:
	./build-or-push.sh build

clean:
	podman ps -a | awk '{print $$1}' | grep -iv container | xargs podman rm -f || true

run:
	podman run -dt -p 8080:8080/tcp --name owner-onboarding-service quay.io/ayosef/fdo-owner-onboarding-service
	podman run -dt -p 8084:8084/tcp --name rendezvous-server quay.io/ayosef/fdo-rendezvous-server

push: build
	./build-or-push.sh push
