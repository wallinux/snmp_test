#include <net-snmp/net-snmp-config.h>
#include <net-snmp/net-snmp-includes.h>
#include <net-snmp/agent/net-snmp-agent-includes.h>

#include <signal.h>
#include <stdlib.h>

#include <netSnmpIETFWGTable.h>

static int keep_running;
static char agentx_socket[] = "/tmp/snmp-test/var/agentx/master";
static const char *name = "subwgt";
const char *my_dbg_tokens = "subwgt,agentx/master,agentx/subagent,snmp_agent,agent_set,transport_callback";

int nsleep = 0;

extern void netsnmp_enable_filelog(netsnmp_log_handler *logh, int dont_zero_log);

RETSIGTYPE
stop_server(int a) {
    keep_running = 0;
}

int
main (int argc, char **argv) {
    int agentx_subagent=1; /* change this if you want to
			      be a SNMP master agent */
    netsnmp_log_handler *logh;

    if (argc > 1) {
	int out = atoi(argv[1]);
	if (out > 0)
	    nsleep = out;
    }

    /* print log errors to stderr */
    //snmp_enable_stderrlog();
    logh = netsnmp_register_loghandler(NETSNMP_LOGHANDLER_FILE, LOG_DEBUG);
    if (logh) {
	logh->pri_max = LOG_EMERG;
	printf("Debug logfile: /tmp/subwgt.log\n");
	logh->token   = strdup("/tmp/subwgt.log");
	netsnmp_enable_filelog(logh,
			       netsnmp_ds_get_boolean(NETSNMP_DS_LIBRARY_ID,
						      NETSNMP_DS_LIB_APPEND_LOGFILES));
    }
    debug_register_tokens(my_dbg_tokens);
    snmp_set_do_debugging(1);
    /* we're an agentx subagent? */
    if (agentx_subagent) {
	/* make us a agentx client. */
	netsnmp_ds_set_boolean(NETSNMP_DS_APPLICATION_ID,
			       NETSNMP_DS_AGENT_ROLE, 1);
	netsnmp_ds_set_string(NETSNMP_DS_APPLICATION_ID,
			      NETSNMP_DS_AGENT_X_SOCKET, agentx_socket);
    }

    DEBUGMSGT(("subwgt","--> init_agent\n"));
    /* initialize the agent library */
    init_agent(name);

    /* initialize mib code here */

    /* mib code: nit_netSnmpIETFWGTable from init_netSnmpIETFWGTable.c */
    DEBUGMSGT(("subwgt","--> init_netSnmpIETFWGTable\n"));
    init_netSnmpIETFWGTable();

    /* subwgt will be used to read subwgt.conf files. */
    DEBUGMSGT(("subwgt","--> init_snmp\n"));
    init_snmp(name);

    /* If we're going to be a snmp master agent, initial the ports */
    if (!agentx_subagent) {
        DEBUGMSGT(("subwgt","--> init_master_agent\n"));
        init_master_agent();  /* open the port to listen on
				 (defaults to udp:161) */
    }
    /* In case we recevie a request to stop (kill -TERM or kill -INT) */
    keep_running = 1;
    signal(SIGTERM, stop_server);
    signal(SIGINT, stop_server);

    DEBUGMSGT(("subwgt", "(sleep %d) is up and running.\n", nsleep));

    /* you're main loop here... */
    while(keep_running) {
	/* if you use select(), see snmp_select_info() in snmp_api(3) */
	/*     --- OR ---  */
        DEBUGMSGT(("subwgt", "--> agent_check_and_process\n"));
	agent_check_and_process(0); /* 0 == don't block */
	if (nsleep > 0)
	    sleep(nsleep);
    }

    /* at shutdown time */
    DEBUGMSGT(("subwgt","--> snmp_shutdown\n"));
    snmp_shutdown(name);
    return 1;
}
