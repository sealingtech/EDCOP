SHELL := /bin/bash

iso:
	docker build -t edcop_builder -f build/Dockerfile .
	id=$$(docker create edcop_builder); docker cp $$id:/EDCOP/build/EDCOP-dev.iso ./EDCOP-dev.iso; docker rm -v $$id  
	docker rmi edcop_builder

docs:
	cd ./docs && $(MAKE) html
