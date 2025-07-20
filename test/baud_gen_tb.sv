`timescale 1us/1ns

module brg_tb;

    localparam CLK_FREQ = 576_000;
    //576 KHz clock: 1/576000 = 1.736 us = 1736 ns
    localparam CLK_PERIOD = 1736;

    logic clk;
    logic rst_n;
    logic [1:0] select;
    logic baud_tick;

    baud_gen #(.CLK_FREQ(CLK_FREQ)) dut (
        .clk(clk),
        .reset(rst_n),
        .sel(select),
        .baud_clk(baud_tick)
    );
  
  	initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

	integer i;
  
      initial begin
        $dumpfile("baud_gen_tb.vcd");
        $dumpvars;
    end
    initial begin
        rst_n = 0;
        select = 2'b00;
        #5;
        rst_n = 1;

        
        for (i = 0; i < 4; i = i + 1) begin
            select = i[1:0];
            $display("Testing select = %0d", select);
            repeat (1000) begin
                @(posedge clk);
                if (baud_tick)
                    $display("Time %0t: baud_tick (select=%0d)", $time, select);
            end
        end

        $display("Testbench finished.");
        $finish;
    end

endmodule