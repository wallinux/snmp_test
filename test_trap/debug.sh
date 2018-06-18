DEBUG_NOTE=': echo -e --- '
DEBUG_ARGS="-v 3 -r 0 -a MD5 -A $USM_CMD_PW -l authNoPriv -u $USM_CMD_USER $CONFIG_HOST"
DEBUG_SNMPSET="snmpset $DEBUG_ARGS"
DEBUG_SNMPGET="snmpget $DEBUG_ARGS"
DEBUG_SNMPWALK="snmpwalk $DEBUG_ARGS"
DEBUG_OUT="/dev/null"

##############################################################################
function debug_on ()
{
    $DEBUG_NOTE DEBUG on
    $DEBUG_SNMPSET NET-SNMP-AGENT-MIB::nsDebugEnabled.0 = 1 > $DEBUG_OUT
}

function debug_off ()
{
    $DEBUG_NOTE DEBUG off
    $DEBUG_SNMPSET NET-SNMP-AGENT-MIB::nsDebugEnabled.0 = 2 > $DEBUG_OUT
}

function debug_status ()
{
    $DEBUG_NOTE DEBUG status
    $DEBUG_SNMPGET NET-SNMP-AGENT-MIB::nsDebugEnabled.0
}

function debug_test ()
{
    $DEBUG_NOTE
    echo ----------------------------------------------
    debug_on
    debug_status
    debug_off
    debug_status
}

##############################################################################
function debugall_on ()
{
    $DEBUG_NOTE DEBUGOUTPUTALL on
    $DEBUG_SNMPSET NET-SNMP-AGENT-MIB::nsDebugOutputAll.0 = 1 > $DEBUG_OUT
    debug_on
}

function debugall_off ()
{
    $DEBUG_NOTE DEBUGOUTPUTALL off
    $DEBUG_SNMPSET NET-SNMP-AGENT-MIB::nsDebugOutputAll.0 = 2 > $DEBUG_OUT
    debug_off
}

function debugall_status ()
{
    $DEBUG_NOTE DEBUGOUTPUTALL status
    $DEBUG_SNMPGET NET-SNMP-AGENT-MIB::nsDebugOutputAll.0
    debug_status
}

function debugall_test ()
{
    $DEBUG_NOTE
    echo ----------------------------------------------
    debugall_on
    debugall_status
    debugall_off
    debugall_status
}

##############################################################################
function debug_token_create ()
{
    local token=$1

    $DEBUG_NOTE TOKEN create $token
    $DEBUG_SNMPSET NET-SNMP-AGENT-MIB::nsDebugTokenStatus."'$token'" = 5
}

function debug_token_destroy ()
{
    local token=$1

    $DEBUG_NOTE TOKEN destroy $token
    $DEBUG_SNMPSET NET-SNMP-AGENT-MIB::nsDebugTokenStatus."'$token'" = 6
}

function debug_token_on ()
{
    local token=$1

    $DEBUG_NOTE TOKEN on $token
    $DEBUG_SNMPSET NET-SNMP-AGENT-MIB::nsDebugTokenStatus."'$token'" = 1 > $DEBUG_OUT
}

function debug_token_off ()
{
    local token=$1

    $DEBUG_NOTE TOKEN off $token
    $DEBUG_SNMPSET NET-SNMP-AGENT-MIB::nsDebugTokenStatus."'$token'" = 2 > $DEBUG_OUT
}

function debug_token_status ()
{
    local token=$1

    $DEBUG_NOTE TOKEN status $token
    $DEBUG_SNMPGET NET-SNMP-AGENT-MIB::nsDebugTokenStatus."'$token'"
}

function debug_token_test ()
{
    $DEBUG_NOTE
    echo ----------------------------------------------
    debug_token_create $1
    debug_token_status $1
    debug_token_off $1
    debug_token_status $1
    debug_token_on $1
    debug_token_status $1
    debug_token_destroy $1
}

##############################################################################
function debug_list ()
{
    $DEBUG_NOTE LIST
    echo ----------------------------------------------
    $DEBUG_SNMPWALK "NET-SNMP-AGENT-MIB::nsConfigDebug"
    echo ----------------------------------------------
    $DEBUG_SNMPWALK "NET-SNMP-AGENT-MIB::nsLoggingTable"
}

function debug_testall ()
{
    pdu_test
    debug_test
    debugall_test
    debug_token_test AW
    debug_list
}

##############################################################################
function pdu_on ()
{
    $DEBUG_NOTE PDU on
    $DEBUG_SNMPSET NET-SNMP-AGENT-MIB::nsDebugDumpPdu.0 = 1 > $DEBUG_OUT
}

function pdu_off ()
{
    $DEBUG_NOTE PDU off
    $DEBUG_SNMPSET NET-SNMP-AGENT-MIB::nsDebugDumpPdu.0 = 2  > $DEBUG_OUT
}

function pdu_status ()
{
    $DEBUG_NOTE PDU status
    $DEBUG_SNMPGET NET-SNMP-AGENT-MIB::nsDebugDumpPdu.0
}

function pdu_test ()
{
    echo ----------------------------------------------
    pdu_on
    pdu_status
    pdu_off
    pdu_status
}

##############################################################################
# TODO
# handle logging level
