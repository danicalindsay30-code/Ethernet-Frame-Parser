# FSM Design

## 1. Overview

The Ethernet Frame Parser uses a finite state machine (FSM) to control the processing of an incoming Ethernet II frame.

The FSM determines which field of the frame is currently being processed. A state-local byte counter is used to determine which byte within that field is currently being processed.

The parser processes the frame in the following order:

```text
IDLE → DEST_MAC → SRC_MAC → ETHERTYPE → PAYLOAD → IDLE
```

The parser uses the following input control signals:

* `valid_in` — indicates that `data_in` contains a valid byte.
* `last_in` — indicates that the current valid byte is the final byte of the frame.

---

## 2. States

### 2.1 `IDLE`

**Purpose:**

The parser starts in `IDLE` and waits for the beginning of a new Ethernet frame.

**Operation:**

* Wait for `valid_in` to become `1`.
* No frame data is captured while waiting.
* The byte counter is reset and ready for a new frame.

**Exit condition:**

```text
valid_in == 1
```

**Next state:**

```text
DEST_MAC
```

---

### 2.2 `DEST_MAC`

**Purpose:**

Capture the 6-byte Destination MAC address.

**Entry condition:**

The parser enters this state when a valid byte is received while in `IDLE`.

**Operation:**

* Capture each valid `data_in` byte into `dest_mac_reg`.
* Increment the state-local byte counter after each valid byte.
* The counter represents the byte position within the Destination MAC field.

**Counter range:**

```text
0 → 5
```

The counter corresponds to:

| Counter | Byte                   |
| ------: | ---------------------- |
|     `0` | Destination MAC byte 0 |
|     `1` | Destination MAC byte 1 |
|     `2` | Destination MAC byte 2 |
|     `3` | Destination MAC byte 3 |
|     `4` | Destination MAC byte 4 |
|     `5` | Destination MAC byte 5 |

**Exit condition:**

```text
valid_in == 1 && counter == 5
```

The byte received when `counter == 5` is the sixth and final byte of the Destination MAC address.

**Next state:**

```text
SRC_MAC
```

**Counter behaviour:**

The counter is reset when transitioning to `SRC_MAC`.

---

### 2.3 `SRC_MAC`

**Purpose:**

Capture the 6-byte Source MAC address.

**Entry condition:**

The parser enters this state after the final Destination MAC byte has been received.

**Operation:**

* Capture each valid `data_in` byte into `src_mac_reg`.
* Increment the state-local byte counter after each valid byte.
* The counter represents the byte position within the Source MAC field.

**Counter range:**

```text
0 → 5
```

The counter corresponds to:

| Counter | Byte              |
| ------: | ----------------- |
|     `0` | Source MAC byte 0 |
|     `1` | Source MAC byte 1 |
|     `2` | Source MAC byte 2 |
|     `3` | Source MAC byte 3 |
|     `4` | Source MAC byte 4 |
|     `5` | Source MAC byte 5 |

**Exit condition:**

```text
valid_in == 1 && counter == 5
```

The byte received when `counter == 5` is the sixth and final byte of the Source MAC address.

**Next state:**

```text
ETHERTYPE
```

**Counter behaviour:**

The counter is reset when transitioning to `ETHERTYPE`.

---

### 2.4 `ETHERTYPE`

**Purpose:**

Capture the 2-byte EtherType field.

**Entry condition:**

The parser enters this state after the final Source MAC byte has been received.

**Operation:**

* Capture each valid `data_in` byte into `ethertype_reg`.
* Increment the state-local byte counter after each valid byte.
* The counter represents the byte position within the EtherType field.

**Counter range:**

```text
0 → 1
```

The counter corresponds to:

| Counter | Byte             |
| ------: | ---------------- |
|     `0` | EtherType byte 0 |
|     `1` | EtherType byte 1 |

For example, an IPv4 EtherType is:

```text
0x0800
```

which arrives as:

```text
08
00
```

The two bytes are combined to form:

```text
ethertype_reg = 16'h0800
```

**Exit condition:**

```text
valid_in == 1 && counter == 1
```

The byte received when `counter == 1` is the second and final EtherType byte.

