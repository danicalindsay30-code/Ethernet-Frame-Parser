# Ethernet Frame Parser — Architecture

## 1. Architecture Overview

The Ethernet Frame Parser processes an Ethernet II frame presented as an 8-bit streaming input.

The design is divided into control and datapath components.

```text
                    Input Stream
                         │
                         ▼
                 ┌───────────────┐
                 │      FSM      │
                 │   Controller  │
                 └───────┬───────┘
                         │
             ┌───────────┼────────────┐
             │           │            │
             ▼           ▼            ▼
        Byte Counter  MAC Registers  EtherType
                         │
                         │
                         ▼
                    Payload Path
                         │
                         ▼
                    Output Stream
```

---

## 2. Major Components

The initial architecture consists of:

1. Input streaming interface
2. Finite state machine
3. State-local byte counter
4. Destination MAC register
5. Source MAC register
6. EtherType register
7. Payload forwarding path
8. Frame completion logic

---

## 3. Input Streaming Interface

The parser receives one byte per valid clock cycle.

```text
data_in[7:0]
valid_in
last_in
```

The `valid_in` signal determines whether the current `data_in` value should be processed.

The `last_in` signal identifies the final byte of the frame.

---

## 4. Control Path

The FSM determines which portion of the Ethernet frame is currently being processed.

The initial states are:

```text
IDLE
DEST_MAC
SRC_MAC
ETHERTYPE
PAYLOAD
```

The FSM is responsible for:

* Detecting the beginning of a frame.
* Selecting the current frame field.
* Controlling field transitions.
* Resetting the local counter when entering a new field.
* Detecting the end of the frame.

The detailed state transitions are documented in `06_fsm_design.md`.

---

## 5. State-Local Counter

Each field uses a local byte counter.

```text
DEST_MAC:
    0 → 5

SRC_MAC:
    0 → 5

ETHERTYPE:
    0 → 1

PAYLOAD:
    0 → variable
```

The counter advances when a valid byte is processed.

The counter resets when transitioning to a new field.

This avoids coupling the control logic to absolute frame-wide byte offsets.

---

## 6. Destination MAC Datapath

While the FSM is in `DEST_MAC`, incoming bytes are stored in the destination MAC register.

```text
data_in[7:0]
     │
     ▼
┌──────────────────┐
│ dest_mac_reg     │
│      [47:0]      │
└──────────────────┘
```

Six bytes are required to construct the complete Destination MAC address.

---

## 7. Source MAC Datapath

While the FSM is in `SRC_MAC`, incoming bytes are stored in the source MAC register.

```text
data_in[7:0]
     │
     ▼
┌──────────────────┐
│ src_mac_reg      │
│      [47:0]      │
└──────────────────┘
```

Six bytes are required to construct the complete Source MAC address.

---

## 8. EtherType Datapath

While the FSM is in `ETHERTYPE`, incoming bytes are stored in the EtherType register.

```text
data_in[7:0]
     │
     ▼
┌──────────────────┐
│ ethertype_reg    │
│      [15:0]      │
└──────────────────┘
```

Two bytes are required to construct the complete EtherType value.

---

## 9. Payload Path

Once the EtherType field has been received, subsequent valid bytes are treated as payload.

The parser does not initially interpret the payload.

Instead:

```text
data_in
   │
   ▼
payload_data_o
```

with:

```text
payload_valid_o
```

indicating when the payload data is valid.

The frame ends when:

```text
valid_in == 1 && last_in == 1
```

---

## 10. Control and Datapath Relationship

The FSM determines which datapath operation should occur.

```text
                FSM
                 │
       ┌─────────┼──────────┐
       │         │          │
       ▼         ▼          ▼
   DEST_MAC   SRC_MAC   ETHERTYPE
       │         │          │
       ▼         ▼          ▼
    Capture    Capture    Capture
    dest MAC   src MAC    EtherType
```

The state identifies the current field, while the local counter identifies the byte position within that field.

For example:

```text
state = DEST_MAC
counter = 3
```

means that the fourth byte of the Destination MAC is currently being processed.

---

## 11. Future Extension

The parser is intended to provide a modular starting point for additional protocol-processing stages.

A possible future architecture is:

```text
Ethernet Parser
       │
       ▼
IPv4 Parser
       │
       ▼
UDP Parser
       │
       ▼
MoldUDP64 Parser
       │
       ▼
ITCH Decoder
       │
       ▼
Order Book
```

Each parser can process and forward a streaming payload to the next stage.

The initial Ethernet parser is therefore designed to separate Ethernet-specific processing from higher-level protocol processing.
