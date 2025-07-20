module Tx_path #(parameter WIDTH_SIZE = 8)(input clk, input reset, input valid, input err, input [WIDTH_SIZE-1:0] input_tx, input PF, output reg Tx, output reg ready);
    reg [5:0] index;
    reg [3:0] parity_counter;
    reg [7:0] parity;
  
  	//added registers
  	reg err_reg;
  	reg [WIDTH_SIZE-1:0] data;
    
    typedef enum logic [1:0] { IDLE_STATE = 2'b00, START_STATE = 2'b01, DATA_STATE = 2'b10, STOP_STATE = 2'b11 } state_type;
    state_type state, next_state;
    
    reg [5:0] next_index;
    reg [3:0] next_parity_counter;
    reg [7:0] next_parity;
    reg next_err_reg;
    reg [WIDTH_SIZE-1:0] next_data;

    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            state <= IDLE_STATE;
            index <= 0;
            parity_counter <= 0;
            parity <= 0;
            err_reg <= 0;
            data <= 0;
        end 
        else begin
            state <= next_state;
            index <= next_index;
            parity_counter <= next_parity_counter;
            parity <= next_parity;
            err_reg <= next_err_reg;
            data <= next_data;
        end
    end

    always @(*) begin
        next_state = state;
        next_index = index;
        next_parity_counter = parity_counter;
        next_parity = parity;
        next_err_reg = err_reg;
        next_data = data;
        
        case (state)
            IDLE_STATE: begin
                next_index = 0;
                next_parity_counter = 0;
                next_parity = 0;
                
                if (valid == 1) begin
                    next_state = START_STATE;
                end
            end

            START_STATE: begin
                next_data = input_tx;
                next_err_reg = err;
                next_state = DATA_STATE;
            end

            DATA_STATE: begin
                if (parity_counter == 8) begin
                    next_parity_counter = (PF == 0) ? 1 : 0;
                    
                    //changed the condition
                    if(PF == 1 && WIDTH_SIZE > 8 && index < WIDTH_SIZE) begin
                        next_parity = 0;
                    end else begin
                        if(index >= WIDTH_SIZE) begin
                            next_state = STOP_STATE;
                        end 
                        else begin
                            next_index = index + 1;
                            next_parity = parity ^ data[index];
                            //added this condition
                            if(parity_counter != 8)
                                next_parity_counter = parity_counter + 1;
                        end
                    end
                end else begin
                    next_parity = parity ^ data[index];
                    next_index = index + 1;
                    next_parity_counter = parity_counter + 1;
                end
            end

            STOP_STATE: begin
                next_state = IDLE_STATE;
            end
        endcase
    end

    always @(*) begin
        Tx = 1;
        ready = 1;
        
        case (state)
            IDLE_STATE: begin
                Tx = 1;
              if (valid)
                ready = 0;
              else
                ready = 1;
            end

            START_STATE: begin
                ready = 0;
                Tx = 0;
            end

            DATA_STATE: begin
                ready = 0;
                if (parity_counter == 8) begin
                    if(PF == 1 && WIDTH_SIZE > 8 && index < WIDTH_SIZE) begin
                        Tx = (err_reg == 1) ? ~parity : parity;
                    end else begin
                        if(index >= WIDTH_SIZE) begin
                            Tx = (err_reg == 1) ? ~parity : parity;
                        end 
                        else begin
                            Tx = data[index];
                        end
                    end
                end else begin
                    Tx = data[index];
                end
            end

            STOP_STATE: begin
                Tx = 1;
                ready = 1;
            end
        endcase
    end


endmodule : Tx_path