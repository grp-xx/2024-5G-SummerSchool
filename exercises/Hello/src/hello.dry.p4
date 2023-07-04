/* -*- P4_16 -*- */
#include <core.p4>
#include <v1model.p4>

/*************************************************************************
*********************** H E A D E R S  ***********************************
*************************************************************************/

typedef bit<48> macAddr_t;
typedef bit<32> ip4Addr_t;

header ethernet_h {
    macAddr_t dstAddr;
    macAddr_t srcAddr;
    bit<16>   etherType;
}

header ipv4_h {
    bit<4>    version;
    bit<4>    ihl;
    bit<8>    diffserv;
    bit<16>   totalLen;
    bit<16>   identification;
    bit<3>    flags;
    bit<13>   fragOffset;
    bit<8>    ttl;
    bit<8>    protocol;
    bit<16>   hdrChecksum;
    ip4Addr_t srcAddr;
    ip4Addr_t dstAddr;
}

header parity_h {
    bit<8> par;
}

header extra_h {
    bit<16> in_port;
}


struct metadata {
    /* empty */
}

struct headers {
       ethernet_h ethernet;
       ipv4_h     ipv4;
       parity_h   parity;

}


/*************************************************************************
*********************** P A R S E R  ***********************************
*************************************************************************/

parser MyParser(packet_in packet,
                out headers hdr,
                inout metadata meta,
                inout standard_metadata_t standard_metadata) {

    state start
    {
  	    packet.extract(hdr.ethernet);
        transition select(hdr.ethernet.etherType)
        {
            0x0800 : ipv4;
            default: accept;
        }
    }
    state ipv4
    {
        packet.extract(hdr.ipv4);
        transition accept;
    }
}


/*************************************************************************
************   C H E C K S U M    V E R I F I C A T I O N   *************
*************************************************************************/

control MyVerifyChecksum(inout headers hdr, inout metadata meta) {
    apply {  }
}


/*************************************************************************
**************  I N G R E S S   P R O C E S S I N G   *******************
*************************************************************************/

control MyIngress(inout headers hdr,
                  inout metadata meta,
                  inout standard_metadata_t standard_metadata) {


    action swap_macs()
    {
        macAddr_t tmp;
        tmp = hdr.ethernet.srcAddr;
        hdr.ethernet.srcAddr = hdr.ethernet.dstAddr;
        hdr.ethernet.dstAddr = tmp;
    }

    apply {

        if (hdr.ethernet.etherType != 0x0800)
        {
            mark_to_drop(standard_metadata);   
        }
        else
        {
            swap_macs();
            standard_metadata.egress_spec = standard_metadata.ingress_port;
        }
    }
}



/*************************************************************************
****************  E G R E S S   P R O C E S S I N G   *******************
*************************************************************************/

control MyEgress(inout headers hdr,
                 inout metadata meta,
                 inout standard_metadata_t standard_metadata) {  


    apply {
        hdr.parity.setValid();
        bit<32> daddr = hdr.ipv4.dstAddr;
        if ( daddr[0:0] == 0) 
        {
            hdr.parity.par = 0;
        } 
        else
        {
            hdr.parity.par = 1;
        }
    }
    
}
    

/*************************************************************************
*************   C H E C K S U M    C O M P U T A T I O N   **************
*************************************************************************/

control MyComputeChecksum(inout headers  hdr, inout metadata meta) {
            

    apply { 

    }
}

/*************************************************************************
***********************  D E P A R S E R  *******************************
*************************************************************************/

control MyDeparser(packet_out packet, in headers hdr) {
    apply {
		// parsed headers have to be added again into the packet
		packet.emit(hdr.ethernet);
        packet.emit(hdr.parity);
        packet.emit(hdr.ipv4);
        // packet.emit(hdr.extra);
	}
}

/*************************************************************************
***********************  S W I T C H  *******************************
*************************************************************************/

V1Switch(
	MyParser(),
	MyVerifyChecksum(),
	MyIngress(),
	MyEgress(),
	MyComputeChecksum(),
	MyDeparser()
) main;
