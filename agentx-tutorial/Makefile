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
MKDIR		= $(Q)mkdir -p

MIB		= AGENTX-TUTORIAL-MIB
TMP		= $(PWD)/tmp/$(shell hostname)
AGENTX		= agentxTutorial
AGENTXSOCKET	= tcp:localhost:705
#AGENTXSOCKET	= unix:/var/agentx/master2

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

SLEEPTIME	?= 0

-include $(SNMP_ENV)

.PHONY: config prepare start stop restart agentx.start

all: $(AGENTX) prepare
	$(MAKE) restart
	$(SLEEP) 10
	$(MAKE) V=1 get &
	$(SLEEP) 1
	$(MAKE) V=1 get &

$(TMP):
	$(MKDIR) $@

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

$(HOME)/.snmp/mibs:
	$(MKDIR) $@

$(HOME)/.snmp/mibs/$(MIB): $(MIB) | $(HOME)/.snmp/mibs
	$(CP) -f $< $@

$(AGENTX_CONF):
	$(ECHO) "[snmp] logTimestamp 1" > $@
	$(ECHO) "agentXSocket $(AGENTXSOCKET)" >> $@
	$(ECHO) "[snmp] dumpPacket yes" >> $@

$(SNMP_CONF): Makefile | $(TMP)
	$(ECHO) "defcommunity public" > $@
#	$(ECHO) "dumpPacket yes" >> $@

$(SNMPD_CONF): Makefile | $(TMP)
	$(ECHO) "[snmp] logTimestamp 1" > $@
	$(ECHO) "master agentx" >> $@
	$(ECHO) "agentXSocket $(AGENTXSOCKET)" >> $@
	$(ECHO) "agentXTimeout 2" >> $@
	$(ECHO) "agentXRetries 1" >> $@
	$(ECHO) "rwcommunity public" >> $@
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
SNMPD_DBG	= -d -Dagentx/master,agentx/config,sess_process_packet,AW,AW1,sess_read,snmp_agent,agent_set,handler:calling,handler:returned,agentx_build,agent_set,trap,sess_async_send,snmp_synch,snmp_api,signal,netsnmp_unix
#SNMPD_DBG	= -d -Dagentx/master,agentx/config,AW,AW1,snmp_agent,agent_set,handler:calling,handler:returned,agentx_build
snmpd.start: $(SNMPD_CONF)
	$(Q)snmpd $(SNMPD_OPT) -Lf $(SNMPD_LOG) $(SNMPD_DBG) -C -c $< udp:161

#SNMPTRAPD_DBG	= -d -DALL
#SNMPTRAPD_DBG	= -d -Dsess_process_packet,AW,AW1,sess_read,snmp_synch,snmp_api
snmptrapd.start: $(SNMPTRAPD_CONF)
	$(Q)if [ ! -f $(SNMPTRAPD_PID) ]; then \
		snmptrapd -Lf $(SNMPTRAPD_LOG) $(SNMPTRAPD_DBG) -p $(SNMPTRAPD_PID) -C -c $<; \
	fi

#AGENTX_DBG	= -DALL
AGENTX_DBG	= -D$(AGENTX),snmpd/main,agentx/subagent,signal,snmp_alarm,transport:send,transport:recv,netsnmp_unix,session_process_packet,AW,AW1,agentx/config
agentx.start: $(TMP)/$(AGENTX) $(AGENTX_CONF)
	$(Q)$< $(AGENTX_DBG) 2> $(AGENTX_LOG) &

agentx2.start: $(TMP)/$(AGENTX) $(AGENTX_CONF)
	$(Q)$< $(AGENTX_DBG) 2> $(AGENTX_LOG).2 &

start:
	$(MAKE) snmptrapd.start
	$(MAKE) snmpd.start
	$(SLEEP) 7
	$(MAKE) agentx.start
	$(SLEEP) 3

########################################################################
snmptrapd.stop:
	$(Q)if [ -f $(SNMPTRAPD_PID) ]; then \
		kill $$(cat $(SNMPTRAPD_PID)) || true; \
	fi
	$(RM) $(SNMPTRAPD_PID)

snmpd.restart:
	$(MAKE) snmpd.stop
	$(SLEEP) $(SLEEPTIME)
	$(MAKE) snmpd.start SNMPD_OPT=-A

snmpd.stop:
	$(KILLALL) snmpd  2> /dev/null  || true

agentx.stop:
	$(KILLALL) $(AGENTX)  2> /dev/null  || true

stop:
#	$(MAKE) snmptrapd.stop
	$(MAKE) snmpd.stop
	$(MAKE) agentx.stop

stop.force:
	$(KILLALL) -9 snmptrapd || true
	$(RM) $(SNMPTRAPD_PID)
	$(KILLALL) -9 $(AGENTX) || true
	$(KILLALL) -9 snmpd || true

restart:
	$(MAKE) stop
	$(MAKE) start

snmpwalk walk:
	$(Q)snmpwalk -v2c -t 10 -r 0 -c public localhost $(AGENTX)

snmpget get:
	$(Q)snmpget -v2c -t 10 -r 0 -c public localhost $(MIB)::myROInteger.0

translate: prepare
	$(Q)snmptranslate -Tp -IR $(AGENTX)

clean: stop $(AGENTX).clean
	$(MAKE) snmptrapd.stop
	$(RM) -r $(TMP)
	$(RM) *~ \#*\#

distclean: clean
