module Rx_sync (input clk, input reset, input valid_reg, output reg Rx_valid);

typedef enum logic { IDLE = 0, ACTIVE = 1} state_t;

state_t valid_state;

always @(posedge clk or negedge reset) begin
    if (!reset) begin
        valid_state <= IDLE;
    end
    else begin
        case (valid_state)
            IDLE: begin
                if (valid_reg)
                    valid_state <= ACTIVE;
            end
            ACTIVE: begin
                if (!valid_reg)
                    valid_state <= IDLE;
            end
        endcase
    end
end

always @(*) begin
    case (valid_state)
        IDLE: Rx_valid = valid_reg;
        ACTIVE: Rx_valid = 0;
    endcase
end

endmodule