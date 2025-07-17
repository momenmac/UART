`timescale 1ns / 1ps
`include "../modules/baud_gen.sv"

module baud_gen_tb();
    reg clk;
    reg reset;
    reg [1:0] sel;
    wire baud_clk;
    
    //576 KHz clock: 1/576000 = 1.736 us = 1736 ns
    parameter CLK_PERIOD = 1736;
    
    baud_gen dut (
        .clk(clk),
        .reset(reset),
        .sel(sel),
        .baud_clk(baud_clk)
    );
    
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end
    
    initial begin
        reset = 0;
        sel = 2'b00;
        
        #(5*CLK_PERIOD);
        reset = 1;
        #(5*CLK_PERIOD);
        
        $display("Starting Baud Generator Test");
        $display("Time\t\tSel\tBaud Rate\tBaud CLK");
        $display("----\t\t---\t---------\t--------");
        
        sel = 2'b00;
        #(2*CLK_PERIOD); 
        $display("Testing sel = 00 (9600 baud, counter limit = 60)");
        #(130*CLK_PERIOD); 
        
       
        sel = 2'b01;
        #(2*CLK_PERIOD); 
        $display("Testing sel = 01 (19200 baud, counter limit = 30)");
        #(65*CLK_PERIOD); 
        
        
        sel = 2'b10;
        #(2*CLK_PERIOD); 
        $display("Testing sel = 10 (38400 baud, counter limit = 15)");
        #(35*CLK_PERIOD); 
        
        sel = 2'b11;
        #(2*CLK_PERIOD); 
        $display("Testing sel = 11 (57600 baud, counter limit = 10)");
        #(25*CLK_PERIOD); 
        
        $display("Testing reset functionality");
        reset = 0;
        #(10*CLK_PERIOD);
        reset = 1;
        #(10*CLK_PERIOD);
        
        $display("Baud Generator Test Completed");
        $finish;
    end
    
    always @(posedge baud_clk or negedge baud_clk) begin
        $display("%0t ns:\tsel=%b\tbaud_rate=%0d\tbaud_clk=%b", 
                 $time, sel, dut.baud_rate, baud_clk);
    end
    
    initial begin
        $dumpfile("baud_gen_tb.vcd");
        $dumpvars(0, baud_gen_tb);
    end
    
endmodule
