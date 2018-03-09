OBJS=/tmp/netSnmpIETFWGTable.o
TARGETS=/tmp/subwgt

CFLAGS=-I. `net-snmp-config --cflags`
BUILDLIBS=`net-snmp-config --libs`
BUILDAGENTLIBS=`net-snmp-config --agent-libs`

# shared library flags (assumes gcc)
DLFLAGS=-fPIC -shared

all: $(TARGETS)

/tmp/subwgt: subwgt.c $(OBJS)
	$(CC) $(CFLAGS) -o $@ $< $(OBJS) $(BUILDAGENTLIBS) -pthread

/tmp/netSnmpIETFWGTable.o: netSnmpIETFWGTable.c Makefile
	$(CC) $(CFLAGS) $(DLFLAGS) -c -o $@ $<

clean:
	rm -f $(OBJS) $(TARGETS)
