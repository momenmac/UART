`include "Tx_path.sv"
`include "Rx_path.sv"
`include "baud_gen.sv"

module UART #(parameter WIDTH_SIZE = 8)(
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
    output reg Rx_err,
    output reg Tx_err
);
    reg baud_rate;

Rx_path #(
    .WIDTH_SIZE(WIDTH_SIZE)
) rx_inst (
    .clk(baud_clk),
    .reset(reset),
    .Rx(Rx),
    .PF(PF),
    .valid(Rx_valid),
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
    .ready(ready)
);

baud_gen baud_gen_inst (
    .clk(clk),
    .reset(reset),
    .sel(sel),
    .baud_clk(baud_clk)
);

endmodule : UART