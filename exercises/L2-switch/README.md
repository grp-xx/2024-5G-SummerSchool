Simple implementation of a Layer 2 switch.
To setup the emulated environment, compile the p4 code and inject it to the switch, just "make run".
To stop the text, "exit" from mininet, run "make stop" and "make clean" to remove all produced file.
Tables can be populated through:
"simple_switch_CLI --thrift-port 9090 < s1-commands.txt"

For more details, refer to the pdf presentation in the folder.
