Simple implementation of an IP Traffic Probe. The switch copy all IP packets  (that match selected protocol code in the IP header) exchanged among hosts h1, h2, h3 to host h4 via the mirroring port 4.
To setup the emeulated environment, compile the p4 code and inject it tio the switch, just "make run".
To stop the text, "exit" from mininet, run "make stop" and "make clean" to remove all produced file.
Tables can be populated through:
"simple_switch_CLI --thrift-port 9090 < s1-commands.txt" and
"simple_switch_CLI --thrift-port 9090 < s1-monitor-commands.txt"

For more details refer to the pdf presentation in the "5G-SummerSchool-2022" folder.
