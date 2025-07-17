module baud_gen (input clk, input reset, input [1:0] sel, output reg baud_clk);
    reg [5:0] counter;
    reg [5:0] baud_rate;
    
    always @(*) begin
        case(sel)
            2'b00: baud_rate = 60; // 9600 baud 
            2'b01: baud_rate = 30; // 19200 baud
            2'b10: baud_rate = 15;  // 38400 baud  
            2'b11: baud_rate = 10;  // 57600 baud
        endcase
    end
    
    always @(posedge clk or negedge reset) begin
        if(!reset) begin
            counter <= 0;
            baud_clk <= 0;  
        end else begin
            if(counter >= baud_rate - 1) begin
                counter <= 0;
                baud_clk <= ~baud_clk; 
            end else begin
                counter <= counter + 1;
            end
        end
    end
endmodule