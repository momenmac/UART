// Code your design here
module Rx_path #(parameter WIDTH_SIZE = 8) (input clk, input reset, input Rx, input PF, output reg valid, output reg err, output reg [WIDTH_SIZE - 1:0] data);
	reg [5:0] bit_counter;
	reg [3:0] parity_counter;
	reg parity;

	typedef enum logic [1:0] {IDLE_STATE = 2'b00, DATA_STATE = 2'b01, STOP_STATE = 2'b10} state_type;
	state_type state = IDLE_STATE;	
  always @(posedge clk or negedge reset) begin
      if (!reset)
			begin
				state <= IDLE_STATE;
				parity_counter <= 0;
				bit_counter <= 0;
				parity <=0;
				err <= 0;
				data <= 0;
				valid <= 0;
			end
			
		else begin
			case(state)
				IDLE_STATE: begin
					valid <= 0;
					bit_counter <= 0;
					parity_counter <= 0;
					parity <=0;
                  	err <= 0;
					
					if(!Rx)
						state <= DATA_STATE;
				end
				
				DATA_STATE:begin
					if(parity_counter == 8 && PF) begin
						if(parity != Rx)
							err <= 1;
						parity_counter <= 0;
						parity <= 0;
						
						if(bit_counter >= WIDTH_SIZE)
							state <= STOP_STATE;
					end
					else begin
						if (bit_counter < WIDTH_SIZE)begin
                            data <= {Rx, data [WIDTH_SIZE -1:1]};
							parity <= parity ^ Rx;
							bit_counter <= bit_counter + 1;
							parity_counter <= parity_counter + 1;
						end
						else begin
                            if (parity != Rx)
                                err <= 1;
                          	state <= STOP_STATE;

						end
					end
				end
				
				STOP_STATE:begin
					valid <= 1;
					state <= IDLE_STATE;
				end
            endcase
		end
    end

endmodule: Rx_path;