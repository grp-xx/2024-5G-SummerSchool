/* -*- P4_16 -*- */
#include <core.p4>
#include <v1model.p4>

/*************************************************************************
*********************** H E A D E R S  ***********************************
*************************************************************************/

typedef bit<48> macAddr_t;

header ethernet_t {
    macAddr_t dstAddr;
    macAddr_t srcAddr;
    bit<16>   etherType;
}

struct metadata {
    /* empty */
}

struct headers {
       ethernet_t ethernet;
}


/*************************************************************************
*********************** P A R S E R  ***********************************
*************************************************************************/

parser MyParser(packet_in packet,
                out headers hdr,
                inout metadata meta,
                inout standard_metadata_t standard_metadata) {

      state start{
  	  packet.extract(hdr.ethernet);
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
                    

    action swap_macs(inout macAddr_t src, inout macAddr_t dst) {
        macAddr_t tmp = src;
        src = dst;
        dst = tmp;
    }

    register<bit<1>>(8) reg;

    apply {   
        bit<1> flag;
        bit<32> input_port = (bit<32>) standard_metadata.ingress_port;
        reg.read(flag,input_port);
        reg.write(input_port,flag+1);

        if (flag == 1) {
            mark_to_drop(standard_metadata);
        }
        else {
             swap_macs(hdr.ethernet.srcAddr, hdr.ethernet.dstAddr);
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

    // Counting the numeber of reflected frames
    counter(8,CounterType.packets) egress_port_counter;

    apply { 
        egress_port_counter.count( (bit<32>)standard_metadata.egress_port);
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
