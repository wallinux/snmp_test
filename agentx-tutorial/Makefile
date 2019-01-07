
# Define V=1 to echo everything
V	?= 0
ifneq ($(V),1)
	export Q=@
	MAKE	= $(Q)make -s
else
	MAKE	= $(Q)make
endif
export V

ECHO		= $(Q)echo
RM		= $(Q)rm -f
CP		= $(Q)cp
CC		= $(Q)gcc $(CFLAGS)
KILL		= $(Q)kill
KILLALL		= $(Q)killall

MIB		= AGENTX-TUTORIAL-MIB
TOP		= $(shell pwd)
TMP		= $(TOP)/tmp

AGENT		= agentxTutorial

SNMP_ENV	= $(TMP)/snmp.env

SNMP_CONF	= $(TMP)/snmp.conf
SNMPD_CONF	= $(TMP)/snmpd.conf
SNMPTRAPD_CONF	= $(TMP)/snmptrapd.conf

AGENT_LOG	= $(TMP)/agent.log
SNMPD_LOG	= $(TMP)/snmpd.log
SNMPTRAPD_LOG	= $(TMP)/snmptrapd.log

AGENT_PID	= $(TMP)/agent.pid
SNMPD_PID	= $(TMP)/snmpd.pid
SNMPTRAPD_PID	= $(TMP)/snmptrapd.pid

-include $(SNMP_ENV)

.PHONY: config prepare start stop restart test agent.start

all: $(AGENT) prepare
	$(MAKE) restart
	$(Q)sleep 5
#	$(MAKE) snmptrapd.stop
	$(Q)cat $(SNMPTRAPD_LOG)

$(AGENT):
	$(MAKE) -f $@_Makefile

$(AGENT).clean:
	$(MAKE) -f $(AGENT)_Makefile clean

rebuild:
	$(MAKE) $(AGENT).clean
	$(MAKE) $(AGENT)

$(TMP):
	$(Q)mkdir -p $@


$(SNMP_ENV): | $(TMP)
	$(ECHO) export MIBS="+$(MIB)" > $@
	$(ECHO) "export SNMPCONFPATH=$(TMP)" >> $@
	$(ECHO) "export SNMP_PERSISTENT_DIR=$(TMP)/persist" >> $@

$(HOME)/.snmp/mibs/$(MIB): $(MIB)
	$(CP) -f $< $@

$(SNMP_CONF): Makefile | $(TMP)
	$(ECHO) "defcommunity public" > $@

$(SNMPD_CONF): Makefile | $(TMP)
	$(ECHO) "[snmp] logTimestamp 1" > $@
	$(ECHO) "master agentx" >> $@
	$(ECHO) "agentXTimeout 2" >> $@
	$(ECHO) "agentXRetries 2" >> $@
	$(ECHO) "rwcommunity public" >> $@
#	$(ECHO) "# v2c - trap" >> $@
#	$(ECHO) "trap2sink localhost public" >> $@
#	$(ECHO) "# v2c - inform" >> $@
#	$(ECHO) "informsink localhost public" >> $@
#	$(ECHO) "# v3 - trap" >> $@
#	$(ECHO) "oldEngineID 0x80001f8880523983647b8b0355" >> $@
#	$(ECHO) "trapsess     -v 3 -r 3 -t 3 -e 0x80001f8880523983647b8b0355 -a MD5 -A trap1234 -x DES -X trap1234 -l authNoPriv -u trapuser localhost" >> $@
	$(ECHO) "# v3 - inform" >> $@
	$(ECHO) "trapsess -Ci -v 3 -r 3 -t 10 -a MD5 -A trap1234 -x DES -X trap1234 -l authNoPriv -u trapuser localhost" >> $@

$(SNMPTRAPD_CONF): Makefile | $(TMP)
	$(ECHO) "[snmp] logTimestamp 0" > $@
	$(ECHO) "authCommunity log,execute,net public" >> $@
	$(ECHO) 'createUser trapuser MD5 "trap1234" DES "trap1234"' >> $@
	$(ECHO) "authUser log trapuser" >> $@

config: $(SNMP_ENV) $(SNMPD_CONF) $(SNMPTRAPD_CONF) $(SNMP_CONF)
prepare: $(HOME)/.snmp/mibs/$(MIB) config
	$(ECHO) "$(TMP)/core.%e.%p" > /proc/sys/kernel/core_pattern
	$(RM) $(TMP)/core.*.*

########################################################################
#SNMPD_DBG	= -d -DALL
SNMPD_DBG	= -d -Dagentx/master,agentx/config/,sess_process_packet,AW,AW1,sess_read,snmp_agent,agent_set,handler:calling,handler:returned,agentx_build,agent_set,trap,sess_async_send,snmp_synch,snmp_api
snmpd.start: $(SNMPD_CONF)
	$(Q)snmpd $(SNMPD_DBG) -Lf $(SNMPD_LOG) -C -c $< udp:161

#SNMPTRAPD_DBG	= -d -DALL
SNMPTRAPD_DBG	= -d -Dsess_process_packet,AW,AW1,sess_read,snmp_synch,snmp_api
snmptrapd.start: $(SNMPTRAPD_CONF)
	$(Q)if [ ! -f $(SNMPTRAPD_PID) ]; then \
		snmptrapd $(SNMPTRAPD_DEBUG) -Lf $(SNMPTRAPD_LOG) -p $(SNMPTRAPD_PID) -C -c $<; \
	fi

snmptrapd.stop:
	$(Q)if [ -f $(SNMPTRAPD_PID) ]; then \
		kill $$(cat $(SNMPTRAPD_PID)); \
	fi
	$(RM) $(SNMPTRAPD_PID)

#AGENT_DEBUG	= -DALL
AGENT_DEBUG	= -D$(AGENT),snmpd/main,agentx/subagent
agent.start: $(AGENT)
	$(Q)$(TOP)/$< $(AGENT_DEBUG) 2> $(AGENT_LOG) &

start:
	$(MAKE) snmptrapd.start
	$(MAKE) snmpd.start
	$(MAKE) agent.start

########################################################################
stop:
#	$(MAKE) snmptrapd.stop
	$(KILLALL) $(AGENT)  > /dev/null || true
	$(KILLALL) snmpd  > /dev/null  || true

restart:
	$(MAKE) stop
	$(MAKE) start

snmpwalk walk:
	$(Q)snmpwalk -v2c -c public localhost $(AGENT)

translate: prepare
	$(Q)snmptranslate -Tp -IR $(AGENT)

clean: stop $(AGENT).clean
	$(MAKE) snmptrapd.stop
	$(RM) -r $(TMP)
	$(RM) *~ \#*\#

distclean: clean

