`include "Tx_path.sv"
`include "Rx_path.sv"
`include "baud_gen.sv"
`include "Rx_sync.sv"
`include "Tx_sync.sv"

module UART #(parameter WIDTH_SIZE = 8, parameter CLK_FREQ = 576_000)(
    input clk,
    input reset,
    input Tx_valid,
    input Tx_err,
    input [WIDTH_SIZE-1:0] input_tx,
    input PF,
    input Rx,
    input [1:0] sel,
    output reg Tx,
    output reg ready,
    output reg [WIDTH_SIZE-1:0] Rx_data,
    output reg Rx_valid,
    output reg Rx_err);
  
    reg baud_clk;
  
  	reg ready_reg;
  	reg rx_valid_reg;

Rx_path #(
    .WIDTH_SIZE(WIDTH_SIZE)
) rx_inst (
  .clk(baud_clk),
    .reset(reset),
    .Rx(Rx),
    .PF(PF),
    .valid(rx_valid_reg),
    .err(Rx_err),
    .data(Rx_data)
);

Tx_path #(
    .WIDTH_SIZE(WIDTH_SIZE)
) tx_inst (
  .clk(baud_clk),
    .reset(reset),
    .valid(Tx_valid),
    .err(Tx_err),
    .input_tx(input_tx),
    .PF(PF),
    .Tx(Tx),
    .ready(ready_reg)
);

  baud_gen #(.CLK_FREQ(CLK_FREQ)) baud_gen_inst (
    .clk(clk),
    .reset(reset),
    .sel(sel),
  .baud_clk(baud_clk)
);

Rx_sync rx_sync_inst (
    .clk(clk),
    .reset(reset),
    .valid_reg(rx_valid_reg),
    .Rx_valid(Rx_valid)
);
  
  Tx_sync tx_sync_inst (
    .clk(clk),
    .reset(reset),
    .Tx_valid(Tx_valid),
    .ready_reg(ready_reg),
    .ready(ready)
);
  
endmodule : UART