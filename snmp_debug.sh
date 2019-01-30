#!/bin/bash

: "${DBGTRACE:='echo -e --- '}"
#: ${DBGTRACE:=': '}
: ${DEBUG_ARGS:="-v 3 -r 0 -a MD5 -A $USM_CMD_PW -l authNoPriv -u $USM_CMD_USER $CONFIG_HOST"}
: "${DEBUG_OUT:='/dev/null'}"
#: ${DEBUG_OUT:='/dev/stdout'}

DEBUG_SNMPSET="snmpset $DEBUG_ARGS"
DEBUG_SNMPGET="snmpget $DEBUG_ARGS"
DEBUG_SNMPWALK="snmpwalk $DEBUG_ARGS"

##############################################################################
debug_on ()
{
    $DBGTRACE "${FUNCNAME[$0]}"
    $DEBUG_SNMPSET NET-SNMP-AGENT-MIB::nsDebugEnabled.0 = 1 > "$DEBUG_OUT"
}

debug_off ()
{
    $DBGTRACE "${FUNCNAME[$0]}"
    $DEBUG_SNMPSET NET-SNMP-AGENT-MIB::nsDebugEnabled.0 = 2 > "$DEBUG_OUT"
}

debug_status ()
{
    $DBGTRACE "${FUNCNAME[$0]}"
    $DEBUG_SNMPGET NET-SNMP-AGENT-MIB::nsDebugEnabled.0
}

##############################################################################
tokenall_on ()
{
    $DBGTRACE "${FUNCNAME[$0]}"
    $DEBUG_SNMPSET NET-SNMP-AGENT-MIB::nsDebugOutputAll.0 = 1 > "$DEBUG_OUT"
}

tokenall_off ()
{
    $DBGTRACE "${FUNCNAME[$0]}"
    $DEBUG_SNMPSET NET-SNMP-AGENT-MIB::nsDebugOutputAll.0 = 2 > "$DEBUG_OUT"
}

tokenall_status ()
{
    $DBGTRACE "${FUNCNAME[$0]}"
    $DEBUG_SNMPGET NET-SNMP-AGENT-MIB::nsDebugOutputAll.0
}

##############################################################################
debugall_on ()
{
    $DBGTRACE "${FUNCNAME[$0]}"
    $DEBUG_SNMPSET NET-SNMP-AGENT-MIB::nsDebugOutputAll.0 = 1 > "$DEBUG_OUT"
    $DEBUG_SNMPSET NET-SNMP-AGENT-MIB::nsDebugEnabled.0 = 1 > "$DEBUG_OUT"
    $DEBUG_SNMPSET NET-SNMP-AGENT-MIB::nsDebugDumpPdu.0 = 1 > "$DEBUG_OUT"
}

debugall_off ()
{
    $DBGTRACE "${FUNCNAME[$0]}"
    $DEBUG_SNMPSET NET-SNMP-AGENT-MIB::nsDebugEnabled.0 = 2 > "$DEBUG_OUT"
    $DEBUG_SNMPSET NET-SNMP-AGENT-MIB::nsDebugDumpPdu.0 = 2 > "$DEBUG_OUT"
    $DEBUG_SNMPSET NET-SNMP-AGENT-MIB::nsDebugOutputAll.0 = 2 > "$DEBUG_OUT"
}

##############################################################################
token_create ()
{
    local token=$1

    $DBGTRACE "${FUNCNAME[$0]}" "$token"
    $DEBUG_SNMPSET NET-SNMP-AGENT-MIB::nsDebugTokenStatus."'$token'" = 5
}

token_destroy ()
{
    local token=$1

    $DBGTRACE "${FUNCNAME[$0]}" "$token"
    $DEBUG_SNMPSET NET-SNMP-AGENT-MIB::nsDebugTokenStatus."'$token'" = 6
}

token_on ()
{
    local token=$1

    $DBGTRACE "${FUNCNAME[$0]}" "$token"
    $DEBUG_SNMPSET NET-SNMP-AGENT-MIB::nsDebugTokenStatus."'$token'" = 1 > "$DEBUG_OUT"
}

token_off ()
{
    local token=$1

    $DBGTRACE "${FUNCNAME[$0]}" "$token"
    $DEBUG_SNMPSET NET-SNMP-AGENT-MIB::nsDebugTokenStatus."'$token'" = 2 > "$DEBUG_OUT"
}

token_status ()
{
    local token=$1

    $DBGTRACE "${FUNCNAME[$0]}" "$token"
    $DEBUG_SNMPGET NET-SNMP-AGENT-MIB::nsDebugTokenStatus."'$token'"
}


##############################################################################
pdu_on ()
{
    $DBGTRACE "${FUNCNAME[$0]}"
    $DEBUG_SNMPSET NET-SNMP-AGENT-MIB::nsDebugDumpPdu.0 = 1 > "$DEBUG_OUT"
}

pdu_off ()
{
    $DBGTRACE "${FUNCNAME[$0]}"
    $DEBUG_SNMPSET NET-SNMP-AGENT-MIB::nsDebugDumpPdu.0 = 2  > "$DEBUG_OUT"
}

pdu_status ()
{
    $DBGTRACE "${FUNCNAME[$0]}"
    $DEBUG_SNMPGET NET-SNMP-AGENT-MIB::nsDebugDumpPdu.0
}

##############################################################################
debug_list ()
{
    $DBGTRACE "${FUNCNAME[$0]}"
    echo \<----------------------------------------------
    $DEBUG_SNMPWALK "NET-SNMP-AGENT-MIB::nsConfigDebug"
    echo ----------------------------------------------\>
    #$DEBUG_SNMPWALK "NET-SNMP-AGENT-MIB::nsLoggingTable"
}

log_list ()
{
    $DBGTRACE "${FUNCNAME[$0]}"
    echo \<----------------------------------------------
    $DEBUG_SNMPWALK "NET-SNMP-AGENT-MIB::nsLoggingTable"
    echo ----------------------------------------------\>
}
