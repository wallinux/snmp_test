
: ${TRACE:='echo -e --- '}
#: ${TRACE:=': '}
: ${DEBUG_ARGS:="-v 3 -r 0 -a MD5 -A $USM_CMD_PW -l authNoPriv -u $USM_CMD_USER $CONFIG_HOST"}
: ${DEBUG_OUT:='/dev/null'}
#: ${DEBUG_OUT:='/dev/stdout'}

DEBUG_SNMPSET="snmpset $DEBUG_ARGS"
DEBUG_SNMPGET="snmpget $DEBUG_ARGS"
DEBUG_SNMPWALK="snmpwalk $DEBUG_ARGS"

##############################################################################
function debug_on ()
{
    $TRACE $FUNCNAME
    $DEBUG_SNMPSET NET-SNMP-AGENT-MIB::nsDebugEnabled.0 = 1 > $DEBUG_OUT
}

function debug_off ()
{
    $TRACE $FUNCNAME
    $DEBUG_SNMPSET NET-SNMP-AGENT-MIB::nsDebugEnabled.0 = 2 > $DEBUG_OUT
}

function debug_status ()
{
    $TRACE $FUNCNAME
    $DEBUG_SNMPGET NET-SNMP-AGENT-MIB::nsDebugEnabled.0
}

function debug_test ()
{
    $TRACE $FUNCNAME ---
    debug_on
    debug_status
    debug_off
    debug_status
}

##############################################################################
function tokenall_on ()
{
    $TRACE $FUNCNAME
    $DEBUG_SNMPSET NET-SNMP-AGENT-MIB::nsDebugOutputAll.0 = 1 > $DEBUG_OUT
}

function tokenall_off ()
{
    $TRACE $FUNCNAME
    $DEBUG_SNMPSET NET-SNMP-AGENT-MIB::nsDebugOutputAll.0 = 2 > $DEBUG_OUT
}

function tokenall_status ()
{
    $TRACE $FUNCNAME
    $DEBUG_SNMPGET NET-SNMP-AGENT-MIB::nsDebugOutputAll.0
}

function tokenall_test ()
{
    $TRACE $FUNCNAME ---
    tokenall_on
    tokenall_status
    debug_status
    tokenall_off
    tokenall_status
    debug_status
}

##############################################################################
function debugall_on ()
{
    $TRACE $FUNCNAME
    tokenall_on
    debug_on
}

function debugall_off ()
{
    $TRACE $FUNCNAME
    tokenall_off
    debug_off
}

function debugall_status ()
{
    $TRACE $FUNCNAME
    tokenall_status
    debug_status
}

function debugall_test ()
{
    $TRACE $FUNCNAME ---
    debugall_on
    debugall_status
    debugall_off
    debugall_status
}

##############################################################################
function debug_token_create ()
{
    local token=$1

    $TRACE $FUNCNAME $token
    $DEBUG_SNMPSET NET-SNMP-AGENT-MIB::nsDebugTokenStatus."'$token'" = 5
}

function debug_token_destroy ()
{
    local token=$1

    $TRACE $FUNCNAME $token
    $DEBUG_SNMPSET NET-SNMP-AGENT-MIB::nsDebugTokenStatus."'$token'" = 6
}

function debug_token_on ()
{
    local token=$1

    $TRACE $FUNCNAME $token
    $DEBUG_SNMPSET NET-SNMP-AGENT-MIB::nsDebugTokenStatus."'$token'" = 1 > $DEBUG_OUT
}

function debug_token_off ()
{
    local token=$1

    $TRACE $FUNCNAME $token
    $DEBUG_SNMPSET NET-SNMP-AGENT-MIB::nsDebugTokenStatus."'$token'" = 2 > $DEBUG_OUT
}

function debug_token_status ()
{
    local token=$1

    $TRACE $FUNCNAME $token
    $DEBUG_SNMPGET NET-SNMP-AGENT-MIB::nsDebugTokenStatus."'$token'"
}

function debug_token_test ()
{
    $TRACE $FUNCNAME $token ---
    debug_list
    debug_token_create $1
    debug_token_status $1
    debug_token_off $1
    debug_token_status $1
    debug_list
    debug_token_on $1
    debug_token_status $1
    debug_token_destroy $1
    debug_list
}

##############################################################################
function debug_list ()
{
    $TRACE $FUNCNAME
    echo \<LIST----------------------------------------------
    $DEBUG_SNMPWALK "NET-SNMP-AGENT-MIB::nsConfigDebug"
    echo ----------------------------------------------LIST\>
    #$DEBUG_SNMPWALK "NET-SNMP-AGENT-MIB::nsLoggingTable"
}

##############################################################################
function pdu_on ()
{
    $TRACE $FUNCNAME
    $DEBUG_SNMPSET NET-SNMP-AGENT-MIB::nsDebugDumpPdu.0 = 1 > $DEBUG_OUT
}

function pdu_off ()
{
    $TRACE $FUNCNAME
    $DEBUG_SNMPSET NET-SNMP-AGENT-MIB::nsDebugDumpPdu.0 = 2  > $DEBUG_OUT
}

function pdu_status ()
{
    $TRACE $FUNCNAME
    $DEBUG_SNMPGET NET-SNMP-AGENT-MIB::nsDebugDumpPdu.0
}

function pdu_test ()
{
    $TRACE $FUNCNAME ---
    pdu_on
    pdu_status
    pdu_off
    pdu_status
}

##############################################################################
function debug_testall ()
{
    $TRACE $FUNCNAME ---
    pdu_test
    debug_test
    tokenall_test
    debugall_test
    debug_token_test AW
    debug_list
    log_list
}

##############################################################################
# TODO
# handle logging level

function log_list ()
{
    $TRACE $FUNCNAME
    echo \<LIST----------------------------------------------
    $DEBUG_SNMPWALK "NET-SNMP-AGENT-MIB::nsLoggingTable"
    echo ----------------------------------------------LIST\>
}
