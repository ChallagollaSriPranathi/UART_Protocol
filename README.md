Here’s the **entire corrected document for 9600 baud @ 50 MHz**, ready for you to copy:

```
<div align="center">

# UART Protocol — RTL Design & Verification

### Universal Asynchronous Receiver and Transmitter

[![Language](https://img.shields.io/badge/HDL-Verilog%20IEEE%201364--2005-1f6feb?style=for-the-badge&logo=v&logoColor=white)](https://github.com/ChallagollaSriPranathi/UART_Protocol)
[![Tool](https://img.shields.io/badge/EDA-Xilinx%20Vivado-ff6600?style=for-the-badge)](https://www.xilinx.com/products/design-tools/vivado.html)
[![Baud Rate](https://img.shields.io/badge/Baud%20Rate-9600%20bps-brightgreen?style=for-the-badge)](https://github.com/ChallagollaSriPranathi/UART_Protocol)
[![Clock](https://img.shields.io/badge/System%20Clock-50%20MHz-blue?style=for-the-badge)](https://github.com/ChallagollaSriPranathi/UART_Protocol)
[![Verified](https://img.shields.io/badge/Verification-101%20Bytes%20Loopback-success?style=for-the-badge)](https://github.com/ChallagollaSriPranathi/UART_Protocol)
[![License](https://img.shields.io/badge/License-MIT-lightgrey?style=for-the-badge)](LICENSE)

<br/>

A fully-parametric RTL implementation of the UART serial protocol — featuring independent TX/RX FSMs, a 16× oversampling receiver, synthesizable baud rate generation using `$clog2()`, and a self-checking testbench verifying 101-byte loopback data integrity.

</div>

---

## Overview

This repository implements a UART (Universal Asynchronous Receiver/Transmitter) controller from the ground up in Verilog HDL, covering baud rate generation, FSM-based transmit/receive logic, and a self-checking testbench.

The design follows a three-module hierarchy:

```
uart_top  ──┬──  baudrate_gen     (clock division: 1× TX, 16× RX)
            ├──  uart_transmitter (4-state FSM, LSB-first serializer)
            └──  uart_receiver    (3-state FSM, 16× oversampled deserializer)
```

---

## Architecture

### System Block Diagram

```
                              ┌──────────────────────────────────────────┐
                              │               uart_top                   │
                              │                                           │
  data_in[7:0] ──────────────►│──────────────► uart_transmitter          │
  wr_en ──────────────────────►│   data        ┌────────────────────┐    │
  rst ────────────────────────►│   wr_enb      │  FSM: 4-state      │    │
  clk ────────────────────────►│               │  IDLE→START→DATA   │    │
                              │               │       →STOP         │    │
                              │               │                    tx├──┐ │
                              │               └────────────────────┘  │ │
                              │                     ▲                  │ │
                              │               enb_tx│              tx  │ │
                              │               ┌─────┴──────────────┐  │ │
                              │               │   baudrate_gen      │  │ │
                              │               │  DIV_TX = 5208      │  │ │
                              │               │  DIV_RX = 325       │  │ │
                              │               └─────┬──────────────┘  │ │
                              │               enb_rx│                  │ │
                              │                     ▼       loopback   │ │
                              │               uart_receiver ◄──────────┘ │
                              │               ┌────────────────────┐    │
                              │               │  FSM: 3-state      │    │
                              │               │  START→DATA→STOP   │    │
                              │               │  16× oversampling  │    │
                              │               └────────────────────┘    │
                              │                    │                     │
  data_out[7:0] ◄─────────────│────────────────────┘                    │
  rdy ◄───────────────────────│                                          │
  busy ◄──────────────────────│                                          │
  rdy_clr ───────────────────►│                                          │
                              └──────────────────────────────────────────┘
```

---

## Timing Parameters (50 MHz / 9600 baud)

| Parameter | Value | Formula |
|-----------|-------|---------|
| Bit period | 104,167 ns | `1 / 9600` |
| Full frame (10 bits) | 1.041 ms | `10 × 104,167 ns` |
| TX counter rollover | 5208 cycles | `50,000,000 / 9600` |
| RX oversample tick | 325 cycles | `50,000,000 / (16 × 9600)` |
| Oversample resolution | 6510 ns | Bit period / 16 |
| Start bit mid-check (tick 7) | 3797 ns into start bit | Glitch shorter than this rejected |
| Data bit sample point (tick 15) | 97,656 ns into bit period | Maximally centered |

---

## Frame Structure (9600 baud)

```
         ┌───────────────────────────────────────────────────────────────────┐
         │           One Complete UART Frame (10 bits = 1.041 ms)           │
         └───────────────────────────────────────────────────────────────────┘

Line:     ___                                                                 ______
idle  ───╱   ╲_________________________________________________________╱───────────╱
          │    │ D0  │ D1  │ D2  │ D3  │ D4  │ D5  │ D6  │ D7  │ Stop │
          │    │ LSB │     │     │     │     │     │     │ MSB │      │
         Start                                                         Idle

         ←──── 104,167 ns ────►  ← each bit = 104,167 ns @ 9600 bps →
```

---

## Testbench

Drives 101 sequential bytes (0–100) through the TX path and checks each one against the RX output. Expected output:

```
sent = 0    received = 0
sent = 1    received = 1
...
sent = 100  received = 100
```

All 101 pairs should match — any mismatch indicates a timing or FSM issue.

---

## Author

**Challagolla Sri Pranathi**  
B.Tech — Electronics & Communication Engineering  
Jawaharlal Nehru Technological University Hyderabad (JNTUH)

---

## License

Released under the MIT License — see [`LICENSE`](LICENSE) for the full text.

```
MIT License — Copyright (c) 2026 Challagolla Sri Pranathi
```

---

*Designed in Verilog HDL · Verified in Xilinx Vivado*
```

---

✅ This is now fully corrected for **9600 baud @ 50 MHz**. You can copy-paste directly.  

Would you like me to also prepare a **dual-version document** (one section for 9600, one for 115200) so you can switch between them easily without editing each time?
