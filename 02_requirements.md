## Ethernet Frame Parser - Requirements 
## Project Objective
   The objective of this project is to design and implement a SystemVerilog Ethernet II frame parser capable
   of processing a streaming Ethernet frame and extracting key header fields.

   The parser will be developed initially in simulation and subsequently integrated onto the Xillinx Kria KR260 FPGA Platform.

   ## Functional Requirements 
1. Accept an incoming Ethernet II frame as a stream of 8-bit data.
2. Accept a valid_in signal indicating when the input byte is valid.
3. Accept a last_in signal indicating the final byte of the frame.
4. Extract the 6-byte Destination MAC address.
5. Extract the 6-byte Source MAC address.
6. Extract the 2-byte EtherType field.
7. Forward the payload data as a stream.
8. Indicate when the parsed frame fields are valid.
9. Correctly return to the idle state after the end of a frame.
10. Support standard Ethernet II frame sizes within the defined project limits.

## Frame Types Supported 
initial implementation will support:
Ethernet II frames, standard Ethernet frame structure 
The parser will not initially intepret the contents of the payload 

## Out Of Scope
Preamble detection
SFD detection
FCS/CRC generation or checking
IEEE 802.3 LLC/SNAP parsing
VLAN parsing
IPv4 parsing
UDP parsing
TCP parsing
ITCH message decoding
Order-book processing

These may be considered as future extensions.
## Performance Requirements 
Initial parser will be designed to process one byte per valid clock cycle. Performance measurements to be investigates :
Maximum operating frequency, Throughput, Processing latency, Resource utilisation

## Verification Requirements 
The parser shall be verified using simulation before hardware integration.

The verification environment shall test:

Minimum-sized frames
Maximum-sized frames
Different EtherType values
Different MAC addresses
Variable payload lengths
Frame boundaries
Gaps in valid_in
Back-to-back frames
Reset behaviour

## Hardware Target 
The eventual hardware implementation will target the AMD Kria KR260 Robotics Starter Kit.
The initial RTL shall remain sufficiently independent of the physical Ethernet interface to allow the parser to be verified independently before board-level Ethernet integration.
