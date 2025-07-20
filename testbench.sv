// Testbench for UART module
`timescale 1ns/1ns

module testbench;
    parameter WIDTH_SIZE = 8;
    
    // Clock and reset
    reg clk;
    reg reset;
    
    // TX interface
    reg Tx_valid;
    reg Tx_err;
    reg [WIDTH_SIZE-1:0] input_tx;
    reg PF;
    
    // RX interface  
    reg Rx;
    reg [1:0] sel;
    
    // Outputs
    wire Tx;
    wire ready;
    wire [WIDTH_SIZE-1:0] Rx_data;
    wire Rx_valid;
    wire Rx_err;
    
    // Instantiate UART
    UART #(
        .WIDTH_SIZE(WIDTH_SIZE)
    ) dut (
        .clk(clk),
        .reset(reset),
        .Tx_valid(Tx_valid),
        .Tx_err(Tx_err),
        .input_tx(input_tx),
        .PF(PF),
        .Rx(Rx),
        .sel(sel),
        .Tx(Tx),
        .ready(ready),
        .Rx_data(Rx_data),
        .Rx_valid(Rx_valid),
        .Rx_err(Rx_err)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz clock
    end
    
    // Test sequence
    initial begin
        // Initialize signals
        reset = 1;
        Tx_valid = 0;
        Tx_err = 0;
        input_tx = 8'h00;
        PF = 0;
        Rx = 1;
        sel = 2'b00;
        
        // Reset sequence
        #100;
        reset = 0;
        #100;
        
        // Simple test
        @(posedge clk);
        input_tx = 8'hA5;
        Tx_valid = 1;
        @(posedge clk);
        Tx_valid = 0;
        
        // Wait for transmission
        #10000;
        
        $display("Test completed");
        $finish;
    end
    
    // Monitor outputs
    initial begin
        $monitor("Time=%0t: Tx=%b, ready=%b, Rx_data=%h, Rx_valid=%b, Rx_err=%b", 
                 $time, Tx, ready, Rx_data, Rx_valid, Rx_err);
    end
    
endmodule
