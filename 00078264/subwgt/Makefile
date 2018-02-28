OBJS=subwgt.o netSnmpIETFWGTable.o
#TARGETS=example-demon
TARGETS=subwgt

CFLAGS=-I. `net-snmp-config --cflags`
BUILDLIBS=`net-snmp-config --libs`
BUILDAGENTLIBS=`net-snmp-config --agent-libs`

# shared library flags (assumes gcc)
DLFLAGS=-fPIC -shared

all: $(TARGETS)

subwgt: $(OBJS)
	$(CC) -o subwgt $(OBJS)  $(BUILDAGENTLIBS)

netSnmpIETFWGTable.o: netSnmpIETFWGTable.c Makefile
	$(CC) $(CFLAGS) $(DLFLAGS) -c -o netSnmpIETFWGTable.o netSnmpIETFWGTable.c

clean:
	rm -f $(OBJS) $(TARGETS)
