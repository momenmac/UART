# UART Transmitter & Receiver

A SystemVerilog implementation of a UART (Universal Asynchronous Receiver-Transmitter) with both TX and RX paths supporting configurable data widths and baud rates.

## Overview

This UART design operates on a 576 KHz clock and supports multiple data widths with optional parity per byte configuration. The implementation includes both transmitter and receiver paths with proper handshaking protocols.

## Features

- **Data Width Support**: 8, 16, 24, 32 bits
- **Baud Rate Support**: 9600, 19200, 38400, 57600 bps
- **Parity Support**: Optional parity per byte
- **Valid-Ready Protocol**: Handshaking for reliable data transfer
- **Error Detection**: Parity error detection and reporting

## Architecture

### TX Path
- **Input**: Synchronous parallel data with DATA_WIDTH bits
- **Protocol**: Valid-ready handshaking
- **Output**: Serial UART transmission
- **Features**: Error bit input for intentional parity errors

### RX Path
- **Input**: Serial UART data stream
- **Output**: Synchronous parallel data with DATA_WIDTH bits
- **Features**: Valid signal and error detection

### Modules

```
UART/
├── modules/
│   ├── UART.sv          # Top-level UART module
│   ├── Tx_path.sv       # Transmitter implementation
│   ├── Rx_path.sv       # Receiver implementation
│   └── baud_gen.sv      # Baud rate generator
├── test/
│   ├── UART_tb.sv       # (To be implemented)
│   ├── Tx_path_tb.sv    # Transmitter testbench
│   ├── Rx_path_tb.sv    # Receiver testbench
│   └── baud_gen_tb.sv   # Baud generator testbench
├── alt/
│   └── tx_path_alt.sv   # Alternative TX implementation
└── asm/
    ├── rx.jpg           # RX state machine diagram
    └── Tx.jpg           # TX state machine diagram
```

## Configuration Parameters

### UART Module Parameters
- `WIDTH_SIZE`: Data width (8, 16, 24, or 32 bits)

### Baud Rate Selection
The `sel` input controls baud rate:
- `2'b00`: 9600 bps
- `2'b01`: 19200 bps  
- `2'b10`: 38400 bps
- `2'b11`: 57600 bps

### Parity Configuration
- `PF`: Parity flag enable (1 = parity per byte enabled, 0 = disabled)

## Interface Signals

### Top-level UART Module

#### Inputs
- `clk`: System clock (576 KHz)
- `reset`: Active high reset
- `Tx_valid`: Transmit data valid
- `Tx_err`: Force transmit error (for testing)
- `input_tx[WIDTH_SIZE-1:0]`: Parallel data to transmit
- `PF`: Parity flag configuration
- `Rx`: Serial receive data input
- `sel[1:0]`: Baud rate selection

#### Outputs
- `Tx`: Serial transmit data output
- `ready`: Transmitter ready for new data
- `Rx_data[WIDTH_SIZE-1:0]`: Received parallel data
- `Rx_valid`: Received data valid
- `Rx_err`: Receive error flag

## State Machines

The UART implementation uses finite state machines for both TX and RX paths. **Note: The state machine diagrams in the `asm/` folder need to be updated** to reflect the current implementation:

- `asm/rx.jpg`: RX path state machine (needs update)
- `asm/Tx.jpg`: TX path state machine (needs update)

### TX States
1. **IDLE_STATE**: Ready for new transmission
2. **START_STATE**: Send start bit
3. **DATA_STATE**: Send data bits with optional parity
4. **STOP_STATE**: Send stop bit

### RX States
1. **IDLE_STATE**: Waiting for start bit
2. **DATA_STATE**: Receiving data bits and parity
3. **STOP_STATE**: Validate stop bit

## Usage Example

```systemverilog
UART #(
    .WIDTH_SIZE(8)
) uart_inst (
    .clk(clk_576khz),
    .reset(reset),
    .Tx_valid(tx_valid),
    .Tx_err(1'b0),
    .input_tx(data_to_send),
    .PF(parity_enable),
    .Rx(uart_rx_line),
    .sel(2'b00),        // 9600 bps
    .Tx(uart_tx_line),
    .ready(tx_ready),
    .Rx_data(received_data),
    .Rx_valid(rx_valid),
    .Rx_err(rx_error)
);
```

## Testing

The project includes testbenches for individual modules:
- `baud_gen_tb.sv`: Tests baud rate generation
- `Tx_path_tb.sv`: Tests transmitter functionality
- `Rx_path_tb.sv`: Tests receiver functionality

## Development Notes

- Clock frequency: 576 KHz
- Supports multiple data widths through parameterization
- Implements proper UART protocol with start, data, optional parity, and stop bits
- Error handling for parity mismatches
- Ready-valid handshaking for flow control

## TODO

- [ ] Update state machine diagrams in `asm/` folder
- [ ] Implement top-level UART testbench
- [ ] Add timing diagrams
- [ ] Verify all supported configurations
- [ ] Add synthesis reports

## Files Status

- ✅ Core modules implemented
- ✅ Individual testbenches available  
- ⚠️ ASM diagrams need updating
- ❌ Top-level testbench pending
