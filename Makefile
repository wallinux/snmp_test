default: help

include common.mk

DOCKER_ID_USER		= wallinux

################################################################

include network.mk
include snmp.mk
include codechecker.server.mk

pull:: # Update all images
	$(TRACE)

docker.rm: # Remove all dangling containers
	$(TRACE)
	$(DOCKER) ps -qa --filter "status=exited" | xargs docker rm

docker.rmi: # Remove all dangling images
	$(TRACE)
	$(DOCKER) images -q -f dangling=true | xargs docker rmi

clean::
	$(TRACE)
	$(RM) -r $(STAMPSDIR)

distclean:: clean
	$(TRACE)

docker.help:
	$(call run-help, Makefile)

help:: docker.help # Show available rules and info about them
	$(TRACE)
