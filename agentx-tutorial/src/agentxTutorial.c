/*
 * Note: this file originally auto-generated by mib2c using
 *        $
 */

#include <net-snmp/net-snmp-config.h>
#include <net-snmp/net-snmp-includes.h>
#include <net-snmp/agent/net-snmp-agent-includes.h>
#include "agentxTutorial.h"

#define AGENTX_ERR_NOERROR              SNMP_ERR_NOERROR
#define AGENTX_ERR_PARSE_FAILED         (266)
#define AGENTX_ERR_REQUEST_DENIED       (267)
#define AGENTX_ERR_PROCESSING_ERROR     (268)

/*
 * Our data that we want to monitor over SNMP
 */
extern char myROStringVar[80];
extern int myROIntegerVar;

/** Initializes the agentxTutorial module */
void
init_agentxTutorial(void)
{
	const oid myROString_oid[] = { 1,3,6,1,3,9999,1,1 };
	const oid myROInteger_oid[] = { 1,3,6,1,3,9999,1,2 };

	DEBUGMSGTL(("agentxTutorial", "Initializing\n"));

	netsnmp_register_scalar(
		netsnmp_create_handler_registration("myROString",
						    handle_myROString,
						    myROString_oid,
						    OID_LENGTH(myROString_oid),
						    HANDLER_CAN_RONLY)
		);
	netsnmp_register_scalar(
		netsnmp_create_handler_registration("myROInteger",
						    handle_myROInteger,
						    myROInteger_oid,
						    OID_LENGTH(myROInteger_oid),
						    HANDLER_CAN_RONLY)
		);
}

int
handle_myROString(netsnmp_mib_handler *handler,
		  netsnmp_handler_registration *reginfo,
		  netsnmp_agent_request_info *reqinfo,
		  netsnmp_request_info *requests)
{
	/* We are never called for a GETNEXT if it's registered as a
	   "instance", as it's "magically" handled for us.  */

	/* a instance handler also only hands us one request at a time, so
	   we don't need to loop over a list of requests; we'll only get one. */
	DEBUGMSGTL(("agentxTutorial", "%s, mode=%i\n",__func__, reqinfo->mode));
	switch(reqinfo->mode) {

	case MODE_GET:
		snmp_set_var_typed_value(requests->requestvb,
					 ASN_OCTET_STR,
					 myROStringVar,
					 strlen(myROStringVar));
		break;


	default:
		/* we should never get here, so this is a really bad error */
		snmp_log(LOG_ERR, "unknown mode (%d) in handle_myROString\n", reqinfo->mode );
		return SNMP_ERR_GENERR;
	}

	return SNMP_ERR_NOERROR;
}
int
handle_myROInteger(netsnmp_mib_handler *handler,
		   netsnmp_handler_registration *reginfo,
		   netsnmp_agent_request_info *reqinfo,
		   netsnmp_request_info *requests)
{
	/* We are never called for a GETNEXT if it's registered as a
	   "instance", as it's "magically" handled for us.  */
	static int i = 1;
	int sleeptime = 4005000;
	int timeleft;
	int status = AGENTX_ERR_NOERROR;

	/* a instance handler also only hands us one request at a time, so
	   we don't need to loop over a list of requests; we'll only get one. */
	DEBUGMSGTL(("agentxTutorial", "%s, mode=%i\n",__func__, reqinfo->mode));
	switch(reqinfo->mode) {
	case MODE_GET:
		snmp_set_var_typed_value(requests->requestvb,
					 ASN_INTEGER,
					 &myROIntegerVar,
					 sizeof(myROIntegerVar));
		if (i % 2) {
			timeleft = usleep(sleeptime);
			DEBUGMSGTL(("agentxTutorial", "%s: usleep(%i, %i) i=%d\n",__func__, sleeptime, timeleft, i));
			//status = AGENTX_ERR_PROCESSING_ERROR;
		} else
			DEBUGMSGTL(("agentxTutorial", "%s: nosleep i=%d\n",__func__, i));
		i++;
		break;
	default:
		/* we should never get here, so this is a really bad error */
		snmp_log(LOG_ERR, "unknown mode (%d) in handle_myROInteger\n", reqinfo->mode );
		return SNMP_ERR_GENERR;
	}
	DEBUGMSGTL(("agentxTutorial", "%s return status = %d\n",__func__, status));
	return status;
}
