
# Define V=1 to echo everything
V	?= 0
ifneq ($(V),1)
	Q=@
endif

ECHO	= $(Q)/bin/echo -e
RM	= $(Q)rm -f
CC	= $(Q)gcc $(CFLAGS)

TMPDIR  = $(PWD)/tmp/$(shell hostname)

TARGETS = $(TMPDIR)/mysubagent

CFLAGS	       := -I. $(shell net-snmp-config --cflags)
BUILDLIBS      := $(shell net-snmp-config --libs)
BUILDAGENTLIBS := $(shell net-snmp-config --agent-libs)

all: $(TARGETS)

$(TMPDIR)/mysubagent: nstAgentSubagentObject.c | $(TMPDIR)
	$(Q)net-snmp-config --compile-subagent $@ --norm $<
	$(Q)mv netsnmptmp.*.c $(TMPDIR)

$(TMPDIR):
	$(Q)mkdir -p $@

test: $(TMPDIR)/mysubagent | $(TMPDIR)
	$(Q)./test_mysubagent $(TMPDIR)

clean:
	$(RM) $(TARGETS) $(LIBS) *.o

distclean: clean
	$(RM) *~ \#*\# .\#*
	$(RM) -r $(TMPDIR)

build.help:
	$(ECHO) "BUILDLIBS: $(BUILDLIBS)"
	$(ECHO) "BUILDAGENTLIBS: $(BUILDAGENTLIBS)"
	$(ECHO) "CFLAGS: $(CFLAGS)"

help:
	$(ECHO) "\n COUNT=1 TIMEOUT=10 DEBUG_AW=yes make test\n"
