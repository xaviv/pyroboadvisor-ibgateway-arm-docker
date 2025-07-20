run: build
	docker run --platform linux/arm64 -it -p 6800:6800 pyroboadvisor-arm-docker

clean:
	docker image rm -f pyroboadvisor-arm-docker

build:
	docker build --platform linux/arm64 --tag pyroboadvisor-arm-docker .

debug: build
	docker run --platform linux/arm64 -it -p 6800:6800 --entrypoint /bin/bash pyroboadvisor-arm-docker 

#docker-login:
#    echo $$GITHUB_TOKEN | docker login ghcr.io -u <github-username> --password-stdin

#docker-push: build
#    docker push $(IMAGE_NAME):$(TAG)
