module seq_detect_fv (
    input logic clk,
    input logic rst_n,
    input logic din,
    input logic detect
);
    // ============================================================
    // Sequence Detection Properties
    // ============================================================
    property p_detect_1011;
        @(posedge clk) disable iff (!rst_n)
        din ##1 !din ##1 din ##1 din |=> detect;
    endproperty
    assert_detect_1011: assert property (p_detect_1011);

    // ============================================================
    // FSM State Transition Properties
    // ============================================================
    property p_s1011_to_s10;
        @(posedge clk) disable iff (!rst_n)
        (seq_detect_fsm.curr_state == seq_detect_fsm.S1011 && !din) |=> (seq_detect_fsm.curr_state == seq_detect_fsm.S10);
    endproperty
    assert_s1011_to_s10: assert property (p_s1011_to_s10);

    // ============================================================
    // Sanity Check / Cover
    // ============================================================
    cover_detect_triggered: cover property (@(posedge clk) disable iff (!rst_n) detect);

endmodule

// ============================================================
// Bind 
// ============================================================
bind seq_detect_fsm seq_detect_fv i_seq_detect_fv (
    .clk    (clk),
    .rst_n  (rst_n),
    .din    (din),
    .detect (detect)
);
