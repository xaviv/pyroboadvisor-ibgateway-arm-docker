IMAGE_NAME=ghcr.io/xaviv/pyroboadvisor-arm-docker

run: build
	docker run --platform linux/arm64 -it -p 6800:6800 $(IMAGE_NAME):latest

clean:
	docker image rm -f $(IMAGE_NAME):latest

build:
	docker build --platform linux/arm64 --tag $(IMAGE_NAME):latest .

debug: build
	docker run --platform linux/arm64 -it -p 6800:6800 --entrypoint /bin/bash $(IMAGE_NAME):latest

docker-login:
	cat private/github.token | docker login ghcr.io -u xaviv --password-stdin

docker-push: build
	docker push $(IMAGE_NAME):latest
