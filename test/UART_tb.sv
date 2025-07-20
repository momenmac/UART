`timescale 1ns/1ns

module testbench;
    localparam WIDTH_SIZE = 8;
    localparam CLK_FREQ = 576_000;
  	localparam CLK_PERIOD = 1736;

    
    reg clk;
    reg reset;
    
    reg Tx_valid;
    reg Tx_err;
    reg [WIDTH_SIZE-1:0] input_tx;
    reg PF;
    
    reg Rx;
    reg [1:0] sel;
    
    wire Tx;
    wire ready;
    wire [WIDTH_SIZE-1:0] Rx_data;
    wire Rx_valid;
    wire Rx_err;
    
    UART #(
      .WIDTH_SIZE(WIDTH_SIZE), .CLK_FREQ(CLK_FREQ)
    ) dut (
        .clk(clk),
        .reset(reset),
        .Tx_valid(Tx_valid),
        .Tx_err(Tx_err),
        .input_tx(input_tx),
        .PF(PF),
      .Rx(Tx),
        .sel(sel),
        .Tx(Tx),
        .ready(ready),
        .Rx_data(Rx_data),
        .Rx_valid(Rx_valid),
        .Rx_err(Rx_err)
    );
    
    initial begin
      	$dumpfile("dump.vcd");
      $dumpvars;
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end
    
    initial begin
        reset = 1;
        Tx_valid = 0;
        Tx_err = 0;
        input_tx = 8'h00;
        PF = 0;
        Rx = 1;
        sel = 2'b11;
        
        #100;
        reset = 0;
        #100;
      	reset = 1;
        
        @(posedge clk);
        input_tx = 8'hA5;
        Tx_valid = 1;
        @(posedge clk);
        Tx_valid = 1;
      
      wait(ready == 1)
      Tx_valid = 0;
      
      
        @(posedge clk);
        input_tx = 8'hAB;
        Tx_valid = 1;
        @(posedge clk);
        Tx_valid = 1;
      
      wait(ready == 1)
      Tx_valid = 0;
        
        #10000000;
        
        $display("Test completed");
        $finish;
    end
    
    initial begin
        $monitor("Time=%0t: Tx=%b, ready=%b, Rx_data=%h, Rx_valid=%b, Rx_err=%b", 
                 $time, Tx, ready, Rx_data, Rx_valid, Rx_err);
    end
    
endmodule