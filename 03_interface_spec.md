# Ethernet Frame Parser — Interface Specification

## 1. Overview

The Ethernet Frame Parser uses a streaming interface to receive Ethernet II frame data.

The input interface presents one 8-bit byte at a time. Control signals indicate whether the byte is valid and whether it is the final byte of the frame.

---

## 2. Clock and Reset

| Signal  | Direction | Width | Description      |
| ------- | --------- | ----: | ---------------- |
| `clk`   | Input     |     1 | System clock     |
| `rst_n` | Input     |     1 | Active-low reset |

---

## 3. Input Interface

| Signal     | Direction | Width | Description                                                    |
| ---------- | --------- | ----: | -------------------------------------------------------------- |
| `data_in`  | Input     |     8 | Current input byte                                             |
| `valid_in` | Input     |     1 | Indicates that `data_in` is valid                              |
| `last_in`  | Input     |     1 | Indicates that the current byte is the final byte of the frame |

### Streaming Behaviour

When:

```text
valid_in = 1
```

the parser shall process `data_in` as a valid byte.

When:

```text
valid_in = 0
```

the parser shall not consume `data_in` as part of the frame.

When:

```text
valid_in = 1
last_in = 1
```

the current byte shall be treated as the final byte of the frame.

---

## 4. Output Interface

| Signal            | Direction | Width | Description                                            |
| ----------------- | --------- | ----: | ------------------------------------------------------ |
| `dest_mac_o`      | Output    |    48 | Extracted Destination MAC address                      |
| `src_mac_o`       | Output    |    48 | Extracted Source MAC address                           |
| `ethertype_o`     | Output    |    16 | Extracted EtherType                                    |
| `payload_data_o`  | Output    |     8 | Current payload byte                                   |
| `payload_valid_o` | Output    |     1 | Indicates valid payload data                           |
| `frame_done_o`    | Output    |     1 | Indicates that the frame has been completely processed |

---

## 5. Field Validity

The parser shall provide a mechanism for indicating when the extracted header fields are valid.

The exact timing and duration of the field-valid indication will be defined during RTL design.

---

## 6. Interface Assumptions

The initial parser assumes:

* Input data is presented one byte at a time.
* Preamble and SFD have already been handled by an upstream component.
* The parser begins processing at the Destination MAC field.
* Frame termination is indicated using `last_in`.
* FCS processing is outside the parser's initial scope.

---

## 7. Future Interface Considerations

The interface may later be adapted to a full AXI4-Stream interface for integration with AMD/Xilinx Ethernet and DMA infrastructure.

The initial parser is therefore designed around the conceptual streaming signals:

```text
data
valid
last
```

with AXI4-Stream integration treated as a later project stage.
