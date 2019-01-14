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
KILLALL		= $(Q)killall -w
SLEEP		= $(Q)sleep

MIB		= AGENTX-TUTORIAL-MIB
TMP		= $(PWD)/tmp/$(shell hostname)
AGENTX		= agentxTutorial

SNMP_ENV	= $(TMP)/snmp.env

AGENTX_CONF	= $(TMP)/$(AGENTX).conf
SNMP_CONF	= $(TMP)/snmp.conf
SNMPD_CONF	= $(TMP)/snmpd.conf
SNMPTRAPD_CONF	= $(TMP)/snmptrapd.conf

AGENTX_LOG	= $(TMP)/agentx.log
SNMPD_LOG	= $(TMP)/snmpd.log
SNMPTRAPD_LOG	= $(TMP)/snmptrapd.log

AGENTX_PID	= $(TMP)/agentx.pid
SNMPD_PID	= $(TMP)/snmpd.pid
SNMPTRAPD_PID	= $(TMP)/snmptrapd.pid

-include $(SNMP_ENV)

.PHONY: config prepare start stop restart test agentx.start

all: $(AGENTX) prepare
	$(MAKE) restart
	$(SLEEP) 12
#	$(MAKE) snmptrapd.stop
	$(MAKE) snmptrapd.start
	$(SLEEP) 4
	$(Q)if [ -f $(SNMPTRAPD_LOG) ]; then \
		cat $(SNMPTRAPD_LOG); \
	fi

$(TMP):
	$(Q)mkdir -p $@

$(AGENTX):
	$(MAKE) -f $@_Makefile

$(AGENTX).clean:
	$(MAKE) -f $(AGENTX)_Makefile clean

$(TMP)/$(AGENTX): $(AGENTX)
	$(Q)mv $< $@

build:
	$(MAKE) $(AGENTX).clean
	$(MAKE) $(AGENTX)

########################################################################
$(SNMP_ENV): | $(TMP)
	$(ECHO) export MIBS="+$(MIB)" > $@
	$(ECHO) "export SNMPCONFPATH=$(TMP)" >> $@
	$(ECHO) "export SNMP_PERSISTENT_DIR=$(TMP)/persist" >> $@

$(HOME)/.snmp/mibs/$(MIB): $(MIB)
	$(CP) -f $< $@

$(AGENTX_CONF):
	$(ECHO) "[snmp] logTimestamp 1" > $@


$(SNMP_CONF): Makefile | $(TMP)
	$(ECHO) "defcommunity public" > $@
	$(ECHO) "dumpPacket yes" >> $@

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
#	$(ECHO) "trapsess     -v 3 -r 2 -t 6 -e 0x80001f8880523983647b8b0355 -a MD5 -A trap1234 -x DES -X trap1234 -l authNoPriv -u trapuser localhost" >> $@
	$(ECHO) "# v3 - inform" >> $@
	$(ECHO) "trapsess -Ci -v 3 -r 2 -t 4 -a MD5 -A trap1234 -x DES -X trap1234 -l authNoPriv -u trapuser localhost" >> $@

$(SNMPTRAPD_CONF): Makefile | $(TMP)
	$(ECHO) "[snmp] logTimestamp 0" > $@
	$(ECHO) "authCommunity log,execute,net public" >> $@
	$(ECHO) 'createUser trapuser MD5 "trap1234" DES "trap1234"' >> $@
	$(ECHO) "authUser log trapuser" >> $@

config: $(SNMP_ENV) $(SNMPD_CONF) $(SNMPTRAPD_CONF) $(SNMP_CONF) $(AGENTX_CONF)
prepare: $(HOME)/.snmp/mibs/$(MIB) config
	$(ECHO) "$(TMP)/core.%e.%p" > /proc/sys/kernel/core_pattern
	$(RM) $(TMP)/core.*.*

########################################################################
#SNMPD_DBG	= -d -DALL
SNMPD_DBG	= -d -Dagentx/master,agentx/config/,sess_process_packet,AW,AW1,sess_read,snmp_agent,agent_set,handler:calling,handler:returned,agentx_build,agent_set,trap,sess_async_send,snmp_synch,snmp_api,signal
snmpd.start: $(SNMPD_CONF)
	$(Q)snmpd $(SNMPD_DBG) -Lf $(SNMPD_LOG) -C -c $< udp:161

#SNMPTRAPD_DBG	= -d -DALL
SNMPTRAPD_DBG	= -d -Dsess_process_packet,AW,AW1,sess_read,snmp_synch,snmp_api
snmptrapd.start: $(SNMPTRAPD_CONF)
	$(Q)if [ ! -f $(SNMPTRAPD_PID) ]; then \
		snmptrapd $(SNMPTRAPD_DBG) -Lf $(SNMPTRAPD_LOG) -p $(SNMPTRAPD_PID) -C -c $<; \
	fi

#AGENTX_DBG	= -DALL
AGENTX_DBG	= -D$(AGENTX),snmpd/main,agentx/subagent,signal
agentx.start: $(TMP)/$(AGENTX)
	$(Q)$(TOP)/$< $(AGENTX_DBG) 2> $(AGENTX_LOG) &

start:
#	$(MAKE) snmptrapd.start
	$(MAKE) agentx.start
	$(MAKE) snmpd.start

########################################################################
snmptrapd.stop:
	$(Q)if [ -f $(SNMPTRAPD_PID) ]; then \
		kill $$(cat $(SNMPTRAPD_PID)); \
	fi
	$(RM) $(SNMPTRAPD_PID)

stop:
#	$(MAKE) snmptrapd.stop
	$(KILLALL) snmpd  > /dev/null  || true
	$(KILLALL) $(AGENTX)  > /dev/null || true


stop.force:
	$(KILLALL) -9 snmptrapd || true
	$(RM) $(SNMPTRAPD_PID)
	$(KILLALL) -9 $(AGENTX) || true
	$(KILLALL) -9 snmpd || true

restart:
	$(MAKE) stop
	$(MAKE) start

snmpwalk walk:
	$(Q)snmpwalk -v2c -c public localhost $(AGENTX)

translate: prepare
	$(Q)snmptranslate -Tp -IR $(AGENTX)

clean: stop $(AGENTX).clean
	$(MAKE) snmptrapd.stop
	$(RM) -r $(TMP)
	$(RM) *~ \#*\#

distclean: clean
