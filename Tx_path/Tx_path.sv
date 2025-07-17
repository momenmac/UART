module Tx_path #(parameter WIDTH_SIZE = 8)(input clk, input reset, input valid, input err, input [WIDTH_SIZE-1:0] input_tx, input PF, output reg Tx, output reg ready);
    reg [5:0] index;
    reg [3:0] parity_counter;
    reg [7:0] parity;
  
  	//added registers
  	reg err_reg;
  	reg [WIDTH_SIZE-1:0] data;
    
    typedef enum logic [1:0] { IDLE_STATE = 2'b00, START_STATE = 2'b01, DATA_STATE = 2'b10, STOP_STATE = 2'b11 } state_type;
    state_type state = IDLE_STATE;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE_STATE;
            ready <= 0;
            Tx <= 1;
            index <= 0;
            parity_counter <= 0;
            parity <= 0;
        end 
        else begin
            case (state)
                IDLE_STATE: begin
					Tx <= 1;
                    ready <= 1;
                    index <= 0;
                    parity_counter <= 0;
                    parity <= 0;

                    if (valid == 1)
                        state <= START_STATE;
                end

                START_STATE: begin
                  	data <= input_tx;
                  	err_reg <= err;
                    ready <= 0;
                    Tx <= 0;
                  	
                    state <= DATA_STATE;

                end

                DATA_STATE: begin
                  if (parity_counter == 8) begin
                    parity_counter <= (PF == 0)? 1 :0;
                    
                    //changed the condition
                    if(PF == 1 && WIDTH_SIZE > 8 && index < WIDTH_SIZE) begin
						Tx <= parity;
						parity <= 0;
                      	//simplified if statment
                      	Tx <= (err_reg == 1) ? ~parity : parity;
                      
                        end else begin
                            if(index >= WIDTH_SIZE) begin
                              Tx <= (err_reg == 1) ? ~parity : parity;
                                state <= STOP_STATE;
                            end 
                          	else begin
                                Tx <= data[index];	 
								index <= index + 1;
                                parity <= parity ^ data[index];
                              //added this condition
                              if(parity_counter != 8)
                               	parity_counter <= parity_counter + 1;

                            end
                        end
                    end else begin
                        Tx <= data[index];
                        parity <= parity ^ data[index];
                        index <= index + 1;
                        parity_counter <= parity_counter + 1;
                    end
                end

                STOP_STATE: begin
                    Tx <= 1;
                    state <= IDLE_STATE;
                end

            endcase
        end
    end


endmodule : Tx_path;


