
# Define V=1 to echo everything
V	?= 0
ifneq ($(V),1)
	export Q=@
	MAKE	= $(Q)make -s
else
	MAKE	= $(Q)make
endif
export V

ECHO	= $(Q)echo
RM	= $(Q)rm -f
CP	= $(Q)cp
CC	= $(Q)gcc $(CFLAGS)
KILLALL	= $(Q)killall

MIB = AGENTX-TUTORIAL-MIB
TOP = $(shell pwd)
TMP = $(TOP)/tmp

AGENT = agentxTutorial

-include snmp.env

.PHONY: prepare start stop restart test agent.start

all: $(AGENT) prepare
	$(MAKE) restart
	$(Q)sleep 5
#	$(KILLALL) snmptrapd
	$(Q)cat $(TMP)/snmptrapd.log

$(AGENT):
	$(MAKE) -f $@_Makefile

$(AGENT).clean:
	$(MAKE) -f $(AGENT)_Makefile clean

rebuild:
	$(MAKE) $(AGENT).clean
	$(MAKE) $(AGENT)

$(TMP):
	$(Q)mkdir -p $@


$(TMP)/snmp.env: | $(TMP)
	$(ECHO) export MIBS="+$(MIB)" > $@
	$(ECHO) export SNMPCONFPATH=$(TMP) >> $@

$(HOME)/.snmp/mibs/$(MIB): $(MIB)
	$(CP) -f $< $@

$(TMP)/snmpd.conf: Makefile | $(TMP)
	$(ECHO) "rwcommunity public" > $@
	$(ECHO) "master agentx" >> $@
#	$(ECHO) "trap2sink localhost public" >> $@
	$(ECHO) "informsink localhost public" >> $@

$(TMP)/snmptrapd.conf: Makefile | $(TMP)
	$(ECHO) "authCommunity log public" > $@

prepare: $(HOME)/.snmp/mibs/$(MIB) $(TMP)/snmp.env $(TMP)/snmpd.conf $(TMP)/snmptrapd.conf
	$(ECHO) "$(TMP)/core.%e.%p" > /proc/sys/kernel/core_pattern
	$(RM) $(TMP)/core.*.*

snmpd_dbg = -d -Dagentx/master,agentx/config/,sess_process_packet,AW,AW1,sess_read,snmp_agent,agent_set,handler:calling,handler:returned,agentx_build,agent_set,trap,sess_async_send,snmp_synch,snmp_api
#snmpd_dbg = -d -DALL
snmpd.start: $(TMP)/snmpd.conf
	$(Q)snmpd $(snmpd_dbg) -Lf $(TMP)/snmpd.log -C -c $< udp:161

snmptrapd.start: $(TMP)/snmptrapd.conf
	$(Q)snmptrapd -Lf $(TMP)/snmptrapd.log -C -c $<

#agent_debug = -D$(AGENT),snmpd/main,agentx/subagent
agent_debug = -DALL
agent.start: $(AGENT)
	$(Q)$(TOP)/$< $(agent_debug) 2> $(TMP)/agent.log &

start:
	$(MAKE) snmptrapd.start
	$(MAKE) snmpd.start
	$(MAKE) agent.start

stop:
	$(KILLALL) snmptrapd > /dev/null || true
	$(KILLALL) $(AGENT)  > /dev/null || true
	$(KILLALL) snmpd  > /dev/null  || true

restart:
	$(MAKE) stop
	$(MAKE) start

snmpwalk:
	$(Q)snmpwalk -v2c -c public localhost $(AGENT)

translate: prepare
	$(Q)snmptranslate -Tp -IR $(AGENT)

clean: stop $(AGENT).clean
	$(RM) -r $(TMP)
	$(RM) *~ \#*\#
