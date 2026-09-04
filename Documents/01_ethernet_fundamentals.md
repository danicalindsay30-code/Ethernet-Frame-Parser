Ethernet Fundamentals

## What is Ethernet?
Ethernet is a networking technology used to transfer data between devices on a  network.
## Ethernet Frame 
An ethernet frame is a container that contains the data being transmitted across a local network it contains:
1. Destination Mac
2. Source MAC
3. Type
4. Data
5. FCS

## Frame Structure
<img width="1209" height="403" alt="image" src="https://github.com/user-attachments/assets/49e8b98d-6e4d-4127-a71e-5599ece8ca39" />

*preamable [7 Bytes] is alternating 1s and 0s comes before the frame and is used to indicate the start of a frame by giving the receiver a regular alternating bit pattern before the frame begins, its main purpose is synchronisation between the transmitter and receiver.

*The start frame delimiter [1 Byte] - indicative of the end of the premable and the start of the frame. Contains a specific bit sequence.

Outside the parser boundary. Synchronisation is assumed to have been handled by the upstream Ethernet PHY/MAC.

## Destination MAC
Destination MAC is  a 48-bit/6 bytes physical hardware identifier located at the start of the frame header that specifies the MAC address of the device sending the frame.

## Source MAC
Source MAC is  a 48-bit/6 bytes physical hardware identifier located after the destination MAC that specifies the MAC address of the device sending the frame.

## EtherType
A 2-byte field specifying the type or length of the payload data.

The Ethernet II header is 14 bytes containing the Destination and Source Mac addresses and the EtherType.

## Payload 
Payload refers to the actual data being transmitted across the network, varying in size and including information to be delivered to the recipient. size ranges from 46 to 1500 bytes in length.

*if less than 46 bytes the sending device adds padding(extra zeros).


## FCS
Frame Check Sequence - A 4 byte field for error checking, it helps the recieving device compare the data to the initial transmitted data to identify any errors in the frame during transmission.
Algorithim used is the cyclic redundancy check [CRC]

*For Version 1 FCS checking is outside the scope of the parser.

## Standard Ethernet II Structure :
Minimum frame : 64 Bytes 
Maximum Frame: 1518 Bytes 
<img width="463" height="791" alt="image" src="https://github.com/user-attachments/assets/28db43ac-a1d1-4d4f-b749-ec256731c090" />
 
 Each clock cycle there is a byte sent, the byte contains an 8 bit data_in and two flags. The Valid_in flag determines whether the data byte being transmitted is accepted data. if valid_in is not asserted the parser should ignore this packet. The last flag indicates when the final byte of the upstream is transmitted.

 The counter isn't dependent on the clock cycle as their is the potentiality for data to be invalid meaning for that clock cycle the data is disregarded. Counter advances based on accepted data.

 The finite state machine determines what kind of field the parser is currently processing.

## Data example
00 11 22 33 44 55
AA BB CC DD EE FF
08 00
45 00 00 28 ...
              FSM          Counter       data

             DEST_MAC        0            00
             DEST_MAC        1            11
             DEST_MAC        2            22
             DEST_MAC        3            33
             DEST_MAC        4            44
             DEST_MAC        5            55
                 │
                 ▼
             SRC_MAC         0            AA
             SRC_MAC         1            BB
             SRC_MAC         2            CC
             SRC_MAC         3            DD
             SRC_MAC         4            EE
             SRC_MAC         5            FF
                 │
                 ▼
            ETHERTYPE         0            08
            ETHERTYPE         1            00
                 │
                 ▼
             PAYLOAD          0            45
             PAYLOAD          1            00
             PAYLOAD          2            00
             PAYLOAD          3            28
                 ...

# Finite state machine design 
State local counter - the counter resets with each state change 
