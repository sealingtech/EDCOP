SHELL := /bin/bash

config-offline:
	$(MAKE) config-offline -C build

iso:
	$(MAKE) config-offline -C build
rpm:	
