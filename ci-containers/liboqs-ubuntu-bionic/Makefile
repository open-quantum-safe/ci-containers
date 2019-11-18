IMAGENAME = liboqs-ubuntu-bionic

help:
	@echo "Targets:"
	@echo "build: Create Docker image"
	@echo "bash: Open root bash in Docker image"
	@echo "getopenssl: Retrieve openssl executable and config"
	@echo "test: Test installation"
	@echo "clean: Clean folder"

build:
	docker build --build-arg ARCH=x86_64 -t $(IMAGENAME) .

push:
	docker login && docker tag $(IMAGENAME) zrlmib/$(IMAGENAME) && docker push zrlmib/$(IMAGENAME)

bash:
	docker run -it $(IMAGENAME) bash

run:
	docker run -t $(IMAGENAME)

clean:
	rm -rf *.sh *.c ../build 

clobber: clean
	-docker images -q | xargs docker rmi -f	
