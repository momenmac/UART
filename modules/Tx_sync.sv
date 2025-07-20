module Tx_sync(input clk, input reset, input Tx_valid, input ready_reg, output reg ready);
    typedef enum logic { IDLE = 0, ACTIVE = 1} state_t;
    state_t ready_state;

    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            ready_state <= IDLE;
        end
        else begin
            case (ready_state)
                IDLE: begin
                    if (Tx_valid && ready_reg)
                        ready_state <= ACTIVE;
                end
                ACTIVE: begin
                    if (!Tx_valid || !ready_reg)
                        ready_state <= IDLE;
                end
            endcase
        end
    end

    always @(*) begin
        case (ready_state)
            IDLE: ready = ready_reg; 
            ACTIVE: ready = 0; 
        endcase
    end
endmodule