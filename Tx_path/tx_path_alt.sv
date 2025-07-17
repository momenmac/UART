// Code your testbench here
// or browse Examples
module Tx_path_alt #(parameter WIDTH_SIZE = 8)(input clk, input reset, input valid, input err, input [WIDTH_SIZE-1:0] input_tx, input PF, output reg Tx, output reg ready);
    reg [5:0] index;
    reg [3:0] parity_counter;
    reg [7:0] parity;
  	reg err_reg;
  	reg [WIDTH_SIZE-1:0] data;
    
    typedef enum logic [1:0] { IDLE_STATE = 2'b00, START_STATE = 2'b01, DATA_STATE = 2'b10, STOP_STATE = 2'b11 } state_type;
    state_type state, next_state;

    // block 1 
    always @(posedge clk or posedge reset) begin
        if (reset)
            state <= IDLE_STATE;
        else
            state <= next_state;
    end

    // block 2: sequential logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            ready <= 0;
            Tx <= 1;
            index <= 0;
            parity_counter <= 0;
            parity <= 0;
            data <= 0;
            err_reg <= 0;
        end 
        else begin
            case (state)
                IDLE_STATE: begin
                    Tx <= 1;
                    ready <= 1;
                    index <= 0;
                    parity_counter <= 0;
                    parity <= 0;
                end

                START_STATE: begin
                    data <= input_tx;
                    err_reg <= err;
                    ready <= 0;
                    Tx <= 0;
                end

                DATA_STATE: begin
                    if (parity_counter == 8) begin
                        parity_counter <= (PF == 0) ? 1 : 0;
                        
                        //changed the condition
                        if(PF == 1 && WIDTH_SIZE > 8 && index < WIDTH_SIZE) begin
                            parity <= 0;
                            //simplified if statement
                            Tx <= (err_reg == 1) ? ~parity : parity;
                        end else begin
                            if(index >= WIDTH_SIZE) begin
                                Tx <= (err_reg == 1) ? ~parity : parity;
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
                end

            endcase
        end
    end

    // block 3: combinational logic 
    always @(*) begin
        next_state = state; // default to stay in current state
        
        case (state)
            IDLE_STATE: begin
                if (valid == 1)
                    next_state = START_STATE;
            end

            START_STATE: begin
                next_state = DATA_STATE;
            end

            DATA_STATE: begin
                if (parity_counter == 8) begin
                    if(PF == 1 && WIDTH_SIZE > 8 && index < WIDTH_SIZE) begin
                        // stay in DATA_STATE
                    end else begin
                        if(index >= WIDTH_SIZE) begin
                            next_state = STOP_STATE;
                        end 
                    end
                end
            end

            STOP_STATE: begin
                next_state = IDLE_STATE;
            end

        endcase
    end


endmodule : Tx_path;