default: help

include common.mk

REGISTRY_PORT	= 5000
REGISTRY_SERVER	= localhost:$(REGISTRY_PORT)

################################################################

include network.mk
include snmp.mk

pull:: # Update all images
	$(TRACE)

docker.rm: # Remove all dangling containers
	$(TRACE)
	$(DOCKER) ps -qa --filter "status=exited" | xargs docker rm

docker.rmi: # Remove all dangling images
	$(TRACE)
	$(DOCKER) images -q -f dangling=true | xargs docker rmi

clean:
	$(RM) -r $(STAMPSDIR)

docker.help:
	$(call run-help, Makefile)

help:: docker.help # Show available rules and info about them
	$(TRACE)
