
```
<div align="center">

# UART Protocol — RTL Design & Verification

### Full-Stack Serial Communication Controller in Synthesizable Verilog HDL

[![Language](https://img.shields.io/badge/HDL-Verilog%20IEEE%201364--2005-1f6feb?style=for-the-badge&logo=v&logoColor=white)](https://github.com/ChallagollaSriPranathi/UART-Protocol)
[![Tool](https://img.shields.io/badge/EDA-Xilinx%20Vivado-ff6600?style=for-the-badge)](https://www.xilinx.com/products/design-tools/vivado.html)
[![Baud Rate](https://img.shields.io/badge/Baud%20Rate-9600%20bps-brightgreen?style=for-the-badge)](https://github.com/ChallagollaSriPranathi/UART-Protocol)
[![Clock](https://img.shields.io/badge/System%20Clock-50%20MHz-blue?style=for-the-badge)](https://github.com/ChallagollaSriPranathi/UART-Protocol)
[![Verified](https://img.shields.io/badge/Verification-101%20Bytes%20Loopback-success?style=for-the-badge)](https://github.com/ChallagollaSriPranathi/UART-Protocol)
[![License](https://img.shields.io/badge/License-MIT-lightgrey?style=for-the-badge)](LICENSE)

<br/>

> **A from-scratch, fully-parametric RTL implementation of the UART serial protocol** — featuring dual independent FSMs, a 16× oversampling receiver, synthesizable baud rate generation using `$clog2()`, and a self-checking testbench that verifies 101-byte round-trip data integrity.

</div>

---

## 🔍 Project Overview

This repository implements a **complete, industry-style UART (Universal Asynchronous Receiver/Transmitter) controller** from the ground up in Verilog HDL. Every layer of the design — from baud clock division to FSM state encoding to testbench verification tasks — is hand-crafted and documented.

The design is structured as a **four-module hierarchy**:

```
uart_top  ──┬──  baudrate_gen    (clock division: 1× TX, 16× RX)
            ├──  uart_transmitter (4-state FSM, LSB-first serializer)
            └──  uart_receiver    (3-state FSM, 16× oversampled deserializer)
```

Everything is **synthesizable RTL** — no `#delay`-driven logic, no behavioral-only constructs, no latches.

---

## 🏗️ Architecture

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

## ⏱️ UART Frame & Timing Analysis (50 MHz / 9600 baud)

### Frame Structure

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

### Timing Parameters

| Parameter | Value | Formula |
|-----------|-------|---------|
| Bit period | **104,167 ns** | `1 / 9600` |
| Full frame (10 bits) | **1.041 ms** | `10 × 104,167 ns` |
| TX counter rollover | **5208 cycles** | `50,000,000 / 9600` |
| RX oversample tick | **325 cycles** | `50,000,000 / (16 × 9600)` |
| Oversample resolution | **6510 ns** | Bit period / 16 |
| Start bit mid-check (tick 7) | **3797 ns** into start bit | Glitch < this = rejected |
| Data bit sample point (tick 15) | **97,656 ns** into bit period | Maximally centered |
| `counter_tx` register width | **13 bits** | `⌈log₂(5208)⌉` |
| `counter_rx` register width | **10 bits** | `⌈log₂(325)⌉` |

---

## 🧪 Simulation Results

```
Total bytes transmitted : 101 (values 0–100)
Total bytes received    : 101
Mismatches              : 0
Framing errors          : 0
Simulation time         : ~10 ms (@ 100 MHz TB clock)
```

---

## 👩‍💻 Author

<div align="center">

**Challagolla Sri Pranathi**

B.Tech — Electronics & Communication Engineering  
Jawaharlal Nehru Technological University Hyderabad (JNTUH) | Class of 2026  

[![GitHub](https://img.shields.io/badge/GitHub-ChallagollaSriPranathi-181717?style=flat-square&logo=github)](https://github.com/ChallagollaSriPranathi)

</div>

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
