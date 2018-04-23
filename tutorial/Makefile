#
# Warning: you may need more libraries than are included here on the
# build line.  The agent frequently needs various libraries in order
# to compile pieces of it, but is OS dependent and we can't list all
# the combinations here.  Instead, look at the libraries that were
# used when linking the snmpd master agent and copy those to this
# file.
#

CC=gcc $(CFLAGS)

TARGETS=example-demon snmpdemoapp asyncapp mysubagent
LIBS=nstAgentPluginObject.so

CFLAGS	:= -I. $(shell net-snmp-config --cflags)
BUILDLIBS := $(shell net-snmp-config --libs)
BUILDAGENTLIBS := $(shell net-snmp-config --agent-libs)

# shared library flags (assumes gcc)
DLFLAGS=-fPIC -shared

all: $(TARGETS) $(LIBS)

snmpdemoapp: snmpdemoapp.c
	$(CC) -o $@ $< $(BUILDLIBS)

asyncapp: asyncapp.c
	$(CC) -o $@ $< $(BUILDLIBS)

example-demon: example-demon.c nstAgentSubagentObject.o 
	$(CC) -o $@ $< nstAgentSubagentObject.o $(BUILDAGENTLIBS)

nstAgentSubagentObject.o: nstAgentSubagentObject.c
	$(CC) -c -o $@ $<

mysubagent: nstAgentSubagentObject.c
	net-snmp-config --compile-subagent $@ $<

nstAgentPluginObject.so: nstAgentPluginObject.c Makefile
	$(CC) $(CFLAGS) $(DLFLAGS) -c -o nstAgentPluginObject.o nstAgentPluginObject.c
	$(CC) $(CFLAGS) $(DLFLAGS) -o nstAgentPluginObject.so nstAgentPluginObject.o

test1:
	./test_mysubagent

test2:
	./test_example-demon

clean:
	rm -f $(TARGETS) $(LIBS) *.o

help:
	@echo BUILDLIBS: $(BUILDLIBS)
	@echo BUILDAGENTLIBS: $(BUILDAGENTLIBS)
	@echo CFLAGS: $(CFLAGS)
