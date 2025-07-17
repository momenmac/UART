module tx_tb;
  	parameter width = 32;
    reg clk;
    reg reset;
    reg valid;
    reg err;
  	reg [width -1:0] input_tx;
    reg PF;
    wire Tx;
    wire ready;

    Tx_path #(
      .WIDTH_SIZE(width) 
    ) uut (
        .clk(clk),
        .reset(reset),
        .valid(valid),
        .err(err),
        .input_tx(input_tx),
        .PF(PF),
        .Tx(Tx),
        .ready(ready)
    );

    initial begin
        $dumpfile("tx_tb.vcd");
        $dumpvars(0, tx_tb);
        clk = 0;
        reset = 0;
        valid = 0;
        err = 0;
        PF = 0;

		repeat (5) @(posedge clk)
        reset = 1;
      	repeat (10) @(posedge clk)
        reset = 0;
      
      	@(posedge clk)
   		valid = 1;
        input_tx = 'b01010101010101010101010101010101;
      	@(negedge ready)
      	valid = 0;
      
      	@(posedge clk)
      	valid = 1;
        err = 1;
        input_tx = 'b01010101010101010101011101011101;
      	@(negedge ready)
      	valid = 0;
      
      
      	@(posedge clk)
   		valid = 1;
        PF = 1;
      	err = 0;
        input_tx = 'b01010101010101010101010101010101;
      	@(negedge ready)
      	valid = 0;
        


        #1000
        $finish;
    end

    initial begin
    $monitor("Time=%0t | reset=%b | valid=%b | err=%b | input_tx=%h | PF=%b | Tx=%b | ready=%b", 
             $time, reset, valid, err, input_tx, PF, Tx, ready);
    end

    // Clock generation
    always #10 clk = ~clk;

endmodule : tx_tb;