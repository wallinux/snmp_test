default: help

include common.mk

REGISTRY_PORT		= 5000
REGISTRY_SERVER		= localhost:$(REGISTRY_PORT)

################################################################
include snmp.mk

pull:: # Update all images
	$(TRACE)

clean:
	$(RM) -r $(STAMPSDIR)

docker.help:
	$(call run-help, Makefile)

help:: docker.help # Show available rules and info about them
	$(TRACE)
