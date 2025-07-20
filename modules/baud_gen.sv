module baud_gen #(
    parameter CLK_FREQ = 576_000  
)(
    input clk, 
    input reset, 
    input [1:0] sel, 
    output reg baud_clk
);
    
  localparam BAUD_9600_DIV   = CLK_FREQ / (9600 * 2);
  localparam BAUD_19200_DIV  = CLK_FREQ / (19200 * 2);
  localparam BAUD_38400_DIV  = CLK_FREQ / (38400 * 2);
  localparam BAUD_57600_DIV  = CLK_FREQ / (57600 * 2);

    localparam COUNTER_WIDTH = $clog2(BAUD_9600_DIV + 1);
    
    reg [COUNTER_WIDTH-1:0] counter;
    reg [COUNTER_WIDTH-1:0] baud_div;
    
    always @(*) begin
        case(sel)
            2'b00: baud_div = BAUD_9600_DIV;   // 9600 baud 
            2'b01: baud_div = BAUD_19200_DIV;  // 19200 baud
            2'b10: baud_div = BAUD_38400_DIV;  // 38400 baud  
            2'b11: baud_div = BAUD_57600_DIV;  // 57600 baud
        endcase
    end
    
    always @(posedge clk or negedge reset) begin
        if(!reset) begin
            counter <= 0;
            baud_clk <= 0;  
        end else begin
            if(counter >= baud_div) begin
                counter <= 0;
                baud_clk <= ~baud_clk; 
            end else begin
                counter <= counter + 1;
            end
        end
    end
    
endmodule