**Next state:**

```text
PAYLOAD
```

**Counter behaviour:**

The counter is reset when transitioning to `PAYLOAD`.

---

### 2.5 `PAYLOAD`

**Purpose:**

Process the variable-length payload following the Ethernet II header.

**Entry condition:**

The parser enters this state after the final EtherType byte has been received.

**Operation:**

* For every valid input byte, forward `data_in` to the payload output.
* Assert `payload_valid` when a valid payload byte is available.
* Continue processing payload bytes until the end of the frame is indicated by `last_in`.
* The payload counter may be used to track the number of payload bytes processed.

**Counter range:**

```text
0 → variable
```

Unlike the Destination MAC, Source MAC and EtherType fields, the payload does not have a fixed length.

**Continue condition:**

```text
valid_in == 1 && last_in == 0
```

The parser remains in `PAYLOAD`.

**Exit condition:**

```text
valid_in == 1 && last_in == 1
```

The current byte is the final byte of the frame.

**Next state:**

```text
IDLE
```

**Counter behaviour:**

The counter is reset when returning to `IDLE`.

---

# 3. FSM State Diagram

The overall FSM is:

<img width="1338" height="802" alt="image" src="https://github.com/user-attachments/assets/62f20502-5779-4eb0-8e7c-9cd55326b9ad" />


---

# 4. State Transition Table

| Current State | Event / Condition          | Action                                          | Next State  |
| ------------- | -------------------------- | ----------------------------------------------- | ----------- |
| `IDLE`        | `valid_in`                 | Begin processing frame                          | `DEST_MAC`  |
| `DEST_MAC`    | `valid_in`                 | Capture destination MAC byte; increment counter | `DEST_MAC`  |
| `DEST_MAC`    | `valid_in && counter == 5` | Capture final destination byte; reset counter   | `SRC_MAC`   |
| `SRC_MAC`     | `valid_in`                 | Capture source MAC byte; increment counter      | `SRC_MAC`   |
| `SRC_MAC`     | `valid_in && counter == 5` | Capture final source byte; reset counter        | `ETHERTYPE` |
| `ETHERTYPE`   | `valid_in`                 | Capture EtherType byte; increment counter       | `ETHERTYPE` |
| `ETHERTYPE`   | `valid_in && counter == 1` | Capture final EtherType byte; reset counter     | `PAYLOAD`   |
| `PAYLOAD`     | `valid_in && !last_in`     | Forward payload byte                            | `PAYLOAD`   |
| `PAYLOAD`     | `valid_in && last_in`      | Forward final payload byte; reset counter       | `IDLE`      |

---

# 5. State-Local Counter Design

A state-local counter is used rather than a single counter representing the position within the entire frame.

The counter therefore has a different meaning depending on the current state.

```text
DEST_MAC
counter: 0 → 5
```

means:

> Which byte of the Destination MAC am I processing?

```text
SRC_MAC
counter: 0 → 5
```

means:

> Which byte of the Source MAC am I processing?

```text
ETHERTYPE
counter: 0 → 1
```

means:

> Which byte of the EtherType am I processing?

This provides a separation between the **frame field being processed** and the **byte position within that field**.

---

# 6. FSM Responsibilities

The FSM is responsible for **control**, rather than storing the frame data itself.

### FSM

Determines:

* Which field is currently being processed.
* When to transition to the next field.
* When the byte counter should reset.
* When payload processing begins.
* When the frame has finished.

### Byte Counter

Determines:

* Which byte within the current field is being processed.

### Registers / Datapath

Store or process:

* Destination MAC.
* Source MAC.
* EtherType.
* Payload data.

Conceptually:

```text
                 ┌───────────────┐
                 │      FSM      │
                 │    CONTROL    │
                 └───────┬───────┘
                         │
                         │ controls
                         ▼
                 ┌───────────────┐
                 │    Datapath   │
                 │               │
                 │  Registers    │
                 │  Counter      │
                 │  Payload      │
                 └───────────────┘
```

The FSM therefore answers:

> **What field am I processing?**

The counter answers:

> **Which byte of that field am I processing?**

The datapath answers:

> **What should I do with this byte?**
