run: build
	docker run --platform linux/arm64 -it -p 4002:4002 -p 4001:4001 -p 6800:6800 -p 5900:5900 pyroboadvisor-arm-docker

clean:
	docker image rm -f pyroboadvisor-arm-docker

build:
	docker build --platform linux/arm64 --tag pyroboadvisor-arm-docker .

debug: build
	docker run --platform linux/arm64 -it -p 4002:4002 -p 4001:4001 -p 6800:6800 -p 5900:5900 --entrypoint /bin/bash pyroboadvisor-arm-docker 
