Simple implementation of a Layer 3 forwarding node.
To setup the emeulated environment, compile the p4 code and inject it tio the switch, just "make run".
To stop the text, "exit" from mininet, run "make stop" and "make clean" to remove all produced file.
Tables can be populated through:
"simple_switch_CLI --thrift-port 9090 < s1-commands.txt" and
"simple_switch_CLI --thrift-port 9091 < s1-commands.txt"

For more details refer to the pdf presentation in the "5G-SummerSchool-2022" folder.
