`timescale 1ns/1ps

module seq_detect_fsm (
    input  logic clk,
    input  logic rst_n,
    input  logic din,
    output logic detect
);

    // ============================================================
    // State declaration
    // ============================================================
    // 移除寬度限制，交由合成器自動優化編碼方式
    typedef enum {
        IDLE,   // 無有效匹配
        S1,     // 匹配到 "1"
        S10,    // 匹配到 "10"
        S101,   // 匹配到 "101"
        S1011   // 成功匹配到 "1011"
    } state_t;

    state_t curr_state;
    state_t next_state;

    // ============================================================
    // Sequential logic: state register
    // ============================================================
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            curr_state <= IDLE;
        else
            curr_state <= next_state;
    end

    // ============================================================
    // Combinational logic: next-state logic
    // ============================================================
    always_comb begin
        next_state = curr_state;

        case (curr_state)
            IDLE: begin
                if (din)
                    next_state = S1;
                else
                    next_state = IDLE;
            end

            S1: begin
                if (din)
                    next_state = S1;
                else
                    next_state = S10;
            end

            S10: begin
                if (din)
                    next_state = S101;
                else
                    next_state = IDLE;
            end

            S101: begin
                if (din)
                    next_state = S1011; 
                else
                    next_state = S10;  
            end

            S1011: begin
                if (din)
                    next_state = S1;    // 序列變成 10111，保留最後的 "1"
                else
                    next_state = S10;   // 序列變成 10110，保留後綴 "10"（考慮重疊）
            end

            default: begin
                next_state = IDLE;
            end
        endcase
    end

    // ============================================================
    // Output logic (Pure Moore Machine)
    // ============================================================
    assign  detect = (curr_state == S1011);

endmodule