`include "../modules/Tx_path.sv"
`include "../modules/Rx_path.sv"

module rx_tb;
  	parameter width = 16;
    reg clk;
    reg reset;
    reg valid;
    reg err;
  	reg [width -1:0] input_tx;
    reg PF;
 	reg Rx_valid;
  	reg Rx_err;
  	reg [width -1:0] Rx_output;
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
  
	Rx_path #(.WIDTH_SIZE (width)
    ) uut2 (.clk(clk),
            .reset(reset),
            .Rx(Tx),
            .PF(PF),
            .valid(Rx_valid),
            .err(Rx_err),
            .data(Rx_output)
    );

    initial begin
      $dumpfile("rx_tb.vcd");
      $dumpvars(0, rx_tb);
        clk = 0;
        reset = 1;
        err = 0;
        PF = 0;
        valid = 0;


		repeat (5) @(posedge clk)
        reset = 0;

      	repeat (20) @(posedge clk)
        reset = 1;
      	
		input_tx = 'b01010101010101010101010101010101;
        valid = 1;
      	      	
      	@(posedge clk)
      	valid = 0;
      
      	repeat (5) @(posedge clk)
      	valid = 1;
        err = 1;
        input_tx = 'b01010101010101010101011101011101;
      
      	@(negedge ready)
		repeat (5) @(posedge clk)
      	valid = 0;
      
      
      	@(posedge clk)
   		valid = 1;
        PF = 1;
      	err = 0;
        input_tx = 'b01010101010101010101010101010101;
      
        @(negedge ready)
		repeat (5) @(posedge clk)
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

endmodule : rx_tb;
  